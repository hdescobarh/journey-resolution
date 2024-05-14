# Calcula varianza de una sola variable
variance_univar_naive <- function(data_vector, sample = TRUE) {
  divisor <- length(data_vector)
  if (sample) {
    divisor <- divisor - 1
  }
  square_difference <- (data_vector - sum(data_vector) / length(data_vector))^2
  sum(square_difference) / divisor
}

# Recibe una matrix nxp con n observaciones y p variables
variance_multivar_naive <- function(data_matrix, sample = TRUE) {
  divisor <- dim(data_matrix)[1]
  if (sample) {
    divisor <- divisor - 1
  }
  # MARGIN = 2 indica que se realiza sobre las columnas
  centroid <- apply(data_matrix, MARGIN = 2, FUN = sum) / dim(data_matrix)[1]
  # X_nxp - 1_nxp diag(C_p)
  centralized_data <- data_matrix - matrix(
    centroid, dim(data_matrix)[1], dim(data_matrix)[2],
    byrow = TRUE
  )
  crossprod(centralized_data) / divisor
}

variance_naive <- function(data, sample = TRUE) {
  if (is.vector(data)) {
    variance_univar_naive(data, sample)
  } else if (is.matrix(data)) {
    variance_multivar_naive(data, sample)
  } else {
    stop("Data must be a vector or matrix")
  }
}

example_vector <- c(0.15, 0.80, 0.16, 0.09, 0.55)



example_dataframe <- data.frame(
  var_a = c(18, 19, 21, 21, 28),
  var_b = c(0.15, 0.80, 0.16, 0.09, 0.55),
  var_c = c(261, 335, 574, 593, 123),
  var_d = c("x", "z", "x", "x", "z")
)

tolerance <- 1E-15
pass_vector <- variance_naive(
  as.matrix(as.vector(example_dataframe[, 2]))
) - var(as.vector(example_dataframe[, 2])) <= tolerance

pass_matrix <- variance_naive(
  as.matrix(example_dataframe[, 1:3])
) - var(as.matrix(example_dataframe[, 1:3])) <= tolerance
