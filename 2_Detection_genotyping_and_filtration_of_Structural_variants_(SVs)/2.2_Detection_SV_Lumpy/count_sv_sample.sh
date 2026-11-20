#!/bin/bash

# Improved script to count SVs using SU/PE/SR fields instead of GT
input_vcf="28_lumpy_SV_merged_SVTYPE_PRECISE_NC_SIZE_BI.vcf.gz"

# Get sample list from VCF
samples=($(bcftools query -l "$input_vcf"))

# Process data using SU (Split Reads) as presence criterion
bcftools query -f '%INFO/SVTYPE\t[%SU ]\n' "$input_vcf" | \
awk -v SAMPLES="${samples[*]}" '
BEGIN {
    split(SAMPLES, samples_arr, " ");
    total_samples = length(samples_arr);
    printf "Sample\tTotal_SVs\tDEL\tDUP\tINV\n";
}
{
    svtype = $1;
    for (i=1; i<=total_samples; i++) {
        su = $(i+1);
        # Count if there is at least 1 split read (SU > 0)
        if (su + 0 > 0) {
            counts[i,"total"]++;
            if (svtype == "DEL") counts[i,"DEL"]++;
            else if (svtype == "DUP") counts[i,"DUP"]++;
            else if (svtype == "INV") counts[i,"INV"]++;
        }
    }
}
END {
    for (i=1; i<=total_samples; i++) {
        total = (counts[i,"total"] != "") ? counts[i,"total"] : 0;
        del = (counts[i,"DEL"] != "") ? counts[i,"DEL"] : 0;
        dup = (counts[i,"DUP"] != "") ? counts[i,"DUP"] : 0;
        inv = (counts[i,"INV"] != "") ? counts[i,"INV"] : 0;
        printf "%s\t%d\t%d\t%d\t%d\n", samples_arr[i], total, del, dup, inv;
    }
}' | column -t
