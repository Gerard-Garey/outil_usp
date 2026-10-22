###############################################################################
#  tests/mesure_lb1_dw_t8.R  --  PUISSANCES DE LJUNG-BOX (RETARD 1) ET DE
#  DURBIN-WATSON A T = 8, UNION SOUS H0, ET CONTROLES MONTE-CARLO DE LA
#  PUISSANCE ENVELOPPE DE H2 (Q-D1-Fh-9, #302, #303, #299)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (tools::md5sum() pour les empreintes). Il ne modifie ni
#  R/engine.R ni tests/reference/ : il n'appelle que des fonctions du moteur
#  inchangees (.imhof_p_sup0(), .dw_valeurs_propres(), dw_p_exacte(),
#  dw_puissance_ar1(), usp_puissance_enveloppe_h2(), engine_sous_graine()).
#  Sortie en markdown sur la console (UTF-8) ; un fichier n'est ecrit que
#  sur --ecrire. Tous les libelles non ASCII sont ecrits en echappements \u
#  (fichier source ASCII).
#
#  Objet. Verser au depot les mesures citees sans script par la rubrique 6
#  des fiches du .tex (decision du mainteneur du 20/10/2026, D1 option (a)) :
#    - le motif du retrait de Ljung-Box (retard 1) sur z (LB1) et sur ratios
#      bruts (LB1r), decision Q-D1-Fh-9 : puissances de Durbin-Watson (DW) et
#      de LB1, part des rejets de LB1 vers rho_1 < 0, part des rejets par au
#      moins une des deux sous H0 ;
#    - les controles Monte-Carlo de la puissance enveloppe pi_env de H2
#      (#299, usp_puissance_enveloppe_h2()).
#  Le tableau porte sur z_t, residus standardises, exact par la methode
#  d'Imhof : il remplace comme preuve le tableau hors depot sur les ratios
#  bruts u_t. A pi chapeau variable, la mesure sur u_t n'est pas chiffree.
#
#  Cadre (le meme que dw_puissance_ar1()) : T = 8 ; z i.i.d. N(0,1) sous H0
#  et AR(1) gaussien stationnaire, Sigma = (rho^|i-j|), sous les
#  alternatives ; SANS reajustement ; les deux statistiques sont calculees
#  sur la serie centree : rho_1 = sum_{t>=2} zc_t zc_{t-1} / sum zc_t^2 et DW
#  = stat_dw() = sum (zc_t - zc_{t-1})^2 / sum zc_t^2. Statut : les
#  valeurs d'Imhof sont des APPROXIMATIONS NUMERIQUES (quadrature) de
#  quantites EXACTES dans ce cadre ; les simulations sont des CONSTATS DE
#  SIMULATION ; l'AR(1) est une alternative choisie, hors modele
#  reglementaire (l'annexe XVII suppose des annees independantes).
#
#  Protocole.
#    Base commune. H = base orthonormee du complement du vecteur 1 (comme
#    usp_puissance_enveloppe_h2()), w = H'z ~ N(0, H' Sigma H), de dimension
#    T - 1 ; B = H' C H, C = matrice symetrique des produits de retard 1
#    (1/2 sur les deux diagonales voisines). rho_1 = w'Bw / w'w, donc
#    {rho_1 > c} = {w'(B - cI)w > 0} : forme quadratique en normales
#    independantes de coefficients les valeurs propres de
#    S (B - cI) S, S racine symetrique de H' Sigma H (S = I sous H0), dont
#    la queue en 0 est calculee par .imhof_p_sup0() appelee sans
#    modification, sur h normalise par max|h| (le signe de la forme ne depend
#    pas de l'echelle ; meme precaution que dw_puissance_ar1()). {rho_1 < -c}
#    = {w'(-B - cI)w > 0}.
#    1. MOMENTS EXACTS DE rho_1 sous H0. Forme close : rho_1 est un rapport
#       de formes quadratiques N / D de w ~ N(0, I), independant de son
#       denominateur D = w'w (la direction w/|w| est independante de |w|),
#       d'ou E[N^k] = E[rho_1^k] E[D^k], soit E rho_1 = tr(B)/(T - 1) =
#       -1/T et E rho_1^2 = (2 tr(B^2) + tr(B)^2) / ((T - 1)(T + 1)).
#       Verification numerique de l'independance, qui ne la suppose pas :
#       les memes moments sont recalcules par quadrature de la loi de rho_1
#       donnee par Imhof, E rho_1 = int_0^lmax P(rho_1 > c) dc -
#       int_0^{-lmin} P(rho_1 < -c) dc et E rho_1^2 = int_0^max(lmax,-lmin)
#       2c [P(rho_1 > c) + P(rho_1 < -c)] dc ; plus la moyenne simulee.
#    2. LB1 CALIBRE EXACTEMENT. Q = T (T + 2) rho_1^2 / (T - 1) (lag 1 de
#       Box.test(type = "Ljung-Box"), controle ci-dessous) ; rejet si
#       |rho_1| > c, c racine (uniroot(), tol 1e-12) de P(rho_1 > c) +
#       P(rho_1 < -c) = alpha sous H0. Sortie : c, valeur critique de Q, part
#       des rejets avec rho_1 < 0 = P(rho_1 < -c) / alpha (rejets avec
#       rho_1 < 0 : ceux de la queue basse), puissance sous AR(1), rho dans
#       {-0,6 ; -0,3 ; +0,3 ; +0,6}, alpha = 0,10 et 0,05, par Imhof.
#    3. PUISSANCE DE DW : dw_puissance_ar1(8, rho, alpha), memes rho et alpha.
#    4. UNION SOUS H0 : P(DW rejette ou LB1 rejette), par simulation (R
#       tirages de z i.i.d. N(0,1)), avec l'erreur Monte-Carlo
#       sqrt(p (1 - p) / R). DW rejette si DW <= d_bas ou DW >= d_haut,
#       points critiques de la loi nulle P0(DW <= d_bas) = P0(DW >= d_haut)
#       = alpha / 2 (meme calcul que dw_puissance_ar1(), copie declaree ;
#       controle : equivalence avec dw_p_exacte() < alpha sur 300 series).
#    5. CONTROLES MONTE-CARLO DE pi_env (#299). usp_puissance_enveloppe_h2(x,
#       alpha) sur J1 (xt de tests/donnees/donnees_ln.csv) et J2 (xi de
#       tests/unitaires/test_controles_numeriques.R, egal a xt de
#       tests/donnees/donnees_ln_interieur.csv), contre une simulation
#       directe du test invariant le plus puissant, selon le protocole de
#       controle du message du commit 484d29a (statistique SCE MCG sous
#       Sigma0 / Sigma1, par sens) : ln y = e, e ~ N(0, diag(v)), v = 1 pour
#       Sigma0 (delta = 1) et v_t = xbar / x_t pour Sigma1 (delta = 0, limite
#       des faibles CV) ; SCE(v) = min_mu sum (e_t - mu)^2 / v_t ; sens "H0 :
#       Sigma_n" : rejet si SCE(v_n) / SCE(v_a) > k, k = quantile (1 -
#       alpha) de ce rapport sous H0 estime sur R_PI tirages ; puissance =
#       part de R_PI autres tirages, independants, sous H1 qui depassent k.
#       R_PI = 2e6 (sections 1 a 4 : R = 2e5). pi_env simule = max des deux
#       sens. Controles : le maximum du moteur contre le maximum simule, et
#       chaque sens simule contre sa puissance d'Imhof (copie declaree de
#       sens() de usp_puissance_enveloppe_h2(), qui ne rend que le maximum ;
#       accord de la copie avec le moteur controle). Erreur Monte-Carlo : binomiale de la puissance, plus celle du
#       seuil k estime, propagee par la pente locale de la puissance en alpha
#       (mesuree sur les memes tirages a alpha +/- min(0,01 ; alpha / 2)) :
#       SE = sqrt(p (1 - p) / R_PI + pente^2 alpha (1 - alpha) / R_PI).
#       Precisions (avis d'actuary) : (i) le maximum des deux sens est biaise
#       vers le haut, d'au plus 0,56 erreur Monte-Carlo (1/sqrt(pi) pour deux
#       sens independants et de meme variance, moins sous correlation
#       positive), negligeable a R_PI = 2e6 ; (ii) l'erreur affichee est celle
#       du sens retenu (le plus grand des deux), non celle du maximum ; (iii)
#       portee : la simulation reproduit le modele limite du moteur (c -> 0,
#       Sigma1 = diag(xbar / x_t)) ; elle controle donc le calcul d'Imhof de
#       usp_puissance_enveloppe_h2(), sans valider l'approximation des faibles
#       coefficients de variation. La decroissance de pi_env en c (modele a c
#       fini) est non chiffree (aucun argument c) : usp_puissance_enveloppe_h2(x,
#       alpha) n'expose que la limite c -> 0.
#
#  Graine et generateur. Tout tirage passe par engine_sous_graine(SEED,
#  expr), SEED = 20261020, sous le generateur ENGINE_RNG_KIND, consignes dans
#  la sortie. Un flux par bloc, commence a la meme graine : la matrice des
#  2e5 x 8 normales de la base H0 (blocs 1 a 4) en est une ; les alternatives
#  AR(1) en sont des transformations (memes innovations pour tous les rho) ;
#  le bloc 5 tire deux matrices de 2e6 x 8 normales (z0 puis z1), memes pour
#  J1, J2 et les deux alpha.
#
#  Tolerances des controles. Calcul numerique (Imhof, formes closes) contre
#  une valeur attendue arrondie : le demi-pas d'arrondi de cette valeur, soit
#  5e-4 pour une valeur a trois decimales (puissances de DW et de LB1, part
#  des rejets avec rho_1 < 0), 5e-5 pour une valeur a quatre decimales
#  (ecart-type 0,2835, pi_env du message du commit 484d29a), et 1e-12 pour
#  l'identite E rho_1 = -1/T (aucun arrondi) ; verification numerique de
#  l'independance (forme close contre quadrature, sans valeur arrondie) :
#  1e-6 ; accord de la copie declaree de sens() avec le moteur : 1e-9.
#  Simulation contre une valeur exacte : 3
#  erreurs Monte-Carlo ; contre une valeur attendue arrondie ("environ
#  0,141") : 3 erreurs Monte-Carlo plus 5e-4.
#  Les ecarts sont rapportes dans tous les cas, jamais masques ; code de
#  sortie 1 si un controle echoue.
#
#  Usage (depuis la racine du depot ; LC_ALL=C.UTF-8 sous Linux, #113) :
#      Rscript tests/mesure_lb1_dw_t8.R [--ecrire]
#  --ecrire : ecrit en plus, si tous les controles tiennent,
#  docs/tableaux/20261020-mesure-lb1-dw-t8.md (plateforme, generateur,
#  graine, SHA de HEAD, md5 du moteur, empreintes du script et de
#  tests/outils_tests.R) ; sans cette option, rien n'est ecrit. Gardes
#  anticipees (avant tout calcul) puis finales (avant d'ecrire), comme les
#  autres scripts (#205, #173) : docs/tableaux/ doit exister ; refus (code
#  1, rien d'ecrit) si le commit lu par commit_depot() n'est pas un SHA nu
#  (arbre de travail modifie, script non suivi ou git indisponible) ; refus
#  si le fichier cible est suivi par git (ce script n'a pas d'option
#  --remplacer). Le tableau se produit donc apres le commit du script.
#  Duree : voir la ligne "Duree" de la console (mesuree le 20/10/2026, Linux,
#  R 4.3.3 : environ 6 s pour les sections 1 a 4 a R = 2e5, environ 1 min en
#  tout avec la section 5 a R = 2e6).
#  Code de sortie : 0 si les controles tiennent, 1 sinon.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/mesure_lb1_dw_t8.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113) ------------------------------
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
if (length(setdiff(ARGS, "--ecrire"))) stop("option inconnue : ", paste(setdiff(ARGS, "--ecrire"), collapse = " "))
OPT_ECRIRE <- "--ecrire" %in% ARGS

