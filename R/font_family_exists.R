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
  match_ <- best_family_match(font_family)
  ( match_ == font_family )
}
