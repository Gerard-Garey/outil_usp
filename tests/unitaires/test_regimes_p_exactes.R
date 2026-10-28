###############################################################################
#  tests/unitaires/test_regimes_p_exactes.R  --  P-VALUES EXACTES SELON LE
#                                                 REGIME DE pi_t (ISSUE #70)
#
#  Consigne d'actuary du 27/09/2026 (etape 4 d'E1), regles R7, R8, R9 amendee,
#  2b, 2c et 5a-5c :
#    - les sept lignes a loi de reference exacte (Durbin-Watson, suites,
#      Smirnov, Spearman volume et temps, Mann-Kendall, Cox-Stuart ;
#      Shapiro-Wilk a loi nulle simulee, huitieme, retiree par #302) n'ont de
#      p exacte qu'a pi_t constant ;
#    - Spearman : aucune p exacte avec ex aequo, ni a T > 9 ;
#    - add() restitue dans detail le motif d'absence de p_min.
#  References : appels directs des fonctions de loi exacte (dw_p_exacte,
#  runs_p_exacte, mk_p_exacte, stats::ks.test,
#  stats::cor.test), enumeration exhaustive des 8! permutations (Spearman avec
#  ex aequo), prho.c de R (n_small = 9 : exact pour n <= 9, Edgeworth AS 89
#  au-dela).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_regimes_p_exactes.R")

# Objet bootstrap fictif (aucune simulation) : p Monte-Carlo a 0,5, aucun
# motif ; `motif` en pose un sur une statistique (meme outil que
# test_inoperance.R).
boot_fictif <- function(f, p = 0.5, motif = NULL) {
  s <- .stats_bootstrapables(f$x, f$y, f$z, f$pi)
  pm <- stats::setNames(rep(p, length(s)), names(s))
  mm <- stats::setNames(rep(NA_character_, length(s)), names(s))
  if (!is.null(motif)) { pm[names(motif)] <- NA_real_; mm[names(motif)] <- motif }
  list(stats_obs = as.list(s), p_mc = pm, err_mc = pm * 0 + 0.01, motif_mc = mm)
}
ligne <- function(tt, nom) Filter(function(l) identical(l$test, nom), tt)[[1]]
NOM <- c(DW = "Autocorrelation d'ordre 1 (Durbin-Watson)",
         Runs = "Test des suites (aleatoire des signes)",
         Smirnov = "Egalite des lois petits vs gros volumes (2 ech.)",
         SpearVol = "Independance ratio S/P vs volume",
         SpearTps = "Correlation ratio S/P vs temps",
         MK = "Tendance monotone du ratio S/P",
         CoxStuart = "Tendance par signes du ratio S/P")
NAT_MC <- "Monte-Carlo (bootstrap parametrique)"
TXT_R8 <- paste("p exacte non attribuee : loi de reference exacte seulement",
                "a pi_t constant (z = P epsilon non echangeable, r_t non",
                "identiquement distribues).")
commence_par_r8 <- function(d) startsWith(d, TXT_R8)
# Smirnov et Spearman ratio / temps : diagnostics par decision depuis #299
# (Q-D1-Fh-5) ; la regle R7 decide encore de leur p exacte (colonne
# p_exacte), mais aucune p n'est retenue (nature_p NA) et add() ne restitue
# plus le motif d'effectifs (ex aequo) dans le detail : usp_tests() le joint
# lui-meme (detail_diag(), #358 ; avis d'actuary du 20/10/2026).
DIAG_299 <- c("Smirnov", "SpearTps")
MOTIF_EA_R <- "ex aequo dans r : loi de permutation conditionnelle non tabulee, p_min et p exacte non attribuees"
est_diag_299 <- function(l) identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
  is.na(l$nature_p) && is.na(l$p_retenue) && isFALSE(l$inoperant)
# Ajustement force a delta = 1 (pi_t exactement constant), gamma de
# usp_ajuster() ; meme construction que f29_bande (test_lois_exactes.R).
fit_force <- function(x, y, d) {
  g <- usp_ajuster(x, y)$gamma
  c(usp_noyau(d, g, x, y),
    list(delta = d, gamma = g, T = length(x), x = x, y = y, xbar = mean(x),
         convergence = 0L, part_starts_convergents = 1,
         delta_au_bord = usp_regime(d, x)$delta_au_bord))
}

## --- 1. pi_t exactement constant : sept p exactes, valeurs d'avant #70 -----
x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
fit <- usp_ajuster(x, y)
tt <- usp_tests(fit, boot_fictif(fit), methode = "premium")
verifier("Regime des donnees de test : delta = 1, pi_t exactement constant, sans ex aequo",
         identical(fit$delta, 1) && isTRUE(usp_regime(fit$delta, fit$x)$pi_constant_exact) &&
           anyDuplicated(y / x) == 0 && anyDuplicated(x) == 0)
# Cox-Stuart a T = 8 : m <= n_p = 4, p_min >= 0,125 >= alpha = 0,10, donc
# ligne restituee en diagnostic par la regle R1 de #44 (sans nature_p) ; sa
# p exacte reste calculee et comparee.
nature_attendue <- function(tt, k) {
  l <- ligne(tt, NOM[[k]])
  if (k == "CoxStuart") identical(l$type, "diagnostic") && is.na(l$nature_p)
  else if (k %in% DIAG_299) est_diag_299(l)
  else identical(l$nature_p, "exacte")
}
verifier("pi_t constant exact : quatre lignes 'exacte' (Cox-Stuart inoperante, R1 ; Smirnov et Spearman-temps diagnostics par decision, #299), p_exacte identique a l'appel direct",
         {
           z <- fit$z; r <- y / x; grp <- x > stats::median(x)
           attendu <- list(
             DW = dw_p_exacte(z), Runs = runs_p_exacte(z),
             Smirnov = stats::ks.test(z[grp], z[!grp])$p.value,
             SpearVol = stats::cor.test(r, x, method = "spearman", exact = TRUE)$p.value,
             SpearTps = stats::cor.test(r, seq_along(r), method = "spearman", exact = TRUE)$p.value,
             MK = mk_p_exacte(r), CoxStuart = test_cox_stuart(r)$p)
           ko <- names(NOM)[!vapply(names(NOM), function(k) {
             l <- ligne(tt, NOM[[k]])
             nature_attendue(tt, k) && identical(l$p_exacte, attendu[[k]])
           }, logical(1))]
           if (length(ko)) paste("lignes en defaut :", paste(ko, collapse = ", ")) else TRUE
         })
verifier("pi_t constant exact : detail sans suffixe de bande ni phrase R8",
         !any(vapply(NOM, function(n) {
           d <- ligne(tt, n)$detail
           grepl("pi_t constant a la tolerance", d, fixed = TRUE) ||
             grepl("p exacte non attribuee", d, fixed = TRUE)
         }, logical(1))))

## --- 2. pi_t variable, T = 5 (delta = 0) -----------------------------------
f5 <- usp_ajuster(x[1:5], y[1:5])
t5 <- usp_tests(f5, boot_fictif(f5), methode = "premium")
verifier("T = 5 : pi_t variable (delta = 0, volumes variables)",
         !isTRUE(usp_regime(f5$delta, f5$x)$pi_constant))
verifier("T = 5 : DW, Spearman x2, MK -> p_exacte NA, Monte-Carlo retenue (Spearman-temps : diagnostic par decision, #299), detail commencant par R8",
         all(vapply(c("DW", "SpearVol", "SpearTps", "MK"), function(k) {
           l <- ligne(t5, NOM[[k]])
           is.na(l$p_exacte) && commence_par_r8(l$detail) &&
             (if (k %in% DIAG_299) est_diag_299(l) && identical(l$p_mc, 0.5)
              else identical(l$nature_p, NAT_MC))
         }, logical(1))))
verifier("T = 5 : suites et Cox-Stuart -> p_exacte NA, INFO par la regle R1, phrase R8",
         all(vapply(NOM[c("Runs", "CoxStuart")], function(n) {
           l <- ligne(t5, n)
           is.na(l$p_exacte) && identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
             grepl("TEST INOPERANT", l$detail, fixed = TRUE) && grepl(TXT_R8, l$detail, fixed = TRUE)
         }, logical(1))))

## --- 3. pi_t variable, T = 8 (delta interieur) ------------------------------
# Provenance : x fixe ; set.seed(20260928) ;
# y <- round(x * 0.75 * exp(rnorm(8, 0, 0.25 * sqrt(mean(x) / x))), 2).
x8 <- c(50, 200, 80, 150, 60, 180, 100, 120)
y8 <- c(27.25, 105.90, 57.04, 117.04, 64.50, 152.70, 95.28, 113.69)
f8 <- usp_ajuster(x8, y8)
t8 <- usp_tests(f8, boot_fictif(f8), methode = "premium")
verifier("T = 8 : pi_t variable, delta dans ]0,1[, sans ex aequo, n1 = n2 = 4 pour Smirnov",
         !isTRUE(usp_regime(f8$delta, f8$x)$pi_constant) && f8$delta > 0 && f8$delta < 1 &&
           anyDuplicated(y8 / x8) == 0 && anyDuplicated(x8) == 0 && sum(x8 > stats::median(x8)) == 4)
