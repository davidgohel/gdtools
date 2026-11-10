#' @title Get font metrics for a string.
#'
#' @description Compute the width, ascent and descent of a single
#' string in points, from the metrics stored in the font file.
#'
#' @note This function will be deprecated in a future release.
#' Use [strings_sizes()] instead.
#'
#' @return A named numeric vector with elements `width`,
#' `ascent` and `descent` (unit is points).
#' @param x Character vector of strings to measure (only the first element is used).
#' @param bold,italic Is text bold/italic?
#' @param fontname Font name.
#' @param fontsize Font size in points.
#' @param fontfile Path to a font file. If empty, the font is
#' resolved by name via 'systemfonts'.
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
#' For each `x` element, determines the width and height of a bounding box that's big enough
#' to (just) enclose the provided text. Unit is points.
#'
#' @note This function is deprecated and will be removed in a future
#' release. Use [strings_sizes()] instead, which returns the width, the
#' ascent and the descent in inches (the height is the sum of the ascent
#' and the descent).
#' @param x Character vector of strings to measure
#' @param bold,italic Is text bold/italic? A logical vector, recycled to match `x`.
#' @param fontname Font name. A character vector, recycled to match `x`.
#' @param fontsize Font size. A numeric vector, recycled to match `x`.
#' @param fontfile Font file. A character vector, recycled to match `x`.
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
#' - the width is the sum of the glyph advances; with
#'   `kerning = TRUE`, the kerning between consecutive glyphs is
#'   added (see below);
#' - the ascent and the descent are those of the box enclosing
#'   the ink of the glyphs, so they depend on the text
#'   (`"xxx"` has no descent).
#'
#' The results only depend on the font file: the same file gives
#' the same values on every platform. They are accurate for
#' devices whose rendering finds the same font -- this is
#' guaranteed for 'systemfonts'-based devices (ragg, svglite,
#' ggiraph) and true for `cairo_pdf()` when
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
#'   and recycled to match the length of `x`.
#' @param fontname A character vector specifying the font family name (e.g., "sans", "serif", "mono").
#'   Default is "sans". This argument is vectorized.
#' @param fontsize A numeric vector specifying the font size in points.
#'   Default is 10. This argument is vectorized.
#' @param bold A logical vector indicating whether the text should be bold.
#'   Default is FALSE. This argument is vectorized.
#' @param italic A logical vector indicating whether the text should be italic.
#'   Default is FALSE. This argument is vectorized.
#' @param kerning If `TRUE`, the width includes the kerning stored in the
#'   font file, as devices that kern when drawing (ragg, svglite, ggiraph,
#'   `cairo_pdf()`). Default is `FALSE`, the width is then the sum
#'   of the glyph advances. A single logical value.
#' @section Kerning:
#' Kerning adjusts the space between some pairs of glyphs (for example
#' "AV" or "To"). With `kerning = TRUE`, the adjustments are read from the
#' tables of the font file and added to the width, without text shaping:
#'
#' - a single table is used: 'kerx' when the font has one, otherwise
#'   'GPOS' when it has a 'kern' feature, otherwise the 'kern' table;
#' - in 'GPOS', the lookups of the 'kern' feature for the script of the
#'   text are used; the script (Latin, Greek or Cyrillic) is guessed from
#'   the first letter of the string, other strings use the default script;
#' - adjustments of single glyphs and of pairs of glyphs are applied;
#'   contextual kerning is not;
#' - ligatures and other glyph substitutions are not applied, so the width
#'   of a string such as `"office"` may differ from the drawn text with
#'   fonts that substitute glyphs by default;
#' - right-to-left and complex scripts are not shaped.
#' @examples
#' strings_sizes(letters)
#' strings_sizes("AVATAR", fontsize = 12)$width
#' strings_sizes("AVATAR", fontsize = 12, kerning = TRUE)$width
#' strings_sizes("Hello World!", bold = TRUE, italic = FALSE,
#'   fontname = "sans", fontsize = 12)
#' @family functions for font metrics
#' @export
strings_sizes <- function(
  x,
  fontname = "sans",
  fontsize = 10,
  bold = FALSE,
  italic = FALSE,
  kerning = FALSE
) {
  stopifnot(
    is.character(x),
    is.character(fontname),
    is.numeric(fontsize),
    is.logical(bold),
    is.logical(italic),
    is.logical(kerning),
    length(kerning) == 1,
    !is.na(kerning)
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
    rep("", max_length),
    kerning = kerning
  )
  # lighter than data.frame(), same object
  structure(
    list(
      width = z$width / 72,
      ascent = z$ascent / 72,
      descent = z$descent / 72
    ),
    class = "data.frame",
    row.names = .set_row_names(max_length)
  )
}

