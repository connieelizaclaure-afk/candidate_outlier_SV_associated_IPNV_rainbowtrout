# Population Genetic Differentiation: fsthet

This directory contains the scripts and procedures for analyzing population genetic differentiation using `fsthet` (Fst-Heterozygosity Smoothed Quantiles). This program is designed to generate smoothed quantiles for the Fst-heterozygosity distribution, particularly suited for genome-wide structural variants (SVs) in *Oncorhynchus mykiss*.

## 1. Convert VCF to Genepop Format

The input VCF file must be converted into Genepop format to be compatible with the `fsthet` R package. This is achieved using the `genepop.sh` script.

```bash
# Grant execution permissions
chmod +x genepop.sh

# Run the conversion
./genepop.sh 28_manta_lumpy_gatk_delly_clean_genotype80_maf01.vcf 28_manta_lumpy_gatk_delly_clean_genotype80_maf01.txt
```

## 2. Population Differentiation Analysis in R

Once the data is in the correct format, the `fsthet` analysis is performed within R to analyze the Fst-heterozygosity distribution and identify potential outliers.

*   **Execute the R script:**

```bash
Rscript fsthet.R
```

**Note:** The `fsthet.R` script utilizes the generated `.txt` Genepop file to calculate smoothed quantiles and evaluate loci that deviate from the expected distribution, indicating potential selection or significant differentiation between groups.
