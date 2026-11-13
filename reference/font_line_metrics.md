# Line metrics of fonts

Vertical metrics of the lines of text written with a font, read from the
font file: the part of a line above its baseline (`ascent`), the part
below (`descent`) and their sum, the distance between the baselines of
two lines in single spacing (`line_height`). Multiply `line_height` by a
line spacing factor (1.5 for example) to get the distance between
baselines with this spacing.

The values follow the rule of the text metrics of Windows, applied by
'Microsoft Word' for single line spacing: `ascent` is the `usWinAscent`
of the 'OS/2' table plus the external leading, `descent` is its
`usWinDescent`; the external leading is the line gap of the 'hhea'
table, reduced by what `usWinAscent` and `usWinDescent` add to the
ascender and descender of 'hhea', and not negative. Fonts without these
values use the ascender, descender and line gap of 'hhea'.

These metrics depend on the font only, unlike the ascent and descent
returned by
[`strings_sizes()`](https://davidgohel.github.io/gdtools/reference/strings_sizes.md),
which are those of the ink of the glyphs of a string. Fonts are found as
with
[`strings_sizes()`](https://davidgohel.github.io/gdtools/reference/strings_sizes.md).

## Usage

``` r
font_line_metrics(
  fontname = "sans",
  fontsize = 10,
  bold = FALSE,
  italic = FALSE
)
```

## Arguments

- fontname:

  A character vector of font family names. This argument is vectorized,
  as `fontsize`, `bold` and `italic`: they are recycled to the length of
  the longest one.

- fontsize:

  A numeric vector of font sizes in points.

- bold, italic:

  Logical vectors, for the bold and italic faces.

## Value

A data.frame with columns `ascent`, `descent` and `line_height`, in
inches, one row per font.

## See also

[`strings_sizes()`](https://davidgohel.github.io/gdtools/reference/strings_sizes.md)

Other functions for font metrics:
[`m_str_extents()`](https://davidgohel.github.io/gdtools/reference/m_str_extents.md),
[`str_metrics()`](https://davidgohel.github.io/gdtools/reference/str_metrics.md),
[`strings_sizes()`](https://davidgohel.github.io/gdtools/reference/strings_sizes.md)

## Examples

``` r
font_line_metrics(c("sans", "serif"), fontsize = 12)
#>      ascent    descent line_height
#> 1 0.1547038 0.03930664   0.1940104
#> 2 0.1547038 0.03930664   0.1940104
# distance between baselines with a line spacing of 1.5, in points
font_line_metrics("sans", fontsize = 12)$line_height * 1.5 * 72
#> [1] 20.95312
```
