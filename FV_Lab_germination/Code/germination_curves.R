# author: hdescobarh

########## Environment set up ##########

missing_packages <- character()
for (package in c(
  "ggplot2", "cowplot",
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

theme_set(theme_bw() +
  theme(
    axis.text = element_text(size = 16),
    text = element_text(size = 18)
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
