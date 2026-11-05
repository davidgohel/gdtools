# Find best family match with systemfonts (deprecated)

`match_family()` returns the best font family match. It is deprecated
and will be removed in a future release, use
[`systemfonts::match_fonts()`](https://systemfonts.r-lib.org/reference/match_fonts.html)
instead.

## Usage

``` r
match_family(font = "sans", bold = TRUE, italic = TRUE)
```

## Arguments

- font:

  family or face to match.

- bold:

  Whether to match a font featuring a bold face.

- italic:

  Whether to match a font featuring an italic face.

## Examples

``` r
suppressWarnings(match_family("sans"))
#> [1] "DejaVu Sans"
suppressWarnings(match_family("serif"))
#> [1] "DejaVu Serif"
```
