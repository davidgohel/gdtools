#' @title Check if font family exists.
#'
#' @description Check if a font family exists in available fonts.
#'
#' @return A logical value
#' @param font_family font family name (case sensitive)
#' @param system_only If `TRUE`, only look in system-installed fonts
#'   (as returned by [systemfonts::system_fonts()]). This is useful
#'   to verify that a font will be found by fontconfig, which is the
#'   font resolution mechanism used by Cairo devices at rendering
#'   time. When `FALSE` (the default), both system and registered
#'   fonts are considered.
#' @examples
#' font_family_exists("sans")
#' font_family_exists("Arial")
#' font_family_exists("Courier")
#' font_family_exists("Arial", system_only = TRUE)
#' @export
font_family_exists <- function(font_family = "sans", system_only = FALSE) {
  if (system_only) {
    families <- c(cached_system_fonts()$family, default_sys_fonts()$family)
  } else {
    families <- sys_fonts()$family
  }
  tolower(font_family) %in% tolower(families)
}

#' @title List fonts for 'systemfonts'.
#'
#' @description List system and registry fonts into a data.frame
#' containing columns such as path, family, style, weight and italic.
#'
#' Listing the system fonts is slow when many fonts are installed, so
#' the list is read once per R session; fonts registered with
#' 'systemfonts' (e.g. with [register_liberationsans()] or
#' [register_gfont()]) are always included. Call [sys_fonts_reset()]
#' after installing a font on the system during the session.
#' @return A data.frame of font information.
#' @examples
#' sys_fonts()
#' @export
#' @importFrom systemfonts system_fonts registry_fonts
sys_fonts <- function() {
  db_sys <- cached_system_fonts()
  db_reg <- registry_fonts()
  nam <- intersect(colnames(db_sys), colnames(db_reg))
  db_sys <- db_sys[, nam]
  db_reg <- db_reg[, nam]
  font_db <- rbind(db_sys, db_reg, default_sys_fonts())
  font_db
}

default_sys_fonts <- function() {
  dat <- data.frame(
    path = rep(NA_character_, 16),
    index = rep(NA_integer_, 16),
    family = rep(c("sans", "serif", "mono", "symbol"), each = 4),
    style = rep(c("Regular", "Bold", "Italic", "Bold Italic"), 4),
    weight = rep(c("normal", "bold", "normal", "bold"), 4),
    italic = rep(c(FALSE, FALSE, TRUE, TRUE), 4),
    stringsAsFactors = FALSE
  )
  res <- match_fonts(
    family = dat$family,
    weight = dat$weight,
    italic = dat$italic
  )
  dat$path <- res$path
  dat$index <- res$index
  dat
}

# the list of system fonts, read once per session (see sys_fonts_reset())
sys_fonts_cache <- new.env(parent = emptyenv())

cached_system_fonts <- function() {
  if (is.null(sys_fonts_cache$fonts)) {
    sys_fonts_cache$fonts <- system_fonts()
  }
  sys_fonts_cache$fonts
}

#' @title Refresh the list of system fonts
#'
#' @description The list of system fonts used by [sys_fonts()] and
#' [font_family_exists()] is read once per R session, as reading it is
#' slow when many fonts are installed. Call this function after
#' installing a font on the system during the session so that it is
#' found.
#'
#' It also resets the font cache of 'systemfonts'
#' ([systemfonts::reset_font_cache()]).
#' @return `NULL`, invisibly.
#' @examples
#' sys_fonts_reset()
#' @family functions for font management
#' @export
#' @importFrom systemfonts reset_font_cache
sys_fonts_reset <- function() {
  sys_fonts_cache$fonts <- NULL
  reset_font_cache()
  invisible(NULL)
}
