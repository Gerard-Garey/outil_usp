###############################################################################
#  tests/unitaires/test_mk_spearman.R  --  CORRELATION ENTRE S DE MANN-KENDALL
#                                          ET RHO DE SPEARMAN CONTRE LE TEMPS,
#                                          SOUS H0, A T = 8 (ISSUE #420, POINT 1)
#
#  Les fiches Mann-Kendall et Spearman du document justifient une decision de
#  diagnostic par la forte correlation de S et de rho contre le temps. Ce
#  fichier la chiffre par ENUMERATION EXACTE des 8! = 40 320 ordres
#  equiprobables (aucun tirage : resultat exact, pas un constat de simulation).
#
#  Resultat (specification d'actuary-approfondi, avis 0b (iv), mesure) :
#    corr(S, rho) = 2 (T + 1) / sqrt(2 T (2 T + 5)) = 0,981980506061966 a T = 8,
#    soit corr^2 = 27/28, controle EXACT en entiers : 28 Cov^2 = 27 Var(S) Var(D)
#    avec D = somme des t * R_t, dont rho est une fonction affine.
#
#  Demonstration elementaire (decision du mainteneur du 04/11/2026). Sous H0,
#  les rangs R_1, ..., R_n forment une permutation uniforme de 1..n, et
#    S = somme sur i < j de sign(R_j - R_i),   D = somme sur t de t R_t.
#    - Pour t hors de {i, j}, E[sign(R_j - R_i) R_t] = 0 : l'echange de R_i et
#      de R_j change le signe et laisse R_t (loi inchangee).
#    - E[sign(R_j - R_i) R_j] = (n + 1) / 6 (et E[sign(R_j - R_i) R_i] est son
#      oppose, par le meme echange).
#    - D'ou Cov(S, D) = (n + 1) / 6 * somme sur i < j de (j - i)
#                     = (n + 1) / 6 * n (n - 1) (n + 1) / 6.
#    - Var(S) = n (n - 1) (2 n + 5) / 18 (65,333... a n = 8).
#    - Var(D) = (n (n^2 - 1) / 12)^2 / (n - 1).
#    - Le quotient Cov / sqrt(Var(S) Var(D)) vaut 2 (n + 1) / sqrt(2 n (2 n + 5)).
#  Aucune source bibliographique n'est invoquee : le resultat repose sur
#  l'enumeration exacte et la demonstration ci-dessus.
#
#  Fonctions du moteur : test_mann_kendall() (S) et stats::cor(method =
#  "spearman") sont confrontees aux formules directes sur un echantillon de 404
#  permutations (une sur cent) ; l'enumeration complete utilise les formules
#  directes, vectorisees. Attention : la ligne SpearTps du moteur (R/engine.R,
#  entree SpearTps du catalogue Monte-Carlo) prend $statistic de
#  stats::cor.test(method = "spearman"), c'est-a-dire sum d^2 =
#  (n^3 - n) (1 - rho) / 6, fonction affine DECROISSANTE de rho : la
#  correlation de S avec la statistique du moteur vaut donc -0,98198... (meme
#  valeur absolue, signe oppose).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_mk_spearman.R")

n <- 8L

# Toutes les permutations de 1..k, une par ligne (insertion de k dans les
# permutations de 1..k-1), R base seul ; l'ordre des lignes est sans effet.
.permutations <- function(k) {
  if (k == 1L) return(matrix(1L, 1L, 1L))
  p <- .permutations(k - 1L)
  do.call(rbind, lapply(seq_len(k), function(pos) {
    cbind(p[, seq_len(pos - 1L), drop = FALSE], k,
          p[, seq_len(k - 1L)[seq_len(k - 1L) >= pos], drop = FALSE])
  }))
}
P <- .permutations(n)
storage.mode(P) <- "integer"

verifier("Enumeration : 8! = 40 320 permutations, toutes distinctes, chacune de 1..8",
         nrow(P) == factorial(n) && ncol(P) == n &&
           !anyDuplicated(apply(P, 1, paste, collapse = "")) &&
           all(apply(P, 1, function(r) all(sort(r) == seq_len(n)))))

# S = somme sur i < j de sign(R_j - R_i) ; D = somme de t * R_t (entiers).
S <- integer(nrow(P))
for (i in 1:(n - 1)) for (j in (i + 1):n) S <- S + as.integer(sign(P[, j] - P[, i]))
D <- as.vector(P %*% seq_len(n))
rho <- (12 * D - 3 * n * (n + 1)^2) / (n * (n^2 - 1))   # rho = 1 - 6 sum d^2 / (n (n^2 - 1))

## --- 1. Les formules directes coincident avec le moteur ------------------------
# Echantillon fixe (une permutation sur 100, sans aleatoire) : S du moteur
# (test_mann_kendall()) et rho de cor() sur les rangs.
ech <- seq(1L, nrow(P), by = 100L)
S_moteur   <- vapply(ech, function(k) test_mann_kendall(as.numeric(P[k, ]))$S, numeric(1))
rho_stats  <- vapply(ech, function(k) stats::cor(P[k, ], seq_len(n), method = "spearman"), numeric(1))
verifier("S de la formule directe = S de test_mann_kendall() sur 404 permutations",
         identical(as.numeric(S[ech]), S_moteur) && length(ech) == 404L)
