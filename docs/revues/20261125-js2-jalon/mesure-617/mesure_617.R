###############################################################################
#  mesure_617.R -- mesure de #617 (JS2, etape 2b)
#
#  Question : la colonne J-1 d'un trapeze, degeneree a l'observe, reste-t-elle
#  degeneree dans les replications de mw_bootstrap() ? Qu'en est-il de la
#  famille Alpha, qui ne recoit pas l'ensemble fige ?
#
#  Specification : docs/revues/20261125-js2-jalon/actuary-1-protocole-617.md,
#  section 5 (regle de decision : section 4, figee avant l'execution).
#
#  Commande, depuis la racine du depot :
#    LC_ALL=C.UTF-8 Rscript docs/revues/20261125-js2-jalon/mesure-617/mesure_617.R \
#      > docs/revues/20261125-js2-jalon/mesure-617/sortie_mesure_617.txt 2>&1
#  Options (defauts) : --B=999 --graine=20260831 --triangles=T1,T2,T0
#  Avec B < 999 l'en-tete porte "ESSAI, NON VERSABLE".
#
#  Le script ne modifie aucun fichier du depot. Il charge le moteur par
#  charger_moteur() (ADR 0016) et pose deux crochets de lecture dans
#  environment(run_engine), retires meme en cas d'erreur ; il ne tire rien
#  lui-meme (toute l'aleatoire passe par mw_bootstrap(), sous
#  engine_sous_graine()).
###############################################################################

T_DEBUT <- Sys.time()
options(width = 200)   # impression des triangles sur une seule bande

# --- Constantes du protocole (aucun seuil ajoute) ----------------------------
MD5_ENGINE_ATTENDU <- "723277ddfa5736d7411838d15d8dad00"   # en-tete du protocole
TOL_DEG   <- 1e-12     # tolerance du predicat de degenerescence (et D4)
DATE_REF  <- "2026-12-31"
ALPHA_NIV <- c(0.10, 0.05)   # seuils de l'ecart de verdict (E2, par. 4.3)
N_I3      <- 50L
ISSUE_RANG <- c("1" = 1L, "2a" = 2L, "2b" = 3L, "3" = 4L)

# --- Arguments ----------------------------------------------------------------
lire_args <- function(args) {
  o <- list(B = 999L, graine = 20260831, triangles = c("T1", "T2", "T0"))
  for (a in args) {
    if (grepl("^--B=", a)) o$B <- as.integer(sub("^--B=", "", a))
    else if (grepl("^--graine=", a)) o$graine <- as.numeric(sub("^--graine=", "", a))
    else if (grepl("^--triangles=", a))
      o$triangles <- strsplit(sub("^--triangles=", "", a), ",", fixed = TRUE)[[1]]
    else stop("argument inconnu : ", a)
  }
  if (length(o$B) != 1L || is.na(o$B) || o$B < 1L) stop("--B doit etre un entier >= 1")
  if (length(o$graine) != 1L || !is.finite(o$graine)) stop("--graine doit etre un nombre")
  if (!length(o$triangles) || !all(o$triangles %in% c("T1", "T2", "T0")))
    stop("--triangles : sous-ensemble de T1,T2,T0")
  o
}
OPT <- lire_args(commandArgs(trailingOnly = TRUE))

# --- Racine et moteur ---------------------------------------------------------
if (!file.exists("R/engine.R"))
  stop("lancer depuis la racine du depot (R/engine.R introuvable)")
source("R/charger_moteur.R")
charger_moteur()
env <- environment(run_engine)

# --- Utilitaires de sortie (ASCII) --------------------------------------------
sortie <- function(...) cat(..., "\n", sep = "")
titre  <- function(s) sortie("\n", s, "\n", strrep("-", nchar(s)))
f17    <- function(x) format(x, digits = 17)
f6     <- function(x) format(x, digits = 6)
ok_ko  <- function(x) if (isTRUE(x)) "OK" else "ECHEC"

# --- Lecture et construction des triangles (protocole, par. 3) ---------------
# Lecture comme tests/outils_tests.R, l. 76-91 (code recopie).
lire_csv_triangle <- function(fichier) {
  df <- utils::read.csv(file.path("tests", "donnees", fichier))
  m <- as.matrix(df[, setdiff(names(df), "i")])
  storage.mode(m) <- "double"
  unname(m)
}

