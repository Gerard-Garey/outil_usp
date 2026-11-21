###############################################################################
#  tests/unitaires/test_merz_wuthrich_trapeze.R  --  METHODE DU RISQUE DE
#  RESERVE No 2 SUR UN TRAPEZE I > J (issue #567)
#
#  Etape 3 de S6 : les fonctions de Merz-Wuthrich sont generalisees a I >= J
#  (convention (B), forme consolidee, specification d'actuary 2a,
#  docs/revues/20261120-s6-trapeze/actuary-2a-specification-567.md ; decisions
#  du mainteneur du 20/11/2026 : D1', Q-2a-1 (c), Q-2a-2, Q-2a-4, Q-2a-5).
#  Jusqu'a l'etape 6, C3, mw_valider_triangle() emettait MW-04 et
#  run_engine() refusait un trapeze : les blocs ecrits avant la levee
#  testent donc les trapezes par les fonctions internes (chemin P1 de la
#  specification, par. 9).
#    - C1 (par. 1.3) : MSEP et reserve egales, a 1e-12 relatif, aux valeurs
#      de CL_MSEPs (ChainLadder 0.2.21, implementation de M. Wuthrich, non
#      formule publiee) ; sigma2_(J-1) (regle et estimateur direct) egaux aux
#      valeurs de la transcription independante du script hors CI (entrees de
#      CL_MSEPs, non sorties) ; valeurs recalculees hors CI par
#      tests/unitaires/generer_valeurs_externes.R (section "Trapezes I > J")
#      et ecrites en dur ; et une transcription independante de la
#      convention (B) ecrite ici, sans le moteur ;
#    - geometrie : derniers cumuls bornes a la colonne J, reserve exactement
#      nulle et cumul ultime observe pour les annees i <= I-J ;
#    - critere (o) (par. 8, P6) : statistiques observees du 8 x 7 tire de
#      tests/donnees/triangle_mw.csv identiques au bit a celles du 8 x 8
#      (13 cles de MW_CATALOGUE_MC) ;
#    - option (c) : residus de la colonne J-1 reduits par l'estimateur direct ;
#      MSEP et simulation du bootstrap sur la valeur de la regle de minimum ;
#    - cas speciaux (s1) a (s8) du par. 9 ; chemins P5 (bootstrap) et P6
#      (mw_sensibilite_sigma2_dernier()) ;
#    - etape 6, C1 (consigne d'architect, par. 1.2 ; textes (t2) et (t3) de
#      T0) : colonnes sigma_residus et sigma_residus_direct de
#      plots_data$facteurs, feuille usage_sigma, mention M23 du detail M6
#      d'un trapeze (verifier_detail()), detail M6 d'un carre inchange,
#      mw_cellules_observees() ;
#    - etape 6, C3 (consigne d'architect, par. 1.4 ; texte (t1) de T0) :
#      levee de MW-04 (decision D2 (a') du mainteneur, ADR 0005 annote le
#      21/11/2026) ; run_engine() calcule un trapeze, avec l'avertissement de
#      geometrie (t1), une fois ; sigma_USP du 8 x 6 (cas reserve2_trapeze)
#      ecrit en dur ; I < J toujours refuse par MW-03 seul.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_merz_wuthrich_trapeze.R")

## --- Donnees -----------------------------------------------------------------
# Triangle 8 x 8 du cas reserve2 (tests/donnees/triangle_mw.csv, lu comme
# tests/outils_tests.R) et triangle de Taylor & Ashe (jeu GenIns de
# ChainLadder, celui de test_merz_wuthrich.R).
tz_carre <- local({
  df <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(df[, setdiff(names(df), "i")])
  storage.mode(m) <- "double"
  unname(m)
})
tz_ta <- matrix(c(357848, 352118, 290507, 310608, 443160, 396132, 440832, 359480, 376686, 344014,
  1124788, 1236139, 1292306, 1418858, 1136350, 1333217, 1288463, 1421128, 1363294, NA,
  1735330, 2170033, 2218525, 2195047, 2128333, 2180715, 2419861, 2864498, NA, NA,
  2218270, 3353322, 3235179, 3757447, 2897821, 2985752, 3483130, NA, NA, NA,
  2745596, 3799067, 3985995, 4029929, 3402672, 3691712, NA, NA, NA, NA,
  3319994, 4120063, 4132918, 4381982, 3873311, NA, NA, NA, NA, NA,
  3466336, 4647867, 4628910, 4588268, NA, NA, NA, NA, NA, NA,
  3606286, 4914039, 4909315, NA, NA, NA, NA, NA, NA, NA,
  3833515, 5339085, NA, NA, NA, NA, NA, NA, NA, NA,
  3901463, NA, NA, NA, NA, NA, NA, NA, NA, NA), 10, 10)
# Trapezes : dernieres colonnes retirees (illustratifs, D(2)(d) n'y est pas
# juge), plus un 6 x 5 (I - J = 1, T = 6) : lignes 2 a 7 et colonnes 0 a 4
# du 8 x 8, dont la partie observee est exactement i + j <= 5.
tz_jeux <- list(
  "8x7" = tz_carre[, 1:7], "8x6" = tz_carre[, 1:6], "8x5" = tz_carre[, 1:5],
  "10x9" = tz_ta[, 1:9], "10x7" = tz_ta[, 1:7], "10x5" = tz_ta[, 1:5],
  "6x5" = local({
    m <- tz_carre[3:8, 1:5]
    m[row(m) + col(m) - 2L > 5L] <- NA
    m
  }))
