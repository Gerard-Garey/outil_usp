setwd("/home/user/outil_usp")
source("tests/outils_tests.R")
a <- commandArgs(TRUE); etiq <- a[1]; patchs <- a[-1]
env <- environment(run_engine)
for (p in patchs) sys.source(p, envir = env)
for (nom in c("premium", "reserve2")) {
  invisible(CAS[[nom]]())
  t <- sapply(1:3, function(i) system.time(CAS[[nom]]())[[3]])
  cat(sprintf("%-8s %-9s %s  mediane %.2f s\n", etiq, nom, paste(sprintf("%.2f", t), collapse = " "), median(t)))
}
