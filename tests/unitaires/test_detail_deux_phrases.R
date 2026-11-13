###############################################################################
#  tests/unitaires/test_detail_deux_phrases.R  --  DETAIL DES LIGNES DE TEST :
#                                                  DEUX PHRASES, 400 CARACTERES
#                                                  (ISSUE #514)
#
#  Specification finale d'actuary (docs/revues/20261109-detail-deux-phrases/
#  specification-actuary.md, par. 8) et decisions du mainteneur du 09/11/2026
#  (Q-1 a Q-8 ; docs/revues/20261109-detail-deux-phrases.md). Le texte propre
#  d'une ligne (detail prive des mentions conditionnelles M1 a M22, dont les
#  mentions de regime M17 a M22) compte au plus PHRASES_MAX = 2 phrases
#  (regle (P)) et PLAFOND_TEXTE_PROPRE = 400 caracteres. Outils
#  (compter_phrases(), MENTIONS, texte_propre(), verifier_detail()) dans
#  outils_unitaires.R, partages avec les fichiers qui appellent
#  verifier_detail() sur leurs objets.
#    A0 : regle (P), exemples de la specification ;
#    A1 : chaque mention reconnait en entier un exemple produit par le moteur ;
#         les mentions reecrites et les mentions de regime font une phrase ;
#         texte_propre() retire les mentions ;
#    A2 : les six cas de reference, recalcules par run_engine()
#         (tests/outils_tests.R, CAS ; environ 60 s) : texte propre <= 2
#         phrases, <= 400 caracteres, non vide hors non applicable ;
#         phrases du detail = phrases du texte propre + phrases des mentions ;
#         ensemble des lignes a plus de deux phrases mentions comprises ;
#    A3 : renvois, libelles cites entre guillemets existants ;
#    A4 : branches rares (scenarios S1 a S22) et pose des mentions de regime ;
#    A5 : controle de source.
#  Aucun controle dans add() : pas d'arret a l'execution sur des donnees
#  d'utilisateur (specification, par. 8).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_detail_deux_phrases.R")

.racine514 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."

## --- A0 : regle (P) ---------------------------------------------------------------
verifier("A0 regle (P) : exemples de la specification",
         identical(compter_phrases("a. b"), 2L) &&
           identical(compter_phrases("a ; b"), 2L) &&
           identical(compter_phrases("fin."), 1L) &&
           identical(compter_phrases(""), 0L) &&
           identical(compter_phrases(NA_character_), 0L) &&
           identical(compter_phrases("x (a ; b. C) y"), 1L) &&
           identical(compter_phrases("i.i.d. normal"), 1L) &&
           identical(compter_phrases("p. 12"), 1L) &&
           identical(compter_phrases("D6.49"), 1L) &&
           identical(compter_phrases("T! appariements"), 1L) &&
           identical(compter_phrases("famille B. font"), 2L))
verifier("A0 regle (P) : '.' sans condition de majuscule, crochets, abreviations",
         identical(compter_phrases("fin. suite minuscule"), 2L) &&
           identical(compter_phrases("[0 ; 1] puis fin."), 1L) &&
           identical(compter_phrases("eq. (2.5) et vol. 2"), 1L) &&
           identical(compter_phrases("R2 < 0.5. Diagnostic"), 2L) &&
           identical(compter_phrases("(sous un plan). p-value"), 2L))

