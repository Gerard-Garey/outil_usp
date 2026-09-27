###############################################################################
#  tests/unitaires/test_statistiques.R  --  STATISTIQUES DE TEST ET P-VALUES
#  NON EXACTES
#
#  Normalite (AD, CvM, KS, Lilliefors, Shapiro-Francia, Jarque-Bera,
#  D'Agostino), independance (DW, suites, Cox-Stuart), heteroscedasticite
#  (Breusch-Pagan, White, Goldfeld-Quandt, Brown-Forsythe), specification
#  (RESET, TOST), ruptures (sup-F), valeurs aberrantes (Grubbs).
#  References : definitions integrales calculees analytiquement, stats::
#  (ks.test, lm, anova, t.test, confint), valeurs de lmtest / tseries / car
#  ecrites en dur (voir generer_valeurs_externes.R), simulation a graine fixe
#  pour les approximations de Stephens et de Dallal-Wilkinson.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_statistiques.R")

z1 <- c(0.52, -1.31, 0.87, 1.64, -0.23, -0.95, 0.31, -0.48)
z2 <- c(1.2, 1.5, 0.9, 0.4, -0.3, -0.8, -1.1, -1.6)
za <- c(2.9, -0.4, 0.1, -0.6, 0.3, -0.2, 0.05, -0.35)    # asymetrique, queue lourde
x_ln <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)  # tests/donnees
y_ln <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)

## --- Anderson-Darling et Cramer-von Mises : definitions integrales ----------
# A2 = n int_0^1 (F_n - u)^2 / (u (1 - u)) du et W2 = n int_0^1 (F_n - u)^2 du,
# F_n constante par morceaux entre les u_(k) = pnorm(z_(k)). Primitives
# exactes sur [a, b] avec F_n = c :
#   int (c - u)^2 / (u (1 - u)) = -(b - a) + c^2 ln(b / a) - (1 - c)^2 ln((1 - b) / (1 - a))
#   int (c - u)^2               = ((b - c)^3 - (a - c)^3) / 3
integrales_edf <- function(z) {
  n <- length(z); u <- c(0, stats::pnorm(sort(z)), 1)
  A <- W <- 0
  for (k in 0:n) {
    a <- u[k + 1]; b <- u[k + 2]; c <- k / n
    t1 <- if (c > 0) c^2 * log(b / a) else 0
    t2 <- if (c < 1) (1 - c)^2 * log((1 - b) / (1 - a)) else 0
    A <- A + (-(b - a) + t1 - t2)
    W <- W + ((b - c)^3 - (a - c)^3) / 3
  }
  c(A2 = n * A, W2 = n * W)
}
for (k in 1:3) {
  z <- list(z1, z2, za)[[k]]; ref <- integrales_edf(z)
  verifier(sprintf("AD = definition integrale (serie %d)", k),
           proche(stat_ad(z), ref[["A2"]], rel = 1e-10))
  verifier(sprintf("CvM = definition integrale (serie %d)", k),
           proche(stat_cvm(z), ref[["W2"]], rel = 1e-10))
}

## --- Kolmogorov-Smirnov et Lilliefors ----------------------------------------
for (k in 1:3) {
  z <- list(z1, z2, za)[[k]]
  verifier(sprintf("KS contre N(0,1) = ks.test (serie %d)", k),
           proche(stat_ks(z), stats::ks.test(z, "pnorm")$statistic, rel = 1e-12))
  verifier(sprintf("Lilliefors = ks.test sur l'echantillon standardise (serie %d)", k),
           proche(stat_lilliefors(z),
                  stats::ks.test((z - mean(z)) / stats::sd(z), "pnorm")$statistic, rel = 1e-12))
}
verifier("Lilliefors : invariant par z -> a + b z (b > 0) ; NA si ecart-type nul",
         isTRUE(proche(stat_lilliefors(10 + 4 * za), stat_lilliefors(za), rel = 1e-12)) &&
         is.na(stat_lilliefors(rep(1, 8))))

## --- Approximations de Stephens et de Dallal-Wilkinson : calibration ---------
# Loi nulle simulee (graine fixe, 10 000 echantillons normaux, T = 8) ; AD et
# CvM calcules avec parametres ESTIMES (cas 3 de Stephens). Tolerance
# 0,01 + 0,06 p : couvre l'erreur Monte-Carlo (<= 0,005) et l'erreur propre
# des approximations publiees (observee <= 0,03 a la mediane), mais detecte
# une erreur de transcription d'un coefficient.
set.seed(201)
n <- 8; Zs <- matrix(stats::rnorm(1e4 * n), ncol = n)
Std <- (Zs - rowMeans(Zs)) / apply(Zs, 1, stats::sd)
sim <- list(AD = apply(Std, 1, stat_ad), CvM = apply(Std, 1, stat_cvm),
            Lillie = apply(Zs, 1, stat_lilliefors),
            SF = apply(Zs, 1, function(v) test_shapiro_francia(v)$stat))
