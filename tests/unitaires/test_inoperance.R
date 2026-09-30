###############################################################################
#  tests/unitaires/test_inoperance.R  --  TESTS INOPERANTS, MOTIFS MONTE-CARLO,
#                                         P-VALUES RETENUES (ISSUE #44)
#
#  Specification commune #44 / #70 / #59 d'actuary (26/09/2026), section 1.9 :
#    - p minimale atteignable des lois de reference discretes (regle R1) ;
#    - regle d'inoperance de add() (engine_registre_tests()) ;
#    - motif d'indisponibilite de la p Monte-Carlo, conditions `degenere` et
#      `non_definie` du catalogue (regles R2, R3 ; ADR 0003 point 5) ;
#    - constante et TOST (regle R5), pente et Fisher (regle R4, option E),
#      Anderson-Darling et Cramer-von Mises (regle R6).
#  References : enumeration exhaustive (suites), stats::binom.test,
#  stats::ks.test, stats::cor.test (Kendall et Spearman exacts), stats::pt,
#  calcul a la main de l'indice lambda.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_inoperance.R")

x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
fit <- usp_ajuster(x, y)                       # delta = 1, pi_t constant

# Objet bootstrap fictif (aucune simulation) : p Monte-Carlo a 0,5, aucun
# motif ; `motif` permet d'en poser un sur une statistique.
boot_fictif <- function(f, p = 0.5, motif = NULL) {
  s <- .stats_bootstrapables(f$x, f$y, f$z)
  pm <- stats::setNames(rep(p, length(s)), names(s))
  mm <- stats::setNames(rep(NA_character_, length(s)), names(s))
  if (!is.null(motif)) { pm[names(motif)] <- NA_real_; mm[names(motif)] <- motif }
  list(stats_obs = as.list(s), p_mc = pm, err_mc = pm * 0 + 0.01, motif_mc = mm)
}
ligne <- function(tt, nom) Filter(function(l) identical(l$test, nom), tt)[[1]]

## --- 1. p minimale atteignable (regle R1) -------------------------------------
# Suites : enumeration exhaustive des arrangements de n1 signes + et n2 signes -,
# loi de R, puis minimum sur le support de 2 min(P(R <= r), P(R >= r)).
runs_p_min_enum <- function(n1, n2) {
  n <- n1 + n2
  pos <- utils::combn(n, n1)
  R <- apply(pos, 2, function(p) { s <- rep(-1, n); s[p] <- 1; 1 + sum(diff(s) != 0) })
  sup <- sort(unique(R))
  min(1, min(vapply(sup, function(r) 2 * min(mean(R <= r), mean(R >= r)), numeric(1))))
}
verifier("runs_p_min : enumeration exhaustive, n1 = n2 = floor(T/2), T = 5..12",
         {
           ok <- vapply(5:12, function(T) {
             k <- T %/% 2
             isTRUE(proche(runs_p_min(k, k), runs_p_min_enum(k, k), abs = 1e-12))
           }, logical(1))
           if (all(ok)) TRUE else paste("T en defaut :", paste((5:12)[!ok], collapse = ", "))
         })
verifier("runs_p_min : valeurs de la specification (0,667 ; 0,200 ; 0,057 ; 0,016 ; 0,004)",
         proche(runs_p_min(2, 2), 2 / 3, rel = 1e-12) && proche(runs_p_min(3, 3), 0.2, rel = 1e-12) &&
         proche(runs_p_min(4, 4), 4 / 70, rel = 1e-12) &&
         round(runs_p_min(5, 5), 3) == 0.016 && round(runs_p_min(6, 6), 3) == 0.004)
verifier("runs_p_min : effectifs desequilibres (n1 = 5, n2 = 3) = enumeration ; NA si un seul cote",
         proche(runs_p_min(5, 3), runs_p_min_enum(5, 3), abs = 1e-12) &&
         is.na(runs_p_min(0, 8)) && is.na(runs_p_min(8, 0)))
verifier("cox_stuart_p_min : = binom.test(0, m) pour m = 2..6 ; m = 3 -> 0,25 ; m = 0 -> 1",
         all(vapply(2:6, function(m) isTRUE(proche(cox_stuart_p_min(m),
                                                   stats::binom.test(0, m, 0.5)$p.value,
                                                   rel = 1e-12)), logical(1))) &&
         identical(cox_stuart_p_min(3), 0.25) && identical(cox_stuart_p_min(0), 1))
