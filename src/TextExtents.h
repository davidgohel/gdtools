#ifndef GDTOOLS_TEXTEXTENTS
#define GDTOOLS_TEXTEXTENTS

struct FontMetric {
  double height, width, ascent, descent;
};

class TextExtents {
  struct CairoContext;
  CairoContext* cairo_;

public:

  TextExtents();

  void setFont(std::string fontname = "sans", double fontsize = 12,
    bool bold = false, bool italic = false);

  ~TextExtents();

  FontMetric extents(std::string x);

};

#endif
