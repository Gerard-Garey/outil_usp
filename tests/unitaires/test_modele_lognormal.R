###############################################################################
#  tests/unitaires/test_modele_lognormal.R  --  MODELE LOGNORMAL (SECTIONS B, C)
#
#  usp_pi(), usp_noyau(), usp_objectif(), usp_ajuster(), usp_ajuster_rapide(),
#  usp_simuler(), usp_regime().
#  References :
#    - transcription litterale, ecrite ici independamment du moteur, des
#      formules de l'annexe XVII, section B, par. 5 et 6 (JOUE L 12/273-274) ;
#    - vraisemblance lognormale calculee par stats::dlnorm ;
#    - maximum de vraisemblance independant (optimisation a 3 parametres
#      delta, gamma, ln beta, multi-demarrages) ;
#    - forme fermee lorsque pi_t est constant (delta = 1 ou x constant) :
#      ln(y/x) ~ N(m, s^2) i.i.d., d'ou sigma = sqrt(exp(s^2) - 1) exp(m + s^2/2)
#      avec m, s^2 moyenne et variance (divisee par T) de ln(y/x).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_modele_lognormal.R")

# Jeu de test du depot (delta estime au bord, delta = 1)
x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
# Jeu simule sous le modele (delta = 0,5, gamma = ln 0,12, beta = 0,7, graine 2),
# dont l'estimation de delta est interieure a [0, 1].
xi <- c(50, 80, 120, 200, 300, 150, 90, 60)
yi <- c(29.92, 56.9, 101.25, 123.06, 207.23, 105.91, 68.59, 40.05)

## --- Transcription litterale du reglement (section B, par. 5 et 6) ---------
reg_pi <- function(d, g, x) 1 / log(1 + ((1 - d) * mean(x) / x + d) * exp(2 * g))
reg_sigma <- function(d, g, x, y) {
  p <- reg_pi(d, g, x)
  exp(g + (0.5 * length(x) + sum(p * log(y / x))) / sum(p))
}
reg_objectif <- function(d, g, x, y) {
  p <- reg_pi(d, g, x)
  sum(p * (log(y / x) + 1 / (2 * p) + g - log(reg_sigma(d, g, x, y)))^2) - sum(log(p))
}
# -2 log-vraisemblance lognormale : Y_t ~ LN(ln(beta x_t) - 1/(2 pi_t), 1/pi_t),
# de sorte que E[Y_t] = beta x_t (proportionnalite, B(2)(g)(i)).
m2ll <- function(d, g, lb, x, y) {
  p <- reg_pi(d, g, x)
  -2 * sum(stats::dlnorm(y, meanlog = lb + log(x) - 1 / (2 * p), sdlog = 1 / sqrt(p), log = TRUE))
}
grille <- expand.grid(d = c(0, 0.3, 0.664, 1), g = c(-3, -2.32, -1.9, -1))
verifier("usp_pi = pi_t du reglement (par. 5(d)), 16 points (delta, gamma)",
         all(vapply(seq_len(nrow(grille)), function(k)
           isTRUE(proche(usp_pi(grille$d[k], grille$g[k], xi), reg_pi(grille$d[k], grille$g[k], xi),
                         rel = 1e-13)), logical(1))))
verifier("usp_noyau : sigma(delta, gamma) = fonction d'ecart type du reglement (par. 5)",
         all(vapply(seq_len(nrow(grille)), function(k)
           isTRUE(proche(usp_noyau(grille$d[k], grille$g[k], xi, yi)$sigma,
                         reg_sigma(grille$d[k], grille$g[k], xi, yi), rel = 1e-12)), logical(1))))
verifier("usp_noyau : objectif = montant a minimiser du reglement (par. 6)",
         all(vapply(seq_len(nrow(grille)), function(k)
           isTRUE(proche(usp_noyau(grille$d[k], grille$g[k], xi, yi)$obj,
                         reg_objectif(grille$d[k], grille$g[k], xi, yi), rel = 1e-11, abs = 1e-11)),
           logical(1))))
verifier("usp_noyau : objectif = -2 log-vraisemblance lognormale (dlnorm) a constante pres",
         all(vapply(seq_len(nrow(grille)), function(k) {
           kk <- usp_noyau(grille$d[k], grille$g[k], xi, yi)
           isTRUE(proche(kk$obj + 8 * log(2 * pi) + 2 * sum(log(yi)),
                         m2ll(grille$d[k], grille$g[k], kk$ln_beta, xi, yi), rel = 1e-11))
         }, logical(1))))
