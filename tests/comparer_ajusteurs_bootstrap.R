###############################################################################
#  tests/comparer_ajusteurs_bootstrap.R  --  REAJUSTEMENT BOOTSTRAP : AJUSTEUR
#  RAPIDE CONTRE AJUSTEUR COMPLET (issue #43, protocole d'actuary du
#  26/09/2026, commentaire de l'issue)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  Il ne modifie aucun fichier du depot ; l'option --csv ecrit hors du depot.
#  R base + stats (plus tools pour le md5, comme regenerer_et_rendre_compte.R).
#
#  Objet : sur les MEMES replications que usp_bootstrap() (meme graine, meme
#  usp_simuler(fit)), comparer trois reajustements de chaque replication :
#    R  : usp_ajuster_rapide(x, yb, delta_obs, gamma_obs), celui du moteur ;
#    C  : usp_ajuster(x, yb), l'ajusteur de l'ajustement observe (54
#         demarrages), valeurs par defaut ;
#    R3 : candidat de correction, defini ICI et non dans le moteur : trois
#         appels de usp_ajuster_rapide() depuis (delta_obs, gamma_obs),
#         (0, gamma_obs), (1, gamma_obs), dans cet ordre, objectif minimal
#         retenu avec la regle du premier a moins de 1e-10 (celle de
#         usp_ajuster()).
#  Depuis #109, usp_ajuster_rapide() porte elle-meme ces trois demarrages :
#  R est le correctif R3 du moteur, et R3 ci-dessus le rejoue depuis chacun
#  des trois points (neuf demarrages), comme controle croise.
#  Le reajustement ne consomme aucun alea (L-BFGS-B deterministe) : la suite
#  des yb est celle du moteur, verifiee par le controle d'integrite S5
#  (identical() avec usp_bootstrap() et run_engine()).
#
#  Jeux (T = 8) : J1, tests/donnees/donnees_ln.csv (jeu des quatre cas de
#  reference lognormaux) ; J2, jeu a delta estime interieur lu dans
#  tests/unitaires/test_controles_numeriques.R (lignes "xi <-" et "yi <-").
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/comparer_ajusteurs_bootstrap.R [--B 999]
#          [--graine 20260831] [--jeu J1|J2|tous] [--csv <fichier hors depot>]
#          [--sans-seconde-passe]
#  Par defaut : protocole complet (B = 999, graine 20260831, deux jeux,
#  seconde passe automatique a 4 999 replications, graine 20260926, sur le
#  jeu dont l'intervalle de Clopper-Pearson de q_opt contient 1 %).
#  --sans-seconde-passe : essais seulement (hors protocole).
#  Sortie : tableaux T0 a T8 en markdown sur la console (UTF-8).
#  Code de sortie : 0 si le controle d'integrite S5 tient, 1 sinon (quel que
#  soit le bilan S1-S4 : outil de mesure, pas batterie). La conclusion
#  (divergence ou non, paragraphe 7 du protocole) revient a actuary.
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
OPT_B       <- as.integer(lire_option("--B", "999"))
OPT_GRAINE  <- as.numeric(lire_option("--graine", "20260831"))
OPT_JEU     <- lire_option("--jeu", "tous")
OPT_CSV     <- lire_option("--csv", NA_character_)
OPT_SECONDE <- !("--sans-seconde-passe" %in% ARGS)
if (!OPT_JEU %in% c("J1", "J2", "tous")) stop("--jeu : J1, J2 ou tous")
if (!is.finite(OPT_B) || OPT_B < 21L) stop("--B : entier >= 21")

# Seconde passe (paragraphe 3 du protocole)
B_SECONDE      <- 4999L
GRAINE_SECONDE <- 20260926
# Seuils du protocole (paragraphe 6), reperes numeriques fixes pour ce
# protocole : S1 (q_opt), S2 (|Delta p_mc|), S3 (quantiles de sigma_USP),
# S4 (composante de tolerance).
SEUIL_S1 <- 0.01
SEUIL_S2 <- 0.01
SEUIL_S3 <- 1e-3
SEUIL_S4 <- 1e-3

# --- Chargement du moteur et des outils --------------------------------------
DOSSIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) dirname(f) else if (file.exists("tests/outils_tests.R")) "tests" else "."
})
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))

# Console en UTF-8 quelle que soit la locale (meme definition que
# tests/regenerer_et_rendre_compte.R, issue #82).
ecrire_console <- function(x) writeLines(enc2utf8(x), useBytes = TRUE)

# --csv : refuse dans le depot
if (!is.na(OPT_CSV)) {
  rep_csv <- normalizePath(dirname(OPT_CSV), winslash = "/", mustWork = TRUE)
  rac <- normalizePath(RACINE, winslash = "/", mustWork = TRUE)
  if (startsWith(tolower(paste0(rep_csv, "/")), tolower(paste0(rac, "/"))))
    stop("--csv : le fichier doit etre ecrit hors du depot (", rep_csv, ")")
}

