#' @useDynLib gdtools
#' @importFrom Rcpp sourceCpp
#' @importFrom grDevices is.raster
NULL

#' @title Version numbers of C libraries
#'
#' @description Return the runtime version of the Cairo and FreeType
#' libraries linked to the package.
#' @return An object of class \code{"numeric_version"}.
#' @examples
#' version_cairo()
#' version_freetype()
#' @export
version_cairo <- function() {
  ver <- version_cairo_()
  ver <- strsplit(ver, "\\.")[[1]]
  ver <- as.integer(ver)

  structure(list(ver), class = c("package_version", "numeric_version"))
}
