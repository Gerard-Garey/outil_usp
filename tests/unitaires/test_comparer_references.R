###############################################################################
#  tests/unitaires/test_comparer_references.R  --  SORTIE MARKDOWN DE
#  comparer_references.R (issue #66)
#
#  Teste markdown_cas(), borner_markdown() et ajouter_markdown() de
#  tests/comparer_references.R sur des objets construits a la main, sans
#  reference ni appel du moteur : section d'un cas conforme, tableau des
#  ecarts (colonnes, echappement, colonne Seuil), plafond de lignes par cas,
#  cas en erreur, troncature a une fin de ligne sous la limite d'octets
#  (UTF-8), ajout a un fichier existant sans depasser la limite, place
#  insuffisante (rien d'ajoute, sans erreur), barre verticale non echappee
#  hors tableau, valeur manquante distincte de la chaine "NA", reference
#  absente comptee comme erreur (code de sortie 1) ; tableau de bascule en
#  deux parts (--deux-parts, issue #67) : separation numerique / non
#  numerique, motifs de refus, section markdown.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_comparer_references.R")

# Meme chargement que test_regenerer_et_rendre_compte.R : environnement dedie.
.dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
cr <- new.env(parent = globalenv())
cr$DOSSIER_TESTS <- file.path(.dossier, "..")
sys.source(file.path(cr$DOSSIER_TESTS, "comparer_references.R"), envir = cr)

leve <- function(expr) inherits(tryCatch(expr, error = function(e) e), "error")
octets <- function(l) sum(nchar(enc2utf8(l), type = "bytes") + 1)
lignes_tableau <- function(md) grep("^\\| `", md, value = TRUE)

base <- list(sigma = 0.123456789, tests = list(list(test = "A", p = 0.5, verdict = "OK"),
                                               list(test = "B", p = 0.25, verdict = "OK")))

## --- Cas conforme ------------------------------------------------------------
r0 <- cr$comparer_objets(base, base)
md0 <- cr$markdown_cas("premium", r0)
verifier("markdown_cas : cas conforme -> titre CONFORME, synthese, aucun tableau",
         md0[1] == "### `premium` : CONFORME" && any(grepl("^- Synth.*CONFORME", md0)) &&
         !any(grepl("^\\|", md0)))

## --- Cas non conforme : tableau ------------------------------------------------
b <- base; b$sigma <- 0.2; b$tests[[1]]$verdict <- "ALERTE | x"; b$tests[[2]]$p <- NULL
r1 <- cr$comparer_objets(base, b)
md1 <- cr$markdown_cas("premium", r1)
tl <- lignes_tableau(md1)
verifier("markdown_cas : en-tete Feuille | Reference | Valeur | Ecart | Seuil",
         any(md1 == "| Feuille | R\u00e9f\u00e9rence | Valeur | \u00c9cart | Seuil |"))
verifier("markdown_cas : une ligne de tableau par ecart, cinq colonnes, barres internes echappees",
         length(tl) == r1$n_ecarts &&
         all(lengths(regmatches(tl, gregexpr("(?<!\\\\)\\|", tl, perl = TRUE))) == 6L))
verifier("markdown_cas : colonne Seuil selon la mesure (relatif, non numerique, absente)",
         any(grepl("^\\| `sigma` .*\\| 1e-06 \\(relatif\\) \\|$", tl)) &&
         any(grepl("verdict` .*identit\u00e9 exig\u00e9e \\(non numerique\\) \\|$", tl)) &&
         any(grepl("^\\| `tests\\[\\[2\\]\\]\\$p` .*feuille absente du r\u00e9sultat \\|$", tl)))
verifier("markdown_cas : valeurs en police de code, ecart en notation scientifique",
         any(grepl("^\\| `sigma` \\| `0.123456789` \\| `0.2` \\| 6.200e-01 \\|", tl)))

## --- Plafond de lignes par cas ------------------------------------------------
v <- list(x = seq(1, 2, length.out = 30)); w <- list(x = v$x * 2)
r2 <- cr$comparer_objets(v, w)
md2 <- cr$markdown_cas("reserve1", r2, max_lignes = 7L)
verifier("markdown_cas : au plus max_lignes lignes, les autres decomptees",
         length(lignes_tableau(md2)) == 7L && r2$n_ecarts == 30L &&
         any(grepl("^\\*23 ligne\\(s\\) omise\\(s\\) sur 30 \\(au plus 7 par cas\\)", md2)))
