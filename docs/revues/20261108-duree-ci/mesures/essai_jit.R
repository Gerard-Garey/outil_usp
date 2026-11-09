setwd("/home/user/outil_usp")
source("tests/outils_tests.R")
mode <- commandArgs(TRUE)[1]; nom <- commandArgs(TRUE)[2]
if (mode == "precompile") {
  t <- system.time({
    env <- environment(run_engine)
    for (n in ls(env, all.names = TRUE)) {
      f <- get(n, env)
      if (is.function(f) && !is.primitive(f)) assign(n, compiler::cmpfun(f), envir = env)
    }
  })
  cat("precompilation :", t[[3]], "s\n")
}
for (k in 1:2) { t <- system.time(r <- CAS[[nom]]()); cat(mode, nom, "appel", k, ":", t[[3]], "s\n") }
saveRDS(nettoyer <- r, sprintf("/tmp/duree-ci/jit_%s_%s.rds", mode, nom))
