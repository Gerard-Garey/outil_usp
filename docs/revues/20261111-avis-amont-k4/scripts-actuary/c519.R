rep <- function(pat_test, old, new, which = cas) for (n in which) for (l in refs[[n]]$tests) if (identical(l$test, pat_test)) {
  if (!grepl(old, l$detail, fixed = TRUE)) { cat(n, ": ancien texte absent !\n"); next }
  d2 <- sub(old, new, l$detail, fixed = TRUE); z <- mes(d2); o <- mes(l$detail)
  cat(sprintf("%-18s %-45s avant %d/%3d apres %d/%3d\n", n, substr(pat_test,1,45), o[1], o[2], z[1], z[2])) }
rep("Valeurs aberrantes multiples (ESD generalise)", "a niveau superieur a alpha a T = 8 en simulation (valeurs",
    "a niveau superieur a alpha a T = 8 en simulation sous i.i.d. normal (valeurs")
oldR <- sprintf(E$PHRASE_MW_ROSNER_DIAGNOSTIC, 0.10)
newR_g <- paste(
  "Repere du nombre de cellules aberrantes (ESD de Rosner a alpha = %g, nombre en",
  "estimation), sans p-value : son cadre (echantillon i.i.d. normal) ne couvre pas les",
  "residus de Mack, contraints par colonne. Diagnostic sans verdict : la ligne",
  "\"Cellule aberrante du triangle (residus studentises externes)\" fait foi.")
rep("Cellules aberrantes multiples (ESD generalise)", oldR, sprintf(newR_g, 0.10), "reserve2")
for (a in c(0.1, 0.05, 0.025, 0.0125, 1/30, 0.2999)) cat(sprintf("alpha %s -> '%s'\n", format(a, digits=17), sub(".*alpha = ([^,]*),.*", "\\1", sprintf(newR_g, a))))
cat("Rosner gabarit:", nchar(newR_g), "\n")
oldC <- "Distance de Cramer-von Mises a la loi normale, tres correlee a celle d'Anderson-Darling, pour information."
newC <- "Distance de Cramer-von Mises a la loi normale, celle d'Anderson-Darling sans la ponderation des queues, pour information."
rep("Cramer-von Mises", oldC, newC)
newV <- "Verdict sensible a l'alea de simulation (p a moins de 2 erreurs de Monte-Carlo du seuil)."
for (n in cas) for (l in refs[[n]]$tests) if (endsWith(l$detail, E$PHRASE_VERDICT_SENSIBLE_MC)) {
  d2 <- paste0(substr(l$detail, 1, nchar(l$detail) - nchar(E$PHRASE_VERDICT_SENSIBLE_MC)), newV)
  cat(n, "|", l$test, "| fin :", substr(d2, nchar(d2) - 140, nchar(d2)), "\n") }
H0n <- "pertes lognormales : erreurs epsilon_t i.i.d. N(0,1) du modele reglementaire, dont les residus standardises z = P epsilon sont l'image (z non i.i.d.)"
H0m <- "residus de Mack lus comme un echantillon i.i.d. normal (loi de reference de la p-value, non hypothese du modele de Mack)"
cat("H0n", nchar(H0n), "\nH0m", nchar(H0m), "\n")
cat("H0 max actuel:", max(unlist(lapply(refs, function(r) vapply(r$tests, function(l) if (is.na(l$H0)) 0L else nchar(l$H0), 1L)))), "\n")
