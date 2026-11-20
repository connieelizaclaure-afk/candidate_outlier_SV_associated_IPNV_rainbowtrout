#!/bin/bash

# Script: extract_vcf.sh
# Description: Extracts specific information from structural variant VCF files
# Usage: ./extract_vcf.sh input.vcf [output_file.tsv]

# Check if a file was provided
if [ $# -eq 0 ]; then
    echo "Error: No VCF file provided"
    echo "Usage: $0 input.vcf [output_file.tsv]"
    exit 1
fi

VCF_FILE="$1"
OUTPUT_FILE="${2:-sv_extracted_info.tsv}"

# Check if the file exists
if [ ! -f "$VCF_FILE" ]; then
    echo "Error: File $VCF_FILE does not exist"
    exit 1
fi

# Check dependencies
if ! command -v bcftools &> /dev/null; then
    echo "Error: bcftools is not installed"
    exit 1
fi

echo "Processing file: $VCF_FILE"
echo "Output file: $OUTPUT_FILE"

# Extract sample names
SAMPLES=$(bcftools query -l "$VCF_FILE" 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Error: Could not read samples from VCF file"
    exit 1
fi

# Create header with sample names for GT
GT_HEADER=""
for sample in $SAMPLES; do
    GT_HEADER="${GT_HEADER}\t${sample}_GT"
done

# Output file header
echo -e "CHROM\tPOS\tID\tREF\tALT\tSVTYPE\tSVLEN\tSUPP_VEC\tSUPP${GT_HEADER}" > "$OUTPUT_FILE"

# Function to extract INFO fields
extract_info_field() {
    local info="$1"
    local field="$2"
    echo "$info" | grep -o "${field}=[^;]*" | cut -d'=' -f2 | sed 's/^$/./'
}

# Process the VCF
bcftools view "$VCF_FILE" 2>/dev/null | while IFS=$'\t' read -r chrom pos id ref alt qual filter info format samples_line; do
    # Skip header lines
    if [[ $chrom == \#* ]]; then
        continue
    fi
    
    # Extract INFO fields
    svtype=$(extract_info_field "$info" "SVTYPE")
    svlen=$(extract_info_field "$info" "SVLEN")
    supp_vec=$(extract_info_field "$info" "SUPP_VEC")
    supp=$(extract_info_field "$info" "SUPP")
    
    # Extract genotypes for each sample
    gt_values=""
    if [ -n "$samples_line" ]; then
        # Get the GT field index in FORMAT
        format_fields=(${format//:/ })
        gt_index=-1
        for i in "${!format_fields[@]}"; do
            if [ "${format_fields[$i]}" = "GT" ]; then
                gt_index=$i
                break
            fi
        done
        
        # Extract GT for each sample
        if [ $gt_index -ne -1 ]; then
            sample_array=(${samples_line// / })
            for sample_gt in "${sample_array[@]}"; do
                gt_fields=(${sample_gt//:/ })
                if [ ${#gt_fields[@]} -gt $gt_index ]; then
                    gt_values="${gt_values}\t${gt_fields[$gt_index]}"
                else
                    gt_values="${gt_values}\t."
                fi
            done
        else
            # If no GT field, put dots for all samples
            for sample in $SAMPLES; do
                gt_values="${gt_values}\t."
            done
        fi
    else
        # If no sample information, put dots for all
        for sample in $SAMPLES; do
            gt_values="${gt_values}\t."
        done
    fi
    
    # Write line to output file
    echo -e "${chrom}\t${pos}\t${id}\t${ref}\t${alt}\t${svtype}\t${svlen}\t${supp_vec}\t${supp}${gt_values}" >> "$OUTPUT_FILE"
    
done

echo "Extraction completed. Results saved in: $OUTPUT_FILE"

# Show basic statistics
echo ""
echo "Extracted file statistics:"
echo "=========================="
count=$(tail -n +2 "$OUTPUT_FILE" | wc -l)
echo "Number of variants: $count"

if [ $count -gt 0 ]; then
    echo ""
    echo "SV type distribution:"
    tail -n +2 "$OUTPUT_FILE" | cut -f6 | sort | uniq -c | sort -nr | while read count type; do
        echo "  $type: $count"
    done
    
    echo ""
    echo "First 5 variants:"
    head -n 6 "$OUTPUT_FILE" | column -t
fi
