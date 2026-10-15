source("R/engine.R")
r <- readRDS("tests/reference/premium.rds"); cat("parametre_final :", names(r$parametre_final), "\n")
for (cc in c("premium","premium_ii6","premium_interieur","premium_net","reserve1")) {
  r <- readRDS(file.path("tests/reference", paste0(cc, ".rds"))); b <- r$bootstrap; s <- r$ajustement$sigma; pf <- r$parametre_final
  sb <- b$sigma_boot[is.finite(b$sigma_boot)]; T <- r$ajustement$T; corr <- sqrt((T+1)/(T-1))
  cred <- pf$credibilite; if (is.null(cred)) cred <- pf$c; sstd <- pf$sigma_standard; if (is.null(sstd)) sstd <- pf$sigma_std
  su <- pf$sigma_usp
  usp_b <- cred * corr * sb + (1 - cred) * sstd
  q <- quantile(usp_b, c(.05,.95), type = 7); basic <- c(2*su - q[2], 2*su - q[1])
  cat(sprintf("%-18s sigma_hat=%.5f mean(s*)=%.5f (%+.1f%%) rang(sigma_hat)=%.3f | sigma_USP=%.5f  percentile90=[%.5f;%.5f] (ref %.5f;%.5f)  basic90=[%.5f;%.5f]  rang(sigma_USP)=%.3f\n",
    cc, s, mean(sb), 100*(mean(sb)/s-1), mean(sb < s), su, q[1], q[2], r$ic_bootstrap[["5%"]], r$ic_bootstrap[["95%"]], basic[1], basic[2], mean(usp_b < su)))
}
cat("\n--- puissance_t8.R : statistiques couvertes ---\n")
