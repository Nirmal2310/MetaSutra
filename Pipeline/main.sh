#!/bin/bash

helpFunction()
{
   echo "Usage: main.sh [-s SRR123456] [-r /path/to/reference.fasta] [-t 16]"
   echo -e "\t-s <filename> Name of the input paired-end Fastq file(There's no need to add the file extension)"
   echo -e "\t-r <filename> Name of the Reference Host Genome Fasta File(Include the Path if the fasta file in not in the same directory as the script)"
   echo -e "\t-t <int> Number of threads to be used for the analysis. [default: 16]"
   echo -e "\t-m <int> Amount of memory (GB) to be used for the analysis. [default: 200]"
   echo -e "\t-c <int> Assembly completeness threshold for the metaWRAP pipeline. [default: 55]"
   echo -e "\t-d <int> Contamination threshold for the metaWRAP pipeline. [default: 10]"
   exit 1 # Exit script after printing help
} 

# Default values for the pipeline parameters

threads=16

mem=200

comp=55

cont=10

while getopts "s:r:t:m:c:d:" opt
do
    case "$opt" in
    s )
        sample="$OPTARG"
        ;;
    r )
        ref="$OPTARG"
        ;;
    t )
        threads="$OPTARG"
        ;;
    m )
        mem="$OPTARG"
        ;;
    c )
        comp="$OPTARG"
        ;;
    d )
        cont="$OPTARG"
        ;;
    ? ) helpFunction ;;
    esac
done

if [ -z "$sample" ] || [ -z "$ref" ]
    then
    echo "Please provide atleast the sample name and the reference genome name";
    helpFunction
fi
path=$(which conda | sed "s/\b\/conda\b//g")

if [ -f ${sample}*1.fastq.gz ]
    
    then
    
    forward=$(ls -1 ${sample}*1.fastq.gz)
    
    echo $forward
    
    reverse=$(echo "$forward" | sed "s/1.fastq.gz/2.fastq.gz/g")
    
    echo $reverse
    
    if [[ "$forward" != "${sample}_1.fastq.gz" ]]
        
        then
        
        mv $forward ${sample}_1.fastq.gz
        
        mv $reverse ${sample}_2.fastq.gz
    fi

else
    
    echo "Paired-End Fastq File is Missing.";

fi

if [ -d "${sample}_out" ]; then
	
    echo "Directory Exists"

else
	
    mkdir ${sample}_out
	
    mv ${sample}_1.fastq.gz ${sample}_2.fastq.gz ${sample}_out/

fi

#Preprocessing the Raw Sequencing Reads

source $path/activate fastp

fastp -w $threads --in1 ${sample}_out/${sample}_1.fastq.gz --in2 ${sample}_out/${sample}_2.fastq.gz --out1 ${sample}_out/${sample}_1_trim.fastq.gz --out2 ${sample}_out/${sample}_2_trim.fastq.gz --unpaired1 ${sample}_out/${sample}_se.fastq.gz --unpaired2 ${sample}_out/${sample}_se.fastq.gz  --adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA --adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT --low_complexity_filter -l 36 --average_qual 20

source $path/activate bbtools

seal.sh in1=${sample}_out/${sample}_1_trim.fastq.gz in2=${sample}_out/${sample}_2_trim.fastq.gz ref=$ref ambig=all outu1=${sample}_out/${sample}_final_1.fastq.gz outu2=${sample}_out/${sample}_final_2.fastq.gz threads=${threads} -Xmx${mem}g

seal.sh in1=${sample}_out/${sample}_se.fastq.gz ref=$ref ambig=all outu1=${sample}_out/${sample}_final_se.fastq.gz -Xmx${mem}g

rm -r ${sample}_out/${sample}_1_trim.fastq.gz ${sample}_out/${sample}_2_trim.fastq.gz ${sample}_out/${sample}_se.fastq.gz

gunzip ${sample}_out/${sample}_final_*.fastq.gz

# Assembling the Reads using SPAdes and Binning the Contigs using MetaWRAP

source $path/activate base

spades.py -o ${sample}_out/${sample}_spades_out --threads $threads --meta --only-assembler -1 ${sample}_out/${sample}_final_1.fastq -2 ${sample}_out/${sample}_final_2.fastq -s ${sample}_out/${sample}_final_se.fastq -m $mem

