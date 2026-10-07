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
  s <- .stats_bootstrapables(f$x, f$y, f$z, f$pi)
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
           r <- reg_fictif(); r$add("F", "t", "ref", fonction = "usp_tests", p_ex = 0.9, p_min = 0.125,
                                    effectifs = "m = 4", detail = "d")
           l <- r$lignes()[[1]]
           identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
             is.na(l$p_retenue) && is.na(l$nature_p) && is.na(l$sens) &&
             identical(l$p_exacte, 0.9) && identical(l$p_min, 0.125) &&
             startsWith(l$detail, "TEST INOPERANT au seuil alpha = 0.1 : p-value minimale atteignable = 0.1250 (m = 4)") &&
             endsWith(l$detail, " d")
         })
verifier("add() : p_min = alpha (borne incluse) -> inoperant",
         { r <- reg_fictif(); r$add("F", "t", "ref", fonction = "usp_tests", p_ex = 0.9, p_min = 0.10)
           identical(r$lignes()[[1]]$type, "diagnostic") })
verifier("add() : alpha/2 <= p_min < alpha -> test maintenu, ECHEC inatteignable dans detail",
         {
           r <- reg_fictif(); r$add("F", "t", "ref", fonction = "usp_tests", p_ex = 0.06, p_min = 4 / 70, detail = "d.")
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
           r$add("F", "t", "ref", fonction = "usp_tests", p_min = 4 / 70, mc_nom = "A", effectifs = "n1 = 4, n2 = 4",
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
           r <- reg_fictif(); r$add("F", "t", "ref", fonction = "usp_tests", p_min = 4 / 70, mc_nom = "A")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$verdict, "OK") &&
             startsWith(l$detail, "p_min de la loi de reference echangeable = 0.0571 >= alpha/2 = 0.05 ;") &&
             endsWith(l$detail, ": ECHEC possible") && !grepl("inatteignable", l$detail, fixed = TRUE)
         })
verifier("add() : p_ex NA, p asymptotique seule, alpha/2 <= p_min < alpha -> texte de la p asymptotique",
         {
           r <- reg_fictif(); r$add("F", "t", "ref", fonction = "usp_tests", p_as = 0.3, p_min = 4 / 70)
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$nature_p, "asymptotique") &&
             grepl("la p-value asymptotique retenue, calculee hors de cette loi", l$detail, fixed = TRUE) &&
             !grepl("inatteignable", l$detail, fixed = TRUE)
         })
# #128, point 2' (decision du mainteneur du 01/10/2026) : sans aucune p, la
# phrase "ECHEC inatteignable" n'est plus ajoutee ; le detail dit qu'aucun
# verdict n'est possible. Type, verdict, sens et p_retenue inchanges.
verifier("add() : aucune p (exacte, Monte-Carlo, asymptotique), alpha/2 <= p_min < alpha -> test INFO, phrase 'aucune p-value disponible', sans 'ECHEC inatteignable'",
         {
           r <- reg_fictif(); r$add("F", "t", "ref", fonction = "usp_tests", p_min = 4 / 70)
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             identical(l$sens, "ne pas rejeter") &&
             identical(l$detail, "aucune p-value disponible sur ces donnees : aucun verdict (ADR 0001).")
         })
verifier("add() : p_ex NA, p_min >= alpha -> TEST INOPERANT en tete, p_min 'sous la loi de reference echangeable'",
         {
           r <- reg_fictif(p_mc = 0.048)
           r$add("F", "t", "ref", fonction = "usp_tests", p_min = 0.125, mc_nom = "A", effectifs = "m = 4", detail = "d")
           l <- r$lignes()[[1]]
           identical(l$type, "diagnostic") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             identical(l$p_mc, 0.048) &&
             identical(l$detail, paste("TEST INOPERANT au seuil alpha = 0.1 : p-value minimale atteignable",
                                       "sous la loi de reference echangeable = 0.1250 (m = 4) ; aucun",
                                       "verdict (ADR 0001). d"))
         })
verifier("add() : p_min NA -> comportement inchange (verdict, detail)",
         {
           r <- reg_fictif(); r$add("F", "t", "ref", fonction = "usp_tests", p_ex = 0.01, detail = "d")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$verdict, "ECHEC") && identical(l$detail, "d") &&
             is.na(l$p_min)
         })
verifier("add() : sens = 'rejeter' et p_min >= alpha -> inoperant",
         { r <- reg_fictif(); r$add("F", "t", "ref", fonction = "usp_tests", p_ex = 0.01, p_min = 0.2, sens = "rejeter")
           identical(r$lignes()[[1]]$verdict, "INFO") })
verifier("add() : p_min < alpha/2 -> test, detail inchange",
         { r <- reg_fictif(); r$add("F", "t", "ref", fonction = "usp_tests", p_ex = 0.01, p_min = 0.02, detail = "d")
           l <- r$lignes()[[1]]; identical(l$verdict, "ECHEC") && identical(l$detail, "d") })

## --- 3. Motifs d'indisponibilite Monte-Carlo (regles R2, R3) ------------------
verifier("engine_p_mc : motifs (observee non finie > aucune replication > replications insuffisantes > dispersion nulle), p_mc NA",
         {
           a <- engine_p_mc(1:9, NA_real_, "haut")
           b <- engine_p_mc(c(NA, NaN), 1, "haut")
           c0 <- engine_p_mc(rep(2, 50), 2, "deux")
           d <- engine_p_mc(1:99, 70, "haut")
           e <- engine_p_mc(1:9, 7, "haut")
           identical(a$motif, MOTIF_MC_OBS_NON_FINIE) && identical(b$motif, MOTIF_MC_AUCUNE_REPLIC) &&
             identical(c0$motif, MOTIF_MC_DISPERSION_NULLE) && is.na(c0$p_mc) && is.na(c0$err_mc) &&
             identical(c0$B_effectif, 50) && is.na(d$motif) && proche(d$p_mc, 0.31) &&
             identical(e$motif, MOTIF_MC_REPLIC_INSUFFISANTES)
         })
verifier("engine_p_mc : dispersion tout juste au-dessus du seuil relatif (50 simulations) -> p_mc calculee",
         is.na(engine_p_mc(c(rep(1e6, 49), 1e6 + 1e-3), 1e6, "haut")$motif) &&
         identical(engine_p_mc(c(rep(1e6, 49), 1e6 + 1e-7), 1e6, "haut")$motif, MOTIF_MC_DISPERSION_NULLE))
# #128, point 1 : 0 < B_eff < B_MIN_DEGENERESCENCE = 50 -> motif
# MOTIF_MC_REPLIC_INSUFFISANTES, p_mc et err_mc NA (motif pose si et
# seulement si p_mc est absente), B_effectif rendu ; B_eff = 50 : p_mc
# calculee, sans motif ; B_eff = 0 : motif existant MOTIF_MC_AUCUNE_REPLIC.
# Les simulations non finies ne comptent pas dans B_eff.
verifier("engine_p_mc : B_eff = 1 et 49 -> motif replications insuffisantes, p_mc NA ; 50 -> p_mc calculee ; 0 -> aucune replication",
         {
           insuff <- function(o, b) identical(o$motif, MOTIF_MC_REPLIC_INSUFFISANTES) &&
             is.na(o$p_mc) && is.na(o$err_mc) && identical(o$B_effectif, b)
           o1 <- engine_p_mc(c(3, NA, Inf), 2, "haut")
           o49 <- engine_p_mc(c(1:49, rep(NA, 50)), 20, "deux")
           o49c <- engine_p_mc(rep(2, 49), 2, "deux")
           o50 <- engine_p_mc(c(1:50, rep(NaN, 49)), 20, "deux")
           o0 <- engine_p_mc(rep(NA_real_, 99), 2, "haut")
           B_MIN_DEGENERESCENCE == 50 &&
             grepl("B_MIN_DEGENERESCENCE = 50", MOTIF_MC_REPLIC_INSUFFISANTES, fixed = TRUE) &&
             insuff(o1, 1) && insuff(o49, 49) && insuff(o49c, 49) &&
             is.na(o50$motif) && identical(o50$B_effectif, 50) &&
             proche(o50$p_mc, 2 * 21 / 51) && proche(o50$granularite, 2 / 51) &&
             identical(o0$motif, MOTIF_MC_AUCUNE_REPLIC) && identical(o0$B_effectif, 0)
         })
verifier("engine_p_mc : loi ponctuelle, observee hors de l'atome -> motif atome hors obs, p_mc NA",
         {
           o <- engine_p_mc(rep(2, 50), 3, "haut")
           identical(o$motif, MOTIF_MC_ATOME_HORS_OBS) && is.na(o$p_mc) && is.na(o$err_mc)
         })
