context("font file metric info")

test_that("a string has positive dimensions", {
  skip_if_not_installed("fontquiver")
  file <- fontquiver::font("Bitstream Vera", "Sans", "Bold")$ttf
  value <- str_metrics(x = "Hello World", fontsize = 12, fontfile = file)
  expect_true(value["width"] > 0)
  expect_true(value["ascent"] > 0)
  expect_false(value["descent"] < 0)
})

test_that("m_str_extents and gplyphs_match works ", {
  expect_true(all(glyphs_match(letters)))

  mstre <- m_str_extents(letters, fontsize = 1:26)
  expect_equal(dim(mstre), c(26, 2))
  expect_true(all(is.numeric(mstre)))

  mstre <- m_str_extents(letters[1:3],
    bold = c(TRUE, FALSE, TRUE),
    italic = c(FALSE, TRUE, TRUE),
    fontname = c("sans", "sans", "sans")
  )
  expect_equal(dim(mstre), c(3, 2))
  expect_true(all(is.numeric(mstre)))
})
