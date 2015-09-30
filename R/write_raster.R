#' Draw a raster image to a png file
#'
#' Draw a raster image based on colors. Image data is arranged by
#' row, it's made of 4 elements giving one colour (red, green, blue and alpha).
#' Data is scaled to width and height.
#'
#' @param red,green,blue,alpha Integer vector of red, green, blue, and
#'   alpha components (values must be between 0 and 255).
#' @param w,h Width and height of original matrix
#' @param width,height Width and height in pixels.
#' @param interpolate A logical value indicating whether to linearly
#'   interpolate the image.
#' @param filename name of the file to create
#' @examples
#' # create a color data matrix
#' w <- 5L
#' h <- 4L
#' red <- c(197L, 197L, 197L, 197L, 197L, 225L, 225L, 225L, 225L,
#' 225L, 254L, 254L, 254L, 254L, 254L, 255L, 255L, 255L, 255L, 255L)
#' green <- c(78L, 78L, 78L, 78L, 78L, 106L, 106L, 106L, 106L, 106L,
#' 134L, 134L, 134L, 134L, 134L, 162L, 162L, 162L, 162L, 162L)
#' blue <- c(109L, 109L, 109L, 109L, 109L, 134L, 134L, 134L, 134L,
#' 134L, 161L, 161L, 161L, 161L, 161L, 188L, 188L, 188L, 188L, 188L)
#' alpha <- rep(255L, length(blue))
#'
#' # generate the corresponding png
#' write_raster(red = as.integer(red), green = as.integer(green),
#'   blue = as.integer(blue), alpha = as.integer(alpha),
#'   width = 50, height = 75, w = w, h = h, filename = "raster.png"
#' )
#' @export
write_raster <- function(red, green, blue, alpha, w, h, width, height,
                         interpolate = FALSE, filename) {

  if( missing( filename ) )
    stop("filename is missing")

  stopifnot(is.numeric(red))
  stopifnot(is.numeric(green))
  stopifnot(is.numeric(blue))
  stopifnot(is.numeric(alpha))
  stopifnot(is.numeric(w))
  stopifnot(is.numeric(h))
  stopifnot(is.numeric(width))
  stopifnot(is.numeric(height))

  .lgts = sign( abs( diff(c( length(red), length(green), length(blue), length(alpha) )) ) )

  if( !all( .lgts == 0 ) )
    stop("red, green, blue, alpha should all have the same length.")

  stopifnot(length(w) == 1)
  stopifnot(length(h) == 1)
  stopifnot(length(width) == 1)
  stopifnot(length(height) == 1)
  w = as.integer(w)
  h = as.integer(h)
  width = as.double(width)
  height = as.double(height)
  raster_to_png(red, green, blue, alpha, w, h, width, height, interpolate, filename)
  invisible()
}