# --- Jeux ---------------------------------------------------------------------
# J2 : lu dans le test unitaire qui le definit (source unique).
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
JEUX <- list(J1 = list(x = .ln$xt, y = .ln$yt,
                       libelle = "J1 : tests/donnees/donnees_ln.csv (jeu des cas de reference)"),
             J2 = c(lire_j2(),
                    libelle = "J2 : xi, yi de tests/unitaires/test_controles_numeriques.R (delta estime interieur)"))
JEUX_RETENUS <- if (OPT_JEU == "tous") names(JEUX) else OPT_JEU
CAS_LN <- c("premium", "reserve1", "premium_ii6", "premium_net")
AJ <- c("R", "C", "R3")

# --- Ajusteurs -----------------------------------------------------------------
# Chacun rend list(delta, gamma, sigma, obj, z) (plus n_starts_optimum et
# kkt_au_moins_un pour C) ou leve une erreur (replication ecartee et comptee).
ajuster_R <- function(fit, yb) {
  f <- usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma)
  list(delta = f$delta, gamma = f$gamma, sigma = f$sigma, obj = f$obj, z = f$z)
}
ajuster_C <- function(fit, yb) {
  f <- usp_ajuster(fit$x, yb)
  list(delta = f$delta, gamma = f$gamma, sigma = f$sigma, obj = f$obj_min, z = f$z,
       n_starts_optimum = f$n_starts_optimum, kkt = f$kkt_au_moins_un)
}
# R3 : fonction locale du script (candidat de correction), pas du moteur.
ajuster_R3 <- function(fit, yb) {
  departs <- list(c(fit$delta, fit$gamma), c(0, fit$gamma), c(1, fit$gamma))
  best <- NULL
  for (p in departs) {
    f <- try(usp_ajuster_rapide(fit$x, yb, p[1], p[2]), silent = TRUE)
    if (inherits(f, "try-error") || !is.finite(f$obj)) next
    if (is.null(best) || f$obj < best$obj - 1e-10) best <- f
  }
  if (is.null(best)) stop("R3 : aucun demarrage abouti")
  list(delta = best$delta, gamma = best$gamma, sigma = best$sigma, obj = best$obj, z = best$z)
}
AJUSTEURS <- list(R = ajuster_R, C = ajuster_C, R3 = ajuster_R3)

# --- Rejeu des replications ------------------------------------------------------
# Meme structure que usp_bootstrap() : yb <- usp_simuler(fit) sous
# engine_sous_graine(graine, ...), statistiques du catalogue par
# .stats_bootstrapables() dans un try() ; une replication dont le
# reajustement ou les statistiques echouent est ecartee (comptee).
rejouer <- function(fit, B, graine) {
  noms <- names(.stats_bootstrapables(fit$x, fit$y, fit$z, fit$pi))
  vide <- function() rep(NA_real_, B)
  out <- lapply(stats::setNames(AJ, AJ), function(a)
    list(delta = vide(), gamma = vide(), sigma = vide(), obj = vide(),
         ok_ajust = rep(FALSE, B), ok_stats = rep(FALSE, B),
         sim = matrix(NA_real_, B, length(noms), dimnames = list(NULL, noms))))
  n_opt_C <- rep(NA_real_, B); kkt_C <- rep(NA, B)
  engine_sous_graine(graine, {
    for (b in seq_len(B)) {
      yb <- usp_simuler(fit)
      for (a in AJ) {
        f <- try(AJUSTEURS[[a]](fit, yb), silent = TRUE)
        if (inherits(f, "try-error")) next
        out[[a]]$delta[b] <- f$delta; out[[a]]$gamma[b] <- f$gamma
        out[[a]]$sigma[b] <- f$sigma; out[[a]]$obj[b] <- f$obj
        out[[a]]$ok_ajust[b] <- TRUE
        if (a == "C") { n_opt_C[b] <- f$n_starts_optimum; kkt_C[b] <- f$kkt }
        sb <- try(.stats_bootstrapables(fit$x, yb, f$z, f$pi), silent = TRUE)
        if (inherits(sb, "try-error")) next
        out[[a]]$sim[b, ] <- sb[noms]
        out[[a]]$ok_stats[b] <- TRUE
      }
    }
  })
  out$C$n_starts_optimum <- n_opt_C
  out$C$kkt <- kkt_C
  out$B <- B; out$graine <- graine
  out
}

# Vecteurs "a la usp_bootstrap()" d'un ajusteur : sigma, delta, gamma des
# replications dont reajustement et statistiques ont abouti.
vecteurs_boot <- function(o) {
  garde <- o$ok_stats
  list(sigma_boot = o$sigma[garde & is.finite(o$sigma)],
       delta_boot = o$delta[garde & is.finite(o$delta)],
       gamma_boot = o$gamma[garde & is.finite(o$gamma)])
}