verifier("usp_noyau : ln(beta) maximise la vraisemblance a (delta, gamma) fixes",
         {
           kk <- usp_noyau(0.3, -2, xi, yi)
           o <- stats::optimize(function(lb) m2ll(0.3, -2, lb, xi, yi), c(-3, 2), tol = 1e-12)
           isTRUE(proche(kk$ln_beta, o$minimum, abs = 1e-6))
         })
verifier("usp_noyau : residus standardises z = v sqrt(pi)",
         {
           kk <- usp_noyau(0.3, -2, xi, yi)
           isTRUE(proche(kk$z, (log(yi / xi) + 1 / (2 * kk$pi) - kk$ln_beta) * sqrt(kk$pi), rel = 1e-12))
         })
verifier("usp_objectif : penalite hors de [0, 1] pour delta",
         usp_objectif(c(-0.01, -2), xi, yi, mean(xi)) == 1e12 &&
         usp_objectif(c(1.01, -2), xi, yi, mean(xi)) == 1e12)

## --- usp_ajuster : maximum de vraisemblance ---------------------------------
mv_independant <- function(x, y) {
  best <- NULL
  for (d0 in c(0.05, 0.5, 0.95)) for (g0 in log(c(0.02, 0.1, 0.3))) {
    f <- stats::optim(c(d0, g0, log(mean(y / x))), function(p) m2ll(p[1], p[2], p[3], x, y),
                      method = "L-BFGS-B", lower = c(0, -12, -5), upper = c(1, 3, 5),
                      control = list(factr = 1e3, maxit = 2000))
    if (is.null(best) || f$value < best$value) best <- f
  }
  list(delta = best$par[1], gamma = best$par[2], sigma = exp(best$par[2] + best$par[3]),
       m2ll = best$value)
}
f_t <- usp_ajuster(x, y); f_i <- usp_ajuster(xi, yi)
for (cas in list(list(nom = "jeu de test (delta au bord)", f = f_t, x = x, y = y),
                 list(nom = "jeu a delta interieur", f = f_i, x = xi, y = yi))) {
  m <- mv_independant(cas$x, cas$y)
  verifier(sprintf("usp_ajuster = maximum de vraisemblance independant, %s", cas$nom),
           isTRUE(proche(cas$f$delta, m$delta, abs = 1e-4)) &&
           isTRUE(proche(cas$f$gamma, m$gamma, abs = 1e-4)) &&
           isTRUE(proche(cas$f$sigma, m$sigma, rel = 1e-5)))
  verifier(sprintf("usp_ajuster : objectif minimal <= optimum independant, %s", cas$nom),
           cas$f$obj_min + length(cas$x) * log(2 * pi) + 2 * sum(log(cas$y)) <= m$m2ll + 1e-7)
  verifier(sprintf("usp_ajuster : condition du premier ordre et convergence, %s", cas$nom),
           cas$f$foc < 1e-8 && cas$f$convergence == 0 && cas$f$part_starts_convergents >= 0.5)
}
verifier("usp_ajuster : delta au bord signale (jeu de test, delta = 1), non signale (delta = 0,66)",
         isTRUE(f_t$delta_au_bord) && f_t$delta > 1 - 1e-6 &&
         !isTRUE(f_i$delta_au_bord) && f_i$delta > 0.05 && f_i$delta < 0.95)
forme_fermee <- function(x, y) {
  r <- log(y / x); m <- mean(r); s2 <- mean((r - m)^2)
  sqrt(exp(s2) - 1) * exp(m + s2 / 2)
}
verifier("delta = 1 : sigma = forme fermee lognormale i.i.d. (jeu de test)",
         proche(f_t$sigma, forme_fermee(x, y), rel = 1e-6))
verifier("delta = 1 : moyenne simple des z nulle par construction (cf. issue #3)",
         abs(mean(f_t$z)) < 1e-12)
# delta n'est pas identifie (objectif plat en delta) : la valeur rendue par
# l'optimiseur est un artefact, seule la constance de pi_t (par les volumes)
# est garantie et verifiee (avis actuary, issue #31).
verifier("x constant : sigma = forme fermee ; delta non identifie (objectif plat), pi_t constant par les volumes",
         {
           f <- usp_ajuster(rep(100, 8), y)
           k0 <- usp_noyau(0, f$gamma, rep(100, 8), y); k1 <- usp_noyau(1, f$gamma, rep(100, 8), y)
           isTRUE(proche(f$sigma, forme_fermee(rep(100, 8), y), rel = 1e-6)) &&
             isTRUE(proche(k0$obj, k1$obj, rel = 1e-12)) &&
             isTRUE(usp_regime(f$delta, f$x)$pi_constant)
         })
