###############################################################################
#  tests/unitaires/test_controles_numeriques.R  --  CONTROLES NUMERIQUES DE
#  L'ESTIMATION LOGNORMALE (issue #22, decision M11)
#
#  usp_gradient(), usp_gradient_optim(), usp_hessienne(),
#  usp_grad_ln_sigma(), usp_hessienne_libre(), usp_pas_newton_borne(),
#  usp_condition_premier_ordre(), usp_kkt_satisfaite(),
#  usp_controles_numeriques(), champs d'ajustement de usp_ajuster()
#  (dont kkt_au_moins_un, regle "au moins un demarrage a l'optimum
#  satisfait KKT", decision du mainteneur du 24/09/2026) et place des deux
#  controles dans
#  res$controles (famille "H.") hors de la table des tests.
#  References :
#    - differentiation numerique centree de l'objectif usp_noyau()$obj,
#      independante de l'expression analytique du gradient ;
#    - reduction exacte a pi_t constant : g_gamma = w (somme(z_t^2) - T),
#      w = -pi 2 e a / (1 + e a) commun a toutes les annees (somme(z_t) = 0
#      par la forme fermee de ln(beta)) ;
#    - conditions de Kuhn-Tucker d'un minimum sous contrainte de bornes ;
#    - ajustement deliberement non converge (factr = 1e13, maxit = 2) ;
#    - issue #71 (specification d'actuary du 28/09/2026, section 6) :
#      hessienne par differences centrees ecrites a la main, gradient de
#      ln(sigma) contre la difference centree de ln(usp_noyau()$sigma),
#      reduction a pi_t constant, pas de Newton complet ecrete calcule a la
#      main sur entrees synthetiques (minimiseur d'un modele quadratique
#      convexe sur la bande [0, 1] x R).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_controles_numeriques.R")

# Jeu de test du depot (delta estime au bord 1) et jeu simule a delta interieur
x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
xi <- c(50, 80, 120, 200, 300, 150, 90, 60)
yi <- c(29.92, 56.9, 101.25, 123.06, 207.23, 105.91, 68.59, 40.05)

NOM_FOC   <- "Condition du premier ordre (gradient projete, KKT)"
NOM_MULTI <- "Convergence multi-demarrages"
FAM_H     <- "H. Controles numeriques de l'estimation"
ctrl <- function(fit, nom) {
  cc <- usp_controles_numeriques(fit)
  cc[[which(vapply(cc, function(u) u$test, character(1)) == nom)]]
}

## --- Gradient analytique contre difference centree -------------------------
verifier("usp_gradient = difference centree de l'objectif (16 points, deux jeux, ecart relatif < 1e-6)",
         {
           h <- 1e-5; em <- 0
           for (dat in list(list(x, y), list(xi, yi)))
             for (d in c(0.1, 0.37, 0.5, 0.9)) for (g in c(-4, -2, -1, 0.5)) {
               o <- function(dd, gg) usp_noyau(dd, gg, dat[[1]], dat[[2]])$obj
               num <- c((o(d + h, g) - o(d - h, g)) / (2 * h),
                        (o(d, g + h) - o(d, g - h)) / (2 * h))
               an <- usp_gradient(d, g, dat[[1]], dat[[2]])
               em <- max(em, abs(an - num) / pmax(1, abs(num)))
             }
           if (em < 1e-6) TRUE else sprintf("ecart relatif max %.3e", em)
         })
verifier("usp_gradient : composantes nommees delta et gamma",
         identical(names(usp_gradient(0.5, -2, xi, yi)), c("delta", "gamma")))

## --- Reduction a pi_t constant ---------------------------------------------
verifier("usp_gradient : a pi_t constant (delta = 1, puis x constant), g_gamma = w (somme(z^2) - T) et g_delta nul a x constant",
         {
           ok <- TRUE
           for (cas in list(list(d = 1, xx = x, yy = y), list(d = 0.37, xx = rep(100, 8), yy = y))) {
             for (g in c(-3, -1.9, -1)) {
               k <- usp_noyau(cas$d, g, cas$xx, cas$yy)
               e <- exp(2 * g); a <- cas$d + (1 - cas$d) * mean(cas$xx) / cas$xx
               w <- unique(signif(-k$pi * 2 * e * a / (1 + e * a), 12))
               gr <- usp_gradient(cas$d, g, cas$xx, cas$yy)
               ok <- ok && length(w) == 1L &&
                 isTRUE(proche(gr[["gamma"]], w * (sum(k$z^2) - length(cas$xx)), rel = 1e-10, abs = 1e-12))
             }
           }
           ok && usp_gradient(0.37, -2, rep(100, 8), y)[["delta"]] == 0
         })

## --- Champs d'ajustement ---------------------------------------------------
f_t <- usp_ajuster(x, y); f_i <- usp_ajuster(xi, yi)
CH_71 <- c("hessienne", "grad_ln_sigma", "pas_newton", "erreur_sigma", "pas_ecrete")
verifier("usp_ajuster : champs de la condition du premier ordre (#71) et du multi-demarrages, sans 'foc', 'hessien_gamma' ni 'pas_newton_gamma'",
         {
           ch <- c("gradient", "gradient_projete", CH_71, "n_starts_optimum", "n_starts_echec")
           all(ch %in% names(f_t)) &&
             !any(c("foc", "hessien_gamma", "pas_newton_gamma") %in% names(f_t)) &&
             length(f_t$gradient) == 2L && length(f_t$gradient_projete) == 2L &&
             identical(dim(f_t$hessienne), c(2L, 2L)) &&
             identical(dimnames(f_t$hessienne), list(c("delta", "gamma"), c("delta", "gamma"))) &&
             identical(names(f_t$grad_ln_sigma), c("delta", "gamma")) &&
             identical(names(f_t$pas_newton), c("delta", "gamma")) &&
             is.double(f_t$erreur_sigma) && length(f_t$erreur_sigma) == 1L &&
             is.logical(f_t$pas_ecrete) && length(f_t$pas_ecrete) == 1L
         })
verifier("usp_ajuster : champs = usp_condition_premier_ordre() au point estime",
         {
           cpo <- usp_condition_premier_ordre(f_i$delta, f_i$gamma, xi, yi)
           all(vapply(c("gradient", "gradient_projete", CH_71),
                      function(ch) identical(cpo[[ch]], f_i[[ch]]), logical(1)))
         })
# Specification d'actuary (#71, section 6, point 1) : differences centrees
# ecrites a la main (h = 1e-4), H_gamma_gamma identique a l'ancienne formule
# de hessien_gamma, symetrie exacte.
verifier("usp_hessienne = differences centrees (h = 1e-4) du gradient analytique ecrites a la main, symetrique ; H_gamma_gamma = ancienne formule (#71)",
         {
           h <- 1e-4; ok <- TRUE
           for (dat in list(list(f_i$delta, f_i$gamma, xi, yi), list(f_t$delta, f_t$gamma, x, y))) {
             d <- dat[[1]]; g <- dat[[2]]; xx <- dat[[3]]; yy <- dat[[4]]
             gr <- function(dd, gg) usp_gradient(dd, gg, xx, yy)
             hgg <- (gr(d, g + h)[["gamma"]] - gr(d, g - h)[["gamma"]]) / (2 * h)
             hdd <- (gr(d + h, g)[["delta"]] - gr(d - h, g)[["delta"]]) / (2 * h)
             hdg <- 0.5 * ((gr(d, g + h)[["delta"]] - gr(d, g - h)[["delta"]]) / (2 * h) +
                           (gr(d + h, g)[["gamma"]] - gr(d - h, g)[["gamma"]]) / (2 * h))
             H <- usp_hessienne(d, g, xx, yy)
             ok <- ok && identical(H[["gamma", "gamma"]], hgg) && identical(H[["delta", "delta"]], hdd) &&
               identical(H[["delta", "gamma"]], hdg) && identical(H[["gamma", "delta"]], hdg) &&
               identical(usp_condition_premier_ordre(d, g, xx, yy)$hessienne, H)
           }
           ok
         })
# Au bord delta = 1 avec pg_delta = 0 (jeu de test), seul gamma est libre :
# le pas est l'ancien pas de Newton en gamma, -pg_gamma / H_gamma_gamma.
verifier("usp_condition_premier_ordre, delta au bord et contrainte active : pas = (0, -pg_gamma / H_gamma_gamma), erreur_sigma = d ln(sigma) / d gamma * pas_gamma (#71)",
         {
           cpo <- usp_condition_premier_ordre(f_t$delta, f_t$gamma, x, y)
           H <- cpo$hessienne[["gamma", "gamma"]]
           cpo$gradient_projete[["delta"]] == 0 &&
             identical(cpo$pas_newton, c(delta = 0, gamma = -cpo$gradient_projete[["gamma"]] / H)) &&
             identical(cpo$erreur_sigma, cpo$grad_ln_sigma[["gamma"]] * cpo$pas_newton[["gamma"]]) &&
             identical(cpo$pas_ecrete, FALSE) && abs(cpo$erreur_sigma) <= 1e-6
         })
