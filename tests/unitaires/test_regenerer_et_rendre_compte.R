###############################################################################
#  tests/unitaires/test_regenerer_et_rendre_compte.R  --  REGENERATION
#  CONTROLEE D'UNE REFERENCE (issue #64)
#
#  Teste analyser_regeneration(), verifier_regeneration() et
#  tableau_markdown() de tests/regenerer_et_rendre_compte.R sur des objets
#  construits a la main, sans reference ni fichier : refus hors motifs (derive
#  infime comprise), acceptation, ajouts et suppressions de feuilles, noeuds
#  de structure, motifs sans effet, tableau markdown bien forme, et
#  verification qu'aucune feuille hors motifs n'a bouge.
#  Teste aussi extraire_option() et designer() de outils_tests.R, partagees
#  avec patcher_reference.R.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_regenerer_et_rendre_compte.R")

# Meme chargement que test_patcher_reference.R : environnement dedie.
.dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
rg <- new.env(parent = globalenv())
rg$DOSSIER_TESTS <- file.path(.dossier, "..")
sys.source(file.path(rg$DOSSIER_TESTS, "regenerer_et_rendre_compte.R"), envir = rg)

analyser <- function(avant, apres, motifs = character(0)) rg$analyser_regeneration(avant, apres, motifs)
leve <- function(expr) inherits(tryCatch(expr, error = function(e) e), "error")

base <- list(sigma = 0.123456789, tests = list(list(test = "A", p = 0.5, detail = "x"),
                                               list(test = "B", p = 0.25, detail = "y")))

## --- Options de ligne de commande et motifs (outils_tests.R) ---------------
verifier("extraire_option : valeurs repetees et reste dans l'ordre",
         identical(rg$extraire_option(c("premium", "--attendu", "a", "--issue", "9", "--attendu", "b"), "--attendu"),
                   list(valeurs = c("a", "b"), reste = c("premium", "--issue", "9"))))
verifier("extraire_option : option sans valeur -> erreur",
         leve(rg$extraire_option(c("premium", "--attendu"), "--attendu")))
verifier("designer : aucun motif -> aucun chemin",
         identical(rg$designer(c("a", "b"), character(0)), character(0)))

## --- Rien a regenerer --------------------------------------------------------
verifier("Objets identiques : rien a regenerer, ecriture non acceptable",
         { a <- analyser(base, base, "detail"); a$rien_a_regenerer && !a$acceptable && !nrow(a$lignes) })

## --- Acceptation ---------------------------------------------------------------
apres1 <- base; apres1$tests[[2]]$detail <- "y modifie"
verifier("Changement designe par le motif : acceptable",
         { a <- analyser(base, apres1, "tests\\[\\[2\\]\\]\\$detail")
           a$acceptable && identical(a$designees, "tests[[2]]$detail") && !length(a$hors_motifs) })
verifier("Acceptation : nombre de feuilles identiques = feuilles de la reference - 1",
         { a <- analyser(base, apres1, "detail"); a$n_identiques == a$n_feuilles_avant - 1L })

## --- Refus hors motifs -----------------------------------------------------
verifier("Feuille en ecart au seuil hors motifs : refus, feuille listee",
         { b <- apres1; b$sigma <- 0.2
           a <- analyser(base, b, "detail")
           !a$acceptable && identical(a$hors_motifs, "sigma") && any(grepl("sigma", rg$motifs_de_refus(a))) })
verifier("Derive infime (1e-12, sous le seuil) hors motifs : refus (non strictement identique)",
         { b <- apres1; b$sigma <- b$sigma * (1 + 1e-12)
           a <- analyser(base, b, "detail")
           !a$acceptable && identical(a$hors_motifs, "sigma") && !a$lignes$au_seuil[a$lignes$chemin == "sigma"] })
verifier("Motif attendu ne designant aucun changement : refus",
         { a <- analyser(base, apres1, c("detail", "sigma"))
           !a$acceptable && identical(a$motifs_sans_effet, "sigma") })
