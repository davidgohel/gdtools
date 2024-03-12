test_that("generic utils work", {
  ve_c <- version_cairo()

  expect_true(ve_c > 0)
  expect_s3_class(ve_c, "package_version")
  expect_s3_class(ve_c, "numeric_version")

  expect_equal(
    match_family("serif"),
    "DejaVu Serif"
  )
})
