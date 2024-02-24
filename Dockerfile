FROM ubuntu:22.04 as base

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    software-properties-common \
    curl \
    rsync \
    wget \
    gnupg \
    ca-certificates \
    unzip \
    gfortran \
    build-essential checkinstall \
    libcurl4-gnutls-dev zlib1g-dev libssl-dev libxml2-dev libxslt1-dev libffi-dev libreadline-dev tk-dev libncursesw5-dev xz-utils \
    python3 \
    python3-pip \
    libbz2-dev \
    liblzma-dev \
    xorg-dev \
    libcurl4-gnutls-dev \
    tar \
    git \
    git-lfs \
    bedtools \
    autoconf \
    automake \
    vcftools \
    bcftools \
    locales \
    libpcre++-dev


#RUN pip3 install snakemake

# Install pipenv and project dependencies
RUN pip install pipenv

# Copy Pipfile and Pipfile.lock into the container
COPY Pipfile Pipfile.lock  /app/
RUN pipenv install --ignore-pipfile

RUN localedef -i en_US -f UTF-8 en_US.UTF-8 && \
       echo "LANG=en_US.UTF-8" > /etc/locale.conf

ENV LANG en_US.UTF-8

# Install R and required packages
ENV R_VERSION 3.6.3
RUN wget https://cran.r-project.org/src/base/R-3/R-${R_VERSION}.tar.gz && \
        tar xvzf R-${R_VERSION}.tar.gz && \
        cd R-${R_VERSION} && \
        ./configure --with-x=yes --with-readline=no --with-PCRE=no --build=aarch64-unknown-linux-gnu && \
        make && \
        make install && \
        cd ..

# Install additional R packages
COPY ./requirements.txt .
RUN Rscript -e 'install.packages(scan("requirements.txt", what = "package"), repos="https://cloud.r-project.org")'

# library(devtools); devtools::install_github("psyteachr/introdataviz")

# Copy over your pipeline files
COPY . /app/pipeline
WORKDIR /app/pipeline

# Add tool directories to PATH
ENV PATH "/usr/lib/R/bin:$PATH"