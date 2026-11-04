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

# Temporary diagnostic for the Windows CI: worst strings, then the width of
# single characters in each font, with both engines.
width_diagnostic <- function(x, grid, glyph, cairo) {
  d <- glyph$width - cairo$width
  worst <- order(-abs(d))[1:8]
  paths <- vapply(
    seq_len(nrow(grid)),
    function(k) {
      basename(systemfonts::match_fonts(
        grid$fontname[k],
        italic = grid$italic[k],
        weight = if (grid$bold[k]) "bold" else "normal"
      )$path)
    },
    ""
  )
  rows <- sprintf(
    "%s b=%s i=%s [%s] '%s': glyph=%.4f cairo=%.4f diff=%.4f",
    grid$fontname[worst],
    grid$bold[worst],
    grid$italic[worst],
    paths[worst],
    encodeString(x[worst]),
    glyph$width[worst],
    cairo$width[worst],
    d[worst]
  )
  chars <- c("A", "a", "m", "W", "i", "1", " ", "\t", "é", "漢")
  fonts <- c("sans", "serif", "mono")
  per_char <- vapply(
    fonts,
    function(f) {
      n <- length(chars)
      g <- glyph_metrics_(chars, rep(f, n), rep(10, n), rep(FALSE, n),
        rep(FALSE, n), rep("", n))$width
      cc <- m_str_metrics_(chars, rep(f, n), rep(10, n), rep(0L, n),
        rep(0L, n), rep("", n))$width
      paste0(
        f, ": ",
        paste(sprintf("%s=%.4f/%.4f", encodeString(chars), g, cc),
          collapse = " "
        )
      )
    },
    ""
  )
  paste(
    c(
      "max width difference (glyph vs cairo). Worst strings:",
      rows,
      "Single characters (glyph/cairo):",
      per_char,
      paste("cairo", format(version_cairo()), "freetype",
        format(version_freetype()))
    ),
    collapse = "\n"
  )
}

test_that("glyph and Cairo engines agree on system fonts", {
  skip_on_cran()
  strings <- reference_strings()
  grid <- expand.grid(
    i = seq_along(strings),
    fontname = c("sans", "serif", "mono"),
    bold = c(FALSE, TRUE),
    italic = c(FALSE, TRUE),
    stringsAsFactors = FALSE
  )
  x <- strings[grid$i]
  n <- length(x)
  cairo <- m_str_metrics_(
    x,
    grid$fontname,
    rep(10, n),
    as.integer(grid$bold),
    as.integer(grid$italic),
    rep("", n)
  )
  glyph <- glyph_metrics_(
    x,
    fontname = grid$fontname,
    fontsize = rep(10, n),
    bold = grid$bold,
    italic = grid$italic,
    fontfile = rep("", n)
  )
  expect_lt(
    max_abs_diff(glyph$width, cairo$width),
    0.02,
    label = width_diagnostic(x, grid, glyph, cairo)
  )
  expect_lt(max_abs_diff(glyph$ascent, cairo$ascent), 0.005)
  expect_lt(max_abs_diff(glyph$descent, cairo$descent), 0.005)
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
