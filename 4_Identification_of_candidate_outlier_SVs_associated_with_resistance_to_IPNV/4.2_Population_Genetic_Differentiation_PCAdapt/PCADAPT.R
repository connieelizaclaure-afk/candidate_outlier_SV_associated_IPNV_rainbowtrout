# 1. Load required libraries
#------------------------------------------------------------------------------
library(pcadapt)
library(qvalue)
library(dplyr)
library(vcfR)
library(ggplot2)
packageVersion("pcadapt") # ‘4.4.1’
packageVersion("qvalue") # ‘2.42.0’

# 2. Convert the .vcf file to the PCAdapt input format
#------------------------------------------------------------------------------
path_to_file <- "./03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/28_manta_lumpy_gatk_delly_clean_genotype80_maf01.vcf"
filename <- read.pcadapt(path_to_file, type = "vcf")

# 3. Extract locus-level information from the VCF file
#------------------------------------------------------------------------------
vcf <- read.vcfR("./03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/28_manta_lumpy_gatk_delly_clean_genotype80_maf01.vcf", verbose=FALSE)
position <- getPOS(vcf) # Object storing all variant positions
chromosome <- getCHROM(vcf) # Object storing the chromosome identifiers
locinames <- paste(vcf@fix[,"CHROM"], vcf@fix[,"POS"], sep="_")
head(locinames)
SNP <- c(1:31823) # Retain the "SNP" designation although the variants are indels, in order to avoid incompatibilities with the PCAdapt input format
locinames<- data.frame(SNP, locinames)

# 4. Select the number of principal components (K = 1:10)
#------------------------------------------------------------------------------
x <- pcadapt(input = filename, K = 5)

# 5. Compute the proportion of variance explained by each principal component
#------------------------------------------------------------------------------
png(file = "G:/Mi unidad/Doctorado/CLAURE_Eliza_Tesis_doctorado/03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/screeplot.png", 
    width=3000, height=2500, units="px", res=350)
plot ( x , option  =  "screeplot")+ theme_classic()+scale_x_continuous(breaks = seq(0,10, by = 1))

dev.off ()

# 6. Score plot: projections of individuals onto the specified principal components
#------------------------------------------------------------------------------
poplist.names  <-  c ( rep ( "susceptible" , 14 ), rep ( "resistant" , 14 ))
print(poplist.names)

# PC1–PC2
png(file = "G:/Mi unidad/Doctorado/CLAURE_Eliza_Tesis_doctorado/03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/PC1-2.png", 
    width=3000, height=2500, units="px", res=350)
plot ( x , option  =  "scores" , pop  =  poplist.names )+ theme_classic()
dev.off ()

# PC1–PC3
png(file = "G:/Mi unidad/Doctorado/CLAURE_Eliza_Tesis_doctorado/03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/PC1-3.png", 
    width=3000, height=2500, units="px", res=350)
plot ( x , option  =  "scores" , i  =  1 , j  =  3 , pop  =  poplist.names )+ theme_classic()
dev.off ()

# PC2–PC3
png(file = "G:/Mi unidad/Doctorado/CLAURE_Eliza_Tesis_doctorado/03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/PC2-3.png", 
    width=3000, height=2500, units="px", res=350)
plot ( x , option  =  "scores" , i  =  2 , j  =  3 , pop  =  poplist.names )+ theme_classic()
dev.off ()

# 7. Computation of the PCA-based test statistic
#------------------------------------------------------------------------------
# Note: the test statistic is based on the z-scores obtained by regressing each indel on the K principal 
#       components. The statistic used to detect atypical indels is the Mahalanobis distance, a 
#       multidimensional approach that measures how far a point lies from the mean.

x <- pcadapt(filename, K = 2)
summary(x)

# scores: (n,K) matrix containing the projections of individuals onto each principal component.
# singular.values: vector containing the ordered square roots of the proportion of variance explained by each PC.
# loadings: (L,K) matrix containing the correlations between each genetic marker and each PC.
# zscores: (L,K) matrix containing the z-scores.
# af: vector of length L containing the allelic frequencies of the derived alleles, where 0 assumes genotypes are coded as homozygous for the reference allele.
# maf: vector of length L containing the minor allelic frequencies.
# chi2.stat: vector of length L containing the rescaled statistics stat/gif, which follow a chi-square distribution with K degrees of freedom.
# gif: numeric value corresponding to the genomic inflation factor estimated from stat.
# pvalues: vector containing L p-values.
# pass: list of indices of the indels retained after the exclusion imposed by the minor allelic frequency threshold.

