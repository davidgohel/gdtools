#include <Rcpp.h>
#include "TextExtents.h"

using namespace Rcpp;

//' Compute string extents.
//'
//' Determines the width and height of a bounding box that's big enough
//' to (just) enclose the provided text.
//'
//' @param x Character vector of of strings to measure
//' @param bold,italic Is text bold/italic?
//' @param fontname Font name
//' @param fontsize Font size (in pixels)
//' @examples
//' str_extents(letters)
//' str_extents("Hello World!", bold = TRUE, italic = FALSE,
//'   fontname = "Sans", fontsize = 12)
//' @export
// [[Rcpp::export]]
NumericMatrix str_extents(CharacterVector x, std::string fontname = "sans",
                          int fontsize = 12, int bold = false,
                          int italic = false) {
  int n = x.size();
  TextExtents te;
  te.setFont(fontname, fontsize, bold, italic);
  NumericMatrix out(n, 2);

  for (int i = 0; i < n; ++i) {
    if (x[i] == NA_STRING) {
      out(i, 0) = NA_REAL;
      out(i, 1) = NA_REAL;
    } else {
      std::string str(Rf_translateCharUTF8(x[i]));
      FontMetric fm = te.extents(str);

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
NumericVector str_metrics(std::string x, std::string fontname = "sans",
                          int fontsize = 12, int bold = false,
                          int italic = false) {

  TextExtents te;
  te.setFont(fontname, fontsize, bold, italic);
  FontMetric fm = te.extents(x);

  return NumericVector::create(
    _["width"] = fm.width,
    _["ascent"] = fm.ascent,
    _["descent"] = fm.descent
  );
}
