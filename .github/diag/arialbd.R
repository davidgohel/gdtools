# Temporary diagnostic: why do the glyph and Cairo engines disagree on the
# width of a Greek string in Arial Bold on Windows?
pkgload::load_all(".", quiet = TRUE)

x <- "\u03a9\u03bc\u03ad\u03b3\u03b1"
chars <- strsplit(x, "")[[1]]
size <- 10

for (weight in c("normal", "bold")) {
  font <- systemfonts::match_fonts("sans", weight = weight)
  cat("\n==== sans", weight, ":", font$path, "index", font$index, "\n")
  cat("size:", file.size(font$path), " md5:", unname(tools::md5sum(font$path)), "\n")
  info <- systemfonts::font_info(path = font$path, index = font$index)
  print(info[, intersect(names(info), c("family", "style", "n_glyphs", "max_ascend", "max_descend"))])

  n <- length(chars)
  b <- weight == "bold"
  g <- glyph_metrics_(chars, rep("sans", n), rep(size, n), rep(b, n), rep(FALSE, n), rep("", n))
  cc <- m_str_metrics_(chars, rep("sans", n), rep(size, n), rep(as.integer(b), n), rep(0L, n), rep("", n))
  gi <- systemfonts::glyph_info(chars, path = font$path, index = font$index, size = 100, res = 1e4)
  print(data.frame(
    char = sprintf("U+%04X", vapply(chars, utf8ToInt, 0L)),
    glyph_index = gi$index, glyph_name = gi$name,
    glyph_w = round(g$width, 4), cairo_w = round(cc$width, 4), diff = round(g$width - cc$width, 4)
  ))

  gs <- glyph_metrics_(x, "sans", size, b, FALSE, "")
  cs <- m_str_metrics_(x, "sans", size, as.integer(b), 0L, "")
  cat(sprintf("string: glyph=%.4f (sum chars %.4f) | cairo=%.4f (sum chars %.4f)\n",
    gs$width, sum(g$width), cs$width, sum(cc$width)))

  # pairs: does Cairo's string width differ from the sum of its characters?
  pairs <- paste0(chars[-n], chars[-1])
  pc <- m_str_metrics_(pairs, rep("sans", n - 1), rep(size, n - 1), rep(as.integer(b), n - 1), rep(0L, n - 1), rep("", n - 1))$width
  print(data.frame(pair = pairs, cairo_pair = round(pc, 4), cairo_sum = round(cc$width[-n] + cc$width[-1], 4)))
}
cat("\ncairo", format(version_cairo()), "freetype", format(version_freetype()),
  "systemfonts", format(packageVersion("systemfonts")), "\n")
