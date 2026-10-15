suppressMessages(source("R/engine.R"))
cat("## (a) Puissance exacte du test F(4,4) bilateral (Goldfeld-Quandt a pi constant, z i.i.d. normaux), alpha = 0.10\n")
h <- 4; qlo <- qf(0.05, h, h); qhi <- qf(0.95, h, h)
for (rho in c(1, 1.26, 1.5, 2, 3, 5, 10, 20)) {
  pw <- pf(qhi / rho, h, h, lower.tail = FALSE) + pf(qlo / rho, h, h)
  cat(sprintf("  rapport de variances %5.2f : puissance = %.3f\n", rho, pw))
}
cat("  (F_0.95(4,4) =", round(qhi, 3), ")\n")
cat("## (a') Rapport max(x)/min(x) des volumes J1 et J2 (contraste de variance delta=0 vs delta=1)\n")
d1 <- read.csv("tests/donnees/donnees_ln.csv"); print(head(d1, 3)); x1 <- d1[[1]]; y1 <- d1[[2]]
d2 <- read.csv("tests/donnees/donnees_ln_interieur.csv"); x2 <- d2[[1]]
cat(sprintf("  J1 : T = %d, max/min = %.3f, CV = %.3f ; J2 : max/min = %.3f, CV = %.3f\n",
            length(x1), max(x1)/min(x1), sd(x1)/mean(x1), max(x2)/min(x2), sd(x2)/mean(x2)))
cat("## (b) Enumeration des 8! ordres : Mann-Kendall vs Spearman(ratio, temps), p exactes bilaterales\n")
P <- engine_permutations(8); T <- 8
S <- apply(P, 1, function(p) { s <- 0; for (i in 1:(T-1)) for (j in (i+1):T) s <- s + sign(p[j]-p[i]); s })
rho <- apply(P, 1, function(p) 1 - 6*sum((p - 1:T)^2)/(T*(T^2-1)))
pS <- sapply(abs(S), function(a) mean(abs(S) >= a))
pR <- sapply(abs(rho), function(a) mean(abs(rho) >= a - 1e-12))
verdict <- function(p) ifelse(p < 0.05, "ECHEC", ifelse(p < 0.10, "ALERTE", "OK"))
vS <- verdict(pS); vR <- verdict(pR)
cat(sprintf("  correlation (S_MK, rho_s) sur les 40320 ordres : %.4f\n", cor(S, rho)))
cat("  table des verdicts (lignes MK, colonnes Spearman-temps) :\n"); print(table(MK = vS, Spearman = vR))
cat(sprintf("  desaccord de verdict : %.2f %% des ordres ; taille exacte a 0.10 : MK %.4f, Spearman %.4f ; a 0.05 : MK %.4f, Spearman %.4f\n",
            100*mean(vS != vR), mean(pS < 0.10), mean(pR < 0.10), mean(pS < 0.05), mean(pR < 0.05)))
cat("## (c) Temps d'un usp_ajuster() sur J1\n")
t0 <- system.time(f1 <- usp_ajuster(x1, y1))
cat(sprintf("  %.2f s ; delta = %.4f gamma = %.4f beta = %.4f sigma = %.4f\n", t0[["elapsed"]], f1$delta, f1$gamma, f1$beta, f1$sigma))
cat("  noms de fit:", names(f1), "\n")
