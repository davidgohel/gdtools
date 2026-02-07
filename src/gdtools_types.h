#ifndef __GDTOOLS_TYPES__
#define __GDTOOLS_TYPES__

#include <string>
#include <map>

class FontMetric {
public:
  double height, width, ascent, descent;
  FontMetric() : height(0), width(0), ascent(0), descent(0) {}
};

typedef struct _cairo_font_face cairo_font_face_t;

class CairoContext {
  struct CairoContext_;
  CairoContext_* cairo_;
  typedef std::map<std::string, cairo_font_face_t*> fontCache;

public:
  CairoContext();
  ~CairoContext();

  void cacheFont(fontCache& cache, std::string& key, std::string fontfile, int fontindex);
  void setFont(std::string fontname = "sans", double fontsize = 12,
               bool bold = false, bool italic = false,
               std::string fontfile = "");

  FontMetric getExtents(std::string x);

};

#endif
