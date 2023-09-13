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

if [ ! -d localDB ]; then

        unzip localDB.zip 
        rm -rf localDB.zip
fi

grep -qF "export Pfam_DATA=\"$base_dir\"" ~/.bashrc || echo "export Pfam_DATA=\"$base_dir\"" >> ~/.bashrc

grep -qF "export RGI_DB=\"$base_dir/localDB\"" ~/.bashrc || echo "export RGI_DB=\"$base_dir/localDB\"" >> ~/.bashrc

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
        wget -c http://cab.spbu.ru/files/release3.15.5/SPAdes-3.15.5-Linux.tar.gz

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
        
        # Download CHECKM Data (Required by metaWRAP)
        if [ ! -d CHECKM_DATA ]; then
                
                mkdir CHECKM_DATA
        fi
        
        cd CHECKM_DATA
        
        wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
        
        tar -xvf *.tar.gz
        
        rm *.tar.gz* 
        
        source $path/activate metawrap
        
        checkm data setRoot $PWD
        
        source $path/activate base
        
        cd $base_dir
        
fi

if { conda env list | grep "gtdbtk"; } >/dev/null 2>&1; then
        
        echo "Environment Exist"

else
        
        conda create --name gtdbtk --file gtdbtk.txt
        
        cd DATA
        
        if [ ! -d release95 ]; then
                
                wget -c --no-check-certificate https://data.gtdb.ecogenomic.org/releases/release95/95.0/auxillary_files/gtdbtk_r95_data.tar.gz
        
                tar -xvf gtdbtk_r95_data.tar.gz 
        
                rm -rf *.tar.gz*
        fi
        
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