# run_engine() refuse B < B_MIN_USAGE = 99 (constat C1 de la revue finale
# d'E1) : la branche "sous B_MIN_DEGENERESCENCE" est exercee par
# usp_bootstrap() et usp_tests() appeles directement, non bornes.
# B = 2 (#128) : toutes les p_mc absentes, motif replications insuffisantes ;
# Smirnov et Cox-Stuart gardent leur p exacte (motif sans degenerescence) ;
# une ligne sans p exacte avec p asymptotique se replie, nommee (RESET) ;
# une ligne sans aucune p reste un test INFO avec la phrase de #128 (sup-F).
verifier("usp_bootstrap(B = 2) + usp_tests() : motif replications insuffisantes ; p exactes gardees, repli nomme, test sans p-value",
         {
           b2 <- usp_bootstrap(fit, B = 2, seed = 20260831)
           t2 <- usp_tests(fit, b2, methode = "premium")
           sm <- ligne(t2, "Egalite des lois petits vs gros volumes (2 ech.)")
           cs <- ligne(t2, "Tendance par signes du ratio S/P")
           rs <- ligne(t2, "RESET (forme fonctionnelle)")
           sf <- ligne(t2, "Rupture de niveau (sup-F)")
           identical(sm$nature_p, "exacte") && is.finite(sm$p_retenue) &&
             is.finite(cs$p_exacte) && identical(cs$type, "diagnostic") &&
             all(b2$motif_mc == MOTIF_MC_REPLIC_INSUFFISANTES) && all(is.na(b2$p_mc)) &&
             identical(rs$nature_p, paste0("asymptotique (Monte-Carlo indisponible : ",
                                           MOTIF_MC_REPLIC_INSUFFISANTES, ")")) &&
             identical(sf$type, "test") && identical(sf$verdict, "INFO") && is.na(sf$p_retenue) &&
             startsWith(sf$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_REPLIC_INSUFFISANTES,
                                          " ; aucune p-value disponible sur ces donnees : aucun verdict (ADR 0001)."))
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
sim_synth <- matrix(rep(1:99, 4), 99, 4, dimnames = list(NULL, c("A", "B", "C", "D")))
obs_synth <- c(A = 70, B = 70, C = NA_real_, D = NA_real_)
mc_synth <- .mc_p_values(sim_synth, obs_synth, cat_synth, e = list(v = 70))
verifier(".mc_p_values : degenere(e) TRUE -> p_mc NA, motif de la condition du catalogue ; FALSE -> inchange",
         is.na(mc_synth$p_mc[["A"]]) && is.na(mc_synth$err_mc[["A"]]) &&
         identical(mc_synth$motif_mc[["A"]], MOTIF_MC_CONDITION) &&
         proche(mc_synth$p_mc[["B"]], 0.31) && is.na(mc_synth$motif_mc[["B"]]))
verifier(".mc_p_values : non_definie remplace le motif generique ; sans elle, motif generique",
         identical(mc_synth$motif_mc[["C"]], "motif du catalogue") &&
         identical(mc_synth$motif_mc[["D"]], MOTIF_MC_OBS_NON_FINIE))
verifier(".mc_p_values : sans contexte, conditions du catalogue non evaluees (compatibilite)",
         proche(.mc_p_values(sim_synth, obs_synth, cat_synth)$p_mc[["A"]], 0.31))
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
             r <- reg_motif(m); r$add("F", "t", "ref", fonction = "usp_tests", p_ex = 0.5, p_as = 0.3, mc_nom = "S")
             l <- r$lignes()[[1]]
             identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
               is.na(l$p_retenue) && startsWith(l$detail, m)
           }, logical(1))
           all(ok)
         })
# Cas construit (#126, point 1) : 60 simulations toutes egales a 2, observee
# 3 ; le motif est produit par engine_p_mc() via .mc_p_values(), puis lu par
# add(). Le detail porte le motif, la phrase de DETAIL_MC_ATOME_HORS_OBS et le
# detail de l'appelant, sans l'ecart observee - atome (grandeur de bruit).
verifier("add() : loi simulee ponctuelle hors de l'atome -> diagnostic INFO, detail complete (#126)",
         {
           cat_at <- list(S = .mc_entree(function(e) e$v, "haut"))
           mc_at <- .mc_p_values(matrix(2, 60, 1, dimnames = list(NULL, "S")), c(S = 3),
                                 cat_at, e = list(v = 3))
           r <- engine_registre_tests(mc_at, cat_at, 0.10, "Monte-Carlo")
           r$add("F", "t", "ref", fonction = "usp_tests", p_ex = 0.5, mc_nom = "S", detail = "detail appelant")
           l <- r$lignes()[[1]]
           attendu <- paste0(MOTIF_MC_ATOME_HORS_OBS, " : aucune p-value retenue (ADR 0001). ",
                             DETAIL_MC_ATOME_HORS_OBS, " detail appelant")
           identical(mc_at$motif_mc[["S"]], MOTIF_MC_ATOME_HORS_OBS) &&
             identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
             is.na(l$p_retenue) && identical(l$detail, attendu) &&
             grepl(paste("Aucune simulation sous le modele ajuste ne reproduit la valeur",
                         "observee : incompatibilite du modele avec les donnees ou asymetrie",
                         "de calcul entre observe et simule, a examiner avant toute conclusion."),
                   l$detail, fixed = TRUE) &&
             !grepl("(loi simulee ponctuelle)", l$detail, fixed = TRUE)
         })
# Controle negatif (#126, constat C2 d'audit) : les autres motifs de
# degenerescence et une ligne sans motif ne recoivent pas la phrase ; detail
# inchange pour eux (prefixe du motif puis detail de l'appelant).
verifier("add() : dispersion nulle, condition du catalogue, ligne sans motif -> detail sans la phrase de l'atome hors obs",
         {
           ok <- vapply(c(MOTIF_MC_DISPERSION_NULLE, MOTIF_MC_CONDITION), function(m) {
             r <- reg_motif(m); r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", detail = "d")
             identical(r$lignes()[[1]]$detail,
                       paste0(m, " : aucune p-value retenue (ADR 0001). d"))
           }, logical(1))
           r0 <- engine_registre_tests(list(p_mc = c(S = 0.4), err_mc = c(S = 0.01),
                                            motif_mc = c(S = NA_character_)),
                                       list(S = .mc_entree(function(e) 1, "haut")),
                                       0.10, "Monte-Carlo")
           r0$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", detail = "d")
           l0 <- r0$lignes()[[1]]
           all(ok) && identical(l0$detail, "d") && identical(l0$type, "test") &&
             !grepl(DETAIL_MC_ATOME_HORS_OBS, l0$detail, fixed = TRUE) &&
             identical(.complement_motif_mc(NA_character_), character(0))
         })
verifier("add() : statistique observee non finie sans p exacte -> non applicable avec le motif",
         {
           r <- reg_motif(MOTIF_MC_OBS_NON_FINIE); r$add("F", "t", "ref", fonction = "usp_tests", p_as = 0.3, mc_nom = "S")
           l <- r$lignes()[[1]]
           identical(l$type, "non applicable") && identical(l$verdict, "INFO") &&
             startsWith(l$detail, MOTIF_MC_OBS_NON_FINIE)
         })
verifier("add() : aucune replication finie avec p asymptotique -> repli NOMME",
         {
           r <- reg_motif(MOTIF_MC_AUCUNE_REPLIC); r$add("F", "t", "ref", fonction = "usp_tests", p_as = 0.3, mc_nom = "S")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$p_retenue, 0.3) &&
             identical(l$nature_p, paste0("asymptotique (Monte-Carlo indisponible : ",
                                          MOTIF_MC_AUCUNE_REPLIC, ")"))
         })
verifier("add() : repli_asymptotique = FALSE, aucune replication finie -> diagnostic, p asymptotique conservee non retenue",
         {
           r <- reg_motif(MOTIF_MC_AUCUNE_REPLIC)
           r$add("F", "t", "ref", fonction = "usp_tests", p_as = 0.3, mc_nom = "S", repli_asymptotique = FALSE,
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
           r$add("F", "t", "ref", fonction = "usp_tests", p_ex = 0.5, mc_nom = "S")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$nature_p, "exacte") && identical(l$p_retenue, 0.5)
         })
verifier("add() : bootstrap sans champ motif_mc (objet anterieur) -> comportement inchange",
         {
           r <- engine_registre_tests(list(p_mc = c(S = NA_real_), err_mc = c(S = NA_real_)),
                                      list(S = .mc_entree(function(e) 1, "haut")), 0.10, "MC")
           r$add("F", "t", "ref", fonction = "usp_tests", p_as = 0.3, mc_nom = "S")
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
           is.na(l$p_exacte) && identical(l$p_asymptotique, test_intercept(x, y, fit$pi)$p) &&
             identical(l$p_retenue, 0.5) && identical(l$nature_p, "Monte-Carlo (bootstrap parametrique)")
         })