# --- Chargement du moteur et des outils --------------------------------------
DOSSIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) dirname(f) else if (file.exists("tests/outils_tests.R")) "tests" else "."
})
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))

NOM_FICHIER <- "20261020-mesure-lb1-dw-t8.md"
CHEMIN_ECRIT <- file.path(RACINE, "docs", "tableaux", NOM_FICHIER)
# Empreintes du code execute : md5 de ce script et de tests/outils_tests.R ;
# "hors depot" si le script execute n'est pas celui du depot (copie declaree
# de empreintes_code() de tests/mesure_b_dossier_t8.R).
empreintes_code <- function() {
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  md5 <- function(x) if (!length(x) || !file.exists(x)) "absent" else unname(tools::md5sum(x))
  dans <- length(f) == 1L && identical(normalizePath(f, winslash = "/", mustWork = FALSE),
                                       normalizePath(file.path(RACINE, SCRIPT), winslash = "/", mustWork = FALSE))
  sprintf("%s %s%s ; tests/outils_tests.R %s", SCRIPT, md5(f), if (dans) "" else " (hors d\u00e9p\u00f4t)",
          md5(file.path(RACINE, "tests", "outils_tests.R")))
}
# Gardes de --ecrire (#205, #173), anticipees (avant tout calcul) puis
# finales (avant d'ecrire) : dossier cible, arbre propre et script suivi,
# fichier cible non suivi par git (ce script n'a pas d'option --remplacer).
gardes_ecrire <- function(quand) {
  if (!dir.exists(file.path(RACINE, "docs", "tableaux"))) stop("dossier de sortie introuvable : docs/tableaux")
  nv <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(), quand)
  if (length(nv)) {
    message("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
            " -- aucun fichier ecrit")
    quit(status = 1L)
  }
  tryCatch(garde_ecrasement(CHEMIN_ECRIT, FALSE, RACINE, quitter = FALSE),
           garde_ecrasement_refus = function(e) {
             message("--ecrire refuse : ", NOM_FICHIER, " existe deja et est suivi par git, ou son suivi par git ",
                     "ne peut etre verifie (git indisponible) ; ce script ne remplace pas un tableau suivi ",
                     "-- aucun fichier ecrit")
             quit(status = 1L)
           })
  invisible(NULL)
}
if (OPT_ECRIRE) gardes_ecrire("de l'ex\u00e9cution")
COMMIT <- commit_depot(SCRIPT)
MD5_MOTEUR <- unname(tools::md5sum(file.path(RACINE, "R", "engine.R")))

