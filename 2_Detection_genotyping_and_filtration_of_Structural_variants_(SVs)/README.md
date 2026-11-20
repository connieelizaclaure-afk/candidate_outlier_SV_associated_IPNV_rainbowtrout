# 2. Detection, Genotyping, and Filtration of Structural Variants (SVs)

This directory contains the core analytical workflow for the identification, multi-tool detection, integration, and filtration of structural variants (SVs) in rainbow trout (*Oncorhynchus mykiss*). The study focuses on variants associated with Infectious Pancreatic Necrosis Virus (IPNV) resistance.

The pipeline utilizes four different detection algorithms (Manta, Lumpy, Delly, and GATK) to capture SVs, followed by an integration step to consolidate results and a filtration process.

## Directory Structure

This stage is divided into six specialized modules. Each folder contains its own `README.md` with specific installation instructions, execution scripts, and technical parameters:

 **[2.1_Detection_SV_Manta](./2.1_Detection_SV_Manta/)**: Identification of SVs and small indels using the Manta structural variant caller. Includes inversion conversion and a 7-step initial filtration.
 **[2.2_Detection_SV_Lumpy](./2.2_Detection_SV_Lumpy/)**: Discovery of SVs based on a general probabilistic framework, integrating multiple signal types (split-reads and discordant pairs).
 **[2.3_Detection_SV_Delly](./2.3_Detection_SV_Delly/)**: Discovery-to-genotyping workflow for SVs using integrated paired-end, split-read, and read-depth analysis.
 **[2.4_Detection_SV_Gatk](./2.4_Detection_SV_Gatk/)**: Identification of structural variants using the GATK-SV pipeline components optimized for high-throughput sequencing data.
 **[2.5_Integrate_SV_Jasmine](./2.5_Integrate_SV_Jasmine/)**: Integration of multi-caller SV sets into a unified non-redundant call set using `Jasmine`, prioritizing consensus and precise breakpoint refinement.
 **[2.6_Filtration_SV](./2.6_Filtration_SV/)**: Final refinement of the integrated dataset, applying filters for genotyping rate (≥ 0.8) and Minor Allele Frequency (MAF ≥ 0.1) to define the final candidate variants.

## Workflow Execution

The analysis must be executed in a specific sequence to ensure data integrity:
1. Execute individual detection algorithms in folders `2.1` through `2.4`.
2. Run the integration pipeline in `2.5` to merge the multi-tool outputs.
3. Apply the final quality and frequency filters in `2.6` to generate the clean VCF for downstream genomic analysis.
