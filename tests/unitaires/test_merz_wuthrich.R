###############################################################################
#  tests/unitaires/test_merz_wuthrich.R  --  METHODE DU RISQUE DE RESERVE No 2
#
#  mw_ajuster(), mw_msep(), mw_residus() : annexe XVII, section D.
#  Par. 4 : identique dans la version d'origine (JOUE L 12/277) et dans la
#  version consolidee au 14.11.2024. Par. 5 : VERSION CONSOLIDEE en vigueur
#  (ADR 0005) ; dans la version d'origine, le par. 5 couvre le JOUE
#  L 12/277-278 (pagination verifiee le 22/09/2026, issue #26) et sa formule
#  differe de celle appliquee.
#  References :
#    - triangle 5 x 5 calculable a la main (facteurs en fractions exactes,
#      sigma_j^2 par une identite algebrique distincte de la formule codee) ;
#    - triangle de Taylor & Ashe (1983), publie, et valeurs de ChainLadder
#      0.2.18 (MackChainLadder, CDR) ecrites en dur (generer_valeurs_externes.R) ;
#    - transcription litterale du par. D(5), ecrite ici independamment.
#
#  Fichier coupe en deux (issue #512) : les sections a partir de "Colonnes
#  degenerees exclues des residus de Mack (issue #60)" (dont #115, p_min des
#  lignes a loi discrete et regle R1) sont dans test_merz_wuthrich_suite.R.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_merz_wuthrich.R")

## --- Triangle 5 x 5 calcule a la main ---------------------------------------
tri <- matrix(NA_real_, 5, 5)
tri[1, ] <- c(100, 150, 180, 190, 195)
tri[2, 1:4] <- c(110, 160, 190, 200)
tri[3, 1:3] <- c(120, 185, 220)
tri[4, 1:2] <- c(130, 200)
tri[5, 1] <- 140
aj <- mw_ajuster(tri)
f_main <- c(695 / 460, 590 / 495, 390 / 370, 195 / 190)
verifier("f_j chain-ladder (par. 4(c)) = fractions calculees a la main",
         proche(aj$f, f_main, rel = 1e-14))
verifier("f_j = estimateur de la regression ponderee sans constante, poids 1/C (Mack 1993)",
         {
           fl <- vapply(0:3, function(j) {
             i <- 1:(4 - j); C0 <- tri[i, j + 1]; C1 <- tri[i, j + 2]
             unname(stats::coef(stats::lm(C1 ~ C0 - 1, weights = 1 / C0)))
           }, numeric(1))
           isTRUE(proche(aj$f, fl, rel = 1e-12))
         })
# sigma_j^2 = (somme C(i,j+1)^2 / C(i,j) - f_j somme C(i,j+1)) / (I - j - 1) :
# identite algebrique equivalente a la formule du par. 5(d)(ii) (soustraction
# de termes proches : tolerance relative 1e-8).
s2_main <- vapply(0:2, function(j) {
  i <- 1:(4 - j); C0 <- tri[i, j + 1]; C1 <- tri[i, j + 2]
  (sum(C1^2 / C0) - f_main[j + 1] * sum(C1)) / (4 - j - 1)
}, numeric(1))
verifier("sigma_j^2, j = 0..J-2 (par. 5(d)(ii)) = identite algebrique",
         proche(aj$sigma2[1:3], s2_main, rel = 1e-8))
verifier("sigma_(J-1)^2 = min(s2_(J-2), s2_(J-3), s2_(J-2)^2 / s2_(J-3))",
         proche(aj$sigma2[4], min(s2_main[3], s2_main[2], s2_main[3]^2 / s2_main[2]), rel = 1e-8))
res_main <- c(0,
              200 * f_main[4] - 200,
              220 * prod(f_main[3:4]) - 220,
              200 * prod(f_main[2:4]) - 200,
              140 * prod(f_main) - 140)
verifier("Reserve par annee d'accident et totale (par. 4) = calcul a la main",
         isTRUE(proche(aj$reserve_par_annee, res_main, rel = 1e-12, abs = 1e-12)) &&
         isTRUE(proche(aj$reserve, sum(res_main), rel = 1e-12)))
verifier("S_j et S'_j (par. 5(b), (c)) = sommes a la main",
         isTRUE(proche(aj$S[1:4], c(460, 495, 370, 190))) && is.na(aj$S[5]) &&
         isTRUE(proche(aj$Sp, c(600, 695, 590, 390, 195))))
verifier("Q_j = sigma_j^2 / f_j^2 (par. 5(d))", proche(aj$Q, aj$sigma2 / f_main^2, rel = 1e-14))
verifier("MSEP, premier terme : somme_i C^(i,J)^2 Q_(I-i) / C(i,I-i) = calcul a la main",
         {
           Cu <- tri[, 1] * 0; Cu[1] <- 195
           Cu[2:5] <- res_main[2:5] + c(200, 220, 200, 140)
           t1 <- sum(vapply(1:4, function(i) Cu[i + 1]^2 * aj$Q[4 - i + 1] / c(195, 200, 220, 200, 140)[i + 1],
                            numeric(1)))
           isTRUE(proche(mw_msep(aj)$terme_variance, t1, rel = 1e-12))
         })
verifier("Residus de Mack : r = sqrt(C) (F - f_j) / sigma_j, 4 + 3 + 2 cellules (j = 3 ecartee : une seule cellule)",
         {
           r <- mw_residus(aj)
           c00 <- sqrt(100) * (150 / 100 - f_main[1]) / sqrt(s2_main[1])
           nrow(r) == 9 && isTRUE(proche(r$residu[r$i == 0 & r$j == 0], c00, rel = 1e-12))
         })

## --- Proprietes de la MSEP ---------------------------------------------------
verifier("Triangle deterministe (F(i,j) = f_j exactement) : sigma^2 = 0 et MSEP = 0",
         {
           td <- matrix(NA_real_, 5, 5); fj <- c(1.5, 1.2, 1.1, 1.05)
           for (i in 1:5) { td[i, 1] <- 100 + 10 * i
             if (i <= 4) for (j in 2:(6 - i)) td[i, j] <- td[i, j - 1] * fj[j - 1] }
           a <- mw_ajuster(td)
           isTRUE(proche(a$f, fj, rel = 1e-13)) && all(abs(a$sigma2) < 1e-10) &&
             abs(mw_msep(a)$msep) < 1e-10
         })
verifier("Homogeneite : C -> lambda C multiplie MSEP par lambda^2 et reserve par lambda",
         {
           a2 <- mw_ajuster(1000 * tri)
           isTRUE(proche(mw_msep(a2)$msep, 1000^2 * mw_msep(aj)$msep, rel = 1e-10)) &&
             isTRUE(proche(a2$reserve, 1000 * aj$reserve, rel = 1e-12))
         })
verifier("MSEP et ses deux termes positifs ou nuls",
         {
           m <- mw_msep(aj)
           m$terme_variance >= 0 && m$terme_estimation >= 0 &&
             isTRUE(proche(m$msep, m$terme_variance + m$terme_estimation))
         })
# Scenario du constat sur les reserves negatives (voir test_calibration.R).
tri_decroissant <- matrix(NA_real_, 5, 5)
tri_decroissant[1, ] <- c(100, 95, 92, 90, 89); tri_decroissant[2, 1:4] <- c(110, 104, 100, 99)
tri_decroissant[3, 1:3] <- c(120, 115, 110); tri_decroissant[4, 1:2] <- c(130, 122)
tri_decroissant[5, 1] <- 140
verifier("Triangle a cumuls decroissants : reserve chain-ladder negative (-27,566619)",
         {
           a <- mw_ajuster(tri_decroissant)
           isTRUE(mw_valider_triangle(tri_decroissant)$ok) &&
             isTRUE(proche(a$reserve, -27.56661936, rel = 1e-8))
         })

## --- Applicabilite de la methode : reserve totale et MSEP (decision M4) ------
# sigma(res,s,USP) = c * racine(MSEP)/R + (1-c) * sigma(res,s) est un
# coefficient de variation : il n'est defini que pour R > 0. run_engine() doit
# refuser (ok = FALSE, validation) sans lever d'erreur, et non produire
# silencieusement un sigma_USP. Voir l'issue #7.
verifier("run_engine : reserve totale negative refusee (ok = FALSE, motif chiffre)",
         {
           r <- run_engine(methode = "reserve2", triangle = tri_decroissant,
                           segment = 1, annexe = "II", B = 99)
           identical(r$ok, FALSE) && !r$validation$ok &&
             any(grepl("-27.5666", r$validation$erreurs, fixed = TRUE)) &&
             any(grepl("n'est pas applicable", r$validation$erreurs, fixed = TRUE)) &&
             is.null(r$parametre_final)
         })
verifier("run_engine : reserve totale exactement nulle refusee (tous les f_j = 1)",
         {
           tz <- matrix(NA_real_, 5, 5)
           for (i in 1:5) for (j in 1:(6 - i)) tz[i, j] <- 100 + 10 * i
           a <- mw_ajuster(tz)
           r <- run_engine(methode = "reserve2", triangle = tz,
                           segment = 1, annexe = "II", B = 99)
           a$reserve == 0 && all(abs(a$f - 1) < 1e-14) &&
             identical(r$ok, FALSE) &&
             any(grepl("R = 0", r$validation$erreurs, fixed = TRUE)) &&
             is.null(r$parametre_final)
         })
# Des reserves negatives sur certaines annees de survenance (bonis de
# liquidation, recours) avec un total positif sont licites : le calcul se
# poursuit, un f_j < 1 isole ne vaut qu'avertissement.
verifier("run_engine : reserves negatives par annee mais total positif -> calcul mene a terme",
         {
           tp <- matrix(NA_real_, 5, 5)
           tp[1, ] <- c(100, 150, 180, 190, 189); tp[2, 1:4] <- c(110, 160, 190, 199)
           tp[3, 1:3] <- c(120, 185, 219); tp[4, 1:2] <- c(130, 200); tp[5, 1] <- 140
           a <- mw_ajuster(tp)
           r <- run_engine(methode = "reserve2", triangle = tp,
                           segment = 1, annexe = "II", B = 99)
           any(a$reserve_par_annee < 0) && any(a$f < 1) && a$reserve > 0 &&
             isTRUE(r$ok) && is.finite(r$parametre_final$sigma_usp) &&
             r$parametre_final$sigma_usp > 0 &&
             isTRUE(proche(r$parametre_final$sigma_estime,
                           sqrt(mw_msep(a)$msep) / a$reserve, rel = 1e-12)) &&
             any(grepl("cumul decroissant", r$validation$avertissements, fixed = TRUE))
         })

## --- Extrapolation de sigma2_(J-1) quand un argument du minimum est nul -----
# Par. 5(d)(ii), seconde ligne : sigma2_(J-1) = min(sigma2_(J-2), sigma2_(J-3),
# sigma2_(J-2)^2/sigma2_(J-3)). Les trois arguments sont positifs ou nuls
# (sommes de carres ponderees par des C(i,j) > 0, quotient de telles
# quantites) : des qu'un argument est nul, le minimum vaut 0, et
# l'indetermination arithmetique du quotient est sans effet. Aucune clause de
# cas degenere ne figure a l'annexe XVII (a contrario, l'annexe XVIII prevoit
# explicitement "d1 = 1 lorsque SS ou SC est egal a zero"). Voir l'issue #7.
#
# Triangle degenere : colonne J-3 = 2 a facteurs individuels tous egaux a 1,
# puis reprise du mouvement (f_3 et f_4 differents de 1). Il passe
# mw_valider_triangle() sans reserve autre que celle liee a I + 1 = 6.
tri_deg <- matrix(NA_real_, 6, 6)
tri_deg[1, ] <- c(1000, 1600, 1800, 1800, 1830, 1835)
tri_deg[2, 1:5] <- c(1100, 1815, 2000, 2000, 2050)
tri_deg[3, 1:4] <- c(900, 1395, 1580, 1580)
tri_deg[4, 1:3] <- c(1200, 1980, 2210)
tri_deg[5, 1:2] <- c(1050, 1638)
tri_deg[6, 1]   <- 980
verifier("sigma2_(J-3) = 0 : sigma2_(J-1) = 0 par la lettre du par. 5(d)(ii)",
         {
           a <- mw_ajuster(tri_deg)
           isTRUE(mw_valider_triangle(tri_deg)$ok) &&
             a$sigma2[a$J - 2] == 0 && a$sigma2[a$J - 1] > 0 &&
             a$sigma2[a$J] == 0
         })
verifier("Colonne J-3 degeneree : detection par les facteurs, arguments du minimum restitues",
         {
           ex <- mw_extrapolation_sigma2(mw_ajuster(tri_deg))
           isTRUE(ex$degeneree) && ex$colonne == 2 && ex$nb_facteurs == 3 &&
             ex$ecart_relatif <= 1e-15 && is.na(ex$quotient) &&
             identical(ex$retenu, "sigma2_(J-3)") && ex$valeur == 0 &&
             isTRUE(proche(ex$sigma2_Jm2, 0.0657894736842, rel = 1e-10)) &&
             identical(ex$developpement_acheve, FALSE)
         })
verifier("run_engine : colonne J-3 degeneree signalee dans validation$avertissements",
         {
           r <- run_engine(methode = "reserve2", triangle = tri_deg,
                           segment = 1, annexe = "II", B = 99)
           av <- r$validation$avertissements
           isTRUE(r$ok) &&
             any(grepl("sigma2_(J-3) = 0", av, fixed = TRUE)) &&
             any(grepl("application litterale", av, fixed = TRUE)) &&
             any(grepl("AUCUNE variance sur la derniere annee de developpement",
                       av, fixed = TRUE)) &&
             any(grepl("Verifier l'origine des donnees", av, fixed = TRUE)) &&
             any(grepl("n'est pourtant PAS acheve", av, fixed = TRUE))
         })
verifier("Diagnostic M6 : les trois arguments du minimum et celui qui est retenu sont affiches",
         {
           r <- run_engine(methode = "reserve2", triangle = tri_deg,
                           segment = 1, annexe = "II", B = 99)
           d <- engine_table_tests(r)
           l <- d$commentaire[grepl("Extrapolation de sigma", d$test)]
           length(l) == 1 &&
             grepl("sigma2_(J-2) = 0.0657895", l, fixed = TRUE) &&
             grepl("sigma2_(J-3) = 0,", l, fixed = TRUE) &&
             grepl("atteint par sigma2_(J-3)", l, fixed = TRUE)
         })
# Cas symetrique : sigma2_(J-2) = 0 avec sigma2_(J-3) > 0. Le quotient vaut
# alors 0 et le minimum litteral donne 0 sans aucune garde. La colonne J-2
# (j = 3) a ses deux facteurs individuels egaux a 1,02 : depuis l'issue #21,
# elle est detectee comme la colonne J-3 et le meme avertissement est emis,
# seule la cause changeant (il ne l'etait pas auparavant).
tri_sym <- matrix(NA_real_, 6, 6)
tri_sym[1, ] <- c(1000, 1600, 1800, 1900, 1938, 1945)
tri_sym[2, 1:5] <- c(1100, 1815, 2000, 2150, 2193)
tri_sym[3, 1:4] <- c(900, 1395, 1580, 1650)
tri_sym[4, 1:3] <- c(1200, 1980, 2210)
tri_sym[5, 1:2] <- c(1050, 1638)
tri_sym[6, 1]   <- 980
# Les deux autres chemins vers sigma2_(J-1) = 0 (issue #21) :
# - tri_2 : colonnes J-3 ET J-2 degenerees (sigma2_(J-3) = sigma2_(J-2) = 0) ;
# - tri_ach : colonne J-2 degeneree avec developpement acheve (f_(J-2) =
#   f_(J-1) = 1) : l'avertissement subsiste, sans la phrase "PAS acheve".
tri_2 <- tri_deg
tri_2[1, 5:6] <- c(1836, 1841)
tri_2[2, 5] <- 2040
tri_ach <- tri_sym
tri_ach[1, 5:6] <- c(1900, 1900)
tri_ach[2, 5] <- 2150
# sigma_USP de reference (segment 1 de l'annexe II) : mesures sur le moteur
# le 23/09/2026 ; l'issue #21 ne change aucun calcul (valeurs identiques avant
# et apres), elles fixent le fait que l'avertissement ne touche pas au calcul.
# Avertissement des colonnes exclues des residus de Mack (#33 ; formulation
# de l'issue #60, Q-E2r-60-2, et enonce du predicat decide le 06/10/2026).
av_exclues <- function(av) grep(paste0("a facteurs individuels egaux a f_j a la tolerance ",
                                       "relative 1e-12 de l'outil (",
                                       .MW_PREDICAT_DEGENERE_TEXTE,
                                       " ; sigma2_j nul ou numeriquement nul)"), av,
                                fixed = TRUE, value = TRUE)
run_mw <- function(t) run_engine(methode = "reserve2", triangle = t,
                                 segment = 1, annexe = "II", B = 99)
av_extrap <- function(r) grep("sigma2_(J-1) = min", r$validation$avertissements,
                              fixed = TRUE, value = TRUE)
