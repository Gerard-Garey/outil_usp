###############################################################################
#  tests/unitaires/test_concordance_doc_moteur.R  --  EXTRACTION DES
#  CITATIONS ET DES DECOMPTES DU LATEX (issue #65)
#
#  Teste les fonctions d'extraction de tests/concordance_doc_moteur.R sur des
#  chaines LaTeX construites en memoire, sans lire le document ni executer le
#  moteur (sauf le dernier bloc, qui lance le script) : \code{} imbriques, noms coupes en deux \code{}, commentaires,
#  desechappement, citations de fonction (qualifiees, internes, a joker,
#  avec arguments), nombres en lettres, registre des decomptes (phrase
#  verifiee, ecart, phrase introuvable), inventaire, familles, exemptions
#  nominatives (appliquee, ancree sur son contexte, perimee), seuil de B
#  (valider_B(), --B sous B_MIN refuse), recapitulatif apres exemptions et
#  mode --strict (script lance sur une copie modifiee du .tex et sur l'etat
#  du depot).
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

## --- Exemptions nominatives (decision Q-O3) --------------------------------
doc_ex <- c("\\code{R/engine.R} & Contenu &",
            "Toute primitive Shiny (\\code{input\\$}, \\code{reactive()},",
            "\\code{render*()}) \\\\", "Ligne sans rapport.", "Autre ligne.",
            "Ailleurs, \\code{reactive()} cite hors du tableau.")
cit_ex <- cc$citations_fonctions(cc$extraire_codes(doc_ex))
st_ex <- c(reactive = "INTROUVABLE", "render*" = "INTROUVABLE")
ex_reg <- list(list(nom = "reactive", contexte = "Toute primitive Shiny", fenetre = 2L, motif = "m1"),
               list(nom = "render*", contexte = "Toute primitive Shiny", fenetre = 2L, motif = "m2"),
               list(nom = "shinyApp", contexte = "Toute primitive Shiny", fenetre = 2L, motif = "m3"))
ex <- cc$appliquer_exemptions(cit_ex, st_ex, doc_ex, ex_reg)
verifier("Exemption appliquee : reactive() l.2 et render*() l.3 (contexte a la ligne precedente) exemptees",
         identical(ex$exemptees$nom, c("reactive", "render*")) && identical(ex$exemptees$ligne, 2:3) &&
           identical(ex$exemptees$motif, c("m1", "m2")))
verifier("Exemption ancree sur son contexte : reactive() hors de la fenetre du contexte (l.6) reste un ecart",
         identical(ex$ecarts$nom, "reactive") && identical(ex$ecarts$lignes, "6"))
verifier("Exemption perimee (aucune citation introuvable correspondante) signalee",
         identical(ex$perimees$nom, "shinyApp"))
ex2 <- cc$appliquer_exemptions(cit_ex, c(reactive = "moteur ou affichage", "render*" = "INTROUVABLE"),
                               doc_ex, ex_reg[1:2])
verifier("Exemption d'un nom devenu trouvable : perimee, pas d'ecart pour ce nom",
         identical(ex2$perimees$nom, "reactive") && !nrow(ex2$ecarts))
verifier("Liste EXEMPTES_CODE du script : reactive et render*, motif de la colonne Interdit",
         identical(vapply(cc$EXEMPTES_CODE, `[[`, "", "nom"), c("reactive", "render*")) &&
           all(grepl("Interdit", vapply(cc$EXEMPTES_CODE, `[[`, "", "motif"))))

## --- Seuil de B (structure de la table des tests dependante de B) ---------
.err <- function(expr) tryCatch({ expr; NA_character_ }, error = function(e) conditionMessage(e))
verifier("B_MIN = 21 : premier B pour lequel length(usp_b) > 20 (condition de run_engine())",
         identical(cc$B_MIN, 21L))
verifier("valider_B : 21 et \"99\" acceptes, renvoyes en entier",
         identical(cc$valider_B(21), 21L) && identical(cc$valider_B("99"), 99L))
verifier("valider_B : 20 refuse, message citant la condition du moteur et la ligne perdue",
         grepl("B >= 21 requis", .err(cc$valider_B(20)), fixed = TRUE) &&
           grepl("length(usp_b) > 20", .err(cc$valider_B(20)), fixed = TRUE) &&
           grepl("Largeur relative de l'IC bootstrap 90%", .err(cc$valider_B("1")), fixed = TRUE))
verifier("valider_B : valeurs non entieres refusees (abc, 25.5, vide)",
         all(grepl("entier attendu", c(.err(cc$valider_B("abc")), .err(cc$valider_B("25.5")),
                                       .err(cc$valider_B(""))), fixed = TRUE)))

## --- Mode --strict sur le document (execute le moteur, ~10 s par appel) ----
.racine <- normalizePath(file.path(.dossier, "..", ".."))
.lancer_concordance <- function(...) {
  ancien <- setwd(.racine); on.exit(setwd(ancien))
  sortie <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
                                     c("tests/concordance_doc_moteur.R", ...), stdout = TRUE, stderr = TRUE))
  list(code = if (is.null(attr(sortie, "status"))) 0L else attr(sortie, "status"), sortie = sortie)
}
.tex_mutant <- tempfile(fileext = ".tex")
writeLines(c(readLines(file.path(.racine, "docs", "latex", "doc_tests_usp.tex"), warn = FALSE, encoding = "UTF-8"),
             "Mutant : \\code{fonction\\_inventee\\_xyz()}."), .tex_mutant, useBytes = TRUE)
r_mut <- .lancer_concordance("--strict", "--tex", .tex_mutant)
unlink(.tex_mutant)
verifier("--strict echoue (code 1) sur un nom invente dans une copie du .tex, signale comme ecart non exempte",
         r_mut$code == 1L && any(grepl("^    fonction_inventee_xyz\\(\\) ", r_mut$sortie)) &&
           any(grepl("non exempte", r_mut$sortie)))
verifier("Recapitulatif de la section 1 sur la copie mutante : 1 nom INTROUVABLE non exempte",
         any(grepl("^  INTROUVABLE non exempte +1$", r_mut$sortie)))
r_act <- .lancer_concordance("--strict")
r_b20 <- .lancer_concordance("--B", "20")
verifier("--B 20 refuse par le script lance (code 1, erreur explicite, moteur non execute)",
         r_b20$code == 1L && any(grepl("--B = 20 refuse", r_b20$sortie, fixed = TRUE)) &&
           !any(grepl("^=== 2", r_b20$sortie)))
verifier("--strict reussit (code 0) sur l'etat actuel du depot",
         r_act$code == 0L)
verifier("Recapitulatif de la section 1 apres exemptions : 2 noms exemptes, aucun INTROUVABLE non exempte",
         any(grepl("^  exempte \\(EXEMPTES_CODE\\) +2$", r_act$sortie)) &&
           !any(grepl("^  INTROUVABLE", r_act$sortie)))
verifier("Etat actuel : reactive() et render*() exemptes, aucune exemption perimee",
         sum(grepl("^    (reactive|render\\*)\\(\\) +ligne [0-9]+ +primitive Shiny", r_act$sortie)) == 2L &&
           !any(grepl("perimee", r_act$sortie)))

fin_fichier()
