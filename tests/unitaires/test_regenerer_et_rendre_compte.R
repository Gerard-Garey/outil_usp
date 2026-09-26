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
#  avec patcher_reference.R ; le mode creation (M31) ; et, pour plusieurs cas
#  (M33), lire_arguments() (motifs par cas, doublons, noms invalides),
#  commande_rejouable(), remplacer_references() (tout ou rien, restauration)
#  et references_hors_liste() (md5 des .rds hors liste) ; enfin
#  ecrire_console() sous LC_ALL=C et sous la locale du poste (issue #82).
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

## --- Mode creation (M31) -----------------------------------------------------
# Reference : specification M31 (ADR 0011 amende) -- refus si le .rds existe,
# aucun .rds existant modifie, tableau "absent / ajoute" seulement. Fichiers
# ecrits dans un dossier temporaire, jamais dans tests/reference/.
verifier("NOM_CAS_VALIDE : noms de CAS et premium_ii6 admis ; point, barre, espace, majuscule refuses",
         all(grepl(rg$NOM_CAS_VALIDE, c(names(rg$CAS), "premium_ii6", "premium_net"))) &&
           !any(grepl(rg$NOM_CAS_VALIDE, c("../premium", "premium.rds", "a b", "Premium", "_x", "1cas", ""))))
verifier("references_modifiees : seul l'ajout du fichier cree -> aucun ecart",
         identical(rg$references_modifiees(c(a.rds = "1", b.rds = "2"),
                                           c(a.rds = "1", b.rds = "2", n.rds = "3"), "n.rds"), character(0)))
verifier("references_modifiees : md5 modifie, fichier disparu, fichier en plus, fichier deja present",
         { m <- rg$references_modifiees(c(a.rds = "1", b.rds = "2", n.rds = "0"),
                                        c(a.rds = "9", n.rds = "3", x.rds = "4"), "n.rds")
           length(m) == 4L && any(grepl("^a.rds : modifie", m)) && any(grepl("^b.rds : disparu", m)) &&
             any(grepl("^x.rds : apparu", m)) && any(grepl("^n.rds : existait deja", m)) })
verifier("references_modifiees : fichier cree absent apres -> ecart",
         identical(rg$references_modifiees(c(a.rds = "1"), c(a.rds = "1"), "n.rds"),
                   "n.rds : absent apres la creation"))
.dos <- tempfile("creation-"); dir.create(.dos)
verifier("creer_reference : ecrit un fichier relu identical(), sans temporaire residuel ; md5 des autres inchange",
         { rg$ecrire_reference(NA, list(x = 1), chemin = file.path(.dos, "a.rds"))
           e0 <- rg$empreintes_references(.dos)
           obj <- list(sigma = 0.1, v = 1:3, s = "t")
           rg$creer_reference(obj, file.path(.dos, "n.rds"))
           e1 <- rg$empreintes_references(.dos)
           identical(readRDS(file.path(.dos, "n.rds")), obj) &&
             identical(sort(list.files(.dos, all.files = TRUE, no.. = TRUE)), c("a.rds", "n.rds")) &&
             !length(rg$references_modifiees(e0, e1, "n.rds")) })
verifier("creer_reference : refus si le fichier existe, fichier existant intact",
         { f <- file.path(.dos, "a.rds"); m0 <- unname(tools::md5sum(f))
           leve(rg$creer_reference(list(y = 2), f)) && identical(unname(tools::md5sum(f)), m0) &&
             identical(readRDS(f), list(x = 1)) })
verifier("empreintes_references : ignore les fichiers caches (temporaires) et non .rds",
         { writeLines("t", file.path(.dos, ".n-tmp.rds")); writeLines("t", file.path(.dos, "notes.txt"))
           identical(names(rg$empreintes_references(.dos)), c("a.rds", "n.rds")) })
unlink(.dos, recursive = TRUE)
verifier("tableau_creation_markdown : ligne absent / ajoute, sigma, references existantes intactes",
         { res <- list(parametre_final = list(sigma_usp = 0.1234567891), v = 1:3)
           md <- rg$tableau_creation_markdown("cas_x", res, "cas_x.rds", c(a.rds = "m1"),
                                              c(a.rds = "m1", cas_x.rds = "m2"), issue = "61",
                                              commande = "Rscript tests/regenerer_et_rendre_compte.R cas_x --creer --issue 61 --ecrire")
           any(md == "| `tests/reference/cas_x.rds` | (absente) | ajout\u00e9e : 4 feuille(s), md5 `m2` |") &&
             any(grepl("0.1234567891", md, fixed = TRUE)) &&
             any(grepl("md5 identiques avant / apr\u00e8s (`a.rds`)", md, fixed = TRUE)) &&
             grepl("(issue #61)", md[1], fixed = TRUE) && !any(grepl("MODIFI", md)) })
