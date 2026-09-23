###############################################################################
#  tests/unitaires/test_lois_exactes.R  --  LOIS EXACTES SOUS H0
#
#  Mann-Kendall (loi mahonienne), suites de Wald-Wolfowitz (Swed-Eisenhart),
#  Durbin-Watson (Imhof), moments de Z du test calendaire de Mack, loi nulle
#  simulee de Shapiro-Wilk.
#  References : enumeration exhaustive sur petit n, fonctions de stats::
#  (cor.test, pf, dbinom), valeurs de lmtest::dwtest ecrites en dur (voir
#  generer_valeurs_externes.R), simulation a graine fixe.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_lois_exactes.R")

# Toutes les permutations de 1..n (une par ligne), R base.
permutations <- function(n) {
  if (n == 1) return(matrix(1L, 1, 1))
  p <- permutations(n - 1)
  do.call(rbind, lapply(seq_len(n), function(k) cbind(k, ifelse(p >= k, p + 1L, p))))
}
# S de Kendall de chaque ligne d'une matrice (serie chronologique en ligne).
S_kendall <- function(M) {
  n <- ncol(M); S <- numeric(nrow(M))
  for (i in 1:(n - 1)) for (j in (i + 1):n) S <- S + sign(M[, j] - M[, i])
  S
}

z1 <- c(0.52, -1.31, 0.87, 1.64, -0.23, -0.95, 0.31, -0.48)
z2 <- c(1.2, 1.5, 0.9, 0.4, -0.3, -0.8, -1.1, -1.6)
z3 <- c(1, -1, 1.2, -0.8, 0.9, -1.1, 1.05, -0.9)

## --- Mann-Kendall -----------------------------------------------------------
for (n in 2:12) {
  d <- .mk_loi_exacte(n)
  verifier(sprintf("MK n=%d : loi exacte de S de masse 1 et symetrique", n),
           isTRUE(proche(sum(d$prob), 1, abs = 1e-14)) &&
           isTRUE(proche(d$prob, rev(d$prob), abs = 1e-15)) &&
           isTRUE(proche(d$S, -rev(d$S))))
}
# Enumeration exhaustive des n! permutations (n <= 7).
for (n in 3:7) {
  P <- permutations(n); S <- S_kendall(P)
  d <- .mk_loi_exacte(n)
  freq <- vapply(d$S, function(s) mean(S == s), numeric(1))
  verifier(sprintf("MK n=%d : loi mahonienne = enumeration des %d permutations", n, nrow(P)),
           proche(d$prob, freq, abs = 1e-14))
}
# Nombre de permutations de 4 elements a k inversions : 1 3 5 6 5 3 1
# (nombres de Mahon, OEIS A008302, ligne n = 4).
verifier("MK n=4 : effectifs mahoniens 1 3 5 6 5 3 1",
         proche(.mk_loi_exacte(4)$prob * 24, c(1, 3, 5, 6, 5, 3, 1), abs = 1e-12))
# Serie strictement croissante : seule l'identite atteint S = n(n-1)/2, et son
# symetrique S = -n(n-1)/2 : p = 2 / n!.
verifier("MK n=5 serie croissante : p exacte = 2/120",
         proche(mk_p_exacte(c(1, 2, 4, 7, 11)), 2 / 120, rel = 1e-12))
# p exacte = P(|S| >= |S_obs|) par enumeration, pour quelques series n = 7.
set.seed(101)
P7 <- permutations(7); S7 <- S_kendall(P7)
for (k in 1:4) {
  v <- stats::rnorm(7); Sobs <- S_kendall(matrix(v, 1))
  verifier(sprintf("MK n=7 serie %d : p exacte = enumeration", k),
           proche(mk_p_exacte(v), mean(abs(S7) >= abs(Sobs)), abs = 1e-12))
}
# Equivalence avec stats::cor.test(method = "kendall", exact = TRUE) : la loi
# de S etant symetrique, 2 min(P(S <= s), P(S >= s)) = P(|S| >= |s|).
set.seed(102)
for (n in c(5, 8, 10, 12)) {
  v <- stats::rnorm(n)
  verifier(sprintf("MK n=%d : p exacte = cor.test(kendall, exact = TRUE)", n),
           proche(mk_p_exacte(v),
                  stats::cor.test(seq_len(n), v, method = "kendall", exact = TRUE)$p.value,
                  rel = 1e-10))
}
verifier("MK : p exacte invariante par transformation croissante et par symetrie",
         isTRUE(proche(mk_p_exacte(exp(z1)), mk_p_exacte(z1))) &&
         isTRUE(proche(mk_p_exacte(3 + 2 * z1), mk_p_exacte(z1))) &&
         isTRUE(proche(mk_p_exacte(-z1), mk_p_exacte(z1))) &&
         isTRUE(proche(mk_p_exacte(rev(z1)), mk_p_exacte(z1))))
