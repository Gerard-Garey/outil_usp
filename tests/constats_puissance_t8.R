###############################################################################
#  tests/constats_puissance_t8.R  --  REPRODUCTION DE DEUX CONSTATS DE
#  NIVEAU ET DE PUISSANCE A T = 8 (issue #114)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  Il n'ecrit aucun fichier : sortie en markdown sur la console (UTF-8).
#  R base + stats.
#
#  Objet : deux constats cites dans le projet sans que leur script ait ete
#  versionne (decision du mainteneur du 27/09/2026, issue #114).
#
#  C1. Puissance du test des suites contre Durbin-Watson exact (commentaire
#      d'actuary du 23/09/2026 sur l'issue #44) : "20 000 AR(1) gaussiens de
#      longueur 8, alpha = 0,10, indicatif, hors modele USP ; rho = 0,3 /
#      0,5 / 0,7 / 0,9 -> suites 0,080 / 0,118 / 0,175 / 0,247, Durbin-Watson
#      exact 0,163 / 0,268 / 0,395 / 0,529". Statut : CONSTAT DE SIMULATION,
#      HORS MODELE REGLEMENTAIRE (l'annexe XVII suppose des annees
#      independantes ; l'AR(1) est une alternative choisie pour mesurer la
#      puissance, pas un modele du dossier).
#      Protocole retenu (le commentaire ne precise ni l'initialisation ni la
#      regression sous-jacente) :
#        - e_1..e_8 i.i.d. N(0,1) ; variante principale STATIONNAIRE,
#          u_1 = e_1 / sqrt(1 - rho^2), u_t = rho u_{t-1} + e_t ; variante
#          secondaire DEPART NUL, u_1 = e_1 (non stationnaire, variance
#          croissante) ; memes innovations pour tous les rho et les deux
#          variantes (nombres aleatoires communs) ;
#        - les deux tests sont appliques a la serie u elle-meme, par les
#          fonctions du moteur : runs_p_exacte() (loi de Swed & Eisenhart aux
#          effectifs de part et d'autre de la mediane, doublement, M8) et
#          dw_p_exacte() (statistique sur la serie CENTREE, soit les residus
#          de la regression sur la seule constante ; loi exacte d'Imhof ; p
#          bilaterale 2 min(P(DW <= d), P(DW >= d))). Le moteur les applique
#          aux residus standardises z ; a pi chapeau constant, z est une
#          transformation affine croissante des log-ratios (usp_noyau()), et
#          les deux p-values sont invariantes par une telle transformation
#          (controle d'integrite ci-dessous) : appliquer les tests a u revient
#          a traiter u comme les log-ratios d'un jeu a pi constant ;
#        - rejet si p < alpha (verdict different de OK dans add()) ;
#        - ligne rho = 0 ajoutee (niveau : 4/70 = 0,0571 exactement pour les
#          suites a T = 8 sans ex aequo, alpha pour Durbin-Watson).
#
#  C2. "0 rejet sur 3 000 a 5 %" du Kolmogorov-Smirnov contre N(0,1)
#      (detail de la ligne dans usp_tests() ; fiche et tableau 1 du .tex).
#      Le protocole n'est pas ecrit ; trois lectures sont mesurees, plus une
#      ligne de reference :
#        K0 (reference, parametres CONNUS) : echantillons N(0,1) de taille 8,
#           D contre N(0,1) sans standardisation ;
#        K1 (residus du moteur, lecture du detail : "standardises par le
#           MODELE") : jeux simules sous le modele ajuste au jeu J1
#           (tests/donnees/donnees_ln.csv) par usp_simuler(), le generateur du
#           bootstrap parametrique, reajustes par usp_ajuster(), D = stat_ks()
#           sur les residus z du reajustement (statistique du catalogue KS) ;
#        K2 (lecture de la fiche : "parametres estimes") : echantillons N(0,1)
#           standardises par la moyenne et l'ecart-type empiriques (s en T-1) ;
#        K3 : idem, ecart-type du maximum de vraisemblance (s en T), soit les
#           z du moteur quand pi chapeau est constant (usp_noyau()).
#      p-value : formule de Kolmogorov de la ligne de usp_tests(), transcrite
#      dans p_kolmogorov() (transcription controlee contre run_engine() sur
#      J1) ; rejet si p < 0,05. Statut : constat de simulation du niveau
#      (K1 : sous le modele reglementaire ajuste ; K0, K2, K3 : sous
#      l'hypothese de normalite i.i.d.).
#      Convergence des reajustements K1 : un reajustement est ECARTE seulement
#      s'il echoue (erreur de usp_ajuster()) ou rend des z non finis ; ceux
#      dont l'optimum retenu a un code optim() `convergence` != 0 (arret sur
#      maxit, 1, ou message L-BFGS-B, 52) sont GARDES dans le taux, comme le
#      moteur les garde dans run_engine(), mais comptes et signales dans la
#      sortie : nombre, codes, rejets parmi eux, nombre de reajustements sans
#      aucun demarrage a l'optimum de code 0 (n_starts_optimum_code0 = 0) et
#      minimum de n_starts_optimum (demarrages a l'optimum, sur 54).
#
#  Incertitude : intervalle de Clopper-Pearson a 95 % sur chaque taux
#  (erreur Monte-Carlo, fonction de R ; elle ne dit rien de l'erreur
#  d'approximation en T). Compatibilite avec la valeur publiee :
#    C1 : la valeur publiee est elle-meme une estimation Monte-Carlo sur
#      20 000 tirages (arrondie au millieme, erreur d'arrondi <= 0,0005,
#      petite devant l'ecart-type ~0,003) ; les deux estimations sont
#      comparees par l'ecart normalise z de deux proportions independantes
#      (ecart_z()), compatibles si |z| <= 1,96 (niveau 5 % par comparaison,
#      huit comparaisons non corrigees pour la multiplicite) ;
#    C2 : taux publie 0 / 3 000 ; test exact de Fisher bilateral
#      (stats::fisher.test()) sur le tableau 2 x 2 (k, n - k ; 0, 3 000) de la
#      reproduction et du constat publie, compatible si p >= 0,05 (les deux
#      echantillons sont traites comme independants ; lectures K0 a K3 non
#      corrigees pour la multiplicite).
#
#  Alea : tout tirage passe par engine_sous_graine() avec une graine
#  explicite : innovations AR(1) sous --graine ; echantillons K0, K2, K3 sous
#  --graine + 1 ; jeux simules de K1 sous --graine + 2, tous tires en un seul
#  flux avant tout calcul.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/constats_puissance_t8.R [--R 20000] [--R-ks 3000]
#          [--graine 20260927] [--partie tout|ar1|ks]
#  Duree mesuree : voir la ligne "Duree" de la sortie.
#  Code de sortie : 0 si les controles d'integrite tiennent, 1 sinon.
###############################################################################

