###############################################################################
#  docs/revues/20261123-a2-creneau/rejeu_sonde_S_615.R  --  REJEU DU BLOC S
#  DE LA SONDE DE #612 SUR LE MOTEUR CORRIGE DE #615 (variante P1)
#
#  Critere d'acceptation 2 de la specification d'actuary
#  (actuary-5-specification-615.md, par. 4) : sur le moteur corrige, les p du
#  mode "courant" doivent egaler les p "P1" de
#  docs/tableaux/20261123-issue612-simulation-jm1-trapeze-sonde.tsv.
#  tests/simulation_jm1_trapeze_t8.R ne peut pas servir : son controle
#  d'integrite (1) exige git diff --quiet HEAD -- R/engine.R, et son enveloppe
#  f_residus_sonde() garde l'ancienne signature de mw_residus() (instrument
#  de #612 fige, non modifie).
#
#  Methode : pour chacune des 35 lignes (configuration x rho x variante) du
#  TSV, triangle reconstruit par la recette tri_sonde() du script de sonde,
#  mw_bootstrap(aj, B = 999, seed = graine de la ligne,
#  figes = .mw_ensembles_figes(aj)) sur le moteur de la copie de travail,
#  SANS substitution de mw_residus() ; variante V2 : .mw_simulation_sigma_direct()
#  remplacee le temps de l'appel, dans environment(run_engine), par le corps
#  F_V2 du script (l. 501), puis restauree. Sont compares, au bit pres
#  (identical() sur les valeurs relues du TSV), les 13 p_mc, les 13 err_mc et
#  les 13 statistiques observees a la ligne "P1" ; |dp| au mode "courant"
#  donne l'effet de #615. Lecture seule : aucun fichier ecrit.
#
#  Lancement, depuis la racine du depot (chemins relatifs a la racine ;
#  2 processus, quelques minutes) :
#      LC_ALL=C.UTF-8 Rscript docs/revues/20261123-a2-creneau/rejeu_sonde_S_615.R
#  Sortie versee : rejeu_sonde_S_615.txt (meme dossier).
###############################################################################
if (!file.exists("R/charger_moteur.R")) stop("lancer depuis la racine du depot")
source("R/charger_moteur.R")
ENV <- charger_moteur(dans = globalenv()); ENV_M <- environment(run_engine)
source_tri <- function(f) { d <- utils::read.csv(f); m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m) }
BASES <- list(reserve2 = source_tri("tests/donnees/triangle_mw.csv"),
              reserve2_trapeze = source_tri("tests/donnees/triangle_mw_trapeze.csv"))
tri_sonde <- function(base, jstar, rho) {
  tri <- BASES[[base]]; I <- nrow(tri) - 1L; J <- ncol(tri) - 1L
  a0 <- mw_ajuster(tri); f <- a0$f[jstar + 1L]
  F0 <- tri[, -1L, drop = FALSE] / tri[, -ncol(tri), drop = FALSE]
  n <- I - jstar; u <- seq(-1, 1, length.out = n)
  nt <- tri
  nt[seq_len(n), jstar + 2L] <- nt[seq_len(n), jstar + 1L] * f * (1 + rho * u)
  if (jstar + 1L <= J - 1L) for (j in (jstar + 1L):(J - 1L)) {
    r <- seq_len(I - j); nt[r, j + 2L] <- nt[r, j + 1L] * F0[r, j + 1L]
  }
  nt
}
F_V2 <- function(aj) !is.null(aj[["sigma2_Jm1_direct"]]) && !.mw_colonne_degeneree(aj, aj$J - 1L)
environment(F_V2) <- ENV_M
tsv <- utils::read.delim("docs/tableaux/20261123-issue612-simulation-jm1-trapeze-sonde.tsv", colClasses = "character", check.names = FALSE)
CLES <- names(MW_CATALOGUE_MC)
cles_tsv <- paste0("p:", CLES); err_tsv <- paste0("err:", CLES)
taches <- unique(tsv[, c("cfg", "base", "jstar", "rho", "graine", "variante")])
un <- function(k) {
  t <- taches[k, ]
  tri <- tri_sonde(t$base, as.integer(t$jstar), as.numeric(t$rho))
  aj <- mw_ajuster(tri); fg <- .mw_ensembles_figes(aj)
  orig <- get(".mw_simulation_sigma_direct", envir = ENV_M)
  if (t$variante == "V2") assign(".mw_simulation_sigma_direct", F_V2, envir = ENV_M)
  bt <- tryCatch(mw_bootstrap(aj, B = 999, seed = as.numeric(t$graine), figes = fg),
                 finally = assign(".mw_simulation_sigma_direct", orig, envir = ENV_M))
  lig <- function(mode) tsv[tsv$cfg == t$cfg & tsv$rho == t$rho & tsv$variante == t$variante & tsv$mode == mode, ]
  p_new <- unlist(bt$p_mc[CLES]); e_new <- unlist(bt$err_mc[CLES]); o_new <- unlist(bt$stats_obs[CLES])
  P1 <- lig("P1"); CO <- lig("courant")
  num <- function(L, cols) as.numeric(unlist(L[, cols]))
  dP1 <- abs(p_new - num(P1, cles_tsv)); dCO <- abs(p_new - num(CO, cles_tsv))
  data.frame(cfg = t$cfg, base = t$base, jstar = t$jstar, rho = as.numeric(t$rho), variante = t$variante,
             p_egal_P1 = identical(unname(p_new), num(P1, cles_tsv)),
             err_egal_P1 = identical(unname(e_new), num(P1, err_tsv)),
             obs_egal_P1 = identical(unname(o_new), num(P1, paste0("obs:", CLES))),
             maxdp_P1 = suppressWarnings(max(dP1, na.rm = TRUE)), maxdp_courant = suppressWarnings(max(dCO, na.rm = TRUE)),
             cle_maxdp_courant = if (all(is.na(dCO))) NA_character_ else CLES[which.max(dCO)],
             Beff_min = min(unlist(bt$B_effectif[CLES])), Beff_min_P1 = as.integer(P1$B_eff_min),
             stringsAsFactors = FALSE)
}
R <- do.call(rbind, parallel::mclapply(seq_len(nrow(taches)), un, mc.cores = 2L, mc.preschedule = FALSE))
R <- R[order(as.integer(R$cfg), R$variante, R$rho), ]
cat("md5 R/engine.R :", unname(tools::md5sum("R/engine.R")), "\n")
print(R, row.names = FALSE)
cat("\nLignes :", nrow(R), " p = P1 (identical) :", sum(R$p_egal_P1), " err = P1 :", sum(R$err_egal_P1),
    " obs = P1 :", sum(R$obs_egal_P1), " max |dp| vs P1 :", max(R$maxdp_P1), "\n")
