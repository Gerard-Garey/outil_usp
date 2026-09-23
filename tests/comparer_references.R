###############################################################################
#  tests/comparer_references.R  --  TABLEAU AVANT / APRES DES RESULTATS
#
#  Recalcule chaque cas et le compare a la reference enregistree avec le
#  comparateur unique de non-regression (comparer_objets() de
#  outils_tests.R, le meme que test_reproductibilite.R) : liste, grandeur par
#  grandeur, les valeurs en ecart au seuil -- chemin dans l'objet retourne par
#  run_engine(), valeur de reference (avant), nouvelle valeur (apres), ecart
#  (relatif, ou absolu pour une reference nulle ou quasi nulle) --, puis une
#  ligne de synthese par fichier, affichee meme quand tout est conforme :
#  nombre de feuilles non strictement identiques (derive de plateforme
#  comprise) et ecart maximal, avec la feuille qui l'atteint. Sert a
#  documenter un changement de resultats avant de regenerer les references.
#  Ne modifie aucun fichier.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/comparer_references.R            # tous les cas
#      Rscript tests/comparer_references.R premium    # un seul cas
#  Options :
#      --tout          inclure les grandeurs de INSTABLES et les champs
#                      EXCLUS_AJUSTEMENT (issue #22), exclus sinon ;
#      --seuil <tol>   afficher les ecarts au-dela de tol au lieu de
#                      TOLERANCE (par ex. --seuil 0 pour lister toutes les
#                      feuilles non strictement identiques) ; n'influe que
#                      sur le seuil d'affichage : ni sur la bascule relatif /
#                      absolu (toujours TOLERANCE), ni sur le critere de la CI.
###############################################################################

source(if (file.exists("tests/outils_tests.R")) "tests/outils_tests.R" else "outils_tests.R")

args <- commandArgs(trailingOnly = TRUE)
tout <- "--tout" %in% args
args <- setdiff(args, "--tout")
seuil <- TOLERANCE
k <- match("--seuil", args)
if (!is.na(k)) {
  if (k == length(args)) stop("--seuil sans valeur")
  seuil <- as.numeric(args[k + 1L])
  if (!is.finite(seuil) || seuil < 0) stop("--seuil : valeur invalide")
  args <- args[-c(k, k + 1L)]
}
noms <- args
if (!length(noms)) noms <- names(CAS)
inconnus <- setdiff(noms, names(CAS))
if (length(inconnus)) stop("Cas inconnu(s) : ", paste(inconnus, collapse = ", "))

# aplatir() et comparer_objets() sont definies dans outils_tests.R,
# partagees avec test_reproductibilite.R et patcher_reference.R : les chemins
# affiches ici sont exactement les motifs que le patcher accepte, et un ecart
# signale ici est exactement ce qui fait echouer la CI (au seuil TOLERANCE).

for (nom in noms) {
  ref_f <- chemin_reference(nom)
  if (!file.exists(ref_f)) { cat(nom, ": reference absente\n\n"); next }
  avant <- readRDS(ref_f); apres <- executer_cas(nom)
  if (!tout) { avant <- neutraliser_instables(avant); apres <- neutraliser_instables(apres) }
  # --seuil ne change que le seuil de conformite affiche (tol) ; la bascule
  # relatif / absolu reste celle de la CI (TOLERANCE).
  r <- comparer_objets(avant, apres, tol = seuil, bascule = TOLERANCE)
  cat("=== ", nom, " : ", r$n_ecarts, " grandeur(s) en ecart au seuil ",
      format(seuil), "\n", sep = "")
  if (r$n_ecarts) {
    tab <- r$ecarts
    names(tab)[names(tab) == "reference"] <- "avant"
    names(tab)[names(tab) == "obtenu"] <- "apres"
    tab$ecart <- ifelse(is.na(tab$ecart), "", formatC(tab$ecart, digits = 3, format = "e"))
    print(tab, row.names = FALSE, right = FALSE)
  }
  if (length(r$structure))
    cat("Structure (type ou attributs) differente :", paste(r$structure, collapse = ", "), "\n")
  cat("Synthese :", resumer_comparaison(r)[1], "\n\n")
}