verifier("Constante sans p Monte-Carlo (motif aucune replication finie) : INFO, p_retenue NA, p_asymptotique conservee",
         {
           t0 <- usp_tests(fit, boot_fictif(fit, motif = c(Intercept = MOTIF_MC_AUCUNE_REPLIC)),
                           methode = "premium")
           l <- ligne(t0, "Nullite de la constante (proportionnalite stricte)")
           identical(l$type, "diagnostic") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             identical(l$p_asymptotique, test_intercept(x, y, fit$pi)$p) && grepl("non retenue", l$loi, fixed = TRUE)
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
# #215 (decision P3 du mainteneur du 07/10/2026) : modele auxiliaire pondere,
# poids estimes ; p exacte NA dans les deux branches de marge, p rangee dans
# p_asymptotique et retenue hors hierarchie.
verifier("TOST (R5, #215) : nature 'modele auxiliaire pondere' dans les deux branches de marge, p_exacte NA, p retenue = p_asymptotique",
         {
           a <- ligne(tt, "Equivalence de la constante a zero (TOST)")
           t2 <- usp_tests(fit, boot_fictif(fit), delta_equiv = 5, methode = "premium")
           b <- ligne(t2, "Equivalence de la constante a zero (TOST)")
           identical(a$nature_p, paste("sous le modele auxiliaire pondere : loi de Student (poids estimes),",
                                       "marge estimee sur les donnees")) &&
             identical(b$nature_p, paste("sous le modele auxiliaire pondere : loi de Student (poids estimes),",
                                         "marge fixee a priori")) &&
             is.na(a$p_exacte) && is.na(b$p_exacte) &&
             is.finite(a$p_asymptotique) && identical(a$p_retenue, a$p_asymptotique) &&
             is.finite(b$p_asymptotique) && identical(b$p_retenue, b$p_asymptotique)
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
pente <- "Test de Pitman sur la pente (lien positif pertes / volume)"
fisher <- "Test de Fisher (significativite globale)"
NAT_PITMAN <- "exacte par permutation (H0 : y independant de x, hors modele reglementaire)"
NAT_PITMAN_MC <- "Monte-Carlo (permutations aleatoires ; H0 : y independant de x)"
verifier("usp_identifiabilite_pente(unilateral = TRUE) : puissance = P(t > t(1-alpha, T-2) | ncp) ; J1 0,6461 (#169)",
         {
           ip <- usp_identifiabilite_pente(x, fit$beta, fit$sigma, 0.10, unilateral = TRUE)
           lam <- sqrt(7) * stats::sd(x) / mean(x) * fit$beta / fit$sigma
           proche(ip$puissance, stats::pt(stats::qt(0.90, 6), 6, ncp = lam, lower.tail = FALSE),
                  rel = 1e-12) && round(ip$puissance, 4) == 0.6461
         })
verifier("Pente (R4 unilaterale) et Fisher : CV(x) = 3 % -> pente diagnostic ; CV(x) = 30 % et J1 -> pente test ; Fisher toujours diagnostic (#169)",
         {
           identical(ligne(t03, pente)$type, "diagnostic") &&
             identical(ligne(t30, pente)$type, "test") && identical(ligne(tt, pente)$type, "test") &&
             all(vapply(list(tt, t03, t30), function(t)
               identical(ligne(t, fisher)$type, "diagnostic") &&
                 identical(ligne(t, fisher)$verdict, "INFO") && is.na(ligne(t, fisher)$p_retenue) &&
                 is.na(ligne(t, fisher)$nature_p) && is.finite(ligne(t, fisher)$p_asymptotique) &&
                 grepl("redondante avec le test de Pitman (F = t^2)", ligne(t, fisher)$detail, fixed = TRUE),
               logical(1)))
         })
verifier("Pente (J1) : p exacte 4462/40320, nature de la permutation, p de Student unilaterale restituee non retenue, ALERTE, lambda et puissance rappeles (#169)",
         {
           l <- ligne(tt, pente); d <- ligne(t03, pente)
           identical(l$p_exacte, 4462 / 40320) && identical(l$p_retenue, l$p_exacte) &&
             identical(l$nature_p, NAT_PITMAN) && identical(l$verdict, "ALERTE") &&
             identical(l$fonction, "usp_permutation_pente") && identical(l$p_min, 1 / 40320) &&
             proche(l$p_asymptotique, stats::pt(l$stat, 6, lower.tail = FALSE), rel = 1e-12) &&
             grepl("Pente identifiable", l$detail, fixed = TRUE) && grepl("lambda", l$detail, fixed = TRUE) &&
             identical(d$type, "diagnostic") && grepl("PENTE NON IDENTIFIABLE", d$detail, fixed = TRUE)
         })
# Jeu (xi, yi) de test_controles_numeriques.R (J2, delta interieur).
xi <- c(50, 80, 120, 200, 300, 150, 90, 60)
yi <- c(29.92, 56.9, 101.25, 123.06, 207.23, 105.91, 68.59, 40.05)
f_i <- usp_ajuster(xi, yi)
t_i <- usp_tests(f_i, boot_fictif(f_i), methode = "premium")
verifier("Pente et Fisher (#169) : jeu J2, p = p_min = 1/40320, OK ; Fisher diagnostic, loi F(1,6), p F bilaterale restituee",
         {
           m <- ligne(t_i, pente); f <- ligne(t_i, fisher)
           identical(m$type, "test") && identical(m$p_exacte, 1 / 40320) && identical(m$p_min, 1 / 40320) &&
             identical(m$verdict, "OK") && identical(m$nature_p, NAT_PITMAN) &&
             identical(f$type, "diagnostic") && grepl("^F\\(1,6\\)", f$loi) &&
             proche(f$p_asymptotique, stats::pf(f$stat, 1, 6, lower.tail = FALSE), rel = 1e-10)
         })
## --- 4 bis. Test de Pitman : usp_permutation_pente() (#169) ------------------
# Enumeration independante : boucle naive sur les T! appariements (stats::cor).
naive_perm <- function(x, y, uni) {
  P <- as.matrix(expand.grid(rep(list(seq_along(x)), length(x))))
  P <- P[apply(P, 1, function(v) !anyDuplicated(v)), , drop = FALSE]
  r0 <- stats::cor(x, y); r <- apply(P, 1, function(p) stats::cor(x, y[p]))
  (if (uni) sum(r >= r0 - 1e-12) else sum(abs(r) >= abs(r0) - 1e-12)) / nrow(P)
}
verifier("usp_permutation_pente : enumeration = boucle naive (T = 4, 5 ; unilateral et bilateral ; ex aequo compris)",
         {
           ok <- TRUE
           for (T_ in 4:5) for (i in 1:12) {
             xs <- 50 + 30 * ((i * seq_len(T_) * 7) %% 11); ys <- round(xs * (1 + ((i + seq_len(T_)) %% 5) / 7) / 20)
             if (stats::sd(xs) == 0 || stats::sd(ys) == 0) next
             for (u in c(TRUE, FALSE))
               ok <- ok && proche(usp_permutation_pente(xs, ys, unilateral = u)$p, naive_perm(xs, ys, u), rel = 1e-12)
           }
           ok
         })
verifier("usp_permutation_pente : J1 4462/40320 unilateral, 8515/40320 bilateral ; p >= 1/T! ; invariances d'echelle et de translation",
         {
           u <- usp_permutation_pente(x, y); b <- usp_permutation_pente(x, y, unilateral = FALSE)
           identical(u$p, 4462 / 40320) && identical(b$p, 8515 / 40320) && u$p >= 1 / 40320 &&
             identical(u$methode, "enumeration") && identical(u$n_perm, 40320) &&
             all(vapply(list(usp_permutation_pente(x, 1e3 * y), usp_permutation_pente(x, 1e-3 * y),
                             usp_permutation_pente(x, y + 50), usp_permutation_pente(1e3 * x, y)),
                        function(v) identical(v$p, u$p), logical(1)))
         })
verifier("usp_permutation_pente : p_min avec ex aequo, formule (T >= 10) = enumeration (T = 5) ; y = (1,1,1,1,2) -> 0,2",
         {
           ok <- TRUE
           for (i in 1:40) {
             xs <- 10 * (1 + (i * c(1, 3, 5, 7, 9)) %% 4); ys <- 1 + (i * c(2, 3, 5, 7, 11)) %% 3
             if (stats::sd(xs) == 0 || stats::sd(ys) == 0) next
             xa <- engine_aplatir_ex_aequo(xs, plancher = 0); o <- order(xa)
             f <- .usp_nb_appariements(xa[o], sort(engine_aplatir_ex_aequo(ys, plancher = 0))) / 120
             ok <- ok && proche(usp_permutation_pente(xs, ys)$p_min, f, rel = 1e-12)
           }
           ok && proche(usp_permutation_pente(c(10, 20, 30, 40, 50), c(1, 1, 1, 1, 2))$p_min, 0.2, rel = 1e-12)
         })
verifier("usp_permutation_pente : T = 9 enumeration (362880) ; T = 10 et 12 permutations aleatoires reproductibles, etat RNG restaure, p sur la grille (1+k)/(B+1)",
         {
           x9 <- 100 + 10 * (1:9) + (1:9)^2; y9 <- x9 * (1 + ((1:9) %% 4) / 10)
           p9 <- usp_permutation_pente(x9, y9)
           ok <- identical(p9$methode, "enumeration") && identical(p9$n_perm, 362880)
           for (T_ in c(10, 12)) {
             xs <- 100 + 7 * seq_len(T_) + (seq_len(T_) %% 3) * 5; ys <- xs * (1 + (seq_len(T_) %% 4) / 10)
             set.seed(7); s0 <- .Random.seed; k0 <- RNGkind()
             a <- usp_permutation_pente(xs, ys, B = 199, seed = 3); b <- usp_permutation_pente(xs, ys, B = 199, seed = 3)
             ok <- ok && identical(a, b) && identical(s0, .Random.seed) && identical(k0, RNGkind()) &&
               identical(a$methode, "aleatoire") && identical(a$B, 199) &&
               proche(a$p * 200, round(a$p * 200), rel = 1e-12) && a$p >= 1 / 200 &&
               proche(a$err_mc, sqrt(a$p * (1 - a$p) / 199), rel = 1e-12)
           }
           ok
         })
verifier("Pente T = 10 : nature Monte-Carlo des permutations (p_mc_ext), p exacte NA ; B <= 9 -> OK inatteignable dans le detail (#169)",
         {
           xs <- 100 + 7 * (1:10) + ((1:10) %% 3) * 5; ys <- xs * (1 + ((1:10) %% 4) / 10)
           f10 <- usp_ajuster(xs, ys)
           l <- ligne(usp_tests(f10, boot_fictif(f10), methode = "premium",
                                permutation_pente = usp_permutation_pente(xs, ys, B = 199)), pente)
           l9 <- ligne(usp_tests(f10, boot_fictif(f10), methode = "premium",
                                 permutation_pente = usp_permutation_pente(xs, ys, B = 9)), pente)
           identical(l$nature_p, NAT_PITMAN_MC) && is.na(l$p_exacte) && identical(l$p_retenue, l$p_mc) &&
             is.finite(l$err_mc) && !grepl("OK inatteignable", l$detail, fixed = TRUE) &&
             grepl("OK inatteignable", l9$detail, fixed = TRUE) && !identical(l9$verdict, "OK")
         })
verifier("Garde-fou (ADR 0002, point 4) : p de permutation absente sur une ligne applicable -> erreur, jamais la p de Student sous la nature de la permutation",
         {
           pp <- usp_permutation_pente(x, y); pp$p <- NA_real_
           e <- tryCatch(usp_tests(fit, boot_fictif(fit), methode = "premium", permutation_pente = pp),
                         error = function(e) conditionMessage(e))
           is.character(e) && grepl("repli sur la p de Student interdit", e, fixed = TRUE)
         })
verifier("Garde-fou de sens : permutation_pente bilaterale passee a usp_tests() -> erreur (SENS_PITMAN_PENTE)",
         {
           e <- tryCatch(usp_tests(fit, boot_fictif(fit), methode = "premium",
                                   permutation_pente = usp_permutation_pente(x, y, unilateral = FALSE)),
                         error = function(e) conditionMessage(e))
           is.character(e) &&
             grepl("sens de la p de permutation de la pente different de SENS_PITMAN_PENTE", e, fixed = TRUE)
         })
# Sens du test (SENS_PITMAN_PENTE, seule definition, #169) : verrou sur
# "unilateral" (decision du mainteneur du 06/10/2026) ; p bilaterale de
# permutation restituee pour information dans le detail (libelle neutre :
# la p unilaterale n'est pas toujours retenue, R4 et R1).
verifier("SENS_PITMAN_PENTE : verrou unilateral (toute autre valeur refusee) ; p bilaterale J1 8515/40320 = 0,2112 dans le detail, libelle neutre, p de Student unilaterale",
         {
           e <- tryCatch(.pitman_unilateral("bilateral"), error = function(e) conditionMessage(e))
           l <- ligne(tt, pente); pp <- usp_permutation_pente(x, y)
           identical(SENS_PITMAN_PENTE, "unilateral") && isTRUE(.pitman_unilateral()) &&
             is.character(e) && grepl("n'admet que", e, fixed = TRUE) &&
             !"SENS_PITMAN_PENTE" %in% names(formals(run_engine)) &&
             identical(pp$p_bilateral, 8515 / 40320) &&
             identical(usp_permutation_pente(x, y, unilateral = FALSE)$p, pp$p_bilateral) &&
             grepl(paste("p de permutation unilaterale (sens du test) ; p bilaterale de permutation (|r|),",
                         "pour information, non retenue = 0.2112."), l$detail, fixed = TRUE) &&
             !grepl("unilaterale retenue", l$detail, fixed = TRUE) &&
             grepl("p de Student unilaterale (t(T-2)", l$detail, fixed = TRUE)
         })
# run_engine() a T = 10 (#169, constat C1 d'audit) : la ligne recoit la
# permutation calculee avec le B et la graine de l'execution. Donnees choisies
# pour que p depende de B et de la graine (p = 0,16 a B = 199, graine 11 ;
# 0,146 a B = 999 ; 0,135 a la graine par defaut).
x10p <- 100 + 7 * (1:10) + ((1:10) %% 3) * 5
y10p <- c(80, 95, 70, 110, 90, 85, 120, 75, 100, 105)
res10p <- run_engine(xt = x10p, yt = y10p, methode = "premium", segment = 1, annexe = "II",
                     nature_donnees = "brutes", B = 199, seed = 11)
verifier("run_engine(T = 10, B = 199, seed = 11) : p_mc de la pente = usp_permutation_pente(B = 199, seed = 11)$p ; metadata$permutation_pente (aleatoire, 199, p_bilateral)",
         {
           pp <- usp_permutation_pente(x10p, y10p, B = 199, seed = 11)
           l <- ligne(res10p$tests, pente); m <- res10p$metadata$permutation_pente
           isTRUE(res10p$ok) && identical(l$p_mc, pp$p) && identical(l$p_retenue, pp$p) &&
             identical(l$err_mc, pp$err_mc) && is.na(l$p_exacte) &&
             !identical(pp$p, usp_permutation_pente(x10p, y10p)$p) &&
             identical(m, list(methode = "aleatoire", B = 199, p_bilateral = pp$p_bilateral)) &&
             grepl("pour information, non retenue : non imprimee (tirages aleatoires).", l$detail, fixed = TRUE)
         })
verifier("run_engine(T = 8) : metadata$permutation_pente = enumeration, B NA, p_bilateral = celle du detail ; volumes constants -> non calcule",
         {
           r8 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                            nature_donnees = "brutes", B = B_MIN_USAGE, seed = 20260831)
           rc <- run_engine(xt = rep(100, 8), yt = y, methode = "premium", segment = 1, annexe = "II",
                            nature_donnees = "brutes", B = B_MIN_USAGE, seed = 20260831)
           identical(r8$metadata$permutation_pente,
                     list(methode = "enumeration", B = NA_real_, p_bilateral = 8515 / 40320)) &&
             identical(rc$metadata$permutation_pente,
                       list(methode = "non calcule", B = NA_real_, p_bilateral = NA_real_))
         })
verifier("Pente : y = (1,1,1,1,2) a T = 5 -> p_min = 0,2 >= alpha, test inoperant (R1)",
         {
           x5 <- c(10, 20, 30, 40, 50); y5 <- c(1, 1, 1, 1, 2)
           f5 <- usp_ajuster(x5, y5)
           l <- ligne(usp_tests(f5, boot_fictif(f5), methode = "premium"), pente)
           identical(l$type, "diagnostic") && isTRUE(l$inoperant) && proche(l$p_min, 0.2, rel = 1e-12) &&
             identical(l$verdict, "INFO") && startsWith(l$detail, "TEST INOPERANT")
         })
# Reprise de la revue finale (#169, decisions du mainteneur du 07/10/2026).
# avec_avert() rend la valeur et les avertissements emis (verifier() les
# neutralise sans les compter).
avec_avert <- function(expr) {
  w <- character(0)
  v <- withCallingHandlers(expr, warning = function(e) {
    w <<- c(w, conditionMessage(e)); invokeRestart("muffleWarning")
  })
  list(v = v, w = w)
}
verifier("usp_permutation_pente : y = 0,5 x (|r_obs| > 1 a l'arrondi) -> t = Inf, sans NaN ni avertissement ; p = 1/8!",
         {
           a <- avec_avert(usp_permutation_pente(seq(100, 170, 10), 0.5 * seq(100, 170, 10)))
           length(a$w) == 0L && identical(a$v$t, Inf) && identical(a$v$p, 1 / 40320) &&
             identical(a$v$p_min, 1 / 40320)
         })
verifier("usp_permutation_pente : p_min a T = 200 (factorial() deborde) fini dans ]0, 1], sans avertissement, = 1/C(200,100) et 2/C(200,100) en bilateral",
         {
           x200 <- rep(c(100, 150), each = 100); y200 <- rep(c(50, 80, 60, 70), 50)
           u <- avec_avert(usp_permutation_pente(x200, y200, B = 9))
           b <- avec_avert(usp_permutation_pente(x200, y200, B = 9, unilateral = FALSE))
           length(u$w) == 0L && length(b$w) == 0L &&
             is.finite(u$v$p_min) && u$v$p_min > 0 && u$v$p_min <= 1 &&
             isTRUE(proche(u$v$p_min, 1 / choose(200, 100), rel = 1e-10)) &&
             isTRUE(proche(b$v$p_min, 2 / choose(200, 100), rel = 1e-10))
         })
verifier("usp_permutation_pente : p_min a T <= 170 = nombre arrondi / factorial(T) au bit pres (9!/10! = 0,1 exactement ; T = 170)",
         {
           x10 <- c(rep(100, 9), 200); y10 <- c(50, 55, 60, 52, 58, 62, 54, 57, 61, 120)
           x170 <- rep(c(100, 150), each = 85); y170 <- rep(c(50, 80), 85)
           xa <- engine_aplatir_ex_aequo(x170, plancher = 0); o <- order(xa)
           n170 <- .usp_nb_appariements(xa[o], sort(engine_aplatir_ex_aequo(y170, plancher = 0)))
           identical(usp_permutation_pente(x10, y10, B = 9)$p_min, 0.1) &&
             identical(usp_permutation_pente(x170, y170, B = 9)$p_min, n170 / factorial(170))
         })
verifier("Pente et Fisher : ajustement exact (x = 1:8, y = 2 x, t = F = Inf) -> non applicables, motifs 'statistique t non finie' et 'statistique F non finie' seuls",
         {
           f_ex <- usp_ajuster(1:8, 2 * (1:8))
           t_ex <- usp_tests(f_ex, boot_fictif(f_ex), methode = "premium")
           l <- ligne(t_ex, pente); fi <- ligne(t_ex, fisher)
           identical(l$type, "non applicable") && !is.finite(l$stat) && is.na(l$p_retenue) &&
             identical(l$detail, paste("statistique t non finie (erreur-type de la pente de la",
                                       "regression de y sur x nulle : ajustement exact, ou non",
                                       "calculable) : test non applicable")) &&
             identical(fi$type, "non applicable") && !is.finite(fi$stat) && is.na(fi$p_retenue) &&
             identical(fi$detail, paste("statistique F non finie (somme des carres residuelle de la",
                                        "regression de y sur x nulle : ajustement exact, ou non",
                                        "calculable) : non applicable"))
         })
verifier("Pente T = 10, B = 9 : pas de mention 'OK inatteignable' sous R4 (diagnostic) ni sous R1 (p_min = 0,1 >= alpha)",
         {
           xs <- 100 + 7 * (1:10) + ((1:10) %% 3) * 5; ys <- xs * (1 + ((1:10) %% 4) / 10)
           xc <- mean(xs) * (1 + 0.03 * as.numeric(scale(xs))); yc <- xc * ys / xs
           f4 <- usp_ajuster(xc, yc)
           l4 <- ligne(usp_tests(f4, boot_fictif(f4), methode = "premium",
                                 permutation_pente = usp_permutation_pente(xc, yc, B = 9)), pente)
           x1 <- c(rep(100, 9), 200); y1 <- c(50, 55, 60, 52, 58, 62, 54, 57, 61, 120)
           f1 <- usp_ajuster(x1, y1)
           l1 <- ligne(usp_tests(f1, boot_fictif(f1), methode = "premium",
                                 permutation_pente = usp_permutation_pente(x1, y1, B = 9)), pente)
           identical(l4$type, "diagnostic") && !isTRUE(l4$inoperant) &&
             grepl("PENTE NON IDENTIFIABLE", l4$detail, fixed = TRUE) &&
             !grepl("OK inatteignable", l4$detail, fixed = TRUE) &&
             identical(l1$type, "diagnostic") && isTRUE(l1$inoperant) &&
             startsWith(l1$detail, "TEST INOPERANT") &&
             !grepl("OK inatteignable", l1$detail, fixed = TRUE)
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

## --- 4 bis. #128 : B effectif insuffisant, test sans p-value, plancher -------
# Bootstrap construit par .mc_p_values() sur B_eff simulations finies
# 1..B_eff (et 99 - B_eff non finies), observee au milieu : motif produit par
# engine_p_mc(), lu par add().
boot_beff <- function(b_eff, obs = 0.5 * (b_eff + 1), queue = "haut") {
  cat_q <- list(S = .mc_entree(function(e) e$v, queue))
  sim <- matrix(c(seq_len(b_eff), rep(NA_real_, max(0, 99 - b_eff))), ncol = 1,
                dimnames = list(NULL, "S"))
  mc <- .mc_p_values(sim, c(S = obs), cat_q, e = list(v = obs))
  list(p_mc = mc$p_mc, err_mc = mc$err_mc, motif_mc = mc$motif_mc,
       B_effectif = mc$B_effectif, granularite_stat = mc$granularite)
}
reg_beff <- function(b_eff, alpha = 0.10, ...) {
  b <- boot_beff(b_eff, ...)
  engine_registre_tests(b, list(S = .mc_entree(function(e) 1, "haut")), alpha, "Monte-Carlo")
}
verifier("add() : B_eff = 1 et 49, p asymptotique -> repli nomme 'Monte-Carlo indisponible : replications finies insuffisantes'",
         all(vapply(c(1, 49), function(b) {
           r <- reg_beff(b); r$add("F", "t", "ref", fonction = "usp_tests", p_as = 0.3, mc_nom = "S")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$verdict, "OK") && identical(l$p_retenue, 0.3) &&
             is.na(l$p_mc) &&
             identical(l$nature_p, paste0("asymptotique (Monte-Carlo indisponible : ",
                                          MOTIF_MC_REPLIC_INSUFFISANTES, ")"))
         }, logical(1))))
verifier("add() : B_eff = 1 et 49, aucune p -> test INFO, sens et p_retenue inchanges, motif puis phrase 'aucune p-value disponible'",
         all(vapply(c(1, 49), function(b) {
           r <- reg_beff(b); r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", detail = "d")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             is.na(l$nature_p) && identical(l$sens, "ne pas rejeter") &&
             identical(l$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_REPLIC_INSUFFISANTES,
                                        " ; aucune p-value disponible sur ces donnees : aucun verdict",
                                        " (ADR 0001). d"))
         }, logical(1))))
verifier("add() : B_eff = 50 -> p Monte-Carlo retenue, aucun motif ni phrase de #128",
         {
           r <- reg_beff(50); r$add("F", "t", "ref", fonction = "usp_tests", p_as = 0.3, mc_nom = "S", detail = "d")
           l <- r$lignes()[[1]]
           identical(l$nature_p, "Monte-Carlo") && proche(l$p_retenue, 26 / 51) && identical(l$detail, "d")
         })
verifier("add() : B_eff = 0, aucune p -> motif 'aucune replication finie' dans le detail (residu C1)",
         {
           r <- reg_beff(0); r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$verdict, "INFO") &&
             identical(l$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_AUCUNE_REPLIC,
                                        " ; aucune p-value disponible sur ces donnees : aucun verdict",
                                        " (ADR 0001)."))
         })
verifier("add() : aucune p, motif deja dans le detail -> motif non repete ; alpha/2 <= p_min < alpha -> sans 'ECHEC inatteignable'",
         {
           r <- reg_motif("statistique observee non definie : ex aequo")
           r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 0.0625, effectifs = "m = 5",
                 detail = "p_mc absente (statistique observee non definie : ex aequo)")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$verdict, "INFO") &&
             identical(l$detail, paste("aucune p-value disponible sur ces donnees : aucun verdict (ADR 0001).",
                                       "p_mc absente (statistique observee non definie : ex aequo)")) &&
             !grepl("inatteignable", l$detail, fixed = TRUE)
         })