# --- Mise en forme -------------------------------------------------------------
fmt <- function(x, d = 4) ifelse(is.na(x), "NA", trimws(formatC(x, digits = d, format = "g")))
pct <- function(k, n) if (n > 0) sprintf("%.1f %%", 100 * k / n) else "NA"
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
regime <- function(d) ifelse(is.na(d), NA_character_,
                        ifelse(d <= TOL_DELTA_BORD, "0",
                               ifelse(d >= 1 - TOL_DELTA_BORD, "1", "int")))
gamma_borne <- function(g) is.finite(g) & (g <= BORNES_GAMMA[1] + 1e-6 | g >= BORNES_GAMMA[2] - 1e-6)
QP <- c(.025, .05, .25, .5, .75, .95, .975)

# --- Analyse d'une passe (agregats 1 a 4 du protocole) ------------------------------
analyser <- function(o, nom_jeu, passe) {
  L <- character(0)
  n <- o$B
  # T1
  L <- c(L, sprintf("### T1 -- %s, %s : r\u00e9gimes, bornes, \u00e9checs, quantiles", nom_jeu, passe), "",
         entete_md(c("Ajusteur", "\u03b4*=0", "int", "\u03b4*=1", "\u03b3* sur borne",
                     "\u00e9checs r\u00e9ajust.", "\u00e9checs stat.")))
  for (a in AJ) {
    r <- regime(o[[a]]$delta[o[[a]]$ok_ajust])
    na <- length(r)
    L <- c(L, ligne_md(a, pct(sum(r == "0"), na), pct(sum(r == "int"), na), pct(sum(r == "1"), na),
                       sum(gamma_borne(o[[a]]$gamma)), sum(!o[[a]]$ok_ajust),
                       sum(o[[a]]$ok_ajust & !o[[a]]$ok_stats)))
  }
  L <- c(L, "", entete_md(c("Ajusteur", "Grandeur", paste0("q", 100 * QP, " %"))))
  for (g in c("delta", "gamma", "sigma")) for (a in AJ) {
    v <- o[[a]][[g]][o[[a]]$ok_ajust]
    L <- c(L, ligne_md(a, switch(g, delta = "\u03b4*", gamma = "\u03b3*", sigma = "\u03c3*"),
                       paste(fmt(stats::quantile(v, QP, names = FALSE), 7), collapse = " | ")))
  }
  if (any(o$C$ok_ajust))
    L <- c(L, "", sprintf("C : n_starts_optimum min / m\u00e9diane / max = %s / %s / %s ; kkt_au_moins_un FALSE : %d r\u00e9plication(s).",
                          min(o$C$n_starts_optimum, na.rm = TRUE), stats::median(o$C$n_starts_optimum, na.rm = TRUE),
                          max(o$C$n_starts_optimum, na.rm = TRUE), sum(o$C$kkt %in% FALSE)))
  # T2
  L <- c(L, "", sprintf("### T2 -- %s, %s : r\u00e9gimes crois\u00e9s (lignes : ajusteur compar\u00e9 ; colonnes : C)", nom_jeu, passe))
  for (a in c("R", "R3")) {
    ok <- o[[a]]$ok_ajust & o$C$ok_ajust
    tt <- table(factor(regime(o[[a]]$delta[ok]), c("0", "int", "1")),
                factor(regime(o$C$delta[ok]), c("0", "int", "1")))
    L <- c(L, "", entete_md(c(sprintf("%s / C", a), "C : 0", "C : int", "C : 1")))
    for (i in rownames(tt)) L <- c(L, ligne_md(sprintf("%s : %s", a, i), paste(tt[i, ], collapse = " | ")))
  }
  # T3 et T4
  res_q <- list()
  L <- c(L, "", sprintf("### T3 -- %s, %s : optimum non atteint (\u0394O = O*_X \u2212 O*_C > %g)", nom_jeu, passe, TOL_OPTIMUM), "",
         entete_md(c("Ajusteur", "n appari\u00e9es", "k (\u0394O > 1e-6)", "q_opt", "IC 95 % Clopper-Pearson",
                     "IC contient 1 %", "k (\u0394O < \u22121e-6)")))
  detail <- character(0)
  T4 <- character(0)
  for (a in c("R", "R3")) {
    ok <- o[[a]]$ok_ajust & o$C$ok_ajust
    dO <- o[[a]]$obj - o$C$obj
    div <- which(ok & dO > TOL_OPTIMUM)
    neg <- which(ok & dO < -TOL_OPTIMUM)
    np <- sum(ok); k <- length(div)
    ic <- if (np > 0) stats::binom.test(k, np)$conf.int else c(NA, NA)
    contient <- isTRUE(ic[1] <= SEUIL_S1 && ic[2] >= SEUIL_S1)
    res_q[[a]] <- list(k = k, n = np, q = k / np, ic = ic, contient = contient, neg = length(neg),
                       div = div)
    L <- c(L, ligne_md(a, np, k, sprintf("%.4f", k / np), sprintf("[%.4f ; %.4f]", ic[1], ic[2]),
                       if (contient) "oui" else "non", length(neg)))
    for (b in c(div, neg))
      detail <- c(detail, ligne_md(a, b, fmt(o[[a]]$delta[b], 6), fmt(o$C$delta[b], 6), fmt(dO[b], 4),
                                   fmt(abs(o[[a]]$sigma[b] - o$C$sigma[b]) / o$C$sigma[b], 4),
                                   if (dO[b] > 0) "optimum non atteint" else "C pire que X"))
    # Composante de tolerance : |Delta O| <= 1e-6
    tol <- ok & abs(dO) <= TOL_OPTIMUM
    ds <- abs(o[[a]]$sigma - o$C$sigma)[tol] / o$C$sigma[tol]
    dg <- abs(o[[a]]$gamma - o$C$gamma)[tol]
    dd <- abs(o[[a]]$delta - o$C$delta)[tol]
    qq <- function(v) paste(fmt(stats::quantile(v, c(.5, .9, 1), names = FALSE), 3), collapse = " | ")
    T4 <- c(T4, ligne_md(a, sum(tol), "abs(\u0394\u03c3*)/\u03c3*_C", qq(ds)),
            ligne_md(a, sum(tol), "abs(\u0394\u03b3*)", qq(dg)),
            ligne_md(a, sum(tol), "abs(\u0394\u03b4*)", qq(dd)))
    res_q[[a]]$max_ds_tol <- if (length(ds)) max(ds) else NA_real_
    res_q[[a]]$n_ds_1e6 <- sum(ds > 1e-6)
  }
  L <- c(L, "", "R\u00e9plications concern\u00e9es :", "",
         entete_md(c("Ajusteur X", "b", "\u03b4*_X", "\u03b4*_C", "\u0394O", "abs(\u0394\u03c3*)/\u03c3*_C", "Nature")),
         if (length(detail)) detail else ligne_md("aucune", "", "", "", "", "", ""))
  L <- c(L, "", sprintf("### T4 -- %s, %s : composante de tol\u00e9rance (|\u0394O| \u2264 1e-6)", nom_jeu, passe), "",
         entete_md(c("Ajusteur", "n", "Grandeur", "q50 %", "q90 %", "max")), T4)
  L <- c(L, "", sprintf("Nombre de r\u00e9plications \u00e0 abs(\u0394\u03c3*)/\u03c3*_C > 1e-6 (composante de tol\u00e9rance) : R %d, R3 %d.",
                        res_q$R$n_ds_1e6, res_q$R3$n_ds_1e6), "")
  ecrire_console(L)
  res_q
}

