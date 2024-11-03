# gdtools 0.4.1

- specify systemfonts version shoud be 1.1.0 (#71)

# gdtools 0.4.0

## Changes

- Move 'gfonts' and 'curl' in 'Suggests' dependencies so that it can
be used with 'webR'.

# gdtools 0.3.7

## Issues

- fix htmlDependancy for Liberation Sans

# gdtools 0.3.6

## Changes

- update 'Google Fonts' font database

# gdtools 0.3.5

## Issues

- fix -Wformat-security issue under r-devel

## New features

- `install_gfont_script()` can now directly generate a script
file ready to be executed to install a 'Google Font', use
argument `file`.

# gdtools 0.3.4

## Changes

- update to libcairo 1.18
- use dontrun macro to avoid CRAN errors

# gdtools 0.3.3

## Issues

- no more calls to `gfonts::get_all_fonts()`. This should enable usage
for those with no access to website used by 'gfonts'.

# gdtools 0.3.2

## New features

- new function `installed_gfonts()` to list installed font from 'Google'

# gdtools 0.3.1

## New features

- add 'liberation-sans' for having a fallback when off-line

# gdtools 0.3.0

## New features

- The package now allows to download and work with Google Fonts thanks to the
'gfonts' and 'systemfonts' package. This is very useful for managing fonts with
graphics produced with 'ragg', 'svglite' and 'ggiraph' but also with 'flextable'
tables. Finally, it is possible to easily embed these fonts in HTML documents.

# gdtools 0.2.4

* Windows: add support for ucrt toolchains

# gdtools 0.2.3

* fixes for configure script for M1 mac and solaris

# gdtools 0.2.2

* Small tweaks for configure script

# gdtools 0.2.1

## issues

* Change font_family_exists so that it only check a family exists in
  family column returned by systemfonts::system_fonts()
* fix a memory leak

# gdtools 0.2.0

* refactor - package is now using package systemfonts instead of using fontconfig to locate fonts file

# gdtools 0.1.9

* keep locale intact when using various gdtools functions (fix #51)
* Reuse magick FONTCONFIG_PATH if exists

# gdtools 0.1.8

* Windows: update cairo stack to rwinlib/cairo v1.15.10

# gdtools 0.1.6

* update with Rcpp 0.12.12
* new function `glyphs_match` to test whether glyphs in strings are all existing in a font table or not.

# gdtools 0.1.5

* increase tolerance in font metrics unit-tests as new version of freetype
  is slightly changing returned extents.

# gdtools 0.1.4

* New file src/registerDynamicSymbol.c to correctly register provided routines
* a cleanup file to delete src/Makevars when package has been built

# gdtools 0.1.3

* Add set_dummy_conf() and unset_dummy_conf() to set a minimalistic
  Fontconfig configuration. Useful to speed up cache building on
  Appveyor or CRAN.
* skip tests that need fontquiver when not installed.

# gdtools 0.1.2

* Fix a crash on some Linux platforms (hadley/svglite#80)

# gdtools 0.1.1

## updates

* examples from sys_fonts and match_family are marked as donttest as their first run
  can be slow if no font caches are existing.

# gdtools 0.1.0

## new functions

* sys_fonts: get system fonts details.
* font_family_exists: test if a given font family name can be matched exactly
* match_family: find best family match for a given Fontconfig pattern
* match_font: returns font information for a given Fontconfig pattern
* base64_string_export: encode a string in base64
* version_cairo: runtime version of the Cairo library
* version_freetype: runtime version of the FreeType library
* version_fontconfig: compile-time version of the Fontconfig library

## updates

* CONFIGURE file has been updated with Homebrew new repo (Jeroen Ooms)
* GPL-3 license file has been added
* CairoContext now uses Fontconfig to find system fonts
* CairoContext now supports user-defined font files

# gdtools 0.0.7

* Fix to let OS X Snow Leopard produce binaries (Jeroen Ooms)

# gdtools 0.0.6

* Fix to prevent OSX CRAN builder from linking
  against old libs in /usr/local/lib (Jeroen Ooms)

# gdtools 0.0.5

* new function raster_write to write raster object to a png file
* usage of testthat

# gdtools 0.0.4

* Fix for Mavericks CRAN builder (Jeroen Ooms)
* Fix for solaris CRAN builder (Jeroen Ooms)

