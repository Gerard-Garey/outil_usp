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
           m$terme_variance >= 0 && m$terme_covariance >= 0 &&
             isTRUE(proche(m$msep, m$terme_variance + m$terme_covariance))
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
             grepl("sigma2_(J-3) = 0 ;", l, fixed = TRUE) &&
             grepl("minimum atteint par sigma2_(J-3)", l, fixed = TRUE)
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
# de l'issue #60, Q-E2r-60-2).
av_exclues <- function(av) grep(paste0("a facteurs individuels tous egaux a f_j a 1e-12 pres ",
                                       "en relatif (sigma2_j nul ou numeriquement nul)"), av,
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
             grepl("facteurs individuels tous egaux", detail_m6(r), fixed = TRUE) &&
             grepl("nul par voie de consequence", detail_m6(r), fixed = TRUE) &&
             # Depuis #33, l'absence de residus est dite par l'avertissement
             # general sur les colonnes exclues, et non plus par celui-ci.
             !grepl("n'ont pas de residu de Mack", av, fixed = TRUE) &&
             any(grepl("j = 3 (2 facteurs). Le residu de Mack y vaut 0/0",
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
             grepl("minimum atteint par sigma2_(J-2) et sigma2_(J-3) (ex aequo)", l,
                   fixed = TRUE) &&
             grepl("Colonnes J-3 et J-2 a facteurs individuels tous egaux", l,
                   fixed = TRUE) &&
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
               sum(grepl("n'ont pas de residu de Mack", av, fixed = TRUE)) == 1 &&
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
             grepl("nul par voie de consequence", detail_m6(r), fixed = TRUE) &&
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
             !grepl("n'ont pas de residu de Mack", av, fixed = TRUE) &&
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
             grepl("Colonne de developpement a facteurs individuels tous egaux", av, fixed = TRUE) &&
             grepl("j = 1 (4 facteurs)", av, fixed = TRUE) &&
             grepl(sprintf("ces 4 facteurs individuels n'ont pas de residu de Mack et sont exclus ; %d residu(s)",
                           nrow(rs)), av, fixed = TRUE) &&
             grepl(.MW_LIGNES_RESIDUS_TEXTE, av, fixed = TRUE) &&
             !any(grepl("sigma2_(J-1) = min", r$validation$avertissements, fixed = TRUE))
         })
verifier("Colonnes exclues : une seule phrase par triangle, J-3 / J-2 compris (tri_deg, tri_sym, tri_2)",
         all(vapply(list(tri_deg, tri_sym, tri_2), function(t) {
           av <- run_mw(t)$validation$avertissements
           length(av_exclues(av)) == 1 &&
             sum(grepl("n'ont pas de residu de Mack", av, fixed = TRUE)) == 1
         }, logical(1))) &&
         grepl("Colonnes de developpement a facteurs individuels tous egaux", av_exclues(run_mw(tri_2)$validation$avertissements),
               fixed = TRUE))
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
             assign("mw_residus", function(aj, j_degeneres = NULL) perturb(orig(aj, j_degeneres)),
                    envir = globalenv())
             L1 <- tryCatch(mw_tests(aj, boot),
                            finally = assign("mw_residus", orig, envir = globalenv()))
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
           if (identical(mw_residus, orig) && setequal(mesure, cite) && length(cite) == 11) TRUE
           else paste("mesure :", paste(mesure, collapse = " ; "))
         })
