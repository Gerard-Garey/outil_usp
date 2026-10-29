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
#  Issue #385 (option (a), decisions du mainteneur du 28/10/2026) : rang k*
#  de la bande simultanee selon l'eq. (4.17) de Davison et Hinkley (1997)
#  (engine_rang_simultane_dh() sur les lignes de S), champs regle_rang et
#  motif de plots_data$qq_enveloppe, cas k* NA (aucun rang admissible) et
#  sous-titre du QQ-plot (.qq_sous_titre(), R/display_helpers.R), qui
#  restitue le motif du moteur.
#  References independantes :
#    - residus reajustes recalcules replication par replication sous la meme
#      graine (usp_simuler(), usp_ajuster_rapide() ou usp_noyau()) ;
#    - quantiles et taux de sortie recalcules a la main a partir de z_boot ;
#    - taux (4.17) recalcule par les rangs "min" et "max" de rank(), sans
#      balayage des bornes ;
#    - valeurs de boot::envelope() 1.3.30 ecrites en dur (k.ov = (7, 993),
#      err.ov[2] = 0,092 et 0,090 sur les references premium et
#      premium_interieur ; provenance : tests/unitaires/generer_valeurs_externes.R),
#      et comparaison directe si le paquet boot est installe.
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
# Taux de sortie de l'eq. (4.17) au rang k, ecriture independante de
# engine_rang_simultane_dh() : une ligne sort au rang k si, dans une colonne,
# son rang "min" est <= k ou son rang "max" est >= B + 1 - k.
taux_417 <- function(S, k) {
  B <- nrow(S)
  rmin <- apply(S, 2, rank, ties.method = "min")
  rmax <- apply(S, 2, rank, ties.method = "max")
  m <- pmin(apply(rmin, 1, min), B + 1 - apply(rmax, 1, max))
  mean(m <= k)
}

# --- (i) z_boot : dimension B x T, lignes retenues, valeurs ---------------
b199 <- usp_bootstrap(f1, B = 199, seed = GRAINE)
# z_boot n'est plus le dernier champ depuis #240 : p_mc_regime le suit.
verifier("(i) usp_bootstrap() : z_boot matrice B x T, apres n_echec_restreint, suivi de p_mc_regime (#240), p_min_mc (#125) et stats_boot (#297)",
         is.matrix(b199$z_boot) && identical(dim(b199$z_boot), c(199L, T1)) &&
           is.double(b199$z_boot) &&
           identical(tail(names(b199), 5),
                     c("n_echec_restreint", "z_boot", "p_mc_regime", "p_min_mc", "stats_boot")))
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
             identical(e$B_eff, 199L) && is.finite(e$taux_global_ponctuel) &&
             identical(e$motif, "moins de 500 replications retenues : bande simultanee non calculee")
         })
