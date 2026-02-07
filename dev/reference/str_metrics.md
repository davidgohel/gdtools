# Get font metrics for a string.

Compute the width, ascent and descent of a single string in points using
Cairo text measurement.

## Usage

``` r
str_metrics(
  x,
  fontname = "sans",
  fontsize = 12,
  bold = FALSE,
  italic = FALSE,
  fontfile = ""
)
```

## Arguments

- x:

  Character vector of strings to measure (only the first element is
  used).

- fontname:

  Font name.

- fontsize:

  Font size in points.

- bold, italic:

  Is text bold/italic?

- fontfile:

  Path to a font file. If empty, the font is resolved by name via
  `systemfonts`.

## Value

A named numeric vector with elements `width`, `ascent` and `descent`
(unit is points).

## Note

This function will be deprecated in a future release. Use
[`strings_sizes()`](https://davidgohel.github.io/gdtools/dev/reference/strings_sizes.md)
instead.

## See also

Other functions for font metrics:
[`m_str_extents()`](https://davidgohel.github.io/gdtools/dev/reference/m_str_extents.md),
[`strings_sizes()`](https://davidgohel.github.io/gdtools/dev/reference/strings_sizes.md)

## Examples

``` r
str_metrics("Hello World!")
#>      width     ascent    descent 
#> 74.1328125  9.1171875  0.1699219 
```
