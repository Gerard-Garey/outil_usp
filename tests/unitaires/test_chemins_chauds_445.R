###############################################################################
#  tests/unitaires/test_chemins_chauds_445.R  --  CHEMINS CHAUDS DU BOOTSTRAP
#                         CONTRE LEUR FORME D'AVANT #445 (B2, B3, B4)
#
#  Issue #445 : trois allegements des chemins chauds du bootstrap, chacun
#  retenu seulement s'il est identique au bit pres. Test differentiel : la
#  forme d'avant #445 est recopiee ci-dessous comme oracle, ou rappelee par
#  la fonction de stats qu'elle appelait, et confrontee a la nouvelle.
#    - B2 : .mw_df() contre data.frame() (attributs dans le meme ordre, noms
#      de lignes automatiques, repli sur data.frame() pour une colonne a
#      noms) ; mw_test_cellule_aberrante() contre son corps d'avant #445 ;
#      table vide initiale des colonnes exclues de mw_residus().
#    - B3 : predicat des colonnes degenerees de aj calcule une fois par
#      .mw_contexte_mc() (degeneres_aj) contre son evaluation colonne par
#      colonne : mw_test_ordonnee_origine(), mw_test_homogeneite_f(),
#      mw_test_courbure(), mw_influence(), mw_test_cellule_aberrante() et
#      statistiques du catalogue MW_CATALOGUE_MC (.mw_stats()), sur des
#      triangles tires sous graine, simules comme dans le bootstrap, et sous
#      des ensembles figes d'un autre triangle (colonne degeneree dans aj et
#      hors de l'ensemble fige : statistique NA).
#    - B4 : .usp_spearman_S() contre stats::cor.test(method = "spearman",
#      exact = FALSE) et .usp_smirnov_D() contre stats::ks.test(), sur des
#      vecteurs tires sous graine (continus, ex aequo, constants, NA,
#      effectifs de 1 a 12).
#  Critere : identical(attrib.as.set = FALSE) (valeurs au bit pres, types,
#  noms, attributs et leur ordre) ; une erreur de l'oracle est une erreur de
#  la nouvelle forme.
#  Piste B1 (lm.wfit() dans l'ordonnee a l'origine) : realisee par #513, test
#  differentiel par lm() dans tests/unitaires/test_ordonnee_wls.R.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_chemins_chauds_445.R")

meme <- function(a, b) identical(a, b, attrib.as.set = FALSE)
# Resultat ou erreur (classe "error"), pour comparer les deux formes.
essai <- function(expr) tryCatch(suppressWarnings(expr), error = function(e) e)
meme_ou_erreurs <- function(a, b) {
  if (inherits(a, "error") || inherits(b, "error")) inherits(a, "error") && inherits(b, "error")
  else meme(a, b)
}

