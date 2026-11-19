# SV Identification using Lumpy

This directory contains the pipeline for identifying structural variants (SVs) in *Oncorhynchus mykiss* using Lumpy. The workflow includes tool installation, generation of empirical statistics for library insert sizes, extraction of discordant and split-read alignments, SV calling, and a multi-step filtration process.

## 1. Installation

The Lumpy software is installed from the official repository and compiled locally.

```bash
cd /mnt/disco2/pcaceres/eliza_trout/softwares

git clone --recursive git@github.com:arq5x/lumpy-sv.git
cd lumpy-sv
make
cp bin/* /mnt/disco2/pcaceres/eliza_trout/softwares/lumpy-sv/bin/.
```

## 2. Generate Empirical Statistics for Insert Size

Empirical insert size statistics must be generated for each of the 28 samples to provide Lumpy with the necessary library parameters.

```bash
# Example for sample M0018
samtools view ./bam/M0018.sorted.bam \
| tail -n+100000 \
| ./softwares/lumpy-sv/scripts/pairend_distro.py \
-r 150 \
-X 4 \
-N 270000000 \
-o ./lumpy/M0018.lib1.histo 2>&1 \
| grep -E 'mean:|stdev:' \
>> Mean_stdev_M0018.txt
```

**Parameters:**
*   `-r`: Read length (150 bp).
*   `-X`: Number of standard deviations from the mean to the extension.
*   `-N`: Number of reads to sample.
*   `-o`: Output histogram file.

## 3. Verify Read Counts

Verify the number of reads per sample to ensure `-N` does not exceed the total available reads.

```bash
samtools flagstat ./bam/M0018.sorted.bam
```

## 4. Calculate Global Mean and Standard Deviation

The statistics from individual samples are processed and combined.

```bash
# Calculate statistics for each library
chmod +x samtool_lib1histo.sh
./samtool_lib1histo.sh

# Combine results into a single file
chmod +x combinar_stats.sh
./combinar_stats.sh
```

## 5. Extract Discordant Paired-End Alignments

Extract reads where the pairing is discordant (e.g., unexpected orientation or distance).

```bash
# Single sample extraction
samtools view -b -F 1294 M0018.sorted.bam > M0018.discordants.unsorted.bam

# Multiple sample extraction via script
chmod +x samtools_discordants.sh
./samtools_discordants.sh
```

## 6. Extract Split-Read Alignments

Extract reads that are split across different genomic locations, indicating a structural breakpoint.

```bash
# Single sample extraction
samtools view -h ./bam/M0018.sorted.bam \
| ./softwares/lumpy-sv/scripts/extractSplitReads_BwaMem -i stdin \
| samtools view -Sb - \
> ./bam/M0018.splitters.unsorted.bam

# Multiple sample extraction via script
chmod +x samtools_splitters_unsorted_bam.sh
./samtools_splitters_unsorted_bam.sh
```

## 7. Sort Alignments

Sort the discordant and split-read BAM files.

```bash
# Example for single sample
samtools sort -@ 4 -m 2G -o M0018.discordants.bam M0018.discordants.unsorted.bam
samtools sort -@ 4 -m 2G -o M0018.splitters.bam M0018.splitters.unsorted.bam

# Multiple sample sorting via script
chmod +x samtools_sort_splitters_discordants.sh
./samtools_sort_splitters_discordants.sh
```

## 8. Execute Lumpy SV Calling

SV calling is performed sample by sample using the calculated mean and standard deviation values.

```bash
# Example execution for sample M0018
lumpy \
-mw 4 \
-tt 0 \
-pe id:M0018,bam_file:M0018.discordants.bam,histo_file:M0018.lib1.histo,mean:304.91686086742595,stdev:66.112064280901,read_length:150,min_non_overlap:150,discordant_z:5,back_distance:10,weight:1,min_mapping_threshold:20 \
-sr id:M0018,bam_file:M0018.splitters.bam,back_distance:10,weight:1,min_mapping_threshold:20 \
> M0018.vcf
```
*Note: This process is repeated for all 28 samples (M0018 to S0373).*

## 9. Genotyping with SVTyper

Apply genotypes to the discovered SVs using `svtyper`.

```bash
conda activate svtyper_py2

# Example for sample M0018
svtyper \
-B /mnt/disco2/pcaceres/eliza_trout/bam/M0018.sorted.bam \
-i M0018.vcf \
-o M0018.gt.vcf
```

## 10. Compress and Index VCF Files

Prepare the genotyped files for merging.

```bash
bgzip *.gt.vcf

chmod +x fix_vcf_completely.sh
./fix_vcf_completely.sh
```

## 11. Merge VCF Files

Combine the individual sample VCFs into a single cohort file.

```bash
chmod +x merged_gt.sh
./merged_gt.sh

# Verify the merged file
bcftools view 28_lumpy_SV_merged.vcf | less -S
```

## 12. Sort and Index Merged VCF

```bash
vcf-sort 28_lumpy_SV_merged.vcf | bgzip > 28_lumpy_SV_merged.vcf.gz
tabix -p vcf 28_lumpy_SV_merged.vcf.gz

# Initial SV count by type
bcftools query -f '%SVTYPE\n' 28_lumpy_SV_merged.vcf.gz | sort | uniq -c
```

## 13. Filtration Pipeline

The SVs are filtered through five distinct stages to ensure high-quality variant calls.

1.  **Filter by SVTYPE:** Retain only DEL, DUP, and INV.
    ```bash
    chmod +x filter_lumpy_SVTYPE.sh
    ./filter_lumpy_SVTYPE.sh
    ```
2.  **Filter by Precision:** Retain only precise variants (exclude IMPRECISE).
    ```bash
    chmod +x filter_imprecise.sh
    ./filter_imprecise.sh
    ```
3.  **Filter by Chromosome (NC):** Exclude scaffolds (NW) and retain only chromosome-level contigs (NC).
    ```bash
    chmod +x filter_NC.sh
    ./filter_NC.sh 28_lumpy_SV_merged_SVTYPE_PRECISE.vcf.gz
    ```
4.  **Filter by Size (SVLEN):** Apply length-based filters.
    ```bash
    chmod +x filter_size.sh
    ./filter_size.sh 28_lumpy_SV_merged_SVTYPE_PRECISE_NC.vcf.gz
    ```
5.  **Filter for Biallelic Data:**
    ```bash
    bcftools view -m2 -M2 28_lumpy_SV_merged_SVTYPE_PRECISE_NC_SIZE.vcf.gz -O z -o 28_lumpy_SV_merged_SVTYPE_PRECISE_NC_SIZE_BI.vcf.gz
    bcftools index 28_lumpy_SV_merged_SVTYPE_PRECISE_NC_SIZE_BI.vcf.gz
    ```

## 14. Exploratory Data Analysis

Final counts are generated to summarize the SVs found across the cohort.

```bash
# Count SVs per sample
chmod +x count_sv_sample.sh
./count_sv_sample.sh
```

**Final Output:** `28_lumpy_SV_merged_SVTYPE_PRECISE_NC_SIZE_BI.vcf.gz`
