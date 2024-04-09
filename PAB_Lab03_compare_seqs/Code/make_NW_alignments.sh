#!/bin/bash

SEQUENCES=$1
OUTPUT_FILE=$2

touch $OUTPUT_FILE

while read -r line; do
  # set Internal Field Separator
  IFS=","
  ARRAY=($line)
  ID="${ARRAY[0]}"
  ALIGNMENT=$(perl "./third_party/NW_book_blast_korf.pl" "${ARRAY[1]}" "${ARRAY[2]}")
  printf "%s,%s\n" $ID $(sed -z "s/\n/\\\n/" <<< $ALIGNMENT) >> $OUTPUT_FILE
done < "$SEQUENCES"
