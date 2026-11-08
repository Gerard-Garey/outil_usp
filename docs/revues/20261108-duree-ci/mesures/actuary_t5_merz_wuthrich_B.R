source("R/charger_moteur.R"); charger_moteur()
RACINE <- "."
tri_ref <- local({ d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv")); m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m) })
t5 <- tri_ref[1:5, 1:5]; t5[row(t5) + col(t5) > 6] <- NA
for (cfg in list(c(99,0.10), c(99,0.20), c(199,0.10), c(499,0.10))) {
  tm <- system.time(r <- run_engine(methode="reserve2", triangle=t5, segment=1, annexe="II", B=cfg[1], alpha=cfg[2]))
  d <- engine_table_tests(r); ca <- d[d$test=="Effets d'annee calendaire (test de Mack)",]
  cat(sprintf("B=%d alpha=%.2f t=%.1fs p=%.4f pmm=%.4f verdict=%s inop=%s inatt=%s\n", cfg[1], cfg[2], tm[3], ca$p_retenue, ca$p_min_mc, ca$verdict, ca$inoperant, grepl("inatteignable", ca$commentaire)))
}
