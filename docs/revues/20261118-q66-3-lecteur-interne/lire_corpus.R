# Q-66-3 (examen de la lecture des classeurs par le lecteur interne seul).
# Lit chaque classeur du corpus par engine_lire_xlsx() sur le chemin courant
# (openxlsx si installe, lecteur interne sinon), puis par
# engine_lire_donnees_csv() (series) ou engine_lire_triangle() (triangle),
# et enregistre les retours et les durees dans un .rds.
# Usage : Rscript lire_corpus.R <sortie.rds> <classeur> [<classeur> ...]
args <- commandArgs(trailingOnly = TRUE)
sortie <- args[1]; fichiers <- args[-1]
source("R/charger_moteur.R"); charger_moteur()
chemin <- if (requireNamespace("openxlsx", quietly = TRUE))
  paste("openxlsx", as.character(utils::packageVersion("openxlsx"))) else "interne"
cat("chemin :", chemin, "\n")
res <- list()
for (f in fichiers) {
  lu <- tryCatch(engine_lire_xlsx(f), error = function(e)
    structure(list(classe = class(e), message = conditionMessage(e)), class = "refus"))
  # Duree : mediane de 7 lectures (le resultat lu est celui de la premiere)
  du <- vapply(1:7, function(k) system.time(try(engine_lire_xlsx(f), silent = TRUE))[["elapsed"]], 0)
  aval <- NULL
  if (is.data.frame(lu)) {
    aval <- if (grepl("triangle", basename(f)))
      tryCatch(engine_lire_triangle(lu), error = function(e) paste("erreur :", conditionMessage(e)))
    else tryCatch(engine_lire_donnees_csv(lu), error = function(e) paste("erreur :", conditionMessage(e)))
  }
  res[[f]] <- list(lu = lu, aval = aval, duree = stats::median(du))
}
saveRDS(list(chemin = chemin, res = res), sortie)
cat(length(res), "classeurs lus\n")
