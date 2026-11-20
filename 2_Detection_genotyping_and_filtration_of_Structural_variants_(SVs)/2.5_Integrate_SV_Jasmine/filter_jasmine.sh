#!/bin/bash

# Input and output files
INPUT_VCF="28_manta_lumpy_gatk_delly_noGenotypes.vcf"
OUTPUT_VCF="28_manta_lumpy_gatk_delly_noGenotypes_clean.vcf"

# Check if input file exists
if [ ! -f "$INPUT_VCF" ]; then
    echo "Error: Input file '$INPUT_VCF' not found."
    exit 1
fi

# Check if awk is available
if ! command -v awk &> /dev/null; then
    echo "Error: 'awk' command not found."
    exit 1
fi

# Check if sed is available
if ! command -v sed &> /dev/null; then
    echo "Error: 'sed' command not found."
    exit 1
fi

echo "Processing VCF file: $INPUT_VCF"
echo "Output will be saved to: $OUTPUT_VCF"

# Process the VCF file
awk '
BEGIN {
    FS = "\t"
    OFS = "\t"
    
    # Define missing INFO fields
    missing_info["STRANDS"]          = "##INFO=<ID=STRANDS,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["AC"]               = "##INFO=<ID=AC,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["AF"]               = "##INFO=<ID=AF,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["AN"]               = "##INFO=<ID=AN,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["BaseQRankSum"]     = "##INFO=<ID=BaseQRankSum,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["DP"]               = "##INFO=<ID=DP,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["ExcessHet"]        = "##INFO=<ID=ExcessHet,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["FS"]               = "##INFO=<ID=FS,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["InbreedingCoeff"]  = "##INFO=<ID=InbreedingCoeff,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["MLEAC"]            = "##INFO=<ID=MLEAC,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["MLEAF"]            = "##INFO=<ID=MLEAF,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["MQ"]               = "##INFO=<ID=MQ,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["MQRankSum"]        = "##INFO=<ID=MQRankSum,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["QD"]               = "##INFO=<ID=QD,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["ReadPosRankSum"]   = "##INFO=<ID=ReadPosRankSum,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["SOR"]              = "##INFO=<ID=SOR,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["CIPOS95"]          = "##INFO=<ID=CIPOS95,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["CIEND95"]          = "##INFO=<ID=CIEND95,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["SU"]               = "##INFO=<ID=SU,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["CIGAR"]            = "##INFO=<ID=CIGAR,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["HOMSEQ"]           = "##INFO=<ID=HOMSEQ,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["SVINSLEN"]         = "##INFO=<ID=SVINSLEN,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["SVINSSEQ"]         = "##INFO=<ID=SVINSSEQ,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["INV3"]             = "##INFO=<ID=INV3,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["EVENT"]            = "##INFO=<ID=EVENT,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["JUNCTION_QUAL"]    = "##INFO=<ID=JUNCTION_QUAL,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["INV5"]             = "##INFO=<ID=INV5,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["LEFT_SVINSSEQ"]    = "##INFO=<ID=LEFT_SVINSSEQ,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["RIGHT_SVINSSEQ"]   = "##INFO=<ID=RIGHT_SVINSSEQ,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["MATEID"]           = "##INFO=<ID=MATEID,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["BND_DEPTH"]        = "##INFO=<ID=BND_DEPTH,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["MATE_BND_DEPTH"]   = "##INFO=<ID=MATE_BND_DEPTH,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_info["SPLIT_READS"]      = "##INFO=<ID=SPLIT_READS,Number=.,Type=String,Description=\"Number of split reads supporting the variant (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["FWD_SPLIT_READS"]  = "##INFO=<ID=FWD_SPLIT_READS,Number=.,Type=String,Description=\"Number of forward split reads supporting the variant (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["REV_SPLIT_READS"]  = "##INFO=<ID=REV_SPLIT_READS,Number=.,Type=String,Description=\"Number of reverse split reads supporting the variant (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["OVERLAP"]          = "##INFO=<ID=OVERLAP,Number=.,Type=String,Description=\"Overlap information for the variant (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["ALGORITHM"]        = "##INFO=<ID=ALGORITHM,Number=.,Type=String,Description=\"Algorithm used to call the variant (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["LEFT_ANCHOR"]      = "##INFO=<ID=LEFT_ANCHOR,Number=.,Type=String,Description=\"Left anchor information for the variant (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["RIGHT_ANCHOR"]     = "##INFO=<ID=RIGHT_ANCHOR,Number=.,Type=String,Description=\"Right anchor information for the variant (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["STABLE_DEPTHS"]    = "##INFO=<ID=STABLE_DEPTHS,Number=.,Type=String,Description=\"Stable depths information for the variant (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["S_INS_0"]          = "##INFO=<ID=S_INS_0,Number=.,Type=String,Description=\"Insertion sequence information (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["DISCORDANT"]       = "##INFO=<ID=DISCORDANT,Number=.,Type=String,Description=\"Discordant read information (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["AVG_STABLE_NM"]    = "##INFO=<ID=AVG_STABLE_NM,Number=.,Type=String,Description=\"Average stable NM value (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["SPANNING_READS"]   = "##INFO=<ID=SPANNING_READS,Number=.,Type=String,Description=\"Number of spanning reads (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["INCOMPLETE_ASSEMBLY"] = "##INFO=<ID=INCOMPLETE_ASSEMBLY,Number=.,Type=String,Description=\"Incomplete assembly information (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["PE"]               = "##INFO=<ID=PE,Number=.,Type=String,Description=\"Paired-end evidence count (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["SR"]               = "##INFO=<ID=SR,Number=.,Type=String,Description=\"Split-read evidence count (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["PRECISE"]          = "##INFO=<ID=PRECISE,Number=.,Type=String,Description=\"Precision of the variant call (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["CHR2"]             = "##INFO=<ID=CHR2,Number=.,Type=String,Description=\"Chromosome of the second breakend (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["MAPQ"]             = "##INFO=<ID=MAPQ,Number=.,Type=String,Description=\"Mapping quality (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["CT"]               = "##INFO=<ID=CT,Number=.,Type=String,Description=\"Connection type (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["INSLEN"]           = "##INFO=<ID=INSLEN,Number=.,Type=String,Description=\"Insertion length (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["SRQ"]              = "##INFO=<ID=SRQ,Number=.,Type=String,Description=\"Split-read quality (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["CONSENSUS"]        = "##INFO=<ID=CONSENSUS,Number=.,Type=String,Description=\"Consensus sequence (added by clean_vcf_del_fields_improved.sh)\">"
    missing_info["CE"]               = "##INFO=<ID=CE,Number=.,Type=String,Description=\"Consensus sequence (added by clean_vcf_del_fields_improved.sh)\">"
    
    # Define missing FORMAT fields
    missing_format["AD"]             = "##FORMAT=<ID=AD,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_format["DP"]             = "##FORMAT=<ID=DP,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_format["PGT"]            = "##FORMAT=<ID=PGT,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_format["PID"]            = "##FORMAT=<ID=PID,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_format["PL"]             = "##FORMAT=<ID=PL,Number=G,Type=Integer,Description=\"Phred-scaled genotype likelihoods (corrected by clean_vcf_del_fields_improved.sh)\">"
    missing_format["PS"]             = "##FORMAT=<ID=PS,Number=.,Type=String,Description=\"Field added by clean_vcf_del_fields_improved.sh\">"
    missing_format["SU"]             = "##FORMAT=<ID=SU,Number=.,Type=String,Description=\"Number of pieces of evidence supporting the variant (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["PE"]             = "##FORMAT=<ID=PE,Number=.,Type=String,Description=\"Paired-end evidence count (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["SR"]             = "##FORMAT=<ID=SR,Number=.,Type=String,Description=\"Split-read evidence count (added by clean_vcf_del_fields_improved.sh\">"
    missing_format["PR"]             = "##FORMAT=<ID=PR,Number=.,Type=String,Description=\"Spanning paired-read support (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["SQ"]             = "##FORMAT=<ID=SQ,Number=.,Type=String,Description=\"Sequence quality (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["GL"]             = "##FORMAT=<ID=GL,Number=G,Type=Float,Description=\"Genotype likelihoods (corrected by clean_vcf_del_fields_improved.sh)\">"
    missing_format["RO"]             = "##FORMAT=<ID=RO,Number=.,Type=String,Description=\"Reference allele observations (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["AO"]             = "##FORMAT=<ID=AO,Number=.,Type=String,Description=\"Alternate allele observations (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["QR"]             = "##FORMAT=<ID=QR,Number=.,Type=String,Description=\"Sum of quality of reference observations (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["QA"]             = "##FORMAT=<ID=QA,Number=.,Type=String,Description=\"Sum of quality of alternate observations (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["RS"]             = "##FORMAT=<ID=RS,Number=.,Type=String,Description=\"Reference allele support (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["AS"]             = "##FORMAT=<ID=AS,Number=.,Type=String,Description=\"Alternate allele support (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["ASC"]            = "##FORMAT=<ID=ASC,Number=.,Type=String,Description=\"Allele-specific call information (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["RP"]             = "##FORMAT=<ID=RP,Number=.,Type=String,Description=\"Reference allele position (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["AP"]             = "##FORMAT=<ID=AP,Number=.,Type=String,Description=\"Alternate allele position (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["AB"]             = "##FORMAT=<ID=AB,Number=.,Type=String,Description=\"Allele balance (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["RCL"]            = "##FORMAT=<ID=RCL,Number=.,Type=String,Description=\"Read count left (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["RC"]             = "##FORMAT=<ID=RC,Number=.,Type=String,Description=\"Read count (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["RCR"]            = "##FORMAT=<ID=RCR,Number=.,Type=String,Description=\"Read count right (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["CN"]             = "##FORMAT=<ID=CN,Number=.,Type=String,Description=\"Copy number (added by clean_vcf_del_fields_improved.sh)\">"
    missing_format["DR"]             = "##FORMAT=<ID=DR,Number=.,Type=String,Description=\"Reference allele read count (added by
    missing_format["DV"]             = "##FORMAT=<ID=DV,Number=.,Type=String,Description=\"Recuento de lecturas del alelo variante (agregado por clean_vcf_del_fields_improved.sh)\">"
    missing_format["RR"]             = "##FORMAT=<ID=RR,Number=.,Type=String,Description=\"Lecturas del alelo de referencia (agregado por clean_vcf_del_fields_improved.sh)\">"
    missing_format["RV"]             = "##FORMAT=<ID=RV,Number=.,Type=String,Description=\"Lecturas del alelo variante (agregado por clean_vcf_del_fields_improved.sh)\">"
	    header_index = 0
    in_header = 1
}

