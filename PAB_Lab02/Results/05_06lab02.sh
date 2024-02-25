#!/bin/bash
# Hans D. Escobar H.

printf "Escriba las rutas de los dos archivos:\n"
read -rp "Archivo 1: " FILE1
read -rp "Archivo 2: " FILE2
printf "\n"

if [ ! -f "$FILE1" ]; then
    printf "Error: la ruta '%s' no corresponde a un archivo.\n" "$FILE1"

elif [ ! -f "$FILE2" ]; then
    printf "Error: la ruta '%s' no corresponde a un archivo.\n" "$FILE2"
else
    printf "Printing head of %s...\n" "$FILE1"
    head -n 2 "$FILE1" | while read -r line; do printf "\t %s\n" "$line"; done

    printf "\nPrinting tail of %s...\n" "$FILE2"
    tail -n 2 "$FILE2" | while read -r line; do printf "\t %s\n" "$line "; done
fi
