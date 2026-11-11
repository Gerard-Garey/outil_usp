###############################################################################
#  tests/unitaires/test_merz_wuthrich_suite.R  --  METHODE DU RISQUE DE RESERVE
#  No 2 : SUITE DE test_merz_wuthrich.R (issue #512)
#
#  Seconde moitie de l'ancien test_merz_wuthrich.R (a partir de la section
#  " Colonnes degenerees exclues des residus de Mack (issue #60) "), separee
#  pour repartir la batterie sur plusieurs jobs de la CI en deux fichiers
#  d'environ meme duree. Les assertions sont celles de l'ancien fichier, sans
#  changement ni doublon, sauf la refonte du test calendaire (#512, avis
#  d'actuary du 08/11/2026) ; les references sont celles de test_merz_wuthrich.R.
#  Le preambule ci-dessous reprend, a l'identique, les seules definitions de la
#  premiere moitie dont cette suite a besoin (triangles, ajustements, aides).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_merz_wuthrich_suite.R")

## --- Preambule : definitions reprises de test_merz_wuthrich.R ---------------
tri <- matrix(NA_real_, 5, 5)
tri[1, ] <- c(100, 150, 180, 190, 195)
tri[2, 1:4] <- c(110, 160, 190, 200)
tri[3, 1:3] <- c(120, 185, 220)
tri[4, 1:2] <- c(130, 200)
tri[5, 1] <- 140
aj <- mw_ajuster(tri)
tri_deg <- matrix(NA_real_, 6, 6)
tri_deg[1, ] <- c(1000, 1600, 1800, 1800, 1830, 1835)
tri_deg[2, 1:5] <- c(1100, 1815, 2000, 2000, 2050)
tri_deg[3, 1:4] <- c(900, 1395, 1580, 1580)
tri_deg[4, 1:3] <- c(1200, 1980, 2210)
tri_deg[5, 1:2] <- c(1050, 1638)
tri_deg[6, 1]   <- 980
tri_sym <- matrix(NA_real_, 6, 6)
tri_sym[1, ] <- c(1000, 1600, 1800, 1900, 1938, 1945)
tri_sym[2, 1:5] <- c(1100, 1815, 2000, 2150, 2193)
tri_sym[3, 1:4] <- c(900, 1395, 1580, 1650)
tri_sym[4, 1:3] <- c(1200, 1980, 2210)
tri_sym[5, 1:2] <- c(1050, 1638)
tri_sym[6, 1]   <- 980
av_exclues <- function(av) grep(paste0("a facteurs individuels egaux a f_j a la tolerance ",
                                       "relative 1e-12 de l'outil (",
                                       .MW_PREDICAT_DEGENERE_TEXTE,
                                       " ; sigma2_j nul ou numeriquement nul)"), av,
                                fixed = TRUE, value = TRUE)
run_mw <- function(t) run_engine(methode = "reserve2", triangle = t,
                                 segment = 1, annexe = "II", B = 99)
av_extrap <- function(r) grep("sigma2_(J-1) = min", r$validation$avertissements,
                              fixed = TRUE, value = TRUE)
detail_m6 <- function(r) {
  d <- engine_table_tests(r)
  d$commentaire[grepl("Extrapolation de sigma", d$test)]
}
ta <- matrix(c(357848, 352118, 290507, 310608, 443160, 396132, 440832, 359480, 376686, 344014,
  1124788, 1236139, 1292306, 1418858, 1136350, 1333217, 1288463, 1421128, 1363294, NA,
  1735330, 2170033, 2218525, 2195047, 2128333, 2180715, 2419861, 2864498, NA, NA,
  2218270, 3353322, 3235179, 3757447, 2897821, 2985752, 3483130, NA, NA, NA,
  2745596, 3799067, 3985995, 4029929, 3402672, 3691712, NA, NA, NA, NA,
  3319994, 4120063, 4132918, 4381982, 3873311, NA, NA, NA, NA, NA,
  3466336, 4647867, 4628910, 4588268, NA, NA, NA, NA, NA, NA,
  3606286, 4914039, 4909315, NA, NA, NA, NA, NA, NA, NA,
  3833515, 5339085, NA, NA, NA, NA, NA, NA, NA, NA,
  3901463, NA, NA, NA, NA, NA, NA, NA, NA, NA), 10, 10)
at <- mw_ajuster(ta)
boot_mw_fictif <- local({
  s <- .mw_stats(at)
  p <- stats::setNames(rep(0.5, length(s)), names(s))
  list(stats_obs = as.list(s), p_mc = p, err_mc = p * 0 + 0.01,
       B = 999, B_effectif = p * 0 + 999, cumuls_retires = FALSE, plafond_cumuls = FALSE)
})
mw_tests_modifie <- function(avant, apres) {
  txt <- paste(deparse(mw_tests), collapse = "\n")
  if (!grepl(avant, txt, fixed = TRUE)) stop("motif absent du corps de mw_tests : ", avant)
  f <- eval(parse(text = sub(avant, apres, txt, fixed = TRUE)))
  environment(f) <- environment(mw_tests)
  f
}
ta_deg <- ta
ta_deg[1:5, 6] <- 1.05 * ta[1:5, 5]
ta_bruit <- ta_deg
ta_bruit[1:5, 6] <- ta_deg[1:5, 6] * (1 + c(1, -1, 1, -1, 1) * 1e-14)
tri_ref <- local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
nb_warnings_mw <- function(t) {
  n <- 0L
  withCallingHandlers(run_engine(methode = "reserve2", triangle = t, segment = 1,
                                 annexe = "II", B = 99),
                      warning = function(w) { n <<- n + 1L; invokeRestart("muffleWarning") })
  n
}
ta_pert <- function(eps) {
  t <- ta_deg
  t[1:5, 6] <- ta_deg[1:5, 6] * (1 + c(1, -1, 1, -1, 1) * eps)
  t
}
f192 <- mw_ajuster(tri_ref)$f
tri192 <- function(c0, f) {
  n <- length(c0); t <- matrix(NA_real_, n, n); t[, 1] <- c0
  for (i in 1:(n - 1)) for (j in 2:(n - i + 1)) t[i, j] <- t[i, j - 1] * f[j - 1]
  t
}
total_exact <- tri192(tri_ref[, 1], f192)
total_f_binaire <- tri192(c(256, 300, 320, 336, 344, 352, 360, 384),
                          c(2, 1.5, 1.25, 1.125, 1.0625, 1.03125, 1.015625))
col0_192 <- function(eps) {
  t <- total_exact; t[, 1] <- t[, 1] * (1 + rep(c(1, -1), 4) * eps); t
}
sauf_une <- total_exact
sauf_une[, 2] <- tri_ref[, 2]
for (i in 1:6) for (j in 3:(9 - i)) sauf_une[i, j] <- sauf_une[i, j - 1] * f192[j - 1]
total_arrondi <- round(total_exact, 2)
acceptes192 <- list(col0_1e11 = col0_192(1e-11), sauf_une = sauf_une,
                    total_arrondi = total_arrondi)
fragments192 <- c("Triangle totalement degenere : pour chaque annee de developpement j = 0..J-2",
                  paste0("(a la tolerance relative 1e-12 de l'outil pres : ",
                         .MW_PREDICAT_DEGENERE_TEXTE, ")"),
                  "Pour des facteurs exactement egaux, en arithmetique exacte, sigma2_j = 0 (annexe XVII, D(5)(d)(ii)) et MSEP = 0 ; ici sigma2_j et la MSEP (valeur calculee : ",
                  ") sont nuls ou negligeables a la tolerance de l'outil (residus d'arrondi ou ecarts relatifs entre facteurs de l'ordre de 1e-12), aucun residu de Mack n'est retenu",
                  "par D(4), sigma(res,s,USP) = (1 - c) * sigma(res,s) a un ecart negligeable pres, sans contribution significative des donnees.",
                  "(D(2)(h), en particulier iv : variance proportionnelle au cumul precedent)",
                  "representativite du risque de reserve (D(2)(a))",
                  "article 219, paragraphe 1, point d)",
                  "L'outil n'applique donc pas a ce triangle la methode du risque de reserve no 2 (article 220, paragraphe 1, point b)).",
                  "paiements cumules observes (D(1))")
motif192 <- function(e) length(e) == 1L &&
  all(vapply(fragments192, grepl, logical(1), x = e, fixed = TRUE)) &&
  !grepl("0/0", e, fixed = TRUE)

## --- Colonnes degenerees exclues des residus de Mack (issue #60) ------------
# Decision du mainteneur du 05/10/2026 (Q-E2r-60-1, variante (b)) :
# mw_residus() ecarte une colonne sur le predicat .mw_colonne_degeneree()
# (#56) et non plus sur sigma2_j = 0 exact ; l'ensemble des colonnes
# degenerees est fige au triangle observe par mw_bootstrap() et transmis aux
# residus de chaque replication (contexte .mw_contexte_mc(), ExpVar,
# KruskalAcc). Predicat etendu (constat C1 de l'audit de #152) : colonne
# rendue constante par l'aplatissement des ex aequo en plancher 0.
verifier("ta_bruit : colonne j = 4 exclue des residus (39 retenus, comme ta_deg), avertissement emis (#60)",
         {
           ok <- vapply(list(ta_deg, ta_bruit), function(t) {
             a <- mw_ajuster(t); rs <- mw_residus(a)
             av <- av_exclues(mw_valider_ajustement(a, mw_msep(a)$msep)$avertissements)
             nrow(rs) == 39L && !any(rs$j == 4) &&
               identical(attr(rs, "colonnes_exclues")$j, 4L) &&
               length(av) == 1 && grepl("j = 4 (5 facteurs)", av, fixed = TRUE) &&
               grepl("Le pool de reechantillonnage du bootstrap ne contient que les residus retenus",
                     av, fixed = TRUE)
           }, logical(1))
           # garde : sigma2_4 de ta_bruit est strictement positif (bruit d'arrondi)
           mw_ajuster(ta_bruit)$sigma2[5] > 0 && all(ok)
         })
verifier("mw_residus(aj, j_degeneres) : ensemble fourni prioritaire, NULL = ensemble calcule sur aj (#60)",
         {
           a <- mw_ajuster(ta); ad <- mw_ajuster(ta_deg)
           r1 <- mw_residus(a, j_degeneres = 4L)            # colonne non degeneree, figee
           r2 <- mw_residus(ad, j_degeneres = integer(0))   # sigma2_4 = 0 : exclue quand meme
           identical(mw_residus(ad), mw_residus(ad, .mw_colonnes_degenerees(ad))) &&
             identical(mw_residus(a), mw_residus(a, .mw_colonnes_degenerees(a))) &&
             !any(r1$j == 4) && identical(attr(r1, "colonnes_exclues")$j, 4L) &&
             !any(r2$j == 4) && identical(attr(r2, "colonnes_exclues")$j, 4L)
         })
# Rejeu de la boucle de mw_bootstrap() : nombre de residus du contexte de
# chaque replication (ensemble fige), a comparer a l'observe.
n_res_replications <- function(t, B = 99, seed = 20260831) {
  aj <- mw_ajuster(t); jd <- .mw_colonnes_degenerees(aj); n <- rep(NA_integer_, B)
  engine_sous_graine(seed, {
    pool <- .mw_pool_residus(aj, jd)   # pool de mw_bootstrap() (#46)
    # retirage et plafond de mw_bootstrap() (#257), fonction partagee
    n_max <- FACTEUR_B_MAX_MW * (B + 1); n_tir <- 0
    for (b in seq_len(B)) {
      tir <- .mw_tirer_triangle_valide(aj, pool, n_max - n_tir)
      n_tir <- n_tir + tir$n
      if (is.null(tb <- tir$tri)) next
      ab <- try(mw_ajuster(tb), silent = TRUE)
      if (inherits(ab, "try-error")) next
      n[b] <- nrow(.mw_contexte_mc(ab, .mw_ensembles_figes(ab, jd))$res)
    }
  })
  list(obs = nrow(mw_residus(aj)), n = n)
}
verifier("Bootstrap : meme nombre de residus a l'observe et dans chaque replication (ta_deg, tri_sym ; #60)",
         all(vapply(list(ta_deg, tri_sym), function(t) {
           m <- n_res_replications(t)
           any(!is.na(m$n)) && all(is.na(m$n) | m$n == m$obs)
         }, logical(1))))
# Critere conjoint #60 + #152 (specification (c) 3 et 4), B = 99 ici ; mesure
# aussi a B = 999 (compte rendu de #60). Tolerance 1e-6 (TOLERANCE des
# references).
tables_mw60 <- local({
  cache <- list()
  function(nm, t) {
    if (is.null(cache[[nm]])) cache[[nm]] <<- engine_table_tests(run_mw(t))
    cache[[nm]]
  }
})
memes_p <- function(d1, d2) {
  p1 <- d1$p_retenue; p2 <- d2$p_retenue
  identical(d1$test, d2$test) && identical(d1$verdict, d2$verdict) &&
    identical(is.na(p1), is.na(p2)) &&
    isTRUE(all(abs(p1 - p2)[!is.na(p1)] <= 1e-6 * pmax(1, abs(p1[!is.na(p1)]))))
}
verifier("run_engine : ta_deg et ta_bruit, memes verdicts et memes p retenues (#60 avec #152)",
         memes_p(tables_mw60("ta_deg", ta_deg), tables_mw60("ta_bruit", ta_bruit)))
verifier("run_engine : ta_deg perturbe a 4e-13 (colonne j = 4 degeneree), p-values de ta_deg (#60, gel)",
         {
           t4 <- ta_pert(4e-13); a4 <- mw_ajuster(t4)
           d0 <- tables_mw60("ta_deg", ta_deg); d4 <- tables_mw60("ta_4e13", t4)
           .mw_ecart_facteurs(a4, 4L)$ecart > 0 && 4L %in% .mw_colonnes_degenerees(a4) &&
             memes_p(d0, d4) &&
             identical(d0$p_monte_carlo, d4$p_monte_carlo)
         })
# Extension du gel a CorrDev et Calendrier (#60, decision Q-E2r-60-1 (b)
# etendue par le mainteneur le 06/10/2026) : mw_stat_correlation_dev() et
# mw_test_annees_calendaires() recoivent l'ensemble fige j_degeneres.
verifier("CorrDev, Calendrier : j_degeneres NULL = ensemble de aj ; colonne figee hors statistique (#60)",
         {
           a <- mw_ajuster(ta); ad <- mw_ajuster(ta_deg)
           cd <- mw_stat_correlation_dev(a, j_degeneres = 4L)
           ca <- mw_test_annees_calendaires(a, j_degeneres = 4L)
           identical(mw_stat_correlation_dev(ad), mw_stat_correlation_dev(ad, .mw_colonnes_degenerees(ad))) &&
             identical(mw_test_annees_calendaires(ad),
                       mw_test_annees_calendaires(ad, .mw_colonnes_degenerees(ad))) &&
             # paires (3, 4) et (4, 5) exclues : deux paires de moins que sans gel
             length(cd$T) == length(mw_stat_correlation_dev(a, integer(0))$T) - 2L &&
             all(ca$etiquettes$lab[ca$etiquettes$j == 4] == "*") &&
             any(mw_test_annees_calendaires(a, integer(0))$etiquettes$lab[ca$etiquettes$j == 4] != "*")
         })
# Rejeu de la boucle de mw_bootstrap() (B = 99, graine 20260831) : statistiques
# Calendrier et CorrDev repliquees, ta_deg contre sa perturbation a 4e-13.
# Avant le gel (2a3e3f0), elles different aux replications b = 28, 63, 83
# (CorrDev) et b = 83 (Calendrier) ; a B = 999, 30 et 8 replications, sans
# changer les p_mc (mesure du compte rendu de #60, extension du 06/10/2026).
# Pool tire dans .mw_pool_residus(aj, jd), comme mw_bootstrap() (#46) : le
# rejeu suit le pool du moteur sans copie a synchroniser.
stats_cal_cor <- function(t, B = 99, seed = 20260831) {
  aj <- mw_ajuster(t); jd <- .mw_colonnes_degenerees(aj)
  S <- matrix(NA_real_, B, 2, dimnames = list(NULL, c("Calendrier", "CorrDev")))
  engine_sous_graine(seed, {
    pool <- .mw_pool_residus(aj, jd)
    # retirage et plafond de mw_bootstrap() (#257), fonction partagee
    n_max <- FACTEUR_B_MAX_MW * (B + 1); n_tir <- 0
    for (b in seq_len(B)) {
      tir <- .mw_tirer_triangle_valide(aj, pool, n_max - n_tir)
      n_tir <- n_tir + tir$n
      if (is.null(tb <- tir$tri)) next
      ab <- try(mw_ajuster(tb), silent = TRUE)
      if (inherits(ab, "try-error")) next
      S[b, ] <- .mw_stats(ab, .mw_ensembles_figes(ab, jd))[colnames(S)]
    }
  })
  S
}
verifier("Bootstrap : Calendrier et CorrDev repliquees identiques, ta_deg contre perturbation a 4e-13 (#60, gel)",
         {
           s0 <- stats_cal_cor(ta_deg); s4 <- stats_cal_cor(ta_pert(4e-13))
           sum(!is.na(s0)) > 150 && identical(is.na(s0), is.na(s4)) &&
             isTRUE(all(abs(s0 - s4) <= 1e-9 * pmax(1, abs(s0)), na.rm = TRUE))
         })
# Triangle a facteurs binaires (#192) dont seule la colonne j = 5 est rendue
# non degeneree (C(0,6) x 1,01, ligne 0 repropagee) : accepte, pool de deux
# residus (cas bin_pert_j5 d'actuary, specification de #192, Q3).
bin_pert_j5 <- local({
  m <- total_f_binaire; m[1, 7] <- m[1, 7] * 1.01
  m[1, 8] <- m[1, 7] * (total_f_binaire[1, 8] / total_f_binaire[1, 7]); m
})
verifier("bin_pert_j5 : accepte, mw_residus() non vide (2 residus, colonne j = 5), aucun avertissement R (#60)",
         {
           a <- mw_ajuster(bin_pert_j5); rs <- mw_residus(a)
           nw <- 0L
           r <- withCallingHandlers(run_mw(bin_pert_j5),
                                    warning = function(w) { nw <<- nw + 1L
                                      invokeRestart("muffleWarning") })
           identical(.mw_colonnes_degenerees(a), c(0:4, 6L)) &&
             nrow(rs) == 2L && all(rs$j == 5L) &&
             isTRUE(r$ok) && is.null(r$validation$erreur_r) && nw == 0L
         })
# Constat C1 de l'audit de #152 : colonne 0 a facteurs 1,5 (1 + 0,9e-12 k),
# k = 0..6 : ecart relatif a f_0 superieur a 1e-12, mais facteurs aplatis
# tous egaux (pas adjacent 0,9e-12 < 1e-12). Avant #60 : non degeneree,
# rho = NA silencieux dans HomogF et K variable entre observe et
# replications ; residus de bruit d'arrondi gardes.
tri_c1 <- local({
  t <- matrix(NA_real_, 8, 8)
  t[, 1] <- c(1000, 1200, 900, 1500, 1100, 1300, 1250, 950)
  fac0 <- 1.5 * (1 + (0:6) * 0.9e-12)
  for (i in 1:7) t[i, 2] <- t[i, 1] * fac0[i]
  fac <- list(NULL, c(1.10, 1.12, 1.08, 1.15, 1.09, 1.11), c(1.05, 1.04, 1.06, 1.03, 1.07),
              c(1.02, 1.03, 1.01, 1.025), c(1.010, 1.008, 1.012), c(1.005, 1.003), 1.002)
  for (j in 2:7) for (i in 1:(8 - j)) t[i, j + 1] <- round(t[i, j] * fac[[j]][i], 2)
  t
})
verifier("Colonne aplatie constante (C1) : degeneree, exclue de HomogF et des residus, sans rho = NA (#60)",
         {
           a <- mw_ajuster(tri_c1); jd <- .mw_colonnes_degenerees(a)
           h <- mw_test_homogeneite_f(a); rs <- mw_residus(a)
           # replications : K = 3 dans chacune, aucune p nulle (avant #90 :
           # Spearman asymptotique a rho = +-1 pour n = 4 rendait p = 0, ecartee
           # par .fisher_combine(), d'ou K = 2 dans 5 replications sur 99),
           # aucun rho = NA
           kk <- integer(0); nna <- 0L; np0 <- 0L
           engine_sous_graine(20260831, {
             pool <- .mw_pool_residus(a, jd)   # pool de mw_bootstrap() (#46)
             # retirage et plafond de mw_bootstrap() (#257), fonction partagee
             n_max <- FACTEUR_B_MAX_MW * (99 + 1); n_tir <- 0
             for (b in 1:99) {
               tir <- .mw_tirer_triangle_valide(a, pool, n_max - n_tir)
               n_tir <- n_tir + tir$n
               if (is.null(tb <- tir$tri)) next
               ab <- try(mw_ajuster(tb), silent = TRUE)
               if (inherits(ab, "try-error")) next
               hb <- mw_test_homogeneite_f(ab, jd)
               if (is.null(hb$K)) next
               kk <- c(kk, hb$K); nna <- nna + sum(is.na(hb$detail$rho))
               np0 <- np0 + sum(hb$detail$p == 0)
             }
           })
           .mw_ecart_facteurs(a, 0L)$ecart > 1e-12 && .mw_colonne_degeneree(a, 0L) &&
             identical(jd, c(0L, a$J - 1L)) &&
             identical(h$exclues$j, 0L) && h$K == 3 && !anyNA(h$detail$rho) &&
             !any(rs$j == 0) && length(kk) > 0 && all(kk == 3L) && nna == 0L && np0 == 0L
         })
