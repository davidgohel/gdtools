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

FcPattern* fcFindMatch(const char* fontname, int bold, int italic) {
  FcPattern* pattern;
  if(!(pattern = FcNameParse((FcChar8 *) fontname)))
    Rcpp::stop("Fontconfig error: unable to parse font name: %s", fontname);

  int weight = bold ? FC_WEIGHT_BOLD : FC_WEIGHT_MEDIUM;
  int slant = italic ? FC_SLANT_ITALIC : FC_SLANT_ROMAN;
  FcPatternAddInteger(pattern, FC_WEIGHT, weight);
  FcPatternAddInteger(pattern, FC_SLANT, slant);

  FcDefaultSubstitute(pattern);
  FcConfigSubstitute(0, pattern, FcMatchPattern);

  // Need to initialise result for fontconfig versions prior to 2.10
  // (e.g. old Linux distributions)
  FcResult result = FcResultMatch;
  FcPattern* match = FcFontMatch(0, pattern, &result);
  FcPatternDestroy(pattern);

  if (match && result == FcResultMatch)
    return match;
  else
    Rcpp::stop("Fontconfig error: unable to match font pattern");
}

std::string fcFindFontFile(FcPattern* match) {
  std::string output;
  FcChar8 *matched_file;
  if (match && FcPatternGetString(match, FC_FILE, 0, &matched_file) == FcResultMatch)
    output = (const char*) matched_file;
  return output;
}

//' Find best family match with fontconfig
//'
//' \code{match_family()} returns the best font family match for the
//' fontconfig pattern constructed from the \code{bold} and
//' \code{italic} arguments. The default pattern is bold italic to make
//' sure the matched font has enough features to be used in R graphics
//' (plain, bold, italic, bold italic). \code{match_font()} returns the
//' font file from the best family match, along with some metada in the
//' attributes.
//'
//' Fontconfig matching is controlled via the \code{fonts.conf}
//' file. Call \code{Sys.setenv(FC_DEBUG = 1024)} before calling
//' \code{match_family()} to make fontconfig reveal what configuration
//' file it is currently using (there can be several installations on
//' one system, especially on Macs).
//'
//' @param font family or face to match.
//' @param bold Wheter to match a font featuring a \code{bold} face.
//' @param italic Wheter to match a font featuring an \code{italic} face.
//'
//' @export
//' @examples
//' match_family("sans")
//' match_family("serif", bold = FALSE, italic = TRUE)
//'
//' match_font("Helvetica", bold = FALSE, italic = TRUE)
// [[Rcpp::export]]
std::string match_family(std::string font = "sans",
                         bool bold = 1, bool italic = 1) {
  if (!FcInit())
    Rcpp::stop("Fontconfig error: unable to initialize");
  FcPattern* match = fcFindMatch(font.c_str(), bold, italic);

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

//' @rdname match_family
//' @export
// [[Rcpp::export]]
Rcpp::CharacterVector match_font(std::string font = "sans",
                                 bool bold = 0, bool italic = 0) {
  if (!FcInit())
    Rcpp::stop("Fontconfig error: unable to initialize");
  FcPattern* match = fcFindMatch(font.c_str(), bold, italic);

  std::string file, attr_family, attr_fullname;
  int weight, slant = 0;
  FcChar8* buffer;
  if (match) {
    file = fcFindFontFile(match);
    if (FcPatternGetString(match, FC_FAMILY, 0, &buffer) == FcResultMatch)
      attr_family = (const char*) buffer;
    if (FcPatternGetString(match, FC_FULLNAME, 0, &buffer) == FcResultMatch)
      attr_fullname = (const char*) buffer;
    FcPatternGetInteger(match, FC_SLANT, 0, &slant);
    FcPatternGetInteger(match, FC_WEIGHT, 0, &weight);
  }
  FcPatternDestroy(match);

  // Reloading pattern to get actual weight and slant
  FcPattern* pat = 0;

  if (file.size()) {
    Rcpp::CharacterVector output(file);
    output.attr("font") = Rcpp::CharacterVector(attr_family);
    output.attr("fullname") = Rcpp::CharacterVector(attr_fullname);
    output.attr("weight") = Rcpp::wrap(weight);
    output.attr("slant") = Rcpp::wrap(slant);
    return output;
  } else {
    Rcpp::stop("Fontconfig error: unable to match font pattern");
  }
}
