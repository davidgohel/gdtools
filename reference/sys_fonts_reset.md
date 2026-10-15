# Refresh the list of system fonts

The list of system fonts used by
[`sys_fonts()`](https://davidgohel.github.io/gdtools/reference/sys_fonts.md)
and
[`font_family_exists()`](https://davidgohel.github.io/gdtools/reference/font_family_exists.md)
is read once per R session, as reading it is slow when many fonts are
installed. Call this function after installing a font on the system
during the session so that it is found.

It also resets the font cache of 'systemfonts'
([`systemfonts::reset_font_cache()`](https://systemfonts.r-lib.org/reference/reset_font_cache.html)).

## Usage

``` r
sys_fonts_reset()
```

## Value

`NULL`, invisibly.

## See also

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
[`register_liberationserif()`](https://davidgohel.github.io/gdtools/reference/register_liberationserif.md)

## Examples

``` r
sys_fonts_reset()
```
