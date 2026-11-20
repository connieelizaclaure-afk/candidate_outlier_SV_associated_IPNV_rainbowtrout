#!/bin/bash

INPUT_VCF="28_gatk_raw_filter_INDEL_PASS_SVTYPE_NC.vcf.gz"
OUTPUT_VCF="28_gatk_raw_filter_INDEL_PASS_SVTYPE_NC_SIZE.vcf.gz"

# Process VCF using END when available
zcat "$INPUT_VCF" | \
awk -v OFS="\t" '
# Keep headers
/^##/ {print; next}
/^#CHROM/ {print; next}

{
    # Extract fields
    chrom = $1
    pos = $2
    info = $8
    
    # Initialize size
    size = 0
    use_end = 0
    
    # Search for END field in INFO
    if (info ~ /END=[0-9]+/) {
        split(info, info_arr, ";")
        for (i in info_arr) {
            if (info_arr[i] ~ /^END=/) {
                split(info_arr[i], end_arr, "=")
                end = end_arr[2]
                
                # Calculate size using END
                size = end - pos + 1
                use_end = 1
                break
            }
        }
    }
    
    # If END not found, calculate REF/ALT length difference
    if (!use_end) {
        ref_len = length($4)
        alt_len = length($5)
        size = (alt_len > ref_len) ? alt_len - ref_len : ref_len - alt_len
    }
    
    # FILTER: Keep only variants with size between 50 and 5000 bp
    if (size >= 50 && size <= 5000) {
        print
    }
}
' | bgzip -c > "$OUTPUT_VCF"

# Verify results
if [ $(zgrep -v "^#" "$OUTPUT_VCF" | wc -l) -gt 0 ]; then
    tabix -p vcf "$OUTPUT_VCF"
    echo "Filtering completed: $OUTPUT_VCF"
    echo "Variants kept: $(zgrep -v "^#" "$OUTPUT_VCF" | wc -l)"
    
    # Verify sizes in the resulting file
    echo "Checking sizes of kept variants:"
    zcat "$OUTPUT_VCF" | grep -v "^#" | head -n 5 | awk '
{
    if ($8 ~ /END=[0-9]+/) {
        split($8, a, /END=/);
        split(a[2], b, /;/);
        end = b[1];
        size = end - $2 + 1;
        method = "END-POS+1";
    } else {
        ref_len = length($4);
        alt_len = length($5);
        size = (alt_len > ref_len) ? alt_len - ref_len : ref_len - alt_len;
        method = "REF-ALT";
    }
    print $1 ":" $2, $4 ">" $5, "Size:", size, "Method:", method;
}
'
else
    echo "Warning: No variants found meeting the criteria"
    echo "File created: $OUTPUT_VCF (empty)"
fi
