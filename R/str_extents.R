#' @useDynLib gdtools
#' @importFrom Rcpp sourceCpp
#' @title get extents for strings of text
#' @description Gets the extents for strings of text. The extents describe a
#' rectangle that encloses the portion of the formatted text.
#' @param str strings of text
#' @param bold is bold
#' @param italic is italic
#' @param fontname font name
#' @param fontsize font size in pixel
#' @examples
#' str_extents(str = "Hello World!", bold = TRUE, italic = FALSE,
#'   fontname = "Sans", fontsize = 12)
#' @export
str_extents <- function( str, bold = FALSE, italic = FALSE, fontname = "Sans", fontsize = 12 ) {
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

  fontsize = as.integer(fontsize)
  if( fontsize < 1 )
    stop("fontsize must be greater than 0")
  out = sapply(str, get_str_dim,
         bold = bold,
         italic = italic,
         fontname = fontname, fontsize = fontsize )
  dimnames(out)[[1]] = c("width", "height")
  out

}