verifier("add() : aucune p et p_min >= alpha -> TEST INOPERANT inchange, sans phrase de #128",
         {
           r <- reg_fictif(); r$add("F", "t", "ref", fonction = "usp_tests", p_min = 0.125, detail = "d")
           l <- r$lignes()[[1]]
           identical(l$type, "diagnostic") && startsWith(l$detail, "TEST INOPERANT") &&
             !grepl("aucune p-value disponible", l$detail, fixed = TRUE)
         })
verifier(".mc_p_values : B_eff < 50 et condition degenere(e) vraie -> motif de la condition (pas de repli)",
         {
           cat_d <- list(S = .mc_entree(function(e) e$v, "haut", degenere = function(e) TRUE))
           mc <- .mc_p_values(matrix(1:9, ncol = 1, dimnames = list(NULL, "S")), c(S = 5), cat_d,
                              e = list(v = 5))
           identical(mc$motif_mc[["S"]], MOTIF_MC_CONDITION) && is.na(mc$p_mc[["S"]])
         })
# B_eff = 0 (#128, question 1 de coder, avis d'actuary) : la condition
# degenere l'emporte aussi sur MOTIF_MC_AUCUNE_REPLIC ; la ligne est un
# diagnostic sans p retenue, meme avec p asymptotique (aucun repli). Une
# statistique observee non finie garde MOTIF_MC_OBS_NON_FINIE.
verifier(".mc_p_values + add() : B_eff = 0 et condition degenere(e) vraie -> diagnostic INFO sans p, aucun repli ; observee non finie inchangee",
         {
           cat_d <- list(S = .mc_entree(function(e) e$v, "haut", degenere = function(e) TRUE))
           sim0 <- matrix(NA_real_, 99, 1, dimnames = list(NULL, "S"))
           mc <- .mc_p_values(sim0, c(S = 5), cat_d, e = list(v = 5))
           mc_nf <- .mc_p_values(sim0, c(S = NA_real_), cat_d, e = list(v = NA_real_))
           r <- engine_registre_tests(list(p_mc = mc$p_mc, err_mc = mc$err_mc, motif_mc = mc$motif_mc,
                                           B_effectif = mc$B_effectif, granularite_stat = mc$granularite),
                                      cat_d, 0.10, "Monte-Carlo")
           r$add("F", "t", "ref", fonction = "usp_tests", p_as = 0.3, mc_nom = "S")
           l <- r$lignes()[[1]]
           identical(mc$motif_mc[["S"]], MOTIF_MC_CONDITION) && identical(mc$B_effectif[["S"]], 0) &&
             identical(mc_nf$motif_mc[["S"]], MOTIF_MC_OBS_NON_FINIE) &&
             identical(l$type, "diagnostic") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             is.na(l$nature_p) && identical(l$p_asymptotique, 0.3) && startsWith(l$detail, MOTIF_MC_CONDITION)
         })
