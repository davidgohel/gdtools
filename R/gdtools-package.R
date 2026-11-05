#' @useDynLib gdtools
#' @importFrom Rcpp sourceCpp
NULL

#' @title Version of the Cairo library (deprecated)
#'
#' @description gdtools no longer uses Cairo: font metrics are read with
#' FreeType from the font files (see [version_freetype()]). This function
#' is deprecated and will be removed in a future release.
#' @return `NULL`, invisibly.
#' @examples
#' suppressWarnings(version_cairo())
#' @export
#' @keywords internal
version_cairo <- function() {
  .Deprecated(
    msg = paste0(
      "`version_cairo()` is deprecated: gdtools no longer uses Cairo ",
      "and the function returns NULL."
    )
  )
  invisible(NULL)
}