verifier("MK : p exacte NA avec ex aequo et au-dela de n = 12",
         is.na(mk_p_exacte(c(1, 2, 2, 3, 4))) && is.na(mk_p_exacte(1:13 + 0.5)))
verifier("MK : statistique asymptotique = cor.test(kendall, exact = FALSE, continuity = TRUE)",
         proche(test_mann_kendall(z1)$stat,
                stats::cor.test(seq_along(z1), z1, method = "kendall",
                                exact = FALSE, continuity = TRUE)$statistic, rel = 1e-10))
v_ea <- c(3, 1, 2, 2, 5, 4, 4, 6)
verifier("MK : variance corrigee des ex aequo = cor.test(kendall)",
         proche(test_mann_kendall(v_ea)$stat,
                suppressWarnings(stats::cor.test(seq_along(v_ea), v_ea, method = "kendall",
                                                 exact = FALSE, continuity = TRUE)$statistic),
                rel = 1e-10))

## --- Suites de Wald-Wolfowitz ------------------------------------------------
# Enumeration des choose(n, n1) arrangements de n1 signes + et n2 signes -.
runs_enum <- function(n1, n2) {
  n <- n1 + n2
  pos <- utils::combn(n, n1)
  apply(pos, 2, function(p) { s <- rep(-1, n); s[p] <- 1; 1 + sum(diff(s) != 0) })
}
for (cas in list(c(1, 1), c(2, 3), c(4, 4), c(3, 5), c(5, 4), c(6, 6))) {
  n1 <- cas[1]; n2 <- cas[2]; n <- n1 + n2
  d <- .runs_dens(n1, n2); R <- runs_enum(n1, n2)
  freq <- vapply(d$R, function(r) mean(R == r), numeric(1))
  verifier(sprintf("Suites n1=%d n2=%d : loi de Swed-Eisenhart = enumeration", n1, n2),
           proche(d$prob, freq, abs = 1e-14))
  # Moments de Wald & Wolfowitz (1940) : E = 1 + 2 n1 n2 / n,
  # V = 2 n1 n2 (2 n1 n2 - n) / (n^2 (n - 1)).
  if (n > 2) verifier(sprintf("Suites n1=%d n2=%d : moments de Wald-Wolfowitz", n1, n2),
           isTRUE(proche(sum(d$R * d$prob), 1 + 2 * n1 * n2 / n, rel = 1e-12)) &&
           isTRUE(proche(sum(d$R^2 * d$prob) - sum(d$R * d$prob)^2,
                         2 * n1 * n2 * (2 * n1 * n2 - n) / (n^2 * (n - 1)), rel = 1e-10)))
}
# p exacte bilaterale par enumeration directe, convention du DOUBLEMENT
# (issue #29, decision M8 ; Gibbons & Pratt, 1975, Amer. Statist. 29, 20-25) :
# 2 min(P(R <= R_obs), P(R >= R_obs)) bornee a 1, celle du bootstrap
# (queue = "deux"). Les frequences sont comptees sur les choose(n, n1)
# arrangements, sans passer par .runs_dens().
runs_p_enum <- function(z) {
  s <- sign(z - stats::median(z)); s <- s[s != 0]
  n1 <- sum(s > 0); n2 <- sum(s < 0); Robs <- 1 + sum(diff(s) != 0)
  R <- runs_enum(n1, n2)
  min(1, 2 * min(mean(R <= Robs), mean(R >= Robs)))
}
for (k in 1:3) {
  z <- list(z1, z2, z3)[[k]]
  verifier(sprintf("Suites : p exacte = enumeration (serie %d)", k),
           proche(runs_p_exacte(z), runs_p_enum(z), abs = 1e-12))
}
set.seed(103)
z7 <- stats::rnorm(7)     # n impair : la valeur egale a la mediane est ecartee
verifier("Suites n impair : p exacte = enumeration (mediane ecartee)",
         proche(runs_p_exacte(z7), runs_p_enum(z7), abs = 1e-12))
# n1 = n2 = 4 : P(R = 2) = P(R = 8) = 2 / C(8, 4) = 2/70. En doublement,
# p = 2 P(R <= 2) = 2 P(R >= 8) = 4/70 (valeur identique en vraisemblance
# minimale : cette assertion ne discrimine pas les deux conventions).
verifier("Suites : z2 (R = 2) et z3 (R = 8) ont la p minimale 4/70",
         isTRUE(proche(runs_p_exacte(z2), 4 / 70, rel = 1e-12)) &&
         isTRUE(proche(runs_p_exacte(z3), 4 / 70, rel = 1e-12)))
