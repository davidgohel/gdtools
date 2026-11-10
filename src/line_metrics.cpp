#include <Rcpp.h>
#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_TRUETYPE_TABLES_H
#include <algorithm>
#include <vector>

using namespace Rcpp;

// Vertical metrics of the lines of text of fonts, read from the tables of the
// font files with FreeType: the part of a line above its baseline, the part
// below, and their sum, the distance between the baselines of two lines in
// single spacing. Values are in em.
//
// Rule of the text metrics of Windows (GDI), applied by Microsoft Word (see
// the OpenType specification, tables 'OS/2' and 'hhea', and the description
// of usWinAscent and usWinDescent, used for the line spacing on Windows):
//
// - ascent: usWinAscent of 'OS/2', plus the external leading;
// - descent: usWinDescent of 'OS/2';
// - external leading: the lineGap of 'hhea', reduced by what usWinAscent +
//   usWinDescent add to the ascender and descender of 'hhea', and not
//   negative.
//
// Fonts without 'OS/2' table or with null usWinAscent and usWinDescent use
// the ascender, descender and line gap of 'hhea'; fonts without these tables
// use the metrics given by FreeType for the face. `failed` is TRUE when the
// font file could not be opened.
// [[Rcpp::export]]
List font_line_metrics_(CharacterVector path, IntegerVector index) {
  int n = path.size();
  NumericVector ascent(n);
  NumericVector descent(n);
  NumericVector line_height(n);
  LogicalVector failed(n);

  FT_Library library;
  if (FT_Init_FreeType(&library)) {
    Rcpp::stop("FreeType error: unable to initialize FreeType library object");
  }

  for (int i = 0; i < n; ++i) {
    FT_Face face;
    if (FT_New_Face(library, CHAR(path[i]), index[i], &face) != 0) {
      failed[i] = true;
      ascent[i] = descent[i] = line_height[i] = NA_REAL;
      continue;
    }
    double upem = face->units_per_EM > 0 ? face->units_per_EM : 1;
    // defaults: metrics of the face computed by FreeType
    double a = face->ascender;
    double d = -face->descender;
    double gap = std::max(0.0, (double) face->height - (a + d));

    TT_HoriHeader* hhea =
      (TT_HoriHeader*) FT_Get_Sfnt_Table(face, FT_SFNT_HHEA);
    TT_OS2* os2 = (TT_OS2*) FT_Get_Sfnt_Table(face, FT_SFNT_OS2);
    if (hhea != NULL) {
      a = hhea->Ascender;
      d = -hhea->Descender;
      gap = std::max(0, (int) hhea->Line_Gap);
    }
    if (os2 != NULL && os2->version != 0xFFFFu &&
        (os2->usWinAscent > 0 || os2->usWinDescent > 0)) {
      double win_a = os2->usWinAscent;
      double win_d = os2->usWinDescent;
      double external = std::max(0.0, gap - ((win_a + win_d) - (a + d)));
      a = win_a + external;
      d = win_d;
    } else {
      a = a + gap;
    }
    ascent[i] = a / upem;
    descent[i] = d / upem;
    line_height[i] = (a + d) / upem;
    FT_Done_Face(face);
  }
  FT_Done_FreeType(library);

  return List::create(
    _["ascent"] = ascent,
    _["descent"] = descent,
    _["line_height"] = line_height,
    _["failed"] = failed
  );
}
