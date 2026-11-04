# Text measurement from glyph metrics, without Cairo.
#
# For each distinct font, the glyphs used by the strings are measured once
# with systemfonts::glyph_info() at a large reference size, then scaled to the
# requested size. The width is the sum of the glyph advances (no kerning, as
# Cairo's toy text API), the ascent and the descent are those of the union of
# the ink boxes of the glyphs.
#
# Values are returned in points.

# glyph_info() returns integers (pixels): measuring at a large size and a
# high resolution keeps the rounding error below 0.001 point per glyph at
# 10 points. 100 points at 1e4 dpi is about 13900 pixels per em, close to the
# largest size FreeType accepts (1000 points fails with error 23).
glyph_ref_size <- 100
glyph_ref_res <- 1e4

glyph_metrics_ <- function(x, fontname, fontsize, bold, italic, fontfile) {
  n <- length(x)
  width <- rep(NA_real_, n)
  ascent <- rep(NA_real_, n)
  descent <- rep(NA_real_, n)

  x <- enc2utf8(x)
  has_file <- !is.na(fontfile) & nzchar(fontfile)
  key <- ifelse(
    has_file,
    paste("file", fontfile, sep = "\r"),
    paste("name", fontname, bold, italic, sep = "\r")
  )

  for (k in unique(key)) {
    i <- which(key == k)
    i <- i[!is.na(x[i])]
    if (!length(i)) {
      next
    }
    j <- i[1]
    if (has_file[j]) {
      path <- fontfile[j]
      index <- 0L
    } else {
      font <- systemfonts::match_fonts(
        family = fontname[j],
        italic = italic[j],
        weight = if (bold[j]) "bold" else "normal"
      )
      path <- font$path
      index <- font$index
    }

    codes <- lapply(x[i], utf8ToInt)
    # invalid UTF-8 gives NA: measured as an empty string, as Cairo does
    invalid <- vapply(codes, anyNA, FALSE)
    codes[invalid] <- list(integer(0))

    m <- tryCatch(
      measure_codes_(codes, path = path, index = index),
      error = function(e) {
        # The file found by systemfonts may not be readable by its FreeType,
        # e.g. reserved macOS system fonts. Same fallback as ragg: warn and
        # use the default sans-serif font.
        label <- if (has_file[j]) fontfile[j] else fontname[j]
        warning("Unable to load font: ", label, ", using 'sans' instead.",
          call. = FALSE
        )
        fallback <- systemfonts::match_fonts(
          family = "sans",
          italic = italic[j],
          weight = if (bold[j]) "bold" else "normal"
        )
        measure_codes_(codes, path = fallback$path, index = fallback$index)
      }
    )
    scale <- fontsize[i] / glyph_ref_size
    width[i] <- m$width * scale
    ascent[i] <- m$ascent * scale
    descent[i] <- m$descent * scale
  }

  data.frame(
    width = width,
    ascent = ascent,
    descent = descent,
    stringsAsFactors = FALSE
  )
}

# Measure strings given as lists of code points, with one font, at the
# reference size. Returns width, ascent and descent in points.
measure_codes_ <- function(codes, path, index) {
  n <- length(codes)
  out <- list(
    width = numeric(n),
    ascent = numeric(n),
    descent = numeric(n)
  )
  lens <- lengths(codes)
  if (!any(lens > 0)) {
    return(out)
  }

  all_codes <- unlist(codes, use.names = FALSE)
  string_id <- rep.int(seq_len(n), lens)
  uniq <- unique(all_codes)

  info <- systemfonts::glyph_info(
    glyphs = intToUtf8(uniq, multiple = TRUE),
    path = path,
    index = index,
    size = glyph_ref_size,
    res = glyph_ref_res
  )
  to_pt <- 72 / glyph_ref_res
  advance <- info$x_advance * to_pt
  top <- info$y_bearing * to_pt
  bottom <- (info$height - info$y_bearing) * to_pt
  # glyphs without ink (spaces) do not contribute to the ink box
  has_ink <- info$height > 0

  pos <- match(all_codes, uniq)

  w <- rowsum(advance[pos], string_id, reorder = TRUE)
  out$width[as.integer(rownames(w))] <- w[, 1]

  inked <- has_ink[pos]
  if (any(inked)) {
    out$ascent <- group_max_(top[pos][inked], string_id[inked], n)
    out$descent <- group_max_(bottom[pos][inked], string_id[inked], n)
  }
  out
}

# Maximum of `value` by `group` (integers in 1..n); 0 for empty groups.
group_max_ <- function(value, group, n) {
  out <- numeric(n)
  o <- order(group, value)
  last <- !duplicated(group[o], fromLast = TRUE)
  out[group[o][last]] <- value[o][last]
  out
}
