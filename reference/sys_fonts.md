# List fonts for 'systemfonts'.

List system and registry fonts into a data.frame containing columns such
as path, family, style, weight and italic.

Listing the system fonts is slow when many fonts are installed, so the
list is read once per R session; fonts registered with 'systemfonts'
(e.g. with
[`register_liberationsans()`](https://davidgohel.github.io/gdtools/reference/register_liberationsans.md)
or
[`register_gfont()`](https://davidgohel.github.io/gdtools/reference/register_gfont.md))
are always included. Call
[`sys_fonts_reset()`](https://davidgohel.github.io/gdtools/reference/sys_fonts_reset.md)
after installing a font on the system during the session.

## Usage

``` r
sys_fonts()
```

## Value

A data.frame of font information.

## Examples

``` r
sys_fonts()
#> # A tibble: 178 × 6
#>    path                                         index family style weight italic
#>    <chr>                                        <int> <chr>  <chr> <ord>  <lgl> 
#>  1 /usr/share/fonts/type1/urw-base35/URWGothic…     0 URW G… Book… normal FALSE 
#>  2 /usr/share/fonts/truetype/lato/Lato-ThinIta…     0 Lato   Thin… normal TRUE  
#>  3 /usr/share/fonts/truetype/liberation/Libera…     0 Liber… Bold  bold   FALSE 
#>  4 /usr/share/fonts/truetype/lato/Lato-Semibol…     0 Lato   Semi… semib… TRUE  
#>  5 /usr/share/fonts/type1/urw-base35/NimbusMon…     0 Nimbu… Bold… bold   TRUE  
#>  6 /usr/share/fonts/truetype/liberation/Libera…     0 Liber… Bold  bold   FALSE 
#>  7 /usr/share/fonts/opentype/urw-base35/Nimbus…     0 Nimbu… Bold… bold   TRUE  
#>  8 /usr/share/fonts/type1/urw-base35/NimbusRom…     0 Nimbu… Regu… normal FALSE 
#>  9 /usr/share/fonts/truetype/lato/Lato-MediumI…     0 Lato   Medi… medium TRUE  
#> 10 /usr/share/fonts/type1/urw-base35/NimbusRom…     0 Nimbu… Ital… normal TRUE  
#> # ℹ 168 more rows
```
