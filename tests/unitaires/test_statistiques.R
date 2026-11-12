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

## --- Anscombe-Glynn : statistique Z non definie (#485) ----------------------
# Decision QA1 (a) du mainteneur du 10/11/2026 : des que 1 + x sqrt(2/(A - 4))
# <= 0 (b2 = 1, T = 40), stat et p a NA, z_non_definie a TRUE ; la ligne
# d'usp_tests() reste non applicable sous un motif propre, jamais "T < 20".
NOM_AG_485 <- "Aplatissement (Anscombe-Glynn, T >= 20)"
MOTIF_AG_Z_485 <- paste("statistique Z non definie : 1 + x sqrt(2/(A - 4)) <= 0 (aplatissement",
                        "b2 tres inferieur a 3, hors du domaine de la transformation de",
                        "Wilson-Hilferty) ; aucune p-value de Monte-Carlo prevue : test",
                        "non applicable")
ligne_ag_485 <- function(x, y) {
  r <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                  nature_donnees = "brutes", B = B_MIN_USAGE, seed = 20260831)
  list(ok = r$ok, l = Filter(function(e) identical(e$test, NOM_AG_485), r$tests)[[1]],
       z = r$ajustement$z)
}
verifier("Anscombe-Glynn (#485) : b2 = 1 a T = 40 -> Z non definie (stat et p NA, z_non_definie) ; T = 20, 30 : Z finie",
         {
           a40 <- test_anscombe_kurt(rep(c(-1, 1), 20))
           a20 <- test_anscombe_kurt(rep(c(-1, 1), 10))
           a30 <- test_anscombe_kurt(rep(c(-1, 1), 15))
           identical(a40$stat, NA_real_) && identical(a40$p, NA_real_) &&
             isTRUE(a40$z_non_definie) &&
             is.finite(a20$stat) && identical(a20$z_non_definie, FALSE) &&
             is.finite(a30$stat) && identical(a30$z_non_definie, FALSE) &&
             identical(test_anscombe_kurt(za)$z_non_definie, FALSE) &&
             identical(a40$b2_non_defini, FALSE) && identical(a30$b2_non_defini, FALSE)
         })
verifier("Anscombe-Glynn (#485) : z constant a T = 40 -> b2 non defini (stat et p NA, b2_non_defini), avant Z",
         {
           a0 <- test_anscombe_kurt(rep(0, 40))
           identical(a0$stat, NA_real_) && identical(a0$p, NA_real_) &&
             isTRUE(a0$b2_non_defini) && identical(a0$z_non_definie, FALSE)
         })
# Jeu de l'issue : T = 40, volumes constants (pi_t constant), log(y/x) =
# -0,4 +/- 0,1 permutes plus un bruit de 0,005 (b2 mesure 1,0086).
set.seed(485)
x_485 <- rep(100, 40)
y_485 <- x_485 * exp(-0.4 + sample(rep(c(-0.1, 0.1), 20)) + stats::rnorm(40, 0, 0.005))
verifier("Anscombe-Glynn (#485) : run_engine() a T = 40, b2 ~ 1 -> non applicable, stat NA, motif Z non definie, sans \"T < 20\"",
         {
           g <- ligne_ag_485(x_485, y_485)
           isTRUE(g$ok) && identical(g$l$type, "non applicable") &&
             identical(g$l$stat, NA_real_) && isTRUE(g$l$estim < 1.1) &&
             is.na(g$l$p_retenue) && is.na(g$l$p_asymptotique) &&
             identical(g$l$detail, MOTIF_AG_Z_485) && !grepl("< 20", g$l$detail, fixed = TRUE)
         })
verifier("Anscombe-Glynn (#485) : run_engine() a T = 10 -> motif T < 20 inchange",
         {
           g <- ligne_ag_485(x_485[1:10], y_485[1:10])
           isTRUE(g$ok) && identical(g$l$type, "non applicable") &&
             identical(g$l$detail, "T = 10 < 20 : test non defini")
         })
