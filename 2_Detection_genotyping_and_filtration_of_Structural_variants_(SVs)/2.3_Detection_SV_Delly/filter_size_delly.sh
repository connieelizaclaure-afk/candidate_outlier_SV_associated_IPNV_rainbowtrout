#!/bin/bash

# Script: filter_size_delly.sh
# Description: Filters Delly VCF files excluding variants <50bp and >5,000bp
# Usage: ./filter_size_delly.sh input_file.vcf.gz

# Check argument
if [ "$#" -ne 1 ]; then
  echo "Error: You must provide exactly one compressed VCF file"
  echo "Usage: $0 input_file.vcf.gz"
  exit 1
fi

input_vcf="$1"
output_vcf="${input_vcf%.vcf.gz}_SIZE.vcf.gz"

# Check file existence
if [ ! -f "$input_vcf" ]; then
  echo "Error: File '$input_vcf' does not exist"
  exit 1
fi

# Filter variants by size (using Delly-specific fields)
echo "Filtering Delly structural variants by size..."
echo "Excluding variants <50bp and >5,000bp"

# For Delly, we use END - POS + 1 to calculate size
bcftools view "$input_vcf" \
  --include '( (END - POS + 1) >= 50 && (END - POS + 1) <= 5000 )' \
  -Oz -o "$output_vcf"

# Index the resulting file
echo "Indexing filtered file..."
bcftools index "$output_vcf"

echo "Filtering completed!"
echo "Input file: $input_vcf"
echo "Output file: $output_vcf"