mv ${sample}_out/${sample}_spades_out/contigs.fasta ${sample}_out/${sample}_spades_contigs.fasta

source $path/activate metawrap

metawrap binning -t $threads -m $mem --maxbin2 --metabat2 --concoct --run-checkm -a ${sample}_out/${sample}_spades_contigs.fasta -o ${sample}_out/${sample}_metawrap_binning_results ${sample}_out/${sample}_final_1.fastq ${sample}_out/${sample}_final_2.fastq ${sample}_out/${sample}_final_se.fastq

metawrap bin_refinement -o ${sample}_out/${sample}_metawrap_bin_refinement -t $threads -A ${sample}_out/${sample}_metawrap_binning_results/metabat2_bins/ -B ${sample}_out/${sample}_metawrap_binning_results/maxbin2_bins/ -C ${sample}_out/${sample}_metawrap_binning_results/concoct_bins/ -c $comp -x $cont

metawrap reassemble_bins -o ${sample}_out/${sample}_metawrap_bin_reassemble -1 ${sample}_out/${sample}_final_1.fastq -2 ${sample}_out/${sample}_final_2.fastq -t $threads -m $mem -b ${sample}_out/${sample}_metawrap_bin_refinement/metawrap_${comp}_${cont}_bins

# Annotating the Binned Contigs

source $path/activate gtdbtk

gtdbtk classify_wf --genome_dir ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/ --out_dir ${sample}_out/${sample}_gtdbtk_classified --cpus $threads -x fa --prefix ${sample} --pplacer_cpus $threads

# Manipulating the GTDBTK output to get the lowest taxonomic-level information

awk '{if(NR>1) print $1}' ${sample}_out/${sample}_gtdbtk_classified/classify/${sample}.bac120.summary.tsv | sed 's/^$//g; s/$/.fa/g' > ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp 

awk '{size = split($2,array,";")} {sub(/s__/, "", array[size]); if(NR>1) {if($3~"N/A"){sub(/g__/,"",array[size-1]); print array[size-1]} else {print array[size]"_"$3}}}' ${sample}_out/${sample}_gtdbtk_classified/classify/${sample}.bac120.summary.tsv > ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp2

awk '{ c[$0]++; printf "%s%s\n", $0, (c[$0] > 1 ? "_" c[$0] : "") }' ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp2 > ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp3

mv ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp3 ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp2

paste -d " " ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp2 > ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/list

awk '{size = split($2,array,";");sub("f__","",array[5]);if(NR>1)print array[5]}' ${sample}_out/${sample}_gtdbtk_classified/classify/${sample}.bac120.summary.tsv > ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp3

paste -d "\t" ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp2 ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp3 > ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp4

echo -e "unclassified\tunclassified" | cat ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp4 - > ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp5

echo -e "Classification\tFamily" | cat - ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp5 > ${sample}_out/${sample}_family_info.txt

rm -r ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/tmp*

# Renaming the Contigs headers with their taxonomic lineage annotation

while read p q
do 

    mkdir ${sample}_out/${sample}_${q}_bin 

    cat ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/$p | sed "s/>.*NODE/>$q/g" > ${sample}_out/${sample}_${q}_bin/$q.fasta 

done < "${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/list"

awk '{print $2}' ${sample}_out/${sample}_metawrap_bin_reassemble/reassembled_bins/list > ${sample}_out/list

# Running RGI using all the binned contigs

source $path/activate rgi

if [ -f "$PWD/card.json" ]; then
	
    echo "RGI DataBase Exist."

else
	
    
	rgi load --card_json $RGI_DB --local

fi

while read p
do 

    rgi main -n $threads --input_sequence ${sample}_out/${sample}_${p}_bin/$p.fasta --output ${sample}_out/${sample}_${p}_bin/${p}_rgi --input_type contig --clean --local

    awk -F "\t" '{if(NR>1 && $10 >= 85 && $10 <= 100 && $21 >= 85 && $21 <= 100) print $0}' ${sample}_out/${sample}_${p}_bin/${p}_rgi.txt > ${sample}_out/${sample}_${p}_bin/temp && mv ${sample}_out/${sample}_${p}_bin/temp ${sample}_out/${sample}_${p}_bin/${p}_rgi.txt

done < "${sample}_out/list"

# Getting the Genomic Locations of Respective ARGs from the RGI Output

