# Taller Hidden Markov Models - README

## Repasando algunos conceptos

- Proceso estocástico:

Sea el espacio de probabilidad $(\Omega, \mathcal{F}, \mathbb{P})$,  un espacio medible $(\Xi, \mathcal{X})$ y un conjunto arbitrario $T$ denominado conjunto indice. El proceso estocástico $\{ X_t \}_{t \in T}$ es el conjunto $\{X(t) |\space t \in T\}$ t.q. $\forall t$,  $X_t(\omega): (\Omega, \mathcal{F}, \mathbb{P}) \to (\Xi, \mathcal{X})$


La dimensión de la estructura asociada a $T$ determina el número de parámetros, su cardinalidad sí el proceso es discreto ($T$ es contable) o continuo ($T$ es incontable), y el proceso es de un lado ($T$ posee un minimal) o dos lados ($T$ no tiene minimal)

- Filtration and adaptation

La filtración $\{\mathcal{F}_t\}$ es ua colección de $\sigma-\text{algebras}$ $\{\mathcal{F}_t| \space t \in T\}$ tal que $T$ es un conjunto ordenado y la colección es no decreciente; es decir, $\mathcal{F}_s \supseteq\mathcal{F}_t , \forall s>t$

> "A process being adapted to a filtration just means that, at every time, the
filtration gives us enough information to find the value of the process." (Shalizi & Kontorovich, 2010)


- Propiedad de Markov


Un proceso de estocástico $X$ de un parámetro es un proceso de Markov respecto a la filtración ${\mathcal{F}}_t$ cuando:

1. $X_t$ está adaptado a la filtración


2. Para cualquier $s > t$, $X_s {\perp \!\!\! \perp} \mathcal{F}_t|X_t$

> "The Markov property is the independence of the future from the past, given the
present. Let us be more formal." (Shalizi & Kontorovich, 2010)

Sí el proceso es condicionalmente estacionario, entonces es homogéneo en $T$.

- Probabilidades de transición

Una forma de describir un proceso de Markov es a través de sus probabilidades de transición.

$$\mathbf{P}(X_s \in B | X_t = x), \forall s>t, x\in\Xi, B \in X$$

- Matrices de transición

En el caso de un proceso de Markov discreto y homogéneo en $T$, la probabilidad de transición un paso esta dada por $\mathbf{P}(X_{n+1} = j | X_n = i) = p(i, j)$ y define una matriz de transición. La potencia de dicha matriz define la matriz de transición en $m>1$ pasos.


## Referencias

- Shalizi, C. R., & Kontorovich, A. (2010). Almost None of the Theory of Stochastic Processes. https://www.stat.cmu.edu/~cshalizi/almost-none/
- Siegrist, K. (n.d.). Markov Processes. Probability, Mathematical Statistics, and Stochastic Processes. https://stats.libretexts.org/Bookshelves/Probability_Theory/Probability_Mathematical_Statistics_and_Stochastic_Processes_(Siegrist)/16%3A_Markov_Processes
