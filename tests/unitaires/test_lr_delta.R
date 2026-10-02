###############################################################################
#  tests/unitaires/test_lr_delta.R  --  RAPPORT DE VRAISEMBLANCE SUR DELTA ET
#  BOOTSTRAP RESTREINT (issue #45, specification d'actuary du 28/09/2026,
#  par. 5, tests U1 a U10 ; decisions du mainteneur du 28/09/2026) ; U11 :
#  echec isole sur l'observe et chemins d'echec du bootstrap restreint (#161)
#
#  usp_ajuster_contraint(), .p_melange_chernoff(), usp_lr_delta(),
#  champ sigma_boot_restreint de usp_bootstrap(), ic_bootstrap_restreint et
#  largeur_ic_restreint de run_engine(), trois lignes de diagnostic de
#  usp_tests(), plots_data$lr_delta, arguments p_mc_ext / err_mc_ext de add().
#  References independantes :
#    - forme fermee du MV lognormal a delta = 1 (pi_t constant) :
#      m = moyenne(ln r_t), s2 = somme((ln r_t - m)^2) / T,
#      beta~ = exp(m + s2 / 2), sigma~ = beta~ sqrt(exp(s2) - 1) ;
#    - extremites du profil usp_profil()$delta_obj (optimisation distincte) ;
#    - p-value Monte-Carlo (1 + #{LR* >= LR}) / (B + 1) recalculee a la main ;
#    - quantiles de l'IC restreint recalcules a partir des tirages.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_lr_delta.R")

# J1 : jeu de test du depot (delta estime au bord 1) ; J2 : jeu a delta
# interieur (test_controles_numeriques.R)
x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
xi <- c(50, 80, 120, 200, 300, 150, 90, 60)
yi <- c(29.92, 56.9, 101.25, 123.06, 207.23, 105.91, 68.59, 40.05)
B_T <- 199L; GRAINE <- 20260831

# Forme fermee du MV lognormal a delta = 1
forme_fermee_1 <- function(x, y) {
  lr <- log(y / x); m <- mean(lr); s2 <- sum((lr - m)^2) / length(lr)
  b <- exp(m + s2 / 2)
  c(beta = b, sigma = b * sqrt(exp(s2) - 1))
}

f1 <- usp_ajuster(x, y); f2 <- usp_ajuster(xi, yi)
l1 <- usp_lr_delta(f1, B = B_T, seed = GRAINE)
l2 <- usp_lr_delta(f2, B = B_T, seed = GRAINE)

# --- U1 : forme fermee a delta = 1 --------------------------------------------
verifier("U1 usp_ajuster_contraint(delta0 = 1) : sigma et beta de la forme fermee (J1, J2), 1e-6 relatif",
         {
           ok <- TRUE
           for (j in list(list(x, y, f1), list(xi, yi, f2))) {
             fc <- usp_ajuster_contraint(j[[1]], j[[2]], 1, j[[3]]$gamma)
             ff <- forme_fermee_1(j[[1]], j[[2]])
             ok <- ok && isTRUE(proche(fc$sigma, ff[["sigma"]], rel = 1e-6)) &&
               isTRUE(proche(fc$beta, ff[["beta"]], rel = 1e-6))
           }
           ok
         })
verifier("U1 usp_ajuster_contraint() : forme de usp_ajuster_rapide() (delta fixe, champs de usp_simuler())",
         {
           fc <- usp_ajuster_contraint(xi, yi, 0, f2$gamma)
           fc$delta == 0 && all(c("pi", "beta", "sigma", "obj", "gamma", "T", "x", "y", "xbar") %in% names(fc))
         })

# --- U2 : coherence avec le profil ---------------------------------------------
verifier("U2 obj_contraint aux bornes = extremites de usp_profil()$delta_obj, LR = max(0, extremite - obj_min) (J1, J2), 1e-6",
         {
           ok <- TRUE
           for (j in list(list(f1, l1), list(f2, l2))) {
             pr <- usp_profil(j[[1]]); n <- length(pr$delta_obj)
             ok <- ok && n == 41L &&
               isTRUE(proche(j[[2]]$borne0$obj_contraint, pr$delta_obj[1], rel = 0, abs = 1e-6)) &&
               isTRUE(proche(j[[2]]$borne1$obj_contraint, pr$delta_obj[n], rel = 0, abs = 1e-6)) &&
               isTRUE(proche(j[[2]]$borne0$lr, max(0, pr$delta_obj[1] - j[[1]]$obj_min), rel = 0, abs = 1e-6)) &&
               isTRUE(proche(j[[2]]$borne1$lr, max(0, pr$delta_obj[n] - j[[1]]$obj_min), rel = 0, abs = 1e-6))
           }
           ok
         })

