###############################################################################
#  tests/mesure_courbure_delta_158.R  --  COURBURE EN DELTA DU CONTROLE KKT A
#  VOLUMES QUASI CONSTANTS : PLANCHER DE BRUIT, RELATION ETENDUE / COURBURE,
#  EFFETS CONTREFACTUELS DES OPTIONS DE D2-Fc (issue #158)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils et tools, livres avec R). Il ne modifie ni
#  R/engine.R, ni tests/reference/ : les options (A), (C), (C'), (D) et (E)
#  sont des CONTREFACTUELS calcules ici, a partir des fonctions du moteur
#  (usp_condition_premier_ordre(), usp_hessienne_libre(),
#  usp_pas_newton_borne(), usp_kkt_satisfaite(), usp_noyau(),
#  usp_hessienne()). Tous les libelles non ASCII sont ecrits en
#  echappements \u (fichier source ASCII).
#
#  Protocole : docs/specifications/fc-validation-ajustement.md, par. 5.2
#  (adopte par le mainteneur, Q-D1-Fc-6) ; options du par. 5.3.
#    - Ni bootstrap ni run_engine() : usp_ajuster() (verite du moteur :
#      libelle, verdict, champs du demarrage retenu) et demarrages(), copie
#      de la boucle des demarrages d'usp_ajuster() (meme grille, meme
#      optim(), meme marge 1e-10, meme ensemble a l'optimum TOL_OPTIMUM),
#      comme kkt_reference() de tests/unitaires/test_controles_numeriques.R.
#      Controle de coherence par jeu : demarrage retenu de la copie
#      identique (identical()) a celui d'usp_ajuster(), meme
#      kkt_au_moins_un, meme erreur_sigma, meme libelle de courbure ; les
#      desaccords sont comptes et imprimes (colonne "Incoherences").
#    - Generateurs (44 cellules de 100 jeux, graine 20261018 + indice de
#      cellule, indice 1 a 44 dans l'ordre G1 s = 0, G1 s = 0,01, G2, G3,
#      puis epsilon croissant) :
#        G1 : x = 100 (1 + eps U(-1, 1)), y = y de J1 * exp(N(0, s)) ;
#        G2 : volumes de J1 comprimes a l'etendue relative eps autour de
#             leur moyenne, x' = xbar (1 + eps (x - xbar) / (max x - min x)),
#             ratios y/x de J1 conserves annee par annee ; jeu 1 dans l'ordre
#             de J1, jeux 2 a 100 : volumes comprimes permutes par sample()
#             (CHOIX DU SCRIPT : la specification ne dit pas comment tirer
#             100 jeux d'une transformation deterministe ; voir le tableau) ;
#        G3 : idem avec J2.
#      Tirages par engine_sous_graine() (generateur ENGINE_RNG_KIND).
#    - (P1) 40 premiers jeux de chaque cellule G1 s = 0,01, echelles
#      (x, y) * {1e-3 ; 1 ; 1e6} (reajustement a chaque echelle) :
#      H_dd(h), h dans {1e-2 ; 1e-3 ; 1e-4 ; 1e-5 ; 1e-6}, au demarrage
#      retenu ; bruit nu(h) = ecart-type de H_dd(h) sur les 20 points
#      delta_hat +- j 1e-12, j = 1..10, h dans {1e-4 ; 1e-6} ; classement
#      "reel" si meme signe pour tous les h et |H(h) - H(1e-2)| <=
#      0,1 |H(1e-2)|, "bruit" sinon, "non fini" si un H(h) n'est pas fini.
#      Complement du script : meme classement sur det(H).
#    - (P2) par jeu : libelle, verdict, delta_hat, bord, delta libre, H_dd,
#      H_gg, |H_dd|/H_gg, d ln sigma / d delta, eff_delta =
#      max_{b in {0, 1}} |ln sigma(b, gamma_hat) - ln sigma(delta_hat,
#      gamma_hat)|, demarrages a l'optimum, demarrages KKT, ecart relatif de
#      sigma entre le retenu et le premier demarrage KKT (ordre de la grille).
#      Frequence du libelle avec IC exact de Clopper-Pearson a 95 %
#      (stats::binom.test()).
#    - (P3) options, sur P2, sur les 1 238 jeux de
#      tests/unitaires/test_controles_numeriques.R (graine 20260924 x 1 051,
#      graine 12345 x 187, generateur recopie), sur les deux valeurs l du cas
#      xw et sur J1, J2 :
#        (E)  statu quo (regle actuelle) ;
#        (A)  delta non libre si |H_dd| <= tau H_gg (H_gg > 0), tau dans
#             TAU_A ; applique a chaque demarrage a l'optimum (decision
#             kkt_au_moins_un) et au demarrage retenu (libelle, stat) ;
#        (C)  libelle et stat lus sur le premier demarrage a l'optimum qui
#             satisfait KKT (ordre de la grille), a defaut sur le retenu ;
#             decision inchangee ;
#        (C') anomalies du retenu imprimees seulement si le controle sort
#             ECHEC ; decision et stat inchanges ;
#        (D)  delta non libre si eff_delta <= repere, repere REP_SIGMA_KKT ou
#             REP_SIGMA_KKT / 2, eff_delta calcule au point (delta_s,
#             gamma_s) de chaque demarrage. "Non libre" s'obtient en
#             appelant usp_pas_newton_borne() et usp_kkt_satisfaite() avec
#             volumes_constants = TRUE (meme branche que l'exception des
#             volumes constants ; la condition |pg_delta| <= REP_GD_KKT est
#             donc conservee, CHOIX DU SCRIPT).
#  Bornes : budget de calcul (--budget, 1 200 s par defaut) verifie avant
#    chaque jeu ; au-dela, les cellules restantes ne sont pas calculees, la
#    sortie est PARTIELLE (liste des cellules faites et non faites en fin de
#    tableau), sans relance. Ecriture incrementale : une ligne par cellule
#    de P2 des qu'elle est faite ; les tableaux agreges en fin d'execution.
#  Statut des valeurs : CONSTAT DE SIMULATION sous ces generateurs, pas un
#    resultat general. Le nombre de jeux fixe l'incertitude de Monte-Carlo
#    des frequences, pas l'erreur en T.
#
#  Usage (depuis la racine du depot ; LC_ALL=C.UTF-8 sous Linux, #113) :
#      Rscript tests/mesure_courbure_delta_158.R [--sortie FICHIER.md]
#          [--budget SECONDES] [--essai]
#  --sortie : defaut docs/tableaux/<AAAAMMJJ>-issue158-courbure-delta.md
#    (date d'execution) ; refus si le fichier existe deja.
#  --essai : 5 jeux par cellule, 20 jeux sur les 1 238, NON versionnable.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/mesure_courbure_delta_158.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113) ------------------------------
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
local({
  i <- 1L
  while (i <= length(ARGS)) {
    a <- ARGS[i]
    if (a %in% c("--sortie", "--budget")) {
      if (i == length(ARGS)) stop("option ", a, " sans valeur")
      i <- i + 2L
    } else if (a == "--essai") i <- i + 1L
    else stop("option inconnue : ", a)
  }
})
lire_option <- function(nom, defaut) {
  i <- match(nom, ARGS)
  if (is.na(i)) defaut else ARGS[i + 1L]
}
ESSAI <- "--essai" %in% ARGS
BUDGET <- as.numeric(lire_option("--budget", "1200"))
if (!is.finite(BUDGET) || BUDGET <= 0) stop("--budget : nombre de secondes > 0 attendu")

