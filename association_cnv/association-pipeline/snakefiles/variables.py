### Snakemake_workflows initialization #######################################
libdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../lib'))
resourcesdir = os.path.abspath(os.path.join(os.path.dirname(workflow.basedir), '../resources'))

### Programs #######################################
#Include here all programs and versions.You can run the specific program/version
#calling it as {program_version} inside the code. E.g {plink17}
plink = "plink"
plink17 = "/home/haydee.artaza/programs/plink-1.07-x86_64/plink"

### Prefix file names #######################################
### module 1,2 and 3
cnv_all_prefix = 'study_all_cnvs'
cnv_prefix = 'study_core_cnvs'

### Workflow parameters ##################################
cnv_type = ['del', 'dup']
cnv_lengths = ['50', '100', '200', '500', '1000', '1000000'] #length in KB. In this case the last inteval is a big number to represent cnvs >=1000
CNV_PLINK_EXT =['.cnv','.fam','.cnv.map']
CNV_EXT=['.cnv.indiv','.cnv.summary']
# CNVs length and SNPs number for filtering rule 
cnvKB = "50" # bigger than 50 kb
cnvSNPs = "5" # bigger than 5 snps
# Common CNV frequency: frequencies greater than or equal to (high_freq) from a subset of healthy control individuals (random_controls)
high_freq = "4" # 2% of 200, change these values according your strategy
random_controls = "200"

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
