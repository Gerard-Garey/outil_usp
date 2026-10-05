###############################################################################
#  tests/unitaires/test_controles_entree.R  --  CONTROLES D'ENTREE
#
#  engine_valider_donnees(), mw_valider_triangle(), engine_lire_donnees_csv(),
#  usp_controle_donnees(), usp_lire_vecteur() / usp_charger().
#  Cas valides, valeurs negatives ou nulles, NA, valeurs infinies, longueurs
#  differentes, T < 5, triangle non carre.
#  Reference : exigences de l'annexe XVII (B(2)(b) et D(2)(b), (c), (e) :
#  au moins 5 annees ; strict positivite requise par la loi lognormale et par
#  les rapports C(i,j+1)/C(i,j)) et article 19 (donnees completes).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_controles_entree.R")

x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
contient <- function(txt, motif) any(grepl(motif, txt, fixed = TRUE))

## --- engine_valider_donnees ---------------------------------------------------
v <- engine_valider_donnees(x, y)
verifier("Validation : jeu de test valide (ok, aucune erreur, T = 8)",
         isTRUE(v$ok) && !length(v$erreurs) && v$T == 8)
verifier("Validation : T = 8 < 10 -> avertissement de credibilite partielle",
         contient(v$avertissements, "credibilite partielle"))
verifier("Validation : T = 5 accepte, T = 4 refuse (annexe XVII, B/C(2)(b))",
         isTRUE(engine_valider_donnees(x[1:5], y[1:5])$ok) &&
         !engine_valider_donnees(x[1:4], y[1:4])$ok &&
         contient(engine_valider_donnees(x[1:4], y[1:4])$erreurs, "au moins 5"))
verifier("Validation : x negatif ou nul refuse",
         !engine_valider_donnees(replace(x, 3, -1), y)$ok &&
         !engine_valider_donnees(replace(x, 3, 0), y)$ok)
verifier("Validation : y nul ou negatif refuse (lognormale)",
         !engine_valider_donnees(x, replace(y, 2, 0))$ok &&
         !engine_valider_donnees(x, replace(y, 2, -5))$ok)
verifier("Validation : NA dans x ou y refuse (art. 19), sans erreur R",
         {
           a <- engine_valider_donnees(replace(x, 1, NA), y)
           b <- engine_valider_donnees(x, replace(y, 8, NaN))
           !a$ok && !b$ok && contient(a$erreurs, "manquantes")
         })
verifier("Validation : longueurs differentes refusees",
         {
           a <- engine_valider_donnees(x, y[-1])
           !a$ok && contient(a$erreurs, "meme longueur")
         })
verifier("Validation : vecteurs non numeriques refuses",
         !engine_valider_donnees(as.character(x), y)$ok &&
         !engine_valider_donnees(x > 110, y)$ok)
verifier("Validation : vecteurs vides refuses", !engine_valider_donnees(numeric(0), numeric(0))$ok)
verifier("Validation : avertissements ratio >= 5, amplitude >= 10, doublons",
         contient(engine_valider_donnees(x, replace(y, 1, 600))$avertissements, "Ratio") &&
         contient(engine_valider_donnees(replace(x, 1, 10), y)$avertissements, "Amplitude") &&
         contient(engine_valider_donnees(c(x, x[1]), c(y, y[1]))$avertissements, "dupliques"))
verifier("Validation : T_min parametrable",
         !engine_valider_donnees(x, y, T_min = 9)$ok &&
         isTRUE(engine_valider_donnees(x[1:3], y[1:3], T_min = 3)$ok))
# Issue #33 (defaut releve par audit, repris de l'issue #7), corrige : Inf
# passait les controles (anyNA(Inf) est FALSE, Inf > 0) et run_engine()
# s'arretait sur une erreur R au lieu de renvoyer ok = FALSE.
verifier("Validation : valeur infinie dans y ou x refusee (#33)",
         !engine_valider_donnees(x, replace(y, 3, Inf))$ok &&
         !engine_valider_donnees(replace(x, 2, Inf), y)$ok &&
         !engine_valider_donnees(x, replace(y, 3, -Inf))$ok &&
         contient(engine_valider_donnees(x, replace(y, 3, Inf))$erreurs, "infinies"))
verifier("run_engine : valeur infinie -> ok = FALSE avec motif, sans erreur R (#33)",
         {
           r <- run_engine(xt = x, yt = replace(y, 3, Inf), methode = "premium",
                           segment = 1, annexe = "II", B = B_MIN_USAGE, nature_donnees = "brutes")
           identical(r$ok, FALSE) && contient(r$validation$erreurs, "infinies")
         })
## --- Marge du test d'equivalence (#33, complement d'audit de #58) ------------
# Avis d'actuary du 24/09/2026 : theta reel fini, 0 < theta < 1 ; delta_equiv
# (s'il est fourni) reel fini, 0 < Delta < moyenne(yt), theta alors ignore.
# Hors domaine : ok = FALSE avec un motif nommant le parametre.
marge_refusee <- function(th = 0.10, de = NULL, motif) {
  v <- engine_valider_donnees(x, y, theta_equiv = th, delta_equiv = de)
  !v$ok && contient(v$erreurs, motif)
}
verifier("Marge theta : NA, vide, multiple, texte, Inf, 0, negative, 1 et plus refuses",
         all(vapply(list(NA, NA_real_, numeric(0), NULL, c(0.1, 0.2), "0.1", Inf, -Inf, 0, -0.1, 1, 1.5),
                    function(th) marge_refusee(th = th, motif = "theta_equiv"), logical(1))))
verifier("Marge theta : 0 < theta < 1 accepte (0,10 ; 0,999 ; 1e-6), jeu valide inchange",
         all(vapply(c(0.10, 0.999, 1e-6), function(th)
           isTRUE(engine_valider_donnees(x, y, theta_equiv = th)$ok), logical(1))) &&
         identical(engine_valider_donnees(x, y), engine_valider_donnees(x, y, theta_equiv = 0.10)))
# Audit de #33 (C2) : la valeur refusee est restituee telle qu'elle a ete
# fournie (deparse), guillemets d'un texte compris.
verifier("Marge : valeur refusee restituee par deparse() (texte entre guillemets, vecteur en c(...)) (#33)",
         {
           e1 <- engine_valider_donnees(x, y, theta_equiv = "0.1")$erreurs
           e2 <- engine_valider_donnees(x, y, theta_equiv = c(0.1, 0.2))$erreurs
           e3 <- engine_valider_donnees(x, y, delta_equiv = "8")$erreurs
           e4 <- engine_valider_donnees(x, y, theta_equiv = NULL)$erreurs
           contient(e1, "theta_equiv = \"0.1\"") && contient(e2, "theta_equiv = c(0.1, 0.2)") &&
             contient(e3, "delta_equiv = \"8\"") && contient(e4, "theta_equiv = vide")
         })
verifier("Marge Delta : NA, vide, multiple, Inf, 0, negative, >= moyenne(y) refuses",
         all(vapply(list(NA, numeric(0), c(1, 2), Inf, 0, -1, mean(y), 2 * mean(y)),
                    function(de) marge_refusee(de = de, motif = "delta_equiv"), logical(1))))
verifier("Marge Delta fournie : theta ignore (theta = 5 ou NA accepte avec Delta = 8)",
         isTRUE(engine_valider_donnees(x, y, theta_equiv = 5, delta_equiv = 8)$ok) &&
         isTRUE(engine_valider_donnees(x, y, theta_equiv = NA, delta_equiv = 8)$ok))
verifier("run_engine : theta_equiv NA ou 1, delta_equiv vide -> ok = FALSE, sans erreur R",
         {
           r1 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                            theta_equiv = NA, nature_donnees = "brutes")
           r2 <- run_engine(xt = x, yt = y, methode = "reserve1", segment = 1, B = B_MIN_USAGE,
                            theta_equiv = 1)
           r3 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                            delta_equiv = numeric(0), nature_donnees = "brutes")
           identical(r1$ok, FALSE) && identical(r2$ok, FALSE) && identical(r3$ok, FALSE) &&
             contient(r1$validation$erreurs, "theta_equiv") &&
             contient(r3$validation$erreurs, "delta_equiv")
         })

## --- Profondeur T (issue #87) ------------------------------------------------
# Defaut releve par audit (audit leger de #33) : T = 5.5 donnait l'indice
# (n - T + 1):n = 3.5:8, soit les annees 3 a 7 (l'annee la plus recente
# ecartee en silence, sigma_USP 0,108587 au lieu de 0,111452) ; NA, Inf et un
# texte etaient ignores (T = 8) ; c(5, 6) et T = 9.5 > n levaient une erreur
# R. Attendu : ok = FALSE avec un motif, sans troncature ni erreur R.
T_refuses <- list(5.5, 7.5, 9.5, NA, NA_real_, Inf, -Inf, c(5, 6), "6", numeric(0), TRUE)
verifier("engine_valider_profondeur : NULL et entiers de [5 ; n] acceptes (5, 8, 6L)",
         identical(engine_valider_profondeur(NULL, 8), character(0)) &&
         all(vapply(list(5, 8, 6L, 7), function(t)
           identical(engine_valider_profondeur(t, 8), character(0)), logical(1))))
verifier("engine_valider_profondeur : non entier, NA, infini, multiple, texte, vide, logique refuses (motif 'entier')",
         all(vapply(T_refuses, function(t) {
           e <- engine_valider_profondeur(t, 8)
           length(e) == 1L && contient(e, "nombre entier d'annees")
         }, logical(1))))
verifier("engine_valider_profondeur : T > n et T < 5 refuses ; T_min parametrable",
         contient(engine_valider_profondeur(9, 8), "superieure au nombre d'annees fournies (8)") &&
         all(vapply(c(4, 0, -1), function(t)
           contient(engine_valider_profondeur(t, 8), "au moins 5"), logical(1))) &&
         identical(engine_valider_profondeur(3, 8, T_min = 1), character(0)))
verifier("run_engine : T refuse (5.5, NA, Inf, c(5, 6), '6', T > n entier ou non) -> ok = FALSE avec motif, sans erreur R (#87)",
         all(vapply(c(T_refuses[c(1, 3, 4, 6, 8, 9)], list(9)), function(t) {
           r <- tryCatch(run_engine(xt = x, yt = y, methode = "premium", segment = 1,
                                    B = B_MIN_USAGE, T = t, nature_donnees = "brutes"),
                         error = function(e) e)
           !inherits(r, "error") && identical(r$ok, FALSE) &&
             contient(r$validation$erreurs, "Profondeur T")
         }, logical(1))))
verifier("run_engine : T = 6 retient les 6 annees les plus recentes (metadata$T = 6), T = 8 equivaut a T absent",
         {
           r6 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                            T = 6, nature_donnees = "brutes")
           r8 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                            T = 8, nature_donnees = "brutes")
           r0 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                            nature_donnees = "brutes")
           isTRUE(r6$ok) && identical(r6$metadata$T, 6L) &&
             identical(r6$donnees$xt, x[3:8]) && identical(r6$donnees$yt, y[3:8]) &&
             identical(r8$parametre_final, r0$parametre_final) && identical(r8$metadata$T, 8L)
         })
verifier("usp_charger : T non entier ou NA refuse (erreur explicite, pas de troncature) (#87)",
         {
           fx3 <- tempfile(fileext = ".csv"); fy3 <- tempfile(fileext = ".csv")
           writeLines(as.character(x), fx3); writeLines(as.character(y), fy3)
           e <- tryCatch(usp_charger(fx3, fy3, T = 5.5), error = function(e) conditionMessage(e))
           is.character(e) && grepl("nombre entier", e, fixed = TRUE) &&
             leve_erreur(usp_charger(fx3, fy3, T = NA))
         })

verifier("run_engine : T refuse -> aucun avertissement de serie retenue, validation$T = NA (#87, audit)",
         {
           r <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                           T = 5.5, nature_donnees = "brutes")
           identical(r$ok, FALSE) && identical(r$validation$avertissements, character(0)) &&
             identical(r$validation$T, NA_integer_)
         })
verifier("engine_valider_profondeur : annexe XVII citee si T_min >= 5 seulement ; motif neutre sinon",
         contient(engine_valider_profondeur(5.5, 8), "annexe XVII") &&
         !contient(engine_valider_profondeur(5.5, 8, T_min = 1), "annexe XVII") &&
         identical(engine_valider_profondeur(0, 8, T_min = 1), "Profondeur T = 0 : T >= 1 attendu."))

## --- Donnees a l'echelle extreme (issues #88, #145) ---------------------------
# Defaut releve par audit (audit leger de #33) : des donnees finies et
# strictement positives mais a l'echelle extreme passaient la validation et
# faisaient lever une erreur R en cours de calcul (xt x 1e298 : lm.fit() de
# test_white(), regresseur x^2 infini, jusqu'a l'issue #110 ; yt x 1e-300 :
# test logique sur NA dans le detail de la distance de Cook). Decision du
# mainteneur (26/09/2026) : filet limite au calcul qui suit une validation
# reussie ; l'erreur y est un DEFAUT DE CALCUL INTERCEPTE (ok = FALSE, motif
# neutre, diagnostic dans validation$erreur_r) ; les erreurs d'usage restent
# des erreurs R. Le choix "aucun seuil d'echelle" de #88 est RENVERSE par
# #145 (specification du 02/10/2026) : toute valeur de xt ou de yt de la
# serie retenue hors de [DOMAINE_NUMERIQUE_MIN ; DOMAINE_NUMERIQUE_MAX] =
# [1e-50 ; 1e50], bornes incluses, est refusee par engine_valider_donnees()
# avec un motif explicite, avant tout calcul ; hors d'environ [1e-155 ;
# 1e151], le moteur rendait ok = TRUE avec des verdicts faux (mesure de la
# specification). Le filet reste en place : ses scenarios sont desormais
# declenches par une erreur injectee dans l'environnement du moteur (comme
# le test Merz-Wuthrich ci-dessous), aucune donnee du domaine ne le
# declenchant plus. Les motifs compares sont les textes fixes du moteur, en
# ASCII, jamais le message traduit de conditionMessage().
MOTIF_DEFAUT <- "Defaut de calcul intercepte"
MOTIF_DOMAINE <- "hors du domaine numerique [1e-50 ; 1e+50]"
calcul_extreme <- function(xt, yt) suppressWarnings(
  run_engine(xt = xt, yt = yt, methode = "premium", segment = 1, B = B_MIN_USAGE,
             nature_donnees = "brutes"))
# Evalue expr avec la fonction `nom` du moteur remplacee par f, restauree en
# sortie (meme en cas d'erreur).
avec_injection <- function(nom, f, expr) {
  e <- environment(run_engine)
  orig <- get(nom, envir = e)
  assign(nom, f, envir = e)
  on.exit(assign(nom, orig, envir = e))
  expr
}
panne <- function(...) stop("panne simulee")
verifier("Domaine numerique : constantes [1e-50 ; 1e50] et plage du ratio [0,1 ; 5[ nommees (#145)",
         identical(DOMAINE_NUMERIQUE_MIN, 1e-50) && identical(DOMAINE_NUMERIQUE_MAX, 1e50) &&
         identical(RATIO_PLAUSIBLE_MIN, 0.1) && identical(RATIO_PLAUSIBLE_MAX, 5))
verifier("run_engine : xt x 1e298, xt x 1e200, yt x 1e-300, xt et yt x 1e-300, xt x 1e-300 -> refus motive (ok = FALSE, sans defaut intercepte ni erreur R) (#145)",
         all(vapply(list(list(x * 1e298, y), list(x * 1e200, y), list(x, y * 1e-300),
                         list(x * 1e-300, y * 1e-300), list(x * 1e-300, y)), function(d) {
           r <- tryCatch(calcul_extreme(d[[1]], d[[2]]), error = function(e) e)
           !inherits(r, "error") && inherits(r, "usp_engine") && identical(r$ok, FALSE) &&
             contient(r$validation$erreurs, MOTIF_DOMAINE) &&
             contient(r$validation$erreurs, "invariants par un changement d'unite commun") &&
             !contient(r$validation$erreurs, MOTIF_DEFAUT) && is.null(r$validation$erreur_r)
         }, logical(1))))
verifier("Domaine numerique : le motif cite la serie, la valeur fautive (17 chiffres si necessaire), la borne et le nombre de valeurs hors domaine (#145)",
         {
           e1 <- engine_valider_donnees(x * 1e-300, y)$erreurs
           e2 <- engine_valider_donnees(replace(x, 3, 2e60), y)$erreurs
           e3 <- engine_valider_donnees(replace(x, 1, 1e50 * (1 + .Machine$double.eps)), y)$erreurs
           length(e1) == 1L && contient(e1, "xt = 1.042e-298 (< 1e-50, borne inferieure) ; 8 valeurs hors du domaine") &&
             contient(e1, "delta_equiv") &&
             length(e2) == 1L && contient(e2, "xt = 2e+60 (> 1e+50, borne superieure).") &&
             contient(e3, "xt = 1.0000000000000003e+50 (> 1e+50, borne superieure)")
         })
verifier("Domaine numerique : bornes 1e-50 et 1e50 acceptees, refus juste au-dela (un ulp), sur xt comme sur yt (#145)",
         {
           haut <- 1e50 * (1 + .Machine$double.eps); bas <- 1e-50 * (1 - .Machine$double.eps)
           ok <- function(xt, yt) engine_valider_donnees(xt, yt)$ok
           refus <- function(xt, yt, s) {
             v <- engine_valider_donnees(xt, yt)
             !v$ok && length(v$erreurs) == 1L && contient(v$erreurs, paste("Valeur de", s, MOTIF_DOMAINE))
           }
           haut != 1e50 && bas != 1e-50 &&
             ok(replace(x, 1, 1e50), replace(y, 1, 6e49)) &&
             ok(replace(x, 1, 1.5e-50), replace(y, 1, 1e-50)) &&
             ok(replace(x, 1, 1e-50), replace(y, 1, 1e-50)) &&
             ok(replace(x, 1, 1e50), replace(y, 1, 1e50)) &&
             refus(replace(x, 1, haut), replace(y, 1, 6e49), "xt") &&
             refus(replace(x, 1, 1e50), replace(y, 1, haut), "yt") &&
             refus(replace(x, 1, 1.5e-50), replace(y, 1, bas), "yt") &&
             refus(replace(x, 1, bas), replace(y, 1, 1e-50), "xt")
         })
verifier("Domaine numerique : seule la serie retenue est controlee (annee hors domaine ecartee par T acceptee, refusee sinon) (#145)",
         {
           s8 <- engine_valider_serie_retenue(c(1e-60, x), c(1, y), T = 8)$validation
           s9 <- engine_valider_serie_retenue(c(1e-60, x), c(1, y))$validation
           isTRUE(s8$ok) && !s9$ok && contient(s9$erreurs, "xt = 1e-60 (< 1e-50, borne inferieure).")
         })
verifier("Domaine numerique : refus avec les autres refus, sans doublon pour une valeur nulle, negative, NA ou infinie (#145)",
         {
           pas_domaine <- function(v) !contient(v$erreurs, MOTIF_DOMAINE)
           pas_domaine(engine_valider_donnees(replace(x, 2, 0), y)) &&
             pas_domaine(engine_valider_donnees(replace(x, 2, -1e60), y)) &&
             pas_domaine(engine_valider_donnees(replace(x, 2, NA), y)) &&
             pas_domaine(engine_valider_donnees(replace(x, 2, Inf), y)) &&
             identical(engine_valider_donnees(x * 1e60, y)$avertissements, character(0))
         })
# Invariance d'unite (specification de #145) : une serie portee pres d'une
# borne du domaine par un facteur commun 2^k (multiplication exacte en
# virgule flottante) donne des resultats identiques au bit pres a ceux de
# l'echelle 1. L'invariance de RESET et de White a une echelle quelconque
# reste testee au niveau de la fonction (test_volumes_constants.R).
verifier("Invariance d'unite : xt et yt x 2^k pres des bornes (k = 159 et -172) -> sigma_USP, p-values retenues, verdicts et controles A identical() a l'echelle 1 (#145)",
         {
           cle <- function(r) {
             tt <- engine_table_tests(r)
             list(sigma = r$parametre_final$sigma_usp, p = tt$p_retenue, verdict = tt$verdict,
                  controles = vapply(r$controles, function(l) l$verdict, ""))
           }
           k_haut <- floor(log2(DOMAINE_NUMERIQUE_MAX / max(x, y)))
           k_bas <- ceiling(log2(DOMAINE_NUMERIQUE_MIN / min(x, y)))
           r1 <- calcul_extreme(x, y); a <- cle(r1)
           k_haut == 159 && k_bas == -172 &&
             max(x, y) * 2^(k_haut + 1) > DOMAINE_NUMERIQUE_MAX &&
             min(x, y) * 2^(k_bas - 1) < DOMAINE_NUMERIQUE_MIN &&
             isTRUE(r1$ok) && length(a$p) > 0L && length(a$controles) > 0L &&
             all(vapply(c(k_haut, k_bas), function(k) {
               r <- calcul_extreme(x * 2^k, y * 2^k)
               isTRUE(r$ok) && identical(cle(r), a)
             }, logical(1)))
         })