verifier("smirnov_p_min : = ks.test(1:n, (n+1):(2n)) exact, n = 3..6 (2/70 a n = 4)",
         all(vapply(3:6, function(n) isTRUE(proche(smirnov_p_min(n, n),
                                                   stats::ks.test(1:n, (n + 1):(2 * n))$p.value,
                                                   rel = 1e-12)), logical(1))) &&
         proche(smirnov_p_min(4, 4), 2 / 70, rel = 1e-12))
verifier("mk_p_min : = cor.test exact (Kendall et Spearman) sur la permutation extreme, T = 5..9",
         all(vapply(5:9, function(T) {
           k <- stats::cor.test(1:T, 1:T, method = "kendall", exact = TRUE)$p.value
           s <- suppressWarnings(stats::cor.test(1:T, 1:T, method = "spearman", exact = TRUE)$p.value)
           isTRUE(proche(mk_p_min(T), k, rel = 1e-10)) && isTRUE(proche(mk_p_min(T), s, rel = 1e-10))
         }, logical(1))))

## --- 2. Regle d'inoperance dans add() -----------------------------------------
reg_fictif <- function(alpha = 0.10, p_mc = 0.5) {
  engine_registre_tests(list(p_mc = c(A = p_mc), err_mc = c(A = 0.01)),
                        list(A = .mc_entree(function(e) 1, "haut")), alpha, "Monte-Carlo")
}
verifier("add() : p_min >= alpha -> diagnostic INFO, p_retenue NA, p_exacte conservee, detail TEST INOPERANT",
         {
           r <- reg_fictif(); r$add("F", "t", "ref", p_ex = 0.9, p_min = 0.125,
                                    effectifs = "m = 4", detail = "d")
           l <- r$lignes()[[1]]
           identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
             is.na(l$p_retenue) && is.na(l$nature_p) && is.na(l$sens) &&
             identical(l$p_exacte, 0.9) && identical(l$p_min, 0.125) &&
             startsWith(l$detail, "TEST INOPERANT au seuil alpha = 0.1 : p-value minimale atteignable = 0.1250 (m = 4)") &&
             endsWith(l$detail, " d")
         })
verifier("add() : p_min = alpha (borne incluse) -> inoperant",
         { r <- reg_fictif(); r$add("F", "t", "ref", p_ex = 0.9, p_min = 0.10)
           identical(r$lignes()[[1]]$type, "diagnostic") })
verifier("add() : alpha/2 <= p_min < alpha -> test maintenu, ECHEC inatteignable dans detail",
         {
           r <- reg_fictif(); r$add("F", "t", "ref", p_ex = 0.06, p_min = 4 / 70, detail = "d.")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$verdict, "ALERTE") &&
             grepl("ECHEC inatteignable : p_min = 0.0571 >= alpha/2 = 0.05", l$detail, fixed = TRUE)
         })
# p exacte absente (pi_t variable, regle R7) : p_min est celle de la loi de
# reference echangeable, pas une borne de la p Monte-Carlo retenue (#44,
# option 3 d'actuary, 27/09/2026). Cas construit : p_mc = 0,048 < alpha/2
# alors que p_min = 4/70 = 0,0571 >= alpha/2.
verifier("add() : p_ex NA, p_min = 0,0571, p_mc = 0,048 -> ECHEC, detail 'ECHEC possible' sans 'ECHEC inatteignable'",
         {
           r <- reg_fictif(p_mc = 0.048)
           r$add("F", "t", "ref", p_min = 4 / 70, mc_nom = "A", effectifs = "n1 = 4, n2 = 4",
                 detail = "d.")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$verdict, "ECHEC") && identical(l$p_retenue, 0.048) &&
             !grepl("ECHEC inatteignable", l$detail, fixed = TRUE) &&
             identical(l$detail, paste("d. p_min de la loi de reference echangeable = 0.0571 >= alpha/2 = 0.05",
                                       "(n1 = 4, n2 = 4) ; la p-value Monte-Carlo retenue, simulee sous le",
                                       "modele ajuste, peut lui etre inferieure (erreur Monte-Carlo,",
                                       "non-echangeabilite) : ECHEC possible"))
         })
