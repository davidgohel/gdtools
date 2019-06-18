# Uses XQuartz fontconfig configuration on OSX
.onLoad <- function(lib, pkg){
  if(!nchar(Sys.getenv("FONTCONFIG_PATH"))){

    if( Sys.info()['sysname'] == "Windows" ){
      Sys.setenv(FONTCONFIG_PATH = file.path(lib, pkg, "fontconfig") )
    } else if(file.exists(fontdir <- system.file("etc", "fonts", package = "magick", mustWork = FALSE))) {
      Sys.setenv(FONTCONFIG_PATH=fontdir)
    } else if(file.exists("/opt/X11/lib/X11/fontconfig")){
        Sys.setenv(FONTCONFIG_PATH="/opt/X11/lib/X11/fontconfig")
    }
  }
}
