# Metrics must equal the reference values on every platform: they are read
# from the same font files (Liberation, shipped by fontquiver). The reference
# values were measured with Cairo, used by gdtools up to version 0.5.2.

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

test_that("font files give the reference values", {
  skip_if_not_installed("fontquiver")
  x <- read_reference()
  glyph <- glyph_of_cases(x$cases)
  # points, rounded to 1e-6
  expect_lt(max_abs_diff(glyph$width, x$ref$width), 2e-6)
  expect_lt(max_abs_diff(glyph$ascent, x$ref$ascent), 2e-6)
  expect_lt(max_abs_diff(glyph$descent, x$ref$descent), 2e-6)
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
  expect_lt(max_abs_diff(glyph$width, x$ref$width), 2e-6)
  expect_lt(max_abs_diff(glyph$ascent, x$ref$ascent), 2e-6)
  expect_lt(max_abs_diff(glyph$descent, x$ref$descent), 2e-6)
})

test_that("glyph engine handles empty, NA and invalid strings", {
  # declared UTF-8, so that it is invalid whatever the native encoding: in a
  # Windows-1252 session (R < 4.2 on Windows), "\xff" is a valid "y diaeresis"
  invalid <- "\xff"
  Encoding(invalid) <- "UTF-8"
  x <- c("", " ", NA_character_, invalid, "abc")
  res <- glyph_metrics_(
    x,
    fontname = rep("sans", 5),
    fontsize = rep(10, 5),
    bold = rep(FALSE, 5),
    italic = rep(FALSE, 5),
    fontfile = rep("", 5)
  )
  row <- function(i) vapply(res, function(z) z[i], 0)
  expect_equal(row(1), c(width = 0, ascent = 0, descent = 0))
  expect_true(res$width[2] > 0)
  expect_equal(res$ascent[2], 0)
  expect_true(all(is.na(row(3))))
  # invalid UTF-8 is measured as an empty string
  expect_equal(row(4), c(width = 0, ascent = 0, descent = 0))
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
