#' Run Shiny Data Converter App
#'
#' Launches an interactive Shiny application for converting data between
#' wide and long formats.
#'
#' @return None (launches Shiny app)
#' @export
#'
#' @examples
#' \dontrun{
#' run_converter_app()
#' }
run_converter_app <- function() {
  app_dir <- system.file("shiny-apps", "converter", package = "longorwide")
  
  if (app_dir == "") {
    stop("Could not find Shiny app directory. Try re-installing the package.")
  }
  
  shiny::runApp(app_dir, display.mode = "normal")
}
