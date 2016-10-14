context("metric info")

test_that("a string has positive dimensions", {
  value <- str_extents("Hello World!")
  expect_true(all( value > 0 ))
})

test_that("known fonts have correct metrics", {
  extents <- function(ttf) as.vector(round(str_extents("foobar", fontfile = ttf), 4))
  sans <- fontquiver::font("Liberation", "Sans", "Regular")
  mono_bi <- fontquiver::font("Bitstream Vera", "Sans Mono", "Bold Oblique")
  expect_equal(extents(sans$ttf), c(34.0254, 8.8281))
  expect_equal(extents(mono_bi$ttf), c(43.3477, 9.2969))
})
