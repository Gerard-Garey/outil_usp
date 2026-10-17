###############################################################################
#  tests/unitaires/test_retirage_mw.R  --  RETIRAGE DES TRIANGLES SIMULES A
#                                          CUMUL NON STRICTEMENT POSITIF
#                                          (ISSUE #257, OPTION A1)
#
#  Specification docs/specifications/e2d-merz-wuthrich-replications-definitions.md,
#  par. 3 (tests T257-1 a T257-8) et decisions D1-1 a D1-4 du mainteneur du
#  13/10/2026 :
#    - mw_simuler_triangle() rend le triangle des le premier cumul simule non
#      strictement positif ou non fini (cellule a NA, colonnes suivantes non
#      tirees), sans racine carree d'un cumul negatif ;
#    - mw_bootstrap() retire le triangle entier par .mw_tirer_triangle_valide(),
#      au plus FACTEUR_B_MAX_MW (B + 1) triangles tires au total ; au plafond,
#      les replications restantes valent NA ;
#    - deux booleens bootstrap$cumuls_retires et bootstrap$plafond_cumuls ;
#      deux phrases fixes sans nombre, jointes par mw_tests() sur les lignes
#      Monte-Carlo avant la phrase de #204, celle de #244 restant la derniere ;
#    - au plafond, la phrase de #204 du cas A est celle du plafond (#279 :
#      replications manquantes, deux causes nommees) ; la phrase du plafond
#      est construite depuis FACTEUR_B_MAX_MW (controle par mutation).
#  Assertions par relations (B effectif = B, B effectif < B, egalite entre
#  statistiques), sans compte de tirages code en dur (comme 5541cc8). Valeurs
#  mesurees (R 4.3.3, Linux, graine 20260831), en commentaire seulement :
#  TA8 ligne 0 x 1e-15, B = 999 : 24 212 triangles tires, B effectif 999 ;
#  ligne 0 x 1e-17 : 25 000 (plafond), B effectif 839 ; ligne 4 x 0,03,
#  0,01, 0,003, B = 199 : 254, 329, 437 triangles tires, B effectif 199.
#  T257-1 (reserve2 identique, deux booleens FALSE poses par patch) est porte
#  par tests/test_reproductibilite.R ; T257-7 (sentinelle 5 x 5) par
#  test_merz_wuthrich.R, inchange.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_retirage_mw.R")

.racine257 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."

