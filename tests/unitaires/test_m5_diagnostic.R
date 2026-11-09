###############################################################################
#  tests/unitaires/test_m5_diagnostic.R  --  LIGNES M5 DE MERZ-WUTHRICH EN
#                                            DIAGNOSTIC (ISSUE #245)
#
#  Specification d'E2e (docs/specifications/e2e-niveaux-et-documentation.md,
#  section 2, tests T245-1 a T245-4 ; decisions D1-1 (a) et D1-2 (A) du
#  mainteneur, 13/10/2026) :
#    - T245-1 : les deux lignes M5 sont de type "diagnostic", verdict INFO,
#      sens, p_retenue et nature_p a NA, inoperant FALSE ;
#    - T245-2 : Shapiro-Wilk, p en colonne p_asymptotique (et non plus
#      p_exacte), identique a sw_p_loi_nulle(W, n) ;
#    - T245-3 : Lilliefors, p_asymptotique = lillie_p(D, n) ;
#    - T245-4 : detail des deux lignes = phrases fixes du point 4, sans aucun
#      nombre (regle #76) hors du renvoi "D(2)(h)".
#  T245-5 : U120-1 reecrit (test_nature_p_non_simulee.R) ; T245-6 : mesure de
#  .MW_LIGNES_RESIDUS (test_merz_wuthrich.R), inchangee ; T245-7 : registre
#  de concordance (test_concordance_doc_moteur.R).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_m5_diagnostic.R")

.racine245 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."

# Triangle du cas reserve2 (outils_tests.R) a B = B_MIN_USAGE : les lignes M5
# n'ont pas de mc_nom, leurs valeurs ne dependent pas du bootstrap.
outils245 <- new.env(parent = globalenv())
sys.source(file.path(.racine245, "tests", "outils_tests.R"), envir = outils245)
res245 <- suppressWarnings(run_engine(methode = "reserve2", triangle = outils245$.tri,
                                      segment = 1, annexe = "II", B = B_MIN_USAGE))
ligne245 <- function(nom) Filter(function(l) identical(l$test, nom), res245$tests)
NOM_SW <- "Shapiro-Wilk sur les residus de Mack"
NOM_LI <- "Lilliefors sur les residus de Mack"
sw245 <- ligne245(NOM_SW); li245 <- ligne245(NOM_LI)
n245 <- length(mw_residus(mw_ajuster(outils245$.tri))$residu)

verifier("T245-1 reserve2 : une ligne M5 Shapiro-Wilk et une ligne M5 Lilliefors",
         isTRUE(res245$ok) && length(sw245) == 1L && length(li245) == 1L &&
           startsWith(sw245[[1]]$famille, "M5") && startsWith(li245[[1]]$famille, "M5"))
for (l in c(sw245, li245)) local({
  l <- l
  verifier(paste0("T245-1 ", l$test, " : diagnostic, INFO, sens / p_retenue / nature_p NA, inoperant FALSE"),
           identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
             identical(l$sens, NA_character_) && identical(l$p_retenue, NA_real_) &&
             identical(l$nature_p, NA_character_) && identical(l$inoperant, FALSE) &&
             identical(l$p_min_mc, NA_real_) && is.na(l$p_mc))
})

verifier("T245-2 Shapiro-Wilk : p_exacte NA, p_asymptotique = sw_p_loi_nulle(W, n) (identical) = 0,07139643",
         {
           l <- sw245[[1]]
           identical(l$p_exacte, NA_real_) &&
             identical(l$p_asymptotique, sw_p_loi_nulle(l$stat, n245)) &&
             isTRUE(proche(l$p_asymptotique, 0.07139643, rel = 1e-7)) &&
             identical(l$fonction, ".shapiro_sur") &&
             identical(l$loi, paste("loi de W sous echantillon i.i.d. normal (simulation directe),",
                                    "non sous le modele de Mack"))
         })
verifier("T245-3 Lilliefors : p_asymptotique = lillie_p(D, n) = 0,4569697 ; variante secondaire",
         {
           l <- li245[[1]]
           identical(l$p_exacte, NA_real_) &&
             identical(l$p_asymptotique, lillie_p(l$stat, n245)) &&
             identical(l$stat, stat_lilliefors(mw_residus(mw_ajuster(outils245$.tri))$residu)) &&
             isTRUE(proche(l$p_asymptotique, 0.4569697, rel = 1e-7)) &&
             identical(l$variante, "secondaire") && identical(l$fonction, "stat_lilliefors") &&
             identical(l$loi, paste("loi de Lilliefors sous echantillon i.i.d. normal (parametres estimes),",
                                    "non sous le modele de Mack"))
         })

# Textes de #514 (specification finale d'actuary, M5 : usage, lignes liees).
DETAIL_SW <- paste(
  "Diagnostic sans verdict : la normalite n'est pas exigee par le modele",
  "(D(2)(h) : deux premiers moments), et la loi de W, celle d'un",
  "echantillon i.i.d. normal, rejette trop souvent sur des residus de Mack",
  "(simulation), p-value utile seulement pour un quantile de la MSEP. A",
  "lire avec \"Lilliefors sur les residus de Mack\".")
DETAIL_LI <- paste(
  "Diagnostic sans verdict : approximation de Dallal et Wilkinson etablie",
  "pour un echantillon i.i.d. normal, qui rejette trop souvent sur des",
  "residus de Mack (simulation), p-value pour information. A lire avec",
  "\"Shapiro-Wilk sur les residus de Mack\".")
sans_renvois <- function(x) gsub("D\\(2\\)\\(h\\)", "", x)
verifier("T245-4 Shapiro-Wilk : detail = phrase fixe du point 4, ASCII, sans nombre hors renvois",
         identical(sw245[[1]]$detail, DETAIL_SW) && !grepl("[^ -~]", sw245[[1]]$detail) &&
           !grepl("[0-9]", sans_renvois(sw245[[1]]$detail)))
verifier("T245-4 Lilliefors : detail = phrase fixe du point 4, ASCII, sans nombre hors renvois",
         identical(li245[[1]]$detail, DETAIL_LI) && !grepl("[^ -~]", li245[[1]]$detail) &&
           !grepl("[0-9]", sans_renvois(li245[[1]]$detail)))
# #514 (A3) : texte propre en deux phrases au plus et 400 caracteres au plus.
verifier_detail(res245, "reserve2 a B = B_MIN_USAGE (lignes M5)")

fin_fichier()
