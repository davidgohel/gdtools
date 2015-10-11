#include <Rcpp.h>

#include <stdio.h>
#include <stdlib.h>
#include "cairo.h"
#include <fstream>

using namespace Rcpp;
using namespace std;

// [[Rcpp::interfaces(r, cpp)]]

#define R_RED(col)  (((col)    )&255)
#define R_GREEN(col)    (((col)>> 8)&255)
#define R_BLUE(col) (((col)>>16)&255)
#define R_ALPHA(col)    (((col)>>24)&255)

static const std::string base64_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789+/";

std::string base64_encode(std::vector<char> data) {

  unsigned int in_len = data.size();
  unsigned char* bytes_to_encode =
    reinterpret_cast<unsigned char *>(data.data());

  std::string ret;
  int i = 0;
  int j = 0;
  unsigned char char_array_3[3];
  unsigned char char_array_4[4];

  while (in_len--) {
    char_array_3[i++] = *(bytes_to_encode++);
    if (i == 3) {
      char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
      char_array_4[1] = ((char_array_3[0] & 0x03) << 4)
        + ((char_array_3[1] & 0xf0) >> 4);
      char_array_4[2] = ((char_array_3[1] & 0x0f) << 2)
        + ((char_array_3[2] & 0xc0) >> 6);
      char_array_4[3] = char_array_3[2] & 0x3f;

      for (i = 0; (i < 4); i++)
        ret += base64_chars[char_array_4[i]];
      i = 0;
    }
  }

  if (i) {
    for (j = i; j < 3; j++)
      char_array_3[j] = '\0';

    char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
    char_array_4[1] = ((char_array_3[0] & 0x03) << 4)
      + ((char_array_3[1] & 0xf0) >> 4);
    char_array_4[2] = ((char_array_3[1] & 0x0f) << 2)
      + ((char_array_3[2] & 0xc0) >> 6);
    char_array_4[3] = char_array_3[2] & 0x3f;

    for (j = 0; (j < i + 1); j++)
      ret += base64_chars[char_array_4[j]];

    while ((i++ < 3))
      ret += '=';

  }

  return ret;

}


static cairo_status_t stream_data(void* closure, const unsigned char* data, unsigned int length)
{
  vector<char>* in = reinterpret_cast<vector<char>*>(closure);
  for (unsigned int i = 0; i < length; ++i)
    in->push_back(data[i]);
  return CAIRO_STATUS_SUCCESS;
}


// [[Rcpp::export]]
std::string raster_to_str(std::vector<unsigned int> raster,
  int w, int h, double width, double height, int interpolate) {

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
    imageData[i * 4 + 3] = R_ALPHA(raster[i]);
    imageData[i * 4 + 2] = R_RED(raster[i]);
    imageData[i * 4 + 1] = R_GREEN(raster[i]);
    imageData[i * 4 + 0] = R_BLUE(raster[i]);
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

  vector<char> in;
  cairo_surface_write_to_png_stream(basesurface, stream_data, &in);

  cairo_surface_destroy(image);
  cairo_surface_destroy(basesurface);
  std::string out = base64_encode(in);
  return out;
}

vector<unsigned int> convert_hex(vector<string> hcode) {
  vector<unsigned int> bit_coded_colors(hcode.size());

  for( int i = 0 ; i < hcode.size() ; i++ ){
    std::stringstream str_abgr;
    unsigned int bit_coded_color;
    string in = "0x";

    if(  hcode[i].size() == 9 ) {
      in += hcode[i].substr(7, 2 );
    } else in += "FF";

    in += hcode[i].substr(5, 2 );
    in += hcode[i].substr(3, 2 );
    in += hcode[i].substr(1, 2 );

    str_abgr << std::hex << in;
    str_abgr >> bit_coded_color;

    bit_coded_colors[i] = bit_coded_color;
  }
  return bit_coded_colors;
}


// [[Rcpp::export]]
std::string base64_raster_encode(CharacterVector raster_, int w, int h, double width, double height,
                            int interpolate) {
  vector<string> raster = Rcpp::as<vector<string> >(raster_);
  vector<unsigned int> out = convert_hex(raster);
  return raster_to_str(out, w, h, width, height, interpolate);
}

// Encode a file into base64.
// [[Rcpp::export]]
std::string base64_file_encode(std::string filename) {
  ifstream ifs(filename.c_str(), ios::binary | ios::ate);
  if (!ifs.good())
    stop("Failed to open %s", filename);

  ifstream::pos_type pos = ifs.tellg();

  std::vector<char> result(pos);

  ifs.seekg(0, ios::beg);
  ifs.read(&result[0], pos);
  ifs.close();

  return base64_encode(result);
}
