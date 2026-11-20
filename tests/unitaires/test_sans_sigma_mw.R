###############################################################################
#  tests/unitaires/test_sans_sigma_mw.R  --  REPLICATIONS SANS SIGMA SIMULE
#                                            DU BOOTSTRAP DE MERZ-WUTHRICH
#                                            (ISSUE #492)
#
#  Specification d'actuary, docs/revues/20261119-s5-bootstrap-mw/
#  actuary-1a-specification-492-avis-b1.md, par. A.2, A.3 et A.7 :
#    - bootstrap$n_sans_sigma (mw_bootstrap()) : nombre de replications dont
#      les statistiques sont calculees (sim[b, ] pose) et dont sigma* n'est
#      pas fini ; entier de longueur 1, jamais NA, entre 0 et B ; 0L sans
#      tirage ; place juste apres plafond_cumuls, stats_boot restant le
#      dernier element ; aucun alea ajoute ni retire ;
#    - note de textes_ic_bootstrap() (R/display_helpers.R), branche
#      reserve2 : phrase "k sur B = B" quand k > 0, note inchangee si k = 0
#      ou si le champ est absent.
#  Fixture : tests/donnees/triangle_mw_volatil.csv, triangle 8 x 8 d'entiers
#  du par. A.0 de la specification (dput repris tel quel). Valeurs mesurees
#  par actuary (R 4.3.3, Linux, graine par defaut) : 77 sur B = 199, 453 sur
#  B = 999 ; la CI les confirme.
#  Oracle independant (A.7, point 3) : boucle de mw_bootstrap() rejouee pas a
#  pas sous la meme graine, instrumentee (statistiques calculees, causes de
#  sigma* non fini), sans lire le compteur du moteur. Second triangle : TA8,
#  ligne 0 x 1e-17, B = 99, ou le plafond du retirage de #257 est atteint
#  (replications sans statistiques) : B - length(sigma_boot) y differe de
#  n_sans_sigma.
#  Le controle de la reference reserve2 (n_sans_sigma = 0L) echoue tant que
#  tests/reference/reserve2.rds n'est pas regenere par la CI (ADR 0011).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_sans_sigma_mw.R")

.racine492 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."

lire_tri492 <- function(fichier) {
  d <- utils::read.csv(file.path(.racine492, "tests", "donnees", fichier))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
}
vol492 <- lire_tri492("triangle_mw_volatil.csv")
# dput du par. A.0 de la specification : la fixture versionnee en est la copie.
vol492_dput <- structure(c(1022, 1190, 1017, 1017, 1126, 1015, 852, 960, 998, 1383, 1132, 1143,
  1230, 1121, 927, NA, 1069, 1445, 1128, 1261, 1139, 1053, NA, NA, 1120, 1447, 1119, 1321,
  1252, NA, NA, NA, 1266, 1491, 1094, 1291, NA, NA, NA, NA, 1336, 1486, 1228, NA, NA, NA, NA,
  NA, 1199, 1490, NA, NA, NA, NA, NA, NA, 1179, NA, NA, NA, NA, NA, NA, NA), dim = c(8L, 8L))
# TA8 : Taylor & Ashe (1983), lignes et colonnes 1..8 (meme triangle que
# tests/unitaires/test_retirage_mw.R), ligne 0 multipliee par 1e-17.
ta8_492 <- local({
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
  m <- ta[1:8, 1:8]; m[outer(0:7, 0:7, "+") > 7] <- NA_real_
  m[1L, ] <- m[1L, ] * 1e-17; m
})

# Oracle : la boucle de mw_bootstrap() rejouee sous la meme graine (memes
# appels, dans le meme ordre, donc memes tirages), instrumentee. Rend les
# comptes par etape et les sigma* finis, sans lire bootstrap$n_sans_sigma.
oracle492 <- function(aj, B, seed = 20260831) {
  combn <- new.env(parent = emptyenv())
  engine_sous_graine(seed, {
    figes <- .mw_ensembles_figes(aj)
    pool <- .mw_pool_residus(aj, figes$degeneres)
    e_obs <- .mw_contexte_mc(aj, figes, combn)
    obs <- .mc_evaluer(MW_CATALOGUE_MC, e_obs)
    n_max <- FACTEUR_B_MAX_MW * (as.numeric(B) + 1); n_tires <- 0
    n <- c(plafond = 0L, echec_ajustement = 0L, echec_stats = 0L, stats = 0L,
           reserve_non_positive = 0L, msep_erreur = 0L, msep_non_finie = 0L, sigma_fini = 0L,
           sans_sigma = 0L)
    sig <- numeric(0)
    for (b in seq_len(B)) {
      tir <- .mw_tirer_triangle_valide(aj, pool, n_max - n_tires)
      n_tires <- n_tires + tir$n
      if (is.null(tir$tri)) { n[["plafond"]] <- n[["plafond"]] + 1L; next }
      ab <- try(mw_ajuster(tir$tri), silent = TRUE)
      if (inherits(ab, "try-error")) { n[["echec_ajustement"]] <- n[["echec_ajustement"]] + 1L; next }
      sb <- try(.mw_stats(ab, figes, replique = TRUE, combn = combn), silent = TRUE)
      if (inherits(sb, "try-error")) { n[["echec_stats"]] <- n[["echec_stats"]] + 1L; next }
      n[["stats"]] <- n[["stats"]] + 1L
      mb <- try(mw_msep(ab), silent = TRUE)
      s <- NA_real_
      if (inherits(mb, "try-error")) n[["msep_erreur"]] <- n[["msep_erreur"]] + 1L
      else if (!is.finite(mb$msep)) n[["msep_non_finie"]] <- n[["msep_non_finie"]] + 1L
      else if (!(ab$reserve > 0)) n[["reserve_non_positive"]] <- n[["reserve_non_positive"]] + 1L
      else s <- sqrt(mb$msep) / ab$reserve
      if (is.finite(s)) { n[["sigma_fini"]] <- n[["sigma_fini"]] + 1L; sig <- c(sig, s) }
      else n[["sans_sigma"]] <- n[["sans_sigma"]] + 1L
    }
    list(n = n, sig = sig)
  })
}
type_ok <- function(k, B) is.integer(k) && length(k) == 1L && !is.na(k) && k >= 0L && k <= B

