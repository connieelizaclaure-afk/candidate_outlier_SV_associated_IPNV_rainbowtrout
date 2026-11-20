# Population Genomic Analysis

The primary objective of this module is to conduct Principal Component Analysis (PCA) to visualize genetic clustering and differentiate between variant types (Deletions and Insertions).

## Directory Structure

This stage is organized into the following analytical steps:

1.  **Variant Separation**: Segregation of the integrated VCF file into specific SV types (DEL and INS).
2.  **PCA Computation**: Calculation of eigenvalues and eigenvectors using `PLINK`.
3.  **Visualization**: Generation of PCA plots using R scripts for population structure assessment.

## Workflow Execution

### 1. Structural Variant Type Separation
Before performing the population analysis, the integrated dataset is split to analyze total SVs, Deletions (DEL), and Insertions (INS) independently using `bcftools`.

```bash
# Filter for Deletions
bcftools view -i 'INFO/SVTYPE="DEL"' 28_manta_lumpy_gatk_delly_clean_genotype80_maf01.vcf -o 28_manta_lumpy_gatk_delly_clean_genotype80_maf01_DEL.vcf

# Filter for Insertions
bcftools view -i 'INFO/SVTYPE="INS"' 28_manta_lumpy_gatk_delly_clean_genotype80_maf01.vcf -o 28_manta_lumpy_gatk_delly_clean_genotype80_maf01_INS.vcf

# Review generated VCFs
bcftools view 28_manta_lumpy_gatk_delly_clean_genotype80_maf01_DEL.vcf | less -S
bcftools view 28_manta_lumpy_gatk_delly_clean_genotype80_maf01_INS.vcf | less -S
```

### 2. Principal Component Analysis (PCA) with PLINK
The PCA is performed using `PLINK 1.9` to generate `.eigenval` and `.eigenvec` files. Filters for missingness (`--geno 0.2`) and minor allele frequency (`--maf 0.05`) are applied.

**2.1. Analysis for Total SVs (31,823 variants):**
```bash
plink --vcf 28_manta_lumpy_gatk_delly_clean_genotype80_maf01.vcf \
--geno 0.2 \
--maf 0.05 \
--pca 10 \
--allow-extra-chr \
--double-id \
--out pca_SV_filter
```

**2.2. Analysis for Deletions (29,179 variants):**
```bash
plink --vcf 28_manta_lumpy_gatk_delly_clean_genotype80_maf01_DEL.vcf \
--geno 0.2 \
--maf 0.05 \
--pca 10 \
--allow-extra-chr \
--double-id \
--out pca_DEP_filter
```

**2.3. Analysis for Insertions (2,644 variants):**
```bash
plink --vcf 28_manta_lumpy_gatk_delly_clean_genotype80_maf01_INS.vcf \
--geno 0.2 \
--maf 0.05 \
--pca 10 \
--allow-extra-chr \
--double-id \
--out pca_INS_filter
```

### 3. Data Visualization
The final step involves executing the R script to visualize the results:

```bash
Rscript PCA.R
```

## Technical Notes
- **Software Requirements**: `bcftools`, `PLINK 1.9`, and `R`.
- **Output**: The analysis generates eigenvectors and eigenvalues which are then plotted to assess clusters between resistant and susceptible IPNV groups.
