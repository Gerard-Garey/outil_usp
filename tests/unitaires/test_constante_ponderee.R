###############################################################################
#  tests/unitaires/test_constante_ponderee.R  --  CONSTANTE ET TOST SOUS LE
#                         MODELE AUXILIAIRE PONDERE ; REPERE DE RENVOI (#215)
#
#  Specification d'actuary-approfondi du 06/10/2026 et decisions du mainteneur
#  du 07/10/2026 (P1 a P5, option C) :
#    - poids GLS a delta estime, w_t = 1 / (x_t^2 expm1(1 / pi_t)),
#      usp_poids_gls() ; identite avec 1 / [x_t (delta x_t + (1 - delta) xbar)] ;
#    - t de la constante : a poids constants, celui de lm(y ~ x) ; invariant
#      par y -> c y et x -> c x ; a delta = 1, t de la pente de
#      lm(r ~ I(1 / x)) ; garde des poids invalides ;
#    - valeurs de l'issue (B = 999, graine 20260831) sur J1 et J2 ;
#    - colonne renvoi d'engine_table_tests() (usp_renvois()) coherente avec
#      le detail des lignes constante et Spearman ratio / volume.
#  References : stats::lm (MCO, MCP), algebre des poids, valeurs de l'issue.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_constante_ponderee.R")

# J1 : donnees de test (delta estime = 1) ; J2 : xi, yi de
# test_controles_numeriques.R (delta estime interieur).
x1 <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y1 <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
x2 <- c(50, 80, 120, 200, 300, 150, 90, 60)
y2 <- c(29.92, 56.9, 101.25, 123.06, 207.23, 105.91, 68.59, 40.05)
f1 <- usp_ajuster(x1, y1); f2 <- usp_ajuster(x2, y2)

NOM_CST <- "Nullite de la constante (proportionnalite stricte)"
NOM_TOST <- "Equivalence de la constante a zero (TOST)"
NOM_SV <- "Independance ratio S/P vs volume"
# Debuts des deux textes de renvoi (libelle d'actuary, #215).
TXT_RENVOI_CST <- "pi_t constant (delta estime a 1) : sous y_t = a + b x_t, E[r_t] = b + a / x_t"
TXT_RENVOI_SV <- "pi_t constant (delta estime a 1) : une constante a non nulle dans"

boot_fictif <- function(f, p = 0.5, motif = NULL) {
  s <- .stats_bootstrapables(f$x, f$y, f$z, f$pi)
  pm <- stats::setNames(rep(p, length(s)), names(s))
  mm <- stats::setNames(rep(NA_character_, length(s)), names(s))
  if (!is.null(motif)) { pm[names(motif)] <- NA_real_; mm[names(motif)] <- motif }
  list(stats_obs = as.list(s), p_mc = pm, err_mc = pm * 0 + 0.01, motif_mc = mm)
}
ligne <- function(tt, nom) Filter(function(l) identical(l$test, nom), tt)[[1]]
t_mco <- function(x, y) summary(stats::lm(y ~ x))$coefficients[1, ]

## --- 1. Poids et statistique ------------------------------------------------
verifier("usp_poids_gls() : identite avec pi estime, w proportionnel a 1 / [x (delta x + (1 - delta) xbar)] (J1, delta = 1 ; J2, delta interieur)",
         all(vapply(list(f1, f2), function(f) {
           w <- usp_poids_gls(f$x, f$pi)
           ref <- 1 / (f$x * (f$delta * f$x + (1 - f$delta) * mean(f$x)))
           isTRUE(proche(w / w[1], ref / ref[1], rel = 1e-10)) && isTRUE(proche(max(w), 1, rel = 0))
         }, logical(1))) && f1$delta == 1 && f2$delta > 0.1 && f2$delta < 0.9)
verifier("usp_poids_gls() : formule brute 1 / (x^2 expm1(1 / pi)) a un facteur pres (J2)",
         {
           w <- usp_poids_gls(x2, f2$pi); b <- 1 / (x2^2 * expm1(1 / f2$pi))
           isTRUE(proche(w, b / max(b), rel = 1e-12))
         })
