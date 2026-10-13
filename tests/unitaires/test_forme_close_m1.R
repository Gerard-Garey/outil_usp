###############################################################################
#  tests/unitaires/test_forme_close_m1.R  --  COURBURE ET PENTE INTRA-COLONNE
#                                             DE M1 EN FORME CLOSE (ISSUE #253)
#
#  Specification d'E2d (docs/specifications/e2d-merz-wuthrich-replications-
#  definitions.md, section 6, tests T253-1 a T253-7 ; decisions D1-5 a D1-7
#  du mainteneur, 13/10/2026) : t du terme quadratique de mw_test_courbure()
#  par .mw_courbure_colonne() (Cauchy-Binet, regle de Cramer) et pente
#  intra-colonne de .mw_lm_intra() (Frisch et Waugh, 1933), sans lm().
#  Valeurs attendues ecrites en dur : reference en arithmetique rationnelle
#  exacte (entrees : les flottants du moteur, convertis exactement ; seule la
#  racine finale est arrondie), calculee par actuary pour la specification
#  (T253-1, T253-2, T253-5 « bornes ») et, pour le triangle a deux echelles
#  extremes de T253-5, par la meme reference lors de l'implementation ; cas
#  ligne 0 x 1e-14 : reference Rmpfr du script ci-dessous (4 096 bits, memes
#  17 chiffres a 8 192 bits). Source et controle de toutes ces valeurs :
#  tests/unitaires/generer_valeurs_forme_close_m1.R (hors CI, Rmpfr), qui
#  les recalcule par une methode independante de la forme close (equations
#  normales, elimination de Gauss a 4 096 bits, controle a 8 192 bits) et
#  sort avec le code 1 si l'une s'ecarte de la tolerance de son test.
#  Convention de la pente intra-colonne : y = F tel que le moteur le stocke
#  dans mw_residus(), soit le quotient C(i,j+1) / C(i,j) arrondi en double
#  (pas le quotient exact des deux flottants) ; avec le quotient exact, les
#  references bougeraient de 1e-15 a 3e-14 en relatif, sous les tolerances
#  (1e-12 et 1e-10).
#  T253-7 (reserve2 sous TOLERANCE, verdicts identiques) est porte par
#  tests/test_reproductibilite.R.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_forme_close_m1.R")

