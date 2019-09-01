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
#' @importFrom systemfonts match_font
font_family_exists <- function( font_family = "sans" ){
  match_ <- match_font(font_family)
  match_ <- gsub("([^.]+)\\.[[:alnum:]]+$", "\\1", basename(match_$path) )
  identical(tolower(match_), tolower(font_family) )
}
