###############################################################################
#  tests/unitaires/test_nature_p_non_simulee.R  --  NATURE D'UNE P NON SIMULEE
#                                                   QUI N'EST PAS ASYMPTOTIQUE
#                                                   (ISSUE #120)
#
#  Specification commune d'E2b (docs/specifications/e2b-doctrine-p-monte-carlo.md,
#  section 2, tests U120-1 a U120-7 ; decision D1-3 ; ADR 0003 annote le
#  12/10/2026, point 1) :
#    - constante NATURE_APPROX_N_FINI et argument nature_as d'add() ;
#    - nature de la ligne "Aplatissement (Anscombe-Glynn, T >= 20)"
#      (usp_tests()) ; la ligne "Lilliefors sur les residus de Mack"
#      (mw_tests()), diagnostic depuis #245, n'a plus de nature_p (U120-1,
#      reecrit : T245-5) ;
#    - badge "approx. n fini" de badge_nature() (display_helpers.R).
#  U120-7 (aucune valeur numerique changee sur les six cas) est porte par
#  tests/test_reproductibilite.R (comparaison aux references, dont celle de
#  reserve2 patchee sur la seule chaine nature_p) et par l'invariant de
#  tests/patcher_reference.R, qui refuse toute valeur numerique.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_nature_p_non_simulee.R")

.racine120 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."

# Registre fictif (aucune simulation) : une statistique Monte-Carlo "A".
reg120 <- function(p_mc = 0.5) {
  engine_registre_tests(list(p_mc = c(A = p_mc), err_mc = c(A = 0.01)),
                        list(A = .mc_entree(function(e) 1, "haut")), 0.10, "Monte-Carlo")
}
nature120 <- function(...) {
  r <- reg120(); r$add("F", "t", "ref", fonction = "usp_tests", ...)
  r$lignes()[[1]]$nature_p
}

## --- U120-2 / U120-3 : argument nature_as d'add() ------------------------------
verifier("NATURE_APPROX_N_FINI : libelle ASCII de la decision D1-3",
         identical(NATURE_APPROX_N_FINI, "approximation a n fini sous i.i.d. normal"))
verifier("U120-2 add() : p_as seule, sans mc_nom -> 'asymptotique' par defaut",
         identical(nature120(p_as = 0.3), "asymptotique"))
verifier("U120-2 add() : p_as seule, nature_as = NATURE_APPROX_N_FINI -> cette nature, p et verdict inchanges",
         {
           r <- reg120(); r$add("F", "t", "ref", fonction = "usp_tests", p_as = 0.3,
                                nature_as = NATURE_APPROX_N_FINI)
           l <- r$lignes()[[1]]
           identical(l$nature_p, NATURE_APPROX_N_FINI) && identical(l$p_retenue, 0.3) &&
             identical(l$verdict, "OK") && identical(l$type, "test")
         })
verifier("U120-3 add() : nature_as = 'approchee' -> erreur 'nature_as inconnue'",
         {
           m <- tryCatch({ nature120(p_as = 0.3, nature_as = "approchee"); "" },
                         error = function(e) conditionMessage(e))
           grepl("^add\\(\\) : nature_as inconnue : approchee", m)
         })
verifier("U120-3 add() : nature_as NA, vide, de longueur 2 ou non chaine -> erreur",
         leve_erreur(nature120(p_as = 0.3, nature_as = NA_character_)) &&
           leve_erreur(nature120(p_as = 0.3, nature_as = "")) &&
           leve_erreur(nature120(p_as = 0.3, nature_as = c("asymptotique", NATURE_APPROX_N_FINI))) &&
           leve_erreur(nature120(p_as = 0.3, nature_as = 1)))
verifier("U120-3 add() : nature_as controle meme sans p non simulee",
         leve_erreur(nature120(p_ex = 0.3, nature_as = "approchee")))

## --- U120-4 : la hierarchie prime ----------------------------------------------
verifier("U120-4 add() : p exacte finie -> 'exacte', quel que soit nature_as",
         identical(nature120(p_ex = 0.2, p_as = 0.3, nature_as = NATURE_APPROX_N_FINI), "exacte") &&
           identical(nature120(p_ex = 0.2, p_as = 0.3), "exacte"))
verifier("U120-4 add() : p Monte-Carlo finie (mc_nom) -> nature Monte-Carlo, quel que soit nature_as",
         identical(nature120(mc_nom = "A", p_as = 0.3, nature_as = NATURE_APPROX_N_FINI), "Monte-Carlo") &&
           identical(nature120(mc_nom = "A", p_as = 0.3), "Monte-Carlo"))
verifier("U120-4 add() : p Monte-Carlo externe (p_mc_ext) -> nature Monte-Carlo, quel que soit nature_as",
         identical(nature120(p_mc_ext = 0.4, err_mc_ext = 0.01, p_as = 0.3,
                             nature_as = NATURE_APPROX_N_FINI), "Monte-Carlo"))

