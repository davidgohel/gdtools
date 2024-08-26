#' @title Check if font family exists.
#'
#' @description Check if a font family exists in system fonts.
#'
#' @return A logical value
#' @param font_family font family name (case sensitive)
#' @examples
#' font_family_exists("sans")
#' font_family_exists("Arial")
#' font_family_exists("Courier")
#' @export
font_family_exists <- function( font_family = "sans" ){
  datafonts <- sys_fonts()
  tolower(font_family) %in% tolower(datafonts$family)
}

#' @title List fonts for 'systemfonts'.
#'
#' @description List system and registryfonts details into a data.frame
#' containing columns foundry, family, file, slant and weight.
#' @examples
#' sys_fonts()
#' @export
#' @importFrom systemfonts system_fonts registry_fonts
sys_fonts <- function() {
  db_sys <- system_fonts()
  db_reg <- registry_fonts()
  nam <- intersect(colnames(db_sys), colnames(db_reg))
  db_sys <- db_sys[,nam]
  db_reg <- db_reg[,nam]
  font_db <- rbind(db_sys, db_reg, default_sys_fonts())
  font_db
}

default_sys_fonts <- function() {
  dat <- data.frame(
    path = rep(NA_character_, 16),
    index = rep(NA_integer_, 16),
    family = rep(c("sans", "serif", "mono", "symbol"), each = 4),
    style = rep(c("Regular", "Bold", "Italic", "Bold Italic"), 4),
    weight = rep(c("normal", "bold", "normal", "bold"), 4),
    italic = rep(c(FALSE, FALSE, TRUE, TRUE), 4),
    stringsAsFactors = FALSE
  )
  res <- match_fonts(family = dat$family, weight = dat$weight, italic = dat$italic)
  dat$path <- res$path
  dat$index <- res$index
  dat
}
