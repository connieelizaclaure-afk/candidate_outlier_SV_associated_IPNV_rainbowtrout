#!/bin/bash

# ------------------------------------------------------
# Script to filter SV by type in VCF.gz
# Requires: bcftools, tabix
# Usage: ./filter_svtype.sh diploid_merged_28samples_PASS.vcf.gz
# ------------------------------------------------------

# Check input parameters
if [ $# -eq 0 ]; then
    echo "Error: Provide VCF.gz file as argument"
    echo "Example: ./filter_svtype.sh diploid_merged_28samples_PASS.vcf.gz"
    exit 1
fi

INPUT_VCF=$1
OUTPUT_VCF="diploid_merged_28samples_PASS_SVTYPE.vcf.gz"

# Check file existence
if [ ! -f "${INPUT_VCF}" ]; then
    echo "Error: Input file not found: ${INPUT_VCF}"
    exit 1
fi

if [ ! -f "${INPUT_VCF}.tbi" ]; then
    echo "Error: .tbi index not found for ${INPUT_VCF}"
    exit 1
fi

# Filter variant types
echo "Filtering SVTYPE: DEL, DUP, INS, INV..."
bcftools view ${INPUT_VCF} \
    -i 'SVTYPE="DEL" || SVTYPE="DUP" || SVTYPE="INS" || SVTYPE="INV"' \
    -Oz \
    -o ${OUTPUT_VCF}

# Index output file
echo "Indexing output file..."
tabix -p vcf ${OUTPUT_VCF}

# Generate report
echo "=== Filtering completed ==="
echo "Output file: ${OUTPUT_VCF}"
echo "Total filtered variants: $(bcftools view -H ${OUTPUT_VCF} | wc -l)"

echo -e "\nFinal SV type distribution:"
bcftools query -f '%SVTYPE\n' ${OUTPUT_VCF} | 
    sort | 
    uniq -c |
    awk '{printf "%-5s: %d (%.2f%%)\n", $2, $1, ($1/'$(bcftools view -H ${OUTPUT_VCF} | wc -l)')*100}'

echo -e "\nVerification of excluded types (BND):"
bcftools query -f '%SVTYPE\n' ${OUTPUT_VCF} | 
    grep "BND" | 
    wc -l | 
    awk '{print "Number of remaining BND: " $1}'
