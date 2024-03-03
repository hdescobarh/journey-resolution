#!/bin/bash
# author Hans D. Escobar H.

# Extrae la secuencia de un FASTA y cuenta el número de Metioninas

CODON_LIST=$(grep "^[^>]" <../Example_Data/fasta_example.fasta | tr -d "[:space:]" | fold -w3)
COUNTER=0
for TRINUCLEOTIDE in $CODON_LIST; do
  if [ "${TRINUCLEOTIDE^^}" == 'ATG' ]; then
    ((COUNTER++))
  fi
done

printf "There are %s Methionines\n" $COUNTER