## --- A1 : mentions conditionnelles --------------------------------------------------
# Registre fictif (aucune simulation, meme construction que
# test_verdict_sensible_mc.R) : une statistique Monte-Carlo "S".
ligne514 <- function(p_mc = NA_real_, err_mc = NA_real_, alpha = 0.10, g = NULL,
                     motif = NULL, pmm = NULL, ...) {
  boot <- list(p_mc = c(S = p_mc), err_mc = c(S = err_mc))
  if (!is.null(g)) boot$granularite_stat <- c(S = g)
  if (!is.null(motif)) boot$motif_mc <- c(S = motif)
  if (!is.null(pmm)) boot$p_min_mc <- c(S = pmm)
  r <- engine_registre_tests(boot, list(S = .mc_entree(function(e) 1, "haut")), alpha,
                             "Monte-Carlo")
  # Sans p Monte-Carlo ni motif (p exacte seule) : ligne sans mc_nom.
  if (is.na(p_mc) && is.null(motif)) r$add("F", "t", "ref", fonction = "usp_tests", ...)
  else r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", ...)
  r$lignes()[[1]]$detail
}
BASE514 <- "Base de la ligne."
# Exemples produits par le moteur : add() (registre fictif) pour M2 a M10,
# fonctions et constantes du moteur pour les autres. Chaque exemple est
# (mention, detail produit) ; le detail produit est la mention jointe a
# BASE514 (ou la mention seule).
.rx_entier <- function(rx, x) {
  m <- regexpr(rx, x, perl = TRUE)
  m > 0L && m == 1L && attr(m, "match.length") == nchar(x)
}
ex514 <- local({
  bt <- function(plafond, B_eff, p, motif = NA_character_)
    list(B = 999, B_effectif = c(S = B_eff), p_mc = c(S = p), plafond_cumuls = plafond,
         motif_mc = c(S = motif), cumuls_retires = TRUE)
  cols <- data.frame(j = c(1L, 3L), n_facteurs = c(4L, 3L))
  r_ex <- list(exclues = cols, non_identifiables = cols[1, ], K = 2L, eligibles = 4L)
  list(
    M1_degenere = .prefixe_motif_mc(MOTIF_MC_ATOME_HORS_OBS),
    M1_indisponible = .prefixe_motif_mc(MOTIF_MC_REPLIC_INSUFFISANTES),
    M3 = sub(" Base de la ligne\\.$", "",
             ligne514(motif = MOTIF_MC_REPLIC_INSUFFISANTES, p_as = 0.3, detail = BASE514)),
    M2 = sub(" Base de la ligne\\.$", "",
             ligne514(motif = MOTIF_MC_OBS_NON_FINIE, detail = BASE514)),
    M4 = sub(" Base de la ligne\\.$", "",
             ligne514(p_ex = 0.5, p_min = 0.125, effectifs = "m = 4 differences non nulles",
                      detail = BASE514)),
    M5 = sub(" Base de la ligne\\.$", "",
             ligne514(p_mc = 0.5, err_mc = 0.01, pmm = 0.2, p_min = 0.07,
                      effectifs = "n1 = 4, n2 = 4", detail = BASE514)),
    M6_exacte = sub("^Base de la ligne\\. ", "",
                    ligne514(p_ex = 0.5, p_min = 0.07, effectifs = "n1 = 4, n2 = 4",
                             detail = BASE514)),
    M6_mc = sub("^Base de la ligne\\. ", "",
                ligne514(p_mc = 0.5, err_mc = 0.01, pmm = 0.06, p_min = 0.07,
                         effectifs = "n1 = 4, n2 = 4", detail = BASE514)),
    M7 = sub("^Base de la ligne\\. ", "",
             ligne514(p_mc = 0.5, err_mc = 0.01, p_min = 0.07,
                      effectifs = "T = 8, sans ex aequo", detail = BASE514)),
    M8_mw = .mw_p_min_ligne(TRUE, c(4, 3), "colonnes n_j", function(n) 0.01,
                            ex_aequo = TRUE)$effectifs,
    M9 = sub(" Base de la ligne\\.$", "",
             ligne514(motif = MOTIF_MC_REPLIC_INSUFFISANTES, detail = BASE514)),
    M10 = sub("^Base de la ligne\\. ", "",
              ligne514(p_mc = 0.5, err_mc = 0.01, g = 0.06, detail = BASE514)),
    M11 = sub("^Base de la ligne\\. ", "",
              ligne514(p_mc = 0.09, err_mc = 0.0091, detail = BASE514)),
    M12_retires = PHRASE_MW_CUMULS_RETIRES,
    M12_plafond = PHRASE_MW_PLAFOND_CUMULS,
    M13_a = .mw_phrase_b_effectif(bt(FALSE, 950, 0.5), "S"),
    M13_a_plafond = .mw_phrase_b_effectif(bt(TRUE, 950, 0.5), "S"),
    M13_b = .mw_phrase_b_effectif(bt(FALSE, 12, NA_real_, MOTIF_MC_REPLIC_INSUFFISANTES), "S"),
    M14 = .mw_phrase_exclusion(r_ex, "quoi de la ligne", "de proportionnalite"),
    M14_non_identifiable = .mw_phrase_non_identifiable(r_ex),
    M15_a = PHRASE_FAMILLE_B_EFF_REDUIT,
    M15_b = PHRASE_FAMILLE_B_EFF_INSUFFISANT,
    # Meme construction que les lignes du rapport de vraisemblance de
    # usp_tests() (prefixe pref), motif de degenerescence et complement.
    M16 = paste(paste0(MOTIF_MC_ATOME_HORS_OBS, " : aucune p-value Monte-Carlo."),
                .complement_motif_mc(MOTIF_MC_ATOME_HORS_OBS)))
})
# Mention de MENTIONS a laquelle chaque exemple est confronte.
cle514 <- c(M14_non_identifiable = "M14")
verifier("A1 chaque mention M1 a M16 reconnait en entier un exemple produit par le moteur",
         all(vapply(names(ex514), function(k) {
           m <- if (k %in% names(cle514)) cle514[[k]] else k
           !is.null(MENTIONS[[m]]) && .rx_entier(MENTIONS[[m]], ex514[[k]])
         }, logical(1))))
verifier("A1 les exemples M2 a M10 sont bien produits par add() (non vides, sans la base)",
         all(vapply(ex514[c("M3", "M2", "M4", "M5", "M6_exacte", "M6_mc", "M7", "M9", "M10", "M11")],
                    function(s) nzchar(s) && !grepl("Base de la ligne", s, fixed = TRUE),
                    logical(1))))
# Mentions reecrites (separateur " ; " devenu ", ", Q-2) : une phrase chacune.
verifier("A1 les mentions reecrites (M3, M4, M5, M7, M8, M9, M14, T-3b) font une phrase",
         all(vapply(ex514[c("M3", "M4", "M5", "M7", "M8_mw", "M9", "M14",
                            "M14_non_identifiable", "M15_b")],
                    function(s) identical(compter_phrases(s), 1L), logical(1))))
