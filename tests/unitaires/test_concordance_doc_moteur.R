###############################################################################
#  tests/unitaires/test_concordance_doc_moteur.R  --  EXTRACTION DES
#  CITATIONS ET DES DECOMPTES DU LATEX (issues #65, #75)
#
#  Teste les fonctions d'extraction de tests/concordance_doc_moteur.R sur des
#  chaines LaTeX construites en memoire, sans lire le document ni executer le
#  moteur (sauf le dernier bloc, qui lance le script) : \code{} imbriques, noms coupes en deux \code{}, commentaires,
#  desechappement, citations de fonction (qualifiees, internes, a joker,
#  avec arguments), nombres en lettres, registre des decomptes (phrase
#  verifiee, ecart, phrase introuvable, methode multiple), inventaire par
#  occurrence et classement des formulations (verifiee, exemptee, non
#  classee, exemption perimee ; issue #75 ; audit de #75 : verifiee a la
#  seule position d'un nombre capture, qualificatif intercale, nombre en
#  mode mathematique, nombres en lettres jusqu'a cent, risque residuel des
#  exemptions de provenance), grandeurs, familles, exemptions
#  nominatives (appliquee, ancree sur son contexte, perimee, jugee sans
#  paquet : issue #86), colonne "Cle MC" (issue #91 : cles, fins de rangee
#  \\, \\* et \\[..], rangee non terminee), seuil de B
#  (valider_B(), --B sous B_MIN = B_MIN_USAGE refuse), rubrique 7 et tableau de
#  tracabilite (issue #114 : presence, unicite, position apres \Usage,
#  fiches hors registre, registre confronte a des lignes du moteur
#  construites en memoire, rangees manquantes, en double ou non reconnues,
#  chemins cites inexistants, injections dans une copie du .tex),
#  recapitulatif apres exemptions et
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
verifier("Inventaire : 'N lignes' / 'N entrees' / 'N tests' en chiffres et en lettres, une ligne par occurrence",
         identical(inv$ligne, c(1L, 2L, 2L, 3L, 3L)) &&
           identical(inv$formulation, c("50 lignes", "Dix-neuf entr\u00e9es", "quinze tests", "six lignes", "3 entr\u00e9es")))

## --- Classement des formulations (issue #75) --------------------------------
doc75 <- c("Au total, des 50 lignes de la table auditable, et un test",
           "isol\u00e9 ; puis Treize de ces quinze",
           "tests reposent sur le bootstrap. Ailleurs, les deux tests pr\u00e9c\u00e9dents",
           "et enfin 51 lignes de tests pour la prime.")
reg75 <- list(
  list(id = "total", methode = "m", motif = paste0("des ", cc$N_, " lignes de la table auditable"),
       champs = "lignes (total)"),
  list(id = "boot", methode = c("m", "m2"), motif = paste0(cc$N_, " de ces ", cc$N_, " tests reposent"),
       champs = c("nature Monte-Carlo", "type test")))
ex75 <- list(list(id = "anaphore", contexte = "les deux tests pr\u00e9c\u00e9dents", motif = "a"),
             list(id = "perimee", contexte = "phrase disparue", motif = "b"))
g75 <- list(m = c("lignes (total)" = 50, "nature Monte-Carlo" = 13, "type test" = 15),
            m2 = c("nature Monte-Carlo" = 12, "type test" = 15))
inv75 <- cc$inventaire_decomptes(doc75)
verifier("Inventaire : formulation coupee par un retour a la ligne trouvee (l.2 a 3) ; 'un test' (singulier) ignore",
         identical(inv75$formulation, c("50 lignes", "quinze tests", "deux tests", "51 lignes")) &&
           identical(inv75$ligne, c(1L, 2L, 3L, 4L)) && identical(inv75$ligne_fin, c(1L, 3L, 3L, 4L)))
v75 <- cc$verifier_decomptes(doc75, g75, reg75)
verifier("Registre, methode multiple : une ligne par methode et par grandeur, prefixe de methode ; 13 contre 12 -> ecart",
         identical(v75$grandeur[v75$assertion == "boot"],
                   c("m : nature Monte-Carlo", "m : type test", "m2 : nature Monte-Carlo", "m2 : type test")) &&
           identical(v75$statut[v75$assertion == "boot"], c("ok", "ok", "ECART", "ok")) &&
           all(v75$ligne[v75$assertion == "boot"] == 2L) && all(v75$ligne_fin[v75$assertion == "boot"] == 3L))
