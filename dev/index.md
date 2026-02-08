# gdtools

`gdtools` addresses four practical problems when working with fonts in
R:

| Problem                                                                                                                                     | gdtools solution                                                                                                                                                                                                                                                               |
|---------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Measure text without a device: layout calculations (column widths, text wrapping) need reliable metrics independent of the rendering device | [`strings_sizes()`](https://davidgohel.github.io/gdtools/dev/reference/strings_sizes.md) via Cairo                                                                                                                                                                             |
| Register non-system fonts: Google Fonts or Liberation fonts (bundled) must be made visible to ‘systemfonts’                                 | [`font_set_liberation()`](https://davidgohel.github.io/gdtools/dev/reference/font_set_liberation.md), [`font_set_auto()`](https://davidgohel.github.io/gdtools/dev/reference/font_set_auto.md), [`font_set()`](https://davidgohel.github.io/gdtools/dev/reference/font_set.md) |
| Embed fonts in HTML: Shiny, R Markdown and girafe need `htmlDependency` objects so the browser loads the right fonts                        | `font_set()$dependencies`, [`gfontHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/gfontHtmlDependency.md), `liberation*HtmlDependency()`                                                                                                                 |
| Check font availability: detect missing fonts before rendering, to avoid silent fallbacks                                                   | [`font_family_exists()`](https://davidgohel.github.io/gdtools/dev/reference/font_family_exists.md), [`sys_fonts()`](https://davidgohel.github.io/gdtools/dev/reference/sys_fonts.md)                                                                                           |

## How font metric calculation works

`gdtools` was originally designed to compute font metrics for R graphic
devices via C-level interfaces (Cairo and FreeType). With the arrival of
the ‘systemfonts’ package, font discovery and matching became much
simpler and the C interface was no longer needed by other packages.

The package has since been refocused. Font metric calculation follows
two steps:

1.  Font lookup: ‘systemfonts’ resolves the family name to a font file.
    Any font registered via
    [`systemfonts::register_font()`](https://systemfonts.r-lib.org/reference/register_font.html),
    [`register_gfont()`](https://davidgohel.github.io/gdtools/dev/reference/register_gfont.md),
    or
    [`font_set()`](https://davidgohel.github.io/gdtools/dev/reference/font_set.md)
    is found.
2.  Metric computation: Cairo reads the font file and computes width,
    ascent, and descent.

The metrics are independent of any graphic device. Whether they match
the final rendering depends on how the device resolves fonts on its
side, this is a device concern.

## Installation

You can install the released version of gdtools from CRAN with:

``` r
install.packages("gdtools")
```

And the development version from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("davidgohel/gdtools")
```

## Font metrics

The main function for text measurement is
[`strings_sizes()`](https://davidgohel.github.io/gdtools/dev/reference/strings_sizes.md).
It returns width, ascent and descent in inches using Cairo. The
measurements are accurate for devices that use Cairo or ‘systemfonts’
for font resolution (ragg, svglite, ggiraph,
[`cairo_pdf()`](https://rdrr.io/r/grDevices/cairo.html), …); for devices
with their own font engine
([`pdf()`](https://rdrr.io/r/grDevices/pdf.html),
[`png()`](https://rdrr.io/r/grDevices/png.html), …) the metrics may not
match the rendering.

``` r
library(gdtools)
strings_sizes(
  c("a string", "a longer string"),
  fontsize = 24, 
  bold = TRUE, 
  italic = TRUE
)
#>      width    ascent    descent
#> 1 1.203939 0.2413737 0.07259115
#> 2 2.315104 0.2413737 0.07259115
```

All arguments are vectorized:

``` r
strings_sizes(
  c("normal", "bold", "italic", "bold-italic"),
  fontsize = 12,
  bold = c(FALSE, TRUE, FALSE, TRUE),
  italic = c(FALSE, FALSE, TRUE, TRUE)
)
#>       width    ascent     descent
#> 1 0.5094401 0.1195475 0.003173828
#> 2 0.3517253 0.1199544 0.003092448
#> 3 0.3334147 0.1195475 0.002929688
#> 4 0.7870280 0.1206868 0.003092448
```

## Font management

[`font_set_auto()`](https://davidgohel.github.io/gdtools/dev/reference/font_set_auto.md)
detects the best available system fonts and falls back to Liberation
fonts when needed. It returns a `font_set` object ready to use with
ggplot2, ggiraph, or any ‘systemfonts’-based device:

``` r
library(gdtools)

fonts <- font_set_auto()
fonts
#> Font set
#>   sans:    Arial [system]
#>   serif:   Times New Roman [system]
#>   mono:    Courier New [system]
#>   symbol:  Symbol [system]
#>   4 HTML dependencies
```

For explicit control,
[`font_set()`](https://davidgohel.github.io/gdtools/dev/reference/font_set.md)
lets you pick each role with
[`font_google()`](https://davidgohel.github.io/gdtools/dev/reference/font_google.md),
[`font_liberation()`](https://davidgohel.github.io/gdtools/dev/reference/font_liberation.md),
or a plain family name:

``` r
fonts <- font_set(
  sans  = font_google("Open Sans"),
  mono  = font_liberation("mono")
)

fonts$sans          # "Open Sans"
fonts$dsvg_fonts    # named list for dsvg() / girafe()
fonts$dependencies  # list of htmlDependency objects
```

For an offline-only setup,
[`font_set_liberation()`](https://davidgohel.github.io/gdtools/dev/reference/font_set_liberation.md)
uses Liberation fonts for all four roles:

``` r
fonts <- font_set_liberation()
fonts
```

### Going further

#### Google Fonts

A set of lower-level functions is provided to download and cache fonts
from ‘Google Fonts’. They can be used in ‘R Markdown’ documents and
‘Shiny’ applications, as well as with graphic outputs generated by
‘ggiraph’, ‘ragg’ and ‘svglite’, or tabular outputs from ‘flextable’.

``` r
# Download and register with systemfonts (cached for future use)
register_gfont(family = "Open Sans")
```

Use
[`addGFontHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/addGFontHtmlDependency.md)
to embed a Google Font in an HTML document, and
[`gfontHtmlDependency()`](https://davidgohel.github.io/gdtools/dev/reference/gfontHtmlDependency.md)
to create an `htmltools` dependency object.

To install a Google Font at the system level (e.g. in a Dockerfile), use
[`install_gfont_script()`](https://davidgohel.github.io/gdtools/dev/reference/install_gfont_script.md):

``` r
install_gfont_script("Fira Sans", platform = "debian", file = "install-font.sh")
```

#### Liberation fonts

The package bundles ‘Liberation Sans’, ‘Liberation Serif’ and
‘Liberation Mono’ fonts (SIL Open Font License). They are useful as
cross-platform fallback fonts, for visual tests, or when no internet
connection is available.

[`font_set_liberation()`](https://davidgohel.github.io/gdtools/dev/reference/font_set_liberation.md)
registers all three families with ‘systemfonts’ and produces the
matching HTML dependencies in a single call:

``` r
fonts <- font_set_liberation()
fonts$sans
fonts$dependencies
```

The individual functions
[`register_liberationsans()`](https://davidgohel.github.io/gdtools/dev/reference/register_liberationsans.md),
[`register_liberationserif()`](https://davidgohel.github.io/gdtools/dev/reference/register_liberationserif.md)
and
[`register_liberationmono()`](https://davidgohel.github.io/gdtools/dev/reference/register_liberationmono.md)
remain available when only a specific variant is needed.
