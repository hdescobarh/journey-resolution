#!/bin/bash
# Hans D. Escobar H.

MIN_LENGHT=4
printf "Por favor, ingrese su nombre de usuario:\n> "
read -r MYNAME
if [ "$(echo -n "$MYNAME" | wc -m)" -ge $MIN_LENGHT ]; then
    printf "Hola %s :)\n" "$MYNAME"
else
    printf "Error: el nombre de usuario debe tener almenos %s caracteres.\n" $MIN_LENGHT
fi
