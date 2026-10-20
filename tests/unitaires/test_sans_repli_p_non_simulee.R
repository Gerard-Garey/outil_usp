###############################################################################
#  tests/unitaires/test_sans_repli_p_non_simulee.R  --  SORT DE LA P NON SIMULEE
#                                                       QUAND LA P MONTE-CARLO
#                                                       MANQUE (ISSUE #181)
#
#  Specification commune d'E2b (docs/specifications/e2b-doctrine-p-monte-carlo.md,
#  section 3, tests U181-1 a U181-9 ; decisions D1-1 (B) generalisee et D1-2
#  diagnostic ; ADR 0003 annote le 12/10/2026, point 2) :
#    - une ligne de type test dont la p Monte-Carlo manque pour un motif non
#      degenere, sans p exacte finie, avec une p non simulee finie, devient un
#      diagnostic (INFO, p non simulee conservee dans sa colonne, p_retenue et
#      nature_p NA, inoperant FALSE), detail prefixe "Monte-Carlo indisponible :
#      <motif> ; <libelle_p_as> non retenue (ADR 0001)." ;
#    - plus aucun repli nomme "asymptotique (Monte-Carlo indisponible : ...)".
#  U181-9 (six references identiques) est porte par tests/test_reproductibilite.R.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_sans_repli_p_non_simulee.R")

.racine181 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."

LIB181 <- "p non simulee (loi du champ loi)"
pre181 <- function(motif, lib = LIB181)
  paste0("Monte-Carlo indisponible : ", motif, " ; ", lib, " non retenue (ADR 0001).")

# Registre fictif : une statistique Monte-Carlo "S", p_mc absente pour le
# motif donne.
reg181 <- function(motif) {
  engine_registre_tests(list(p_mc = c(S = NA_real_), err_mc = c(S = NA_real_),
                             motif_mc = c(S = motif)),
                        list(S = .mc_entree(function(e) 1, "haut")), 0.10, "Monte-Carlo")
}
ligne181 <- function(motif, ...) {
  r <- reg181(motif); r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", ...)
  r$lignes()[[1]]
}
est_diag181 <- function(l, motif, p_as, detail_suite = "") {
  identical(l$type, "diagnostic") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
    is.na(l$nature_p) && identical(l$p_asymptotique, p_as) && identical(l$inoperant, FALSE) &&
    is.na(l$sens) && identical(l$detail, trimws(paste(pre181(motif), detail_suite)))
}

## --- U181-1 / U181-2 : motifs non degeneres ------------------------------------
verifier("U181-1 add() : MOTIF_MC_REPLIC_INSUFFISANTES, p_as = 0,03 -> diagnostic INFO, p conservee non retenue",
         {
           l <- ligne181(MOTIF_MC_REPLIC_INSUFFISANTES, p_as = 0.03)
           est_diag181(l, MOTIF_MC_REPLIC_INSUFFISANTES, 0.03) &&
             startsWith(l$detail, paste("Monte-Carlo indisponible : replications finies insuffisantes",
                                        "(B_effectif < B_MIN_DEGENERESCENCE = 50) ; p non simulee",
                                        "(loi du champ loi) non retenue (ADR 0001)."))
         })
verifier("U181-2 add() : MOTIF_MC_AUCUNE_REPLIC, MOTIF_MC_REGIME_RARE, motif de non_definie -> meme diagnostic, detail conserve",
         all(vapply(c(MOTIF_MC_AUCUNE_REPLIC, MOTIF_MC_REGIME_RARE,
                      "statistique observee non definie : ex aequo"), function(m)
           est_diag181(ligne181(m, p_as = 0.03, detail = "d."), m, 0.03, "d."), logical(1))))
verifier("U181-2 add() : sens 'rejeter' et verdict fourni absent -> meme diagnostic (sens NA)",
         est_diag181(ligne181(MOTIF_MC_AUCUNE_REPLIC, p_as = 0.5, sens = "rejeter"),
                     MOTIF_MC_AUCUNE_REPLIC, 0.5))
