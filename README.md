Rare CNVs Analysis Pipeline
======

Overview
-----------------------------
This pipeline is a generic bioinformatic solution to identify rare CNVs in case-control based studies. Using SNPs-array genotyping data, this pipeline performs CNV detection and quality control, followed by the burden analysis, rare CNV frequency analysis and CNV enrichment analysis [see pipeline workflow](manual/images/Rare_CNV_pipeline-drawio.png).

Dependencies
-----------------------------
- Python (>=3.8.5)
- Snakemake (5.22.1)
- bcftools
- vcftools
- plink (1.7)
- PennCNV (1.0.5)
- R (3.6.3, see requirements.txt and Dockerfile for the list of packages) 

Installation
-----------------------------
Download the git project:

```bash
git clone  https://github.com/haydeeartaza/RareCNVsAnalysis.git
```

For direct installation on the system see instructions for Snakemake and dependencies [here](manual/INSTALL.md).

If you are going to use Docker, you simply need to build the image (it will take a moment first time):

```bash
docker build -t rarecnvs_image:latest .
```

Step 1: CNV detection and QC
-----------------------------


To run the pipeline on the supplied test data on the native system:

```bash
conda activate snakemake
snakemake -s qc-cnv/qc-pipeline/snakefiles/qc.snake --core 1
```

To run the pipeline on the supplied test data using Docker (after you have built the image):

```bash
docker run --rm -it  -v ${PWD}:/app/pipeline rarecnvs_image:latest snakemake -s qc-cnv/qc-pipeline/snakefiles/qc.snake --core 1
```

### Pipeline configuration

To configure the pipeline for your own dataset you need to adjust two files: 

- [qc-cnv/qc-pipeline/snakefiles/config.json](qc-cnv/qc-pipeline/snakefiles/config.json)
- [qc-cnv/qc-pipeline/snakefiles/variables.py](qc-cnv/qc-pipeline/snakefiles/variables.py)

Note that for docker-based run you can just replace the input data filenames.

Modify [`config.json`](qc-cnv/qc-pipeline/snakefiles/config.json)  including the genotyping files path (`final_report_file` and `signal_intensity_file` respectively) and specifying the ouput directory. In this example directory `test/data` at the root of the repository should contain the SNP-array files, directory `output_qc` will contain all files generted in this pipeline.

Note that the `config.json` in this example is adapted for running with Docker, if you run it on the native system, you need to replace `/app/pipeline/` with the full path to where you want to write your output.
  
``` json
{
    "final_report_file": "test/data/GSA-24-v3-0-a1-demo-data-12_FinalReport.txt",
    "signal_intensity_file": "test/data/SNPs_Table.txt",
    
    "gc_content_file": "qc-cnv/resources/gc5Base.sorted.txt",
    "hmm_file": "qc-cnv/resources/hhall.hmm",
    "immunoglobulin_region_file": "qc-cnv/resources/immunoglobulin_penncnv.txt",
    "centromere_telomere_region_file": "qc-cnv/resources/centromere_telomere_penncnv.txt",

    "list_signal_files_file": "/app/pipeline/output_qc/data_conversion/list.txt",
    "map_file": "/app/pipeline/output_qc/data_conversion/sample_map.txt",   
    "snp_file": "/app/pipeline/output_qc/data_conversion/SNPfile.txt",
    "pfb_file": "/app/pipeline/output_qc/data_conversion/model.pfb",
    "gcmodel_file": "/app/pipeline/output_qc/data_conversion/hg19.gcmodel",
    "sample_pass_list_file": "/app/pipeline/output_qc/data_clean/samples_qcpass.list",
    "sample_pass_file": "/app/pipeline/output_qc/data_clean/samples_qcpass.rawcn",
    "sample_summary_file": "/app/pipeline/output_qc/data_clean/samples_qcsum.list",
    "sample_clean_file": "/app/pipeline/output_qc/data_clean/samples_qcpass.clean.rawcn",
    "sample_merged_file": "/app/pipeline/output_qc/data_clean/samples_qcpass.clean.merged.rawcn",
    "data_conversion_path": "/app/pipeline/output_qc/data_conversion",
    "data_intensity_path" :  "/app/pipeline/output_qc/data_conversion/data_intensity",
    "data_calling_path": "/app/pipeline/output_qc/data_calling",
    "data_clean_path": "/app/pipeline/output_qc/data_clean",
    "graphic_path": "/app/pipeline/output_qc/graphic",
    "graphic_qc_path": "/app/pipeline/output_qc/graphic/qc",
    "log_path": "/app/pipeline/output_qc/logs"
}
```

Modify [`variables.py`](qc-cnv/qc-pipeline/snakefiles/variables.py) including programs location, setting files prefixes and PennCNV parameters. This script will also create the output directories that were previously set in `config.json` file.

```python
  ### snakemake_workflows initialization ########################################
libdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../lib'))
resourcesdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../resources'))

### programs ########################################
#Include here all programs and versions.You can run the specific program/version
#calling it as {program_version} inside the code. E.g {R_3_4}
pennCNV = "/PennCNV-1.0.5"
# this is needed for using X11 graphic device for plotting in docker
# if running on the native system just set it to "Rscript"
Rscript = "xvfb-run Rscript"
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

### Create paths if they don't exist ###################################

paths = [
    config['data_conversion_path'],
    config['data_intensity_path'],
    config['data_calling_path'],
    config['data_clean_path'],
    config['graphic_path'],
    config['log_path'],
]

for path in paths:
    if not os.path.exists(path):
        os.makedirs(path)
```