# Appels directs d'usp_tests() (reponses d'actuary du 10/11/2026) : residus
# z substitues dans l'ajustement, objet bootstrap fictif (aucune simulation).
boot_fictif_485 <- function(f) {
  s <- .stats_bootstrapables(f$x, f$y, f$z, f$pi)
  pm <- stats::setNames(rep(0.5, length(s)), names(s)); pm[!is.finite(s)] <- NA_real_
  mm <- stats::setNames(rep(NA_character_, length(s)), names(s))
  mm[!is.finite(s)] <- MOTIF_MC_OBS_NON_FINIE
  list(stats_obs = as.list(s), p_mc = pm, err_mc = pm * 0 + 0.01, motif_mc = mm)
}
ligne_ag_direct_485 <- function(f)
  Filter(function(e) identical(e$test, NOM_AG_485),
         suppressWarnings(usp_tests(f, boot_fictif_485(f), methode = "premium")))[[1]]
verifier("Anscombe-Glynn (#485) : usp_tests(), z constant a T = 40, pi_t constant -> non applicable, motif b2 non defini",
         {
           f0 <- usp_ajuster(x_485, y_485); f0$z <- rep(0, 40)
           l <- ligne_ag_direct_485(f0)
           isTRUE(usp_regime(f0$delta, f0$x)$pi_constant) &&
             identical(l$type, "non applicable") && identical(l$stat, NA_real_) &&
             is.na(l$p_retenue) && identical(l$verdict, "INFO") &&
             identical(l$detail, paste("aplatissement b2 non defini (moment centre d'ordre 2 des residus nul :",
                                       "residus constants) ; aucune p-value de Monte-Carlo prevue : test",
                                       "non applicable"))
         })
verifier("Anscombe-Glynn (#485) : usp_tests(), pi_t variable et Z non definie -> motif pi_t, H0, H1 et stat_nom presents, loi NA (#533), stat NA",
         {
           xv <- seq(50, 400, length.out = 40); yv <- 0.6 * xv
           g <- usp_ajuster(x_485, y_485)$gamma
           fv <- c(usp_noyau(0.5, g, xv, yv),
                   list(delta = 0.5, gamma = g, T = 40L, x = xv, y = yv, xbar = mean(xv),
                        convergence = 0L, part_starts_convergents = 1,
                        delta_au_bord = usp_regime(0.5, xv)$delta_au_bord))
           fv$z <- rep(c(-1, 1), 20)
           l <- ligne_ag_direct_485(fv)
           !isTRUE(usp_regime(0.5, xv)$pi_constant) && isTRUE(test_anscombe_kurt(fv$z)$z_non_definie) &&
             identical(l$type, "non applicable") && identical(l$stat, NA_real_) &&
             identical(l$stat_nom, "Z") && identical(l$H0, "aplatissement de la population egal a 3") &&
             identical(l$H1, "aplatissement different de 3") &&
             identical(l$loi, NA_character_) && isTRUE(proche(l$estim, 1, abs = 1e-12)) &&
             is.na(l$p_retenue) &&
             identical(l$detail, paste("approximation a n fini etablie pour un echantillon i.i.d. normal,",
                                       "sans objet a pi_t variable (z = P epsilon non i.i.d.) ; aucune",
                                       "p-value de Monte-Carlo prevue : test non applicable"))
         })
verifier("Anscombe-Glynn (#485) : run_engine() a T = 30, cas regulier -> test, p d'approximation a n fini retenue",
         {
           set.seed(4850)
           x30 <- rep(100, 30); y30 <- x30 * exp(-0.4 + stats::rnorm(30, 0, 0.1))
           g <- ligne_ag_485(x30, y30)
           ak <- test_anscombe_kurt(g$z)
           isTRUE(g$ok) && identical(g$l$type, "test") && is.finite(g$l$stat) &&
             identical(g$l$stat, ak$stat) && identical(g$l$p_retenue, ak$p) &&
             identical(g$l$nature_p, NATURE_APPROX_N_FINI)
         })

## --- Test des suites : statistique non definie (#486) -------------------------
# Avis amont d'actuary (section 4) : stat et p a NA (jamais NaN) et cause
# rendue par test_runs() ; n1 = n2 = 1 : variance de R nulle, garde avant
# .runs_z() ; motif des lignes choisi par la cause.
CAUSE_RUNS_UN_COTE_486 <- "un seul cote de la mediane represente : loi de R non definie"
CAUSE_RUNS_N11_486 <- paste("une seule valeur de chaque cote de la mediane (n1 = n2 = 1) :",
                            "R = 2 pour tout arrangement, loi de R degeneree (variance nulle)")