# Specification d'actuary (#71, section 6, point 2) : implementation
# independante, difference centree de ln(sigma) (h = 1e-5), 16 points x 2 jeux.
verifier("usp_grad_ln_sigma = difference centree de ln(usp_noyau()$sigma) (16 points, deux jeux, ecart relatif < 1e-8) (#71)",
         {
           h <- 1e-5; em <- 0
           for (dat in list(list(x, y), list(xi, yi)))
             for (d in c(0.1, 0.37, 0.5, 0.9)) for (g in c(-4, -2, -1, 0.5)) {
               ls <- function(dd, gg) log(usp_noyau(dd, gg, dat[[1]], dat[[2]])$sigma)
               num <- c((ls(d + h, g) - ls(d - h, g)) / (2 * h),
                        (ls(d, g + h) - ls(d, g - h)) / (2 * h))
               an <- usp_grad_ln_sigma(d, g, dat[[1]], dat[[2]])
               em <- max(em, abs(an - num) / pmax(1, abs(num)))
             }
           identical(names(usp_grad_ln_sigma(0.5, -2, xi, yi)), c("delta", "gamma")) &&
             (if (em < 1e-8) TRUE else sprintf("ecart relatif max %.3e", em))
         })
# Reduction a pi_t constant (specification d'actuary, section 2 (b)) :
# d ln(sigma) / d gamma = 1 + e / (1 + e), e = exp(2 gamma) (a = 1), et
# d ln(sigma) / d delta = -pi e / (T (1 + e)) somme((1 - xbar / x_t)(r_t - ln(beta))),
# ln(beta) = 1 / (2 pi) + r_barre ; a volumes constants, cette derivee est
# nulle. La specification ecrit r_t - r_barre au lieu de r_t - ln(beta) :
# les deux ne coincident que si somme(1 - xbar / x_t) = 0, ce qui n'est pas
# le cas du jeu de test (mesure du 29/09/2026 a delta = 1 : la forme en
# r_barre s'ecarte de la derivee exacte de 1 % a gamma = -3 et la double a
# gamma = -1 ; le gradient analytique concorde, lui, avec la difference
# centree, test precedent). Forme retenue ici : r_t - ln(beta), derivee de
# la formule (b).
verifier("usp_grad_ln_sigma : reduction a pi_t constant (delta = 1 ; volumes constants), tolerance 1e-10 (#71)",
         {
           ok <- TRUE
           for (cas in list(list(d = 1, xx = x, yy = y), list(d = 0.37, xx = rep(100, 8), yy = y)))
             for (g in c(-3, -1.9, -1)) {
               e <- exp(2 * g); a <- cas$d + (1 - cas$d) * mean(cas$xx) / cas$xx
               p <- unique(signif(usp_pi(cas$d, g, cas$xx), 12))
               r <- log(cas$yy / cas$xx)
               att_g <- 1 + e * a[1] / (1 + e * a[1])
               att_d <- -p * e / (length(cas$xx) * (1 + e * a[1])) *
                 sum((1 - mean(cas$xx) / cas$xx) * (r - (1 / (2 * p) + mean(r))))
               gl <- usp_grad_ln_sigma(cas$d, g, cas$xx, cas$yy)
               ok <- ok && length(p) == 1L &&
                 isTRUE(proche(gl[["gamma"]], att_g, rel = 1e-10, abs = 1e-12)) &&
                 isTRUE(proche(gl[["delta"]], att_d, rel = 1e-10, abs = 1e-12))
             }
           ok && usp_grad_ln_sigma(0.37, -2, rep(100, 8), y)[["delta"]] == 0
         })

## --- Pas de Newton complet ecrete (#71), entrees synthetiques ----------------
# Specification d'actuary (#71, section 6, point 4) : fonction pure, valeurs
# calculees a la main.
HS <- function(dd, dg, gg) matrix(c(dd, dg, dg, gg), 2, 2,
                                  dimnames = list(c("delta", "gamma"), c("delta", "gamma")))
GLS1 <- c(delta = 0.01, gamma = 1.02)
verifier("usp_pas_newton_borne (i) : pg_delta = 0 -> seul gamma libre, pas = (0, -pg_gamma / H_gamma_gamma) (#71)",
         {
           pn <- usp_pas_newton_borne(HS(2, -3, 30), c(delta = 0, gamma = 3e-6), 1, GLS1)
           identical(pn$pas, c(delta = 0, gamma = -3e-6 / 30)) && !pn$libre_delta &&
             isTRUE(pn$def_pos) && identical(pn$pas_ecrete, FALSE) &&
             identical(pn$erreur_sigma, 1.02 * (-3e-6 / 30))
         })
verifier("usp_pas_newton_borne (ii) : delta interieur sans ecretage, pas = -H^-1 pg (1e-12), erreur_sigma = produit scalaire (#71)",
         {
           H <- HS(2, -3, 30); pg <- c(delta = 1e-4, gamma = -2e-5)
           # -H^-1 pg a la main : det = 2 * 30 - 9 = 51
           att <- -c((30 * 1e-4 + 3 * -2e-5) / 51, (3 * 1e-4 + 2 * -2e-5) / 51)
           pn <- usp_pas_newton_borne(H, pg, 0.5, GLS1)
           pn$libre_delta && isTRUE(pn$def_pos) && identical(pn$pas_ecrete, FALSE) &&
             isTRUE(all.equal(unname(pn$pas), att, tolerance = 1e-12)) &&
             isTRUE(all.equal(pn$erreur_sigma, sum(GLS1 * att), tolerance = 1e-12))
         })
verifier("usp_pas_newton_borne (iii) : ecretage a delta = 1, pas = (1e-5, 1e-6), pas_ecrete (#71)",
         {
           # pas libre 30 * 1e-3 / 51 = 5,88e-4 : franchit 1 depuis 1 - 1e-5 ;
           # ecrete a 1e-5, puis pas_gamma = -(0 + (-3)(1e-5)) / 30 = 1e-6.
           pn <- usp_pas_newton_borne(HS(2, -3, 30), c(delta = -1e-3, gamma = 0), 1 - 1e-5, GLS1)
           isTRUE(pn$pas_ecrete) && pn$libre_delta &&
             isTRUE(all.equal(unname(pn$pas), c(1e-5, 1e-6), tolerance = 1e-10)) &&
             isTRUE(all.equal(pn$erreur_sigma, 0.01 * 1e-5 + 1.02 * 1e-6, tolerance = 1e-10))
         })
verifier("usp_pas_newton_borne (iii bis) : ecretage a delta = 0 (#71)",
         {
           # pas libre -30 * 1e-3 / 51 = -5,88e-4 depuis 1e-5 : ecrete a -1e-5,
           # puis pas_gamma = -(0 + (-3)(-1e-5)) / 30 = -1e-6.
           pn <- usp_pas_newton_borne(HS(2, -3, 30), c(delta = 1e-3, gamma = 0), 1e-5, GLS1)
           isTRUE(pn$pas_ecrete) &&
             isTRUE(all.equal(unname(pn$pas), c(-1e-5, -1e-6), tolerance = 1e-10))
         })
verifier("usp_pas_newton_borne (iv) : H_gamma_gamma > 0, det < 0 -> non definie positive si delta libre, definie positive au bord actif (#71)",
         {
           H <- HS(0.1, 3, 30)                 # det = 3 - 9 < 0
           pl <- usp_pas_newton_borne(H, c(delta = 1e-5, gamma = 1e-7), 0.5, GLS1)
           pb <- usp_pas_newton_borne(H, c(delta = 0, gamma = 1e-7), 1, GLS1)
           identical(pl$def_pos, FALSE) && all(is.na(pl$pas)) && is.na(pl$erreur_sigma) &&
             is.na(pl$pas_ecrete) && isTRUE(pb$def_pos) && identical(pb$pas_ecrete, FALSE) &&
             identical(pb$pas, c(delta = 0, gamma = -1e-7 / 30))
         })
verifier("usp_hessienne_libre : def_pos NA si un element de H_F n'est pas fini ; H_delta_delta non fini ignore si delta n'est pas libre (#71)",
         {
           H <- HS(NaN, -3, 30)
           is.na(usp_hessienne_libre(H, c(delta = 1e-5, gamma = 0))$def_pos) &&
             isTRUE(usp_hessienne_libre(H, c(delta = 0, gamma = 0))$def_pos) &&
             is.na(usp_hessienne_libre(HS(2, -3, Inf), c(delta = 0, gamma = 0))$def_pos)
         })
