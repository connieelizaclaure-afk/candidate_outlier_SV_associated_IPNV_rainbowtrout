#!/bin/bash

# Script to filter a Lumpy VCF keeping only:
# DEL, DUP, INV, INS, CNV

# Input and output files
INPUT_VCF="28_lumpy_SV_merged.vcf.gz"
OUTPUT_VCF="28_lumpy_SV_merged_SVTYPE.vcf.gz"

# Check dependencies
if ! command -v bcftools &> /dev/null; then
    echo "Error: bcftools is not. Install with: conda install -c bioconda bcftools"
    exit 1
fi

if ! command -v tabix &> /dev/null; then
    echo "Error: tabix is not installed. Install with: conda install -c bioconda htslib"
    exit 1
fi

# Verify that the input file exists
if [ ! -f "$INPUT_VCF" ]; then
    echo "Error: Input file $INPUT_VCF not found"
    exit 1
fi

# Filter with explicit logical conditions
echo "Filtering structural variants..."
bcftools view -i 'INFO/SVTYPE="DEL" || INFO/SVTYPE="DUP" || INFO/SVTYPE="INV" || INFO/SVTYPE="INS" || INFO/SVTYPE="CNV"' \
    "$INPUT_VCF" -Oz -o "$OUTPUT_VCF"

# Index the result
echo "Indexing output file..."
tabix -p vcf "$OUTPUT_VCF"

# Final report
echo -e "\nSummary of retained variants:"
bcftools query -f '%SVTYPE\n' "$OUTPUT_VCF" | sort | uniq -c | awk '{print $2": "$1}'

echo -e "\nProcess completed!"
echo "Filtered file: $OUTPUT_VCF"
echo "Generated index: $OUTPUT_VCF.tbi"
