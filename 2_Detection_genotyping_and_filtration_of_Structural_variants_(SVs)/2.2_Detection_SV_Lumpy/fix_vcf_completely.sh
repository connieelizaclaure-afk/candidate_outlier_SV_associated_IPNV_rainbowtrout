#!/bin/bash

# Script to process LUMPY VCF files and fix headers

for file in *.gt.vcf.gz; do
  if [ -f "$file" ]; then
    echo "Processing: $file"
    
    # Step 1: Decompress and create a completely new VCF with correct headers
    bgzip -d -c "$file" > temp_original.vcf
    
    # Create a new VCF with minimal but correct headers
    {
      # Basic essential headers
      echo "##fileformat=VCFv4.2"
      echo "##source=LUMPY"
      echo "##contig=<ID=NC_048565.1>"
      echo "##contig=<ID=NC_001717.1>"
      
      # Extract only essential INFO and FORMAT headers from the original
      grep -E "^##(INFO|FORMAT|ALT|FILTER)=" temp_original.vcf | head -50
      
      # Column line
      grep "^#CHROM" temp_original.vcf
      
      # Extract and sort data lines
      grep -v "^#" temp_original.vcf | sort -k1,1 -k2,2n
    } > temp_fixed.vcf
    
    # Step 2: Compress the corrected file
    bgzip -c temp_fixed.vcf > "${file%.gt.vcf.gz}_fixed.gt.vcf.gz"
    
    # Step 3: Index
    tabix -p vcf "${file%.gt.vcf.gz}_fixed.gt.vcf.gz"
    
    # Verify
    if tabix -l "${file%.gt.vcf.gz}_fixed.gt.vcf.gz" > /dev/null 2>&1; then
      echo "  ✓ Success: ${file%.gt.vcf.gz}_fixed.gt.vcf.gz"
      
      # Verify that the contig is defined
      if zcat "${file%.gt.vcf.gz}_fixed.gt.vcf.gz" | grep -q "##contig=<ID=NC_048565.1>"; then
        echo "  ✓ Contig correctly defined"
      else
        echo "  ✗ Contig not found"
      fi
    else
      echo "  ✗ Error indexing"
    fi
    
    # Cleanup
    rm temp_original.vcf temp_fixed.vcf
    
  else
    echo "WARNING: $file not found"
  fi
  echo ""
done

echo "Process completed!"
