#include "kerning.h"
#include FT_TRUETYPE_TABLES_H
#include FT_TRUETYPE_TAGS_H
#include <algorithm>

namespace {

// Big-endian reads with bounds checks: out of range reads give 0, so that a
// broken table cannot read outside its buffer.
struct Bytes {
  const uint8_t* p;
  size_t n;
  explicit Bytes(const std::vector<uint8_t>& v) : p(v.data()), n(v.size()) {}
  uint8_t u8(size_t o) const { return o < n ? p[o] : 0; }
  uint16_t u16(size_t o) const {
    return o + 2 <= n ? (uint16_t) ((p[o] << 8) | p[o + 1]) : 0;
  }
  int16_t i16(size_t o) const { return (int16_t) u16(o); }
  uint32_t u32(size_t o) const {
    return o + 4 <= n ? ((uint32_t) p[o] << 24) | ((uint32_t) p[o + 1] << 16) |
                          ((uint32_t) p[o + 2] << 8) | (uint32_t) p[o + 3]
                      : 0;
  }
};

const uint32_t TAG_KERN = FT_MAKE_TAG('k', 'e', 'r', 'n');
const uint32_t TAG_DFLT = FT_MAKE_TAG('D', 'F', 'L', 'T');
const uint32_t TAG_dflt = FT_MAKE_TAG('d', 'f', 'l', 't');
const uint32_t TAG_LATN = FT_MAKE_TAG('l', 'a', 't', 'n');
const uint32_t TAG_GREK = FT_MAKE_TAG('g', 'r', 'e', 'k');
const uint32_t TAG_CYRL = FT_MAKE_TAG('c', 'y', 'r', 'l');

bool load_table(FT_Face face, FT_ULong tag, std::vector<uint8_t>& buf) {
  FT_ULong len = 0;
  if (FT_Load_Sfnt_Table(face, tag, 0, NULL, &len) != 0 || len == 0) {
    return false;
  }
  buf.resize(len);
  if (FT_Load_Sfnt_Table(face, tag, 0, buf.data(), &len) != 0) {
    buf.clear();
    return false;
  }
  return true;
}

int popcount8(uint16_t x) {
  int n = 0;
  for (int k = 0; k < 8; ++k) {
    n += (x >> k) & 1;
  }
  return n;
}

// Size of a ValueRecord and its XAdvance (0 when absent).
size_t value_size(uint16_t format) { return 2 * popcount8(format); }
int x_advance(const Bytes& b, size_t o, uint16_t format) {
  if (!(format & 0x4)) {
    return 0;
  }
  return b.i16(o + 2 * popcount8(format & 0x3));
}

// Coverage index of a glyph, -1 when the glyph is not covered.
long coverage_index(const Bytes& b, size_t o, uint32_t g) {
  uint16_t format = b.u16(o);
  long n = b.u16(o + 2);
  long lo = 0, hi = n - 1;
  if (format == 1) {
    while (lo <= hi) {
      long mid = (lo + hi) / 2;
      uint16_t x = b.u16(o + 4 + 2 * mid);
      if (x < g) lo = mid + 1;
      else if (x > g) hi = mid - 1;
      else return mid;
    }
  } else if (format == 2) {
    while (lo <= hi) {
      long mid = (lo + hi) / 2;
      size_t r = o + 4 + 6 * mid;
      uint16_t start = b.u16(r), end = b.u16(r + 2);
      if (g < start) hi = mid - 1;
      else if (g > end) lo = mid + 1;
      else return (long) b.u16(r + 4) + (long) (g - start);
    }
  }
  return -1;
}

// Class of a glyph in a ClassDef table (0 when not listed).
uint16_t class_of(const Bytes& b, size_t o, uint32_t g) {
  uint16_t format = b.u16(o);
  if (format == 1) {
    uint32_t start = b.u16(o + 2), n = b.u16(o + 4);
    if (g >= start && g < start + n) {
      return b.u16(o + 6 + 2 * (g - start));
    }
  } else if (format == 2) {
    long lo = 0, hi = (long) b.u16(o + 2) - 1;
    while (lo <= hi) {
      long mid = (lo + hi) / 2;
      size_t r = o + 4 + 6 * mid;
      uint16_t start = b.u16(r), end = b.u16(r + 2);
      if (g < start) hi = mid - 1;
      else if (g > end) lo = mid + 1;
      else return b.u16(r + 4);
    }
  }
  return 0;
}

// Value of a pair in a sorted array of (left u16, right u16, value i16).
bool find_pair(const Bytes& b, size_t o, size_t n, uint32_t left,
               uint32_t right, int& value) {
  uint32_t key = (left << 16) | right;
  long lo = 0, hi = (long) n - 1;
  while (lo <= hi) {
    long mid = (lo + hi) / 2;
    size_t r = o + 6 * mid;
    uint32_t k = ((uint32_t) b.u16(r) << 16) | b.u16(r + 2);
    if (k < key) lo = mid + 1;
    else if (k > key) hi = mid - 1;
    else {
      value = b.i16(r + 4);
      return true;
    }
  }
  return false;
}

// Number of 6-byte records that fit in the buffer from `o`.
size_t fit_records(const Bytes& b, size_t o, size_t n) {
  if (o >= b.n) return 0;
  return std::min(n, (b.n - o) / 6);
}

} // namespace

