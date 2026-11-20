#!/bin/bash

# Sample list (28 total)
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
  # Execute the command
  samtools view "./bam/${sample}.sorted.bam" \
    | tail -n+100000 \
    | ./softwares/lumpy-sv/scripts/pairend_distro.py \
        -r 150 \
        -X 4 \
        -N 270000000 \
        -o "./lumpy/${sample}.lib1.histo" 2>&1 \
    | grep -E 'mean:|stdev:' \
    >> "Mean_stdev_${sample}.txt"
done
