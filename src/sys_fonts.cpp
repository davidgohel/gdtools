#include <Rcpp.h>
#include <fontconfig/fontconfig.h>
using namespace Rcpp;


//' @title List system fonts.
//'
//' @description List system fonts details into a data.frame containing columns foundry, family,
//' file, slant and weight.
//'
//' @examples
//' \donttest{
//' # The first run can be slow when font caches are missing
//' # as font files are then being scanned to build those font caches.
//' sys_fonts()
//' }
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

FcPattern* fcMakePattern(FcPattern* pattern, int bold, int italic) {
  int weight = bold ? FC_WEIGHT_BOLD : FC_WEIGHT_MEDIUM;
  int slant = italic ? FC_SLANT_ITALIC : FC_SLANT_ROMAN;
  FcPatternAddInteger(pattern, FC_WEIGHT, weight);
  FcPatternAddInteger(pattern, FC_SLANT, slant);

  FcDefaultSubstitute(pattern);
  FcConfigSubstitute(0, pattern, FcMatchPattern);

  return pattern;
}

FcPattern* fcFindMatch(const char* fontname, int bold, int italic) {
  FcPattern* pattern;
  if(!(pattern = FcNameParse((FcChar8 *) fontname)))
    Rcpp::stop("Fontconfig error: unable to parse font name: %s", fontname);
  pattern = fcMakePattern(pattern, bold, italic);

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

int fcFindFontIndex(const char* fontfile, int bold, int italic) {
  FcFontSet* set = FcFontSetCreate();
  if (!FcFileScan(set, NULL, NULL, NULL, (const FcChar8*) fontfile, FcFalse)) {
    FcFontSetDestroy(set);
    Rcpp::stop("Fontconfig error: unable to allocate font");
  }

  FcPattern* pattern = FcPatternCreate();
  pattern = fcMakePattern(pattern, bold, italic);

  FcResult result;
  FcPattern* match = FcFontSetMatch(NULL, &set, 1, pattern, &result);
  FcPatternDestroy(pattern);

  int index;
  result = FcPatternGetInteger(match, FC_INDEX, 0, &index);
  FcFontSetDestroy(set);
  FcPatternDestroy(match);

  if (match && result == FcResultMatch)
    return index;
  else
    return 0;
}

// [[Rcpp::export]]
std::string match_family_(std::string font = "sans",
                          bool bold = true, bool italic = true) {
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

// [[Rcpp::export]]
Rcpp::CharacterVector match_font_(std::string font = "sans",
                                  bool bold = false, bool italic = false) {
  if (!FcInit())
    Rcpp::stop("Fontconfig error: unable to initialize");
  FcPattern* match = fcFindMatch(font.c_str(), bold, italic);

  std::string file, attr_family, attr_fullname;
  int index, weight, slant = 0;
  FcChar8* buffer;
  if (match) {
    file = fcFindFontFile(match);
    if (FcPatternGetString(match, FC_FAMILY, 0, &buffer) == FcResultMatch)
      attr_family = (const char*) buffer;
    if (FcPatternGetString(match, FC_FULLNAME, 0, &buffer) == FcResultMatch)
      attr_fullname = (const char*) buffer;
    FcPatternGetInteger(match, FC_SLANT, 0, &slant);
    FcPatternGetInteger(match, FC_WEIGHT, 0, &weight);
    FcPatternGetInteger(match, FC_INDEX, 0, &index);
  }
  FcPatternDestroy(match);

  if (file.size()) {
    Rcpp::CharacterVector output(file);
    output.attr("font") = Rcpp::CharacterVector(attr_family);
    output.attr("fullname") = Rcpp::CharacterVector(attr_fullname);
    /* The following are the weight and slant from the ideal pattern,
       not the matched one. */
    // output.attr("weight") = Rcpp::wrap(weight);
    // output.attr("slant") = Rcpp::wrap(slant);
    output.attr("index") = Rcpp::wrap(index);
    return output;
  } else {
    Rcpp::stop("Fontconfig error: unable to match font pattern");
  }
}