tz_aj <- lapply(tz_jeux, mw_ajuster)

## --- Donnees du cas reserve2_trapeze (decision Q-F1 (a), etape 6, C3) --------
# tests/donnees/triangle_mw_trapeze.csv : colonnes i et j0 a j5 de
# triangle_mw.csv, texte des cellules repris a l'identique ; lu comme
# tests/outils_tests.R lit le cas (.tri_trapeze), il donne le 8 x 6 tz_jeux.
local({
  src <- readLines(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  trp <- readLines(file.path(RACINE, "tests", "donnees", "triangle_mw_trapeze.csv"))
  sept <- vapply(strsplit(src, ",", fixed = TRUE), function(x) {
    x <- c(x, rep("", 9L - length(x)))           # champs vides de fin rendus par strsplit()
    paste(x[1:7], collapse = ",")
  }, character(1))
  df <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw_trapeze.csv"))
  m <- as.matrix(df[, setdiff(names(df), "i")]); storage.mode(m) <- "double"
  verifier("triangle_mw_trapeze.csv = sept premiers champs de chaque ligne de triangle_mw.csv (texte), 8 x 6 lu = tz_carre[, 1:6]",
           identical(trp, sept) && length(trp) == 9L &&
             identical(utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))[, 1:7], df) &&
             identical(unname(m), tz_jeux[["8x6"]]))
})

## --- C1 : valeurs de CL_MSEPs (ChainLadder 0.2.21), ecrites en dur ----------
# Colonnes : MSEP, reserve (sorties de CL_MSEPs), sigma2_(J-1) de la regle de
# minimum, sigma2_(J-1) estimateur direct (transcription independante du
# script hors CI, entrees de CL_MSEPs). Specification d'actuary 2a, par. 1.3 (tableau des
# valeurs mesurees par le prototype, egales a CL_MSEPs a 2,2e-16 pres) ;
# recalculees le 20/11/2026 par la section "Trapezes I > J" de
# generer_valeurs_externes.R (archive de md5 2a1fc0fcc593ec99529a40399274a088),
# memes 15 chiffres significatifs.
tz_c1 <- list(
  "8x7"  = c(19915.3947059509, 8490.81633282289, 0.0300913181729469, 0.189673662669698),
  "8x6"  = c(17334.2597283566, 7273.53169003966, 0.141927830391250, 0.0973247604368617),
  "8x5"  = c(15763.5410314709, 5885.87803675476, 0.684464137043688, 0.314778798976253),
  "10x9" = c(2764721031511.53, 17825075.6984623, 24.3674453780781, 1147.36596842866),
  "10x7" = c(2220973209004.33, 12983205.6743162, 12418.5249545645, 8185.77162000963),
  "10x5" = c(1405527865679.78, 8599219.11811852, 37736.8550479964, 15182.9026809764))
for (g in names(tz_c1)) local({
  a <- tz_aj[[g]]
  verifier(sprintf("C1 %s : MSEP et reserve = CL_MSEPs, sigma2_(J-1) regle et direct = transcription hors CI, a 1e-12", g),
           proche(c(mw_msep(a)$msep, a$reserve, a$sigma2[a$J], a$sigma2_Jm1_direct),
                  tz_c1[[g]], rel = 1e-12))
})

