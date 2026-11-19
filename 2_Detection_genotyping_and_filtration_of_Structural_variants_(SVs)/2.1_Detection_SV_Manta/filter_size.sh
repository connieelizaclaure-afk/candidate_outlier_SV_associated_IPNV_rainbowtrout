#!/bin/bash

# Script: filter_size.sh
# Description: Filters VCF to exclude structural variants <50bp, >5,000bp and without SVLEN value
# Usage: ./filter_size.sh input_file.vcf.gz

# Check that argument is provided
if [ "$#" -ne 1 ]; then
    echo "Error: Incorrect number of arguments."
    echo "Usage: $0 input_file.vcf.gz"
    exit 1
fi

input_vcf="$1"
output_vcf="${input_vcf%.vcf.gz}_SIZE.vcf.gz"

# Check if input file exists
if [ ! -f "$input_vcf" ]; then
    echo "Error: Input file '$input_vcf' does not exist."
    exit 1
fi

# Filter by size with bcftools
echo "Filtering structural variants by size (50bp <= |SVLEN| <= 5,000bp)..."
echo "Excluding variants without SVLEN value"

bcftools view "$input_vcf" \
    --include '(abs(SVLEN) >= 50 && abs(SVLEN) <= 5000)' \
    -Oz -o "$output_vcf"

# Index the output file
echo "Indexing output file..."
bcftools index "$output_vcf"

echo "Filtering completed! Output file: $output_vcf"
