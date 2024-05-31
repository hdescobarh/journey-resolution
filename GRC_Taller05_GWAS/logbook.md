# Bitácora

## 30-05-2024

### Instalando bibliotecas

- Genome Association and Prediction Integrated Tools - [GAPIT](https://github.com/jiabowang/GAPIT)

Tuve inconvenientes con devtools, requería las siguientes dependencias:

```bash
apt install -y libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev cmake
```


```R
update.packages(ask = FALSE)
install.packages("devtools")
devtools::install_github("jiabowang/GAPIT", dependencies=TRUE)
```

## 31-05-2024

### Revisando manual de GAPIT 


[User's manual](https://zzlab.net/GAPIT/gapit_help_document.pdf)

...debo decir que el código es horrible y la documentación pobre (｡ŏ_ŏ) 


       Y: = NULL, data.frame of phenotype data, samples in rows, traits
          in column, first column is sample name

       G: = NULL, data.frame of genotypic data, HAPMAP format


