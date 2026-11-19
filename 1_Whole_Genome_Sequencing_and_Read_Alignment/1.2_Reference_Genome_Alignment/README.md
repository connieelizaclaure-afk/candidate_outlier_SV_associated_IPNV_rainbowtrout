# Reference Genome Alignment

This directory contains the pipeline for aligning whole-genome sequencing reads to the rainbow trout (*Oncorhynchus mykiss*) reference genome (USDA_OmykA_1.1). The analysis utilizes data from the IPNV challenge test conducted by Effigen S.A.

## Steps for Reference Genome Alignment

### 1. Reference Genome Retrieval
Navigate to the project analysis directory and download the rainbow trout reference genome assembly from the NCBI database.

```bash
# Enter the analysis directory
cd /mnt/disco2/pcaceres/eliza_trout

# Navigate to the reference folder and download the assembly (GCF_013265735.2)
cd reference
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/013/265/735/GCF_013265735.2_USDA_OmykA_1.1/GCF_013265735.2_USDA_OmykA_1.1_genomic.fna.gz
```

### 2. Genome Indexing
Index the reference genome using `BWA` to facilitate rapid read mapping.

```bash
bwa index GCF_013265735.2_USDA_OmykA_1.1_genomic.fna.gz
```

### 3. Read Mapping, Sorting, and Compression
Execute the alignment script using BWA-MEM. This process generates sorted BAM files and their corresponding indices for each sample.

* **Execute the alignment pipeline**

>chmod +x bwa.sh
>./bwa.sh

_# Expected output files per sample: .sorted.bam and .sorted.bam.bai_

* **Verify BAM file headers and coordinate sorting**

>samtools view -H M0018.sorted.bam | grep "SO:coordinate"

_# Confirmation of @HD VN:1.6 SO:coordinate indicates correct sorting. Errors will trigger a header read failure._

### 4. Sample Mapping Statistics
Generate descriptive statistics for each BAM file. These metrics (e.g., total reads, mapped percentage, and properly paired reads) are essential for subsequent structural variant detection using Lumpy.

* **Calculate flagstat metrics for a single sample**

>samtools flagstat M0018.sorted.bam

_# Example output:_  
_# 264094755 + 0 in total (QC-passed reads + QC-failed reads)_  
_# 3663669 + 0 secondary_  
_# 0 + 0 supplementary_  
_# 0 + 0 duplicates_  
_# 263618069 + 0 mapped (99.82% : N/A)_  
_# 260431086 + 0 paired in sequencing_  
_# 130215543 + 0 read1_  
_# 130215543 + 0 read2_  
_# 248163550 + 0 properly paired (95.29% : N/A)_  
_# 259736634 + 0 with itself and mate mapped_  
_# 217766 + 0 singletons (0.08% : N/A)_  
_# 7604314 + 0 with mate mapped to a different chr_  
_# 3222665 + 0 with mate mapped to a different chr (mapQ>=5)_

### 5. Batch Statistical Processing
Run the automated script to compile alignment statistics across the entire sample set.

* **Run the batch statistics script**

>chmod +x calcular_estadisticas.sh
>./calcular_estadisticas.sh