## --- Triangles ---------------------------------------------------------------
D445 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
TRI445 <- unname(as.matrix(D445[, setdiff(names(D445), "i")])); storage.mode(TRI445) <- "double"
# Triangle I x I tire sous la graine courante : facteurs individuels
# perturbes, avec, selon le type, une colonne exactement ou presque
# proportionnelle (degeneree), des ex aequo, une colonne de C constants, des
# noms de lignes, ou une cellule a influence non bornee (autres cellules de
# la colonne proportionnelles).
triangle_445 <- function(type, I = 8L) {
  m <- matrix(NA_real_, I, I)
  m[, 1] <- stats::runif(I, 100, 1000)
  f <- exp(stats::rnorm(I - 1L, 0.3, 0.2))
  for (j in 2:I) m[, j] <- m[, j - 1] * f[j - 1] * exp(stats::rnorm(I, 0, 0.08))
  m[row(m) + col(m) > I + 1L] <- NA_real_
  j <- 1L + sample.int(4L, 1L)
  r <- which(!is.na(m[, j + 1L]))
  switch(type,
         prop      = { m[r, j + 1L] <- m[r, j] * 1.07 },
         presque   = { m[r, j + 1L] <- m[r, j] * 1.07 * (1 + 1e-14 * seq_along(r)) },
         ex_aequo  = { m <- round(m, -1) },
         c0_const  = { m[r, j] <- m[r[1L], j]; m[r, j + 1L] <- m[r, j] * exp(stats::rnorm(length(r), 0.3, 0.05)) },
         noms      = { rownames(m) <- paste0("a", 2000L + seq_len(I)) },
         non_borne = { r2 <- which(!is.na(m[, 3L])); m[r2, 3L] <- m[r2, 2L] * 3; m[r2[1L], 3L] <- m[r2[1L], 2L] * 3.5 },
         nominal   = NULL)
  m
}
TYPES_445 <- c("nominal", "prop", "presque", "ex_aequo", "c0_const", "noms", "non_borne")
TRIANGLES_445 <- local({
  set.seed(4450L)
  l <- list(reference = TRI445)
  for (k in seq_len(84L)) l[[sprintf("%s_%d", TYPES_445[(k - 1L) %% 7L + 1L], k)]] <-
    triangle_445(TYPES_445[(k - 1L) %% 7L + 1L])
  # triangles simules par mw_simuler_triangle(), comme dans le bootstrap
  aj0 <- mw_ajuster(TRI445); jd0 <- .mw_colonnes_degenerees(aj0)
  engine_sous_graine(20260831L, {
    pool <- .mw_pool_residus(aj0, jd0)
    for (b in seq_len(40L)) {
      t <- mw_simuler_triangle(aj0, pool * (if (b %% 2L) 1 else 6))
      if (all(is.finite(t[!is.na(t)])) && all(t[!is.na(t)] > 0)) l[[sprintf("simule_%d", b)]] <- t
    }
  })
  l
})
AJ_445 <- Filter(is.list, lapply(TRIANGLES_445, function(t) essai(mw_ajuster(t))))
# Ensembles figes : ceux du triangle lui-meme, et ceux du triangle de
# reference (dans un triangle a colonne degeneree, la colonne est hors de
# l'ensemble fige et rend les statistiques de M1 non definies).
FIGES_REF_445 <- .mw_ensembles_figes(mw_ajuster(TRI445))

## --- B2 : data.frame() hors des replications ---------------------------------
verifier(".mw_df() (#445, B2) = data.frame() au bit pres : colonnes vides, entieres, reelles, logiques, une a six colonnes, NA, repli sur data.frame() pour une colonne a noms",
         {
           set.seed(1L)
           cas <- list(
             vide2   = list(i = integer(0), j = integer(0)),
             un      = list(i = 3L, j = 4L),
             six     = list(i = 1:5, j = c(2L, 2L, 3L, 3L, 3L), n_j = rep(5L, 5), t = stats::rnorm(5),
                            p = stats::runif(5), non_borne = c(TRUE, FALSE, FALSE, NA, FALSE)),
             vide6   = list(i = integer(0), j = integer(0), n_j = integer(0), t = numeric(0),
                            p = numeric(0), non_borne = logical(0)),
             na      = list(a = c(NA, 1.5, NaN), b = c(NA_integer_, 2L, 3L)),
             noms    = list(i = c(x = 1L, y = 2L), j = 3:4),
             noms2   = list(i = 1:2, j = c(u = 3L, v = 4L)))
           r <- vapply(names(cas), function(nm)
             meme(do.call(.mw_df, cas[[nm]]), do.call(data.frame, cas[[nm]])), logical(1))
           if (all(r)) TRUE else paste("differents :", paste(names(r)[!r], collapse = ", "))
         })

