Rare CNVs Analysis Pipeline
======

Overwiew
-----------------------------
This pipeline is a generic bioinformatic solution to identify rare CNVs in case-control based studies. Using SNPs-array genotyping data, this pipeline performs CNV detection and quality control, followed by the burden analysis, rare CNV frequency analysis and CNV enrichment analysis.

Details about config, input/output files and a module/rule description see [user guide manual](manual/Rare_CNVs_pipeline_guide.pdf).

Pipeline Structure
-----------------------------
The pipeline executes two major tasks:

1. Quality control analysis, which uses SNP-array genotyping data (green box) as an input to obtain high-quality samples and CNV calls. 
2. Rare CNV analysis, which takes samples and CNV calls from the QC pipeline output, and after the data format conversion, consists of burden, rare CNV and enrichment analysis. 

Black dotted lines split each analysis in their corresponding modules, purple boxes represent a specific task in each module, yellow boxes show representative outputs (files and/or plots), and the blue box represents external functions used by some modules. Dotted purple boxes are optional tasks which could be easily removed or changed to adapt the pipeline with the study requirements.

![Pipeline workflow](manual/images/Rare_CNV_pipeline.png)

Dependencies
-----------------------------
- Mambaforge3
- Snakemake 5.22.1
- R (>=3.6.3)
- Python (>=3.8.5)
- BedTools
- plink (1.7)
- PennCNV (1.0.5)

Installation of dependencies
-----------------------------

Dependencies available via Conda are installed by Snakemake (Integrated Package Management). Dependencies not availabe should be installed manually. See Snakemake and dependencies installation [here](manual/INSTALL.md)

SNP-array data
-----------------------------
As a default, this pipeline is set up to use **Illumina SNP-array genotyping data**. However, **Affymetrix array data** can also be used with this pipeline. The  **Input Files Specification** section of the [user guide manual](manual/Rare_CNVs_pipeline_guide.pdf) contains the guidelines to prepare the appropriate input files and modify pipeline files accordingly.

Pipeline execution
-----------------------------

**1. Create the directory structure:**
```
.
├── data
├── QCResults
└── RareCNVsResults
```

