# 1. Integrate eigenvector, eigenvalue, and phenotype information into data frames
#--------------------------------------------------------------------------------
library(ggplot2)

# 1.1. Read eigenvector coordinates
pca_SV_FILT <- read.table("./03_DATOS_Y_METADATOS/12_PCA/pca_SV_filter.eigenvec", header=FALSE)
pca_DEL_FILT <- read.table("./03_DATOS_Y_METADATOS/12_PCA/pca_DEP_filter.eigenvec", header=FALSE)
pca_INS_FILT <- read.table("./03_DATOS_Y_METADATOS/12_PCA/pca_INS_filter.eigenvec", header=FALSE)

# 1.2. Assign column names to sample identifiers
colnames(pca_SV_FILT)[1:2] <- c("FID", "IID")
colnames(pca_DEL_FILT)[1:2] <- c("FID", "IID")
colnames(pca_INS_FILT)[1:2] <- c("FID", "IID")

# 1.3. Read eigenvalues and compute variance explained
eigenvals_SV_FILT <- scan("./03_DATOS_Y_METADATOS/12_PCA/pca_SV_filter.eigenval", quiet=TRUE)
var_exp_SV_FILT <- eigenvals_SV_FILT / sum(eigenvals_SV_FILT) * 100

eigenvals_DEL_FILT <- scan("./03_DATOS_Y_METADATOS/12_PCA/pca_DEP_filter.eigenval", quiet=TRUE)
var_exp_DEL_FILT <- eigenvals_DEL_FILT / sum(eigenvals_DEL_FILT) * 100

eigenvals_INS_FILT <- scan("./03_DATOS_Y_METADATOS/12_PCA/pca_INS_filter.eigenval", quiet=TRUE)
var_exp_INS_FILT <- eigenvals_INS_FILT / sum(eigenvals_INS_FILT) * 100

# 1.4. Define phenotypic groups
susceptible <- c("M0018", "M0675", "M0679", "M0696", "M0943", "M0993","M1010", "M1011", "M1013", "M1015", "M1017", "M1021", "M1043", "M1048")
resistant <- c("S0080", "S0093", "S0098", "S0107", "S0116", "S0130", "S0159","S0168", "S0169", "S0185", "S0343", "S0350", "S0368", "S0373")

# 1.5. Assign phenotype column to each data frame iteratively
nombres_dataframes <- c( "pca_SV_FILT", "pca_DEL_FILT", "pca_INS_FILT")

for (nombre in nombres_dataframes) {
  if (exists(nombre)) {
    df <- get(nombre)
    df$Phenotype <- ifelse(df$IID %in% susceptible, "susceptible", "resistant")
    assign(nombre, df, envir = .GlobalEnv)
  } else {
    warning(paste("Data frame", nombre, "does not exist"))
  }
}

# 2. Principal Component Analysis (PCA) visualization
#--------------------------------------------------------------------------------

# 2.1. PCA for all structural variants (insertions and deletions)

pca_SV_FILT_g <- ggplot(pca_SV_FILT, aes(x=V3, y=V4, color=Phenotype, fill=Phenotype)) +
  # Scatter points for all groups
  geom_point(size=3.5, alpha=0.8) +
  # Point labels (sample identifiers)
  geom_text(data = pca_SV_FILT, aes(label=IID), 
            vjust=-0.8, size=1.5, alpha=0.8, show.legend = FALSE) +
  # Custom color palette
  scale_color_manual(
    values = c("susceptible" = "#A11F0C", 
               "resistant" = "#80BD9E")
  ) +
  scale_fill_manual(
    values = c("susceptible" = "#A11F0C", 
               "resistant" = "#80BD9E")
  ) +
  labs(
    x = paste0("PC1 (", round(var_exp_SV_FILT[1], 2), "%)"),
    y = paste0("PC2 (", round(var_exp_SV_FILT[2], 2), "%)"),
    color = "Phenotype",
    fill = "Phenotype"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust=0.5, face="bold", size=16),
    axis.title = element_text(size=10),
    legend.position = "right",
    legend.title = element_text(face="bold")
  )

