Rare CNVs Analysis Pipeline
======

Overwiew
-----------------------------
This pipeline is a generic bioinformatic solution to identify rare CNVs in case-control based studies. Using SNPs-array genotyping data, this pipeline performs the CNV detection and quality control, followed by the burden analysis, the rare CNV frequency analysis and the enrichment CNV analysis [see pipeline workflow](manual/images/Rare_CNV_pipeline-drawio.png).

Dependencies
-----------------------------
- Snakemake 5.22.1
- Python 3.8.5
- R 3.6.3

Installation
-----------------------------
1. Snakemake
Installation via Conda:
- conda install -n base -c conda-forge mamba
- mamba create -c conda-forge -c bioconda -n snakemake snakemake
- conda activate snakemake
Find other options in [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html)

2. R dependencies
``` r
#Install all libraries used in this pipeline
# Package names
packages <- c("ggplot2", "fmsb", "gridExtra", "dplyr", "reshape", "introdataviz")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
```
Pipeline Execution
-----------------------------
1. Download the git project:
```
$ git clone  https://github.com/haydeeartaza/RareCNVsAnalysis.git
```
2. Detection calls and QC analysis execution: 
```
$ cd qc-cnv
```
Modify the config.json [(in qc-pipeline/snakefiles)](qc-cnv/qc-pipeline/snakefiles/config.json) to include the genotyping files path (report file and intensity signal file)
![config.json](manual/images/config_QC_file.png)

Modify the variables.py [(in qc-pipeline/snakefiles)](qc-cnv/qc-pipeline/snakefiles/variables.py) to include the programs location, parameters and ouput paths.
![variable.py](manual/images/variables_QC_file.png)

Excute:
```
$ snakemake -s qc-pipeline/snakefiles/qc.snake
```

Rare CNVs analysis execution:
```
$ cd association-cnv
```
Modify the config.json and variables.json files in association-pipeline/snakefiles, and then excute
```
$ snakemake -s association-pipeline/snakefiles/association.snake
```
![Output directroies](manual/images/pipeline_output_dirs.png)

Details about config, input/output files and a module/rule description see [user guide manual](manual/Rare_CNVs_pipeline_guide.pdf)

Pipeline Structure
-----------------------------
The pipeline consists of two major tasks: (1) quality control analysis, which uses the SNP-array genotyping data (green box) as an input to obtain good-quality samples and high-quality calls. (2) rare CNVs analysis, which takes samples and calls from the QC pipeline output, and after the data format conversion, performs the burden, rare CNVs and enrichment analysis. Black dotted lines split each analysis in their corresponding modules, purple boxes represent a specific task in each module, yellow boxes show representative outputs (files and/or plots), and the blue box represents external functions used by some modules. Dotted purple boxes are optional tasks which could be easily removed or changed to adapt the pipeline with the study requirements.

![Pipeline workflow](manual/images/Rare_CNV_pipeline-drawio.png)
