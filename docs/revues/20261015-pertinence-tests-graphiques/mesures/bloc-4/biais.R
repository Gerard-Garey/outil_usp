source("R/engine.R")
cat(sprintf("corr reglementaire sqrt((T+1)/(T-1)) a T=8 : %.4f\n", sqrt(9/7)))
for (cc in c("premium","premium_ii6","premium_interieur","premium_net","reserve1")) {
  r <- readRDS(file.path("tests/reference", paste0(cc, ".rds"))); b <- r$bootstrap; s <- r$ajustement$sigma
  su <- r$parametre_final$sigma_usp; ic <- r$ic_bootstrap
  sb <- b$sigma_boot; sb <- sb[is.finite(sb)]
  usp_b <- r$ic_bootstrap  # bornes
  cat(sprintf("%-18s sigma_hat=%.5f  mean(s*)=%.5f (%.1f%%)  med(s*)=%.5f (%.1f%%)  rang de sigma_hat dans s* = %.3f  sigma_hat/mean(s*)=%.3f\n",
    cc, s, mean(sb), 100*(mean(sb)/s-1), median(sb), 100*(median(sb)/s-1), mean(sb < s), s/mean(sb)))
  cat("   ic_bootstrap (noms) :", paste(names(ic), round(unlist(ic),5), collapse=" "), "\n")
  q <- quantile(sb, c(.05,.95)); cred <- usp_credibilite(r$ajustement$T, r$metadata$bareme %||% "court")
}
r <- readRDS("tests/reference/premium.rds"); str(r$ic_bootstrap); str(r$parametre_final[c("sigma_usp","credibilite","sigma_standard","sigma_estime","sigma_corrige")])