# Plateforme de calcul (copie declaree de plateforme_calcul() de
# tests/constats_puissance_t8.R).
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(extSoftVersion()["BLAS"]), txt(La_library()), txt(La_version()))
}
ecrire_console <- function(x) writeLines(enc2utf8(x), useBytes = TRUE)

# --- Mise en forme -------------------------------------------------------------
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
num <- function(x, d = 3) if (length(x) != 1L || is.na(x)) "\u2014" else sub(".", ",", sprintf(paste0("%.", d, "f"), x), fixed = TRUE)
sci <- function(g) sub(".", ",", sprintf("%.1e", g), fixed = TRUE)
RHO1 <- "\u03c1\u0302\u2081"          # rho chapeau indice 1
ALPHA <- "\u03b1"
PI_ENV <- "\u03c0_env"

# --- Parametres ----------------------------------------------------------------
T_ <- 8L
ALPHAS <- c(0.10, 0.05)
RHOS <- c(-0.6, -0.3, 0.3, 0.6)
R_SIM <- 200000L       # sections 1 a 4
R_PI <- 2000000L       # section 5 (pi_env)
SEED <- 20261020
# Valeurs attendues (note d'actuary, brief du 20/10/2026) : alpha = 0,10.
ATT_E_RHO  <- -0.125
ATT_SD_RHO <- 0.2835
ATT_PART_NEG <- c("0.1" = 0.900, "0.05" = 0.940)
ATT_DW  <- c(0.355, 0.163, 0.159, 0.328)       # rho = -0,6 ; -0,3 ; +0,3 ; +0,6, alpha = 0,10
ATT_LB1 <- c(0.513, 0.242, 0.073, 0.135)
ATT_UNION <- 0.141                              # alpha = 0,10, "environ" (erreur 0,0008)
# Valeurs de pi_env du commit 484d29a (message), 4 decimales.
ATT_PI_ENV <- list(J1 = c("0.1" = 0.1267, "0.05" = 0.0658), J2 = c("0.1" = 0.3433, "0.05" = 0.2227))
# Tolerances des valeurs attendues arrondies : demi-pas d'arrondi.
TOL_3DEC <- 5e-4       # valeur attendue a trois decimales
TOL_4DEC <- 5e-5       # valeur attendue a quatre decimales
TOL_EXACT <- 1e-12     # identite algebrique (E rho_1 = -1/T)

# Controles : data.frame cumule (id, libelle, obtenu, attendu, tolerance, statut).
CTRL <- data.frame(id = character(0), libelle = character(0), obtenu = numeric(0), attendu = numeric(0),
                   tolerance = numeric(0), ok = logical(0), stringsAsFactors = FALSE)
ctrl <- function(id, libelle, obtenu, attendu, tol) {
  ok <- length(obtenu) == 1L && is.finite(obtenu) && abs(obtenu - attendu) <= tol
  CTRL[nrow(CTRL) + 1L, ] <<- list(id, libelle, obtenu, attendu, tol, ok)
  invisible(ok)
}
se_bin <- function(p, n) sqrt(p * (1 - p) / n)

# --- Base commune : matrices de la loi exacte ------------------------------------
H <- qr.Q(qr(cbind(1, diag(T_))))[, -1L, drop = FALSE]      # T x (T-1), complement de 1
C1 <- matrix(0, T_, T_)
C1[cbind(1:(T_ - 1L), 2:T_)] <- 0.5
C1[cbind(2:T_, 1:(T_ - 1L))] <- 0.5
BM <- crossprod(H, C1 %*% H)                                 # B = H'CH
LAM_B <- eigen(BM, symmetric = TRUE, only.values = TRUE)$values
Id1 <- diag(T_ - 1L)

