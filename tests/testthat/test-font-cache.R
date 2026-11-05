test_that("font-caching works", {
  ds <- dummy_setup()

  expect_silent(fcd <- fonts_cache_dir())
  expect_true(dir.exists(fcd))
  expect_true(grepl("GDTOOLS_CACHE_DIR", fcd))

  options(GDTOOLS_CACHE_DIR = tempdir())
  expect_silent(fcd <- fonts_cache_dir())
  expect_true(dir.exists(fcd))
  expect_false(grepl("GDTOOLS_CACHE_DIR", fcd))

  options(GDTOOLS_CACHE_DIR = NULL)

  Sys.setenv(GDTOOLS_CACHE_DIR = "")

  init_fonts_cache()
  expect_silent(fcd <- fonts_cache_dir())
  expect_true(dir.exists(fcd))
  expect_true(grepl("gdtools", fcd))

  rm_fonts_cache()
  expect_false(dir.exists(fonts_cache_dir()))
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
