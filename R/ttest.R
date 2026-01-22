#' Run T-Tests
#'
#' Conducts t-tests for within-subjects, between-subjects designs, or with 
#' multiple trials.
#'
#' @param data A data frame containing the variables
#' @param design Type of design: "within", "between", or "multiple_trials"
#' @param dv Name of the dependent variable column (for between-subjects)
#' @param iv Name of the independent variable column (for between-subjects)
#' @param group1 Name of first group column (for within-subjects)
#' @param group2 Name of second group column (for within-subjects)
#' @param trial_cols Character vector of column names for multiple trials 
#'   (for multiple_trials design)
#' @param paired Logical, whether to conduct paired t-test (default: TRUE for within)
#'
#' @return A list containing the t-test result and descriptive statistics
#' @export
#' @importFrom stats t.test
#' @importFrom dplyr %>% group_by summarise
#'
#' @examples
#' # Between-subjects design
#' data_between <- data.frame(
#'   group = rep(c("A", "B"), each = 10),
#'   score = c(rnorm(10, 10, 2), rnorm(10, 12, 2))
#' )
#' run_ttest(data_between, design = "between", dv = "score", iv = "group")
#'
#' # Within-subjects design
#' data_within <- data.frame(
#'   pre = rnorm(10, 10, 2),
#'   post = rnorm(10, 12, 2)
#' )
#' run_ttest(data_within, design = "within", group1 = "pre", group2 = "post")
run_ttest <- function(data, design = c("within", "between", "multiple_trials"),
                     dv = NULL, iv = NULL, group1 = NULL, group2 = NULL,
                     trial_cols = NULL, paired = NULL) {
  
  design <- match.arg(design)
  
  if (design == "between") {
    if (is.null(dv) || is.null(iv)) {
      stop("For between-subjects design, specify dv and iv")
    }
    
    groups <- unique(data[[iv]])
    if (length(groups) != 2) {
      stop("Between-subjects design requires exactly 2 groups")
    }
    
    group_data1 <- data[data[[iv]] == groups[1], dv]
    group_data2 <- data[data[[iv]] == groups[2], dv]
    
    result <- t.test(group_data1, group_data2, paired = FALSE)
    
    descriptives <- data %>%
      group_by(!!sym(iv)) %>%
      summarise(
        n = n(),
        mean = mean(!!sym(dv), na.rm = TRUE),
        sd = sd(!!sym(dv), na.rm = TRUE),
        .groups = "drop"
      )
    
  } else if (design == "within") {
    if (is.null(group1) || is.null(group2)) {
      stop("For within-subjects design, specify group1 and group2")
    }
    
    if (is.null(paired)) paired <- TRUE
    
    result <- t.test(data[[group1]], data[[group2]], paired = paired)
    
    descriptives <- data.frame(
      measure = c(group1, group2),
      n = c(length(data[[group1]]), length(data[[group2]])),
      mean = c(mean(data[[group1]], na.rm = TRUE), 
               mean(data[[group2]], na.rm = TRUE)),
      sd = c(sd(data[[group1]], na.rm = TRUE), 
             sd(data[[group2]], na.rm = TRUE))
    )
    
  } else if (design == "multiple_trials") {
    if (is.null(trial_cols) || length(trial_cols) < 2) {
      stop("For multiple trials design, specify at least 2 trial_cols")
    }
    
    results <- list()
    descriptives <- data.frame(
      trial = trial_cols,
      n = sapply(trial_cols, function(x) sum(!is.na(data[[x]]))),
      mean = sapply(trial_cols, function(x) mean(data[[x]], na.rm = TRUE)),
      sd = sapply(trial_cols, function(x) sd(data[[x]], na.rm = TRUE))
    )
    
    # Conduct pairwise t-tests
    comparisons <- combn(trial_cols, 2, simplify = FALSE)
    for (comp in comparisons) {
      comp_name <- paste(comp[1], "vs", comp[2])
      results[[comp_name]] <- t.test(data[[comp[1]]], data[[comp[2]]], 
                                     paired = TRUE)
    }
    
    return(list(results = results, descriptives = descriptives))
  }
  
  return(list(result = result, descriptives = descriptives))
}

# Helper to use sym from rlang through dplyr
#' @importFrom rlang sym
NULL
