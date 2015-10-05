#include "gdtools_types.h"
#include <Rcpp.h>
#include <cairo-ft.h>
#include <fontconfig/fontconfig.h>

using namespace Rcpp;

//' Compute string extents.
//'
//' Determines the width and height of a bounding box that's big enough
//' to (just) enclose the provided text.
//'
//' @param x Character vector of of strings to measure
//' @param bold,italic Is text bold/italic?
//' @param fontname Font name
//' @param fontsize Font size
//' @examples
//' str_extents(letters)
//' str_extents("Hello World!", bold = TRUE, italic = FALSE,
//'   fontname = "sans", fontsize = 12)
//' @export
// [[Rcpp::export]]
NumericMatrix str_extents(CharacterVector x, std::string fontname = "sans",
                          double fontsize = 12, int bold = false,
                          int italic = false) {
  int n = x.size();
  CairoContext cc;
  cc.setFont(fontname, fontsize, bold, italic);
  NumericMatrix out(n, 2);

  for (int i = 0; i < n; ++i) {
    if (x[i] == NA_STRING) {
      out(i, 0) = NA_REAL;
      out(i, 1) = NA_REAL;
    } else {
      std::string str(Rf_translateCharUTF8(x[i]));
      FontMetric fm = cc.getExtents(str);

      out(i, 0) = fm.width;
      out(i, 1) = fm.height;
    }
  }

  return out;
}

//' Get font metrics for a string.
//'
//' @return A named numeric vector
//' @inheritParams str_extents
//' @examples
//' str_metrics("Hello World!")
//' @export
// [[Rcpp::export]]
NumericVector str_metrics(CharacterVector x, std::string fontname = "sans",
                          double fontsize = 12, int bold = false,
                          int italic = false) {

  CairoContext cc;
  cc.setFont(fontname, fontsize, bold, italic);

  std::string str(Rf_translateCharUTF8(x[0]));

  FontMetric fm = cc.getExtents(str);

  return NumericVector::create(
    _["width"] = fm.width,
    _["ascent"] = fm.ascent,
    _["descent"] = fm.descent
  );
}


//' Check if font family exists.
//'
//' @return A logical value
//' @param font_family font family name (case sensitive)
//' @examples
//' font_family_exists("sans")
//' font_family_exists("Arial")
//' font_family_exists("Courier")
//' @export
// [[Rcpp::export]]
bool font_family_exists(std::string font_family = "sans" ) {

  FcFontSet *font_set;
  FcPattern *font_pattern;
  FcResult font_result;
  FcPattern *font_candidate;

  if (!FcInit ()) {
    warning ("Font config initialization failed");
    return R_NilValue;
  }

  font_pattern = FcNameParse ((const FcChar8 *)font_family.c_str());

  if (!font_pattern){
    warning ("Unable to parse pattern string");
    return R_NilValue;
  }

  FcConfigSubstitute (0, font_pattern, FcMatchPattern);
  FcDefaultSubstitute (font_pattern);
  font_set = FcFontSetCreate ();

  font_candidate = FcFontMatch (0, font_pattern, &font_result);
  if (font_candidate)
    FcFontSetAdd (font_set, font_candidate);

  FcPatternDestroy (font_pattern);

  bool out = FALSE;
  if (font_set) {
    int	j;

    for (j = 0; j < font_set->nfont; j++) {
      FcChar8	*family;

      if (FcPatternGetString (font_set->fonts[j], FC_FAMILY, 0, &family) != FcResultMatch)
        family = (FcChar8 *) R_NilValue;
      const char* charFamily = reinterpret_cast<char*>(family);
      if( charFamily == font_family)
        out = TRUE;
      break;
    }

    FcFontSetDestroy (font_set);
  }
  return out;
}