# --- p_mc (agregat 6) --------------------------------------------------------------
p_mc_ajusteurs <- function(fit, o) {
  stats_obs <- .stats_bootstrapables(fit$x, fit$y, fit$z, fit$pi)
  lapply(stats::setNames(AJ, AJ), function(a) .mc_p_values(o[[a]]$sim, stats_obs, USP_CATALOGUE_MC))
}
classer_s2 <- function(d, gran) {
  # Tolerance 1e-12 : un ecart d'exactement une granularite, calcule par
  # difference de deux fractions, peut depasser gran d'un arrondi.
  ifelse(is.na(d), "NA", ifelse(abs(d) <= gran + 1e-12, "n\u00e9gligeable",
                                ifelse(abs(d) <= SEUIL_S2, "mineur", "mat\u00e9riel")))
}
table_T5 <- function(pm, nom_jeu) {
  noms <- names(pm$R$p_mc)
  dC <- pm$C$p_mc - pm$R$p_mc; d3 <- pm$R3$p_mc - pm$R$p_mc
  gran <- pm$R$granularite
  sC <- classer_s2(dC, gran); s3 <- classer_s2(d3, gran)
  L <- c(sprintf("### T5 -- %s : p_mc des %d statistiques du catalogue", nom_jeu, length(noms)), "",
         entete_md(c("Stat.", "Queue", "p_R", "p_C", "p_R3", "p_C \u2212 p_R", "p_R3 \u2212 p_R",
                     "err_mc (R)", "granularit\u00e9 (R)", "S2 (C)", "S2 (R3)")))
  for (i in seq_along(noms))
    L <- c(L, ligne_md(noms[i], USP_CATALOGUE_MC[[noms[i]]]$queue,
                       fmt(pm$R$p_mc[i], 4), fmt(pm$C$p_mc[i], 4), fmt(pm$R3$p_mc[i], 4),
                       fmt(dC[i], 3), fmt(d3[i], 3), fmt(pm$R$err_mc[i], 3), fmt(gran[i], 3),
                       sC[i], s3[i]))
  L <- c(L, "", sprintf("max |p_C \u2212 p_R| = %s (%s) ; max |p_R3 \u2212 p_R| = %s ; B effectif R / C / R3 : %s / %s / %s.",
                        fmt(max(abs(dC), na.rm = TRUE), 4), noms[which.max(abs(dC))],
                        fmt(max(abs(d3), na.rm = TRUE), 4),
                        paste(range(pm$R$B_effectif), collapse = "-"),
                        paste(range(pm$C$B_effectif), collapse = "-"),
                        paste(range(pm$R3$B_effectif), collapse = "-")), "")
  ecrire_console(L)
  pire <- function(s) if (any(s == "mat\u00e9riel")) "mat\u00e9riel" else if (any(s == "mineur")) "mineur"
                      else if (any(s == "NA")) "NA" else "n\u00e9gligeable"
  list(C = pire(sC), R3 = pire(s3), max_C = max(abs(dC), na.rm = TRUE), max_R3 = max(abs(d3), na.rm = TRUE))
}

