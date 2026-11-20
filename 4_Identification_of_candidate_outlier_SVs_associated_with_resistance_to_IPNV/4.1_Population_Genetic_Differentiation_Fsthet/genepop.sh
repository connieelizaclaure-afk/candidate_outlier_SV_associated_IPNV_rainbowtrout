#!/bin/bash
#===============================================================================
# genepop.sh - Converts VCF to Genepop format (.txt)
#
# Output format (3 digits per allele):
#   NC_048593.1_47627763
#   NC_048593.1_47642135
#   NC_048593.1_47670014
#   Pop
#   M0018 ,  001002 001001 001001 001002 ...
#   M0675 ,  002002 001001 001001 002002 ...
#
# Encoding:
#   0/0 → 001001 | 0/1 → 001002 | 1/1 → 002002 | ./. → 000000
#
# Usage: ./genepop.sh <input.vcf> [output.txt]
# Dependencies: awk
#===============================================================================

set -euo pipefail

# --- Configuration ---
VCF="${1:-}"
OUT="${2:-}"

if [[ -z "$VCF" ]]; then
    echo "Error: No VCF file specified."
    echo "Usage: $0 <input.vcf> [output.txt]"
    exit 1
fi

if [[ ! -f "$VCF" ]]; then
    echo "Error: File '$VCF' does not exist."
    exit 1
fi

if [[ -z "$OUT" ]]; then
    OUT="${VCF%.vcf}.txt"
    OUT="${OUT%.vcf.gz}.txt"
fi

echo "▶ Reading: $VCF"
echo "▶ Writing: $OUT"

# --- Processing with awk ---
awk '
BEGIN {
    FS = "\t"
    n_samples = 0
    n_loci = 0
}

# Skip metadata
/^##/ { next }

# Get sample names
/^#CHROM/ {
    for (i = 10; i <= NF; i++) {
        samples[++n_samples] = $i
    }
    next
}

# Process variants
!/^#/ {
    n_loci++
    loci[n_loci] = $1 "_" $2   # CHROM_POS as locus identifier

    # Locate GT column in FORMAT
    split($9, fmt, ":")
    gt_col = 0
    for (i = 1; i <= length(fmt); i++) {
        if (fmt[i] == "GT") {
            gt_col = i
            break
        }
    }
    if (gt_col == 0) {
        print "Error: GT not found in FORMAT (line " NR ")." > "/dev/stderr"
        exit 1
    }

    # Extract genotypes from each sample
    for (s = 1; s <= n_samples; s++) {
        split($(s + 9), sample_fields, ":")
        gt = sample_fields[gt_col]

        # Normalize: phased | → /
        gsub(/[|]/, "/", gt)
        split(gt, al, "/")

        # Allele 1 (3 digits)
        if (al[1] == "." || al[1] == "" || gt == "./.") {
            a1 = "000"
        } else {
            a1 = sprintf("%03d", al[1] + 1)
        }

        # Allele 2 (3 digits)
        if (al[2] == "." || al[2] == "" || gt == "./.") {
            a2 = "000"
        } else {
            a2 = sprintf("%03d", al[2] + 1)
        }

        gts[s, n_loci] = a1 a2
    }
}

END {
    # === WRITE GENEPOP FILE ===

    # 1. Loci: one per line
    for (l = 1; l <= n_loci; l++) {
        print loci[l] > "'"$OUT"'"
    }

    # 2. Population marker
    print "Pop" > "'"$OUT"'"

    # 3. Individuals: "NAME ,  GENOTYPES"
    for (s = 1; s <= n_samples; s++) {
        line = samples[s] " ,  "
        for (l = 1; l <= n_loci; l++) {
            if (l > 1) line = line " "
            line = line gts[s, l]
        }
        print line > "'"$OUT"'"
    }

    printf "✅ Completed: %d loci, %d individuals\n", n_loci, n_samples
}
' "$VCF"

echo "📄 File generated: $OUT"