RACINE <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f)) normalizePath(file.path(dirname(f), "..")) else normalizePath(".")
})
SORTIE <- lire_option("--sortie", file.path(RACINE, "docs", "tableaux",
  sprintf("%s-issue158-courbure-delta.md", format(Sys.Date(), "%Y%m%d"))))
if (file.exists(SORTIE)) stop("fichier de sortie deja present (aucun ecrasement) : ", SORTIE)

source(file.path(RACINE, "R", "engine.R"))

# --- Plan --------------------------------------------------------------------
GRAINE_BASE <- 20261018
EPS <- c(1.5e-6, 2e-6, 3e-6, 5e-6, 1e-5, 1.3e-5, 2e-5, 3e-5, 1e-4, 1e-3, 1e-2)
GENS <- c("G1 s=0", "G1 s=0.01", "G2", "G3")
N_JEUX <- if (ESSAI) 5L else 100L
N_P1 <- if (ESSAI) 3L else 40L
ECHELLES_P1 <- c(1e-3, 1, 1e6)
H_P1 <- c(1e-2, 1e-3, 1e-4, 1e-5, 1e-6)
H_BRUIT <- c(1e-4, 1e-6)
J_BRUIT <- c(-(10:1), 1:10) * 1e-12
TAU_A <- c(1e-14, 1e-13, 1e-12, 1e-11, 1e-10, 1e-9, 1e-8)
REP_D <- c(REP_SIGMA_KKT, REP_SIGMA_KKT / 2)
N_TCN <- if (ESSAI) 20L else 1238L

J1 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
J2 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln_interieur.csv"))
J1 <- list(x = J1$xt, y = J1$yt); J2 <- list(x = J2$xt, y = J2$yt)

# --- Ecriture ----------------------------------------------------------------
ecrire <- function(...) cat(enc2utf8(c(...)), file = SORTIE, append = TRUE, sep = "\n")
num <- function(v, d = 3) ifelse(is.na(v), "\u2014", trimws(formatC(v, digits = d, format = "g")))
ligne <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete <- function(cols) c(ligne(paste(cols, collapse = " | ")),
                           ligne(paste(rep("---", length(cols)), collapse = " | ")))
temps <- function() as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
hors_budget <- function() temps() > BUDGET

# --- Copie de la boucle des demarrages d'usp_ajuster() -------------------------
demarrages <- function(x, y, n_starts_delta = 9, controle = list(factr = 1e2, maxit = 500)) {
  xbar <- mean(x)
  starts <- expand.grid(delta = seq(0, 1, length.out = n_starts_delta),
                        gamma = log(c(0.01, 0.03, 0.06, 0.10, 0.20, 0.40)))
  vals <- rep(NA_real_, nrow(starts)); pars <- matrix(NA_real_, nrow(starts), 2)
  best <- NULL; ib <- NA_integer_
  for (i in seq_len(nrow(starts))) {
    fit <- try(stats::optim(
      par = c(starts$delta[i], starts$gamma[i]),
      fn = usp_objectif, gr = usp_gradient_optim, x = x, y = y, xbar = xbar,
      method = "L-BFGS-B",
      lower = c(0, BORNES_GAMMA[1]), upper = c(1, BORNES_GAMMA[2]),
      control = controle), silent = TRUE)
    if (inherits(fit, "try-error")) next
    vals[i] <- fit$value; pars[i, ] <- fit$par
    if (is.null(best) || fit$value < best$value - 1e-10) { best <- fit; ib <- i }
  }
  a_opt <- abs(vals - best$value) < TOL_OPTIMUM
  list(pars = pars, idx = which(!is.na(vals) & a_opt), ib = ib)
}

# eff_delta au point (d, g) : max_{b in {0, 1}} |ln sigma(b, g) - ln sigma(d, g)|
eff_delta <- function(d, g, x, y, xbar) {
  ls <- function(b) log(usp_noyau(b, g, x, y, xbar)$sigma)
  l0 <- ls(d)
  max(abs(ls(0) - l0), abs(ls(1) - l0))
}