## --- Transcription independante de la convention (B), sans le moteur --------
# D(4)(c) et D(5)(d)(ii) en indices 0, sommes de la MSEP restreintes aux
# annees i, k = I-J+1..I, termes croises par le crochet de l'annee min(i, k)
# (forme consolidee) ; derniers cumuls C(i, min(I-i, J)). Ecrite a partir du
# texte, sans lire d'objet du moteur.
tz_transcrire <- function(tri) {
  I <- nrow(tri) - 1; J <- ncol(tri) - 1
  f <- s2 <- numeric(J)
  for (j in 0:(J - 1)) { r <- 0:(I - j - 1)
    f[j + 1] <- sum(tri[r + 1, j + 2]) / sum(tri[r + 1, j + 1]) }
  for (j in 0:(J - 2)) { r <- 0:(I - j - 1)
    s2[j + 1] <- sum(tri[r + 1, j + 1] * (tri[r + 1, j + 2] / tri[r + 1, j + 1] - f[j + 1])^2) /
      (I - j - 1) }
  s2[J] <- min(s2[J - 1], s2[J - 2], s2[J - 1]^2 / s2[J - 2])
  r <- 0:(I - J)
  s2d <- if (I > J) sum(tri[r + 1, J] * (tri[r + 1, J + 1] / tri[r + 1, J] - f[J])^2) / (I - J)
         else NA_real_
  Q <- s2 / f^2
  S  <- vapply(0:(J - 1), function(j) sum(tri[(0:(I - j - 1)) + 1, j + 1]), numeric(1))
  Sp <- vapply(0:(J - 1), function(j) sum(tri[(0:(I - j)) + 1, j + 1]), numeric(1))
  der <- vapply(0:I, function(i) tri[i + 1, min(I - i, J) + 1], numeric(1))
  ult <- vapply(0:I, function(i) {
    d <- min(I - i, J); v <- der[i + 1]
    if (d < J) for (j in d:(J - 1)) v <- v * f[j + 1]
    v }, numeric(1))
  ii <- (I - J + 1):I
  D <- vapply(ii, function(i) {
    k <- I - i; v <- Q[k + 1] / S[k + 1]
    if (k + 1 <= J - 1) for (j in (k + 1):(J - 1))
      v <- v + tri[I - j + 1, j + 1] / Sp[j + 1] * Q[j + 1] / S[j + 1]
    v }, numeric(1))
  t1 <- sum(vapply(ii, function(i) ult[i + 1]^2 * Q[I - i + 1] / der[i + 1], numeric(1)))
  t2 <- 0
  for (a in seq_along(ii)) for (b in seq_along(ii))
    t2 <- t2 + ult[ii[a] + 1] * ult[ii[b] + 1] * D[min(a, b)]
  list(f = f, s2 = s2, s2d = s2d, der = der, ult = ult, msep = t1 + t2,
       reserve = sum(ult - der))
}
for (g in names(tz_jeux)) local({
  a <- tz_aj[[g]]; t <- tz_transcrire(tz_jeux[[g]])
  verifier(sprintf("Transcription (B) %s : f, sigma2 (regle), estimateur direct a 1e-12", g),
           isTRUE(proche(a$f, t$f, rel = 1e-12)) && isTRUE(proche(a$sigma2, t$s2, rel = 1e-12)) &&
             isTRUE(proche(a$sigma2_Jm1_direct, t$s2d, rel = 1e-12)))
  verifier(sprintf("Transcription (B) %s : derniers cumuls, ultimes, reserve et MSEP a 1e-12", g),
           isTRUE(proche(a$dernier_observe, t$der, rel = 1e-12)) &&
             isTRUE(proche(a$ultime, t$ult, rel = 1e-12)) &&
             isTRUE(proche(a$reserve, t$reserve, rel = 1e-12)) &&
             isTRUE(proche(mw_msep(a)$msep, t$msep, rel = 1e-12)))
})
# Sur les carres, la meme transcription redonne mw_msep() : la restriction
# des sommes y est 1..I.
verifier("Transcription (B) sur les carres 8 x 8 et 10 x 10 = mw_msep() a 1e-12",
         isTRUE(proche(mw_msep(mw_ajuster(tz_carre))$msep, tz_transcrire(tz_carre)$msep, rel = 1e-12)) &&
           isTRUE(proche(mw_msep(mw_ajuster(tz_ta))$msep, tz_transcrire(tz_ta)$msep, rel = 1e-12)))

## --- Objet d'ajustement : champ de l'estimateur direct -----------------------
noms_carre <- c("I", "J", "tri", "f", "sigma2", "Q", "S", "Sp", "C_chapeau", "dernier_observe",
                "ultime", "reserve_par_annee", "reserve")
verifier("Carre : objet d'ajustement sans champ nouveau (noms et ordre historiques)",
         identical(names(mw_ajuster(tz_carre)), noms_carre) &&
           identical(names(mw_ajuster(tz_ta)), noms_carre))
verifier("Carre : variances des residus = aj$sigma2 (identical)",
         identical(.mw_sigma2_residus(mw_ajuster(tz_carre)), mw_ajuster(tz_carre)$sigma2))
verifier("Trapeze : champ sigma2_Jm1_direct ajoute en fin de liste, seul",
         all(vapply(tz_aj, function(a) identical(names(a), c(noms_carre, "sigma2_Jm1_direct")),
                    logical(1))))
verifier("Trapeze : variances des residus = aj$sigma2 sauf sigma2_(J-1) = estimateur direct",
         all(vapply(tz_aj, function(a) {
           s <- .mw_sigma2_residus(a)
           identical(s[-a$J], a$sigma2[-a$J]) && identical(s[a$J], a$sigma2_Jm1_direct)
         }, logical(1))))
# Troncature du 8 x 8 : f_j et sigma2_j (j <= J-2) sont les memes sommes ;
# l'estimateur direct de la colonne J-1 du trapeze est le sigma2_(J-1) de la
# premiere ligne de D(5)(d)(ii) du carre, meme expression : egalite au bit.
local({
  a8 <- mw_ajuster(tz_carre)
  for (g in c("8x7", "8x6", "8x5")) local({
    a <- tz_aj[[g]]; J <- a$J
    verifier(sprintf("Troncature %s du 8 x 8 : f, sigma2_j (j <= J-2) et estimateur direct identical", g),
             identical(a$f, a8$f[1:J]) && identical(a$sigma2[1:(J - 1)], a8$sigma2[1:(J - 1)]) &&
               identical(a$sigma2_Jm1_direct, a8$sigma2[J]))
  })
})