verifier("test_intercept() : a poids constants (pi_t = 1 / log1p(c / x_t^2)), t, p et a de lm(y ~ x) (J1, J2)",
         all(vapply(list(list(x1, y1), list(x2, y2)), function(d) {
           pc <- 1 / log1p(0.3 * mean(d[[1]])^2 / d[[1]]^2)
           ti <- test_intercept(d[[1]], d[[2]], pc); m <- t_mco(d[[1]], d[[2]])
           isTRUE(proche(usp_poids_gls(d[[1]], pc), rep(1, 8), rel = 1e-12)) &&
             isTRUE(proche(c(ti$stat, ti$p, ti$a), m[c(3, 4, 1)], rel = 1e-9))
         }, logical(1))))
verifier("test_intercept() : t invariant par y -> c y et par x -> c x (c = 1e-6, 1e3 ; pi fixe), a homogene a y",
         {
           t0 <- test_intercept(x2, y2, f2$pi)
           all(vapply(c(1e-6, 1e3), function(cc) {
             ty <- test_intercept(x2, cc * y2, f2$pi); tx <- test_intercept(cc * x2, y2, f2$pi)
             isTRUE(proche(ty$stat, t0$stat, rel = 1e-9)) && isTRUE(proche(tx$stat, t0$stat, rel = 1e-9)) &&
               isTRUE(proche(ty$a, cc * t0$a, rel = 1e-9))
           }, logical(1)))
         })
verifier("Invariance par changement d'unite de bout en bout : pi estime et t de la constante sur (c x, c y), c = 1e3",
         {
           fc <- usp_ajuster(1e3 * x2, 1e3 * y2)
           isTRUE(proche(fc$pi, f2$pi, rel = 1e-6)) &&
             isTRUE(proche(test_intercept(fc$x, fc$y, fc$pi)$stat, test_intercept(x2, y2, f2$pi)$stat, rel = 1e-6))
         })
verifier("A delta = 1 (J1) : t pondere de la constante = t de la pente de lm(r ~ I(1/x)), r = y / x",
         {
           r <- y1 / x1
           tr <- summary(stats::lm(r ~ I(1 / x1)))$coefficients[2, 3]
           isTRUE(proche(test_intercept(x1, y1, f1$pi)$stat, tr, rel = 1e-9))
         })
verifier("TOST : a et se du modele pondere = ceux de test_intercept() ; p = max(p_bas, p_haut) a t(T-2)",
         {
           to <- test_tost_intercept(x2, y2, f2$pi)
           m <- summary(stats::lm(y2 ~ x2, weights = usp_poids_gls(x2, f2$pi)))$coefficients
           D <- 0.1 * mean(y2)
           isTRUE(proche(to$a, m[1, 1], rel = 1e-12)) && isTRUE(proche(to$se, m[1, 2], rel = 1e-12)) &&
             isTRUE(proche(to$a, test_intercept(x2, y2, f2$pi)$a, rel = 0)) &&
             isTRUE(proche(to$p, max(stats::pt((m[1, 1] + D) / m[1, 2], 6, lower.tail = FALSE),
                                    stats::pt((m[1, 1] - D) / m[1, 2], 6)), rel = 1e-12))
         })
