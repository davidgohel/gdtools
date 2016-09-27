#include "gdtools_types.h"
#include <Rcpp.h>
#include <cairo.h>
#include <cairo-pdf.h>
#include <cairo-ft.h>
#include <ft2build.h>
#include FT_FREETYPE_H

using namespace Rcpp;

struct FamiliesContext::FamiliesContext_ {
  std::string fontname;
  int selected_family;
  FontFileContext *sans_;
  FontFileContext *serif_;
  FontFileContext *mono_;
};

FamiliesContext::FamiliesContext(std::string fontname_,
  CharacterVector sans_files,
  CharacterVector serif_files,
  CharacterVector mono_files) {
    families_ = new FamiliesContext_();

    families_->fontname = fontname_;
    families_->sans_ = new FontFileContext(sans_files);
    families_->serif_ = new FontFileContext(serif_files);
    families_->mono_ = new FontFileContext(mono_files);
    families_->selected_family = 0;
}

FamiliesContext::~FamiliesContext() {
  delete(families_->sans_);
  delete(families_->serif_);
  delete(families_->mono_);
}

void FamiliesContext::setFont(std::string family, double fontsize, bool bold, bool italic) {
  if( family == "sans" || family == "" ){
      families_->selected_family = 0;
      families_->sans_->setFont(fontsize, bold, italic);
      families_->sans_->setFallBack("M");
    } else if( family == "serif" ){
      families_->selected_family = 1;
      families_->serif_->setFont(fontsize, bold, italic);
      families_->serif_->setFallBack("M");
  } else if( family == "mono" ){
      families_->selected_family = 2;
      families_->mono_->setFont(fontsize, bold, italic);
      families_->mono_->setFallBack("M");
  } else stop("unkown family");

}

FontMetric FamiliesContext::getExtents(std::string x) {
  if( families_->selected_family == 0 ){
    return families_->sans_->getExtents(x);
  } else if( families_->selected_family == 1 ){
    return families_->serif_->getExtents(x);
  } else {
    return families_->mono_->getExtents(x);
  }
}

std::string FamiliesContext::getFontname() {
  return families_->fontname;
}