## --- Geometrie : annees i <= I-J et (s8) -------------------------------------
for (g in names(tz_jeux)) local({
  a <- tz_aj[[g]]; tri <- tz_jeux[[g]]; I <- a$I; J <- a$J; k <- seq_len(I - J)
  verifier(sprintf("%s : dernier cumul observe C(i, min(I-i, J))", g),
           identical(unname(a$dernier_observe),
                     vapply(0:I, function(i) tri[i + 1, min(I - i, J) + 1], numeric(1))))
  verifier(sprintf("%s (s8) : C^(i,J) = C(i,J), lignes non projetees et reserve identical(0) pour i <= I-J", g),
           identical(unname(a$ultime[k]), tri[k, J + 1]) &&
             identical(a$C_chapeau[k, , drop = FALSE], tri[k, , drop = FALSE]) &&
             identical(unname(a$reserve_par_annee[k]), rep(0, I - J)))
  verifier(sprintf("%s (s8) : contributions nulles pour i <= I-J, somme = terme de variance", g), {
    m <- mw_msep(a); ct <- mw_contributions(a, m)
    identical(ct$terme_variance[k], rep(0, I - J)) && identical(ct$reserve[k], rep(0, I - J)) &&
      isTRUE(proche(sum(ct$terme_variance), m$terme_variance, rel = 1e-12))
  })
})
verifier("(s8) mw_plots_data() sur 8 x 6 : contributions et reserves par annee nulles pour i <= I-J ; deux sigma de J-1 (#567, etape 6)", {
  a <- tz_aj[["8x6"]]; m <- mw_msep(a); rs <- mw_residus(a)
  pd <- mw_plots_data(a, rs, list(sigma_boot = numeric(0)), m, alpha = 0.10)
  identical(pd$contributions, mw_contributions(a, m)) &&
    identical(pd$reserve_par_annee$reserve[1:2], c(0, 0)) &&
    identical(pd$facteurs$sigma_regle_minimum, c(FALSE, FALSE, FALSE, FALSE, TRUE)) &&
    identical(pd$facteurs$sigma, sqrt(a$sigma2)) &&
    identical(pd$facteurs$sigma_residus_direct, c(FALSE, FALSE, FALSE, FALSE, TRUE)) &&
    identical(pd$facteurs$sigma_residus, sqrt(.mw_sigma2_residus(a)))
})

## --- Restitution des deux sigma de J-1 et mention M6 (etape 6, C1) ------------
# Forme (ii) de Q-A1 (consigne d'architect, par. 1.2, points 1 a 3 et 7 ;
# textes (t2) et (t3) de T0) : colonnes sigma_residus et sigma_residus_direct
# en fin de plots_data$facteurs, feuille usage_sigma en fin de liste, mention
# M23 en fin du detail M6 d'un trapeze, detail d'un carre inchange. Par les
# fonctions internes, bootstrap a B = 19 : le detail
# M6 ne lit pas le bootstrap.
tz_pd_tests <- function(a) {
  fg <- .mw_ensembles_figes(a); rs <- mw_residus(a)
  bt <- mw_bootstrap(a, B = 19, seed = 20260831, figes = fg)
  ts <- mw_tests(a, bt, 0.10, figes = fg)
  list(pd = mw_plots_data(a, rs, bt, mw_msep(a), alpha = 0.10), ts = ts,
       m6 = Filter(function(x) identical(x$test,
         "Extrapolation de sigma pour la derniere annee de developpement"), ts)[[1]])
}
NOMS_FACTEURS <- c("j", "f", "sigma", "sigma_regle_minimum", "sigma_residus", "sigma_residus_direct")
tz_5x5 <- tz_carre[4:8, 1:5]                      # partie observee exactement i + j <= 4
for (g in c("reserve2 8x8", "5x5", "GenIns 10x10")) local({
  a <- mw_ajuster(switch(g, "reserve2 8x8" = tz_carre, "5x5" = tz_5x5, "GenIns 10x10" = tz_ta))
  o <- tz_pd_tests(a); f <- o$pd$facteurs
  verifier(sprintf("Carre %s : sigma_residus identical a sigma, drapeau direct FALSE partout, colonnes en fin", g),
           identical(names(f), NOMS_FACTEURS) && identical(f$sigma_residus, f$sigma) &&
             is.logical(f$sigma_residus_direct) && !any(f$sigma_residus_direct) &&
             !anyNA(f$sigma_residus_direct))
  verifier(sprintf("Carre %s : usage_sigma = MW_USAGE_SIGMA, derniere feuille ; detail M6 sans mention M23", g),
           identical(o$pd$usage_sigma, MW_USAGE_SIGMA) &&
             identical(utils::tail(names(o$pd), 1), "usage_sigma") &&
             identical(names(MW_USAGE_SIGMA), c("sigma", "sigma_residus")) &&
             identical(o$m6$detail, .mw_detail_extrapolation(mw_extrapolation_sigma2(a))) &&
             !"M23" %in% mentions_presentes(o$m6$detail) && identical(o$m6$estim, a$sigma2[a$J]))
})
for (g in c("8x5", "8x6", "8x7")) local({
  a <- tz_aj[[g]]; J <- a$J
  o <- tz_pd_tests(a); f <- o$pd$facteurs
  verifier(sprintf("%s : sigma_residus[J] = sqrt(sigma2_Jm1_direct), sigma_residus[-J] = sigma[-J], sigma inchange, un seul drapeau TRUE en j = J-1", g),
           identical(names(f), NOMS_FACTEURS) &&
             identical(f$sigma_residus[J], sqrt(a$sigma2_Jm1_direct)) &&
             identical(f$sigma_residus[-J], f$sigma[-J]) && identical(f$sigma, sqrt(a$sigma2)) &&
             is.logical(f$sigma_residus_direct) && sum(f$sigma_residus_direct) == 1L &&
             identical(f$j[f$sigma_residus_direct], J - 1L) &&
             identical(o$pd$usage_sigma, MW_USAGE_SIGMA) &&
             identical(utils::tail(names(o$pd), 1), "usage_sigma"))
  mention <- sprintf(FORMAT_MENTION_MW_SIGMA_DIRECT, a$I - J + 1L,
                     format(a$sigma2_Jm1_direct, digits = 6, decimal.mark = "."), a$I - J)
  base <- .mw_detail_extrapolation(mw_extrapolation_sigma2(a))
  verifier(sprintf("%s : detail M6 = detail du carre puis mention M23 (.engine_joindre), estim = valeur de la regle", g),
           identical(o$m6$detail, paste(base, mention)) &&
             identical(o$m6$detail, .engine_joindre(base, mention)) &&
             grepl(sprintf("porte %d facteurs", a$I - J + 1L), mention, fixed = TRUE) &&
             grepl(sprintf("a %d degre(s) de liberte", a$I - J), mention, fixed = TRUE) &&
             identical(o$m6$estim, a$sigma2[J]) &&
             "M23" %in% mentions_presentes(o$m6$detail) &&
             identical(texte_propre(o$m6$detail), base))
  verifier_detail(o$ts, sprintf("mw_tests() sur le trapeze %s (mention M23)", g))
})

