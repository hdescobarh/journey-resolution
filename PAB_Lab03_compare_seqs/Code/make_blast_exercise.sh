#!/bin/bash
# Author: hdescobarh

# Use the script location as reference directory
cd "$(dirname "$0")" || exit

SEQUENCES_CSV="../Data/data_for_blast.csv"

# 1. Download sequences from NCBI

echo "Downloading sequences..."

# Entrez Programming Utilities Help https://www.ncbi.nlm.nih.gov/books/NBK25497/
python3 "download_data.py" "$SEQUENCES_CSV" "../Data/Sequences" || exit
echo "Done"

# 2. Create Blast Database

echo "Creating Blast Databases..."
mkdir -p "../Data/BlastDB"
declare -a DB_PATHS
declare -a QUERIES_PATHS

while IFS="," read -ra ARRAY; do # IFS = Internal Field Separator
  if [ "${ARRAY[6]}" == "makedb" ]; then
    INPUT_SEQUENCE="../Data/Sequences/${ARRAY[0]}.fasta"
    OUTPUT_DB="../Data/BlastDB/${ARRAY[0]}"
    NCBI_TXID="${ARRAY[2]}"
    # Building a BLAST database with your (local) sequences https://www.ncbi.nlm.nih.gov/books/NBK569841/
    makeblastdb -dbtype "nucl" -in "$INPUT_SEQUENCE" -parse_seqids -out "$OUTPUT_DB" -taxid "$NCBI_TXID" -logfile "${OUTPUT_DB}.makeblastdb.log" && DB_PATHS+=("$OUTPUT_DB")
  else
    QUERIES_PATHS+=("../Data/Sequences/${ARRAY[0]}.fasta")
  fi
done < <(sed 1d "$SEQUENCES_CSV") # https://www.gnu.org/software/bash/manual/bash.html#Process-Substitution

echo "Done"

# 3. Make blast search

echo "Starting Blast search for ${#QUERIES_PATHS[@]} queries in ${#DB_PATHS[@]} databases.."

mkdir -p "../Results/Blast_Searches"

for DB in "${DB_PATHS[@]}"; do
  for QUERY in "${QUERIES_PATHS[@]}"; do
    DB_NAME="$(basename -- "$DB")"
    QUERY_NAME="$(basename -- "$QUERY" ".fasta")"
    echo "Searching ${QUERY_NAME} in ${DB_NAME}..."
    OUTPUT_PATH="../Results/Blast_Searches/db-${DB_NAME}_q-${QUERY_NAME}.tsv"

    # word_size, scores and gap penalties are the default for the task "blastn"

    # remember default fields for outfmt 6, 7 and 10 are:
    #   - Query Seq-id, Subject Seq-id, Percentage of identical matches, Alignment length,
    #   - Number of mismatches, Number of gap openings, Start of alignment in query, End of alignment in query,
    #   - Start of alignment in subject, End of alignment in subject, Expect value, Bit score
    # https://www.ncbi.nlm.nih.gov/books/NBK279684/#appendices.Options_for_the_commandline_a

    blastn -query "$QUERY" -task "blastn" -db "$DB" -out "$OUTPUT_PATH" -evalue 0.05 -word_size 11 -gapopen 5 -gapextend 2 -reward 2 -penalty -3 -outfmt 6
    echo "Done"
  done
done

echo "Done all BLAST searches"