p_formule <- list(AD = function(i) ad_p_stephens(sim$AD[i], n),
                  CvM = function(i) cvm_p_stephens(sim$CvM[i], n),
                  Lillie = function(i) lillie_p(sim$Lillie[i], n),
                  SF = function(i) test_shapiro_francia(Zs[i, ])$p)
for (nm in names(sim)) {
  s <- sim[[nm]]; bas <- nm == "SF"        # Shapiro-Francia rejette en queue basse
  depass <- vapply(c(0.5, 0.25, 0.10, 0.05, 0.01), function(p) {
    q <- stats::quantile(s, if (bas) p else 1 - p, names = FALSE, type = 1)
    i <- which(s == q)[1]
    p_emp <- if (bas) mean(s <= q) else mean(s >= q)
    abs(p_formule[[nm]](i) - p_emp) - (0.01 + 0.06 * p_emp)
  }, numeric(1))
  verifier(sprintf("%s : p approchee conforme a la loi nulle simulee (T = 8)", nm),
           if (all(depass <= 0)) TRUE else sprintf("depassement max %.4f", max(depass)))
}
verifier("AD, CvM, Lilliefors : p dans [0, 1], decroissante (sauts <= 0,005 aux raccords)",
         {
           pa <- vapply(seq(0.01, 3, by = 0.001), ad_p_stephens, numeric(1), n = 8)
           pc <- vapply(seq(0.001, 1.5, by = 0.0005), cvm_p_stephens, numeric(1), n = 8)
           pl <- vapply(seq(0.05, 0.6, by = 0.0005), lillie_p, numeric(1), n = 8)
           all(c(pa, pc, pl) >= 0 & c(pa, pc, pl) <= 1) &&
             all(diff(pa) <= 0.005) && all(diff(pc) <= 0.005) && all(diff(pl) <= 0.005)
         })
# AD et CvM : NA pour T = 4..7, plage de nortest::ad.test (n > 7 ; #44, R6) ;
# Lilliefors et Shapiro-Francia : NA pour T < 5.
verifier("AD, CvM : NA pour T = 4..7 ; Lilliefors, Shapiro-Francia : NA pour T < 5",
         all(vapply(4:7, function(n) is.na(ad_p_stephens(0.5, n)) && is.na(cvm_p_stephens(0.1, n)),
                    logical(1))) &&
         is.finite(ad_p_stephens(0.5, 8)) && is.finite(cvm_p_stephens(0.1, 8)) &&
         is.na(lillie_p(0.3, 4)) && is.na(test_shapiro_francia(z1[1:4])$p))
verifier("Shapiro-Francia : W' = cor(z tries, scores de Blom)^2",
         proche(test_shapiro_francia(za)$stat,
                stats::cor(sort(za), stats::qnorm((1:8 - 3/8) / (8 + 1/4)))^2, rel = 1e-12))

## --- Jarque-Bera, D'Agostino -------------------------------------------------
# Valeurs de tseries::jarque.bera.test (tseries 0.10-55).
verifier("Jarque-Bera = tseries::jarque.bera.test (z1, z2)",
         isTRUE(proche(test_jarque_bera(z1)$stat, 0.351111954225445, rel = 1e-10)) &&
         isTRUE(proche(test_jarque_bera(z2)$stat, 0.703675922948379, rel = 1e-10)))
zs <- c(-4, -2, -1, -0.5, 0.5, 1, 2, 4)
verifier("D'Agostino : echantillon symetrique -> Z = 0 et p = 1",
         isTRUE(proche(test_dagostino_skew(zs)$stat, 0, abs = 1e-12)) &&
         isTRUE(proche(test_dagostino_skew(zs)$p, 1, abs = 1e-12)))
verifier("D'Agostino : Z change de signe avec z -> -z ; NA pour T < 8",
         isTRUE(proche(test_dagostino_skew(-za)$stat, -test_dagostino_skew(za)$stat, rel = 1e-12)) &&
         is.na(test_dagostino_skew(za[1:7])$stat))
verifier("Anscombe-Glynn : non defini pour T < 20", is.na(test_anscombe_kurt(za)$stat))

