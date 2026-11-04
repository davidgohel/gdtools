# Version of the Cairo library (deprecated)

gdtools no longer uses Cairo: font metrics are read with FreeType from
the font files (see
[`version_freetype()`](https://davidgohel.github.io/gdtools/dev/reference/version_freetype.md)).
This function is deprecated and will be removed in a future release.

## Usage

``` r
version_cairo()
```

## Value

`NULL`, invisibly.

## Examples

``` r
suppressWarnings(version_cairo())
```
