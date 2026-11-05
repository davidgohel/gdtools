#' Find best family match with systemfonts (deprecated)
#'
#' `match_family()` returns the best font family match. It is deprecated and
#' will be removed in a future release, use [systemfonts::match_fonts()]
#' instead.
#'
#' @param font family or face to match.
#' @param bold Whether to match a font featuring a bold face.
#' @param italic Whether to match a font featuring an italic face.
#' @export
#' @examples
#' suppressWarnings(match_family("sans"))
#' suppressWarnings(match_family("serif"))
#' @importFrom systemfonts match_fonts system_fonts
#' @keywords internal
match_family <- function(
  font = "sans",
  bold = TRUE,
  italic = TRUE
) {
  .Deprecated(new = "systemfonts::match_fonts")
  if (bold) {
    weight <- "bold"
  } else {
    weight <- "normal"
  }
  font <- match_fonts(font, weight = weight, italic = italic)

  sysfonts <- sys_fonts()
  match <- which(sysfonts$path %in% font$path)
  sysfonts$family[match[1]]
}
