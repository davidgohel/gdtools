#include <Rcpp.h>
#include <cairo.h>
#include <string.h>

// [[Rcpp::interfaces(r, cpp)]]
using namespace Rcpp;

struct FontMetric {
  double height, width, ascent, descent;
};

class TextExtents {
  cairo_surface_t* surface_;
  cairo_t* context_;

public:

  TextExtents(std::string fontname = "sans", double fontsize = 12,
              bool bold = false, bool italic = false) {

    surface_ = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 100, 100);
    context_ = cairo_create(surface_);

    cairo_select_font_face(context_,
      fontname.c_str(),
      italic ? CAIRO_FONT_SLANT_ITALIC : CAIRO_FONT_SLANT_NORMAL,
      bold ? CAIRO_FONT_WEIGHT_BOLD : CAIRO_FONT_WEIGHT_NORMAL
    );

    cairo_set_font_size(context_, fontsize);
  }

  ~TextExtents() {
    cairo_surface_destroy(surface_);
    cairo_destroy(context_);
  }

  FontMetric extents(std::string x) {
    cairo_text_extents_t te;
    cairo_text_extents(context_, x.c_str(), &te);

    FontMetric fm;
    fm.height = te.height;
    fm.width = te.x_advance;
    fm.ascent = -te.y_bearing;
    fm.descent = te.height + te.y_bearing;

    return fm;
  }

};

//' Compute string extents.
//'
//' Determines the width and height of a bounding box that's big enough
//' to (just) enclose the provided text.
//'
//' @param x Character vector of of strings to measure
//' @param bold,italic Is text bold/italic?
//' @param fontname Font name
//' @param fontsize Font size (in pixels)
//' @examples
//' str_extents(letters)
//' str_extents("Hello World!", bold = TRUE, italic = FALSE,
//'   fontname = "Sans", fontsize = 12)
//' @export
// [[Rcpp::export]]
NumericMatrix str_extents(CharacterVector x, std::string fontname = "sans",
                          int fontsize = 12, int bold = false,
                          int italic = false) {
  int n = x.size();
  TextExtents te(fontname, fontsize, bold, italic);
  NumericMatrix out(n, 2);

  for (int i = 0; i < n; ++i) {
    if (x[i] == NA_STRING) {
      out(i, 0) = NA_REAL;
      out(i, 1) = NA_REAL;
    } else {
      std::string str(Rf_translateCharUTF8(x[i]));
      FontMetric fm = te.extents(str);

      out(i, 0) = fm.width;
      out(i, 1) = fm.height;
    }
  }

  return out;
}

//' Get font metrics for a string.
//'
//' @return A named numeric vector
//' @inheritParams str_extents
//' @examples
//' str_metrics("Hello World!")
//' @export
// [[Rcpp::export]]
NumericVector str_metrics(std::string x, std::string fontname = "sans",
                          int fontsize = 12, int bold = false,
                          int italic = false) {

  TextExtents te(fontname, fontsize, bold, italic);
  FontMetric fm = te.extents(x);

  return NumericVector::create(
    _["width"] = fm.width,
    _["ascent"] = fm.ascent,
    _["descent"] = fm.descent
  );
}
