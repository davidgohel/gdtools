# Package index

## Text measurement

Compute text width, ascent and descent using Cairo, independently of any
graphic device. strings_sizes() is the recommended entry point.

- [`strings_sizes()`](https://davidgohel.github.io/gdtools/reference/strings_sizes.md)
  : Compute strings sizes

## Font set

Create a font set that bundles registration, HTML dependencies and
family names in one step. Use font_google() or font_liberation() to
describe each font role, then pass the result to girafe(), dsvg() or
ggplot2 themes. font_set_liberation() is a ready-made set that works
offline on any platform.

- [`font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.md)
  : Create a font set
- [`font_set_liberation()`](https://davidgohel.github.io/gdtools/reference/font_set_liberation.md)
  : Liberation font set
- [`font_set_auto()`](https://davidgohel.github.io/gdtools/reference/font_set_auto.md)
  : Automatic font set
- [`font_google()`](https://davidgohel.github.io/gdtools/reference/font_google.md)
  : Google Font specification
- [`font_liberation()`](https://davidgohel.github.io/gdtools/reference/font_liberation.md)
  : Liberation Font specification

## Google Fonts

Lower-level helpers to download, cache and register individual fonts
from Google Fonts.

- [`register_gfont()`](https://davidgohel.github.io/gdtools/reference/register_gfont.md)
  : Register a 'Google Font'
- [`gfontHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/gfontHtmlDependency.md)
  : 'Google Font' HTML dependency
- [`addGFontHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/addGFontHtmlDependency.md)
  : Use a Font in Shiny or Markdown
- [`installed_gfonts()`](https://davidgohel.github.io/gdtools/reference/installed_gfonts.md)
  : List installed 'Google Fonts'
- [`install_gfont_script()`](https://davidgohel.github.io/gdtools/reference/install_gfont_script.md)
  : Shell command to install a font from 'Google Fonts'

## Liberation Fonts

Lower-level helpers to register and embed the bundled Liberation fonts
(Sans, Serif, Mono) individually.

- [`register_liberationsans()`](https://davidgohel.github.io/gdtools/reference/register_liberationsans.md)
  : Register font 'Liberation Sans'
- [`register_liberationserif()`](https://davidgohel.github.io/gdtools/reference/register_liberationserif.md)
  : Register font 'Liberation Serif'
- [`register_liberationmono()`](https://davidgohel.github.io/gdtools/reference/register_liberationmono.md)
  : Register font 'Liberation Mono'
- [`liberationsansHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/liberationsansHtmlDependency.md)
  : 'Liberation Sans' Font HTML dependency
- [`liberationserifHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/liberationserifHtmlDependency.md)
  : 'Liberation Serif' Font HTML dependency
- [`liberationmonoHtmlDependency()`](https://davidgohel.github.io/gdtools/reference/liberationmonoHtmlDependency.md)
  : 'Liberation Mono' Font HTML dependency

## Font discovery

Query available fonts on the system. font_family_exists() checks whether
a font is available, sys_fonts() lists all known fonts, and
match_family() finds the best match for a given name.

- [`font_family_exists()`](https://davidgohel.github.io/gdtools/reference/font_family_exists.md)
  : Check if font family exists.
- [`sys_fonts()`](https://davidgohel.github.io/gdtools/reference/sys_fonts.md)
  : List fonts for 'systemfonts'.

## Font cache

Manage the local directory where downloaded font files are stored. The
cache location can be customised with the GDTOOLS_CACHE_DIR environment
variable or R option.

- [`fonts_cache_dir()`](https://davidgohel.github.io/gdtools/reference/fonts_cache_dir.md)
  [`rm_fonts_cache()`](https://davidgohel.github.io/gdtools/reference/fonts_cache_dir.md)
  [`init_fonts_cache()`](https://davidgohel.github.io/gdtools/reference/fonts_cache_dir.md)
  : Manage Font Working Directory
- [`dummy_setup()`](https://davidgohel.github.io/gdtools/reference/dummy_setup.md)
  : Set up a temporary font cache

## C library versions

Return the runtime version of the Cairo and FreeType libraries linked to
the package.

- [`version_freetype()`](https://davidgohel.github.io/gdtools/reference/version_cairo.md)
  [`version_cairo()`](https://davidgohel.github.io/gdtools/reference/version_cairo.md)
  : Version numbers of C libraries
