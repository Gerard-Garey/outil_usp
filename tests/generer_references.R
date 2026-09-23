###############################################################################
#  tests/generer_references.R  --  REGENERATION DES VALEURS DE REFERENCE
#
#  A lancer UNIQUEMENT lorsqu'une modification change volontairement les
#  resultats du moteur, apres avoir documente les ecarts (valeur avant, valeur
#  apres, explication) dans la PR ou le commit correspondant.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/generer_references.R            # tous les cas
#      Rscript tests/generer_references.R premium    # un seul cas
###############################################################################

source(if (file.exists("tests/outils_tests.R")) "tests/outils_tests.R" else "outils_tests.R")

noms <- commandArgs(trailingOnly = TRUE)
if (!length(noms)) noms <- names(CAS)
inconnus <- setdiff(noms, names(CAS))
if (length(inconnus)) stop("Cas inconnu(s) : ", paste(inconnus, collapse = ", "))

for (nom in noms) {
  res <- executer_cas(nom)
  ecrire_reference(nom, res)   # outils_tests.R, partage avec regenerer_et_rendre_compte.R
  cat(sprintf("%-9s reference ecrite : %s\n", nom, chemin_reference(nom)))
}