while read p 
do 
    
    lines=$(wc -l < ${sample}_out/${sample}_${p}_bin/${p}_rgi.txt)

    if [ "$lines" -le 0 ]; then
        
	echo "NO ARGs FOUND FOR ${p}. CHECKING FOR NEXT BIN."
    
    else

        awk -F "\t" '{print $2}' ${sample}_out/${sample}_${p}_bin/${p}_rgi.txt | sed 's/\(cov_[^_]*\)_.*$/\1/' > ${sample}_out/${sample}_${p}_bin/tmp
    
        awk -F "\t" '{print ":"$3"-"$4,$5}' ${sample}_out/${sample}_${p}_bin/${p}_rgi.txt > ${sample}_out/${sample}_${p}_bin/tmp2
    
        paste -d "" ${sample}_out/${sample}_${p}_bin/tmp ${sample}_out/${sample}_${p}_bin/tmp2 > ${sample}_out/${sample}_${p}_bin/tmp3
    
        awk 'BEGIN {FS="\t"}{print $9}' ${sample}_out/${sample}_${p}_bin/${p}_rgi.txt | awk '{gsub(/[[:punct:]]/, ""); gsub(/ /, "_"); print $0}' > ${sample}_out/${sample}_${p}_bin/tmp4

        awk -F "\t" '{print $2}' ${sample}_out/${sample}_${p}_bin/${p}_rgi.txt > ${sample}_out/${sample}_${p}_bin/tmp5
    
        while read -r line 
        do 
        
            echo $p >> ${sample}_out/${sample}_${p}_bin/tmp6
    
        done < "${sample}_out/${sample}_${p}_bin/tmp"

        paste -d " " ${sample}_out/${sample}_${p}_bin/tmp3 ${sample}_out/${sample}_${p}_bin/tmp4 ${sample}_out/${sample}_${p}_bin/tmp5 ${sample}_out/${sample}_${p}_bin/tmp6  > ${sample}_out/${sample}_${p}_bin/arg_coordinates

        rm -r ${sample}_out/${sample}_${p}_bin/tmp*

        echo "$p" >> ${sample}_out/arg_list
    fi

done < "${sample}_out/list"

# Indexing the Individual Assembly Fasta files to get the AMR genes

source $path/activate bwa

while read p 
do 

    samtools faidx ${sample}_out/${sample}_${p}_bin/$p.fasta 

done < "${sample}_out/list"

while read i
do
    while read p q r s t
    do
        
        samtools faidx ${sample}_out/${sample}_${i}_bin/$t.fasta $p | sed "s/>.*$/>${s}_${r}/g" >> ${sample}_out/${sample}_${i}_bin/${i}_amr.fasta
    
    done < "${sample}_out/${sample}_${i}_bin/arg_coordinates"

done < "${sample}_out/arg_list"

# Concatenating unclassified contigs into a single file

