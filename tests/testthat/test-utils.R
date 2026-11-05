test_that("generic utils work", {
  expect_warning(ve_c <- version_cairo(), "deprecated")
  expect_null(ve_c)

  ve_ft <- version_freetype()

  expect_true(ve_ft > numeric_version('0'))
  expect_s3_class(ve_ft, "package_version")
  expect_s3_class(ve_ft, "numeric_version")

  skip_on_cran()
  font_set_liberation()
  expect_warning(serif <- match_family("serif"), "deprecated")
  expect_true(is.character(serif))
  expect_warning(
    sans <- match_family("sans", bold = FALSE, italic = FALSE),
    "deprecated"
  )
  expect_true(is.character(sans))
})

test_that("ensure_cache_dir errors clearly when dir cannot be created (#82)", {
  parent <- tempfile()
  writeLines("x", parent)
  on.exit(unlink(parent), add = TRUE)
  bad_path <- file.path(parent, "subdir")
  expect_error(
    gdtools:::ensure_cache_dir(bad_path),
    "Cannot create cache directory"
  )
})
