# Corpus de 2a sous les prototypes (i) et (ii) de #606 ; reprend les definitions de sonde606.R sans forger.
a <- commandArgs(TRUE); moteur <- a[1]; chargeur <- a[2]; corpus <- a[3]; sonde <- a[4]
lignes <- readLines(sonde); fin <- grep("^forge <- function", lignes) - 1L
eval(parse(text = c("a <- c(moteur, chargeur, tempfile())", lignes[2:fin][-1])))
fs <- sort(list.files(corpus, pattern = "\\.xlsx$", recursive = TRUE, full.names = TRUE))
lit <- function(f) tryCatch(E$engine_lire_xlsx(f), error = function(e) paste("REFUS:", conditionMessage(e)))
aval <- function(r, f) if (!is.data.frame(r)) r else if (grepl("triangle", f)) E$engine_lire_triangle(r) else E$engine_lire_donnees_csv(r)
n_ok <- 0
for (f in fs) {
  out <- lapply(c("avant", "i", "ii"), function(m) { mode(m); r <- lit(f); list(r = r, a = aval(r, f)) })
  same <- identical(out[[1]], out[[2]]) && identical(out[[1]], out[[3]])
  n_ok <- n_ok + same
  cat(sprintf("%-70s %s %s\n", sub(paste0(corpus, "/"), "", f, fixed = TRUE), if (is.data.frame(out[[1]]$r)) "lu" else "refus", if (same) "identical" else "DIFFERENT"))
}
cat("identiques (avant = i = ii, lecture et aval) :", n_ok, "sur", length(fs), "\n"); mode("avant")