REGIME514 <- c(M17a = MENTION_PI_VARIABLE_TEST, M17a_sans_mc = MENTION_PI_VARIABLE_TEST_SANS_MC,
               M17b = MENTION_PI_VARIABLE_DIAG,
               M18 = sprintf(FORMAT_MENTION_BANDE, TOL_DELTA_BORD,
                             "1 - delta = 5e-07, etendue relative des volumes = 3e-07"),
               M19 = MENTION_H3_PI_VARIABLE, M20a = MENTION_DELTA_BORNE_1,
               M20b = MENTION_VOLUMES_CONSTANTS, M21 = MENTION_EDGEWORTH,
               M22 = MENTION_PERMUTATIONS_ALEATOIRES)
verifier("A1 mentions de regime M17 a M22 : une phrase chacune, reconnues en entier, ASCII",
         all(vapply(names(REGIME514), function(k)
           identical(compter_phrases(REGIME514[[k]]), 1L) &&
             .rx_entier(MENTIONS[[k]], REGIME514[[k]]) && !grepl("[^ -~]", REGIME514[[k]]),
           logical(1))))
verifier("A1 texte_propre() retire les mentions de regime posees en tete",
         all(vapply(REGIME514, function(m) identical(texte_propre(paste(m, BASE514)), BASE514),
                    logical(1))) &&
           identical(texte_propre(paste(MENTION_PI_VARIABLE_TEST, MENTION_EDGEWORTH, BASE514)),
                     BASE514))
verifier("A1 texte_propre() retire les mentions posees par add() et garde la base",
         all(vapply(list(
           ligne514(motif = MOTIF_MC_REPLIC_INSUFFISANTES, p_as = 0.3, detail = BASE514),
           ligne514(p_ex = 0.5, p_min = 0.125, effectifs = "m = 4 paires", detail = BASE514),
           ligne514(p_mc = 0.5, err_mc = 0.01, pmm = 0.2, p_min = 0.07, detail = BASE514),
           ligne514(p_ex = 0.5, p_min = 0.07, effectifs = "n1 = 4, n2 = 4", detail = BASE514),
           ligne514(p_mc = 0.5, err_mc = 0.01, p_min = 0.07, detail = BASE514),
           ligne514(p_mc = 0.5, err_mc = 0.01, g = 0.06, detail = BASE514),
           ligne514(p_mc = 0.09, err_mc = 0.0091, detail = BASE514),
           ligne514(motif = MOTIF_MC_ATOME_HORS_OBS, detail = BASE514)),
           function(d) identical(texte_propre(d), BASE514), logical(1))) &&
           identical(texte_propre(ligne514(motif = MOTIF_MC_REPLIC_INSUFFISANTES,
                                           detail = BASE514)), BASE514) &&
           identical(texte_propre(paste(BASE514, ex514$M12_retires, ex514$M13_a)), BASE514) &&
           identical(texte_propre(paste(BASE514, ex514$M14)), BASE514) &&
           identical(texte_propre(paste(ex514$M15_b, BASE514)), BASE514) &&
           identical(texte_propre(paste(ex514$M16, BASE514)), BASE514))

## --- A2 : six cas de reference ------------------------------------------------------
# Recalcul par run_engine() (CAS de tests/outils_tests.R, environ 60 s), pour
# que le controle porte sur le moteur courant et non sur des references
# anterieures a un patch. outils_tests.R est evalue dans un environnement
# dedie (le moteur qu'il recharge y reste confine).
env514 <- new.env()
local(source(file.path(.racine514, "tests", "outils_tests.R"), local = TRUE), envir = env514)
res514 <- lapply(stats::setNames(names(env514$CAS), names(env514$CAS)), env514$executer_cas)
for (cas in names(res514)) verifier_detail(res514[[cas]], paste("A2 cas", cas))
plus_de_deux <- unlist(lapply(names(res514), function(cas)
  vapply(Filter(function(l) compter_phrases(l$detail) > PHRASES_MAX, res514[[cas]]$tests),
         function(l) paste(cas, l$test, sep = " x "), character(1))))
# Ensemble attendu (specification finale, par. 8, A2) : 5 lignes R7 par cas a
# delta = 1 (M20a, M4 sur Cox-Stuart, M6 sur les suites) ; 17 lignes de
# premium_interieur (M17a, M17b, M19, M5, M6, M11) ; 2 lignes de reserve2
# (M11). La specification en comptait 39, avec "Independance ratio S/P vs
# volume" de premium_interieur : sans le renvoi de #215 (pi_t variable,
# Q-7 (b)), son texte propre n'a qu'une phrase, M17a comprise 2 (mesure du
# 09/11/2026), d'ou 38.
r7_514 <- c("Independance ratio S/P vs volume", "Tendance monotone du ratio S/P",
            "Tendance par signes du ratio S/P", "Autocorrelation d'ordre 1 (Durbin-Watson)",
            "Test des suites (aleatoire des signes)")
attendu514 <- c(
  unlist(lapply(c("premium", "premium_ii6", "premium_net", "reserve1"),
                function(cas) paste(cas, r7_514, sep = " x "))),
  paste("premium_interieur", c(
    r7_514[-1], "Test des suites sur ratios bruts", "Correlation ratio S/P vs temps",
    "Egalite des lois petits vs gros volumes (2 ech.)", "Shapiro-Wilk sur residus standardises",
    "Shapiro-Francia", "Anderson-Darling", "Cramer-von Mises", "Kolmogorov-Smirnov contre N(0,1)",
    "Lilliefors (KS a parametres estimes)", "Jarque-Bera", "Asymetrie (D'Agostino, T >= 8)",
    "Valeur aberrante isolee (Grubbs)"), sep = " x "),
  paste("reserve2", c("Absence de tendance des facteurs avec le cumul, a colonne donnee",
                      "Nullite de l'ordonnee a l'origine, colonne par colonne"), sep = " x "))