verifier("T = 8 : sept lignes p_exacte NA",
         all(vapply(NOM, function(n) is.na(ligne(t8, n)$p_exacte), logical(1))))
verifier("T = 8 : quatre lignes Monte-Carlo retenue (type test) ; Smirnov et Spearman-temps diagnostics par decision (#299), p Monte-Carlo conservee ; Cox-Stuart INFO par R1",
         all(vapply(NOM[c("DW", "Runs", "SpearVol", "MK")], function(n) {
           l <- ligne(t8, n); identical(l$type, "test") && identical(l$nature_p, NAT_MC)
         }, logical(1))) &&
           all(vapply(NOM[DIAG_299], function(n) {
             l <- ligne(t8, n); est_diag_299(l) && identical(l$p_mc, 0.5)
           }, logical(1))) &&
           identical(ligne(t8, NOM[["CoxStuart"]])$type, "diagnostic") &&
           identical(ligne(t8, NOM[["CoxStuart"]])$verdict, "INFO"))
verifier("T = 8 : phrase R8 sur les sept lignes",
         all(vapply(NOM, function(n) grepl(TXT_R8, ligne(t8, n)$detail, fixed = TRUE), logical(1))))

## --- 4. Assertion negative I3 : aucune nature 'exacte' a pi_t variable -----
verifier("I3 : aucune ligne de nature 'exacte' a pi_t variable (T = 5 et T = 8), toutes lignes",
         !any(vapply(c(t5, t8), function(l) identical(l$nature_p, "exacte"), logical(1))))

## --- 5. Bande de tolerance : p exactes attribuees, suffixe ------------------
fb <- local({
  d <- 1 - TOL_DELTA_BORD / 2; r <- y / x; o <- order(r)
  r[o[5]] <- r[o[4]] * (1 - 1e-10); yy <- r * x
  c(usp_noyau(d, fit$gamma, x, yy),
    list(delta = d, gamma = fit$gamma, T = length(x), x = x, y = yy,
         xbar = mean(x), convergence = 0L, part_starts_convergents = 1,
         delta_au_bord = usp_regime(d, x)$delta_au_bord))
})
tb <- usp_tests(fb, boot_fictif(fb), methode = "premium")
verifier("Bande : pi_constant vrai, pi_constant_exact faux",
         isTRUE(usp_regime(fb$delta, fb$x)$pi_constant) &&
           !isTRUE(usp_regime(fb$delta, fb$x)$pi_constant_exact))
verifier("Bande : sept lignes p_exacte finie, 'exacte' (Cox-Stuart : R1 ; Smirnov et Spearman-temps : diagnostics, #299), detail suffixe 'a la tolerance TOL_DELTA_BORD'",
         all(vapply(names(NOM), function(k) {
           l <- ligne(tb, NOM[[k]])
           is.finite(l$p_exacte) && nature_attendue(tb, k) &&
             grepl("a la tolerance TOL_DELTA_BORD", l$detail, fixed = TRUE) &&
             !grepl("p exacte non attribuee", l$detail, fixed = TRUE)
         }, logical(1))))
verifier("Bande : ligne Runsr sans phrase R7/R8 (regime #29 inchange : p exacte NA, signes differents ; diagnostic R15, #303)",
         {
           l <- ligne(tb, "Test des suites sur ratios bruts")
           is.na(l$p_exacte) && identical(l$p_mc, 0.5) && identical(l$type, "diagnostic") &&
             is.na(l$nature_p) &&
             !grepl("p exacte non attribuee", l$detail, fixed = TRUE) &&
             !grepl("loi de reference exacte a un ecart", l$detail, fixed = TRUE)
         })
# #128, point c : la phrase "p-value Monte-Carlo ... est calculee" (#214 ;
# "est retenue" avant) de la ligne Runsr (regime 3, pi_t variable) n'est
# ecrite que si p_mc existe ;
# sinon la ligne, sans p exacte ni asymptotique, est un test sans p-value
# (phrase de #128 en tete). Regime 2 (bande a signes differents) depuis
# #187 : p_mc presente, la phrase dit la p Monte-Carlo calculee ; depuis #303
# (regle R15, pi_t constant), sans renvoi a nature_p, la ligne etant un
# diagnostic ; p_mc absente, le motif est en tete (motif non degenere :
# "Monte-Carlo indisponible : <motif>.") et la phrase de R15 en fin, sans la
# phrase txt_mc_indispo(), qui disait une troisieme fois l'absence de p
# retenue (#358).
verifier("Runsr, regimes 2 et 3 : p_mc presente -> 'est calculee' (3, #214 ; 2, #187, #303) ; absente -> 'indisponible' (3 : test sans p-value) ou motif et phrase de R15 seuls (2 : diagnostic R15, #358)",
         {
           txt_ind <- "est indisponible sur ces donnees : aucune p-value n'est retenue (ADR 0001)"
           m <- c(Runsr = MOTIF_MC_AUCUNE_REPLIC)
           nm <- "Test des suites sur ratios bruts"
           a3 <- ligne(t8, nm)
           b3 <- ligne(usp_tests(f8, boot_fictif(f8, motif = m), methode = "premium"), nm)
           a2 <- ligne(tb, nm)
           b2 <- ligne(usp_tests(fb, boot_fictif(fb, motif = m), methode = "premium"), nm)
           grepl(paste("Seule la p-value Monte-Carlo, simulee sous le modele ajuste avec ses pi_t,",
                       "est calculee ;", PHRASE_RENVOI_NATURE_P, ";"),
                 a3$detail, fixed = TRUE) && !grepl(" est retenue", a3$detail, fixed = TRUE) &&
             grepl(paste("La p-value Monte-Carlo, simulee sous le modele ajuste avec ses pi_t,", txt_ind),
                   b3$detail, fixed = TRUE) && !grepl(" est retenue", b3$detail, fixed = TRUE) &&
             grepl("La p-value Monte-Carlo, simulee sous le modele ajuste, est calculee.",
                   a2$detail, fixed = TRUE) && !grepl(PHRASE_RENVOI_NATURE_P, a2$detail, fixed = TRUE) &&
             !grepl(" est retenue", a2$detail, fixed = TRUE) &&
             !grepl(txt_ind, b2$detail, fixed = TRUE) &&
             grepl("(issue #29, seconde condition de la fonction usp_runsr_p_exacte). Restituee en diagnostic (regle R15)",
                   b2$detail, fixed = TRUE) &&
             !grepl(" est retenue", b2$detail, fixed = TRUE) &&
             identical(b3$type, "test") && identical(b3$verdict, "INFO") && is.na(b3$p_retenue) &&
             startsWith(b3$detail, "Monte-Carlo indisponible : aucune replication finie") &&
             identical(b2$type, "diagnostic") && identical(b2$verdict, "INFO") && is.na(b2$p_retenue) &&
             startsWith(b2$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_AUCUNE_REPLIC, ".")) &&
             !grepl(": aucune p-value retenue (ADR 0001)", b2$detail, fixed = TRUE) &&
             endsWith(b2$detail, "dont le type et le verdict font foi.")
         })
# #182 (Q1 d'audit, retenue) : txt_mc_indispo() n'a que des appelants sans p
# exacte (RESET, OLS-CUSUM, Runsr non attribuee) ; p_mc absente, aucune
# p-value n'est retenue, et le texte le dit sans renvoyer a nature_p. La
# phrase "s'il en est une" reste dans les branches AVEC p_mc de type test
# (depuis #214, RESET, OLS-CUSUM, Runsr regime 3), add() pouvant encore
# ecarter la p calculee ; elle est retiree des branches de Runsr a pi_t
# constant (regimes 1 et 2), diagnostics de la regle R15 depuis #303.
verifier("txt_mc_indispo (#182) : RESET et OLS-CUSUM sans p_mc -> 'aucune p-value n'est retenue' ; Runsr regime 2 avec p_mc -> 'est calculee', sans 's'il en est une' (#303)",
         {
           ko <- usp_tests(fit, boot_fictif(fit, motif = c(RESET = MOTIF_MC_AUCUNE_REPLIC,
                                                           CUSUM = MOTIF_MC_AUCUNE_REPLIC)),
                           methode = "premium")
           r <- ligne(ko, "RESET (forme fonctionnelle)"); k <- ligne(ko, "Stabilite cumulee (OLS-CUSUM)")
           a2 <- ligne(tb, "Test des suites sur ratios bruts")
           nouveau <- "est indisponible sur ces donnees : aucune p-value n'est retenue (ADR 0001)"
           all(vapply(list(r, k), function(l)
             grepl(nouveau, l$detail, fixed = TRUE) && !grepl("s'il en est une", l$detail, fixed = TRUE) &&
               is.na(l$p_retenue) && is.na(l$p_exacte), logical(1))) &&
             is.finite(a2$p_mc) &&
             grepl("simulee sous le modele ajuste, est calculee.", a2$detail, fixed = TRUE) &&
             !grepl("s'il en est une", a2$detail, fixed = TRUE) && !grepl(nouveau, a2$detail, fixed = TRUE)
         })

