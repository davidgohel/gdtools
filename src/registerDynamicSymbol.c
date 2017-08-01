#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME: 
   Check these declarations against the C/Fortran source code.
*/

/* .Call calls */
extern SEXP _gdtools_base64_file_encode(SEXP);
extern SEXP _gdtools_base64_raster_encode(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _gdtools_base64_string_encode(SEXP);
extern SEXP _gdtools_context_create();
extern SEXP _gdtools_context_extents(SEXP, SEXP);
extern SEXP _gdtools_context_set_font(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _gdtools_match_family_(SEXP, SEXP, SEXP);
extern SEXP _gdtools_match_font_(SEXP, SEXP, SEXP);
extern SEXP _gdtools_raster_png_(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _gdtools_raster_to_file(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _gdtools_raster_to_str(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _gdtools_RcppExport_registerCCallable();
extern SEXP _gdtools_str_extents(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _gdtools_str_metrics(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _gdtools_sys_fonts();
extern SEXP _gdtools_version_cairo_();
extern SEXP _gdtools_version_fontconfig();
extern SEXP _gdtools_version_freetype();

static const R_CallMethodDef CallEntries[] = {
    {"_gdtools_base64_file_encode",           (DL_FUNC) &_gdtools_base64_file_encode,           1},
    {"_gdtools_base64_raster_encode",         (DL_FUNC) &_gdtools_base64_raster_encode,         6},
    {"_gdtools_base64_string_encode",         (DL_FUNC) &_gdtools_base64_string_encode,         1},
    {"_gdtools_context_create",               (DL_FUNC) &_gdtools_context_create,               0},
    {"_gdtools_context_extents",              (DL_FUNC) &_gdtools_context_extents,              2},
    {"_gdtools_context_set_font",             (DL_FUNC) &_gdtools_context_set_font,             6},
    {"_gdtools_match_family_",                (DL_FUNC) &_gdtools_match_family_,                3},
    {"_gdtools_match_font_",                  (DL_FUNC) &_gdtools_match_font_,                  3},
    {"_gdtools_raster_png_",                  (DL_FUNC) &_gdtools_raster_png_,                  7},
    {"_gdtools_raster_to_file",               (DL_FUNC) &_gdtools_raster_to_file,               7},
    {"_gdtools_raster_to_str",                (DL_FUNC) &_gdtools_raster_to_str,                6},
    {"_gdtools_RcppExport_registerCCallable", (DL_FUNC) &_gdtools_RcppExport_registerCCallable, 0},
    {"_gdtools_str_extents",                  (DL_FUNC) &_gdtools_str_extents,                  6},
    {"_gdtools_str_metrics",                  (DL_FUNC) &_gdtools_str_metrics,                  6},
    {"_gdtools_sys_fonts",                    (DL_FUNC) &_gdtools_sys_fonts,                    0},
    {"_gdtools_version_cairo_",               (DL_FUNC) &_gdtools_version_cairo_,               0},
    {"_gdtools_version_fontconfig",           (DL_FUNC) &_gdtools_version_fontconfig,           0},
    {"_gdtools_version_freetype",             (DL_FUNC) &_gdtools_version_freetype,             0},
    {NULL, NULL, 0}
};

void R_init_gdtools(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
