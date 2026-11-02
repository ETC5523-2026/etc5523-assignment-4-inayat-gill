#' Launch the Melbourne foot traffic Shiny app
#'
#' Opens the interactive app included in this package. The app lets you compare
#' the typical hourly pattern of foot traffic across Melbourne sensor locations
#' and years, and see how traffic changed relative to 2019.
#'
#' @return Called for its side effect of starting the app. It does not return a
#'   value.
#'
#' @export
#'
#' @examples
#' if (interactive()) {
#'   launch_app()
#' }
launch_app <- function() {
  app_dir <- system.file("app", package = "melbfoot")
  if (identical(app_dir, "")) {
    stop(
      "Could not find the app directory. Try re-installing `melbfoot`.",
      call. = FALSE
    )
  }
  shiny::runApp(app_dir, display.mode = "normal")
}