detail_m6 <- function(r) {
  d <- engine_table_tests(r)
  d$commentaire[grepl("Extrapolation de sigma", d$test)]
}
verifier("sigma2_(J-2) = 0 avec sigma2_(J-3) > 0 : sigma2_(J-1) = 0, avertissement emis (#21)",
         {
           a <- mw_ajuster(tri_sym)
           ex <- mw_extrapolation_sigma2(a)
           r <- run_mw(tri_sym)
           av <- av_extrap(r)
           isTRUE(mw_valider_triangle(tri_sym)$ok) &&
             a$sigma2[a$J - 1] < 1e-12 && a$sigma2[a$J - 2] > 1e-3 &&
             a$sigma2[a$J] < 1e-12 && ex$quotient < 1e-12 &&
             isTRUE(ex$degeneree_Jm2) && identical(ex$degeneree_Jm3, FALSE) &&
             isTRUE(ex$degeneree) && ex$nb_facteurs_Jm2 == 2 &&
             identical(ex$retenu, "sigma2_(J-2)") &&
             isTRUE(r$ok) && length(av) == 1 &&
             grepl("sigma2_(J-2) = 0", av, fixed = TRUE) &&
             grepl("j = J-2 = 3", av, fixed = TRUE) &&
             grepl("AUCUNE variance", av, fixed = TRUE) &&
             grepl("n'est pourtant PAS acheve", av, fixed = TRUE) &&
             !grepl("sigma2_(J-3) = 0", av, fixed = TRUE) &&
             grepl(", colonne J-2 degeneree : voir l'avertissement sur les donnees.", detail_m6(r), fixed = TRUE) &&
             grepl("(colonne J-2 degeneree, quotient non compte)", detail_m6(r), fixed = TRUE) &&
             # Depuis #33, l'absence de residus est dite par l'avertissement
             # general sur les colonnes exclues, et non plus par celui-ci.
             !grepl("sont exclus des residus de Mack", av, fixed = TRUE) &&
             any(grepl(paste0("j = 3 (2 facteurs). Le residu de Mack n'y est pas defini (0/0) ",
                              "si les facteurs sont exactement egaux"),
                       r$validation$avertissements, fixed = TRUE)) &&
             isTRUE(proche(r$parametre_final$sigma_usp, 0.0769833895, rel = 1e-8))
         })
verifier("Colonne J-3 degeneree (tri_deg) : colonne J-2 non degeneree, sigma_USP inchange",
         {
           ex <- mw_extrapolation_sigma2(mw_ajuster(tri_deg))
           r <- run_mw(tri_deg)
           identical(ex$degeneree_Jm2, FALSE) && isTRUE(ex$degeneree_Jm3) &&
             isTRUE(proche(r$parametre_final$sigma_usp, 0.0779834956, rel = 1e-8))
         })
verifier("Colonnes J-3 et J-2 degenerees (tri_2) : un seul avertissement, ex aequo au M6 (#21)",
         {
           a <- mw_ajuster(tri_2)
           ex <- mw_extrapolation_sigma2(a)
           r <- run_mw(tri_2)
           av <- av_extrap(r)
           l <- detail_m6(r)
           isTRUE(mw_valider_triangle(tri_2)$ok) && isTRUE(r$ok) &&
             isTRUE(ex$degeneree_Jm3) && isTRUE(ex$degeneree_Jm2) &&
             isTRUE(ex$degeneree) && is.na(ex$quotient) && a$sigma2[a$J] == 0 &&
             length(av) == 1 &&
             grepl("j = J-3 = 2", av, fixed = TRUE) &&
             grepl("j = J-2 = 3", av, fixed = TRUE) &&
             grepl("sigma2_(J-3) = 0", av, fixed = TRUE) &&
             grepl("sigma2_(J-2) = 0", av, fixed = TRUE) &&
             grepl("n'est pourtant PAS acheve", av, fixed = TRUE) &&
             length(l) == 1 &&
             grepl("atteint par sigma2_(J-2) et sigma2_(J-3) (ex aequo)", l,
                   fixed = TRUE) &&
             grepl(", colonnes J-3 et J-2 degenerees : voir l'avertissement sur les donnees.", l,
                   fixed = TRUE) &&
             # enonce du predicat une seule fois, J-3 et J-2 degenerees (#60)
             lengths(regmatches(av, gregexpr(.MW_PREDICAT_DEGENERE_TEXTE, av,
                                             fixed = TRUE))) == 1L &&
             isTRUE(proche(r$parametre_final$sigma_usp, 0.0764092721, rel = 1e-8))
         })
verifier("Colonne J-2 degeneree, developpement acheve (tri_ach) : avertissement sans 'PAS acheve'",
         {
           ex <- mw_extrapolation_sigma2(mw_ajuster(tri_ach))
           r <- run_mw(tri_ach)
           av <- av_extrap(r)
           isTRUE(mw_valider_triangle(tri_ach)$ok) && isTRUE(r$ok) &&
             isTRUE(ex$degeneree_Jm2) && identical(ex$developpement_acheve, TRUE) &&
             length(av) == 1 &&
             !grepl("PAS acheve", av, fixed = TRUE) &&
             isTRUE(proche(r$parametre_final$sigma_usp, 0.0800581924, rel = 1e-8))
         })
verifier("Homogeneite : un avertissement de meme squelette par triangle degenere, aucun sinon",
         {
           msg_deg <- vapply(list(tri_deg, tri_sym, tri_2, tri_ach), function(t) {
             av <- run_mw(t)$validation$avertissements
             sum(grepl("sigma2_(J-1) = min", av, fixed = TRUE)) == 1 &&
               sum(grepl("AUCUNE variance sur la derniere annee de developpement",
                         av, fixed = TRUE)) == 1 &&
               sum(grepl("sont exclus des residus de Mack", av, fixed = TRUE)) == 1 &&
               sum(grepl("Verifier l'origine des donnees", av, fixed = TRUE)) == 1
           }, logical(1))
           tp <- matrix(NA_real_, 5, 5)
           tp[1, ] <- c(100, 150, 180, 190, 189); tp[2, 1:4] <- c(110, 160, 190, 199)
           tp[3, 1:3] <- c(120, 185, 219); tp[4, 1:2] <- c(130, 200); tp[5, 1] <- 140
           msg_nd <- vapply(list(tri, tp), function(t)
             !any(grepl("sigma2_(J-", run_mw(t)$validation$avertissements, fixed = TRUE)),
             logical(1))
           all(msg_deg) && all(msg_nd)
         })
# Colonne J-2 constante a 1e-14 pres (scenario d'actuary, #21) : sigma2_(J-2)
# ~ 1e-25 et le quotient ~ 1e-50 est l'argmin litteral (ex$retenu), mais le
# detail M6 nomme la cause, sigma2_(J-2), sans compter le quotient comme
# argument distinct.
verifier("Colonne J-2 constante a 1e-14 pres : argmin litteral = quotient, cause nommee au M6",
         {
           t4 <- tri_sym
           t4[2, 5] <- 2193 * (1 + 1e-14)
           ex <- mw_extrapolation_sigma2(mw_ajuster(t4))
           r <- run_mw(t4)
           av <- av_extrap(r)
           isTRUE(ex$degeneree_Jm2) &&
             identical(ex$retenu, "sigma2_(J-2)^2/sigma2_(J-3)") &&
             grepl("(colonne J-2 degeneree, quotient non compte)", detail_m6(r), fixed = TRUE) &&
             length(av) == 1 && grepl("j = J-2 = 3", av, fixed = TRUE)
         })
# Colonne J-2 detectee (facteurs egaux a l'arrondi pres) mais sigma2_(J-2) > 0
# (2,1e-28). Triangle trouve par le balayage d'audit (graine 1, 7e tirage :
# cumuls 1760,07 et 2554,89 multiplies par 1,187), ecrit ici en dur. Depuis
# l'issue #60 (test inverse), mw_residus() ecarte la colonne sur le predicat
# .mw_colonne_degeneree() et non plus sur sigma2_j = 0 exact : ses residus de
# bruit d'arrondi sont absents, et l'avertissement des colonnes exclues est
# emis ; celui de l'extrapolation ne dit toujours pas les residus absents
# (issue #33 : dit une seule fois, par l'avertissement des colonnes exclues).
verifier("Colonne detectee avec sigma2 > 0 : residus exclus, avertissement des colonnes exclues (#60)",
         {
           t5 <- tri_sym
           t5[1, 4] <- 1760.07; t5[2, 4] <- 2554.89
           t5[1, 5] <- 1760.07 * 1.187; t5[2, 5] <- 2554.89 * 1.187
           t5[1, 6] <- t5[1, 5] * 1.003
           a <- mw_ajuster(t5)
           ex <- mw_extrapolation_sigma2(a)
           r <- run_mw(t5)
           av <- av_extrap(r)
           isTRUE(mw_valider_triangle(t5)$ok) && isTRUE(r$ok) &&
             isTRUE(ex$degeneree_Jm2) && a$sigma2[a$J - 1] > 0 &&
             sum(mw_residus(a)$j == 3) == 0 &&
             identical(attr(mw_residus(a), "colonnes_exclues")$j, 3L) &&
             length(av) == 1 &&
             !grepl("absents", av, fixed = TRUE) &&
             !grepl("sont exclus des residus de Mack", av, fixed = TRUE) &&
             length(av_exclues(r$validation$avertissements)) == 1 &&
             grepl("j = 3 (2 facteurs)", av_exclues(r$validation$avertissements), fixed = TRUE)
         })
# Les residus de Mack d'une colonne a sigma2_j = 0 sont absents de
# mw_residus() : c'est ce qu'affirme l'avertissement.
verifier("Colonne degeneree : aucun residu de Mack (mw_residus) pour ses facteurs",
         {
           j_res <- function(t) mw_residus(mw_ajuster(t))$j
           !any(j_res(tri_deg) == 2) && !any(j_res(tri_sym) == 3) &&
             !any(j_res(tri_2) %in% 2:3) && !any(j_res(tri_ach) == 3) &&
             any(j_res(tri_sym) == 2) && any(j_res(tri_deg) == 3)
         })
## --- Colonnes exclues de mw_residus() et reserve negligeable (#33) ----------
# Avis d'actuary du 24/09/2026 (commentaire de #33) : une colonne a
# sigma2_j = 0 reste exclue, mais l'exclusion est dite par UN avertissement
# de validation par triangle (colonnes, residus exclus et retenus, lignes
# concernees), sans champ nouveau dans le resultat. Triangle tri_j1 : colonne
# j = 1 (hors J-3 = 2 et J-2 = 3) a facteurs tous egaux a 1,25 (exact en
# binaire, sigma2_1 = 0 exactement), la colonne J-2 de tri_sym rendue non
# degeneree (2195 au lieu de 2193).
tri_j1 <- tri_sym
tri_j1[2, 5] <- 2195
for (i in 1:4) tri_j1[i, 3] <- 1.25 * tri_j1[i, 2]
for (i in 1:3) tri_j1[i, 4:(7 - i)] <- tri_sym[i, 4:(7 - i)] / tri_sym[i, 3] * tri_j1[i, 3]
tri_j1[2, 5] <- 2195 / 2000 * tri_j1[2, 3]

verifier("Colonne j = 1 a sigma2 = 0 (hors J-3, J-2) : exclue, attribut renseigne, un avertissement (#33)",
         {
           a <- mw_ajuster(tri_j1)
           rs <- mw_residus(a)
           ce <- attr(rs, "colonnes_exclues")
           r <- run_mw(tri_j1)
           av <- av_exclues(r$validation$avertissements)
           ex <- mw_extrapolation_sigma2(a)
           isTRUE(mw_valider_triangle(tri_j1)$ok) && isTRUE(r$ok) &&
             a$sigma2[2] == 0 && all(a$sigma2[-c(2, a$J)] > 0) && !isTRUE(ex$degeneree) &&
             identical(ce$j, 1L) && identical(ce$n_facteurs, 4L) && !any(rs$j == 1) &&
             nrow(rs) == sum(pmax(a$I - (0:(a$J - 1)), 0)[-c(2, a$J)]) &&
             length(av) == 1 &&
             grepl("Colonne de developpement a facteurs individuels egaux a f_j", av, fixed = TRUE) &&
             grepl("j = 1 (4 facteurs)", av, fixed = TRUE) &&
             grepl(sprintf("ces 4 facteurs individuels sont exclus des residus de Mack ; %d residu(s)",
                           nrow(rs)), av, fixed = TRUE) &&
             grepl(.MW_LIGNES_RESIDUS_TEXTE, av, fixed = TRUE) &&
             !any(grepl("sigma2_(J-1) = min", r$validation$avertissements, fixed = TRUE))
         })
verifier("Colonnes exclues : une seule phrase par triangle, J-3 / J-2 compris (tri_deg, tri_sym, tri_2)",
         all(vapply(list(tri_deg, tri_sym, tri_2), function(t) {
           av <- run_mw(t)$validation$avertissements
           length(av_exclues(av)) == 1 &&
             sum(grepl("sont exclus des residus de Mack", av, fixed = TRUE)) == 1
         }, logical(1))) &&
         grepl("Colonnes de developpement a facteurs individuels egaux a f_j",
               av_exclues(run_mw(tri_2)$validation$avertissements), fixed = TRUE))
verifier("Colonnes exclues : l'attribut n'est pas stocke dans le resultat (res$residus, plots_data)",
         {
           r <- run_mw(tri_j1)
           is.null(attr(r$residus, "colonnes_exclues")) &&
             is.null(attr(r$plots_data$residus, "colonnes_exclues"))
         })
# Reserve positive mais negligeable (decision du mainteneur du 24/09/2026) :
# avertissement non bloquant si racine(MSEP) / R >= 1, aucun refus, M4
# inchangee. Triangle tri_vol : cumuls quasi plats et bruites (facteurs
# autour de 1), R = 20,27, racine(MSEP) / R = 1,96 (mesure du 25/09/2026).
tri_vol <- matrix(NA_real_, 6, 6)
tri_vol[1, ] <- c(1000, 1003, 998, 1004, 999, 1001)
tri_vol[2, 1:5] <- c(1100, 1096, 1104, 1097, 1102)
tri_vol[3, 1:4] <- c(900, 905, 898, 903)
tri_vol[4, 1:3] <- c(1200, 1193, 1207)
tri_vol[5, 1:2] <- c(1050, 1056)
tri_vol[6, 1]   <- 980
av_cv <- function(av) grep("Reserve chain-ladder positive mais faible devant son incertitude",
                           av, fixed = TRUE, value = TRUE)
verifier("Reserve negligeable : racine(MSEP) / R >= 1 -> ok = TRUE et avertissement (#33)",
         {
           r <- run_mw(tri_vol)
           av <- av_cv(r$validation$avertissements)
           isTRUE(r$ok) && r$parametre_final$sigma_estime >= 1 && length(av) == 1 &&
             grepl(sprintf("= %s >= 1", format(r$parametre_final$sigma_estime, digits = 4)), av,
                   fixed = TRUE) &&
             grepl("de l'ultime total", av, fixed = TRUE) &&
             grepl("sans fondement reglementaire ni statistique", av, fixed = TRUE) &&
             grepl("run-off", av, fixed = TRUE)
         })
verifier("Reserve negligeable : pas d'avertissement sous le repere (triangles de test et tri_sym)",
         {
           d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
           m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"
           a <- mw_ajuster(unname(m)); ms <- mw_msep(a)$msep
           v <- mw_valider_ajustement(a, ms)
           isTRUE(v$ok) && sqrt(ms) / a$reserve < 1 && !length(v$avertissements) &&
             !length(av_cv(run_mw(tri_sym)$validation$avertissements))
         })
verifier("Reserve negligeable : repere a la frontiere (objet reduit, racine(MSEP) / R = 1 et 0,999)",
         length(av_cv(mw_valider_ajustement(list(I = 4L, reserve = 10), 100)$avertissements)) == 1 &&
         !length(av_cv(mw_valider_ajustement(list(I = 4L, reserve = 10), 99.8)$avertissements)) &&
         isTRUE(mw_valider_ajustement(list(I = 4L, reserve = 10), 400)$ok))