verifier("Exposant de variance : colonne a |r| constants ecartee (aucun rho = NA) (#60)",
         {
           # colonne j = 0 : F = 1,5 + s / racine(C), signes s = (+, -, -, +),
           # racines 10, 20, 30, 40 : somme s racine(C) = 0, donc f_0 = 1,5 et
           # |r(i,0)| tous egaux
           tr <- matrix(NA_real_, 5, 5)
           tr[, 1] <- c(100, 400, 900, 1600, 2500)
           tr[1:4, 2] <- tr[1:4, 1] * (1.5 + c(1, -1, -1, 1) / sqrt(tr[1:4, 1]))
           fs <- list(c(1.20, 1.25, 1.22), c(1.05, 1.08), 1.02)
           for (j in 2:4) for (i in 1:(5 - j)) tr[i, j + 1] <- tr[i, j] * fs[[j - 1]][i]
           a <- mw_ajuster(tr); rs <- mw_residus(a); ev <- mw_test_exposant_variance(a)
           r0 <- abs(rs$residu[rs$j == 0])
           length(r0) == 4L && length(unique(engine_aplatir_ex_aequo(r0))) == 1L &&
             !(0 %in% ev$detail$j) && !anyNA(ev$detail$rho)
         })
verifier("Aucun avertissement R de run_engine(reserve2) : ta_bruit, tri_c1, t5 (#60)",
         {
           t5 <- tri_sym
           t5[1, 4] <- 1760.07; t5[2, 4] <- 2554.89
           t5[1, 5] <- 1760.07 * 1.187; t5[2, 5] <- 2554.89 * 1.187
           t5[1, 6] <- t5[1, 5] * 1.003
           n <- vapply(list(ta_bruit = ta_bruit, tri_c1 = tri_c1, t5 = t5), nb_warnings_mw, integer(1))
           if (all(n == 0L)) TRUE
           else paste("avertissements R :", paste(names(n), n, sep = " = ", collapse = ", "))
         })

## --- Enonce du predicat, frontiere de la fenetre C1, KruskalAcc, variance
## unitaire (issue #60, decisions du mainteneur du 06/10/2026) ---------------
# R1 (constat C1-a) : une seule chaine .MW_PREDICAT_DEGENERE_TEXTE, nommant
# les deux volets du predicat, reprise par l'avertissement des colonnes
# exclues, le motif de #192 et la phrase d'exclusion de M1.
# R2 (constat C1-b, refus garde) : total_exact dont la colonne 0 est chainee
# par pas relatif de 9e-13 (ecart a f_0 ~ 2,8e-12 > 1e-12, mais facteurs que
# l'aplatissement rend tous egaux) est refuse ; par pas de 1,5e-12 (ecart
# ~ 4,7e-12, chaine rompue), il est accepte.
c1b <- function(pas) {
  t <- total_exact; n <- nrow(t); fac <- f192[1] * (1 + (0:(n - 2)) * pas)
  for (i in 1:(n - 1)) {
    t[i, 2] <- t[i, 1] * fac[i]
    if (n - i + 1 >= 3) for (j in 3:(n - i + 1)) t[i, j] <- t[i, j - 1] * f192[j - 1]
  }
  t
}
verifier("Enonce unique du predicat dans l'avertissement, le motif #192 et la phrase de M1 (#60, C1-a)",
         {
           a <- mw_ajuster(ta_bruit)
           av <- av_exclues(mw_valider_ajustement(a, mw_msep(a)$msep)$avertissements)
           ar <- mw_ajuster(total_exact)
           er <- mw_valider_ajustement(ar, mw_msep(ar)$msep)$erreurs
           d <- engine_table_tests(run_mw(ta_bruit))$commentaire
           ph <- d[grepl("Colonne degeneree", d, fixed = TRUE)]
           length(av) == 1L && motif192(er) && length(ph) >= 3L &&
             all(grepl(.MW_PREDICAT_DEGENERE_TEXTE, ph, fixed = TRUE)) &&
             any(grepl("ordonnee a l'origine nulle pour des facteurs exactement egaux", ph,
                       fixed = TRUE)) &&
             any(grepl("terme quadratique nul pour des facteurs exactement egaux", ph,
                       fixed = TRUE)) &&
             !any(grepl("1e-12 pres en relatif", c(av, er, ph), fixed = TRUE))
         })
verifier("Frontiere C1-b : colonne 0 chainee par 9e-13 refusee (#192), par 1,5e-12 acceptee (#60)",
         {
           t9 <- c1b(0.9e-12); t15 <- c1b(1.5e-12)
           a9 <- mw_ajuster(t9); a15 <- mw_ajuster(t15)
           e9 <- .mw_ecart_facteurs(a9, 0L)$ecart; e15 <- .mw_ecart_facteurs(a15, 0L)$ecart
           r9 <- run_mw(t9); r15 <- run_mw(t15)
           e9 > 1e-12 && e9 < 6e-12 && e15 > 1e-12 &&
             isTRUE(.mw_colonne_degeneree(a9, 0L)) && isFALSE(.mw_colonne_degeneree(a15, 0L)) &&
             identical(r9$ok, FALSE) && motif192(r9$validation$erreurs) &&
             isTRUE(r15$ok) &&
             !any(grepl("Triangle totalement degenere", r15$validation$erreurs, fixed = TRUE))
         })
# R3 (Q3) et R5 : col0_1e11 et sauf_une ne gardent de residus que dans la
# colonne j = 0, un par annee de survenance i = 0..6.
verifier("KruskalAcc : un residu par annee de survenance -> H = N - 1, p asymptotique NA (#60, Q3)",
         all(vapply(list(col0_192(1e-11), sauf_une), function(t) {
           a <- mw_ajuster(t); rs <- mw_residus(a); k <- mw_test_homogeneite_accident(a)
           l <- engine_table_tests(run_mw(t))
           l <- l[l$test == "Homogeneite des residus entre annees de survenance", ]
           nrow(rs) == 7L && length(unique(rs$i)) == 7L &&
             isTRUE(proche(k$stat, nrow(rs) - 1, rel = 1e-12)) && is.na(k$p) &&
             nrow(l) == 1L && is.na(l$p_asymptotique) && is.na(l$p_retenue) &&
             identical(l$verdict, "INFO") && isTRUE(k$un_par_annee) &&
             l$type == "diagnostic" &&
             identical(l$loi_sous_H0, "degeneree : H = N - 1 par construction") &&
             grepl("H = N - 1 par construction", l$commentaire, fixed = TRUE) &&
             grepl("loi simulee de dispersion nulle", l$commentaire, fixed = TRUE)
         }, logical(1))) &&
           # temoin : plusieurs residus par annee, p asymptotique definie
           local({ k <- mw_test_homogeneite_accident(mw_ajuster(tri_ref))
                   is.finite(k$p) && identical(k$un_par_annee, FALSE) }))
# Detail complet de la ligne, un residu par annee de survenance (#449) : la
# phrase generale (qui dit que la ligne teste l'homogeneite) est remplacee,
# non precedee, par la phrase du cas ; le prefixe du motif Monte-Carlo (loi simulee de
# dispersion nulle) reste en tete, pose par add(), sans phrase finale (B
# effectif = B, aucun triangle simule retire).
verifier("KruskalAcc : un residu par annee -> detail complet de la ligne = prefixe du motif Monte-Carlo + phrase du cas seule, phrase generale remplacee (#449)",
         all(vapply(list(col0_192(1e-11), sauf_une), function(t) {
           l <- Filter(function(l) identical(l$test, "Homogeneite des residus entre annees de survenance"),
                       run_mw(t)$tests)
           # Texte de #514 (specification finale d'actuary) : phrase du cas, puis
           # lignes liees.
           length(l) == 1L && identical(l[[1]]$detail, paste(
             "loi simulee de dispersion nulle : aucune p-value retenue.",
             "Un residu de Mack par annee de survenance : H = N - 1 par construction, la",
             "ligne ne mesure rien ici (ni homogeneite entre annees, ni independance de",
             "D(2)(h)(i)). A lire avec \"Homogeneite de f_j entre annees de survenance\" et",
             "\"Effets d'annee calendaire (test de Mack)\".")) &&
             !grepl("Homogeneite des residus entre annees de survenance sous", l[[1]]$detail, fixed = TRUE)
         }, logical(1))))
# Type, H0 et H1 de la ligne (#469, avis amont d'actuary sur K3, section 2,
# point 2 ; decision du mainteneur) : un residu par annee -> diagnostic pose
# par mw_tests(), H0 et H1 "sans objet", nom inchange, verdict INFO, non
# inoperant, p_min_mc NA ; temoin tri_ref : test, textes d'origine.
verifier("KruskalAcc : un residu par annee -> diagnostic, H0 et H1 sans objet ; plusieurs residus -> test, textes d'origine (#469)",
         {
           kr <- function(t) Filter(function(l) identical(l$test,
             "Homogeneite des residus entre annees de survenance"), run_mw(t)$tests)[[1]]
           un <- vapply(list(col0_192(1e-11), sauf_une), function(t) {
             l <- kr(t)
             identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
               identical(l$H0, paste("sans objet : un residu de Mack par annee de survenance,",
                                     "H = N - 1 par construction")) &&
               identical(l$H1, "sans objet") && identical(l$inoperant, FALSE) &&
               is.na(l$p_min_mc) && is.na(l$p_retenue)
           }, logical(1))
           l0 <- kr(tri_ref)
           all(un) && identical(l0$type, "test") && l0$verdict %in% c("OK", "ALERTE", "ECHEC") &&
             identical(l0$H0, "les residus de Mack ont la meme distribution dans toutes les lignes") &&
             identical(l0$H1, "au moins une annee de survenance se comporte differemment")
         })
verifier("Variance unitaire : 'et NON 1' omis si une seule colonne garde des residus (k = 1) (#60, R5)",
         {
           com <- function(t) {
             d <- engine_table_tests(run_mw(t))
             d$commentaire[d$test == "Variance unitaire des residus de Mack"]
           }
           c1 <- vapply(list(col0_192(1e-11), sauf_une), com, character(1))
           cr <- com(tri_ref)
           # Libelle de #514 (specification finale d'actuary) ; N - k est dans la
           # fiche.
           all(startsWith(c1, "Grandeur contrainte par construction (reference 1), qui ne")) &&
             !any(grepl("NON 1", c1, fixed = TRUE)) &&
             grepl("^Grandeur contrainte par construction \\(reference [0-9.]+, et NON 1\\), qui ne", cr)
         })

# Messages M6 dans la fenetre C1 (#60, decision du mainteneur du 06/10/2026,
# constat C1 de l'audit) : tri_ref, ligne 0 multipliee par 1000 (poids
# concentre), colonne J-3 chainee par pas relatif de 0,95e-12 autour de
# 1,05 (ecart a f_j mesure 1,9e-12 > 1e-12, colonne degeneree par le second
# volet du predicat), colonnes suivantes a 1,01 (la colonne J-2 est donc
# aussi degeneree, a ecart nul : l'enonce du predicat doit figurer une seule
# fois pour les deux colonnes). Construction de l'audit.
tri_m6c1 <- local({
  t <- tri_ref; n <- nrow(t); a0 <- mw_ajuster(t); j <- a0$J - 3L; nf <- a0$I - j
  t[1, ] <- t[1, ] * 1000
  fac <- 1.05 * (1 + (0:(nf - 1)) * 0.95e-12)
  for (i in 1:nf) {
    t[i, j + 2] <- t[i, j + 1] * fac[i]
    if (j + 3 <= n - i + 1) for (k in (j + 3):(n - i + 1)) t[i, k] <- t[i, k - 1] * 1.01
  }
  t
})
verifier("Messages M6 en fenetre C1 : predicat enonce une fois, plus de 'tous egaux' (#60)",
         {
           a <- mw_ajuster(tri_m6c1); j <- a$J - 3L
           r <- run_mw(tri_m6c1); av <- av_extrap(r); l <- detail_m6(r)
           # "tous egaux" hors de l'enonce du predicat lui-meme ("rend tous egaux")
           hors <- function(x) gsub(.MW_PREDICAT_DEGENERE_TEXTE, "", x, fixed = TRUE)
           .mw_ecart_facteurs(a, j)$ecart > 1e-12 && isTRUE(.mw_colonne_degeneree(a, j)) &&
             isTRUE(r$ok) && length(av) == 1L &&
             lengths(regmatches(av, gregexpr(.MW_PREDICAT_DEGENERE_TEXTE, av,
                                             fixed = TRUE))) == 1L &&
             grepl("au sens de ce predicat (ecart relatif maximal", av, fixed = TRUE) &&
             grepl(", colonnes J-3 et J-2 degenerees : voir l'avertissement sur les donnees.",
                   l, fixed = TRUE) &&
             !any(grepl("tous egaux", hors(c(r$validation$avertissements, l)), fixed = TRUE))
         })

## --- p-values de Spearman de HomogF et d'ExpVar, combinaison de Fisher (#90) ---
# Avant #90 : cor.test(exact = FALSE) rendait p = 0 a |rho| = 1 (n = 4) et
# .fisher_combine() ecartait la colonne sans le dire ; K variait entre
# l'observe et les replications. Decisions du mainteneur du 06/10/2026 :
# HomogF et ExpVar, .fisher_combine() compris.
verifier(".mw_spearman_p : 1/12 a n = 4, 2/10! a n = 10, |rho| = 1 (#90)",
         {
           identical(.mw_spearman_p(1:4, 4:1), 1 / 12) &&
             identical(.mw_spearman_p(1:10, 10:1), 2 / factorial(10)) &&
             identical(.mw_spearman_p(1:10, 1:10), 2 / factorial(10))
         })
verifier(".mw_spearman_p = cor.test(exact = TRUE) a n <= 9 sans ex aequo (#90)",
         {
           ok <- engine_sous_graine(20261006, vapply(1:500, function(k) {
             n <- sample(4:9, 1); a <- stats::rnorm(n); b <- sample(n)
             identical(.mw_spearman_p(a, b),
                       stats::cor.test(a, b, method = "spearman", exact = TRUE)$p.value)
           }, logical(1)))
           all(ok)
         })
verifier(".mw_spearman_p jamais nulle, dans [2/n!, 1], avec ex aequo ou n > 9 (#90)",
         {
           ok <- engine_sous_graine(20261006, vapply(1:500, function(k) {
             n <- sample(4:30, 1); a <- round(stats::rnorm(n), 1); b <- sample(n)
             a[1:2] <- a[1]                       # au moins un ex aequo dans a
             p <- .mw_spearman_p(a, b); p >= 2 / factorial(n) && p <= 1
           }, logical(1)))
           # ex aequo a la tolerance dans b (plancher 0) : b aplati, loi
           # conditionnelle aux rangs moyens de b aplati (#207 ; cor.test() sur
           # b brut, sans ex aequo au bit pres, enumererait une autre loi)
           b <- c(1, 1 * (1 + 1e-14), 2, 3, 4, 5); a <- c(2, 1, 4, 3, 5, 6)
           p <- .mw_spearman_p(a, b, plancher_b = 0)
           all(ok) && identical(p, .mw_spearman_loi_rangs(a, c(1, 1, 2, 3, 4, 5))$p) &&
             !identical(p, stats::cor.test(a, b, method = "spearman", exact = TRUE)$p.value)
         })
verifier(".fisher_combine : aucune exclusion, p = 0 au plancher, p non finie -> NA, K constant (#90)",
         {
           f0 <- .fisher_combine(c(0, 0.5)); fn <- .fisher_combine(c(0.2, NA, 0.5))
           f1 <- .fisher_combine(c(0.2, 0.5))
           f0$K == 2L && proche(f0$stat, -2 * (log(.Machine$double.xmin) + log(0.5)), 1e-12) &&
             fn$K == 3L && is.na(fn$stat) && is.na(fn$p) &&
             f1$K == 2L && proche(f1$stat, -2 * log(0.1), 1e-12)
         })
verifier("ta_deg : HomogF a K = 5, p de la colonne j = 5 (n = 4, rho = -1) = 1/12 (#90)",
         {
           h <- mw_test_homogeneite_f(mw_ajuster(ta_deg)); d5 <- h$detail[h$detail$j == 5, ]
           h$K == 5L && nrow(d5) == 1L && d5$n == 4L && d5$rho == -1 && identical(d5$p, 1 / 12)
         })
verifier("tri_deg : B_effectif = 99 pour HomogF et ExpVar, B = 99 (#90)",
         {
           b <- run_engine(methode = "reserve2", triangle = tri_deg, segment = 1, annexe = "II",
                           B = 99)$bootstrap
           b$B_effectif[["HomogF"]] == 99 && b$B_effectif[["ExpVar"]] == 99
         })

## --- p_min des lignes a loi de reference discrete et regle R1 (#115) ---------
# Specification d'actuary (docs/specifications/e2-reduite.md, #115 (c)) ;
# decisions du mainteneur du 06/10/2026 (Q-E2r-115-2 a 4). Valeurs de
# controle par enumeration exhaustive, independante des fonctions du moteur.
kw_enum <- function(t) {
  N <- sum(t); g <- rep(seq_along(t), t)
  perms <- function(v) {
    if (length(v) <= 1) return(list(v))
    out <- list()
    for (x in unique(v)) { i <- match(x, v); for (q in perms(v[-i])) out[[length(out) + 1]] <- c(x, q) }
    out
  }
  h <- vapply(perms(g), function(gg) sum(tapply(seq_len(N), gg, sum)^2 / t), numeric(1))
  sum(abs(h - max(h)) < 1e-9) / length(h)
}
# Queue basse depuis #276 (decision Q-Fd-1 du 14/10/2026) : min_z P(Z <= z).
cal_enum <- function(nk) {
  gr <- as.matrix(expand.grid(lapply(nk, function(n) 0:n)))
  pr <- apply(gr, 1, function(l) prod(stats::dbinom(l, nk, 0.5)))
  Z <- apply(gr, 1, function(l) sum(pmin(l, nk - l)))
  min(vapply(sort(unique(Z)), function(z) min(1, sum(pr[Z <= z])), numeric(1)))
}
verifier("p_min Kruskal-Wallis par enumeration : (3,3,2,1) -> 24/5040, (4,3,2,1) -> 24/12600 (#115)",
         isTRUE(proche(.mw_kruskal_p_min(c(3, 3, 2, 1)), 24 / 5040, 1e-12)) &&
           isTRUE(proche(.mw_kruskal_p_min(c(4, 3, 2, 1)), 1.904762e-3, 1e-6)) &&
           all(vapply(list(c(3, 3, 2, 1), c(4, 3, 2, 1), c(2, 2, 2), c(3, 2, 2, 1)), function(t)
             isTRUE(proche(.mw_kruskal_p_min(t), kw_enum(t), 1e-12)), logical(1))) &&
           .mw_kruskal_p_min(rep(1, 5)) == 1 && is.na(.mw_kruskal_p_min(4)))
verifier("p_min calendaire (queue basse) par enumeration : (3,3) -> 0,0625, (2,3,2,4) -> 0,0078125 (#115, #276)",
         identical(.mw_calendrier_p_min(c(3, 3)), 0.0625) &&
           identical(.mw_calendrier_p_min(c(2, 3, 2, 4)), 0.0078125) &&
           all(vapply(list(c(3, 3), c(2, 3, 2, 4), c(2, 2), c(5, 2, 3), c(2, 3, 4, 4, 6, 5)), function(n)
             isTRUE(proche(.mw_calendrier_p_min(n), cal_enum(n), 1e-12)), logical(1))) &&
           is.na(.mw_calendrier_p_min(1)))
# Forme close de la p_min en queue basse (#276, spec. fd-test-calendaire.md,
# par. 1.3, point 3) : min_z P(Z <= z) = P(Z = 0) = prod_k 2^(1 - n_k), et
# moitie exacte de l'ancienne p_min bilaterale (calcul independant par
# enumeration, cote bilateral recalcule ici).
cal_enum_deux <- function(nk) {
  gr <- as.matrix(expand.grid(lapply(nk, function(n) 0:n)))
  pr <- apply(gr, 1, function(l) prod(stats::dbinom(l, nk, 0.5)))
  Z <- apply(gr, 1, function(l) sum(pmin(l, nk - l)))
  min(vapply(sort(unique(Z)), function(z) min(1, 2 * min(sum(pr[Z <= z]), sum(pr[Z >= z]))), numeric(1)))
}
verifier("p_min calendaire, forme close prod 2^(1 - n_k) et moitie de la p_min bilaterale (#276)",
         {
           cas <- list(2, 3, 7, c(2, 2), c(3, 3), c(2, 3, 2, 4), c(5, 2, 3), c(2, 3, 4, 4, 6, 5),
                       c(2, 2, 2, 2, 2), c(11, 9, 6))
           all(vapply(cas, function(n)
             isTRUE(proche(.mw_calendrier_p_min(n), prod(2^(1 - n)), 1e-12)), logical(1))) &&
             identical(.mw_calendrier_p_min(c(2, 3, 4, 4, 6, 5)), 2^-18) &&
             all(vapply(cas[seq_len(8)], function(n)
               isTRUE(proche(.mw_calendrier_p_min(n), cal_enum_deux(n) / 2, 1e-12)), logical(1))) &&
             identical(.mw_calendrier_p_min(c(1, 2)), 0.5)
         })
verifier("p_min CorrDev (4,3) -> 2/(4! 3!) = 0,013889 ; Fisher de rangs prod 2/n_j!, NA a n_j > 9 ou K < 2 (#115)",
         isTRUE(proche(.mw_corr_p_min(c(4, 3)), 2 / 144, 1e-12)) &&
           isTRUE(proche(.mw_corr_p_min(3), 1 / 3, 1e-12)) &&
           isTRUE(proche(.mw_fisher_rangs_p_min(c(7, 6, 5, 4)),
                         16 / prod(factorial(c(7, 6, 5, 4))), 1e-12)) &&
           is.na(.mw_fisher_rangs_p_min(c(10, 4))) && is.na(.mw_fisher_rangs_p_min(5)))
