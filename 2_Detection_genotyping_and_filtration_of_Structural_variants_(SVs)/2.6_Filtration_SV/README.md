# Filtration SV

This directory contains the workflow for filtering Structural Variants (SVs) based on genotyping rate and Minor Allele Frequency (MAF). 

## 1. Quality Filtering

The filtering process is divided into two main steps: genotype rate thresholding and frequency filtering.

### 1.1 Filter by Genotype Rate (≥ 0.8)

In this step, variants that are not genotyped in at least 80% of the samples are removed. This helps eliminate variants with high levels of missing data.

```bash
# Execute the genotyping filter script
chmod +x filter_genotype.sh
./filter_genotype.sh
```
---

### 1.2 Filter by Minor Allele Frequency (MAF ≥ 0.01)

This step filters out rare variants that appear in less than 1% of the population. We first calculate the MAF using the `fill-tags` plugin and then apply the filter.

```bash
# Calculate MAF and filter for values >= 0.01 (Note: command uses 0.1 threshold as per script)
bcftools +fill-tags 28_manta_lumpy_gatk_delly_clean_genotype80.vcf -- -t MAF | \
bcftools view -i 'MAF >= 0.1' -O v -o 28_manta_lumpy_gatk_delly_clean_genotype80_maf01.vcf
```

## Summary of Results

The filtering process significantly reduced the noise in the dataset, moving from a large initial set to a refined collection of variants.

**Final Output File:** `28_manta_lumpy_gatk_delly_clean_genotype80_maf01.vcf`
