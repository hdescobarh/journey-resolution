#!/usr/bin/Rscript --vanilla
# author: hdescobarh

########################## SETUP ##########################

args <- commandArgs(trailingOnly = TRUE)

# Arguments validation

if (length(args) < 2) {
  stop("Need two arguments: input_file, output_directory.\n", call. = FALSE)
}

input_file_path <- args[1]
output_directory_path <- args[2]

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


########################## ANALYSIS ##########################

# 1. Load data
data <- read.table(
  file = input_file_path, header = TRUE, row.names = 1
)

# Check expected columns and factors
if (!all(
  colnames(data) ==
    c("K562Cell", "K562Cytosol", "K562Nucleolus", "K562Nucleus")
)) {
  stop("Non-valid table. Expected data with the columns:
  'K562Cell', 'K562Cytosol', 'K562Nucleolus', 'K562Nucleus'")
}
group <- factor(c("Ce", "Cy", "Nl", "Nu"))

# Make DGEList object
data <- DGEList(counts = data, group = group)

# 2. Filtering

keep <- filterByExpr(data, group = group, min.count = 10)
data <- data[keep, , keep.lib.sizes = FALSE]

# 3. Normalization

data_normalized <- normLibSizes(data)

# 4. Differential Expression testing

# Model and dispersion
design <- model.matrix(~group)
common_bcv <- 0.2

# Make comparison pairs

group_pairs <- list()
for (i in 1:(nlevels(group) - 1)) {
  for (j in (i + 1):(length(group))) {
    group_pairs[[length(group_pairs) + 1]] <- c(
      levels(group)[i], levels(group)[j]
    )
  }
}

# Paired Exact tests

summary_pairs <- matrix(nrow = 3, ncol = 0)
for (current_pair in group_pairs) {
  et <- exactTest(
    data_normalized,
    dispersion = common_bcv^2, pair = current_pair
  )
  # Table of the Top Differentially Expressed Genes/Tags
  max_number_of_genes <- 20
  top <- topTags(et, n = max_number_of_genes, sort.by = "logFC")
  file_name <- sprintf(
    "%s/top%s_DE_%s.txt",
    output_directory_path,
    max_number_of_genes,
    paste(current_pair, collapse = "_")
  )
  write.table(
    top,
    file = file_name, append = FALSE, quote = FALSE, sep = "\t"
  )
  # Identify significantly differentially expressed genes
  res <- decideTests(et, p.value = 0.1)
  summary_pairs <- cbind(summary_pairs, summary(res))
}
summary_pairs <- as.data.frame(summary_pairs)

file_name <- sprintf(
  "%s/summary_all_pairs.txt",
  output_directory_path
)
write.table(
  summary_pairs,
  file = file_name, append = FALSE, quote = FALSE, sep = "\t"
)
