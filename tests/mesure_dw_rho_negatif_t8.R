###############################################################################
#  tests/mesure_dw_rho_negatif_t8.R  --  PUISSANCE DU TEST DE DURBIN-WATSON A
#  T = 8 CONTRE UN AR(1) A rho NEGATIF, JUSQU'A LA GARDE rho = -1 + 1e-6 (#164)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (tools::md5sum() pour les empreintes). Il ne modifie ni
#  R/engine.R ni tests/reference/ : il appelle dw_puissance_ar1() du moteur,
#  inchangee, pour la puissance, et, pour le recoupement par simulation (section
#  2), .dw_valeurs_propres(), .imhof_p_sup0(), stat_dw(), dw_p_exacte() et
#  engine_sous_graine(). La seule logique reprise est declaree (points
#  critiques et statistique matricielle de la section 2).
#  Sortie en markdown sur la console (UTF-8) ; un fichier n'est ecrit que sur
#  --ecrire. Tous les libelles non ASCII sont ecrits en echappements \u
#  (fichier source ASCII).
#
#  Objet. Avis d'actuary retenu par le mainteneur le 31/10/2026 (commentaire
#  6541872644 de #164, point "Mesure de la puissance de Durbin-Watson pres de
#  rho = -1") : tracer la puissance du test bilateral exact de Durbin-Watson
#  (dw_p_exacte(), p = 2 min(P0(DW <= d), P0(DW >= d)), rejet si p < alpha)
#  pour rho de -0,999 a 0, grille etendue jusqu'a la garde du moteur
#  (-1 + 1e-6) sur avis d'actuary du 31/10/2026 (point M3). Ces valeurs ne figuraient dans aucun fichier
#  versionne ; elles prolongent mesure_lb1_dw_t8.R (rho = -0,6 ; -0,3 ;
#  +0,3 ; +0,6).
#
#  Cadre (celui de dw_puissance_ar1()) : T = 8 ; z gaussien centre, i.i.d.
#  N(0,1) sous H0, AR(1) STATIONNAIRE, Sigma = (rho^|i-j|), sous l'alternative ;
#  SANS reajustement ; statistique calculee sur la serie centree (stat_dw()).
#  Statut : approximation numerique d'Imhof (quadrature, uniroot()) d'une
#  quantite EXACTE dans ce cadre : loi de DW sous H0 pour z i.i.d. N(0,1),
#  puissance sous un AR(1) stationnaire, alternative hors modele
#  reglementaire (l'annexe XVII suppose des annees independantes ; l'AR(1)
#  est une alternative choisie) ; z n'est pas le vecteur de residus
#  reajustes du moteur. La grille d'Imhof est DETERMINISTE (aucun tirage). Le
#  recoupement par simulation (section 2) tire sous engine_sous_graine() avec
#  la graine explicite SEED_SIM, consignee en T0 avec le generateur : le script
#  n'est donc plus "sans graine" (avis d'actuary du 31/10/2026, reponse a la
#  question 2 de la premiere remise). Statut de la sortie : approximation
#  numerique d'Imhof d'une quantite exacte, recoupee par simulation a rho =
#  -0,9 et -0,99 ; rho <= -0,999 non recoupes.
#  Variante a depart nul (z_1 = e_1 a la place de la loi stationnaire) : NON
#  calculee (abandonnee sans issue, avis d'actuary du 31/10/2026).
#  dw_puissance_ar1() ne porte que l'AR(1) stationnaire (lecture du code).
#
#  Protocole.
#    1. Grille rho dans {-1 + 1e-6 ; -0,99999 ; -0,9999 ; -0,999 ; -0,99 ;
#       -0,98 ; -0,95 ; -0,9 ; -0,8 ; -0,7 ; -0,5 ; -0,3 ; 0}, alpha dans
#       {0,10 ; 0,05} : puissance = dw_puissance_ar1(8, rho, alpha) ; rho = 0
#       sert de controle de niveau (doit rendre alpha). Domaine du moteur :
#       -1 + 1e-6 <= rho (garde de dw_puissance_ar1()) ; le point -1 + 1e-6 EST
#       la garde (1 - |rho| = 1e-6, admis : le test de la garde, rho < -1 +
#       1e-6, est faux sur cette valeur calculee de la meme facon). La colonne
#       "1 - puissance" (deficit) est la quantite qui tend vers 0 quand rho ->
#       -1. Deuxieme tableau : deficit / (1 - |rho|)^(1/2) (1 - |rho| lu comme
#       1 + rho), coefficient de la loi en (1 - |rho|)^(1/2) que le commentaire
#       de dw_puissance_ar1() releve pour rho < 0 ; mesure du 31/10/2026 :
#       1,2188 (alpha = 0,10) et 1,8153 (alpha = 0,05) a 1 - |rho| = 1e-6.
#    Controles (section "Controles" de la sortie, sans numero ; code de
#       sortie 1 si l'un echoue ; ecarts toujours rapportes) :
#       D1  determinisme : un second appel de dw_puissance_ar1(8, -0,99, 0,10)
#           rend la valeur de la grille a l'identique (tolerance 0) ;
#       N   niveau : puissance a rho = 0 egale a alpha, a 1e-8 (tolerance de
#           tests/unitaires/test_lois_exactes.R, assertion "rho = 0 rend alpha" ;
#           ecart mesure le 31/10/2026 : 2,2e-14 a alpha = 0,10 et 7,7e-14 a
#           alpha = 0,05) ;
#       M   monotonie : nombre de paires voisines de la grille (|rho|
#           croissant, rho = 0 compris) ou la puissance ne croit pas ;
#       B   nombre de points rho < 0 de la grille ou la puissance ne depasse
#           pas alpha. M et B sont des CONSTATS sur la grille a T = 8, non
#           garantis en general : le commentaire de dw_puissance_ar1() signale
#           un comportement decroissant a T = 4 (alpha = 0,10) et T = 5
#           (alpha = 0,05) ;
#       L   liens aux valeurs deja versionnees (alpha = 0,10) : rho = -0,5,
#           0,277840 a 1e-6 (tests/unitaires/test_lois_exactes.R, valeurs de
#           la fiche DW, issue #116) ; rho = -0,3 et -0,6, 0,163 et 0,355 a
#           5e-4, demi-pas d'arrondi des valeurs a trois decimales de
#           docs/tableaux/20261020-mesure-lb1-dw-t8.md (sections 3).
#       C   loi du deficit : ecart relatif du coefficient deficit / (1 -
#           |rho|)^(1/2) entre 1 - |rho| = 1e-4 (rho = -0,9999) et 1 - |rho| =
#           1e-6 (rho = -1 + 1e-6), a 1e-3 (constat a T = 8, par seuil ; 1,9e-4
#           a alpha = 0,10 et 4,1e-4 a alpha = 0,05 mesures le 31/10/2026).
#       Chaque controle L recalcule son point par un appel de
#       dw_puissance_ar1() propre, que la grille le contienne ou non.
#    2. RECOUPEMENT PAR SIMULATION (section 2 de la sortie), independant
#       d'Imhof pour l'alternative, a rho = -0,9 et -0,99 (alpha = 0,10 et 0,05), plus rho = 0 (niveau, qui
#       controle les points critiques). N_SIM = 4e5 series AR(1) stationnaires
#       a T = 8 (z_1 = e_1, z_t = rho z_{t-1} + sqrt(1 - rho^2) e_t, memes
#       innovations e pour tous les rho), tirees dans un seul flux
#       engine_sous_graine(SEED_SIM = 20261031), generateur ENGINE_RNG_KIND.
#       Statistique : DW = sum (zc_t - zc_{t-1})^2 / sum zc_t^2 sur la serie
#       centree zc, formule matricielle (controle S0 : identique a stat_dw()
#       du moteur sur 100 series, 1e-12). Points critiques bilateraux de la
#       loi nulle exacte, P0(DW <= d_bas) = P0(DW >= d_haut) = alpha / 2, par
#       .imhof_p_sup0() sur .dw_valeurs_propres(8) et uniroot() (copie
#       declaree du calcul de dw_puissance_ar1() et de mesure_lb1_dw_t8.R :
#       cette loi nulle est celle de dw_p_exacte(), seule l'alternative est
#       recoupee) ; controle S1 : la region [d_bas, d_haut] equivaut a
#       dw_p_exacte() < alpha sur 300 series simulees (desaccords, tolerance
#       0). Controles S-rho-alpha : |frequence de rejet - valeur d'Imhof| <=
#       3 erreurs-types, erreur-type binomiale sqrt(p (1 - p) / N_SIM) avec p la
#       valeur d'Imhof (au plus 7,9e-4 a N_SIM = 4e5, donc <= 1e-3). A rho = 0,
#       la valeur de reference est alpha (niveau exact).
#
#  Usage (depuis la racine du depot ; LC_ALL=C.UTF-8 sous Linux, #113) :
#      Rscript tests/mesure_dw_rho_negatif_t8.R
#      Rscript tests/mesure_dw_rho_negatif_t8.R --essai
#      Rscript tests/mesure_dw_rho_negatif_t8.R --ecrire --issue 164
#  --essai (M39, mode d'essai des scripts de mesure hors CI) : grille reduite
#  (rho dans {-1 + 1e-6 ; -0,9999 ; -0,99 ; 0}, alpha = 0,10) et recoupement REDUIT (rho = -0,99,
#  alpha = 0,10, N_SIM = 2e4, meme graine ; erreur-type plus grande, controle
#  S1 sur 300 series), marques en sortie, NON versionnables (--ecrire refuse
#  avec --essai) ; annonce la duree estimee d'une execution COMPLETE (part
#  fixe mesuree + nombre d'appels de dw_puissance_ar1() de l'execution
#  complete x duree moyenne mesuree par appel + duree du recoupement
#  proportionnelle a N_SIM x nombre de rho, points critiques et S1 comptes
#  par seuil ; extrapolation).
#  Les controles s'appliquent et le code de sortie suit les controles, comme
#  pour une execution complete (un script perime echoue donc a l'essai).
#  --ecrire --issue N : ecrit, si tous les controles tiennent,
#  docs/tableaux/<AAAAMMJJ>-issue<N>-dw-rho-negatif.md (date du jour ;
#  plateforme, SHA de HEAD, md5 du moteur, empreintes du script et de
#  tests/outils_tests.R) ; --issue est obligatoire avec --ecrire, refuse sans.
#  Sans --ecrire, rien n'est ecrit. Gardes anticipees (avant tout calcul)
#  puis finales (avant d'ecrire), comme les autres scripts (#205, #173) :
#  docs/tableaux/ doit exister ; refus (code 1, rien d'ecrit) si le commit lu
#  par commit_depot() n'est pas un SHA nu (arbre de travail modifie, script
#  non suivi ou git indisponible) ; refus si le fichier cible est suivi par
#  git (ce script n'a pas d'option --remplacer, comme mesure_lb1_dw_t8.R).
#  Le tableau se produit donc apres le commit du script.
#  Duree : voir la ligne "Duree" de la console.
#  Code de sortie : 0 si les controles tiennent, 1 sinon.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/mesure_dw_rho_negatif_t8.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113) ------------------------------
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break

