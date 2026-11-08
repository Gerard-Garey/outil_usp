setwd("/home/user/outil_usp")
source("R/charger_moteur.R"); charger_moteur()
env <- environment(run_engine)
sys.source("/tmp/duree-ci/patch_mw_wls.R", envir = env)
ref <- function(C0, C1) { m <- try(env$.mw_summary_lm(stats::lm(C1 ~ C0, weights = 1 / C0)), silent = TRUE); if (inherits(m, "try-error")) "erreur" else if (nrow(m$coefficients) < 2) "rang" else unname(m$coefficients) }
new <- function(C0, C1) { m <- try(env$.mw_wls_coefs(C0, C1), silent = TRUE); if (inherits(m, "try-error")) "erreur" else if (is.null(m)) "rang" else unname(m) }
set.seed(1); n_ko <- 0; types <- character(0)
for (k in 1:3000) {
  n <- sample(3:9, 1); typ <- sample(c("alea", "parfait", "constant", "echelle", "exaequo"), 1)
  C0 <- exp(rnorm(n, 10, 1))
  if (typ == "constant") C0 <- rep(C0[1], n)
  if (typ == "exaequo") C0[2] <- C0[1]
  C1 <- C0 * exp(rnorm(n, 0.3, 0.1))
  if (typ == "parfait") C1 <- 1.5 * C0
  if (typ == "echelle") { C0 <- C0 * 1e8; C1 <- C1 * 1e8 }
  a <- suppressWarnings(ref(C0, C1)); b <- suppressWarnings(new(C0, C1))
  if (!identical(a, b)) { n_ko <- n_ko + 1; types <- c(types, typ) }
}
cat("cas differents :", n_ko, "sur 3000\n"); print(table(types))