verifier("A2 lignes a plus de deux phrases mentions comprises : exactement les 38 lignes attendues",
         if (setequal(plus_de_deux, attendu514) && length(attendu514) == 38L) TRUE
         else paste("en trop :", paste(setdiff(plus_de_deux, attendu514), collapse = " | "),
                    "; manquantes :", paste(setdiff(attendu514, plus_de_deux), collapse = " | ")))
# Phrases du detail = phrases du texte propre + phrases des mentions
# presentes (chaque mention extraite comptee par la regle (P)).
phrases_mentions <- function(d) sum(vapply(mentions_presentes(d), function(k)
  sum(vapply(regmatches(d, gregexpr(MENTIONS[[k]], d, perl = TRUE))[[1]], compter_phrases,
             integer(1))), integer(1)))
verifier("A2 phrases du detail = phrases du texte propre + phrases des mentions presentes",
         {
           ko <- unlist(lapply(names(res514), function(cas) vapply(res514[[cas]]$tests, function(l)
             if (compter_phrases(l$detail) == compter_phrases(texte_propre(l$detail)) +
                 phrases_mentions(l$detail)) NA_character_ else paste(cas, l$test, sep = " x "),
             character(1))))
           ko <- ko[!is.na(ko)]
           if (!length(ko)) TRUE else paste(ko, collapse = " | ")
         })
long514 <- vapply(res514, function(r) max(vapply(r$tests, function(l)
  nchar(texte_propre(l$detail)), integer(1))), integer(1))
cat(sprintf("  A2 longueur maximale du texte propre : %s\n",
            paste(sprintf("%s %d", names(long514), long514), collapse = ", ")))

## --- A3 : renvois ------------------------------------------------------------------
# Chaque libelle cite entre guillemets dans un detail est un libelle de ligne
# de la meme methode, ou le prefixe commun des lignes de rapport de
# vraisemblance.
verifier("A3 libelles cites entre guillemets : lignes existantes de la meme methode",
         {
           ko <- unlist(lapply(names(res514), function(cas) {
             noms <- vapply(res514[[cas]]$tests, `[[`, character(1), "test")
             cites <- unlist(regmatches(vapply(res514[[cas]]$tests, `[[`, character(1), "detail"),
                                        gregexpr('"[^"]+"', vapply(res514[[cas]]$tests, `[[`,
                                                                    character(1), "detail"))))
             cites <- unique(gsub('^"|"$', "", cites))
             bad <- setdiff(cites, c(noms, "Rapport de vraisemblance : delta = ..."))
             if (length(bad)) paste(cas, ":", paste(bad, collapse = " | ")) else NULL
           }))
           if (!length(ko)) TRUE else paste(ko, collapse = " ; ")
         })

## --- A4 : branches rares ------------------------------------------------------------
# Objet bootstrap fictif (aucune simulation), meme outil que
# test_regimes_p_exactes.R : p Monte-Carlo a p, motif optionnel.
boot514 <- function(f, p = 0.5, motif = NULL) {
  s <- .stats_bootstrapables(f$x, f$y, f$z, f$pi)
  pm <- stats::setNames(rep(p, length(s)), names(s))
  mm <- stats::setNames(rep(NA_character_, length(s)), names(s))
  if (!is.null(motif)) { pm[names(motif)] <- NA_real_; mm[names(motif)] <- motif }
  list(stats_obs = as.list(s), p_mc = pm, err_mc = pm * 0 + 0.01, motif_mc = mm)
}
# Ajustement force a delta = d, gamma de usp_ajuster() (meme construction que
# fit_force() de test_regimes_p_exactes.R).
force514 <- function(x, y, d) {
  g <- usp_ajuster(x, y)$gamma
  c(usp_noyau(d, g, x, y),
    list(delta = d, gamma = g, T = length(x), x = x, y = y, xbar = mean(x),
         convergence = 0L, part_starts_convergents = 1,
         delta_au_bord = usp_regime(d, x)$delta_au_bord))
}
x514 <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y514 <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
ut514 <- function(f, b = boot514(f), ...) usp_tests(f, b, methode = "premium", ...)
f_d1 <- force514(x514, y514, 1)
verifier_detail(ut514(f_d1), "S22 Runsr branche 1 (pi_t exactement constant)")
verifier_detail(ut514(force514(x514, y514, 1 - 5e-7)),
                "S3 bande de tolerance (1 - delta) et S22 Runsr branche 1b")
xb514 <- x514[1] * (1 + c(0, 1, 2, 3, 2, 1, 0, 1) * 1e-7)
verifier_detail(ut514(force514(xb514, y514, 0.4)),
                "S3 bande de tolerance (etendue relative des volumes)")
