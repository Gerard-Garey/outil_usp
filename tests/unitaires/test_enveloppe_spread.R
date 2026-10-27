###############################################################################
#  tests/unitaires/test_enveloppe_spread.R  --  ENVELOPPE DE SIMULATION DU
#  GRAPHIQUE DISPERSION-NIVEAU (issue #306 ; specification
#  docs/specifications/fn-incertitude-bootstrap.md, par. 1.4 a 1.6 et 8 ;
#  decisions du mainteneur du 27/10/2026 : Q-D1-Fn-1 (A), bandes ponctuelle et
#  simultanee a 90 % tirees de z_boot ; Q-D1-Fn-2, regle de rang de l'eq.
#  (4.17) de Davison et Hinkley ; Q-D1-Fn-3, bande inconditionnelle)
#
#  Constantes SPREAD_LOWESS_F et SPREAD_LOWESS_ITER, engine_rang_simultane_dh(),
#  engine_enveloppe_spread(), champ plots_data$spread_enveloppe de
#  engine_plots_data(), et plot_spread() (R/display_helpers.R, base R et
#  plotly).
#  References independantes :
#    - k* et taux de sortie de l'eq. (4.17) calcules a la main sur des
#      matrices de rangs connus, et recalcules sur les cas reels par une
#      ecriture independante (rangs "min" et "max" de rank(), sans balayage
#      des bornes) ;
#    - quantiles de type 7 recalcules par interpolation en clair ;
#    - si le paquet boot est installe : bornes de boot::envelope().
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_enveloppe_spread.R")

# J1 : jeu de test du depot (tests/donnees/donnees_ln.csv)
x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
GRAINE <- 20260831
f1 <- usp_ajuster(x, y); T1 <- length(x)
prof1 <- usp_profil(f1)

# Courbes simulees recalculees (lowess() aux valeurs par defaut de R).
courbes <- function(zb, xx = x) {
  zb <- zb[apply(is.finite(zb), 1, all), , drop = FALSE]
  t(apply(zb, 1, function(z) stats::lowess(xx, sqrt(abs(z)))$y))
}
# Taux de sortie de l'eq. (4.17) au rang k, ecriture independante : une
# ligne sort au rang k si, dans une colonne, son rang "min" est <= k ou son
# rang "max" est >= B + 1 - k (ex aequo compris).
taux_417 <- function(L, k) {
  B <- nrow(L)
  rmin <- apply(L, 2, rank, ties.method = "min")
  rmax <- apply(L, 2, rank, ties.method = "max")
  m <- pmin(apply(rmin, 1, min), B + 1 - apply(rmax, 1, max))
  mean(m <= k)
}
k_etoile_417 <- function(L) {
  ks <- seq_len(nrow(L) %/% 2)
  ok <- ks[vapply(ks, function(k) taux_417(L, k) <= 0.10, logical(1))]
  if (length(ok)) max(ok) else NA_integer_
}
# Quantile de type 7 en clair : h = 1 + (n - 1) p, interpolation entre les
# statistiques d'ordre floor(h) et floor(h) + 1.
q7 <- function(v, p) {
  v <- sort(v); n <- length(v); h <- 1 + (n - 1) * p; lo <- floor(h)
  if (lo >= n) return(v[n])
  v[lo] + (h - lo) * (v[lo + 1] - v[lo])
}

# --- Constantes du lissage et courbe observee --------------------------------
verifier("SPREAD_LOWESS_F = 2/3 et SPREAD_LOWESS_ITER = 3L, identiques aux defauts de stats::lowess()",
         identical(SPREAD_LOWESS_F, 2/3) && identical(SPREAD_LOWESS_ITER, 3L) &&
           identical(SPREAD_LOWESS_F, eval(formals(stats::lowess)$f)) &&
           identical(SPREAD_LOWESS_ITER, eval(formals(stats::lowess)$iter)))
b199 <- usp_bootstrap(f1, B = 199, seed = GRAINE)
pd199 <- engine_plots_data(f1, b199, prof1)
verifier("Courbe observee spread_lisse identical() a lowess(x, sqrt(|z|)) aux arguments par defaut (avant le passage aux constantes)",
         {
           lo <- stats::lowess(x, sqrt(abs(f1$z)))
           identical(pd199$spread_lisse, data.frame(x = lo$x, y = lo$y))
         })

