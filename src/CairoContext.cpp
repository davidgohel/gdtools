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
  fontCache fonts;
};

CairoContext::CairoContext() {
  cairo_ = new CairoContext_();
  cairo_->surface = cairo_pdf_surface_create(NULL, 720, 720);
  cairo_->context = cairo_create(cairo_->surface);

  if (FT_Init_FreeType(&(cairo_->library)))
    Rcpp::stop("FreeType error: unable to initialize FreeType library object");
}

CairoContext::~CairoContext() {
  fontCache::iterator it = cairo_->fonts.begin();
  while (it != cairo_->fonts.end()) {
    cairo_font_face_destroy(it->second);
    ++it;
  }

  cairo_surface_destroy(cairo_->surface);
  cairo_destroy(cairo_->context);

  delete cairo_;
}

void CairoContext::cacheFont(fontCache& cache, std::string& key,
                             std::string fontfile, int fontindex)  {
  FT_Face face;
  if (0 != FT_New_Face(cairo_->library, fontfile.c_str(), fontindex, &face))
    Rcpp::stop("FreeType error: unable to open %s", fontfile.c_str());

  cairo_font_face_t* cairo_face = cairo_ft_font_face_create_for_ft_face(face, 0);

  cairo_user_data_key_t font_key;
  cairo_status_t status = cairo_font_face_set_user_data(
    cairo_face, &font_key, face, (cairo_destroy_func_t) FT_Done_Face
  );
  if (status) {
    cairo_font_face_destroy(cairo_face);
    FT_Done_Face(face);
    Rcpp::stop("Cairo error: unable to handle %s", fontfile.c_str());
  }

  cache[key] = cairo_face;
}

struct font_file_t {
  std::string file;
  int index;
};

static int locate_font(const char *family, int italic, int bold, char *path, int max_path_length) {
  static int (*p_locate_font)(const char *family, int italic, int bold, char *path, int max_path_length) = NULL;
  if (p_locate_font == NULL) {
    p_locate_font = (int(*)(const char *, int, int, char *, int)) R_GetCCallable("systemfonts", "locate_font");
  }
  return p_locate_font(family, italic, bold, path, max_path_length);
}


font_file_t findFontFile(const char* fontname, int bold, int italic) {

  char *path = new char[PATH_MAX+1];
  path[PATH_MAX] = '\0';

  font_file_t output;
  output.index = locate_font(fontname, italic, bold, path, PATH_MAX);
  output.file = path;
  delete[] path;
  if (output.file.size())
    return output;
  else
    Rcpp::stop("error: unable to match font pattern");
}

void CairoContext::setFont(std::string fontname, double fontsize,
                           bool bold, bool italic, std::string fontfile) {
  std::string key;
  if (fontfile.size()) {
    // Use file path as key to cached elements
    key = fontfile;
    if (cairo_->fonts.find(key) == cairo_->fonts.end()) {
      cacheFont(cairo_->fonts, key, fontfile, 0);
    }
  } else {
    // Use font name and bold/italic properties as key
    char props[20];
    snprintf(props, sizeof(props), " %d %d", (int) bold, (int) italic);
    key = fontname + props;
    if (cairo_->fonts.find(key) == cairo_->fonts.end()) {
      // Add font to cache
      font_file_t fontfile = findFontFile(fontname.c_str(), bold, italic);
      cacheFont(cairo_->fonts, key, fontfile.file, fontfile.index);
    }
  }

  cairo_set_font_size(cairo_->context, fontsize);
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


bool CairoContext::validateGlyphs(std::string x) {

  cairo_glyph_t* glyphs = NULL;
  int glyph_count;
  cairo_text_cluster_t* clusters = NULL;
  int cluster_count;
  cairo_text_cluster_flags_t clusterflags;
  bool out = true;

  cairo_status_t status = cairo_scaled_font_text_to_glyphs(cairo_get_scaled_font(cairo_->context), 0, 0, x.c_str(), x.size(), &glyphs, &glyph_count, &clusters, &cluster_count,
                                                           &clusterflags);

  if (status == CAIRO_STATUS_SUCCESS) {

    // for each cluster
    int glyph_index = 0;
    for (int i = 0; i < cluster_count; i++) {
      cairo_text_cluster_t* cluster = &clusters[i];

      cairo_glyph_t* clusterglyphs = &glyphs[glyph_index];
      if( clusterglyphs[0].index < 1 ){
        out = false;
        break;
      }

      glyph_index += cluster->num_glyphs;
    }
  } else stop("Could not get table of glyphs");

  cairo_glyph_free(glyphs);
  cairo_text_cluster_free(clusters);

  return out;
}
