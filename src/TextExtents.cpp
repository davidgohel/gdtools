#include <Rcpp.h>
#include <cairo.h>
#include <string.h>

#include "TextExtents.h"

struct TextExtents::CairoContext {
  cairo_surface_t* surface;
  cairo_t* context;
};

TextExtents::TextExtents() {
  cairo_ = new CairoContext();
  cairo_->surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 100, 100);
  cairo_->context = cairo_create(cairo_->surface);
}

TextExtents::~TextExtents() {
  cairo_surface_destroy(cairo_->surface);
  cairo_destroy(cairo_->context);
  delete cairo_;
}

void TextExtents::setFont(std::string fontname, double fontsize,
                          bool bold, bool italic) {

  cairo_select_font_face(cairo_->context,
    fontname.c_str(),
    italic ? CAIRO_FONT_SLANT_ITALIC : CAIRO_FONT_SLANT_NORMAL,
    bold ? CAIRO_FONT_WEIGHT_BOLD : CAIRO_FONT_WEIGHT_NORMAL
  );

  cairo_set_font_size(cairo_->context, fontsize);
}


FontMetric TextExtents::extents(std::string x) {
  cairo_text_extents_t te;
  cairo_text_extents(cairo_->context, x.c_str(), &te);

  FontMetric fm;
  fm.height = te.height;
  fm.width = te.x_advance;
  fm.ascent = -te.y_bearing;
  fm.descent = te.height + te.y_bearing;

  return fm;
}
