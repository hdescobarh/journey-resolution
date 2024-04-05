# Bitácora - Laboratorio comparación de secuencias biológicas en servidores sin interfase gráfica


## 2024-04-05

### Datos - Genoma completo 

Se trabajará con el cromosoma (GI and version NC_002695.2) del _[genome assembly ASM886v2](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000008865.2/)_ de la especie _Escherichia coli_ O157:H7 str. Sakai

- Descripción ensamblado:

|||
| :-: | :-: |
| Taxon | _Escherichia coli_ O157:H7 str. Sakai |
| Strain | Sakai substr. RIMD 0509952 |
| NCBI RefSeq assembly | GCF_000008865.2 |
| RefSeq Genome size | 	5.6 Mb |
| RefSeq Scaffold N50 | 5.5Mb |
| RefSeq Contig L50 | 1 |
| RefSeq Assembly level | Complete Genome |
| RefSeq Chromosome number | 3 |

- Descripción cromosomas:

| Chromosome | RefSeq | Size (bp) | GC content (%) |
| :-: | :-: | :-: | :-: |
| chromosome | NC_002695.2 | 5,498,578 | 50.5 |
| pOSAK1 | NC_002127.1 | 3,306 | 43.5 |
| pO157 | NC_002128.1 | 92,721 | 47.5 |

### Datos de trabajo - fragmentos de 2kb

El taller solo requiere dos fragmentos, uno del mismo NC_002695.2 y de otra cepa (Escherichia coli str. K-12 substr. MG1655 en este caso) en las __mismas coordenadas__. Sin embargo, al tratarse de dos ensamblados diferentes no necesariamente las mismas coordenadas se corresponden con los mismos elementos, como se logra apreciar en la tabla de abajo al comparar la columna "Genes" de las primeras dos filas (mismas coordenadas). En la fila 3 se ve el fragmento que sí contendría los mismos elementos.

Considerando quizá ver el efecto de la divergencia, se agrego un genero de la misma familia Enterobacteriaceae.

| ID | Taxon | RefSeq Accession | Interval | Genes |
| :-: | :-: | :-: | :-: | :-: |
| ecoli_sakai_a| Escherichia coli O157:H7 str. Sakai| NC_002695.2 | 512000..514000 | yajR (-), cyoE (-), cyoD (-) |
| ecoli_k12_b| Escherichia coli str. K-12 substr. MG1655 | NC_000913.3 | 512000..514000 | glsaA (+), ybaT (+), cuerR   (+)|
| ecoli_k12_a| Escherichia coli str. K-12 substr. MG1655 | NC_000913.3 | 445900..447900  | yajR (-), cyoE (-), cyoD(-) |
| edisenteriae_a| Shigella dysenteriae strain SWHEFF_49| NZ_CP055055.1 | 1174030..1176030| HUZ68_RS05625 (-), cyoE (-), 	HUZ68_RS05635(-)| 



### Obtención de los datos  

Por la facilidad que ofrece al no depender de software especifico, una buena opción es descargarlo a través de E-utilities:

> "The Entrez Programming Utilities (E-utilities) are a set of nine server-side programs that provide a stable interface into the Entrez query and database system at the National Center for Biotechnology Information (NCBI)"
> ___[Entrez Programming Utilities Help](https://www.ncbi.nlm.nih.gov/books/NBK25497/)___
