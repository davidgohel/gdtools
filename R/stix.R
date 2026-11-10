# STIX Two Math -----

#' @export
#' @title Register font 'STIX Two Math'
#' @description Register the font 'STIX Two Math', shipped with 'gdtools',
#' so that it can be found by name with the 'systemfonts' package: by
#' functions measuring or drawing equations (such as the 'equatags'
#' package) and by graphic devices using 'systemfonts' ('ragg',
#' 'svglite', 'ggiraph').
#'
#' 'STIX Two Math' is an OpenType math font: it has a 'MATH' table giving
#' the parameters used to lay out equations, and size variants of
#' operators and delimiters.
#'
#' Nothing is done when a font is already found under `name`, for example
#' when 'STIX Two Math' is installed on the system (it is on macOS).
#' @param name the name to use for the font family when registering with
#' 'systemfonts'.
#' @return TRUE if a font is found under `name` after the operation.
#' @section License:
#' 'STIX Two Math' (version 2.13 b171) is copyright The STIX Fonts Project
#' Authors and licensed under the SIL Open Font License 1.1, see
#' `system.file("fonts", "stix", "OFL.txt", package = "gdtools")` and the
#' file `COPYRIGHTS` of the package.
#' @family functions for font management
#' @seealso [stixmath_file()]
#' @examples
#' register_stixmath()
register_stixmath <- function(name = "STIX Two Math") {
  if (!font_family_exists(name)) {
    register_font(name = name, plain = stixmath_file())
  }
  font_family_exists(name)
}

#' @export
#' @title Path of the font file 'STIX Two Math'
#' @description Path of the font file 'STIX Two Math' shipped with
#' 'gdtools', for functions that read font files directly.
#' @return A path to an OpenType font file.
#' @family functions for font management
#' @seealso [register_stixmath()]
#' @examples
#' stixmath_file()
stixmath_file <- function() {
  system.file("fonts", "stix", "STIXTwoMath-Regular.otf", package = "gdtools")
}