# Suffixe de bande seulement si la p exacte de la ligne est finie (#70, Q3).
# Fit SYNTHETIQUE, construit comme le retour d'usp_ajuster_rapide() (non un
# ajustement) : delta = 1 - TOL_DELTA_BORD / 2, gamma de l'ajustement des
# donnees de test, un ex aequo dans r (r_2 = r_1).
fbe <- local({
  y2 <- y; y2[2] <- x[2] * y[1] / x[1]; d <- 1 - TOL_DELTA_BORD / 2
  c(usp_noyau(d, fit$gamma, x, y2),
    list(delta = d, gamma = fit$gamma, T = 8, x = x, y = y2, xbar = mean(x)))
})
tbe <- usp_tests(fbe, boot_fictif(fbe), methode = "premium")
verifier("Bande avec ex aequo dans r : regime pi_constant et non pi_constant_exact",
         isTRUE(usp_regime(fbe$delta, fbe$x)$pi_constant) &&
           !isTRUE(usp_regime(fbe$delta, fbe$x)$pi_constant_exact) &&
           anyDuplicated(fbe$y / fbe$x) > 0)
verifier("Bande avec ex aequo : Spearman x2 et MK sans p exacte ni suffixe de bande ; DW et suites avec ; Spearman-temps (diagnostic, #299) avec motif ex aequo joint par usp_tests()",
         all(vapply(c("SpearVol", "SpearTps", "MK"), function(k) {
           l <- ligne(tbe, NOM[[k]])
           is.na(l$p_exacte) && is.na(l$p_min) &&
             !grepl("a la tolerance TOL_DELTA_BORD", l$detail, fixed = TRUE) &&
             (if (k %in% DIAG_299) est_diag_299(l) && grepl(MOTIF_EA_R, l$detail, fixed = TRUE)
              else grepl("ex aequo dans r", l$detail, fixed = TRUE))
         }, logical(1))) &&
           all(vapply(NOM[c("DW", "Runs")], function(n) {
             l <- ligne(tbe, n)
             is.finite(l$p_exacte) && grepl("a la tolerance TOL_DELTA_BORD", l$detail, fixed = TRUE)
           }, logical(1))))

## --- 6. Spearman avec ex aequo a pi_t constant ------------------------------
verifier("Reference : cor.test(exact = TRUE) avec ex aequo rend la p asymptotique (5,30e-7)",
         {
           a <- suppressWarnings(stats::cor.test(c(1, 1, 2:7), 1:8, method = "spearman",
                                                 exact = TRUE)$p.value)
           b <- suppressWarnings(stats::cor.test(c(1, 1, 2:7), 1:8, method = "spearman",
                                                 exact = FALSE)$p.value)
           identical(a, b) && isTRUE(proche(a, 5.296154e-07, rel = 1e-6))
         })
verifier("Reference : loi de permutation conditionnelle enumeree (8!) : p = 4 / 40 320",
         {
           perms <- function(n) {
             if (n == 1) return(matrix(1L))
             p <- perms(n - 1)
             do.call(rbind, lapply(1:n, function(i) { q <- p; q[q >= i] <- q[q >= i] + 1L; cbind(i, q) }))
           }
           P <- perms(8); rx <- rank(c(1, 1, 2:7)); ry <- 1:8
           S <- rowSums((matrix(rx[P], nrow(P)) - matrix(ry, nrow(P), 8, byrow = TRUE))^2)
           Sobs <- sum((rx - ry)^2); ES <- mean(S)
           nrow(P) == 40320L && sum(abs(S - ES) >= abs(Sobs - ES) - 1e-9) == 4L
         })
y2 <- y; y2[2] <- x[2] * y[1] / x[1]                 # r_2 = r_1
f2 <- usp_ajuster(x, y2); t2 <- usp_tests(f2, boot_fictif(f2), methode = "premium")
x3 <- x; x3[2] <- x[1]; y3 <- y * x3 / x              # x_2 = x_1, ratios conserves
f3 <- usp_ajuster(x3, y3); t3 <- usp_tests(f3, boot_fictif(f3), methode = "premium")
verifier("Ex aequo : les deux jeux sont a pi_t exactement constant",
         isTRUE(usp_regime(f2$delta, f2$x)$pi_constant_exact) &&
           isTRUE(usp_regime(f3$delta, f3$x)$pi_constant_exact) &&
           anyDuplicated(y2 / x) > 0 && anyDuplicated(x3) > 0 && anyDuplicated(y3 / x3) == 0)
verifier("Ex aequo dans r : Spearman x2 et MK -> p_exacte NA, Monte-Carlo, p_asymptotique exact = FALSE, 'ex aequo dans r' (Spearman-temps : diagnostic par decision, #299, motif ex aequo joint par usp_tests())",
         {
           r2 <- y2 / x
           p_as <- list(SpearVol = suppressWarnings(stats::cor.test(r2, x, method = "spearman",
                                                                    exact = FALSE)$p.value),
                        SpearTps = suppressWarnings(stats::cor.test(r2, seq_along(r2), method = "spearman",
                                                                    exact = FALSE)$p.value))
           all(vapply(c("SpearVol", "SpearTps", "MK"), function(k) {
             l <- ligne(t2, NOM[[k]])
             is.na(l$p_exacte) && is.na(l$p_min) &&
               (if (k %in% DIAG_299) est_diag_299(l) && grepl(MOTIF_EA_R, l$detail, fixed = TRUE)
                else identical(l$nature_p, NAT_MC) && grepl("ex aequo dans r", l$detail, fixed = TRUE)) &&
               (k == "MK" || identical(l$p_asymptotique, p_as[[k]]))
           }, logical(1)))
         })
verifier("Ex aequo dans x : Spearman-volume NA et 'ex aequo dans x' ; Spearman-temps p exacte calculee (diagnostic par decision, #299)",
         {
           lv <- ligne(t3, NOM[["SpearVol"]]); lt <- ligne(t3, NOM[["SpearTps"]])
           r3 <- y3 / x3
           is.na(lv$p_exacte) && identical(lv$nature_p, NAT_MC) &&
             grepl("ex aequo dans x", lv$detail, fixed = TRUE) &&
             est_diag_299(lt) &&
             identical(lt$p_exacte, stats::cor.test(r3, seq_along(r3), method = "spearman",
                                                    exact = TRUE)$p.value)
         })

## --- 7. Spearman a T > 9 : developpement d'Edgeworth, pas de p exacte --------
x10 <- c(x, 125.10, 108.70); y10 <- c(y, 91.33, 80.12)
f10 <- fit_force(x10, y10, 1)
t10 <- usp_tests(f10, boot_fictif(f10), methode = "premium")
verifier("T = 10 : pi_t exactement constant, sans ex aequo",
         isTRUE(usp_regime(f10$delta, f10$x)$pi_constant_exact) &&
           anyDuplicated(y10 / x10) == 0 && anyDuplicated(x10) == 0)
verifier("T = 10 : Spearman x2 -> p_exacte NA, detail 'Edgeworth' (prho.c, n_small = 9) ; MK reste exacte ; Spearman-temps diagnostic (#299)",
         all(vapply(c("SpearVol", "SpearTps"), function(k) {
           l <- ligne(t10, NOM[[k]])
           is.na(l$p_exacte) && grepl("Edgeworth", l$detail, fixed = TRUE) &&
             (if (k %in% DIAG_299) est_diag_299(l) else identical(l$nature_p, NAT_MC))
         }, logical(1))) &&
           identical(ligne(t10, NOM[["MK"]])$nature_p, "exacte"))
# T = 10 avec un ex aequo dans r : les deux motifs (Edgeworth et ex aequo).
y10e <- y10; y10e[2] <- x10[2] * y10[1] / x10[1]
f10e <- fit_force(x10, y10e, 1)
t10e <- usp_tests(f10e, boot_fictif(f10e), methode = "premium")
verifier("T = 10, ex aequo dans r : Spearman x2 -> p_exacte et p_min NA, detail 'Edgeworth' et 'ex aequo dans r' (Spearman-temps, diagnostic #299 : motif joint par usp_tests())",
         anyDuplicated(y10e / x10) > 0 &&
           all(vapply(c("SpearVol", "SpearTps"), function(k) {
             l <- ligne(t10e, NOM[[k]])
             is.na(l$p_exacte) && is.na(l$p_min) && grepl("Edgeworth", l$detail, fixed = TRUE) &&
               (if (k %in% DIAG_299) est_diag_299(l) && grepl(MOTIF_EA_R, l$detail, fixed = TRUE)
                else grepl("ex aequo dans r", l$detail, fixed = TRUE))
           }, logical(1))))

## --- 8. add() seul : restitution du motif de l'absence de p_min -------------
reg <- engine_registre_tests(boot_fictif(fit), USP_CATALOGUE_MC, 0.10, NAT_MC)
reg$add("F", "a", "r", fonction = "usp_tests", detail = "base.", p_as = 0.5, p_min = NA_real_, effectifs = "motif X")
reg$add("F", "b", "r", fonction = "usp_tests", detail = "base.", p_as = 0.5, p_min = NA_real_)
reg$add("F", "c", "r", fonction = "usp_tests", type = "non applicable", detail = "base.", p_min = NA_real_,
        effectifs = "motif X")