t_debut <- Sys.time()

# --- Options ------------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
lire_option <- function(nom, defaut) {
  i <- match(nom, ARGS)
  if (is.na(i)) return(defaut)
  if (i == length(ARGS)) stop("option ", nom, " sans valeur")
  ARGS[i + 1L]
}
OPT_R      <- as.integer(lire_option("--R", "20000"))
OPT_R_KS   <- as.integer(lire_option("--R-ks", "3000"))
OPT_GRAINE <- as.numeric(lire_option("--graine", "20260927"))
OPT_PARTIE <- lire_option("--partie", "tout")
if (!OPT_PARTIE %in% c("tout", "ar1", "ks")) stop("--partie : tout, ar1 ou ks")
if (!is.finite(OPT_R) || OPT_R < 1L) stop("--R : entier >= 1")
if (!is.finite(OPT_R_KS) || OPT_R_KS < 1L) stop("--R-ks : entier >= 1")
if (!is.finite(OPT_GRAINE)) stop("--graine : nombre")

T_ <- 8L
ALPHA_AR1 <- 0.10
ALPHA_KS <- 0.05
# Constat publie de C2 : 0 rejet sur 3 000.
K_PUB_KS <- 0L
N_PUB_KS <- 3000L
RHOS <- c(0, 0.3, 0.5, 0.7, 0.9)
# Valeurs publiees (commentaire d'actuary du 23/09/2026 sur #44) ; NA : non publiee.
PUB_SUITES <- c(NA, 0.080, 0.118, 0.175, 0.247)
PUB_DW     <- c(NA, 0.163, 0.268, 0.395, 0.529)

# --- Chargement du moteur et des outils --------------------------------------
DOSSIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) dirname(f) else if (file.exists("tests/outils_tests.R")) "tests" else "."
})
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))

