#!/usr/bin/env bash

cd "$(dirname "$0")" || exit
notebook="solucion_taller05.ipynb"
output_dir="../Results"
jupyter nbconvert $notebook --TagRemovePreprocessor.enabled=True --TagRemovePreprocessor.remove_input_tags remove_input --TagRemovePreprocessor.remove_cell_tags remove_cell --to html --output-dir=$output_dir
