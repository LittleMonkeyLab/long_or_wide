#' Check Statistical Assumptions
#'
#' Checks common statistical assumptions including normality, homogeneity of 
#' variance, and linearity.
#'
#' @param data A data frame containing the variables
#' @param dv Name of the dependent variable column
#' @param group Optional name of grouping variable for group-based tests
#' @param check_normality Logical, check normality (default: TRUE)
#' @param check_homogeneity Logical, check homogeneity of variance (default: TRUE)
#'
#' @return A list containing test results
#' @export
#' @importFrom stats shapiro.test bartlett.test
#'
#' @examples
#' data_check <- data.frame(
#'   group = rep(c("A", "B", "C"), each = 20),
#'   score = c(rnorm(20, 10, 2), rnorm(20, 12, 2), rnorm(20, 14, 2))
#' )
#' check_assumptions(data_check, dv = "score", group = "group")
check_assumptions <- function(data, dv, group = NULL,
                             check_normality = TRUE,
                             check_homogeneity = TRUE) {
  
  results <- list()
  
  # Check normality
  if (check_normality) {
    if (is.null(group)) {
      # Overall normality
      if (nrow(data) >= 3 && nrow(data) <= 5000) {
        shapiro_result <- shapiro.test(data[[dv]])
        results$normality <- list(
          test = "Shapiro-Wilk",
          statistic = shapiro_result$statistic,
          p_value = shapiro_result$p.value,
          interpretation = ifelse(shapiro_result$p.value > 0.05,
                                 "Data appear normally distributed",
                                 "Data may not be normally distributed")
        )
      } else {
        results$normality <- list(
          test = "Shapiro-Wilk",
          note = "Sample size outside valid range (3-5000)"
        )
      }
    } else {
      # Normality by group
      groups <- unique(data[[group]])
      normality_by_group <- list()
      
      for (g in groups) {
        group_data <- data[data[[group]] == g, dv]
        if (length(group_data) >= 3 && length(group_data) <= 5000) {
          shapiro_result <- shapiro.test(group_data)
          normality_by_group[[as.character(g)]] <- list(
            statistic = shapiro_result$statistic,
            p_value = shapiro_result$p.value
          )
        }
      }
      
      results$normality_by_group <- normality_by_group
    }
  }
  
  # Check homogeneity of variance
  if (check_homogeneity && !is.null(group)) {
    tryCatch({
      bartlett_result <- bartlett.test(data[[dv]] ~ data[[group]])
      results$homogeneity <- list(
        test = "Bartlett's test",
        statistic = bartlett_result$statistic,
        p_value = bartlett_result$p.value,
        interpretation = ifelse(bartlett_result$p.value > 0.05,
                               "Variances appear homogeneous",
                               "Variances may not be homogeneous")
      )
    }, error = function(e) {
      results$homogeneity <- list(
        test = "Bartlett's test",
        error = e$message
      )
    })
  }
  
  return(results)
}

#' Calculate Descriptive Statistics
#'
#' Calculates common descriptive statistics for variables.
#'
#' @param data A data frame containing the variables
#' @param vars Character vector of variable names to describe
#' @param group Optional name of grouping variable
#'
#' @return A data frame with descriptive statistics
#' @export
#' @importFrom dplyr %>% group_by summarise across all_of n
#' @importFrom stats sd median
#' @importFrom rlang sym
#'
#' @examples
#' data_desc <- data.frame(
#'   group = rep(c("A", "B"), each = 20),
#'   var1 = rnorm(40, 10, 2),
#'   var2 = rnorm(40, 5, 1)
#' )
#' descriptive_stats(data_desc, vars = c("var1", "var2"))
#' descriptive_stats(data_desc, vars = c("var1", "var2"), group = "group")
descriptive_stats <- function(data, vars, group = NULL) {
  
  if (!all(vars %in% names(data))) {
    stop("Some variables not found in data")
  }
  
  if (is.null(group)) {
    # Overall descriptives
    result <- data.frame(
      variable = vars,
      n = sapply(vars, function(v) sum(!is.na(data[[v]]))),
      mean = sapply(vars, function(v) mean(data[[v]], na.rm = TRUE)),
      sd = sapply(vars, function(v) sd(data[[v]], na.rm = TRUE)),
      min = sapply(vars, function(v) min(data[[v]], na.rm = TRUE)),
      max = sapply(vars, function(v) max(data[[v]], na.rm = TRUE)),
      median = sapply(vars, function(v) median(data[[v]], na.rm = TRUE))
    )
  } else {
    # Descriptives by group
    if (!group %in% names(data)) {
      stop("Group variable not found in data")
    }
    
    result_list <- list()
    for (v in vars) {
      group_stats <- data %>%
        group_by(!!sym(group)) %>%
        summarise(
          variable = v,
          n = sum(!is.na(!!sym(v))),
          mean = mean(!!sym(v), na.rm = TRUE),
          sd = sd(!!sym(v), na.rm = TRUE),
          min = min(!!sym(v), na.rm = TRUE),
          max = max(!!sym(v), na.rm = TRUE),
          median = median(!!sym(v), na.rm = TRUE),
          .groups = "drop"
        )
      result_list[[v]] <- group_stats
    }
    result <- do.call(rbind, result_list)
  }
  
  return(result)
}

#' Calculate Cronbach's Alpha
#'
#' Calculates Cronbach's alpha reliability coefficient for a set of items.
#'
#' @param data A data frame containing the items
#' @param items Character vector of column names representing scale items
#'
#' @return A list with alpha coefficient and item statistics
#' @export
#' @importFrom psych alpha
#'
#' @examples
#' data_alpha <- data.frame(
#'   item1 = c(4, 5, 3, 4, 5),
#'   item2 = c(5, 4, 4, 5, 4),
#'   item3 = c(3, 4, 3, 4, 5),
#'   item4 = c(4, 5, 4, 5, 4)
#' )
#' cronbach_alpha(data_alpha, items = c("item1", "item2", "item3", "item4"))
cronbach_alpha <- function(data, items) {
  
  if (!all(items %in% names(data))) {
    stop("Some items not found in data")
  }
  
  item_data <- data[, items, drop = FALSE]
  
  # Remove rows with missing data
  item_data <- na.omit(item_data)
  
  if (nrow(item_data) < 2) {
    stop("Insufficient data for alpha calculation")
  }
  
  alpha_result <- psych::alpha(item_data)
  
  return(list(
    alpha = alpha_result$total$raw_alpha,
    standardized_alpha = alpha_result$total$std.alpha,
    n_items = length(items),
    n_observations = nrow(item_data),
    item_statistics = alpha_result$item.stats,
    alpha_if_dropped = alpha_result$alpha.drop
  ))
}
