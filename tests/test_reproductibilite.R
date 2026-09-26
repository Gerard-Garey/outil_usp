###############################################################################
#  tests/test_reproductibilite.R  --  TESTS DE NON-REGRESSION DU MOTEUR
#
#  Pour chaque cas de CAS (outils_tests.R : prime, reserve 1, reserve 2
#  Merz-Wuthrich, prime sur le segment II-6 modifie par M6, issue #61, et
#  prime II-1 sur donnees declarees nettes, issue #55) :
#    1. REPRODUCTIBILITE : deux appels de run_engine() avec les memes donnees,
#       les memes parametres et la meme graine donnent des objets identiques
#       au bit pres (identical) ;
#    2. NON-REGRESSION : le resultat coincide avec la reference enregistree
#       dans tests/reference/, VALEUR PAR VALEUR a la tolerance TOLERANCE
#       (comparer_objets() de outils_tests.R : chemins, structure et chaque
#       feuille jugee isolement, sans moyenne), hors grandeurs connues comme
#       instables (INSTABLES, chacune liee a une issue) et des champs exclus
#       par conception (EXCLUS_AJUSTEMENT, issue #22). L'ecart maximal
#       mesure est affiche meme quand le cas est conforme.
#
#  Code de sortie 0 si tout passe, 1 sinon (utilise par l'integration
#  continue). Duree : quelques minutes.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/test_reproductibilite.R
###############################################################################

source(if (file.exists("tests/outils_tests.R")) "tests/outils_tests.R" else "outils_tests.R")

echecs <- character(0)
for (nom in names(CAS)) {
  t0 <- Sys.time()
  a <- executer_cas(nom)
  b <- executer_cas(nom)

  if (!isTRUE(a$ok)) {
    echecs <- c(echecs, sprintf("%s : run_engine() a renvoye ok = FALSE\n%s", nom, decrire_refus(a)))
    next
  }
  if (!identical(a, b))
    echecs <- c(echecs, sprintf("%s : deux appels a graine identique different", nom))

  ref_f <- chemin_reference(nom)
  if (!file.exists(ref_f)) {
    echecs <- c(echecs, sprintf("%s : reference absente (%s)", nom, ref_f))
  } else {
    cmp <- comparer_objets(neutraliser_instables(readRDS(ref_f)),
                           neutraliser_instables(a), tol = TOLERANCE)
    synthese <- resumer_comparaison(cmp)
    if (!cmp$conforme)
      echecs <- c(echecs, sprintf("%s : ecart a la reference\n    %s", nom,
                                  paste(synthese, collapse = "\n    ")))
  }

  cat(sprintf("%-11s sigma_USP = %.10f  (%.0f s)\n", nom,
              a$parametre_final$sigma_usp,
              as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  if (file.exists(ref_f)) cat("            ", synthese[1], "\n", sep = "")
}

if (length(echecs)) {
  cat("\nECHEC\n", paste0("  - ", echecs, collapse = "\n"), "\n", sep = "")
  quit(status = 1)
}
cat("\nOK : reproductibilite et non-regression verifiees pour",
    length(CAS), "cas.\n")
