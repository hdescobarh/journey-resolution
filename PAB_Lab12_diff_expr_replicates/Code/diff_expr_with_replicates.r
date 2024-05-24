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

############ 1. Load data

data <- read.table(
  file = input_file_path, header = TRUE, row.names = 1
)

# Check table format and add factors to data

expected_cols <- c(
  "A549CellCiptapRep3", "A549CellCiptapRep4",
  "A549CytosolCiptapRep3", "A549CytosolCiptapRep4",
  "A549NucleusCiptapRep3", "A549NucleusCiptapRep4"
)
if (!all(
  colnames(data) ==
    expected_cols
)) {
  stop(sprintf(
    "Non-valid table. Expected data with the columns: %s",
    paste(expected_cols, collapse = ", ")
  ))
}

group <- factor(c("Ce", "Ce", "Cy", "Cy", "Nu", "Nu"))
data <- DGEList(counts = data, group = group)

############ 2. Filtering

# filtering keeps genes that have CPM >= CPM.cutoff in MinSampleSize samples,
#   where CPM.cutoff = min.count/median(lib.size)*1e6 and MinSampleSize is the
#   smallest group sample size or, more generally, the minimum inverse leverage
#   computed from the design matrix.

keep <- filterByExpr(data, group = group, min.count = 10)

# Updated libraries size
data <- data[keep, , keep.lib.sizes = FALSE]

############ 3. Normalization

# Calculate scaling factors to convert the raw library sizes for a
#   set of sequenced samples into normalized effective library sizes.

# The method TMMwsp is a variant of TMM that is intended to have more stable
#   performance when the counts have a high proportion of zeros.
data_normalized <- normLibSizes(data, method = "TMMwsp")

############ 4. Dispersion estimation

design <- model.matrix(~ 0 + group, data = data_normalized$samples)
colnames(design) <- levels(data_normalized$samples$group)

# Estimates Common, Trended and Tagwise Negative Binomial dispersions
#   by weighted likelihood empirical Bayes
data_normalized <- estimateDisp(data_normalized, design)

############ 5. Model fit and differential expression tests

# Model Fit
# Fit a negative binomial generalized log-linear model to the read
#   counts for each gene.
fit <- glmFit(data_normalized, design)


# Remember the used design is ~ 0 + group

my_contrasts <- makeContrasts(
  CyvsCe = Cy - Ce, # c(-1,1,0)
  NuvsCe = Nu - Ce, # c(-1,0,1)
  NuvsCy = Nu - Cy, # c(0,-1,1)
  levels = design
)

for (current_contrast in colnames(my_contrasts)) {
  # Given genewise generalized linear model fits, conduct likelihood
  #   ratio tests for a given coefficient or coefficient contrast.

  qlf <- glmLRT(fit, contrast = my_contrasts[, current_contrast])

  # Table rows = min(n, number of genes with adjusted p-value <= cutoff p-value)
  #   default p-value cutoff is 1!!!
  # Default adjust.method = "BH"
  # FDR: false discovery rate (only when adjust.method is "BH", "BY" or "fdr")
  top <- topTags(qlf, n = Inf)
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
  plotSmear(qlf, de.tags = top_selected_ids)
  abline(
    h = c(-0.5, 0, 0.5), col = c("#0459ad", "red", "#0459ad"), lty = 2
  )
  dev.off()
}