# Convention du doublement (issue #29, M8), valeurs ecrites en dur a partir de
# 70 P(R = 2..8) = (2, 6, 18, 18, 18, 6, 2) : z1 a R = 6 (signes + - + + - - + -),
# p = 2 P(R >= 6) = 2 x 26/70 = 52/70 = 0,743 ; la vraisemblance minimale
# donnerait 1 (R = 4, 5, 6 equiprobables). Assertion discriminante.
verifier("Suites (#29) : doublement, z1 (R = 6) -> p = 52/70, et non 1 (vraisemblance minimale)",
         identical(test_runs(z1)$runs, 6) &&
         isTRUE(proche(runs_p_exacte(z1), 52 / 70, rel = 1e-12)))
# Valeurs atteignables a T = 8 (n1 = n2 = 4) : sur les 70 arrangements des
# signes, la p exacte ne prend que 4 valeurs, 1 (R = 5), 52/70 = 0,743
# (R = 4, 6), 16/70 = 0,229 (R = 3, 7), 4/70 = 0,057 (R = 2, 8).
verifier("Suites (#29) : T = 8, valeurs atteignables {1 ; 0,743 ; 0,229 ; 0,057}",
         {
           pos <- utils::combn(8, 4)
           pv <- apply(pos, 2, function(p) { s <- rep(-1, 8); s[p] <- 1; runs_p_exacte(s) })
           vals <- sort(unique(round(pv, 12)), decreasing = TRUE)
           isTRUE(proche(vals, c(1, 52 / 70, 16 / 70, 4 / 70), abs = 1e-12)) &&
           isTRUE(all.equal(round(vals, 3), c(1, 0.743, 0.229, 0.057)))
         })
# T = 5 (n1 = n2 = 2 apres ecart de la valeur mediane) : R uniforme sur
# {2, 3, 4} ; en doublement p = 2/3 pour R = 2 ou 4, 1 pour R = 3 (la
# vraisemblance minimale donnerait 1 quel que soit R).
verifier("Suites (#29) : T = 5, p exacte = 2/3 (R = 2, 4) ou 1 (R = 3), ensemble {0,667 ; 1}",
         {
           s5 <- list(c(-2, -1, 0, 1, 2), c(2, 1, 0, -1, -2),       # R = 2
                      c(1, -1, 0, -2, 2), c(-1, 1, 0, 2, -2),       # R = 3
                      c(1, -1, 0, 2, -2), c(-1, 1, 0, -2, 2))       # R = 4
           R5 <- vapply(s5, function(v) test_runs(v)$runs, numeric(1))
           p5 <- vapply(s5, runs_p_exacte, numeric(1))
           identical(R5, c(2, 2, 3, 3, 4, 4)) &&
           isTRUE(proche(p5, c(2, 2, 3, 3, 2, 2) / 3, abs = 1e-12)) &&
           isTRUE(proche(p5, vapply(s5, runs_p_enum, numeric(1)), abs = 1e-12)) &&
           isTRUE(all.equal(sort(unique(round(p5, 3))), c(0.667, 1)))
         })
verifier("Suites : p exacte invariante par transformation croissante",
         proche(runs_p_exacte(exp(z1)), runs_p_exacte(z1)))
verifier("Suites : NA si un seul cote de la mediane est represente",
         is.na(runs_p_exacte(c(1, 1, 1, 1, 2))))
# Statistique asymptotique : Z = (R - E) / sqrt(V), E et V calcules ici par
# enumeration (et non par la formule utilisee par le moteur).
verifier("Suites : Z asymptotique = (R - E) / sqrt(V), moments par enumeration",
         {
           s <- sign(z1 - stats::median(z1)); R <- runs_enum(4, 4)
           Robs <- 1 + sum(diff(s) != 0)
           isTRUE(proche(test_runs(z1)$stat, (Robs - mean(R)) / sqrt(mean(R^2) - mean(R)^2),
                         rel = 1e-10))
         })
# Signe de Z : une serie regroupee (4 valeurs sous la mediane puis 4 au-dessus,
# R = 2 < E = 5) a trop peu de suites, donc Z < 0 ; une serie alternee (R = 8)
# en a trop, donc Z > 0. Assertion independante de la convention bilaterale
# de runs_p_exacte() (seule la statistique Z est lue).
verifier("Suites : Z < 0 pour une serie regroupee (R = 2), Z > 0 pour une serie alternee (R = 8)",
         {
           rg <- test_runs(c(-1, -1, -1, -1, 1, 1, 1, 1))
           al <- test_runs(c(-1, 1, -1, 1, -1, 1, -1, 1))
           identical(rg$runs, 2) && rg$stat < 0 && identical(al$runs, 8) && al$stat > 0
         })