verifier("add() : p_ex NA, alpha/2 <= p_min < alpha, p_mc = 0,5 -> test OK, meme texte 'ECHEC possible'",
         {
           r <- reg_fictif(); r$add("F", "t", "ref", p_min = 4 / 70, mc_nom = "A")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$verdict, "OK") &&
             startsWith(l$detail, "p_min de la loi de reference echangeable = 0.0571 >= alpha/2 = 0.05 ;") &&
             endsWith(l$detail, ": ECHEC possible") && !grepl("inatteignable", l$detail, fixed = TRUE)
         })
verifier("add() : p_ex NA, p asymptotique seule, alpha/2 <= p_min < alpha -> texte de la p asymptotique",
         {
           r <- reg_fictif(); r$add("F", "t", "ref", p_as = 0.3, p_min = 4 / 70)
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$nature_p, "asymptotique") &&
             grepl("la p-value asymptotique retenue, calculee hors de cette loi", l$detail, fixed = TRUE) &&
             !grepl("inatteignable", l$detail, fixed = TRUE)
         })
verifier("add() : aucune p (exacte, Monte-Carlo, asymptotique), alpha/2 <= p_min < alpha -> INFO, texte 'ECHEC inatteignable' inchange",
         {
           r <- reg_fictif(); r$add("F", "t", "ref", p_min = 4 / 70)
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             identical(l$detail, "ECHEC inatteignable : p_min = 0.0571 >= alpha/2 = 0.05")
         })
verifier("add() : p_ex NA, p_min >= alpha -> TEST INOPERANT en tete, p_min 'sous la loi de reference echangeable'",
         {
           r <- reg_fictif(p_mc = 0.048)
           r$add("F", "t", "ref", p_min = 0.125, mc_nom = "A", effectifs = "m = 4", detail = "d")
           l <- r$lignes()[[1]]
           identical(l$type, "diagnostic") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             identical(l$p_mc, 0.048) &&
             identical(l$detail, paste("TEST INOPERANT au seuil alpha = 0.1 : p-value minimale atteignable",
                                       "sous la loi de reference echangeable = 0.1250 (m = 4) ; aucun",
                                       "verdict (ADR 0001). d"))
         })
verifier("add() : p_min NA -> comportement inchange (verdict, detail)",
         {
           r <- reg_fictif(); r$add("F", "t", "ref", p_ex = 0.01, detail = "d")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$verdict, "ECHEC") && identical(l$detail, "d") &&
             is.na(l$p_min)
         })
verifier("add() : sens = 'rejeter' et p_min >= alpha -> inoperant",
         { r <- reg_fictif(); r$add("F", "t", "ref", p_ex = 0.01, p_min = 0.2, sens = "rejeter")
           identical(r$lignes()[[1]]$verdict, "INFO") })
verifier("add() : p_min < alpha/2 -> test, detail inchange",
         { r <- reg_fictif(); r$add("F", "t", "ref", p_ex = 0.01, p_min = 0.02, detail = "d")
           l <- r$lignes()[[1]]; identical(l$verdict, "ECHEC") && identical(l$detail, "d") })

## --- 3. Motifs d'indisponibilite Monte-Carlo (regles R2, R3) ------------------
verifier("engine_p_mc : motifs (observee non finie > aucune replication > dispersion nulle), p_mc NA",
         {
           a <- engine_p_mc(1:9, NA_real_, "haut")
           b <- engine_p_mc(c(NA, NaN), 1, "haut")
           c0 <- engine_p_mc(rep(2, 50), 2, "deux")
           d <- engine_p_mc(1:9, 7, "haut")
           identical(a$motif, MOTIF_MC_OBS_NON_FINIE) && identical(b$motif, MOTIF_MC_AUCUNE_REPLIC) &&
             identical(c0$motif, MOTIF_MC_DISPERSION_NULLE) && is.na(c0$p_mc) && is.na(c0$err_mc) &&
             identical(c0$B_effectif, 50) && is.na(d$motif) && proche(d$p_mc, 0.4)
         })
verifier("engine_p_mc : dispersion tout juste au-dessus du seuil relatif (50 simulations) -> p_mc calculee",
         is.na(engine_p_mc(c(rep(1e6, 49), 1e6 + 1e-3), 1e6, "haut")$motif) &&
         identical(engine_p_mc(c(rep(1e6, 49), 1e6 + 1e-7), 1e6, "haut")$motif, MOTIF_MC_DISPERSION_NULLE))