# Ligne d : p exacte (p_min associee a une p non simulee seule refusee
# depuis #181).
reg$add("F", "d", "r", fonction = "usp_tests", detail = "base", p_ex = 0.5, p_min = 0.001, effectifs = "motif X")
reg$add("F", "e", "r", fonction = "usp_tests", p_as = 0.5, p_min = NA_real_, effectifs = "motif X")
L <- reg$lignes()
verifier("add() : p_min NA et effectifs renseignes -> detail termine par le motif",
         identical(L[[1]]$detail, "base. motif X") && identical(L[[5]]$detail, "motif X"))
verifier("add() : effectifs NA, ligne non applicable, p_min finie -> detail inchange",
         identical(L[[2]]$detail, "base.") && identical(L[[3]]$detail, "base.") &&
           identical(L[[4]]$detail, "base"))

## --- 9. Cas limite 5c : pi_t variable et ex aequo de Cox-Stuart -------------
# y[5] tel que r_5 = r_1 : difference nulle dans la premiere paire (m = 3).
# (La mutation y[2] de la consigne ne cree pas d'ex aequo DANS UNE PAIRE de
# Cox-Stuart a T = 8 : paires (1,5), (2,6), (3,7), (4,8).)
y9 <- y8; y9[5] <- x8[5] * y8[1] / x8[1]
f9 <- usp_ajuster(x8, y9)
b9 <- boot_fictif(f9, motif = c(CoxStuart = "statistique observee non definie : ex aequo"))
verifier("5c : pi_t variable et m = 3 < n_p = 4",
         !isTRUE(usp_regime(f9$delta, f9$x)$pi_constant) &&
           test_cox_stuart(y9 / x8)$m == 3L && test_cox_stuart(y9 / x8)$n_p == 4L)
verifier("5c, alpha = 0,10 : Cox-Stuart INFO par la regle R1 (p_min = 0,25), les deux motifs dans detail",
         {
           l <- ligne(usp_tests(f9, b9, methode = "premium"), NOM[["CoxStuart"]])
           identical(l$type, "diagnostic") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             is.na(l$p_exacte) && is.na(l$p_mc) &&
             startsWith(l$detail, "TEST INOPERANT") &&
             grepl(TXT_R8, l$detail, fixed = TRUE) &&
             grepl("replications sans ex aequo", l$detail, fixed = TRUE)
         })
# alpha = 0,29 et non 0,30 : run_engine() exige alpha < SEUIL_ECHEC_SENS_REJETER.
verifier("5c, alpha = 0,29 (R1 non declenchee) : type test, INFO, p_retenue et nature_p NA, les deux motifs",
         {
           l <- ligne(usp_tests(f9, b9, alpha = 0.29, methode = "premium"), NOM[["CoxStuart"]])
           identical(l$type, "test") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             is.na(l$nature_p) && is.na(l$p_exacte) && is.na(l$p_mc) &&
             grepl(TXT_R8, l$detail, fixed = TRUE) &&
             grepl("replications sans ex aequo", l$detail, fixed = TRUE)
         })
verifier("Cox-Stuart, alpha = 0,29 : donnees de test -> 'exacte', p_retenue = cx$p ; fixture T = 8 a pi_t variable -> Monte-Carlo",
         {
           a <- ligne(usp_tests(fit, boot_fictif(fit), alpha = 0.29, methode = "premium"), NOM[["CoxStuart"]])
           b <- ligne(usp_tests(f8, boot_fictif(f8), alpha = 0.29, methode = "premium"), NOM[["CoxStuart"]])
           identical(a$type, "test") && identical(a$nature_p, "exacte") &&
             identical(a$p_retenue, test_cox_stuart(y / x)$p) &&
             identical(b$type, "test") && identical(b$nature_p, NAT_MC) && is.na(b$p_exacte)
         })

## --- 10. Invariants --------------------------------------------------------
# T = 5 : 40 lignes (Smirnov et Ljung-Box au retard 2 exigent T >= 8),
# nombre inchange par #70 ; 42 a T >= 8 depuis #302 (Shapiro-Wilk a loi
# nulle simulee, Ljung-Box (1) et Box-Pierce (2) retirees ; Box-Pierce (2)
# n'existait qu'a T >= 8).
verifier("Invariants : 42 lignes usp_tests() a T >= 8 dans tous les regimes testes, 40 a T = 5 (LB1r retiree, #303 ; trois lignes retirees, #302)",
         all(vapply(list(tt, t8, tb, t2, t3, t10), length, integer(1)) == 42L) &&
           length(t5) == 40L)
verifier("Invariant M7 : hors test, verdict INFO et sens NA",
         all(vapply(c(tt, t5, t8, tb), function(l)
           identical(l$type, "test") ||
             (identical(l$verdict, "INFO") && is.na(l$sens) && is.na(l$p_retenue)),
           logical(1))))
res8 <- run_engine(xt = x8, yt = y8, methode = "premium", segment = 1, annexe = "II",
                   nature_donnees = "brutes", B = 99, seed = 20260831)
verifier("run_engine, pi_t variable, B = 99 : 47 lignes hors lecture conjointe (#45 ; LB1r retiree, #303 ; trois lignes retirees, #302 ; lignes de famille de #297 en fin), catalogue complet, aucune nature 'exacte' sur les sept",
         isTRUE(res8$ok) &&
           sum(vapply(res8$tests, function(l) !identical(l$fonction, "engine_p_famille"), NA)) == 47L &&
           identical(names(res8$bootstrap$p_mc), names(USP_CATALOGUE_MC)) &&
           !any(vapply(res8$tests, function(l)
             l$test %in% NOM && identical(l$nature_p, "exacte"), logical(1))))

## --- 11. Regle R15 (#303) : lignes sur ratios bruts a pi_t constant ---------
# A pi_t constant (regime$pi_constant, bande TOL_DELTA_BORD comprise), DWr,
# Runsr, supFr, CUSUMr et Grubbsr sont restituees en diagnostic par
# usp_tests() : verdict INFO, ni p retenue, ni nature, ni sens, inoperant
# FALSE, p-values conservees, detail = motif actuel puis phrase fixe de R15.
# A pi_t variable (jeu J2, delta estime interieur ; f8), elles restent des
# tests. Ljung-Box (1) sur ratios bruts (LB1r) est retiree dans tous les
# regimes, avec son entree de catalogue.
NOM_R15 <- c(DWr = "Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts",
             Runsr = "Test des suites sur ratios bruts",
             supFr = "Rupture de niveau (sup-F) sur ratios bruts",
             CUSUMr = "Stabilite cumulee (OLS-CUSUM) sur ratios bruts",
             Grubbsr = "Valeur aberrante isolee (Grubbs) sur ratios bruts")
TXT_R15 <- paste("Restituee en diagnostic (regle R15) : aucun verdict ni p-value",
                 "retenue ; l'hypothese releve de la ligne homologue sur residus",
                 "standardises, dont le type et le verdict font foi.")
NOM_LB1R <- "Ljung-Box (retard 1) sur ratios bruts"
j2 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln_interieur.csv"))
fj2 <- usp_ajuster(j2$xt, j2$yt)
tj2 <- usp_tests(fj2, boot_fictif(fj2), methode = "premium")
est_r15 <- function(l) identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
  is.na(l$p_retenue) && is.na(l$nature_p) && is.na(l$sens) && isFALSE(l$inoperant) &&
  identical(l$p_mc, 0.5) && endsWith(l$detail, TXT_R15) &&
  grepl("CONTROLE SANS OBJET ICI", l$detail, fixed = TRUE)
verifier("R15 (#303) : pi_t exactement constant (delta = 1) et bande de tolerance, cinq lignes en diagnostic R15",
         isTRUE(usp_regime(fit$delta, fit$x)$pi_constant_exact) &&
           isTRUE(usp_regime(fb$delta, fb$x)$pi_constant) &&
           all(vapply(list(tt, tb), function(t)
             all(vapply(NOM_R15, function(n) est_r15(ligne(t, n)), logical(1))), logical(1))))
verifier("R15 (#303) : la ligne Runsr a pi_t constant garde sa p exacte et sa p_min, sans renvoi a nature_p",
         {
           b <- ligne(tt, NOM_R15[["Runsr"]])
           is.finite(b$p_exacte) && is.finite(b$p_min) &&
             !grepl(PHRASE_RENVOI_NATURE_P, b$detail, fixed = TRUE) &&
             !grepl(PHRASE_RENVOI_NATURE_P, ligne(tb, NOM_R15[["Runsr"]])$detail, fixed = TRUE)
         })
verifier("R15 (#303) : pi_t variable (jeu J2, delta interieur ; f8), cinq lignes de type test, p Monte-Carlo retenue, sans phrase R15",
         {
           ok <- vapply(list(tj2, t8), function(t) all(vapply(NOM_R15, function(n) {
             l <- ligne(t, n)
             identical(l$type, "test") && identical(l$nature_p, NAT_MC) && identical(l$p_retenue, 0.5) &&
               !grepl("regle R15", l$detail, fixed = TRUE)
           }, logical(1))), logical(1))
           !isTRUE(usp_regime(fj2$delta, fj2$x)$pi_constant) && fj2$delta > 0 && fj2$delta < 1 && all(ok)
         })
verifier("R15 (#303) : Ljung-Box (1) sur ratios bruts retiree dans tous les regimes, entree LB1r retiree du catalogue",
         !"LB1r" %in% names(USP_CATALOGUE_MC) &&
           !any(vapply(c(tt, tb, t8, tj2, t5), function(l) identical(l$test, NOM_LB1R), logical(1))))
