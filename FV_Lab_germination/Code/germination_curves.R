# author: hdescobarh

########## Environment set up ##########

missing_packages <- character()
for (package in c(
  "ggplot2", "cowplot", "scales", "gtable",
  "germinationmetrics"
)) {
  if (!require(package, quietly = TRUE, character.only = TRUE)) {
    missing_packages <- append(missing_packages, package)
  }
}

if (length(missing_packages) > 0) {
  stop(
    sprintf(
      "Missing the following packages: %s",
      paste(missing_packages, collapse = ", ")
    ),
    call. = FALSE
  )
}

# plots configuration

# ggplot configuration

theme_set(theme_bw(base_size = 18, base_line_size = 1) +
  theme(
    axis.text = element_text(size = 16),
    text = element_text(size = 18),
    legend.title = element_text(size = 19),
    legend.text = element_text(size = 18)
  ))

plot_base_width <- 15
options(repr.plot.width = plot_base_width)




#' Plots multiple four-parameter hill function fitted cumulative
#' germination curves filtered by a Treatment column
#'
#' @param fits Output from germinationmetrics::FourPHFfit.bulk.
#' must have a Treatment column
#' @param treatment A single treatment
plot_by_treatment <- function(fits, treatment) {
  cumulative_plot <- plot(
    fits[fits$Treatment == treatment, ],
    group.col = "Replicate", rog = FALSE, show.points = TRUE
  ) +
    theme(
      legend.position = "none",
      plot.margin = unit(c(25, 15, 5, 5), "pt"),
      axis.text = element_text(size = 16),
      text = element_text(size = 18)
    )

  density_plot <- plot(
    fits[fits$Treatment == treatment, ],
    group.col = "Replicate", rog = TRUE, annotate = "t50.germ"
  ) +
    theme(
      axis.title.y = element_blank(),
      plot.margin = unit(c(25, 5, 5, 0), "pt"),
      axis.text = element_text(size = 16),
      text = element_text(size = 18)
    )

  row_plot <- plot_grid(
    cumulative_plot, density_plot,
    labels = c("Cumulative", "Density"), ncol = 2
  )

  title <- ggdraw() +
    draw_label(
      sprintf("Tratamiento %s", treatment),
      fontface = "bold",
      x = 0,
      hjust = 0
    ) +
    theme(
      plot.margin = margin(0, 0, 0, 7)
    )

  final_plot <- plot_grid(
    title, row_plot,
    ncol = 1,
    rel_heights = c(0.1, 1)
  )

  final_plot
}

#' Get parameters of interest and cumulative percent time interval counts
#' from fits
#'
#' @param fits Output from germinationmetrics::FourPHFfit.bulk.
#' @param param_names Character vector of curve parameters to keep
#' @param time_interval_names Character vector of names of each time interval
#' @param time_interval Numeric vector of values of time intervals
#' @param cumulative_prefix  prefix for name of cumulative percent at each time
#'
get_from_fits <- function(
    fits, param_names = c("a", "b", "c", "y0"), time_interval_names,
    time_intervals, cumulative_prefix = "C") {
  if (length(time_interval_names) != length(time_intervals)) {
    stop("time_interval_names and time_intervals must have the same length")
  }

  if (!all(c("a", "b", "c", "y0") %in% param_names)) {
    stop("param_names must contain a, b, c and y0 parameters")
  }

  # Get cumulative percent
  cumulative_percent <- apply(
    fits[, c(time_interval_names, "Total_Seeds")], 1,
    function(x) {
      output <- c()
      for (i in seq_along(time_interval_names)) {
        percent_germination <- 100 * sum(x[1:i]) / x[["Total_Seeds"]]
        output <- c(output, percent_germination)
      }
      output
    }
  )
  cumulative_percent <- t(cumulative_percent)
  colnames(cumulative_percent) <- paste(
    cumulative_prefix, time_intervals,
    sep = ""
  )

  # Recover from parameters to keep
  final_df <- fits[c("Treatment", "Replicate", param_names)]
  for (param in param_names) {
    final_df[[param]] <- as.numeric(final_df[[param]])
  }

  # Combine
  final_df <- cbind(final_df, cumulative_percent)
  final_df
}

#' Gets Mean and Standard Error by Treatment and column
#'
#' @param to_summarize data.frame
#' @param cols_to_exclude character vector with names of columns to ignore
#' @param mean_suffix  suffix for name of column Mean
#' @param std_err_suffix suffix for name of column Standard Error
summarize_fits <- function(
    to_summarize, cols_to_exclude,
    mean_suffix = ".Mean", std_err_suffix = ".StdError") {
  col_names <- names(
    to_summarize
  )[!(names(to_summarize) %in% cols_to_exclude)]

  fit_summary <- data.frame()

  for (treatment in levels(to_summarize$Treatment)) {
    # Prepare the list to store statistics
    treatment_summary <- list()

    # Get treatment rows
    treatment_sub_df <- to_summarize[to_summarize == treatment, ]
    treatment_sample_size <- nrow(treatment_sub_df)

    for (current_col in col_names) {
      mean_key <- paste(current_col, mean_suffix, sep = "")
      treatment_summary[[mean_key]] <- mean(treatment_sub_df[[current_col]])

      std_err_key <- paste(current_col, std_err_suffix, sep = "")
      treatment_summary[[std_err_key]] <- sd(
        treatment_sub_df[[current_col]]
      ) / sqrt(treatment_sample_size)
    }

    treatment_summary_row <- cbind(
      data.frame(Treatment = treatment, stringsAsFactors = TRUE),
      as.data.frame(treatment_summary)
    )

    fit_summary <- rbind(fit_summary, treatment_summary_row)
    rownames(fit_summary) <- fit_summary[, 1]
  }
  fit_summary
}