# Enumeration independante (constat C4 de l'audit) : toutes les permutations
# des facteurs de chaque colonne, statistique recalculee hors du moteur.
perms_n <- function(n) {
  if (n == 1) return(matrix(1L, 1, 1))
  q <- perms_n(n - 1)
  do.call(rbind, lapply(seq_len(n), function(k) cbind(k, ifelse(q >= k, q + 1L, q))))
}
p_min_enum <- function(v, pr, queue) {
  u <- sort(unique(round(v, 10))); v <- round(v, 10)
  min(vapply(u, function(x) if (queue == "haut") sum(pr[v >= x]) else
    min(1, 2 * min(sum(pr[v <= x]), sum(pr[v >= x]))), numeric(1)))
}
# CorrDev, colonnes chainees de longueurs (a, b, c) : paire 1 = colonne A
# restreinte a ses b premieres lignes contre B ; paire 2 = B restreinte a
# ses c premieres lignes contre C ; poids n - 1 (mw_stat_correlation_dev()).
corr_enum <- function(a, b, c, fixer_A = FALSE) {
  PA <- if (fixer_A) matrix(seq_len(a), 1) else perms_n(a); PB <- perms_n(b); PC <- perms_n(c)
  v <- numeric(0)
  for (i in seq_len(nrow(PA))) for (j in seq_len(nrow(PB))) for (k in seq_len(nrow(PC))) {
    r1 <- stats::cor(rank(PA[i, seq_len(b)]), PB[j, ])
    r2 <- stats::cor(rank(PB[j, seq_len(c)]), PC[k, ])
    v <- c(v, ((b - 1) * r1 + (c - 1) * r2) / (b + c - 2))
  }
  p_min_enum(v, rep(1 / length(v), length(v)), "deux")
}
# Fisher de rangs, colonnes de tailles (n1, n2) : p_j par cor.test(exact = TRUE).
fisher_enum <- function(n1, n2) {
  pj <- function(n) apply(perms_n(n), 1, function(x)
    stats::cor.test(seq_len(n), x, method = "spearman", exact = TRUE)$p.value)
  X <- as.vector(outer(-2 * log(pj(n1)), -2 * log(pj(n2)), "+"))
  p_min_enum(X, rep(1 / length(X), length(X)), "haut")
}
verifier("Enumeration independante : CorrDev (4,4,3) et (5,4,3), Fisher de rangs (4,3) (#115, C4)",
         isTRUE(proche(corr_enum(4, 4, 3), 2 / 144, 1e-9)) &&
           isTRUE(proche(corr_enum(4, 4, 3), .mw_corr_p_min(c(4, 3)), 1e-9)) &&
           isTRUE(proche(corr_enum(5, 4, 3, fixer_A = TRUE), .mw_corr_p_min(c(4, 3)), 1e-9)) &&
           isTRUE(proche(corr_enum(6, 5, 4, fixer_A = TRUE), .mw_corr_p_min(c(5, 4)), 1e-9)) &&
           isTRUE(proche(fisher_enum(4, 3), .mw_fisher_rangs_p_min(c(4, 3)), 1e-9)) &&
           isTRUE(proche(fisher_enum(4, 3), 1 / 36, 1e-9)))
verifier("Kruskal-Wallis : forme close k! prod n_i! / N!, 18 groupes en moins d'une seconde (#115, C1)",
         {
           t0 <- proc.time()[["elapsed"]]; p18 <- .mw_kruskal_p_min(18:1)
           duree <- proc.time()[["elapsed"]] - t0
           duree < 1 && isTRUE(proche(p18, exp(lfactorial(18) + sum(lfactorial(18:1)) - lfactorial(171)),
                                      1e-12)) &&
             isTRUE(proche(.mw_kruskal_p_min(c(6, 6, 5, 4, 3, 2, 1)), 8.292518941e-15, 1e-9))
         })
verifier("p_min non finie : NA et motif explicite dans effectifs (#115, C2)",
         {
           s0 <- .mw_p_min_ligne(TRUE, rep(10, 30), "t", .mw_kruskal_p_min)
           s1 <- .mw_p_min_ligne(TRUE, c(3, 2), "t", function(n) NA_real_)
           is.na(s0$p_min) && grepl("hors de la precision de la machine (N = 300) : p_min non calculable",
                                    s0$effectifs, fixed = TRUE) &&
             is.na(s1$p_min) && identical(s1$effectifs,
               "t = 3, 2, p_min non calculable sur ces effectifs, p_min non attribuee")
         })
verifier("reserve2 : p_min des six lignes discretes, les 19 autres NA (#115, critere 1 ; 21 lignes depuis #308, 25 avec les quatre lignes de lecture conjointe de #297)",
         {
           d <- engine_table_tests(run_mw(tri_ref))
           att <- c("Homogeneite de f_j entre annees de survenance" = 16 / prod(factorial(7:4)),
                    "Adequation de l'exposant de variance, colonne par colonne" = 16 / prod(factorial(7:4)),
                    "Effets d'annee calendaire (test de Mack)" = 2^-18,
                    "Homogeneite des residus entre annees de survenance" = 8.292518941e-15,
                    "Correlation entre annees de developpement adjacentes" = 2 / 12441600,
                    "Test des suites sur les residus de Mack" = runs_p_min(13, 13))
           nrow(d) == 25L && all(is.na(d$p_min[!d$test %in% names(att)])) &&
             all(vapply(names(att), function(k)
               isTRUE(proche(d$p_min[d$test == k], att[[k]], 1e-6)), logical(1))) &&
             isTRUE(proche(runs_p_min(13, 13), 3.845932e-7, 1e-6)) &&
             !any(d$inoperant)
         })
# Depuis #125 (D1-8), la p Monte-Carlo etant retenue, R1 lit le plancher
# Monte-Carlo p_min_mc (B = 99, B_eff = 99) : CorrDev 0,38 >= alpha ->
# inoperant (prefixe Monte-Carlo). Suites : diagnostic par decision depuis
# #312 (Q-D1-Fm-1 (B)), hors du domaine de R1 (lignes de type test) :
# p_min = 4/70 restituee, p_min_mc NA, detail T-1 sans texte de R1 ; le
# plancher Monte-Carlo du bootstrap (0,02) reste lisible dans
# bootstrap$p_min_mc. Calendaire en queue basse depuis #276 (decision Q-Fd-1 ;
# spec. fd-test-calendaire.md, par. 5.1 et 6) : plancher 0,05 = alpha/2 a
# B = 99 (0,10 en bilateral, alors inoperant) -> test ALERTE, ECHEC dit
# inatteignable ; p_min 0,0625 (0,125 en bilateral). L'autre branche de R1
# (plancher sous alpha/2 : aucun texte, ECHEC possible) est exercee a
# B = 99 et alpha = 0,20 : p = p_min_mc = 0,05 < alpha/2 = 0,10 -> ECHEC, sans
# le texte "inatteignable". Elle l'etait avant a B = 999 et alpha = 0,10
# (p_min_mc = 0,048, a deux replications du seuil alpha/2 = 0,05 : jeu d'essai
# fragile, tout changement de l'ordre des tirages de mw_bootstrap() le faisait
# basculer ; avis d'actuary du 08/11/2026, docs/revues/20261108-duree-ci/
# avis-actuary.md). Ici le plancher (0,05) est loin du seuil (0,10).
verifier("Sous-triangle 5 x 5, alpha = 0,10 (Calendaire ECHEC atteignable a alpha = 0,20) : CorrDev inoperant sur p_min_mc, Calendaire test (queue basse, #276), Suites diagnostic par decision sans texte de R1 (#115, #125, #312)",
         {
           t5 <- tri_ref[1:5, 1:5]; t5[row(t5) + col(t5) > 6] <- NA
           r5 <- run_mw(t5)
           d <- engine_table_tests(r5)
           l <- function(k, d) d[d$test == k, ]
           pre <- paste("TEST INOPERANT au seuil alpha = 0.1 : plus petite p-value Monte-Carlo",
                        "atteignable sur ces replications >= alpha")
           ina <- paste("ECHEC inatteignable : plus petite p-value Monte-Carlo atteignable sur ces",
                        "replications >= alpha/2 = 0.05 (diagonales n_k = 3, 3)")
           ca <- l("Effets d'annee calendaire (test de Mack)", d)
           co <- l("Correlation entre annees de developpement adjacentes", d)
           su <- l("Test des suites sur les residus de Mack", d)
           d20 <- engine_table_tests(run_engine(methode = "reserve2", triangle = t5, segment = 1,
                                                annexe = "II", B = 99, alpha = 0.20))
           c9 <- l("Effets d'annee calendaire (test de Mack)", d20)
           isTRUE(co$inoperant) && co$type == "diagnostic" && identical(co$verdict, "INFO") &&
             startsWith(co$commentaire, pre) &&
             !ca$inoperant && ca$type == "test" && identical(ca$verdict, "ALERTE") &&
             grepl(ina, ca$commentaire, fixed = TRUE) &&
             isTRUE(proche(ca$p_retenue, 0.05, 1e-12)) &&
             identical(ca$p_min, 0.0625) && isTRUE(proche(co$p_min, 1 / 3, 1e-12)) &&
             isTRUE(proche(ca$p_min_mc, 0.05, 1e-12)) && isTRUE(proche(co$p_min_mc, 0.38, 1e-12)) &&
             !c9$inoperant && c9$type == "test" && identical(c9$verdict, "ECHEC") &&
             isTRUE(proche(c9$p_retenue, 0.05, 1e-12)) && isTRUE(proche(c9$p_min_mc, 0.05, 1e-12)) &&
             !grepl("inatteignable", c9$commentaire, fixed = TRUE) &&
             su$type == "diagnostic" && identical(su$verdict, "INFO") && !su$inoperant &&
             isTRUE(proche(su$p_min, 4 / 70, 1e-12)) && is.na(su$p_min_mc) &&
             isTRUE(proche(r5$bootstrap$p_min_mc[["Runs"]], 0.02, 1e-12)) &&
             startsWith(su$commentaire, "Detecte un regroupement ou une alternance des signes") &&
             grepl("Diagnostic par decision, sans verdict ni p-value retenue", su$commentaire, fixed = TRUE) &&
             !grepl("ECHEC", su$commentaire, fixed = TRUE) && !grepl("p_min", su$commentaire, fixed = TRUE)
         })
# Queue basse du test calendaire (#276, decisions Q-Fd-1 et Q-Fd-3 ; reprise
# apres l'audit leger). Triangle 8 x 8 a diagonales equilibrees : rangs des
# facteurs par colonne trouves par recherche aleatoire (graine 1, 3 000
# tirages, maximum de Z*) hors de ce fichier ; Z = 12, Z* = 2,704 > 0 (cote
# haut, abandonne par la forme unilaterale). Mesure du 16/10/2026 a B = 99,
# graine 20260831 : p Monte-Carlo "bas" = 1 (verdict OK), p "deux" = 0,02
# (< alpha/2 : la forme bilaterale aurait rendu ECHEC).
tri_cal_haut <- local({
  rk <- list(c(4, 1, 6, 7, 2, 5, 3), c(6, 2, 5, 3, 1, 4), c(3, 2, 4, 1, 5), c(2, 4, 3, 1),
             c(2, 1, 3), 2:1, 1)
  f <- c(1.8, 1.4, 1.2, 1.1, 1.05, 1.03, 1.02)
  t <- matrix(NA_real_, 8, 8); t[, 1] <- 100 + 10 * (0:7)
  for (j in 0:6) { idx <- 0:(6 - j)
    t[idx + 1, j + 2] <- t[idx + 1, j + 1] * f[j + 1] * (1 + 0.01 * rk[[j + 1]]) }
  t
})
verifier("p asymptotique calendaire Phi(Z*) (queue basse, #276) : reserve2 1,996364e-4 ; Z* > 0 -> p > 0,5",
         {
           c2 <- mw_test_annees_calendaires(mw_ajuster(tri_ref))
           ch <- mw_test_annees_calendaires(mw_ajuster(tri_cal_haut))
           identical(c2$p, .p_borne(stats::pnorm(c2$stat))) &&
             isTRUE(proche(c2$p, 1.996364159e-4, 1e-8)) &&
             isTRUE(proche(2 * (1 - stats::pnorm(abs(c2$stat))), 2 * c2$p, 1e-10)) &&
             identical(ch$p, .p_borne(stats::pnorm(ch$stat))) &&
             ch$Z == 12 && isTRUE(proche(ch$stat, 2.7043359, 1e-6)) && ch$p > 0.5 &&
             isTRUE(proche(ch$p, 0.9965779, 1e-6))
         })
verifier("Cote haut abandonne (#276) : Z* > 0 -> p Monte-Carlo 1 et verdict OK ; la queue \"deux\" rendrait p = 0,02 (B = 99)",
         {
           aj <- mw_ajuster(tri_cal_haut)
           # meme flux de mw_bootstrap(), catalogue local dont seule la queue
           # de Calendrier differe (copie de la fonction dans un environnement
           # fils de celui du moteur)
           boot_queue <- function(queue) {
             ct <- MW_CATALOGUE_MC
             ct$Calendrier <- .mc_entree(ct$Calendrier$calc, queue, extremes = ct$Calendrier$extremes)
             f <- mw_bootstrap; e <- new.env(parent = environment(mw_bootstrap))
             e$MW_CATALOGUE_MC <- ct; environment(f) <- e
             f(aj, B = 99, seed = 20260831)
           }
           b0 <- mw_bootstrap(aj, B = 99, seed = 20260831)
           bb <- boot_queue("bas"); bd <- boot_queue("deux")
           d <- engine_table_tests(run_mw(tri_cal_haut))
           ca <- d[d$test == "Effets d'annee calendaire (test de Mack)", ]
           identical(MW_CATALOGUE_MC$Calendrier$queue, "bas") &&
             identical(b0$p_mc[["Calendrier"]], bb$p_mc[["Calendrier"]]) &&
             identical(b0$p_mc[["Calendrier"]], 1) && b0$B_effectif[["Calendrier"]] == 99 &&
             isTRUE(proche(bd$p_mc[["Calendrier"]], 0.02, 1e-12)) &&
             bd$p_mc[["Calendrier"]] < 0.05 &&
             ca$type == "test" && identical(ca$verdict, "OK") && identical(ca$p_retenue, 1)
         })
# Adapte par #207 : la p_min de HomogF est attribuee avec ex aequo (loi
# conditionnelle aux rangs moyens, decision Q-E2c-3) ; celle de CorrDev reste
# NA avec motif.
verifier("Ex aequo de F : p_min de HomogF attribuee (#207), p_min NA de CorrDev avec motif (#115, critere 4)",
         {
           t <- tri_ref
           t[2, 2] <- t[2, 1] * t[1, 2] / t[1, 1]          # F(1,0) = F(0,0)
           t[3, 3] <- t[3, 2] * t[1, 3] / t[1, 2]          # F(2,1) = F(0,1)
           d <- engine_table_tests(run_mw(t))
           mot <- "ex aequo : loi de permutation conditionnelle non tabulee, p_min non attribuee"
           hf <- d[d$test == "Homogeneite de f_j entre annees de survenance", ]
           co <- d[d$test == "Correlation entre annees de developpement adjacentes", ]
           # colonnes n_j = 7, 6, 5, 4 ; un ex aequo double en j = 0 et j = 1 :
           # masses 2 x 2!/7!, 2 x 2!/6!, 2/5!, 2/4! (forme close 2 prod t_g!/n!)
           isTRUE(proche(hf$p_min, 64 / prod(factorial(7:4)), 1e-12)) && hf$type == "test" &&
             !grepl("non tabulee", hf$commentaire, fixed = TRUE) &&
             is.na(co$p_min) && co$type == "test" && grepl(mot, co$commentaire, fixed = TRUE)
         })

## --- p de Spearman avec ex aequo a n <= 9 : loi conditionnelle aux rangs (#207)
# Specification d'actuary approuvee le 11/10/2026 (Q-E2c-3 : p_min attribuee ;
# Q-E2c-4 : p bilaterale par doublement). Controles independants du moteur :
# enumeration brute des n! permutations (perms_n(), ci-dessus), D entier.
spearman_enum <- function(a, b) {
  n <- length(a); A <- round(2 * rank(a)); B <- round(2 * rank(b))
  P <- perms_n(n)
  D <- apply(P, 1, function(pi) n * sum(A * B[pi]) - sum(A) * sum(B))
  d0 <- n * sum(A * B) - sum(A) * sum(B)
  q <- function(d) min(nrow(P), 2 * min(sum(D <= d), sum(D >= d)))
  qs <- vapply(D, q, numeric(1))
  list(p = q(d0) / nrow(P), masse_min = sum(qs == min(qs)) / nrow(P))
}
verifier("Spearman avec ex aequo : a = (1,1,2,3,4), b = 5:1 -> p = 1/30 (#207)",
         identical(.mw_spearman_p(c(1, 1, 2, 3, 4), 5:1), 1 / 30) &&
           identical(spearman_enum(c(1, 1, 2, 3, 4), 5:1)$p, 1 / 30))
verifier("Spearman avec ex aequo des deux cotes (ExpVar) : p = 0,10 par doublement, masse_min = 0,05 (#207)",
         {
           sp <- .mw_spearman(c(1, 1, 1, 3, 4), c(1, 2, 2, 4, 5), plancher_b = 0)
           identical(sp$p, 0.1) && identical(sp$masse_min, 0.05) &&
             identical(sp$rho, unname(suppressWarnings(stats::cor.test(
               c(1, 1, 1, 3, 4), c(1, 2, 2, 4, 5), method = "spearman", exact = FALSE))$estimate))
         })
verifier("masse_min de HomogF (b = idx sans ex aequo) = forme close 2 prod t_g!/n! : 1/90, 1/420, 1/1890 (#207)",
         {
           m <- function(a) .mw_spearman(a, seq_along(a) - 1L)$masse_min
           fc <- function(a) 2 * prod(factorial(table(a))) / factorial(length(a))
           cas <- list(c(1, 1, 2, 2, 3, 4), c(5, 5, 5, 1, 2, 3, 4), c(1, 1, 1, 1, 2, 2, 3, 3, 4))
           identical(m(cas[[1]]), 1 / 90) && identical(m(cas[[2]]), 1 / 420) &&
             identical(m(cas[[3]]), 1 / 1890) &&
             all(vapply(cas, function(a) identical(m(a), fc(a)), logical(1))) &&
             identical(.mw_spearman(c(3, 1, 4, 2), 0:3)$masse_min, 2 / 24)
         })
verifier("Contre-epreuve par enumeration brute des n! permutations, n = 4 a 7, ex aequo tires (#207)",
         {
           ok <- engine_sous_graine(20261011, vapply(1:48, function(k) {
             n <- 4L + (k %% 4L)
             a <- sample(1:3, n, replace = TRUE); if (!anyDuplicated(a)) a[2] <- a[1]
             b <- if (k %% 2L) seq_len(n) - 1L else sample(1:4, n, replace = TRUE)
             if (length(unique(a)) < 2 || length(unique(b)) < 2) return(TRUE)
             sp <- .mw_spearman(a, b, plancher_b = 0); en <- spearman_enum(a, b)
             identical(sp$p, en$p) && identical(sp$masse_min, en$masse_min) &&
               sp$p >= 2 / factorial(n) && sp$p <= 1 &&
               identical(sp$rho, stats::cor(rank(a), rank(b)))
           }, logical(1)))
           all(ok)
         })
# n = 8 (40 320 permutations, reprise apres audit, m3(a)) : D de toutes les
# permutations par produit matriciel, p et masse_min par tabulation des
# valeurs distinctes de D (spearman_enum() serait quadratique en n!).
spearman_enum_tab <- function(a, b) {
  n <- length(a); A <- round(2 * rank(a)); B <- round(2 * rank(b)); P <- perms_n(n)
  D <- as.vector(matrix(B[P], nrow(P)) %*% A) * n - sum(A) * sum(B)
  d0 <- n * sum(A * B) - sum(A) * sum(B)
  tb <- table(D); v <- as.numeric(names(tb)); cnt <- as.vector(tb); N <- nrow(P)
  q <- vapply(v, function(d) min(N, 2 * min(sum(cnt[v <= d]), sum(cnt[v >= d]))), numeric(1))
  list(p = min(N, 2 * min(sum(D <= d0), sum(D >= d0))) / N, masse_min = sum(cnt[q == min(q)]) / N)
}
verifier("Contre-epreuve par enumeration brute a n = 8 : ex aequo d'un cote, puis des deux cotes (#207)",
         {
           cas <- list(list(c(3, 3, 1, 5, 2, 2, 2, 4), 0:7),
                       list(c(1, 1, 2, 2, 3, 3, 4, 4), c(8, 6, 7, 5, 3, 4, 1, 2)),
                       list(c(1, 2, 2, 3, 3, 3, 4, 5), c(2, 2, 1, 3, 3, 5, 4, 4)),
                       list(c(5, 1, 1, 2, 4, 4, 3, 3), c(1, 1, 1, 2, 2, 3, 3, 3)))
           all(vapply(cas, function(x) {
             sp <- .mw_spearman(x[[1]], x[[2]], plancher_b = 0); en <- spearman_enum_tab(x[[1]], x[[2]])
             identical(sp$p, en$p) && identical(sp$masse_min, en$masse_min)
           }, logical(1)))
         })
verifier("Spearman a entree constante (ex aequo a n <= 9) : rho, p et masse_min NA (#207, m2)",
         {
           s1 <- .mw_spearman(c(2, 2, 2, 2, 2), 0:4); s2 <- .mw_spearman(c(1, 3, 2, 5), c(4, 4, 4, 4), 0)
           all(is.na(c(s1$rho, s1$p, s1$masse_min, s2$rho, s2$p, s2$masse_min))) &&
             is.na(.mw_spearman_p(c(2, 2, 2, 2, 2), 0:4))
         })