verifier("Ratio y/x : avertissement si r < 0,1 (xt x 1e3, ratio 7e-4) ou r >= 5 ; r = 0,1 sans avertissement (#145)",
         {
           avt <- function(xt, yt) engine_valider_donnees(xt, yt)$avertissements
           motif <- "Ratio y/x hors de la plage plausible [0.1 ; 5[ : verifier les unites."
           contient(avt(x * 1e3, y), motif) && isTRUE(engine_valider_donnees(x * 1e3, y)$ok) &&
             contient(avt(x * 1e-1, y * 50), motif) &&
             !contient(avt(c(10, x[-1]), c(1, y[-1])), motif) &&
             contient(avt(c(10, x[-1]), c(0.99, y[-1])), motif) &&
             !contient(avt(x, y), motif)
         })
verifier("Ligne A 'Plausibilite du ratio y/x' : memes constantes que l'avertissement (r = 0,1 OK ; 0,099 et 5 ECHEC), detail inchange (#145)",
         {
           ligne <- function(xt, yt) {
             r <- usp_controle_donnees(xt, yt)
             r[[which(vapply(r, function(l) l$test, "") == "Plausibilite du ratio y/x")]]
           }
           l1 <- ligne(c(10, x[-1]), c(1, y[-1]))
           identical(l1$verdict, "OK") &&
             identical(l1$detail, "min = 0.100 ; median = 0.751 ; max = 0.894") &&
             identical(ligne(c(10, x[-1]), c(0.99, y[-1]))$verdict, "ECHEC") &&
             identical(ligne(c(10, x[-1]), c(50, y[-1]))$verdict, "ECHEC") &&
             identical(ligne(c(10, x[-1]), c(49.9, y[-1]))$verdict, "OK") &&
             identical(ligne(x * 1e3, y)$verdict, "ECHEC")
         })
## --- Distance de Cook a toute echelle (issue #153) ----------------------------
# Critere amende du 02/10/2026 : (1) run_engine() sans erreur R ni defaut de
# calcul intercepte pour x et y x 10^e, e de -300 a 300 (plus -165, -160,
# 152, 160, entrees sous-normales et echelle asymetrique) : refus de #145
# hors du domaine numerique ; dans le domaine, ok = TRUE, sigma_USP et p
# retenues egales a celles de l'echelle 1 a TOLERANCE pres
# (comparer_objets(), tests/outils_tests.R), verdicts identiques ; (2)
# usp_tests() et engine_influence() en appel direct sans erreur R sur le
# meme balayage ; (3) ligne Cook a l'echelle exacte (.usp_echelle_exacte(),
# puissance de 2) ; (4) garde "non applicable" sur une distance non finie
# (.usp_ligne_cook()) ; (5) motif des graphiques d'influence
# (plots_data$influence_motif) sur la meme garde. Jeu de l'issue : avant #153, usp_tests() levait une
# erreur R a x et y x 10^e pour e <= -164 (if (any(ck > 4 / T)) sur NaN) ;
# sur les entrees sous-normales, deux autres erreurs R : TOST
# (if (p_bas >= p_haut) sur NaN, garde "statistique non definie" de
# test_tost_intercept()) et lm.influence() dans engine_influence() (resolue
# par la meme mise a l'echelle exacte que la ligne Cook).
# Dans le domaine, run_engine() est lance sur un echantillon d'echelles (le
# calcul complet prend quelques secondes par echelle) ; hors du domaine, le
# refus est verifie a chaque echelle. Les appels directs parcourent e par
# pas de 10, plus les echelles nommees.
x153 <- c(100, 150, 200, 300, 400, 500, 600, 700)
y153 <- x153 * c(0.71, 0.64, 0.80, 0.69, 0.75, 0.62, 0.90, 0.66)
e_sym153 <- c(-300:300, -165, -160, 152, 160)
ech153 <- c(lapply(e_sym153, function(e) c(10^e, 10^e)),
            list(c(1e-320, 1e-320), c(5e-324, 5e-324)),
            lapply(c(-300, -200, -60, 60, 200, 300), function(e) c(10^e, 1)))
dans_domaine <- function(v) all(v >= DOMAINE_NUMERIQUE_MIN & v <= DOMAINE_NUMERIQUE_MAX)
.dossier153 <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
outils153 <- new.env(parent = globalenv())
sys.source(file.path(.dossier153, "..", "outils_tests.R"), envir = outils153)
verifier(".usp_echelle_exacte() : diviseur puissance de 2 (max dans [1 ; 2[), D_t et h_t de y ~ x - 1 identical() a l'echelle 1 ; v inchange si max(|v|) nul ou non fini (#153)",
         {
           d_h <- function(a, b) { m <- stats::lm(b ~ a - 1)
             list(unname(stats::cooks.distance(m)), unname(stats::hatvalues(m))) }
           all(vapply(list(list(x, y), list(x153, y153)), function(d) {
             xe <- .usp_echelle_exacte(d[[1]]); ye <- .usp_echelle_exacte(d[[2]])
             r <- d[[1]] / xe
             max(xe) >= 1 && max(xe) < 2 && max(ye) >= 1 && max(ye) < 2 &&
               length(unique(r)) == 1L && r[1] == 2^round(log2(r[1])) &&
               identical(d_h(xe, ye), d_h(d[[1]], d[[2]]))
           }, logical(1))) &&
             identical(.usp_echelle_exacte(c(0, 0)), c(0, 0)) &&
             identical(.usp_echelle_exacte(c(1, Inf)), c(1, Inf)) &&
             identical(.usp_echelle_exacte(c(1, NA)), c(1, NA))
         })
verifier(".usp_ligne_cook() : distance non finie (NaN, NA, Inf) -> non applicable, estim NA, motif ; distances finies -> diagnostic, detail du repere 4/T (#153)",
         {
           na <- lapply(list(c(0.1, NaN), c(NA, 0.2), c(Inf, 0.1)), .usp_ligne_cook, T = 8)
           ok <- .usp_ligne_cook(c(0.1, 0.6, 0.2, 0.7, 0, 0, 0, 0), T = 8)
           ok0 <- .usp_ligne_cook(rep(0.1, 8), T = 8)
           all(vapply(na, function(l) identical(l$type, "non applicable") && identical(l$estim, NA_real_) &&
                        identical(l$detail, paste("distance de Cook non finie (par exemple residus de",
                                                  "y = beta x tous nuls) : diagnostic non applicable")),
                      logical(1))) &&
             identical(ok$type, "diagnostic") && identical(ok$estim, 0.7) &&
             identical(ok$detail, "repere conventionnel 4/T = 0.500 ; 2 observation(s) au-dessus (rangs 2, 4)") &&
             identical(ok0$detail, "repere conventionnel 4/T = 0.500 ; 0 observation(s) au-dessus")
         })
# Issue des regressions sur donnees degenerees : dependante de la
# plateforme. Sur y exactement proportionnel a x (x = 2^(0:7), y = x / 2)
# et sur les entrees sous-normales (x et y x 1e-320, 5e-324), lm() rend
# selon le BLAS, ses routines et la version de R des residus exactement
# nuls (D_t et residu standardise 0/0 = NaN) ou un bruit d'arrondi (valeurs
# finies), une constante et une erreur-type NaN ou finies. Mesures (R 4.3.3,
# OpenBLAS 0.3.20 de la CI charge par LD_PRELOAD) : cas proportionnel,
# max D_t NaN avec les routines Zen, Haswell et le BLAS de reference, fini
# (0,0029) avec SkylakeX ; sous-normaux, statistique non definie ici sous
# les quatre configurations, mais assertion en echec sur la CI (R 4.3.1,
# OpenBLAS 0.3.20, AMD EPYC 7763). Ces cas ne figent donc aucune des deux
# issues : ils exigent l'absence d'erreur R et la coherence de l'issue
# rendue (garde posee avec son motif et des valeurs non finies, ou ligne
# calculee, finie, sans motif ; pour TOST, tout motif que
# test_tost_intercept() peut produire, si sa condition est vraie sur ces
# donnees). Les gardes sont atteintes a coup sur par
# injection dans l'environnement du moteur : .usp_echelle_exacte() rend
# y = 0 (residus de y = beta x exactement nuls, 0 x fini = 0 sous tout
# BLAS) et summary() rend une constante et une erreur-type NaN dans
# test_tost_intercept().
LIGNE_COOK153 <- "Points influents (distance de Cook)"
LIGNE_TOST153 <- "Equivalence de la constante a zero (TOST)"
MOTIF_INFLUENCE153 <- paste("Residu standardise ou distance de Cook non fini (par exemple",
                            "residus de y = beta x tous nuls) : graphique non disponible")
DETAIL_TOST153 <- paste("statistique t non definie (constante ou",
                        "erreur-type de la regression de y sur x",
                        "non calculable) : test non applicable")
ligne153 <- function(tt, nom) tt[[which(vapply(tt, function(l) l$test, "") == nom)]]
# Ligne Cook : non applicable (INFO, estim NA, motif) ou diagnostic fini.
cook_garde153 <- function(l) identical(l$type, "non applicable") && identical(l$verdict, "INFO") &&
  identical(l$estim, NA_real_) && contient(l$detail, "distance de Cook non finie")
cook_calcule153 <- function(l) identical(l$type, "diagnostic") && is.finite(l$estim) &&
  startsWith(l$detail, "repere conventionnel 4/T")
# plots_data : motif pose et residu_std, cook tous non finis ; ou motif
# absent et tout fini.
influence_garde153 <- function(pd) !any(is.finite(pd$influence$cook)) &&
  !any(is.finite(pd$influence$residu_std)) && identical(pd$influence_motif, MOTIF_INFLUENCE153)
influence_calcule153 <- function(pd) all(is.finite(pd$influence$cook)) &&
  all(is.finite(pd$influence$residu_std)) && is.null(pd$influence_motif)
# x ecarte par lm() dans le modele de la ligne Cook et de engine_influence()
# (lm(ye ~ xe - 1) sur .usp_echelle_exacte(), memes donnees) : le moteur n'a
# pas de motif propre a ce cas, ses deux gardes ne lisent que la finitude de
# D_t et du residu standardise ; x ecarte (rang 0, coefficient NA) n'admet
# que l'issue garde (D_t = 0/0 = NaN, mesure sur une colonne nulle sous les
# quatre configurations BLAS).
cook_x_ecarte153 <- function(x, y) {
  xe <- .usp_echelle_exacte(x); ye <- .usp_echelle_exacte(y)
  anyNA(stats::coef(stats::lm(ye ~ xe - 1)))
}
# TOST : motif attendu, lu dans test_tost_intercept() et recalcule sur les
# memes donnees par les memes conditions, dans le meme ordre de priorite :
# (1) "volumes constants" si usp_volumes_constants(x) ; (2) "marge" si la
# marge est invalide (theta non fini ou <= 0 sans delta_abs ; delta_abs non
# fini ou <= 0) ; (3) "x ecarte" (#168) si lm() a ecarte x (garde-fou R12 :
# "x" absent de rownames(summary(stats::lm(y ~ x))$coefficients)) ; (4)
# "statistique non definie" si et seulement si p_bas ou p_haut, recalculees
# ici par les formules de test_tost_intercept() (a, se, Delta = theta *
# mean(y) sans delta_abs, delta_abs sinon, t_bas, t_haut, pt() a T - 2
# ddl), n'est pas finie ; sinon ligne calculee (NA). Le motif ne lit rien du
# resultat teste : un resultat forge avec ce motif sur des donnees
# ordinaires est refuse (#153). summary() est celle de l'environnement du
# moteur, pour que le motif attendu reflete ce que le moteur a vu sous les
# injections de summary() (avec_summary_nan153(), avec_summary_sans_x153()).
# p et stat valent NA_real_ sur toute branche non applicable, et sont finis
# sur la branche calculee.
tost_motif_attendu153 <- function(x, y, theta = 0.10, delta_abs = NULL) {
  if (usp_volumes_constants(x)) return("volumes constants")
  if ((is.null(delta_abs) && (!is.finite(theta) || theta <= 0)) ||
      (!is.null(delta_abs) && (!is.finite(delta_abs) || delta_abs <= 0))) return("marge")
  resume <- get("summary", envir = environment(run_engine))
  m <- resume(stats::lm(y ~ x))
  if (!"x" %in% rownames(m$coefficients)) return("x ecarte")
  a <- m$coefficients[1, 1]; se <- m$coefficients[1, 2]
  ddl <- length(x) - 2
  Delta <- if (is.null(delta_abs)) theta * mean(y) else delta_abs
  p_bas <- stats::pt((a + Delta) / se, ddl, lower.tail = FALSE)
  p_haut <- stats::pt((a - Delta) / se, ddl, lower.tail = TRUE)
  if (is.finite(p_bas) && is.finite(p_haut)) NA_character_ else "statistique non definie"
}
tost_coherent153 <- function(r, ref, x, y) !inherits(r, "error") && identical(names(r), ref) &&
  identical(r$non_applicable, tost_motif_attendu153(x, y)) &&
  (if (is.na(r$non_applicable)) is.finite(r$p) && is.finite(r$stat)
   else identical(r$p, NA_real_) && identical(r$stat, NA_real_))
# Ligne TOST de usp_tests(), en regard de test_tost_intercept() sur les memes
# donnees (x, y = fit$x, fit$y) : detail du motif, lu dans usp_tests()
# ("volumes constants" : texte de la regle R13 ; "x ecarte" : texte du
# garde-fou R12, #168) ; ligne "test" a p retenue finie si calculee.
ligne_tost_coherente153 <- function(lt, r, x) {
  m <- r$non_applicable
  if (is.na(m)) return(identical(lt$type, "test") && is.finite(lt$p_retenue) &&
                         startsWith(lt$detail, "Rejeter H0 fournit une preuve POSITIVE"))
  attendu <- switch(m,
    "volumes constants" = NA_character_,
    "x ecarte" = paste("regression de y sur x : x ecarte par lm() pour colinearite,",
                       "test non applicable"),
    "marge" = paste("marge Delta invalide (sans delta_equiv : theta_equiv non",
                    "fini ou <= 0 ; ou delta_equiv non fini ou <= 0) : test",
                    "non applicable"),
    "statistique non definie" = DETAIL_TOST153,
    return(FALSE))
  identical(lt$type, "non applicable") && identical(lt$verdict, "INFO") && is.na(lt$p_retenue) &&
    (if (is.na(attendu)) startsWith(lt$detail, "volumes x_t constants") else identical(lt$detail, attendu))
}
# Injections deterministes (voir ci-dessus).
.echelle_orig153 <- .usp_echelle_exacte
echelle_y_nul153 <- function(y0) function(v) if (isTRUE(all.equal(v, y0))) 0 * v else .echelle_orig153(v)
avec_summary_nan153 <- function(expr) {
  e <- environment(run_engine)
  existait <- exists("summary", envir = e, inherits = FALSE)
  if (existait) orig <- get("summary", envir = e, inherits = FALSE)
  assign("summary", function(object, ...) {
    s <- base::summary(object, ...)
    if (inherits(object, "lm")) s$coefficients[1, 1:2] <- NaN
    s
  }, envir = e)
  on.exit(if (existait) assign("summary", orig, envir = e) else rm("summary", envir = e))
  expr
}
.tost_orig153 <- test_tost_intercept
# Garde Cook atteinte a coup sur (usp_tests(), engine_plots_data()) : avant
# #153, erreur R dans usp_tests() (if (any(ck > 4 / T)) sur NaN, defaut
# intercepte par run_engine()) ; plot_influence_levier() et
# plot_influence_cook() levaient une erreur R sans le motif.
verifier("run_engine, residus de y = beta x exactement nuls (injection : .usp_echelle_exacte() rend y = 0) -> ok = TRUE, ligne Cook non applicable avec motif, plots_data$influence_motif pose (residu_std et cook non finis, leviers finis), memes noms de plots_data que sans injection a influence_motif pres (#153)",
         {
           r1 <- calcul_extreme(x, y)
           ri <- avec_injection(".usp_echelle_exacte", echelle_y_nul153(y), calcul_extreme(x, y))
           ti <- engine_table_tests(ri); t1 <- engine_table_tests(r1)
           ci <- ti[ti$test == LIGNE_COOK153, ]
           isTRUE(ri$ok) && isTRUE(r1$ok) && is.null(ri$validation$erreur_r) &&
             identical(ci$type, "non applicable") && identical(ci$verdict, "INFO") &&
             identical(ci$estimation, NA_real_) && contient(ci$commentaire, "distance de Cook non finie") &&
             influence_garde153(ri$plots_data) && all(is.finite(ri$plots_data$influence$levier)) &&
             influence_calcule153(r1$plots_data) &&
             identical(setdiff(names(ri$plots_data), "influence_motif"), names(r1$plots_data)) &&
             identical(tail(names(ri$plots_data), 1), "qq_enveloppe") &&
             identical(names(ti), names(t1)) && identical(ti$test, t1$test)
         })
# Garde TOST atteinte a coup sur : avant #153, erreur R de
# if (p_bas >= p_haut) sur NaN.
verifier("test_tost_intercept() et usp_tests(), constante et erreur-type NaN (injection de summary()) -> non applicable 'statistique non definie', memes champs que la branche calculee, detail exact de la ligne, sans erreur R ; motif accepte par tost_coherent153() sous l'injection, refuse hors injection et resultat forge (motif, p = stat = NA sur les donnees de test) refuse (#153)",
         {
           ref <- names(test_tost_intercept(x153, y153))
           r <- tryCatch(avec_summary_nan153(test_tost_intercept(x153, y153)), error = function(e) e)
           # Resultat forge : branche calculee relabellisee, sans injection.
           forge <- modifyList(test_tost_intercept(x153, y153),
                               list(stat = NA_real_, p = NA_real_,
                                    non_applicable = "statistique non definie"))
           f1 <- usp_ajuster(x153, y153); b1 <- usp_bootstrap(f1, B = B_MIN_USAGE)
           tt <- tryCatch(avec_injection("test_tost_intercept",
                                         function(...) avec_summary_nan153(.tost_orig153(...)),
                                         usp_tests(f1, b1, methode = "premium")),
                          error = function(e) e)
           !inherits(r, "error") && identical(r$non_applicable, "statistique non definie") &&
             identical(r$p, NA_real_) && identical(r$stat, NA_real_) && identical(names(r), ref) &&
             !exists("summary", envir = environment(run_engine), inherits = FALSE) &&
             !inherits(tt, "error") && ligne_tost_coherente153(ligne153(tt, LIGNE_TOST153), r, x153) &&
             identical(ligne153(tt, LIGNE_TOST153)$verdict, "INFO") &&
             isTRUE(avec_summary_nan153(tost_coherent153(r, ref, x153, y153))) &&
             !tost_coherent153(r, ref, x153, y153) && !tost_coherent153(forge, ref, x153, y153) &&
             tost_coherent153(test_tost_intercept(x153, y153), ref, x153, y153)
         })