# Les lignes citees par l'avertissement comme fondees sur les residus de Mack
# (.MW_LIGNES_RESIDUS) sont exactement celles de mw_tests() qui consomment
# mw_residus() : mesure par perturbation de mw_residus() (bootstrap fixe),
# union sur sept perturbations ; une ligne consomme les residus si sa
# statistique, son estimation ou une de ses p-values change.
verifier("Lignes citees comme fondees sur les residus = lignes qui consomment mw_residus() (mesure)",
         {
           d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
           m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"
           t_ref <- unname(m)
           orig <- mw_residus
           # Etat du generateur capture a l'entree du bloc (mw_bootstrap()
           # regraine plus bas) et restaure meme si une mesure echoue.
           graine <- if (exists(".Random.seed", envir = globalenv()))
             get(".Random.seed", envir = globalenv()) else NULL
           restaurer_graine <- function() {
             if (is.null(graine)) {
               if (exists(".Random.seed", envir = globalenv())) rm(".Random.seed", envir = globalenv())
             } else assign(".Random.seed", graine, envir = globalenv())
           }
           M <- tryCatch({
           sig <- function(L) vapply(L, function(x) paste(format(c(x$stat, x$estim,
             x$p_exacte, x$p_asymptotique, x$p_mc), digits = 15), collapse = "|"), "")
           prep <- lapply(list(deg = tri_deg, ref = t_ref), function(t) {
             aj <- mw_ajuster(t); boot <- mw_bootstrap(aj, B = 19)
             list(aj = aj, boot = boot, L0 = mw_tests(aj, boot))
           })
           mesurer <- function(nom, perturb) {
             aj <- prep[[nom]]$aj; boot <- prep[[nom]]$boot; L0 <- prep[[nom]]$L0
             # Substitution dans l'environnement du moteur (ADR 0016, #200).
             assign("mw_residus", function(aj, j_degeneres = NULL) perturb(orig(aj, j_degeneres)),
                    envir = environment(mw_tests))
             L1 <- tryCatch(mw_tests(aj, boot),
                            finally = assign("mw_residus", orig, envir = environment(mw_tests)))
             stats::setNames(sig(L0) != sig(L1), vapply(L0, `[[`, "", "test"))
           }
           set.seed(20260923)
           P <- list(
             list("deg", function(r) r[r$j != 3, ]),
             list("ref", function(r) { r$residu <- r$residu * runif(nrow(r), 0.5, 1.5); r }),
             list("ref", function(r) r[r$j != 0, ]),
             list("ref", function(r) { r$residu[3] <- 50; r }),
             list("ref", function(r) { r$residu <- r$residu * sample(c(-1, 1), nrow(r), TRUE); r }),
             list("ref", function(r) { r$C <- r$C * runif(nrow(r), 0.5, 1.5); r }),
             list("ref", function(r) { r$F <- r$F * runif(nrow(r), 0.9, 1.1); r }))
           sapply(P, function(p) mesurer(p[[1]], p[[2]]))
           }, finally = restaurer_graine())
           mesure <- rownames(M)[rowSums(M) > 0]
           cite <- unlist(.MW_LIGNES_RESIDUS, use.names = FALSE)
           # 10 lignes depuis #300 (11 avant : la ligne de cellule aberrante
           # est calculee sur mw_influence(), non sur mw_residus()).
           if (identical(mw_residus, orig) && setequal(mesure, cite) && length(cite) == 10) TRUE
           else paste("mesure :", paste(mesure, collapse = " ; "))
         })
# Coherence de la constante .MW_LIGNES_COLONNES_ECARTEES (#363, decision
# Q-44-3 (a)) avec mw_tests() : elle nomme exactement les lignes qui recoivent
# l'ensemble fige jd (figes$degeneres), directement ou par mw_residus(). Mesure
# par substitution de figes$degeneres (boot fixe, triangle de non-regression,
# deux ensembles, 2 et 0:3 : chacun des cinq essayes a la mise au point donne a
# lui seul les memes 17 lignes) : les lignes dont le contenu change lisent jd. Les lignes
# fondees sur les residus (.MW_LIGNES_RESIDUS, mesurees plus haut par
# perturbation de mw_residus()) en font partie par construction, mais l'une
# d'elles, Rosner, n'imprime que son nombre de cellules declarees (0 ici) et
# ne change pas sous cette substitution : l'ensemble mesure est donc complete
# par .MW_LIGNES_RESIDUS. La constante porte aussi la famille de chaque ligne.
verifier("Lignes citees comme ecartant les colonnes degenerees = lignes de mw_tests() qui recoivent jd (mesure, #363)",
         {
           d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
           m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"
           a <- mw_ajuster(unname(m)); boot <- mw_bootstrap(a, B = 19)
           f0 <- .mw_ensembles_figes(a)
           L0 <- mw_tests(a, boot, figes = f0)
           noms <- vapply(L0, `[[`, "", "test")
           mesure <- unique(unlist(lapply(list(2L, 0:3), function(jx) {
             f1 <- f0; f1$degeneres <- jx
             L1 <- mw_tests(a, boot, figes = f1)
             noms[!vapply(seq_along(L0), function(k) identical(L0[[k]], L1[[k]]), NA)]
           })))
           cite <- unlist(.MW_LIGNES_COLONNES_ECARTEES, use.names = FALSE)
           fam_cite <- rep(names(.MW_LIGNES_COLONNES_ECARTEES), lengths(.MW_LIGNES_COLONNES_ECARTEES))
           fam_ligne <- substr(vapply(L0, `[[`, "", "famille"), 1, 2)[match(cite, noms)]
           residus <- unlist(.MW_LIGNES_RESIDUS, use.names = FALSE)
           if (setequal(c(mesure, residus), cite) && !anyDuplicated(cite) &&
               all(cite %in% noms) && identical(unname(fam_ligne), fam_cite) &&
               all(residus %in% cite) && length(mesure) == 17 && length(cite) == 18) TRUE
           else paste("mesure :", paste(mesure, collapse = " ; "),
                      "| citees hors mesure et hors residus :",
                      paste(setdiff(cite, c(mesure, residus)), collapse = " ; "),
                      "| mesurees non citees :", paste(setdiff(mesure, cite), collapse = " ; "))
         })
# Triangle de non-regression (tests/donnees/triangle_mw.csv) : aucune des
# deux colonnes n'est degeneree. Detail M6 de #514 (specification finale
# d'actuary, M6-1 : phrase 1, regle et arguments ; phrase 2, ligne liee ;
# Q-3 : sensibilite de #310 retiree du detail), a la lettre.
LIE_M6 <- "A lire avec \"Part de la reserve portee par la derniere annee d'accident\"."
T514_M6 <- paste0(
  "Valeur fixee par la regle de minimum de l'annexe XVII, D(5)(d)(ii), ",
  "non estimee : min(sigma2_(J-2) = 0.189674, sigma2_(J-3) = 0.0973248, ",
  "quotient = 0.36965) = 0.0973248, atteint par sigma2_(J-3). ", LIE_M6)
verifier("Triangle de non-regression : colonnes J-3 et J-2 non degenerees, detail M6 = texte de #514",
         {
           d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
           m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"
           a <- mw_ajuster(unname(m))
           ex <- mw_extrapolation_sigma2(a)
           ex$ecart_relatif > 1e-3 && ex$ecart_relatif_Jm2 > 1e-3 &&
             identical(ex$degeneree_Jm3, FALSE) && identical(ex$degeneree_Jm2, FALSE) &&
             identical(ex$degeneree, FALSE) &&
             identical(.mw_detail_extrapolation(ex), T514_M6)
         })

## --- Sensibilite de racine(MSEP) a sigma2_(J-1) (#310) -----------------------
# Specification Fm, § 3 (decisions Q-D1-Fm-6 a Q-D1-Fm-9). Les racines de
# MSEP de reference sont celles de la mesure m_fm_d de la specification
# (docs/tableaux/20261023-fm-mesures.md), recalculees ici par un remplacement
# reecrit hors de la fonction (meme methode que mw_sensibilite_sigma2_dernier()
# : sigma2[J] et Q[J] remplaces, mw_msep()). Depuis #514 (Q-3), la
# sensibilite n'est plus restituee dans le detail M6 ; la fonction reste, et
# ses valeurs sont verifiees ici.
local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"
  t_ref <- unname(m)
  a <- mw_ajuster(t_ref); J <- a$J
  ex <- mw_extrapolation_sigma2(a)
  s <- mw_sensibilite_sigma2_dernier(a, ex)
  msep_avec <- function(v) {
    b <- a; b$sigma2[J] <- v; b$Q[J] <- v / b$f[J]^2; mw_msep(b)
  }
  verifier("#310 : MSEP recalculee avec la valeur de la regle identical() a mw_msep(aj)",
           identical(msep_avec(a$sigma2[J]), mw_msep(a)) &&
             identical(s$racine_msep_regle, sqrt(mw_msep(a)$msep)) &&
             identical(s$valeur_regle, a$sigma2[J]))
  verifier("#310 : racines de MSEP sur reserve2 (regle, sigma2_(J-2), quotient, 0) a 1e-6 relatif",
           isTRUE(s$applicable) &&
             isTRUE(proche(s$racine_msep_regle, 199.494435, rel = 1e-6)) &&
             isTRUE(proche(unname(s$racine_msep_arguments),
                           c(226.413084, 199.494435, 271.305067), rel = 1e-6)) &&
             isTRUE(proche(s$racine_msep_zero, 166.479535, rel = 1e-6)) &&
             isTRUE(proche(unname(s$racine_msep_arguments),
                           vapply(c(ex$sigma2_Jm2, ex$sigma2_Jm3, ex$quotient),
                                  function(v) sqrt(msep_avec(v)$msep), numeric(1)), rel = 1e-15)) &&
             identical(names(s$racine_msep_arguments), c("sigma2_Jm2", "sigma2_Jm3", "quotient")))
  verifier("#514 : detail M6 de reserve2 = texte de #514 a la lettre (mw_tests()), sans sensibilite",
           identical(detail_m6(run_mw(t_ref)), T514_M6) &&
             !grepl("Sensibilite|contrefactuel", detail_m6(run_mw(t_ref))))
  verifier("#310 : vocabulaire R1, ni 'extrapolee' ni 'imposee' dans le detail M6",
           !grepl("extrapol|impose", T514_M6) &&
             !grepl("extrapol|impose", .mw_detail_extrapolation(ex)))
  verifier("#310 : plots_data$facteurs$sigma_regle_minimum, logique, en fin, un seul TRUE en j = J - 1",
           {
             f <- run_mw(t_ref)$plots_data$facteurs
             identical(names(f), c("j", "f", "sigma", "sigma_regle_minimum")) &&
               is.logical(f$sigma_regle_minimum) && sum(f$sigma_regle_minimum) == 1L &&
               identical(f$j[f$sigma_regle_minimum], J - 1L) &&
               identical(f$sigma, sqrt(a$sigma2))
           })
})
verifier("#310 / #514 : quotient non defini (sigma2_(J-3) = 0) -> 'non defini' dans min(...), colonne J-3 degeneree nommee, sans sensibilite",
         {
           a <- mw_ajuster(tri_deg); ex <- mw_extrapolation_sigma2(a)
           s <- mw_sensibilite_sigma2_dernier(a, ex)
           l <- detail_m6(run_mw(tri_deg))
           is.na(s$racine_msep_arguments[["quotient"]]) && a$sigma2[a$J] == 0 &&
             identical(l, .mw_detail_extrapolation(ex)) &&
             grepl("quotient = non defini (sigma2_(J-3) = 0)", l, fixed = TRUE) &&
             endsWith(l, paste(", colonne J-3 degeneree : voir l'avertissement sur les donnees.",
                               LIE_M6)) &&
             !grepl("Sensibilite|contrefactuel", l)
         })
# Colonne J-2 de tri_sym constante a 1e-14 pres (valeur de la regle de l'ordre
# de 1e-50) : degeneree a la tolerance de l'outil, nommee dans la seconde
# phrase ; sensibilite absente du detail (#514).
verifier("#310 / #514 : colonne J-2 constante a 1e-14 pres (regle > 0 mais nulle a la tolerance) : cause nommee, sans sensibilite",
         {
           t4 <- tri_sym
           t4[2, 5] <- 2193 * (1 + 1e-14)
           a <- mw_ajuster(t4); ex <- mw_extrapolation_sigma2(a)
           l <- detail_m6(run_mw(t4))
           a$sigma2[a$J] > 0 && isTRUE(ex$degeneree) &&
             identical(l, .mw_detail_extrapolation(ex)) &&
             grepl(", colonne J-2 degeneree : voir l'avertissement sur les donnees.", l, fixed = TRUE) &&
             !grepl("Sensibilite|contrefactuel", l)
         })
# Constat C1 de la revue finale (erratum (2) du 24/10/2026 de la specification
# Fm, T-4) : colonne J-3 constante a 1e-14 pres, F(i, J-3) = 1,1 (1 + 1e-14
# (i mod 2)), colonnes suivantes reechelonnees. sigma2_(J-3) ~ 1e-25 n'est pas
# nul, le quotient vaut ~ 1e23 : mw_sensibilite_sigma2_dernier() rend la
# racine de la MSEP du quotient NA (meme condition, degeneree_Jm3, que
# l'omission du contrefactuel) ; arguments["quotient"] garde sa valeur
# calculee.
local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"
  m <- unname(m)
  degen_Jm3 <- function(tri, eps) {
    I <- nrow(tri) - 1L; j <- ncol(tri) - 4L
    for (i in 0:(I - j - 1L)) {
      old <- tri[i + 1, j + 2]
      new <- tri[i + 1, j + 1] * 1.1 * (1 + eps * (i %% 2))
      k <- (j + 2):(I - i + 1)
      tri[i + 1, k] <- tri[i + 1, k] * new / old
    }
    tri
  }
  verifier("#310 (C1) : colonne J-3 constante a 1e-14 pres -> racine du quotient NA dans mw_sensibilite_sigma2_dernier() ; detail M6 sans sensibilite, colonne J-3 nommee",
           {
             t1 <- degen_Jm3(m, 1e-14)
             a <- mw_ajuster(t1); ex <- mw_extrapolation_sigma2(a)
             s <- mw_sensibilite_sigma2_dernier(a, ex)
             l <- detail_m6(run_mw(t1))
             isTRUE(ex$degeneree_Jm3) && a$sigma2[a$J] > 0 &&
               is.finite(ex$quotient) && ex$quotient > 1e20 &&
               identical(s$arguments[["quotient"]], ex$quotient) &&
               is.na(s$racine_msep_arguments[["quotient"]]) &&
               all(is.finite(s$racine_msep_arguments[c("sigma2_Jm2", "sigma2_Jm3")])) &&
               identical(l, .mw_detail_extrapolation(ex)) &&
               grepl(", colonne J-3 degeneree : voir l'avertissement", l, fixed = TRUE) &&
               !grepl("Sensibilite|contrefactuel", l)
           })
  verifier("#310 (C1) : colonne J-3 exactement constante -> quotient NA, 'non defini' (inchange)",
           {
             t0 <- degen_Jm3(m, 0)
             a <- mw_ajuster(t0); ex <- mw_extrapolation_sigma2(a)
             s <- mw_sensibilite_sigma2_dernier(a, ex)
             l <- .mw_detail_extrapolation(ex)
             isTRUE(ex$degeneree_Jm3) && a$sigma2[a$J] == 0 && is.na(ex$quotient) &&
               is.na(s$arguments[["quotient"]]) &&
               is.na(s$racine_msep_arguments[["quotient"]]) &&
               grepl("quotient = non defini (sigma2_(J-3) = 0)", l, fixed = TRUE)
           })
  # #372 (1) : les racines de MSEP de la mesure de l'issue (triangle_mw.csv,
  # colonne J-3 presque constante) restent celles de
  # mw_sensibilite_sigma2_dernier() (valeurs a 6 chiffres significatifs, telles
  # que l'ancien detail les imprimait) ; depuis #514, aucune n'est imprimee
  # dans le detail M6.
  verifier("#372 (1) / #514 : eps = 5e-12, 1e-4, 1e-3 -> racines de MSEP de mw_sensibilite_sigma2_dernier() inchangees, detail M6 sans sensibilite",
           {
             f6 <- function(x) format(x, digits = 6)
             z <- lapply(c(5e-12, 1e-4, 1e-3), function(eps) {
               t <- degen_Jm3(m, eps); a <- mw_ajuster(t); ex <- mw_extrapolation_sigma2(a)
               list(s = mw_sensibilite_sigma2_dernier(a, ex), l = detail_m6(run_mw(t)),
                    ex = ex)
             })
             r <- function(k) vapply(c(z[[k]]$s$racine_msep_regle,
                                       z[[k]]$s$racine_msep_arguments[1:2],
                                       z[[k]]$s$racine_msep_zero), f6, "")
             identical(unname(r(1)), c("160.926", "222.538", "160.926", "160.926")) &&
               z[[1]]$s$racine_msep_arguments[["quotient"]] / z[[1]]$s$racine_msep_regle > 1e9 &&
               identical(unname(r(2)), c("160.935", "222.55", "160.935", "160.931")) &&
               identical(f6(z[[2]]$s$racine_msep_arguments[["quotient"]]), "21457.6") &&
               identical(unname(r(3)), c("161.413", "222.704", "161.413", "161.036")) &&
               identical(f6(z[[3]]$s$racine_msep_arguments[["quotient"]]), "2153.77") &&
               all(vapply(z, function(x) identical(x$l, .mw_detail_extrapolation(x$ex)) &&
                            !grepl("Sensibilite|contrefactuel", x$l), logical(1)))
           })
})
# Racine de la MSEP nulle avec la valeur de la regle (facteurs constants par
# colonne, 8 x 8 : tous les sigma2_j nuls, MSEP = 0) : ecarts relatifs non
# definis, la sensibilite n'est pas applicable.
verifier("#310 : racine(MSEP) de la regle nulle (facteurs constants par colonne) -> sensibilite non applicable, aucun NaN",
         {
           fc <- c(2, 1.5, 1.2, 1.1, 1.05, 1.02, 1.01)
           tc <- matrix(NA_real_, 8, 8)
           for (i in 1:8) { tc[i, 1] <- 1000 + 100 * i
             if (i <= 7) for (j in 2:(9 - i)) tc[i, j] <- tc[i, j - 1] * fc[j - 1] }
           a <- mw_ajuster(tc); ex <- mw_extrapolation_sigma2(a)
           s <- mw_sensibilite_sigma2_dernier(a, ex)
           l <- .mw_detail_extrapolation(ex)
           isTRUE(ex$applicable) && mw_msep(a)$msep == 0 &&
             identical(s$applicable, FALSE) && is.na(s$racine_msep_regle) &&
             all(is.na(s$racine_msep_arguments)) && is.na(s$racine_msep_zero) &&
             !grepl("NaN", l, fixed = TRUE) && !grepl("Sensibilite", l, fixed = TRUE)
         })
