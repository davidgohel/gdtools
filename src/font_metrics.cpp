#include <Rcpp.h>
#include <cairo.h>
#include <string.h>

// [[Rcpp::interfaces(r, cpp)]]
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector str_extent(std::string str, bool bold = false,
                         bool italic = false,
                         std::string fontname = "Sans",
                         int fontsize = 12) {

  cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 100, 100);
  cairo_t *cr = cairo_create (surface);

  cairo_font_slant_t slant = CAIRO_FONT_SLANT_NORMAL;
  cairo_font_weight_t wght  = CAIRO_FONT_WEIGHT_NORMAL;

  if( bold > 0 ) wght = CAIRO_FONT_WEIGHT_BOLD;
  if( italic > 0 ) slant = CAIRO_FONT_SLANT_ITALIC;

  cairo_select_font_face (cr, fontname.c_str(), slant, wght);
  cairo_set_font_size(cr, (double)fontsize);
  cairo_text_extents_t te;
  cairo_text_extents (cr, str.c_str(), &te);

  return NumericVector::create(te.x_advance, te.height);
}

//' Compute string extents.
//'
//' Determines the width and height of a bounding box that's big enough
//' to (just) enclose the provided text.
//'
//' @param str Character ector of of strings to measure
//' @param bold,italic Is text bold/italic?
//' @param fontname Font name
//' @param fontsize Font size (in pixels)
//' @examples
//' str_extents(letters)
//' str_extents("Hello World!", bold = TRUE, italic = FALSE,
//'   fontname = "Sans", fontsize = 12)
//' @export
// [[Rcpp::export]]
NumericMatrix str_extents(CharacterVector str, bool bold = false,
                          bool italic = false, std::string fontname = "Sans",
                          int fontsize = 12) {
  int n = str.size();
  NumericMatrix out(n, 2);

  for (int i = 0; i < n; ++i) {
    if (str[i] == NA_STRING) {
      out(i, 0) = NA_REAL;
      out(i, 1) = NA_REAL;
    } else {
      NumericVector extent = str_extent(std::string(str[i]),
        bold, italic, fontname, fontsize);
      out.row(i) = extent;
    }
  }

  return out;
}


// [[Rcpp::export]]
NumericVector get_font_info(std::string str, int bold, int italic, std::string fontname, int fontsize ) {
  cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 100, 100);
  cairo_t *cr = cairo_create (surface);

  cairo_font_slant_t slant = CAIRO_FONT_SLANT_NORMAL;
  cairo_font_weight_t wght  = CAIRO_FONT_WEIGHT_NORMAL;

  if( bold > 0 ) wght = CAIRO_FONT_WEIGHT_BOLD;
  if( italic > 0 ) slant = CAIRO_FONT_SLANT_ITALIC;
  cairo_select_font_face (cr, fontname.c_str(), slant, wght);
  cairo_set_font_size(cr, (double)fontsize);
  cairo_text_extents_t te;
  cairo_text_extents (cr, str.c_str(), &te);
  NumericVector out(3);
  out[0] = te.x_advance;
  out[1] = -te.y_bearing;
  out[2] = te.height+te.y_bearing;
  return out;
}
