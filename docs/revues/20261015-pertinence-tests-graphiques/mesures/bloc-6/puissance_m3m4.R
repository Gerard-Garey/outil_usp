# Mesure exploratoire (bloc 6, revue de pertinence 15/10/2026) : niveau et
# puissance des lignes M3/M4 de Merz-Wuthrich sous le plan reserve2 (modele de
# Mack ajuste, erreurs gaussiennes), B = 199, R triangles par scenario.
# Constat de simulation sous un plan, scripts hors depot.
source("R/engine.R")
df <- utils::read.csv("tests/donnees/triangle_mw.csv")
tri <- as.matrix(df[, setdiff(names(df), "i")]); storage.mode(tri) <- "double"; tri <- unname(tri)
aj0 <- mw_ajuster(tri)
I <- aj0$I; J <- aj0$J; f <- aj0$f; s2 <- aj0$sigma2
args <- commandArgs(trailingOnly = TRUE)
R <- if (length(args)) as.integer(args[1]) else 100L
B <- if (length(args) > 1) as.integer(args[2]) else 199L

gen_h0 <- function() {
  repeat {
    C <- matrix(NA_real_, I + 1, J + 1); C[, 1] <- tri[, 1]
    ok <- TRUE
    for (j in 0:(J - 1)) for (i in 0:(I - j - 1)) {
      C[i + 1, j + 2] <- f[j + 1] * C[i + 1, j + 1] +
        sqrt(s2[j + 1] * C[i + 1, j + 1]) * stats::rnorm(1)
      if (!is.finite(C[i + 1, j + 2]) || C[i + 1, j + 2] <= 0) ok <- FALSE
    }
    if (ok) return(C)
  }
}
increments <- function(C) { P <- C; P[, -1] <- C[, -1] - C[, -ncol(C)]; P }
recumul <- function(P) { C <- P; for (j in 2:ncol(P)) C[, j] <- C[, j - 1] + P[, j]; C }
appliquer <- function(C, scen) {
  P <- increments(C)
  for (i in 0:I) for (j in 0:J) if (!is.na(P[i + 1, j + 1])) {
    k <- i + j
    fac <- switch(scen,
      H0 = 1,
      cal7 = if (k == 7) 1.15 else 1,
      cal4 = if (k == 4) 1.15 else 1,
      derive = (1.05)^max(0, k - 3),
      ligne = if (i == 2 && j >= 2) 1.5 else 1,
      cellule = if (i == 2 && j == 2) 4 else 1)
    P[i + 1, j + 1] <- P[i + 1, j + 1] * fac
  }
  recumul(P)
}
cles <- c("Calendrier", "KruskalAcc", "CorrDev", "DW", "Runs", "Grubbs")
scens <- c("H0", "cal7", "cal4", "derive", "ligne", "cellule")
out <- list()
t0 <- Sys.time()
for (sc in scens) {
  for (r in seq_len(R)) {
    seed <- 31000000L + match(sc, scens) * 100000L + r
    C <- engine_sous_graine(seed, appliquer(gen_h0(), sc))
    if (any(C[!is.na(C)] <= 0)) next
    aj <- try(mw_ajuster(C), silent = TRUE); if (inherits(aj, "try-error")) next
    figes <- .mw_ensembles_figes(aj)
    boot <- try(mw_bootstrap(aj, B = B, seed = seed + 50L, figes = figes), silent = TRUE)
    if (inherits(boot, "try-error")) next
    res <- mw_residus(aj, figes$degeneres)
    ro <- test_rosner(res$residu, alpha = 0.10)
    gr <- test_grubbs(res$residu)
    cal <- mw_test_annees_calendaires(aj, figes$degeneres)
    out[[length(out) + 1]] <- data.frame(scen = sc, r = r,
      t(boot$p_mc[cles]), rosner = ro$nb_outliers,
      grubbs_i = res$i[gr$idx], grubbs_j = res$j[gr$idx],
      Z = cal$Z, Zstar = cal$stat, DWstat = stat_dw(res$residu),
      stringsAsFactors = FALSE)
    if (sc == "H0" && r == 1) cat("premier triangle :", format(Sys.time() - t0), "\n")
  }
  cat(sc, "termine :", format(Sys.time() - t0), "\n")
}
D <- do.call(rbind, out)
write.table(D, "docs/revues/20261015-pertinence-tests-graphiques/mesures/bloc-6/puissance_brut.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
cat("\nR =", R, " B =", B, "\n")
cat("\nTaux de rejet a 0,10 (p_mc < 0,10) par scenario ; rosner : part avec >= 1 cellule declaree\n")
agg <- aggregate(cbind(Calendrier, KruskalAcc, CorrDev, DW, Runs, Grubbs) ~ scen, D, function(p) mean(p < 0.10))
agg$rosner <- aggregate(rosner ~ scen, D, function(x) mean(x >= 1))$rosner
agg$n <- aggregate(r ~ scen, D, length)$r
print(agg[match(scens, agg$scen), ], digits = 3)
cat("\nTaux a 0,05 (ECHEC)\n")
print(aggregate(cbind(Calendrier, KruskalAcc, CorrDev, DW, Runs, Grubbs) ~ scen, D, function(p) mean(p < 0.05))[match(scens, agg$scen), ], digits = 3)
cat("\nCellule injectee (2,2) : part ou Grubbs designe cette cellule, scenario cellule :\n")
dc <- D[D$scen == "cellule", ]; cat(mean(dc$grubbs_i == 2 & dc$grubbs_j == 2), "\n")
cat("\nCorrelation de Spearman des p_mc sous H0 (redondance) :\n")
dh <- D[D$scen == "H0", cles]; print(round(cor(dh, method = "spearman"), 2))
cat("\nSous H0 : part des triangles avec >= 1 rejet a 0,10 parmi les 5 lignes M3 :", mean(apply(D[D$scen == "H0", cles[1:5]] < 0.10, 1, any)), "\n")
cat("Sens de DW sous cal7 (DW < 2 = autocorr positive) : moyenne DWstat H0 / cal7 / derive :",
    tapply(D$DWstat, D$scen, mean)[c("H0", "cal7", "derive")], "\n")
