#include <Rcpp.h>
#include <systemfonts.h>
#include <algorithm>
#include <cstdint>
#include <numeric>
#include <unordered_map>
#include <vector>

using namespace Rcpp;

namespace {

struct GlyphMetric {
  double width;
  double ascent;
  double descent;
  int error;
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

GlyphMetric measure_glyph(uint32_t code, const char* path, int index,
                          double size, double res) {
  GlyphMetric m = {0, 0, 0, 0};
  m.error = glyph_metrics(code, path, index, size, res,
                          &m.ascent, &m.descent, &m.width);
  if (m.error != 0) {
    // one retry: a previous failure can leave the systemfonts cache in a
    // state where the next load fails
    m.error = glyph_metrics(code, path, index, size, res,
                            &m.ascent, &m.descent, &m.width);
  }
  if (m.error != 0) {
    m.width = m.ascent = m.descent = 0;
  }
  return m;
}

} // namespace

// Measure strings from glyph metrics given by the systemfonts C API (no
// Cairo). `font` gives, for each string, a 1-based row in `path`/`index`.
// Width is the sum of glyph advances (no kerning); ascent and descent are
// those of the union of the glyph ink boxes. Values are in pixels at `size`
// points and `res` dpi. `failed` is TRUE when the font could not be read.
// NA strings give NA; invalid UTF-8 is measured as an empty string.
// [[Rcpp::export]]
DataFrame glyph_strings_(CharacterVector x,
                         IntegerVector font,
                         CharacterVector path,
                         IntegerVector index,
                         double size,
                         double res) {
  int n = x.size();
  NumericVector width(n);
  NumericVector ascent(n);
  NumericVector descent(n);
  LogicalVector failed(n);

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
  bool current_failed = false;
  const char* current_path = NULL;
  int current_index = 0;

  for (int k = 0; k < n; ++k) {
    int i = order[k];
    if (x[i] == NA_STRING) {
      width[i] = ascent[i] = descent[i] = NA_REAL;
      continue;
    }
    if (font[i] != current_font) {
      current_font = font[i];
      current_failed = false;
      cache.clear();
      std::fill(bmp_known.begin(), bmp_known.end(), 0);
      current_path = CHAR(path[current_font - 1]);
      current_index = index[current_font - 1];
    }
    if (current_failed) {
      failed[i] = true;
      continue;
    }
    if (!decode_utf8(Rf_translateCharUTF8(x[i]), codes)) {
      continue;
    }

    double w = 0, a = 0, d = 0;
    bool inked = false;
    bool string_failed = false;
    for (uint32_t code : codes) {
      const GlyphMetric* mp;
      if (code < bmp_size) {
        if (!bmp_known[code]) {
          bmp[code] = measure_glyph(code, current_path, current_index,
                                    size, res);
          bmp_known[code] = 1;
        }
        mp = &bmp[code];
      } else {
        std::unordered_map<uint32_t, GlyphMetric>::iterator it =
          cache.find(code);
        if (it == cache.end()) {
          it = cache.emplace(code, measure_glyph(code, current_path,
                                                 current_index, size,
                                                 res)).first;
        }
        mp = &it->second;
      }
      const GlyphMetric& m = *mp;
      if (m.error != 0) {
        string_failed = true;
        break;
      }
      w += m.width;
      // glyphs without ink (spaces) do not contribute to the ink box
      if (m.ascent + m.descent > 0) {
        if (!inked) {
          a = m.ascent;
          d = m.descent;
          inked = true;
        } else {
          a = std::max(a, m.ascent);
          d = std::max(d, m.descent);
        }
      }
    }
    if (string_failed) {
      current_failed = true;
      failed[i] = true;
      continue;
    }
    width[i] = w;
    ascent[i] = a;
    descent[i] = d;
  }

  return DataFrame::create(
    _["width"] = width,
    _["ascent"] = ascent,
    _["descent"] = descent,
    _["failed"] = failed
  );
}
