suppressMessages(source("R/engine.R"))
d1 <- read.csv("tests/donnees/donnees_ln.csv"); x <- d1$xt; y <- d1$yt
d2 <- read.csv("tests/donnees/donnees_ln_interieur.csv")
cat(sprintf("J1 : max/min = %.3f, CV = %.3f, xbar/x_t in [%.3f ; %.3f] ; J2 : max/min = %.3f, CV = %.3f\n",
    max(x)/min(x), sd(x)/mean(x), min(mean(x)/x), max(mean(x)/x), max(d2$xt)/min(d2$xt), sd(d2$xt)/mean(d2$xt)))
t0 <- system.time(f1 <- usp_ajuster(x, y))
cat(sprintf("usp_ajuster(J1) : %.2f s ; delta = %.4f gamma = %.4f beta = %.4f sigma = %.4f\n", t0[["elapsed"]], f1$delta, f1$gamma, f1$beta, f1$sigma))
T <- length(x); xbar <- mean(x); g <- x > median(x)
stats_h2 <- function(fit) {
  z <- fit$z
  D <- unname(ks.test(z[g], z[!g])$statistic)
  c(BP = test_breusch_pagan(z^2, x)$stat, BP79 = test_breusch_pagan_original(z^2, x)$stat,
    White = test_white(z^2, x)$stat, GQ = test_goldfeld_quandt(z, x)$stat,
    BF = test_brown_forsythe(z, x)$stat, D1 = as.numeric(D > 0.999), delta = fit$delta)
}
# generateurs : log Y_t = log(beta x_t) - s_t^2/2 + s_t N(0,1), E[Y_t] = beta x_t
gen <- function(sd_t) exp(log(f1$beta * x) - sd_t^2/2 + sd_t * rnorm(T))
sd_null <- sqrt(1 / f1$pi)                                  # modele ajuste (delta = 1)
sd_d0   <- sqrt(1 / usp_pi(0, f1$gamma, x))                 # delta = 0, meme gamma (famille reglementaire)
sd_x2   <- sd_null * ifelse(g, 2, 1)                        # ecart-type x2 les annees de fort volume
sd_x3   <- sd_null * ifelse(g, 3, 1)
sd_k3   <- sd_null * (x / xbar)^3                           # log-ecart-type en (x/xbar)^3
cat(sprintf("rapport max/min des variances log : delta=0 %.3f ; x2 %.1f ; x3 %.1f ; k3 %.3f\n",
    max(sd_d0^2)/min(sd_d0^2), 4, 9, max(sd_k3^2)/min(sd_k3^2)))
R <- 250
run <- function(sd_t, seed) { set.seed(seed); t(replicate(R, { yy <- gen(sd_t); stats_h2(usp_ajuster(x, yy)) })) }
tt <- system.time({
  S0 <- run(sd_null, 1); Sd0 <- run(sd_d0, 2); Sx2 <- run(sd_x2, 3); Sx3 <- run(sd_x3, 4); Sk3 <- run(sd_k3, 5)
})
cat(sprintf("duree des 5 x %d ajustements : %.0f s\n", R, tt[["elapsed"]]))
q90 <- apply(S0[, c("BP","BP79","White","BF")], 2, quantile, 0.90, na.rm = TRUE)
Fn <- ecdf(S0[, "GQ"])
taux <- function(S) c(sapply(c("BP","BP79","White","BF"), function(k) mean(S[, k] > q90[k], na.rm = TRUE)),
                      GQ = mean(2 * pmin(Fn(S[, "GQ"]), 1 - Fn(S[, "GQ"])) < 0.10),
                      Smirnov_D1 = mean(S[, "D1"]), delta_bord1 = mean(S[, "delta"] >= 1 - 1e-6), delta_bord0 = mean(S[, "delta"] <= 1e-6))
res <- rbind(nul_modele_ajuste = taux(S0), delta0_meme_gamma = taux(Sd0), sd_x2_fort_volume = taux(Sx2),
             sd_x3_fort_volume = taux(Sx3), logsd_k3 = taux(Sk3))
cat("Taux de rejet a alpha = 0.10, loi de reference = statistiques sous le modele ajuste a J1 (R = 250 par ligne, IC95 +- ~0.04) :\n")
print(round(res, 3))
## RESET : puissance contre une courbure, p F(2,5) (R = 2000, sans ajustement)
s <- (x - xbar) / diff(range(x)); set.seed(7)
for (kap in c(0, 0.5, 1, 2, 4)) {
  rej <- mean(replicate(2000, { yy <- gen(sd_null) * (1 + kap * s^2); test_reset(x, yy)$p < 0.10 }))
  cat(sprintf("RESET J1, E[Y] = beta x (1 + %.1f s^2), ecart max %.0f %% : rejet p_F(2,5) < 0.10 = %.3f\n", kap, 100*kap*0.25, rej))
}