# Triangle de non-regression (tests/donnees/triangle_mw.csv) : aucune des
# deux colonnes n'est degeneree, et le detail M6 est celui de la reference
# versionnee au caractere pres (l'issue #21 ne le modifie pas).
verifier("Triangle de non-regression : colonnes J-3 et J-2 non degenerees, detail M6 = reserve2.rds",
         {
           d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
           m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"
           ex <- mw_extrapolation_sigma2(mw_ajuster(unname(m)))
           ref <- readRDS(file.path(RACINE, "tests", "reference", "reserve2.rds"))
           k <- which(vapply(ref$tests, function(x) identical(
             x$test, "Extrapolation de sigma pour la derniere annee de developpement"),
             logical(1)))
           ex$ecart_relatif > 1e-3 && ex$ecart_relatif_Jm2 > 1e-3 &&
             identical(ex$degeneree_Jm3, FALSE) && identical(ex$degeneree_Jm2, FALSE) &&
             identical(ex$degeneree, FALSE) && length(k) == 1 &&
             identical(.mw_detail_extrapolation(ex), ref$tests[[k]]$detail)
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
             isTRUE(proche(m$terme_variance + m$terme_covariance,
                           msep_reglement(at), rel = 1e-10))
         })

## --- Restitution : ADR 0001, un diagnostic n'a pas de verdict ---------------
# CONTEXT.md : "Un diagnostic n'a pas de verdict (affiche INFO)." add() applique
# deja cette regle de lui-meme des que type != "test" ; le defaut ne peut donc
# naitre que d'un appelant qui FORCE un verdict par l'argument verdict = .
# mw_tests() ne lit du bootstrap que p_mc et err_mc : un objet fictif suffit,
# aucune simulation n'est necessaire ici.
boot_mw_fictif <- local({
  s <- .mw_stats(at)
  p <- stats::setNames(rep(0.5, length(s)), names(s))
  list(stats_obs = as.list(s), p_mc = p, err_mc = p * 0 + 0.01)
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
# type n'est ni "test" ni "procedure de decision" sort INFO ET sens NA.
verifier("mw_tests : TOUT diagnostic sort en INFO, sens, p_retenue et nature_p NA (ADR 0001)",
         {
           faux <- Filter(function(l) !l$type %in% c("test", "procedure de decision") &&
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
verifier("ESD Merz-Wuthrich (procedure de decision) : verdict OK / ALERTE / ECHEC, sens 'ne pas rejeter'",
         {
           e <- Filter(function(l) identical(l$type, "procedure de decision"), lignes_mw)
           length(e) == 1L &&
             identical(e[[1]]$test, "Cellules aberrantes multiples (ESD generalise)") &&
             e[[1]]$verdict %in% c("OK", "ALERTE", "ECHEC") &&
             identical(e[[1]]$sens, "ne pas rejeter")
         })
# Gardes de add() (revue d'audit du commit #24), exercees en reinjectant par
# texte (deparse) un appel fautif dans le corps de mw_tests().
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
           grepl("un verdict n'est admis que pour type = 'test' ou 'procedure de decision'", m, fixed = TRUE) &&
             grepl("Part de la reserve portee par la derniere annee d'accident", m, fixed = TRUE)
         })
verifier("add() (mw_tests) refuse une procedure de decision sans verdict (ESD)",
         {
           m <- erreur_mw(mw_tests_modifie("verdict = if (ro$nb_outliers >= 2)",
                                           "verdict = if (TRUE) NULL else if (ro$nb_outliers >= 2)"))
           grepl("une ligne de type 'procedure de decision' doit fournir son verdict", m, fixed = TRUE) &&
             grepl("Cellules aberrantes multiples (ESD generalise)", m, fixed = TRUE)
         })
verifier("mw_tests : types en usage dans {test, diagnostic, non applicable, procedure de decision}",
         {
           hors <- setdiff(unique(vapply(lignes_mw, function(l) l$type, character(1))),
                           c("test", "diagnostic", "non applicable", "procedure de decision"))
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
# facteurs individuels sont tous egaux a f_j (a 1e-12 pres en relatif,
# predicat unique .mw_colonne_degeneree()) n'a pas de statistique definie
# (0/0) : elle est exclue de la combinaison de Fisher, avant tout appel a
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
           oo$K == 6 && cb$K == 5 && hf$K == 4 &&
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
# comptes (element nw), non asserts ici (voir plus bas).
k_replications <- function(t, B = 99, seed = 20260831) {
  aj <- mw_ajuster(t); jd <- .mw_colonnes_degenerees(aj)
  Ko <- Kc <- rep(NA_integer_, B); nw <- 0L
  engine_sous_graine(seed, {
    res <- mw_residus(aj); pool <- res$residu - mean(res$residu)
    for (b in seq_len(B)) {
      tb <- mw_simuler_triangle(aj, pool)
      if (anyNA(tb[upper.tri(tb, diag = TRUE)[, rev(seq_len(ncol(tb)))]])) next
      ab <- try(mw_ajuster(tb), silent = TRUE)
      if (inherits(ab, "try-error")) next
      withCallingHandlers({
        o <- mw_test_ordonnee_origine(ab, j_degeneres = jd)
        c2 <- mw_test_courbure(ab, j_degeneres = jd)
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
             oo <- suppressWarnings(mw_test_ordonnee_origine(a))
             cb <- suppressWarnings(mw_test_courbure(a))
             # une replication ou la colonne j = 4 devient degeneree n'a pas de
             # statistique (NA), jamais un K different de l'observe ; le
             # nombre de NA du rejeu est celui que B_effectif ecarte.
             identical(kr$jd, a$J - 1L) && oo$K == 7 && cb$K == 6 &&
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
           base_oo <- paste("La regression ponderee SANS constante et de poids 1/C(i,j) a pour",
                            "estimateur exactement f_j (identite de Mack, verifiee a 1e-16).",
                            "Ajouter une constante fournit donc le test naturel de la",
                            "proportionnalite, colonne par colonne.")
           nrow(l) == 1 && l$estimation == 2 &&
             grepl("Colonne degeneree", l$commentaire, fixed = TRUE) &&
             grepl("j = 2 (3 facteurs)", l$commentaire, fixed = TRUE) &&
             grepl("K = 2 colonne(s) testee(s) sur 3 eligible(s)", l$commentaire, fixed = TRUE) &&
             identical(dr$commentaire[grepl("ordonnee a l'origine", dr$test)], base_oo) &&
             identical(dr$commentaire[grepl("Homogeneite de f_j", dr$test)],
                       "Correlation de rang entre F(i,j) et i, colonne par colonne, combinee par Fisher") &&
             identical(dr$commentaire[grepl("courbure", dr$test)],
                       "Une courbure invalide la linearite meme si la constante est nulle")
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
           ok <- vapply(c(-40, 40), function(e) {
             r <- lancer(e); d <- engine_table_tests(r)
             isTRUE(r$ok) &&
               isTRUE(proche(r$parametre_final$sigma_usp, r0$parametre_final$sigma_usp,
                             rel = 1e-6)) &&
               identical(d$test, d0$test) && identical(d$verdict, d0$verdict) &&
               isTRUE(proche(d$p_retenue, d0$p_retenue, rel = 1e-6, abs = 1e-12))
           }, logical(1))
           isTRUE(r0$ok) && all(ok)
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
                  "(a la tolerance relative 1e-12 de l'outil pres)",
                  "En arithmetique exacte, sigma2_j = 0 (annexe XVII, D(5)(d)(ii)), MSEP = 0 (valeur calculee : ",
                  "aucun residu de Mack n'est defini",
                  "par D(4), sigma(res,s,USP) = (1 - c) * sigma(res,s)",
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
  # HomogF : Fisher sur les p-values de Spearman F ~ i
  ph <- unlist(lapply(0:(J - 1), function(j) {
    i <- 0:(I - j - 1); if (length(i) < 4) return(NULL)
    suppressWarnings(cor.test(Fcol(j), i, method = "spearman", exact = FALSE)$p.value)
  }))
  # ExpVar et KruskalAcc : sur les residus de Mack (r et C arrondis)
  res <- mw_residus(mw_ajuster(t))
  pe <- unlist(lapply(unique(res$j), function(j) {
    d <- res[res$j == j, ]; Cs <- signif(d$C, 12)
    if (nrow(d) < 4 || sd(Cs) == 0) return(NULL)
    suppressWarnings(cor.test(signif(abs(d$residu), 12), Cs,
                              method = "spearman", exact = FALSE)$p.value)
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

## --- Colonnes degenerees exclues des residus de Mack (issue #60) ------------
# Decision du mainteneur du 05/10/2026 (Q-E2r-60-1, variante (b)) :
# mw_residus() ecarte une colonne sur le predicat .mw_colonne_degeneree()
# (#56) et non plus sur sigma2_j = 0 exact ; l'ensemble des colonnes
# degenerees est fige au triangle observe par mw_bootstrap() et transmis aux
# residus de chaque replication (contexte .mw_contexte_mc(), ExpVar,
# KruskalAcc). Predicat etendu (constat C1 de l'audit de #152) : colonne
# rendue constante par l'aplatissement des ex aequo en plancher 0.
verifier("ta_bruit : colonne j = 4 exclue des residus (39 retenus, comme ta_deg), avertissement emis (#60)",
         {
           ok <- vapply(list(ta_deg, ta_bruit), function(t) {
             a <- mw_ajuster(t); rs <- mw_residus(a)
             av <- av_exclues(mw_valider_ajustement(a, mw_msep(a)$msep)$avertissements)
             nrow(rs) == 39L && !any(rs$j == 4) &&
               identical(attr(rs, "colonnes_exclues")$j, 4L) &&
               length(av) == 1 && grepl("j = 4 (5 facteurs)", av, fixed = TRUE) &&
               grepl("Le pool de reechantillonnage du bootstrap ne contient que les residus retenus",
                     av, fixed = TRUE)
           }, logical(1))
           # garde : sigma2_4 de ta_bruit est strictement positif (bruit d'arrondi)
           mw_ajuster(ta_bruit)$sigma2[5] > 0 && all(ok)
         })
verifier("mw_residus(aj, j_degeneres) : ensemble fourni prioritaire, NULL = ensemble calcule sur aj (#60)",
         {
           a <- mw_ajuster(ta); ad <- mw_ajuster(ta_deg)
           r1 <- mw_residus(a, j_degeneres = 4L)            # colonne non degeneree, figee
           r2 <- mw_residus(ad, j_degeneres = integer(0))   # sigma2_4 = 0 : exclue quand meme
           identical(mw_residus(ad), mw_residus(ad, .mw_colonnes_degenerees(ad))) &&
             identical(mw_residus(a), mw_residus(a, .mw_colonnes_degenerees(a))) &&
             !any(r1$j == 4) && identical(attr(r1, "colonnes_exclues")$j, 4L) &&
             !any(r2$j == 4) && identical(attr(r2, "colonnes_exclues")$j, 4L)
         })
# Rejeu de la boucle de mw_bootstrap() : nombre de residus du contexte de
# chaque replication (ensemble fige), a comparer a l'observe.
n_res_replications <- function(t, B = 99, seed = 20260831) {
  aj <- mw_ajuster(t); jd <- .mw_colonnes_degenerees(aj); n <- rep(NA_integer_, B)
  engine_sous_graine(seed, {
    res <- mw_residus(aj, jd); pool <- res$residu - mean(res$residu)
    for (b in seq_len(B)) {
      tb <- mw_simuler_triangle(aj, pool)
      if (anyNA(tb[upper.tri(tb, diag = TRUE)[, rev(seq_len(ncol(tb)))]])) next
      ab <- try(mw_ajuster(tb), silent = TRUE)
      if (inherits(ab, "try-error")) next
      n[b] <- nrow(.mw_contexte_mc(ab, jd)$res)
    }
  })
  list(obs = nrow(mw_residus(aj)), n = n)
}
verifier("Bootstrap : meme nombre de residus a l'observe et dans chaque replication (ta_deg, tri_sym ; #60)",
         all(vapply(list(ta_deg, tri_sym), function(t) {
           m <- n_res_replications(t)
           any(!is.na(m$n)) && all(is.na(m$n) | m$n == m$obs)
         }, logical(1))))
# Critere conjoint #60 + #152 (specification (c) 3 et 4), B = 99 ici ; mesure
# aussi a B = 999 (compte rendu de #60). Tolerance 1e-6 (TOLERANCE des
# references).
tables_mw60 <- local({
  cache <- list()
  function(nm, t) {
    if (is.null(cache[[nm]])) cache[[nm]] <<- engine_table_tests(run_mw(t))
    cache[[nm]]
  }
})
memes_p <- function(d1, d2) {
  p1 <- d1$p_retenue; p2 <- d2$p_retenue
  identical(d1$test, d2$test) && identical(d1$verdict, d2$verdict) &&
    identical(is.na(p1), is.na(p2)) &&
    isTRUE(all(abs(p1 - p2)[!is.na(p1)] <= 1e-6 * pmax(1, abs(p1[!is.na(p1)]))))
}
verifier("run_engine : ta_deg et ta_bruit, memes verdicts et memes p retenues (#60 avec #152)",
         memes_p(tables_mw60("ta_deg", ta_deg), tables_mw60("ta_bruit", ta_bruit)))
verifier("run_engine : ta_deg perturbe a 4e-13 (colonne j = 4 degeneree), p-values de ta_deg (#60, gel)",
         {
           t4 <- ta_pert(4e-13); a4 <- mw_ajuster(t4)
           d0 <- tables_mw60("ta_deg", ta_deg); d4 <- tables_mw60("ta_4e13", t4)
           .mw_ecart_facteurs(a4, 4L)$ecart > 0 && 4L %in% .mw_colonnes_degenerees(a4) &&
             memes_p(d0, d4) &&
             identical(d0$p_monte_carlo, d4$p_monte_carlo)
         })
# Triangle a facteurs binaires (#192) dont seule la colonne j = 5 est rendue
# non degeneree (C(0,6) x 1,01, ligne 0 repropagee) : accepte, pool de deux
# residus (cas bin_pert_j5 d'actuary, specification de #192, Q3).
bin_pert_j5 <- local({
  m <- total_f_binaire; m[1, 7] <- m[1, 7] * 1.01
  m[1, 8] <- m[1, 7] * (total_f_binaire[1, 8] / total_f_binaire[1, 7]); m
})
verifier("bin_pert_j5 : accepte, mw_residus() non vide (2 residus, colonne j = 5), aucun avertissement R (#60)",
         {
           a <- mw_ajuster(bin_pert_j5); rs <- mw_residus(a)
           nw <- 0L
           r <- withCallingHandlers(run_mw(bin_pert_j5),
                                    warning = function(w) { nw <<- nw + 1L
                                      invokeRestart("muffleWarning") })
           identical(.mw_colonnes_degenerees(a), c(0:4, 6L)) &&
             nrow(rs) == 2L && all(rs$j == 5L) &&
             isTRUE(r$ok) && is.null(r$validation$erreur_r) && nw == 0L
         })
# Constat C1 de l'audit de #152 : colonne 0 a facteurs 1,5 (1 + 0,9e-12 k),
# k = 0..6 : ecart relatif a f_0 superieur a 1e-12, mais facteurs aplatis
# tous egaux (pas adjacent 0,9e-12 < 1e-12). Avant #60 : non degeneree,
# rho = NA silencieux dans HomogF et K variable entre observe et
# replications ; residus de bruit d'arrondi gardes.
tri_c1 <- local({
  t <- matrix(NA_real_, 8, 8)
  t[, 1] <- c(1000, 1200, 900, 1500, 1100, 1300, 1250, 950)
  fac0 <- 1.5 * (1 + (0:6) * 0.9e-12)
  for (i in 1:7) t[i, 2] <- t[i, 1] * fac0[i]
  fac <- list(NULL, c(1.10, 1.12, 1.08, 1.15, 1.09, 1.11), c(1.05, 1.04, 1.06, 1.03, 1.07),
              c(1.02, 1.03, 1.01, 1.025), c(1.010, 1.008, 1.012), c(1.005, 1.003), 1.002)
  for (j in 2:7) for (i in 1:(8 - j)) t[i, j + 1] <- round(t[i, j] * fac[[j]][i], 2)
  t
})
verifier("Colonne aplatie constante (C1) : degeneree, exclue de HomogF et des residus, sans rho = NA (#60)",
         {
           a <- mw_ajuster(tri_c1); jd <- .mw_colonnes_degenerees(a)
           h <- mw_test_homogeneite_f(a); rs <- mw_residus(a)
           # replications : K + nombre de p nulles ecartees par .fisher_combine()
           # (Spearman asymptotique a rho = +-1 pour n = 4, issue #90) = 3,
           # aucun rho = NA
           kk <- integer(0); nna <- 0L
           engine_sous_graine(20260831, {
             pool <- rs$residu - mean(rs$residu)
             for (b in 1:99) {
               tb <- mw_simuler_triangle(a, pool)
               if (anyNA(tb[upper.tri(tb, diag = TRUE)[, rev(seq_len(ncol(tb)))]])) next
               ab <- try(mw_ajuster(tb), silent = TRUE)
               if (inherits(ab, "try-error")) next
               hb <- mw_test_homogeneite_f(ab, jd)
               if (is.null(hb$K)) next
               kk <- c(kk, hb$K + sum(hb$detail$p == 0)); nna <- nna + sum(is.na(hb$detail$rho))
             }
           })
           .mw_ecart_facteurs(a, 0L)$ecart > 1e-12 && .mw_colonne_degeneree(a, 0L) &&
             identical(jd, c(0L, a$J - 1L)) &&
             identical(h$exclues$j, 0L) && h$K == 3 && !anyNA(h$detail$rho) &&
             !any(rs$j == 0) && length(kk) > 0 && all(kk == 3L) && nna == 0L
         })
verifier("Exposant de variance : colonne a |r| constants ecartee (aucun rho = NA) (#60)",
         {
           # colonne j = 0 : F = 1,5 + s / racine(C), signes s = (+, -, -, +),
           # racines 10, 20, 30, 40 : somme s racine(C) = 0, donc f_0 = 1,5 et
           # |r(i,0)| tous egaux
           tr <- matrix(NA_real_, 5, 5)
           tr[, 1] <- c(100, 400, 900, 1600, 2500)
           tr[1:4, 2] <- tr[1:4, 1] * (1.5 + c(1, -1, -1, 1) / sqrt(tr[1:4, 1]))
           fs <- list(c(1.20, 1.25, 1.22), c(1.05, 1.08), 1.02)
           for (j in 2:4) for (i in 1:(5 - j)) tr[i, j + 1] <- tr[i, j] * fs[[j - 1]][i]
           a <- mw_ajuster(tr); rs <- mw_residus(a); ev <- mw_test_exposant_variance(a)
           r0 <- abs(rs$residu[rs$j == 0])
           length(r0) == 4L && length(unique(engine_aplatir_ex_aequo(r0))) == 1L &&
             !(0 %in% ev$detail$j) && !anyNA(ev$detail$rho)
         })
verifier("Aucun avertissement R de run_engine(reserve2) : ta_bruit, tri_c1, t5 (#60)",
         {
           t5 <- tri_sym
           t5[1, 4] <- 1760.07; t5[2, 4] <- 2554.89
           t5[1, 5] <- 1760.07 * 1.187; t5[2, 5] <- 2554.89 * 1.187
           t5[1, 6] <- t5[1, 5] * 1.003
           n <- vapply(list(ta_bruit = ta_bruit, tri_c1 = tri_c1, t5 = t5), nb_warnings_mw, integer(1))
           if (all(n == 0L)) TRUE
           else paste("avertissements R :", paste(names(n), n, sep = " = ", collapse = ", "))
         })

fin_fichier()