# T = 5 : test_runs() et runs_p_exacte() ecartent la valeur egale a la mediane
# (s[s != 0]), d'ou n1 = n2 = 2. Les 6 arrangements de ++-- donnent
# R = 2 (++--, --++), R = 3 (+--+, -++-), R = 4 (+-+-, -+-+) : loi uniforme
# sur {2, 3, 4}, verifiee par l'enumeration et par la valeur 1/3 ecrite en dur.
verifier("Suites T = 5 (n1 = n2 = 2) : .runs_dens(2, 2) uniforme sur {2, 3, 4}",
         {
           d22 <- .runs_dens(2, 2); R22 <- runs_enum(2, 2)
           isTRUE(all.equal(d22$R, 2:4)) &&
           isTRUE(proche(d22$prob, rep(1 / 3, 3), abs = 1e-14)) &&
           isTRUE(proche(d22$prob, as.numeric(table(factor(R22, levels = 2:4))) / 6,
                         abs = 1e-14))
         })
# Dichotomie a T = 5 : 1:5 -> mediane 3 ecartee, signes --++, R = 2 ; Z calcule
# avec n1 = n2 = 2 (E = 3, V = 2/3), et non avec n = 5.
verifier("Suites T = 5 : mediane ecartee, Z = (2 - 3) / sqrt(2/3)",
         identical(test_runs(1:5)$runs, 2) &&
         isTRUE(proche(test_runs(1:5)$stat, -1 / sqrt(2 / 3), rel = 1e-12)))
# Coherence loi simulee / loi exacte. Sous H0 (8 tirages i.i.d. continus), les
# 70 arrangements des signes par rapport a la mediane sont equiprobables, donc
# le R compte par test_runs() suit .runs_dens(4, 4). On simule N = 10 000
# series i.i.d. N(0, 1) et on compare les frequences de R aux probabilites
# exactes, classe par classe, a 4 ecarts-types binomiaux sqrt(p (1 - p) / N)
# (risque de fausse alerte < 7e-5 par classe sous l'approximation normale,
# < 5e-4 pour les 7 classes ; la graine est fixe, le resultat est donc
# deterministe). Ce que l'assertion prouve : la chaine de test_runs()
# (dichotomie par la mediane, comptage de R) appliquee a des tirages i.i.d.
# reproduit la loi exacte, a l'erreur Monte-Carlo pres ; un ecart de
# probabilite superieur a ~0,018 sur une classe centrale serait detecte. Ce
# qu'elle ne prouve pas : que le bootstrap parametrique de usp_bootstrap()
# reproduise cette loi. Celui-ci simule sous le modele ajuste et recalcule
# les residus apres re-estimation ; ces residus ne sont pas i.i.d., et la loi
# de R qui en resulte n'a pas a coincider avec .runs_dens(4, 4). Elle ne dit
# rien non plus de la convention bilaterale de runs_p_exacte() (#29).
verifier("Suites : loi de R simulee (i.i.d., N = 10 000) = .runs_dens(4, 4) a 4 ecarts-types",
         {
           avant <- if (exists(".Random.seed", envir = globalenv()))
                      get(".Random.seed", envir = globalenv()) else NULL
           set.seed(107); N <- 10000
           Rsim <- vapply(seq_len(N), function(i) test_runs(stats::rnorm(8))$runs,
                          numeric(1))
           if (!is.null(avant)) assign(".Random.seed", avant, envir = globalenv())
           d44 <- .runs_dens(4, 4)
           fsim <- vapply(d44$R, function(r) mean(Rsim == r), numeric(1))
           all(Rsim %in% d44$R) &&
           all(abs(fsim - d44$prob) <= 4 * sqrt(d44$prob * (1 - d44$prob) / N))
         })

