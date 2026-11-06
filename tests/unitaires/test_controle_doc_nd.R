###############################################################################
#  tests/unitaires/test_controle_doc_nd.R  --  CONTROLES DE CI SUR LA
#  DOCUMENTATION LATEX (branche ND, lot L0, issue #451)
#
#  Teste tests/controle_doc_nd.R sur des chaines et des fichiers construits en
#  memoire ou dans un dossier temporaire, sans lire docs/latex/ :
#    (a) motifs de la liste A : cas positifs (numero d'issue, ADR, Q-..., D1-...,
#        Mnn, sigle de branche, SHA, date de la vie du depot, decision du
#        mainteneur, nom d'agent, "jusqu'a cette issue") et cas negatifs
#        (QQ-plot, regle R14, M6, graine 20260831, fichier docs/tableaux/,
#        "valeurs issues du bootstrap", dates reglementaires 2015 et 2024,
#        \code{ND}, L-BFGS-B) ; liste B ; recouvrement de deux motifs d'un
#        meme id ; parties du document ; exception E3 (partie IV seulement) ;
#        exception sur mesure (perimee, levee, fenetre de lignes) ;
#    (b) plafond de pages : lecture d'un .aux synthetique, etendue, trois
#        verdicts (violation, a verifier, conforme), bornes, exception au
#        plafond (appliquee, perimee), repli sans labels -fin et sans .aux ;
#    (c) debordements : journal synthetique (Overfull hbox/vbox, borne de 1,5 pt) ;
#    (d) remplissage : marques et mots construits a la main (blanc, encadre
#        court coupe, titre, bandeau de section seul en bas de page, rubrique,
#        titre de fiche separe de la rubrique 1, pages en paysage), lecture d'un
#        fichier .remp, et passe de mesure reelle sur un petit document (pdflatex,
#        mdframed ; garde-fou du texte, dossier du document intact) ;
#    options : code de sortie sans et avec --bloquant, arguments refuses.
#  L'etat reel du .tex n'est pas juge ici : c'est l'etape de la CI qui le
#  publie (avertissement jusqu'au lot L7).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_controle_doc_nd.R")

.dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
.script <- file.path(.dossier, "..", "controle_doc_nd.R")
nd <- new.env(parent = globalenv())
sys.source(.script, envir = nd)

motifs <- function(x, ...) nd$nd_motifs_de(x, ...)
# Chaines accentuees ecrites en \u pour ne pas dependre de la locale du fichier.
dec <- "d\u00e9cision du mainteneur"

# --- (a) Cas positifs : le motif attendu est detecte --------------------------------
verifier("A1 : issue~\\#169", "A1" %in% motifs("issue~\\#169"))
verifier("A1 : (\\#40, \\#55) enumeration", "A1" %in% motifs("voir \\#40, \\#55"))
verifier("A3 : ADR~0002", "A3" %in% motifs("ADR~0002"))
verifier("A5 : Q-D1-Fb-1", "A5" %in% motifs("Q-D1-Fb-1"))
verifier("A5 : Q-46-15", "A5" %in% motifs("Q-46-15"))
verifier("A6 : D1-Fb", "A6" %in% motifs("D1-Fb"))
verifier("A6 : D1-7", "A6" %in% motifs("la d\u00e9cision D1-7"))
verifier("A7 : M27", "A7" %in% motifs("M27"))
verifier("A8 : branche~Fk", "A8" %in% motifs("branche~Fk"))
verifier("A8 : branche~ND", "A8" %in% motifs("branche~ND"))
verifier("A8 : E2c isole", "A8" %in% motifs("la branche E2c"))
verifier("A11 : fee9968", "A11" %in% motifs("commit fee9968"))
verifier("A10 : 6~octobre 2026", "A10" %in% motifs("6~octobre 2026"))
verifier("A10 : le 6 octobre 2026 (espace entre jour et mois)", "A10" %in% motifs("le 6 octobre 2026"))
verifier("A10 : date en fin de ligne, annee 2026 a la ligne suivante", "A10" %in% motifs(c("la decision du 6 octobre", "2026 a ete prise")))
verifier("A10 negatif : date en fin de ligne suivie de 2015 a la ligne suivante",
         identical(motifs(c("publie le 17 janvier", "2015 au Journal officiel")), character(0)))
verifier("A10 negatif : date de l'annee 2015 avec espace", identical(motifs("du 17 janvier 2015"), character(0)))
verifier("A13 : decision du en fin de ligne, 9 octobre a la ligne suivante",
         "A13" %in% motifs(c("(issue~\\#1, d\u00e9cision du", "9~octobre)")) && identical(motifs(c("la d\u00e9cision du", "t\u00e9moin y est")), character(0)))
verifier("A13 : decision du 9 octobre (chiffre)", "A13" %in% motifs("d\u00e9cision du 9 octobre"))
verifier("A4 : \\code{docs/}\\allowbreak\\code{references/}", "A4" %in% motifs("\\code{docs/}\\allowbreak\\code{references/x.md}"))
verifier("A4 : docs/ suivi d'un retour a la ligne \\newline", "A4" %in% motifs("\\code{docs/}\\newline \\code{specifications/}"))
verifier("A4 negatif : \\code{docs/}\\allowbreak\\code{tableaux/} reste admis", identical(motifs("\\code{docs/}\\allowbreak\\code{tableaux/x.md}"), character(0)))
verifier("A8 negatif Unicode : Frequence, Frechet; positif Fk", identical(motifs("Fr\u00e9quence Fr\u00e9chet"), character(0)) && "A8" %in% motifs("branche Fk"))
verifier("A9 negatif Unicode : Opuse; positif Opus", identical(motifs("Opus\u00e9"), character(0)) && "A9" %in% motifs("le modele Opus"))
verifier("A10 : jour et mois sans annee", "A10" %in% motifs("le 6~octobre"))
verifier("A10 : 1\\textsuperscript{er}~octobre", "A10" %in% motifs("1\\textsuperscript{er}~octobre"))
verifier("A10 : 23/09/2026", "A10" %in% motifs("23/09/2026"))
verifier("A10 : 2026-10-08", "A10" %in% motifs("2026-10-08"))
verifier("A10 : ao\u00fbt", "A10" %in% motifs("12~ao\u00fbt 2026"))
verifier("A13 et A9 : decision du mainteneur",
         all(c("A13", "A9") %in% motifs(dec)))