**2. In the same directory download the git project:**
```
$ git clone  https://github.com/haydeeartaza/RareCNVsAnalysis.git
```
```
.
├── RareCNVsAnalysis
├── data
├── QCResults
└── RareCNVsResults
```
- **data**: Directory containing the **test** SNP-array genotyping data. Download the final report and the SNPs file from [input data](https://drive.google.com/uc?export=download&id=1EbEWtprUBIz_PKB5C8709JhL2fQBDpSE). Originally downloaded from [Illumina GenomeStudio project](https://emea.support.illumina.com/content/dam/illumina-support/documents/downloads/productfiles/global-screening-array-24/v3-0/infinium-global-screening-array-24-v3-0-a1-demo-data-12.zip) 
- **QCResults**: QC pipeline ouput directory created automaticaly during QC pipeline execution.
- **RareCNVsResults**: Rare CNV pipeline ouput directory created automaticaly during the pipeline execution.

### Preparing the environment for calling and QC analysis

**1. Setting up the configuration files:**
```
$ cd RareCNVsResults/qc-cnv
```
Replace config.js and variables.py:
- Modify **config.json** file in **qc-pipeline/snakefiles/config.json**. Replace all instances of **path_to** according to your installation path.

  The first block refers to SNPs array report and the SNPs table files (see user guide manual, **Input Files Specification**, and Figre 5 and Figure 6 [here](https://github.com/haydeeartaza/RareCNVsAnalysis/blob/main/manual/Rare_CNVs_pipeline_guide.pdf))
  ``` json
    "final_report_file": "path_to/data/GSA-24-v3-0-a1-demo-data-12_FinalReport.txt",
    "signal_intensity_file": "path_to/data/SNPs_Table.txt",
  ```
  The second block refers to external files used for the QC execution stored  in **resources** directoy included within the pipeline:
  ``` json
    "gc_content_file": "path_to/RareCNVsAnalysis/qc-cnv/resources/gc5Base.sorted.txt",
    "hmm_file": "path_to/RareCNVsAnalysis/qc-cnv/resources/hhall.hmm",
    "immunoglobulin_region_file": "path_to/RareCNVsAnalysis/qc-cnv/resources/immunoglobulin_penncnv.txt",
    "centromere_telomere_region_file": "path_to/RareCNVsAnalysis/qc-cnv/resources/centromere_telomere_penncnv.txt",
  ```
  The third block refers to files generated in this analysis which will be used as a input in the **Rare CNVs analysis**:
  ``` json
    "list_signal_files_file": "path_to/QCResults/data_conversion/list.txt",
    "map_file": "path_to/QCResults/data_conversion/sample_map.txt",   
    "snp_file": "path_to/QCResults/data_conversion/SNPfile.txt",
    "pfb_file": "path_to/QCResults/data_conversion/model.pfb",
    "gcmodel_file": "path_to/QCResults/data_conversion/hg19.gcmodel",
    "sample_pass_list_file": "path_to/QCResults/data_clean/samples_qcpass.list",
    "sample_pass_file": "path_to/QCResults/data_clean/samples_qcpass.rawcn",
    "sample_summary_file": "path_to/QCResults/data_clean/samples_qcsum.list",
    "sample_clean_file": "path_to/QCResults/data_clean/samples_qcpass.clean.rawcn",
    "sample_merged_file": "path_to/QCResults/data_clean/samples_qcpass.clean.merged.rawcn",
  ```

  The last block indicates the output directories for each module and the Conda environment file location:
  ``` json
    "data_conversion_path": "path_to/QCResults/data_conversion",
    "data_intensity_path" :  "path_to/QCResults/data_conversion/data_intensity",
    "data_calling_path": "path_to/QCResults/data_calling",
    "data_clean_path": "path_to/QCResults/data_clean",
    "graphic_path": "path_to/QCResults/graphics",
    "graphic_qc_path": "path_to/QCResults/graphics/qc",
    "log_path": "path_to/QCResults/logs",
    
    "dependenciesenv_file": "path_to/RareCNVsAnalysis/qc-cnv/qc-pipeline/snakefiles/env/dependenciesenv.yml"
  ```
- Modify **variables.py** file in qc-pipeline/snakefiles/variables.py according to your PennCNV path, prefixes and PennCNV parameters:

    ```python
    ### snakemake_workflows initialization ########################################
    libdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../lib'))
    resourcesdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../resources'))
    
    ### programs ########################################
    #Include here all programs and versions.
    #You specify program/version by calling it as {program_version} inside the code. E.g {pennCNV}
    pennCNV = "path_to/programs/PennCNV-1.0.5"
    
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
**2. Running the calling and  QC pipeline**

- Excute the pipeline with the comman line:
    ```
    $ conda activate snakemake
    $ snakemake --sdm conda --conda-create-envs-only -s qc-pipeline/snakefiles/qc.snake 
    $ snakemake --sdm conda --core 1 -s qc-pipeline/snakefiles/qc.snakesnakemake 
    ```
   - --sdm conda: use Conda integration in Snakemake
   - --conda-create-envs-only:  will only install the required Conda environments without running the full workflow

### Preparing the environment for Rare CNVs analysis

**1. Setting up the configuration files:**
```
$ cd association-cnv
```
Replace config.js and variables.py:
- Modify the config.json file in association-pipeline/snakefiles. Replace all instances of **path_to** according to your installation path.

    First block referst to the files generated in the previous detections and QC analysis stored at `QCResults`, which will be the input files for this pipeline.
    ``` json
        "map_file": "path_to/QCResults/data_conversion/sample_map.txt",
        "sample_all_file": "path_to/QCResults/data_calling/sampleall.rawcn",
        "sample_merged_file": "path_to/QCResults/data_clean/samples_qcpass.clean.merged.rawcn",
    ```
    Second block refers to the external files used as imput in the different modules. These files should be provided by the users according the study requeriments.
    ``` json
        "controls_random_file": "path_to/RareCNVsAnalysis/Resources/controls_random_sampling.txt",
        "genes_ref_file": "path_to/RareCNVsAnalysis/Resources/glist-hg19.dat",
        "core_file": "path_to/RareCNVsAnalysis/Resources/core.txt",
        "pathway_file": "path_to/RareCNVsAnalysis/Resources/panelApp_AI_genes.dat",
        "allpheno_file": "path_to/RareCNVsAnalysis/Resources/pheno.tsv",
    ```
    - `glist-hg19.dat`: Genome reference file (chr-bp1-bp2-geneid) for the geneset-enrichment test, download from [Plink resources web page](https://www.cog-genomics.org/plink/1.9/resources). Available, hg18, hg19 and hg38 versions.
    - `panelApp_AI_genes.dat`: geneset list (chr-bp1-bp2-geneid)(e.g autoimmune related genes from PanelApp).
    - `pheno.tsv`: phenotype file (see NOTE below regarding format specification).

    Last block indicates the output directories for each module and the Conda environment file location:
    ``` json
        "data_conversion_path": "path_to/RareCNVsResults/data_conversion",
        "burden_analysis_path": "path_to/RareCNVsResults/burden_analysis",
        "burden_temp_path": "path_to/RareCNVsResults/burden_analysis/temp",
        "burden_graph_path": "path_to/RareCNVsResults/graphics/burden_analysis",
        "rare_cnvs_path": "path_to/RareCNVsResults/rare_cnvs",
        "rare_cnvs_summary_path": "path_to/RareCNVsResults/rare_cnvs/summary",
        "rare_cnvs_reference_path": "path_to/RareCNVsResults/rare_cnvs/Reference",
        "rare_cnvs_reference_summary_path": "path_to/RareCNVsResults/rare_cnvs/Reference/summary",
        "rare_cnvs_forplots_path": "path_to/RareCNVsResults/rare_cnvs/forplots",
        "rare_cnvs_graph_path": "path_to/RareCNVsResults/graphics/rare_cnvs",
        "enrichment_rare_cnvs_path": "path_to/RareCNVsResults/enrichment_rare_cnvs",
        "enrichment_rare_cnvs_genic_path": "path_to/RareCNVsResults/enrichment_rare_cnvs/genic_CNVs",
        "enrichment_rare_cnvs_pathway_path": "path_to/RareCNVsResults/enrichment_rare_cnvs/pathway_CNVs",
        "log_path": "path_to/RareCNVsResults/logs",
        
        "dependenciesenv_file": "path_to/RareCNVsAnalysis/association-cnv/association-pipeline/snakefiles/env/dependenciesenv.yml"
    ```
> [!NOTE]
> **Phenotype** file should containt the the case/control and gender information in columns 3 and 7 respectivelly, as is shown in the example below. Function `create_fam_file` in [functions.sh](association_cnv/lib/functions.sh) can be modified to adjust these positions.
    
    ```
    NAT REG	CAT PID     FID AGE SEX
    A   1   1   NA06985 0   10  1
    B   2   2   NA12717 0   25  2
    C   3   1   NA12873 0   45  1
    D   4   2   NA12891 0   15  2
    ```
**2. Running the RareCNVs pipeline**

- Excute the pipeline with the comman line:
    ```
    $ conda activate snakemake
    $ snakemake --sdm conda --conda-create-envs-only -s association-pipeline/snakefiles/association.snake 
    $ snakemake --sdm conda --core 1 -s association-pipeline/snakefiles/association.snake ```  
> [!NOTE]
> - Illumina data test consiste of 12 samples, using this data for test both pipelines will generate not meaninful results.
>
> - If any part of the code is changed the pipeline should be run again and it is also recomendable to remove the output directories for generate results from scrath.
> 

![Output directroies](manual/images/pipeline_output_dirs.png)


Publication and Citation
-----------------------------
This project is provisionally described in [Artaza H. *et al.*, doi:10.1101/2024.03.13.584428](https://doi.org/10.1101/2024.03.13.584428)