## --- Issue #29 (M8) : p exacte du test des suites sur ratios bruts ---------
# usp_runsr_p_exacte() n'attribue la p exacte a la ligne Runsr que si DEUX
# conditions tiennent : pi_constant (usp_regime(), tolerance TOL_DELTA_BORD) et
# identite effective des signes de z_t - med(z) et de u_t - med(u), u = r -
# moyenne(r) etant le vecteur effectivement teste. A pi_t
# EXACTEMENT constant la seconde decoule de la premiere (transformation
# monotone) ; dans la bande de tolerance elle peut tomber, et le cas
# f29_bande ci-dessous en est un exemple construit. Chaque condition est
# testee isolement (deux mutations), puis dans usp_tests().
x29 <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y29 <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
f29 <- usp_ajuster(x29, y29)                        # delta = 1 : pi_t constant
f29_0 <- usp_ajuster(x29[1:5], y29[1:5])            # delta = 0 : pi_t variable
# Cas construit : delta = 1 - TOL_DELTA_BORD / 2 (pi_constant vrai a la
# tolerance pres) et deux ratios centraux distants de 1e-10 relatif ; le
# terme 1/(2 pi_t) de z_t les ordonne a l'inverse des r_t, donc les signes
# des deux annees centrales s'echangent.
f29_bande <- local({
  d <- 1 - TOL_DELTA_BORD / 2; r <- y29 / x29; o <- order(r)
  r[o[5]] <- r[o[4]] * (1 - 1e-10); yy <- r * x29
  c(usp_noyau(d, f29$gamma, x29, yy),
    list(delta = d, gamma = f29$gamma, T = length(x29), x = x29, y = yy,
         xbar = mean(x29), convergence = 0L, part_starts_convergents = 1,
         delta_au_bord = usp_regime(d, x29)$delta_au_bord))
})
u_de <- function(f) { r <- f$y / f$x; r - mean(r) }
signes_egaux <- function(f) {
  u <- u_de(f)
  all(sign(f$z - stats::median(f$z)) == sign(u - stats::median(u)))
}
boot29 <- function(f) {
  s <- .stats_bootstrapables(f$x, f$y, f$z)
  p <- stats::setNames(rep(0.5, length(s)), names(s))
  list(stats_obs = as.list(s), p_mc = p, err_mc = p * 0 + 0.01)
}
ligne29 <- function(f, nom) Filter(function(l) l$test == nom, usp_tests(f, boot29(f)))[[1]]
verifier("Runsr (#29) : les trois cas couvrent les trois combinaisons des deux conditions",
         isTRUE(usp_regime(f29$delta, f29$x)$pi_constant) && signes_egaux(f29) &&
         !isTRUE(usp_regime(f29_0$delta, f29_0$x)$pi_constant) &&
         isTRUE(usp_regime(f29_bande$delta, f29_bande$x)$pi_constant) &&
         !isTRUE(usp_regime(f29_bande$delta, f29_bande$x)$pi_constant_exact) &&
         !signes_egaux(f29_bande))
verifier("Runsr (#29) : usp_runsr_p_exacte() = runs_p_exacte(u) si les deux conditions tiennent",
         {
           u <- u_de(f29)
           isTRUE(proche(usp_runsr_p_exacte(f29$z, u, TRUE), runs_p_exacte(u), abs = 0)) &&
           isTRUE(proche(usp_runsr_p_exacte(f29$z, u, TRUE), 52 / 70, rel = 1e-12))
         })
verifier("Runsr (#29) : mutation 1, pi_constant FALSE a signes identiques -> NA",
         {
           u <- u_de(f29)
           is.na(usp_runsr_p_exacte(f29$z, u, FALSE)) &&
           is.na(usp_runsr_p_exacte(f29$z, u, NA))
         })
verifier("Runsr (#29) : mutation 2, pi_constant TRUE a signes differents -> NA",
         {
           u <- u_de(f29)
           zp <- f29$z[c(2:8, 1)]                    # memes valeurs, signes decales
           !all(sign(zp - stats::median(zp)) == sign(u - stats::median(u))) &&
           is.na(usp_runsr_p_exacte(zp, u, TRUE))
         })
verifier("Runsr (#29) : pi_t constant (delta = 1), Runs et Runsr portent la meme p_retenue exacte",
         {
           a <- ligne29(f29, "Test des suites (aleatoire des signes)")
           b <- ligne29(f29, "Test des suites sur ratios bruts")
           identical(a$stat, b$stat) && identical(a$p_retenue, b$p_retenue) &&
           identical(b$nature_p, "exacte") && identical(b$p_exacte, b$p_retenue) &&
           isTRUE(proche(b$p_retenue, 52 / 70, rel = 1e-12))
         })
verifier("Runsr (#29) : pi_t variable (T = 5, delta = 0), pas de p exacte, Monte-Carlo retenue",
         {
           b <- ligne29(f29_0, "Test des suites sur ratios bruts")
           is.na(b$p_exacte) && identical(b$nature_p, "Monte-Carlo (bootstrap parametrique)") &&
           identical(b$p_retenue, 0.5)
         })
verifier("Runsr (#29) : pi_constant vrai mais signes differents (bande de tolerance), pas de p exacte",
         {
           b <- ligne29(f29_bande, "Test des suites sur ratios bruts")
           is.na(b$p_exacte) && identical(b$nature_p, "Monte-Carlo (bootstrap parametrique)")
         })