# Queue en 0 de w'A w, w ~ N(0, Sw) : racine symetrique S de Sw (NULL : Sw = I).
racine_sym <- function(Sw) {
  es <- eigen(Sw, symmetric = TRUE)
  es$vectors %*% diag(sqrt(pmax(es$values, 0))) %*% t(es$vectors)
}
p_sup_forme <- function(A, S = NULL) {
  h <- if (is.null(S)) eigen(A, symmetric = TRUE, only.values = TRUE)$values
       else eigen(S %*% A %*% S, symmetric = TRUE, only.values = TRUE)$values
  .imhof_p_sup0(h / max(abs(h)))
}
# P(rho_1 > c) et P(rho_1 < -c), sous H0 (S = NULL) ou sous N(0, Sw) (S).
p_rho_sup <- function(c, S = NULL) p_sup_forme(BM - c * Id1, S)
p_rho_inf <- function(c, S = NULL) p_sup_forme(-BM - c * Id1, S)
# Racine symetrique de H' Sigma H pour l'AR(1) de parametre rho.
S_ar1 <- function(rho) racine_sym(crossprod(H, outer(seq_len(T_), seq_len(T_), function(i, j) rho^abs(i - j)) %*% H))

# --- Statistiques sur des series simulees (lignes) --------------------------------
centrer <- function(Z) Z - rowMeans(Z)
stat_rho1_mat <- function(Z) { zc <- centrer(Z); rowSums(zc[, -1L, drop = FALSE] * zc[, -T_, drop = FALSE]) / rowSums(zc^2) }
stat_dw_mat <- function(Z) { zc <- centrer(Z); rowSums((zc[, -1L, drop = FALSE] - zc[, -T_, drop = FALSE])^2) / rowSums(zc^2) }
ar1_mat <- function(E, rho) {
  Z <- E; s <- sqrt(1 - rho^2)
  for (t in 2:T_) Z[, t] <- rho * Z[, t - 1L] + s * E[, t]
  Z
}

# --- Points critiques de DW (copie declaree du calcul de dw_puissance_ar1()) --------
LAM_DW <- .dw_valeurs_propres(T_)
points_critiques_dw <- function(alpha) {
  p0_sup <- function(d) .imhof_p_sup0(LAM_DW - d)
  lo <- min(LAM_DW) + 1e-9; hi <- max(LAM_DW) - 1e-9
  c(bas  = stats::uniroot(function(d) (1 - p0_sup(d)) - alpha / 2, c(lo, hi), tol = 1e-12)$root,
    haut = stats::uniroot(function(d) p0_sup(d) - alpha / 2, c(lo, hi), tol = 1e-12)$root)
}

sortie <- character(0)
ajouter <- function(...) sortie <<- c(sortie, ...)

# Flux de la base H0 (blocs 1 a 4) et des alternatives : une matrice R x T.
E0 <- engine_sous_graine(SEED, matrix(stats::rnorm(R_SIM * T_), R_SIM, T_))

###############################################################################
# 0. Controles d'integrite des statistiques
###############################################################################
# (a) rho_1 et Q : definition de Box.test(lag = 1, "Ljung-Box") sur 100 series.
ecart_q <- max(vapply(1:100, function(i) {
  z <- E0[i, ]
  r1 <- stat_rho1_mat(matrix(z, 1L))
  q <- T_ * (T_ + 2) * r1^2 / (T_ - 1)
  abs(q - unname(stats::Box.test(z, lag = 1L, type = "Ljung-Box")$statistic))
}, 0))
ctrl("I1", "Q = T(T+2) rho_1^2/(T-1) contre stats::Box.test(lag = 1, Ljung-Box), 100 s\u00e9ries (\u00e9cart max)", ecart_q, 0, 1e-10)
# (b) stat_dw_mat contre stat_dw() du moteur.
ecart_dw <- max(vapply(1:100, function(i) abs(stat_dw_mat(matrix(E0[i, ], 1L)) - stat_dw(E0[i, ])), 0))
ctrl("I2", "DW matriciel contre stat_dw() du moteur, 100 s\u00e9ries (\u00e9cart max)", ecart_dw, 0, 1e-12)
# (c) Rejet de DW par intervalle critique = p < alpha de dw_p_exacte().
desacc <- 0L
for (a in ALPHAS) {
  d <- points_critiques_dw(a)
  for (i in 1:300) {
    z <- E0[i, ]; ds <- stat_dw(z)
    rej_int <- ds <= d[["bas"]] || ds >= d[["haut"]]
    rej_p <- dw_p_exacte(z) < a
    if (!identical(rej_int, rej_p)) desacc <- desacc + 1L
  }
}
ctrl("I3", "R\u00e9gion critique de DW [d_bas, d_haut] contre dw_p_exacte() < alpha, 300 s\u00e9ries \u00d7 2 seuils (nombre de d\u00e9saccords)", desacc, 0, 0)

###############################################################################
# 1. Moments exacts de rho_1 sous H0
###############################################################################
E_rho_close <- sum(LAM_B) / (T_ - 1)
E_rho2_close <- (2 * sum(LAM_B^2) + sum(LAM_B)^2) / ((T_ - 1) * (T_ + 1))
SD_rho_close <- sqrt(E_rho2_close - E_rho_close^2)
lmax <- max(LAM_B); lmin <- min(LAM_B)
vect <- function(f) Vectorize(f, "c")
E_rho_quad <- stats::integrate(vect(p_rho_sup), 0, lmax, rel.tol = 1e-8)$value -
              stats::integrate(vect(p_rho_inf), 0, -lmin, rel.tol = 1e-8)$value