# Branche R12 des fonctions de coherence (x ecarte par lm(), issue possible
# sur une autre plateforme) : summary() injectee rend la table des
# coefficients sans la ligne x. Sous l'injection, la condition R12 est
# vraie et "x ecarte" (#168) est accepte avec le detail du garde-fou ;
# hors injection, la meme reponse est refusee (condition fausse).
avec_summary_sans_x153 <- function(expr) {
  e <- environment(run_engine)
  existait <- exists("summary", envir = e, inherits = FALSE)
  if (existait) orig <- get("summary", envir = e, inherits = FALSE)
  assign("summary", function(object, ...) {
    s <- base::summary(object, ...)
    if (inherits(object, "lm")) s$coefficients <- s$coefficients[rownames(s$coefficients) != "x", , drop = FALSE]
    s
  }, envir = e)
  on.exit(if (existait) assign("summary", orig, envir = e) else rm("summary", envir = e))
  expr
}
verifier("Coherence TOST (#153, #168) : x ecarte par lm() (injection de summary() sans la ligne x) -> 'x ecarte' accepte, ligne au detail du garde-fou R12 ; meme reponse refusee quand lm() garde x ; reponse calculee refusee sous la condition R12",
         {
           ref <- names(test_tost_intercept(x153, y153))
           f1 <- usp_ajuster(x153, y153); b1 <- usp_bootstrap(f1, B = B_MIN_USAGE)
           r12 <- avec_summary_sans_x153(test_tost_intercept(x153, y153))
           ok12 <- avec_summary_sans_x153(tost_coherent153(r12, ref, x153, y153))
           tt12 <- avec_injection("test_tost_intercept",
                                  function(...) avec_summary_sans_x153(.tost_orig153(...)),
                                  usp_tests(f1, b1, methode = "premium"))
           r0 <- test_tost_intercept(x153, y153)
           identical(r12$non_applicable, "x ecarte") && isTRUE(ok12) &&
             ligne_tost_coherente153(ligne153(tt12, LIGNE_TOST153), r12, x153) &&
             !tost_coherent153(r12, ref, x153, y153) &&
             !isTRUE(avec_summary_sans_x153(tost_coherent153(r0, ref, x153, y153))) &&
             tost_coherent153(r0, ref, x153, y153) &&
             !exists("summary", envir = environment(run_engine), inherits = FALSE)
         })
# Issue #168 : motif du garde-fou R12 (x ecarte par lm() pour colinearite,
# hors volumes constants) dans le detail des lignes constante, pente et
# Fisher, comme pour les lignes TOST (#153) et R2. Aucun jeu du domaine ne
# l'atteint de facon stable (issue de lm() dependante de la plateforme) :
# summary() est injectee sans la ligne x dans les trois fonctions qui
# regressent y sur x (test_intercept(), test_lm_complet(),
# test_tost_intercept()), et dans elles seules. Les textes attendus sont
# ecrits en dur : TOST et R2 gardent leurs chaines d'avant #168.
DETAIL_R12_168 <- "regression de y sur x : x ecarte par lm() pour colinearite, test non applicable"
DETAIL_R2_R12_168 <- "x ecarte par lm() pour colinearite : R2 non defini"
LIGNES_R12_168 <- c("Nullite de la constante (proportionnalite stricte)",
                    LIGNE_TOST153,
                    "Test de Student sur la pente (lm(y~x))",
                    "Test de Fisher (significativite globale)")
LIGNE_R2_168 <- "Coefficient de determination R2"
FONCTIONS_R12_168 <- c("test_intercept", "test_lm_complet", "test_tost_intercept")
# Evalue expr avec les trois fonctions enveloppees dans avec_summary_sans_x153().
avec_r12_168 <- function(expr) {
  e <- environment(run_engine)
  orig <- mget(FONCTIONS_R12_168, envir = e)
  for (nm in FONCTIONS_R12_168) local({
    f <- orig[[nm]]
    assign(nm, function(...) avec_summary_sans_x153(f(...)), envir = e)
  })
  on.exit(for (nm in FONCTIONS_R12_168) assign(nm, orig[[nm]], envir = e))
  expr
}
verifier("test_intercept() et test_lm_complet() : champ x_ecarte TRUE sur la seule branche du garde-fou R12 (injection), FALSE sur la branche calculee et a volumes constants, stat et p NA sous R12 ; test_tost_intercept() : motif 'x ecarte' sous R12, 'volumes constants' a volumes constants (#168)",
         {
           xq <- 300 * (1 + c(1, -1, 1, -1, 1, -1, 1, -1) * 1e-8)
           i12 <- avec_r12_168(test_intercept(x153, y153))
           l12 <- avec_r12_168(test_lm_complet(x153, y153))
           i0 <- test_intercept(x153, y153); l0 <- test_lm_complet(x153, y153)
           identical(i12$x_ecarte, TRUE) && identical(l12$x_ecarte, TRUE) &&
             identical(i0$x_ecarte, FALSE) && identical(l0$x_ecarte, FALSE) &&
             identical(test_intercept(xq, y153)$x_ecarte, FALSE) &&
             identical(test_lm_complet(xq, y153)$x_ecarte, FALSE) &&
             identical(i12$stat, NA_real_) && identical(i12$p, NA_real_) &&
             identical(l12$t_pente, NA_real_) && identical(l12$F, NA_real_) && identical(l12$R2, NA_real_) &&
             identical(names(i12), names(i0)) && identical(names(l12), names(l0)) &&
             identical(avec_r12_168(test_tost_intercept(x153, y153))$non_applicable, "x ecarte") &&
             identical(test_tost_intercept(xq, y153)$non_applicable, "volumes constants") &&
             is.na(test_tost_intercept(x153, y153)$non_applicable) &&
             !exists("summary", envir = environment(run_engine), inherits = FALSE)
         })
verifier("usp_tests(), x ecarte par lm() hors volumes constants (injection de summary() dans les trois fonctions qui regressent y sur x) : constante, TOST, pente, Fisher non applicables (INFO, p retenue NA) au detail du garde-fou R12, R2 au sien ; autres lignes et ordre identiques a l'appel sans injection (#168)",
         {
           f1 <- usp_ajuster(x153, y153); b1 <- usp_bootstrap(f1, B = B_MIN_USAGE)
           t12 <- tryCatch(avec_r12_168(usp_tests(f1, b1, methode = "premium")), error = function(e) e)
           t0 <- usp_tests(f1, b1, methode = "premium")
           if (inherits(t12, "error")) return(paste("erreur :", conditionMessage(t12)))
           noms12 <- vapply(t12, function(l) l$test, ""); noms0 <- vapply(t0, function(l) l$test, "")
           pb <- character(0)
           for (nm in LIGNES_R12_168) {
             l <- ligne153(t12, nm)
             if (!(identical(l$type, "non applicable") && identical(l$verdict, "INFO") &&
                   is.na(l$p_retenue) && identical(l$detail, DETAIL_R12_168)))
               pb <- c(pb, nm)
             if (identical(ligne153(t0, nm)$detail, DETAIL_R12_168)) pb <- c(pb, paste(nm, "(sans injection)"))
           }
           r2 <- ligne153(t12, LIGNE_R2_168)
           if (!(identical(r2$type, "non applicable") && identical(r2$detail, DETAIL_R2_R12_168)))
             pb <- c(pb, LIGNE_R2_168)
           autres <- !noms0 %in% c(LIGNES_R12_168, LIGNE_R2_168)
           if (!identical(noms12, noms0)) pb <- c(pb, "ordre des lignes")
           else if (!identical(t12[autres], t0[autres])) pb <- c(pb, "autres lignes modifiees")
           if (exists("summary", envir = environment(run_engine), inherits = FALSE)) pb <- c(pb, "summary non restauree")
           if (length(pb)) paste(pb, collapse = " ; ") else TRUE
         })
# Priorite R13 > R12 dans usp_tests() (garde !vol_cst de detail_r12()) : a
# volumes constants, test_intercept() et test_lm_complet() sortent avant
# lm() avec x_ecarte = FALSE ; pour atteindre la garde, leur resultat est
# rendu avec x_ecarte force a TRUE. TOST : priorite assuree par
# test_tost_intercept() (motif "volumes constants" teste avant lm()).
verifier("usp_tests() a volumes constants, x_ecarte force a TRUE dans test_intercept() et test_lm_complet() : le motif R13 prime sur R12 pour constante, pente, Fisher (garde de detail_r12()), TOST et R2 (#168)",
         {
           xq <- 300 * (1 + c(1, -1, 1, -1, 1, -1, 1, -1) * 1e-8)
           fq <- usp_ajuster(xq, y153); bq <- suppressWarnings(usp_bootstrap(fq, B = B_MIN_USAGE))
           e <- environment(run_engine)
           orig <- mget(c("test_intercept", "test_lm_complet"), envir = e)
           force_ecarte <- function(f) function(...) { r <- f(...); r$x_ecarte <- TRUE; r }
           tq <- tryCatch(suppressWarnings({
             assign("test_intercept", force_ecarte(orig$test_intercept), envir = e)
             assign("test_lm_complet", force_ecarte(orig$test_lm_complet), envir = e)
             usp_tests(fq, bq, methode = "premium")
           }), error = function(e) e)
           for (nm in names(orig)) assign(nm, orig[[nm]], envir = e)
           !inherits(tq, "error") &&
             identical(get("test_intercept", envir = e), orig$test_intercept) &&
             all(vapply(c(LIGNES_R12_168, LIGNE_R2_168), function(nm) {
               l <- ligne153(tq, nm)
               identical(l$type, "non applicable") && startsWith(l$detail, "volumes x_t constants")
             }, logical(1)))
         })
# Jeu xp153 (y = x / 2, issue de lm() dependante de la plateforme, voir
# ci-dessous) : le detail des quatre lignes porte le motif R12 si et
# seulement si lm(y ~ x) ecarte x sur cette machine (condition recalculee
# sur les donnees ajustees, comme dans le moteur).
verifier("usp_tests(), y exactement proportionnel a x : constante, TOST, pente et Fisher au detail du garde-fou R12 si et seulement si lm(y ~ x) ecarte x sur cette plateforme (#168)",
         {
           f <- usp_ajuster(2^(0:7), 2^(0:7) / 2)
           b <- suppressWarnings(usp_bootstrap(f, B = B_MIN_USAGE))
           tt <- tryCatch(suppressWarnings(usp_tests(f, b, methode = "premium")), error = function(e) e)
           ecarte <- local({ x <- f$x; y <- f$y
             !"x" %in% rownames(summary(stats::lm(y ~ x))$coefficients) })
           !inherits(tt, "error") &&
             all(vapply(LIGNES_R12_168, function(nm)
               identical(ligne153(tt, nm)$detail, DETAIL_R12_168) == ecarte, logical(1)))
         })
# Entree construite de l'issue : y exactement proportionnel a x (x
# puissances de 2, y = x / 2). Issue dependante de la plateforme (voir
# ci-dessus) : aucune erreur R et issue coherente.
xp153 <- 2^(0:7)
verifier("usp_tests() : y exactement proportionnel a x -> sans erreur R ; ligne Cook non applicable avec motif (D_t non fini) ou diagnostic fini (x non ecarte par lm()), selon la plateforme (#153)",
         {
           f <- usp_ajuster(xp153, xp153 / 2)
           b <- suppressWarnings(usp_bootstrap(f, B = B_MIN_USAGE))
           tt <- tryCatch(suppressWarnings(usp_tests(f, b, methode = "premium")), error = function(e) e)
           !inherits(tt, "error") &&
             (cook_garde153(ligne153(tt, LIGNE_COOK153)) ||
                (cook_calcule153(ligne153(tt, LIGNE_COOK153)) && !cook_x_ecarte153(f$x, f$y)))
         })
# Meme entree par run_engine() (decision du mainteneur du 02/10/2026 : la
# serie exactement proportionnelle n'est pas refusee, issue #188) : ok =
# TRUE ; ligne Cook non applicable si et seulement si le motif des
# graphiques d'influence (plots_data$influence_motif) est pose ; motif
# absent sur les donnees de test, lr_delta et qq_enveloppe restant en fin
# de liste.
verifier("run_engine : y exactement proportionnel a x -> ok = TRUE ; ligne Cook non applicable et plots_data$influence_motif pose (residu_std et cook non finis), ou ligne Cook diagnostic finie et motif absent (x non ecarte par lm()) ; motif absent sur les donnees de test (#153)",
         {
           rp <- calcul_extreme(xp153, xp153 / 2); r1 <- calcul_extreme(x, y)
           tp <- engine_table_tests(rp); cp <- tp[tp$test == LIGNE_COOK153, ]
           garde <- identical(cp$type, "non applicable") && identical(cp$estimation, NA_real_) &&
             influence_garde153(rp$plots_data)
           calcule <- identical(cp$type, "diagnostic") && isTRUE(is.finite(cp$estimation)) &&
             influence_calcule153(rp$plots_data) && !cook_x_ecarte153(xp153, xp153 / 2)
           isTRUE(rp$ok) && isTRUE(r1$ok) && (garde || calcule) &&
             identical(tail(names(rp$plots_data), 1), "qq_enveloppe") &&
             is.null(r1$plots_data$influence_motif)
         })
verifier("test_tost_intercept() : entrees sous-normales (x et y x 1e-320, 5e-324) -> sans erreur R, memes champs que la branche calculee ; motif egal a celui que declenchent les conditions de test_tost_intercept() sur ces donnees (volumes constants, marge, x ecarte par lm() (R12), 'statistique non definie' si et seulement si p_bas ou p_haut, recalculees depuis summary(lm(y ~ x)), n'est pas finie), ligne calculee finie sinon (#153)",
         {
           ref <- names(test_tost_intercept(x153, y153))
           all(vapply(c(1e-320, 5e-324), function(f) {
             r <- tryCatch(test_tost_intercept(x153 * f, y153 * f), error = function(e) e)
             tost_coherent153(r, ref, x153 * f, y153 * f)
           }, logical(1)))
         })
# Issue observee sur la plateforme courante, pour le journal (CI comprise).
local({
  cp <- tryCatch({
    f <- usp_ajuster(xp153, xp153 / 2)
    ligne153(suppressWarnings(usp_tests(f, suppressWarnings(usp_bootstrap(f, B = B_MIN_USAGE)),
                                        methode = "premium")), LIGNE_COOK153)$type
  }, error = function(e) paste("erreur R :", conditionMessage(e)))
  ts <- vapply(c(1e-320, 5e-324), function(f) tryCatch({
    r <- test_tost_intercept(x153 * f, y153 * f)
    if (is.na(r$non_applicable)) sprintf("calcule (p = %.3g)", r$p) else r$non_applicable
  }, error = function(e) paste("erreur R :", conditionMessage(e))), "")
  cat(sprintf("  note : plateforme courante, y = x / 2 : ligne Cook %s ; TOST sous-normal 1e-320 : %s ; 5e-324 : %s (#153).\n",
              cp, ts[1], ts[2]))
})
verifier("usp_tests() et engine_influence() en appel direct : aucune erreur R pour x et y x 10^e (e de -300 a 300 par pas de 10, -165, -164, -160, 152, 160), sous-normaux et x seul ; sous-normaux, ligne TOST coherente avec test_tost_intercept() ; hors sous-normaux, max D_t egal a celui de l'echelle 1 a TOLERANCE pres et D_t de engine_influence() identical() a la ligne Cook (#153)",
         {
           f1 <- usp_ajuster(x153, y153); b1 <- usp_bootstrap(f1, B = B_MIN_USAGE)
           ligne <- function(tt, nom) tt[[which(vapply(tt, function(l) l$test, "") == nom)]]
           cook <- function(tt) ligne(tt, "Points influents (distance de Cook)")
           d1 <- cook(usp_tests(f1, b1, methode = "premium"))$estim
           # Echelles de ech153 hors puissances de 10 symetriques : les
           # sous-normaux et l'echelle asymetrique, toutes reprises.
           autres <- ech153[vapply(ech153, function(f) f[1] < .Machine$double.xmin || f[1] != f[2],
                                   logical(1))]
           ech <- c(lapply(c(seq(-300, 300, by = 10), -165, -164, -160, 152, 160),
                           function(e) c(10^e, 10^e)), autres)
           length(autres) == length(ech153) - length(e_sym153) && all(vapply(ech, function(f) {
             fe <- tryCatch(suppressWarnings(usp_ajuster(x153 * f[1], y153 * f[2])),
                            error = function(e) e)
             if (inherits(fe, "error")) return(FALSE)
             tt <- tryCatch(suppressWarnings(usp_tests(fe, b1, methode = "premium")),
                            error = function(e) e)
             inf <- tryCatch(suppressWarnings(engine_influence(fe)), error = function(e) e)
             if (inherits(tt, "error") || inherits(inf, "error")) return(FALSE)
             sous_normal <- f[1] < .Machine$double.xmin
             if (sous_normal) {
               r <- tryCatch(test_tost_intercept(fe$x, fe$y), error = function(e) e)
               return(tost_coherent153(r, names(test_tost_intercept(x153, y153)), fe$x, fe$y) &&
                        ligne_tost_coherente153(ligne(tt, LIGNE_TOST153), r, fe$x))
             }
             isTRUE(outils153$comparer_objets(d1, cook(tt)$estim)$conforme) &&
               identical(max(inf$cook), cook(tt)$estim)
           }, logical(1)))
         })
verifier("run_engine : x et y x 10^e (e de -300 a 300, -165, -160, 152, 160), sous-normaux, x seul -> refus de #145 hors du domaine ; dans le domaine (echantillon), ok = TRUE, sigma_USP et p retenues a TOLERANCE pres, verdicts identiques a l'echelle 1 ; jamais d'erreur R ni de defaut intercepte (#153)",
         {
           cle <- function(r) { tt <- engine_table_tests(r)
             list(sigma = r$parametre_final$sigma_usp, p = tt$p_retenue) }
           r1 <- calcul_extreme(x153, y153); a <- cle(r1); v1 <- engine_table_tests(r1)$verdict
           echantillon <- c(-51, -30, -10, -1, 1, 10, 30, 47)
           n_dans <- 0L
           ok <- all(vapply(ech153, function(f) {
             xx <- x153 * f[1]; yy <- y153 * f[2]
             dans <- dans_domaine(c(xx, yy))
             e <- round(log10(f[1]))
             if (dans && !(f[1] == f[2] && e %in% echantillon)) return(TRUE)
             r <- tryCatch(calcul_extreme(xx, yy), error = function(e) e)
             if (inherits(r, "error") || !inherits(r, "usp_engine") ||
                 contient(r$validation$erreurs, MOTIF_DEFAUT) || !is.null(r$validation$erreur_r))
               return(FALSE)
             if (!dans) return(identical(r$ok, FALSE) && contient(r$validation$erreurs, MOTIF_DOMAINE))
             n_dans <<- n_dans + 1L
             isTRUE(r$ok) && isTRUE(outils153$comparer_objets(a, cle(r))$conforme) &&
               identical(engine_table_tests(r)$verdict, v1)
           }, logical(1)))
           ok && isTRUE(r1$ok) && n_dans == length(echantillon) &&
             !dans_domaine(c(x153, y153) * 10^-52) && !dans_domaine(c(x153, y153) * 10^48)
         })
verifier("run_engine : erreur injectee dans le calcul (usp_simuler, usp_tests) -> ok = FALSE, defaut intercepte, sans erreur R (#88)",
         all(vapply(c("usp_simuler", "usp_tests"), function(nom) {
           r <- tryCatch(avec_injection(nom, panne, calcul_extreme(x, y)), error = function(e) e)
           er <- r$validation$erreur_r
           !inherits(r, "error") && identical(r$ok, FALSE) && inherits(r, "usp_engine") &&
             contient(r$validation$erreurs, MOTIF_DEFAUT) &&
             is.list(er) && identical(names(er), c("message", "appel", "origine", "pile")) &&
             is.character(er$message) && length(er$pile) >= 1L &&
             is.character(er$origine) && length(er$origine) == 1L && er$origine %in% er$pile &&
             identical(r$methode, "premium") && identical(r$metadata$methode, "premium")
         }, logical(1))))
# Origine = derniere fonction de la pile definie dans le moteur. Trois
# injections : (1) erreur dans usp_simuler(), appelee par usp_bootstrap()
# sous engine_sous_graine() : origine usp_simuler ; (2) usp_tests() dont
# l'erreur nait d'un argument passe a une fermeture locale add() et evalue
# paresseusement dans le cadre de sprintf() (forme du scenario yt x 1e-300
# d'avant #145) : add() n'est pas une fonction de l'environnement du
# moteur, l'origine est usp_tests ; (3) usp_tests() dont l'erreur nait dans
# une fonction de R (stats::lm.fit) : attribuee a usp_tests.
verifier("run_engine : origine reelle de l'erreur, fonction du moteur (piles injectees : usp_bootstrap > engine_sous_graine > usp_simuler ; usp_tests > add > sprintf ; usp_tests > stats::lm.fit)",
         {
           b1 <- avec_injection("usp_simuler", panne, calcul_extreme(x, y))$validation
           b2 <- avec_injection("usp_tests", function(...) {
             add <- function(nom, detail) sprintf("%s : %s", nom, detail)
             add("ligne", stop("panne simulee"))
           }, calcul_extreme(x, y))$validation
           b3 <- avec_injection("usp_tests", function(...) stats::lm.fit(matrix(NA_real_, 2, 1), c(1, 2)),
                                calcul_extreme(x, y))$validation
           identical(b1$erreur_r$pile, c("usp_bootstrap", "engine_sous_graine", "usp_simuler")) &&
             identical(b1$erreur_r$origine, "usp_simuler") &&
             contient(b1$erreurs, "(erreur R dans usp_simuler())") &&
             identical(b1$erreur_r$message, "panne simulee") &&
             identical(b2$erreur_r$pile, c("usp_tests", "add", "sprintf")) &&
             identical(b2$erreur_r$origine, "usp_tests") &&
             contient(b2$erreurs, "(erreur R dans usp_tests())") &&
             identical(b3$erreur_r$pile, c("usp_tests", "stats::lm.fit")) &&
             identical(b3$erreur_r$origine, "usp_tests")
         })