# Plancher Monte-Carlo (#128, point d) : g = granularite_stat. Bilateral a
# alpha = 0,05 : B_eff = 79 -> g = 2/80 = 0,025 >= alpha/2 (mention) ;
# B_eff = 80 -> g = 2/81 < alpha/2 (aucune mention).
verifier("add() : plancher bilateral, alpha = 0,05 : B_eff = 79 -> mention 'ECHEC inatteignable' ; 80 -> aucune",
         {
           r79 <- reg_beff(79, alpha = 0.05, queue = "deux"); r79$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", detail = "d")
           r80 <- reg_beff(80, alpha = 0.05, queue = "deux"); r80$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", detail = "d")
           l79 <- r79$lignes()[[1]]; l80 <- r80$lignes()[[1]]
           identical(l79$nature_p, "Monte-Carlo") && identical(l79$verdict, "OK") &&
             identical(l79$detail, "d ; plancher Monte-Carlo >= alpha/2 = 0.025 : ECHEC inatteignable") &&
             identical(l80$detail, "d")
         })
verifier("add() : plancher, sens 'rejeter' : g = 1/100 >= alpha = 0,01 -> 'OK inatteignable' ; g = 1/101 -> aucune",
         {
           r1 <- reg_beff(99, alpha = 0.01); r1$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", sens = "rejeter")
           r2 <- reg_beff(100, alpha = 0.01); r2$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", sens = "rejeter")
           identical(r1$lignes()[[1]]$detail,
                     "plancher Monte-Carlo >= alpha = 0.01 : OK inatteignable") &&
             identical(r2$lignes()[[1]]$detail, "")
         })
verifier("add() : plancher, sens 'ne pas rejeter', g = 2/100 >= alpha = 0,02 -> 'seul OK atteignable' ; p exacte retenue -> aucune",
         {
           r1 <- reg_beff(99, alpha = 0.02, queue = "deux"); r1$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S")
           r2 <- reg_beff(99, alpha = 0.02, queue = "deux"); r2$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", p_ex = 0.5)
           identical(r1$lignes()[[1]]$detail,
                     "plancher Monte-Carlo >= alpha = 0.02 : seul OK atteignable") &&
             identical(r2$lignes()[[1]]$detail, "")
         })
