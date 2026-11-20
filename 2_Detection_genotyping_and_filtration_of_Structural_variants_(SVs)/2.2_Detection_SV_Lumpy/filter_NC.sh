#!/bin/bash

# Script: filter_NC.sh
# Description: Filters a VCF to keep only NC contigs (excluding NW)
# Usage: ./filter_NC.sh input.vcf.gz

if [ "$#" -ne 1 ]; then
    echo "Error: Usage: $0 input.vcf.gz"
    exit 1
fi

input_vcf="$1"
output_vcf="${input_vcf%.vcf.gz}_NC.vcf.gz"

# Check input file
if [ ! -f "$input_vcf" ]; then
    echo "Error: $input_vcf does not exist."
    exit 1
fi

# Method 1: Use awk to filter NC contigs and header
echo "Filtering NC contigs..."
zcat "$input_vcf" | awk '$1 ~ /^NC/ || $0 ~ /^#/' | bgzip > "$output_vcf"

# Index
echo "Indexing $output_vcf..."
tabix -p vcf "$output_vcf"

echo "Done! Filtered file: $output_vcf"