# Evaluation d'un demarrage : regle actuelle et variante "delta non libre"
evaluer <- function(d, g, x, y, xbar, vol_cst) {
  cpo <- usp_condition_premier_ordre(d, g, x, y, xbar)
  bord_g <- !is.na(usp_gamma_bord(g))
  grad_fini <- all(is.finite(c(cpo$gradient, cpo$gradient_projete)))
  lib <- usp_hessienne_libre(cpo$hessienne, cpo$gradient_projete, vol_cst)
  kkt <- usp_kkt_satisfaite(cpo, g, volumes_constants = vol_cst)
  # Variante "delta non libre" (options A et D)
  pn <- usp_pas_newton_borne(cpo$hessienne, cpo$gradient_projete, d, cpo$grad_ln_sigma, TRUE)
  cnl <- cpo; cnl$pas_newton <- pn$pas; cnl$erreur_sigma <- pn$erreur_sigma
  if (bord_g) { cnl$pas_newton[] <- NA_real_; cnl$erreur_sigma <- NA_real_ }
  kkt_nl <- usp_kkt_satisfaite(cnl, g, volumes_constants = TRUE)
  H <- cpo$hessienne
  list(d = d, g = g, grad_fini = grad_fini, bord_g = bord_g,
       libre = lib$libre_delta, def_pos = lib$def_pos, kkt = kkt, err = cpo$erreur_sigma,
       def_pos_nl = pn$def_pos, kkt_nl = kkt_nl, err_nl = cnl$erreur_sigma,
       hdd = H[1, 1], hgg = H[2, 2], eff = eff_delta(d, g, x, y, xbar),
       sigma = usp_noyau(d, g, x, y, xbar)$sigma)
}

# Libelle de courbure d'un point (regle d'usp_controles_numeriques())
lib_nsp <- function(bord_g, def_pos) !bord_g && isFALSE(def_pos)
lib_nf  <- function(bord_g, def_pos) !bord_g && is.na(def_pos)

# Noms des options
OPTIONS <- c("E", sprintf("A tau=%s", formatC(TAU_A, format = "g")), "C", "C'",
             sprintf("D rep=%s", formatC(REP_D, format = "g")))

# Option sur un jeu : liste (nsp, nf, libre, kkt, stat)
options_jeu <- function(S, r, verdict_ok, nsp0, nf0) {
  out <- list()
  forcer <- function(s, crit) s$libre && crit(s)
  appliquer <- function(crit) {
    kk <- vapply(S, function(s) if (forcer(s, crit)) s$kkt_nl else s$kkt, logical(1))
    f <- forcer(r, crit)
    dp <- if (f) r$def_pos_nl else r$def_pos
    list(nsp = lib_nsp(r$bord_g, dp), nf = lib_nf(r$bord_g, dp),
         libre = r$libre && !f, kkt = any(kk), stat = if (f) r$err_nl else r$err)
  }
  kkt0 <- any(vapply(S, function(s) s$kkt, logical(1)))
  out[["E"]] <- list(nsp = nsp0, nf = nf0, libre = r$libre, kkt = kkt0, stat = r$err)
  for (k in seq_along(TAU_A)) {
    tau <- TAU_A[k]
    out[[OPTIONS[1 + k]]] <- appliquer(function(s)
      is.finite(s$hdd) && is.finite(s$hgg) && s$hgg > 0 && abs(s$hdd) <= tau * s$hgg)
  }
  ik <- which(vapply(S, function(s) s$kkt, logical(1)))
  pc <- if (length(ik)) S[[ik[1]]] else r
  out[["C"]] <- list(nsp = lib_nsp(pc$bord_g, pc$def_pos), nf = lib_nf(pc$bord_g, pc$def_pos),
                     libre = pc$libre, kkt = kkt0, stat = pc$err)
  out[["C'"]] <- list(nsp = nsp0 && !verdict_ok, nf = nf0 && !verdict_ok,
                      libre = r$libre, kkt = kkt0, stat = r$err)
  for (k in seq_along(REP_D)) {
    rep <- REP_D[k]
    out[[OPTIONS[1 + length(TAU_A) + 2 + k]]] <- appliquer(function(s) is.finite(s$eff) && s$eff <= rep)
  }
  out
}

# Analyse complete d'un jeu
analyser <- function(x, y) {
  xbar <- mean(x)
  fit <- usp_ajuster(x, y)
  cn <- usp_controles_numeriques(fit)[[1]]
  vol_cst <- usp_volumes_constants(x)
  dm <- demarrages(x, y)
  S <- lapply(dm$idx, function(i) evaluer(dm$pars[i, 1], dm$pars[i, 2], x, y, xbar, vol_cst))
  r <- S[[match(dm$ib, dm$idx)]]
  nsp0 <- grepl("courbure non strictement positive", cn$detail, fixed = TRUE)
  nf0 <- grepl("courbure non finie", cn$detail, fixed = TRUE)
  ok <- identical(cn$verdict, "OK")
  kk <- vapply(S, function(s) s$kkt, logical(1))
  ik <- which(kk)
  coherent <- identical(dm$pars[dm$ib, 1], fit$delta) && identical(dm$pars[dm$ib, 2], fit$gamma) &&
    identical(any(kk), fit$kkt_au_moins_un) && identical(r$err, fit$erreur_sigma) &&
    identical(nsp0, lib_nsp(r$bord_g, r$def_pos)) && identical(nf0, lib_nf(r$bord_g, r$def_pos))
  list(base = data.frame(
    etendue = diff(range(x)) / mean(x), vol_cst = vol_cst,
    nsp = nsp0, nf = nf0, verdict_ok = ok, delta = fit$delta, gamma = fit$gamma,
    delta_bord = isTRUE(fit$delta_au_bord), libre = r$libre,
    hdd = r$hdd, hgg = r$hgg, ratio = abs(r$hdd) / r$hgg,
    dls_d = unname(fit$grad_ln_sigma[["delta"]]), eff = r$eff,
    n_opt = length(S), n_kkt = length(ik),
    ecart_sigma_kkt = if (length(ik)) abs(r$sigma / S[[ik[1]]]$sigma - 1) else NA_real_,
    stat = fit$erreur_sigma, coherent = coherent),
    opt = options_jeu(S, r, ok, nsp0, nf0), fit = fit, detail = cn$detail)
}

