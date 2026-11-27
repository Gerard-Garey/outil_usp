###############################################################################
#  tests/outils_mesure_dw.R  --  AIDES COMMUNES DES DEUX SCRIPTS DE MESURE
#  DURBIN-WATSON HORS CI (issue #421, point 4 ; decision Q-78-4 (a))
#
#  Fichier d'aides, pas un test ni un script de mesure : il n'est lance ni
#  par la CI, ni par tests/test_unitaires.R (nom sans prefixe test_, hors de
#  tests/unitaires/), ni par test_reproductibilite.R. Charge par source()
#  par tests/mesure_dw_rho_negatif_t8.R et tests/mesure_lb1_dw_t8.R, APRES
#  tests/outils_tests.R (qui charge le moteur et definit RACINE), avant leurs
#  gardes de --ecrire. R base + stats (tools::md5sum() pour les empreintes) ;
#  aucun tirage, aucune ecriture de fichier.
#
#  Definition unique des cinq fonctions que les deux scripts portaient en
#  copies declarees jusqu'a #421 : empreintes_code(), plateforme_calcul(),
#  dw_mat() (stat_dw_mat() dans mesure_lb1_dw_t8.R), ar1_mat() et
#  points_critiques_dw(). Texte repris de ces copies, a deux changements
#  pres, sans effet sur les valeurs calculees :
#    - T (nombre de colonnes, ou argument de points_critiques_dw()) n'est
#      plus lu dans la variable globale T_ du script ;
#    - empreintes_code() recoit le chemin du script en argument et cite en
#      outre l'empreinte de ce fichier (outil charge).
#  tests/outils_tests.R reste inchange (contrats partages, Q-78-4 (a)).
###############################################################################

if (!exists("RACINE", inherits = TRUE) || !exists(".dw_valeurs_propres", mode = "function", inherits = TRUE))
  stop("tests/outils_mesure_dw.R : charger d'abord tests/outils_tests.R (moteur et RACINE)")

OUTILS_MESURE_DW <- "tests/outils_mesure_dw.R"

# Empreintes du code execute : md5 du script (chemin relatif a la racine,
# "hors depot" si le script execute n'est pas celui du depot), de
# tests/outils_tests.R et de ce fichier.
empreintes_code <- function(script, racine = RACINE) {
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  md5 <- function(x) if (!length(x) || !file.exists(x)) "absent" else unname(tools::md5sum(x))
  dans <- length(f) == 1L && identical(normalizePath(f, winslash = "/", mustWork = FALSE),
                                       normalizePath(file.path(racine, script), winslash = "/", mustWork = FALSE))
  sprintf("%s %s%s ; tests/outils_tests.R %s ; %s %s", script, md5(f), if (dans) "" else " (hors d\u00e9p\u00f4t)",
          md5(file.path(racine, "tests", "outils_tests.R")), OUTILS_MESURE_DW,
          md5(file.path(racine, OUTILS_MESURE_DW)))
}

# Plateforme de calcul : R, systeme, machine, BLAS, LAPACK.
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(extSoftVersion()["BLAS"]), txt(La_library()), txt(La_version()))
}

# Statistique DW sur chaque ligne d'une matrice (une serie par ligne, T =
# ncol(Z)), calculee sur la serie centree comme stat_dw() du moteur :
# sum (zc_t - zc_{t-1})^2 / sum zc_t^2.
dw_mat <- function(Z) {
  zc <- Z - rowMeans(Z)
  rowSums((zc[, -1L, drop = FALSE] - zc[, -ncol(zc), drop = FALSE])^2) / rowSums(zc^2)
}

# AR(1) stationnaire gaussien sur les lignes de E (innovations N(0,1), T =
# ncol(E)) : z_1 = e_1, z_t = rho z_{t-1} + sqrt(1 - rho^2) e_t.
ar1_mat <- function(E, rho) {
  Z <- E; s <- sqrt(1 - rho^2)
  for (t in 2:ncol(E)) Z[, t] <- rho * Z[, t - 1L] + s * E[, t]
  Z
}

# Points critiques bilateraux de la loi nulle exacte de DW a T observations :
# P0(DW <= d_bas) = P0(DW >= d_haut) = alpha / 2, par .imhof_p_sup0() sur
# .dw_valeurs_propres(T) et uniroot() (copie declaree du calcul de
# dw_puissance_ar1() du moteur, qui ne rend pas ces points).
points_critiques_dw <- function(alpha, T) {
  lam <- .dw_valeurs_propres(T)
  p0_sup <- function(d) .imhof_p_sup0(lam - d)
  lo <- min(lam) + 1e-9; hi <- max(lam) - 1e-9
  c(bas  = stats::uniroot(function(d) (1 - p0_sup(d)) - alpha / 2, c(lo, hi), tol = 1e-12)$root,
    haut = stats::uniroot(function(d) p0_sup(d) - alpha / 2, c(lo, hi), tol = 1e-12)$root)
}
