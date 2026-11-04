#' @title Get font metrics for a string.
#'
#' @description Compute the width, ascent and descent of a single
#' string in points, from the metrics stored in the font file.
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
str_metrics <- function(
  x,
  fontname = "sans",
  fontsize = 12,
  bold = FALSE,
  italic = FALSE,
  fontfile = ""
) {
  z <- glyph_metrics_(
    x = x[1],
    fontname = fontname[1],
    fontsize = fontsize[1],
    bold = bold[1],
    italic = italic[1],
    fontfile = fontfile[1]
  )
  c(width = z$width, ascent = z$ascent, descent = z$descent)
}

#' Compute string extents for a vector of strings.
#'
#' For each \code{x} element, determines the width and height of a bounding box that's big enough
#' to (just) enclose the provided text. Unit is points.
#'
#' @note This function is deprecated and will be removed in a future
#' release. Use [strings_sizes()] instead, which returns the width, the
#' ascent and the descent in inches (the height is the sum of the ascent
#' and the descent).
#' @param x Character vector of strings to measure
#' @param bold,italic Is text bold/italic? A logical vector, recycled to match \code{x}.
#' @param fontname Font name. A character vector, recycled to match \code{x}.
#' @param fontsize Font size. A numeric vector, recycled to match \code{x}.
#' @param fontfile Font file. A character vector, recycled to match \code{x}.
#' @family functions for font metrics
#' @export
#' @keywords internal
m_str_extents <- function(
  x,
  fontname = "sans",
  fontsize = 10,
  bold = FALSE,
  italic = FALSE,
  fontfile = NULL
) {
  .Deprecated(new = "strings_sizes")
  stopifnot(
    is.character(x),
    is.character(fontname),
    is.numeric(fontsize),
    is.logical(bold),
    is.logical(italic),
    is.character(fontfile) || is.null(fontfile)
  )

  max_length <- length(x)
  fontname <- rep(fontname, length.out = max_length)
  fontsize <- rep(fontsize, length.out = max_length)
  bold <- rep(bold, length.out = max_length)
  italic <- rep(italic, length.out = max_length)

  if (is.null(fontfile)) {
    fontfile <- rep("", length.out = max_length)
  } else {
    fontfile <- rep(fontfile, length.out = max_length)
  }

  z <- glyph_metrics_(x, fontname, fontsize, bold, italic, fontfile)
  cbind(z$width, z$ascent + z$descent)
}


#' @title Compute strings sizes
#' @description
#' Determines widths, ascent and descent in inches.
#' Font lookup is performed by 'systemfonts' (so any font
#' registered via [systemfonts::register_font()],
#' [register_gfont()], or [font_set()] is found), then the
#' metrics stored in the font file are read with FreeType,
#' without scaling or hinting:
#'
#' - the width is the sum of the glyph advances (no kerning);
#' - the ascent and the descent are those of the box enclosing
#'   the ink of the glyphs, so they depend on the text
#'   (`"xxx"` has no descent).
#'
#' The results only depend on the font file: the same file gives
#' the same values on every platform. They are accurate for
#' devices whose rendering finds the same font -- this is
#' guaranteed for 'systemfonts'-based devices (ragg, svglite,
#' ggiraph) and true for Cairo devices (`cairo_pdf()`, ...) when
#' the font is also installed at the system level. For devices
#' with their own font engine (`pdf()`, `png()`, ...) the
#' metrics may not match the rendering.
#'
#' When the font file found cannot be read, a warning is issued
#' and the default sans-serif font is used. `NA` strings give
#' `NA` metrics; invalid UTF-8 strings are measured as empty
#' strings.
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
strings_sizes <- function(
  x,
  fontname = "sans",
  fontsize = 10,
  bold = FALSE,
  italic = FALSE
) {
  stopifnot(
    is.character(x),
    is.character(fontname),
    is.numeric(fontsize),
    is.logical(bold),
    is.logical(italic)
  )

  max_length <- length(x)
  fontname <- rep(fontname, length.out = max_length)
  fontsize <- rep(fontsize, length.out = max_length)
  bold <- rep(bold, length.out = max_length)
  italic <- rep(italic, length.out = max_length)

  z <- glyph_metrics_(
    x,
    fontname,
    fontsize,
    bold,
    italic,
    rep("", max_length)
  )
  z$width <- z$width / 72
  z$ascent <- z$ascent / 72
  z$descent <- z$descent / 72
  z
}
