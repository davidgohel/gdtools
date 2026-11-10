#ifndef GDTOOLS_KERNING_H
#define GDTOOLS_KERNING_H

#include <ft2build.h>
#include FT_FREETYPE_H
#include <cstddef>
#include <cstdint>
#include <unordered_map>
#include <vector>

// Kerning read from the tables of a font file, without shaping: the
// adjustment between two consecutive glyphs. Written from the OpenType
// specification ('GPOS', 'kern') and the Apple TrueType Reference Manual
// ('kern' version 1.0, 'kerx').
//
// A single table is used: 'kerx' when the font has one, otherwise 'GPOS'
// when it has a 'kern' feature, otherwise the 'kern' table.
//
// Supported: 'GPOS' single and pair adjustments of the 'kern' feature
// (lookup types 1 and 2, all formats, also through extension lookups), 'kern'
// tables of OpenType (format 0) and Apple (formats 0, 2 and 3), 'kerx' format
// 0. Not supported: contextual kerning,
// substitutions (ligatures), mark positioning.

class FontKerning {
public:
  explicit FontKerning(FT_Face face);

  // TRUE when the font has no kerning that can be applied.
  bool empty() const { return source_ == NONE; }

  // Sum of the adjustments of the glyphs of a string, in font units.
  // `script` is an OpenType script tag (see guess_script()), 0 if unknown.
  double adjust(const std::vector<uint32_t>& glyphs, uint32_t script);

private:
  enum Source { NONE, GPOS, TABLE };

  // A subtable of a 'kern' or 'kerx' table.
  struct TableSub {
    int kind;         // PAIRS, APPLE_CLASS or APPLE_ARRAY
    size_t offset;    // start of the data, see table_value()
    size_t n_pairs;   // for PAIRS
    bool override_;   // replaces the accumulated value
    bool kerx;        // the subtable belongs to 'kerx'
  };
  enum { PAIRS, APPLE_CLASS, APPLE_ARRAY };

  struct PairResult {
    bool applies;
    int value;
    bool skip_second;
  };

  Source source_;
  std::vector<uint8_t> gpos_;
  std::vector<uint8_t> table_; // 'kern' or 'kerx'
  std::vector<TableSub> subs_;

  // 'GPOS': adjustment subtables (offsets in gpos_) of each lookup, and
  // lookups of the 'kern' feature by script tag.
  struct Lookup {
    uint16_t type; // 1 (single) or 2 (pair); 0 when not supported
    std::vector<size_t> subtables;
  };
  std::unordered_map<uint16_t, Lookup> lookups_;
  std::unordered_map<uint32_t, std::vector<uint16_t> > script_lookups_;

  void read_kern_table();
  void read_kerx_table();
  const std::vector<uint16_t>& lookups_for(uint32_t script);
  const Lookup& lookup_of(uint16_t index);
  PairResult pair_pos(size_t subtable, uint32_t first, uint32_t second) const;
  bool single_pos(size_t subtable, uint32_t glyph, int& value) const;
  int table_value(uint32_t left, uint32_t right) const;
};

// OpenType script tag of a string: the script of the first character that
// belongs to a script. Only Latin, Greek and Cyrillic are recognized; 0
// otherwise.
uint32_t guess_script(const std::vector<uint32_t>& codes);

#endif
