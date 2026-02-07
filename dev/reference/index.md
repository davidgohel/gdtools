# Package index

## Text measurement

Compute text width, ascent and descent using Cairo, independently of any
graphic device. strings_sizes() is the recommended entry point.

- [`strings_sizes()`](https://davidgohel.github.io/gdtools/dev/reference/strings_sizes.md)
  : Compute strings sizes

## Google Fonts

Download, cache and register fonts from Google Fonts. Use
register_gfont() to make a font available to R packages that rely on
systemfonts (flextable, ggiraph, ragg, svglite). Use
gfontHtmlDependency() or addGFontHtmlDependency() to embed the font in
an HTML output (Shiny, R Markdown, Quarto).

- [`register_gfont()`](https://davidgohel.github.io/gdtools/dev/reference/register_gfont.md)
  : Register a 'Google Font'
- [`gfontHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/gfontHtmlDependency.md)
  : 'Google Font' HTML dependency
- [`addGFontHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/addGFontHtmlDependency.md)
  : Use a Font in Shiny or Markdown
- [`installed_gfonts()`](https://davidgohel.github.io/gdtools/dev/reference/installed_gfonts.md)
  : List installed 'Google Fonts'
- [`install_gfont_script()`](https://davidgohel.github.io/gdtools/dev/reference/install_gfont_script.md)
  : Shell command to install a font from 'Google Fonts'

## Liberation Fonts

Register and embed the bundled Liberation fonts (Sans, Serif, Mono).
These metrically compatible alternatives to Arial, Times New Roman and
Courier New are useful as cross-platform fallback fonts, for visual
tests, or when no internet connection is available.

- [`register_liberationsans()`](https://davidgohel.github.io/gdtools/dev/reference/register_liberationsans.md)
  : Register font 'Liberation Sans'
- [`register_liberationserif()`](https://davidgohel.github.io/gdtools/dev/reference/register_liberationserif.md)
  : Register font 'Liberation Serif'
- [`register_liberationmono()`](https://davidgohel.github.io/gdtools/dev/reference/register_liberationmono.md)
  : Register font 'Liberation Mono'
- [`liberationsansHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/liberationsansHtmlDependency.md)
  : 'Liberation Sans' Font HTML dependency
- [`liberationserifHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/liberationserifHtmlDependency.md)
  : 'Liberation Serif' Font HTML dependency
- [`liberationmonoHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/liberationmonoHtmlDependency.md)
  : 'Liberation Mono' Font HTML dependency

## Font discovery

Query available fonts on the system. font_family_exists() checks whether
a font is available, sys_fonts() lists all known fonts, and
match_family() finds the best match for a given name.

- [`font_family_exists()`](https://davidgohel.github.io/gdtools/dev/reference/font_family_exists.md)
  : Check if font family exists.
- [`sys_fonts()`](https://davidgohel.github.io/gdtools/dev/reference/sys_fonts.md)
  : List fonts for 'systemfonts'.

## Font cache

Manage the local directory where downloaded font files are stored. The
cache location can be customised with the GDTOOLS_CACHE_DIR environment
variable or R option.

- [`fonts_cache_dir()`](https://davidgohel.github.io/gdtools/dev/reference/fonts_cache_dir.md)
  [`rm_fonts_cache()`](https://davidgohel.github.io/gdtools/dev/reference/fonts_cache_dir.md)
  [`init_fonts_cache()`](https://davidgohel.github.io/gdtools/dev/reference/fonts_cache_dir.md)
  : Manage Font Working Directory
- [`dummy_setup()`](https://davidgohel.github.io/gdtools/dev/reference/dummy_setup.md)
  : Set up a temporary font cache

## C library versions

Return the runtime version of the Cairo and FreeType libraries linked to
the package.

- [`version_freetype()`](https://davidgohel.github.io/gdtools/dev/reference/version_cairo.md)
  [`version_cairo()`](https://davidgohel.github.io/gdtools/dev/reference/version_cairo.md)
  : Version numbers of C libraries
