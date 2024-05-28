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

# Libraries validation

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
  data_normalized <- normLibSizes(
    non_normalized_data,
    method = normalization_method
  )

  plotMDS(data_normalized, col = as.numeric(data_normalized$samples$treat))
  # Estimates Common, Trended and Tagwise NB dispersions
  data_normalized <- estimateDisp(data_normalized, design)
  plotBCV(data_normalized)
  plotMeanVar(data_normalized, show.tagwise.vars = TRUE, NBline = TRUE)
  data_normalized
}


############ 4. Model fit



model_fit <- function(data_normalized, contrasts) {
  # The QL F-test's statistic reflects the uncertainty in the dispersion
  #   estimation for each gene and gives more control over type I error rate.

  fit <- glmQLFit(data_normalized)
  plotQLDisp(fit)

  # Heat map
  # The documentation suggest to use "moderated log-counts-per-million"
  # for drawing a head map of individual RNA-seq samples


  # get cpm log2 values using the fitted coefficients
  log_cpm <- cpm(fit, log = TRUE)
  heatmap(log_cpm, scale = "row", col = heat.colors(256))

  fit
}
############ 6. differential expression tests