verifier("Motif trop etroit (chemin nu d'un vecteur indexe) : refus",
         { b <- base; b$v <- c(1, 2); c2 <- b; c2$v <- c(1, 3)
           a <- analyser(b, c2, "^v$"); !a$acceptable && identical(a$hors_motifs, "v[2]") })

## --- Ajouts et suppressions ------------------------------------------------
ajout <- base; ajout$tests[[3]] <- list(test = "C", p = 0.1, detail = "z")
verifier("Ajout d'une entree : feuilles 'ajoutee', acceptable si designees, racine couverte",
         { a <- analyser(base, ajout, "tests\\[\\[3\\]\\]")
           a$acceptable && all(a$lignes$mesure == "ajoutee") && nrow(a$lignes) == 3L &&
             !length(a$structure_hors_motifs) })
verifier("Ajout non designe : refus",
         !analyser(base, ajout, character(0))$acceptable)
verifier("Suppression d'une entree : feuilles 'absente', acceptable si designees",
         { a <- analyser(ajout, base, "tests\\[\\[3\\]\\]")
           a$acceptable && all(a$lignes$mesure == "absente") && a$n_identiques == a$n_feuilles_avant - 3L })
verifier("Vecteur qui franchit la longueur 1 : chemin nu et chemins indexes, tous a designer",
         { b <- base; b$w <- "a"; c2 <- base; c2$w <- c("a", "b")
           ok1 <- analyser(b, c2, "^w")$acceptable
           a2 <- analyser(b, c2, "^w$")
           ok1 && !a2$acceptable && setequal(a2$hors_motifs, c("w[1]", "w[2]")) })

## --- Structure (type, attributs) -------------------------------------------
verifier("Changement de classe sans feuille modifiee : refus hors motifs, accepte si le noeud est designe",
         { b <- list(d = data.frame(x = 1:2)); c2 <- list(d = list(x = 1:2))
           a1 <- analyser(b, c2); a2 <- analyser(b, c2, "^d$")
           !nrow(a1$lignes) && !a1$acceptable && identical(a1$structure_hors_motifs, "d") && a2$acceptable })

## --- Verification apres ecriture ---------------------------------------------
verifier("verifier_regeneration : reference relue = recalcule -> feuilles hors motifs comptees",
         { a <- analyser(base, apres1, "detail")
           n <- rg$verifier_regeneration(base, apres1, apres1, a$designees)
           n == a$n_feuilles_avant - 1L })
verifier("verifier_regeneration : feuille hors motifs modifiee dans l'ancienne reference -> erreur",
         { a <- analyser(base, apres1, "detail")
           # le recalcule et la reference ecrite portent un sigma different de
           # l'ancienne reference, alors que sigma n'est pas designe
           b <- apres1; b$sigma <- 1
           leve(rg$verifier_regeneration(base, b, b, a$designees)) })
verifier("verifier_regeneration : reference ecrite differente du recalcule -> erreur",
         { b <- apres1; b$tests[[1]]$p <- 0.51
           leve(rg$verifier_regeneration(base, b, apres1, "tests[[2]]$detail")) })
verifier("verifier_regeneration : suppression designee acceptee",
         { a <- analyser(ajout, base, "tests\\[\\[3\\]\\]")
           rg$verifier_regeneration(ajout, base, base, a$designees) == a$n_feuilles_avant - 3L })

## --- Tableau markdown ------------------------------------------------------
long <- paste(rep("abcdefghij", 20), collapse = "")
avec_long <- apres1; avec_long$tests[[2]]$detail <- paste0(long, " | avec barre")
md <- rg$tableau_markdown(analyser(ajout, avec_long, c("tests\\[\\[3\\]\\]", "detail")), "cas", 64,
                          c("tests\\[\\[3\\]\\]", "detail"), date = as.Date("2026-09-23"),
                          plateforme_txt = "R version 4.3.1, Windows")
lignes_tab <- grep("^\\|", md, value = TRUE)
# Barres verticales non echappees = separateurs de colonnes.
n_sep <- vapply(lignes_tab, function(l) lengths(regmatches(l, gregexpr("(?<!\\\\)\\|", l, perl = TRUE))),
                integer(1))