verifier("A9 : \\code{actuary}", "A9" %in% motifs("\\code{actuary}"))
verifier("A9 : cas d'audit 176", "A9" %in% motifs("cas d'audit~176"))
verifier("A12 : jusqu'a cette issue", "A12" %in% motifs("jusqu'\u00e0 cette issue"))
verifier("A12 : le moteur de l'issue~, sans numero", "A12" %in% motifs("avant l'issue, un nom"))
verifier("A13 : visee par", "A13" %in% motifs("vis\u00e9e par"))
verifier("A2 : commentaire 6021758543 (espace) et commentaire~6021758543", all(c("A2") %in% motifs("commentaire 6021758543")) && "A2" %in% motifs("commentaire~6021758543"))
verifier("A14 : execution 39394706119, execution~39394706119, run 41886457559, actions/runs/41886457559",
         all(vapply(c("par l'ex\u00e9cution 39394706119 du", "ex\u00e9cution~39394706119", "le run 41886457559", "actions/runs/41886457559"),
                    function(x) "A14" %in% motifs(x), logical(1))))
verifier("A4 : CONTEXT.md, .github/, feuille-de-route, docs/specifications/",
         all(vapply(c("CONTEXT.md", ".github/ci.yml", "feuille-de-route", "docs/specifications/x.md"),
                    function(x) "A4" %in% motifs(x), logical(1))))
verifier("A4 : docs/suivi-documentation/ hors partie IV (sans exception)",
         "A4" %in% motifs("docs/suivi-documentation/I.md"))

# --- (a) Cas negatifs : aucun motif de la liste A -----------------------------------------
negatifs <- c(
  "QQ-plot", "r\u00e8gle~R14", "M6", "20260831", "20260901",
  "docs/tableaux/20261008-issue220-pitman.md", "docs/tableaux/20260930-issue116-grille.tsv",
  "valeurs issues du bootstrap", "17~janvier 2015", "17~janvier~2015", "14~novembre 2024",
  "14 novembre 2024", "25.3.2015", "r\u00e8glement 2015/35", "EIOPA-BoS-14/178",
  "\\code{ND}", "\\code{annee,ND}", "L-BFGS-B", "AR(1)", "constat~C6", "J1 et J2",
  "\\annee", "Exercice 2026", "1961", "\u00e0 l'issue du calcul", "l'issue de la proc\u00e9dure",
  "mod\u00e8le d'effacee", "$0{,}1138150042$", "ex\u00e9cution du calcul", "ex\u00e9cutions de 1000 r\u00e9plications", "1.0000000000000011",
  "Fr\u00e9quence", "Fr\u00e9chet", "Opus\u00e9", "la d\u00e9cision du t\u00e9moin", "d\u00e9cision du jeu de contr\u00f4le",
  "ex\u00e9cution~12", "6021758543", "run de 200 r\u00e9plications", "0,99999899999999997124", "tests/reference/", "R/engine.R", "app.R")
for (x in negatifs)
  verifier(paste0("negatif : ", x), identical(motifs(x), character(0)))

# --- Liste B ------------------------------------------------------------------------------------
.b <- function(x) nd$nd_chercher(x, rep("Partie I", length(x)), nd$MOTIFS_B)$motif
verifier("B1 : auparavant", "B1" %in% .b("Auparavant non; mais auparavant oui"))
verifier("B2 et B12 : d\u00e9sormais, commit", all(c("B2", "B12") %in% .b("d\u00e9sormais, au commit")))
verifier("B11 : dur\u00e9e ... ~s", "B11" %in% .b("dur\u00e9e $2\\,256$~s"))
verifier("liste B : pas de faux positif sur un texte neutre", length(.b("Texte neutre sur la statistique.")) == 0L)
verifier("liste B ne produit rien de la liste A", identical(motifs("auparavant, commit"), character(0)))

# --- Recouvrement, comptage et parties ---------------------------------------------------------
.occ <- function(x, partie = "Partie I") nd$nd_chercher(x, rep(partie, length(x)), nd$MOTIFS_A)
verifier("\\code{actuary} compte une seule occurrence de A9 (recouvrement)",
         sum(.occ("\\code{actuary}")$motif == "A9") == 1L)
verifier("deux numeros d'issue sur une ligne : deux occurrences de A1",
         sum(.occ("issues~\\#12 et~\\#13")$motif == "A1") == 2L)
.tex_p <- c("\\newcommand{\\partie}[2]{x}", "avant", "\\partie{Partie I}{A}", "p1",
            "\\partie{Partie II}{B}", "p2", "\\partie{Partie III}{C}", "p3",
            "\\partie{Partie IV}{D}", "p4", "\\partie{Annexe}{E}", "p5")
verifier("parties : preambule puis chaque \\partie{...}",
         identical(nd$nd_parties(.tex_p),
                   c("Preambule", "Preambule", "Partie I", "Partie I", "Partie II", "Partie II",
                     "Partie III", "Partie III", "Partie IV", "Partie IV", "Annexe", "Annexe")))
r <- nd$nd_controle_motifs(c("\\partie{Partie III}{C}", "issue~\\#7", "\\partie{Partie IV}{D}",
                             "issue~\\#8 et ADR~0001"), exceptions = list())
.t <- nd$nd_table_motifs(r$a, nd$MOTIFS_A)
verifier("nd_controle_motifs : decompte par motif et par partie",
         .t[.t$motif == "A1", "occurrences"] == 2L && .t[.t$motif == "A1", "Partie III"] == 1L &&
         .t[.t$motif == "A1", "Partie IV"] == 1L && .t[.t$motif == "A3", "Partie IV"] == 1L &&
         .t[.t$motif == "A2", "occurrences"] == 0L)

