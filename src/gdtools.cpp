#include "gdtools_types.h"
#include <Rcpp.h>

using namespace Rcpp;
// [[Rcpp::interfaces(r, cpp)]]

// [[Rcpp::export]]
XPtrCairoContext context_create() {
  return XPtrCairoContext(new CairoContext());
}

// [[Rcpp::export]]
void context_set_font(XPtrCairoContext cc, std::string fontname,
                      double fontsize, bool bold, bool italic) {
  cc->setFont(fontname, fontsize, bold, italic);
}

// [[Rcpp::export]]
FontMetric context_extents(XPtrCairoContext cc, std::string x) {
  return cc->extents(x);
}
