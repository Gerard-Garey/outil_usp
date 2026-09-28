###############################################################################
#  tests/unitaires/test_volumes_constants.R  --  UNE SEULE NOTION DE VOLUMES
#                                               CONSTANTS (ISSUE #59)
#
#  Specification commune #44 / #70 / #59 d'actuary (26/09/2026), section 3 :
#    - predicat unique usp_volumes_constants() (regle R11), lu par
#      usp_regime() ;
#    - fonctions de test : NA a volumes constants ou quasi constants, memes
#      noms de champs que la branche calculee, aucune erreur R (R11, R12) ;
#    - usp_tests() / run_engine() : treize lignes "non applicable" avec un
#      motif unique (R13), aucune erreur R pour une etendue relative de 1e-12
#      a 1e-6 (constat de l'issue : "subscript out of bounds" dans
#      test_lm_complet()) ;
#    - invariant I5 : la liste des lignes ne depend pas du regime ;
#    - issue #110 (specification d'actuary) : RESET et White en base reduite
#      s = (x - moyenne) / etendue, non applicables a moins de trois volumes
#      distincts (motif (a)) ou sur rang numerique deficient (motif (b)).
#  References : definition de la specification (diff(range(x)) <= tol *
#  mean(x)), texte des regles R11-R13, liste des lignes de run_engine() sur
#  les donnees de test (volumes variables).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_volumes_constants.R")

x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
alt <- rep(c(1, -1), 4)

# Les treize lignes de la regle R13.
NOMS_R13 <- c("Nullite de la constante (proportionnalite stricte)",
              "Equivalence de la constante a zero (TOST)",
              "Test de Student sur la pente (lm(y~x))",
              "Test de Fisher (significativite globale)",
              "Coefficient de determination R2",
              "RESET (forme fonctionnelle)",
              "Independance ratio S/P vs volume",
              "Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)",
              "Heteroscedasticite vs volume - Breusch-Pagan original (non robuste)",
              "Heteroscedasticite (forme quadratique)",
              "Egalite des variances petits vs gros volumes",
              "Homogeneite des dispersions (mediane)",
              "Egalite des lois petits vs gros volumes (2 ech.)")
MOTIF_R13 <- "^volumes x_t constants a la tolerance relative TOL_DELTA_BORD = 1e-06 pres \\(etendue relative = [^)]+\\) : regression / partition sur le volume sans objet$"

lancer <- function(xx, methode = "premium")
  run_engine(xt = xx, yt = y, methode = methode, segment = 1, annexe = "II",
             nature_donnees = if (methode == "premium") "brutes", B = B_MIN_USAGE, seed = 20260831)

## --- 1. Predicat unique (regle R11) ------------------------------------------
verifier("usp_volumes_constants : definition diff(range(x)) <= TOL_DELTA_BORD * mean(x)",
         {
           cas <- list(rep(110, 8), 100 * (1 + alt * 1e-8), 100 * (1 + alt * 4e-7),
                       100 * (1 + alt * 1e-5), 110 * (1 + c(0, 2e-6, rep(0, 6))), x)
           att <- c(TRUE, TRUE, TRUE, FALSE, FALSE, FALSE)
           obt <- vapply(cas, usp_volumes_constants, logical(1))
           ref <- vapply(cas, function(v) diff(range(v)) <= 1e-6 * mean(v), logical(1))
           if (identical(obt, att) && identical(obt, ref)) TRUE
           else paste("obtenu :", paste(obt, collapse = " "))
         })
verifier("usp_regime()$volumes_constants = usp_volumes_constants(x) (une seule definition)",
         all(vapply(list(rep(110, 8), 100 * (1 + alt * 1e-8), 100 * (1 + alt * 1e-5), x),
                    function(v) identical(usp_regime(0.37, v)$volumes_constants,
                                          usp_volumes_constants(v)), logical(1))))
