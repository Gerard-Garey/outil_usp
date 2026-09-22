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
# p exacte (methode de la densite) par enumeration directe.
runs_p_enum <- function(z) {
  s <- sign(z - stats::median(z)); s <- s[s != 0]
  n1 <- sum(s > 0); n2 <- sum(s < 0); Robs <- 1 + sum(diff(s) != 0)
  R <- runs_enum(n1, n2); pr <- table(R) / length(R)
  sum(pr[pr <= pr[as.character(Robs)] + 1e-12])
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
# n1 = n2 = 4 : P(R = 2) = P(R = 8) = 2 / C(8, 4) = 2/70 sont les deux issues
# les moins probables ; la p (methode de la densite) vaut donc 4/70.
verifier("Suites : z2 (R = 2) et z3 (R = 8) ont la p minimale 4/70",
         isTRUE(proche(runs_p_exacte(z2), 4 / 70, rel = 1e-12)) &&
         isTRUE(proche(runs_p_exacte(z3), 4 / 70, rel = 1e-12)))
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
