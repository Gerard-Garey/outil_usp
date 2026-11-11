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
# Mentions de regime de #514 (specification finale d'actuary, M17a et M17b) :
# pi_t variable, en tete du texte de la ligne (test ou diagnostic par
# decision). TXT_R8 garde le nom de la regle (#70).
TXT_R8 <- MENTION_PI_VARIABLE_TEST
r8_present <- function(d) grepl(MENTION_PI_VARIABLE_TEST, d, fixed = TRUE) ||
  grepl(MENTION_PI_VARIABLE_TEST_SANS_MC, d, fixed = TRUE) ||
  grepl(MENTION_PI_VARIABLE_DIAG, d, fixed = TRUE)
commence_par_r8 <- function(d) startsWith(d, MENTION_PI_VARIABLE_TEST) ||
  startsWith(d, MENTION_PI_VARIABLE_DIAG)
# Mention de bande de #514 (M18).
TXT_BANDE <- "pi_t n'est constant qu'a la tolerance TOL_DELTA_BORD"
# Phrase fixe de la regle R15 (#303, texte de #514 : la ligne homologue est
# nommee par son libelle).
TXT_R15_DEBUT <- "Diagnostic (regle R15), sans verdict ni p-value retenue : la ligne \""
txt_r15 <- function(h) paste0(TXT_R15_DEBUT, h, "\" fait foi.")
fin_r15 <- function(d) grepl(TXT_R15_DEBUT, d, fixed = TRUE) && endsWith(d, "\" fait foi.")
# Smirnov et Spearman ratio / temps : diagnostics par decision depuis #299
# (Q-D1-Fh-5) ; la regle R7 decide encore de leur p exacte (colonne
# p_exacte), mais aucune p n'est retenue (nature_p NA) et add() ne restitue
# plus le motif d'effectifs (ex aequo) dans le detail : usp_tests() le joint
# lui-meme (detail_diag(), #358 ; avis d'actuary du 20/10/2026).
DIAG_299 <- c("Smirnov", "SpearTps")
MOTIF_EA_R <- "ex aequo dans r : loi conditionnelle non tabulee, p_min et p exacte non attribuees"
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
           grepl(TXT_BANDE, d, fixed = TRUE) || r8_present(d)
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
             grepl("TEST INOPERANT", l$detail, fixed = TRUE) && r8_present(l$detail)
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
         all(vapply(NOM, function(n) r8_present(ligne(t8, n)$detail), logical(1))))

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
verifier("Bande : sept lignes p_exacte finie, 'exacte' (Cox-Stuart : R1 ; Smirnov et Spearman-temps : diagnostics, #299), mention de bande M18 (#514)",
         all(vapply(names(NOM), function(k) {
           l <- ligne(tb, NOM[[k]])
           is.finite(l$p_exacte) && nature_attendue(tb, k) &&
             grepl(TXT_BANDE, l$detail, fixed = TRUE) && !r8_present(l$detail)
         }, logical(1))))