# Divergence flottante r / u (revue d'audit du commit #29) : r a deux valeurs
# centrales distantes de 1 ulp relatif ; r_5 - med(r) vaut 0 exactement,
# u_5 - med(u) vaut un negatif apres le centrage par la moyenne. La
# condition porte sur u, le vecteur teste : avec z = u elle tient, avec
# z = r (signes de r) elle tombe.
verifier("Runsr (#29) : condition de signes sur u = r - moyenne(r), non sur r (divergence flottante)",
         {
           r <- c(0.53089313523378223, 0.60298728744965047, 0.58827837626449764,
                  0.8435114233288914, 0.69205185910686851, 0.88492070999927819,
                  0.69205185910686862, 0.85880925413221121)
           u <- r - mean(r)
           sr <- sign(r - stats::median(r)); su <- sign(u - stats::median(u))
           if (all(sr == su)) "cas non discriminant sur cette plateforme : signes de r et u egaux"
           else is.na(usp_runsr_p_exacte(r, u, TRUE)) &&
             isTRUE(proche(usp_runsr_p_exacte(u, u, TRUE), runs_p_exacte(u), abs = 0))
         })
# Cas de bout en bout a volumes constants (pi_t exactement constant quel que
# soit delta) : T = 5 (T impair, valeur mediane ecartee, n1 = n2 = 2) et
# T = 8 avec deux ratios ex aequo sur la mediane (n1 = n2 = 3). Les p
# attendues sont recalculees par l'enumeration independante runs_p_enum().
f29_t5 <- usp_ajuster(rep(100, 5), c(66, 70, 75, 82, 91))     # signes - - 0 + +, R = 2
f29_ea <- usp_ajuster(rep(100, 8), c(70, 82, 75, 75, 66, 90, 60, 88))
verifier("Runsr (#29) : T = 5 a volumes constants, p exacte = 2/3 par usp_tests()",
         {
           b <- ligne29(f29_t5, "Test des suites sur ratios bruts")
           a <- ligne29(f29_t5, "Test des suites (aleatoire des signes)")
           isTRUE(usp_regime(f29_t5$delta, f29_t5$x)$pi_constant_exact) &&
           identical(b$nature_p, "exacte") && identical(a$p_retenue, b$p_retenue) &&
           isTRUE(proche(b$p_retenue, 2 / 3, rel = 1e-12)) &&
           isTRUE(proche(b$p_retenue, runs_p_enum(u_de(f29_t5)), abs = 1e-12))
         })
verifier("Runsr (#29) : ex aequo sur la mediane (T = 8, n1 = n2 = 3), p exacte = enumeration",
         {
           u <- u_de(f29_ea)
           b <- ligne29(f29_ea, "Test des suites sur ratios bruts")
           sum(u == stats::median(u)) == 2 && signes_egaux(f29_ea) &&
           identical(b$nature_p, "exacte") &&
           isTRUE(proche(b$p_retenue, runs_p_enum(u), abs = 1e-12)) &&
           isTRUE(proche(b$p_retenue, 0.2, rel = 1e-12))
         })
# Champs loi et detail de Runsr, par regime (revue d'audit et d'actuary).
cas_runsr <- list(f29 = f29, f29_0 = f29_0, f29_bande = f29_bande,
                  f29_t5 = f29_t5, f29_ea = f29_ea)
verifier("Runsr (#29) : loi et detail contiennent EXACTE si et seulement si nature_p = exacte",
         {
           ok <- vapply(cas_runsr, function(f) {
             b <- ligne29(f, "Test des suites sur ratios bruts")
             ex <- identical(b$nature_p, "exacte")
             ex == grepl("EXACTE", b$loi, fixed = TRUE) &&
               ex == grepl("EXACTE", b$detail, fixed = TRUE)
           }, logical(1))
           if (all(ok)) TRUE else paste("cas en defaut :", paste(names(ok)[!ok], collapse = ", "))
         })
verifier("Runsr (#29) : detail du regime 1 a pi_t exactement constant, sans variante de tolerance",
         {
           d <- ligne29(f29, "Test des suites sur ratios bruts")$detail
           grepl("IDENTIQUE", d, fixed = TRUE) && grepl("doublement", d, fixed = TRUE) &&
             !grepl("n'est constant qu'a la tolerance", d, fixed = TRUE)
         })
verifier("Runsr (#29) : bande de tolerance a signes differents, identite 'n'est plus garantie', pas d'IDENTIQUE",
         {
           d <- ligne29(f29_bande, "Test des suites sur ratios bruts")$detail
           grepl("n'est plus garantie", d, fixed = TRUE) && !grepl("IDENTIQUE", d, fixed = TRUE) &&
             grepl("TOL_DELTA_BORD = 1e-06 pres (1 - delta = 5e-07)", d, fixed = TRUE)
         })
