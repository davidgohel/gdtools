# Liberation Sans -----
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
#' @param name the name to use for the font family when
#' registering with 'systemfonts'. Using a custom name
#' (e.g. `"sans"`, `"serif"`, `"mono"`) allows devices like
#' 'ragg' to resolve generic family names to this font.
#' @return TRUE if the operation went ok.
#' @family functions for font management
#' @examples
#' register_liberationsans()
#' register_liberationsans(name = "sans")
register_liberationsans <- function(name = "Liberation Sans") {
  if (!font_family_exists(name)) {
    liberation_lst <- font_faces("Liberation", family = "sans")
    register_font(
      name = name,
      plain = liberation_lst$plain$ttf,
      bold = liberation_lst$bold$ttf,
      italic = liberation_lst$italic$ttf,
      bolditalic = liberation_lst$bolditalic$ttf
    )
  }
  font_family_exists(name)
}

#' @export
#' @title 'Liberation Sans' Font HTML dependency
#' @description Create an HTML dependency ready
#' to be used in 'Shiny' or 'R Markdown' with
#' 'Liberation Sans' Font.
#' @seealso [gfontHtmlDependency()]
#' @family functions for font management
liberationsansHtmlDependency <- function() {
  pkg_version <- packageVersion("gdtools")
  pkg_version_str <- format(pkg_version)

  font_id <- "liberation-sans"
  liberationsans_to_cache()
  htmlDependency(
    all_files = TRUE,
    name = font_id,
    version = pkg_version_str,
    src = file.path(fonts_cache_dir(), font_id),
    stylesheet = paste0("css/", font_id, ".css")
  )
}


# Liberation Serif -----
liberationserif_to_cache <- function() {
  font_id <- "liberation-serif"

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
      from = system.file(package = "gdtools", "css/liberation-serif.css"),
      to = font_css_, overwrite = TRUE)
  }

}


#' @export
#' @title Register font 'Liberation Serif'
#' @description Register font 'Liberation Serif' so that it can be used
#' with devices using the 'systemfonts' package, i.e. the 'flextable'
#' package and graphic outputs generated with the 'ragg', 'svglite'
#' and 'ggiraph' packages.
#' @inheritParams register_liberationsans
#' @return TRUE if the operation went ok.
#' @family functions for font management
#' @examples
#' register_liberationserif()
#' register_liberationserif(name = "serif")
register_liberationserif <- function(name = "Liberation Serif") {
  if (!font_family_exists(name)) {
    liberation_lst <- font_faces("Liberation", family = "serif")
    register_font(
      name = name,
      plain = liberation_lst$plain$ttf,
      bold = liberation_lst$bold$ttf,
      italic = liberation_lst$italic$ttf,
      bolditalic = liberation_lst$bolditalic$ttf
    )
  }
  font_family_exists(name)
}

#' @export
#' @title 'Liberation Serif' Font HTML dependency
#' @description Create an HTML dependency ready
#' to be used in 'Shiny' or 'R Markdown' with
#' 'Liberation Serif' Font.
#' @seealso [gfontHtmlDependency()]
#' @family functions for font management
liberationserifHtmlDependency <- function() {
  pkg_version <- packageVersion("gdtools")
  pkg_version_str <- format(pkg_version)

  font_id <- "liberation-serif"
  liberationserif_to_cache()
  htmlDependency(
    all_files = TRUE,
    name = font_id,
    version = pkg_version_str,
    src = file.path(fonts_cache_dir(), font_id),
    stylesheet = paste0("css/", font_id, ".css")
  )
}

# Liberation Mono -----
liberationmono_to_cache <- function() {
  font_id <- "liberation-mono"

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
      from = system.file(package = "gdtools", "css/liberation-mono.css"),
      to = font_css_, overwrite = TRUE)
  }

}


#' @export
#' @title Register font 'Liberation Mono'
#' @description Register font 'Liberation Mono' so that it can be used
#' with devices using the 'systemfonts' package, i.e. the 'flextable'
#' package and graphic outputs generated with the 'ragg', 'svglite'
#' and 'ggiraph' packages.
#' @inheritParams register_liberationsans
#' @return TRUE if the operation went ok.
#' @family functions for font management
#' @examples
#' register_liberationmono()
#' register_liberationmono(name = "mono")
register_liberationmono <- function(name = "Liberation Mono") {
  if (!font_family_exists(name)) {
    liberation_lst <- font_faces("Liberation", family = "mono")
    register_font(
      name = name,
      plain = liberation_lst$plain$ttf,
      bold = liberation_lst$bold$ttf,
      italic = liberation_lst$italic$ttf,
      bolditalic = liberation_lst$bolditalic$ttf
    )
  }
  font_family_exists(name)
}

#' @export
#' @title 'Liberation Mono' Font HTML dependency
#' @description Create an HTML dependency ready
#' to be used in 'Shiny' or 'R Markdown' with
#' 'Liberation Mono' Font.
#' @seealso [gfontHtmlDependency()]
#' @family functions for font management
liberationmonoHtmlDependency <- function() {
  pkg_version <- packageVersion("gdtools")
  pkg_version_str <- format(pkg_version)

  font_id <- "liberation-mono"
  liberationmono_to_cache()
  htmlDependency(
    all_files = TRUE,
    name = font_id,
    version = pkg_version_str,
    src = file.path(fonts_cache_dir(), font_id),
    stylesheet = paste0("css/", font_id, ".css")
  )
}