# Defaut de l'issue #71 (specification d'actuary, section 6, point 5) : a
# delta interieur (xi, yi), un residu pg = (1e-4, 0) a un pas en gamma a
# delta fixe nul et |pg_delta| <= 1e-4, que l'ancienne regle acceptait ; le
# pas complet -H^-1 (1e-4, 0), avec H mesure (1,987 ; -3,339 ; 31,665),
# donne une erreur relative sur sigma de -6,4e-6 (reference a la main,
# tolerance relative 1e-2 pour le bruit de H entre plateformes).
verifier("Defaut #71 : a delta interieur, pg = (1e-4, 0) -> erreur_sigma ~ -6,4e-6, KKT non satisfaite",
         {
           cpo <- usp_condition_premier_ordre(f_i$delta, f_i$gamma, xi, yi)
           Hm <- HS(1.987, -3.339, 31.665)
           pas_att <- -solve(Hm, c(1e-4, 0))
           err_att <- sum(cpo$grad_ln_sigma * pas_att)
           pn <- usp_pas_newton_borne(cpo$hessienne, c(delta = 1e-4, gamma = 0), f_i$delta,
                                      cpo$grad_ln_sigma)
           cpo$gradient_projete <- c(delta = 1e-4, gamma = 0)
           cpo$pas_newton <- pn$pas; cpo$erreur_sigma <- pn$erreur_sigma
           isTRUE(proche(pn$erreur_sigma, err_att, rel = 1e-2)) &&
             isTRUE(proche(err_att, -6.4e-6, rel = 1e-2)) &&
             identical(usp_kkt_satisfaite(cpo, f_i$gamma), FALSE)
         })
verifier("usp_ajuster : n_starts_optimum = nombre de demarrages a 1e-6 de l'optimum, kappa = n_starts_optimum / demarrages aboutis",
         f_t$n_starts_optimum >= 2 && f_t$n_starts_echec == 0 &&
           isTRUE(proche(f_t$part_starts_convergents, f_t$n_starts_optimum / 54, rel = 1e-12)))

## --- KKT au bord (delta = 1) et delta interieur ----------------------------
verifier("KKT a delta = 1 (jeu de test) : g_delta < 0, composante projetee nulle, FOC OK",
         f_t$delta_au_bord && f_t$delta > 1 - 1e-6 && f_t$gradient[["delta"]] < 0 &&
           f_t$gradient_projete[["delta"]] == 0 &&
           identical(ctrl(f_t, NOM_FOC)$verdict, "OK"))
# Reference independante de la regle de projection : la derivee UNILATERALE
# de l'objectif vers l'interieur du domaine, par difference finie (h = 1e-7),
# et la composante projetee attendue ecrite a la main (mesure du 23/09/2026) :
#   (x, y) a (0 ; -2)       : derivee a droite -0,695258 -> descente vers
#                             l'interieur, violation : pg attendue -0,695258 ;
#   (x[1:5], y[1:5]) a (0 ; -2,5) : +0,0550875 -> montee, pg attendue 0 ;
#   (x, y) a (1 ; -1,93)    : derivee a gauche -0,528477 -> pg attendue 0 ;
#   (xi, yi) a (1 ; -2,3)   : +1,3188 -> violation, pg attendue 1,3188.
verifier("KKT : composante projetee en delta = valeurs attendues a la main aux bornes 0 et 1 (derivee unilaterale de l'objectif)",
         {
           h <- 1e-7
           o <- function(d, g, xx, yy) usp_noyau(d, g, xx, yy)$obj
           cas <- list(
             list(d = 0, g = -2,    xx = x,      yy = y,      pg = -0.695258),
             list(d = 0, g = -2.5,  xx = x[1:5], yy = y[1:5], pg = 0),
             list(d = 1, g = -1.93, xx = x,      yy = y,      pg = 0),
             list(d = 1, g = -2.3,  xx = xi,     yy = yi,     pg = 1.3188))
           pb <- character(0)
           for (k in seq_along(cas)) {
             cs <- cas[[k]]
             du <- if (cs$d == 0) (o(h, cs$g, cs$xx, cs$yy) - o(0, cs$g, cs$xx, cs$yy)) / h
                   else (o(1, cs$g, cs$xx, cs$yy) - o(1 - h, cs$g, cs$xx, cs$yy)) / h
             pg <- usp_condition_premier_ordre(cs$d, cs$g, cs$xx, cs$yy)$gradient_projete[["delta"]]
             # la valeur ecrite a la main doit etre celle de la difference finie
             ok_ref <- if (cs$pg == 0) TRUE else isTRUE(proche(du, cs$pg, rel = 1e-5))
             ok <- ok_ref && isTRUE(proche(pg, cs$pg, rel = 1e-5, abs = 0))
             if (!ok) pb <- c(pb, sprintf("cas %d : pg %.6g, attendu %.6g (derivee unilaterale %.6g)",
                                          k, pg, cs$pg, du))
           }
           if (length(pb)) paste(pb, collapse = " ; ") else TRUE
         })
verifier("FOC a delta interieur (jeu simule) : |g_delta| <= 1e-4, delta libre, H definie positive, |erreur_sigma| <= 1e-6, OK",
         !f_i$delta_au_bord && abs(f_i$gradient[["delta"]]) <= 1e-4 &&
           isTRUE(usp_hessienne_libre(f_i$hessienne, f_i$gradient_projete)$libre_delta) &&
           isTRUE(usp_hessienne_libre(f_i$hessienne, f_i$gradient_projete)$def_pos) &&
           abs(f_i$erreur_sigma) <= 1e-6 &&
           identical(ctrl(f_i, NOM_FOC)$verdict, "OK"))

## --- Echecs deliberes ------------------------------------------------------
# Critere d'acceptation de l'issue #22 (ajustement non converge nettement
# detecte, seuil 1e-3), transpose par #71 sur la grandeur jugee
# |erreur_sigma| : ajustement a demarrage UNIQUE (0,5 ; ln 0,1), avec les
# bornes, l'objectif et le gradient analytique de usp_ajuster() (#63).
# Avec la grille de 54 demarrages, le meilleur point non converge est plus
# proche de l'optimum : le critere 1e-3 n'y vaut pas, mais les deux
# controles sortent ECHEC (assertion suivante).
fit_demarrage_unique <- function(xx, yy, controle) {
  o <- stats::optim(c(0.5, log(0.1)), usp_objectif, gr = usp_gradient_optim,
                    x = xx, y = yy, xbar = mean(xx),
                    method = "L-BFGS-B", lower = c(0, BORNES_GAMMA[1]),
                    upper = c(1, BORNES_GAMMA[2]), control = controle)
  d <- o$par[1]; g <- o$par[2]
  cpo <- usp_condition_premier_ordre(d, g, xx, yy)
  c(usp_noyau(d, g, xx, yy),
    list(delta = d, gamma = g, T = length(xx), x = xx, y = yy, xbar = mean(xx)),
    cpo,
    list(obj_min = o$value, convergence = o$convergence, part_starts_convergents = 1,
         n_starts_optimum = 1L, n_starts_echec = 0L,
         delta_au_bord = usp_regime(d, xx)$delta_au_bord,
         kkt_au_moins_un = usp_kkt_satisfaite(cpo, g)))
}
for (ct in list(list(factr = 1e13, maxit = 500), list(factr = 1e5, maxit = 2)))
  for (dat in list(list(nom = "jeu de test", x = x, y = y), list(nom = "delta interieur", x = xi, y = yi)))
    verifier(sprintf("Ajustement non converge (demarrage unique, factr = %g, maxit = %d, %s) : FOC ECHEC, |erreur_sigma| > 1e-3",
                     ct$factr, ct$maxit, dat$nom),
             {
               f <- fit_demarrage_unique(dat$x, dat$y, ct)
               c1 <- ctrl(f, NOM_FOC)
               if (identical(c1$verdict, "ECHEC") && isTRUE(abs(f$erreur_sigma) > 1e-3)) TRUE
               else sprintf("verdict %s, erreur_sigma %.3e", c1$verdict, f$erreur_sigma)
             })
