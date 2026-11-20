# Functional Annotation using Ensembl

Ensembl annotates genes, calculates multiple alignments, predicts regulatory function, and collects disease data.

---

## 1. Extract Chromosome and Position Information

Before gene identification, the chromosome and position data are extracted from the filtered VCF file.

```bash
# Provide execution permissions
chmod +x extract_chrom_pos.sh

# Execute extraction script
./extract_chrom_pos.sh ./jasmine_28_5M/28_manta_lumpy_gatk_delly_clean_genotype80_maf01_pgd_gea.vcf > ./jasmine_28_5M/CHROM_POS_pgd_gea.txt
```

## 2. Identify Genes using Ensembl

The final identification of genes associated with the structural variants is performed using an R-based integration with Ensembl databases.

```bash
# Execute Ensembl annotation script
Rscript ensembl.R
```

---

**Note:** Ensure that the input VCF path matches the results obtained from the population genomics and genotype-phenotype association modules (PGD/GEA).
