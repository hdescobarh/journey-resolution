#!/usr/bin/Rscript --vanilla
# author: hdescobarh

########################## ENVIRONMENT SET UP ##########################

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


########################## LOAD AND VALIDATE DATA ##########################


data <- read.table(
  file = "Example_Data/Segemehl_filTotal3.txt",
  header = TRUE, row.names = 1
)

# Table columns names verification

if (!all(
  grepl("[DM]\\d+R\\d+", colnames(data))
)) {
  stop(sprintf(
    "Invalid columns names. They must follow the format '[DM]\\d+R\\d+'",
    paste("", collapse = ", ")
  ))
}

########################## ANALYSIS ##########################





############ 2. Filtering


############ 3. Data Normalization


############ 4. Set experiment design


############ 5. Dispersion estimation


############ 6. Model fit

############ 7. differential expression tests
