###############################################################################
#  tests/unitaires/test_calibration.R  --  CALIBRATION REGLEMENTAIRE
#
#  Tables des annexes II et XIV, bareme de credibilite (annexe XVII, section
#  G), parametre final sigma_USP (sections B(4), C et D(4)), et parcours de
#  bout en bout par run_engine() sur trois segments modifies par M6 (issue
#  #61).
#  Sources des valeurs :
#  - annexes II et XIV : version consolidee du 14.11.2024 du reglement
#    delegue (UE) 2015/35 (xhtml a la racine du depot, qui fait foi), tableaux
#    sous le marqueur M6, soit le reglement delegue (UE) 2019/981 de la
#    Commission du 8 mars 2019, JO L 161 du 18.6.2019, p. 1 (issue #19).
#    Annexe II : lignes 36887 a 37140 environ du xhtml ; annexe XIV : lignes
#    81342 a 81454. Les valeurs de la version d'origine (JOUE L 12 du
#    17.1.2015, p. L 12/230 et L 12/269) sont perimees et ne sont plus
#    testees ;
#  - annexe XVII (sous le marqueur B, non modifiee sur ces points) : section
#    B(4) p. L 12/273, section D(4) p. L 12/277, section G p. L 12/282 du
#    JOUE L 12 du 17.1.2015.
#  Les valeurs sont ressaisies ici independamment des tables du moteur
#  (double saisie) : pour les annexes II et XIV, depuis la table etablie par
#  l'agent regulatory sur la version consolidee (issue #19), sans copie
#  depuis R/engine.R.
#
#  PAGINATION (reserve levee) : les pages de l'annexe XVII ci-dessus ont ete
#  verifiees le 22/09/2026 sur la version d'origine (JOUE L 12 du 17.1.2015 ;
#  agent regulatory, commentaire de l'issue #26). Elles ne valent que pour
#  cette version : le par. D(5) applique par le moteur est celui de la
#  version consolidee, dont la formule differe de celle d'origine (ADR 0005).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_calibration.R")

champ <- function(liste, nom) vapply(liste, function(s) s[[nom]], numeric(1))

## --- Tables des annexes II et XIV (double saisie, version en vigueur M6) ----
prime_II   <- c(10, 8, 15, 8, 14, 19, 8.3, 6.4, 13, 17, 17, 17) / 100
reserve_II <- c(9, 8, 11, 10, 11, 17.2, 5.5, 22, 20, 20, 20, 20) / 100
prime_XIV   <- c(5, 8.5, 9.6, 17) / 100
reserve_XIV <- c(5.7, 14, 11, 17) / 100
verifier("Annexe II : ecarts types standard des 12 segments (prime, reserve)",
         {
           inf <- lapply(1:12, usp_segment_infos, annexe = "II")
           isTRUE(proche(champ(inf, "sigma_prime_brut"), prime_II)) &&
             isTRUE(proche(champ(inf, "sigma_reserve"), reserve_II))
         })
verifier("Annexe XIV : ecarts types standard des 4 segments (prime, reserve)",
         {
           inf <- lapply(1:4, usp_segment_infos, annexe = "XIV")
           isTRUE(proche(champ(inf, "sigma_prime_brut"), prime_XIV)) &&
             isTRUE(proche(champ(inf, "sigma_reserve"), reserve_XIV))
         })
