b <- read.delim("docs/tableaux/20261119-issue387-couverture-ic-sigma-mw-brut.tsv", stringsAsFactors = FALSE)
sA <- 0.02182451
for (P in 1:2) {
  u <- read.delim(sprintf("/tmp/claude-0/-home-user-outil-usp/8f991392-3bf5-5fd0-a4b8-27e588ed5637/scratchpad/p610/u_P%d.tsv", P))
  bb <- b[b$profil == paste0("P", P) & b$r %in% u$r, ]; bb <- bb[order(bb$r), ]
  cat(sprintf("P%d : n=%d ; sigma_hat identiques au brut : %s ; max ecart rel %.2g\n", P, nrow(bb), identical(bb$sigma_hat, u$sh), max(abs(bb$sigma_hat/u$sh - 1))))
  # manque haut de I1 90 % selon le brut vs selon u (u > 0.95 approx) ; exact : sigma_A > I1_90_haut
  mh <- sA > bb$I1_90_haut
  cat(sprintf("  manque haut I1 90%% (brut, r<=400) = %.4f ; part u = 1 (pilote) = %.4f ; CP 95%% de u=1 : [%.3f ; %.3f]\n", mean(mh), mean(u$u == 1),
      qbeta(.025, sum(u$u == 1), sum(u$u < 1) + 1), qbeta(.975, sum(u$u == 1) + 1, sum(u$u < 1))))
  # sur tout le brut (2000) : part sigma_A > I1_95_haut (q 0.975)
  ba <- b[b$profil == paste0("P", P) & b$statut == "ok", ]
  cat(sprintf("  brut complet n=%d : part sigma_A > q0.975 = %.4f ; > q0.95 = %.4f\n", nrow(ba), mean(sA > ba$I1_95_haut), mean(sA > ba$I1_90_haut)))
  # relation u=1 avec sh/sA
  cat(sprintf("  mediane sh/sA si u=1 : %.3f ; sinon %.3f ; max sh/sA parmi u=1 : %.3f\n", median(u$sh[u$u==1]/sA), median(u$sh[u$u<1]/sA), max(u$sh[u$u==1]/sA)))
}
