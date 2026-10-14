###############################################################################
#  tests/unitaires/test_forme_close_m1.R  --  COURBURE ET PENTE INTRA-COLONNE
#                                             DE M1 EN FORME CLOSE (ISSUE #253)
#
#  Specification d'E2d (docs/specifications/e2d-merz-wuthrich-replications-
#  definitions.md, section 6, tests T253-1 a T253-7 ; decisions D1-5 a D1-7
#  du mainteneur, 13/10/2026) : t du terme quadratique de mw_test_courbure()
#  par .mw_courbure_colonne() (Cauchy-Binet, regle de Cramer) et pente
#  intra-colonne de .mw_lm_intra() (Frisch et Waugh, 1933), sans lm().
#  Valeurs attendues ecrites en dur : reference en arithmetique rationnelle
#  exacte (entrees : les flottants du moteur, convertis exactement ; seule la
#  racine finale est arrondie), calculee par actuary pour la specification
#  (T253-1, T253-2, T253-5 « bornes ») et, pour le triangle a deux echelles
#  extremes de T253-5, par la meme reference lors de l'implementation ; cas
#  ligne 0 x 1e-14 : reference Rmpfr du script ci-dessous (4 096 bits, memes
#  17 chiffres a 8 192 bits). Source et controle de toutes ces valeurs :
#  tests/unitaires/generer_valeurs_forme_close_m1.R (hors CI, Rmpfr), qui
#  les recalcule par une methode independante de la forme close (equations
#  normales, elimination de Gauss a 4 096 bits, controle a 8 192 bits) et
#  sort avec le code 1 si l'une s'ecarte de la tolerance de son test.
#  Convention de la pente intra-colonne : y = F tel que le moteur le stocke
#  dans mw_residus(), soit le quotient C(i,j+1) / C(i,j) arrondi en double
#  (pas le quotient exact des deux flottants) ; avec le quotient exact, les
#  references bougeraient de 1e-15 a 3e-14 en relatif, sous les tolerances
#  (1e-12 et 1e-10).
#  T253-7 (reserve2 sous TOLERANCE, verdicts identiques) est porte par
#  tests/test_reproductibilite.R.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_forme_close_m1.R")

