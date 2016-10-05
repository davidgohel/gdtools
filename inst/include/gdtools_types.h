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
using namespace Rcpp;

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
               bool bold = false, bool italic = false,
               std::string fontfile = "");

  FontMetric getExtents(std::string x);
};

typedef Rcpp::XPtr<CairoContext> XPtrCairoContext;

// FontFileContext
class FontFileContext {
  struct FontFileContext_;
  FontFileContext_* cairo_;

public:
  FontFileContext(CharacterVector fontfile);
  ~FontFileContext();

  void setFont(double fontsize = 12, bool bold = false, bool italic = false);
  void setFallBack(std::string fallback = "M");

  FontMetric getExtents(std::string x);
};


typedef Rcpp::XPtr<FontFileContext> XPtrFontFileContext;


// FamiliesContext
class FamiliesContext {
  struct FamiliesContext_;
  FamiliesContext_* families_;

public:
  FamiliesContext(std::string fontname,
                  CharacterVector sans_files,
                  CharacterVector serif_files,
                  CharacterVector mono_files);
  ~FamiliesContext();

  void setFont(std::string family,
               double fontsize = 12, bool bold = false, bool italic = false);
  void setFallBack(std::string fallback = "M");
  FontMetric getExtents(std::string x);
  std::string getFontname();
};


typedef Rcpp::XPtr<FamiliesContext> XPtrFamiliesContext;

#endif