construire_triangles <- function() {
  tri_trap <- lire_csv_triangle("triangle_mw_trapeze.csv")
  tri_mw   <- lire_csv_triangle("triangle_mw.csv")

  # T1 : C(i,5) := C(i,4) * f_4 pour i = 0..2 (f_4 de l'original), soit
  # i = 0..I-J, colonne J-1 -> J.
  aj <- mw_ajuster(tri_trap); I <- aj$I; J <- aj$J
  T1 <- tri_trap
  for (i in 0:(I - J)) T1[i + 1, J + 1] <- T1[i + 1, J] * aj$f[J]

  # T2 : colonnes j0 a j4 de triangle_mw.csv ; C(i,4) := C(i,3) * f_3, i = 0..3.
  T2 <- tri_mw[, 1:5]
  aj2 <- mw_ajuster(T2); I2 <- aj2$I; J2 <- aj2$J
  for (i in 0:(I2 - J2)) T2[i + 1, J2 + 1] <- T2[i + 1, J2] * aj2$f[J2]

  # T0 : T1, puis colonne 2 rendue degeneree : pour i = 0..4, les colonnes
  # 3..5 de la ligne i sont multipliees par f_2 * C(i,2) / C(i,3) (f_2 de T1) ;
  # les facteurs des colonnes 3 et 4 sont inchanges.
  aj1 <- mw_ajuster(T1)
  f2 <- aj1$f[3]
  T0 <- T1
  for (i in 0:4) {
    r <- f2 * T0[i + 1, 3] / T0[i + 1, 4]
    T0[i + 1, 4:6] <- T0[i + 1, 4:6] * r
  }
  list(T1 = T1, T2 = T2, T0 = T0)
}

# --- Quantiles de log10(ecart) : "0" pour un ecart nul ------------------------
# type = 1 (fonction de repartition empirique inverse, sans interpolation) :
# commute avec la transformation croissante log10, de sorte que le quantile
# de log10(ecart) est le log10 du quantile de l'ecart.
quantiles_log10 <- function(ecart) {
  e <- ecart[is.finite(ecart)]
  if (!length(e)) return("(aucun ecart fini)")
  ps <- c(0, 0.01, 0.5, 0.99, 1)
  q <- stats::quantile(e, ps, type = 1, names = FALSE)
  v <- vapply(q, function(x) if (x == 0) "0" else sprintf("%.3f", log10(x)), "")
  paste(sprintf("q%s = %s", format(ps, nsmall = 2), v), collapse = " ; ")
}

# --- Controle I5 (md5 du moteur, etat du depot) ------------------------------
controle_i5 <- function() {
  md5 <- unname(tools::md5sum("R/engine.R"))
  st <- tryCatch(system2("git", c("status", "--porcelain", "--", "R/", "tests/", "app.R"),
                         stdout = TRUE, stderr = TRUE),
                 error = function(e) paste("git indisponible :", conditionMessage(e)))
  st_status <- attr(st, "status")
  git_ok <- length(st) == 0L && is.null(st_status)
  list(md5 = md5, md5_ok = identical(md5, MD5_ENGINE_ATTENDU),
       git = st, git_ok = git_ok, ok = identical(md5, MD5_ENGINE_ATTENDU) && git_ok)
}

