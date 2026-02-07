# Get font metrics for a string.

Get font metrics for a string.

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

  Character vector of strings to measure

- fontname:

  Font name

- fontsize:

  Font size

- bold, italic:

  Is text bold/italic?

- fontfile:

  Font file

## Value

A named numeric vector

## Examples

``` r
str_metrics("Hello World!")
#>      width     ascent    descent 
#> 74.1328125  9.1171875  0.1699219 
```