verifier("engine_p_mc : sous B_MIN_DEGENERESCENCE = 50 simulations finies, loi constante -> p_mc calculee, aucun motif",
         {
           o <- engine_p_mc(rep(2, 49), 2, "deux")
           B_MIN_DEGENERESCENCE == 50 && identical(o$p_mc, 1) && is.na(o$motif)
         })
verifier("engine_p_mc : loi ponctuelle, observee hors de l'atome -> motif atome hors obs, p_mc NA",
         {
           o <- engine_p_mc(rep(2, 50), 3, "haut")
           identical(o$motif, MOTIF_MC_ATOME_HORS_OBS) && is.na(o$p_mc) && is.na(o$err_mc)
         })
# run_engine() refuse B < B_MIN_USAGE = 99 (constat C1 de la revue finale
# d'E1) : la branche "sous B_MIN_DEGENERESCENCE" est exercee par
# usp_bootstrap() et usp_tests() appeles directement, non bornes.
verifier("usp_bootstrap(B = 2) + usp_tests() : Smirnov et Cox-Stuart gardent leur p exacte (aucune degenerescence sous 50)",
         {
           b2 <- usp_bootstrap(fit, B = 2, seed = 20260831)
           t2 <- usp_tests(fit, b2, methode = "premium")
           sm <- ligne(t2, "Egalite des lois petits vs gros volumes (2 ech.)")
           cs <- ligne(t2, "Tendance par signes du ratio S/P")
           identical(sm$nature_p, "exacte") && is.finite(sm$p_retenue) &&
             is.finite(cs$p_exacte) && identical(cs$type, "diagnostic") &&
             all(is.na(b2$motif_mc)) && all(is.finite(b2$p_mc[c("Smirnov", "CoxStuart")]))
         })
verifier("run_engine(B = 2) refuse : erreur d'usage citant B_MIN_USAGE",
         {
           e <- tryCatch(run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                                    nature_donnees = "brutes", B = 2, seed = 20260831),
                         error = function(e) e)
           inherits(e, "error") && grepl("B >= B_MIN_USAGE = 99", conditionMessage(e), fixed = TRUE)
         })
cat_synth <- list(
  A = .mc_entree(function(e) e$v, "haut", degenere = function(e) TRUE),
  B = .mc_entree(function(e) e$v, "haut", degenere = function(e) FALSE),
  C = .mc_entree(function(e) NA_real_, "haut", non_definie = function(e) "motif du catalogue"),
  D = .mc_entree(function(e) NA_real_, "haut"))
sim_synth <- matrix(rep(1:9, 4), 9, 4, dimnames = list(NULL, c("A", "B", "C", "D")))
obs_synth <- c(A = 7, B = 7, C = NA_real_, D = NA_real_)
mc_synth <- .mc_p_values(sim_synth, obs_synth, cat_synth, e = list(v = 7))
verifier(".mc_p_values : degenere(e) TRUE -> p_mc NA, motif de la condition du catalogue ; FALSE -> inchange",
         is.na(mc_synth$p_mc[["A"]]) && is.na(mc_synth$err_mc[["A"]]) &&
         identical(mc_synth$motif_mc[["A"]], MOTIF_MC_CONDITION) &&
         proche(mc_synth$p_mc[["B"]], 0.4) && is.na(mc_synth$motif_mc[["B"]]))
verifier(".mc_p_values : non_definie remplace le motif generique ; sans elle, motif generique",
         identical(mc_synth$motif_mc[["C"]], "motif du catalogue") &&
         identical(mc_synth$motif_mc[["D"]], MOTIF_MC_OBS_NON_FINIE))
verifier(".mc_p_values : sans contexte, conditions du catalogue non evaluees (compatibilite)",
         proche(.mc_p_values(sim_synth, obs_synth, cat_synth)$p_mc[["A"]], 0.4))
verifier(".mc_entree : degenere ou non_definie autre qu'une fonction refuse ; degenere non logique refuse",
         leve_erreur(.mc_entree(function(e) 1, "haut", degenere = TRUE)) &&
         leve_erreur(.mc_entree(function(e) 1, "haut", non_definie = "x")) &&
         leve_erreur(.mc_p_values(sim_synth[, "A", drop = FALSE], c(A = 7),
                                  list(A = .mc_entree(function(e) 1, "haut",
                                                      degenere = function(e) NA)), e = list())))