E_rho2_quad <- stats::integrate(vect(function(c) 2 * c * (p_rho_sup(c) + p_rho_inf(c))), 0, max(lmax, -lmin), rel.tol = 1e-8)$value
SD_rho_quad <- sqrt(E_rho2_quad - E_rho_quad^2)
r1_h0 <- stat_rho1_mat(E0)
E_rho_sim <- mean(r1_h0); SD_rho_sim <- stats::sd(r1_h0)
se_mean <- SD_rho_sim / sqrt(R_SIM)
kurt <- mean((r1_h0 - E_rho_sim)^4) / SD_rho_sim^4
se_sd <- SD_rho_sim * sqrt((kurt - 1) / (4 * R_SIM))
ctrl("M1a", "E \u03c1\u0302\u2081 (forme close) contre -1/T", E_rho_close, ATT_E_RHO, TOL_EXACT)
ctrl("M1b", "\u00e9cart-type de \u03c1\u0302\u2081 (forme close) contre la valeur attendue 0,2835", SD_rho_close, ATT_SD_RHO, TOL_4DEC)
ctrl("M1c", "E \u03c1\u0302\u2081 : forme close contre quadrature d'Imhof (ind\u00e9pendance de \u03c1\u0302\u2081 et de son d\u00e9nominateur, v\u00e9rifi\u00e9e num\u00e9riquement)", E_rho_quad, E_rho_close, 1e-6)
ctrl("M1d", "\u00e9cart-type de \u03c1\u0302\u2081 : forme close contre quadrature d'Imhof", SD_rho_quad, SD_rho_close, 1e-6)
ctrl("M1e", "E \u03c1\u0302\u2081 simul\u00e9e contre -1/T (3 erreurs Monte-Carlo)", E_rho_sim, ATT_E_RHO, 3 * se_mean)
ctrl("M1f", "\u00e9cart-type simul\u00e9 de \u03c1\u0302\u2081 contre la forme close (3 erreurs Monte-Carlo)", SD_rho_sim, SD_rho_close, 3 * se_sd)
ajouter(sprintf("## Mesure de Ljung-Box (retard 1) et de Durbin-Watson \u00e0 T = %d (Q-D1-Fh-9, #302, #303, #299)", T_), "",
        "Statut : approximations num\u00e9riques d'Imhof de quantit\u00e9s exactes (z i.i.d. N(0,1) sous H0, AR(1) gaussien stationnaire sous les alternatives, sans r\u00e9ajustement, m\u00eame cadre que `dw_puissance_ar1()`), et constats de simulation ; **hors mod\u00e8le r\u00e9glementaire** (l'annexe XVII suppose des ann\u00e9es ind\u00e9pendantes). Le tableau porte sur les r\u00e9sidus standardis\u00e9s z_t ; \u00e0 \u03c0\u0302 variable, la mesure sur les ratios bruts u_t n'est pas chiffr\u00e9e.", "",
        "### 1. Moments exacts de \u03c1\u0302\u2081 sous H0", "",
        entete_md(c("Grandeur", "Forme close (traces)", "Quadrature d'Imhof", "Simulation (R tirages)", "Attendu")),
        ligne_md(paste0("E ", RHO1), num(E_rho_close, 6), num(E_rho_quad, 6), sprintf("%s \u00b1 %s", num(E_rho_sim, 4), num(se_mean, 4)), "\u22120,125 (\u22121/T)"),
        ligne_md(paste0("\u00c9cart-type de ", RHO1), num(SD_rho_close, 6), num(SD_rho_quad, 6), sprintf("%s \u00b1 %s", num(SD_rho_sim, 4), num(se_sd, 4)), "0,2835"),
        "", sprintf("Formes closes : E \u03c1\u0302\u2081 = tr(B)/(T \u2212 1), E \u03c1\u0302\u2081\u00b2 = (2 tr(B\u00b2) + tr(B)\u00b2)/((T \u2212 1)(T + 1)), valables parce que \u03c1\u0302\u2081 est ind\u00e9pendant de son d\u00e9nominateur w'w sous H0. La quadrature recalcule les m\u00eames moments \u00e0 partir de la loi de \u03c1\u0302\u2081 donn\u00e9e par Imhof, sans cette hypoth\u00e8se (\u00e9cart forme close \u2212 quadrature : %s sur la moyenne, %s sur l'\u00e9cart-type). Simulation : R = %d, \u00b1 = une erreur Monte-Carlo.",
                    sci(E_rho_quad - E_rho_close), sci(SD_rho_quad - SD_rho_close), R_SIM), "")

###############################################################################
# 2. LB1 calibre exactement
###############################################################################
CAL <- lapply(ALPHAS, function(a) {
  c_a <- stats::uniroot(function(c) p_rho_sup(c) + p_rho_inf(c) - a, c(1e-9, max(lmax, -lmin) - 1e-9), tol = 1e-12)$root
  list(alpha = a, c = c_a, q = T_ * (T_ + 2) * c_a^2 / (T_ - 1), p_haut = p_rho_sup(c_a), p_bas = p_rho_inf(c_a))
})
names(CAL) <- vapply(ALPHAS, format, "")
ligs <- character(0)
for (k in CAL) {
  part <- k$p_bas / k$alpha
  taux_sim <- mean(abs(r1_h0) > k$c)
  part_sim <- mean(r1_h0 < -k$c) / taux_sim
  ctrl(sprintf("M2-a%s-niveau", num(k$alpha, 2)), sprintf("niveau de LB1 calibr\u00e9 simul\u00e9 contre alpha = %s (3 erreurs Monte-Carlo)", num(k$alpha, 2)),
       taux_sim, k$alpha, 3 * se_bin(k$alpha, R_SIM))
  ctrl(sprintf("M2-a%s-part", num(k$alpha, 2)), sprintf("part des rejets de LB1 avec \u03c1\u0302\u2081 < 0 \u00e0 alpha = %s", num(k$alpha, 2)),
       part, ATT_PART_NEG[[format(k$alpha)]], TOL_3DEC)
  ligs <- c(ligs, ligne_md(num(k$alpha, 2), num(k$c, 4), num(k$q, 3), num(k$p_haut, 5), num(k$p_bas, 5), num(part, 3),
                           num(ATT_PART_NEG[[format(k$alpha)]], 3), num(part_sim, 3), sprintf("%s \u00b1 %s", num(taux_sim, 4), num(se_bin(k$alpha, R_SIM), 4))))
}
ajouter("### 2. LB1 calibr\u00e9 exactement : rejet si |\u03c1\u0302\u2081| > c", "",
        paste0("Q = T(T + 2)\u03c1\u0302\u2081\u00b2/(T \u2212 1) ; c tel que P(\u03c1\u0302\u2081 > c) + P(\u03c1\u0302\u2081 < \u2212c) = ", ALPHA, " sous H0, chaque probabilit\u00e9 par `.imhof_p_sup0()`."), "",
        entete_md(c(ALPHA, "c", "Q critique", "P(\u03c1\u0302\u2081 > c)", "P(\u03c1\u0302\u2081 < \u2212c)", "Part des rejets avec \u03c1\u0302\u2081 < 0", "Attendu", "Part simul\u00e9e", "Niveau simul\u00e9 (R tirages)")),
        ligs, "")