cl75 <- cc$classer_formulations(doc75, v75, ex75)
verifier("Classement : verifiee (registre, y compris a cheval sur deux lignes), exemptee, NON CLASSEE",
         identical(cl75$formulations$statut, c("verifiee", "verifiee", "exemptee", "NON CLASSEE")) &&
           identical(cl75$formulations$par, c("total", "boot", "anaphore", NA)))
verifier("Classement : exemption de decompte perimee signalee",
         identical(cl75$perimees$id, "perimee"))
verifier("Classement : une phrase du registre introuvable ne couvre aucune formulation",
         identical(cc$classer_formulations(doc75, cc$verifier_decomptes(doc75, g75, reg75[2]), list())$formulations$statut,
                   c("NON CLASSEE", "verifiee", "NON CLASSEE", "NON CLASSEE")))
# Audit de #75, C3 : un nombre NON capture dans l'etendue d'une phrase du
# registre n'est pas verifie par elle (il l'etait auparavant, la phrase
# couvrant toute formulation commencant dans son etendue).
.doc_c3 <- "Des 50 lignes de la table auditable, dont 7 lignes fixes, on retient tout."
.reg_c3 <- list(list(id = "c3", methode = "m", motif = paste0("des ", cc$N_, " lignes de la table auditable, dont"),
                     champs = "lignes (total)"))
.v_c3 <- cc$verifier_decomptes(c(.doc_c3), list(m = c("lignes (total)" = 50)), .reg_c3)
.cl_c3 <- cc$classer_formulations(.doc_c3, .v_c3, list())
.reg_c3l <- list(list(id = "c3l", methode = "m",
                      motif = paste0("des ", cc$N_, " lignes de la table auditable, dont 7 lignes fixes"),
                      champs = "lignes (total)"))
.cl_c3l <- cc$classer_formulations(.doc_c3, cc$verifier_decomptes(.doc_c3, list(m = c("lignes (total)" = 50)), .reg_c3l),
                                   list())
verifier("C3 : verifiee seulement a la position d'un groupe capturant ; nombre non capture dans l'etendue d'une phrase -> NON CLASSEE",
         identical(.v_c3$pos_cap, 5L) &&
           identical(.cl_c3$formulations$formulation, c("50 lignes", "7 lignes")) &&
           identical(.cl_c3$formulations$statut, c("verifiee", "NON CLASSEE")) &&
           identical(.cl_c3l$formulations$statut, c("verifiee", "NON CLASSEE")))
verifier("C3 : registre dont le nombre de groupes capturants differe du nombre de champs -> erreur explicite",
         grepl("groupe(s) capturant(s)", tryCatch({
           cc$verifier_decomptes(.doc_c3, list(m = c("lignes (total)" = 50)),
                                 list(list(id = "x", methode = "m", motif = paste0("des ", cc$N_, " lignes"),
                                           champs = c("a", "b")))); ""
         }, error = function(e) conditionMessage(e)), fixed = TRUE))

## --- Audit de #75, C2 : qualificatif intercale, mode mathematique, cent ----
verifier("nombre_fr : jusqu'a cent (soixante-dix, soixante-et-onze, quatre-vingts, quatre-vingt-dix-neuf, cent)",
         identical(unname(vapply(c("soixante-dix", "soixante-et-onze", "quatre-vingts", "quatre-vingt",
                                   "quatre-vingt-un", "quatre-vingt-dix-neuf", "cent", "vingts"),
                                 cc$nombre_fr, numeric(1))),
                   c(70, 71, 80, 80, 81, 99, 100, NA)))
.doc_c2 <- c("On compte $6$ lignes, puis quatre-vingts lignes et quatre-vingt-dix-neuf entr\u00e9es ;",
             "les cinq autres lignes, les deux derni\u00e8res entr\u00e9es, les trois autres m\u00eames tests ;",
             "mais six grandes lignes et deux cents lignes ne sont pas lues.")
.inv_c2 <- cc$inventaire_decomptes(.doc_c2)
verifier("Inventaire C2 : $6$ lignes, quatre-vingts lignes, quatre-vingt-dix-neuf entrees, un ou deux qualificatifs intercales",
         identical(.inv_c2$formulation,
                   c("6 lignes", "quatre-vingts lignes", "quatre-vingt-dix-neuf entr\u00e9es", "cinq autres lignes",
                     "deux derni\u00e8res entr\u00e9es", "trois autres m\u00eames tests")) &&
           identical(unname(vapply(sub(" .*$", "", .inv_c2$formulation), cc$nombre_fr, numeric(1))),
                     c(6, 80, 99, 5, 2, 3)))