# Une assertion par valeur remplacee par le reglement delegue (UE) 2019/981
# (M6), avec la ligne du xhtml consolide du 14.11.2024 (issue #19). Valeurs
# saisies en toutes lettres, independamment des vecteurs ci-dessus.
valeur_M6 <- function(annexe, segment, champ_nom, attendu, ligne, avant) {
  verifier(sprintf("M6 : %s-%d, %s = %s %% (xhtml l. %d ; %s %% en 2015)",
                   annexe, segment, champ_nom, attendu, ligne, avant),
           proche(usp_segment_infos(segment, annexe)[[champ_nom]], attendu / 100))
}
valeur_M6("II",  6, "sigma_prime_brut", 19,   37030, 12)
valeur_M6("II",  6, "sigma_reserve",    17.2, 37033, 19)
valeur_M6("II",  7, "sigma_prime_brut", 8.3,  37047, 7)
valeur_M6("II",  7, "sigma_reserve",    5.5,  37050, 12)
valeur_M6("II",  8, "sigma_prime_brut", 6.4,  37064, 9)
valeur_M6("II",  8, "sigma_reserve",    22,   37067, 20)
valeur_M6("XIV", 1, "sigma_reserve",    5.7,  81403, 5)
valeur_M6("XIV", 3, "sigma_prime_brut", 9.6,  81434, 8)
valeur_M6("XIV", 4, "sigma_reserve",    17,   81454, 20)
verifier("SEGMENTS : 16 cles uniques annexe-segment",
         nrow(SEGMENTS) == 16 && !anyDuplicated(SEGMENTS$cle) &&
         all(c("II-1", "II-12", "XIV-1", "XIV-4") %in% SEGMENTS$cle))
verifier("usp_segment_infos : segment 1 de l'annexe XIV = frais medicaux, bareme court",
         {
           s <- usp_segment_infos(1, "XIV")
           s$sigma_prime_brut == 0.05 && s$bareme == "court" && s$annexe == "XIV"
         })
verifier("usp_segment_infos : erreur pour un segment inexistant (II-13, II-0, XIV-5)",
         leve_erreur(usp_segment_infos(13, "II")) && leve_erreur(usp_segment_infos(0, "II")) &&
         leve_erreur(usp_segment_infos(5, "XIV")))
# Issue #33 (defaut releve par audit, repris de l'issue #7), corrige.
verifier("usp_segment_infos : une annexe inconnue (xiv en minuscules, III, NA, vecteur) est refusee (#33)",
         leve_erreur(usp_segment_infos(1, "xiv")) && leve_erreur(usp_segment_infos(1, "III")) &&
         leve_erreur(usp_segment_infos(1, NA_character_)) &&
         leve_erreur(usp_segment_infos(1, c("II", "XIV"))) && leve_erreur(usp_segment_infos(1, 2)))
verifier("usp_bareme_segment : une annexe inconnue est refusee, y compris sans segment (#33)",
         leve_erreur(usp_bareme_segment(1, "xiv")) && leve_erreur(usp_bareme_segment(NULL, "III")) &&
         identical(usp_bareme_segment(NULL, "II"), "court"))

## --- Bareme de credibilite (section G) ---------------------------------------
long  <- c(34, 43, 51, 59, 67, 74, 81, 87, 92, 96, 100) / 100     # T = 5..15
court <- c(34, 51, 67, 81, 92, 100) / 100                          # T = 5..10
verifier("Credibilite, bareme long (G(1)) : T = 5..15",
         proche(vapply(5:15, usp_credibilite, 0, bareme = "long"), long))
verifier("Credibilite, bareme court (G(2)) : T = 5..10",
         proche(vapply(5:10, usp_credibilite, 0, bareme = "court"), court))
verifier("Credibilite : 100 % au-dela du bareme (15 et plus / 10 et plus)",
         all(vapply(c(16, 20, 40), usp_credibilite, 0, bareme = "long") == 1) &&
         all(vapply(c(11, 15, 40), usp_credibilite, 0, bareme = "court") == 1))
verifier("Credibilite : T = 8 (profondeur du projet) -> 59 % (long), 81 % (court)",
         usp_credibilite(8, "long") == 0.59 && usp_credibilite(8, "court") == 0.81)
verifier("Credibilite : T < 5 refuse (T = 4, 1, 0), dans les deux baremes",
         leve_erreur(usp_credibilite(4, "court")) && leve_erreur(usp_credibilite(4, "long")) &&
         leve_erreur(usp_credibilite(1)) && leve_erreur(usp_credibilite(0)))