verifier("Donnees exactement proportionnelles (y = 0,7 x) : beta = 0,7 et sigma ~ 0",
         {
           f <- usp_ajuster(xi, 0.7 * xi)
           isTRUE(proche(f$beta, 0.7, rel = 1e-8)) && f$sigma < 1e-4
         })

## --- Invariances ------------------------------------------------------------
verifier("Invariance : (x, y) -> (a x, a y) laisse delta, gamma, sigma inchanges",
         {
           f <- usp_ajuster(1000 * xi, 1000 * yi)
           isTRUE(proche(f$delta, f_i$delta, abs = 1e-5)) &&
             isTRUE(proche(f$gamma, f_i$gamma, abs = 1e-5)) && isTRUE(proche(f$sigma, f_i$sigma, rel = 1e-6))
         })
verifier("Invariance : y -> b y multiplie beta et sigma par b, delta et gamma inchanges",
         {
           f <- usp_ajuster(xi, 1.5 * yi)
           isTRUE(proche(f$delta, f_i$delta, abs = 1e-5)) &&
             isTRUE(proche(f$sigma, 1.5 * f_i$sigma, rel = 1e-6)) &&
             isTRUE(proche(f$beta, 1.5 * f_i$beta, rel = 1e-6))
         })
verifier("Invariance : permutation des annees sans effet sur l'estimation",
         {
           o <- c(5, 2, 8, 1, 7, 3, 6, 4)
           f <- usp_ajuster(xi[o], yi[o])
           isTRUE(proche(f$delta, f_i$delta, abs = 1e-5)) && isTRUE(proche(f$sigma, f_i$sigma, rel = 1e-6))
         })
verifier("usp_ajuster_rapide depuis l'optimum : meme solution",
         {
           f <- usp_ajuster_rapide(xi, yi, f_i$delta, f_i$gamma)
           isTRUE(proche(f$sigma, f_i$sigma, rel = 1e-6))
         })

## --- usp_simuler : loi simulee = modele ajuste --------------------------------
# 20 000 replications (graine fixe) : E[Y_t / x_t] = beta (tolerance 5
# erreurs-types) et Var(ln Y_t) = 1 / pi_t (tolerance relative 5 %, erreur-type
# relative ~ 1 %).
verifier("usp_simuler : E[Y_t/x_t] = beta et Var(ln Y_t) = 1/pi_t",
         {
           set.seed(301)
           S <- t(replicate(20000, usp_simuler(f_i)))
           R <- sweep(S, 2, f_i$x, "/")
           se <- apply(R, 2, stats::sd) / sqrt(nrow(R))
           all(abs(colMeans(R) - f_i$beta) <= 5 * se) &&
             isTRUE(proche(apply(log(S), 2, stats::var), 1 / f_i$pi, rel = 0.05))
         })

# Constat d'audit : avec une valeur infinie (acceptee par la validation, voir
# test_controles_entree.R), l'objectif vaut la penalite 1e12 en tout point ;
# le premier demarrage est retenu comme optimum et sigma = Inf est renvoye
# sans erreur.
# Issue #33 (defaut releve par audit, repris de l'issue #7)
## --- usp_regime : tolerance unique delta au bord / pi_t constant (issue #31) --
# pi_t est constant en t si et seulement si delta = 1 ou x_t constant ; les
# deux drapeaux partagent TOL_DELTA_BORD (seuils a tau/2 et 2 tau de part et
# d'autre de chaque frontiere).
tau <- TOL_DELTA_BORD
regime <- function(d, xx = x) unlist(usp_regime(d, xx))
verifier("TOL_DELTA_BORD : tolerance unique, egale a 1e-6",
         identical(TOL_DELTA_BORD, 1e-6))
verifier("usp_regime : delta = 1 au bord et pi_t constant ; delta = 0 au bord, pi_t variable",
         identical(regime(1)[c("delta_au_bord", "pi_constant")], c(delta_au_bord = TRUE, pi_constant = TRUE)) &&
         identical(regime(0)[c("delta_au_bord", "pi_constant")], c(delta_au_bord = TRUE, pi_constant = FALSE)))
