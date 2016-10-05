#include "gdtools_types.h"
#include <Rcpp.h>

using namespace Rcpp;
// [[Rcpp::interfaces(r, cpp)]]

// [[Rcpp::export]]
XPtrCairoContext context_create() {
  return XPtrCairoContext(new CairoContext());
}

// [[Rcpp::export]]
bool context_set_font(XPtrCairoContext cc, std::string fontname,
                      double fontsize, bool bold, bool italic,
                      std::string fontfile = "") {
  cc->setFont(fontname, fontsize, bold, italic, fontfile);

  // should return void, but doesn't seem to be supported for cpp
  // interface
  return true;
}

// [[Rcpp::export]]
FontMetric context_extents(XPtrCairoContext cc, std::string x) {
  return cc->getExtents(x);
}

