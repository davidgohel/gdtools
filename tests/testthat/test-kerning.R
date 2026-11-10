# Kerning read from the tables of test fonts built for these tests (see
# data-src/kerning-fonts.py): each font has chosen advances and a chosen
# kerning, so the expected widths are written by hand.
#
# 1000 units per em, measured at 1000 points: widths are in font units.
# Advances: space 250, A 600, V 500, T 550, o 450, Y 520, period 200,
# Alpha (U+0391) 610, De (U+0414) 630.

kerning_font <- function(name) {
  test_path("fixtures", "kerning", paste0(name, ".ttf"))
}

width_units <- function(font, x, kerning = TRUE) {
  n <- length(x)
  glyph_metrics_(
    x,
    fontname = rep("", n),
    fontsize = rep(1000, n),
    bold = rep(FALSE, n),
    italic = rep(FALSE, n),
    fontfile = rep(kerning_font(font), n),
    kerning = kerning
  )$width
}

test_that("without kerning, the width is the sum of the advances", {
  expect_equal(width_units("gpos-pairs", c("AV", "To"), kerning = FALSE), c(1100, 1000))
  expect_equal(width_units("kerx", c("AV", "To"), kerning = FALSE), c(1100, 1000))
})

test_that("GPOS pairs of glyphs and of classes, first subtable wins", {
  # lookup: pair A V -20 (format 1), then classes [A Alpha] x [V Y] -70
  # (format 2)
  expect_equal(
    width_units("gpos-pairs", c("AV", "AY", "ΑV", "TV", "VA", "AVAV")),
    c(1100 - 20, 1120 - 70, 1110 - 70, 1050, 1100, 2200 - 40)
  )
})

test_that("GPOS pair with a value for the second glyph skips it", {
  # A V: -30 on A and -10 on V; V Y -40
  expect_equal(
    width_units("gpos-second", c("AV", "VY", "AVY")),
    c(1100 - 40, 1020 - 40, 1620 - 40)
  )
})

test_that("GPOS single adjustments and extension lookups", {
  # space -50 (single adjustment), T o -60 (pair), both in extension lookups
  expect_equal(
    width_units("gpos-single", c(" ", "  ", "To", "T o")),
    c(250 - 50, 500 - 100, 1000 - 60, 1250 - 50)
  )
})

test_that("GPOS lookups depend on the script of the text", {
  # A V: -80 for latn, -30 for grek, -10 for DFLT (used for cyrl, absent)
  expect_equal(
    width_units(
      "gpos-scripts",
      c("AV", ".AV", "ΑAV", "ДAV")
    ),
    c(1100 - 80, 1300 - 80, 1710 - 30, 1730 - 10)
  )
})

test_that("OpenType kern table, override and cross-stream subtables", {
  # A V -45 and T o -60; then A V -5 overriding; cross-stream A V ignored
  expect_equal(
    width_units("kern-opentype", c("AV", "To")),
    c(1100 - 5, 1000 - 60)
  )
})

test_that("GPOS is used when it has a kern feature, the kern table otherwise", {
  # GPOS kern A V -80, kern table A V -45 and T o -60
  expect_equal(width_units("gpos-and-kern", c("AV", "To")), c(1100 - 80, 1000))
  # GPOS without kern feature (dist A V -99), kern table A V -45
  expect_equal(width_units("gpos-no-kern-feature", "AV"), 1100 - 45)
})

test_that("Apple kern table, formats 0, 2 and 3", {
  # format 0: A V -45, T o -60, vertical subtable ignored
  expect_equal(
    width_units("kern-apple-0", c("AV", "To")),
    c(1100 - 45, 1000 - 60)
  )
  # formats 2 and 3: classes A x [V Y] -70, T x o -60
  x <- c("AV", "AY", "To", "TV", "VA", "oT")
  expected <- c(1100 - 70, 1120 - 70, 1000 - 60, 1050, 1100, 1000)
  expect_equal(width_units("kern-apple-2", x), expected)
  expect_equal(width_units("kern-apple-3", x), expected)
})

test_that("kerx is used before GPOS", {
  # kerx A V -25, T o -35, vertical subtable ignored; GPOS kern A V -80
  expect_equal(width_units("kerx", c("AV", "To")), c(1100 - 25, 1000 - 35))
  # kerx without horizontal subtable: no kerning, GPOS is not used
  expect_equal(width_units("kerx-vertical", "AV"), 1100)
})

test_that("broken tables do not fail", {
  # truncated GPOS
  w <- width_units("broken-gpos", c("AV", "To", "AVATAR"))
  expect_true(all(is.finite(w)))
  # kern subtable announcing 5000 pairs, holding one (A V -45)
  expect_equal(width_units("broken-kern", c("AV", "To")), c(1100 - 45, 1000))
})

test_that("kerning changes the width only", {
  skip_if_not_installed("fontquiver")
  register_liberationsans(name = "gdtools-test-sans")
  x <- c("AVATAR", "To", "minimum", "", NA)
  plain <- strings_sizes(x, fontname = "gdtools-test-sans", fontsize = 12)
  kerned <- strings_sizes(
    x,
    fontname = "gdtools-test-sans",
    fontsize = 12,
    kerning = TRUE
  )
  expect_lt(kerned$width[1], plain$width[1])
  expect_lt(kerned$width[2], plain$width[2])
  expect_identical(kerned$width[3:4], plain$width[3:4])
  expect_true(is.na(kerned$width[5]))
  expect_identical(kerned$ascent, plain$ascent)
  expect_identical(kerned$descent, plain$descent)
})

test_that("kerning must be a single logical value", {
  expect_error(strings_sizes("a", kerning = NA))
  expect_error(strings_sizes("a", kerning = c(TRUE, FALSE)))
  expect_error(strings_sizes("a", kerning = "yes"))
})
