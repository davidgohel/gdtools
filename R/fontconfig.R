#' Find best family match with systemfonts
#'
#' \code{match_family()} returns the best font family match.
#'
#' @param font family or face to match.
#' @param bold,italic,debug deprecated
#' @export
#' @examples
#' match_family("sans")
#' match_family("serif")
#' @importFrom systemfonts match_font
match_family <- function(font = "sans", bold = TRUE, italic = TRUE, debug = NULL) {
  # keep locale intact
  font <- match_font(font)
  gsub( "\\.[A-Za-z]{3,}$", "", basename(font$path) )
}


#' Set and unset a minimalistic Fontconfig configuration
#'
#' @export
#' @examples
#' if( require("fontquiver") ){
#' on_appveyor <- function() {
#'   identical(Sys.getenv("APPVEYOR"), "True")
#' }
#'
#' # Use minimal fonts.conf to speed up fc-cache
#' if (on_appveyor()) {
#'   set_dummy_conf()
#' }
#'
#' unset_dummy_conf()
#' }
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
#' @author Paul Murrell
fontconfig_reinit <- function() {
}
