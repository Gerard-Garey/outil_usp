source("R/engine.R")
res <- readRDS("tests/reference/reserve2.rds")
aj <- res$ajustement
cat("champs ajustement:", names(aj), "\n")
tri <- aj$tri; I <- aj$I; J <- aj$J
cat("f:", round(aj$f,4), "\nsigma2:", round(aj$sigma2,4), "\n")
# (a) PenteIntra : part de sum w Ct^2 par colonne
r <- mw_residus(aj)
w <- r$C / r$sigma_j^2; w <- w * 2^-floor(log2(max(w)))
Ct <- numeric(length(w))
for (g in split(seq_along(w), r$j)) { wg <- w[g]; Ct[g] <- .mw_centrage_pondere(r$C[g], wg, sum(wg)) }
part <- tapply(w * Ct^2, r$j, sum); cat("\n(a) PenteIntra : part de sum w Ct^2 par colonne j :\n"); print(round(part / sum(part), 3))
cat("n_j :", tapply(r$j, r$j, length), "\n"); print(round(.mw_lm_intra(r), 4))
cat("CV intra-colonne de C(i,j) :", round(tapply(r$C, r$j, function(x) sd(x)/mean(x)), 3), "\n")
# (b) Origine : se(a_j), effet minimal detectable (alpha 0.10 bilateral, puissance 0.80, Student non central)
cat("\n(b) Ordonnee a l'origine par colonne :\n")
for (j in 0:(J-1)) { idx <- 0:(I-j-1); if (length(idx) < 3) next
  x <- tri[idx+1, j+1]; y <- tri[idx+1, j+2]
  fit <- lm(y ~ x, weights = 1/x); s <- summary(fit)$coefficients
  df <- length(idx) - 2; q <- qt(0.95, df)
  pw <- function(ncp) 1 - pt(q, df, ncp) + pt(-q, df, ncp) - 0.8
  ncp <- uniroot(pw, c(0.1, 200))$root
  cat(sprintf("j=%d n=%d df=%d a=%.1f se(a)=%.1f t=%.2f p=%.3f | MDE(a) = %.0f = %.0f%% du niveau moyen de C(i,j+1) (%.0f) ; CV(C(i,j))=%.3f\n",
      j, length(idx), df, s[1,1], s[1,2], s[1,3], s[1,4], ncp*s[1,2], 100*ncp*s[1,2]/mean(y), mean(y), sd(x)/mean(x))) }
# (c) famille alpha
fa <- mw_famille_alpha(aj); cat("\n(c) Alpha : stat =", round(fa$stat,5), "\n"); print(round(fa$detail, 4))
# (d) BP : nR2 et structure mecanique
cat("\n(d) BP : n =", nrow(r), " nR2 =", round(nrow(r) * summary(lm(I(r$residu^2) ~ r$C))$r.squared, 3), "\n")
m <- data.frame(j = sort(unique(r$j)), n = as.vector(tapply(r$j, r$j, length)), moy_r2 = round(as.vector(tapply(r$residu^2, r$j, mean)),3), moy_C = round(as.vector(tapply(r$C, r$j, mean)),0), var_C_intra = round(as.vector(tapply(r$C, r$j, var)),0))
print(m)
cat("part de la variance de C entre colonnes :", round(1 - sum((m$n-1)*m$var_C_intra)/((nrow(r)-1)*var(r$C)), 3), "\n")
cat("cor(moy_r2, moy_C) entre colonnes :", round(cor(m$moy_r2, m$moy_C), 3), "\n")
# (e) pool
pool <- .mw_pool_residus(aj); cat("\n(e) pool : n =", length(pool), " var =", round(var(pool),4), " kurtosis excès =", round(mean(pool^4)/mean(pool^2)^2 - 3, 3), "\n")
cat("residus bruts de la colonne n_j = 2 (j=5) :", round(r$residu[r$j == 5], 4), " ; redresses (avant recentrage) :", round((r$residu / sqrt(1 - r$C / ave(r$C, r$j, FUN = sum)))[r$j == 5], 4), "\n")
cat("valeurs |r~| == 1 avant recentrage :", sum(abs(round((r$residu / sqrt(1 - r$C / ave(r$C, r$j, FUN = sum))), 10)) == 1), "\n")