# --- Options (avant tout chargement du moteur) -------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
local({
  i <- 1L
  while (i <= length(ARGS)) {
    a <- ARGS[i]
    if (a == "--issue") {
      if (sum(ARGS == "--issue") > 1L) stop("option --issue donnee plusieurs fois")
      if (i == length(ARGS)) stop("option --issue sans valeur")
      i <- i + 2L
    } else if (a %in% c("--ecrire", "--essai")) i <- i + 1L
    else stop("option inconnue : ", a)
  }
})
OPT_ECRIRE <- "--ecrire" %in% ARGS
OPT_ESSAI  <- "--essai" %in% ARGS
OPT_ISSUE  <- if ("--issue" %in% ARGS) ARGS[match("--issue", ARGS) + 1L] else NA_character_
if (OPT_ECRIRE && OPT_ESSAI) stop("--ecrire : refuse avec --essai (execution d'essai, non versionnable)")
if (OPT_ECRIRE && (is.na(OPT_ISSUE) || !grepl("^[1-9][0-9]*$", OPT_ISSUE)))
  stop("--ecrire exige --issue N (N entier positif, issue de rattachement du tableau)")
if (!OPT_ECRIRE && !is.na(OPT_ISSUE)) stop("--issue : reserve a --ecrire")

# --- Chargement du moteur et des outils --------------------------------------
DOSSIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) dirname(f) else if (file.exists("tests/outils_tests.R")) "tests" else "."
})
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))

DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
NOM_FICHIER <- if (OPT_ECRIRE) sprintf("%s-issue%s-dw-rho-negatif.md", DATE_SORTIE, OPT_ISSUE) else NA_character_
CHEMIN_ECRIT <- if (OPT_ECRIRE) file.path(RACINE, "docs", "tableaux", NOM_FICHIER) else NA_character_
# Empreintes du code execute : md5 de ce script et de tests/outils_tests.R ;
# "hors depot" si le script execute n'est pas celui du depot (copie declaree
# de empreintes_code() de tests/mesure_lb1_dw_t8.R).
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
# tests/mesure_lb1_dw_t8.R).
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
ALPHA <- "\u03b1"
RHO <- "\u03c1"

# --- Parametres ----------------------------------------------------------------
T_ <- 8L
RHO_GARDE <- -1 + 1e-6   # garde de dw_puissance_ar1() : 1 - |rho| = 1e-6
RHO_1E4 <- -0.9999       # 1 - |rho| = 1e-4
RHOS_COMPLET <- c(RHO_GARDE, -0.99999, RHO_1E4, -0.999, -0.99, -0.98, -0.95, -0.9, -0.8, -0.7, -0.5, -0.3, 0)
ALPHAS_COMPLET <- c(0.10, 0.05)
RHOS <- if (OPT_ESSAI) c(RHO_GARDE, RHO_1E4, -0.99, 0) else RHOS_COMPLET
ALPHAS <- if (OPT_ESSAI) 0.10 else ALPHAS_COMPLET
N_APPELS_LIENS <- 3L   # rho = -0,5 ; -0,3 ; -0,6 (alpha = 0,10), controles L
N_APPELS_DETERM <- 1L  # second appel du controle D1
SEED_SIM <- 20261031   # graine du recoupement simule (section 2), engine_sous_graine()
RHOS_SIM_COMPLET <- c(0, -0.9, -0.99)
RHOS_SIM <- if (OPT_ESSAI) -0.99 else RHOS_SIM_COMPLET
ALPHAS_SIM <- if (OPT_ESSAI) 0.10 else ALPHAS_COMPLET
N_SIM_COMPLET <- 400000L
N_SIM <- if (OPT_ESSAI) 20000L else N_SIM_COMPLET
N_S1 <- 300L           # series du controle S1 (reparties entre les rho simules)
TOL_NIVEAU <- 1e-8     # tolerance de test_lois_exactes.R (rho = 0 rend alpha)
TOL_6DEC <- 1e-6
TOL_3DEC <- 5e-4       # demi-pas d'arrondi d'une valeur a trois decimales
ATT_FICHE <- 0.277840  # rho = -0,5, alpha = 0,10 (test_lois_exactes.R, fiche DW, #116)
ATT_LB1 <- c("-0.3" = 0.163, "-0.6" = 0.355)   # mesure_lb1_dw_t8.R, alpha = 0,10

