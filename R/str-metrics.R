#' @title Get font metrics for a string.
#'
#' @description Compute the width, ascent and descent of a single
#' string in points using Cairo text measurement.
#'
#' @note This function will be deprecated in a future release.
#' Use [strings_sizes()] instead.
#'
#' @return A named numeric vector with elements \code{width},
#' \code{ascent} and \code{descent} (unit is points).
#' @param x Character vector of strings to measure (only the first element is used).
#' @param bold,italic Is text bold/italic?
#' @param fontname Font name.
#' @param fontsize Font size in points.
#' @param fontfile Path to a font file. If empty, the font is
#' resolved by name via \code{systemfonts}.
#' @family functions for font metrics
#' @examples
#' str_metrics("Hello World!")
#' @export
#' @keywords internal
str_metrics <- function(x, fontname = "sans", fontsize = 12, bold = FALSE, italic = FALSE, fontfile = "") {
  str_metrics_(x = x, fontname = fontname, fontsize = fontsize, bold = bold, italic = italic, fontfile = fontfile)
}

#' Compute string extents for a vector of strings.
#'
#' For each \code{x} element, determines the width and height of a bounding box that's big enough
#' to (just) enclose the provided text. Unit is points.
#'
#' @note This function will be deprecated in a future release.
#' Use [strings_sizes()] instead.
#' @param x Character vector of strings to measure
#' @param bold,italic Is text bold/italic? A logical vector, recycled to match \code{x}.
#' @param fontname Font name. A character vector, recycled to match \code{x}.
#' @param fontsize Font size. A numeric vector, recycled to match \code{x}.
#' @param fontfile Font file. A character vector, recycled to match \code{x}.
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
#' @family functions for font metrics
#' @export
#' @keywords internal
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


#' @title Compute strings sizes
#' @description
#' Determines widths, ascent and descent in inches using
#' Cairo text measurement (device-independent).
#'
#' @param x A character vector of strings to measure. All arguments are vectorized
#'   and recycled to match the length of \code{x}.
#' @param fontname A character vector specifying the font family name (e.g., "sans", "serif", "mono").
#'   Default is "sans". This argument is vectorized.
#' @param fontsize A numeric vector specifying the font size in points.
#'   Default is 10. This argument is vectorized.
#' @param bold A logical vector indicating whether the text should be bold.
#'   Default is FALSE. This argument is vectorized.
#' @param italic A logical vector indicating whether the text should be italic.
#'   Default is FALSE. This argument is vectorized.
#' @examples
#' strings_sizes(letters)
#' strings_sizes("Hello World!", bold = TRUE, italic = FALSE,
#'   fontname = "sans", fontsize = 12)
#' @family functions for font metrics
#' @export
strings_sizes <- function(x, fontname = "sans", fontsize=10, bold = FALSE, italic = FALSE) {

  stopifnot(is.character(x), is.character(fontname),
            is.numeric(fontsize), is.logical(bold),
            is.logical(italic))

  max_length <- length(x)
  fontname <- rep(fontname, length.out = max_length)
  fontsize <- rep(fontsize, length.out = max_length)
  bold <- rep(bold, length.out = max_length)
  italic <- rep(italic, length.out = max_length)

  z <- m_str_metrics_(x, fontname, fontsize, as.integer(bold), as.integer(italic),
                       rep("", max_length))
  z$width <- z$width / 72
  z$ascent <- z$ascent / 72
  z$descent <- z$descent / 72
  z
}