verifier(".mw_p_min_ligne : colonne de plus de 9 facteurs avec ex aequo, aucune mention de loi enumeree (#207, m1)",
         {
           e <- .mw_p_min_ligne(TRUE, c(10, 5), "colonnes n_j", function(n) 0.5, TRUE, n_max = 9,
                                ex_aequo_enumere = TRUE)
           is.na(e$p_min) && !grepl("enumeree", e$effectifs, fixed = TRUE) &&
             grepl("colonne de plus de 9 facteurs", e$effectifs, fixed = TRUE)
         })
verifier(".mw_p_min_ligne : p_min non finie avec ex aequo (K < 2), aucune mention de loi enumeree ; longueurs differentes nommees (#207, /code-review)",
         {
           e <- .mw_p_min_ligne(TRUE, c(5), "colonnes n_j", function(n) NA_real_, TRUE, n_max = 9,
                                ex_aequo_enumere = TRUE)
           f <- .mw_p_min_ligne(TRUE, c(5, 4), "colonnes n_j", function(n) 0.01, TRUE, n_max = 9,
                                ex_aequo_enumere = TRUE)
           m <- tryCatch(.mw_spearman_loi_rangs(1:5, 1:4), error = conditionMessage)
           is.na(e$p_min) && !grepl("enumeree", e$effectifs, fixed = TRUE) &&
             identical(f$p_min, 0.01) && grepl("enumeree", f$effectifs, fixed = TRUE) &&
             grepl("longueurs differentes", m, fixed = TRUE)
         })
verifier("p_min de Fisher avec ex aequo = produit des masse_min, par enumeration brute (4 et 3 facteurs) (#207)",
         {
           a1 <- c(1, 1, 2, 3); a2 <- c(2, 2, 1)
           pj <- function(a) { P <- perms_n(length(a))
             apply(P, 1, function(pi) spearman_enum(a[pi], seq_along(a) - 1L)$p) }
           X <- as.vector(outer(-2 * log(pj(a1)), -2 * log(pj(a2)), "+"))
           enum <- p_min_enum(X, rep(1 / length(X), length(X)), "haut")
           ms <- c(.mw_spearman(a1, 0:3)$masse_min, .mw_spearman(a2, 0:2)$masse_min)
           isTRUE(proche(.mw_fisher_rangs_p_min(c(4, 3), ms), enum, 1e-9)) &&
             isTRUE(proche(enum, (4 / 24) * (4 / 6), 1e-9)) &&
             identical(.mw_fisher_rangs_p_min(c(7, 6, 5, 4)),
                       .mw_fisher_rangs_p_min(c(7, 6, 5, 4), 2 / factorial(c(7, 6, 5, 4)))) &&
             is.na(.mw_fisher_rangs_p_min(c(5, 4), c(0.1, NA)))
         })
verifier(".mw_p_min_ligne : ex aequo enumeres, p_min attribuee et motif dans effectifs (#207)",
         {
           s <- .mw_p_min_ligne(TRUE, c(5, 4), "colonnes n_j",
                                function(n) .mw_fisher_rangs_p_min(n, c(1 / 30, 1 / 12)), TRUE,
                                n_max = 9, ex_aequo_enumere = TRUE)
           s10 <- .mw_p_min_ligne(TRUE, c(10, 4), "colonnes n_j", function(n) 0.5, TRUE,
                                  n_max = 9, ex_aequo_enumere = TRUE)
           isTRUE(proche(s$p_min, 1 / 360, 1e-12)) &&
             identical(s$effectifs, paste("colonnes n_j = 5, 4, ex aequo : loi de permutation",
                                          "conditionnelle aux rangs moyens, enumeree")) &&
             is.na(s10$p_min) && grepl("colonne de plus de 9 facteurs", s10$effectifs, fixed = TRUE)
         })
verifier("ExpVar a premiere colonne de cumuls a ex aequo : p_min attribuee, motif enumere (#207)",
         {
           t <- tri_ref; t[1:8, 1] <- round(t[1:8, 1], -2)  # 300 x 5, 400 x 3
           t[, -1] <- t[, -1] - tri_ref[, 1] + t[, 1]
           ev <- mw_test_exposant_variance(mw_ajuster(t))
           d <- engine_table_tests(run_engine(methode = "reserve2", triangle = t, segment = 1,
                                              annexe = "II", B = 99))
           x <- d[d$test == "Adequation de l'exposant de variance, colonne par colonne", ]
           any(ev$detail$ex_aequo) && length(ev$masse_min) == nrow(ev$detail) &&
             is.finite(x$p_min) && x$p_min == .mw_fisher_rangs_p_min(ev$detail$n, ev$masse_min)
         })

## --- Pool du bootstrap redresse par le levier (#46, variante B) ---------------
# Decision du mainteneur du 06/10/2026 (Q-E2r-46-1) : r~_ij = r_ij / sqrt(1 - h_ij),
# h_ij = C_ij / S_j, puis recentrage. Reference recalculee ici a partir du
# triangle, sans mw_influence() : S_j = somme des C_ij de la colonne.
pool_attendu46 <- function(t) {
  a <- mw_ajuster(t); rs <- mw_residus(a)
  S <- vapply(seq_len(nrow(rs)), function(k) {
    j <- rs$j[k]; sum(t[seq_len(nrow(t) - j - 1), j + 1])
  }, numeric(1))
  rr <- rs$residu / sqrt(1 - rs$C / S)
  list(rs = rs, brut = rr, pool = rr - mean(rr))
}
verifier("Pool redresse (#46) : r / sqrt(1 - C/S) - moyenne a 1e-15 pres sur reserve2",
         {
           p <- .mw_pool_residus(mw_ajuster(tri_ref)); att <- pool_attendu46(tri_ref)
           length(p) == nrow(att$rs) && max(abs(p - att$pool)) <= 1e-15
         })
verifier("Pool redresse (#46) : |r~| = 1 pour n_j = 2 avant recentrage ; somme r^2 = n_j - 1 par colonne",
         {
           att <- pool_attendu46(tri_ref); nj <- table(att$rs$j)
           j2 <- as.integer(names(nj)[nj == 2])
           length(j2) == 1 && isTRUE(proche(abs(att$brut[att$rs$j == j2]), c(1, 1), rel = 1e-14)) &&
             all(vapply(names(nj), function(j)
               isTRUE(proche(sum(att$rs$residu[att$rs$j == as.integer(j)]^2), nj[[j]] - 1, rel = 1e-12)),
               logical(1)))
         })
verifier("Pool redresse (#46) : aucun NaN, longueur = residus retenus (ta_deg, tri_deg, tri_c1, col0_1e11, sauf_une)",
         all(vapply(list(ta_deg, tri_deg, tri_c1, acceptes192$col0_1e11, acceptes192$sauf_une), function(t) {
           a <- mw_ajuster(t); jd <- .mw_colonnes_degenerees(a); p <- .mw_pool_residus(a, jd)
           length(p) == nrow(mw_residus(a, jd)) && length(p) > 0 && all(is.finite(p)) &&
             abs(mean(p)) < 1e-15 && identical(p, .mw_pool_residus(a))
         }, logical(1))))
verifier("mw_bootstrap() tire dans .mw_pool_residus() ; statistiques observees inchangees (#46)",
         {
           a <- mw_ajuster(tri_ref); jd <- .mw_colonnes_degenerees(a)
           b <- mw_bootstrap(a, B = 19)
           sig <- rep(NA_real_, 19)
           engine_sous_graine(20260831, {
             pool <- .mw_pool_residus(a, jd)
             # boucle alignee sur celle de mw_bootstrap() (sauts compris)
             # retirage et plafond de mw_bootstrap() (#257), fonction partagee
             n_max <- FACTEUR_B_MAX_MW * (19 + 1); n_tir <- 0
             for (k in 1:19) {
               tir <- .mw_tirer_triangle_valide(a, pool, n_max - n_tir)
               n_tir <- n_tir + tir$n
               if (is.null(tb <- tir$tri)) next
               ab <- try(mw_ajuster(tb), silent = TRUE)
               if (inherits(ab, "try-error")) next
               sb <- try(.mw_stats(ab, .mw_ensembles_figes(ab, jd), replique = TRUE), silent = TRUE)
               if (inherits(sb, "try-error")) next
               m <- try(mw_msep(ab), silent = TRUE)
               if (!inherits(m, "try-error") && is.finite(m$msep) && ab$reserve > 0)
                 sig[k] <- sqrt(m$msep) / ab$reserve
             }
           })
           identical(b$sigma_boot, sig[is.finite(sig)]) &&
             identical(b$stats_obs, as.list(.mc_evaluer(MW_CATALOGUE_MC, .mw_contexte_mc(a, .mw_ensembles_figes(a, jd)))))
         })
# C2 de l'audit de #46 : ligne 0 de reserve2 multipliee par 1e17. 1 - C/S vaut
# 0 en flottant pour les cellules de la ligne 0 ; 1 - h est calcule comme la
# somme des autres cellules divisee par S_j, d'ou un pool fini et un bootstrap
# qui tourne (B_eff > 0) ou, a defaut, un motif.
verifier("Pool redresse (#46, C2) : ligne 0 x 1e17, pool fini, B_eff > 0 ou motif",
         {
           t17 <- tri_ref; t17[1, ] <- t17[1, ] * 1e17
           a <- mw_ajuster(t17); jd <- .mw_colonnes_degenerees(a)
           p <- .mw_pool_residus(a, jd)
           r <- suppressWarnings(run_engine(methode = "reserve2", triangle = t17, segment = 1,
                                                annexe = "II", B = 99))
           tb <- engine_table_tests(r)
           be <- unlist(r$bootstrap$B_effectif); mo <- unlist(r$bootstrap$motif_mc)
           isTRUE(r$ok) && length(p) > 0 && all(is.finite(p)) &&
             all(is.finite(r$bootstrap$sigma_boot)) && length(r$bootstrap$sigma_boot) > 0 &&
             all(be > 0 | (!is.na(mo[names(be)]) & nzchar(mo[names(be)]))) &&
             !any(is.nan(tb$p_retenue))
         })

## --- Residus de Mack sous forme stable (#233) -------------------------------
# F(i,j) - f_j calcule par .mw_ecart_facteur_stable() (somme des ecarts aux
# autres facteurs ponderee par les C(k,j)) et non par difference : une ligne
# qui domine ses colonnes d'un facteur 1e15 ou 1e16 ne doit plus noyer les
# residus dans l'arrondi de f_j. Deux proprietes exactes, sans reference
# externe :
#  - colonne a n_j = 2 cellules (j = 5 de reserve2) : |r_ij| = sqrt(1 - h_ij),
#    1 - h_ij = C(autre,j) / S_j ;
#  - contrainte d'estimation de f_j : somme_i sqrt(C_ij) r_ij = 0, verifiee
#    en relatif a 1e-12 de somme_i |sqrt(C_ij) r_ij| pour j = 0..6 ; la
#    colonne j = 6 (n_j = 1) n'a pas de residu, j = 0..5 doivent en avoir.
# Moteur d'avant #233 (7613e8a) : ligne 0 x 1e16, |r / sqrt(1 - h)| = 0 sur
# la cellule dominante de j = 5 et rapports de contrainte jusqu'a 1 ; ligne
# 3 x 1e15, rapports jusqu'a 1 (colonne j = 2).
.verifier_residus_stables <- function(ligne, e) {
  t <- tri_ref; t[ligne + 1, ] <- t[ligne + 1, ] * 10^e
  a <- mw_ajuster(t); r <- mw_residus(a)
  c5 <- r[r$j == 5, ]
  omh <- vapply(seq_len(nrow(c5)), function(k) {
    col <- a$tri[1:2, 6]; sum(col[-(c5$i[k] + 1)]) / sum(col)
  }, numeric(1))
  n2 <- nrow(c5) == 2L && all(abs(abs(c5$residu) / sqrt(omh) - 1) <= 1e-12)
  contrainte <- vapply(0:6, function(j) {
    x <- r[r$j == j, ]
    if (!nrow(x)) return(NA_real_)
    v <- sqrt(x$C) * x$residu
    abs(sum(v)) / sum(abs(v))
  }, numeric(1))
  n2 && all(!is.na(contrainte[1:6])) && is.na(contrainte[7]) &&
    all(contrainte[1:6] <= 1e-12)
}
verifier("Residus stables (#233) : reserve2, ligne 0 x 1e16 : |r / sqrt(1 - h)| = 1 a 1e-12 en j = 5 (n = 2) ; contrainte somme sqrt(C) r = 0 a 1e-12 pres, j = 0..6",
         .verifier_residus_stables(0L, 16))
verifier("Residus stables (#233) : reserve2, ligne 3 x 1e15 : memes controles",
         .verifier_residus_stables(3L, 15))

# mw_influence() (#233, suite) : f_j^(-i), 1 - h_i, s2_(i) et dfbeta_relatif
# par sommes des AUTRES cellules et ecarts stables. Moteur d'avant (7613e8a),
# reserve2 ligne 0 : x 1e16, f_sans_cellule de la cellule dominante 3,0 /
# 1,333 / 1,333 / 1,0 / 1,0 au lieu de 3,203 / 1,657 / 1,332 / 1,156 /
# 1,095 (j = 0..4) ; x 1e17, 1 - h = 0, f_sans_cellule NaN, dfbetas NA.
.verifier_influence_dominante <- function(e) {
  t <- tri_ref; t[1, ] <- t[1, ] * 10^e
  inf <- mw_influence(mw_ajuster(t))
  d <- inf[inf$i == 0, ]
  # f_j recalcule sur la colonne privee de la ligne 0 (lignes 1..I-j-1)
  f_ref <- vapply(d$j, function(j) {
    k <- 2:(nrow(t) - j - 1)
    sum(t[k, j + 2]) / sum(t[k, j + 1])
  }, numeric(1))
  dfb <- d$dfbetas[d$j <= 4]                      # n_j >= 3 : j = 0..4
  nrow(d) == 6L && all(abs(d$f_sans_cellule / f_ref - 1) <= 1e-12) &&
    length(dfb) == 5L && all(is.finite(dfb))
}
verifier("mw_influence() stable (#233) : reserve2, ligne 0 x 1e16 : f_sans_cellule dominante = f_j sans la ligne 0 a 1e-12 ; DFBETAS finis (j = 0..4)",
         .verifier_influence_dominante(16))
verifier("mw_influence() stable (#233) : reserve2, ligne 0 x 1e17 : memes controles",
         .verifier_influence_dominante(17))

# Noms de ligne du triangle (#268) : facultatifs ; s'ils sont fournis, chacun
# est renseigne (ni NA, ni vide, ni fait de seuls blancs) et unique. Avant
# #268 : nom NA -> defaut de calcul intercepte (erreur R dans
# mw_plots_data()) ; nom vide et doublon -> ok = TRUE, le doublon remplace en
# silence dans les tables. Un refus est un motif metier, sans erreur_r.
.run_noms <- function(noms) {
  t <- tri_ref; rownames(t) <- noms
  run_engine(methode = "reserve2", triangle = t, segment = 1, annexe = "II", B = 99)
}
.refus_noms <- function(noms, motif) {
  r <- .run_noms(noms)
  v <- mw_valider_triangle(`rownames<-`(tri_ref, noms))
  identical(r$ok, FALSE) && identical(r$validation$ok, FALSE) &&
    is.null(r$validation$erreur_r) && is.null(r$parametre_final) &&
    identical(r$validation$erreurs, motif) && identical(v$ok, FALSE) &&
    identical(v$erreurs, motif)
}
annees <- as.character(2017:2024)
verifier("Noms de ligne (#268) : nom NA refuse, motif metier, sans erreur_r",
         .refus_noms(replace(annees, 8, NA),
                     "Nom d'annee d'accident manquant ou vide en ligne 8 (i=7)."))
verifier("Noms de ligne (#268) : nom vide refuse, motif metier, sans erreur_r",
         .refus_noms(replace(annees, 3, ""),
                     "Nom d'annee d'accident manquant ou vide en ligne 3 (i=2)."))
verifier("Noms de ligne (#268) : nom fait de seuls blancs refuse comme un nom vide",
         .refus_noms(replace(annees, 1, " \t"),
                     "Nom d'annee d'accident manquant ou vide en ligne 1 (i=0)."))
verifier("Noms de ligne (#268) : annees d'accident en double refusees, un motif par nom, positions citees",
         .refus_noms(replace(annees, c(7, 4), c("2022", "2019")),
                     c("Annee d'accident en double : \"2019\" (lignes 3 et 4, i=2 et i=3).",
                       "Annee d'accident en double : \"2022\" (lignes 6 et 7, i=5 et i=6).")))
verifier("Noms de ligne (#268) : trois lignes au meme nom, un seul motif",
         .refus_noms(replace(annees, c(2, 5), "2017"),
                     "Annee d'accident en double : \"2017\" (lignes 1, 2 et 5, i=0, i=1 et i=4)."))
verifier("Noms de ligne (#268) : blanc initial, doublon compare sans les blancs, forme saisie citee",
         .refus_noms(replace(annees, 7, " 2022"),
                     "Annee d'accident en double : \"2022\", \" 2022\" (lignes 6 et 7, i=5 et i=6)."))
verifier("Noms de ligne (#268) : blanc final, doublon compare sans les blancs, forme saisie citee",
         .refus_noms(replace(annees, 2, "2017 "),
                     "Annee d'accident en double : \"2017\", \"2017 \" (lignes 1 et 2, i=0 et i=1)."))
verifier("Noms de ligne (#268) : manquants et doublon cumules, doublon compte hors des noms manquants",
         .refus_noms(c(NA, "", annees[3:6], "2022", "2024"),
                     c("Nom d'annee d'accident manquant ou vide en ligne 1 (i=0).",
                       "Nom d'annee d'accident manquant ou vide en ligne 2 (i=1).",
                       "Annee d'accident en double : \"2022\" (lignes 6 et 7, i=5 et i=6).")))
# Blancs Unicode et echappement des formes citees (#268, correction du
# 16/10/2026) : l'espace insecable U+00A0, les autres blancs \h, \v et les
# caracteres de format sans chasse U+200B, U+200C, U+200D, U+2060, U+FEFF
# (decision du mainteneur du 16/10/2026) sont des blancs ; une forme citee
# est echappee (tabulation, guillemet), et un blanc ou un caractere de format
# non ASCII y est ecrit \uXXXX quelle que soit la locale. Chaines non ASCII
# construites par intToUtf8() et rawToChar() : ce fichier reste en ASCII.
.u <- function(...) intToUtf8(c(...))
.octets <- function(b, enc) { s <- rawToChar(as.raw(b)); Encoding(s) <- enc; s }
verifier("Noms de ligne (#268) : espace insecable finale, doublon compare sans elle, citee \\u00a0",
         .refus_noms(replace(annees, 7, paste0("2022", .u(0xA0))),
                     "Annee d'accident en double : \"2022\", \"2022\\u00a0\" (lignes 6 et 7, i=5 et i=6)."))
verifier("Noms de ligne (#268) : nom fait d'une seule espace insecable refuse comme un nom vide",
         .refus_noms(replace(annees, 3, .u(0xA0)),
                     "Nom d'annee d'accident manquant ou vide en ligne 3 (i=2)."))
verifier("Noms de ligne (#268) : nom fait de blancs Unicode (U+2003, U+3000) refuse comme un nom vide",
         .refus_noms(replace(annees, 5, .u(0x2003, 0x3000)),
                     "Nom d'annee d'accident manquant ou vide en ligne 5 (i=4)."))
verifier("Noms de ligne (#268) : nom fait de l'espace sans chasse U+200B refuse comme un nom vide",
         .refus_noms(replace(annees, 4, .u(0x200B)),
                     "Nom d'annee d'accident manquant ou vide en ligne 4 (i=3)."))
verifier("Noms de ligne (#268) : \"x\" suivi de U+FEFF doublon de \"x\", cite \\ufeff",
         .refus_noms(c("x", paste0("x", .u(0xFEFF)), annees[3:8]),
                     "Annee d'accident en double : \"x\", \"x\\ufeff\" (lignes 1 et 2, i=0 et i=1)."))
verifier("Noms de ligne (#268) : U+2060, U+200C et U+200D de bord retires, doublon de \"x\"",
         .refus_noms(c(paste0(.u(0x2060, 0x200C), "x", .u(0x200D)), "x", annees[3:8]),
                     "Annee d'accident en double : \"\\u2060\\u200cx\\u200d\", \"x\" (lignes 1 et 2, i=0 et i=1)."))
verifier("Noms de ligne (#268) : tabulation et guillemet echappes dans les formes citees",
         .refus_noms(c("a\tb", "a\tb ", "a\"b", " a\"b", annees[5:8]),
                     c("Annee d'accident en double : \"a\\tb\", \"a\\tb \" (lignes 1 et 2, i=0 et i=1).",
                       "Annee d'accident en double : \"a\\\"b\", \" a\\\"b\" (lignes 3 et 4, i=2 et i=3).")))
verifier("Noms de ligne (#268) : nom a octet A0 non UTF-8 (Latin-1 non declare), sans erreur R, lu comme une espace insecable",
         .refus_noms(replace(annees, 7, .octets(c(0x32, 0x30, 0x32, 0x32, 0xa0), "unknown")),
                     "Annee d'accident en double : \"2022\", \"2022\\u00a0\" (lignes 6 et 7, i=5 et i=6)."))
# Encodage "bytes" : avant la reprise, citer() levait une erreur R
# (utf8ToInt() -> NA) que run_engine() propageait sans ok = FALSE. Depuis
# #321 (decision d'actuary), un nom d'encodage "bytes" ne recoit que son
# propre motif : il est exclu des controles de nom manquant et de doublon,
# ses caracteres n'etant pas determines.
.motif_bytes <- function(k) sprintf(paste(
  "Nom d'annee d'accident en ligne %d (i=%d) declare d'encodage \"bytes\" :",
  "ses caracteres ne sont pas determines ; fournir le nom en UTF-8 ou en",
  "Latin-1 declare."), k, k - 1L)