## --- Fixture volatile -------------------------------------------------------------
aj_vol <- mw_ajuster(vol492)
b199 <- suppressWarnings(mw_bootstrap(aj_vol, B = 199))
or199 <- oracle492(aj_vol, 199)
verifier("#492 fixture volatile : copie exacte du dput de la specification (par. A.0)",
         identical(vol492, vol492_dput))
verifier("#492 fixture volatile, B = 199, graine par defaut : n_sans_sigma = 77 = B_effectif (199 sur les 13 statistiques) - length(sigma_boot) (122)",
         identical(b199$n_sans_sigma, 77L) && length(b199$B_effectif) == 13L &&
           all(b199$B_effectif == 199) && length(b199$sigma_boot) == 122L &&
           identical(b199$cumuls_retires, FALSE) && identical(b199$plafond_cumuls, FALSE))
verifier("#492 fixture volatile, B = 199 : oracle par boucle instrumentee (meme compte, memes sigma*, seule cause la reserve simulee <= 0)",
         or199$n[["sans_sigma"]] == b199$n_sans_sigma && identical(or199$sig, b199$sigma_boot) &&
           or199$n[["stats"]] == 199L && or199$n[["reserve_non_positive"]] == 77L &&
           or199$n[["msep_erreur"]] == 0L && or199$n[["msep_non_finie"]] == 0L)
verifier("#492 n_sans_sigma : entier de longueur 1, non NA, entre 0 et B ; juste apres plafond_cumuls, stats_boot dernier",
         type_ok(b199$n_sans_sigma, 199L) &&
           identical(utils::tail(names(b199), 5L),
                     c("cumuls_retires", "plafond_cumuls", "n_sans_sigma", "p_min_mc", "stats_boot")))
verifier("#492 fixture volatile, B = 999 (controle) : n_sans_sigma = 453 = 999 - length(sigma_boot)",
         {
           b <- suppressWarnings(mw_bootstrap(aj_vol, B = 999))
           identical(b$n_sans_sigma, 453L) && all(b$B_effectif == 999) &&
             length(b$sigma_boot) == 546L && type_ok(b$n_sans_sigma, 999L)
         })
verifier("#492 B = 0 (appel direct) : n_sans_sigma = 0L sans tirage",
         identical(suppressWarnings(mw_bootstrap(aj_vol, B = 0))$n_sans_sigma, 0L))

## --- Plafond du retirage atteint : le compteur ne confond pas les causes ------------
aj_ta <- mw_ajuster(ta8_492)
bta <- suppressWarnings(mw_bootstrap(aj_ta, B = 99))
orta <- oracle492(aj_ta, 99)
verifier("#492 TA8 ligne 0 x 1e-17, B = 99 (plafond atteint) : n_sans_sigma = compte de l'oracle, invariant n_sans_sigma + length(sigma_boot) = replications a statistiques calculees, et B - length(sigma_boot) != n_sans_sigma",
         isTRUE(bta$plafond_cumuls) && orta$n[["plafond"]] > 0L && type_ok(bta$n_sans_sigma, 99L) &&
           bta$n_sans_sigma == orta$n[["sans_sigma"]] && identical(orta$sig, bta$sigma_boot) &&
           bta$n_sans_sigma + length(bta$sigma_boot) == orta$n[["stats"]] &&
           99L - length(bta$sigma_boot) != bta$n_sans_sigma)

