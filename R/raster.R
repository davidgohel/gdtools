#' Draw/preview a raster into a string
#'
#' \code{raster_view} is a helper function for testing. It uses \code{htmltools}
#' to render a png as an image with base64 encoded data image.
#'
#' @param x A raster object
#' @param width,height Width and height in pixels.
#' @param interpolate A logical value indicating whether to linearly
#'   interpolate the image.
#' @param code base64 code of a raster
#' @export
#' @examples
#' r <- as.raster(matrix(hcl(0, 80, seq(50, 80, 10)),
#'  nrow = 4, ncol = 5))
#' plot(r)
#' code <- raster_str(r, width = 50, height = 50)
#' if (interactive() && require("htmltools")) {
#'   raster_view(code = code)
#' }
raster_str <- function(x, width = 480, height = 480, interpolate = FALSE) {

  stopifnot(is.raster(x))

  value <- base64_raster_encode(x,
                w = ncol(x), h = nrow(x), width = width, height = height,
                interpolate = interpolate)
  value
}


#' @export
#' @rdname raster_str
raster_view <- function(code) {
  img <- paste0("<img src=\"data:image/png;base64,", code, "\" />")
  htmltools::browsable(htmltools::HTML(img))
}

