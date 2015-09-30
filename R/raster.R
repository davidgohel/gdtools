#' Draw/preview a raster to a png file
#'
#' \code{raster_view} is a helper function for testing. It uses \code{htmltools}
#' to render a png as an image with base64 encoded data image.
#'
#' @param x A raster object
#' @param path name of the file to create
#' @param width,height Width and height in pixels.
#' @param interpolate A logical value indicating whether to linearly
#'   interpolate the image.
#' @export
#' @examples
#' r <- as.raster(matrix(hcl(0, 80, seq(50, 80, 10)),
#'  nrow = 4, ncol = 5))
#' plot(r)
#' t <- tempfile()
#' raster_write(r, t, width = 50, height = 50)
#' if (require("htmltools")) {
#'   raster_view(t)
#' }
raster_write <- function(x, path, width = 480, height = 480,
                         interpolate = FALSE) {
  stopifnot(is.raster(x))

  col <- col2rgb(x, alpha = TRUE)
  raster_to_png(col["red", ], col["green", ], col["blue", ], col["alpha", ],
    w = ncol(x), h = nrow(x), width = width, height = height,
    interpolate = interpolate, filename = path)

  invisible(path)
}

#' @export
#' @rdname raster_write
raster_view <- function(path) {
  code <- png_as_base64(path)
  img <- paste0("<img src=\"data:image/png;base64,", code, "\" />")
  htmltools::browsable(htmltools::HTML(img))
}
