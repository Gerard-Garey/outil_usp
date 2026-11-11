`%||%` <- function(a,b) if (is.null(a)) b else a
for (f in list.files("tests/reference", full.names=TRUE)) {
  nm <- sub("\\.rds$","",basename(f)); x <- readRDS(f)
  if (nm=="premium") cat(names(x$tests[[1]]),"\n")
  out <- do.call(rbind, lapply(seq_along(x$tests), function(i) { t <- x$tests[[i]]
    data.frame(i=i, famille=t$famille, test=t$test, H0=t$H0 %||% "", loi=t$loi %||% "", detail=t$detail %||% "", inoperant=isTRUE(t$inoperant), stringsAsFactors=FALSE) }))
  saveRDS(out, file.path(Sys.getenv("S"), paste0("dump_", nm, ".rds")))
  cat(nm, nrow(out), "\n")
}