verifier("R/engine.R : plus aucune garde sd(x) == 0, sd(x) > 0 ni sd(reg) == 0",
         {
           f <- if (file.exists("R/engine.R")) "R/engine.R" else file.path("..", "R", "engine.R")
           src <- readLines(f, warn = FALSE)
           code <- sub("#.*$", "", src)
           k <- grep("sd\\((e\\$)?(x|reg)\\) *(==|>) *0", code)
           if (!length(k)) TRUE else paste("lignes", paste(k, collapse = ", "))
         })

## --- 2. Fonctions de test appelees directement (regles R11, R12) --------------
x_q <- 100 * (1 + alt * 1e-8)                  # quasi constant, dans la bande
fit_q <- usp_ajuster(x_q, y)
verifier("Fonctions de R11 a volumes quasi constants : stat et p NA, memes noms de champs que la branche calculee",
         {
           appels <- list(
             lm_complet = function(v) test_lm_complet(v, y),
             reset      = function(v) test_reset(v, y),
             tost       = function(v) test_tost_intercept(v, y),
             intercept  = function(v) test_intercept(v, y),
             bp79       = function(v) test_breusch_pagan_original(fit_q$z^2, v),
             bp         = function(v) test_breusch_pagan(fit_q$z^2, v),
             white      = function(v) test_white(fit_q$z^2, v),
             gq         = function(v) test_goldfeld_quandt(fit_q$z, v),
             bf         = function(v) test_brown_forsythe(fit_q$z, v))
           pb <- character(0)
           for (nm in names(appels)) {
             a <- tryCatch(appels[[nm]](x_q), error = function(e) e)
             b <- appels[[nm]](x)
             if (inherits(a, "error")) { pb <- c(pb, paste(nm, ": erreur", conditionMessage(a))); next }
             if (!identical(names(a), names(b))) pb <- c(pb, paste(nm, ": noms de champs"))
             st <- if (nm == "lm_complet") a$t_pente else a$stat
             p  <- if (nm == "lm_complet") c(a$p_pente, a$p_F) else a$p
             if (!is.na(st) || any(!is.na(p))) pb <- c(pb, paste(nm, ": valeur calculee"))
             if (!all(is.finite(if (nm == "lm_complet") b$p_pente else b$p)))
               pb <- c(pb, paste(nm, ": branche calculee non finie sur volumes variables"))
           }
           if (length(pb)) paste(pb, collapse = " ; ") else TRUE
         })
verifier("Goldfeld-Quandt a volumes constants : NA, et non la comparaison des deux moities de la periode",
         {
           g <- test_goldfeld_quandt(fit_q$z, rep(110, 8))
           u <- fit_q$z; h <- 4
           moities <- (sum(u[5:8]^2) / h) / (sum(u[1:4]^2) / h)
           is.na(g$stat) && is.na(g$p) && is.finite(moities)
         })
verifier("Catalogue Monte-Carlo a volumes quasi constants : Intercept, RESET, BP, BP79, White, GQ, BF, Smirnov, SpearVol NA, sans erreur",
         {
           s <- tryCatch(.stats_bootstrapables(x_q, y, fit_q$z), error = function(e) e)
           nm <- c("Intercept", "RESET", "BP", "BP79", "White", "GQ", "BF", "Smirnov", "SpearVol")
           if (inherits(s, "error")) paste("erreur :", conditionMessage(s))
           else if (all(is.na(s[nm]))) TRUE
           else paste("finies :", paste(nm[!is.na(s[nm])], collapse = ", "))
         })

