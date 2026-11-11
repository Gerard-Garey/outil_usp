S <- Sys.getenv("S")
suppressMessages({source("R/charger_moteur.R"); m <- charger_moteur()})
env <- environment(m$run_engine)
for (nm in c("DETAIL_P_FAMILLE","DETAIL_P_GLOBALE")) { s <- get(nm, env); cat(nm, "nchar =", nchar(s), "\n", s, "\n") }
cas <- c("premium","premium_ii6","premium_interieur","premium_net","reserve1","reserve2")
for (n in cas) { r <- readRDS(file.path(S, paste0("dump_", n, ".rds")))
  f <- r$test[grepl("^p de famille", r$test)]; g <- r$test[grepl("^p globale", r$test)]
  cat(n, "nlignes", nrow(r), " famille:", length(f), " globale:", length(g), "\n")
  d <- r$detail[grepl("^p de famille|^p globale", r$test)]; cat("   nchar detail:", paste(nchar(d), collapse=","), "\n")
  cat("   contient 'Puissance'/'puissance':", sum(grepl("uissance", d)), "\n")
  if (n=="premium") for (x in r[grepl("^p de famille|^p globale", r$test), "test"]) cat("    test:", x, "\n")
  if (n=="reserve2") print(r[grepl("^p de famille|^p globale", r$test), c("i","test")])
}
