#!/usr/bin/env bash

OUTPUT_DIR="../Results"
HAPMAP_FILE="../Example_Data/GBS_150G.txt"
PHENOTYPE_FILE="../Example_Data/pheno.txt"
COMPONENTS=("2" "3")

# Use this script location as reference directory
cd "$(dirname "$0")" || exit
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR" || exit

for CURRENT in "${COMPONENTS[@]}"; do
  OUT="ncomponents_$CURRENT"
  rm -rf "$OUT"
  mkdir "$OUT"
  cd "$OUT" || exit
  Rscript --vanilla "../../$(dirname "$0")/gwas_mixed_linear.R" "../$PHENOTYPE_FILE" "../$HAPMAP_FILE" "$CURRENT" 2>&1 | tee "_script_report.txt"
  cd ..
done
