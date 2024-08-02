# author: hdescobarh

library("methods")
library("ggplot2")
library("cowplot")
library("gtable")

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
      # A_max, K > 0, R_d <= 0
      if (A_max <= 0 || K <= 0 || R_d > 0) {
        str_template <- c(
          "At least one of the parameters is invalid:\n",
          "A_max: %s\n",
          "K: %s\n",
          "R_d: %s\n",
          "A_max, K must be positive. R_d must be non-positive."
        )
        stop(
          sprintf(paste(str_template, collapse = ""), A_max, K, R_d),
          call. = FALSE
        )
      }
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
  nls_out <- rectangular_hyperbolic_nls(data, QF_col, Photo_col)
  curve_param <- coefficients(nls_out[["nls_model"]])

  # Create LightResponseCurveMM
  mm_curve <- LightResponseCurveMM(
    A_max = curve_param[["A_max"]],
    K = curve_param[["K"]], R_d = curve_param[["R_d"]]
  )

  list(
    LightResponseCurveMM = mm_curve,
    nls_model = nls_out$nls_model,
    nls_parameters_summary = nls_out$nls_parameters_summary
  )
}

#' Performs a non-linear regression to fit a rectangular hyperbolic curve
#'
#' Uses the Gauss–Newton least squares method to fit a
#' rectangular hyperbolic (Michaelis-Menten) curve
#' @param data data.frame with quantum flux and net photosynthesis data
#' @param QF_col integer indicating quantum flux column
#' @param Photo_col integer indicating net photosynthesis column
#' @return 'nls' class model
rectangular_hyperbolic_nls <- function(data, QF_col, Photo_col) {
  colnames(data)[c(QF_col, Photo_col)] <- c("QF", "Photo")

  # Find initial values
  A_max_guess <- max(data$Photo)
  A_max_half <- A_max_guess / 2
  distances <- sapply(data$Photo, function(x) abs(x - A_max_half))
  K_guess <- data$QF[distances == min(distances)]
  R_d_guess <- min(data$Photo)

  # Get better initial estimates
  initial_model <- nls(
    Photo ~ ((A_max * QF) / (K + QF)) + R_d,
    data,
    start = list(
      A_max = A_max_guess, K = K_guess, R_d = R_d_guess
    ),

    # Small QF are relevant to capture dark respiration
    # and max quantum yield; so, this is represented by 1 / QF^2,
    # QF + 1 is to avoid Inf values at QF = 0
    # In addition, I want to give a decent weight to saturating QF values
    # w(x), with a > 1 function has:
    #   lim x-> +Inf w(x) = (0.5 / a^2) + 0.00001
    #   min(w(x)) = 1x10^-5 at x = a - 1
    weights = (-log(sqrt(exp(1)) * (QF + 1) / K_guess) / (QF + 1)^2)
    + (0.5 / K_guess^2) + 0.00001
  )
  starting_values <- coefficients(initial_model)

  # Get a better model, bound R_d to have respiration (the plant is C3)
  model <- nls(
    Photo ~ ((A_max * QF) / (K + QF)) + R_d,
    data,
    start = list(
      A_max = starting_values[["A_max"]],
      K = starting_values[["K"]],
      R_d = starting_values[["R_d"]]
    ),
    control = nls.control(
      maxiter = 1000, minFactor = 1 / 2048, scaleOffset = 1
    ),
    algorithm = "port",
    upper = c(
      Inf, Inf,
      max(starting_values[["R_d"]], R_d_guess)
    ),
    lower = c(0, 0, -Inf)
  )

  # Some parameters validation
  curve_param <- coefficients(model)
  if (curve_param[["R_d"]] > 0) {
    stop(
      sprintf(
        "Regression estimated a positive R_d value (%.5f). Check the data.",
        curve_param[["R_d"]]
      ),
      call. = FALSE
    )
  }

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
    nls_model = model, nls_parameters_summary = model_parameters
  )
}

#' Get photosynthesis light-response curve parameters by each experimental unit
#'
#' @param data Data frame with QF and Photo for each sample and treatment
#' @param treatment_index Index of the column with the treatment groups names
lr_parameters_by_sample <- function(data, treatment_index) {
  all_treatments <- data.frame()
  for (t in levels(data[, treatment_index])) {
    for (s in levels(data$Sample)) {
      current_data <- data[
        (data[, treatment_index] == t) & (data$Sample == s),
      ]
      cat(
        "Treatment", t,
        "x Sample", s,
        "Starting.."
      )
      model <- light_response_curve_mm_nls(
        data = current_data,
        QF_col = 3, Photo_col = 4
      )

      curve_parameters <- model$LightResponseCurveMM$to_list()
      all_treatments <- rbind(
        all_treatments,
        c(Treatment = (t), Sample = (s), curve_parameters)
      )
      cat("Done!\n\n")
    }
  }

  all_treatments <- transform(
    all_treatments,
    Treatment = as.factor(Treatment), Sample = as.factor(Sample),
    D_r = abs(R_d)
  )

  all_treatments <- subset(all_treatments,
    select = -c(
      which(colnames(all_treatments) == "R_d")
    )
  )
  all_treatments
}

