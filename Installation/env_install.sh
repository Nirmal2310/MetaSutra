#!/bin/bash
if which conda >/dev/null; then
        echo "Conda Exist"
else
        source ~/.bashrc
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
        && chmod +x miniconda.sh && bash miniconda.sh -b -p miniconda
        base_dir=$(echo $PWD)
        export PATH=$base_dir/miniconda/bin:$PATH
        source ~/.bashrc
        echo -e "$base_dir/miniconda/etc/profile.d/conda.sh" >> ~/.profile
        conda init bash
fi
path=$(which conda | sed "s/\b\/conda\b//g")
gtdbtk_path=$(which conda | sed "s/\b\/bin\/conda\b//g")
base_dir=$PWD
echo "export Pfam_DATA=\"$base_dir\"" >> ~/.bashrc
echo "export RGI_DB=\"$base_dir/localDB\"" >> ~/.bashrc
source ~/.bashrc
wget https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz
gunzip Pfam-A.hmm.gz
docker pull finlaymaguire/rgi:6.0.1
if { conda env list | grep "bwa"; } >/dev/null 2>&1; then
        echo "Environment Exist"
else
        conda create --name bwa --file bwa.txt
fi
if { conda env list | grep "bbtools"; } >/dev/null 2>&1; then
        echo "Environment Exist"
else
        conda create --name bbtools --file bbtools.txt
fi
if { conda env list | grep "fastp"; } >/dev/null 2>&1; then
        echo "Environment Exist"
else
        conda create --name fastp --file fastp.txt
fi
if { conda env list | grep "spades"; } >/dev/null 2>&1; then
        echo "Environment Exist"
else
        conda create --name spades --file spades.txt
fi
if { conda env list | grep "metawrap"; } >/dev/null 2>&1; then
        echo "Environment Exist"
else
        git clone https://github.com/bxlab/metaWRAP.git
        echo "export PATH=\"$PWD/metaWRAP/bin/:\$PATH\"" >> ~/.bashrc
        source ~/.bashrc
        conda create --name metawrap --file metawrap.txt
        mkdir DATA && cd DATA
        # Download CHECKM Data (Required by metaWRAP)
        mkdir CHECKM_DATA
        cd CHECKM_DATA
        wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
        tar -xvf *.tar.gz
        rm *.gz 
        source $path/activate metawrap
        checkm data setRoot ./
        source $path/activate base
        cd ../
        # Downloading NCBI Nucleotide Data (Required by metaWRAP)
        mkdir NCBI_nt && cd NCBI_nt 
        for i in {00..60} 
        do 
                wget -c https://ftp.ncbi.nlm.nih.gov/blast/db/nt.$i.tar.gz 
                tar -xvf nt.$i.tar.gz 
                rm -r nt.$i.tar.gz
        done
        cd ..
        nt=$PWD/NCBI_nt
        sed -i "s.BLASTDB=/scratch/gu/NCBI_nt.BLASTDB=$nt.g" $base_dir/metaWRAP/bin/config-metawrap  
        # Downloading NCBI Taxonomy Data (Required by metaWRAP)
        mkdir NCBI_tax && cd NCBI_tax 
        wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
        tar -xvf *.tar.gz
        cd ..
        tax=$PWD/NCBI_tax
        sed -i "s.TAXDUMP=/scratch/gu/NCBI_tax.TAXDUMP=$tax.g" $base_dir/metaWRAP/bin/config-metawrap
        cd $base_dir
fi
if { conda env list | grep "gtdbtk"; } >/dev/null 2>&1; then
        echo "Environment Exist"
else
        conda create --name gtdbtk --file gtdbtk.txt
        cd DATA
        wget -c --no-check-certificate https://data.gtdb.ecogenomic.org/releases/release95/95.0/auxillary_files/gtdbtk_r95_data.tar.gz
        tar -xvf gtdbtk_r95_data.tar.gz 
        rm -rf *.tar.gz
        cd release95
        echo "export GTDBTK_DATA_PATH=$PWD/" > $gtdbtk_path/envs/gtdbtk/etc/conda/activate.d/gtdbtk.sh
        cd $base_dir
fi
if { conda env list | grep "plasmidverify"; } >/dev/null 2>&1; then
        echo "Environment Exist"
else
        conda create --name plasmidverify --file plasmidverify.txt
        git clone https://github.com/ablab/plasmidVerify.git
        echo "export PATH=\"$PWD/plasmidVerify/:\$PATH\"" >> ~/.bashrc
        source ~/.bashrc
fi
if { conda env list | grep "plannotate"; } >/dev/null 2>&1; then
        echo "Environment Exist"
else
        git clone --depth 1 --branch master https://github.com/barricklab/pLannotate.git
        cd pLannotate
        conda install -y -c conda-forge mamba
        mamba env create -f environment.yml
        source $path/activate plannotate
        conda install -y -c conda-forge streamlit=1.2.0
        echo "" > requirements.txt
        pip install . --no-deps -vv
        plannotate setupdb
        cd ..
fi
if { conda env list | grep "R-4.2"; } >/dev/null 2>&1; then
        echo "Environment Exist"
else
        conda create --name R-4.2 --file R-4.2.txt
fi
