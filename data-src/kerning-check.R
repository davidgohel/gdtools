# Diagnostic of kerning on the fonts installed on the machine (first face of
# each file). Run from the package root:
#
#   pkgload::load_all(); d <- source("data-src/kerning-check.R")$value
#
# Not a test and no reference engine: it lists, for each font,
#
# - the table used ('kerx', 'GPOS', 'kern' or none);
# - the kerning content of the font that is not read (contextual lookups,
#   other formats of 'kerx' or Apple 'kern', variation subtables): for these
#   fonts, the widths may miss some kerning;
# - fonts that cannot be measured;
# - suspicious values, to look at by hand: kerning larger than 30% of the
#   width of a string, or positive kerning larger than 10%.
#
# The tables are inspected here in R, independently of src/kerning.cpp.

local({
  u8 <- function(r, o) as.integer(r[o + 1])
  u16 <- function(r, o) as.integer(r[o + 1]) * 256L + as.integer(r[o + 2])
  u32 <- function(r, o) sum(as.numeric(r[o + 1:4]) * c(16777216, 65536, 256, 1))
  tag <- function(r, o) {
    x <- r[o + 1:4]
    if (any(x == as.raw(0))) "" else rawToChar(x)
  }
  tables <- function(r, off) {
    out <- list()
    for (i in seq_len(u16(r, off + 4))) {
      p <- off + 12 + (i - 1) * 16
      out[[tag(r, p)]] <- u32(r, p + 8)
    }
    out
  }

  # kerning content of a font file (first face) that is not read
  inspect <- function(path) {
    r <- readBin(path, "raw", file.size(path))
    off <- if (tag(r, 0) == "ttcf") u32(r, 12) else 0
    tb <- tables(r, off)
    not_read <- character()
    gpos_kern <- FALSE
    if (!is.null(tb$GPOS)) {
      g <- tb$GPOS
      fl <- g + u16(r, g + 6)
      ll <- g + u16(r, g + 8)
      lookups <- integer()
      for (i in seq_len(u16(r, fl))) {
        rec <- fl + 2 + (i - 1) * 6
        if (tag(r, rec) == "kern") {
          gpos_kern <- TRUE
          ft <- fl + u16(r, rec + 4)
          for (j in seq_len(u16(r, ft + 2))) {
            lookups <- c(lookups, u16(r, ft + 4 + (j - 1) * 2))
          }
        }
      }
      for (li in unique(lookups)) {
        lk <- ll + u16(r, ll + 2 + li * 2)
        type <- u16(r, lk)
        if (type == 9 && u16(r, lk + 4) > 0) {
          st <- lk + u16(r, lk + 6)
          type <- u16(r, st + 2)
        }
        if (!type %in% c(1, 2)) {
          not_read <- c(not_read, paste0("GPOS lookup type ", type))
        }
      }
    }
    if (!is.null(tb$kerx)) {
      k <- tb$kerx
      p <- k + 8
      for (s in seq_len(u32(r, k + 4))) {
        cov <- u32(r, p + 4)
        fmt <- cov %% 256
        horizontal <- cov < 2^29
        if (horizontal && fmt != 0) not_read <- c(not_read, paste0("kerx format ", fmt))
        if (cov %/% 2^29 %% 2 == 1) not_read <- c(not_read, "kerx variation")
        p <- p + u32(r, p)
      }
      source <- "kerx"
    } else if (gpos_kern) {
      source <- "GPOS"
    } else if (!is.null(tb$kern)) {
      k <- tb$kern
      if (u16(r, k) == 0) {
        p <- k + 4
        for (s in seq_len(u16(r, k + 2))) {
          fmt <- u8(r, p + 4)
          if (fmt != 0) not_read <- c(not_read, paste0("kern format ", fmt))
          p <- p + max(u16(r, p + 2), 14 + 6 * u16(r, p + 6))
        }
      } else {
        p <- k + 8
        for (s in seq_len(u32(r, k + 4))) {
          cov <- u16(r, p + 4)
          fmt <- cov %% 256
          if (cov < 0x2000 && !fmt %in% c(0, 2, 3)) {
            not_read <- c(not_read, paste0("Apple kern format ", fmt))
          }
          if (cov %/% 0x2000 %% 2 == 1) not_read <- c(not_read, "Apple kern variation")
          p <- p + u32(r, p)
        }
      }
      source <- "kern"
    } else {
      source <- "none"
    }
    list(source = source, not_read = paste(unique(not_read), collapse = ", "))
  }

  set.seed(3)
  latin <- c(LETTERS, letters)
  greek <- intToUtf8(c(0x391:0x3A1, 0x3A3:0x3A9, 0x3AC:0x3CE), multiple = TRUE)
  cyr <- intToUtf8(0x410:0x44F, multiple = TRUE)
  acc <- strsplit("àâäéèêëîïôöùûüçÀÉÈÊÇñÑåøæœß", "")[[1]]
  mk <- function(pool, n) {
    vapply(seq_len(n), function(i) paste(sample(pool, sample(2:9, 1), TRUE), collapse = ""), "")
  }
  hard <- c("AVATAR", "To", "Today", "WAVE", "LTA", "Yo", "P.", "y,", "AV AV", "T. Y.")
  words <- c(hard, mk(latin, 300), mk(c(latin, acc), 300), mk(greek, 300), mk(cyr, 300))
  n <- length(words)

  sf <- systemfonts::system_fonts()
  sf <- sf[!duplicated(sf$path) & grepl("\\.(ttf|otf|ttc)$", sf$path, ignore.case = TRUE), ]
  lib <- unlist(lapply(
    fontquiver::font_families("Liberation")[c("sans", "serif", "mono")],
    function(f) vapply(f[c("plain", "bold", "italic", "bolditalic")], function(x) x$ttf, "")
  ))
  files <- data.frame(family = c(sf$family, rep("Liberation", length(lib))), path = c(sf$path, lib))

  rows <- lapply(seq_len(nrow(files)), function(i) {
    p <- files$path[i]
    info <- tryCatch(inspect(p), error = function(e) list(source = "?", not_read = "table not inspected"))
    measure <- function(kerning) {
      glyph_metrics_(words, rep("", n), rep(12, n), rep(FALSE, n), rep(FALSE, n), rep(p, n), kerning = kerning)$width
    }
    t0 <- Sys.time()
    res <- tryCatch(
      withCallingHandlers(
        list(plain = measure(FALSE), kerned = measure(TRUE)),
        warning = function(w) invokeRestart("muffleWarning")
      ),
      error = function(e) conditionMessage(e)
    )
    seconds <- as.numeric(Sys.time() - t0, units = "secs")
    if (is.character(res)) {
      return(data.frame(family = files$family[i], file = basename(p), source = info$source,
        not_read = info$not_read, error = res, kerned_words = NA, max_ratio = NA,
        max_positive = NA, worst = "", seconds = seconds))
    }
    kern <- res$kerned - res$plain
    ratio <- ifelse(res$plain > 0, kern / res$plain, 0)
    data.frame(family = files$family[i], file = basename(p), source = info$source,
      not_read = info$not_read, error = if (anyNA(res$kerned)) "NA width" else "",
      kerned_words = sum(abs(kern) > 1e-9), max_ratio = max(abs(ratio)),
      max_positive = max(ratio), worst = words[which.max(abs(ratio))], seconds = seconds)
  })
  d <- do.call(rbind, rows)

  cat("files:", nrow(d), "\n")
  cat("table used:\n")
  print(table(d$source))
  cat("\nfonts with kerning content that is not read:\n")
  print(d[d$not_read != "", c("family", "file", "source", "not_read", "kerned_words")], row.names = FALSE)
  cat("\nfonts that cannot be measured:\n")
  print(d[d$error != "", c("family", "file", "error")], row.names = FALSE)
  cat("\nsuspicious values (kerning > 30% of the width, or positive > 10%):\n")
  print(d[d$error == "" & (d$max_ratio > 0.3 | d$max_positive > 0.1),
    c("family", "file", "source", "max_ratio", "max_positive", "worst")], row.names = FALSE)
  cat("\nslowest files (seconds for", 2 * n, "strings):\n")
  print(head(d[order(-d$seconds), c("family", "file", "source", "seconds")], 5), row.names = FALSE)
  invisible(d)
})
