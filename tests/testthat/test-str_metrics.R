context("font file metric info")
library(fontquiver)

test_that("a string has positive dimensions", {
  sans_ <- font_families("Bitstream Vera")$sans
  value <- str_metrics(x = "Hello World", fontsize = 12, bold = TRUE, italic = TRUE,
                       fontfile = c(sans_$bold$file) )
  expect_true( value["width"] > 0)
  expect_true( value["ascent"] > 0 )
  expect_false( value["descent"] < 0 )
})

test_that("fallback usage", {
  sans_ <- font_families("Bitstream Vera")$sans
  expect_warning(
    value_1 <- str_metrics(
      x = "\u265E", fontsize = 12, bold = FALSE, italic = FALSE,
      fontfile = sans_$bolditalic$file
    )
  )
  value_2 <- str_metrics(
    x = "M", fontsize = 12, bold = FALSE, italic = FALSE,
    fontfile = sans_$bolditalic$file)
  expect_equivalent(value_1, value_2)
})


