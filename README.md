
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gdtools

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/gdtools)](https://CRAN.R-project.org/package=gdtools)
[![R build
status](https://github.com/davidgohel/gdtools/workflows/R-CMD-check/badge.svg)](https://github.com/davidgohel/gdtools/actions)
[![Coverage
Status](https://img.shields.io/codecov/c/github/davidgohel/gdtools/master.svg)](https://codecov.io/github/davidgohel/gdtools?branch=master)
<!-- badges: end -->

The package `gdtools` provides functionalities to get font metrics and
to generate base64 encoded string from raster matrix. It is used by
package `ggiraph` and `rvg` to allow font metric calculation but can
also be used to compute the exact size a text would have with specific
font options (size, bold, italic).

## Installation

You can install the released version of gdtools from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("gdtools")
```

And the development version from
[GitHub](https://github.com/davidgohel/gdtools) with:

``` r
# install.packages("devtools")
devtools::install_github("davidgohel/gdtools")
```

## Example

``` r
library(gdtools)
str_extents(c("a string", "a longer string"), 
  fontsize = 24, bold = TRUE, italic = TRUE)
#>           [,1]     [,2]
#> [1,]  86.68359 22.60547
#> [2,] 166.68750 22.60547
```

## For mac os users

This package needs X11 to be available on mac os machines. This will
make cairo, font-config and other system dependancies available. This is
documented here: [R for Mac OS
X](https://cran.r-project.org/bin/macosx/) ; X11 can be downloaded from
[XQuartz](https://www.xquartz.org/) website.

  - `Unable to load shared object`
    
    Sometimes, when your OS got updated, some font settings and several
    other settings can be changed. An error similar to the one below can
    be read :
    
        Error in dyn.load(file, DLLpath = DLLpath, ...) : 
         unable to load shared object '/Library/Frameworks/R.framework/Versions/.../gdtools/libs/gdtools.so':
        dlopen(/Library/Frameworks/R.framework/Versions/.../gdtools/libs/gdtools.so, 6): Library not loaded: /opt/X11/lib/libcairo.2.dylib
        Referenced from: /Library/Frameworks/R.framework/Versions/.../gdtools/libs/gdtools.so 
        Reason: image not found
    
    Or
    
        Error: package or namespace load failed for ‘xxxx’ in dyn.load(file, DLLpath = DLLpath, ...):
         unable to load shared object '/Library/Frameworks/R.framework/Versions/.../systemfonts/libs/systemfonts.so':
        dlopen(/Library/Frameworks/R.framework/Versions/.../systemfonts/libs/systemfonts.so, 6): Library not loaded: /opt/X11/lib/libfreetype.6.dylib
        Referenced from: /Library/Frameworks/R.framework/Versions/.../systemfonts/libs/systemfonts.so
        Reason: image not found
    
    > Solution:
    
    1.  Close all R sessions
    2.  Re-install XQuartz when upgrading your macOS to a new major
        version.
    3.  Re-install package gdtools.
    
    If you need to build the package from sources, make sure XCode is
    installed and you have accepted the license agreement.
