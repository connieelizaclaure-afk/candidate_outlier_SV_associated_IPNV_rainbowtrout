# Integrate SV Jasmine

This directory contains the workflow for merging Structural Variant (SV) calls from multiple detection tools (Manta, Lumpy, GATK, and Delly) using Jasmine. The goal is to create a unified, non-redundant consensus VCF for 28 samples of *Oncorhynchus mykiss*.

## 1. Installation of Jasmine

Jasmine was installed via the Bioconda channel.

```bash
cd /mnt/disco2/pcaceres/eliza_trout/softwares

conda config --add channels bioconda
conda config --add channels conda-forge
conda install jasminesv

mkdir jasmine_28_5M
```

## 2. Preparation of Input Files

The filtered VCF files from each detection tool were decompressed while preserving the original compressed versions.

```bash
# Manta
gunzip -k diploid_merged_28samples_PASS_precise_NC_SIZE_BI.vcf.gz
# Lumpy
gunzip -k 28_lumpy_SV_merged_SVTYPE_PRECISE_NC_SIZE_BI.vcf.gz 
# GATK
gunzip -k 28_gatk_raw_filter_INDEL_PASS_SVTYPE_NC_SIZE_BI.vcf.gz 
# Delly
gunzip -k 28_delly_SV_merged_PASS_precise_NC_SIZE_BI.vcf.gz
```

## 3. Creating the Input List

Jasmine requires a text file listing the paths to all VCF files that need to be merged.

```bash
nano 28_SV_manta_lumpy_gatk_delly.txt
```

## 4. Execution of Jasmine

The merging process was executed with specific parameters to normalize variant types and handle genotypes across the cohort.

```bash
jasmine \
--file_list=28_SV_manta_lumpy_gatk_delly.txt \
out_file=28_manta_lumpy_gatk_delly.vcf \
--ignore_strand \
--normalize_type \
--output_genotypes \
--default_zero_genotype \
--max_dist_linear=0.5 \
--min_dist=50 \
--max_dist=5000 \
2> jasminef_28.err > jasminef_28.log
```

### Configuration Parameters:
*   **`--ignore_strand`**: Allows merging of variants even if they are on different strands.
*   **`--normalize_type`**: Standardizes variant types (INS/DEL/DUP/INV/TRA).
*   **`--output_genotypes`**: Reports genotypes for the consensus variants across all source samples.
*   **`--default_zero_genotype`**: Assigns `0|0` instead of `./.` for samples without a merged variant.
*   **`--max_dist_linear=0.5`**: Sets the distance threshold as a proportion (50%) of the variant length.
*   **`--min_dist=50`**: The minimum distance threshold (bp) applied when using linear distance.
*   **`--max_dist=5000`**: The maximum allowable distance (bp) between variants for merging.

## 5. Header Addition and Cleanup

A specific script was used to clean the VCF and add necessary headers.

```bash
chmod +x filter_jasmine.sh
./filter_jasmine.sh
```

## 6. Compression and Indexing

The final VCF was sorted, compressed, and indexed for downstream analysis.

```bash
bcftools sort 28_manta_lumpy_gatk_delly_noGenotypes_clean.vcf -o 28_manta_lumpy_gatk_delly_noGenotypes_clean_sorted.vcf
bgzip 28_manta_lumpy_gatk_delly_noGenotypes_clean_sorted.vcf
bcftools index 28_manta_lumpy_gatk_delly_noGenotypes_clean_sorted.vcf.gz
```

## 7. Data Extraction

Relevant information was extracted from the final VCF into a TSV format.

```bash
chmod +x extract_vcf.sh
./extract_vcf.sh 28_manta_lumpy_gatk_delly_noGenotypes_clean_sorted.vcf.gz resultados_jasmine.tsv
```

**Final Output File:** `28_manta_lumpy_gatk_delly_noGenotypes_clean_sorted.vcf.gz`
