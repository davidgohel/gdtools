#include <Rcpp.h>
#include "cairo.h"
using namespace Rcpp;
using namespace std;


// [[Rcpp::export]]
void raster_to_png(IntegerVector red, IntegerVector green, IntegerVector blue,
		IntegerVector alpha, int w, int h, double width, double height,
		int interpolate, std::string filename) {

	int i;
	int img_width = (int) width;
	int img_height = (int) height;

	cairo_surface_t *basesurface = cairo_image_surface_create(
			CAIRO_FORMAT_ARGB32, img_width, img_height);
	cairo_t *cc = cairo_create(basesurface);

	if (w != img_width || h != img_height)
		cairo_scale(cc, width / w, height / h);

	std::vector<unsigned char> imageData(4 * w * h);
	for (i = 0; i < w * h; i++) {
		int calpha = alpha[i];
		int cred = red[i];
		int cgreen = green[i];
		int cblue = blue[i];

		imageData[i * 4 + 3] = calpha;
		imageData[i * 4 + 2] = cred;
		imageData[i * 4 + 1] = cgreen;
		imageData[i * 4 + 0] = cblue;
	}

	int stride;
	stride = cairo_format_stride_for_width(CAIRO_FORMAT_ARGB32, w);
	cairo_surface_t *image = cairo_image_surface_create_for_data(&imageData[0],
			CAIRO_FORMAT_ARGB32, w, h, stride);

	cairo_set_source_surface(cc, image, 0, 0);
	if (interpolate > 0) {
		cairo_pattern_set_filter(cairo_get_source(cc), CAIRO_FILTER_BILINEAR);
		cairo_pattern_set_extend(cairo_get_source(cc), CAIRO_EXTEND_PAD);
	} else
		cairo_pattern_set_filter(cairo_get_source(cc), CAIRO_FILTER_NEAREST);

	cairo_new_path(cc);
	cairo_rectangle(cc, 0, 0, img_width, img_height);
	cairo_clip(cc);
	cairo_paint(cc);
	cairo_destroy(cc);

	cairo_surface_write_to_png(basesurface, filename.c_str());
	cairo_surface_destroy(image);
	cairo_surface_destroy(basesurface);
}