## --- 3. run_engine() dans la bande (regle R13, aucune erreur R) --------------
res_var <- lancer(x)
noms_ref <- vapply(res_var$tests, `[[`, character(1), "test")
dans_bande <- list(
  "x = 100 (1 +/- 1e-12)" = 100 * (1 + alt * 1e-12),
  "x = 100 (1 +/- 1e-10)" = 100 * (1 + alt * 1e-10),
  "x = 100 (1 +/- 1e-8)"  = 100 * (1 + alt * 1e-8),
  "x = 100 (1 +/- 1e-7)"  = 100 * (1 + alt * 1e-7),
  # la frontiere exacte 2 eps = TOL_DELTA_BORD n'est pas testee : son issue
  # depend de l'arrondi des entrees.
  "x = 100 (1 +/- 4e-7)"  = 100 * (1 + alt * 4e-7),
  "x = 110 (1 + (0, 1e-8, 0...))" = 110 * (1 + c(0, 1e-8, rep(0, 6))),
  "x = 110 (1 + (0, 5e-7, 0...))" = 110 * (1 + c(0, 5e-7, rep(0, 6))),
  "x = 110 (1 + (0, 1e-6, 0...))" = 110 * (1 + c(0, 1e-6, rep(0, 6))),
  "x = rep(110, 8)" = rep(110, 8))
res_bande <- lapply(dans_bande, function(v) tryCatch(lancer(v), error = function(e) e))
controle_r13 <- function(r) {
  if (inherits(r, "error")) return(paste("erreur R :", conditionMessage(r)))
  if (!isTRUE(r$ok)) return(paste("ok FALSE :", r$validation$erreurs[1]))
  L <- r$tests
  noms <- vapply(L, `[[`, character(1), "test")
  if (!identical(noms, noms_ref)) return("liste des lignes differente (invariant I5)")
  pb <- character(0)
  for (l in L[noms %in% NOMS_R13]) {
    if (l$type != "non applicable") pb <- c(pb, paste(l$test, ": type", l$type))
    if (!grepl(MOTIF_R13, l$detail)) pb <- c(pb, paste(l$test, ": motif"))
    if (l$verdict != "INFO") pb <- c(pb, paste(l$test, ": verdict", l$verdict))
    if (any(is.finite(c(l$stat, l$estim, l$p_exacte, l$p_asymptotique, l$p_mc, l$p_retenue))))
      pb <- c(pb, paste(l$test, ": valeur calculee"))
  }
  if (length(pb)) paste(pb, collapse = " ; ") else TRUE
}
for (nm in names(dans_bande)) local({
  r <- res_bande[[nm]]
  verifier(sprintf("run_engine(premium), %s : ok, memes lignes qu'a volumes variables, treize lignes non applicables au motif unique (#59)", nm),
           controle_r13(r))
})
verifier("Volumes quasi constants : aucune erreur R interceptee par run_engine() (constat de l'issue #59)",
         all(vapply(res_bande, function(r) !inherits(r, "error") && is.null(r$validation$erreur_r),
                    logical(1))))
verifier("Motif R13 : etendue relative imprimee (0 a volumes exactement constants, 2e-08 a 1 +/- 1e-8)",
         {
           d <- function(r) Filter(function(l) l$test == NOMS_R13[6], r$tests)[[1]]$detail
           grepl("(etendue relative = 0)", d(res_bande[["x = rep(110, 8)"]]), fixed = TRUE) &&
             grepl("(etendue relative = 2e-08)", d(res_bande[["x = 100 (1 +/- 1e-8)"]]), fixed = TRUE)
         })
verifier("Volumes exactement constants : memes types que dans la bande, ligne par ligne",
         {
           ty <- function(r) vapply(r$tests, `[[`, character(1), "type")
           identical(ty(res_bande[["x = rep(110, 8)"]]), ty(res_bande[["x = 110 (1 + (0, 5e-7, 0...))"]]))
         })
verifier("Volumes constants : bootstrap sans erreur, B_effectif = 0 et motif Monte-Carlo pose pour les neuf statistiques (regle R14)",
         {
           b <- res_bande[["x = rep(110, 8)"]]$bootstrap
           nm <- c("Intercept", "RESET", "BP", "BP79", "White", "GQ", "BF", "Smirnov", "SpearVol")
           # Motif de priorite R2 d'engine_p_mc() (observe NA avant B_eff = 0).
           all(b$B_effectif[nm] == 0) && all(b$motif_mc[nm] == MOTIF_MC_OBS_NON_FINIE)
         })