.racine253 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."
tri253 <- local({
  d <- utils::read.csv(file.path(.racine253, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
# Ligne i (0-based) multipliee par k
ligne253 <- function(t, i, k) { t[i + 1, ] <- t[i + 1, ] * k; t }
# t de la courbure par colonne retenue, K, et t de la pente intra-colonne
stats253 <- function(t) {
  aj <- mw_ajuster(t)
  res <- mw_residus(aj, .mw_colonnes_degenerees(aj))
  cb <- mw_test_courbure(aj)
  li <- .mw_lm_intra(res)
  list(t = cb$detail$t, j = cb$detail$j, K = cb$K, stat = cb$stat, p = cb$p,
       pente = if (is.null(li)) NA_real_ else unname(li[["t value"]]))
}
# Triangle « bornes » : ligne 0 portee a 1e50 (max), ligne 3 a 1e-50 (min)
bornes253 <- local({
  t <- tri253
  t[1, ] <- t[1, ] * 1e50 / max(t[1, ], na.rm = TRUE)
  t[4, ] <- t[4, ] * 1e-50 / min(t[4, ], na.rm = TRUE)
  t
})
# Deux echelles extremes : ligne 0 a 1e48 (max), lignes 1 a 3 a 1e-48 (min)
extreme253 <- local({
  t <- tri253
  t[1, ] <- t[1, ] * 1e48 / max(t[1, ], na.rm = TRUE)
  for (i in 2:4) t[i, ] <- t[i, ] * 1e-48 / min(t[i, ], na.rm = TRUE)
  t
})
ok_liste <- function(r) {
  ko <- vapply(r, function(v) !isTRUE(v), logical(1))
  if (!any(ko)) TRUE else
    paste(names(r)[ko], vapply(r[ko], function(v) paste(as.character(v), collapse = " "), ""),
          sep = " : ", collapse = " ; ")
}

verifier("T253-1 : reserve2, t de la courbure (n = 7, 6, 5, 4) et de la pente intra-colonne = reference rationnelle a 1e-12 (#253)",
         {
           s <- stats253(tri253)
           ok_liste(list(
             K = identical(s$K, 4L),
             courbure = proche(s$t, c(0.93422764996969232, -1.9823633206000404,
                                      -9.1618120029068368, -3.462887950378827), rel = 1e-12),
             pente = proche(s$pente, 0.2600197442537881, rel = 1e-12)))
         })

verifier("T253-2 : reserve2, ligne 0 x 1e30, ligne 3 x 1e30, ligne 0 x 1e-30 : t = reference rationnelle a 1e-10 (#253)",
         {
           att <- list(
             l0p30 = list(ligne253(tri253, 0, 1e30),
                          c(-3.2321868753333782, -2.6230673521146479, -1.2246845553777297,
                            0.27555322316525688), -0.64792170590960629),
             l3p30 = list(ligne253(tri253, 3, 1e30),
                          c(-1.7637144365936694, -3.1751739033668485, -1.0848619801581147,
                            -1.9731120214984617), 0.58992812949620965),
             l0m30 = list(ligne253(tri253, 0, 1e-30),
                          c(3.1467379665547841, 2.1589835486730493, 0.79635768376122973,
                            -0.58330789698280028), -1.120997177810577))
           ok_liste(unlist(lapply(att, function(a) {
             s <- stats253(a[[1]])
             list(K = identical(s$K, 4L), courbure = proche(s$t, a[[2]], rel = 1e-10),
                  pente = proche(s$pente, a[[3]], rel = 1e-10))
           }), recursive = FALSE))
         })

# Avant #253, lm() ecartait le terme par son rang numerique : courbure NA
# des e = 13 (exclusion silencieuse partielle a e = 12, ligne 3), pente NA
# des e = 15 (specification, section 4).
verifier("T253-3 : lignes 0 et 3 x 10^e, e = 12..17, 20, 25, 30 : courbure et pente finies, K = 4 partout (#253)",
         {
           ko <- character(0)
           for (i in c(0, 3)) for (e in c(12:17, 20, 25, 30)) {
             s <- stats253(ligne253(tri253, i, 10^e))
             if (!(identical(s$K, 4L) && is.finite(s$stat) && is.finite(s$pente)))
               ko <- c(ko, sprintf("ligne %d e = %d (K = %s, X = %s, pente = %s)", i, e,
                                   format(s$K), format(s$stat), format(s$pente)))
           }
           if (!length(ko)) TRUE else paste(ko, collapse = " ; ")
         })

verifier("T253-4 : invariance a l'echelle globale, lambda = 10^-40, 10^-20, 10^20, 10^40 : t a 1e-12 (#253)",
         {
           s0 <- stats253(tri253)
           ok_liste(unlist(lapply(c(-40, -20, 20, 40), function(k) {
             s <- stats253(tri253 * 10^k)
             stats::setNames(list(proche(s$t, s0$t, rel = 1e-12), proche(s$pente, s0$pente, rel = 1e-12)),
                             paste0(c("courbure", "pente"), " 1e", k))
           }), recursive = FALSE))
         })

# Triangle a deux echelles extremes : la version de la specification
# (produits directs de poids et de differences) y rend NaN et Inf (mesure
# lors de l'implementation, hypothese [H] de la specification confirmee) ;
# le calcul a exposant separe reste fini et exact.
verifier("T253-5 : triangles aux bornes du domaine [1e-50 ; 1e50] de #185 : valides, t finis = reference rationnelle a 1e-10 (#253)",
         {
           sb <- stats253(bornes253); sx <- stats253(extreme253)
           ok_liste(list(
             valides = isTRUE(mw_valider_triangle(bornes253)$ok) &&
               isTRUE(mw_valider_triangle(extreme253)$ok),
             bornes_K = identical(sb$K, 4L),
             bornes_courbure = proche(sb$t, c(0.081519213694489751, -2.013620676168856,
                                              -4.5274309238335313, -6.6723491946328828), rel = 1e-10),
             bornes_pente = proche(sb$pente, -0.65007141204537222, rel = 1e-10),
             extreme_K = identical(sx$K, 4L),
             extreme_finis = all(is.finite(c(sx$t, sx$stat, sx$p, sx$pente))),
             extreme_courbure = proche(sx$t, c(-4.5539052541909681, -8.7152604957341513,
                                               -3.9732558970578664e+25, 0.46224878577219491),
                                       rel = 1e-10),
             extreme_pente = proche(sx$pente, -0.78452449405942448, rel = 1e-10)))
         })

verifier("T253-6 / T269-6 : colonne a deux valeurs distinctes de C(i,j) ecartee (K = 3) et enregistree dans non_identifiables ; pente a C constant par colonne : NULL, statistique NA (#253, D1-7, #269)",
         {
           t <- tri253
           t[, 1] <- rep(c(250, 320), 4)            # colonne j = 0 : deux valeurs
           s <- stats253(t)
           ni <- mw_test_courbure(mw_ajuster(t))$non_identifiables
           res <- data.frame(j = rep(0:1, each = 3), C = rep(c(10, 20), each = 3),
                             sigma_j = rep(c(1, 2), each = 3), F = c(1.5, 1.6, 1.4, 1.1, 1.2, 1.05))
           ok_liste(list(
             K = identical(s$K, 3L), j = identical(as.integer(s$j), 1:3),
             non_identifiables = nrow(ni) == 1L && identical(ni$j, 0L) &&
               identical(ni$n_facteurs, 7L),
             colonne_null = is.null(.mw_courbure_colonne(t[1:7, 1], t[1:7, 2])),
             pente_null = is.null(.mw_lm_intra(res)),
             pente_na = identical(.mw_pente_intra(res), NA_real_)))
         })

# Hors tableau de la specification (demande d'actuary) : seul cas mesure ou
# l'ancien moteur (lm()) rendait une pente intra-colonne finie et fausse,
# sans NA ni avertissement (t = -2,566 contre -1,1210, erreur relative 1,29).
verifier("reserve2, ligne 0 x 1e-14 : t de la courbure et de la pente intra-colonne = reference Rmpfr a 1e-10 (#253)",
         {
           s <- stats253(ligne253(tri253, 0, 1e-14))
           ok_liste(list(
             K = identical(s$K, 4L),
             courbure = proche(s$t, c(3.1467379665547831, 2.1589835486730452,
                                      0.79635768376122591, -0.58330789698280312), rel = 1e-10),
             pente = proche(s$pente, -1.1209971778104361, rel = 1e-10)))
         })

# Ajustement parfait (G = 0) : colonne j = 0 quadratique exacte en binaire,
# C(i,1) = 3 C(i,0) + C(i,0)^2 / 512, C(i,0) entiers de somme 2048 (facteurs,
# ecarts et determinants exacts) : t = +Inf, p = 0, relevee au plancher de
# .fisher_combine() ; X reste fini (mesure : 1429,6). Colonne affine exacte
# (C(i,0) puissances de 2 de somme 1024, C(i,1) = 3 C(i,0) + 64) : N = G = 0,
# t = NaN, d'ou une statistique de Fisher NA (regle de #90).
verifier("G = 0 : colonne quadratique exacte, t = +Inf, p = 0, X de Fisher fini ; N = G = 0 : t NaN, statistique NA (#253)",
         {
           t <- tri253
           C0 <- c(256, 264, 280, 288, 296, 312, 352)
           t[1:7, 1] <- C0; t[1:7, 2] <- 3 * C0 + C0^2 / 512
           s <- stats253(t)
           r <- .mw_courbure_colonne(t[1:7, 1], t[1:7, 2])
           Ca <- c(32, 32, 64, 128, 256, 512)
           ra <- .mw_courbure_colonne(Ca, 3 * Ca + 64)
           ok_liste(list(
             c2 = identical(unname(r[["c2"]]), 1 / 512),
             t_inf = identical(unname(r[["t"]]), Inf),
             p_nul = identical(unname(r[["p"]]), 0),
             K = identical(s$K, 4L),
             X_fini = is.finite(s$stat) && s$stat > -2 * log(.Machine$double.xmin),
             affine_t_nan = is.nan(ra[["t"]]),
             affine_stat_na = is.na(.fisher_combine(c(ra[["p"]], 0.5, 0.2))$stat)))
         })

# Hors tableau de la specification : la forme close est celle de lm() la ou
# lm() est precis (reserve2), y compris a valeurs de C(i,j) repetees (au
# moins trois distinctes), ou la difference divisee e[Q] de la specification
# n'est pas definie et ou le developpement de det_Q selon e l'est ; vecteur
# de .mw_lm_intra() de memes noms que la ligne "C" de summary.lm().
verifier("Forme close = summary(lm()) a 1e-10 sur reserve2 et a valeurs de C repetees ; noms de .mw_lm_intra() = ceux de co[\"C\", ] (#253)",
         {
           aj <- mw_ajuster(tri253)
           res <- mw_residus(aj, .mw_colonnes_degenerees(aj))
           res$w <- res$C / res$sigma_j^2
           co <- summary(stats::lm(F ~ factor(j) + C, weights = w, data = res))$coefficients["C", ]
           li <- .mw_lm_intra(res)
           C0 <- c(300, 300, 320, 340, 360, 360); C1 <- c(960, 985, 1010, 1080, 1110, 1150)
           ref_lm <- summary(stats::lm(C1 ~ C0 + I(C0^2), weights = 1 / C0))$coefficients[3, ]
           cc <- .mw_courbure_colonne(C0, C1)
           ok_liste(list(
             noms = identical(names(li), names(co)),
             pente = proche(li, co, rel = 1e-10),
             repetees = proche(cc[c("c2", "t", "p")], ref_lm[c(1, 3, 4)], rel = 1e-10)))
         })

## --- Colonnes non identifiables de la courbure (#269, #270) ---------------
# Specification d'E2e (docs/specifications/e2e-niveaux-et-documentation.md,
# sections 4 a 6, tests T269-1 a T269-6 et T270-1 a T270-8 ; decisions D1-5 a
# D1-8 du mainteneur, 13/10/2026). Triangles construits a partir de reserve2
# (section 4) : T1, C(0..2,1) = 1000 et C(3..5,1) = 1100 ; T2, C(0..2,2) =
# 1600 et C(3..4,2) = 1800 ; T3, C(.,0) = 320 et 350 en alternance (colonne
# figee) ; T4, C(0..5,1) = 1050 (constante) ; hors tableau : T5 (pour
# T269-3), T1 et colonne j = 2 degeneree, C(i,3) = 1,3 C(i,2) pour i = 0..4 ;
# T6 (constat 3b de l'audit de #269), T2 et colonne j = 1 degeneree,
# C(i,1) = C(i,2) / 1,3 pour i = 0..5 : colonne degeneree AVANT la colonne
# non identifiable j = 2.
# Allegement (constat 3c de l'audit de #269 : 8 appels de run_engine(),
# 55,6 s) : un seul run_engine() (T1, B = 199, chemin complet) ; ailleurs,
# libelle lu dans mw_tests() sur un mw_bootstrap() calcule une fois par
# triangle, B et graine (cache boot270()), celui de T1 a B = 999 etant
# partage par T269-1, T269-5, T270-1 et T270-8 ; K des replications par un
# rejeu de la boucle de mw_bootstrap() reduit a la courbure (rejeu270()).
t1_269 <- local({ t <- tri253; t[1:6, 2] <- rep(c(1000, 1100), each = 3); t })
t2_269 <- local({ t <- tri253; t[1:5, 3] <- c(1600, 1600, 1600, 1800, 1800); t })
t3_269 <- local({ t <- tri253; t[, 1] <- rep(c(320, 350), 4); t })
t4_270 <- local({ t <- tri253; t[1:6, 2] <- 1050; t })
t5_269 <- local({ t <- t1_269; t[1:5, 4] <- 1.3 * t[1:5, 3]; t })
t6_270 <- local({ t <- t2_269; t[1:6, 2] <- t[1:6, 3] / 1.3; t })
# mw_bootstrap() calcule une fois par (triangle, B, graine). T1 a B = 999 :
# appel sous un generateur de l'appelant different (L'Ecuyer-CMRG, graine 7),
# etat avant et apres conserve pour T270-8.
.cache270 <- new.env()
boot270 <- function(nom, t, B, seed = 20260831) {
  cle <- paste(nom, B, seed)
  if (is.null(.cache270[[cle]])) {
    aj <- mw_ajuster(t)
    .cache270[[cle]] <- if (nom == "t1" && B == 999 && seed == 20260831) {
      # etat de la session restaure en sortie (generateur et graine)
      rk0 <- RNGkind()
      s0 <- if (exists(".Random.seed", envir = globalenv(), inherits = FALSE))
        get(".Random.seed", envir = globalenv())
      on.exit({
        do.call(RNGkind, as.list(rk0))
        if (is.null(s0)) rm(".Random.seed", envir = globalenv())
        else assign(".Random.seed", s0, envir = globalenv())
      }, add = TRUE)
      RNGkind("L'Ecuyer-CMRG"); set.seed(7)
      avant <- list(kind = RNGkind(), seed = .Random.seed)
      b <- mw_bootstrap(aj, B = B, seed = seed)
      apres <- list(kind = RNGkind(), seed = .Random.seed)
      list(aj = aj, boot = b, avant = avant, apres = apres)
    } else list(aj = aj, boot = mw_bootstrap(aj, B = B, seed = seed))
  }
  .cache270[[cle]]
}
# Ligne de courbure de mw_tests() (estimation et libelle), comme la lit
# engine_table_tests() dans run_engine()
courbure_mw270 <- function(nom, t, B, seed = 20260831) {
  x <- boot270(nom, t, B, seed)
  l <- Filter(function(r) grepl("courbure", r$test), mw_tests(x$aj, x$boot))
  data.frame(estimation = vapply(l, function(r) r$estim, 0),
             commentaire = vapply(l, function(r) r$detail, ""))
}
# Rejeu de la boucle de mw_bootstrap() (graine, pool, retirage et plafond de
# #257, fonctions partagees), reduit a la courbure : statistique et K de chaque
# replication, ensembles jd et jni figes a l'observe comme dans mw_bootstrap()
rejeu270 <- function(t, B = 999, seed = 20260831) {
  aj <- mw_ajuster(t); jd <- .mw_colonnes_degenerees(aj)
  jni <- .mw_colonnes_courbure_non_identifiables(aj, jd)
  s <- rep(NA_real_, B); K <- rep(NA_integer_, B)
  engine_sous_graine(seed, {
    pool <- .mw_pool_residus(aj, jd)
    n_max <- FACTEUR_B_MAX_MW * (B + 1); n_tir <- 0
    for (b in seq_len(B)) {
      tir <- .mw_tirer_triangle_valide(aj, pool, n_max - n_tir)
      n_tir <- n_tir + tir$n
      if (is.null(tb <- tir$tri)) next
      ab <- try(mw_ajuster(tb), silent = TRUE)
      if (inherits(ab, "try-error")) next
      cb <- mw_test_courbure(ab, jd, jni)
      s[b] <- cb$stat; K[b] <- if (is.null(cb$K)) NA_integer_ else as.integer(cb$K)
    }
  })
  obs <- mw_test_courbure(aj)
  list(jni = jni, K_obs = obs$K, K = K, s = s,
       p_mc = engine_p_mc(s, obs$stat, "haut")$p_mc)
}
base269 <- "Une courbure invalide la linearite meme si la constante est nulle"
phrase269_t1 <- paste(
  "Colonne a moins de trois valeurs distinctes de C(i,j) : j = 1 (6 facteurs) ;",
  "terme quadratique non identifiable, colonne hors de la combinaison de Fisher ;",
  "K = 3 colonne(s) testee(s) sur 4 eligible(s). L'exclusion ne vaut pas preuve de linearite.")
# Commentaire sans la phrase de #244 finale, si elle est posee
sans244 <- function(x) {
  s <- paste0(" ", PHRASE_VERDICT_SENSIBLE_MC)
  if (endsWith(x, s)) substr(x, 1L, nchar(x) - nchar(s)) else x
}

verifier("T269-1 : T1, phrase de la colonne non identifiable j = 1 (6 facteurs), K = 3 sur 4 eligibles ; estimation = 3 (#269)",
         {
           l <- courbure_mw270("t1", t1_269, 999)
           cb <- mw_test_courbure(mw_ajuster(t1_269))
           ok_liste(list(
             ligne = nrow(l) == 1L, estim = identical(l$estimation, 3),
             phrase = identical(sans244(l$commentaire), paste0(base269, ". ", phrase269_t1)),
             element = identical(cb$non_identifiables,
                                 data.frame(j = 1L, n_facteurs = 6L)),
             exclues_vide = nrow(cb$exclues) == 0L,
             K_elig = identical(cb$K, 3L) && identical(cb$eligibles, 4L)))
         })
verifier("T269-2 : T3, colonne figee j = 0 (7 facteurs) ; T2, j = 2 (5 facteurs) (#269)",
         {
           l3 <- courbure_mw270("t3", t3_269, 99); l2 <- courbure_mw270("t2", t2_269, 99)
           ok_liste(list(
             t3 = grepl("valeurs distinctes de C(i,j) : j = 0 (7 facteurs) ;", l3$commentaire, fixed = TRUE),
             t3_K = grepl("K = 3 colonne(s) testee(s) sur 4 eligible(s)", l3$commentaire, fixed = TRUE),
             t2 = grepl("valeurs distinctes de C(i,j) : j = 2 (5 facteurs) ;", l2$commentaire, fixed = TRUE),
             estim = identical(c(l3$estimation, l2$estimation), c(3, 3))))
         })
verifier("T269-3 : colonne degeneree (j = 2) et colonne non identifiable (j = 1) : deux phrases, la degeneree d'abord, meme clause K = 2 sur 4 (#269)",
         {
           l <- courbure_mw270("t5", t5_269, 99)
           cm <- l$commentaire
           p_deg <- regexpr("Colonne degeneree", cm, fixed = TRUE)
           p_ni <- regexpr("Colonne a moins de trois valeurs distinctes", cm, fixed = TRUE)
           ok_liste(list(
             deux = p_deg > 0 && p_ni > 0, ordre = p_deg < p_ni,
             base = startsWith(cm, paste0(base269, ". Colonne degeneree")),
             deg = grepl("j = 2 (5 facteurs) ; terme quadratique nul", cm, fixed = TRUE),
             ni = grepl("j = 1 (6 facteurs) ; terme quadratique non identifiable", cm, fixed = TRUE),
             clause = lengths(regmatches(cm, gregexpr(
               "K = 2 colonne(s) testee(s) sur 4 eligible(s).", cm, fixed = TRUE))) == 2L,
             estim = identical(l$estimation, 2)))
         })
verifier("T269-4 : reserve2, aucune colonne non identifiable, phrase vide ; detail de la reference = libelle de base (#269)",
         {
           cb <- mw_test_courbure(mw_ajuster(tri253))
           ref <- readRDS(file.path(.racine253, "tests", "reference", "reserve2.rds"))
           k <- which(vapply(ref$tests, function(x) grepl("courbure", x$test), logical(1)))
           ok_liste(list(
             vide = identical(cb$non_identifiables, data.frame(j = integer(0), n_facteurs = integer(0))),
             phrase = identical(.mw_phrase_non_identifiable(cb), ""),
             ref = length(k) == 1L && identical(ref$tests[[k]]$detail, base269)))
         })
# Trois configurations : B = 999 et B = 199 a la graine 20260831 (seul B
# varie), B = 199 aux graines 20260831 et 1 (seule la graine varie) ; la
# configuration (199, 20260831) par run_engine() (chemin complet), les deux
# autres par mw_tests() sur le mw_bootstrap() du cache.
verifier("T269-5 : T1, B = 199 et 999, deux graines : phrase identique (aucun nombre issu du bootstrap), phrase de #244 en dernier si posee ; run_engine() et mw_tests() (#269)",
         {
           re <- engine_table_tests(run_engine(methode = "reserve2", triangle = t1_269, segment = 1,
                                               annexe = "II", B = 199, seed = 20260831))
           cms <- c(re$commentaire[grepl("courbure", re$test)],
                    courbure_mw270("t1", t1_269, 999)$commentaire,
                    courbure_mw270("t1", t1_269, 199, seed = 1)$commentaire)
           att <- paste0(base269, ". ", phrase269_t1)
           ok_liste(list(
             trois = length(cms) == 3L,
             identiques = all(vapply(cms, sans244, "") == att),
             fin = all(cms == att | cms == paste(att, PHRASE_VERDICT_SENSIBLE_MC))))
         })
# Plusieurs colonnes : forme plurielle (T1 et T2 combines)
verifier("Phrase plurielle : j = 1 (6 facteurs), j = 2 (5 facteurs), K = 2 sur 4 (#269)",
         {
           t <- t1_269; t[1:5, 3] <- t2_269[1:5, 3]
           ph <- .mw_phrase_non_identifiable(mw_test_courbure(mw_ajuster(t)))
           identical(ph, paste(
             "Colonnes a moins de trois valeurs distinctes de C(i,j) : j = 1 (6 facteurs), j = 2 (5 facteurs) ;",
             "terme quadratique non identifiable, colonnes hors de la combinaison de Fisher ;",
             "K = 2 colonne(s) testee(s) sur 4 eligible(s). L'exclusion ne vaut pas preuve de linearite."))
         })

# Rejeux (K et statistique de chaque replication), calcules une fois
rejeux270 <- list(t1 = rejeu270(t1_269), t2 = rejeu270(t2_269),
                  t3 = rejeu270(t3_269), t4 = rejeu270(t4_270))
k3_partout <- function(r) identical(r$K_obs, 3L) && sum(!is.na(r$K)) > 0L &&
  all(r$K[is.finite(r$s)] == 3L)
verifier("T270-1 : T1, mw_bootstrap() B = 999 : K = 3 dans toutes les replications finies, p_mc Courbure 0,031 (ALERTE -> ECHEC, D1-8) ; rejeu = mw_bootstrap() (#270)",
         {
           b <- boot270("t1", t1_269, 999)$boot; r <- rejeux270$t1
           ok_liste(list(
             jni = identical(r$jni, 1L), K3 = k3_partout(r),
             B_eff = identical(b$B_effectif[["Courbure"]], 999),
             p_mc = proche(b$p_mc[["Courbure"]], 0.031, rel = 1e-12),
             rejeu = identical(r$p_mc, b$p_mc[["Courbure"]]) &&
               identical(sum(is.finite(r$s)), as.integer(b$B_effectif[["Courbure"]])),
             obs = identical(b$stats_obs$Courbure, mw_test_courbure(mw_ajuster(t1_269))$stat)))
         })
verifier("T270-2 : T2 et T4, rejeu de la boucle de mw_bootstrap() (egalite rejeu = mw_bootstrap() assertee sur T1 par T270-1) : K = 3 dans toutes les replications finies ; p_mc 0,394 et 0,016 (#270)",
         {
           r2 <- rejeux270$t2; r4 <- rejeux270$t4
           ok_liste(list(
             jni = identical(r2$jni, 2L) && identical(r4$jni, 1L),
             K3 = k3_partout(r2) && k3_partout(r4),
             p_t2 = proche(r2$p_mc, 0.394, rel = 1e-12),
             p_t4 = proche(r4$p_mc, 0.016, rel = 1e-12)))
         })
verifier("T270-3 : T3 (colonne figee j = 0), rejeu de la boucle de mw_bootstrap() : K = 3 partout, p_mc 0,017 inchangee (#270)",
         {
           r <- rejeux270$t3
           ok_liste(list(jni = identical(r$jni, 0L), K3 = k3_partout(r),
                         p = proche(r$p_mc, 0.017, rel = 1e-12)))
         })
verifier("T270-4 : invariance de l'appel observe : mw_test_courbure(aj) = mw_test_courbure(aj, jd, jni) ; .mw_contexte_mc() et .mw_stats() de meme ; ensembles (reserve2 vide, T1 {1}, T2 {2}, T3 {0}, T4 {1}) (#270)",
         {
           tris <- list(reserve2 = tri253, t1 = t1_269, t2 = t2_269, t3 = t3_269, t4 = t4_270)
           att <- list(reserve2 = integer(0), t1 = 1L, t2 = 2L, t3 = 0L, t4 = 1L)
           ok <- vapply(names(tris), function(nm) {
             aj <- mw_ajuster(tris[[nm]]); jd <- .mw_colonnes_degenerees(aj)
             jni <- .mw_colonnes_courbure_non_identifiables(aj, jd)
             identical(jni, att[[nm]]) &&
               identical(jni, .mw_colonnes_courbure_non_identifiables(aj)) &&
               identical(mw_test_courbure(aj), mw_test_courbure(aj, jd, jni)) &&
               identical(.mw_contexte_mc(aj), .mw_contexte_mc(aj, jd, jni)) &&
               identical(.mw_contexte_mc(aj)$j_non_identifiables, jni) &&
               identical(.mw_stats(aj), .mw_stats(aj, jd, jni))
           }, logical(1))
           if (all(ok)) TRUE else paste("ecart :", paste(names(ok)[!ok], collapse = ", "))
         })
verifier("T270-5 : second volet : T1 avec j_non_identifiables = integer(0) (colonne j = 1 retenue, deux valeurs) : stat NA, K NA, aucun calcul partiel ; T4 (C constant) de meme (#270)",
         {
           a1 <- mw_ajuster(t1_269); a4 <- mw_ajuster(t4_270)
           c1 <- mw_test_courbure(a1, integer(0), integer(0))
           c4 <- mw_test_courbure(a4, NULL, integer(0))
           ok_liste(list(
             stat = identical(c1$stat, NA_real_) && identical(c4$stat, NA_real_),
             K = identical(c1$K, NA_integer_) && identical(c4$K, NA_integer_),
             detail_vide = identical(c1$detail, data.frame()),
             ni_vide = nrow(c1$non_identifiables) == 0L,
             # colonnes parcourues jusqu'a l'arret : j = 0 et j = 1
             eligibles = identical(c1$eligibles, 2L),
             fermeture = identical(MW_CATALOGUE_MC$Courbure$calc(
               .mw_contexte_mc(a1, integer(0), integer(0))), NA_real_)))
         })
# Constat 3b de l'audit de #269 : au retour NA d'une colonne degeneree, le
# moteur porte l'element non_identifiables COMPLET (ensemble fige, forme avant
# la boucle), et non les seules colonnes parcourues avant l'arret. T6 : colonne
# degeneree j = 1 retenue (j_degeneres = integer(0)), colonne non
# identifiable j = 2 apres elle (j = 6, un facteur, est aussi degeneree,
# comme dans reserve2 ; hors de la courbure, n_j < 4).
verifier("Constat 3b (#269, #270) : retour NA d'une colonne degeneree retenue, non_identifiables complet (j = 2, 5 facteurs, apres l'arret de j = 1) ; meme element qu'a l'appel observe",
         {
           a6 <- mw_ajuster(t6_270)
           na6 <- mw_test_courbure(a6, integer(0))
           ob6 <- mw_test_courbure(a6)
           ok_liste(list(
             degeneree = 1L %in% .mw_colonnes_degenerees(a6),
             na = identical(na6$stat, NA_real_) && identical(na6$K, NA_integer_),
             arret_j1 = identical(na6$eligibles, 2L),
             complet = identical(na6$non_identifiables, data.frame(j = 2L, n_facteurs = 5L)),
             observe = identical(ob6$non_identifiables, na6$non_identifiables) &&
               identical(ob6$K, 2L)))
         })
verifier("T270-8 : T1, mw_bootstrap() sous un generateur de l'appelant different (L'Ecuyer-CMRG) : RNGkind() et .Random.seed restaures (#270)",
         {
           x <- boot270("t1", t1_269, 999)
           ok_liste(list(kind = identical(x$avant$kind, x$apres$kind),
                         seed = identical(x$avant$seed, x$apres$seed),
                         lecuyer = identical(x$avant$kind[1], "L'Ecuyer-CMRG")))
         })

bilan_fichier()
