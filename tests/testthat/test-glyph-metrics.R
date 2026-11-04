# The glyph engine (systemfonts) must give the same metrics as Cairo, and
# the same metrics on every platform for the same font files.

read_reference <- function() {
  ref <- utils::read.csv(
    test_path("fixtures", "glyph-reference.csv"),
    stringsAsFactors = FALSE
  )
  cases <- reference_cases()
  stopifnot(
    nrow(ref) == nrow(cases),
    all(ref$string_id == cases$string_id),
    all(ref$family == cases$family),
    all(ref$face == cases$face),
    all(ref$size == cases$size)
  )
  list(cases = cases, ref = ref)
}

max_abs_diff <- function(a, b) {
  max(abs(a - b))
}

glyph_of_cases <- function(cases) {
  n <- nrow(cases)
  glyph_metrics_(
    cases$x,
    fontname = rep("", n),
    fontsize = cases$size,
    bold = rep(FALSE, n),
    italic = rep(FALSE, n),
    fontfile = cases$file
  )
}

test_that("glyph engine matches the Cairo reference values", {
  skip_if_not_installed("fontquiver")
  x <- read_reference()
  glyph <- glyph_of_cases(x$cases)
  # points; Cairo reference measured on macOS (cairo 1.18.6)
  expect_lt(max_abs_diff(glyph$width, x$ref$width), 0.02)
  expect_lt(max_abs_diff(glyph$ascent, x$ref$ascent), 0.005)
  expect_lt(max_abs_diff(glyph$descent, x$ref$descent), 0.005)
})

test_that("Cairo engine gives the reference values on this platform", {
  skip_on_cran()
  skip_if_not_installed("fontquiver")
  x <- read_reference()
  n <- nrow(x$cases)
  cairo <- m_str_metrics_(
    x$cases$x,
    rep("", n),
    x$cases$size,
    rep(0L, n),
    rep(0L, n),
    x$cases$file
  )
  # reference values are rounded to 1e-6
  expect_lt(max_abs_diff(cairo$width, x$ref$width), 2e-6)
  expect_lt(max_abs_diff(cairo$ascent, x$ref$ascent), 2e-6)
  expect_lt(max_abs_diff(cairo$descent, x$ref$descent), 2e-6)
})

test_that("fonts resolved by name give the reference values", {
  skip_if_not_installed("fontquiver")
  # Liberation files from fontquiver, registered under names that cannot
  # exist on the machine: a system "Liberation Sans" may be another version.
  families <- c(
    sans = "gdtools-test-sans",
    serif = "gdtools-test-serif",
    mono = "gdtools-test-mono"
  )
  register_liberationsans(name = families[["sans"]])
  register_liberationserif(name = families[["serif"]])
  register_liberationmono(name = families[["mono"]])

  x <- read_reference()
  n <- nrow(x$cases)
  fontname <- unname(families[x$cases$family])
  bold <- x$cases$face %in% c("bold", "bolditalic")
  italic <- x$cases$face %in% c("italic", "bolditalic")

  glyph <- glyph_metrics_(
    x$cases$x,
    fontname = fontname,
    fontsize = x$cases$size,
    bold = bold,
    italic = italic,
    fontfile = rep("", n)
  )
  expect_lt(max_abs_diff(glyph$width, x$ref$width), 0.02)
  expect_lt(max_abs_diff(glyph$ascent, x$ref$ascent), 0.005)
  expect_lt(max_abs_diff(glyph$descent, x$ref$descent), 0.005)

  skip_on_cran()
  cairo <- m_str_metrics_(
    x$cases$x,
    fontname,
    x$cases$size,
    as.integer(bold),
    as.integer(italic),
    rep("", n)
  )
  expect_lt(max_abs_diff(cairo$width, x$ref$width), 2e-6)
  expect_lt(max_abs_diff(cairo$ascent, x$ref$ascent), 2e-6)
  expect_lt(max_abs_diff(cairo$descent, x$ref$descent), 2e-6)
})

test_that("glyph engine handles empty, NA and invalid strings", {
  x <- c("", " ", NA_character_, "\xff", "abc")
  res <- glyph_metrics_(
    x,
    fontname = rep("sans", 5),
    fontsize = rep(10, 5),
    bold = rep(FALSE, 5),
    italic = rep(FALSE, 5),
    fontfile = rep("", 5)
  )
  expect_equal(unlist(res[1, ]), c(width = 0, ascent = 0, descent = 0))
  expect_true(res$width[2] > 0)
  expect_equal(res$ascent[2], 0)
  expect_true(all(is.na(res[3, ])))
  # invalid UTF-8 is measured as an empty string, as Cairo does
  expect_equal(unlist(res[4, ]), c(width = 0, ascent = 0, descent = 0))
  expect_true(res$width[5] > 0)
})

test_that("glyph engine falls back to sans when a font cannot be read", {
  not_a_font <- tempfile(fileext = ".ttf")
  writeLines("not a font", not_a_font)
  on.exit(unlink(not_a_font))
  expect_warning(
    res <- glyph_metrics_(
      "abc",
      fontname = "",
      fontsize = 10,
      bold = FALSE,
      italic = FALSE,
      fontfile = not_a_font
    ),
    "Unable to load font"
  )
  sans <- glyph_metrics_("abc", "sans", 10, FALSE, FALSE, "")
  expect_equal(res, sans)
})
