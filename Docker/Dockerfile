ARG baseimageversion=latest

FROM base:${baseimageversion}

ARG VERSION=master

ARG VCS_REF

ARG BUILD_DATE

RUN echo "VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

ENV http_proxy="http://xen03.iitd.ac.in:3128" # Change the Proxy Accordingly

ENV https_proxy="http://xen03.iitd.ac.in:3128" # Change the Proxy Accordingly

RUN mkdir /module

WORKDIR /module

RUN wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /module/miniconda.sh && chmod +x /module/miniconda.sh && bash /module/miniconda.sh -b -p /module/miniconda && rm -rf /module/miniconda.sh

ENV PATH="/module/miniconda/bin:/opt/spades/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

RUN conda config --add channels defaults

RUN conda config --add channels bioconda

RUN conda config --add channels conda-forge

RUN conda config --add channels flomertens

ADD bbtools.txt .

ADD bwa.txt .

ADD fastp.txt .

ADD gtdbtk.txt .

ADD metawrap.txt .

ADD rgi.txt .

ADD seqkit.txt .

ENV path="/module/miniconda/bin"

ENV gtdbtk_path="/module/miniconda"

RUN wget https://card.mcmaster.ca/latest/data && tar -xvf data ./card.json && rm -r data

ENV RGI_DB="/module/card.json"

RUN conda create --name rgi --file rgi.txt

RUN conda create --name bwa --file bwa.txt

RUN conda create --name bbtools --file bbtools.txt

RUN conda create --name fastp --file fastp.txt

RUN git clone https://github.com/bxlab/metaWRAP.git

ENV PATH="/module/miniconda/bin:/opt/spades/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/module/metaWRAP/bin/:$PATH"

RUN conda create --name metawrap --file metawrap.txt

RUN mkdir CHECKM_DATA

WORKDIR /module/CHECKM_DATA

RUN wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz

RUN tar -xvf *.tar.gz

RUN rm *.tar.gz*

SHELL ["/bin/bash", "-c"]

RUN source /module/miniconda/bin/activate metawrap

RUN echo -e "cat << EOF\n/module/CHECKM_DATA\nEOF\n" | /module/miniconda/envs/metawrap/bin/checkm data setRoot /module/CHECKM_DATA

RUN source /module/miniconda/bin/activate base

WORKDIR /module

RUN conda create --name gtdbtk --file gtdbtk.txt

RUN mkdir DATA

WORKDIR /module/DATA

RUN wget -c --no-check-certificate https://data.gtdb.ecogenomic.org/releases/release95/95.0/auxillary_files/gtdbtk_r95_data.tar.gz

RUN tar -xvf gtdbtk_r95_data.tar.gz

RUN rm -rf *.tar.gz*

WORKDIR /module/DATA/release95

RUN echo "export GTDBTK_DATA_PATH=/module/DATA/release95/" > /module/miniconda/envs/gtdbtk/etc/conda/activate.d/gtdbtk.sh

WORKDIR /module

RUN conda create --name seqkit --file seqkit.txt

ADD main.sh .
