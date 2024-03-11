Rare CNVs Analysis Pipeline
======

Test
-----------------------------
1. Create the test directory structure
```
.
├── RareCNVsAnalysis
├── data
├── QCResults
└── RareCNVsResults
```
- **RareCNVsAnalysis**: Pipeline project download from:
```
$ git clone  https://github.com/haydeeartaza/RareCNVsAnalysis.git
```
- **data**: Directory with SNP-array genotyping data. Download [input data](https://drive.google.com/uc?export=download&id=1EbEWtprUBIz_PKB5C8709JhL2fQBDpSE)
- **QCResults**: QC pipeline ouput directory created automaticaly during QC pipeline execution.
- **RareCNVsResults**: Rare CNV pipeline ouput directory created automaticaly during the pipeline execution.

2. Replace config.js and variables.py in **qc-pipeline**:
- **config.js**. Replace `**.**` with your mounting point, e.g. `/home/userme`
```json
{
    "final_report_file": "./data/GSA-24-v3-0-a1-demo-data-12_FinalReport.txt",
    "signal_intensity_file": "./data/SNPs_Table.txt",
    
    "gc_content_file": "./RareCNVsAnalysis/qc-cnv/resources/gc5Base.sorted.txt",
    "hmm_file": "./RareCNVsAnalysis/qc-cnv/resources/hhall.hmm",
    "immunoglobulin_region_file": "./RareCNVsAnalysis/qc-cnv/resources/immunoglobulin_penncnv.txt",
    "centromere_telomere_region_file": "./RareCNVsAnalysis/qc-cnv/resources/centromere_telomere_penncnv.txt",

    "list_signal_files_file": "./QCResults/data_conversion/list.txt",
    "map_file": "./QCResults/data_conversion/sample_map.txt",   
    "snp_file": "./QCResults/data_conversion/SNPfile.txt",
    "pfb_file": "./QCResults/data_conversion/model.pfb",
    "gcmodel_file": "./QCResults/data_conversion/hg19.gcmodel",
    "sample_pass_list_file": "./QCResults/data_clean/samples_qcpass.list",
    "sample_pass_file": "./QCResults/data_clean/samples_qcpass.rawcn",
    "sample_summary_file": "./QCResults/data_clean/samples_qcsum.list",
    "sample_clean_file": "./QCResults/data_clean/samples_qcpass.clean.rawcn",
    "sample_merged_file": "./QCResults/data_clean/samples_qcpass.clean.merged.rawcn",
   
    "data_conversion_path": "./QCResults/data_conversion",
    "data_intensity_path" :  "./QCResults/data_conversion/data_intensity",
    "data_calling_path": "./QCResults/data_calling",
    "data_clean_path": "./QCResults/data_clean",
    "graphic_path": "./QCResults/graphics",
    "graphic_qc_path": "./QCResults/graphics/qc",
    "log_path": "./QCResults/logs"
}
```
- **variables.py** Replace `**path**` with your programs path, e.g. `/home/userme/software`
```python
### snakemake_workflows initialization ########################################
libdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../lib'))
resourcesdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../resources'))

### programs ########################################
#Include here all programs and versions.You can run the specific program/version
#calling it as {program_version} inside the code. E.g {R_3_4}
pennCNV = "/path/programs/PennCNV-1.0.5"

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
3. Replace config.js and variables.py in ***association-pipeline**:
- **config.js**. Replace `**.**` with your mounting point, e.g. `/home/userme`
```
{
    "map_file": "./QCResults/data_conversion/sample_map.txt",
    "sample_all_file": "./QCResults/data_calling/sampleall.rawcn",
    "sample_merged_file": "./QCResults/data_clean/samples_qcpass.clean.merged.rawcn",

    "controls_random_file": "./Resources/controls_random_sampling.txt",
    "genes_ref_file": "./Resources/enrichment/glist-hg19.dat",
    "core_file": "./Resources/21h_positive_core.txt",
    "pathway_file": "./Resources/enrichment/PanelApp/panelApp_AI_genes.dat",
    "allpheno_file": "./Resources/ALL_phenotypes_09052019.tsv",

    "data_conversion_path": "./RareCNVsResults/data_conversion",
    "burden_analysis_path": "./RareCNVsResults/burden_analysis",
    "burden_temp_path": "./RareCNVsResults/burden_analysis/temp",
    "burden_graph_path": "./RareCNVsResults/graphics/burden_analysis",
    "rare_cnvs_path": "./RareCNVsResults/rare_cnvs",
    "rare_cnvs_summary_path": "./RareCNVsResults/rare_cnvs/summary",
    "rare_cnvs_reference_path": "./RareCNVsResults/rare_cnvs/Reference",
    "rare_cnvs_reference_summary_path": "./RareCNVsResults/rare_cnvs/Reference/summary",
    "rare_cnvs_forplots_path": "./RareCNVsResults/rare_cnvs/forplots",
    "rare_cnvs_graph_path": "./RareCNVsResults/graphics/rare_cnvs",
    "enrichment_rare_cnvs_path": "./RareCNVsResults/enrichment_rare_cnvs",
    "enrichment_rare_cnvs_genic_path": "./RareCNVsResults/enrichment_rare_cnvs/genic_CNVs",
    "enrichment_rare_cnvs_pathway_path": "./RareCNVsResults/enrichment_rare_cnvs/pathway_CNVs",
    "log_path": "./RareCNVsResults/logs"
 
} 
```
- **variables.py** Replace `**path**` with your programs path, e.g. `/home/userme/software`
```
### Snakemake_workflows initialization #######################################
libdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../lib'))
resourcesdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../resources'))

### Programs #######################################
#Include here all programs and versions.You can run the specific program/version
#calling it as {program_version} inside the code. E.g {plink17}
plink = "plink"
plink17 = "/path/programs/plink-1.07-x86_64/plink"
bedtools = "/path/programs/bedtools-2-31-1/bin/bedtools"

### Prefix file names #######################################
### module 1,2 and 3
cnv_all_prefix = 'study_all_cnvs'
cnv_prefix = 'study_core_cnvs'

### Workflow parameters ##################################
cnv_type = ['del', 'dup']
cnv_lengths = ['50', '100', '200', '500', '1000'] #length in KB. In this case the last inteval is a big number to represent cnvs >=1000
CNV_PLINK_EXT =['.cnv','.fam','.cnv.map']
CNV_EXT=['.cnv.indiv','.cnv.summary']
# CNVs length and SNPs number for filtering rule 
cnvKB = "50" # bigger than 50 kb
cnvSNPs = "5" # bigger than 5 snps
# Common CNV frequency: frequencies greater than or equal to (high_freq) from a subset of healthy control individuals (random_controls)
high_freq = "1" # value just for test
random_controls = "2" # value just for test

### Create paths if don't exist ###################################
if not os.path.exists(config['log_path']):
    os.makedirs(config['log_path'])
if not os.path.exists(config['data_conversion_path']):
    os.makedirs(config['data_conversion_path'])
if not os.path.exists(config['burden_analysis_path']):
    os.makedirs(config['burden_analysis_path'])
if not os.path.exists(config['burden_temp_path']):
    os.makedirs(config['burden_temp_path'])
if not os.path.exists(config['burden_graph_path']):
    os.makedirs(config['burden_graph_path'])
if not os.path.exists(config['rare_cnvs_path']):
    os.makedirs(config['rare_cnvs_path'])
if not os.path.exists(config['rare_cnvs_summary_path']):
    os.makedirs(config['rare_cnvs_summary_path'])
if not os.path.exists(config['rare_cnvs_reference_path']):
    os.makedirs(config['rare_cnvs_reference_path'])
if not os.path.exists(config['rare_cnvs_forplots_path']):
    os.makedirs(config['rare_cnvs_forplots_path'])
if not os.path.exists(config['rare_cnvs_graph_path']):
    os.makedirs(config['rare_cnvs_graph_path'])
if not os.path.exists(config['enrichment_rare_cnvs_path']):
    os.makedirs(config['enrichment_rare_cnvs_path'])
if not os.path.exists(config['enrichment_rare_cnvs_genic_path']):
    os.makedirs(config['enrichment_rare_cnvs_genic_path'])
if not os.path.exists(config['enrichment_rare_cnvs_pathway_path']):
    os.makedirs(config['enrichment_rare_cnvs_pathway_path'])
```

4. Run test
```
$ conda activate snakemake
$ cd qc-cnv
$ snakemake -s qc-pipeline/snakefiles/qc.snake --core 1
$ cd association-cnv
$ snakemake -s association-pipeline/snakefiles/association.snake --core 1
```
5. Notes
- This test only shows the pipeline execution. As the input sample size is small  (12 samples) pipeline can obtain meaninful results.
- If any part of the code is changed the pipeline should be run again and it is also recomendable to remove the output directories for generate results from scrath.
- Frequency (high_freq) and controls reference (random_controls) value should be modified according the study requeriments and the number of reference controls as well. See (Rare copy number variation in autoimmune Addison’s disease) [doi:10.3389/fimmu.2024.1374499]