# Constat C1 d'actuary (fin de branche K1) : dans la bande due aux volumes,
# a delta = 0, l'ecart de la variance unitaire est de l'ordre de l'etendue
# relative des volumes, non de (1 - delta) = 1 ; le texte nomme les deux.
xv514 <- 100 * (1 + c(-2, 2, -2, 2, -2, 2, -2, 2) * 1e-7)
t_bv <- ut514(force514(xv514, y514, 0))
verifier_detail(t_bv, "S3 bande de tolerance (volumes 100 (1 +- 2e-7), delta = 0)")
verifier("A4 C1 : variance unitaire dans la bande (volumes, delta = 0 ; 1 - delta) : ordre (1 - delta) ou etendue relative des volumes ; texte sans la reserve a pi_t exactement constant",
         {
           var514 <- "Variance unitaire des residus standardises"
           reserve <- "a un ecart d'ordre (1 - delta), ou de l'etendue relative des volumes, pres."
           dv <- function(tt) Filter(function(l) identical(l$test, var514), tt)[[1]]$detail
           rg <- usp_regime(0, xv514)
           isTRUE(rg$pi_constant) && !isTRUE(rg$pi_constant_exact) &&
             grepl("a pi_t constant a TOL_DELTA_BORD pres seulement", dv(t_bv), fixed = TRUE) &&
             grepl(reserve, dv(t_bv), fixed = TRUE) &&
             grepl(reserve, dv(ut514(force514(x514, y514, 1 - 5e-7))), fixed = TRUE) &&
             !grepl("etendue relative", dv(ut514(f_d1)), fixed = TRUE) &&
             !grepl("TOL_DELTA_BORD", dv(ut514(f_d1)), fixed = TRUE)
         })
verifier_detail(ut514(force514(x514, y514, 0.4)), "S4 delta interieur, pi_t variable")
verifier_detail(ut514(force514(x514, y514, 0)), "S5 delta au bord, pi_t variable")
verifier_detail(ut514(force514(rep(110, 8), y514, 0)), "S1 volumes constants")
verifier_detail(ut514(force514(x514, rep(80, 8), 1)), "S2 pertes constantes, delta = 1")
verifier_detail(ut514(force514(x514, rep(80, 8), 0.4)), "S2 pertes constantes, pi_t variable")
x10 <- c(x514, 140.1, 138.6); y10 <- c(y514, 99.3, 104.8)
verifier_detail(ut514(force514(x10, y10, 1)), "S6 T = 10, pi_t constant")
verifier_detail(ut514(force514(x10, y10, 0.4)), "S6 T = 10, pi_t variable")
verifier_detail(ut514(force514(x514[1:5], y514[1:5], 1)), "S7 T = 5")
yea <- x514 * c(0.6, 0.6, 0.7, 0.65, 0.8, 0.62, 0.7, 0.75)
verifier_detail(ut514(force514(x514, yea, 1)), "S8 ex aequo dans r, pi_t constant")
verifier_detail(ut514(force514(x514, yea, 0.4)), "S8 ex aequo dans r, pi_t variable")
# Mediane des volumes = 100, deux annees au-dessus : groupe de moins de 3.
xsm <- c(100, 100, 100, 100, 100, 100, 120, 130)
verifier_detail(ut514(force514(xsm, y514, 0.4)), "S9 partition de Smirnov non calculable")
verifier_detail(ut514(f_d1, boot514(f_d1, p = 0.5, motif = c(RESET = MOTIF_MC_REPLIC_INSUFFISANTES,
                                                              CUSUM = MOTIF_MC_AUCUNE_REPLIC,
                                                              Runsr = MOTIF_MC_DISPERSION_NULLE,
                                                              KS = MOTIF_MC_ATOME_HORS_OBS,
                                                              SpearTps = MOTIF_MC_CONDITION))),
                "S12 p Monte-Carlo indisponible (motifs varies), pi_t constant")
f_v <- force514(x514, y514, 0.4)
verifier_detail(ut514(f_v, boot514(f_v, motif = c(RESET = MOTIF_MC_REPLIC_INSUFFISANTES,
                                                  Runsr = MOTIF_MC_AUCUNE_REPLIC,
                                                  CoxStuart = MOTIF_MC_REPLIC_INSUFFISANTES,
                                                  Intercept = MOTIF_MC_AUCUNE_REPLIC))),
                "S12 p Monte-Carlo indisponible, pi_t variable (S22 Runsr branche 3 sans p_mc)")
verifier_detail(ut514(f_d1, delta_equiv = 1e-6), "S13 TOST R14, p_plancher >= 0.30")
verifier_detail(ut514(f_d1, delta_equiv = 150), "S13 TOST de type test")
verifier_detail(ut514(f_d1, theta_equiv = 0.25), "S13 TOST R14 ou test (marge relative 25 %)")
# S10, S11 : regle R1 (deux branches et ECHEC possible) ; S15 jackknife.
verifier_detail(ut514(f_d1, alpha = 0.30), "S10 regle R1, alpha = 0.30")
verifier_detail(ut514(f_v, boot514(f_v, p = 0.5), alpha = 0.15), "S11 ECHEC possible, pi_t variable")
rob514 <- list(
  list(jack_non_evaluables = c(2L, 4L, 5L, 7L), jack_annees = c(1L, 3L, 6L, 8L),
       jack_usp_annees = c(-0.1, -0.1, -0.1, -0.1), jack_annee = 1L, jack_usp = -0.1),
  list(jack_non_evaluables = c(2L, 4L, 5L), jack_annees = c(1L, 3L, 6L),
       jack_usp_annees = c(-0.1, 0.1, 0), jack_annee = 1L, jack_usp = -0.1),
  list(jack_non_evaluables = 1:8, jack_annee = NULL))