verifier("Tableau : en-tete Feuille | Avant | Apres | Ecart | Mesure, puis separateur",
         identical(lignes_tab[1], "| Feuille | Avant | Apr\u00e8s | \u00c9cart | Mesure |") &&
           identical(lignes_tab[2], "|---|---|---|---|---|"))
verifier("Tableau : chaque ligne a exactement 5 colonnes (6 separateurs non echappes)",
         all(n_sep == 6L))
verifier("Tableau : une ligne par feuille differente (3 supprimees + 1 modifiee)",
         length(lignes_tab) == 2L + 4L)
verifier("Tableau : feuilles absentes d'un cote marquees '(absente)'",
         sum(grepl("(absente)", lignes_tab, fixed = TRUE)) == 3L)
verifier("Tableau : chaine longue tronquee avec sa longueur",
         any(grepl(sprintf("\u2026 (%d car.)", nchar(avec_long$tests[[2]]$detail)), lignes_tab, fixed = TRUE)) &&
           !any(grepl(long, lignes_tab, fixed = TRUE)))
verifier("Tableau : ligne de synthese, plateforme, date et issue presentes",
         any(grepl("^\\*\\*Synth\u00e8se\\*\\* : 10 feuille\\(s\\)", md)) &&
           any(md == "- Plateforme : R version 4.3.1, Windows") &&
           any(md == "- Date : 2026-09-23") && grepl("(issue #64)", md[1], fixed = TRUE))
verifier("Tableau : nombre de feuilles identiques dans la synthese",
         any(grepl("6 feuille(s) identique(s) au bit pr\u00e8s", md, fixed = TRUE)))
verifier("plateforme() : R.version.string et systeme",
         identical(rg$plateforme(), sprintf("%s, %s", R.version.string, Sys.info()[["sysname"]])))

## --- Audit R1, point 1 : feuille designee + ancetre modifie au-dela de names
# Un ancetre d'une feuille designee n'est couvert que si sa difference se
# limite a l'attribut names.
m1 <- "tests\\[\\[1\\]\\]\\$detail"
b1 <- base; b1$tests[[1]]$detail <- "x modifie"
verifier("Feuille designee + classe de la racine changee : refus, (racine) listee",
         { b <- b1; class(b) <- "autre"; a <- analyser(base, b, m1)
           !a$acceptable && "(racine)" %in% a$structure_hors_motifs })
verifier("Feuille designee + attribut ajoute a tests : refus, tests liste",
         { b <- b1; attr(b$tests, "bar") <- 1; a <- analyser(base, b, m1)
           !a$acceptable && "tests" %in% a$structure_hors_motifs })
verifier("Feuille designee + attribut ajoute a tests[[1]] : refus",
         { b <- b1; attr(b$tests[[1]], "foo") <- "x"; a <- analyser(base, b, m1)
           !a$acceptable && "tests[[1]]" %in% a$structure_hors_motifs })
verifier("Feuille designee + classe de tests[[1]] changee : refus",
         { b <- b1; class(b$tests[[1]]) <- "autre"; a <- analyser(base, b, m1)
           !a$acceptable && "tests[[1]]" %in% a$structure_hors_motifs })
verifier("Feuille designee ajoutee dans une liste nommee : ancetre (names seul) couvert",
         { b <- base; b$tests[[1]]$nouveau <- "n"; analyser(base, b, "nouveau")$acceptable })
verifier("Noeud present d'un seul cote, non designe par un motif : refus",
         { a <- analyser(base, ajout, "tests\\[\\[3\\]\\]\\$")
           !a$acceptable && "tests[[3]]" %in% a$structure_hors_motifs })

## --- Point 2 : ecriture atomique ---------------------------------------------
dtmp <- tempfile("regen"); dir.create(dtmp)
fref <- file.path(dtmp, "cas.rds"); saveRDS(base, fref, version = 3)
md5_0 <- unname(tools::md5sum(fref))
verifier("remplacer_reference : verification en echec -> ancienne reference intacte, aucun temporaire",
         { b <- apres1; b$sigma <- 1   # sigma change hors motifs
           leve(rg$remplacer_reference(b, base, "tests[[2]]$detail", fref)) &&
             identical(unname(tools::md5sum(fref)), md5_0) &&
             identical(list.files(dtmp, all.files = TRUE, no.. = TRUE), "cas.rds") })
