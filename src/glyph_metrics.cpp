#include <Rcpp.h>
#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_ADVANCES_H
#include <algorithm>
#include <cstdint>
#include <numeric>
#include <unordered_map>
#include <vector>

using namespace Rcpp;

namespace {

// Metrics of one glyph, in font units.
struct GlyphMetric {
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
// advance from the 'hmtx' table (as HarfBuzz), the ink box from the outline.
GlyphMetric read_glyph(FT_Face face, uint32_t code) {
  GlyphMetric m = {0, 0, 0, false};
  FT_UInt gid = FT_Get_Char_Index(face, code); // 0 is .notdef

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

} // namespace

// Measure strings from the metrics stored in font files, read with FreeType
// (no Cairo, no hinting, no scaling). `font` gives, for each string, a
// 1-based row in `path`/`index`. Width is the sum of glyph advances (no
// kerning); ascent and descent are those of the union of the glyph ink
// boxes. Values are in em (divide by units per em done here): multiply by
// the font size to get points. `failed` is TRUE when the font file could not
// be opened. NA strings give NA; invalid UTF-8 is measured as an empty
// string.
// [[Rcpp::export]]
DataFrame glyph_strings_(CharacterVector x,
                         IntegerVector font,
                         CharacterVector path,
                         IntegerVector index) {
  int n = x.size();
  NumericVector width(n);
  NumericVector ascent(n);
  NumericVector descent(n);
  LogicalVector failed(n);

  FT_Library library;
  if (FT_Init_FreeType(&library)) {
    Rcpp::stop("FreeType error: unable to initialize FreeType library object");
  }

  // process strings font by font
  std::vector<int> order(n);
  std::iota(order.begin(), order.end(), 0);
  std::stable_sort(order.begin(), order.end(),
                   [&font](int a, int b) { return font[a] < font[b]; });

  // glyph cache of the current font: direct table for the Basic
  // Multilingual Plane, hash map above
  const uint32_t bmp_size = 0x10000;
  std::vector<GlyphMetric> bmp(bmp_size);
  std::vector<char> bmp_known(bmp_size, 0);
  std::unordered_map<uint32_t, GlyphMetric> cache;
  std::vector<uint32_t> codes;

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
      if (FT_New_Face(library, CHAR(path[current_font - 1]),
                      index[current_font - 1], &face) != 0) {
        face = NULL;
      } else {
        units_per_em = face->units_per_EM > 0 ? face->units_per_EM : 1;
      }
    }
    if (face == NULL) {
      failed[i] = true;
      continue;
    }
    if (!decode_utf8(Rf_translateCharUTF8(x[i]), codes)) {
      continue;
    }

    double w = 0, a = 0, d = 0;
    bool inked = false;
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
    width[i] = w / units_per_em;
    ascent[i] = a / units_per_em;
    descent[i] = d / units_per_em;
  }

  if (face != NULL) {
    FT_Done_Face(face);
  }
  FT_Done_FreeType(library);

  return DataFrame::create(
    _["width"] = width,
    _["ascent"] = ascent,
    _["descent"] = descent,
    _["failed"] = failed
  );
}
