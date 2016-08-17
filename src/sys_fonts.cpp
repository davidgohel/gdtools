#include <Rcpp.h>
#include <fontconfig/fontconfig.h>
using namespace Rcpp;


//' @title List system fonts.
//'
//' @description List system fonts details into a data.frame containing columns foundry, family,
//' file, slant and weight.
//'
//' @examples
//' sys_fonts()
//' @export
// [[Rcpp::export]]
Rcpp::DataFrame sys_fonts() {
  FcConfig *config;
  FcBool result;
  int i;

  result = FcInit();
  config = FcConfigGetCurrent();
  FcConfigSetRescanInterval(config, 0);

  // show the fonts (debugging)
  FcPattern *pat;
  pat = FcPatternCreate();
  FcObjectSet *os;
  os = FcObjectSetBuild (FC_FOUNDRY, FC_FAMILY, FC_FILE, FC_SLANT, FC_WEIGHT, (char *)NULL);
  FcFontSet *fs;
  fs = FcFontList(config, pat, os);

  CharacterVector fontfoundry(fs->nfont);
  CharacterVector fontfamily(fs->nfont);
  CharacterVector fontfile(fs->nfont);
  IntegerVector fontslant(fs->nfont);
  IntegerVector fontweight(fs->nfont);

  for (i=0; fs && i < fs->nfont; i++) {
    FcChar8 *file, *family, *foundry;
    int slant, weight;

    if (FcPatternGetString(fs->fonts[i], FC_FAMILY, 0, &family) == FcResultMatch) {
      fontfamily(i) = reinterpret_cast<char *>(family);
    }

    if (FcPatternGetString(fs->fonts[i], FC_FOUNDRY, 0, &foundry) == FcResultMatch) {
      fontfoundry(i) = reinterpret_cast<char *>(foundry);
    }

    if (FcPatternGetString(fs->fonts[i], FC_FILE, 0, &file) == FcResultMatch) {
      fontfile(i) = reinterpret_cast<char *>(file);
    }

    if (FcPatternGetInteger(fs->fonts[i], FC_SLANT, 0, &slant) == FcResultMatch) {
      fontslant(i) = slant;
    }

    if (FcPatternGetInteger(fs->fonts[i], FC_WEIGHT, 0, &weight) == FcResultMatch) {
      fontweight(i) = weight;
    }

  }
  if (fs) FcFontSetDestroy(fs);

  return DataFrame::create(
    _["foundry"] = fontfoundry,
    _["family"] = fontfamily,
    _["file"] = fontfile,
    _["slant"] = fontslant,
    _["weight"] = fontweight
  );
}




// [[Rcpp::export]]
String best_family_match(std::string font_family = "sans" ) {

  FcFontSet *font_set;
  FcPattern *font_pattern;
  FcResult font_result;
  FcPattern *font_candidate;

  if (!FcInit ()) {
    warning ("Font config initialization failed");
    return R_NilValue;
  }

  font_pattern = FcNameParse ((const FcChar8 *)font_family.c_str());

  if (!font_pattern){
    warning ("Unable to parse pattern string");
    return R_NilValue;
  }

  FcConfigSubstitute (0, font_pattern, FcMatchPattern);
  FcDefaultSubstitute (font_pattern);
  font_set = FcFontSetCreate ();

  font_candidate = FcFontMatch (0, font_pattern, &font_result);
  if (font_candidate)
    FcFontSetAdd (font_set, font_candidate);

  FcPatternDestroy (font_pattern);


  if (font_set && font_set->fonts && font_set->fonts[0]) {
    FcChar8	*family;
    if (FcPatternGetString (font_set->fonts[0], FC_FAMILY, 0, &family) == FcResultMatch){
      return String(reinterpret_cast<char *>(family));
    }
    FcFontSetDestroy (font_set);
  }
  return NA_STRING;
}
