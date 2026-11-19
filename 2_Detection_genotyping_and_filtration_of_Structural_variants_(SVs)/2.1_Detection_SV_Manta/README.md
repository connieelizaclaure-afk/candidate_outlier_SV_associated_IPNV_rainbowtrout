# Structural Variant Detection using Manta

Identification of Structural Variants (SV) in Rainbow Trout (*Oncorhynchus mykiss*) for the IPNv challenge test, Effigen S.A.

---

## 1. Environment Setup
Manta requires a Python 2.7 environment for execution.

```bash
# Create the environment named 'manta'
conda create --name manta python=2.7

# Activate the environment
conda activate manta

# To deactivate the environment when finished
# conda deactivate
```

## 2. Installation
Navigate to your software directory and download the Manta release.

```bash
cd /mnt/disco2/pcaceres/eliza_trout/softwares

wget https://github.com/Illumina/manta/releases/download/v${MANTA_VERSION}/manta-${MANTA_VERSION}.release_src.tar.bz2
tar -xjf manta-${MANTA_VERSION}.release_src.tar.bz2
mkdir build && cd build
```

## 3. Workflow Execution
Configure and run the Manta analysis for the 28 sorted BAM files.

```bash
mkdir manta

python ./softwares/manta2/bin/configManta.py \
--bam ./bam/M0018.sorted.bam \
--bam ./bam/M0675.sorted.bam \
--bam ./bam/M0679.sorted.bam \
--bam ./bam/M0696.sorted.bam \
--bam ./bam/M0943.sorted.bam \
--bam ./bam/M0993.sorted.bam \
--bam ./bam/M1010.sorted.bam \
--bam ./bam/M1011.sorted.bam \
--bam ./bam/M1013.sorted.bam \
--bam ./bam/M1015.sorted.bam \
--bam ./bam/M1017.sorted.bam \
--bam ./bam/M1021.sorted.bam \
--bam ./bam/M1043.sorted.bam \
--bam ./bam/M1048.sorted.bam \
--bam ./bam/S0080.sorted.bam \
--bam ./bam/S0093.sorted.bam \
--bam ./bam/S0098.sorted.bam \
--bam ./bam/S0107.sorted.bam \
--bam ./bam/S0116.sorted.bam \
--bam ./bam/S0130.sorted.bam \
--bam ./bam/S0159.sorted.bam \
--bam ./bam/S0168.sorted.bam \
--bam ./bam/S0169.sorted.bam \
--bam ./bam/S0185.sorted.bam \
--bam ./bam/S0343.sorted.bam \
--bam ./bam/S0350.sorted.bam \
--bam ./bam/S0368.sorted.bam \
--bam ./bam/S0373.sorted.bam \
--referenceFasta ./reference/OmykA_1.1_manta.fna.gz \
--runDir ./manta/manta_trucha

# Execute the workflow
cd manta_trucha
python runWorkflow.py
```

## 4. Inversion Conversion (BND to INV)
Manta reports inversions as breakends (BND) by default. Use `convertInversion.py` to reformat them into simple inverted sequence junctions.

```bash
python ./softwares/manta2/libexec/convertInversion.py /usr/bin/samtools ./reference/OmykA_1.1_manta.fna.gz ./manta_merged/candidateSV.vcf > ./jasminesv/candidateSV_INV.vcf
python ./softwares/manta2/libexec/convertInversion.py /usr/bin/samtools ./reference/OmykA_1.1_manta.fna.gz ./manta_merged/candidateSmallIndels.vcf > ./jasminesv/candidateSmallIndels_INV.vcf
python ./softwares/manta2/libexec/convertInversion.py /usr/bin/samtools ./reference/OmykA_1.1_manta.fna.gz ./manta_merged/diploidSV.vcf > ./jasminesv/diploid_merged_28samples_PASS.vcf
```

## 5. Filtering Process
The following criteria are applied to the VCF files:
1. Retain only variants with a `PASS` filter status.
2. Keep only specific SV types: DEL, INS, DUP, and INV (excluding BND).
3. Filter by precision, chromosome name (NC), and size (SVLEN).

### 5.1. Filter by PASS
```bash
chmod +x filter_pass_sv.sh
./filter_pass_sv.sh merged_28samples.vcf.gz
```

### 5.2. Filter by SVTYPE
```bash
chmod +x filter_svtype.sh
./filter_svtype.sh diploid_merged_28samples_PASS.vcf.gz
```

### 5.3. Filter by IMPRECISE
```bash
chmod +x filter_imprecise.sh
./filter_imprecise.sh
```

### 5.4. Filter by Contig (NC_)
Extracts chromosomes (NC) and excludes scaffolds (NW).
```bash
chmod +x filter_NC.sh
./filter_NC.sh diploid_merged_28samples_PASS_precise.vcf.gz
```

### 5.5. Filter by Size (SVLEN)
```bash
chmod +x filter_size.sh
./filter_size.sh diploid_merged_28samples_PASS_precise_NC.vcf.gz
```

### 5.6. Biallelic Data Filtering
```bash
bcftools view -m2 -M2 diploid_merged_28samples_PASS_precise_NC_SIZE.vcf.gz -O z -o diploid_merged_28samples_PASS_precise_NC_SIZE_BI.vcf.gz
bcftools index diploid_merged_28samples_PASS_precise_NC_SIZE_BI.vcf.gz
```

## 6. Exploratory Data Analysis
```bash
chmod +x count_sv_detail.sh
./count_sv_detail.sh diploid_merged_28samples_PASS_precise_NC_SIZE_BI.vcf.gz
```

**Final Output File:** `diploid_merged_28samples_PASS_precise_NC_SIZE_BI.vcf.gz`