# Regle R1 sans p exacte, alpha/2 <= p_min < alpha, p Monte-Carlo retenue
# (#128, constat M1 d'audit) : si le plancher g >= alpha/2, la suite "ECHEC
# possible" est omise et la mention du plancher suit ; si g < alpha/2, texte
# inchange. Cas construit : bilateral, alpha = 0,06 (alpha/2 = 0,03),
# p_min = 4/70 = 0,0571 ; B_eff = 59 -> g = 2/60 = 0,0333 >= 0,03 ;
# B_eff = 99 -> g = 2/100 = 0,02 < 0,03.
verifier("add() : R1 sans p exacte, g >= alpha/2 -> 'ECHEC possible' omis, plancher mentionne ; g < alpha/2 -> 'ECHEC possible' inchange",
         {
           r1 <- reg_beff(59, alpha = 0.06, queue = "deux")
           r1$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 4 / 70, effectifs = "n1 = 4, n2 = 4")
           r2 <- reg_beff(99, alpha = 0.06, queue = "deux")
           r2$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 4 / 70, effectifs = "n1 = 4, n2 = 4")
           identical(r1$lignes()[[1]]$detail,
                     paste("p_min de la loi de reference echangeable = 0.0571 >= alpha/2 = 0.03",
                           "(n1 = 4, n2 = 4) ; plancher Monte-Carlo >= alpha/2 = 0.03 : ECHEC inatteignable")) &&
             identical(r2$lignes()[[1]]$detail,
                       paste("p_min de la loi de reference echangeable = 0.0571 >= alpha/2 = 0.03",
                             "(n1 = 4, n2 = 4) ; la p-value Monte-Carlo retenue, simulee sous le modele",
                             "ajuste, peut lui etre inferieure (erreur Monte-Carlo, non-echangeabilite) :",
                             "ECHEC possible"))
         })
# Cas mesure par l'audit (M1) : jeu f8 de test_regimes_p_exactes.R (pi_t
# variable), usp_bootstrap(B = 59), alpha = 0,06, lignes des suites.
x8 <- c(50, 200, 80, 150, 60, 180, 100, 120)
y8 <- c(27.25, 105.90, 57.04, 117.04, 64.50, 152.70, 95.28, 113.69)
f8 <- usp_ajuster(x8, y8)
b8_59 <- usp_bootstrap(f8, B = 59, seed = 20260831)
t8_59 <- usp_tests(f8, b8_59, alpha = 0.06, methode = "premium")
verifier("f8, B = 59, alpha = 0,06 : lignes des suites (residus, ratios bruts) sans 'ECHEC possible', plancher ECHEC inatteignable",
         all(vapply(c("Test des suites (aleatoire des signes)", "Test des suites sur ratios bruts"),
                    function(nm) {
           l <- ligne(t8_59, nm)
           identical(l$nature_p, "Monte-Carlo (bootstrap parametrique)") && identical(l$type, "test") &&
             identical(b8_59$B_effectif[[if (grepl("ratios", nm)) "Runsr" else "Runs"]], 59) &&
             endsWith(l$detail, paste("p_min de la loi de reference echangeable = 0.0571 >= alpha/2 = 0.03",
                                      "(n1 = 4, n2 = 4) ; plancher Monte-Carlo >= alpha/2 = 0.03 : ECHEC inatteignable")) &&
             !grepl("ECHEC possible", l$detail, fixed = TRUE)
         }, logical(1))))
# Runsr, regime 1 (pi_t constant, p exacte) : la phrase "p-value EXACTE est
# retenue" n'est ecrite que hors motif de degenerescence de Runsr (#128).
verifier("Runsr regime 1 : sans motif -> 'EXACTE est retenue' ; motif de degenerescence -> diagnostic, 'EXACTE est ecartee'",
         {
           nm <- "Test des suites sur ratios bruts"
           a <- ligne(usp_tests(fit, boot_fictif(fit), methode = "premium"), nm)
           b <- ligne(usp_tests(fit, boot_fictif(fit, motif = c(Runsr = MOTIF_MC_DISPERSION_NULLE)),
                                methode = "premium"), nm)
           identical(a$nature_p, "exacte") &&
             grepl("la p-value EXACTE est retenue (convention bilaterale", a$detail, fixed = TRUE) &&
             identical(b$type, "diagnostic") && is.na(b$p_retenue) &&
             startsWith(b$detail, MOTIF_MC_DISPERSION_NULLE) &&
             grepl("la p-value EXACTE est ecartee par le motif de degenerescence en tete (ADR 0001).",
                   b$detail, fixed = TRUE) &&
             !grepl("EXACTE est retenue", b$detail, fixed = TRUE)
         })
# Runsr, regime 1 : la phrase "La p-value Monte-Carlo de la colonne p_mc
# estime la meme quantite" n'est ecrite que si p_mc existe (#128, point c,
# reserve R1 d'actuary : jeu de controle avec usp_bootstrap(B = 40), sous le
# seuil de 50 replications, p_mc NA).
verifier("Runsr regime 1 : p_mc finie -> phrase sur p_mc presente ; p_mc NA (B = 40) -> absente, p exacte retenue",
         {
           nm <- "Test des suites sur ratios bruts"
           phr <- "La p-value Monte-Carlo de la colonne p_mc estime la meme quantite, a l'erreur Monte-Carlo pres."
           b40 <- usp_bootstrap(fit, B = 40, seed = 20260831)
           a <- ligne(usp_tests(fit, boot_fictif(fit), methode = "premium"), nm)
           k <- ligne(usp_tests(fit, b40, methode = "premium"), nm)
           is.finite(a$p_mc) && grepl(phr, a$detail, fixed = TRUE) &&
             is.na(b40$p_mc[["Runsr"]]) && is.na(k$p_mc) &&
             identical(k$nature_p, "exacte") && is.finite(k$p_retenue) &&
             grepl("standardises (issue #29).", k$detail, fixed = TRUE) &&
             !grepl("p_mc", k$detail, fixed = TRUE) &&
             !grepl("estime la meme quantite", k$detail, fixed = TRUE)
         })
# Phrases du detail qui nomment la p Monte-Carlo retenue (#128, point c) :
# conditionnelles a la presence de p_mc.
verifier("usp_tests() : RESET et OLS-CUSUM, p_mc presente -> 'retenue' ; absente -> 'indisponible', nature_p nomme le repli",
         {
           ok <- usp_tests(fit, boot_fictif(fit), methode = "premium")
           ko <- usp_tests(fit, boot_fictif(fit, motif = c(RESET = MOTIF_MC_AUCUNE_REPLIC,
                                                           CUSUM = MOTIF_MC_AUCUNE_REPLIC)),
                           methode = "premium")
           r1 <- ligne(ok, "RESET (forme fonctionnelle)"); r2 <- ligne(ko, "RESET (forme fonctionnelle)")
           c1 <- ligne(ok, "Stabilite cumulee (OLS-CUSUM)"); c2 <- ligne(ko, "Stabilite cumulee (OLS-CUSUM)")
           endsWith(r1$detail, "1970). La p Monte-Carlo, simulee sous le modele ajuste, est retenue.") &&
             endsWith(r2$detail, paste("1970). La p Monte-Carlo, simulee sous le modele ajuste, est",
                                       "indisponible sur ces donnees ; la p-value retenue, s'il en est",
                                       "une, est nommee par nature_p.")) &&
             startsWith(r2$nature_p, "asymptotique (Monte-Carlo indisponible") &&
             identical(c1$detail, "La formule asymptotique n'a aucune validite a T = 8 : p_mc retenue") &&
             identical(c2$detail, paste("La formule asymptotique n'a aucune validite a T = 8 ; p_mc est",
                                        "indisponible sur ces donnees ; la p-value retenue, s'il en est",
                                        "une, est nommee par nature_p")) &&
             startsWith(c2$nature_p, "asymptotique (Monte-Carlo indisponible")
         })
# Cas du commentaire 5888798043 de #128 : T = 12, pi_t variable, une paire
# de Cox-Stuart a difference nulle (r_7 = r_1 : m = 5 sur n_p = 6), alpha =
# 0,10, p_min = 0,0625 dans [alpha/2, alpha[ : test sans p-value (ni p
# exacte, R7 ; ni p Monte-Carlo, ex aequo). Restitution 2' ; a T = 10 (m = 4
# sur n_p = 5, p_min = 0,125), TEST INOPERANT inchange.
x12 <- c(100, 120, 90, 150, 200, 80, 130, 170, 110, 95, 210, 140)
y12 <- c(55.5473, 89.7727, 45.4909, 183.251, 182.202, 39.2104, 72.2114,
         166.748, 90.18, 57.2182, 276.78, 116.692)
y12[7] <- x12[7] * y12[1] / x12[1]
res12 <- run_engine(xt = x12, yt = y12, methode = "premium", segment = 1, annexe = "II",
                    nature_donnees = "brutes", B = B_MIN_USAGE, seed = 20260831)
x10 <- x12[1:10]; y10 <- y12[1:10]; y10[6] <- x10[6] * y10[1] / x10[1]
res10 <- run_engine(xt = x10, yt = y10, methode = "premium", segment = 1, annexe = "II",
                    nature_donnees = "brutes", B = B_MIN_USAGE, seed = 20260831)