verifier("Suites (#486) : n1 = n2 = 1 -> stat et p NA (et non NaN), R = 2, cause n1 = n2 = 1",
         {
           a <- test_runs(c(1, 2, 2, 2, 3)); b <- test_runs(c(3, 2, 2, 2, 1))
           identical(a$stat, NA_real_) && identical(a$p, NA_real_) && identical(a$runs, 2) &&
             identical(a$cause, CAUSE_RUNS_N11_486) && identical(b$stat, NA_real_) &&
             identical(b$cause, CAUSE_RUNS_N11_486) &&
             identical(unname(.runs_effectifs(c(1, 2, 2, 2, 3))), c(1L, 1L))
         })
verifier("Suites (#486) : un seul cote de la mediane (n1 = 0 ou n2 = 0) -> stat NA, cause un seul cote",
         {
           a <- test_runs(c(1, 1, 1, 1, 2)); b <- test_runs(c(2, 2, 2, 2, 1))
           identical(a$stat, NA_real_) && identical(a$p, NA_real_) &&
             identical(a$cause, CAUSE_RUNS_UN_COTE_486) && identical(b$cause, CAUSE_RUNS_UN_COTE_486)
         })
verifier("Suites (#486) : cas regulier inchange (stat, p et R de .runs_z()), cause NA",
         all(vapply(list(c(1, 8, 2, 7, 3, 6, 4, 5), 1:5, c(0.3, -1.2, 0.8, 2.1, -0.4, 0.05, -2, 1.1)),
                    function(v) {
                      a <- test_runs(v); ne <- .runs_effectifs(v)
                      s <- sign(v - stats::median(v)); s <- s[s != 0]
                      R <- 1 + sum(diff(s) != 0); Z <- .runs_z(R, ne[["n1"]], ne[["n2"]])
                      identical(a, list(stat = Z, p = .p_borne(2 * (1 - stats::pnorm(abs(Z)))),
                                        runs = R, cause = NA_character_))
                    }, logical(1))))
# Scenario lognormal de l'issue : T = 5, trois ratios S/P egaux a la mediane.
x_486 <- c(100, 130, 90, 160, 120)
ligne_486 <- function(t, nom) Filter(function(e) identical(e$test, nom), t)[[1]]
NOM_RUNSR_486 <- "Test des suites sur ratios bruts"
NOM_RUNS_486 <- "Test des suites (aleatoire des signes)"
verifier("Suites (#486) : run_engine() lognormal T = 5, n1 = n2 = 1 sur u -> Runsr non applicable, stat NA, motif n1 = n2 = 1, aucun NaN dans la table",
         {
           r <- run_engine(xt = x_486, yt = x_486 * c(.6, .7, .7, .7, .85), methode = "premium",
                           segment = 1, annexe = "II", nature_donnees = "brutes",
                           B = 199, seed = 20260831)
           l <- ligne_486(r$tests, NOM_RUNSR_486); st <- engine_table_tests(r)$statistique
           isTRUE(r$ok) && identical(l$type, "non applicable") && identical(l$stat, NA_real_) &&
             identical(r$bootstrap$stats_obs$Runsr, NA_real_) && identical(l$verdict, "INFO") &&
             identical(l$inoperant, FALSE) &&
             identical(l$detail, paste0(CAUSE_RUNS_N11_486, ", test non applicable")) &&
             !any(is.nan(st))
         })
verifier("Suites (#486) : run_engine() lognormal T = 5, un seul cote sur u -> Runsr, motif un seul cote inchange",
         {
           r <- run_engine(xt = x_486, yt = x_486 * c(.7, .7, .7, .7, .8), methode = "premium",
                           segment = 1, annexe = "II", nature_donnees = "brutes",
                           B = 199, seed = 20260831)
           l <- ligne_486(r$tests, NOM_RUNSR_486)
           isTRUE(r$ok) && identical(l$type, "non applicable") && identical(l$stat, NA_real_) &&
             identical(l$detail, paste("un seul cote de la mediane represente : loi de R non definie,",
                                       "test non applicable")) &&
             !any(is.nan(engine_table_tests(r)$statistique))
         })
