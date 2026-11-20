# Identification of Candidate Outlier SVs Associated with Resistance to IPNV

This directory contains the analytical workflows for identifying structural variants (SVs) WITH association with resistance to the Infectious Pancreatic Necrosis Virus (IPNV) in *Oncorhynchus mykiss*.

The analysis is divided into two main approaches: population genetic differentiation (outlier detection) and genotype-phenotype association testing.

## Directory Structure

The analysis is organized into four main sub-stages:

###  [4.1 Population Genetic Differentiation (Fsthet)](./4.1_Population_Genetic_Differentiation_Fsthet/)
Focuses on identifying outliers based on the relationship between FST and heterozygosity. 

###  [4.2 Population Genetic Differentiation (PCAdapt)](./4.2_Population_Genetic_Differentiation_PCAdapt/)
Utilizes Principal Component Analysis (PCA) to detect outliers. 

###  [4.3 Genotype-Phenotype Association (RDA)](./4.3_Genotype_phenotype_association_RDA/)
Performs Redundancy Analysis (RDA) to identify SVs associated with phenotypic variables (IPNV resistance). 

###  [4.4 Genotype-Phenotype Association (LFMM)](./4.4_Genotype_phenotype_association_LFMM/)
Applies Latent Factor Mixed Models (LFMM) to test for associations between SVs and phenotypes while accounting for unobserved population structure (latent factors).
