# Algunas notas sobre Perl


## Primitives

- $ scalars: str, int, float.
- @ arrays.
- % hashes.
- $ references ([perlreftut](https://perldoc.perl.org/perlreftut)).

## Variables

### Declaration

```perl
my $scalar_var = "str_value";
my @array_var = ("val1", 2, 3.14); # $array_var[index]
my %hash_var_way1 = ("key1", "scalar_val1", "key2", "scalar_val2"); # $hash_var{key}
my %hash_var_way2 = ( "key1"  => "scalar_val1", "key2" => "scalar_val2");
my $array_named_reference = \@array_var; # @{$aref}, ${$aref}[index] or $aref->[index],
my $array_anonymus_reference = ["val1", 2, 3.14]; # $aref[row]->[col] or $aref[row][col]
my $hash_named_reference = \%hash_var; # %{$href}, ${$href}{key} or $href->{key}
my $hash_anonymus_reference = { "key1"  => "scalar_val1", "key2" => "scalar_val2"};
```

Know more with [perldata](https://perldoc.perl.org/perldata)

### Special variables

- $_ : default variable used as argument for some functions, subroutines and looping. 
- $#array_var : last index of of @array_var.
- @ARGV : script's command line arguments.
- %ENV : contains environment variables

Know more with [perlvar](https://perldoc.perl.org/perlvar).

## Control structures

https://perldoc.perl.org/perlintro#Conditional-and-looping-constructs

- if-elsif-else
- unless
- for
- foreach
- while
- until
- switch-case


## Bibliografía


- [Beginning Perl](https://learn.perl.org/books/beginning-perl/)
- [Modern Perl](https://www.onyxneon.com/books/modern_perl/index.html)
- [Perl Documentation](https://perldoc.perl.org/)
