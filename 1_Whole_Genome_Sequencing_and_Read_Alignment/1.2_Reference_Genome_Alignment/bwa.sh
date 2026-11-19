#!/bin/bash

# Variables
REF=/mnt/disco2/pcaceres/eliza_trout/reference/GCF_013265735.2_USDA_OmykA_1.1_genomic.fna.gz

# Create folders if they don't exist
mkdir -p sam bam

# Maximum number of parallel processes
MAX_JOBS=3
# Current job counter
job_count=0

# Loop for each sample
for fq1 in ./raw_data/*_1.fq.gz; do
fq2=${fq1/_1/_2}
base=$(basename $fq1 _1.fq.gz)

(
  echo "Processing sample: $base"
  
  rg_string='@RG\tID:'$base'\.1\tSM:'$base'\tPL:illumina\tLB:1\tPU:1'
  
  # Step 1: alignment with BWA MEM
  bwa mem -t 8 -M -R $rg_string $REF $fq1 $fq2 > ./sam/$base.sam
  
  # Step 2: convert SAM to BAM and sort
  samtools sort -@ 4 -o ./bam/$base.sorted.bam ./sam/$base.sam
  
  # Step 3: index the BAM
  samtools index ./bam/$base.sorted.bam
  
  echo "Completed: $base"
) &
  
  ((job_count++))

# Wait if there are already 3 jobs running
if [[ $job_count -ge $MAX_JOBS ]]; then
wait
job_count=0
fi
done

# Wait for any remaining processes
wait
