###############################################################################
#  tests/test_reproductibilite.R  --  TESTS DE NON-REGRESSION DU MOTEUR
#
#  Pour chaque methode (prime, reserve 1, reserve 2 Merz-Wuthrich) :
#    1. REPRODUCTIBILITE : deux appels de run_engine() avec les memes donnees,
#       les memes parametres et la meme graine donnent des objets identiques
#       au bit pres (identical) ;
#    2. NON-REGRESSION : le resultat coincide avec la reference enregistree
#       dans tests/reference/, a la tolerance relative TOLERANCE pres.
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
    echecs <- c(echecs, sprintf("%s : run_engine() a renvoye ok = FALSE", nom))
    next
  }
  if (!identical(a, b))
    echecs <- c(echecs, sprintf("%s : deux appels a graine identique different", nom))

  ref_f <- chemin_reference(nom)
  if (!file.exists(ref_f)) {
    echecs <- c(echecs, sprintf("%s : reference absente (%s)", nom, ref_f))
  } else {
    ecart <- all.equal(readRDS(ref_f), a, tolerance = TOLERANCE)
    if (!isTRUE(ecart))
      echecs <- c(echecs, sprintf("%s : ecart a la reference\n    %s", nom,
                                  paste(utils::head(ecart, 10), collapse = "\n    ")))
  }

  cat(sprintf("%-9s sigma_USP = %.10f  (%.0f s)\n", nom,
              a$parametre_final$sigma_usp,
              as.numeric(difftime(Sys.time(), t0, units = "secs"))))
}

if (length(echecs)) {
  cat("\nECHEC\n", paste0("  - ", echecs, collapse = "\n"), "\n", sep = "")
  quit(status = 1)
}
cat("\nOK : reproductibilite et non-regression verifiees pour",
    length(CAS), "methodes.\n")
