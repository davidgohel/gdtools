#include <Rcpp.h>
#include "kerning.h"
#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_ADVANCES_H
#include <algorithm>
#include <memory>
#include <cstdint>
#include <numeric>
#include <string>
#include <unordered_map>
#include <vector>

using namespace Rcpp;

namespace {

// Metrics of one glyph, in font units.
struct GlyphMetric {
  uint32_t gid;
  double advance;
  double top;    // yMax of the ink box
  double bottom; // -yMin of the ink box
  bool inked;
};

// Decode UTF-8 into code points. Returns false on invalid input.
bool decode_utf8(const char* s, std::vector<uint32_t>& out) {
  out.clear();
  const unsigned char* p = reinterpret_cast<const unsigned char*>(s);
  while (*p) {
    uint32_t c = *p;
    int extra;
    if (c < 0x80) {
      extra = 0;
    } else if ((c & 0xE0) == 0xC0) {
      c &= 0x1F;
      extra = 1;
    } else if ((c & 0xF0) == 0xE0) {
      c &= 0x0F;
      extra = 2;
    } else if ((c & 0xF8) == 0xF0) {
      c &= 0x07;
      extra = 3;
    } else {
      return false;
    }
    ++p;
    for (int k = 0; k < extra; ++k, ++p) {
      if ((*p & 0xC0) != 0x80) {
        return false;
      }
      c = (c << 6) | (*p & 0x3F);
    }
    out.push_back(c);
  }
  return true;
}

// Read the metrics stored in the font file, unscaled and unhinted: the
// advance from the 'hmtx' table, the ink box from the outline.
GlyphMetric read_glyph(FT_Face face, uint32_t code) {
  GlyphMetric m = {0, 0, 0, 0, false};
  FT_UInt gid = FT_Get_Char_Index(face, code); // 0 is .notdef
  m.gid = gid;

  FT_Fixed advance = 0;
  if (FT_Get_Advance(face, gid, FT_LOAD_NO_SCALE, &advance) == 0) {
    m.advance = (double) advance;
  }
  if (FT_Load_Glyph(face, gid, FT_LOAD_NO_SCALE) == 0) {
    const FT_Glyph_Metrics& gm = face->glyph->metrics;
    if (gm.height > 0) {
      m.top = (double) gm.horiBearingY;
      m.bottom = (double) (gm.height - gm.horiBearingY);
      m.inked = true;
    }
  }
  return m;
}

// Kerning tables, kept for the session: reading them costs more than
// measuring a short string. Keyed by file path and face index; the cache is
// emptied when it holds too many fonts.
std::unordered_map<std::string, std::shared_ptr<FontKerning> > kerning_cache;

std::shared_ptr<FontKerning> kerning_of(FT_Face face, const char* path,
                                        int index) {
  std::string key = std::string(path) + '\n' + std::to_string(index);
  std::unordered_map<std::string, std::shared_ptr<FontKerning> >::iterator
    it = kerning_cache.find(key);
  if (it != kerning_cache.end()) {
    return it->second;
  }
  if (kerning_cache.size() >= 64) {
    kerning_cache.clear();
  }
  std::shared_ptr<FontKerning> k(new FontKerning(face));
  kerning_cache[key] = k;
  return k;
}

} // namespace

