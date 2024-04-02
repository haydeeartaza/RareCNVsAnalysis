Rare CNVs Analysis Pipeline
======

Test using Docker
-----------------------------

1. Download the source code:

    ```bash
    git clone  https://github.com/haydeeartaza/RareCNVsAnalysis.git
    ```

2. Create the test directory structure as below:

    ```bash
    RareCNVsAnalysis
    ├── test
        ├── data
    ├── output_qc
    └── output_association
    ```

- **RareCNVsAnalysis**: Pipeline project repository.
- **test/data**: Directory with SNP-array genotyping data.
- **output_qc**: QC pipeline ouput directory created automaticaly during QC pipeline execution.
- **output_association**: Rare CNV pipeline ouput directory created automaticaly during the pipeline execution.

3. Download the final report and the SNPs file from [test input data](https://drive.google.com/uc?export=download&id=1EbEWtprUBIz_PKB5C8709JhL2fQBDpSE). Originally downloaded from [Illumina GenomeStudio project](https://emea.support.illumina.com/content/dam/illumina-support/documents/downloads/productfiles/global-screening-array-24/v3-0/infinium-global-screening-array-24-v3-0-a1-demo-data-12.zip).

4. Build the Docker image:

    ```bash
    docker build -t rarecnvs_image:latest .
    ```


5. Configuration of the  **qc-pipeline**: [config.json](../qc-cnv/qc-pipeline/snakefiles/config.json) and [variables.py](../qc-cnv/qc-pipeline/snakefiles/variables.py) are already set for this dataset.
6. Configuration of the **association-pipeline**: [config.json](../association_cnv/association-pipeline/snakefiles/config.json) and [variables.py](../association_cnv/association-pipeline/snakefiles/variables.py)  are already set for this dataset.
7. Run the test:

    ```bash
    docker run --rm -it  -v ${PWD}:/app/pipeline rarecnvs_image:latest snakemake -s qc-cnv/qc-pipeline/snakefiles/qc.snake --core 1
    docker run --rm -it  -v ${PWD}:/app/pipeline rarecnvs_image:latest snakemake -s association-cnv/association-pipeline/snakefiles/association.snake --core 1
    ```
## Notes
- This test only shows the pipeline execution. As the input sample size is small  (12 samples) pipeline can not obtain meaninful results.
- If any part of the code is changed the pipeline should be run again and it is also recomendable to remove the output directories for generate results from scrath.
- Frequency (high_freq) and controls reference (random_controls) values should be modified according the study requeriments and the number of reference controls as well. See [Rare copy number variation in autoimmune Addison's disease (doi:10.3389/fimmu.2024.1374499)](https://www.frontiersin.org/journals/immunology/articles/10.3389/fimmu.2024.1374499/abstract)