reg_motif <- function(motif) engine_registre_tests(
  list(p_mc = c(S = NA_real_), err_mc = c(S = NA_real_), motif_mc = c(S = motif)),
  list(S = .mc_entree(function(e) 1, "haut")), 0.10, "Monte-Carlo")
verifier("add() : motif de degenerescence -> diagnostic INFO, aucune p retenue meme avec p exacte ou asymptotique",
         {
           ok <- vapply(c(MOTIF_MC_CONDITION, MOTIF_MC_DISPERSION_NULLE, MOTIF_MC_ATOME_HORS_OBS),
                        function(m) {
             r <- reg_motif(m); r$add("F", "t", "ref", p_ex = 0.5, p_as = 0.3, mc_nom = "S")
             l <- r$lignes()[[1]]
             identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
               is.na(l$p_retenue) && startsWith(l$detail, m)
           }, logical(1))
           all(ok)
         })
verifier("add() : statistique observee non finie sans p exacte -> non applicable avec le motif",
         {
           r <- reg_motif(MOTIF_MC_OBS_NON_FINIE); r$add("F", "t", "ref", p_as = 0.3, mc_nom = "S")
           l <- r$lignes()[[1]]
           identical(l$type, "non applicable") && identical(l$verdict, "INFO") &&
             startsWith(l$detail, MOTIF_MC_OBS_NON_FINIE)
         })
verifier("add() : aucune replication finie avec p asymptotique -> repli NOMME",
         {
           r <- reg_motif(MOTIF_MC_AUCUNE_REPLIC); r$add("F", "t", "ref", p_as = 0.3, mc_nom = "S")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$p_retenue, 0.3) &&
             identical(l$nature_p, paste0("asymptotique (Monte-Carlo indisponible : ",
                                          MOTIF_MC_AUCUNE_REPLIC, ")"))
         })
verifier("add() : repli_asymptotique = FALSE, aucune replication finie -> diagnostic, p asymptotique conservee non retenue",
         {
           r <- reg_motif(MOTIF_MC_AUCUNE_REPLIC)
           r$add("F", "t", "ref", p_as = 0.3, mc_nom = "S", repli_asymptotique = FALSE,
                 libelle_p_as = "p de Student sous le modele auxiliaire MCO")
           l <- r$lignes()[[1]]
           identical(l$type, "diagnostic") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             identical(l$p_asymptotique, 0.3) &&
             startsWith(l$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_AUCUNE_REPLIC,
                                         " ; p de Student sous le modele auxiliaire MCO non retenue"))
         })
verifier("add() : motif present et p exacte finie (hors degenerescence) -> p exacte retenue",
         {
           r <- reg_motif("statistique observee non definie : ex aequo")
           r$add("F", "t", "ref", p_ex = 0.5, mc_nom = "S")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$nature_p, "exacte") && identical(l$p_retenue, 0.5)
         })
verifier("add() : bootstrap sans champ motif_mc (objet anterieur) -> comportement inchange",
         {
           r <- engine_registre_tests(list(p_mc = c(S = NA_real_), err_mc = c(S = NA_real_)),
                                      list(S = .mc_entree(function(e) 1, "haut")), 0.10, "MC")
           r$add("F", "t", "ref", p_as = 0.3, mc_nom = "S")
           identical(r$lignes()[[1]]$nature_p, "asymptotique")
         })

## --- 4. usp_tests() : constante, TOST, pente, Fisher, AD, CvM ---------------
tt <- usp_tests(fit, boot_fictif(fit), methode = "premium")
verifier("usp_tests : 46 lignes sans jackknife, IC ni LR sur delta (51 par run_engine()) ; toute ligne non-test hors procedure de decision sort INFO (M7)",
         length(tt) == 46L &&
         all(vapply(Filter(function(l) !l$type %in% c("test", "procedure de decision"), tt),
                    function(l) identical(l$verdict, "INFO") && is.na(l$sens), logical(1))))
verifier("usp_tests : chaque ligne porte un champ p_min (NA pour une loi continue)",
         all(vapply(tt, function(l) "p_min" %in% names(l), logical(1))) &&
         is.na(ligne(tt, "Shapiro-Wilk sur residus standardises")$p_min))