# --- U3 : bornes -----------------------------------------------------------------
verifier("U3 J1 (delta estime = 1) : LR(1) == 0 exactement, p_mc(1) == 1, LR(0) > 0",
         l1$borne1$lr == 0 && l1$borne1$p_mc == 1 && l1$borne0$lr > 0)
verifier("U3 J2 (delta interieur) : LR(0) > 0 et LR(1) > 0",
         l2$borne0$lr > 0 && l2$borne1$lr > 0)
verifier("U3 LR >= 0, LR* >= 0, n_refit_pire == 0 et n_echec == 0 (J1, J2, deux bornes)",
         all(vapply(list(l1$borne0, l1$borne1, l2$borne0, l2$borne1), function(b)
           b$lr >= 0 && all(b$lr_boot >= 0) && b$n_refit_pire == 0L && b$n_echec == 0L, logical(1))))

# --- U4 : p asymptotique du melange ----------------------------------------------
verifier("U4 .p_melange_chernoff() : p(0) = 1, p(qchisq(0,8 ; 1)) = 0,10, p(qchisq(0,9 ; 1)) = 0,05",
         .p_melange_chernoff(0) == 1 &&
           isTRUE(proche(.p_melange_chernoff(stats::qchisq(0.8, 1)), 0.10, rel = 0, abs = 1e-12)) &&
           isTRUE(proche(.p_melange_chernoff(stats::qchisq(0.9, 1)), 0.05, rel = 0, abs = 1e-12)))
verifier("U4 p_asymptotique de usp_lr_delta() = .p_melange_chernoff(LR) (J1, J2)",
         all(vapply(list(l1$borne0, l1$borne1, l2$borne0, l2$borne1), function(b)
           identical(b$p_asymptotique, .p_melange_chernoff(b$lr)), logical(1))))

# --- U5 : invariant avec le bootstrap principal ----------------------------------
verifier("U5 J1, borne delta = 1 = delta estime, meme graine : LR*_b == 0 des que delta*_b >= 1 - TOL_DELTA_BORD",
         {
           bt <- usp_bootstrap(f1, B = B_T, seed = GRAINE)
           l1$borne1$n_echec == 0L && length(bt$delta_boot) == B_T &&
             length(l1$borne1$lr_boot) == B_T &&
             sum(bt$delta_boot >= 1 - TOL_DELTA_BORD) > 0 &&
             all(l1$borne1$lr_boot[bt$delta_boot >= 1 - TOL_DELTA_BORD] == 0)
         })

# --- U6 : p Monte-Carlo recalculee ------------------------------------------------
verifier("U6 p_mc = (1 + #{LR* >= LR}) / (B_eff + 1), err_mc = sqrt(p(1 - p) / B_eff), granularite = 1 / (B_eff + 1)",
         all(vapply(list(l1$borne0, l2$borne0, l2$borne1), function(b) {
           Be <- length(b$lr_boot)
           p <- (1 + sum(b$lr_boot >= b$lr)) / (Be + 1)
           b$B_effectif == Be && isTRUE(proche(b$p_mc, p)) &&
             isTRUE(proche(b$err_mc, sqrt(p * (1 - p) / Be))) &&
             isTRUE(proche(b$granularite, 1 / (Be + 1))) &&
             isTRUE(proche(b$part_lr_nul, mean(b$lr_boot == 0)))
         }, logical(1))))

# --- U7 : volumes constants ------------------------------------------------------
rc <- run_engine(xt = rep(110, 8), yt = y, methode = "premium", segment = 1, annexe = "II",
                 nature_donnees = "brutes", B = B_MIN_USAGE, seed = GRAINE)