# Commit du depot (meme definition que tests/taux_franchissement_reperes.R),
# complete de la mention "(script non suivi)" quand ce script n'est pas
# versionne (git ls-files --error-unmatch en echec).
commit_depot <- function() {
  git <- function(...) tryCatch(suppressWarnings(system2("git", c("-C", RACINE, ...), stdout = TRUE, stderr = FALSE)),
                                error = function(e) character(0))
  h <- git("rev-parse", "HEAD")
  if (length(h) != 1L || !grepl("^[0-9a-f]{40}$", h)) return("inconnu")
  if (length(git("status", "--porcelain", "--untracked-files=no"))) h <- paste(h, "(arbre de travail modifi\u00e9)")
  suivi <- tryCatch(suppressWarnings(system2("git", c("-C", RACINE, "ls-files", "--error-unmatch",
                                                      "tests/constats_puissance_t8.R"),
                                             stdout = FALSE, stderr = FALSE)),
                    error = function(e) 1L)
  if (!identical(as.integer(suivi), 0L)) h <- paste(h, "(script non suivi)")
  h
}

# Console en UTF-8 quelle que soit la locale (meme definition que
# tests/taux_franchissement_reperes.R).
ecrire_console <- function(x) writeLines(enc2utf8(x), useBytes = TRUE)

# --- Mise en forme -------------------------------------------------------------
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
num <- function(x, d = 3) if (is.na(x)) "\u2014" else sub(".", ",", sprintf(paste0("%.", d, "f"), x), fixed = TRUE)
ic_cp <- function(k, n) {
  ci <- stats::binom.test(k, n)$conf.int
  c(ci[1], ci[2])
}
txt_ic <- function(ci) sprintf("[%s ; %s]", num(ci[1]), num(ci[2]))
# Ecart normalise entre deux estimations independantes d'une meme proportion
# (reproduction sur R tirages, publication sur R_PUB) : z = (p1 - p2) /
# sqrt(pbar (1 - pbar) (1/R + 1/R_PUB)), pbar ponderee ; compatible si |z| <= 1,96.
R_PUB <- 20000
ecart_z <- function(k, n, pub) {
  pbar <- (k + pub * R_PUB) / (n + R_PUB)
  (k / n - pub) / sqrt(pbar * (1 - pbar) * (1 / n + 1 / R_PUB))
}
compat <- function(pub, k, n) if (is.na(pub)) c("\u2014", "\u2014") else {
  z <- ecart_z(k, n, pub)
  c(sub(".", ",", sprintf("%+.2f", z), fixed = TRUE), if (abs(z) <= stats::qnorm(0.975)) "oui" else "**non**")
}

INTEGRITE <- TRUE
controle <- function(ok, libelle) {
  if (!isTRUE(ok)) INTEGRITE <<- FALSE
  sprintf("%s : %s", libelle, if (isTRUE(ok)) "OK" else "ECHEC")
}

# p-value de Kolmogorov de la ligne "Kolmogorov-Smirnov contre N(0,1)" de
# usp_tests() (transcription ; controlee contre run_engine() plus bas).
p_kolmogorov <- function(dd, T) {
  if (is.finite(dd)) .p_borne(2 * sum((-1)^(0:99) * exp(-2 * (1:100)^2 * T * dd^2))) else NA_real_
}

