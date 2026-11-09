###############################################################################
#  tests/unitaires/test_ordonnee_wls.R  --  ORDONNEE A L'ORIGINE DE M1 PAR
#                         lm.wfit() CONTRE SON CALCUL PAR lm() (#513)
#
#  Depuis #513, mw_test_ordonnee_origine() calcule la table des coefficients
#  de la regression ponderee C1 = a + b C0 (poids 1/C0) par
#  .mw_coefs_origine() (stats::lm.wfit() et transcription des lignes de
#  summary.lm() qui la forment) au lieu de summary(lm(C1 ~ C0, weights =
#  1 / C0)) par .mw_summary_lm() (#203). Test differentiel : l'ancienne
#  implementation est recopiee ci-dessous comme oracle (corps de
#  mw_test_ordonnee_origine() et de .mw_summary_lm() d'avant #513) et
#  confrontee a la nouvelle :
#    - table des coefficients, colonne par colonne de regression : cas
#      nominaux tires sous graine, ajustement parfait (avertissement
#      "essentially perfect fit" de summary.lm()), C0 constant (rang 1), NA
#      et NaN (na.omit() de lm()), poids invalides, poids nuls (C0 infini),
#      deux lignes restantes (ddl nul), echelles extremes ;
#    - resultat complet de mw_test_ordonnee_origine() sur des triangles
#      varies : triangle_mw.csv, triangles tires sous graine (ex aequo,
#      colonnes proportionnelles, echelles de 1e-8 a 1e46), triangles
#      simules par mw_simuler_triangle() comme dans le bootstrap, ensembles
#      figes imposes vides (C0 constant soumis a la regression).
#  Critere : identical() (valeurs au bit pres, noms et attributs) quand
#  l'oracle rend une table de deux lignes ; moins de deux lignes des deux
#  cotes sinon ; une erreur de l'oracle est une erreur de la nouvelle
#  implementation ; aucun avertissement R de la nouvelle implementation.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_ordonnee_wls.R")

## --- Oracle : implementation d'avant #513 -----------------------------------
summary_lm_avant <- function(m) {
  force(m)
  msg <- "essentially perfect fit: summary may be unreliable"
  withCallingHandlers(summary(m), warning = function(w) {
    appel <- conditionCall(w)
    if (is.call(appel) && identical(appel[[1]], as.name("summary.lm")) &&
        conditionMessage(w) %in% c(msg, gettext(msg, domain = "R-stats")))
      invokeRestart("muffleWarning")
  })
}
coefs_avant <- function(C0, C1)
  summary_lm_avant(stats::lm(C1 ~ C0, weights = 1 / C0))$coefficients

origine_avant <- function(aj, j_degeneres = NULL, j_non_identifiables = NULL) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  blocs <- list()
  ex <- .mw_exclues_vide()
  figes <- .mw_ensembles_figes(aj, j_degeneres, integer(0), j_non_identifiables)
  jd <- figes$degeneres
  jni <- figes$origine_non_identifiables
  ni <- .mw_table_non_identifiables(jni, I, J, jd, 3L)
  na_stat <- function() .mw_stat_non_definie_ni(ex, ni)
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 3) next
    if (j %in% jd) { ex <- .mw_exclure(ex, j, length(idx)); next }
    ex$eligibles <- ex$eligibles + 1L
    if (j %in% jni) next
    if (.mw_colonne_degeneree(aj, j)) return(na_stat())
    C0 <- tri[idx + 1, j + 1]; C1 <- tri[idx + 1, j + 2]
    m <- try(summary_lm_avant(stats::lm(C1 ~ C0, weights = 1 / C0)), silent = TRUE)
    if (inherits(m, "try-error") || nrow(m$coefficients) < 2) return(na_stat())
    blocs[[length(blocs) + 1L]] <- list(
      j = j, n = length(idx), a = m$coefficients[1, 1], se_a = m$coefficients[1, 2],
      t = m$coefficients[1, 3], p = m$coefficients[1, 4], b = m$coefficients[2, 1],
      f_cl = aj$f[j + 1])
  }
  det <- .mw_empiler(blocs)
  if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det,
                              exclues = ex$colonnes, eligibles = ex$eligibles,
                              non_identifiables = ni))
  fc <- .fisher_combine(det$p)
  list(stat = fc$stat, p = fc$p, K = fc$K, detail = det,
       t_max = det$t[which.max(abs(det$t))], j_max = det$j[which.max(abs(det$t))],
       exclues = ex$colonnes, eligibles = ex$eligibles, non_identifiables = ni)
}