// Measure strings from the metrics stored in font files, read with FreeType
// (no hinting, no scaling). `font` gives, for each string, a
// 1-based row in `path`/`index`. Width is the sum of glyph advances, plus
// the kerning between consecutive glyphs when `kerning` is TRUE (see
// kerning.h); ascent and descent are those of the union of the glyph ink
// boxes. Values are in em (divide by units per em done here): multiply by
// the font size to get points. `failed` is TRUE when the font file could not
// be opened. NA strings give NA; invalid UTF-8 is measured as an empty
// string.
// [[Rcpp::export]]
List glyph_strings_(CharacterVector x,
                         IntegerVector font,
                         CharacterVector path,
                         IntegerVector index,
                         bool kerning) {
  int n = x.size();
  NumericVector width(n);
  NumericVector ascent(n);
  NumericVector descent(n);
  LogicalVector failed(n);

  // strings are translated before FreeType is opened: the translation raises
  // an R error for some strings (encoding "bytes"), which would leave the
  // FreeType objects open. The memory of the translated strings is freed by R
  // at the end of the call.
  std::vector<const char*> utf8(n, NULL);
  for (int i = 0; i < n; ++i) {
    if (x[i] != NA_STRING) {
      utf8[i] = Rf_translateCharUTF8(x[i]);
    }
  }

  FT_Library library;
  if (FT_Init_FreeType(&library)) {
    Rcpp::stop("FreeType error: unable to initialize FreeType library object");
  }

  // process strings font by font
  std::vector<int> order(n);
  std::iota(order.begin(), order.end(), 0);
  std::stable_sort(order.begin(), order.end(),
                   [&font](int a, int b) { return font[a] < font[b]; });

  // glyph cache of the current font: small direct table for Latin
  // characters (U+0000 to U+024F), hash map above. The table is kept small:
  // it is allocated and cleared at each call.
  const uint32_t bmp_size = 0x250;
  std::vector<GlyphMetric> bmp(bmp_size);
  std::vector<char> bmp_known(bmp_size, 0);
  std::unordered_map<uint32_t, GlyphMetric> cache;
  std::vector<uint32_t> codes;
  std::vector<uint32_t> glyphs;
  std::shared_ptr<FontKerning> kern;

  int current_font = -1;
  FT_Face face = NULL;
  double units_per_em = 1;

  for (int k = 0; k < n; ++k) {
    int i = order[k];
    if (x[i] == NA_STRING) {
      width[i] = ascent[i] = descent[i] = NA_REAL;
      continue;
    }
    if (font[i] != current_font) {
      current_font = font[i];
      if (face != NULL) {
        FT_Done_Face(face);
        face = NULL;
      }
      cache.clear();
      std::fill(bmp_known.begin(), bmp_known.end(), 0);
      kern.reset();
      if (FT_New_Face(library, CHAR(path[current_font - 1]),
                      index[current_font - 1], &face) != 0) {
        face = NULL;
      } else {
        units_per_em = face->units_per_EM > 0 ? face->units_per_EM : 1;
        if (kerning) {
          kern = kerning_of(face, CHAR(path[current_font - 1]),
                            index[current_font - 1]);
          if (kern->empty()) kern.reset();
        }
      }
    }
    if (face == NULL) {
      failed[i] = true;
      continue;
    }
    if (!decode_utf8(utf8[i], codes)) {
      continue;
    }

    double w = 0, a = 0, d = 0;
    bool inked = false;
    glyphs.clear();
    for (uint32_t code : codes) {
      const GlyphMetric* mp;
      if (code < bmp_size) {
        if (!bmp_known[code]) {
          bmp[code] = read_glyph(face, code);
          bmp_known[code] = 1;
        }
        mp = &bmp[code];
      } else {
        std::unordered_map<uint32_t, GlyphMetric>::iterator it =
          cache.find(code);
        if (it == cache.end()) {
          it = cache.emplace(code, read_glyph(face, code)).first;
        }
        mp = &it->second;
      }
      const GlyphMetric& m = *mp;
      w += m.advance;
      if (kern) glyphs.push_back(m.gid);
      // glyphs without ink (spaces) do not contribute to the ink box
      if (m.inked) {
        if (!inked) {
          a = m.top;
          d = m.bottom;
          inked = true;
        } else {
          a = std::max(a, m.top);
          d = std::max(d, m.bottom);
        }
      }
    }
    if (kern) {
      w += kern->adjust(glyphs, guess_script(codes));
    }
    width[i] = w / units_per_em;
    ascent[i] = a / units_per_em;
    descent[i] = d / units_per_em;
  }

  if (face != NULL) {
    FT_Done_Face(face);
  }
  FT_Done_FreeType(library);

  // a list, not a DataFrame: DataFrame::create() calls R code and costs
  // more than measuring a few strings
  return List::create(
    _["width"] = width,
    _["ascent"] = ascent,
    _["descent"] = descent,
    _["failed"] = failed
  );
}