sortie <- c(
  "## Constats de niveau et de puissance \u00e0 T = 8 (issue #114)", "",
  sprintf("Param\u00e8tres : R=%d ; R_ks=%d ; graine=%s ; partie=%s ; T=%d", OPT_R, OPT_R_KS,
          format(OPT_GRAINE, scientific = FALSE), OPT_PARTIE, T_), "",
  entete_md(c("Grandeur", "Valeur")),
  ligne_md("Plateforme", plateforme()),
  ligne_md("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
  ligne_md("Commit", commit_depot()),
  ligne_md("Script", "tests/constats_puissance_t8.R (hors CI ; protocole dans l'en-t\u00eate)"), "")
controles <- character(0)

# --- C1 : AR(1), suites contre Durbin-Watson ----------------------------------
if (OPT_PARTIE %in% c("tout", "ar1")) {
  E <- engine_sous_graine(OPT_GRAINE, matrix(stats::rnorm(OPT_R * T_), nrow = OPT_R))
  serie_ar1 <- function(e, rho, stationnaire) {
    u <- numeric(length(e))
    u[1] <- if (stationnaire) e[1] / sqrt(1 - rho^2) else e[1]
    for (t in 2:length(e)) u[t] <- rho * u[t - 1] + e[t]
    u
  }
  # Controle d'invariance affine (z du moteur a pi constant = a + b u, b > 0).
  u1 <- serie_ar1(E[1, ], 0.5, TRUE)
  controles <- c(controles, controle(
    isTRUE(all.equal(dw_p_exacte(u1), dw_p_exacte(3 + 0.2 * u1), tolerance = 1e-8)) &&
      identical(runs_p_exacte(u1), runs_p_exacte(3 + 0.2 * u1)),
    "C1, invariance affine des p exactes (dw_p_exacte(), runs_p_exacte())"))
  mesurer <- function(stationnaire) {
    t(vapply(RHOS, function(rho) {
      p <- vapply(seq_len(OPT_R), function(i) {
        u <- serie_ar1(E[i, ], rho, stationnaire)
        c(runs_p_exacte(u), dw_p_exacte(u))
      }, numeric(2))
      c(k_suites = sum(p[1, ] < ALPHA_AR1), na_suites = sum(!is.finite(p[1, ])),
        k_dw = sum(p[2, ] < ALPHA_AR1), na_dw = sum(!is.finite(p[2, ])))
    }, numeric(4)))
  }
  t1 <- Sys.time()
  M_st <- mesurer(TRUE)
  M_nul <- mesurer(FALSE)
  duree_ar1 <- as.numeric(difftime(Sys.time(), t1, units = "secs"))
  controles <- c(controles, controle(all(c(M_st[, c("na_suites", "na_dw")], M_nul[, c("na_suites", "na_dw")]) == 0),
                                     "C1, aucune p-value manquante"))
  tableau_ar1 <- function(M, titre, avec_pub) {
    cols <- c("\u03c1", "Suites : taux", "IC 95 % (C-P)", if (avec_pub) c("Publi\u00e9", "z", "Compatible"),
              "DW exact : taux", "IC 95 % (C-P)", if (avec_pub) c("Publi\u00e9", "z", "Compatible"))
    lignes <- vapply(seq_along(RHOS), function(j) {
      cs <- ic_cp(M[j, "k_suites"], OPT_R); cd <- ic_cp(M[j, "k_dw"], OPT_R)
      v <- c(num(RHOS[j], 1), num(M[j, "k_suites"] / OPT_R), txt_ic(cs),
             if (avec_pub) c(num(PUB_SUITES[j]), compat(PUB_SUITES[j], M[j, "k_suites"], OPT_R)),
             num(M[j, "k_dw"] / OPT_R), txt_ic(cd),
             if (avec_pub) c(num(PUB_DW[j]), compat(PUB_DW[j], M[j, "k_dw"], OPT_R)))
      ligne_md(paste(v, collapse = " | "))
    }, "")
    c(titre, "", entete_md(cols), lignes, "")
  }
  sortie <- c(sortie,
    "### C1 -- Puissance du test des suites et de Durbin-Watson exact, AR(1) gaussien, T = 8, \u03b1 = 0,10", "",
    paste("Statut : **constat de simulation, hors mod\u00e8le r\u00e9glementaire** (l'annexe XVII suppose",
          "des ann\u00e9es ind\u00e9pendantes ; l'AR(1) est l'alternative choisie pour mesurer la puissance).",
          "Tests appliqu\u00e9s \u00e0 la s\u00e9rie par les fonctions du moteur runs_p_exacte() (loi de",
          "Swed & Eisenhart, doublement) et dw_p_exacte() (s\u00e9rie centr\u00e9e : r\u00e9sidus de la",
          "r\u00e9gression sur la constante ; loi exacte d'Imhof ; p bilat\u00e9rale par doublement) ;",
          "rejet si p < \u03b1. Ligne \u03c1 = 0 : niveau (suites : 4/70 = 0,0571 exactement ; DW : 0,10). Colonnes z et Compatible : \u00e9cart normalis\u00e9 de deux proportions ind\u00e9pendantes (reproduction, publication sur 20 000 tirages) ; compatible si |z| \u2264 1,96."), "",
    sprintf("R\u00e9plications : %d par valeur de \u03c1 (innovations communes \u00e0 tous les \u03c1 et aux deux variantes, graine %s).",
            OPT_R, format(OPT_GRAINE, scientific = FALSE)), "",
    tableau_ar1(M_st, "**C1.a -- variante principale : AR(1) stationnaire** (u_1 = e_1 / \u221a(1 \u2212 \u03c1\u00b2))", TRUE),
    tableau_ar1(M_nul, "**C1.b -- variante secondaire : d\u00e9part nul** (u_1 = e_1)", TRUE),
    sprintf("Dur\u00e9e de C1 : %.0f s.", duree_ar1), "")
}

# --- C2 : Kolmogorov-Smirnov contre N(0,1), niveau a 5 % -----------------------
if (OPT_PARTIE %in% c("tout", "ks")) {
  # Controle de la transcription de p_kolmogorov() et de stat_ks() contre la
  # ligne produite par run_engine() sur J1 (p non simulee independante de B).
  res0 <- run_engine(xt = .ln$xt, yt = .ln$yt, methode = "premium", segment = 1, annexe = "II",
                     nature_donnees = "brutes", B = 99, seed = 20260831)
  tab0 <- engine_table_tests(res0)
  l_ks <- tab0[tab0$test == "Kolmogorov-Smirnov contre N(0,1)", ]
  FIT0 <- usp_ajuster(.ln$xt, .ln$yt)
  controles <- c(controles, controle(
    nrow(l_ks) == 1L && isTRUE(all.equal(l_ks$stat, stat_ks(FIT0$z), tolerance = 1e-10)) &&
      isTRUE(all.equal(l_ks$p_asymptotique, p_kolmogorov(stat_ks(FIT0$z), T_), tolerance = 1e-10)),
    "C2, transcription de la p de Kolmogorov et de stat_ks(fit$z) (contre run_engine(), J1)"))

  t2 <- Sys.time()
  Z <- engine_sous_graine(OPT_GRAINE + 1, matrix(stats::rnorm(OPT_R_KS * T_), nrow = OPT_R_KS))
  sd_mv <- function(v) sqrt(mean((v - mean(v))^2))
  p_k0 <- apply(Z, 1, function(v) p_kolmogorov(stat_ks(v), T_))
  p_k2 <- apply(Z, 1, function(v) p_kolmogorov(stat_ks((v - mean(v)) / stats::sd(v)), T_))
  p_k3 <- apply(Z, 1, function(v) p_kolmogorov(stat_ks((v - mean(v)) / sd_mv(v)), T_))
  Y <- engine_sous_graine(OPT_GRAINE + 2, lapply(seq_len(OPT_R_KS), function(b) usp_simuler(FIT0)))
  aj <- lapply(Y, function(y) tryCatch(usp_ajuster(.ln$xt, y), error = function(e) NULL))
  ok_aj <- vapply(aj, function(f) !is.null(f) && all(is.finite(f$z)), logical(1))
  p_k1 <- vapply(aj[ok_aj], function(f) p_kolmogorov(stat_ks(f$z), T_), numeric(1))
  pi_cst <- vapply(aj[ok_aj], function(f) isTRUE(diff(range(f$pi)) <= 1e-12 * max(f$pi)), logical(1))
  # Convergence des reajustements gardes (voir l'en-tete) : code optim() de
  # l'optimum retenu, demarrages a l'optimum (tous codes, puis code 0).
  conv_k1 <- vapply(aj[ok_aj], function(f) as.integer(f$convergence), integer(1))
  n_opt_k1 <- vapply(aj[ok_aj], function(f) as.integer(f$n_starts_optimum), integer(1))
  n_opt0_k1 <- vapply(aj[ok_aj], function(f) as.integer(f$n_starts_optimum_code0), integer(1))
  duree_ks <- as.numeric(difftime(Sys.time(), t2, units = "secs"))

  ligne_ks <- function(code, libelle, p) {
    n <- sum(is.finite(p)); k <- sum(p[is.finite(p)] < ALPHA_KS); ci <- ic_cp(k, n)
    p_f <- stats::fisher.test(matrix(c(k, n - k, K_PUB_KS, N_PUB_KS - K_PUB_KS), nrow = 2L, byrow = TRUE))$p.value
    ligne_md(code, libelle, sprintf("%d / %d", k, n), num(k / n, 4), txt_ic(ci), num(p_f, 4),
             if (p_f >= 0.05) "oui" else "**non**")
  }
  sortie <- c(sortie,
    "### C2 -- Niveau du Kolmogorov-Smirnov contre N(0,1) \u00e0 5 %, T = 8 (\u00ab 0 rejet sur 3 000 \u00bb)", "",
    paste("Statut : constat de simulation du niveau. p-value : formule de Kolmogorov de la ligne de",
          "usp_tests() (transcription contr\u00f4l\u00e9e) ; D = stat_ks() du moteur ; rejet si p < 0,05.",
          "Le protocole d'origine n'est pas \u00e9crit : quatre lectures sont mesur\u00e9es. Colonne",
          "\u00ab Compatible \u00bb : test exact de Fisher bilat\u00e9ral sur le tableau 2 \u00d7 2 (k, n \u2212 k ; 0, 3 000)",
          "de la reproduction et du constat publi\u00e9 ; compatible si p \u2265 0,05 (quatre comparaisons non corrig\u00e9es",
          "pour la multiplicit\u00e9)."), "",
    entete_md(c("Lecture", "\u00c9chantillons", "Rejets / R", "Taux", "IC 95 % (C-P)", "p Fisher contre 0 / 3 000", "Compatible")),
    ligne_ks("K0", "N(0,1) i.i.d., param\u00e8tres CONNUS (r\u00e9f\u00e9rence)", p_k0),
    ligne_ks("K1", sprintf("r\u00e9sidus z de usp_ajuster() sur jeux simul\u00e9s sous le mod\u00e8le ajust\u00e9 \u00e0 J1 (usp_simuler()) ; \u03c0\u0302 constant dans %d / %d r\u00e9ajustements", sum(pi_cst), sum(ok_aj)), p_k1),
    ligne_ks("K2", "N(0,1) i.i.d. standardis\u00e9s par moyenne et \u00e9cart-type empiriques (s en T \u2212 1)", p_k2),
    ligne_ks("K3", "N(0,1) i.i.d. standardis\u00e9s par moyenne et \u00e9cart-type du MV (s en T) = z du moteur \u00e0 \u03c0\u0302 constant", p_k3),
    "",
    sprintf("R\u00e9ajustements K1 \u00e9chou\u00e9s ou non finis (\u00e9cart\u00e9s) : %d / %d. Graines : K0, K2, K3 %s ; K1 %s.",
            sum(!ok_aj), OPT_R_KS, format(OPT_GRAINE + 1, scientific = FALSE),
            format(OPT_GRAINE + 2, scientific = FALSE)),
    sprintf(paste("Convergence des r\u00e9ajustements K1 gard\u00e9s (inclus dans le taux) : code optim() de l'optimum",
                  "retenu \u2260 0 dans %d / %d (codes : %s), dont %d rejet(s) \u00e0 5 %% ; aucun d\u00e9marrage \u00e0 l'optimum",
                  "de code 0 dans %d / %d ; d\u00e9marrages \u00e0 l'optimum : minimum %s sur 54."),
            sum(conv_k1 != 0L), length(conv_k1),
            if (any(conv_k1 != 0L)) {
              tb <- table(conv_k1[conv_k1 != 0L])
              paste(sprintf("%s : %d", names(tb), as.integer(tb)), collapse = ", ")
            } else "\u2014",
            sum(p_k1[conv_k1 != 0L] < ALPHA_KS),
            sum(n_opt0_k1 == 0L), length(n_opt0_k1),
            if (length(n_opt_k1)) as.character(min(n_opt_k1)) else "\u2014"),
    sprintf("Plus petite p-value observ\u00e9e : K0 %s ; K1 %s ; K2 %s ; K3 %s.",
            num(min(p_k0), 4), num(min(p_k1), 4), num(min(p_k2), 4), num(min(p_k3), 4)),
    sprintf("Dur\u00e9e de C2 : %.0f s.", duree_ks), "")
}

duree <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
sortie <- c(sortie, "### Contr\u00f4les d'int\u00e9grit\u00e9", "", paste("-", controles), "",
            sprintf("Dur\u00e9e totale : %.0f s.", duree))
ecrire_console(sortie)
quit(status = if (INTEGRITE) 0L else 1L)
