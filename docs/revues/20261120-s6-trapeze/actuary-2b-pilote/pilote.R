# Pilote 2b (#610) : relecture du monde de #387, P1 (graines de #387), et couts.
# Aucune couverture de candidat n'est calculee.
setwd("/home/user/outil_usp")
source("tests/outils_tests.R")
args <- commandArgs(TRUE); N <- as.integer(args[1]); P <- as.integer(args[2])
restreindre <- function(tri) { tri[row(tri) + col(tri) - 2L > nrow(tri) - 1L] <- NA; tri }
tri0 <- restreindre(.tri); aj0 <- mw_ajuster(tri0); jd0 <- .mw_colonnes_degenerees(aj0)
pool <- .mw_pool_residus(aj0, jd0); sdp <- sqrt(mean((pool - mean(pool))^2)); poolE <- pool / sdp
sigA <- sqrt(mw_msep(aj0)$msep) / aj0$reserve
tir <- switch(as.character(P), "1" = function(n) sample(poolE, n, replace = TRUE), "2" = function(n) stats::rnorm(n))
gen <- function(aj, tirer) { I <- aj$I; J <- aj$J; tri <- matrix(NA_real_, I + 1, J + 1); tri[, 1] <- aj$tri[, 1]
  for (j in 0:(J - 1)) { idx <- 0:(I - j - 1); sg <- sqrt(aj$sigma2[j + 1]); if (!is.finite(sg)) sg <- 0
    e <- tirer(length(idx)); Cij <- tri[idx + 1, j + 1]; nv <- Cij * aj$f[j + 1] + e * sg * sqrt(Cij)
    inval <- !is.finite(nv) | nv <= 0; if (any(inval)) { nv[inval] <- NA_real_; tri[idx + 1, j + 2] <- nv; return(tri) }
    tri[idx + 1, j + 2] <- nv }; tri }
boucle <- function(aj, B, seed, figes, garder = FALSE) engine_sous_graine(seed, {
  pool <- .mw_pool_residus(aj, figes$degeneres); n_max <- FACTEUR_B_MAX_MW * (as.numeric(B) + 1); n_t <- 0
  sig <- rep(NA_real_, B); fits <- if (garder) vector("list", B) else NULL
  for (b in seq_len(B)) { t <- .mw_tirer_triangle_valide(aj, pool, n_max - n_t); n_t <- n_t + t$n
    if (is.null(t$tri)) next; ab <- try(mw_ajuster(t$tri), silent = TRUE); if (inherits(ab, "try-error")) next
    mb <- try(mw_msep(ab), silent = TRUE)
    if (!inherits(mb, "try-error") && is.finite(mb$msep) && ab$reserve > 0) { sig[b] <- sqrt(mb$msep) / ab$reserve; if (garder) fits[[b]] <- ab } }
  list(sig = sig, fits = fits) })
out <- data.frame(r = integer(0), sh = numeric(0), u = numeric(0), umin = numeric(0), nfin = integer(0), lsd = numeric(0), t = numeric(0))
for (r in seq_len(N)) {
  t1 <- proc.time()[["elapsed"]]
  tri <- engine_sous_graine(387000000 + 1000000 * (P - 1) + r, gen(aj0, tir))
  aj <- mw_ajuster(tri); sh <- sqrt(mw_msep(aj)$msep) / aj$reserve
  lg <- boucle(aj, 999, 387500000 + 1000000 * (P - 1) + r, .mw_ensembles_figes(aj))
  s <- lg$sig[is.finite(lg$sig)]
  out[r, ] <- list(r, sh, mean(s <= sigA), mean(s < sigA), length(s), sd(log(s)), proc.time()[["elapsed"]] - t1)
}
write.table(out, sprintf("/tmp/claude-0/-home-user-outil-usp/8f991392-3bf5-5fd0-a4b8-27e588ed5637/scratchpad/p610/u_P%d.tsv", P), sep = "\t", row.names = FALSE)
cat(sprintf("P%d N=%d sigma_A=%.7g ; temps moyen par triangle (B=999, boucle allegee) = %.3f s\n", P, N, sigA, mean(out$t)))
u <- out$u
cat("quantiles de u = G*(sigma_A) :", paste(sprintf("%.4f", quantile(u, c(.025, .05, .5, .9, .95, .975), type = 7)), collapse = " "), "\n")
cat(sprintf("part u >= 0.95 (manque haut I1 90%%) = %.3f ; part u = 1 = %.3f ; part u > 0.999 = %.3f ; part u <= 0.05 = %.3f\n",
            mean(u > 0.95), mean(u == 1), mean(u > 0.999), mean(u < 0.05)))
cat(sprintf("mediane sh/sigA = %.3f ; mediane sd(log sigma*) = %.3f ; sd(log sh) = %.3f\n", median(out$sh / sigA), median(out$lsd), sd(log(out$sh))))