verifier("Credibilite : bareme inconnu refuse", leve_erreur(usp_credibilite(8, "moyen")))
verifier("Credibilite : croissante en T",
         all(diff(vapply(5:20, usp_credibilite, 0, bareme = "long")) >= 0) &&
         all(diff(vapply(5:20, usp_credibilite, 0, bareme = "court")) >= 0))
# Issue #33 (defaut releve par audit, repris de l'issue #7), corrige.
verifier("Credibilite : une duree non entiere, non finie, manquante ou multiple est refusee explicitement (#33)",
         leve_erreur(usp_credibilite(7.5)) && leve_erreur(usp_credibilite(Inf)) &&
         leve_erreur(usp_credibilite(NA_real_)) && leve_erreur(usp_credibilite(c(8, 9))) &&
         leve_erreur(usp_credibilite("8")) && usp_credibilite(8L) == 0.81)

## --- Attribution du bareme (G(1) et G(2)) -----------------------------------
verifier("Bareme : annexe II segments 1, 5, 6 -> long",
         all(vapply(c(1, 5, 6), usp_bareme_segment, "", annexe = "II") == "long"))
verifier("Bareme : annexe II segments 2-4 et 7-12 -> court",
         all(vapply(c(2:4, 7:12), usp_bareme_segment, "", annexe = "II") == "court"))
verifier("Bareme : annexe XIV, tous segments (y compris les numeros 1, 5, 6) -> court",
         all(vapply(c(1:4, 5, 6), usp_bareme_segment, "", annexe = "XIV") == "court"))
verifier("Bareme : segment absent (NULL ou NA) -> court",
         usp_bareme_segment(NULL) == "court" && usp_bareme_segment(NA) == "court")

## --- Parametre final, methodes lognormales (section B(4)) -------------------
# sigma_USP = c * sigma(delta, gamma) * sqrt((T+1)/(T-1)) + (1 - c) * sigma_std
fit_fictif <- function(T, sigma) list(T = T, sigma = sigma)
verifier("usp_parametre : T = 8, bareme court, calcul a la main",
         {
           p <- usp_parametre(fit_fictif(8, 0.12), 0.10, "court")
           isTRUE(proche(p$correction_taille, sqrt(9 / 7))) &&
             isTRUE(proche(p$credibilite, 0.81)) &&
             isTRUE(proche(p$sigma_estime, 0.12 * sqrt(9 / 7))) &&
             isTRUE(proche(p$sigma_usp, 0.81 * 0.12 * sqrt(9 / 7) + 0.19 * 0.10, rel = 1e-14)) &&
             isTRUE(proche(p$variation_relative, p$sigma_usp / 0.10 - 1, rel = 1e-14))
         })
verifier("usp_parametre : T = 8, bareme long (c = 59 %)",
         proche(usp_parametre(fit_fictif(8, 0.12), 0.10, "long")$sigma_usp,
                0.59 * 0.12 * sqrt(9 / 7) + 0.41 * 0.10, rel = 1e-14))
verifier("usp_parametre : T = 5 (minimum), correction sqrt(6/4), c = 34 %",
         proche(usp_parametre(fit_fictif(5, 0.2), 0.08, "court")$sigma_usp,
                0.34 * 0.2 * sqrt(6 / 4) + 0.66 * 0.08, rel = 1e-14))
verifier("usp_parametre : T = 15, bareme long -> c = 1, sigma_USP = sigma * sqrt(16/14)",
         proche(usp_parametre(fit_fictif(15, 0.07), 0.10, "long")$sigma_usp,
                0.07 * sqrt(16 / 14), rel = 1e-14))
verifier("usp_parametre : sigma estime corrige = sigma standard -> sigma_USP = sigma standard",
         proche(usp_parametre(fit_fictif(8, 0.10 / sqrt(9 / 7)), 0.10, "court")$sigma_usp,
                0.10, rel = 1e-14))
verifier("usp_parametre : T = 4 refuse", leve_erreur(usp_parametre(fit_fictif(4, 0.1), 0.1)))