###############################################################################
# 3. Puissances de LB1 (Imhof) et de DW (dw_puissance_ar1()) sous AR(1)
###############################################################################
pw_lb1 <- function(rho, a) { S <- S_ar1(rho); c_a <- CAL[[format(a)]]$c; p_rho_sup(c_a, S) + p_rho_inf(c_a, S) }
PTS <- lapply(ALPHAS, points_critiques_dw); names(PTS) <- vapply(ALPHAS, format, "")
ligs <- character(0)
for (a in ALPHAS) {
  for (i in seq_along(RHOS)) {
    rho <- RHOS[i]
    Z <- ar1_mat(E0, rho)
    r1 <- stat_rho1_mat(Z); dw <- stat_dw_mat(Z)
    p_lb <- pw_lb1(rho, a); p_dw <- dw_puissance_ar1(T_, rho, a)
    s_lb <- mean(abs(r1) > CAL[[format(a)]]$c); s_dw <- mean(dw <= PTS[[format(a)]][["bas"]] | dw >= PTS[[format(a)]][["haut"]])
    id <- sprintf("M3-a%s-r%s", num(a, 2), num(rho, 1))
    ctrl(paste0(id, "-LB1sim"), sprintf("puissance de LB1 simul\u00e9e contre Imhof (rho = %s, alpha = %s ; 3 erreurs Monte-Carlo)", num(rho, 1), num(a, 2)),
         s_lb, p_lb, 3 * se_bin(p_lb, R_SIM))
    ctrl(paste0(id, "-DWsim"), sprintf("puissance de DW simul\u00e9e contre dw_puissance_ar1() (rho = %s, alpha = %s ; 3 erreurs Monte-Carlo)", num(rho, 1), num(a, 2)),
         s_dw, p_dw, 3 * se_bin(p_dw, R_SIM))
    att_dw <- att_lb <- NA_real_
    if (a == 0.10) {
      att_dw <- ATT_DW[i]; att_lb <- ATT_LB1[i]
      ctrl(paste0(id, "-DW"), sprintf("puissance de DW, dw_puissance_ar1(8, %s, 0,10), contre la valeur attendue", num(rho, 1)), p_dw, att_dw, TOL_3DEC)
      ctrl(paste0(id, "-LB1"), sprintf("puissance de LB1 par Imhof (rho = %s, alpha = 0,10) contre la valeur attendue", num(rho, 1)), p_lb, att_lb, TOL_3DEC)
    }
    ligs <- c(ligs, ligne_md(num(a, 2), num(rho, 1), num(p_dw, 3), num(att_dw, 3), sprintf("%s \u00b1 %s", num(s_dw, 4), num(se_bin(p_dw, R_SIM), 4)),
                             num(p_lb, 3), num(att_lb, 3), sprintf("%s \u00b1 %s", num(s_lb, 4), num(se_bin(p_lb, R_SIM), 4)),
                             num(p_lb - p_dw, 3)))
  }
}
ajouter("### 3. Puissances sous AR(1) : Durbin-Watson bilat\u00e9ral exact et LB1 calibr\u00e9", "",
        paste0("DW : `dw_puissance_ar1(8, \u03c1, ", ALPHA, ")` ; LB1 : Imhof sous N(0, \u03a3), \u03a3 = (\u03c1^|i\u2212j|), au seuil c de la section 2. Colonnes \"Simul\u00e9\" : fr\u00e9quence de rejet sur R = ",
               R_SIM, " s\u00e9ries AR(1), \u00b1 = une erreur Monte-Carlo binomiale ; colonnes \"Attendu\" : valeurs de la note d'actuary, donn\u00e9es \u00e0 ", ALPHA, " = 0,10 seulement (\u2014 : sans valeur attendue)."), "",
        entete_md(c(ALPHA, "\u03c1", "DW (Imhof)", "DW attendu", "DW simul\u00e9", "LB1 (Imhof)", "LB1 attendu", "LB1 simul\u00e9", "LB1 \u2212 DW")),
        ligs, "")

###############################################################################
# 4. Union sous H0
###############################################################################
ligs <- character(0)
for (a in ALPHAS) {
  d <- PTS[[format(a)]]; c_a <- CAL[[format(a)]]$c
  dw0 <- stat_dw_mat(E0)
  rej_dw <- dw0 <= d[["bas"]] | dw0 >= d[["haut"]]
  rej_lb <- abs(r1_h0) > c_a
  p_u <- mean(rej_dw | rej_lb); se_u <- se_bin(p_u, R_SIM)
  p_both <- mean(rej_dw & rej_lb)
  ctrl(sprintf("M4-a%s-DW", num(a, 2)), sprintf("niveau de DW simul\u00e9 contre alpha = %s (3 erreurs Monte-Carlo)", num(a, 2)), mean(rej_dw), a, 3 * se_bin(a, R_SIM))
  if (a == 0.10)
    ctrl("M4-a0,10-union", "P(DW rejette ou LB1 rejette) \u00e0 alpha = 0,10 contre 0,141 (3 erreurs Monte-Carlo + 5e-4 d'arrondi de la valeur attendue)", p_u, ATT_UNION, 3 * se_u + 5e-4)
  ligs <- c(ligs, ligne_md(num(a, 2), num(mean(rej_dw), 4), num(mean(rej_lb), 4), num(p_both, 4), num(p_u, 4), num(se_u, 4),
                           if (a == 0.10) "0,141 environ (erreur 0,0008)" else "\u2014"))
}
ajouter("### 4. Union sous H0 : P(DW rejette ou LB1 rejette)", "",
        sprintf("Simulation, R = %d s\u00e9ries z i.i.d. N(0,1), graine %s ; chaque test calibr\u00e9 \u00e0 son niveau nominal (sections 2 et 3). Erreur Monte-Carlo = sqrt(p(1 \u2212 p)/R).", R_SIM, format(SEED, scientific = FALSE)), "",
        entete_md(c(ALPHA, "P(DW rejette)", "P(LB1 rejette)", "P(les deux)", "P(union)", "Erreur Monte-Carlo", "Attendu")),
        ligs, "")