## --- Triangles ---------------------------------------------------------------------
r2_257 <- local({
  d <- utils::read.csv(file.path(.racine257, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
# TA8 : Taylor & Ashe (1983), lignes et colonnes 1..8, cellules i + j <= 7
# (meme triangle que tests/mesure_precision_residus_mw.R).
ta8_257 <- local({
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
  m <- ta[1:8, 1:8]; m[outer(0:7, 0:7, "+") > 7] <- NA_real_; m
})
t5_257 <- local({ t <- r2_257[1:5, 1:5]; t[row(t) + col(t) > 6] <- NA; t })
# ligne i (indice 0) multipliee par k
ligne_x <- function(t, i, k) { t[i + 1L, ] <- t[i + 1L, ] * k; t }

# Bootstrap et nombre d'avertissements R emis pendant son calcul.
boot_nw <- function(t, B) {
  nw <- 0L
  b <- withCallingHandlers(mw_bootstrap(mw_ajuster(t), B = B),
                           warning = function(w) { nw <<- nw + 1L; invokeRestart("muffleWarning") })
  list(b = b, nw = nw)
}
noms_mc <- names(MW_CATALOGUE_MC)
# lignes Monte-Carlo : p_mc finie (les 13 statistiques du catalogue ont ici une
# p Monte-Carlo, B effectif >= B_MIN_DEGENERESCENCE) ; les autres lignes n'en ont pas.
lignes_mc <- function(tm) Filter(function(l) is.finite(l$p_mc), tm)
autres <- function(tm) Filter(function(l) !is.finite(l$p_mc), tm)
a_beff <- function(l) grepl("B effectif =", l$detail, fixed = TRUE)
pos <- function(motif, d) regexpr(motif, d, fixed = TRUE)[[1]]

## --- T257-2 : borne de positivite (spec. par. 1) ---------------------------------------
# m = minimum du pool (m < 0) ; C*(i, j+1) >= g(C*(i, j)), g(C) = f_j C + sigma_j m sqrt(C),
# croissante des que sqrt(C) > -sigma_j m / (2 f_j). On itere L(i, j+1) = g(L(i, j))
# depuis la premiere colonne observee : si L reste dans la zone croissante et positive,
# aucun tirage ne produit de cumul <= 0, quels que soient la graine et B. Rend la marge
# minimale f_j sqrt(L) / (sigma_j |m|) (> 1/2 : zone croissante) et le minimum de L.
# Marges mesurees : reserve2 37,7 ; 5 x 5 84,3 ; TA8 2,91 (spec. par. 1).
borne_positivite <- function(t) {
  aj <- mw_ajuster(t); jd <- .mw_colonnes_degenerees(aj)
  m <- min(.mw_pool_residus(aj, jd)); L <- aj$tri[, 1]
  marge <- Inf; lmin <- Inf
  for (j in 0:(aj$J - 1)) {
    idx <- 0:(aj$I - j - 1) + 1L
    sg <- sqrt(aj$sigma2[j + 1]); if (!is.finite(sg)) sg <- 0
    f <- aj$f[j + 1]
    if (sg > 0) marge <- min(marge, f * sqrt(L[idx]) / (sg * abs(m)))
    L[idx] <- f * L[idx] + sg * m * sqrt(L[idx])
    lmin <- min(lmin, L[idx])
  }
  list(m = m, marge = marge, lmin = lmin)
}
verifier("T257-2 borne de positivite : reserve2, sentinelle 5 x 5 et TA8 ne peuvent tirer aucun cumul <= 0 (#257)",
         all(vapply(list(r2_257, t5_257, ta8_257), function(t) {
           p <- borne_positivite(t)
           p$m < 0 && p$marge > 0.5 && p$lmin > 0
         }, logical(1))) &&
           isTRUE(proche(borne_positivite(r2_257)$marge, 37.7, 1e-2)) &&
           isTRUE(proche(borne_positivite(ta8_257)$marge, 2.91, 1e-2)))

## --- T257-8 : mw_simuler_triangle() avec un pool force -----------------------------------
verifier("T257-8 mw_simuler_triangle(), pool -1e6 : NA des la premiere colonne tiree, colonnes suivantes non tirees, aucun avertissement (#257)",
         {
           aj <- mw_ajuster(ta8_257); nw <- 0L
           tb <- withCallingHandlers(engine_sous_graine(1L, mw_simuler_triangle(aj, -1e6)),
                                     warning = function(w) { nw <<- nw + 1L; invokeRestart("muffleWarning") })
           nw == 0L && identical(tb[, 1], aj$tri[, 1]) &&
             all(is.na(tb[seq_len(aj$I), 2])) && all(is.na(tb[, -(1:2)])) &&
             .mw_triangle_incomplet(tb) &&
             is.null(engine_sous_graine(1L, .mw_tirer_triangle_valide(aj, -1e6, 3))$tri)
         })
verifier("T257-8 bis : sans cumul invalide, mw_simuler_triangle() consomme un sample() par colonne (flux inchange)",
         {
           aj <- mw_ajuster(r2_257); pool <- .mw_pool_residus(aj)
           s <- engine_sous_graine(5L, { mw_simuler_triangle(aj, pool); stats::runif(1) })
           # reference : memes sample() que la boucle, dans le meme ordre
           r <- engine_sous_graine(5L, {
             for (j in 0:(aj$J - 1)) sample(pool, aj$I - j, replace = TRUE)
             stats::runif(1) })
           identical(s, r)
         })
verifier(".mw_tirer_triangle_valide() : reste = 0 rend NULL sans tirer ; n et rejets coherents",
         {
           aj <- mw_ajuster(r2_257); pool <- .mw_pool_residus(aj)
           z <- .mw_tirer_triangle_valide(aj, pool, 0)
           o <- engine_sous_graine(3L, .mw_tirer_triangle_valide(aj, pool, 5))
           is.null(z$tri) && z$n == 0 && z$rejets == 0 &&
             !is.null(o$tri) && o$n == 1 && o$rejets == 0 &&
             identical(o$tri, engine_sous_graine(3L, mw_simuler_triangle(aj, pool)))
         })

## --- T257-3 : TA8, ligne 0 x 1e-15, B = 999 ---------------------------------------------
bt3 <- boot_nw(ligne_x(ta8_257, 0L, 1e-15), 999)
tm3 <- mw_tests(mw_ajuster(ligne_x(ta8_257, 0L, 1e-15)), bt3$b)
verifier("T257-3 TA8 ligne 0 x 1e-15, B = 999 : aucun avertissement, B effectif = B sur les 13 statistiques, retirage sans plafond (#257)",
         bt3$nw == 0L && identical(sort(names(bt3$b$B_effectif)), sort(noms_mc)) &&
           all(bt3$b$B_effectif == bt3$b$B) &&
           isTRUE(bt3$b$cumuls_retires) && identical(bt3$b$plafond_cumuls, FALSE))
verifier("T257-3 phrase de retirage sur les 13 lignes Monte-Carlo, sans phrase de plafond ni 'B effectif =' (#257)",
         {
           lm_ <- lignes_mc(tm3)
           length(lm_) == 13L &&
             all(vapply(lm_, function(l) grepl(PHRASE_MW_CUMULS_RETIRES, l$detail, fixed = TRUE), logical(1))) &&
             !any(vapply(tm3, function(l) grepl(PHRASE_MW_PLAFOND_CUMULS, l$detail, fixed = TRUE), logical(1))) &&
             !any(vapply(tm3, a_beff, logical(1))) &&
             !any(vapply(autres(tm3), function(l)
               grepl(PHRASE_MW_CUMULS_RETIRES, l$detail, fixed = TRUE), logical(1)))
         })

## --- T257-4 : TA8, ligne 0 x 1e-17, B = 999 (plafond) -----------------------------------
bt4 <- boot_nw(ligne_x(ta8_257, 0L, 1e-17), 999)
tm4 <- mw_tests(mw_ajuster(ligne_x(ta8_257, 0L, 1e-17)), bt4$b)
verifier("T257-4 TA8 ligne 0 x 1e-17, B = 999 : plafond atteint, B effectif < B et egal entre statistiques definies (#257)",
         {
           be <- bt4$b$B_effectif[is.finite(unlist(bt4$b$stats_obs[noms_mc]))]
           bt4$nw == 0L && isTRUE(bt4$b$plafond_cumuls) && isTRUE(bt4$b$cumuls_retires) &&
             length(be) > 0L && all(be < bt4$b$B) && all(be > 0) && length(unique(be)) == 1L
         })
verifier("T257-4 phrases dans l'ordre : retirage, plafond, puis #204 ; #244 derniere s'il y a lieu (#257, D1-4)",
         {
           lm_ <- lignes_mc(tm4)
           length(lm_) == 13L && all(vapply(lm_, function(l) {
             d <- l$detail
             a <- pos(PHRASE_MW_CUMULS_RETIRES, d); b <- pos(PHRASE_MW_PLAFOND_CUMULS, d)
             c <- pos("B effectif =", d); v <- pos(PHRASE_VERDICT_SENSIBLE_MC, d)
             a > 0 && b > a && (c < 0 || c > b) && (v < 0 || v > max(b, c)) &&
               (v < 0 || endsWith(d, PHRASE_VERDICT_SENSIBLE_MC))
           }, logical(1))) && any(vapply(lm_, a_beff, logical(1)))
         })
# #279 : au plafond, phrase du cas A au plafond, nombres lus dans l'objet
# (B effectif 839 sur 999 mesure, non code en dur) ; plus aucune phrase
# imputant les replications manquantes a une statistique non finie.
gabarit_plafond_279 <- paste(
  "B effectif = %d sur B = %d (%d replication(s) manquante(s) : plafond de tirages",
  "atteint et, le cas echeant, statistique non finie) : p-value Monte-Carlo comptee",
  "sur les seules replications ou la statistique est finie ; les replications perdues",
  "au plafond le sont independamment de la valeur de la statistique, l'absence de",
  "biais de la selection par statistique non finie n'est pas demontree.")
verifier("T257-4 / #279 : phrase du plafond sur les 13 lignes Monte-Carlo, nombres de boot$B_effectif et boot$B, aucune 'ecartee(s), statistique non finie'",
         {
           # les lignes ne portent pas mc_nom : B effectif est le meme sur les
           # 13 statistiques (assertion T257-4 ci-dessus), lu dans l'objet
           lm_ <- lignes_mc(tm4)
           be <- unique(as.integer(bt4$b$B_effectif)); B <- as.integer(bt4$b$B)
           ok <- vapply(lm_, function(l)
             grepl(sprintf(gabarit_plafond_279, be, B, B - be), l$detail, fixed = TRUE), logical(1))
           length(be) == 1L && length(lm_) == 13L && all(ok) &&
             !any(vapply(tm4, function(l) grepl("ecartee(s), statistique non finie", l$detail, fixed = TRUE),
                         logical(1)))
         })

## --- T257-5 : TA8, ligne 4 x 0,03, 0,01, 0,003, B = 199 ----------------------------------
verifier("T257-5 TA8 ligne 4 x 0,03, 0,01 et 0,003, B = 199 : B effectif = B partout, aucun avertissement (#257)",
         all(vapply(c(0.03, 0.01, 0.003), function(k) {
           r <- boot_nw(ligne_x(ta8_257, 4L, k), 199)
           r$nw == 0L && all(r$b$B_effectif == 199) && isTRUE(r$b$cumuls_retires) &&
             identical(r$b$plafond_cumuls, FALSE)
         }, logical(1))))

## --- T257-6 : etat de l'appelant et reproductibilite -------------------------------------
verifier("T257-6 TA8 ligne 0 x 1e-15 : .Random.seed et RNGkind() de l'appelant inchanges ; deux appels identical() (#257)",
         {
           aj <- mw_ajuster(ligne_x(ta8_257, 0L, 1e-15))
           set.seed(42L); avant_s <- .Random.seed; avant_k <- RNGkind()
           b1 <- mw_bootstrap(aj, B = 99)
           ok_etat <- identical(.Random.seed, avant_s) && identical(RNGkind(), avant_k)
           b2 <- mw_bootstrap(aj, B = 99)
           ok_etat && identical(b1, b2) && isTRUE(b1$cumuls_retires)
         })

## --- Sans retirage : booleens FALSE, phrases absentes --------------------------------------
verifier("TA8 non modifie, B = 99 : cumuls_retires et plafond_cumuls FALSE, aucune phrase de retirage (#257)",
         {
           aj <- mw_ajuster(ta8_257); b <- mw_bootstrap(aj, B = 99); tm <- mw_tests(aj, b)
           identical(b$cumuls_retires, FALSE) && identical(b$plafond_cumuls, FALSE) &&
             identical(utils::tail(names(b), 3L), c("cumuls_retires", "plafond_cumuls", "p_min_mc")) &&
             !any(vapply(tm, function(l) grepl(PHRASE_MW_CUMULS_RETIRES, l$detail, fixed = TRUE) ||
                           grepl(PHRASE_MW_PLAFOND_CUMULS, l$detail, fixed = TRUE), logical(1)))
         })
verifier("T257-1 reference reserve2 : cumuls_retires et plafond_cumuls FALSE, avant p_min_mc (#257, patch chirurgical)",
         {
           f <- file.path(.racine257, "tests", "reference", "reserve2.rds")
           b <- readRDS(f)$bootstrap
           identical(b$cumuls_retires, FALSE) && identical(b$plafond_cumuls, FALSE) &&
             identical(utils::tail(names(b), 3L), c("cumuls_retires", "plafond_cumuls", "p_min_mc"))
         })

## --- Phrases : aucun nombre issu du bootstrap, refus explicite --------------------------
verifier("Phrases du retirage : texte fixe, seul nombre la formule 25 (B + 1) egale a FACTEUR_B_MAX_MW (#257, regle #76)",
         !grepl("[0-9]", PHRASE_MW_CUMULS_RETIRES) &&
           identical(regmatches(PHRASE_MW_PLAFOND_CUMULS, gregexpr("[0-9]+", PHRASE_MW_PLAFOND_CUMULS))[[1]],
                     c(as.character(FACTEUR_B_MAX_MW), "1")) &&
           identical(.mw_phrases_retirage(list(cumuls_retires = FALSE, plafond_cumuls = FALSE)), "") &&
           identical(.mw_phrases_retirage(list(cumuls_retires = TRUE, plafond_cumuls = TRUE)),
                     paste(PHRASE_MW_CUMULS_RETIRES, PHRASE_MW_PLAFOND_CUMULS)))
## --- #279 : phrase du plafond construite depuis FACTEUR_B_MAX_MW ----------------------
gabarit_phrase_plafond <- paste(
  "Plafond de %d (B + 1) triangles simules atteint : des replications manquent",
  "faute de triangle simule a cumuls strictement positifs.")
verifier("#279 PHRASE_MW_PLAFOND_CUMULS = sprintf(gabarit, FACTEUR_B_MAX_MW) (controle statique)",
         identical(PHRASE_MW_PLAFOND_CUMULS, sprintf(gabarit_phrase_plafond, FACTEUR_B_MAX_MW)))
# Mutation : la source du moteur, FACTEUR_B_MAX_MW porte a 30, evaluee dans un
# environnement neuf ; une phrase ecrite en dur garderait "25". A 25,5,
# l'evaluation doit echouer (sprintf("%d") refuse un double non entier).
src_279 <- readLines(file.path(.racine257, "R", "engine.R"), warn = FALSE, encoding = "UTF-8")
aff_279 <- grep("^FACTEUR_B_MAX_MW <- 25$", src_279)
muter_279 <- function(v) {
  s <- src_279; s[aff_279] <- paste("FACTEUR_B_MAX_MW <-", v)
  e <- new.env(parent = globalenv())
  eval(parse(text = s, encoding = "UTF-8"), envir = e)
  e
}
verifier("#279 mutation FACTEUR_B_MAX_MW 25 -> 30 (environnement neuf) : 'Plafond de 30 (B + 1)', aussi via .mw_phrases_retirage()",
         {
           e <- muter_279("30")
           ph <- e$PHRASE_MW_PLAFOND_CUMULS
           r <- e$.mw_phrases_retirage(list(cumuls_retires = TRUE, plafond_cumuls = TRUE))
           length(aff_279) == 1L && identical(e$FACTEUR_B_MAX_MW, 30) &&
             grepl("Plafond de 30 (B + 1)", ph, fixed = TRUE) && !grepl("25", ph, fixed = TRUE) &&
             grepl(ph, r, fixed = TRUE) && !grepl("25", r, fixed = TRUE) &&
             identical(PHRASE_MW_PLAFOND_CUMULS, sprintf(gabarit_phrase_plafond, 25))
         })
verifier("#279 mutation FACTEUR_B_MAX_MW 25 -> 25.5 : le chargement du moteur leve une erreur (facteur non entier refuse, non tronque)",
         length(aff_279) == 1L && leve_erreur(muter_279("25.5")))

verifier(".mw_phrases_retirage() : booleen absent, NA ou non logique refuse (jamais devine)",
         all(vapply(list(list(plafond_cumuls = FALSE), list(cumuls_retires = FALSE),
                         list(cumuls_retires = NA, plafond_cumuls = FALSE),
                         list(cumuls_retires = 0, plafond_cumuls = FALSE)),
                    function(b) inherits(try(.mw_phrases_retirage(b), silent = TRUE), "try-error"),
                    logical(1))))

fin_fichier()