# Ligne sur z : residus substitues dans l'ajustement, objet bootstrap fictif
# de #485 (aucune simulation).
verifier("Suites (#486) : usp_tests(), ligne sur z -> motif choisi par la cause (n1 = n2 = 1 ; un seul cote)",
         {
           f <- usp_ajuster(x_486, x_486 * c(.62, .7, .66, .75, .85))
           f1 <- f; f1$z <- c(1, 2, 2, 2, 3)
           f0 <- f; f0$z <- c(1, 1, 1, 1, 2)
           l1 <- ligne_486(suppressWarnings(usp_tests(f1, boot_fictif_485(f1), methode = "premium")),
                           NOM_RUNS_486)
           l0 <- ligne_486(suppressWarnings(usp_tests(f0, boot_fictif_485(f0), methode = "premium")),
                           NOM_RUNS_486)
           identical(l1$type, "non applicable") && identical(l1$stat, NA_real_) &&
             identical(l1$detail, paste0(CAUSE_RUNS_N11_486, ", test non applicable")) &&
             identical(l0$type, "non applicable") && identical(l0$stat, NA_real_) &&
             identical(l0$detail, paste("un seul cote de la mediane represente : loi de R non",
                                        "definie, test non applicable"))
         })
# Ligne Runsr a pi_t constant et signes identiques (#532, avis amont d'actuary
# de K3b, section 4) : Runsr finie implique une p exacte finie, la branche
# "sans p exacte" du detail est retiree et remplacee par une assertion. Jeu
# a ratios (0,8 x 7 ; 1,4), delta = 1 (pi_t constant), objet bootstrap fictif
# dont la statistique observee de Runsr, non finie sur ce jeu (un seul cote de
# la mediane), est forcee a 1.
MSG_RUNSR_INCOHERENT_532 <- paste0("usp_tests() : p exacte de Runsr non definie a pi_t constant ",
                                   "et signes identiques, statistique observee finie : ",
                                   "objet bootstrap incoherent")
verifier("Suites (#532) : pi_t constant, signes identiques, Runsr observee finie mais p exacte non definie -> assertion, message exact ; Runsr non finie -> non applicable",
         {
           x <- c(100, 130, 90, 160, 120, 110, 140, 150)
           f <- usp_ajuster(x, x * c(rep(0.8, 7), 1.4))
           b <- boot_fictif_485(f)
           l_na <- ligne_486(suppressWarnings(usp_tests(f, b, methode = "premium")),
                             NOM_RUNSR_486)
           b$stats_obs$Runsr <- 1; b$p_mc[["Runsr"]] <- 0.5; b$motif_mc[["Runsr"]] <- NA_character_
           e <- tryCatch(suppressWarnings(usp_tests(f, b, methode = "premium")),
                         error = function(e) e)
           isTRUE(usp_regime(f$delta, f$x)$pi_constant) &&
             identical(l_na$type, "non applicable") &&
             identical(l_na$detail, paste("un seul cote de la mediane represente : loi de R non",
                                          "definie, test non applicable")) &&
             inherits(e, "error") && identical(conditionMessage(e), MSG_RUNSR_INCOHERENT_532)
         })
# Scenario Merz-Wuthrich de l'issue : I = 8, colonnes 0-4 et 6 degenerees
# (facteurs individuels egaux par colonne), colonne 5 a deux facteurs
# distincts : deux residus de Mack, de signes opposes.
tri_486 <- local({
  f <- c(1.5, 1.2, 1.1, 1.05, 1.02, NA, 1.01)
  t <- matrix(NA_real_, 8, 8); t[, 1] <- c(1000, 1100, 900, 1200, 1050, 980, 1010, 1150)
  for (i in 1:8) for (j in seq_len(8 - i) + 1)
    t[i, j] <- t[i, j - 1] * (if (j == 7) (if (i == 1) 1.03 else 1.05) else f[j - 1])
  t
})
verifier("Suites (#486) : Merz-Wuthrich a deux residus de Mack -> stat NA, motif n1 = n2 = 1, aucun NaN dans la table",
         {
           r <- run_engine(methode = "reserve2", triangle = tri_486, segment = 2, annexe = "II",
                           B = 199, seed = 20260831)
           l <- ligne_486(r$tests, "Test des suites sur les residus de Mack")
           isTRUE(r$ok) && nrow(mw_residus(r$ajustement)) == 2L &&
             identical(r$bootstrap$stats_obs$Runs, NA_real_) &&
             identical(l$type, "non applicable") && identical(l$stat, NA_real_) &&
             identical(l$estim, 2) && identical(l$verdict, "INFO") &&
             endsWith(l$detail, paste("Une seule valeur de chaque cote de la mediane (n1 = n2 = 1) :",
                                      "R = 2 pour tout arrangement, loi de R degeneree (variance nulle).")) &&
             !any(is.nan(engine_table_tests(r)$statistique))
         })