verifier("Garde des poids (#215) : pi non fini, nul, negatif ou de mauvaise longueur -> usp_poids_gls() NULL, constante stat NA, TOST 'statistique non definie' ; volumes et pertes constants prioritaires",
         {
           mauvais <- list(replace(f2$pi, 1, NA), replace(f2$pi, 1, Inf), replace(f2$pi, 1, 0),
                           replace(f2$pi, 1, -1), f2$pi[-1])
           ok <- vapply(mauvais, function(p) {
             ti <- test_intercept(x2, y2, p); to <- test_tost_intercept(x2, y2, p)
             is.null(usp_poids_gls(x2, p)) && identical(ti$stat, NA_real_) && identical(ti$p, NA_real_) &&
               identical(ti$a, NA_real_) && identical(ti$x_ecarte, FALSE) &&
               identical(to$non_applicable, "statistique non definie") && identical(to$p, NA_real_)
           }, logical(1))
           all(ok) &&
             identical(test_tost_intercept(rep(100, 8), y2, NA)$non_applicable, "volumes constants") &&
             identical(test_tost_intercept(x2, rep(70, 8), NA)$non_applicable, "pertes constantes") &&
             identical(test_intercept(x2, rep(70, 8), NA)$pertes_constantes, TRUE) &&
             identical(names(test_intercept(x2, y2, NA)), names(test_intercept(x2, y2, f2$pi))) &&
             identical(names(test_tost_intercept(x2, y2, NA)), names(test_tost_intercept(x2, y2, f2$pi)))
         })
verifier("Catalogue Monte-Carlo : entree Intercept = t pondere de test_intercept() au pi du contexte",
         isTRUE(proche(USP_CATALOGUE_MC$Intercept$calc(.usp_contexte_mc(x2, y2, f2$z, f2$pi)),
                       test_intercept(x2, y2, f2$pi)$stat, rel = 0)) &&
           identical(USP_CATALOGUE_MC$Intercept$calc(.usp_contexte_mc(x2, y2, f2$z, rep(NA_real_, 8))),
                     NA_real_))

## --- 2. Lignes de usp_tests() -------------------------------------------------
tt2 <- usp_tests(f2, boot_fictif(f2), methode = "premium")
verifier("Ligne constante : stat = t pondere, estim = a pondere, p_asymptotique = p de Student ponderee non retenue, p Monte-Carlo retenue, loi 'modele auxiliaire pondere'",
         {
           l <- ligne(tt2, NOM_CST); ti <- test_intercept(x2, y2, f2$pi)
           identical(l$stat, ti$stat) && identical(l$estim, unname(ti$a)) &&
             identical(l$p_asymptotique, ti$p) && is.na(l$p_exacte) && identical(l$p_retenue, 0.5) &&
             identical(l$nature_p, "Monte-Carlo (bootstrap parametrique)") &&
             startsWith(l$loi, "t(6) sous le modele auxiliaire pondere (poids estimes") &&
             grepl("non retenue", l$loi, fixed = TRUE)
         })
verifier("Constante sans p Monte-Carlo : diagnostic, libelle 'p de Student sous le modele auxiliaire pondere non retenue'",
         {
           l <- ligne(usp_tests(f2, boot_fictif(f2, motif = c(Intercept = MOTIF_MC_AUCUNE_REPLIC)),
                                methode = "premium"), NOM_CST)
           identical(l$type, "diagnostic") && is.na(l$p_retenue) &&
             grepl("p de Student sous le modele auxiliaire pondere non retenue", l$detail, fixed = TRUE)
         })
verifier("Ligne TOST : p_exacte NA dans les deux branches de marge, p retenue = p_asymptotique = p de test_tost_intercept(), loi 'modele auxiliaire pondere'",
         {
           a <- ligne(tt2, NOM_TOST)
           b <- ligne(usp_tests(f2, boot_fictif(f2), delta_equiv = 5, methode = "premium"), NOM_TOST)
           is.na(a$p_exacte) && is.na(b$p_exacte) &&
             identical(a$p_retenue, test_tost_intercept(x2, y2, f2$pi)$p) &&
             identical(b$p_retenue, test_tost_intercept(x2, y2, f2$pi, delta_abs = 5)$p) &&
             identical(a$p_asymptotique, a$p_retenue) && identical(b$p_asymptotique, b$p_retenue) &&
             grepl("modele auxiliaire pondere", a$loi, fixed = TRUE) &&
             grepl("marge estimee", a$loi, fixed = TRUE) && grepl("marge fixee a priori", b$loi, fixed = TRUE)
         })

