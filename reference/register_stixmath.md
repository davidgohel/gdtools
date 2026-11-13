# Register font 'STIX Two Math'

Register the font 'STIX Two Math', shipped with 'gdtools', so that it
can be found by name with the 'systemfonts' package: by functions
measuring or drawing equations (such as the 'equatags' package) and by
graphic devices using 'systemfonts' ('ragg', 'svglite', 'ggiraph').

'STIX Two Math' is an OpenType math font: it has a 'MATH' table giving
the parameters used to lay out equations, and size variants of operators
and delimiters.

Nothing is done when a font is already found under `name`, for example
when 'STIX Two Math' is installed on the system (it is on macOS).

## Usage

``` r
register_stixmath(name = "STIX Two Math")
```

## Arguments

- name:

  the name to use for the font family when registering with
  'systemfonts'.

## Value

TRUE if a font is found under `name` after the operation.

## License

'STIX Two Math' (version 2.13 b171) is copyright The STIX Fonts Project
Authors and licensed under the SIL Open Font License 1.1, see
`system.file("fonts", "stix", "OFL.txt", package = "gdtools")` and the
file `COPYRIGHTS` of the package.

## See also

[`stixmath_file()`](https://davidgohel.github.io/gdtools/reference/stixmath_file.md)

Other functions for font management:
[`addGFontHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/addGFontHtmlDependency.md),
[`fonts_cache_dir()`](https://davidgohel.github.io/gdtools/reference/fonts_cache_dir.md),
[`gfontHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/gfontHtmlDependency.md),
[`install_gfont_script()`](https://davidgohel.github.io/gdtools/reference/install_gfont_script.md),
[`installed_gfonts()`](https://davidgohel.github.io/gdtools/reference/installed_gfonts.md),
[`liberationmonoHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/liberationmonoHtmlDependency.md),
[`liberationsansHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/liberationsansHtmlDependency.md),
[`liberationserifHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/liberationserifHtmlDependency.md),
[`register_gfont()`](https://davidgohel.github.io/gdtools/reference/register_gfont.md),
[`register_liberationmono()`](https://davidgohel.github.io/gdtools/reference/register_liberationmono.md),
[`register_liberationsans()`](https://davidgohel.github.io/gdtools/reference/register_liberationsans.md),
[`register_liberationserif()`](https://davidgohel.github.io/gdtools/reference/register_liberationserif.md),
[`stixmath_file()`](https://davidgohel.github.io/gdtools/reference/stixmath_file.md),
[`sys_fonts_reset()`](https://davidgohel.github.io/gdtools/reference/sys_fonts_reset.md)

## Examples

``` r
register_stixmath()
#> [1] TRUE
```
