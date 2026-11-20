#!/bin/bash

# Input compressed VCF file
INPUT_VCF="28_gatk_raw_filter_INDEL_PASS_SVTYPE_NC_SIZE_BI.vcf.gz"

# Output file for variant sizes
OUTPUT_TSV="28_variant_sizes_SIZE.tsv"

# Check if input file exists
if [ ! -f "$INPUT_VCF" ]; then
    echo "Error: Input file '$INPUT_VCF' not found."
    exit 1
fi

# Check if zcat is available
if ! command -v zcat &> /dev/null; then
    echo "Error: 'zcat' command not found. Please install gzip tools."
    exit 1
fi

# Calculate variant sizes and save results
zcat "$INPUT_VCF" | awk '
BEGIN {
    # Configure field separators
    FS = "\t";
    OFS = "\t";
    
    # Print output file header
    print "CHROM", "POS", "ID", "REF", "ALT", "SIZE", "SIZE_METHOD";
}

# Skip metadata lines
/^##/ { next }

# Skip column header line
/^#CHROM/ { next }

# Process each variant
{
    # Extract relevant fields
    chrom = $1;
    pos = $2;
    id = $3;
    ref = $4;
    alt = $5;
    info = $8;
    
    # Try to extract END from INFO field
    end = "";
    split(info, info_fields, ";");
    for (i in info_fields) {
        if (info_fields[i] ~ /^END=/) {
            split(info_fields[i], arr, "=");
            end = arr[2];
            break;
        }
    }
    
    # Calculate size using different methods
    size = "NA";
    method = "none";
    
    # Method 1: Use END if available
    if (end != "") {
        size = end - pos + 1;
        method = "END-POS+1";
    }
    # Method 2: For insertions (ALT > REF)
    else if (length(alt) > length(ref)) {
        size = length(alt) - length(ref);
        method = "ALT-REF";
    }
    # Method 3: For deletions (REF > ALT)
    else if (length(ref) > length(alt)) {
        size = length(ref) - length(alt);
        method = "REF-ALT";
    }
    # Method 4: For SNPs and MNPs
    else {
        size = length(ref);
        method = "REF-length";
    }
    
    # Print results
    print chrom, pos, id, ref, alt, size, method;
}
' > "$OUTPUT_TSV"

# Verify output was created
if [ -f "$OUTPUT_TSV" ]; then
    # Count variants (excluding header)
    variant_count=$(awk 'NR>1 && NF>0' "$OUTPUT_TSV" | wc -l)
    
    echo "Size calculation completed. Results saved to: $OUTPUT_TSV"
    echo "Total variants processed: $variant_count"
    
    # Show first few lines as preview
    echo -e "\nPreview of first 5 variants:"
    head -n 6 "$OUTPUT_TSV" | column -t -s $'\t'
else
    echo "Error: Output file '$OUTPUT_TSV' was not created."
    exit 1
fi