# --- engine_rang_simultane_dh() : jeux de rangs connus -----------------------
# B = 60, deux colonnes de rangs 1:60 sur les memes lignes : 2k lignes sortent
# au rang k, taux 2k/60 ; k* = 3 (taux 6/60 = 0,10), k = 4 donne 8/60.
L60 <- cbind(1:60, 1:60) + 0
r60 <- engine_rang_simultane_dh(L60)
verifier("(4.17) rangs connus, B = 60, colonnes alignees : k* = 3, taux 0,10, bornes Sc[3, ] = 3 et Sc[58, ] = 58",
         identical(r60$k, 3L) && identical(r60$taux, 6 / 60) &&
           identical(r60$sim_bas, c(3, 3)) && identical(r60$sim_haut, c(58, 58)) &&
           identical(taux_417(L60, 3), 0.10) && taux_417(L60, 4) > 0.10)
verifier("(4.17) contre la regle stricte du QQ-plot sur le meme jeu : la regle stricte admet k = 4 (taux 6/60), (4.17) s'arrete a k = 3",
         {
           strict <- function(k) mean(rowSums(L60 < rep(c(k, k), each = 60) |
                                              L60 > rep(c(61 - k, 61 - k), each = 60)) > 0)
           identical(strict(4), 0.10) && strict(5) > 0.10 && identical(r60$k, 3L)
         })
# B = 40, extremes de la colonne 2 sur d'autres lignes que ceux de la
# colonne 1 : a k = 1, lignes 1, 40 (colonne 1) et 3, 38 (colonne 2), 4/40 ;
# a k = 2, lignes 1 a 4 et 37 a 40, 8/40.
L40 <- cbind(1:40, c(3, 4, 1, 2, 5:36, 39, 40, 37, 38)) + 0
r40 <- engine_rang_simultane_dh(L40)
verifier("(4.17) rangs connus, B = 40, extremes croises : k* = 1, taux 4/40, bornes Sc[1, ] et Sc[40, ]",
         identical(r40$k, 1L) && identical(r40$taux, 4 / 40) &&
           identical(r40$sim_bas, c(1, 1)) && identical(r40$sim_haut, c(40, 40)) &&
           identical(taux_417(L40, 1), 0.10) && identical(taux_417(L40, 2), 0.20))
verifier("(4.17) aucun k admissible : B = 10 (taux 2/10 a k = 1 sur colonnes alignees ; 4/10 sur extremes croises) -> k, taux et bornes NA",
         {
           a <- engine_rang_simultane_dh(cbind(1:10, 1:10) + 0)
           b <- engine_rang_simultane_dh(cbind(1:10, c(2, 1, 3:8, 10, 9)) + 0)
           all(vapply(list(a, b), function(r)
             identical(r$k, NA_integer_) && identical(r$taux, NA_real_) &&
               all(is.na(r$sim_bas)) && all(is.na(r$sim_haut)), logical(1))) &&
             taux_417(cbind(1:10, 1:10), 1) == 0.2
         })
# Ex aequo : trois lignes ex aequo au minimum de la colonne sortent toutes a
# k = 1 (valeur <= Sc[1, ]), avec la ligne du maximum : 4/40 ; a k = 2,
# Sc[2, ] vaut encore 1 et la ligne de 39 s'ajoute : 5/40.
L_ea <- cbind(c(1, 1, 1, 4:40)) + 0
r_ea <- engine_rang_simultane_dh(L_ea)
verifier("(4.17) ex aequo au minimum (trois lignes a 1, B = 40, T = 1) : toutes sortent a k = 1, k* = 1, taux 4/40",
         identical(r_ea$k, 1L) && identical(r_ea$taux, 4 / 40) &&
           identical(r_ea$sim_bas, 1) && identical(r_ea$sim_haut, 40) &&
           identical(taux_417(L_ea, 1), 0.10) && identical(taux_417(L_ea, 2), 5 / 40))
verifier("(4.17) ex aequo rendant k = 1 non admissible (cinq lignes a 1, B = 40) : taux 6/40 a k = 1, k* NA",
         {
           r <- engine_rang_simultane_dh(cbind(c(rep(1, 5), 6:40)) + 0)
           identical(r$k, NA_integer_) && identical(taux_417(cbind(c(rep(1, 5), 6:40)), 1), 6 / 40)
         })