verifier("markdown_cas : la commande de la liste complete reprend un seuil non standard",
         any(grepl("comparer_references.R reserve1 --seuil 0`", cr$markdown_cas("reserve1", r2, seuil = 0, max_lignes = 1L))))

## --- Cas en erreur ----------------------------------------------------------------
verifier("markdown_cas : erreur -> titre ERREUR et message sur une ligne",
         { m <- cr$markdown_cas("reserve2", erreur = "boum\nligne 2")
           m[1] == "### `reserve2` : ERREUR" && any(m == "Comparaison impossible : `boum ligne 2`") })

## --- Bornage en octets ---------------------------------------------------------------
l <- c(md1, rep("| `x` | `\u00e9\u00e9\u00e9` | `y` | 1 | 1e-06 (relatif) |", 200))
verifier("borner_markdown : texte sous la limite rendu tel quel",
         identical(cr$borner_markdown(l, octets(l)), enc2utf8(l)))
verifier("borner_markdown : au-dela, taille <= limite, debut conserve, lignes omises decomptees",
         { t <- cr$borner_markdown(l, 2000)
           n <- length(t) - 2L
           octets(t) <= 2000 && identical(t[seq_len(n)], enc2utf8(l[seq_len(n)])) &&
           grepl(sprintf("^\\*\\*R\u00e9sum\u00e9 tronqu\u00e9\\*\\* : %d ligne\\(s\\) omise\\(s\\) sur %d ",
                         length(l) - n, length(l)), t[length(t)]) &&
           octets(c(t[seq_len(n)], l[n + 1L], t[(n + 1L):length(t)])) > 2000 })
verifier("borner_markdown : limite plus petite que la mention -> erreur de classe markdown_trop_petit",
         inherits(tryCatch(cr$borner_markdown(l, 50), error = function(e) e), "markdown_trop_petit"))

## --- Ajout a un fichier -----------------------------------------------------------------
verifier("ajouter_markdown : ajoute a la suite du contenu existant, fichier <= limite",
         { f <- tempfile(fileext = ".md"); on.exit(unlink(f))
           writeLines("deja la", f)
           cr$ajouter_markdown(l, f, max_octets = 3000)
           x <- readLines(f, encoding = "UTF-8")
           x[1] == "deja la" && file.size(f) <= 3000 && grepl("limite de 3000 octets", x[length(x)]) })

verifier("ajouter_markdown : place restante trop petite -> rien d'ajoute, avertissement, pas d'erreur",
         { f <- tempfile(fileext = ".md"); on.exit(unlink(f))
           writeLines(strrep("x", 2950), f); t0 <- file.size(f)
           sortie <- capture.output(res <- tryCatch(cr$ajouter_markdown(l, f, max_octets = 3000),
                                                    error = function(e) e))
           identical(res, character(0)) && file.size(f) == t0 &&
           any(grepl("^AVERTISSEMENT : markdown non ajoute", sortie)) })
verifier("ajouter_markdown : fichier deja au-dela de la limite -> rien d'ajoute, pas d'erreur",
         { f <- tempfile(fileext = ".md"); on.exit(unlink(f))
           writeLines(strrep("x", 4000), f); t0 <- file.size(f)
           invisible(capture.output(res <- cr$ajouter_markdown(l, f, max_octets = 3000)))
           identical(res, character(0)) && file.size(f) == t0 })
verifier("ajouter_markdown : place trop petite et fichier absent -> fichier non cree",
         { f <- tempfile(fileext = ".md")
           invisible(capture.output(cr$ajouter_markdown(l, f, max_octets = 50)))
           !file.exists(f) })

## --- Barre verticale hors tableau, manquants (issue #66, audit leger) --------------------
verifier("texte_code : une ligne, accent grave remplace, barre verticale non echappee, troncature de cellule()",
         identical(cr$texte_code("a|b\nc`d"), "a|b c'd") &&
         identical(cr$texte_code(strrep("z", 70)), gsub("\\|", "|", cr$cellule(strrep("z", 70)))) &&
         identical(cr$cellule("a|b\nc`d"), "a\\|b c'd"))