## --- Durbin-Watson, Cox-Stuart -----------------------------------------------
# DW = z'MAMz / z'Mz, A = D'D (D matrice des differences premieres), M
# projecteur de centrage : forme matricielle independante du code.
verifier("DW = forme quadratique z'MAMz / z'Mz",
         {
           D <- diff(diag(8)); A <- crossprod(D); M <- diag(8) - 1 / 8
           isTRUE(proche(stat_dw(za), c(t(za) %*% M %*% A %*% M %*% za) /
                                      c(t(za) %*% M %*% za), rel = 1e-12))
         })
verifier("DW : invariant par z -> a + b z et par retournement",
         isTRUE(proche(stat_dw(3 - 2 * za), stat_dw(za), rel = 1e-12)) &&
         isTRUE(proche(stat_dw(rev(za)), stat_dw(za), rel = 1e-12)))
verifier("Cox-Stuart : serie croissante T = 8 -> K = 4 paires, p = 2 x 0,5^4",
         isTRUE(proche(test_cox_stuart(1:8)$stat, 4)) &&
         isTRUE(proche(test_cox_stuart(1:8)$p, 0.125, rel = 1e-12)))
verifier("Cox-Stuart : T = 7 impair -> 3 paires (valeur centrale ecartee), p = 0,25",
         isTRUE(proche(test_cox_stuart(c(1, 3, 2, 9, 5, 6, 4))$stat, 3)) &&
         isTRUE(proche(test_cox_stuart(c(1, 3, 2, 9, 5, 6, 4))$p, 0.25, rel = 1e-12)))
verifier("Cox-Stuart : NA si toutes les differences sont nulles",
         is.na(test_cox_stuart(rep(2, 8))$p))
# Ex aequo (#85) : m = differences non nulles, n_p = paires. Reference : test
# binomial exact, K ~ Binomiale(m, 1/2) sous H0 conditionnellement a m. La
# statistique Monte-Carlo n'est definie que sans ex aequo (m = n_p) : les
# replications, continues, suivent B(n_p, 1/2) et non la loi B(m, 1/2) du K
# observe, d'ou une p_mc NA en presence d'ex aequo.
cs_a <- c(1, 2, 3, 4, 1, 5, 6, 7)   # differences (0, 3, 3, 3) : K = 3, m = 3
cs_b <- c(1, 2, 3, 4, 1, 1, 1, 1)   # differences (0, -1, -2, -3) : K = 0, m = 3
cs_mc <- function(v) USP_CATALOGUE_MC$CoxStuart$calc(.usp_contexte_mc(rep(1, length(v)), v,
                                                                       rep(0, length(v))))
cs_ligne <- function(res) {
  t <- Filter(function(t) identical(t$test, "Tendance par signes du ratio S/P"), res$tests)
  if (length(t) == 1L) t[[1]] else NULL
}
verifier("Cox-Stuart : une difference nulle -> m = 3 sur n_p = 4 paires, p = binom.test(K, 3)",
         identical(test_cox_stuart(cs_a)[c("stat", "m", "n_p")], list(stat = 3L, m = 3L, n_p = 4L)) &&
         identical(test_cox_stuart(cs_b)[c("stat", "m", "n_p")], list(stat = 0L, m = 3L, n_p = 4L)) &&
         isTRUE(proche(test_cox_stuart(cs_a)$p, 0.25, rel = 1e-12)) &&
         isTRUE(proche(test_cox_stuart(cs_b)$p, 0.25, rel = 1e-12)))
verifier("Cox-Stuart Monte-Carlo : statistique de catalogue NA pour K = 3 et K = 0 a m = 3 (ex aequo)",
         is.na(cs_mc(cs_a)) && is.na(cs_mc(cs_b)))
# Enumeration par le moteur : pour n_p = 1..8 et K = 0..n_p, serie SANS ex
# aequo de T = 2 n_p valeurs (K differences +10, n_p - K differences -10). La
# p exacte de test_cox_stuart() doit egaler P(|K' - n_p/2| >= s), K' de loi
# B(n_p, 1/2) enumeree, s = statistique du catalogue : le pliage est la
# region de rejet du test binomial exact.
verifier("Cox-Stuart : p exacte = queue haute enumeree de la statistique du catalogue (n_p = 1..8, sans ex aequo)",
         all(vapply(1:8, function(n_p) {
           kk <- 0:n_p; pk <- stats::dbinom(kk, n_p, 0.5); sk <- abs(kk - n_p / 2)
           all(vapply(kk, function(K) {
             v <- c(seq_len(n_p), seq_len(n_p) + ifelse(seq_len(n_p) <= K, 10, -10))
             cx <- test_cox_stuart(v); s <- cs_mc(v)
             identical(cx$stat, K) && identical(cx$m, n_p) && is.finite(s) &&
               isTRUE(proche(cx$p, min(1, sum(pk[sk >= s - 1e-12])), rel = 1e-12))
           }, logical(1)))
         }, logical(1))))
