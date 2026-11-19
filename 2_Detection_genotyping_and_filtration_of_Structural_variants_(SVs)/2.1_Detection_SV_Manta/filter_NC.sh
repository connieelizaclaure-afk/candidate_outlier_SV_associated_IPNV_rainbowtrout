#!/bin/bash

# Script: filter_NC.sh
# Description: Filters a VCF file to keep only NC contigs (chromosomes) 
#              and exclude NW contigs (unassembled scaffolds)
# Usage: ./filter_NC.sh input.vcf.gz

# Check that argument is provided
if [ "$#" -ne 1 ]; then
    echo "Error: Incorrect number of arguments"
    echo "Usage: $0 input.vcf.gz"
    exit 1
fi

INPUT_VCF="$1"
OUTPUT_VCF="${INPUT_VCF%.vcf.gz}_NC.vcf.gz"

# Check that input file exists
if [ ! -f "$INPUT_VCF" ]; then
    echo "Error: Input file $INPUT_VCF does not exist"
    exit 1
fi

# Check that bcftools is installed
if ! command -v bcftools &> /dev/null; then
    echo "Error: bcftools is not installed or not in PATH"
    exit 1
fi

# Extract the list of NC contigs from the VCF file
CONTIGS_NC=$(bcftools view -h "$INPUT_VCF" | grep -E '^##contig=<ID=NC_' | cut -d'=' -f3 | cut -d',' -f1 | tr '\n' ',' | sed 's/,$//')

if [ -z "$CONTIGS_NC" ]; then
    echo "Error: No NC contigs found in the VCF file"
    exit 1
fi

# Filter to keep only NC contigs
echo "Filtering NC contigs..."
bcftools view -t "$CONTIGS_NC" -Oz -o "$OUTPUT_VCF" "$INPUT_VCF"

# Index the output VCF file
echo "Indexing output file..."
bcftools index -t "$OUTPUT_VCF"

echo "Process completed. Generated file: $OUTPUT_VCF"