# --- Bande ponctuelle sur une matrice jouet ----------------------------------
# 30 lignes deterministes, deux lignes non finies ecartees.
z_jouet <- sin(outer(1:30, 1:T1) * 0.7) * 2
z_jouet[c(5, 17), 2] <- c(NA, Inf)
e_jouet <- engine_enveloppe_spread(z_jouet, x)
L_jouet <- courbes(z_jouet)
verifier("Matrice jouet (30 lignes, 2 non finies) : B_eff = 28, bornes ponctuelles = quantiles 5 % et 95 % de type 7 recalcules en clair, x = sort(x), bande simultanee NA (B_eff < 500) avec motif",
         {
           bas <- apply(L_jouet, 2, q7, p = 0.05); haut <- apply(L_jouet, 2, q7, p = 0.95)
           identical(e_jouet$B_eff, 28L) && nrow(L_jouet) == 28L &&
             isTRUE(proche(e_jouet$bandes$bas, bas, rel = 1e-12)) &&
             isTRUE(proche(e_jouet$bandes$haut, haut, rel = 1e-12)) &&
             identical(e_jouet$bandes$x, sort(x)) &&
             all(is.na(e_jouet$bandes$sim_bas)) && all(is.na(e_jouet$bandes$sim_haut)) &&
             identical(e_jouet$k, NA_integer_) && is.na(e_jouet$taux_global_simultane) &&
             identical(e_jouet$motif, "moins de 500 replications retenues : bande simultanee non calculee")
         })
verifier("Matrice jouet : taux_global_ponctuel = proportion des lignes ayant une valeur strictement hors de [bas, haut]",
         {
           hors <- vapply(seq_len(nrow(L_jouet)), function(i)
             any(L_jouet[i, ] < e_jouet$bandes$bas | L_jouet[i, ] > e_jouet$bandes$haut), logical(1))
           identical(e_jouet$taux_global_ponctuel, mean(hors))
         })

# --- Cas reel, B = 999 : champ plots_data$spread_enveloppe -------------------
r999 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                   B = 999, seed = GRAINE, nature_donnees = "brutes")
e999 <- r999$plots_data$spread_enveloppe
L999 <- courbes(r999$bootstrap$z_boot)
verifier("plots_data$spread_enveloppe : suivi des trois champs de #305 en fin de plots_data, champs dans l'ordre du par. 1.5, constantes du QQ-plot, regle DH1997_4.17, motif NA",
         identical(tail(names(r999$plots_data), 5), c("qq_enveloppe", "spread_enveloppe", "sigma_usp_boot",
                                                       "regime_boot", "boot_reperes")) &&
           identical(names(e999), c("bandes", "source", "B_eff", "niveau_ponctuel", "niveau_simultane",
                                    "k", "taux_global_ponctuel", "taux_global_simultane",
                                    "B_min_simultane", "regle_rang", "motif")) &&
           is.data.frame(e999$bandes) &&
           identical(names(e999$bandes), c("x", "bas", "haut", "sim_bas", "sim_haut")) &&
           identical(e999$source, "bootstrap") &&
           identical(e999$niveau_ponctuel, ENVELOPPE_QQ_NIVEAU) &&
           identical(e999$niveau_simultane, ENVELOPPE_QQ_NIVEAU) &&
           identical(e999$B_min_simultane, ENVELOPPE_QQ_B_MIN_SIM) &&
           identical(e999$regle_rang, "DH1997_4.17") && identical(e999$motif, NA_character_))
verifier("B = 999 : x des bandes identical() a spread_lisse$x ; B_eff = lignes finies de z_boot",
         identical(e999$bandes$x, r999$plots_data$spread_lisse$x) &&
           identical(e999$B_eff, nrow(L999)) && nrow(L999) == 999L)
verifier("B = 999 : bornes ponctuelles = quantiles de type 7 recalcules en clair sur les courbes simulees",
         isTRUE(proche(e999$bandes$bas, apply(L999, 2, q7, p = 0.05), rel = 1e-12)) &&
           isTRUE(proche(e999$bandes$haut, apply(L999, 2, q7, p = 0.95), rel = 1e-12)))