verifier("Cox-Stuart Monte-Carlo : sans ex aequo, statistique inchangee |K - n_p/2|, n_p = T - ceiling(T/2)",
         all(vapply(list(1:8, 8:1, y_ln / x_ln, z1, z2, za, c(1, 3, 2, 9, 5, 6, 4)), function(v) {
           n_p <- length(v) - ceiling(length(v) / 2)
           isTRUE(proche(cs_mc(v), abs(test_cox_stuart(v)$stat - n_p / 2), rel = 1e-12))
         }, logical(1))))
# Le verdict n'est pas verifie ici : il changera avec #44.
# Depuis #44 (regle R1), p_min = 0,25 (m = 3) ou 1 (m = 0) >= alpha = 0,10 :
# la ligne est un test inoperant, restituee en diagnostic INFO, p exacte
# conservee mais non retenue, detail prefixe ; le motif d'indisponibilite
# Monte-Carlo est celui du catalogue ("statistique observee non definie :
# ex aequo"), et non le motif generique de statistique non finie.
detail_cs_85 <- paste("m = 3 differences non nulles sur n_p = 4 paires ;",
                      "p_mc non calculee (replications sans ex aequo)")
verifier("Cox-Stuart, run_engine() avec ex aequo (m = 3, n_p = 4) : p exacte calculee, p_mc NA avec motif, inoperant (#85, #44)",
         {
           res_cs <- run_engine(xt = rep(100, 8), yt = c(70, 76, 83, 95, 70, 72, 78, 117),
                                methode = "premium", segment = 1, annexe = "II",
                                nature_donnees = "brutes", B = B_MIN_USAGE, seed = 20260831)
           t_cs <- cs_ligne(res_cs)
           isTRUE(res_cs$ok) && !is.null(t_cs) && identical(t_cs$stat, 1L) &&
             identical(t_cs$detail, paste(
               "TEST INOPERANT au seuil alpha = 0.1 : p-value minimale atteignable = 0.2500",
               "(m = 3 differences non nulles) ; aucun verdict (ADR 0001).", detail_cs_85)) &&
             isTRUE(proche(t_cs$p_exacte, 1, rel = 1e-12)) &&
             is.na(t_cs$p_mc) && is.na(t_cs$err_mc) &&
             identical(t_cs$type, "diagnostic") && is.na(t_cs$nature_p) &&
             identical(t_cs$verdict, "INFO") && identical(t_cs$p_min, 0.25) &&
             is.na(res_cs$bootstrap$stats_obs[["CoxStuart"]]) &&
             identical(unname(res_cs$bootstrap$motif_mc[["CoxStuart"]]),
                       "statistique observee non definie : ex aequo") &&
             identical(unname(res_cs$bootstrap$B_effectif[["CoxStuart"]]), B_MIN_USAGE)
         })
verifier("Cox-Stuart, run_engine() sans difference non nulle (m = 0) : K non defini, p_min = 1, inoperant sans cas particulier (#85, #44)",
         {
           res_c0 <- run_engine(xt = rep(100, 8), yt = c(70, 76, 83, 95, 70, 76, 83, 95),
                                methode = "premium", segment = 1, annexe = "II",
                                nature_donnees = "brutes", B = B_MIN_USAGE, seed = 20260831)
           t_c0 <- cs_ligne(res_c0)
           tb_c0 <- tryCatch(engine_table_tests(res_c0), error = function(e) NULL)
           isTRUE(res_c0$ok) && !is.null(t_c0) &&
             is.na(t_c0$stat) && is.na(t_c0$p_exacte) && is.na(t_c0$p_mc) &&
             is.na(t_c0$p_retenue) && is.na(t_c0$nature_p) && identical(t_c0$verdict, "INFO") &&
             identical(t_c0$type, "diagnostic") && identical(t_c0$p_min, 1) &&
             identical(t_c0$detail, paste(
               "TEST INOPERANT au seuil alpha = 0.1 : p-value minimale atteignable = 1.0000",
               "(m = 0 differences non nulles) ; aucun verdict (ADR 0001).",
               "aucune difference non nulle sur n_p = 4 paires :",
               "K non defini")) &&
             is.data.frame(tb_c0)
         })