# --- Execution ----------------------------------------------------------------------
temps <- list()
chrono <- function(etape, expr) {
  t0 <- Sys.time(); v <- expr
  temps[[etape]] <<- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  v
}
integrite <- character(0)   # constats d'echec S5
bilan <- list()
csv_lignes <- list()

commit <- tryCatch(suppressWarnings(system2("git", c("-C", RACINE, "rev-parse", "--short", "HEAD"),
                                            stdout = TRUE, stderr = FALSE)),
                   error = function(e) "inconnu")
modif_moteur <- tryCatch(suppressWarnings(system2("git", c("-C", RACINE, "status", "--porcelain", "R/engine.R"),
                                                  stdout = TRUE, stderr = FALSE)),
                         error = function(e) character(0))
md5_moteur <- unname(tools::md5sum(file.path(RACINE, "R", "engine.R")))

ecrire_console(c(
  "## Issue #43 -- r\u00e9ajustement bootstrap : usp_ajuster_rapide() (R) contre usp_ajuster() (C), candidat R3",
  "", "### T0 -- en-t\u00eate", "",
  sprintf("- Jeux : %s", paste(vapply(JEUX[JEUX_RETENUS], function(j) j$libelle, ""), collapse = " ; ")),
  sprintf("- B = %d, graine = %.0f ; seconde passe : %s", OPT_B, OPT_GRAINE,
          if (OPT_SECONDE) sprintf("automatique (B = %d, graine = %.0f)", B_SECONDE, GRAINE_SECONDE) else "d\u00e9sactiv\u00e9e (--sans-seconde-passe)"),
  sprintf("- G\u00e9n\u00e9rateur (engine_sous_graine()) : %s", paste(ENGINE_RNG_KIND, collapse = ", ")),
  sprintf("- %s ; plateforme %s", R.version.string, R.version$platform),
  sprintf("- md5 de R/engine.R : %s ; commit %s%s", md5_moteur, paste(commit, collapse = ""),
          if (length(modif_moteur)) " (R/engine.R MODIFI\u00c9 dans l'arbre de travail)" else " (R/engine.R conforme au commit)"),
  sprintf("- Seuils : TOL_OPTIMUM = %g, TOL_DELTA_BORD = %g ; S1 %g, S2 %g, S3 %g, S4 %g", TOL_OPTIMUM,
          TOL_DELTA_BORD, SEUIL_S1, SEUIL_S2, SEUIL_S3, SEUIL_S4), ""))

