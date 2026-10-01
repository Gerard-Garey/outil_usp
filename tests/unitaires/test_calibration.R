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
# Issue #105 : erreur d'usage nommant segment en appel direct (texte "1"
# refuse sans conversion, decision du mainteneur du 27/09/2026, Q-E0b-2).
verifier("usp_segment_infos : segment c(1, 2), integer(0), NA, Inf, 1.5, TRUE, \"1\", c(a = 1), matrix(1) -> erreur d'usage nommant segment (#105)",
         all(vapply(list(c(1, 2), integer(0), NA, NA_real_, Inf, 1.5, TRUE, "1",
                         c(a = 1), matrix(1)),
                    function(s) {
                      e <- tryCatch(usp_segment_infos(s, "II"), error = function(e) e)
                      inherits(e, "error") && startsWith(conditionMessage(e), "segment = ") &&
                        grepl("un nombre scalaire fini entier, sans attribut, est attendu",
                              conditionMessage(e), fixed = TRUE)
                    }, logical(1))))
verifier("usp_segment_infos : les seize segments acceptes en entier (1L) et en double (1), memes caracteristiques (#105)",
         {
           sans_num <- function(l) { l$segment <- NULL; l }
           paires <- rbind(data.frame(a = "II", k = 1:12), data.frame(a = "XIV", k = 1:4))
           all(mapply(function(a, k) {
             d <- tryCatch(usp_segment_infos(as.double(k), a), error = function(e) NULL)
             i <- tryCatch(usp_segment_infos(as.integer(k), a), error = function(e) NULL)
             !is.null(d) && !is.null(i) && identical(sans_num(d), sans_num(i))
           }, paires$a, paires$k))
         })
verifier("usp_segment_infos : message du segment inconnu inchange (II-13, XIV-5 ; #105)",
         identical(tryCatch(usp_segment_infos(13, "II"), error = conditionMessage),
                   "Segment 13 inconnu dans l'annexe II.") &&
           identical(tryCatch(usp_segment_infos(5, "XIV"), error = conditionMessage),
                     "Segment 5 inconnu dans l'annexe XIV."))
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
verifier("Bareme : annexe XIV, tous segments (y compris le numero 1) -> court",
         all(vapply(1:4, usp_bareme_segment, "", annexe = "XIV") == "court"))
verifier("Bareme : segment absent (NULL) -> court, dans les deux annexes",
         usp_bareme_segment(NULL) == "court" && usp_bareme_segment(NULL, "XIV") == "court")
# Issue #133 (avis d'actuary Q-E1d-4) : en appel direct, usp_bareme_segment()
# controle segment comme run_engine(). Avant #133, "1", TRUE, factor(5),
# c(a = 1) rendaient "long", NA, 1.5, 99 et 5 en annexe XIV rendaient
# "court", c(1, 2) et integer(0) levaient une erreur R sans nom d'argument.
motif_bareme <- function(expr, debut) {
  m <- tryCatch({ expr; NA_character_ }, error = conditionMessage)
  !is.na(m) && startsWith(m, debut)
}
verifier("Bareme : NA, NA_real_, NA_integer_, \"1\", TRUE, factor(5), c(a = 1), 1.5, c(1, 2), integer(0) -> erreur d'usage nommant segment, annexes II et XIV (#133)",
         all(vapply(list(NA, NA_real_, NA_integer_, "1", TRUE, factor(5), c(a = 1), 1.5,
                         c(1, 2), integer(0)),
                    function(s) motif_bareme(usp_bareme_segment(s, "II"), "segment = ") &&
                      motif_bareme(usp_bareme_segment(s, "XIV"), "segment = "),
                    logical(1))))
verifier("Bareme : segment absent de l'annexe (99 en annexe II, 5 en annexe XIV) -> erreur, message de usp_segment_infos() (#133)",
         identical(tryCatch(usp_bareme_segment(99, "II"), error = conditionMessage),
                   "Segment 99 inconnu dans l'annexe II.") &&
           identical(tryCatch(usp_bareme_segment(5, "XIV"), error = conditionMessage),
                     "Segment 5 inconnu dans l'annexe XIV.") &&
           identical(tryCatch(usp_bareme_segment(13, "II"), error = conditionMessage),
                     "Segment 13 inconnu dans l'annexe II."))
verifier("Bareme : annexe controlee avant segment (NA en annexe III -> erreur d'annexe ; #133)",
         motif_bareme(usp_bareme_segment(NA, "III"), "Annexe inconnue (III)"))
verifier("Bareme : segment entier stocke en integer accepte (5L -> long, 2L -> court ; #133)",
         identical(usp_bareme_segment(5L), "long") && identical(usp_bareme_segment(2L), "court"))
# Issue #133, point 2 : une valeur presque entiere est citee a 17 chiffres
# (1 + 1e-15 etait cite 1, valeur que le message refuse) ; une valeur exacte
# a 15 chiffres reste citee a 15 chiffres (0.3, et non 0.29999999999999999,
# ecriture de deparse() avec digits17 seul).
verifier("Message d'usage : segment 1 + 1e-15 cite a 17 chiffres (#133)",
         motif_bareme(usp_segment_infos(1 + 1e-15, "II"), "segment = 1.0000000000000011 : ") &&
           motif_bareme(usp_bareme_segment(1 + 1e-15, "II"), "segment = 1.0000000000000011 : "))
# Constat C1 de l'audit de #133 : la relecture de la valeur citee ne doit
# rien evaluer. Un attribut de type langage (deparse() retire le quote())
# etait execute par eval(str2lang(deparse(v))) ; l'effet de bord teste ici
# (assign dans l'environnement global) est cherche apres l'appel.
verifier("Message d'usage : un attribut de type langage n'est pas execute, la valeur est citee a 17 chiffres (#133, audit C1)",
         {
           if (exists("trace_c1_133", envir = globalenv(), inherits = FALSE))
             rm("trace_c1_133", envir = globalenv())
           effet <- quote(assign("trace_c1_133", TRUE, envir = globalenv()))
           m1 <- tryCatch(.engine_verifier_usage(B = 999, seed = structure(1 + 1e-15, a = effet),
                                                 bareme = NULL, segment = 1),
                          error = conditionMessage)
           m2 <- tryCatch(usp_bareme_segment(structure(1 + 1e-15, a = effet)),
                          error = conditionMessage)
           !exists("trace_c1_133", envir = globalenv(), inherits = FALSE) &&
             startsWith(m1, "seed = structure(1.0000000000000011, a = assign(") &&
             startsWith(m2, "segment = structure(1.0000000000000011, a = assign(")
         })
verifier("Message d'usage : -0, Inf, -Inf, NaN, NA_real_ cites tels quels, sans avertissement (#133)",
         {
           w <- FALSE
           v <- withCallingHandlers(
             vapply(list(-0, Inf, -Inf, NaN, NA_real_, c(NA, 1 + 1e-15)), .engine_saisie, ""),
             warning = function(e) { w <<- TRUE; invokeRestart("muffleWarning") })
           !w && identical(v, c("0", "Inf", "-Inf", "NaN", "NA_real_", "c(NA, 1.0000000000000011)"))
         })
