#' Run Multiple Regression
#'
#' Conducts multiple regression analysis with optional covariates.
#'
#' @param data A data frame containing the variables
#' @param dv Name of the dependent variable column
#' @param predictors Character vector of predictor variable names
#' @param covariates Optional character vector of covariate names to control for
#' @param standardize Logical, whether to standardize predictors (default: FALSE)
#'
#' @return A list containing the regression model, summary, and diagnostics
#' @export
#' @importFrom stats lm formula as.formula anova
#' @importFrom dplyr %>% mutate across all_of
#'
#' @examples
#' data_reg <- data.frame(
#'   y = rnorm(50, 10, 2),
#'   x1 = rnorm(50, 5, 1),
#'   x2 = rnorm(50, 3, 1),
#'   covariate = rnorm(50, 0, 1)
#' )
#' run_multiple_regression(data_reg, dv = "y", predictors = c("x1", "x2"))
#' run_multiple_regression(data_reg, dv = "y", predictors = c("x1", "x2"), 
#'                        covariates = "covariate")
run_multiple_regression <- function(data, dv, predictors, covariates = NULL,
                                   standardize = FALSE) {
  
  if (!dv %in% names(data)) {
    stop("Dependent variable not found in data")
  }
  
  if (!all(predictors %in% names(data))) {
    stop("Some predictors not found in data")
  }
  
  if (!is.null(covariates) && !all(covariates %in% names(data))) {
    stop("Some covariates not found in data")
  }
  
  # Prepare data
  model_data <- data
  
  # Standardize if requested
  if (standardize) {
    vars_to_standardize <- c(dv, predictors)
    if (!is.null(covariates)) {
      vars_to_standardize <- c(vars_to_standardize, covariates)
    }
    
    model_data <- model_data %>%
      mutate(
        across(
          all_of(vars_to_standardize),
          ~ scale(.) %>% as.vector()
        )
      )
  }
  
  # Build formula
  all_predictors <- predictors
  if (!is.null(covariates)) {
    all_predictors <- c(covariates, predictors)
  }
  
  formula_str <- paste(dv, "~", paste(all_predictors, collapse = " + "))
  model_formula <- as.formula(formula_str)
  
  # Fit model
  model <- lm(model_formula, data = model_data)
  model_summary <- summary(model)
  
  # If covariates present, also fit model without main predictors for comparison
  hierarchical <- NULL
  if (!is.null(covariates) && length(covariates) > 0) {
    formula_cov <- paste(dv, "~", paste(covariates, collapse = " + "))
    model_cov <- lm(as.formula(formula_cov), data = model_data)
    hierarchical <- anova(model_cov, model)
  }
  
  # Calculate VIF if multiple predictors
  vif_values <- NULL
  if (length(all_predictors) > 1) {
    tryCatch({
      # Check if we have enough data and variation for VIF
      # VIF requires at least 2 predictors and sufficient observations
      if (nrow(model_data) > length(all_predictors) + 1) {
        vif_values <- car::vif(model)
      } else {
        warning("Insufficient observations for VIF calculation")
      }
    }, error = function(e) {
      warning("Could not calculate VIF: ", e$message, 
              ". This may occur with categorical predictors or collinearity issues.")
    })
  }
  
  return(list(
    model = model,
    summary = model_summary,
    hierarchical_comparison = hierarchical,
    vif = vif_values,
    formula = formula_str
  ))
}
