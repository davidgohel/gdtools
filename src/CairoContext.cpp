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
  bool currently_freetype; // FIXME: needed?
  FT_Library library;
  std::vector<FT_Face> ft_fonts;
  std::map<std::string, cairo_font_face_t*> fonts;
  FontMetric fallback;
};

CairoContext::CairoContext() {
  cairo_ = new CairoContext_();
  cairo_->surface = cairo_pdf_surface_create(NULL, 720, 720);
  cairo_->context = cairo_create(cairo_->surface);
  cairo_->currently_freetype = 0;

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

  if (fontfile.size()) {
    if (cairo_->fonts.find(fontfile) == cairo_->fonts.end()) {
      cairo_->ft_fonts.push_back(FT_Face());
      FT_Face* new_face = &(cairo_->ft_fonts[cairo_->ft_fonts.size()]);
      FT_New_Face(cairo_->library, fontfile.c_str(), 0, new_face);
      cairo_->fonts[fontfile] = cairo_ft_font_face_create_for_ft_face(*new_face, 0);
    }
    cairo_set_font_face(cairo_->context, cairo_->fonts[fontfile]);
    cairo_->currently_freetype = 1;
  } else {
    cairo_select_font_face(cairo_->context,
      fontname.c_str(),
      italic ? CAIRO_FONT_SLANT_ITALIC : CAIRO_FONT_SLANT_NORMAL,
      bold ? CAIRO_FONT_WEIGHT_BOLD : CAIRO_FONT_WEIGHT_NORMAL
    );
    cairo_->currently_freetype = 0;
  }
  cairo_set_font_size(cairo_->context, fontsize);

  // set fallback
  cairo_->fallback = this->getExtents("M");
}

FontMetric CairoContext::getExtents(std::string x) {
  cairo_glyph_t* glyphs = NULL;
  int glyph_count;
  cairo_text_cluster_t* clusters = NULL;
  int cluster_count;
  cairo_text_cluster_flags_t clusterflags;

  cairo_status_t status = cairo_scaled_font_text_to_glyphs(cairo_get_scaled_font(cairo_->context), 0, 0, x.c_str(), x.size(), &glyphs, &glyph_count, &clusters, &cluster_count,
                                                           &clusterflags);
  double w_ = 0.0;
  double h_ = 0.0;
  double a_ = 0.0;
  double d_ = 0.0;
  double descent = 0;

  if (status == CAIRO_STATUS_SUCCESS) {

    // for each cluster
    int glyph_index = 0;
    for (int i = 0; i < cluster_count; i++) {
      cairo_text_cluster_t* cluster = &clusters[i];

      cairo_glyph_t* clusterglyphs = &glyphs[glyph_index];
      if( clusterglyphs[0].index > 0 ){
        cairo_text_extents_t extents;
        cairo_scaled_font_glyph_extents(cairo_get_scaled_font(cairo_->context), clusterglyphs, cluster->num_glyphs, &extents);
        descent = extents.height + extents.y_bearing;

        w_ += extents.x_advance;
        h_ = (extents.height > h_) ? extents.height : h_;
        a_ = (extents.y_bearing < a_) ? extents.y_bearing : a_;
        d_ = (descent > d_) ? descent : d_;
      } else {
        warning("CairoContext::getExtents: not match glyph in font table.");
        w_ += cairo_->fallback.width;
        h_ = (cairo_->fallback.height > h_) ? cairo_->fallback.height : h_;
        a_ = (-cairo_->fallback.ascent < a_) ? -cairo_->fallback.ascent : a_;
        d_ = (cairo_->fallback.descent > d_) ? cairo_->fallback.descent : d_;
      }

      glyph_index += cluster->num_glyphs;
    }
  } else stop("Could not get table of glyphs");


  FontMetric fm;
  fm.height = h_;
  fm.width = w_;
  fm.ascent = -a_;
  fm.descent = d_ ;

  cairo_glyph_free(glyphs);
  cairo_text_cluster_free(clusters);

  return fm;
}