print(pca_SV_FILT_g)

# Save output
ggsave("./03_DATOS_Y_METADATOS/12_PCA/pca_SV_FILT.svg", plot = pca_SV_FILT_g, width = 20, height = 20, dpi = 800)
ggsave("./03_DATOS_Y_METADATOS/12_PCA/pca_SV_FILT.png", plot = pca_SV_FILT_g, width = 5, height = 5, dpi = 300)

# 2.2. PCA for deletions (DEL)

pca_DEL_FILT_g <- ggplot(pca_DEL_FILT, aes(x=V3, y=V4, color=Phenotype, fill=Phenotype)) +
  # Scatter points for all groups
  geom_point(size=3.5, alpha=0.8) +
  # Point labels (sample identifiers)
  geom_text(data = pca_DEL_FILT, aes(label=IID), 
            vjust=-0.8, size=1.5, alpha=0.8, show.legend = FALSE) +
  # Custom color palette
  scale_color_manual(
    values = c("susceptible" = "#A11F0C", 
               "resistant" = "#80BD9E")
  ) +
  scale_fill_manual(
    values = c("susceptible" = "#A11F0C", 
               "resistant" = "#80BD9E")
  ) +
  labs(
    x = paste0("PC1 (", round(var_exp_DEL_FILT[1], 2), "%)"),
    y = paste0("PC2 (", round(var_exp_DEL_FILT[2], 2), "%)"),
    color = "Phenotype",
    fill = "Phenotype"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust=0.5, face="bold", size=16),
    axis.title = element_text(size=10),
    legend.position = "right",
    legend.title = element_text(face="bold")
  )

print(pca_DEL_FILT_g)

# Save output
ggsave("./03_DATOS_Y_METADATOS/12_PCA/pca_DEL_FILT.svg", plot = pca_DEL_FILT_g, width = 20, height = 20, dpi = 800)
ggsave("./03_DATOS_Y_METADATOS/12_PCA/pca_DEL_FILT.png", plot = pca_DEL_FILT_g, width = 5, height = 5, dpi = 300)

# 2.3. PCA for insertions (INS)

pca_INS_FILT_g <- ggplot(pca_INS_FILT, aes(x=V3, y=V4, color=Phenotype, fill=Phenotype)) +
  # Scatter points for all groups
  geom_point(size=3.5, alpha=0.8) +
  # Point labels (sample identifiers)
  geom_text(data = pca_INS_FILT, aes(label=IID), 
            vjust=-0.8, size=1.5, alpha=0.8, show.legend = FALSE) +
  # Custom color palette
  scale_color_manual(
    values = c("susceptible" = "#A11F0C", 
               "resistant" = "#80BD9E")
  ) +
  scale_fill_manual(
    values = c("susceptible" = "#A11F0C", 
               "resistant" = "#80BD9E")
  ) +
  labs(
    x = paste0("PC1 (", round(var_exp_INS_FILT[1], 2), "%)"),
    y = paste0("PC2 (", round(var_exp_INS_FILT, 2), "%)"),
    color = "Phenotype",
    fill = "Phenotype"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust=0.5, face="bold", size=16),
    axis.title = element_text(size=10),
    legend.position = "right",
    legend.title = element_text(face="bold")
  )

print(pca_INS_FILT_g)

# Save output
ggsave("./03_DATOS_Y_METADATOS/12_PCA/pca_INS_FILT.svg", plot = pca_INS_FILT_g, width = 20, height = 20, dpi = 800)
ggsave("./03_DATOS_Y_METADATOS/12_PCA/pca_INS_FILT.png", plot = pca_INS_FILT_g, width = 5, height = 5, dpi = 300)

