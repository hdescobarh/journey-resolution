#!/usr/bin/env bash
# author: hdescobarh

# Use this script location as reference directory
cd "$(dirname "$0")" || exit

Rscript --vanilla "analysis.R" 2>&1 | tee "../Results/report.txt"
