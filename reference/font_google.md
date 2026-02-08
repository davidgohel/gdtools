# Google Font specification

Create a font specification for a Google Font, to be used with
[`font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.md).

## Usage

``` r
font_google(family, subset = c("latin", "latin-ext"))
```

## Arguments

- family:

  family name of a 'Google Fonts', for example, "Open Sans", "Roboto",
  "Fira Code" or "Fira Sans Condensed".

- subset:

  font subset, a character vector, it defaults to only "latin" and
  "latin-ext".

## Value

An object of class `font_spec`.

## See also

Other font set functions:
[`font_liberation()`](https://davidgohel.github.io/gdtools/reference/font_liberation.md),
[`font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.md),
[`font_set_auto()`](https://davidgohel.github.io/gdtools/reference/font_set_auto.md),
[`font_set_liberation()`](https://davidgohel.github.io/gdtools/reference/font_set_liberation.md)

## Examples

``` r
font_google("Roboto")
#> $family
#> [1] "Roboto"
#> 
#> $subset
#> [1] "latin"     "latin-ext"
#> 
#> $source
#> [1] "google"
#> 
#> attr(,"class")
#> [1] "font_spec"
```
