OLD_F <- E$DETAIL_P_FAMILLE; OLD_G <- E$DETAIL_P_GLOBALE
NEW_F <- paste(
  "Diagnostic sans verdict : une p de famille faible signale qu'au moins une",
  "hypothese de la famille est mise en cause sous le modele ajuste (p plug-in non",
  "exacte), une p elevee n'atteste pas l'adequation (puissance non mesuree a T = 8).",
  "Tests de la famille (cles mc_nom) : [%s], voir aussi \"p globale (minP, lecture",
  "conjointe de la batterie)\".")
NEW_G <- paste(
  "Diagnostic sans verdict : une p globale faible signale qu'au moins une hypothese",
  "de la batterie est mise en cause sous le modele ajuste, compte tenu des %d tests",
  "et de leur dependance (p plug-in non exacte, sur les p Monte-Carlo et non les p",
  "retenues). Une p elevee n'atteste pas l'adequation du modele (puissance non",
  "mesuree a T = 8), voir les lignes \"p de famille (minP, lecture conjointe)\".")
cat("NEW_F gabarit", nchar(NEW_F), " NEW_G gabarit", nchar(NEW_G), "\n")
cat("NEW_F:\n", NEW_F, "\nNEW_G:\n", NEW_G, "\n")
mx <- c(f = 0, g = 0)
for (n in cas) for (l in refs[[n]]$tests) { if (!grepl("^p de famille|^p globale", l$test)) next
  glob <- grepl("^p globale", l$test)
  if (glob) { k <- as.integer(sub(".*compte tenu des ([0-9]+) tests.*", "\\1", l$detail)); old <- sprintf(OLD_G, k); new <- sprintf(NEW_G, k) }
  else { mem <- sub(".*cles mc_nom\\) : \\[([^]]*)\\].*", "\\1", l$detail); old <- sprintf(OLD_F, mem); new <- sprintf(NEW_F, mem) }
  d2 <- sub(old, new, l$detail, fixed = TRUE); z <- mes(d2)
  cat(sprintf("%-18s %-8s %d phr %3d car\n", n, if (glob) "globale" else "famille", z[1], z[2]))
  if (glob) mx["g"] <- max(mx["g"], z[2]) else mx["f"] <- max(mx["f"], z[2]) }
print(mx)
worstB <- "Intercept, RESET, SpearVol, SpearTps, MK, CoxStuart"
z <- mes(sprintf(NEW_F, worstB)); cat("pire liste B (6 membres) :", z, "\n")
z <- mes(sprintf(NEW_G, 99L)); cat("globale k = 99 :", z, "\n")
z <- mes(.engine_joindre <- NULL)