verifier("U7 volumes constants : LR nuls, LR* tous nuls, p_mc NA, motif MOTIF_MC_DISPERSION_NULLE",
         isTRUE(rc$ok) &&
           all(vapply(list(rc$lr_delta$borne0, rc$lr_delta$borne1), function(b)
             b$lr == 0 && length(b$lr_boot) == B_MIN_USAGE && all(b$lr_boot == 0) &&
               is.na(b$p_mc) && identical(b$motif_mc, MOTIF_MC_DISPERSION_NULLE), logical(1))))
verifier("U7 volumes constants : lignes LR INFO, detail = motif puis VOLUMES CONSTANTS",
         {
           tt <- rc$tests[vapply(rc$tests, function(t) grepl("^Rapport de vraisemblance : delta", t$test), logical(1))]
           length(tt) == 2L && all(vapply(tt, function(t)
             t$verdict == "INFO" && is.na(t$p_mc) &&
               startsWith(t$detail, paste0(MOTIF_MC_DISPERSION_NULLE, " : aucune p-value Monte-Carlo.")) &&
               grepl("VOLUMES CONSTANTS : delta non identifie", t$detail, fixed = TRUE) &&
               !grepl("SOLUTION AU BORD", t$detail, fixed = TRUE), logical(1)))
         })

# --- U8 : structure ----------------------------------------------------------------
r1 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                 nature_donnees = "brutes", B = B_T, seed = GRAINE)
CHAMPS_BORNE <- c("delta0", "gamma_contraint", "beta_contraint", "sigma_contraint", "obj_contraint",
                  "lr", "p_asymptotique", "p_mc", "err_mc", "B_effectif", "granularite", "motif_mc",
                  "part_lr_nul", "n_refit_pire", "n_echec", "lr_boot")
verifier("U8 res$lr_delta : champs dans l'ordre (borne0, borne1, B, seed, tol_nul ; 16 champs par borne)",
         identical(names(r1$lr_delta), c("borne0", "borne1", "B", "seed", "tol_nul")) &&
           identical(names(r1$lr_delta$borne0), CHAMPS_BORNE) &&
           identical(names(r1$lr_delta$borne1), CHAMPS_BORNE) &&
           r1$lr_delta$B == B_T && r1$lr_delta$seed == GRAINE && r1$lr_delta$tol_nul == TOL_OPTIMUM)
verifier("U8 res$profil sans lr_delta0 ni lr_delta1",
         identical(names(r1$profil), c("delta_grid", "delta_obj", "gamma_grid", "gamma_obj")))
# Depuis l'issue #47, plots_data$qq_enveloppe suit lr_delta et
# bootstrap$z_boot suit n_echec_restreint (champs ajoutes en fin de liste).
verifier("U8 res : lr_delta apres profil, ic_bootstrap_restreint apres ic_bootstrap, plots_data$lr_delta suivi du seul qq_enveloppe (#47)",
         {
           n <- names(r1)
           match("lr_delta", n) == match("profil", n) + 1L &&
             match("ic_bootstrap_restreint", n) == match("ic_bootstrap", n) + 1L &&
             identical(tail(names(r1$plots_data), 2), c("lr_delta", "qq_enveloppe")) &&
             identical(tail(names(r1$bootstrap), 3), c("sigma_boot_restreint", "n_echec_restreint", "z_boot")) &&
             is.integer(r1$bootstrap$n_echec_restreint) &&
             tail(names(r1$ajustement), 1) == "kkt_au_moins_un" &&
             "largeur_ic_restreint" %in% names(r1$ajustement)
         })
NOMS_45 <- c("Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime)",
             "Rapport de vraisemblance : delta = 0 (variance lineaire en volume)",
             "Rapport de vraisemblance : delta = 1 (variance quadratique en volume)")
verifier("U8 trois dernieres lignes de tests : diagnostics G., INFO, p_retenue et nature_p NA, apres la largeur de l'IC complet",
         {
           n <- length(r1$tests); t3 <- r1$tests[(n - 2):n]
           identical(vapply(t3, `[[`, "", "test"), NOMS_45) &&
             r1$tests[[n - 3]]$test == "Largeur relative de l'IC bootstrap 90%" &&
             all(vapply(t3, function(t) t$type == "diagnostic" && t$verdict == "INFO" &&
                          is.na(t$p_retenue) && is.na(t$nature_p) && is.na(t$sens) &&
                          startsWith(t$famille, "G."), logical(1)))
         })
