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
verifier("AD, CvM, Lilliefors, Shapiro-Francia : NA pour T < 5",
         is.na(ad_p_stephens(0.5, 4)) && is.na(cvm_p_stephens(0.1, 4)) &&
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
# err_mc = sqrt(p (1 - p) / B_eff), formule inchangee par #41 (issue #40).
verifier("engine_p_mc : queues haute, basse, bilaterale par enumeration (sim = 1..9, obs = 7)",
         {
           h <- engine_p_mc(1:9, 7, "haut"); b <- engine_p_mc(1:9, 7, "bas")
           d <- engine_p_mc(1:9, 7, "deux")
           proche(h$p_mc, 0.4) && proche(b$p_mc, 0.8) && proche(d$p_mc, 0.8) &&
             proche(h$err_mc, sqrt(0.4 * 0.6 / 9)) && proche(d$err_mc, sqrt(0.8 * 0.2 / 9)) &&
             identical(h$B_effectif, 9)
         })
verifier("engine_p_mc : bilaterale bornee a 1 (obs = mediane), err_mc nulle",
         { d <- engine_p_mc(1:9, 5, "deux"); identical(d$p_mc, 1) && identical(d$err_mc, 0) })
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
verifier(".mc_p_values : une colonne absente du catalogue est refusee",
         leve_erreur(.mc_p_values(matrix(1:9, 9, 1, dimnames = list(NULL, "Inconnue")),
                                  list(Inconnue = 7), USP_CATALOGUE_MC)))

fin_fichier()