## --- 3. Valeurs de l'issue (B = 999, graine 20260831) ------------------------
# Critere 3 de #215. p_mc a un pas de comptage bilateral (2 / (B + 1)) pres.
run_jeu <- function(x, y) run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                                     nature_donnees = "brutes", B = 999, seed = 20260831)
r1 <- run_jeu(x1, y1); r2 <- run_jeu(x2, y2)
tb1 <- engine_table_tests(r1); tb2 <- engine_table_tests(r2)
valeurs_215 <- function(tb, t, p_mc, p_tost, v_tost) {
  c <- tb[tb$test == NOM_CST, ]; o <- tb[tb$test == NOM_TOST, ]
  ok <- round(c$statistique, 4) == t && abs(c$p_monte_carlo - p_mc) <= 0.002 + 1e-12 &&
    round(o$p_retenue, 4) == p_tost && identical(o$verdict, v_tost)
  if (isTRUE(ok)) TRUE else sprintf("t = %.4f, p_mc = %.4f, TOST = %.4f (%s)", c$statistique,
                                    c$p_monte_carlo, o$p_retenue, o$verdict)
}
verifier("Valeurs de #215, J1 : t = 0,0667 ; p_mc = 0,964 ; TOST 0,4651 ECHEC",
         valeurs_215(tb1, 0.0667, 0.964, 0.4651, "ECHEC"))
verifier("Valeurs de #215, J2 : t = -0,3745 ; p_mc = 0,692 ; TOST 0,1313 ALERTE",
         valeurs_215(tb2, -0.3745, 0.692, 0.1313, "ALERTE"))

## --- 4. Repere de renvoi : coherence colonne <-> detail ---------------------
# Coherence (ADR 0003, annotation du 07/10/2026, point 4) : repere non NA sur
# la constante si et seulement si son detail porte le renvoi ; le detail de
# Spearman ratio / volume le porte si et seulement si celui de la constante
# le porte ; aucune autre ligne n'a de repere. regime = TRUE / FALSE : le
# renvoi est attendu / exclu.
coherence <- function(tt, regime, renvoi = usp_renvois(tt)) {
  noms <- vapply(tt, function(l) l$test, "")
  i_cst <- which(noms == NOM_CST); i_sv <- which(noms == NOM_SV)
  if (length(i_cst) != 1L || length(i_sv) != 1L) return("lignes constante / Spearman absentes")
  d_cst <- grepl(TXT_RENVOI_CST, tt[[i_cst]]$detail, fixed = TRUE)
  d_sv <- grepl(TXT_RENVOI_SV, tt[[i_sv]]$detail, fixed = TRUE)
  r_cst <- !is.na(renvoi[i_cst])
  pb <- c(if (r_cst != d_cst) sprintf("repere %s, detail constante %s", r_cst, d_cst),
          if (d_sv != d_cst) sprintf("detail Spearman %s, detail constante %s", d_sv, d_cst),
          if (any(!is.na(renvoi[-i_cst]))) "repere hors de la constante",
          if (r_cst && !identical(renvoi[i_cst], NOM_SV)) "valeur du repere",
          if (r_cst != regime) sprintf("regime attendu %s, obtenu %s", regime, r_cst))
  if (length(pb)) paste(pb, collapse = " ; ") else TRUE
}
tests_de <- function(x, y, ...) { f <- usp_ajuster(x, y); usp_tests(f, boot_fictif(f), methode = "premium", ...) }
verifier("Renvoi, pi_t constant (J1, delta = 1, T = 8, sans ex aequo) : repere et deux details",
         coherence(tests_de(x1, y1), TRUE))
verifier("Renvoi, pi_t variable (J2) : ni repere ni detail",
         coherence(tt2, FALSE))
