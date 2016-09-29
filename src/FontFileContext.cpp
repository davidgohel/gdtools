#include "gdtools_types.h"
#include <Rcpp.h>
#include <cairo.h>
#include <cairo-pdf.h>
#include <cairo-ft.h>
#include <ft2build.h>
#include FT_FREETYPE_H

using namespace Rcpp;

struct FontFileContext::FontFileContext_ {
  cairo_surface_t* surface;
  cairo_t* context;
  FT_Library library;
  FT_Face face_regular;
  FT_Face face_bold;
  FT_Face face_italic;
  FT_Face face_bolditalic;
  FontMetric fallback;

};

FontFileContext::FontFileContext(CharacterVector fontfiles) {
  cairo_ = new FontFileContext_();
  cairo_->surface = cairo_pdf_surface_create(NULL, 720, 720);
  cairo_->context = cairo_create(cairo_->surface);

  if ( FT_Init_FreeType( &(cairo_->library) ) ) {
    stop("FreeType error : unable to initialize FreeType library object.");
  }

  if ( FT_New_Face( cairo_->library, fontfiles(0), 0, &(cairo_->face_regular) ) ){
    FT_Done_FreeType(cairo_->library);
    stop("FreeType error : unable to initialize regular face object.");
  }

  if ( fontfiles(1) == NA_STRING ){
    FT_New_Face( cairo_->library, fontfiles(0), 0, &(cairo_->face_bold) );
    warning("bold font file is missing, fallback to regular");
  } else if ( FT_New_Face( cairo_->library, fontfiles(1), 0, &(cairo_->face_bold) ) ){
    FT_Done_FreeType(cairo_->library);
    stop("FreeType error : unable to initialize bold face object.");
  }

  if ( fontfiles(2) == NA_STRING ){
    FT_New_Face( cairo_->library, fontfiles(0), 0, &(cairo_->face_italic) );
    warning("italic font file is missing, fallback to regular");
  } else if( FT_New_Face( cairo_->library, fontfiles(2), 0, &(cairo_->face_italic) ) ){
    FT_Done_FreeType(cairo_->library);
    stop("FreeType error : unable to initialize italic face object.");
  }

  if ( fontfiles(3) == NA_STRING ){
    FT_New_Face( cairo_->library, fontfiles(0), 0, &(cairo_->face_bolditalic) );
    warning("bolditalic font file is missing, fallback to regular");
  } else if( FT_New_Face( cairo_->library, fontfiles(3), 0, &(cairo_->face_bolditalic) ) ){
    FT_Done_FreeType(cairo_->library);
    stop("FreeType error : unable to initialize bolditalic face object.");
  }

}

FontFileContext::~FontFileContext() {
  cairo_destroy(cairo_->context);
  cairo_surface_destroy(cairo_->surface);
  delete cairo_;
}

void FontFileContext::setFont(double fontsize, bool bold, bool italic) {
  cairo_set_font_size(cairo_->context, fontsize);
  cairo_font_face_t *fontFace;

  if( !bold && !italic)
    fontFace = cairo_ft_font_face_create_for_ft_face(cairo_->face_regular,0);
  else if( bold && !italic)
    fontFace = cairo_ft_font_face_create_for_ft_face(cairo_->face_bold,0);
  else if( !bold && italic)
    fontFace = cairo_ft_font_face_create_for_ft_face(cairo_->face_italic,0);
  else
    fontFace = cairo_ft_font_face_create_for_ft_face(cairo_->face_bolditalic,0);

  cairo_set_font_face(cairo_->context, fontFace);
}

void FontFileContext::setFallBack(std::string fallback) {
  cairo_->fallback.ascent = 0.0;
  cairo_->fallback.descent = 0.0;
  cairo_->fallback.width = 0.0;
  cairo_->fallback.height = 0.0;

  cairo_->fallback = this->getExtents(fallback.c_str());
}
FontMetric FontFileContext::getExtents(std::string x) {

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
        warning("[gdtools] FontFileContext::getExtents: not match glyph in font table.");
        w_ += cairo_->fallback.width;
        h_ = (cairo_->fallback.height > h_) ? cairo_->fallback.height : h_;
        a_ = (-cairo_->fallback.ascent < a_) ? -cairo_->fallback.ascent : a_;
        d_ = (cairo_->fallback.descent > d_) ? cairo_->fallback.descent : d_;
      }

      glyph_index += cluster->num_glyphs;
    }
  } else stop("[gdtools] FontFileContext::getExtents");


  FontMetric fm;
  fm.height = h_;
  fm.width = w_;
  fm.ascent = -a_;
  fm.descent = d_ ;

  cairo_glyph_free(glyphs);
  cairo_text_cluster_free(clusters);

  return fm;
}
