# Cout par statistique des catalogues Monte-Carlo, sur le contexte observe.
setwd("/home/user/outil_usp")
source("tests/outils_tests.R")
env <- environment(run_engine)
# Lognormal : contexte observe du cas premium
fit <- usp_ajuster(.ln$xt, .ln$yt)
k <- usp_noyau(fit$delta, fit$gamma, fit$x, fit$y, fit$xbar)
e <- env$.usp_contexte_mc(fit$x, fit$y, k$z, k$pi)
N <- 300
cout <- sapply(names(USP_CATALOGUE_MC), function(nm) { f <- USP_CATALOGUE_MC[[nm]]$calc; f(e); system.time(for (i in 1:N) f(e))[[3]] / N * 1000 })
tc <- system.time(for (i in 1:N) env$.usp_contexte_mc(fit$x, fit$y, k$z, k$pi))[[3]]/N*1000
cat("Lognormal : ms par replication et par statistique (contexte :", round(tc, 3), "ms)\n")
print(round(sort(cout, decreasing = TRUE), 3)); cat("somme :", round(sum(cout), 2), "ms ; x 999 =", round(sum(cout) * 999 / 1000, 2), "s\n")
# Merz-Wuthrich
aj <- mw_ajuster(.tri)
e2 <- env$.mw_contexte_mc(aj)
cout2 <- sapply(names(MW_CATALOGUE_MC), function(nm) { f <- MW_CATALOGUE_MC[[nm]]$calc; r <- try(f(e2), silent = TRUE); system.time(for (i in 1:50) try(f(e2), silent = TRUE))[[3]] / 50 * 1000 })
cat("Merz-Wuthrich : ms par replication et par statistique\n")
print(round(sort(cout2, decreasing = TRUE), 3)); cat("somme :", round(sum(cout2), 2), "ms ; x 999 =", round(sum(cout2) * 999 / 1000, 2), "s\n")
