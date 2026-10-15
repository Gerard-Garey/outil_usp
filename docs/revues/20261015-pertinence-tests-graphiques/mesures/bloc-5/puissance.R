# Sonde de puissance (ordre de grandeur) : 20 triangles par alternative, B = 199, erreurs N.
source("R/engine.R")
res <- readRDS("tests/reference/reserve2.rds"); aj0 <- res$ajustement
I <- aj0$I; J <- aj0$J; f <- aj0$f; s2 <- aj0$sigma2; col0 <- aj0$tri[, 1]
gen <- function(seed, delta = 0, expo = 1) {
  set.seed(seed); tri <- matrix(NA_real_, I + 1, J + 1); tri[, 1] <- col0
  for (j in 0:(J - 1)) { idx <- 0:(I - j - 1); C <- tri[idx + 1, j + 1]; Cb <- mean(C)
    a <- delta * f[j + 1] * Cb; fp <- f[j + 1] * (1 - delta)
    v <- s2[j + 1] * C^expo * Cb^(1 - expo)          # variance moyenne conservee a C = Cb
    repeat { nv <- a + fp * C + rnorm(length(C)) * sqrt(v); if (all(nv > 0)) break }
    tri[idx + 1, j + 2] <- nv }
  tri }
cles <- names(MW_CATALOGUE_MC)
run <- function(nom, delta, expo, n = 20) {
  P <- t(sapply(seq_len(n), function(k) { tri <- gen(5000 + k, delta, expo)
    aj <- mw_ajuster(tri); b <- mw_bootstrap(aj, B = 199, seed = 6000 + k); unlist(b$p_mc[cles]) }))
  cat(sprintf("\n%s : taux de rejet a 0,10 (n = %d, B = 199)\n", nom, n))
  print(round(colMeans(P < 0.10, na.rm = TRUE), 2)); flush.console() }
t0 <- Sys.time()
run("H0 (delta = 0, exposant 1)", 0, 1)
run("A1 : ordonnee a l'origine, delta = 0,20 (a_j = 0,2 f_j Cbar_j)", 0.20, 1)
run("A2 : exposant de variance 2", 0, 2)
run("A3 : exposant de variance 0", 0, 0)
cat("duree :", format(Sys.time() - t0), "\n")