for (k in seq_along(rob514)) {
  fj <- f_d1; fj$ecart_jackknife <- if (k < 3L) 0.05 else NULL
  verifier_detail(ut514(fj, robustesse = rob514[[k]]), sprintf("S15 jackknife, cas %d", k))
}
fj <- f_d1; fj$ecart_jackknife <- NULL
verifier_detail(ut514(fj, robustesse = list(jack_non_evaluables = c(2L, 3L, 4L, 5L), jack_annee = NULL)),
                "S15 jackknife, sigma_USP nul et plus de 3 annees non evaluables")
jk514 <- Filter(function(l) grepl("jackknife", l$test, fixed = TRUE),
                ut514(within(f_d1, ecart_jackknife <- 0.05), robustesse = rob514[[1]]))[[1]]$detail
verifier("S15 Q-5 : au-dela de 3 annees, leur seul nombre",
         grepl(", 4 annees non evaluables", jk514, fixed = TRUE) &&
           startsWith(jk514, "4 annees les plus influentes sur sigma_USP, a egalite numerique (sigma_USP en baisse)") &&
           !grepl("2, 4, 5", jk514, fixed = TRUE))
jk3 <- Filter(function(l) grepl("jackknife", l$test, fixed = TRUE),
              ut514(within(f_d1, ecart_jackknife <- 0.05), robustesse = rob514[[2]]))[[1]]$detail
verifier("S15 Q-5 : jusqu'a 3 annees, citees",
         grepl("annee(s) 2, 4 et 5 non evaluable(s)", jk3, fixed = TRUE) &&
           grepl("a egalite numerique : 1, 3 et 6", jk3, fixed = TRUE))
# S14 : rapport de vraisemblance (fictif : p_mc presente, absente, borne en
# echec, solution au bord).
lr514 <- function(p_mc, lr = 0.5, motif = NA_character_)
  list(borne0 = list(lr = lr, p_mc = p_mc, err_mc = 0.01, motif_mc = motif, delta0 = 0,
                     sigma_contraint = 0.1, p_asymptotique = 0.3),
       borne1 = list(lr = 0, p_mc = p_mc, err_mc = 0.01, motif_mc = motif, delta0 = 1,
                     sigma_contraint = 0.1, p_asymptotique = 1))
verifier_detail(ut514(f_d1, lr_delta = lr514(0.4)), "S14 rapport de vraisemblance, p_mc presente, bord")
verifier_detail(ut514(f_v, lr_delta = lr514(NA_real_, motif = MOTIF_MC_ATOME_HORS_OBS)),
                "S14 rapport de vraisemblance, p_mc absente (motif et complement)")
verifier_detail(ut514(f_v, lr_delta = lr514(0.4, lr = NA_real_)),
                "S14 rapport de vraisemblance, borne en echec")
verifier_detail(ut514(force514(rep(110, 8), y514, 0), lr_delta = lr514(0.4)),
                "S14 rapport de vraisemblance, volumes constants")
# S16 : T-3a et T-3b (lignes de famille fictives).
cat514 <- list(A = .mc_entree(function(e) 1, "haut"), B = .mc_entree(function(e) 1, "haut"))
lf514 <- function(n, na_B = 0L) {
  S <- cbind(A = seq_len(n) / n, B = rev(seq_len(n)) / n)
  if (na_B) S[seq_len(na_B), "B"] <- NA
  list(stats_boot = S, stats_obs = list(A = 0.5, B = 0.5))
}
lig514 <- lapply(c("A", "B"), function(k) list(famille = "B. x", test = paste("test", k),
                                              type = "test", variante = "principale",
                                              sens = "ne pas rejeter", mc_nom = k, p_mc = 0.5))
p3a <- engine_p_famille(lig514, lf514(200, 10L), cat514)
p3b <- engine_p_famille(lig514, lf514(30), cat514)
verifier("S16 T-3a et T-3b : texte propre <= 2 phrases et <= 400 caracteres",
         length(p3a) >= 1L && length(p3b) >= 1L &&
           all(vapply(c(p3a, p3b), function(f) {
             tp <- texte_propre(f$args$detail)
             compter_phrases(tp) <= PHRASES_MAX && nchar(tp) <= PLAFOND_TEXTE_PROPRE &&
               nzchar(tp)
           }, logical(1))) &&
           grepl(PHRASE_FAMILLE_B_EFF_REDUIT, p3a[[1]]$args$detail, fixed = TRUE) &&
           startsWith(p3b[[1]]$args$detail, PHRASE_FAMILLE_B_EFF_INSUFFISANT))
