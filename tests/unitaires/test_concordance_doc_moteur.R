###############################################################################
#  tests/unitaires/test_concordance_doc_moteur.R  --  EXTRACTION DES
#  CITATIONS ET DES DECOMPTES DU LATEX (issue #65)
#
#  Teste les fonctions d'extraction de tests/concordance_doc_moteur.R sur des
#  chaines LaTeX construites en memoire, sans lire le document ni executer le
#  moteur : \code{} imbriques, noms coupes en deux \code{}, commentaires,
#  desechappement, citations de fonction (qualifiees, internes, a joker,
#  avec arguments), nombres en lettres, registre des decomptes (phrase
#  verifiee, ecart, phrase introuvable), inventaire, familles.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_concordance_doc_moteur.R")

.dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
cc <- new.env(parent = globalenv())
sys.source(file.path(.dossier, "..", "concordance_doc_moteur.R"), envir = cc)

tex <- c("Voir \\code{run\\_engine()} et \\code{.shapiro\\_sur()} ; % \\code{commente()}",
         "puis \\code{test\\_shapiro\\_}\\\\ \\code{francia()} et \\code{stats::shapiro.test()},",
         "\\code{usp\\_bareme\\_segment(segment, annexe)}, \\code{test\\_*()}, \\code{res\\$ok},",
         "\\code{x^{2}()} ; 100~\\% et \\code{mw\\_test\\_}",
         "\\code{ordonnee\\_origine()} sur deux lignes.")
codes <- cc$extraire_codes(tex)
cit <- cc$citations_fonctions(codes)

verifier("Commentaire LaTeX ignore (\\code{} apres %)",
         !any(grepl("commente", codes$brut)))
verifier("\\% echappe n'ouvre pas de commentaire",
         any(grepl("mw\\\\_test\\\\_ordonnee", codes$brut)))
verifier("Nom coupe en deux \\code{} (separes par \\\\) recolle",
         "test_shapiro_francia" %in% cit$nom)
verifier("Nom coupe sur deux lignes recolle, avec la ligne du debut",
         "mw_test_ordonnee_origine" %in% cit$nom && cit$ligne[cit$nom == "mw_test_ordonnee_origine"] == 4L)
verifier("Accolades imbriquees : le contenu s'arrete a l'accolade fermante appariee",
         "x^{2}()" %in% cc$desechapper(codes$brut))
verifier("Citations : interne, qualifiee, avec arguments, joker",
         all(c("run_engine", ".shapiro_sur", "stats::shapiro.test", "usp_bareme_segment", "test_*") %in% cit$nom))
verifier("\\code{} sans parenthese (champ) : pas une citation de fonction",
         !any(grepl("ok", cit$nom)) && "res$ok" %in% cc$desechapper(codes$brut))
verifier("Numeros de ligne des citations",
         identical(cit$ligne[match(c("run_engine", "stats::shapiro.test", "test_*"), cit$nom)], c(1L, 2L, 3L)))

## --- Statut d'un nom -------------------------------------------------------
env <- new.env(parent = globalenv())
env$ma_fonction <- function() NULL
defs <- data.frame(nom = c("lr", "outil"), fichier = c("engine.R", "outils_tests.R"), locale = c(TRUE, FALSE),
                   stringsAsFactors = FALSE)
verifier("statut_fonction : moteur, base, qualifiee, joker, locale, outil de test, introuvable",
         identical(c(cc$statut_fonction("ma_fonction", env), cc$statut_fonction("mean", env),
                     cc$statut_fonction("stats::var", env), cc$statut_fonction("ma_*", env),
                     cc$statut_fonction("lr", env, defs = defs), cc$statut_fonction("outil", env, defs = defs),
                     cc$statut_fonction("nexiste_pas_xyz", env), cc$statut_fonction("stats::nexiste_pas", env)),
                   c("moteur ou affichage", "R (chemin de recherche)", "paquet stats", "joker (1 fonction(s))",
                     "fonction locale (engine.R)", "outil de test (outils_tests.R)", "INTROUVABLE", "INTROUVABLE")))

## --- Nombres et decomptes --------------------------------------------------
verifier("nombre_fr : chiffres, lettres, composes",
         identical(vapply(c("50", "Dix-neuf", "une", "trente-deux", "vingt-et-un", "douzaine"), cc$nombre_fr, numeric(1)),
                   c(`50` = 50, `Dix-neuf` = 19, une = 1, `trente-deux` = 32, `vingt-et-un` = 21, douzaine = NA)))

registre <- list(
  list(id = "total", methode = "m", motif = "des (\\d+) lignes de la table auditable", champs = "lignes (total)"),
  list(id = "types", methode = "m",
       motif = paste0("(", cc$MOT_NOMBRE, ") entr\u00e9es, dont (", cc$MOT_NOMBRE, ") tests"),
       champs = c("lignes (total)", "type test")),
  list(id = "absente", methode = "m", motif = "phrase disparue (\\d+)", champs = "lignes (total)"))
doc <- c("Sur le jeu de contr\u00f4le, des 50~lignes de la",
         "table auditable ; \\textbf{Dix-neuf} entr\u00e9es, dont \\textbf{quinze} tests.",
         "Les six lignes sur base $u_t$ et 3~entr\u00e9es ailleurs.")
g <- list(m = c("lignes (total)" = 50, "type test" = 14))
v <- cc$verifier_decomptes(doc, g, registre)
verifier("Decompte sur deux lignes (espace insecable, retour a la ligne) : verifie, lignes 1 a 2",
         v$statut[v$assertion == "total"] == "ok" && v$ligne[v$assertion == "total"] == 1L &&
           v$ligne_fin[v$assertion == "total"] == 2L)
verifier("Nombres en lettres sous \\textbf{} : total 19 annonce contre 50 mesure -> ecart, 15 contre 14 -> ecart",
         identical(v$annonce[v$assertion == "types"], c(19, 15)) &&
           identical(v$statut[v$assertion == "types"], c("ECART", "ECART")))
verifier("Phrase du registre introuvable : statut INTROUVABLE",
         v$statut[v$assertion == "absente"] == "INTROUVABLE")
inv <- cc$inventaire_decomptes(doc)
verifier("Inventaire : 'N lignes' / 'N entrees' en chiffres et en lettres",
         identical(inv$ligne, 1:3))

## --- Familles --------------------------------------------------------------
verifier("familles_produites : champ famille a toute profondeur, sans doublon",
         identical(cc$familles_produites(list(tests = list(list(famille = "B. x"), list(famille = "B. x")),
                                              controles = list(list(famille = "A. y")))),
                   c("B. x", "A. y")))

fin_fichier()