# Controles : data.frame cumule (id, libelle, obtenu, attendu, tolerance, ok).
CTRL <- data.frame(id = character(0), libelle = character(0), obtenu = numeric(0), attendu = numeric(0),
                   tolerance = numeric(0), ok = logical(0), stringsAsFactors = FALSE)
ctrl <- function(id, libelle, obtenu, attendu, tol) {
  ok <- length(obtenu) == 1L && is.finite(obtenu) && abs(obtenu - attendu) <= tol
  CTRL[nrow(CTRL) + 1L, ] <<- list(id, libelle, obtenu, attendu, tol, ok)
  invisible(ok)
}

###############################################################################
# 1. Grille de puissances : dw_puissance_ar1(8, rho, alpha)
###############################################################################
t_grille <- Sys.time()
PUIS <- matrix(NA_real_, length(RHOS), length(ALPHAS), dimnames = list(vapply(RHOS, format, ""), vapply(ALPHAS, format, "")))
n_appels <- 0L
for (j in seq_along(ALPHAS)) {
  for (i in seq_along(RHOS)) {
    PUIS[i, j] <- dw_puissance_ar1(T_, RHOS[i], ALPHAS[j])
    n_appels <- n_appels + 1L
  }
}
duree_grille <- as.numeric(difftime(Sys.time(), t_grille, units = "secs"))

###############################################################################
# Controles (section "Controles" de la sortie)
###############################################################################
# D1 : determinisme (second appel, meme valeur a l'identique).
t_d <- Sys.time()
p_d <- dw_puissance_ar1(T_, -0.99, 0.10)
n_appels <- n_appels + 1L
ctrl("D1", "d\u00e9terminisme : second appel de dw_puissance_ar1(8, -0,99, 0,10) contre la valeur de la grille (\u00e9cart)",
     p_d - PUIS[format(-0.99), format(0.10)], 0, 0)
# N, M, B : par seuil.
for (a in ALPHAS) {
  p <- PUIS[, format(a)]
  ctrl(sprintf("N-a%s", num(a, 2)), sprintf("niveau : puissance \u00e0 \u03c1 = 0 contre \u03b1 = %s", num(a, 2)),
       p[[format(0)]], a, TOL_NIVEAU)
  o <- order(abs(RHOS))
  ctrl(sprintf("M-a%s", num(a, 2)),
       sprintf("constat sur la grille \u00e0 T = 8 (non garanti en g\u00e9n\u00e9ral) : paires voisines (\\|\u03c1\\| croissant, \u03c1 = 0 compris) o\u00f9 la puissance ne cro\u00eet pas, \u03b1 = %s", num(a, 2)),
       sum(diff(p[o]) <= 0), 0, 0)
  ctrl(sprintf("B-a%s", num(a, 2)),
       sprintf("constat sur la grille \u00e0 T = 8 (non garanti en g\u00e9n\u00e9ral) : points \u03c1 < 0 o\u00f9 la puissance ne d\u00e9passe pas \u03b1 = %s", num(a, 2)),
       sum(p[RHOS < 0] <= a), 0, 0)
}
# C : stabilite du coefficient deficit / (1 - |rho|)^(1/2) de 1e-4 a 1e-6.
coef_deficit <- function(r, a) (1 - PUIS[format(r), format(a)]) / sqrt(1 + r)
for (a in ALPHAS) {
  c4 <- coef_deficit(RHO_1E4, a)
  ctrl(sprintf("C-a%s", num(a, 2)),
       sprintf("constat \u00e0 T = 8 : d\u00e9ficit / (1 \u2212 \\|\u03c1\\|)^\u00bd, \u03c1 = \u22121 + 10^\u22126 contre \u03c1 = \u22120,9999 (obtenu et attendu = coefficients), \u03b1 = %s ; tol\u00e9rance = 10^\u22123 en relatif",
               num(a, 2)),
       coef_deficit(RHO_GARDE, a), c4, 1e-3 * c4)
}
# L : liens aux valeurs versionnees (alpha = 0,10), un appel propre par point.
p_l5 <- dw_puissance_ar1(T_, -0.5, 0.10)
p_l3 <- dw_puissance_ar1(T_, -0.3, 0.10)
p_l6 <- dw_puissance_ar1(T_, -0.6, 0.10)
n_appels <- n_appels + N_APPELS_LIENS
ctrl("L-0,5", "dw_puissance_ar1(8, -0,5, 0,10) contre 0,277840 (test_lois_exactes.R, fiche DW, #116)", p_l5, ATT_FICHE, TOL_6DEC)
ctrl("L-0,3", "dw_puissance_ar1(8, -0,3, 0,10) contre 0,163 (mesure_lb1_dw_t8.R, 20261020-mesure-lb1-dw-t8.md)", p_l3, ATT_LB1[["-0.3"]], TOL_3DEC)
ctrl("L-0,6", "dw_puissance_ar1(8, -0,6, 0,10) contre 0,355 (mesure_lb1_dw_t8.R, 20261020-mesure-lb1-dw-t8.md)", p_l6, ATT_LB1[["-0.6"]], TOL_3DEC)
duree_controles <- as.numeric(difftime(Sys.time(), t_d, units = "secs"))

