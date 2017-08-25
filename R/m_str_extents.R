#' Compute string extents for a vector of string.
#'
#' For each \code{x} element, determines the width and height of a bounding box that's big enough
#' to (just) enclose the provided text. Unit is pixel.
#' @param x Character vector of strings to measure
#' @param bold,italic Is text bold/italic?. A vector of logical to match with x.
#' @param fontname Font name. A vector of character to match with x.
#' @param fontsize Font size. A vector of numeric to match with x.
#' @param fontfile Font file. A vector of character to match with x.
#' @examples
#' \donttest{
#' # The first run can be slow when font caches are missing
#' # as font files are then being scanned to build those font caches.
#' m_str_extents(letters, fontsize = 1:26)
#' m_str_extents(letters[1:3],
#'   bold = c(TRUE, FALSE, TRUE),
#'   italic = c(FALSE, TRUE, TRUE),
#'   fontname = c("sans", "sans", "sans") )
#' }
#' @export
m_str_extents <- function(x, fontname = "sans", fontsize=10, bold = FALSE, italic = FALSE, fontfile = NULL) {

  stopifnot(is.character(x), is.character(fontname),
            is.numeric(fontsize), is.logical(bold),
            is.logical(italic), is.character(fontfile) || is.null(fontfile))

  max_length <- length(x)
  fontname <- rep(fontname, length.out = max_length)
  fontsize <- rep(fontsize, length.out = max_length)
  bold <- rep(bold, length.out = max_length)
  italic <- rep(italic, length.out = max_length)

  if( is.null(fontfile) )
    fontfile <- rep("", length.out = max_length)
  else
    fontfile <- rep(fontfile, length.out = max_length)

  m_str_extents_(x, fontname, fontsize, bold, italic, fontfile)
}
