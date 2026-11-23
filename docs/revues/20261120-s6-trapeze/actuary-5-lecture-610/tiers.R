d <- read.delim("/home/user/outil_usp/docs/tableaux/20261120-issue610-couverture-ic-sigma-mw-imbrique-brut.tsv", stringsAsFactors = FALSE)
sA <- 0.02182451066
for (p in c("P1","P2")) { x <- d[d$profil == p, ]; r <- x$sigma_hat/sA
  sat <- x$Qw_05 == 0
  cat(p, " sigma_hat/sigma_A mediane : satures", round(median(r[sat]),3), " non satures", round(median(r[!sat]),3), "\n")
  for (iv in c("I4","C1","C2")) { lo <- x[[paste0(iv,"_90_bas")]]; hi <- x[[paste0(iv,"_90_haut")]]
    cat(sprintf("  %s : log-largeur mediane tiers bas (r<q1/3) %.3f, haut (r>q2/3) %.3f\n", iv,
      median(log(hi/lo)[r < quantile(r,1/3)]), median(log(hi/lo)[r > quantile(r,2/3)]))) }
}