# --- Mesure d'un triangle -----------------------------------------------------
mesurer <- function(nom, tri, B, graine) {
  titre(sprintf("TRIANGLE %s", nom))
  aj <- mw_ajuster(tri)
  I <- aj$I; J <- aj$J
  figes <- .mw_ensembles_figes(aj)
  jd <- figes$degeneres
  nJm1 <- I - J + 1L                                  # n_{J-1}
  regle <- aj$sigma2[J]
  direct <- aj[["sigma2_Jm1_direct"]]

  # 1. En-tete ---------------------------------------------------------------
  sortie("Triangle (format 17 chiffres), I = ", I, ", J = ", J, " :")
  m <- tri; dimnames(m) <- list(paste0("i", 0:I), paste0("j", 0:J))
  print(format(m, digits = 17), quote = FALSE)
  sortie("sigma2_j (j = 0..J-1) : ", paste(f17(aj$sigma2), collapse = " ; "))
  sortie("sigma2_(J-1), regle de minimum : ", f17(regle))
  sortie("sigma2_(J-1), estimateur direct : ", if (is.null(direct)) "absent" else f17(direct))
  sortie("figes$degeneres : {", paste(jd, collapse = ", "), "}")
  sortie("figes$non_identifiables : {", paste(figes$non_identifiables, collapse = ", "), "}")
  sortie("figes$origine_non_identifiables : {",
         paste(figes$origine_non_identifiables, collapse = ", "), "}")
  sortie("n_j (j = 0..J-1) : ", paste(I - 0:(J - 1), collapse = " ; "))
  sortie("n_{J-1} = ", nJm1)

  # 2. Preconditions P2 a P6 (P1 apres l'execution) --------------------------
  titre("Preconditions")
  est_T0 <- identical(nom, "T0")
  P <- list(
    P2 = I > J,
    P3 = (J - 1L) %in% jd,
    P4 = identical(.mw_cas_sigma_direct(aj), "degenere"),
    P5 = if (est_T0) isTRUE(regle <= 1e-20) else isTRUE(regle > 1e-6),
    P6 = nJm1 >= 3L)
  sortie("P2 (I > J) : ", ok_ko(P$P2), " (I = ", I, ", J = ", J, ")")
  sortie("P3 (J-1 dans figes$degeneres) : ", ok_ko(P$P3))
  sortie("P4 (cas \"degenere\") : ", ok_ko(P$P4), " (cas = ", .mw_cas_sigma_direct(aj), ")")
  sortie("P5 (regle ", if (est_T0) "<= 1e-20" else "> 1e-6", ") : ", ok_ko(P$P5),
         " (regle = ", f6(regle), ")")
  sortie("P6 (n_{J-1} >= 3) : ", ok_ko(P$P6), " (n = ", nJm1, ")")

  # 3. Execution sans crochets -----------------------------------------------
  appel <- function() run_engine(methode = "reserve2", triangle = tri, segment = 1,
                                 annexe = "II", date_reference = DATE_REF,
                                 B = B, seed = graine)
  titre("Executions")
  t_a <- Sys.time()
  res0 <- tryCatch(appel(), error = function(e) e)
  if (inherits(res0, "error")) {
    sortie("run_engine() sans crochets : ERREUR : ", conditionMessage(res0))
    sortie("P1 (ok = TRUE) : ECHEC")
    return(list(nom = nom, issue = "sans conclusion", motif = "run_engine() en erreur"))
  }
  P$P1 <- isTRUE(res0$ok)
  sortie("run_engine() sans crochets : ", sprintf("%.1f s", as.numeric(difftime(Sys.time(), t_a, units = "secs"))))
  sortie("P1 (ok = TRUE) : ", ok_ko(P$P1))
  if (!P$P1) return(list(nom = nom, issue = "sans conclusion", motif = "P1"))

  # 4-5. Crochets (lecture seule, aucun tirage), retires en toute circonstance
  jr <- new.env(); jr$stats <- list()
  jt <- new.env(); jt$sig <- numeric(0); jt$lpool <- integer(0); jt$pool <- NULL
  orig_stats  <- get(".mw_stats", envir = env, inherits = FALSE)
  orig_tirer  <- get(".mw_tirer_triangle_valide", envir = env, inherits = FALSE)
  hook_stats <- function(aj, figes = NULL, replique = FALSE, combn = NULL) {
    r <- orig_stats(aj, figes, replique, combn)
    if (isTRUE(replique))
      jr$stats[[length(jr$stats) + 1L]] <- list(tri = aj$tri, figes = figes, stats = r)
    r
  }
  hook_tirer <- function(aj, pool, reste) {
    jt$sig <- c(jt$sig, aj$sigma2[aj$J])
    jt$lpool <- c(jt$lpool, length(pool))
    if (is.null(jt$pool)) jt$pool <- pool
    orig_tirer(aj, pool, reste)
  }
  t_b <- Sys.time()
  res1 <- tryCatch({
    assign(".mw_stats", hook_stats, envir = env)
    assign(".mw_tirer_triangle_valide", hook_tirer, envir = env)
    appel()
  }, error = function(e) e,
  finally = {
    assign(".mw_stats", orig_stats, envir = env)
    assign(".mw_tirer_triangle_valide", orig_tirer, envir = env)
  })
  sortie("run_engine() avec crochets : ", sprintf("%.1f s", as.numeric(difftime(Sys.time(), t_b, units = "secs"))))
  if (inherits(res1, "error")) {
    sortie("ERREUR avec crochets : ", conditionMessage(res1))
    return(list(nom = nom, issue = "sans conclusion", motif = "run_engine() avec crochets en erreur"))
  }

  # Controles I1, I4 --------------------------------------------------------
  titre("Controles d'integrite (I1 a I4)")
  I <- list()
  I$I1a <- identical(res0$bootstrap, res1$bootstrap)
  tt0 <- engine_table_tests(res0); tt1 <- engine_table_tests(res1)
  I$I1b <- identical(tt0, tt1)
  sortie("I1 : identical(res$bootstrap) : ", ok_ko(I$I1a),
         " ; identical(engine_table_tests) : ", ok_ko(I$I1b))
  I$I4 <- identical(get(".mw_stats", envir = env, inherits = FALSE), orig_stats) &&
    identical(get(".mw_tirer_triangle_valide", envir = env, inherits = FALSE), orig_tirer)
  sortie("I4 : crochets retires (.mw_stats et .mw_tirer_triangle_valide identiques aux originaux) : ", ok_ko(I$I4))

  # 6. I2, D1, D2, D3 ---------------------------------------------------------
  jl <- jr$stats
  R <- length(jl)
  sb <- res1$bootstrap$stats_boot
  noms <- colnames(sb)
  vus <- which(rowSums(!is.na(sb)) > 0)
  sortie("|R| (replications au journal) = ", R, " ; lignes de stats_boot non entierement NA = ",
         length(vus), " ; B = ", B)
  I$I2_n <- identical(as.integer(R), length(vus))
  I$I2_v <- I$I2_n && length(noms) == 13L && all(vapply(seq_len(R), function(k)
    all(noms %in% names(jl[[k]]$stats)) &&
      identical(unname(as.numeric(jl[[k]]$stats[noms])), unname(as.numeric(sb[vus[k], ]))),
    logical(1)))
  sortie("I2 : |R| = nombre de lignes non NA : ", ok_ko(I$I2_n),
         " ; 13 statistiques identiques, dans l'ordre : ", ok_ko(I$I2_v),
         " (", length(noms), " statistiques)")

  # I3 : re-evaluation de .mw_stats() sur les N_I3 premieres replications.
  n3 <- min(N_I3, R)
  I$I3 <- n3 > 0 && all(vapply(seq_len(n3), function(k) {
    r <- .mw_stats(mw_ajuster(jl[[k]]$tri), jl[[k]]$figes, TRUE,
                   new.env(parent = emptyenv()))
    identical(r, jl[[k]]$stats)
  }, logical(1)))
  sortie("I3 : .mw_stats(replique = TRUE, combn neuf) sur les ", n3,
         " premieres replications redonne le journal : ", ok_ko(I$I3))

  i5 <- controle_i5()
  I$I5 <- i5$ok
  sortie("I5 : md5 de R/engine.R = ", i5$md5, " (attendu ", MD5_ENGINE_ATTENDU, ") : ",
         ok_ko(i5$md5_ok), " ; git status --porcelain -- R/ tests/ app.R vide : ",
         ok_ko(i5$git_ok))
  if (!i5$git_ok) sortie("  git : ", paste(i5$git, collapse = " | "))

  titre("Controles de doctrine (D1 a D3)")
  D <- list()
  D$D1 <- length(jt$sig) > 0L && all(vapply(jt$sig, function(s) identical(s, regle), logical(1)))
  sortie("D1 : aj$sigma2[J] recu par .mw_tirer_triangle_valide() = regle de l'observe (",
         f17(regle), ") a chaque appel : ", ok_ko(D$D1), " (", length(jt$sig), " appels",
         if (!is.null(direct)) paste0(" ; appels egaux a l'estimateur direct : ",
                                      sum(jt$sig == direct)) else "", ")")
  fig_obs <- .mw_ensembles_figes(aj)
  D$D2 <- R > 0L && all(vapply(jl, function(e) identical(e$figes, fig_obs), logical(1)))
  sortie("D2 : figes recu par .mw_stats() identique a .mw_ensembles_figes(aj) observe, dans les ",
         R, " replications : ", ok_ko(D$D2))
  res_obs <- mw_residus(aj, jd)
  D$D3 <- length(jt$lpool) > 0L && all(jt$lpool == nrow(res_obs)) &&
    !any(res_obs$j %in% jd)
  sortie("D3 : longueur du vivier = nrow(mw_residus(aj, figes$degeneres)) = ", nrow(res_obs),
         " a chaque appel, sans ligne j dans figes$degeneres : ", ok_ko(D$D3),
         " (longueurs vues : ", paste(unique(jt$lpool), collapse = ", "), ")")
  sortie("    (info) vivier identique a .mw_pool_residus(aj, figes$degeneres) : ",
         ok_ko(identical(jt$pool, .mw_pool_residus(aj, jd))))

  # 7. Par replication : predicat, volet, ecart, detail Alpha -----------------
  ab_l <- lapply(jl, function(e) mw_ajuster(e$tri))
  pred <- ecart <- matrix(NA, R, length(jd), dimnames = list(NULL, jd))
  for (k in seq_len(R)) for (c in seq_along(jd)) {
    pred[k, c]  <- .mw_colonne_degeneree(ab_l[[k]], jd[c])
    ecart[k, c] <- .mw_ecart_facteurs(ab_l[[k]], jd[c])$ecart
  }
  fa_l <- lapply(ab_l, mw_famille_alpha)

  # 8. D4 sur toutes les replications ; D5 -----------------------------------
  obs <- unlist(res0$bootstrap$stats_obs)[noms]
  queues <- vapply(MW_CATALOGUE_MC[noms], function(e) e$queue, "")
  cles12 <- setdiff(noms, "Alpha")
  indic <- function(x, o, q) {
    if (!is.finite(x) || !is.finite(o)) return(NA)
    switch(q, haut = x >= o, bas = x <= o, deux = c(x >= o, x <= o))
  }
  d4 <- character(R); d4_det <- list(); alpha_change <- 0L
  for (k in seq_len(R)) {
    ab <- ab_l[[k]]; tb <- ab$tri
    tbd <- tb
    for (i in 0:(ab$I - ab$J)) tbd[i + 1, ab$J + 1] <- tb[i + 1, ab$J] * ab$f[ab$J]
    sd <- tryCatch(.mw_stats(mw_ajuster(tbd), figes, TRUE, new.env(parent = emptyenv()))[noms],
                   error = function(e) NULL)
    sj <- jl[[k]]$stats[noms]
    if (is.null(sd)) { d4[k] <- "echec"; d4_det[[length(d4_det) + 1L]] <-
      sprintf("rep %d : .mw_stats() en erreur sur le triangle degenere", k); next }
    if (!identical(unname(as.numeric(sj["Alpha"])), unname(as.numeric(sd["Alpha"]))))
      alpha_change <- alpha_change + 1L
    if (identical(unname(as.numeric(sj[cles12])), unname(as.numeric(sd[cles12])))) {
      d4[k] <- "identique"; next
    }
    etat <- "tolerance"
    for (nm in cles12) {
      a <- sj[[nm]]; b <- sd[[nm]]
      if (identical(a, b)) next
      tol_ok <- is.finite(a) && is.finite(b) && abs(a - b) <= TOL_DEG * max(1, abs(a)) &&
        identical(indic(a, obs[[nm]], queues[[nm]]), indic(b, obs[[nm]], queues[[nm]]))
      d4_det[[length(d4_det) + 1L]] <- sprintf(
        "rep %d, %s : journal %s, degenere %s, ecart %s : %s", k, nm, f17(a), f17(b),
        f6(abs(a - b)), if (tol_ok) "dans la tolerance (a lire en 2c)" else "HORS TOLERANCE")
      if (!tol_ok) etat <- "echec"
    }
    d4[k] <- etat
  }
  D$D4 <- R > 0L && !any(d4 == "echec")
  sortie("D4 : 12 cles hors Alpha, journal vs triangle de la replication avec C*(i,J) := C*(i,J-1) f*_(J-1), i = 0..I-J :")
  sortie("     identique : ", sum(d4 == "identique"), " ; tolerance (<= 1e-12 relatif, sans bascule) : ",
         sum(d4 == "tolerance"), " ; echec : ", sum(d4 == "echec"), " ; sur |R| = ", R, " : ",
         ok_ko(D$D4))
  if (length(d4_det)) {
    sortie("     detail (au plus 20 lignes) :")
    for (s in head(unlist(d4_det), 20L)) sortie("       ", s)
  }
  sortie("     (info) Alpha : replications dont la valeur change entre journal et triangle degenere : ",
         alpha_change, " / ", R)
  d5_ok <- vapply(fa_l, function(fa) {
    det <- fa$detail
    nrow(det) > 0 && any(det$j == J - 1L & det$n == nJm1)
  }, logical(1))
  sortie("D5 (lecture) : ligne j = J-1 de poids n_{J-1} = ", nJm1,
         " dans mw_famille_alpha(ab)$detail : ", sum(d5_ok), " / ", R, " replications")
  al_coh <- vapply(seq_len(R), function(k)
    identical(unname(as.numeric(jl[[k]]$stats["Alpha"])), unname(as.numeric(fa_l[[k]]$stat))),
    logical(1))
  sortie("     (info) stat de mw_famille_alpha(ab) identique a la valeur Alpha du journal : ",
         sum(al_coh), " / ", R)

  # 9. M1 -----------------------------------------------------------------------
  titre("M1 : part des replications ou la colonne figee reste degeneree (.mw_colonne_degeneree)")
  pi_j <- setNames(rep(NA_real_, length(jd)), jd)
  for (c in seq_along(jd)) {
    j <- jd[c]
    k <- sum(pred[, c]); n <- R
    pi_j[c] <- if (n > 0) k / n else NA_real_
    ci <- if (n > 0) stats::binom.test(k, n)$conf.int else c(NA_real_, NA_real_)
    volet <- ifelse(!pred[, c], "non degeneree",
                    ifelse(is.finite(ecart[, c]) & ecart[, c] <= TOL_DEG, "ecart <= 1e-12",
                           "aplatissement"))
    sortie("j = ", j, if (j == J - 1L) " (= J-1)" else "", " : pi = ", k, "/", n, " = ",
           sprintf("%.4f", pi_j[c]), " ; Clopper-Pearson 95 % [", sprintf("%.4f", ci[1]),
           " ; ", sprintf("%.4f", ci[2]), "]")
    sortie("    volets : ecart <= 1e-12 : ", sum(volet == "ecart <= 1e-12"),
           " ; aplatissement : ", sum(volet == "aplatissement"),
           " ; non degeneree : ", sum(volet == "non degeneree"))
    sortie("    log10(ecart relatif max) : ", quantiles_log10(ecart[, c]))
    sortie("    ecarts non finis : ", sum(!is.finite(ecart[, c])))
  }

  # 10. M2 ---------------------------------------------------------------------
  titre("M2 : famille Alpha avec et sans les colonnes de figes$degeneres")
  sans <- function(det) {
    if (!nrow(det)) return(NA_real_)
    d <- det[!(det$j %in% jd), , drop = FALSE]
    if (!nrow(d)) NA_real_ else sum(d$n * d$amplitude) / sum(d$n)
  }
  fa_obs <- mw_famille_alpha(aj)
  A_obs <- res0$bootstrap$stats_obs$Alpha
  As_obs <- sans(fa_obs$detail)
  sortie("stats_obs$Alpha identique a mw_famille_alpha(aj)$stat : ",
         ok_ko(identical(A_obs, fa_obs$stat)))
  A_star  <- vapply(jl, function(e) unname(as.numeric(e$stats["Alpha"])), numeric(1))
  As_star <- vapply(fa_l, function(fa) sans(fa$detail), numeric(1))
  p_m <- res0$bootstrap$p_mc[["Alpha"]]; err_m <- res0$bootstrap$err_mc[["Alpha"]]
  Be_m <- res0$bootstrap$B_effectif[["Alpha"]]
  pm_re <- engine_p_mc(sb[, "Alpha"], A_obs, "haut")
  mc_s <- engine_p_mc(As_star, As_obs, "haut")
  p_s <- mc_s$p_mc
  dp <- p_m - p_s
  fin_m <- is.finite(A_star); fin_s <- is.finite(As_star)
  N_m <- sum(A_star[fin_m] >= A_obs); N_s <- sum(As_star[fin_s] >= As_obs)
  ind_m <- A_star >= A_obs; ind_s <- As_star >= As_obs
  basc_hs <- sum(ind_m & !ind_s, na.rm = TRUE)       # compte avec, pas sans
  basc_sh <- sum(!ind_m & ind_s, na.rm = TRUE)       # compte sans, pas avec
  sortie("A_obs = ", f17(A_obs), " ; A^sans_obs = ", f17(As_obs))
  sortie("p_moteur (res$bootstrap$p_mc[[\"Alpha\"]]) = ", f17(p_m), " ; err_mc = ", f6(err_m),
         " ; B_eff = ", Be_m, " ; recalcul par engine_p_mc : ", ok_ko(identical(pm_re$p_mc, p_m)))
  sortie("p_sans (engine_p_mc, queue haute) = ", f17(p_s), " ; err_mc = ", f6(mc_s$err_mc),
         " ; B_eff = ", mc_s$B_effectif, if (!is.na(mc_s$motif)) paste0(" ; motif = ", mc_s$motif) else "")
  sortie("Delta p = p_moteur - p_sans = ", f17(dp))
  sortie("N_moteur = #(A* >= A_obs) = ", N_m, " ; N_sans = #(A^sans* >= A^sans_obs) = ", N_s,
         " ; N_moteur - N_sans = ", N_m - N_s)
  sortie("bascules (indicateur de depassement different) : ", basc_hs + basc_sh,
         " (compte avec seulement : ", basc_hs, " ; compte sans seulement : ", basc_sh, ")")
  sortie("(info) propriete exacte p_moteur >= p_sans : ", ok_ko(isTRUE(p_m >= p_s)))
  q <- vapply(fa_l, function(fa) {
    det <- fa$detail
    if (!nrow(det)) return(NA_real_)
    num <- det$n[det$j == J - 1L] * det$amplitude[det$j == J - 1L]
    if (length(num) != 1L) return(NA_real_)
    num / sum(det$n * det$amplitude)
  }, numeric(1))
  qq <- q[is.finite(q)]
  sortie("q_b = n_{J-1} a*_{J-1} / somme n_j a*_j : ", length(qq), " valeurs finies sur ", R,
         " (non finies : denominateur nul ou ligne absente) ; quantiles (type 7) 0, 0.01, 0.5, 0.99, 1 : ",
         if (length(qq)) paste(sprintf("%.6g", stats::quantile(qq, c(0, 0.01, 0.5, 0.99, 1),
                                                                  type = 7, names = FALSE)),
                               collapse = " ; ") else "-")
  ligne_alpha <- tt0[!is.na(tt0$mc_nom) & tt0$mc_nom == "Alpha", , drop = FALSE]
  if (nrow(ligne_alpha))
    sortie("(info) ligne Alpha de engine_table_tests(res0) : verdict = ", ligne_alpha$verdict[1],
           " ; p_retenue = ", f6(ligne_alpha$p_retenue[1]), " ; famille = ", ligne_alpha$famille[1],
           " ; test = ", ligne_alpha$test[1])
  else sortie("(info) ligne Alpha absente de engine_table_tests(res0)")
  e2 <- vapply(ALPHA_NIV, function(s) isTRUE((p_m < s) != (p_s < s)), logical(1))
  sortie("(info) seuils de verdict : ", paste(sprintf("p < %.2f : moteur %s, sans %s -> %s", ALPHA_NIV,
         p_m < ALPHA_NIV, p_s < ALPHA_NIV, ifelse(e2, "de part et d'autre", "meme cote")),
         collapse = " ; "))

  # 11. Issue mecanique (protocole, par. 4.3) ---------------------------------
  titre("Issue mecanique (par. 4.3) pour ce triangle")
  p_ok <- all(unlist(P)); i_ok <- all(unlist(I))
  d_ok <- all(unlist(D))
  pi_crit <- if (est_T0) pi_j else pi_j[as.character(J - 1L)]
  pi_lt1 <- any(pi_crit < 1, na.rm = TRUE) || any(is.na(pi_crit))
  dp_nul <- isTRUE(dp == 0)
  sortie("critere P1 a P6 : ", ok_ko(p_ok), " ; I1 a I5 : ", ok_ko(i_ok),
         " ; D1 a D4 : ", ok_ko(d_ok))
  sortie("critere pi sur ", if (est_T0) "toutes les colonnes figees" else "J-1", " : ",
         paste(sprintf("pi_%s = %s", names(pi_crit), format(pi_crit)), collapse = ", "),
         " (< 1 : ", pi_lt1, ")")
  sortie("critere Delta p = 0 : ", dp_nul, " (Delta p = ", f17(dp), ")")
  note <- ""
  issue <- if (!(p_ok && i_ok)) "sans conclusion"
           else if (!d_ok) "3"
           else if (!dp_nul) { note <- paste0("E3", if (any(e2)) " et E2" else "")
                               "2b" }
           else if (pi_lt1) { if (est_T0) note <- "nuancer \"negligeable\" (pi < 1 sur T0)"
                              "2a" }
           else "1"
  sortie("ISSUE POUR ", nom, " : ", issue, if (nzchar(note)) paste0(" (", note, ")") else "")
  if (issue == "2b") sortie("  (constat ADR 0018 : E3", if (any(e2)) " ; E2 : verdict de part et d'autre d'un seuil" else "", ")")

  list(nom = nom, issue = issue, motif = if (issue == "sans conclusion") "P ou I en echec" else "",
       pi = pi_j, dp = dp, p_m = p_m, p_s = p_s, R = R, D = D, P = P, I = I)
}

