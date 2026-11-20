# 1. Load required libraries
#-------------------------------------------------------------------------------
library(fsthet)
library(dplyr)
library(tibble)
library(tidyverse)
library(data.table)
library(tidyr)

# 1.1. Verify package versions
packageVersion("fsthet") # ‘1.0.1’

# 2. Import genetic data
#-------------------------------------------------------------------------------
# NOTE: When converting to the Genepop format, manually append a population number
# after each "Pop" entry (e.g., Pop 1, Pop 2); otherwise, Fst estimation will fail.
gpop <- my.read.genepop("./03_DATOS_Y_METADATOS/13_Diferenciacion_genetica_poblacional_fsthet/28_manta_lumpy_gatk_delly_clean_genotype80_maf01.txt")

# 3. Compute Fst and Ht statistics
#-------------------------------------------------------------------------------
fsts <- calc.actual.fst(gpop, fst.choice="fst") # Estimate Ht and Fst per locus
head(fsts)

#                Locus        Ht         Fst
# 1  NC_048565.1_35324 0.3750000 0.027210884
# 2 NC_048565.1_128839 0.1913265 0.000000000
# 3 NC_048565.1_169333 0.3156888 0.002020202
# 4 NC_048565.1_288818 0.1956285 0.011111111
# 5 NC_048565.1_302727 0.1815366 0.006366183
# 6 NC_048565.1_310755 0.2399686 0.001733770

write.csv(fsts, file="./03_DATOS_Y_METADATOS/13_Diferenciacion_genetica_poblacional_fsthet/Fst_locus.csv", row.names = F)

# 4. Plot the distribution of heterozygosity (Ht) versus Fst
#-------------------------------------------------------------------------------
plot(fsts$Ht, fsts$Fst, xlab="Ht", ylab="Fst", pch=19, cex=0.5) # Ht: between-population heterozygosity

# 5. Generate quantiles via bootstrap procedure
#-------------------------------------------------------------------------------
quant.out <- fst.boot(gpop, fst.choice="fst", bootstrap = FALSE)
str(quant.out)
head(quant.out[[3]][[1]])

# 5.1. Direct binning and quantile estimation
head(fsts)
bins <- make.bins(fsts)
cis <- find.quantiles(bins = bins$bins, bin.fst = bins$bin.fst)
str(cis)

# 6. Extract confidence intervals
#-------------------------------------------------------------------------------
quant.list <- ci.means(quant.out[[3]])
head(quant.list)

# 6.1. Plot confidence interval results
plotting.cis(df=fsts, ci.df=quant.list, sig.list=NULL, make.file=F)

# 7. Identify outliers
#-------------------------------------------------------------------------------
outliers <- find.outliers(fsts, boot.out=quant.out)
head(outliers)
length(outliers$Locus)
# 959

# quant.out contains the bootstrap distribution quantiles.
# For each locus, the observed Fst is compared against the upper quantile.
# If the observed Fst exceeds the 95th percentile (default threshold), the locus is flagged as an outlier.

# 8. Apply the fsthet function (direct method)
#-------------------------------------------------------------------------------
out.dat <- fsthet(gpop)

# 8.1. Summarize the number of TRUE and FALSE outlier calls
out.dat %>% count(Outlier)
#    Outlier     n
# 1      FALSE 30864
# 2      TRUE   959

plotting.cis(df=fsts, ci.df=quant.list, sig.list=outliers$Locus, ci.col="blue",
             sig.col="red", pt.pch=1, make.file=F)

# 9. Plot heterozygosity–Fst outliers
#-------------------------------------------------------------------------------
fsthet_indels <- function() {
  par(mar = c(4, 4, 1, 14))

  plot(out.dat$Ht, out.dat$Fst, xlab="Expected heterozygosity", ylab=expression("F"[ST]), pch=21, cex=0.8,
       col=ifelse(out.dat$Outlier==TRUE & out.dat$Fst>0.05, "#2988BC",
                  ifelse(out.dat$Outlier==TRUE & out.dat$Fst<0.05, "#90AFC5", "#D0D1CA")),
       bg=ifelse(out.dat$Outlier==TRUE & out.dat$Fst>0.05, "#2988BC",
                 ifelse(out.dat$Outlier==TRUE & out.dat$Fst<0.05, "#90AFC5", "#D0D1CA")))

  # Reference lines removed

  legend(0.53, 0.4,
         legend = c("divergent InDels", "balancing InDels", "neutral InDels"),
         pch = c(19, 19, 19), cex = 1.0,
         col = c("#2988BC", "#90AFC5", "#D0D1CA"),
         xpd = TRUE)
}

fsthet_indels()


