#!/bin/bash

helpFunction()
{
   echo "Usage: metasutra_run.sh [-s SRR123456] [-r /path/to/reference.fasta] [-t 16]"
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

DOCKERCMD="time -o metashiny_${sample}_${threads}.txt docker run -v $PWD:$PWD --name metashiny_${threads} --cpus ${threads} --memory ${mem}g --workdir $PWD --rm metashiny:latest bash /module/main.sh -s ${sample} -r ${ref} -t ${threads} -m ${mem} -c ${comp} -d ${cont}"

date +"[%Y-%m-%d %H:%M:%S] Starting Run using the contained : metashiny:latest"

$DOCKERCMD &

while true 
do
	DOCKERID=$(docker ps --format '{{.ID}}')
	if [ -z "$DOCKERID" ];then
	 echo "Not running"
	else
	docker stats --no-stream | grep metashiny_${threads} | awk '{print $4}' >> metashiny_${sample}_${threads}_mem_usage.txt &  docker stats --no-stream | grep metashiny_${threads} | awk '{print $3}' >> metashiny_${sample}_${threads}_cpu_usage.txt &  docker stats --no-stream | grep metashiny_${threads} | awk '{print $7}' >> metashiny_${sample}_${threads}_peak_mem.txt;
	docker ps --no-trunc | grep "${DOCKERID}" >/dev/null;
		if [ $? -ne 0 ];then
		
		break
		
		fi
	fi
done

date +"[%Y-%m-%d %H:%M:%S] Finished benchmark"