# Corps de mw_test_cellule_aberrante() d'avant #445 (tables par data.frame(),
# sans argument degeneres_aj).
cellule_avant <- function(aj, j_degeneres = NULL, replique = FALSE) {
  jd <- .mw_j_exclues(aj, j_degeneres)
  inf <- mw_influence(aj)
  t <- rep(NA_real_, nrow(inf))
  for (j in unique(inf$j)) {
    sel <- which(inf$j == j)
    t[sel] <- inf$dfbetas[sel] * sqrt(.mw_sommes_autres(inf$C[sel]) / inf$C[sel])
  }
  nj <- stats::ave(inf$j, inf$j, FUN = length)
  k <- nj >= MW_NJ_MIN_CELLULE & !(inf$j %in% jd)
  na <- list(stat = NA_real_, p = NA_real_, N_t = sum(k), i = NA_integer_, j = NA_integer_,
             n_j = NA_integer_, t = NA_real_, non_borne = .MW_DF_VIDE_I_J, cellules = NULL)
  if (!any(k)) return(na)
  nb <- inf$dfbetas_non_borne[k]
  tk <- t[k]; njk <- nj[k]; ik <- inf$i[k]; jk <- inf$j[k]
  if (any(is.na(tk) & !nb)) return(na)
  if (any(nb) && !replique) {
    na$non_borne <- data.frame(i = ik[nb], j = jk[nb])
    return(na)
  }
  p <- 2 * stats::pt(-abs(tk), njk - 2); p[nb] <- 0
  im <- which.min(p)
  M <- min(p)
  list(stat = M, p = min(1, length(p) * M), N_t = length(p), i = ik[im], j = jk[im],
       n_j = njk[im], t = tk[im], non_borne = data.frame(i = ik[nb], j = jk[nb]),
       cellules = data.frame(i = ik, j = jk, n_j = njk, t = tk, p = p, non_borne = nb))
}
verifier("mw_test_cellule_aberrante() (#445, B2) = corps d'avant #445 au bit pres (observe et replication, ensembles figes propres, de reference et vides ; cellules a influence non bornee comprises)",
         {
           n <- 0L; nb <- 0L; ko <- character(0)
           for (nm in names(AJ_445)) {
             aj <- AJ_445[[nm]]
             for (jd in list(NULL, FIGES_REF_445$degeneres, integer(0))) for (rep in c(FALSE, TRUE)) {
               a <- essai(mw_test_cellule_aberrante(aj, jd, replique = rep))
               b <- essai(cellule_avant(aj, jd, replique = rep))
               n <- n + 1L
               if (is.list(b) && nrow(b$non_borne)) nb <- nb + 1L
               if (!meme_ou_erreurs(a, b)) ko <- c(ko, nm)
             }
           }
           if (!length(ko) && n >= 600L && nb >= 1L) TRUE else
             sprintf("%d appels, %d a cellule non bornee, differents : %s", n, nb, paste(unique(ko), collapse = ", "))
         })

verifier("mw_residus() (#445, B2) : table vide initiale des colonnes exclues = data.frame(j = integer(0), n_facteurs = integer(0)), avant et apres ajout d'une ligne ; constante .MW_DF_VIDE_J_N intacte apres des exclusions",
         {
           d0 <- data.frame(j = integer(0), n_facteurs = integer(0))
           a <- .MW_DF_VIDE_J_N; a[nrow(a) + 1L, ] <- list(3L, 5L)
           b <- d0; b[nrow(b) + 1L, ] <- list(3L, 5L)
           aj <- mw_ajuster(TRI445)
           ex0 <- attr(mw_residus(aj), "colonnes_exclues")
           ex1 <- attr(mw_residus(aj, c(1L, 2L)), "colonnes_exclues")
           meme(.MW_DF_VIDE_J_N, d0) && meme(a, b) && nrow(ex1) >= 2L &&
             meme(.MW_DF_VIDE_J_N, d0)
         })

## --- B3 : predicat des colonnes degenerees de aj, calcule une fois -----------
verifier(".mw_contexte_mc() (#445, B3) : degeneres_aj = .mw_colonnes_degenerees(aj), y compris sous un ensemble fige d'un autre triangle",
         all(vapply(AJ_445, function(aj) {
           e1 <- .mw_contexte_mc(aj); e2 <- .mw_contexte_mc(aj, FIGES_REF_445)
           meme(e1$degeneres_aj, .mw_colonnes_degenerees(aj)) &&
             meme(e2$degeneres_aj, .mw_colonnes_degenerees(aj))
         }, logical(1))))

