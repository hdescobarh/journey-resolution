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

- Es posible que toque instalar algunos paquetes necesarios para compilar código. Para debian based:

```bash
sudo apt-get install build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev
```

- Este paquete es necesario para usar las funcionalidades para R de VS Code

```R
update.packages(ask=FALSE) # puede requerir sudo para actualizar algunos paquetes
install.packages("languageserver", dependencies=TRUE)
```

- Kernel de R para Jupyter. Recordar tener instalado Jupyter en el entorno de Python

```R
install.packages('IRkernel')
IRkernel::installspec()
```

### Perl

- Configurando cpan (para instalar en el home sí no se tiene privilegios)

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
sudo cpan App::cpanminus
```

- Instalando servidor de lenguaje (para usar richterger.perl)

Dependencias en Debian based

```bash
sudo apt install libanyevent-perl libclass-refresh-perl libcompiler-lexer-perl libdata-dump-perl libio-aio-perl libjson-perl libmoose-perl libpadwalker-perl libscalar-list-utils-perlx libcoro-perl
```

```bash
sudo cpanm Perl::LanguageServer
```
- En caso de tener problemas con Perl::ServerLanguage, una opción es usar bscan.perlnavigator

Para algunas funcionalidades requiere Perl::Critic

```
sudo cpanm Perl::Critic
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

- GRC: Genética de Rasgos Complejos (2029263), 2024-01, Johana Carolina Soto Sedano
- PAB: Programación y algoritmos para Bioinformática (2025439), 2024-01, Clara Isabel Bermudez Santana
- FV: Fisiología vegetal (2017538), 2024-01, Hernán Mauricio Romero

## Conexión a través de un proxy

[SSH to remote hosts through a proxy or bastion with ProxyJump](https://www.redhat.com/sysadmin/ssh-proxy-bastion-proxyjump)


- Con ProxyJump

```bash
ssh -J <user_name>@<jump_server:port> <remote_server:port>
```

- Con ProxyCommand

```bash
ssh -o ProxyCommand="ssh -W %h:%p <user_name>@<jump_server>" <remote_server>
```

- Configurando OpenSSH

```
### Jump server
Host <jump_nickname>
    HostName <jump_server>
    User <user_name>
    IdentityFile ~/.ssh/id_rsa
### Remote host
Host <remote_nickname>
    HostName <remote_server>c
    ProxyJump <jump_nickname>
```