###############################################################################
# 2. Recoupement par simulation (independant d'Imhof pour l'alternative)
###############################################################################
# Statistique DW et AR(1) stationnaire sur les lignes d'une matrice (copies
# declarees de stat_dw_mat() et ar1_mat() de tests/mesure_lb1_dw_t8.R).
dw_mat <- function(Z) { zc <- Z - rowMeans(Z); rowSums((zc[, -1L, drop = FALSE] - zc[, -T_, drop = FALSE])^2) / rowSums(zc^2) }
ar1_mat <- function(E, rho) {
  Z <- E; s <- sqrt(1 - rho^2)
  for (t in 2:T_) Z[, t] <- rho * Z[, t - 1L] + s * E[, t]
  Z
}
# Points critiques de la loi nulle (copie declaree du calcul de
# dw_puissance_ar1() et de points_critiques_dw() de mesure_lb1_dw_t8.R).
LAM_DW <- .dw_valeurs_propres(T_)
points_critiques_dw <- function(alpha) {
  p0_sup <- function(d) .imhof_p_sup0(LAM_DW - d)
  lo <- min(LAM_DW) + 1e-9; hi <- max(LAM_DW) - 1e-9
  c(bas  = stats::uniroot(function(d) (1 - p0_sup(d)) - alpha / 2, c(lo, hi), tol = 1e-12)$root,
    haut = stats::uniroot(function(d) p0_sup(d) - alpha / 2, c(lo, hi), tol = 1e-12)$root)
}
t_sim <- Sys.time()
E_SIM <- engine_sous_graine(SEED_SIM, matrix(stats::rnorm(N_SIM * T_), N_SIM, T_))
DW_SIM <- lapply(RHOS_SIM, function(r) dw_mat(ar1_mat(E_SIM, r)))
names(DW_SIM) <- vapply(RHOS_SIM, format, "")
duree_tirage <- as.numeric(difftime(Sys.time(), t_sim, units = "secs"))
# S0 : statistique matricielle contre stat_dw() du moteur.
ctrl("S0", "statistique DW matricielle contre stat_dw() du moteur, 100 s\u00e9ries simul\u00e9es (\u00e9cart max)",
     max(abs(DW_SIM[[1L]][1:100] - vapply(1:100, function(i) stat_dw(ar1_mat(E_SIM[i, , drop = FALSE], RHOS_SIM[1L])[1L, ]), 0))), 0, 1e-12)
t_pc <- Sys.time()
PTS <- lapply(ALPHAS_SIM, points_critiques_dw); names(PTS) <- vapply(ALPHAS_SIM, format, "")
# S1 : region critique [d_bas, d_haut] contre dw_p_exacte() < alpha.
n_s1 <- N_S1 %/% length(RHOS_SIM)
for (a in ALPHAS_SIM) {
  d <- PTS[[format(a)]]; desacc <- 0L
  for (k in names(DW_SIM)) {
    r <- RHOS_SIM[match(k, names(DW_SIM))]
    for (i in seq_len(n_s1)) {
      z <- ar1_mat(E_SIM[i, , drop = FALSE], r)[1L, ]; ds <- DW_SIM[[k]][i]
      if (!identical(ds <= d[["bas"]] || ds >= d[["haut"]], dw_p_exacte(z) < a)) desacc <- desacc + 1L
    }
  }
  ctrl(sprintf("S1-a%s", num(a, 2)), sprintf("r\u00e9gion critique de DW contre dw_p_exacte() < \u03b1 = %s, %d s\u00e9ries \u00d7 %d \u03c1 (d\u00e9saccords)",
                                              num(a, 2), n_s1, length(RHOS_SIM)), desacc, 0, 0)
}
duree_pc <- as.numeric(difftime(Sys.time(), t_pc, units = "secs"))
# S-rho-alpha : frequence de rejet simulee contre la valeur d'Imhof (grille).
SIM <- do.call(rbind, lapply(RHOS_SIM, function(r) do.call(rbind, lapply(ALPHAS_SIM, function(a) {
  d <- PTS[[format(a)]]; x <- DW_SIM[[format(r)]]
  imhof <- PUIS[format(r), format(a)]
  sim <- mean(x <= d[["bas"]] | x >= d[["haut"]]); se <- sqrt(imhof * (1 - imhof) / N_SIM)
  ctrl(sprintf("S-r%s-a%s", num(r, 2), num(a, 2)),
       sprintf("puissance simul\u00e9e (N = %d) contre Imhof, \u03c1 = %s, \u03b1 = %s (3 erreurs-types)", N_SIM, num(r, 2), num(a, 2)),
       sim, imhof, 3 * se)
  data.frame(rho = r, alpha = a, imhof = imhof, sim = sim, se = se)
}))))
duree_sim <- as.numeric(difftime(Sys.time(), t_sim, units = "secs"))
INTEGRITE <- all(CTRL$ok)