verifier("Cox-Stuart T = 12, m = 5 sur n_p = 6, alpha = 0,10 : test INFO sans p-value, phrase de #128, sans 'ECHEC inatteignable'",
         {
           cx <- test_cox_stuart(y12 / x12, plancher = 0); l <- ligne(res12$tests, "Tendance par signes du ratio S/P")
           cx$m == 5L && cx$n_p == 6L && proche(l$p_min, 0.0625) &&
             identical(l$type, "test") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             identical(l$sens, "ne pas rejeter") &&
             startsWith(l$detail, paste("Monte-Carlo indisponible : statistique observee non definie : ex aequo ;",
                                        "aucune p-value disponible sur ces donnees : aucun verdict (ADR 0001).",
                                        "p exacte non attribuee")) &&
             !grepl("inatteignable", l$detail, fixed = TRUE)
         })
verifier("Cox-Stuart T = 10, m = 4 sur n_p = 5, alpha = 0,10 : TEST INOPERANT inchange",
         {
           cx <- test_cox_stuart(y10 / x10, plancher = 0); l <- ligne(res10$tests, "Tendance par signes du ratio S/P")
           cx$m == 4L && cx$n_p == 5L && identical(l$type, "diagnostic") &&
             startsWith(l$detail, "TEST INOPERANT") &&
             !grepl("aucune p-value disponible", l$detail, fixed = TRUE)
         })

## --- 4 ter. #165 : condition necessaire de conclusion du TOST --------------
# Formulation d'actuary arretee par le mainteneur (commentaire 5927254443 de
# #165) : apres le texte d'avant #165, une phrase decidee par p_plancher =
# 1 - F_t(Delta/se) (p du TOST en a = 0) compare a alpha et a
# SEUIL_ECHEC_SENS_REJETER ; rho = t(1-alpha, T-2) x se / Delta a %.2f.
# Valeurs construites loin des points de bascule de %.2f (mesure sur ces
# donnees : rho = 9.8114 ; 0.5560 ; 1.6680 ; 0.8313 ; 0.6541 avant #215,
# se(a) MCO ; depuis #215, se(a) du modele auxiliaire pondere, 53,7545 au
# lieu de 57,9278 : rho = 9.1046 ; 0.5160 ; 1.5479 ; 0.7714 ; 0.6070, memes
# branches et memes verdicts), donc independantes de la plateforme.
NOM_TOST165 <- "Equivalence de la constante a zero (TOST)"
TXT_FIN165 <- paste(". L'equivalence ne peut pas etre conclue avec ces donnees (plan de volumes,",
                    "dispersion residuelle) et cette marge : ce verdict traduit une absence de",
                    "preuve, non un ecart a la proportionnalite.")
TXT_NON165 <- paste("Condition necessaire de conclusion non remplie : t(1-alpha, T-2) x se(a) /",
                    "Delta = %s >= 1, soit se(a) >= Delta / t(1-alpha, T-2) : quelle que soit la",
                    "constante estimee, p >= alpha")
# Texte d'avant #165, recalcule depuis test_tost_intercept().
# pi : pi_t de l'ajustement de (x, y) (#215), par defaut celui des donnees de test.
avant165 <- function(x, y, theta = 0.10, delta_abs = NULL, pi = fit$pi) {
  t0 <- test_tost_intercept(x, y, pi, theta = theta, delta_abs = delta_abs)
  sprintf(paste("Rejeter H0 fournit une preuve POSITIVE de proportionnalite.",
                "Delta = %s (valeur : estimation \"marge Delta\") ;",
                "p_bas = %.4f, p_haut = %.4f."),
          if (is.null(delta_abs)) sprintf("%.0f %% de la moyenne de y", 100 * theta)
          else "marge fixee a priori", t0$p_bas, t0$p_haut)
}
tost165 <- function(f, ...) ligne(usp_tests(f, boot_fictif(f), methode = "premium", ...), NOM_TOST165)
verifier("TOST (#165), donnees des quatre cas lognormaux (alpha = 0,10, theta = 0,10), premium et reserve1 : texte d'avant + 'non remplie ... = 9.10 >= 1 ... et meme p >= 0.3 : OK et ALERTE inatteignables. L'equivalence ...' ; p retenue et verdict ECHEC inchanges",
         {
           att <- paste(avant165(x, y),
                        paste0(sprintf(TXT_NON165, "9.10"),
                               " et meme p >= 0.3 : OK et ALERTE inatteignables", TXT_FIN165))
           ok <- vapply(c("premium", "reserve1"), function(m) {
             l <- ligne(usp_tests(fit, boot_fictif(fit), methode = m), NOM_TOST165)
             identical(l$detail, att) && identical(l$verdict, "ECHEC") &&
               identical(l$p_retenue, test_tost_intercept(x, y, fit$pi)$p)
           }, logical(1))
           if (all(ok)) TRUE else paste("en defaut :", paste(names(ok)[!ok], collapse = ", "))
         })
verifier("TOST (#165), marge fixee a priori delta_equiv = 150 (rho = 0.52 < 1) : texte d'avant + 'remplie', verdict OK",
         {
           l <- tost165(fit, delta_equiv = 150)
           identical(l$detail, paste(avant165(x, y, delta_abs = 150),
                                     paste("Condition necessaire de conclusion remplie :",
                                           "t(1-alpha, T-2) x se(a) / Delta = 0.52 < 1."))) &&
             identical(l$verdict, "OK")
         })
verifier("TOST (#165), marge estimee theta_equiv = 1,5 (rho = 0.61 < 1) : 'remplie', verdict OK",
         {
           l <- tost165(fit, theta_equiv = 1.5)
           identical(l$detail, paste(avant165(x, y, theta = 1.5),
                                     paste("Condition necessaire de conclusion remplie :",
                                           "t(1-alpha, T-2) x se(a) / Delta = 0.61 < 1."))) &&
             identical(l$verdict, "OK")
         })
verifier("TOST (#165), marge fixee a priori delta_equiv = 50 (alpha <= p_plancher < 0,30, rho = 1.55) : 'OK inatteignable' seul, verdict ALERTE",
         {
           l <- tost165(fit, delta_equiv = 50)
           t0 <- test_tost_intercept(x, y, fit$pi, delta_abs = 50)
           pp <- stats::pt(50 / t0$se, 6, lower.tail = FALSE)
           pp >= 0.10 && pp < SEUIL_ECHEC_SENS_REJETER &&
             identical(l$detail, paste(avant165(x, y, delta_abs = 50),
                                       paste0(sprintf(TXT_NON165, "1.55"), " : OK inatteignable",
                                              TXT_FIN165))) &&
             !grepl("ALERTE inatteignables", l$detail, fixed = TRUE) &&
             identical(l$verdict, "ALERTE")
         })
verifier("TOST (#165), alpha de la regle des verdicts : delta_equiv = 50 a alpha = 0,25 -> 'remplie' avec t(0,75 ; 6) (rho = 0.77), verdict OK",
         {
           l <- ligne(usp_tests(fit, boot_fictif(fit), alpha = 0.25, methode = "premium",
                                delta_equiv = 50), NOM_TOST165)
           identical(l$detail, paste(avant165(x, y, delta_abs = 50),
                                     paste("Condition necessaire de conclusion remplie :",
                                           "t(1-alpha, T-2) x se(a) / Delta = 0.77 < 1."))) &&
             identical(l$verdict, "OK")
         })
# Cas construits a la frontiere (reprise de l'audit de #165) : Delta =
# se(a) x t(q ; 6) x k, k = 1,005 ou 1/1,005, q = 0,90 (bascule alpha = 0,10)
# ou 0,70 (bascule SEUIL_ECHEC_SENS_REJETER = 0,30), alpha = 0,10. Mesure sur
# ces donnees (p_plancher a 6 ddl ; a 7 ddl entre parentheses) :
#   q = 0,90, k = 1,005 : 0,099029 (0,095581), p = 0,1084 -> remplie, ALERTE
#   q = 0,90, k = 1/1,005 : 0,100975 (0,097540), p = 0,1105 -> OK inatteignable, ALERTE
#   q = 0,70, k = 1,005 : 0,299111 (0,297716), p = 0,3210 -> OK inatteignable, ECHEC
#   q = 0,70, k = 1/1,005 : 0,300886 (0,299506), p = 0,3228 -> OK et ALERTE inatteignables, ECHEC
# (p mesurees depuis #215, se(a) et a du modele auxiliaire pondere ;
# p_plancher, fonction de q et k seuls, inchangees.)
# Ecarts aux seuils de l'ordre de 1e-3 : sans rapport avec la derive de
# plateforme ; les cas k = 1/1,005 distinguent T - 2 de T - 1 ddl. rho
# (0,995 a q = 0,90, k = 1,005) n'est pas compare : l'arrondi %.2f y montre
# 1.00 (limite admise, commentaire 5927254443 de #165).
verifier("TOST (#165), cas a la frontiere (marge 0,5 % autour de t(0,90 ; 6) et t(0,70 ; 6), delta_equiv, alpha = 0,10) : branche decidee par p_plancher a T - 2 ddl contre alpha et SEUIL_ECHEC_SENS_REJETER, verdict coherent",
         {
           se0 <- test_tost_intercept(x, y, fit$pi)$se
           cas <- list(list(q = 0.90, k = 1.005,     br = "remplie", v = "ALERTE"),
                       list(q = 0.90, k = 1 / 1.005, br = "ok",      v = "ALERTE"),
                       list(q = 0.70, k = 1.005,     br = "ok",      v = "ECHEC"),
                       list(q = 0.70, k = 1 / 1.005, br = "deux",    v = "ECHEC"))
           ok <- vapply(cas, function(cc) {
             d <- se0 * stats::qt(cc$q, 6) * cc$k
             l <- tost165(fit, delta_equiv = d)
             br <- if (grepl("conclusion remplie", l$detail, fixed = TRUE)) "remplie"
                   else if (grepl("OK et ALERTE inatteignables", l$detail, fixed = TRUE)) "deux"
                   else if (grepl(" : OK inatteignable. L'equivalence", l$detail, fixed = TRUE)) "ok"
                   else "?"
             identical(br, cc$br) && identical(l$verdict, cc$v) &&
               startsWith(l$detail, avant165(x, y, delta_abs = d))
           }, logical(1))
           if (all(ok)) TRUE else paste("cas en defaut :", paste(which(!ok), collapse = ", "))
         })