verifier("run_engine : injection restauree, calcul nominal apres un defaut intercepte (ok = TRUE)",
         {
           avec_injection("usp_simuler", panne, calcul_extreme(x, y))
           isTRUE(calcul_extreme(x, y)$ok)
         })
# L'erreur injectee dans usp_simuler() nait sous engine_sous_graine() :
# la restauration se fait au deroulement de la pile (on.exit).
verifier("run_engine : generateur et graine de l'appelant restaures apres un defaut intercepte (erreur nee sous engine_sous_graine())",
         {
           kind0 <- RNGkind()
           suppressWarnings(RNGkind("Wichmann-Hill", "Box-Muller", "Rounding"))
           set.seed(7); avant <- .Random.seed; k_avant <- RNGkind()
           r <- avec_injection("usp_simuler", panne, calcul_extreme(x, y))
           ok <- identical(r$ok, FALSE) && identical(r$validation$erreur_r$origine, "usp_simuler") &&
             identical(.Random.seed, avant) && identical(RNGkind(), k_avant)
           suppressWarnings(RNGkind(kind0[1], kind0[2], kind0[3]))
           ok
         })
verifier("run_engine : options(usp.engine.lever_erreurs = TRUE) releve l'erreur au lieu de l'intercepter",
         {
           ancien <- options(usp.engine.lever_erreurs = TRUE)
           leve <- leve_erreur(avec_injection("usp_simuler", panne, calcul_extreme(x, y)))
           options(ancien)
           leve && identical(avec_injection("usp_simuler", panne, calcul_extreme(x, y))$ok, FALSE)
         })
verifier("run_engine, Merz-Wuthrich : erreur dans le calcul apres mw_valider_triangle() -> defaut intercepte (reserve2)",
         {
           e <- environment(run_engine)
           orig <- get("mw_bootstrap", envir = e)
           assign("mw_bootstrap", function(...) stop("panne simulee"), envir = e)
           tri <- as.matrix(read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv")))
           tri <- unname(tri[, colnames(tri) != "i"]); storage.mode(tri) <- "double"
           r <- tryCatch(run_engine(methode = "reserve2", triangle = tri, segment = 1, B = B_MIN_USAGE),
                         error = function(err) err,
                         finally = assign("mw_bootstrap", orig, envir = e))
           !inherits(r, "error") && identical(r$ok, FALSE) && identical(r$methode, "reserve2") &&
             contient(r$validation$erreurs, "(erreur R dans mw_bootstrap())") &&
             identical(r$validation$erreur_r$origine, "mw_bootstrap")
         })
verifier("run_engine : erreurs d'usage -> erreur R explicite, non interceptee (annexe III, methode 'prime', segment 99, reserve2 sans triangle, xt manquant, B = -1, 0 ou 98, seed NA, bareme 'x')",
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", annexe = "III", segment = 1,
                                B = B_MIN_USAGE, nature_donnees = "brutes")) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "prime", segment = 1, B = B_MIN_USAGE)) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", segment = 99, B = B_MIN_USAGE,
                                nature_donnees = "brutes")) &&
         leve_erreur(run_engine(methode = "reserve2", B = B_MIN_USAGE)) &&
         leve_erreur(run_engine(yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                                nature_donnees = "brutes")) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = -1,
                                nature_donnees = "brutes")) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = 0,
                                nature_donnees = "brutes")) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = 98,
                                nature_donnees = "brutes")) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                                seed = NA, nature_donnees = "brutes")) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                                bareme = "x", nature_donnees = "brutes")))

# Suite de #88 (decision du mainteneur du 26/09/2026) : alpha, sigma_standard,
# seed et bareme invalides levent une erreur d'usage de
# .engine_verifier_usage(), sur les deux branches (premium et reserve2),
# avant tout calcul : ni defaut de calcul intercepte, ni message traduit de
# R. Le motif est une sous-chaine ASCII du message du moteur.
tri_usage <- as.matrix(read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv")))
tri_usage <- unname(tri_usage[, colnames(tri_usage) != "i"])
storage.mode(tri_usage) <- "double"
# Les arguments passes remplacent ceux de l'appel nominal (B compris) ; une
# valeur NULL est transmise telle quelle (a[n] <- l[n] conserve l'entree).
appel_usage <- function(nominal, ...) {
  l <- list(...)
  for (n in names(l)) nominal[n] <- l[n]
  do.call(run_engine, nominal)
}
usage_premium <- function(...) appel_usage(list(xt = x, yt = y, methode = "premium", segment = 1,
                                                B = B_MIN_USAGE, nature_donnees = "brutes"), ...)
usage_mw <- function(...) appel_usage(list(methode = "reserve2", triangle = tri_usage,
                                           segment = 1, B = B_MIN_USAGE), ...)
# TRUE si chaque valeur de `valeurs`, passee comme argument `arg`, leve une
# erreur R dont le message contient `motif` (fixe), sur les deux branches.
erreur_usage <- function(arg, valeurs, motif) {
  all(vapply(valeurs, function(v) {
    all(vapply(list(usage_premium, usage_mw), function(f) {
      e <- tryCatch(do.call(f, stats::setNames(list(v), arg)), error = function(e) e)
      inherits(e, "error") && grepl(motif, conditionMessage(e), fixed = TRUE)
    }, logical(1)))
  }, logical(1)))
}
# TRUE si chaque valeur est acceptee (ok = TRUE) sur les deux branches.
usage_accepte <- function(arg, valeurs) {
  all(vapply(valeurs, function(v) {
    all(vapply(list(usage_premium, usage_mw), function(f) {
      r <- tryCatch(do.call(f, stats::setNames(list(v), arg)), error = function(e) e)
      !inherits(r, "error") && isTRUE(r$ok)
    }, logical(1)))
  }, logical(1)))
}
verifier("run_engine : alpha NA, vide, texte, vecteur, logique, 0, 0,30, 0,5, 0,999, 1, 1.5, -0.1, Inf -> erreur d'usage (premium, reserve2)",
         erreur_usage("alpha", list(NA, NULL, "0.1", c(0.1, 0.2), TRUE, 0, 0.30, 0.5, 0.999,
                                    1, 1.5, -0.1, Inf),
                      "0 < alpha < SEUIL_ECHEC_SENS_REJETER = 0.3, est attendu"))
verifier("run_engine : alpha 0,30 refuse, message citant la zone ALERTE",
         {
           e <- tryCatch(usage_premium(alpha = 0.30), error = function(e) e)
           inherits(e, "error") && startsWith(conditionMessage(e), "alpha = 0.3 : ") &&
             grepl("la zone ALERTE des tests en sens rejeter disparait", conditionMessage(e),
                   fixed = TRUE)
         })
# alpha = 0,01 n'est plus accepte a B = B_MIN_USAGE = 99 (#127 : B >= 400 a
# ce seuil) ; son acceptation a B = 400 est verifiee plus bas sur
# .engine_verifier_usage(), sans bootstrap.
verifier("run_engine : alpha 0,05 ; 0,10 ; 0,29 acceptes a B = 99 (premium, reserve2)",
         usage_accepte("alpha", list(0.05, 0.10, 0.29)))
verifier("run_engine : SEUIL_ECHEC_SENS_REJETER vaut 0,30 (seuil ECHEC des tests en sens rejeter)",
         identical(SEUIL_ECHEC_SENS_REJETER, 0.30))
verifier("run_engine : sigma_standard NA, texte, vecteur, logique, 0, negatif, Inf -> erreur d'usage (premium, reserve2)",
         erreur_usage("sigma_standard", list(NA, NA_real_, "0.1", c(0.1, 0.2), TRUE, 0, -0.1, Inf),
                      "sigma_standard > 0, est attendu"))
verifier("run_engine : sigma_standard NULL, 0,10 et 2 acceptes (premium, reserve2)",
         usage_accepte("sigma_standard", list(NULL, 0.10, 2)))
verifier("run_engine : seed NULL, NA, texte, vecteur, logique, 1.5, Inf, 3e9 -> erreur d'usage du moteur (premium, reserve2)",
         erreur_usage("seed", list(NULL, NA, NA_real_, "5", "a", c(1, 2), TRUE, 1.5, Inf, 3e9),
                      "un nombre scalaire fini entier, |seed| <= 2147483647"))
verifier("run_engine : seed NA et NULL -> message du moteur citant la valeur recue",
         {
           e1 <- tryCatch(usage_premium(seed = NA), error = function(e) e)
           e2 <- tryCatch(usage_mw(seed = NULL), error = function(e) e)
           inherits(e1, "error") && inherits(e2, "error") &&
             startsWith(conditionMessage(e1), "seed = NA : un nombre scalaire fini entier") &&
             startsWith(conditionMessage(e2), "seed = vide : ") &&
             grepl("NULL refuse : calcul non reproductible", conditionMessage(e2), fixed = TRUE)
         })
verifier("run_engine : seed 20260831, -5, 5L, .Machine$integer.max et son oppose acceptes (premium, reserve2)",
         usage_accepte("seed", list(20260831, -5, 5L, .Machine$integer.max,
                                    -.Machine$integer.max)))
verifier("run_engine : bareme 'moyen', 'Court', 'co', '', NA, c('court', 'long'), 1 -> erreur d'usage citant l'annexe XVII, section G (premium, reserve2)",
         erreur_usage("bareme", list("moyen", "Court", "co", "", NA, NA_character_,
                                     c("court", "long"), 1),
                      "(bareme de credibilite de l'annexe XVII, section G)") &&
           {
             e <- tryCatch(usage_mw(bareme = "moyen"), error = function(e) e)
             startsWith(conditionMessage(e), "bareme = \"moyen\" : ")
           })
verifier("run_engine : bareme NULL, 'court' et 'long' acceptes (premium, reserve2)",
         usage_accepte("bareme", list(NULL, "court", "long")))
# Constat C1 de la revue finale d'E1 : B est borne par B_MIN_USAGE = 99
# (plancher bilateral 2/(B+1) = 0,02 < alpha/2, detection de degenerescence
# armee, ligne de largeur d'IC presente) ; B = 0 et B = 98 etaient acceptes
# (controle B >= 0).
# Constat m1 de l'audit leger (#44) : B non entier (99.5, 999.5) etait
# accepte et consigne tel quel dans metadata$B pour floor(B) tirages.
verifier("run_engine : B 0, 98, 99.5, 999.5, -1, NA, texte, vecteur, Inf -> erreur d'usage citant B_MIN_USAGE = 99 (premium, reserve2)",
         B_MIN_USAGE == 99 &&
           erreur_usage("B", list(0, 98, 98.9, 99.5, 999.5, -1, NA, NA_real_, "999", c(99, 999), Inf),
                        "B >= B_MIN_USAGE = 99, sans attribut, est attendu") &&
           {
             e <- tryCatch(usage_premium(B = 98), error = function(e) e)
             inherits(e, "error") && startsWith(conditionMessage(e), "B = 98 : ")
           })
verifier("run_engine : B = B_MIN_USAGE = 99 accepte (premium, reserve2)",
         usage_accepte("B", list(99)))

# #127 (note d'actuary et decisions du mainteneur du 28/09/2026) : B + 1 >
# 4/alpha, en plus de B_MIN_USAGE, pour que l'ECHEC bilateral d'une ligne a
# p-value Monte-Carlo seule reste atteignable (plancher 2/(B+1) < alpha/2).
# Reference : table du paragraphe 2 de la note, plus petit entier B tel que
# 2 * (1 / (B + 1)) < alpha / 2 (4/alpha si entier, ceiling(4/alpha) - 1 sinon).
verifier("engine_b_minimal : table de la note (#127) pour alpha 0,01 a 0,29",
         identical(vapply(c(0.01, 0.02, 0.025, 0.03, 0.04, 0.05, 0.10, 0.20, 0.29),
                          engine_b_minimal, numeric(1)),
                   c(400, 200, 160, 133, 100, 80, 40, 20, 13)))
verifier("engine_b_minimal : minimalite sur alpha = 0,005..0,295 (b admis, b - 1 refuse)",
         all(vapply(seq(0.005, 0.295, by = 0.005), function(a) {
           b <- engine_b_minimal(a)
           (2 * (1 / (b + 1)) < a / 2) && !(2 * (1 / b) < a / 2)
         }, logical(1))))
verifier("run_engine : B = 99, alpha = 0,01 -> erreur d'usage B + 1 > 4/alpha, B >= 400 (premium, reserve2)",
         erreur_usage("alpha", list(0.01), "B + 1 > 4/alpha") &&
           erreur_usage("alpha", list(0.01), "B >= 400 a ce seuil") &&
           {
             e <- tryCatch(usage_mw(alpha = 0.01), error = function(e) e)
             inherits(e, "error") && startsWith(conditionMessage(e), "B = 99 et alpha = 0.01 : ")
           })
verifier("run_engine : B = 99, alpha = 0,04 -> erreur d'usage, B >= 100 (premium, reserve2)",
         erreur_usage("alpha", list(0.04), "B >= 100 a ce seuil"))
verifier("run_engine : B = 99 et alpha 0,05 ou 0,10 acceptes (premium, reserve2)",
         usage_accepte("alpha", list(0.05, 0.10)))
# Bords, sur .engine_verifier_usage() directement (aucun bootstrap).
verif_usage <- function(B, alpha) {
  tryCatch(.engine_verifier_usage(B, 20260831, NULL, alpha = alpha, segment = 1),
           error = function(e) e)
}
verifier(".engine_verifier_usage : (399 ; 0,01) refuse par la regle en alpha, (400 ; 0,01) accepte",
         {
           e <- verif_usage(399, 0.01)
           inherits(e, "error") && grepl("B >= 400 a ce seuil", conditionMessage(e), fixed = TRUE) &&
             isTRUE(verif_usage(400, 0.01))
         })
# B < B_MIN_USAGE : engine_motif_b_alpha() rend NULL (decision du mainteneur
# du 28/09/2026), le bandeau de l'application concorde avec l'erreur au clic.
verifier(".engine_verifier_usage : (39 ; 0,10) et (40 ; 0,10) refuses par B_MIN_USAGE avant la regle en alpha ; motif en alpha NULL",
         all(vapply(c(39, 40), function(b) {
           e <- verif_usage(b, 0.10)
           inherits(e, "error") &&
             grepl("B >= B_MIN_USAGE = 99, sans attribut, est attendu", conditionMessage(e), fixed = TRUE) &&
             !grepl("4/alpha", conditionMessage(e), fixed = TRUE)
         }, logical(1))) &&
           is.null(engine_motif_b_alpha(39, 0.10)) && is.null(engine_motif_b_alpha(98, 0.01)))
# Revue d'audit de #127 (constats C1 et C2) : alpha tres petit faisait
# boucler engine_b_minimal() sans fin (b + 1 == b au-dela de 2^53) et
# as.integer() du B minimal rendait NA au-dela de .Machine$integer.max.
# L'admission est decidee par la condition directe ; chaque appel est borne
# par setTimeLimit (5 s ; une boucle sans fin leve alors une erreur de
# delai, distincte du refus attendu).
sous_delai <- function(expr) {
  setTimeLimit(elapsed = 5, transient = TRUE)
  on.exit(setTimeLimit(elapsed = Inf))
  tryCatch(expr, error = function(e) e)
}
verifier(".engine_verifier_usage : alpha 1e-16, 1e-200, 1e-310, 5e-324 -> refus B + 1 > 4/alpha sans blocage, sans valeur de B minimal",
         all(vapply(c(1e-16, 1e-200, 1e-310, 5e-324), function(a) {
           e <- sous_delai(.engine_verifier_usage(999, 20260831, NULL, alpha = a, segment = 1))
           inherits(e, "error") &&
             grepl("B + 1 > 4/alpha est requis, B trop petit pour ce seuil", conditionMessage(e), fixed = TRUE) &&
             !grepl("NA", conditionMessage(e), fixed = TRUE)
         }, logical(1))))
verifier("engine_b_minimal : alpha 1e-16, 1e-200, 1e-310, 5e-324 -> erreur explicite sans blocage",
         all(vapply(c(1e-16, 1e-200, 1e-310, 5e-324), function(a) {
           e <- sous_delai(engine_b_minimal(a))
           inherits(e, "error") &&
             startsWith(conditionMessage(e), "engine_b_minimal() : 4/alpha = ")
         }, logical(1))))
verifier("engine_motif_b_alpha : alpha = 1e-10 -> B >= 40000000000 cite, sans NA ni avertissement",
         {
           w <- NULL
           m <- withCallingHandlers(engine_motif_b_alpha(999, 1e-10),
                                    warning = function(c) { w <<- c; invokeRestart("muffleWarning") })
           is.null(w) && is.character(m) && !grepl("NA", m, fixed = TRUE) &&
             grepl("soit B >= 40000000000 a ce seuil", m, fixed = TRUE)
         })
verifier("engine_motif_b_alpha : NULL a (999 ; 0,01), message identique a l'erreur de run_engine a (99 ; 0,01)",
         {
           e <- tryCatch(usage_premium(alpha = 0.01), error = function(e) e)
           m <- engine_motif_b_alpha(99, 0.01)
           is.null(engine_motif_b_alpha(999, 0.01)) && is.character(m) && length(m) == 1L &&
             inherits(e, "error") && identical(conditionMessage(e), m) &&
             identical(engine_motif_b_alpha(99L, 0.01), m)
         })
# Coherence avec la regle des verdicts de add() (engine_registre_tests()),
# sans bootstrap : ligne a p-value Monte-Carlo seule, cle bilaterale, p_mc
# egal au plancher 2 * (1 / (B + 1)) a B = engine_b_minimal(alpha) (ECHEC) et
# a B - 1 (ALERTE) : la borne est celle du verdict, non une approximation.
verdict_plancher <- function(alpha, B) {
  r <- engine_registre_tests(list(p_mc = c(A = 2 * (1 / (B + 1))), err_mc = c(A = 0)),
                             list(A = .mc_entree(function(e) 1, "deux")), alpha, "Monte-Carlo")
  r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "A")
  l <- r$lignes()[[1]]
  c(l$nature_p, l$verdict)
}
verifier("add() : p_mc au plancher bilateral -> ECHEC a b = engine_b_minimal(alpha), ALERTE a b - 1 (alpha 0,005..0,295)",
         all(vapply(seq(0.005, 0.295, by = 0.005), function(a) {
           b <- engine_b_minimal(a)
           identical(verdict_plancher(a, b), c("Monte-Carlo", "ECHEC")) &&
             identical(verdict_plancher(a, b - 1), c("Monte-Carlo", "ALERTE"))
         }, logical(1))))

# Constat 4 de la revue finale de #88 : un segment inconnu, ou l'absence a la
# fois de segment et de sigma_standard, etaient controles apres la validation
# des donnees ; l'appel levait une erreur R sur des donnees valides et
# rendait ok = FALSE sur des donnees refusees. Controles desormais dans
# .engine_verifier_usage() : erreur R quelles que soient les donnees.
y_neg <- y; y_neg[3] <- -1
tri_2x2 <- matrix(c(1, 2, 3, NA), 2)
# TRUE si chaque appel (liste d'arguments de run_engine) leve une erreur R
# dont le message contient motif.
erreurs_segment <- function(appels, motif) {
  all(vapply(appels, function(a) {
    e <- tryCatch(do.call(run_engine, a), error = function(e) e)
    inherits(e, "error") && grepl(motif, conditionMessage(e), fixed = TRUE)
  }, logical(1)))
}
appels_segment <- function(...) {
  s <- list(...)
  list(c(list(xt = x, yt = y, methode = "premium", B = B_MIN_USAGE, nature_donnees = "brutes"), s),
       c(list(xt = x, yt = y_neg, methode = "premium", B = B_MIN_USAGE, nature_donnees = "brutes"), s),
       c(list(xt = x[1:4], yt = y[1:4], methode = "premium", B = B_MIN_USAGE, nature_donnees = "brutes"), s),
       c(list(xt = x, yt = y, methode = "reserve1", B = B_MIN_USAGE), s),
       c(list(xt = x, yt = y_neg, methode = "reserve1", B = B_MIN_USAGE), s),
       c(list(methode = "reserve2", triangle = tri_usage, B = B_MIN_USAGE), s),
       c(list(methode = "reserve2", triangle = tri_2x2, B = B_MIN_USAGE), s))
}
verifier("run_engine : segment 99 -> erreur d'usage, donnees valides ou refusees (yt negatif, T = 4, triangle 2x2 ; premium, reserve1, reserve2)",
         erreurs_segment(appels_segment(segment = 99), "Segment 99 inconnu dans l'annexe II.") &&
           erreurs_segment(appels_segment(segment = 5, annexe = "XIV"),
                           "Segment 5 inconnu dans l'annexe XIV."))
