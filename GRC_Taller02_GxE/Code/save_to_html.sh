#!/usr/bin/env bash

jupyter nbconvert mi_solucion.ipynb --TagRemovePreprocessor.enabled=True --TagRemovePreprocessor.remove_input_tags remove_input --TagRemovePreprocessor.remove_cell_tags remove_cell --to html