## --- Heteroscedasticite -------------------------------------------------------
u <- z1 - mean(z1)   # residus centres : lmtest::bptest(u ~ 1) regresse u^2 sur x
# Valeurs de lmtest::bptest(u ~ 1, varformula = ~ x), lmtest 0.9-40.
verifier("Breusch-Pagan studentise (Koenker) = lmtest::bptest(studentize = TRUE)",
         proche(test_breusch_pagan(u^2, x_ln)$stat, 1.36405467085672, rel = 1e-10))
verifier("Breusch-Pagan original (1979) = lmtest::bptest(studentize = FALSE)",
         proche(test_breusch_pagan_original(u^2, x_ln)$stat, 0.706768361547104, rel = 1e-10))
verifier("Breusch-Pagan (Koenker) : LM = T cor(u^2, x)^2",
         proche(test_breusch_pagan(za^2, x_ln)$stat, 8 * stats::cor(za^2, x_ln)^2, rel = 1e-10))
verifier("White : LM = T R2 de u^2 sur (1, x, x^2), moindres carres par qr",
         {
           X <- cbind(1, x_ln, x_ln^2); yy <- za^2
           e <- qr.resid(qr(X), yy); R2 <- 1 - sum(e^2) / sum((yy - mean(yy))^2)
           isTRUE(proche(test_white(za^2, x_ln)$stat, 8 * R2, rel = 1e-8))
         })
verifier("Goldfeld-Quandt : F = moyenne des u^2 des 4 plus gros x / des 4 plus petits",
         {
           o <- order(x_ln); F <- mean(za[o][5:8]^2) / mean(za[o][1:4]^2)
           isTRUE(proche(test_goldfeld_quandt(za, x_ln)$stat, F, rel = 1e-12)) &&
             isTRUE(proche(test_goldfeld_quandt(za, x_ln)$p,
                           2 * min(stats::pf(F, 4, 4), 1 - stats::pf(F, 4, 4)), rel = 1e-12))
         })
# Valeurs de car::leveneTest(center = median), car 3.1-2.
verifier("Brown-Forsythe = car::leveneTest(center = median)",
         isTRUE(proche(test_brown_forsythe(z1, x_ln)$stat, 0.957677018262245, rel = 1e-10)) &&
         isTRUE(proche(test_brown_forsythe(z1, x_ln)$p, 0.365566126151317, rel = 1e-10)))
verifier("Brown-Forsythe : F = t^2 du test de Student a variances egales sur |u - mediane|",
         {
           g <- x_ln > stats::median(x_ln)
           d1 <- abs(za[g] - stats::median(za[g])); d0 <- abs(za[!g] - stats::median(za[!g]))
           isTRUE(proche(test_brown_forsythe(za, x_ln)$stat,
                         unname(stats::t.test(d1, d0, var.equal = TRUE)$statistic)^2, rel = 1e-10))
         })

## --- Specification : RESET, TOST ---------------------------------------------
# Valeurs de lmtest::resettest(y ~ x - 1, power = 2:3, type = "fitted").
verifier("RESET = lmtest::resettest (statistique et p)",
         isTRUE(proche(test_reset(x_ln, y_ln)$stat, 0.00507687817450208, rel = 1e-8)) &&
         isTRUE(proche(test_reset(x_ln, y_ln)$p, 0.99494110930386626, rel = 1e-10)))
# Propriete du TOST (Schuirmann 1987) : rejet a alpha des deux tests
# unilateraux <=> intervalle de confiance a 1 - 2 alpha inclus dans ]-D, D[.
verifier("TOST : p < 0,05 <=> IC a 90 % de la constante inclus dans ]-Delta, Delta[",
         {
           ic <- stats::confint(stats::lm(y_ln ~ x_ln), level = 0.90)[1, ]
           ok <- TRUE
           for (D in c(10, 50, 100, 150, 200, 400)) {
             p <- test_tost_intercept(x_ln, y_ln, delta_abs = D)$p
             ok <- ok && ((p < 0.05) == (ic[1] > -D && ic[2] < D))
           }
           ok
         })
verifier("TOST : p = max des deux p unilaterales ; marge a priori signalee",
         {
           r <- test_tost_intercept(x_ln, y_ln, delta_abs = 100)
           isTRUE(proche(r$p, max(r$p_bas, r$p_haut))) && isTRUE(r$marge_a_priori)
         })
