# 1. Load the required libraries
#-------------------------------------------------------------------------------
library(stringr)
library(data.table)
library(dplyr)
library(readr)
library(biomaRt)


# 2. Import the structural variants exclusive to the M and S groups
#-------------------------------------------------------------------------------
o_mykiss <- read_delim("./03_DATOS_Y_METADATOS/19_Anotacion_funcional_ensembl/oncorhynchus_mykiss.txt")
chrom_pgd_gea <- read_delim("./03_DATOS_Y_METADATOS/19_Anotacion_funcional_ensembl/CHROM_POS_pgd_gea.txt")

# 2.1. Add an identifier column
chrom_pgd_gea <- chrom_pgd_gea  %>%
  mutate(CHROM_POS_ID = paste(CHROM, POS, sep = "_"))

# 2.2. Replace RefSeq chromosome accessions (e.g., NC_048565.1) with numeric chromosome labels
reemplazo <- setNames(as.character(o_mykiss$CHROM), o_mykiss$RefSeq)
chrom_pgd_gea$CHROM <- reemplazo[chrom_pgd_gea$CHROM]

# 3. Define flanking windows extending 10,000 bp upstream and downstream of each position
#-------------------------------------------------------------------------------
chrom_pgd_gea %>%
  mutate(
    start = POS - 10000,
    end = POS + 10000,
    rango = paste0(CHROM, ":", start, ":", end))-> PGD_GEA

summary(PGD_GEA$rango)

PGD_GEA$rango -> lista_regiones_PGD_GEA

lista_regiones_PGD_GEA

# 4. Gene identification through Ensembl
#-------------------------------------------------------------------------------

# 4.1. Configure the connection timeout threshold
options(timeout = 300)

# 4.2. Establish a direct connection to the main Ensembl site
ensembl <- useEnsembl(
  biomart = "ensembl",
  host = "https://beta.ensembl.org")

# 4.3. Search for the available datasets (using the 'ensembl' object connected to the main host)
searchDatasets(mart = ensembl, pattern = "mykiss")
#         dataset                          description        version
#  132 omykiss_gene_ensembl Rainbow trout genes (USDA_OmykA_1.1) USDA_OmykA_1.

# 4.4. Load the target dataset
mykiss_ensembl <- useEnsembl(
  biomart = "ensembl",
  dataset = "omykiss_gene_ensembl",
  host = "https://beta.ensembl.org")

# 4.5. Verify that the connection was established correctly
print(mykiss_ensembl)

# 5. Retrieve annotation information for candidate genes
#-------------------------------------------------------------------------------
ensembl <- useMart("ENSEMBL_MART_ENSEMBL")             # loading genes database
ensembl <- useDataset("omykiss_gene_ensembl", ensembl)

filter <- "chromosomal_region"
attributes <- c("ensembl_gene_id", 
                "external_gene_name", 
                "description",
                "chromosome_name", 
                "start_position", 
                "end_position")
attributes

listAttributes(mart = ensembl) # Inspect all attribute types that can be returned for each gene.

#searchFilters(mart = ensembl, pattern = "NP")

#  6. Query the BioMart resource and store the results
#-------------------------------------------------------------------------------
results_pgd_gea <- getBM(attributes = attributes,
                         filters = filter,
                         values = lista_regiones_PGD_GEA,
                         mart = mykiss_ensembl)
head(results_pgd_gea)
results_pgd_gea
results_pgd_gea[["ensembl_gene_id"]]->genes_ensembl_PGD_GEA
genes_ensembl_PGD_GEA

write.table(results_pgd_gea,"./03_DATOS_Y_METADATOS/19_Anotacion_funcional_ensembl/results_gene_PGD_GEA.txt", quote = F,row.names = F, col.names = T)
write.table(genes_ensembl_PGD_GEA,"./03_DATOS_Y_METADATOS/19_Anotacion_funcional_ensembl/ensembl_gene_PGD_GEA.txt", quote = F,row.names = F, col.names = F)
