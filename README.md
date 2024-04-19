# Monorepo Biología semestre 10


Almaceno soluciones a algunas asignaciones de mi ultimo semestre 🥳 2024-01 🎉✨✨✨


## Enviromenment configuration

### R

- Este paquete es necesario para usar las funcionalidades para R de VS Code

```R
update.packages(ask=FALSE)
install.packages("languageserver")
```

- Kernel de R para Jupyter. Recordar tener instalado Jupyter

```R
install.packages('IRkernel')
IRkernel::installspec()
```

### Perl

- Configurando cpan

Sí es la primera vez que se corre, entra en modo configuración

```Bash
cpan
```
También se puede invocar desde la prompt the cpan:

```cpan
cpan[1]> o conf init
```

- Instalar cpanm

```bash
cpan App::cpanminus
```

- Instalando servidor de lenguaje

Dependencias en Debian based

```bash
sudo apt install libanyevent-perl libclass-refresh-perl libcompiler-lexer-perl libdata-dump-perl libio-aio-perl libjson-perl libmoose-perl libpadwalker-perl libscalar-list-utils-perl libcoro-perl
```

```bash
cpanm Perl::LanguageServer
```

## Estructura

Las primeras 2 o 3 letras de las carpetas indican la asignatura asociada.

- GRC: Genética de Rasgos Complejos
- PAB: Programación y algoritmos para Bioinformática
- FV: Fisiología vegetal

