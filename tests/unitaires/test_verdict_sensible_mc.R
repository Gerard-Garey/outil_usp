###############################################################################
#  tests/unitaires/test_verdict_sensible_mc.R  --  VERDICT MONTE-CARLO PROCHE
#                                                  D'UN SEUIL (ISSUE #244)
#
#  Specification commune d'E2b (docs/specifications/e2b-doctrine-p-monte-carlo.md,
#  section 5, tests U244-1 a U244-8 ; decision D1-5 ; ADR 0003 annote le
#  12/10/2026, point 3) :
#    - constante PHRASE_VERDICT_SENSIBLE_MC, posee par add() seul en dernier
#      element du detail ;
#    - condition : ligne de type test, sans verdict fourni, p retenue
#      Monte-Carlo, err_mc finie et > 0, |p - s| < 2 err_mc (stricte) pour un
#      seuil s de la regle des verdicts : {alpha/2, alpha} en sens "ne pas
#      rejeter", {alpha, SEUIL_ECHEC_SENS_REJETER} en sens "rejeter".
#  U244-9 : seuils atteignables seulement (g_mc NA ou < s). Renvoi de #215
#  pose avant la phrase (constat C1 de l'audit).
#  U244-7 : la regle, recalculee sur les champs des six references, designe
#  exactement les 11 lignes de la specification, qui seules portent la
#  phrase ; l'egalite moteur = references (p, verdicts, detail) est portee par
#  tests/test_reproductibilite.R, et l'absence de toute valeur numerique
#  changee par l'invariant de tests/patcher_reference.R.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_verdict_sensible_mc.R")

.racine244 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."

PH <- PHRASE_VERDICT_SENSIBLE_MC

# Registre fictif (aucune simulation) : une statistique Monte-Carlo "S" de
# p-value p_mc et d'erreur err_mc ; granularite g optionnelle.
ligne244 <- function(p_mc = NA_real_, err_mc = NA_real_, alpha = 0.10, queue = "haut",
                     g = NULL, motif = NULL, mc = TRUE, ...) {
  boot <- list(p_mc = c(S = p_mc), err_mc = c(S = err_mc))
  if (!is.null(g)) boot$granularite_stat <- c(S = g)
  if (!is.null(motif)) boot$motif_mc <- c(S = motif)
  r <- engine_registre_tests(boot, list(S = .mc_entree(function(e) 1, queue)), alpha, "Monte-Carlo")
  if (mc) r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", ...)
  else r$add("F", "t", "ref", fonction = "usp_tests", ...)
  r$lignes()[[1]]
}
porte <- function(l) endsWith(l$detail, PH)
n_phrase <- function(l) lengths(regmatches(l$detail, gregexpr(PH, l$detail, fixed = TRUE)))

## --- U244-8 : la phrase -----------------------------------------------------------
verifier("U244-8 PHRASE_VERDICT_SENSIBLE_MC = texte de l'issue ; seul nombre : la constante 2 (regle #76)",
         identical(PH, paste("verdict sensible a l'alea de simulation",
                             "(p a moins de 2 erreurs de Monte-Carlo du seuil)")) &&
           identical(gsub("[^0-9]", "", PH), "2"))
verifier("U244-8 la phrase posee est identical() a la constante (detail vide)",
         identical(ligne244(0.090, 0.0091)$detail, PH))

## --- U244-1 / U244-2 : sens "ne pas rejeter", seuils alpha et alpha/2 ------------
verifier("U244-1 unilateral a alpha : p = 0,090, err = 0,0091 -> phrase ; p et verdict inchanges",
         {
           l <- ligne244(0.090, 0.0091)
           porte(l) && identical(l$p_retenue, 0.090) && identical(l$verdict, "ALERTE") &&
             identical(l$type, "test") && identical(l$inoperant, FALSE)
         })
verifier("U244-1 unilateral a alpha : p = 0,120, err = 0,0091 -> pas de phrase",
         !grepl(PH, ligne244(0.120, 0.0091)$detail, fixed = TRUE))