#' Generate points to draw a four parameters Hill function
#'
#' @param max_time upper bound x to plot
#' @param a asymptote
#' @param b parameter controlling the shape and steepness of the curve
#' @param c time required for 50% of viable seeds to germinate
#' @param y0 intercept on the y axis
#' @param time_step get a point each time_step
get_hill_points <- function(max_time, a, b, c, y0, time_step) {
  xs <- seq(1, max_time, time_step)
  ys <- sapply(
    xs,
    function(x, a, b, c, y0) {
      x_power_b <- x^b
      y0 + (a * x_power_b) / (c^b + x_power_b)
    },
    a = a, b = b, c = c, y0 = y0
  )
  data.frame(time = xs, germination_percent = ys)
}

#' From the output of summarize_fits generate a list of data.frame
#' containing the points to plot
#'
#' @param fits_summary
#' @param max_time upper bound x to plot
#' @param time_step get a point each time_step
#' @param mean_suffix  suffix for name of column Mean
#' @param std_err_suffix suffix for name of column Standard Error
generate_hill_curves <- function(
    fits_summary, max_time, time_step = 0.1,
    mean_suffix = ".Mean", std_err_suffix = ".StdError") {
  curves_df <- data.frame()
  for (treatment in levels(fits_summary$Treatment)) {
    current_curve <- get_hill_points(
      max_time = max_time,
      a = fits_summary[treatment, paste("a", mean_suffix, sep = "")],
      b = fits_summary[treatment, paste("b", mean_suffix, sep = "")],
      c = fits_summary[treatment, paste("c", mean_suffix, sep = "")],
      y0 = fits_summary[treatment, paste("y0", mean_suffix, sep = "")],
      time_step = time_step
    )

    curve <- cbind(
      data.frame(
        Treatment = rep(treatment, nrow(current_curve)),
        stringsAsFactors = TRUE
      ),
      current_curve
    )

    curves_df <- rbind(curves_df, curve)
  }
  curves_df
}

#' From a summary of get_from_fits take cumulative percent observations
#' and their Standard Errors
#'
#' @param fits_summary
#' @param time_interval Numeric vector of values of time intervals
#' @param cumulative_prefix  prefix for name of cumulative percent at each time
#' @param mean_suffix  suffix for name of column Mean
#' @param std_err_suffix suffix for name of column Standard Error
extract_observations <- function(
    fits_summary,
    time_intervals,
    cumulative_prefix = "C",
    mean_suffix = ".Mean", std_err_suffix = ".StdError") {
  mean_keys <- paste(
    cumulative_prefix, time_intervals, mean_suffix,
    sep = ""
  )
  std_err_keys <- paste(
    cumulative_prefix, time_intervals, std_err_suffix,
    sep = ""
  )
  observations_df <- data.frame()
  for (treatment in levels(fits_summary$Treatment)) {
    current_obs <- data.frame(
      Treatment = rep(treatment, length(time_intervals)),
      time = time_intervals,
      germination_percent = unname(t(fits_summary[treatment, mean_keys])[, 1]),
      stdError = unname(t(fits_summary[treatment, std_err_keys])[, 1]),
      stringsAsFactors = TRUE
    )

    observations_df <- rbind(observations_df, current_obs)
  }
  observations_df
}

#' Generate points to draw the derivative of the four parameters Hill function
#'
#' @param max_time upper bound x to plot
#' @param a asymptote
#' @param b parameter controlling the shape and steepness of the curve
#' @param c time required for 50% of viable seeds to germinate
#' @param y0 intercept on the y axis
#' @param time_step get a point each time_step
get_derivative_hill_points <- function(max_time, a, b, c, y0, time_step) {
  xs <- seq(1, max_time, time_step)
  ys <- sapply(
    xs,
    function(x, a, b, c) {
      c_power_b <- c^b
      (a * b * c_power_b * x^(b - 1)) / (c_power_b + x^b)^2
    },
    a = a, b = b, c = c
  )
  data.frame(time = xs, derivative = ys)
}