## --- Outils ------------------------------------------------------------------
# Evalue expr en collectant ses avertissements (rendus dans $w) et son erreur
# eventuelle ($erreur).
avec_avert <- function(expr) {
  w <- character(0)
  v <- tryCatch(withCallingHandlers(expr, warning = function(x) {
    w <<- c(w, conditionMessage(x)); invokeRestart("muffleWarning") }),
    error = function(e) structure(conditionMessage(e), class = "erreur513"))
  list(v = v, w = w, erreur = inherits(v, "erreur513"))
}
# Issue de la comparaison d'une colonne de regression : "identique",
# "rang<2", "erreur" (memes issues des deux cotes) ou "ECART : ...".
comparer_coefs <- function(C0, C1) {
  a <- avec_avert(coefs_avant(C0, C1))
  n <- avec_avert(.mw_coefs_origine(C0, C1))
  if (length(n$w)) return(paste("ECART : avertissement", paste(n$w, collapse = " ; ")))
  if (a$erreur) return(if (n$erreur) "erreur" else "ECART : erreur de l'oracle seul")
  if (n$erreur) return("ECART : erreur de la nouvelle implementation seule")
  if (nrow(a$v) < 2) return(if (nrow(n$v) < 2) "rang<2" else "ECART : rang")
  if (identical(n$v, a$v)) "identique" else "ECART : valeurs"
}
# Triangle I x I (cumuls), cellules i + j > I - 1 a NA.
triangle_tire <- function(I = 8L, echelle = 1, ex_aequo = FALSE, prop = FALSE,
                          c0_const = FALSE) {
  c0 <- if (c0_const) rep(500, I) else stats::runif(I, 100, 1000)
  if (ex_aequo) c0 <- round(c0, -2)
  f <- exp(stats::rnorm(I - 1L, 0.3, 0.2))
  m <- matrix(NA_real_, I, I)
  m[, 1] <- c0
  for (j in 2:I) m[, j] <- m[, j - 1] * f[j - 1] *
    (if (prop) 1 else exp(stats::rnorm(I, 0, 0.05)))
  m[row(m) + col(m) > I + 1L] <- NA_real_
  m * echelle
}
D513 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
TRI513 <- unname(as.matrix(D513[, setdiff(names(D513), "i")])); storage.mode(TRI513) <- "double"

## --- Table des coefficients : colonnes de regression --------------------------
verifier(".mw_coefs_origine() (#513) : cas limites = oracle summary(lm()) (ajustement parfait, C0 constant, NA, NaN, poids invalides ou nuls, ddl nul, echelles extremes)",
         {
           x <- c(312, 355, 401, 458, 520)
           cas <- list(
             nominal       = list(x, x * 2.1 + c(3, -5, 2, 7, -4)),
             parfait       = list(x, 2 * x),
             parfait_a     = list(x, 5 + 2 * x),
             n3            = list(x[1:3], x[1:3] * c(2.0, 2.2, 1.9)),
             c0_constant   = list(rep(400, 5), c(800, 810, 790, 805, 795)),
             na_c0         = list(replace(x, 2, NA), x * 2.1 + c(3, -5, 2, 7, -4)),
             nan_c1        = list(x, replace(x * 2.1 + c(3, -5, 2, 7, -4), 4, NaN)),
             na_ddl0       = list(replace(x, c(1, 2, 3), NA), x * 2.1 + c(3, -5, 2, 7, -4)),
             na_tout       = list(rep(NA_real_, 5), x),
             c0_negatif    = list(replace(x, 3, -x[3]), x * 2),
             c0_nul        = list(replace(x, 3, 0), x * 2 + 1:5),
             c0_infini     = list(replace(x, 3, Inf), x * 2 + 1:5),
             c1_infini     = list(x, replace(x * 2, 3, Inf)),
             echelle_m150  = list(x * 1e-150, (x * 2.1 + c(3, -5, 2, 7, -4)) * 1e-150),
             echelle_150   = list(x * 1e150, (x * 2.1 + c(3, -5, 2, 7, -4)) * 1e150),
             echelle_46    = list(x * 1e46, 2 * x * 1e46 * (1 + c(1, -1, 1, -1, 1) * 1e-13)))
           r <- vapply(cas, function(k) comparer_coefs(k[[1]], k[[2]]), character(1))
           attendu <- c(nominal = "identique", parfait = "identique", parfait_a = "identique",
                        n3 = "identique", c0_constant = "rang<2", na_c0 = "identique",
                        nan_c1 = "identique", na_ddl0 = "identique", na_tout = "erreur",
                        c0_negatif = "erreur", c0_nul = "erreur", c0_infini = "identique",
                        c1_infini = "erreur", echelle_m150 = "identique",
                        echelle_150 = "identique", echelle_46 = "identique")
           ok <- identical(r, attendu)
           if (ok) TRUE else paste(names(r), r, sep = " = ", collapse = " ; ")
         })

