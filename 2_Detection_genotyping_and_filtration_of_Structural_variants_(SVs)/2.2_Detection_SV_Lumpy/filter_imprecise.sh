#!/bin/bash

# Script to filter imprecise structural variants
# Input: 28_lumpy_SV_merged_SVTYPE.vcf.gz
# Output: 28_lumpy_SV_merged_SVTYPE_PRECISE.vcf.gz

# Define input and output files
INPUT_VCF="28_lumpy_SV_merged_SVTYPE.vcf.gz"
OUTPUT_VCF="28_lumpy_SV__SVTYPE_PRECISE.vcf.gz"

# Check if the input file exists
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
