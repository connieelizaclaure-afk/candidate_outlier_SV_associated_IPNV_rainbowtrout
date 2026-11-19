#!/bin/bash

# Script to filter imprecise structural variants
# Input: diploid_merged_28samples_PASS_SVTYPE.vcf.gz 
# Output: diploid_merged_28samples_PASS_SVTYPE_precise.vcf.gz

# Define input and output files
INPUT_VCF="diploid_merged_28samples_PASS_SVTYPE.vcf.gz"
OUTPUT_VCF="diploid_merged_28samples_PASS_SVTYPE_precise.vcf.gz"

# Check if input file exists
if [ ! -f "$INPUT_VCF" ]; then
    echo "Error: Input file $INPUT_VCF not found!"
    exit 1
fi

# Filter imprecise variants using bcftools
echo "Filtering imprecise variants..."
bcftools view -e 'INFO/IMPRECISE=1' "$INPUT_VCF" | \
    bgzip > "$OUTPUT_VCF"

# Index the resulting VCF file
echo "Indexing output VCF file..."
tabix -p vcf "$OUTPUT_VCF"

echo "Process completed!"
echo "Output file: $OUTPUT_VCF"
echo "Index created: $OUTPUT_VCF.tbi"
