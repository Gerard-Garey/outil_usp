###############################################################################
#  tests/unitaires/test_patcher_reference.R  --  PATCH CHIRURGICAL (issue #32)
#
#  Teste patcher_objets() de tests/patcher_reference.R sur des objets
#  construits a la main, sans reference ni moteur : un vecteur de textes qui
#  franchit la longueur 1 (1 -> 2, 2 -> 1) doit etre patche comme le
#  remplacement d'un seul vecteur, et les controles existants (invariant
#  "aucune valeur numerique posee", ecarts non designes) ne doivent pas etre
#  affaiblis.
#
#  Reference : l'objet recalcule lui-meme. Un patch accepte dont tous les
#  chemins differents sont designes doit rendre un objet identical() au
#  resultat recalcule.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_patcher_reference.R")

# Le patcher est source dans un environnement dedie : ses fonctions et
# outils_tests.R (qu'il charge) n'atteignent pas l'environnement global.
.dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
patcher_env <- new.env(parent = globalenv())
sys.source(file.path(.dossier, "..", "patcher_reference.R"), envir = patcher_env)

# Patch silencieux : renvoie l'objet patche, ou la condition d'erreur si le
# patch est refuse.
patcher <- function(avant, apres, motifs) {
  r <- NULL
  utils::capture.output(r <- tryCatch(patcher_env$patcher_objets(avant, apres, motifs)$patche,
                                      error = function(e) e))
  r
}
refuse <- function(r) inherits(r, "error")

## --- Cas de l'issue #32, a l'identique -------------------------------------
avant <- list(validation = list(avertissements = "a"))
apres <- list(validation = list(avertissements = c("a", "b")))
verifier("Issue #32 : avertissements 'a' -> c('a','b') patche a l'identique du recalcule",
         { r <- patcher(avant, apres, "avertissements"); !refuse(r) && identical(r, apres) })

## --- 1 -> 2 et 2 -> 1 au milieu d'autres entrees ---------------------------
# Les entrees voisines (numeriques) restent en place : le vecteur remplace
# garde sa position dans son conteneur.
obj <- function(avt) list(validation = list(ok = TRUE, erreurs = character(0),
                                            avertissements = avt, T = 8L),
                          sigma = 0.123456789)
verifier("1 -> 2 : vecteur remplace en entier, position et voisins conserves",
         { r <- patcher(obj("a"), obj(c("a", "b")), "avertissements")
           !refuse(r) && identical(r, obj(c("a", "b"))) })
verifier("2 -> 1 : vecteur remplace en entier, position et voisins conserves",
         { r <- patcher(obj(c("a", "b")), obj("a"), "avertissements")
           !refuse(r) && identical(r, obj("a")) })
verifier("3 -> 1 (chaine nouvelle) : vecteur remplace en entier",
         { r <- patcher(obj(c("a", "b", "c")), obj("z"), "avertissements")
           !refuse(r) && identical(r, obj("z")) })

## --- Cas inchanges : sans franchissement de la longueur 1 -------------------
verifier("Vecteur inchange : seul le texte designe ailleurs est patche",
         { a <- obj(c("a", "b")); b <- a; b$validation$erreurs <- "e"
           r <- patcher(a, b, "erreurs"); !refuse(r) && identical(r, b) })
verifier("2 -> 3 (sans franchissement) : patch feuille a feuille inchange",
         { r <- patcher(obj(c("a", "b")), obj(c("a", "b", "c")), "avertissements")
           !refuse(r) && identical(r, obj(c("a", "b", "c"))) })

## --- Controles non affaiblis ------------------------------------------------
verifier("Vecteur numerique 1 -> 2 : refuse (invariant, aucune valeur numerique posee)",
         { a <- list(x = 1); b <- list(x = c(1, 2)); refuse(patcher(a, b, "x")) })
verifier("Vecteur numerique 2 -> 1 : refuse (invariant, aucune valeur numerique posee)",
         { a <- list(x = c(1, 2)); b <- list(x = 3); refuse(patcher(a, b, "x")) })
verifier("Motif ne designant que le chemin nu : chemins indexes laisses, patch refuse",
         refuse(patcher(obj("a"), obj(c("a", "b")), "avertissements$")))

fin_fichier()