verifier("remplacer_reference : succes -> reference remplacee, aucun temporaire",
         { n <- rg$remplacer_reference(apres1, base, "tests[[2]]$detail", fref)
           identical(readRDS(fref), apres1) && n == length(rg$aplatir(base)) - 1L &&
             identical(list.files(dtmp, all.files = TRUE, no.. = TRUE), "cas.rds") })
unlink(dtmp, recursive = TRUE)

## --- Point 3 : chaines longues differant au-dela de la largeur ------------------
pa <- paste0(long, "FIN-A suite"); pb <- paste0(long, "FIN-B suite")
cp <- rg$cellules_paire(pa, pb)
verifier("cellules_paire : difference au-dela de la largeur -> fenetre autour du 1er caractere different",
         cp$avant != cp$apres && grepl("FIN-A", cp$avant, fixed = TRUE) && grepl("FIN-B", cp$apres, fixed = TRUE) &&
           grepl("car. 205", cp$avant, fixed = TRUE) && nchar(cp$avant) < nchar(pa))
verifier("cellules_paire : difference en tete -> troncature ordinaire",
         { c2 <- rg$cellules_paire(paste0("A", long), paste0("B", long))
           identical(c2$avant, rg$cellule(paste0("A", long))) })
verifier("Tableau : deux chaines longues differant en fin sont distinctes dans le tableau",
         { b <- base; b$tests[[1]]$detail <- pa; c2 <- base; c2$tests[[1]]$detail <- pb
           md2 <- rg$tableau_markdown(analyser(b, c2, "detail"), "cas")
           l <- grep("^\\| `tests", md2, value = TRUE)
           length(l) == 1L && grepl("FIN-A", l) && grepl("FIN-B", l) })

## --- Point 4 : motif sans effet, resultat identique -----------------------
verifier("Resultat identique + motif attendu : refus avec --ecrire (code 1), rapport a blanc (code 0)",
         { a <- analyser(base, base, "detail")
           d1 <- rg$decider(a, ecrire = TRUE); d0 <- rg$decider(a, ecrire = FALSE)
           identical(a$motifs_sans_effet, "detail") && d1$action == "rien" && d1$code == 1L && d0$code == 0L })
verifier("Resultat identique sans motif : rien a regenerer, code 0",
         { d <- rg$decider(analyser(base, base), ecrire = TRUE); d$action == "rien" && d$code == 0L })
verifier("decider : refus hors motifs -> code 1 avec --ecrire ; acceptable -> ecrire",
         { b <- apres1; b$sigma <- 0.2
           rg$decider(analyser(base, b, "detail"), TRUE)$code == 1L &&
             rg$decider(analyser(base, apres1, "detail"), TRUE)$action == "ecrire" })

## --- Point 5 : commande rejouable ------------------------------------------
verifier("commande_rejouable : toutes les options, motifs entre apostrophes shell",
         identical(rg$commande_rejouable("premium", c("tests\\[\\[47\\]\\]\\$detail", "it's"), "64",
                                         ecrire = TRUE, batteries = FALSE),
                   paste("Rscript tests/regenerer_et_rendre_compte.R premium",
                         "--attendu 'tests\\[\\[47\\]\\]\\$detail' --attendu 'it'\\''s'",
                         "--issue 64 --ecrire --sans-batteries")))

## --- Point 6 : motif trop large --------------------------------------------
verifier("Motif designant plus de SEUIL_MOTIF_LARGE feuilles : signale, sans refus",
         { g1 <- list(v = as.list(seq_len(rg$SEUIL_MOTIF_LARGE + 1L) + 0)); g2 <- g1
           g2$v <- lapply(g2$v, function(x) x + 0.5)
           a <- analyser(g1, g2, "^v")
           a$acceptable && identical(names(a$motifs_larges), "^v") &&
             a$motifs_larges[["^v"]] == rg$SEUIL_MOTIF_LARGE + 1L &&
             any(grepl("Avertissement", rg$tableau_markdown(a, "cas", motifs = "^v"))) })
