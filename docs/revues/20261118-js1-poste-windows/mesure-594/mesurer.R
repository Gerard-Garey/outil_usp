args <- commandArgs(TRUE); dossier <- args[1]; chemin_lib <- args[2]
source("R/charger_moteur.R"); charger_moteur()
ref <- read.csv("tests/donnees/donnees_ln.csv"); ref[] <- lapply(ref, as.numeric)
num3 <- function(d) unname(lapply(d[c("t","xt","yt")], as.numeric))
notes_b <- c(" debut blanc", "fin blanche ", " deux ", "sans", NA, "x ", " y", "z")
avec <- requireNamespace("openxlsx", quietly = TRUE)
cat("chemin :", if (avec) paste("openxlsx", packageVersion("openxlsx")) else "repli (openxlsx absent)", "\n")
for (f in sort(list.files(dossier, full.names = TRUE))) {
  r <- tryCatch(engine_lire_xlsx(f), error = function(e) e)
  etat <- if (inherits(r, "condition")) paste0("refus [", class(r)[1], "] ", substr(conditionMessage(r), 1, 110))
          else if (identical(num3(r), unname(as.list(ref)))) "lu, t/xt/yt identiques au CSV (identical)"
          else "lu, ECART"
  cat(sprintf("%-42s moteur : %s\n", basename(f), etat))
  if (avec) {
    o <- openxlsx::read.xlsx(f, sheet = 1)
    same <- identical(num3(o), unname(as.list(ref)))
    nb <- if (grepl("blancs", f)) notes_b else trimws(notes_b)
    cat(sprintf("%-42s openxlsx::read.xlsx direct : t/xt/yt identiques = %s ; note = %s\n", "", same,
        paste(sprintf("[%s]", o$note), collapse = " ")))
    cat(sprintf("%-42s note attendue : %s ; identique = %s\n", "", paste(sprintf("[%s]", nb), collapse = " "), identical(o$note, nb)))
  }
}
