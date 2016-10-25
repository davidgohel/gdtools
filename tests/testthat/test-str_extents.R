context("metric info")

test_that("a string has positive dimensions", {
  value <- str_extents("Hello World!")
  expect_true(all( value > 0 ))
})

extents <- function(font, ...) {
  extents <- str_extents("foobar", fontfile = font$ttf, ...)
  as.vector(round(extents, 4))
}
sans <- fontquiver::font("Liberation", "Sans", "Regular")
mono_bi <- fontquiver::font("Bitstream Vera", "Sans Mono", "Bold Oblique")

test_that("known fonts have correct metrics", {
  expect_equal(extents(sans), c(34.0254, 8.8281))
  expect_equal(extents(mono_bi), c(43.3477, 9.2969))
})

test_that("fractional font sizes are correctly measured", {
  if (version_freetype() < "2.6.3") {
    skip("Old FreeType return different extents for fractional sizes")
  }
  expect_equal(extents(sans, fontsize = 15.05), c(42.5317, 11.0156))
})