verifier("U181-2 add() : p_min fournie (alpha/2 <= p_min < alpha) -> diagnostic, R1 sans objet, inoperant FALSE",
         est_diag181(ligne181(MOTIF_MC_REPLIC_INSUFFISANTES, p_as = 0.2, p_min = 4 / 70),
                     MOTIF_MC_REPLIC_INSUFFISANTES, 0.2))
verifier("U181-2 add() : libelle_p_as fourni -> libelle de l'appelant dans le prefixe",
         {
           l <- ligne181(MOTIF_MC_AUCUNE_REPLIC, p_as = 0.2, libelle_p_as = "p de Student")
           identical(l$type, "diagnostic") && is.na(l$p_retenue) &&
             identical(l$detail, pre181(MOTIF_MC_AUCUNE_REPLIC, "p de Student"))
         })

## --- U181-3 / U181-4 : p exacte, aucune p non simulee ----------------------------
verifier("U181-3 add() : p exacte finie -> p exacte retenue, ligne de type test",
         {
           l <- ligne181(MOTIF_MC_REPLIC_INSUFFISANTES, p_ex = 0.2, p_as = 0.03)
           identical(l$type, "test") && identical(l$nature_p, "exacte") && identical(l$p_retenue, 0.2) &&
             identical(l$verdict, "OK") && !grepl("non retenue", l$detail, fixed = TRUE)
         })
verifier("U181-4 add() : p_as NA -> test sans p-value retenue, detail de #128 inchange",
         {
           l <- ligne181(MOTIF_MC_AUCUNE_REPLIC, detail = "d")
           identical(l$type, "test") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             identical(l$sens, "ne pas rejeter") &&
             identical(l$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_AUCUNE_REPLIC,
                                        " ; aucune p-value disponible sur ces donnees : aucun verdict",
                                        " (ADR 0001). d"))
         })

## --- U181-5 : motifs degeneres et observee non finie (regle R3 inchangee) ------
verifier("U181-5 add() : motifs degeneres -> diagnostic au prefixe du motif, sans le prefixe de #181",
         all(vapply(c(MOTIF_MC_DISPERSION_NULLE, MOTIF_MC_ATOME_HORS_OBS, MOTIF_MC_CONDITION), function(m) {
           l <- ligne181(m, p_ex = 0.2, p_as = 0.03)
           identical(l$type, "diagnostic") && is.na(l$p_retenue) &&
             startsWith(l$detail, paste0(m, " : aucune p-value retenue (ADR 0001).")) &&
             !grepl("non retenue (ADR 0001)", l$detail, fixed = TRUE)
         }, logical(1))))
verifier("U181-5 add() : statistique observee non finie, sans p exacte -> non applicable",
         {
           l <- ligne181(MOTIF_MC_OBS_NON_FINIE, p_as = 0.03)
           identical(l$type, "non applicable") && startsWith(l$detail, MOTIF_MC_OBS_NON_FINIE)
         })