for (nj in JEUX_RETENUS) {
  j <- JEUX[[nj]]
  fit <- usp_ajuster(j$x, j$y)
  ecrire_console(c(sprintf("## %s", j$libelle), "",
                   sprintf("Ajustement observ\u00e9 (C) : \u03b4 = %s, \u03b3 = %s, \u03c3 = %s, O = %s.",
                           fmt(fit$delta, 7), fmt(fit$gamma, 7), fmt(fit$sigma, 7), fmt(fit$obj_min, 10)), ""))
  o <- chrono(sprintf("%s : rejeu B = %d (R, C, R3)", nj, OPT_B), rejouer(fit, OPT_B, OPT_GRAINE))

  # --- S5 : integrite contre le bootstrap du moteur ---
  s5 <- character(0)
  ref_boot <- chrono(sprintf("%s : usp_bootstrap() du moteur", nj), usp_bootstrap(fit, B = OPT_B, seed = OPT_GRAINE))
  vR <- vecteurs_boot(o$R)
  pR <- .mc_p_values(o$R$sim, .stats_bootstrapables(fit$x, fit$y, fit$z, fit$pi), USP_CATALOGUE_MC)
  controler <- function(nom, a, b) if (!identical(a, b)) s5 <<- c(s5, nom)
  for (ch in c("sigma_boot", "delta_boot", "gamma_boot"))
    controler(paste0("usp_bootstrap()$", ch), vR[[ch]], ref_boot[[ch]])
  controler("usp_bootstrap()$p_mc", pR$p_mc, ref_boot$p_mc)
  controler("usp_bootstrap()$err_mc", pR$err_mc, ref_boot$err_mc)
  controler("usp_bootstrap()$B_effectif", pR$B_effectif, ref_boot$B_effectif)
  res_cas <- list()
  if (nj == "J1") {
    res_cas <- chrono("J1 : run_engine() des quatre cas", lapply(stats::setNames(CAS_LN, CAS_LN), function(cc) CAS[[cc]]()))
    defaut <- OPT_B == 999L && OPT_GRAINE == 20260831
    for (cc in CAS_LN) {
      rb <- res_cas[[cc]]$bootstrap
      controler(sprintf("run_engine(%s)$ajustement delta/gamma", cc),
                c(res_cas[[cc]]$ajustement$delta, res_cas[[cc]]$ajustement$gamma), c(fit$delta, fit$gamma))
      if (defaut) {
        for (ch in c("sigma_boot", "delta_boot", "gamma_boot"))
          controler(sprintf("run_engine(%s)$bootstrap$%s", cc, ch), vR[[ch]], rb[[ch]])
        controler(sprintf("run_engine(%s)$bootstrap$p_mc", cc), pR$p_mc, rb$p_mc)
      }
    }
  }
  n_neg <- sum(o$R$ok_ajust & o$C$ok_ajust & (o$R$obj - o$C$obj) < -TOL_OPTIMUM) +
           sum(o$R3$ok_ajust & o$C$ok_ajust & (o$R3$obj - o$C$obj) < -TOL_OPTIMUM)
  n_ech <- sum(vapply(AJ, function(a) sum(!o[[a]]$ok_ajust) + sum(o[[a]]$ok_ajust & !o[[a]]$ok_stats), 0))
  if (n_neg > 0) s5 <- c(s5, sprintf("%d r\u00e9plication(s) \u00e0 \u0394O < \u22121e-6 (C pire)", n_neg))
  if (n_ech > 0) s5 <- c(s5, sprintf("%d \u00e9chec(s) de r\u00e9ajustement ou de statistiques", n_ech))
  ecrire_console(c(sprintf("Contr\u00f4le d'int\u00e9grit\u00e9 S5 (%s) : %s", nj,
                           if (length(s5)) paste("\u00c9CHEC --", paste(s5, collapse = " ; "))
                           else if (nj == "J1" && !(OPT_B == 999L && OPT_GRAINE == 20260831))
                             "OK (usp_bootstrap() ; comparaison \u00e0 run_engine() omise : B ou graine hors d\u00e9faut)"
                           else sprintf("OK (identical() avec usp_bootstrap()%s ; aucun \u0394O < \u22121e-6 ; aucun \u00e9chec)",
                                        if (nj == "J1") " et run_engine() des quatre cas" else "")), ""))
  # Rejeu identique au moteur exige avant toute exploitation (paragraphe 3) :
  # une divergence des sigma, delta, gamma ou p_mc de R arrete le script.
  if (any(grepl("^(usp_bootstrap|run_engine)", s5))) {
    ecrire_console("ARR\u00caT : le rejeu ne reproduit pas le bootstrap du moteur ; mesure invalide.")
    quit(status = 1)
  }
  integrite <- c(integrite, if (length(s5)) paste(nj, ":", s5))

  # --- Agregats 1 a 4 ---
  rq <- analyser(o, nj, sprintf("B = %d, graine %.0f", OPT_B, OPT_GRAINE))

  # --- Agregat 6 : p_mc ---
  pm <- p_mc_ajusteurs(fit, o)
  s2 <- table_T5(pm, nj)

  # --- Agregats 5 (sigma_USP) et 7 (verdicts), J1 seulement ---
  s3 <- NULL; s2_verdict <- NULL
  if (nj == "J1") {
    vX <- lapply(o[AJ], vecteurs_boot)
    L7 <- c("### T7 -- J1 : IC bootstrap de \u03c3_USP par cas (quantiles 2,5 / 5 / 50 / 95 / 97,5 %)", "",
            entete_md(c("Cas", "Quantile", "R", "C", "R3", "(C \u2212 R)/R", "(R3 \u2212 R)/R")))
    L7b <- c("", entete_md(c("Cas", "largeur_ic R", "largeur_ic C", "largeur_ic R3", "max abs((C \u2212 R)/R)",
                              "max abs((R3 \u2212 R)/R)", "S3 (C)", "S3 (R3)")))
    L6 <- c("### T6 -- J1 : lignes de la table des tests dont p_retenue, nature_p ou verdict change", "")
    s3 <- list(C = "aucun", R3 = "aucun"); s2_verdict <- list(C = 0L, R3 = 0L)
    for (cc in CAS_LN) {
      res <- res_cas[[cc]]; pf <- res$parametre_final; md <- res$metadata
      qX <- lapply(vX, function(v) {
        ub <- pf$credibilite * v$sigma_boot * pf$correction_taille + (1 - pf$credibilite) * pf$sigma_standard
        if (length(ub) > 20) stats::quantile(ub, c(.025, .05, .5, .95, .975)) else NULL
      })
      larg <- vapply(qX, function(q) unname((q[4] - q[2]) / pf$sigma_usp), 0)
      if (OPT_B == 999L && OPT_GRAINE == 20260831) {
        if (!identical(qX$R, res$ic_bootstrap)) integrite <- c(integrite, sprintf("J1 : IC R de %s diff\u00e9rent de res$ic_bootstrap", cc))
        if (!identical(unname(larg[["R"]]), res$ajustement$largeur_ic)) integrite <- c(integrite, sprintf("J1 : largeur_ic R de %s diff\u00e9rente", cc))
      }
      eC <- (qX$C - qX$R) / qX$R; e3 <- (qX$R3 - qX$R) / qX$R
      for (i in 1:5)
        L7 <- c(L7, ligne_md(cc, names(qX$R)[i], fmt(qX$R[i], 7), fmt(qX$C[i], 7), fmt(qX$R3[i], 7),
                             fmt(eC[i], 3), fmt(e3[i], 3)))
      clS3 <- function(e) if (max(abs(e)) > SEUIL_S3) "mat\u00e9riel" else "aucun"
      if (clS3(eC) != "aucun") s3$C <- "mat\u00e9riel"
      if (clS3(e3) != "aucun") s3$R3 <- "mat\u00e9riel"
      L7b <- c(L7b, ligne_md(cc, fmt(larg[["R"]], 6), fmt(larg[["C"]], 6), fmt(larg[["R3"]], 6),
                             fmt(max(abs(eC)), 3), fmt(max(abs(e3)), 3), clS3(eC), clS3(e3)))
      # Verdicts : usp_tests() avec le bootstrap remplace (paragraphe 5, point 7).
      jk <- res$jackknife; d_jack <- jk$sigma_usp - pf$sigma_usp
      rob <- if (any(is.finite(d_jack))) {
        i_j <- which.max(abs(d_jack)); list(jack_annee = i_j, jack_usp = d_jack[i_j] / pf$sigma_usp)
      } else list(jack_annee = NULL, jack_usp = NULL)
      # Les champs du bootstrap sont remplaces pour les TROIS ajusteurs, R
      # compris : a B et graine par defaut, le rejeu R reproduit res$tests
      # (controle d'integrite ci-dessous) ; hors defaut, R, C et R3 restent
      # comparables entre eux.
      tests_de <- function(a) {
        b <- res$bootstrap; f <- res$ajustement
        b$p_mc <- pm[[a]]$p_mc; b$err_mc <- pm[[a]]$err_mc; b$B_effectif <- pm[[a]]$B_effectif
        b$granularite_stat <- pm[[a]]$granularite
        b[c("sigma_boot", "delta_boot", "gamma_boot")] <- vX[[a]]
        f$largeur_ic <- larg[[a]]
        # lr_delta : repris tel quel de run_engine() (res$lr_delta, issue #45)
        # pour les trois ajusteurs, comme run_engine() le passe a usp_tests() ;
        # son bootstrap restreint (usp_lr_delta(), flux propre) reajuste par
        # usp_ajuster_rapide() seul et n'entre pas dans la comparaison.
        usp_tests(f, b, md$alpha, theta_equiv = md$theta_equiv, delta_equiv = md$delta_equiv,
                  robustesse = rob, methode = md$methode, lr_delta = res$lr_delta)
      }
      tR <- tests_de("R")
      if (OPT_B == 999L && OPT_GRAINE == 20260831 && !identical(tR, res$tests))
        integrite <- c(integrite, sprintf("J1 : usp_tests() reconstruit pour %s diff\u00e9rent de res$tests", cc))
      for (a in c("C", "R3")) {
        tX <- tests_de(a)
        lignes <- character(0); trans <- character(0)
        for (i in seq_along(tR)) {
          u <- tR[[i]]; v <- tX[[i]]
          if (!identical(u$p_retenue, v$p_retenue) || !identical(u$nature_p, v$nature_p) ||
              !identical(u$verdict, v$verdict)) {
            lignes <- c(lignes, ligne_md(cc, a, i, cellule(u$test, 60), cellule(u$nature_p, 45),
                                         fmt(u$p_retenue, 4), fmt(v$p_retenue, 4),
                                         u$verdict, v$verdict))
            if (!identical(u$verdict, v$verdict)) trans <- c(trans, paste(u$verdict, "\u2192", v$verdict))
          }
        }
        s2_verdict[[a]] <- s2_verdict[[a]] + length(trans)
        L6 <- c(L6, sprintf("%s, R \u2192 %s : %d ligne(s) modifi\u00e9e(s) sur %d ; verdicts modifi\u00e9s : %s.",
                            cc, a, length(lignes), length(tR),
                            if (length(trans)) paste(names(table(trans)), table(trans), sep = " : ", collapse = " ; ") else "aucun"))
        if (length(lignes))
          L6 <- c(L6, "", entete_md(c("Cas", "X", "Ligne", "Test", "nature_p (R)", "p_retenue R",
                                      "p_retenue X", "verdict R", "verdict X")), lignes, "")
      }
    }
    ecrire_console(c(L6, ""))
    ecrire_console(c(L7, L7b, ""))
  }

  # --- Seconde passe (paragraphe 3) ---
  rq2 <- NULL
  if (OPT_SECONDE && isTRUE(rq$R$contient)) {
    ecrire_console(c(sprintf("Seconde passe sur %s : l'IC de Clopper-Pearson de q_opt (R) contient 1 %%.", nj), ""))
    o2 <- chrono(sprintf("%s : seconde passe B = %d", nj, B_SECONDE), rejouer(fit, B_SECONDE, GRAINE_SECONDE))
    rq2 <- analyser(o2, nj, sprintf("seconde passe B = %d, graine %.0f", B_SECONDE, GRAINE_SECONDE))
    if (!is.na(OPT_CSV)) csv_lignes[[paste(nj, "seconde")]] <- list(o = o2, jeu = nj, passe = "seconde")
  }
  if (!is.na(OPT_CSV)) csv_lignes[[paste(nj, "premiere")]] <- list(o = o, jeu = nj, passe = "premiere")

  bilan[[nj]] <- list(rq = rq, rq2 = rq2, s2 = s2, s3 = s3, s2_verdict = s2_verdict, s5 = s5)
}

