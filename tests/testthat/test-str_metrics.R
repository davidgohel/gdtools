context("font file metric info")


test_that("a string has positive dimensions", {
  skip_if_not_installed("fontquiver")
  file <- fontquiver::font("Bitstream Vera", "Sans", "Bold")$ttf
  value <- str_metrics(x = "Hello World", fontsize = 12, fontfile = file )
  expect_true( value["width"] > 0)
  expect_true( value["ascent"] > 0 )
  expect_false( value["descent"] < 0 )
})
