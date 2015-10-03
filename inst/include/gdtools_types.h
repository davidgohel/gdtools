#ifndef __GDTOOLS_TYPES__
#define __GDTOOLS_TYPES__

#include <RcppCommon.h>

class FontMetric {
public:
  double height, width, ascent, descent;

  FontMetric();
  FontMetric(SEXP);
  operator SEXP() const ;
};

#include <Rcpp.h>

inline FontMetric::FontMetric() {}

inline FontMetric::FontMetric(SEXP x_) {
  Rcpp::NumericVector x(x_);
  if (x.size() != 4)
    Rcpp::stop("Invalid size");

  width = x[0];
  height = x[1];
  ascent = x[2];
  descent = x[3];
}

inline FontMetric::operator SEXP() const {
  return Rcpp::NumericVector::create(width, height, ascent, descent);
}

class CairoContext {
  struct CairoContext_;
  CairoContext_* cairo_;

public:
  CairoContext();
  ~CairoContext();

  void setFont(std::string fontname = "sans", double fontsize = 12,
    bool bold = false, bool italic = false);

  FontMetric getExtents(std::string x);
};

typedef Rcpp::XPtr<CairoContext> XPtrCairoContext;

#endif
