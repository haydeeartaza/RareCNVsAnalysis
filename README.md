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
- Modify the config.json [(in qc-pipeline/snakefiles/config.json)](qc-cnv/qc-pipeline/snakefiles/config.json) to include the genotyping files path (report file and intensity signal file) and to specify the ouput directory, in this example directory `Results` will contains all files generted in this pipeline.
``` json
{
        "final_report_file": "/path_to/GSA2016_308_025_FinalReport.txt",
        "signal_intensity_file": "/path_to/signal_intensity.txt",
        "list_signal_files_file": "/Results/data_conversion/list.txt",
        "map_file": "/Results/data_conversion/sample_map.txt",   
        "snp_file": "/Results/data_conversion/SNPfile.txt",
        "pfb_file": "/Results/data_conversion/model.pfb",
        "gcmodel_file": "/Results/data_conversion/hg19.gcmodel",
        "gc_content_file": "/path_to/gc5Base.sorted.txt",
        "hmm_file": "/path_to/hhall.hmm",
        "sample_pass_list_file": "/Results/data_clean/samples_qcpass.list",
        "sample_pass_file": "/Results/data_clean/samples_qcpass.rawcn",
        "sample_summary_file": "/Results/data_clean/samples_qcsum.list",
        "immunoglobulin_region_file": "/path_to/immunoglobulin_penncnv.txt",
        "centromere_telomere_region_file": "/path_to/centromere_telomere_penncnv.txt",
        "sample_clean_file": "/Results/data_clean/samples_qcpass.clean.rawcn",
        "sample_merged_file": "/Results/data_clean/samples_qcpass.clean.merged.rawcn",
        "data_conversion_path": "/Results/data_conversion",
        "data_intensity_path" :  "/Results/data_conversion/data_intensity",
        "data_calling_path": "/Results/data_calling",
        "data_clean_path": "/Results/data_clean",
        "graphic_path": "/Results/graphic",
        "graphic_qc_path": "/Results/graphic/qc",
        "log_path": "/Results/logs"
    
}
```
- Modify the variables.py [(in qc-pipeline/snakefiles/variables.py)](qc-cnv/qc-pipeline/snakefiles/variables.py) to include the programs location, set files prefixes and PennCNV parameters. Pipeline will create the output directories specified in this file and previously set in `config.json` file.
``` phyton
  ### snakemake_workflows initialization ########################################
  libdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../lib'))
  resourcesdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../resources'))

  ### programs ########################################
  plink = "/home/programs/plink"
  bcftools = "/home/programs/bcftools/bcftools-1.8/bin/bcftools"

  ### prefix ########################################
  ### module 1,2 and 3
  signal_prefix = "split"
  calling_prefix = "sampleall"

  ### Workflow parameters ##################################
  ### extensions 
  PLINK_EXT =['.bed','.bim','.fam']
  TPLINK_EXT =['.tped','.tfam']

  ### PennCNV parameters
  qcnumcnv = "50"
  wf = "0.05"
  qcbafdrift = "0.01"
  qclrrsd = "0.3"

  ### Create paths if don't exist ###################################

  if not os.path.exists(config['log_path']):
    os.makedirs(config['log_path'])
  if not os.path.exists(config['data_conversion_path']):
    os.makedirs(config['data_conversion_path'])
  if not os.path.exists(config['data_intensity_path']):
    os.makedirs(config['data_intensity_path'])
  if not os.path.exists(config['data_calling_path']):
    os.makedirs(config['data_calling_path'])
  if not os.path.exists(config['data_clean_path']):
    os.makedirs(config['data_clean_path'])
  if not os.path.exists(config['graphic_path']):
    os.makedirs(config['graphic_path'])
  if not os.path.exists(config['graphic_qc_path']):
    os.makedirs(config['graphic_qc_path'])
```
- Excute the pipeline with the comman line:
```
$ snakemake -s qc-pipeline/snakefiles/qc.snake
```

3. Rare CNVs analysis execution:
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
