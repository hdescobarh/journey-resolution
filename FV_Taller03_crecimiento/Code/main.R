# author: hdescobarh

########## Environment set up ##########

missing_packages <- character()
for (package in c(
  "tidyverse", "cowplot", "gtable"
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

########## Regression Models ##########

#' Calculates the Corrected Akaike information criterion (AICc)
#' based on the formula given by Burnham, K. P., & Anderson, D. R. (1998).
#' Practical Use of the Information-Theoretic Approach.
#' In Model Selection and Inference (pp. 75–117).
#' Springer New York. https://doi.org/10.1007/978-1-4757-2917-7_3
#'
#' @param model A nls object
AIC_corrected <- function(model) {
  number_parameters <- length(coefficients(model))
  number_observations <- length(fitted(model))
  correction <- (
    2 * number_parameters * (number_parameters + 1)
  ) / (number_observations - number_parameters - 1)
  AIC(model) + correction
}

#' Calculates the pseudo coefficient of determination
#' based on the formula given by Schabenberger, O., & Pierce, F. J. (2001).
#' Nonlinear Models. In Contemporary Statistical Models for the Plant and
#' Soil Sciences (p. 760).CRC Press. https://doi.org/10.1201/9781420040197
#'
#' @param model_summary A summary.nls object
#' @param centralized_response A numeric vector of y_i - ȳ.
#' y_i: response variable observations
#' ȳ: response variable average
pseudo_R_square <- function(model_summary, centralized_response) {
  # mean squared error (MSE) or mean squared deviation (MSD) is the
  # sum of squares error (SSE) or residual sum of squares (RSS) divided
  # by its degrees of freedom. sqrt(MSE) = the Residual Standard Deviation
  mse <- model_summary$sigma^2

  # Total mean square (MST) is the
  # sum of squares total (SST) or the total sum of squares (TSS) divided
  # by its degrees of freedom
  sst <- (t(centralized_response) %*% centralized_response)[[1]]
  mst <- sst / (length(centralized_response) - model_summary$df[1] + 1)

  1 - mse / mst
}

#' Gives the Corrected Akaike information criterion (AICc), the
#' pseudo coefficient of determination, and the proportion of significative
#' estimated parameters from a non-linear regression model
#'
#' @param nls_model A nls object
#' @param centralized_response A numeric vector of y_i - ȳ.
#' y_i: response variable observations
#' ȳ: response variable average
model_goodness <- function(nls_model, centralized_response) {
  model_summary <- summary(nls_model)
  significative_proportion <- sum(
    model_summary$coefficients[, "Pr(>|t|)"] < 0.05
  ) / length(model_summary$coefficients[, "Pr(>|t|)"])

  list(
    AICc = AIC_corrected(nls_model),
    pseudo_R_square = pseudo_R_square(model_summary, centralized_response),
    significative_proportion = significative_proportion
  )
}

#' Fit multiple models and returns a list of them and
#' their goodness of fit statistics
#'
#' @param data data.frame
#' @param group character group col
#' @param response character response variable col
#' @param explanatory character explanatory variable col
#' @return A list with the following components:
#' @description goodness: data.frame with AICc, pseudo R^2 and
#' proportion of significative by each group x model
#' @description models: a nested list with the models. First level is the
#' group name. Second level is the model name.
test_nls_models <- function(data, group, response, explanatory) {
  models_goodness_fit <- data.frame()
  nls_models <- list()
  # Fit multiple models by each group
  for (current_group in levels(data[[group]])) {
    group_subset <- filter(data, .data[[group]] == current_group)
    group_models <- list(
      gompertz = nls(
        as.formula(
          paste(response, "~ SSgompertz(", explanatory, ", Asym, b2, b3)")
        ),
        group_subset
      ),
      logistic = nls(
        as.formula(
          paste(response, "~ SSlogis(", explanatory, ", Asym, xmid, scal)")
        ),
        group_subset
      ),
      asymptotic = nls(
        as.formula(
          paste(response, "~ SSasymp(", explanatory, ", Asym, R0, lrc)")
        ),
        group_subset
      ),
      asymptotic_origin = nls(
        as.formula(
          paste(response, "~ SSasympOrig(", explanatory, ", Asym, lrc)")
        ),
        group_subset
      )
    )

    nls_models[[current_group]] <- group_models

    centralized_response <- group_subset[[response]] -
      mean(group_subset[[response]])


    # Get values to check Goodness of fit
    for (current_model in names(group_models)) {
      current_model_goodness <- model_goodness(
        group_models[[current_model]], centralized_response
      )
      models_goodness_fit <- rbind(
        models_goodness_fit,
        data.frame(
          Group = current_group,
          model = current_model,
          current_model_goodness,
          stringsAsFactors = TRUE
        )
      )
    }
  }

  list(
    goodness = models_goodness_fit,
    models = nls_models
  )
}


#' From the output of test_nls_models, extract the the models matching
#' model_name
#'
#' @param tested_models test_nls_models's output
#' @param model_name character model name
filter_models <- function(tested_models, model_name) {
  models_to_use <- list()
  for (genotype in levels(data$Genotype)) {
    models_to_use[[genotype]] <- tested_models[[
      "models"
    ]][[genotype]][[model_name]]
  }
  models_to_use
}

#' Returns the ordinate of the logistic function
#'
#' @param x the numeric value of the abscise
#' @param Asym parameter representing the asymptote of the logistic regression
#' @param xmid parameter representing the x value at the inflection
#' point of the logistic curve.
#' @param scal scale parameter of the logistic regression
logis_fun <- function(x, Asym, xmid, scal) {
  Asym / (1 + exp((xmid - x) / scal))
}

#' Returns the reproductive efficiency from the logistic regression.
#' It corresponds to the value of the second derivative at the inflection point
#'
#' Bibliography: Sari, B. G., Olivoto, T., Diel, M. I., Krysczun, D. K.,
#' Lúcio, A. D. C.,& Savian, T. V. (2018). Nonlinear Modeling for Analyzing Data
#' from Multiple Harvest Crops. Agronomy Journal, 110(6), 2331–2342.
#' https://doi.org/10.2134/agronj2018.05.0307
#'
#' @param Asym parameter representing the asymptote of the logistic regression
#' @param scal scale parameter of the logistic regression
logis_reprod_effic <- function(Asym, scal) {
  Asym / (4 * scal)
}

#' Returns the year of maximum production from the logistic regression.
#' It corresponds to the value of x at the point of asymptotic deceleration;
#' this is, the las inflection point of the second derivative.
#'
#' Bibliography: Mischan, M. M., Pinho, S. Z. D., & Carvalho, L. R. D.
#' (2011).Determination of a point sufficiently close to the asymptote in
#' nonlinear growth functions. Scientia Agricola, 68(1), 109–114.
#' https://doi.org/10.1590/S0103-90162011000100016
#'
#' @param xmid parameter representing the x value at the inflection
#' point of the logistic curve.
#' @param scal scale parameter of the logistic regression
logis_year_max_prod <- function(xmid, scal) {
  scal * log(2 * sqrt(6) + 5) + xmid
}

#' Returns the integral of the fitted logistic function at x
#'
#' @param x the numeric value of the abscise
#' @param Asym parameter representing the asymptote of the logistic regression
#' @param xmid parameter representing the x value at the inflection
#' point of the logistic curve.
#' @param scal scale parameter of the logistic regression
logis_integral <- function(x, Asym, xmid, scal) {
  Asym * (scal * log(exp((-x + xmid) / scal) + 1) + x)
}
