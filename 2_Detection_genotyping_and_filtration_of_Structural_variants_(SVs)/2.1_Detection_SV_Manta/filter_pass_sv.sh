#!/bin/bash

# --------------------------------------------
# Script to filter PASS variants in VCF.gz
# Requires: bcftools
# Usage: ./filter_pass_sv.sh merged_28samples.vcf.gz
# --------------------------------------------

# Check parameters and files
if [ $# -eq 0 ]; then
    echo "Error: Provide VCF.gz file as argument"
    echo "Example: ./filter_pass_sv.sh merged_28samples.vcf.gz"
    exit 1
fi

INPUT_VCF=$1
OUTPUT_VCF="diploid_merged_28samples_PASS.vcf.gz"

# Check file existence
if [ ! -f "${INPUT_VCF}" ]; then
    echo "Error: Input VCF file not found: ${INPUT_VCF}"
    exit 1
fi

if [ ! -f "${INPUT_VCF}.tbi" ]; then
    echo "Error: .tbi index not found for ${INPUT_VCF}"
    exit 1
fi

# Filter PASS variants
echo "Filtering PASS variants..."
bcftools view ${INPUT_VCF} \
    -i 'FILTER="PASS"' \
    -Oz \
    -o ${OUTPUT_VCF}

# Index output file
echo "Indexing output file..."
tabix -p vcf ${OUTPUT_VCF}

# Generate report
echo "=== Filtering results ==="
echo "Input file: ${INPUT_VCF}"
echo "Output file: ${OUTPUT_VCF}"
echo "Number of PASS variants: $(bcftools view -H ${OUTPUT_VCF} | wc -l)"

echo -e "\nVariant type distribution:"
bcftools query -f '%INFO/SVTYPE\n' ${OUTPUT_VCF} | 
    sort | 
    uniq -c | 
    awk '{printf "%-5s: %d (%.2f%%)\n", $2, $1, ($1/'$(bcftools view -H ${OUTPUT_VCF} | wc -l)')*100}'

echo -e "\nFirst 5 PASS variants:"
bcftools view ${OUTPUT_VCF} | 
    grep -v "^#" | 
    head -n 5 | 
    cut -f1-5,7,8 | 
    awk '{printf "%-5s %-9s %-15s %-5s %-15s %-10s %s\n", $1, $2, $3, $4, $5, $6, $7}'
