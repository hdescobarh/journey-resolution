#!/bin/bash
# Author: hdescobarh

cd "$(dirname "$0")" || exit
mkdir -p "../Results"

SEQUENCES="../Data/sequences_for_NW.csv"
OUTPUT_FILE="../Results/global_alignments.csv"

echo "id,alignment" >$OUTPUT_FILE

sed 1d "$SEQUENCES" | while IFS="," read -ra ARRAY; do # IFS: Internal Field Separator
  ID="${ARRAY[0]}"
  ALIGNMENT=$(perl "./third_party/NW_book_blast_korf.pl" "${ARRAY[1]}" "${ARRAY[2]}")
  FORMATED_ALIGMENT=$(sed -z "s/\n/\\\n/" <<<"$ALIGNMENT")
  printf "%s,%s\n" "$ID" "$FORMATED_ALIGMENT" >>"$OUTPUT_FILE"
done
