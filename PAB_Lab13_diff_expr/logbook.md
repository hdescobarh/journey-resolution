# ED multiples set de datos y comparaciones


## Datos

Corresponde a datos de miRNA mapeados con diferentes aplicaciones: BWA, Bowtie, Bowtie2 y Segemehl. Hay un archivo en formatoTSV (tab-separated values) por cada programa; primera fila es header, primera columna los ID de los tag (miRNA).

El formato de los tratamientos en regex es: \[DM\](03|12|24|48)R\[456\]

Ejemplo:

| MIRNA | D03R4 | D03R5 | M03R5 | M03R6 | D12R4 | D12R5 | D12R6 | ... |
| -: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| hsa-mir-197-3p | 160 | 275 | 235 | 265 | 349 | 377 | 356 | ... |
| hsa-mir-200b-3p | 6 | 8 | 6 | 7 | 11 | 22 | 14 | ... |
| hsa-mir-200a-3p | 2 | 7 | 6 | 7 | 6 | 9 | 3 | ... |

❗ En principio deberían ser 24 (2x4x3) columnas; sin embargo, la mayoría solo tiene 22, faltando M48R6 y M24R5. Tener en cuenta en caso de querer compararse entre archivos.
