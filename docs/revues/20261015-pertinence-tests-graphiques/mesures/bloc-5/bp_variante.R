# BP actuel (r^2 ~ C) contre variante a effets fixes de colonne (r^2 ~ factor(j) + C) et variante relative
# (r^2 ~ factor(j) + C/Cbar_j), p Monte-Carlo par le bootstrap du moteur (meme graine, meme pool).
source("R/engine.R")
res <- readRDS("tests/reference/reserve2.rds"); aj <- res$ajustement
stats3 <- function(a) { r <- mw_residus(a); n <- nrow(r); jj <- factor(r$j)
  Crel <- r$C / ave(r$C, r$j, FUN = mean)
  c(BP = n * summary(lm(I(r$residu^2) ~ r$C))$r.squared,
    BPcol = { m0 <- lm(I(r$residu^2) ~ jj); m1 <- lm(I(r$residu^2) ~ jj + r$C); n * (1 - deviance(m1)/deviance(m0)) },
    BPrel = { m0 <- lm(I(r$residu^2) ~ jj); m1 <- lm(I(r$residu^2) ~ jj + Crel); n * (1 - deviance(m1)/deviance(m0)) }) }
obs <- stats3(aj); print(round(obs, 3))
pool <- .mw_pool_residus(aj); B <- 999
sim <- engine_sous_graine(20260831, t(sapply(seq_len(B), function(b) { tb <- mw_simuler_triangle(aj, pool); stats3(mw_ajuster(tb)) })))
p <- sapply(names(obs), function(k) (1 + sum(sim[, k] >= obs[k])) / (B + 1))
cat("p Monte-Carlo (queue haute, B = 999, graine 20260831) :\n"); print(round(p, 3))
cat("p_mc BP du moteur (reference) :", res$bootstrap$p_mc[["BP"]], "\n")
# niveau nominal chi2(1) des trois variantes : quantiles bootstrap de la statistique
cat("quantiles bootstrap 0,90 des statistiques (ref chi2(1) : 2,706) :\n"); print(round(apply(sim, 2, quantile, 0.9), 3))
