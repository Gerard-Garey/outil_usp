###############################################################################
#  tests/unitaires/test_ex_aequo.R  --  UNE SEULE DEFINITION DE L'EX AEQUO
#                                       (ISSUE #112)
#
#  Note d'actuary du 28/09/2026 sur #112 (sections 2, 4, 5 et 7), decisions
#  du mainteneur du meme jour (Q1 a Q3 selon l'avis) :
#    - engine_aplatir_ex_aequo() / engine_ex_aequo(), tolerance TOL_EX_AEQUO
#      = 1e-12 avec plancher max(1, |a|, |b|), chainage des valeurs triees ;
#    - aplatissement interne a Cox-Stuart, Spearman x2, Mann-Kendall, suites
#      (Runs, Runsr, suites de Mack) et Smirnov, a l'observe et dans les
#      catalogues Monte-Carlo ;
#    - Smirnov avec ex aequo : ni p exacte ni p_min, motif dans effectifs,
#      p Monte-Carlo retenue (option (i)) ;
#    - .usp_nb_volumes_distincts() (#110) branchee sur la meme definition.
#  References : definition de la note (section 2), valeurs construites.
#  Le cas de l'issue (206,91/312,60 contre 68,97/104,20) est egal au bit
#  pres et n'est pas utilise ; la paire 472,89/611,68 contre
#  3 310,23/4 281,76 (egale en decimal : 3 310,23 = 7 x 472,89 et
#  4 281,76 = 7 x 611,68) differe en flottant, ce que garde un stopifnot().
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_ex_aequo.R")

## --- 1. Definition : engine_aplatir_ex_aequo() --------------------------------
verifier("TOL_EX_AEQUO = 1e-12 (decision du mainteneur, 28/09/2026)",
         identical(TOL_EX_AEQUO, 1e-12))
verifier("Aplatissement : c(1, 1 + 1e-13, 2) -> deux premieres valeurs egales a 1",
         identical(engine_aplatir_ex_aequo(c(1, 1 + 1e-13, 2)), c(1, 1, 2)))
verifier("Aplatissement : c(1, 1 + 1e-6, 2) inchange",
         identical(engine_aplatir_ex_aequo(c(1, 1 + 1e-6, 2)), c(1, 1 + 1e-6, 2)))
verifier("Echelle relative : c(1e6, 1e6 + 1e-7) ex aequo, c(1e6, 1e6 + 1e-5) distincts",
         engine_ex_aequo(c(1e6, 1e6 + 1e-7)) && !engine_ex_aequo(c(1e6, 1e6 + 1e-5)))
verifier("Plancher absolu : c(0, 5e-13) ex aequo, c(0, 5e-12) distincts",
         engine_ex_aequo(c(0, 5e-13)) && !engine_ex_aequo(c(0, 5e-12)) &&
         identical(engine_aplatir_ex_aequo(c(5e-13, 0)), c(0, 0)))
verifier("Chainage : c(0, 6e-13, 1.2e-12) forme un seul groupe (plus petite valeur)",
         {
           v <- c(0, 6e-13, 1.2e-12)
           # l'ecart extreme 1,2e-12 depasse la tolerance : seul le chainage
           # des ecarts adjacents (6e-13) reunit les trois valeurs
           !(abs(v[3] - v[1]) <= TOL_EX_AEQUO) &&
             identical(engine_aplatir_ex_aequo(v), c(0, 0, 0)) &&
             identical(engine_aplatir_ex_aequo(rev(v)), c(0, 0, 0))
         })
verifier("Ordre d'origine conserve, valeurs negatives",
         identical(engine_aplatir_ex_aequo(c(3, -2, -2 - 1e-13, 5, -2 + 1e-13)),
                   c(3, -2 - 1e-13, -2 - 1e-13, 5, -2 - 1e-13)))
verifier("Sans ex aequo, l'aplatissement est l'identite",
         {
           v <- c(0.3, -1.2, 5, 2.5e-3, 1e4)
           identical(engine_aplatir_ex_aequo(v), v) && !engine_ex_aequo(v)
         })
