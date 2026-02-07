# Check if font family exists.

Check if a font family exists in system fonts.

## Usage

``` r
font_family_exists(font_family = "sans")
```

## Arguments

- font_family:

  font family name (case sensitive)

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
```
