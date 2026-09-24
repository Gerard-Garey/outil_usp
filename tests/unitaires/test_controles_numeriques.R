###############################################################################
#  tests/unitaires/test_controles_numeriques.R  --  CONTROLES NUMERIQUES DE
#  L'ESTIMATION LOGNORMALE (issue #22, decision M11)
#
#  usp_gradient(), usp_condition_premier_ordre(), usp_kkt_satisfaite(),
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
#    - ajustement deliberement non converge (factr = 1e13, maxit = 2).
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
verifier("usp_ajuster : champs de la condition du premier ordre et du multi-demarrages, sans 'foc'",
         {
           ch <- c("gradient", "gradient_projete", "hessien_gamma", "pas_newton_gamma",
                   "n_starts_optimum", "n_starts_echec")
           all(ch %in% names(f_t)) && !("foc" %in% names(f_t)) &&
             length(f_t$gradient) == 2L && length(f_t$gradient_projete) == 2L &&
             is.numeric(f_t$hessien_gamma) && is.numeric(f_t$pas_newton_gamma)
         })
verifier("usp_ajuster : champs = usp_condition_premier_ordre() au point estime",
         {
           cpo <- usp_condition_premier_ordre(f_i$delta, f_i$gamma, xi, yi)
           identical(cpo$gradient, f_i$gradient) &&
             identical(cpo$gradient_projete, f_i$gradient_projete) &&
             identical(cpo$hessien_gamma, f_i$hessien_gamma) &&
             identical(cpo$pas_newton_gamma, f_i$pas_newton_gamma)
         })
