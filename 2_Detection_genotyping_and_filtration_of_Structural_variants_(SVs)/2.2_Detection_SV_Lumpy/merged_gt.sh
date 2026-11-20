#!/bin/bash

# Simplified version - assumes all files exist
OUTPUT_VCF="28_lumpy_SV_merged.vcf"

echo "Merging 28 VCF files..."
bcftools merge \
  -o "$OUTPUT_VCF" \
  -O v \
  M0018_fixed.gt.vcf.gz \
  M0675_fixed.gt.vcf.gz \
  M0679_fixed.gt.vcf.gz \
  M0696_fixed.gt.vcf.gz \
  M0943_fixed.gt.vcf.gz \
  M0993_fixed.gt.vcf.gz \
  M1010_fixed.gt.vcf.gz \
  M1011_fixed.gt.vcf.gz \
  M1013_fixed.gt.vcf.gz \
  M1015_fixed.gt.vcf.gz \
  M1017_fixed.gt.vcf.gz \
  M1021_fixed.gt.vcf.gz \
  M1043_fixed.gt.vcf.gz \
  M1048_fixed.gt.vcf.gz \
  S0080_fixed.gt.vcf.gz \
  S0093_fixed.gt.vcf.gz \
  S0098_fixed.gt.vcf.gz \
  S0107_fixed.gt.vcf.gz \
  S0116_fixed.gt.vcf.gz \
  S0130_fixed.gt.vcf.gz \
  S0159_fixed.gt.vcf.gz \
  S0168_fixed.gt.vcf.gz \
  S0169_fixed.gt.vcf.gz \
  S0185_fixed.gt.vcf.gz \
  S0343_fixed.gt.vcf.gz \
  S0350_fixed.gt.vcf.gz \
  S0368_fixed.gt.vcf.gz \
  S0373_fixed.gt.vcf.gz

echo "Merge completed: $OUTPUT_VCF"