## --- Voie MSEP en erreur ou negative (reprise de l'audit leger) ----------------------
# mw_msep() substituee dans environment(run_engine) (ADR 0016), restauree par
# on.exit : MSEP negative un appel sur 3, erreur un appel sur 5 (l'erreur
# l'emporte aux multiples de 15). B = 60, multiple de 15 : les deux cycles y
# sont complets. Le compte "R* <= 0" seul vient de l'oracle sans
# substitution (memes tirages : mw_msep() ne tire pas). Un compteur reduit a
# la reserve simulee (if (!(ab$reserve > 0))) ne compterait pas les
# replications a MSEP negative ou en erreur : il echouerait aux deux
# controles.
verifier("#492 mw_msep() substituee (MSEP negative 1 appel sur 3, erreur 1 appel sur 5), fixture, B = 60 : n_sans_sigma + length(sigma_boot) = B_effectif et n_sans_sigma > compte 'R* <= 0' seul",
         local({
           e <- environment(run_engine)
           orig <- get("mw_msep", envir = e, inherits = FALSE)
           on.exit(assign("mw_msep", orig, envir = e), add = TRUE)
           n_r <- oracle492(aj_vol, 60)$n[["reserve_non_positive"]]
           cpt <- new.env(parent = emptyenv()); cpt$n <- 0L
           assign("mw_msep", function(...) {
             cpt$n <- cpt$n + 1L
             if (cpt$n %% 5L == 0L) stop("MSEP en erreur (substitution de test)")
             m <- orig(...)
             if (cpt$n %% 3L == 0L) m$msep <- -abs(m$msep) - 1
             m
           }, envir = e)
           b <- suppressWarnings(mw_bootstrap(aj_vol, B = 60))
           be <- unique(b$B_effectif)
           cpt$n > 0L && length(be) == 1L && type_ok(b$n_sans_sigma, 60L) &&
             b$n_sans_sigma + length(b$sigma_boot) == be &&
             b$n_sans_sigma > n_r
         }))

## --- Reference reserve2 -------------------------------------------------------------
verifier("#492 reference reserve2 : n_sans_sigma = 0L = B - length(sigma_boot)",
         {
           b <- readRDS(file.path(.racine492, "tests", "reference", "reserve2.rds"))$bootstrap
           identical(b$n_sans_sigma, 0L) && b$B - length(b$sigma_boot) == 0
         })

## --- Affichage : note de textes_ic_bootstrap() ---------------------------------------
source(file.path(.racine492, "R", "display_helpers.R"), local = TRUE)
# Constat de couverture requalifie (#387, decision du mainteneur du
# 19/11/2026, D2 (b), par. 2.1) : place apres le compte k sur B quand k > 0.
NOTE_MW_492 <- paste("Niveaux nominaux. À T = 8, sous les modèles ajustés à deux triangles,",
                     "l'intervalle de percentile couvre nettement moins que son niveau nominal",
                     "(σ sous-estimé, borne haute dépassée) ; aucun intervalle « basic » mesuré",
                     "ne rétablit ce niveau. Constat de simulation : voir la documentation, fiche",
                     "de l'intervalle bootstrap.")
NOTE_MW_K <- paste("Intervalle conditionnel à une réserve simulée strictement positive.",
                   "Réplications sans σ simulé (réserve simulée négative ou nulle,",
                   "ou MSEP simulée non finie ou négative), écartées de l'intervalle mais",
                   "non des p-values de Monte-Carlo : %s sur B = %s.",
                   NOTE_MW_492)
res_vol <- suppressWarnings(run_engine(methode = "reserve2", segment = 1, annexe = "II",
                                       triangle = vol492, date_reference = "2025-12-31", B = 199))
verifier("#492 textes_ic_bootstrap(), fixture volatile, B = 199 : note 'Intervalle conditionnel ...' avec '77 sur B = 199' (texte du par. A.3)",
         {
           t <- textes_ic_bootstrap(res_vol)
           isTRUE(res_vol$ok) && identical(res_vol$bootstrap$n_sans_sigma, 77L) &&
             identical(t$note, sprintf(NOTE_MW_K, "77", "199")) &&
             grepl("77 sur B = 199", t$note, fixed = TRUE)
         })
verifier("#492 textes_ic_bootstrap(), reserve2 : k = 0 ou champ absent, note reduite au constat de couverture (sans compte) ; lignes inchangees",
         {
           r0 <- res_vol; r0$bootstrap$n_sans_sigma <- 0L
           ra <- res_vol; ra$bootstrap$n_sans_sigma <- NULL
           t <- textes_ic_bootstrap(res_vol); t0 <- textes_ic_bootstrap(r0); ta <- textes_ic_bootstrap(ra)
           identical(t0$note, NOTE_MW_492) && identical(ta$note, NOTE_MW_492) &&
             identical(t0$lignes, t$lignes) && identical(ta$lignes, t$lignes)
         })
verifier("#492 textes_ic_bootstrap() : entiers lus dans les champs, sans decimale ni separateur des milliers (k = 1234, B = 9999 synthetiques)",
         {
           r <- res_vol; r$bootstrap$n_sans_sigma <- 1234L; r$bootstrap$B <- 9999
           identical(textes_ic_bootstrap(r)$note, sprintf(NOTE_MW_K, "1234", "9999"))
         })

fin_fichier()
