test_that("generic utils work", {
  ve_c <- version_cairo()

  expect_true(ve_c > numeric_version('0'))
  expect_s3_class(ve_c, "package_version")
  expect_s3_class(ve_c, "numeric_version")

  ve_ft <- version_freetype()

  expect_true(ve_ft > numeric_version('0'))
  expect_s3_class(ve_ft, "package_version")
  expect_s3_class(ve_ft, "numeric_version")

  skip_on_cran()
  font_set_liberation()
  expect_true(is.character(match_family("serif")))
  expect_true(is.character(match_family("sans", bold = FALSE, italic = FALSE)))
})

test_that("set_dummy_conf is deprecated", {
  expect_warning(result <- set_dummy_conf(), "should not be used")
  expect_false(result)
})