png(file = "./03_DATOS_Y_METADATOS/13_Diferenciacion_genetica_poblacional_fsthet/fsthet_indel.png",
    width = 6500, height = 3500, units = "px", res = 700)
fsthet_indels()
dev.off()

svg(file = "./03_DATOS_Y_METADATOS/13_Diferenciacion_genetica_poblacional_fsthet/fsthet_indel.svg",
    width = 9.5, height = 5)
fsthet_indels()
dev.off()

# 10. Plot outliers along the genome by chromosome
#-------------------------------------------------------------------------------

o_mykiss <- read_delim("./03_DATOS_Y_METADATOS/13_Diferenciacion_genetica_poblacional_fsthet/oncorhynchus_mykiss.txt")

# 10.1. Parse the CHROM_POS field into separate chromosome and position columns
out.dat_chrom <- out.dat %>%
  mutate(
    CHROM = sub("_(\\d+)$", "", Locus),
    POS   = as.numeric(sub(".*_(\\d+)$", "\\1", Locus)))

out.dat_chrom$POS <- as.numeric(out.dat_chrom$POS) # Ensure position is numeric
head(out.dat_chrom) # Inspect result

reemplazo <- setNames(as.character(o_mykiss$CHROM), o_mykiss$RefSeq)

out.dat_chrom$CHROM <- reemplazo[out.dat_chrom$CHROM]

# 10.2. Compute cumulative positions scaled to chromosome lengths
chr_sizes <- out.dat_chrom %>%
  group_by(CHROM) %>%
  summarise(chr_size = max(POS, na.rm = TRUE), .groups = "drop")

chr_order <- str_sort(unique(chr_sizes$CHROM), numeric = TRUE)

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

# 10.3. Classify each locus by selection type (divergent / balancing / neutral)
out.dat_chrom <- out.dat_chrom %>%
  mutate(
    selection = case_when(
      Outlier == TRUE & Fst > 0.05 ~ "Divergent",
      Outlier == TRUE & Fst < 0.05 ~ "Balancing",
      TRUE ~ "Neutral" ))

chrom_levels <- c(as.character(c(1:28, 30:32)), "Y") # Chromosome ordering

out.dat_chrom <- out.dat_chrom %>%
  mutate(CHROM = factor(CHROM, levels = chrom_levels))

# 10.4. Generate Manhattan plot by chromosome
p <- ggplot() +

  # Neutral loci — alternating colors by chromosome
  geom_point(data = filter(out.dat_chrom, selection == "Neutral") %>%
               mutate(chr_par = as.numeric(CHROM) %% 2),
             aes(x = pos_cum, y = Fst, color = factor(chr_par)),
             size = 0.6, alpha = 0.5, show.legend = FALSE) +

  # Balancing selection outliers
  geom_point(data = filter(out.dat_chrom, selection == "Balancing"),
             aes(x = pos_cum, y = Fst),
             color = "#90AFC5", size = 1.8, alpha = 0.9) +

  # Divergent selection outliers
  geom_point(data = filter(out.dat_chrom, selection == "Divergent"),
             aes(x = pos_cum, y = Fst),
             color = "#2988BC", size = 1.8, alpha = 0.9) +

  # Alternating colors for neutral loci
  scale_color_manual(values = c("#756867", "#D5D6D2")) +

  # X-axis with chromosome labels (1–28, 30–32, Y)
  scale_x_continuous(
    breaks = chr_sizes$chr_center,
    labels = chr_sizes$CHROM,
    expand = c(0, 0)
  ) +

  # Y-axis formatting
  scale_y_continuous(
    labels = function(x) trimws(format(x, scientific = FALSE)),
    expand = c(0, 0)
  ) +

  labs(x = "Chromosome", y = expression(F[ST])) +
  theme_bw() +
  theme(
    legend.position     = "none",
    axis.text.x         = element_text(angle = 90, vjust = 0.5, size = 12),
    axis.text.y         = element_text(hjust = 1, size = 12),
    axis.title.x        = element_text(size = 14),  # X-axis title size
    axis.title.y        = element_text(size = 14),  # Y-axis title size
    panel.grid.major    = element_blank(),
    panel.grid.minor    = element_blank()
  )

print(p)

# Save output
ggsave("./03_DATOS_Y_METADATOS/13_Diferenciacion_genetica_poblacional_fsthet/fsthet_chrom.svg", plot = p, width = 10, height = 5, dpi = 300)
ggsave("./03_DATOS_Y_METADATOS/13_Diferenciacion_genetica_poblacional_fsthet/fsthet_chrom.png", plot = p, width = 10, height = 5, dpi = 300)