verifier("Longueur 0 et 1 : vecteur rendu tel quel, aucun ex aequo",
         identical(engine_aplatir_ex_aequo(2.5), 2.5) && !engine_ex_aequo(2.5) &&
         identical(engine_aplatir_ex_aequo(numeric(0)), numeric(0)))
verifier("Valeur non finie : erreur (NA, NaN, Inf)",
         leve_erreur(engine_aplatir_ex_aequo(c(1, NA))) &&
         leve_erreur(engine_aplatir_ex_aequo(c(1, NaN))) &&
         leve_erreur(engine_ex_aequo(c(1, Inf))))

## --- 2. Ratios egaux en decimal, distincts en flottant ------------------------
ra <- 472.89 / 611.68
rb <- 3310.23 / 4281.76
stopifnot(ra != rb)          # garde : le cas n'a d'objet que si les flottants different
verifier("472,89/611,68 et 3 310,23/4 281,76 : distincts en flottant, ex aequo a TOL_EX_AEQUO",
         ra != rb && engine_ex_aequo(c(ra, rb)) && !anyDuplicated(c(ra, rb)))
verifier("Cas synthetique a et a (1 + 2 eps) : ex aequo (independant de la plateforme)",
         {
           a <- 0.7731
           b <- a * (1 + 2 * .Machine$double.eps)
           a != b && engine_ex_aequo(c(a, b))
         })

## --- 3. Serie T = 8 contenant la paire en positions 1 et 5 --------------------
# Ratios tries : 0,62 < 0,65 < 0,70 < ra ~ rb < 0,85 < 0,90 < 0,95 : la paire
# occupe les rangs 4 et 5 (mediane) ; positions 1 et 5 : premiere paire de
# Cox-Stuart. run_engine() y ajuste delta = 1 (pi_t constant) : les p exactes
# seraient attribuees sans ex aequo.
x_ea <- c(611.68, 700, 820, 950, 4281.76, 1200, 1500, 1800)
y_ea <- c(472.89, 0.70 * 700, 0.85 * 820, 0.65 * 950, 3310.23,
          0.90 * 1200, 0.62 * 1500, 0.95 * 1800)
r_ea <- y_ea / x_ea
stopifnot(r_ea[1] != r_ea[5])
verifier("test_cox_stuart() : m = 3 differences non nulles sur n_p = 4 paires",
         {
           cx <- test_cox_stuart(r_ea)
           identical(cx$m, 3L) && identical(cx$n_p, 4L)
         })
verifier("mk_p_exacte() : NA (ex aequo a la tolerance)", is.na(mk_p_exacte(r_ea)))
verifier("test_mann_kendall() : correction de variance des ex aequo appliquee",
         {
           ra_ <- engine_aplatir_ex_aequo(r_ea)
           identical(test_mann_kendall(r_ea), test_mann_kendall(ra_)) &&
             sum(duplicated(ra_)) == 1L
         })
verifier(".runs_effectifs() : la paire, a la mediane, est ecartee (n1 + n2 = 6)",
         identical(unname(.runs_effectifs(r_ea)), c(3L, 3L)))

res_ea <- run_engine(xt = x_ea, yt = y_ea, methode = "premium", segment = 1, annexe = "II",
                     nature_donnees = "brutes", B = B_MIN_USAGE, seed = 20260831)
lig_ea <- function(nom, base = NULL) {
  l <- Filter(function(l) identical(l$test, nom) && (is.null(base) || identical(l$base, base)),
              res_ea$tests)
  if (length(l) != 1L) stop("ligne introuvable ou multiple : ", nom)
  l[[1]]
}
verifier("run_engine() sur la serie : delta = 1 (pi_t constant, p exactes attribuables)",
         isTRUE(res_ea$ok) && identical(res_ea$ajustement$delta, 1))
