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
    python3-dev \
    python3-pip \
    libbz2-dev \
    liblzma-dev \
    xorg-dev \
    xauth \
    libx11-dev \
    libcurl4-gnutls-dev \
    libharfbuzz-dev libfribidi-dev \
    libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev \
    libperl-dev \
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

# Install pipenv and project dependencies
RUN pip install pipenv

# Copy Pipfile and Pipfile.lock into the container
COPY Pipfile Pipfile.lock  .
RUN pipenv install --system --deploy --ignore-pipfile

RUN localedef -i en_US -f UTF-8 en_US.UTF-8 && \
       echo "LANG=en_US.UTF-8" > /etc/locale.conf

ENV LANG en_US.UTF-8

# Download and install PLINK v1.7 in the root directory
RUN wget -q https://s3.amazonaws.com/plink1-assets/1.07/plink1_linux_x86_64.zip && \
    unzip plink1_linux_x86_64.zip -d /usr/local/bin/ && \
    ln -s /usr/local/bin/plink-1.07-x86_64/plink /usr/bin/plink && \
    rm plink1_linux_x86_64.zip

# Download and install PLINK v1.9 in the root directory
RUN wget -q https://s3.amazonaws.com/plink1-assets/dev/plink_linux_x86_64.zip && \
    unzip plink_linux_x86_64.zip -d /usr/local/bin/ && \
    ln -s /usr/local/bin/plink /usr/bin/plink2 && \
    rm plink_linux_x86_64.zip

# Download and install PennCNV v1.0.5 in the root directory
RUN wget https://github.com/WGLab/PennCNV/archive/v1.0.5.tar.gz && \
    tar xvfz v1.0.5.tar.gz && \
    cd PennCNV-1.0.5/kext && \
    make && \
    cd ../..

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
RUN Rscript -e 'install.packages("https://cran.r-project.org/src/contrib/Archive/pbkrtest/pbkrtest_0.4-7.tar.gz", repos=NULL, type="source"); \
    install.packages(scan("requirements.txt", what = "package"), repos="https://cloud.r-project.org"); \
    library(devtools); devtools::install_github("psyteachr/introdataviz", upgrade_dependencies = FALSE)'

# Copy over your pipeline files
COPY . /app/pipeline
WORKDIR /app/pipeline

# Add tool directories to PATH, including PennCNV scripts
ENV PATH "/usr/lib/R/bin:/usr/bin/python3:/usr/local/bin:/PennCNV-1.0.5:$PATH"
