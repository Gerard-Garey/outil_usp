source("R/engine.R")
set.seed(20261015)
T <- 8; R <- 100000
Z <- matrix(rnorm(R * T), R, T)
## 1. Grubbs : borne de Bonferroni vs loi exacte simulee (i.i.d. normal)
G <- apply(Z, 1, function(v) max(abs(v - mean(v))) / sd(v))
bonf <- function(g, n = T) { tt <- sqrt(n * (n - 2) * g^2 / ((n - 1)^2 - n * g^2)); pmin(1, 2 * n * (1 - pt(tt, n - 2))) }
cat("Grubbs T=8 : seuil de disjonction sqrt((T-1)/2) =", sqrt((T - 1) / 2), "\n")
for (g in c(1.6, 1.75, 1.871, 1.9, 2.0, 2.03, 2.1, 2.2, 2.3)) cat(sprintf("g=%.3f  P_sim(G>g)=%.4f  Bonferroni=%.4f\n", g, mean(G > g), bonf(g)))
cat("quantile 90% de G simule :", quantile(G, 0.90), " ; borne max (T-1)/sqrt(T) =", (T-1)/sqrt(T), "\n")
## 2. Rosner ESD k=2 alpha=0.10 sous i.i.d. normal (T=8)
kk <- apply(Z[1:50000, ], 1, function(v) test_rosner(v, k = 2, alpha = 0.10)$nb_outliers)
cat(sprintf("ESD T=8 k=2 alpha=0.10 : P(k>=1)=%.4f  P(k=2)=%.4f  (R=50000)\n", mean(kk >= 1), mean(kk == 2)))
et1 <- apply(Z[1:50000, ], 1, function(v) { r <- test_rosner(v, k = 2, alpha = 0.10); r$R[1] > r$lambda[1] })
cat(sprintf("  premiere etape seule : %.4f\n", mean(et1)))
## 3. Lois nulles de supF et CUSUM sous i.i.d. normal (T=8), quantiles 90%
sF <- apply(Z, 1, stat_supF); sC <- apply(Z, 1, stat_cusum)
q90F <- quantile(sF, 0.90); q90C <- quantile(sC, 0.90); q90G <- quantile(G, 0.90)
cat(sprintf("q90 supF=%.3f (F(1,6) q90=%.3f) ; q90 CUSUM=%.3f (Kolmogorov q90=1.224) ; q90 Grubbs=%.3f\n", q90F, qf(0.9,1,6), q90C, q90G))
cat("P(supF > qf(.9,1,6)) =", mean(sF > qf(0.9, 1, 6)), " ; P(CUSUM > 1.224) =", mean(sC > 1.224), "\n")
## 4. Puissance a alpha = 0.10 (rejet si stat > q90 nul) contre rupture de niveau / derive / contamination
Rp <- 20000
pw <- function(gen) { M <- t(replicate(Rp, gen())); c(supF = mean(apply(M,1,stat_supF) > q90F), CUSUM = mean(apply(M,1,stat_cusum) > q90C), Grubbs = mean(apply(M,1,function(v) max(abs(v-mean(v)))/sd(v)) > q90G)) }
for (D in c(1, 1.5, 2, 3)) { cat(sprintf("rupture au milieu (k=4), saut %.1f sigma : ", D)); print(round(pw(function() rnorm(T) + c(rep(0,4), rep(D,4))), 3)) }
for (D in c(1.5, 2)) { cat(sprintf("rupture tardive (k=6), saut %.1f sigma : ", D)); print(round(pw(function() rnorm(T) + c(rep(0,6), rep(D,2))), 3)) }
for (s in c(0.25, 0.5)) { cat(sprintf("derive lineaire, pente %.2f sigma/an (ecart total %.2f) : ", s, 7*s)); print(round(pw(function() rnorm(T) + s * (1:T)), 3)) }
for (L in c(3, 4, 5)) { cat(sprintf("contamination : une annee a %d sigma : ", L)); print(round(pw(function() { v <- rnorm(T); v[sample(T,1)] <- v[sample(T,1)] + L; v }), 3)) }
## 5. Lowess sur 8 points sous i.i.d. normal : amplitude de la courbe sqrt|z| vs x (x du jeu de controle)
x <- readRDS("tests/reference/premium.rds")$ajustement$x
amp <- replicate(20000, { z <- rnorm(T); z <- (z - mean(z)) / sqrt(mean((z-mean(z))^2)); lo <- lowess(x, sqrt(abs(z))); c(diff(range(lo$y)), lo$y[length(lo$y)] - lo$y[1]) })
cat(sprintf("lowess (f=2/3) sous le modele, x du jeu de controle : amplitude de la courbe, mediane %.3f, q90 %.3f ; ecart extremes (fin-debut) : P(|.|>0.3)=%.3f, q90 |.| = %.3f ; E sqrt|z| ~ %.3f\n", median(amp[1,]), quantile(amp[1,],.9), mean(abs(amp[2,])>0.3), quantile(abs(amp[2,]),.9), mean(sqrt(abs(rnorm(1e6))))))
