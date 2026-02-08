# Changelog

## gdtools 0.5.0

### New features

- New font management API:
  [`font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.md),
  [`font_set_liberation()`](https://davidgohel.github.io/gdtools/reference/font_set_liberation.md),
  and
  [`font_set_auto()`](https://davidgohel.github.io/gdtools/reference/font_set_auto.md)
  provide a unified way to configure font aliases, register fonts with
  ‘systemfonts’, and generate ‘htmlDependency’ objects in a single step.
  Helper functions
  [`font_google()`](https://davidgohel.github.io/gdtools/reference/font_google.md)
  and
  [`font_liberation()`](https://davidgohel.github.io/gdtools/reference/font_liberation.md)
  declare individual font sources.

### changes

- [`register_liberationsans()`](https://davidgohel.github.io/gdtools/reference/register_liberationsans.md),
  [`register_liberationserif()`](https://davidgohel.github.io/gdtools/reference/register_liberationserif.md)
  and
  [`register_liberationmono()`](https://davidgohel.github.io/gdtools/reference/register_liberationmono.md)
  gain a `name` parameter to register Liberation fonts under a custom
  family name (e.g. `"sans"`, `"serif"`, `"mono"`). Default values are
  unchanged.
- remove unused `str_extents()`.
- remove C++ exported interface as no package uses `LinkingTo: gdtools`
  anymore.

### issues

- fix face mapping in
  [`strings_sizes()`](https://davidgohel.github.io/gdtools/reference/strings_sizes.md):
  italic text was incorrectly measured as bold-italic (face 4 instead of
  face 3).
- [`strings_sizes()`](https://davidgohel.github.io/gdtools/reference/strings_sizes.md)
  now re-uses Cairo text measurement instead of
  [`systemfonts::string_metrics_dev()`](https://systemfonts.r-lib.org/reference/string_metrics_dev.html).
  Callers no longer need a ragg device open for accurate metrics. The
  measurements are accurate for devices that use Cairo or ‘systemfonts’
  (ragg, svglite, ggiraph,
  [`cairo_pdf()`](https://rdrr.io/r/grDevices/cairo.html), …).

## gdtools 0.4.4

CRAN release: 2025-10-06

- add tools to use fonts ‘Liberation Serif’ and ‘Liberation Mono’.
- deprecate
  [`set_dummy_conf()`](https://davidgohel.github.io/gdtools/reference/set_dummy_conf.md)
  that should be removed from the package in a later version.
- remove `raster_*` functions not used anymore

## gdtools 0.4.2

CRAN release: 2025-03-27

- Windows: use cairo from Rtools if available on recent R versions

## gdtools 0.4.1

CRAN release: 2024-11-04

- specify systemfonts version shoud be 1.1.0
  ([\#71](https://github.com/davidgohel/gdtools/issues/71))

## gdtools 0.4.0

CRAN release: 2024-08-28

### Changes

- Move ‘gfonts’ and ‘curl’ in ‘Suggests’ dependencies so that it can be
  used with ‘webR’.

## gdtools 0.3.7

CRAN release: 2024-03-05

### Issues

- fix htmlDependancy for Liberation Sans

## gdtools 0.3.6

CRAN release: 2024-02-22

### Changes

- update ‘Google Fonts’ font database

## gdtools 0.3.5

CRAN release: 2023-12-09

### Issues

- fix -Wformat-security issue under r-devel

### New features

- [`install_gfont_script()`](https://davidgohel.github.io/gdtools/reference/install_gfont_script.md)
  can now directly generate a script file ready to be executed to
  install a ‘Google Font’, use argument `file`.

## gdtools 0.3.4

CRAN release: 2023-10-15

### Changes

- update to libcairo 1.18
- use dontrun macro to avoid CRAN errors

## gdtools 0.3.3

CRAN release: 2023-03-27

### Issues

- no more calls to
  [`gfonts::get_all_fonts()`](https://dreamrs.github.io/gfonts/reference/get_all_fonts.html).
  This should enable usage for those with no access to website used by
  ‘gfonts’.

## gdtools 0.3.2

CRAN release: 2023-03-13

### New features

- new function
  [`installed_gfonts()`](https://davidgohel.github.io/gdtools/reference/installed_gfonts.md)
  to list installed font from ‘Google’

## gdtools 0.3.1

CRAN release: 2023-02-17

### New features

- add ‘liberation-sans’ for having a fallback when off-line

## gdtools 0.3.0

CRAN release: 2023-01-15

### New features

- The package now allows to download and work with Google Fonts thanks
  to the ‘gfonts’ and ‘systemfonts’ package. This is very useful for
  managing fonts with graphics produced with ‘ragg’, ‘svglite’ and
  ‘ggiraph’ but also with ‘flextable’ tables. Finally, it is possible to
  easily embed these fonts in HTML documents.

## gdtools 0.2.4

CRAN release: 2022-02-14

- Windows: add support for ucrt toolchains

## gdtools 0.2.3

CRAN release: 2021-01-06

- fixes for configure script for M1 mac and solaris

## gdtools 0.2.2

CRAN release: 2020-04-03

- Small tweaks for configure script

## gdtools 0.2.1

CRAN release: 2019-10-14

### issues

- Change font_family_exists so that it only check a family exists in
  family column returned by systemfonts::system_fonts()
- fix a memory leak

## gdtools 0.2.0

CRAN release: 2019-09-03

- refactor - package is now using package systemfonts instead of using
  fontconfig to locate fonts file

## gdtools 0.1.9

CRAN release: 2019-06-18

- keep locale intact when using various gdtools functions (fix
  [\#51](https://github.com/davidgohel/gdtools/issues/51))
- Reuse magick FONTCONFIG_PATH if exists

## gdtools 0.1.8

CRAN release: 2019-04-02

- Windows: update cairo stack to rwinlib/cairo v1.15.10

## gdtools 0.1.6

CRAN release: 2017-09-01

- update with Rcpp 0.12.12
- new function `glyphs_match` to test whether glyphs in strings are all
  existing in a font table or not.

## gdtools 0.1.5

CRAN release: 2017-08-08

- increase tolerance in font metrics unit-tests as new version of
  freetype is slightly changing returned extents.

## gdtools 0.1.4

CRAN release: 2017-03-17

- New file src/registerDynamicSymbol.c to correctly register provided
  routines
- a cleanup file to delete src/Makevars when package has been built

## gdtools 0.1.3

CRAN release: 2016-11-11

- Add set_dummy_conf() and unset_dummy_conf() to set a minimalistic
  Fontconfig configuration. Useful to speed up cache building on
  Appveyor or CRAN.
- skip tests that need fontquiver when not installed.

## gdtools 0.1.2

CRAN release: 2016-11-06

- Fix a crash on some Linux platforms (hadley/svglite#80)

## gdtools 0.1.1

CRAN release: 2016-11-01

### updates

- examples from sys_fonts and match_family are marked as donttest as
  their first run can be slow if no font caches are existing.

## gdtools 0.1.0

### new functions

- sys_fonts: get system fonts details.
- font_family_exists: test if a given font family name can be matched
  exactly
- match_family: find best family match for a given Fontconfig pattern
- match_font: returns font information for a given Fontconfig pattern
- base64_string_export: encode a string in base64
- version_cairo: runtime version of the Cairo library
- version_freetype: runtime version of the FreeType library
- version_fontconfig: compile-time version of the Fontconfig library

### updates

- CONFIGURE file has been updated with Homebrew new repo (Jeroen Ooms)
- GPL-3 license file has been added
- CairoContext now uses Fontconfig to find system fonts
- CairoContext now supports user-defined font files

## gdtools 0.0.7

CRAN release: 2016-02-16

- Fix to let OS X Snow Leopard produce binaries (Jeroen Ooms)

## gdtools 0.0.6

CRAN release: 2015-11-25

- Fix to prevent OSX CRAN builder from linking against old libs in
  /usr/local/lib (Jeroen Ooms)

## gdtools 0.0.5

CRAN release: 2015-11-12

- new function raster_write to write raster object to a png file
- usage of testthat

## gdtools 0.0.4

CRAN release: 2015-10-28

- Fix for Mavericks CRAN builder (Jeroen Ooms)
- Fix for solaris CRAN builder (Jeroen Ooms)