verifier("markdown_cas : barre verticale non echappee hors tableau (erreur, synthese, structure)",
         { m <- cr$markdown_cas("reserve2", erreur = "x | y")
           rs <- cr$comparer_objets(list(`a|b` = 1), list(`a|b` = 2))
           rt <- cr$comparer_objets(list(`a|b` = list(1)), list(`a|b` = list(1L)))
           ms <- cr$markdown_cas("premium", rs); mt <- cr$markdown_cas("premium", rt)
           any(m == "Comparaison impossible : `x | y`") &&
           any(grepl("^- Synth.*a\\|b", ms)) && !any(grepl("^- Synth.*\\\\\\|", ms)) &&
           any(grepl("^- Structure .*`a\\|b", mt)) && !any(grepl("^- Structure .*\\\\\\|", mt)) &&
           any(grepl("^\\| `a\\\\\\|b` \\|", lignes_tableau(ms))) })
verifier("markdown_cas : NA manquant affiche \\<NA\\> hors police de code, chaine \"NA\" en `NA`",
         { rn <- cr$comparer_objets(list(p = 0.5, q = "NA", s = "x"), list(p = NA_real_, q = "y", s = NA))
           tn <- lignes_tableau(cr$markdown_cas("premium", rn))
           any(grepl("^\\| `p` \\| `0.5` \\| \\\\<NA\\\\> \\|", tn)) &&
           any(grepl("^\\| `q` \\| `NA` \\| `y` \\|", tn)) &&
           any(grepl("^\\| `s` \\| `x` \\| \\\\<NA\\\\> \\|", tn)) &&
           identical(rn$ecarts$reference_na, c(FALSE, FALSE, FALSE)) &&
           identical(rn$ecarts$obtenu_na, c(TRUE, FALSE, TRUE)) })
verifier("comparer_objets : NaN n'est pas marque manquant",
         !cr$comparer_objets(list(p = 1), list(p = NaN))$ecarts$obtenu_na)

## --- Tableau de bascule en deux parts (--deux-parts, issue #67, Q-O4) -------------------
ref_b <- list(sigma = 0.5, zero = 1e-17, n = 3L, v = c(1, 2, 3),
              ctl = list(verdict = "OK", detail = "a", kkt = TRUE), p = 0.2)
obt_b <- ref_b
obt_b$sigma <- 0.5 * (1 + 3e-7); obt_b$zero <- 2e-16; obt_b$v[2] <- 2 * (1 + 1e-9)
pb <- cr$separer_parts(cr$comparer_objets(ref_b, obt_b, tol = 0))
verifier("separer_parts : derive seule -> part numerique (triee par ecart decroissant), part non numerique vide",
         identical(pb$numerique$chemin, c("sigma", "v[2]", "zero")) &&
         identical(pb$numerique$mesure, c("relatif", "relatif", "absolu")) &&
         !nrow(pb$non_numerique) && !length(pb$structure) && !length(cr$refus_bascule(pb)))
verifier("separer_parts : exige comparer_objets() au seuil 0",
         leve(cr$separer_parts(cr$comparer_objets(ref_b, obt_b))))
obt_c <- obt_b
obt_c$ctl$detail <- "b"; obt_c$ctl$kkt <- FALSE; obt_c$p <- NA_real_; obt_c$n <- 3
pc <- cr$separer_parts(cr$comparer_objets(ref_b, obt_c, tol = 0))
verifier("separer_parts : chaine, booleen, NA et changement de type -> part non numerique",
         setequal(pc$non_numerique$chemin, c("ctl$detail", "ctl$kkt", "p", "n")) &&
         identical(sort(unique(pc$non_numerique$mesure)), c("non fini", "non numerique")) &&
         identical(pc$numerique$chemin, c("sigma", "v[2]", "zero")))
verifier("refus_bascule : part non numerique non vide -> un motif de refus",
         { rf <- cr$refus_bascule(pc); length(rf) == 1L && grepl("^part non numerique non vide : 4 feuille", rf) })
obt_d <- obt_b; obt_d$v[3] <- 3 * (1 + 2e-6)
pd <- cr$separer_parts(cr$comparer_objets(ref_b, obt_d, tol = 0))
verifier("refus_bascule : ecart numerique > TOLERANCE -> refus (ce n'est plus de la derive)",
         { rf <- cr$refus_bascule(pd); length(rf) == 1L && grepl("^1 ecart\\(s\\) numerique\\(s\\) au-dela du seuil 1e-06", rf) })
