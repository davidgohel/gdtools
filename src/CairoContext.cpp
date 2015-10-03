#include "gdtools_types.h"
#include <Rcpp.h>
#include <cairo.h>
#include <cairo-pdf.h>
#include <string.h>

using namespace Rcpp;

struct CairoContext::CairoContext_ {
  cairo_surface_t* surface;
  cairo_t* context;
};

CairoContext::CairoContext() {
  cairo_ = new CairoContext_();
  cairo_->surface = cairo_pdf_surface_create(NULL, 720, 720);
  cairo_->context = cairo_create(cairo_->surface);
}

CairoContext::~CairoContext() {
  cairo_surface_destroy(cairo_->surface);
  cairo_destroy(cairo_->context);
  delete cairo_;
}

void CairoContext::setFont(std::string fontname, double fontsize,
  bool bold, bool italic) {

  cairo_select_font_face(cairo_->context,
    fontname.c_str(),
    italic ? CAIRO_FONT_SLANT_ITALIC : CAIRO_FONT_SLANT_NORMAL,
    bold ? CAIRO_FONT_WEIGHT_BOLD : CAIRO_FONT_WEIGHT_NORMAL
  );

  cairo_set_font_size(cairo_->context, fontsize);
}

FontMetric CairoContext::getExtents(std::string x) {
  cairo_text_extents_t te;
  cairo_text_extents(cairo_->context, x.c_str(), &te);

  FontMetric fm;
  fm.height = te.height;
  fm.width = te.x_advance;
  fm.ascent = -te.y_bearing;
  fm.descent = te.height + te.y_bearing;

  return fm;
}
