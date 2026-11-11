for (f in list.files("tests/reference", full.names=TRUE)) {
  x <- readRDS(f); cat("==", f, class(x), "\n"); cat(names(x), "\n")
  if (!is.null(x$tests)) { cat("tests class:", class(x$tests), " dim:", paste(dim(x$tests), collapse="x"), "\n"); if (is.data.frame(x$tests)) cat(names(x$tests), "\n") }
}
