###############################################################################
#  tests/unitaires/test_enveloppe_qq.R  --  ENVELOPPE DU QQ-PLOT SOUS LE
#  MODELE AJUSTE (issue #47, note d'actuary du 28/09/2026, par. 2 et 4,
#  tests (i) a (vii) ; decisions du mainteneur du 28/09/2026 : option A,
#  deux bandes, niveau fixe de 90 %)
#
#  Champ z_boot de usp_bootstrap(), engine_enveloppe_qq(), colonnes env_bas,
#  env_haut, env_sim_bas, env_sim_haut de plots_data$qqnorm et champ
#  plots_data$qq_enveloppe de engine_plots_data(), retrait de
#  SEED_ENVELOPPE_QQ et de metadata$seed_enveloppe_qq.
#  References independantes :
#    - residus reajustes recalcules replication par replication sous la meme
#      graine (usp_simuler(), usp_ajuster_rapide() ou usp_noyau()) ;
#    - quantiles et taux de sortie recalcules a la main a partir de z_boot.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_enveloppe_qq.R")

# J1 : jeu de test du depot (tests/donnees/donnees_ln.csv)
x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
GRAINE <- 20260831
f1 <- usp_ajuster(x, y); T1 <- length(x)
prof1 <- usp_profil(f1)

# Statistiques d'ordre des lignes entierement finies, et taux de sortie
# stricte d'une bande (recalcul independant de engine_enveloppe_qq()).
ordres <- function(zb) t(apply(zb[apply(is.finite(zb), 1, all), , drop = FALSE], 1, sort))
taux_sortie <- function(S, bas, haut) {
  hors <- vapply(seq_len(nrow(S)), function(i) any(S[i, ] < bas | S[i, ] > haut), logical(1))
  mean(hors)
}

# --- (i) z_boot : dimension B x T, lignes retenues, valeurs ---------------
b199 <- usp_bootstrap(f1, B = 199, seed = GRAINE)
verifier("(i) usp_bootstrap() : z_boot matrice B x T, dernier champ, apres n_echec_restreint",
         is.matrix(b199$z_boot) && identical(dim(b199$z_boot), c(199L, T1)) &&
           is.double(b199$z_boot) &&
           identical(tail(names(b199), 2), c("n_echec_restreint", "z_boot")))
verifier("(i) z_boot : lignes finies en nombre egal au B effectif de AD (statistique toujours finie)",
         sum(apply(is.finite(b199$z_boot), 1, all)) == b199$B_effectif[["AD"]] &&
           all(apply(is.finite(b199$z_boot), 1, all) | apply(is.na(b199$z_boot), 1, all)))
verifier("(i) z_boot : lignes 1 a 5 = residus reajustes recalcules sous la meme graine (usp_ajuster_rapide())",
         {
           z_ref <- engine_sous_graine(GRAINE, t(vapply(1:5, function(b) {
             yb <- usp_simuler(f1)
             usp_ajuster_rapide(x, yb, f1$delta, f1$gamma)$z
           }, numeric(T1))))
           identical(b199$z_boot[1:5, ], z_ref)
         })
verifier("(i) refit = FALSE : lignes de z_boot = residus de usp_noyau() aux parametres ajustes",
         {
           b_nr <- usp_bootstrap(f1, B = 20, seed = GRAINE, refit = FALSE)
           z_ref <- engine_sous_graine(GRAINE, t(vapply(1:20, function(b) {
             yb <- usp_simuler(f1)
             usp_noyau(f1$delta, f1$gamma, x, yb, f1$xbar)$z
           }, numeric(T1))))
           identical(dim(b_nr$z_boot), c(20L, T1)) && identical(b_nr$z_boot, z_ref)
         })
