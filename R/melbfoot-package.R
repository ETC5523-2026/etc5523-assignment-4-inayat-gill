#' @keywords internal
"_PACKAGE"

# The Shiny app in inst/app uses bslib and ggplot2, so they are declared as
# imports here to make sure they are installed with the package.
#' @importFrom rlang .data
#' @importFrom bslib bs_theme
#' @importFrom ggplot2 ggplot
#' @importFrom utils globalVariables
NULL

# `ped_hourly` is lazy-loaded package data used as a default argument
globalVariables("ped_hourly")