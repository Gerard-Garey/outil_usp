###############################################################################
#  tests/unitaires/test_regimes_p_exactes.R  --  P-VALUES EXACTES SELON LE
#                                                 REGIME DE pi_t (ISSUE #70)
#
#  Consigne d'actuary du 27/09/2026 (etape 4 d'E1), regles R7, R8, R9 amendee,
#  2b, 2c et 5a-5c :
#    - les huit lignes a loi de reference exacte (Durbin-Watson, suites,
#      Shapiro-Wilk loi nulle, Smirnov, Spearman volume et temps,
#      Mann-Kendall, Cox-Stuart) n'ont de p exacte qu'a pi_t constant ;
#    - Spearman : aucune p exacte avec ex aequo, ni a T > 9 ;
#    - add() restitue dans detail le motif d'absence de p_min.
#  References : appels directs des fonctions de loi exacte (dw_p_exacte,
#  runs_p_exacte, sw_p_loi_nulle, mk_p_exacte, stats::ks.test,
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
  s <- .stats_bootstrapables(f$x, f$y, f$z)
  pm <- stats::setNames(rep(p, length(s)), names(s))
  mm <- stats::setNames(rep(NA_character_, length(s)), names(s))
  if (!is.null(motif)) { pm[names(motif)] <- NA_real_; mm[names(motif)] <- motif }
  list(stats_obs = as.list(s), p_mc = pm, err_mc = pm * 0 + 0.01, motif_mc = mm)
}
ligne <- function(tt, nom) Filter(function(l) identical(l$test, nom), tt)[[1]]
NOM <- c(DW = "Autocorrelation d'ordre 1 (Durbin-Watson)",
         Runs = "Test des suites (aleatoire des signes)",
         SWnul = "Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston)",
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
# Ajustement force a delta = 1 (pi_t exactement constant), gamma de
# usp_ajuster() ; meme construction que f29_bande (test_lois_exactes.R).
fit_force <- function(x, y, d) {
  g <- usp_ajuster(x, y)$gamma
  c(usp_noyau(d, g, x, y),
    list(delta = d, gamma = g, T = length(x), x = x, y = y, xbar = mean(x),
         convergence = 0L, part_starts_convergents = 1,
         delta_au_bord = usp_regime(d, x)$delta_au_bord))
}

## --- 1. pi_t exactement constant : huit p exactes, valeurs d'avant #70 -----
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
  else identical(l$nature_p, "exacte")
}
verifier("pi_t constant exact : sept lignes 'exacte' (Cox-Stuart inoperante, R1), p_exacte identique a l'appel direct",
         {
           z <- fit$z; r <- y / x; grp <- x > stats::median(x)
           W <- ligne(tt, NOM[["SWnul"]])$stat
           attendu <- list(
             DW = dw_p_exacte(z), Runs = runs_p_exacte(z), SWnul = sw_p_loi_nulle(W, 8),
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
verifier("T = 5 : DW, Spearman x2, MK -> p_exacte NA, Monte-Carlo retenue, detail commencant par R8",
         all(vapply(NOM[c("DW", "SpearVol", "SpearTps", "MK")], function(n) {
           l <- ligne(t5, n)
           is.na(l$p_exacte) && identical(l$nature_p, NAT_MC) && commence_par_r8(l$detail)
         }, logical(1))))
verifier("T = 5 : suites et Cox-Stuart -> p_exacte NA, INFO par la regle R1, phrase R8",
         all(vapply(NOM[c("Runs", "CoxStuart")], function(n) {
           l <- ligne(t5, n)
           is.na(l$p_exacte) && identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
             grepl("TEST INOPERANT", l$detail, fixed = TRUE) && grepl(TXT_R8, l$detail, fixed = TRUE)
         }, logical(1))))
verifier("T = 5 : Shapiro-Wilk loi nulle -> non applicable, p_exacte NA, INFO, W conserve",
         {
           l <- ligne(t5, NOM[["SWnul"]])
           identical(l$type, "non applicable") && is.na(l$p_exacte) && identical(l$verdict, "INFO") &&
             is.finite(l$stat) && grepl("sans objet a pi_t variable", l$detail, fixed = TRUE)
         })

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
verifier("T = 8 : huit lignes p_exacte NA",
         all(vapply(NOM, function(n) is.na(ligne(t8, n)$p_exacte), logical(1))))
verifier("T = 8 : six lignes Monte-Carlo retenue (type test) ; Cox-Stuart INFO par R1",
         all(vapply(NOM[c("DW", "Runs", "Smirnov", "SpearVol", "SpearTps", "MK")], function(n) {
           l <- ligne(t8, n); identical(l$type, "test") && identical(l$nature_p, NAT_MC)
         }, logical(1))) &&
           identical(ligne(t8, NOM[["CoxStuart"]])$type, "diagnostic") &&
           identical(ligne(t8, NOM[["CoxStuart"]])$verdict, "INFO"))
verifier("T = 8 : Shapiro-Wilk loi nulle non applicable ; phrase R8 sur les sept autres lignes",
         identical(ligne(t8, NOM[["SWnul"]])$type, "non applicable") &&
           all(vapply(NOM[names(NOM) != "SWnul"], function(n)
             grepl(TXT_R8, ligne(t8, n)$detail, fixed = TRUE), logical(1))))

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
verifier("Bande : huit lignes p_exacte finie, 'exacte' (Cox-Stuart : R1), detail suffixe 'a la tolerance TOL_DELTA_BORD'",
         all(vapply(names(NOM), function(k) {
           l <- ligne(tb, NOM[[k]])
           is.finite(l$p_exacte) && nature_attendue(tb, k) &&
             grepl("a la tolerance TOL_DELTA_BORD", l$detail, fixed = TRUE) &&
             !grepl("p exacte non attribuee", l$detail, fixed = TRUE)
         }, logical(1))))
verifier("Bande : ligne Runsr sans phrase R7/R8 (regime #29 inchange : p exacte NA, signes differents)",
         {
           l <- ligne(tb, "Test des suites sur ratios bruts")
           is.na(l$p_exacte) && identical(l$nature_p, NAT_MC) &&
             !grepl("p exacte non attribuee", l$detail, fixed = TRUE) &&
             !grepl("loi de reference exacte a un ecart", l$detail, fixed = TRUE)
         })
# #128, point c : la phrase "p-value Monte-Carlo ... est retenue" de la
# ligne Runsr (regimes 2, bande a signes differents, et 3, pi_t variable)
# n'est ecrite que si p_mc existe ; sinon la ligne, sans p exacte ni
# asymptotique, est un test sans p-value (phrase de #128 en tete).
verifier("Runsr, regimes 2 et 3 : p_mc presente -> 'est retenue' ; absente -> 'indisponible', test sans p-value",
         {
           txt_ind <- "est indisponible sur ces donnees ; la p-value retenue, s'il en est une, est nommee par nature_p"
           m <- c(Runsr = MOTIF_MC_AUCUNE_REPLIC)
           nm <- "Test des suites sur ratios bruts"
           a3 <- ligne(t8, nm)
           b3 <- ligne(usp_tests(f8, boot_fictif(f8, motif = m), methode = "premium"), nm)
           a2 <- ligne(tb, nm)
           b2 <- ligne(usp_tests(fb, boot_fictif(fb, motif = m), methode = "premium"), nm)
           grepl("Seule la p-value Monte-Carlo, simulee sous le modele ajuste avec ses pi_t, est retenue ;",
                 a3$detail, fixed = TRUE) &&
             grepl(paste("La p-value Monte-Carlo, simulee sous le modele ajuste avec ses pi_t,", txt_ind),
                   b3$detail, fixed = TRUE) && !grepl("est retenue", b3$detail, fixed = TRUE) &&
             grepl("Monte-Carlo, simulee sous le modele ajuste, est retenue.", a2$detail, fixed = TRUE) &&
             endsWith(b2$detail, paste0("Monte-Carlo, simulee sous le modele ajuste, ", txt_ind, ".")) &&
             !grepl("est retenue", b2$detail, fixed = TRUE) &&
             all(vapply(list(b2, b3), function(l)
               identical(l$type, "test") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
                 startsWith(l$detail, "Monte-Carlo indisponible : aucune replication finie"),
               logical(1)))
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
verifier("Bande avec ex aequo : Spearman x2 et MK sans p exacte ni suffixe de bande ; DW et suites avec",
         all(vapply(NOM[c("SpearVol", "SpearTps", "MK")], function(n) {
           l <- ligne(tbe, n)
           is.na(l$p_exacte) && grepl("ex aequo dans r", l$detail, fixed = TRUE) &&
             !grepl("a la tolerance TOL_DELTA_BORD", l$detail, fixed = TRUE)
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
verifier("Ex aequo dans r : Spearman x2 et MK -> p_exacte NA, Monte-Carlo, p_asymptotique exact = FALSE, 'ex aequo dans r'",
         {
           r2 <- y2 / x
           p_as <- list(SpearVol = suppressWarnings(stats::cor.test(r2, x, method = "spearman",
                                                                    exact = FALSE)$p.value),
                        SpearTps = suppressWarnings(stats::cor.test(r2, seq_along(r2), method = "spearman",
                                                                    exact = FALSE)$p.value))
           all(vapply(c("SpearVol", "SpearTps", "MK"), function(k) {
             l <- ligne(t2, NOM[[k]])
             is.na(l$p_exacte) && identical(l$nature_p, NAT_MC) &&
               grepl("ex aequo dans r", l$detail, fixed = TRUE) &&
               (k == "MK" || identical(l$p_asymptotique, p_as[[k]]))
           }, logical(1)))
         })
verifier("Ex aequo dans x : Spearman-volume NA et 'ex aequo dans x' ; Spearman-temps exacte",
         {
           lv <- ligne(t3, NOM[["SpearVol"]]); lt <- ligne(t3, NOM[["SpearTps"]])
           r3 <- y3 / x3
           is.na(lv$p_exacte) && identical(lv$nature_p, NAT_MC) &&
             grepl("ex aequo dans x", lv$detail, fixed = TRUE) &&
             identical(lt$nature_p, "exacte") &&
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
verifier("T = 10 : Spearman x2 -> p_exacte NA, detail 'Edgeworth' (prho.c, n_small = 9) ; MK reste exacte",
         all(vapply(NOM[c("SpearVol", "SpearTps")], function(n) {
           l <- ligne(t10, n)
           is.na(l$p_exacte) && identical(l$nature_p, NAT_MC) && grepl("Edgeworth", l$detail, fixed = TRUE)
         }, logical(1))) &&
           identical(ligne(t10, NOM[["MK"]])$nature_p, "exacte"))
# T = 10 avec un ex aequo dans r : les deux motifs (Edgeworth et ex aequo).
y10e <- y10; y10e[2] <- x10[2] * y10[1] / x10[1]
f10e <- fit_force(x10, y10e, 1)
t10e <- usp_tests(f10e, boot_fictif(f10e), methode = "premium")
verifier("T = 10, ex aequo dans r : Spearman x2 -> p_exacte et p_min NA, detail 'Edgeworth' et 'ex aequo dans r'",
         anyDuplicated(y10e / x10) > 0 &&
           all(vapply(NOM[c("SpearVol", "SpearTps")], function(n) {
             l <- ligne(t10e, n)
             is.na(l$p_exacte) && is.na(l$p_min) && grepl("Edgeworth", l$detail, fixed = TRUE) &&
               grepl("ex aequo dans r", l$detail, fixed = TRUE)
           }, logical(1))))

## --- 8. add() seul : restitution du motif de l'absence de p_min -------------
reg <- engine_registre_tests(boot_fictif(fit), USP_CATALOGUE_MC, 0.10, NAT_MC)
reg$add("F", "a", "r", fonction = "usp_tests", detail = "base.", p_as = 0.5, p_min = NA_real_, effectifs = "motif X")
reg$add("F", "b", "r", fonction = "usp_tests", detail = "base.", p_as = 0.5, p_min = NA_real_)
reg$add("F", "c", "r", fonction = "usp_tests", type = "non applicable", detail = "base.", p_min = NA_real_,
        effectifs = "motif X")
reg$add("F", "d", "r", fonction = "usp_tests", detail = "base", p_as = 0.5, p_min = 0.001, effectifs = "motif X")
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
# T = 5 : 43 lignes (Smirnov, Ljung-Box et Box-Pierce au retard 2 exigent
# T >= 8), nombre inchange par #70.
verifier("Invariants : 46 lignes usp_tests() a T >= 8 dans tous les regimes testes, 43 a T = 5",
         all(vapply(list(tt, t8, tb, t2, t3, t10), length, integer(1)) == 46L) &&
           length(t5) == 43L)
verifier("Invariant M7 : hors test et procedure de decision, verdict INFO et sens NA",
         all(vapply(c(tt, t5, t8, tb), function(l)
           l$type %in% c("test", "procedure de decision") ||
             (identical(l$verdict, "INFO") && is.na(l$sens) && is.na(l$p_retenue)),
           logical(1))))
res8 <- run_engine(xt = x8, yt = y8, methode = "premium", segment = 1, annexe = "II",
                   nature_donnees = "brutes", B = 99, seed = 20260831)
verifier("run_engine, pi_t variable, B = 99 : 51 lignes (#45), catalogue complet, aucune nature 'exacte' sur les huit",
         isTRUE(res8$ok) && length(res8$tests) == 51L &&
           identical(names(res8$bootstrap$p_mc), names(USP_CATALOGUE_MC)) &&
           !any(vapply(res8$tests, function(l)
             l$test %in% NOM && identical(l$nature_p, "exacte"), logical(1))))

fin_fichier()
