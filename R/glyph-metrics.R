# Text measurement from glyph metrics, without Cairo.
#
# Strings are measured in C++ (`glyph_strings_()`) with the systemfonts C
# API: each distinct glyph is measured once per font at a large reference
# size, then values are scaled to the requested size. The width is the sum
# of the glyph advances (no kerning, as Cairo's toy text API), the ascent and
# the descent are those of the union of the ink boxes of the glyphs.
#
# Values are returned in points.

# Glyph metrics are integers (pixels): measuring at a large size and a
# high resolution keeps the rounding error below 0.001 point per glyph at
# 10 points. 100 points at 1e4 dpi is about 13900 pixels per em, close to the
# largest size FreeType accepts (1000 points fails with error 23).
glyph_ref_size <- 100
glyph_ref_res <- 1e4

glyph_metrics_ <- function(x, fontname, fontsize, bold, italic, fontfile) {
  has_file <- !is.na(fontfile) & nzchar(fontfile)
  key <- ifelse(
    has_file,
    paste("file", fontfile, sep = "\r"),
    paste("name", fontname, bold, italic, sep = "\r")
  )
  first <- which(!duplicated(key))
  font_id <- match(key, key[first])
  fonts <- resolve_fonts_(
    fontname = fontname[first],
    bold = bold[first],
    italic = italic[first],
    fontfile = ifelse(has_file[first], fontfile[first], "")
  )

  m <- glyph_strings_(
    x,
    font_id,
    fonts$path,
    fonts$index,
    glyph_ref_size,
    glyph_ref_res
  )

  if (any(m$failed)) {
    # The file found by systemfonts may not be readable by its FreeType,
    # e.g. reserved macOS system fonts. Same fallback as ragg: warn and use
    # the default sans-serif font.
    failed <- sort(unique(font_id[m$failed]))
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
    redo <- m$failed
    m[redo, ] <- glyph_strings_(
      x[redo],
      match(font_id[redo], failed),
      sans$path,
      sans$index,
      glyph_ref_size,
      glyph_ref_res
    )
  }

  scale <- fontsize / glyph_ref_size * 72 / glyph_ref_res
  data.frame(
    width = m$width * scale,
    ascent = m$ascent * scale,
    descent = m$descent * scale,
    stringsAsFactors = FALSE
  )
}

# Font file and index for each font description, resolved by systemfonts.
resolve_fonts_ <- function(fontname, bold, italic, fontfile) {
  path <- fontfile
  index <- integer(length(fontfile))
  by_name <- !nzchar(fontfile)
  if (any(by_name)) {
    found <- systemfonts::match_fonts(
      family = fontname[by_name],
      italic = italic[by_name],
      weight = ifelse(bold[by_name], "bold", "normal")
    )
    path[by_name] <- found$path
    index[by_name] <- found$index
  }
  data.frame(
    path = path,
    index = index,
    label = ifelse(by_name, fontname, fontfile),
    bold = bold,
    italic = italic,
    stringsAsFactors = FALSE
  )
}
