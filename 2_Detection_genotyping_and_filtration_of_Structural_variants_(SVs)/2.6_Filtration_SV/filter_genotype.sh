#!/bin/bash

# Input file name
INPUT_VCF="28_manta_lumpy_gatk_delly_noGenotypes_clean_sorted_annotate.vcf"
OUTPUT_VCF="28_manta_lumpy_gatk_delly_clean_genotype80.vcf"

# Check if the file exists
if [ ! -f "$INPUT_VCF" ]; then
    echo "Error: File $INPUT_VCF does not exist."
    exit 1
fi

echo "Starting filtering: Keeping variants with genotype rate >= 80%..."

# Command explanation:
# -i 'F_MISSING <= 0.2': Filters variants where the missing data fraction is less than or equal to 20% (equivalent to a genotype rate >= 80%).
# -O v: Specifies that the output should be in VCF format.
# -o: Output file.

bcftools view -i 'F_MISSING <= 0.2' "$INPUT_VCF" -O v -o "$OUTPUT_VCF"

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Process completed. Filtered file generated: $OUTPUT_VCF"
else
    echo "Error: A problem occurred during filtering."
    exit 1
fi
