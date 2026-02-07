# Manage Font Working Directory

Initialize or remove font directory used to store downloaded font files.

This directory is managed by R function `R_user_dir()` but can also be
defined in a non-user location by setting ENV variable
`GDTOOLS_CACHE_DIR` or by setting R option `GDTOOLS_CACHE_DIR`.

Its value can be read with the `fonts_cache_dir()` function.

The directory can be deleted with `rm_fonts_cache()` and created with
`init_fonts_cache()`.

## Usage

``` r
fonts_cache_dir()

rm_fonts_cache()

init_fonts_cache()
```

## See also

Other functions for font management:
[`addGFontHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/addGFontHtmlDependency.md),
[`gfontHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/gfontHtmlDependency.md),
[`install_gfont_script()`](https://davidgohel.github.io/gdtools/dev/reference/install_gfont_script.md),
[`installed_gfonts()`](https://davidgohel.github.io/gdtools/dev/reference/installed_gfonts.md),
[`liberationmonoHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/liberationmonoHtmlDependency.md),
[`liberationsansHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/liberationsansHtmlDependency.md),
[`liberationserifHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/liberationserifHtmlDependency.md),
[`register_gfont()`](https://davidgohel.github.io/gdtools/dev/reference/register_gfont.md),
[`register_liberationmono()`](https://davidgohel.github.io/gdtools/dev/reference/register_liberationmono.md),
[`register_liberationsans()`](https://davidgohel.github.io/gdtools/dev/reference/register_liberationsans.md),
[`register_liberationserif()`](https://davidgohel.github.io/gdtools/dev/reference/register_liberationserif.md)

## Examples

``` r
fonts_cache_dir()
#> [1] "/home/runner/.local/share/R/gdtools"

options(GDTOOLS_CACHE_DIR = tempdir())
fonts_cache_dir()
#> [1] "/tmp/RtmpojFSi4"
options(GDTOOLS_CACHE_DIR = NULL)

Sys.setenv(GDTOOLS_CACHE_DIR = tempdir())
fonts_cache_dir()
#> [1] "/tmp/RtmpojFSi4"
Sys.setenv(GDTOOLS_CACHE_DIR = "")



init_fonts_cache()
#> [1] "/home/runner/.local/share/R/gdtools"
dir.exists(fonts_cache_dir())
#> [1] TRUE

rm_fonts_cache()
dir.exists(fonts_cache_dir())
#> [1] FALSE
```
