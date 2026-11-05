# count the calls listing the system fonts while evaluating `expr`
count_font_listings <- function(expr) {
  counter <- new.env()
  counter$n <- 0L
  suppressMessages(trace(
    "system_fonts",
    tracer = bquote(
      assign("n", get("n", envir = .(counter)) + 1L, envir = .(counter))
    ),
    print = FALSE,
    where = asNamespace("gdtools")
  ))
  on.exit(suppressMessages(
    untrace("system_fonts", where = asNamespace("gdtools"))
  ))
  force(expr)
  counter$n
}

test_that("system fonts are listed once per session", {
  sys_fonts_reset()
  n <- count_font_listings({
    sys_fonts()
    font_family_exists("sans")
    font_family_exists("sans", system_only = TRUE)
    font_set_liberation()
  })
  expect_equal(n, 1L)
})

test_that("sys_fonts_reset() refreshes the list of system fonts", {
  sys_fonts()
  expect_null(sys_fonts_reset())
  n <- count_font_listings(sys_fonts())
  expect_equal(n, 1L)
})

test_that("registered fonts are found without refreshing the list", {
  sys_fonts()
  name <- "gdtools test cached family"
  expect_false(font_family_exists(name))
  expect_true(register_liberationsans(name = name))
  expect_true(font_family_exists(name))
  expect_true(name %in% sys_fonts()$family)
})
