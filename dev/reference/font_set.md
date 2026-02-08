# Create a font set

Bundle font registration, HTML dependencies, and font family names into
a single object. Each argument accepts a
[`font_google()`](https://davidgohel.github.io/gdtools/dev/reference/font_google.md)
specification, a
[`font_liberation()`](https://davidgohel.github.io/gdtools/dev/reference/font_liberation.md)
specification, or a plain character string naming a system font already
available.

The returned object provides fields ready to use with `ggplot2::theme()`
(`$sans`, `$serif`, `$mono`), `girafe(fonts = ...)` or
`dsvg(fonts = ...)` (`$dsvg_fonts`), and `girafe(dependencies = ...)`
(`$dependencies`).

## Usage

``` r
font_set(sans = NULL, serif = NULL, mono = NULL, symbol = NULL)
```

## Arguments

- sans:

  font for sans-serif text.

- serif:

  font for serif text.

- mono:

  font for monospace text.

- symbol:

  font for symbol text.

## Value

An object of class `font_set` with elements:

- sans:

  character, the sans font family name (or NULL)

- serif:

  character, the serif font family name (or NULL)

- mono:

  character, the mono font family name (or NULL)

- symbol:

  character, the symbol font family name (or NULL)

- dependencies:

  list of `htmlDependency` objects

- dsvg_fonts:

  named list of family names for `dsvg()`

- sources:

  named list of source labels

## See also

[`font_set_liberation()`](https://davidgohel.github.io/gdtools/dev/reference/font_set_liberation.md),
[`font_set_auto()`](https://davidgohel.github.io/gdtools/dev/reference/font_set_auto.md)

Other font set functions:
[`font_google()`](https://davidgohel.github.io/gdtools/dev/reference/font_google.md),
[`font_liberation()`](https://davidgohel.github.io/gdtools/dev/reference/font_liberation.md),
[`font_set_auto()`](https://davidgohel.github.io/gdtools/dev/reference/font_set_auto.md),
[`font_set_liberation()`](https://davidgohel.github.io/gdtools/dev/reference/font_set_liberation.md)

## Examples

``` r
fonts <- font_set(sans = font_liberation("sans"))
fonts$sans
#> [1] "Liberation Sans"
fonts$dsvg_fonts
#> $sans
#> [1] "Liberation Sans"
#> 
fonts$dependencies
#> [[1]]
#> List of 10
#>  $ name      : chr "liberation-sans"
#>  $ version   : chr "0.4.5.8"
#>  $ src       :List of 1
#>   ..$ file: chr "/home/runner/.local/share/R/gdtools/liberation-sans"
#>  $ meta      : NULL
#>  $ script    : NULL
#>  $ stylesheet: chr "css/liberation-sans.css"
#>  $ head      : NULL
#>  $ attachment: NULL
#>  $ package   : NULL
#>  $ all_files : logi TRUE
#>  - attr(*, "class")= chr "html_dependency"
#> 
```
