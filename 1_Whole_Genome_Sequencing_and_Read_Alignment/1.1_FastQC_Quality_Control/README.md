# 1.1 FastQC Quality Control

The following code allows verifying the quality of the sequencing data. Note that while Novogene provides pre-reviewed files, this step ensures data integrity for the current analysis.

```bash
# FastQC Quality Control
#-------------------------------------------------------------------------------
# NOTE: Novogene sends files reviewed with FastQC. However, 
# the following code allows verifying the QUALITY of the data.

# Enter the directory created for analysis
cd /mnt/disco2/pcaceres/eliza_trout 

# Create output directory
mkdir -p 1_quality_control_fastqc 

# Run FastQC on all .fq.gz files using 4 threads
fastqc -t 4 ./raw_data/*.fq.gz -o 1_quality_control_fastqc 

# NOTE: Inside the 1_quality_control_fastqc folder, 4 files per sample should be created:
# M0018_1_fastqc.html
# M0018_1_fastqc.zip   
# M0018_2_fastqc.html 
# M0018_2_fastqc.zip   

# Verify file existence and size
ls -lh M0018_1_fastqc.zip 
# Note: If the size is 0 or very small (e.g., <1KB), the file is empty/corrupt.

# List internal content of the ZIP file
unzip -l M0018_1_fastqc.zip 

# Expected output structure:
# Archive:  M0018_1_fastqc.zip
# Length      Date    Time    Name
# ---------  ---------- -----   ----
#  0  2025-04-23 21:17   M0018_1_fastqc/
#  0  2025-04-23 21:17   M0018_1_fastqc/Icons/
#  0  2025-04-23 21:17   M0018_1_fastqc/Images/
#  1197  2025-04-23 21:17   M0018_1_fastqc/Icons/fastqc_icon.png
#  1450  2025-04-23 21:17   M0018_1_fastqc/Icons/warning.png
#  1561  2025-04-23 21:17   M0018_1_fastqc/Icons/error.png
#  1715  2025-04-23 21:17   M0018_1_fastqc/Icons/tick.png
#  474  2025-04-23 21:17   M0018_1_fastqc/summary.txt
#  42613  2025-04-23 21:17   M0018_1_fastqc/Images/per_base_quality.png
#  18620  2025-04-23 21:17   M0018_1_fastqc/Images/per_tile_quality.png
#  42759  2025-04-23 21:17   M0018_1_fastqc/Images/per_sequence_quality.png
#  46989  2025-04-23 21:17   M0018_1_fastqc/Images/per_base_sequence_content.png
#  88420  2025-04-23 21:17   M0018_1_fastqc/Images/per_sequence_gc_content.png
#  40527  2025-04-23 21:17   M0018_1_fastqc/Images/per_base_n_content.png
#  23753  2025-04-23 21:17   M0018_1_fastqc/Images/sequence_length_distribution.png
#  38978  2025-04-23 21:17   M0018_1_fastqc/Images/duplication_levels.png
#  66093  2025-04-23 21:17   M0018_1_fastqc/Images/adapter_content.png
#  597756  2025-04-23 21:17   M0018_1_fastqc/fastqc_report.html
#  936106  2025-04-23 21:17   M0018_1_fastqc/fastqc_data.txt
#  2970  2025-04-23 21:17   M0018_1_fastqc/fastqc.fo
# ---------                     -------
#  1951981                     20 files
```