verifier("(i) echec reel du reajustement de la replication 3 (usp_ajuster_rapide() remplace localement) : ligne 3 de z_boot NA, autres identiques au bootstrap ordinaire, B_eff = B - 1",
         {
           # Copie locale de usp_bootstrap() dont l'environnement masque
           # usp_ajuster_rapide() par une version qui echoue au 3e appel ;
           # le moteur n'est pas modifie. L'echec intervient apres
           # usp_simuler() : les tirages des autres replications sont les memes.
           env_echec <- new.env(parent = environment(usp_bootstrap))
           env_echec$n_appels <- 0L
           env_echec$usp_ajuster_rapide <- function(...) {
             env_echec$n_appels <- env_echec$n_appels + 1L
             if (env_echec$n_appels == 3L) stop("echec simule")
             get("usp_ajuster_rapide", envir = environment(usp_bootstrap))(...)
           }
           boot_echec <- usp_bootstrap; environment(boot_echec) <- env_echec
           b_e <- boot_echec(f1, B = 30, seed = GRAINE)
           b_o <- usp_bootstrap(f1, B = 30, seed = GRAINE)
           e <- engine_enveloppe_qq(b_e$z_boot, T1)
           env_echec$n_appels == 30L &&
             all(is.na(b_e$z_boot[3, ])) && all(is.finite(b_e$z_boot[-3, ])) &&
             identical(b_e$z_boot[-3, ], b_o$z_boot[-3, ]) &&
             identical(e$info$B_eff, 29L)
         })
verifier("(i) engine_enveloppe_qq() : lignes NA ecartees du B effectif et des bandes",
         {
           zb <- b199$z_boot; zb[c(3, 50, 120), ] <- NA
           e <- engine_enveloppe_qq(zb, T1)
           S <- ordres(zb)
           q <- apply(S, 2, stats::quantile, probs = c(0.05, 0.95), type = 7, names = FALSE)
           e$info$B_eff == 196L && nrow(S) == 196L &&
             identical(unname(e$bandes[, "bas"]), q[1, ]) && identical(unname(e$bandes[, "haut"]), q[2, ])
         })

# --- (ii) enveloppe recalculable depuis res$bootstrap$z_boot --------------
r1 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                 B = 199, seed = GRAINE, nature_donnees = "brutes")
verifier("(ii) env_bas / env_haut = quantiles 5 % et 95 % (type 7) des colonnes triees de z_boot, apres order(order(theorique))",
         {
           S <- ordres(r1$bootstrap$z_boot)
           q <- apply(S, 2, stats::quantile, probs = c(0.05, 0.95), type = 7, names = FALSE)
           d <- r1$plots_data$qqnorm; o <- order(order(d$theorique))
           identical(d$env_bas, q[1, o]) && identical(d$env_haut, q[2, o])
         })
verifier("(ii) B = 199 (B_eff < ENVELOPPE_QQ_B_MIN_SIM = 500) : env_sim_bas / env_sim_haut NA, k NA, taux simultane NA",
         {
           d <- r1$plots_data$qqnorm; e <- r1$plots_data$qq_enveloppe
           identical(ENVELOPPE_QQ_B_MIN_SIM, 500L) &&
             all(is.na(d$env_sim_bas)) && all(is.na(d$env_sim_haut)) &&
             identical(e$k, NA_integer_) && is.na(e$taux_global_simultane) &&
             identical(e$B_eff, 199L) && is.finite(e$taux_global_ponctuel)
         })
verifier("(ii) plots_data$qq_enveloppe : champs, source, B_eff, niveaux fixes, seuil, taux ponctuel recalcule ; dernier champ de plots_data",
         {
           e <- r1$plots_data$qq_enveloppe
           S <- ordres(r1$bootstrap$z_boot)
           d <- r1$plots_data$qqnorm; o <- order(d$theorique)
           identical(names(e), c("source", "B_eff", "niveau_ponctuel", "niveau_simultane", "k",
                                 "taux_global_ponctuel", "taux_global_simultane",
                                 "B_min_simultane")) &&
             identical(e$source, "bootstrap") && identical(e$B_eff, nrow(S)) &&
             identical(e$niveau_ponctuel, 0.90) && identical(e$niveau_simultane, 0.90) &&
             identical(e$B_min_simultane, ENVELOPPE_QQ_B_MIN_SIM) &&
             isTRUE(all.equal(e$taux_global_ponctuel, taux_sortie(S, d$env_bas[o], d$env_haut[o]),
                              tolerance = 0)) &&
             identical(tail(names(r1$plots_data), 1), "qq_enveloppe") &&
             identical(names(d), c("theorique", "empirique", "env_bas", "env_haut",
                                   "env_sim_bas", "env_sim_haut"))
         })