verifier("Renvoi, run_engine() : colonne renvoi de engine_table_tests() avant fonction, inoperant ; J1 repere, J2 aucun",
         identical(tail(names(tb1), 3L), c("renvoi", "fonction", "inoperant")) &&
           is.character(tb1$renvoi) && identical(tb1$renvoi, usp_renvois(r1$tests)) &&
           isTRUE(coherence(r1$tests, TRUE)) && isTRUE(coherence(r2$tests, FALSE)) &&
           all(is.na(tb2$renvoi)))
verifier("Renvoi, ex aequo dans x (pi_t constant, p exacte de Spearman non attribuee) : ni repere ni detail",
         {
           x3 <- x1; x3[2] <- x1[1]; y3 <- y1 * x3 / x1
           f3 <- usp_ajuster(x3, y3)
           isTRUE(usp_regime(f3$delta, f3$x)$pi_constant) &&
             isTRUE(coherence(usp_tests(f3, boot_fictif(f3), methode = "premium"), FALSE))
         })
verifier("Renvoi, T = 10 (pi_t constant, Edgeworth : p exacte non attribuee) : ni repere ni detail",
         {
           x10 <- c(x1, 140.5, 136.1); y10 <- c(y1, 96.3, 101.8)
           f10 <- usp_ajuster(x10, y10)
           f10$delta == 1 && isTRUE(coherence(usp_tests(f10, boot_fictif(f10), methode = "premium"), FALSE))
         })
verifier("Renvoi, volumes constants (R13) : ni repere ni detail",
         coherence(tests_de(rep(100, 8), y1), FALSE))
verifier("Renvoi, pertes constantes (#189, pi_t constant, Spearman calcule) : ni repere ni detail",
         {
           f <- usp_ajuster(x1, rep(70, 8)); tt <- usp_tests(f, boot_fictif(f), methode = "premium")
           isTRUE(usp_regime(f$delta, f$x)$pi_constant) &&
             identical(ligne(tt, NOM_SV)$type, "test") && is.finite(ligne(tt, NOM_SV)$p_exacte) &&
             isTRUE(coherence(tt, FALSE))
         })
verifier("Renvoi, t de la constante non fini (poids invalides : pi injecte non fini sur J1) : ni repere ni detail",
         {
           f <- f1; f$pi[1] <- NA_real_
           tt <- usp_tests(f, boot_fictif(f1), methode = "premium")
           identical(ligne(tt, NOM_CST)$type, "non applicable") && isTRUE(coherence(tt, FALSE))
         })
verifier("Renvoi, x ecarte par lm() (R12, injection de summary() sans la ligne x) : ni repere ni detail",
         {
           e <- environment(run_engine)
           assign("summary", function(object, ...) {
             s <- base::summary(object, ...)
             if (inherits(object, "lm"))
               s$coefficients <- s$coefficients[rownames(s$coefficients) != "x", , drop = FALSE]
             s
           }, envir = e)
           tt <- tryCatch(usp_tests(f1, boot_fictif(f1), methode = "premium"), error = function(e) e)
           rm("summary", envir = e)
           !inherits(tt, "error") && identical(ligne(tt, NOM_CST)$type, "non applicable") &&
             isTRUE(coherence(tt, FALSE))
         })
verifier("Renvoi, reserve2 : colonne renvoi presente, toute NA",
         {
           tri <- local({
             d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
             m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
           })
           r <- run_engine(methode = "reserve2", triangle = tri, segment = 1, annexe = "II", B = 99)
           tb <- engine_table_tests(r)
           isTRUE(r$ok) && "renvoi" %in% names(tb) && all(is.na(tb$renvoi)) &&
             identical(tail(names(tb), 2L), c("fonction", "inoperant"))
         })
verifier("usp_renvois() : ne lit pas le detail (detail efface : meme repere) ; type et p_exacte de Spearman decident",
         {
           tt <- tests_de(x1, y1)
           sans <- lapply(tt, function(l) { l$detail <- ""; l })
           i <- which(vapply(tt, function(l) l$test, "") == NOM_SV)
           pna <- tt; pna[[i]]$p_exacte <- NA_real_
           dia <- tt; dia[[i]]$type <- "diagnostic"
           r0 <- usp_renvois(tt)
           identical(usp_renvois(sans), r0) && sum(!is.na(r0)) == 1L &&
             all(is.na(usp_renvois(pna))) && all(is.na(usp_renvois(dia)))
         })