verifier("rho de la formule directe = cor(method = \"spearman\") sur les memes permutations",
         isTRUE(proche(rho[ech], rho_stats, rel = 1e-12, abs = 1e-12)))

## --- 2. Moments exacts de S et de D ------------------------------------------
N <- nrow(P)
# E[D] = (n + 1)/2 * n (n + 1)/2 = n (n + 1)^2 / 4 = 162 a n = 8 : D' = 2 D - 324
# = 2 (D - E[D]) est entier, de moyenne nulle.
Dp <- 2 * D - n * (n + 1)^2 / 2
verifier("E[D] = n (n + 1)^2 / 4 = 162 et E[S] = 0, en entiers",
         sum(D) == N * n * (n + 1)^2 / 4 && sum(D) == N * 162 && sum(S) == 0)
var_S_formule <- n * (n - 1) * (2 * n + 5) / 18
verifier("Var(S) = n (n - 1) (2 n + 5) / 18 = 65,333... : 18 sum(S^2) = N n (n - 1) (2 n + 5)",
         18 * sum(as.numeric(S)^2) == N * n * (n - 1) * (2 * n + 5) &&
           isTRUE(proche(sum(as.numeric(S)^2) / N, var_S_formule, rel = 1e-14)))
var_D_formule <- (n * (n^2 - 1) / 12)^2 / (n - 1)
verifier("Var(D) = (n (n^2 - 1) / 12)^2 / (n - 1) = 252 : sum(D'^2) = 4 N Var(D)",
         sum(Dp^2) == 4 * N * 252 && var_D_formule == 252)
verifier("Cov(S, D) = (n + 1)/6 * n (n - 1)(n + 1)/6 = 126 : sum(S D') = 2 N Cov",
         sum(as.numeric(S) * Dp) == 2 * N * 126 &&
           (n + 1) / 6 * n * (n - 1) * (n + 1) / 6 == 126)

## --- 3. Correlation : controle exact en entiers, puis valeur -------------------
# 28 Cov^2 = 27 Var(S) Var(D), avec les sommes entieres (le facteur N^2 et le
# facteur 2 de D' se simplifient des deux cotes) : 28 (sum S D')^2 =
# 27 (sum S^2)(sum D'^2) ; produits < 2^53 (environ 3e15), donc exacts en double.
sSD <- sum(as.numeric(S) * Dp); sSS <- sum(as.numeric(S)^2); sDD <- sum(Dp^2)
verifier("Controle exact en entiers : 28 (sum S D')^2 = 27 (sum S^2)(sum D'^2), corr^2 = 27/28",
         28 * sSD^2 == 27 * sSS * sDD && max(28 * sSD^2, 27 * sSS * sDD) < 2^53)
r_enum <- stats::cor(S, rho)
r_formule <- 2 * (n + 1) / sqrt(2 * n * (2 * n + 5))
verifier("corr(S, rho) enumeree = 0,981980506061966 (specification d'actuary)",
         isTRUE(proche(r_enum, 0.981980506061966, rel = 1e-14)))
verifier("corr(S, rho) enumeree = 2 (T + 1) / sqrt(2 T (2 T + 5)) a T = 8",
         isTRUE(proche(r_enum, r_formule, rel = 1e-14)))
verifier("corr(S, rho)^2 = 27/28",
         isTRUE(proche(r_enum^2, 27 / 28, rel = 1e-14)))

## --- 4. Signe : statistique du moteur (sum d^2 de cor.test) -------------------
# sum d^2 = (n^3 - n) (1 - rho) / 6 sur toutes les permutations ; cor.test()
# (exact = FALSE) rend cette grandeur dans $statistic, confrontee sur l'echantillon.
sd2 <- rowSums((P - matrix(seq_len(n), N, n, byrow = TRUE))^2)
sd2_moteur <- vapply(ech, function(k)
  unname(suppressWarnings(stats::cor.test(P[k, ], seq_len(n), method = "spearman",
                                          exact = FALSE)$statistic)), numeric(1))
verifier("$statistic de cor.test = sum d^2 = (n^3 - n)(1 - rho)/6 (echantillon)",
         isTRUE(proche(sd2_moteur, sd2[ech], rel = 1e-12, abs = 1e-12)) &&
           isTRUE(proche(sd2, (n^3 - n) * (1 - rho) / 6, rel = 1e-12, abs = 1e-12)))
verifier("corr(S, sum d^2) = -corr(S, rho) = -0,981980506061966 (signe oppose)",
         isTRUE(proche(stats::cor(S, sd2), -r_enum, rel = 1e-14)) &&
           isTRUE(proche(stats::cor(S, sd2), -0.981980506061966, rel = 1e-14)))

fin_fichier()