# Valeurs mesurees (non-regression, #58 : mesure du 23/09/2026 reconfirmee
# pour #59) : sigma_USP ne depend d'aucune des treize lignes.
verifier("Volumes exactement constants : sigma_USP = 0,1261524 (premium) et 0,1220524 (reserve1), inchange par #59",
         {
           r1 <- lancer(rep(110, 8), "reserve1")
           proche(res_bande[["x = rep(110, 8)"]]$parametre_final$sigma_usp, 0.1261524, abs = 5e-8) &&
             proche(r1$parametre_final$sigma_usp, 0.1220524, abs = 5e-8) &&
             identical(vapply(r1$tests, `[[`, character(1), "test"), noms_ref)
         })

## --- 4. Hors de la bande : lignes calculees ------------------------------------
# Formes de reference calculees ici, independamment du moteur (issue #110) :
# forme standard de RESET (f = beta_hat x, regresseurs f^2, f^3) et de White
# ({1, x, x^2}) ; forme orthogonale poly(x, 2), qui engendre le meme espace
# et reste de plein rang quand la forme standard perd x^3 (resp. x^2) par
# colinearite numerique.
reset_std <- function(v, yy) {
  m0 <- stats::lm(yy ~ v - 1); f <- stats::fitted(m0)
  stats::anova(m0, stats::lm(yy ~ v + I(f^2) + I(f^3) - 1))$F[2]
}
reset_poly <- function(v, yy) {
  m0 <- stats::lm(yy ~ v - 1); P <- stats::poly(v, 2)
  stats::anova(m0, stats::lm(yy ~ v + I(v * P[, 1]) + I(v * P[, 2]) - 1))$F[2]
}
white_std  <- function(u2, v) length(u2) * summary(stats::lm(u2 ~ v + I(v^2)))$r.squared
white_poly <- function(u2, v) length(u2) * summary(stats::lm(u2 ~ stats::poly(v, 2)))$r.squared
fit_x <- usp_ajuster(x, y)
MOTIF_A <- "moins de trois volumes distincts (k = 2)"
MOTIF_B <- "de rang deficient : terme ecarte par lm() pour colinearite, test non applicable"
ligne <- function(r, nom) Filter(function(l) l$test == nom, r$tests)[[1]]

# Huit volumes distincts, etendue relative ~4 % : la forme standard est de
# plein rang ; le moteur (base reduite) rend la meme statistique.
verifier("x = 100 (1 + 0,01 scale(1:8)), hors bande, huit volumes distincts : treize lignes calculees, F RESET et LM White du moteur = forme standard (rel 1e-10)",
         {
           x8 <- 100 * (1 + 0.01 * as.numeric(scale(1:8)))
           r <- lancer(x8)
           L <- Filter(function(l) l$test %in% NOMS_R13, r$tests)
           ty <- vapply(L, `[[`, character(1), "type")
           f8 <- usp_ajuster(x8, y)
           isTRUE(r$ok) && length(L) == 13L && all(ty %in% c("test", "diagnostic")) &&
             identical(vapply(r$tests, `[[`, character(1), "test"), noms_ref) &&
             isTRUE(proche(test_reset(x8, y)$stat, reset_std(x8, y), rel = 1e-10)) &&
             isTRUE(proche(test_white(f8$z^2, x8)$stat, white_std(f8$z^2, x8), rel = 1e-10))
         })