# 8. Manhattan plot
# ------------------------------------------------------------------------------
png(file = "G:/Mi unidad/Doctorado/CLAURE_Eliza_Tesis_doctorado/03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/MANHATTAN.png", 
    width=3000, height=2500, units="px", res=350)
plot ( x , option  =  "manhattan")+theme_classic()
dev.off()

# 9. Quantile–quantile (Q–Q) plot
# ------------------------------------------------------------------------------
png(file = "G:/Mi unidad/Doctorado/CLAURE_Eliza_Tesis_doctorado/03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/QQplot.png", 
    width=2500, height=2500, units="px", res=350)
plot(x,option="qqplot",threshold=0.1)+theme_classic()
dev.off()

# 10. Histogram of p-values
# ------------------------------------------------------------------------------
png(file = "G:/Mi unidad/Doctorado/CLAURE_Eliza_Tesis_doctorado/03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/hist_p_value.png", 
    width=2500, height=2500, units="px", res=350)
hist(x$pvalues, xlab = "p-values", main = NULL, breaks = 500, col = "orange")
dev.off()

# 11. Distribution of the test statistic
# ------------------------------------------------------------------------------
png(file = "G:/Mi unidad/Doctorado/CLAURE_Eliza_Tesis_doctorado/03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/stat_distribution.png", 
    width=3500, height=2500, units="px", res=350)
plot(x, option = "stat.distribution")+theme_classic()
dev.off()

# 12. Outlier detection
#--------------------------------------------------------------------------------
# 12.1 Q-value function
qval <- qvalue(x$pvalues)$qvalues
alpha <- 0.05 # Define the false discovery rate (FDR)
outliers <- which(qval < alpha)
outliers
length(outliers) # 440
indel_pc <- get.pc(x,outliers) # Identify the PCs associated with the outliers
OUTLIERS <- merge(locinames,indel_pc) # Merge with locinames (CHROM_POSITION)
write.table(OUTLIERS, "./03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/outliers_alpha0.05txt", quote=FALSE, sep="\t", row.names=FALSE)

# 12.2. Benjamini-Hochberg procedure
padj <- p.adjust(x$pvalues,method="BH")
padj
alpha <- 0.05
outliersBH <- which(padj < alpha)
length(outliersBH)#440
indel_pcBH <- get.pc(x,outliersBH) # Identify the PCs associated with the outliers
OUTLIERS_BH <- merge(locinames,indel_pcBH)

write.table(OUTLIERS_BH, "03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/outliers_BH.txt", quote=FALSE, sep="\t", row.names=FALSE)
write.table(OUTLIERS_BH$locinames, "03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/WHITELIST_PCADAPT_outliers_BH.txt", quote=FALSE, sep="\t", row.names=FALSE)

# 12.3 Bonferroni correction (more stringent)
padj <- p.adjust(x$pvalues,method="bonferroni")
alpha <- 0.05
outliersBF <- which(padj < alpha)
length(outliersBF) #102
indel_pcBF <- get.pc(x,outliersBF)
OUTLIERS_BF <- merge(locinames,indel_pcBF)
write.table(OUTLIERS_BF, "03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/outliers_BF.txt", quote=FALSE, sep="\t", row.names=FALSE)

# 13. Outlier visualization
#--------------------------------------------------------------------------------
# 13.1. Build a data frame with the q-value estimates
q_values<-data.frame(qval)
q_values$SNP <-c(1:31823) # Append the total number of indels (retained in the SNP column) to facilitate plotting

# 13.2. Add a column discriminating outlier loci from neutral loci
q_values$SELECTION <- ifelse(q_values$qval<=0.05,"diversifying","neutral") 
q_values$SELECTION<- factor(q_values$SELECTION)
levels(q_values$SELECTION)

# 13.3. Transform the q-values into log10(q-value)
q_values$LOG10_Q <- -log10(q_values$qval) # Creates the log10(q-value) column
plot(q_values$SNP,q_values$LOG10_Q)