verifier("Spearman x2 et Mann-Kendall : p exacte et p_min NA, motif ex aequo, Monte-Carlo retenue",
         {
           noms <- c("Independance ratio S/P vs volume", "Correlation ratio S/P vs temps",
                     "Tendance monotone du ratio S/P")
           all(vapply(noms, function(n) {
             l <- lig_ea(n)
             is.na(l$p_exacte) && is.na(l$p_min) && is.finite(l$p_mc) &&
               identical(l$p_retenue, l$p_mc) &&
               grepl("ex aequo dans r : loi de permutation conditionnelle non tabulee",
                     l$detail, fixed = TRUE)
           }, logical(1)))
         })
verifier("Cox-Stuart : m = 3 sur n_p = 4 affiche, p_mc non calculee (motif ex aequo)",
         {
           l <- lig_ea("Tendance par signes du ratio S/P")
           grepl("m = 3 differences non nulles sur n_p = 4 paires", l$detail, fixed = TRUE) &&
             is.na(l$p_mc) && identical(l$p_min, 0.25)
         })
verifier("Smirnov (option (i)) : p exacte et p_min NA, motif ex aequo dans z, Monte-Carlo retenue",
         {
           l <- lig_ea("Egalite des lois petits vs gros volumes (2 ech.)")
           identical(l$type, "test") && is.na(l$p_exacte) && is.na(l$p_min) &&
             is.finite(l$stat) && is.finite(l$p_mc) && identical(l$p_retenue, l$p_mc) &&
             grepl("ex aequo dans z : loi conditionnelle non attribuee", l$detail, fixed = TRUE) &&
             !grepl("minimale atteignable = 0.0286", l$detail, fixed = TRUE)
         })
verifier("Suites (z et r) : la paire a la mediane ecartee, n1 = n2 = 3",
         {
           a <- lig_ea("Test des suites (aleatoire des signes)")
           b <- lig_ea("Test des suites sur ratios bruts")
           grepl("n1 = 3, n2 = 3", a$detail, fixed = TRUE) &&
             grepl("n1 = 3, n2 = 3", b$detail, fixed = TRUE)
         })
verifier("Catalogue Monte-Carlo : memes statistiques observees que usp_tests() (SpearVol, SpearTps, MK, Smirnov, Runs, Runsr)",
         {
           so <- res_ea$bootstrap$stats_obs
           identical(unname(so$SpearVol), lig_ea("Independance ratio S/P vs volume")$stat) &&
             identical(unname(so$SpearTps), lig_ea("Correlation ratio S/P vs temps")$stat) &&
             identical(unname(so$MK), lig_ea("Tendance monotone du ratio S/P")$stat) &&
             identical(unname(so$Smirnov), lig_ea("Egalite des lois petits vs gros volumes (2 ech.)")$stat) &&
             identical(unname(so$Runs), lig_ea("Test des suites (aleatoire des signes)")$stat) &&
             is.na(so$CoxStuart)
         })

## --- 4. Ecart relatif 1e-6 : aucun ex aequo -----------------------------------
y_d <- y_ea; y_d[5] <- 3310.23 * (1 + 1e-6)
r_d <- y_d / x_ea
verifier("Ecart relatif 1e-6 : aucun des cinq tests ne signale d'ex aequo",
         {
           cx <- test_cox_stuart(r_d)
           !engine_ex_aequo(r_d) && identical(cx$m, 4L) && is.finite(mk_p_exacte(r_d)) &&
             sum(.runs_effectifs(r_d)) == 8L &&
             identical(engine_aplatir_ex_aequo(r_d), r_d)
         })
verifier("Ecart relatif 1e-6 via run_engine() : aucun motif ex aequo, p_min attribuees",
         {
           res_d <- run_engine(xt = x_ea, yt = y_d, methode = "premium", segment = 1,
                               annexe = "II", nature_donnees = "brutes",
                               B = B_MIN_USAGE, seed = 20260831)
           noms <- c("Independance ratio S/P vs volume", "Correlation ratio S/P vs temps",
                     "Tendance monotone du ratio S/P", "Tendance par signes du ratio S/P",
                     "Egalite des lois petits vs gros volumes (2 ech.)",
                     "Test des suites (aleatoire des signes)")
           ls_ <- Filter(function(l) l$test %in% noms, res_d$tests)
           length(ls_) == length(noms) &&
             !any(vapply(ls_, function(l) grepl("ex aequo dans", l$detail) ||
                                          grepl("differences non nulles sur", l$detail),
                         logical(1))) &&
             all(vapply(ls_, function(l) is.finite(l$p_min), logical(1)))
         })