# Regles R1 et R3 sur la ligne Spearman ratio / volume : la ligne sort en
# diagnostic (test inoperant, ou motif Monte-Carlo de degenerescence) avec sa
# p exacte. Depuis l'option (ii) d'actuary (decision du mainteneur du
# 07/10/2026), le renvoi est pose apres coup par .usp_poser_renvois() selon
# usp_renvois() : ni repere ni renvoi dans les detail (avant : divergence,
# detail porteur et colonne NA).
verifier("Renvoi, R1 sur Spearman (T = 5, delta = 1, alpha = 0,01 < p_min = 2/5! = 0,0167) : ni repere ni detail",
         {
           f5 <- usp_ajuster(x1[2:6], y1[2:6])
           tt <- usp_tests(f5, boot_fictif(f5), alpha = 0.01, methode = "premium")
           l <- ligne(tt, NOM_SV)
           f5$delta == 1 && isTRUE(l$inoperant) && is.finite(l$p_exacte) && isTRUE(coherence(tt, FALSE))
         })
verifier("Renvoi, R3 sur Spearman (motif de degenerescence injecte sur SpearVol, J1) : ni repere ni detail",
         {
           tt <- usp_tests(f1, boot_fictif(f1, motif = c(SpearVol = MOTIF_MC_DISPERSION_NULLE)),
                           methode = "premium")
           l <- ligne(tt, NOM_SV)
           identical(l$type, "diagnostic") && is.finite(l$p_exacte) && isTRUE(coherence(tt, FALSE))
         })
verifier("Renvoi pose en fin de detail, apres les mentions d'add() (J1) : la constante et Spearman ratio / volume se terminent par les textes (a) et (b)",
         {
           tt <- tests_de(x1, y1)
           endsWith(ligne(tt, NOM_CST)$detail, USP_TXT_RENVOI_CST) &&
             endsWith(ligne(tt, NOM_SV)$detail, USP_TXT_RENVOI_SV) &&
             startsWith(USP_TXT_RENVOI_CST, TXT_RENVOI_CST) && startsWith(USP_TXT_RENVOI_SV, TXT_RENVOI_SV)
         })
verifier(".usp_poser_renvois() idempotent (ADR 0003, point de vigilance (c)) : une seconde application sur les lignes finales de usp_tests() ne change rien (J1)",
         {
           tt <- tests_de(x1, y1)
           identical(.usp_poser_renvois(tt), tt)
         })
# Constat 3 d'audit (#215) : motif "statistique non definie" de la constante
# (t non fini hors R13, #189, R12), texte commun avec le TOST, qui nomme les
# poids invalides.
TXT_STAT_NON_DEF215 <- paste("statistique t non definie (poids de la regression ponderee non",
                             "valides, ou constante ou erreur-type de la regression de y sur x",
                             "non calculable) : test non applicable")
verifier("Constat 3 : pi injecte non fini (f$pi[1] <- NA, J1) -> constante et TOST non applicables, INFO, detail = motif 'statistique non definie' (poids invalides)",
         {
           f <- f1; f$pi[1] <- NA_real_
           tt <- usp_tests(f, boot_fictif(f1), methode = "premium")
           lc <- ligne(tt, NOM_CST); lt <- ligne(tt, NOM_TOST)
           identical(lc$type, "non applicable") && identical(lc$verdict, "INFO") &&
             identical(lc$detail, TXT_STAT_NON_DEF215) &&
             identical(lt$type, "non applicable") && identical(lt$verdict, "INFO") &&
             identical(lt$detail, TXT_STAT_NON_DEF215)
         })

fin_fichier()
