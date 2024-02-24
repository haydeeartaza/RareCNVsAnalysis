FROM ubuntu:focal-20220426 as base

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    software-properties-common \
    curl \
    rsync \
    wget \
    gnupg \
    ca-certificates \
    unzip \
    python3 \
    python3-pip \
    gfortran \
    build-essential libcurl4-gnutls-dev zlib1g-dev libssl-dev libxml2-dev libxslt1-dev libffi-dev libreadline-dev tk-dev libncursesw5-dev xz-utils \
    libbz2-dev \
    liblzma-dev \
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


RUN pip3 install snakemake

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

# Copy over your pipeline files
COPY . /app/pipeline
WORKDIR /app/pipeline

# Add tool directories to PATH
ENV PATH "/usr/lib/R/bin:$PATH"

# Set default command
CMD ["snakemake"]