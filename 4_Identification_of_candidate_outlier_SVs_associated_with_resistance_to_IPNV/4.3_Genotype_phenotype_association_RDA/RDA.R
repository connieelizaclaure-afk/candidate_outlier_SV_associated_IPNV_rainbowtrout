# 1. Load required libraries
# ------------------------------------------------------------------------------
library(psych)    # Used to investigate correlations among predictors
library(vegan)    # Used to run RDA
library(qvalue)
library(vcfR)
library(VennDiagram)
library(tidyverse)
library(hrbrthemes)
library(tm)
library(proustr)

# 2. Obtain the individual x indel genotype matrix
#------------------------------------------------------------------------------
vcf <- read.vcfR("./03_DATOS_Y_METADATOS/16_Asociacion_genotipo_ambiente_rda/28_manta_lumpy_gatk_delly_clean_genotype80_maf01.vcf", verbose=FALSE)

# 2.1. Convert the VCF format into the indel data matrix required by RDA
geno <- extract.gt(vcf) # Matrix of genotypes, columns = individuals, rows = SNPs
position <- getPOS(vcf) # Object storing all variant positions
chromosome <- getCHROM(vcf) # Object storing the chromosome identifiers

G <- matrix(NA, nrow = nrow(geno), ncol = ncol(geno)) # Creates a matrix with columns = individuals and rows = indels

G[geno %in% c("0/0", "0|0")] <- 0
G[geno  %in% c("0/1", "1/0", "1|0", "0|1")] <- 1
G[geno %in% c("1/1", "1|1")] <- 2
table(as.vector(G))

# NOTE 1: 0 -> the individual carries no copy of the focal allele
#         1 -> the individual is heterozygous
#         2 -> the individual is homozygous for the focal allele

sum(is.na(G)) # Reports the number of missing values
# 34762
gen.imp <- apply(G, 2, function(x) replace(x, is.na(x), as.numeric(names(which.max(table(x))))))
sum(is.na(gen.imp)) # No missing values remaining

# 2.2. Retrieve the locus annotation CHROM_POS
locinames <- paste("INDEL",vcf@fix[,"CHROM"], vcf@fix[,"POS"], sep="_")
head(locinames)

# "INDEL_NC_048565.1_35324"  "INDEL_NC_048565.1_128839" "INDEL_NC_048565.1_169333" "INDEL_NC_048565.1_288818"
# "INDEL_NC_048565.1_302727" "INDEL_NC_048565.1_310755
INDELdata <- t(gen.imp) # G stores individuals in columns, whereas RDA requires them in rows

# 2.3. Display the first five indels across the first 20 individuals
head(INDELdata[,1:20])

# 3. Read the metadata table
#------------------------------------------------------------------------------
ind <- read.table("./03_DATOS_Y_METADATOS/16_Asociacion_genotipo_ambiente_rda/popmap_trout.txt", header=TRUE)
head(ind)
#      id         pop
# 1 M0018 susceptible
# 2 M0675 susceptible
# 3 M0679 susceptible
# 4 M0696 susceptible
# 5 M0943 susceptible
# 6 M0993 susceptible

# 3.1. Verify the number of individuals per population
table(ind$pop)

# resistant susceptible 
#        14          14

# 3.2. Label rows = individuals and columns = SNPs
colnames(INDELdata)<- locinames # Replace the column names with the SNP identifiers
rownames(INDELdata)<- ind$id # Replace the row names with the individual identifiers

# 4. Read and filter the environmental predictors
#-------------------------------------------------------------------------------
env <- read.csv("./03_DATOS_Y_METADATOS/16_Asociacion_genotipo_ambiente_rda/variables_RDA.csv",sep=";")
str(env) # Inspect the structure of the data frame
summary(env)
env$INDIVIDUAL <- as.character(env$INDIVIDUAL) # Individuals stored as characters (not factors)
env$ECOTYPE <- as.factor(env$ECOTYPE)

# 4.1. Confirm that the genotypic data (INDELdata) and the phenotypic data (env) are in identical order
identical(rownames(INDELdata), env[,1]) 

# 4.2. Discard highly correlated predictors, r > 0.7

pred_red <- data.frame(env$BINARY_SURVIVAL)
colnames(pred_red) <- c("BINARY_SURVIVAL")

# 5. Run the RDA
#-------------------------------------------------------------------------------
ele.rda <- rda(INDELdata ~ ., data=pred_red, scale=T)
ele.rda

# Call: rda(formula = INDELdata ~ BINARY_SURVIVAL, data = pred_red, scale = T)

# Inertia Proportion Rank
# Total         3.182e+04  1.000e+00     
# Constrained   1.177e+03  3.697e-02    1
# Unconstrained 3.064e+04  9.630e-01   26

# Inertia is correlations

# Eigenvalues for constrained axes:
#   RDA1 
# 1176.5 