# P1 : courbure en delta au demarrage retenu selon h, et bruit
p1_jeu <- function(fit) {
  x <- fit$x; y <- fit$y; xbar <- fit$xbar; d <- fit$delta; g <- fit$gamma
  Hh <- lapply(H_P1, function(h) usp_hessienne(d, g, x, y, xbar, h))
  hdd <- vapply(Hh, function(H) H[1, 1], numeric(1))
  det <- vapply(Hh, function(H) H[1, 1] * H[2, 2] - H[1, 2]^2, numeric(1))
  classer <- function(v) {
    if (!all(is.finite(v))) "non fini"
    else if (length(unique(sign(v))) == 1L && all(abs(v - v[1]) <= 0.1 * abs(v[1]))) "reel"
    else "bruit"
  }
  nu <- vapply(H_BRUIT, function(h)
    stats::sd(vapply(J_BRUIT, function(j) usp_hessienne(d + j, g, x, y, xbar, h)[1, 1], numeric(1))),
    numeric(1))
  hb <- hdd[match(H_BRUIT, H_P1)]
  c(classe = classer(hdd), classe_det = classer(det), signe = if (is.finite(hdd[1])) sign(hdd[1]) else NA,
    rapport_1e4 = nu[1] / abs(hb[1]), rapport_1e6 = nu[2] / abs(hb[2]),
    hdd_1e2 = hdd[1])
}

# --- Generateurs ---------------------------------------------------------------
comprimer <- function(x, eps) mean(x) * (1 + eps * (x - mean(x)) / (max(x) - min(x)))
generer_cellule <- function(gen, eps, graine, n) engine_sous_graine(graine, {
  lapply(seq_len(n), function(k) {
    if (gen %in% c("G1 s=0", "G1 s=0.01")) {
      s <- if (gen == "G1 s=0") 0 else 0.01
      xs <- 100 * (1 + eps * stats::runif(8, -1, 1))
      list(x = xs, y = J1$y * exp(stats::rnorm(8, 0, s)))
    } else {
      J <- if (gen == "G2") J1 else J2
      xc <- comprimer(J$x, eps)
      p <- if (k == 1L) 1:8 else sample(8)
      xs <- xc[p]
      list(x = xs, y = (J$y / J$x) * xs)
    }
  })
})

# Jeux de tests/unitaires/test_controles_numeriques.R (generateur recopie)
jeux_tcn <- function() {
  x <- J1$x; y <- J1$y
  tirer <- function(graine, n) engine_sous_graine(graine, {
    out <- vector("list", n)
    for (k in 1:n) {
      xs <- if (k %% 2) x else x * exp(stats::rnorm(8, 0, 0.5))
      d <- stats::runif(1); s <- stats::runif(1, 0.05, 0.3)
      sd2 <- log(1 + s^2 * (d + (1 - d) * mean(xs) / xs))
      ys <- 0.7 * xs * exp(stats::rnorm(8, -sd2 / 2, sqrt(sd2)))
      out[[k]] <- list(x = xs, y = ys)
    }
    out
  })
  c(tirer(20260924, 1051), tirer(12345, 187))
}

# --- En-tete -------------------------------------------------------------------
md5 <- function(f) unname(tools::md5sum(file.path(RACINE, f)))
git <- function(...) tryCatch(system2("git", c("-C", RACINE, ...), stdout = TRUE, stderr = FALSE),
                              error = function(e) NA_character_, warning = function(w) NA_character_)
etat_moteur <- git("status", "--porcelain", "--", "R/engine.R")
ecrire(paste0("# Courbure en \u03b4 du contr\u00f4le KKT \u00e0 volumes quasi constants : plancher de bruit, ",
       "relation \u00e9tendue / courbure, effets des options de D2-Fc (issue #158)"), "")
ecrire("### T0 \u2014 Ex\u00e9cution", "")
ecrire(entete(c("Grandeur", "Valeur")))
ecrire(ligne("Date", format(t_debut, "%Y-%m-%d %H:%M:%S %Z")))
ecrire(ligne("Script", sprintf("`%s`, md5 `%s`", SCRIPT, md5(SCRIPT))))
ecrire(ligne("Commit", sprintf("`%s`", paste(git("rev-parse", "HEAD"), collapse = ""))))
ecrire(ligne("Moteur", sprintf("`R/engine.R`, md5 `%s` ; %s", md5("R/engine.R"),
  if (length(etat_moteur) && nzchar(etat_moteur[1])) "**modifi\u00e9 dans l'arbre de travail** (non commit\u00e9)"
  else "identique au commit")))
ecrire(ligne("Plateforme", paste(R.version$platform, utils::sessionInfo()$running, sep = ", ")))
ecrire(ligne("R", R.version.string))
ecrire(ligne("BLAS", sprintf("`%s`", extSoftVersion()[["BLAS"]])))
ecrire(ligne("LAPACK", sprintf("`%s`", La_library())))
ecrire(ligne("Locale", Sys.getlocale("LC_CTYPE")))
ecrire(ligne("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")))
ecrire(ligne("Graines", sprintf(paste0("P2 : %d + indice de cellule (1 \u00e0 %d) ; ",
  "1 238 jeux : 20260924 (1 051) et 12345 (187)"), GRAINE_BASE, length(GENS) * length(EPS))))