verifier("Constante (R5) : p_exacte NA, p_asymptotique = p de Student de test_intercept(), p Monte-Carlo retenue",
         {
           l <- ligne(tt, "Nullite de la constante (proportionnalite stricte)")
           is.na(l$p_exacte) && identical(l$p_asymptotique, test_intercept(x, y)$p) &&
             identical(l$p_retenue, 0.5) && identical(l$nature_p, "Monte-Carlo (bootstrap parametrique)")
         })
verifier("Constante sans p Monte-Carlo (motif aucune replication finie) : INFO, p_retenue NA, p_asymptotique conservee",
         {
           t0 <- usp_tests(fit, boot_fictif(fit, motif = c(Intercept = MOTIF_MC_AUCUNE_REPLIC)),
                           methode = "premium")
           l <- ligne(t0, "Nullite de la constante (proportionnalite stricte)")
           identical(l$type, "diagnostic") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             identical(l$p_asymptotique, test_intercept(x, y)$p) && grepl("non retenue", l$loi, fixed = TRUE)
         })
verifier("Spearman et Mann-Kendall : un ex aequo dans r -> p_min NA ; Spearman-volume : ex aequo dans x -> NA",
         {
           y2 <- y; y2[2] <- x[2] * y[1] / x[1]          # r_2 = r_1
           f2 <- usp_ajuster(x, y2); t2 <- usp_tests(f2, boot_fictif(f2), methode = "premium")
           x3 <- x; x3[2] <- x[1]; y3 <- y * x3 / x       # x_2 = x_1, ratios conserves
           f3 <- usp_ajuster(x3, y3); t3 <- usp_tests(f3, boot_fictif(f3), methode = "premium")
           anyDuplicated(y2 / x) > 0 &&
             all(vapply(c("Independance ratio S/P vs volume", "Correlation ratio S/P vs temps",
                          "Tendance monotone du ratio S/P"),
                        function(n) is.na(ligne(t2, n)$p_min), logical(1))) &&
             is.na(ligne(t3, "Independance ratio S/P vs volume")$p_min) &&
             isTRUE(proche(ligne(t3, "Correlation ratio S/P vs temps")$p_min, 2 / factorial(8), rel = 1e-12))
         })
verifier("TOST (R5) : nature 'modele auxiliaire MCO' dans les deux branches de marge",
         {
           a <- ligne(tt, "Equivalence de la constante a zero (TOST)")
           t2 <- usp_tests(fit, boot_fictif(fit), delta_equiv = 5, methode = "premium")
           b <- ligne(t2, "Equivalence de la constante a zero (TOST)")
           identical(a$nature_p, "sous le modele auxiliaire MCO : loi de Student, marge estimee sur les donnees") &&
             identical(b$nature_p, "sous le modele auxiliaire MCO : t(T-2) exacte, marge fixee a priori") &&
             is.finite(b$p_exacte) && identical(b$p_retenue, b$p_exacte)
         })
verifier("usp_identifiabilite_pente : lambda = sqrt(T-1) CV(x) beta / sigma et puissance = pt(, ncp) recalcules",
         {
           ip <- usp_identifiabilite_pente(x, fit$beta, fit$sigma, 0.10)
           lam <- sqrt(7) * stats::sd(x) / mean(x) * fit$beta / fit$sigma
           q <- stats::qt(0.95, 6)
           pw <- stats::pt(-q, 6, ncp = lam) + 1 - stats::pt(q, 6, ncp = lam)
           proche(ip$lambda, lam, rel = 1e-12) && proche(ip$puissance, pw, rel = 1e-10) &&
             round(ip$lambda, 2) == 1.78 && round(ip$puissance, 2) == 0.47
         })
