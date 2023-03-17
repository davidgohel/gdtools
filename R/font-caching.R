#' @importFrom tools R_user_dir
#' @export
#' @title manage font working directory
#' @description Initialize or remove font directory used
#' to store downloaded font files.
#'
#' This directory is managed by R function [R_user_dir()] but can also
#' be defined in a non-user location by setting ENV variable `GDTOOLS_CACHE_DIR`
#' or by setting R option `GDTOOLS_CACHE_DIR`.
#'
#' Its value can be read with the `fonts_cache_dir()` function.
#'
#' The directory can be deleted with `rm_fonts_cache()` and
#' created with `init_fonts_cache()`.
#' @family functions for font management
#' @examples
#' fonts_cache_dir()
#'
#' options(GDTOOLS_CACHE_DIR = tempdir())
#' fonts_cache_dir()
#' options(GDTOOLS_CACHE_DIR = NULL)
#'
#' Sys.setenv(GDTOOLS_CACHE_DIR=tempdir())
#' fonts_cache_dir()
#' Sys.setenv(GDTOOLS_CACHE_DIR="")
#'
#'
#'
#' init_fonts_cache()
#' dir.exists(fonts_cache_dir())
#'
#' rm_fonts_cache()
#' dir.exists(fonts_cache_dir())
fonts_cache_dir <- function(){
  if (dir.exists(Sys.getenv("GDTOOLS_CACHE_DIR"))) {
    dir <- Sys.getenv("GDTOOLS_CACHE_DIR")
  } else if (!is.null(getOption("GDTOOLS_CACHE_DIR")) && dir.exists(getOption("GDTOOLS_CACHE_DIR")) ) {
    dir <- getOption("GDTOOLS_CACHE_DIR")
  } else {
    dir <- R_user_dir(package = "gdtools", which = "data")
  }
  if (is.null(getOption("GFONTS_DOWNLOAD_SLEEPTIME"))) {
    options(GFONTS_DOWNLOAD_SLEEPTIME = 1)
  }

  dir
}

#' @title dummy 'Google Fonts' cache
#' @description dummy 'Google Fonts' cache
#' used for examples.
#' @export
#' @keywords internal
dummy_setup <- function() {
  options(GDTOOLS_CACHE_DIR = file.path(tempdir(), "GDTOOLS_CACHE_DIR"))
  dir.create(getOption("GDTOOLS_CACHE_DIR"), recursive = TRUE, showWarnings = TRUE)
  fonts_cache_dir()
}


user_cache_exists <- function() {
  fonts_cache_dir() == R_user_dir(package = "gdtools", which = "data")
}

#' @export
#' @rdname fonts_cache_dir
rm_fonts_cache <- function(){
  dir <- fonts_cache_dir()
  unlink(dir, recursive = TRUE, force = TRUE)
}



#' @export
#' @rdname fonts_cache_dir
init_fonts_cache <- function(){
  rm_fonts_cache()
  dir.create(fonts_cache_dir(), showWarnings = FALSE, recursive = TRUE)
  liberationsans_to_cache()
  fonts_cache_dir()
}

css_filepath <- function(id) {
  file.path(css_dir(id = id), paste0(id, ".css"))
}

css_dir <- function(id) {
  file.path(fonts_cache_dir(), id, "css")
}
font_dir <- function(id) {
  file.path(fonts_cache_dir(), id, "fonts")
}
reduce_faces <- function(variants) {
  faces <- c(
    plain = "regular",
    italic = "italic",
    bold = "700",
    bolditalic = "700italic")
  faces <- faces[faces%in%variants]
  faces <- faces[!is.na(faces)]
  faces
}

#' @importFrom curl has_internet
#' @export
#' @title Test for internet connectivity
#' @description The function is a copy of
#' [curl::has_internet()].
#' @examples
#' has_internet()
#' @keywords internal
has_internet <- curl::has_internet

#' @importFrom gfonts download_font generate_css
font_to_cache <- function(family, faces = NULL, subset = c("latin", "latin-ext")) {

  stopifnot(`'family' is expected to be a character value` = is.character(family), `family is expected to be a single value` = length(family) == 1L)

  x <- gfonts_summary()

  if(!family %in% x$family) {
    stop("family ", shQuote(family), " is not in the fonts provided by 'google fonts'.")
  }

  font_id <- x[x$family %in% family,]$id

  css_file <- css_filepath(id = font_id)
  if(file.exists(css_file)) return(TRUE)

  if (!has_internet()) {
    stop("an internet connection is required to download the font files.")
  }

  if (is.null(faces)) {
    faces <- reduce_faces(x[x$id %in% font_id,]$variants[[1]])
  }

  subsets <- intersect(x[x$id %in% font_id,]$subsets[[1]], subset)

  .font_dir <- font_dir(id = font_id)
  .css_dir <- css_dir(id = font_id)

  dir.create(.font_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(.css_dir, recursive = TRUE, showWarnings = FALSE)

  download_font(
    id = font_id,
    subsets = paste0(subsets, collapse = ","),
    variants = faces,
    output_dir = .font_dir)
  Sys.sleep(getOption("GFONTS_DOWNLOAD_SLEEPTIME"))
  generate_css(
    prefer_local_source = FALSE,
    browser_support = "best",
    subsets = paste0(subsets, collapse = ","),
    id = font_id,
    variants = faces,
    font_dir = "../fonts/",
    output = css_file)

  # drop IE support as it generates issues - enough with IE8
  css_str <- readLines(css_file, encoding = "UTF-8")
  css_str <- css_str[!grepl("/* IE6-IE8 */", css_str, fixed = TRUE)]
  writeLines(css_str, css_file, useBytes = TRUE)
  TRUE

}

liberationsans_to_cache <- function() {
  font_id <- "liberation-sans"

  font_dir_ <- font_dir(id = font_id)
  font_css_ <- css_dir(id = font_id)

  if (!dir.exists(font_dir_) || !dir.exists(font_css_)) {
    dir.create(font_dir_, showWarnings = FALSE, recursive = TRUE)
    file.copy(
      from = list.files(
        system.file(package = "fontLiberation", "fonts/liberation-fonts"),
        full.names = TRUE),
      to = font_dir_, overwrite = TRUE)

    dir.create(font_css_, showWarnings = FALSE, recursive = TRUE)
    file.copy(
      from = system.file(package = "gdtools", "css/liberation-sans.css"),
      to = font_css_, overwrite = TRUE)
  }

}

#' @importFrom fontquiver font_faces
#' @export
#' @title Register font 'Liberation Sans'
#' @description Register font 'Liberation Sans' so that it can be used
#' with devices using the 'systemfonts' package, i.e. the 'flextable'
#' package and graphic outputs generated with the 'ragg', 'svglite'
#' and 'ggiraph' packages.
#' @return TRUE if the operation went ok.
#' @family functions for font management
register_liberationsans <- function() {
    if (!font_family_exists("Liberation Sans")) {
      liberation_lst <- font_faces("Liberation", family = "sans")
      register_font(
        name = "Liberation Sans",
        plain = liberation_lst$plain$ttf,
        bold = liberation_lst$bold$ttf,
        italic = liberation_lst$italic$ttf,
        bolditalic = liberation_lst$bolditalic$ttf
      )
    }
  font_family_exists("Liberation Sans")
}


## gfonts_summary -----
#' @importFrom gfonts get_all_fonts
gfonts_summary <- function() {
  all_gfonts
}