## --- mw_cellules_observees() : partie observee i + j <= I ---------------------
verifier("mw_cellules_observees() : matrice logique de la dimension du triangle, = !is.na() des jeux (carres et trapezes)",
         all(vapply(c(tz_jeux, list(tz_carre, tz_ta, tz_5x5)), function(t) {
           m <- mw_cellules_observees(t)
           is.logical(m) && is.matrix(m) && identical(dim(m), dim(t)) && identical(m, !is.na(t))
         }, logical(1))))
verifier("mw_cellules_observees() : 8 x 6, 8, 7, 6, 5, 4, 3 cellules observees dans les colonnes j = 0 a 5",
         identical(colSums(mw_cellules_observees(tz_jeux[["8x6"]])), c(8, 7, 6, 5, 4, 3)))
verifier("mw_cellules_observees() : forme seule lue (valeurs NA ou renseignees sous la diagonale sans effet)", {
  t <- tz_jeux[["8x6"]]; t2 <- t; t2[8, 6] <- 1; t2[is.na(t2)] <- 7; t2[1, 1] <- NA
  identical(mw_cellules_observees(t), mw_cellules_observees(t2))
})

## --- Critere (o) : 8 x 7 et 8 x 8 ont les memes statistiques observees -------
# Specification 2a, par. 8, P6, (o) : sous l'option (c), la colonne J-1 = 5
# du 8 x 7 est la colonne 5 du 8 x 8 (deux facteurs, sigma2_5 direct), et la
# colonne 6 du 8 x 8 (un facteur, degeneree) n'a ni residu ni etiquette. La
# comparaison a tests/reference/reserve2.rds (meme egalite, mesuree a l'etape
# 3) n'est pas faite ici : la reference est produite par la CI et
# l'egalite au bit entre plateformes n'est pas garantie.
local({
  a8 <- mw_ajuster(tz_carre); a7 <- tz_aj[["8x7"]]
  obs <- function(a) as.list(.mc_evaluer(MW_CATALOGUE_MC,
    .mw_contexte_mc(a, .mw_ensembles_figes(a), new.env(parent = emptyenv()))))
  o8 <- obs(a8); o7 <- obs(a7)
  verifier("(o) 8 x 7 : statistiques observees des 13 cles identical a celles du 8 x 8",
           length(o8) == 13L && identical(o7, o8))
  verifier("(o) 8 x 7 : residus, influence et identifiabilite intra identical a ceux du 8 x 8",
           identical(mw_residus(a7), mw_residus(a8)) &&
             identical(mw_influence(a7), mw_influence(a8)) &&
             identical(mw_identifiabilite_intra(a7), mw_identifiabilite_intra(a8)))
  verifier("Ensembles figes : colonne J-1 dans degeneres pour le carre, pas pour le 8 x 7",
           identical(.mw_ensembles_figes(a8)$degeneres, 6L) &&
             identical(.mw_ensembles_figes(a7)$degeneres, integer(0)))
})

