# Test fonts for tests/testthat/test-kerning.R.
#
# Each font holds a few glyphs with chosen advances and a chosen kerning, so
# that the expected widths can be written by hand in the tests, in font
# units (1000 units per em). No text engine is involved.
#
# 'GPOS' and the 'kern' tables of format 0 are compiled by fontTools from a
# description: they are written by another implementation than the reader
# of gdtools. fontTools cannot compile 'kerx' and the formats 2 and 3 of the
# Apple 'kern' table: these are assembled byte by byte below, from the Apple
# TrueType Reference Manual.
#
# Run from the package root, with fontTools 4.68.0:
#
#   python3 -m venv /tmp/ftvenv
#   /tmp/ftvenv/bin/pip install fonttools==4.68.0
#   /tmp/ftvenv/bin/python data-src/kerning-fonts.py

import os
import struct

from fontTools.feaLib.builder import addOpenTypeFeaturesFromString
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib.tables import _k_e_r_n
from fontTools.ttLib.tables.DefaultTable import DefaultTable

OUT = "tests/testthat/fixtures/kerning"

# glyph ids are the positions in this list
GLYPHS = [".notdef", "space", "A", "V", "T", "o", "Y", "period", "Alpha", "De"]
GID = {g: i for i, g in enumerate(GLYPHS)}
CMAP = {
    0x20: "space", 0x41: "A", 0x56: "V", 0x54: "T", 0x6F: "o", 0x59: "Y",
    0x2E: "period", 0x391: "Alpha", 0x414: "De",
}
ADVANCES = {
    ".notdef": 500, "space": 250, "A": 600, "V": 500, "T": 550, "o": 450,
    "Y": 520, "period": 200, "Alpha": 610, "De": 630,
}


def base_font(name):
    fb = FontBuilder(1000, isTTF=True)
    fb.setupGlyphOrder(GLYPHS)
    fb.setupCharacterMap(CMAP)
    fb.setupGlyf({g: TTGlyphPen(None).glyph() for g in GLYPHS})
    fb.setupHorizontalMetrics({g: (ADVANCES[g], 0) for g in GLYPHS})
    fb.setupHorizontalHeader(ascent=800, descent=-200)
    fb.setupNameTable({"familyName": "gdtools kerning " + name, "styleName": "Regular"})
    fb.setupOS2()
    fb.setupPost()
    return fb


def save(fb, name):
    fb.save(os.path.join(OUT, name + ".ttf"))


def add_features(fb, fea):
    addOpenTypeFeaturesFromString(fb.font, fea)


def kern_table(version, subtables):
    """'kern' compiled by fontTools; subtables: (pairs, coverage) with pairs
    {(left, right): value}. Version 0 (OpenType) or 1.0 (Apple). coverage is
    the byte of flags: the low byte of the OpenType coverage field, the high
    byte of the Apple one."""
    table = _k_e_r_n.table__k_e_r_n()
    table.version = version
    table.kernTables = []
    for pairs, coverage in subtables:
        sub = _k_e_r_n.KernTable_format_0(apple=(version == 1.0))
        sub.version = 0
        sub.format = 0
        sub.coverage = coverage
        sub.tupleIndex = 0
        sub.kernTable = dict(pairs)
        table.kernTables.append(sub)
    return table


def raw_table(tag, data):
    table = DefaultTable(tag)
    table.data = data
    return table


def u16(*v):
    return struct.pack(">" + "H" * len(v), *v)


def i16(*v):
    return struct.pack(">" + "h" * len(v), *v)


def apple_kern(subtables):
    """Apple 'kern' table: version 1.0, then subtables given as
    (coverage, body) where body follows the 8-byte subtable header."""
    out = struct.pack(">II", 0x00010000, len(subtables))
    for coverage, body in subtables:
        out += struct.pack(">IHH", 8 + len(body), coverage, 0) + body
    return out


