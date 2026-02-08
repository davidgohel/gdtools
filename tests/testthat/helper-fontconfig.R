skip_if_not_ready <- function() {
  skip_on_cran()
  skip_if_not_installed("curl")
  skip_if_not(curl::has_internet(), "no internet connection")
}
