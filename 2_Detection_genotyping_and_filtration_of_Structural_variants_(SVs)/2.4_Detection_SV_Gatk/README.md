# Structural Variant Detection using GATK

This directory contains the workflow for identifying structural variants (specifically INDELs) in *Oncorhynchus mykiss* using the Genome Analysis Toolkit (GATK) v4.3.0.0. The pipeline covers variant calling, genotyping, and a rigorous multi-step filtration process.

## 1. Installation of GATK

GATK was installed by downloading the release from the official repository:

```bash
cd /mnt/disco2/pcaceres/eliza_trout/softwares

wget https://github.com/broadinstitute/gatk/releases/download/4.3.0.0/gatk-4.3.0.0.zip
unzip gatk-4.3.0.0.zip
```

## 2. Reference Dictionary Generation

Before variant calling, a sequence dictionary must be created for the reference genome.

```bash
GATK=/mnt/disco2/pcaceres/eliza_trout/softwares/gatk-4.3.0.0/gatk
REF=/mnt/disco2/pcaceres/eliza_trout/reference/OmykA_1.1_manta.fna.gz

$GATK CreateSequenceDictionary -R $REF
```

**Note:** Ensure the reference file is accompanied by its index (`.fai`). Upon successful execution, an `OmykA_1.1_manta.dict` file is generated.

## 3. Haplotype Calling per Sample

Variants are called for each sample using `HaplotypeCaller` in GVCF mode, processed in parallel.

```bash
mkdir haplotypecaller
cd /mnt/disco2/pcaceres/eliza_trout/bam

ls *.sorted.bam | xargs -I @@ -P 7 sh -c "$GATK --java-options \"-Xmx7g\" HaplotypeCaller \
-I @@ \
-R $REF \
-ERC GVCF \
-O /mnt/disco2/pcaceres/eliza_trout/haplotypecaller/@@.g.vcf.gz"
```

**Note:** For each sample, two files are generated in the output folder: the `.g.vcf.gz` file and its corresponding `.tbi` index.

## 4. Merging GVCF Files

All individual GVCF files are combined into a single cohort file.

```bash
# Prepare the input string for all samples
dog=$(ls *.gz | sed 's/^/-V /')

mkdir GVCF

$GATK --java-options "-Xmx7g" CombineGVCFs \
-R $REF \
$dog \
-O ../GVCF/combined_gvcf.g.vcf.gz

# Verification
zcat combined_gvcf.g.vcf.gz | less -S
```

**Note:** The resulting `combined_gvcf.g.vcf.gz` should have a file size approximately equal to the sum of all individual input files.

## 5. Joint Genotyping

Final joint genotyping is performed on the combined population file.

```bash
cd GVCF/
  
$GATK --java-options "-Xmx124g" GenotypeGVCFs \
-R $REF \
-V combined_gvcf.g.vcf.gz \
-G StandardAnnotation \
-O 28_gatk_raw.vcf.gz

# Verification
zcat 28_gatk_raw.vcf.gz | less -S
```

## 6. Variant Filtration

Standard GATK hard-filtering criteria are applied to the raw VCF file.

```bash
$GATK --java-options "-Xmx7g" VariantFiltration \
-R $REF \
-V 28_gatk_raw.vcf.gz  \
--filter-name "LowQD" --filter-expression "QD < 2.0" \
--filter-name "HighFS" --filter-expression "FS > 60.0" \
--filter-name "LowMQ" --filter-expression "MQ < 40.0" \
--filter-name "HighSOR" --filter-expression "SOR > 3.0" \
-O 28_gatk_raw_filter.vcf.gz
```

### Filtration Criteria:
*   **QD (Quality by Depth):** Variants with QD < 2.0 are marked as "LowQD".
*   **FS (Fisher Strand):** Phred-scaled p-value for strand bias. FS > 60.0 is marked as "HighFS".
*   **MQ (Mapping Quality):** MQ < 40.0 indicates variants in difficult-to-map regions.
*   **SOR (Strand Odds Ratio):** SOR > 3.0 indicates significant strand bias.

## 7. Variant Selection by Type

The filtered file is split into specific variant classes, focusing on INDELs for the structural variant study.

```bash
# 7.1. Extract INDELs
$GATK --java-options "-Xmx7g" SelectVariants \
-R $REF \
-V 28_gatk_raw_filter.vcf.gz  \
--select-type-to-include INDEL \
-O 28_gatk_raw_filter_INDEL.vcf.gz

# 7.2. Extract SNPs
$GATK --java-options "-Xmx7g" SelectVariants \
-R $REF \
-V 28_gatk_raw_filter.vcf.gz   \
--select-type-to-include SNP \
-O 28_gatk_raw_filter_SNP.vcf.gz 

# 7.3. Count structural variants (INDELs)
python contar_variantes.py
```

## 8. Filtration Pipeline

A specific pipeline is executed to isolate high-quality structural variants.

1.  **Filter by PASS:** Retains only variants that passed all GATK filters.
    ```bash
    chmod +x filter_PASS.sh
    ./filter_PASS.sh
    ```

2.  **Add SVTYPE Annotation:** Essential for variant categorization.
    ```bash
    chmod +x SVTYPE_GATK.sh
    ./SVTYPE_GATK.sh
    ```

3.  **Chromosomal Contig Filtration (NC):** Excludes scaffolds (NW) and retains only variants on established chromosomes (NC).
    ```bash
    chmod +x filter_NC.sh
    ./filter_NC.sh 28_gatk_raw_filter_INDEL_PASS_SVTYPE.vcf.gz
    ```

4.  **Size Filtration:** Retains variants with sizes between 50 bp and 5,000 bp.
    ```bash
    chmod +x filter_size_gatk.sh
    ./filter_size_gatk.sh
    ```

5.  **Biallelic Data Selection:** Filters for biallelic sites only.
    ```bash
    bcftools view -m2 -M2 28_gatk_raw_filter_INDEL_PASS_SVTYPE_NC_SIZE.vcf.gz -O z -o 28_gatk_raw_filter_INDEL_PASS_SVTYPE_NC_SIZE_BI.vcf.gz
    bcftools index 28_gatk_raw_filter_INDEL_PASS_SVTYPE_NC_SIZE_BI.vcf.gz
    ```

## 9. Exploratory Data Analysis

Final analysis to determine the size and chromosomal position of the identified variants.

```bash
chmod +x size_gatk.sh
./size_gatk.sh 
```

**Final Output File:** `28_gatk_raw_filter_INDEL_PASS_SVTYPE_NC_SIZE_BI.vcf.gz`