#' Get some descriptive statistics for each treatment group
lr_summary_by_treatment <- function(sample_parameters) {
  # Get statistics
  descriptive <- by(
    sample_parameters, sample_parameters[, "Treatment"],
    function(x) {
      param_names <- c("A_max", "K", "D_r", "LCP", "Phi")
      all <- vector(mode = "list", length = 2 * length(param_names))
      mean_str <- ".mean"
      std_error_str <- ".stdErr"
      names(all) <- paste(param_names,
        rep(c(mean_str, std_error_str), 5),
        sep = ""
      )
      for (parameter in param_names) {
        all[[paste(
          parameter, mean_str,
          sep = ""
        )]] <- mean(x[, parameter])
        all[[paste(
          parameter, std_error_str,
          sep = ""
        )]] <- sd(x[, parameter]) / sqrt(length(x[, parameter]))
      }
      all
    }
  )

  # add statistics to a data.frame
  descriptive_df <- data.frame()
  for (treatment in names(descriptive)) {
    descriptive_df <- rbind(
      descriptive_df,
      as.data.frame(descriptive[[treatment]], row.names = treatment)
    )
  }
  # Sort by treatments
  descriptive_df <- descriptive_df[
    order(row.names(descriptive_df), decreasing = TRUE),
  ]
  # Sort columns
  descriptive_df <- descriptive_df[
    with(descriptive_df, order(colnames(descriptive_df)))
  ]

  descriptive_df
}

#' Plot light-response curves by treatment group
#'
#' @param descriptive_df and data.frame output from lr_summary_by_treatment
#' @param max_qf numeric maximum value of quantum flux to plot
#' @param legend_title string to put in legend's title
lr_groups_plot <- function(descriptive_df, max_qf, legend_title) {
  # Generate light-response curves from estimated treatment group parameters
  theoretical_curves <- data.frame()

  for (treatment in rownames(descriptive_df)) {
    lr_curve <- LightResponseCurveMM(
      A_max = descriptive_df[treatment, "A_max.mean"],
      K = descriptive_df[treatment, "K.mean"],
      R_d = -descriptive_df[treatment, "D_r.mean"]
    )
    theoretical_curve <- lr_curve$theoretical_curve[
      lr_curve$theoretical_curve$QF <= max_qf,
    ]
    theoretical_curve$Treatment <- treatment
    theoretical_curves <- rbind(theoretical_curves, theoretical_curve)
  }

  # plot them
  ggplot(
    theoretical_curves,
    aes(x = QF, y = Photo, group = Treatment, color = Treatment)
  ) +
    geom_line() +
    geom_hline(
      yintercept = 0,
      color = "#5f5f5f", linetype = "solid"
    ) +
    labs(colour = legend_title) +
    theme(aspect.ratio = 0.5) +
    labs(
      x = expression("PPFD (" * mu * mol ~ m^{
        -2
      } ~ s^
        {
          -1
        } * ")"),
      y = expression("Fotosíntesis neta" ~ "(" * mu * mol ~ m^{
        -2
      } ~ s^
        {
          -1
        } * ")")
    ) +
    scale_y_continuous(
      breaks = sort(
        c(
          seq(
            round(min(theoretical_curves$Photo), 2),
            max(theoretical_curves$Photo),
            2
          ),
          0,
          round(max(theoretical_curves$Photo), 2)
        )
      )
    ) +
    scale_x_continuous(
      breaks = seq(
        0,
        max_qf,
        100
      )
    )
}


#' Basic boxplot including all light response parameters
all_parameters_boxplot <- function(sample_lr_parameters) {
  param_names <- colnames(sample_lr_parameters)[
    which(!colnames(sample_lr_parameters) %in% c("Treatment", "Sample"))
  ]

  plots <- vector(mode = "list", length = length(param_names))
  names(plots) <- param_names
  for (param in param_names) {
    current_plot <- ggplot(sample_lr_parameters) +
      geom_boxplot(
        aes(
          x = .data[["Treatment"]],
          y = .data[[param]],
          fill = .data[["Treatment"]]
        )
      ) +
      theme(
        legend.position = "none",
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.margin = unit(c(20, 5, 0, 0), "pt")
      )
    plots[[param]] <- current_plot
  }

  without_legend <- plot_grid(
    plotlist = plots,
    align = "hv", ncol = 3
    # labels = param_names
  )

  legend <- gtable_filter(
    ggplot_gtable(
      ggplot_build(plots[[1]] + theme(
        legend.position = "bottom",
        plot.margin = unit(c(0, 0, 0, 0), "pt")
      ))
    ), "guide-box"
  )
  plot_grid(without_legend, legend, ncol = 1, rel_heights = c(1, .2))
}
