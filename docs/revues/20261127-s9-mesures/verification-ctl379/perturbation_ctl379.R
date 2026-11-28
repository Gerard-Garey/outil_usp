# Controle de methode : controle_chaine() corrige detecte une p_mc perturbee
# (une ligne de LIG_B de res$tests, p_mc + 1e-12 ou NA -> 0.5) sur une
# replication par (jeu, point) (b = 10) ; temoin non perturbe : identique.
SP <- "/tmp/claude-0/-home-user-outil-usp/3407551e-539e-4dba-954f-822f43f11bd0/scratchpad"
SCRIPT <- normalizePath("tests/puissance_t8.R")
commandArgs <- function(trailingOnly = FALSE)
  if (trailingOnly) "--familles" else c("R", paste0("--file=", SCRIPT), "--args", "--familles")
ex <- parse(SCRIPT, keep.source = FALSE, encoding = "UTF-8")
i_fam <- which(vapply(ex, function(e) identical(deparse(e)[1], "if (OPT_FAMILLES) {"), logical(1)))
for (e in ex[seq_len(i_fam - 1L)]) eval(e, globalenv())
rm(commandArgs)
POINTS_FAM <- strsplit(OPT_POINTS, ",", fixed = TRUE)[[1]]
PLAN <- list()
for (jn in JEUX_B) {
  J <- charger_jeu(jn); fit <- usp_ajuster(J$x, J$y)
  PLAN[[jn]] <- list(nom = jn, x = J$x, fit = fit, E = tirer_e(OPT_GRAINE + 1, 300L))
}
taches <- expand.grid(pt = POINTS_FAM, jeu = JEUX_B, stringsAsFactors = FALSE)
b <- 10L
out <- parallel::mclapply(seq_len(nrow(taches)), function(i) {
  J <- PLAN[[taches$jeu[i]]]; pt <- taches$pt[i]
  y <- simuler_alt(J$fit, POINTS_A[[pt]]$phi(J$E[b, ], J$x, b)); g <- OPT_GRAINE_IC + 1000 * b
  res <- run_engine(xt = J$x, yt = y, methode = METHODE, segment = SEGMENT, annexe = ANNEXE, nature_donnees = NATURE,
                    B = OPT_B, alpha = ALPHA, theta_equiv = THETA_EQUIV, seed = g, date_reference = DATE_REFERENCE_TESTS)
  temoin <- controle_chaine(J, y, g, res)
  # ligne de LIG_B perturbee : la k-ieme cle tournante, dans res$tests
  k <- LIG_B[(i - 1L) %% length(LIG_B) + 1L]
  j <- which(vapply(res$tests, function(l) identical(l$test, LIGNES[[k]]), logical(1)))
  stopifnot(length(j) == 1L)
  p0 <- res$tests[[j]]$p_mc
  rp <- res; rp$tests[[j]]$p_mc <- if (is.finite(p0)) p0 + 1e-12 else 0.5
  pert <- controle_chaine(J, y, g, rp)
  c(jeu = taches$jeu[i], point = pt, b = b, cle = k, p0 = sprintf("%.17g", p0), variante = res$bootstrap$p_mc_regime$variante,
    temoin = temoin, perturbe = pert)
}, mc.cores = 4L, mc.preschedule = FALSE)
print(as.data.frame(do.call(rbind, out)), right = FALSE)
