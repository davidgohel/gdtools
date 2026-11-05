#' @importFrom tools R_user_dir
#' @export
#' @title Manage Font Working Directory
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
#' Sys.setenv(GDTOOLS_CACHE_DIR = tempdir())
#' fonts_cache_dir()
#' Sys.setenv(GDTOOLS_CACHE_DIR = "")
#'
#'
#'
#' init_fonts_cache()
#' dir.exists(fonts_cache_dir())
#'
#' rm_fonts_cache()
#' dir.exists(fonts_cache_dir())
fonts_cache_dir <- function() {
  if (dir.exists(Sys.getenv("GDTOOLS_CACHE_DIR"))) {
    dir <- Sys.getenv("GDTOOLS_CACHE_DIR")
  } else if (
    !is.null(getOption("GDTOOLS_CACHE_DIR")) &&
      dir.exists(getOption("GDTOOLS_CACHE_DIR"))
  ) {
    dir <- getOption("GDTOOLS_CACHE_DIR")
  } else {
    dir <- R_user_dir(package = "gdtools", which = "data")
  }
  if (is.null(getOption("GFONTS_DOWNLOAD_SLEEPTIME"))) {
    options(GFONTS_DOWNLOAD_SLEEPTIME = 1)
  }

  dir
}

#' @title Set up a temporary font cache
#' @description Create a temporary directory used as the
#' 'Google Fonts' cache. This is intended for examples and tests.
#' @return The path to the temporary cache directory (invisibly).
#' @export
#' @keywords internal
dummy_setup <- function() {
  dummy_dir <- file.path(tempdir(), "GDTOOLS_CACHE_DIR")
  options(GDTOOLS_CACHE_DIR = dummy_dir)
  ensure_cache_dir(dummy_dir)
  fonts_cache_dir()
}


user_cache_exists <- function() {
  fonts_cache_dir() == R_user_dir(package = "gdtools", which = "data")
}

#' @export
#' @rdname fonts_cache_dir
rm_fonts_cache <- function() {
  dir <- fonts_cache_dir()
  unlink(dir, recursive = TRUE, force = TRUE)
}


#' @export
#' @rdname fonts_cache_dir
init_fonts_cache <- function() {
  rm_fonts_cache()
  ensure_cache_dir(fonts_cache_dir())
  liberationsans_to_cache()
  fonts_cache_dir()
}

ensure_cache_dir <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  if (!dir.exists(path)) {
    stop(
      "Cannot create cache directory ",
      shQuote(path),
      ". Check write permissions on the parent directory, ",
      "or set option 'GDTOOLS_CACHE_DIR' / env var 'GDTOOLS_CACHE_DIR' ",
      "to a writable location.",
      call. = FALSE
    )
  }
  invisible(path)
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