# Eigenvalues for unconstrained axes:
#   PC1    PC2    PC3    PC4    PC5    PC6    PC7    PC8 
# 1543.9 1464.8 1362.6 1318.9 1304.3 1267.5 1238.4 1226.7 
# (Showing 8 of 26 unconstrained eigenvalues)

# 5.1. Compute R2
RsquareAdj(ele.rda)
# $r.squared
# [1] 0.03697315

# $adj.r.squared
# [1] -6.634881e-05

# 5.2. Variance explained by each axis
summary(eigenvals(ele.rda, model = "constrained"))

# Importance of components:
#  RDA1
# Eigenvalue            1177
# Proportion Explained     1
# Cumulative Proportion    1

# 5.3. Canonical eigenvalue diagram
screeplot(ele.rda)

# 5.4. Assess the overall importance of the constrained axes
signif.full <- anova.cca(ele.rda, parallel=getOption("mc.cores")) # Number of permutations = 999 by default
signif.full

# Permutation test for rda under reduced model
# Permutation: free
# Number of permutations: 999

# Model: rda(formula = INDELdata ~ BINARY_SURVIVAL, data = pred_red, scale = T)
# Df Variance      F Pr(>F)
# Model     1   1176.5 0.9982  0.501
# Residual 26  30644.5  

# 5.5. Evaluate the significance of each axis
signif.axis <- anova.cca(ele.rda, by="axis", parallel=getOption("mc.cores"))# computationally time-consuming step
signif.axis

# Permutation test for rda under reduced model
# Forward tests for axes
# Permutation: free
# Number of permutations: 999

# Model: rda(formula = INDELdata ~ BINARY_SURVIVAL, data = pred_red, scale = T)
#          Df Variance      F Pr(>F)
# RDA1      1   1176.5 0.9982  0.489
# Residual 26  30644.5

# 5.6. Estimate the variance inflation factors of the predictor variables
vif.cca(ele.rda)
# BINARY_SURVIVAL 
# 1 

# 6. Plot the RDA
#-------------------------------------------------------------------------------
plot(ele.rda, scaling=3)          # default is axes 1 and 2
plot(ele.rda, choices = c(1, 3), scaling=3)  # axes 1 and 3
plot(ele.rda, choices = c(2, 3), scaling=3)  # axes 1 and 3

levels(env$ECOTYPE) <- c("susceptible","resistant")
eco <- env$ECOTYPE
bg <- c("#A11F0C",
        "#80BD9E" )

# 6.1. Configure the graphic so that each phenotype is rendered in a distinct color

rda12 <- function() {
  
  par(mar = c(4, 4, 1, 8))
  
  plot(ele.rda, type = "n", xlim = c(-4, 4), ylim = c(-4, 4))
  points(ele.rda, display = "species", pch = 21, cex = 0.8,col = "#D0D1CA", bg = "#F9F9F9", scaling = 3)  # indels (species)
  points(ele.rda,display = "sites",pch = 21, cex = 0.8,col = bg[eco], bg = bg[eco],scaling = 3)  # Samples (sites)
  text(ele.rda, scaling = 3, display = "bp",col = "#ED8C72", cex = 0.7)# Predictors (bp)
  legend(4.5, 0,legend = levels(eco), pch = 19, col = bg,xpd = TRUE) # Legend
}

rda12()


png(file = "./03_DATOS_Y_METADATOS/16_Asociacion_genotipo_ambiente_rda/RDA12.png", 
    width = 4500, height = 3500, units = "px", res = 700)
rda12()
dev.off()


svg(file = "./03_DATOS_Y_METADATOS/16_Asociacion_genotipo_ambiente_rda/RDA12.svg",
    width = 6.5, height = 5, pointsize = 12)
rda12()
dev.off()

load.rda <- scores(ele.rda, choices=c(1:3), display="species")  # "species" scores for the first three axes

# 6.2. Histogram of the loadings on each RDA axis
hist(load.rda[,1], main="Loadings on RDA1")
hist(load.rda[,2], main="Loadings on RDA2")
hist(load.rda[,3], main="Loadings on RDA3") 


# 7. Detect potentially adaptive indels
#-------------------------------------------------------------------------------
outliers <- function(x,z){
  lims <- mean(x) + c(-1, 1) * z * sd(x)     # find loadings +/-z sd from mean loading     
  x[x < lims[1] | x > lims[2]] }              # locus names in these tails

cand1 <- outliers(load.rda[,1],3); cand1 # 16
cand2 <- outliers(load.rda[,2],3);cand2 # 131
cand3 <- outliers(load.rda[,3],3) # 52
ncand <- length(cand1) + length(cand2)+ length(cand3)
ncand
# 199

# 7. Organize the list of candidate outliers
cand1 <- cbind.data.frame(rep(1,times=length(cand1)), names(cand1), unname(cand1))
cand2 <- cbind.data.frame(rep(2,times=length(cand2)), names(cand2), unname(cand2))
cand3 <- cbind.data.frame(rep(3,times=length(cand3)), names(cand3), unname(cand3))

