#!/usr/bin/env bash
# author: hdescobarh

# Use this script location as reference directory
cd "$(dirname "$0")" || exit

METHODS="TMMwsp, upperquartile, none"
ROOT_OUTPUT_DIR="../Results"

# location of count file by tool used to map genes
declare -A FILE_PATHS
FILE_PATHS["Bowtie"]="../Example_Data/Bowtie_filTotal.txt"
FILE_PATHS["Bowtie2"]="../Example_Data/Bowtie2_filTotal.txt"
FILE_PATHS["BWA"]="../Example_Data/BWA_filTotal.txt"
FILE_PATHS["Segemehl"]="../Example_Data/Segemehl_filTotal3.txt"

for tool in "${!FILE_PATHS[@]}"; do
  printf "Running analysis for %s mapping...\n" "$tool"
  current_output_dir="${ROOT_OUTPUT_DIR}/${tool}"
  Rscript --vanilla "./do_DE_analysis.r" "${FILE_PATHS[$tool]}" "$METHODS" "$current_output_dir"
  echo "Done!"

done

echo "Finished all analysis."
