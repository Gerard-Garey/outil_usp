###############################################################################
#  tests/comparer_references.R  --  TABLEAU AVANT / APRES DES RESULTATS
#
#  Recalcule chaque cas et liste, grandeur par grandeur, les valeurs qui
#  different de la reference enregistree : chemin dans l'objet retourne par
#  run_engine(), valeur de reference (avant), nouvelle valeur (apres), ecart
#  relatif. Sert a documenter un changement de resultats avant de regenerer
#  les references. Ne modifie aucun fichier.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/comparer_references.R            # tous les cas
#      Rscript tests/comparer_references.R premium    # un seul cas
#  Option : --tout pour inclure les grandeurs de INSTABLES (exclues sinon).
###############################################################################

source(if (file.exists("tests/outils_tests.R")) "tests/outils_tests.R" else "outils_tests.R")

args <- commandArgs(trailingOnly = TRUE)
tout <- "--tout" %in% args
noms <- setdiff(args, "--tout")
if (!length(noms)) noms <- names(CAS)
inconnus <- setdiff(noms, names(CAS))
if (length(inconnus)) stop("Cas inconnu(s) : ", paste(inconnus, collapse = ", "))

# aplatir() est definie dans outils_tests.R, partagee avec
# patcher_reference.R : les chemins affiches ici sont exactement les motifs
# que le patcher accepte.

fmt <- function(v) if (is.numeric(v)) formatC(v, digits = 10, format = "g") else as.character(v)

for (nom in noms) {
  ref_f <- chemin_reference(nom)
  if (!file.exists(ref_f)) { cat(nom, ": reference absente\n\n"); next }
  avant <- readRDS(ref_f); apres <- executer_cas(nom)
  if (!tout) { avant <- neutraliser_instables(avant); apres <- neutraliser_instables(apres) }
  fa <- aplatir(avant); fb <- aplatir(apres)
  cles <- union(names(fa), names(fb))
  lignes <- list()
  for (cle in cles) {
    a <- fa[[cle]]; b <- fb[[cle]]
    if (isTRUE(all.equal(a, b, tolerance = TOLERANCE))) next
    ecart <- if (is.numeric(a) && is.numeric(b) && length(a) == 1 && length(b) == 1 &&
                 is.finite(a) && is.finite(b) && a != 0) abs(b - a) / abs(a) else NA_real_
    lignes[[length(lignes) + 1]] <- data.frame(
      grandeur = cle,
      avant = if (is.null(a)) "(absent)" else paste(fmt(a), collapse = " "),
      apres = if (is.null(b)) "(absent)" else paste(fmt(b), collapse = " "),
      ecart_relatif = if (is.na(ecart)) "" else formatC(ecart, digits = 3, format = "e"),
      stringsAsFactors = FALSE)
  }
  cat("=== ", nom, " : ", length(lignes), " grandeur(s) modifiee(s)\n", sep = "")
  if (length(lignes)) print(do.call(rbind, lignes), row.names = FALSE, right = FALSE)
  cat("\n")
}