verifier("M1 et M4 (#445, B3) : argument degeneres_aj = evaluation colonne par colonne au bit pres (ordonnee, homogeneite, courbure, influence, cellule aberrante ; ensembles figes propres, de reference et vides)",
         {
           n <- 0L; n_na <- 0L; ko <- character(0)
           for (nm in names(AJ_445)) {
             aj <- AJ_445[[nm]]; da <- .mw_colonnes_degenerees(aj)
             fp <- .mw_ensembles_figes(aj)
             for (fg in list(fp, FIGES_REF_445, list(degeneres = integer(0), non_identifiables = integer(0),
                                                     origine_non_identifiables = integer(0)))) {
               paires <- list(
                 origine  = list(essai(mw_test_ordonnee_origine(aj, fg$degeneres, fg$origine_non_identifiables, da)),
                                 essai(mw_test_ordonnee_origine(aj, fg$degeneres, fg$origine_non_identifiables))),
                 homf     = list(essai(mw_test_homogeneite_f(aj, fg$degeneres, da)),
                                 essai(mw_test_homogeneite_f(aj, fg$degeneres))),
                 courbure = list(essai(mw_test_courbure(aj, fg$degeneres, fg$non_identifiables, NULL, da)),
                                 essai(mw_test_courbure(aj, fg$degeneres, fg$non_identifiables))),
                 cellule  = list(essai(mw_test_cellule_aberrante(aj, fg$degeneres, TRUE, da)),
                                 essai(mw_test_cellule_aberrante(aj, fg$degeneres, TRUE))))
               for (p in names(paires)) {
                 n <- n + 1L
                 if (is.list(paires[[p]][[2L]]) && is.na(paires[[p]][[2L]]$stat)) n_na <- n_na + 1L
                 if (!meme_ou_erreurs(paires[[p]][[1L]], paires[[p]][[2L]])) ko <- c(ko, paste(nm, p))
               }
             }
             n <- n + 1L
             if (!meme_ou_erreurs(essai(mw_influence(aj, da)), essai(mw_influence(aj)))) ko <- c(ko, paste(nm, "influence"))
           }
           if (!length(ko) && n >= 1500L && n_na >= 50L) TRUE else
             sprintf("%d comparaisons, %d statistiques NA, differents : %s", n, n_na, paste(ko, collapse = ", "))
         })

verifier("MW_CATALOGUE_MC (#445, B3) : .mw_stats() (observe et replication) = catalogue evalue sans degeneres_aj au bit pres, extremites et motifs non_definie compris",
         {
           oracle <- function(aj, fg, rep) {
             e <- .mw_contexte_mc(aj, fg); e$degeneres_aj <- NULL
             if (rep) e$replique <- TRUE
             .mc_evaluer(MW_CATALOGUE_MC, e)
           }
           cotes <- function(e) lapply(MW_CATALOGUE_MC, function(ent)
             list(if (is.function(ent$extremes)) essai(ent$extremes(e)),
                  if (is.function(ent$non_definie)) essai(ent$non_definie(e))))
           n <- 0L; n_na <- 0L; ko <- character(0)
           for (nm in names(AJ_445)) {
             aj <- AJ_445[[nm]]
             for (fg in list(NULL, FIGES_REF_445)) for (rep in c(FALSE, TRUE)) {
               a <- essai(.mw_stats(aj, fg, replique = rep)); b <- essai(oracle(aj, fg, rep))
               n <- n + 1L
               if (is.numeric(b)) n_na <- n_na + any(is.na(b))
               if (!meme_ou_erreurs(a, b)) ko <- c(ko, nm)
             }
             e1 <- .mw_contexte_mc(aj); e0 <- e1; e0$degeneres_aj <- NULL
             if (!meme(cotes(e1), cotes(e0))) ko <- c(ko, paste(nm, "extremes/non_definie"))
           }
           if (!length(ko) && n >= 500L && n_na >= 20L) TRUE else
             sprintf("%d evaluations, %d avec NA, differents : %s", n, n_na, paste(unique(ko), collapse = ", "))
         })

## --- B4 : statistiques de cor.test() et de ks.test() calculees seules ---------
spearman_avant <- function(a, b)
  suppressWarnings(unname(stats::cor.test(a, b, method = "spearman", exact = FALSE)$statistic))
smirnov_avant <- function(x, y) unname(suppressWarnings(stats::ks.test(x, y)$statistic))

