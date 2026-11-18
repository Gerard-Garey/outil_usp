# Usage : Rscript mesurer_blancs.R <dossier> (openxlsx via R_LIBS, ou absent)
dossier <- commandArgs(TRUE)[1]
source("R/charger_moteur.R"); charger_moteur()
ref <- read.csv("tests/donnees/donnees_ln.csv"); ref[] <- lapply(ref, as.numeric)
num3 <- function(d) unname(lapply(d[c("t","xt","yt")], as.numeric))
avec <- requireNamespace("openxlsx", quietly = TRUE)
cat("chemin :", if (avec) paste("openxlsx", packageVersion("openxlsx")) else "repli (openxlsx absent)", "\n")
for (f in sort(list.files(dossier, full.names = TRUE))) {
  r <- tryCatch(engine_lire_xlsx(f), error = function(e) e)
  etat <- if (inherits(r, "condition")) paste0("refus : ", substr(conditionMessage(r), 1, 90))
          else sprintf("lu, %d lignes, t/xt/yt identiques au CSV = %s", nrow(r),
                       nrow(r) >= 8 && identical(num3(r[1:8, ]), unname(as.list(ref))))
  cat(sprintf("%-32s moteur : %s\n", basename(f), etat))
  if (avec) {
    o <- tryCatch(openxlsx::read.xlsx(f, sheet = 1), error = function(e) e)
    if (inherits(o, "condition")) { cat(sprintf("%-32s read.xlsx : erreur %s\n", "", conditionMessage(o))); next }
    cat(sprintf("%-32s read.xlsx : %d lignes ; note = %s\n", "", nrow(o),
                paste(sprintf("[%s]", head(o$note, 9)), collapse = " ")))
  }
}
