#' @title Encode a png file in base 64 format
#' @param filename name of the file to create
#' @examples
#' # create a color data matrix
#' w <- 5L
#' h <- 4L
#' red <- c(197L, 197L, 197L, 197L, 197L, 225L, 225L, 225L, 225L,
#' 225L, 254L, 254L, 254L, 254L, 254L, 255L, 255L, 255L, 255L, 255L)
#' green = c(78L, 78L, 78L, 78L, 78L, 106L, 106L, 106L, 106L, 106L,
#' 134L, 134L, 134L, 134L, 134L, 162L, 162L, 162L, 162L, 162L)
#' blue = c(109L, 109L, 109L, 109L, 109L, 134L, 134L, 134L, 134L,
#' 134L, 161L, 161L, 161L, 161L, 161L, 188L, 188L, 188L, 188L, 188L)
#' alpha = rep(255L, length(blue))
#'
#' # generate the corresponding png
#' write_raster(red = as.integer(red), green = as.integer(green),
#' blue = as.integer(blue), alpha = as.integer(alpha),
#' width = 50, height = 75, w = w, h = h, filename = "raster.png")
#'
#' str_b64 = png_get_base64("raster.png")
#' @export
png_get_base64 <- function(filename) {

  if( missing( filename ) )
    stop("filename is missing")
  if( !file.exists(filename) )
    stop("file ", filename, " does not exist.")

  str = png_to_base64(filename)
  str
}