# Ligne non applicable : aucune p-value restituee (#486, ecart releve par
# docwriter). A pi_t constant (volumes constants), runs_p_exacte() et
# runs_p_min() rendraient 1 a n1 = n2 = 1 (loi ponctuelle R = 2) : p_exacte
# et p_min a NA, comme a n1 = 0 ou n2 = 0, sur la ligne z et sur Runsr.
verifier("Suites (#486) : n1 = n2 = 1 a pi_t constant -> p_exacte et p_min NA (ligne z et Runsr), comme un seul cote",
         {
           xc <- rep(100, 5); champs <- c("type", "p_exacte", "p_min", "p_retenue", "verdict", "inoperant")
           f <- usp_ajuster(xc, xc * c(.62, .7, .66, .75, .85))
           f1 <- f; f1$z <- c(-1, 0, 0, 0, 1); f0 <- f; f0$z <- c(1, 1, 1, 1, 2)
           lz1 <- ligne_486(suppressWarnings(usp_tests(f1, boot_fictif_485(f1), methode = "premium")),
                            NOM_RUNS_486)
           lz0 <- ligne_486(suppressWarnings(usp_tests(f0, boot_fictif_485(f0), methode = "premium")),
                            NOM_RUNS_486)
           rr <- function(m) ligne_486(run_engine(xt = xc, yt = xc * m, methode = "premium", segment = 1,
                                                  annexe = "II", nature_donnees = "brutes",
                                                  B = 199, seed = 20260831)$tests, NOM_RUNSR_486)
           lr1 <- rr(c(.6, .7, .7, .7, .85)); lr0 <- rr(c(.7, .7, .7, .7, .8))
           isTRUE(usp_regime(f$delta, f$x)$pi_constant) &&
             identical(runs_p_exacte(f1$z), 1) && identical(runs_p_min(1, 1), 1) &&
             identical(lz1$type, "non applicable") && identical(lz1$p_exacte, NA_real_) &&
             identical(lz1$p_min, NA_real_) && identical(lz1[champs], lz0[champs]) &&
             identical(lr1$type, "non applicable") && identical(lr1$p_exacte, NA_real_) &&
             identical(lr1$p_min, NA_real_) && identical(lr1[c(champs, "loi")], lr0[c(champs, "loi")])
         })

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
                                                                       rep(0, length(v)), rep(1, length(v))))
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
# Texte de #514 (specification finale d'actuary, U11), precede de la mention
# de regime M21 (volumes constants, p exacte finie).
cs_514 <- function(eff) sprintf(paste(
  "Un ECHEC ou une ALERTE signale une tendance du ratio S/P, par le signe des",
  "differences entre premiere et seconde moitie de la periode (%s). A lire avec",
  "\"Tendance monotone du ratio S/P\", meme alternative."), eff)
detail_cs_85 <- paste(MENTION_VOLUMES_CONSTANTS,
                      cs_514("m = 3 differences non nulles sur n_p = 4 paires, p_mc non calculee"))
