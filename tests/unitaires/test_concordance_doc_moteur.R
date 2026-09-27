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
#  nominatives (appliquee, ancree sur son contexte, perimee, jugee sans
#  paquet : issue #86), colonne "Cle MC" (issue #91 : cles, fins de rangee
#  \\, \\* et \\[..], rangee non terminee), seuil de B
#  (valider_B(), --B sous B_MIN refuse), recapitulatif apres exemptions et
#  mode --strict (script lance sur une copie modifiee du .tex). L'etat reel
#  du depot n'est pas juge ici : c'est l'etape --strict de la CI qui le fait
#  (decision (a) du mainteneur sur l'audit de #65).
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
# Issue #86 : un nom exempte est juge sans consulter les paquets. Simule avec
# tools (installe avec R, non attache par Rscript) a la place de shiny :
# file_ext() et le joker file_* ne sont trouves que dans le paquet.
.env86 <- new.env(parent = globalenv())
.ex86 <- list(list(nom = "file_ext", contexte = "x", fenetre = 0L, motif = "m"),
              list(nom = "file_*", contexte = "x", fenetre = 0L, motif = "m"))
.st86 <- cc$statuts_citations(c("file_ext", "file_*", "md5sum"), .env86, paquets = "tools", exemptions = .ex86)
.st86_sans <- cc$statuts_citations(c("file_ext", "file_*"), .env86, paquets = "tools", exemptions = list())
verifier("Issue #86 (temoin) : sans exemption, file_ext() et file_*() sont trouves dans le paquet tools",
         identical(.st86_sans[["file_ext"]], "paquet tools") && startsWith(.st86_sans[["file_*"]], "joker ("))
verifier("Issue #86 : nom et joker exemptes juges sans paquet (INTROUVABLE), nom non exempte trouve dans le paquet",
         identical(unname(.st86), c("INTROUVABLE", "INTROUVABLE", "paquet tools")))
verifier("Liste EXEMPTES_CODE du script : reactive et render*, motif de la colonne Interdit",
         identical(vapply(cc$EXEMPTES_CODE, `[[`, "", "nom"), c("reactive", "render*")) &&
           all(grepl("Interdit", vapply(cc$EXEMPTES_CODE, `[[`, "", "motif"))))

## --- Colonne "Cle MC" de l'index des fonctions (issue #91) ----------------
doc_mc <- c("\\code{A} & x \\\\",
            "\\begin{longtable}{ll}",
            "\\textbf{Test} & \\textbf{Cl\u00e9 MC} \\\\",
            "\\endfirsthead",
            "\\multicolumn{2}{l}{\\textit{Suite page suivante}} \\\\",
            "\\endlastfoot",
            "\\multicolumn{2}{l}{\\textbf{Hypothèse H1}} \\\\",
            "\\midrule",
            "Student & \\code{test\\_intercept()} (Dallal \\& Wilkinson) & \\code{Intercept} \\\\",
            "Spearman & \\code{stats::cor.test()} & \\code{SpearVol} /",
            "\\code{SpearTps} \\\\",
            "TOST & \\code{test\\_tost\\_intercept()} & --- \\\\",
            "\\multicolumn{2}{l}{\\textbf{Méthode Merz--Wüthrich --- M1}} \\\\",
            "Pente & \\code{.mw\\_lm\\_intra()} & \\code{Intercept} \\\\",
            "Bootstrap & \\code{mw\\_bootstrap()} & toutes les clés ci-dessus \\\\",
            "\\end{longtable}")
cles_mc <- cc$cles_mc_index(doc_mc)
verifier("cles_mc_index : cles de la derniere colonne apres \\endlastfoot, methode de l'intertitre, ligne exacte",
         identical(cles_mc$cle, c("Intercept", "SpearVol", "SpearTps", "Intercept")) &&
           identical(cles_mc$methode, c("USP", "USP", "USP", "MW")) &&
           identical(cles_mc$ligne, c(9L, 10L, 11L, 14L)))
verifier("cles_mc_index : NULL si le tableau a en-tete Cle MC est absent",
         is.null(cc$cles_mc_index(doc_mc[-3])))
.cat_mc <- list(USP = c("Intercept", "SpearVol", "SpearTps"), MW = c("PenteIntra", "Origine"))
e_mc <- cc$verifier_cles_mc(cles_mc, .cat_mc)
verifier("Issue #91 : cle USP (Intercept) citee sous un intertitre Merz--Wuthrich signalee, avec son catalogue d'origine",
         identical(e_mc$cle, "Intercept") && identical(e_mc$ligne, 14L) &&
           identical(e_mc$motif, "absente du catalogue MW (cle du catalogue USP)"))
verifier("verifier_cles_mc : cle hors de toute section signalee ; aucune cle, aucun ecart",
         identical(cc$verifier_cles_mc(data.frame(ligne = 1L, cle = "SW", methode = NA_character_,
                                                  stringsAsFactors = FALSE), .cat_mc)$motif,
                   "hors de toute section de methode") &&
           !nrow(cc$verifier_cles_mc(cles_mc[0, ], .cat_mc)))
verifier("cles_mc_index : toutes les rangees terminees -> attribut non_terminee a NA",
         identical(attr(cles_mc, "non_terminee"), NA_integer_))