# Deux volumes distincts : regression auxiliaire de rang 2, RESET et White
# non applicables au motif (a) (issue #110) ; les onze autres lignes de R13
# sont calculees.
verifier("x = 100 (1 +/- 1e-5), hors bande, k = 2 : onze lignes calculees, RESET et White non applicables au motif (a), INFO, p_retenue NA, motif Monte-Carlo observe non fini",
         {
           r <- lancer(100 * (1 + alt * 1e-5))
           L <- Filter(function(l) l$test %in% NOMS_R13, r$tests)
           ty <- stats::setNames(vapply(L, `[[`, character(1), "type"),
                                 vapply(L, `[[`, character(1), "test"))
           na <- NOMS_R13[c(6, 10)]
           b <- r$bootstrap
           isTRUE(r$ok) && length(L) == 13L &&
             all(ty[setdiff(NOMS_R13, na)] %in% c("test", "diagnostic")) &&
             all(vapply(na, function(nm) {
               l <- ligne(r, nm)
               l$type == "non applicable" && startsWith(l$detail, MOTIF_A) &&
                 l$verdict == "INFO" && is.na(l$p_retenue) && is.na(l$nature_p)
             }, logical(1))) &&
             all(b$motif_mc[c("RESET", "White")] == MOTIF_MC_OBS_NON_FINIE) &&
             all(b$B_effectif[c("RESET", "White")] == 0) &&
             identical(vapply(r$tests, `[[`, character(1), "test"), noms_ref)
         })
# A e = 2e-6 une seule annee differe (k = 2) : RESET et White au motif (a) ;
# la partition par la mediane des volumes laisse 1 et 7 annees, Smirnov n'est
# pas calculable (ligne presente, non applicable, motif de la partition et
# non celui des volumes constants).
verifier("x = 110 (1 + (0, 2e-6, 0...)), hors bande, k = 2 : dix lignes calculees, RESET et White au motif (a), Smirnov non applicable par la partition",
         {
           r <- lancer(110 * (1 + c(0, 2e-6, rep(0, 6))))
           L <- Filter(function(l) l$test %in% NOMS_R13, r$tests)
           ty <- stats::setNames(vapply(L, `[[`, character(1), "type"),
                                 vapply(L, `[[`, character(1), "test"))
           sm <- ligne(r, NOMS_R13[13])
           isTRUE(r$ok) && length(L) == 13L &&
             all(ty[NOMS_R13[-c(6, 10, 13)]] %in% c("test", "diagnostic")) &&
             all(vapply(NOMS_R13[c(6, 10)], function(nm) {
               l <- ligne(r, nm); l$type == "non applicable" && startsWith(l$detail, MOTIF_A)
             }, logical(1))) &&
             sm$type == "non applicable" &&
             startsWith(sm$detail, "partition par la mediane des volumes : groupes de 1 et 7") &&
             identical(vapply(r$tests, `[[`, character(1), "test"), noms_ref)
         })

## --- 4ter. RESET et White en base reduite (issue #110) ---------------------------
verifier("test_reset() et test_white() a deux volumes distincts (100, 101 alternes) : stat et p NA, motif (a)",
         {
           x2 <- rep(c(100, 101), 4)
           tr <- test_reset(x2, y); wh <- test_white(fit_x$z^2, x2)
           is.na(tr$stat) && is.na(tr$p) && startsWith(tr$non_applicable, MOTIF_A) &&
             is.na(wh$stat) && is.na(wh$p) && startsWith(wh$non_applicable, MOTIF_A)
         })
verifier("Branche calculee : non_applicable = NA_character_ ; volumes constants : motif \"volumes constants\"",
         identical(test_reset(x, y)$non_applicable, NA_character_) &&
           identical(test_white(fit_x$z^2, x)$non_applicable, NA_character_) &&
           identical(test_reset(rep(110, 8), y)$non_applicable, "volumes constants") &&
           identical(test_white(fit_x$z^2, rep(110, 8))$non_applicable, "volumes constants"))