###############################################################################
# 5. Controles Monte-Carlo de pi_env (#299)
###############################################################################
lire_j2 <- function() {
  f <- file.path(RACINE, "tests", "unitaires", "test_controles_numeriques.R")
  l <- readLines(f)
  env <- new.env()
  for (v in c("xi", "yi")) {
    li <- grep(sprintf("^%s <- c\\(", v), l, value = TRUE)
    if (length(li) != 1L) stop("J2 : ligne '", v, " <- c(' introuvable ou multiple dans ", f)
    eval(parse(text = li), envir = env)
  }
  list(x = env$xi, y = env$yi)
}
J2 <- lire_j2()
JEUX <- list(J1 = .ln$xt, J2 = J2$x)
ctrl("E0", "J2 (xi de test_controles_numeriques.R) = xt de donnees_ln_interieur.csv (all.equal, nombre de d\u00e9saccords)",
     as.numeric(!isTRUE(all.equal(JEUX$J2, .ln_int$xt))), 0, 0)
# Deux matrices independantes de normales, tirees dans un seul flux a la graine SEED.
ZZ <- engine_sous_graine(SEED, list(z0 = matrix(stats::rnorm(R_PI * T_), R_PI, T_),
                                    z1 = matrix(stats::rnorm(R_PI * T_), R_PI, T_)))
# SCE MCG (somme des carres residuelle de l'estimation MCG de mu) sous diag(v), ligne par ligne.
sce_mcg <- function(Em, v) { w <- 1 / v; rowSums(sweep(Em^2, 2, w, "*")) - rowSums(sweep(Em, 2, w, "*"))^2 / sum(w) }
# Un sens : H0 de variance v_n, H1 de variance v_a ; rejet si SCE(v_n)/SCE(v_a) > k.
puissance_sens <- function(vn, va, alpha) {
  lam0 <- sce_mcg(sweep(ZZ$z0, 2, sqrt(vn), "*"), vn) / sce_mcg(sweep(ZZ$z0, 2, sqrt(vn), "*"), va)
  lam1 <- sce_mcg(sweep(ZZ$z1, 2, sqrt(va), "*"), vn) / sce_mcg(sweep(ZZ$z1, 2, sqrt(va), "*"), va)
  pw <- function(a) mean(lam1 > stats::quantile(lam0, 1 - a, type = 7, names = FALSE))
  p <- pw(alpha); h <- min(0.01, alpha / 2)
  pente <- (pw(alpha + h) - pw(alpha - h)) / (2 * h)
  c(p = p, se = sqrt(p * (1 - p) / R_PI + pente^2 * alpha * (1 - alpha) / R_PI), pente = pente)
}
# Puissance d'Imhof de chaque sens (copie declaree de sens() de
# usp_puissance_enveloppe_h2(), qui ne rend que le maximum des deux sens) :
# sens 1 = "H0 : delta = 1" (sens(a)), sens 2 = "H0 : delta = 0" (sens(1/a)),
# a = valeurs propres de H' diag(xbar / x) H ; memes appels de
# .imhof_p_sup0() et d'uniroot() que le moteur.
imhof_sens <- function(x, alpha) {
  Hx <- qr.Q(qr(cbind(1, diag(length(x)))))[, -1L, drop = FALSE]
  a <- eigen(crossprod(Hx, (mean(x) / x) * Hx), symmetric = TRUE, only.values = TRUE)$values
  p_sup <- function(h) .imhof_p_sup0(h / max(abs(h)))
  sens <- function(a) {
    k <- stats::uniroot(function(k) p_sup(1 - k / a) - alpha, range(a),
                        f.lower = 1 - alpha, f.upper = -alpha, tol = 1e-12)$root
    p_sup(a - k)
  }
  c(sens1 = sens(a), sens2 = sens(1 / a))
}
ligs <- character(0)
for (j in names(JEUX)) {
  x <- JEUX[[j]]; v0 <- rep(1, length(x)); v1 <- mean(x) / x
  for (a in ALPHAS) {
    pe <- usp_puissance_enveloppe_h2(x, a)
    im <- imhof_sens(x, a)
    s1 <- puissance_sens(v0, v1, a)     # sens "H0 : delta = 1"
    s2 <- puissance_sens(v1, v0, a)     # sens "H0 : delta = 0"
    m <- if (s1[["p"]] >= s2[["p"]]) s1 else s2
    ctrl(sprintf("P5-%s-a%s-copie", j, num(a, 2)), sprintf("%s, %s, alpha = %s : maximum des deux sens d'Imhof (copie de sens()) contre le moteur", PI_ENV, j, num(a, 2)),
         max(im), pe, 1e-9)
    ctrl(sprintf("P5-%s-a%s-mc1", j, num(a, 2)), sprintf("%s, %s, alpha = %s : sens 1 (H0 : delta = 1) simul\u00e9 contre Imhof (3 erreurs Monte-Carlo)", PI_ENV, j, num(a, 2)),
         s1[["p"]], im[["sens1"]], 3 * s1[["se"]])
    ctrl(sprintf("P5-%s-a%s-mc2", j, num(a, 2)), sprintf("%s, %s, alpha = %s : sens 2 (H0 : delta = 0) simul\u00e9 contre Imhof (3 erreurs Monte-Carlo)", PI_ENV, j, num(a, 2)),
         s2[["p"]], im[["sens2"]], 3 * s2[["se"]])
    ctrl(sprintf("P5-%s-a%s-val", j, num(a, 2)), sprintf("%s, %s, alpha = %s : \u03c0_env du moteur contre la valeur du message du commit 484d29a", PI_ENV, j, num(a, 2)),
         pe, ATT_PI_ENV[[j]][[format(a)]], TOL_4DEC)
    ctrl(sprintf("P5-%s-a%s-mc", j, num(a, 2)), sprintf("%s, %s, alpha = %s : \u03c0_env du moteur contre la simulation directe (max des deux sens ; 3 erreurs Monte-Carlo)", PI_ENV, j, num(a, 2)),
         max(s1[["p"]], s2[["p"]]), pe, 3 * m[["se"]])
    ligs <- c(ligs, ligne_md(j, num(a, 2), num(pe, 4), num(ATT_PI_ENV[[j]][[format(a)]], 4),
                             num(im[["sens1"]], 4), sprintf("%s \u00b1 %s", num(s1[["p"]], 4), num(s1[["se"]], 4)),
                             num(im[["sens2"]], 4), sprintf("%s \u00b1 %s", num(s2[["p"]], 4), num(s2[["se"]], 4)),
                             sprintf("%s \u00b1 %s", num(m[["p"]], 4), num(m[["se"]], 4)), num(m[["p"]] - pe, 4)))
  }
}
ajouter(paste0("### 5. Contr\u00f4les Monte-Carlo de ", PI_ENV, " (#299, `usp_puissance_enveloppe_h2()`)"), "",
        sprintf("Test invariant le plus puissant entre \u03b4 = 1 (\u03a30 = I) et \u03b4 = 0 (\u03a31 = diag(x\u0304/x_t)), limite des faibles coefficients de variation, simul\u00e9 directement : rapport SCE MCG(\u03a3_n)/SCE MCG(\u03a3_a), seuil k estim\u00e9 sur R tirages sous H0, puissance sur R autres tirages sous H1 (graine %s, deux matrices ind\u00e9pendantes). **R = %d pour cette section** (R = %d pour les sections 1 \u00e0 4). Sens 1 : H0 : \u03b4 = 1 ; sens 2 : H0 : \u03b4 = 0. \u00b1 = une erreur Monte-Carlo (binomiale, plus seuil k estim\u00e9 propag\u00e9 par la pente locale de la puissance en %s).", format(SEED, scientific = FALSE), R_PI, R_SIM, ALPHA), "",
        paste0("**Trois pr\u00e9cisions.** (i) Le maximum des deux sens est biais\u00e9 vers le haut, d'au plus 0,56 erreur Monte-Carlo (1/\u221a\u03c0 pour deux sens ind\u00e9pendants, moins sous corr\u00e9lation positive), n\u00e9gligeable \u00e0 R = ", R_PI, ". (ii) L'erreur affich\u00e9e en face de \"Simul\u00e9 max\" est celle du sens retenu (le plus grand des deux), non celle du maximum. (iii) Port\u00e9e : la simulation reproduit le mod\u00e8le limite du moteur (c \u2192 0, \u03a31 = diag(x\u0304/x_t)) ; elle contr\u00f4le donc le calcul d'Imhof de `usp_puissance_enveloppe_h2()`, sans valider l'approximation des faibles coefficients de variation."), "",
        entete_md(c("Jeu", ALPHA, paste0(PI_ENV, " (moteur)"), paste0(PI_ENV, " (commit 484d29a)"), "Imhof sens 1", "Simul\u00e9 sens 1", "Imhof sens 2", "Simul\u00e9 sens 2", "Simul\u00e9 max", "Simul\u00e9 \u2212 moteur")),
        ligs, "",
        "**D\u00e9croissance de \u03c0_env en c : non chiffr\u00e9e (aucun argument c).** `usp_puissance_enveloppe_h2(x, alpha)` n'expose que la limite c \u2192 0 : calculer la puissance \u00e0 c fini demanderait de r\u00e9\u00e9crire le mod\u00e8le (traitement du terme de moyenne \u22121/2 ln(1 + c a_t), qui sort du groupe d'invariance), ce que ce script n'invente pas.", "")

