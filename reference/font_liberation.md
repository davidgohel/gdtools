# Liberation Font specification

Create a font specification for a Liberation font, to be used with
[`font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.md).

## Usage

``` r
font_liberation(variant = c("sans", "serif", "mono"))
```

## Arguments

- variant:

  one of `"sans"`, `"serif"`, or `"mono"`.

## Value

An object of class `font_spec`.

## See also

Other font set functions:
[`font_google()`](https://davidgohel.github.io/gdtools/reference/font_google.md),
[`font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.md),
[`font_set_auto()`](https://davidgohel.github.io/gdtools/reference/font_set_auto.md),
[`font_set_liberation()`](https://davidgohel.github.io/gdtools/reference/font_set_liberation.md)

## Examples

``` r
font_liberation("sans")
#> $family
#> [1] "Liberation Sans"
#> 
#> $variant
#> [1] "sans"
#> 
#> $source
#> [1] "liberation"
#> 
#> attr(,"class")
#> [1] "font_spec"
font_liberation("mono")
#> $family
#> [1] "Liberation Mono"
#> 
#> $variant
#> [1] "mono"
#> 
#> $source
#> [1] "liberation"
#> 
#> attr(,"class")
#> [1] "font_spec"
```
