# Population Genetic Differentiation: PCAdapt

This directory contains the necessary scripts for identifying candidate adaptive structural variants using `PCAdapt`. 

## 1. Population Differentiation Analysis in R

The analysis is conducted using the `PCAdapt` package within the R environment. This tool performs a Principal Component Analysis (PCA) and determines outliers based on the Mahalanobis distance, identifying variants that contribute significantly to population differentiation.

*   **Execute the R script:**

```bash
Rscript PCADAPT.R
```

**Note:** The script processes the filtered structural variant dataset to produce statistical outputs and visualizations that highlight candidate loci potentially associated with the phenotypic challenge responses observed in the IPNV challenge test.
