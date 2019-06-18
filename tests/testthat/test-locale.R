context("locale")

# Store initial locale Info
get_locale <- function() {
  vapply(
    c("LC_COLLATE", "LC_CTYPE", "LC_MONETARY", "LC_NUMERIC", "LC_TIME"),
    Sys.getlocale,
    character(1)
  )
}
set_locale <- function(locales) {
  old_locale <- get_locale()
  mapply(Sys.setlocale, category = names(locales), locale = locales)
  old_locale
}
old_locale <- get_locale()
test_locale <- c(
  LC_COLLATE = "German_Germany.1252",
  LC_CTYPE = "German_Germany.1252",
  LC_MONETARY = "German_Germany.1252",
  LC_NUMERIC = "C",
  LC_TIME = "German_Germany.1252"
)

# Force-clears the font cache to ensure replicability of the locale bug (#51) in multiple times in the same R session
prepare <- function() {
  gdtools:::reload_dll()
  set_locale(test_locale)
}

test_that("sys_fonts keeps locale intact", {
  prepare()
  gdtools::sys_fonts()
  expect_identical(get_locale(), test_locale)
})

test_that("set_dummy_conf keeps locale intact", {
  prepare()
  gdtools::set_dummy_conf()
  expect_identical(get_locale(), test_locale)
})

test_that("str_metrics keeps locale intact", {
  prepare()
  gdtools::str_metrics(x = "asdf")
  expect_identical(get_locale(), test_locale)
})

test_that("glyphs_match keeps locale intact", {
  prepare()
  gdtools::glyphs_match(x = "asdf")
  expect_identical(get_locale(), test_locale)
})

test_that("match_font keeps locale intact", {
  prepare()
  gdtools::match_font(font = "sans")
  expect_identical(get_locale(), test_locale)
})

test_that("font_family_exists keeps locale intact", {
  prepare()
  gdtools::font_family_exists(font_family = "sans")
  expect_identical(get_locale(), test_locale)
})

test_that("str_extents keeps locale intact", {
  prepare()
  gdtools::str_extents(x = "asdf")
  expect_identical(get_locale(), test_locale)
})

test_that("match_family keeps locale intact", {
  prepare()
  gdtools::match_family(font = "sans")
  expect_identical(get_locale(), test_locale)
})

test_that("m_str_extents keeps locale intact", {
  prepare()
  gdtools::m_str_extents(x = "asdf")
  expect_identical(get_locale(), test_locale)
})

set_locale(old_locale)