# --- CSV hors depot -------------------------------------------------------------------
if (!is.na(OPT_CSV)) {
  df <- do.call(rbind, lapply(csv_lignes, function(e) {
    o <- e$o
    d <- data.frame(jeu = e$jeu, passe = e$passe, b = seq_len(o$B))
    for (a in AJ) for (g in c("delta", "gamma", "sigma", "obj", "ok_ajust", "ok_stats"))
      d[[paste0(g, "_", a)]] <- o[[a]][[g]]
    d$n_starts_optimum_C <- o$C$n_starts_optimum; d$kkt_C <- o$C$kkt
    d
  }))
  utils::write.csv(df, OPT_CSV, row.names = FALSE)
  ecrire_console(c(sprintf("Valeurs par r\u00e9plication \u00e9crites dans %s (%d lignes).", OPT_CSV, nrow(df)), ""))
}

# --- T8 : bilan -------------------------------------------------------------------
classe_s1 <- function(q) if (q$k == 0) "aucun" else if (q$q > SEUIL_S1) "mat\u00e9riel" else "mineur"
L8 <- c("### T8 -- bilan S1 \u00e0 S5 (rep\u00e8res du protocole ; la conclusion revient \u00e0 actuary)", "",
        entete_md(c("Jeu", "Ajusteur", "S1 (q_opt, IC 95 %)", "S1 seconde passe", "S2 (p_mc)",
                    "S2 verdicts modifi\u00e9s", "S3 (IC \u03c3_USP)", "S4 (tol\u00e9rance, max abs(\u0394\u03c3*)/\u03c3*)", "S5")))
