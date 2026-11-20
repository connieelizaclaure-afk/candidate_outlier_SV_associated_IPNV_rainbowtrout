#!/bin/bash

# Script to filter variants with PASS criterion
# Input: 28_delly_SV_merged.vcf.gz
# Output: 28_delly_SV_merged_PASS.vcf.gz

# Define files
INPUT_VCF="28_delly_SV_merged.vcf.gz"
OUTPUT_VCF="28_delly_SV_merged_PASS.vcf.gz"

# Check input file and index
if [ ! -f "$INPUT_VCF" ]; then
  echo "Error: Input file $INPUT_VCF not found!"
  exit 1
fi

if [ ! -f "$INPUT_VCF.tbi" ]; then
  echo "Error: Index $INPUT_VCF.tbi not found!"
  exit 1
fi

# Filter PASS variants
echo "Filtering variants with PASS criterion..."
bcftools view -f "PASS" -Oz -o "$OUTPUT_VCF" "$INPUT_VCF"

# Index the output file
echo "Indexing output VCF file..."
tabix -p vcf "$OUTPUT_VCF"

echo "Filtering completed!"
echo "Output file: $OUTPUT_VCF"
echoIndex created: $OUTPUT_VCF.tbi"