verifier("Message B et alpha (engine_motif_b_alpha) : alpha 0.03 + 4e-18 cite a 17 chiffres, 0.03 et 99L cites a 15 (#133, audit C2)",
         startsWith(engine_motif_b_alpha(99, 0.03 + 4e-18), "B = 99 et alpha = 0.030000000000000002 : ") &&
           startsWith(engine_motif_b_alpha(99L, 0.03), "B = 99 et alpha = 0.03 : "))
verifier("Message d'usage : B, seed, alpha, sigma_standard presque entiers ou presque decimaux cites a 17 chiffres, valeurs exactes a 15 chiffres (#133)",
         motif_bareme(.engine_verifier_usage(B = 999 + 1e-13, seed = 1, bareme = NULL, segment = 1),
                      "B = 999.00000000000011 : ") &&
           motif_bareme(.engine_verifier_usage(B = 999, seed = 1 + 1e-15, bareme = NULL, segment = 1),
                        "seed = 1.0000000000000011 : ") &&
           motif_bareme(.engine_verifier_usage(B = 999, seed = 1, bareme = NULL, alpha = 0.3,
                                               segment = 1), "alpha = 0.3 : ") &&
           motif_bareme(.engine_verifier_usage(B = 999, seed = 1, bareme = NULL,
                                               alpha = 0.3 + 1e-16, segment = 1),
                        "alpha = 0.3000000000000001 : ") &&
           motif_bareme(.engine_verifier_usage(B = 999, seed = 1, bareme = NULL,
                                               sigma_standard = -0.1), "sigma_standard = -0.1 : ") &&
           motif_bareme(.engine_verifier_usage(B = 999, seed = 1, bareme = NULL,
                                               sigma_standard = -(0.1 + 2e-17)),
                        "sigma_standard = -0.10000000000000002 : "))

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
# B = B_MIN_USAGE = 99, le minimum admis par run_engine() (constat C1 de la
# revue finale d'E1) : sigma_USP ne depend pas du bootstrap (estimation par
# maximum de vraisemblance, MSEP analytique) ; mesure du 27/09/2026 : sigma_USP
# egaux a B = 99 et B = 999 pour les trois cas ci-dessous (difference nulle
# en double precision). Les sigma_USP attendus sont ceux du tableau de #19
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
B_M6 <- B_MIN_USAGE
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
                  segment = cas$segment, annexe = cas$annexe, B = B_M6,
                  nature_donnees = if (cas$methode == "premium") "brutes")
  pf <- res$parametre_final
  etiquette <- sprintf("run_engine %s, %s-%d", cas$methode, cas$annexe, cas$segment)
  # bareme_saisi (issue #93) : bareme deduit du segment, drapeau FALSE.
  verifier(sprintf("%s : T = 8, bareme %s (non saisi), c = %g", etiquette, cas$bareme, cas$cred),
           isTRUE(res$ok) && res$metadata$T == 8 && res$metadata$bareme == cas$bareme &&
             identical(res$metadata$bareme_saisi, FALSE) &&
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

## --- Parametre standard remplace : donnees brutes ou nettes (issue #55) ------
# Decision M13 du mainteneur (commentaire de l'issue #55, 23/09/2026) et
# lecture de l'agent regulatory (commentaire du 24/09/2026) :
# - facteur NP standard (reassurance non proportionnelle), saisi ici en dur,
#   independamment de R/engine.R : art. 117, paragraphe 3, deuxieme et
#   troisieme phrases (marqueur B, JOUE L 12/75) : 80 % pour les segments 1,
#   4 et 5 de l'annexe II, 100 % pour tous les autres ; art. 148,
#   paragraphe 3, deuxieme phrase (marqueur B, L 12/94) : 100 % pour tous
#   les segments de l'annexe XIV ;
# - donnees brutes : parametre remplace art. 218, paragraphe 1, point a) ii)
#   (c) ii) en sante), valeur standard = sigma brut de l'annexe (annexe XVII,
#   B(2)(c), marqueur M1) ; donnees nettes : point a) i) (c) i)), valeur
#   standard = NP standard x sigma brut (B(2)(d), marqueur M1) ;
# - methodes de reserve : sigma(res,s), sans NP ; donnees nettes exigees
#   (C(2)(c), D(2)(f)) : NULL ou "nettes" acceptes, "brutes" refuse
#   (decision du mainteneur du 25/09/2026) ;
# - toute saisie du sigma standard est une derogation, meme egale a la table,
#   signalee par le drapeau explicite metadata$sigma_standard_saisi pour les
#   trois methodes (decision du mainteneur du 25/09/2026).
np_II  <- c(80, 100, 100, 80, 80, 100, 100, 100, 100, 100, 100, 100) / 100
np_XIV <- c(100, 100, 100, 100) / 100
verifier("NP standard, annexe II : 80 % pour 1, 4, 5 ; 100 % ailleurs (art. 117, par. 3)",
         identical(vapply(1:12, function(k) usp_segment_infos(k, "II")$np_standard, 0), np_II))
verifier("NP standard, annexe XIV : 100 % pour les 4 segments (art. 148, par. 3)",
         identical(vapply(1:4, function(k) usp_segment_infos(k, "XIV")$np_standard, 0), np_XIV))
verifier("SEGMENTS : colonne np_standard alignee sur les deux annexes (16 cles)",
         identical(SEGMENTS$np_standard, c(np_II, np_XIV)))

ps_b <- usp_parametre_standard("premium", 1, "II", "brutes")
ps_n <- usp_parametre_standard("premium", 1, "II", "nettes")
verifier("Donnees brutes II-1 : sigma standard = sigma brut de la table, sans multiplication (identical), point a) ii), B(2)(c)",
         identical(ps_b$sigma_standard, ANNEXE_II$sigma_prime_brut[1]) &&
           identical(ps_b$sigma_standard, 0.10) &&
           identical(ps_b$point_art218, "art. 218, paragraphe 1, point a) ii)") &&
           grepl("section B, paragraphe 2, point c)", ps_b$exigence_donnees, fixed = TRUE) &&
           !ps_b$saisie && identical(ps_b$nature_donnees, "brutes"))
verifier("Donnees nettes II-1 : sigma standard = 0,8 x 10 % = 8 %, point a) i), B(2)(d)",
         isTRUE(proche(ps_n$sigma_standard, 0.08, rel = 1e-15)) &&
           identical(ps_n$np_standard, 0.8) && identical(ps_n$sigma_annexe, 0.10) &&
           identical(ps_n$point_art218, "art. 218, paragraphe 1, point a) i)") &&
           grepl("section B, paragraphe 2, point d)", ps_n$exigence_donnees, fixed = TRUE))
verifier("Donnees nettes : II-4 = 0,8 x 8 %, II-5 = 0,8 x 14 %, II-2 = 8 % (NP 100 %), II-6 = 19 %",
         isTRUE(proche(usp_parametre_standard("premium", 4, "II", "nettes")$sigma_standard, 0.064, rel = 1e-15)) &&
           isTRUE(proche(usp_parametre_standard("premium", 5, "II", "nettes")$sigma_standard, 0.112, rel = 1e-15)) &&
           identical(usp_parametre_standard("premium", 2, "II", "nettes")$sigma_standard, 0.08) &&
           identical(usp_parametre_standard("premium", 6, "II", "nettes")$sigma_standard, 0.19))
verifier("Annexe XIV : nettes = brutes (NP 100 %), points c) i) / c) ii)",
         {
           a <- usp_parametre_standard("premium", 1, "XIV", "brutes")
           b <- usp_parametre_standard("premium", 1, "XIV", "nettes")
           identical(a$sigma_standard, 0.05) && identical(b$sigma_standard, 0.05) &&
             identical(a$point_art218, "art. 218, paragraphe 1, point c) ii)") &&
             identical(b$point_art218, "art. 218, paragraphe 1, point c) i)")
         })
verifier("Nature non declaree ou irrecevable (NULL, NA, \"Brutes\", \"net\", vecteur, nombre) : erreur pour premium",
         leve_erreur(usp_parametre_standard("premium", 1, "II")) &&
           leve_erreur(usp_parametre_standard("premium", 1, "II", NA_character_)) &&
           leve_erreur(usp_parametre_standard("premium", 1, "II", "Brutes")) &&
           leve_erreur(usp_parametre_standard("premium", 1, "II", "net")) &&
           leve_erreur(usp_parametre_standard("premium", 1, "II", c("brutes", "nettes"))) &&
           leve_erreur(usp_parametre_standard("premium", 1, "II", 1)))
verifier("Methodes de reserve : sigma(res,s) de la table, point a) iv), NULL = \"nettes\" (exigence C(2)(c), D(2)(f))",
         {
           r1 <- usp_parametre_standard("reserve1", 1, "II")
           r1n <- usp_parametre_standard("reserve1", 1, "II", "nettes")
           r2 <- usp_parametre_standard("reserve2", 4, "XIV", "nettes")
           identical(r1, r1n) && identical(r1$sigma_standard, 0.09) &&
             identical(r1$point_art218, "art. 218, paragraphe 1, point a) iv)") &&
             grepl("section C, paragraphe 2, point c)", r1$exigence_donnees, fixed = TRUE) &&
             identical(r1$nature_donnees, "nettes") && is.na(r1$np_standard) &&
             identical(r2$sigma_standard, 0.17) &&
             identical(r2$point_art218, "art. 218, paragraphe 1, point c) iv)") &&
             grepl("section D, paragraphe 2, point f)", r2$exigence_donnees, fixed = TRUE)
         })
verifier("Methodes de reserve, appel direct : \"brutes\" (et valeur non reconnue) -> erreur R",
         leve_erreur(usp_parametre_standard("reserve1", 1, "II", "brutes")) &&
           leve_erreur(usp_parametre_standard("reserve2", 1, "II", "brutes")) &&
           leve_erreur(usp_parametre_standard("reserve1", 1, "II", "net")) &&
           leve_erreur(usp_parametre_standard("reserve2", 1, "II", NA_character_)))
verifier("Saisie libre : elle prime (derogation signalee), la valeur reglementaire reste restituee",
         {
           s <- usp_parametre_standard("premium", 1, "II", "nettes", sigma_standard = 0.12)
           s0 <- usp_parametre_standard("premium", NULL, "II", "brutes", sigma_standard = 0.12)
           identical(s$sigma_standard, 0.12) && isTRUE(s$saisie) &&
             isTRUE(proche(s$sigma_reglementaire, 0.08, rel = 1e-15)) &&
             identical(s0$sigma_standard, 0.12) && is.na(s0$sigma_reglementaire) &&
             leve_erreur(usp_parametre_standard("premium", NULL, "II", "brutes"))
         })

# Bout en bout, B = B_MIN_USAGE (sigma_USP ne depend pas du bootstrap, voir plus haut).
.args55 <- list(xt = .ln_m6$xt, yt = .ln_m6$yt, methode = "premium", segment = 1,
                annexe = "II", B = B_M6)
r_sans <- tryCatch(do.call(run_engine, .args55), error = function(e) e)
verifier("run_engine premium sans declaration : ok = FALSE avec motif, sans erreur R (M13)",
         !inherits(r_sans, "error") && identical(r_sans$ok, FALSE) &&
           any(grepl("Nature des donnees non declaree", r_sans$validation$erreurs, fixed = TRUE)))
verifier("run_engine premium, nature irrecevable (\"brut\", NA) : ok = FALSE, sans erreur R",
         identical(do.call(run_engine, c(.args55, nature_donnees = "brut"))$ok, FALSE) &&
           identical(do.call(run_engine, c(.args55, list(nature_donnees = NA_character_)))$ok, FALSE))
verifier("run_engine premium, sigma standard saisi sans declaration : refuse aussi (ok = FALSE)",
         identical(do.call(run_engine, c(.args55, sigma_standard = 0.12))$ok, FALSE))
verifier("engine_valider_donnees : nature obligatoire pour premium, \"brutes\" refuse en reserve, rien sans methode",
         isTRUE(engine_valider_donnees(.ln_m6$xt, .ln_m6$yt)$ok) &&
           isTRUE(engine_valider_donnees(.ln_m6$xt, .ln_m6$yt, nature_donnees = "brutes")$ok) &&
           !engine_valider_donnees(.ln_m6$xt, .ln_m6$yt, methode = "premium")$ok &&
           isTRUE(engine_valider_donnees(.ln_m6$xt, .ln_m6$yt, methode = "premium",
                                         nature_donnees = "nettes")$ok) &&
           isTRUE(engine_valider_donnees(.ln_m6$xt, .ln_m6$yt, methode = "reserve1")$ok) &&
           isTRUE(engine_valider_donnees(.ln_m6$xt, .ln_m6$yt, methode = "reserve1",
                                         nature_donnees = "nettes")$ok) &&
           {
             v <- engine_valider_donnees(.ln_m6$xt, .ln_m6$yt, methode = "reserve1",
                                         nature_donnees = "brutes")
             !v$ok && length(v$erreurs) == 1L &&
               grepl("section C, paragraphe 2, point c)", v$erreurs, fixed = TRUE)
           } &&
           {
             v <- engine_valider_donnees(.ln_m6$xt, .ln_m6$yt, methode = "reserve2",
                                         nature_donnees = "brutes")
             !v$ok && grepl("section D, paragraphe 2, point f)", v$erreurs[1], fixed = TRUE)
           } &&
           !engine_valider_donnees(.ln_m6$xt, .ln_m6$yt, methode = "reserve1",
                                   nature_donnees = "net")$ok)

r_b <- do.call(run_engine, c(.args55, nature_donnees = "brutes"))
r_n <- do.call(run_engine, c(.args55, nature_donnees = "nettes"))
verifier("run_engine II-1 : sigma standard 10 % (brutes) et 8 % (nettes), nature et saisie dans metadata",
         identical(r_b$parametre_final$sigma_standard, 0.10) &&
           isTRUE(proche(r_n$parametre_final$sigma_standard, 0.08, rel = 1e-15)) &&
           identical(r_b$metadata$nature_donnees, "brutes") &&
           identical(r_n$metadata$nature_donnees, "nettes") &&
           identical(r_b$metadata$sigma_standard_saisi, FALSE))
# Delta sigma_USP = -(1 - c)(1 - NP) sigma brut, exact et independant des
# donnees : sigma estime ne depend pas du sigma standard (avis actuary, #55).
verifier("run_engine II-1 : sigma_USP(nettes) - sigma_USP(brutes) = -(1 - 0,59)(1 - 0,8) x 10 % = -0,0082",
         isTRUE(proche(r_n$parametre_final$sigma_usp - r_b$parametre_final$sigma_usp,
                       -(1 - 0.59) * (1 - 0.8) * 0.10, rel = 1e-10)) &&
           identical(r_n$parametre_final$sigma_estime, r_b$parametre_final$sigma_estime))
verifier("engine_parametre_standard : nature, point, exigence, sigma brut, NP, sigma retenu (nettes II-1)",
         {
           d <- engine_parametre_standard(r_n)
           v <- stats::setNames(d$valeur, d$grandeur); t <- stats::setNames(d$texte, d$grandeur)
           grepl("^nettes", t[["Nature declaree des donnees"]]) &&
             grepl("point a) i) :", t[["Parametre standard remplace"]], fixed = TRUE) &&
             grepl("B, paragraphe 2, point d)", t[["Exigence relative aux donnees"]], fixed = TRUE) &&
             identical(v[["sigma brut (primes) de l'annexe II"]], 0.10) &&
             identical(v[["Facteur NP standard (art. 117, paragraphe 3)"]], 0.8) &&
             identical(v[["sigma standard retenu dans le melange"]], r_n$parametre_final$sigma_standard) &&
             identical(t[["Origine du sigma standard retenu"]], "parametre reglementaire")
         })
r_d <- do.call(run_engine, c(.args55, nature_donnees = "nettes", sigma_standard = 0.12))
verifier("Saisie libre du sigma standard (premium) : conservee, derogation dans metadata et dans la restitution",
         identical(r_d$parametre_final$sigma_standard, 0.12) &&
           identical(r_d$metadata$sigma_standard_saisi, TRUE) &&
           {
             d <- engine_parametre_standard(r_d)
             identical(d$texte[d$grandeur == "Origine du sigma standard retenu"],
                       "sigma standard saisi, derogation au parametre reglementaire") &&
               isTRUE(proche(d$valeur[d$grandeur == "sigma standard reglementaire"], 0.08, rel = 1e-15))
           })
sans_exec <- function(r) { r$metadata[c("horodatage", "duree_sec")] <- NULL; r }
r1_sans <- run_engine(xt = .ln_m6$xt, yt = .ln_m6$yt, methode = "reserve1", segment = 1,
                      annexe = "II", B = B_M6)
r1_net <- run_engine(xt = .ln_m6$xt, yt = .ln_m6$yt, methode = "reserve1", segment = 1,
                     annexe = "II", B = B_M6, nature_donnees = "nettes")
r1_brut <- tryCatch(run_engine(xt = .ln_m6$xt, yt = .ln_m6$yt, methode = "reserve1", segment = 1,
                               annexe = "II", B = B_M6, nature_donnees = "brutes"),
                    error = function(e) e)
r2_sans <- run_engine(methode = "reserve2", triangle = .tri_m6, segment = 1, annexe = "II", B = B_M6)
r2_net <- run_engine(methode = "reserve2", triangle = .tri_m6, segment = 1, annexe = "II", B = B_M6,
                     nature_donnees = "nettes")
r2_brut <- tryCatch(run_engine(methode = "reserve2", triangle = .tri_m6, segment = 1, annexe = "II",
                               B = B_M6, nature_donnees = "brutes"),
                    error = function(e) e)
verifier("Methodes de reserve : NULL et \"nettes\" acceptes (resultats identical), sigma(res,s) = 9 %, metadata sans nature",
         identical(sans_exec(r1_sans), sans_exec(r1_net)) &&
           identical(sans_exec(r2_sans), sans_exec(r2_net)) &&
           identical(r1_sans$parametre_final$sigma_standard, 0.09) &&
           identical(r2_sans$parametre_final$sigma_standard, 0.09) &&
           !"nature_donnees" %in% c(names(r1_sans$metadata), names(r2_sans$metadata)))
verifier("Methodes de reserve : donnees \"brutes\" refusees (ok = FALSE, motif C(2)(c) / D(2)(f), sans erreur R)",
         !inherits(r1_brut, "error") && identical(r1_brut$ok, FALSE) &&
           any(grepl("section C, paragraphe 2, point c)", r1_brut$validation$erreurs, fixed = TRUE)) &&
           !inherits(r2_brut, "error") && identical(r2_brut$ok, FALSE) &&
           any(grepl("section D, paragraphe 2, point f)", r2_brut$validation$erreurs, fixed = TRUE)) &&
           identical(r2_brut$metadata$methode, "reserve2"))
# Ordre des champs : sigma_standard_saisi (#55) est suivi des seuls champs
# ajoutes par l'issue #37 (generateur et graines fixes), puis de
# bareme_saisi (#93), puis de n_fournies (#104), dernier avant les champs
# d'execution ; les champs ajoutes le sont en fin de metadata (patch des
# references, feuille ajoutee en fin de conteneur).
verifier("Drapeau explicite sigma_standard_saisi (FALSE sans saisie) pour les trois methodes, suivi des seuls champs de #37, de bareme_saisi (#93), de n_fournies (#104) puis de horodatage",
         identical(r_b$metadata$sigma_standard_saisi, FALSE) &&
           identical(r1_sans$metadata$sigma_standard_saisi, FALSE) &&
           identical(r2_sans$metadata$sigma_standard_saisi, FALSE) &&
           all(vapply(list(r_b, r1_sans, r2_sans), function(r) {
             nm <- names(r$metadata)
             entre <- nm[seq.int(match("sigma_standard_saisi", nm) + 1L, match("horodatage", nm) - 1L)]
             # seed_enveloppe_qq retire par l'issue #47 (enveloppe lue dans
             # le bootstrap), pour les trois methodes.
             attendu <- c("generateur", "seed_loi_nulle_sw", "bareme_saisi", "n_fournies")
             identical(entre, attendu)
           }, logical(1))))
verifier("Saisie EGALE a la table : derogation pour les trois methodes (drapeau TRUE, origine \"saisi\")",
         {
           e_p <- do.call(run_engine, c(.args55, nature_donnees = "brutes", sigma_standard = 0.10))
           e_1 <- run_engine(xt = .ln_m6$xt, yt = .ln_m6$yt, methode = "reserve1", segment = 1,
                             annexe = "II", B = B_M6, sigma_standard = 0.09)
           e_2 <- run_engine(methode = "reserve2", triangle = .tri_m6, segment = 1, annexe = "II",
                             B = B_M6, sigma_standard = 0.09)
           all(vapply(list(e_p, e_1, e_2), function(r) {
             d <- engine_parametre_standard(r)
             identical(r$metadata$sigma_standard_saisi, TRUE) &&
               identical(d$texte[d$grandeur == "Origine du sigma standard retenu"],
                         "sigma standard saisi, derogation au parametre reglementaire") &&
               identical(d$valeur[d$grandeur == "sigma standard retenu dans le melange"],
                         d$valeur[d$grandeur == "sigma standard reglementaire"])
           }, logical(1))) &&
             identical(e_p$parametre_final$sigma_usp, r_b$parametre_final$sigma_usp)
         })
verifier("engine_parametre_standard : table rendue visiblement ; drapeau absent -> erreur (pas de deduction)",
         isTRUE(withVisible(engine_parametre_standard(r_b))$visible) &&
           is.data.frame(engine_parametre_standard(r_b)) &&
           {
             r_x <- r1_sans; r_x$metadata$sigma_standard_saisi <- NULL
             leve_erreur(engine_parametre_standard(r_x))
           })
verifier("engine_parametre_standard, reserve : nettes (exigence), a) iv), derogation si sigma saisi (drapeau)",
         {
           d1 <- engine_parametre_standard(r1_sans)
           d2 <- engine_parametre_standard(r2_sans)
           r2s <- run_engine(methode = "reserve2", triangle = .tri_m6, segment = 1, annexe = "II",
                             B = B_M6, sigma_standard = 0.15)
           d3 <- engine_parametre_standard(r2s)
           grepl("^nettes", d1$texte[1]) && grepl("point a) iv)", d1$texte[2], fixed = TRUE) &&
             grepl("section C, paragraphe 2, point c)", d1$texte[3], fixed = TRUE) &&
             grepl("section D, paragraphe 2, point f)", d2$texte[3], fixed = TRUE) &&
             identical(d2$texte[d2$grandeur == "Origine du sigma standard retenu"],
                       "parametre reglementaire") &&
             identical(d3$texte[d3$grandeur == "Origine du sigma standard retenu"],
                       "sigma standard saisi, derogation au parametre reglementaire")
         })
## --- Bareme de credibilite saisi : derogation declaree (issue #93) ----------
# Source : annexe XVII, section G, points (1) et (2) (marqueur B, JOUE L 12
# du 17.1.2015, p. L 12/282) : le bareme est une fonction du segment et de
# T, le texte n'ouvre aucun choix. Decision du mainteneur du 26/09/2026
# (lecture (B), avis actuary de l'issue #93) : un bareme saisi est admis et
# signale par metadata$bareme_saisi, meme egal au bareme du segment
# (parallelisme strict avec sigma_standard_saisi) ; sans segment designe, le
# bareme "court" pose par convention est restitue comme non determine par
# la section G. Valeurs attendues du chiffrage de l'avis actuary (tableau
# du paragraphe 3, jeu donnees_ln.csv, brutes, a 1e-8 pres), saisies en dur ;
# tolerance relative 1e-6, celle des cas M6 ci-dessus.
# Le refus d'une valeur de bareme invalide ("moyen", "Court", NA,
# c("court", "long"), 1) par une erreur d'usage est teste dans
# test_controles_entree.R (issue #88).
sans_meta <- function(r) { r$metadata <- NULL; r }
meta_sans <- function(r, champs = c("horodatage", "duree_sec", "bareme_saisi")) {
  m <- r$metadata; m[champs] <- NULL; m
}
r_b1c <- do.call(run_engine, c(.args55, nature_donnees = "brutes", bareme = "court"))
r_b1l <- do.call(run_engine, c(.args55, nature_donnees = "brutes", bareme = "long"))
.args93_2 <- .args55; .args93_2$segment <- 2
r_b2  <- do.call(run_engine, c(.args93_2, nature_donnees = "brutes"))
r_b2l <- do.call(run_engine, c(.args93_2, nature_donnees = "brutes", bareme = "long"))
verifier("Bareme force : II-1 brutes \"court\" -> c = 0,81, sigma_USP = 0,11572284 ; II-2 brutes \"long\" -> c = 0,59, sigma_USP = 0,10325244 (#93)",
         identical(r_b1c$parametre_final$credibilite, 0.81) &&
           isTRUE(proche(r_b1c$parametre_final$sigma_usp, 0.11572284, rel = 1e-6)) &&
           identical(r_b2l$parametre_final$credibilite, 0.59) &&
           isTRUE(proche(r_b2l$parametre_final$sigma_usp, 0.10325244, rel = 1e-6)) &&
           identical(r_b1c$parametre_final$sigma_estime, r_b$parametre_final$sigma_estime) &&
           identical(r_b2l$parametre_final$sigma_estime, r_b2$parametre_final$sigma_estime))
# Identite exacte, independante des donnees : sigma estime corrige ne depend
# pas du bareme, seul le poids c du melange change.
verifier("Bareme force : sigma_USP(force) - sigma_USP(regl.) = (c_force - c_regl.) x (sigma estime corrige - sigma standard) (#93)",
         all(vapply(list(list(r_b1c, r_b), list(r_b2l, r_b2)), function(p) {
           f <- p[[1]]$parametre_final; g <- p[[2]]$parametre_final
           isTRUE(proche(f$sigma_usp - g$sigma_usp,
                         (f$credibilite - g$credibilite) * (g$sigma_estime - g$sigma_standard),
                         rel = 1e-10))
         }, logical(1))))
r1_c <- run_engine(xt = .ln_m6$xt, yt = .ln_m6$yt, methode = "reserve1", segment = 1,
                   annexe = "II", B = B_M6, bareme = "court")
r1_l <- run_engine(xt = .ln_m6$xt, yt = .ln_m6$yt, methode = "reserve1", segment = 1,
                   annexe = "II", B = B_M6, bareme = "long")
r2_c <- run_engine(methode = "reserve2", triangle = .tri_m6, segment = 1, annexe = "II",
                   B = B_M6, bareme = "court")
r2_l <- run_engine(methode = "reserve2", triangle = .tri_m6, segment = 1, annexe = "II",
                   B = B_M6, bareme = "long")
origine_bareme <- function(r) {
  d <- engine_parametre_standard(r); d$texte[d$grandeur == "Origine du bareme retenu"]
}
verifier("Drapeau bareme_saisi : FALSE sans saisie, TRUE avec saisie (contraire ou egale), trois methodes (#93)",
         all(vapply(list(r_b, r1_sans, r2_sans), function(r)
           identical(r$metadata$bareme_saisi, FALSE), logical(1))) &&
           all(vapply(list(r_b1c, r_b1l, r1_c, r1_l, r2_c, r2_l), function(r)
             identical(r$metadata$bareme_saisi, TRUE), logical(1))))
# Issue #131 (lecture R1, decision du mainteneur du 01/10/2026) : le detail
# de la ligne "Credibilite pleine atteinte" et l'avertissement de
# credibilite partielle nomment la derogation des que le bareme est saisi,
# meme egal au bareme du segment ; ces deux chaines sont donc retirees de la
# comparaison, et leur mention de la saisie est verifiee a part.
sans_cred <- function(r) {
  r <- sans_meta(r)
  r$validation$avertissements <- grep("credibilite partielle", r$validation$avertissements,
                                      value = TRUE, fixed = TRUE, invert = TRUE)
  r$controles <- lapply(r$controles, function(l) {
    if (identical(l$test, "Credibilite pleine atteinte")) l$detail <- NULL
    l
  })
  r
}
mentions_saisie <- function(r) {
  txt <- c(grep("credibilite partielle", r$validation$avertissements, value = TRUE, fixed = TRUE),
           unlist(lapply(r$controles, function(l)
             if (identical(l$test, "Credibilite pleine atteinte")) l$detail)))
  length(txt) > 0 && all(grepl(paste("bareme long saisi (valeurs de G(1)) : saisie declaree comme",
                                     "derogation (#93), egale au bareme reglementaire du segment II-1"),
                               txt, fixed = TRUE))
}
verifier("Saisie EGALE au bareme du segment (II-1 \"long\" : premium, reserve1, reserve2) : resultat identical hors metadata et chaines de credibilite (#131), drapeau TRUE, origine \"saisi, egal\" (#93)",
         all(vapply(list(list(r_b1l, r_b), list(r1_l, r1_sans), list(r2_l, r2_sans)), function(p)
           identical(sans_cred(p[[1]]), sans_cred(p[[2]])) &&
             mentions_saisie(p[[1]]) && !mentions_saisie(p[[2]]) &&
             identical(meta_sans(p[[1]]), meta_sans(p[[2]])) &&
             identical(p[[1]]$metadata$bareme_saisi, TRUE) &&
             identical(origine_bareme(p[[1]]),
                       paste("bareme saisi (long), egal au bareme de l'annexe XVII, section G,",
                             "paragraphe 1 : saisie declaree comme derogation")),
           logical(1))))
r_0  <- do.call(run_engine, c(.args55[setdiff(names(.args55), "segment")],
                              nature_donnees = "brutes", sigma_standard = 0.12))
r_0l <- do.call(run_engine, c(.args55[setdiff(names(.args55), "segment")],
                              nature_donnees = "brutes", sigma_standard = 0.12, bareme = "long"))
verifier("engine_parametre_standard : bareme applicable, bareme retenu (c, T) et origine, quatre etats (#93)",
         {
           lignes <- c("Bareme et facteur c applicables (annexe XVII, section G)",
                       "Bareme et facteur c retenus", "Origine du bareme retenu")
           d_b <- engine_parametre_standard(r_b); d_c <- engine_parametre_standard(r_b1c)
           d_2 <- engine_parametre_standard(r_b2l); d_0 <- engine_parametre_standard(r_0)
           identical(tail(d_b$grandeur, 3), lignes) &&
             identical(tail(d_b$valeur, 3), c(0.59, 0.59, NA)) &&
             identical(tail(d_b$texte, 3), c("long, annexe XVII, section G, paragraphe 1", "long, T = 8",
                                             "bareme reglementaire du segment")) &&
             identical(tail(d_c$valeur, 3), c(0.59, 0.81, NA)) &&
             identical(tail(d_c$texte, 3), c("long, annexe XVII, section G, paragraphe 1", "court, T = 8", paste(
               "bareme saisi (court), contraire a l'annexe XVII, section G, paragraphe 1 :",
               "derogation au bareme de l'annexe XVII, section G"))) &&
             identical(tail(d_2$texte, 1), paste(
               "bareme saisi (long), contraire a l'annexe XVII, section G, paragraphe 2 :",
               "derogation au bareme de l'annexe XVII, section G")) &&
             identical(tail(d_0$valeur, 3), c(NA, 0.81, NA)) &&
             identical(tail(d_0$texte, 3), c("non determine : aucun segment designe",
               "court, T = 8", paste("bareme par defaut (court), aucun segment designe :",
                                     "non determine par l'annexe XVII, section G"))) &&
             identical(origine_bareme(r2_sans), "bareme reglementaire du segment") &&
             identical(tail(engine_parametre_standard(r2_sans)$valeur, 3), c(0.59, 0.59, NA))
         })
verifier("engine_parametre_standard : drapeau bareme_saisi absent ou NA -> erreur ; bareme non saisi incoherent avec le segment -> erreur (#93)",
         {
           r_x <- r_b; r_x$metadata$bareme_saisi <- NULL
           r_y <- r_b; r_y$metadata$bareme_saisi <- NA
           r_z <- r_b1c; r_z$metadata$bareme_saisi <- FALSE
           r_w <- r_b; r_w$metadata$bareme <- "court"; r_w$metadata$bareme_saisi <- TRUE
           leve_erreur(engine_parametre_standard(r_x)) && leve_erreur(engine_parametre_standard(r_y)) &&
             leve_erreur(engine_parametre_standard(r_z)) &&
             leve_erreur(engine_parametre_standard(r_w))
         })
verifier("engine_derogations : 0 ligne sans derogation ; sigma seul, bareme seul, les deux ; data.frame visible ; NULL si ok = FALSE (#93)",
         {
           r_sb <- do.call(run_engine, c(.args55, nature_donnees = "nettes", sigma_standard = 0.12,
                                         bareme = "court"))
           d0 <- withVisible(engine_derogations(r_b)); d_s <- engine_derogations(r_d)
           d_c <- engine_derogations(r_b1c); d_l <- engine_derogations(r_b1l)
           d_sb <- engine_derogations(r_sb)
           isTRUE(d0$visible) && is.data.frame(d0$value) && nrow(d0$value) == 0L &&
             identical(names(d0$value), c("parametre", "valeur_reglementaire", "valeur_retenue",
                                          "conforme", "libelle")) &&
             identical(d_s$parametre, "sigma_standard") && identical(d_s$conforme, FALSE) &&
             identical(d_s$libelle, "sigma standard saisi, derogation au parametre reglementaire") &&
             identical(d_c$parametre, "bareme") && identical(d_c$conforme, FALSE) &&
             identical(d_c$valeur_reglementaire, "long") && identical(d_c$valeur_retenue, "court") &&
             identical(d_c$libelle, paste(
               "bareme de credibilite saisi (court), derogation au bareme de l'annexe XVII,",
               "section G : bareme reglementaire du segment 1 de l'annexe II : long (annexe XVII,",
               "section G, paragraphe 1)")) &&
             identical(d_l$conforme, TRUE) &&
             identical(d_l$libelle, paste(
               "bareme de credibilite saisi (long), egal au bareme de l'annexe XVII, section G,",
               "paragraphe 1 : saisie declaree comme derogation")) &&
             identical(d_sb$parametre, c("sigma_standard", "bareme")) &&
             is.null(engine_derogations(r_sans))
         })
verifier("engine_derogations : sans segment, ligne \"non determine par l'annexe XVII, section G\" (conforme NA), saisie ou non ; drapeau absent -> erreur (#93)",
         {
           d_0 <- engine_derogations(r_0); d_0l <- engine_derogations(r_0l)
           r_x <- r_b; r_x$metadata$bareme_saisi <- NULL
           r_y <- r_b; r_y$metadata$sigma_standard_saisi <- NULL
           identical(d_0$parametre, c("sigma_standard", "bareme")) &&
             identical(d_0$conforme, c(NA, NA)) &&
             identical(d_0$valeur_reglementaire, c(NA_character_, NA_character_)) &&
             identical(d_0$valeur_retenue[2], "court") &&
             identical(d_0$libelle[2], paste("bareme de credibilite court non determine par",
                                             "l'annexe XVII, section G : aucun segment designe")) &&
             identical(r_0$metadata$bareme_saisi, FALSE) &&
             identical(d_0l$conforme[2], NA) &&
             identical(d_0l$libelle[2], paste(
               "bareme de credibilite saisi (long), non determine par l'annexe XVII, section G :",
               "aucun segment designe (saisie declaree comme derogation)")) &&
             identical(origine_bareme(r_0l), paste(
               "bareme saisi (long), non determine par l'annexe XVII, section G : aucun segment",
               "designe (saisie declaree comme derogation)")) &&
             leve_erreur(engine_derogations(r_x)) && leve_erreur(engine_derogations(r_y))
         })
# Constat M1 de l'audit de #93 : conforme = TRUE pour un sigma standard saisi
# egal a NP standard x sigma brut (0,08 = 0,8 x 10 %, premium nettes II-1),
# egalite jugee a TOLERANCE_CONFORME_SIGMA pres ; reserve2 sans segment :
# deux lignes, conforme non determinable.
verifier("engine_derogations : sigma saisi 0,08 egal a 0,8 x 10 % (premium nettes II-1) -> conforme TRUE ; reserve2 sans segment -> 2 lignes, conforme NA (#93)",
         {
           r_e <- do.call(run_engine, c(.args55, nature_donnees = "nettes", sigma_standard = 0.08))
           r_m <- run_engine(methode = "reserve2", triangle = .tri_m6, B = B_M6,
                             sigma_standard = 0.09)
           d_e <- engine_derogations(r_e); d_m <- engine_derogations(r_m)
           identical(d_e$parametre, "sigma_standard") && identical(d_e$conforme, TRUE) &&
             identical(r_m$metadata$bareme_saisi, FALSE) &&
             identical(d_m$parametre, c("sigma_standard", "bareme")) &&
             identical(d_m$conforme, c(NA, NA)) &&
             identical(d_m$valeur_retenue, c("0.09", "court"))
         })
rm(r_b1c, r_b1l, r_b2, r_b2l, r1_c, r1_l, r2_c, r2_l, r_0, r_0l, .args93_2)
## --- Citation des hypotheses H1-H4 (issue #92) -------------------------------
# Source : annexe XVII, point B(2)(g) i. a iv. (methode du risque de primes,
# JOUE L 12/273) et point C(2)(e) i. a iv. (methode du risque de reserve
# no 1, L 12/274-275) ; numerotation identique dans la version consolidee du
# 14.11.2024 (lecture de l'agent regulatory, issue #92). B(2)(f) porte sur les
# depenses et C(2)(f) n'existe pas : aucune famille ne doit citer "(2)(f)".
# Chaines attendues ressaisies ici (double saisie), sans copie du moteur.
familles_h <- function(res) {
  f <- unique(engine_table_tests(res)$famille)
  f[substr(f, 1, 2) %in% c("B.", "C.", "D.", "E.")]
}
fam_attendues <- function(pt) c(
  paste0("B. H1 - linearite / proportionnalite (annexe XVII ", pt, "(i))"),
  paste0("C. H2 - structure de variance (annexe XVII ", pt, "(ii))"),
  paste0("D. H3 - lognormalite (annexe XVII ", pt, "(iii))"),
  paste0("E. H4 - independance et validite du MV (annexe XVII ", pt, "(iv))"))
verifier("Citation H1-H4, premium : annexe XVII, B(2)(g)(i) a (iv) (issue #92)",
         identical(familles_h(r_b), fam_attendues("B(2)(g)")))
verifier("Citation H1-H4, reserve1 : annexe XVII, C(2)(e)(i) a (iv) (issue #92)",
         identical(familles_h(r1_sans), fam_attendues("C(2)(e)")))
verifier("Aucune famille ne cite \"(2)(f)\" (premium, reserve1, reserve2 ; issue #92)",
         !any(grepl("(2)(f)", c(engine_table_tests(r_b)$famille, engine_table_tests(r1_sans)$famille,
                                  engine_table_tests(r2_sans)$famille), fixed = TRUE)))
verifier("usp_tests() : methode hors premium / reserve1 refusee (erreur de programmation)",
         {
           f <- usp_ajuster(.ln_m6$xt, .ln_m6$yt)
           msg <- function(m) tryCatch({ usp_tests(f, r_b$bootstrap, methode = m); "" },
                                       error = function(e) conditionMessage(e))
           motif <- "methode doit valoir \"premium\" ou \"reserve1\""
           identical(msg("reserve1"), "") &&
             grepl(motif, msg("reserve2"), fixed = TRUE) &&
             grepl(motif, msg(NA_character_), fixed = TRUE)
         })
verifier("usp_tests() : methode obligatoire, sans valeur par defaut (revue finale de #88, constat 3)",
         {
           f <- usp_ajuster(.ln_m6$xt, .ln_m6$yt)
           e <- tryCatch(usp_tests(f, r_b$bootstrap), error = function(e) e)
           fm <- formals(usp_tests)
           "methode" %in% names(fm) && identical(deparse(fm[["methode"]]), "") &&
             inherits(e, "error") &&
             grepl("l'argument methode (\"premium\" ou \"reserve1\") est obligatoire",
                   conditionMessage(e), fixed = TRUE)
         })
verifier("GROUPES (display_helpers.R) : prefixes B. a E. inchanges, citations B(2)(g) ; C(2)(e) (issue #92)",
         {
           e <- new.env()
           sys.source(file.path(.racine, "R", "display_helpers.R"), envir = e)
           g <- e$GROUPES[c("B.", "C.", "D.", "E.")]
           r <- c("i", "ii", "iii", "iv")
           identical(unname(vapply(g, function(x) x$cle, character(1))),
                     c("H1", "H2", "H3", "H4")) &&
             identical(unname(vapply(g, function(x) x$ref, character(1))),
                       sprintf("annexe XVII, B(2)(g)(%s) ; C(2)(e)(%s)", r, r)) &&
             !any(grepl("(2)(f)", vapply(e$GROUPES, function(x) x$ref, character(1)),
                        fixed = TRUE)) &&
             identical(e$groupe_de(familles_h(r1_sans)[1])$cle, "H1")
         })
## --- Annees fournies et profondeur retenue (issue #104) ---------------------
# Lecture (A), decision du mainteneur du 28/09/2026 : la duree de credibilite
# est la profondeur T retenue (annexe XVII, section G, paragraphe 3), pas le
# nombre n d'annees fournies ; la troncature est restituee par
# metadata$n_fournies et par une ligne "profondeur" de engine_derogations().
# Serie de n = 12 annees : les 8 annees de tests/donnees/donnees_ln.csv,
# precedees de 4 annees SYNTHETIQUES (valeurs arbitraires, sans source :
# elles sont ecartees par T = 8 et ne doivent peser sur aucun resultat).
.x12 <- c(95.10, 97.80, 99.40, 101.05, .ln_m6$xt)
.y12 <- c(71.30, 64.20, 80.15, 69.90, .ln_m6$yt)
r_12 <- do.call(run_engine, c(modifyList(.args55, list(xt = .x12, yt = .y12)),
                              nature_donnees = "brutes", T = 8))
verifier("Profondeur, n = 12, T = 8, II-1 : n_fournies = 12, T = 8, c = c(8) = 0,59 ; sigma_USP et parametre final identiques au calcul sur les 8 annees retenues (#104)",
         identical(r_12$metadata$n_fournies, 12L) && identical(r_12$metadata$T, 8L) &&
           identical(r_12$parametre_final$credibilite, 0.59) &&
           identical(r_12$parametre_final$sigma_usp, r_b$parametre_final$sigma_usp) &&
           identical(r_12$parametre_final, r_b$parametre_final))
verifier("Profondeur, n = 12, T = 8 : une ligne \"profondeur\" (valeur retenue \"8\", valeur reglementaire et conforme NA), libelle cite G(3)(a), art. 219(1)(a) -> art. 19(1)(b), B(2)(a), art. 219(1)(e) (#104)",
         {
           d <- engine_derogations(r_12)
           identical(d$parametre, "profondeur") && identical(d$valeur_retenue, "8") &&
             identical(d$valeur_reglementaire, NA_character_) && identical(d$conforme, NA) &&
             identical(d$libelle, paste(
               "profondeur retenue T = 8 sur n = 12 annees fournies : les 4 annees les plus",
               "anciennes sont ecartees de l'estimation, la duree de credibilite (annexe XVII,",
               "section G, paragraphe 3, point a)) etant T = 8 ; exclusion a justifier dans le dossier",
               "(art. 219, paragraphe 1, point a), renvoyant a l'art. 19, paragraphe 1, point b) ;",
               "motif de representativite : annexe XVII, section B, paragraphe 2, point a)) et a",
               "documenter (art. 219, paragraphe 1, point e))"))
         })
verifier("Profondeur, n = T : n_fournies = T, aucune ligne \"profondeur\" (premium T = 8 sur 8, T NULL ; reserve2) (#104)",
         {
           r_8 <- do.call(run_engine, c(.args55, nature_donnees = "brutes", T = 8))
           identical(r_b$metadata$n_fournies, 8L) && identical(r_8$metadata$n_fournies, 8L) &&
             nrow(engine_derogations(r_b)) == 0L && nrow(engine_derogations(r_8)) == 0L &&
             identical(r2_sans$metadata$n_fournies, r2_sans$metadata$T) &&
             !"profondeur" %in% engine_derogations(r2_sans)$parametre
         })
verifier("Profondeur, reserve no 1, n = 12, T = 11 : \"exercices\", singulier masculin, G(3)(b) et section C cites ; n_fournies absent, non entier ou < T -> erreur (#104)",
         {
           r1_11 <- run_engine(xt = .x12, yt = .y12, methode = "reserve1", segment = 1,
                               annexe = "II", B = B_M6, T = 11)
           l <- engine_derogations(r1_11)$libelle
           r_x <- r_12; r_x$metadata$n_fournies <- NULL
           r_y <- r_12; r_y$metadata$n_fournies <- 7L
           r_z <- r_12; r_z$metadata$n_fournies <- 12.5
           identical(r1_11$metadata$n_fournies, 12L) &&
             grepl("sur n = 12 exercices fournis : l'exercice le plus ancien est ecarte de l'estimation",
                   l, fixed = TRUE) &&
             grepl("annexe XVII, section G, paragraphe 3, point b)) etant T = 11", l, fixed = TRUE) &&
             !grepl("annee", l, fixed = TRUE) &&
             grepl("annexe XVII, section C, paragraphe 2, point a)", l, fixed = TRUE) &&
             leve_erreur(engine_derogations(r_x)) && leve_erreur(engine_derogations(r_y)) &&
             leve_erreur(engine_derogations(r_z))
         })
verifier("Profondeur, reserve no 1, n = 12, T = 10 : pluriel masculin \"les 2 exercices les plus anciens sont ecartes\" (#104)",
         {
           r1_10 <- run_engine(xt = .x12, yt = .y12, methode = "reserve1", segment = 1,
                               annexe = "II", B = B_M6, T = 10)
           grepl("sur n = 12 exercices fournis : les 2 exercices les plus anciens sont ecartes de",
                 engine_derogations(r1_10)$libelle, fixed = TRUE)
         })
verifier("Profondeur, reserve no 2 : n_fournies different de T (triangle tronque) -> erreur (#104)",
         {
           r_t <- r2_sans; r_t$metadata$n_fournies <- r_t$metadata$T + 1L
           leve_erreur(engine_derogations(r_t))
         })
# engine_derogations() appelle .engine_trace_profondeur() avant
# .engine_trace_bareme() (#135) : un metadata$T absent, non fini ou non
# entier y est refuse par le message propre de .engine_trace_profondeur(),
# et non par celui de usp_credibilite().
verifier("Profondeur : metadata$T absent, non fini ou non entier -> engine_derogations() leve \"metadata$T absent ou invalide\", distinct de n_fournies < T (#104, #135)",
         {
           msg <- function(expr) tryCatch({ expr; NA_character_ },
                                          error = function(e) conditionMessage(e))
           r_u <- r_12; r_u$metadata$T <- NULL
           r_v <- r_12; r_v$metadata$T <- NA_real_
           r_s <- r_12; r_s$metadata$T <- 10.5
           r_w <- r_12; r_w$metadata$n_fournies <- 7L
           attendu <- "engine_derogations() : metadata$T absent ou invalide."
           identical(msg(engine_derogations(r_u)), attendu) &&
             identical(msg(engine_derogations(r_v)), attendu) &&
             identical(msg(engine_derogations(r_s)), attendu) &&
             identical(msg(engine_derogations(r_w)),
                       "engine_derogations() : metadata$n_fournies inferieur a la profondeur T retenue.")
         })
rm(r_12, .x12, .y12)
rm(r_sans, r_b, r_n, r_d, r1_sans, r1_net, r1_brut, r2_sans, r2_net, r2_brut)

fin_fichier()
