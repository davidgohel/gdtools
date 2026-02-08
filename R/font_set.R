#' @title Google Font specification
#' @description Create a font specification for a Google Font,
#' to be used with [font_set()].
#' @param family family name of a 'Google Fonts', for example,
#' "Open Sans", "Roboto", "Fira Code" or "Fira Sans Condensed".
#' @param subset font subset, a character vector, it defaults to
#' only "latin" and "latin-ext".
#' @return An object of class `font_spec`.
#' @family font set functions
#' @export
#' @examples
#' font_google("Roboto")
font_google <- function(family, subset = c("latin", "latin-ext")) {
  structure(
    list(family = family, subset = subset, source = "google"),
    class = "font_spec"
  )
}

#' @title Liberation Font specification
#' @description Create a font specification for a Liberation font,
#' to be used with [font_set()].
#' @param variant one of `"sans"`, `"serif"`, or `"mono"`.
#' @return An object of class `font_spec`.
#' @family font set functions
#' @export
#' @examples
#' font_liberation("sans")
#' font_liberation("mono")
font_liberation <- function(variant = c("sans", "serif", "mono")) {
  variant <- match.arg(variant)
  families <- c(
    sans = "Liberation Sans",
    serif = "Liberation Serif",
    mono = "Liberation Mono"
  )
  structure(
    list(
      family = families[[variant]],
      variant = variant,
      source = "liberation"
    ),
    class = "font_spec"
  )
}

# CSS format descriptor from file extension
css_font_format <- function(path) {
  ext <- tolower(tools::file_ext(path))
  switch(
    ext,
    ttf = "truetype",
    otf = "opentype",
    woff = "woff",
    woff2 = "woff2",
    "truetype"
  )
}

