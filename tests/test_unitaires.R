###############################################################################
#  tests/test_unitaires.R  --  LANCEUR DES TESTS UNITAIRES DU MOTEUR
#
#  Execute tous les fichiers tests/unitaires/test_*.R, chacun dans son propre
#  environnement, apres chargement de R/engine.R. Complement des tests de
#  non-regression (test_reproductibilite.R) : chaque fonction du moteur est
#  confrontee a une valeur de reference justifiee (texte reglementaire, valeur
#  publiee, enumeration exhaustive, implementation independante) ou a une
#  propriete theorique.
#
#  Les defauts connus du moteur sont documentes par des tests "echec attendu"
#  (xfail) : ils ne font pas echouer la batterie tant que le defaut subsiste ;
#  un "succes inattendu" (XPASS), signe que le defaut a ete corrige, la fait
#  echouer afin que le test soit transforme en test ordinaire.
#
#  R base + stats uniquement. Duree : quelques secondes.
#  Code de sortie 0 si tout passe, 1 sinon (utilise par l'integration continue).
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/test_unitaires.R
#  Detail de toutes les assertions :
#      Rscript -e "options(tu.verbeux = TRUE); source('tests/test_unitaires.R')"
###############################################################################

.args <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
DOSSIER_UNITAIRES <- if (length(.args)) file.path(dirname(.args), "unitaires") else
                     if (dir.exists("tests/unitaires")) "tests/unitaires" else "unitaires"
if (!dir.exists(DOSSIER_UNITAIRES)) {
  cat("Dossier des tests unitaires introuvable :", DOSSIER_UNITAIRES, "\n")
  quit(status = 1)
}

LANCEUR_UNITAIRES <- TRUE
source(file.path(DOSSIER_UNITAIRES, "outils_unitaires.R"))

t0 <- Sys.time()
for (f in sort(list.files(DOSSIER_UNITAIRES, pattern = "^test_.*[.]R$", full.names = TRUE))) {
  r <- tryCatch({ sys.source(f, envir = new.env(parent = globalenv())); NULL },
                error = function(e) e)
  if (inherits(r, "error")) {
    .tu$fichier <- basename(f)
    .enregistrer("chargement du fichier", "ECHEC", conditionMessage(r))
  }
}
cat(sprintf("\nDuree totale : %.1f s\n", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
terminer()