ecrire(ligne("Budget", sprintf("%.0f s", BUDGET)))
ecrire(ligne("Mode", if (ESSAI) "**essai (non versionnable)**" else "complet"))
ecrire(ligne("Dur\u00e9es", "@@DUREES@@"))
ecrire(ligne("Sortie", "@@STATUT@@"))
ecrire("")
ecrire(paste0("Statut : **constat de simulation** sous les g\u00e9n\u00e9rateurs ci-dessous, pas un r\u00e9sultat ",
  "g\u00e9n\u00e9ral. Le nombre de jeux fixe l'incertitude de Monte-Carlo des fr\u00e9quences, pas l'erreur en T. ",
  "Protocole : `docs/specifications/fc-validation-ajustement.md`, \u00a7 5.2 (Q-D1-Fc-6). ",
  "Libell\u00e9 compt\u00e9 : \u00ab courbure non strictement positive \u00bb dans le `detail` du contr\u00f4le ",
  "\u00ab Condition du premier ordre \u00bb d'`usp_controles_numeriques()` (\u00ab courbure non finie \u00bb compt\u00e9 \u00e0 part)."), "")
ecrire(paste0("G\u00e9n\u00e9rateurs : G1, x = 100 (1 + \u03b5 U(\u22121, 1)), y = y de J1 \u00b7 exp(N(0, s)) ",
  "(\u00e9tendue relative r\u00e9elle jusqu'\u00e0 2\u03b5) ; G2 (G3), volumes de J1 (J2) comprim\u00e9s \u00e0 l'\u00e9tendue ",
  "relative \u03b5 exactement, ratios y/x de J1 (J2) conserv\u00e9s ann\u00e9e par ann\u00e9e ; jeu 1 dans l'ordre ",
  "de J1 (J2), jeux 2 \u00e0 100 volumes comprim\u00e9s permut\u00e9s (choix du script, la sp\u00e9cification ",
  "ne fixant pas l'al\u00e9a de G2 et G3). eff_\u03b4 = max_{b \u2208 {0, 1}} |ln \u03c3(b, \u03b3\u0302) \u2212 ln \u03c3(\u03b4\u0302, \u03b3\u0302)|."), "")

# --- P2 (et P1 a l'echelle 1) ----------------------------------------------------
ecrire("### T1 \u2014 P2 : fr\u00e9quence du libell\u00e9 par g\u00e9n\u00e9rateur et \u03b5 (\u00e9crit cellule par cellule)", "")
ecrire(entete(c("G\u00e9n\u00e9rateur", "\u03b5", "Jeux", "\u00c9tendue r\u00e9elle (min ; max)",
  "Volumes constants", "Libell\u00e9s \u00ab non strictement positive \u00bb", "Fr\u00e9quence",
  "IC 95 % (Clopper-Pearson)", "\u00c9tendue r\u00e9elle max des libell\u00e9s",
  "Libell\u00e9s \u00ab non finie \u00bb", "ECHEC", "\u03b4 au bord", "\u03b4 libre", "Incoh\u00e9rences", "Dur\u00e9e (s)")))

P2 <- list(); P1 <- list(); faites <- character(0); non_faites <- character(0)
cellule <- 0L
for (gen in GENS) for (eps in EPS) {
  cellule <- cellule + 1L
  nom <- sprintf("%s eps=%s", gen, formatC(eps, format = "g"))
  if (hors_budget()) { non_faites <- c(non_faites, nom); next }
  t0 <- temps()
  jeux <- generer_cellule(gen, eps, GRAINE_BASE + cellule, N_JEUX)
  res <- list()
  for (k in seq_along(jeux)) {
    if (hors_budget()) break
    a <- analyser(jeux[[k]]$x, jeux[[k]]$y)
    res[[k]] <- a
    if (gen == "G1 s=0.01" && k <= N_P1)
      P1[[length(P1) + 1]] <- c(list(eps = eps, echelle = 1, jeu = k, nsp = a$base$nsp), as.list(p1_jeu(a$fit)))
  }
  n <- length(res)
  if (n < length(jeux)) non_faites <- c(non_faites, sprintf("%s (%d jeux sur %d)", nom, n, length(jeux)))
  if (n == 0L) next
  if (n == length(jeux)) faites <- c(faites, nom)
  b <- do.call(rbind, lapply(res, function(a) a$base))
  b$gen <- gen; b$eps <- eps; b$jeu <- seq_len(n)
  P2[[nom]] <- list(base = b, opt = lapply(res, function(a) a$opt))
  k <- sum(b$nsp)
  ic <- stats::binom.test(k, n)$conf.int
  ecrire(ligne(gen, num(eps, 2), n, sprintf("%s ; %s", num(min(b$etendue)), num(max(b$etendue))),
    sum(b$vol_cst), k, num(k / n), sprintf("[%s ; %s]", num(ic[1]), num(ic[2])),
    if (k) num(max(b$etendue[b$nsp])) else "\u2014",
    sum(b$nf), sum(!b$verdict_ok), sum(b$delta_bord), sum(b$libre), sum(!b$coherent),
    sprintf("%.1f", temps() - t0)))
}
ecrire("")

# --- P1 aux echelles 1e-3 et 1e6 --------------------------------------------------
for (ech in setdiff(ECHELLES_P1, 1)) {
  for (eps in EPS) {
    nom <- sprintf("P1 echelle=%s eps=%s", formatC(ech, format = "g"), formatC(eps, format = "g"))
    if (hors_budget()) { non_faites <- c(non_faites, nom); next }
    cel <- 1L + length(EPS) + match(eps, EPS) - 1L
    jeux <- generer_cellule("G1 s=0.01", eps, GRAINE_BASE + cel, N_JEUX)[seq_len(N_P1)]
    m <- 0L
    for (k in seq_along(jeux)) {
      if (hors_budget()) break
      fit <- usp_ajuster(ech * jeux[[k]]$x, ech * jeux[[k]]$y)
      nsp <- grepl("courbure non strictement positive", usp_controles_numeriques(fit)[[1]]$detail, fixed = TRUE)
      P1[[length(P1) + 1]] <- c(list(eps = eps, echelle = ech, jeu = k, nsp = nsp), as.list(p1_jeu(fit)))
      m <- m + 1L
    }
    if (m == length(jeux)) faites <- c(faites, nom)
    else non_faites <- c(non_faites, sprintf("%s (%d jeux sur %d)", nom, m, length(jeux)))
  }
}

