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
