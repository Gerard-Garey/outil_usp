# Simulation bloc 3 : (1) puissance comparee des tests de normalite a T = 8 sous i.i.d.
# (loi nulle simulee exacte a pi_t constant, niveau 0,10), redondance (correlations des stats
# sous H0) ; (2) Bartels exact (8! permutations) vs suites exact vs DW Imhof sous AR(1).
suppressMessages(source("R/engine.R"))
set.seed(20261015)
T_ <- 8L
R0 <- 20000L; R1 <- 5000L
std_ml <- function(x) (x - mean(x)) / sqrt(mean((x - mean(x))^2))   # z a delta=1 (diviseur T)
stats8 <- function(x) {
  z <- std_ml(x)
  c(SW = .shapiro_sur(z)$stat, SF = test_shapiro_francia(z)$stat,
    AD = stat_ad(z), CvM = stat_cvm(z), KS = stat_ks(z), Lillie = stat_lilliefors(z),
    JB = test_jarque_bera(z)$stat, DAgo = test_dagostino_skew(z)$stat)
}
sens <- c(SW = "bas", SF = "bas", AD = "haut", CvM = "haut", KS = "haut", Lillie = "haut", JB = "haut", DAgo = "deux")
null_mat <- t(replicate(R0, stats8(rnorm(T_))))
cat("Correlations (Spearman) des statistiques sous H0 i.i.d. normal, T = 8 :\n")
print(round(cor(null_mat, method = "spearman"), 2))
alpha <- 0.10
crit <- lapply(names(sens), function(k) {
  v <- null_mat[, k]
  switch(sens[[k]], bas = c(lo = quantile(v, alpha), hi = Inf),
         haut = c(lo = -Inf, hi = quantile(v, 1 - alpha)),
         deux = c(lo = quantile(v, alpha / 2), hi = quantile(v, 1 - alpha / 2)))
})
names(crit) <- names(sens)
rejet <- function(m) sapply(names(sens), function(k) {
  v <- m[, k]; cr <- crit[[k]]
  mean(switch(sens[[k]], bas = v <= cr[1], haut = v >= cr[2], deux = v <= cr[1] | v >= cr[2]))
})
alts <- list(
  "N(0,1) (niveau)" = function() rnorm(T_),
  "t3" = function() rt(T_, 3), "t5" = function() rt(T_, 5),
  "exp" = function() rexp(T_), "lognorm(0;0,5)" = function() rlnorm(T_, 0, 0.5),
  "lognorm(0;0,3)" = function() rlnorm(T_, 0, 0.3),
  "contam. 1 obs x3" = function() { x <- rnorm(T_); x[1] <- 3 * x[1]; x },
  "contam. 1 obs x4" = function() { x <- rnorm(T_); x[1] <- 4 * x[1]; x },
  "uniforme" = function() runif(T_)
)
cat("\nTaux de rejet a alpha = 0,10 (loi nulle simulee R0 = 20000, R1 = 5000 par alternative) :\n")
res <- t(sapply(alts, function(f) rejet(t(replicate(R1, stats8(f()))))))
print(round(res, 3))
# Accord des rejets entre SW et les autres sous t3 (redondance en decision)
m_t3 <- t(replicate(R1, stats8(rt(T_, 3))))
rj <- sapply(names(sens), function(k) { v <- m_t3[, k]; cr <- crit[[k]]
  switch(sens[[k]], bas = v <= cr[1], haut = v >= cr[2], deux = v <= cr[1] | v >= cr[2]) })
cat("\nSous t3 : P(rejet par au moins un des 8) =", round(mean(rowSums(rj) > 0), 3),
    "; P(rejet SW) =", round(mean(rj[, "SW"]), 3), "; P(rejet par >= 1 des 8 | SW accepte) =",
    round(mean(rowSums(rj[!rj[, "SW"], ]) > 0), 3), "\n")
rj0 <- sapply(names(sens), function(k) { v <- null_mat[, k]; cr <- crit[[k]]
  switch(sens[[k]], bas = v <= cr[1], haut = v >= cr[2], deux = v <= cr[1] | v >= cr[2]) })
cat("Sous H0 : P(au moins un des 8 rejette a 0,10) =", round(mean(rowSums(rj0) > 0), 3),
    "; P(au moins un des 5 (SW, AD, CvM, Lillie, JB)) =",
    round(mean(rowSums(rj0[, c("SW","AD","CvM","Lillie","JB")]) > 0), 3), "\n")

# ---- (2) Bartels exact vs suites vs DW ----
rvn <- function(x) { r <- rank(x); sum(diff(r)^2) / sum((r - mean(r))^2) }
perms <- function(n) { if (n == 1) return(matrix(1)); p <- perms(n - 1); 
  do.call(rbind, lapply(1:n, function(i) cbind(i, ifelse(p >= i, p + 1, p)))) }
P8 <- perms(8L)
rvn_null <- apply(P8, 1, function(r) sum(diff(r)^2) / sum((r - mean(r))^2))
rvn_null <- round(rvn_null, 10)
tab <- table(rvn_null)
cat("\nBartels T = 8 : nombre de valeurs distinctes de RVN =", length(tab),
    "; p_min bilaterale (doublement) =", signif(2 * min(tab) / length(rvn_null), 4), "\n")
Fn <- ecdf(rvn_null)
p_bartels <- function(x) { s <- round(rvn(x), 10); lo <- Fn(s); hi <- 1 - Fn(s - 1e-9); min(1, 2 * min(lo, hi)) }
p_runs <- function(x) runs_p_exacte(x)
p_dw <- function(x) dw_p_exacte(x)
ar1 <- function(rho) { e <- rnorm(T_); x <- numeric(T_); x[1] <- e[1] / sqrt(1 - rho^2)
  for (t in 2:T_) x[t] <- rho * x[t - 1] + e[t]; x }
scen <- list("rho=0" = function() ar1(0), "rho=-0,5" = function() ar1(-0.5), "rho=0,3" = function() ar1(0.3),
             "rho=0,5" = function() ar1(0.5), "rho=0,7" = function() ar1(0.7), "rho=0,9" = function() ar1(0.9),
             "tendance 2 et" = function() rnorm(T_) + 2 * (0:7) / 7,
             "rupture 2 et apres an 4" = function() rnorm(T_) + 2 * (c(0, 0, 0, 0, 1, 1, 1, 1)),
             "t3 i.i.d." = function() rt(T_, 3))
R2 <- 3000L
cat("\nPuissance a alpha = 0,10 (R =", R2, ") : Bartels exact (8!), suites exact (ALERTE seule), DW Imhof exact bilateral, et a alpha = 0,05 Bartels :\n")
out <- t(sapply(scen, function(f) { pb <- numeric(R2); pr <- numeric(R2); pd <- numeric(R2)
  for (i in 1:R2) { x <- f(); pb[i] <- p_bartels(x); pr[i] <- p_runs(x); pd[i] <- p_dw(x) }
  c(Bartels10 = mean(pb < 0.10), Suites10 = mean(pr < 0.10), DW10 = mean(pd < 0.10),
    Bartels05 = mean(pb < 0.05), DW05 = mean(pd < 0.05)) }))
print(round(out, 3))
cat("\nValeurs atteignables de la p Bartels a T = 8 (les 6 plus petites) :\n")
pv <- sort(unique(sapply(as.numeric(names(tab)), function(s) { lo <- Fn(s); hi <- 1 - Fn(s - 1e-9); min(1, 2 * min(lo, hi)) })))
print(signif(head(pv, 6), 4))