verifier("tableau_creation_markdown : reference existante modifiee signalee",
         { md <- rg$tableau_creation_markdown("cas_x", list(v = 1), "cas_x.rds", c(a.rds = "m1"),
                                              c(a.rds = "m9", cas_x.rds = "m2"))
           any(grepl("MODIFI\u00c9ES", md)) && any(grepl("a.rds : modifie", md, fixed = TRUE)) })
verifier("commande_rejouable : --creer apres le nom du cas",
         identical(rg$commande_rejouable("premium_ii6", character(0), "61", ecrire = TRUE,
                                         batteries = TRUE, creer = TRUE),
                   "Rscript tests/regenerer_et_rendre_compte.R premium_ii6 --creer --issue 61 --ecrire"))

## --- Plusieurs cas (M33) -------------------------------------------------------
# Reference : specification M33 (ADR 0011, complement du 24/09/2026) --
# motifs attendus par cas, tout ou rien, cas seul inchange. Fichiers ecrits
# dans un dossier temporaire, jamais dans tests/reference/.
la <- rg$lire_arguments
verifier("lire_arguments : un cas, motifs avant ou apres le nom, dans l'ordre (usage anterieur)",
         { x <- la(c("--attendu", "a", "premium", "--attendu", "b", "--issue", "40", "--ecrire"))
           identical(x$cas, "premium") && identical(x$motifs, list(premium = c("a", "b"))) &&
             identical(x$issue, "40") && x$ecrire && x$batteries && !x$creer })
verifier("lire_arguments : plusieurs cas, chaque --attendu rattache au dernier cas nomme",
         { x <- la(c("premium", "--attendu", "a", "--attendu", "b", "reserve2", "--attendu", "c",
                     "--issue", "40", "--sans-batteries"))
           identical(x$cas, c("premium", "reserve2")) &&
             identical(x$motifs, list(premium = c("a", "b"), reserve2 = "c")) && !x$batteries })
verifier("lire_arguments : cas sans motif conserve (vecteur vide)",
         identical(la(c("premium", "reserve1", "--attendu", "c"))$motifs,
                   list(premium = character(0), reserve1 = "c")))
verifier("lire_arguments : refus d'un doublon, d'un motif avant le premier de plusieurs cas, d'un nom invalide ou inconnu",
         leve(la(c("premium", "--attendu", "a", "premium", "--attendu", "b"))) &&
           leve(la(c("--attendu", "a", "premium", "reserve1"))) &&
           leve(la(c("premium", "../x"))) && leve(la(c("Premium"))) &&
           leve(la(c("premium", "inconnu_x"))))
verifier("lire_arguments : --creer a plusieurs cas, --ecrire sans --issue, --issue double ou non numerique, aucun cas -> erreur",
         leve(la(c("premium", "reserve1", "--creer"))) && leve(la(c("premium", "--ecrire"))) &&
           leve(la(c("premium", "--issue", "1", "--issue", "2"))) && leve(la(c("premium", "--issue", "x"))) &&
           leve(la(c("--issue", "1"))) && leve(la(c("premium", "--attendu"))))
verifier("lire_arguments : valeur de --attendu egale a un drapeau ou commencant par -- refusee, drapeaux lus a leur place",
         leve(la(c("premium", "--attendu", "--sans-batteries", "reserve1", "--attendu", "b"))) &&
           leve(la(c("premium", "--attendu", "--ecrire", "--issue", "40"))) &&
           leve(la(c("premium", "--attendu", "--x"))) && leve(la(c("premium", "--issue", "--ecrire"))) &&
           { x <- la(c("premium", "--sans-batteries", "--attendu", "a", "reserve1", "--attendu", "b",
                       "--issue", "40", "--ecrire"))
             !x$batteries && x$ecrire && !x$creer &&
               identical(x$motifs, list(premium = "a", reserve1 = "b")) })
