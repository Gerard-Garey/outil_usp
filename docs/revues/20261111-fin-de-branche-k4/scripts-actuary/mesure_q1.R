source("tests/unitaires/outils_unitaires.R")
F2 <- paste(
  "Diagnostic sans verdict : une p de famille faible signale qu'au moins une",
  "hypothese de la famille est mise en cause sous le modele ajuste (p plug-in non",
  "exacte), une p elevee n'atteste pas l'adequation (puissance non mesuree).",
  "Tests de la famille (cles mc_nom) : [%s], voir aussi \"p globale (minP, lecture",
  "conjointe de la batterie)\".")
G2 <- paste(
  "Diagnostic sans verdict : une p globale faible signale qu'au moins une hypothese",
  "de la batterie est mise en cause sous le modele ajuste, compte tenu des %d tests",
  "et de leur dependance (p plug-in non exacte, sur les p Monte-Carlo et non les p",
  "retenues). Une p elevee n'atteste pas l'adequation du modele (puissance non",
  "mesuree), voir les lignes \"p de famille (minP, lecture conjointe)\".")
cat("identite avec sub : F", identical(F2, sub(" a T = 8)", ")", DETAIL_P_FAMILLE, fixed=TRUE)),
    " G", identical(G2, sub(" a T = 8)", ")", DETAIL_P_GLOBALE, fixed=TRUE)), "\n")
cat("gabarits actuels : F", nchar(DETAIL_P_FAMILLE), " G", nchar(DETAIL_P_GLOBALE), "\n")
cat("gabarits cibles  : F", nchar(F2), " G", nchar(G2), "\n")
cat("G k=99 :", nchar(texte_propre(sprintf(G2, 99L))), compter_phrases(texte_propre(sprintf(G2, 99L))), "\n")
pire <- sprintf(F2, "Intercept, RESET, SpearVol, SpearTps, MK, CoxStuart")
cat("F pire :", nchar(texte_propre(pire)), compter_phrases(texte_propre(pire)), "\n")
for (f in list.files("tests/reference", pattern="\\.rds$", full.names=TRUE)) {
  o <- readRDS(f)
  for (l in o$tests) if (grepl("mesuree a T = 8", l$detail, fixed=TRUE)) {
    av <- texte_propre(l$detail)
    ap <- texte_propre(sub(" a T = 8)", ")", l$detail, fixed=TRUE))
    cat(sprintf("%-22s %-55s avant %d/%d apres %d/%d\n", basename(f), substr(l$test,1,55),
        compter_phrases(av), nchar(av), compter_phrases(ap), nchar(ap)))
  }
}