## --- Parametre final, Merz-Wuthrich (section D(4)) ---------------------------
# sigma = c * sqrt(MSEP) / reserve + (1 - c) * sigma_std ; duree = I + 1
# (G(3)(c)) ; aucune correction de taille.
verifier("mw_parametre : I + 1 = 8 annees, bareme long, calcul a la main",
         {
           p <- mw_parametre(list(I = 7L, reserve = 2000), msep = 150^2,
                             sigma_standard = 0.09, bareme = "long")
           isTRUE(proche(p$sigma_estime, 150 / 2000)) &&
             isTRUE(proche(p$credibilite, 0.59)) && p$duree_credibilite == 8 &&
             isTRUE(proche(p$sigma_usp, 0.59 * 0.075 + 0.41 * 0.09, rel = 1e-14))
         })
verifier("mw_parametre : I + 1 = 4 annees refuse",
         leve_erreur(mw_parametre(list(I = 3L, reserve = 1), 1, 0.1)))
# Decision M4 (issue #7) : sigma(res,s,USP) est un coefficient de variation
# (racine(MSEP) / R) ; il n'est defini que pour une reserve totale R > 0. Une
# reserve negative donnait un sigma estime negatif et un sigma_USP inferieur au
# sigma standard, une reserve nulle un NaN, tous deux sans alerte. Les valeurs
# du scenario viennent du triangle decroissant de test_merz_wuthrich.R.
verifier("mw_parametre : reserve negative ou nulle refusee (erreur explicite)",
         leve_erreur(mw_parametre(list(I = 4L, reserve = -27.56661936), 6.11375969, 0.09, "long")) &&
         leve_erreur(mw_parametre(list(I = 4L, reserve = 0), 0, 0.09, "long")))
# La MSEP negative est impossible sur un triangle valide, mais mw_parametre() et
# mw_valider_ajustement() sont publiques : sans garde, sqrt() y produirait un NaN
# assorti d'un simple avertissement, soit exactement la sortie silencieuse que la
# decision M4 vise a supprimer.
verifier("mw_parametre : MSEP non finie ou negative refusee (erreur explicite)",
         leve_erreur(mw_parametre(list(I = 4L, reserve = 100), NA_real_, 0.09, "long")) &&
         leve_erreur(mw_parametre(list(I = 4L, reserve = 100), Inf, 0.09, "long")) &&
         leve_erreur(mw_parametre(list(I = 4L, reserve = 100), -5, 0.09, "long")))
verifier("mw_valider_ajustement : MSEP negative refusee malgre une reserve positive",
         !isTRUE(mw_valider_ajustement(list(I = 4L, reserve = 100), -5)$ok))
verifier("mw_valider_ajustement : R > 0 et MSEP finie -> ok, aucune erreur",
         {
           v <- mw_valider_ajustement(list(I = 4L, reserve = 100), 25)
           isTRUE(v$ok) && !length(v$erreurs)
         })
verifier("mw_valider_ajustement : le motif de refus donne la valeur de R",
         {
           v <- mw_valider_ajustement(list(I = 4L, reserve = -27.56661936), 6.11375969)
           !v$ok && length(v$erreurs) == 1 &&
             grepl("-27.5666", v$erreurs, fixed = TRUE) &&
             grepl("n'est pas applicable", v$erreurs, fixed = TRUE)
         })

