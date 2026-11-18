# Usage : Rscript mesurer_entete.R <classeur>, depuis la racine du depot ;
# openxlsx est pris dans R_LIBS (chemin openxlsx) ou absent (chemin de repli).
f <- commandArgs(TRUE)[1]
source("R/charger_moteur.R"); charger_moteur()
avec <- requireNamespace("openxlsx", quietly = TRUE)
cat("chemin :", if (avec) paste("openxlsx", packageVersion("openxlsx")) else "repli (openxlsx absent)", "\n")
if (avec) cat("openxlsx::read.xlsx direct, noms :", paste(sprintf("[%s]", names(openxlsx::read.xlsx(f))), collapse = " "), "\n")
r <- tryCatch(engine_lire_xlsx(f), error = function(e) e)
cat("engine_lire_xlsx :", if (inherits(r, "condition")) paste("refus :", conditionMessage(r)) else paste("lu, noms :", paste(names(r), collapse = " ")), "\n")