verifier("U8 lignes LR sur J1 : stat = LR, estim = sigma contraint, p_mc et err_mc de la borne (finies), p_as du melange",
         {
           n <- length(r1$tests)
           all(vapply(1:2, function(k) {
             t <- r1$tests[[n - 2 + k]]; b <- r1$lr_delta[[k]]
             identical(t$stat, b$lr) && identical(t$estim, b$sigma_contraint) &&
               is.finite(t$p_mc) && identical(t$p_mc, b$p_mc) && identical(t$err_mc, b$err_mc) &&
               identical(t$p_asymptotique, b$p_asymptotique) && is.na(t$p_exacte)
           }, logical(1))) &&
             startsWith(r1$tests[[n]]$detail, "SOLUTION AU BORD delta = 1 : LR = 0 par construction.") &&
             startsWith(r1$tests[[n - 1]]$detail, "Aucun verdict (ADR 0001)")
         })
verifier("U8 add() : p_mc_ext et mc_nom ensemble -> erreur",
         {
           reg <- engine_registre_tests(r1$bootstrap, USP_CATALOGUE_MC, 0.10, "Monte-Carlo")
           leve_erreur(reg$add("G.", "essai", "ref", fonction = "usp_tests", mc_nom = names(USP_CATALOGUE_MC)[1], p_mc_ext = 0.5)) &&
             !leve_erreur(reg$add("G.", "essai", "ref", fonction = "usp_tests", type = "diagnostic", p_mc_ext = 0.5, err_mc_ext = 0.01))
         })
# Cas construit (#126, constat C1 d'audit) : tous les LR* nuls et LR observe
# positif a la borne delta = 0 de J1 -> engine_p_mc() pose
# MOTIF_MC_ATOME_HORS_OBS. La borne est forgee a partir de usp_lr_delta()
# (champs de engine_p_mc() reportes tels quels) et passee a usp_tests(),
# chemin reel de la ligne (p_mc_ext de add()).
verifier("U8 ligne LR, loi simulee ponctuelle hors de l'atome : motif puis DETAIL_MC_ATOME_HORS_OBS dans le detail (#126)",
         {
           mc0 <- engine_p_mc(rep(0, 60), 1e-3, "haut")
           lf <- l1
           lf$borne0$lr <- 1e-3; lf$borne0$lr_boot <- rep(0, 60)
           lf$borne0$p_mc <- mc0$p_mc; lf$borne0$err_mc <- mc0$err_mc
           lf$borne0$B_effectif <- mc0$B_effectif; lf$borne0$granularite <- mc0$granularite
           lf$borne0$motif_mc <- mc0$motif
           tf <- usp_tests(f1, r1$bootstrap, methode = "premium", lr_delta = lf)
           t0 <- tf[[which(vapply(tf, `[[`, "", "test") == NOMS_45[2])]]
           t1 <- tf[[which(vapply(tf, `[[`, "", "test") == NOMS_45[3])]]
           identical(mc0$motif, MOTIF_MC_ATOME_HORS_OBS) &&
             t0$verdict == "INFO" && is.na(t0$p_mc) && is.na(t0$p_retenue) &&
             startsWith(t0$detail, paste(paste0(MOTIF_MC_ATOME_HORS_OBS, " : aucune p-value Monte-Carlo."),
                                         DETAIL_MC_ATOME_HORS_OBS, "Aucun verdict (ADR 0001)")) &&
             !grepl(DETAIL_MC_ATOME_HORS_OBS, t1$detail, fixed = TRUE)
         })
verifier("U8 plots_data$lr_delta : seuil obj_min + qchisq(0,80 ; 1), q90 du LR simule, LR",
         {
           L <- r1$plots_data$lr_delta; om <- r1$ajustement$obj_min
           q <- function(v) unname(stats::quantile(v, 0.90, type = 7))
           identical(names(L), c("obj_min", "seuil_asymptotique", "q90_bootstrap", "lr")) &&
             L$obj_min == om && L$seuil_asymptotique == om + stats::qchisq(0.80, 1) &&
             identical(names(L$q90_bootstrap), c("delta0", "delta1")) &&
             isTRUE(proche(L$q90_bootstrap, c(om + q(r1$lr_delta$borne0$lr_boot),
                                              om + q(r1$lr_delta$borne1$lr_boot)))) &&
             identical(unname(L$lr), c(r1$lr_delta$borne0$lr, r1$lr_delta$borne1$lr))
         })
