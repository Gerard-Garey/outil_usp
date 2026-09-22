###############################################################################
#  tests/unitaires/test_merz_wuthrich.R  --  METHODE DU RISQUE DE RESERVE No 2
#
#  mw_ajuster(), mw_msep(), mw_residus() : annexe XVII, section D, par. 4 et 5
#  de la VERSION CONSOLIDEE en vigueur. La pagination "JOUE L 12/277-278" qui
#  circulait ici n'a jamais ete verifiee (ADR 0005) : elle est retiree.
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
# alors 0 et le minimum litteral donne 0 sans aucune garde ; la colonne J-3
# n'etant pas degeneree, aucun avertissement n'est emis.
tri_sym <- matrix(NA_real_, 6, 6)
tri_sym[1, ] <- c(1000, 1600, 1800, 1900, 1938, 1945)
tri_sym[2, 1:5] <- c(1100, 1815, 2000, 2150, 2193)
tri_sym[3, 1:4] <- c(900, 1395, 1580, 1650)
tri_sym[4, 1:3] <- c(1200, 1980, 2210)
tri_sym[5, 1:2] <- c(1050, 1638)
tri_sym[6, 1]   <- 980
verifier("sigma2_(J-2) = 0 avec sigma2_(J-3) > 0 : sigma2_(J-1) = 0, sans avertissement",
         {
           a <- mw_ajuster(tri_sym)
           ex <- mw_extrapolation_sigma2(a)
           r <- run_engine(methode = "reserve2", triangle = tri_sym,
                           segment = 1, annexe = "II", B = 99)
           a$sigma2[a$J - 1] < 1e-12 && a$sigma2[a$J - 2] > 1e-3 &&
             a$sigma2[a$J] < 1e-12 && ex$quotient < 1e-12 &&
             identical(ex$degeneree, FALSE) &&
             identical(ex$retenu, "sigma2_(J-2)") &&
             isTRUE(r$ok) &&
             !any(grepl("sigma2_(J-3) = 0", r$validation$avertissements, fixed = TRUE))
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
echec_attendu("mw_tests : TOUT diagnostic sort en INFO (ADR 0001)",
              "ligne M2 'Variance unitaire des residus de Mack' : verdict ALERTE/OK force par l'appelant",
              {
                faux <- Filter(function(l) identical(l$type, "diagnostic") &&
                                           !identical(l$verdict, "INFO"), lignes_mw)
                if (!length(faux)) TRUE
                else paste("verdict non INFO :",
                           paste(vapply(faux, function(l) sprintf("%s -> %s", l$test, l$verdict),
                                        character(1)), collapse = " ; "))
              })

fin_fichier()
