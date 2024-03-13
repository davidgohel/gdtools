test_that("generic utils work", {
  ve_c <- version_cairo()

  expect_s3_class(ve_c, "package_version")
  expect_s3_class(ve_c, "numeric_version")

  expect_true(match_family("serif") %in% c("Times New Roman", "DejaVu Serif"))
})
