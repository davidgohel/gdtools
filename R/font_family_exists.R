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
#' @importFrom systemfonts match_font system_fonts
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
  font_db <- rbind(db_sys, db_reg)
  font_db
}