verifier("U244-2 a alpha/2 : p = 0,045, err = 0,0066 -> phrase, verdict ECHEC inchange",
         {
           l <- ligne244(0.045, 0.0066)
           porte(l) && identical(l$verdict, "ECHEC") && identical(l$p_retenue, 0.045)
         })
verifier("U244-2 a alpha/2 : p = 0,035, err = 0,0066 -> pas de phrase",
         !grepl(PH, ligne244(0.035, 0.0066)$detail, fixed = TRUE))

## --- U244-3 : bilateral -----------------------------------------------------------
verifier("U244-3 bilateral : p = 0,11, err = sqrt(0,11 x 1,89 / 999) -> phrase, verdict OK inchange",
         {
           l <- ligne244(0.11, sqrt(0.11 * 1.89 / 999), queue = "deux")
           porte(l) && identical(l$verdict, "OK")
         })

## --- U244-4 : sens "rejeter", seuils alpha et SEUIL_ECHEC_SENS_REJETER -----------
verifier("U244-4 sens 'rejeter' : p = 0,105 (pres d'alpha), err = 0,0097 -> phrase, verdict ALERTE",
         {
           l <- ligne244(0.105, 0.0097, sens = "rejeter")
           porte(l) && identical(l$verdict, "ALERTE")
         })
verifier("U244-4 sens 'rejeter' : p = 0,29 (pres de 0,30), err = 0,0143 -> phrase, verdict ALERTE",
         {
           l <- ligne244(0.29, 0.0143, sens = "rejeter")
           porte(l) && identical(l$verdict, "ALERTE")
         })
verifier("U244-4 sens 'rejeter' : p = 0,20, err = 0,0126 -> pas de phrase",
         !grepl(PH, ligne244(0.20, 0.0126, sens = "rejeter")$detail, fixed = TRUE))
verifier("U244-4 sens 'rejeter' : alpha/2 n'est pas un seuil (p = 0,045, err = 0,0066) -> pas de phrase",
         !grepl(PH, ligne244(0.045, 0.0066, sens = "rejeter")$detail, fixed = TRUE))
verifier("U244-4 sens 'ne pas rejeter' : 0,30 n'est pas un seuil (p = 0,29, err = 0,0143) -> pas de phrase",
         !grepl(PH, ligne244(0.29, 0.0143)$detail, fixed = TRUE))

## --- U244-5 : exclusions ------------------------------------------------------------
verifier("U244-5 p exacte retenue (p_ex = p_mc = 0,090) -> pas de phrase",
         {
           l <- ligne244(0.090, 0.0091, p_ex = 0.090)
           identical(l$nature_p, "exacte") && !grepl(PH, l$detail, fixed = TRUE)
         })
verifier("U244-5 diagnostic fourni par l'appelant -> pas de phrase",
         !grepl(PH, ligne244(0.090, 0.0091, type = "diagnostic")$detail, fixed = TRUE))
verifier("U244-5 test inoperant (p_min >= alpha, regle R1) -> pas de phrase",
         {
           l <- ligne244(0.090, 0.0091, p_min = 0.2)
           identical(l$inoperant, TRUE) && !grepl(PH, l$detail, fixed = TRUE)
         })
verifier("U244-5 verdict fourni -> pas de phrase",
         !grepl(PH, ligne244(0.090, 0.0091, verdict = "OK")$detail, fixed = TRUE))
verifier("U244-5 err_mc = 0 ou NA -> pas de phrase",
         !grepl(PH, ligne244(0.090, 0)$detail, fixed = TRUE) &&
           !grepl(PH, ligne244(0.090, NA_real_)$detail, fixed = TRUE))
verifier("U244-5 ligne sans p_mc (p non simulee retenue, sans mc_nom) -> pas de phrase",
         {
           l <- ligne244(mc = FALSE, p_as = 0.090)
           identical(l$p_retenue, 0.090) && !grepl(PH, l$detail, fixed = TRUE)
         })
