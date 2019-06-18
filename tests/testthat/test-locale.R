context("locale")

test_that("locale is not modified", {
  oldloc <- Sys.getlocale()
  fonts <- gdtools::sys_fonts()
  newloc <- Sys.getlocale()
  expect_equal(oldloc, Sys.getlocale())
})
