context("font file metric info")

test_that("a string has positive dimensions", {
  skip_if_not_installed("fontquiver")
  file <- fontquiver::font("Bitstream Vera", "Sans", "Bold")$ttf
  value <- str_metrics(x = "Hello World", fontsize = 12, fontfile = file)
  expect_true(value["width"] > 0)
  expect_true(value["ascent"] > 0)
  expect_false(value["descent"] < 0)
})

test_that("strings_sizes face mapping is correct", {
  # italic must use face 3, not face 4 (bold-italic)
  plain <- strings_sizes("Test", fontname = "sans", fontsize = 12)
  bold <- strings_sizes("Test", fontname = "sans", fontsize = 12, bold = TRUE)
  italic <- strings_sizes("Test", fontname = "sans", fontsize = 12, italic = TRUE)
  bi <- strings_sizes("Test", fontname = "sans", fontsize = 12, bold = TRUE, italic = TRUE)

  # italic and bold-italic must differ
  expect_false(italic$width == bi$width)
  # all faces must return positive widths
  expect_true(all(c(plain$width, bold$width, italic$width, bi$width) > 0))
})

test_that("strings_sizes vectorised faces are correct", {
  res <- strings_sizes(
    rep("Test", 4),
    fontname = "sans", fontsize = 12,
    bold = c(FALSE, TRUE, FALSE, TRUE),
    italic = c(FALSE, FALSE, TRUE, TRUE)
  )
  # italic (row 3) and bold-italic (row 4) must differ
  expect_false(res$width[3] == res$width[4])
})

test_that("NA strings produce NA metrics", {
  res <- strings_sizes(c("hello", NA_character_, "world"))
  expect_true(is.na(res$width[2]))
  expect_true(is.na(res$ascent[2]))
  expect_true(is.na(res$descent[2]))
  expect_true(res$width[1] > 0)
  expect_true(res$width[3] > 0)

  mstre <- m_str_extents(c("a", NA_character_), fontsize = 12)
  expect_true(is.na(mstre[2, 1]))
  expect_true(is.na(mstre[2, 2]))
  expect_true(mstre[1, 1] > 0)
})

test_that("m_str_extents works ", {

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
