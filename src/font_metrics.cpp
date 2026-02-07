#include "gdtools_types.h"
#include <Rcpp.h>
#include <cairo-ft.h>

using namespace Rcpp;

// [[Rcpp::export]]
NumericMatrix str_extents_(CharacterVector x, std::string fontname = "sans",
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

// [[Rcpp::export]]
NumericVector str_metrics_(CharacterVector x, std::string fontname = "sans",
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

// [[Rcpp::export]]
Rcpp::DataFrame m_str_metrics_(CharacterVector x,
                               std::vector<std::string> fontname,
                               std::vector<double> fontsize,
                               std::vector<int> bold,
                               std::vector<int> italic,
                               std::vector<std::string> fontfile) {
  int n = x.size();
  CairoContext cc;
  NumericVector widths(n);
  NumericVector ascents(n);
  NumericVector descents(n);

  for (int i = 0; i < n; ++i) {
    cc.setFont(fontname[i], fontsize[i], bold[i], italic[i], fontfile[i]);
    if (x[i] == NA_STRING) {
      widths[i] = NA_REAL;
      ascents[i] = NA_REAL;
      descents[i] = NA_REAL;
    } else {
      std::string str(Rf_translateCharUTF8(x[i]));
      FontMetric fm = cc.getExtents(str);

      widths[i] = fm.width;
      ascents[i] = fm.ascent;
      descents[i] = fm.descent;
    }
  }

  return Rcpp::DataFrame::create(
    _["width"] = widths,
    _["ascent"] = ascents,
    _["descent"] = descents,
    _["stringsAsFactors"] = false
  );
}
