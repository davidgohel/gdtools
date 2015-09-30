#include "gdtools_types.h"
#include <Rcpp.h>
using namespace Rcpp;

FontMetric::FontMetric() {}

FontMetric::FontMetric(SEXP x_) {
  IntegerVector x(x_);
  if (x.size() != 4)
    stop("Invalid size");

  width = x[0];
  height = x[1];
  ascent = x[2];
  descent = x[3];
}

FontMetric::operator SEXP() const {
  return Rcpp::IntegerVector::create(width, height, ascent, descent);
}