# Etendue relative 2,9e-6 (hors bande, huit volumes distincts) : la forme
# standard perd x^3 (resp. x^2) ; la base reduite reste de plein rang et
# egale la forme orthogonale poly(x, 2).
verifier("x = 100 (1 + 1e-6 scale(1:8)), etendue 2,9e-6 : RESET et White finies, = forme poly(x, 2) (rel 1e-10)",
         {
           xe <- 100 * (1 + 1e-6 * as.numeric(scale(1:8)))
           fe <- usp_ajuster(xe, y)
           tr <- test_reset(xe, y); wh <- test_white(fe$z^2, xe)
           !usp_volumes_constants(xe) && is.finite(tr$stat) && is.finite(tr$p) &&
             is.finite(wh$stat) && is.finite(wh$p) &&
             isTRUE(proche(tr$stat, reset_poly(xe, y), rel = 1e-10)) &&
             isTRUE(proche(wh$stat, white_poly(fe$z^2, xe), rel = 1e-10))
         })
verifier("Grille d'etendues relatives {2,9e-6, 2,9e-4, 2,9e-3, 2,9e-2} : RESET et White = forme poly(x, 2) (rel 1e-10)",
         {
           pb <- character(0)
           for (cv in c(1e-6, 1e-4, 1e-3, 1e-2)) {
             xe <- 100 * (1 + cv * as.numeric(scale(1:8)))
             u2 <- fit_x$z^2
             if (!isTRUE(proche(test_reset(xe, y)$stat, reset_poly(xe, y), rel = 1e-10)))
               pb <- c(pb, sprintf("RESET cv = %g", cv))
             if (!isTRUE(proche(test_white(u2, xe)$stat, white_poly(u2, xe), rel = 1e-10)))
               pb <- c(pb, sprintf("White cv = %g", cv))
           }
           if (length(pb)) paste(pb, collapse = " ; ") else TRUE
         })
x3 <- 100 * (1 + 1e-2 * rep(c(-1, 0, 1), length.out = 8))
verifier("k = 3 (100 (1 + 1e-2 (-1, 0, 1, ...))) : RESET et White finies",
         {
           tr <- test_reset(x3, y); wh <- test_white(fit_x$z^2, x3)
           .usp_nb_volumes_distincts(x3) == 3L && is.finite(tr$stat) && is.finite(tr$p) &&
             is.finite(wh$stat) && is.finite(wh$p) && is.na(tr$non_applicable) && is.na(wh$non_applicable)
         })
verifier("k = 3, troisieme valeur a 1e-13 relatif de la premiere : RESET et White au motif (b) (rang numerique deficient)",
         {
           x3b <- x3; x3b[x3b == max(x3b)] <- min(x3b) * (1 + 1e-13)
           tr <- test_reset(x3b, y); wh <- test_white(fit_x$z^2, x3b)
           .usp_nb_volumes_distincts(x3b) == 3L && !usp_volumes_constants(x3b) &&
             is.na(tr$stat) && is.na(tr$p) && endsWith(tr$non_applicable, MOTIF_B) &&
             startsWith(tr$non_applicable, "regression auxiliaire RESET") &&
             is.na(wh$stat) && is.na(wh$p) && endsWith(wh$non_applicable, MOTIF_B) &&
             startsWith(wh$non_applicable, "regression auxiliaire de White")
         })
verifier("Invariance d'unite : test_reset(c x, c y) et test_white(u2, c x) = valeurs a l'echelle 1 (rel 1e-10), c = 1e-150 et 1e150",
         {
           r1 <- test_reset(x, y); w1 <- test_white(fit_x$z^2, x)
           all(vapply(c(1e-150, 1e150), function(cc) {
             rc <- test_reset(cc * x, cc * y); wc <- test_white(fit_x$z^2, cc * x)
             isTRUE(proche(rc$stat, r1$stat, rel = 1e-10)) && isTRUE(proche(rc$p, r1$p, rel = 1e-10)) &&
               isTRUE(proche(wc$stat, w1$stat, rel = 1e-10)) && isTRUE(proche(wc$p, w1$p, rel = 1e-10))
           }, logical(1)))
         })
