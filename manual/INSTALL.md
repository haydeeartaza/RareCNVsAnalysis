Rare CNVs Analysis Pipeline
======

Installation
-----------------------------
1. Mambaforge
```
$ curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
$ bash Miniforge3-$(uname)-$(uname -m).sh
```
&ensp;Set environment path (.profile /.bashrc):
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
$ add path "path_to/PennCNV-1.0.5/" to qc-cnv/qc-pipeline/snakefiles/variables.py 
```
&ensp;More details at [PennCNV documentation](https://penncnv.openbioinformatics.org/en/latest/user-guide/install/)

4. Plink
```
$ wget  https://zzz.bwh.harvard.edu/plink/dist/plink-1.07-x86_64.zip
$ unzip plink-1.07-x86_64.zip
$ add path “plink-1.07-x86_64/plink” to association_cnv/association-pipeline/snakefiles/variables.py
```
