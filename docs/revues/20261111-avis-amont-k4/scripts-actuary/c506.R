OLD_F <- E$DETAIL_P_FAMILLE; OLD_G <- E$DETAIL_P_GLOBALE
cand_F <- list(
 FA = paste("Diagnostic sans verdict, aucun verdict de ligne n'etant modifie : une p de famille faible",
  "signale qu'au moins une hypothese de la famille est mise en cause sous le modele ajuste (p plug-in",
  "non exacte), une p elevee n'atteste pas leur adequation (puissance non mesuree a T = 8). Tests de la",
  "famille (cles mc_nom) : [%s], voir aussi \"p globale (minP, lecture conjointe de la batterie)\"."),
 FB = paste("Diagnostic sans verdict : une p de famille faible signale qu'au moins une",
  "hypothese de la famille est mise en cause sous le modele ajuste (p plug-in non",
  "exacte), une p elevee n'atteste pas leur adequation (puissance non mesuree a T = 8). Tests de la famille (cles",
  "mc_nom) : [%s], voir aussi \"p globale (minP, lecture conjointe de la batterie)\"."))
cand_G <- list(
 GA = paste("Diagnostic sans verdict : une p globale faible signale qu'au moins une hypothese",
  "de la batterie est mise en cause sous le modele ajuste, compte tenu des %d tests",
  "et de leur dependance (p plug-in non exacte, sur les p Monte-Carlo et non les p",
  "retenues). Une p elevee n'atteste pas l'adequation du modele (puissance non mesuree a T = 8) :",
  "lire avec les lignes \"p de famille (minP, lecture conjointe)\"."),
 GB = paste("Diagnostic sans verdict, aucun verdict de ligne n'etant modifie : une p globale faible signale qu'au moins une hypothese",
  "de la batterie est mise en cause sous le modele ajuste, compte tenu des %d tests",
  "et de leur dependance (p plug-in non exacte, sur les p Monte-Carlo et non les p",
  "retenues). Une p elevee n'atteste pas l'adequation du modele (puissance non mesuree a T = 8) :",
  "lire avec les lignes \"p de famille (minP, lecture conjointe)\"."))
cat("Gabarits (sans %s/%d) :\n"); for (n in names(cand_F)) cat(n, nchar(cand_F[[n]]), "\n"); for (n in names(cand_G)) cat(n, nchar(cand_G[[n]]), "\n")
res <- list()
for (n in cas) { L <- refs[[n]]$tests
  for (l in L) { if (!grepl("^p de famille|^p globale", l$test)) next
    glob <- grepl("^p globale", l$test)
    if (glob) { k <- as.integer(sub(".*compte tenu des ([0-9]+) tests.*", "\\1", l$detail)); old <- sprintf(OLD_G, k)
      news <- lapply(cand_G, function(g) sprintf(g, k)) }
    else { mem <- sub(".*cles mc_nom\\) : \\[([^]]*)\\].*", "\\1", l$detail); old <- sprintf(OLD_F, mem)
      news <- lapply(cand_F, function(g) sprintf(g, mem)) }
    stopifnot(grepl(old, l$detail, fixed = TRUE))
    o <- mes(l$detail)
    out <- sprintf("%-18s %-8s avant %d/%3d", n, if (glob) "globale" else "famille", o[1], o[2])
    for (nn in names(news)) { d2 <- sub(old, news[[nn]], l$detail, fixed = TRUE); z <- mes(d2); out <- paste(out, sprintf("| %s %d/%3d", nn, z[1], z[2])) }
    cat(out, "\n") } }
# borne sur la liste des membres : union des mc_nom candidats par prefixe
for (n in cas) { L <- refs[[n]]$tests
  fam <- vapply(L, function(l) substr(l$famille,1,2), ""); mc <- vapply(L, function(l) if (is.null(l$mc_nom)||is.na(l$mc_nom)) NA_character_ else l$mc_nom, "")
  sens <- vapply(L, function(l) if (is.na(l$sens)) "" else l$sens, ""); var <- vapply(L, function(l) l$variante, "")
  cand <- !is.na(mc) & var == "principale" & !grepl("^LC", fam)
  for (p in unique(fam[cand])) cat(sprintf("%-18s %s candidats(sens quelconque, type quelconque): %s\n", n, p, paste(unique(mc[cand & fam == p]), collapse=", ")))
}