verifier("TOST : non applicable si x constant ou marge non positive",
         is.na(test_tost_intercept(rep(100, 8), y_ln)$p) &&
         is.na(test_tost_intercept(x_ln, y_ln, delta_abs = -1)$p) &&
         is.na(test_tost_intercept(x_ln, y_ln, theta = 0)$p))

## --- Rupture de niveau (sup-F), CUSUM ----------------------------------------
# Pour chaque date k autorisee (2 <= k <= 6 a T = 8, rognage 15 %), F de Chow =
# statistique F de l'ANOVA a deux groupes (t <= k, t > k).
verifier("sup-F = max des F d'ANOVA a deux groupes sur k = 2..6",
         {
           Fk <- vapply(2:6, function(k) {
             g <- factor(seq_along(za) > k)
             stats::anova(stats::lm(za ~ g))[["F value"]][1]
           }, numeric(1))
           isTRUE(proche(stat_supF(za), max(Fk), rel = 1e-10))
         })
verifier("sup-F et CUSUM : NA pour une serie constante",
         is.na(stat_supF(rep(1, 8))) && is.na(stat_cusum(rep(1, 8))))

## --- Grubbs --------------------------------------------------------------------
# Valeur critique bilaterale de Grubbs (1969) : G_c = (n-1)/sqrt(n) *
# sqrt(t^2 / (n - 2 + t^2)), t = quantile 1 - alpha/(2n) de Student(n-2).
# Un echantillon construit pour que G = G_c doit avoir p = alpha.
verifier("Grubbs : p = alpha a la valeur critique de Grubbs (1969), T = 8, alpha = 0,05",
         {
           nn <- 8; a <- 0.05; tq <- stats::qt(1 - a / (2 * nn), nn - 2)
           Gc <- (nn - 1) / sqrt(nn) * sqrt(tq^2 / (nn - 2 + tq^2))
           base <- c(-1.1, -0.6, -0.2, 0, 0.3, 0.5, 0.9)
           xo <- stats::uniroot(function(v) test_grubbs(c(base, v))$stat - Gc,
                                c(1, 50), tol = 1e-12)$root
           isTRUE(proche(test_grubbs(c(base, xo))$p, a, rel = 1e-6))
         })
verifier("Grubbs : p = 0 a la borne (n-1)/sqrt(n) ; NA si ecart-type nul",
         isTRUE(proche(test_grubbs(c(rep(0, 7), 1))$p, 0)) && is.na(test_grubbs(rep(3, 8))$p))

## --- P-value de Monte-Carlo : engine_p_mc() (issue #41) ----------------------
# Reference : enumeration directe sur sim = 1..9 (B_eff = 9).
# obs = 7 : #{sim >= 7} = 3, #{sim <= 7} = 7, d'ou p haut = 4/10, p bas =
# 8/10, p bilaterale = 2 min(4/10, 8/10) = 8/10.
# err_mc = sqrt(p (1 - p) / B_eff) en queue haute ou basse, sqrt(p (2 - p) /
# B_eff) en bilateral (issue #40).
verifier("engine_p_mc : queues haute, basse, bilaterale par enumeration (sim = 1..9, obs = 7)",
         {
           h <- engine_p_mc(1:9, 7, "haut"); b <- engine_p_mc(1:9, 7, "bas")
           d <- engine_p_mc(1:9, 7, "deux")
           proche(h$p_mc, 0.4) && proche(b$p_mc, 0.8) && proche(d$p_mc, 0.8) &&
             proche(h$err_mc, sqrt(0.4 * 0.6 / 9)) && proche(b$err_mc, sqrt(0.8 * 0.2 / 9)) &&
             proche(d$err_mc, sqrt(0.8 * 1.2 / 9)) &&
             proche(h$granularite, 1 / 10) && proche(d$granularite, 2 / 10) &&
             identical(h$B_effectif, 9)
         })
verifier("engine_p_mc : bilaterale bornee a 1 (obs = mediane), err_mc = 1 / sqrt(B_eff)",
         { d <- engine_p_mc(1:9, 5, "deux"); identical(d$p_mc, 1) && proche(d$err_mc, 1 / 3) })
verifier("engine_p_mc : simulations non finies ignorees dans p et B_effectif",
         identical(engine_p_mc(c(1:9, NA, Inf, NaN), 7, "haut"), engine_p_mc(1:9, 7, "haut")))
verifier("engine_p_mc : NA si valeur observee non finie ou aucune simulation finie",
         {
           o <- engine_p_mc(1:9, NA_real_, "haut"); v <- engine_p_mc(c(NA, NA), 1, "bas")
           is.na(o$p_mc) && is.na(o$err_mc) && identical(o$B_effectif, 9) &&
             is.na(v$p_mc) && identical(v$B_effectif, 0)
         })