# --- Exceptions : E3, perimee, levee, fenetre ----------------------------------------------
# L'exception transitoire E7 est retiree au lot L1 (#452) : le moteur ne cite plus
# aucun numero d'issue ; seule E3 reste dans la liste par defaut.
exc <- nd$exceptions_motifs_defaut()
verifier("liste par defaut : E3 seule (E7 retiree au lot L1)",
         identical(vapply(exc, `[[`, character(1), "id"), "E3") &&
         identical(vapply(nd$EXCEPTIONS_MOTIFS, `[[`, character(1), "id"), "E3") &&
         !exists("E7_TRANSITOIRE", envir = nd, inherits = FALSE) &&
         !exists("nd_zones_moteur", envir = nd, inherits = FALSE))
verifier("E3 : docs/suivi-documentation/ exempte en partie IV",
         identical(motifs("docs/suivi-documentation/IV.md", exceptions = exc, partie_unique = "Partie IV"),
                   character(0)))
for (p in c("Partie I", "Partie II", "Partie III", "Annexe", "Preambule"))
  verifier(paste0("E3 : docs/suivi-documentation/ refuse en ", p),
           "A4" %in% motifs("docs/suivi-documentation/IV.md", exceptions = exc, partie_unique = p))
verifier("E3 : un autre chemin de docs/ reste refuse en partie IV",
         "A4" %in% motifs("docs/specifications/x.md", exceptions = exc, partie_unique = "Partie IV"))
verifier("ancienne chaine de E7 : un numero d'issue dans une phrase du moteur est refuse",
         "A1" %in% motifs("Restituee en diagnostic par decision (issue \\#299) : aucun verdict", exceptions = exc))
.bilan <- function(x, exceptions) {
  parties <- nd$nd_parties(x)
  nd$nd_appliquer_exceptions(nd$nd_chercher(x, parties, nd$MOTIFS_A), x, exceptions)$bilan
}
b <- .bilan(c("rien a signaler", "texte neutre"), exc)
verifier("E3 (regle permanente) en attente quand rien n'est a exempter", identical(b$statut, "en attente"))
b <- .bilan(c("\\partie{Partie IV}{D}", "docs/suivi-documentation/IV.md"), exc)
verifier("exception appliquee : E3 compte une occurrence",
         identical(b$statut, "appliquee") && identical(b$n, 1L))
.ex <- function(actif = TRUE, fenetre = 1L)
  list(list(id = "EX", motifs = "A1", zone = "phrase[~\\s]+admise[~\\s]+\\(issue[~\\s]+\\\\#9\\)",
            fenetre = fenetre, parties = NULL, actif = actif, raison = "test"))
b <- .bilan("phrase admise (issue~\\#9)", .ex(actif = FALSE))
verifier("exception levee : statut 'levee', jamais perimee", identical(b$statut, "levee"))
verifier("exception levee : l'occurrence reste un motif",
         "A1" %in% motifs("phrase admise (issue~\\#9)", exceptions = .ex(actif = FALSE)))
verifier("exception a fenetre de deux lignes : zone coupee par un retour a la ligne, reconnue",
         identical(motifs(c("phrase admise", "(issue~\\#9)"), exceptions = .ex(fenetre = 2L)), character(0)) &&
         "A1" %in% motifs(c("phrase admise", "(issue~\\#9)"), exceptions = .ex(fenetre = 1L)))
verifier("exception : un numero d'issue hors de la zone, sur la meme ligne, reste refuse",
         identical(motifs("voir issue~\\#5 ; phrase admise (issue~\\#9)", exceptions = .ex()), "A1"))
b <- .bilan("issue~\\#9", list(list(id = "EX", motifs = "A1", zone = "ne correspond a rien",
                                    parties = NULL, actif = TRUE, raison = "test")))
verifier("exception sur mesure qui n'exempte rien : perimee", identical(b$statut, "PERIMEE"))
b <- .bilan("issue~\\#9 (cas admis)", list(list(id = "EX", motifs = "A1", zone = "issue~\\\\#9",
                                                parties = NULL, actif = TRUE, raison = "test")))
verifier("exception sur mesure qui exempte une occurrence : appliquee", identical(b$statut, "appliquee") && b$n == 1L)

# --- (b) Verdicts du plafond de pages ------------------------------------------------------------
v <- nd$nd_verdict_fiche
verifier("verdict : 3 pages et 12 000 caracteres = violation", identical(v(3L, 12000L), "violation"))
verifier("verdict : 3 pages et 9 000 caracteres = a verifier", identical(v(3L, 9000L), "a verifier"))
verifier("verdict : 2 pages et 20 000 caracteres = conforme", identical(v(2L, 20000L), "conforme"))
verifier("verdict : 1 page = conforme", identical(v(1L, 30000L), "conforme"))
verifier("verdict : bornes 10 500 (a verifier) et 10 501 (violation) a 3 pages",
         identical(v(3L, 10500L), "a verifier") && identical(v(3L, 10501L), "violation"))
verifier("verdict : 5 pages et source courte = a verifier", identical(v(5L, 4000L), "a verifier"))
verifier("verdict avec exception (plafond 3) : 3 pages conforme, 4 pages violation",
         identical(v(3L, 20000L, 3L), "conforme (exception)") && identical(v(4L, 20000L, 3L), "violation"))
verifier("verdict sans pages : caracteres seuls, jamais une violation",
         identical(v(NA_integer_, 20000L), "a verifier (sans pages)") &&
         identical(v(NA_integer_, 5000L), "conforme (sans pages)"))

# --- (b) .aux synthetique et etendue ---------------------------------------------------------------
fiche_tex <- function(lab, n) c(sprintf("\\begin{fiche}{Fiche %s}", lab), sprintf("\\label{fiche:%s}", lab),
                                strrep("x", n), "\\end{fiche}")
tex_b <- c("\\partie{Partie II}{Cadre}", fiche_tex("proc", 100),
           "\\partie{Partie III}{Fiches}", fiche_tex("a", 12000), fiche_tex("b", 9000),
           fiche_tex("c", 500), fiche_tex("d", 15000),
           "\\partie{Partie IV}{Validation}", fiche_tex("e", 20000))