# Depuis #63 (gradient analytique), sur le jeu de test a factr = 1e13, deux
# demarrages s'arretent au meme point non converge avec le code 0 (mesure du
# 29/09/2026, Linux, R 4.3.3) : le controle multi-demarrages y sort OK. Il
# juge la coherence des points d'arret entre demarrages (au moins deux a
# l'optimum, au moins un au code 0) ; il n'est pas concu pour detecter une
# tolerance d'arret relachee quand les demarrages concordent. C'est la
# condition du premier ordre qui le fait (|erreur_sigma| = 3,9e-4, ECHEC).
# Proprietes verifiees : FOC ECHEC sur les quatre cas ; multi-demarrages
# ECHEC a maxit = 2 (aucun demarrage a l'optimum au code 0).
verifier("usp_ajuster non converge (grille complete ; factr = 1e13, puis maxit = 2) : FOC ECHEC sur les quatre cas, multi-demarrages ECHEC a maxit = 2",
         {
           pb <- character(0)
           for (ct in list(list(factr = 1e13, maxit = 500), list(factr = 1e5, maxit = 2)))
             for (dat in list(list("jeu de test", x, y), list("delta interieur", xi, yi))) {
               f <- usp_ajuster(dat[[2]], dat[[3]], controle = ct)
               v <- vapply(usp_controles_numeriques(f), function(u) u$verdict, character(1))
               if (v[[1]] != "ECHEC" || (ct$maxit == 2 && v[[2]] != "ECHEC"))
                 pb <- c(pb, sprintf("%s, factr %g, maxit %d : %s", dat[[1]], ct$factr, ct$maxit,
                                     paste(v, collapse = "/")))
             }
           if (length(pb)) paste(pb, collapse = " ; ") else TRUE
         })
verifier("gamma force a la borne 3 : FOC ECHEC, detail 'Demarrage retenu : gamma sur une borne.' sans mention de courbure (#76)",
         {
           cpo <- usp_condition_premier_ordre(f_t$delta, 3, x, y)
           f <- utils::modifyList(f_t, cpo)
           f$gamma <- 3; f$kkt_au_moins_un <- FALSE
           c1 <- ctrl(f, NOM_FOC)
           !usp_kkt_satisfaite(cpo, 3) &&
           identical(c1$verdict, "ECHEC") &&
             identical(c1$detail, paste("Condition KKT verifiee par au moins un demarrage a l'optimum : non.",
                                        "Demarrage retenu : gamma sur une borne."))
         })
verifier("gamma force a la borne -12 : FOC ECHEC, detail 'Demarrage retenu : gamma sur une borne.' sans mention de courbure (#76)",
         {
           cpo <- usp_condition_premier_ordre(f_t$delta, -12, x, y)
           f <- utils::modifyList(f_t, cpo)
           f$gamma <- -12; f$kkt_au_moins_un <- FALSE
           c1 <- ctrl(f, NOM_FOC)
           !usp_kkt_satisfaite(cpo, -12) &&
           identical(c1$verdict, "ECHEC") &&
             identical(c1$detail, paste("Condition KKT verifiee par au moins un demarrage a l'optimum : non.",
                                        "Demarrage retenu : gamma sur une borne."))
         })
verifier("FOC : gradient non fini -> ECHEC",
         {
           f <- f_t; f$gradient[["gamma"]] <- NaN; f$gradient_projete[["gamma"]] <- NaN
           f$pas_newton[] <- NaN; f$erreur_sigma <- NaN; f$kkt_au_moins_un <- FALSE
           identical(ctrl(f, NOM_FOC)$verdict, "ECHEC")
         })
verifier("FOC : courbure H_gamma_gamma <= 0 -> ECHEC",
         {
           f <- f_t; f$hessienne[["gamma", "gamma"]] <- -1; f$kkt_au_moins_un <- FALSE
           identical(ctrl(f, NOM_FOC)$verdict, "ECHEC")
         })
# Precision de M11 (decision du mainteneur apres audit) : reussi si AU MOINS
# UN demarrage a l'optimum rend le code 0 et si au moins deux demarrages
# atteignent l'optimum. Le code du demarrage retenu seul ne decide plus.
verifier("Multi-demarrages : OK sur les jeux de test ; ECHEC si aucun demarrage a l'optimum ne rend 0, ou moins de deux a l'optimum",
         {
           f1 <- f_t; f1$convergence <- 52L                      # retenu 52, autres a 0
           f0 <- f_t; f0$convergence <- 52L; f0$n_starts_optimum_code0 <- 0L
           f2 <- f_t; f2$n_starts_optimum <- 1L; f2$n_starts_optimum_code0 <- 1L
           f3 <- f_t; f3$n_starts_optimum <- 2L; f3$n_starts_optimum_code0 <- 1L
           identical(ctrl(f_t, NOM_MULTI)$verdict, "OK") &&
             identical(ctrl(f_i, NOM_MULTI)$verdict, "OK") &&
             identical(ctrl(f1, NOM_MULTI)$verdict, "OK") &&
             identical(ctrl(f0, NOM_MULTI)$verdict, "ECHEC") &&
             identical(ctrl(f2, NOM_MULTI)$verdict, "ECHEC") &&
             identical(ctrl(f3, NOM_MULTI)$verdict, "OK")
         })
# Decision du mainteneur (23/09/2026) : le detail n'imprime pas le nombre de
# demarrages a l'optimum au code 0 (un demarrage bascule entre les codes 0 et
# 52 selon la machine), seulement le respect de la regle (oui / non).
verifier("Multi-demarrages : detail invariant quand n_starts_optimum_code0 varie (>= 1), 'oui' / 'non' selon la regle (#76)",
         {
           fa <- f_t; fa$n_starts_optimum_code0 <- 53L
           fb <- f_t; fb$n_starts_optimum_code0 <- 1L
           fc <- f_t; fc$n_starts_optimum_code0 <- 0L
           da <- ctrl(f_t, NOM_MULTI)$detail
           identical(da, ctrl(fa, NOM_MULTI)$detail) && identical(da, ctrl(fb, NOM_MULTI)$detail) &&
             identical(da, "54 demarrages a l'optimum ; au moins un au code 0 d'optim() : oui.") &&
             identical(ctrl(fc, NOM_MULTI)$detail,
                       "54 demarrages a l'optimum ; au moins un au code 0 d'optim() : non.") &&
             !grepl("dont", da, fixed = TRUE)
         })
# Decision du mainteneur (24/09/2026, option (a)) : le detail n'imprime pas non
# plus le code d'optim() du demarrage retenu (premier demarrage a l'optimum,
# departage par l'ordre de la grille ; 52 ou 0 selon la machine) ; la valeur
# reste dans res$ajustement$convergence.
verifier("Multi-demarrages : detail invariant quand le code du demarrage retenu varie (0 / 52), sans 'code du demarrage retenu'",
         {
           f52 <- f_t; f52$convergence <- 52L
           f0 <- f_t; f0$convergence <- 0L
           da <- ctrl(f0, NOM_MULTI)$detail
           identical(da, ctrl(f52, NOM_MULTI)$detail) &&
             !grepl("code du demarrage retenu", da, fixed = TRUE) &&
             !grepl("code du demarrage retenu", ctrl(f_i, NOM_MULTI)$detail, fixed = TRUE)
         })
verifier("usp_ajuster : n_starts_optimum_code0 = demarrages a l'optimum rendant le code 0 (<= n_starts_optimum)",
         is.integer(f_t$n_starts_optimum_code0) &&
           f_t$n_starts_optimum_code0 <= f_t$n_starts_optimum && f_t$n_starts_optimum_code0 >= 1L)
# Cas d'audit (200 jeux simules sous le modele, graine 12345, cas 176 et 187) :
# 54 demarrages a moins de 1,9e-12 de l'optimum ; le demarrage retenu (le
# premier, marge 1e-10) rend le code 52, 53 (resp. 52) autres rendent 0.
# Mesure du 23/09/2026 : l'ancienne regle donnait ECHEC sur ces deux cas.
# Propriete verifiee : OK, quel que soit le demarrage retenu sur la plateforme.
# Mesure du 24/09/2026 (session cloud Linux, R 4.3.3) : cas 176, retenu au
# code 52 et 53 demarrages a l'optimum au code 0 ; cas 187, retenu au code 0
# et 54 au code 0 -- le code du demarrage retenu depend de la plateforme
# (issue #22, decision du mainteneur du 24/09/2026).
sim_audit <- local({
  set.seed(12345); out <- list()
  for (k in 1:187) {
    xs <- if (k %% 2) x else x * exp(rnorm(8, 0, 0.5))
    d <- runif(1); s <- runif(1, 0.05, 0.3)
    sd2 <- log(1 + s^2 * (d + (1 - d) * mean(xs) / xs))
    ys <- 0.7 * xs * exp(rnorm(8, -sd2 / 2, sqrt(sd2)))
    if (k %in% c(176, 187)) out[[as.character(k)]] <- list(x = xs, y = ys)
  }
  out
})
for (k in names(sim_audit))
  verifier(sprintf("Multi-demarrages, cas d'audit %s (demarrage retenu au code 52 selon la plateforme, autres a 0) : OK", k),
           {
             f <- usp_ajuster(sim_audit[[k]]$x, sim_audit[[k]]$y)
             v <- ctrl(f, NOM_MULTI)$verdict
             if (identical(v, "OK")) TRUE
             else sprintf("verdict %s, code retenu %d, a l'optimum %d dont %d au code 0", v,
                          f$convergence, f$n_starts_optimum, f$n_starts_optimum_code0)
           })

