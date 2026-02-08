test_that("font_liberation() returns font_spec", {
  spec <- font_liberation("sans")
  expect_s3_class(spec, "font_spec")
  expect_identical(spec$family, "Liberation Sans")
  expect_identical(spec$variant, "sans")
  expect_identical(spec$source, "liberation")

  spec_mono <- font_liberation("mono")
  expect_identical(spec_mono$family, "Liberation Mono")
  expect_identical(spec_mono$variant, "mono")

  spec_serif <- font_liberation("serif")
  expect_identical(spec_serif$family, "Liberation Serif")
  expect_identical(spec_serif$variant, "serif")
})

test_that("font_google() returns font_spec", {
  skip_if_not_ready()
  spec <- font_google("Roboto")
  expect_s3_class(spec, "font_spec")
  expect_identical(spec$family, "Roboto")
  expect_identical(spec$subset, c("latin", "latin-ext"))
  expect_identical(spec$source, "google")

  spec2 <- font_google("Open Sans", subset = "latin")
  expect_identical(spec2$subset, "latin")
})

test_that("font_set_liberation() works", {
  fonts <- font_set_liberation()
  expect_s3_class(fonts, "font_set")
  expect_identical(fonts$sans, "Liberation Sans")
  expect_identical(fonts$serif, "Liberation Serif")
  expect_identical(fonts$mono, "Liberation Mono")
  expect_identical(fonts$symbol, "Liberation Sans")
  expect_length(fonts$dependencies, 4L)
  expect_identical(
    fonts$dsvg_fonts,
    list(
      sans = "Liberation Sans",
      serif = "Liberation Serif",
      mono = "Liberation Mono",
      symbol = "Liberation Sans"
    )
  )
  expect_identical(
    fonts$sources,
    list(
      sans = "liberation",
      serif = "liberation",
      mono = "liberation",
      symbol = "liberation"
    )
  )
})

test_that("font_set() with system font string", {
  register_liberationsans()
  fonts <- font_set(sans = "Liberation Sans")
  expect_s3_class(fonts, "font_set")
  expect_identical(fonts$sans, "Liberation Sans")
  expect_null(fonts$serif)
  expect_null(fonts$mono)
  expect_null(fonts$symbol)
  expect_length(fonts$dependencies, 1L)
  expect_s3_class(fonts$dependencies[[1]], "html_dependency")
  expect_identical(fonts$dependencies[[1]]$name, "liberation-sans")
  expect_identical(fonts$sources$sans, "system")
})

test_that("font_set() errors on nonexistent system font", {
  expect_error(
    font_set(sans = "nonexistent_xyz_font_abc"),
    "not available"
  )
})

test_that("font_set() with single liberation font", {
  fonts <- font_set(sans = font_liberation("sans"))
  expect_identical(fonts$sans, "Liberation Sans")
  expect_null(fonts$serif)
  expect_null(fonts$mono)
  expect_null(fonts$symbol)
  expect_length(fonts$dependencies, 1L)
  expect_s3_class(fonts$dependencies[[1]], "html_dependency")
  expect_identical(fonts$dsvg_fonts, list(sans = "Liberation Sans"))
})

test_that("font_set() with mixed liberation fonts", {
  fonts <- font_set(
    sans = font_liberation("sans"),
    mono = font_liberation("mono")
  )
  expect_identical(fonts$sans, "Liberation Sans")
  expect_null(fonts$serif)
  expect_identical(fonts$mono, "Liberation Mono")
  expect_length(fonts$dependencies, 2L)
  expect_identical(
    fonts$dsvg_fonts,
    list(
      sans = "Liberation Sans",
      mono = "Liberation Mono"
    )
  )
})

test_that("font_set() with symbol role", {
  register_liberationsans()
  fonts <- font_set(symbol = "Liberation Sans")
  expect_s3_class(fonts, "font_set")
  expect_null(fonts$sans)
  expect_identical(fonts$symbol, "Liberation Sans")
  expect_identical(fonts$dsvg_fonts, list(symbol = "Liberation Sans"))
  expect_identical(fonts$sources$symbol, "system")
  expect_length(fonts$dependencies, 1L)

  fonts3 <- font_set(
    sans = font_liberation("sans"),
    symbol = font_liberation("mono")
  )
  expect_identical(fonts3$sans, "Liberation Sans")
  expect_identical(fonts3$symbol, "Liberation Mono")
  expect_length(fonts3$dependencies, 2L)
  expect_identical(
    fonts3$dsvg_fonts,
    list(
      sans = "Liberation Sans",
      symbol = "Liberation Mono"
    )
  )
})

test_that("print.font_set() runs without error", {
  fonts <- font_set_liberation()
  expect_output(print(fonts), "Font set")
  expect_output(print(fonts), "Liberation Sans")
  expect_output(print(fonts), "4 HTML dependencies")
})

test_that("system font generates CSS and caches files", {
  register_liberationsans()
  fonts <- font_set(sans = "Liberation Sans")
  dep <- fonts$dependencies[[1]]

  # CSS file exists
  css_path <- file.path(dep$src, "css", paste0(dep$name, ".css"))
  expect_true(file.exists(css_path))
  css_content <- readLines(css_path)
  expect_true(any(grepl("@font-face", css_content)))
  expect_true(any(grepl("Liberation Sans", css_content)))
  expect_true(any(grepl("font-weight: 400", css_content)))
  expect_true(any(grepl("font-weight: 700", css_content)))

  # font files exist
  fonts_path <- file.path(dep$src, "fonts")
  expect_true(dir.exists(fonts_path))
  font_files <- list.files(fonts_path)
  expect_true(length(font_files) >= 1L)
})

test_that("font_set() with google font", {
  skip_if_not_ready()
  skip_if_not(check_gfonts())
  dummy_setup()
  fonts <- font_set(sans = font_google("Open Sans"))
  expect_s3_class(fonts, "font_set")
  expect_identical(fonts$sans, "Open Sans")
  expect_length(fonts$dependencies, 1L)
  expect_identical(fonts$sources$sans, "google")
})
