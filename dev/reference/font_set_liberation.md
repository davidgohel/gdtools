# Liberation font set

Shortcut to create a
[`font_set()`](https://davidgohel.github.io/gdtools/dev/reference/font_set.md)
with all four font roles using Liberation fonts (Sans, Serif, Mono) and
Liberation Sans as a fallback for symbols.

## Usage

``` r
font_set_liberation()
```

## Value

An object of class `font_set`.

## See also

[`font_set()`](https://davidgohel.github.io/gdtools/dev/reference/font_set.md),
[`font_set_auto()`](https://davidgohel.github.io/gdtools/dev/reference/font_set_auto.md)

Other font set functions:
[`font_google()`](https://davidgohel.github.io/gdtools/dev/reference/font_google.md),
[`font_liberation()`](https://davidgohel.github.io/gdtools/dev/reference/font_liberation.md),
[`font_set()`](https://davidgohel.github.io/gdtools/dev/reference/font_set.md),
[`font_set_auto()`](https://davidgohel.github.io/gdtools/dev/reference/font_set_auto.md)

## Examples

``` r
fonts <- font_set_liberation()
fonts
#> Font set
#>   sans:    Liberation Sans [liberation]
#>   serif:   Liberation Serif [liberation]
#>   mono:    Liberation Mono [liberation]
#>   symbol:  Liberation Sans [liberation]
#>   4 HTML dependencies
```