verifier("Runsr (#29) : pi_t variable (T = 5, delta = 0), detail 'heteroscedastiques'",
         {
           d <- ligne29(f29_0, "Test des suites sur ratios bruts")$detail
           grepl("heteroscedastiques", d, fixed = TRUE) && !grepl("SANS OBJET", d, fixed = TRUE)
         })
verifier("Runsr (#29) : variante 1b, pi_t constant a la tolerance pres avec signes identiques",
         {
           f <- local({
             d <- 1 - TOL_DELTA_BORD / 2
             c(usp_noyau(d, f29$gamma, x29, y29),
               list(delta = d, gamma = f29$gamma, T = length(x29), x = x29, y = y29,
                    xbar = mean(x29), convergence = 0L, part_starts_convergents = 1,
                    delta_au_bord = usp_regime(d, x29)$delta_au_bord))
           })
           b <- ligne29(f, "Test des suites sur ratios bruts")
           signes_egaux(f) && identical(b$nature_p, "exacte") &&
             grepl("exacte a cet ordre pres", b$detail, fixed = TRUE) &&
             grepl("TOL_DELTA_BORD = 1e-06 pres (1 - delta = 5e-07)", b$detail, fixed = TRUE)
         })
verifier("Base r (#29) : les cinq autres detail ne disent plus 'statistique est meme identique'",
         {
           nn <- c("Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts",
                   "Ljung-Box (retard 1) sur ratios bruts",
                   "Rupture de niveau (sup-F) sur ratios bruts",
                   "Stabilite cumulee (OLS-CUSUM) sur ratios bruts",
                   "Valeur aberrante isolee (Grubbs) sur ratios bruts")
           dd <- unlist(lapply(cas_runsr, function(f)
             vapply(nn, function(n) ligne29(f, n)$detail, character(1))))
           dc <- vapply(nn, function(n) ligne29(f29, n)$detail, character(1))
           !any(grepl("statistique est meme identique", dd, fixed = TRUE)) &&
             all(grepl("transformation logarithmique.", dc, fixed = TRUE))
         })
verifier("Base r (#29) : DWr, LB1r, supFr, CUSUMr, Grubbsr restent en Monte-Carlo, pi_t constant ou non",
         {
           nn <- c("Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts",
                   "Ljung-Box (retard 1) sur ratios bruts",
                   "Rupture de niveau (sup-F) sur ratios bruts",
                   "Stabilite cumulee (OLS-CUSUM) sur ratios bruts",
                   "Valeur aberrante isolee (Grubbs) sur ratios bruts")
           all(vapply(list(f29, f29_0, f29_bande), function(f)
             all(vapply(nn, function(n) {
               l <- ligne29(f, n)
               is.na(l$p_exacte) && identical(l$nature_p, "Monte-Carlo (bootstrap parametrique)")
             }, logical(1))), logical(1)))
         })

## --- Durbin-Watson : loi exacte ---------------------------------------------
# Controle de l'integrale d'Imhof sur une forme dont la loi est connue :
# Q = chi2_k - c chi2_1 (independants), P(Q < 0) = P(F(k, 1) < c / k).
for (k in c(1, 3, 5)) for (cc in c(0.5, 7)) {
  h <- c(rep(1, k), -cc)
  verifier(sprintf("Imhof : forme chi2_%d - %.1f chi2_1, P(Q < 0) = pf(c/k, %d, 1)", k, cc, k),
           proche(.imhof_p_sup0(h), stats::pf(cc / k, k, 1), abs = 1e-7))
}
verifier("Imhof : les valeurs pour h et -h sont complementaires",
         proche(.imhof_p_sup0(c(2, 1, -0.7)) + .imhof_p_sup0(-c(2, 1, -0.7)), 1, abs = 1e-8))
# Valeurs de reference : lmtest::dwtest(z ~ 1, exact = TRUE, alternative =
# "two.sided"), algorithme de Pan, independant d'Imhof (lmtest 0.9-40).
verifier("DW exacte = lmtest::dwtest (Pan), z1",
         proche(dw_p_exacte(z1), 0.732330931379162, rel = 1e-7))
verifier("DW exacte = lmtest::dwtest (Pan), z2 (forte autocorrelation positive)",
         proche(dw_p_exacte(z2), 9.09462245183251e-06, rel = 1e-5))
verifier("DW exacte = lmtest::dwtest (Pan), z3 (autocorrelation negative)",
         proche(dw_p_exacte(z3), 0.00469722960450603, rel = 1e-6))