verifier("usp_condition_premier_ordre : H_gamma_gamma = difference centree (h = 1e-4) du gradient analytique, pas de Newton = -pg_gamma / H",
         {
           cpo <- usp_condition_premier_ordre(f_i$delta, f_i$gamma, xi, yi)
           h <- 1e-4
           H <- (usp_gradient(f_i$delta, f_i$gamma + h, xi, yi)[["gamma"]] -
                 usp_gradient(f_i$delta, f_i$gamma - h, xi, yi)[["gamma"]]) / (2 * h)
           identical(cpo$hessien_gamma, H) &&
             identical(cpo$pas_newton_gamma, -cpo$gradient_projete[["gamma"]] / H)
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
verifier("FOC a delta interieur (jeu simule) : |g_delta| <= 1e-4, |pas de Newton| <= 1e-6, OK",
         !f_i$delta_au_bord && abs(f_i$gradient[["delta"]]) <= 1e-4 &&
           abs(f_i$pas_newton_gamma) <= 1e-6 && f_i$hessien_gamma > 0 &&
           identical(ctrl(f_i, NOM_FOC)$verdict, "OK"))

## --- Echecs deliberes ------------------------------------------------------
# Critere d'acceptation de l'issue (|pas de Newton| > 1e-3) : ajustement a
# demarrage UNIQUE (0,5 ; ln 0,1), avec les bornes et l'objectif de
# usp_ajuster(). Mesure : |pas| de 7,3e-3 a 1,7e-2 sur les quatre cas. Avec
# la grille de 54 demarrages, le meilleur point non converge est plus proche
# de l'optimum (|pas| mesure 1,5e-5 a 4,0e-3) : le critere 1e-3 n'y vaut
# pas, mais les deux controles sortent ECHEC (assertion suivante).
fit_demarrage_unique <- function(xx, yy, controle) {
  o <- stats::optim(c(0.5, log(0.1)), usp_objectif, x = xx, y = yy, xbar = mean(xx),
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
    verifier(sprintf("Ajustement non converge (demarrage unique, factr = %g, maxit = %d, %s) : FOC ECHEC, |pas de Newton| > 1e-3",
                     ct$factr, ct$maxit, dat$nom),
             {
               f <- fit_demarrage_unique(dat$x, dat$y, ct)
               c1 <- ctrl(f, NOM_FOC)
               if (identical(c1$verdict, "ECHEC") && abs(f$pas_newton_gamma) > 1e-3) TRUE
               else sprintf("verdict %s, pas %.3e", c1$verdict, f$pas_newton_gamma)
             })
verifier("usp_ajuster non converge (grille complete ; factr = 1e13, puis maxit = 2) : les deux controles ECHEC",
         {
           ok <- TRUE
           for (ct in list(list(factr = 1e13, maxit = 500), list(factr = 1e5, maxit = 2)))
             for (dat in list(list(x, y), list(xi, yi))) {
               f <- usp_ajuster(dat[[1]], dat[[2]], controle = ct)
               cc <- usp_controles_numeriques(f)
               ok <- ok && all(vapply(cc, function(u) u$verdict, character(1)) == "ECHEC")
             }
           ok
         })
verifier("gamma force a la borne 3 : FOC ECHEC, 'maximum de vraisemblance non atteint'",
         {
           cpo <- usp_condition_premier_ordre(f_t$delta, 3, x, y)
           f <- utils::modifyList(f_t, cpo)
           f$gamma <- 3; f$kkt_au_moins_un <- FALSE
           c1 <- ctrl(f, NOM_FOC)
           !usp_kkt_satisfaite(cpo, 3) &&
           identical(c1$verdict, "ECHEC") &&
             grepl("maximum de vraisemblance non atteint", c1$detail, fixed = TRUE)
         })
verifier("gamma force a la borne -12 : FOC ECHEC, 'maximum de vraisemblance non atteint'",
         {
           cpo <- usp_condition_premier_ordre(f_t$delta, -12, x, y)
           f <- utils::modifyList(f_t, cpo)
           f$gamma <- -12; f$kkt_au_moins_un <- FALSE
           c1 <- ctrl(f, NOM_FOC)
           !usp_kkt_satisfaite(cpo, -12) &&
           identical(c1$verdict, "ECHEC") &&
             grepl("maximum de vraisemblance non atteint", c1$detail, fixed = TRUE)
         })
verifier("FOC : gradient non fini -> ECHEC",
         {
           f <- f_t; f$gradient[["gamma"]] <- NaN; f$gradient_projete[["gamma"]] <- NaN
           f$pas_newton_gamma <- NaN; f$kkt_au_moins_un <- FALSE
           identical(ctrl(f, NOM_FOC)$verdict, "ECHEC")
         })
verifier("FOC : courbure H_gamma_gamma <= 0 -> ECHEC",
         {
           f <- f_t; f$hessien_gamma <- -1; f$kkt_au_moins_un <- FALSE
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
verifier("Multi-demarrages : detail invariant quand n_starts_optimum_code0 varie (>= 1), 'oui' / 'non' selon la regle",
         {
           fa <- f_t; fa$n_starts_optimum_code0 <- 53L
           fb <- f_t; fb$n_starts_optimum_code0 <- 1L
           fc <- f_t; fc$n_starts_optimum_code0 <- 0L
           da <- ctrl(f_t, NOM_MULTI)$detail
           identical(da, ctrl(fa, NOM_MULTI)$detail) && identical(da, ctrl(fb, NOM_MULTI)$detail) &&
             grepl("au code de retour 0 d'optim() (convergence) : oui ;", da, fixed = TRUE) &&
             grepl("au code de retour 0 d'optim() (convergence) : non ;", ctrl(fc, NOM_MULTI)$detail, fixed = TRUE) &&
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
verifier("KKT en delta, cas d'audit au basculement du bord : OK des deux cotes",
         {
           xw <- x^3 / 1e4
           vv <- vapply(c(0.89559862669921131, 0.89559862669966606), function(l) {
             yy <- xw * (y / x) * exp(l * (1:8 - 4.5) / 10)
             ctrl(usp_ajuster(xw, yy), NOM_FOC)$verdict
           }, character(1))
           if (all(vv == "OK")) TRUE else paste("verdicts :", paste(vv, collapse = ", "))
         })

## --- Regle "au moins un demarrage a l'optimum satisfait KKT" (#22) ---------
# Decision du mainteneur du 24/09/2026 (constat 4 de la revue finale d'audit,
# specification d'actuary) : le verdict FOC ne depend plus du demarrage
# retenu. usp_kkt_satisfaite() juge un demarrage ; usp_ajuster() rend
# kkt_au_moins_un ; usp_controles_numeriques() en tire le verdict.
verifier("usp_kkt_satisfaite : TRUE au point estime a delta interieur (xi, yi)",
         isTRUE(usp_kkt_satisfaite(usp_condition_premier_ordre(f_i$delta, f_i$gamma, xi, yi),
                                   f_i$gamma)))
verifier("usp_kkt_satisfaite : FALSE si gamma sur une borne (3, -12), H <= 0 ou NaN, gradient NaN, |pas| = 1,5e-6 ou |pg_delta| = 2e-4",
         {
           c0 <- usp_condition_premier_ordre(f_i$delta, f_i$gamma, xi, yi)
           non <- function(cpo, g = f_i$gamma) identical(usp_kkt_satisfaite(cpo, g), FALSE)
           mod <- function(...) utils::modifyList(c0, list(...))
           cg <- c0; cg$gradient[["gamma"]] <- NaN; cg$gradient_projete[["gamma"]] <- NaN
           cd <- c0; cd$gradient_projete[["delta"]] <- 2e-4
           r <- c(borne3 = non(usp_condition_premier_ordre(f_i$delta, 3, xi, yi), 3),
                  borne12 = non(usp_condition_premier_ordre(f_i$delta, -12, xi, yi), -12),
                  gamma_borne_seul = non(c0, BORNES_GAMMA[2]),
                  H_neg = non(mod(hessien_gamma = -1)), H_nul = non(mod(hessien_gamma = 0)),
                  H_nan = non(mod(hessien_gamma = NaN)), grad_nan = non(cg),
                  pas_pos = non(mod(pas_newton_gamma = 1.5e-6)),
                  pas_neg = non(mod(pas_newton_gamma = -1.5e-6)),
                  pg_delta = non(cd))
           if (all(r)) TRUE else paste("non FALSE :", paste(names(r)[!r], collapse = ", "))
         })
verifier("usp_kkt_satisfaite : conditions jugees sur le meme point (pas OK et |pg_delta| = 2e-4 -> FALSE)",
         {
           c0 <- usp_condition_premier_ordre(f_i$delta, f_i$gamma, xi, yi)
           c0$pas_newton_gamma <- 1e-8; c0$gradient_projete[["delta"]] <- 2e-4
           identical(usp_kkt_satisfaite(c0, f_i$gamma), FALSE)
         })
verifier("usp_ajuster : kkt_au_moins_un logique de longueur 1, TRUE sur (x, y) et (xi, yi)",
         is.logical(f_t$kkt_au_moins_un) && length(f_t$kkt_au_moins_un) == 1L &&
           isTRUE(f_t$kkt_au_moins_un) && isTRUE(f_i$kkt_au_moins_un))
# Reference independante : les 54 optim() refaits dans le test (meme grille,
# meme reglage), la condition ecrite a la main sur les champs de
# usp_condition_premier_ordre(), sans usp_kkt_satisfaite().
kkt_reference <- function(xx, yy, controle = list(factr = 1e5, maxit = 500)) {
  st <- expand.grid(delta = seq(0, 1, length.out = 9),
                    gamma = log(c(0.01, 0.03, 0.06, 0.10, 0.20, 0.40)))
  fits <- lapply(seq_len(nrow(st)), function(i) try(stats::optim(
    c(st$delta[i], st$gamma[i]), usp_objectif, x = xx, y = yy, xbar = mean(xx),
    method = "L-BFGS-B", lower = c(0, BORNES_GAMMA[1]), upper = c(1, BORNES_GAMMA[2]),
    control = controle), silent = TRUE))
  fits <- fits[!vapply(fits, inherits, logical(1), "try-error")]
  v <- vapply(fits, function(o) o$value, numeric(1))
  opt <- fits[abs(v - min(v)) < 1e-6]
  any(vapply(opt, function(o) {
    d <- o$par[1]; g <- o$par[2]
    cp <- usp_condition_premier_ordre(d, g, xx, yy)
    all(is.finite(c(cp$gradient, cp$gradient_projete))) &&
      g > BORNES_GAMMA[1] + 1e-6 && g < BORNES_GAMMA[2] - 1e-6 &&
      is.finite(cp$hessien_gamma) && cp$hessien_gamma > 0 &&
      is.finite(cp$pas_newton_gamma) && abs(cp$pas_newton_gamma) <= 1e-6 &&
      abs(cp$gradient_projete[["delta"]]) <= 1e-4
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
verifier("Verdict FOC = kkt_au_moins_un : ECHEC si FALSE bien que le retenu satisfasse ; OK si TRUE bien que le retenu ait |pas| = 1,5e-6",
         {
           fa <- f_t; fa$kkt_au_moins_un <- FALSE
           fb <- f_i; fb$pas_newton_gamma <- 1.5e-6
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
verifier("Detail FOC invariant quand le pas de Newton et pg_delta du retenu franchissent les reperes (kkt_au_moins_un constant) ; regle et oui / non imprimes",
         {
           d0 <- ctrl(f_i, NOM_FOC)$detail
           fa <- f_i; fa$pas_newton_gamma <- 1.5e-6
           fb <- f_i; fb$pas_newton_gamma <- -1.5e-6
           fc <- f_i; fc$gradient_projete[["delta"]] <- 2e-4; fc$gradient[["delta"]] <- 2e-4
           fn <- f_i; fn$kkt_au_moins_un <- FALSE
           dt <- ctrl(f_t, NOM_FOC)$detail
           identical(d0, ctrl(fa, NOM_FOC)$detail) && identical(d0, ctrl(fb, NOM_FOC)$detail) &&
             identical(d0, ctrl(fc, NOM_FOC)$detail) &&
             !any(grepl("sous le repere|au-dessus de|Kuhn-Tucker satisfaite|Kuhn-Tucker violee",
                        c(d0, dt))) &&
             all(grepl("au moins un demarrage a l'optimum", c(d0, dt), fixed = TRUE)) &&
             grepl(sprintf("<= %s : oui (M15 etendue a KKT)", engine_fmt_repere(REP_GD_KKT)),
                   d0, fixed = TRUE) &&
             grepl(sprintf("<= %s : non (M15 etendue a KKT)", engine_fmt_repere(REP_GD_KKT)),
                   ctrl(fn, NOM_FOC)$detail, fixed = TRUE)
         })

## --- Mineurs d'audit ---------------------------------------------------------
verifier("gamma sur une borne : pas de Newton et stat du controle NA",
         {
           ok <- TRUE
           for (gb in BORNES_GAMMA) {
             cpo <- usp_condition_premier_ordre(f_t$delta, gb, x, y)
             f <- utils::modifyList(f_t, cpo); f$gamma <- gb
             ok <- ok && is.na(cpo$pas_newton_gamma) && is.na(ctrl(f, NOM_FOC)$stat)
           }
           ok
         })
verifier("Libelle : gradient non fini et courbure non finie distingues",
         {
           fg <- f_t; fg$gradient[["gamma"]] <- NaN; fg$gradient_projete[["gamma"]] <- NaN
           fg$pas_newton_gamma <- NA_real_
           fh <- f_t; fh$hessien_gamma <- NaN; fh$pas_newton_gamma <- NA_real_
           fh$kkt_au_moins_un <- FALSE
           dg <- ctrl(fg, NOM_FOC)$detail; dh <- ctrl(fh, NOM_FOC)$detail
           grepl("Gradient non fini", dg, fixed = TRUE) && !grepl("Courbure non finie", dg, fixed = TRUE) &&
             grepl("Courbure non finie", dh, fixed = TRUE) && !grepl("Gradient non fini", dh, fixed = TRUE) &&
             identical(ctrl(fh, NOM_FOC)$verdict, "ECHEC")
         })
verifier("Volumes constants : le detail FOC dit delta non identifie (#58), sans 'AU BORD' seul",
         {
           d <- ctrl(usp_ajuster(rep(100, 8), y), NOM_FOC)$detail
           grepl("non identifie", d, fixed = TRUE) && grepl("#58", d, fixed = TRUE) &&
             !grepl("AU BORD", d, fixed = TRUE)
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
verifier("usp_controles_numeriques : stat = pas de Newton (FOC) et part kappa (multi-demarrages)",
         {
           cc <- usp_controles_numeriques(f_i)
           identical(cc[[1]]$stat, f_i$pas_newton_gamma) &&
             identical(cc[[2]]$stat, f_i$part_starts_convergents)
         })
verifier("Detail FOC : reperes REP_PAS_KKT (M9) et REP_GD_KKT, plancher ndeps, regime de delta nomme",
         {
           dt <- ctrl(f_t, NOM_FOC)$detail; di <- ctrl(f_i, NOM_FOC)$detail
           all(vapply(c(engine_fmt_repere(REP_PAS_KKT), "M9", "ndeps", engine_fmt_repere(REP_GD_KKT)),
                      grepl, logical(1), x = di, fixed = TRUE)) &&
             grepl("AU BORD", dt, fixed = TRUE) && grepl("interieur", di, fixed = TRUE)
         })
## --- Reperes : constantes du moteur et libelles (audit M1, issue #22) -------
# Les reperes sont definis une seule fois en tete du moteur (TOL_OPTIMUM,
# REP_PAS_KKT, REP_GD_KKT) et imprimes dans les libelles par
# engine_fmt_repere(). Reference : les valeurs des decisions M15/M25
# (1e-6), M17 (1e-6) et M16 (1e-4) ; puis propriete de liaison : une autre
# valeur des constantes modifie la decision ET le libelle, qui ne peut donc
# pas rester perime.
verifier("Reperes : TOL_OPTIMUM = 1e-6 (M15, M25), REP_PAS_KKT = 1e-6 (M17), REP_GD_KKT = 1e-4 (M16), ecrits 1e-6 / 1e-4",
         identical(TOL_OPTIMUM, 1e-6) && identical(REP_PAS_KKT, 1e-6) && identical(REP_GD_KKT, 1e-4) &&
           identical(engine_fmt_repere(c(1e-6, 1e-4, 1e-10, 2.5e-7)), c("1e-6", "1e-4", "1e-10", "2.5e-7")) &&
           identical(formals(usp_kkt_satisfaite)$rep_pas, quote(REP_PAS_KKT)) &&
           identical(formals(usp_kkt_satisfaite)$rep_gd, quote(REP_GD_KKT)))
verifier("Libelles FOC et multi-demarrages : chaque repere imprime est la valeur formatee de sa constante",
         {
           lib <- function() {
             cc <- usp_controles_numeriques(f_i)
             c(foc = cc[[1]]$detail, multi = cc[[2]]$detail)
           }
           attendu <- function(d) {
             o <- engine_fmt_repere(TOL_OPTIMUM); p <- engine_fmt_repere(REP_PAS_KKT)
             g <- engine_fmt_repere(REP_GD_KKT)
             all(vapply(c(sprintf("objectif a moins de %s du minimum", o),
                          sprintf("|pg_gamma / H_gamma_gamma| <= %s (gamma interieur", p),
                          sprintf("|pg_delta| <= %s : ", g),
                          sprintf("Repere %s ancre sur M9", p),
                          sprintf("Repere %s : regle unique", g)),
                        grepl, logical(1), x = d[["foc"]], fixed = TRUE)) &&
               grepl(sprintf("demarrage(s) a moins de %s de l'objectif minimal", o),
                     d[["multi"]], fixed = TRUE)
           }
           d0 <- lib()
           ok0 <- attendu(d0)
           # Autres valeurs des constantes (environnement de definition du
           # moteur), restaurees a la sortie
           env <- environment(usp_controles_numeriques)
           sauve <- mget(c("TOL_OPTIMUM", "REP_PAS_KKT", "REP_GD_KKT"), envir = env)
           on.exit(list2env(sauve, envir = env), add = TRUE)
           assign("TOL_OPTIMUM", 3e-7, envir = env)
           assign("REP_PAS_KKT", 2e-6, envir = env)
           assign("REP_GD_KKT", 5e-5, envir = env)
           d1 <- lib()
           cpo <- usp_condition_premier_ordre(f_i$delta, f_i$gamma, xi, yi)
           cpo$pas_newton_gamma <- 1.5e-6
           kkt_suit <- isTRUE(usp_kkt_satisfaite(cpo, f_i$gamma))
           ok1 <- attendu(d1) && !any(grepl("1e-6|1e-4", d1)) && kkt_suit
           list2env(sauve, envir = env)
           if (ok0 && ok1 && identical(lib(), d0)) TRUE
           else sprintf("libelle initial conforme %s, apres changement %s, KKT suit REP_PAS_KKT %s",
                        ok0, attendu(d1), kkt_suit)
         })
verifier("Detail multi-demarrages : convention minimale nommee, kappa sans repere 0.5",
         {
           d <- ctrl(f_t, NOM_MULTI)$detail
           grepl("convention minimale", d, fixed = TRUE) && grepl("sans reference", d, fixed = TRUE) &&
             !grepl("0.5", d, fixed = TRUE) && !grepl("repere conventionnel", d, fixed = TRUE)
         })
# Regle de stabilite inter-plateformes : aucune chaine ne restitue une
# valeur d'optimiseur. Une perturbation de gamma de 1e-9 (au-dela de la derive
# poste / CI) change g, pg, H et le pas de Newton sans changer le detail.
verifier("Details des deux controles invariants a une perturbation de gamma de 1e-9 (aucune mantisse d'optimiseur)",
         {
           f2 <- utils::modifyList(f_i, usp_condition_premier_ordre(f_i$delta, f_i$gamma + 1e-9, xi, yi))
           f2$gamma <- f_i$gamma + 1e-9
           a <- usp_controles_numeriques(f_i); b <- usp_controles_numeriques(f2)
           f2$pas_newton_gamma != f_i$pas_newton_gamma &&
             f2$gradient_projete[["delta"]] != f_i$gradient_projete[["delta"]] &&
             identical(a[[1]]$detail, b[[1]]$detail) && identical(a[[2]]$detail, b[[2]]$detail)
         })

## --- Place dans le resultat de run_engine() --------------------------------
res <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II", B = 99)
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
