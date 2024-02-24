# Hans D. Escobar H.

# Required libraries validation
if (!require("lme4", quietly = TRUE)) {
  print("Error: missing lme4 package")
  quit()
}

# V_P and H^2 functions
phenotypic_variance <- function(line_variance, residual_variance) {
  # V_P = V_G + V_E , V_G  := line_variance, V_E := residual_variance
  return(line_variance + residual_variance)
}

broad_sense_heritability <- function(line_variance, phenotypic_variance) {
  # $H^2 = \frac{V_G}{V_P}$ - additive and non-additive genetic effects
  return(line_variance / phenotypic_variance)
}


# --------------------------------------------------------------------------
# Generate pelargonina table

get_pelargonina_variances <- function(location_df) {
  # Fit a linear mixed-effects model (LMM) to data
  lmer_mod_object <- lmer(Pelargonina ~ (1 | Line), data = location_df)
  # Extract Variance and Correlation Components
  vc_df <- as.data.frame(VarCorr(lmer_mod_object))[, c("grp", "vcov")]
  return(vc_df)
}


data_df <- read.table("../Example_Data/pelargo.txt", header = TRUE)


pelargonina_summary <- data.frame(
  # subachoque 1, sumapaz 2
  "Location" = factor(levels = c("subachoque", "sumapaz")),
  "V_G" = double(),
  "V_E" = double(),
  "V_P" = double(),
  "H^2" = double()
)

for (loc in c("1", "2")) {
  # Generate variance values
  variances_df <- get_pelargonina_variances(data_df[data_df$Location == loc, ])
  line_variance <- variances_df[variances_df$grp == "Line", ][, "vcov"]
  residual_variance <- variances_df[variances_df$grp == "Residual", ][, "vcov"]
  v_p <- phenotypic_variance(line_variance, residual_variance)
  broad_heritability <- broad_sense_heritability(line_variance, v_p)

  # Validation of location values
  if (loc == 1) {
    location <- "subachoque"
  } else if (loc == 2) {
    location <- "sumapaz"
  } else {
    throw("Invalid location value", loc)
  }

  # Generate summary data frame
  pelargonina_summary[nrow(pelargonina_summary) + 1, ] <- list(
    location, line_variance, residual_variance, v_p, broad_heritability
  )
}

# Save tables

if (!dir.exists("../Results")) {
  dir.create("../Results")
}

write.table(
  pelargonina_summary,
  file = "../Results/pelargonina_summary.tsv", sep = "\t",
  row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8"
)

print(format(pelargonina_summary, digits = 4, nsmall = 4))