dir_b <- tempfile("nd_"); dir.create(dir_b)
aux_complet <- c("\\relax", "\\newlabel{fiche:1}{{3.1}{8}{Proc}{subsection.3.1}{}}",
                 "\\newlabel{fiche:1-fin}{{3.1}{8}{}{subsection.3.1}{}}",
                 "\\newlabel{fiche:2}{{4.1}{10}{Titre {avec} accolades}{subsection.4.1}{}}",
                 "\\newlabel{fiche:2-fin}{{4.1}{12}{}{subsection.4.1}{}}",
                 "\\newlabel{fiche:3}{{4.2}{12}{B}{subsection.4.2}{}}",
                 "\\newlabel{fiche:3-fin}{{4.2}{14}{}{subsection.4.2}{}}",
                 "\\newlabel{fiche:4}{{4.3}{14}{C}{subsection.4.3}{}}",
                 "\\newlabel{fiche:4-fin}{{4.3}{14}{}{subsection.4.3}{}}",
                 "\\newlabel{fiche:5}{{4.4}{15}{D}{subsection.4.4}{}}",
                 "\\newlabel{fiche:5-fin}{{4.4}{15}{}{subsection.4.4}{}}",
                 "\\newlabel{fiche:6}{{5.1}{50}{E}{subsection.5.1}{}}",
                 "\\newlabel{fiche:6-fin}{{5.1}{60}{}{subsection.5.1}{}}",
                 "\\newlabel{sec:autre}{{2}{3}{x}{section.2}{}}")
f_aux <- file.path(dir_b, "complet.aux"); writeLines(aux_complet, f_aux)
aux <- nd$nd_lire_aux(f_aux)
verifier("nd_lire_aux : seuls les labels fiche: sont lus, avec leur page",
         identical(aux$label[aux$label == "fiche:2"], "fiche:2") && aux$page[aux$label == "fiche:2"] == 10L &&
         aux$page[aux$label == "fiche:2-fin"] == 12L && !any(grepl("sec:", aux$label)) && nrow(aux) == 12L)
verifier("nd_lire_aux : fichier absent = NULL", is.null(nd$nd_lire_aux(file.path(dir_b, "absent.aux"))))
res <- nd$nd_controle_pages(tex_b, aux, exceptions = list())
f <- res$fiches
verifier("pages : seules les fiches de la partie III sont examinees (a, b, c, d)",
         identical(f$label, paste0("fiche:", c("a", "b", "c", "d"))))
verifier("pages : etendue = fin - debut + 1", identical(f$etendue, c(3L, 3L, 1L, 1L)))
verifier("pages : caracteres de \\begin a \\end inclus",
         identical(f$caracteres, vapply(list(fiche_tex("a", 12000), fiche_tex("b", 9000), fiche_tex("c", 500),
                                             fiche_tex("d", 15000)),
                                        function(z) as.integer(sum(nchar(z) + 1L)), integer(1))))
verifier("pages : les trois verdicts (violation, a verifier, conforme)",
         identical(f$verdict, c("violation", "a verifier", "conforme", "conforme")))
verifier("pages : aucun avis quand le .aux est complet", length(res$avis) == 0L)

# Repli sans labels -fin, puis sans .aux.
f_sans_fin <- file.path(dir_b, "sans_fin.aux")
writeLines(grep("-fin", aux_complet, fixed = TRUE, invert = TRUE, value = TRUE), f_sans_fin)
res2 <- nd$nd_controle_pages(tex_b, nd$nd_lire_aux(f_sans_fin), exceptions = list())
verifier("repli sans labels -fin : avis, caracteres seuls, aucune violation",
         length(res2$avis) == 1L && grepl("-fin", res2$avis, fixed = TRUE) &&
         identical(res2$fiches$verdict, c("a verifier (sans pages)", "conforme (sans pages)",
                                          "conforme (sans pages)", "a verifier (sans pages)")) &&
         all(is.na(res2$fiches$etendue)))
res3 <- nd$nd_controle_pages(tex_b, NULL, exceptions = list())
verifier("repli sans .aux : avis, memes verdicts que sans labels -fin",
         length(res3$avis) == 1L && grepl(".aux", res3$avis, fixed = TRUE) &&
         identical(res3$fiches$verdict, res2$fiches$verdict))

# Exceptions au plafond.
res4 <- nd$nd_controle_pages(tex_b, aux, exceptions = list(
  list(label = "fiche:a", pages = 3L, raison = "test"),
  list(label = "fiche:c", pages = 3L, raison = "test"),
  list(label = "fiche:absente", pages = 3L, raison = "test"),
  list(label = "fiche:3", pages = 3L, raison = "test (numero automatique)")))
verifier("exception au plafond : appliquee (conforme (exception)) sur la fiche a, 3 pages accordees",
         identical(res4$fiches$verdict[1L], "conforme (exception)"))
verifier("exception au plafond designee par son numero automatique (fiche:3 = fiche b)",
         identical(res4$fiches$verdict[2L], "conforme (exception)"))
verifier("exception au plafond periee : fiche conforme sans elle, ou introuvable",
         identical(res4$exceptions$statut,
                   c("appliquee", "PERIMEE (conforme sans exception)",
                     "PERIMEE (fiche introuvable en partie III)", "appliquee")))
verifier("EXCEPTIONS_PLAFOND vide au depart", length(nd$EXCEPTIONS_PLAFOND) == 0L)
verifier("nd_fiches : fiches mal appariees refusees",
         leve_erreur(nd$nd_fiches(c("\\begin{fiche}{A}", "\\begin{fiche}{B}", "\\end{fiche}"))))