#' From the output of summarize_fits generate a list of data.frame
#' containing the points to plot the derivative of the
#' Hill's four-parameter curve. Be aware that values are percentage values.
#'
#' @param fits_summary
#' @param max_time upper bound x to plot
#' @param time_step get a point each time_step
#' @param mean_suffix  suffix for name of column Mean
#' @param std_err_suffix suffix for name of column Standard Error
generate_derivative_curves <- function(
    fits_summary, max_time, time_step = 0.1,
    mean_suffix = ".Mean", std_err_suffix = ".StdError") {
  curves_df <- data.frame()
  for (treatment in levels(fits_summary$Treatment)) {
    current_curve <- get_derivative_hill_points(
      max_time = max_time,
      a = fits_summary[treatment, paste("a", mean_suffix, sep = "")],
      b = fits_summary[treatment, paste("b", mean_suffix, sep = "")],
      c = fits_summary[treatment, paste("c", mean_suffix, sep = "")],
      time_step = time_step
    )

    curve <- cbind(
      data.frame(
        Treatment = rep(treatment, nrow(current_curve)),
        stringsAsFactors = TRUE
      ),
      current_curve
    )

    curves_df <- rbind(curves_df, curve)
  }
  curves_df
}

#' Plot the cumulative percent germination curves
#'
#' @param curves_df data.frame generated by generate_hill_curves
#' @param observations_df data.frame generated by extract_observations
#' @param treatment_colors named vector with the color by treatment group
plot_cumulative <- function(curves_df, observations_df, treatment_colors) {
  must_names <- c("Treatment", "time", "germination_percent")
  must_names2 <- c(must_names, "stdError")
  if (!all(must_names %in% names(curves_df))) {
    stop(
      paste(
        "curves_df must have the names",
        paste(must_names, collapse = ", ")
      )
    )
  }

  if (!all(must_names2 %in% names(observations_df))) {
    stop(
      paste(
        "observations_df must have the names",
        paste(must_names2, collapse = ", ")
      )
    )
  }

  x_min <- min(curves_df$time)
  x_max <- max(curves_df$time)
  x_step <- floor((x_max - x_min) / 5)

  ggplot(
    data = curves_df,
    mapping = aes(
      x = time, y = germination_percent, group = Treatment, color = Treatment
    )
  ) +
    geom_line(linewidth = 1.1) +
    geom_point(
      data = observations_df,
      size = 1.8,
      mapping = aes(
        x = time, y = germination_percent, group = Treatment
      )
    ) +
    geom_errorbar(
      data = observations_df, width = 0.3, alpha = 0.8,
      aes(
        ymin = germination_percent - stdError,
        ymax = germination_percent + stdError
      ),
    ) +
    labs(
      x = expression("Tiempo" ~ "(Días)"),
      y = expression("Germinación" ~ "(%)"),
      colour = expression("Tratamiento")
    ) +
    scale_x_continuous(breaks = seq(x_min, x_max, x_step)) +
    scale_y_continuous(breaks = seq(0, 100, 10)) +
    scale_colour_manual(values = treatment_colors)
}


#' Plot the density of probability of germination
#' @param derivative_df data.frame generated by generate_derivative_curves
#' @param treatment_colors named vector with the color by treatment group
#' @param half_activation_df a data.frame with treatment half activation values
plot_density <- function(derivative_df, half_activation_df, treatment_colors) {
  must_names <- c("Treatment", "time", "density")
  must_names2 <- c("Treatment", "half_activation")

  if (!all(must_names %in% names(derivative_df))) {
    stop(
      paste(
        "derivative_df must have the names",
        paste(must_names, collapse = ", ")
      )
    )
  }

  if (!all(must_names2 %in% names(half_activation_df))) {
    stop(
      paste(
        "half_activation_df must have the names",
        paste(must_names2, collapse = ", ")
      )
    )
  }

  # choose a good x interval to plot
  non_zero_index <- which(derivative_df$derivative > 0.01)
  left_tail_upper_bound <- min(derivative_df[non_zero_index, "time"])
  right_tail_lower_bound <- max(derivative_df[non_zero_index, "time"])
  rho <- 0.90
  start_time <- floor(left_tail_upper_bound * rho)
  end_time <- ceiling(
    right_tail_lower_bound * (1 - rho) + max(derivative_df$time) * rho
  )
  filtered_time <- which(
    derivative_df$time >= start_time &
      derivative_df$time <= end_time
  )

  x_min <- floor(start_time)
  x_max <- ceiling(end_time)
  x_step <- floor((x_max - x_min) / 8)

  y_min <- 0
  y_max <- max(derivative_df$density)

  ggplot(
    data = derivative_df[filtered_time, ],
    mapping = aes(
      x = time, y = density, group = Treatment, color = Treatment
    )
  ) +
    geom_line(linewidth = 1.1) +
    geom_vline(
      data = half_activation_df, linetype = "dashed",
      linewidth = 1.08, alpha = 0.6,
      mapping = aes(
        xintercept = half_activation, group = Treatment, color = Treatment
      )
    ) +
    labs(
      x = expression("Tiempo" ~ "(Días)"),
      y = expression("FDP de germinación"),
      colour = expression("Tratamiento")
    ) +
    scale_x_continuous(breaks = seq(x_min, x_max, x_step)) +
    scale_y_continuous(
      breaks = signif(seq(y_min, y_max, length.out = 6), 2),
      labels = label_comma(big.mark = ".", decimal.mark = ",")
    ) +
    scale_colour_manual(values = treatment_colors)
}