# Cache a system font and generate its @font-face CSS
sysfont_to_cache <- function(family) {
  font_id <- tolower(gsub("[^a-zA-Z0-9]+", "-", family))
  font_id <- sub("-+$", "", font_id)

  css_file <- css_filepath(id = font_id)
  if (file.exists(css_file)) {
    return(font_id)
  }

  faces <- list(
    regular = list(
      weight = "normal",
      italic = FALSE,
      css_weight = 400L,
      css_style = "normal"
    ),
    bold = list(
      weight = "bold",
      italic = FALSE,
      css_weight = 700L,
      css_style = "normal"
    ),
    italic = list(
      weight = "normal",
      italic = TRUE,
      css_weight = 400L,
      css_style = "italic"
    ),
    bolditalic = list(
      weight = "bold",
      italic = TRUE,
      css_weight = 700L,
      css_style = "italic"
    )
  )

  .font_dir <- font_dir(id = font_id)
  .css_dir <- css_dir(id = font_id)
  dir.create(.font_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(.css_dir, recursive = TRUE, showWarnings = FALSE)

  css_lines <- character()

  for (face_name in names(faces)) {
    face <- faces[[face_name]]
    matched <- match_fonts(
      family = family,
      weight = face$weight,
      italic = face$italic
    )
    src_path <- matched$path[1L]
    if (is.na(src_path) || !nzchar(src_path) || !file.exists(src_path)) {
      next
    }

    ext <- tolower(tools::file_ext(src_path))
    dest_name <- paste0(font_id, "-", face_name, ".", ext)
    file.copy(src_path, file.path(.font_dir, dest_name), overwrite = TRUE)

    fmt <- css_font_format(src_path)
    css_lines <- c(
      css_lines,
      "@font-face {",
      sprintf("  font-family: '%s';", family),
      sprintf("  font-style: %s;", face$css_style),
      sprintf("  font-weight: %d;", face$css_weight),
      sprintf("  src: url('../fonts/%s') format('%s');", dest_name, fmt),
      "}",
      ""
    )
  }

  writeLines(css_lines, css_file, useBytes = TRUE)
  font_id
}

# Create an htmlDependency for a system font
sysfontHtmlDependency <- function(family) {
  font_id <- sysfont_to_cache(family)
  pkg_version <- packageVersion("gdtools")
  htmlDependency(
    all_files = TRUE,
    name = font_id,
    version = format(pkg_version),
    src = file.path(fonts_cache_dir(), font_id),
    stylesheet = paste0("css/", font_id, ".css")
  )
}

# Process a single font role value into family name + dependency
process_font_role <- function(value) {
  if (is.character(value)) {
    if (!font_family_exists(value)) {
      stop(
        "Font family ",
        shQuote(value),
        " is not available. ",
        "Register it first or use font_google() / font_liberation().",
        call. = FALSE
      )
    }
    dep <- sysfontHtmlDependency(value)
    list(family = value, dependency = dep, source = "system")
  } else if (inherits(value, "font_spec")) {
    if (value$source == "google") {
      check_gfonts(errors = TRUE)
      register_gfont(family = value$family, subset = value$subset)
      dep <- gfontHtmlDependency(family = value$family, subset = value$subset)
      list(family = value$family, dependency = dep, source = "google")
    } else if (value$source == "liberation") {
      register_fn <- switch(
        value$variant,
        sans = register_liberationsans,
        serif = register_liberationserif,
        mono = register_liberationmono
      )
      dep_fn <- switch(
        value$variant,
        sans = liberationsansHtmlDependency,
        serif = liberationserifHtmlDependency,
        mono = liberationmonoHtmlDependency
      )
      register_fn()
      dep <- dep_fn()
      list(family = value$family, dependency = dep, source = "liberation")
    } else {
      stop("Unknown font_spec source: ", shQuote(value$source), call. = FALSE)
    }
  } else {
    stop(
      "Each argument must be a character string, a font_google(), or a font_liberation() object.",
      call. = FALSE
    )
  }
}

#' @title Create a font set
#' @description Bundle font registration, HTML dependencies, and
#' font family names into a single object. Each argument accepts
#' a [font_google()] specification, a [font_liberation()] specification,
#' or a plain character string naming a system font already available.
#'
#' The returned object provides fields ready to use with
#' [ggplot2::theme()] (`$sans`, `$serif`, `$mono`),
#' `girafe(fonts = ...)` or `dsvg(fonts = ...)` (`$dsvg_fonts`),
#' and `girafe(dependencies = ...)` (`$dependencies`).
#' @param sans font for sans-serif text.
#' @param serif font for serif text.
#' @param mono font for monospace text.
#' @param symbol font for symbol text.
#' @return An object of class `font_set` with elements:
#' \describe{
#'   \item{sans}{character, the sans font family name (or NULL)}
#'   \item{serif}{character, the serif font family name (or NULL)}
#'   \item{mono}{character, the mono font family name (or NULL)}
#'   \item{symbol}{character, the symbol font family name (or NULL)}
#'   \item{dependencies}{list of `htmlDependency` objects}
#'   \item{dsvg_fonts}{named list of family names for `dsvg()`}
#'   \item{sources}{named list of source labels}
#' }
#' @family font set functions
#' @export
#' @examples
#' fonts <- font_set(sans = font_liberation("sans"))
#' fonts$sans
#' fonts$dsvg_fonts
#' fonts$dependencies
font_set <- function(sans = NULL, serif = NULL, mono = NULL, symbol = NULL) {
  roles <- list(sans = sans, serif = serif, mono = mono, symbol = symbol)
  families <- list()
  dependencies <- list()
  sources <- list()
  dsvg_fonts <- list()

  for (role in names(roles)) {
    value <- roles[[role]]
    if (is.null(value)) {
      next
    }
    result <- process_font_role(value)
    families[[role]] <- result$family
    sources[[role]] <- result$source
    dsvg_fonts[[role]] <- result$family
    if (!is.null(result$dependency)) {
      dependencies <- c(dependencies, list(result$dependency))
    }
  }

  structure(
    list(
      sans = families[["sans"]],
      serif = families[["serif"]],
      mono = families[["mono"]],
      symbol = families[["symbol"]],
      dependencies = dependencies,
      dsvg_fonts = dsvg_fonts,
      sources = sources
    ),
    class = "font_set"
  )
}

#' @title Liberation font set
#' @description Shortcut to create a [font_set()] with all four
#' font roles using Liberation fonts (Sans, Serif, Mono) and
#' Liberation Sans as a fallback for symbols.
#' @return An object of class `font_set`.
#' @family font set functions
#' @export
#' @examples
#' fonts <- font_set_liberation()
#' fonts
font_set_liberation <- function() {
  font_set(
    sans = font_liberation("sans"),
    serif = font_liberation("serif"),
    mono = font_liberation("mono"),
    symbol = font_liberation("sans")
  )
}

# Try each candidate in order; return the first one found, or NULL.
first_available <- function(candidates) {
  for (f in candidates) {
    if (font_family_exists(f)) {
      return(f)
    }
  }
  NULL
}

#' @title Automatic font set
#' @description Build a [font_set()] by detecting the best available
#' system fonts for each role (sans, serif, mono, symbol).
#'
#' For each role a list of well-known fonts is tried in order.
#' When none is found on the system, the corresponding Liberation
#' font is used as a guaranteed offline fallback.
#'
#' | Role | Candidates (in order) | Fallback |
#' |------|----------------------|----------|
#' | sans | Arial, Helvetica, DejaVu Sans | Liberation Sans |
#' | serif | Times New Roman, Times, DejaVu Serif | Liberation Serif |
#' | mono | Courier New, Courier, DejaVu Sans Mono | Liberation Mono |
#' | symbol | Symbol, Apple Symbols | Liberation Sans |
#'
#' @return An object of class `font_set`.
#' @family font set functions
#' @export
#' @examples
#' fonts <- font_set_auto()
#' fonts
font_set_auto <- function() {
  sans_candidates <- c("Arial", "Helvetica", "DejaVu Sans")
  serif_candidates <- c("Times New Roman", "Times", "DejaVu Serif")
  mono_candidates <- c("Courier New", "Courier", "DejaVu Sans Mono")
  symbol_candidates <- c("Symbol", "Apple Symbols")

  sans <- first_available(sans_candidates)
  serif <- first_available(serif_candidates)
  mono <- first_available(mono_candidates)
  symbol <- first_available(symbol_candidates)

  font_set(
    sans = if (!is.null(sans)) sans else font_liberation("sans"),
    serif = if (!is.null(serif)) serif else font_liberation("serif"),
    mono = if (!is.null(mono)) mono else font_liberation("mono"),
    symbol = if (!is.null(symbol)) symbol else font_liberation("sans")
  )
}

#' @export
print.font_set <- function(x, ...) {
  cat("Font set\n")
  roles <- c("sans", "serif", "mono", "symbol")
  for (role in roles) {
    family <- x[[role]]
    if (!is.null(family)) {
      source <- x$sources[[role]]
      cat(sprintf("  %-8s %s [%s]\n", paste0(role, ":"), family, source))
    }
  }
  n_deps <- length(x$dependencies)
  if (n_deps > 0L) {
    cat(sprintf(
      "  %d HTML %s\n",
      n_deps,
      if (n_deps == 1L) "dependency" else "dependencies"
    ))
  }
  invisible(x)
}