###############################################################################
# Sortie
###############################################################################
sortie <- character(0)
ajouter <- function(...) sortie <<- c(sortie, ...)

# rho proches de -1 : sans zeros finaux (num(-0,9999, 3) rendrait -1,000).
lib_rho <- function(r) if (r == 0) "0 (contr\u00f4le de niveau)" else if (r < -0.999) sub(".", ",", sub("0+$", "", sprintf("%.6f", r)), fixed = TRUE) else num(r, 3)
lignes <- vapply(seq_along(RHOS), function(i) {
  cel <- unlist(lapply(seq_along(ALPHAS), function(j) c(num(PUIS[i, j], 4), num(1 - PUIS[i, j], 4))))
  ligne_md(lib_rho(RHOS[i]), if (RHOS[i] == 0) "\u2014" else sci(1 + RHOS[i]), paste(cel, collapse = " | "))
}, "")
cols_a <- unlist(lapply(ALPHAS, function(a) c(sprintf("Puissance (%s = %s)", ALPHA, num(a, 2)), "1 \u2212 puissance")))
ajouter("## Puissance du test de Durbin-Watson \u00e0 T = 8 contre un AR(1) \u00e0 \u03c1 n\u00e9gatif (#164)", "",
        if (OPT_ESSAI) c(paste0("**Essai (--essai) : non versionnable.** Grille r\u00e9duite (\u03c1 \u2208 {\u22121 + 10^\u22126 ; \u22120,9999 ; \u22120,99 ; 0}, ", ALPHA,
                                " = 0,10) ; l'ex\u00e9cution compl\u00e8te porte sur ", length(RHOS_COMPLET), " valeurs de \u03c1 et 2 seuils. Recoupement par simulation r\u00e9duit \u00e0 \u03c1 = \u22120,99, ", ALPHA,
                                " = 0,10, N = ", format(N_SIM, scientific = FALSE), " (ex\u00e9cution compl\u00e8te : \u03c1 \u2208 {0 ; \u22120,9 ; \u22120,99}, 2 seuils, N = ",
                                format(N_SIM_COMPLET, scientific = FALSE), ")."), ""),
        paste0("Statut : approximation num\u00e9rique d'Imhof d'une quantit\u00e9 exacte, recoup\u00e9e par simulation \u00e0 ", if (OPT_ESSAI) "\u03c1 = \u22120,99 (essai)" else "\u03c1 = \u22120,9 et \u22120,99", " ; \u03c1 \u2264 \u22120,999 non recoup\u00e9s ; loi de DW sous H0 pour z i.i.d. N(0,1), puissance sous un AR(1) stationnaire, alternative hors mod\u00e8le r\u00e9glementaire (l'annexe XVII suppose des ann\u00e9es ind\u00e9pendantes ; l'AR(1) est une alternative choisie) ; z n'est pas le vecteur de r\u00e9sidus r\u00e9ajust\u00e9s du moteur. La grille d'Imhof est d\u00e9terministe ; seul le recoupement tire, sous une graine consign\u00e9e en T0."), "",
        "Cadre : T = 8 ; z gaussien centr\u00e9, i.i.d. N(0,1) sous H0, AR(1) stationnaire de matrice de covariance (\u03c1^|i\u2212j|) sous l'alternative ; sans r\u00e9ajustement ; statistique calcul\u00e9e sur la s\u00e9rie centr\u00e9e. Test bilat\u00e9ral exact de `dw_p_exacte()` (p = 2 min(P0(DW \u2264 d), P0(DW \u2265 d)), rejet si p < \u03b1), puissance par `dw_puissance_ar1(8, \u03c1, \u03b1)`. Variante \u00e0 d\u00e9part nul : non calcul\u00e9e (`dw_puissance_ar1()` ne porte que l'AR(1) stationnaire).", "",
        "### 1. Puissance de DW par \u03c1", "",
        entete_md(c(RHO, "1 \u2212 \\|\u03c1\\|", cols_a)),
        lignes, "",
        paste0("\u00ab 1 \u2212 puissance \u00bb : d\u00e9ficit de puissance, la quantit\u00e9 qui tend vers 0 quand \u03c1 \u2192 \u22121. Le moteur refuse \u03c1 < \u22121 + 10^\u22126 (garde de `dw_puissance_ar1()`) ; le point le plus proche de \u22121 de la grille, \u03c1 = \u22121 + 10^\u22126, est la garde elle-m\u00eame (1 \u2212 |\u03c1| = 10^\u22126, admis)."), "")