# Issue #105 : segment non scalaire, vide, NA, non fini, non entier, logique,
# texte ("1" refuse sans conversion, decision du mainteneur du 27/09/2026,
# Q-E0b-2) ou porteur d'attributs -> erreur d'usage nommant segment, quelles
# que soient les donnees. Avant #105, c(1, 2) et integer(0) levaient une
# erreur R sans nom d'argument ("the condition has length > 1", "argument is
# of length zero") et "1", TRUE, c(a = 1), matrix(1) etaient acceptes.
motif_segment <- "un nombre scalaire fini entier, sans attribut, est attendu (numero de segment"
verifier("run_engine : segment c(1, 2), integer(0), NA, NA_real_, Inf, 1.5, TRUE, \"1\", c(a = 1), matrix(1) -> erreur d'usage nommant segment, donnees valides ou refusees (premium, reserve1, reserve2 ; #105)",
         all(vapply(list(c(1, 2), integer(0), NA, NA_real_, Inf, 1.5, TRUE, "1",
                         c(a = 1), matrix(1)),
                    function(s) erreurs_segment(appels_segment(segment = s), motif_segment) &&
                      erreurs_segment(appels_segment(segment = s, annexe = "XIV"), motif_segment),
                    logical(1))))
verifier("run_engine : message de segment invalide citant la valeur recue (\"1\", c(1, 2), integer(0) ; #105)",
         erreurs_segment(appels_segment(segment = "1"), "segment = \"1\" : ") &&
           erreurs_segment(appels_segment(segment = c(1, 2)), "segment = c(1, 2) : ") &&
           erreurs_segment(appels_segment(segment = integer(0)), "segment = vide : "))
verifier("run_engine : ni segment ni sigma_standard -> erreur d'usage, donnees valides ou refusees (premium, reserve1, reserve2)",
         erreurs_segment(appels_segment(),
                         "Fournir soit sigma_standard, soit segment (avec son annexe)."))
verifier("run_engine : sigma_standard seul accepte sans segment (premium, reserve2)",
         {
           a <- usage_premium(segment = NULL, sigma_standard = 0.1)
           b <- usage_mw(segment = NULL, sigma_standard = 0.1)
           isTRUE(a$ok) && isTRUE(b$ok)
         })
# Reserve d'audit : une valeur porteuse d'attributs etait acceptee et son
# attribut propage dans le resultat ; elle est refusee.
verifier("run_engine : B, alpha, seed, bareme, sigma_standard porteurs d'attributs (noms, dim) -> erreur d'usage (premium, reserve2)",
         erreur_usage("B", list(c(a = B_MIN_USAGE), matrix(B_MIN_USAGE)), "sans attribut, est attendu") &&
           erreur_usage("alpha", list(c(a = 0.1), matrix(0.1)), "sans attribut") &&
           erreur_usage("seed", list(c(a = 5), matrix(5)), "sans attribut") &&
           erreur_usage("bareme", list(c(a = "court"), matrix("court")), "(sans attribut)") &&
           erreur_usage("sigma_standard", list(c(a = 0.1), matrix(0.1)), "sans attribut"))
verifier("run_engine : theta_equiv invalide -> refus ok = FALSE en premium et reserve1 (#33), ignore en reserve2",
         {
           r1 <- usage_premium(theta_equiv = NA)
           r3 <- run_engine(xt = x, yt = y, methode = "reserve1", segment = 1, B = B_MIN_USAGE,
                            theta_equiv = NA)
           r2 <- usage_mw(theta_equiv = NA)
           identical(r1$ok, FALSE) && is.null(r1$validation$erreur_r) &&
             contient(r1$validation$erreurs, "theta_equiv = NA") &&
             identical(r3$ok, FALSE) && is.null(r3$validation$erreur_r) &&
             contient(r3$validation$erreurs, "theta_equiv = NA") && isTRUE(r2$ok)
         })
verifier("run_engine : filet transparent sans erreur (identique avec et sans interception, hors horodatage et duree)",
         {
           sans_temps <- function(r) { r$metadata$horodatage <- NULL; r$metadata$duree_sec <- NULL; r }
           a <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                           nature_donnees = "brutes")
           ancien <- options(usp.engine.lever_erreurs = TRUE)
           b <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                           nature_donnees = "brutes")
           options(ancien)
           identical(sans_temps(a), sans_temps(b))
         })

## --- mw_valider_triangle -----------------------------------------------------
triangle <- function(n, f = 1.3, base = 100) {
  m <- matrix(NA_real_, n, n)
  for (i in 1:n) for (j in 1:(n - i + 1)) m[i, j] <- (base + 10 * i + j) * f^(j - 1)
  m
}
t5 <- triangle(5)
verifier("Triangle 5 x 5 valide : ok, I = J = 4",
         {
           r <- mw_valider_triangle(t5)
           isTRUE(r$ok) && r$I == 4 && r$J == 4 && !length(r$erreurs)
         })
verifier("Triangle : moins de 10 annees -> avertissement",
         contient(mw_valider_triangle(t5)$avertissements, "credibilite partielle"))
verifier("Triangle 4 x 4 refuse (D(2)(b) et (c))",
         {
           r <- mw_valider_triangle(triangle(4))
           !r$ok && contient(r$erreurs, "D(2)(b)") && contient(r$erreurs, "D(2)(c)")
         })
verifier("Triangle 6 x 5 (I > J) refuse : non carre",
         {
           r <- mw_valider_triangle(triangle(6)[, 1:5])
           !r$ok && contient(r$erreurs, "non carre")
         })
verifier("Triangle 5 x 6 (moins d'annees d'accident que de developpement) refuse (D(2)(e))",
         {
           r <- mw_valider_triangle(cbind(triangle(5), NA))
           !r$ok && contient(r$erreurs, "D(2)(e)")
         })
verifier("Triangle : cellule observee manquante refusee",
         {
           m <- t5; m[2, 3] <- NA
           r <- mw_valider_triangle(m)
           !r$ok && contient(r$erreurs, "(i=1, j=2)")
         })
verifier("Triangle : cumul nul ou negatif refuse",
         {
           m0 <- t5; m0[3, 1] <- 0; mn <- t5; mn[1, 5] <- -4
           !mw_valider_triangle(m0)$ok && !mw_valider_triangle(mn)$ok
         })
verifier("Triangle : cellule observee infinie refusee",
         {
           m <- t5; m[1, 2] <- Inf
           !mw_valider_triangle(m)$ok
         })
# Audit de #33 (C3) : une valeur non finie n'est pas une cellule manquante ;
# motif distinct, avec la position et la valeur.
verifier("Triangle : Inf, -Inf, NaN signales 'valeur non finie' (pas 'manquante'), NA reste 'manquante' (#33)",
         {
           m <- t5; m[1, 2] <- Inf; m[2, 1] <- -Inf; m[3, 2] <- NaN; m[1, 4] <- NA
           e <- mw_valider_triangle(m)$erreurs
           contient(e, "Valeur non finie en (i=0, j=1) : Inf") &&
             contient(e, "Valeur non finie en (i=1, j=0) : -Inf") &&
             contient(e, "Valeur non finie en (i=2, j=1) : NaN") &&
             contient(e, "Cellule observee manquante en (i=0, j=3)") &&
             !contient(e, "manquante en (i=0, j=1)") && length(e) == 4L
         })
verifier("Triangle : data.frame ou matrice de caracteres refuses",
         !mw_valider_triangle(as.data.frame(t5))$ok &&
         !mw_valider_triangle(matrix(as.character(t5), 5))$ok)
verifier("Triangle : cumul decroissant accepte avec avertissement",
         {
           m <- t5; m[1, 3] <- m[1, 2] - 1
           r <- mw_valider_triangle(m)
           isTRUE(r$ok) && contient(r$avertissements, "cumul decroissant")
         })

## --- engine_lire_donnees_csv --------------------------------------------------
df <- data.frame(t = c(2003, 2001, 2002, 2004, 2005), xt = c(3, 1, 2, 4, 5) * 100,
                 yt = c(3, 1, 2, 4, 5) * 70)
verifier("Lecture : colonnes t, xt, yt ; tri par t",
         {
           r <- engine_lire_donnees_csv(df)
           isTRUE(r$ok) && identical(r$xt, c(1, 2, 3, 4, 5) * 100) &&
             identical(r$yt, c(1, 2, 3, 4, 5) * 70) && r$n == 5
         })
verifier("Lecture : sans colonne t, ordre du fichier conserve",
         identical(engine_lire_donnees_csv(df[, c("xt", "yt")])$xt, df$xt))
verifier("Lecture : colonne manquante refusee avec message explicite",
         {
           r <- engine_lire_donnees_csv(df[, c("t", "xt")])
           !r$ok && contient(r$erreurs, "yt")
         })
verifier("Lecture : valeur non numerique refusee",
         !engine_lire_donnees_csv(data.frame(t = 1:5, xt = c("1", "2", "a", "4", "5"),
                                             yt = 1:5, stringsAsFactors = FALSE))$ok)
verifier("Lecture : tableau vide ou objet non tabulaire refuse",
         !engine_lire_donnees_csv(df[0, ])$ok && !engine_lire_donnees_csv(list(xt = 1))$ok)
# Issue #33 (defaut releve par audit, repris de l'issue #7), corrige :
# lecture d'un fichier d'echange.
verifier("Lecture : colonne facteur convertie par ses valeurs, non par ses codes (#33)",
         {
           f <- factor(c("104.2", "102.25", "109.34", "114.64", "118.41"))
           r <- engine_lire_donnees_csv(data.frame(t = factor(2001:2005), xt = f,
                                                   yt = factor(c("70", "80", "85", "90", "99"))))
           isTRUE(r$ok) && identical(r$xt, c(104.2, 102.25, 109.34, 114.64, 118.41)) &&
             identical(r$yt, c(70, 80, 85, 90, 99))
         })
# Avis d'actuary du 24/09/2026 : annexe XVII, B(2)(b) et C(2)(b), annees
# consecutives ; doublon, trou, annee non entiere ou manquante : refus.
verifier("Lecture : annees t dupliquees ou non consecutives refusees (#33)",
         {
           a <- engine_lire_donnees_csv(data.frame(t = c(2001, 2001, 2002, 2003, 2004), xt = 1:5, yt = 1:5))
           b <- engine_lire_donnees_csv(data.frame(t = c(2001, 2003, 2005, 2007, 2009), xt = 1:5, yt = 1:5))
           c <- engine_lire_donnees_csv(data.frame(t = c(2001.5, 2002.5, 2003.5, 2004.5, 2005.5),
                                                   xt = 1:5, yt = 1:5))
           !a$ok && contient(a$erreurs, "dupliquee") && !b$ok &&
             contient(b$erreurs, "non consecutives") && !c$ok && contient(c$erreurs, "entiers")
         })
verifier("Lecture : colonne t incomplete ou non numerique refusee (tri non effectue en silence) (#33)",
         {
           a <- engine_lire_donnees_csv(data.frame(t = c(3, 1, NA, 2, 5), xt = 1:5, yt = 1:5))
           b <- engine_lire_donnees_csv(data.frame(t = c("2001", "2002", "x", "2004", "2005"),
                                                   xt = 1:5, yt = 1:5, stringsAsFactors = FALSE))
           !a$ok && contient(a$erreurs, "ligne(s) 3") && !b$ok
         })
verifier("Lecture : t consecutive dans le desordre -> triee en croissant",
         {
           r <- engine_lire_donnees_csv(data.frame(t = c(2005, 2003, 2004, 2001, 2002),
                                                   xt = c(5, 3, 4, 1, 2), yt = c(50, 30, 40, 10, 20)))
           isTRUE(r$ok) && identical(r$xt, c(1, 2, 3, 4, 5)) && identical(r$yt, c(10, 20, 30, 40, 50))
         })

## --- engine_lire_triangle (#33, #4 piste 3) -----------------------------------
# Conversion fichier -> triangle en une fonction du moteur, puis
# mw_valider_triangle().
fichier_tri <- function(m) {
  d <- as.data.frame(m); names(d) <- paste0("j", seq_len(ncol(m)) - 1L)
  cbind(i = seq_len(nrow(m)), d)
}
verifier("engine_lire_triangle : colonne i ignoree, triangle 5 x 5 rendu tel quel",
         {
           r <- engine_lire_triangle(fichier_tri(t5))
           isTRUE(r$ok) && identical(r$triangle, t5) && r$I == 4 && r$J == 4
         })
verifier("engine_lire_triangle : colonnes facteur ou texte converties par leurs valeurs",
         {
           d <- fichier_tri(t5)
           d[] <- lapply(d, function(v) factor(ifelse(is.na(v), "", format(v, digits = 17))))
           r <- engine_lire_triangle(d)
           isTRUE(r$ok) && isTRUE(all.equal(r$triangle, t5, tolerance = 1e-15))
         })
verifier("engine_lire_triangle : cellule non numerique refusee (pas lue comme NA), avec sa position",
         {
           d <- fichier_tri(t5); d$j1 <- as.character(d$j1); d$j1[3] <- "abc"
           r <- engine_lire_triangle(d)
           !r$ok && contient(r$erreurs, "(i=2, j=1)") && is.null(r$triangle)
         })
verifier("engine_lire_triangle : cellule texte \"Inf\" signalee 'valeur non finie', non 'manquante' (#33)",
         {
           d <- fichier_tri(t5); d$j1 <- as.character(d$j1); d$j1[1] <- "Inf"
           r <- engine_lire_triangle(d)
           !r$ok && contient(r$erreurs, "Valeur non finie en (i=0, j=1)") &&
             !contient(r$erreurs, "manquante") && is.null(r$triangle)
         })
verifier("engine_lire_triangle : erreurs de recevabilite de mw_valider_triangle() restituees",
         {
           d <- fichier_tri(t5); d$j2[2] <- NA
           r1 <- engine_lire_triangle(d)
           r2 <- engine_lire_triangle(fichier_tri(triangle(4)))
           !r1$ok && contient(r1$erreurs, "(i=1, j=2)") && !r2$ok && contient(r2$erreurs, "D(2)(b)") &&
             !engine_lire_triangle(data.frame())$ok && !engine_lire_triangle(list(a = 1))$ok
         })

## --- usp_controle_donnees ----------------------------------------------------
verifier("Controles qualite : 8 lignes ; jeu de test OK sauf credibilite pleine (T < 10)",
         {
           r <- usp_controle_donnees(x, y)
           verd <- vapply(r, function(l) l$verdict, "")
           length(r) == 8 && all(verd %in% c("OK", "ECHEC")) &&
             identical(unname(verd[8]), "ECHEC") && all(verd[1:7] == "OK")
         })
# Issue #33 (defaut releve par audit, repris de l'issue #7), corrige. Avis
# d'actuary du 24/09/2026 : un controle non etabli vaut ECHEC et le dit ;
# sous T = 5, la ligne de credibilite sort ECHEC, bareme non defini.
verifier("Controles qualite : T = 4 donne une ligne ECHEC (et non une erreur R) (#33)",
         {
           r <- usp_controle_donnees(x[1:4], y[1:4])
           l <- r[[8]]
           length(r) == 8 && identical(l$verdict, "ECHEC") &&
             grepl("bareme non defini sous T = 5", l$detail, fixed = TRUE) &&
             identical(r[[1]]$verdict, "ECHEC")
         })
verifier("Controles qualite : un NA donne une ligne ECHEC (et non une erreur R) (#33)",
         {
           r <- usp_controle_donnees(replace(x, 2, NA), y)
           verd <- vapply(r, function(l) l$verdict, "")
           det <- vapply(r, function(l) l$detail, "")
           nx <- c("Strict positivite de x_t", "Absence de doublons parfaits",
                   "Plausibilite du ratio y/x", "Amplitude du volume (stabilite du perimetre)")
           tests <- vapply(r, function(l) l$test, "")
           length(r) == 8 && all(verd[tests %in% nx] == "ECHEC") &&
             all(grepl("controle non etabli : valeur(s) manquante(s)", det[tests %in% nx], fixed = TRUE)) &&
             identical(unname(verd[tests == "Absence de valeurs manquantes"]), "ECHEC") &&
             identical(unname(verd[tests == "Strict positivite de y_t (requise par la lognormale)"]), "OK") &&
             !any(grepl("NA", det[tests %in% nx], fixed = TRUE))
         })
verifier("Controles qualite : jeu de test inchange (details identiques, sans mention 'non etabli')",
         !any(grepl("non etabli", vapply(usp_controle_donnees(x, y), function(l) l$detail, ""),
                    fixed = TRUE)))

## --- Credibilite pleine et credibilite partielle (issue #131) ----------------
# Lecture R1 de regulatory (commentaire 5927125080 de #131) et decisions du
# mainteneur du 01/10/2026 : le controle "Credibilite pleine atteinte" et
# les avertissements de credibilite partielle lisent c(duree, bareme
# applique), bareme qui entre dans sigma_USP (metadata$bareme) ; la duree est
# le T de l'estimation (I + 1 en reserve no 2), jamais le nombre d'annees
# fournies. Les reperes statistiques (T < 10, I + 1 < 10) sont inchanges.
xc <- 100 * 1.03^(1:20); yc <- 0.7 * xc * (1 + 0.05 * sin(1:20))
# Un test plus haut affecte une variable c dans l'environnement du fichier ;
# lance seul par Rscript, cet environnement est l'environnement global, ou
# le moteur est charge, et do.call(c, vals) de .mc_evaluer() y trouvait cette
# variable au lieu de base::c (defaut de calcul intercepte, mesure).
if (exists("c", inherits = FALSE)) rm(c)
ligne_cred <- function(r) Filter(function(l) l$test == "Credibilite pleine atteinte", r)[[1]]
verifier("Credibilite pleine : verdict OK ssi usp_credibilite(T, bareme du segment) == 1, 16 segments, T = 5..20 (#131)",
         all(vapply(seq_len(nrow(SEGMENTS)), function(k) {
           s <- SEGMENTS$segment[k]; a <- SEGMENTS$annexe[k]
           b <- usp_bareme_segment(s, a)
           all(vapply(5:20, function(T) {
             l <- ligne_cred(usp_controle_donnees(xc[1:T], yc[1:T], segment = s, annexe = a))
             identical(l$verdict, if (usp_credibilite(T, b) == 1) "OK" else "ECHEC")
           }, logical(1)))
         }, logical(1))))
verifier("Credibilite pleine : grille de regulatory (II-1, II-5, II-6 : T = 10, 14 non, 15 oui ; II-2, XIV-1 : T = 9 non, 10 oui) (#131)",
         {
           v <- function(T, s, a = "II")
             ligne_cred(usp_controle_donnees(xc[1:T], yc[1:T], segment = s, annexe = a))$verdict
           all(vapply(c(1, 5, 6), function(s)
             v(10, s) == "ECHEC" && v(14, s) == "ECHEC" && v(15, s) == "OK", logical(1))) &&
             v(9, 2) == "ECHEC" && v(10, 2) == "OK" &&
             v(9, 1, "XIV") == "ECHEC" && v(10, 1, "XIV") == "OK"
         })
