# Coverage Visualization with DeepTools

This directory contains the pipeline for converting BAM files to bedGraph and bigWig formats to visualize genome coverage. The analysis is performed on whole-genome sequencing data from rainbow trout (*Oncorhynchus mykiss*) as part of the IPNV challenge test by Effigen S.A
---

## Steps for Coverage Analysis

### 1. Installation
Install `deeptools` using the conda package manager.

```bash
conda install -c conda-forge -c bioconda deeptools
```
*For more information, visit the [DeepTools documentation](https://deeptools.readthedocs.io/en/latest/content/list_of_tools.html).*

### 2. Multi-BAM Summary Generation
Calculate read coverages across genomic regions (bins) for multiple BAM files. This generates a compressed numpy array (`.npz`) used for downstream plotting.

```bash
# Create directory for output files
mkdir deeptools

multiBamSummary bins \
--numberOfProcessors 8 \
--bamfiles ./bam/*.sorted.bam \
--minMappingQuality 30 \
--labels M0018 M0675 M0679 M0696 M0943 M0993 M1010 M1011 M1013 M1015 M1017 M1021 M1043 M1048 S0080 S0093 S0098 S0107 S0116 S0130 S0159 S0168 S0169 S0185 S0343 S0350 S0368 S0373 \
--outFileName ./deeptools/readCount_28.npz \
--verbose
```

### 3. Correlation Analysis (plotCorrelation)
Calculate the Spearman correlation between samples based on the read counts calculated in the previous step.

```bash
cd deeptools

plotCorrelation \
-in readCount_28.npz \
--corMethod spearman \
--skipZeros \
--plotTitle "Spearman Correlation of Read Counts" \
--whatToPlot heatmap \
--colorMap RdYlBu \
--plotNumbers \
-o heatmap_SpearmanCorr_readCounts_28.svg \
--outFileCorMatrix SpearmanCorr_readCounts_28.tab
```
> **Note:** The dendrogram indicates which samples have the most similar read counts.

### 4. Principal Component Analysis (plotPCA)
Perform PCA to visualize the variability and clustering of the samples.

```bash
plotPCA \
-in readCount_28.npz \
-o PCA_readCounts_28_1.svg \
-T "PCA of read counts" \
--markers o o o o o o o o o o o o o o o o o o o o o o o o o o o o \
--colors '#ff7c80ff' '#ff7c80ff' '#ff7c80ff' '#ff7c80ff' '#ff7c80ff' '#ff7c80ff' '#ff7c80ff' '#ff7c80ff' '#ff7c80ff' '#ff7c80ff' '#ff7c80ff' '#ff7c80ff' '#ff7c80ff' '#ff7c80ff' '#91f3a1ff' '#91f3a1ff' '#91f3a1ff' '#91f3a1ff' '#91f3a1ff' '#91f3a1ff' '#91f3a1ff' '#91f3a1ff' '#91f3a1ff' '#91f3a1ff' '#91f3a1ff' '#91f3a1ff' '#91f3a1ff' '#91f3a1ff'
```
> **Note:** This generates an eigenvalue plot and a scree plot showing the amount of variability explained by individual components.

### 5. Fragment Size Calculation (bamPEFragmentSize)
Estimate the fragment size of paired-end reads.

*   **Single Sample Analysis:**
    ```bash
    bamPEFragmentSize \
    -hist fragmentSize_M0018.svg \
    -T "Fragment size of rainbow trout data" \
    --maxFragmentLength 1000 \
    -b ./bam/M0018.sorted.bam \
    -samplesLabel M0018
    ```

*   **Batch Processing:**
    Execute the automated script for all samples.
    ```bash
    chmod +x bamPEFragmentSize.sh
    ./bamPEFragmentSize.sh
    ```

### 6. Coverage Distribution Plotting (plotCoverage)
Assess the sequencing depth and fraction of the genome covered.

*   **Single Sample Analysis:**
    ```bash
    plotCoverage \
    -b ./bam/M0018.sorted.bam \
    --plotFile "M0018_coverage" \
    -n 1000000 \
    --plotTitle "Coverage of rainbow trout" \
    --outRawCounts coverage_M0018.tab \
    --ignoreDuplicates \
    --minMappingQuality 10
    ```

*   **Batch Processing:**
    Execute the automated script for multiple samples.
    ```bash
    chmod +x plot_coverage.sh
    ./plot_coverage.sh
    ```