# --- Options et code de sortie (script lance en processus) ---------------------------------------
lancer <- function(...) {
  s <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"), shQuote(c(.script, ...)),
                                stdout = TRUE, stderr = TRUE, env = "LC_ALL=C.UTF-8"))
  st <- attr(s, "status")
  list(sortie = as.character(s), statut = if (is.null(st)) 0L else as.integer(st))
}
f_sale <- file.path(dir_b, "sale.tex"); f_sale_aux <- file.path(dir_b, "sale.aux")
writeLines(c(tex_b[1:3], "voir issue~\\#12", tex_b[4:length(tex_b)]), f_sale)
# Le .aux de sale.tex : meme fiches (une ligne de texte de plus ne change pas les ids).
writeLines(aux_complet, f_sale_aux)
f_propre <- file.path(dir_b, "propre.tex"); f_propre_aux <- file.path(dir_b, "propre.aux")
writeLines(c("\\partie{Partie III}{F}", fiche_tex("a", 500)), f_propre)
writeLines(c("\\newlabel{fiche:1}{{4.1}{10}{A}{x}{}}", "\\newlabel{fiche:1-fin}{{4.1}{10}{}{x}{}}"), f_propre_aux)

r <- lancer(paste0("--tex=", f_sale), paste0("--aux=", f_sale_aux))
verifier("sans --bloquant : code 0 malgre violations de A et du plafond",
         r$statut == 0L && any(grepl("BILAN : 1 occurrence", r$sortie)) && any(grepl("1 violation", r$sortie)))
r <- lancer(paste0("--tex=", f_sale), paste0("--aux=", f_sale_aux), "--bloquant")
verifier("--bloquant : code 1 en cas de violation", r$statut == 1L)
r <- lancer(paste0("--tex=", f_sale), paste0("--aux=", f_sale_aux), "--bloquant", "--pages-seules")
verifier("--bloquant --pages-seules : code 1 sur la seule violation du plafond",
         r$statut == 1L && !any(grepl("Liste A", r$sortie)))
r <- lancer(paste0("--tex=", f_sale), paste0("--aux=", f_sale_aux), "--bloquant", "--motifs-seuls")
verifier("--bloquant --motifs-seuls : code 1 sur la seule liste A, sans controle (b)",
         r$statut == 1L && !any(grepl("Plafond de pages", r$sortie)))
r <- lancer(paste0("--tex=", f_propre), paste0("--aux=", f_propre_aux), "--bloquant")
verifier("--bloquant sur un .tex propre : code 0", r$statut == 0L && any(grepl("BILAN : 0 occurrence", r$sortie)))
r <- lancer(paste0("--tex=", f_sale), "--motifs-seuls", "--max-lignes=0")
verifier("--max-lignes=0 : aucune ligne en cause imprimee", !any(grepl("^  l[.][0-9]+ ", r$sortie)))
r <- lancer(paste0("--tex=", f_sale), "--motifs-seuls", "--max-lignes=1")
verifier("--max-lignes=1 : une ligne en cause pour A1", sum(grepl("^  l[.]4 ", r$sortie)) >= 1L)
r <- lancer("--inconnue")
verifier("argument inconnu : code 2", r$statut == 2L)
r <- lancer("--motifs-seuls", "--pages-seules")
verifier("--motifs-seuls et --pages-seules s'excluent : code 2", r$statut == 2L)
r <- lancer(paste0("--tex=", file.path(dir_b, "absent.tex")))
verifier("fichier .tex introuvable : code 2", r$statut == 2L)
r <- lancer(paste0("--tex=", f_sale), paste0("--aux=", file.path(dir_b, "absent.aux")), "--pages-seules")
verifier("sans .aux : le controle (b) le signale et retombe sur les caracteres, code 0",
         r$statut == 0L && any(grepl("AVERTISSEMENT : aucun fichier .aux", r$sortie, fixed = TRUE)))

# --- (c) Debordements : journal LaTeX ---------------------------------------------------------------
log_c <- c("This is pdfTeX", "Overfull \\hbox (0.68134pt too wide) in paragraph at lines 14605--14605",
           " []\\T1/ntxtt/m/n/10 xxxx", "Overfull \\hbox (23.45457pt too wide) in paragraph at lines 23028--23040",
           "Underfull \\hbox (badness 10000) in paragraph at lines 5--6",
           "Overfull \\vbox (1.2pt too high) has occurred while \\output is active []",
           "Overfull \\vbox (1.5pt too high) has occurred while \\output is active []",
           "Overfull \\vbox (1.51pt too high) has occurred while \\output is active []",
           "Overfull \\vbox (22.09131pt too high) has occurred while \\output is active []",
           "Overfull \\hbox (3.0pt too wide) in alignment at lines 7--9")
f_log <- file.path(dir_b, "complet.log"); writeLines(log_c, f_log)
j <- nd$nd_lire_journal(f_log)
verifier("journal : 8 debordements lus, Underfull ignore", nrow(j) == 7L && sum(j$type == "hbox") == 3L && sum(j$type == "vbox") == 4L)
verifier("journal : tailles et lignes sources", identical(round(j$taille[1:2], 2), c(0.68, 23.45)) &&
         identical(j$ligne_tex[1:2], c(14605L, 23028L)) && is.na(j$ligne_tex[4L]) && j$ligne_tex[7L] == 7L)
verifier("journal : tout Overfull \\hbox est une violation, meme de 0,68 pt",
         identical(j$verdict[j$type == "hbox"], rep("violation", 3L)))
verifier("journal : Overfull \\vbox = avertissement jusqu'a 1,5 pt (borne incluse), violation au-dela",
         identical(j$verdict[j$type == "vbox"], c("avertissement", "avertissement", "violation", "violation")))
verifier("verdict de debordement : fonction", identical(nd$nd_verdict_debordement("vbox", 1.5), "avertissement") &&
         identical(nd$nd_verdict_debordement("hbox", 0.01), "violation") && identical(nd$nd_verdict_debordement("vbox", NA_real_), "violation"))
verifier("journal absent = NULL, avis", is.null(nd$nd_lire_journal(file.path(dir_b, "absent.log"))) &&
         length(nd$nd_controle_debordements(NULL)$avis) == 1L)
