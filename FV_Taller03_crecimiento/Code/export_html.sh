#!/usr/bin/env bash

notebook="raw_report.ipynb"
output_dir="../Results"

cd "$(dirname "$0")" || exit
mkdir -p $output_dir
jupyter nbconvert $notebook \
  --TagRemovePreprocessor.enabled=True \
  --TagRemovePreprocessor.remove_input_tags remove_input \
  --TagRemovePreprocessor.remove_cell_tags remove_cell \
  --TagRemovePreprocessor.remove_all_outputs_tags remove_output \
  --to html \
  --output-dir=$output_dir
