# author: hdescobarh

missing_packages <- character()
for (package in c(
  "edgeR", "limma"
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

normalization_and_dispersion <- function(
    non_normalized_data, normalization_method, design, output_directory_path) {
  # Calculate scaling factors for transforming
  #   library sizes to effective library sizes
  data_normalized <- edgeR::normLibSizes(
    non_normalized_data,
    method = normalization_method
  )

  # Estimates Common, Trended and Tagwise NB dispersions
  data_normalized <- edgeR::estimateDisp(data_normalized, design)


  pdf(
    file = sprintf(
      "%s/data_exploration.pdf",
      output_directory_path
    )
  )
  limma::plotMDS(
    data_normalized,
    col = as.numeric(data_normalized$samples$treat)
  )
  edgeR::plotMeanVar(data_normalized, show.tagwise.vars = TRUE, NBline = TRUE)
  edgeR::plotBCV(data_normalized)
  dev.off()

  data_normalized
}

model_fit <- function(
    data_normalized, output_directory_path) {
  # The QL F-test's statistic reflects the uncertainty in the dispersion
  #   estimation for each gene and gives more control over type I error rate.
  fit <- edgeR::glmQLFit(data_normalized)

  # get cpm log2 values using the fitted coefficients
  log_cpm <- edgeR::cpm(fit, log = TRUE)

  pdf(
    file = sprintf(
      "%s/dispersion_and_clustering.pdf",
      output_directory_path
    )
  )
  edgeR::plotQLDisp(fit)

  # Heat map
  # The documentation suggest to use "moderated log-counts-per-million"
  # for drawing a head map of individual RNA-seq samples
  heatmap(log_cpm, scale = "row", col = heat.colors(256))
  dev.off()

  fit
}

test_models <- function(
    fit, contrasts, output_directory_path) {
  for (current_contrast in colnames(contrasts)) {
    # Performs genewise quasi F-tests for the given contrast
    qlf_test <- edgeR::glmQLFTest(
      fit,
      contrast = contrasts[, current_contrast]
    )

    # Table rows =min(n, number of genes with
    #   adjusted p-value <= cutoff p-value), the default p-value cutoff is 1!!!
    top <- edgeR::topTags(qlf_test, n = Inf)
    # Save top table
    top_table_file_name <- sprintf(
      "%s/top_DE_%s.tsv",
      output_directory_path,
      current_contrast
    )
    write.table(
      top,
      file = top_table_file_name, append = FALSE, quote = FALSE, sep = "\t"
    )

    # Make a mean-difference plot with smearing of points with very low counts
    # Highlight top FDR < 0.05
    fdr_threshold <- 0.05
    top_selected_ids <- rownames(top$table)[top$table$FDR < fdr_threshold]

    smear_file_name <- sprintf(
      "%s/smear_MDplot_%s.pdf",
      output_directory_path,
      current_contrast
    )
    pdf(file = smear_file_name)
    edgeR::plotSmear(qlf_test, de.tags = top_selected_ids)
    abline(
      h = c(-0.5, 0, 0.5), col = c("#0459ad", "red", "#0459ad"), lty = 2
    )
    dev.off()
  }
}
