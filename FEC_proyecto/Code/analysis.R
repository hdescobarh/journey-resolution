#!/usr/bin/Rscript --vanilla
# author: hdescobarh

########################## ENVIRONMENT SET UP ##########################

# Load packages

missing_packages <- character()
for (package in c(
  "factoextra", "corrplot"
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

# Files and directories validation

data_file <- "../Data/env_data.tsv"
output_directory <- "../Results/"

if (!file.exists(data_file)) {
  stop(sprintf("Input file (%s) does not exist", data_file),
    call. = FALSE
  )
}

if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}

# ggplot config

# factoextra is not using the updated theme, add + theme_get() to plots
theme_set(theme_gray() +
  theme(
    axis.text = element_text(size = 16),
    text = element_text(size = 18),
    aspect.ratio = 1,
  ))
update_geom_defaults("text", list(size = 50))


# 524e4e
########################## LOAD DATA ##########################

data <- read.delim(
  data_file,
  row.names = 1,
  colClasses = c("character", "factor", rep("double", 18)),
  comment.char = "#"
)

# Data filtering
data <- subset(data,
  select = -c(temperature_celsius, OD_ppm, conductividad_muScm)
)
data <- data[!is.na(data[, "feopigmentos"]), seq_len(ncol(data) - 2)]


########################## ANALYSIS ##########################

data_pca <- prcomp(data[, 2:ncol(data)], scale = TRUE)

# PCA - scree plot

scree_plot <- fviz_eig(
  data_pca,
  title = "Sedimentación - PCA",
  xlab = "Dimensiones",
  ylab = "Porcentaje varianza explicada"
) + theme_get()

ggsave(
  plot = scree_plot,
  paste(output_directory, "scree.png", sep = ""),
  width = 30, units = "cm", scale = 1
)


# PCA - loadings plot
loading_plot <- fviz_pca_var(data_pca,
  col.var = "contrib", # Color by contributions to the PC
  gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
  repel = TRUE,
  title = "Variables - PCA",
  labelsize = 6,
) + theme_get()

ggsave(
  plot = loading_plot,
  paste(output_directory, "loading.png", sep = ""),
  width = 30, units = "cm", scale = 1
)


# PCA - score plot
score_plot <- fviz_pca_ind(data_pca,
  col.ind = "cos2", # Color by the quality of representation
  gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
  repel = TRUE,
  title = "Puntos muéstrales - PCA",
  labelsize = 6,
  geom = "text"
) + theme_get()

ggsave(
  plot = score_plot,
  paste(output_directory, "score.png", sep = ""),
  width = 30, units = "cm", scale = 1
)

# Correlations matrix
png(paste(output_directory, "corr.png", sep = ""))
data_corr <- cor(data[, 2:ncol(data)])
p.mat <- cor.mtest(data[, 2:ncol(data)])
corrplot(
  data_corr,
  type = "upper", order = "hclust",
  p.mat = p.mat$p, sig.level = 0.01, diag = FALSE
)
dev.off()

# Report information

warnings()
sessionInfo()
