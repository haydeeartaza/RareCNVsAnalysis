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
    x11-apps \
    xvfb xauth xfonts-base \
    cmake \  
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
    libpcre++-dev \
    gawk 

# Use the right falour of awk
RUN ln -sf /usr/bin/gawk awk

# Install pipenv and project dependencies
RUN pip install pipenv

# Copy Pipfile and Pipfile.lock into the container
COPY Pipfile Pipfile.lock  ./
RUN pipenv install --system --deploy --ignore-pipfile

RUN localedef -i en_US -f UTF-8 en_US.UTF-8 && \
       echo "LANG=en_US.UTF-8" > /etc/locale.conf

ENV LANG en_US.UTF-8

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
# package from archive necessary for few other packages
# the versions were picked to build and work within the given R version
COPY ./requirements.txt ./
RUN Rscript -e 'install.packages("devtools", repos="https://cloud.r-project.org", dependencies = TRUE); \
    install.packages(scan("requirements.txt", what = "package"), repos="https://cloud.r-project.org"); \
    library(devtools); devtools::install_version(package="pbkrtest", version="0.4.7", repos="https://cloud.r-project.org"); \
    install.packages("glossary", repos="https://cloud.r-project.org"); \ 
    devtools::install_version(package="ggpubr", version = "0.6.0", repos="https://cloud.r-project.org"); \
    devtools::install_github("psyteachr/introdataviz", upgrade_dependencies = FALSE)'

# Download and install PLINK v1.7 in the root directory
# the default one did not work on this system, using official Debian build for Ubuntu
RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/p/plink/plink_1.07+dfsg-3build1_amd64.deb && \
    dpkg -i plink_1.07+dfsg-3build1_amd64.deb && \
    rm plink_1.07+dfsg-3build1_amd64.deb

# Download and install PLINK v1.9 in the root directory
RUN wget -q https://s3.amazonaws.com/plink1-assets/dev/plink_linux_x86_64.zip && \
    unzip plink_linux_x86_64.zip -d /usr/local/bin/ && \
    ln -s /usr/local/bin/plink /usr/bin/plink2 && \
    rm plink_linux_x86_64.zip

# Copy over your pipeline files
COPY . /app/pipeline
WORKDIR /app/pipeline

# Add tool directories to PATH, including PennCNV scripts
ENV PATH "/usr/lib/R/bin:/usr/bin/python3:/usr/local/bin:/PennCNV-1.0.5:$PATH"
