# Automatic font set

Build a
[`font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.md)
by detecting the best available system fonts for each role (sans, serif,
mono, symbol).

For each role a list of well-known fonts is tried in order. When none is
found on the system, the corresponding Liberation font is used as a
guaranteed offline fallback.

|        |                                        |                  |
|--------|----------------------------------------|------------------|
| Role   | Candidates (in order)                  | Fallback         |
| sans   | Arial, Helvetica, DejaVu Sans          | Liberation Sans  |
| serif  | Times New Roman, Times, DejaVu Serif   | Liberation Serif |
| mono   | Courier New, Courier, DejaVu Sans Mono | Liberation Mono  |
| symbol | Symbol, Apple Symbols                  | Liberation Sans  |

## Usage

``` r
font_set_auto()
```

## Value

An object of class `font_set`.

## See also

[`font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.md),
[`font_set_liberation()`](https://davidgohel.github.io/gdtools/reference/font_set_liberation.md)

Other font set functions:
[`font_google()`](https://davidgohel.github.io/gdtools/reference/font_google.md),
[`font_liberation()`](https://davidgohel.github.io/gdtools/reference/font_liberation.md),
[`font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.md),
[`font_set_liberation()`](https://davidgohel.github.io/gdtools/reference/font_set_liberation.md)

## Examples

``` r
fonts <- font_set_auto()
fonts
#> Font set
#>   sans:    DejaVu Sans [system]
#>   serif:   DejaVu Serif [system]
#>   mono:    DejaVu Sans Mono [system]
#>   symbol:  Symbol [system]
#>   4 HTML dependencies
```
