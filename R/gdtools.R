#' @useDynLib gdtools
#' @importFrom Rcpp sourceCpp
#' @importFrom grDevices is.raster
NULL

#' Version numbers of C libraries
#'
#' \code{version_cairo()} and \code{version_freetype()} return the
#' runtime version and \code{version_fontconfig()} returns the
#' compile-time version. These helpers return version objects as with
#' \code{\link[utils]{packageVersion}()}.
#' @export
version_cairo <- function() {
  ver <- version_cairo_()
  ver <- strsplit(ver, "\\.")[[1]]
  ver <- as.integer(ver)

  structure(list(ver), class = c("package_version", "numeric_version"))
}
