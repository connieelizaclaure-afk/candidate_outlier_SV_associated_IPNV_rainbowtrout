import gzip

def contar_variantes_vcf(archivo_vcf_gz):
    contador = 0
    with gzip.open(archivo_vcf_gz, 'rt') as f:
        for linea in f:
            # Skip header lines (start with '##') and the column line ('#CHROM')
            if not linea.startswith('#'):
                contador += 1
    return contador

# Name of the compressed VCF file
archivo = "28_gatk_raw_filter_INDEL.vcf.gz"
num_variantes = contar_variantes_vcf(archivo)
print(f"Número total de variantes: {num_variantes}")