# --- P3 : ensembles complementaires -------------------------------------------------
P3 <- list()
analyser_ensemble <- function(nom, jeux) {
  res <- list()
  for (k in seq_along(jeux)) {
    if (hors_budget()) break
    res[[k]] <- analyser(jeux[[k]]$x, jeux[[k]]$y)
  }
  if (length(res) == length(jeux)) faites <<- c(faites, nom)
  else non_faites <<- c(non_faites, sprintf("%s (%d jeux sur %d)", nom, length(res), length(jeux)))
  res
}
P3$tcn <- analyser_ensemble("1 238 jeux de test_controles_numeriques.R", jeux_tcn()[seq_len(N_TCN)])
xw <- J1$x^3 / 1e4
L_XW <- c(0.89559862669921131, 0.89559862669966606)
P3$xw <- analyser_ensemble("cas xw (2 valeurs de l)", lapply(L_XW, function(l)
  list(x = xw, y = xw * (J1$y / J1$x) * exp(l * (1:8 - 4.5) / 10))))
P3$ref <- analyser_ensemble("J1 et J2", list(J1, J2))
t_calcul <- temps()

# --- Tableaux agreges ---------------------------------------------------------------
B2 <- if (length(P2)) do.call(rbind, lapply(P2, function(p) p$base)) else NULL
O2 <- unlist(lapply(P2, function(p) p$opt), recursive = FALSE)

# T2 : P2, plus grande etendue
if (!is.null(B2)) {
  ecrire("### T2 \u2014 P2 : plus grande \u00e9tendue o\u00f9 un libell\u00e9 appara\u00eet", "")
  ecrire(entete(c("G\u00e9n\u00e9rateur", "Libell\u00e9s", "Plus grand \u03b5 nominal libell\u00e9",
                  "Plus grande \u00e9tendue r\u00e9elle libell\u00e9e", "Libell\u00e9s \u00e0 \u03b5 > 3e-5",
                  "Libell\u00e9s \u00e0 \u03b5 \u2265 1e-4", "Verdicts des libell\u00e9s (OK / ECHEC)")))
  for (gen in c(GENS, "Tous")) {
    s <- if (gen == "Tous") B2 else B2[B2$gen == gen, ]
    l <- s[s$nsp, ]
    ecrire(ligne(gen, nrow(l), if (nrow(l)) num(max(l$eps), 2) else "\u2014",
                 if (nrow(l)) num(max(l$etendue)) else "\u2014",
                 sum(l$eps > 3e-5), sum(l$eps >= 1e-4),
                 sprintf("%d / %d", sum(l$verdict_ok), sum(!l$verdict_ok))))
  }
  ecrire("")

  # T3 : quantiles separes libelles / non libelles
  ecrire("### T3 \u2014 P2 : grandeurs au d\u00e9marrage retenu, jeux libell\u00e9s et non libell\u00e9s (m\u00e9diane ; min ; max)", "")
  ecrire(entete(c("G\u00e9n\u00e9rateur", "\u03b5", "Groupe", "Jeux", "\u03b4\u0302 int\u00e9rieur",
    "\\|H_\u03b4\u03b4\\| / H_\u03b3\u03b3", "\\|\u2202 ln \u03c3 / \u2202\u03b4\\|", "eff_\u03b4",
    "\u00c9cart relatif de \u03c3 au 1er d\u00e9marrage KKT", "D\u00e9marrages \u00e0 l'optimum (m\u00e9d.)",
    "D\u00e9marrages KKT (m\u00e9d.)")))
  q3 <- function(v) { v <- v[is.finite(v)]
    if (!length(v)) "\u2014" else sprintf("%s ; %s ; %s", num(stats::median(v)), num(min(v)), num(max(v))) }
  for (gen in GENS) for (eps in EPS) for (grp in c(TRUE, FALSE)) {
    s <- B2[B2$gen == gen & B2$eps == eps & B2$nsp == grp, ]
    if (!nrow(s)) next
    ecrire(ligne(gen, num(eps, 2), if (grp) "libell\u00e9s" else "non libell\u00e9s", nrow(s),
      sum(!s$delta_bord), q3(s$ratio), q3(abs(s$dls_d)), q3(s$eff), q3(s$ecart_sigma_kkt),
      stats::median(s$n_opt), stats::median(s$n_kkt)))
  }
  ecrire("")
}

