###############################################################################
#  tests/unitaires/test_patcher_reference.R  --  PATCH CHIRURGICAL (issue #32)
#
#  Teste patcher_objets() de tests/patcher_reference.R sur des objets
#  construits a la main, sans reference ni moteur : un vecteur de textes qui
#  franchit la longueur 1 (1 -> 2, 2 -> 1) doit etre patche comme le
#  remplacement d'un seul vecteur, et les controles existants (invariant
#  "aucune valeur numerique posee", ecarts non designes, juges au seuil de la
#  non-regression) ne doivent pas etre affaiblis.
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

# Le patcher est source dans un environnement dedie : ses fonctions,
# outils_tests.R et le moteur que celui-ci charge n'atteignent pas
# l'environnement global. DOSSIER_TESTS, construit comme le chemin de
# outils_unitaires.R, rend le chargement independant du repertoire courant.
.dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
patcher_env <- new.env(parent = globalenv())
patcher_env$DOSSIER_TESTS <- file.path(.dossier, "..")
sys.source(file.path(patcher_env$DOSSIER_TESTS, "patcher_reference.R"), envir = patcher_env)

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
verifier("Vecteur de textes porteur d'un attribut 1 -> 2 : refuse (l'attribut cache un nombre)",
         { a <- list(x = "a"); b <- list(x = structure(c("a", "b"), note = 3.14))
           refuse(patcher(a, b, "x")) })

## --- Derive de plateforme non designee (issue #14, seuil TOLERANCE) --------
# Le tri des grandeurs differentes suit le comparateur unique de
# outils_tests.R : une derive sous le seuil 1e-6 n'est pas un ecart et reste
# a sa valeur de reference ; au-dela, non designee, elle fait refuser le patch.
verifier("Derive de 5e-7 non designee : patch accepte, valeur de reference conservee",
         { a <- list(t = "a", x = 0.3); b <- list(t = "b", x = 0.3 * (1 + 5e-7))
           r <- patcher(a, b, "^t$"); !refuse(r) && identical(r, list(t = "b", x = 0.3)) })
verifier("Ecart de 2e-6 non designe : patch refuse",
         { a <- list(t = "a", x = 0.3); b <- list(t = "b", x = 0.3 * (1 + 2e-6))
           refuse(patcher(a, b, "^t$")) })

## --- Formes de chemins : vecteur nomme, vecteur imbrique ------------------
verifier("Vecteur nomme 1 -> 2 : c(x='a') -> c(x='a', y='b') patche a l'identique du recalcule",
         { a <- list(v = c(x = "a")); b <- list(v = c(x = "a", y = "b"))
           r <- patcher(a, b, "v"); !refuse(r) && identical(r, b) })
verifier("Vecteur imbrique tests[[2]]$av 1 -> 2 : patche a l'identique du recalcule",
         { mk <- function(av) list(tests = list(list(av = "z", p = 0.5), list(av = av, p = 0.25)))
           r <- patcher(mk("a"), mk(c("a", "b")), "av")
           !refuse(r) && identical(r, mk(c("a", "b"))) })

fin_fichier()
