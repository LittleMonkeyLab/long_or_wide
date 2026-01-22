#' Prepare Qualtrics Data
#'
#' Cleans and prepares Qualtrics survey data by removing header rows,
#' renaming columns, and optionally filtering columns.
#'
#' @param data A data frame imported from Qualtrics
#' @param remove_first_rows Number of header rows to remove (default: 2, 
#'   which removes the import ID and question text rows)
#' @param column_mapping Optional named vector to rename columns 
#'   (e.g., c("new_name" = "old_name"))
#'
#' @return A cleaned data frame
#' @export
#' @importFrom dplyr %>% select mutate
#'
#' @examples
#' \dontrun{
#' # Assuming qualtrics_data is imported from CSV
#' clean_data <- prepare_qualtrics(qualtrics_data, remove_first_rows = 2)
#' }
prepare_qualtrics <- function(data, remove_first_rows = 2, 
                             column_mapping = NULL) {
  
  # Remove header rows
  if (remove_first_rows > 0) {
    data <- data[-seq_len(remove_first_rows), , drop = FALSE]
  }
  
  # Reset row names
  rownames(data) <- NULL
  
  # Apply column mapping if provided
  if (!is.null(column_mapping)) {
    for (new_name in names(column_mapping)) {
      old_name <- column_mapping[[new_name]]
      if (old_name %in% names(data)) {
        names(data)[names(data) == old_name] <- new_name
      }
    }
  }
  
  # Convert appropriate columns to numeric
  # Typically, response columns are numeric
  data <- data %>%
    dplyr::mutate(across(where(is.character), ~ {
      # Try to convert to numeric
      suppressWarnings({
        num_version <- as.numeric(.)
        # If all values that exist fail to convert, keep as character
        # If at least some values convert successfully, use numeric version
        if (sum(!is.na(num_version)) > 0 || all(is.na(.))) {
          num_version
        } else {
          .
        }
      })
    }))
  
  return(data)
}

#' Reverse Score Items
#'
#' Reverse scores specified items on a scale.
#'
#' @param data A data frame containing the items to reverse score
#' @param items Character vector of column names to reverse score
#' @param min_value Minimum value of the scale
#' @param max_value Maximum value of the scale
#'
#' @return A data frame with reversed items
#' @export
#' @importFrom dplyr %>% mutate across all_of
#'
#' @examples
#' data <- data.frame(
#'   id = 1:3,
#'   item1 = c(5, 4, 3),
#'   item2 = c(2, 3, 4),
#'   item3 = c(1, 2, 5)
#' )
#' # Reverse score item2 and item3 on a 1-5 scale
#' reverse_score(data, items = c("item2", "item3"), min_value = 1, max_value = 5)
reverse_score <- function(data, items, min_value, max_value) {
  
  if (!all(items %in% names(data))) {
    stop("Some items not found in data")
  }
  
  data %>%
    dplyr::mutate(
      across(
        all_of(items),
        ~ max_value + min_value - .
      )
    )
}
