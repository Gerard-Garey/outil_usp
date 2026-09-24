###############################################################################
#  tests/unitaires/test_comparer_references.R  --  SORTIE MARKDOWN DE
#  comparer_references.R (issue #66)
#
#  Teste markdown_cas(), borner_markdown() et ajouter_markdown() de
#  tests/comparer_references.R sur des objets construits a la main, sans
#  reference ni appel du moteur : section d'un cas conforme, tableau des
#  ecarts (colonnes, echappement, colonne Seuil), plafond de lignes par cas,
#  cas en erreur, troncature a une fin de ligne sous la limite d'octets
#  (UTF-8), ajout a un fichier existant sans depasser la limite.
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
verifier("borner_markdown : limite plus petite que la mention -> erreur",
         leve(cr$borner_markdown(l, 50)))

## --- Ajout a un fichier -----------------------------------------------------------------
verifier("ajouter_markdown : ajoute a la suite du contenu existant, fichier <= limite",
         { f <- tempfile(fileext = ".md"); on.exit(unlink(f))
           writeLines("deja la", f)
           cr$ajouter_markdown(l, f, max_octets = 3000)
           x <- readLines(f, encoding = "UTF-8")
           x[1] == "deja la" && file.size(f) <= 3000 && grepl("limite de 3000 octets", x[length(x)]) })

fin_fichier()