verifier("commande_rejouable : un cas, motifs en liste = motifs en vecteur (sortie d'avant M33)",
         identical(rg$commande_rejouable("premium", list(premium = c("a", "it's")), "40", TRUE, TRUE),
                   rg$commande_rejouable("premium", c("a", "it's"), "40", TRUE, TRUE)))
verifier("commande_rejouable : plusieurs cas, chacun suivi de ses --attendu ; relue par lire_arguments a l'identique",
         { cmd <- rg$commande_rejouable(c("premium", "reserve2"), list(premium = c("a", "b"), reserve2 = "c|d"),
                                        "40", ecrire = TRUE, batteries = FALSE)
           # Relecture comme le ferait un shell POSIX (motifs sans apostrophe).
           mots <- gsub("^'|'$", "", strsplit(sub("^Rscript tests/regenerer_et_rendre_compte.R ", "", cmd), " ")[[1]])
           x <- la(mots)
           identical(cmd, paste("Rscript tests/regenerer_et_rendre_compte.R premium --attendu 'a' --attendu 'b'",
                                "reserve2 --attendu 'c|d' --issue 40 --ecrire --sans-batteries")) &&
             identical(x$motifs, list(premium = c("a", "b"), reserve2 = "c|d")) && !x$batteries })
verifier("tableau_markdown : ligne multi-cas seulement avec plusieurs cas",
         { a <- analyser(base, apres1, "detail")
           m1 <- rg$tableau_markdown(a, "premium", 40, "detail", cas_execution = "premium")
           m2 <- rg$tableau_markdown(a, "premium", 40, "detail", cas_execution = c("premium", "reserve2"))
           identical(m1, rg$tableau_markdown(a, "premium", 40, "detail")) &&
             length(m2) == length(m1) + 1L &&
             any(grepl("plusieurs cas (M33) : `premium`, `reserve2`", m2, fixed = TRUE)) })
verifier("references_hors_liste : seuls des fichiers de la liste changent -> aucun ecart",
         identical(rg$references_hors_liste(c(a.rds = "1", b.rds = "2", c.rds = "3"),
                                            c(a.rds = "9", b.rds = "8", c.rds = "3"), c("a.rds", "b.rds")),
                   character(0)))
verifier("references_hors_liste : hors liste modifie, fichier disparu, fichier apparu",
         { m <- rg$references_hors_liste(c(a.rds = "1", b.rds = "2", c.rds = "3"),
                                         c(a.rds = "9", c.rds = "7", x.rds = "4"), "a.rds")
           length(m) == 3L && any(grepl("^c.rds : modifie hors liste", m)) &&
             any(grepl("^b.rds : disparu", m)) && any(grepl("^x.rds : apparu", m)) })
.dm <- tempfile("multi-"); dir.create(.dm)
fa <- file.path(.dm, "a.rds"); fb <- file.path(.dm, "b.rds"); fc <- file.path(.dm, "c.rds")
for (f in c(fa, fb, fc)) saveRDS(base, f, version = 3)
e0 <- rg$empreintes_references(.dm)
cache_vide <- function() identical(sort(list.files(.dm, all.files = TRUE, no.. = TRUE)), c("a.rds", "b.rds", "c.rds"))
verifier("remplacer_references : echec du 2e cas -> 1er cas restaure, aucune reference modifiee, aucun fichier residuel",
         { mauvais <- apres1; mauvais$sigma <- 1   # sigma change hors motifs : verification en echec
           lots <- list(list(apres = apres1, avant = base, designees = "tests[[2]]$detail", chemin = fa),
                        list(apres = mauvais, avant = base, designees = "tests[[2]]$detail", chemin = fb))
           e <- tryCatch(rg$remplacer_references(lots), error = function(e) conditionMessage(e))
           is.character(e) && grepl("b.rds", e, fixed = TRUE) && grepl("2 reference(s) restauree(s)", e, fixed = TRUE) &&
             identical(rg$empreintes_references(.dm), e0) && cache_vide() })
