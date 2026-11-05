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
#        meme id ; parties du document ; exceptions E3 (partie IV seulement)
#        et E7 (chaine du moteur, drapeau transitoire) ; exception perimee ;
#    (b) plafond de pages : lecture d'un .aux synthetique, etendue, trois
#        verdicts (violation, a verifier, conforme), bornes, exception au
#        plafond (appliquee, perimee), repli sans labels -fin et sans .aux ;
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
  "mod\u00e8le d'effacee", "0,99999899999999997124", "tests/reference/", "R/engine.R", "app.R")
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

# --- Exceptions : E3, E7, perimee ---------------------------------------------------------
exc <- nd$exceptions_motifs_defaut(e7_actif = TRUE, e7_issues = 299L)
verifier("E3 : docs/suivi-documentation/ exempte en partie IV",
         identical(motifs("docs/suivi-documentation/IV.md", exceptions = exc, partie_unique = "Partie IV"),
                   character(0)))
for (p in c("Partie I", "Partie II", "Partie III", "Annexe", "Preambule"))
  verifier(paste0("E3 : docs/suivi-documentation/ refuse en ", p),
           "A4" %in% motifs("docs/suivi-documentation/IV.md", exceptions = exc, partie_unique = p))
verifier("E3 : un autre chemin de docs/ reste refuse en partie IV",
         "A4" %in% motifs("docs/specifications/x.md", exceptions = exc, partie_unique = "Partie IV"))
.chaine <- "Restituee en diagnostic par decision (issue \\#299) : aucun verdict"
verifier("E7 : la chaine du moteur (issue \\#299) est admise",
         identical(motifs(.chaine, exceptions = exc), character(0)))
verifier("E7 : une autre issue (\\#302) n'est pas admise (la grille valide #299 seul)",
         "A1" %in% motifs(sub("299", "302", .chaine, fixed = TRUE), exceptions = exc))
verifier("E7 : un numero d'issue hors de la chaine, sur la meme ligne, reste refuse",
         identical(motifs(paste("voir issue~\\#5 ;", .chaine), exceptions = exc), "A1"))
exc_levee <- nd$exceptions_motifs_defaut(e7_actif = FALSE)
verifier("E7 levee (drapeau FALSE) : la chaine redevient un motif",
         "A1" %in% motifs(.chaine, exceptions = exc_levee))
verifier("drapeau E7_TRANSITOIRE du script : TRUE au depart (a lever au lot L1)",
         isTRUE(nd$E7_TRANSITOIRE) && isTRUE(nd$exceptions_motifs_defaut()[[2L]]$actif))
.bilan <- function(x, exceptions) {
  parties <- nd$nd_parties(x)
  nd$nd_appliquer_exceptions(nd$nd_chercher(x, parties, nd$MOTIFS_A), x, exceptions)$bilan
}
b <- .bilan(c("rien a signaler", "texte neutre"), exc)
verifier("exception perimee : E3 et E7 n'exemptent rien sur un texte propre",
         identical(b$statut, c("PERIMEE", "PERIMEE")))
b <- .bilan(c("\\partie{Partie IV}{D}", "docs/suivi-documentation/IV.md", .chaine), exc)
verifier("exception appliquee : E3 et E7 comptent chacune une occurrence",
         identical(b$statut, c("appliquee", "appliquee")) && identical(b$n, c(1L, 1L)))
b <- .bilan(.chaine, exc_levee)
verifier("exception levee : statut 'levee', jamais perimee", identical(b$statut, c("PERIMEE", "levee")))
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

unlink(dir_b, recursive = TRUE)
fin_fichier()