def kerx(subtables):
    """'kerx' version 2, subtables given as (coverage, body) where body
    follows the 12-byte subtable header."""
    out = struct.pack(">HHI", 2, 0, len(subtables))
    for coverage, body in subtables:
        out += struct.pack(">III", 12 + len(body), coverage, 0) + body
    return out


def kerx_pairs(pairs):
    """Body of a 'kerx' format 0 subtable."""
    items = sorted((GID[l], GID[r], v) for (l, r), v in pairs.items())
    body = struct.pack(">IIII", len(items), 0, 0, 0)
    for l, r, v in items:
        body += struct.pack(">HHh", l, r, v)
    return body


os.makedirs(OUT, exist_ok=True)

# GPOS pairs: a lookup with a glyph pair subtable (format 1) first, then a
# class pair subtable (format 2). The first subtable that applies wins.
fb = base_font("gpos-pairs")
add_features(fb, """
languagesystem DFLT dflt;
@L = [A Alpha];
@R = [V Y];
lookup pairs {
  pos A V -20;
  pos @L @R -70;
} pairs;
feature kern { lookup pairs; } kern;
""")
save(fb, "gpos-pairs")

# GPOS pair with a value for the second glyph: the second glyph is then not
# the first glyph of the next pair in the same lookup.
fb = base_font("gpos-second")
add_features(fb, """
languagesystem DFLT dflt;
lookup second {
  pos A <0 0 -30 0> V <0 0 -10 0>;
  pos V Y -40;
} second;
feature kern { lookup second; } kern;
""")
save(fb, "gpos-second")

# GPOS single adjustment (lookup type 1) and extension lookups (type 9).
fb = base_font("gpos-single")
add_features(fb, """
languagesystem DFLT dflt;
lookup space useExtension { pos space -50; } space;
lookup pairs useExtension { pos T o -60; } pairs;
feature kern { lookup space; lookup pairs; } kern;
""")
save(fb, "gpos-single")

# GPOS scripts: different lookups for DFLT, latn and grek.
fb = base_font("gpos-scripts")
add_features(fb, """
languagesystem DFLT dflt;
languagesystem latn dflt;
languagesystem grek dflt;
lookup k_dflt { pos A V -10; } k_dflt;
lookup k_latn { pos A V -80; } k_latn;
lookup k_grek { pos A V -30; } k_grek;
feature kern {
  script DFLT; language dflt; lookup k_dflt;
  script latn; language dflt; lookup k_latn;
  script grek; language dflt; lookup k_grek;
} kern;
""")
save(fb, "gpos-scripts")

# 'kern' table, OpenType format 0: two horizontal subtables, the second one
# overrides the value of the pairs it holds; a cross-stream subtable is
# ignored.
fb = base_font("kern-opentype")
fb.font["kern"] = kern_table(0, [
    ({("A", "V"): -45, ("T", "o"): -60}, 0x01),
    ({("A", "V"): -5}, 0x01 | 0x08),
    ({("A", "V"): -999}, 0x01 | 0x04),
])
save(fb, "kern-opentype")

# 'GPOS' without 'kern' feature: the 'kern' table is used.
fb = base_font("gpos-no-kern-feature")
add_features(fb, """
languagesystem DFLT dflt;
feature dist { pos A V -99; } dist;
""")
fb.font["kern"] = kern_table(0, [({("A", "V"): -45}, 0x01)])
save(fb, "gpos-no-kern-feature")

# 'GPOS' with 'kern' feature and 'kern' table: 'GPOS' only.
fb = base_font("gpos-and-kern")
add_features(fb, """
languagesystem DFLT dflt;
feature kern { pos A V -80; } kern;
""")
fb.font["kern"] = kern_table(0, [({("A", "V"): -45, ("T", "o"): -60}, 0x01)])
save(fb, "gpos-and-kern")

