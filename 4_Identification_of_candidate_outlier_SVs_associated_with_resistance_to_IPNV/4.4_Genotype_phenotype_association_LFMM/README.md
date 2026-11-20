# Genotype-Phenotype/Environment Association: LFMM

This directory contains the scripts required to perform association analysis using Latent Factor Mixed Models (LFMM). 

## 1. Format Conversion (VCF to LFMM)

The input VCF file must be converted into `.geno` and subsequently `.lfmm` formats to be processed by the LFMM algorithms.

*   **Convert VCF to GENO:**

```bash
chmod +x vcf2geno.sh
./vcf2geno.sh 28_manta_lumpy_gatk_delly_clean_genotype80_maf01.vcf 28_manta_lumpy_gatk_delly_clean_genotype80_maf01.geno
```

*   **Convert GENO to LFMM:**

```bash
chmod +x geno2lfmm.sh
./geno2lfmm.sh 28_manta_lumpy_gatk_delly_clean_genotype80_maf01.geno 28_manta_lumpy_gatk_delly_clean_genotype80_maf01.lfmm
```

## 2. Latent Factor Mixed Model Analysis

The association analysis is performed in R using the `LEA` or `lfmm` package to estimate latent factors and identify significant associations.

*   **Execute the R script:**

```bash
Rscript LFMM.R
```