# Merz-Wuthrich : S17 colonnes degenerees et non identifiables, S19 un residu
# par annee, S20 identifiabilite sans colonne retenue, S21 M6 (fonctions
# directes, sans bootstrap).
ex_m6 <- list(
  list(applicable = TRUE, sigma2_Jm2 = 0.1, sigma2_Jm3 = 0.2, quotient = 0.05, valeur = 0.05,
       retenu = "sigma2_(J-2)^2/sigma2_(J-3)", degeneree_Jm2 = FALSE, degeneree_Jm3 = FALSE),
  list(applicable = TRUE, sigma2_Jm2 = 0, sigma2_Jm3 = 0, quotient = NA_real_, valeur = 0,
       retenu = "sigma2_(J-2)", degeneree_Jm2 = TRUE, degeneree_Jm3 = TRUE),
  list(applicable = TRUE, sigma2_Jm2 = 1e-28, sigma2_Jm3 = 0.2, quotient = 1e-58, valeur = 1e-58,
       retenu = "sigma2_(J-2)^2/sigma2_(J-3)", degeneree_Jm2 = TRUE, degeneree_Jm3 = FALSE),
  list(applicable = TRUE, sigma2_Jm2 = 0.1, sigma2_Jm3 = 0, quotient = NA_real_, valeur = 0,
       retenu = "sigma2_(J-3)", degeneree_Jm2 = FALSE, degeneree_Jm3 = TRUE),
  list(applicable = TRUE, sigma2_Jm2 = 0.1, sigma2_Jm3 = 0.1, quotient = 0.1, valeur = 0.1,
       retenu = "sigma2_(J-2)", degeneree_Jm2 = FALSE, degeneree_Jm3 = FALSE),
  list(applicable = FALSE))
verifier("S21 M6 : J-2, J-3, les deux, quotient NA, ex aequo, non applicable",
         all(vapply(ex_m6, function(e) {
           d <- .mw_detail_extrapolation(e)
           compter_phrases(d) <= PHRASES_MAX && nchar(d) <= PLAFOND_TEXTE_PROPRE
         }, logical(1))))
tri514 <- unname(as.matrix(utils::read.csv(file.path(.racine514, "tests", "donnees",
                                                     "triangle_mw.csv"))[, -1]))
storage.mode(tri514) <- "double"
aj514 <- mw_ajuster(tri514)
bt514 <- mw_bootstrap(aj514, B = 99)
verifier_detail(mw_tests(aj514, bt514), "Merz-Wuthrich, triangle de reference a B = 99")
cols514 <- data.frame(j = 1:4, n_facteurs = c(6L, 5L, 4L, 3L))
verifier("S17 phrases d'exclusion de colonnes (K fini et NA) : une phrase chacune",
         all(vapply(list(list(K = 1L, eligibles = 5L), list(K = NA_integer_, eligibles = 3L)),
                    function(r) {
                      r$exclues <- cols514; r$non_identifiables <- cols514
                      all(vapply(c(.mw_phrase_exclusion(r, "quoi", "de linearite"),
                                   .mw_phrase_non_identifiable(r),
                                   .mw_phrase_origine_non_identifiable(r)),
                                 function(s) identical(compter_phrases(s), 1L), logical(1)))
                    }, logical(1))))

# Pose des mentions de regime (specification finale, par. 2 et 8, A4).
nom_r7 <- c("Independance ratio S/P vs volume", "Tendance monotone du ratio S/P",
            "Tendance par signes du ratio S/P", "Autocorrelation d'ordre 1 (Durbin-Watson)",
            "Test des suites (aleatoire des signes)")
nom_diag_r7 <- c("Correlation ratio S/P vs temps", "Egalite des lois petits vs gros volumes (2 ech.)")
nom_r15 <- c("Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts",
             "Test des suites sur ratios bruts", "Rupture de niveau (sup-F) sur ratios bruts",
             "Stabilite cumulee (OLS-CUSUM) sur ratios bruts",
             "Valeur aberrante isolee (Grubbs) sur ratios bruts")
porte <- function(tt, nom, k) grepl(MENTIONS[[k]],
  Filter(function(l) identical(l$test, nom), tt)[[1]]$detail, perl = TRUE)
lignes_avec <- function(tt, k) vapply(Filter(function(l) grepl(MENTIONS[[k]], l$detail, perl = TRUE),
                                             tt), `[[`, character(1), "test")
t_d1 <- ut514(f_d1); t_v <- ut514(force514(x514, y514, 0.4))
t_b <- ut514(force514(x514, y514, 1 - 5e-7)); t_vc <- ut514(force514(rep(110, 8), y514, 0))
t_10 <- ut514(force514(x10, y10, 0.4))
verifier("A4 M20a : lignes R7 de type test a delta = 1 (p exacte), jamais R15 ni diagnostics par decision",
         setequal(lignes_avec(t_d1, "M20a"), nom_r7) &&
           !any(lignes_avec(res514$premium$tests, "M20a") %in% c(nom_r15, nom_diag_r7)))
verifier("A4 M17a et M17b a pi_t variable : M17b sur les seuls diagnostics par decision R7, M17a sur les lignes R7 de type test et Runsr",
         setequal(lignes_avec(t_v, "M17b"), nom_diag_r7) &&
           setequal(lignes_avec(t_v, "M17a"), c(nom_r7, "Test des suites sur ratios bruts")) &&
           setequal(lignes_avec(res514$premium_interieur$tests, "M17b"), nom_diag_r7))