grep ">" ${sample}_out/${sample}_metawrap_bin_refinement/metawrap_${comp}_${cont}_bins/*.fa | sed 's/^.*>//g' > ${sample}_out/${sample}_passed_headers

grep ">" ${sample}_out/${sample}_spades_contigs.fasta | grep -v -f ${sample}_out/${sample}_passed_headers | sed 's/>//g' > ${sample}_out/${sample}_failed_headers

source $path/activate bwa

samtools faidx ${sample}_out/${sample}_spades_contigs.fasta

source $path/activate seqkit

seqkit grep -j $threads -f ${sample}_out/${sample}_failed_headers ${sample}_out/${sample}_spades_contigs.fasta > ${sample}_out/${sample}_unclassified_contigs.fasta

mkdir ${sample}_out/${sample}_unclassified_bin

# Running RGI using all unbinned contigs

source $path/activate rgi

rgi main -n $threads --input_sequence ${sample}_out/${sample}_unclassified_contigs.fasta --output ${sample}_out/${sample}_unclassified_bin/unclassified_rgi --input_type contig --clean --local

awk -F "\t" '{if(NR>1 && $10 >= 85 && $10 <= 100 && $21 >= 85 && $21 <= 100) print $0}' ${sample}_out/${sample}_unclassified_bin/unclassified_rgi.txt > ${sample}_out/${sample}_unclassified_bin/temp  && mv ${sample}_out/${sample}_unclassified_bin/temp ${sample}_out/${sample}_unclassified_bin/unclassified_rgi.txt

# Getting the Genomic Locations of Respective ARGs from the RGI Output

lines=$(wc -l < ${sample}_out/${sample}_unclassified_bin/unclassified_rgi.txt)

if [ "$lines" -le 0 ]; then

    echo "No ARGs Found For UNCLASSIFIED BIN."
else

    awk -F "\t" '{ print $2}' ${sample}_out/${sample}_unclassified_bin/unclassified_rgi.txt | sed 's/\(cov_[^_]*\)_.*$/\1/' > ${sample}_out/${sample}_unclassified_bin/tmp

    awk -F "\t" '{ print ":"$3"-"$4,$5}' ${sample}_out/${sample}_unclassified_bin/unclassified_rgi.txt > ${sample}_out/${sample}_unclassified_bin/tmp2

    paste -d "" ${sample}_out/${sample}_unclassified_bin/tmp ${sample}_out/${sample}_unclassified_bin/tmp2 > ${sample}_out/${sample}_unclassified_bin/tmp3

    awk 'BEGIN {FS="\t"}{ print $9}' ${sample}_out/${sample}_unclassified_bin/unclassified_rgi.txt | awk '{gsub(/[[:punct:]]/, ""); gsub(/ /, "_"); print $0}' > ${sample}_out/${sample}_unclassified_bin/tmp4

    awk -F "\t" '{print $2}' ${sample}_out/${sample}_unclassified_bin/unclassified_rgi.txt > ${sample}_out/${sample}_unclassified_bin/tmp5

    paste -d " " ${sample}_out/${sample}_unclassified_bin/tmp3 ${sample}_out/${sample}_unclassified_bin/tmp4 ${sample}_out/${sample}_unclassified_bin/tmp5 > ${sample}_out/${sample}_unclassified_bin/arg_coordinates

    rm -r ${sample}_out/${sample}_unclassified_bin/tmp*

    source $path/activate bwa

    samtools faidx ${sample}_out/${sample}_unclassified_contigs.fasta

    while read p q r s
    do

        samtools faidx ${sample}_out/${sample}_unclassified_contigs.fasta $p | sed "s/>.*$/>${s}_${r}/g" >> ${sample}_out/${sample}_unclassified_bin/${sample}_unclassified_amr.fasta

    done < "${sample}_out/${sample}_unclassified_bin/arg_coordinates"
fi

# Concatenating the AMR Fasta files to get the Counts

cat ${sample}_out/${sample}_*_bin/*_amr.fasta > ${sample}_out/${sample}_amr_genes.fasta

source $path/activate bwa

samtools faidx ${sample}_out/${sample}_amr_genes.fasta

bwa index ${sample}_out/${sample}_amr_genes.fasta

bwa mem -t ${threads} ${sample}_out/${sample}_amr_genes.fasta ${sample}_out/${sample}_final_1.fastq ${sample}_out/${sample}_final_2.fastq | samtools view -@ $threads -q 1 -bS | samtools sort -@ $threads -o ${sample}_out/${sample}_amr_mapped.sorted.bam

samtools index -@ $threads ${sample}_out/${sample}_amr_mapped.sorted.bam

samtools idxstats ${sample}_out/${sample}_amr_mapped.sorted.bam | awk 'BEGIN{FS=" "; OFS="\t"}{print $1,$2,$3}' > ${sample}_out/temp

sed -i "$ d" ${sample}_out/temp

ls -d ${sample}_out/${sample}*_bin/ | sed "s/${sample}_out\/${sample}_//g;s/_bin//g;s/\///g" > ${sample}_out/bin_list

while read p; do cat ${sample}_out/${sample}_${p}_bin/${p}_rgi.txt | while read line; do echo $p; done; done < "${sample}_out/bin_list" | sed 's/_/ /g' > ${sample}_out/temp2

awk 'BEGIN{FS="\t";OFS="\t"}{ print $9,$10,$15,$16,$17,$21}' ${sample}_out/${sample}_*_bin/*_rgi.txt | paste -d "\t" ${sample}_out/temp - ${sample}_out/temp2 > ${sample}_out/temp3

echo -e "ARG\tORF_length\tCounts\tARO_term\tPercentage_Identity\tDrug_Class\tResistance_Mechanism\tAMR_Gene_Family\tPercentage_Coverage\tClassification" | cat - ${sample}_out/temp3 > ${sample}_out/${sample}_consolidated_final_arg_counts.txt

rm -r ${sample}_out/temp*

source $path/activate base
