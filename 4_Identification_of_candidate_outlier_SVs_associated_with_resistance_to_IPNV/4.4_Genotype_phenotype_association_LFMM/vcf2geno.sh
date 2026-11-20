#!/bin/bash
# ============================================================
# vcf2geno.sh — Converts VCF (SNPs or INDELs) to .geno format
# Output format: no spaces between genotypes (e.g., 01109002)
#   - 0 = hom REF, 1 = het, 2 = hom ALT, 9 = missing
# ============================================================

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <input_file.vcf> <output_file.geno>"
    echo "Example: $0 indels_filtrados.vcf indels.geno"
    exit 1
fi

VCF="$1"
OUT="$2"

if [ ! -f "$VCF" ]; then
    echo "Error: File $VCF not found"
    exit 1
fi

echo "🔄 Processing $VCF → $OUT ..."

awk '
BEGIN { OFS = "" }

/^##/ { next }

/^#/ {
    n_samples = NF - 9
    printf "✔ File: %s (%d samples)\n", FILENAME, n_samples > "/dev/stderr"
    next
}

{
    formato = $9
    num_formato = split(formato, fmt_arr, ":")

    pos_gt = 0
    for (j = 1; j <= num_formato; j++) {
        if (fmt_arr[j] == "GT") {
            pos_gt = j
            break
        }
    }

    if (pos_gt == 0) {
        print "⚠ Warning: Line " NR " without GT, skipping..." > "/dev/stderr"
        next
    }

    linea = ""
    for (i = 10; i <= NF; i++) {
        split($i, campos, ":")
        gt = campos[pos_gt]

        if (gt == "./." || gt == ".|." || gt == ".") {
            val = 9
        } else if (gt == "0/0" || gt == "0|0") {
            val = 0
        } else if (gt == "0/1" || gt == "1/0" || gt == "0|1" || gt == "1|0") {
            val = 1
        } else if (gt == "1/1" || gt == "1|1") {
            val = 2
        } else {
            if (index(gt, "/")) sep = "/"; else if (index(gt, "|")) sep = "|"; else sep = ""
            if (sep == "") {
                val = 9
            } else {
                split(gt, alelos, sep)
                a1 = alelos[1]; a2 = alelos[2]
                if (a1 == "." || a2 == ".") {
                    val = 9
                } else if (a1 == "0" && a2 == "0") {
                    val = 0
                } else if (a1 == "0" || a2 == "0") {
                    val = 1
                } else if (a1 == a2) {
                    val = 2
                } else {
                    val = 1
                }
            }
        }

        # 👇 Direct concatenation, NO spaces
        linea = linea val
    }
    print linea
}
' "$VCF" > "$OUT"

NLOCI=$(wc -l < "$OUT")
NIND=$(awk '{print length; exit}' < "$OUT")
echo "✅ Conversion completed: $OUT"
echo "   📊 Loci:    $NLOCI"
echo "   🧬 Samples: $NIND"

# Show first 3 lines as example
echo ""
echo "📄 First 3 lines of the file:"
head -3 "$OUT"
