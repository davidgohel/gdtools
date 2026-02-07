# Register font 'Liberation Mono'

Register font 'Liberation Mono' so that it can be used with devices
using the 'systemfonts' package, i.e. the 'flextable' package and
graphic outputs generated with the 'ragg', 'svglite' and 'ggiraph'
packages.

## Usage

``` r
register_liberationmono(name = "Liberation Mono")
```

## Arguments

- name:

  the name to use for the font family when registering with
  'systemfonts'. Using a custom name (e.g. `"sans"`, `"serif"`,
  `"mono"`) allows devices like 'ragg' to resolve generic family names
  to this font.

## Value

TRUE if the operation went ok.

## See also

Other functions for font management:
[`addGFontHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/addGFontHtmlDependency.md),
[`fonts_cache_dir()`](https://davidgohel.github.io/gdtools/dev/reference/fonts_cache_dir.md),
[`gfontHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/gfontHtmlDependency.md),
[`install_gfont_script()`](https://davidgohel.github.io/gdtools/dev/reference/install_gfont_script.md),
[`installed_gfonts()`](https://davidgohel.github.io/gdtools/dev/reference/installed_gfonts.md),
[`liberationmonoHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/liberationmonoHtmlDependency.md),
[`liberationsansHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/liberationsansHtmlDependency.md),
[`liberationserifHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/liberationserifHtmlDependency.md),
[`register_gfont()`](https://davidgohel.github.io/gdtools/dev/reference/register_gfont.md),
[`register_liberationsans()`](https://davidgohel.github.io/gdtools/dev/reference/register_liberationsans.md),
[`register_liberationserif()`](https://davidgohel.github.io/gdtools/dev/reference/register_liberationserif.md)

## Examples

``` r
register_liberationmono()
#> [1] TRUE
register_liberationmono(name = "mono")
#> [1] TRUE
```