colnames(cand1) <- colnames(cand2) <- colnames(cand3) <- c("axis","INDELs","loading")

cand <- rbind(cand1, cand2, cand3)
cand$snp <- as.character(cand$INDELs)
summary(cand)

foo <- matrix(nrow=(ncand), ncol=1)  # 6 columns for 6 predictors
colnames(foo) <- c("BINARY_SURVIVAL")

for (i in 1:length(cand$INDELs)) {
  nam <- cand[i,2]
  INDEL.gen <- INDELdata[,nam]
  foo[i,] <- apply(pred_red,2,function(x) cor(x,INDEL.gen))
}

cand <- cbind.data.frame(cand,foo)  
head(cand)

# 7.2. Identify duplicated loci among the potentially adaptive outliers

length(cand$INDELs[duplicated(cand$INDELs)]) #0 
foo <- cbind(cand$axis, duplicated(cand$INDELs)) 

table(foo[foo[,1]==1,2]) # Duplicated loci on axis 1
table(foo[foo[,1]==2,2]) # Duplicated loci on axis 2
table(foo[foo[,1]==3,2]) # Duplicated loci on axis 3

cand <- cand[!duplicated(cand$INDELs),] # Remove duplicated entries

# 7.3. Assign one predictor to each outlier
for (i in 1:length(cand$snp)) {
  bar <- cand[i,]
  cand[i,6] <- names(which.max(abs(bar[5]))) # Depends on the number of variables
  cand[i,7] <- max(abs(bar[5]))              # Number of columns set according to the correlated predictors
}

colnames(cand)[6] <- "predictor"
colnames(cand)[7] <- "correlation"

table(cand$predictor) 

# BINARY_SURVIVAL 
# 199 

# 7.4. Export the list of outliers
write.table(cand, "./03_DATOS_Y_METADATOS/16_Asociacion_genotipo_ambiente_rda/outliers_RDA.txt", quote=FALSE, sep="\t", row.names=FALSE)

cand<-subset(cand, axis==1) # Retain only the first axis (the most conservative approach)
BINARY_SURVIVAL<-subset(cand, axis==1)
BINARY_SURVIVAL<-BINARY_SURVIVAL$INDELs
write.table(cand$INDELs, "./03_DATOS_Y_METADATOS/16_Asociacion_genotipo_ambiente_rda/ALL_RDA.txt", quote=FALSE, sep="\t", row.names=FALSE)

# 7.5. Build one list per environmental variable

write.table(BINARY_SURVIVAL, "./03_DATOS_Y_METADATOS/16_Asociacion_genotipo_ambiente_rda/white_list_rda_BINARY_SURVIVAL.txt", quote=FALSE, sep="\t", row.names=FALSE)

# 7.6. Map the candidate indels
sel <- cand$INDELs
env <- cand$predictor

env[env=="BINARY_SURVIVAL"] <- "#ED8C72"

# 7.7 Assign a color to each predictor
col.pred <- rownames(ele.rda$CCA$v) # pull the SNP names

for (i in 1:length(sel)) {           # color code candidate SNPs
  foo <- match(sel[i],col.pred)
  col.pred[foo] <- env[i]
}

col.pred[grep("INDEL_",col.pred)] <- '#f1eef6' # non-candidate SNPs
empty <- col.pred
empty[grep("#f1eef6",empty)] <- rgb(0,1,0, alpha=0) # transparent
col_var <- c("#ED8C72") # Defines the color of the arrows

# 8. Plot the outliers
#-------------------------------------------------------------------------------
rda_outlier12 <- function() {
  
  par(mar = c(4, 4, 1, 6))
  
  plot(ele.rda, type="n", scaling=3, xlim=c(-0.3,0.3), ylim=c(-0.3,0.3))
  points(ele.rda, display="species", pch=21, cex=1, col="#D0D1CA", bg=col.pred, scaling=3)
  points(ele.rda, display="species", pch=21, cex=1, col=empty, bg=empty, scaling=3)
  text(ele.rda, scaling=3, display="bp", col=col_var, cex=0.5)
  legend(1.55,0, legend=c("BINARY SURVIVAL"), 
         col=col_var, pch=21, cex=0.5, pt.bg=col_var,
         xpd = TRUE)# Legend
}

rda_outlier12()

png(file = "./03_DATOS_Y_METADATOS/16_Asociacion_genotipo_ambiente_rda/RDA_outlier12.png", 
    width = 4500, height = 3500, units = "px", res = 700)
rda_outlier12()
dev.off()

svg(file = "./03_DATOS_Y_METADATOS/16_Asociacion_genotipo_ambiente_rda/RDA_outlier12.svg",
    width = 6.4, height = 5, pointsize = 12)
rda_outlier12()
dev.off()