verifier("#310 : sensibilite non applicable (objet d'ajustement reduit) : aucune valeur ; detail M6 de la branche non applicable (texte de #514)",
         {
           ex0 <- mw_extrapolation_sigma2(list(I = 4L, reserve = 10))
           s0 <- mw_sensibilite_sigma2_dernier(list(I = 4L, reserve = 10), ex0)
           identical(s0$applicable, FALSE) && is.na(s0$racine_msep_regle) &&
             identical(.mw_detail_extrapolation(ex0),
                       paste("Valeur fixee par la regle de minimum de l'annexe XVII, D(5)(d)(ii), non",
                             "estimee : la regle ne lit que les deux dernieres variances estimees.",
                             LIE_M6))
         })

## --- Test des suites en diagnostic secondaire, moyennes par groupe (#312) ----
# Specification Fm, par. 1.1, 1.2, 7 et texte T-1 (decisions Q-D1-Fm-1 (B)
# et Q-D1-Fm-2 du mainteneur, 23/10/2026). Valeurs attendues des moyennes :
# tableaux du par. 1.2 (mesure m_fm_a, a 1e-5 pres) ; valeurs exactes contre
# tapply() sur la table des residus qui alimente les nuages.
local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"
  r312 <- run_mw(unname(m))
  pd <- r312$plots_data; res <- pd$residus
  ga <- pd$residus_acc_groupes; gc <- pd$residus_cal_groupes
  # Depuis #311, qqline suit residus_cal_groupes en fin de liste.
  # Depuis #305, sigma_usp_boot et boot_reperes suivent qqline.
  verifier("#312 : residus_acc_groupes et residus_cal_groupes apres sigma_boot (puis qqline, #311, et les deux champs de #305), aucune feuille deplacee",
           {
             nm <- names(pd)
             identical(utils::tail(nm, 6), c("sigma_boot", "residus_acc_groupes", "residus_cal_groupes",
                                             "qqline", "sigma_usp_boot", "boot_reperes")) &&
               identical(nm[1:14], c("facteurs", "reserve_par_annee", "residus", "residus_dev",
                                     "residus_acc", "residus_cal", "residus_C", "qqnorm", "regressions",
                                     "alpha", "origine", "influence", "contributions", "sigma_boot")) &&
               identical(names(ga), c("i", "n", "moyenne")) &&
               identical(names(gc), c("calendrier", "n", "moyenne")) &&
               is.integer(ga$n) && is.integer(gc$n)
           })
  verifier("#312 : n et moyennes par groupe = table() et tapply() sur les residus des nuages, a 1e-10",
           {
             ta <- tapply(res$residu, res$i, mean); tc <- tapply(res$residu, res$calendrier, mean)
             identical(as.numeric(ga$i), as.numeric(names(ta))) &&
               identical(as.numeric(gc$calendrier), as.numeric(names(tc))) &&
               identical(as.integer(ga$n), as.integer(table(res$i))) &&
               identical(as.integer(gc$n), as.integer(table(res$calendrier))) &&
               isTRUE(proche(ga$moyenne, unname(as.numeric(ta)), rel = 1e-10, abs = 1e-10)) &&
               isTRUE(proche(gc$moyenne, unname(as.numeric(tc)), rel = 1e-10, abs = 1e-10))
           })
  verifier("#312 : reserve2, effectifs et moyennes du par. 1.2 de la specification Fm (1e-5), somme des n = N = 27",
           identical(as.integer(ga$n), c(6L, 6L, 5L, 4L, 3L, 2L, 1L)) &&
             identical(as.integer(gc$n), c(1L, 2L, 3L, 4L, 5L, 6L, 6L)) &&
             sum(ga$n) == nrow(res) && sum(gc$n) == nrow(res) && nrow(res) == 27L &&
             isTRUE(proche(gc$moyenne, c(0.10811, -1.03213, -1.35373, -0.70681, 0.49849, 1.06507, -0.07445),
                           abs = 1e-5)) &&
             isTRUE(proche(ga$moyenne, c(-0.5047, -0.3665, -0.2242, 0.3175, 0.7853, 0.9015, 0.5111),
                           abs = 1e-4)))
  # Ligne du test des suites : texte de #514 (specification finale d'actuary),
  # qui remplace le texte T-1 de la specification Fm : phrase d'usage puis
  # phrase fixe des diagnostics par decision ; le motif d'effectifs n'y est
  # plus joint quand p_min n'est pas attribuee (p_min NA dans son champ).
  t1 <- paste("Detecte un regroupement ou une alternance des signes des residus de Mack, pour",
              "information. Diagnostic par decision, sans verdict ni p-value retenue : la ligne",
              "\"Autocorrelation des residus (Durbin-Watson)\", memes residus dans le meme",
              "ordre, fait foi.")
  lr <- Filter(function(l) identical(l$test, "Test des suites sur les residus de Mack"), r312$tests)
  verifier("#312 : test des suites, variante secondaire et diagnostic par decision (verdict INFO, inoperant FALSE, detail T-1 a la lettre)",
           length(lr) == 1L && {
             l <- lr[[1]]
             nzchar(t1) &&
               identical(l$type, "diagnostic") && identical(l$variante, "secondaire") &&
               identical(l$verdict, "INFO") && identical(l$inoperant, FALSE) &&
               identical(l$detail, t1) && is.na(l$p_retenue) && is.na(l$nature_p) &&
               is.na(l$sens) && identical(l$fonction, "test_runs")
           })
  verifier("#312 : test des suites, p_mc = bootstrap$p_mc[\"Runs\"], p non simulee conservee, p_min conservee, p_min_mc NA (R1 hors test)",
           length(lr) == 1L && {
             l <- lr[[1]]
             identical(l$p_mc, unname(r312$bootstrap$p_mc[["Runs"]])) && is.finite(l$p_mc) &&
               identical(l$p_asymptotique, test_runs(mw_residus(r312$ajustement)$residu)$p) &&
               is.finite(l$p_min) && is.na(l$p_min_mc) &&
               is.finite(r312$bootstrap$p_min_mc[["Runs"]])
           })
  # p Monte-Carlo absente : motif en tete du detail (pose par add(), forme de
  # .prefixe_motif_mc(), #358), puis T-1 ; statistique observee non
  # finie (motif MOTIF_MC_OBS_NON_FINIE) : priorite des motifs non
  # applicables, la ligne reste de type test et add() la rend non applicable.
  ligne_runs <- function(motif) {
    b <- r312$bootstrap
    b$p_mc[["Runs"]] <- NA_real_; b$motif_mc[["Runs"]] <- motif
    Filter(function(l) identical(l$test, "Test des suites sur les residus de Mack"),
           mw_tests(r312$ajustement, b, 0.10))[[1]]
  }
  verifier("#312 : p Monte-Carlo absente (replications insuffisantes) -> diagnostic, 'Monte-Carlo indisponible : <motif>.' puis T-1",
           {
             l <- ligne_runs(MOTIF_MC_REPLIC_INSUFFISANTES)
             # La phrase de #204 (B effectif) suit, jointe par l'enveloppe add() de
             # mw_tests() (bootstrap fictif : p absente avec B effectif = B).
             identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
               startsWith(l$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_REPLIC_INSUFFISANTES,
                                           ". ", t1))
           })
  verifier("#312 : motif de degenerescence -> '<motif> : aucune p-value retenue.' et complement, puis T-1",
           {
             l <- ligne_runs(MOTIF_MC_DISPERSION_NULLE)
             pre <- trimws(paste(c(paste0(MOTIF_MC_DISPERSION_NULLE, " : aucune p-value retenue."),
                                   .complement_motif_mc(MOTIF_MC_DISPERSION_NULLE)), collapse = " "))
             identical(l$type, "diagnostic") && startsWith(l$detail, .engine_joindre(pre, t1))
           })
  verifier("#312 : motif statistique observee non finie -> ligne non applicable (priorite des motifs non applicables), sans T-1",
           {
             l <- ligne_runs(MOTIF_MC_OBS_NON_FINIE)
             identical(l$type, "non applicable") && identical(l$verdict, "INFO") &&
               startsWith(l$detail, MOTIF_MC_OBS_NON_FINIE) && !grepl("#312", l$detail, fixed = TRUE)
           })
  # p_min non attribuee (constat de /code-review) : add() ne restitue
  # effectifs qu'aux lignes de type test ; sur le diagnostic, mw_tests() joint
  # le motif au detail (precedent de detail_diag() de usp_tests()), dans l'ordre
  # motif Monte-Carlo, effectifs, T-1. Aucun triangle recevable ne rend
  # runs_p_min() non fini (NA seulement si un cote de la mediane est vide) :
  # .mw_p_min_ligne() est substituee le temps d'un appel de mw_tests().
  ligne_runs_pmin_na <- function(b = r312$bootstrap) {
    # Substitution dans l'environnement du moteur (ADR 0016, #200).
    e <- environment(mw_tests)
    orig <- get(".mw_p_min_ligne", envir = e)
    on.exit(assign(".mw_p_min_ligne", orig, envir = e))
    assign(".mw_p_min_ligne", function(...) {
      o <- orig(...)
      list(p_min = NA_real_,
           effectifs = paste(o$effectifs, ", p_min non calculable sur ces effectifs, p_min non attribuee",
                             sep = ""))
    }, envir = e)
    Filter(function(l) identical(l$test, "Test des suites sur les residus de Mack"),
           mw_tests(r312$ajustement, b, 0.10))[[1]]
  }
  eff_ru <- .runs_effectifs(mw_residus(r312$ajustement)$residu)
  eff_txt <- paste0(paste(sprintf("%s = %d", names(eff_ru), as.integer(eff_ru)), collapse = ", "),
                    ", p_min non calculable sur ces effectifs, p_min non attribuee")
  # Mention M8 (correction d'actuary sur #514) : effectifs joints apres le
  # texte propre, point final.
  t1_eff <- paste(t1, paste0(eff_txt, "."))
  verifier("#312 / #514 : p_min non attribuee -> texte fixe du diagnostic puis effectifs en mention M8",
           {
             f0 <- .mw_p_min_ligne
             l <- ligne_runs_pmin_na()
             identical(l$type, "diagnostic") && is.na(l$p_min) &&
               identical(l$detail, t1_eff) &&
               identical(.mw_p_min_ligne, f0)
           })
  verifier("#312 : p_min non attribuee et p Monte-Carlo absente -> motif Monte-Carlo, texte fixe, effectifs (M8, #514)",
           {
             b <- r312$bootstrap
             b$p_mc[["Runs"]] <- NA_real_; b$motif_mc[["Runs"]] <- MOTIF_MC_REPLIC_INSUFFISANTES
             l <- ligne_runs_pmin_na(b)
             identical(l$type, "diagnostic") &&
               startsWith(l$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_REPLIC_INSUFFISANTES,
                                           ". ", t1_eff))
           })
})
verifier("#312 : colonne degeneree (tri_deg, j = 2) exclue des groupes comme dans mw_residus()",
         {
           r <- run_mw(tri_deg); pd <- r$plots_data
           rs <- mw_residus(mw_ajuster(tri_deg))
           !(2 %in% rs$j) && 2 %in% attr(rs, "colonnes_exclues")$j &&
             sum(pd$residus_acc_groupes$n) == nrow(rs) &&
             sum(pd$residus_cal_groupes$n) == nrow(rs) &&
             isTRUE(proche(pd$residus_acc_groupes$moyenne,
                           unname(as.numeric(tapply(rs$residu, rs$i, mean))), rel = 1e-10, abs = 1e-10)) &&
             isTRUE(proche(pd$residus_cal_groupes$moyenne,
                           unname(as.numeric(tapply(rs$residu, rs$calendrier, mean))), rel = 1e-10, abs = 1e-10))
         })
# Zero residu sous les deux formes : table de mw_residus() a zero ligne, et
# data.frame() sans colonne, sortie de .mw_empiler() quand aucune colonne
# ne donne de residu (constat C1 de l'audit de #312).
verifier("#312 : .mw_residus_par_groupe(), table vide (0 ligne, 3 colonnes, n entier) sur zero residu, y compris data.frame() sans colonne ; cle hors de i / calendrier refusee",
         {
           rs <- mw_residus(aj)[0, ]
           g0 <- .mw_residus_par_groupe(rs, "calendrier")
           vide <- function(g, cle) identical(names(g), c(cle, "n", "moyenne")) && nrow(g) == 0L &&
             is.integer(g$n) && is.numeric(g$moyenne)
           vide(g0, "calendrier") && vide(.mw_residus_par_groupe(data.frame(), "i"), "i") &&
             vide(.mw_residus_par_groupe(data.frame(), "calendrier"), "calendrier") &&
             inherits(try(.mw_residus_par_groupe(mw_residus(aj), "j"), silent = TRUE), "try-error")
         })
# Triangle non degenere : la valeur ne change pas (le minimum litteral est
# applique comme auparavant) et aucun avertissement n'est emis.
verifier("Triangle non degenere : sigma2_(J-1) inchange = min(...) et aucun avertissement",
         {
           ex <- mw_extrapolation_sigma2(aj)
           r <- run_engine(methode = "reserve2", triangle = tri,
                           segment = 1, annexe = "II", B = 99)
           identical(ex$degeneree, FALSE) && is.finite(ex$quotient) &&
             isTRUE(proche(aj$sigma2[4],
                           min(s2_main[3], s2_main[2], s2_main[3]^2 / s2_main[2]),
                           rel = 1e-8)) &&
             isTRUE(proche(ex$valeur, aj$sigma2[4], rel = 1e-14)) &&
             !any(grepl("sigma2_(J-3) = 0", r$validation$avertissements, fixed = TRUE))
         })
# Le critere de degenerescence porte sur les facteurs, non sur sigma2 teste
# en virgule flottante : une colonne constante a 1e-14 pres est detectee, une
# colonne reellement dispersee ne l'est pas.
verifier("Detection : colonne constante a 1e-14 pres detectee, colonne dispersee non",
         {
           t2 <- tri_deg
           t2[2, 4] <- t2[2, 3] * (1 + 1e-14)        # F(1,2) = 1 + 1e-14
           d1 <- mw_extrapolation_sigma2(mw_ajuster(t2))$degeneree
           t3 <- tri_deg
           t3[2, 4] <- t3[2, 3] * (1 + 1e-4)         # dispersion reelle
           d2 <- mw_extrapolation_sigma2(mw_ajuster(t3))$degeneree
           isTRUE(d1) && identical(d2, FALSE)
         })

## --- Triangle de Taylor & Ashe (1983) ----------------------------------------
# Donnees publiees (cumules), jeu GenIns de ChainLadder.
ta <- matrix(c(357848, 352118, 290507, 310608, 443160, 396132, 440832, 359480, 376686, 344014,
  1124788, 1236139, 1292306, 1418858, 1136350, 1333217, 1288463, 1421128, 1363294, NA,
  1735330, 2170033, 2218525, 2195047, 2128333, 2180715, 2419861, 2864498, NA, NA,
  2218270, 3353322, 3235179, 3757447, 2897821, 2985752, 3483130, NA, NA, NA,
  2745596, 3799067, 3985995, 4029929, 3402672, 3691712, NA, NA, NA, NA,
  3319994, 4120063, 4132918, 4381982, 3873311, NA, NA, NA, NA, NA,
  3466336, 4647867, 4628910, 4588268, NA, NA, NA, NA, NA, NA,
  3606286, 4914039, 4909315, NA, NA, NA, NA, NA, NA, NA,
  3833515, 5339085, NA, NA, NA, NA, NA, NA, NA, NA,
  3901463, NA, NA, NA, NA, NA, NA, NA, NA, NA), 10, 10)
at <- mw_ajuster(ta)
# ChainLadder 0.2.18 : MackChainLadder(GenIns, est.sigma = "Mack").
verifier("Taylor & Ashe : f_j = ChainLadder::MackChainLadder",
         proche(at$f, c(3.49060654793229, 1.74733264210049, 1.45741283601824, 1.17385170939979,
                        1.10382353224434, 1.08626936443639, 1.05387435550481, 1.07655517835294,
                        1.01772472521954), rel = 1e-12))
