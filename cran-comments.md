## Test environments

- local OS X install (R 4.6.1)
- ubuntu 24.04 (release)
- winbuilder (with release and devel) 

## R CMD check results

There were no ERROR, WARNING or NOTE. 

## Reverse dependencies

There were 0 ERROR, 0 WARNING and 0 NOTE related to gdtools. 

## Changes in system requirements

gdtools no longer uses Cairo: metrics are read with FreeType from the font
files, and `SystemRequirements` is now `freetype2`.
