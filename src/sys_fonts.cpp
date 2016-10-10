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

FcPattern* findMatch(const char* fontname, int bold, int italic) {
  FcPattern* pattern;
  if(!(pattern = FcNameParse((FcChar8 *) fontname)))
    Rcpp::stop("Fontconfig error: unable to parse font name: %s", fontname);

  int weight = bold ? FC_WEIGHT_BOLD : FC_WEIGHT_MEDIUM;
  int slant = italic ? FC_SLANT_ITALIC : FC_SLANT_ROMAN;
  FcPatternAddInteger(pattern, FC_WEIGHT, weight);
  FcPatternAddInteger(pattern, FC_SLANT, slant);

  FcDefaultSubstitute(pattern);
  FcConfigSubstitute(0, pattern, FcMatchPattern);

  FcResult result;
  FcPattern* match = FcFontMatch(0, pattern, &result);
  FcPatternDestroy(pattern);

  if (match && result == FcResultMatch)
    return match;
  else
    Rcpp::stop("Fontconfig error: unable to match font pattern");
}

//' Find best family match with fontconfig
//'
//' This returns the best font family match for the pattern
//' constructed with \code{bold} and \code{italic}. The default
//' pattern is bold italic to make sure the matched font has enough
//' features to be used in R graphics (plain, bold, italic, bold
//' italic).
//'
//' @param family Family to match.
//' @param bold Wheter to match a font featuring a \code{bold} face.
//' @param italic Wheter to match a font featuring an \code{italic} face.
//'
//' @export
//' @examples
//' match_family("sans")
//' match_family("serif", bold = FALSE, italic = TRUE)
// [[Rcpp::export]]
String match_family(std::string family = "sans",
                    bool bold = 1, bool italic = 1) {
  FcPattern* match = findMatch(family.c_str(), bold, italic);

  std::string output;
  FcChar8* matched_family;
  if (match && FcPatternGetString(match, FC_FAMILY, 0, &matched_family) == FcResultMatch)
    output = (const char*) matched_family;
  FcPatternDestroy(match);

  if (output.size())
    return output;
  else
    Rcpp::stop("Fontconfig error: unable to match font pattern");
}