Execute the pipeline as shown above either on the native system, or using Docker.

Step 2: Rare CNVs analysis
-----------------------------

To run the pipeline on the supplied test data on the native system:

```bash
snakemake -s association-cnv/association-pipeline/snakefiles/association.snake --core 1
```

To run the pipeline on the supplied test data via Docker:

```bash
docker run --rm -it  -v ${PWD}:/app/pipeline rarecnvs_image:latest snakemake -s association-cnv/association-pipeline/snakefiles/association.snake --core 1
```

### Pipeline configuration

To configure the pipeline for your own dataset you need to adjust two files: 

- [association-cnv/association-pipeline/snakefiles/config.json](association_cnv/association-pipeline/snakefiles/config.json)
- [association-cnv/association-pipeline/snakefiles/variables.py](association_cnv/association-pipeline/snakefiles/variables.py)

Modify the [`config.json`](association_cnv/association-pipeline/snakefiles/config.json) file. In this example directory `output_qc` refers the directory with the quality controlled CNV calls from the previous step, directory `output_association` will contain all files generted in this pipeline and `test/resources` refers to the directory containing the input files for this step of the pipeline.

``` json
{
    "map_file": "/app/pipeline/output_qc/data_conversion/sample_map.txt",
    "sample_all_file": "/app/pipeline/output_qc/data_calling/sampleall.rawcn",
    "sample_merged_file": "/app/pipeline/output_qc/data_clean/samples_qcpass.clean.merged.rawcn",
    
    "controls_random_file": "test/resources/controls_random_sampling.txt",
    "genes_ref_file": "test/resources/glist-hg19.dat",
    "core_file": "test/resources/core.txt",
    "pathway_file": "test/resources/panelApp_AI_genes.dat",
    "allpheno_file": "test/resources/pheno.tsv",

    "data_conversion_path": "/app/pipeline/output_association/data_conversion",
    "burden_analysis_path": "/app/pipeline/output_association/burden_analysis",
    "burden_temp_path": "/app/pipeline/output_association/burden_analysis/temp",
    "burden_graph_path": "/app/pipeline/output_association/graphics/burden_analysis",
    "rare_cnvs_path": "/app/pipeline/output_association/rare_cnvs",
    "rare_cnvs_summary_path": "/app/pipeline/output_association/rare_cnvs/summary",
    "rare_cnvs_reference_path": "/app/pipeline/output_association/rare_cnvs/Reference",
    "rare_cnvs_reference_summary_path": "/app/pipeline/output_association/rare_cnvs/Reference/summary",
    "rare_cnvs_forplots_path": "/app/pipeline/output_association/rare_cnvs/forplots",
    "rare_cnvs_graph_path": "/app/pipeline/output_association/graphics/rare_cnvs",
    "enrichment_rare_cnvs_path": "/app/pipeline/output_association/enrichment_rare_cnvs",
    "enrichment_rare_cnvs_genic_path": "/app/pipeline/output_association/enrichment_rare_cnvs/genic_CNVs",
    "enrichment_rare_cnvs_pathway_path": "/app/pipeline/output_association/enrichment_rare_cnvs/pathway_CNVs",
    "log_path": "/app/pipeline/output_association/logs"
 
}
```

**NOTE:**
> **Phenotype** file should containt the the case/control and gender information in columns 3 and 7 respectivelly, as is shown in the example below. Function `create_fam_file` in [functions.sh](association_cnv/lib/functions.sh) can be modified to adjust these positions.

```R
NAT REG	CAT PID     FID AGE SEX
A   1   1   NA06985 0   10  1
B   2   2   NA12717 0   25  2
C   3   1   NA12873 0   45  1
D   4   2   NA12891 0   15  2
```

User guide
-----------------------------

For details about config, input/output files (see example image below) and modules/rules description see [the user guide manual](manual/Rare_CNVs_pipeline_guide.pdf).

![Output directroies](manual/images/pipeline_output_dirs.png)

Test
-----------------------------
See test instructions for run [on the native system](test/Test-native-system.md) and [via Docker](test/Test-docker.md).

Publication and Citation
-----------------------------
This project is provisionally described in [Artaza H. *et al.*, doi:10.1101/2024.03.13.584428](https://doi.org/10.1101/2024.03.13.584428).

Publication and Citation
-----------------------------
This project is provisionally described in [Artaza H. *et al.*, doi:10.1101/2024.03.13.584428](https://doi.org/10.1101/2024.03.13.584428)

Pipeline Structure
-----------------------------
The pipeline executes two major tasks:

- 1. Quality control analysis, which uses SNP-array genotyping data (green box) as an input to obtain high-quality samples and CNV calls. 
- 2. Rare CNV analysis, which takes samples and CNV calls from the QC pipeline output, and after the data format conversion, consists of burden, rare CNV and enrichment analysis. 

Black dotted lines split each analysis in their corresponding modules, purple boxes represent a specific task in each module, yellow boxes show representative outputs (files and/or plots), and the blue box represents external functions used by some modules. Dotted purple boxes are optional tasks which could be easily removed or changed to adapt the pipeline with the study requirements.

![Pipeline workflow](manual/images/Rare_CNV_pipeline.png)