###############################################################################
# Controles d'integrite et sortie
###############################################################################
INTEGRITE <- all(CTRL$ok)
fmt_ctrl <- function(g) if (abs(g) < 1e-3 && g != 0) sci(g) else num(g, 5)
ajouter("### Contr\u00f4les", "",
        entete_md(c("Id", "Contr\u00f4le", "Obtenu", "Attendu", "\u00c9cart", "Tol\u00e9rance", "Statut")),
        vapply(seq_len(nrow(CTRL)), function(i) with(CTRL[i, ], ligne_md(id, libelle, fmt_ctrl(obtenu), fmt_ctrl(attendu),
                                                              fmt_ctrl(obtenu - attendu), fmt_ctrl(tolerance), if (ok) "OK" else "**\u00c9CHEC**")), ""),
        "", sprintf("%d contr\u00f4les, %d en \u00e9chec.", nrow(CTRL), sum(!CTRL$ok)), "")

T0 <- c("### T0", "",
        entete_md(c("Grandeur", "Valeur")),
        ligne_md("Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)", plateforme_calcul()),
        ligne_md("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
        ligne_md("Graine (engine_sous_graine())", format(SEED, scientific = FALSE)),
        ligne_md("R, sections 1 \u00e0 4 (s\u00e9ries simul\u00e9es)", format(R_SIM, scientific = FALSE)),
        ligne_md("R, section 5 (tirages par matrice, deux matrices)", format(R_PI, scientific = FALSE)),
        ligne_md("Commit (HEAD)", COMMIT),
        ligne_md("md5 de R/engine.R", MD5_MOTEUR),
        ligne_md("Empreintes du code (script ex\u00e9cut\u00e9, outils charg\u00e9s)", empreintes_code()),
        ligne_md("Script", sprintf("%s%s (hors CI ; protocole dans l'en-t\u00eate)", SCRIPT, if (OPT_ECRIRE) " --ecrire" else "")), "")

duree <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
ecrire_console(c(sortie, T0, sprintf("Dur\u00e9e totale : %.0f s.", duree)))

if (OPT_ECRIRE) {
  if (!INTEGRITE) {
    message("--ecrire : contr\u00f4les en \u00e9chec, aucun fichier \u00e9crit")
  } else {
    gardes_ecrire("\u00e0 l'\u00e9criture")
    con <- file(CHEMIN_ECRIT, open = "wb")
    writeLines(enc2utf8(c(sortie, T0)), con, useBytes = TRUE)
    close(con)
    message("\u00e9crit : ", CHEMIN_ECRIT)
  }
}
quit(status = if (INTEGRITE) 0L else 1L)