verifier("Taylor & Ashe : sigma_j^2 (extrapolation de Mack comprise) = ChainLadder",
         proche(at$sigma2, c(160280.327480486885, 37736.855047996425, 41965.213017424052,
                             15182.902680976453, 13731.323891978825, 8185.771620009637,
                             446.616550105362, 1147.365968428651, 446.616550105362), rel = 1e-10))
verifier("Taylor & Ashe : reserve totale = IBNR ChainLadder (18 680 855,61)",
         proche(at$reserve, 18680855.6119243, rel = 1e-12))

## --- MSEP a un an : conformite au texte (par. D(5)) -------------------------
# Transcription litterale du par. D(5) tel qu'imprime dans la version consolidee :
#   MSEP = somme_(i=1..I) C^(i,J)^2 * ( Q_(I-i)/C(i,I-i) + Delta_i )
#        + 2 * somme_(i=1..I) somme_(k=i+1..I) C^(i,J) C^(k,J) Delta_i,
#   Delta_i = Q_(I-i)/S_(I-i) + somme_(j=I-i+1..J-1) C(I-j,j)/S'_j * Q_j/S_j.
# Points de lecture verifies sur le texte officiel (issue #7, commentaire
# "M1 tranche sur piece") : bornes k = i+1..I, crochet indexe par I-i, facteur
# 2 present, exposant 1 sur C(I-j,j)/S'_j. Le crochet Delta_i figure DEUX fois,
# y compris a l'interieur de la premiere somme : ce sont ces termes diagonaux,
# et le facteur 2, que les transcriptions anterieures (moteur, documentation
# LaTeX, et la premiere version de cette fonction) omettaient.
msep_reglement <- function(a) {
  I <- a$I; J <- a$J; Cu <- a$C_chapeau[, J + 1]; Cd <- a$dernier_observe
  Delta <- function(i) {
    v <- a$Q[I - i + 1] / a$S[I - i + 1]
    if (I - i + 1 <= J - 1) for (j in (I - i + 1):(J - 1))
      v <- v + a$tri[I - j + 1, j + 1] / a$Sp[j + 1] * a$Q[j + 1] / a$S[j + 1]
    v
  }
  t1 <- sum(vapply(1:I, function(i)
    Cu[i + 1]^2 * (a$Q[I - i + 1] / Cd[i + 1] + Delta(i)), numeric(1)))
  t2 <- 0
  for (i in 1:I) if (i < I) for (k in (i + 1):I)
    t2 <- t2 + 2 * Cu[i + 1] * Cu[k + 1] * Delta(i)
  t1 + t2
}
# La transcription ci-dessus et la valeur externe Merz & Wuthrich (2008)
# coincident : les deux tests ci-dessous etaient en echec attendu (issue #7)
# tant que mw_msep() omettait les termes diagonaux et le facteur 2.
verifier("mw_msep = transcription litterale du par. D(5) tel qu'imprime",
         isTRUE(proche(mw_msep(at)$msep, msep_reglement(at), rel = 1e-10)) &&
         isTRUE(proche(mw_msep(aj)$msep, msep_reglement(aj), rel = 1e-10)))
verifier("racine(MSEP) = erreur a un an de Merz-Wuthrich (2008), ChainLadder::CDR",
         isTRUE(proche(sqrt(mw_msep(at)$msep), 1778967.66335758, rel = 1e-8)))
verifier("Decoupage restitue : terme_variance = variance de processus seule, somme des deux termes = MSEP",
         {
           m <- mw_msep(at)
           t1p <- sum(vapply(1:at$I, function(i)
             at$C_chapeau[i + 1, at$J + 1]^2 * at$Q[at$I - i + 1] /
               at$dernier_observe[i + 1], numeric(1)))
           isTRUE(proche(m$terme_variance, t1p, rel = 1e-12)) &&
             isTRUE(proche(m$terme_variance + m$terme_estimation,
                           msep_reglement(at), rel = 1e-10))
         })

## --- MSEP a un an : verification independante par matrice de coefficients (#50)
# Contre-implementation ecrite a partir du TRIANGLE BRUT, sans aucun appel au
# moteur (ni mw_*, ni objet d'ajustement aj$...), et sans les crochets Delta_i
# de mw_msep() / msep_reglement(). Forme (avis d'actuary sur #7, point 1.1 ;
# docs/specifications/e2-reduite.md, #50) :
#   a_ij = d ln C^{I+1}(i,J) / d ln F(I-j,j), au point F = f^, i = 1..I, j = 0..J-1 :
#          1 si j = I-i ; C(I-j,j)/S'_j si j > I-i ; 0 sinon ;
#   D_j  = Q_j * (1/C(I-j,j) + 1/S_j),  Q_j = sigma2_j / f_j^2 ;  u = (C^(i,J))_i ;
#   MSEP = somme_j D_j * (A' u)_j^2.
# Derivation elementaire (linearisation), pas une citation de Merz et
# Wuthrich (2008). Statut : verification NUMERIQUE d'une meme definition (la
# MSEP du texte consolide), pas une validation statistique de la MSEP a T = 8 :
# approximation lineaire dont la qualite a T = 8 n'est etablie par aucun
# resultat identifie.
msep_matrice <- function(tri) {
  tri <- unname(as.matrix(tri)); storage.mode(tri) <- "double"
  I <- nrow(tri) - 1L; J <- ncol(tri) - 1L
  # Facteurs individuels F(i,j) = C(i,j+1)/C(i,j), definis pour i + j + 1 <= I
  Fi <- tri[, -1L, drop = FALSE] / tri[, -(J + 1L), drop = FALSE]
  W <- tri[, -(J + 1L), drop = FALSE]          # poids C(i,j), colonnes j = 0..J-1
  W[is.na(Fi)] <- 0; Fi[is.na(Fi)] <- 0
  S  <- colSums(W)                             # S_j  = somme_{i=0}^{I-j-1} C(i,j)
  Sp <- colSums(tri[, -(J + 1L), drop = FALSE], na.rm = TRUE)  # S'_j = somme_{i=0}^{I-j}
  f  <- colSums(W * Fi) / S                    # moyenne des F(i,j) ponderee par C(i,j)
  n  <- colSums(W > 0)                         # nombre de facteurs de la colonne j
  # sigma2_j, j = 0..J-2 : somme_i C(i,j) (F(i,j) - f_j)^2 / (n_j - 1)
  s2 <- colSums(W * (Fi - rep(f, each = I + 1L))^2) / (n - 1)
  # Derniere colonne (un seul facteur) : regle min du par. D(5)(d)(ii), le
  # quotient s2_{J-2}^2 / s2_{J-3} etant pris infini si s2_{J-3} = 0 (le
  # minimum vaut alors s2_{J-3} = 0 quelle que soit sa valeur).
  a2 <- s2[J - 1L]; a3 <- s2[J - 2L]
  s2[J] <- min(a2, a3, if (a3 > 0) a2^2 / a3 else Inf)
  Q <- s2 / f^2
  diag_C <- tri[cbind(I + 1L - (0:(J - 1L)), 1:J)]   # C(I-j, j), j = 0..J-1
  # Ultimes : C^(i,J) = C(i,I-i) * produit_{j >= I-i} f_j, i = 1..I
  u <- vapply(1:I, function(i) tri[i + 1L, I - i + 1L] * prod(f[(I - i + 1L):J]), numeric(1))
  A <- matrix(0, I, J)
  for (i in 1:I) for (j in 0:(J - 1L)) {
    if (j == I - i) A[i, j + 1L] <- 1
    else if (j > I - i) A[i, j + 1L] <- diag_C[j + 1L] / Sp[j + 1L]
  }
  D <- Q * (1 / diag_C + 1 / S)
  list(msep = sum(D * as.vector(crossprod(A, u))^2), A = A, D = D, u = u,
       f = f, sigma2 = s2, Q = Q, S = S, Sp = Sp, C_diag = diag_C)
}

# Chain-ladder elementaire a un an : log des ultimes C^{I+1}(i,J), i = 1..I,
# quand la diagonale I+1 est F(I-j,j) = exp(lnF[j+1]) et que les facteurs sont
# re-estimes sur le triangle augmente. Sert a obtenir A par differences
# centrees, sans supposer la forme fermee des coefficients.
cl_ln_ultimes_un_an <- function(tri, lnF) {
  tri <- unname(as.matrix(tri)); I <- nrow(tri) - 1L; J <- ncol(tri) - 1L
  ext <- tri
  for (j in 0:(J - 1L)) ext[I - j + 1L, j + 2L] <- tri[I - j + 1L, j + 1L] * exp(lnF[j + 1L])
  f1 <- vapply(0:(J - 1L), function(j)
    sum(ext[1:(I - j + 1L), j + 2L]) / sum(ext[1:(I - j + 1L), j + 1L]), numeric(1))
  vapply(1:I, function(i)
    log(ext[i + 1L, I - i + 2L]) + sum(log(f1[(0:(J - 1L)) >= I - i + 1L])), numeric(1))
}
A_differences <- function(tri, f, h) {
  J <- length(f)
  vapply(1:J, function(j) {
    e <- replace(numeric(J), j, h)
    (cl_ln_ultimes_un_an(tri, log(f) + e) - cl_ln_ultimes_un_an(tri, log(f) - e)) / (2 * h)
  }, numeric(nrow(tri) - 1L))
}
msep_differences <- function(tri, h) {
  m <- msep_matrice(tri)
  sum(m$D * as.vector(crossprod(A_differences(tri, m$f, h), m$u))^2)
}

# Formules fautives historiques, recalculees localement a partir des memes
# grandeurs (issue #7, ADR 0005) : libelle publie en 2015 (double somme
# k = 1..I, crochet indexe par i, ni termes diagonaux du crochet dans la
# premiere somme ni facteur 2), et formule de mw_msep() avant cb7f497
# (k = i+1..I, sans termes diagonaux ni facteur 2).
msep_fautives <- function(tri) {
  m <- msep_matrice(tri); I <- length(m$u); J <- length(m$f)
  dl <- vapply(1:I, function(i) {
    j <- I - i; v <- m$Q[j + 1L] / m$S[j + 1L]
    if (j + 1L <= J - 1L) for (l in (j + 1L):(J - 1L))
      v <- v + m$C_diag[l + 1L] / m$Sp[l + 1L] * m$Q[l + 1L] / m$S[l + 1L]
    v
  }, numeric(1))
  proc <- sum(m$u^2 * m$Q[I - (1:I) + 1L] / m$C_diag[I - (1:I) + 1L])
  c(libelle_2015 = proc + sum(m$u * sum(m$u) * dl),
    moteur_avant_cb7f497 = proc + sum(vapply(1:I, function(i)
      m$u[i] * sum(m$u[seq_len(I) > i]) * dl[i], numeric(1))))
}
triangles_50 <- list(ta = ta, triangle_mw = local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
}), tri_deg = tri_deg)
msep_moteur_50 <- vapply(triangles_50, function(t) mw_msep(mw_ajuster(t))$msep, numeric(1))
verifier("msep_matrice = mw_msep()$msep a 1e-12 (Taylor & Ashe, triangle_mw.csv, tri_deg ; #50)",
         all(vapply(names(triangles_50), function(n)
           isTRUE(proche(msep_matrice(triangles_50[[n]])$msep, msep_moteur_50[[n]], rel = 1e-12)),
           logical(1))))
verifier("racine(msep_matrice(Taylor & Ashe)) = ChainLadder::CDR 1 778 967,66335758 a 1e-12 (#50)",
         proche(sqrt(msep_matrice(ta)$msep), 1778967.66335758, rel = 1e-12))
# Critere 3 rendu mecanique : evaluee dans un environnement qui ne voit que
# R base, la fonction rend le meme objet ; aucun nom du moteur n'y figure.
verifier("msep_matrice independante du moteur : identique evaluee sous baseenv(), aucun nom mw_/aj (#50)",
         {
           m0 <- msep_matrice; environment(m0) <- baseenv()
           noms <- all.names(body(msep_matrice))
           all(vapply(triangles_50, function(t) identical(m0(t), msep_matrice(t)), logical(1))) &&
             !any(grepl("^\\.?mw_|^engine_|^usp_|^run_engine$|^aj$", noms))
         })
# Mesure : ecart relatif du libelle 2015 a la MSEP +49 % / +15 % / +55 %, de
# l'ancien mw_msep() -27 % / -44 % / -22 % (ta / triangle_mw / tri_deg) ;
# sur Taylor & Ashe, racines 2 171 772 et 1 519 876 (valeurs de l'issue #7,
# arrondies a l'unite : d'ou la tolerance relative 1e-6).
verifier("msep_matrice s'ecarte d'au moins 1e-3 des formules fautives historiques (libelle 2015, ancien moteur ; #50)",
         all(vapply(triangles_50, function(t)
           all(abs(msep_fautives(t) / msep_matrice(t)$msep - 1) >= 1e-3), logical(1))) &&
           isTRUE(proche(sqrt(msep_fautives(ta)), c(2171772, 1519876), rel = 1e-6)))
# Ecarts mesures a h = 1e-4 : 3,0e-10 (ta), 2,6e-10 (triangle_mw), 1,1e-10
# (tri_deg). Ordre h^2 : rapport e(2e-3)/e(1e-3) = 4,000 a 3e-4 pres sur les
# trois triangles. En dessous de h ~ 2,5e-4, l'arrondi en eps/h pese autant
# que la troncature et fausse le rapport : il n'est donc pas mesure a 1e-4.
verifier("A par differences centrees (h = 1e-4) : MSEP a 1e-8 de mw_msep(), A a 1e-8, convergence en h^2 (#50)",
         all(vapply(names(triangles_50), function(n) {
           t <- triangles_50[[n]]; m <- msep_matrice(t); ref <- msep_moteur_50[[n]]
           e1 <- abs(msep_differences(t, 1e-4) / ref - 1)
           r <- abs(msep_differences(t, 2e-3) / ref - 1) /
             abs(msep_differences(t, 1e-3) / ref - 1)
           e1 <= 1e-8 && max(abs(A_differences(t, m$f, 1e-4) - m$A)) <= 1e-8 &&
             r >= 3.9 && r <= 4.1
         }, logical(1))))

## --- Restitution : ADR 0001, un diagnostic n'a pas de verdict ---------------
# CONTEXT.md : "Un diagnostic n'a pas de verdict (affiche INFO)." add() applique
# deja cette regle de lui-meme des que type != "test" ; le defaut ne peut donc
# naitre que d'un appelant qui FORCE un verdict par l'argument verdict = .
# mw_tests() lit du bootstrap p_mc et err_mc (add()), et B et B_effectif
# (.mw_phrase_b_effectif(), #204, refus explicite s'ils manquent), et
# cumuls_retires et plafond_cumuls (.mw_phrases_retirage(), #257, meme
# refus) : un objet fictif suffit, aucune simulation n'est necessaire ici ;
# B_effectif = B, aucun retirage, aucune phrase de #204 ni de #257.
boot_mw_fictif <- local({
  s <- .mw_stats(at)
  p <- stats::setNames(rep(0.5, length(s)), names(s))
  list(stats_obs = as.list(s), p_mc = p, err_mc = p * 0 + 0.01,
       B = 999, B_effectif = p * 0 + 999, cumuls_retires = FALSE, plafond_cumuls = FALSE)
})
lignes_mw <- mw_tests(at, boot_mw_fictif)
verifier("M6 concentration de la reserve : diagnostic sans verdict (ADR 0001)",
         {
           l <- Filter(function(x) grepl("^Part de la reserve", x$test), lignes_mw)
           length(l) == 1L && identical(l[[1]]$type, "diagnostic") &&
             identical(l[[1]]$verdict, "INFO")
         })
# Etait en echec attendu tant que la ligne M2 "Variance unitaire des residus
# de Mack" forcait un verdict ALERTE/OK ; elle sort INFO depuis que sa valeur
# de reference a ete corrigee. Marque retiree, test ordinaire.
# Etendu par #24 (ADR 0001, amendement du 23/09/2026) : toute ligne dont le
# type n'est pas "test" sort INFO ET sens NA (type "procedure de decision"
# retire, #357).
verifier("mw_tests : TOUT diagnostic sort en INFO, sens, p_retenue et nature_p NA (ADR 0001)",
         {
           faux <- Filter(function(l) !identical(l$type, "test") &&
                                      !(identical(l$verdict, "INFO") &&
                                          identical(l$sens, NA_character_) &&
                                          identical(l$p_retenue, NA_real_) &&
                                          identical(l$nature_p, NA_character_)), lignes_mw)
           if (!length(faux)) TRUE
           else paste("ligne non-test hors INFO / sens NA / p_retenue NA / nature_p NA :",
                      paste(vapply(faux, function(l) sprintf("%s -> %s / %s", l$test,
                                                             l$verdict, l$sens),
                                   character(1)), collapse = " ; "))
         })