.racine253 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."
tri253 <- local({
  d <- utils::read.csv(file.path(.racine253, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
# Ligne i (0-based) multipliee par k
ligne253 <- function(t, i, k) { t[i + 1, ] <- t[i + 1, ] * k; t }
# t de la courbure par colonne retenue, K, et t de la pente intra-colonne
stats253 <- function(t) {
  aj <- mw_ajuster(t)
  res <- mw_residus(aj, .mw_colonnes_degenerees(aj))
  cb <- mw_test_courbure(aj)
  li <- .mw_lm_intra(res)
  list(t = cb$detail$t, j = cb$detail$j, K = cb$K, stat = cb$stat, p = cb$p,
       pente = if (is.null(li)) NA_real_ else unname(li[["t value"]]))
}
# Triangle « bornes » : ligne 0 portee a 1e50 (max), ligne 3 a 1e-50 (min)
bornes253 <- local({
  t <- tri253
  t[1, ] <- t[1, ] * 1e50 / max(t[1, ], na.rm = TRUE)
  t[4, ] <- t[4, ] * 1e-50 / min(t[4, ], na.rm = TRUE)
  t
})
# Deux echelles extremes : ligne 0 a 1e48 (max), lignes 1 a 3 a 1e-48 (min)
extreme253 <- local({
  t <- tri253
  t[1, ] <- t[1, ] * 1e48 / max(t[1, ], na.rm = TRUE)
  for (i in 2:4) t[i, ] <- t[i, ] * 1e-48 / min(t[i, ], na.rm = TRUE)
  t
})
ok_liste <- function(r) {
  ko <- vapply(r, function(v) !isTRUE(v), logical(1))
  if (!any(ko)) TRUE else
    paste(names(r)[ko], vapply(r[ko], function(v) paste(as.character(v), collapse = " "), ""),
          sep = " : ", collapse = " ; ")
}

verifier("T253-1 : reserve2, t de la courbure (n = 7, 6, 5, 4) et de la pente intra-colonne = reference rationnelle a 1e-12 (#253)",
         {
           s <- stats253(tri253)
           ok_liste(list(
             K = identical(s$K, 4L),
             courbure = proche(s$t, c(0.93422764996969232, -1.9823633206000404,
                                      -9.1618120029068368, -3.462887950378827), rel = 1e-12),
             pente = proche(s$pente, 0.2600197442537881, rel = 1e-12)))
         })

verifier("T253-2 : reserve2, ligne 0 x 1e30, ligne 3 x 1e30, ligne 0 x 1e-30 : t = reference rationnelle a 1e-10 (#253)",
         {
           att <- list(
             l0p30 = list(ligne253(tri253, 0, 1e30),
                          c(-3.2321868753333782, -2.6230673521146479, -1.2246845553777297,
                            0.27555322316525688), -0.64792170590960629),
             l3p30 = list(ligne253(tri253, 3, 1e30),
                          c(-1.7637144365936694, -3.1751739033668485, -1.0848619801581147,
                            -1.9731120214984617), 0.58992812949620965),
             l0m30 = list(ligne253(tri253, 0, 1e-30),
                          c(3.1467379665547841, 2.1589835486730493, 0.79635768376122973,
                            -0.58330789698280028), -1.120997177810577))
           ok_liste(unlist(lapply(att, function(a) {
             s <- stats253(a[[1]])
             list(K = identical(s$K, 4L), courbure = proche(s$t, a[[2]], rel = 1e-10),
                  pente = proche(s$pente, a[[3]], rel = 1e-10))
           }), recursive = FALSE))
         })

# Avant #253, lm() ecartait le terme par son rang numerique : courbure NA
# des e = 13 (exclusion silencieuse partielle a e = 12, ligne 3), pente NA
# des e = 15 (specification, section 4).
verifier("T253-3 : lignes 0 et 3 x 10^e, e = 12..17, 20, 25, 30 : courbure et pente finies, K = 4 partout (#253)",
         {
           ko <- character(0)
           for (i in c(0, 3)) for (e in c(12:17, 20, 25, 30)) {
             s <- stats253(ligne253(tri253, i, 10^e))
             if (!(identical(s$K, 4L) && is.finite(s$stat) && is.finite(s$pente)))
               ko <- c(ko, sprintf("ligne %d e = %d (K = %s, X = %s, pente = %s)", i, e,
                                   format(s$K), format(s$stat), format(s$pente)))
           }
           if (!length(ko)) TRUE else paste(ko, collapse = " ; ")
         })

verifier("T253-4 : invariance a l'echelle globale, lambda = 10^-40, 10^-20, 10^20, 10^40 : t a 1e-12 (#253)",
         {
           s0 <- stats253(tri253)
           ok_liste(unlist(lapply(c(-40, -20, 20, 40), function(k) {
             s <- stats253(tri253 * 10^k)
             stats::setNames(list(proche(s$t, s0$t, rel = 1e-12), proche(s$pente, s0$pente, rel = 1e-12)),
                             paste0(c("courbure", "pente"), " 1e", k))
           }), recursive = FALSE))
         })

# Triangle a deux echelles extremes : la version de la specification
# (produits directs de poids et de differences) y rend NaN et Inf (mesure
# lors de l'implementation, hypothese [H] de la specification confirmee) ;
# le calcul a exposant separe reste fini et exact.
verifier("T253-5 : triangles aux bornes du domaine [1e-50 ; 1e50] de #185 : valides, t finis = reference rationnelle a 1e-10 (#253)",
         {
           sb <- stats253(bornes253); sx <- stats253(extreme253)
           ok_liste(list(
             valides = isTRUE(mw_valider_triangle(bornes253)$ok) &&
               isTRUE(mw_valider_triangle(extreme253)$ok),
             bornes_K = identical(sb$K, 4L),
             bornes_courbure = proche(sb$t, c(0.081519213694489751, -2.013620676168856,
                                              -4.5274309238335313, -6.6723491946328828), rel = 1e-10),
             bornes_pente = proche(sb$pente, -0.65007141204537222, rel = 1e-10),
             extreme_K = identical(sx$K, 4L),
             extreme_finis = all(is.finite(c(sx$t, sx$stat, sx$p, sx$pente))),
             extreme_courbure = proche(sx$t, c(-4.5539052541909681, -8.7152604957341513,
                                               -3.9732558970578664e+25, 0.46224878577219491),
                                       rel = 1e-10),
             extreme_pente = proche(sx$pente, -0.78452449405942448, rel = 1e-10)))
         })

verifier("T253-6 : colonne a deux valeurs distinctes de C(i,j) ecartee (K = 3) ; pente a C constant par colonne : NULL, statistique NA (#253, D1-7)",
         {
           t <- tri253
           t[, 1] <- rep(c(250, 320), 4)            # colonne j = 0 : deux valeurs
           s <- stats253(t)
           res <- data.frame(j = rep(0:1, each = 3), C = rep(c(10, 20), each = 3),
                             sigma_j = rep(c(1, 2), each = 3), F = c(1.5, 1.6, 1.4, 1.1, 1.2, 1.05))
           ok_liste(list(
             K = identical(s$K, 3L), j = identical(as.integer(s$j), 1:3),
             colonne_null = is.null(.mw_courbure_colonne(t[1:7, 1], t[1:7, 2])),
             pente_null = is.null(.mw_lm_intra(res)),
             pente_na = identical(.mw_pente_intra(res), NA_real_)))
         })

# Hors tableau de la specification (demande d'actuary) : seul cas mesure ou
# l'ancien moteur (lm()) rendait une pente intra-colonne finie et fausse,
# sans NA ni avertissement (t = -2,566 contre -1,1210, erreur relative 1,29).
verifier("reserve2, ligne 0 x 1e-14 : t de la courbure et de la pente intra-colonne = reference Rmpfr a 1e-10 (#253)",
         {
           s <- stats253(ligne253(tri253, 0, 1e-14))
           ok_liste(list(
             K = identical(s$K, 4L),
             courbure = proche(s$t, c(3.1467379665547831, 2.1589835486730452,
                                      0.79635768376122591, -0.58330789698280312), rel = 1e-10),
             pente = proche(s$pente, -1.1209971778104361, rel = 1e-10)))
         })

# Ajustement parfait (G = 0) : colonne j = 0 quadratique exacte en binaire,
# C(i,1) = 3 C(i,0) + C(i,0)^2 / 512, C(i,0) entiers de somme 2048 (facteurs,
# ecarts et determinants exacts) : t = +Inf, p = 0, relevee au plancher de
# .fisher_combine() ; X reste fini (mesure : 1429,6). Colonne affine exacte
# (C(i,0) puissances de 2 de somme 1024, C(i,1) = 3 C(i,0) + 64) : N = G = 0,
# t = NaN, d'ou une statistique de Fisher NA (regle de #90).
verifier("G = 0 : colonne quadratique exacte, t = +Inf, p = 0, X de Fisher fini ; N = G = 0 : t NaN, statistique NA (#253)",
         {
           t <- tri253
           C0 <- c(256, 264, 280, 288, 296, 312, 352)
           t[1:7, 1] <- C0; t[1:7, 2] <- 3 * C0 + C0^2 / 512
           s <- stats253(t)
           r <- .mw_courbure_colonne(t[1:7, 1], t[1:7, 2])
           Ca <- c(32, 32, 64, 128, 256, 512)
           ra <- .mw_courbure_colonne(Ca, 3 * Ca + 64)
           ok_liste(list(
             c2 = identical(unname(r[["c2"]]), 1 / 512),
             t_inf = identical(unname(r[["t"]]), Inf),
             p_nul = identical(unname(r[["p"]]), 0),
             K = identical(s$K, 4L),
             X_fini = is.finite(s$stat) && s$stat > -2 * log(.Machine$double.xmin),
             affine_t_nan = is.nan(ra[["t"]]),
             affine_stat_na = is.na(.fisher_combine(c(ra[["p"]], 0.5, 0.2))$stat)))
         })

# Hors tableau de la specification : la forme close est celle de lm() la ou
# lm() est precis (reserve2), y compris a valeurs de C(i,j) repetees (au
# moins trois distinctes), ou la difference divisee e[Q] de la specification
# n'est pas definie et ou le developpement de det_Q selon e l'est ; vecteur
# de .mw_lm_intra() de memes noms que la ligne "C" de summary.lm().
verifier("Forme close = summary(lm()) a 1e-10 sur reserve2 et a valeurs de C repetees ; noms de .mw_lm_intra() = ceux de co[\"C\", ] (#253)",
         {
           aj <- mw_ajuster(tri253)
           res <- mw_residus(aj, .mw_colonnes_degenerees(aj))
           res$w <- res$C / res$sigma_j^2
           co <- summary(stats::lm(F ~ factor(j) + C, weights = w, data = res))$coefficients["C", ]
           li <- .mw_lm_intra(res)
           C0 <- c(300, 300, 320, 340, 360, 360); C1 <- c(960, 985, 1010, 1080, 1110, 1150)
           ref_lm <- summary(stats::lm(C1 ~ C0 + I(C0^2), weights = 1 / C0))$coefficients[3, ]
           cc <- .mw_courbure_colonne(C0, C1)
           ok_liste(list(
             noms = identical(names(li), names(co)),
             pente = proche(li, co, rel = 1e-10),
             repetees = proche(cc[c("c2", "t", "p")], ref_lm[c(1, 3, 4)], rel = 1e-10)))
         })

bilan_fichier()
