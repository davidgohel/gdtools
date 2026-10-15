# Compute string extents for a vector of strings.

For each `x` element, determines the width and height of a bounding box
that's big enough to (just) enclose the provided text. Unit is points.

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

  Font name. A character vector, recycled to match `x`.

- fontsize:

  Font size. A numeric vector, recycled to match `x`.

- bold, italic:

  Is text bold/italic? A logical vector, recycled to match `x`.

- fontfile:

  Font file. A character vector, recycled to match `x`.

## Note

This function is deprecated and will be removed in a future release. Use
[`strings_sizes()`](https://davidgohel.github.io/gdtools/dev/reference/strings_sizes.md)
instead, which returns the width, the ascent and the descent in inches
(the height is the sum of the ascent and the descent).

## See also

Other functions for font metrics:
[`str_metrics()`](https://davidgohel.github.io/gdtools/dev/reference/str_metrics.md),
[`strings_sizes()`](https://davidgohel.github.io/gdtools/dev/reference/strings_sizes.md)
