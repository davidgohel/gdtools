# Compute strings sizes

Determines widths, ascent and descent in inches. Font lookup is
performed by 'systemfonts' (so any font registered via
[`systemfonts::register_font()`](https://systemfonts.r-lib.org/reference/register_font.html),
[`register_gfont()`](https://davidgohel.github.io/gdtools/reference/register_gfont.md),
or
[`font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.md)
is found), then Cairo computes the actual metrics. The results are
accurate for devices whose rendering finds the same font – this is
guaranteed for 'systemfonts'-based devices (ragg, svglite, ggiraph) and
true for Cairo devices
([`cairo_pdf()`](https://rdrr.io/r/grDevices/cairo.html), ...) when the
font is also installed at the system level. For devices with their own
font engine ([`pdf()`](https://rdrr.io/r/grDevices/pdf.html),
[`png()`](https://rdrr.io/r/grDevices/png.html), ...) the metrics may
not match the rendering.

## Usage

``` r
strings_sizes(
  x,
  fontname = "sans",
  fontsize = 10,
  bold = FALSE,
  italic = FALSE
)
```

## Arguments

- x:

  A character vector of strings to measure. All arguments are vectorized
  and recycled to match the length of `x`.

- fontname:

  A character vector specifying the font family name (e.g., "sans",
  "serif", "mono"). Default is "sans". This argument is vectorized.

- fontsize:

  A numeric vector specifying the font size in points. Default is 10.
  This argument is vectorized.

- bold:

  A logical vector indicating whether the text should be bold. Default
  is FALSE. This argument is vectorized.

- italic:

  A logical vector indicating whether the text should be italic. Default
  is FALSE. This argument is vectorized.

## See also

Other functions for font metrics:
[`m_str_extents()`](https://davidgohel.github.io/gdtools/reference/m_str_extents.md),
[`str_metrics()`](https://davidgohel.github.io/gdtools/reference/str_metrics.md)

## Examples

``` r
strings_sizes(letters)
#>         width     ascent     descent
#> 1  0.08511013 0.07778592 0.001966688
#> 2  0.08816189 0.10552300 0.001966688
#> 3  0.07636176 0.07778592 0.001966688
#> 4  0.08816189 0.10552300 0.001966688
#> 5  0.08544922 0.07778592 0.001966688
#> 6  0.04889594 0.10552300 0.000000000
#> 7  0.08816189 0.07778592 0.028889974
#> 8  0.08802626 0.10552300 0.000000000
#> 9  0.03858778 0.10552300 0.000000000
#> 10 0.03858778 0.10552300 0.028889974
#> 11 0.08043077 0.10552300 0.000000000
#> 12 0.03858778 0.10552300 0.000000000
#> 13 0.13529460 0.07778592 0.000000000
#> 14 0.08802626 0.07778592 0.000000000
#> 15 0.08497450 0.07778592 0.001966688
#> 16 0.08816189 0.07778592 0.028889974
#> 17 0.08816189 0.07778592 0.028889974
#> 18 0.05710178 0.07778592 0.000000000
#> 19 0.07236057 0.07778592 0.001966688
#> 20 0.05445692 0.09752062 0.000000000
#> 21 0.08802626 0.07778592 0.001966688
#> 22 0.08219401 0.07595486 0.000000000
#> 23 0.11359321 0.07595486 0.000000000
#> 24 0.08219401 0.07595486 0.000000000
#> 25 0.08219401 0.07595486 0.028889974
#> 26 0.07290310 0.07595486 0.000000000
strings_sizes("Hello World!", bold = TRUE, italic = FALSE,
  fontname = "sans", fontsize = 12)
#>      width    ascent     descent
#> 1 1.172282 0.1266276 0.002360026
```