# --- Programme principal ------------------------------------------------------
essai <- OPT$B < 999L
sortie("MESURE DE #617 -- JS2, etape 2b -- protocole actuary-1-protocole-617.md, par. 5")
if (essai) sortie("*** ESSAI, NON VERSABLE (B = ", OPT$B, " < 999) ***")
sortie("B = ", OPT$B, " ; graine = ", format(OPT$graine, scientific = FALSE),
       " ; triangles = ", paste(OPT$triangles, collapse = ","))
i5_debut <- controle_i5()
sortie("I5 au depart : md5 de R/engine.R = ", i5_debut$md5, " : ", ok_ko(i5_debut$md5_ok),
       " ; git status vide : ", ok_ko(i5_debut$git_ok))

tris <- construire_triangles()
resultats <- list()
for (nm in OPT$triangles) {
  r <- tryCatch(mesurer(nm, tris[[nm]], OPT$B, OPT$graine),
                error = function(e) {
                  sortie("ERREUR INATTENDUE sur ", nm, " : ", conditionMessage(e))
                  list(nom = nm, issue = "sans conclusion", motif = "erreur inattendue")
                })
  resultats[[nm]] <- r
}

titre("SYNTHESE")
i5_fin <- controle_i5()
sortie("I5 a la fin : md5 de R/engine.R : ", ok_ko(i5_fin$md5_ok), " ; git status vide : ",
       ok_ko(i5_fin$git_ok))