# Volumes resserres (CV 3 %) ou disperses (CV 30 %), ratios S/P conserves.
fit_cv <- function(cv) {
  xc <- mean(x) * (1 + cv * as.numeric(scale(x)))
  usp_ajuster(xc, xc * y / x)
}
f03 <- fit_cv(0.03); f30 <- fit_cv(0.30)
t03 <- usp_tests(f03, boot_fictif(f03), methode = "premium")
t30 <- usp_tests(f30, boot_fictif(f30), methode = "premium")
pente <- "Test de Student sur la pente (lm(y~x))"
fisher <- "Test de Fisher (significativite globale)"
verifier("Pente et Fisher (R4) : CV(x) = 3 % -> diagnostic ; CV(x) = 30 % -> test ; meme type pour les deux",
         {
           identical(ligne(t03, pente)$type, "diagnostic") && identical(ligne(t03, fisher)$type, "diagnostic") &&
             identical(ligne(t30, pente)$type, "test") && identical(ligne(t30, fisher)$type, "test") &&
             all(vapply(list(tt, t03, t30), function(t)
               identical(ligne(t, pente)$type, ligne(t, fisher)$type), logical(1)))
         })
verifier("Pente et Fisher (R4) : donnees de test -> diagnostic, lambda et puissance rappeles ; test -> nature MCO",
         {
           l <- ligne(tt, pente); m <- ligne(t30, pente)
           identical(l$type, "diagnostic") &&
             grepl("PENTE NON IDENTIFIABLE", l$detail, fixed = TRUE) &&
             grepl("lambda", m$detail, fixed = TRUE) && grepl("Pente identifiable", m$detail, fixed = TRUE) &&
             identical(m$nature_p, paste("sous le modele auxiliaire MCO : t(T-2) exacte (H0 non simulable :",
                                         "le modele ajuste appartient a H1)")) &&
             is.finite(l$p_asymptotique)
         })
# Nature propre a la ligne Fisher (#117) : sa loi de reference est F(1,T-2),
# non t(T-2). Jeu (xi, yi) de test_controles_numeriques.R (J2, delta
# interieur), ou pente et Fisher sont de type test.
xi <- c(50, 80, 120, 200, 300, 150, 90, 60)
yi <- c(29.92, 56.9, 101.25, 123.06, 207.23, 105.91, 68.59, 40.05)
f_i <- usp_ajuster(xi, yi)
t_i <- usp_tests(f_i, boot_fictif(f_i), methode = "premium")
verifier("Pente et Fisher (#117) : jeu J2 (xi, yi), deux tests ; nature de Fisher F(1,T-2), de la pente t(T-2), loi de Fisher F(1,6)",
         {
           m <- ligne(t_i, pente); f <- ligne(t_i, fisher)
           identical(m$type, "test") && identical(f$type, "test") &&
             identical(m$nature_p, paste("sous le modele auxiliaire MCO : t(T-2) exacte (H0 non simulable :",
                                         "le modele ajuste appartient a H1)")) &&
             identical(f$nature_p, paste("sous le modele auxiliaire MCO : F(1,T-2) exacte (H0 non simulable :",
                                         "le modele ajuste appartient a H1)")) &&
             grepl("^F\\(1,6\\)", f$loi) && !grepl("t(T-2)", f$nature_p, fixed = TRUE)
         })
verifier("AD, CvM (R6) : estim = statistique sur (z - zbar)/s_z, p_asymptotique = Stephens sur estim",
         {
           zs <- (fit$z - mean(fit$z)) / stats::sd(fit$z)
           a <- ligne(tt, "Anderson-Darling"); w <- ligne(tt, "Cramer-von Mises")
           identical(a$estim, stat_ad(zs)) && identical(w$estim, stat_cvm(zs)) &&
             identical(a$p_asymptotique, ad_p_stephens(stat_ad(zs), 8)) &&
             identical(w$p_asymptotique, cvm_p_stephens(stat_cvm(zs), 8)) &&
             round(a$estim, 3) == 0.286 && round(a$p_asymptotique, 3) == 0.527 &&
             round(w$estim, 4) == 0.0491 && round(w$p_asymptotique, 3) == 0.480
         })
# A pi_t constant, (z - zbar)/s_z = sqrt((T-1)/T) z a la tolerance d'arret de
# l'optimiseur pres (var(z) = T/(T-1) a ~6e-7 relatif, ADR 0001 amende).
verifier("AD, CvM (R6) : a pi_t constant, (z - zbar)/s_z = sqrt((T-1)/T) z a 1e-6 pres",
         {
           zs <- (fit$z - mean(fit$z)) / stats::sd(fit$z)
           isTRUE(proche(zs, sqrt(7 / 8) * fit$z, rel = 1e-6, abs = 1e-9))
         })