verifier("Cas construit f29_bande (#29, ratios centraux distants de 1e-10) : distincts a TOL_EX_AEQUO",
         {
           x29 <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
           y29 <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
           r <- y29 / x29; o <- order(r)
           r[o[5]] <- r[o[4]] * (1 - 1e-10)
           !engine_ex_aequo(r)
         })

## --- 5. Jeu de controle : aplatissement sans effet ----------------------------
verifier("Jeu de controle (x, y des cas de reference) : x, r, u, z sans ex aequo, aplatissement identite",
         {
           x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
           y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
           f <- usp_ajuster(x, y); r <- y / x; u <- r - mean(r)
           all(vapply(list(x, r, u, f$z), function(v)
             identical(engine_aplatir_ex_aequo(v), v), logical(1)))
         })

## --- 6. Volumes distincts (#110) sur la meme definition -----------------------
verifier(".usp_nb_volumes_distincts() : volumes egaux a 1e-13 relatif comptent pour un",
         .usp_nb_volumes_distincts(c(100, 100 * (1 + 1e-13), 200, 200)) == 2L &&
         .usp_nb_volumes_distincts(c(100, 100 * (1 + 1e-6), 200)) == 3L)
verifier(".usp_nb_volumes_distincts() : tolerance purement relative, invariante d'unite (c = 1e-150, 1e150, 1e-200, 1e200)",
         {
           v <- c(100, 100 * (1 + 1e-13), 101, 200)
           all(vapply(c(1, 1e-150, 1e150, 1e-200, 1e200), function(cc)
             .usp_nb_volumes_distincts(cc * v) == 3L, logical(1)))
         })
verifier("plancher : engine_aplatir_ex_aequo(plancher = 0) purement relatif, defaut plancher = 1 inchange",
         engine_ex_aequo(c(0, 5e-13)) && !engine_ex_aequo(c(0, 5e-13), plancher = 0) &&
         engine_ex_aequo(c(1e-3, 1e-3 + 5e-13)) &&
         !engine_ex_aequo(c(1e-3, 1e-3 + 5e-13), plancher = 0) &&
         identical(.usp_aplatir_volumes(c(1e-3, 1e-3 * (1 + 1e-13))), c(1e-3, 1e-3)))
# Constat C1 d'audit (#112) : la version par division par le plus petit |x|
# non nul debordait (x / s = 1e300 / 1e-300) et levait "valeur non finie".
verifier("C1 : .usp_nb_volumes_distincts(c(1e-300, 2e-300, 1e300, 5, 6)) = 5, sans erreur",
         {
           k <- tryCatch(.usp_nb_volumes_distincts(c(1e-300, 2e-300, 1e300, 5, 6)),
                         error = function(e) conditionMessage(e))
           if (identical(k, 5L)) TRUE else paste("obtenu :", k)
         })
verifier("Volumes (1e-3, 1e-3 + 5e-13, 2e-3, 3e-3) : meme reponse pour k et pour SpearVol (4 volumes distincts)",
         {
           xv <- c(1e-3, 1e-3 + 5e-13, 2e-3, 3e-3, 4e-3, 5e-3, 6e-3, 7e-3)
           rv <- c(0.71, 0.64, 0.80, 0.69, 0.75, 0.62, 0.90, 0.66)
           e <- list(x = xv, r = rv, T = 8L)
           s_cat <- USP_CATALOGUE_MC$SpearVol$calc(e)
           s_brut <- unname(suppressWarnings(stats::cor.test(rv, xv, method = "spearman",
                                                             exact = FALSE)$statistic))
           .usp_nb_volumes_distincts(xv[1:4]) == 4L &&
             .usp_nb_volumes_distincts(xv) == 8L &&
             !anyDuplicated(.usp_aplatir_volumes(xv)) &&
             identical(s_cat, s_brut) &&
             # au plancher 1, les deux premiers volumes seraient ex aequo
             engine_ex_aequo(xv)
         })