verifier("Credibilite pleine : detail du bareme applique (segment G(1) / G(2), convention sans segment, saisie #93) (#131)",
         {
           d <- function(...) ligne_cred(usp_controle_donnees(xc[1:10], yc[1:10], ...))$detail
           d1 <- d(segment = 1); d2 <- d(segment = 2); d0 <- d(); ds <- d(segment = 2, bareme = "long")
           grepl("c = 74% ; bareme long du segment II-1 (annexe XVII, G(1))", d1, fixed = TRUE) &&
             grepl("pleine a partir de T = 15", d1, fixed = TRUE) &&
             grepl("c = 100% ; bareme court du segment II-2 (annexe XVII, G(2))", d2, fixed = TRUE) &&
             grepl("court par convention, non determine par la section G", d0, fixed = TRUE) &&
             grepl(paste("bareme long saisi (valeurs de G(1)) : derogation au bareme de la section G",
                         "(#93) ; bareme reglementaire du segment II-2 : court (G(2)), c = 100%"),
                   ds, fixed = TRUE) &&
             grepl(paste("bareme long saisi (valeurs de G(1)) : saisie declaree comme derogation (#93),",
                         "egale au bareme reglementaire du segment II-1"),
                   d(segment = 1, bareme = "long"), fixed = TRUE) &&
             grepl(paste("bareme long saisi (valeurs de G(1)) : saisie declaree comme derogation,",
                         "bareme reglementaire non determine"), d(bareme = "long"), fixed = TRUE) &&
             identical(ligne_cred(usp_controle_donnees(xc[1:10], yc[1:10], segment = 2,
                                                      bareme = "long"))$verdict, "ECHEC") &&
             !any(grepl("bareme court) /", c(d1, d2, d0, ds), fixed = TRUE))
         })
verifier("Credibilite pleine : duree = T retenu, pas n fourni (run_engine, II-1, n = 16, T = 10 : non atteinte) (#131)",
         {
           r <- run_engine(xc[1:16], yc[1:16], methode = "premium", segment = 1, annexe = "II",
                           T = 10, B = 99, nature_donnees = "brutes")
           l <- ligne_cred(r$controles)
           r$metadata$T == 10 && r$metadata$n_fournies == 16 && identical(l$verdict, "ECHEC") &&
             grepl("T = 10 ; c = 74%", l$detail, fixed = TRUE) &&
             any(grepl("T = 10 : credibilite partielle, c = 74%", r$validation$avertissements, fixed = TRUE))
         })
verifier("engine_valider_donnees : credibilite partielle ssi c(T, bareme applique) < 1 ; repere T < 10 inchange (#131)",
         {
           a <- function(T, ...) engine_valider_donnees(xc[1:T], yc[1:T], ...)$avertissements
           cp <- function(v) any(grepl("credibilite partielle", v, fixed = TRUE))
           la <- function(v) any(grepl("lois asymptotiques peu fiables", v, fixed = TRUE))
           cp(a(10, segment = 1)) && cp(a(14, segment = 1)) && !cp(a(15, segment = 1)) &&
             !cp(a(10, segment = 2)) && cp(a(9, segment = 2)) && !cp(a(10, segment = 1, annexe = "XIV")) &&
             cp(a(10, segment = 2, bareme = "long")) && !cp(a(10)) && cp(a(8)) &&
             !la(a(10, segment = 1)) && la(a(9, segment = 2)) && la(a(8))
         })
verifier("engine_valider_donnees / mw_valider_triangle : bareme ou segment invalide refuse sans erreur R (#131)",
         {
           v1 <- engine_valider_donnees(x, y, bareme = "co")
           v2 <- engine_valider_donnees(x, y, segment = 7, annexe = "XIV")
           v3 <- mw_valider_triangle(t5, bareme = "lng")
           v4 <- engine_valider_donnees(x, y, bareme = c(a = "long"))
           v5 <- mw_valider_triangle(t5, bareme = structure("court", classe = "x"))
           !v1$ok && contient(v1$erreurs, "bareme = \"co\"") && !v2$ok &&
             contient(v2$erreurs, "Segment 7 inconnu dans l'annexe XIV") &&
             !v3$ok && contient(v3$erreurs, "bareme = \"lng\"") &&
             !v4$ok && contient(v4$erreurs, "(sans attribut)") &&
             !v5$ok && contient(v5$erreurs, "(sans attribut)")
         })
verifier("mw_valider_triangle : segment invalide ne masque pas une cellule manquante, les deux erreurs sont rapportees (#131)",
         {
           m <- triangle(6); m[1, 1] <- NA
           r <- mw_valider_triangle(m, segment = 99)
           !r$ok && length(r$erreurs) == 2L &&
             contient(r$erreurs, "Cellule observee manquante en (i=0, j=0).") &&
             contient(r$erreurs, "Segment 99 inconnu dans l'annexe II.") &&
             !length(r$avertissements)
         })
verifier("engine_valider_serie_retenue : serie tronquee a T comme run_engine() (n = 16, T = 10, II-1 : c = 74%) (#131)",
         {
           sr <- engine_valider_serie_retenue(xc[1:16], yc[1:16], T = 10, methode = "premium",
                                              nature_donnees = "brutes", segment = 1)
           r <- run_engine(xc[1:16], yc[1:16], methode = "premium", segment = 1, annexe = "II",
                           T = 10, B = 99, nature_donnees = "brutes")
           identical(sr$validation, r$validation) && identical(sr$xt, xc[7:16]) &&
             identical(sr$yt, yc[7:16]) &&
             contient(sr$validation$avertissements, "T = 10 : credibilite partielle, c = 74%")
         })
verifier("engine_valider_serie_retenue : T refuse = meme validation que run_engine() (serie non tronquee, avertissements retires) (#131, #87)",
         all(vapply(list(NA, 5.5, 20, 4), function(Tr) {
           sr <- engine_valider_serie_retenue(xc[1:16], yc[1:16], T = Tr, methode = "premium",
                                              nature_donnees = "brutes", segment = 1)
           r <- run_engine(xc[1:16], yc[1:16], methode = "premium", segment = 1, annexe = "II",
                           T = Tr, B = 99, nature_donnees = "brutes")
           identical(sr$validation, r$validation) && !sr$validation$ok &&
             length(sr$xt) == 16 && !length(sr$validation$avertissements)
         }, logical(1))))

## --- Validation des seules annees retenues (non-regression de #154) ---------
# Reproduction de l'issue #154 (resolue en code par #131, fcbef03 et
# 859ac7d) : n = 10 annees fournies, T = 8 retenues (les plus recentes) ; les
# deux annees ecartees portent des valeurs que engine_valider_donnees()
# refuserait ou signalerait sur la serie entiere. Le contrat fixe :
# engine_valider_serie_retenue() et run_engine() ne valident que les T
# annees retenues (lecture (A) de #104) ; la marge Delta et les
# avertissements portent sur ces seules annees.
x154 <- function(a) c(a, 100, x); y154 <- function(a) c(a, 50, y)
args154 <- list(T = 8, methode = "premium", nature_donnees = "brutes", segment = 1L)
sr154 <- function(xt, yt, ...)
  do.call(engine_valider_serie_retenue, c(list(xt, yt), args154, list(...)))
re154 <- function(xt, yt, ...)
  do.call(run_engine, c(list(xt, yt), args154, list(annexe = "II", B = 99), list(...)))
verifier("#154 : annee refusable hors des T retenues (x_1 = NA, n = 10, T = 8) : moteur ok, run_engine() ok, serie entiere refusee",
         {
           xn <- x154(NA); yn <- y154(1e6)
           v <- engine_valider_donnees(xn, yn)
           sr <- sr154(xn, yn); r <- re154(xn, yn)
           !v$ok && contient(v$erreurs, "Valeurs manquantes") &&
             sr$validation$ok && identical(sr$validation$T, 8L) &&
             identical(sr$xt, x) && identical(sr$yt, y) &&
             isTRUE(r$ok) && identical(r$validation, sr$validation) &&
             r$metadata$T == 8 && r$metadata$n_fournies == 10
         })
verifier("#154 : toute valeur refusable de l'annee ecartee (NA, NaN, 0, -1, Inf, sur xt ou yt) laisse la serie retenue valide",
         all(vapply(list(NA_real_, NaN, 0, -1, Inf), function(a) {
           v1 <- sr154(x154(a), y154(50))$validation
           v2 <- sr154(x154(100), y154(a))$validation
           v1$ok && v2$ok && !engine_valider_donnees(x154(a), y154(50))$ok &&
             !engine_valider_donnees(x154(100), y154(a))$ok
         }, logical(1))))
verifier("#154 : marge Delta comparee a la moyenne des T retenues (85.005), dans les deux sens, moteur et run_engine()",
         {
           # Annees ecartees elevees : moyenne des n = 100073.0 ; Delta = 90 >=
           # 85.005 est refusee, alors qu'elle passerait sur les n annees.
           xh <- x154(100); yh <- y154(1e6)
           sh <- sr154(xh, yh, delta_equiv = 90); rh <- re154(xh, yh, delta_equiv = 90)
           # Annees ecartees faibles : moyenne des n = 68.204 ; Delta = 70 <
           # 85.005 est acceptee, alors qu'elle serait refusee sur les n annees.
           xb <- c(1, 1, x); yb <- c(1, 1, y)
           sb <- sr154(xb, yb, delta_equiv = 70); rb <- re154(xb, yb, delta_equiv = 70)
           proche(mean(y), 85.005) &&
             engine_valider_donnees(xh, yh, delta_equiv = 90)$ok &&
             !sh$validation$ok && contient(sh$validation$erreurs,
                                                   paste0("perte moyenne (", format(mean(y), digits = 6), ")")) &&
             !isTRUE(rh$ok) && identical(rh$validation, sh$validation) &&
             !engine_valider_donnees(xb, yb, delta_equiv = 70)$ok &&
             sb$validation$ok && isTRUE(rb$ok) && identical(rb$validation, sb$validation)
         })
verifier("#154 : avertissements calcules sur les T retenues (ratio et amplitude des annees ecartees absents, T = 8 affiche)",
         {
           xw <- c(1, 100, x); yw <- c(1e4, 50, y)
           an <- engine_valider_donnees(xw, yw)$avertissements
           at <- sr154(xw, yw)$validation$avertissements
           contient(an, "Ratio y/x hors de la plage") && contient(an, "Amplitude des volumes") &&
             !contient(an, "T = 8") &&
             !contient(at, "Ratio y/x hors de la plage") && !contient(at, "Amplitude des volumes") &&
             contient(at, "T = 8 : credibilite partielle") && contient(at, "T = 8 : lois asymptotiques") &&
             !contient(at, "T = 10")
         })
verifier("mw_valider_triangle : credibilite partielle ssi c(I + 1, bareme applique) < 1 ; repere I + 1 < 10 inchange (#131)",
         {
           a <- function(n, ...) mw_valider_triangle(triangle(n), ...)$avertissements
           cp <- function(v) any(grepl("credibilite partielle", v, fixed = TRUE))
           vb <- function(v) any(grepl("estimateurs de variance tres bruites", v, fixed = TRUE))
           all(vapply(c(10, 12, 14), function(n) cp(a(n, segment = 1)), logical(1))) &&
             !cp(a(15, segment = 1)) && cp(a(8, segment = 1)) && vb(a(8, segment = 1)) &&
             !cp(a(10, segment = 2)) && !vb(a(10, segment = 2)) &&
             cp(a(10, segment = 2, bareme = "long")) &&
             any(grepl("I + 1 = 10 annees d'accident (duree, G(3)(c)) : credibilite partielle, c = 74%",
                       a(10, segment = 1), fixed = TRUE))
         })

## --- usp_lire_vecteur / usp_charger ------------------------------------------
fx <- tempfile(fileext = ".csv"); fy <- tempfile(fileext = ".csv")
writeLines(c("x", "100", "110", "120", "130", "140"), fx)
writeLines(c("70", "80", "85", "90", "99"), fy)
verifier("Lecture vecteur : avec ou sans en-tete ; T = n dernieres annees",
         {
           r <- usp_charger(fx, fy)
           r2 <- usp_charger(fx, fy, T = 3)
           identical(r$x, c(100, 110, 120, 130, 140)) && identical(r$y, c(70, 80, 85, 90, 99)) &&
             identical(r2$x, c(120, 130, 140)) && r2$T == 3
         })
verifier("Lecture vecteur : longueurs differentes et T trop grand refuses",
         {
           fz <- tempfile(fileext = ".csv"); writeLines(c("1", "2", "3"), fz)
           leve_erreur(usp_charger(fx, fz)) && leve_erreur(usp_charger(fx, fy, T = 6))
         })
# Issue #33 (defaut releve par audit, repris de l'issue #7), corrige : une
# cellule vide etait retiree en silence ; deux vides a des annees differentes
# donnaient deux series de meme longueur mais DECALEES.
verifier("Lecture vecteur : cellule vide refusee (pas de decalage silencieux des annees) (#33)",
         {
           fx2 <- tempfile(fileext = ".csv"); fy2 <- tempfile(fileext = ".csv")
           writeLines(c("x", "100", "", "120", "130", "140", "150"), fx2)
           writeLines(c("y", "70", "80", "", "90", "95", "99"), fy2)
           e <- tryCatch(usp_charger(fx2, fy2), error = function(e) conditionMessage(e))
           is.character(e) && grepl("Cellule(s) vide(s) en position 2", e, fixed = TRUE)
         })
verifier("Lecture vecteur : valeur non numerique au milieu refusee ; separateur final et lignes vides finales toleres",
         {
           f1 <- tempfile(); writeLines(c("100", "110", "abc", "130"), f1)
           f2 <- tempfile(); writeLines(c("100,110,120,130,140,", "", ""), f2)
           f3 <- tempfile(); writeLines(c("x,100,110,,130,140"), f3)
           leve_erreur(usp_lire_vecteur(f1)) && leve_erreur(usp_lire_vecteur(f3)) &&
             identical(usp_lire_vecteur(f2), c(100, 110, 120, 130, 140))
         })
# Audit de #33 (C1) : l'ancien lecteur sautait les lignes vides ; celles de
# tete (avant l'en-tete ou entre l'en-tete et la premiere valeur) restent
# sans effet. Seule une cellule vide au milieu de la serie est refusee.
verifier("Lecture vecteur : lignes vides de tete ou apres l'en-tete ignorees, vide au milieu refuse avec sa position (#33)",
         {
           lit <- function(l) { f <- tempfile(); writeLines(l, f, useBytes = TRUE); usp_lire_vecteur(f) }
           msg <- function(l) tryCatch(lit(l), error = function(e) conditionMessage(e))
           identical(lit(c("", "100", "110")), c(100, 110)) &&
             identical(lit(c("x", "", "100", "110")), c(100, 110)) &&
             identical(lit(c("", "", "x", "", "100", "110", "")), c(100, 110)) &&
             identical(lit(c("", "100,110,120")), c(100, 110, 120)) &&
             identical(lit(c(",100,110")), c(100, 110)) &&
             grepl("Cellule(s) vide(s) en position 2", msg(c("", "x", "100", "", "110")), fixed = TRUE)
         })
verifier("Lecture vecteur : tableau a plusieurs lignes et colonnes refuse (format non reconnu)",
         {
           f <- tempfile(); writeLines(c("a,b", "1,2", "3,4"), f)
           leve_erreur(usp_lire_vecteur(f))
         })
# Revue finale de la branche (#33) : le format en ligne avec en-tete (ligne 1
# = en-tetes non numeriques, ligne 2 = la serie), lu par l'ancien lecteur,
# etait refuse comme tableau. Retabli par decision du mainteneur du
# 25/09/2026 ; tout autre tableau reste refuse, sans aplatissement.
verifier("Lecture vecteur : serie en ligne avec ligne d'en-tetes acceptee (sep ',' et ';', dec ',') (#33)",
         {
           lit <- function(l, sep = ",", dec = ".") {
             f <- tempfile(); writeLines(l, f, useBytes = TRUE); usp_lire_vecteur(f, sep, dec)
           }
           identical(lit(c("a2017,a2018,a2019,a2020", "104.2,102.25,109.34,114.64")),
                     c(104.2, 102.25, 109.34, 114.64)) &&
             identical(lit(c("a2017;a2018;a2019;a2020", "104,2;102,25;109,34;114,64"), ";", ","),
                       c(104.2, 102.25, 109.34, 114.64)) &&
             identical(lit("104.2,102.25,109.34,114.64"), c(104.2, 102.25, 109.34, 114.64))
         })
verifier("Lecture vecteur : 2 lignes numeriques ou 3 lignes x n refusees (tableau, pas d'aplatissement) (#33)",
         {
           msg <- function(l) {
             f <- tempfile(); writeLines(l, f, useBytes = TRUE)
             tryCatch(usp_lire_vecteur(f), error = function(e) conditionMessage(e))
           }
           grepl("Format non reconnu", msg(c("1,2,3", "4,5,6")), fixed = TRUE) &&
             grepl("Format non reconnu", msg(c("a,b,c", "1,2,3", "4,5,6")), fixed = TRUE) &&
             grepl("Format non reconnu", msg(c("a,2018,c", "1,2,3")), fixed = TRUE)
         })
verifier("Lecture vecteur : cellule vide au milieu d'une serie en ligne avec en-tetes refusee avec sa position (#33)",
         {
           f <- tempfile(); writeLines(c("a2017;a2018;a2019;a2020", "104,2;;109,34;114,64"), f)
           e <- tryCatch(usp_lire_vecteur(f, ";", ","), error = function(e) conditionMessage(e))
           is.character(e) && grepl("Cellule(s) vide(s) en position 2", e, fixed = TRUE)
         })
# Issue #95 : serie en ligne avec ligne d'en-tetes ; une valeur manquante de
# bord (cellule vide ecartee) ou en surnombre passait sans message. Decision
# du mainteneur : alignement colonne par colonne (en-tete non vide et valeur,
# ou rien) ; etiquette de ligne admise, sauf "NA", "-" ou nombre ecrit avec
# l'autre separateur decimal.
# useBytes = TRUE : les chaines non ASCII ("\u2013"...) sont ecrites en
# octets UTF-8 quelle que soit la locale (sous LC_ALL = C, writeLines() sans
# useBytes les ecrivait "<U+2013>" ; audit de la reprise de #102).
msg_ligne <- function(l, sep = ",", dec = ".") {
  f <- tempfile(); writeLines(l, f, useBytes = TRUE)
  tryCatch(usp_lire_vecteur(f, sep, dec), error = function(e) conditionMessage(e))
}
# is.character(txt) : une serie lue (numerique) au lieu d'un refus fait
# echouer le test proprement (audit de #102).
a_motif <- function(txt, ...)
  is.character(txt) && all(vapply(c(...), function(p) grepl(p, txt, fixed = TRUE), TRUE))
verifier("Lecture vecteur : serie en ligne, valeur manquante de bord ou en surnombre refusee, colonnes fautives et decomptes donnes (#95)",
         a_motif(msg_ligne(c("a,b,c,d", "1,2,3,")),
                 "colonne 4 : en-tete \"d\" sans valeur", "3 valeur(s) pour 4 en-tete(s) non vide(s)") &&
           a_motif(msg_ligne(c("a,b,c,d", ",2,3,4")),
                   "colonne 1 : en-tete \"a\" sans valeur", "3 valeur(s) pour 4 en-tete(s) non vide(s)") &&
           a_motif(msg_ligne(c("a,b", "1,2,3")),
                   "colonne 3 : valeur \"3\" sans en-tete", "3 valeur(s) pour 2 en-tete(s) non vide(s)"))
verifier("Lecture vecteur : serie en ligne, en-tetes et valeurs decales ou en-tete vide intercale refuses colonne par colonne (#95)",
         a_motif(msg_ligne(c("a,b,c,", ",2,3,4")),
                 "colonne 1 : en-tete \"a\" sans valeur ; colonne 4 : valeur \"4\" sans en-tete") &&
           a_motif(msg_ligne(c("a,b,,d", "1,2,3,4")), "colonne 3 : valeur \"3\" sans en-tete") &&
           a_motif(msg_ligne(c("a,,c", "1,2,3")), "colonne 2 : valeur \"2\" sans en-tete") &&
           a_motif(msg_ligne(c("serie,a2017,a2018", ",1,2")),
                   "colonne 1 : en-tete \"serie\" sans valeur", "retirer son en-tete"))
# Depuis #102 (regle stricte), ces trois cellules, sous un en-tete non vide,
# sont refusees par le message de la regle stricte, qui cite la cellule, sa
# colonne et, pour une cellule a l'allure d'un nombre, le separateur decimal
# attendu ; le predicat en position d'etiquette (sous une cellule d'angle
# vide) est exerce au test suivant.
verifier("Lecture vecteur : serie en ligne, etiquette \"NA\", \"-\" ou nombre a l'autre separateur decimal refusee (#95)",
         a_motif(msg_ligne(c("a,b,c", "NA,2,3")), "cellule \"NA\" (colonne 1)", "etiquette") &&
           a_motif(msg_ligne(c("a,b,c", "-,2,3")), "cellule \"-\" (colonne 1)", "etiquette") &&
           a_motif(msg_ligne(c("a2017;a2018;a2019", "1,5;2;3"), ";", "."),
                   "cellule \"1,5\" (colonne 1)", "separateur decimal"))
