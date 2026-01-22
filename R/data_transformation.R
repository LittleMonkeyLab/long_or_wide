#' Convert Wide Format to Long Format
#'
#' Converts data from wide format (one row per subject) to long format
#' (multiple rows per subject, one per condition/time point).
#'
#' @param data A data frame in wide format
#' @param id_cols Character vector of column names that identify each subject
#' @param value_cols Character vector of column names to pivot to long format
#' @param names_to Name of the new column that will contain the variable names
#' @param values_to Name of the new column that will contain the values
#'
#' @return A data frame in long format
#' @export
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr %>%
#'
#' @examples
#' # Example with repeated measures
#' wide_data <- data.frame(
#'   id = 1:3,
#'   time1 = c(10, 12, 11),
#'   time2 = c(15, 14, 16),
#'   time3 = c(20, 19, 21)
#' )
#' wide_to_long(wide_data, id_cols = "id", 
#'              value_cols = c("time1", "time2", "time3"),
#'              names_to = "timepoint", values_to = "score")
wide_to_long <- function(data, id_cols, value_cols, 
                         names_to = "variable", values_to = "value") {
  
  if (!all(id_cols %in% names(data))) {
    stop("Some id_cols not found in data")
  }
  
  if (!all(value_cols %in% names(data))) {
    stop("Some value_cols not found in data")
  }
  
  data %>%
    tidyr::pivot_longer(
      cols = all_of(value_cols),
      names_to = names_to,
      values_to = values_to
    )
}

#' Convert Long Format to Wide Format
#'
#' Converts data from long format (multiple rows per subject) to wide format
#' (one row per subject).
#'
#' @param data A data frame in long format
#' @param id_cols Character vector of column names that identify each subject
#' @param names_from Name of the column containing the variable names
#' @param values_from Name of the column containing the values
#'
#' @return A data frame in wide format
#' @export
#' @importFrom tidyr pivot_wider
#' @importFrom dplyr %>%
#'
#' @examples
#' # Example with repeated measures
#' long_data <- data.frame(
#'   id = rep(1:3, each = 3),
#'   timepoint = rep(c("time1", "time2", "time3"), 3),
#'   score = c(10, 15, 20, 12, 14, 19, 11, 16, 21)
#' )
#' long_to_wide(long_data, id_cols = "id",
#'              names_from = "timepoint", values_from = "score")
long_to_wide <- function(data, id_cols, names_from, values_from) {
  
  if (!all(id_cols %in% names(data))) {
    stop("Some id_cols not found in data")
  }
  
  if (!names_from %in% names(data)) {
    stop("names_from column not found in data")
  }
  
  if (!values_from %in% names(data)) {
    stop("values_from column not found in data")
  }
  
  data %>%
    tidyr::pivot_wider(
      id_cols = all_of(id_cols),
      names_from = names_from,
      values_from = values_from
    )
}

# Import helper for all_of
#' @importFrom dplyr all_of
NULL
