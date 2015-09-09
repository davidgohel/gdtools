#include <Rcpp.h>
#include <cairo.h>
#include <string.h>

using namespace Rcpp;

// [[Rcpp::export]]
double get_font_metrics(CharacterVector str, int bold, int italic, CharacterVector fontface, int fontsize ) {
  cairo_surface_t *surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 100, 100);
  cairo_t *cr = cairo_create (surface);

  cairo_font_slant_t slant = CAIRO_FONT_SLANT_NORMAL;
  cairo_font_weight_t wght  = CAIRO_FONT_WEIGHT_NORMAL;

  if( bold > 0 ) wght = CAIRO_FONT_WEIGHT_BOLD;
  if( italic > 0 ) slant = CAIRO_FONT_SLANT_ITALIC;


  cairo_select_font_face (cr, fontface[0], slant, wght);

  cairo_text_extents_t te;
  cairo_text_extents (cr, str[0], &te);
  return te.x_advance;
}

