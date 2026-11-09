# Essai (c3) : regression ponderee C1 ~ C0 (poids 1 / C0) de mw_test_ordonnee_origine()
# par stats::lm.wfit(), appelee par lm(), et transcription des lignes de summary.lm()
# qui donnent la table des coefficients (memes operations, meme ordre).
# Ecarts de comportement possibles hors du domaine usuel (NA : lm() les retire par
# na.omit, lm.wfit() leve une erreur ; avertissement "essentially perfect fit").
.mw_wls_coefs <- function(C0, C1) {
  w <- 1 / C0
  X <- cbind(`(Intercept)` = 1, C0 = C0)
  z <- stats::lm.wfit(X, C1, w)
  p <- z$rank
  if (p < 2L) return(NULL)
  rdf <- z$df.residual
  r <- z$residuals
  rss <- sum(w * r^2)
  resvar <- rss / rdf
  p1 <- 1L:p
  Qr <- z$qr
  R <- chol2inv(Qr$qr[p1, p1, drop = FALSE])
  se <- sqrt(diag(R) * resvar)
  est <- z$coefficients[Qr$pivot[p1]]
  tval <- est / se
  cbind(Estimate = est, `Std. Error` = se, `t value` = tval,
        `Pr(>|t|)` = 2 * stats::pt(abs(tval), rdf, lower.tail = FALSE))
}

mw_test_ordonnee_origine <- function(aj, j_degeneres = NULL, j_non_identifiables = NULL) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  # Une ligne par colonne retenue, table assemblee une fois (.mw_empiler(),
  # #239, #250).
  blocs <- list()
  ex <- .mw_exclues_vide()
  # Ensembles figes par .mw_ensembles_figes() (#290), ensemble de la courbure
  # impose vide : son calcul n'est pas fait ici (il n'est pas lu).
  figes <- .mw_ensembles_figes(aj, j_degeneres, integer(0), j_non_identifiables)
  jd <- figes$degeneres
  jni <- figes$origine_non_identifiables
  # Element "non_identifiables" (#273) : forme avant la boucle, porte par
  # tous les retours (.mw_table_non_identifiables()).
  ni <- .mw_table_non_identifiables(jni, I, J, jd, 3L)
  na_stat <- function() .mw_stat_non_definie_ni(ex, ni)
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 3) next                    # 2 parametres + 1 ddl minimum
    # Colonne degeneree (issue #56) : t_j = a_j / se(a_j) vaut 0/0, statistique
    # non definie ; colonne de l'ensemble fige exclue, colonne retenue mais
    # degeneree -> statistique NA, AVANT tout appel a lm().
    if (j %in% jd) { ex <- .mw_exclure(ex, j, length(idx)); next }
    ex$eligibles <- ex$eligibles + 1L
    # Colonne non identifiable de l'ensemble fige (#273) : ecartee, comptee
    # dans "eligibles", hors de K, nommee dans le libelle par
    # .mw_phrase_origine_non_identifiable(). Testee AVANT le controle de
    # degenerescence, comme pour la courbure (#270).
    if (j %in% jni) next
    if (.mw_colonne_degeneree(aj, j)) return(na_stat())
    C0 <- tri[idx + 1, j + 1]; C1 <- tri[idx + 1, j + 2]
    m <- try(list(coefficients = .mw_wls_coefs(C0, C1)), silent = TRUE)
    if (!inherits(m, 'try-error') && is.null(m$coefficients)) m$coefficients <- matrix(0, 0, 4)
    # Plus aucune exclusion silencieuse (#273, second volet de #56) : une
    # colonne retenue dont lm() echoue ou rend moins de deux coefficients
    # (C(i,j) constant dans une replication, ou rang numerique deficient a
    # l'observe, option (A)) rend la statistique NA, K = NA ; la replication
    # sort de B effectif, au lieu d'une statistique a une colonne de moins.
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
