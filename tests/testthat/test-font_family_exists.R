context("font family exists")

test_that("an invalid fontname does not match any family", {
  expect_false( font_family_exists("that font does not exists") )
})

test_that("an valid fontname does has a match", {
  sys_fonts_ <- sys_fonts()
  if( nrow(sys_fonts_) > 0 ) {
    sys_fonts_ <- head(sys_fonts_, n = 1 )
    family <- as.character(sys_fonts_$family)
    expect_true( font_family_exists(family) )
  }
})

test_that("no crash after loading Fontconfig via Cairo devices", {
  grDevices::svg(tempfile())
  graphics::plot(1:10)
  grDevices::dev.off()

  expect_error(match_family("sans"), NA)
})