# Depuis #300 (decision Q-D1-Fi-7 du 19/10/2026, visa du 21/10/2026), la
# ligne de Rosner sur residus de Mack est un diagnostic par decision, sans
# verdict ; le type "procedure de decision" est retire (#357) et son refus
# par add() est exerce sur le registre lognormal (test_defauts_connus.R).
verifier("ESD Merz-Wuthrich (#300) : diagnostic sans verdict (INFO, sens NA)",
         {
           e <- Filter(function(l) identical(l$test, "Cellules aberrantes multiples (ESD generalise)"), lignes_mw)
           length(e) == 1L && identical(e[[1]]$type, "diagnostic") &&
             identical(e[[1]]$verdict, "INFO") && identical(e[[1]]$sens, NA_character_)
         })
# Gardes de add() (revue d'audit du commit #24), exercees en reinjectant par
# texte (deparse) un appel fautif dans le corps de mw_tests(). Argument
# verdict retire par #484 : refuse par R comme argument inutilise (message
# localise, d'ou la recherche du seul texte de l'argument).
mw_tests_modifie <- function(avant, apres) {
  txt <- paste(deparse(mw_tests), collapse = "\n")
  if (!grepl(avant, txt, fixed = TRUE)) stop("motif absent du corps de mw_tests : ", avant)
  f <- eval(parse(text = sub(avant, apres, txt, fixed = TRUE)))
  environment(f) <- environment(mw_tests)
  f
}
erreur_mw <- function(f) tryCatch({ f(at, boot_mw_fictif); "" }, error = function(e) conditionMessage(e))
verifier("add() (mw_tests) refuse un verdict force sur un diagnostic (part de la reserve, verdict = 'OK')",
         {
           m <- erreur_mw(mw_tests_modifie('type = "diagnostic", estim_nom = "part"',
                                           'type = "diagnostic", verdict = "OK", estim_nom = "part"'))
           grepl('verdict = "OK"', m, fixed = TRUE)
         })
verifier("add() (mw_tests) refuse un verdict force sur le diagnostic de Rosner (#300)",
         {
           m <- erreur_mw(mw_tests_modifie('estim_nom = "nb de cellules declarees (repere de Rosner)"',
                                           'verdict = "OK", estim_nom = "nb de cellules declarees (repere de Rosner)"'))
           grepl('verdict = "OK"', m, fixed = TRUE)
         })
verifier("mw_tests : types en usage dans {test, diagnostic, non applicable} (#357)",
         {
           hors <- setdiff(unique(vapply(lignes_mw, function(l) l$type, character(1))),
                           c("test", "diagnostic", "non applicable"))
           if (length(hors)) paste("type hors vocabulaire :", paste(hors, collapse = ", ")) else TRUE
         })

# La contrainte qui fonde la valeur de reference du diagnostic M2 : sigma2_j
# etant l'estimateur de Mack, la somme des carres des residus vaut n_j - 1
# EXACTEMENT dans chaque colonne. Verifie colonne par colonne plutot que sur
# le total, qui pourrait coincider par compensation.
verifier("residus de Mack : somme_i r(i,j)^2 = n_j - 1 dans chaque colonne",
         {
           rs <- mw_residus(at)
           ecarts <- vapply(split(rs, rs$j), function(d) sum(d$residu^2) - (nrow(d) - 1),
                            numeric(1))
           isTRUE(proche(unname(ecarts), rep(0, length(ecarts)), abs = 1e-10, rel = 0))
         })

## --- Colonnes degenerees dans les verifications colonne par colonne de M1 ----
# Issue #56 (avis d'actuary du 24/09/2026). Une colonne eligible dont les
# facteurs individuels sont egaux a f_j a la tolerance relative 1e-12 de
# l'outil (ecart relatif au plus 1e-12, ou facteurs que l'aplatissement des
# ex aequo rend tous egaux ; predicat unique .mw_colonne_degeneree()) n'a pas
# de statistique definie (0/0), ou seulement un bruit d'arrondi : elle est exclue de la combinaison de Fisher, avant tout appel a
# lm(), dans l'observe comme dans chaque replication du bootstrap. Aucun
# avertissement R ne doit sortir de run_engine() (ni capture, ni masquage).
# ta_deg : Taylor & Ashe dont la colonne j = 4 est rendue degeneree (5
# facteurs individuels egaux a 1,05 ; cellules C(i,5), i = 0..4, remplacees,
# les autres inchangees). ta_bruit : la meme, colonne j = 4 perturbee de
# +/- 1e-14 en relatif (ecart relatif des facteurs ~1e-14 < 1e-12).
ta_deg <- ta
ta_deg[1:5, 6] <- 1.05 * ta[1:5, 5]
ta_bruit <- ta_deg
ta_bruit[1:5, 6] <- ta_deg[1:5, 6] * (1 + c(1, -1, 1, -1, 1) * 1e-14)
tri_ref <- local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
nb_warnings_mw <- function(t) {
  n <- 0L
  withCallingHandlers(run_engine(methode = "reserve2", triangle = t, segment = 1,
                                 annexe = "II", B = 99),
                      warning = function(w) { n <<- n + 1L; invokeRestart("muffleWarning") })
  n
}
verifier("Aucun avertissement R de run_engine(reserve2) sur triangle degenere ou de reference (#56)",
         {
           n <- vapply(list(tri_deg = tri_deg, tri_sym = tri_sym, tri_2 = tri_2,
                            tri_ach = tri_ach, ta_deg = ta_deg, ref = tri_ref),
                       nb_warnings_mw, integer(1))
           if (all(n == 0L)) TRUE
           else paste("avertissements R :", paste(names(n), n, sep = " = ", collapse = ", "))
         })
verifier("Predicat unique : .mw_colonne_degeneree() = degeneree_Jm3 / _Jm2 de mw_extrapolation_sigma2()",
         {
           ok <- vapply(list(tri_deg, tri_sym, tri_2, tri_ach, ta, ta_deg, tri_ref), function(t) {
             a <- mw_ajuster(t); ex <- mw_extrapolation_sigma2(a)
             identical(.mw_colonne_degeneree(a, a$J - 3L), ex$degeneree_Jm3) &&
               identical(.mw_colonne_degeneree(a, a$J - 2L), ex$degeneree_Jm2)
           }, logical(1))
           all(ok)
         })
verifier("tri_deg : colonne j = 2 exclue de l'ordonnee a l'origine, K = 2 sur 3 eligibles (#56)",
         {
           oo <- mw_test_ordonnee_origine(mw_ajuster(tri_deg))
           identical(oo$exclues$j, 2L) && identical(oo$exclues$n_facteurs, 3L) &&
             oo$K == 2 && oo$eligibles == 3L && !(2 %in% oo$detail$j) &&
             isTRUE(proche(oo$stat, 7.465589, rel = 1e-6))
         })
verifier("ta_deg : colonne j = 4 exclue des trois verifications de M1, K = 6 / 5 / 4 (#56)",
         {
           a <- mw_ajuster(ta_deg)
           oo <- mw_test_ordonnee_origine(a); cb <- mw_test_courbure(a)
           hf <- mw_test_homogeneite_f(a)
           # HomogF : K = 5 depuis #90 (la colonne j = 5, n = 4, rho = -1, p = 0
           # en Student, etait ecartee par .fisher_combine() : K = 4 avant)
           oo$K == 6 && cb$K == 5 && hf$K == 5 &&
             identical(oo$exclues$j, 4L) && identical(cb$exclues$j, 4L) &&
             identical(hf$exclues$j, 4L) &&
             !(4 %in% oo$detail$j) && !(4 %in% cb$detail$j) && !(4 %in% hf$detail$j)
         })
verifier("Stabilite au bruit : ta_deg perturbe de 1e-14 donne les memes X, K et tableaux (#56)",
         {
           a1 <- mw_ajuster(ta_deg); a2 <- mw_ajuster(ta_bruit)
           f <- list(mw_test_ordonnee_origine, mw_test_courbure, mw_test_homogeneite_f)
           ok <- vapply(f, function(g) {
             r1 <- g(a1); r2 <- g(a2)
             isTRUE(proche(r1$stat, r2$stat, rel = 1e-9)) && r1$K == r2$K &&
               identical(r1$exclues, r2$exclues) &&
               isTRUE(all.equal(r1$detail, r2$detail, tolerance = 1e-9))
           }, logical(1))
           .mw_ecart_facteurs(a2, 4L)$ecart > 0 && all(ok)
         })
# Ensemble fige a l'observe dans le bootstrap (#56, option (a) d'actuary,
# constats C1 / C2 de l'audit). ta_deg dont la colonne j = 4 est perturbee de
# +/- eps en relatif : ecart relatif des facteurs mesure 0, 5,64e-13,
# 1,02e-12 et 2,26e-12 pour eps = 0, 5e-13, 9e-13, 2e-12 (seuil 1e-12 : la
# colonne est degeneree a l'observe pour les deux premiers seulement). La
# derniere colonne j = J - 1 (un seul facteur, F = f_j) verifie trivialement
# le predicat et figure dans .mw_colonnes_degenerees() ; non eligible (moins
# de 3 facteurs), elle n'est jamais comptee parmi les exclues.
ta_pert <- function(eps) {
  t <- ta_deg
  t[1:5, 6] <- ta_deg[1:5, 6] * (1 + c(1, -1, 1, -1, 1) * eps)
  t
}
# Rejoue la boucle de mw_bootstrap() (meme graine, memes tirages) et rend,
# par replication, le K des verifications Origine et Courbure calcule avec
# l'ensemble fige a l'observe. Sert au test seulement : K par replication
# n'est pas expose dans le resultat. Les avertissements R eventuels sont
# comptes (element nw) ; nuls depuis #203 (assertion plus bas).
k_replications <- function(t, B = 99, seed = 20260831) {
  aj <- mw_ajuster(t); jd <- .mw_colonnes_degenerees(aj)
  # colonnes non identifiables de la courbure figees a l'observe, comme dans
  # mw_bootstrap() (#270)
  jni <- .mw_colonnes_courbure_non_identifiables(aj, jd)
  # colonnes non identifiables de l'ordonnee a l'origine figees de meme (#273)
  jno <- .mw_colonnes_origine_non_identifiables(aj, jd)
  Ko <- Kc <- rep(NA_integer_, B); nw <- 0L
  engine_sous_graine(seed, {
    pool <- .mw_pool_residus(aj, jd)   # pool de mw_bootstrap() (#46)
    # retirage et plafond de mw_bootstrap() (#257), fonction partagee
    n_max <- FACTEUR_B_MAX_MW * (B + 1); n_tir <- 0
    for (b in seq_len(B)) {
      tir <- .mw_tirer_triangle_valide(aj, pool, n_max - n_tir)
      n_tir <- n_tir + tir$n
      if (is.null(tb <- tir$tri)) next
      ab <- try(mw_ajuster(tb), silent = TRUE)
      if (inherits(ab, "try-error")) next
      withCallingHandlers({
        o <- mw_test_ordonnee_origine(ab, j_degeneres = jd, j_non_identifiables = jno)
        c2 <- mw_test_courbure(ab, j_degeneres = jd, j_non_identifiables = jni)
      }, warning = function(w) { nw <<- nw + 1L; invokeRestart("muffleWarning") })
      Ko[b] <- if (is.null(o$K)) NA_integer_ else as.integer(o$K)
      Kc[b] <- if (is.null(c2$K)) NA_integer_ else as.integer(c2$K)
    }
  })
  list(jd = jd, Ko = Ko, Kc = Kc, nw = nw)
}
# mw_bootstrap(B = 99) et rejeu, calcules une fois par perturbation (cache).
cache_pert <- new.env()
pert_calc <- function(e) {
  cle <- format(e)
  if (is.null(cache_pert[[cle]])) {
    t <- ta_pert(e); n <- 0L
    b <- withCallingHandlers(mw_bootstrap(mw_ajuster(t), B = 99),
                             warning = function(w) { n <<- n + 1L; invokeRestart("muffleWarning") })
    cache_pert[[cle]] <- list(a = mw_ajuster(t), n = n, b = b, kr = k_replications(t))
  }
  cache_pert[[cle]]
}
verifier("Bootstrap sans avertissement R, colonne j = 4 degeneree a l'observe (eps = 0, 5e-13 ; #56)",
         {
           n <- vapply(c(0, 5e-13), function(e) pert_calc(e)$n, integer(1))
           if (all(n == 0L)) TRUE else paste("avertissements :", paste(n, collapse = ", "))
         })
verifier("K identique entre observe et replications, colonne degeneree a l'observe (eps = 0, 5e-13 ; #56)",
         {
           ok <- vapply(c(0, 5e-13), function(e) {
             p <- pert_calc(e); a <- p$a; kr <- p$kr; b <- p$b
             identical(kr$jd, c(4L, a$J - 1L)) &&
               mw_test_ordonnee_origine(a)$K == 6 && mw_test_courbure(a)$K == 5 &&
               all(kr$Ko == 6) && all(kr$Kc == 5) &&
               all(b$B_effectif[c("Origine", "Courbure")] == 99)
           }, logical(1))
           all(ok)
         })
verifier("K identique entre observe et replications, colonne retenue a l'observe (eps = 9e-13, 2e-12 ; #56)",
         {
           ok <- vapply(c(9e-13, 2e-12), function(e) {
             p <- pert_calc(e); a <- p$a; kr <- p$kr; b <- p$b
             oo <- mw_test_ordonnee_origine(a)
             cb <- mw_test_courbure(a)
             # une replication ou la colonne j = 4 devient degeneree n'a pas de
             # statistique (NA), jamais un K different de l'observe ; le
             # nombre de NA du rejeu est celui que B_effectif ecarte.
             identical(kr$jd, a$J - 1L) && oo$K == 7 && cb$K == 6 && kr$nw == 0L &&
               all(is.na(kr$Ko) | kr$Ko == 7) && all(is.na(kr$Kc) | kr$Kc == 6) &&
               b$B_effectif[["Origine"]] <= 99 &&
               b$B_effectif[["Origine"]] == sum(!is.na(kr$Ko)) &&
               b$B_effectif[["Courbure"]] == sum(!is.na(kr$Kc))
           }, logical(1))
           all(ok)
         })
verifier("j_degeneres : colonne figee exclue meme non degeneree, colonne non figee degeneree -> NA (#56)",
         {
           ab <- mw_ajuster(ta)                        # colonne j = 4 non degeneree
           o1 <- mw_test_ordonnee_origine(ab, j_degeneres = 4L)
           ad <- mw_ajuster(ta_deg)                    # colonne j = 4 degeneree
           o2 <- mw_test_ordonnee_origine(ad, j_degeneres = integer(0))
           c2 <- mw_test_courbure(ad, j_degeneres = integer(0))
           h2 <- mw_test_homogeneite_f(ad, j_degeneres = integer(0))
           o1$K == 6 && identical(o1$exclues$j, 4L) && !(4 %in% o1$detail$j) &&
             is.na(o2$stat) && is.na(o2$K) && is.na(c2$stat) && is.na(c2$K) &&
             is.na(h2$stat) && is.na(h2$K)
         })
verifier("j_degeneres : f(aj) et f(aj, .mw_colonnes_degenerees(aj)) identiques (tri_ref, tri_deg ; #56)",
         {
           f <- list(mw_test_ordonnee_origine, mw_test_courbure, mw_test_homogeneite_f)
           ok <- vapply(list(tri_ref, tri_deg), function(t) {
             a <- mw_ajuster(t)
             all(vapply(f, function(g)
               identical(g(a), g(a, j_degeneres = .mw_colonnes_degenerees(a))), logical(1)))
           }, logical(1))
           a_d <- mw_ajuster(tri_deg); a_r <- mw_ajuster(tri_ref)
           all(ok) && identical(.mw_colonnes_degenerees(a_d), c(2L, a_d$J - 1L)) &&
             identical(.mw_colonnes_degenerees(a_r), a_r$J - 1L)
         })
verifier("Restitution : la colonne exclue est nommee dans le commentaire, estimation = K (#56)",
         {
           d <- engine_table_tests(run_mw(tri_deg))
           l <- d[grepl("ordonnee a l'origine", d$test), ]
           dr <- engine_table_tests(run_engine(methode = "reserve2", triangle = tri_ref,
                                               segment = 1, annexe = "II", B = 99))
           # Textes de #514 (specification finale d'actuary, M1).
           base_oo <- paste("Un ECHEC ou une ALERTE signale une composante fixe (ordonnee a l'origine)",
                            "dans au moins une colonne, contraire a la proportionnalite des cumules. A",
                            "lire avec \"Absence de tendance des facteurs avec le cumul, a colonne",
                            "donnee\" et \"Identifiabilite intra-colonne (dispersion des cumuls par",
                            "colonne)\", qui borne sa puissance.")
           nrow(l) == 1 && l$estimation == 2 &&
             grepl("Colonne degeneree", l$commentaire, fixed = TRUE) &&
             grepl("j = 2 (3 facteurs)", l$commentaire, fixed = TRUE) &&
             grepl("K = 2 colonne(s) testee(s) sur 3 eligible(s)", l$commentaire, fixed = TRUE) &&
             # A B = 99, les trois p Monte-Carlo (0,12 ; 0,08 ; 0,05) sont a moins
             # de 2 err_mc d'un seuil : phrase de #244 en dernier.
             identical(dr$commentaire[grepl("ordonnee a l'origine", dr$test)],
                       paste(base_oo, PHRASE_VERDICT_SENSIBLE_MC)) &&
             identical(dr$commentaire[grepl("Homogeneite de f_j", dr$test)],
                       paste("Un ECHEC ou une ALERTE signale des facteurs individuels qui derivent avec",
                             "l'annee de survenance, contraire a un f_j commun. A lire avec \"Effets",
                             "d'annee calendaire (test de Mack)\" et \"Homogeneite des residus entre",
                             "annees de survenance\".", PHRASE_VERDICT_SENSIBLE_MC)) &&
             identical(dr$commentaire[grepl("courbure", dr$test)],
                       paste("Un ECHEC ou une ALERTE signale une relation non lineaire entre cumuls",
                             "successifs, qui invalide la proportionnalite meme si la constante est nulle.",
                             "A lire avec \"Nullite de l'ordonnee a l'origine, colonne par colonne\".",
                             PHRASE_VERDICT_SENSIBLE_MC))
         })