for (nm in names(resultats)) {
  r <- resultats[[nm]]
  sortie(nm, " : issue ", r$issue,
         if (!is.null(r$dp)) paste0(" ; Delta p = ", f6(r$dp), " (p_moteur ", f6(r$p_m),
                                    ", p_sans ", f6(r$p_s), ")") else "",
         if (!is.null(r$pi)) paste0(" ; ", paste(sprintf("pi_%s = %s", names(r$pi), format(r$pi)),
                                                  collapse = ", ")) else "")
}
issues <- vapply(resultats, function(r) r$issue, "")
global <- if (any(issues == "sans conclusion") || !(i5_debut$ok && i5_fin$ok)) {
  "sans conclusion"
} else {
  names(which.max(ISSUE_RANG[issues]))
}
sortie("ISSUE GLOBALE : ", global,
       if (!setequal(OPT$triangles, c("T1", "T2", "T0"))) " (sous-ensemble de triangles : non versable)" else "",
       if (essai) " (ESSAI, NON VERSABLE)" else "")

# --- Pied de sortie -----------------------------------------------------------
titre("PIED")
chemin_script <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])
sha <- tryCatch(system2("git", c("rev-parse", "HEAD"), stdout = TRUE, stderr = FALSE),
                error = function(e) "indisponible")
sortie("duree : ", sprintf("%.1f s", as.numeric(difftime(Sys.time(), T_DEBUT, units = "secs"))))
sortie(R.version.string)
sortie("RNGkind() : ", paste(RNGkind(), collapse = ", "))
sortie("git rev-parse HEAD : ", paste(sha, collapse = " "))
sortie("md5 R/engine.R : ", unname(tools::md5sum("R/engine.R")))
sortie("md5 R/charger_moteur.R : ", unname(tools::md5sum("R/charger_moteur.R")))
sortie("md5 mesure_617.R : ", if (is.na(chemin_script) || !file.exists(chemin_script)) "indisponible"
                               else unname(tools::md5sum(chemin_script)))