FontKerning::FontKerning(FT_Face face) : source_(NONE) {
  if (!FT_IS_SFNT(face)) {
    return;
  }
  if (load_table(face, FT_MAKE_TAG('k', 'e', 'r', 'x'), table_)) {
    read_kerx_table();
    // a font with 'kerx' is kerned by 'kerx' only, even without horizontal
    // subtable
    source_ = subs_.empty() ? NONE : TABLE;
    return;
  }
  if (load_table(face, TTAG_GPOS, gpos_)) {
    Bytes b(gpos_);
    size_t features = b.u16(6);
    uint16_t n = b.u16(features);
    for (uint16_t i = 0; i < n; ++i) {
      if (b.u32(features + 2 + 6 * i) == TAG_KERN) {
        source_ = GPOS;
        return;
      }
    }
    gpos_.clear();
  }
  if (load_table(face, TAG_KERN, table_)) {
    read_kern_table();
    source_ = subs_.empty() ? NONE : TABLE;
  }
}

void FontKerning::read_kern_table() {
  Bytes b(table_);
  if (b.u16(0) == 0) {
    // OpenType: version u16, nTables u16, subtables with a 6-byte header
    uint16_t n = b.u16(2);
    size_t p = 4;
    for (uint16_t s = 0; s < n && p < b.n; ++s) {
      uint16_t length = b.u16(p + 2), coverage = b.u16(p + 4);
      bool horizontal = coverage & 0x1, cross = coverage & 0x4;
      if (horizontal && !cross && (coverage >> 8) == 0) {
        TableSub sub = {PAIRS, p + 14, 0, (coverage & 0x8) != 0, false};
        sub.n_pairs = fit_records(b, sub.offset, b.u16(p + 6));
        subs_.push_back(sub);
      }
      // the 16-bit length overflows for large subtables: only trusted when
      // it is not shorter than the pairs it holds
      size_t needed = 14 + 6 * (size_t) b.u16(p + 6);
      p += std::max((size_t) length, needed);
    }
  } else if (b.u32(0) == 0x00010000) {
    // Apple: version u32, nTables u32, subtables with an 8-byte header
    uint32_t n = b.u32(4);
    size_t p = 8;
    for (uint32_t s = 0; s < n && p < b.n; ++s) {
      uint32_t length = b.u32(p);
      uint16_t coverage = b.u16(p + 4);
      // vertical, cross-stream and variation subtables are skipped
      if ((coverage & 0xE000) == 0) {
        int format = coverage & 0xFF;
        if (format == 0) {
          TableSub sub = {PAIRS, p + 16, 0, false, false};
          sub.n_pairs = fit_records(b, sub.offset, b.u16(p + 8));
          subs_.push_back(sub);
        } else if (format == 2) {
          TableSub sub = {APPLE_CLASS, p, 0, false, false};
          subs_.push_back(sub);
        } else if (format == 3) {
          TableSub sub = {APPLE_ARRAY, p + 8, 0, false, false};
          subs_.push_back(sub);
        }
      }
      if (length == 0) break;
      p += length;
    }
  }
}