## --- Option (c) : residus de la colonne J-1 ----------------------------------
local({
  a <- tz_aj[["8x6"]]; J <- a$J; n <- a$I - J + 1          # n = 3 facteurs
  rs <- mw_residus(a); r <- rs[rs$j == J - 1, ]
  verifier("(c) 8 x 6 : n_(J-1) residus, reduits par l'estimateur direct, somme des carres = n - 1",
           nrow(r) == n && isTRUE(proche(r$sigma_j, rep(sqrt(a$sigma2_Jm1_direct), n), rel = 0)) &&
             isTRUE(proche(sum(r$residu^2), n - 1, rel = 1e-12)))
  inf <- mw_influence(a)
  verifier("(c) 8 x 6 : residu de mw_influence() de la colonne J-1 = celui de mw_residus()",
           identical(inf$residu[inf$j == J - 1], r$residu))
  verifier("(c) 8 x 6 : e_a de la colonne J-1 lu sur l'estimateur direct", {
    det <- mw_identifiabilite_intra(a)$detail
    C0 <- a$tri[1:n, J]; C1 <- a$tri[1:n, J + 1]
    D <- 0; for (u in 1:(n - 1)) for (v in (u + 1):n)
      D <- D + ((C0[u] - C0[v]) / sqrt(C0[u]) / sqrt(C0[v]))^2
    isTRUE(proche(det$e_a[det$j == J - 1],
                  sqrt(a$sigma2_Jm1_direct) * sqrt(sum(C0) / D) / mean(C1), rel = 1e-12))
  })
  # Le champ de l'estimateur direct n'entre ni dans la MSEP ni dans la
  # simulation du bootstrap (Q-2a-2) : objets identiques sans lui.
  b <- a; b$sigma2_Jm1_direct <- NULL
  pool <- .mw_pool_residus(a)
  verifier("(c) MSEP et triangle simule identical sans le champ de l'estimateur direct",
           identical(mw_msep(a), mw_msep(b)) &&
             identical(engine_sous_graine(567L, .mw_simuler_triangle_etat(a, pool)),
                       engine_sous_graine(567L, .mw_simuler_triangle_etat(b, pool))))
  verifier("(c) vivier : n_(J-1) residus redresses de la colonne J-1, de valeur absolue <= sqrt(n - 1)",
           length(pool) == nrow(rs) &&
             all(abs(mw_residus_redresses(a, rs)[rs$j == J - 1]) <= sqrt(n - 1) + 1e-12))
})

## --- .mw_triangle_incomplet() : partie observee i + j <= I -----------------
local({
  ancien <- function(tb) anyNA(tb[upper.tri(tb, diag = TRUE)[, rev(seq_len(ncol(tb)))]])
  t8 <- tz_carre; t8b <- t8; t8b[3, 4] <- NA; t8c <- t8; t8c[8, 2] <- 5
  verifier("Triangle incomplet, carre : meme decision que l'ancien masque",
           identical(.mw_triangle_incomplet(t8), ancien(t8)) &&
             identical(.mw_triangle_incomplet(t8b), ancien(t8b)) &&
             !.mw_triangle_incomplet(t8) && .mw_triangle_incomplet(t8b) &&
             !.mw_triangle_incomplet(t8c))
  t7 <- tz_jeux[["8x7"]]; t7b <- t7; t7b[2, 7] <- NA        # (i, j) = (1, 6) : 1 + 6 <= 7
  verifier("Triangle incomplet, 8 x 7 : complet ; cellule (1, 6) manquante detectee (i + j <= I, j > I - J)",
           !.mw_triangle_incomplet(t7) && .mw_triangle_incomplet(t7b))
  a <- tz_aj[["8x7"]]
  s <- engine_sous_graine(20260831L, .mw_simuler_triangle_etat(a, .mw_pool_residus(a)))
  verifier("Triangle simule d'un 8 x 7 : complet selon les deux controles, partie non observee NA",
           isTRUE(s$complet) && !.mw_triangle_incomplet(s$tri) &&
             all(is.na(s$tri[row(s$tri) + col(s$tri) - 2L > 7L])) &&
             identical(dim(s$tri), dim(t7)))
})

