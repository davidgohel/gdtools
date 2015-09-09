#' @import htmltools
#' @title Run plotting code and view raster in RStudio Viewer or web browser
#' @description  This is useful primarily for testing.
#' @param code raster base64 encoded string.
#' @param ... Other arguments - not used.
#' @export
html_raster <- function(code, ...) {
  code = paste0("<img src=\"data:image/png;base64,", code, "\" />")
  browsable(
    HTML(paste0(code, collapse = "\n"))
  )
}
