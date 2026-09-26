###############################################################################
#  tests/generer_references.R  --  REGENERATION DES VALEURS DE REFERENCE
#
#  Les references versionnees (tests/reference/) ne sont produites que par la
#  CI : workflow .github/workflows/references.yml (mode bascule pour ce
#  script, sur un checkout jetable du runner ; ADR 0011, point 10). Une
#  execution locale, pour experimenter, est admise a condition de n'en
#  commiter aucun .rds. Une regeneration ordinaire passe par le mode
#  regeneration du meme workflow (tests/regenerer_et_rendre_compte.R), un
#  changement non numerique par tests/patcher_reference.R (skill
#  verifier-reproductibilite, etape 4).
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

# Tous les cas sont calcules avant toute ecriture : un resultat ok = FALSE
# (refus ou defaut de calcul intercepte, issue #88) n'est jamais ecrit comme
# reference ; ses motifs et son diagnostic sont affiches, arret en code 1,
# aucune reference n'etant alors ecrite.
resultats <- lapply(stats::setNames(noms, noms), executer_cas)
refuses <- names(resultats)[!vapply(resultats, function(r) isTRUE(r$ok), logical(1))]
if (length(refuses)) {
  for (nom in refuses)
    cat(sprintf("%s : run_engine() renvoie ok = FALSE\n%s\n", nom, decrire_refus(resultats[[nom]])))
  cat("Aucune reference ecrite.\n")
  quit(status = 1)
}
for (nom in noms) {
  ecrire_reference(nom, resultats[[nom]])   # outils_tests.R, partage avec regenerer_et_rendre_compte.R
  cat(sprintf("%-9s reference ecrite : %s\n", nom, chemin_reference(nom)))
}
