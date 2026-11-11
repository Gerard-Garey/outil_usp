S <- Sys.getenv("S")
suppressMessages({source("R/charger_moteur.R"); m <- charger_moteur()})
env <- new.env(parent = environment(m$run_engine))
ex <- parse("tests/unitaires/outils_unitaires.R", keep.source = FALSE)
want <- c("PLAFOND_TEXTE_PROPRE","PHRASES_MAX","ABREV_FIN_PHRASE_514","compter_phrases","rx_fixe",".rx_motif",".rx_par",".rx_num",".rx_b_effectif","MENTIONS","texte_propre")
for (e in ex) if (is.call(e) && identical(e[[1]], as.name("<-")) && as.character(e[[2]])[1] %in% want) eval(e, env)
cas <- c("premium","premium_ii6","premium_interieur","premium_net","reserve1","reserve2")
ajout_f <- "Puissance non mesuree a T = 8 : une p de famille elevee n'atteste pas l'adequation des hypotheses de la famille."
ajout_g <- "Puissance non mesuree a T = 8 : une p globale elevee n'atteste pas l'adequation du modele."
cat("nchar ajout_f:", nchar(ajout_f), " ajout_g:", nchar(ajout_g), "\n")
for (n in cas) { r <- readRDS(file.path(S, paste0("dump_", n, ".rds")))
  k <- which(grepl("^p de famille|^p globale", r$test))
  for (i in k) { d <- r$detail[i]; tp <- env$texte_propre(d)
    glob <- grepl("^p globale", r$test[i])
    # insertion "avant Diagnostic sans verdict" selon l'issue
    d2 <- paste(if (glob) ajout_g else ajout_f, d); tp2 <- env$texte_propre(d2)
    cat(sprintf("%-18s i=%2d %-8s avant: %d phr %3d car | apres (proposition #506): %d phr %3d car\n", n, i, if (glob) "globale" else "famille", env$compter_phrases(tp), nchar(tp), env$compter_phrases(tp2), nchar(tp2))) } }
cat("\n--- marges #514 des textes de #519, #503, #528\n")
mm <- function(n, pat) { r <- readRDS(file.path(S, paste0("dump_", n, ".rds"))); i <- which(grepl(pat, r$test))[1]; tp <- env$texte_propre(r$detail[i]); cat(sprintf("%-18s %-55s %d phr %3d car (marge %d car)\n", n, substr(r$test[i],1,55), env$compter_phrases(tp), nchar(tp), 400 - nchar(tp))) }
mm("premium", "ESD generalise"); mm("reserve2", "Cellules aberrantes multiples"); mm("reserve2", "Variance unitaire"); mm("premium", "Cramer-von Mises"); mm("premium_interieur", "Cramer-von Mises"); mm("premium", "Valeur aberrante isolee \\(Grubbs\\)$")