verifier(sprintf("B = 999 : k* (%s) = plus grand k de taux (4.17) <= 0,10, recalcule par les rangs ; taux a k* + 1 > 0,10 ; bornes Sc[k*, ] et Sc[B + 1 - k*, ]",
                 e999$k),
         {
           k <- e999$k; Sc <- apply(L999, 2, sort); B <- nrow(L999)
           is.integer(k) && identical(k, as.integer(k_etoile_417(L999))) &&
             identical(e999$taux_global_simultane, taux_417(L999, k)) &&
             taux_417(L999, k + 1L) > 0.10 &&
             identical(e999$bandes$sim_bas, Sc[k, ]) && identical(e999$bandes$sim_haut, Sc[B + 1L - k, ])
         })
if (requireNamespace("boot", quietly = TRUE)) {
  verifier("B = 999 : bornes simultanees identical() a celles de boot::envelope(level = c(0,90 ; 0,90)) (meme k*)",
           {
             ev <- boot::envelope(mat = L999, level = c(0.90, 0.90))
             identical(as.integer(ev$k.ov[1]), e999$k) &&
               identical(unname(ev$overall[2, ]), e999$bandes$sim_bas) &&
               identical(unname(ev$overall[1, ]), e999$bandes$sim_haut)
           })
} else cat("  note : paquet boot absent ; comparaison a boot::envelope() non exercee.\n")
verifier("B = 999 : emboitement sim_bas <= bas <= haut <= sim_haut",
         with(e999$bandes, all(sim_bas <= bas) && all(bas <= haut) && all(haut <= sim_haut)))
verifier("Niveau fixe : alpha = 0,05 ne change pas spread_enveloppe (B = 199)",
         {
           ra <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                            B = 199, seed = GRAINE, nature_donnees = "brutes", alpha = 0.05)
           rb <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                            B = 199, seed = GRAINE, nature_donnees = "brutes")
           identical(ra$plots_data$spread_enveloppe, rb$plots_data$spread_enveloppe)
         })

# --- Chemins existants inchanges sur les cinq cas lognormaux de reference -----
# spread_lisse et qq_enveloppe recalcules par run_engine() (CAS de
# tests/outils_tests.R) contre tests/reference/<cas>.rds. Comparaison par
# comparer_objets() a TOLERANCE, seul comparateur aux references (ADR 0006,
# second amendement ; ADR 0011) : un identical() echouerait sur une autre
# plateforme que celle de la CI par la seule derive d'optimiseur. Le nombre
# de feuilles non strictement identiques est rapporte (0 attendu sur la
# plateforme des references).
outils306 <- new.env(parent = globalenv())
sys.source(file.path(if (exists("RACINE", inherits = TRUE)) RACINE else ".", "tests", "outils_tests.R"),
           envir = outils306)
CAS_LN306 <- c("premium", "reserve1", "premium_ii6", "premium_net", "premium_interieur")
comp306 <- lapply(CAS_LN306, function(cas) {
  ref <- readRDS(outils306$chemin_reference(cas))$plots_data
  obt <- outils306$executer_cas(cas)$plots_data
  champs <- c("spread_lisse", "qq_enveloppe")
  list(cas = cas, comp = outils306$comparer_objets(ref[champs], obt[champs]),
       identiques = identical(ref[champs], obt[champs]))
})
verifier(sprintf("Cinq cas lognormaux : spread_lisse et qq_enveloppe conformes a tests/reference/<cas>.rds a TOLERANCE (identical() : %s)",
                 paste(vapply(comp306, function(r) sprintf("%s %s", r$cas, r$identiques), ""),
                       collapse = ", ")),
         all(vapply(comp306, function(r) isTRUE(r$comp$conforme), logical(1))))

# --- Aucun tirage -------------------------------------------------------------
verifier("engine_enveloppe_spread() et engine_plots_data() laissent .Random.seed intact et n'appellent pas engine_sous_graine()",
         {
           set.seed(7); avant <- .Random.seed
           engine_enveloppe_spread(r999$bootstrap$z_boot, x)
           engine_plots_data(f1, b199, prof1)
           identical(.Random.seed, avant) &&
             !any(grepl("engine_sous_graine", deparse(body(engine_enveloppe_spread)), fixed = TRUE)) &&
             !any(grepl("engine_sous_graine", deparse(body(engine_rang_simultane_dh)), fixed = TRUE))
         })

