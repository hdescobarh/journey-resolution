# author: hdescobarh

library("methods")

# Rectangular hyperbolic (Michaelis-Menten) model for light response curve
#
#' @field A_max maximum photosynthesis
#' @field K light saturation constant
#' @field R_d dark respiration
#' @field LCP light compensation point
#' @field Phi photosynthetic efficiency
#' @field linear_intercept intercept for the linear g(x) = Φx + a
#' @field linear_part_bound upper bound of quantum flux considered
#' to be in the linear part
#' @field theoretical_curve data frame with points of the theoretical curve
LightResponseCurveMM <- setRefClass(
  "LightResponseCurveMM",
  fields = list(
    A_max = "numeric", K = "numeric", R_d = "numeric",
    Phi = "numeric", LCP = "numeric",
    linear_intercept = "numeric",
    linear_part_bound = "numeric",
    theoretical_curve = "data.frame"
  ),
  methods = list(
    initialize = function(A_max, K, R_d) {
      .self$A_max <- A_max
      .self$K <- K
      .self$R_d <- R_d
      .self$LCP <- .self$inverse(0)
      .self$linear_analysis()
    },

    #' Get the net photosynthesis from the quantum flux
    #'
    #' @param quantum_flux also name photon flux, PARi in photon units
    #'  and, photosynthetic photon flux density PPFD
    net_photo = function(quantum_flux) {
      # Michaelis-Menten photosynthesis curve f(x),
      # in the sub-domain of interest, x ≥ 0, the function is defined in
      # all points and its image is in [R_d, V_max)
      if (quantum_flux < 0) {
        stop("quantum_flux must be non-negative", call. = FALSE)
      }
      (A_max * quantum_flux) / (K + quantum_flux) + R_d
    },

    #' Inverse of the Rectangular hyperbolic function
    inverse = function(photo) {
      # The inverse is only valid for A ∈ [R_d, V_max)
      # and (V_max + R_d - A) ≠ 0
      if (photo < R_d) {
        stop(
          sprintf("Net photosynthesis must be equal or greater than %f", R_d),
          call. = FALSE
        )
      } else if (photo >= R_d + A_max) {
        stop(
          sprintf(
            "Net photosynthesis must be lower than %f", R_d + A_max
          ),
          call. = FALSE
        )
      }

      # Avoid catastrophic cancellation
      a <- if (abs(photo - R_d) < 1e-5) 0 else photo - R_d

      (K * a) / (A_max - a)
    },
    derivative = function(quantum_flux) {
      if (quantum_flux < 0) {
        stop("quantum_flux must be non-negative", call. = FALSE)
      }
      # the derivative f'(x) = A_max K / (K + x)^2,
      # f'(x) is monotonically decreasing in x ≥ 0
      A_max * K / (K + quantum_flux)^2
    },
    linear_analysis = function() {
      # Generate the curve theoretical curve
      qf_values <- seq(
        0, inverse(A_max + R_d - 0.5),
        by = 0.2
      )
      .self$theoretical_curve <- data.frame(
        QF = qf_values, Photo = sapply(qf_values, .self$net_photo)
      )

      # This curve derivative is monotonically decreasing,
      # we only need to find the cluster with the highest derivatives
      derivatives <- sapply(theoretical_curve$QF, .self$derivative)
      clustering <- kmeans(derivatives, 2)
      target_cluster <- match(max(clustering$centers), clustering$centers)
      selected_items <- clustering$cluster == target_cluster

      # fit the found linear section with a linear regression
      linear_coefficients <- coef(
        lm(Photo ~ QF, theoretical_curve[selected_items, ])
      )

      # store results
      .self$linear_intercept <- linear_coefficients[["(Intercept)"]]
      .self$Phi <- linear_coefficients[["QF"]]
      .self$linear_part_bound <- theoretical_curve[
        match(
          max(theoretical_curve[selected_items, "QF"]),
          theoretical_curve[selected_items, "QF"]
        ), "QF"
      ]
    },
    show = function() {
      template <- c(
        "Maximum photosynthesis: %g\n",
        "Light saturation constant: %g\n",
        "Dark respiration: %g\n",
        "Light compensation point: %g\n",
        "Photosynthetic efficiency Φ: %g"
      )

      cat(sprintf(
        paste(template, collapse = ""),
        .self$A_max, .self$K, .self$R_d, .self$LCP, .self$Phi
      ))
    },
    to_list = function() {
      list(
        A_max = .self$A_max, K = .self$K, R_d = .self$R_d,
        LCP = .self$LCP, Phi = .self$Phi
      )
    }
  )
)

#' Creates a light response curve
#'
#' Creates a response rectangular hyperbolic (Michaelis-Menten) curve
#' using a non-linear least squares regression
#' @param data data.frame with quantum flux and net photosynthesis data
#' @param QF_col integer indicating quantum flux column
#' @param Photo_col integer indicating net photosynthesis column
light_response_curve_mm_nls <- function(data, QF_col, Photo_col) {
  colnames(data)[c(QF_col, Photo_col)] <- c("QF", "Photo")

  # Find initial values
  A_max <- max(data$Photo)
  A_max_half <- A_max / 2
  distances <- sapply(data$Photo, function(x) abs(x - A_max_half))
  K <- data$QF[distances == min(distances)]
  R_d <- min(data$Photo)

  # Perform regression
  model <- nls(
    Photo ~ ((A_max * QF) / (K + QF)) + R_d,
    data,
    start = list(
      A_max = A_max, K = K, R_d = R_d
    ),
    control = nls.control(minFactor = 1 / 2048),
  )

  # Some parameters validation
  curve_param <- coefficients(model)
  if (curve_param[["R_d"]] > 0) {
    stop(
      sprintf(
        "R_d value is non-negative: %.5f",
        curve_param[["R_d"]]
      ),
      call. = FALSE
    )
  }
  # Create LightResponseCurveMM
  mm_curve <- LightResponseCurveMM(
    A_max = curve_param[["A_max"]],
    K = curve_param[["K"]], R_d = curve_param[["R_d"]]
  )

  # Describe model
  model_summary <- summary(model)
  level <- 0.95
  confidence_intervals <- confint(model, level = level)
  model_parameters <- cbind(
    model_summary$coefficients, confidence_intervals
  )
  colnames(model_parameters) <- c(
    "estimate", "std_error", "statistic", "p_value",
    paste("conf_low_", level * 100, sep = ""),
    paste("conf_high_", level * 100, sep = "")
  )

  list(
    LightResponseCurveMM = mm_curve,
    nls_model = model, nls_parameters_summary = model_parameters
  )
}