# Avis d'actuary : predicat unique .allure_manquante_ou_nombre(), applique a
# l'etiquette du format avec en-tetes et a l'en-tete des autres formats.
# Adapte a #102 (regle stricte) : l'etiquette n'est admise que sous une
# cellule d'angle vide ; la ligne d'en-tetes commence donc par une cellule
# vide pour que le predicat soit exerce en position d'etiquette.
verifier("Lecture vecteur : etiquette NaN, #N/A, N/A, n.d., 1 234, 1.234,5 (dec ',') ou 1,234.5 (dec '.') refusee (#95)",
         a_motif(msg_ligne(c(",b,c", "NaN,2,3")), "cellule \"NaN\" (colonne 1), en position d'etiquette") &&
           a_motif(msg_ligne(c(",b,c", "#N/A,2,3")), "cellule \"#N/A\"", "valeur manquante") &&
           a_motif(msg_ligne(c(",b,c", "N/A,2,3")), "cellule \"N/A\"", "etiquette") &&
           a_motif(msg_ligne(c(",b,c", "n.d.,2,3")), "cellule \"n.d.\"", "etiquette") &&
           a_motif(msg_ligne(c(",b,c", "1 234,2,3")), "cellule \"1 234\"", "etiquette") &&
           a_motif(msg_ligne(c(";b;c", "1.234,5;2;3"), ";", ","), "cellule \"1.234,5\"", "etiquette") &&
           a_motif(msg_ligne(c(";b;c", "1,234.5;2;3"), ";", "."), "cellule \"1,234.5\"", "etiquette"))
verifier("Lecture vecteur : en-tete NA, - ou NaN refuse en format ligne sans en-tetes et en format colonne (#95)",
         {
           en_tete <- "en position d'en-tete (premiere cellule non vide)"
           all(vapply(c("NA", "-", "NaN"), function(z)
             a_motif(msg_ligne(paste0(z, ",2,3")), paste0("cellule \"", z, "\" ", en_tete)) &&
               a_motif(msg_ligne(c(z, "2", "3")), paste0("cellule \"", z, "\" ", en_tete)), TRUE))
         })
# Adapte a #102 (decision du mainteneur du 28/09/2026) : "12a" (commence par
# un chiffre), "--" et "." (faits de tirets et de points) passent de la liste
# des cellules admises a celle des cellules refusees.
verifier("Predicat .allure_manquante_ou_nombre() : manquants et nombres refuses, TRUE et en-tetes ordinaires admis (#95, #102)",
         {
           # Espace insecable en UTF-8 (C2 A0) et en Windows-1252 (A0) ; deux
           # appels successifs (un litteral dans gsub() donnait un resultat
           # instable sous une locale Windows-1252).
           nbsp <- paste0("1", intToUtf8(160), "234")
           nbsp1252 <- rawToChar(as.raw(c(0x31, 0xa0, 0x32, 0x33, 0x34)))
           oui <- c("NA", "nan", "N/A", "#n/a", "N.D.", "-", "1,5", "1 234", nbsp, nbsp1252,
                    "1.234,5", "1,234.5", "'1'234", "+3", "12a", "--", ".")
           identical(.allure_manquante_ou_nombre(oui), rep(TRUE, 17)) &&
             identical(.allure_manquante_ou_nombre(oui), rep(TRUE, 17)) &&
             identical(.allure_manquante_ou_nombre(
               c("TRUE", "x", "a2017", "serie", "annee", "", "NA2", NA)), rep(FALSE, 8))
         })
verifier("Lecture vecteur : cellule d'espaces sous un en-tete refusee a l'alignement (colonne 1 : en-tete \"a\" sans valeur) (#95)",
         a_motif(msg_ligne(c("a,b,c", "\"   \",2,3")), "colonne 1 : en-tete \"a\" sans valeur"))
# Adapte a #102 : l'etiquette x est lue sous une cellule d'angle vide (sous
# "serie", elle est refusee : regle stricte) et l'en-tete "12a" est refuse
# (commence par un chiffre).
verifier("Lecture vecteur : formats sains inchanges (en-tete x en colonne, etiquette x, en-tetes a2017...) (#95, #102)",
         {
           lit <- function(l, sep = ",", dec = ".") { f <- tempfile(); writeLines(l, f, useBytes = TRUE); usp_lire_vecteur(f, sep, dec) }
           identical(lit(c("x", "1", "2", "3")), c(1, 2, 3)) &&
             identical(lit("x,1,2,3"), c(1, 2, 3)) &&
             identical(lit(c(",a2017,a2018", "x,1,2")), c(1, 2)) &&
             a_motif(msg_ligne(c("12a", "1", "2")), "cellule \"12a\" en position d'en-tete") &&
             identical(lit(c("a2017;a2018;a2019", "1,5;2;3"), ";", ","), c(1.5, 2, 3))
         })
# Audit (mineur 2) et avis d'actuary : espace fine insecable U+202F (octets
# E2 80 AF) traitee comme une espace ; exception des etiquettes d'exercice
# AAAA-AA / AAAA-AAAA ; valeurs non finies refusees des la lecture.
verifier("Predicat .allure_manquante_ou_nombre() : U+202F reconnue, 12.2017, +1 et '2017 refuses, 2017-2018 et 2017-18 admis (#95)",
         {
           fine <- rawToChar(as.raw(c(0x31, 0xe2, 0x80, 0xaf, 0x32, 0x33, 0x34)))
           identical(.allure_manquante_ou_nombre(c(fine, "12.2017", "+1", "'2017")), rep(TRUE, 4)) &&
             identical(.allure_manquante_ou_nombre(c("2017-2018", "2017-18")), c(FALSE, FALSE))
         })
# Adapte a #102 (regle stricte) : etiquettes lues sous une cellule d'angle vide.
verifier("Lecture vecteur : en-tete ou etiquette 1<U+202F>234 et '2017 refuses ; 2017-2018 et 2017-18 admis en en-tete et en etiquette (#95)",
         {
           lit_brut <- function(r, sep = ",") {
             f <- tempfile(); writeBin(r, f)
             tryCatch(usp_lire_vecteur(f, sep), error = function(e) conditionMessage(e))
           }
           fine <- as.raw(c(0x31, 0xe2, 0x80, 0xaf, 0x32, 0x33, 0x34))
           a_motif(lit_brut(c(fine, charToRaw("\n1\n2\n"))), "en position d'en-tete") &&
             a_motif(lit_brut(c(charToRaw(",b,c\n"), fine, charToRaw(",2,3\n"))),
                     "(colonne 1), en position d'etiquette") &&
             a_motif(msg_ligne(c("'2017", "1", "2")), "cellule \"'2017\" en position d'en-tete") &&
             identical(msg_ligne(c("2017-2018", "1", "2")), c(1, 2)) &&
             identical(msg_ligne(c("2017-18", "1", "2")), c(1, 2)) &&
             identical(msg_ligne(c(",b,c", "2017-2018,1,2")), c(1, 2)) &&
             identical(msg_ligne(c(",b,c", "2017-18,1,2")), c(1, 2)) &&
             # Variante au tiret demi-cadratin U+2013, admise (reprise de #102, C2)
             identical(msg_ligne(c("2017\u201318", "1", "2")), c(1, 2)) &&
             identical(msg_ligne(c(",b,c", "2017\u201318,1,2")), c(1, 2)) &&
             identical(.allure_manquante_ou_nombre(c("2017\u201318", "2017\u20132018")), c(FALSE, FALSE))
         })
verifier("Lecture vecteur : Inf, -Inf en tete ou au milieu de la serie refuses a la lecture avec leur position",
         a_motif(msg_ligne("Inf,2,3"), "non numerique(s) en position 1", "\"Inf\"") &&
           a_motif(msg_ligne(c("Inf", "2", "3")), "non numerique(s) en position 1", "\"Inf\"") &&
           a_motif(msg_ligne(c("x", "1", "-Inf", "3")), "non numerique(s) en position 2", "\"-Inf\"") &&
           a_motif(msg_ligne("1,2,Inf"), "non numerique(s) en position 3", "\"Inf\""))
verifier("Lecture vecteur : serie en ligne, vide au milieu de la ligne de valeurs : message #33 inchange (#95)",
         a_motif(msg_ligne(c("a,b,c", "1,,3")), "Cellule(s) vide(s) en position 2"))
# Adapte a #102 (regle stricte) : l'etiquette "x" sous l'en-tete "serie",
# admise depuis le 26/09, est refusee ; sous une cellule d'angle vide, elle
# reste admise.
verifier("Lecture vecteur : serie en ligne, colonnes alignees acceptees (colonne vide de bord, etiquette de ligne sous angle vide) (#95, #102)",
         {
           lit <- function(l) { f <- tempfile(); writeLines(l, f, useBytes = TRUE); usp_lire_vecteur(f) }
           identical(lit(c(",b,c,d", ",2,3,4")), c(2, 3, 4)) &&
             identical(lit(c("a,b,c,d,", "1,2,3,4,")), c(1, 2, 3, 4)) &&
             a_motif(msg_ligne(c("serie,a2017,a2018", "x,1,2")), "cellule \"x\" (colonne 1)",
                     "l'en-tete \"serie\" au-dessus d'elle n'est pas vide") &&
             identical(lit(c(",a2017,a2018", "x,1,2")), c(1, 2)) &&
             identical(lit(c("a,b,c", "1,2,3", "")), c(1, 2, 3))
         })
# Issue #96 : BOM UTF-8 (EF BB BF) en tete du fichier. Fichiers ecrits en
# binaire ; lecture dans la locale courante, puis, si le systeme l'accepte,
# sous LC_CTYPE = "C" (non UTF-8, ou le defaut se manifestait), la locale
# de l'appelant etant restauree en sortie.
bom_csv <- function(txt) {
  f <- tempfile(fileext = ".csv")
  writeBin(c(as.raw(c(0xef, 0xbb, 0xbf)), charToRaw(txt)), f)
  f
}
lit_bom <- function() list(
  usp_lire_vecteur(bom_csv("1,2,3\n")),
  usp_lire_vecteur(bom_csv("1\n2\n3\n")),
  usp_lire_vecteur(bom_csv("x\n1\n2\n3\n")),
  usp_lire_vecteur(bom_csv("a2017;a2018;a2019\n1,5;2;3\n"), ";", ","))
attendu_bom <- list(c(1, 2, 3), c(1, 2, 3), c(1, 2, 3), c(1.5, 2, 3))
verifier("Lecture vecteur : CSV avec BOM ecrit en binaire lu sans perte dans la locale courante (#96)",
         identical(lit_bom(), attendu_bom))
# Evalue f() sous LC_CTYPE = "C" et restaure la locale de l'appelant ; rend
# "locale C indisponible" (avec un message visible) si le systeme refuse la
# locale ou si elle reste UTF-8, l'assertion etant alors neutre.
sous_locale_c <- function(f) {
  avant <- Sys.getlocale("LC_CTYPE")
  r <- tryCatch({
    pose <- suppressWarnings(Sys.setlocale("LC_CTYPE", "C"))
    if (!nzchar(pose) || isTRUE(l10n_info()[["UTF-8"]])) "locale C indisponible" else f()
  }, finally = suppressWarnings(Sys.setlocale("LC_CTYPE", avant)))
  if (!identical(Sys.getlocale("LC_CTYPE"), avant)) stop("locale LC_CTYPE non restauree")
  if (identical(r, "locale C indisponible"))
    message("  (information) LC_CTYPE = C indisponible ou UTF-8 : assertion BOM non exercee")
  r
}
verifier("Lecture vecteur : CSV avec BOM lu sans perte sous LC_CTYPE = C (non UTF-8), locale restauree (#96)",
         {
           r <- sous_locale_c(lit_bom)
           identical(r, "locale C indisponible") || identical(r, attendu_bom)
         })
# Lecteurs de l'application (read.csv avec en-tete, puis engine_lire_*) : hors
# locale UTF-8, le BOM altere le premier nom de colonne ("X...t" sous C).
verifier("Lecture t, xt, yt : CSV avec BOM lu par read.csv sous LC_CTYPE = C, colonne t reconnue et controlee (#96)",
         {
           r <- sous_locale_c(function() {
             ok <- engine_lire_donnees_csv(utils::read.csv(
               bom_csv("t,xt,yt\n2,11,21\n1,10,20\n3,12,22\n"), stringsAsFactors = FALSE))
             trou <- engine_lire_donnees_csv(utils::read.csv(
               bom_csv("t,xt,yt\n1,10,20\n3,12,22\n"), stringsAsFactors = FALSE))
             list(isTRUE(ok$ok) && identical(ok$xt, c(10, 11, 12)) && identical(ok$yt, c(20, 21, 22)),
                  !trou$ok && contient(trou$erreurs, "non consecutives"))
           })
           identical(r, "locale C indisponible") || identical(r, list(TRUE, TRUE))
         })
verifier("Lecture triangle : CSV 5 x 5 avec colonne i et BOM lu par read.csv sous LC_CTYPE = C, ok = TRUE (#96)",
         {
           tri <- paste0("i,d1,d2,d3,d4,d5\n1,100,150,170,180,185\n2,110,160,180,190,\n",
                         "3,120,175,195,,\n4,130,185,,,\n5,140,,,,\n")
           r <- sous_locale_c(function() {
             v <- engine_lire_triangle(utils::read.csv(bom_csv(tri), stringsAsFactors = FALSE,
                                                       row.names = NULL))
             isTRUE(v$ok) && identical(dim(v$triangle), c(5L, 5L)) && identical(v$triangle[1, 1], 100)
           })
           identical(r, "locale C indisponible") || isTRUE(r)
         })
verifier("Retrait du BOM d'un nom de colonne : formes brute, \"X...\", \"X.U.FEFF.\" et EF 2E 2E ; autres noms intacts (#96)",
         {
           b <- function(...) rawToChar(as.raw(c(...)))
           identical(.nom_sans_bom(b(0xef, 0xbb, 0xbf, 0x74)), "t") &&
             identical(.nom_sans_bom("X...t"), "t") && identical(.nom_sans_bom("X.U.FEFF.i"), "i") &&
             identical(.nom_sans_bom(b(0xef, 0x2e, 0x2e, 0x78, 0x74)), "xt") &&
             identical(.nom_sans_bom("t"), "t") && identical(.nom_sans_bom("X..."), "X...") &&
             identical(.nom_sans_bom("X.1"), "X.1") && identical(.nom_sans_bom(NA_character_), NA_character_)
         })
verifier("Retrait du BOM : .sans_bom() retire EF BB BF de tete seulement, laisse le reste intact (#96)",
         {
           s <- rawToChar(as.raw(c(0xef, 0xbb, 0xbf, 0x31, 0x32)))
           identical(.sans_bom(s), "12") && identical(.sans_bom("12"), "12") &&
             identical(.sans_bom(""), "") && identical(.sans_bom(NA_character_), NA_character_) &&
             identical(.sans_bom(rawToChar(as.raw(c(0x31, 0xef, 0xbb, 0xbf)))),
                       rawToChar(as.raw(c(0x31, 0xef, 0xbb, 0xbf))))
         })

# Issue #99 : CSV encode en Windows-1252 (octets non UTF-8) lu sous une locale
# UTF-8. trimws() puis as.numeric() levaient une erreur R brute ("input string
# 1 is invalid UTF-8") avant tout controle. Fichiers ecrits en binaire, lus
# dans la locale courante, sous LC_CTYPE = C et sous une locale UTF-8
# (C.UTF-8, sinon en_US.UTF-8), la locale de l'appelant etant restauree.
sous_locale_utf8 <- function(f) {
  avant <- Sys.getlocale("LC_CTYPE")
  r <- tryCatch({
    pose <- ""
    for (loc in c("C.UTF-8", "C.utf8", "en_US.UTF-8", "fr_FR.UTF-8")) {
      pose <- suppressWarnings(Sys.setlocale("LC_CTYPE", loc))
      if (nzchar(pose) && isTRUE(l10n_info()[["UTF-8"]])) break
    }
    if (!nzchar(pose) || !isTRUE(l10n_info()[["UTF-8"]])) "locale UTF-8 indisponible" else f()
  }, finally = suppressWarnings(Sys.setlocale("LC_CTYPE", avant)))
  if (!identical(Sys.getlocale("LC_CTYPE"), avant)) stop("locale LC_CTYPE non restauree")
  if (identical(r, "locale UTF-8 indisponible"))
    message("  (information) aucune locale UTF-8 disponible : assertion #99 non exercee")
  r
}
csv_brut <- function(...) {
  f <- tempfile(fileext = ".csv")
  writeBin(unlist(lapply(list(...), function(z) if (is.raw(z)) z else charToRaw(z))), f)
  f
}
# Quatre fichiers Windows-1252 : en-tete "ann<E9>e" en colonne (lu 1, 2) ;
# "1<A0>2,2,3" (espace insecable A0 : en-tete a l'allure d'un nombre,
# refuse par le predicat, qui voit donc l'octet A0 isole) ; meme cellule en
# etiquette sous une ligne d'en-tetes ; cellule "<E9>" au milieu d'une serie
# en colonne (valeur non numerique, position 2). L'etiquette est placee sous
# une cellule d'angle vide (regle stricte de #102). Renvoie, pour chaque fichier,
# la serie lue ou le message d'erreur, et la validite UTF-8 des messages en
# locale UTF-8.
lit_1252 <- function() {
  lit <- function(f) tryCatch(usp_lire_vecteur(f), error = function(e) conditionMessage(e))
  r <- list(
    entete = lit(csv_brut("ann", as.raw(0xe9), "e\n1\n2\n")),
    nbsp   = lit(csv_brut("1", as.raw(0xa0), "2,2,3\n")),
    etiq   = lit(csv_brut(",b,c\n1", as.raw(0xa0), "2,2,3\n")),
    milieu = lit(csv_brut("x\n1\n", as.raw(0xe9), "\n3\n")))
  ok <- identical(r$entete, c(1, 2)) &&
    a_motif(r$nbsp, "en position d'en-tete (premiere cellule non vide)", "l'allure d'une valeur manquante") &&
    a_motif(r$etiq, "(colonne 1), en position d'etiquette de ligne") &&
    a_motif(r$milieu, "Valeur(s) non numerique(s) en position 2")
  if (isTRUE(l10n_info()[["UTF-8"]]))
    ok <- ok && all(validUTF8(unlist(r[c("nbsp", "etiq", "milieu")])))
  ok
}
verifier("Lecture vecteur : CSV Windows-1252 (ann<E9>e, 1<A0>2, <E9>) ecrit en binaire lu ou refuse avec motif dans la locale courante (#99)",
         isTRUE(lit_1252()))
verifier("Lecture vecteur : CSV Windows-1252 lu ou refuse avec motif sous LC_CTYPE = C, locale restauree (#99)",
         {
           r <- sous_locale_c(lit_1252)
           identical(r, "locale C indisponible") || isTRUE(r)
         })
verifier("Lecture vecteur : CSV Windows-1252 lu ou refuse avec motif sous une locale UTF-8, sans erreur R, messages UTF-8 valides ; octet A0 isole reconnu par le predicat (#99)",
         {
           r <- sous_locale_utf8(lit_1252)
           identical(r, "locale UTF-8 indisponible") || isTRUE(r)
         })
verifier("Lecture vecteur : formats sains inchanges sous une locale UTF-8 (colonne, ligne, en-tetes a2017, dec ',', BOM) (#99)",
         {
           r <- sous_locale_utf8(function() {
             lit <- function(l, sep = ",", dec = ".") { f <- tempfile(); writeLines(l, f, useBytes = TRUE); usp_lire_vecteur(f, sep, dec) }
             identical(lit(c("x", " 1 ", "2", "3")), c(1, 2, 3)) &&
               identical(lit("x,1,2,3"), c(1, 2, 3)) &&
               # Etiquette x sous une cellule d'angle vide (regle stricte, #102).
               identical(lit(c(",a2017,a2018", "x,1,2")), c(1, 2)) &&
               identical(lit(c("a2017;a2018;a2019", "1,5;2;3"), ";", ","), c(1.5, 2, 3)) &&
               identical(lit_bom(), attendu_bom)
           })
           identical(r, "locale UTF-8 indisponible") || isTRUE(r)
         })