verifier("TOST (#165), branches non calculees inchangees : marge invalide et volumes constants sans phrase de condition",
         {
           a <- tost165(fit, delta_equiv = -1)
           b <- tost165(usp_ajuster(rep(100, 8), y))
           identical(a$type, "non applicable") && identical(b$type, "non applicable") &&
             !grepl("Condition necessaire", a$detail, fixed = TRUE) &&
             !grepl("Condition necessaire", b$detail, fixed = TRUE)
         })
# Propriete (graine explicite, engine_sous_graine()) : 30 series simulees,
# marge fixee a priori Delta = se(a) x k, k log-uniforme sur [0,2 ; 4], alpha
# tire dans {0,05 ; 0,10 ; 0,20}. Le detail ne contredit jamais le verdict et
# chaque branche est rencontree.
verifier("TOST (#165), propriete sur 30 series simulees (graine 165) : jamais 'non remplie' avec OK, jamais 'OK et ALERTE inatteignables' hors ECHEC, 'remplie' si et seulement si p_plancher < alpha, 'OK et ALERTE inatteignables' si et seulement si p_plancher >= SEUIL_ECHEC_SENS_REJETER ; les trois branches rencontrees",
         {
           sim <- engine_sous_graine(165L, lapply(1:30, function(i) {
             xs <- 100 * exp(cumsum(stats::rnorm(8, 0.03, 0.08)))
             ys <- 0.7 * xs * exp(stats::rnorm(8, 0, 0.15)) + stats::rnorm(1, 0, 10)
             list(x = xs, y = ys, k = exp(stats::runif(1, log(0.2), log(4))),
                  alpha = sample(c(0.05, 0.10, 0.20), 1))
           }))
           pb <- character(0); vu <- c(remplie = 0L, ok_inat = 0L, ok_alerte_inat = 0L)
           for (i in seq_along(sim)) {
             s <- sim[[i]]
             f <- usp_ajuster(s$x, s$y)
             se <- test_tost_intercept(s$x, s$y, f$pi)$se
             d <- se * s$k
             l <- ligne(usp_tests(f, boot_fictif(f), alpha = s$alpha, methode = "premium",
                                  delta_equiv = d), NOM_TOST165)
             pp <- stats::pt(d / se, 6, lower.tail = FALSE)
             rem <- grepl("conclusion remplie", l$detail, fixed = TRUE)
             non <- grepl("conclusion non remplie", l$detail, fixed = TRUE)
             deux <- grepl("OK et ALERTE inatteignables", l$detail, fixed = TRUE)
             if (rem) vu["remplie"] <- vu["remplie"] + 1L
             else if (deux) vu["ok_alerte_inat"] <- vu["ok_alerte_inat"] + 1L
             else if (non) vu["ok_inat"] <- vu["ok_inat"] + 1L
             if (!identical(l$type, "test") || rem == non ||
                 (non && identical(l$verdict, "OK")) ||
                 (deux && !identical(l$verdict, "ECHEC")) ||
                 rem != (pp < s$alpha) ||
                 deux != (pp >= SEUIL_ECHEC_SENS_REJETER) ||
                 !startsWith(l$detail, avant165(s$x, s$y, delta_abs = d, pi = f$pi)))
               pb <- c(pb, sprintf("serie %d (verdict %s)", i, l$verdict))
           }
           if (length(pb)) paste(pb, collapse = " ; ")
           else if (any(vu == 0L)) paste("branche non rencontree :", paste(names(vu)[vu == 0L], collapse = ", "))
           else TRUE
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

## --- 6. Champ inoperant (#129, point 3) ----------------------------------------
# add() pose sur chaque ligne un logique inoperant, TRUE si et seulement si la
# bascule de la regle R1 a eu lieu (detail prefixe "TEST INOPERANT"), FALSE
# sinon, jamais NA ; dernier champ de la ligne, apres p_min et fonction.
# Invariant verifie sur les lignes de run_engine() de ce fichier et sur
# celles des cinq references versionnees (tests/reference/).
inv_inop <- function(tt) {
  ok_type <- vapply(tt, function(l) is.logical(l$inoperant) && length(l$inoperant) == 1L &&
                      !is.na(l$inoperant), logical(1))
  if (!all(ok_type)) return(paste("inoperant non logique, NA ou de longueur != 1 :",
                                  sum(!ok_type), "ligne(s)"))
  inop <- vapply(tt, function(l) l$inoperant, logical(1))
  pref <- vapply(tt, function(l) startsWith(l$detail, "TEST INOPERANT"), logical(1))
  noms_ok <- vapply(tt, function(l) identical(tail(names(l), 3L),
                                              c("p_min", "fonction", "inoperant")), logical(1))
  diag_ok <- all(vapply(tt[inop], function(l) identical(l$type, "diagnostic") &&
                          identical(l$verdict, "INFO"), logical(1)))
  if (!identical(inop, pref)) paste("inoperant != prefixe TEST INOPERANT :", sum(inop != pref), "ligne(s)")
  else if (!all(noms_ok)) paste("ordre des derniers champs faux :", sum(!noms_ok), "ligne(s)")
  else if (!diag_ok) "ligne inoperante hors diagnostic INFO"
  else TRUE
}
verifier("add() : bascule R1 -> inoperant TRUE ; p_min < alpha, p_min NA -> FALSE ; derniers champs p_min, fonction, inoperant",
         {
           r <- reg_fictif()
           r$add("F", "t1", "ref", fonction = "usp_tests", p_ex = 0.9, p_min = 0.125)
           r$add("F", "t2", "ref", fonction = "usp_tests", p_ex = 0.06, p_min = 4 / 70)
           r$add("F", "t3", "ref", fonction = "usp_tests", p_ex = 0.01)
           r$add("F", "t4", "ref", fonction = "usp_tests", type = "diagnostic", estim = 1, p_min = 0.5)
           L <- r$lignes()
           identical(vapply(L, function(l) l$inoperant, logical(1)), c(TRUE, FALSE, FALSE, FALSE)) &&
             isTRUE(inv_inop(L))
         })
verifier("add() : ligne R3 (statistique observee non finie, degenerescence) -> inoperant FALSE",
         {
           r <- reg_motif(MOTIF_MC_OBS_NON_FINIE)
           r$add("F", "t", "ref", fonction = "usp_tests", p_as = 0.3, mc_nom = "S", p_min = 0.5)
           r2 <- reg_motif(MOTIF_MC_DISPERSION_NULLE)
           r2$add("F", "t", "ref", fonction = "usp_tests", p_ex = 0.3, mc_nom = "S", p_min = 0.5)
           l <- r$lignes()[[1]]; l2 <- r2$lignes()[[1]]
           identical(l$type, "non applicable") && identical(l$inoperant, FALSE) &&
             identical(l2$type, "diagnostic") && identical(l2$inoperant, FALSE) &&
             isTRUE(inv_inop(list(l, l2)))
         })
verifier("add() : ligne sans aucune p-value (#128, point 2') -> inoperant FALSE ; avec p_min >= alpha -> TRUE",
         {
           r <- reg_fictif()
           r$add("F", "t", "ref", fonction = "usp_tests", p_min = 4 / 70)
           r$add("F", "u", "ref", fonction = "usp_tests", p_min = 0.125)
           L <- r$lignes()
           startsWith(L[[1]]$detail, "aucune p-value disponible") && identical(L[[1]]$inoperant, FALSE) &&
             identical(L[[2]]$inoperant, TRUE) && isTRUE(inv_inop(L))
         })
verifier("run_engine() : inoperant <=> prefixe TEST INOPERANT sur toutes les lignes (T = 8, volumes constants, T = 10, T = 12)",
         {
           v <- lapply(list(T8 = res_ln, vc = res_vc, T10 = res10, T12 = res12), function(r) inv_inop(r$tests))
           ok <- vapply(v, isTRUE, logical(1))
           cs10 <- ligne(res10$tests, "Tendance par signes du ratio S/P")
           cs12 <- ligne(res12$tests, "Tendance par signes du ratio S/P")
           if (!all(ok)) paste(names(v)[!ok], unlist(v[!ok]), collapse = " ; ")
           else isTRUE(cs10$inoperant) && identical(cs12$inoperant, FALSE) &&
             any(vapply(res_ln$tests, function(l) l$inoperant, logical(1)))
         })
verifier("References versionnees (5 cas) : inoperant <=> prefixe TEST INOPERANT, jamais NA, derniers champs p_min, fonction, inoperant",
         {
           cas <- c("premium", "reserve1", "reserve2", "premium_ii6", "premium_net")
           v <- lapply(cas, function(k) {
             f <- file.path(RACINE, "tests", "reference", paste0(k, ".rds"))
             if (!file.exists(f)) "reference absente" else inv_inop(readRDS(f)$tests)
           })
           ok <- vapply(v, isTRUE, logical(1))
           if (all(ok)) TRUE else paste(cas[!ok], unlist(v[!ok]), collapse = " ; ")
         })
verifier("engine_table_tests : colonne logique inoperant, derniere colonne, alignee sur le champ des lignes",
         {
           tb <- engine_table_tests(res_ln)
           identical(tail(names(tb), 2L), c("fonction", "inoperant")) && is.logical(tb$inoperant) &&
             !anyNA(tb$inoperant) &&
             identical(tb$inoperant, vapply(res_ln$tests, function(l) l$inoperant, logical(1)))
         })

fin_fichier()
