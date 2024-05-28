#!/usr/bin/Rscript --vanilla
# author: hdescobarh

########################## ENVIRONMENT SET UP ##########################

args <- commandArgs(trailingOnly = TRUE)

# Arguments validation

if (length(args) < 4) {
  stop("Need two arguments: input_file, output_directory.\n", call. = FALSE)
}

input_file_path <- args[1]
data_unique_id <- args[2]
normalization_methods <- args[3]
output_directory_path <- args[4]


if (!file.exists(input_file_path)) {
  stop(sprintf("Input file (%s) does not exist", input_file_path))
}

if (!dir.exists(output_directory_path)) {
  dir.create(output_directory_path)
}


########################## LOAD AND VALIDATE DATA ##########################


data <- read.table(
  file = input_file_path, header = TRUE, row.names = 1
)

# Table columns name verification

pattern <- "[DM]\\d+R\\d+"

if (!all(
  grepl(pattern, colnames(data))
)) {
  stop(sprintf(
    "Invalid columns names. They must follow the format %s",
    pattern
  ))
}

# Set samples data frame

treat <- factor(substr(names(data), 1, 1))
time <- factor(substr(names(data), 2, 3))
group <- factor(paste(treat, time, sep = "_"))
samples <- data.frame(row.names = names(data), treat, time, group)

data <- DGEList(counts = data, samples = samples)

########################## ANALYSIS ##########################


############ 1. Set experiment design and contrasts

design <- model.matrix(~ 0 + group, data = data$samples)
colnames(design) <- levels(data$samples$group)

my_contrasts <- makeContrasts(
  # Inside D
  DD_12vs03 = D_12 - D_03,
  DD_24vs12 = D_24 - D_12,
  DD_48vs24 = D_48 - D_24,
  DD_24vs03 = D_24 - D_03,
  DD_48vs12 = D_48 - D_12,
  DD_48vs03 = D_48 - D_03,
  # Inside M
  MM_12vs03 = M_12 - M_03,
  MM_24vs12 = M_24 - M_12,
  MM_48vs24 = M_48 - M_24,
  MM_24vs03 = M_24 - M_03,
  MM_48vs12 = M_48 - M_12,
  MM_48vs03 = M_48 - M_03,
  # Between D and M - same time
  DM_same_03 = D_03 - M_03,
  DM_same_12 = D_12 - M_12,
  DM_same_24 = D_24 - M_24,
  DM_same_48 = D_48 - M_48,
  # Between D and M - differences between t and t+1
  DM_delta_12vs03 = (D_12 - D_03) - (M_12 - M_03),
  DM_delta_24vs12 = (D_24 - D_12) - (M_24 - M_12),
  DM_delta_48vs24 = (D_48 - D_24) - (M_48 - M_24),
  DM_delta_24vs03 = (D_24 - D_03) - (M_24 - M_03),
  DM_delta_48vs03 = (D_48 - D_03) - (M_48 - M_03),
  DM_delta_48vs12 = (D_48 - D_12) - (M_48 - M_12),
  levels = design
)

############ 2. Filtering

# keeps genes with CPM >= CPM.cutoff in MinSampleSize samples
#   such that CPM.cutoff = min.count/median(lib.size)*1e6

keep <- filterByExpr(data, group = group, min.count = 200)
data <- data[keep, , keep.lib.sizes = FALSE]

############ 3. Data Normalization & Dispersion estimation


normalization_and_dispersion <- function(
    non_normalized_data, normalization_method, design) {
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


############ 4. Model fit



model_fit <- function(data_normalized, contrasts) {
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
############ 6. differential expression tests

test_models <- function(fit, contrasts) {
  for (current_contrast in colnames(my_contrasts)) {
    # Performs genewise quasi F-tests for the given contrast
    qlf_test <- edgeR::glmQLFTest(
      fit,
      contrast = my_contrasts[, current_contrast]
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