void FontKerning::read_kerx_table() {
  // version u16, padding u16, nTables u32, subtables with a 12-byte header
  Bytes b(table_);
  uint32_t n = b.u32(4);
  size_t p = 8;
  for (uint32_t s = 0; s < n && p < b.n; ++s) {
    uint32_t length = b.u32(p), coverage = b.u32(p + 4);
    // vertical, cross-stream and variation subtables are skipped
    if ((coverage & 0xE0000000u) == 0 && (coverage & 0xFF) == 0) {
      TableSub sub = {PAIRS, p + 28, 0, false, true};
      sub.n_pairs = fit_records(b, sub.offset, b.u32(p + 12));
      subs_.push_back(sub);
    }
    if (length == 0) break;
    p += length;
  }
}

int FontKerning::table_value(uint32_t left, uint32_t right) const {
  Bytes b(table_);
  int total = 0;
  for (const TableSub& sub : subs_) {
    int v = 0;
    if (sub.kind == PAIRS) {
      // a subtable that does not hold the pair leaves the value unchanged,
      // even when it overrides
      if (!find_pair(b, sub.offset, sub.n_pairs, left, right, v)) continue;
    } else if (sub.kind == APPLE_CLASS) {
      // offsets from the start of the subtable; class values of the left
      // table are offsets of rows, those of the right table of columns
      size_t st = sub.offset;
      size_t lt = st + b.u16(st + 10), rt = st + b.u16(st + 12);
      uint32_t lf = b.u16(lt), ln = b.u16(lt + 2);
      uint32_t rf = b.u16(rt), rn = b.u16(rt + 2);
      if (left >= lf && left < lf + ln && right >= rf && right < rf + rn) {
        uint16_t lc = b.u16(lt + 4 + 2 * (left - lf));
        uint16_t rc = b.u16(rt + 4 + 2 * (right - rf));
        v = b.i16(st + lc + rc);
      }
    } else if (sub.kind == APPLE_ARRAY) {
      size_t o = sub.offset;
      uint32_t glyph_count = b.u16(o);
      uint32_t value_count = b.u8(o + 2), left_count = b.u8(o + 3),
               right_count = b.u8(o + 4);
      size_t values = o + 6;
      size_t left_class = values + 2 * value_count;
      size_t right_class = left_class + glyph_count;
      size_t index = right_class + glyph_count;
      if (left < glyph_count && right < glyph_count) {
        uint32_t lc = b.u8(left_class + left), rc = b.u8(right_class + right);
        if (lc < left_count && rc < right_count) {
          uint32_t k = b.u8(index + lc * right_count + rc);
          if (k < value_count) {
            v = b.i16(values + 2 * k);
          }
        }
      }
    }
    total = sub.override_ ? v : total + v;
  }
  return total;
}