## --- KKT en delta : regle unique |pg_delta| <= 1e-4 --------------------------
# Decision par demarrage (usp_kkt_satisfaite(), depuis la regle "au moins un
# demarrage", decision du mainteneur du 24/09/2026).
verifier("KKT en delta, regle unique : au bord, |pg_delta| = 3,6e-6 -> satisfaite ; 2e-4 -> non",
         {
           ca <- usp_condition_premier_ordre(f_t$delta, f_t$gamma, x, y)
           cb <- ca
           ca$gradient_projete[["delta"]] <- 3.6e-6; cb$gradient_projete[["delta"]] <- 2e-4
           isTRUE(usp_kkt_satisfaite(ca, f_t$gamma)) && identical(usp_kkt_satisfaite(cb, f_t$gamma), FALSE)
         })
verifier("KKT en delta, regle unique : a l'interieur, |pg_delta| = 2e-4 -> non satisfaite",
         {
           cb <- usp_condition_premier_ordre(f_i$delta, f_i$gamma, xi, yi)
           cb$gradient[["delta"]] <- 2e-4; cb$gradient_projete[["delta"]] <- 2e-4
           identical(usp_kkt_satisfaite(cb, f_i$gamma), FALSE)
         })
# Cas d'audit : volumes x^3 / 1e4, y deforme par exp(l (t - 4,5) / 10) ; aux
# deux valeurs de l qui encadrent le basculement de delta estime (bisection,
# poste du mainteneur), delta = 1 avec pg_delta = 3,6e-6 d'un cote, delta
# interieur 0,99999809 avec g_delta = 2,3e-6 de l'autre (mesure du
# 23/09/2026). L'ancienne regle (pg_delta = 0 exige au bord) donnait ECHEC
# puis OK pour une perturbation de 4,5e-13 de l : discontinuite supprimee.
# #71 (specification d'actuary, section 6, point 7) : delta libre des deux
# cotes (au bord, pg_delta pousse vers l'interieur ; a l'interieur, toujours),
# donc meme ensemble libre : le controle reste continu a la bascule. Le
# basculement a ete localise avec l'optimiseur anterieur a #63 : le cote
# effectivement atteint depend de l'optimiseur, la propriete testee (OK et
# delta libre) vaut des deux cotes.
verifier("KKT en delta, cas d'audit au basculement du bord : OK des deux cotes, delta libre des deux cotes (#71)",
         {
           xw <- x^3 / 1e4
           vv <- vapply(c(0.89559862669921131, 0.89559862669966606), function(l) {
             yy <- xw * (y / x) * exp(l * (1:8 - 4.5) / 10)
             f <- usp_ajuster(xw, yy)
             paste(ctrl(f, NOM_FOC)$verdict,
                   usp_hessienne_libre(f$hessienne, f$gradient_projete)$libre_delta)
           }, character(1))
           if (all(vv == "OK TRUE")) TRUE else paste("verdicts, delta libre :", paste(vv, collapse = ", "))
         })

## --- Regle "au moins un demarrage a l'optimum satisfait KKT" (#22) ---------
# Decision du mainteneur du 24/09/2026 (constat 4 de la revue finale d'audit,
# specification d'actuary) : le verdict FOC ne depend plus du demarrage
# retenu. usp_kkt_satisfaite() juge un demarrage ; usp_ajuster() rend
# kkt_au_moins_un ; usp_controles_numeriques() en tire le verdict.
verifier("usp_kkt_satisfaite : TRUE au point estime a delta interieur (xi, yi)",
         isTRUE(usp_kkt_satisfaite(usp_condition_premier_ordre(f_i$delta, f_i$gamma, xi, yi),
                                   f_i$gamma)))
verifier("usp_kkt_satisfaite : FALSE si gamma sur une borne (3, -12), H_gamma_gamma <= 0 ou NaN, det(H) <= 0 a delta libre, gradient NaN, pas NaN, |erreur_sigma| = 1,5e-6 ou |pg_delta| = 2e-4 (#71)",
         {
           c0 <- usp_condition_premier_ordre(f_i$delta, f_i$gamma, xi, yi)
           non <- function(cpo, g = f_i$gamma) identical(usp_kkt_satisfaite(cpo, g), FALSE)
           mod <- function(...) utils::modifyList(c0, list(...))
           mh <- function(i, j, v) { cc <- c0; cc$hessienne[[i, j]] <- v; cc }
           cg <- c0; cg$gradient[["gamma"]] <- NaN; cg$gradient_projete[["gamma"]] <- NaN
           cd <- c0; cd$gradient_projete[["delta"]] <- 2e-4
           cp <- c0; cp$pas_newton[["delta"]] <- NaN
           r <- c(borne3 = non(usp_condition_premier_ordre(f_i$delta, 3, xi, yi), 3),
                  borne12 = non(usp_condition_premier_ordre(f_i$delta, -12, xi, yi), -12),
                  gamma_borne_seul = non(c0, BORNES_GAMMA[2]),
                  H_neg = non(mh("gamma", "gamma", -1)), H_nul = non(mh("gamma", "gamma", 0)),
                  H_nan = non(mh("gamma", "gamma", NaN)),
                  H_dd_nan = non(mh("delta", "delta", NaN)),
                  det_neg = non(mh("delta", "delta", 0.1)), grad_nan = non(cg), pas_nan = non(cp),
                  err_pos = non(mod(erreur_sigma = 1.5e-6)),
                  err_neg = non(mod(erreur_sigma = -1.5e-6)),
                  pg_delta = non(cd))
           if (all(r)) TRUE else paste("non FALSE :", paste(names(r)[!r], collapse = ", "))
         })
verifier("usp_kkt_satisfaite : conditions jugees sur le meme point (erreur_sigma OK et |pg_delta| = 2e-4 -> FALSE)",
         {
           c0 <- usp_condition_premier_ordre(f_i$delta, f_i$gamma, xi, yi)
           c0$erreur_sigma <- 1e-8; c0$gradient_projete[["delta"]] <- 2e-4
           identical(usp_kkt_satisfaite(c0, f_i$gamma), FALSE)
         })
verifier("usp_ajuster : kkt_au_moins_un logique de longueur 1, TRUE sur (x, y) et (xi, yi)",
         is.logical(f_t$kkt_au_moins_un) && length(f_t$kkt_au_moins_un) == 1L &&
           isTRUE(f_t$kkt_au_moins_un) && isTRUE(f_i$kkt_au_moins_un))
# Reference independante : les 54 optim() refaits dans le test (meme grille,
# meme reglage, gradient analytique depuis #63), la condition ecrite a la
# main (#71 : ensemble libre, critere de Sylvester, pas de Newton complet,
# ecretage, erreur_sigma) sur le gradient projete, la hessienne et le
# gradient de ln(sigma) de usp_condition_premier_ordre(), sans
# usp_kkt_satisfaite() ni usp_pas_newton_borne().
kkt_reference <- function(xx, yy, controle = list(factr = 1e2, maxit = 500)) {
  st <- expand.grid(delta = seq(0, 1, length.out = 9),
                    gamma = log(c(0.01, 0.03, 0.06, 0.10, 0.20, 0.40)))
  fits <- lapply(seq_len(nrow(st)), function(i) try(stats::optim(
    c(st$delta[i], st$gamma[i]), usp_objectif, gr = usp_gradient_optim,
    x = xx, y = yy, xbar = mean(xx),
    method = "L-BFGS-B", lower = c(0, BORNES_GAMMA[1]), upper = c(1, BORNES_GAMMA[2]),
    control = controle), silent = TRUE))
  fits <- fits[!vapply(fits, inherits, logical(1), "try-error")]
  v <- vapply(fits, function(o) o$value, numeric(1))
  opt <- fits[abs(v - min(v)) < 1e-6]
  any(vapply(opt, function(o) {
    d <- o$par[1]; g <- o$par[2]
    cp <- usp_condition_premier_ordre(d, g, xx, yy)
    pg <- cp$gradient_projete; H <- cp$hessienne; gl <- cp$grad_ln_sigma
    if (!all(is.finite(c(cp$gradient, pg)))) return(FALSE)
    if (!(g > BORNES_GAMMA[1] + 1e-6 && g < BORNES_GAMMA[2] - 1e-6)) return(FALSE)
    hgg <- H[2, 2]; hdd <- H[1, 1]; hdg <- H[1, 2]
    # delta jamais libre a volumes constants (etendue relative <= 1e-6,
    # reprise de #71 apres audit)
    libre <- pg[1] != 0 && diff(range(xx)) > 1e-6 * mean(xx)
    if (!libre) {
      if (!(is.finite(hgg) && hgg > 0)) return(FALSE)
      err <- gl[2] * (-pg[2] / hgg)
    } else {
      if (!(all(is.finite(H)) && hgg > 0 && hdd * hgg - hdg^2 > 0)) return(FALSE)
      det <- hdd * hgg - hdg^2
      pd <- -(hgg * pg[1] - hdg * pg[2]) / det
      pgm <- -(-hdg * pg[1] + hdd * pg[2]) / det
      if (d + pd < 0 || d + pd > 1) {
        pd <- (if (d + pd < 0) 0 else 1) - d
        pgm <- -(pg[2] + hdg * pd) / hgg
      }
      err <- gl[1] * pd + gl[2] * pgm
    }
    is.finite(err) && abs(err) <= 1e-6 && abs(pg[1]) <= 1e-4
  }, logical(1)))
}
verifier("usp_ajuster : kkt_au_moins_un = reference independante (optim() refaits, condition a la main), jeux (x, y), (xi, yi) et non converge (factr = 1e13)",
         {
           ct <- list(factr = 1e13, maxit = 500)
           r <- c(identical(f_t$kkt_au_moins_un, kkt_reference(x, y)),
                  identical(f_i$kkt_au_moins_un, kkt_reference(xi, yi)),
                  identical(usp_ajuster(xi, yi, controle = ct)$kkt_au_moins_un,
                            kkt_reference(xi, yi, ct)))
           if (all(r)) TRUE else paste("desaccord :", paste(which(!r), collapse = ", "))
         })
