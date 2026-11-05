# Reference metrics measured with Cairo, used by tests/testthat/test-glyph-metrics.R.
#
# Fonts are the Liberation files shipped by fontquiver, so every machine
# measures the same font files. The values were generated with the Cairo
# engine (`m_str_metrics_()`, removed since then; the last released version
# using it is 0.5.2), from the package root at commit 26dbd8a:
#
#   pkgload::load_all(); source("data-src/glyph-reference.R")
#
# Kept as a record of how tests/testthat/fixtures/glyph-reference.csv was made.
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