verifier(".usp_spearman_S() (#445, B4) = S de cor.test(method = \"spearman\", exact = FALSE) au bit pres (2 000 paires : continues, ex aequo, constantes, NA, n de 1 a 12, longueurs differentes)",
         {
           set.seed(4451L); ko <- 0L; n_na <- 0L; n_err <- 0L
           for (k in seq_len(2000L)) {
             n <- c(1L, 2L, 3L, 6L, 8L, 8L, 8L, 10L, 12L)[(k - 1L) %% 9L + 1L]
             a <- stats::rnorm(n); b <- if (k %% 2L) seq_len(n) else stats::rlnorm(n)
             if (k %% 5L == 0L) a <- round(a, 0)
             if (k %% 7L == 0L) b <- round(b, 0)
             if (k %% 11L == 0L) a[] <- a[1L]
             if (k %% 13L == 0L && n > 2L) a[2L] <- NA
             if (k %% 17L == 0L) b <- b[-1L]
             x <- essai(.usp_spearman_S(a, b)); y <- essai(spearman_avant(a, b))
             if (inherits(y, "error")) n_err <- n_err + 1L else if (is.na(y)) n_na <- n_na + 1L
             if (!meme_ou_erreurs(x, y)) ko <- ko + 1L
           }
           if (!ko && n_na >= 50L && n_err >= 50L) TRUE else
             sprintf("%d differences, %d S NA, %d erreurs", ko, n_na, n_err)
         })

verifier(".usp_smirnov_D() (#445, B4) = D de ks.test() a deux echantillons au bit pres (2 000 paires : continues, ex aequo dans et entre echantillons, NA, effectifs de 0 a 9)",
         {
           set.seed(4452L); ko <- 0L; n_ties <- 0L; n_err <- 0L
           for (k in seq_len(2000L)) {
             nx <- c(0L, 1L, 3L, 4L, 4L, 5L, 9L)[(k - 1L) %% 7L + 1L]
             ny <- c(4L, 3L, 4L, 1L, 5L, 0L)[(k - 1L) %% 6L + 1L]
             x <- stats::rnorm(nx); y <- stats::rnorm(ny, 0.3)
             if (k %% 3L == 0L) { x <- round(x, 0); y <- round(y, 0) }
             if (k %% 10L == 0L && nx > 1L) x[1L] <- NA
             if (k %% 3L == 0L) n_ties <- n_ties + (length(unique(c(x, y))) < length(c(x, y)))
             a <- essai(.usp_smirnov_D(x, y)); b <- essai(smirnov_avant(x, y))
             if (inherits(b, "error")) n_err <- n_err + 1L
             if (!meme_ou_erreurs(a, b)) ko <- ko + 1L
           }
           if (!ko && n_ties >= 100L && n_err >= 100L) TRUE else
             sprintf("%d differences, %d paires a ex aequo, %d erreurs", ko, n_ties, n_err)
         })

verifier("USP_CATALOGUE_MC (#445, B4) : SpearVol, SpearTps et Smirnov = valeurs par cor.test() et ks.test() au bit pres (300 contextes, volumes constants et ex aequo compris)",
         {
           set.seed(4453L); ko <- character(0)
           for (k in seq_len(300L)) {
             T <- c(6L, 8L, 8L, 10L, 12L)[(k - 1L) %% 5L + 1L]
             x <- round(stats::runif(T, 50, 200), 1)
             if (k %% 7L == 0L) x[2L] <- x[1L]
             if (k %% 11L == 0L) x[] <- x[1L]
             y <- x * exp(stats::rnorm(T, -0.4, 0.2)); if (k %% 13L == 0L) y <- 0.7 * x
             z <- stats::rnorm(T); if (k %% 5L == 0L) z <- round(z, 1)
             e <- .usp_contexte_mc(x, y, z, stats::runif(1))
             v <- c(SpearVol = USP_CATALOGUE_MC$SpearVol$calc(e), SpearTps = USP_CATALOGUE_MC$SpearTps$calc(e),
                    Smirnov = USP_CATALOGUE_MC$Smirnov$calc(e))
             sm <- NA_real_
             if (e$T >= 8 && !usp_volumes_constants(e$x)) {
               g <- e$x > stats::median(e$x)
               if (sum(g) >= 3 && sum(!g) >= 3) {
                 za <- engine_aplatir_ex_aequo(e$z); sm <- smirnov_avant(za[g], za[!g])
               }
             }
             w <- c(SpearVol = if (!usp_volumes_constants(e$x))
                      spearman_avant(.usp_aplatir_ratios(e$r), .usp_aplatir_volumes(e$x)) else NA_real_,
                    SpearTps = spearman_avant(.usp_aplatir_ratios(e$r), seq_along(e$r)),
                    Smirnov = sm)
             if (!meme(v, w)) ko <- c(ko, as.character(k))
           }
           if (!length(ko)) TRUE else paste("contextes differents :", paste(ko, collapse = ", "))
         })

fin_fichier()