verifier("Verdict FOC = kkt_au_moins_un : ECHEC si FALSE bien que le retenu satisfasse ; OK si TRUE bien que le retenu ait |erreur_sigma| = 1,5e-6",
         {
           fa <- f_t; fa$kkt_au_moins_un <- FALSE
           fb <- f_i; fb$erreur_sigma <- 1.5e-6
           isTRUE(usp_kkt_satisfaite(usp_condition_premier_ordre(f_t$delta, f_t$gamma, x, y), f_t$gamma)) &&
             identical(ctrl(fa, NOM_FOC)$verdict, "ECHEC") &&
             isTRUE(fb$kkt_au_moins_un) && identical(ctrl(fb, NOM_FOC)$verdict, "OK")
         })
# Cas de simulation (graine 20260924, 1 051 jeux tires comme sim_audit ; cas
# k = 324 et k = 1051, delta interieur). Mesure du 24/09/2026 (session cloud
# Linux, R 4.3.3) : le demarrage retenu a |Delta gamma| = 1,24e-6 (k = 324)
# et 1,39e-6 (k = 1051), au-dessus du repere 1e-6 : l'ancienne regle (seul
# demarrage retenu) donnait ECHEC. La valeur de |Delta gamma| du retenu
# depend de la plateforme et n'est pas testee ; propriete verifiee : OK.
sim_kkt <- local({
  set.seed(20260924); out <- list()
  for (k in 1:1051) {
    xs <- if (k %% 2) x else x * exp(rnorm(8, 0, 0.5))
    d <- runif(1); s <- runif(1, 0.05, 0.3)
    sd2 <- log(1 + s^2 * (d + (1 - d) * mean(xs) / xs))
    ys <- 0.7 * xs * exp(rnorm(8, -sd2 / 2, sqrt(sd2)))
    if (k %in% c(324, 1051)) out[[as.character(k)]] <- list(x = xs, y = ys)
  }
  out
})
for (k in names(sim_kkt))
  verifier(sprintf("FOC, cas simule %s (delta interieur ; retenu au-dessus de 1e-6 selon la plateforme, un autre demarrage a l'optimum en dessous) : OK", k),
           {
             f <- usp_ajuster(sim_kkt[[k]]$x, sim_kkt[[k]]$y)
             v <- ctrl(f, NOM_FOC)$verdict
             if (!f$delta_au_bord && identical(v, "OK")) TRUE
             else sprintf("verdict %s, delta %.6g", v, f$delta)
           })
verifier("Detail FOC invariant quand erreur_sigma et pg_delta du retenu franchissent les reperes, ou quand le pas est ecrete (kkt_au_moins_un constant) ; regle et oui / non imprimes",
         {
           d0 <- ctrl(f_i, NOM_FOC)$detail
           fa <- f_i; fa$erreur_sigma <- 1.5e-6
           fb <- f_i; fb$erreur_sigma <- -1.5e-6; fb$pas_ecrete <- TRUE
           fc <- f_i; fc$gradient_projete[["delta"]] <- 2e-4; fc$gradient[["delta"]] <- 2e-4
           fn <- f_i; fn$kkt_au_moins_un <- FALSE
           dt <- ctrl(f_t, NOM_FOC)$detail
           identical(d0, ctrl(fa, NOM_FOC)$detail) && identical(d0, ctrl(fb, NOM_FOC)$detail) &&
             identical(d0, ctrl(fc, NOM_FOC)$detail) &&
             !any(grepl("sous le repere|au-dessus de|Kuhn-Tucker satisfaite|Kuhn-Tucker violee",
                        c(d0, dt))) &&
             identical(d0, "Condition KKT verifiee par au moins un demarrage a l'optimum : oui.") &&
             identical(dt, d0) &&
             identical(ctrl(fn, NOM_FOC)$detail,
                       "Condition KKT verifiee par au moins un demarrage a l'optimum : non.")
         })

## --- Mineurs d'audit ---------------------------------------------------------
verifier("gamma sur une borne : pas de Newton, erreur_sigma, pas_ecrete et stat du controle NA",
         {
           ok <- TRUE
           for (gb in BORNES_GAMMA) {
             cpo <- usp_condition_premier_ordre(f_t$delta, gb, x, y)
             f <- utils::modifyList(f_t, cpo); f$gamma <- gb
             ok <- ok && all(is.na(cpo$pas_newton)) && is.na(cpo$erreur_sigma) &&
               is.na(cpo$pas_ecrete) && is.na(ctrl(f, NOM_FOC)$stat)
           }
           ok
         })
# Libelles de la condition du premier ordre (#76, retouches du mainteneur du
# 24/09/2026) : une assertion exacte par variante. Reference : les textes
# valides par le mainteneur ; la courbure est « non finie » si H_gamma_gamma
# est NaN ou +-Inf, « non strictement positive » si H est finie et <= 0 ;
# les anomalies du demarrage retenu sont reunies sous un seul prefixe,
# separees par " ; ", dans l'ordre gradient, courbure, gamma sur une borne ;
# la phrase des volumes constants reste a part, avant ; la courbure n'est
# pas mentionnee quand gamma est sur une borne.
K_OUI <- "Condition KKT verifiee par au moins un demarrage a l'optimum : oui."
K_NON <- "Condition KKT verifiee par au moins un demarrage a l'optimum : non."
verifier("Libelle FOC : gradient non fini seul (#76)",
         {
           fg <- f_t; fg$gradient[["gamma"]] <- NaN; fg$gradient_projete[["gamma"]] <- NaN
           fg$pas_newton[] <- NA_real_
           identical(ctrl(fg, NOM_FOC)$detail,
                     paste(K_OUI, "Demarrage retenu : gradient non fini."))
         })
verifier("Libelle FOC : H = +Inf -> 'courbure non finie', ECHEC (#76)",
         {
           f <- f_t; f$hessienne[["gamma", "gamma"]] <- Inf; f$pas_newton[] <- NA_real_
           f$kkt_au_moins_un <- FALSE
           identical(ctrl(f, NOM_FOC)$detail,
                     paste(K_NON, "Demarrage retenu : courbure non finie.")) &&
             identical(ctrl(f, NOM_FOC)$verdict, "ECHEC")
         })
verifier("Libelle FOC : H = -Inf -> 'courbure non finie' (#76)",
         {
           f <- f_t; f$hessienne[["gamma", "gamma"]] <- -Inf; f$pas_newton[] <- NA_real_
           f$kkt_au_moins_un <- FALSE
           identical(ctrl(f, NOM_FOC)$detail,
                     paste(K_NON, "Demarrage retenu : courbure non finie."))
         })
verifier("Libelle FOC : H = NaN -> 'courbure non finie', ECHEC (#76)",
         {
           f <- f_t; f$hessienne[["gamma", "gamma"]] <- NaN; f$pas_newton[] <- NA_real_
           f$kkt_au_moins_un <- FALSE
           identical(ctrl(f, NOM_FOC)$detail,
                     paste(K_NON, "Demarrage retenu : courbure non finie.")) &&
             identical(ctrl(f, NOM_FOC)$verdict, "ECHEC")
         })
