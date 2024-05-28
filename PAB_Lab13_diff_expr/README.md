# Differential expression multiple factors x normalization x mapping

It performs differential expression analysis from data with multiple factors. It checks different normalization strategies and uses files generated by different gene mapping tools.

To run the analyses:

```bash
./Code/run_main.sh 
```

## Data

The count files columns names are in the form \[DM\](03|12|24|48)R\[456\].

For example:

| MIRNA | D03R4 | D03R5 | M03R5 | M03R6 | D12R4 | D12R5 | D12R6 | ... |
| -: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| hsa-mir-197-3p | 160 | 275 | 235 | 265 | 349 | 377 | 356 | ... |
| hsa-mir-200b-3p | 6 | 8 | 6 | 7 | 11 | 22 | 14 | ... |
| hsa-mir-200a-3p | 2 | 7 | 6 | 7 | 6 | 9 | 3 | ... |