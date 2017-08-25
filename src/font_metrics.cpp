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
//' @param x Character vector of strings to measure
//' @param bold,italic Is text bold/italic?
//' @param fontname Font name
//' @param fontsize Font size
//' @param fontfile Font file
//' @examples
//' \donttest{
//' # The first run can be slow when font caches are missing
//' # as font files are then being scanned to build those font caches.
//' str_extents(letters)
//' str_extents("Hello World!", bold = TRUE, italic = FALSE,
//'   fontname = "sans", fontsize = 12)
//' }
//' @export
// [[Rcpp::export]]
NumericMatrix str_extents(CharacterVector x, std::string fontname = "sans",
                          double fontsize = 12, int bold = false,
                          int italic = false, std::string fontfile = "") {
  int n = x.size();
  CairoContext cc;
  cc.setFont(fontname, fontsize, bold, italic, fontfile);
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
//' \donttest{
//' # The first run can be slow when font caches are missing
//' # as font files are then being scanned to build those font caches.
//' str_metrics("Hello World!")
//' }
//' @export
// [[Rcpp::export]]
NumericVector str_metrics(CharacterVector x, std::string fontname = "sans",
                          double fontsize = 12, int bold = false,
                          int italic = false, std::string fontfile = "") {

  CairoContext cc;
  cc.setFont(fontname, fontsize, bold, italic, fontfile);

  std::string str(Rf_translateCharUTF8(x[0]));

  FontMetric fm = cc.getExtents(str);

  return NumericVector::create(
    _["width"] = fm.width,
    _["ascent"] = fm.ascent,
    _["descent"] = fm.descent
  );
}

// [[Rcpp::export]]
NumericMatrix m_str_extents_(CharacterVector x,
                            std::vector<std::string> fontname,
                            std::vector<double> fontsize,
                            std::vector<int> bold,
                            std::vector<int> italic,
                            std::vector<std::string> fontfile) {
  int n = x.size();
  CairoContext cc;
  NumericMatrix out(n, 2);

  for (int i = 0; i < n; ++i) {
    cc.setFont(fontname[i], fontsize[i], bold[i], italic[i], fontfile[i]);
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

//' Validate glyph entries
//'
//' Determines if strings contain glyphs not part of a font.
//'
//' @param x Character vector of strings
//' @param bold,italic Is text bold/italic?
//' @param fontname Font name
//' @param fontfile Font file
//' @return a logical vector, if a character element is containing at least
//' a glyph that can not be matched in the font table, FALSE is returned.
//'
//' @examples
//' glyphs_match(letters)
//' glyphs_match("\u265E", bold = TRUE)
//' @export
// [[Rcpp::export]]
LogicalVector glyphs_match(CharacterVector x, std::string fontname = "sans",
                          int bold = false, int italic = false,
                          std::string fontfile = "") {
  int n = x.size();
  CairoContext cc;
  cc.setFont(fontname, 10.0, bold, italic, fontfile);
  LogicalVector out(n);

  for (int i = 0; i < n; ++i) {
    if (x[i] == NA_STRING) {
      out(i) = NA_LOGICAL;
    } else {
      std::string str(Rf_translateCharUTF8(x[i]));
      out(i) = cc.validateGlyphs(str);
    }
  }

  return out;
}



