# Compute string extents for a vector of string.

For each `x` element, determines the width and height of a bounding box
that's big enough to (just) enclose the provided text. Unit is pixel.

## Usage

``` r
m_str_extents(
  x,
  fontname = "sans",
  fontsize = 10,
  bold = FALSE,
  italic = FALSE,
  fontfile = NULL
)
```

## Arguments

- x:

  Character vector of strings to measure

- fontname:

  Font name. A vector of character to match with x.

- fontsize:

  Font size. A vector of numeric to match with x.

- bold, italic:

  Is text bold/italic?. A vector of logical to match with x.

- fontfile:

  Font file. A vector of character to match with x.

## Examples

``` r
# \donttest{
# The first run can be slow when font caches are missing
# as font files are then being scanned to build those font caches.
m_str_extents(letters, fontsize = 1:26)
#>            [,1]       [,2]
#>  [1,]  0.612793  0.5742188
#>  [2,]  1.269531  1.5478516
#>  [3,]  1.649414  1.7226562
#>  [4,]  2.539062  3.0957031
#>  [5,]  3.076172  2.8710938
#>  [6,]  2.112305  4.5585938
#>  [7,]  4.443359  5.3764648
#>  [8,]  5.070312  6.0781250
#>  [9,]  2.500488  6.8378906
#> [10,]  2.778320  9.6777344
#> [11,]  6.370117  8.3574219
#> [12,]  3.333984  9.1171875
#> [13,] 12.663574  7.2807617
#> [14,]  8.873047  7.8408203
#> [15,]  9.177246  8.6132812
#> [16,] 10.156250 12.2890625
#> [17,] 10.791016 13.0571289
#> [18,]  7.400391 10.0810547
#> [19,]  9.898926 10.9101562
#> [20,]  7.841797 14.0429688
#> [21,] 13.309570 12.0585938
#> [22,] 13.019531 12.0312500
#> [23,] 18.811035 12.5781250
#> [24,] 14.203125 13.1250000
#> [25,] 14.794922 18.8720703
#> [26,] 13.647461 14.2187500
m_str_extents(letters[1:3],
  bold = c(TRUE, FALSE, TRUE),
  italic = c(FALSE, TRUE, TRUE),
  fontname = c("sans", "sans", "sans") )
#>          [,1]     [,2]
#> [1,] 6.748047 5.742188
#> [2,] 6.347656 7.739258
#> [3,] 5.927734 5.742188
# }
```
