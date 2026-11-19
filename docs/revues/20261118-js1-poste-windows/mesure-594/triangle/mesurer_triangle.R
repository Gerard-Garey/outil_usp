# Lit chaque classeur par engine_lire_xlsx() puis engine_lire_triangle(), sur
# le chemin courant (openxlsx si installe, lecteur interne sinon).
# Usage : Rscript mesurer_triangle.R <dossier>
source("R/charger_moteur.R"); charger_moteur()
cat("chemin :", if (requireNamespace("openxlsx", quietly = TRUE))
  paste("openxlsx", utils::packageVersion("openxlsx")) else "interne", "\n")
for (f in sort(list.files(commandArgs(TRUE)[1], "\\.xlsx$", full.names = TRUE))) {
  cat("==", basename(f), "\n")
  lu <- tryCatch(engine_lire_xlsx(f), error = function(e) e)
  if (inherits(lu, "error")) { cat("refus", class(lu)[1], ":", conditionMessage(lu), "\n"); next }
  cat("lu", nrow(lu), "x", ncol(lu), "\n")
  r <- engine_lire_triangle(lu)
  cat("ok =", r$ok, "\n"); if (!isTRUE(r$ok)) print(r[setdiff(names(r), "triangle")])
}