# Controle par simulation (graine fixe, 1e5 tirages N(0, 1), T = 8) :
# erreur-type Monte-Carlo de la p bilaterale <= 0,0032 ; tolerance 0,01.
set.seed(104)
Zs <- matrix(stats::rnorm(1e5 * 8), ncol = 8)
Zc <- Zs - rowMeans(Zs)
DWs <- rowSums((Zc[, -1] - Zc[, -8])^2) / rowSums(Zc^2)
for (k in 1:2) {
  z <- list(z1, c(0.3, -0.2, 0.9, 1.1, 0.4, -0.6, -1.2, -0.5))[[k]]
  d <- stat_dw(z)
  p_emp <- 2 * min(mean(DWs <= d), mean(DWs >= d))
  verifier(sprintf("DW exacte = simulation a 0,01 pres (serie %d)", k),
           proche(dw_p_exacte(z), p_emp, abs = 0.01))
}
verifier("DW : p exacte invariante par z -> a + b z (b < 0 compris) et par retournement",
         isTRUE(proche(dw_p_exacte(5 - 3 * z1), dw_p_exacte(z1), rel = 1e-8)) &&
         isTRUE(proche(dw_p_exacte(rev(z1)), dw_p_exacte(z1), rel = 1e-8)))
verifier("DW : p dans [0, 1] et NA pour T < 4",
         all(vapply(list(z1, z2, z3), dw_p_exacte, numeric(1)) >= 0) &&
         all(vapply(list(z1, z2, z3), dw_p_exacte, numeric(1)) <= 1) &&
         is.na(dw_p_exacte(c(1, 2, 0))))
# Constat d'audit : le nom et le commentaire annoncent P(Q > 0), la fonction
# renvoie P(Q < 0) (0,5 - integrale / pi, alors qu'Imhof 1961 donne
# P(Q > x) = 0,5 + integrale / pi). Sans effet sur la p bilaterale de
# dw_p_exacte, symetrique ; toute utilisation unilaterale serait inversee.
# Issue #33 (defaut releve par audit, repris de l'issue #7)
echec_attendu(".imhof_p_sup0 renvoie P(Q > 0) comme annonce",
              "constat audit : renvoie P(Q < 0)",
              isTRUE(proche(.imhof_p_sup0(c(1, -0.5)),
                            stats::pf(0.5, 1, 1, lower.tail = FALSE), abs = 1e-7)))

## --- Moments de Z = min(L, n - L), test calendaire de Mack --------------------
for (n in 2:15) {
  l <- 0:n; pz <- stats::dbinom(l, n, 0.5); zz <- pmin(l, n - l)
  m <- .mack_moments_Z(n)
  verifier(sprintf("Mack : E et V de Z exacts (loi binomiale), n = %d", n),
           isTRUE(proche(m[["E"]], sum(zz * pz), rel = 1e-12, abs = 1e-14)) &&
           isTRUE(proche(m[["V"]], sum(zz^2 * pz) - sum(zz * pz)^2, rel = 1e-10, abs = 1e-14)))
}
verifier("Mack : moments nuls pour n < 2", all(.mack_moments_Z(1) == 0))

## --- Shapiro-Wilk : loi nulle simulee ---------------------------------------
w_null <- sw_loi_nulle(8)
verifier("SW simulee : p dans [1/(B+1), 1] et croissante en W",
         {
           W <- seq(0.6, 1, by = 0.01); p <- vapply(W, sw_p_loi_nulle, numeric(1), n = 8)
           all(p >= 1 / (length(w_null) + 1)) && all(p <= 1) && all(diff(p) >= 0)
         })
verifier("SW simulee : NA si W non fini ou n < 3",
         is.na(sw_p_loi_nulle(NA, 8)) && is.na(sw_p_loi_nulle(0.9, 2)))
# Coherence avec la normalisation de Royston (shapiro.test) : ecart attendu =
# erreur Monte-Carlo (<= 0,0036 pour 20 000 tirages) + erreur d'approximation
# de Royston ; tolerance 0,02.
set.seed(105)
ecarts <- vapply(1:8, function(k) {
  v <- stats::rnorm(8); s <- stats::shapiro.test(v)
  abs(sw_p_loi_nulle(unname(s$statistic), 8) - s$p.value)
}, numeric(1))
verifier("SW simulee : coherente avec shapiro.test (Royston) a 0,02 pres", max(ecarts) <= 0.02)
verifier("SW simulee : etat du generateur restaure s'il existait",
         {
           set.seed(106); avant <- .Random.seed
           sw_loi_nulle(9, B_null = 300, seed = 3)
           identical(avant, .Random.seed)
         })

fin_fichier()
