# Monorepo Biología semestre 10


Almaceno soluciones a algunas asignaciones de mi ultimo semestre 🥳 2024-01 🎉✨✨✨


## Enviromenment configuration

### Python

- Creación del entorno virtual a partir de requirements.txt

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

### R

- Este paquete es necesario para usar las funcionalidades para R de VS Code

```R
update.packages(ask=FALSE)
install.packages("languageserver")
```

- Kernel de R para Jupyter. Recordar tener instalado Jupyter en el entorno de Python

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

## Como usar Jupyter para Python y R

- Activar el entorno virtual sí no esta activo

- Iniciar servidor 

```bash
jupyter notebook
```

En caso de querer revisar los servidores activos y sus token:

```bash
jupyter server list
```

- Seleccionar Kernel

Se puede trabajar con el notebook desde VSCode. Para seleccionar el kernel, es necesario indicar que se conecte a un servidor de Jupyter, colocar URL y password (Token), y seleccionar entre los kernel disponibles.

- __Opción sin servidor__ (solo Python): la extensión de Jupyter también permite seleccionar como "kernel" un entorno virtual de Python. Pero para trabajar con R o MATLAB se debe hacer creando un servidor.

## Estructura de archivos

Las primeras 2 o 3 letras de las carpetas indican la asignatura asociada.

- GRC: Genética de Rasgos Complejos
- PAB: Programación y algoritmos para Bioinformática
- FV: Fisiología vegetal

