# List installed 'Google Fonts'

List installed 'Google Fonts' that can be found in the user cache
directory.

## Usage

``` r
installed_gfonts()
```

## Value

families names as a character vector

## See also

Other functions for font management:
[`addGFontHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/addGFontHtmlDependency.md),
[`fonts_cache_dir()`](https://davidgohel.github.io/gdtools/reference/fonts_cache_dir.md),
[`gfontHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/gfontHtmlDependency.md),
[`install_gfont_script()`](https://davidgohel.github.io/gdtools/reference/install_gfont_script.md),
[`liberationmonoHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/liberationmonoHtmlDependency.md),
[`liberationsansHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/liberationsansHtmlDependency.md),
[`liberationserifHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/liberationserifHtmlDependency.md),
[`register_gfont()`](https://davidgohel.github.io/gdtools/reference/register_gfont.md),
[`register_liberationmono()`](https://davidgohel.github.io/gdtools/reference/register_liberationmono.md),
[`register_liberationsans()`](https://davidgohel.github.io/gdtools/reference/register_liberationsans.md),
[`register_liberationserif()`](https://davidgohel.github.io/gdtools/reference/register_liberationserif.md)

## Examples

``` r
if (FALSE) { # \dontrun{
if (check_gfonts()) {
  dummy_setup()
  register_gfont(family = "Roboto")
  installed_gfonts()
}
} # }
```
