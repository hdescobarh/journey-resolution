#!/bin/bash
# hdescobarh

# Ejemplo sincronizar con HPC
cd "202401_monorepo/" || exit

find ./ -type d -regex '\.\/PAB_Lab0[3-9][A-Za-z_]*[^/]' | while read -r LINE; do
  SOURCE_DIR="$(basename -- "$LINE")"
  rsync -aPv "$SOURCE_DIR" "perseus:ws_PAB/$SOURCE_DIR"
done