verifier("Noms de ligne (#268, #321) : encodage \"bytes\", octets UTF-8 (C2 A0) : seul le motif \"bytes\", pas de doublon, sans erreur R",
         .refus_noms(replace(annees, 7, .octets(c(0x32, 0x30, 0x32, 0x32, 0xc2, 0xa0), "bytes")),
                     .motif_bytes(7)))
verifier("Noms de ligne (#268, #321) : encodage \"bytes\", octets Latin-1 (A0) : seul le motif \"bytes\", pas de doublon, sans erreur R",
         .refus_noms(replace(annees, 7, .octets(c(0x32, 0x30, 0x32, 0x32, 0xa0), "bytes")),
                     .motif_bytes(7)))
verifier("Noms de ligne (#268, #321) : encodage \"bytes\", nom fait d'une seule espace insecable : seul le motif \"bytes\", pas de nom vide",
         .refus_noms(replace(annees, 3, .octets(c(0xc2, 0xa0), "bytes")),
                     .motif_bytes(3)))
verifier("Noms de ligne (#321) : nom \"bytes\" en ligne 3 et doublon ASCII \"2022\" en lignes 6 et 7 : deux motifs, positions d'origine",
         .refus_noms(replace(annees, c(3, 7), c(.octets(c(0x32, 0x30, 0xe9), "bytes"), "2022")),
                     c(.motif_bytes(3),
                       "Annee d'accident en double : \"2022\" (lignes 6 et 7, i=5 et i=6).")))
# Motifs par ligne interclasses dans l'ordre des lignes (nom manquant et
# "bytes"), doublons ensuite : avant cette reprise, le motif "bytes" de la
# ligne 4 precedait le motif de nom manquant de la ligne 2.
verifier("Noms de ligne (#321) : NA en ligne 2, \"bytes\" en ligne 4, vide en ligne 6 : motifs dans l'ordre des lignes",
         .refus_noms(c(annees[1], NA, annees[3], .octets(c(0x32, 0x30, 0xe9), "bytes"),
                       annees[5], "", annees[7:8]),
                     c("Nom d'annee d'accident manquant ou vide en ligne 2 (i=1).",
                       .motif_bytes(4),
                       "Nom d'annee d'accident manquant ou vide en ligne 6 (i=5).")))
# Un nom "bytes" retire de la lecture des autres noms : laisse dans le
# vecteur sans recodage, il ferait lire trimws() octet par octet pour tous
# les noms ("2022" suivi d'une espace insecable UTF-8 lu "2022\xc2", doublon
# manque ; mesure de la reprise).
verifier("Noms de ligne (#321) : nom \"bytes\" en ligne 3, \"2022\" suivi d'une espace insecable UTF-8 en ligne 7 : doublon de \"2022\" detecte",
         .refus_noms(replace(annees, c(3, 7), c(.octets(c(0x32, 0x30, 0xe9), "bytes"),
                                                paste0("2022", .u(0xA0)))),
                     c(.motif_bytes(3),
                       "Annee d'accident en double : \"2022\", \"2022\\u00a0\" (lignes 6 et 7, i=5 et i=6).")))
# Issue #321 : un nom non ASCII UNIQUE d'encodage "bytes" passait
# mw_valider_triangle() ; run_engine() rendait ensuite ok = FALSE avec
# l'erreur R interceptee "translating strings with "bytes" encoding is not
# allowed" (make.unique() dans .mw_noms_lignes_empilees()). Il est refuse par
# un motif metier, sans erreur_r, octets Latin-1 (32 30 E9) comme UTF-8
# (32 30 C3 A9) ; les memes octets en encodage "unknown" restent admis.
verifier("Noms de ligne (#321) : nom unique \"bytes\" a octets Latin-1 (32 30 E9) refuse par motif metier, sans erreur_r",
         .refus_noms(replace(annees, 4, .octets(c(0x32, 0x30, 0xe9), "bytes")),
                     .motif_bytes(4)))
verifier("Noms de ligne (#321) : nom unique \"bytes\" a octets UTF-8 (32 30 C3 A9) refuse par motif metier, sans erreur_r",
         .refus_noms(replace(annees, 4, .octets(c(0x32, 0x30, 0xc3, 0xa9), "bytes")),
                     .motif_bytes(4)))
verifier("Noms de ligne (#321) : deux noms \"bytes\" (lignes 2 et 8), un motif par ligne, dans l'ordre des lignes",
         .refus_noms(c(annees[1], .octets(c(0x32, 0x30, 0xe9), "bytes"), annees[3:7],
                       .octets(c(0x32, 0x31, 0xc3, 0xa9), "bytes")),
                     c(.motif_bytes(2), .motif_bytes(8))))
verifier("Noms de ligne (#321) : memes octets en encodage \"unknown\" admis, ok = TRUE sans erreur_r",
         all(vapply(list(c(0x32, 0x30, 0xe9), c(0x32, 0x30, 0xc3, 0xa9)), function(b) {
           r <- .run_noms(replace(annees, 4, .octets(b, "unknown")))
           isTRUE(r$ok) && is.null(r$validation$erreur_r)
         }, logical(1))))
# Nom declare UTF-8 dont les octets n'en sont pas (seconde reprise du
# 16/10/2026) : avant elle, trimws() levait l'erreur R "input string 3 is
# invalid UTF-8", propagee par run_engine() sans ok = FALSE. Relu en Latin-1
# (decision du mainteneur du 16/10/2026) : 32 FF FE -> "2", U+00FF, U+00FE.
.utf8_invalide <- .octets(c(0x32, 0xff, 0xfe), "UTF-8")
verifier("Noms de ligne (#268) : nom declare UTF-8 invalide (32 FF FE) seul : accepte sans erreur R, par mw_valider_triangle() et run_engine()",
         local({
           noms <- replace(annees, 3, .utf8_invalide)
           v <- tryCatch(mw_valider_triangle(`rownames<-`(tri_ref, noms)),
                         error = function(e) NULL)
           r <- tryCatch(.run_noms(noms), error = function(e) NULL)
           !is.null(v) && isTRUE(v$ok) && !is.null(r) && isTRUE(r$ok)
         }))
verifier("Noms de ligne (#268) : deux noms declares UTF-8 invalides identiques : doublon refuse sans erreur R, cite en Latin-1",
         .refus_noms(c(.utf8_invalide, .utf8_invalide, annees[3:8]),
                     paste0("Annee d'accident en double : \"2", .u(0xFF, 0xFE),
                            "\" (lignes 1 et 2, i=0 et i=1).")))
verifier("Noms de ligne (#268) : nom declare UTF-8 a octet A0 (32 30 32 32 A0) : doublon de \"2022\" refuse sans erreur R",
         .refus_noms(replace(annees, 7, .octets(c(0x32, 0x30, 0x32, 0x32, 0xa0), "UTF-8")),
                     "Annee d'accident en double : \"2022\", \"2022\\u00a0\" (lignes 6 et 7, i=5 et i=6)."))
# Parametre final identique, noms compris (issue #319) : avant sa correction,
# sous un triangle nomme, sigma_usp, sigma_estime, sigma_estime_brut et
# variation_relative portaient un nom de ligne ("2018" pour 2017:2024), pris
# par les sommes de mw_msep() sur les cumuls ultimes nommes ; l'assertion
# comparait alors les valeurs par unname().
verifier("Noms de ligne (#268, #319) : triangle sans noms et triangle a noms valides admis, parametre final identique",
         {
           r0 <- run_engine(methode = "reserve2", triangle = tri_ref, segment = 1,
                            annexe = "II", B = 99)
           r1 <- .run_noms(annees)
           isTRUE(r0$ok) && isTRUE(r1$ok) && !length(r1$validation$erreurs) &&
             identical(r0$parametre_final, r1$parametre_final)
         })
verifier("Parametre final sans nom (#319) : champs scalaires de parametre_final et msep sans nom sous un triangle nomme",
         {
           r1 <- .run_noms(annees)
           ms <- mw_msep(mw_ajuster(`rownames<-`(tri_ref, annees)))
           isTRUE(r1$ok) &&
             all(vapply(r1$parametre_final, function(x) is.null(names(x)), logical(1))) &&
             all(vapply(ms, function(x) is.null(names(x)), logical(1))) &&
             identical(ms, mw_msep(mw_ajuster(tri_ref)))
         })
# Lignes de mw_tests() sans nom (#319, reprise) : avant elle, l'estimation de
# la ligne "Part de la reserve portee par la derniere annee d'accident"
# portait le nom de la derniere ligne ("2024"), lu sur reserve_par_annee.
.champs_tests <- c("stat", "estim", "p_exacte", "p_asymptotique", "p_mc", "err_mc",
                   "p_retenue", "p_min", "p_min_mc", "mc_nom")
verifier("Tests sans nom (#319) : stat, estim et p-values de res$tests sans nom sous un triangle nomme ; res$tests et engine_table_tests() identiques",
         {
           r0 <- run_engine(methode = "reserve2", triangle = tri_ref, segment = 1,
                            annexe = "II", B = 99)
           r1 <- .run_noms(annees)
           isTRUE(r1$ok) &&
             all(vapply(r1$tests, function(t)
               all(vapply(intersect(.champs_tests, names(t)), function(ch) is.null(names(t[[ch]])),
                          logical(1))), logical(1))) &&
             identical(r0$tests, r1$tests) &&
             identical(engine_table_tests(r0), engine_table_tests(r1))
         })
verifier("Noms de ligne (#268) : data.frame a noms de ligne automatiques admis",
         isTRUE(run_engine(methode = "reserve2", triangle = as.data.frame(tri_ref),
                           segment = 1, annexe = "II", B = 99)$ok))

## --- Diagnostic par diagonale, repere de Mack 1997 (#275) -------------------
# Specification docs/specifications/fd-test-calendaire.md, par. 3.2 et 3.4 ;
# decisions Q-Fd-4 a Q-Fd-6 du mainteneur (14/10/2026).
# Resultat factice de mw_test_annees_calendaires() : une diagonale k par
# repartition (n, l), etiquettes "L" x l et "S" x (n - l).
cal_factice <- function(n, l, k = 0L, extra = NULL) {
  lab <- c(rep("L", l), rep("S", n - l), extra)
  list(etiquettes = data.frame(i = seq_along(lab) - 1L, j = 0L, diag = k, lab = lab,
                               stringsAsFactors = FALSE))
}
# Table de prob(Z_j <= z_j) de Mack (1997), D6, p. D6.49 : table recalculee
# sous la loi binomiale (spec. par. 3.4, valeurs a 4 decimales ; NA hors
# support) ; egalite avec la table publiee de D6.49 non verifiee, PDF hors
# depot.
table_d649 <- rbind(
  c(0.5, 1, NA, NA, NA, NA), c(0.25, 1, NA, NA, NA, NA),
  c(0.125, 0.625, 1, NA, NA, NA), c(0.0625, 0.375, 1, NA, NA, NA),
  c(0.03125, 0.21875, 0.6875, 1, NA, NA), c(0.015625, 0.125, 0.4531, 1, NA, NA),
  c(0.0078, 0.0703, 0.2891, 0.7266, 1, NA), c(0.0039, 0.0391, 0.1797, 0.5078, 1, NA),
  c(0.0020, 0.0215, 0.1094, 0.3438, 0.7539, 1), c(0.0010, 0.0117, 0.0654, 0.2266, 0.5488, 1))
# Effectifs de reference independants de choose() : triangle de Pascal par
# recurrence entiere.
pascal <- function(n) { v <- 1; for (k in seq_len(n)) v <- c(v, 0) + c(0, v); v }
verifier("mw_calendrier_diagonales() : p_diag par enumeration (Pascal), n = 2 a 11, toute repartition (L, S), <= 1 et = 1 au z maximal ; table recalculee sous la loi binomiale (spec. par. 3.4) a 5e-5, egalite avec la table publiee de D6.49 non verifiee, PDF hors depot (#275)",
         all(vapply(2:11, function(n) all(vapply(0:n, function(l) {
           d <- mw_calendrier_diagonales(cal_factice(n, l))
           z <- min(l, n - l)
           ref <- sum(pascal(n)[pmin(0:n, n - 0:n) <= z]) / 2^n
           nrow(d) == 1L && d$n == n && d$L == l && d$S == n - l && d$Z == z &&
             identical(d$p_diag, ref) && all(d$p_diag <= 1) &&
             (z < floor(n / 2) || identical(d$p_diag, 1)) &&
             abs(d$p_diag - table_d649[n - 1L, z + 1L]) <= 5e-5 &&
             identical(d$repere, ref <= 0.10)
         }, logical(1))), logical(1))))
verifier("mw_calendrier_diagonales() : repere a 10 % independant d'alpha, seulement a n_k >= 5 (P(Z <= 0) = 2^(1 - n)) (#275)",
         identical(REPERE_DIAGONALE_MACK_1997, 0.10) &&
           !mw_calendrier_diagonales(cal_factice(4, 0))$repere &&
           mw_calendrier_diagonales(cal_factice(5, 0))$repere &&
           identical(mw_calendrier_diagonales(cal_factice(5, 0))$p_diag, 2^-4))
verifier(".mw_n_min_repere_diagonale() : minimum d'etiquettes du detail derive du repere, 5 a 0,10, 6 a 0,05, 4 a 0,20, puissances de 2 exactes (0,125 -> 4, 0,0625 -> 5, 0,5 -> 2, 1 -> 1), coherent avec mw_calendrier_diagonales() au repere courant (#275)",
         identical(.mw_n_min_repere_diagonale(), 5L) &&
           identical(.mw_n_min_repere_diagonale(0.10), 5L) &&
           identical(.mw_n_min_repere_diagonale(0.05), 6L) &&
           identical(.mw_n_min_repere_diagonale(0.20), 4L) &&
           identical(.mw_n_min_repere_diagonale(0.125), 4L) &&
           identical(.mw_n_min_repere_diagonale(0.0625), 5L) &&
           identical(.mw_n_min_repere_diagonale(0.5), 2L) &&
           identical(.mw_n_min_repere_diagonale(1), 1L) && {
             n0 <- .mw_n_min_repere_diagonale()
             !mw_calendrier_diagonales(cal_factice(n0 - 1L, 0))$repere &&
               mw_calendrier_diagonales(cal_factice(n0, 0))$repere
           })
verifier("mw_calendrier_diagonales() : \"*\" ecartees, n_k < 2 ecartees, ordre de k, aucune diagonale -> 0 ligne (#275)",
         {
           e <- rbind(cal_factice(3, 1, k = 4L, extra = c("*", "*"))$etiquettes,
                      cal_factice(1, 1, k = 0L, extra = "*")$etiquettes,
                      cal_factice(2, 2, k = 2L)$etiquettes)
           d <- mw_calendrier_diagonales(list(etiquettes = e))
           v1 <- mw_calendrier_diagonales(cal_factice(1, 0, extra = c("*", "*")))
           v2 <- mw_calendrier_diagonales(list(etiquettes = list(lab = NULL)))
           identical(d$k, c(2L, 4L)) && identical(d$n, c(2L, 3L)) && identical(d$Z, c(0L, 1L)) &&
             nrow(v1) == 0L && nrow(v2) == 0L &&
             identical(names(v1), c("k", "n", "L", "S", "Z", "p_diag", "repere"))
         })
verifier("mw_calendrier_diagonales() : k, n_k et Z_k = ceux de la statistique globale (cal$detail), somme des Z_k = Z (#275)",
         all(vapply(list(tri_ref, tri_cal_haut, tri, ta), function(t) {
           cal <- mw_test_annees_calendaires(mw_ajuster(t))
           d <- mw_calendrier_diagonales(cal)
           identical(as.numeric(d$n), unname(cal$detail[, "n"])) &&
             identical(as.numeric(d$Z), unname(cal$detail[, "Z"])) &&
             identical(as.character(d$k), rownames(cal$detail)) &&
             sum(d$Z) == cal$Z && identical(d$L + d$S, d$n)
         }, logical(1))))
verifier("reserve2 (#275) : une seule diagonale reperee, k = 5, n = 6, Z = 0, P = 0,03125 ; ligne diagnostic INFO apres le test calendaire",
         {
           r <- run_mw(tri_ref)
           d <- mw_calendrier_diagonales(mw_test_annees_calendaires(r$ajustement))
           # designation par le nom, non par la position (l'insertion de la
           # ligne de #308 en fin de M1 a decale M2 a M6 d'un cran)
           noms <- vapply(r$tests, `[[`, "", "test")
           k <- match("Effets d'annee calendaire par diagonale (repere de Mack 1997)", noms)
           x <- r$tests[[k]]
           identical(d$k[d$repere], 5L) && d$n[d$repere] == 6L && d$Z[d$repere] == 0L &&
             identical(d$p_diag[d$repere], 0.03125) && all(d$p_diag <= 1) &&
             identical(noms[k - 1L], "Effets d'annee calendaire (test de Mack)") &&
             identical(x$type, "diagnostic") && identical(x$verdict, "INFO") &&
             identical(x$famille, r$tests[[k - 1L]]$famille) &&
             identical(x$fonction, "mw_calendrier_diagonales") && identical(x$estim, 1) &&
             identical(x$estim_nom, "diagonales sous le repere de 10 %") &&
             all(is.na(c(x$stat, x$p_exacte, x$p_asymptotique, x$p_mc, x$err_mc, x$p_retenue,
                         x$p_min, x$p_min_mc))) && is.na(x$nature_p) && is.na(x$sens) &&
             !x$inoperant &&
             # #514 (Q-3) : valeurs par diagonale retirees du detail (rendues
             # par mw_calendrier_diagonales(), verifiees ci-dessus).
             !grepl("k = 5 : n = 6", x$detail, fixed = TRUE) &&
             grepl("Le test est \"Effets d'annee calendaire (test de Mack)\", qui fait foi.", x$detail, fixed = TRUE) &&
             grepl("(nombre sous le repere de 10 % en estimation", x$detail, fixed = TRUE) &&
             !grepl("[^ -~]", x$detail)
         })
verifier("Diagnostic par diagonale sans diagonale retenue (#275) : estim NA, detail \"aucune diagonale retenue (n_k >= 2)\"",
         {
           # colonnes j = 1 et 2 a facteurs egaux (etiquettes "*") : seule la
           # colonne 0 etiquette, une etiquette par diagonale
           t <- matrix(NA_real_, 5, 5); t[, 1] <- c(100, 110, 120, 130, 140)
           t[1:4, 2] <- t[1:4, 1] * c(1.5, 1.6, 1.7, 1.55)
           t[1:3, 3] <- t[1:3, 2] * 1.2; t[1:2, 4] <- t[1:2, 3] * 1.1; t[1, 5] <- t[1, 4] * 1.05
           r <- run_mw(t)
           x <- r$tests[[which(vapply(r$tests, `[[`, "", "fonction") == "mw_calendrier_diagonales")]]
           nrow(mw_calendrier_diagonales(mw_test_annees_calendaires(r$ajustement))) == 0L &&
             identical(x$detail, "aucune diagonale retenue (n_k >= 2)") && is.na(x$estim) &&
             identical(x$verdict, "INFO") && identical(x$type, "diagnostic")
         })


## --- M1 : identifiabilite intra-colonne (#308) ------------------------------
# Specification Fj, par. 3.3 et 5 (T-3) ; decisions Q-D1-Fj-1 (forme F1 : une
# ligne de diagnostic en fin de M1, apres la famille alpha) et Q-D1-Fj-2 (CV_j,
# R_j, e_a,j ; aucun effet minimal detectable) du 22/10/2026. Oracle
# independant de S_j / D_j : element (1, 1) de (X'WX)^-1 de lm(C1 ~ C0,
# weights = 1/C0), lu dans summary()$cov.unscaled.
NOM308 <- "Identifiabilite intra-colonne (dispersion des cumuls par colonne)"
ligne308 <- function(L) L[[which(vapply(L, `[[`, "", "test") == NOM308)]]
# Textes de #514 (specification d'actuary, W6 ; Q-3) : les valeurs par
# colonne (CV, R, e_a) ne sont plus restituees dans le detail, qui ne depend
# plus que de l'existence d'une colonne retenue ; elles sont rendues par
# mw_identifiabilite_intra(), verifiee directement ci-dessous.
# Textes de #514 (specification finale d'actuary) : phrase d'usage, puis
# lignes liees ; valeurs par colonne rendues par mw_identifiabilite_intra().
LIE308 <- paste("Lignes liees : \"Nullite de l'ordonnee a l'origine, colonne par colonne\", \"Absence",
                "de tendance des facteurs avec le cumul, a colonne donnee\" et \"Adequation de",
                "l'exposant de variance, colonne par colonne\".")
TXT308 <- paste("Diagnostic sans verdict : moins les cumuls d'une colonne sont disperses (CV",
                "moyen en estimation, detail par mw_identifiabilite_intra()), moins les lignes",
                "liees sont puissantes.", LIE308)
TXT308_VIDE <- paste("Diagnostic sans verdict : aucune colonne retenue (n_j >= 3 hors colonnes",
                     "degenerees).", LIE308)
