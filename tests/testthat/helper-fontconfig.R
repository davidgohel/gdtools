
local <- function() {
  identical(Sys.getenv("NOT_CRAN"), "true")
}

# Use minimal fonts.conf to speed up fc-cache
if (!local()) {
  if( require("fontquiver") )
    set_dummy_conf()
}