verifier("Volume nul ou quasi nul, plancher 0 : ni division par zero ni boucle",
         {
           a <- .usp_aplatir_volumes(c(0, 0, 1e-300, 5))
           b <- .usp_aplatir_volumes(c(0, 1e-320, 5))
           identical(a, c(0, 0, 1e-300, 5)) && identical(b, c(0, 1e-320, 5)) &&
             .usp_nb_volumes_distincts(c(0, 0, 1e-300, 5)) == 3L &&
             .usp_nb_volumes_distincts(rep(0, 4)) == 1L &&
             .usp_nb_volumes_distincts(c(0, 1e-320, 5)) == 3L
         })

## --- Ex aequo des ratios a tolerance relative (issue #187) -------------------
# Les tests de rang et de signe sur ratios (Mann-Kendall, Cox-Stuart,
# Spearman ratio / volume et ratio / temps) aplatissent r_t a plancher 0
# (tolerance purement relative), et les suites sur ratios bruts aplatissent
# u_t = r_t - moyenne(r) a plancher max|r| (.usp_plancher_u(), decision
# Q-187-1 b), a l'observe comme dans le catalogue USP_CATALOGUE_MC : leurs
# resultats ne dependent plus de l'unite de y par rapport a x. Avant #187 (plancher 1, tolerance absolue 1e-12 sous 1),
# donnees_ln.csv a y x 1e-10 fusionnait deux ratios distants de 7,7e-4 en
# relatif (suites INFO, p exactes perdues), et a y x 1e-20, x x 1e40 les
# quatre lignes passaient en INFO (mesures de l'issue).
LIGNES_RATIOS <- c("Independance ratio S/P vs volume", "Correlation ratio S/P vs temps",
                   "Tendance monotone du ratio S/P", "Tendance par signes du ratio S/P",
                   "Test des suites sur ratios bruts")
.dossier187 <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
outils187 <- new.env(parent = globalenv())
sys.source(file.path(.dossier187, "..", "outils_tests.R"), envir = outils187)
d187 <- utils::read.csv(file.path(.dossier187, "..", "donnees", "donnees_ln.csv"))
calcul187 <- function(x, y) suppressWarnings(
  run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
             nature_donnees = "brutes"))