.id_r <- "prime : lignes de base r hors suites (restent en Monte-Carlo)"
.reg_r <- Filter(function(a) identical(a$id, .id_r), cc$DECOMPTES)
.doc_r <- c("Les six autres lignes de la base \u00ab ratios bruts \u00bb restent en Monte-Carlo dans tous les",
            "r\u00e9gimes.")
.g_r <- list(premium = c("base r hors suites" = 5, "base r hors suites Monte-Carlo" = 5))
.v_r <- cc$verifier_decomptes(.doc_r, .g_r, .reg_r)
.cl_r <- cc$classer_formulations(.doc_r, .v_r, list())
verifier("C2 : decompte faux apres un qualificatif intercale (six autres lignes, mesure 5) -> ECART sur les deux grandeurs, formulation verifiee",
         length(.reg_r) == 1L && identical(.v_r$annonce, c(6, 6)) && identical(.v_r$statut, c("ECART", "ECART")) &&
           identical(.cl_r$formulations$formulation, "six autres lignes") &&
           identical(.cl_r$formulations$statut, "verifiee"))
verifier("C2 : meme phrase juste (cinq), une ligne de base r hors suites sortie de Monte-Carlo -> ECART sur la seconde grandeur",
         identical(cc$verifier_decomptes(sub("six", "cinq", .doc_r),
                                         list(premium = c("base r hors suites" = 5, "base r hors suites Monte-Carlo" = 4)),
                                         .reg_r)$statut, c("ok", "ECART")))
verifier("grandeurs_moteur : lignes de base r hors test des suites, et parmi elles en Monte-Carlo",
         {
           lr <- list(list(base = "r", test = "Test des suites sur ratios bruts", nature_p = "exacte"),
                      list(base = "r", test = "Grubbs sur ratios bruts", nature_p = "Monte-Carlo (bootstrap parametrique)"),
                      list(base = "r", test = "sup-F sur ratios bruts", nature_p = "asymptotique (x)"),
                      list(base = "z", test = "Grubbs", nature_p = "Monte-Carlo (bootstrap parametrique)"))
           g <- cc$grandeurs_moteur(lr)
           isTRUE(all(unname(g[c("base r hors suites", "base r hors suites Monte-Carlo")]) == c(2, 1)))
         })
verifier("Exemptions de provenance par fonction : motif ecrivant le risque residuel (code change, document non)",
         sum(vapply(cc$EXEMPTES_DECOMPTES, function(e) grepl("risque residuel", e$motif, fixed = TRUE), logical(1))) == 8L)
verifier("Registre et exemptions du script : identifiants uniques, motif ecrit pour chaque exemption",
         !anyDuplicated(vapply(cc$DECOMPTES, `[[`, "", "id")) &&
           !anyDuplicated(vapply(cc$EXEMPTES_DECOMPTES, `[[`, "", "id")) &&
           all(nzchar(vapply(cc$EXEMPTES_DECOMPTES, `[[`, "", "motif"))))
verifier("grandeurs_moteur : base, variante, suites, grandeur rivee, sans objet, p exacte hors base r, famille x type, res$controles",
         {
           lg <- list(list(famille = "E. x", type = "test", base = "z", test = "Test des suites (x)", p_exacte = 0.5),
                      list(famille = "E. x", type = "test", base = "r", test = "Test des suites sur ratios bruts",
                           p_exacte = 0.5, detail = "a. CONTROLE SANS OBJET ICI : b"),
                      list(famille = "E. x", type = "diagnostic", base = "commun", variante = "secondaire",
                           detail = "Grandeur rivee par l'estimation : c", p_exacte = NA_real_))
           g <- cc$grandeurs_moteur(lg, controles = list(list(famille = "A. y"), list(famille = "H. z")))
           isTRUE(all(unname(g[c("base z", "base r", "variante secondaire", "lignes du test des suites",
                                 "grandeur rivee", "detail sans objet ici", "p exacte hors base r",
                                 "famille E. type test", "famille E. type diagnostic",
                                 "controles (total)", "controles famille H.")]) ==
                        c(1, 1, 1, 2, 1, 1, 1, 2, 1, 2, 1)))
         })