f_log0 <- file.path(dir_b, "vide.log"); writeLines("This is pdfTeX", f_log0)
verifier("journal sans debordement : table vide", nrow(nd$nd_lire_journal(f_log0)) == 0L)
f_log_v <- file.path(dir_b, "vbox_tolere.log")
writeLines("Overfull \\vbox (1.0pt too high) has occurred while \\output is active []", f_log_v)
r <- lancer(paste0("--tex=", f_propre), "--debordements", paste0("--log=", f_log))
verifier("--debordements : code 0 sans --bloquant malgre les violations", r$statut == 0L && any(grepl("TOTAL [(]c[)]", r$sortie)) &&
         any(grepl("5 violation", r$sortie)) && !any(grepl("Liste A", r$sortie)))
r <- lancer(paste0("--tex=", f_propre), "--debordements", paste0("--log=", f_log), "--bloquant")
verifier("--debordements --bloquant : code 1 (Overfull \\hbox)", r$statut == 1L)
r <- lancer(paste0("--tex=", f_propre), "--debordements", paste0("--log=", f_log_v), "--bloquant")
verifier("--debordements --bloquant : un \\vbox de 1,0 pt seul reste un avertissement, code 0", r$statut == 0L)
r <- lancer(paste0("--tex=", f_propre), paste0("--aux=", f_propre_aux), paste0("--log=", f_log), "--bloquant")
verifier("sans selecteur : les debordements font partie des controles par defaut, code 1 avec --bloquant",
         r$statut == 1L && any(grepl("[(]c[)] Debordements", r$sortie)))
r <- lancer(paste0("--tex=", f_propre), "--debordements", paste0("--log=", file.path(dir_b, "absent.log")), "--bloquant")
verifier("--debordements sans journal : avis, code 0", r$statut == 0L && any(grepl("AVERTISSEMENT : aucun journal", r$sortie)))
r <- lancer("--debordements", "--remplissage")
verifier("deux selecteurs s'excluent : code 2", r$statut == 2L)

# --- (d) Remplissage : marques et analyse (geometrie construite a la main) -----------------------------
g_ <- list(feuille = 842, haut = 71, hauteur_utile = 700, interligne = 14.7)   # bas = 771
mot_ <- function(page, y0, txt = "texte", x0 = 71, h = 10) data.frame(page = page, x0 = x0, y0 = y0, x1 = x0 + 30, y1 = y0 + h,
                                                                   mot = txt, stringsAsFactors = FALSE)
lignes_ <- function(page, y_debut, n, pas = 14.7) do.call(rbind, lapply(seq_len(n), function(i) mot_(page, y_debut + (i - 1L) * pas)))
mots_ <- function(...) { m <- do.call(rbind, list(...)); attr(m, "paysage") <- integer(0); m }
marq_ <- function(nb_pages, voulues = integer(0), titres = NULL, debut = NULL, fin = NULL, inmes = integer(0)) {
  list(pages = data.frame(page = seq_len(nb_pages), volontaire = seq_len(nb_pages) %in% voulues),
       encadres = list(debut = if (is.null(debut)) data.frame(id = integer(0), page = integer(0), y = numeric(0)) else debut,
                       fin = if (is.null(fin)) data.frame(id = integer(0), page = integer(0), y = numeric(0)) else fin,
                       inmesurables = inmes),
       titres = if (is.null(titres)) data.frame(niveau = character(0), page = integer(0), y = numeric(0), texte = character(0),
                                                stringsAsFactors = FALSE) else titres,
       geometrie = g_)
}
cons <- function(r, type) r$constats[r$constats$type == type, , drop = FALSE]

# Blancs : page 2 finit a 300 (blanc de 67 %), page 3 aussi mais saut voulu, page 4 finit a 700 (10 %), page 5 a 570 (28 %).
m_blanc <- mots_(lignes_(1, 71, 48), lignes_(2, 71, 16), lignes_(3, 71, 16), lignes_(4, 71, 43), lignes_(5, 71, 34), lignes_(6, 71, 10))
r <- nd$nd_analyser_remplissage(marq_(6, voulues = 3L), m_blanc)
verifier("blanc : page 2 signalee (> 30 %), page 3 exemptee (saut voulu), pages 4 et 5 sous le seuil",
         identical(cons(r, "blanc")$page, c(2L, 6L)) && grepl("^6[0-9] %", cons(r, "blanc")$detail[1L]))
verifier("blanc : une page sans aucun mot compte 100 %", identical(cons(nd$nd_analyser_remplissage(marq_(2), mots_(lignes_(1, 71, 40))), "blanc")$page, 2L))

# Encadres : n.1 coupe a 2 lignes en bas (court), n.2 long coupe en deux gros morceaux, n.3 sur une page, n.4 inmesurable.
yb <- function(td) 842 - td   # ordonnee depuis le bas de la feuille
deb <- data.frame(id = 1:4, page = c(1L, 3L, 5L, 5L), y = c(yb(745), yb(500), yb(300), yb(300)))
fin <- data.frame(id = 1:4, page = c(2L, 4L, 5L, 6L), y = c(yb(100), yb(600), yb(400), yb(100)))
m_enc <- mots_(lignes_(1, 735, 3), lignes_(1, 71, 45), lignes_(2, 71, 8),
               lignes_(3, 490, 20), lignes_(4, 71, 36), lignes_(5, 71, 40), lignes_(6, 71, 8))
r <- nd$nd_analyser_remplissage(marq_(6, debut = deb, fin = fin, inmes = 4L), m_enc)
e <- cons(r, "encadre")
verifier("encadre court coupe en deux morceaux de 2 et 8 lignes signale; encadre long, encadre d'une page et encadre inmesurable non signales",
         nrow(e) == 1L && e$page == 1L && grepl("encadre n. 1", e$detail) && grepl("court", e$detail))
deb3 <- data.frame(id = 1L, page = 3L, y = yb(700)); fin3 <- data.frame(id = 1L, page = 5L, y = yb(300))
r <- nd$nd_analyser_remplissage(marq_(6, debut = deb3, fin = fin3), mots_(lignes_(3, 695, 5), lignes_(4, 71, 48), lignes_(5, 71, 20),
                                                                           lignes_(1, 71, 48), lignes_(2, 71, 48), lignes_(6, 71, 48)))