# Cle de comparaison des lignes sur ratios : verdict, nature, p retenue et
# nombre d'INFO, mais aussi statistique, p exacte et p_min (statistiques de
# rang, invariantes d'echelle), et le commentaire de chaque ligne, qui porte
# les effectifs de la loi discrete (m, n1, n2) : verdict et p retenue seuls
# laissaient survivre un retour de test_cox_stuart() au plancher 1 dans
# usp_tests() (ligne INFO a c = 1 comme a c = 1e-20 ; audit de #187, C1).
cle187 <- function(res) {
  tt <- engine_table_tests(res); l <- tt[match(LIGNES_RATIOS, tt$test), ]
  list(verdict = l$verdict, nature = l$nature_p, p = l$p_retenue,
       n_info = sum(l$verdict == "INFO"),
       num = c(l$statistique, l$p_exacte, l$p_min), detail = l$commentaire,
       commentaire = tt$commentaire)
}
# Mises a l'echelle : c applique a y puis a x, c dans {1e-40, 1e-20, 1e-10,
# 1e10, 1e40}, et mises a l'echelle opposees de y et de x jusqu'aux bornes du
# domaine de #145 (commentaire d'actuary du 05/10/2026 sur #187 : ratios
# d'environ 1e-100 a 1e100). Renvoie les ecarts a c = 1 (vide si conforme).
balayage187 <- function(x, y, echelles = c(1e-40, 1e-20, 1e-10, 1e10, 1e40)) {
  a <- cle187(calcul187(x, y))
  sc <- list()
  for (cc in echelles) {
    sc[[sprintf("y x %g", cc)]] <- c(1, cc); sc[[sprintf("x x %g", cc)]] <- c(cc, 1)
  }
  sc[["y -> 1e-50, x -> 1e50"]] <- c(DOMAINE_NUMERIQUE_MAX / max(x), DOMAINE_NUMERIQUE_MIN / min(y))
  sc[["y -> 1e50, x -> 1e-50"]] <- c(DOMAINE_NUMERIQUE_MIN / min(x), DOMAINE_NUMERIQUE_MAX / max(y))
  ecarts <- character(0)
  for (nm in names(sc)) {
    res <- calcul187(x * sc[[nm]][1], y * sc[[nm]][2])
    if (!isTRUE(res$ok)) { ecarts <- c(ecarts, paste(nm, ": refus")); next }
    b <- cle187(res)
    if (!identical(b$verdict, a$verdict) || !identical(b$nature, a$nature) ||
        !identical(b$n_info, a$n_info) ||
        !isTRUE(outils187$comparer_objets(a$p, b$p)$conforme))
      ecarts <- c(ecarts, sprintf("%s : verdicts %s", nm, paste(b$verdict, collapse = "/")))
    if (!isTRUE(outils187$comparer_objets(a$num, b$num)$conforme))
      ecarts <- c(ecarts, sprintf("%s : statistique, p exacte ou p_min differente", nm))
    if (!identical(b$detail, a$detail))
      ecarts <- c(ecarts, sprintf("%s : commentaire (effectifs) different", nm))
    if (any(grepl("()", b$commentaire, fixed = TRUE)))
      ecarts <- c(ecarts, paste(nm, ": commentaire avec \"()\""))
  }
  if (length(ecarts)) paste(ecarts, collapse = " ; ") else TRUE
}
verifier("#187 : donnees_ln.csv, y puis x x c (c = 1e-40 a 1e40) et echelles opposees aux bornes du domaine -> verdicts, natures, p retenues, statistiques, p exactes, p_min (TOLERANCE), commentaires (effectifs) et nombre d'INFO des lignes sur ratios egaux a c = 1, aucun commentaire avec \"()\"",
         balayage187(d187$xt, d187$yt))
# Jeu a delta interieur (tests/unitaires/test_controles_numeriques.R) : le
# commentaire d'actuary sur #187 y mesurait 14 lignes INFO a y x 1e-6, 17 a
# y x 1e-11, 18 a y x 1e-12 et 1e-13 avant #187. Echantillon d'echelles
# (cout : un run_engine() par echelle).
verifier("#187 : jeu a delta interieur, y x 1e-12, x x 1e12 et echelles opposees aux bornes du domaine -> lignes sur ratios egales a c = 1",
         balayage187(c(50, 80, 120, 200, 300, 150, 90, 60),
                     c(29.92, 56.9, 101.25, 123.06, 207.23, 105.91, 68.59, 40.05),
                     echelles = 1e-12))
verifier("#187 : catalogue Monte-Carlo, MK, SpearVol, SpearTps, CoxStuart et Runsr invariants par r x c (c = 1e-30, 1e-12, 1e12)",
         {
           xr <- d187$xt; yr <- d187$yt; fr <- usp_ajuster(xr, yr); zr <- fr$z
           noms <- c("MK", "SpearVol", "SpearTps", "CoxStuart", "Runsr")
           st <- function(cc) vapply(noms, function(n)
             USP_CATALOGUE_MC[[n]]$calc(.usp_contexte_mc(xr, yr * cc, zr, fr$pi)), numeric(1))
           s1 <- st(1)
           all(is.finite(s1)) &&
             all(vapply(c(1e-30, 1e-12, 1e12), function(cc)
               isTRUE(outils187$comparer_objets(s1, st(cc))$conforme), logical(1)))
         })
