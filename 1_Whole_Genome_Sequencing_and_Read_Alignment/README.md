# 1. Whole Genome Sequencing and Read Alignment

This directory contains the initial stages of the bioinformatic pipeline for identifying structural variants (SVs) associated with Infectious Pancreatic Necrosis Virus (IPNV) resistance in rainbow trout (*Oncorhynchus mykiss*). 

The analysis starts with raw sequencing data from 28 individuals (14 resistant and 14 susceptible) selected from an IPNV challenge trial. The workflow ensures high-quality data through rigorous control and accurate alignment to the reference genome.

## Directory Structure

This stage is divided into three sequential steps. Each folder contains its own `README.md` with specific execution scripts and technical details:

  **[1.1_FastQC_Quality_Control](./1.1_FastQC_Quality_Control/)**: Raw data evaluation using FastQC to assess per-base quality, adapter content, and duplication levels.
  **[1.2_Reference_Genome_Alignment](./1.2_Reference_Genome_Alignment/)**: Read mapping to the *Oncorhynchus mykiss* reference genome (USDA_OmykA_1.1) using `BWA-MEM`.
  **[1.3_Coverage_Visualization_DeepTools](./1.3_Coverage_Visualization_DeepTools/)**: Quality assessment of the alignment, including coverage depth and correlation between samples using `deepTools`.

## Workflow Execution

The analysis must be executed in order:
1. Run the quality control scripts in `1.1`.
2. Perform the alignment and indexing in `1.2`.
3. Generate visualization plots and coverage statistics in `1.3`.

