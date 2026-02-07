# Version numbers of C libraries

Return the runtime version of the Cairo and FreeType libraries linked to
the package.

## Usage

``` r
version_freetype()

version_cairo()
```

## Value

An object of class `"numeric_version"`.

## Examples

``` r
version_cairo()
#> [1] ‘1.18.0’
version_freetype()
#> [1] ‘2.13.2’
```