# Loi du d\u00e9ficit pr\u00e8s de \u03c1 = \u22121 : coefficient d\u00e9ficit / (1 \u2212 |\u03c1|)^\u00bd, 1 \u2212 |\u03c1| lu comme 1 + \u03c1.
neg <- which(RHOS < 0)
ajouter("### 1 bis. D\u00e9ficit rapport\u00e9 \u00e0 (1 \u2212 |\u03c1|)^\u00bd", "",
        paste0("Coefficient = (1 \u2212 puissance) / (1 \u2212 |\u03c1|)^\u00bd, 1 \u2212 |\u03c1| lu comme 1 + \u03c1 ; mesure pour \u03c1 < 0 de la grille, hors recoupement par simulation. Constat \u00e0 T = 8 : \u00e0 1 \u2212 |\u03c1| = 10^\u22124 et 10^\u22126, les deux coefficients diff\u00e8rent de moins de 10^\u22123 en relatif (contr\u00f4le C) ; la loi en (1 \u2212 |\u03c1|)^\u00bd est celle que rel\u00e8ve le commentaire de `dw_puissance_ar1()`. Au-del\u00e0 de la garde, non \u00e9valu\u00e9 ici."), "",
        entete_md(c(RHO, "1 \u2212 \\|\u03c1\\|", unlist(lapply(ALPHAS, function(a) sprintf("D\u00e9ficit / (1 \u2212 \\|\u03c1\\|)^\u00bd (%s = %s)", ALPHA, num(a, 2)))))),
        vapply(neg, function(i) ligne_md(lib_rho(RHOS[i]), sci(1 + RHOS[i]),
                                         paste(vapply(ALPHAS, function(a) num(coef_deficit(RHOS[i], a), 4), ""), collapse = " | ")), ""), "")

# Signe des ecarts simule - Imhof : constat calcule ; explication proposee
# seulement si tous les ecarts (au moins deux) sont negatifs.
n_neg <- sum(SIM$sim - SIM$imhof < 0)
phrase_signes <- if (n_neg == nrow(SIM) && nrow(SIM) > 1L) {
  sprintf(" Constat : les %d \u00e9carts simul\u00e9 \u2212 Imhof sont tous n\u00e9gatifs. Explication propos\u00e9e, non test\u00e9e par ce script : les innovations e sont communes \u00e0 tous les \u03c1 et les deux seuils d'un m\u00eame \u03c1 reposent sur les m\u00eames s\u00e9ries, donc les fr\u00e9quences de rejet sont corr\u00e9l\u00e9es et le signe commun ne se lit pas comme %d \u00e9vidences ind\u00e9pendantes d'un \u00e9cart d'Imhof (le crit\u00e8re de validit\u00e9 reste le contr\u00f4le S, \u00e0 3 erreurs-types).", nrow(SIM), nrow(SIM))
} else sprintf(" Constat : %d \u00e9cart(s) simul\u00e9 \u2212 Imhof n\u00e9gatif(s) sur %d.", n_neg, nrow(SIM))
ajouter("### 2. Recoupement par simulation (ind\u00e9pendant d'Imhof pour l'alternative)", "",
        sprintf("N = %s s\u00e9ries AR(1) stationnaires \u00e0 T = 8 par \u03c1 (z_1 = e_1, z_t = \u03c1 z_{t\u22121} + \u221a(1 \u2212 \u03c1\u00b2) e_t, m\u00eames innovations pour tous les \u03c1), graine %s sous `engine_sous_graine()`, g\u00e9n\u00e9rateur %s. Statistique DW sur la s\u00e9rie centr\u00e9e (formule matricielle, contr\u00f4le S0 contre `stat_dw()`) ; points critiques bilat\u00e9raux de la loi nulle exacte (copie d\u00e9clar\u00e9e du calcul de `dw_puissance_ar1()`, contr\u00f4le S1 contre `dw_p_exacte()`). Erreur-type = sqrt(p(1 \u2212 p)/N) avec p la valeur d'Imhof (au plus %s ici%s). \u03c1 = 0 : niveau (valeur de r\u00e9f\u00e9rence \u03b1). Les \u03c1 \u2264 \u22120,999 ne sont pas recoup\u00e9s.%s",
                format(N_SIM, scientific = FALSE), format(SEED_SIM, scientific = FALSE), paste(ENGINE_RNG_KIND, collapse = ", "), sci(max(SIM$se)),
                if (max(SIM$se) <= 1e-3) ", soit \u2264 10^\u22123" else " : N r\u00e9duit de l'essai, > 10^\u22123",
                phrase_signes), "",
        entete_md(c(RHO, ALPHA, "Imhof (grille)", "Simul\u00e9 \u00b1 erreur-type", "Simul\u00e9 \u2212 Imhof", "\u00c9cart en erreurs-types")),
        vapply(seq_len(nrow(SIM)), function(i) with(SIM[i, ], ligne_md(num(rho, 2), num(alpha, 2), num(imhof, 5), sprintf("%s \u00b1 %s", num(sim, 5), num(se, 5)),
                                                                     num(sim - imhof, 5), num((sim - imhof) / se, 2))), ""), "")

