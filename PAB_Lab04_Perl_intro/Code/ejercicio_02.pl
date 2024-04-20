#!/usr/bin/perl
# author: hdescobarh

use strict;
use warnings;

# Dada una secuencia X seleccionar aleatoriamente una posición asignado aleatoriamente
# un nucleotide diferente al nucleotide existe en la posición escogida sobre X

if ( @ARGV != 3 ) {
    printf "Número de argumentos (%u) no valido. Los argumentos esperados son:
        1. Secuencia de DNA
        2. Probabilidad de transversión
        3. Probabilidad de transición\n", scalar @ARGV;
    exit;
}

printf "%s\n", one_step_substitution(@ARGV);

# La solución está pensada para secuencias de DNA


# Recibe una cadena representando bases de DNA y con una distribución
# uniforme selecciona una posición. Retorna un array formado por (indice, base)
sub sample_position_uniform {
    die "The sequence cannot be empty." unless ( @_ > 0 );
    my ($dna_sequence) = @_;    # !!!! Paréntesis necesarios (destructuring),
        # sí no crea un contexto escalar y asigna la longitud

# Automatically calls srand unless srand has already been called. (https://perldoc.perl.org/functions/rand)
    my $index      = int( rand( length($dna_sequence) ) );
    my $nucleotide = substr( $dna_sequence, $index, 1 );
    return $index, $nucleotide;
}

# Muestra un nucleótido diferente al ingresado basado en las probabilidades de transversión y transición (deben sumar 1).
# El modelo asume distribución uniforme dentro de las transversiones
sub two_parameter_substitution {
    my ( $nucleotide, $transversion_p, $transition_p ) = @_;
    $nucleotide = uc($nucleotide);

    # Validations
    die "Transition and transversion probabilities must sum 1.0"
      unless ( $transversion_p + $transition_p == 1 );

    die "Nucleotide must be a single valid DNA base (G, C, A, T)"
      unless ( $nucleotide =~ /^(G|A|C|T)$/ );

# Generate map. First index correspond to a transition, the later to transversions
    my %substitution_mappings = (
        "G" => [ "A", "C", "T" ],
        "A" => [ "G", "C", "T" ],
        "C" => [ "T", "G", "A" ],
        "T" => [ "C", "G", "A" ],
    );

    # Sample from distribution
    my $cut_value = rand();
    my $next_nucleotide;

    if ( $cut_value <= $transition_p ) {
        $next_nucleotide = $substitution_mappings{$nucleotide}->[0];
    }
    elsif ( $cut_value <= $transition_p + $transversion_p / 2 ) {
        $next_nucleotide = $substitution_mappings{$nucleotide}->[1];
    }
    else {
        $next_nucleotide = $substitution_mappings{$nucleotide}->[2];
    }

    return $next_nucleotide;
}

# Toma una cadena de DNA y realiza una única mutación por sustitución bajo un modelo de sustitución
# de dos parámetros: Probabilidad transversión y transición.
sub one_step_substitution {
    my ( $dna_sequence, $transversion_p, $transition_p ) = @_;

    # De forma uniforme muestra lugar de sustitución
    my ( $index, $nucleotide ) = sample_position_uniform($dna_sequence);

    # Con el modelo de sustitución muestra la mutación
    my $next_nucleotide =
      two_parameter_substitution( $nucleotide, $transversion_p, $transition_p );

    # Aplica los cambios en el lugar muestreado
    substr( $dna_sequence, $index, 1, $next_nucleotide );
    return $dna_sequence;
}
