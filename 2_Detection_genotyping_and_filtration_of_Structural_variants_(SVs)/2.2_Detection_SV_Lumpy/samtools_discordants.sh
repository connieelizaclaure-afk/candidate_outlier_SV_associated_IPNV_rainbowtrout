#!/bin/bash

# List of all samples
samples=(
  "M0018" "M0675" "M0679" "M0696" "M0943"
  "M0993" "M1010" "M1011" "M1013" "M1015"
  "M1017" "M1021" "M1043" "M1048" "S0080"
  "S0093" "S0098" "S0107" "S0116" "S0130"
  "S0159" "S0168" "S0169" "S0185" "S0343"
  "S0350" "S0368" "S0373"
)

# Process all samples
for sample in "${samples[@]}"; do
  echo "Processing ${sample}..."
  
  # Execute samtools command
  samtools view -b -F 1294 "${sample}".sorted.bam > "${sample}".discordants.unsorted.bam
  
  # Check success
  if [ $? -eq 0 ]; then
    echo "-> ${sample} completed successfully"
  else
    echo "!! Error processing ${sample}"
  fi
  
  echo "---------------------------------"
done

echo "Process completed for all samples!"