verifier("U8 reserve2 : ni lr_delta ni ic_bootstrap_restreint",
         {
           df <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
           tri <- unname(as.matrix(df[, -1]))
           r2 <- run_engine(methode = "reserve2", triangle = tri, segment = 1, annexe = "II",
                            B = B_MIN_USAGE, seed = GRAINE)
           isTRUE(r2$ok) && is.null(r2$lr_delta) && is.null(r2$ic_bootstrap_restreint) &&
             !"lr_delta" %in% names(r2$plots_data)
         })

# --- U9 : bootstrap restreint par forme fermee -------------------------------------
verifier("U9 J1 : n_echec_restreint = 0, sigma_boot_restreint = forme fermee a delta = 1 sur les memes y* (1e-6 relatif), meme longueur que sigma_boot",
         {
           bt <- r1$bootstrap
           ys <- engine_sous_graine(GRAINE, lapply(seq_len(B_T), function(b) usp_simuler(r1$ajustement)))
           ff <- vapply(ys, function(v) forme_fermee_1(x, v)[["sigma"]], numeric(1))
           identical(bt$n_echec_restreint, 0L) &&
             length(bt$sigma_boot_restreint) == length(bt$sigma_boot) &&
             isTRUE(proche(bt$sigma_boot_restreint, ff, rel = 1e-6))
         })

# --- U10 : IC restreint --------------------------------------------------------------
verifier("U10 ic_bootstrap_restreint = quantiles de c sigma*_r sqrt((T+1)/(T-1)) + (1 - c) sigma_std ; largeur = (q95 - q05) / sigma_USP",
         {
           pf <- r1$parametre_final; T <- length(x)
           u <- pf$credibilite * r1$bootstrap$sigma_boot_restreint * sqrt((T + 1) / (T - 1)) +
             (1 - pf$credibilite) * pf$sigma_standard
           q <- stats::quantile(u, c(.025, .05, .5, .95, .975))
           isTRUE(proche(r1$ic_bootstrap_restreint, q)) &&
             identical(names(r1$ic_bootstrap_restreint), names(q)) &&
             isTRUE(proche(r1$ajustement$largeur_ic_restreint,
                           (q[["95%"]] - q[["5%"]]) / pf$sigma_usp))
         })

# --- U11 : echec isole sur l'observe et chemins d'echec du bootstrap restreint (#161) ---
# Erreur injectee dans l'environnement du moteur (comme #145,
# test_controles_entree.R), sans argument nouveau de run_engine() :
# usp_ajuster_contraint() en echec sur les seules donnees OBSERVEES a une
# borne (J2, delta interieur : les deux bornes appellent l'ajustement
# contraint sur l'observe) ; usp_objectif() en echec dans usp_profil()
# seulement (pile d'appel) ; usp_ajuster_contraint() en echec un appel sur
# cinq sur les y* (m3). Attendu : ok = TRUE, sigma_USP et autres resultats
# inchanges, ligne concernee "non applicable", INFO, p_retenue NA, motif fixe.
avec_injection_161 <- function(nom, f, expr) {
  e <- environment(run_engine)
  orig <- get(nom, envir = e)
  assign(nom, f, envir = e)
  on.exit(assign(nom, orig, envir = e))
  expr
}
contraint_orig <- usp_ajuster_contraint; objectif_orig <- usp_objectif
calcul_j2 <- function() run_engine(xt = xi, yt = yi, methode = "premium", segment = 1,
                                   annexe = "II", nature_donnees = "brutes",
                                   B = B_MIN_USAGE, seed = GRAINE)
r2_ref <- calcul_j2()
panne_borne <- function(d_cible) function(x, y, delta0, gamma_depart) {
  if (identical(y, yi) && delta0 == d_cible) stop("panne simulee")
  contraint_orig(x, y, delta0, gamma_depart)
}
lignes_lr <- function(r) r$tests[vapply(r$tests, function(t)
  grepl("^Rapport de vraisemblance : delta", t$test), logical(1))]