const std::vector<uint16_t>& FontKerning::lookups_for(uint32_t script) {
  std::unordered_map<uint32_t, std::vector<uint16_t> >::iterator it =
    script_lookups_.find(script);
  if (it != script_lookups_.end()) {
    return it->second;
  }
  std::vector<uint16_t>& out = script_lookups_[script];
  Bytes b(gpos_);
  size_t scripts = b.u16(4), features = b.u16(6);

  // script of the text, then the default scripts
  uint32_t candidates[4] = {script, TAG_DFLT, TAG_dflt, TAG_LATN};
  uint16_t n_scripts = b.u16(scripts);
  size_t script_table = 0;
  for (int c = 0; c < 4 && script_table == 0; ++c) {
    if (candidates[c] == 0) continue;
    for (uint16_t i = 0; i < n_scripts; ++i) {
      size_t rec = scripts + 2 + 6 * i;
      if (b.u32(rec) == candidates[c]) {
        script_table = scripts + b.u16(rec + 4);
        break;
      }
    }
  }
  if (script_table == 0 || b.u16(script_table) == 0) {
    return out;
  }
  // default language system
  size_t lang_sys = script_table + b.u16(script_table);
  std::vector<uint16_t> feature_ids;
  uint16_t required = b.u16(lang_sys + 2);
  if (required != 0xFFFF) feature_ids.push_back(required);
  uint16_t n_features = b.u16(lang_sys + 4);
  for (uint16_t i = 0; i < n_features; ++i) {
    feature_ids.push_back(b.u16(lang_sys + 6 + 2 * i));
  }
  uint16_t n_all = b.u16(features);
  for (uint16_t f : feature_ids) {
    if (f >= n_all) continue;
    size_t rec = features + 2 + 6 * f;
    if (b.u32(rec) != TAG_KERN) continue;
    size_t feature = features + b.u16(rec + 4);
    uint16_t n_lookups = b.u16(feature + 2);
    for (uint16_t j = 0; j < n_lookups; ++j) {
      out.push_back(b.u16(feature + 4 + 2 * j));
    }
  }
  // lookups are applied in the order of the lookup list
  std::sort(out.begin(), out.end());
  out.erase(std::unique(out.begin(), out.end()), out.end());
  return out;
}

const FontKerning::Lookup& FontKerning::lookup_of(uint16_t index) {
  std::unordered_map<uint16_t, Lookup>::iterator it = lookups_.find(index);
  if (it != lookups_.end()) {
    return it->second;
  }
  Lookup& out = lookups_[index];
  out.type = 0;
  Bytes b(gpos_);
  size_t list = b.u16(8);
  if (index >= b.u16(list)) {
    return out;
  }
  size_t table = list + b.u16(list + 2 + 2 * index);
  uint16_t type = b.u16(table);
  uint16_t n = b.u16(table + 4);
  for (uint16_t s = 0; s < n; ++s) {
    size_t sub = table + b.u16(table + 6 + 2 * s);
    uint16_t sub_type = type;
    if (type == 9) {
      // extension: real type and 32-bit offset (same type for all subtables)
      sub_type = b.u16(sub + 2);
      sub = sub + b.u32(sub + 4);
    }
    if (sub_type == 1 || sub_type == 2) {
      out.type = sub_type;
      out.subtables.push_back(sub);
    }
  }
  return out;
}

bool FontKerning::single_pos(size_t st, uint32_t glyph, int& value) const {
  Bytes b(gpos_);
  uint16_t format = b.u16(st);
  uint16_t cov_offset = b.u16(st + 2);
  if (cov_offset == 0) return false;
  long cov = coverage_index(b, st + cov_offset, glyph);
  if (cov < 0) return false;
  uint16_t vf = b.u16(st + 4);
  if (format == 1) {
    value = x_advance(b, st + 6, vf);
    return true;
  }
  if (format == 2) {
    if (cov >= b.u16(st + 6)) return false;
    value = x_advance(b, st + 8 + value_size(vf) * cov, vf);
    return true;
  }
  return false;
}

