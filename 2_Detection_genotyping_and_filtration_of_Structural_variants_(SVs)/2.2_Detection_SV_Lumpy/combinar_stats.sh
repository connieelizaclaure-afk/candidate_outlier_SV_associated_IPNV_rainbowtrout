#!/bin/bash

# Output file
output_file="lumpy_28_meanstdev.txt"

# File header
echo -e "Sample\tMean\tStdev" > "$output_file"

# File list (adjust names if there are errors)
files=(
  "Mean_stdev_M0018.txt"   "Mean_stdev_M0675.txt"   "Mean_stdev_M0679.txt"
  "Mean_stdev_M0696.txt"   "Mean_stdev_M0943.txt"   "Mean_stdev_M0993.txt"
  "Mean_stdev_M1010.txt"   "Mean_stdev_M1011.txt"   "Mean_stdev_M1013.txt"
  "Mean_stdev_M1015.txt"   "Mean_stdev_M1017.txt"   "Mean_stdev_M1021.txt"
  "Mean_stdev_M1043.txt"   "Mean_stdev_M1048.txt"   "Mean_stdev_S0080.txt"
  "Mean_stdev_S0093.txt"   "Mean_stdev_S0098.txt"   "Mean_stdev_S0107.txt"
  "Mean_stdev_S0116.txt"   "Mean_stdev_S0130.txt"   "Mean_stdev_S0159.txt"
  "Mean_stdev_S0168.txt"   "Mean_stdev_S0169.txt"   "Mean_stdev_S0185.txt"
  "Mean_stdev_S0343.txt"   "Mean_stdev_S0350.txt"   "Mean_stdev_S0368.txt"
  "Mean_stdev_S0373.txt"
)

# Process each file
for file in "${files[@]}"; do
  # Extract sample name
  sample=$(basename "$file" .txt | cut -d'_' -f3)

  # Extract mean and stdev values
  read -r mean stdev <<< $(awk '{print $1,$2}' "$file" | sed 's/mean://;s/stdev://')

  # Write to combined file
  echo -e "$sample\t$mean\t$stdev" >> "$output_file"
done

echo "Combined file generated: $output_file"
