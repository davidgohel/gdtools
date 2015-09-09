#' @title Get font metrics for a string of text
#' @description Calculate the font metrics for a string of text as
#' a numeric named vector of length 3 containing width, ascent
#' and descent.
#' @param str string of text
#' @param bold is bold
#' @param italic is italic
#' @param fontname font name
#' @param fontsize font size in pixel
#' @examples
#' font_metrics(str = "Hello World!", bold = TRUE, italic = FALSE,
#'   fontname = "Sans", fontsize = 12)
#' @export
font_metrics <- function( str, bold = FALSE, italic = FALSE, fontname = "Sans", fontsize = 12 ) {
  stopifnot(is.character(str))
  stopifnot(is.logical(bold) )
  stopifnot(is.logical(italic) )
  stopifnot(is.character(fontname))
  stopifnot(is.numeric(fontsize))
  stopifnot(length(fontname) == 1)
  stopifnot(length(bold) == 1)
  stopifnot(length(italic) == 1)
  stopifnot(length(fontname) == 1)
  stopifnot(length(fontsize) == 1)
  stopifnot(length(str) == 1)

  fontsize = as.integer(fontsize)
  if( fontsize < 1 )
    stop("fontsize must be greater than 0")
  out = get_font_info(str, bold = bold, italic = italic,
               fontname = fontname, fontsize = fontsize )
  names(out) = c("width", "ascent", "descent")
  out

}
