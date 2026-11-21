d <- read.delim("/home/user/outil_usp/docs/tableaux/20261120-issue610-couverture-ic-sigma-mw-imbrique-brut.tsv", stringsAsFactors = FALSE)
sA <- 0.02182451066
for (p in c("P1","P2","P3")) {
  x <- d[d$profil == p, ]
  cov <- function(iv) x[[paste0(iv,"_90_bas")]] <= sA & sA <= x[[paste0(iv,"_90_haut")]]
  hi <- function(iv) sA > x[[paste0(iv,"_90_haut")]]
  cat("=====", p, "\n")
  for (iv in c("C1","C2","C0")) { t <- table(I4 = cov("I4"), cand = cov(iv)); cat(iv, "vs I4 (FALSE=manque):\n"); print(t)
    b <- t["TRUE","FALSE"]; cc <- t["FALSE","TRUE"]; cat(sprintf("  McNemar exact p = %.3g\n", binom.test(b, b + cc)$p.value)) }
  t <- table(C1 = cov("C1"), C2 = cov("C2")); print(t)
  sat <- x$Qw_05 == 0
  cat("saturation C1 90 haute :", sum(sat), " ; manque haut C1 parmi saturés :", sum(hi("C1")[sat]), " ; parmi non saturés :", sum(hi("C1")[!sat]), "/", sum(!sat), "\n")
  r <- x$sigma_hat / sA
  cat("sigma_hat/sigma_A quantiles 5/25/50/75/95 :", round(quantile(r, c(.05,.25,.5,.75,.95)), 3), "\n")
  m2 <- hi("C2"); cat("C2 manque haut : sigma_hat/sigma_A des manques, quantiles 50/95 :", round(quantile(r[m2], c(.5,.95)),3), " max:", round(max(r[m2]),3), "\n")
  cat("  sigma_A / borne haute C2 parmi manques (quantiles 10/50/90) :", round(quantile(sA / x$C2_90_haut[m2], c(.1,.5,.9)), 3), "\n")
  m1 <- hi("C1"); cat("  sigma_A / borne haute C1 parmi manques (quantiles 10/50/90) :", round(quantile(sA / x$C1_90_haut[m1], c(.1,.5,.9)), 3), "\n")
  # part des manques hauts sous sigma_hat/sigma_A < 0.8
  cat("  part des manques hauts C2 avec sigma_hat/sigma_A < 0.8 :", round(mean(r[m2] < 0.8), 3), "\n")
  # ratio haute / sigma_hat median
  cat("  borne haute / sigma_hat, mediane : I1", round(median(x$I1_90_haut / x$sigma_hat),3), " I4", round(median(x$I4_90_haut / x$sigma_hat),3), " C1", round(median(x$C1_90_haut / x$sigma_hat),3), " C2", round(median(x$C2_90_haut / x$sigma_hat),3), "\n")
  cat("  cor(log sigma_hat, log(C2_haut/sigma_hat)) :", round(cor(log(x$sigma_hat), log(x$C2_90_haut / x$sigma_hat)), 3), "\n")
  cat("  cor(log sigma_hat, se_hat) :", round(cor(log(x$sigma_hat), x$se_hat), 3), "\n")
}