pe <- cr$separer_parts(cr$comparer_objets(list(a = list(1)), list(a = list(1L)), tol = 0))
verifier("refus_bascule : structure differente seule -> refus",
         length(pe$structure) > 0L && length(cr$refus_bascule(pe)) == 1L)
verifier("markdown_deux_parts : derive seule -> titre, synthese des deux parts, un seul tableau",
         { m <- cr$markdown_deux_parts("premium", pb, 9L)
           m[1] == "### `premium` : d\u00e9rive num\u00e9rique seule" &&
           any(grepl("^- Part num\u00e9rique : 3 feuille\\(s\\) .* sur 9 ; \u00e9cart maximal 3.000e-07 \\(relatif, `sigma`\\) ; 0 au-del\u00e0", m)) &&
           any(m == "- Part non num\u00e9rique (doit \u00eatre vide) : 0 feuille(s)") &&
           !any(grepl("^#### Part non", m)) && length(lignes_tableau(m)) == 3L && !any(grepl("Refus", m)) })
verifier("markdown_deux_parts : part non numerique -> BASCULE REFUSEE, ses lignes, plafond par part",
         { m <- cr$markdown_deux_parts("reserve1", pc, 9L, max_lignes = 2L)
           m[1] == "### `reserve1` : BASCULE REFUS\u00c9E" && any(grepl("^- \\*\\*Refus\\*\\* : ", m)) &&
           any(m == "#### Part non num\u00e9rique") && length(lignes_tableau(m)) == 4L &&
           any(grepl("^\\*2 ligne\\(s\\) omise\\(s\\) sur 4 \\(au plus 2 par part\\)", m)) &&
           any(grepl("^\\*1 ligne\\(s\\) omise\\(s\\) sur 3 \\(au plus 2 par part\\)", m)) })

verifier("comparer_references.R : --deux-parts et --seuil incompatibles (erreur, aucun cas execute)",
         { owd <- setwd(file.path(cr$DOSSIER_TESTS, "..")); on.exit(setwd(owd))
           sortie <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
             c("tests/comparer_references.R", "--deux-parts", "--seuil", "0"), stdout = TRUE, stderr = TRUE))
           identical(attr(sortie, "status"), 1L) && any(grepl("--seuil incompatible", sortie)) &&
           !any(grepl("^=== ", sortie)) })

## --- Reference absente : erreur, code de sortie 1 ------------------------------------------
verifier("comparer_references.R : reference absente -> ERREUR dans le markdown et code de sortie 1",
         { d <- tempfile(); dir.create(file.path(d, "tests", "reference"), recursive = TRUE)
           on.exit(unlink(d, recursive = TRUE))
           for (f in c("tests/outils_tests.R", "tests/comparer_references.R"))
             file.copy(file.path(cr$DOSSIER_TESTS, "..", f), file.path(d, f))
           dir.create(file.path(d, "R")); dir.create(file.path(d, "tests", "donnees"))
           file.copy(file.path(cr$DOSSIER_TESTS, "..", "R", "engine.R"), file.path(d, "R"))
           file.copy(list.files(file.path(cr$DOSSIER_TESTS, "donnees"), full.names = TRUE),
                     file.path(d, "tests", "donnees"))
           md <- file.path(d, "resume.md")
           # RACINE (outils_tests.R) se deduit du repertoire courant.
           # Retour au repertoire initial garanti par on.exit(), meme si
           # system2() leve une erreur (sinon les fichiers suivants
           # tourneraient dans d, puis supprime) ; after = FALSE : on quitte d
           # avant de le supprimer (unlink ci-dessus).
           owd <- setwd(d)
           on.exit(setwd(owd), add = TRUE, after = FALSE)
           sortie <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
             c("tests/comparer_references.R", "premium", "--markdown", md),
             stdout = TRUE, stderr = TRUE))
           statut <- attr(sortie, "status")
           x <- readLines(md, encoding = "UTF-8")
           identical(statut, 1L) && any(x == "### `premium` : ERREUR") &&
           any(grepl("reference absente", sortie)) })

fin_fichier()
