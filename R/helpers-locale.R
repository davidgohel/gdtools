# Get some locale infos
get_locale <- function() {
  vapply(
    c("LC_COLLATE", "LC_CTYPE", "LC_MONETARY", "LC_NUMERIC", "LC_TIME"),
    Sys.getlocale,
    character(1)
  )
}

# Set locale infos
set_locale <- function(locales) {
  old_locale <- get_locale()
  mapply(Sys.setlocale, category = names(locales), locale = locales)
  old_locale
}
