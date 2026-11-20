# Functional Annotation of SVs using snpEff

This directory contains the workflow for annotating the functional effects of identified structural variants (SVs) using **snpEff**. 

## 1. Installation

To install the latest version of snpEff, download and unzip the core package:

```bash
wget https://snpeff.blob.core.windows.net/versions/snpEff_latest_core.zip
unzip snpEff_latest_core.zip
```

## 2. Database Creation

Since specific species data might be missing from the default database, a custom database for *O. mykiss* must be created.

### 2.1 Check for Existing Databases
```bash
java -jar snpEff.jar databases | grep "mykiss"
```

### 2.2 Download Reference Data from NCBI
Download the genome and GTF files:
*   [NCBI FTP Link (USDA_OmykA_1.1)](https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/013/265/735/GCF_013265735.2_USDA_OmykA_1.1/)

```bash
gunzip -k GCF_013265735.2_USDA_OmykA_1.1_genomic.gtf.gz 
gunzip -k GCF_013265735.2_USDA_OmykA_1.1_genomic.fna.gz
```

### 2.3 Rename and Organize Files
Rename the files to the standard format required by snpEff and move them to the data directory:

```bash
mv GCF_013265735.2_USDA_OmykA_1.1_genomic.gtf genes.gtf
mv GCF_013265735.2_USDA_OmykA_1.1_genomic.fna sequences.fa

# Structure: snpeff_sv/snpEff/data/Oncorhynchus_mykiss/
```

### 2.4 Configure snpEff
Add the new genome entry to the `snpEff.config` file:

```bash
cd /snpeff_sv/snpEff
nano snpEff.config
```
Add the following line to the configuration:
`Oncorhynchus_mykiss.genome : Oncorhynchus mykiss`

### 2.5 Build the Database
Build the species-specific database:

```bash
java -jar snpEff.jar build -gtf22 -v Oncorhynchus_mykiss -noCheckCds -noCheckProtein
```

## 3. Execution

Run snpEff to annotate the filtered and merged VCF file:

```bash
java -Xmx8g -jar snpEff.jar -v Oncorhynchus_mykiss \
28_manta_lumpy_gatk_delly_clean_genotype80_maf01_pgd_gea.vcf > \
28_manta_lumpy_gatk_delly_clean_genotype80_maf01_pgd_gea_snpeff.vcf
```