FontKerning::PairResult FontKerning::pair_pos(size_t st, uint32_t first,
                                              uint32_t second) const {
  PairResult res = {false, 0, false};
  Bytes b(gpos_);
  uint16_t format = b.u16(st);
  uint16_t cov_offset = b.u16(st + 2);
  if (cov_offset == 0) return res;
  long cov = coverage_index(b, st + cov_offset, first);
  if (cov < 0) return res;
  uint16_t vf1 = b.u16(st + 4), vf2 = b.u16(st + 6);
  size_t s1 = value_size(vf1), s2 = value_size(vf2);

  if (format == 1) {
    if (cov >= b.u16(st + 8)) return res;
    size_t set = st + b.u16(st + 10 + 2 * cov);
    size_t record = 2 + s1 + s2;
    long lo = 0, hi = (long) b.u16(set) - 1;
    while (lo <= hi) {
      long mid = (lo + hi) / 2;
      size_t r = set + 2 + record * mid;
      uint16_t g = b.u16(r);
      if (g < second) lo = mid + 1;
      else if (g > second) hi = mid - 1;
      else {
        res.applies = true;
        res.value = x_advance(b, r + 2, vf1) + x_advance(b, r + 2 + s1, vf2);
        res.skip_second = vf2 != 0;
        return res;
      }
    }
  } else if (format == 2) {
    uint16_t cd1 = b.u16(st + 8), cd2 = b.u16(st + 10);
    uint16_t c1 = cd1 ? class_of(b, st + cd1, first) : 0;
    uint16_t c2 = cd2 ? class_of(b, st + cd2, second) : 0;
    uint16_t n1 = b.u16(st + 12), n2 = b.u16(st + 14);
    if (c1 >= n1 || c2 >= n2) return res;
    size_t r = st + 16 + ((size_t) c1 * n2 + c2) * (s1 + s2);
    // applies once the first glyph is covered, even with a zero value
    res.applies = true;
    res.value = x_advance(b, r, vf1) + x_advance(b, r + s1, vf2);
    res.skip_second = vf2 != 0;
  }
  return res;
}

double FontKerning::adjust(const std::vector<uint32_t>& glyphs,
                           uint32_t script) {
  size_t n = glyphs.size();
  // single adjustments also apply to a string of one glyph
  if (n == 0 || source_ == NONE) {
    return 0;
  }
  double total = 0;
  if (source_ == TABLE) {
    for (size_t i = 0; i + 1 < n; ++i) {
      if (glyphs[i] > 0xFFFF || glyphs[i + 1] > 0xFFFF) continue;
      total += table_value(glyphs[i], glyphs[i + 1]);
    }
    return total;
  }
  // 'GPOS': each lookup goes through the string; in a lookup, the first
  // subtable that applies to a glyph or a pair wins
  // references stay valid: elements of an unordered_map are not moved
  const std::vector<uint16_t>& lookups = lookups_for(script);
  for (uint16_t index : lookups) {
    const Lookup& lookup = lookup_of(index);
    const std::vector<size_t>& subtables = lookup.subtables;
    if (lookup.type == 1) {
      for (size_t i = 0; i < n; ++i) {
        for (size_t st : subtables) {
          int v = 0;
          if (single_pos(st, glyphs[i], v)) {
            total += v;
            break;
          }
        }
      }
      continue;
    }
    if (lookup.type != 2) continue;
    size_t i = 0;
    while (i + 1 < n) {
      size_t step = 1;
      for (size_t st : subtables) {
        PairResult r = pair_pos(st, glyphs[i], glyphs[i + 1]);
        if (r.applies) {
          total += r.value;
          if (r.skip_second) step = 2;
          break;
        }
      }
      i += step;
    }
  }
  return total;
}

uint32_t guess_script(const std::vector<uint32_t>& codes) {
  for (uint32_t c : codes) {
    if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == 0xAA ||
        c == 0xBA || (c >= 0xC0 && c <= 0x24F && c != 0xD7 && c != 0xF7) ||
        (c >= 0x1E00 && c <= 0x1EFF) || (c >= 0xFB00 && c <= 0xFB06)) {
      return TAG_LATN;
    }
    if ((c >= 0x370 && c <= 0x3FF && c != 0x374 && c != 0x37E &&
         c != 0x385 && c != 0x387) ||
        (c >= 0x1F00 && c <= 0x1FFF)) {
      return TAG_GREK;
    }
    if ((c >= 0x400 && c <= 0x52F) || (c >= 0x1C80 && c <= 0x1C8F) ||
        (c >= 0x2DE0 && c <= 0x2DFF) || (c >= 0xA640 && c <= 0xA69F)) {
      return TAG_CYRL;
    }
  }
  return 0;
}
