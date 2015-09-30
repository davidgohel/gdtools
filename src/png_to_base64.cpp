#include <Rcpp.h>

#include <stdio.h>
#include <stdlib.h>
#include "cairo.h"
#include <fstream>

using namespace Rcpp;
using namespace std;

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


//' Encode a png file into base64.
//'
//' @param filename name of the file to create
//' @examples
//' r <- as.raster(matrix(hcl(50, 80, seq(50, 80, 10)),
//'  nrow = 4, ncol = 5))
//'
//' t <- tempfile()
//' write_raster(r, t, width = 50, height = 50)
//' png_as_base64(t)
//' @export
// [[Rcpp::export]]
String png_as_base64(std::string filename) {

  ifstream ifs(filename.c_str(), ios::binary | ios::ate);
  if (!ifs.good())
    stop("Failed to open %s", filename);

  ifstream::pos_type pos = ifs.tellg();

  std::vector<char> result(pos);

  ifs.seekg(0, ios::beg);
  ifs.read(&result[0], pos);
  ifs.close();

  String str_out = base64_encode(result);
  return str_out;
}
