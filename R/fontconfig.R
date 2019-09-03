#' Find best family match with systemfonts
#'
#' \code{match_family()} returns the best font family match.
#'
#' @param font family or face to match.
#' @param bold Wheter to match a font featuring a \code{bold} face.
#' @param italic Wheter to match a font featuring an \code{italic} face.
#' @param debug deprecated
#' @export
#' @examples
#' match_family("sans")
#' match_family("serif")
#' @importFrom systemfonts match_font
match_family <- function(font = "sans", bold = TRUE, italic = TRUE, debug = NULL) {
  # keep locale intact
  font <- match_font(font, bold = bold, italic = italic)
  gsub( "\\.[A-Za-z]{3,}$", "", basename(font$path) )
}


#' Set and unset a minimalistic Fontconfig configuration
#'
#' @note
#' Fontconfig is not used anymore and these functions will be deprecated
#' in the next release.
#' @export
set_dummy_conf <- function() {
}

#' @rdname set_dummy_conf
#' @export
unset_dummy_conf <- function() {
}

#' @export
#' @title reload Fontconfig configuration
#' @description This function can be used to make fontconfig
#' reload font configuration files.
#' @note
#' Fontconfig is not used anymore and that function will be deprecated
#' in the next release.
#' @author Paul Murrell
fontconfig_reinit <- function() {
}