verifier("Libelle FOC : H finie <= 0 (-1 et 0) -> 'courbure non strictement positive' (#76)",
         {
           f <- f_t; f$hessienne[["gamma", "gamma"]] <- -1; f$kkt_au_moins_un <- FALSE
           f0 <- f; f0$hessienne[["gamma", "gamma"]] <- 0
           att <- paste(K_NON, "Demarrage retenu : courbure non strictement positive.")
           identical(ctrl(f, NOM_FOC)$detail, att) && identical(ctrl(f0, NOM_FOC)$detail, att)
         })
# #71 (specification d'actuary, section 6, point 10) : a delta interieur,
# delta est libre et la courbure est jugee sur la hessienne entiere
# (Sylvester) ; H_gamma_gamma > 0 mais det(H) < 0 -> meme texte que H_gamma_gamma
# <= 0. Un element non fini de H_delta_delta n'est une anomalie que si delta
# est libre. Un pas ecrete n'ajoute aucun texte.
verifier("Libelle FOC : delta libre, det(H) < 0 -> 'courbure non strictement positive' ; H_delta_delta NaN -> 'courbure non finie' ; au bord actif, H_delta_delta ignoree ; ecretage sans texte (#71)",
         {
           f <- f_i; f$hessienne[["delta", "delta"]] <- 0.1; f$kkt_au_moins_un <- FALSE
           fn <- f_i; fn$hessienne[["delta", "delta"]] <- NaN; fn$kkt_au_moins_un <- FALSE
           fb <- f_t; fb$hessienne[["delta", "delta"]] <- NaN
           fe <- f_i; fe$pas_ecrete <- TRUE
           identical(ctrl(f, NOM_FOC)$detail,
                     paste(K_NON, "Demarrage retenu : courbure non strictement positive.")) &&
             identical(ctrl(fn, NOM_FOC)$detail,
                       paste(K_NON, "Demarrage retenu : courbure non finie.")) &&
             identical(ctrl(fb, NOM_FOC)$detail, K_OUI) &&
             identical(ctrl(fe, NOM_FOC)$detail, K_OUI)
         })
verifier("Libelle FOC : cumul gradient non fini + courbure, un seul prefixe (#76)",
         {
           fa <- f_t; fa$gradient[["gamma"]] <- NaN; fa$gradient_projete[["gamma"]] <- NaN
           fa$hessienne[["gamma", "gamma"]] <- NaN; fa$kkt_au_moins_un <- FALSE
           fb <- fa; fb$hessienne[["gamma", "gamma"]] <- -1
           identical(ctrl(fa, NOM_FOC)$detail,
                     paste(K_NON, "Demarrage retenu : gradient non fini ; courbure non finie.")) &&
             identical(ctrl(fb, NOM_FOC)$detail,
                       paste(K_NON, "Demarrage retenu : gradient non fini ; courbure non strictement positive."))
         })
verifier("Libelle FOC : cumul avec gamma sur une borne, courbure omise (#76)",
         {
           fa <- f_t; fa$gradient[["gamma"]] <- NaN; fa$gradient_projete[["gamma"]] <- NaN
           fa$hessienne[["gamma", "gamma"]] <- NaN; fa$kkt_au_moins_un <- FALSE; fa$gamma <- BORNES_GAMMA[2]
           identical(ctrl(fa, NOM_FOC)$detail,
                     paste(K_NON, "Demarrage retenu : gradient non fini ; gamma sur une borne."))
         })
# Reprise de #71 apres audit (constat C1, avis d'actuary du 29/09/2026) : a
# volumes constants (usp_volumes_constants(), predicat de usp_regime()),
# delta n'est pas identifie et n'est jamais libre ; sans cette exception,
# g_delta (bruit d'arrondi) rendait delta libre et det(H), H_delta_delta ~
# 1e-25, prenait un signe aleatoire : libelle "courbure non strictement
# positive" et stat NA sur 23 jeux sur 40 d'etendue 1e-15 a 1e-13 (mesure
# d'audit). Reference : F = {gamma}, def_pos = (H_gamma_gamma > 0), pas en
# delta nul.
verifier("usp_hessienne_libre : a volumes constants, delta jamais libre, def_pos = (H_gamma_gamma > 0) meme si det(H) < 0 (#71, reprise)",
         {
           H <- HS(-1e-25, 3e-10, 30)            # det < 0
           a <- usp_hessienne_libre(H, c(delta = 2e-10, gamma = 1e-9), volumes_constants = TRUE)
           b <- usp_hessienne_libre(H, c(delta = 2e-10, gamma = 1e-9))
           pn <- usp_pas_newton_borne(H, c(delta = 2e-10, gamma = 1e-9), 0.5, GLS1, volumes_constants = TRUE)
           !a$libre_delta && isTRUE(a$def_pos) && b$libre_delta && identical(b$def_pos, FALSE) &&
             identical(pn$pas, c(delta = 0, gamma = -1e-9 / 30)) &&
             identical(pn$erreur_sigma, 1.02 * (-1e-9 / 30))
         })
# Balayage de l'audit : volumes x = 100 (1 + eps U(-1, 1)), eps de 1e-15 a
# 1e-7 (etendue relative <= 2e-7, dans la bande TOL_DELTA_BORD), cinq tirages
# par eps (graine 20260929), et le jeu quasi constant 100 (1 + alt 1e-8) de
# test_volumes_constants.R perturbe a 1e-13 ; y du jeu de test. Proprietes :
# aucun libelle "courbure", stat fini, delta non libre, FOC OK.
verifier("Volumes constants (balayage eps = 1e-15 a 1e-7, x_q perturbe a 1e-13) : aucun libelle 'courbure', stat fini, delta non libre, FOC OK (#71, reprise)",
         {
           set.seed(20260929)
           alt <- rep(c(1, -1), 4)
           xs <- c(lapply(rep(10^(-15:-7), each = 5), function(e) 100 * (1 + e * runif(8, -1, 1))),
                   lapply(1:5, function(k) 100 * (1 + alt * 1e-8) * (1 + 1e-13 * runif(8, -1, 1))))
           pb <- character(0)
           for (k in seq_along(xs)) {
             f <- usp_ajuster(xs[[k]], y); c1 <- ctrl(f, NOM_FOC)
             if (!usp_volumes_constants(xs[[k]]) || grepl("courbure", c1$detail) || !is.finite(c1$stat) ||
                 isTRUE(usp_hessienne_libre(f$hessienne, f$gradient_projete, TRUE)$libre_delta) ||
                 f$pas_newton[["delta"]] != 0 || c1$verdict != "OK")
               pb <- c(pb, sprintf("jeu %d : %s (stat %g)", k, c1$detail, c1$stat))
           }
           if (length(pb)) paste(pb, collapse = " ; ") else TRUE
         })
verifier("Volumes constants : le detail FOC dit delta non identifie (#58, #76)",
         {
           fv <- usp_ajuster(rep(100, 8), y)
           d <- ctrl(fv, NOM_FOC)$detail
           identical(d, paste(sprintf("Condition KKT verifiee par au moins un demarrage a l'optimum : %s.",
                                      if (isTRUE(fv$kkt_au_moins_un)) "oui" else "non"),
                              "Volumes constants : delta non identifie."))
         })
verifier("Libelle FOC : volumes constants + anomalies, phrase a part placee avant (#76, exemple du mainteneur)",
         {
           fa <- f_t; fa$x <- rep(100, 8); fa$gradient[["gamma"]] <- NaN
           fa$gradient_projete[["gamma"]] <- NaN
           fa$hessienne[["gamma", "gamma"]] <- NaN; fa$kkt_au_moins_un <- FALSE
           fb <- fa; fb$gamma <- BORNES_GAMMA[2]
           fc <- fa; fc$gradient <- f_t$gradient; fc$gradient_projete <- f_t$gradient_projete
           fc$hessienne[["gamma", "gamma"]] <- -1
           identical(ctrl(fa, NOM_FOC)$detail,
                     paste(K_NON, "Volumes constants : delta non identifie.",
                           "Demarrage retenu : gradient non fini ; courbure non finie.")) &&
             identical(ctrl(fb, NOM_FOC)$detail,
                       paste(K_NON, "Volumes constants : delta non identifie.",
                             "Demarrage retenu : gradient non fini ; gamma sur une borne.")) &&
             identical(ctrl(fc, NOM_FOC)$detail,
                       paste(K_NON, "Volumes constants : delta non identifie.",
                             "Demarrage retenu : courbure non strictement positive."))
         })