verifier("grandeurs_moteur : p exacte hors base r retenue, lignes non applicables a volumes constants (#59)",
         {
           lg <- list(list(base = "z", p_exacte = 0.5, nature_p = "exacte"),
                      list(base = "commun", p_exacte = 0.5, nature_p = "Monte-Carlo (bootstrap parametrique)"),
                      list(base = "r", p_exacte = 0.5, nature_p = "exacte"),
                      list(base = "commun", type = "non applicable",
                           detail = "volumes x_t constants a la tolerance relative TOL_DELTA_BORD = 1e-06 pres"),
                      list(base = "commun", type = "non applicable", detail = "autre motif ; volumes x_t constants a la tolerance relative"))
           g <- cc$grandeurs_moteur(lg)
           isTRUE(all(unname(g[c("p exacte hors base r", "p exacte hors base r retenue",
                                 "non applicable volumes constants")]) == c(2, 1, 1)))
         })
.reg_59 <- Filter(function(a) grepl("(#59)", a$id, fixed = TRUE), cc$DECOMPTES)
.doc_59 <- c("(fiche \\ref{fiche:position-delta}), et treize lignes d'\\code{usp\\_tests()} sont restitu\u00e9es",
             "\u00ab~non applicable~\u00bb, sans verdict")
verifier("Registre (#59) : treize lignes non applicables, mesurees sur les deux executions a volumes constants",
         length(.reg_59) == 1L &&
           identical(cc$verifier_decomptes(.doc_59, list(premium_vc = c("non applicable volumes constants" = 13),
                                                          reserve1_vc = c("non applicable volumes constants" = 12)),
                                           .reg_59)$statut, c("ok", "ECART")))
verifier("grandeurs_code : tailles des catalogues et lignes Merz-Wuthrich sur residus",
         identical(cc$grandeurs_code(list(USP_CATALOGUE_MC = list(a = 1, b = 2), MW_CATALOGUE_MC = list(c = 3),
                                          .MW_LIGNES_RESIDUS = list(M1 = "u", M2 = c("v", "w")))),
                   c("catalogue USP" = 2L, "catalogue MW" = 1L, "lignes MW sur residus" = 3L)))

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
verifier("B_MIN = B_MIN_USAGE = 99, lu dans R/engine.R (minimum admis par run_engine(), au-dessus de length(usp_b) > 20)",
         identical(cc$B_MIN, 99L) && identical(cc$B_MIN, as.integer(B_MIN_USAGE)) && cc$B_MIN > 20L)
verifier("valider_B : 99 et \"999\" acceptes, renvoyes en entier",
         identical(cc$valider_B(99), 99L) && identical(cc$valider_B("999"), 999L))