# Priorite des motifs non applicables : statistique observee non finie
# (motif MOTIF_MC_OBS_NON_FINIE, Runsr d'un seul cote de la mediane compris)
# -> la ligne reste non applicable, sans phrase de R15.
verifier("R15 (#303) : statistique observee non finie a pi_t constant, ligne non applicable sans phrase R15",
         {
           b <- boot_fictif(fit, motif = c(DWr = MOTIF_MC_OBS_NON_FINIE, Runsr = MOTIF_MC_OBS_NON_FINIE))
           b$stats_obs$DWr <- NA_real_; b$stats_obs$Runsr <- NA_real_
           t <- usp_tests(fit, b, methode = "premium")
           all(vapply(NOM_R15[c("DWr", "Runsr")], function(n) {
             l <- ligne(t, n)
             identical(l$type, "non applicable") && !grepl("regle R15", l$detail, fixed = TRUE)
           }, logical(1))) && est_r15(ligne(t, NOM_R15[["supFr"]]))
         })
# p Monte-Carlo absente a pi_t constant : diagnostic R15, le motif en tete du
# detail, sous la forme de sa classe comme dans add() (degenerescence :
# "<motif> : aucune p-value retenue (ADR 0001)." ; autre motif :
# "Monte-Carlo indisponible : <motif>."), la phrase de R15 en fin.
verifier("R15 (#303) : p Monte-Carlo absente a pi_t constant, diagnostic R15 avec le motif en tete",
         {
           b <- boot_fictif(fit, motif = c(CUSUMr = MOTIF_MC_DISPERSION_NULLE, Runsr = MOTIF_MC_AUCUNE_REPLIC))
           t <- usp_tests(fit, b, methode = "premium")
           l <- ligne(t, NOM_R15[["CUSUMr"]]); r <- ligne(t, NOM_R15[["Runsr"]])
           identical(l$type, "diagnostic") && is.na(l$p_mc) && is.na(l$p_retenue) &&
             startsWith(l$detail, paste0(MOTIF_MC_DISPERSION_NULLE, " : aucune p-value retenue (ADR 0001).")) &&
             endsWith(l$detail, TXT_R15) &&
             # Runsr, regime 1 sans p_mc : p exacte conservee, phrase de R15
             # jointe apres le point final (" ", jamais " ; ").
             identical(r$type, "diagnostic") && is.finite(r$p_exacte) && is.na(r$p_retenue) &&
             startsWith(r$detail, "Monte-Carlo indisponible : aucune replication finie (B_effectif = 0).") &&
             !grepl(": aucune p-value retenue (ADR 0001)", r$detail, fixed = TRUE) &&
             grepl(paste("(issue #29).", TXT_R15), r$detail, fixed = TRUE)
         })
# La phrase de R15 renvoie au type et au verdict de la ligne homologue, qui
# peut elle-meme etre sans verdict : T = 5 a volumes constants, suites sur z
# en test inoperant (R1, p_min = 2/3 >= alpha) ; J1 a B = 40 (aucune p_mc,
# motif replications insuffisantes), sup-F sur z en test sans p-value (INFO)
# et DW sur z en test a p exacte (mesure du 19/10/2026 : OK, p = 0,565).
verifier("R15 (#303) : T = 5 a volumes constants, Runsr porte la phrase R15 pendant que les suites sur z sont un test inoperant",
         {
           f5c <- usp_ajuster(rep(100, 5), c(66, 70, 75, 82, 91))
           t5c <- usp_tests(f5c, boot_fictif(f5c), methode = "premium")
           a <- ligne(t5c, "Test des suites (aleatoire des signes)"); r <- ligne(t5c, NOM_R15[["Runsr"]])
           isTRUE(usp_regime(f5c$delta, f5c$x)$pi_constant_exact) &&
             isTRUE(a$inoperant) && identical(a$type, "diagnostic") &&
             identical(r$type, "diagnostic") && isFALSE(r$inoperant) && endsWith(r$detail, TXT_R15)
         })
verifier("R15 (#303) : J1 a B = 40, DWr et supFr portent la phrase R15 ; homologues sur z : sup-F test INFO sans p retenue, DW test a p exacte",
         {
           j1 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
           fj1 <- usp_ajuster(j1$xt, j1$yt)
           tj1 <- usp_tests(fj1, usp_bootstrap(fj1, B = 40, seed = 20260831), methode = "premium")
           dz <- ligne(tj1, "Autocorrelation d'ordre 1 (Durbin-Watson)"); sz <- ligne(tj1, "Rupture de niveau (sup-F)")
           dr <- ligne(tj1, NOM_R15[["DWr"]]); sr <- ligne(tj1, NOM_R15[["supFr"]])
           isTRUE(usp_regime(fj1$delta, fj1$x)$pi_constant) &&
             all(vapply(list(dr, sr), function(l)
               identical(l$type, "diagnostic") && is.na(l$p_mc) && endsWith(l$detail, TXT_R15) &&
                 startsWith(l$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_REPLIC_INSUFFISANTES, ".")),
               logical(1))) &&
             identical(sz$type, "test") && identical(sz$verdict, "INFO") && is.na(sz$p_retenue) &&
             identical(dz$type, "test") && identical(dz$nature_p, "exacte") && is.finite(dz$p_retenue)
         })

## --- 12. #302 : batterie H3/H4 ----------------------------------------------
# Decisions du mainteneur du 19/10/2026 (Q-D1-Fh-4, Q-D1-Fh-9 ; specification
# Fh, section 5) : Shapiro-Wilk a loi nulle simulee, Ljung-Box (retard 1) et
# Box-Pierce (retard 2) retirees dans tous les regimes, avec les entrees LB1
# et BP2 du catalogue ; Kolmogorov-Smirnov contre N(0,1) et Cramer-von Mises
# en diagnostic par decision dans tous les regimes (p-values conservees,
# phrase fixe en fin de detail, motif Monte-Carlo en tete s'il manque une
# p_mc) ; a pi_t variable, phrase fixe sur les lignes H3 dont la p non
# simulee est calculee ; Anscombe-Glynn non applicable a pi_t variable
# (T >= 20).
NOM_RETIRES_302 <- c("Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston)",
                     "Ljung-Box (retard 1)", "Box-Pierce (retard 2)")
NOM_DIAG_302 <- c(KS = "Kolmogorov-Smirnov contre N(0,1)", CvM = "Cramer-von Mises")
TXT_DIAG_302 <- c(
  KS = paste("Restituee en diagnostic par decision (issue #302) : aucun verdict ni",
             "p-value retenue ; l'hypothese releve de la ligne Lilliefors (distance",
             "de Kolmogorov sur residus re-standardises), dont le type et le",
             "verdict font foi."),
  CvM = paste("Restituee en diagnostic par decision (issue #302) : aucun verdict ni",
              "p-value retenue ; W2 etant tres correlee a A2, l'hypothese releve de",
              "la ligne Anderson-Darling, dont le type et le verdict font foi."))
NOM_H3_302 <- c(SW = "Shapiro-Wilk sur residus standardises", SF = "Shapiro-Francia",
                AD = "Anderson-Darling", Lillie = "Lilliefors (KS a parametres estimes)",
                JB = "Jarque-Bera", DAgo = "Asymetrie (D'Agostino, T >= 8)")
TXT_H3_302 <- paste("p non simulee etablie pour un echantillon i.i.d. normal, que",
                    "z = P epsilon ne verifie pas a pi_t variable : restituee pour",
                    "information, jamais retenue.")
NOM_AG <- "Aplatissement (Anscombe-Glynn, T >= 20)"
est_diag_302 <- function(l, k) identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
  is.na(l$p_retenue) && is.na(l$nature_p) && is.na(l$sens) && isFALSE(l$inoperant) &&
  identical(l$p_mc, 0.5) && is.finite(l$p_asymptotique) && endsWith(l$detail, TXT_DIAG_302[[k]])
verifier("#302 : trois lignes retirees dans tous les regimes (T = 8 et T = 5), entrees LB1 et BP2 retirees du catalogue",
         !any(c("LB1", "BP2") %in% names(USP_CATALOGUE_MC)) &&
           !any(vapply(c(tt, tb, t8, tj2, t5), function(l) l$test %in% NOM_RETIRES_302, logical(1))) &&
           !any(vapply(res8$tests, function(l) l$test %in% NOM_RETIRES_302, logical(1))) &&
           # sw_p_loi_nulle() reste une fonction du moteur (appelee par mw_tests()).
           is.function(sw_p_loi_nulle))
verifier("#302 : KS contre N(0,1) et Cramer-von Mises en diagnostic par decision, pi_t constant (exact et bande) et variable (f8, J2)",
         all(vapply(list(tt, tb, t8, tj2), function(t)
           all(vapply(names(NOM_DIAG_302), function(k) est_diag_302(ligne(t, NOM_DIAG_302[[k]]), k), logical(1))),
           logical(1))))
