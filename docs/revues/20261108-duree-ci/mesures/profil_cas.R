setwd("/home/user/outil_usp")
source("tests/outils_tests.R")
args <- commandArgs(TRUE)
for (nom in args) {
  # premier appel (caches froids) puis second (caches chauds)
  for (k in 1:2) {
    f <- sprintf("/tmp/duree-ci/rprof_%s_%d.out", nom, k)
    Rprof(f, interval = 0.01, line.profiling = FALSE)
    t <- system.time(r <- CAS[[nom]]())
    Rprof(NULL)
    cat(sprintf("%s appel %d : %.1f s ecoule, %.1f s user\n", nom, k, t[["elapsed"]], t[["user.self"]]))
    s <- summaryRprof(f)
    print(head(s$by.self, 15)); print(head(s$by.total, 40))
  }
}