verifier("engine_p_mc : sens de rejet inconnu refuse",
         leve_erreur(engine_p_mc(1:9, 7, "gauche")) && leve_erreur(engine_p_mc(1:9, 7, NA)))

## --- Erreur de Monte-Carlo selon le sens du rejet (issue #40) ---------------
# Reference : enumeration exacte de la loi binomiale des comptages, sans
# erreur Monte-Carlo (avis d'actuary du 24/09/2026 sur #40). Avec sim =
# N fois +1 et B - N fois -1 et obs = 0 : #{sim >= 0} = N, #{sim <= 0} = B - N.
# Sous le modele de la simulation, N ~ Binomiale(B, q+) exactement, q+ = p / 2
# en bilateral (queue la plus petite, q- = 1 - p / 2), q+ = p en queue haute.
# L'ecart-type exact de p_mc est celui de engine_p_mc() applique a chaque N,
# pondere par dbinom ; err_mc est evaluee par engine_p_mc() au N qui donne
# p_mc = p exactement. Tolerance 1 % relative (ecart d'enumeration <= 0,5 %
# pour p <= 0,9 ; la formule unilaterale appliquee au bilateral en est a 30 %
# a 70 %).
.p40_B <- 999
.p40_sim <- function(N, B = .p40_B) c(rep(1, N), rep(-1, B - N))
# N = 0 et N = B sont exclus : les B = 999 simulations y sont constantes
# (toutes -1 ou toutes +1), l'observee 0 est hors de l'atome, et
# engine_p_mc() rend alors p_mc = NA, motif MOTIF_MC_ATOME_HORS_OBS (#44,
# regle R2 et reprise) ; leur poids binomial est inferieur a 1e-20 pour tous les
# q ci-dessous (0,05 <= q <= 0,5), les poids restants sont renormalises.
.p40_sd_exact <- function(q, queue, B = .p40_B) {
  N <- 1:(B - 1)
  pm <- vapply(N, function(n) engine_p_mc(.p40_sim(n, B), 0, queue)$p_mc, numeric(1))
  w <- stats::dbinom(N, B, q); w <- w / sum(w)
  sqrt(sum(w * pm^2) - sum(w * pm)^2)
}
.p40_err <- function(N, queue) engine_p_mc(.p40_sim(N), 0, queue)
# N tel que 2 (1 + N) / (B + 1) = p : 49, 186, 399, 449 pour p = 0,10 ;
# 0,374 ; 0,80 ; 0,90.
for (.cas in list(c(0.10, 49), c(0.374, 186), c(0.80, 399), c(0.90, 449))) local({
  p <- .cas[1]; N <- .cas[2]
  verifier(sprintf("engine_p_mc : err_mc bilaterale = ecart-type exact (dbinom, B = 999) a 1 %%, p = %.3f", p),
           {
             e <- .p40_err(N, "deux")
             proche(e$p_mc, p, rel = 1e-12) &&
               proche(e$err_mc, sqrt(p * (2 - p) / .p40_B), rel = 1e-12) &&
               isTRUE(proche(e$err_mc, .p40_sd_exact(p / 2, "deux"), rel = 0.01))
           })
})
# Bord p = 1 (q+ = q- = 1/2) : la formule vaut 1 / sqrt(B) et majore
# l'ecart-type exact, lui-meme egal a sqrt((1 - 2/pi) / B) a 5 % pres
# (approximation normale de |p+ - 1/2|).
verifier("engine_p_mc : bord p = 1, err_mc >= ecart-type exact = sqrt((1 - 2/pi)/B) a 5 %",
         {
           e <- .p40_err(499, "deux"); sdx <- .p40_sd_exact(0.5, "deux")
           identical(e$p_mc, 1) && proche(e$err_mc, 1 / sqrt(.p40_B), rel = 1e-12) &&
             e$err_mc >= sdx && isTRUE(proche(sdx, sqrt((1 - 2 / pi) / .p40_B), rel = 0.05))
         })
