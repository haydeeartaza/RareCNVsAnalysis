Rare CNVs Analysis Pipeline
======

Installation
-----------------------------
1. Mambaforge
```
$ curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
$ bash Miniforge3-$(uname)-$(uname -m).sh
```
&ensp;Set environment path:
```
$ MINIFORGE="/path/miniforge3/bin/"
$ export PATH="$PATH:$MINIFORGE"
```

2. Snakemake
&ensp;Installation via Conda:
```
$ conda install -n base -c conda-forge mamba
$ mamba create -c conda-forge -c bioconda -n snakemake snakemake
$ conda activate snakemake
```
&ensp;Find other options in [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html)

3. PennCNV
```
$ wget https://github.com/WGLab/PennCNV/archive/v1.0.5.tar.gz
$ tar xvfz v1.0.5.tar.gz
$ cd PennCNV-1.0.5/kext
$ make
```
&ensp;More details at [PennCNV documentation](https://penncnv.openbioinformatics.org/en/latest/user-guide/install/)

4. Bedtools
```
$ wget https://github.com/arq5x/bedtools2/releases/download/v2.29.1/bedtools-2.31.1.tar.gz
$ tar -xvzf bedtools-2.31.1.tar.gz
$ cd bedtools2/
$ make
$ Add path “bedtools2/bin” to variables.py 

5. R dependencies
``` r
#Install all libraries used in this pipeline
# Package names
packages <- c("ggplot2", "fmsb", "gridExtra", "dplyr", "reshape", "devtools")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
devtools::install_github("psyteachr/introdataviz")
## Before install devtools library
## apt-get install libssl-dev
## apt-get install libfontconfig1-dev
## apt-get install libharfbuzz-dev libfribidi-dev
## apt-get install libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev
## apt-get install libcurl4-openssl-dev
## apt-get install cmake

```