verifier("valider_B : 98 et 20 refuses, message citant B_MIN_USAGE, la condition de l'IC et la ligne perdue",
         grepl("B >= B_MIN_USAGE = 99 requis", .err(cc$valider_B(98)), fixed = TRUE) &&
           grepl("B >= B_MIN_USAGE = 99 requis", .err(cc$valider_B(20)), fixed = TRUE) &&
           grepl("length(usp_b) > 20", .err(cc$valider_B(98)), fixed = TRUE) &&
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
# Issue #75 : deux injections dans une meme copie du .tex (un seul appel du
# script) -- un decompte faux dans une phrase du registre ("Treize de ces
# quinze tests" -> "Douze", mesure 13) et une formulation nouvelle ni
# verifiee ni exemptee (l'exemple de faux negatif de l'ancien en-tete,
# "51 lignes de tests pour la prime").
.tex_75 <- readLines(file.path(.racine, "docs", "latex", "doc_tests_usp.tex"), warn = FALSE, encoding = "UTF-8")
.k75 <- grep("Treize de ces quinze", .tex_75, fixed = TRUE)
.tex_mutant <- tempfile(fileext = ".tex")
.k75r <- grep("Les cinq autres lignes de la base", .tex_75, fixed = TRUE)
writeLines(c(sub("Les cinq autres lignes de la base", "Les six autres lignes de la base",
                 sub("Treize de ces quinze", "Douze de ces quinze", .tex_75, fixed = TRUE), fixed = TRUE),
             "Mutant : on compte 51~lignes de tests pour la prime.",
             "Mutant : puis $6$ lignes et quatre-vingts lignes."), .tex_mutant, useBytes = TRUE)
r_75 <- .lancer_concordance("--strict", "--tex", .tex_mutant)
unlink(.tex_mutant)
verifier("Issue #75 : --strict echoue (code 1) sur un decompte faux injecte dans une phrase du registre (annonce 12, mesure 13)",
         length(.k75) == 1L && r_75$code == 1L &&
           any(grepl(sprintf("^    \\[ECART +\\] l\\.%-5d Merz-Wuthrich : tests reposant sur le bootstrap +nature Monte-Carlo +annonce 12 +mesure 13$",
                             .k75), r_75$sortie)))
verifier("Issue #75 : formulations injectees ni verifiees ni exemptees signalees NON CLASSEES (51 lignes, $6$ lignes, quatre-vingts lignes), les autres restant classees",
         any(grepl(sprintf("^    l\\.%-5d 51 lignes ", length(.tex_75) + 1L), r_75$sortie)) &&
           any(grepl(sprintf("^    l\\.%-5d 6 lignes ", length(.tex_75) + 2L), r_75$sortie)) &&
           any(grepl(sprintf("^    l\\.%-5d quatre-vingts lignes ", length(.tex_75) + 2L), r_75$sortie)) &&
           any(grepl("^  ECART -- 3 formulation\\(s\\) ni verifiee\\(s\\)", r_75$sortie)))
verifier("Audit de #75, C2 : --strict signale le decompte faux injecte apres un qualificatif intercale (six autres lignes, mesure 5)",
         length(.k75r) == 1L &&
           any(grepl(sprintf("^    \\[ECART +\\] l\\.%-5d prime : lignes de base r hors suites .* base r hors suites +annonce 6 +mesure 5$",
                             .k75r), r_75$sortie)))
r_b98 <- .lancer_concordance("--B", "98")
verifier("--B 98 refuse par le script lance (code 1, erreur explicite, moteur non execute)",
         r_b98$code == 1L && any(grepl("--B = 98 refuse", r_b98$sortie, fixed = TRUE)) &&
           !any(grepl("^=== 2", r_b98$sortie)))
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
# Issue #114 : rubrique 7 "Pertinence et puissance a faible T" et tableau de
# tracabilite, sur des chaines LaTeX en memoire.
.t7 <- c("\\newcommand{\\Pertinence}{\\item[7.]}",          # 1  definition : ignoree
         "\\begin{fiche}{A}", "\\label{fiche:a}%",            # 2-3
         "\\Cadre x", "\\Usage u", "\\Pertinence p",          # 4-6  rubrique 7 apres \Usage
         "\\end{fiche}",                                      # 7
         "\\begin{fiche}{B}", "\\label{fiche:b}%",            # 8-9
         "\\Usage u \\PertinenceX", "\\end{fiche}",           # 10-11 \PertinenceX : autre macro
         "\\begin{fiche}{C}", "\\label{fiche:c}%",            # 12-13
         "\\Pertinence p", "\\Usage u", "\\end{fiche}",       # 14-16 rubrique 7 avant \Usage
         "\\begin{fiche}{D}", "\\label{fiche:d}%",            # 17-18
         "\\Usage u", "\\Pertinence p", "\\Pertinence q",     # 19-21 rubrique 7 deux fois
         "\\end{fiche}",                                      # 22
         "\\begin{fiche}{E}", "Sans label", "\\Usage",        # 23-25 fiche sans label nomme
         "\\Pertinence", "\\end{fiche}",                      # 26-27
         "% \\Pertinence commentee", "\\Pertinence hors fiche", # 28-29
         "\\begin{fiche}{F}", "\\label{fiche:f}%")            # 30-31 fiche non terminee
.f7 <- cc$fiches_rubrique7(.t7)
verifier("Issue #114 : fiches_rubrique7() lit label, nombre de \\Pertinence et position par rapport a \\Usage",
         identical(.f7$label, c("fiche:a", "fiche:b", "fiche:c", "fiche:d", NA)) &&
           identical(.f7$n_pertinence, c(1L, 0L, 1L, 2L, 1L)) &&
           identical(.f7$apres_usage, c(TRUE, FALSE, FALSE, TRUE, TRUE)) &&
           identical(.f7$ligne_pertinence, c(6L, NA, 14L, 20L, 26L)))
verifier("Issue #114 : \\Pertinence hors fiche signale (definition \\newcommand et commentaire exceptes), fiche non terminee signalee",
         identical(attr(.f7, "hors_fiche"), 29L) && identical(attr(.f7, "non_terminee"), 30L))
.e7 <- cc$verifier_rubrique7(.f7, c("fiche:a", "fiche:b", "fiche:c", "fiche:z"))
.a_motif <- function(e, label, rx, ligne = NULL)
  any((if (is.na(label)) is.na(e$label) else e$label %in% label) & grepl(rx, e$motif) &
        (if (is.null(ligne)) TRUE else e$ligne %in% ligne))
verifier("Issue #114 : fiche de test sans rubrique 7 (fiche du registre) signalee",
         .a_motif(.e7, "fiche:b", "^rubrique 7 absente de la fiche$", 8L))
verifier("Issue #114 : rubrique 7 sur une fiche hors du registre (diagnostic) signalee",
         .a_motif(.e7, "fiche:d", "hors du registre", 20L))
verifier("Issue #114 : rubrique 7 avant \\Usage signalee",
         .a_motif(.e7, "fiche:c", "avant \\\\Usage", 14L))
verifier("Issue #114 : rubrique 7 presente deux fois signalee",
         .a_motif(.e7, "fiche:d", "presente 2 fois", 20L))
verifier("Issue #114 : rubrique 7 dans une fiche sans label nomme, hors fiche, fiche non terminee, label du registre introuvable",
         .a_motif(.e7, NA, "sans label nomme", 26L) && .a_motif(.e7, NA, "hors de tout environnement", 29L) &&
           .a_motif(.e7, NA, "non termine", 30L) && .a_motif(.e7, "fiche:z", "introuvable dans le document"))
verifier("Issue #114 : aucune autre signalisation (fiche:a conforme ; 8 ecarts au total)",
         !any(.e7$label %in% "fiche:a") && nrow(.e7) == 8L)
verifier("Issue #114 : fiche sans \\Usage portant la rubrique 7 signalee",
         .a_motif(cc$verifier_rubrique7(cc$fiches_rubrique7(c("\\begin{fiche}{G}", "\\label{fiche:g}", "\\Pertinence",
                                                              "\\end{fiche}")), "fiche:g"),
                  "fiche:g", "sans \\\\Usage", 3L))

.tt <- c("\\subsection{Tracabilite}", "\\label{tab:tracabilite-puissance}",                         # 1-2
         "Script \\code{tests/concordance\\_doc\\_moteur.R}, sortie \\code{docs/tableaux/}\\newline",  # 3
         "\\code{absent\\_114.md} ; \\code{tests/} puis \\code{docs/} ; \\code{p\\_min}.",             # 4
         "\\begin{longtable}{lll}", "\\textbf{Test (fiche)} & a & b \\\\", "\\endhead",                # 5-7
         "\\bottomrule", "\\endlastfoot",                                                              # 8-9
         "\\multicolumn{3}{l}{\\textbf{M\\'ethode}} \\\\", "\\midrule",                                # 10-11
         "A (\\ref{fiche:a}) & \\code{f()} & \\code{tests/outils\\_tests.R} \\\\",                     # 12
         "B, variante (\\ref{fiche:b}) & x & --- \\\\",                                                # 13
         "B (\\ref{fiche:b}) & x & --- \\\\*",                                                         # 14
         "Sans renvoi & x & --- \\\\",                                                                 # 15
         "C (\\ref{fiche:c})", "& x & \\code{tests/inexistant\\_114.R} \\\\[2pt]",                     # 16-17
         "Non terminee (\\ref{fiche:d}) & x",                                                          # 18
         "\\end{longtable}")                                                                           # 19
.rg <- cc$lignes_tracabilite(.tt)
verifier("Issue #114 : lignes_tracabilite() lit une rangee par fiche (fins \\\\, \\\\* et \\\\[..], rangee sur deux lignes), intertitre ignore",
         identical(.rg$label, c("fiche:a", "fiche:b", "fiche:b", "fiche:c")) &&
           identical(.rg$ligne, c(12L, 13L, 14L, 16L)) &&
           identical(attr(.rg, "non_reconnues"), 15L) && identical(attr(.rg, "non_terminee"), 18L))
.etr <- cc$verifier_tracabilite(.rg, c("fiche:a", "fiche:c", "fiche:e"))
verifier("Issue #114 : rangee en double signalee",
         .a_motif(.etr, "fiche:b", "citee par 2 rangees", 14L))
verifier("Issue #114 : rangee manquante (fiche a rubrique 7 sans rangee) signalee",
         .a_motif(.etr, "fiche:e", "sans rangee"))
verifier("Issue #114 : rangee pour une fiche sans rubrique 7, rangee sans renvoi et rangee non terminee signalees",
         .a_motif(.etr, "fiche:b", "sans rubrique 7", 13L) && .a_motif(.etr, NA, "Nom \\(\\\\ref", 15L) &&
           .a_motif(.etr, NA, "non terminee", 18L) && nrow(.etr) == 5L &&
           !any(.etr$label %in% c("fiche:a", "fiche:c")))
verifier("Issue #114 : lignes_tracabilite() renvoie NULL sans le label du tableau",
         is.null(cc$lignes_tracabilite(.tt[-2L])))
.ch <- cc$chemins_tracabilite(.tt)
verifier("Issue #114 : chemins cites dans la sous-section, coupe en deux \\code{} recolle, texte intercale non recolle, champs et fonctions exclus",
         identical(.ch$chemin, c("tests/concordance_doc_moteur.R", "docs/tableaux/absent_114.md", "tests/", "docs/",
                                 "tests/outils_tests.R", "tests/inexistant_114.R")) &&
           identical(.ch$ligne, c(3L, 3L, 4L, 4L, 12L, 17L)))
.mq <- cc$verifier_chemins(.ch, .racine)
verifier("Issue #114 : fichier cite inexistant signale, fichiers et dossiers existants acceptes",
         identical(.mq$chemin, c("docs/tableaux/absent_114.md", "tests/inexistant_114.R")))

.reg <- list(list(label = "fiche:a", tests = c("A1", "A2")),
             list(label = "fiche:b", tests = "B", hors_jeux = "motif"),
             list(label = "fiche:c", tests = "C"),
             list(label = "fiche:d", tests = "D"))
.lm <- data.frame(test = c("A1", "A2", "B", "C", "X", "Z"),
                  type = c("test", "diagnostic", "diagnostic", "diagnostic", "procedure de decision", "diagnostic"),
                  stringsAsFactors = FALSE)
.er <- cc$verifier_registre_rubrique7(.lm, .reg)
verifier("Issue #114 : registre au moteur -- ligne de type procedure sans fiche, nom perime, fiche sans ligne de type test signales ; hors_jeux accepte",
         .a_motif(.er, NA, "rattachee a aucune fiche") && .er$test[is.na(.er$label)] == "X" &&
           .a_motif(.er, "fiche:d", "produit par aucune execution") &&
           .a_motif(.er, "fiche:c", "aucune ligne de type test") && nrow(.er) == 3L)
.lm$type[.lm$test == "B"] <- "test"
.reg[[4L]]$tests <- c("D", "A1")
.lm <- rbind(.lm, data.frame(test = "D", type = "diagnostic", stringsAsFactors = FALSE))
.er2 <- cc$verifier_registre_rubrique7(.lm, .reg)
verifier("Issue #114 : registre au moteur -- declaration hors_jeux perimee et ligne rattachee a deux fiches signalees",
         .a_motif(.er2, "fiche:b", "hors_jeux perimee") && .a_motif(.er2, "fiche:a, fiche:d", "plusieurs fiches"))
.labs <- vapply(cc$REGISTRE_RUBRIQUE7, `[[`, character(1), "label")
.noms <- unlist(lapply(cc$REGISTRE_RUBRIQUE7, `[[`, "tests"))
verifier("Issue #114 : registre REGISTRE_RUBRIQUE7 -- 53 fiches (decision du mainteneur du 27/09/2026), labels et noms uniques",
         length(.labs) == 53L && !anyDuplicated(.labs) && !anyDuplicated(.noms) &&
           all(grepl("^(fiche|mw):[a-z0-9-]+$", .labs)) && sum(startsWith(.labs, "mw:")) == 16L)
verifier("Issue #114 : jeu J2 lu dans test_controles_numeriques.R (T = 8)",
         { j <- cc$lire_jeu_j2(.racine); length(j$x) == 8L && length(j$y) == 8L })

# Issue #114 : injections dans une copie du .tex, un seul appel du script
# --strict, lignes conservees (remplacement de contenu, pas d'insertion) :
# rubrique 7 retiree d'une fiche de test (RESET), ajoutee a un diagnostic
# (R2), deplacee avant \Usage (White), doublee (Goldfeld-Quandt) ; rangee
# Lilliefors remplacee par un double de la rangee Jarque-Bera ; fichier cite
# inexistant (issue72-J2.md -> issue72-J3.md sur la rangee Fisher).
.tex_114 <- readLines(file.path(.racine, "docs", "latex", "doc_tests_usp.tex"), warn = FALSE, encoding = "UTF-8")
.bornes <- function(lab) {
  d <- grep(sprintf("\\label{%s}", lab), .tex_114, fixed = TRUE)
  f <- grep("\\end{fiche}", .tex_114, fixed = TRUE); c(d - 1L, f[f > d][1L])
}
.dans <- function(lab, rx) { b <- .bornes(lab); k <- grep(rx, .tex_114); k[k > b[1L] & k < b[2L]] }
.m <- .tex_114
.k_reset <- .dans("fiche:reset", "^\\\\Pertinence\\s*$"); .m[.k_reset] <- ""
.b_r2 <- .bornes("fiche:r2"); .m[.b_r2[2L] - 1L] <- paste(.m[.b_r2[2L] - 1L], "\\Pertinence")
.k_white <- .dans("fiche:white", "^\\\\Pertinence\\s*$"); .k_white_h <- .dans("fiche:white", "^\\\\Hzero")
.m[.k_white] <- ""; .m[.k_white_h] <- paste(.m[.k_white_h], "\\Pertinence")
.k_gq <- .dans("fiche:goldfeld-quandt", "^\\\\Pertinence\\s*$"); .m[.k_gq] <- "\\Pertinence \\Pertinence"
.k_li <- grep("(\\ref{fiche:lilliefors}) &", .tex_114, fixed = TRUE)
.k_jb <- grep("(\\ref{fiche:jarque-bera}) &", .tex_114, fixed = TRUE)
.m[.k_li] <- .tex_114[.k_jb]
.k_fi <- grep("(\\ref{fiche:fisher-global}) &", .tex_114, fixed = TRUE)
.m[.k_fi] <- sub("issue72-J2.md", "issue72-J3.md", .m[.k_fi], fixed = TRUE)
.tex_mutant <- tempfile(fileext = ".tex")
writeLines(.m, .tex_mutant, useBytes = TRUE)
r_114 <- .lancer_concordance("--strict", "--tex", .tex_mutant)
unlink(.tex_mutant)
.sortie_a <- function(ligne, label, rx) {
  lig <- gsub("?", "\\?", sprintf("%-5s", if (is.na(ligne)) "?" else ligne), fixed = TRUE)
  any(grepl(sprintf("^    l\\.%s %-34s %s", lig, label, rx), r_114$sortie))
}
verifier("Issue #114 : injections localisees dans la copie du .tex (une ligne chacune)",
         all(lengths(list(.k_reset, .k_white, .k_white_h, .k_gq, .k_li, .k_jb, .k_fi)) == 1L) &&
           !is.na(.b_r2[2L]) && .m[.k_fi] != .tex_114[.k_fi])
verifier("Issue #114 : --strict echoue (code 1) sur les injections de rubrique 7 et du tableau",
         r_114$code == 1L)
verifier("Issue #114 : --strict signale la fiche de test privee de rubrique 7 (RESET)",
         .sortie_a(.bornes("fiche:reset")[1L], "fiche:reset", "rubrique 7 absente de la fiche$"))
verifier("Issue #114 : --strict signale la rubrique 7 sur un diagnostic (R2)",
         .sortie_a(.b_r2[2L] - 1L, "fiche:r2", "rubrique 7 sur une fiche hors du registre"))
verifier("Issue #114 : --strict signale la rubrique 7 avant \\Usage (White) et en double (Goldfeld-Quandt)",
         .sortie_a(.k_white_h, "fiche:white", "rubrique 7 avant \\\\Usage") &&
           .sortie_a(.k_gq, "fiche:goldfeld-quandt", "rubrique 7 presente 2 fois"))
verifier("Issue #114 : --strict signale le tableau -- rangee en double, rangee manquante, rangee d'une fiche sans rubrique 7, fiche a rubrique 7 sans rangee",
         .sortie_a(max(.k_li, .k_jb), "fiche:jarque-bera", "fiche citee par 2 rangees") &&
           .sortie_a(NA, "fiche:lilliefors", "fiche a rubrique 7 sans rangee") &&
           .sortie_a(grep("(\\ref{fiche:reset}) &", .tex_114, fixed = TRUE), "fiche:reset", "rangee pour une fiche sans rubrique 7") &&
           .sortie_a(NA, "fiche:r2", "fiche a rubrique 7 sans rangee"))
verifier("Issue #114 : --strict signale le fichier cite inexistant (issue72-J3.md), et lui seul",
         any(grepl(sprintf("^    l\\.%-5d docs/tableaux/20260927-issue72-J3\\.md$", .k_fi), r_114$sortie)) &&
           any(grepl("^  ECART -- 1 chemin\\(s\\) cite\\(s\\) inexistant\\(s\\)", r_114$sortie)))

# Aucune assertion sur l'etat reel du depot (--strict sur le .tex versionne,
# recapitulatif apres exemptions, exemptions perimees) : elle ferait echouer
# test_unitaires.R sur un ecart de concordance, et sauter en CI l'etape de
# reproductibilite qui la suit. Ce controle est porte par l'etape
# "Concordance documentation <-> moteur (--strict)" de ci.yml, qui s'execute
# meme apres un echec des tests (issue #65, decision (a) du mainteneur).

fin_fichier()
