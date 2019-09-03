#' Compute string extents.
#'
#' Determines the width and height of a bounding box that's big enough
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
