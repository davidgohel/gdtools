#' Draw a raster to a png file
#'
#' @param x A raster object
#' @param width,height Width and height in pixels.
#' @param interpolate A logical value indicating whether to linearly
#'   interpolate the image.
#' @param filename name of the file to create
#' @export
#' @examples
#' r <- as.raster(matrix(hcl(0, 80, seq(50, 80, 10)),
#'  nrow = 4, ncol = 5))
#' plot(r)
#' t <- tempfile()
#' write_raster(r, t, width = 50, height = 50)
write_raster <- function(x, filename, width = 480, height = 480,
                         interpolate = FALSE) {
  stopifnot(is.raster(x))

  col <- col2rgb(x, alpha = TRUE)
  raster_to_png(col["red", ], col["green", ], col["blue", ], col["alpha", ],
    w = ncol(x), h = nrow(x), width = width, height = height,
    interpolate = interpolate, filename = filename)

  invisible(filename)
}
