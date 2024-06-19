#!/usr/bin/Rscript --vanilla

# packages validation

missing_packages <- character()
for (package in c(
  "GAPIT"
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

# Input validation

args <- commandArgs(trailingOnly = TRUE)


if (length(args) < 3) {
  stop(
    "Needs three arguments:
    - Phenotype file path
    - Hapmap file path
    - Total of PCA components\n",
    call. = FALSE
  )
}

phenotype_file <- args[1]
hapmap_file <- args[2]
pca_components_number <- as.integer(args[3])

for (file in c(phenotype_file, hapmap_file)) {
  if (!file.exists(file)) {
    stop(sprintf("Input file (%s) does not exist", file),
      call. = FALSE
    )
  }
}

if (!is.integer(pca_components_number)) {
  stop("Invalid PCA components number",
    call. = FALSE
  )
}


# Load data
phenotype <- read.table(phenotype_file, head = TRUE, sep = "\t")
genotype_hapmap <- read.table(hapmap_file, head = FALSE, sep = "\t", )


# GWAS - MLM MODEL
output <- GAPIT(
  Y = phenotype,
  G = genotype_hapmap,
  PCA.total = pca_components_number,
  model = c("MLM")
)

warnings()

sessionInfo()