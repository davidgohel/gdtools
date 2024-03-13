test_that("generic utils work", {
  ve_c <- version_cairo()

  expect_true(ve_c > numeric_version('0'))
  expect_s3_class(ve_c, "package_version")
  expect_s3_class(ve_c, "numeric_version")

  skip_on_cran()
  expect_true(is.character(match_family("serif")))
})