verifier("#187 : fonctions de rang a plancher 0 (r) et max|r| (u) invariantes d'echelle, plancher 1 par defaut inchange (z_t, residus de Mack)",
         {
           r <- d187$yt / d187$xt; u <- r - mean(r)
           rs <- r * 1e-20; us <- rs - mean(rs); pu <- .usp_plancher_u(rs)
           identical(test_mann_kendall(r * 1e-20, plancher = 0)$S, test_mann_kendall(r)$S) &&
             identical(test_cox_stuart(r * 1e-20, plancher = 0)$m, 4L) &&
             identical(test_cox_stuart(r * 1e-20)$m, 0L) &&
             identical(mk_p_exacte(r * 1e-20, plancher = 0), mk_p_exacte(r)) &&
             is.na(mk_p_exacte(r * 1e-20)) &&
             identical(runs_p_exacte(us, plancher = pu), runs_p_exacte(u)) &&
             identical(.runs_effectifs(us, plancher = pu), .runs_effectifs(u)) &&
             identical(test_runs(us, plancher = pu)$runs, test_runs(u)$runs) &&
             is.na(test_runs(us)$stat)
         })
# Libelle de la ligne des suites sur ratios bruts quand pi_t est EXACTEMENT
# constant mais qu'un signe differe entre u_t - med(u) et z_t - med(z) (#187,
# troisieme constat) : volumes constants (pi_t exactement constant), deux
# ratios centraux 0,75 -/+ d. A d = 1e-13 (mesure du 06/10/2026) : ex aequo
# sur u (plancher max|r| = 0,9, tolerance 9e-13 > ecart 2e-13 : n1 = n2 = 3)
# mais distincts sur z (plancher 1 ; Runs : n1 = n2 = 4, statistique
# -2,291 contre -1,826 sur Runsr), d'ou le regime 2. Le libelle ne contient
# ni "()" ni "tolerance TOL_DELTA_BORD", nomme la constance exacte, decrit la
# tolerance relative a max|r| sur u et ne dit pas la p Monte-Carlo retenue.
runsr187 <- function(d) {
  xc <- rep(100, 8)
  rc <- c(0.6, 0.65, 0.7, 0.75 - d, 0.75 + d, 0.8, 0.85, 0.9)
  res <- calcul187(xc, rc * xc)
  tt <- engine_table_tests(res)
  list(ok = res$ok, pi_exact = usp_regime(res$ajustement$delta, xc)$pi_constant_exact,
       runs = tt[tt$test == "Test des suites (aleatoire des signes)", ],
       runsr = tt[tt$test == "Test des suites sur ratios bruts", ])
}
verifier("#187 : Runsr a pi_t exactement constant et signes differents (d = 1e-13) -> libelle sans \"()\", constance exacte nommee, tolerance relative a max|r| sur u, p Monte-Carlo non dite retenue",
         {
           a <- runsr187(1e-13); cm <- a$runsr$commentaire
           isTRUE(a$ok) && isTRUE(a$pi_exact) && length(cm) == 1L &&
             !identical(a$runs$statistique, a$runsr$statistique) &&
             grepl("pi_t est exactement constant", cm, fixed = TRUE) &&
             grepl("relative a max|r| sur u, absolue sous 1 sur z", cm, fixed = TRUE) &&
             grepl("seconde condition de la fonction usp_runsr_p_exacte", cm, fixed = TRUE) &&
             !grepl("TOL_DELTA_BORD", cm, fixed = TRUE) &&
             !grepl("()", cm, fixed = TRUE) &&
             !grepl("Monte-Carlo, simulee sous le modele ajuste, est retenue", cm, fixed = TRUE)
         })
# A d = 1e-14, les deux ratios centraux sont ex aequo sur u ET sur z : signes
# identiques, Runs et Runsr coherents (mesure du 06/10/2026 : tous deux INFO,
# inoperants, statistique -1,826 des deux cotes) ; le regime 2 n'est pas
# atteint (sous le plancher 0 sur u de la premiere version de #187, il
# l'etait).
verifier("#187 : d = 1e-14, Runs et Runsr coherents (tous deux INFO, meme statistique), hors regime 2",
         {
           a <- runsr187(1e-14); cm <- a$runsr$commentaire
           isTRUE(a$ok) && isTRUE(a$pi_exact) &&
             identical(a$runs$verdict, "INFO") && identical(a$runsr$verdict, "INFO") &&
             identical(a$runs$statistique, a$runsr$statistique) &&
             is.finite(a$runsr$statistique) &&
             !grepl("Toutefois au moins un signe differe", cm, fixed = TRUE)
         })

fin_fichier()