# T4 : P1
if (length(P1)) {
  D1 <- do.call(rbind, lapply(P1, function(p) data.frame(
    eps = p$eps, echelle = p$echelle, jeu = p$jeu, nsp = p$nsp, classe = p$classe, classe_det = p$classe_det,
    signe = as.numeric(p$signe), r4 = as.numeric(p$rapport_1e4), r6 = as.numeric(p$rapport_1e6))))
  ecrire("### T4 \u2014 P1 : plancher de bruit de H_\u03b4\u03b4 (G1 s = 0,01, 40 premiers jeux par \u03b5)", "")
  ecrire(paste0("\u00ab R\u00e9el \u00bb : m\u00eame signe de H_\u03b4\u03b4(h) pour h \u2208 {1e-2 ; 1e-3 ; 1e-4 ; 1e-5 ; 1e-6} ",
    "et |H(h) \u2212 H(1e-2)| \u2264 0,1 |H(1e-2)| ; \u00ab bruit \u00bb sinon. \u03bd\u0302(h) : \u00e9cart-type de ",
    "H_\u03b4\u03b4(h) sur 20 points \u03b4\u0302 \u00b1 j\u00b71e-12, rapport\u00e9 \u00e0 |H_\u03b4\u03b4(h)|. ",
    "Colonne det : m\u00eame classement sur det(H) (compl\u00e9ment du script)."), "")
  ecrire(entete(c("\u00c9chelle", "\u03b5", "Jeux", "Libell\u00e9s", "H_\u03b4\u03b4 r\u00e9el / bruit / non fini",
    "dont libell\u00e9s r\u00e9el / bruit", "det r\u00e9el / bruit / non fini", "H_\u03b4\u03b4 < 0",
    "\u03bd\u0302(1e-4)/\\|H\\| m\u00e9diane ; max", "\u03bd\u0302(1e-6)/\\|H\\| m\u00e9diane ; max")))
  mm <- function(v) { v <- v[is.finite(v)]
    if (!length(v)) "\u2014" else sprintf("%s ; %s", num(stats::median(v)), num(max(v))) }
  for (ech in ECHELLES_P1) for (eps in EPS) {
    s <- D1[D1$echelle == ech & D1$eps == eps, ]
    if (!nrow(s)) next
    cpt <- function(cl, v = s$classe) sum(v == cl)
    ecrire(ligne(num(ech), num(eps, 2), nrow(s), sum(s$nsp),
      sprintf("%d / %d / %d", cpt("reel"), cpt("bruit"), cpt("non fini")),
      sprintf("%d / %d", sum(s$nsp & s$classe == "reel"), sum(s$nsp & s$classe == "bruit")),
      sprintf("%d / %d / %d", cpt("reel", s$classe_det), cpt("bruit", s$classe_det), cpt("non fini", s$classe_det)),
      sum(s$signe < 0, na.rm = TRUE), mm(s$r4), mm(s$r6)))
  }
  ecrire("")
  ecrire(sprintf(paste0("Total P1 : %d jeux ; H_\u03b4\u03b4 class\u00e9 \u00ab bruit \u00bb : %d ; \u00ab non fini \u00bb : %d ; ",
    "libell\u00e9s : %d, dont class\u00e9s \u00ab bruit \u00bb : %d. Libell\u00e9 identique aux trois \u00e9chelles : %s."),
    nrow(D1), sum(D1$classe == "bruit"), sum(D1$classe == "non fini"), sum(D1$nsp),
    sum(D1$nsp & D1$classe == "bruit"),
    local({ k <- paste(D1$eps, D1$jeu)
      tt <- tapply(D1$nsp, k, function(v) length(v) < 3L || length(unique(v)) == 1L)
      sprintf("%d jeux sur %d", sum(tt), length(tt)) })), "")
}

# T5 : P3
ecrire("### T5 \u2014 P3 : effets contrefactuels des options", "")
ecrire(paste0("(E) statu quo ; (A) \u03b4 non libre si |H_\u03b4\u03b4| \u2264 \u03c4 H_\u03b3\u03b3 ; (C) libell\u00e9 et `stat` lus ",
  "sur le premier d\u00e9marrage \u00e0 l'optimum qui satisfait KKT (ordre de la grille) ; (C\u2032) anomalies imprim\u00e9es ",
  "seulement si ECHEC ; (D) \u03b4 non libre si eff_\u03b4 \u2264 rep\u00e8re (REP_SIGMA_KKT = 1e-6 ou REP_SIGMA_KKT/2), ",
  "jug\u00e9 \u00e0 chaque d\u00e9marrage. Bascules : \u03b4 libre au point lu par la r\u00e8gle actuelle, non libre au point ",
  "lu par l'option. D\u00e9saccords : d\u00e9cision `kkt_au_moins_un` de l'option contre la r\u00e8gle actuelle."), "")
agr <- function(B, O, sel) {
  if (is.null(B) || !any(sel)) return(NULL)
  vapply(OPTIONS, function(o) {
    oo <- lapply(O[sel], function(z) z[[o]])
    e <- lapply(O[sel], function(z) z[["E"]])
    nsp <- sum(vapply(oo, function(z) z$nsp, logical(1)))
    nf <- sum(vapply(oo, function(z) z$nf, logical(1)))
    bas <- sum(vapply(seq_along(oo), function(i) e[[i]]$libre && !oo[[i]]$libre, logical(1)))
    k0 <- vapply(e, function(z) z$kkt, logical(1)); k1 <- vapply(oo, function(z) z$kkt, logical(1))
    c(nsp = nsp, nf = nf, bascules = bas, ok_echec = sum(k0 & !k1), echec_ok = sum(!k0 & k1))
  }, numeric(5))
}
tcn_B <- if (length(P3$tcn)) do.call(rbind, lapply(P3$tcn, function(a) a$base)) else NULL
tcn_O <- lapply(P3$tcn, function(a) a$opt)
a_plage <- if (!is.null(B2)) agr(B2, O2, B2$eps >= 2e-6 & B2$eps <= 1e-2) else NULL
a_1e2 <- if (!is.null(B2)) agr(B2, O2, B2$eps >= 1e-2) else NULL
a_tcn <- if (length(tcn_O)) agr(tcn_B, tcn_O, rep(TRUE, length(tcn_O))) else NULL
a_tout <- if (!is.null(B2)) agr(B2, O2, rep(TRUE, nrow(B2))) else NULL
cel <- function(a, o, ch) if (is.null(a)) "\u2014" else format(a[ch, o])
ecrire(sprintf(paste0("Effectifs : P2, \u03b5 \u2208 [2e-6 ; 1e-2] : %d jeux ; P2, \u03b5 = 1e-2 : %d jeux ; ",
  "1 238 jeux : %d jeux calcul\u00e9s ; P2 entier : %d jeux."),
  if (is.null(B2)) 0L else sum(B2$eps >= 2e-6), if (is.null(B2)) 0L else sum(B2$eps >= 1e-2),
  length(tcn_O), if (is.null(B2)) 0L else nrow(B2)), "")
