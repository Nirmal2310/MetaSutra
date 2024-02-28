ARG osversion=18.04
FROM ubuntu:${osversion}

ARG VERSION=master
ARG VCS_REF
ARG BUILD_DATE

RUN echo "VCS_REF: "${VCS_REF}", BUILD_DATE: "${BUILD_DATE}", VERSION: "${VERSION}

RUN echo "Acquire::http::Proxy \"http://xen03.iitd.ac.in:3128/\"; Acquire::https::Proxy \"http://xen03.iitd.ac.in:3128/\"; Acquire::ftp::Proxy \"http://xen03.iitd.ac.in:3128/\";" > /etc/apt/apt.conf # Change the Proxy Accordingly

RUN apt update && \
    apt install --yes \
       locales
RUN locale-gen en_GB.UTF-8

ENV DEBIAN_FRONTEND=noninteractive LANG=en_GB.UTF-8 LANGUAGE=en_GB:UTF-8 LC_ALL=en_GB.UTF-8

RUN apt install --yes \
        software-properties-common && \
    apt update && \
    apt install --yes \
       nvi \
       nano \
       libbsd-dev \
       liblog-log4perl-perl \
       libmoose-perl \
       libfile-which-perl \
       libipc-run-perl \
       libterm-progressbar-perl \
       libgraph-perl \
       liblist-moreutils-perl \
       build-essential \
       git \
       wget

ENV http_proxy="http://xen03.iitd.ac.in:3128" # Change the Proxy Accordingly

ENV https_proxy="http://xen03.iitd.ac.in:3128" # Change the Proxy Accordingly

RUN cd /tmp/ && \
    wget -O - -c https://github.com/ablab/spades/releases/download/v3.15.5/SPAdes-3.15.5-Linux.tar.gz | \
       tar -xzf - && mv SPAdes-3.15.5-Linux/ /opt/spades/

ENV PATH "/opt/spades/bin/:$PATH"

# Setup of /data volume and set it as working directory

VOLUME /fungel/MetaShiny/docker/base

WORKDIR /fungel/MetaShiny/docker/base
