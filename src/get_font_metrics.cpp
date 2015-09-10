#include <Rcpp.h>
#include <cairo.h>
#include <string.h>

using namespace Rcpp;

// [[Rcpp::interfaces(r, cpp)]]

// [[Rcpp::export]]
NumericVector get_str_dim(std::string str, int bold, int italic, std::string fontname, int fontsize ) {
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
  NumericVector out(2);
  out[0] = te.x_advance;
  out[1] = te.height;
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