# --- Degenerescences -----------------------------------------------------------
pd10 <- engine_plots_data(f1, usp_bootstrap(f1, B = 10, seed = GRAINE), prof1)
verifier("B = 10 (B_eff < ENVELOPPE_QQ_B_MIN = 20) : quatre bornes NA, k et taux NA, motif",
         {
           e <- pd10$spread_enveloppe
           identical(ENVELOPPE_QQ_B_MIN, 20L) && identical(e$B_eff, 10L) &&
             all(is.na(unlist(e$bandes[c("bas", "haut", "sim_bas", "sim_haut")]))) &&
             identical(e$k, NA_integer_) && is.na(e$taux_global_ponctuel) &&
             is.na(e$taux_global_simultane) &&
             identical(e$motif, "moins de 20 replications retenues : enveloppe non disponible")
         })
verifier("B = 199 (20 <= B_eff < 500) : bande ponctuelle finie, simultanee NA, k NA, motif",
         {
           e <- pd199$spread_enveloppe
           identical(e$B_eff, 199L) && all(is.finite(e$bandes$bas)) && all(is.finite(e$bandes$haut)) &&
             all(is.na(e$bandes$sim_bas)) && all(is.na(e$bandes$sim_haut)) &&
             identical(e$k, NA_integer_) && is.finite(e$taux_global_ponctuel) &&
             identical(e$motif, "moins de 500 replications retenues : bande simultanee non calculee")
         })
verifier("Seuils sur les lignes de z_boot a B = 999 : B_eff = 19 -> tout NA ; 20 -> ponctuelle ; 499 -> ponctuelle seule ; 500 -> simultanee, k entier, motif NA",
         {
           zb <- r999$bootstrap$z_boot
           e19 <- engine_enveloppe_spread(zb[1:19, ], x); e20 <- engine_enveloppe_spread(zb[1:20, ], x)
           e499 <- engine_enveloppe_spread(zb[1:499, ], x); e500 <- engine_enveloppe_spread(zb[1:500, ], x)
           all(is.na(e19$bandes$bas)) && all(is.finite(e20$bandes$bas)) &&
             all(is.na(e20$bandes$sim_bas)) &&
             all(is.finite(e499$bandes$bas)) && all(is.na(e499$bandes$sim_bas)) &&
             identical(e499$k, NA_integer_) &&
             all(is.finite(e500$bandes$sim_bas)) && is.integer(e500$k) && e500$k >= 1L &&
             identical(e500$motif, NA_character_)
         })
verifier("Aucun k admissible a B_eff = 500 (60 lignes identiques de z_boot, a 1000 partout, ex aequo au maximum de chaque colonne : taux >= 60/500 a k = 1, lignes du minimum en plus) : bande ponctuelle seule, k NA, motif",
         {
           zb <- r999$bootstrap$z_boot[1:500, ]; zb[1:60, ] <- 1000
           e <- engine_enveloppe_spread(zb, x)
           identical(e$B_eff, 500L) && all(is.finite(e$bandes$bas)) &&
             all(is.na(e$bandes$sim_bas)) && all(is.na(e$bandes$sim_haut)) &&
             identical(e$k, NA_integer_) && is.na(e$taux_global_simultane) &&
             taux_417(courbes(zb), 1) >= 60 / 500 &&
             identical(e$motif, paste("aucun rang k admissible : taux de sortie (4.17) superieur a 0,10",
                                      "au rang k = 1 ; bande simultanee non disponible"))
         })
verifier("Lignes NA de z_boot ecartees du B effectif et des bandes",
         {
           zb <- r999$bootstrap$z_boot; zb[c(3, 50, 120), ] <- NA
           e <- engine_enveloppe_spread(zb, x); L <- courbes(zb)
           identical(e$B_eff, 996L) &&
             isTRUE(proche(e$bandes$bas, apply(L, 2, q7, p = 0.05), rel = 1e-12)) &&
             identical(e$k, as.integer(k_etoile_417(L)))
         })
verifier("z_boot absent : B_eff = 0, bornes NA, motif du seuil de 20",
         {
           e <- engine_enveloppe_spread(NULL, x)
           identical(e$B_eff, 0L) && all(is.na(e$bandes$bas)) &&
             identical(e$motif, "moins de 20 replications retenues : enveloppe non disponible")
         })
