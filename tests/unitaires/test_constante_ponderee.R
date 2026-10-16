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
# delta_equiv = 15 (et non 5 avant #298) : sur J2, p_plancher = 0,0193 < alpha,
# la ligne reste un test ; a delta_equiv = 5, p_plancher >= alpha et la regle
# R14 (#298) la restitue en diagnostic, sans p retenue.
verifier("Ligne TOST : p_exacte NA dans les deux branches de marge, p retenue = p_asymptotique = p de test_tost_intercept(), loi 'modele auxiliaire pondere'",
         {
           a <- ligne(tt2, NOM_TOST)
           b <- ligne(usp_tests(f2, boot_fictif(f2), delta_equiv = 15, methode = "premium"), NOM_TOST)
           identical(a$type, "test") && identical(b$type, "test") &&
             is.na(a$p_exacte) && is.na(b$p_exacte) &&
             identical(a$p_retenue, test_tost_intercept(x2, y2, f2$pi)$p) &&
             identical(b$p_retenue, test_tost_intercept(x2, y2, f2$pi, delta_abs = 15)$p) &&
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
# p du TOST lue dans p_asymptotique (champ conserve) ; depuis #298 (regle
# R14), la ligne de J1 est un diagnostic : p retenue NA, verdict INFO.
valeurs_215 <- function(tb, t, p_mc, p_tost, v_tost) {
  c <- tb[tb$test == NOM_CST, ]; o <- tb[tb$test == NOM_TOST, ]
  ok <- round(c$statistique, 4) == t && abs(c$p_monte_carlo - p_mc) <= 0.002 + 1e-12 &&
    round(o$p_asymptotique, 4) == p_tost && identical(o$verdict, v_tost) &&
    (if (identical(v_tost, "INFO")) is.na(o$p_retenue) && identical(o$type, "diagnostic")
     else identical(o$p_retenue, o$p_asymptotique))
  if (isTRUE(ok)) TRUE else sprintf("t = %.4f, p_mc = %.4f, TOST = %.4f (%s)", c$statistique,
                                    c$p_monte_carlo, o$p_asymptotique, o$verdict)
}
verifier("Valeurs de #215, J1 : t = 0,0667 ; p_mc = 0,964 ; TOST 0,4651 (p asymptotique), diagnostic INFO depuis #298 (ECHEC avant)",
         valeurs_215(tb1, 0.0667, 0.964, 0.4651, "INFO"))
# J2 (delta estime interieur) : depuis #240, la p Monte-Carlo est
# conditionnelle au regime interieur de delta estime (variante V3b) ; la
# valeur de #215, 0,692, etait la p marginale (V1). 0,670 = p_V3b:Intercept
# du jeu observe J2 dans la mesure de #229
# (docs/tableaux/20261010-issue229-p-conditionnelle-regime-brut.tsv) ; t et
# le TOST ne dependent pas du bootstrap.
verifier("Valeurs de #215, J2 : t = -0,3745 ; p_mc = 0,670 (conditionnelle au regime, #240 ; 0,692 avant) ; TOST 0,1313 ALERTE",
         valeurs_215(tb2, -0.3745, 0.670, 0.1313, "ALERTE"))

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
# Depuis #237, la constante et le TOST lisent .usp_lm_pondere() (QR) et
# test_lm_complet() summary() : la ligne x est retiree des deux.
verifier("Renvoi, x ecarte par lm() (R12, injection de summary() et de .usp_lm_pondere() sans la ligne x) : ni repere ni detail",
         {
           e <- environment(run_engine)
           sans_x <- function(cf) cf[rownames(cf) != "x", , drop = FALSE]
           pond_orig <- get(".usp_lm_pondere", envir = e, inherits = FALSE)
           assign("summary", function(object, ...) {
             s <- base::summary(object, ...)
             if (inherits(object, "lm")) s$coefficients <- sans_x(s$coefficients)
             s
           }, envir = e)
           assign(".usp_lm_pondere", function(...) {
             m <- pond_orig(...); if (!is.null(m)) m$coefficients <- sans_x(m$coefficients); m
           }, envir = e)
           tt <- tryCatch(usp_tests(f1, boot_fictif(f1), methode = "premium"),
                          error = function(e) e,
                          finally = {
                            rm("summary", envir = e)
                            assign(".usp_lm_pondere", pond_orig, envir = e)
                          })
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

# Regression ponderee partagee (#222, point 1) : un seul appel de
# .usp_lm_pondere() par usp_tests() (deux avant #222), aucun a pertes
# constantes ; resultats des deux fonctions identiques avec m passe ou
# calcule par defaut.
verifier("Regression ponderee partagee (#222) : usp_tests() appelle .usp_lm_pondere() une fois (J1, J2), zero a pertes constantes ; test_intercept() et test_tost_intercept() avec m = .usp_lm_pondere() identiques a l'appel sans m",
         {
           e <- environment(run_engine)
           pond_orig <- get(".usp_lm_pondere", envir = e, inherits = FALSE)
           n <- 0L
           assign(".usp_lm_pondere", function(...) { n <<- n + 1L; pond_orig(...) }, envir = e)
           compte <- function(f) { b <- boot_fictif(f); n <<- 0L; usp_tests(f, b, methode = "premium"); n }
           fc <- f2; fc$y <- rep(70, 8)
           r <- tryCatch(c(compte(f1), compte(f2), compte(fc)), error = function(err) err,
                         finally = assign(".usp_lm_pondere", pond_orig, envir = e))
           m2 <- .usp_lm_pondere(x2, y2, f2$pi)
           !inherits(r, "error") && identical(r, c(1L, 1L, 0L)) &&
             identical(test_intercept(x2, y2, f2$pi, m = m2), test_intercept(x2, y2, f2$pi)) &&
             identical(test_tost_intercept(x2, y2, f2$pi, m = m2), test_tost_intercept(x2, y2, f2$pi)) &&
             identical(test_tost_intercept(x2, y2, f2$pi, delta_abs = 5, m = m2),
                       test_tost_intercept(x2, y2, f2$pi, delta_abs = 5))
         })

## --- 5. Seuil de rejet de la constante (#314) --------------------------------
# Specification fb-pente-et-constante.md, section 4, decision Q-D1-Fb-6 :
# c_alpha = t(1 - alpha/2, T - 2) x se(a), se(a) du modele auxiliaire pondere,
# en % de la moyenne de y arrondi a l'unite. Critere (a) : recalcul
# independant par stats::lm(y ~ x, weights = usp_poids_gls(x, fit$pi)) sur
# J1 (tests/donnees/donnees_ln.csv) et J2 (donnees_ln_interieur.csv) ;
# critere (b) : phrase absente sur les branches non applicables et a t non
# fini.
TXT_SEUIL_CST <- "Seuil de rejet de la constante au seuil alpha"
TXT_NON_REJET <- "Le NON-rejet ne prouve pas la proportionnalite : voir le test d'equivalence ci-dessous."
phrase_seuil <- function(alpha, pct) sprintf(paste(
  "Seuil de rejet de la constante au seuil alpha = %g : |a| >= t(1-alpha/2, T-2)",
  "x se(a) = %s %% de la moyenne de y (loi de Student du modele auxiliaire",
  "pondere, approchee ; la p retenue, de Monte-Carlo, n'a pas exactement ce",
  "seuil)."), alpha, pct)
lire_jeu <- function(f) utils::read.csv(file.path(RACINE, "tests", "donnees", f))
seuil_lm <- function(d, alpha) {
  f <- usp_ajuster(d$xt, d$yt)
  m <- stats::lm(yt ~ xt, data = d, weights = usp_poids_gls(d$xt, f$pi))
  100 * stats::qt(1 - alpha / 2, nrow(d) - 2) * summary(m)$coefficients[1, 2] / mean(d$yt)
}
seuil_ok <- function(fichier, alpha, attendu) {
  d <- lire_jeu(fichier); f <- usp_ajuster(d$xt, d$yt)
  det <- ligne(usp_tests(f, boot_fictif(f), alpha = alpha, methode = "premium"), NOM_CST)$detail
  c_lm <- seuil_lm(d, alpha)
  ok <- identical(sprintf("%.0f", c_lm), attendu) &&
    startsWith(det, paste(TXT_NON_REJET, phrase_seuil(alpha, attendu)))
  if (isTRUE(ok)) TRUE else sprintf("seuil lm = %.4f ; detail = %s", c_lm, det)
}
verifier("Seuil de rejet de la constante (#314, critere (a)), alpha = 0,10 : 123 % sur J1, 12 % sur J2, recalcule par lm(y ~ x, weights = usp_poids_gls(x, fit$pi)) ; phrase juste apres celle du TOST",
         isTRUE(seuil_ok("donnees_ln.csv", 0.10, "123")) &&
           isTRUE(seuil_ok("donnees_ln_interieur.csv", 0.10, "12")))
verifier("Seuil de rejet de la constante (#314), alpha = 0,05 : 155 % sur J1, 15 % sur J2",
         isTRUE(seuil_ok("donnees_ln.csv", 0.05, "155")) &&
           isTRUE(seuil_ok("donnees_ln_interieur.csv", 0.05, "15")))
verifier("Seuil de rejet de la constante (#314) : sur J1, phrase avant le renvoi croise de .usp_poser_renvois() ; sur J2, derniere phrase du detail",
         {
           d1 <- ligne(tests_de(x1, y1), NOM_CST)$detail
           d2 <- ligne(tt2, NOM_CST)$detail
           p1 <- regexpr(TXT_SEUIL_CST, d1, fixed = TRUE); r1p <- regexpr(TXT_RENVOI_CST, d1, fixed = TRUE)
           p1 > 0 && r1p > p1 && endsWith(d2, "n'a pas exactement ce seuil).")
         })
verifier("Seuil de rejet de la constante (#314, critere (b)) : absent a volumes constants, a pertes constantes, a t non fini (pi injecte non fini) et a x ecarte (R12)",
         {
           sans <- function(tt) !grepl(TXT_SEUIL_CST, ligne(tt, NOM_CST)$detail, fixed = TRUE) &&
             identical(ligne(tt, NOM_CST)$type, "non applicable")
           f_pc <- usp_ajuster(x1, rep(70, 8))
           f_na <- f1; f_na$pi[1] <- NA_real_
           e <- environment(run_engine)
           pond_orig <- get(".usp_lm_pondere", envir = e, inherits = FALSE)
           assign(".usp_lm_pondere", function(...) {
             m <- pond_orig(...)
             if (!is.null(m)) m$coefficients <- m$coefficients[rownames(m$coefficients) != "x", , drop = FALSE]
             m
           }, envir = e)
           t_r12 <- tryCatch(usp_tests(f1, boot_fictif(f1), methode = "premium"),
                             error = function(err) err,
                             finally = assign(".usp_lm_pondere", pond_orig, envir = e))
           !inherits(t_r12, "error") &&
             sans(tests_de(rep(100, 8), y1)) &&
             sans(usp_tests(f_pc, boot_fictif(f_pc), methode = "premium")) &&
             sans(usp_tests(f_na, boot_fictif(f1), methode = "premium")) &&
             sans(t_r12)
         })
# Reserve (a) d'actuary : sans p Monte-Carlo de la constante, add() bascule
# la ligne en diagnostic (regle R3, #181) et aucun seuil de rejet n'est dit.
verifier("Seuil de rejet de la constante (#314) : absent quand la p Monte-Carlo de la constante n'est pas finie (diagnostic d'add(), motifs MOTIF_MC_AUCUNE_REPLIC et MOTIF_MC_DISPERSION_NULLE ; J2), t fini",
         all(vapply(c(MOTIF_MC_AUCUNE_REPLIC, MOTIF_MC_DISPERSION_NULLE), function(mo) {
           l <- ligne(usp_tests(f2, boot_fictif(f2, motif = c(Intercept = mo)), methode = "premium"),
                      NOM_CST)
           identical(l$type, "diagnostic") && is.finite(l$stat) &&
             !grepl(TXT_SEUIL_CST, l$detail, fixed = TRUE) && grepl(TXT_NON_REJET, l$detail, fixed = TRUE)
         }, logical(1))))

fin_fichier()