# Skip complete error lines
/^[[:space:]]*\[[WE]::(bcf_hrec_check|vcf_parse_info|vcf_parse_format_dict2|bcf_hdr_parse_line)\]/ { next }

# Header processing
in_header && /^#/ {
    if (/^##INFO/) {
        if (match($0, /ID=([^,>]+)/, arr)) {
            existing_info[arr[1]] = 1
        }
    }
    else if (/^##FORMAT/) {
        if (match($0, /ID=([^,>]+)/, arr)) {
            id = arr[1]
            existing_format[id] = 1
            
            # Correct existing PL definition if incorrect
            if (id == "PL" && /Number=\./) {
                # Build corrected line using existing description if available
                desc_start = index($0, "Description=")
                if (desc_start > 0) {
                    desc = substr($0, desc_start)
                    # Remove closing > from description
                    if (substr(desc, length(desc)) == ">") {
                        desc = substr(desc, 1, length(desc) - 1)
                    }
                    corrected_line = "##FORMAT=<ID=PL,Number=G,Type=Integer," desc ">"
                } else {
                    corrected_line = "##FORMAT=<ID=PL,Number=G,Type=Integer,Description=\"Phred-scaled genotype likelihoods (corrected by clean_vcf_del_fields_improved.sh)\">"
                }
                $0 = corrected_line
            }
            # Correct existing GL definition if incorrect
            else if (id == "GL" && (/Number=\./ || /Type=String/)) {
                # Build corrected line using existing description if available
                desc_start = index($0, "Description=")
                if (desc_start > 0) {
                    desc = substr($0, desc_start)
                    # Remove closing > from description
                    if (substr(desc, length(desc)) == ">") {
                        desc = substr(desc, 1, length(desc) - 1)
                    }
                    corrected_line = "##FORMAT=<ID=GL,Number=G,Type=Float," desc ">"
                } else {
                    corrected_line = "##FORMAT=<ID=GL,Number=G,Type=Float,Description=\"Genotype likelihoods (corrected by clean_vcf_del_fields_improved.sh)\">"
                }
                $0 = corrected_line
            }
        }
    }
    
    if (/^#CHROM/) {
        header_lines[++header_index] = $0
        in_header = 0
        
        # Print original header (except #CHROM) + missing fields + #CHROM
        for (i = 1; i < header_index; i++) {
            print header_lines[i]
        }
        # Add missing INFO fields
        for (id in missing_info) {
            if (!existing_info[id]) {
                print missing_info[id]
            }
        }
        # Add missing FORMAT fields
        for (id in missing_format) {
            if (!existing_format[id]) {
                print missing_format[id]
            }
        }
        print header_lines[header_index]
        next
    } else {
        header_lines[++header_index] = $0
        next
    }
}

