#!/usr/bin/Rscript --vanilla
# author: hdescobarh

########################## ENVIRONMENT SET UP ##########################

args <- commandArgs(trailingOnly = TRUE)
valid_methods <- c("TMM", "TMMwsp", "RLE", "upperquartile", "none")

# Arguments validation

if (length(args) < 3) {
  stop(
    sprintf(
      "Needs three arguments:
    - input_file_path: the expression counts file
    - normalization_methods: a list of comma separated values from
        %s.
    - output_directory_path\n",
      paste(valid_methods, collapse = ", ")
    ),
    call. = FALSE
  )
}

input_file_path <- args[1]
normalization_methods <- unlist(strsplit(args[2], split = "\\s*,\\s*"))
output_directory_path <- args[3]


if (!file.exists(input_file_path)) {
  stop(sprintf("Input file (%s) does not exist", input_file_path),
    call. = FALSE
  )
}

if (!dir.exists(output_directory_path)) {
  dir.create(output_directory_path)
}

if (!all(normalization_methods %in% valid_methods)) {
  stop(
    sprintf(
      "normalization_methods must be a string of comma separated valid values.
      Valid methods are:\n%s",
      paste("\t-", valid_methods, collapse = "\n")
    ),
    call. = FALSE
  )
}

# Load customized routines
source("DE_customized_functions.r")

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


############ Set experiment design and contrasts

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

############ Filtering

# keeps genes with CPM >= CPM.cutoff in MinSampleSize samples
#   such that CPM.cutoff = min.count/median(lib.size)*1e6

keep <- filterByExpr(data, group = group, min.count = 200)
data <- data[keep, , keep.lib.sizes = FALSE]

for (current_method in normalization_methods) {
  current_output_dir <- paste(
    output_directory_path, current_method,
    sep = "/"
  )

  if (!dir.exists(current_output_dir)) {
    dir.create(current_output_dir)
  }

  current_normalized <- normalization_and_dispersion(
    non_normalized_data = data,
    normalization_method = current_method,
    design = design,
    output_directory_path = current_output_dir
  )

  current_fit <- model_fit(
    data_normalized = current_normalized,
    output_directory_path = current_output_dir
  )

  test_models(
    current_fit,
    contrasts = my_contrasts,
    output_directory_path = current_output_dir
  )
}