verifier("AD, CvM (R6) : p_asymptotique NA pour T = 5..7, motif 'hors de la plage' dans le detail",
         all(vapply(5:7, function(T) {
           f <- usp_ajuster(x[1:T], y[1:T]); t <- usp_tests(f, boot_fictif(f), methode = "premium")
           a <- ligne(t, "Anderson-Darling"); w <- ligne(t, "Cramer-von Mises")
           is.na(a$p_asymptotique) && is.na(w$p_asymptotique) && is.finite(a$estim) &&
             grepl("hors de la plage", a$detail, fixed = TRUE) &&
             grepl("hors de la plage", w$detail, fixed = TRUE)
         }, logical(1))))
verifier("Cox-Stuart, suites, Smirnov, Mann-Kendall, Spearman : p_min renseignee ; Cox-Stuart inoperant a T = 8",
         {
           cs <- ligne(tt, "Tendance par signes du ratio S/P")
           ru <- ligne(tt, "Test des suites (aleatoire des signes)")
           ks <- ligne(tt, "Egalite des lois petits vs gros volumes (2 ech.)")
           identical(cs$p_min, 0.125) && identical(cs$type, "diagnostic") &&
             proche(ru$p_min, 4 / 70, rel = 1e-12) && identical(ru$type, "test") &&
             grepl("ECHEC inatteignable", ru$detail, fixed = TRUE) &&
             proche(ks$p_min, 2 / 70, rel = 1e-12) &&
             all(vapply(c("Independance ratio S/P vs volume", "Correlation ratio S/P vs temps",
                          "Tendance monotone du ratio S/P"),
                        function(n) isTRUE(proche(ligne(tt, n)$p_min, 2 / factorial(8), rel = 1e-12)),
                        logical(1)))
         })

## --- 5. Invariant I2 sur run_engine() ----------------------------------------
# Aucune ligne dont la p Monte-Carlo manque ne retombe sur une nature
# "asymptotique" sans motif : a T = 8, la seule ligne a p asymptotique sans
# statistique Monte-Carlo (Anscombe-Glynn, T >= 20) est non applicable.
inv_i2 <- function(res) {
  tb <- engine_table_tests(res)
  n_nu <- sum(tb$nature_p == "asymptotique", na.rm = TRUE)
  if (n_nu == 0L && all(is.na(res$bootstrap$motif_mc) | nzchar(res$bootstrap$motif_mc))) TRUE
  else paste("lignes 'asymptotique' sans motif :", n_nu)
}
res_ln <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                     nature_donnees = "brutes", B = B_MIN_USAGE, seed = 20260831)
res_vc <- run_engine(xt = rep(100, 8), yt = y, methode = "premium", segment = 1, annexe = "II",
                     nature_donnees = "brutes", B = B_MIN_USAGE, seed = 20260831)
verifier("Invariant I2 : donnees de test, aucune nature 'asymptotique' sans motif ; motif_mc tout NA",
         isTRUE(inv_i2(res_ln)) && all(is.na(res_ln$bootstrap$motif_mc)) &&
           identical(names(res_ln$bootstrap$motif_mc), names(USP_CATALOGUE_MC)))
verifier("Invariant I2 : volumes constants, aucune nature 'asymptotique' sans motif", inv_i2(res_vc))
verifier("engine_table_tests : colonne p_min presente, une valeur par ligne",
         { tb <- engine_table_tests(res_ln); "p_min" %in% names(tb) && nrow(tb) == length(res_ln$tests) })
# L'invariant I5 (memes lignes a volumes constants) est teste dans
# test_volumes_constants.R (#59).
# B = B_MIN_USAGE = 99 : IC bootstrap 90 % calcule (plus de 20 tirages), donc
# ligne de largeur d'IC presente (48 lignes avant #45) ; sous 21 tirages, que
# run_engine() n'admet plus, elle manquait (47 lignes). Depuis #45 : plus la
# ligne de l'IC restreint (meme regle) et les deux lignes LR sur delta.
verifier("run_engine : 51 lignes sur les donnees de test a B = B_MIN_USAGE (lignes de largeur d'IC et de LR sur delta comprises)",
         length(res_ln$tests) == 51L && !is.null(res_ln$ic_bootstrap) &&
           any(vapply(res_ln$tests, function(l) identical(l$test, "Largeur relative de l'IC bootstrap 90%"),
                      logical(1))))

fin_fichier()
