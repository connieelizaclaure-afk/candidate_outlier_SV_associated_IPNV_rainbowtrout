# SV Identification Using Delly

This directory contains the pipeline for identifying structural variants (SVs) in *Oncorhynchus mykiss* using Delly. The workflow covers installation, variant calling, file conversion, and a rigorous multi-step filtration process to ensure high-quality SV calls.

## 1. Installation

Delly is installed via Conda using the Bioconda channel.

```bash
cd /mnt/disco2/pcaceres/eliza_trout/softwares

conda install bioconda::delly
conda install bioconda/label/cf201901::delly
```

## 2. Variant Calling with Delly

Delly discovers structural variants through genomic alignment, producing results in BCF (Binary VCF) format.

```bash
# Example for a single sample
delly call -g ./reference/OmykA_1.1_manta.fna.gz -o ./delly/M0018_delly.bcf ./bam/M0018.sorted.bam

# Multiple sample calling via script
chmod +x delly_call.sh
./delly_call.sh
```

## 3. Merge SV Sites

Merge individual BCF files into a unified list of structural variant sites. Note that the resulting merged file does not contain sample names.

```bash
delly merge -o 28_delly_SV_merged.bcf ./delly/*_delly.bcf
```

## 4. Format Conversion

Convert the binary BCF file to a standard VCF format.

```bash
bcftools view 28_delly_SV_merged.bcf > 28_delly_SV_merged.vcf
```

## 5. Compression

Compress the VCF file using `bgzip`.

```bash
bgzip -c 28_delly_SV_merged.vcf > 28_delly_SV_merged.vcf.gz
```

## 6. Indexing and Verification

Index the compressed file with `tabix` and verify the initial SV counts.

```bash
tabix -p vcf 28_delly_SV_merged.vcf.gz

# Verify the number of SVs
bcftools query -f '%SVTYPE\n' 28_delly_SV_merged.vcf.gz | sort | uniq -c
```

## 7. Filtration Pipeline

The SVs are filtered through five distinct stages to extract high-confidence variants.

### 7.1. PASS Filter
Filter variants based on the quality filter "PASS".
```bash
chmod +x filter_PASS.sh
./filter_PASS.sh
```

### 7.2. Precision Filter
Retain only precise variants, excluding those marked as IMPRECISE.
```bash
chmod +x filter_imprecise.sh
./filter_imprecise.sh
```

### 7.3. Chromosome (NC) Filter
Retain chromosome-level contigs (names starting with "NC_") and automatically exclude scaffolds (NW).
```bash
chmod +x filter_NC.sh
./filter_NC.sh 28_delly_SV_merged_PASS_precise.vcf.gz 
```

### 7.4. Size (SVLEN) Filter
Filter SVs based on their length.
```bash
chmod +x filter_size_delly.sh
./filter_size_delly.sh 28_delly_SV_merged_PASS_precise_NC.vcf.gz
```

### 7.5. Biallelic Filter
Retain only biallelic data for downstream analysis.
```bash
bcftools view -m2 -M2 28_delly_SV_merged_PASS_precise_NC_SIZE.vcf.gz -O z -o 28_delly_SV_merged_PASS_precise_NC_SIZE_BI.vcf.gz  
bcftools index 28_delly_SV_merged_PASS_precise_NC_SIZE_BI.vcf.gz  
```

## 8. Exploratory Data Analysis

Final counts are generated to summarize the SV distribution across the cohort.

```bash
# Count SVs per sample
chmod +x count_sv_detail.sh
./count_sv_detail.sh 28_delly_SV_merged_PASS_precise_NC_SIZE_BI.vcf.gz   
```

**Final Output:** `28_delly_SV_merged_PASS_precise_NC_SIZE_BI.vcf.gz`





























