verifier(".mw_coefs_origine() (#513) : 2 000 colonnes tirees sous graine (n de 3 a 8, ex aequo, ajustement quasi parfait, echelles de 1e-8 a 1e46) identiques a l'oracle summary(lm())",
         {
           r <- engine_sous_graine(513L, vapply(seq_len(2000L), function(b) {
             n <- sample(3:8, 1L)
             C0 <- stats::runif(n, 50, 5000)
             if (b %% 5L == 0L) C0 <- round(C0, -2)            # ex aequo
             bruit <- if (b %% 7L == 0L) 1e-14 else 0.05       # quasi parfait
             C1 <- C0 * exp(stats::rnorm(1L, 0.3, 0.2)) + stats::rnorm(n, 0, bruit * mean(C0))
             e <- 10^sample(c(-8, 0, 8, 20, 46), 1L)
             comparer_coefs(C0 * e, C1 * e)
           }, character(1)))
           tab <- table(r)
           if (all(grepl("^(identique|rang<2|erreur)$", r)) && tab[["identique"]] >= 1900L) TRUE else
             paste(names(tab), tab, sep = " : ", collapse = " ; ")
         })

## --- mw_test_ordonnee_origine() complet : triangles varies --------------------
verifier("mw_test_ordonnee_origine() (#513) : resultat identical() a l'oracle lm() sur triangle_mw.csv (unites 1, 1e-8, 1e20, 1e46), 600 triangles tires et 300 triangles simules du bootstrap, sans avertissement",
         {
           compare_tri <- function(t, jd = NULL, jni = NULL) {
             aj <- mw_ajuster(t)
             a <- avec_avert(origine_avant(aj, jd, jni))
             n <- avec_avert(mw_test_ordonnee_origine(aj, jd, jni))
             if (length(n$w)) return("avertissement")
             if (a$erreur || n$erreur) return(if (a$erreur && n$erreur) "erreur" else "ECART erreur")
             if (!identical(n$v, a$v)) return("ECART")
             if (is.na(n$v$stat)) "identique (stat NA)" else "identique"
           }
           r_ref <- vapply(c(1, 1e-8, 1e20, 1e46), function(e) compare_tri(TRI513 * e), character(1))
           r_tire <- engine_sous_graine(5130L, vapply(seq_len(600L), function(b) {
             t <- triangle_tire(I = sample(5:10, 1L),
                                echelle = 10^sample(c(-8, 0, 8, 20, 46), 1L),
                                ex_aequo = b %% 4L == 0L, prop = b %% 9L == 0L,
                                c0_const = b %% 11L == 0L)
             # ensembles figes imposes vides une fois sur trois : colonne a
             # C0 constant soumise a la regression (rang 1)
             if (b %% 3L == 0L) compare_tri(t, integer(0), integer(0)) else compare_tri(t)
           }, character(1)))
           aj0 <- mw_ajuster(TRI513); jd0 <- .mw_colonnes_degenerees(aj0)
           jno0 <- .mw_colonnes_origine_non_identifiables(aj0, jd0)
           r_boot <- engine_sous_graine(20260831L, {
             pool <- .mw_pool_residus(aj0, jd0)
             vapply(seq_len(300L), function(b) {
               t <- mw_simuler_triangle(aj0, pool * (if (b %% 2L) 1 else 6))
               if (any(!is.finite(t[!is.na(t)])) || any(t[!is.na(t)] <= 0)) return("hors domaine")
               compare_tri(t, jd0, jno0)
             }, character(1))
           })
           r <- c(r_ref, r_tire, r_boot)
           tab <- table(r)
           ok <- all(r %in% c("identique", "identique (stat NA)", "erreur", "hors domaine")) &&
             all(r_ref == "identique") && sum(r == "identique") >= 600L &&
             any(r == "identique (stat NA)")
           if (ok) TRUE else paste(names(tab), tab, sep = " : ", collapse = " ; ")
         })

fin_fichier()