verifier("Cox-Stuart, run_engine() avec ex aequo (m = 3, n_p = 4) : p exacte calculee, p_mc NA avec motif, inoperant (#85, #44)",
         {
           res_cs <- run_engine(xt = rep(100, 8), yt = c(70, 76, 83, 95, 70, 72, 78, 117),
                                methode = "premium", segment = 1, annexe = "II",
                                nature_donnees = "brutes", B = B_MIN_USAGE, seed = 20260831)
           t_cs <- cs_ligne(res_cs)
           isTRUE(res_cs$ok) && !is.null(t_cs) && identical(t_cs$stat, 1L) &&
             identical(t_cs$detail, paste(
               "TEST INOPERANT au seuil alpha = 0.1 : p-value minimale atteignable = 0.2500",
               "(m = 3 differences non nulles), aucun verdict.", detail_cs_85)) &&
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
             # #469 (option (i) d'actuary) : le motif d'indisponibilite de la p
             # Monte-Carlo (non_definie du catalogue) suit la phrase TEST
             # INOPERANT, comme le bloc aucune_p l'imprime hors R1.
             identical(t_c0$detail, paste(
               "TEST INOPERANT au seuil alpha = 0.1 : p-value minimale atteignable = 1.0000",
               "(m = 0 differences non nulles), aucun verdict.",
               "Monte-Carlo indisponible : statistique observee non definie : ex aequo.",
               cs_514("aucune difference non nulle : K non defini"))) &&
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
# Depuis #215 : IC de la constante du modele auxiliaire pondere (poids
# usp_poids_gls() au pi de l'ajustement), meme regression que le TOST.
pi_ln <- usp_ajuster(x_ln, y_ln)$pi
verifier("TOST : p < 0,05 <=> IC a 90 % de la constante ponderee inclus dans ]-Delta, Delta[",
         {
           w_ln <- usp_poids_gls(x_ln, pi_ln)
           ic <- stats::confint(stats::lm(y_ln ~ x_ln, weights = w_ln), level = 0.90)[1, ]
           ok <- TRUE
           for (D in c(10, 50, 100, 150, 200, 400)) {
             p <- test_tost_intercept(x_ln, y_ln, pi_ln, delta_abs = D)$p
             ok <- ok && ((p < 0.05) == (ic[1] > -D && ic[2] < D))
           }
           ok
         })
verifier("TOST : p = max des deux p unilaterales ; marge a priori signalee",
         {
           r <- test_tost_intercept(x_ln, y_ln, pi_ln, delta_abs = 100)
           isTRUE(proche(r$p, max(r$p_bas, r$p_haut))) && isTRUE(r$marge_a_priori)
         })
verifier("TOST : non applicable si x constant ou marge non positive",
         is.na(test_tost_intercept(rep(100, 8), y_ln, pi_ln)$p) &&
         is.na(test_tost_intercept(x_ln, y_ln, pi_ln, delta_abs = -1)$p) &&
         is.na(test_tost_intercept(x_ln, y_ln, pi_ln, theta = 0)$p))

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
# Reference : enumeration directe sur sim = 1..99 (B_eff = 99, au moins
# B_MIN_DEGENERESCENCE = 50 : sous ce seuil, p_mc n'est plus calculee, #128).
# obs = 70 : #{sim >= 70} = 30, #{sim <= 70} = 70, d'ou p haut = 31/100, p bas
# = 71/100, p bilaterale = 2 min(31/100, 71/100) = 62/100.
# err_mc = sqrt(p (1 - p) / B_eff) en queue haute ou basse, sqrt(p (2 - p) /
# B_eff) en bilateral (issue #40).
verifier("engine_p_mc : queues haute, basse, bilaterale par enumeration (sim = 1..99, obs = 70)",
         {
           h <- engine_p_mc(1:99, 70, "haut"); b <- engine_p_mc(1:99, 70, "bas")
           d <- engine_p_mc(1:99, 70, "deux")
           proche(h$p_mc, 0.31) && proche(b$p_mc, 0.71) && proche(d$p_mc, 0.62) &&
             proche(h$err_mc, sqrt(0.31 * 0.69 / 99)) && proche(b$err_mc, sqrt(0.71 * 0.29 / 99)) &&
             proche(d$err_mc, sqrt(0.62 * 1.38 / 99)) &&
             proche(h$granularite, 1 / 100) && proche(d$granularite, 2 / 100) &&
             identical(h$B_effectif, 99)
         })
verifier("engine_p_mc : bilaterale bornee a 1 (obs = mediane), err_mc = 1 / sqrt(B_eff)",
         { d <- engine_p_mc(1:99, 50, "deux"); identical(d$p_mc, 1) && proche(d$err_mc, 1 / sqrt(99)) })
verifier("engine_p_mc : simulations non finies ignorees dans p et B_effectif",
         identical(engine_p_mc(c(1:99, NA, Inf, NaN), 70, "haut"), engine_p_mc(1:99, 70, "haut")))
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
verifier("engine_p_mc : NA dans sim exclus de B_eff (p = 2 (1+30)/100, err_mc et granularite sur B_eff = 99)",
         {
           d <- engine_p_mc(c(NA, 1:49, NA, 50:99, NA), 70, "deux")
           identical(d$B_effectif, 99) && proche(d$p_mc, 0.62) &&
             proche(d$err_mc, sqrt(0.62 * 1.38 / 99)) && proche(d$granularite, 0.02)
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
