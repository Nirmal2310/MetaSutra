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

if [ ! -f card.json ]; then

        wget https://card.mcmaster.ca/latest/data
        tar -xvf data ./card.json && rm -r data
fi

grep -qF "export Pfam_DATA=\"$base_dir\"" ~/.bashrc || echo "export Pfam_DATA=\"$base_dir\"" >> ~/.bashrc

grep -qF "export RGI_DB=\"$base_dir/card.json\"" ~/.bashrc || echo "export RGI_DB=\"$base_dir/card.json\"" >> ~/.bashrc

source ~/.bashrc

if [ -f Pfam-A.hmm ]; then
        echo "File Exists."
else
        wget https://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz

        gunzip Pfam-A.hmm.gz
fi

if { conda env list |  grep "rgi"; } > /dev/null 2>&1; then

        echo "Environment Exist"

else

        conda create --name rgi --file rgi.txt

fi

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

if { which spades.py; } >/dev/null 2>&1; then
        
        echo "SPAdes Exist"
        
        source ~/.bashrc

else
        wget -c https://github.com/ablab/spades/releases/download/v3.15.5/SPAdes-3.15.5.tar.gz

        tar -xvf SPAdes-3.15.5-Linux.tar.gz && rm -r SPAdes-3.15.5-Linux.tar.gz

        cd SPAdes-3.15.5-Linux

        grep -qF "export PATH=\"$PWD/bin:" ~/.bashrc || echo "export PATH=\"$PWD/bin:\$PATH\"" >> ~/.bashrc

        source ~/.bashrc

        cd $base_dir

fi

if { conda env list | grep "metawrap"; } >/dev/null 2>&1; then
        
        echo "Environment Exist"

else
        
        git clone https://github.com/bxlab/metaWRAP.git
        
        grep -qF "export PATH=\"$PWD/metaWRAP/bin/:" ~/.bashrc || echo "export PATH=\"$PWD/metaWRAP/bin/:\$PATH\"" >> ~/.bashrc
        
        source ~/.bashrc
        
        conda create --name metawrap --file metawrap.txt
        
        if [ ! -d DATA ]; then
        
                mkdir DATA
        fi

        cd DATA

        if [ ! -d CHECKM_DATA ]; then
                
                mkdir CHECKM_DATA
        fi
        
        # Download CHECKM Data (Required by metaWRAP)
        
        cd CHECKM_DATA
        
        wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
        
        tar -xvf *.tar.gz
        
        rm *.tar.gz*
        
        source $path/activate metawrap
        
        echo -e "cat << EOF\n$PWD\nEOF\n" | checkm data setRoot
        
        source $path/activate base
        
        cd $base_dir

fi
if { conda env list | grep "gtdbtk"; } >/dev/null 2>&1; then
        
        echo "Environment Exist"

else
        
        conda create --name gtdbtk --file gtdbtk.txt
        
        cd DATA

        if [ ! -d gtdbtk_data ]; then

                wget -c --no-check-certificate https://data.gtdb.ecogenomic.org/releases/release220/220.0/auxillary_files/gtdbtk_package/full_package/gtdbtk_r220_data.tar.gz -O gtdbtk_data.tar.gz
        
                mkdir gtdbtk_data
                
                tar -xvf gtdbtk_data.tar.gz -C gtdbtk_data --strip 1
        
                rm -rf gtdbtk_data.tar.gz
        fi
        
        cd gtdbtk_data
        
        source $path/activate gtdbtk

        conda env config vars set GTDBTK_DATA_PATH="$PWD"

        source $path/deactivate

        source $path/activate gtdbtk # Reactivating Environment to Save Changes

        source $path/activate base
        
        cd $base_dir

fi

if { conda env list | grep "seqkit";} > /dev/null 2>&1; then

        echo "Environment Exist"

else
        
        conda create --name seqkit --file seqkit.txt
        
fi
