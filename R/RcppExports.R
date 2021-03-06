# Generated by using Rcpp::compileAttributes() -> do not edit by hand
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

str_extents_ <- function(x, fontname = "sans", fontsize = 12, bold = FALSE, italic = FALSE, fontfile = "") {
    .Call('_gdtools_str_extents_', PACKAGE = 'gdtools', x, fontname, fontsize, bold, italic, fontfile)
}

str_metrics_ <- function(x, fontname = "sans", fontsize = 12, bold = FALSE, italic = FALSE, fontfile = "") {
    .Call('_gdtools_str_metrics_', PACKAGE = 'gdtools', x, fontname, fontsize, bold, italic, fontfile)
}

m_str_extents_ <- function(x, fontname, fontsize, bold, italic, fontfile) {
    .Call('_gdtools_m_str_extents_', PACKAGE = 'gdtools', x, fontname, fontsize, bold, italic, fontfile)
}

glyphs_match_ <- function(x, fontname = "sans", bold = FALSE, italic = FALSE, fontfile = "") {
    .Call('_gdtools_glyphs_match_', PACKAGE = 'gdtools', x, fontname, bold, italic, fontfile)
}

context_create <- function() {
    .Call('_gdtools_context_create', PACKAGE = 'gdtools')
}

context_set_font <- function(cc, fontname, fontsize, bold, italic, fontfile = "") {
    .Call('_gdtools_context_set_font', PACKAGE = 'gdtools', cc, fontname, fontsize, bold, italic, fontfile)
}

context_extents <- function(cc, x) {
    .Call('_gdtools_context_extents', PACKAGE = 'gdtools', cc, x)
}

raster_to_str <- function(raster, w, h, width, height, interpolate) {
    .Call('_gdtools_raster_to_str', PACKAGE = 'gdtools', raster, w, h, width, height, interpolate)
}

raster_to_file <- function(raster, w, h, width, height, interpolate, filename) {
    .Call('_gdtools_raster_to_file', PACKAGE = 'gdtools', raster, w, h, width, height, interpolate, filename)
}

raster_png_ <- function(raster_, w, h, width, height, interpolate, filename) {
    .Call('_gdtools_raster_png_', PACKAGE = 'gdtools', raster_, w, h, width, height, interpolate, filename)
}

base64_raster_encode <- function(raster_, w, h, width, height, interpolate) {
    .Call('_gdtools_base64_raster_encode', PACKAGE = 'gdtools', raster_, w, h, width, height, interpolate)
}

base64_file_encode <- function(filename) {
    .Call('_gdtools_base64_file_encode', PACKAGE = 'gdtools', filename)
}

base64_string_encode <- function(string) {
    .Call('_gdtools_base64_string_encode', PACKAGE = 'gdtools', string)
}

#' @rdname version_cairo
#' @export
version_freetype <- function() {
    .Call('_gdtools_version_freetype', PACKAGE = 'gdtools')
}

version_cairo_ <- function() {
    .Call('_gdtools_version_cairo_', PACKAGE = 'gdtools')
}

# Register entry points for exported C++ functions
methods::setLoadAction(function(ns) {
    .Call('_gdtools_RcppExport_registerCCallable', PACKAGE = 'gdtools')
})