# Echelles extremes (constat C1 d'audit, #110) : sans normalisation
# d'echelle, F de RESET etait faux sans alerte a x et y x 1e-160 a 1e-162
# (0,241146 ; 0,241012 ; 0,2) et NaN a partir de 1e-163 (sous-depassement
# des sommes de carres dans anova()). Avec .usp_normaliser_echelle(), la
# statistique est finie et egale a celle de l'echelle 1.
verifier("Echelles extremes : test_reset(c x, c y), c = 1e-200 et 1e200, et balayage c = 1e-160, 1e-161, 1e-162 : F fini = echelle 1 (rel 1e-10), non_applicable NA",
         {
           r1 <- test_reset(x, y)
           all(vapply(c(1e-200, 1e200, 1e-160, 1e-161, 1e-162), function(cc) {
             rc <- test_reset(cc * x, cc * y)
             is.finite(rc$stat) && isTRUE(proche(rc$stat, r1$stat, rel = 1e-10)) &&
               isTRUE(proche(rc$p, r1$p, rel = 1e-10)) && identical(rc$non_applicable, NA_character_)
           }, logical(1)))
         })
verifier("Echelles extremes : test_white(c u2, x), c = 1e-200, 1e200, 1e-160, 1e-161, 1e-162 : LM fini = echelle 1 (rel 1e-10), non_applicable NA",
         {
           w1 <- test_white(fit_x$z^2, x)
           all(vapply(c(1e-200, 1e200, 1e-160, 1e-161, 1e-162), function(cc) {
             wc <- test_white(cc * fit_x$z^2, x)
             is.finite(wc$stat) && isTRUE(proche(wc$stat, w1$stat, rel = 1e-10)) &&
               isTRUE(proche(wc$p, w1$p, rel = 1e-10)) && identical(wc$non_applicable, NA_character_)
           }, logical(1)))
         })
# Garde (c) : non_applicable NA si et seulement si la statistique est finie.
# Declencheurs mesures : y identiquement nul pour RESET (F = 0/0), u2
# identiquement nul pour White (R^2 = 0/0) ; avant la garde, stat NaN et
# non_applicable NA.
verifier("Garde (c) : test_reset(x, 0) et test_white(0, x) -> stat et p NA (et non NaN), motif de statistique non finie",
         {
           tr <- test_reset(x, rep(0, 8)); wh <- test_white(rep(0, 8), x)
           identical(tr$stat, NA_real_) && identical(tr$p, NA_real_) &&
             identical(tr$non_applicable, "statistique F non finie : test non applicable") &&
             identical(wh$stat, NA_real_) && identical(wh$p, NA_real_) &&
             identical(wh$non_applicable, "statistique LM non finie : test non applicable")
         })
verifier(".stats_bootstrapables() : RESET et White NA a k = 2 hors bande, finies a k = 3",
         {
           x2 <- 100 * (1 + alt * 1e-5)
           s2 <- .stats_bootstrapables(x2, y, usp_ajuster(x2, y)$z)
           s3 <- .stats_bootstrapables(x3, y, usp_ajuster(x3, y)$z)
           all(is.na(s2[c("RESET", "White")])) && all(is.finite(s3[c("RESET", "White")]))
         })