verifier("Motif designant SEUIL_MOTIF_LARGE feuilles : non signale",
         { g1 <- list(v = as.list(seq_len(rg$SEUIL_MOTIF_LARGE) + 0)); g2 <- g1
           g2$v <- lapply(g2$v, function(x) x + 0.5)
           !length(analyser(g1, g2, "^v")$motifs_larges) })

## --- Alignement sur comparer_references.R (#66, audit leger de b012f7a) -----
# Hors tableau (commande, motifs, structure, feuille maximale, batteries) :
# texte_code(), barre verticale NON echappee (un antislash s'afficherait dans
# la police de code) ; dans le tableau : cellule(), barre echappee.
# Reference : texte_code() et cellule() de outils_tests.R, et le rendu de
# comparer_references.R --markdown.
verifier("Hors tableau : motifs, commande, structure et feuille maximale via texte_code() (barre non echappee)",
         { b <- base; b[["x|y"]] <- 1; c2 <- b; c2[["x|y"]] <- 2; attr(c2$tests, "k") <- 1
           a <- analyser(b, c2, c("x\\|y", "a|b"))
           md3 <- rg$tableau_markdown(a, "cas", motifs = c("x\\|y", "a|b"),
                                      commande = "Rscript tests/regenerer_et_rendre_compte.R cas --attendu 'a|b'")
           hors <- grep("^\\|", md3, value = TRUE, invert = TRUE)
           any(hors == "- Commande : `Rscript tests/regenerer_et_rendre_compte.R cas --attendu 'a|b'`") &&
             any(hors == "- Motifs attendus : `x\\|y`, `a|b`") &&
             any(grepl("(relatif, `x|y`)", hors, fixed = TRUE)) &&
             any(grepl("modifi\u00e9s (type ou attributs) : `tests`", hors, fixed = TRUE)) &&
             !any(grepl("a\\|b", hors, fixed = TRUE)) &&
             any(grepl("^\\| `x\\\\\\|y` \\|", md3)) })
verifier("Hors tableau : avertissement de motif large via texte_code() (barre non echappee)",
         { g1 <- list(v = as.list(seq_len(rg$SEUIL_MOTIF_LARGE + 1L) + 0)); g2 <- g1
           g2$v <- lapply(g2$v, function(x) x + 0.5)
           m <- "^v|^w"
           md3 <- rg$tableau_markdown(analyser(g1, g2, m), "cas", motifs = m)
           l <- grep("Avertissement", md3, value = TRUE)
           length(l) == 1L && grepl("motif `^v|^w` :", l, fixed = TRUE) })
verifier("Tableau : valeur manquante affichee \\<NA\\> (reference_na / obtenu_na), distincte de la chaine \"NA\"",
         { b <- list(a = NA_real_, s = "NA", c = 1, d = NA_character_)
           c2 <- list(a = 0.5, s = "x", c = NA_real_, d = "NA")
           md3 <- rg$tableau_markdown(analyser(b, c2, "."), "cas")
           ligne <- function(ch) grep(sprintf("^\\| `%s` \\|", ch), md3, value = TRUE)
           identical(ligne("a"), "| `a` | \\<NA\\> | 0.5 |  | non fini |") &&
             identical(ligne("s"), "| `s` | NA | x |  | non numerique |") &&
             identical(ligne("c"), "| `c` | 1 | \\<NA\\> |  | non fini |") &&
             identical(ligne("d"), "| `d` | \\<NA\\> | NA |  | non numerique |") })
verifier("Tableau : feuille ajoutee ou supprimee reste '(absente)' du cote manquant",
         { b <- list(a = 1); c2 <- list(a = 1, n = NA_real_)
           md3 <- rg$tableau_markdown(analyser(b, c2, "n"), "cas")
           md4 <- rg$tableau_markdown(analyser(c2, b, "n"), "cas")
           any(grepl("^\\| `n` \\| \\(absente\\) \\| \\\\<NA\\\\> \\|", md3)) &&
             any(grepl("^\\| `n` \\| \\\\<NA\\\\> \\| \\(absente\\) \\|", md4)) })

fin_fichier()
