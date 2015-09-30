#' Encode a png file into base64.
#'
#' @param filename name of the file to create
#' @examples
#' r <- as.raster(matrix(hcl(50, 80, seq(50, 80, 10)),
#'  nrow = 4, ncol = 5))
#'
#' t <- tempfile()
#' write_raster(r, t, width = 50, height = 50)
#' png_get_base64(t)
#' @export
png_get_base64 <- function(filename) {

  if( missing( filename ) )
    stop("filename is missing")
  if( !file.exists(filename) )
    stop("file ", filename, " does not exist.")

  str = png_to_base64(filename)
  str
}