## --- Bout en bout sur des segments modifies par M6 (issue #61) --------------
# run_engine() complet sur les donnees de non-regression (tests/donnees/),
# segment designe par son numero et son annexe : la valeur de l'annexe en
# vigueur doit atteindre parametre_final. Un segment au bareme long (II-6,
# primes), deux au bareme court (II-7, reserve1 ; XIV-4, reserve2), T = 8.
# Valeurs attendues saisies en dur (version consolidee du 14.11.2024, xhtml a
# la racine du depot, marqueur M6 ; lignes indiquees ci-dessous, les memes
# que plus haut), jamais relues de ANNEXE_II / ANNEXE_XIV. Credibilite a
# T = 8 : 59 % (G(1)), 81 % (G(2)).
# B = 19 : sigma_USP ne depend pas du bootstrap (estimation par maximum de
# vraisemblance, MSEP analytique) ; mesure : memes sigma_USP a B = 19 et
# B = 999 a 1e-10 pres. Les sigma_USP attendus sont ceux du tableau de #19
# (B = 999, graine 20260831, vises par le mainteneur), arrondis a 1e-8 ;
# tolerance relative 1e-6, celle de la non-regression (TOLERANCE).
# Mordant : contre le moteur anterieur a #19 (f67f5e0 ; 12 %, 12 % et 20 %),
# les 9 assertions sur sigma_standard et sigma_USP echouent ; les 3 sur T,
# le bareme et c passent, M6 ne touchant pas la section G (mesure hors
# depot, issue #61).
.racine <- if (exists("RACINE", inherits = TRUE)) RACINE else "."
.ln_m6 <- utils::read.csv(file.path(.racine, "tests", "donnees", "donnees_ln.csv"))
.tri_m6 <- local({
  df <- utils::read.csv(file.path(.racine, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(df[, setdiff(names(df), "i")])
  storage.mode(m) <- "double"
  unname(m)
})
B_M6 <- 19
bout_en_bout_M6 <- list(
  list(methode = "premium",  annexe = "II",  segment = 6, sigma_std = 0.19,
       ligne = 37030, cred = 0.59, bareme = "long",  sigma_usp = 0.14835244),
  list(methode = "reserve1", annexe = "II",  segment = 7, sigma_std = 0.055,
       ligne = 37050, cred = 0.81, bareme = "court", sigma_usp = 0.10717284),
  list(methode = "reserve2", annexe = "XIV", segment = 4, sigma_std = 0.17,
       ligne = 81454, cred = 0.81, bareme = "court", sigma_usp = 0.04997785))
for (cas in bout_en_bout_M6) {
  res <- if (cas$methode == "reserve2")
    run_engine(methode = "reserve2", triangle = .tri_m6, segment = cas$segment,
               annexe = cas$annexe, B = B_M6)
  else run_engine(xt = .ln_m6$xt, yt = .ln_m6$yt, methode = cas$methode,
                  segment = cas$segment, annexe = cas$annexe, B = B_M6)
  pf <- res$parametre_final
  etiquette <- sprintf("run_engine %s, %s-%d", cas$methode, cas$annexe, cas$segment)
  verifier(sprintf("%s : T = 8, bareme %s, c = %g", etiquette, cas$bareme, cas$cred),
           isTRUE(res$ok) && res$metadata$T == 8 && res$metadata$bareme == cas$bareme &&
             isTRUE(proche(pf$credibilite, cas$cred)))
  verifier(sprintf("%s : sigma_standard = %g %% (xhtml l. %d, M6)", etiquette,
                   100 * cas$sigma_std, cas$ligne),
           proche(pf$sigma_standard, cas$sigma_std))
  # Relation du parametre final avec c et sigma_standard en dur : section
  # B(4) (et C) pour les methodes lognormales, correction sqrt(9/7) sur le
  # sigma(delta, gamma) de l'ajustement ; section D(4) pour Merz-Wuthrich,
  # racine(MSEP) / reserve, sans correction de taille.
  sigma_chapeau <- if (cas$methode == "reserve2")
    sqrt(res$msep$msep) / res$ajustement$reserve
  else res$ajustement$sigma * sqrt(9 / 7)
  verifier(sprintf("%s : sigma_USP = c * sigma estime%s + (1 - c) * sigma_standard",
                   etiquette, if (cas$methode == "reserve2") "" else " * sqrt(9/7)"),
           proche(pf$sigma_usp, cas$cred * sigma_chapeau + (1 - cas$cred) * cas$sigma_std,
                  rel = 1e-12))
  verifier(sprintf("%s : sigma_USP = %.8f (tableau de #19, B = 999)", etiquette, cas$sigma_usp),
           proche(pf$sigma_usp, cas$sigma_usp, rel = 1e-6))
}
rm(res, pf, cas)

fin_fichier()