oracle308 <- function(t) {
  a <- mw_ajuster(t); ii <- mw_identifiabilite_intra(a)
  vapply(seq_len(nrow(ii$detail)), function(k) {
    j <- ii$detail$j[k]; i <- seq_len(a$I - j); C0 <- t[i, j + 1]; C1 <- t[i, j + 2]
    cu <- summary(stats::lm(C1 ~ C0, weights = 1 / C0))$cov.unscaled[1, 1]
    isTRUE(proche(ii$detail$e_a[k], sqrt(a$sigma2[j + 1] * cu) / mean(C1), 1e-10)) &&
      isTRUE(proche(ii$detail$cv[k], stats::sd(C0) / mean(C0), 1e-14)) &&
      isTRUE(proche(ii$detail$R[k], max(C0) / min(C0), 1e-14)) &&
      ii$detail$n[k] == length(i)
  }, logical(1))
}
verifier("Identifiabilite intra-colonne (#308) : e_a = sigma_j sqrt(S_j/D_j)/moyenne(C1), S_j/D_j = cov.unscaled[1, 1] de lm(C1 ~ C0, weights = 1/C0) a 1e-10 relatif ; CV, R, n_j ; reserve2 et Taylor & Ashe",
         { o1 <- oracle308(tri_ref); o2 <- oracle308(ta)
           length(o1) == 5L && all(o1) && length(o2) == 7L && all(o2) })
verifier("Identifiabilite intra-colonne (#308) : reserve2, colonnes j = 0..4, n_j = 7..3, CV, R, e_a du par. 3.3 de la specification Fj, estim = moyenne des CV = 0,07295",
         {
           ii <- mw_identifiabilite_intra(mw_ajuster(tri_ref)); d <- ii$detail
           identical(d$j, 0:4) && identical(d$n, 7:3) &&
             isTRUE(proche(d$cv, c(0.0739, 0.0763, 0.0796, 0.0751, 0.0599), 0, 5e-5)) &&
             isTRUE(proche(d$R, c(1.229, 1.211, 1.206, 1.182, 1.126), 0, 5e-4)) &&
             isTRUE(proche(d$e_a, c(0.0800, 0.0930, 0.0973, 0.0812, 0.0685), 0, 5e-5)) &&
             identical(ii$estim, mean(d$cv)) && isTRUE(proche(ii$estim, 0.07295, 0, 5e-6))
         })
verifier("Identifiabilite intra-colonne (#308) : reserve2, ligne de diagnostic juste apres la famille alpha (fin de M1), INFO, fonction, estim, p-values NA ; champs T-3 a la lettre",
         {
           r <- run_mw(tri_ref); noms <- vapply(r$tests, `[[`, "", "test")
           k <- match(NOM308, noms); x <- r$tests[[k]]
           identical(noms[k - 1L], "Stabilite du facteur selon la ponderation (famille alpha)") &&
             identical(x$famille, r$tests[[k - 1L]]$famille) && startsWith(x$famille, "M1") &&
             !startsWith(r$tests[[k + 1L]]$famille, "M1") &&
             identical(x$type, "diagnostic") && identical(x$verdict, "INFO") &&
             identical(x$fonction, "mw_identifiabilite_intra") && identical(x$inoperant, FALSE) &&
             identical(x$estim_nom, "CV moyen des colonnes retenues") &&
             identical(x$estim, mw_identifiabilite_intra(r$ajustement)$estim) &&
             all(is.na(c(x$stat, x$p_exacte, x$p_asymptotique, x$p_mc, x$err_mc, x$p_retenue,
                         x$p_min, x$p_min_mc))) &&
             is.na(x$H0) && is.na(x$H1) && is.na(x$nature_p) && is.na(x$sens) &&
             identical(x$reference, paste(
               "Construction de l'outil : dispersion de C(i,j) a colonne donnee et erreur type de",
               "l'ordonnee a l'origine de la regression ponderee C(.,j+1) ~ a_j + b_j C(.,j), poids",
               "1/C(.,j) (Mack 1994, CAS Forum, chap. 5, p. 121-123), sous H0, sigma_j de Mack (1993)")) &&
             identical(x$detail, TXT308) && !grepl("[^ -~]", x$detail)
         })
verifier("Identifiabilite intra-colonne (#308) : colonne C(i,j) constante (D_j = 0) -> e_a NA, CV = 0, R = 1, texte \"e_a non definie (C(i,j) constant)\"",
         {
           t <- matrix(NA_real_, 5, 5); t[, 1] <- c(100, 100, 100, 100, 140)
           t[1:4, 2] <- t[1:4, 1] * c(1.5, 1.6, 1.7, 1.55); t[1:3, 3] <- t[1:3, 2] * c(1.2, 1.25, 1.18)
           t[1:2, 4] <- t[1:2, 3] * c(1.1, 1.08); t[1, 5] <- t[1, 4] * 1.05
           d <- mw_identifiabilite_intra(mw_ajuster(t))$detail; x <- ligne308(run_mw(t)$tests)
           identical(d$j, 0:1) && is.na(d$e_a[1]) && identical(d$cv[1], 0) && identical(d$R[1], 1) &&
             is.finite(d$e_a[2]) &&
             isTRUE(proche(d$cv[2], 0.0625, 0, 5e-5)) && isTRUE(proche(d$R[2], 1.133, 0, 5e-4)) &&
             isTRUE(proche(d$e_a[2], 0.3398, 0, 5e-5)) &&
             identical(x$detail, TXT308)
         })
verifier("Identifiabilite intra-colonne (#308) : colonne degeneree exclue (triangle td de M4, j = 0) ; retenue si j_degeneres = integer(0), les autres colonnes inchangees",
         {
           # td de la section M4 (#300, #352) : tri_nb300, colonne j = 0 a
           # facteurs tous egaux a 1,5 (tri_nb300 est defini plus bas)
           td <- matrix(NA_real_, 6, 6); td[, 1] <- c(100, 120, 90, 110, 130, 105)
           td[1:5, 2] <- td[1:5, 1] * 1.5; td[1:4, 3] <- td[1:4, 2] * c(1.20, 1.31, 1.17, 1.26)
           td[1:3, 4] <- td[1:3, 3] * c(1.08, 1.12, 1.05); td[1:2, 5] <- td[1:2, 4] * c(1.03, 1.04)
           td[1, 6] <- td[1, 5] * 1.01
           ad <- mw_ajuster(td)
           d0 <- mw_identifiabilite_intra(ad)$detail
           d1 <- mw_identifiabilite_intra(ad, j_degeneres = integer(0))$detail
           x <- ligne308(run_mw(td)$tests)
           0L %in% .mw_ensembles_figes(ad)$degeneres &&
             identical(d0$j, 1:2) && identical(d1$j, 0:2) &&
             identical(as.list(d1[d1$j != 0L, ]), as.list(d0)) &&
             identical(x$detail, TXT308)
         })
verifier("Identifiabilite intra-colonne (#308) : aucune colonne retenue (j = 0 et 1 degenerees) -> estim NA, texte \"Aucune colonne retenue (n_j >= 3).\"",
         {
           t <- matrix(NA_real_, 5, 5); t[, 1] <- c(100, 110, 120, 130, 140)
           t[1:4, 2] <- t[1:4, 1] * 1.5; t[1:3, 3] <- t[1:3, 2] * 1.2
           t[1:2, 4] <- t[1:2, 3] * c(1.1, 1.08); t[1, 5] <- t[1, 4] * 1.05
           ii <- mw_identifiabilite_intra(mw_ajuster(t)); x <- ligne308(run_mw(t)$tests)
           is.na(ii$estim) && !nrow(ii$detail) && is.na(x$estim) && identical(x$verdict, "INFO") &&
             identical(x$detail, TXT308_VIDE)
         })
# Format de R et de e_a hors de [1e-3 ; 1e6[ (#364, decision Q-44-4 (b) du
# mainteneur du 30/10/2026) : depuis #514 (Q-3), les valeurs par colonne ne
# sont plus imprimees dans le detail et .mw_format_echelle() est retiree ;
# les valeurs de la mesure de l'issue (triangle_mw.csv dont la ligne 0 est
# multipliee par 1e-14 ou par 1e15) sont verifiees sur
# mw_identifiabilite_intra(), formatees ici par sprintf().
local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"
  m <- unname(m)
  ligne0 <- function(fact) { t <- m; t[1, ] <- t[1, ] * fact; t }
  # Valeurs de la mesure de l'issue, sur mw_identifiabilite_intra() (#514).
  valeurs364 <- function(fact) {
    d <- mw_identifiabilite_intra(mw_ajuster(ligne0(fact)))$detail
    sprintf("j = %d : n_j = %d, CV = %.4f, R = %s, e_a = %s", d$j, d$n, d$cv,
            sprintf("%.3e", d$R), sprintf("%.3e", d$e_a))
  }
  verifier("Identifiabilite intra-colonne (#364) : ligne 0 x 1e-14 -> R en 1.229e+14, e_a non nul en notation scientifique (valeurs de mw_identifiabilite_intra(), detail sans valeurs, #514)",
           {
             x <- ligne308(run_mw(ligne0(1e-14))$tests)
             identical(valeurs364(1e-14), c(
               "j = 0 : n_j = 7, CV = 0.4460, R = 1.229e+14, e_a = 1.577e-09",
               "j = 1 : n_j = 6, CV = 0.4957, R = 1.211e+14, e_a = 1.559e-09",
               "j = 2 : n_j = 5, CV = 0.5650, R = 1.206e+14, e_a = 1.074e-09",
               "j = 3 : n_j = 4, CV = 0.6709, R = 1.182e+14, e_a = 6.009e-10",
               "j = 4 : n_j = 3, CV = 0.8677, R = 1.126e+14, e_a = 8.186e-10")) &&
               identical(x$detail, TXT308)
           })
  verifier("Identifiabilite intra-colonne (#364) : ligne 0 x 1e15 -> R en 9.633e+14 ..., e_a de l'ordre de 1e-17 non nul (valeurs de mw_identifiabilite_intra(), detail sans valeurs, #514)",
           {
             x <- ligne308(run_mw(ligne0(1e15))$tests)
             identical(valeurs364(1e15), c(
               "j = 0 : n_j = 7, CV = 2.6458, R = 9.633e+14, e_a = 4.685e-17",
               "j = 1 : n_j = 6, CV = 2.4495, R = 9.809e+14, e_a = 7.109e-17",
               "j = 2 : n_j = 5, CV = 2.2361, R = 9.849e+14, e_a = 8.381e-17",
               "j = 3 : n_j = 4, CV = 2.0000, R = 9.714e+14, e_a = 5.057e-17",
               "j = 4 : n_j = 3, CV = 1.7321, R = 9.535e+14, e_a = 1.321e-17")) &&
               identical(x$detail, TXT308)
           })
})


## --- M2 : heteroscedasticite residuelle a effets fixes de colonne (#301) -----
# Variante FWr (decision Q-D2-Fi-1 du 21/10/2026) : LM = n R^2 partiel de
# r~^2 = r^2 / (1 - h) sur C avec effets fixes de colonne, colonnes n_j >= 3.
# Oracle independant : n [1 - SCR(y ~ factor(j) + C) / SCR(y ~ factor(j))]
# par lm(), 1 - h = 1 - C / S_j (forme directe, et non la somme des autres
# cellules du moteur).
fwr_oracle <- function(aj, res) {
  S <- stats::ave(res$C, res$j, FUN = sum)
  d <- data.frame(y = res$residu^2 / (1 - res$C / S), C = res$C, j = factor(res$j))
  nj <- stats::ave(res$C, res$j, FUN = length)
  d <- droplevels(d[nj >= 3, ])
  m0 <- stats::lm(y ~ j, d); m1 <- stats::lm(y ~ j + C, d)
  nrow(d) * (1 - sum(stats::resid(m1)^2) / sum(stats::resid(m0)^2))
}
tri_r2 <- local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
verifier("M2 (#301) : LM = n R^2 partiel (oracle lm() a effets fixes de colonne), reserve2 et triangle 5 x 5 ; p = chi2(1)",
         {
           ok <- vapply(list(tri_r2, tri), function(t) {
             a <- mw_ajuster(t); rs <- mw_residus(a)
             h <- mw_test_heteroscedasticite_intra(a, rs)
             isTRUE(proche(h$stat, fwr_oracle(a, rs), rel = 1e-9)) &&
               isTRUE(proche(h$p, 1 - stats::pchisq(fwr_oracle(a, rs), 1), rel = 1e-9))
           }, logical(1))
           all(ok)
         })
verifier("M2 (#301) : reserve2, 25 cellules dans 5 colonnes (n_j >= 3), LM = 1,4373 (spec. Fi, par. 3.2)",
         {
           a <- mw_ajuster(tri_r2); h <- mw_test_heteroscedasticite_intra(a, mw_residus(a))
           identical(h$n, 25L) && identical(h$K, 5L) && isTRUE(round(h$stat, 4) == 1.4373) &&
             isTRUE(round(h$p, 4) == 0.2306)
         })
verifier("M2 (#301) : colonnes n_j <= 2 exclues (residus de la colonne n_j = 2 sans effet ; triangle 3 x 3 -> NA, n = 0)",
         {
           a <- mw_ajuster(tri_r2); rs <- mw_residus(a)
           rs2 <- rs; k <- rs2$j == 5
           rs2$residu[k] <- rs2$residu[k] * c(7, -0.1)
           h1 <- mw_test_heteroscedasticite_intra(a, rs)
           h2 <- mw_test_heteroscedasticite_intra(a, rs2)
           t3 <- matrix(NA_real_, 3, 3); t3[, 1] <- c(100, 110, 120)
           t3[1:2, 2] <- c(150, 170); t3[1, 3] <- 180
           a3 <- mw_ajuster(t3); h3 <- mw_test_heteroscedasticite_intra(a3, mw_residus(a3))
           sum(k) == 2L && identical(h1$stat, h2$stat) &&
             is.na(h3$stat) && is.na(h3$p) && identical(h3$n, 0L)
         })
verifier("M2 (#301) : garde NA si C constant dans chaque colonne retenue, ou si r~^2 constant a colonne donnee (SCR = 0)",
         {
           aj5 <- list(I = 5L, tri = matrix(c(rep(100, 5), rep(150, 4), NA, rep(170, 3), NA, NA,
                                              rep(NA, 5), rep(NA, 5)), 5, 5))
           rc <- data.frame(i = c(0:3, 0:2), j = c(rep(0, 4), rep(1, 3)), C = c(rep(100, 4), rep(150, 3)),
                            residu = c(1.2, -0.3, 0.5, -1.4, 0.8, -1.1, 0.3))
           hc <- mw_test_heteroscedasticite_intra(aj5, rc)
           a <- mw_ajuster(tri_r2); rs <- mw_residus(a); rs$residu <- 0
           h0 <- mw_test_heteroscedasticite_intra(a, rs)
           is.na(hc$stat) && is.na(hc$p) && identical(hc$n, 7L) &&
             is.na(h0$stat) && is.na(h0$p) && identical(h0$n, 25L)
         })
verifier("M2 (#301) : ligne de mw_tests() = entree BP du catalogue (statistique observee identique), fonction, H0, loi, detail sans nombre du bootstrap",
         {
           a <- mw_ajuster(tri_r2); b <- mw_bootstrap(a, B = 99)
           L <- mw_tests(a, b)
           x <- L[[which(vapply(L, `[[`, "", "test") == "Heteroscedasticite residuelle vs cumul")]]
           identical(x$stat, unname(b$stats_obs[["BP"]])) &&
             identical(x$stat, mw_test_heteroscedasticite_intra(a, mw_residus(a))$stat) &&
             identical(x$fonction, "mw_test_heteroscedasticite_intra") &&
             identical(x$H0, "a colonne donnee, l'echelle des residus de Mack redresses ne depend pas de C(i,j)") &&
             identical(x$loi, "chi2(1) asymptotique (effets fixes de colonne) -> Monte-Carlo") &&
             identical(x$p_retenue, x$p_mc) && identical(x$nature_p, "Monte-Carlo (bootstrap de residus)") &&
             # Texte de #514 (specification finale d'actuary) ; la construction
             # (Frisch-Waugh, colonnes n_j >= 3) est dans la fiche.
             identical(x$detail, paste(
               "Un ECHEC ou une ALERTE signale une variance des residus de Mack liee au cumul a",
               "colonne donnee, contraire a une variance proportionnelle a C(i,j). A lire avec",
               "\"Adequation de l'exposant de variance, colonne par colonne\", meme hypothese, et",
               "\"Variance unitaire des residus de Mack\".")) &&
             !grepl(format(x$p_mc), x$detail, fixed = TRUE)
         })

## --- M4 : cellule aberrante, residus studentises externes (#300) -------------
# Variante MinP4 (decision Q-D2-Fi-2 du 21/10/2026 ; specification Fi, par.
# 4.1 a 4.4) : M = min_{(i,j)} p_ij, p_ij = 2 F_Student(n_j - 2)(-|t(i,j)|),
# colonnes n_j >= 4 hors colonnes degenerees ; cellule a influence non
# bornee : statistique observee non definie (option (iii), Q-D1-Fi-8),
# p_ij = 0 en replication. Rosner sur residus de Mack : diagnostic par
# decision (Q-D1-Fi-7), phrase fixe du premier complement.
# Oracle independant de t(i,j) : stats::rstudent() de la regression ponderee
# lm(C(.,j+1) ~ 0 + C(.,j), weights = 1/C(.,j)), colonne par colonne.
rstudent_col300 <- function(tr, j) {
  n <- sum(!is.na(tr[, j + 2]))
  x <- tr[seq_len(n), j + 1]; y <- tr[seq_len(n), j + 2]
  unname(stats::rstudent(stats::lm(y ~ 0 + x, weights = 1 / x)))
}
verifier("M4 (#300) : t(i,j) = stats::rstudent() a 1e-13 pres sur reserve2, colonnes j = 0 a 3 (retenues) et j = 4 (n_j = 3, seuil abaisse le temps du test)",
         {
           a <- mw_ajuster(tri_r2); ca <- mw_test_cellule_aberrante(a)
           ok03 <- all(vapply(0:3, function(j) {
             tj <- ca$cellules$t[ca$cellules$j == j]
             isTRUE(max(abs(tj - rstudent_col300(tri_r2, j))) <= 1e-13 * max(1, max(abs(tj))))
           }, logical(1)))
           env <- environment(mw_test_cellule_aberrante)
           seuil <- get("MW_NJ_MIN_CELLULE", envir = env)
           ca3 <- tryCatch({ assign("MW_NJ_MIN_CELLULE", 3L, envir = env); mw_test_cellule_aberrante(a) },
                           finally = assign("MW_NJ_MIN_CELLULE", seuil, envir = env))
           t4 <- ca3$cellules$t[ca3$cellules$j == 4]
           ok4 <- length(t4) == 3L && isTRUE(max(abs(t4 - rstudent_col300(tri_r2, 4))) <= 1e-13 * max(1, max(abs(t4))))
           ok03 && ok4 && identical(get("MW_NJ_MIN_CELLULE", envir = env), 4L)
         })
verifier("M4 (#300) : reserve2, M = 0,1033, cellule (0,2), n_j = 5, t = -2,318, N_t = 22, Bonferroni min(1, N_t M) = 1 ; p_ij = 2 pt(-|t|, n_j - 2)",
         {
           ca <- mw_test_cellule_aberrante(mw_ajuster(tri_r2))
           c3 <- ca$cellules
           isTRUE(round(ca$stat, 4) == 0.1033) && identical(ca$i, 0L) && identical(ca$j, 2L) &&
             identical(ca$n_j, 5L) && isTRUE(round(ca$t, 3) == -2.318) && identical(ca$N_t, 22L) &&
             identical(ca$p, 1) && identical(ca$stat, min(c3$p)) &&
             isTRUE(all.equal(c3$p, 2 * stats::pt(-abs(c3$t), c3$n_j - 2), tolerance = 1e-15)) &&
             !nrow(ca$non_borne)
         })
verifier("M4 (#300) : colonnes n_j <= 3 exclues (C(i,5) modifies : M, t et N_t identiques ; aucune cellule de colonne n_j < 4) ; colonne degeneree passee exclue",
         {
           a <- mw_ajuster(tri_r2); ca <- mw_test_cellule_aberrante(a)
           t2 <- tri_r2; t2[1:3, 6] <- t2[1:3, 6] * c(1.3, 0.8, 1.1)
           ca2 <- mw_test_cellule_aberrante(mw_ajuster(t2))
           cd <- mw_test_cellule_aberrante(a, j_degeneres = 0L)
           all(ca$cellules$n_j >= 4L) && setequal(unique(ca$cellules$j), 0:3) &&
             identical(ca2$stat, ca$stat) && identical(ca2$cellules, ca$cellules) &&
             identical(cd$N_t, 15L) && !any(cd$cellules$j == 0L)
         })
# Triangle 6 x 6 : colonne j = 0 (n_j = 5), F(i,0) = 1,5 sauf F(2,0) = 1,8 :
# a la cellule (2,0) retiree, les quatre autres cellules sont exactement
# proportionnelles (influence non bornee, dfbetas_non_borne), sans que la
# colonne soit degeneree.
tri_nb300 <- local({
  m <- matrix(NA_real_, 6, 6)
  m[, 1] <- c(100, 120, 90, 110, 130, 105)
  m[1:5, 2] <- m[1:5, 1] * c(1.5, 1.5, 1.8, 1.5, 1.5)
  m[1:4, 3] <- m[1:4, 2] * c(1.20, 1.31, 1.17, 1.26)
  m[1:3, 4] <- m[1:3, 3] * c(1.08, 1.12, 1.05)
  m[1:2, 5] <- m[1:2, 4] * c(1.03, 1.04)
  m[1, 6] <- m[1, 5] * 1.01
  m
})
verifier("M4 (#300) option (iii) : cellule (2,0) a influence non bornee -> statistique observee NA (Bonferroni NA), cellule nommee ; en replication p_ij = 0, M = 0",
         {
           a <- mw_ajuster(tri_nb300)
           o <- mw_test_cellule_aberrante(a); r <- mw_test_cellule_aberrante(a, replique = TRUE)
           !(0L %in% .mw_ensembles_figes(a)$degeneres) &&
             is.na(o$stat) && is.na(o$p) && identical(o$N_t, 9L) && is.null(o$cellules) &&
             identical(o$non_borne, data.frame(i = 2L, j = 0L)) &&
             identical(r$stat, 0) && identical(r$p, 0) && identical(r$i, 2L) && identical(r$j, 0L) &&
             identical(r$cellules$p[r$cellules$non_borne], 0) &&
             identical(.mw_motif_cellule_non_bornee(o), paste(
               "statistique observee non definie : residu studentise non borne en cellule (2,0)",
               "(autres cellules de la colonne proportionnelles)")) &&
             is.na(.mw_motif_cellule_non_bornee(mw_test_cellule_aberrante(mw_ajuster(tri_r2))))
         })