verifier("(ii) plots_data$qq_enveloppe : champs, source, B_eff, niveaux fixes, seuil, regle DH1997_4.17 (#385), taux ponctuel recalcule ; suivi de spread_enveloppe (#306) puis des trois champs de #305 en fin de plots_data",
         {
           e <- r1$plots_data$qq_enveloppe
           S <- ordres(r1$bootstrap$z_boot)
           d <- r1$plots_data$qqnorm; o <- order(d$theorique)
           identical(names(e), c("source", "B_eff", "niveau_ponctuel", "niveau_simultane", "k",
                                 "taux_global_ponctuel", "taux_global_simultane",
                                 "B_min_simultane", "regle_rang", "motif")) &&
             identical(e$regle_rang, "DH1997_4.17") &&
             identical(e$source, "bootstrap") && identical(e$B_eff, nrow(S)) &&
             identical(e$niveau_ponctuel, 0.90) && identical(e$niveau_simultane, 0.90) &&
             identical(e$B_min_simultane, ENVELOPPE_QQ_B_MIN_SIM) &&
             isTRUE(all.equal(e$taux_global_ponctuel, taux_sortie(S, d$env_bas[o], d$env_haut[o]),
                              tolerance = 0)) &&
             identical(tail(names(r1$plots_data), 5), c("qq_enveloppe", "spread_enveloppe", "sigma_usp_boot",
                                                       "regime_boot", "boot_reperes")) &&
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
verifier("(ii) B = 999 : taux_global_simultane = taux (4.17) recalcule par les rangs sur les lignes de S au rang k ; motif NA, regle DH1997_4.17",
         {
           e <- r999$plots_data$qq_enveloppe
           S <- ordres(r999$bootstrap$z_boot)
           isTRUE(all.equal(e$taux_global_simultane, taux_417(S, e$k), tolerance = 0)) &&
             identical(e$motif, NA_character_) && identical(e$regle_rang, "DH1997_4.17")
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
verifier("(iii) maximalite de k* (B = 999) selon l'eq. (4.17) : taux (4.17) <= 0,10 a k*, > 0,10 a k* + 1 (recalcul par les rangs) ; k* = 7",
         {
           k <- e999$info$k
           t_k <- taux_417(S999, k); t_k1 <- taux_417(S999, k + 1L)
           identical(k, 7L) && t_k <= 0.10 && t_k1 > 0.10 &&
             isTRUE(all.equal(e999$info$taux_global_simultane, t_k, tolerance = 0)) &&
             identical(unname(e999$bandes[, "sim_bas"]), Sc999[k, ]) &&
             identical(unname(e999$bandes[, "sim_haut"]), Sc999[n999 + 1L - k, ])
         })
verifier("(iii) k* = celui de engine_rang_simultane_dh() sur les lignes de S (bornes identical())",
         {
           r <- engine_rang_simultane_dh(S999)
           identical(e999$info$k, r$k) && identical(e999$info$taux_global_simultane, r$taux) &&
             identical(unname(e999$bandes[, "sim_bas"]), r$sim_bas) &&
             identical(unname(e999$bandes[, "sim_haut"]), r$sim_haut)
         })
verifier("(iii) regle anterieure a #385 (sortie stricte de la bande de toutes les lignes) : elle admettait k* + 1, au taux (4.17) de k* (aucun ex aequo dans S)",
         {
           k <- e999$info$k
           t_strict <- function(kk) taux_sortie(S999, Sc999[kk, ], Sc999[n999 + 1L - kk, ])
           !any(apply(S999, 2, anyDuplicated) > 0L) &&
             t_strict(k + 1L) <= 0.10 && t_strict(k + 2L) > 0.10 &&
             identical(t_strict(k + 1L), taux_417(S999, k)) &&
             t_strict(1L) == 0 && taux_417(S999, 1L) > 0
         })
# Cas k* NA (#385, T >= 26, B_eff = 500) : S construite, colonne j =
# 1000 j + rang, rangs decales circulairement d'une colonne a l'autre
# (rang ((i - (2j - 1)) mod 500) + 1 a la ligne i) : le minimum de la
# colonne j est a la ligne 2j - 1, son maximum a la ligne 2j - 2 (500 pour
# j = 1), toutes distinctes. A k = 1, 2T lignes sortent : 52/500 > 0,10 a
# T = 26 (k* NA), 50/500 = 0,10 a T = 25 (k = 1 admissible). Les lignes de
# z_boot sont passees en ordre decroissant : engine_enveloppe_qq() les trie.
S_construite <- function(T, B = 500L)
  vapply(seq_len(T), function(j) 1000 * j + ((seq_len(B) - (2L * j - 1L)) %% B) + 1, numeric(B))
verifier("(iii) k* NA atteignable (#385) : T = 26, B_eff = 500, 52 lignes sortent a k = 1 -> bornes simultanees NA, k et taux NA, bande ponctuelle finie, motif 'aucun rang k admissible' ; T = 25 : k* = 1, taux 0,10",
         {
           S26 <- S_construite(26L); S25 <- S_construite(25L)
           e26 <- engine_enveloppe_qq(S26[, 26:1], 26L); e25 <- engine_enveloppe_qq(S25[, 25:1], 25L)
           identical(taux_417(S26, 1L), 52 / 500) && identical(taux_417(S25, 1L), 0.10) &&
             identical(e26$info$B_eff, 500L) && identical(e26$info$k, NA_integer_) &&
             identical(e26$info$taux_global_simultane, NA_real_) &&
             all(is.na(e26$bandes[, c("sim_bas", "sim_haut")])) &&
             all(is.finite(e26$bandes[, c("bas", "haut")])) &&
             is.finite(e26$info$taux_global_ponctuel) &&
             identical(e26$info$motif,
                       paste("aucun rang k admissible : taux de sortie (4.17) superieur a 0,10",
                             "au rang k = 1 ; bande simultanee non disponible")) &&
             identical(e26$info$regle_rang, "DH1997_4.17") &&
             identical(e25$info$k, 1L) && identical(e25$info$taux_global_simultane, 0.10) &&
             identical(e25$info$motif, NA_character_) &&
             identical(unname(e25$bandes[, "sim_bas"]), apply(S25, 2, min)) &&
             identical(unname(e25$bandes[, "sim_haut"]), apply(S25, 2, max))
         })
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
             is.na(e$taux_global_ponctuel) && is.na(e$taux_global_simultane) &&
             identical(e$motif, "moins de 20 replications retenues : enveloppe non disponible")
         })
verifier("(v) B = 60 (20 <= B_eff < 500) : bande ponctuelle finie, simultanee NA, k NA",
         {
           d <- pd60$qqnorm; e <- pd60$qq_enveloppe
           all(is.finite(d$env_bas)) && all(is.finite(d$env_haut)) &&
             all(is.na(d$env_sim_bas)) && all(is.na(d$env_sim_haut)) &&
             identical(e$B_eff, 60L) && identical(e$k, NA_integer_) &&
             is.finite(e$taux_global_ponctuel) && is.na(e$taux_global_simultane) &&
             identical(e$motif, "moins de 500 replications retenues : bande simultanee non calculee")
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

# --- Concordance avec boot::envelope() (#385) ----------------------------------
# Valeurs de boot::envelope(mat = S, level = c(0.90, 0.90)) ecrites en dur
# (boot 1.3.30, R 4.3.3, 29/10/2026 ; tests/unitaires/generer_valeurs_externes.R),
# S = statistiques d'ordre de bootstrap$z_boot des references premium et
# premium_interieur (B_eff = 999) : k.ov = (7, 993), err.ov[2] = 0,092 et
# 0,090, taux rapporte a B_eff + 1 (taux du moteur = err.ov[2] (B_eff + 1) /
# B_eff). Le bootstrap des references n'est pas touche par #385.
.racine385 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."
BOOT_ENVELOPE <- list(premium = list(k_ov = c(7, 993), err_ov2 = 0.092),
                      premium_interieur = list(k_ov = c(7, 993), err_ov2 = 0.090))
for (cas in names(BOOT_ENVELOPE)) {
  zb_ref <- readRDS(file.path(.racine385, "tests", "reference", paste0(cas, ".rds")))$bootstrap$z_boot
  e_ref <- engine_enveloppe_qq(zb_ref, ncol(zb_ref)); n_ref <- e_ref$info$B_eff
  v <- BOOT_ENVELOPE[[cas]]
  verifier(sprintf("boot::envelope() en dur (%s, B_eff = 999) : k = k.ov[1] = 7, B_eff + 1 - k = k.ov[2] = 993, taux = err.ov[2] x (B_eff + 1) / B_eff",
                   cas),
           identical(n_ref, 999L) && identical(e_ref$info$k, as.integer(v$k_ov[1])) &&
             identical(n_ref + 1L - e_ref$info$k, as.integer(v$k_ov[2])) &&
             isTRUE(all.equal(e_ref$info$taux_global_simultane, v$err_ov2 * (n_ref + 1) / n_ref,
                              tolerance = 1e-12)))
  if (requireNamespace("boot", quietly = TRUE))
    verifier(sprintf("boot::envelope() installe (%s) : k.ov, bornes $overall (sim_haut, sim_bas) identical() et err.ov[2] x (B_eff + 1) / B_eff",
                     cas),
             {
               ev <- boot::envelope(mat = ordres(zb_ref), level = c(0.90, 0.90))
               identical(as.integer(ev$k.ov), c(e_ref$info$k, n_ref + 1L - e_ref$info$k)) &&
                 identical(unname(ev$overall[1, ]), unname(e_ref$bandes[, "sim_haut"])) &&
                 identical(unname(ev$overall[2, ]), unname(e_ref$bandes[, "sim_bas"])) &&
                 isTRUE(all.equal(ev$err.ov[2] * (n_ref + 1) / n_ref, e_ref$info$taux_global_simultane,
                                  tolerance = 1e-12))
             })
}
if (!requireNamespace("boot", quietly = TRUE))
  cat("  note : paquet boot absent ; comparaison directe a boot::envelope() non exercee.\n")

# --- Sous-titre du QQ-plot : motif du moteur (#385) -----------------------------
# .qq_sous_titre() (R/display_helpers.R) rend un vecteur de une ou deux
# lignes, sur le modele de .spread_sous_titre() : bandes tracees, puis le
# motif du moteur seul, tel quel, en seconde ligne, sans cause reconstruite ;
# objet sans motif (anterieur a #385) : une ligne, aucune cause ecrite.
# plot_qqnorm() trace une ligne par element (mtext() en base R, <sup> par
# ligne en plotly, marge haute de 80 px a deux lignes).
source(file.path(.racine385, "R", "display_helpers.R"), local = TRUE)
ST0 <- "bootstrap param\u00e9trique sous le mod\u00e8le ajust\u00e9, "
PONCT199 <- paste0(ST0, "bande ponctuelle seule sur 199 r\u00e9plications, bande simultan\u00e9e indisponible")
MOTIF500 <- "moins de 500 replications retenues : bande simultanee non calculee"
MOTIF_K <- paste("aucun rang k admissible : taux de sortie (4.17) superieur a 0,10",
                 "au rang k = 1 ; bande simultanee non disponible")
e26_st <- engine_enveloppe_qq(S_construite(26L), 26L)
pd26 <- r1$plots_data
pd26$qq_enveloppe <- e26_st$info
pd26$qqnorm <- data.frame(theorique = stats::qnorm(stats::ppoints(26L)), empirique = sort(S_construite(26L)[1, ] / 1000),
                          env_bas = e26_st$bandes[, "bas"] / 1000, env_haut = e26_st$bandes[, "haut"] / 1000,
                          env_sim_bas = e26_st$bandes[, "sim_bas"], env_sim_haut = e26_st$bandes[, "sim_haut"])
verifier("Sous-titre QQ, B = 999 : une ligne, bandes ponctuelle et simultanee, rang k = 7, sans motif",
         identical(.qq_sous_titre(r999$plots_data),
                   paste0(ST0, "bande ponctuelle et bande simultan\u00e9e (rang k = 7 sur 999 r\u00e9plications)")))
verifier("Sous-titre QQ, B = 199 : deux lignes, bande ponctuelle seule puis motif du moteur (seuil de 500) ; plus de '(B_eff < 500)' reconstruit",
         {
           st <- .qq_sous_titre(r1$plots_data)
           identical(st, c(PONCT199, MOTIF500)) && !any(grepl("B_eff <", st, fixed = TRUE))
         })
verifier("Sous-titre QQ, B = 10 : deux lignes, enveloppe indisponible puis motif du seuil de 20",
         identical(.qq_sous_titre(pd10),
                   c(paste0(ST0, "enveloppe indisponible (10 r\u00e9plications)"),
                     "moins de 20 replications retenues : enveloppe non disponible")))
verifier("Sous-titre QQ, k* NA a B_eff = 500 (T = 26, S construite) : deux lignes, bande ponctuelle seule puis motif 'aucun rang k admissible', aucun '(B_eff < 500)'",
         {
           st <- .qq_sous_titre(pd26)
           identical(st, c(paste0(ST0, "bande ponctuelle seule sur 500 r\u00e9plications, bande simultan\u00e9e indisponible"),
                           MOTIF_K)) && !any(grepl("B_eff <", st, fixed = TRUE))
         })
verifier("Sous-titre QQ, objet anterieur a #385 (qq_enveloppe sans motif ni regle_rang, B = 199) : une ligne, aucune cause ecrite ; sans qq_enveloppe : aucune ligne",
         {
           pd <- r1$plots_data; pd$qq_enveloppe$motif <- NULL; pd$qq_enveloppe$regle_rang <- NULL
           pd0 <- r1$plots_data; pd0$qq_enveloppe <- NULL
           identical(.qq_sous_titre(pd), PONCT199) && identical(.qq_sous_titre(pd0), character(0))
         })
# Rendu base R (pdf(NULL)) : textes de mtext() releves dans l'ordre d'appel,
# avec leur argument line (une ligne par element, la derniere au ras du cadre).
releve_mtext385 <- function(pd) {
  r <- new.env(); r$mt <- list(); ns <- asNamespace("graphics")
  suppressMessages(trace("mtext", tracer = bquote(assign("mt", c(get("mt", envir = .(r)),
                                                     list(list(text = text, line = line))), envir = .(r))),
                         where = ns, print = FALSE))
  on.exit(suppressMessages(untrace("mtext", where = ns)))
  option <- options(usp.graphiques_base = TRUE); grDevices::pdf(NULL)
  on.exit({ grDevices::dev.off(); options(option) }, add = TRUE)
  suppressWarnings(plot_qqnorm(pd))
  r$mt
}
verifier("plot_qqnorm(), base R : B = 199 et k* NA, sous-titre sur deux lignes (bandes tracees en ligne 0,9, motif en ligne 0,15) ; B = 999, une ligne en 0,15",
         {
           m199 <- releve_mtext385(r1$plots_data); m26 <- releve_mtext385(pd26); m999 <- releve_mtext385(r999$plots_data)
           length(m199) == 1L && identical(m199[[1]]$text, c(PONCT199, MOTIF500)) &&
             isTRUE(all.equal(m199[[1]]$line, c(0.9, 0.15))) &&
             length(m26) == 1L && identical(m26[[1]]$text[2], MOTIF_K) &&
             length(m999) == 1L && length(m999[[1]]$text) == 1L && isTRUE(all.equal(m999[[1]]$line, 0.15))
         })
if (requireNamespace("plotly", quietly = TRUE)) {
  construit385 <- function(pd) {
    op <- options(usp.graphiques_base = FALSE); on.exit(options(op))
    plotly::plotly_build(plot_qqnorm(pd))$x$layout
  }
  verifier("plot_qqnorm(), plotly : B = 199, titre suivi de deux <sup> (bandes tracees, motif) et marge haute de 80 ; B = 999, un <sup> et marge de 60",
           {
             l199 <- construit385(r1$plots_data); l999 <- construit385(r999$plots_data)
             t199 <- if (is.list(l199$title)) l199$title$text else l199$title
             t999 <- if (is.list(l999$title)) l999$title$text else l999$title
             endsWith(t199, paste0("<br><sup>", PONCT199, "</sup><br><sup>", MOTIF500, "</sup>")) &&
               identical(l199$margin$t, 80) &&
               lengths(regmatches(t999, gregexpr("<sup>", t999, fixed = TRUE))) == 1L &&
               identical(l999$margin$t, 60)
           })
} else cat("  note : plotly absent ; sous-titre plotly du QQ-plot non exerce (#385).\n")

# --- (vi) graine de l'enveloppe retiree ---------------------------------------
r_res1 <- run_engine(xt = x, yt = y, methode = "reserve1", segment = 1, annexe = "II",
                     B = B_MIN_USAGE, seed = GRAINE)
verifier("(vi) SEED_ENVELOPPE_QQ absent du moteur ; metadata sans seed_enveloppe_qq ni seed_loi_nulle_sw (#351) (premium, reserve1)",
         !exists("SEED_ENVELOPPE_QQ") &&
           !"seed_enveloppe_qq" %in% names(r1$metadata) &&
           !"seed_enveloppe_qq" %in% names(r_res1$metadata) &&
           !"seed_loi_nulle_sw" %in% names(r1$metadata) &&
           !"seed_loi_nulle_sw" %in% names(r_res1$metadata))
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
