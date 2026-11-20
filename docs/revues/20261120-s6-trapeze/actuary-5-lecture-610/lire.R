d <- read.delim("/home/user/outil_usp/docs/tableaux/20261120-issue610-couverture-ic-sigma-mw-imbrique-brut.tsv", stringsAsFactors = FALSE)
sA <- 0.02182451066
cat("statuts:\n"); print(table(d$profil, d$statut))
cp <- function(x, n) c(if (x == 0) 0 else qbeta(0.025, x, n - x + 1), if (x == n) 1 else qbeta(0.975, x + 1, n - x))
classe <- function(x, n, rho) { t <- x / n; ic <- cp(x, n); lo <- rho/2; hi <- 3*rho/2
  if (ic[1] <= rho && rho <= ic[2]) "compatible" else if (t >= lo && t <= hi) "ecart mineur" else if (ic[2] < lo) "dist. cons." else if (ic[1] > hi) "dist. lib." else "non tranche" }
near <- 0
for (p in c("P1","P2","P3")) for (iv in c("I1","I4","C0","C1","C2","C1r","C2r")) for (lv in c("90","95")) {
  x <- d[d$profil == p, ]; b <- x[[paste0(iv,"_",lv,"_bas")]]; h <- x[[paste0(iv,"_",lv,"_haut")]]
  ok <- is.finite(b) & is.finite(h); n <- sum(ok)
  near <- near + sum(abs(b[ok]/sA - 1) < 1e-8 | abs(h[ok]/sA - 1) < 1e-8)
  lo <- sum(sA < b[ok]); hi <- sum(sA > h[ok]); m <- lo + hi; rho <- if (lv == "90") .10 else .05
  cat(sprintf("%s %-3s %s n=%d tau=%.4f [%.4f;%.4f] %-12s | bas %.4f (%s) haut %.4f (%s)\n", p, iv, lv, n, m/n, cp(m,n)[1], cp(m,n)[2], classe(m,n,rho), lo/n, classe(lo,n,rho/2), hi/n, classe(hi,n,rho/2)))
}
cat("bornes a moins de 1e-8 relatif de sigma_A :", near, "\n")