## --- Cas speciaux (s1) a (s7) ------------------------------------------------
# (s1) Colonne J-1 degeneree : C(i,J) = 2 C(i,J-1) pour i <= I-J (facteurs
# exactement 2, f_(J-1) = 2 exactement) : estimateur direct nul, colonne
# J-1 dans l'ensemble des colonnes degenerees, aucun residu, colonne comptee
# comme exclue.
local({
  t <- tz_jeux[["8x6"]]; t[1:3, 6] <- 2 * t[1:3, 5]
  a <- mw_ajuster(t); J <- a$J; rs <- mw_residus(a); ex <- attr(rs, "colonnes_exclues")
  verifier("(s1) colonne J-1 degeneree : estimateur direct nul, colonne degeneree, sans residu",
           identical(a$sigma2_Jm1_direct, 0) && (J - 1L) %in% .mw_colonnes_degenerees(a) &&
             !any(rs$j == J - 1) && identical(ex$j, J - 1L) && identical(ex$n_facteurs, 3L) &&
             all(is.na(mw_influence(a)$residu[mw_influence(a)$j == J - 1])))
  verifier("(s1) regle de minimum inchangee (colonnes J-2, J-3 non degenerees) ; avertissement de colonne exclue",
           identical(a$sigma2[J], tz_aj[["8x6"]]$sigma2[J]) &&
             any(grepl("j = 4 (3 facteurs)", mw_valider_ajustement(a, mw_msep(a)$msep)$avertissements,
                       fixed = TRUE)))
})
# (s2) sigma2_(J-3) = 0 (colonne J-3 a facteurs exactement 2) : regle de
# minimum nulle, estimateur direct > 0, residus de la colonne J-1 gardes.
local({
  t <- tz_jeux[["8x6"]]; t[1:5, 4] <- 2 * t[1:5, 3]           # colonne j = 2 = J-3
  a <- mw_ajuster(t); J <- a$J; rs <- mw_residus(a)
  verifier("(s2) sigma2_(J-3) = 0 : regle de minimum nulle, estimateur direct > 0, residus de J-1 gardes",
           identical(a$sigma2[J - 2], 0) && identical(a$sigma2[J], 0) &&
             a$sigma2_Jm1_direct > 0 && sum(rs$j == J - 1) == 3L &&
             isTRUE(mw_extrapolation_sigma2(a)$degeneree_Jm3))
})
# (s3) R <= 0 (cumuls decroissants, facteurs < 1) : refus M4 inchange, reserve
# des annees i <= I-J nulle.
local({
  g <- c(1, 0.9, 0.8, 0.7, 0.6)
  t <- outer(tz_carre[, 1], g) * (1 + 0.01 * sin(outer(1:8, 1:5)))
  t[row(t) + col(t) - 2L > 7L] <- NA
  a <- mw_ajuster(t); v <- mw_valider_ajustement(a, mw_msep(a)$msep)
  verifier("(s3) 8 x 5 a reserve negative : refus M4, reserve des annees i <= I-J identical(0)",
           a$reserve < 0 && !v$ok && any(grepl("negative ou nulle", v$erreurs)) &&
             identical(unname(a$reserve_par_annee[1:3]), c(0, 0, 0)))
})
# (s4) Annee i <= I-J a cumul decroissant : reserve de la ligne nulle ; le
# triangle est recevable depuis la levee de MW-04 (C3) et recoit
# l'avertissement de cumul decroissant de la ligne (i = 1, lue jusqu'a
# j = min(I - i, J) = J), apres l'avertissement de geometrie (t1).
local({
  t <- tz_jeux[["8x5"]]; t[2, 5] <- t[2, 4] * 0.95
  a <- mw_ajuster(t); v <- mw_valider_triangle(t)
  verifier("(s4) ligne i <= I-J a cumul decroissant : reserve identical(0) ; recevable, avertissements (t1) puis cumul decroissant de l'annee 1",
           identical(unname(a$reserve_par_annee[2]), 0) && isTRUE(v$ok) && !length(v$erreurs) &&
             startsWith(v$avertissements[1], "Triangle a 8 annees d'accident et 5 annees de developpement") &&
             sum(v$avertissements == "Annee d'accident 1 : cumul decroissant (recouvrement ou boni).") == 1L)
})
# (s5) Colonnes 0..J-2 degenerees (facteurs exactement 2), colonne J-1 non :
# regle de minimum nulle, MSEP nulle, refus du triangle totalement degenere.
local({
  t <- matrix(NA_real_, 8, 5)
  t[, 1] <- tz_carre[, 1]
  for (j in 1:3) t[, j + 1] <- 2 * t[, j]
  t[1:4, 5] <- t[1:4, 4] * c(1.10, 1.12, 1.07, 1.15)
  t[row(t) + col(t) - 2L > 7L] <- NA
  a <- mw_ajuster(t); m <- mw_msep(a); v <- mw_valider_ajustement(a, m$msep)
  verifier("(s5) colonnes 0..J-2 degenerees, J-1 non : MSEP nulle, refus totalement degenere",
           identical(a$sigma2[a$J], 0) && identical(m$msep, 0) && a$sigma2_Jm1_direct > 0 &&
             !((a$J - 1L) %in% .mw_colonnes_degenerees(a)) && .mw_triangle_totalement_degenere(a) &&
             !v$ok && any(grepl("Triangle totalement degenere", v$erreurs)))
})
# (s6) Noms de ligne : sans effet sur le calcul ; MSEP sans nom (#319).
local({
  t <- tz_jeux[["8x7"]]; rownames(t) <- 2017:2024
  a <- mw_ajuster(t); a0 <- tz_aj[["8x7"]]
  verifier("(s6) noms de ligne sur un 8 x 7 : MSEP identical, reserves par annee nommees et nulles avant 2018",
           identical(mw_msep(a), mw_msep(a0)) &&
             identical(names(a$reserve_par_annee)[1], "2017") &&
             identical(unname(a$reserve_par_annee), unname(a0$reserve_par_annee)) &&
             identical(mw_residus(a)$residu, mw_residus(a0)$residu))
})
# (s7) Cellules renseignees sous la diagonale : signalees, sans effet sur le
# calcul (seule la partie i + j <= I est lue).
local({
  t <- tz_jeux[["8x7"]]; t[8, 2] <- 999; t[3, 7] <- 999
  a <- mw_ajuster(t); a0 <- tz_aj[["8x7"]]
  verifier("(s7) cellules sous la diagonale d'un 8 x 7 : avertissement, calcul inchange",
           length(.mw_avert_sous_diagonale(t)) == 1L &&
             grepl("(i = 2, j = 6)", .mw_avert_sous_diagonale(t), fixed = TRUE) &&
             identical(a[c("f", "sigma2", "sigma2_Jm1_direct", "C_chapeau", "reserve")],
                       a0[c("f", "sigma2", "sigma2_Jm1_direct", "C_chapeau", "reserve")]) &&
             identical(mw_msep(a), mw_msep(a0)) && identical(mw_residus(a), mw_residus(a0)))
})