verifier("Volumes constants (usp_volumes_constants()) : bornes NA, k NA, B_eff = 0 (aucune courbe calculee), motif 'volumes constants : graphique dispersion-niveau sans objet' ; run_engine() a x constant pose le meme motif",
         {
           xc <- rep(100, T1)
           e <- engine_enveloppe_spread(r999$bootstrap$z_boot, xc)
           rc <- run_engine(xt = xc, yt = y, methode = "premium", segment = 1, annexe = "II",
                            B = 99, seed = GRAINE, nature_donnees = "brutes")
           motif <- "volumes constants : graphique dispersion-niveau sans objet"
           usp_volumes_constants(xc) && identical(e$motif, motif) && identical(e$B_eff, 0L) &&
             identical(rc$plots_data$spread_enveloppe$B_eff, 0L) &&
             all(is.na(unlist(e$bandes[c("bas", "haut", "sim_bas", "sim_haut")]))) &&
             identical(e$k, NA_integer_) && isTRUE(rc$ok) &&
             identical(rc$plots_data$spread_enveloppe$motif, motif)
         })

# --- Affichage : plot_spread() (R/display_helpers.R) --------------------------
.racine306 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."
source(file.path(.racine306, "R", "display_helpers.R"), local = TRUE)
pd999 <- r999$plots_data
forge_niveau <- function(pd, np, ns) {
  pd$spread_enveloppe$niveau_ponctuel <- np; pd$spread_enveloppe$niveau_simultane <- ns; pd
}
# Releve, en base R sur pdf(NULL), des libelles de legende, du sous-titre et
# de l'ordre des traces (polygones, points, lignes).
releve_base306 <- function(pd) {
  r <- new.env(); r$leg <- character(0); r$mt <- character(0); r$seq <- character(0)
  ns <- asNamespace("graphics")
  suppressMessages({
    trace("legend", tracer = bquote(assign("leg", c(get("leg", envir = .(r)), legend), envir = .(r))),
          where = ns, print = FALSE)
    trace("mtext", tracer = bquote(assign("mt", c(get("mt", envir = .(r)), text), envir = .(r))),
          where = ns, print = FALSE)
    for (f in c("polygon", "points.default", "lines.default"))
      trace(f, tracer = bquote(assign("seq", c(get("seq", envir = .(r)), .(f)), envir = .(r))),
            where = ns, print = FALSE)
  })
  on.exit(suppressMessages(for (f in c("legend", "mtext", "polygon", "points.default", "lines.default"))
    untrace(f, where = ns)))
  option <- options(usp.graphiques_base = TRUE); grDevices::pdf(NULL)
  on.exit({ grDevices::dev.off(); options(option) }, add = TRUE)
  suppressWarnings(plot_spread(pd))
  as.list(r)
}
LIB_SIM90 <- "bande simultan\u00e9e 90 % (tous les points \u00e0 la fois)"
LIB_PONCT90 <- "bande ponctuelle 90 % (point par point)"
rb999 <- releve_base306(pd999)
verifier("plot_spread(), base R, B = 999 : deux aplats (simultane puis ponctuel) traces avant le nuage et la courbe ; legende au niveau du moteur (90 %)",
         identical(rb999$seq[1:2], c("polygon", "polygon")) &&
           max(which(rb999$seq == "polygon")) < min(which(rb999$seq %in% c("points.default", "lines.default"))) &&
           identical(rb999$leg, c(LIB_SIM90, LIB_PONCT90)) &&
           identical(rb999$mt, sprintf("bootstrap param\u00e9trique ; bandes ponctuelle et simultan\u00e9e (k = %s sur 999 r\u00e9plications)",
                                       pd999$spread_enveloppe$k)))
rb_95 <- releve_base306(forge_niveau(pd999, 0.80, 0.95))
verifier("plot_spread(), base R, niveaux forges (0,80 ponctuel ; 0,95 simultane) : legende lue dans niveau_*, aucun 90 %",
         identical(rb_95$leg, c("bande simultan\u00e9e 95 % (tous les points \u00e0 la fois)",
                                "bande ponctuelle 80 % (point par point)")) &&
           !any(grepl("90 %", rb_95$leg, fixed = TRUE)))
rb199 <- releve_base306(pd199)
verifier("plot_spread(), base R, B = 199 : un seul aplat (ponctuel), legende ponctuelle seule, sous-titre sur deux lignes (bandes tracees, puis motif du moteur seul)",
         sum(rb199$seq == "polygon") == 1L && identical(rb199$leg, LIB_PONCT90) &&
           identical(rb199$mt, c("bootstrap param\u00e9trique ; bande ponctuelle (199 r\u00e9plications)",
                                 "moins de 500 replications retenues : bande simultanee non calculee")))