## --- Courbure : colonne a 1 ddl residuel conservee (issue #234) ------------
# Decision Q-E2c-1 du mainteneur (11/10/2026), option A : la colonne a n = 4
# (3 parametres, 1 ddl residuel) reste VOLONTAIREMENT dans la combinaison de
# Fisher du test de courbure ; aucun changement de calcul. Sur reserve2
# (triangle_mw.csv) : K = 4, colonnes j = 0..3, n = (7, 6, 5, 4), j = 3
# incluse. t_j attendus : valeurs exactes calculees par actuary en
# arithmetique rationnelle (tolerance relative 1e-9). Les t_j lus dans
# $detail sont aussi recalcules par lm() hors de la fonction, et X = -2 somme
# log p_j, p_j bilaterale de Student a n - 3 ddl.
verifier("Courbure (#234, Q-E2c-1 option A) : reserve2, K = 4, j = 0..3, n = (7, 6, 5, 4), colonne j = 3 a 1 ddl incluse ; t_j = valeurs rationnelles a 1e-9 ; X = Fisher des p_j",
         {
           cb <- mw_test_courbure(mw_ajuster(tri_ref))
           dt <- cb$detail
           t_exact <- c(0.9342276499696924, -1.982363320600040,
                        -9.161812002906837, -3.462887950378827)
           # recalcul independant, selection de mw_test_courbure() (idx = 0..I-j-1)
           t_lm <- vapply(dt$j, function(j) {
             i <- seq_len(nrow(tri_ref) - j - 1)
             C0 <- tri_ref[i, j + 1]; C1 <- tri_ref[i, j + 2]
             summary(stats::lm(C1 ~ C0 + I(C0^2), weights = 1 / C0))$coefficients[3, 3]
           }, numeric(1))
           p_j <- 2 * stats::pt(-abs(dt$t), df = dt$n - 3)
           r <- list(
             K = identical(cb$K, 4L) && identical(cb$eligibles, 4L) && !nrow(cb$exclues),
             j = identical(as.integer(dt$j), 0:3),
             n = identical(as.integer(dt$n), c(7L, 6L, 5L, 4L)),
             ddl_j3 = isTRUE(any(dt$j == 3) && dt$n[dt$j == 3] - 3 == 1),
             t_exact = proche(dt$t, t_exact, rel = 1e-9),
             t_lm = proche(dt$t, t_lm, rel = 1e-12),
             p_j = proche(dt$p, p_j, rel = 1e-12),
             X = proche(cb$stat, -2 * sum(log(p_j)), rel = 1e-12),
             p = proche(cb$p, stats::pchisq(-2 * sum(log(p_j)), 8, lower.tail = FALSE),
                        rel = 1e-10))
           ko <- vapply(r, function(v) !isTRUE(v), logical(1))
           if (!any(ko)) TRUE else
             paste(names(r)[ko], vapply(r[ko], as.character, ""), sep = " : ", collapse = " ; ")
         })

## --- Domaine numerique des cumuls (issue #185) ------------------------------
# Toute cellule observee finie strictement positive hors de
# [DOMAINE_NUMERIQUE_MIN ; DOMAINE_NUMERIQUE_MAX] (bornes incluses) est
# refusee par mw_valider_triangle(), un seul motif par triangle. Avant #185,
# triangle_mw.csv x 1e-110 rendait ok = TRUE avec un sigma_USP faux de 0,5 %
# (mesure de l'issue). Dans le domaine, sigma_USP, p-values retenues et
# verdicts sont invariants par changement d'unite.
d185 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
m185 <- unname(as.matrix(d185[, setdiff(names(d185), "i")])); storage.mode(m185) <- "double"
motif185 <- "hors du domaine numerique"
refus185 <- function(t) {
  v <- mw_valider_triangle(t)
  isFALSE(v$ok) && sum(grepl(motif185, v$erreurs, fixed = TRUE)) == 1L
}
verifier("Domaine (#185) : triangle_mw x 10^e, e = -110, -60, -53, 47, 60, 101 -> refus, un seul motif, borne citee",
         {
           ok <- vapply(c(-110, -60, -53, 47, 60, 101), function(e) {
             v <- mw_valider_triangle(m185 * 10^e)
             msg <- grep(motif185, v$erreurs, fixed = TRUE, value = TRUE)
             borne <- if (e < 0) "borne inferieure" else "borne superieure"
             isFALSE(v$ok) && length(v$erreurs) == 1L && length(msg) == 1L &&
               grepl("en (i=0, j=", msg, fixed = TRUE) &&
               grepl(borne, msg, fixed = TRUE) &&
               # |e| >= 60 : les 36 cellules observees sont hors du domaine ;
               # e = -53, 47 : une partie seulement (10 et 26 cellules)
               grepl(sprintf("; %d cellules observees hors du domaine",
                             if (abs(e) >= 60) 36L else if (e == -53) 10L else 26L),
                     msg, fixed = TRUE) &&
               grepl("changement d'unite", msg, fixed = TRUE)
           }, logical(1))
           all(ok)
         })
verifier("Domaine (#185) : bornes exactes et juste a l'interieur acceptees, juste a l'exterieur refusees",
         {
           bas <- m185 / min(m185, na.rm = TRUE)       # plus petite cellule = 1
           haut <- m185 / max(m185, na.rm = TRUE)      # plus grande cellule = 1
           acc <- list(bas * DOMAINE_NUMERIQUE_MIN, haut * DOMAINE_NUMERIQUE_MAX,
                       bas * DOMAINE_NUMERIQUE_MIN * (1 + 1e-15),
                       haut * DOMAINE_NUMERIQUE_MAX * (1 - 1e-15), m185 * 1e-52, m185 * 1e46)
           ref <- list(bas * DOMAINE_NUMERIQUE_MIN * (1 - 1e-15),
                       haut * DOMAINE_NUMERIQUE_MAX * (1 + 1e-15))
           min(bas, na.rm = TRUE) == 1 && max(haut, na.rm = TRUE) == 1 &&
             all(vapply(acc, function(t) isTRUE(mw_valider_triangle(t)$ok), logical(1))) &&
             all(vapply(ref, refus185, logical(1)))
         })
verifier("Domaine (#185) : une seule cellule hors du domaine -> refus qui la cite, sans decompte ; autres motifs non masques",
         {
           t1 <- m185; t1[3, 2] <- 1e51                # (i=2, j=1)
           v1 <- mw_valider_triangle(t1)
           t2 <- m185; t2[3, 2] <- 1e-51; t2[1, 1] <- NA; t2[2, 3] <- -5
           v2 <- mw_valider_triangle(t2)
           l <- engine_lire_triangle(t1)
           isFALSE(v1$ok) && identical(v1$erreurs, sprintf(paste(
             "Cumul hors du domaine numerique [%g ; %g] en (i=2, j=1) : 1e+51 (> %g, borne superieure).",
             "sigma_USP et les tests sont invariants par un changement d'unite commun",
             "a toutes les cellules du triangle : exprimer les cumuls dans une unite",
             "qui les ramene dans le domaine."),
             DOMAINE_NUMERIQUE_MIN, DOMAINE_NUMERIQUE_MAX, DOMAINE_NUMERIQUE_MAX)) &&
             isFALSE(v2$ok) && length(v2$erreurs) == 3L &&
             any(grepl("Cellule observee manquante en (i=0, j=0)", v2$erreurs, fixed = TRUE)) &&
             any(grepl("Cumul non strictement positif en (i=1, j=2)", v2$erreurs, fixed = TRUE)) &&
             any(grepl("en (i=2, j=1) : 1e-51 (< 1e-50, borne inferieure).", v2$erreurs, fixed = TRUE)) &&
             isFALSE(l$ok) && is.null(l$triangle) && identical(l$erreurs, v1$erreurs)
         })
verifier("Domaine (#185) : run_engine reserve2, triangle_mw x 1e-110 et x 1e60 -> ok = FALSE, motif hors domaine, sans erreur R",
         all(vapply(c(-110, 60), function(e) {
           r <- run_engine(methode = "reserve2", triangle = m185 * 10^e,
                           segment = 1, annexe = "II", B = 99)
           isFALSE(r$ok) && inherits(r, "usp_engine") &&
             any(grepl(motif185, r$validation$erreurs, fixed = TRUE))
         }, logical(1))))
verifier("Domaine (#185) : invariance dans le domaine, x 1e-40 et x 1e40 : sigma_USP et p retenues = echelle 1 (rel 1e-6), verdicts identiques",
         {
           lancer <- function(e) run_engine(methode = "reserve2", triangle = m185 * 10^e,
                                            segment = 1, annexe = "II", B = 99)
           r0 <- lancer(0); d0 <- engine_table_tests(r0)
           # Ligne d'identifiabilite intra-colonne (#308), designee par son nom :
           # CV et e_a sont des rapports, invariants par changement d'echelle.
           nom308 <- "Identifiabilite intra-colonne (dispersion des cumuls par colonne)"
           l0 <- which(d0$test == nom308)
           ok <- vapply(c(-40, 40), function(e) {
             r <- lancer(e); d <- engine_table_tests(r)
             l1 <- which(d$test == nom308)
             isTRUE(r$ok) &&
               length(l0) == 1L && length(l1) == 1L &&
               identical(d$commentaire[l1], d0$commentaire[l0]) &&
               isTRUE(proche(d$estimation[l1], d0$estimation[l0], rel = 1e-12)) &&
               isTRUE(proche(r$parametre_final$sigma_usp, r0$parametre_final$sigma_usp,
                             rel = 1e-6)) &&
               identical(d$test, d0$test) && identical(d$verdict, d0$verdict) &&
               isTRUE(proche(d$p_retenue, d0$p_retenue, rel = 1e-6, abs = 1e-12))
           }, logical(1))
           isTRUE(r0$ok) && all(ok)
         })

## --- Avertissement "essentially perfect fit" de summary.lm() en M1 (#203) ---
# Le critere de cet avertissement depend de l'unite des cumules (ponderation
# 1/C(i,j) de l'ordonnee a l'origine et de la courbure) ; .mw_summary_lm()
# l'intercepte, lui seul, sans changer aucun resultat (objets run_engine()
# identical() avant / apres, mesure #203). Mesure avant #203, B = 199 :
# ta_pert(9e-13) 258 avertissements, triangle_mw x 1e20 : 20, x 1e46 : 1 814,
# tous de mw_test_ordonnee_origine() et mw_test_courbure().
avert203 <- function(expr) {
  w <- character(0)
  withCallingHandlers(expr, warning = function(x) {
    w <<- c(w, conditionMessage(x)); invokeRestart("muffleWarning") })
  w
}
verifier("summary.lm() en M1 (#203) : run_engine reserve2 sans aucun avertissement R, ta_pert(9e-13), triangle_mw x 1e20 et x 1e46 (B = 199)",
         {
           n <- vapply(list(ta_pert(9e-13), m185 * 1e20, m185 * 1e46), function(t)
             length(avert203(run_engine(methode = "reserve2", triangle = t,
                                        segment = 1, annexe = "II", B = 199))), integer(1))
           if (all(n == 0L)) TRUE else paste("avertissements :", paste(n, collapse = ", "))
         })
verifier(".mw_summary_lm() (#203) : resultat = summary() ; seul l'avertissement 'essentially perfect fit' de summary.lm() est intercepte",
         {
           x <- c(1, 2, 3, 4, 5); m <- stats::lm(I(2 * x) ~ x)    # ajustement parfait
           m2 <- m; m2$df.residual <- m2$df.residual + 1L       # autre avertissement de summary.lm()
           .S3method("summary", "faux203", function(object, ...) {
             warning("essentially perfect fit: summary may be unreliable"); "faux" })
           w0 <- avert203(summary(m)); w1 <- avert203(s1 <- .mw_summary_lm(m))
           w2 <- avert203(.mw_summary_lm(m2))
           w3 <- avert203(.mw_summary_lm({ warning("autre 203"); m }))
           w4 <- avert203(.mw_summary_lm(structure(list(), class = "faux203")))
           length(w0) == 1L && grepl("essentially perfect fit", w0) && length(w1) == 0L &&
             identical(s1, suppressWarnings(summary(m))) &&
             identical(w2, "residual degrees of freedom in object suggest this is not an \"lm\" fit") &&
             identical(w3, "autre 203") &&
             identical(w4, "essentially perfect fit: summary may be unreliable")
         })

## --- Triangle totalement degenere refuse (issue #192) -------------------------
# Decision du mainteneur du 05/10/2026 (Q-E2r-192-1, option A) : toutes les
# colonnes j = 0..J-2 degenerees au sens de .mw_colonne_degeneree() (#56) ->
# ok = FALSE, un seul motif (lecture de regulatory), sans avertissement de
# colonnes (Q-E2r-192-4). Triangles partiellement ou quasi degeneres inchanges
# (Q-E2r-192-3). Triangles d'essai reconstruits d'apres la specification
# (docs/specifications/e2-reduite.md, #192), a partir de triangle_mw.csv :
# - total_exact : C(i,0) de triangle_mw, F(i,j) = f_j de triangle_mw ;
# - total_f_binaire : facteurs 2, 1,5, 1,25... exactement representables
#   (sigma2_j = 0 exact ; avant #192 : pool de residus vide, defaut de calcul
#   intercepte dans engine_aplatir_ex_aequo() et deux avertissements R) ;
# - col0(eps) : total_exact, colonne 0 seule multipliee par 1 +/- eps (signes
#   alternes) ; ecart relatif des facteurs F(i,0) ~ 2 eps : degeneree a
#   1e-13, non degeneree a 1e-11 ;
# - sauf_une : total_exact dont la seule colonne j = 0 reprend les facteurs
#   observes de triangle_mw (construction propre a ce test : le prototype de
#   la specification, sigma_USP = 0,03778838, est perdu et n'est pas
#   reproduit ; meme classe : colonnes 1..6 degenerees, colonne 0 non) ;
# - total_arrondi : total_exact arrondi au centime (quasi degenere).
# sigma_USP des triangles acceptes : valeurs mesurees avant #192 (B = 99,
# segment II-1 ; sigma_USP ne depend pas de B), inchangees apres.
f192 <- mw_ajuster(tri_ref)$f
tri192 <- function(c0, f) {
  n <- length(c0); t <- matrix(NA_real_, n, n); t[, 1] <- c0
  for (i in 1:(n - 1)) for (j in 2:(n - i + 1)) t[i, j] <- t[i, j - 1] * f[j - 1]
  t
}
total_exact <- tri192(tri_ref[, 1], f192)
total_f_binaire <- tri192(c(256, 300, 320, 336, 344, 352, 360, 384),
                          c(2, 1.5, 1.25, 1.125, 1.0625, 1.03125, 1.015625))
col0_192 <- function(eps) {
  t <- total_exact; t[, 1] <- t[, 1] * (1 + rep(c(1, -1), 4) * eps); t
}
sauf_une <- total_exact
sauf_une[, 2] <- tri_ref[, 2]
for (i in 1:6) for (j in 3:(9 - i)) sauf_une[i, j] <- sauf_une[i, j - 1] * f192[j - 1]
total_arrondi <- round(total_exact, 2)
refuses192 <- list(total_exact = total_exact, total_f_binaire = total_f_binaire,
                   col0_1e13 = col0_192(1e-13))
acceptes192 <- list(col0_1e11 = col0_192(1e-11), sauf_une = sauf_une,
                    total_arrondi = total_arrondi)