# Errata du 19/10/2026 de la specification Fh (section 5.1) : le renvoi
# "Voir le test de Lilliefors ci-dessus." est retire du detail propre de KS.
verifier("#302 : KS a pi_t constant, detail propre (sans renvoi a Lilliefors) suivi de la phrase fixe ; CvM, phrase fixe seule",
         identical(ligne(tt, NOM_DIAG_302[["KS"]])$detail,
                   paste("Les residus sont standardises par le MODELE, non par la moyenne",
                         "et l'ecart-type empiriques : la loi de Kolmogorov reste tres",
                         "conservatrice (simulation : 0 rejet sur 3 000 a 5 %).",
                         TXT_DIAG_302[["KS"]])) &&
           identical(ligne(tt, NOM_DIAG_302[["CvM"]])$detail, TXT_DIAG_302[["CvM"]]))
verifier("#302 : a pi_t variable (f8, J2), phrase H3 sur SW, SF, AD, Lilliefors, JB, D'Agostino (tests, p Monte-Carlo retenue) et avant la phrase fixe de KS et CvM",
         all(vapply(list(t8, tj2), function(t)
           all(vapply(NOM_H3_302, function(n) {
             l <- ligne(t, n)
             identical(l$type, "test") && identical(l$p_retenue, 0.5) && is.finite(l$p_asymptotique) &&
               grepl(TXT_H3_302, l$detail, fixed = TRUE)
           }, logical(1))) &&
             all(vapply(names(NOM_DIAG_302), function(k)
               grepl(paste(TXT_H3_302, TXT_DIAG_302[[k]]), ligne(t, NOM_DIAG_302[[k]])$detail, fixed = TRUE),
               logical(1))), logical(1))))
verifier("#302 : a pi_t constant (exact et bande), aucune ligne ne porte la phrase H3",
         !any(vapply(c(tt, tb), function(l) grepl(TXT_H3_302, l$detail, fixed = TRUE), logical(1))))
verifier("#302 : a T = 5 (pi_t variable), Anderson-Darling et Cramer-von Mises sans p non simulee ne portent pas la phrase H3",
         all(vapply(c("Anderson-Darling", NOM_DIAG_302[["CvM"]]), function(n) {
           l <- ligne(t5, n); is.na(l$p_asymptotique) && !grepl(TXT_H3_302, l$detail, fixed = TRUE)
         }, logical(1))) && grepl(TXT_H3_302, ligne(t5, NOM_H3_302[["SW"]])$detail, fixed = TRUE))
# p Monte-Carlo absente : motif en tete du detail, forme de sa classe comme
# dans add() ; statistique observee non finie : la ligne reste non
# applicable (add()), sans phrase fixe.
verifier("#302 : KS et CvM sans p Monte-Carlo, motif en tete selon sa classe ; statistique observee non finie -> non applicable",
         {
           b <- boot_fictif(fit, motif = c(KS = MOTIF_MC_DISPERSION_NULLE, CvM = MOTIF_MC_AUCUNE_REPLIC))
           t <- usp_tests(fit, b, methode = "premium")
           k <- ligne(t, NOM_DIAG_302[["KS"]]); w <- ligne(t, NOM_DIAG_302[["CvM"]])
           b2 <- boot_fictif(fit, motif = c(KS = MOTIF_MC_OBS_NON_FINIE)); b2$stats_obs$KS <- NA_real_
           k2 <- ligne(usp_tests(fit, b2, methode = "premium"), NOM_DIAG_302[["KS"]])
           identical(k$type, "diagnostic") && is.na(k$p_mc) &&
             startsWith(k$detail, paste0(MOTIF_MC_DISPERSION_NULLE, " : aucune p-value retenue (ADR 0001).")) &&
             endsWith(k$detail, TXT_DIAG_302[["KS"]]) &&
             identical(w$type, "diagnostic") && is.na(w$p_mc) &&
             identical(w$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_AUCUNE_REPLIC, ". ",
                                        TXT_DIAG_302[["CvM"]])) &&
             identical(k2$type, "non applicable") && !grepl("issue #302", k2$detail, fixed = TRUE)
         })
# Critere (d) de la specification Fh (section 5) : jeu J2 etendu a T = 20
# (x et y de J2, puis 1,05 x et 0,95 x des huit et des quatre premieres
# annees, y perturbe de exp(0,04 sin(1,3 t)), t = 9..20) ; delta estime
# interieur (mesure du 19/10/2026 : 0,647). A pi_t variable, la ligne
# Anscombe-Glynn est non applicable (motif de la section 5.3, Z conserve,
# aucune p) ; sur les memes donnees ajustees a delta = 1 (pi_t exactement
# constant), elle reste un test a p d'approximation a n fini retenue.
x20 <- j2$xt[c(1:8, 1:8, 1:4)] * c(rep(1, 8), rep(1.05, 8), rep(0.95, 4))
y20 <- j2$yt[c(1:8, 1:8, 1:4)] * c(rep(1, 8), rep(1.05, 8), rep(0.95, 4)) *
  exp(c(rep(0, 8), 0.04 * sin(1.3 * (9:20))))
f20 <- usp_ajuster(x20, y20)
t20 <- usp_tests(f20, boot_fictif(f20), methode = "premium")
f20c <- fit_force(x20, y20, 1)
t20c <- usp_tests(f20c, boot_fictif(f20c), methode = "premium")
verifier("#302 (critere (d)) : J2 etendu a T = 20, pi_t variable -> Anscombe-Glynn non applicable, motif de la section 5.3, Z conserve, aucune p",
         {
           l <- ligne(t20, NOM_AG)
           !isTRUE(usp_regime(f20$delta, f20$x)$pi_constant) && f20$delta > 0 && f20$delta < 1 &&
             identical(l$type, "non applicable") && identical(l$verdict, "INFO") && is.finite(l$stat) &&
             is.na(l$p_asymptotique) && is.na(l$p_retenue) && is.na(l$nature_p) &&
             identical(l$detail, paste("approximation a n fini etablie pour un echantillon i.i.d. normal,",
                                       "sans objet a pi_t variable (z = P epsilon non i.i.d.) ; aucune",
                                       "p-value de Monte-Carlo prevue : test non applicable"))
         })
# Priorite du motif "T < 20" (constat C2 de l'audit leger de #302) : sur J2
# (T = 8, pi_t variable), la ligne Anscombe-Glynn reste non applicable au
# motif de T, non a celui de pi_t variable.
verifier("#302 : J2 (T = 8, pi_t variable), Anscombe-Glynn non applicable au motif T < 20, prioritaire sur celui de pi_t variable",
         identical(ligne(tj2, NOM_AG)$type, "non applicable") &&
           identical(ligne(tj2, NOM_AG)$detail, "T = 8 < 20 : test non defini"))
# Diagnostic de #181 a pi_t variable (p Monte-Carlo absente, motif non
# degenere) : la mention d'add() ("... non retenue (ADR 0001).") en tete,
# puis la phrase de la section 5.3 (avis d'actuary du 19/10/2026 : phrase
# maintenue sur un tel diagnostic).
verifier("#302 : J2, p Monte-Carlo de SW absente (motif non degenere), mention d'add() puis phrase de la section 5.3",
         {
           l <- ligne(usp_tests(fj2, boot_fictif(fj2, motif = c(SW = MOTIF_MC_REPLIC_INSUFFISANTES)),
                                methode = "premium"), NOM_H3_302[["SW"]])
           identical(l$type, "diagnostic") && is.na(l$p_retenue) && is.finite(l$p_asymptotique) &&
             identical(l$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_REPLIC_INSUFFISANTES,
                                        " ; p non simulee (loi du champ loi) non retenue (ADR 0001). ",
                                        TXT_H3_302))
         })
verifier("#302 (critere (d)) : memes donnees a delta = 1 (pi_t constant), Anscombe-Glynn test, p d'approximation a n fini retenue",
         {
           l <- ligne(t20c, NOM_AG)
           isTRUE(usp_regime(f20c$delta, f20c$x)$pi_constant_exact) && identical(l$type, "test") &&
             identical(l$nature_p, NATURE_APPROX_N_FINI) && is.finite(l$p_retenue) &&
             identical(l$p_retenue, test_anscombe_kurt(f20c$z)$p)
         })

## --- 13. #299 : lignes H1/H2, puissance enveloppe de H2 ----------------------
# Decision du mainteneur du 19/10/2026 (Q-D1-Fh-5, option (A) ; specification
# Fh, section 6) : Breusch-Pagan studentise (Koenker) reste un test et son
# detail porte la puissance enveloppe pi_env (usp_puissance_enveloppe_h2()) ;
# Breusch-Pagan 1979, White, Goldfeld-Quandt, Brown-Forsythe, Smirnov et
# Spearman ratio / temps sont des diagnostics par decision dans tous les
# regimes (phrases fixes, p-values conservees, inoperant FALSE) ; les motifs
# non applicables (volumes constants, White a moins de trois volumes
# distincts, partition de Smirnov, statistique non definie) priment.
# Valeurs de pi_env de la specification (section 6.2) : J1 (volumes de
# tests/donnees/donnees_ln.csv) 0,127 et 0,066 ; J2 (volumes de
# tests/donnees/donnees_ln_interieur.csv) 0,343 et 0,223, a alpha = 0,10 et
# 0,05 (mesure du 20/10/2026 : 0,126721 ; 0,065804 ; 0,343276 ; 0,222683 ;
# controle Monte-Carlo hors CI, R = 2e5, cite dans le message du commit).
PENV <- usp_puissance_enveloppe_h2
verifier("#299 : pi_env de J1 et J2 a 1e-3 pres (0,127 et 0,343 a alpha = 0,10 ; 0,066 et 0,223 a alpha = 0,05)",
         identical(x, c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)) &&
           identical(as.numeric(j2$xt), c(50, 80, 120, 200, 300, 150, 90, 60)) &&
           isTRUE(proche(PENV(x, 0.10), 0.127, abs = 1e-3)) &&
           isTRUE(proche(PENV(j2$xt, 0.10), 0.343, abs = 1e-3)) &&
           isTRUE(proche(PENV(x, 0.05), 0.066, abs = 1e-3)) &&
           isTRUE(proche(PENV(j2$xt, 0.05), 0.223, abs = 1e-3)))
