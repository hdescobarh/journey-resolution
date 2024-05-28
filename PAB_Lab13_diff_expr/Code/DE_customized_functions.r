# author: hdescobarh

missing_packages <- character()
for (package in c(
  "edgeR"
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

  edgeR::plotMDS(
    data_normalized,
    col = as.numeric(data_normalized$samples$treat)
  )
  # Estimates Common, Trended and Tagwise NB dispersions
  data_normalized <- edgeR::estimateDisp(data_normalized, design)
  edgeR::plotBCV(data_normalized)
  edgeR::plotMeanVar(data_normalized, show.tagwise.vars = TRUE, NBline = TRUE)
  data_normalized
}

model_fit <- function(
    data_normalized, normalization_method, contrasts, output_directory_path) {
  # The QL F-test's statistic reflects the uncertainty in the dispersion
  #   estimation for each gene and gives more control over type I error rate.

  fit <- edgeR::glmQLFit(data_normalized)
  edgeR::plotQLDisp(fit)

  # Heat map
  # The documentation suggest to use "moderated log-counts-per-million"
  # for drawing a head map of individual RNA-seq samples

  # get cpm log2 values using the fitted coefficients
  log_cpm <- edgeR::cpm(fit, log = TRUE)
  heatmap(log_cpm, scale = "row", col = heat.colors(256))

  fit
}

test_models <- function(
    fit, normalization_method, contrasts, output_directory_path) {
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
    top_selected_ids <- top$table[top$table$FDR < fdr_threshold, 1]

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
