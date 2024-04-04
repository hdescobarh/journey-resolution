# Taller alineamiento secuencias - BLAST

## Datos

Se descargaron las secuencias de referencia [RefSeq](https://www.ncbi.nlm.nih.gov/books/NBK21091/) del gen [BRCA2](https://www.ncbi.nlm.nih.gov/gene/675/) de _Homo sapiens_ y sus productos (6 transcritos, 5 proteínas):

| Transcript | Length (nt) | Protein | Length (aa) | Isoform |
| :-: | :-: | :-: | :-: | :-: |
| NR_176251.1 | 12018	| | | |			
| NM_000059.4 | 11954 | NP_000050.3 | 3418 | 1 |
| NM_001406720.1 | 11903 | NP_001393649.1 | 3401 | 2 |
| NM_001406719.1 | 11858 | NP_001393648.1 | 3386 | 3 |
| NM_001406721.1 | 7022 | NP_001393650.1 | 1774 | 4 |
| NM_001406722.1 | 5800 | NP_001393651.1 | 1279 | 5 |

## Metodología

### Programas y queries

En blastn, blastp y blastx usando las siguientes combinaciones de datos y programas, para un total de 4 pares (query, programa):

| Programa | blastn | blastp | blastx |
| :-: | :-: | :-: | :-: |
| Queries | gene.fna, rna.fna | protein.faa | rna.fna |


### Parámetros a evaluar

Para cada par (query, programa) se evaluó el efecto del valor de los parámetros tamaño de palabra (W), matriz de puntuación (S) y esquema penalización de gaps (G). La evaluación se hizo de forma secuencial: primero se evaluó W y se fijó el del mejor tiempo, luego se hizo lo mismo con S, y finalmente G.

La evaluación consistió tomar diferentes valores del parámetro, registrar su tiempo de ejecución y datos de su mejor hit, y seleccionar el valor con menor tiempo de ejecución.



### Configuración por defecto

Se empleará el programa y parámetros por defecto, salvo "Max target sequence" que se fijara a 50. Esto solo afecta las secuencias mostradas y no el número de alineamientos.

- Optimize for Highly similar sequences (megablast)

- Generales

Max target sequence: 50
Automatically adjust parameters for short input sequences: False
Expect threshold: 0
Max matches in a query range: 0

- Filtros y mascara

Filter Low complexity regions: True
Filter Species-specific repeats: False
Mask for lookup table only: True
Mask lower case letters: False

### blastn - gene

### blastn - rna

### blastp

### blastx







primero se filtra W, luego S y luego G, por lo que en realidad no se extra explorando todo el universo W ⨯ S ⨯ G.