for (d_cible in c(0, 1)) {
  r_p <- avec_injection_161("usp_ajuster_contraint", panne_borne(d_cible), calcul_j2())
  k <- d_cible + 1L; autre <- 3L - k
  nb <- c("borne0", "borne1")
  b <- r_p$lr_delta[[nb[k]]]
  verifier(sprintf("U11 borne delta = %d en echec sur l'observe : ok = TRUE, borne de meme forme (16 champs), valeurs NA, aucun bootstrap restreint (#161)", d_cible),
           isTRUE(r2_ref$ok) && isTRUE(r_p$ok) && identical(names(b), CHAMPS_BORNE) &&
             b$delta0 == d_cible && is.na(b$lr) && is.na(b$sigma_contraint) &&
             is.na(b$p_asymptotique) && is.na(b$p_mc) && is.na(b$err_mc) &&
             identical(b$B_effectif, 0) && length(b$lr_boot) == 0L &&
             identical(b$motif_mc, MOTIF_MC_OBS_NON_FINIE) &&
             identical(b$n_echec, NA_integer_) && identical(b$n_refit_pire, NA_integer_) &&
             identical(names(r_p$lr_delta), names(r2_ref$lr_delta)))
  verifier(sprintf("U11 borne delta = %d en echec : autre borne, sigma_USP, bootstrap, profil et lignes hors LR identiques au calcul sans panne (#161)", d_cible),
           identical(r_p$lr_delta[[nb[autre]]], r2_ref$lr_delta[[nb[autre]]]) &&
             identical(r_p$parametre_final, r2_ref$parametre_final) &&
             identical(r_p$bootstrap, r2_ref$bootstrap) &&
             identical(r_p$profil, r2_ref$profil) &&
             identical(r_p$tests[-match(NOMS_45[k + 1L], vapply(r_p$tests, `[[`, "", "test"))],
                       r2_ref$tests[-match(NOMS_45[k + 1L], vapply(r2_ref$tests, `[[`, "", "test"))]))
  verifier(sprintf("U11 borne delta = %d en echec : ligne non applicable, INFO, non inoperante, p_retenue NA, detail = MOTIF_LR_DELTA_ECHEC, fonction usp_lr_delta (#161)", d_cible),
           {
             t <- lignes_lr(r_p)[[k]]
             t$test == NOMS_45[k + 1L] && t$type == "non applicable" && t$verdict == "INFO" &&
               is.na(t$p_retenue) && is.na(t$stat) && is.na(t$estim) &&
               is.na(t$p_mc) && is.na(t$p_asymptotique) && is.na(t$sens) &&
               identical(t$detail, MOTIF_LR_DELTA_ECHEC) && t$fonction == "usp_lr_delta" &&
               identical(t$inoperant, FALSE) &&
               identical(lignes_lr(r_p)[[autre]], lignes_lr(r2_ref)[[autre]])
           })
  verifier(sprintf("U11 borne delta = %d en echec : plots_data de meme forme, lr et q90 a NA pour cette borne seule (#161)", d_cible),
           {
             L <- r_p$plots_data$lr_delta; L0 <- r2_ref$plots_data$lr_delta
             identical(names(r_p$plots_data), names(r2_ref$plots_data)) &&
               identical(names(L), names(L0)) && is.na(L$lr[[k]]) && is.na(L$q90_bootstrap[[k]]) &&
               identical(L$lr[[autre]], L0$lr[[autre]]) &&
               identical(L$q90_bootstrap[[autre]], L0$q90_bootstrap[[autre]]) &&
               identical(L$seuil_asymptotique, L0$seuil_asymptotique) &&
               identical(r_p$plots_data[setdiff(names(r2_ref$plots_data), "lr_delta")],
                         r2_ref$plots_data[setdiff(names(r2_ref$plots_data), "lr_delta")])
           })
}