# Unilateral (queue haute) : N tel que (1 + N) / (B + 1) = p : 99 et 499.
for (.cas in list(c(0.10, 99), c(0.50, 499))) local({
  p <- .cas[1]; N <- .cas[2]
  verifier(sprintf("engine_p_mc : err_mc unilaterale = ecart-type exact (dbinom, B = 999) a 1 %%, p = %.2f", p),
           {
             e <- .p40_err(N, "haut")
             proche(e$p_mc, p, rel = 1e-12) &&
               proche(e$err_mc, sqrt(p * (1 - p) / .p40_B), rel = 1e-12) &&
               isTRUE(proche(e$err_mc, .p40_sd_exact(p, "haut"), rel = 0.01))
           })
})
# Simulations non finies : B_eff les exclut, le denominateur de p_mc est
# B_eff + 1, err_mc et granularite sont calculees sur B_eff.
verifier("engine_p_mc : NA dans sim exclus de B_eff (p = 2 (1+3)/10, err_mc et granularite sur B_eff = 9)",
         {
           d <- engine_p_mc(c(NA, 1:4, NA, 5:9, NA), 7, "deux")
           identical(d$B_effectif, 9) && proche(d$p_mc, 0.8) &&
             proche(d$err_mc, sqrt(0.8 * 1.2 / 9)) && proche(d$granularite, 0.2)
         })
# Simulation a travers engine_p_mc() : S ~ N(0, 1), B = 999, obs =
# qnorm(1 - p/2), R = 2 000 repetitions sous graine locale (restauree, ou
# supprimee si elle n'existait pas) ; pour une meme observation, ecart-type
# empirique des p_mc a 10 % de la moyenne des err_mc rendues par
# engine_p_mc() (incertitude d'un ecart-type estime sur R = 2 000 :
# 1 / sqrt(2R) = 1,6 %, approximation normale), et cette moyenne a 10 % de
# sqrt(p (2 - p) / B) ; queue haute a p = 0,10, reference sqrt(p (1 - p) / B).
verifier("engine_p_mc : ecart-type simule des p_mc (R = 2 000) a 10 % de err_mc, bilateral et unilateral",
         {
           existait <- exists(".Random.seed", envir = globalenv())
           avant <- if (existait) get(".Random.seed", envir = globalenv()) else NULL
           set.seed(40); R <- 2000; B <- .p40_B
           S <- matrix(stats::rnorm(R * B), R, B)
           if (existait) assign(".Random.seed", avant, envir = globalenv())
           else rm(".Random.seed", envir = globalenv())
           compare <- function(obs, queue, p, k) {
             r <- apply(S, 1, function(s) unlist(engine_p_mc(s, obs, queue)[c("p_mc", "err_mc")]))
             e <- mean(r["err_mc", ])
             isTRUE(proche(stats::sd(r["p_mc", ]), e, rel = 0.10)) &&
               isTRUE(proche(e, sqrt(p * (k - p) / B), rel = 0.10))
           }
           ok <- vapply(c(0.10, 0.374, 0.80), function(p)
             compare(stats::qnorm(1 - p / 2), "deux", p, 2), logical(1))
           all(ok) && compare(stats::qnorm(0.90), "haut", 0.10, 1) &&
             identical(exists(".Random.seed", envir = globalenv()), existait)
         })
# Champ granularite_stat de l'objet bootstrap (issue #40) : 2 / (B_eff + 1)
# pour une statistique bilaterale, 1 / (B_eff + 1) sinon, le sens etant lu au
# catalogue. Bootstrap B = 19 sur les donnees de CLAUDE.md, etat du
# generateur restaure (usp_bootstrap() appelle set.seed(), issue #4).
verifier("usp_bootstrap : granularite_stat = k / (B_eff + 1), k = 2 en bilateral, 1 sinon",
         {
           existait <- exists(".Random.seed", envir = globalenv())
           avant <- if (existait) get(".Random.seed", envir = globalenv()) else NULL
           xb <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
           yb <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
           bt <- usp_bootstrap(usp_ajuster(xb, yb), B = 19)
           if (existait) assign(".Random.seed", avant, envir = globalenv())
           else rm(".Random.seed", envir = globalenv())
           g <- bt$granularite_stat
           k <- ifelse(vapply(USP_CATALOGUE_MC, `[[`, "", "queue") == "deux", 2, 1)
           identical(names(g), names(bt$B_effectif)) && identical(names(g), names(k)) &&
             any(k == 2) && any(k == 1) &&
             isTRUE(proche(g, k / (bt$B_effectif + 1), rel = 1e-12)) &&
             identical(bt$granularite, 1 / 20)
         })
rm(.p40_B, .p40_sim, .p40_sd_exact, .p40_err, .cas)
verifier(".mc_p_values : une colonne absente du catalogue est refusee",
         leve_erreur(.mc_p_values(matrix(1:9, 9, 1, dimnames = list(NULL, "Inconnue")),
                                  list(Inconnue = 7), USP_CATALOGUE_MC)))

fin_fichier()
