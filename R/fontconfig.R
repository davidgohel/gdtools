#' Find best family match with fontconfig
#'
#' \code{match_family()} returns the best font family match for the
#' fontconfig pattern constructed from the \code{bold} and
#' \code{italic} arguments. The default pattern is bold italic to make
#' sure the matched font has enough features to be used in R graphics
#' (plain, bold, italic, bold italic). \code{match_font()} returns the
#' font file from the best family match, along with some metada in the
#' attributes.
#'
#' Fontconfig matching is controlled via the \code{fonts.conf}
#' file. Use \code{debug = "config"} to make sure what configuration
#' file it is currently using (there can be several installations on
#' one system, especially on Macs). See
#' \url{https://www.freedesktop.org/software/fontconfig/fontconfig-user.html}
#' for more information about debugging flags.
#'
#' @param font family or face to match.
#' @param bold Wheter to match a font featuring a \code{bold} face.
#' @param italic Wheter to match a font featuring an \code{italic} face.
#' @param debug Flag for debugging FontConfig. Can be one of
#'   \code{"config"}, \code{"match"}. Alternatively, can be an integer
#'   that is directly used as environment variable for \code{FC_DEBUG}
#'   (see FontConfig documentation).
#'
#' @export
#' @examples
#' \dontrun{
#' # The first run can be slow when font caches are missing
#' # as font files are then being scanned to build those font caches.
#' match_family("sans")
#' match_family("serif", bold = FALSE, italic = TRUE)
#'
#' match_font("Helvetica", bold = FALSE, italic = TRUE)
#' match_font("Helvetica", debug = "config")
#' }
match_family <- function(font = "sans", bold = TRUE, italic = TRUE, debug = NULL) {
  if (is.null(debug)) {
    match_family_(font, bold, italic)
  } else {
    on.exit(reload_dll())
    debug <- fc_match_debug(debug)
    withr::with_envvar(debug, match_family_(font, bold, italic))
  }
}

#' @rdname match_family
#' @export
match_font <- function(font = "sans", bold = FALSE, italic = FALSE, debug = NULL) {
  if (is.null(debug)) {
    match_font_(font, bold, italic)
  } else {
    on.exit(reload_dll())
    debug <- fc_match_debug(debug)
    withr::with_envvar(debug, match_font_(font, bold, italic))
  }
}

fc_match_debug <- function(debug) {
  if (is.numeric(debug)) {
    stopifnot(length(debug) == 1)
    debug <- as.character(debug)
  } else {
    debug <- match.arg(debug, c("config", "match"))
    debug <- switch(debug,
      config = "1024",
      match = "1"
    )
  }
  names(debug) <- "FC_DEBUG"
  debug
}

# Hack to force Fontconfig to reload debug flag
reload_dll <- function() {
  ns_env <- asNamespace("gdtools")
  ns_info <- ns_env[[".__NAMESPACE__."]]
  dll <- ns_info$DLLs$gdtools
  dll_path <- .subset2(dll, "path")
  dyn.load(dll_path)
}
