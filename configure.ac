# Process this file with autoconf to produce a configure script.
AC_INIT(rfontmetrics, 0.1, david.gohel@ardata.fr)
AC_CONFIG_HEADER([src/cconfig.h])

# find R home and set CC/CFLAGS
: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
  echo "could not determine R_HOME"
  exit 1
fi
RBIN="${R_HOME}/bin/R"
CC=`"${RBIN}" CMD config CC`;
CFLAGS=`"${RBIN}" CMD config CFLAGS`
CPP=`"${RBIN}" CMD config CPP`;
AC_SUBST(R_HOME)

# platform check
#AC_CANONICAL_HOST

# Checks for programs.
AC_PROG_CC

# Checks for libraries.

# Checks for header files.
AC_HEADER_STDC
AC_HEADER_SYS_WAIT
AC_CHECK_HEADERS([string.h sys/time.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
#AC_HEADER_TIME

# Checks for library functions.
#AC_FUNC_MALLOC
#AC_TYPE_SIGNAL

AC_PATH_PROG([PKGCONF],[pkg-config],[],[$PATH:/usr/local/bin:ext/bin:ext:/sw/bin:/opt/bin])

have_cairo=no
if test "xx$CAIRO_LIBS" == "xx"; then
   if test "xx$PKGCONF" != "xx"; then
      AC_MSG_CHECKING([whether pkg-config knows about cairo])
      if "${PKGCONF}" --exists cairo; then
         AC_MSG_RESULT([yes])
	 AC_MSG_CHECKING([for configurable backends])
	 modlist="cairo"
	 for module in cairo-ft cairo-pdf cairo-png cairo-ps cairo-svn cairo-xlib cairo-xlib-xrender cairo-win32; do
	    if "${PKGCONF}" --exists ${module}; then
		modlist="${modlist} ${module}"
	    fi
	 done
	 AC_MSG_RESULT(${modlist})
	 CAIRO_CFLAGS=`"${PKGCONF}" --cflags ${modlist}`
	 CAIRO_LIBS=`"${PKGCONF}" --libs ${modlist}`
      else
	AC_MSG_RESULT([no])
      fi
   fi
fi
if test -z "${CAIRO_LIBS}"; then
   AC_MSG_NOTICE([CAIRO_LIBS is unset, attempting to guess it.])
   cpre=''
   for pre in /usr /usr/local /usr/X11 /usr/X11R6 /opt /sw; do
      if test -e "${pre}/include/cairo/cairo.h"; then
         cpre=${pre}; break
      fi
   done
   if test -n "${cpre}"; then
      CAIRO_CFLAGS="-I${cpre}/include/cairo"
      if test "${cpre}" = /usr; then
         CAIRO_LIBS="-lcairo"
      else
         CAIRO_LIBS="-L${cpre}/lib -lcairo"
      fi
   fi
fi

AC_MSG_NOTICE([CAIRO_CFLAGS=${CAIRO_CFLAGS}])

# Check for Rconn patch
AC_MSG_CHECKING([if R was compiled with the RConn patch])
if test -f "${R_HOME}/include/R_ext/RConn.h"; then
	AC_MSG_RESULT([yes])
	HAVE_RCONN_H="-DHAVE_RCONN_H"
else
	AC_MSG_RESULT([no])
	HAVE_RCONN_H=""
fi

CPPFLAGS="$CPPFLAGS ${CAIRO_CFLAGS} ${HAVE_RCONN_H}"

AC_CHECK_HEADER(cairo.h,,AC_MSG_ERROR([Cannot find cairo.h! Please install cairo (http://www.cairographics.org/) and/or set CAIRO_CFLAGS/LIBS correspondingly.]))

AC_MSG_CHECKING([for PNG support in rfontmetrics])
AC_LINK_IFELSE([
#include "cairo.h"
int main(void) {
#ifndef CAIRO_HAS_PNG_FUNCTIONS
#error no PNG support
#endif
    return 0;
}],[AC_MSG_RESULT([yes])] ,[AC_MSG_RESULT([no])
AC_MSG_ERROR([rfontmetrics library has no PNG support.])])

uses_ats=no
AC_MSG_CHECKING([for ATS font support in rfontmetrics])
AC_LINK_IFELSE([
#include "cairo.h"
int main(void) {
#ifndef CAIRO_HAS_ATSUI_FONT
#error no PNG support
#endif
    return 0;
}],[AC_MSG_RESULT([yes])
uses_ats=yes],[AC_MSG_RESULT([no])])

if test "xx${CAIRO_LIBS}" == "xx"; then
   if test $uses_ats == "yes"; then
      CAIRO_LIBS="-lcairo -lpng -lz -framework ApplicationServices"
   else
      CAIRO_LIBs="-lcairo -lpng -lz"
   fi
fi

AC_MSG_NOTICE([CAIRO_LIBS=${CAIRO_LIBS}])

LIBS="$LIBS ${CAIRO_LIBS}"

#AC_CHECK_LIB(cairo, cairo_create,,
#[AC_MSG_ERROR([Cannot link to cairo library. Please check config.log for details and set CAIRO_LIBS accordingly.])])

AC_SEARCH_LIBS(deflate, z)

AC_MSG_CHECKING([whether Cairo programs can be compiled])
AC_LINK_IFELSE([
#include <cairo.h>
int main(void) {
  cairo_surface_t *cs = 0;
  cairo_t *cr;
  cr = cairo_create(cs);
  return 0;
}
],[AC_MSG_RESULT(yes)],[AC_MSG_ERROR([Cannot compile a simple Cairo program. See config.log for details.])])


dnl AC_CHECK_LIB(cairo, cairo_image_surface_get_format)
dnl if test "$ac_cv_lib_cairo_cairo_image_surface_get_format" != "yes"; then
dnl   AC_MSG_ERROR([Cairo is too old: >= 1.2 is needed.])
dnl fi
AC_CHECK_DECLS([cairo_image_surface_get_format], [#include <cairo.h>])

has_cairo_ft=no
AC_MSG_CHECKING([for FreeType support in cairo])
AC_COMPILE_IFELSE([
#include <cairo.h>
#ifndef CAIRO_HAS_FT_FONT
#error nope, no ft
#endif
],[has_cairo_ft=yes])
AC_MSG_RESULT(${has_cairo_ft})

need_xtra_ft_flags=no
if test "${has_cairo_ft}" = yes; then
 AC_MSG_CHECKING([whether FreeType needs additional flags])
 AC_LINK_IFELSE([
#include <cairo.h>
#include <cairo-ft.h>
int main(void) {
   cairo_ft_font_face_create_for_pattern(0);
   return 0;
}
],[],[need_xtra_ft_flags=yes])
 AC_MSG_RESULT(${need_xtra_ft_flags})
fi

if test "${need_xtra_ft_flags}" = yes; then
 if test -n "${PKGCONF}"; then
   AC_MSG_CHECKING([whether pkg-config knows about fontconfig or freetype2])
   ftmod=''
   for module in fontconfig freetype2; do
      if "${PKGCONF}" --exists ${module}; then ftmod="${ftmod} ${module}"; fi
   done
   if test -n "${ftmod}"; then
      AC_MSG_RESULT(yes)
      FT_CPPFLAGS=`"${PKGCONF}" --cflags ${ftmod}`
      FT_LIBS=`"${PKGCONF}" --libs ${ftmod}`
   else
      AC_MSG_RESULT(no)
   fi
 fi
 if test -z "${FT_LIBS}"; then
   AC_MSG_CHECKING([whether fontconfig/freetype2 location can be guessed])
   FCI=''; FTI=''; FCL=''; FTL=''
   for pre in /usr /usr/X11 /usr/X11R6 /usr/local /opt /sw; do
     if test -z "${FCI}" -a -e "${pre}/include/fontconfig/fontconfig.h"; then
        FCI="-I${pre}/include"
	FCL="-L${pre}/lib"
     fi
     if test -z "{FTI}" -a -e "${pre}/include/freetype2/freetype/freetype.h"; then
        FTI="-I${pre}/include/freetype2"
	FTL="-L${pre}/lib"
     fi
   done
   if test "${FCI}" = -I/usr/include; then FCI=''; fi
   if test "${FCL}" = "-L/usr/lib"; then FCL=''; fi
   if test "${FTL}" = "-L/usr/lib"; then FTL=''; fi
   if test "${FTL}" = "${FCL}"; then FTL=''; fi
   if test -z "${FCI}" -a -z "${FTI}"; then
      AC_MSG_RESULT(no)
      AC_MSG_ERROR([Cannot find fontconfig/freetype2 although cairo claims to support it. Please check your cairo installation and/or update cairo if necessary or set CAIRO_CFLAGS/CAIRO_LIBS accordingly.])
   fi
   FT_CPPFLAGS="${FCI} ${FTI}"
   FT_LIBS="${FCL} ${FTL} -lfontconfig -lfreetype -lz"
   AC_MSG_RESULT([possibly])
 fi
 zLIBS="${LIBS}"
 LIBS="${LIBS} ${FT_LIBS}"
 zCPPFLAGS="${CPPFLAGS}"
 CPPFLAGS="${CPPFLAGS} ${FT_CPPFLAGS}"
 AC_MSG_CHECKING([whether additional flags work])
 AC_LINK_IFELSE([
#include <cairo.h>
#include <cairo-ft.h>
int main(void) {
   cairo_ft_font_face_create_for_pattern(0);
   return 0;
}
 ],[AC_MSG_RESULT(yes)
 CAIRO_LIBS="${CAIRO_LIBS} ${FT_LIBS}"
 CAIRO_CFLAGS="${CAIRO_CFLAGS} ${FT_CPPFLAGS}"
 ],[
 AC_MSG_RESULT(no)
 AC_MSG_ERROR([Cannot use cairo-ft backend, although cairo claims it is working. Please check your caito installation and/or update cairo if necessary or set CAIRO_CFLAGS/CAIRO_LIBS accordingly.])
 ])
fi

# --- check for JPEG support ---
AC_MSG_CHECKING([wheter libjpeg works])
zLIBS="${LIBS}"
LIBS="${LIBS} -ljpeg"
AC_LINK_IFELSE([
#include <stdio.h>
#include <jpeglib.h>
int main(void) {
  struct jpeg_compress_struct cinfo;
  jpeg_create_compress(&cinfo);
  return 0;
}
],[ AC_MSG_RESULT([yes])
    AC_DEFINE(SUPPORTS_JPEG, 1, [Define to 1 if libjpeg is present and working])],
  [ AC_MSG_RESULT(no)
    LIBS="${zLIBS}"])

# --- check for TIFF support
AC_MSG_CHECKING([wheter libtiff works])
zLIBS="${LIBS}"
LIBS="${LIBS} -ltiff"
AC_LINK_IFELSE([
#include <tiffio.h>
int main(void) {
  TIFF *out = TIFFOpen("new.tif", "w");
  TIFFSetField (out, TIFFTAG_IMAGEWIDTH, 100);
  return 0;
}
],[ AC_MSG_RESULT([yes])
    AC_DEFINE(SUPPORTS_TIFF, 1, [Define to 1 if libtiff is present and working])],
  [ AC_MSG_RESULT(no)
    LIBS="${zLIBS}"])

AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
