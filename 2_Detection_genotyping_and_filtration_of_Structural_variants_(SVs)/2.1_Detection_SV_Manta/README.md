# 2.1 Detection and Genotyping of Structural Variants (SVs) with Manta

This directory contains the pipeline for the detection, genotyping, and filtration of Structural Variants (SVs) in *Oncorhynchus mykiss* using the Manta software and customized bioinformatics workflows.

## Workflow Overview

The process follows a structured sequence from software installation and environment setup to multi-step variant filtration to ensure high-confidence results.

---

### 1. Software Installation and Environment Setup

Manta and its dependencies are managed via a dedicated Conda environment to ensure reproducibility and version control.

```bash
# Create and activate the Manta environment
conda create -n manta_env -c bioconda manta
conda activate manta_env
```

---

### 2. Manta Workflow Configuration

Manta requires a configuration step where it analyzes the alignment files (BAM) to generate the execution scripts.

```bash
# Configuration for germline SV calling
configManta.py \
    --bam sample1.bam \
    --bam sample2.bam \
    --reference reference_genome.fa \
    --runDir ./manta_workdir
```

---

### 3. Execution of the Manta Pipeline

Once configured, the analysis is executed using the generated Python script.

```bash
# Execution using 8 parallel cores
python ./manta_workdir/runWorkflow.py -m local -j 8
```

---

### 4. Conversion of Inversions

By default, Manta represents inversions as breakends (BND). To simplify downstream analysis, these are converted to a standard INV format.

```bash
# Convert breakends to inversions
python convertInversion.py \
    --samtools /usr/bin/samtools \
    --reference reference_genome.fa \
    --vcf ./manta_workdir/results/variants/diploidSV.vcf.gz > diploidSV_converted.vcf
```

---

### 5. Seven-Step SV Filtration Pipeline

To ensure the quality of the candidates, a rigorous 7-step filtration process is implemented using `bcftools` and custom filtering scripts.

* **Basic Quality and PASS Filter**
Keep only variants that passed all internal Manta filters and have a high quality score.
```bash
bcftools filter -i 'FILTER=="PASS" && QUAL > 20' diploidSV_converted.vcf -o sv_step1.vcf
```

* **Size Selection**
Filter SVs based on biologically relevant size ranges (e.g., > 50bp).
```bash
bcftools filter -i 'SVLEN > 50 || SVLEN < -50' sv_step1.vcf -o sv_step2.vcf
```

* **Missing Data Filtration**
Exclude variants with more than 10% missing genotypes across the population.
```bash
bcftools view -e 'F_MISSING > 0.1' sv_step2.vcf -o sv_step3.vcf
```

* **Read Support Filter**
Ensure variants are supported by a minimum number of spanning reads and split-reads.
```bash
# Custom filter for read depth and support
bcftools filter -i 'INFO/SR > 5 || INFO/PR > 5' sv_step3.vcf -o sv_step4.vcf
```

* **Minor Allele Frequency (MAF)**
Filter by MAF to remove rare variants or potential sequencing artifacts.
```bash
bcftools view -i 'MAF > 0.05' sv_step4.vcf -o sv_step5.vcf
```

* **Hardy-Weinberg Equilibrium (HWE)**
Remove variants that deviate significantly from HWE expectations.
```bash
bcftools filter -e 'HWE < 0.001' sv_step5.vcf -o sv_step6.vcf
```

* **Final Clean-up and Normalization**
Standardize the VCF format for final analysis.
```bash
bcftools norm -m -any sv_step6.vcf -f reference_genome.fa -o final_sv_manta.vcf
```

---

### Technical Notes
- **Manta Version:** Ensure you are using version 1.6.0 or higher.
- **Reference Genome:** Use the same indexed FASTA file employed in the alignment phase.
- **Resources:** Multi-sample SV calling is memory-intensive; ensure at least 4GB of RAM per core is available.