verifier("remplacer_references : echec du 2e cas APRES sa substitution -> tous les md5 d'origine, aucun fichier residuel",
         { # Enveloppe : le 2e appel substitue (vraie fonction), puis echoue,
           # comme une relecture differente apres file.rename() (audit de M33).
           vraie <- rg$remplacer_reference; appels <- 0L
           rg$remplacer_reference <- function(...) {
             appels <<- appels + 1L; n <- vraie(...)
             if (appels == 2L) stop("relecture simulee differente apres substitution")
             n }
           lots <- list(list(apres = apres1, avant = base, designees = "tests[[2]]$detail", chemin = fa),
                        list(apres = apres1, avant = base, designees = "tests[[2]]$detail", chemin = fb))
           e <- tryCatch(rg$remplacer_references(lots), error = function(e) conditionMessage(e))
           rg$remplacer_reference <- vraie
           is.character(e) && appels == 2L && grepl("aucune reference modifiee", e, fixed = TRUE) &&
             identical(rg$empreintes_references(.dm), e0) && cache_vide() })
verifier("remplacer_references : succes -> cas de la liste remplaces, hors liste intact, aucun fichier residuel",
         { lots <- list(list(apres = apres1, avant = base, designees = "tests[[2]]$detail", chemin = fa),
                        list(apres = apres1, avant = base, designees = "tests[[2]]$detail", chemin = fb))
           n <- rg$remplacer_references(lots)
           e1 <- rg$empreintes_references(.dm)
           identical(n, rep(length(rg$aplatir(base)) - 1L, 2L)) &&
             identical(readRDS(fa), apres1) && identical(readRDS(fb), apres1) &&
             !length(rg$references_hors_liste(e0, e1, c("a.rds", "b.rds"))) &&
             e1[["c.rds"]] == e0[["c.rds"]] && e1[["a.rds"]] != e0[["a.rds"]] && cache_vide() })
unlink(.dm, recursive = TRUE)

## --- Console en UTF-8 quelle que soit la locale (issue #82) ---------------
# Script lance dans un processus R separe, sous LC_ALL=C puis sous la locale
# du poste ; la sortie standard est relue en octets. Le script source
# regenerer_et_rendre_compte.R (programme principal non execute) et ecrit la
# meme ligne par ecrire_console() puis par writeLines() (temoin du defaut).
.console82 <- function(lc) {
  d <- tempfile("console82-"); dir.create(d); on.exit(unlink(d, recursive = TRUE))
  s <- file.path(d, "s.R"); o <- file.path(d, "o.txt")
  writeLines(c(sprintf("DOSSIER_TESTS <- \"%s\"", normalizePath(rg$DOSSIER_TESTS, winslash = "/")),
               "source(file.path(DOSSIER_TESTS, \"regenerer_et_rendre_compte.R\"))",
               "x <- \"apr\\u00e8s \\u2014 r\\u00e9f\\u00e9rence\"",
               "ecrire_console(x); writeLines(x)"), s)
  ancien <- Sys.getenv("LC_ALL", unset = NA)
  on.exit(if (is.na(ancien)) Sys.unsetenv("LC_ALL") else Sys.setenv(LC_ALL = ancien), add = TRUE)
  if (is.na(lc)) Sys.unsetenv("LC_ALL") else Sys.setenv(LC_ALL = lc)
  suppressWarnings(system2(file.path(R.home("bin"), "Rscript"), s, stdout = o, stderr = FALSE))
  l <- strsplit(rawToChar(readBin(o, "raw", file.size(o))), "\r?\n", useBytes = TRUE)[[1]]
  lapply(l[nzchar(l)], charToRaw)
}
.utf8_82 <- charToRaw(enc2utf8("après — référence"))
.c82 <- .console82("C")
verifier("Issue #82 : ecrire_console() ecrit les octets UTF-8 sous LC_ALL=C",
         length(.c82) == 2L && identical(.c82[[1]], .utf8_82))
verifier("Issue #82 (temoin) : writeLines() seul sous LC_ALL=C n'ecrit pas ces octets (<U+00E8>...)",
         length(.c82) == 2L && !identical(.c82[[2]], .utf8_82) && grepl("<U+00E8>", rawToChar(.c82[[2]]), fixed = TRUE))
.n82 <- .console82(NA)
verifier("Issue #82 : sans LC_ALL, ecrire_console() et writeLines() ecrivent les memes octets (sortie inchangee sous une locale UTF-8)",
         !isTRUE(l10n_info()[["UTF-8"]]) || (length(.n82) == 2L && identical(.n82[[1]], .utf8_82) && identical(.n82[[2]], .utf8_82)))

fin_fichier()
