#!/bin/bash
# ============================================================
# geno2lfmm.sh — Converts .geno file to .lfmm format
# 
# .geno: rows = loci, columns = individuals, NO spaces
#        e.g., 011090021
#
# .lfmm: rows = individuals, columns = loci, WITH spaces
#        e.g., 0 1 1 0 9 0 0 2 1
# ============================================================

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <input_file.geno> <output_file.lfmm>"
    echo "Example: $0 28_manta_lumpy_gatk_delly_clean_genotype80_maf01.geno 28_manta_lumpy_gatk_delly_clean_genotype80_maf01.lfmm"
    exit 1
fi

GENO="$1"
LFMM="$2"

if [ ! -f "$GENO" ]; then
    echo "Error: File $GENO not found"
    exit 1
fi

echo "🔄 Transposing $GENO → $LFMM ..."

# Get dimensions
NLOCI=$(wc -l < "$GENO")
NIND=$(awk '{print length; exit}' < "$GENO")

echo "   📊 Detected dimensions: $NLOCI loci × $NIND individuals"
echo "   🔄 Transposing to: $NIND individuals × $NLOCI loci"

# Transposition using awk:
# - For each line (locus), split character by character and add
#   each value to a column vector (individual)
# - At the end, print each column as a row with spaces
awk '
{
    n_loci++
    n_ind = length($0)
    for (i = 1; i <= n_ind; i++) {
        val = substr($0, i, 1)
        matriz[i] = (i in matriz ? matriz[i] " " val : val)
    }
}
END {
    for (i = 1; i <= n_ind; i++) {
        print matriz[i]
    }
}
' "$GENO" > "$LFMM"

echo "✅ Conversion completed: $LFMM"
echo "   📊 New dimensions: $NIND rows × $NLOCI columns"

# Show first lines as example
echo ""
echo "📄 First 3 rows of .lfmm (individuals 1-10):"
head -3 "$LFMM" | awk '{for(i=1;i<=10;i++) printf "%s ", $i; print "..."}'