## --- U120-1 : M5 Lilliefors de reserve2 (reecrit par #245, T245-5) ------------
# Triangle du cas reserve2 (outils_tests.R) a B = B_MIN_USAGE : la p de
# Lilliefors (lillie_p() sur les residus de Mack) ne depend pas du bootstrap ;
# elle est comparee a la reference a la tolerance de non-regression. Depuis
# #245 (decision D1-1 (a)), la ligne est un diagnostic : add() pose nature_p
# a NA ; NATURE_APPROX_N_FINI n'est plus portee que par Anscombe-Glynn a
# T >= 20 (U120-5).
outils120 <- new.env(parent = globalenv())
sys.source(file.path(.racine120, "tests", "outils_tests.R"), envir = outils120)
res120 <- suppressWarnings(run_engine(methode = "reserve2", triangle = outils120$.tri,
                                      segment = 1, annexe = "II", B = B_MIN_USAGE))
ref120 <- readRDS(file.path(.racine120, "tests", "reference", "reserve2.rds"))
lil <- function(res) Filter(function(l) identical(l$test, "Lilliefors sur les residus de Mack"),
                            res$tests)[[1]]
verifier("U120-1 reserve2 : 'Lilliefors sur les residus de Mack' diagnostic, nature_p et p_retenue NA (#245)",
         identical(lil(res120)$type, "diagnostic") && identical(lil(res120)$nature_p, NA_character_) &&
           identical(lil(res120)$p_retenue, NA_real_) && identical(lil(res120)$verdict, "INFO"))
verifier("U120-1 reserve2 : p_asymptotique de Lilliefors identique a la reference",
         isTRUE(proche(lil(res120)$p_asymptotique, lil(ref120)$p_asymptotique,
                       rel = outils120$TOLERANCE)))
verifier("U120-1 reserve2 : aucune ligne ne porte NATURE_APPROX_N_FINI ni 'asymptotique'",
         {
           n <- vapply(res120$tests, function(l) if (is.na(l$nature_p)) "" else l$nature_p, character(1))
           !any(n == NATURE_APPROX_N_FINI) && !any(startsWith(n, "asymptotique"))
         })

## --- U120-5 : Anscombe-Glynn a T = 20 -------------------------------------------
# Jeu synthetique (tirage unique, valeurs ecrites en dur) : T = 20, la ligne
# Anscombe-Glynn est un test, sans mc_nom ; sa p non simulee est retenue.
x120 <- c(98.87, 101.8, 99.61, 110.06, 114.15, 111.77, 116.84, 123.69, 129.87, 130.49,
          143.58, 149.36, 147.72, 134.9, 145.59, 148.2, 151.07, 161.57, 171.74, 180.49)
y120 <- c(75.87, 77.06, 70.25, 63.14, 85.01, 77.8, 80.52, 74.74, 86.66, 95.24,
          115.13, 103.48, 107.49, 93.92, 88.8, 99.52, 101.66, 112.43, 134.2, 136.36)
r20 <- suppressWarnings(run_engine(xt = x120, yt = y120, methode = "premium", segment = 1,
                                   B = 99, nature_donnees = "brutes"))
verifier("U120-5 Anscombe-Glynn a T = 20 : p retenue = p non simulee, nature NATURE_APPROX_N_FINI",
         {
           l <- Filter(function(l) identical(l$test, "Aplatissement (Anscombe-Glynn, T >= 20)"),
                       r20$tests)[[1]]
           isTRUE(r20$ok) && identical(l$type, "test") && is.finite(l$p_retenue) &&
             identical(l$p_retenue, l$p_asymptotique) && identical(l$nature_p, NATURE_APPROX_N_FINI)
         })
verifier("U120-5 premium a T = 20 : seule la ligne Anscombe-Glynn porte NATURE_APPROX_N_FINI",
         {
           n <- vapply(r20$tests, function(l) if (is.na(l$nature_p)) "" else l$nature_p, character(1))
           t <- vapply(r20$tests, function(l) l$test, character(1))
           identical(t[n == NATURE_APPROX_N_FINI], "Aplatissement (Anscombe-Glynn, T >= 20)")
         })

## --- U120-6 : badge de badge_nature() ------------------------------------------
env120 <- new.env(parent = globalenv())
sys.source(file.path(.racine120, "R", "display_helpers.R"), envir = env120)
verifier("U120-6 badge_nature() : NATURE_APPROX_N_FINI -> 'approx. n fini', distinct du badge 'asymptotique'",
         {
           b <- env120$badge_nature(NATURE_APPROX_N_FINI)
           b_as <- env120$badge_nature("asymptotique")
           grepl(">approx. n fini<", b, fixed = TRUE) && b != b_as &&
             !grepl("#B9770E", b, fixed = TRUE)
         })

bilan_fichier()