# If we find data during header processing
in_header && !/^#/ {
    in_header = 0
    for (i = 1; i <= header_index; i++) {
        print header_lines[i]
    }
    # Add missing INFO fields
    for (id in missing_info) {
        if (!existing_info[id]) {
            print missing_info[id]
        }
    }
    # Add missing FORMAT fields
    for (id in missing_format) {
        if (!existing_format[id]) {
            print missing_format[id]
        }
    }
    # Continue processing this line as data
}

# Data lines
{
    # Remove embedded error messages
    gsub(/\[[WE]::vcf_parse_info\] INFO .* assuming Type=String/, "", $0)
    gsub(/\[W::bcf_hrec_check\] Invalid tag name:.*/, "", $0)
    gsub(/\[W::vcf_parse_format_dict2\] FORMAT .* assuming Type=String/, "", $0)
    gsub(/\[E::bcf_hdr_parse_line\] Could not parse the header line:.*/, "", $0)
    gsub(/\[E::vcf_parse_info\] Could not add dummy header for INFO .*/, "", $0)
    
    # Check if the line contains problematic INFO fields using general patterns
    skip_variant = 0
    if ($8 != ".") {
        n = split($8, info_array, ";")
        for (i = 1; i <= n; i++) {
            # Extract the key from the INFO field
            if (info_array[i] ~ /=/) {
                split(info_array[i], keyval, "=")
                key = keyval[1]
            } else {
                key = info_array[i]
            }
            
            # General patterns to detect problematic fields:
            # 1. Fields containing ",._duplicate" (like "2031,._duplicate8749")
            # 2. Fields that are only 4-digit numbers (like "2013", "2154", etc.)
            # 3. Fields containing invalid characters like commas and dots
            if (key ~ /,\._duplicate/ || 
                key ~ /^[0-9]{4}$/ || 
                key ~ /[^A-Za-z0-9_]/ || 
                key ~ /^[0-9]/) {
                skip_variant = 1
                break
            }
        }
    }
    
    # If the variant contains problematic fields, skip it
    if (skip_variant) {
        next
    }
    
    # Process INFO field (normal cleanup)
    if ($8 != ".") {
        n = split($8, info_array, ";")
        new_info = ""
        for (i = 1; i <= n; i++) {
            if (info_array[i] !~ /^DEL[0-9]+/ && info_array[i] !~ /^Manta[^:]*:[^:]*:/) {
                if (new_info == "") {
                    new_info = info_array[i]
                } else {
                    new_info = new_info ";" info_array[i]
                }
            }
        }
        $8 = (new_info == "") ? "." : new_info
    }
    
    # Remove truncated sequences
    gsub(/>$/, "", $0)
    
    print $0
}' "$INPUT_VCF" > "$OUTPUT_VCF"
  
  # Validate and clean possible errors
  sed -i '/^[^#]/ s/;;\+/;/g' "$OUTPUT_VCF"  # Remove consecutive ';;'
  sed -i '/^[^#]/ s/;$//' "$OUTPUT_VCF"       # Remove trailing ';'
  sed -i '/^[^#]/ s/;\.;/;/g' "$OUTPUT_VCF"   # Clean empty fields
  sed -i '/^$/d' "$OUTPUT_VCF"                # Remove empty lines
  
  echo "Process completed. Clean file: $OUTPUT_VCF"