# Audit R3 : une rangee terminee par \\[2pt] ou \\* ne doit pas fusionner
# avec la suivante (la cle MW mal placee etait alors avalee en silence).
.doc_esp <- doc_mc
.doc_esp[14] <- "Pente & \\code{.mw\\_lm\\_intra()} & \\code{Intercept} \\\\[2pt]"
.doc_esp[12] <- "TOST & \\code{test\\_tost\\_intercept()} & --- \\\\*"
.cles_esp <- cc$cles_mc_index(.doc_esp)
verifier("Fin de rangee \\\\[2pt] et \\\\* reconnues : memes cles, cle USP sous M1 (l.14) toujours signalee",
         identical(.cles_esp$cle, cles_mc$cle) && identical(.cles_esp$methode, cles_mc$methode) &&
           identical(cc$verifier_cles_mc(.cles_esp, .cat_mc)$ligne, 14L) &&
           is.na(attr(.cles_esp, "non_terminee")))
.doc_nt <- doc_mc
.doc_nt[15] <- "Bootstrap & \\code{mw\\_bootstrap()} & \\code{Origine}"
verifier("Rangee non terminee avant \\end{longtable} signalee (attribut non_terminee = ligne de debut)",
         identical(attr(cc$cles_mc_index(.doc_nt), "non_terminee"), 15L))

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
# Issue #91 : regression reelle (e2eabea) reinjectee dans une copie du .tex,
# la cle MW PenteIntra remplacee par la cle USP Intercept sur la ligne M1,
# rangee terminee par \\[2pt] (essai A de l'audit R3 : fin de rangee avec
# espacement, qui fusionnait auparavant avec la rangee suivante).
.tex_91 <- readLines(file.path(.racine, "docs", "latex", "doc_tests_usp.tex"), warn = FALSE, encoding = "UTF-8")
.k91 <- grep("& \\code{PenteIntra} \\\\", .tex_91, fixed = TRUE)
.tex_mutant <- tempfile(fileext = ".tex")
writeLines(sub("& \\code{PenteIntra} \\\\", "& \\code{Intercept} \\\\[2pt]", .tex_91, fixed = TRUE),
           .tex_mutant, useBytes = TRUE)
r_91 <- .lancer_concordance("--strict", "--tex", .tex_mutant)
unlink(.tex_mutant)
verifier("Issue #91 : --strict echoue (code 1) sur la cle USP Intercept injectee a la ligne M1 (fin \\\\[2pt]) d'une copie du .tex",
         length(.k91) == 1L && r_91$code == 1L &&
           any(grepl(sprintf("^    l\\.%-5d Intercept +absente du catalogue MW \\(cle du catalogue USP\\)$", .k91),
                     r_91$sortie)))
r_b20 <- .lancer_concordance("--B", "20")
verifier("--B 20 refuse par le script lance (code 1, erreur explicite, moteur non execute)",
         r_b20$code == 1L && any(grepl("--B = 20 refuse", r_b20$sortie, fixed = TRUE)) &&
           !any(grepl("^=== 2", r_b20$sortie)))
# Natures des p retenues (#44, reprise) : exacte, sous le modele auxiliaire
# MCO, Monte-Carlo, asymptotique et sans p retenue partitionnent les lignes.
# Lignes construites en memoire (une par nature), et table du moteur sur les
# donnees de test (usp_tests() a bootstrap fictif, sans run_engine()).
verifier("grandeurs_moteur : les cinq categories de nature partitionnent les lignes (somme = total)",
         {
           cinq <- c("nature exacte", "nature modele auxiliaire MCO", "nature Monte-Carlo",
                     "nature asymptotique", "sans p-value retenue")
           lg <- lapply(c("exacte", "sous le modele auxiliaire MCO : t(T-2) exacte, marge fixee a priori",
                          "Monte-Carlo (bootstrap parametrique)", "asymptotique (motif)", NA),
                        function(n) list(nature_p = n, type = "test", famille = "B."))
           g <- cc$grandeurs_moteur(lg)
           xs <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
           ys <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
           fx <- usp_ajuster(xs, ys); so <- .stats_bootstrapables(fx$x, fx$y, fx$z)
           tt <- usp_tests(fx, list(stats_obs = as.list(so), p_mc = so * 0 + 0.5,
                                    err_mc = so * 0 + 0.01), methode = "premium")
           g2 <- cc$grandeurs_moteur(tt)
           all(g[cinq] == 1) && sum(g[cinq]) == g[["lignes (total)"]] &&
             sum(g2[cinq]) == g2[["lignes (total)"]] && g2[["nature modele auxiliaire MCO"]] >= 1
         })
# Aucune assertion sur l'etat reel du depot (--strict sur le .tex versionne,
# recapitulatif apres exemptions, exemptions perimees) : elle ferait echouer
# test_unitaires.R sur un ecart de concordance, et sauter en CI l'etape de
# reproductibilite qui la suit. Ce controle est porte par l'etape
# "Concordance documentation <-> moteur (--strict)" de ci.yml, qui s'execute
# meme apres un echec des tests (issue #65, decision (a) du mainteneur).

fin_fichier()