# Variante de M17a sans la proposition sur la p Monte-Carlo (constat Q-A1 de
# l'audit) : p Monte-Carlo de la ligne indisponible (motifs de M1, M3, M9).
t_vm <- ut514(f_v, boot514(f_v, motif = c(Runsr = MOTIF_MC_AUCUNE_REPLIC,
                                          SpearVol = MOTIF_MC_REPLIC_INSUFFISANTES,
                                          CoxStuart = MOTIF_MC_DISPERSION_NULLE)))
sans_mc514 <- c("Test des suites sur ratios bruts", "Independance ratio S/P vs volume",
                "Tendance par signes du ratio S/P")
verifier("A4 M17a sans p Monte-Carlo : variante sans 'en tient lieu' sur les lignes dont la p Monte-Carlo manque, M17a ailleurs, texte propre conforme",
         setequal(lignes_avec(t_vm, "M17a_sans_mc"), sans_mc514) &&
           !any(lignes_avec(t_vm, "M17a") %in% sans_mc514) &&
           setequal(c(lignes_avec(t_vm, "M17a"), lignes_avec(t_vm, "M17a_sans_mc")),
                    c(nom_r7, "Test des suites sur ratios bruts")) &&
           !any(vapply(Filter(function(l) l$test %in% sans_mc514, t_vm), function(l)
             grepl("en tient lieu", l$detail, fixed = TRUE), logical(1))) &&
           startsWith(MENTION_PI_VARIABLE_TEST,
                      sub("\\.$", "", MENTION_PI_VARIABLE_TEST_SANS_MC)))
verifier_detail(t_vm, "S12 M17a sans p Monte-Carlo (Runsr, SpearVol, Cox-Stuart), pi_t variable")
# Mention M8 (correction d'actuary) : motif ex aequo joint apres le texte
# propre des diagnostics par decision (Spearman ratio / temps, Smirnov) et
# de Runs MW a p_min non attribuee.
t_ea1 <- ut514(force514(x514, yea, 1)); t_ea4 <- ut514(force514(x514, yea, 0.4))
f_sm <- force514(x514, y514, 0.4); f_sm$z[2] <- f_sm$z[1]
t_sm <- ut514(f_sm, boot514(force514(x514, y514, 0.4)))
verifier("A4 M8 sur Spearman ratio / temps (ex aequo dans r, pi_t constant et variable) et Smirnov (ex aequo dans z), en fin de detail avec point final",
         porte(t_ea1, "Correlation ratio S/P vs temps", "M8_rangs") &&
           porte(t_ea4, "Correlation ratio S/P vs temps", "M8_rangs") &&
           porte(t_sm, "Egalite des lois petits vs gros volumes (2 ech.)", "M8_smirnov") &&
           all(vapply(list(t_ea1, t_ea4), function(t) endsWith(Filter(function(l)
             identical(l$test, "Correlation ratio S/P vs temps"), t)[[1]]$detail,
             "p_min et p exacte non attribuees."), logical(1))) &&
           !porte(t_v, "Correlation ratio S/P vs temps", "M8_rangs"))
verifier("A4 M19 sur les lignes H3 a pi_t variable dont la p non simulee est finie, jamais a pi_t constant",
         all(c("Shapiro-Wilk sur residus standardises", "Jarque-Bera", "Cramer-von Mises",
               "Kolmogorov-Smirnov contre N(0,1)") %in% lignes_avec(t_v, "M19")) &&
           !length(lignes_avec(t_d1, "M19")))
verifier("A4 M18 dans la bande (lignes R7 a p exacte, diagnostics compris), M20b a volumes constants, ni l'un ni l'autre sur R15",
         length(lignes_avec(t_b, "M18")) >= 5L && !any(lignes_avec(t_b, "M18") %in% nom_r15) &&
           !length(lignes_avec(t_b, "M20a")) &&
           all(lignes_avec(t_vc, "M20b") %in% nom_r7) && length(lignes_avec(t_vc, "M20b")) >= 1L)
verifier("A4 M21 sur les deux lignes Spearman a T = 10",
         setequal(lignes_avec(t_10, "M21"), c("Independance ratio S/P vs volume",
                                              "Correlation ratio S/P vs temps")))
verifier("A4 M22 sur la ligne de Pitman en permutations aleatoires (T = 10), jamais a T = 8",
         identical(lignes_avec(t_10, "M22"), "Test de Pitman sur la pente (lien positif pertes / volume)") &&
           !length(lignes_avec(t_d1, "M22")))

## --- A5 : controle de source -------------------------------------------------------
verifier("A5 .mw_detail_extrapolation() sans argument sens",
         identical(names(formals(.mw_detail_extrapolation)), "ex"))
interdits514 <- c("rangs", "residus declares", "Valeurs : j = ", "k = 1 (",
                  "Sensibilite indicative", "loi de reference exacte seulement a pi_t constant",
                  "que z = P epsilon ne verifie pas", "est nommee par nature_p")
verifier("A5 aucun detail des six cas ne contient les valeurs retirees par Q-3, les anciens textes de regime ni le renvoi a nature_p",
         {
           d <- unlist(lapply(res514, function(r) vapply(r$tests, `[[`, character(1), "detail")))
           tr <- d[vapply(d, function(s) any(vapply(interdits514, grepl, logical(1), s,
                                                    fixed = TRUE)), logical(1))]
           if (!length(tr)) TRUE else paste(tr, collapse = " | ")
         })

fin_fichier()
