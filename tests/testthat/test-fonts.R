ds <- dummy_setup()

test_that("fonts work", {
  skip_if_not(check_gfonts(errors = FALSE))

  fontlist <- gfontHtmlDependency(family = "Open Sans")

  expect_identical(fontlist$name, "open-sans")
  expect_true(grepl("open-sans", fontlist$src[[1]]))
  expect_true(grepl("open-sans.css", fontlist$stylesheet))
  expect_s3_class(fontlist, "html_dependency")

  out <- addGFontHtmlDependency(family = "Roboto")
  expect_s3_class(out, "shiny.tag")
  expect_identical(attr(out, which = "html_dependencies")[[1]]$name, "roboto")
  expect_identical(out$name, "style")

  out <- addGFontHtmlDependency(family = "Open Sans")
  expect_error(addGFontHtmlDependency("notafont"))
  expect_identical(attr(out, which = "html_dependencies")[[1]], fontlist)

  expect_true(register_gfont(family = gfonts::get_all_fonts()$family[4]))

  expect_identical(
    installed_gfonts(),
    c("Roboto", "Open Sans", "Montserrat")
  )

  flib <- liberationsansHtmlDependency()
  expect_identical(flib$name, "liberation-sans")
  expect_true(grepl("liberation-sans", flib$src[[1]]))
  expect_true(grepl("liberation-sans.css", flib$stylesheet))
  expect_s3_class(flib, "html_dependency")

  expect_true(register_liberationsans())
})

test_that("system dependent font installation works", {
  skip_if_not(check_gfonts(errors = FALSE))
  si <- Sys.info()
  if (si["sysname"] == "Linux") {
    sysnm <- "debian"
  } else if (si["sysname"] == "Darwin") {
    sysnm <- "macos"
  } else if (si["sysname"] == "macOS") {
    sysnm <- "macos"
  } else if (si["sysname"] == "Windows") {
    sysnm <- "windows"
  } else {
    sysnm <- NULL
  }
  if (!is.null(sysnm)) {
    expect_silent(command <- install_gfont_script(family = "Roboto", platform = sysnm))
    expect_silent(install_gfont_script(file = tempfile()))
    # Check some part of the command -> Windows is different
    if (si["sysname"] %in% c("Linux", "macOS", "Darwin")) {
      expect_true(grepl(paste0(ds, "/roboto/fonts"), command))
    }
  } else {
    skip("Skipping install_gfont_script test because the platform is not supported")
  }
})

test_that("font-caching works", {
  expect_warning(ds <- dummy_setup())

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