#' @title Line metrics of fonts
#' @description
#' Vertical metrics of the lines of text written with a font, read from the
#' font file: the part of a line above its baseline (`ascent`), the part
#' below (`descent`) and their sum, the distance between the baselines of two
#' lines in single spacing (`line_height`). Multiply `line_height` by a line
#' spacing factor (1.5 for example) to get the distance between baselines with
#' this spacing.
#'
#' The values follow the rule of the text metrics of Windows, applied by
#' 'Microsoft Word' for single line spacing: `ascent` is the `usWinAscent` of
#' the 'OS/2' table plus the external leading, `descent` is its
#' `usWinDescent`; the external leading is the line gap of the 'hhea' table,
#' reduced by what `usWinAscent` and `usWinDescent` add to the ascender and
#' descender of 'hhea', and not negative. Fonts without these values use the
#' ascender, descender and line gap of 'hhea'.
#'
#' These metrics depend on the font only, unlike the ascent and descent
#' returned by [strings_sizes()], which are those of the ink of the glyphs
#' of a string. Fonts are found as with [strings_sizes()].
#'
#' @param fontname A character vector of font family names. This argument is
#'   vectorized, as `fontsize`, `bold` and `italic`: they are recycled to the
#'   length of the longest one.
#' @param fontsize A numeric vector of font sizes in points.
#' @param bold,italic Logical vectors, for the bold and italic faces.
#' @return A data.frame with columns `ascent`, `descent` and `line_height`,
#'   in inches, one row per font.
#' @examples
#' font_line_metrics(c("sans", "serif"), fontsize = 12)
#' # distance between baselines with a line spacing of 1.5, in points
#' font_line_metrics("sans", fontsize = 12)$line_height * 1.5 * 72
#' @family functions for font metrics
#' @seealso [strings_sizes()]
#' @export
font_line_metrics <- function(
  fontname = "sans",
  fontsize = 10,
  bold = FALSE,
  italic = FALSE
) {
  stopifnot(
    is.character(fontname),
    is.numeric(fontsize),
    is.logical(bold),
    is.logical(italic)
  )
  n <- max(length(fontname), length(fontsize), length(bold), length(italic))
  fontname <- rep(fontname, length.out = n)
  fontsize <- rep(fontsize, length.out = n)
  bold <- rep(bold, length.out = n)
  italic <- rep(italic, length.out = n)

  key <- paste(fontname, bold, italic, sep = "\r")
  first <- which(!duplicated(key))
  font_id <- match(key, key[first])
  fonts <- resolve_fonts_(
    fontname = fontname[first],
    bold = bold[first],
    italic = italic[first],
    fontfile = rep("", length(first))
  )
  m <- font_line_metrics_(fonts$path, fonts$index)
  if (any(m$failed)) {
    # same fallback as strings_sizes()
    failed <- which(m$failed)
    warning(
      "Unable to load font: ",
      paste(unique(fonts$label[failed]), collapse = ", "),
      ", using 'sans' instead.",
      call. = FALSE
    )
    sans <- resolve_fonts_(
      fontname = rep("sans", length(failed)),
      bold = fonts$bold[failed],
      italic = fonts$italic[failed],
      fontfile = rep("", length(failed))
    )
    m2 <- font_line_metrics_(sans$path, sans$index)
    m$ascent[failed] <- m2$ascent
    m$descent[failed] <- m2$descent
    m$line_height[failed] <- m2$line_height
  }
  k <- fontsize / 72
  structure(
    list(
      ascent = m$ascent[font_id] * k,
      descent = m$descent[font_id] * k,
      line_height = m$line_height[font_id] * k
    ),
    class = "data.frame",
    row.names = .set_row_names(n)
  )
}