# LR observe non fini sans erreur R (garde !is.finite(lr) de une_borne()) :
# ajustement contraint de la borne 0 rendu avec un objectif NaN sur l'observe.
r_nan <- avec_injection_161("usp_ajuster_contraint", function(x, y, delta0, gamma_depart) {
  f <- contraint_orig(x, y, delta0, gamma_depart)
  if (identical(y, yi) && delta0 == 0) f$obj <- NaN
  f
}, calcul_j2())
verifier("U11 borne delta = 0 a objectif contraint NaN sur l'observe : ok = TRUE, meme borne en echec et meme ligne non applicable que sur erreur R (#161)",
         isTRUE(r_nan$ok) && identical(names(r_nan$lr_delta$borne0), CHAMPS_BORNE) &&
           is.na(r_nan$lr_delta$borne0$lr) && length(r_nan$lr_delta$borne0$lr_boot) == 0L &&
           identical(r_nan$lr_delta$borne1, r2_ref$lr_delta$borne1) &&
           identical(lignes_lr(r_nan)[[1]]$detail, MOTIF_LR_DELTA_ECHEC) &&
           lignes_lr(r_nan)[[1]]$type == "non applicable")

# Volumes constants (avis d'actuary, #161) : x constant, delta non identifie ;
# la borne delta = 1 en echec sur l'observe rend une ligne non applicable dont
# le detail rappelle que le LR y serait nul par construction, suivi du motif
# fixe ; l'autre ligne garde son detail ordinaire (prefixe VOLUMES CONSTANTS
# "LR nul aux deux bornes", inchange).
x_cst <- rep(100, length(y))
calcul_cst <- function() run_engine(xt = x_cst, yt = y, methode = "premium", segment = 1,
                                    annexe = "II", nature_donnees = "brutes",
                                    B = B_MIN_USAGE, seed = GRAINE)
r_cst <- avec_injection_161("usp_ajuster_contraint", function(x, y0, delta0, gamma_depart) {
  if (identical(y0, y) && delta0 == 1) stop("panne simulee")
  contraint_orig(x, y0, delta0, gamma_depart)
}, calcul_cst())
verifier("U11 volumes constants, borne delta = 1 en echec sur l'observe : ligne non applicable, INFO, detail = rappel VOLUMES CONSTANTS + MOTIF_LR_DELTA_ECHEC ; ligne delta = 0 au prefixe ordinaire (#161)",
         {
           l <- lignes_lr(r_cst)
           isTRUE(r_cst$ok) && is.na(r_cst$lr_delta$borne1$lr) &&
             l[[2]]$type == "non applicable" && l[[2]]$verdict == "INFO" && is.na(l[[2]]$p_retenue) &&
             identical(l[[2]]$inoperant, FALSE) &&
             identical(l[[2]]$detail,
                       paste("VOLUMES CONSTANTS : delta non identifie, LR nul par construction attendu",
                             "a cette borne mais non calcule.", MOTIF_LR_DELTA_ECHEC)) &&
             l[[1]]$type == "diagnostic" &&
             grepl("VOLUMES CONSTANTS : delta non identifie, LR nul aux deux bornes par construction.",
                   l[[1]]$detail, fixed = TRUE)
         })

# Profil : usp_objectif() en echec quand il est appele sous usp_profil()
# (pile d'appel), partout (toute la grille) ou au seul point delta = 0,5.
sous_profil <- function() any(vapply(sys.calls(), function(cl)
  identical(cl[[1]], as.name("usp_profil")), logical(1)))
panne_profil <- function(par, ...) {
  if (sous_profil()) stop("panne simulee")
  objectif_orig(par, ...)
}
panne_profil_milieu <- function(par, ...) {
  if (sous_profil() && par[1] == 0.5) stop("panne simulee")
  objectif_orig(par, ...)
}
r_pr <- avec_injection_161("usp_objectif", panne_profil, calcul_j2())
verifier("U11 profil en echec partout : ok = TRUE, meme forme, grilles inchangees, objectifs NA ; sigma_USP, tests, LR et bootstrap identiques (#161)",
         isTRUE(r_pr$ok) && identical(names(r_pr$profil), names(r2_ref$profil)) &&
           identical(r_pr$profil$delta_grid, r2_ref$profil$delta_grid) &&
           identical(r_pr$profil$gamma_grid, r2_ref$profil$gamma_grid) &&
           all(is.na(r_pr$profil$delta_obj)) && all(is.na(r_pr$profil$gamma_obj)) &&
           length(r_pr$profil$delta_obj) == length(r2_ref$profil$delta_obj) &&
           identical(r_pr$parametre_final, r2_ref$parametre_final) &&
           identical(r_pr$tests, r2_ref$tests) && identical(r_pr$lr_delta, r2_ref$lr_delta) &&
           identical(r_pr$bootstrap, r2_ref$bootstrap))