ecrire(entete(c("Option", "Libell\u00e9s \u00ab non strictement positive \u00bb restants, \u03b5 \u2208 [2e-6 ; 1e-2]",
  "Libell\u00e9s \u00ab non finie \u00bb, \u03b5 \u2208 [2e-6 ; 1e-2]",
  "Bascules \u03b4 libre \u2192 non libre, \u03b5 = 1e-2", "Bascules, 1 238 jeux",
  "D\u00e9saccords KKT OK\u2192ECHEC / ECHEC\u2192OK, P2 entier", "D\u00e9saccords KKT, 1 238 jeux",
  "Libell\u00e9s restants, 1 238 jeux")))
for (o in OPTIONS)
  ecrire(ligne(o, cel(a_plage, o, "nsp"), cel(a_plage, o, "nf"), cel(a_1e2, o, "bascules"),
    cel(a_tcn, o, "bascules"),
    if (is.null(a_tout)) "\u2014" else sprintf("%d / %d", a_tout["ok_echec", o], a_tout["echec_ok", o]),
    if (is.null(a_tcn)) "\u2014" else sprintf("%d / %d", a_tcn["ok_echec", o], a_tcn["echec_ok", o]),
    if (is.null(a_tcn)) "\u2014" else format(a_tcn["nsp", o] + a_tcn["nf", o])))
ecrire("")

# T6 : cas xw et J1, J2
ecrire("### T6 \u2014 P3 : continuit\u00e9 au cas `xw` et `stat` sur J1, J2", "")
ecrire(entete(c("Option", sprintf("xw, l = %.17g : verdict, \u03b4 libre", L_XW),
  "J1 : verdict, \u03b4 libre, stat (variation)", "J2 : verdict, \u03b4 libre, stat (variation)")))
desc <- function(a, o, avec_stat = FALSE) {
  if (is.null(a)) return("\u2014")
  z <- a$opt[[o]]; z0 <- a$opt[["E"]]
  s <- sprintf("%s, %s", if (z$kkt) "OK" else "ECHEC", if (z$libre) "oui" else "non")
  if (avec_stat) s <- sprintf("%s, %s (%s)", s, num(z$stat, 6),
    if (identical(z$stat, z0$stat)) "identique" else num(z$stat - z0$stat))
  s
}
g <- function(l, i) if (length(l) >= i) l[[i]] else NULL
for (o in OPTIONS)
  ecrire(ligne(o, desc(g(P3$xw, 1), o), desc(g(P3$xw, 2), o),
               desc(g(P3$ref, 1), o, TRUE), desc(g(P3$ref, 2), o, TRUE)))
ecrire("")
if (length(P3$ref)) ecrire(sprintf(paste0("eff_\u03b4 au d\u00e9marrage retenu : J1 %s, J2 %s ; ",
  "|H_\u03b4\u03b4|/H_\u03b3\u03b3 : J1 %s, J2 %s."),
  num(P3$ref[[1]]$base$eff), num(g(P3$ref, 2)$base$eff),
  num(P3$ref[[1]]$base$ratio), num(g(P3$ref, 2)$base$ratio)), "")

# T7 : separation pour (A) et (D) (min / max des grandeurs selon le libelle)
if (!is.null(B2)) {
  ecrire("### T7 \u2014 S\u00e9paration des jeux libell\u00e9s (P2 entier et 1 238 jeux, \u03b4 libre au retenu)", "")
  ecrire(entete(c("Ensemble", "Groupe", "Jeux", "\\|H_\u03b4\u03b4\\|/H_\u03b3\u03b3 min ; max", "eff_\u03b4 min ; max")))
  mx <- function(v) { v <- v[is.finite(v)]; if (!length(v)) "\u2014" else sprintf("%s ; %s", num(min(v)), num(max(v))) }
  for (ens in c("P2", "1 238 jeux")) {
    B <- if (ens == "P2") B2 else tcn_B
    if (is.null(B)) next
    for (grp in c(TRUE, FALSE)) {
      s <- B[B$libre & B$nsp == grp, ]
      ecrire(ligne(ens, if (grp) "libell\u00e9s" else "non libell\u00e9s", nrow(s), mx(s$ratio), mx(s$eff)))
    }
  }
  ecrire("")
}

# Coherence de la copie de la boucle
n_inc <- (if (is.null(B2)) 0L else sum(!B2$coherent)) + (if (is.null(tcn_B)) 0L else sum(!tcn_B$coherent)) +
  sum(vapply(c(P3$xw, P3$ref), function(a) !a$base$coherent, logical(1)))
ecrire(sprintf(paste0("Coh\u00e9rence de la copie de la boucle des d\u00e9marrages avec `usp_ajuster()` ",
  "(retenu, `kkt_au_moins_un`, `erreur_sigma`, libell\u00e9 de courbure ; `identical()`) : %d incoh\u00e9rence(s)."), n_inc), "")

# Cellules
ecrire("### T8 \u2014 Cellules", "")
ecrire(sprintf("Faites (%d) : %s.", length(faites), paste(faites, collapse = " ; ")), "")
ecrire(sprintf("Non faites ou partielles (%d) : %s.", length(non_faites),
               if (length(non_faites)) paste(non_faites, collapse = " ; ") else "aucune"), "")

# Durees et statut dans l'en-tete
t_fin <- temps()
txt <- readLines(SORTIE, encoding = "UTF-8")
txt <- sub("@@DUREES@@", sprintf("calcul %.1f s ; total %.1f s", t_calcul, t_fin), txt, fixed = TRUE)
txt <- sub("@@STATUT@@", if (length(non_faites)) sprintf("**PARTIELLE** (budget de %.0f s atteint ; %d cellule(s) non faite(s) ou partielle(s), voir T8)",
  BUDGET, length(non_faites)) else "compl\u00e8te", txt, fixed = TRUE)
writeLines(enc2utf8(txt), SORTIE, useBytes = TRUE)
cat(sprintf("Termine en %.1f s ; sortie %s ; %d cellule(s) non faite(s).\n", t_fin, SORTIE, length(non_faites)))