sigma192 <- c(col0_1e11 = 0.0369, sauf_une = 0.0404017443, total_arrondi = 0.0369031172)
fragments192 <- c("Triangle totalement degenere : pour chaque annee de developpement j = 0..J-2",
                  paste0("(a la tolerance relative 1e-12 de l'outil pres : ",
                         .MW_PREDICAT_DEGENERE_TEXTE, ")"),
                  "Pour des facteurs exactement egaux, en arithmetique exacte, sigma2_j = 0 (annexe XVII, D(5)(d)(ii)) et MSEP = 0 ; ici sigma2_j et la MSEP (valeur calculee : ",
                  ") sont nuls ou negligeables a la tolerance de l'outil (residus d'arrondi ou ecarts relatifs entre facteurs de l'ordre de 1e-12), aucun residu de Mack n'est retenu",
                  "par D(4), sigma(res,s,USP) = (1 - c) * sigma(res,s) a un ecart negligeable pres, sans contribution significative des donnees.",
                  "(D(2)(h), en particulier iv : variance proportionnelle au cumul precedent)",
                  "representativite du risque de reserve (D(2)(a))",
                  "article 219, paragraphe 1, point d)",
                  "L'outil n'applique donc pas a ce triangle la methode du risque de reserve no 2 (article 220, paragraphe 1, point b)).",
                  "paiements cumules observes (D(1))")
motif192 <- function(e) length(e) == 1L &&
  all(vapply(fragments192, grepl, logical(1), x = e, fixed = TRUE)) &&
  !grepl("0/0", e, fixed = TRUE)
# Avertissements de colonnes emis par mw_valider_ajustement() : extrapolation
# de sigma2_(J-1) et colonnes exclues des residus de Mack.
av_colonnes192 <- function(av) c(av_extrap(list(validation = list(avertissements = av))),
                                 av_exclues(av))
verifier("Predicat #192 sur des ajustements fictifs : vrai ssi j = 0..J-2 degenerees ; FALSE si objet reduit ou J < 2",
         {
           fict <- function(tri, f) list(I = nrow(tri) - 1L, J = ncol(tri) - 1L,
                                         f = f, tri = tri)
           tt <- matrix(NA_real_, 4, 4)
           tt[, 1] <- c(100, 200, 400, 800)
           for (i in 1:3) for (j in 2:(5 - i)) tt[i, j] <- tt[i, j - 1] * c(2, 1.5, 1.25)[j - 1]
           tp <- tt; tp[2, 3] <- tp[2, 3] * 1.01         # colonne j = 1 non degeneree
           tq <- tt; tq[1, 4] <- tq[1, 4] * 1.01         # colonne J-1 seule : sans effet
           f_tq <- c(2, 1.5, tq[1, 4] / tq[1, 3])
           isTRUE(.mw_triangle_totalement_degenere(fict(tt, c(2, 1.5, 1.25)))) &&
             isFALSE(.mw_triangle_totalement_degenere(fict(tp, c(2, 1.5, 1.25)))) &&
             isTRUE(.mw_triangle_totalement_degenere(fict(tq, f_tq))) &&
             isFALSE(.mw_triangle_totalement_degenere(list(I = 4L, reserve = 10))) &&
             isFALSE(.mw_triangle_totalement_degenere(list(I = 0L, J = 1L, f = 1.5,
                                                         tri = matrix(c(100, 150), 1, 2)))) &&
             isFALSE(.mw_triangle_totalement_degenere(list(I = 0L, J = 0L, f = numeric(0),
                                                         tri = matrix(100, 1, 1))))
         })
verifier("Predicat #192 : faux sur les triangles des tests existants et sur les acceptes, vrai sur les refuses",
         {
           faux <- c(lapply(list(tri, tri_deg, tri_sym, tri_2, tri_ach, tri_j1, ta, ta_deg,
                                 ta_bruit, tri_ref, tri_decroissant), mw_ajuster),
                     lapply(acceptes192, mw_ajuster))
           !any(vapply(faux, .mw_triangle_totalement_degenere, logical(1))) &&
             all(vapply(lapply(refuses192, mw_ajuster), .mw_triangle_totalement_degenere,
                        logical(1)))
         })
verifier("mw_valider_ajustement() : triangle totalement degenere refuse, un seul motif, aucun avertissement de colonnes (#192)",
         all(vapply(refuses192, function(t) {
           a <- mw_ajuster(t); v <- mw_valider_ajustement(a, mw_msep(a)$msep)
           isFALSE(v$ok) && motif192(v$erreurs) && !length(v$avertissements)
         }, logical(1))))
verifier("run_engine : total_exact, total_f_binaire, col0_1e13 -> ok = FALSE, motif #192, sans erreur R ni avertissement R",
         all(vapply(refuses192, function(t) {
           nw <- 0L
           r <- withCallingHandlers(run_engine(methode = "reserve2", triangle = t, segment = 1,
                                               annexe = "II", B = 99),
                                    warning = function(w) { nw <<- nw + 1L
                                      invokeRestart("muffleWarning") })
           inherits(r, "usp_engine") && identical(r$ok, FALSE) && isFALSE(r$validation$ok) &&
             is.null(r$validation$erreur_r) && motif192(r$validation$erreurs) &&
             !length(av_colonnes192(r$validation$avertissements)) &&
             is.null(r$parametre_final) && is.null(r$tests) && nw == 0L
         }, logical(1))))
verifier("run_engine : col0_1e11, sauf_une, total_arrondi acceptes, sigma_USP inchange (#192, Q-E2r-192-3)",
         all(vapply(names(acceptes192), function(nm) {
           r <- run_engine(methode = "reserve2", triangle = acceptes192[[nm]], segment = 1,
                           annexe = "II", B = 99)
           isTRUE(r$ok) && is.null(r$validation$erreur_r) &&
             !any(grepl("Triangle totalement degenere", r$validation$erreurs, fixed = TRUE)) &&
             isTRUE(proche(r$parametre_final$sigma_usp, sigma192[[nm]], rel = 1e-8))
         }, logical(1))))
verifier("Reserve nulle (tous les f_j = 1, triangle totalement degenere) : seul le motif R = 0 (#192)",
         {
           tz <- matrix(NA_real_, 5, 5)
           for (i in 1:5) for (j in 1:(6 - i)) tz[i, j] <- 100 + 10 * i
           r <- run_engine(methode = "reserve2", triangle = tz, segment = 1, annexe = "II", B = 99)
           isTRUE(.mw_triangle_totalement_degenere(mw_ajuster(tz))) && identical(r$ok, FALSE) &&
             any(grepl("R = 0", r$validation$erreurs, fixed = TRUE)) &&
             !any(grepl("Triangle totalement degenere", r$validation$erreurs, fixed = TRUE))
         })

## --- Ex aequo des statistiques de rang de Merz-Wuthrich (issue #152) --------
# Triangle construit : F(0,0) = 7373,22 / 5236,68 et F(1,0) = 1228,87 / 872,78
# sont egaux en decimal (meme paire a -> b, k a -> k b) mais distincts en
# flottant. Autres facteurs de la colonne 0 : 1,20, 1,30, 1,50, 1,55, 1,60 ;
# colonnes suivantes : facteurs choisis ci-dessous (cadence decroissante,
# distincts dans chaque colonne), cumuls arrondis au centime.
tri152 <- local({
  c0 <- c(5236.68, 872.78, 800, 1500, 2200, 950, 1800, 1200)
  fac <- list(c(NA, NA, 1.20, 1.30, 1.50, 1.55, 1.60),  # j = 0 (lignes 2 a 6)
              c(1.10, 1.12, 1.08, 1.15, 1.09, 1.11),    # j = 1
              c(1.05, 1.04, 1.06, 1.03, 1.07),          # j = 2
              c(1.02, 1.03, 1.01, 1.025),               # j = 3
              c(1.010, 1.008, 1.012),                   # j = 4
              c(1.005, 1.003),                          # j = 5
              c(1.002))                                 # j = 6
  t <- matrix(NA_real_, 8, 8); t[, 1] <- c0
  t[1, 2] <- 7373.22; t[2, 2] <- 1228.87
  for (i in 3:7) t[i, 2] <- round(c0[i] * fac[[1]][i], 2)
  for (j in 2:7) for (i in 1:(8 - j)) t[i, j + 1] <- round(t[i, j] * fac[[j]][i], 2)
  t
})
# Garde : la paire est bien distincte en flottant (sinon le cas ne teste rien).
stopifnot(tri152[1, 2] / tri152[1, 1] != tri152[2, 2] / tri152[2, 1])
aj152 <- mw_ajuster(tri152)
# Les cinq statistiques concernees, par leurs fonctions du moteur.
stats152 <- function(a) c(
  Calendrier = mw_test_annees_calendaires(a)$stat,
  CorrDev    = mw_stat_correlation_dev(a)$stat,
  HomogF     = mw_test_homogeneite_f(a)$stat,
  ExpVar     = mw_test_exposant_variance(a)$stat,
  KruskalAcc = mw_test_homogeneite_accident(a)$stat)
# Recomputation independante, sur des valeurs arrondies a 12 chiffres
# significatifs (signif) au lieu de l'aplatissement du moteur. Seuls
# .mack_moments_Z() (moments exacts de Z, hors objet du test) et
# mw_residus() sont repris du moteur.
recalc152 <- function(t) {
  I <- nrow(t) - 1; J <- ncol(t) - 1
  Fcol <- function(j) { i <- 0:(I - j - 1); signif(t[i + 1, j + 2] / t[i + 1, j + 1], 12) }
  # Calendrier : etiquettes par la mediane de chaque colonne
  et <- do.call(rbind, lapply(0:(J - 1), function(j) {
    i <- 0:(I - j - 1); if (length(i) < 2) return(NULL)
    F <- Fcol(j); md <- median(F)
    data.frame(d = i + j, lab = ifelse(F > md, "L", ifelse(F < md, "S", "*")))
  }))
  et <- et[et$lab != "*", ]
  A <- t(vapply(split(et$lab, et$d), function(v) {
    L <- sum(v == "L"); S <- sum(v == "S"); m <- .mack_moments_Z(L + S)
    c(min(L, S), m[["E"]], m[["V"]], L + S)
  }, numeric(4)))
  A <- A[A[, 4] >= 2, , drop = FALSE]
  cal <- (sum(A[, 1]) - sum(A[, 2])) / sqrt(sum(A[, 3]))
  # CorrDev : Spearman entre colonnes adjacentes, pondere par n - 1
  cd <- do.call(rbind, lapply(1:(J - 1), function(k) {
    i <- 0:(I - k - 1); if (length(i) < 3) return(NULL)
    a <- signif(t[i + 1, k + 1] / t[i + 1, k], 12); b <- signif(t[i + 1, k + 2] / t[i + 1, k + 1], 12)
    if (sd(a) == 0 || sd(b) == 0) return(NULL)
    c(cor(rank(a), rank(b)), length(i) - 1)
  }))
  corr <- sum(cd[, 1] * cd[, 2]) / sum(cd[, 2])
  # p de Spearman par colonne (#90) : loi de permutation a n <= 9 sans ex
  # aequo (au bit pres apres signif()) ; avec ex aequo a n <= 9 (#207),
  # enumeration brute des n! permutations sur les rangs moyens, doublement ;
  # sinon Student relevee a 2/n!
  p_sp <- function(a, b) {
    n <- length(a); ea <- anyDuplicated(a) || anyDuplicated(b)
    if (n <= 9 && ea) {
      prm <- function(v) if (length(v) <= 1) list(v) else
        do.call(c, lapply(seq_along(v), function(i) lapply(prm(v[-i]), function(q) c(v[i], q))))
      A <- 2 * rank(a); B <- 2 * rank(b)
      D <- vapply(prm(seq_len(n)), function(pi) sum(A * B[pi]), numeric(1))
      d0 <- sum(A * B)
      return(min(1, 2 * min(sum(D <= d0), sum(D >= d0)) / length(D)))
    }
    ex <- n <= 9 && !ea
    min(1, max(2 / factorial(n),
               suppressWarnings(cor.test(a, b, method = "spearman", exact = ex)$p.value)))
  }
  # HomogF : Fisher sur les p-values de Spearman F ~ i
  ph <- unlist(lapply(0:(J - 1), function(j) {
    i <- 0:(I - j - 1); if (length(i) < 4) return(NULL)
    p_sp(Fcol(j), i)
  }))
  # ExpVar et KruskalAcc : sur les residus de Mack (r et C arrondis)
  res <- mw_residus(mw_ajuster(t))
  pe <- unlist(lapply(unique(res$j), function(j) {
    d <- res[res$j == j, ]; Cs <- signif(d$C, 12)
    if (nrow(d) < 4 || sd(Cs) == 0) return(NULL)
    p_sp(signif(abs(d$residu), 12), Cs)
  }))
  kw <- kruskal.test(signif(res$residu, 12), factor(res$i))$statistic
  c(Calendrier = cal, CorrDev = corr, HomogF = -2 * sum(log(ph)),
    ExpVar = -2 * sum(log(pe)), KruskalAcc = unname(kw))
}
verifier("Ex aequo F (#152) : rangs (3,5 ; 3,5) de la paire, moteur (aplatissement plancher 0) et recomputation signif(F, 12)",
         {
           F0 <- tri152[1:6, 2] / tri152[1:6, 1]
           identical(rank(engine_aplatir_ex_aequo(F0, plancher = 0))[1:2], c(3.5, 3.5)) &&
             identical(rank(signif(F0, 12))[1:2], c(3.5, 3.5))
         })
verifier("Ex aequo F (#152) : etiquette '*' pour F(0,0) et F(1,0), egaux a la mediane (calendrier)",
         {
           e <- mw_test_annees_calendaires(aj152)$etiquettes
           identical(e$lab[e$j == 0 & e$i %in% 0:1], c("*", "*")) &&
             sum(e$lab[e$j == 0] == "*") == 2L
         })
verifier("Ex aequo F (#152) : cinq statistiques = recomputation independante sur signif(., 12)",
         proche(stats152(aj152), recalc152(tri152), rel = 1e-12))
verifier("Ex aequo F (#152) : statistiques du catalogue (bootstrap) = statistiques de mw_tests()",
         {
           b <- mw_bootstrap(aj152, B = 19)
           tt <- mw_tests(aj152, b)
           f <- c(Calendrier = "mw_test_annees_calendaires", CorrDev = "mw_stat_correlation_dev",
                  HomogF = "mw_test_homogeneite_f", ExpVar = "mw_test_exposant_variance",
                  KruskalAcc = "mw_test_homogeneite_accident")
           st_t <- vapply(f, function(fn)
             Filter(function(l) identical(l$fonction, fn), tt)[[1]]$stat, numeric(1))
           identical(unname(unlist(b$stats_obs[names(f)])), unname(st_t)) &&
             identical(unname(st_t), unname(stats152(aj152)))
         })
# Le triangle construit ci-dessus n'a d'ex aequo ni en C, ni en |r|, ni en r :
# il n'exerce pas l'aplatissement d'ExpVar et de KruskalAcc, que couvre le
# triangle d'invariance ci-dessous.
# Invariance : triangle_mw.csv avec C(4,1) = C(3,1) et C(4,2) = C(3,2), d'ou
# F(4,1) = F(3,1), C(4,1) = C(3,1) et r(4,1) = r(3,1) exactement ; C(4,1)
# multiplie par (1 + 4 eps) rend ces egalites seulement approchees.
tri_mw <- local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
tri_eg <- tri_mw; tri_eg[5, 2] <- tri_eg[4, 2]; tri_eg[5, 3] <- tri_eg[4, 3]
tri_pert <- tri_eg; tri_pert[5, 2] <- tri_eg[5, 2] * (1 + 4 * .Machine$double.eps)
verifier("Ex aequo (#152) : C(4,1) x (1 + 4 eps) laisse les cinq statistiques identical()",
         {
           a_eg <- mw_ajuster(tri_eg); a_pe <- mw_ajuster(tri_pert)
           r_eg <- mw_residus(a_eg); r_pe <- mw_residus(a_pe)
           k <- function(r) which(r$j == 1 & r$i %in% 3:4)
           # Garde : la perturbation rompt bien l'egalite flottante de C, F et r
           tri_pert[5, 2] != tri_eg[5, 2] &&
             tri_pert[5, 3] / tri_pert[5, 2] != tri_pert[4, 3] / tri_pert[4, 2] &&
             r_pe$residu[k(r_pe)][1] != r_pe$residu[k(r_pe)][2] &&
             r_eg$residu[k(r_eg)][1] == r_eg$residu[k(r_eg)][2] &&
             identical(stats152(a_eg), stats152(a_pe))
         })
verifier("Ex aequo (#152) : triangle sans ex aequo (triangle_mw.csv), aplatissement sans effet",
         {
           a <- mw_ajuster(tri_mw); I <- a$I; J <- a$J; res <- mw_residus(a)
           Fs <- lapply(0:(J - 1), function(j) {
             i <- 0:(I - j - 1); tri_mw[i + 1, j + 2] / tri_mw[i + 1, j + 1] })
           all(vapply(Fs, function(F) identical(engine_aplatir_ex_aequo(F, plancher = 0), F),
                      logical(1))) &&
             all(vapply(split(res, res$j), function(d)
               identical(engine_aplatir_ex_aequo(d$C, plancher = 0), d$C) &&
                 identical(engine_aplatir_ex_aequo(abs(d$residu)), abs(d$residu)),
               logical(1))) &&
             identical(engine_aplatir_ex_aequo(res$residu), res$residu) &&
             all(is.finite(stats152(a)))
         })

fin_fichier()
