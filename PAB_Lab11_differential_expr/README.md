# Notas personales - RNA-Seq

## Diseño experimental

- Tipo de biblioteca. Por ejemplo, tipo de RNA de interés (determina que enriquecer), sí se requiere mantener la orientación del transcrito (strand-specific), o sí se requiere pareada o simple (e.g.pareada estudiar isoformas).

- Profundidad y ancho de cobertura de secuenciación.

- Replicas técnicas. Son replicas generadas de repetir de forma independiente el mismo protocolo experimental a la __misma__ muestra biológica.Permite capturar la variabilidad introducida por el protocolo para reducir los sesgos introducidos por este. Dependen el protocolo, por ejemplo la secuenciación per se es altamente reproducible, pero la preparación de la biblioteca, cultivo o procedimientos tales como knockdown introducen variabilidad adicional.

- Replicas biológicas. Se generan de aplicar el mismo protocolo experimental a __diferentes__ muestras biológicas. Dependiendo de sí estas muestras tienen o no el mismo origen (e.g., mismo donador o el mismo modelo) se pueden clasificar, respectivamente, en isogénicas o anisogénicas.

| | Técnica | B. Isogénica | B. Anisogénica |
| :- | :-: | :-: | :-: |
| Origen | = | ≠ | ≠ |
| Muestra biológica | = | = | ≠ |

## Cuantificación

El conteo de lecturas (read count) es el número de lecturas que mapean a un gen. Esta influenciado por por la __longitud del transcrito__, por lo que es necesario introducir correcciones por la longitud sí se desea comparar los niveles de expresión de multiples genes (lo que implica diferentes longitudes) dentro una muestra o entre multiples muestras.


## Bibliografía

[1] A. L. Yunshun Chen, “edgeR.” [object Object], 2017. doi: 10.18129/B9.BIOC.EDGER.<br>
[2] S. A. Michael Love, “DESeq2.” [object Object], 2017. doi: 10.18129/B9.BIOC.DESEQ2.<br>
[3] M. I. Love, S. Anders, V. Kim, and W. Huber, “RNA-Seq workflow: gene-level exploratory analysis and differential expression,” F1000Res, vol. 4, p. 1070, Nov. 2016, doi: 10.12688/f1000research.7035.2.<br>
[4] “Terms and Definitions,” The Encyclopedia of DNA Elements (ENCODE). Accessed: May 16, 2024. [Online]. Available: https://www.encodeproject.org/data-standards/terms/<br>
[5] “RNA sequencing,” Functional genomics II. Accessed: May 16, 2024. [Online]. Available: https://www.ebi.ac.uk/training/online/courses/functional-genomics-ii-common-technologies-and-data-analysis-methods/rna-sequencing/<br>
