#' Run ANOVA
#'
#' Conducts one-way, two-way, or repeated measures ANOVA.
#'
#' @param data A data frame containing the variables
#' @param design Type of ANOVA: "one_way", "two_way", or "repeated_measures"
#' @param dv Name of the dependent variable column
#' @param iv1 Name of the first independent variable (factor)
#' @param iv2 Name of the second independent variable (for two-way ANOVA)
#' @param subject_id Name of the subject identifier column (for repeated measures)
#' @param within_factor Name of the within-subjects factor (for repeated measures)
#'
#' @return A list containing the ANOVA result and effect sizes
#' @export
#' @importFrom stats aov anova
#' @importFrom car Anova
#'
#' @examples
#' # One-way ANOVA
#' data_oneway <- data.frame(
#'   group = rep(c("A", "B", "C"), each = 10),
#'   score = c(rnorm(10, 10, 2), rnorm(10, 12, 2), rnorm(10, 14, 2))
#' )
#' run_anova(data_oneway, design = "one_way", dv = "score", iv1 = "group")
#'
#' # Two-way ANOVA
#' data_twoway <- data.frame(
#'   factor1 = rep(c("A", "B"), each = 20),
#'   factor2 = rep(c("X", "Y"), 20),
#'   score = rnorm(40, 10, 2)
#' )
#' run_anova(data_twoway, design = "two_way", dv = "score", 
#'           iv1 = "factor1", iv2 = "factor2")
run_anova <- function(data, design = c("one_way", "two_way", "repeated_measures"),
                     dv, iv1, iv2 = NULL, subject_id = NULL, 
                     within_factor = NULL) {
  
  design <- match.arg(design)
  
  # Ensure factors are actually factors
  if (!is.null(iv1)) {
    data[[iv1]] <- as.factor(data[[iv1]])
  }
  if (!is.null(iv2)) {
    data[[iv2]] <- as.factor(data[[iv2]])
  }
  
  if (design == "one_way") {
    if (is.null(dv) || is.null(iv1)) {
      stop("For one-way ANOVA, specify dv and iv1")
    }
    
    formula_str <- paste(dv, "~", iv1)
    model <- aov(as.formula(formula_str), data = data)
    result <- summary(model)
    
    # Calculate effect size (eta squared)
    ss_total <- sum((data[[dv]] - mean(data[[dv]], na.rm = TRUE))^2, na.rm = TRUE)
    ss_effect <- sum(anova(model)$"Sum Sq"[1])
    eta_squared <- ss_effect / ss_total
    
    return(list(
      anova_result = result,
      model = model,
      eta_squared = eta_squared
    ))
    
  } else if (design == "two_way") {
    if (is.null(dv) || is.null(iv1) || is.null(iv2)) {
      stop("For two-way ANOVA, specify dv, iv1, and iv2")
    }
    
    formula_str <- paste(dv, "~", iv1, "*", iv2)
    model <- aov(as.formula(formula_str), data = data)
    result <- summary(model)
    
    # Calculate effect sizes
    anova_table <- anova(model)
    ss_total <- sum(anova_table$"Sum Sq")
    eta_squared <- anova_table$"Sum Sq" / ss_total
    names(eta_squared) <- rownames(anova_table)
    
    return(list(
      anova_result = result,
      model = model,
      eta_squared = eta_squared
    ))
    
  } else if (design == "repeated_measures") {
    if (is.null(dv) || is.null(subject_id) || is.null(within_factor)) {
      stop("For repeated measures ANOVA, specify dv, subject_id, and within_factor")
    }
    
    data[[subject_id]] <- as.factor(data[[subject_id]])
    data[[within_factor]] <- as.factor(data[[within_factor]])
    
    formula_str <- paste(dv, "~", within_factor, "+ Error(", subject_id, "/", 
                        within_factor, ")")
    model <- aov(as.formula(formula_str), data = data)
    result <- summary(model)
    
    return(list(
      anova_result = result,
      model = model
    ))
  }
}