## --- U181-6 : J1 et J2 a usp_bootstrap(B = 40) ---------------------------------
# J1 : donnees_ln.csv (delta estime = 1) ; J2 : jeu de test_controles_numeriques.R
# (delta estime = 0,664, V3b). B = 40 < B_MIN_DEGENERESCENCE : toutes les p_mc
# manquent (motif replications insuffisantes). Avant #181 : 19 et 23 lignes en
# repli nomme (specification, section 3, mesure M3) ; 6 et 9 tests sans p-value.
d181 <- utils::read.csv(file.path(.racine181, "tests", "donnees", "donnees_ln.csv"))
xi181 <- c(50, 80, 120, 200, 300, 150, 90, 60)
yi181 <- c(29.92, 56.9, 101.25, 123.06, 207.23, 105.91, 68.59, 40.05)
lignes_j <- function(x, y) {
  f <- usp_ajuster(x, y); usp_tests(f, usp_bootstrap(f, B = 40), methode = "premium")
}
tj <- list(J1 = lignes_j(d181$xt, d181$yt), J2 = lignes_j(xi181, yi181))
# Depuis #303 : Ljung-Box (1) sur ratios bruts retiree (J1 et J2 : un test sans
# p-value de moins) ; a pi_t constant (J1), DWr, supFr, CUSUMr et Grubbsr sont
# des diagnostics de la regle R15 et ne sont plus des tests sans p-value
# (J1 : 6 -> 1, sup-F sur z seul ; J2 : 9 -> 8). Depuis #302 : Ljung-Box (1)
# et Box-Pierce (2) retirees, Kolmogorov-Smirnov contre N(0,1) et
# Cramer-von Mises en diagnostic par decision (motif en tete sous la forme
# "Monte-Carlo indisponible : <motif>.", hors du prefixe de #181) : quatre
# lignes de moins au prefixe de #181 (J1 : 19 -> 15 ; J2 : 23 -> 19).
# Depuis #299 : Breusch-Pagan 1979, White, Goldfeld-Quandt, Brown-Forsythe,
# Smirnov et Spearman ratio / temps en diagnostic par decision (meme forme
# du motif que #302) : J1, quatre lignes de moins au prefixe de #181
# (15 -> 11 ; Smirnov et Spearman-temps y ont une p exacte) ; J2, cinq
# (19 -> 14, Spearman-temps compris), et Smirnov, sans p non simulee,
# n'est plus un test sans p-value (8 -> 7).
attendu <- list(J1 = c(diag = 11L, sans_p = 1L), J2 = c(diag = 14L, sans_p = 7L))
for (j in names(tj)) local({
  tt <- tj[[j]]; a <- attendu[[j]]
  pre <- pre181(MOTIF_MC_REPLIC_INSUFFISANTES)
  dg <- Filter(function(l) startsWith(l$detail, pre), tt)
  sp <- Filter(function(l) identical(l$type, "test") && is.na(l$p_retenue) &&
                 grepl("aucune p-value disponible sur ces donnees", l$detail, fixed = TRUE), tt)
  cst <- Filter(function(l) identical(l$test, "Nullite de la constante (proportionnalite stricte)"), tt)[[1]]
  verifier(sprintf("U181-6 %s (B = 40) : %d lignes en diagnostic au prefixe de #181, p non simulee conservee",
                   j, a[["diag"]]),
           length(dg) == a[["diag"]] &&
             all(vapply(dg, function(l) identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
                          is.na(l$p_retenue) && is.na(l$nature_p) && is.finite(l$p_asymptotique) &&
                          !is.finite(l$p_exacte) && identical(l$inoperant, FALSE), logical(1))))
  verifier(sprintf("U181-6 %s : aucune nature 'asymptotique (Monte-Carlo indisponible' ; %d tests sans p-value",
                   j, a[["sans_p"]]),
           !any(vapply(tt, function(l) is.character(l$nature_p) && !is.na(l$nature_p) &&
                         startsWith(l$nature_p, "asymptotique"), logical(1))) &&
             length(sp) == a[["sans_p"]])
  verifier(sprintf("U181-6 %s : constante en diagnostic, libelle explicite inchange", j),
           identical(cst$type, "diagnostic") && is.na(cst$p_retenue) &&
             startsWith(cst$detail, pre181(MOTIF_MC_REPLIC_INSUFFISANTES,
                                           "p de Student sous le modele auxiliaire pondere")))
})

