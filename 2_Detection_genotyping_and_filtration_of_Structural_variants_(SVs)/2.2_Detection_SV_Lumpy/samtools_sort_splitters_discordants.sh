#!/bin/bash

# Script to sort discordant and splitter files for all samples
# samtools_sort_splitters_discordants.sh

# List of samples
samples=(
  "M0018" "M0675" "M0679" "M0696" "M0943"
  "M0993" "M1010" "M1011" "M1013" "M1015"
  "M1017" "M1021" "M1043" "M1048" "S0080"
  "S0093" "S0098" "S0107" "S0116" "S0130"
  "S0159" "S0168" "S0169" "S0185" "S0343"
  "S0350" "S0368" "S0373"
)

# Process each sample
for sample in "${samples[@]}"; do
  echo "===== Processing $sample ====="
  
  # Sort discordants
  echo "1/2 - Sorting discordants..."
  samtools sort -@ 4 -m 2G -o "${sample}.discordants.bam" "${sample}.discordants.unsorted.bam"
  
  # Sort splitters
  echo "2/2 - Sorting splitters..."
  samtools sort -@ 4 -m 2G -o "${sample}.splitters.bam" "${sample}.splitters.unsorted.bam"
  
  echo "===================================="
done

echo "Process completed for all samples!"
