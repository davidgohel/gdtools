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


// [[Rcpp::export]]
XPtrFontFileContext fontfile_context_create(CharacterVector fontfiles) {
  return XPtrFontFileContext(new FontFileContext(fontfiles));
}

// [[Rcpp::export]]
bool fontfile_context_set_font(XPtrFontFileContext cc, double fontsize, bool bold, bool italic, std::string fallback) {
  cc->setFont(fontsize, bold, italic);
  cc->setFallBack(fallback);
  return true;
}

// [[Rcpp::export]]
FontMetric fontfile_context_extents(XPtrFontFileContext cc, std::string x) {
  return cc->getExtents(x);
}



// [[Rcpp::export]]
XPtrFamiliesContext font_context_create(std::string fontname_,
                                        CharacterVector sans_files,
                                        CharacterVector serif_files,
                                        CharacterVector mono_files) {
  return XPtrFamiliesContext(new FamiliesContext(fontname_, sans_files, serif_files, mono_files));
}

// [[Rcpp::export]]
bool font_context_set_font(XPtrFamiliesContext cc,
                           std::string family,
                           double fontsize, bool bold, bool italic) {
  cc->setFont(family, fontsize, bold, italic);
  return true;
}


// [[Rcpp::export]]
FontMetric font_context_extents(XPtrFamiliesContext cc, std::string x) {
  return cc->getExtents(x);
}

// [[Rcpp::export]]
std::string font_context_fontname(XPtrFamiliesContext cc) {
  return cc->getFontname();
}