verifier("U11 profil en echec partout : plots_data de meme forme, profil_delta et profil_gamma a objectif NA, reste identique (#161)",
         {
           pd <- r_pr$plots_data; pd0 <- r2_ref$plots_data
           hors <- setdiff(names(pd0), c("profil_delta", "profil_gamma"))
           identical(names(pd), names(pd0)) &&
             identical(pd$profil_delta$delta, pd0$profil_delta$delta) &&
             all(is.na(pd$profil_delta$objectif)) && all(is.na(pd$profil_gamma$objectif)) &&
             identical(pd[hors], pd0[hors])
         })
r_pm <- avec_injection_161("usp_objectif", panne_profil_milieu, calcul_j2())
verifier("U11 profil en echec au seul point delta = 0,5 : NA a ce point, autres points et profil en gamma identiques (#161)",
         {
           i <- which(r2_ref$profil$delta_grid == 0.5)
           isTRUE(r_pm$ok) && length(i) == 1L && is.na(r_pm$profil$delta_obj[i]) &&
             identical(r_pm$profil$delta_obj[-i], r2_ref$profil$delta_obj[-i]) &&
             identical(r_pm$profil$gamma_obj, r2_ref$profil$gamma_obj)
         })

# m3 : chemins d'echec du bootstrap restreint. usp_ajuster_contraint() en
# echec un appel sur cinq sur les y* (jamais sur l'observe) : replications
# ecartees de usp_lr_delta() (n_echec) et du bootstrap restreint de
# usp_bootstrap() (n_echec_restreint), le bootstrap principal intact.
compteur_161 <- new.env(); compteur_161$n <- 0L
panne_un_sur_cinq <- function(x, y, delta0, gamma_depart) {
  if (!identical(y, yi)) {
    compteur_161$n <- compteur_161$n + 1L
    if (compteur_161$n %% 5L == 0L) stop("panne simulee")
  }
  contraint_orig(x, y, delta0, gamma_depart)
}
r_m3 <- avec_injection_161("usp_ajuster_contraint", panne_un_sur_cinq, calcul_j2())
verifier("U11 (m3) usp_lr_delta, replications en echec : n_echec > 0, B_effectif = B - n_echec = longueur de lr_boot, p_mc recalculee sur les seules replications retenues (#161)",
         isTRUE(r_m3$ok) &&
           all(vapply(list(r2_ref$lr_delta$borne0, r2_ref$lr_delta$borne1), function(b)
             identical(b$n_echec, 0L), logical(1))) &&
           all(vapply(list(r_m3$lr_delta$borne0, r_m3$lr_delta$borne1), function(b) {
             Be <- length(b$lr_boot)
             b$n_echec > 0L && b$B_effectif == B_MIN_USAGE - b$n_echec && Be == b$B_effectif &&
               isTRUE(proche(b$p_mc, (1 + sum(b$lr_boot >= b$lr)) / (Be + 1))) &&
               is.finite(b$lr)
           }, logical(1))) &&
           all(vapply(lignes_lr(r_m3), function(t) t$type == "diagnostic", logical(1))))
verifier("U11 (m3) usp_bootstrap, reajustement contraint en echec : n_echec_restreint > 0, sigma_boot_restreint raccourci d'autant, bootstrap principal identique (#161)",
         {
           bt <- r_m3$bootstrap; bt0 <- r2_ref$bootstrap
           identical(bt0$n_echec_restreint, 0L) && bt$n_echec_restreint > 0L &&
             length(bt$sigma_boot_restreint) == length(bt$sigma_boot) - bt$n_echec_restreint &&
             identical(bt$sigma_boot, bt0$sigma_boot) && identical(bt$p_mc, bt0$p_mc) &&
             identical(r_m3$parametre_final$sigma_usp, r2_ref$parametre_final$sigma_usp)
         })

fin_fichier()
