# Text measurement from the metrics stored in font files, without Cairo.
#
# Strings are measured in C++ (`glyph_strings_()`) with FreeType: each
# distinct glyph is read once per font, unscaled and unhinted, in font units.
# The width is the sum of the glyph advances of the 'hmtx' table (no
# kerning, as HarfBuzz and Cairo's toy text API), the ascent and the descent
# are those of the union of the ink boxes of the glyph outlines. Values are
# exact: they only depend on the font file.
#
# Fonts are resolved by systemfonts; files are opened by the FreeType gdtools
# is linked with, not the one of systemfonts.
#
# Values are returned in points, as a list of three numeric vectors (width,
# ascent, descent): building a data.frame costs more than measuring a few
# strings.

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
    fonts$index
  )

  if (any(m$failed)) {
    # The file found by systemfonts may not be readable, e.g. reserved
    # macOS system fonts with some FreeType builds. Same fallback as ragg:
    # warn and use the default sans-serif font.
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
    m2 <- glyph_strings_(
      x[redo],
      match(font_id[redo], failed),
      sans$path,
      sans$index
    )
    m$width[redo] <- m2$width
    m$ascent[redo] <- m2$ascent
    m$descent[redo] <- m2$descent
  }

  # values are in em
  list(
    width = m$width * fontsize,
    ascent = m$ascent * fontsize,
    descent = m$descent * fontsize
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
  list(
    path = path,
    index = index,
    label = ifelse(by_name, fontname, fontfile),
    bold = bold,
    italic = italic
  )
}
