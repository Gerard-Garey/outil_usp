# Usage : Rscript cas_identiques.R <etiquette> [fichier_patch.R ...]
# Charge le moteur, applique les patchs (evalues dans l'environnement du moteur),
# execute les six cas de reference, enregistre les resultats nettoyes et les durees.
setwd("/home/user/outil_usp")
source("tests/outils_tests.R")
a <- commandArgs(TRUE); etiq <- a[1]; patchs <- a[-1]
env <- environment(run_engine)
for (p in patchs) sys.source(p, envir = env)
cas <- strsplit(Sys.getenv("CAS_LISTE", paste(names(CAS), collapse = ",")), ",")[[1]]
for (nom in cas) {
  t <- system.time(r <- executer_cas(nom))[[3]]
  saveRDS(r, sprintf("/tmp/duree-ci/res_%s_%s.rds", etiq, nom))
  cat(sprintf("%s %-18s %6.2f s\n", etiq, nom, t))
}