## --- 4bis. Garde-fou R12 des regressions auxiliaires d'heteroscedasticite ----
# Scenario d'audit (C2) : T = 200, x = rep(110, 200) sauf x[2] = 110 (1 +
# 1,1e-6), etendue relative 1,1e-6 > TOL_DELTA_BORD (hors bande) ; lm() ecarte
# reg. Avant : Koenker LM = 0, p = 1 (ligne OK a p_retenue 1), BP79 LM de
# l'ordre de 1e-29. Reference : la regle R12 (jamais de p calculee sur une
# regression auxiliaire sans reg) pour Breusch-Pagan ; White est non
# applicable ici des le motif (a) de l'issue #110 (deux volumes distincts,
# k = 2), avant toute regression.
verifier("Breusch-Pagan (Koenker, 1979) : reg ecarte par lm() hors bande -> NA ; White : NA au motif (a) de #110 ; memes champs",
         {
           xa <- rep(110, 200); xa[2] <- 110 * (1 + 1.1e-6)
           u2 <- (sin(seq_len(200)) + 1.5)^2        # deterministe, non constant
           g <- u2 / mean(u2)
           ecarte <- is.na(stats::coef(stats::lm(g ~ xa))["xa"])
           bp <- test_breusch_pagan(u2, xa); bo <- test_breusch_pagan_original(u2, xa)
           wh <- test_white(u2, xa)
           !usp_volumes_constants(xa) && ecarte &&
             is.na(bp$stat) && is.na(bp$p) && is.na(bo$stat) && is.na(bo$p) &&
             is.na(wh$stat) && is.na(wh$p) &&
             identical(names(bp), names(test_breusch_pagan(u2, seq_len(200)))) &&
             identical(names(bo), names(test_breusch_pagan_original(u2, seq_len(200)))) &&
             identical(names(wh), names(test_white(u2, seq_len(200))))
         })
verifier("Garde-fou R12 via usp_tests() (T = 200, reg ecarte) : lignes Koenker, 1979 et White jamais OK a p = 1",
         {
           set.seed(59)
           xa <- rep(110, 200); xa[2] <- 110 * (1 + 1.1e-6)
           ya <- xa * 0.8 * exp(stats::rnorm(200, 0, 0.1))
           fa <- usp_ajuster(xa, ya)
           s <- .stats_bootstrapables(fa$x, fa$y, fa$z)
           pm <- stats::setNames(rep(0.5, length(s)), names(s))
           pm[is.na(s)] <- NA_real_
           mm <- stats::setNames(rep(NA_character_, length(s)), names(s))
           mm[is.na(s)] <- MOTIF_MC_OBS_NON_FINIE
           b <- list(stats_obs = as.list(s), p_mc = pm, err_mc = pm * 0 + 0.01, motif_mc = mm)
           tt <- usp_tests(fa, b, methode = "premium")
           nm <- NOMS_R13[8:10]
           L <- Filter(function(l) l$test %in% nm, tt)
           length(L) == 3L &&
             all(vapply(L, function(l) l$verdict != "OK" && !is.finite(l$p_retenue) &&
                          !is.finite(l$stat), logical(1)))
         })

## --- 5. Invariant I5 et invariant I2 ----------------------------------------------
verifier("Invariant I5 : usp_tests() rend les memes 46 lignes, dans le meme ordre, a volumes variables, quasi constants et constants",
         {
           # Objet bootstrap fictif de test_inoperance.R (aucune simulation).
           bf <- function(f) {
             s <- .stats_bootstrapables(f$x, f$y, f$z)
             pm <- stats::setNames(rep(0.5, length(s)), names(s))
             list(stats_obs = as.list(s), p_mc = pm, err_mc = pm * 0 + 0.01,
                  motif_mc = stats::setNames(rep(NA_character_, length(s)), names(s)))
           }
           nm <- lapply(list(x, x_q, rep(110, 8)), function(v) {
             f <- usp_ajuster(v, y)
             vapply(usp_tests(f, bf(f), methode = "premium"), `[[`, character(1), "test")
           })
           length(nm[[1]]) == 46L && identical(nm[[1]], nm[[2]]) && identical(nm[[1]], nm[[3]])
         })
verifier("Invariant I2 dans la bande : aucune nature 'asymptotique' sans motif",
         all(vapply(res_bande, function(r)
           sum(engine_table_tests(r)$nature_p == "asymptotique", na.rm = TRUE) == 0L, logical(1))))

fin_fichier()
