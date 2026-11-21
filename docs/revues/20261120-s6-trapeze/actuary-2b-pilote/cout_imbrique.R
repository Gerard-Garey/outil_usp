setwd("/home/user/outil_usp")
source("tests/outils_tests.R")
restreindre <- function(tri) { tri[row(tri) + col(tri) - 2L > nrow(tri) - 1L] <- NA; tri }
tri0 <- restreindre(.tri); aj0 <- mw_ajuster(tri0)
B1 <- 40; B2 <- 199
t0 <- proc.time()[["elapsed"]]
fig0 <- .mw_ensembles_figes(aj0)
outer <- engine_sous_graine(610900001, {
  pool <- .mw_pool_residus(aj0, fig0$degeneres); n_max <- FACTEUR_B_MAX_MW * (B1 + 1); n_t <- 0; fits <- list()
  for (b in seq_len(B1)) { t <- .mw_tirer_triangle_valide(aj0, pool, n_max - n_t); n_t <- n_t + t$n
    ab <- mw_ajuster(t$tri); fits[[b]] <- ab }
  fits })
t1 <- proc.time()[["elapsed"]]
nfit <- 0; tf <- 0
res <- lapply(seq_along(outer), function(b) {
  ab <- outer[[b]]
  ta <- proc.time()[["elapsed"]]
  fb <- .mw_ensembles_figes(ab)
  tf <<- tf + proc.time()[["elapsed"]] - ta
  engine_sous_graine(610950000 + b, {
    pool <- .mw_pool_residus(ab, fb$degeneres); n_max <- FACTEUR_B_MAX_MW * (B2 + 1); n_t <- 0; s <- rep(NA_real_, B2)
    for (k in seq_len(B2)) { t <- .mw_tirer_triangle_valide(ab, pool, n_max - n_t); n_t <- n_t + t$n
      if (is.null(t$tri)) next; a2 <- try(mw_ajuster(t$tri), silent = TRUE); if (inherits(a2, "try-error")) next
      m2 <- try(mw_msep(a2), silent = TRUE); nfit <<- nfit + 1
      if (!inherits(m2, "try-error") && is.finite(m2$msep) && a2$reserve > 0) s[k] <- sqrt(m2$msep) / a2$reserve }
    s })
})
t2 <- proc.time()[["elapsed"]]
cat(sprintf("interne : %d ajustements en %.2f s, soit %.3f ms par ajustement (dont figes : %.2f s pour %d appels, %.1f ms par appel)\n",
            nfit, t2 - t1, 1000 * (t2 - t1) / nfit, tf, length(outer), 1000 * tf / length(outer)))
# controle : boucle interne identique a mw_bootstrap(ab, B2, seed)$sigma_boot (premier b)
bt <- mw_bootstrap(outer[[1]], B = as.numeric(B2), seed = 610950001, figes = .mw_ensembles_figes(outer[[1]]))
s1 <- res[[1]]; cat("identique a mw_bootstrap()$sigma_boot :", identical(bt$sigma_boot, s1[is.finite(s1)]), "\n")
t3 <- proc.time()[["elapsed"]]
r <- run_engine(methode = "reserve2", triangle = .tri, segment = 1, annexe = "II", date_reference = DATE_REFERENCE_TESTS)
cat(sprintf("run_engine(reserve2) : %.1f s ; mw_bootstrap(B=199) complet : voir ci-dessus (%.1f s)\n", proc.time()[["elapsed"]] - t3, t3 - t2))