# 13.4. Merge both data frames by the SNP column
pcadapt_loci <- merge(q_values, locinames, by = "SNP", all = TRUE)

# 13.5. Include the size of each chromosome
out.dat_chrom <- pcadapt_loci %>%
  mutate(
    CHROM = sub("_(\\d+)$", "", locinames),
    POS   = as.numeric(sub(".*_(\\d+)$", "\\1", locinames)))

out.dat_chrom$POS <- as.numeric(out.dat_chrom$POS) # Convert POS to numeric (optional, recommended)

head(out.dat_chrom)# Inspect the result

o_mykiss <- read_delim("G:/Mi unidad/Doctorado/Tesis de doctorado/Metodologia/Deteccion de SV trucha arcoiris/datos/oncorhynchus_mykiss.txt")

reemplazo <- setNames(as.character(o_mykiss$CHROM), o_mykiss$RefSeq)

out.dat_chrom$CHROM <- reemplazo[out.dat_chrom$CHROM]

# 13.6. Include chromosomal information (sizes and cumulative positions) ──
chr_sizes <- out.dat_chrom %>%
  group_by(CHROM) %>%
  summarise(chr_size = max(POS, na.rm = TRUE), .groups = "drop")

chr_order <- str_sort(unique(chr_sizes$CHROM), numeric = TRUE)# Chromosome ordering (e.g., NC_048565.1, NC_048566.1, ...)

chr_sizes <- chr_sizes %>%
  mutate(CHROM = factor(CHROM, levels = chr_order)) %>%
  arrange(CHROM) %>%
  mutate(
    chr_start  = cumsum(lag(chr_size, default = 0)),
    chr_center = chr_start + chr_size / 2)

out.dat_chrom <- out.dat_chrom %>%
  mutate(CHROM = factor(CHROM, levels = chr_order)) %>%
  left_join(chr_sizes %>% select(CHROM, chr_start), by = "CHROM") %>%
  mutate(pos_cum = chr_start + POS)

chrom_levels <- c(as.character(c(1:28, 30:32)), "Y")

out.dat_chrom <- out.dat_chrom %>%
  mutate(CHROM = factor(CHROM, levels = chrom_levels))

# 14. Render the Manhattan plot
#------------------------------------------------------------------------------
p <- ggplot() +
  
  # Neutral loci (background) - alternating colors by chromosome
  geom_point(data = filter(out.dat_chrom, SELECTION == "neutral") %>%
               mutate(chr_par = as.numeric(CHROM) %% 2),
             aes(x = pos_cum, y = LOG10_Q, color = factor(chr_par)),
             size = 0.6, alpha = 0.5, show.legend = FALSE) +
  
  # Divergent selection
  geom_point(data = filter(out.dat_chrom, SELECTION == "diversifying"),
             aes(x = pos_cum, y = LOG10_Q),
             color = "#2F496E", size = 1.8, alpha = 0.9) +
  
  # Colors for neutral loci (alternated)
  scale_color_manual(values = c("#756867", "#D5D6D2")) +
  
  # X-axis with chromosome names (1-28, 30-32, Y)
  scale_x_continuous(
    breaks = chr_sizes$chr_center,
    labels = chr_sizes$CHROM,
    expand = c(0, 0)
  ) +
  
  # Y-axis with no padding before 0
  scale_y_continuous(
    labels = function(x) trimws(format(x, scientific = FALSE)),
    expand = c(0, 0)
  ) +
  
  labs(x = "Chromosome", y = expression(-log[10]("q-value"))) +
  theme_bw() +
  theme(
    legend.position     = "none",
    axis.text.x         = element_text(angle = 90, vjust = 0.5, size = 12),
    axis.text.y         = element_text(hjust = 1, size = 12),
    axis.title.x        = element_text(size = 14),  # Size of the X-axis title
    axis.title.y        = element_text(size = 14),  # Size of the Y-axis title
    panel.grid.major    = element_blank(),
    panel.grid.minor    = element_blank()
  )

print(p)


# Save output
ggsave("./03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/pcadapt_chrom.svg", plot = p, width = 10, height = 5, dpi = 300)
ggsave("./03_DATOS_Y_METADATOS/14_Diferenciacion_genetica_poblacional_pcadapt/pcadapt_chrom.png", plot = p, width = 10, height = 5, dpi = 300)
