#' Run plotting code and view raster in RStudio Viewer or web browser.
#'
#' Useful primarily for testing. Requires the \code{htmltools} package
#'
#' @param code raster base64 encoded string.
#' @export
html_raster <- function(code) {
  code <- paste0("<img src=\"data:image/png;base64,", code, "\" />",
    collapse = "\n")
  htmltools::browsable(htmltools::HTML(code))
}
