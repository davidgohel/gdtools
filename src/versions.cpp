#include <Rcpp.h>
#include <ft2build.h>
#include FT_FREETYPE_H

Rcpp::List version_make(int major, int minor, int patch) {
  Rcpp::IntegerVector version;
  Rcpp::CharacterVector s3_class;
  version = Rcpp::IntegerVector::create(major, minor, patch);
  s3_class = Rcpp::CharacterVector::create("package_version", "numeric_version");

  Rcpp::List output;
  output = Rcpp::List::create(version);
  output.attr("class") = s3_class;

  return output;
}

//' @title Version of the FreeType library
//'
//' @description Return the runtime version of the FreeType library
//' linked to the package, used to read font metrics.
//' @return An object of class \code{"numeric_version"}.
//' @examples
//' version_freetype()
//' @export
// [[Rcpp::export]]
Rcpp::List version_freetype() {
  FT_Library library;
  if (FT_Init_FreeType(&library))
    Rcpp::stop("FreeType error: unable to initialise library");

  int major, minor, patch = 0;
  FT_Library_Version(library, &major, &minor, &patch);
  FT_Done_FreeType(library);

  return version_make(major, minor, patch);
}
