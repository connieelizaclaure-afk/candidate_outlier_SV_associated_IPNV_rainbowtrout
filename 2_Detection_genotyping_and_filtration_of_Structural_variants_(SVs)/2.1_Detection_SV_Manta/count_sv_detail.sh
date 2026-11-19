#!/bin/bash

# ------------------------------------------------------
# Script to count SVs by type and sample in VCF.gz
# Requires: bcftools, tabix
# Usage: ./count_sv_detail.sh diploid_merged_28samples_PASS_precise_NC_SIZE_BI.vcf.gz
# ------------------------------------------------------

INPUT_VCF=$1

# Check input
if [ $# -eq 0 ]; then
    echo "Error: Provide VCF.gz file as argument"
    exit 1
fi

if [ ! -f "$INPUT_VCF" ]; then
    echo "Error: File $INPUT_VCF not found"
    exit 1
fi

# Get sample list
SAMPLES=($(bcftools query -l $INPUT_VCF))
NUM_SAMPLES=${#SAMPLES[@]}
SV_TYPES=("DEL" "DUP" "INS" "INV")

echo "Processing $NUM_SAMPLES samples..."
echo "=============================================================="

# Count variants by type and sample
bcftools query -f '%SVTYPE\t[%GT\t]\n' $INPUT_VCF | \
awk -v samples="${SAMPLES[*]}" -v num_samples="$NUM_SAMPLES" -v sv_types="${SV_TYPES[*]}" '
BEGIN {
    split(samples, s, " ")
    split(sv_types, st, " ")
    
    # Initialize counting arrays
    for (i=1; i<=num_samples; i++) {
        total[s[i]] = 0
        for (j=1; j<=4; j++) {
            counts[s[i], st[j]] = 0
        }
    }
}
{
    svtype = $1
    for (i=1; i<=num_samples; i++) {
        gt = $(i+1)
        if (gt != "0/0" && gt != "./.") {
            total[s[i]]++
            counts[s[i], svtype]++
        }
    }
}
END {
    # Print headers
    printf "%-15s\t%8s\t%8s\t%8s\t%8s\t%8s\n", 
           "Sample", "Total", "DEL", "DUP", "INS", "INV"
    
    # Print data
    for (i=1; i<=num_samples; i++) {
        sample = s[i]
        printf "%-15s\t%8d\t%8d\t%8d\t%8d\t%8d\n", 
               sample,
               total[sample],
               counts[sample, "DEL"],
               counts[sample, "DUP"],
               counts[sample, "INS"],
               counts[sample, "INV"]
    }
}'

echo "=============================================================="
