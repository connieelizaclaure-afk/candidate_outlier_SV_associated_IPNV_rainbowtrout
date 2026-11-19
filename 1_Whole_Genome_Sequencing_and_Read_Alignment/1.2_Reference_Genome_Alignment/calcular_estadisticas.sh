#!/bin/bash

# Output file
echo -e "Sample\tTotal_Reads\tMapped_Reads\tMapped_Bases\tMapping_Rate\tMean_Depth\tCoverage_10x" > sample_statistics.tsv

# Reference genome size (required for some calculations)
# Get this value from the .fai file or calculate it
GENOME_SIZE=2500000000  # Adjust this value according to reference genome

for bam in *.sorted.bam; do
sample=$(basename $bam .sorted.bam)
echo "Processing: $sample"

# 1. Total number of reads
TOTAL_READS=$(samtools view -c $bam 2>/dev/null)

# 2. Number of mapped reads
MAPPED_READS=$(samtools view -c -F 4 $bam 2>/dev/null)

# 3. Number of mapped bases
MAPPED_BASES=$(samtools stats $bam 2>/dev/null | grep "bases mapped (cigar)" | cut -f 3)

# 4. Mapping rate
MAPPING_RATE=$(echo "scale=2; $MAPPED_READS * 100 / $TOTAL_READS" | bc)

# 5. Mean depth (using samtools depth)
MEAN_DEPTH=$(samtools depth -a $bam 2>/dev/null | awk '{sum+=$3} END {print sum/NR}')

# 6. Fraction of genome covered >=10x
COVERAGE_10X=$(samtools depth -a $bam 2>/dev/null | awk -v total=$GENOME_SIZE '$3 >= 10 {count++} END {printf "%.4f", count/total}')

# Save results
echo -e "$sample\t$TOTAL_READS\t$MAPPED_READS\t$MAPPED_BASES\t$MAPPING_RATE\t$MEAN_DEPTH\t$COVERAGE_10X" >> sample_statistics.tsv
done