# Bande simultanee : run_engine() a B = 999 (B_eff >= 500).
r999 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                   B = 999, seed = GRAINE, nature_donnees = "brutes")
verifier("(ii) B = 999 : env_sim_bas / env_sim_haut = k*-iemes plus petite et plus grande valeurs de chaque colonne, apres order(order(theorique))",
         {
           S <- ordres(r999$bootstrap$z_boot); Sc <- apply(S, 2, sort)
           k <- r999$plots_data$qq_enveloppe$k; n <- nrow(S)
           d <- r999$plots_data$qqnorm; o <- order(order(d$theorique))
           is.integer(k) && k >= 1L && n >= ENVELOPPE_QQ_B_MIN_SIM &&
             identical(d$env_sim_bas, Sc[k, o]) && identical(d$env_sim_haut, Sc[n + 1L - k, o])
         })
verifier("(ii) B = 999 : taux_global_simultane recalcule sur les lignes de S a la bande de rang k",
         {
           e <- r999$plots_data$qq_enveloppe
           S <- ordres(r999$bootstrap$z_boot); Sc <- apply(S, 2, sort)
           isTRUE(all.equal(e$taux_global_simultane,
                            taux_sortie(S, Sc[e$k, ], Sc[nrow(S) + 1L - e$k, ]), tolerance = 0))
         })
verifier("(ii) niveau fixe : alpha = 0,05 ne change ni les bandes ni qq_enveloppe",
         {
           r1a <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                             B = 199, seed = GRAINE, nature_donnees = "brutes", alpha = 0.05)
           identical(r1a$plots_data$qqnorm, r1$plots_data$qqnorm) &&
             identical(r1a$plots_data$qq_enveloppe, r1$plots_data$qq_enveloppe)
         })

# --- (iii) et (iv) : maximalite de k* et emboitement, B = 999 -------------
b999 <- r999$bootstrap
e999 <- engine_enveloppe_qq(b999$z_boot, T1)
S999 <- ordres(b999$z_boot); Sc999 <- apply(S999, 2, sort); n999 <- nrow(S999)
verifier("(iii) maximalite de k* (B = 999) : taux global <= 0,10 a k*, > 0,10 a k* + 1",
         {
           k <- e999$info$k
           t_k <- taux_sortie(S999, Sc999[k, ], Sc999[n999 + 1L - k, ])
           t_k1 <- taux_sortie(S999, Sc999[k + 1L, ], Sc999[n999 - k, ])
           is.integer(k) && t_k <= 0.10 && t_k1 > 0.10 &&
             isTRUE(all.equal(e999$info$taux_global_simultane, t_k, tolerance = 0))
         })
verifier("(iii) k = 1 toujours admissible : aucune ligne strictement hors de [min, max] de sa colonne",
         taux_sortie(S999, Sc999[1, ], Sc999[n999, ]) == 0)
verifier("(iv) emboitement env_sim_bas <= env_bas <= env_haut <= env_sim_haut quand 2 k* < 0,05 (B_eff + 1)",
         {
           k <- e999$info$k; b <- e999$bandes
           2 * k < 0.05 * (e999$info$B_eff + 1) &&
             all(b[, "sim_bas"] <= b[, "bas"]) && all(b[, "bas"] <= b[, "haut"]) &&
             all(b[, "haut"] <= b[, "sim_haut"])
         })

# --- (v) degenerescence -----------------------------------------------------
# run_engine() refuse B < B_MIN_USAGE : appel direct de engine_plots_data().
pd10 <- engine_plots_data(f1, usp_bootstrap(f1, B = 10, seed = GRAINE), prof1)
pd60 <- engine_plots_data(f1, usp_bootstrap(f1, B = 60, seed = GRAINE), prof1)
verifier("(v) B = 10 (B_eff < 20) : quatre colonnes NA, k NA, taux NA",
         {
           d <- pd10$qqnorm; e <- pd10$qq_enveloppe
           all(is.na(d$env_bas)) && all(is.na(d$env_haut)) &&
             all(is.na(d$env_sim_bas)) && all(is.na(d$env_sim_haut)) &&
             identical(e$B_eff, 10L) && identical(e$k, NA_integer_) &&
             is.na(e$taux_global_ponctuel) && is.na(e$taux_global_simultane)
         })