verifier("#299 : pi_env invariante par x -> lambda x (lambda = 1e3 et 1e-3)",
         all(vapply(list(x, j2$xt), function(v)
           isTRUE(proche(PENV(1e3 * v, 0.10), PENV(v, 0.10), rel = 1e-9)) &&
             isTRUE(proche(PENV(1e-3 * v, 0.05), PENV(v, 0.05), rel = 1e-9)), logical(1))))
# Cache de pi_env (#358) : valeur rendue identique au calcul direct, cle
# exacte (un ulp sur un volume donne une autre entree).
verifier("#358 : cache de pi_env, valeur identique au calcul direct (J1, J2 ; alpha = 0,10 et 0,05), cle a un ulp pres",
         {
           ok <- all(vapply(list(x, j2$xt), function(v) all(vapply(c(0.10, 0.05), function(a)
             identical(PENV(v, a), .usp_puissance_enveloppe_h2_calcul(v, a)) &&
               identical(PENV(v, a), PENV(v, a)), logical(1))), logical(1)))
           x_ulp <- x; x_ulp[1] <- x_ulp[1] * (1 + .Machine$double.eps)
           cle <- function(v, a) paste(sprintf("%a", c(a, v)), collapse = " ")
           ok && !identical(cle(x, 0.10), cle(x_ulp, 0.10)) &&
             !is.null(.cache_pi_env[[cle(x, 0.10)]]) &&
             identical(PENV(x_ulp, 0.10), .usp_puissance_enveloppe_h2_calcul(x_ulp, 0.10))
         })
R_X <- c(1.1, 1.5, 2, 3, 5, 10, 20, 30)
penv_2n <- function(a) vapply(R_X, function(r) PENV(rep(c(1, r), each = 4), a), numeric(1))
verifier("#299 : pi_env >= alpha (J1, J2, plans a deux niveaux de R_x = 1,1 a 30 ; alpha = 0,10 et 0,05)",
         all(vapply(c(0.10, 0.05), function(a)
           all(c(PENV(x, a), PENV(j2$xt, a), penv_2n(a)) >= a), logical(1))))
verifier("#299 : pi_env strictement croissante sur les plans a deux niveaux, R_x = 1,1 a 30 (alpha = 0,10 et 0,05)",
         all(vapply(c(0.10, 0.05), function(a) all(diff(penv_2n(a)) > 0), logical(1))))
verifier("#299 : pi_env non calculee (NA) a volumes constants, a la tolerance TOL_DELTA_BORD comprise ; erreur sur une entree invalide",
         is.na(PENV(rep(110, 8), 0.10)) && is.na(PENV(110 * (1 + c(0, 5e-7, rep(0, 6))), 0.10)) &&
           leve_erreur(PENV(c(1, 2), 0.10)) && leve_erreur(PENV(c(1, -2, 3), 0.10)) &&
           leve_erreur(PENV(x, 0)) && leve_erreur(PENV(x, 1)) && leve_erreur(PENV(c(x, NA), 0.10)))
NOM_BP <- "Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)"
NOM_DIAG_299 <- c(BP79 = "Heteroscedasticite vs volume - Breusch-Pagan original (non robuste)",
                  White = "Heteroscedasticite (forme quadratique)",
                  GQ = "Egalite des variances petits vs gros volumes",
                  BF = "Homogeneite des dispersions (mediane)",
                  Smirnov = "Egalite des lois petits vs gros volumes (2 ech.)",
                  SpearTps = "Correlation ratio S/P vs temps")
TXT_H2_299 <- paste("Restituee en diagnostic par decision (issue #299) : aucun verdict ni",
                    "p-value retenue ; la structure de variance releve de la ligne",
                    "Breusch-Pagan studentise (Koenker), dont le type et le verdict font foi.")
TXT_DIAG_299 <- c(
  BP79 = TXT_H2_299, White = TXT_H2_299, GQ = TXT_H2_299, BF = TXT_H2_299,
  Smirnov = paste("Restituee en diagnostic par decision (issue #299) : aucun verdict ni",
                  "p-value retenue ; compare la position de z entre petits et gros",
                  "volumes, alternative de H1 plutot que de H2 ; l'hypothese H1 releve",
                  "des lignes de la famille B., dont le type et le verdict font foi."),
  SpearTps = paste("Restituee en diagnostic par decision (issue #299) : aucun verdict ni",
                   "p-value retenue ; meme alternative (tendance monotone du ratio) que la",
                   "ligne Mann-Kendall, dont le type et le verdict font foi."))
txt_penv <- function(xx, a = 0.10)
  sprintf(paste("Puissance maximale, au seuil alpha = %g, d'un test invariant de delta = 1",
                "contre delta = 0 ou de delta = 0 contre delta = 1 (ecart le plus grand",
                "de la famille de l'annexe XVII,",
                "limite des faibles coefficients de variation) : %.2f avec ces volumes ;",
                "un OK ne demontre pas la structure de variance."), a, PENV(xx, a))
est_ligne_299 <- function(l, k) est_diag_299(l) && is.na(l$sens) && identical(l$p_mc, 0.5) &&
  endsWith(l$detail, TXT_DIAG_299[[k]]) &&
  # Jonction par ". " (point final ajoute au detail propre s'il manque).
  !grepl(paste(";", TXT_DIAG_299[[k]]), l$detail, fixed = TRUE)
verifier("#299 : six lignes en diagnostic par decision, pi_t constant (exact et bande) et variable (f8, J2), phrase fixe en fin, p Monte-Carlo conservee",
         all(vapply(list(tt, tb, t8, tj2), function(t)
           all(vapply(names(NOM_DIAG_299), function(k) est_ligne_299(ligne(t, NOM_DIAG_299[[k]]), k),
                      logical(1))), logical(1))))
verifier("#299 : p exactes de Smirnov et Spearman-temps conservees a pi_t constant (R7), p non simulees conservees (BP79, White, GQ, BF, Spearman-temps)",
         all(vapply(c("Smirnov", "SpearTps"), function(k) is.finite(ligne(tt, NOM_DIAG_299[[k]])$p_exacte),
                    logical(1))) &&
           all(vapply(c("BP79", "White", "GQ", "BF", "SpearTps"), function(k)
             is.finite(ligne(tt, NOM_DIAG_299[[k]])$p_asymptotique), logical(1))))
verifier("#299 : details propres conserves avant la phrase fixe (BP79 ; Smirnov, point final ajoute ; Spearman-temps, phrase R8 a pi_t variable, suffixe de bande)",
         {
           b79 <- ligne(tt, NOM_DIAG_299[["BP79"]])$detail
           sm <- ligne(tt, NOM_DIAG_299[["Smirnov"]])$detail
           st8 <- ligne(t8, NOM_DIAG_299[["SpearTps"]])$detail
           stb <- ligne(tb, NOM_DIAG_299[["SpearTps"]])$detail
           identical(b79, paste("Version publiee, avec le facteur 1/2 issu de Var(u^2) = 2 sigma^4.",
                                "NON ROBUSTE : sur-rejette si les erreurs ne sont pas normales.",
                                TXT_H2_299)) &&
             grepl("(deux groupes totalement separes). Restituee en diagnostic", sm, fixed = TRUE) &&
             startsWith(st8, TXT_R8) && grepl(paste(TXT_R8, TXT_DIAG_299[["SpearTps"]]), st8, fixed = TRUE) &&
             grepl("a la tolerance TOL_DELTA_BORD", stb, fixed = TRUE) &&
             identical(ligne(tt, NOM_DIAG_299[["GQ"]])$detail, TXT_H2_299) &&
             identical(ligne(tt, NOM_DIAG_299[["SpearTps"]])$detail, TXT_DIAG_299[["SpearTps"]])
         })
verifier("#299 : Breusch-Pagan studentise reste un test, detail = phrase propre puis phrase de pi_env (alpha du calcul), pi_constant et variable",
         {
           ok <- function(t, xx, a = 0.10) {
             l <- ligne(t, NOM_BP)
             identical(l$type, "test") && identical(l$p_retenue, 0.5) && isFALSE(l$inoperant) &&
               startsWith(l$detail, paste("Doit etre non significatif si la ponderation pi_t est correcte.",
                                          txt_penv(xx, a)))
           }
           t05 <- usp_tests(fit, boot_fictif(fit), alpha = 0.05, methode = "premium")
           ok(tt, x) && ok(t8, x8) && ok(tj2, j2$xt) && ok(t05, x, 0.05) &&
             grepl("0.13 avec ces volumes", ligne(tt, NOM_BP)$detail, fixed = TRUE) &&
             grepl("0.34 avec ces volumes", ligne(tj2, NOM_BP)$detail, fixed = TRUE) &&
             grepl("alpha = 0.05,", ligne(t05, NOM_BP)$detail, fixed = TRUE)
         })