fmt_ctrl <- function(g) if (abs(g) < 1e-3 && g != 0) sci(g) else num(g, 6)
ajouter("### Contr\u00f4les", "",
        entete_md(c("Id", "Contr\u00f4le", "Obtenu", "Attendu", "\u00c9cart", "Tol\u00e9rance", "Statut")),
        vapply(seq_len(nrow(CTRL)), function(i) with(CTRL[i, ], ligne_md(id, libelle, fmt_ctrl(obtenu), fmt_ctrl(attendu),
                                                              fmt_ctrl(obtenu - attendu), fmt_ctrl(tolerance), if (ok) "OK" else "**\u00c9CHEC**")), ""),
        "", sprintf("%d contr\u00f4les, %d en \u00e9chec.", nrow(CTRL), sum(!CTRL$ok)), "")

# Duree estimee d'une execution complete (--essai, M39) : part fixe (de
# l'ouverture du script au debut de la grille, chargement du moteur compris)
# + nombre d'appels d'une execution complete x duree moyenne mesuree par
# appel (grille et controles) ; extrapolation, bruitee quand peu d'appels.
duree_fixe <- as.numeric(difftime(t_grille, t_debut, units = "secs"))
duree_appel <- (duree_grille + duree_controles) / n_appels
n_complet <- length(RHOS_COMPLET) * length(ALPHAS_COMPLET) + N_APPELS_DETERM + N_APPELS_LIENS
# Recoupement : tirage et statistiques proportionnels a N_SIM x nombre de rho ;
# points critiques et controle S1 comptes par seuil.
duree_sim_var <- duree_tirage * (N_SIM_COMPLET * length(RHOS_SIM_COMPLET)) / (N_SIM * length(RHOS_SIM))
duree_sim_pc <- duree_pc / length(ALPHAS_SIM) * length(ALPHAS_COMPLET)
duree_estimee <- duree_fixe + n_complet * duree_appel + duree_sim_var + duree_sim_pc
LIB_DUREE <- "Dur\u00e9e estim\u00e9e d'une ex\u00e9cution compl\u00e8te (--essai)"

T0 <- c("### T0", "",
        entete_md(c("Grandeur", "Valeur")),
        ligne_md("Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)", plateforme_calcul()),
        ligne_md("Al\u00e9a", sprintf("recoupement simul\u00e9 seul : engine_sous_graine(%s), g\u00e9n\u00e9rateur %s ; grille d'Imhof sans al\u00e9a",
                                      format(SEED_SIM, scientific = FALSE), paste(ENGINE_RNG_KIND, collapse = ", "))),
        ligne_md("N (s\u00e9ries simul\u00e9es par \u03c1)", format(N_SIM, scientific = FALSE)),
        ligne_md("Commit (HEAD)", COMMIT),
        ligne_md("md5 de R/engine.R", MD5_MOTEUR),
        ligne_md("Empreintes du code (script ex\u00e9cut\u00e9, outils charg\u00e9s)", empreintes_code()),
        ligne_md("Appels de dw_puissance_ar1()", sprintf("%d (grille : %d ; contr\u00f4les : %d)", n_appels,
                                                           length(RHOS) * length(ALPHAS), N_APPELS_DETERM + N_APPELS_LIENS)),
        if (OPT_ESSAI) ligne_md(LIB_DUREE, sprintf("%.0f s (part fixe %.1f s + %d appels \u00d7 %.2f s + recoupement %.1f s ; extrapolation de %d appels et de N = %s)",
                                                    duree_estimee, duree_fixe, n_complet, duree_appel, duree_sim_var + duree_sim_pc, n_appels,
                                                    format(N_SIM, scientific = FALSE))),
        ligne_md("Script", sprintf("%s%s (hors CI ; protocole dans l'en-t\u00eate)", SCRIPT,
                                   if (OPT_ECRIRE) sprintf(" --ecrire --issue %s", OPT_ISSUE) else if (OPT_ESSAI) " --essai" else "")),
        "")

duree <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
ecrire_console(c(sortie, T0, sprintf("Dur\u00e9e totale : %.1f s.", duree)))

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
