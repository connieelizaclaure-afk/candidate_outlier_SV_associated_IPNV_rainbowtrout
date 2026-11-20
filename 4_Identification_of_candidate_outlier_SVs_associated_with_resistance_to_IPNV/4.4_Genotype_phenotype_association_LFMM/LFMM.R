# 1. Load required libraries
#------------------------------------------------------------------------------
library("LEA")
library("fields")
library("RColorBrewer")
library(qvalue)
library(vcfR)
library(VennDiagram)
library(tidyverse)
library(hrbrthemes)
library(tm)
library(proustr)
library(ggvenn)
library(UpSetR)
packageVersion("LEA")# 3.22.0

# 2. Extract locus-level information from the VCF file
#------------------------------------------------------------------------------
vcf <- read.vcfR("./03_DATOS_Y_METADATOS/15_Asociacion_genotipo_ambiente_lfmm/28_manta_lumpy_gatk_delly_clean_genotype80_maf01.vcf", verbose=FALSE)
position <- getPOS(vcf) # Object storing all variant positions
chromosome <- getCHROM(vcf) # Object storing the chromosome identifiers
locinames <- paste(vcf@fix[,"CHROM"], vcf@fix[,"POS"], sep="_") # Build the list of loci
head(locinames)
INDEL <- c(1:31823)
locinames<- data.frame(INDEL, locinames)

# 3. Generate the snmf model object
#-------------------------------------------------------------------------------
obj.snmf <- snmf("./03_DATOS_Y_METADATOS/15_Asociacion_genotipo_ambiente_lfmm/28_manta_lumpy_gatk_delly_clean_genotype80_maf01.lfmm",
                 K = 1:5,
                 entropy = T,
                 ploidy = 2,
                 project = "new")

# 3.1 Plot the cross-entropy criterion
plot(obj.snmf)

# 3.2 Ancestry composition analysis
barplot(t(Q(obj.snmf, K = 2)), col = 1:2)
barplot(t(Q(obj.snmf, K = 3)), col = 1:3)
barplot(t(Q(obj.snmf, K = 4)), col = 1:4)

# 4. Run LFMM separately for each environmental variable
#-------------------------------------------------------------------------------
# NOTE: Each environmental variable must be supplied individually in a separate .env file.
# Binary survival phenotype: susceptible = 0, resistant = 1

obj.lfmm <- lfmm("./03_DATOS_Y_METADATOS/15_Asociacion_genotipo_ambiente_lfmm/28_manta_lumpy_gatk_delly_clean_genotype80_maf01.lfmm", "./03_DATOS_Y_METADATOS/15_Asociacion_genotipo_ambiente_lfmm/survival_binary.env", K = 2, rep = 5, project="new", CPU = 8)# computationally intensive run

# 4.1. Compute the raw p-values
p <- lfmm.pvalues(obj.lfmm, K = 2)
pvalues <- p$pvalues

# 4.2. Store the z-scores from the five replicate runs in matrix zs
zs <- z.scores(obj.lfmm, K = 2,d=1)
?z.scores

# 4.3. Combine the z-scores across replicates using the median
zs.median <- apply(zs, MARGIN = 1, median)

# 4.4. Estimate the genomic inflation factor
lambda <- median(zs.median^2)/qchisq(0.5, df = 1)
lambda

# 0.2572621

# 4.5. Compute p-values from the combined z-scores corrected for inflation
adj.p.values <- pchisq(zs.median^2/lambda, df = 1, lower = FALSE)

# 4.6. Plot the histogram of p-values
hist(adj.p.values, col = "red")

# 4.7. Compute p-values from the combined z-scores with the inflation fixed at 0.55
adj.p.values <- pchisq(zs.median^2/0.55, df = 1, lower = FALSE)

# 4.8. Histogram of p-values (readjusted specification)
hist(adj.p.values, col = "green",xlab= "p-value")
plot(-log10(adj.p.values), pch = 19, col = "blue", cex = .7 )
locinames<-cbind(locinames,adj.p.values)

# 4.9. Outlier detection with FDR control: Benjamini-Hochberg procedure
L <- 31823 # L = number of loci
q <- 0.05 #FDR level q
w <- which(sort(adj.p.values) < q * (1:L)/L)
candidates.bhT <- order(adj.p.values)[w]
length(candidates.bhT) 
# 387 

# 5. Partition the indels into neutral and adaptive categories
#-------------------------------------------------------------------------------
# Data frame of adaptive loci
diversifying<-c(rep("diversifying",387)) # Number set according to the count of outliers
diversifying<-data.frame("SELECTION"=diversifying)

