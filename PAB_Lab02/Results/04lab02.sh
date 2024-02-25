#!/bin/bash
# Hans D. Escobar H.

# Use example:
# bash 04lab02.sh "01lab02.sh" "02_03lab02.sh"

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: debe ingresar dos rutas de archivo."
else
    printf "Printing head of %s...\n" "$1"
    head -n 2 "$1" | while read -r line; do printf "\t %s\n" "$line"; done

    printf "\nPrinting tail of %s...\n" "$2"
    tail -n 2 "$2" | while read -r line; do printf "\t %s\n" "$line "; done
fi
