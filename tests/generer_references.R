###############################################################################
#  tests/generer_references.R  --  REGENERATION DES VALEURS DE REFERENCE
#
#  RESERVE A LA CI : execute par le workflow .github/workflows/references.yml
#  (mode bascule), sur un checkout jetable du runner ; ADR 0011, point 10.
#  Ne pas l'executer ailleurs (poste du mainteneur et sessions compris) : une
#  regeneration ordinaire passe par le mode regeneration du meme workflow
#  (tests/regenerer_et_rendre_compte.R), un changement non numerique par
#  tests/patcher_reference.R (skill verifier-reproductibilite).
#
#  Ecrit dans tests/reference/, sans repertoire de sortie parametrable ; les
#  ecarts (valeur avant, valeur apres, explication) sont documentes avant,
#  dans la PR ou le commit correspondant.
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