verifier("M4 (#300) option (iii) : mw_bootstrap() -> stats_obs MinP4 NA, motif propre (non_definie) ; mw_tests() -> p Monte-Carlo et Bonferroni NA, verdict INFO, motif en tete du detail",
         {
           a <- mw_ajuster(tri_nb300); b <- mw_bootstrap(a, B = 19)
           L <- mw_tests(a, b)
           x <- L[[which(vapply(L, `[[`, "", "test") == "Cellule aberrante du triangle (residus studentises externes)")]]
           motif <- .mw_motif_cellule_non_bornee(mw_test_cellule_aberrante(a))
           is.na(b$stats_obs[["MinP4"]]) && identical(unname(b$motif_mc[["MinP4"]]), motif) &&
             is.na(x$p_mc) && is.na(x$p_asymptotique) && is.na(x$p_retenue) && identical(x$verdict, "INFO") &&
             startsWith(x$detail, paste0("Monte-Carlo indisponible : ", motif, ", aucune p-value disponible")) &&
             is.na(x$estim)
         })
verifier("M4 (#300) : .mw_stats() evalue comme observe par defaut (MinP4 NA sur tri_nb300), en replication avec replique = TRUE (MinP4 = 0)",
         {
           a <- mw_ajuster(tri_nb300); fg <- .mw_ensembles_figes(a)
           is.na(.mw_stats(a, fg)[["MinP4"]]) && identical(.mw_stats(a, fg, replique = TRUE)[["MinP4"]], 0) &&
             identical(.mw_stats(a, fg)[["MinP4"]], .mc_evaluer(MW_CATALOGUE_MC, .mw_contexte_mc(a, fg))[["MinP4"]])
         })
verifier("M4 (#300) : gardes NA (aucune colonne n_j >= 4 : N_t = 0 ; colonne retenue de t NA hors non-borne : statistique NA, en replication aussi)",
         {
           t4 <- tri_nb300[1:4, 1:4]; t4[row(t4) + col(t4) > 5] <- NA
           c4 <- mw_test_cellule_aberrante(mw_ajuster(t4))
           td <- tri_nb300; td[1:5, 2] <- td[1:5, 1] * 1.5
           ad <- mw_ajuster(td)
           cn <- mw_test_cellule_aberrante(ad, j_degeneres = integer(0))
           cr <- mw_test_cellule_aberrante(ad, j_degeneres = integer(0), replique = TRUE)
           cx <- mw_test_cellule_aberrante(ad)
           is.na(c4$stat) && is.na(c4$p) && identical(c4$N_t, 0L) &&
             0L %in% .mw_ensembles_figes(ad)$degeneres &&
             is.na(cn$stat) && is.na(cr$stat) && !nrow(cn$non_borne) &&
             is.finite(cx$stat) && identical(cx$N_t, 4L)
         })
# Frontiere numerique de l'influence non bornee (#352, specification Fj,
# par. 2.3, decision Q-D1-Fj-9 du 22/10/2026) : tri_nb300 dont F(1,0) et
# F(3,0) sont multiplies par 1 + eps et 1 - eps, colonnes suivantes
# reconstruites par les memes facteurs. Frontiere mesuree entre 2e-8 et 3e-8 ;
# eps = 1e-10 et 1e-6 en sont loin dans les deux sens.
tri_nb300_eps <- function(eps) {
  m <- matrix(NA_real_, 6, 6)
  m[, 1] <- c(100, 120, 90, 110, 130, 105)
  m[1:5, 2] <- m[1:5, 1] * c(1.5, 1.5 * (1 + eps), 1.8, 1.5 * (1 - eps), 1.5)
  m[1:4, 3] <- m[1:4, 2] * c(1.20, 1.31, 1.17, 1.26)
  m[1:3, 4] <- m[1:3, 3] * c(1.08, 1.12, 1.05)
  m[1:2, 5] <- m[1:2, 4] * c(1.03, 1.04)
  m[1, 6] <- m[1, 5] * 1.01
  m
}
verifier("M4 (#352) : frontiere numerique, eps = 1e-10 -> influence non bornee en (2,0), statistique NA ; mw_tests() : test sans p-value retenue, INFO, non inoperant",
         {
           a <- mw_ajuster(tri_nb300_eps(1e-10)); ca <- mw_test_cellule_aberrante(a)
           L <- mw_tests(a, mw_bootstrap(a, B = 19))
           x <- L[[which(vapply(L, `[[`, "", "test") == "Cellule aberrante du triangle (residus studentises externes)")]]
           is.na(ca$stat) && identical(ca$non_borne, data.frame(i = 2L, j = 0L)) &&
             identical(x$type, "test") && identical(x$verdict, "INFO") &&
             is.na(x$p_retenue) && identical(x$inoperant, FALSE) && is.na(x$nature_p) &&
             startsWith(x$detail, paste("Monte-Carlo indisponible : statistique observee non definie :",
                                        "residu studentise non borne en cellule (2,0)"))
         })
verifier("M4 (#352) : frontiere numerique, eps = 1e-6 -> statistique definie (finie, > 0), aucune cellule non bornee, |t(2,0)| > 1e5 (pas d'assertion de verdict : il depend de B)",
         {
           ca <- mw_test_cellule_aberrante(mw_ajuster(tri_nb300_eps(1e-6)))
           t20 <- ca$cellules$t[ca$cellules$i == 2L & ca$cellules$j == 0L]
           is.finite(ca$stat) && ca$stat > 0 && nrow(ca$non_borne) == 0 &&
             length(t20) == 1 && abs(t20) > 1e5
         })
# Texte de l'avertissement (#363, decision Q-44-3 (a)), a la lettre, ecrit ici
# sans relire la constante du moteur : les lignes qui ecartent aussi les
# colonnes degenerees sans reposer sur les residus (cellule aberrante de #352
# comprise), apres la liste des lignes fondees sur les residus et avant la
# phrase du pool. Triangle td : colonne j = 0 degeneree.
verifier("Avertissement des colonnes degenerees (#363) : les lignes qui ecartent aussi ces colonnes sans reposer sur les residus sont nommees a la lettre, apres la liste des lignes fondees sur les residus et avant la phrase du pool (triangle td, colonne j = 0 degeneree)",
         {
           td <- tri_nb300; td[1:5, 2] <- td[1:5, 1] * 1.5
           av <- av_exclues(run_mw(td)$validation$avertissements)
           length(av) == 1 &&
             grepl(paste0("fondees sur ces residus, soit ", .MW_LIGNES_RESIDUS_TEXTE, ". ",
                          "Les autres lignes qui ecartent aussi ces colonnes de leur calcul, sans reposer sur ces ",
                          "residus, sont : ",
                          "M1 (\"Nullite de l'ordonnee a l'origine, colonne par colonne\" ; ",
                          "\"Homogeneite de f_j entre annees de survenance\" ; ",
                          "\"Absence de courbure de la regression\" ; ",
                          "\"Identifiabilite intra-colonne (dispersion des cumuls par colonne)\"), ",
                          "M3 (\"Effets d'annee calendaire (test de Mack)\" ; ",
                          "\"Effets d'annee calendaire par diagonale (repere de Mack 1997)\" ; ",
                          "\"Correlation entre annees de developpement adjacentes\"), ",
                          "M4 (\"Cellule aberrante du triangle (residus studentises externes)\") ; ",
                          "la statistique de la ligne M4 \"Cellule aberrante du triangle (residus studentises externes)\" ",
                          "est calculee sur les residus studentises externes de chaque colonne, et non sur ces residus. ",
                          "Le pool de reechantillonnage du bootstrap"), av, fixed = TRUE)
         })
# reserve2 a B = 999, graine par defaut (cas reserve2 de tests/outils_tests.R) :
# decomptes de la specification Fi, par. 4.4 et decisions Q-D1-Fi-7 et
# Q-D2-Fi-2 ; environ 35 s.
outils300 <- new.env(parent = globalenv())
sys.source(file.path(RACINE, "tests", "outils_tests.R"), envir = outils300)
res300 <- outils300$CAS$reserve2()
lig300 <- function(nom) Filter(function(l) identical(l$test, nom), res300$tests)[[1]]
verifier("M4 (#300) : ligne de mw_tests() = entree MinP4 du catalogue (statistique observee identique), fonction, H0, loi, Bonferroni en p non simulee, p Monte-Carlo retenue, detail sans nombre du bootstrap",
         {
           x <- lig300("Cellule aberrante du triangle (residus studentises externes)")
           a <- mw_ajuster(outils300$.tri); ca <- mw_test_cellule_aberrante(a)
           identical(x$stat, unname(res300$bootstrap$stats_obs[["MinP4"]])) && identical(x$stat, ca$stat) &&
             identical(x$fonction, "mw_test_cellule_aberrante") && identical(x$type, "test") &&
             identical(x$H0, "aucun residu de Mack aberrant") && identical(x$H1, "exactement un residu aberrant") &&
             identical(x$p_asymptotique, min(1, 22 * x$stat)) && identical(x$estim, ca$t) &&
             identical(x$p_retenue, x$p_mc) && identical(x$nature_p, "Monte-Carlo (bootstrap de residus)") &&
             identical(x$p_min, NA_real_) && identical(x$p_min_mc, NA_real_) &&
             is.null(MW_CATALOGUE_MC$MinP4$extremes) && identical(MW_CATALOGUE_MC$MinP4$queue, "bas") &&
             is.null(MW_CATALOGUE_MC$Grubbs) &&
             identical(x$reference, paste(
               "Residu studentise externe de la regression ponderee C(.,j+1) ~ 0 + C(.,j), poids 1/C(.,j),",
               "et sa loi de Student a n_j - 2 degres de liberte sous erreurs gaussiennes : Cook & Weisberg",
               "(1982), par. 2.2.1, p. 20, et annexe A.1, p. 209 (nom RSTUDENT : Belsley, Kuh & Welsch 1980,",
               "chap. 2) ; borne de Bonferroni sur le plus grand residu : Cook & Weisberg (1982), p. 22 et 26 ;",
               "construction de l'outil : minimum des p de Student entre colonnes de degres de liberte",
               "differents, colonnes n_j >= 4, p-value Monte-Carlo sur le modele de Mack")) &&
             identical(x$loi, "Student(n_j - 2) par cellule sous le modele auxiliaire gaussien, borne de Bonferroni -> Monte-Carlo") &&
             # Texte de #514 (specification finale d'actuary ; Q-3 : cellule du
             # minimum retiree du detail, t de la cellule en estim).
             startsWith(x$detail, paste(
               "Un ECHEC ou une ALERTE signale une cellule aberrante du triangle (plus petit",
               "residu studentise externe) parmi les N_t = 22 cellules des colonnes n_j >= 4, 3",
               "cellule(s) des colonnes n_j = 3 non couverte(s). A lire avec \"Cellules",
               "aberrantes multiples (ESD generalise)\".")) &&
             !grepl("Minimum en cellule", x$detail, fixed = TRUE) &&
             !grepl(format(x$p_mc), x$detail, fixed = TRUE) && !grepl(format(x$err_mc), x$detail, fixed = TRUE)
         })
verifier("M4 (#300) : reserve2, p_mc 0,898, Bonferroni 1, verdict OK ; B effectif = B",
         {
           x <- lig300("Cellule aberrante du triangle (residus studentises externes)")
           isTRUE(round(x$p_mc, 3) == 0.898) && identical(x$p_asymptotique, 1) && identical(x$verdict, "OK") &&
             identical(unname(res300$bootstrap$B_effectif[["MinP4"]]), 999)
         })
# Texte de #514 (specification finale d'actuary ; Q-3 : rangs des residus
# declares retires), qui remplace la phrase fixe du premier complement de la
# specification Fi (Q-D1-Fi-7).
verifier("Rosner (#300, #514) : diagnostic par decision, verdict INFO, estim_nom impose, phrase de #514 avec alpha (k^ = 0)",
         {
           x <- lig300("Cellules aberrantes multiples (ESD generalise)")
           ph <- paste("Repere du nombre de cellules aberrantes (ESD de Rosner a alpha = 0.10, nombre",
                       "en estimation), sans p-value : son cadre i.i.d. normal (n >= 25) ne couvre pas",
                       "les residus de Mack, contraints par colonne. Diagnostic sans verdict : la ligne",
                       "\"Cellule aberrante du triangle (residus studentises externes)\" fait foi.")
           identical(x$type, "diagnostic") && identical(x$verdict, "INFO") && identical(x$sens, NA_character_) &&
             identical(x$estim_nom, "nb de cellules declarees (repere de Rosner)") && identical(x$estim, 0) &&
             identical(x$fonction, "test_rosner") &&
             identical(x$detail, ph) && identical(x$detail, sprintf(PHRASE_MW_ROSNER_DIAGNOSTIC, 0.10))
         })
verifier("Rosner (#300, #514) : k^ > 0 -> rangs non restitues (Q-3), meme phrase, verdict INFO (k^ injecte)",
         {
           f <- mw_tests_modifie("ro <- test_rosner(r, alpha = alpha)",
                                 "ro <- list(nb_outliers = 2, positions = c(3L, 14L))")
           L <- f(at, boot_mw_fictif)
           x <- Filter(function(l) identical(l$test, "Cellules aberrantes multiples (ESD generalise)"), L)[[1]]
           identical(x$verdict, "INFO") && identical(x$estim, 2) &&
             identical(x$detail, sprintf(PHRASE_MW_ROSNER_DIAGNOSTIC, 0.10)) &&
             !grepl("3, 14", x$detail, fixed = TRUE)
         })
# Depuis #307 (pente relative, decision Q-D1-Fj-3 ; visa de principe
# Q-D1-Fj-10) : la ligne "Absence de tendance des facteurs avec le cumul, a
# colonne donnee" passe d'OK a ALERTE (specification Fj, par. 7) ; la famille
# alpha reste ECHEC (option (b'), Q-D1-Fj-5) ; 13 tests, 8 diagnostics.
# Depuis #312 (Q-D1-Fm-1 (B), specification Fm, par. 7) : le test des suites
# passe en diagnostic par decision, OK -> INFO ; 12 tests, 9 diagnostics.
# Depuis #297 (Q-D1-Fk-2 (a), Q-D1-Fk-3 (B), specification D1-Fk, par. 6) :
# lignes de famille M1, M2, M3 et ligne globale LC, diagnostics INFO ajoutes
# en fin ; 25 lignes, 12 tests, 13 diagnostics, INFO 13.
verifier("Decomptes reserve2 (#300, #308, #307, #312, #297) : 25 lignes (12 tests, 13 diagnostics), OK 5, INFO 13, ALERTE 3, ECHEC 4 ; sigma_USP = reference",
         {
           v <- vapply(res300$tests, `[[`, "", "verdict")
           ty <- vapply(res300$tests, `[[`, "", "type")
           ref <- readRDS(file.path(RACINE, "tests", "reference", "reserve2.rds"))
           length(res300$tests) == 25L &&
             identical(as.integer(table(factor(ty, c("test", "diagnostic")))), c(12L, 13L)) &&
             identical(as.integer(table(factor(v, c("OK", "INFO", "ALERTE", "ECHEC")))), c(5L, 13L, 3L, 4L)) &&
             isTRUE(all.equal(res300$parametre$sigma_usp, ref$parametre$sigma_usp, tolerance = 1e-6))
         })

## --- M1 : pente intra-colonne relative et famille alpha (#307) ---------------
# Specification Fj, par. 4.1, 4.3, 5 (T-4, T-5) et 7 ; decisions Q-D1-Fj-3
# (pente relative), Q-D1-Fj-4 (cle PenteIntra conservee) et Q-D1-Fj-5 (famille
# alpha, option (b')) du 22/10/2026. Lignes lues par leur nom dans res300
# (reserve2, B = 999, graine par defaut).
NOM307 <- "Absence de tendance des facteurs avec le cumul, a colonne donnee"
# Texte de #514 (specification d'actuary, W1 ; une phrase), qui remplace le
# texte T-4 de la specification Fj.
# Texte de #514 (specification finale d'actuary) ; la construction de la
# pente relative est dans la fiche.
DETAIL307 <- paste(
  "Un ECHEC ou une ALERTE signale un facteur de developpement qui varie",
  "avec le niveau du cumul a colonne donnee, contraire a la",
  "proportionnalite des cumules. A lire avec \"Nullite de l'ordonnee a",
  "l'origine, colonne par colonne\", dont une constante produit une telle",
  "pente, et \"Stabilite du facteur selon la ponderation (famille",
  "alpha)\".")
verifier("Pente relative (#307) : reserve2, ligne M1 = entree PenteIntra du catalogue (stat = bootstrap$stats_obs$PenteIntra), estim = b, p de Student en p non simulee non retenue, p Monte-Carlo retenue ; champs T-4 a la lettre",
         {
           x <- lig300(NOM307)
           pr <- .mw_pente_relative(mw_residus(res300$ajustement,
                                               .mw_colonnes_degenerees(res300$ajustement)))
           ok <- list(
             stat_obs = identical(x$stat, res300$bootstrap$stats_obs$PenteIntra),
             stat = identical(x$stat, pr[["t"]]),
             estim = identical(x$estim, pr[["b"]]),
             p_as = identical(x$p_asymptotique, pr[["p"]]),
             p_mc = identical(x$p_mc, res300$bootstrap$p_mc[["PenteIntra"]]) &&
               identical(x$p_retenue, x$p_mc),
             nature = identical(x$nature_p, "Monte-Carlo (bootstrap de residus)"),
             type = identical(x$type, "test") && startsWith(x$famille, "M1"),
             fonction = identical(x$fonction, ".mw_pente_relative"),
             stat_nom = identical(x$stat_nom, "t"),
             estim_nom = identical(x$estim_nom, "pente relative b"),
             H0 = identical(x$H0, "a annee de developpement donnee, le facteur ne depend pas du niveau de C(i,j)"),
             H1 = identical(x$H1, paste0("le facteur relatif F(i,j)/f_j varie avec le volume relatif ",
                                         "C(i,j)/Cbar_j, selon une pente commune aux colonnes")),
             loi = identical(x$loi, "Student(N - G - 1) approx. (pente relative, effets fixes de colonne) -> Monte-Carlo"),
             reference = identical(x$reference, paste0(
               "Mack (1993), ASTIN Bulletin 23(2), section 2, hyp. (1) ; section 3, hyp. (3) ; ",
               "pente relative commune a effets fixes de colonne : construction de l'outil ",
               "(partialisation de Frisch & Waugh, 1933, Econometrica 1(4))")),
             detail = identical(x$detail, DETAIL307) ||
               identical(x$detail, paste(DETAIL307, PHRASE_VERDICT_SENSIBLE_MC)),
             ascii = !grepl("[^ -~]", paste(x$detail, x$reference, x$H1, x$loi)))
           k <- !vapply(ok, isTRUE, logical(1))
           if (!any(k)) TRUE else paste("ecart :", paste(names(ok)[k], collapse = ", "))
         })
verifier("Pente relative (#307) : reserve2, t = 1,7330, b = 0,0592, p_as = 0,0985, p_mc 0,090, ALERTE, phrase de #244 en fin de detail (|0,090 - 0,10| < 2 err_mc) (specification Fj, par. 7)",
         {
           x <- lig300(NOM307)
           isTRUE(proche(x$stat, 1.7330, rel = 0, abs = 5e-5)) &&
             isTRUE(proche(x$estim, 0.0592, rel = 0, abs = 5e-5)) &&
             isTRUE(proche(x$p_asymptotique, 0.0985, rel = 0, abs = 5e-5)) &&
             isTRUE(proche(x$p_mc, 0.090, rel = 1e-12)) && identical(x$verdict, "ALERTE") &&
             abs(x$p_mc - 0.10) < 2 * x$err_mc &&
             identical(x$detail, paste(DETAIL307, PHRASE_VERDICT_SENSIBLE_MC))
         })
verifier("Pente relative (#307) : gardes de .mw_pente_relative() -> b, se, t, p NA : moins de 4 cellules, sigma_j nul, ddl < 1, Sxx = 0 ; finie a ddl = 1",
         {
           r <- data.frame(j = c(0L, 0L, 0L, 1L, 1L), C = c(10, 12, 15, 20, 26),
                           F = c(1.5, 1.4, 1.6, 1.1, 1.2), f_chapeau = c(1.5, 1.5, 1.5, 1.15, 1.15),
                           sigma_j = c(0.1, 0.1, 0.1, 0.05, 0.05))
           na4 <- c(b = NA_real_, se = NA_real_, t = NA_real_, p = NA_real_)
           s0 <- r; s0$sigma_j[4:5] <- 0
           d0 <- r[c(1, 2, 4, 5), ]            # 4 cellules, 2 colonnes : ddl = 1
           d3 <- d0; d3$j <- c(0L, 0L, 1L, 2L) # 4 cellules, 3 colonnes : ddl = 0
           d4 <- d0; d4$j <- 0:3               # une cellule par colonne : Sxx = 0
           all(is.finite(.mw_pente_relative(r))) &&
             identical(.mw_pente_relative(r[1:3, ]), na4) &&
             identical(.mw_pente_relative(s0), na4) &&
             all(is.finite(.mw_pente_relative(d0))) &&
             identical(.mw_pente_relative(d3), na4) &&
             identical(.mw_pente_relative(d4), na4)
         })