# Apple 'kern', format 0, compiled by fontTools; a vertical subtable is
# ignored (fontTools takes the high byte of the coverage: 0x80 is vertical).
fb = base_font("kern-apple-0")
fb.font["kern"] = kern_table(1.0, [
    ({("A", "V"): -45, ("T", "o"): -60}, 0x00),
    ({("A", "V"): -999}, 0x80),
])
save(fb, "kern-apple-0")

# Apple 'kern', format 2 (class table). Offsets from the subtable start:
# header 8, format 2 header 8, left class table at 16 (A, V, T), right class
# table at 26 (V, T, o, Y), array at 38: 3 rows of 3 values. Left class
# values are offsets of rows from the subtable start, right class values
# offsets in a row.
row_width = 6
array = 38
left = u16(GID["A"], 3) + u16(array + 1 * row_width, array, array + 2 * row_width)
right = u16(GID["V"], 4) + u16(2, 0, 4, 2)
values = i16(0, 0, 0) + i16(0, -70, 0) + i16(0, 0, -60)
body = u16(row_width, 16, 26, array) + left + right + values
fb = base_font("kern-apple-2")
fb.font["kern"] = raw_table("kern", apple_kern([(0x0002, body)]))
save(fb, "kern-apple-2")

# Apple 'kern', format 3 (class indices): kern values [0, -70, -60], left
# classes A -> 1, T -> 2, right classes V, Y -> 1, o -> 2.
n = len(GLYPHS)
left_class = [0] * n
right_class = [0] * n
left_class[GID["A"]] = 1
left_class[GID["T"]] = 2
right_class[GID["V"]] = 1
right_class[GID["Y"]] = 1
right_class[GID["o"]] = 2
kern_index = [0, 0, 0, 0, 1, 0, 0, 0, 2]
body = (struct.pack(">HBBBB", n, 3, 3, 3, 0) + i16(0, -70, -60) +
        bytes(left_class) + bytes(right_class) + bytes(kern_index))
fb = base_font("kern-apple-3")
fb.font["kern"] = raw_table("kern", apple_kern([(0x0003, body)]))
save(fb, "kern-apple-3")

# 'kerx' format 0 and 'GPOS' with 'kern' feature: 'kerx' only. A vertical
# subtable is ignored.
fb = base_font("kerx")
add_features(fb, """
languagesystem DFLT dflt;
feature kern { pos A V -80; } kern;
""")
fb.font["kerx"] = raw_table("kerx", kerx([
    (0x00000000, kerx_pairs({("A", "V"): -25, ("T", "o"): -35})),
    (0x80000000, kerx_pairs({("A", "V"): -999})),
]))
save(fb, "kerx")

# 'kerx' without horizontal subtable and 'GPOS' with 'kern' feature: a font
# with 'kerx' is kerned by 'kerx' only, so no kerning.
fb = base_font("kerx-vertical")
add_features(fb, """
languagesystem DFLT dflt;
feature kern { pos A V -80; } kern;
""")
fb.font["kerx"] = raw_table("kerx", kerx([
    (0x80000000, kerx_pairs({("A", "V"): -999})),
]))
save(fb, "kerx-vertical")

# Broken tables: truncated 'GPOS', 'kern' announcing more pairs than it
# holds. Measuring must not fail.
fb = base_font("broken-gpos")
add_features(fb, """
languagesystem DFLT dflt;
feature kern { pos A V -80; pos @X @Y -10; } kern;
""".replace("@X", "[T Y]").replace("@Y", "[o period]"))
gpos = fb.font["GPOS"].compile(fb.font)
fb.font["GPOS"] = raw_table("GPOS", gpos[: len(gpos) // 2])
save(fb, "broken-gpos")

fb = base_font("broken-kern")
pairs = struct.pack(">HHh", GID["A"], GID["V"], -45)
body = struct.pack(">HHHH", 5000, 0, 0, 0) + pairs
fb.font["kern"] = raw_table(
    "kern", struct.pack(">HH", 0, 1) + struct.pack(">HHH", 0, 6 + len(body), 0x0001) + body
)
save(fb, "broken-kern")
