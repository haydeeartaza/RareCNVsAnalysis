Rare CNVs Analysis Pipeline
======

Overwiew
-----------------------------
This pipeline is a generic bioinformatic solution to identify rare CNVs in case-control based studies. Using SNPs-array genotyping data, this pipeline performs the CNV detection and quality control, followed by the burden analysis, the rare CNV frequency analysis and the enrichment CNV analysis [see pipeline workflow](manual/images/Rare_CNV_pipeline-drawio.png).

Dependencies
-----------------------------
- Mambaforge3
- Snakemake 5.22.1
- Python 3.8.5
- R (>=3.6.3)
- Python (>=3.8.5)
- BedTools
- plink (1.7)
- PennCNV (1.0.5)

Installation
-----------------------------
See Snakemake and dependencies installation [here](manual/INSTALL.md)

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
- Modify config.json file [(in qc-pipeline/snakefiles/config.json)](qc-cnv/qc-pipeline/snakefiles/config.json)  including the genotyping files path (report file and intensity signal file) and specifying the ouput directory. In this example directory `Results` will contains all files generted in this pipeline and `path_to` refers to the directory containing requeried files for the pipeline execution.
``` json
{
    "final_report_file": "/data/GSA-24-v3-0-a1-demo-data-12_FinalReport.txt",
    "signal_intensity_file": "/data/SNPs_Table.txt",
    
    "gc_content_file": "/RareCNVsAnalysis/qc-cnv/resources/gc5Base.sorted.txt",
    "hmm_file": "/RareCNVsAnalysis/qc-cnv/resources/hhall.hmm",
    "immunoglobulin_region_file": "/RareCNVsAnalysis/qc-cnv/resources/immunoglobulin_penncnv.txt",
    "centromere_telomere_region_file": "/RareCNVsAnalysis/qc-cnv/resources/centromere_telomere_penncnv.txt",

    "list_signal_files_file": "/QCResults/data_conversion/list.txt",
    "map_file": "/QCResults/data_conversion/sample_map.txt",   
    "snp_file": "/QCResults/data_conversion/SNPfile.txt",
    "pfb_file": "/QCResults/data_conversion/model.pfb",
    "gcmodel_file": "/QCResults/data_conversion/hg19.gcmodel",
    "sample_pass_list_file": "/QCResults/data_clean/samples_qcpass.list",
    "sample_pass_file": "/QCResults/data_clean/samples_qcpass.rawcn",
    "sample_summary_file": "/QCResults/data_clean/samples_qcsum.list",
    "sample_clean_file": "/QCResults/data_clean/samples_qcpass.clean.rawcn",
    "sample_merged_file": "/QCResults/data_clean/samples_qcpass.clean.merged.rawcn",
   
    "data_conversion_path": "/QCResults/data_conversion",
    "data_intensity_path" :  "/QCResults/data_conversion/data_intensity",
    "data_calling_path": "/QCResults/data_calling",
    "data_clean_path": "/QCResults/data_clean",
    "graphic_path": "/QCResults/graphic",
    "graphic_qc_path": "/QCResults/graphic/qc",
    "log_path": "/QCResults/logs"
}
```
- Modify variables.py file [(in qc-pipeline/snakefiles/variables.py)](qc-cnv/qc-pipeline/snakefiles/variables.py) including programs location and setting files prefixes and PennCNV parameters. This pipeline will create the output directories specified in this file that were previously set in `config.json` file.
```python
  ### snakemake_workflows initialization ########################################
libdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../lib'))
resourcesdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../resources'))

### programs ########################################
#Include here all programs and versions.You can run the specific program/version
#calling it as {program_version} inside the code. E.g {R_3_4}
pennCNV = "/home/haydee.artaza/programs/PennCNV-1.0.5"
R_4_1 = "/home/haydee.artaza/programs/R_4_1"
### prefix ########################################
### module 1,2 and 3
signal_prefix = "split"
calling_prefix = "sampleall"

### Workflow parameters ##################################
### File extensions
PLINK_EXT =['.bed','.bim','.fam']
TPLINK_EXT =['.tped','.tfam']
### PennCNV
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
$ conda activate snakemake
$ snakemake -s qc-pipeline/snakefiles/qc.snake --core 1
```

3. Rare CNVs analysis execution:
```
$ cd association-cnv
```
Modify the config.json and variables.json files in association-pipeline/snakefiles, and then excute
```
$ snakemake -s association-pipeline/snakefiles/association.snake --core 1
```
![Output directroies](manual/images/pipeline_output_dirs.png)

Details about config, input/output files and a module/rule description see [user guide manual](manual/Rare_CNVs_pipeline_guide.pdf)

Pipeline Structure
-----------------------------
The pipeline consists of two major tasks: (1) quality control analysis, which uses the SNP-array genotyping data (green box) as an input to obtain good-quality samples and high-quality calls. (2) rare CNVs analysis, which takes samples and calls from the QC pipeline output, and after the data format conversion, performs the burden, rare CNVs and enrichment analysis. Black dotted lines split each analysis in their corresponding modules, purple boxes represent a specific task in each module, yellow boxes show representative outputs (files and/or plots), and the blue box represents external functions used by some modules. Dotted purple boxes are optional tasks which could be easily removed or changed to adapt the pipeline with the study requirements.

![Pipeline workflow](manual/images/Rare_CNV_pipeline.png)
