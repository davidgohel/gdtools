context("font file metric info")
library(fontquiver)

test_that("a string has positive dimensions", {
  file <- fontquiver::font_bitstream_vera(style = "bold")$file
  value <- str_metrics(x = "Hello World", fontsize = 12, fontfile = file )
  expect_true( value["width"] > 0)
  expect_true( value["ascent"] > 0 )
  expect_false( value["descent"] < 0 )
})

test_that("fallback usage", {
  file <- fontquiver::font_bitstream_vera(variant = "sans", style = "bold-oblique")$file
  expect_warning(
    value_1 <- str_metrics( x = "\u265E", fontsize = 12, fontfile = file )
  )
  value_2 <- str_metrics( x = "M", fontsize = 12, fontfile = file )
  expect_equivalent(value_1, value_2)
})


