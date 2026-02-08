# Check if font family exists.

Check if a font family exists in available fonts.

## Usage

``` r
font_family_exists(font_family = "sans", system_only = FALSE)
```

## Arguments

- font_family:

  font family name (case sensitive)

- system_only:

  If `TRUE`, only look in system-installed fonts (as returned by
  [`systemfonts::system_fonts()`](https://systemfonts.r-lib.org/reference/system_fonts.html)).
  This is useful to verify that a font will be found by fontconfig,
  which is the font resolution mechanism used by Cairo devices at
  rendering time. When `FALSE` (the default), both system and registered
  fonts are considered.

## Value

A logical value

## Examples

``` r
font_family_exists("sans")
#> [1] TRUE
font_family_exists("Arial")
#> [1] FALSE
font_family_exists("Courier")
#> [1] FALSE
font_family_exists("Arial", system_only = TRUE)
#> [1] FALSE
```