verifier("encadre long coupe, premier morceau de 5 lignes : conforme", nrow(cons(r, "encadre")) == 0L)
deb4 <- data.frame(id = 1L, page = 3L, y = yb(745)); fin4 <- data.frame(id = 1L, page = 5L, y = yb(300))
r <- nd$nd_analyser_remplissage(marq_(6, debut = deb4, fin = fin4), mots_(lignes_(3, 735, 2), lignes_(4, 71, 48), lignes_(5, 71, 20),
                                                                           lignes_(1, 71, 48), lignes_(2, 71, 48), lignes_(6, 71, 48)))
verifier("encadre long (3 pages) dont le premier morceau n'a que 2 lignes : signale pour le morceau, non comme court",
         nrow(cons(r, "encadre")) == 1L && grepl("moins de 3 lignes", cons(r, "encadre")$detail))

# Titres : sous-section en bas de page (2 lignes dessous) / confortable (5 lignes) / sur la derniere page / en paysage.
ti <- data.frame(niveau = rep("subsection", 4L), page = c(1L, 2L, 5L, 4L),
                 y = c(yb(735), yb(300), yb(750), yb(740)), texte = c("Titre orphelin", "Titre confortable", "Titre de la fin", "Titre paysage"),
                 stringsAsFactors = FALSE)
m_t <- mots_(lignes_(1, 71, 45), lignes_(2, 71, 40), lignes_(3, 71, 10), lignes_(4, 71, 5), lignes_(5, 71, 5))
m_t <- rbind(m_t, mot_(1, 740, "a"), mot_(1, 755, "b"))
attr(m_t, "paysage") <- 4L
r <- nd$nd_analyser_remplissage(marq_(5, titres = ti), m_t)
verifier("titre : orphelin signale, confortable et titre de la derniere page non signales, page en paysage non mesuree",
         identical(cons(r, "titre")$page, 1L) && grepl("Titre orphelin", cons(r, "titre")$detail) && r$resume$paysage == 1L)

# Bandeau de section seul en bas de page : sa marque est posee en tete de la page suivante.
hb_ <- 16.88
bandeau_ <- function(page, y0) mot_(page, y0, "Bandeau", h = hb_)
ti <- data.frame(niveau = "section", page = c(2L, 4L), y = c(yb(175), yb(86)), texte = c("Section normale", "Section au bandeau isole"),
                 stringsAsFactors = FALSE)
m_b <- mots_(lignes_(1, 71, 48), bandeau_(2, 122), lignes_(2, 180, 20), lignes_(3, 71, 40), bandeau_(3, 735), lignes_(4, 100, 20), lignes_(5, 71, 5))
r <- nd$nd_analyser_remplissage(marq_(5, titres = ti), m_b)
verifier("bandeau de section : seul en bas de la page 3 (marque en tete de la page 4) = signale; bandeau suivi de texte = non signale",
         identical(cons(r, "titre")$page, 3L) && grepl("0 ligne", cons(r, "titre")$detail))

# Rubriques lues dans le texte du PDF, titre de fiche separe de la rubrique 1.
rub_ <- function(page, y0, n) rbind(mot_(page, y0, paste0(n, "."), x0 = 71), mot_(page, y0, nd$RUBRIQUES_FICHE[[as.character(n)]], x0 = 90))
m_r <- mots_(lignes_(1, 71, 40), rub_(1, 650, 3), lignes_(1, 665, 6),            # rubrique 3 suivie de 7 lignes : conforme
             rub_(1, 757, 5),                                                   # rubrique 5 : une seule ligne en bas de page
             lignes_(2, 71, 40), rub_(3, 71, 1), lignes_(3, 90, 30), lignes_(4, 71, 10))
ti <- data.frame(niveau = "subsection", page = 2L, y = yb(600), texte = "Test de la fiche", stringsAsFactors = FALSE)
r <- nd$nd_analyser_remplissage(marq_(4, titres = ti), m_r)
verifier("rubrique commencee par une seule ligne en bas de page signalee, rubrique suivie de lignes non signalee",
         identical(cons(r, "rubrique")$page, 1L) && grepl("rubrique 5", cons(r, "rubrique")$detail) && r$resume$rubriques == 3L)
verifier("titre de fiche en page 2, rubrique 1 en page 3 : signale a la page du titre",
         identical(cons(r, "titre")$page, 2L) && grepl("separe de la rubrique 1 [(]page 3[)]", cons(r, "titre")$detail))
r <- nd$nd_analyser_remplissage(marq_(2), mots_(lignes_(1, 71, 3), lignes_(2, 71, 3)))
verifier("document sans constat : table vide, aucune erreur", is.data.frame(r$constats) && nrow(cons(r, "rubrique")) == 0L)
verifier("pages du PDF en surplus des marques : avis, rien n'est mesure",
         is.null(nd$nd_analyser_remplissage(marq_(1), mots_(lignes_(2, 71, 3)))$constats))

# Lecture d'un fichier .remp (ordonnees en sp depuis le bas de la feuille).
f_remp <- file.path(dir_b, "t.remp")
writeLines(c("P 1 1 0 10000", "P 2 2 1 -10000", "B 1 1 3276800", "F 1 2 6553600", "X 2",
             "T section 2 6553600 \\ifttl@toclabel Titre", "T paragraph 2 1 x",
             "G 845.04684pt 71.13188pt 702.78308pt 14.68802pt"), f_remp)
mq <- nd$nd_lire_marques(f_remp)
verifier("marques : pages, volontaire, encadres (sp -> bp), inmesurables, titres, geometrie",
         identical(mq$pages$volontaire, c(FALSE, TRUE)) && abs(mq$encadres$debut$y - 50 * 72 / 72.27) < 1e-9 &&
         identical(mq$encadres$fin$page, 2L) && identical(mq$encadres$inmesurables, 2L) && nrow(mq$titres) == 1L &&
         abs(mq$geometrie$hauteur_utile - 702.78308 * 72 / 72.27) < 1e-6)

