% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fonts.R
\name{install_gfont_script}
\alias{install_gfont_script}
\title{Shell command to install a font from 'Google Fonts'}
\usage{
install_gfont_script(
  family = "Open Sans",
  subset = c("latin", "latin-ext"),
  platform = c("debian", "windows", "macos"),
  file = NULL
)
}
\arguments{
\item{family}{family name of a 'Google Fonts', for example, "Open Sans", "Roboto",
"Fira Code" or "Fira Sans Condensed". Complete list is available with the
following command:

\if{html}{\out{<div class="sourceCode">}}\preformatted{gfonts::get_all_fonts()$family |>
  unlist() |>
  unique() |>
  sort()
}\if{html}{\out{</div>}}}

\item{subset}{font subset, a character vector, it defaults to only "latin" and
"latin-ext" and can contains values such as "greek", "emoji", "chinese-traditional",

Run the following code to get a complete list:

\if{html}{\out{<div class="sourceCode">}}\preformatted{gfonts::get_all_fonts()$subsets |> unlist() |> unique() |> sort()
}\if{html}{\out{</div>}}}

\item{platform}{"debian" and "windows" and "macos" are supported.}

\item{file}{script file to generate, optional. If the parameter is
specified, a file will be generated ready for execution. If the
platform is Windows, administration rights are required to run
the script.}
}
\value{
the 'shell' or 'PowerShell' command as a string
}
\description{
Create a string containing a system command to execute
so that the font from 'Google Fonts' is installed on the system.
Its execution may require root permissions, in dockerfile for example.
}
\details{
It allows users to use fonts from 'Google Fonts' in an HTML page generated by 'shiny' or 'R Markdown'.
At the first request, the font files will be downloaded and stored in a cache on the
user's machine, thus avoiding many useless downloads or allowing to work with
these fonts afterwards without an Internet connection, in a docker image for example.
See \code{\link[=fonts_cache_dir]{fonts_cache_dir()}}.

The server delivering the font files should not be too busy. That's
why a one second pause is added after each download to respect the server's
limits. This time can be set with the option \code{GFONTS_DOWNLOAD_SLEEPTIME} which
must be a number of seconds.
}
\examples{
\dontrun{
if (check_gfonts()) {
  dummy_setup()
  install_gfont_script(family = "Roboto", platform = "macos")
}
}
}
\seealso{
Other functions for font management: 
\code{\link{addGFontHtmlDependency}()},
\code{\link{fonts_cache_dir}()},
\code{\link{gfontHtmlDependency}()},
\code{\link{installed_gfonts}()},
\code{\link{liberationsansHtmlDependency}()},
\code{\link{register_gfont}()},
\code{\link{register_liberationsans}()}
}
\concept{functions for font management}