candidates_bht <- data.frame("INDEL"= candidates.bhT) 
OUTLIERS_BHT <- merge(locinames,candidates_bht) # Merge CHROM_position with the INDEL index
OUTLIERS_BHT <- cbind(OUTLIERS_BHT[, c(1,2,3)],diversifying)

n <- which(sort(adj.p.values) > q * (1:L)/L)
neutral.bhT <- order(adj.p.values)[n]
length(neutral.bhT) 

neutral<-c(rep("neutral",31436)) # Total number of loci minus the number of outliers
neutral<-data.frame("SELECTION"=neutral)

neutral_bht <- data.frame("INDEL"= neutral.bhT) 
NEUTRAL_BHT <- merge(locinames,neutral_bht) # Merge CHROM_position with the INDEL index
NEUTRAL_BHT <- cbind(NEUTRAL_BHT[, c(1,2,3)],neutral)

LFMM<-rbind(OUTLIERS_BHT,NEUTRAL_BHT)
LFMM$LOG10_P <- -log10(LFMM$adj.p.values) # Creates the log10(p-value) column

write.table(LFMM, "./03_DATOS_Y_METADATOS/15_Asociacion_genotipo_ambiente_lfmm/lfmm.txt", quote=FALSE, sep="\t", row.names=FALSE)
write.table(OUTLIERS_BHT$locinames, "./03_DATOS_Y_METADATOS/15_Asociacion_genotipo_ambiente_lfmm/white_list_lfmm.txt", quote=FALSE, sep="\t", row.names=FALSE)

## 5.1. FDR control: Storey's q-values (a less conservative alternative)
plot(qvalue(adj.p.values))
candidates.qvT = which(qvalue(adj.p.values, fdr = 0.05)$signif)
length(candidates.qvT) # 387

# 6. Prepare the outlier data for the Manhattan plot
#-------------------------------------------------------------------------------
# 6.1. Load the LFMM results
# Binary survival phenotype
lfmm<-read.table("./03_DATOS_Y_METADATOS/15_Asociacion_genotipo_ambiente_lfmm/lfmm.txt",header=T)
o_mykiss <- read_delim("./03_DATOS_Y_METADATOS/15_Asociacion_genotipo_ambiente_lfmm/oncorhynchus_mykiss.txt")

# 6.2. Parse the locus identifiers into chromosome and position fields
out.dat_chrom <- lfmm %>%
  mutate(
    CHROM = sub("_(\\d+)$", "", locinames),
    POS   = as.numeric(sub(".*_(\\d+)$", "\\1", locinames)))

out.dat_chrom$POS <- as.numeric(out.dat_chrom$POS)# Convert POS to numeric
head(out.dat_chrom)# Inspect the result

reemplazo <- setNames(as.character(o_mykiss$CHROM), o_mykiss$RefSeq)
out.dat_chrom$CHROM <- reemplazo[out.dat_chrom$CHROM]

# 6.3. Compile the chromosomal information (sizes and cumulative positions)
chr_sizes <- out.dat_chrom %>%
  group_by(CHROM) %>%
  summarise(chr_size = max(POS, na.rm = TRUE), .groups = "drop")

chr_order <- str_sort(unique(chr_sizes$CHROM), numeric = TRUE)# Natural ordering of chromosomes (e.g., NC_048565.1, NC_048566.1, ...)

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

# 7. Render the Manhattan plot
#-------------------------------------------------------------------------------
p <- ggplot() +
  
  # Neutral loci (background) - alternating colors by chromosome
  geom_point(data = filter(out.dat_chrom, SELECTION == "neutral") %>%
               mutate(chr_par = as.numeric(CHROM) %% 2),
             aes(x = pos_cum, y = LOG10_P, color = factor(chr_par)),
             size = 0.6, alpha = 0.5, show.legend = FALSE) +
  
  # Divergent selection
  geom_point(data = filter(out.dat_chrom, SELECTION == "diversifying"),
             aes(x = pos_cum, y = LOG10_P),
             color = "#BC6D4F", size = 1.8, alpha = 0.9) +
  
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
  
  labs(x = "Chromosome", y = expression(-log[10]("p-value"))) +
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
ggsave("./03_DATOS_Y_METADATOS/15_Asociacion_genotipo_ambiente_lfmm/manhatan_plot_lfmm.svg", plot = p, width = 10, height = 5, dpi = 800)
ggsave("./03_DATOS_Y_METADATOS/15_Asociacion_genotipo_ambiente_lfmm/manhatan_plot_lfmm.png", plot = p, width = 10, height = 5, dpi = 800)