verifier("Famille alpha (#307, option (b')) : reserve2, ECHEC inchange (stat 0,00111, p_mc 0,005) ; champs T-5 a la lettre, \"0.17 %\" (#514)",
         {
           x <- lig300("Stabilite du facteur selon la ponderation (famille alpha)")
           al <- mw_famille_alpha(res300$ajustement)
           # Texte de #514 (specification finale d'actuary) ; la colonne de
           # l'ecart maximal est rendue par mw_famille_alpha().
           att <- paste0(
             "Un ECHEC ou une ALERTE signale des estimateurs alpha = 0, 1 et 2 de f_j divergents,",
             " donc une esperance non proportionnelle au cumul (M1), non un defaut de variance",
             " (ecart relatif maximal 0.17 %, seul alpha = 1 entre dans sigma_USP). A lire avec",
             " \"Absence de tendance des facteurs avec le cumul, a colonne donnee\", meme",
             " association du facteur au volume, mais commune aux colonnes.")
           ok <- list(
             verdict = identical(x$verdict, "ECHEC") && identical(x$type, "test"),
             stat = identical(x$stat, al$stat) && isTRUE(proche(x$stat, 0.00111, rel = 0, abs = 5e-6)),
             p_mc = isTRUE(proche(x$p_mc, 0.005, rel = 1e-12)),
             fonction = identical(x$fonction, "mw_famille_alpha"),
             H0 = identical(x$H0, "les estimateurs alpha = 0, 1 et 2 visent le meme f_j"),
             H1 = identical(x$H1, paste0("les trois estimateurs visent des valeurs differentes ",
                                         "(esperance de C(i,j+1) non proportionnelle a C(i,j), ",
                                         "ou facteur non commun aux annees et associe a C(i,j))")),
             reference = identical(x$reference,
               "Mack (1994), CAS Forum (printemps), 101-182, chap. 3, p. 111, et chap. 5, p. 122-124"),
             detail = identical(x$detail, att) ||
               identical(x$detail, paste(att, PHRASE_VERDICT_SENSIBLE_MC)),
             ascii = !grepl("[^ -~]", x$detail))
           k <- !vapply(ok, isTRUE, logical(1))
           if (!any(k)) TRUE else paste("ecart :", paste(names(ok)[k], collapse = ", "))
         })
# Exposant de variance (M2) : le facteur f_j et la constante sigma_j^2
# communs aux annees sont donnes comme interpretation de l'outil, non comme la
# lettre du texte (#409, regulatory). Depuis #514 (specification d'actuary,
# W8, deux phrases), le detail ne le repete plus : H0 et la reference de la
# ligne le portent (lus ici, sur le cas reserve2).
verifier("Exposant de variance (M2, #409) : H0 et reference donnent f_j et sigma_j^2 communs aux annees comme interpretation de l'outil (D(4)(c) et D(5)(d)(ii)) ; detail de #514",
         {
           x <- lig300("Adequation de l'exposant de variance, colonne par colonne")
           grepl("sigma_j^2 et f_j communs aux annees (interpretation de l'outil)", x$H0, fixed = TRUE) &&
             grepl(paste("lu avec D(4)(c) et D(5)(d)(ii) : sigma_j^2 et f_j communs",
                         "(interpretation de l'outil)"), x$reference, fixed = TRUE) &&
             startsWith(x$detail, paste("Un ECHEC ou une ALERTE signale un lien entre |r(i,j)| et",
                                        "C(i,j) dans au moins une colonne, au-dela de l'effet de levier")) &&
             !grepl("[^ -~]", x$detail)
         })
# H1 de l'exposant de variance (M2, #436, texte C de l'arbitrage du
# 05/11/2026, suite de #431) : la chaine cite l'identite
# somme_i sqrt(C(i,j)) r(i,j) = 0 pour ecarter un ecart regulier de
# l'esperance ; l'identite est controlee ici sur les residus de mw_residus()
# (memes colonnes que mw_tests()), dans chaque colonne retenue, rapportee a
# somme_i sqrt(C(i,j)) |r(i,j)| (1e-12) ; rejouee sur le triangle multiplie par
# 1e6 (#449 ; la forme absolue, non invariante d'echelle, est retiree).
verifier("Exposant de variance (M2, #436) : reserve2, somme_i sqrt(C(i,j)) r(i,j) = 0 dans chaque colonne retenue, identite citee par H1 ; H1 = texte C a la lettre",
         {
           a <- res300$ajustement
           rs <- mw_residus(a, .mw_colonnes_degenerees(a))
           s <- tapply(sqrt(rs$C) * rs$residu, rs$j, sum)
           e <- tapply(sqrt(rs$C) * abs(rs$residu), rs$j, sum)
           # Rejeu sur le meme triangle multiplie par 1e6 (#449) : seule la
           # forme relative est invariante d'echelle ; la forme absolue
           # (|somme| <= 1e-12) echoue des que le triangle est a l'echelle
           # des montants reels, d'ou son retrait.
           a6 <- mw_ajuster(a$tri * 1e6)
           rs6 <- mw_residus(a6, .mw_colonnes_degenerees(a6))
           s6 <- tapply(sqrt(rs6$C) * rs6$residu, rs6$j, sum)
           e6 <- tapply(sqrt(rs6$C) * abs(rs6$residu), rs6$j, sum)
           x <- lig300("Adequation de l'exposant de variance, colonne par colonne")
           h1 <- paste0(
             "lien monotone entre |r(i,j)| et C(i,j) dans au moins une colonne (correlation de rang), ",
             "au-dela de ce qu'en produit le modele ajuste (effet de levier compris) ; causes ",
             "possibles, que le test ne separe pas et dont la liste n'est pas fermee : exposant de ",
             "variance different de 1, contraire a la lettre de D(2)(h)(iv) ; constante de variance ",
             "propre a l'annee de survenance, independante de ses cumuls realises mais liee au niveau ",
             "de C(i,j) d'une annee a l'autre, compatible avec la lettre mais non avec ",
             "l'interpretation de l'outil (sigma_j^2 commun aux annees) ; ecart de l'esperance ",
             "concentre sur peu de cellules a une extremite des cumuls de la colonne (palier de ",
             "C(i,j), annee de survenance, cellule ou diagonale : lignes de M1, M3 et M4). Un ecart ",
             "regulier de l'esperance le long de la colonne (ordonnee a l'origine ou facteur ",
             "fonction reguliere de C(i,j), contraires a la lettre de D(2)(h)(iii) ; facteur propre ",
             "a l'annee, independant de ses cumuls realises mais lie a son niveau d'une annee a ",
             "l'autre, compatible avec la lettre mais non avec f_j commun aux annees) donne des ",
             "residus des deux signes de part et d'autre d'un cumul pivot ",
             "(identite sum_i sqrt(C(i,j)) r(i,j) = 0) : il n'est pas vise ici, lignes de M1")
           ok <- list(
             colonnes = length(s) == 6L && nrow(attr(rs, "colonnes_exclues")) == 0L,
             relatif = all(e > 0) && all(abs(s) / e <= 1e-12),
             relatif_1e6 = length(s6) == 6L && all(e6 > 0) && all(abs(s6) / e6 <= 1e-12),
             H1 = identical(x$H1, h1),
             ascii = !grepl("[^ -~]", x$H1))
           k <- !vapply(ok, isTRUE, logical(1))
           if (!any(k)) TRUE else paste("ecart :", paste(names(ok)[k], collapse = ", "))
         })
# Repli de T-5 (statistique NA) : branche inatteignable sur un triangle
# valide (mw_famille_alpha() retient la colonne j = 0 des que I >= 3, et
# mw_valider_triangle() refuse un triangle de trois annees) ; exercee par
# mw_tests() appele directement sur un triangle 3 x 3, hors run_engine().
# add() y pose son prefixe de ligne non applicable devant la premiere phrase.
verifier("Famille alpha (#307) : statistique NA (aucune colonne n_j >= 3, triangle 3 x 3 hors run_engine()) -> ligne non applicable, detail = prefixe d'add() + premiere phrase seule",
         {
           t <- matrix(NA_real_, 3, 3); t[, 1] <- c(100, 120, 90)
           t[1:2, 2] <- t[1:2, 1] * c(1.5, 1.6); t[1, 3] <- t[1, 2] * 1.1
           a <- mw_ajuster(t); al <- mw_famille_alpha(a)
           x <- Filter(function(l) identical(l$test, "Stabilite du facteur selon la ponderation (famille alpha)"),
                       mw_tests(a, mw_bootstrap(a, B = 19)))
           is.na(al$stat) && length(x) == 1L && identical(x[[1]]$type, "non applicable") &&
             identical(x[[1]]$detail, paste0(
               "statistique observee non finie : test non applicable. ",
               "Un ECHEC ou une ALERTE signale des estimateurs alpha = 0, 1 et 2 de f_j divergents,",
               " donc une esperance non proportionnelle au cumul (M1), non un defaut de variance",
               ". A lire avec \"Absence de tendance des facteurs avec le cumul, a colonne donnee\",",
               " meme association du facteur au volume, mais commune aux colonnes."))
         })

## --- QQ-plot des residus de Mack redresses par le levier (#311) -------------
# Specification Fm, par. 2.1, 2.3 et 7 (decisions Q-D1-Fm-4 et Q-D1-Fm-5 du
# mainteneur, 23/10/2026, option (c)) : qqnorm porte r~ = r / sqrt(1 - h)
# (mw_residus_redresses()), theorique les quantiles N(0,1) de leurs rangs,
# qqline = c(0, 1) en fin de plots_data ; borne r~^2 <= n_j - 1 ; vivier du
# bootstrap inchange au bit pres ; lignes M5 sur les residus bruts.
local({
  r311 <- run_mw(tri_ref); aj311 <- r311$ajustement; pd <- r311$plots_data
  res <- pd$residus; rt <- mw_residus_redresses(aj311, res)
  nj <- as.vector(table(res$j)[as.character(res$j)])
  verifier("#311 : qqnorm$empirique tries = sort(mw_residus_redresses()) ; theorique = quantiles N(0,1) (ppoints) aux rangs de r~",
           identical(sort(pd$qqnorm$empirique), sort(rt)) && nrow(pd$qqnorm) == 27L &&
             identical(names(pd$qqnorm), c("theorique", "empirique")) &&
             isTRUE(proche(sort(pd$qqnorm$theorique), stats::qnorm(stats::ppoints(27)), rel = 1e-14)) &&
             identical(order(pd$qqnorm$theorique), order(pd$qqnorm$empirique)))
  verifier("#311 : mw_residus_redresses() = r / sqrt(1 - C/S) recalcule depuis le triangle (1e-14), dans l'ordre de res",
           {
             S <- vapply(seq_len(nrow(res)), function(k)
               sum(tri_ref[seq_len(nrow(tri_ref) - res$j[k] - 1), res$j[k] + 1]), numeric(1))
             isTRUE(proche(rt, res$residu / sqrt(1 - res$C / S), rel = 1e-14))
           })
  verifier("#311 : |r~| = 1 pour n_j = 2 (1e-14) ; max |r~| / sqrt(n_j - 1) <= 1 + 1e-12 (reserve2, Taylor-Ashe, tri_deg, ta_deg)",
           any(nj == 2L) && isTRUE(proche(abs(rt[nj == 2L]), rep(1, sum(nj == 2L)), rel = 1e-14)) &&
             all(vapply(list(tri_ref, ta, tri_deg, ta_deg), function(t) {
               a <- mw_ajuster(t); rs <- mw_residus(a); n <- as.vector(table(rs$j)[as.character(rs$j)])
               x <- mw_residus_redresses(a, rs)
               all(is.finite(x)) && max(abs(x) / sqrt(n - 1)) <= 1 + 1e-12
             }, logical(1))))
  verifier("#311 : qqline = c(ordonnee = 0, pente = 1), derniere feuille de plots_data avant les deux champs de #305 ; feuilles anterieures inchangees et a leur place",
           identical(pd$qqline, c(ordonnee = 0, pente = 1)) &&
             identical(utils::tail(names(pd), 6),
                       c("sigma_boot", "residus_acc_groupes", "residus_cal_groupes", "qqline",
                         "sigma_usp_boot", "boot_reperes")) &&
             identical(names(pd)[1:14], c("facteurs", "reserve_par_annee", "residus", "residus_dev",
                                          "residus_acc", "residus_cal", "residus_C", "qqnorm", "regressions",
                                          "alpha", "origine", "influence", "contributions", "sigma_boot")))
  # Vivier du bootstrap : .mw_pool_residus() appelle mw_residus_redresses().
  # Forme anterieure a #311 (expression litterale) substituee le temps d'un
  # bootstrap : p_mc, sigma_boot et statistiques repliquees identiques.
  pool_avant311 <- function(aj, j_degeneres = NULL) {
    res <- mw_residus(aj, j_degeneres)
    if (!nrow(res)) return(numeric(0))
    pool <- res$residu / sqrt(.mw_un_moins_h(aj, res))
    pool - mean(pool)
  }
  verifier("#311 : .mw_pool_residus() identique au bit pres a la forme anterieure (reserve2, Taylor-Ashe, tri_deg, ta_deg, tri_c1)",
           all(vapply(list(tri_ref, ta, tri_deg, ta_deg, tri_c1), function(t) {
             a <- mw_ajuster(t); jd <- .mw_colonnes_degenerees(a)
             identical(.mw_pool_residus(a, jd), pool_avant311(a, jd))
           }, logical(1))))
  verifier("#311 : bootstrap (B = 99) identique au bit pres avec le vivier de la forme anterieure : p_mc, sigma_boot",
           {
             env <- environment(mw_bootstrap); f0 <- get(".mw_pool_residus", envir = env)
             b1 <- mw_bootstrap(aj311, B = 99)
             assign(".mw_pool_residus", pool_avant311, envir = env)
             b0 <- tryCatch(mw_bootstrap(aj311, B = 99),
                            finally = assign(".mw_pool_residus", f0, envir = env))
             identical(b1$p_mc, b0$p_mc) && identical(b1$sigma_boot, b0$sigma_boot) &&
               identical(get(".mw_pool_residus", envir = env), f0)
           })
  verifier("#311 : lignes M5 (Shapiro-Wilk, Lilliefors) calculees sur les residus bruts, non sur r~",
           {
             l <- function(nom) Filter(function(x) identical(x$test, nom), r311$tests)[[1]]
             r <- mw_residus(aj311)$residu
             identical(l("Shapiro-Wilk sur les residus de Mack")$stat, .shapiro_sur(r)$stat) &&
               identical(l("Lilliefors sur les residus de Mack")$stat, stat_lilliefors(r)) &&
               !identical(.shapiro_sur(r)$stat, .shapiro_sur(rt)$stat)
           })
})

## --- Intervalles de l'ordonnee a l'origine par colonne (issue #404) ----------
# Specification d'actuary-approfondi (decision Q-46-19 du 02/11/2026) :
# mw_plots_data()$origine porte, par colonne, niveau = 1 - alpha, quantile_t
# = qt(1 - alpha/2, n_j - 2), bas et haut = a -/+ quantile_t se_a,
# exclut_zero (dual de p < alpha) et plus_petite_p ; colonnes ajoutees apres
# celles de mw_test_ordonnee_origine(), sans en deplacer aucune.
local({
  COLS_404 <- c("j", "n", "a", "se_a", "t", "p", "b", "f_cl",
                "niveau", "quantile_t", "bas", "haut", "exclut_zero", "plus_petite_p")
  r10 <- run_mw(tri_ref)
  r05 <- run_engine(methode = "reserve2", triangle = tri_ref, segment = 1, annexe = "II",
                    B = 99, alpha = 0.05)
  for (r in list(r10, r05)) {
    al <- r$metadata$alpha; d <- r$plots_data$origine
    q <- stats::qt(1 - al / 2, d$n - 2)
    verifier(sprintf("#404 (reserve2, alpha = %s) : colonnes de origine dans l'ordre, niveau = 1 - alpha, quantile_t = qt(1 - alpha/2, n_j - 2)", al),
             identical(names(d), COLS_404) && nrow(d) == 5L &&
               identical(d$niveau, rep(1 - al, nrow(d))) && isTRUE(proche(d$quantile_t, q, rel = 1e-12)))
    verifier(sprintf("#404 (reserve2, alpha = %s) : bas et haut = a -/+ qt(1 - alpha/2, n_j - 2) se_a a 1e-12", al),
             isTRUE(proche(d$bas, d$a - q * d$se_a, rel = 1e-12)) &&
               isTRUE(proche(d$haut, d$a + q * d$se_a, rel = 1e-12)))
    verifier(sprintf("#404 (reserve2, alpha = %s) : exclut_zero identique a p < alpha (dualite test / intervalle)", al),
             is.logical(d$exclut_zero) && identical(d$exclut_zero, d$p < al))
    verifier(sprintf("#404 (reserve2, alpha = %s) : plus_petite_p vrai sur la seule colonne de plus petite p", al),
             is.logical(d$plus_petite_p) && sum(d$plus_petite_p) == 1L &&
               d$p[d$plus_petite_p] == min(d$p))
  }
  # #432 (point 1) : alpha obligatoire dans mw_plots_data() ; au point
  # d'entree, le niveau suit l'alpha de run_engine().
  verifier("#432 : run_engine(reserve2, alpha = 0,05) -> plots_data$origine$niveau = 0,95 sur chaque colonne (0,90 au defaut) ; mw_plots_data() sans alpha -> erreur",
           {
             aj <- mw_ajuster(tri_ref)
             identical(r05$metadata$alpha, 0.05) &&
               identical(r05$plots_data$origine$niveau, rep(0.95, nrow(r05$plots_data$origine))) &&
               identical(r10$plots_data$origine$niveau, rep(0.90, nrow(r10$plots_data$origine))) &&
               leve_erreur(mw_plots_data(aj, r10$residus, r10$bootstrap, r10$msep))
           })
  verifier("#404 : colonnes de mw_test_ordonnee_origine() inchangees dans origine (memes valeurs au bit pres)",
           identical(as.list(r10$plots_data$origine[, 1:8]),
                     as.list(mw_test_ordonnee_origine(mw_ajuster(tri_ref))$detail)))
  # Reserve2 : la colonne j = 1 (p = 0,030) est la seule dont l'intervalle a
  # 90 % ou a 95 % exclut 0 ; aucune a 99 % (appel direct plus bas).
  verifier("#404 (reserve2) : exclut_zero sur j = 1 seule a alpha = 0,10 et 0,05, aucune a alpha = 0,01 ; plus petite p en j = 1",
           identical(r10$plots_data$origine$j[r10$plots_data$origine$exclut_zero], 1L) &&
             identical(r05$plots_data$origine$j[r05$plots_data$origine$exclut_zero], 1L) &&
             !any(.mw_origine_intervalles(r10$plots_data$origine[, 1:8], 0.01)$exclut_zero) &&
             identical(r10$plots_data$origine$j[r10$plots_data$origine$plus_petite_p], 1L))
  # Appels directs de .mw_origine_intervalles() : dualite sur plusieurs
  # niveaux ; a = se_a = 0 (t = 0/0, injection) -> exclut_zero NA ; aucune
  # p finie -> plus_petite_p FALSE partout ; table vide rendue telle quelle.
  det <- mw_test_ordonnee_origine(mw_ajuster(tri_ref))$detail
  verifier("#404 : .mw_origine_intervalles(), exclut_zero identique a p < alpha pour alpha = 0,01, 0,05, 0,10, 0,20, 0,50",
           all(vapply(c(0.01, 0.05, 0.10, 0.20, 0.50), function(al)
             identical(.mw_origine_intervalles(det, al)$exclut_zero, det$p < al), logical(1))))
  verifier("#404 : .mw_origine_intervalles(), a = se_a = 0 (injection, t et p NaN) -> exclut_zero NA, colonne hors de plus_petite_p",
           {
             dz <- det; dz$a[2] <- 0; dz$se_a[2] <- 0; dz$t[2] <- NaN; dz$p[2] <- NaN
             o <- .mw_origine_intervalles(dz, 0.10)
             is.na(o$exclut_zero[2]) && !anyNA(o$exclut_zero[-2]) && !o$plus_petite_p[2] &&
               sum(o$plus_petite_p) == 1L
           })
  verifier("#404 : .mw_origine_intervalles(), aucune p finie -> plus_petite_p FALSE partout ; table vide rendue telle quelle",
           {
             dn <- det; dn$p[] <- NA_real_
             o <- .mw_origine_intervalles(dn, 0.10)
             identical(o$plus_petite_p, rep(FALSE, nrow(dn))) &&
               identical(.mw_origine_intervalles(data.frame(), 0.10), data.frame())
           })
})

## --- M1 : champ loi de l'ordonnee a l'origine et de la courbure (#447) -------
# Decision du mainteneur du 06/11/2026 : meme texte, a l'octet pres, sur les
# deux lignes ; la ligne de l'homogeneite de f_j garde le sien.
local({
  LOI_447 <- "chi2(2K) approx. (t_j de Student independants sous erreurs gaussiennes seulement) -> Monte-Carlo"
  L <- run_mw(tri_ref)$tests
  lig <- function(nom) L[[which(vapply(L, `[[`, "", "test") == nom)]]
  verifier("#447 (reserve2) : loi de l'ordonnee a l'origine et de la courbure = texte decide, homogeneite de f_j inchangee",
           identical(lig("Nullite de l'ordonnee a l'origine, colonne par colonne")$loi, LOI_447) &&
             identical(lig("Absence de courbure de la regression")$loi, LOI_447) &&
             identical(lig("Homogeneite de f_j entre annees de survenance")$loi,
                       "chi2(2K) approx. -> Monte-Carlo"))
})

fin_fichier()
