###############################################################################
#  tests/unitaires/test_calibration.R  --  CALIBRATION REGLEMENTAIRE
#
#  Tables des annexes II et XIV, bareme de credibilite (annexe XVII, section
#  G), parametre final sigma_USP (sections B(4), C et D(4)).
#  Source des valeurs : reglement delegue (UE) 2015/35, JOUE L 12 du
#  17.1.2015 : annexe II p. L 12/230, annexe XIV p. L 12/269, annexe XVII
#  section B(4) p. L 12/273, section D(4) p. L 12/277, section G p. L 12/282.
#  Les valeurs sont ressaisies ici independamment des tables du moteur
#  (double saisie).
#
#  DEUX RESERVES SUR CE BANDEAU, a lever avant remise du dossier.
#
#  1. La SOURCE est la version d'ORIGINE de 2015. Les annexes II et XIV ont
#     ete remplacees depuis par le reglement delegue (UE) 2019/981 (marqueur
#     M6 de la version consolidee) : neuf ecarts-types standard y different.
#     La double saisie de ce fichier ne protege donc de rien sur ces neuf
#     valeurs, puisqu'elle reproduit la meme source perimee que le moteur.
#     Voir issue #19.
#  2. La PAGINATION n'a jamais ete verifiee sur piece : elle descend d'une
#     source interne a l'autre (ADR 0005). Elle est conservee ici a titre
#     indicatif, non comme une citation du Journal officiel.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_calibration.R")

champ <- function(liste, nom) vapply(liste, function(s) s[[nom]], numeric(1))

## --- Tables des annexes II et XIV (double saisie) ---------------------------
prime_II   <- c(10, 8, 15, 8, 14, 12, 7, 9, 13, 17, 17, 17) / 100
reserve_II <- c(9, 8, 11, 10, 11, 19, 12, 20, 20, 20, 20, 20) / 100
prime_XIV   <- c(5, 8.5, 8, 17) / 100
reserve_XIV <- c(5, 14, 11, 20) / 100
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
# Issue #33 (defaut releve par audit, repris de l'issue #7)
echec_attendu("usp_segment_infos : une annexe inconnue (xiv en minuscules, III) est refusee",
              "constat audit : traitee silencieusement comme l'annexe II",
              leve_erreur(usp_segment_infos(1, "xiv")) && leve_erreur(usp_segment_infos(1, "III")))

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
# Issue #33 (defaut releve par audit, repris de l'issue #7)
echec_attendu("Credibilite : une duree non entiere est refusee explicitement",
              "constat audit : T = 7.5 renvoie NA sans erreur",
              leve_erreur(usp_credibilite(7.5)))

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

fin_fichier()