## --- Forme des deux controles ----------------------------------------------
verifier("usp_controles_numeriques : deux entrees, champs de usp_controle_donnees(), famille H, stat numerique, p NA",
         {
           cc <- usp_controles_numeriques(f_t)
           ref <- names(usp_controle_donnees(x, y)[[1]])
           length(cc) == 2L &&
             all(vapply(cc, function(u) identical(names(u), ref), logical(1))) &&
             all(vapply(cc, function(u) identical(u$famille, FAM_H), logical(1))) &&
             all(vapply(cc, function(u) is.double(u$stat) && is.na(u$p), logical(1))) &&
             identical(vapply(cc, function(u) u$test, character(1)), c(NOM_FOC, NOM_MULTI))
         })
verifier("usp_controles_numeriques : stat = erreur_sigma (FOC, #71) et part kappa (multi-demarrages)",
         {
           cc <- usp_controles_numeriques(f_i)
           identical(cc[[1]]$stat, f_i$erreur_sigma) &&
             identical(cc[[2]]$stat, f_i$part_starts_convergents)
         })
# Libelle concis (#76) : ni regle, ni repere, ni regime de delta dans le
# detail (fiches du .tex) ; delta au bord ou interieur, meme texte.
verifier("Detail FOC concis : ni repere, ni regle, ni regime de delta ; meme texte au bord et a l'interieur (#76)",
         {
           dt <- ctrl(f_t, NOM_FOC)$detail; di <- ctrl(f_i, NOM_FOC)$detail
           isTRUE(f_t$delta_au_bord) && !isTRUE(f_i$delta_au_bord) && identical(dt, di) &&
             !any(grepl("1e-|M9|ndeps|Regle|BORD|interieur", c(dt, di)))
         })
## --- Reperes : constantes du moteur et libelles (audit M1, issue #22) -------
# Les reperes sont definis une seule fois en tete du moteur (TOL_OPTIMUM,
# REP_SIGMA_KKT, REP_GD_KKT). Reference : les valeurs des decisions M15/M25
# (1e-6), #71 (1e-6, 28/09/2026, remplace M17) et M16 (1e-4) ; puis
# propriete de liaison : une autre
# valeur des constantes modifie la decision. Depuis #76, les libelles ne
# les impriment plus : ils ne changent pas avec elles, et ne peuvent donc
# pas rester perimes.
verifier("Reperes : TOL_OPTIMUM = 1e-6 (M15, M25), REP_SIGMA_KKT = 1e-6 (#71), REP_GD_KKT = 1e-4 (M16) ; REP_PAS_KKT retire",
         identical(TOL_OPTIMUM, 1e-6) && identical(REP_SIGMA_KKT, 1e-6) && identical(REP_GD_KKT, 1e-4) &&
           !exists("REP_PAS_KKT") &&
           identical(formals(usp_kkt_satisfaite)$rep_sigma, quote(REP_SIGMA_KKT)) &&
           identical(formals(usp_kkt_satisfaite)$rep_gd, quote(REP_GD_KKT)))
verifier("Libelles FOC et multi-demarrages : aucun repere imprime, invariants quand les constantes changent, decision KKT liee a REP_SIGMA_KKT (#76, #71)",
         {
           lib <- function() {
             cc <- usp_controles_numeriques(f_i)
             c(foc = cc[[1]]$detail, multi = cc[[2]]$detail)
           }
           attendu <- function(d) !any(grepl("e-[0-9]", d))
           d0 <- lib()
           ok0 <- attendu(d0)
           # Autres valeurs des constantes (environnement de definition du
           # moteur), restaurees a la sortie
           env <- environment(usp_controles_numeriques)
           sauve <- mget(c("TOL_OPTIMUM", "REP_SIGMA_KKT", "REP_GD_KKT"), envir = env)
           on.exit(list2env(sauve, envir = env), add = TRUE)
           assign("TOL_OPTIMUM", 3e-7, envir = env)
           assign("REP_SIGMA_KKT", 2e-6, envir = env)
           assign("REP_GD_KKT", 5e-5, envir = env)
           d1 <- lib()
           cpo <- usp_condition_premier_ordre(f_i$delta, f_i$gamma, xi, yi)
           cpo$erreur_sigma <- 1.5e-6
           kkt_suit <- isTRUE(usp_kkt_satisfaite(cpo, f_i$gamma))
           ok1 <- attendu(d1) && identical(d1, d0) && kkt_suit
           list2env(sauve, envir = env)
           if (ok0 && ok1 && identical(lib(), d0)) TRUE
           else sprintf("libelle initial conforme %s, apres changement %s, KKT suit REP_SIGMA_KKT %s",
                        ok0, attendu(d1), kkt_suit)
         })
# Libelle concis (#76) : nombre de demarrages a l'optimum, respect de la
# condition sur le code 0, demarrages sans resultat seulement s'il y en a,
# "1 seul demarrage a l'optimum ; au code 0 d'optim()" s'il n'y en a qu'un
# (retouche du mainteneur du 24/09/2026) ; ni regle ni kappa.
verifier("Detail multi-demarrages : textes du mainteneur et variantes (sans resultat, 1 seul demarrage) (#76)",
         {
           f3 <- f_t; f3$n_starts_echec <- 3L
           f1 <- f_t; f1$n_starts_echec <- 1L
           fu <- f_t; fu$n_starts_optimum <- 1L; fu$n_starts_optimum_code0 <- 1L
           fz <- fu; fz$n_starts_optimum_code0 <- 0L
           identical(ctrl(f_t, NOM_MULTI)$detail, "54 demarrages a l'optimum ; au moins un au code 0 d'optim() : oui.") &&
             identical(ctrl(f3, NOM_MULTI)$detail,
                       "54 demarrages a l'optimum ; au moins un au code 0 d'optim() : oui. 3 demarrages sans resultat.") &&
             identical(ctrl(f1, NOM_MULTI)$detail,
                       "54 demarrages a l'optimum ; au moins un au code 0 d'optim() : oui. 1 demarrage sans resultat.") &&
             identical(ctrl(fu, NOM_MULTI)$detail,
                       "1 seul demarrage a l'optimum ; au code 0 d'optim() : oui.") &&
             identical(ctrl(fz, NOM_MULTI)$detail,
                       "1 seul demarrage a l'optimum ; au code 0 d'optim() : non.") &&
             identical(ctrl(fu, NOM_MULTI)$verdict, "ECHEC") &&
             !grepl("kappa|Regle|convention", ctrl(f_t, NOM_MULTI)$detail)
         })
# Regle de stabilite inter-plateformes : aucune chaine ne restitue une
# valeur d'optimiseur. Une perturbation de gamma de 1e-9 (au-dela de la derive
# poste / CI) change g, pg, H, le pas de Newton et erreur_sigma sans changer
# le detail.
verifier("Details des deux controles invariants a une perturbation de gamma de 1e-9 (aucune mantisse d'optimiseur)",
         {
           f2 <- utils::modifyList(f_i, usp_condition_premier_ordre(f_i$delta, f_i$gamma + 1e-9, xi, yi))
           f2$gamma <- f_i$gamma + 1e-9
           a <- usp_controles_numeriques(f_i); b <- usp_controles_numeriques(f2)
           f2$erreur_sigma != f_i$erreur_sigma &&
             f2$gradient_projete[["delta"]] != f_i$gradient_projete[["delta"]] &&
             identical(a[[1]]$detail, b[[1]]$detail) && identical(a[[2]]$detail, b[[2]]$detail)
         })

## --- Place dans le resultat de run_engine() --------------------------------
res <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II", B = 99,
                  nature_donnees = "brutes")
tb <- engine_table_tests(res)
verifier("run_engine : table des tests a 48 lignes, sans les deux controles numeriques",
         nrow(tb) == 48L && !any(tb$test %in% c(NOM_FOC, NOM_MULTI,
                                                "Condition du premier ordre |sum(pi_t*v_t)|/sum(pi_t)")))
verifier("run_engine : famille G reduite au jackknife et a l'IC",
         identical(tb$test[substr(tb$famille, 1, 2) == "G."],
                   c("Sensibilite au retrait d'une annee (jackknife)",
                     "Largeur relative de l'IC bootstrap 90%")))
verifier("run_engine : res$controles a 10 entrees, les deux dernieres en famille H",
         length(res$controles) == 10L &&
           identical(vapply(res$controles[9:10], function(u) u$famille, character(1)), rep(FAM_H, 2)) &&
           identical(vapply(res$controles[9:10], function(u) u$test, character(1)), c(NOM_FOC, NOM_MULTI)))
verifier("run_engine : controles numeriques OK sur le jeu de test ; resultat produit (non bloquant)",
         isTRUE(res$ok) && all(vapply(res$controles[9:10], function(u) u$verdict, character(1)) == "OK"))

fin_fichier()
