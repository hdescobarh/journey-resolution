# Algunas notas sobre R


## Estructuras de datos

En R todo son objetos, incluyendo variables, expresiones y funciones.

- Objetos con un solo modo (e.g. vectores, matrices) se denominana "atómicos"

```R
A <- matrix(1:4, 2,2)
length(A) # 4
# mode es el tipo más básico de los componentes fundamentales de un objeto:
# logical, numeric, complex, character or raw
mode(A) # "numeric"
class(A) # "matrix" "array"
# attributos no intrinsecos pueden verse con:
attributes(A) # $dim
```

- Los objetos recursivos pueden contener objetos de su mismo modo.

```R
L <- list(c(1,2,3), 60, "x", list(5, 8))
mode(L) # "list"
class(L) # "list"
attributes(L) # NULL
```

## Recordatorio operaciones utiles algebra lineal

Sea __A, B__ matrices cuadradas de dimensión _n_, __x__ y __b__ arrays de longitud _n_, y _e_ un escalar.

```R
outer(x, a, "*") # igual al outer product x %o% x = x x^T
A * B # producto elemento * elemento
A %*% B # producto matricial
crossprod(A, x ) # igual a t(A) %*% x pero mas eficiente
crossprod(x) # x^T x
diag(A) # diagonal de A
diag(x) # una matrix diagonal D con diag(D)=x
diag(e) # una matrix identidad I de dimensión e.
solve(A) # A^-1
solve(A, b) # retorna x, con x = A^-1 b
```
