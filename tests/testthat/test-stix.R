test_that("the STIX Two Math file is shipped", {
  path <- stixmath_file()
  expect_true(file.exists(path))
  info <- systemfonts::font_info(path = path)
  expect_identical(info$family, "STIX Two Math")
  expect_true(file.exists(system.file("fonts", "stix", "OFL.txt", package = "gdtools")))
})

test_that("register_stixmath() registers the shipped file", {
  # a name that can not exist on the machine
  name <- "gdtools-test-stix-math"
  expect_true(register_stixmath(name = name))
  expect_identical(
    normalizePath(systemfonts::match_fonts(name)$path),
    normalizePath(stixmath_file())
  )
})