verifier("Bande : ligne Runsr sans phrase R7/R8 (regime #29 inchange : p exacte NA, signes differents ; diagnostic R15, #303)",
         {
           l <- ligne(tb, "Test des suites sur ratios bruts")
           is.na(l$p_exacte) && identical(l$p_mc, 0.5) && identical(l$type, "diagnostic") &&
             is.na(l$nature_p) &&
             !r8_present(l$detail) && !grepl(TXT_BANDE, l$detail, fixed = TRUE)
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
verifier("Runsr, regimes 2 et 3 : mention M17a en tete (3), texte court (2), sans phrase sur la p Monte-Carlo (#514) ; absente -> motif en tete (3 : test sans p-value ; 2 : diagnostic R15, phrase de R15 en fin, #358)",
         {
           txt_ind <- "est indisponible sur ces donnees : aucune p-value n'est retenue"
           m <- c(Runsr = MOTIF_MC_AUCUNE_REPLIC)
           nm <- "Test des suites sur ratios bruts"
           a3 <- ligne(t8, nm)
           b3 <- ligne(usp_tests(f8, boot_fictif(f8, motif = m), methode = "premium"), nm)
           a2 <- ligne(tb, nm)
           b2 <- ligne(usp_tests(fb, boot_fictif(fb, motif = m), methode = "premium"), nm)
           # Textes de #514 (specification finale d'actuary, Runsr) : branche 3,
           # mention M17a en tete, sans phrase sur la p Monte-Carlo ni renvoi a
           # nature_p ; branche 2, texte court et phrase de R15.
           grepl(MENTION_PI_VARIABLE_TEST, a3$detail, fixed = TRUE) &&
             !grepl("est nommee par nature_p", a3$detail, fixed = TRUE) &&
             !grepl(" est retenue", a3$detail, fixed = TRUE) &&
             # p Monte-Carlo absente : variante de M17a sans la proposition sur
             # la p Monte-Carlo (constat Q-A1 de l'audit).
             grepl(MENTION_PI_VARIABLE_TEST_SANS_MC, b3$detail, fixed = TRUE) &&
             !grepl("en tient lieu", b3$detail, fixed = TRUE) && !grepl(" est retenue", b3$detail, fixed = TRUE) &&
             grepl("mais un signe au moins differe entre u et z", a2$detail, fixed = TRUE) &&
             !grepl("est nommee par nature_p", a2$detail, fixed = TRUE) &&
             !grepl("est calculee", a2$detail, fixed = TRUE) &&
             !grepl(" est retenue", a2$detail, fixed = TRUE) &&
             !grepl(txt_ind, b2$detail, fixed = TRUE) &&
             grepl(paste("ni identite garantie ni p exacte.", txt_r15(NOM[["Runs"]])), b2$detail, fixed = TRUE) &&
             !grepl(" est retenue", b2$detail, fixed = TRUE) &&
             identical(b3$type, "test") && identical(b3$verdict, "INFO") && is.na(b3$p_retenue) &&
             startsWith(b3$detail, "Monte-Carlo indisponible : aucune replication finie") &&
             identical(b2$type, "diagnostic") && identical(b2$verdict, "INFO") && is.na(b2$p_retenue) &&
             startsWith(b2$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_AUCUNE_REPLIC, ".")) &&
             !grepl(": aucune p-value retenue.", b2$detail, fixed = TRUE) &&
             endsWith(b2$detail, txt_r15(NOM[["Runs"]]))
         })
# #182 (Q1 d'audit, retenue) : txt_mc_indispo() n'a que des appelants sans p
# exacte (RESET, OLS-CUSUM, Runsr non attribuee) ; p_mc absente, aucune
# p-value n'est retenue, et le texte le dit sans renvoyer a nature_p. La
# phrase "s'il en est une" reste dans les branches AVEC p_mc de type test
# (depuis #214, RESET, OLS-CUSUM, Runsr regime 3), add() pouvant encore
# ecarter la p calculee ; elle est retiree des branches de Runsr a pi_t
# constant (regimes 1 et 2), diagnostics de la regle R15 depuis #303.
verifier("txt_mc_indispo retiree (#514) : RESET et OLS-CUSUM sans p_mc -> prefixe d'add() seul, sans 's'il en est une' ; Runsr regime 2 avec p_mc -> sans 's'il en est une' (#303)",
         {
           ko <- usp_tests(fit, boot_fictif(fit, motif = c(RESET = MOTIF_MC_AUCUNE_REPLIC,
                                                           CUSUM = MOTIF_MC_AUCUNE_REPLIC)),
                           methode = "premium")
           r <- ligne(ko, "RESET (forme fonctionnelle)"); k <- ligne(ko, "Stabilite cumulee (OLS-CUSUM)")
           a2 <- ligne(tb, "Test des suites sur ratios bruts")
           nouveau <- "est indisponible sur ces donnees : aucune p-value n'est retenue"
           all(vapply(list(r, k), function(l)
             startsWith(l$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_AUCUNE_REPLIC, ", ")) &&
               !grepl(nouveau, l$detail, fixed = TRUE) && !grepl("s'il en est une", l$detail, fixed = TRUE) &&
               is.na(l$p_retenue) && is.na(l$p_exacte), logical(1))) &&
             is.finite(a2$p_mc) &&
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
verifier("Bande avec ex aequo : Spearman x2 et MK sans p exacte ni mention de bande ; DW et suites avec ; Spearman-temps (diagnostic, #299) motif ex aequo en mention M8 apres le texte fixe (#514)",
         all(vapply(c("SpearVol", "SpearTps", "MK"), function(k) {
           l <- ligne(tbe, NOM[[k]])
           is.na(l$p_exacte) && is.na(l$p_min) &&
             !grepl(TXT_BANDE, l$detail, fixed = TRUE) &&
             (if (k %in% DIAG_299) est_diag_299(l) && endsWith(l$detail, paste0(MOTIF_EA_R, "."))
              else grepl("ex aequo dans r", l$detail, fixed = TRUE))
         }, logical(1))) &&
           all(vapply(NOM[c("DW", "Runs")], function(n) {
             l <- ligne(tbe, n)
             is.finite(l$p_exacte) && grepl(TXT_BANDE, l$detail, fixed = TRUE)
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
verifier("Ex aequo dans r : Spearman x2 et MK -> p_exacte NA, Monte-Carlo, p_asymptotique exact = FALSE, 'ex aequo dans r' (Spearman-temps : diagnostic par decision, #299, motif ex aequo en mention M8 depuis #514)",
         {
           r2 <- y2 / x
           p_as <- list(SpearVol = suppressWarnings(stats::cor.test(r2, x, method = "spearman",
                                                                    exact = FALSE)$p.value),
                        SpearTps = suppressWarnings(stats::cor.test(r2, seq_along(r2), method = "spearman",
                                                                    exact = FALSE)$p.value))
           all(vapply(c("SpearVol", "SpearTps", "MK"), function(k) {
             l <- ligne(t2, NOM[[k]])
             is.na(l$p_exacte) && is.na(l$p_min) &&
               (if (k %in% DIAG_299) est_diag_299(l) && endsWith(l$detail, paste0(MOTIF_EA_R, "."))
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
verifier("T = 10, ex aequo dans r : Spearman x2 -> p_exacte et p_min NA, detail 'Edgeworth' et 'ex aequo dans r' (Spearman-temps, diagnostic #299 : motif ex aequo en mention M8 depuis #514)",
         anyDuplicated(y10e / x10) > 0 &&
           all(vapply(c("SpearVol", "SpearTps"), function(k) {
             l <- ligne(t10e, NOM[[k]])
             is.na(l$p_exacte) && is.na(l$p_min) && grepl("Edgeworth", l$detail, fixed = TRUE) &&
               (if (k %in% DIAG_299) est_diag_299(l) && endsWith(l$detail, paste0(MOTIF_EA_R, "."))
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
             grepl(MENTION_PI_VARIABLE_TEST_SANS_MC, l$detail, fixed = TRUE) &&
             grepl("sur n_p = 4 paires, p_mc non calculee", l$detail, fixed = TRUE)
         })
# alpha = 0,29 et non 0,30 : run_engine() exige alpha < SEUIL_ECHEC_SENS_REJETER.
verifier("5c, alpha = 0,29 (R1 non declenchee) : type test, INFO, p_retenue et nature_p NA, les deux motifs",
         {
           l <- ligne(usp_tests(f9, b9, alpha = 0.29, methode = "premium"), NOM[["CoxStuart"]])
           identical(l$type, "test") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             is.na(l$nature_p) && is.na(l$p_exacte) && is.na(l$p_mc) &&
             grepl(MENTION_PI_VARIABLE_TEST_SANS_MC, l$detail, fixed = TRUE) &&
             grepl("sur n_p = 4 paires, p_mc non calculee", l$detail, fixed = TRUE)
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
# n'existait qu'a T >= 8). Ligne Student ajoutee par #423, a tout T : 43 et
# 41.
verifier("Invariants : 43 lignes usp_tests() a T >= 8 dans tous les regimes testes, 41 a T = 5 (LB1r retiree, #303 ; trois lignes retirees, #302 ; ligne Student ajoutee, #423)",
         all(vapply(list(tt, t8, tb, t2, t3, t10), length, integer(1)) == 43L) &&
           length(t5) == 41L)
verifier("Invariant M7 : hors test, verdict INFO et sens NA",
         all(vapply(c(tt, t5, t8, tb), function(l)
           identical(l$type, "test") ||
             (identical(l$verdict, "INFO") && is.na(l$sens) && is.na(l$p_retenue)),
           logical(1))))
res8 <- run_engine(xt = x8, yt = y8, methode = "premium", segment = 1, annexe = "II",
                   nature_donnees = "brutes", B = 99, seed = 20260831)
verifier("run_engine, pi_t variable, B = 99 : 48 lignes hors lecture conjointe (#45 ; LB1r retiree, #303 ; trois lignes retirees, #302 ; ligne Student ajoutee, #423 ; lignes de famille de #297 en fin), catalogue complet, aucune nature 'exacte' sur les sept",
         isTRUE(res8$ok) &&
           sum(vapply(res8$tests, function(l) !identical(l$fonction, "engine_p_famille"), NA)) == 48L &&
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
NOM_LB1R <- "Ljung-Box (retard 1) sur ratios bruts"
j2 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln_interieur.csv"))
fj2 <- usp_ajuster(j2$xt, j2$yt)
tj2 <- usp_tests(fj2, boot_fictif(fj2), methode = "premium")
est_r15 <- function(l) identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
  is.na(l$p_retenue) && is.na(l$nature_p) && is.na(l$sens) && isFALSE(l$inoperant) &&
  identical(l$p_mc, 0.5) && fin_r15(l$detail) &&
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
             !grepl("est nommee par nature_p", b$detail, fixed = TRUE) &&
             !grepl("est nommee par nature_p", ligne(tb, NOM_R15[["Runsr"]])$detail, fixed = TRUE)
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
           }, logical(1))) && est_r15(ligne(t, NOM_R15[["supFr"]])) &&
             # Repli neutre de la ligne Runsr (cause NA, revue finale de #486).
             identical(ligne(t, NOM_R15[["Runsr"]])$detail,
                       paste0(MOTIF_MC_OBS_NON_FINIE, " : test non applicable"))
         })
# p Monte-Carlo absente a pi_t constant : diagnostic R15, le motif en tete du
# detail, sous la forme de sa classe comme dans add() (degenerescence :
# "<motif> : aucune p-value retenue." ; autre motif :
# "Monte-Carlo indisponible : <motif>."), la phrase de R15 en fin.
verifier("R15 (#303) : p Monte-Carlo absente a pi_t constant, diagnostic R15 avec le motif en tete",
         {
           b <- boot_fictif(fit, motif = c(CUSUMr = MOTIF_MC_DISPERSION_NULLE, Runsr = MOTIF_MC_AUCUNE_REPLIC))
           t <- usp_tests(fit, b, methode = "premium")
           l <- ligne(t, NOM_R15[["CUSUMr"]]); r <- ligne(t, NOM_R15[["Runsr"]])
           identical(l$type, "diagnostic") && is.na(l$p_mc) && is.na(l$p_retenue) &&
             startsWith(l$detail, paste0(MOTIF_MC_DISPERSION_NULLE, " : aucune p-value retenue.")) &&
             fin_r15(l$detail) &&
             # Runsr, regime 1 sans p_mc : p exacte conservee, phrase de R15
             # jointe apres le point final (" ", jamais " ; ").
             identical(r$type, "diagnostic") && is.finite(r$p_exacte) && is.na(r$p_retenue) &&
             startsWith(r$detail, "Monte-Carlo indisponible : aucune replication finie (B_effectif = 0).") &&
             !grepl(": aucune p-value retenue.", r$detail, fixed = TRUE) &&
             grepl(paste("(doublon exact).", txt_r15(NOM[["Runs"]])), r$detail, fixed = TRUE)
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
             identical(r$type, "diagnostic") && isFALSE(r$inoperant) && fin_r15(r$detail)
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
               identical(l$type, "diagnostic") && is.na(l$p_mc) && fin_r15(l$detail) &&
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
# Textes de #514 (specification finale d'actuary, U18 et CvM) : texte propre
# de la ligne, puis phrase fixe des diagnostics par decision (detail_diag()).
TXT_DIAG_DEC <- "Diagnostic par decision, sans verdict ni p-value retenue"
TXT_DIAG_302 <- c(
  KS = paste("Distance de Kolmogorov a N(0,1) a parametres connus, conservatrice sur des",
             "residus standardises par le modele (tres conservatrice a T = 8 sur le jeu de",
             "controle, par simulation), pour information.", TXT_DIAG_DEC,
             ": la ligne \"Lilliefors (KS a parametres estimes)\" fait foi."),
  CvM = paste("Distance de Cramer-von Mises a la loi normale, celle d'Anderson-Darling sans la",
              "ponderation des queues, pour information.", TXT_DIAG_DEC,
              ": la ligne \"Anderson-Darling\" fait foi."))
NOM_H3_302 <- c(SW = "Shapiro-Wilk sur residus standardises", SF = "Shapiro-Francia",
                AD = "Anderson-Darling", Lillie = "Lilliefors (KS a parametres estimes)",
                JB = "Jarque-Bera", DAgo = "Asymetrie (D'Agostino, T >= 8)")
# Mention de #514 (M19), en tete du texte.
TXT_H3_302 <- MENTION_H3_PI_VARIABLE
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
# #514 (specification d'actuary, U18) : base vide, le contenu passe dans la
# raison de la phrase fixe.
verifier("#302 : KS et CvM a pi_t constant, texte propre puis phrase fixe (#514)",
         identical(ligne(tt, NOM_DIAG_302[["KS"]])$detail, TXT_DIAG_302[["KS"]]) &&
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
             startsWith(k$detail, paste0(MOTIF_MC_DISPERSION_NULLE, " : aucune p-value retenue.")) &&
             endsWith(k$detail, TXT_DIAG_302[["KS"]]) &&
             identical(w$type, "diagnostic") && is.na(w$p_mc) &&
             identical(w$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_AUCUNE_REPLIC, ". ",
                                        TXT_DIAG_302[["CvM"]])) &&
             identical(k2$type, "non applicable") && !grepl("Diagnostic par decision, sans verdict", k2$detail, fixed = TRUE)
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
# degenere) : la mention d'add() ("... non retenue.") en tete,
# puis la phrase de la section 5.3 (avis d'actuary du 19/10/2026 : phrase
# maintenue sur un tel diagnostic).
verifier("#302 : J2, p Monte-Carlo de SW absente (motif non degenere), mention d'add() puis phrase de la section 5.3",
         {
           l <- ligne(usp_tests(fj2, boot_fictif(fj2, motif = c(SW = MOTIF_MC_REPLIC_INSUFFISANTES)),
                                methode = "premium"), NOM_H3_302[["SW"]])
           identical(l$type, "diagnostic") && is.na(l$p_retenue) && is.finite(l$p_asymptotique) &&
             startsWith(ligne(tj2, NOM_H3_302[["SW"]])$detail, TXT_H3_302) &&
             identical(l$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_REPLIC_INSUFFISANTES,
                                        ", p non simulee (loi du champ loi) non retenue. ",
                                        ligne(tj2, NOM_H3_302[["SW"]])$detail))
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
# Garde de longueur de la cle (revue finale, C1 d'audit) : a T = 650 la cle
# depasse la limite de 10000 octets des noms de variable de R ; la valeur est
# alors rendue par le calcul direct, sans erreur et sans entree de cache. Le
# vecteur de volumes est tire sous engine_sous_graine() (aucun effet sur le
# .Random.seed de l'appelant).
verifier("#358 : T = 650, cle du cache au-dela de la limite de 10000 octets -> aucune erreur, valeur identique au calcul direct, aucune entree de cache",
         {
           x650 <- engine_sous_graine(20261029L, 1 + stats::runif(650))
           cle650 <- paste(sprintf("%a", c(0.10, x650)), collapse = " ")
           cache <- get(".cache_pi_env", envir = environment(run_engine))
           avant <- ls(cache, all.names = TRUE)
           v <- tryCatch(PENV(x650, 0.10), error = function(e) e)
           nchar(cle650, type = "bytes") > 10000L && is.numeric(v) &&
             identical(v, .usp_puissance_enveloppe_h2_calcul(x650, 0.10)) &&
             identical(ls(cache, all.names = TRUE), avant)
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
TXT_H2_299 <- paste(TXT_DIAG_DEC, ": la ligne \"Heteroscedasticite vs volume - Breusch-Pagan",
                    "studentise (Koenker)\" fait foi.")
# Phrases fixes des diagnostics par decision de Smirnov et de Spearman ratio /
# temps (#514, U15 et U9) ; le motif ex aequo n'y figure plus.
RAISON_299 <- c(
  Smirnov = "les lignes de la famille B (H1), dont \"Independance ratio S/P vs volume\", font foi.",
  SpearTps = "la ligne \"Tendance monotone du ratio S/P\", meme alternative, fait foi.")
TXT_DIAG_299 <- c(
  BP79 = TXT_H2_299, White = TXT_H2_299, GQ = TXT_H2_299, BF = TXT_H2_299,
  Smirnov = paste(TXT_DIAG_DEC, ":", RAISON_299[["Smirnov"]]),
  SpearTps = paste(TXT_DIAG_DEC, ":", RAISON_299[["SpearTps"]]))
# Textes propres (#514) de Smirnov et de Spearman ratio / temps.
BASE_299 <- c(
  Smirnov = paste("Compare les lois des residus entre petits et gros volumes, ce qui vise surtout",
                  "une difference de position (alternative de H1 plutot que de H2), pour information."),
  SpearTps = "Mesure une tendance monotone du ratio S/P dans le temps, pour information.")
# Phrase unique de Breusch-Pagan studentise depuis #514 (U12), puissance en
# parenthese.
txt_penv <- function(xx, a = 0.10)
  sprintf(paste("Un ECHEC ou une ALERTE signale une variance des residus liee au volume, contraire",
                "a la structure de variance de l'annexe XVII, un OK ne la demontre pas (puissance",
                "maximale %.2f avec ces volumes au seuil alpha = %g). Seul test de H2 a verdict, a",
                "lire avec \"Position de delta dans [0,1]\" et les lignes \"Rapport de",
                "vraisemblance : delta = ...\"."), PENV(xx, a), a)
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
verifier("#299 : details propres conserves avant la phrase fixe (BP79, Smirnov, Spearman-temps ; mention M17b a pi_t variable, mention de bande)",
         {
           b79 <- ligne(tt, NOM_DIAG_299[["BP79"]])$detail
           sm <- ligne(tt, NOM_DIAG_299[["Smirnov"]])$detail
           st8 <- ligne(t8, NOM_DIAG_299[["SpearTps"]])$detail
           stb <- ligne(tb, NOM_DIAG_299[["SpearTps"]])$detail
           identical(b79, paste("Version publiee du test de Breusch-Pagan, non robuste (sur-rejette sous",
                                "des erreurs a queues plus lourdes que la normale), pour comparaison.",
                                TXT_H2_299)) &&
             identical(sm, paste(BASE_299[["Smirnov"]], TXT_DIAG_299[["Smirnov"]])) &&
             identical(st8, paste(MENTION_PI_VARIABLE_DIAG, BASE_299[["SpearTps"]], TXT_DIAG_299[["SpearTps"]])) &&
             startsWith(stb, TXT_BANDE) &&
             identical(ligne(tt, NOM_DIAG_299[["GQ"]])$detail,
                       paste("Compare les variances des residus entre petits et gros volumes, pour",
                             "information.", TXT_H2_299)) &&
             identical(ligne(tt, NOM_DIAG_299[["SpearTps"]])$detail,
                       paste(BASE_299[["SpearTps"]], TXT_DIAG_299[["SpearTps"]]))
         })
verifier("#299 : Breusch-Pagan studentise reste un test, detail = phrase propre puis phrase de pi_env (alpha du calcul), pi_constant et variable",
         {
           ok <- function(t, xx, a = 0.10) {
             l <- ligne(t, NOM_BP)
             identical(l$type, "test") && identical(l$p_retenue, 0.5) && isFALSE(l$inoperant) &&
               startsWith(l$detail, txt_penv(xx, a))
           }
           t05 <- usp_tests(fit, boot_fictif(fit), alpha = 0.05, methode = "premium")
           ok(tt, x) && ok(t8, x8) && ok(tj2, j2$xt) && ok(t05, x, 0.05) &&
             grepl("0.13 avec ces volumes", ligne(tt, NOM_BP)$detail, fixed = TRUE) &&
             grepl("0.34 avec ces volumes", ligne(tj2, NOM_BP)$detail, fixed = TRUE) &&
             grepl("alpha = 0.05)", ligne(t05, NOM_BP)$detail, fixed = TRUE)
         })
# Echec numerique de pi_env (#358, decision d'actuary) : calcul tente (volumes
# variables, statistique definie) et NA -> motif fixe a la place de la phrase
# de pi_env. NA provoque par substitution de .imhof_p_sup0() dans
# l'environnement du moteur (ADR 0016), sur des volumes x * 3 absents du
# cache ; substitution et entrees du cache retirees en sortie.
TXT_PENV_ECHEC <- paste(
  "Un ECHEC ou une ALERTE signale une variance des residus liee au volume, contraire",
  "a la structure de variance de l'annexe XVII, un OK ne la demontre pas (puissance",
  "maximale non calculee : echec numerique). Seul test de H2 a verdict, a lire avec",
  "\"Position de delta dans [0,1]\" et les lignes \"Rapport de vraisemblance : delta =",
  "...\".")
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
             identical(l$detail, TXT_PENV_ECHEC) &&
             !grepl("avec ces volumes ;", l$detail, fixed = TRUE)
         }))
verifier("#358 : substitution levee, pi_env de nouveau calculee sur 3 x (invariance d'echelle)",
         {
           f3 <- usp_ajuster(3 * x, 3 * y)
           startsWith(ligne(usp_tests(f3, boot_fictif(f3), methode = "premium"), NOM_BP)$detail,
                      txt_penv(x, 0.10))
         })
verifier("#299 : Spearman ratio / volume et Mann-Kendall restent des tests (H1)",
         all(vapply(list(tt, t8), function(t)
           all(vapply(c("Independance ratio S/P vs volume", "Tendance monotone du ratio S/P"),
                      function(n) identical(ligne(t, n)$type, "test"), logical(1))), logical(1))))
# Motif ex aequo sur un diagnostic de #299 (avis d'actuary du 20/10/2026) :
# ordre motif Monte-Carlo, detail propre, phrase fixe portant le motif ex
# aequo (chaine effectifs de la ligne) entre parentheses depuis #514 ; absent
# sans ex aequo.
# Depuis #514 (specification finale d'actuary, U9 et U15), le texte fixe des
# diagnostics par decision ne porte plus le motif ex aequo (p exacte et p_min
# NA dans leurs champs) ; le motif Monte-Carlo d'add() reste en tete.
verifier("#299 : Spearman-temps (ex aequo dans r) : motif Monte-Carlo en tete, texte fixe, motif ex aequo en mention M8 (#514)",
         {
           st <- ligne(t2, NOM_DIAG_299[["SpearTps"]])$detail
           stm <- ligne(usp_tests(f2, boot_fictif(f2, motif = c(SpearTps = MOTIF_MC_AUCUNE_REPLIC)),
                                  methode = "premium"), NOM_DIAG_299[["SpearTps"]])$detail
           att <- paste(BASE_299[["SpearTps"]], TXT_DIAG_299[["SpearTps"]], paste0("T = 8, ", MOTIF_EA_R, "."))
           identical(st, att) &&
             identical(stm, paste0("Monte-Carlo indisponible : ", MOTIF_MC_AUCUNE_REPLIC, ". ", att)) &&
             !grepl("ex aequo", ligne(tt, NOM_DIAG_299[["SpearTps"]])$detail, fixed = TRUE) &&
             !grepl("ex aequo", ligne(tt, NOM_DIAG_299[["Smirnov"]])$detail, fixed = TRUE)
         })
verifier("#299 : Smirnov (ex aequo dans z, pi_t variable) : mention M17b, texte fixe, motif ex aequo en mention M8 (#514)",
         {
           z_e <- f8$z; z_e[2] <- z_e[1]
           f8e <- f8; f8e$z <- z_e
           b <- boot_fictif(f8)
           l <- ligne(usp_tests(f8e, b, methode = "premium"), NOM_DIAG_299[["Smirnov"]])
           grp <- x8 > stats::median(x8)
           ea <- sprintf("n1 = %d, n2 = %d, ex aequo dans z : p_min et p exacte non attribuees.",
                         sum(grp), sum(!grp))
           est_diag_299(l) && is.na(l$p_min) &&
             identical(l$detail, paste(MENTION_PI_VARIABLE_DIAG, BASE_299[["Smirnov"]],
                                       TXT_DIAG_299[["Smirnov"]], ea))
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
             identical(l$type, "non applicable") &&
               !grepl("Diagnostic par decision, sans verdict", l$detail, fixed = TRUE) &&
               !grepl("puissance maximale", l$detail, fixed = TRUE)
           }, logical(1))) &&
           est_ligne_299(ligne(tvc, NOM_DIAG_299[["SpearTps"]]), "SpearTps"))
verifier("#299 : White a moins de trois volumes distincts non applicable, sans phrase ; BP79, GQ, BF, Smirnov diagnostics",
         {
           w <- ligne(t2n, NOM_DIAG_299[["White"]])
           identical(w$type, "non applicable") && grepl("moins de trois volumes distincts", w$detail, fixed = TRUE) &&
             !grepl("Diagnostic par decision, sans verdict", w$detail, fixed = TRUE) &&
             all(vapply(c("BP79", "GQ", "BF", "Smirnov"), function(k)
               est_ligne_299(ligne(t2n, NOM_DIAG_299[[k]]), k), logical(1)))
         })
verifier("#299 : partition de Smirnov a moins de trois annees non applicable, sans phrase",
         {
           l <- ligne(tsm, NOM_DIAG_299[["Smirnov"]])
           identical(l$type, "non applicable") && grepl("moins de 3 dans un groupe", l$detail, fixed = TRUE) &&
             !grepl("Diagnostic par decision, sans verdict", l$detail, fixed = TRUE)
         })
verifier("#299 : statistique observee non finie (BP79, GQ, BP) -> non applicable sans phrase ; p Monte-Carlo absente -> motif en tete, phrase en fin",
         {
           b <- boot_fictif(fit, motif = c(BP79 = MOTIF_MC_OBS_NON_FINIE, BP = MOTIF_MC_OBS_NON_FINIE,
                                           GQ = MOTIF_MC_AUCUNE_REPLIC, BF = MOTIF_MC_DISPERSION_NULLE))
           b$stats_obs$BP79 <- NA_real_; b$stats_obs$BP <- NA_real_
           t <- usp_tests(fit, b, methode = "premium")
           a <- ligne(t, NOM_DIAG_299[["BP79"]]); k <- ligne(t, NOM_BP)
           g <- ligne(t, NOM_DIAG_299[["GQ"]]); f <- ligne(t, NOM_DIAG_299[["BF"]])
           identical(a$type, "non applicable") && !grepl("Diagnostic par decision, sans verdict", a$detail, fixed = TRUE) &&
             !grepl("puissance maximale", k$detail, fixed = TRUE) &&
             identical(g$type, "diagnostic") &&
             identical(g$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_AUCUNE_REPLIC, ". ",
                                        ligne(tt, NOM_DIAG_299[["GQ"]])$detail)) &&
             identical(f$type, "diagnostic") &&
             startsWith(f$detail, paste0(MOTIF_MC_DISPERSION_NULLE, " : aucune p-value retenue.")) &&
             endsWith(f$detail, TXT_H2_299)
         })

## --- 14. #521 : mention M20b lue dans usp_regime() --------------------------
# mention_r7() ne recalcule plus diff(range(x)) == 0 : M20b si volumes_constants
# et pas volumes_dans_bande (volumes exactement constants), sinon M20a a
# delta = 1. Refactor a sortie identique : les attendus sont ceux d'avant
# (mesure du 10/11/2026 sur HEAD, 20 combinaisons de volumes et de delta,
# listes de lignes de usp_tests() identiques au sens de identical()). Ligne
# Durbin-Watson : test, p exacte finie, hors diagnostic, donc branche R7
# atteinte quand pi_t est constant.
alt521 <- rep(c(1, -1), 4)
mention_dw521 <- function(xx, d) {
  f <- fit_force(xx, y, d)
  l <- ligne(usp_tests(f, boot_fictif(f), methode = "premium"), NOM[["DW"]])
  c(detail = l$detail, p_exacte = is.finite(l$p_exacte))
}
dw_cst_1 <- mention_dw521(rep(110, 8), 1)
dw_cst_i <- mention_dw521(rep(110, 8), 0.37)
dw_bd_1 <- mention_dw521(100 * (1 + alt521 * 4e-7), 1)
dw_bd_i <- mention_dw521(100 * (1 + alt521 * 4e-7), 0.37)
verifier("#521 volumes exactement constants (delta = 1 et delta interieur) : p exacte finie, mention M20b en tete de la ligne Durbin-Watson",
         identical(dw_cst_1[["p_exacte"]], "TRUE") && identical(dw_cst_i[["p_exacte"]], "TRUE") &&
           startsWith(dw_cst_1[["detail"]], MENTION_VOLUMES_CONSTANTS) &&
           startsWith(dw_cst_i[["detail"]], MENTION_VOLUMES_CONSTANTS))
verifier("#521 volumes dans la bande de tolerance (x = 100 (1 +/- 4e-7)) : delta = 1 -> M20a (pas M20b) ; delta interieur -> mention de bande M18",
         identical(dw_bd_1[["p_exacte"]], "TRUE") &&
           startsWith(dw_bd_1[["detail"]], MENTION_DELTA_BORNE_1) &&
           !startsWith(dw_bd_1[["detail"]], MENTION_VOLUMES_CONSTANTS) &&
           grepl(TXT_BANDE, dw_bd_i[["detail"]], fixed = TRUE) &&
           !grepl(MENTION_VOLUMES_CONSTANTS, dw_bd_i[["detail"]], fixed = TRUE))

# #514 (A3, S1 a S8) : texte propre en deux phrases au plus et 400
# caracteres au plus sur les objets de ce fichier (regimes de pi_t, T = 5,
# T = 10, ex aequo, volumes constants, bande de tolerance).
for (nm514 in c("tt", "t5", "t8", "tb", "t2", "t3", "t10", "t10e", "tbe", "tj2", "tvc", "t2n", "tsm"))
  if (exists(nm514, inherits = FALSE)) verifier_detail(get(nm514), paste("objet", nm514))

fin_fichier()
