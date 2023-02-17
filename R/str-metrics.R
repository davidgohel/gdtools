#' @title Compute string extents.
#'
#' @description Determines the width and height of a bounding box that's big enough
#' to (just) enclose the provided text.
#'
#' @param x Character vector of strings to measure
#' @param bold,italic Is text bold/italic?
#' @param fontname Font name
#' @param fontsize Font size
#' @param fontfile Font file
#' @examples
#' str_extents(letters)
#' str_extents("Hello World!", bold = TRUE, italic = FALSE,
#'   fontname = "sans", fontsize = 12)
#' @export
str_extents <- function(x, fontname = "sans", fontsize = 12, bold = FALSE, italic = FALSE, fontfile = "") {
  str_extents_(x = x, fontname = fontname, fontsize = fontsize, bold = bold, italic = italic, fontfile = fontfile)
}

#' Get font metrics for a string.
#'
#' @return A named numeric vector
#' @inheritParams str_extents
#' @examples
#' str_metrics("Hello World!")
#' @export
str_metrics <- function(x, fontname = "sans", fontsize = 12, bold = FALSE, italic = FALSE, fontfile = "") {
  str_metrics_(x = x, fontname = fontname, fontsize = fontsize, bold = bold, italic = italic, fontfile = fontfile)
}

#' Validate glyph entries
#'
#' Determines if strings contain glyphs not part of a font.
#'
#' @param x Character vector of strings
#' @param bold,italic Is text bold/italic?
#' @param fontname Font name
#' @param fontfile Font file
#' @return a logical vector, if a character element is containing at least
#' a glyph that can not be matched in the font table, FALSE is returned.
#'
#' @examples
#' glyphs_match(letters)
#' glyphs_match("\u265E", bold = TRUE)
#' @export
glyphs_match <- function(x, fontname = "sans", bold = FALSE, italic = FALSE, fontfile = "") {
  glyphs_match_(x = x, fontname = fontname, bold = bold, italic = italic, fontfile = fontfile)
}


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
