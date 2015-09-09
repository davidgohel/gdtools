#include <Rcpp.h>
#include <cairo.h>
#include <string.h>

using namespace Rcpp;



// [[Rcpp::export]]
NumericVector get_font_metrics(std::string str, int bold, int italic, std::string fontface, int fontsize ) {
  cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 100, 100);
  cairo_t *cr = cairo_create (surface);

  cairo_font_slant_t slant = CAIRO_FONT_SLANT_NORMAL;
  cairo_font_weight_t wght  = CAIRO_FONT_WEIGHT_NORMAL;

  if( bold > 0 ) wght = CAIRO_FONT_WEIGHT_BOLD;
  if( italic > 0 ) slant = CAIRO_FONT_SLANT_ITALIC;


  cairo_select_font_face (cr, fontface.c_str(), slant, wght);

  cairo_text_extents_t te;
  cairo_text_extents (cr, str.c_str(), &te);
  NumericVector out(2);
  out[0] = te.x_advance;
  out[1] = te.height;
  return out;
}
