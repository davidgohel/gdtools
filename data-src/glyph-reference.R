# Reference metrics measured with Cairo, used by tests/testthat/test-glyph-metrics.R.
#
# Fonts are the Liberation files shipped by fontquiver, so every machine
# measures the same font files. Run from the package root, with the Cairo
# engine still available:
#
#   pkgload::load_all(); source("data-src/glyph-reference.R")
#
# The cases are defined in tests/testthat/helper-glyph-reference.R.

source("tests/testthat/helper-glyph-reference.R")

local({
  cases <- reference_cases()
  cairo <- m_str_metrics_(
    cases$x,
    rep("", nrow(cases)),
    cases$size,
    rep(0L, nrow(cases)),
    rep(0L, nrow(cases)),
    cases$file
  )
  out <- data.frame(
    string_id = cases$string_id,
    family = cases$family,
    face = cases$face,
    size = cases$size,
    width = round(cairo$width, 6),
    ascent = round(cairo$ascent, 6),
    descent = round(cairo$descent, 6)
  )
  dir.create("tests/testthat/fixtures", showWarnings = FALSE)
  write.csv(
    out,
    "tests/testthat/fixtures/glyph-reference.csv",
    row.names = FALSE
  )
})