## --- U181-7 : ta_pert(9e-13), B = 60 (Merz-Wuthrich) ---------------------------
# Taylor & Ashe (test_merz_wuthrich.R), colonne 6 rendue presque degeneree :
# B_eff = 42 sur Origine, HomogF et Courbure, B_eff = B sur les dix autres
# statistiques Monte-Carlo.
ta181 <- matrix(c(357848, 352118, 290507, 310608, 443160, 396132, 440832, 359480, 376686, 344014,
  1124788, 1236139, 1292306, 1418858, 1136350, 1333217, 1288463, 1421128, 1363294, NA,
  1735330, 2170033, 2218525, 2195047, 2128333, 2180715, 2419861, 2864498, NA, NA,
  2218270, 3353322, 3235179, 3757447, 2897821, 2985752, 3483130, NA, NA, NA,
  2745596, 3799067, 3985995, 4029929, 3402672, 3691712, NA, NA, NA, NA,
  3319994, 4120063, 4132918, 4381982, 3873311, NA, NA, NA, NA, NA,
  3466336, 4647867, 4628910, 4588268, NA, NA, NA, NA, NA, NA,
  3606286, 4914039, 4909315, NA, NA, NA, NA, NA, NA, NA,
  3833515, 5339085, NA, NA, NA, NA, NA, NA, NA, NA,
  3901463, NA, NA, NA, NA, NA, NA, NA, NA, NA), 10, 10)
ta181[1:5, 6] <- 1.05 * ta181[1:5, 5]
ta181[1:5, 6] <- ta181[1:5, 6] * (1 + c(1, -1, 1, -1, 1) * 9e-13)
aj181 <- mw_ajuster(ta181); bt181 <- mw_bootstrap(aj181, B = 60)
tm181 <- mw_tests(aj181, bt181)
noms3 <- c("Nullite de l'ordonnee a l'origine, colonne par colonne",
           "Homogeneite de f_j entre annees de survenance",
           "Absence de courbure de la regression")
verifier("U181-7 ta_pert(9e-13), B = 60 : B_eff = 42 sur Origine, HomogF, Courbure, B ailleurs",
         identical(unname(bt181$B_effectif[c("Origine", "HomogF", "Courbure")]), c(42, 42, 42)) &&
           all(bt181$B_effectif[setdiff(names(bt181$B_effectif), c("Origine", "HomogF", "Courbure"))] == 60))
verifier("U181-7 Origine, HomogF, Courbure en diagnostic au prefixe de #181, p non simulee conservee",
         all(vapply(noms3, function(n) {
           l <- Filter(function(l) identical(l$test, n), tm181)[[1]]
           identical(l$type, "diagnostic") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             is.na(l$nature_p) && is.finite(l$p_asymptotique) && identical(l$inoperant, FALSE) &&
             startsWith(l$detail, pre181(MOTIF_MC_REPLIC_INSUFFISANTES))
         }, logical(1))))
verifier("U181-7 les dix autres lignes Monte-Carlo gardent leur p Monte-Carlo retenue",
         {
           mc <- Filter(function(l) is.finite(l$p_mc), tm181)
           length(mc) == 10L &&
             all(vapply(mc, function(l) identical(l$type, "test") && identical(l$p_retenue, l$p_mc) &&
                          identical(l$nature_p, "Monte-Carlo (bootstrap de residus)"), logical(1)))
         })

## --- U181-8 : retrait de l'argument repli_asymptotique ---------------------------
verifier("U181-8 R/engine.R : plus de repli_asymptotique, de motif_non_mc ni de texte de repli de R1",
         {
           src <- readLines(file.path(.racine181, "R", "engine.R"), warn = FALSE)
           !any(grepl("repli_asymptotique", src, fixed = TRUE)) &&
             !any(grepl("motif_non_mc", src, fixed = TRUE)) &&
             !any(grepl("p-value asymptotique retenue, calculee hors de cette loi", src, fixed = TRUE)) &&
             !"repli_asymptotique" %in% names(formals(engine_registre_tests(
               list(p_mc = numeric(0), err_mc = numeric(0)), list(), 0.10, "MC")$add))
         })

fin_fichier()