for (nj in names(bilan)) {
  bj <- bilan[[nj]]
  for (a in c("R", "R3")) {
    X <- if (a == "R") "C" else "R3"
    q <- bj$rq[[a]]
    s1 <- sprintf("%s (%d/%d ; [%.4f ; %.4f])", classe_s1(q), q$k, q$n, q$ic[1], q$ic[2])
    s1b <- if (is.null(bj$rq2)) "\u2014" else {
      q2 <- bj$rq2[[a]]; sprintf("%s (%d/%d ; [%.4f ; %.4f])", classe_s1(q2), q2$k, q2$n, q2$ic[1], q2$ic[2])
    }
    s2 <- sprintf("%s (max %s)", bj$s2[[X]], fmt(bj$s2[[paste0("max_", X)]], 3))
    s2v <- if (is.null(bj$s2_verdict)) "\u2014 (J2 : pas de cas)" else as.character(bj$s2_verdict[[X]])
    s3 <- if (is.null(bj$s3)) "\u2014" else bj$s3[[X]]
    # S4 : maximum sur les deux passes quand la seconde a eu lieu.
    m4 <- max(q$max_ds_tol, if (!is.null(bj$rq2)) bj$rq2[[a]]$max_ds_tol, na.rm = TRUE)
    s4 <- sprintf("%s (%s)", if (isTRUE(m4 > SEUIL_S4)) "anomalie (#63)" else "conforme", fmt(m4, 3))
    s5 <- if (length(bj$s5) || any(startsWith(integrite, nj))) "\u00e9chec" else "OK"
    L8 <- c(L8, ligne_md(nj, if (a == "R") "R (moteur) contre C" else "R3 contre C", s1, s1b, s2, s2v, s3, s4, s5))
  }
}
L8 <- c(L8, "", "Colonnes S2 et S3 : \u00e9cart de la p_mc ou du quantile obtenu avec C (ligne R) ou avec R3 (ligne R3), rapport\u00e9 \u00e0 l'ajusteur actuel R.",
        "", "### Temps d'ex\u00e9cution", "",
        entete_md(c("\u00c9tape", "secondes")),
        vapply(names(temps), function(k) ligne_md(k, sprintf("%.1f", temps[[k]])), ""),
        ligne_md("total", sprintf("%.1f", as.numeric(difftime(Sys.time(), t_debut, units = "secs")))), "")
if (length(integrite))
  L8 <- c(L8, "Contr\u00f4le d'int\u00e9grit\u00e9 S5 : \u00c9CHEC", paste("-", integrite), "")
ecrire_console(L8)
quit(status = if (length(integrite)) 1L else 0L)