# Lecteurs de l'application : une cellule non UTF-8 d'un data.frame (lu par
# read.csv quand la conversion de type l'admet, ex. "x<E9>" ; construit ici
# directement) est une cellule non numerique, refusee avec motif, sans
# erreur R.
verifier("Lecture t, xt, yt et triangle : cellule non UTF-8 sous une locale UTF-8 -> refus motive, sans erreur R (#99)",
         {
           r <- sous_locale_utf8(function() {
             e9 <- rawToChar(as.raw(c(0x78, 0xe9)))
             a0 <- rawToChar(as.raw(c(0x31, 0xa0, 0x32)))
             d <- tryCatch(engine_lire_donnees_csv(data.frame(t = 1:2, xt = c(a0, "2"), yt = c("3", e9),
                                                              stringsAsFactors = FALSE)),
                           error = function(e) conditionMessage(e))
             tri <- tryCatch(engine_lire_triangle(data.frame(i = 1:2, d1 = c(e9, "4"), d2 = c("3", ""),
                                                             stringsAsFactors = FALSE)),
                             error = function(e) conditionMessage(e))
             is.list(d) && !d$ok && contient(d$erreurs, "ne sont pas numeriques") &&
               is.list(tri) && !tri$ok && contient(tri$erreurs, "Cellule(s) non numerique(s) en (i=0, j=0)")
           })
           identical(r, "locale UTF-8 indisponible") || isTRUE(r)
         })
verifier(".nettoyer_cellules() : identique a trimws() sur des cellules valides (blancs ASCII, U+00A0 conserve, NA, matrice) ; octets et dim conserves sur une cellule non UTF-8 (#99)",
         {
           x <- c(" a ", "\t\r\nb\n", "", NA, paste0(" ", intToUtf8(233), " "),
                  paste0(intToUtf8(160), "1", intToUtf8(160)), "1 2")
           m <- matrix(c(" 1", "2 ", " x ", ""), 2)
           brut <- rawToChar(as.raw(c(0x20, 0x31, 0xa0, 0x32, 0x20)))
           valides <- function() identical(.nettoyer_cellules(x), trimws(x)) &&
             identical(.nettoyer_cellules(m), trimws(m)) &&
             identical(charToRaw(.nettoyer_cellules(brut)), as.raw(c(0x31, 0xa0, 0x32)))
           r <- sous_locale_utf8(valides)
           valides() && (identical(r, "locale UTF-8 indisponible") || isTRUE(r))
         })
# Audit leger de #99 (constat C1) : Encoding<- refusait une entree de
# longueur nulle.
verifier(".nettoyer_cellules() et .en_numerique() : entree vide (character(0), matrice 0 x 3) sans erreur, identique a trimws() / numeric(0) (#99)",
         {
           vides <- function() {
             m0 <- matrix(character(0), 0, 3)
             identical(.nettoyer_cellules(character(0)), trimws(character(0))) &&
               identical(.nettoyer_cellules(m0), trimws(m0)) &&
               identical(.en_numerique(character(0)), numeric(0))
           }
           r <- sous_locale_utf8(vides)
           vides() && (identical(r, "locale UTF-8 indisponible") || isTRUE(r))
         })


# Issues #102 et #103 : regle commune d'actuary du 28/09/2026 (commentaire
# 5864139292 de #102) et decisions du mainteneur du meme jour (regle stricte
# pour l'etiquette ; refus de "12a" et de "." ; sens des annees fixe par
# plus_recent_en_dernier d'usp_charger()). Mesure sur le code anterieur
# (tete cf3bba8) : "#DIV/0!", "n/d", "N.D", "--", ".", "12a", "1O4.2",
# "104.2 EUR" en premiere cellule d'une colonne etaient ecartes comme en-tete
# (serie lue sans sa premiere valeur) ; "2017,2018,2019" / "1,2,3" etait
# refuse comme "Format non reconnu" sans cause.
marqueurs_102 <- c("NA", "NAN", "N/A", "N.A.", "N.A", "N.D.", "N.D", "ND", "N/D", "NR", "N.R.", "NULL",
                   "NONE", "S.O.", "S.O", "S/O", "NIL", "N.C.", "N.C", "NC", "N/C",
                   "n/d", "null", "s.o.", "n.c.", "nc",
                   "#N/A", "#DIV/0!", "#VALEUR!", "#VALUE!", "#REF!", "#NOM?", "#NAME?", "#NUM!",
                   "#NULL!", "#####", "#",
                   "-", "--", "---", ".", "?", "\u2013", "\u2014", "\u2026", "\u2212")
chiffre_102 <- c("1O4.2", "104.2 EUR", "2017 primes", "12a", "'104", "+104x", "-1O4")
# Signe ecrit avec U+2013 ou le signe moins U+2212 (reprise de #102, C3).
signe_unic_102 <- c("\u2013104.2", "\u2212104.2")
verifier("Predicat .allure_manquante_ou_nombre() : marqueurs (a1)-(a3) et cellules commencant par un chiffre refuses ; en-tetes ordinaires admis ; deux appels identiques (#102)",
         {
           oui <- c(marqueurs_102, chiffre_102, signe_unic_102, "104,2 \u20ac", "---.", "?-")
           non <- c("x", "xt", "a2017", "S1", "LoB12", "2017-18", "2017-2018", "TRUE", "serie",
                    "NA2", "a-", "N.D.x", "x#", "", NA)
           # Tirets et points de suspension en Windows-1252 (octets 96, 97, 85) ;
           # "\u00d6" (C3 96) ne doit pas etre pris pour un tiret.
           w1252 <- vapply(list(0x96, 0x97, 0x85, c(0x2d, 0x96)),
                           function(o) rawToChar(as.raw(o)), "")
           r1 <- .allure_manquante_ou_nombre(c(oui, w1252))
           identical(r1, rep(TRUE, length(oui) + 4)) &&
             identical(.allure_manquante_ou_nombre(c(oui, w1252)), r1) &&
             identical(.allure_manquante_ou_nombre(non), rep(FALSE, length(non))) &&
             identical(.allure_manquante_ou_nombre(c("\u00d6", "a\u2013")), c(FALSE, FALSE))
         })
verifier("Lecture vecteur : marqueur de valeur manquante ou cellule commencant par un chiffre en premiere cellule refuse en en-tete, formats colonne et ligne (#102)",
         {
           en_tete <- "en position d'en-tete (premiere cellule non vide)"
           ascii <- c(marqueurs_102[!grepl("[^ -~]", marqueurs_102)], chiffre_102)
           unic <- c(marqueurs_102[grepl("[^ -~]", marqueurs_102)], signe_unic_102)
           # Cellules ASCII : message citant la cellule ; cellules non ASCII
           # (tirets, points de suspension, dont les octets dependent de la
           # locale d'ecriture) : motif de position seulement.
           all(vapply(ascii, function(z)
             a_motif(msg_ligne(c(z, "102.25", "109.34")), paste0("cellule \"", z, "\" ", en_tete)) &&
               a_motif(msg_ligne(paste0(z, ",102.25,109.34")), paste0("cellule \"", z, "\" ", en_tete)),
             TRUE)) &&
             all(vapply(unic, function(z)
               a_motif(msg_ligne(c(z, "102.25", "109.34")), en_tete) &&
                 a_motif(msg_ligne(paste0(z, ",102.25,109.34")), en_tete), TRUE))
         })
verifier("Lecture vecteur : regle stricte, etiquette refusee sous un en-tete non vide (cellule, colonne, en-tete nommes), admise sous une cellule d'angle vide (#102)",
         {
           stricte <- function(z) a_motif(msg_ligne(c("a17,a18,a19", paste0(z, ",102.25,109.34"))),
                                          paste0("cellule \"", z, "\" (colonne 1) n'est pas numerique"),
                                          "l'en-tete \"a17\" au-dessus d'elle n'est pas vide",
                                          "laisser vide l'en-tete de sa colonne")
           stricte("1O4.2") && stricte("104.2 EUR") && stricte("abc") &&
             identical(msg_ligne(c(",a18,a19", "abc,102.25,109.34")), c(102.25, 109.34)) &&
             a_motif(msg_ligne(c(",a18,a19", "1O4.2,102.25,109.34")),
                     "cellule \"1O4.2\" (colonne 1), en position d'etiquette de ligne") &&
             a_motif(msg_ligne(c("serie,a2017,a2018", "x,1,2")),
                     "cellule \"x\" (colonne 1) n'est pas numerique", "l'en-tete \"serie\"") &&
             # Etiquette dans une colonne de bord gauche vide cote en-tetes, en colonne 2 du fichier
             a_motif(msg_ligne(c(",a,b,c", ",lab,1,2")), "cellule \"lab\" (colonne 2)", "l'en-tete \"a\"")
         })
verifier("Lecture vecteur : marqueurs N.A, S.O, N.C., N.C, NC, N/C refuses en en-tete et en etiquette sous angle vide (reprise de #102)",
         all(vapply(c("N.A", "S.O", "N.C.", "N.C", "NC", "N/C"), function(z)
           a_motif(msg_ligne(c(z, "1", "2")), paste0("cellule \"", z, "\" en position d'en-tete")) &&
             a_motif(msg_ligne(c(",b,c", paste0(z, ",1,2"))),
                     paste0("cellule \"", z, "\" (colonne 1), en position d'etiquette de ligne")), TRUE)))
# Audit de #103 (C1, majeur) : une premiere cellule prise pour une cellule
# d'angle ("2016r", "2016 (prov.)", "2016*", "NA", "a2016") faisait ecarter
# la valeur au-dessous comme etiquette (serie lue "1 2", une annee perdue sans
# message). Regle d'actuary : cellule d'angle vide, ou libelle non numerique
# sans aucun chiffre et hors predicat.
verifier("Lecture vecteur : ligne d'annees, premiere cellule ni vide ni libelle sans chiffre refusee avec sa cause ; annee, exercice, vide admis en angle (#103)",
         {
           cause_angle <- "ici : premiere cellule ni vide ni libelle sans chiffre."
           refus <- list(c("2016r,2017,2018", "abc,1,2"), c("2016 (prov.),2017,2018", "n.c.,1,2"),
                         c("2016*,2017,2018", "x,1,2"), c("2016*,2017,2018", "5,1,2"),
                         c("2016*,2017,2018", ",1,2"), c("NA,2017,2018", "x,1,2"),
                         c("a2016,2017,2018", "abc,1,2"), c("Segment 1,2017,2018", "x,1,2"),
                         c("2016 (prov.),2017,2018", "x,1,2"))
           all(vapply(refus, function(l) a_motif(msg_ligne(l), "Format non reconnu", cause_angle), TRUE)) &&
             identical(msg_ligne(c("annee,2017,2018", "xt,1,2")), c(1, 2)) &&
             identical(msg_ligne(c("exercice,2017,2018", "xt,1,2")), c(1, 2)) &&
             identical(msg_ligne(c(",2017,2018", "xt,1,2")), c(1, 2)) &&
             # Ligne entierement textuelle (H1) : regle stricte, inchangee
             a_motif(msg_ligne(c("a2016,a2017,a2018", "abc,1,2")), "l'en-tete \"a2016\" au-dessus d'elle")
         })
# Cas d'audit de la reprise de #102 (scratchpad/audit/p2.R), en
# non-regression.
verifier("Lecture vecteur : cas d'audit de #102 (signes U+2013 / U+2212, 1O4.2 avec sep ';', etiquette 1,234.5, NA au milieu)",
         a_motif(msg_ligne(c("\u2013104.2", "102.25", "109.34")), "en position d'en-tete") &&
           a_motif(msg_ligne(c("\u2212104.2", "102.25", "109.34")), "en position d'en-tete") &&
           a_motif(msg_ligne("\u2013104.2,102.25,109.34"), "en position d'en-tete") &&
           a_motif(msg_ligne("\u2212104.2,102.25,109.34"), "en position d'en-tete") &&
           a_motif(msg_ligne("1O4.2;102,25;109,34", ";", ","), "cellule \"1O4.2\" en position d'en-tete") &&
           a_motif(msg_ligne(c("a;b;c", "1O4.2;102,25;109,34"), ";", ","),
                   "cellule \"1O4.2\" (colonne 1) n'est pas numerique", "l'en-tete \"a\"") &&
           a_motif(msg_ligne(c(";b;c", "1,234.5;2;3"), ";", ","),
                   "cellule \"1,234.5\" (colonne 1), en position d'etiquette de ligne") &&
           a_motif(msg_ligne(c("x", "NA", "2")), "non numerique(s) en position 1", "\"NA\"") &&
           identical(msg_ligne(c("2017\u201318,2018\u201319", "1,2")), c(1, 2)) &&
           identical(.allure_manquante_ou_nombre(c("2017\u201318", "2017 - 18", "2017-18 ", "\u2013104")),
                     c(FALSE, TRUE, FALSE, TRUE)))
verifier("Lecture vecteur : ligne d'en-tetes d'annees a quatre chiffres consecutives (H2), serie lue dans l'ordre du fichier (#103)",
         identical(msg_ligne(c("2017,2018,2019", "1,2,3")), c(1, 2, 3)) &&
           identical(msg_ligne(c(",2017,2018", "xt,1,2")), c(1, 2)) &&
           identical(msg_ligne(c("annee,2017,2018", "xt,1,2")), c(1, 2)) &&
           identical(msg_ligne(c("2017;2018;2019", "1,5;2;3"), ";", ","), c(1.5, 2, 3)) &&
           identical(msg_ligne(c("2019,2018,2017", "3,2,1")), c(3, 2, 1)) &&
           identical(msg_ligne(c("2017,2018,2019,", "1,2,3,")), c(1, 2, 3)) &&
           identical(msg_ligne(c("1900,1901", "1,2")), c(1, 2)) &&
           identical(msg_ligne(c("2099,2100", "1,2")), c(1, 2)) &&
           a_motif(msg_ligne(c("2017,2018,2019", "1,2,")), "colonne 3 : en-tete \"2019\" sans valeur") &&
           # Cellule d'angle textuelle : pas un en-tete d'annee ; une valeur au-dessous est sans en-tete
           a_motif(msg_ligne(c("annee,2017,2018", "5,1,2")), "colonne 1 : valeur \"5\" sans en-tete") &&
           # Etiquette sous l'angle : predicat applique
           a_motif(msg_ligne(c(",2017,2018", "NA,1,2")), "cellule \"NA\" (colonne 1), en position d'etiquette"))
verifier("Lecture vecteur : sens des annees non interprete, fixe par plus_recent_en_dernier d'usp_charger() (#103)",
         {
           fa <- tempfile(); writeLines(c("2019,2018,2017", "3,2,1"), fa)
           fb <- tempfile(); writeLines(c("2019,2018,2017", "30,20,10"), fb)
           r <- usp_charger(fa, fb, plus_recent_en_dernier = FALSE)
           identical(r$x, c(1, 2, 3)) && identical(r$y, c(10, 20, 30))
         })
verifier("Lecture vecteur : tableau de deux lignes hors H1 et H2 refuse, message nommant la cause (#103)",
         {
           fnr <- function(l, cause) a_motif(msg_ligne(l), "Format non reconnu",
                                              "annees a quatre chiffres consecutives ; ici : ",
                                              paste0("ici : ", cause, "."))
           fnr(c("1,2,3", "4,5,6"), "deux lignes numeriques, la premiere sans annees a quatre chiffres") &&
             fnr(c("17,18,19", "1,2,3"), "deux lignes numeriques, la premiere sans annees a quatre chiffres") &&
             fnr(c("2017,2019,2021", "1,2,3"), "entiers non consecutifs") &&
             fnr(c("2017,2017", "1,2"), "entiers non consecutifs") &&
             fnr(c("2017,2018,2017", "1,2,3"), "entiers non consecutifs") &&
             fnr(c("1899,1900", "1,2"), "annees hors 1900-2100") &&
             fnr(c("2100,2101", "1,2"), "annees hors 1900-2100") &&
             fnr(c("a,2018,c", "1,2,3"), "cellules numeriques melees a du texte") &&
             fnr(c(",2017", "x,5"), "une seule annee") &&
             fnr(c("1.5,2", "a,b"), "cellules numeriques qui ne sont pas des annees a quatre chiffres") &&
             # Trois lignes : message sans phrase de cause (H1/H2 ne valent que pour deux lignes)
             (function(e) grepl("Format non reconnu", e, fixed = TRUE) && !grepl("ici :", e, fixed = TRUE))(
               msg_ligne(c("a,b,c", "1,2,3", "4,5,6")))
         })

# Issue #139 (constat M1 d'audit, revue finale d'E0b ; specification
# d'actuary, variante "predicat entier" decidee par le mainteneur le
# 28/09/2026) : (H1) ne vaut que si la premiere ligne n'a aucune cellule
# numerique ET aucune cellule non vide relevant de .allure_manquante_ou_nombre().
# Mesure sur le code anterieur (tete 496b357, LC_ALL=C.UTF-8) : les six
# fichiers refuses ci-dessous etaient lus sans message, la premiere ligne
# ecartee comme ligne d'en-tetes ("1 000;2 000;3 000" -> 104.2 102.5 109.3 ;
# "1O4.2,1O2.5" -> 1 2 ; "1 000,abc,x" -> 1 2 3 ; "NA,#N/A" -> 1 2 ;
# "2017 primes,2018 primes" -> 1 2 ; "x,2017 primes" -> 1 2).
verifier("Lecture vecteur : ligne d'en-tetes sans cellule numerique mais a cellule de valeur manquante ou de nombre refusee, cellule et colonne nommees (#139)",
         {
           h1 <- function(l, cel, col, sep = ",", dec = ".")
             a_motif(msg_ligne(l, sep, dec),
                     sprintf("cellule \"%s\" (colonne %d) dans la ligne d'en-tetes", cel, col),
                     sprintf("separateur decimal attendu : \"%s\"", dec))
           h1(c("1 000;2 000;3 000", "104,2;102,5;109,3"), "1 000", 1, ";", ",") &&
             h1(c("1O4.2,1O2.5", "1,2"), "1O4.2", 1) &&
             h1(c("1 000,abc,x", "1,2,3"), "1 000", 1) &&
             h1(c("NA,#N/A", "1,2"), "NA", 1) &&
             h1(c("a,#N/A", "1,2"), "#N/A", 2) &&
             # Refus de "2017 primes" : cout assume du predicat entier (#139)
             h1(c("2017 primes,2018 primes", "1,2"), "2017 primes", 1) &&
             h1(c("x,2017 primes", "1,2"), "2017 primes", 2) &&
             # Colonne du fichier, colonne de bord vide retiree comprise
             h1(c(",a,-,c", ",1,2,3"), "-", 3) &&
             # Premiere cellule fautive citee quand il y en a plusieurs
             h1(c("a,12a,N.D.", "1,2,3"), "12a", 2) &&
             # Consequence propre a la ligne d'en-tetes (avis d'actuary sur #139)
             a_motif(msg_ligne(c("1O4.2,1O2.5", "1,2")),
                     paste("ecarter la ligne d'en-tetes qui la contient ferait perdre sans message,",
                           "si cette ligne est une serie mal saisie, toutes ses valeurs.")) &&
             # Couts assumes du predicat entier : marqueurs dans une ligne d'en-tetes
             h1(c("x,-,z", "1,2,3"), "-", 2) &&
             h1(c("annee,ND", "1,2"), "ND", 2) &&
             # Refus d'etiquette : libelle d'origine inchange
             a_motif(msg_ligne(c(",a18,a19", "1O4.2,102.25,109.34")),
                     "l'ecarter comme en-tete ou etiquette ferait perdre une annee sans message.")
         })
verifier("Lecture vecteur : lignes d'en-tetes textuelles, vides de bord et etiquettes d'exercice AAAA-AA toujours admises en (H1) (#139)",
         identical(msg_ligne(c("a2017,a2018,a2019", "1,2,3")), c(1, 2, 3)) &&
           identical(msg_ligne(c(",a18,a19", "x,1,2")), c(1, 2)) &&
           identical(msg_ligne(c("2017-18,2018-19", "1,2")), c(1, 2)) &&
           identical(msg_ligne(c("2017-2018,2018-2019", "1,2")), c(1, 2)) &&
           identical(msg_ligne(c("a;b;c", "1,5;2;3"), ";", ","), c(1.5, 2, 3)))

fin_fichier()
