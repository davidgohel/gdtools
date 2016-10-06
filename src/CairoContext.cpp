#include <string>
#include <map>
#include <algorithm>
#include <Rcpp.h>
#include <cairo.h>
#include <cairo-pdf.h>
#include <cairo-ft.h>
#include <ft2build.h>
#include FT_FREETYPE_H
#include "gdtools_types.h"

using namespace Rcpp;

struct CairoContext::CairoContext_ {
  cairo_surface_t* surface;
  cairo_t* context;
  FT_Library library;
  std::vector<FT_Face> ft_fonts;
  std::map<std::string, cairo_font_face_t*> fonts;
};

CairoContext::CairoContext() {
  cairo_ = new CairoContext_();
  cairo_->surface = cairo_pdf_surface_create(NULL, 720, 720);
  cairo_->context = cairo_create(cairo_->surface);

  if (FT_Init_FreeType(&(cairo_->library)))
    stop("FreeType error : unable to initialize FreeType library object.");
}

CairoContext::~CairoContext() {
  cairo_surface_destroy(cairo_->surface);
  cairo_destroy(cairo_->context);

  std::map<std::string, cairo_font_face_t*>::iterator fonts_it = cairo_->fonts.begin();
  while (fonts_it != cairo_->fonts.end()) {
    cairo_font_face_destroy(fonts_it->second);
    ++fonts_it;
  }
  std::for_each(cairo_->ft_fonts.begin(), cairo_->ft_fonts.end(), &FT_Done_Face);

  delete cairo_;
}

void CairoContext::setFont(std::string fontname, double fontsize,
                           bool bold, bool italic, std::string fontfile) {
  cairo_set_font_size(cairo_->context, fontsize);

  if (fontfile.size())
    setUserFont(fontname, fontsize, bold, italic, fontfile);
  else
    setSystemFont(fontname, fontsize, bold, italic);
}

void CairoContext::setUserFont(std::string& fontname, double fontsize,
                               bool bold, bool italic, std::string& fontfile) {
  if (cairo_->fonts.find(fontfile) == cairo_->fonts.end()) {
    cairo_->ft_fonts.push_back(FT_Face());
    FT_Face* new_face = &(cairo_->ft_fonts[cairo_->ft_fonts.size()]);
    FT_New_Face(cairo_->library, fontfile.c_str(), 0, new_face);
    cairo_->fonts[fontfile] = cairo_ft_font_face_create_for_ft_face(*new_face, 0);
  }

  cairo_set_font_face(cairo_->context, cairo_->fonts[fontfile]);
}

void CairoContext::setSystemFont(std::string& fontname, double fontsize,
                                 bool bold, bool italic) {
  cairo_select_font_face(cairo_->context,
                         fontname.c_str(),
                         italic ? CAIRO_FONT_SLANT_ITALIC : CAIRO_FONT_SLANT_NORMAL,
                         bold ? CAIRO_FONT_WEIGHT_BOLD : CAIRO_FONT_WEIGHT_NORMAL);
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