## --- Credibilite, validation de l'ajustement, P6 -----------------------------
verifier("8 x 5 : duree de credibilite I + 1 = 8 (G(3)(c)), c(8) du bareme applique", {
  a <- tz_aj[["8x5"]]; p <- mw_parametre(a, mw_msep(a)$msep, 0.09, "long")
  identical(p$duree_credibilite, 8L) && identical(p$credibilite, usp_credibilite(8L, "long"))
})
verifier("Trapezes de triangle_mw : mw_valider_ajustement() sans refus ni avertissement",
         all(vapply(c("8x7", "8x6", "8x5"), function(g) {
           v <- mw_valider_ajustement(tz_aj[[g]], mw_msep(tz_aj[[g]])$msep)
           v$ok && !length(v$avertissements)
         }, logical(1))))
verifier("P6 mw_sensibilite_sigma2_dernier() sur 8 x 6 : applicable, racine(MSEP) de la regle identical", {
  a <- tz_aj[["8x6"]]; s <- mw_sensibilite_sigma2_dernier(a)
  isTRUE(s$applicable) && identical(s$valeur_regle, a$sigma2[a$J]) &&
    identical(s$racine_msep_regle, sqrt(mw_msep(a)$msep)) &&
    all(is.finite(s$racine_msep_arguments)) && is.finite(s$racine_msep_zero)
})

## --- P5 : bootstrap et tests d'un 8 x 7 par les fonctions internes -----------
local({
  a <- tz_aj[["8x7"]]; fg <- .mw_ensembles_figes(a)
  bt <- mw_bootstrap(a, B = 99, seed = 20260831, figes = fg)
  ts <- mw_tests(a, bt, 0.10, figes = fg)
  a8 <- mw_ajuster(tz_carre); fg8 <- .mw_ensembles_figes(a8)
  verifier("P5 8 x 7 : bootstrap complet (B effectif = B, sigma* finis), statistiques observees = (o)",
           all(unlist(bt$B_effectif) == 99) && length(bt$sigma_boot) == 99L &&
             all(bt$sigma_boot > 0) && identical(bt$n_sans_sigma, 0L) &&
             identical(bt$stats_obs, as.list(.mc_evaluer(MW_CATALOGUE_MC,
               .mw_contexte_mc(a8, fg8, new.env(parent = emptyenv()))))))
  verifier("P5 8 x 7 : memes lignes de mw_tests() que le carre, estimation M6 = valeur de la regle", {
    noms <- function(l) vapply(l, function(x) x$test, character(1))
    l8 <- noms(mw_tests(a8, mw_bootstrap(a8, B = 99, seed = 1, figes = fg8), 0.10, figes = fg8))
    m6 <- Filter(function(x) identical(x$test,
      "Extrapolation de sigma pour la derniere annee de developpement"), ts)[[1]]
    identical(noms(ts), l8) && identical(m6$estim, a$sigma2[a$J])
  })
})

## --- Levee de MW-04 (etape 6, C3) : run_engine() calcule un trapeze --------
# Consigne d'architect, par. 1.4 ; texte (t1) de T0 (texte complet teste dans
# test_controles_entree.R). Les cinq geometries de l'ancienne garde, B = 99,
# graine 20260831 : ok = TRUE, aucun motif, avertissement de geometrie (t1)
# present une fois, en tete des avertissements de la validation. sigma_USP
# ne lit pas le bootstrap (D(4) : c x racine(MSEP) / R + (1 - c) x sigma
# standard) : celui du 8 x 6, cas reserve2_trapeze de tests/outils_tests.R,
# est ecrit en dur (mesure du 21/11/2026, valeur du tableau
# docs/tableaux/20261121-issue567-levee-mw04.md, egale a B = 99 et a
# B = 999). Les tests du moteur sur trapeze de C4 ne sont pas ici.
SIGMA_USP_8X6 <- 0.0475797067089398
for (g in c("8x7", "8x6", "8x5", "10x5", "6x5")) local({
  t <- tz_jeux[[g]]
  r <- run_engine(methode = "reserve2", triangle = t, segment = 1, annexe = "II",
                  date_reference = DATE_REFERENCE_TESTS, B = 99, seed = 20260831)
  debut <- sprintf("Triangle a %d annees d'accident et %d annees de developpement : ", nrow(t), ncol(t))
  av <- r$validation$avertissements
  verifier(sprintf("Levee de MW-04 : run_engine() sur %s rend ok = TRUE, sans motif, avertissement (t1) une fois, en tete", g),
           identical(r$ok, TRUE) && !length(r$validation$erreurs) &&
             sum(startsWith(av, "Triangle a ")) == 1L && startsWith(av[1], debut) &&
             grepl(sprintf("annees d'accident i = 0 a %d (reserve nulle)", nrow(t) - ncol(t)), av[1],
                   fixed = TRUE))
  if (g == "8x6")
    verifier("Levee de MW-04 : sigma_USP du 8 x 6 (reserve2_trapeze) = valeur du tableau, a 1e-12",
             proche(r$parametre$sigma_usp, SIGMA_USP_8X6, rel = 1e-12))
})
verifier("Refus inchange : 5 x 6 (I < J) recoit MW-03 seul", {
  t <- matrix(NA_real_, 5, 6); t[, 1] <- c(100, 110, 120, 130, 140)
  for (j in 2:6) t[, j] <- t[, j - 1] * 1.1
  v <- mw_valider_triangle(t)
  !v$ok && length(v$erreurs) == 1L && startsWith(v$erreurs, "D(2)(e)")
})

fin_fichier()
