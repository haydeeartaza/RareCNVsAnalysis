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