verifier("(v) B = 60 (20 <= B_eff < 500) : bande ponctuelle finie, simultanee NA, k NA",
         {
           d <- pd60$qqnorm; e <- pd60$qq_enveloppe
           all(is.finite(d$env_bas)) && all(is.finite(d$env_haut)) &&
             all(is.na(d$env_sim_bas)) && all(is.na(d$env_sim_haut)) &&
             identical(e$B_eff, 60L) && identical(e$k, NA_integer_) &&
             is.finite(e$taux_global_ponctuel) && is.na(e$taux_global_simultane)
         })
verifier("(v) B = 199 (20 <= B_eff < 500) : bande ponctuelle finie, simultanee NA, k NA",
         {
           pd199 <- engine_plots_data(f1, b199, prof1)
           d <- pd199$qqnorm; e <- pd199$qq_enveloppe
           all(is.finite(d$env_bas)) && all(is.finite(d$env_haut)) &&
             all(is.na(d$env_sim_bas)) && all(is.na(d$env_sim_haut)) &&
             identical(e$B_eff, 199L) && identical(e$k, NA_integer_) &&
             is.finite(e$taux_global_ponctuel) && is.na(e$taux_global_simultane)
         })
verifier("(v) seuil de la bande simultanee : B_eff = 499 -> sim NA, k NA ; B_eff = 500 -> sim finie, k entier (appel direct sur les lignes de z_boot a B = 999)",
         {
           e499 <- engine_enveloppe_qq(b999$z_boot[1:499, ], T1)
           e500 <- engine_enveloppe_qq(b999$z_boot[1:500, ], T1)
           e499$info$B_eff == 499L && all(is.na(e499$bandes[, c("sim_bas", "sim_haut")])) &&
             identical(e499$info$k, NA_integer_) && all(is.finite(e499$bandes[, c("bas", "haut")])) &&
             e500$info$B_eff == 500L && all(is.finite(e500$bandes[, c("sim_bas", "sim_haut")])) &&
             is.integer(e500$info$k) && e500$info$k >= 1L
         })
verifier("(v) z_boot absent (objet bootstrap sans le champ) : quatre colonnes NA, B_eff = 0",
         {
           b <- usp_bootstrap(f1, B = 10, seed = GRAINE); b$z_boot <- NULL
           pd <- engine_plots_data(f1, b, prof1)
           all(is.na(unlist(pd$qqnorm[c("env_bas", "env_haut", "env_sim_bas", "env_sim_haut")]))) &&
             identical(pd$qq_enveloppe$B_eff, 0L)
         })

# --- (vi) graine de l'enveloppe retiree ---------------------------------------
r_res1 <- run_engine(xt = x, yt = y, methode = "reserve1", segment = 1, annexe = "II",
                     B = B_MIN_USAGE, seed = GRAINE)
verifier("(vi) SEED_ENVELOPPE_QQ absent du moteur ; metadata sans seed_enveloppe_qq (premium, reserve1)",
         !exists("SEED_ENVELOPPE_QQ") &&
           !"seed_enveloppe_qq" %in% names(r1$metadata) &&
           !"seed_enveloppe_qq" %in% names(r_res1$metadata) &&
           identical(r1$metadata$seed_loi_nulle_sw, SEED_LOI_NULLE_SW))
verifier("(vi) engine_plots_data() ne tire plus : n'appelle pas engine_sous_graine() et laisse .Random.seed intact",
         {
           set.seed(11); avant <- .Random.seed
           engine_plots_data(f1, b199, prof1)
           !any(grepl("engine_sous_graine", deparse(body(engine_plots_data)), fixed = TRUE)) &&
             identical(.Random.seed, avant)
         })

# --- (vii) reproductibilite -------------------------------------------------
verifier("(vii) deux appels a graine egale : enveloppes, qq_enveloppe et z_boot identiques ; autre graine : enveloppe differente",
         {
           r2 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                            B = 199, seed = GRAINE, nature_donnees = "brutes")
           r3 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                            B = 199, seed = GRAINE + 1, nature_donnees = "brutes")
           identical(r2$plots_data$qqnorm, r1$plots_data$qqnorm) &&
             identical(r2$plots_data$qq_enveloppe, r1$plots_data$qq_enveloppe) &&
             identical(r2$bootstrap$z_boot, r1$bootstrap$z_boot) &&
             !identical(r3$plots_data$qqnorm$env_bas, r1$plots_data$qqnorm$env_bas)
         })

fin_fichier()