verifier("usp_regime : frontiere delta = 1 - tau (1 - tau/2 : bord et constant ; 1 - 2 tau : ni l'un ni l'autre)",
         identical(regime(1 - tau / 2)[c("delta_au_bord", "pi_constant")], c(delta_au_bord = TRUE, pi_constant = TRUE)) &&
         identical(regime(1 - 2 * tau)[c("delta_au_bord", "pi_constant")], c(delta_au_bord = FALSE, pi_constant = FALSE)))
verifier("usp_regime : frontiere delta = tau (tau/2 : bord, pi_t variable ; 2 tau : ni l'un ni l'autre)",
         identical(regime(tau / 2)[c("delta_au_bord", "pi_constant")], c(delta_au_bord = TRUE, pi_constant = FALSE)) &&
         identical(regime(2 * tau)[c("delta_au_bord", "pi_constant")], c(delta_au_bord = FALSE, pi_constant = FALSE)))
# Volumes perturbes : etendue relative tau/2 (constants) et 2 tau (variables).
# Une etendue relative exactement egale a tau tombe sur la frontiere et se
# decide a l'arrondi pres (mesure : 1,0000000000332 tau -> FALSE).
verifier("usp_regime : volumes constants (delta = 0,37) -> pi_t constant ; tolerance relative tau sur x",
         {
           alt <- rep(c(-1, 1), 4)
           identical(regime(0.37, rep(100, 8)),
                     c(delta_au_bord = FALSE, volumes_constants = TRUE, pi_constant = TRUE,
                       pi_constant_exact = TRUE, delta_dans_bande = FALSE,
                       volumes_dans_bande = FALSE)) &&
             isTRUE(usp_regime(0.37, 100 * (1 + alt * tau / 4))$volumes_constants) &&
             !isTRUE(usp_regime(0.37, 100 * (1 + alt * tau))$volumes_constants)
         })
# Revue de la PR #57 : constance exacte (delta == 1 ou volumes egaux) vs
# constance a la tolerance pres, qui commande le libelle des diagnostics.
verifier("usp_regime : pi_constant_exact vrai a delta = 1 ou volumes egaux, faux dans la bande de tolerance",
         {
           alt <- rep(c(-1, 1), 4)
           isTRUE(usp_regime(1, x)$pi_constant_exact) &&
             isTRUE(usp_regime(0.37, rep(100, 8))$pi_constant_exact) &&
             !isTRUE(usp_regime(1 - tau / 2, x)$pi_constant_exact) &&
             !isTRUE(usp_regime(0.37, 100 * (1 + alt * tau / 4))$pi_constant_exact) &&
             !isTRUE(usp_regime(0, x)$pi_constant_exact)
         })
verifier("usp_regime : delta_dans_bande vrai a 1 - tau/2, faux a 1 et a 1 - 2 tau ; volumes_dans_bande",
         {
           alt <- rep(c(-1, 1), 4)
           isTRUE(usp_regime(1 - tau / 2, x)$delta_dans_bande) &&
             !isTRUE(usp_regime(1, x)$delta_dans_bande) &&
             !isTRUE(usp_regime(1 - 2 * tau, x)$delta_dans_bande) &&
             isTRUE(usp_regime(0.37, 100 * (1 + alt * tau / 4))$volumes_dans_bande) &&
             !isTRUE(usp_regime(0.37, rep(100, 8))$volumes_dans_bande) &&
             !isTRUE(usp_regime(0.37, 100 * (1 + alt * tau))$volumes_dans_bande)
         })
verifier("usp_regime : a delta = 1 - tau, etendue relative des pi_t <= 2 tau etendue(xbar / x_t)",
         {
           p <- usp_pi(1 - tau, f_t$gamma, x)
           diff(range(p)) / mean(p) <= 2 * tau * diff(range(mean(x) / x))
         })
verifier("usp_ajuster : aucun champ ajoute a l'ajustement (structure des references)",
         identical(names(f_t), c("pi", "ln_beta", "beta", "v", "z", "sigma", "obj",
                                 "delta", "gamma", "T", "x", "y", "xbar", "foc",
                                 "obj_min", "convergence", "part_starts_convergents",
                                 "delta_au_bord")))
echec_attendu("usp_ajuster : erreur explicite si l'objectif n'est fini en aucun point",
              "constat audit : y[3] = Inf -> sigma = Inf, obj_min = 1e12, sans erreur",
              leve_erreur(usp_ajuster(x, replace(y, 3, Inf))))

fin_fichier()