verifier("U244-5 p Monte-Carlo absente (motif non degenere) -> diagnostic, pas de phrase",
         {
           l <- ligne244(NA_real_, NA_real_, motif = MOTIF_MC_AUCUNE_REPLIC, p_as = 0.090)
           identical(l$type, "diagnostic") && !grepl(PH, l$detail, fixed = TRUE)
         })
verifier("U244-5 non applicable (statistique observee non finie) -> pas de phrase",
         {
           l <- ligne244(NA_real_, NA_real_, motif = MOTIF_MC_OBS_NON_FINIE)
           identical(l$type, "non applicable") && !grepl(PH, l$detail, fixed = TRUE)
         })
verifier("U244-5 p Monte-Carlo externe (p_mc_ext) retenue pres d'alpha -> phrase",
         porte(ligne244(mc = FALSE, p_mc_ext = 0.090, err_mc_ext = 0.0091)))

## --- U244-6 : frontiere stricte ------------------------------------------------------
# Valeurs dyadiques, exactes en virgule flottante : alpha = 0,25, err = 0,125,
# |0,5 - 0,25| = 0,25 = 2 err exactement ; |0,5 - alpha/2| = 0,375.
verifier("U244-6 egalite |p - alpha| = 2 err_mc (valeurs dyadiques exactes) -> pas de phrase",
         {
           stopifnot(abs(0.5 - 0.25) == 2 * 0.125)
           !grepl(PH, ligne244(0.5, 0.125, alpha = 0.25)$detail, fixed = TRUE)
         })
verifier("U244-6 juste sous l'egalite (p = 0,5 - 2^-10) -> phrase",
         porte(ligne244(0.5 - 2^-10, 0.125, alpha = 0.25)))

## --- Placement et jonction -----------------------------------------------------------
verifier("placement : detail termine par un point -> jonction ' ', phrase en dernier, une fois",
         {
           l <- ligne244(0.090, 0.0091, detail = "Texte.")
           identical(l$detail, paste("Texte.", PH)) && n_phrase(l) == 1L
         })
verifier("placement : detail sans point final -> jonction ' ; '",
         identical(ligne244(0.090, 0.0091, detail = "Texte")$detail, paste0("Texte ; ", PH)))
verifier("placement : apres la mention du plancher Monte-Carlo (#128, point d)",
         identical(ligne244(0.090, 0.0091, g = 0.06, detail = "Texte.")$detail,
                   paste0("Texte. plancher Monte-Carlo >= alpha/2 = 0.05 : ECHEC inatteignable ; ", PH)))

## --- U244-9 : seuils atteignables seulement (precision d'actuary) ---------------
# Plancher g_mc (granularite_stat) >= alpha/2 : alpha/2 inatteignable, ne compte
# pas. p = 0,06 a 1,25 err de alpha/2 = 0,05, a 5 err de alpha = 0,10.
verifier("U244-9 g_mc = 0,06 >= alpha/2 : p a moins de 2 err de alpha/2, a plus de 2 err d'alpha -> pas de phrase",
         {
           l <- ligne244(0.06, 0.008, g = 0.06)
           identical(l$type, "test") && identical(l$verdict, "ALERTE") &&
             !grepl(PH, l$detail, fixed = TRUE)
         })
verifier("U244-9 temoin : g_mc = 0,04 < alpha/2 -> alpha/2 compte, phrase",
         porte(ligne244(0.06, 0.008, g = 0.04)))
verifier("U244-9 sens 'rejeter' : g_mc = 0,12 >= alpha -> alpha ne compte pas ; 0,30 compte",
         !grepl(PH, ligne244(0.125, 0.008, g = 0.12, sens = "rejeter")$detail, fixed = TRUE) &&
           porte(ligne244(0.29, 0.008, g = 0.12, sens = "rejeter")))
verifier("U244-9 p_mc_ext (g_mc NA) : tous les seuils comptent (p = 0,045 pres d'alpha/2)",
         porte(ligne244(mc = FALSE, p_mc_ext = 0.045, err_mc_ext = 0.0066)))

