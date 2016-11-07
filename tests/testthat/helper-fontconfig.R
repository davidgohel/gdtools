
local <- function() {
  identical(Sys.getenv("NOT_CRAN"), "true")
}

# Use minimal fonts.conf to speed up fc-cache
if (!local()) {
  set_dummy_conf()
}
