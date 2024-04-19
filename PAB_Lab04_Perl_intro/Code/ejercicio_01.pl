#!/usr/bin/perl
# author: hdescobarh

# suma
use strict;
use warnings;

if ( @ARGV != 2 ) {
    printf
      "Número de argumentos no valido. Se esperan 2 y se ingresaron %u.\n",
      scalar @ARGV;
    exit;
}

my ( $first, $second ) = @ARGV;
my $suma;

# crea un scope en el que sí uno de los valores no es numérico, peta
{
    use warnings FATAL => 'numeric';
    $suma = $first + $second;
}

print "'$first' + '$second' = '$suma'\n"
