# Cases measured by test-glyph-metrics.R and data-src/glyph-reference.R.
# Liberation files from fontquiver: every machine measures the same files.

reference_strings <- function() {
  c(
    "",
    " ",
    "Hello World!",
    "Placebo",
    "(N=86)",
    "AVAV To Yv",
    "Hg(jy)",
    "xxx",
    "'",
    "_",
    "^'",
    "0123456789",
    "a\tb",
    "été Ça",
    "Ωμέγα",
    "漢字",
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    "abcdefghijklmnopqrstuvwxyz"
  )
}

reference_fonts <- function() {
  lib <- fontquiver::font_families("Liberation")
  grid <- expand.grid(
    family = c("sans", "serif", "mono"),
    face = c("plain", "bold", "italic", "bolditalic"),
    stringsAsFactors = FALSE
  )
  grid$file <- mapply(
    function(family, face) lib[[family]][[face]]$ttf,
    grid$family,
    grid$face
  )
  grid
}

reference_cases <- function() {
  fonts <- reference_fonts()
  strings <- reference_strings()
  sizes <- c(7, 10, 13.5)
  cases <- expand.grid(
    string_id = seq_along(strings),
    font_id = seq_len(nrow(fonts)),
    size = sizes
  )
  data.frame(
    string_id = cases$string_id,
    x = strings[cases$string_id],
    family = fonts$family[cases$font_id],
    face = fonts$face[cases$font_id],
    file = fonts$file[cases$font_id],
    size = cases$size,
    stringsAsFactors = FALSE
  )
}