## --- Renvoi de #215 avant la phrase (constat C1 de l'audit de #244) ---------------
# Scenario de l'audit : donnees du cas premium, yt + 100 (constante non nulle,
# pi_t constant) ; la ligne constante porte le renvoi de #215 et la phrase.
o244 <- new.env(parent = globalenv())
sys.source(file.path(.racine244, "tests", "outils_tests.R"), envir = o244)
r215 <- suppressWarnings(run_engine(xt = o244$.ln$xt, yt = o244$.ln$yt + 100, methode = "premium",
                                    segment = 1, annexe = "II", nature_donnees = "brutes"))
cst244 <- Filter(function(l) identical(l$test, "Nullite de la constante (proportionnalite stricte)") &&
                   identical(l$variante, "principale"), r215$tests)[[1]]
verifier("Renvoi #215 : ligne constante (yt + 100) -> renvoi present, phrase de #244 en dernier, une fois",
         endsWith(cst244$detail, PH) && n_phrase(cst244) == 1L &&
           endsWith(cst244$detail, paste(USP_TXT_RENVOI_CST, PH)) &&
           lengths(regmatches(cst244$detail, gregexpr(USP_TXT_RENVOI_CST, cst244$detail, fixed = TRUE))) == 1L)
verifier("Renvoi #215 : .usp_poser_renvois() idempotent avec la phrase de #244",
         identical(.usp_poser_renvois(r215$tests), r215$tests))

## --- U244-7 : six references ----------------------------------------------------------
# Les 11 lignes de la specification (section 5, mesure M1), par cas : indice
# de la ligne dans res$tests et nom du test.
ATTENDU244 <- list(
  premium = c(`12` = "Heteroscedasticite vs volume - Breusch-Pagan original (non robuste)",
              `15` = "Homogeneite des dispersions (mediane)"),
  premium_ii6 = NULL, premium_net = NULL, reserve1 = NULL,
  premium_interieur = c(`37` = "Valeur aberrante isolee (Grubbs)"),
  reserve2 = c(`2` = "Nullite de l'ordonnee a l'origine, colonne par colonne",
               `6` = "Heteroscedasticite residuelle vs cumul"))
for (cas in c("premium_ii6", "premium_net", "reserve1")) ATTENDU244[cas] <- list(ATTENDU244$premium)
regle244 <- function(l, alpha) {
  if (!identical(l$type, "test") || is.finite(l$p_exacte) || !is.finite(l$p_mc) ||
      !is.finite(l$err_mc) || l$err_mc <= 0) return(FALSE)
  s <- if (identical(l$sens, "rejeter")) c(alpha, SEUIL_ECHEC_SENS_REJETER) else c(alpha / 2, alpha)
  any(abs(l$p_mc - s) < 2 * l$err_mc)
}
n244 <- 0L
for (cas in names(ATTENDU244)) local({
  ref <- readRDS(file.path(.racine244, "tests", "reference", paste0(cas, ".rds")))
  att <- ATTENDU244[[cas]]
  idx_ph <- which(vapply(ref$tests, function(l) grepl(PH, l$detail, fixed = TRUE), logical(1)))
  idx_rg <- which(vapply(ref$tests, regle244, logical(1), alpha = ref$metadata$alpha))
  verifier(sprintf("U244-7 %s : phrase sur les seules lignes %s, en dernier, une fois", cas,
                   paste(names(att), collapse = ", ")),
           identical(as.character(idx_ph), names(att)) &&
             identical(vapply(ref$tests[idx_ph], `[[`, "", "test"), unname(att)) &&
             all(vapply(ref$tests[idx_ph], function(l) porte(l) && n_phrase(l) == 1L, logical(1))))
  verifier(sprintf("U244-7 %s : la regle recalculee sur les champs designe les memes lignes", cas),
           identical(idx_rg, idx_ph))
  n244 <<- n244 + length(idx_ph)
})
verifier("U244-7 six cas : 11 lignes marquees au total", n244 == 11L)

bilan_fichier()
