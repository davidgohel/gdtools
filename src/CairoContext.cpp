#include <string>
#include <map>
#include <algorithm>
#include <Rcpp.h>
#include <cairo.h>
#include <cairo-pdf.h>
#include <cairo-ft.h>
#include <fontconfig/fontconfig.h>
#include <ft2build.h>
#include FT_FREETYPE_H
#include "gdtools_types.h"

using namespace Rcpp;

struct CairoContext::CairoContext_ {
  cairo_surface_t* surface;
  cairo_t* context;

  FT_Library library;
  std::vector<FT_Face> ft_fonts;
  fontCache fonts;
};

CairoContext::CairoContext() {
  cairo_ = new CairoContext_();
  cairo_->surface = cairo_pdf_surface_create(NULL, 720, 720);
  cairo_->context = cairo_create(cairo_->surface);

  if (!FcInit())
    Rcpp::stop("Fontconfig error: unable to initialize");
  if (FT_Init_FreeType(&(cairo_->library)))
    Rcpp::stop("FreeType error: unable to initialize FreeType library object");
}

CairoContext::~CairoContext() {
  cairo_surface_destroy(cairo_->surface);
  cairo_destroy(cairo_->context);

  fontCache::iterator it = cairo_->fonts.begin();
  while (it != cairo_->fonts.end()) {
    cairo_font_face_destroy(it->second);
    ++it;
  }
  std::for_each(cairo_->ft_fonts.begin(), cairo_->ft_fonts.end(), &FT_Done_Face);

  delete cairo_;
}

void CairoContext::cacheFont(fontCache& cache, std::string& key, std::string& fontfile) {
  FT_Face face;
  if (0 != FT_New_Face(cairo_->library, fontfile.c_str(), 0, &face))
    Rcpp::stop("FreeType error: unable to create the font %s", fontfile.c_str());
  cairo_->ft_fonts.push_back(face);

  cache[key] = cairo_ft_font_face_create_for_ft_face(face, 0);
}

void CairoContext::cacheSystemFont(std::string& key, std::string& fontname,
                                   bool bold, bool italic) {
  FcPattern* pattern;
  if(!(pattern = FcNameParse((FcChar8 *) fontname.c_str())))
    Rcpp::stop("Fontconfig error: unable to parse font name: %s", fontname.c_str());

  int weight = bold ? FC_WEIGHT_BOLD : FC_WEIGHT_MEDIUM;
  int slant = italic ? FC_SLANT_ITALIC : FC_SLANT_ROMAN;
  FcPatternAddInteger(pattern, FC_WEIGHT, weight);
  FcPatternAddInteger(pattern, FC_SLANT, slant);

  FcResult result;
  FcDefaultSubstitute(pattern);
  FcConfigSubstitute(0, pattern, FcMatchPattern);
  FcPattern* match = FcFontMatch(0, pattern, &result);

  FcChar8 *matched_file;
  if (match && FcPatternGetString(match, FC_FILE, 0, &matched_file) == FcResultMatch) {
    std::string fontfile = (const char*) matched_file;
    cacheFont(cairo_->fonts, key, fontfile);
  } else {
    Rcpp::stop("Fontconfig error: unable to match font pattern");
  }
}

void CairoContext::setFont(std::string fontname, double fontsize,
                           bool bold, bool italic, std::string fontfile) {
  cairo_set_font_size(cairo_->context, fontsize);

  // Can't make symbols font work correctly with a font selected via
  // fontconfig so we use the toy API which somehow handles it properly.
  if (fontname == "symbol") {
    cairo_select_font_face(cairo_->context,
      fontname.c_str(),
      italic ? CAIRO_FONT_SLANT_ITALIC : CAIRO_FONT_SLANT_NORMAL,
      bold ? CAIRO_FONT_WEIGHT_BOLD : CAIRO_FONT_WEIGHT_NORMAL);
    return;
  }

  std::string key;

  if (fontfile.size()) {
    key = fontfile;
    if (cairo_->fonts.find(key) == cairo_->fonts.end())
      cacheFont(cairo_->fonts, key, fontfile);
  } else {
    char props[20];
    snprintf(props, sizeof(props), " %d %d", (int) bold, (int) italic);
    key = fontname + props;
    if (cairo_->fonts.find(key) == cairo_->fonts.end())
      cacheSystemFont(key, fontname, bold, italic);
  }
  cairo_set_font_face(cairo_->context, cairo_->fonts[key]);
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
