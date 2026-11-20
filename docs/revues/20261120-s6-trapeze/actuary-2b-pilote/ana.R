setwd("/home/user/outil_usp")
b <- read.delim("docs/tableaux/20261119-issue387-couverture-ic-sigma-mw-brut.tsv", stringsAsFactors = FALSE)
sA <- 0.02182451
cp <- function(k, n) c(if (k == 0) 0 else qbeta(.025, k, n - k + 1), if (k == n) 1 else qbeta(.975, k + 1, n - k))
for (P in 1:2) {
  w <- read.delim(sprintf("/tmp/claude-0/-home-user-outil-usp/8f991392-3bf5-5fd0-a4b8-27e588ed5637/scratchpad/p610/w_P%d.tsv", P))
  bb <- b[b$profil == paste0("P", P), ]; bb <- bb[order(bb$r), ]
  cat(sprintf("\nP%d, n = %d (graines de #387) ; sigma_hat : ecart relatif max au brut %.2g ; manque haut I1 90%% brut %.4f, pilote (sA > q95 type 7 non recalcule) ; n_fin min %d\n",
              P, nrow(w), max(abs(bb$sigma_hat / w$sh - 1)), mean(sA > bb$I1_90_haut), min(w$nfin)))
  k <- sum(sA > w$smax); ci <- cp(k, nrow(w))
  cat(sprintf("  sigma_A > max(sigma*) : %d / %d = %.4f, CP [%.4f ; %.4f]\n", k, nrow(w), k / nrow(w), ci[1], ci[2]))
  kk <- sum(sA < w$smin); cat(sprintf("  sigma_A < min(sigma*) : %d\n", kk))
  k4 <- sum(sA > w$sh^2 / w$smin); ci4 <- cp(k4, nrow(w))
  cat(sprintf("  sigma_A > sh^2/min(sigma*) (plafond de I4) : %d = %.4f, CP [%.4f ; %.4f]\n", k4, k4 / nrow(w), ci4[1], ci4[2]))
  k4b <- sum(sA < w$sh^2 / w$smax); cat(sprintf("  sigma_A < sh^2/max(sigma*) (plancher de I4) : %d\n", k4b))
  cat("  quantiles de v = G*(sh^2/sigma_A) (niveau a tel que I4 manque en haut ssi v < a) :",
      paste(sprintf("%.4f", quantile(w$v, c(.01, .025, .05, .1, .5, .95), type = 7)), collapse = " "), "\n")
  cat(sprintf("  part v = 0 : %.4f ; part v < 0.005 : %.4f ; part v < 0.01 : %.4f ; part v < 0.05 (manque haut I4 90%%) : %.4f\n",
              mean(w$v == 0), mean(w$v < 0.005), mean(w$v < 0.01), mean(w$v < 0.05)))
  cat("  quantiles de u = G*(sigma_A) :", paste(sprintf("%.4f", quantile(w$u, c(.05, .5, .8, .9, .95), type = 7)), collapse = " "), "\n")
  # ecart en ecart-types bootstrap log : z = (log sA - log sh) / sd(log sigma*)
  z <- (log(sA) - log(w$sh)) / w$lsd
  cat("  z = (log sigma_A - log sigma_hat)/sd(log sigma*) : quantiles 5/50/95 %",
      paste(sprintf("%.2f", quantile(z, c(.05, .5, .95))), collapse = " "), "\n")
  # rapport sd(log sigma*) / sd(log sigma_hat entre triangles) et correlation avec log sh
  cat(sprintf("  correlation (log sh, sd log sigma*) = %.3f ; mediane sd(log sigma*) par tiers de sh/sA : %s\n",
              cor(log(w$sh), w$lsd), paste(sprintf("%.3f", tapply(w$lsd, cut(w$sh / sA, quantile(w$sh / sA, c(0, 1/3, 2/3, 1)), include.lowest = TRUE), median)), collapse = " ")))
  cat(sprintf("  temps moyen par triangle %.3f s\n", mean(w$t)))
}