# Echec numerique de pi_env (#358, decision d'actuary) : calcul tente (volumes
# variables, statistique definie) et NA -> motif fixe a la place de la phrase
# de pi_env. NA provoque par substitution de .imhof_p_sup0() dans
# l'environnement du moteur (ADR 0016), sur des volumes x * 3 absents du
# cache ; substitution et entrees du cache retirees en sortie.
TXT_PENV_ECHEC <- paste(
  "Puissance maximale d'un test invariant de delta = 1 contre delta = 0 ou de delta = 0",
  "contre delta = 1 (famille de l'annexe XVII) non calculee avec ces volumes : echec",
  "numerique de l'integration d'Imhof ou de la recherche de racine",
  "(usp_puissance_enveloppe_h2()) ; un OK ne demontre pas la structure de variance.")
verifier("#358 : pi_env tentee et NA (echec numerique simule) -> motif fixe dans le detail de Breusch-Pagan studentise, sans la phrase de pi_env",
         local({
           env <- environment(run_engine)
           orig <- get(".imhof_p_sup0", envir = env)
           cache <- get(".cache_pi_env", envir = env)
           avant <- ls(cache, all.names = TRUE)
           on.exit({
             assign(".imhof_p_sup0", orig, envir = env)
             rm(list = setdiff(ls(cache, all.names = TRUE), avant), envir = cache)
           })
           assign(".imhof_p_sup0", function(...) NA_real_, envir = env)
           f3 <- usp_ajuster(3 * x, 3 * y)
           l <- ligne(usp_tests(f3, boot_fictif(f3), methode = "premium"), NOM_BP)
           identical(l$type, "test") && identical(l$p_retenue, 0.5) &&
             identical(l$detail, paste("Doit etre non significatif si la ponderation pi_t est correcte.",
                                       TXT_PENV_ECHEC)) &&
             !grepl("avec ces volumes ;", l$detail, fixed = TRUE)
         }))
verifier("#358 : substitution levee, pi_env de nouveau calculee sur 3 x (invariance d'echelle)",
         {
           f3 <- usp_ajuster(3 * x, 3 * y)
           startsWith(ligne(usp_tests(f3, boot_fictif(f3), methode = "premium"), NOM_BP)$detail,
                      paste("Doit etre non significatif si la ponderation pi_t est correcte.",
                            txt_penv(x, 0.10)))
         })
verifier("#299 : Spearman ratio / volume et Mann-Kendall restent des tests (H1)",
         all(vapply(list(tt, t8), function(t)
           all(vapply(c("Independance ratio S/P vs volume", "Tendance monotone du ratio S/P"),
                      function(n) identical(ligne(t, n)$type, "test"), logical(1))), logical(1))))
# Motif ex aequo sur un diagnostic de #299 (avis d'actuary du 20/10/2026) :
# ordre motif Monte-Carlo, detail propre, motif ex aequo (chaine effectifs
# de la ligne), phrase fixe ; absent sans ex aequo.
verifier("#299 : motif ex aequo joint par usp_tests() sur Spearman-temps (ex aequo dans r), apres le motif Monte-Carlo et avant la phrase fixe ; absent sans ex aequo",
         {
           st <- ligne(t2, NOM_DIAG_299[["SpearTps"]])$detail
           stm <- ligne(usp_tests(f2, boot_fictif(f2, motif = c(SpearTps = MOTIF_MC_AUCUNE_REPLIC)),
                                  methode = "premium"), NOM_DIAG_299[["SpearTps"]])$detail
           identical(st, paste0("T = 8 ; ", MOTIF_EA_R, ". ", TXT_DIAG_299[["SpearTps"]])) &&
             identical(stm, paste0("Monte-Carlo indisponible : ", MOTIF_MC_AUCUNE_REPLIC, ". T = 8 ; ",
                                   MOTIF_EA_R, ". ", TXT_DIAG_299[["SpearTps"]])) &&
             !grepl("ex aequo", ligne(tt, NOM_DIAG_299[["SpearTps"]])$detail, fixed = TRUE) &&
             !grepl("ex aequo", ligne(tt, NOM_DIAG_299[["Smirnov"]])$detail, fixed = TRUE)
         })
verifier("#299 : motif ex aequo joint par usp_tests() sur Smirnov (ex aequo dans z, pi_t variable), detail propre puis motif puis phrase fixe",
         {
           z_e <- f8$z; z_e[2] <- z_e[1]
           f8e <- f8; f8e$z <- z_e
           b <- boot_fictif(f8)
           l <- ligne(usp_tests(f8e, b, methode = "premium"), NOM_DIAG_299[["Smirnov"]])
           grp <- x8 > stats::median(x8)
           ea <- sprintf(paste("n1 = %d, n2 = %d ; ex aequo dans z : loi conditionnelle non attribuee,",
                               "p_min et p exacte non attribuees"), sum(grp), sum(!grp))
           est_diag_299(l) && is.na(l$p_min) &&
             identical(l$detail, paste(TXT_R8, "Voir aussi le QQ-plot a deux echantillons ;",
                                       paste0(ea, "."), TXT_DIAG_299[["Smirnov"]]))
         })
# Priorite des motifs non applicables (critere (c) de la section 6).
fvc <- usp_ajuster(rep(110, 8), y)
tvc <- usp_tests(fvc, boot_fictif(fvc), methode = "premium")
x2n <- rep(c(100, 150), each = 4)
f2n <- usp_ajuster(x2n, y * x2n / x)
t2n <- usp_tests(f2n, boot_fictif(f2n), methode = "premium")
xsm <- c(90, 100, 100, 100, 100, 100, 120, 130)
fsm <- usp_ajuster(xsm, y * xsm / x)
tsm <- usp_tests(fsm, boot_fictif(fsm), methode = "premium")
verifier("#299 : volumes constants, cinq lignes H2 et Breusch-Pagan Koenker non applicables (R13), sans phrase de #299 ni de pi_env ; Spearman-temps diagnostic",
         isTRUE(usp_regime(fvc$delta, fvc$x)$volumes_constants) &&
           all(vapply(c(NOM_BP, NOM_DIAG_299[c("BP79", "White", "GQ", "BF", "Smirnov")]), function(n) {
             l <- ligne(tvc, n)
             identical(l$type, "non applicable") && !grepl("issue #299", l$detail, fixed = TRUE) &&
               !grepl("Puissance maximale", l$detail, fixed = TRUE)
           }, logical(1))) &&
           est_ligne_299(ligne(tvc, NOM_DIAG_299[["SpearTps"]]), "SpearTps"))
verifier("#299 : White a moins de trois volumes distincts non applicable, sans phrase ; BP79, GQ, BF, Smirnov diagnostics",
         {
           w <- ligne(t2n, NOM_DIAG_299[["White"]])
           identical(w$type, "non applicable") && grepl("moins de trois volumes distincts", w$detail, fixed = TRUE) &&
             !grepl("issue #299", w$detail, fixed = TRUE) &&
             all(vapply(c("BP79", "GQ", "BF", "Smirnov"), function(k)
               est_ligne_299(ligne(t2n, NOM_DIAG_299[[k]]), k), logical(1)))
         })
verifier("#299 : partition de Smirnov a moins de trois annees non applicable, sans phrase",
         {
           l <- ligne(tsm, NOM_DIAG_299[["Smirnov"]])
           identical(l$type, "non applicable") && grepl("moins de 3 dans un groupe", l$detail, fixed = TRUE) &&
             !grepl("issue #299", l$detail, fixed = TRUE)
         })
verifier("#299 : statistique observee non finie (BP79, GQ, BP) -> non applicable sans phrase ; p Monte-Carlo absente -> motif en tete, phrase en fin",
         {
           b <- boot_fictif(fit, motif = c(BP79 = MOTIF_MC_OBS_NON_FINIE, BP = MOTIF_MC_OBS_NON_FINIE,
                                           GQ = MOTIF_MC_AUCUNE_REPLIC, BF = MOTIF_MC_DISPERSION_NULLE))
           b$stats_obs$BP79 <- NA_real_; b$stats_obs$BP <- NA_real_
           t <- usp_tests(fit, b, methode = "premium")
           a <- ligne(t, NOM_DIAG_299[["BP79"]]); k <- ligne(t, NOM_BP)
           g <- ligne(t, NOM_DIAG_299[["GQ"]]); f <- ligne(t, NOM_DIAG_299[["BF"]])
           identical(a$type, "non applicable") && !grepl("issue #299", a$detail, fixed = TRUE) &&
             !grepl("Puissance maximale", k$detail, fixed = TRUE) &&
             identical(g$type, "diagnostic") &&
             identical(g$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_AUCUNE_REPLIC, ". ", TXT_H2_299)) &&
             identical(f$type, "diagnostic") &&
             startsWith(f$detail, paste0(MOTIF_MC_DISPERSION_NULLE, " : aucune p-value retenue (ADR 0001).")) &&
             endsWith(f$detail, TXT_H2_299)
         })

fin_fichier()