# --- (d) Remplissage : passe de mesure reelle sur un petit document (pdflatex, mdframed) ---------------
tex_dispo <- nzchar(Sys.which("pdflatex")) && nzchar(Sys.which("pdftotext")) && nzchar(Sys.which("pdfinfo")) &&
             nzchar(Sys.which("kpsewhich")) && nzchar(system2("kpsewhich", "mdframed.sty", stdout = TRUE, stderr = FALSE)[1L])
if (tex_dispo) {
  dir_t <- file.path(dir_b, "tex"); dir.create(dir_t)
  doc <- c("\\documentclass[a4paper,11pt]{article}", "\\usepackage[utf8]{inputenc}", "\\usepackage{mdframed}",
           "\\usepackage[margin=2.5cm]{geometry}", "\\usepackage{titlesec}",
           "\\newmdenv[linecolor=blue,linewidth=0pt,leftline=true]{encadre}",
           "\\begin{document}", "\\section{Un}", "Debut.\\par", "\\vspace*{\\dimexpr\\textheight-6\\baselineskip}",
           "\\begin{encadre}", "Premiere ligne de l'encadre coupe", paste0("\\par Ligne ", 1:12, " de l'encadre."), "\\end{encadre}",
           "Fin du document.", "\\end{document}")
  f_doc <- file.path(dir_t, "mini.tex"); writeLines(doc, f_doc)
  for (i in 1:2) system2("pdflatex", c("-interaction=nonstopmode", "-halt-on-error", paste0("-output-directory=", shQuote(dir_t)), shQuote(f_doc)),
                         stdout = FALSE, stderr = FALSE)
  marq_tex <- file.path(.dossier, "..", "marques_remplissage.tex")
  rr <- nd$nd_controle_remplissage(f_doc, file.path(dir_t, "mini.pdf"), marq_tex)
  verifier("passe de mesure reelle : texte identique (garde-fou), un encadre mesure", length(rr$avis) == 0L && !is.null(rr$constats) &&
           rr$resume$encadres == 1L)
  e <- rr$constats[rr$constats$type == "encadre", , drop = FALSE]
  verifier("passe de mesure reelle : encadre coupe entre les pages 1 et 2 detecte, morceau court", nrow(e) == 1L &&
           grepl("entre les pages 1 et 2", e$detail))
  writeLines(sub("Fin du document.", "Fin du document, modifie.", doc, fixed = TRUE), f_doc)
  rr <- nd$nd_controle_remplissage(f_doc, file.path(dir_t, "mini.pdf"), marq_tex)
  verifier("garde-fou : PDF qui n'a pas le texte de la passe de mesure = avis, rien n'est mesure",
           is.null(rr$constats) && grepl("meme texte", rr$avis))
  verifier("la passe de mesure ne laisse rien dans le dossier du document (hors fichiers de la compilation normale)",
           setequal(list.files(dir_t), c("mini.tex", "mini.pdf", "mini.aux", "mini.log")))
  rr <- nd$nd_controle_remplissage(f_doc, file.path(dir_t, "absent.pdf"), marq_tex)
  verifier("PDF normal absent : avis", is.null(rr$constats) && length(rr$avis) == 1L)
} else cat("  (pdflatex, pdftotext ou mdframed absents : passe de mesure reelle non testee)\n")


# --- Outils PDF absents (pdftotext, pdfinfo) : avis et pas d'erreur (C3) ---------------------------
chemin_avant <- Sys.getenv("PATH")
Sys.setenv(PATH = file.path(dir_b, "vide_de_binaires"))
f_pdf_bidon <- file.path(dir_b, "bidon.pdf"); writeLines("%PDF-1.4", f_pdf_bidon)
f_remp_bidon <- file.path(dir_b, "bidon.remp"); writeLines("G 1pt 1pt 1pt 1pt", f_remp_bidon)
rr <- tryCatch(nd$nd_controle_remplissage(f_sale, f_pdf_bidon, file.path(.dossier, "..", "marques_remplissage.tex"),
                                          remp = f_remp_bidon, pdf_mesure = f_pdf_bidon), error = function(e) e)
mots_abs <- tryCatch(nd$nd_lire_mots(f_pdf_bidon), error = function(e) e)
manq <- nd$nd_outils_pdf_manquants()
Sys.setenv(PATH = chemin_avant)
verifier("pdftotext et pdfinfo absents : avis, aucune erreur, rien n'est mesure",
         !inherits(rr, "error") && is.null(rr$constats) && length(rr$avis) == 1L && grepl("pdftotext et pdfinfo absent", rr$avis) &&
         setequal(manq, c("pdftotext", "pdfinfo")))
verifier("nd_lire_mots sans pdftotext : NULL, aucune erreur", is.null(mots_abs))

# --- Pages en chiffres romains dans le .aux : avis ------------------------------------------------------
f_aux_rom <- file.path(dir_b, "romain.aux")
writeLines(c("\\newlabel{fiche:2}{{4.1}{xiv}{T}{x}{}}", "\\newlabel{fiche:2-fin}{{4.1}{xv}{}{x}{}}",
             "\\newlabel{fiche:3}{{4.2}{16}{T}{x}{}}", "\\newlabel{fiche:3-fin}{{4.2}{16}{}{x}{}}"), f_aux_rom)
ar <- nd$nd_lire_aux(f_aux_rom)
verifier("aux : page romaine lue NA", is.na(ar$page[ar$label == "fiche:2"]) && ar$page[ar$label == "fiche:3"] == 16L)
res_r <- nd$nd_controle_pages(tex_b, ar, exceptions = list())
verifier("aux : avis sur les pages non numeriques, fiches concernees sans etendue (caracteres seuls)",
         any(grepl("non numerique", res_r$avis)) && is.na(res_r$fiches$etendue[1L]) && res_r$fiches$etendue[2L] == 1L &&
         res_r$fiches$verdict[1L] == "a verifier (sans pages)")

unlink(dir_b, recursive = TRUE)
fin_fichier()