verifier("plot_spread(), base R, sans spread_enveloppe (objet anterieur a #306) et a volumes constants : aucun aplat ni legende, sans erreur",
         {
           pd_ancien <- pd999; pd_ancien$spread_enveloppe <- NULL
           pd_vc <- pd999; pd_vc$spread_enveloppe <- engine_enveloppe_spread(r999$bootstrap$z_boot, rep(100, T1))
           ra <- releve_base306(pd_ancien); rv <- releve_base306(pd_vc)
           !any(ra$seq == "polygon") && !length(ra$leg) && !length(ra$mt) &&
             !any(rv$seq == "polygon") && !length(rv$leg) &&
             any(grepl("volumes constants : graphique dispersion-niveau sans objet", rv$mt, fixed = TRUE))
         })
if (requireNamespace("plotly", quietly = TRUE)) {
  construit306 <- function(pd) {
    op <- options(usp.graphiques_base = FALSE); on.exit(options(op))
    plotly::plotly_build(plot_spread(pd))$x
  }
  textes_ann <- function(b) vapply(b$layout$annotations, function(a) a$text, character(1))
  verifier("plot_spread(), plotly, B = 999 : aplats (traces remplies) avant la courbe et le nuage, annotations au niveau du moteur, sous-titre au titre",
           {
             b <- construit306(pd999)
             remplie <- vapply(b$data, function(d) identical(d$fill, "tonexty"), logical(1))
             mode <- vapply(b$data, function(d) if (is.null(d$mode)) "" else d$mode, character(1))
             sum(remplie) == 2L && max(which(remplie)) < min(which(mode %in% c("lines", "markers") & !remplie &
                                                                 vapply(b$data, function(d) !identical(d$line$width, 0), logical(1)))) &&
               identical(textes_ann(b), c(LIB_SIM90, LIB_PONCT90)) &&
               endsWith(b$layout$title$text,
                        sprintf("<br><sup>bootstrap param\u00e9trique ; bandes ponctuelle et simultan\u00e9e (k = %s sur 999 r\u00e9plications)</sup>",
                                pd999$spread_enveloppe$k)) &&
               # Marge haute pour la legende : meme etendue des ordonnees qu'en base R.
               identical(as.numeric(b$layout$yaxis$range), .spread_ylim(pd999, TRUE, TRUE)) &&
               b$layout$yaxis$range[2] > max(pd999$spread_enveloppe$bandes$sim_haut)
           })
  verifier("plot_spread(), plotly, niveaux forges (0,80 ; 0,95) : annotations lues dans niveau_*, aucun 90 %",
           {
             tx <- textes_ann(construit306(forge_niveau(pd999, 0.80, 0.95)))
             identical(tx, c("bande simultan\u00e9e 95 % (tous les points \u00e0 la fois)",
                             "bande ponctuelle 80 % (point par point)")) &&
               !any(grepl("90 %", tx, fixed = TRUE))
           })
  verifier("plot_spread(), plotly, B = 199 et objet sans spread_enveloppe : une bande puis aucune, sans erreur",
           {
             pd_ancien <- pd999; pd_ancien$spread_enveloppe <- NULL
             b1 <- construit306(pd199); b0 <- construit306(pd_ancien)
             sum(vapply(b1$data, function(d) identical(d$fill, "tonexty"), logical(1))) == 1L &&
               identical(textes_ann(b1), LIB_PONCT90) &&
               !any(vapply(b0$data, function(d) identical(d$fill, "tonexty"), logical(1))) &&
               !length(b0$layout$annotations) &&
               endsWith(b1$layout$title$text,
                        paste0("<br><sup>bootstrap param\u00e9trique ; bande ponctuelle (199 r\u00e9plications)</sup>",
                               "<br><sup>moins de 500 replications retenues : bande simultanee non calculee</sup>")) &&
               identical(b0$layout$title$text, "Dispersion-niveau (H2) \u2014 lissage local")
           })
} else cat("  note : plotly absent ; branche plotly de plot_spread() non exercee (attendu en CI, issue #53).\n")

fin_fichier()
