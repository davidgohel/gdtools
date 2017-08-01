context("metric info")

test_that("a string has positive dimensions", {
  value <- str_extents("Hello World!")
  expect_true(all( value > 0 ))
})

extents <- function(font, ...) {
  extents <- str_extents("foobar", fontfile = font$ttf, ...)
  as.vector(round(extents, 4))
}


test_that("known fonts have correct metrics", {
  skip_if_not_installed("fontquiver")
  sans <- fontquiver::font("Liberation", "Sans", "Regular")
  mono_bi <- fontquiver::font("Bitstream Vera", "Sans Mono", "Bold Oblique")
  expect_equal(extents(sans), c(34.0254, 8.8281), tolerance = .1)
  expect_equal(extents(mono_bi), c(43.3477, 9.2969), tolerance = .1)
})

test_that("fractional font sizes are correctly measured", {
  skip_if_not_installed("fontquiver")
  sans <- fontquiver::font("Liberation", "Sans", "Regular")
  if (version_freetype() < "2.6.0") {
    skip("Old FreeType return different extents for fractional sizes")
  }
  expect_equal(extents(sans, fontsize = 15.05), c(42.5317, 11.0156), tolerance = .2)
})
