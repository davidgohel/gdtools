
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gdtools

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/gdtools)](https://CRAN.R-project.org/package=gdtools)
[![R build
status](https://github.com/davidgohel/gdtools/workflows/R-CMD-check/badge.svg)](https://github.com/davidgohel/gdtools/actions)
[![codecov test
coverage](https://codecov.io/gh/davidgohel/gdtools/branch/master/graph/badge.svg)](https://app.codecov.io/gh/davidgohel/gdtools)
<!-- badges: end -->

## Font metrics calculation

The package `gdtools` provides functionalities to get font metrics and
to generate base64 encoded string from raster matrix. It is used by
package ‘flextable’ and ‘rvg’ to allow font metric calculation but can
also be used to compute the exact size a text would have with specific
font options (size, bold, italic).

``` r
library(gdtools)
str_extents(c("a string", "a longer string"), 
  fontsize = 24, bold = TRUE, italic = TRUE)
#>           [,1]     [,2]
#> [1,]  86.68359 22.60547
#> [2,] 166.68750 22.60547
```

## Font management

Another set of functions is provided to support the collection of fonts
from ‘Google Fonts’ in a cache. Their use is simple within ‘R Markdown’
documents and ‘shiny’ applications but also with graphic productions
generated with the ‘ggiraph’, ‘ragg’ and ‘svglite’ packages or with
tabular productions from the ‘flextable’ package.

Function `register_gfont()` is used to register a font with the system.

``` r
# Download to a user cache and register the font with systemfonts
# no need to download the font again
register_gfont(family = "Open Sans")
```

Function `addGFontHtmlDependency()` is used to add a font to a ‘html’
document.

### Utility to install a font

If you need a ‘Google Font’ to be installed on your machine, you can use
`install_gfont_script()`. This is a rare use case but can be useful in
some specific situations, e.g. when you need to install a font on a
server and make it available to all users. It can also be useful when
you are working with a docker image and want to install a font when the
image is built.

``` r
install_gfont_script("Fira Sans", file = "firafont.sh")
```

You then have to run `./firafont.sh`.

### Font ‘Liberation Sans’

If you don’t have web access, you can use font ‘Liberation Sans’ that is
available when using this package. That can be useful when you are
working with visual tests and don’t want to rely on an internet
connection or when you need a font for a ‘shiny’ application and or
graphics produced with packages ‘ggiraph’, ‘ragg’ or ‘svglite’.

## Installation

You can install the released version of gdtools from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("gdtools")
```

And the development version from
[GitHub](https://github.com/davidgohel/gdtools) with:

``` r
# install.packages("remotes")
remotes::install_github("davidgohel/gdtools")
```
