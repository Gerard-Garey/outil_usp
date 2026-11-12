###############################################################################
#  tests/unitaires/test_controles_entree.R  --  CONTROLES D'ENTREE
#
#  engine_valider_donnees(), mw_valider_triangle(), engine_lire_donnees_csv(),
#  usp_controle_donnees(), usp_lire_vecteur() / usp_charger() ; exports de
#  donnees engine_ecrire_csv() et engine_ecrire_xlsx() relus au bit (#488).
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
         contient(engine_valider_donnees(c(x, x[1]), c(y, y[1]))$avertissements, "Couples (x_t, y_t) dupliques detectes."))
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
           contient(e1, "(theta_equiv) = \"0.1\" :") && contient(e2, "(theta_equiv) = c(0.1, 0.2) :") &&
             contient(e3, "(delta_equiv) = \"8\" :") && contient(e4, "(theta_equiv) = vide :")
         })
# Issue #180 : la saisie() locale citait la marge refusee par deparse() a 15
# chiffres (1 + 2^-52 cite 1, -(1 + 2^-52) cite -1) ; .engine_saisie() la
# cite a 17 chiffres quand 15 ne la restituent pas, et garde "vide", les
# guillemets d'un texte et la forme c(...) d'un vecteur.
verifier("Marge : valeur refusee qui exige 17 chiffres citee a 17 chiffres (theta = 1 + 2^-52, Delta = -(1 + 2^-52)) (#180)",
         {
           e1 <- engine_valider_donnees(x, y, theta_equiv = 1 + 2^-52)$erreurs
           e2 <- engine_valider_donnees(x, y, delta_equiv = -(1 + 2^-52))$erreurs
           contient(e1, "(theta_equiv) = 1.0000000000000002 :") &&
             contient(e2, "(delta_equiv) = -1.0000000000000002 :")
         })
verifier("Marge : vide, texte entre guillemets, vecteur en c(...) et valeurs a 15 chiffres conserves (#180)",
         {
           cite <- function(th = 0.10, de = NULL)
             engine_valider_donnees(x, y, theta_equiv = th, delta_equiv = de)$erreurs
           contient(cite(th = NULL), "(theta_equiv) = vide :") &&
             contient(cite(th = numeric(0)), "(theta_equiv) = vide :") &&
             contient(cite(de = numeric(0)), "(delta_equiv) = vide :") &&
             contient(cite(th = "0.1"), "(theta_equiv) = \"0.1\" :") &&
             contient(cite(th = c(0.1, 0.2)), "(theta_equiv) = c(0.1, 0.2) :") &&
             contient(cite(de = c(1, 2)), "(delta_equiv) = c(1, 2) :") &&
             contient(cite(th = 1.5), "(theta_equiv) = 1.5 :") &&
             contient(cite(de = -0.3), "(delta_equiv) = -0.3 :") &&
             contient(cite(th = 5L), "(theta_equiv) = 5L :") &&
             contient(cite(th = TRUE), "(theta_equiv) = TRUE :") &&
             contient(cite(th = NA_real_), "(theta_equiv) = NA (valeur manquante) :")
         })
# Issue #198 : le refus Delta >= moyenne(yt) citait Delta par format()
# (7 chiffres) et la moyenne par format(digits = 6) : Delta = moyenne =
# 80.999951 etait cite "80.99995" et "81", Delta < moyenne en apparence.
# Les deux valeurs sont desormais citees par .engine_saisie(), a 17
# chiffres quand 15 ne les restituent pas (u = 2^-46, ecart entre 81 et
# le double suivant : 81 + u et 81 + 2u sont cites "81" a 15 chiffres) ;
# une valeur que 15 chiffres restituent reste citee a 15 (170.01, 85.005).
verifier("Marge Delta >= moyenne(y) : Delta et moyenne cites par .engine_saisie(), 17 chiffres si necessaire (#198)",
         {
           u <- 2^-46
           cite <- function(yy, de) engine_valider_donnees(x, yy, delta_equiv = de)$erreurs
           e1 <- cite(rep(81 + u, 8), 81 + 2 * u)
           e2 <- cite(rep(81 + u, 8), 81 + u)
           e3 <- cite(rep(81, 8), 81 + u)
           e4 <- cite(rep(80.999951, 8), 80.999951)
           e5 <- cite(y, 2 * mean(y))
           identical(mean(rep(81 + u, 8)), 81 + u) &&
             contient(e1, "(delta_equiv) = 81.000000000000028, superieure ou egale a la perte moyenne (81.000000000000014)") &&
             contient(e2, "(delta_equiv) = 81.000000000000014, superieure ou egale a la perte moyenne (81.000000000000014)") &&
             contient(e3, "(delta_equiv) = 81.000000000000014, superieure ou egale a la perte moyenne (81)") &&
             contient(e4, "(delta_equiv) = 80.999951, superieure ou egale a la perte moyenne (80.999951)") &&
             contient(e5, "(delta_equiv) = 170.01, superieure ou egale a la perte moyenne (85.005)")
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
# Issue #180 (extension Q-R9-2 (A)) : T = 8 + 1.8e-15, refuse comme non
# entier, etait cite "T = 8" par deparse() a 15 chiffres ; .engine_saisie()
# le cite a 17 chiffres, et garde "vide", "6" et c(5, 6).
verifier("engine_valider_profondeur : T refuse qui exige 17 chiffres cite a 17 chiffres ; vide, texte, vecteur conserves (#180)",
         contient(engine_valider_profondeur(8 + 1.8e-15, 10), "Profondeur T = 8.0000000000000018 :") &&
         contient(engine_valider_profondeur(5.5, 8), "Profondeur T = 5.5 :") &&
         contient(engine_valider_profondeur(numeric(0), 8), "Profondeur T = vide :") &&
         contient(engine_valider_profondeur("6", 8), "Profondeur T = \"6\" :") &&
         contient(engine_valider_profondeur(c(5, 6), 8), "Profondeur T = c(5, 6) :"))
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
           length(e1) == 1L && contient(e1, "x_t = 1.042e-298 (< 1e-50, borne inferieure) ; 8 valeurs hors du domaine") &&
             contient(e1, "(et a la marge Delta du test d'equivalence si elle est fournie)") &&
             length(e2) == 1L && contient(e2, "x_t = 2e+60 (> 1e+50, borne superieure).") &&
             contient(e3, "x_t = 1.0000000000000003e+50 (> 1e+50, borne superieure)")
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
             refus(replace(x, 1, haut), replace(y, 1, 6e49), "x_t") &&
             refus(replace(x, 1, 1e50), replace(y, 1, haut), "y_t") &&
             refus(replace(x, 1, 1.5e-50), replace(y, 1, bas), "y_t") &&
             refus(replace(x, 1, bas), replace(y, 1, 1e-50), "x_t")
         })
verifier("Domaine numerique : seule la serie retenue est controlee (annee hors domaine ecartee par T acceptee, refusee sinon) (#145)",
         {
           s8 <- engine_valider_serie_retenue(c(1e-60, x), c(1, y), T = 8)$validation
           s9 <- engine_valider_serie_retenue(c(1e-60, x), c(1, y))$validation
           isTRUE(s8$ok) && !s9$ok && contient(s9$erreurs, "x_t = 1e-60 (< 1e-50, borne inferieure).")
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
           motif <- "Ratio y_t/x_t hors de la plage plausible [0.1 ; 5[ : verifier les unites."
           contient(avt(x * 1e3, y), motif) && isTRUE(engine_valider_donnees(x * 1e3, y)$ok) &&
             contient(avt(x * 1e-1, y * 50), motif) &&
             !contient(avt(c(10, x[-1]), c(1, y[-1])), motif) &&
             contient(avt(c(10, x[-1]), c(0.99, y[-1])), motif) &&
             !contient(avt(x, y), motif)
         })
verifier("Ligne A 'Plausibilite du ratio y/x' : memes constantes que l'avertissement (r = 0,1 OK ; 0,099 et 5 ECHEC), detail avec plage (#145, #186)",
         {
           ligne <- function(xt, yt) {
             r <- usp_controle_donnees(xt, yt)
             r[[which(vapply(r, function(l) l$test, "") == "Plausibilite du ratio y/x")]]
           }
           l1 <- ligne(c(10, x[-1]), c(1, y[-1]))
           identical(l1$verdict, "OK") &&
             identical(l1$detail, "min = 0.100 ; median = 0.751 ; max = 0.894 ; plage plausible [0.1 ; 5[") &&
             identical(ligne(c(10, x[-1]), c(0.99, y[-1]))$verdict, "ECHEC") &&
             identical(ligne(c(10, x[-1]), c(50, y[-1]))$verdict, "ECHEC") &&
             identical(ligne(c(10, x[-1]), c(49.9, y[-1]))$verdict, "OK") &&
             identical(ligne(x * 1e3, y)$verdict, "ECHEC")
         })
verifier("Ligne A 'Plausibilite du ratio y/x' : aux bornes, le detail ne contredit plus le verdict (0,0996 -> 0.0996 ECHEC ; 4,9996 -> 4.9996 OK ; 5 -> 5.000 ECHEC) (#186)",
         {
           ligne <- function(xt, yt) {
             r <- usp_controle_donnees(xt, yt)
             r[[which(vapply(r, function(l) l$test, "") == "Plausibilite du ratio y/x")]]
           }
           xx <- rep(100, 8)
           yy <- function(r1) c(r1 * 100, rep(70, 7))
           lb <- ligne(xx, yy(0.0996)); lh <- ligne(xx, yy(4.9996)); l5 <- ligne(xx, yy(5))
           identical(lb$verdict, "ECHEC") &&
             identical(lb$detail, "min = 0.0996 ; median = 0.700 ; max = 0.700 ; plage plausible [0.1 ; 5[") &&
             identical(lh$verdict, "OK") &&
             identical(lh$detail, "min = 0.700 ; median = 0.700 ; max = 4.9996 ; plage plausible [0.1 ; 5[") &&
             identical(l5$verdict, "ECHEC") &&
             identical(l5$detail, "min = 0.700 ; median = 0.700 ; max = 5.000 ; plage plausible [0.1 ; 5[")
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
# pi_t de l'ajustement (#215 : poids du modele auxiliaire pondere de la
# constante et du TOST) ; invariant par x, y -> c x, c y.
pi153 <- usp_ajuster(x153, y153)$pi
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
             # #514 (Q-3) : rangs retires du detail, separateur ", ".
             startsWith(ok$detail, "Repere conventionnel 4/T = 0.500, 2 annee(s) au-dessus :") &&
             startsWith(ok0$detail, "Repere conventionnel 4/T = 0.500, 0 annee(s) au-dessus :")
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
# Texte etendu par #215 (constat 3 d'audit) : mention des poids invalides.
DETAIL_TOST153 <- paste("statistique t non definie (poids de la regression ponderee non",
                        "valides, ou constante ou erreur-type de la regression de y sur x",
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
# fini ou <= 0) ; (2 bis, #215) "statistique non definie" si les poids
# w_t = 1 / ((x_t / moyenne(x))^2 expm1(1 / pi_t)), rapportes a leur
# maximum, ne sont pas tous finis et > 0 ; (3) "x ecarte" (#168) si lm() a
# ecarte x (garde-fou R12 : "x" absent de rownames(summary(stats::lm(y ~ x,
# weights = w))$coefficients)) ; (4)
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
tost_motif_attendu153 <- function(x, y, pi, theta = 0.10, delta_abs = NULL) {
  if (usp_volumes_constants(x)) return("volumes constants")
  # Pertes constantes (#189) : apres les volumes constants, avant la marge.
  if (usp_pertes_constantes(y)) return("pertes constantes")
  if ((is.null(delta_abs) && (!is.finite(theta) || theta <= 0)) ||
      (!is.null(delta_abs) && (!is.finite(delta_abs) || delta_abs <= 0))) return("marge")
  w <- 1 / ((x / mean(x))^2 * expm1(1 / pi))
  if (!all(is.finite(w)) || any(w <= 0)) return("statistique non definie")
  w <- w / max(w)
  if (!all(is.finite(w)) || any(w <= 0)) return("statistique non definie")
  resume <- get("summary", envir = environment(run_engine))
  m <- resume(stats::lm(y ~ x, weights = w))
  if (!"x" %in% rownames(m$coefficients)) return("x ecarte")
  a <- m$coefficients[1, 1]; se <- m$coefficients[1, 2]
  ddl <- length(x) - 2
  Delta <- if (is.null(delta_abs)) theta * mean(y) else delta_abs
  p_bas <- stats::pt((a + Delta) / se, ddl, lower.tail = FALSE)
  p_haut <- stats::pt((a - Delta) / se, ddl, lower.tail = TRUE)
  if (is.finite(p_bas) && is.finite(p_haut)) NA_character_ else "statistique non definie"
}
tost_coherent153 <- function(r, ref, x, y, pi) !inherits(r, "error") && identical(names(r), ref) &&
  identical(r$non_applicable, tost_motif_attendu153(x, y, pi)) &&
  (if (is.na(r$non_applicable)) is.finite(r$p) && is.finite(r$stat)
   else identical(r$p, NA_real_) && identical(r$stat, NA_real_))
# Ligne TOST de usp_tests(), en regard de test_tost_intercept() sur les memes
# donnees (x, y = fit$x, fit$y) : detail du motif, lu dans usp_tests()
# ("volumes constants" : texte de la regle R13 ; "x ecarte" : texte du
# garde-fou R12, #168 ; "pertes constantes" : texte de #189) ; ligne
# "test" a p retenue finie si calculee.
PREFIXE_PERTES_CST189 <- paste("regression de y sur x : pertes y_t constantes a la tolerance",
                               "relative TOL_DELTA_BORD = 1e-06 pres")
ligne_tost_coherente153 <- function(lt, r, x) {
  m <- r$non_applicable
  if (is.na(m)) return(identical(lt$type, "test") && is.finite(lt$p_retenue) &&
                         startsWith(lt$detail, "Rejeter H0 fournit une preuve POSITIVE"))
  attendu <- switch(m,
    "volumes constants" = NA_character_,
    "pertes constantes" = NA_character_,
    "x ecarte" = paste("regression de y sur x : x ecarte par lm() pour colinearite,",
                       "test non applicable"),
    "marge" = paste("marge Delta invalide (sans delta_equiv : theta_equiv non",
                    "fini ou <= 0 ; ou delta_equiv non fini ou <= 0) : test",
                    "non applicable"),
    "statistique non definie" = DETAIL_TOST153,
    return(FALSE))
  identical(lt$type, "non applicable") && identical(lt$verdict, "INFO") && is.na(lt$p_retenue) &&
    (if (identical(m, "pertes constantes"))
       startsWith(lt$detail, PREFIXE_PERTES_CST189)
     else if (is.na(attendu)) startsWith(lt$detail, "volumes x_t constants")
     else identical(lt$detail, attendu))
}
# Injections deterministes (voir ci-dessus).
.echelle_orig153 <- .usp_echelle_exacte
echelle_y_nul153 <- function(y0) function(v) if (isTRUE(all.equal(v, y0))) 0 * v else .echelle_orig153(v)
# Depuis #237, la constante et le TOST ne passent plus par summary() mais
# par .usp_lm_pondere() (QR) : la meme alteration de la matrice des
# coefficients y est injectee (avec_pondere237()), summary() restant injectee
# pour test_lm_complet() et pour le motif attendu (tost_motif_attendu153()).
avec_pondere237 <- function(alterer, expr) {
  e <- environment(run_engine)
  orig <- get(".usp_lm_pondere", envir = e, inherits = FALSE)
  assign(".usp_lm_pondere", function(...) {
    m <- orig(...)
    if (!is.null(m)) m$coefficients <- alterer(m$coefficients)
    m
  }, envir = e)
  on.exit(assign(".usp_lm_pondere", orig, envir = e))
  expr
}
avec_summary_nan153 <- function(expr) {
  e <- environment(run_engine)
  existait <- exists("summary", envir = e, inherits = FALSE)
  if (existait) orig <- get("summary", envir = e, inherits = FALSE)
  alterer <- function(cf) { cf[1, 1:2] <- NaN; cf }
  assign("summary", function(object, ...) {
    s <- base::summary(object, ...)
    if (inherits(object, "lm")) s$coefficients <- alterer(s$coefficients)
    s
  }, envir = e)
  on.exit(if (existait) assign("summary", orig, envir = e) else rm("summary", envir = e))
  avec_pondere237(alterer, expr)
}
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
             identical(tail(names(ri$plots_data), 5), c("qq_enveloppe", "spread_enveloppe", "sigma_usp_boot",
                                                       "regime_boot", "boot_reperes")) &&
             identical(names(ti), names(t1)) && identical(ti$test, t1$test)
         })
# Garde TOST atteinte a coup sur : avant #153, erreur R de
# if (p_bas >= p_haut) sur NaN.
verifier("test_tost_intercept() et usp_tests(), constante et erreur-type NaN (injection de summary()) -> non applicable 'statistique non definie', memes champs que la branche calculee, detail exact de la ligne, sans erreur R ; motif accepte par tost_coherent153() sous l'injection, refuse hors injection et resultat forge (motif, p = stat = NA sur les donnees de test) refuse (#153)",
         {
           ref <- names(test_tost_intercept(x153, y153, pi153))
           r <- tryCatch(avec_summary_nan153(test_tost_intercept(x153, y153, pi153)), error = function(e) e)
           # Resultat forge : branche calculee relabellisee, sans injection.
           forge <- modifyList(test_tost_intercept(x153, y153, pi153),
                               list(stat = NA_real_, p = NA_real_,
                                    non_applicable = "statistique non definie"))
           f1 <- usp_ajuster(x153, y153); b1 <- usp_bootstrap(f1, B = B_MIN_USAGE)
           # usp_tests() : la regression ponderee est calculee une fois et
           # passee a la constante et au TOST (#222, point 1) ; l'alteration
           # porte donc sur .usp_lm_pondere(), objet partage, et non sur
           # test_tost_intercept() seule.
           tt <- tryCatch(avec_pondere237(function(cf) { cf[1, 1:2] <- NaN; cf },
                                          usp_tests(f1, b1, methode = "premium")),
                          error = function(e) e)
           !inherits(r, "error") && identical(r$non_applicable, "statistique non definie") &&
             identical(r$p, NA_real_) && identical(r$stat, NA_real_) && identical(names(r), ref) &&
             !exists("summary", envir = environment(run_engine), inherits = FALSE) &&
             !inherits(tt, "error") && ligne_tost_coherente153(ligne153(tt, LIGNE_TOST153), r, x153) &&
             identical(ligne153(tt, LIGNE_TOST153)$verdict, "INFO") &&
             isTRUE(avec_summary_nan153(tost_coherent153(r, ref, x153, y153, pi153))) &&
             !tost_coherent153(r, ref, x153, y153, pi153) && !tost_coherent153(forge, ref, x153, y153, pi153) &&
             tost_coherent153(test_tost_intercept(x153, y153, pi153), ref, x153, y153, pi153)
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
  alterer <- function(cf) cf[rownames(cf) != "x", , drop = FALSE]
  assign("summary", function(object, ...) {
    s <- base::summary(object, ...)
    if (inherits(object, "lm")) s$coefficients <- alterer(s$coefficients)
    s
  }, envir = e)
  on.exit(if (existait) assign("summary", orig, envir = e) else rm("summary", envir = e))
  avec_pondere237(alterer, expr)
}
verifier("Coherence TOST (#153, #168) : x ecarte par lm() (injection de summary() sans la ligne x) -> 'x ecarte' accepte, ligne au detail du garde-fou R12 ; meme reponse refusee quand lm() garde x ; reponse calculee refusee sous la condition R12",
         {
           ref <- names(test_tost_intercept(x153, y153, pi153))
           f1 <- usp_ajuster(x153, y153); b1 <- usp_bootstrap(f1, B = B_MIN_USAGE)
           r12 <- avec_summary_sans_x153(test_tost_intercept(x153, y153, pi153))
           ok12 <- avec_summary_sans_x153(tost_coherent153(r12, ref, x153, y153, pi153))
           # Regression ponderee partagee de usp_tests() (#222, point 1) :
           # l'alteration porte sur .usp_lm_pondere().
           tt12 <- avec_pondere237(function(cf) cf[rownames(cf) != "x", , drop = FALSE],
                                   usp_tests(f1, b1, methode = "premium"))
           r0 <- test_tost_intercept(x153, y153, pi153)
           identical(r12$non_applicable, "x ecarte") && isTRUE(ok12) &&
             ligne_tost_coherente153(ligne153(tt12, LIGNE_TOST153), r12, x153) &&
             !tost_coherent153(r12, ref, x153, y153, pi153) &&
             !isTRUE(avec_summary_sans_x153(tost_coherent153(r0, ref, x153, y153, pi153))) &&
             tost_coherent153(r0, ref, x153, y153, pi153) &&
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
# Ligne Student (#423) : memes motifs R13, pertes constantes et R12 que la
# ligne Fisher (detail_motif()).
LIGNES_R12_168 <- c("Nullite de la constante (proportionnalite stricte)",
                    LIGNE_TOST153,
                    "Test de Pitman sur la pente (lien positif pertes / volume)",
                    "Test de Student sur la pente (modele auxiliaire MCO)",
                    "Test de Fisher (significativite globale)")
LIGNE_R2_168 <- "Coefficient de determination R2"
FONCTIONS_R12_168 <- c("test_intercept", "test_lm_complet", "test_tost_intercept")
# Ligne Spearman ratio / volume (#215) : a pi_t constant, son detail porte le
# renvoi croise a la constante si et seulement si celle-ci est calculee ; une
# constante rendue non applicable (R12, pertes constantes) le retire. Elle
# est comparee hors detail, et son detail ne doit pas porter le renvoi.
NOM_SV215 <- "Independance ratio S/P vs volume"
TXT_RENVOI_SV215 <- "pi_t constant (delta estime a 1) : une constante a non nulle dans"
sv_sans_renvoi215 <- function(l, l0) {
  sans_detail <- function(u) { u$detail <- NULL; u }
  identical(sans_detail(l), sans_detail(l0)) && !grepl(TXT_RENVOI_SV215, l$detail, fixed = TRUE)
}
# Evalue expr avec les trois fonctions enveloppees dans avec_summary_sans_x153(),
# et .usp_lm_pondere() alteree (ligne x retiree) : usp_tests() calcule la
# regression ponderee une fois, hors de test_intercept() et de
# test_tost_intercept(), et la leur passe (#222, point 1).
avec_r12_168 <- function(expr) {
  e <- environment(run_engine)
  orig <- mget(FONCTIONS_R12_168, envir = e)
  for (nm in FONCTIONS_R12_168) local({
    f <- orig[[nm]]
    assign(nm, function(...) avec_summary_sans_x153(f(...)), envir = e)
  })
  on.exit(for (nm in FONCTIONS_R12_168) assign(nm, orig[[nm]], envir = e))
  avec_pondere237(function(cf) cf[rownames(cf) != "x", , drop = FALSE], expr)
}
# Fonction du moteur lue dans son environnement (ADR 0016, #200) : la
# substitution d'avec_r12_168() est posee dans environment(run_engine), et la
# copie exposee dans l'environnement global n'est pas substituee ; un appel
# direct a une fonction substituee passe donc par cet environnement.
moteur168 <- function(nom) get(nom, envir = environment(run_engine), inherits = FALSE)
verifier("test_intercept() et test_lm_complet() : champ x_ecarte TRUE sur la seule branche du garde-fou R12 (injection), FALSE sur la branche calculee et a volumes constants, stat et p NA sous R12 ; test_tost_intercept() : motif 'x ecarte' sous R12, 'volumes constants' a volumes constants (#168)",
         {
           xq <- 300 * (1 + c(1, -1, 1, -1, 1, -1, 1, -1) * 1e-8)
           i12 <- avec_r12_168(moteur168("test_intercept")(x153, y153, pi153))
           l12 <- avec_r12_168(moteur168("test_lm_complet")(x153, y153))
           i0 <- test_intercept(x153, y153, pi153); l0 <- test_lm_complet(x153, y153)
           identical(i12$x_ecarte, TRUE) && identical(l12$x_ecarte, TRUE) &&
             identical(i0$x_ecarte, FALSE) && identical(l0$x_ecarte, FALSE) &&
             identical(test_intercept(xq, y153, pi153)$x_ecarte, FALSE) &&
             identical(test_lm_complet(xq, y153)$x_ecarte, FALSE) &&
             identical(i12$stat, NA_real_) && identical(i12$p, NA_real_) &&
             identical(l12$t_pente, NA_real_) && identical(l12$F, NA_real_) && identical(l12$R2, NA_real_) &&
             identical(names(i12), names(i0)) && identical(names(l12), names(l0)) &&
             identical(avec_r12_168(moteur168("test_tost_intercept")(x153, y153, pi153))$non_applicable, "x ecarte") &&
             identical(test_tost_intercept(xq, y153, pi153)$non_applicable, "volumes constants") &&
             is.na(test_tost_intercept(x153, y153, pi153)$non_applicable) &&
             !exists("summary", envir = environment(run_engine), inherits = FALSE)
         })
# Lignes de famille et ligne globale de lecture conjointe (#297) : derivees
# des types des autres lignes (composition figee a l'observe), elles changent
# avec eux ; les comparaisons "autres lignes identiques" portent sur les
# lignes hors lecture conjointe.
sans_famille297 <- function(L) Filter(function(l) !identical(l$fonction, "engine_p_famille"), L)
verifier("usp_tests(), x ecarte par lm() hors volumes constants (injection de summary() dans les trois fonctions qui regressent y sur x) : constante, TOST, pente (Pitman et Student, #423), Fisher non applicables (INFO, p retenue NA) au detail du garde-fou R12, R2 au sien ; autres lignes et ordre identiques a l'appel sans injection, Spearman ratio / volume hors detail et sans renvoi (#168 ; #215)",
         {
           f1 <- usp_ajuster(x153, y153); b1 <- usp_bootstrap(f1, B = B_MIN_USAGE)
           t12 <- tryCatch(avec_r12_168(usp_tests(f1, b1, methode = "premium")), error = function(e) e)
           t0 <- sans_famille297(usp_tests(f1, b1, methode = "premium"))
           if (inherits(t12, "error")) return(paste("erreur :", conditionMessage(t12)))
           t12 <- sans_famille297(t12)
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
           autres <- !noms0 %in% c(LIGNES_R12_168, LIGNE_R2_168, NOM_SV215)
           if (!identical(noms12, noms0)) pb <- c(pb, "ordre des lignes")
           else if (!identical(t12[autres], t0[autres])) pb <- c(pb, "autres lignes modifiees")
           else if (!sv_sans_renvoi215(ligne153(t12, NOM_SV215), ligne153(t0, NOM_SV215)))
             pb <- c(pb, "ligne Spearman ratio / volume")
           if (exists("summary", envir = environment(run_engine), inherits = FALSE)) pb <- c(pb, "summary non restauree")
           if (length(pb)) paste(pb, collapse = " ; ") else TRUE
         })
# Priorite R13 > R12 dans usp_tests() (detail_motif(), #189 ; garde
# !vol_cst de detail_r12() avant #189) : a
# volumes constants, test_intercept() et test_lm_complet() sortent avant
# lm() avec x_ecarte = FALSE ; pour atteindre la garde, leur resultat est
# rendu avec x_ecarte force a TRUE. TOST : priorite assuree par
# test_tost_intercept() (motif "volumes constants" teste avant lm()).
verifier("usp_tests() a volumes constants, x_ecarte force a TRUE dans test_intercept() et test_lm_complet() : le motif R13 prime sur R12 pour constante, pente, Fisher (detail_motif()), TOST et R2 (#168)",
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
# ci-dessous) : le detail des cinq lignes porte le motif R12 si et
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
# Motif du refus "maximum de vraisemblance non atteint" (#188, texte arbitre
# par regulatory, decision du mainteneur du 08/10/2026), reconstruit ici
# morceau par morceau, independamment de usp_valider_ajustement().
motif188 <- function(borne = c("basse", "haute"), methode = c("premium", "reserve1")) {
  borne <- match.arg(borne); methode <- match.arg(methode)
  prem <- methode == "premium"; sec <- if (prem) "B" else "C"
  tt <- sprintf(paste("Maximum de vraisemblance non atteint (annexe XVII, %s(6)) :",
                      "gamma estime sur la borne %s du domaine de recherche [%s ; %s]",
                      "(BORNES_GAMMA, bornes de l'outil, non reglementaires) ; les valeurs",
                      "delta et gamma qui minimisent le montant de %s(6), dont depend le",
                      "parametre de %s(4), ne sont pas determinees dans ce domaine."),
                sec, borne, "-12", "3", sec, sec)
  c1 <- "Cause : ratios y_t/x_t egaux ou quasi egaux ; s'ils sont exactement egaux, ce minimum n'existe pas."
  c2 <- "Cause : dispersion des ratios y_t/x_t extreme ; le minimum, s'il existe, est au-dela de la borne."
  ff <- sprintf(paste("L'outil ne calcule pas de parametre sur ces donnees (article 220,",
                      "paragraphe 1, point %s), qui ne permettent d'etablir ni la",
                      "distribution log-normale ni l'adequation de l'estimation de la",
                      "vraisemblance maximum (%s, iii et iv ; article 219, paragraphe 1,",
                      "point d))."),
                if (prem) "a)" else "b)", if (prem) "B(2)(g)" else "C(2)(e)")
  rr <- "La methode du risque de reserve no 2 reste ouverte (meme point)."
  v1 <- sprintf("Verifier que y_t est observe (%s(1)(a)) et non deduit de x_t par un coefficient fixe.", sec)
  v2 <- sprintf("Verifier les unites, la correspondance des annees et les valeurs aberrantes (%s(1) et %s(2)(a)).",
                sec, sec)
  paste(c(tt, if (borne == "basse") c1 else c2, ff, if (!prem) rr,
          if (borne == "basse") v1 else v2), collapse = " ")
}
# Meme entree par run_engine() : la decision du mainteneur du 02/10/2026
# (serie exactement proportionnelle non refusee) est remplacee par la
# decision du mainteneur du 08/10/2026, #188 : maximum de vraisemblance non
# atteint (gamma sur la borne basse de BORNES_GAMMA, condition KKT non
# satisfaite), ok = FALSE au motif de usp_valider_ajustement(), sans defaut
# intercepte. Donnees de test : ok = TRUE, motif des graphiques d'influence
# absent, qq_enveloppe et spread_enveloppe (#306) restant en fin de liste,
# suivis des trois champs de #305 (sigma_usp_boot, regime_boot, boot_reperes).
verifier("run_engine : y exactement proportionnel a x -> ok = FALSE au motif borne basse, sans erreur_r (decision du mainteneur du 08/10/2026, #188) ; donnees de test : ok = TRUE, plots_data$influence_motif absent, qq_enveloppe et spread_enveloppe suivis des trois champs de #305 en fin de liste (#153, #306, #305)",
         {
           rp <- calcul_extreme(xp153, xp153 / 2); r1 <- calcul_extreme(x, y)
           identical(rp$ok, FALSE) && identical(names(rp), c("ok", "validation", "metadata")) &&
             is.null(rp$validation$erreur_r) &&
             identical(tail(rp$validation$erreurs, 1), motif188("basse", "premium")) &&
             isTRUE(r1$ok) && is.null(r1$plots_data$influence_motif) &&
             identical(tail(names(r1$plots_data), 5), c("qq_enveloppe", "spread_enveloppe", "sigma_usp_boot",
                                                       "regime_boot", "boot_reperes"))
         })
verifier("test_tost_intercept() : entrees sous-normales (x et y x 1e-320, 5e-324) -> sans erreur R, memes champs que la branche calculee ; motif egal a celui que declenchent les conditions de test_tost_intercept() sur ces donnees (volumes constants, marge, x ecarte par lm() (R12), 'statistique non definie' si et seulement si p_bas ou p_haut, recalculees depuis summary(lm(y ~ x)), n'est pas finie), ligne calculee finie sinon (#153)",
         {
           ref <- names(test_tost_intercept(x153, y153, pi153))
           all(vapply(c(1e-320, 5e-324), function(f) {
             r <- tryCatch(test_tost_intercept(x153 * f, y153 * f, pi153), error = function(e) e)
             tost_coherent153(r, ref, x153 * f, y153 * f, pi153)
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
    r <- test_tost_intercept(x153 * f, y153 * f, pi153)
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
               r <- tryCatch(test_tost_intercept(fe$x, fe$y, fe$pi), error = function(e) e)
               return(tost_coherent153(r, names(test_tost_intercept(x153, y153, pi153)), fe$x, fe$y, fe$pi) &&
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
             !"methode" %in% names(r) && identical(r$metadata$methode, "premium")
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
             contient(b1$erreurs, "Defaut de calcul intercepte dans la fonction usp_simuler() du moteur :") &&
             identical(b1$erreur_r$message, "panne simulee") &&
             identical(b2$erreur_r$pile, c("usp_tests", "add", "sprintf")) &&
             identical(b2$erreur_r$origine, "usp_tests") &&
             contient(b2$erreurs, "Defaut de calcul intercepte dans la fonction usp_tests() du moteur :") &&
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
           !inherits(r, "error") && identical(r$ok, FALSE) && !"methode" %in% names(r) &&
             identical(r$metadata$methode, "reserve2") &&
             contient(r$validation$erreurs, "Defaut de calcul intercepte dans la fonction mw_bootstrap() du moteur :") &&
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
                      "doit etre un nombre strictement compris entre 0 et 0.3 (SEUIL_ECHEC_SENS_REJETER)"))
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
                      "l'ecart-type standard saisi doit etre un nombre strictement positif"))
verifier("run_engine : sigma_standard NULL, 0,10 et 2 acceptes (premium, reserve2)",
         usage_accepte("sigma_standard", list(NULL, 0.10, 2)))
verifier("run_engine : seed NULL, NA, texte, vecteur, logique, 1.5, Inf, 3e9 -> erreur d'usage du moteur (premium, reserve2)",
         erreur_usage("seed", list(NULL, NA, NA_real_, "5", "a", c(1, 2), TRUE, 1.5, Inf, 3e9),
                      "la graine doit etre un nombre entier compris entre -2147483647 et 2147483647"))
verifier("run_engine : seed NA et NULL -> message du moteur citant la valeur recue",
         {
           e1 <- tryCatch(usage_premium(seed = NA), error = function(e) e)
           e2 <- tryCatch(usage_mw(seed = NULL), error = function(e) e)
           inherits(e1, "error") && inherits(e2, "error") &&
             startsWith(conditionMessage(e1),
                        "seed = NA (valeur manquante) : la graine doit etre un nombre entier") &&
             startsWith(conditionMessage(e2), "seed = vide : ") &&
             grepl("faute de quoi le calcul ne serait pas reproductible", conditionMessage(e2),
                   fixed = TRUE) &&
             grepl("NULL refuse).", conditionMessage(e2), fixed = TRUE)
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
                        "doit etre un nombre entier au moins egal a 99 (B_MIN_USAGE)") &&
           {
             e <- tryCatch(usage_premium(B = 98), error = function(e) e)
             inherits(e, "error") && startsWith(conditionMessage(e), "B = 98 : ")
           })
verifier("run_engine : B = B_MIN_USAGE = 99 accepte (premium, reserve2)",
         usage_accepte("B", list(99)))

# Issue #527, groupe usage (US-01 a US-05) : texte complet de chaque message,
# mot pour mot celui du tableau du par. 7.2 de l'avis amont d'actuary
# (docs/revues/20261111-avis-amont-k4/actuary-avis-amont.md), declenche par
# run_engine() avec une valeur manquante (US-04 : B = 99, alpha = 0,01).
message_usage <- function(...) {
  e <- tryCatch(usage_premium(...), error = function(e) e)
  if (inherits(e, "error") && is.null(conditionCall(e))) conditionMessage(e) else NA_character_
}
verifier("run_engine : US-01, B vide -> texte complet du message (#527)",
         identical(message_usage(B = NA_real_),
                   paste("B = NA (valeur manquante) : le nombre de replications bootstrap doit etre",
                         "un nombre entier au moins egal a 99 (B_MIN_USAGE) ; en appel direct, un",
                         "nombre seul, sans attribut.")))
verifier("run_engine : US-02, graine vide -> texte complet du message (#527)",
         identical(message_usage(seed = NA_real_),
                   paste("seed = NA (valeur manquante) : la graine doit etre un nombre entier compris",
                         "entre -2147483647 et 2147483647 ; elle est obligatoire, faute de quoi le",
                         "calcul ne serait pas reproductible (en appel direct : un nombre seul, sans",
                         "attribut, NULL refuse).")))
verifier("run_engine : US-03, alpha vide -> texte complet du message (#527)",
         identical(message_usage(alpha = NA_real_),
                   paste("alpha = NA (valeur manquante) : le seuil des verdicts doit etre un nombre",
                         "strictement compris entre 0 et 0.3 (SEUIL_ECHEC_SENS_REJETER) ; au-dela, la",
                         "zone ALERTE des tests en sens rejeter disparait et le verdict ne suit plus",
                         "la regle documentee (en appel direct : un nombre seul, sans attribut).")))
verifier("run_engine : US-04, B = 99 et alpha = 0,01 -> texte complet du message (#527)",
         identical(message_usage(B = 99, alpha = 0.01),
                   paste("B = 99 et alpha = 0.01 : B + 1 > 4/alpha est requis, soit B >= 400 a ce",
                         "seuil (en plus du minimum B >= 99, B_MIN_USAGE). Le plancher bilateral de",
                         "la p-value Monte-Carlo, 2/(B+1) = 0.02, n'est pas inferieur a alpha/2 =",
                         "0.005 : l'ECHEC des tests dont la seule p-value est Monte-Carlo serait",
                         "inatteignable (regle des verdicts).")))
verifier("run_engine : US-05, sigma standard vide -> texte complet du message (#527)",
         identical(message_usage(sigma_standard = NA_real_),
                   paste("sigma_standard = NA (valeur manquante) : l'ecart-type standard saisi doit",
                         "etre un nombre strictement positif ; pour retenir le parametre standard du",
                         "segment, ne pas le saisir (en appel direct : un nombre seul, sans attribut,",
                         "ou NULL).")))

# Issue #527, groupe lognormale (LN-03 a LN-10, PR-01, AJ-04) : texte complet
# de chaque motif change, sur le gabarit du tableau du par. 7.2 de l'avis
# amont d'actuary, declenche par run_engine() (refus ok = FALSE, motif dans
# validation$erreurs, aucune erreur levee). Le motif sans origine d'AJ-04
# est atteint par run_engine() quand la pile de l'erreur ne contient aucune
# fonction du moteur (primitive du corps protege, fonction de R ou anonyme ;
# revue finale de K4, Q2) ; il est declenche ici directement par
# .engine_calcul_protege().
refus_527 <- function(...) {
  a <- list(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
            nature_donnees = "brutes")
  l <- list(...); for (n in names(l)) a[n] <- l[n]
  r <- tryCatch(do.call(run_engine, a), error = function(e) e)
  if (inherits(r, "usp_engine") && identical(r$ok, FALSE)) r$validation$erreurs else NA_character_
}
verifier("run_engine : LN-03, valeur infinie -> texte complet du motif (#527)",
         identical(refus_527(yt = replace(y, 3, Inf)),
                   "Valeurs infinies : x_t et y_t doivent etre des nombres finis."))
verifier("run_engine : LN-04, x_t nul -> texte complet du motif (#527)",
         identical(refus_527(xt = replace(x, 3, 0)),
                   "Toutes les valeurs de x_t doivent etre strictement positives."))
verifier("run_engine : LN-05, y_t negatif -> texte complet du motif (#527)",
         identical(refus_527(yt = replace(y, 3, -1)),
                   "Toutes les valeurs de y_t doivent etre strictement positives (loi lognormale)."))
verifier("run_engine : LN-06, x_t et y_t x 1e-110 -> deux motifs complets, valeurs a 17 chiffres (#527)",
         {
           fin <- paste("sigma_USP et les tests sont invariants par un changement d'unite commun a",
                        "x_t et y_t (et a la marge Delta du test d'equivalence si elle est fournie) :",
                        "exprimer les montants dans une unite qui les ramene dans le domaine.")
           identical(refus_527(xt = x * 1e-110, yt = y * 1e-110),
                     c(paste("Valeur de x_t hors du domaine numerique [1e-50 ; 1e+50] : x_t =",
                             "1.0420000000000001e-108 (< 1e-50, borne inferieure) ; 8 valeurs hors du",
                             "domaine.", fin),
                       paste("Valeur de y_t hors du domaine numerique [1e-50 ; 1e+50] : y_t =",
                             "6.8970000000000006e-109 (< 1e-50, borne inferieure) ; 8 valeurs hors du",
                             "domaine.", fin)))
         })
verifier("run_engine : LN-07, serie de 4 annees et T = 4 -> deux motifs distincts, profondeur puis serie (#527)",
         identical(refus_527(xt = x[1:4], yt = y[1:4], T = 4),
                   c(paste("Profondeur T = 4 inferieure a 5 : l'annexe XVII, B/C(2)(b), exige au moins",
                           "5 annees consecutives."),
                     paste("Annexe XVII, B/C(2)(b) : au moins 5 annees consecutives sont exigees, la",
                           "serie en compte 4."))))
verifier("run_engine : LN-07, serie de 4 annees sans T, et serie de 8 annees a T = 4 -> un motif chacun (#527)",
         identical(refus_527(xt = x[1:4], yt = y[1:4]),
                   paste("Annexe XVII, B/C(2)(b) : au moins 5 annees consecutives sont exigees, la",
                         "serie en compte 4.")) &&
           identical(refus_527(T = 4),
                     paste("Profondeur T = 4 inferieure a 5 : l'annexe XVII, B/C(2)(b), exige au moins",
                           "5 annees consecutives.")))
verifier("run_engine : LN-08, marge Delta vide -> texte complet du motif (#527)",
         identical(refus_527(delta_equiv = NA_real_),
                   paste("Marge Delta du test d'equivalence (delta_equiv) = NA (valeur manquante) : un",
                         "nombre fini strictement positif est attendu.")))
verifier("run_engine : LN-09, marge Delta 500 >= perte moyenne -> texte complet du motif (#527)",
         identical(refus_527(delta_equiv = 500),
                   paste("Marge Delta du test d'equivalence (delta_equiv) = 500, superieure ou egale a",
                         "la perte moyenne (85.005) : l'equivalence ne se lirait plus comme une",
                         "proportionnalite ; 0 < Delta < moyenne des y_t est attendu.")))
verifier("run_engine : LN-10, marge theta vide -> texte complet du motif (#527)",
         identical(refus_527(theta_equiv = NA_real_),
                   paste("Marge theta du test d'equivalence (theta_equiv) = NA (valeur manquante) : un",
                         "nombre fini, 0 < theta < 1 (fraction de la perte moyenne), est attendu.")))
verifier("run_engine : PR-01, profondeur T vide -> texte complet du motif (#527)",
         identical(refus_527(T = NA_real_),
                   paste("Profondeur T = NA (valeur manquante) : un nombre entier d'annees est attendu",
                         "(annexe XVII, B/C(2)(b)) ; la serie n'est pas tronquee.")))
verifier("run_engine : AJ-04, defaut intercepte dans usp_controle_donnees() -> texte complet du motif (#527)",
         {
           r <- avec_injection("usp_controle_donnees", panne, calcul_extreme(x, y))
           identical(r$ok, FALSE) && !is.null(r$validation$erreur_r) &&
             identical(r$validation$erreurs,
                       paste("Defaut de calcul intercepte dans la fonction usp_controle_donnees() du",
                             "moteur : aucun resultat n'est produit ; diagnostic technique dans le champ",
                             "validation$erreur_r du resultat."))
         })
verifier(".engine_calcul_protege : AJ-04 sans fonction d'origine -> texte complet du motif (#527)",
         {
           r <- .engine_calcul_protege("premium", Sys.time(), list(ok = TRUE, erreurs = character(0)),
                                       stop("panne simulee"))
           identical(r$ok, FALSE) && identical(r$validation$erreur_r$origine, NA_character_) &&
             identical(r$validation$erreurs,
                       paste("Defaut de calcul intercepte : aucun resultat n'est produit ; diagnostic",
                             "technique dans le champ validation$erreur_r du resultat."))
         })
# Revue finale de K4, Q2 (avis d'actuary) : origine = derniere fonction du
# moteur de la pile, NA si la pile n'en contient aucune (fonction de R ou
# anonyme jamais dite du moteur), la pile restant dans erreur_r ; avant, repli
# sur le dernier cadre ("dans la fonction data.frame() du moteur").
# (1) .engine_calcul_protege() direct, erreur nee dans data.frame() ;
# (2) run_engine() : usp_controle_donnees() remplacee par une fonction qui
# restaure l'originale puis echoue dans data.frame() (au moment de l'erreur,
# le cadre n'execute plus la fonction du moteur de ce nom) ; (3) une erreur
# nee dans une fonction du moteur garde son nom dans le motif.
verifier(".engine_calcul_protege et run_engine : AJ-04, erreur dans data.frame() sans fonction du moteur dans la pile -> origine NA, pile conservee, motif neutre ; usp_ajuster() garde son nom (revue finale K4, Q2)",
         {
           neutre <- paste("Defaut de calcul intercepte : aucun resultat n'est produit ; diagnostic",
                           "technique dans le champ validation$erreur_r du resultat.")
           r1 <- .engine_calcul_protege("premium", Sys.time(), list(ok = TRUE, erreurs = character(0)),
                                        data.frame(a = 1:2, b = 1:3))
           e <- environment(run_engine)
           orig <- get("usp_controle_donnees", envir = e)
           r2 <- avec_injection("usp_controle_donnees", function(...) {
             assign("usp_controle_donnees", orig, envir = e)
             data.frame(a = 1:2, b = 1:3)
           }, calcul_extreme(x, y))
           r3 <- .engine_calcul_protege("premium", Sys.time(), list(ok = TRUE, erreurs = character(0)),
                                        usp_ajuster(c(1, 2, 3), "a"))
           identical(r1$ok, FALSE) && identical(r1$validation$erreur_r$origine, NA_character_) &&
             "data.frame" %in% r1$validation$erreur_r$pile &&
             identical(r1$validation$erreurs, neutre) &&
             identical(r2$ok, FALSE) && identical(r2$validation$erreur_r$origine, NA_character_) &&
             identical(r2$validation$erreur_r$pile, c("usp_controle_donnees", "data.frame")) &&
             identical(r2$validation$erreurs, neutre) &&
             identical(r3$ok, FALSE) && identical(r3$validation$erreur_r$origine, "usp_ajuster") &&
             identical(r3$validation$erreurs,
                       paste("Defaut de calcul intercepte dans la fonction usp_ajuster() du moteur :",
                             "aucun resultat n'est produit ; diagnostic technique dans le champ",
                             "validation$erreur_r du resultat."))
         })

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
             grepl("doit etre un nombre entier au moins egal a 99 (B_MIN_USAGE)", conditionMessage(e),
                   fixed = TRUE) &&
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
         erreur_usage("B", list(c(a = B_MIN_USAGE), matrix(B_MIN_USAGE)),
                      "en appel direct, un nombre seul, sans attribut.") &&
           erreur_usage("alpha", list(c(a = 0.1), matrix(0.1)), "sans attribut") &&
           erreur_usage("seed", list(c(a = 5), matrix(5)), "sans attribut") &&
           erreur_usage("bareme", list(c(a = "court"), matrix("court")), "(sans attribut)") &&
           erreur_usage("sigma_standard", list(c(a = 0.1), matrix(0.1)), "sans attribut"))
# Avant #489, theta_equiv etait ignore en reserve2 (r2$ok TRUE) : il y est
# desormais une erreur d'usage, argument sans effet pour la methode.
verifier("run_engine : theta_equiv invalide -> refus ok = FALSE en premium et reserve1 (#33), erreur d'usage nommant theta_equiv en reserve2 (#489)",
         {
           r1 <- usage_premium(theta_equiv = NA)
           r3 <- run_engine(xt = x, yt = y, methode = "reserve1", segment = 1, B = B_MIN_USAGE,
                            theta_equiv = NA)
           r2 <- tryCatch(usage_mw(theta_equiv = NA), error = function(e) e)
           identical(r1$ok, FALSE) && is.null(r1$validation$erreur_r) &&
             contient(r1$validation$erreurs, "(theta_equiv) = NA (valeur manquante) :") &&
             identical(r3$ok, FALSE) && is.null(r3$validation$erreur_r) &&
             contient(r3$validation$erreurs, "(theta_equiv) = NA (valeur manquante) :") &&
             inherits(r2, "error") &&
             startsWith(conditionMessage(r2), "theta_equiv : argument sans effet pour la methode \"reserve2\"")
         })

# Issue #489 (constats C5 et C7 de l'audit entrees-sorties ; decision du
# mainteneur du 08/11/2026, Q-55-3 (iii)). C5 : methode et annexe sont
# controlees exactement avant match.arg(), qui completait une abreviation
# (annexe = "X" lue "XIV", "I" lue "II", methode = "p" lue "premium").
# C7 : un argument sans effet pour la methode choisie est une erreur d'usage
# qui le nomme ; plus_recent_en_dernier = NA levait une erreur R qui ne le
# nommait pas.
message_489 <- function(expr) {
  e <- tryCatch({ force(expr); NULL }, error = function(e) e)
  if (inherits(e, "error")) conditionMessage(e) else NA_character_
}
verifier("run_engine : annexe = \"X\", \"I\", \"xiv\", NA, NULL, c(\"II\", \"XIV\") -> erreur d'usage nommant annexe (premium, reserve2 ; #489)",
         all(vapply(list("X", "I", "xiv", NA, NULL, c("II", "XIV")), function(a) {
           m1 <- message_489(usage_premium(annexe = a))
           m2 <- message_489(usage_mw(annexe = a))
           all(!is.na(c(m1, m2))) &&
             all(startsWith(c(m1, m2), paste0("annexe = ", .engine_saisie(a), " : "))) &&
             all(grepl("\"II\" ou \"XIV\" exactement est attendu (aucune abreviation)",
                       c(m1, m2), fixed = TRUE))
         }, logical(1))))
verifier("run_engine : methode = \"p\", \"reserve\", NA, NULL, c(\"premium\", \"reserve1\", \"reserve2\") -> erreur d'usage nommant methode (#489)",
         all(vapply(list("p", "reserve", NA, NULL, c("premium", "reserve1", "reserve2")), function(m) {
           msg <- message_489(usage_premium(methode = m))
           !is.na(msg) && startsWith(msg, paste0("methode = ", .engine_saisie(m), " : ")) &&
             grepl("\"premium\", \"reserve1\" ou \"reserve2\" exactement est attendu",
                   msg, fixed = TRUE)
         }, logical(1))))
verifier("run_engine : methode omise -> premium, annexe omise -> II (defauts inchanges, #489)",
         {
           r <- run_engine(xt = x, yt = y, segment = 1, B = B_MIN_USAGE, nature_donnees = "brutes")
           isTRUE(r$ok) && identical(r$metadata$methode, "premium") &&
             identical(r$metadata$annexe, "II")
         })
verifier("run_engine, reserve2 : xt, yt, T = 5, theta_equiv, delta_equiv, plus_recent_en_dernier fournis -> erreur d'usage nommant l'argument (#489)",
         {
           cas <- list(xt = x, yt = y, T = 5, theta_equiv = 0.10, delta_equiv = 1,
                       plus_recent_en_dernier = TRUE)
           all(vapply(names(cas), function(n) {
             msg <- message_489(do.call(usage_mw, cas[n]))
             !is.na(msg) &&
               startsWith(msg, paste0(n, " : argument sans effet pour la methode \"reserve2\""))
           }, logical(1))) &&
             startsWith(message_489(usage_mw(T = 5, theta_equiv = 0.1)),
                        "T, theta_equiv : arguments sans effet pour la methode \"reserve2\"")
         })
verifier("run_engine, reserve2 : xt et yt NULL, valeurs par defaut de theta_equiv et plus_recent_en_dernier non passees -> accepte (#489)",
         isTRUE(usage_mw(xt = NULL, yt = NULL, T = NULL, delta_equiv = NULL)$ok))
verifier("run_engine, premium et reserve1 : triangle fourni -> erreur d'usage nommant triangle ; triangle NULL accepte (#489)",
         {
           m1 <- message_489(usage_premium(triangle = tri_usage))
           m3 <- message_489(run_engine(xt = x, yt = y, methode = "reserve1", segment = 1,
                                        B = B_MIN_USAGE, triangle = tri_usage))
           !is.na(m1) && startsWith(m1, "triangle : argument sans effet pour la methode \"premium\"") &&
             !is.na(m3) && startsWith(m3, "triangle : argument sans effet pour la methode \"reserve1\"") &&
             isTRUE(usage_premium(triangle = NULL)$ok)
         })
verifier("run_engine, premium : plus_recent_en_dernier NA, NULL, \"a\", 1, c(TRUE, FALSE), c(a = TRUE) -> erreur d'usage nommant l'argument ; FALSE accepte (#489)",
         all(vapply(list(NA, NULL, "a", 1, c(TRUE, FALSE), c(a = TRUE)), function(v) {
           msg <- message_489(usage_premium(plus_recent_en_dernier = v))
           !is.na(msg) && startsWith(msg, paste0("plus_recent_en_dernier = ", .engine_saisie(v), " : ")) &&
             grepl("TRUE ou FALSE (logique scalaire non NA, sans attribut) est attendu", msg, fixed = TRUE)
         }, logical(1))) &&
           isTRUE(usage_premium(plus_recent_en_dernier = FALSE)$ok))
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
           !r$ok && contient(r$erreurs, "non carre") &&
             contient(r$erreurs, "paragraphes 4 et 5")
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
           !r$ok && contient(r$erreurs, "Cellule observee manquante : annee d'accident i = 1, annee de developpement j = 2.")
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
           contient(e, "Valeur non finie en annee d'accident i = 0, annee de developpement j = 1 : Inf") &&
             contient(e, "Valeur non finie en annee d'accident i = 1, annee de developpement j = 0 : -Inf") &&
             contient(e, "Valeur non finie en annee d'accident i = 2, annee de developpement j = 1 : NaN") &&
             contient(e, "Cellule observee manquante : annee d'accident i = 0, annee de developpement j = 3.") &&
             !contient(e, "manquante : annee d'accident i = 0, annee de developpement j = 1.") && length(e) == 4L
         })
# Issue #527, groupe Merz-Wuthrich (MW-04 a MW-08) : texte complet de chaque
# motif change, sur le gabarit du tableau du par. 7.2 de l'avis amont
# d'actuary, declenche par run_engine(methode = "reserve2") sur le triangle
# de tests/donnees (refus ok = FALSE, motif dans validation$erreurs, aucune
# erreur levee). Cellule designee par son annee d'accident i et son annee de
# developpement j.
refus_mw_527 <- function(t) {
  r <- tryCatch(run_engine(methode = "reserve2", triangle = t, segment = 1, annexe = "II",
                           B = B_MIN_USAGE), error = function(e) e)
  if (inherits(r, "usp_engine") && identical(r$ok, FALSE) && is.null(r$validation$erreur_r))
    r$validation$erreurs else NA_character_
}
cellule_527 <- function(i, j, v) { t <- tri_usage; t[i + 1L, j + 1L] <- v; t }
verifier("run_engine reserve2 : MW-04, triangle 8 x 6 -> texte complet du motif (#527)",
         identical(refus_mw_527(tri_usage[, 1:6]),
                   paste("Triangle non carre (8 annees d'accident, 6 annees de developpement) : cas",
                         "non couvert par les formules des paragraphes 4 et 5 de la section D de",
                         "l'annexe XVII.")))
verifier("run_engine reserve2 : MW-05, cellule observee vide -> texte complet du motif (#527)",
         identical(refus_mw_527(cellule_527(0, 2, NA)),
                   paste("Cellule observee manquante : annee d'accident i = 0, annee de",
                         "developpement j = 2.")))
verifier("run_engine reserve2 : MW-06, cellule Inf -> texte complet du motif (#527)",
         identical(refus_mw_527(cellule_527(0, 2, Inf)),
                   paste("Valeur non finie en annee d'accident i = 0, annee de developpement j = 2 :",
                         "Inf.")))
verifier("run_engine reserve2 : MW-07, cumul negatif -> texte complet du motif (#527)",
         identical(refus_mw_527(cellule_527(0, 2, -5)),
                   paste("Cumul non strictement positif : annee d'accident i = 0, annee de",
                         "developpement j = 2.")))
verifier("run_engine reserve2 : MW-08, une cellule 1e120, puis tout le triangle x 1e-110 (17 chiffres, decompte) -> textes complets (#527)",
         {
           fin <- paste("sigma_USP et les tests sont invariants par un changement d'unite commun a",
                        "toutes les cellules du triangle : exprimer les cumuls dans une unite qui les",
                        "ramene dans le domaine.")
           identical(refus_mw_527(cellule_527(0, 2, 1e120)),
                     paste("Cumul hors du domaine numerique [1e-50 ; 1e+50] en annee d'accident i = 0,",
                           "annee de developpement j = 2 : 1e+120 (> 1e+50, borne superieure).", fin)) &&
             identical(refus_mw_527(tri_usage * 1e-110),
                       paste("Cumul hors du domaine numerique [1e-50 ; 1e+50] en annee d'accident i = 0,",
                             "annee de developpement j = 0 : 3.0000000000000003e-108 (< 1e-50, borne",
                             "inferieure) ; 36 cellules observees hors du domaine.", fin))
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
# Issue #491 (decision du mainteneur du 08/11/2026, Q-55-3 (ii)) : toute
# cellule i + j > I non NA est signalee par un avertissement non bloquant,
# quelle que soit sa valeur ; .run_engine_mw() la met a NA avant le calcul
# (triangle restitue et decompte des cellules observees restreints).
tri491 <- local({
  m <- as.matrix(read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv")))
  m <- m[, colnames(m) != "i", drop = FALSE]
  storage.mode(m) <- "double"
  unname(m)
})
cel491 <- function(r) with(r$statistiques_descriptives, valeur[grandeur == "Cellules observees"])
verifier("Triangle de reference : aucune cellule sous la diagonale signalee, 36 cellules observees (#491)",
         {
           r <- run_engine(methode = "reserve2", triangle = tri491, segment = 1,
                           annexe = "II", B = B_MIN_USAGE)
           isTRUE(r$ok) && !contient(r$validation$avertissements, "sous la diagonale") &&
             cel491(r) == 36 && contient(r$controles[[1]]$detail, "36 cellules observees")
         })
verifier("Rectangle 8 x 8 complete par C_chapeau : avertissement, 36 cellules, triangle restitue restreint, sigma_USP inchange (#491)",
         {
           rect <- mw_ajuster(tri491)$C_chapeau
           r0 <- run_engine(methode = "reserve2", triangle = tri491, segment = 1,
                            annexe = "II", B = B_MIN_USAGE)
           r <- run_engine(methode = "reserve2", triangle = rect, segment = 1,
                           annexe = "II", B = B_MIN_USAGE)
           av <- r$validation$avertissements
           isTRUE(r$ok) && !anyNA(rect) &&
             sum(grepl("sous la diagonale", av, fixed = TRUE)) == 1L &&
             contient(av, "(i = 1, j = 7), (i = 2, j = 6), (i = 2, j = 7), (i = 3, j = 5), (i = 3, j = 6) et 23 autre(s) (i : annee d'accident, j : annee de developpement)") &&
             cel491(r) == 36 && contient(r$controles[[1]]$detail, "36 cellules observees") &&
             identical(r$triangle, tri491) &&
             identical(r$parametre_final$sigma_usp, r0$parametre_final$sigma_usp) &&
             abs(r$parametre_final$sigma_usp - 0.04977646) < 5e-9
         })
verifier("Deux cellules sous la diagonale dont une negative : avertissement, pas de refus, 36 cellules (#491)",
         {
           m <- tri491; m[8, 2] <- -3; m[5, 6] <- 1000
           v <- mw_valider_triangle(m)
           l <- engine_lire_triangle(as.data.frame(m))
           r <- run_engine(methode = "reserve2", triangle = m, segment = 1,
                           annexe = "II", B = B_MIN_USAGE)
           isTRUE(v$ok) && !length(v$erreurs) &&
             contient(v$avertissements, "sous la diagonale (i + j > I) en (i = 4, j = 5), (i = 7, j = 1) (i : annee d'accident, j : annee de developpement) :") &&
             isTRUE(l$ok) && contient(l$avertissements, "(i = 4, j = 5), (i = 7, j = 1)") &&
             isTRUE(r$ok) && cel491(r) == 36 && identical(r$triangle, tri491)
         })
verifier("Cellule NaN sous la diagonale signalee et remise a NA (#491)",
         {
           m <- tri491; m[8, 3] <- NaN
           v <- mw_valider_triangle(m)
           r <- run_engine(methode = "reserve2", triangle = m, segment = 1,
                           annexe = "II", B = B_MIN_USAGE)
           isTRUE(v$ok) && contient(v$avertissements, "sous la diagonale (i + j > I) en (i = 7, j = 2) (i : annee d'accident, j : annee de developpement) :") &&
             isTRUE(r$ok) && cel491(r) == 36 && identical(r$triangle, tri491)
         })
verifier("Cellules sous la diagonale : 5 positions citees sans suffixe, 6 avec \"et 1 autre(s)\" (#491)",
         {
           m5 <- tri491; m5[8, 2:6] <- 1
           m6 <- tri491; m6[8, 2:7] <- 1
           a5 <- mw_valider_triangle(m5)$avertissements
           a6 <- mw_valider_triangle(m6)$avertissements
           contient(a5, "(i = 7, j = 1), (i = 7, j = 2), (i = 7, j = 3), (i = 7, j = 4), (i = 7, j = 5) (i : annee d'accident, j : annee de developpement) : hors") &&
             !contient(a5, "autre(s)") &&
             contient(a6, "(i = 7, j = 1), (i = 7, j = 2), (i = 7, j = 3), (i = 7, j = 4), (i = 7, j = 5) et 1 autre(s) (i : annee d'accident, j : annee de developpement) : hors")
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
           !a$ok && contient(a$erreurs, "(ligne(s) de donnees 3)") && !b$ok
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
           !r$ok && contient(r$erreurs, "Cellule(s) non numerique(s) en (i = 2, j = 1)") && is.null(r$triangle)
         })
verifier("engine_lire_triangle : cellule texte \"Inf\" signalee 'valeur non finie', non 'manquante' (#33)",
         {
           d <- fichier_tri(t5); d$j1 <- as.character(d$j1); d$j1[1] <- "Inf"
           r <- engine_lire_triangle(d)
           !r$ok && contient(r$erreurs, "Valeur non finie en annee d'accident i = 0, annee de developpement j = 1 : Inf.") &&
             !contient(r$erreurs, "manquante") && is.null(r$triangle)
         })
verifier("engine_lire_triangle : erreurs de recevabilite de mw_valider_triangle() restituees",
         {
           d <- fichier_tri(t5); d$j2[2] <- NA
           r1 <- engine_lire_triangle(d)
           r2 <- engine_lire_triangle(fichier_tri(triangle(4)))
           !r1$ok && contient(r1$erreurs, "Cellule observee manquante : annee d'accident i = 1, annee de developpement j = 2.") && !r2$ok && contient(r2$erreurs, "D(2)(b)") &&
             !engine_lire_triangle(data.frame())$ok && !engine_lire_triangle(list(a = 1))$ok
         })
# Issue #518 : avertissements_lecture, sous-ensemble des avertissements propre
# au fichier lu (cellules renseignees sous la diagonale, #491), seul restitue
# par l'application au statut de demarrage et d'import ; le champ
# avertissements, calcule sans segment, reste inchange.
sous518 <- function(m) { m[nrow(m), 2] <- 1000; m[nrow(m) - 1L, 3:4] <- c(-3, NaN); m }
verifier("engine_lire_triangle : avertissements_lecture vide sans cellule sous la diagonale (8 x 8 et 10 x 10), avertissements inchanges (#518)",
         {
           r8 <- engine_lire_triangle(fichier_tri(triangle(8)))
           r10 <- engine_lire_triangle(fichier_tri(triangle(10)))
           isTRUE(r8$ok) && identical(r8$avertissements_lecture, character(0)) &&
             identical(r8$avertissements, mw_valider_triangle(triangle(8))$avertissements) &&
             length(r8$avertissements) == 2L && contient(r8$avertissements, "credibilite partielle") &&
             isTRUE(r10$ok) && identical(r10$avertissements_lecture, character(0)) &&
             identical(r10$avertissements, mw_valider_triangle(triangle(10))$avertissements)
         })
verifier("engine_lire_triangle : avertissements_lecture = le seul motif des cellules sous la diagonale (8 x 8 et 10 x 10), meme texte que mw_valider_triangle() avec ou sans segment (#518)",
         all(vapply(c(8L, 10L), function(n) {
           m <- sous518(triangle(n))
           r <- engine_lire_triangle(fichier_tri(m))
           av_seg <- mw_valider_triangle(m, segment = 1)$avertissements
           sd <- grep("sous la diagonale", r$avertissements, fixed = TRUE, value = TRUE)
           isTRUE(r$ok) && length(r$avertissements_lecture) == 1L && identical(r$avertissements_lecture, sd) &&
             identical(r$avertissements_lecture, grep("sous la diagonale", av_seg, fixed = TRUE, value = TRUE)) &&
             contient(r$avertissements_lecture, sprintf("(i = %d, j = 2), (i = %d, j = 3), (i = %d, j = 1) (i : annee d'accident, j : annee de developpement) :", n - 2L, n - 2L, n - 1L)) &&
             !contient(r$avertissements_lecture, "credibilite") && !contient(r$avertissements_lecture, "bruites") &&
             identical(r$avertissements, mw_valider_triangle(m)$avertissements)
         }, logical(1))))
verifier("engine_lire_triangle : avertissements_lecture vide sur un refus, meme a cellules sous la diagonale (#518)",
         {
           d <- fichier_tri(sous518(triangle(8))); d$j2[2] <- NA
           r <- engine_lire_triangle(d)
           !r$ok && identical(r$avertissements_lecture, character(0)) &&
             identical(engine_lire_triangle(data.frame())$avertissements_lecture, character(0))
         })

## --- Repere de profondeur : champ validation$repere_profondeur (#499) ---------
# Champ lu par l'affichage (en tete de l'onglet Tests et de la section 5 du
# rapport fige) : la chaine du repere non reglementaire (T < 10, I + 1 < 10),
# la meme que dans les avertissements, character(0) sinon et sur un refus
# sans avertissement.
REPERE_T8 <- paste("T = 8 : lois asymptotiques peu fiables.",
                   "Privilegier les p-values exactes ou Monte-Carlo.",
                   "Une p-value elevee ne demontre pas la validite de l'hypothese :",
                   "elle ne permet pas de la rejeter.")
REPERE_I8 <- paste("I + 1 = 8 annees d'accident : estimateurs de variance tres bruites en fin de triangle.",
                   "Une p-value elevee ne demontre pas la validite de l'hypothese :",
                   "elle ne permet pas de la rejeter.")
tri499 <- local({
  df <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(df[, setdiff(names(df), "i")]); storage.mode(m) <- "double"; unname(m)
})
x12 <- c(x, 133.5, 136.0, 140.2, 141.8); y12 <- c(y, 90.1, 84.3, 101.7, 95.2)
verifier("repere_profondeur : premium T = 8 pose (texte exact, present une fois dans les avertissements), dans res$validation de run_engine() (#499)",
         {
           v <- engine_valider_donnees(x, y)
           r <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                           nature_donnees = "brutes", B = B_MIN_USAGE)
           identical(v$repere_profondeur, REPERE_T8) && sum(v$avertissements == REPERE_T8) == 1L &&
             isTRUE(r$ok) && identical(r$validation$repere_profondeur, REPERE_T8) &&
             sum(r$validation$avertissements == REPERE_T8) == 1L
         })
verifier("repere_profondeur : T >= 10 vide (character(0)), y compris sur le bareme long a credibilite partielle (#499)",
         {
           v10 <- engine_valider_donnees(x12[1:10], y12[1:10], segment = 1)
           v12 <- engine_valider_donnees(x12, y12)
           isTRUE(v10$ok) && identical(v10$repere_profondeur, character(0)) &&
             contient(v10$avertissements, "credibilite partielle") &&
             isTRUE(v12$ok) && identical(v12$repere_profondeur, character(0)) &&
             !contient(v12$avertissements, "lois asymptotiques")
         })
verifier("repere_profondeur : reserve2 I + 1 = 8 pose dans res$validation de run_engine(), I + 1 = 10 vide (#499)",
         {
           r <- suppressWarnings(run_engine(methode = "reserve2", triangle = tri499, segment = 1,
                                            annexe = "II", B = B_MIN_USAGE))
           v10 <- mw_valider_triangle(triangle(10))
           identical(mw_valider_triangle(tri499)$repere_profondeur, REPERE_I8) &&
             isTRUE(r$ok) && identical(r$validation$repere_profondeur, REPERE_I8) &&
             sum(r$validation$avertissements == REPERE_I8) == 1L &&
             isTRUE(v10$ok) && identical(v10$repere_profondeur, character(0))
         })
verifier("repere_profondeur : refus (ok = FALSE) -- champ present, character(0) sans avertissement (nature absente, T non entier, donnees refusees, triangle non numerique) ; refus de nature du triangle : garde, comme les avertissements (#499)",
         {
           rn <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II", B = B_MIN_USAGE)
           rt <- run_engine(xt = x12, yt = y12, methode = "premium", segment = 1, annexe = "II",
                            nature_donnees = "brutes", T = 8.5, B = B_MIN_USAGE)
           vd <- engine_valider_donnees(replace(x, 3, -1), y)
           vs <- engine_valider_serie_retenue(x12, y12, T = 8.5)
           rc <- run_engine(methode = "reserve2", triangle = matrix("a", 6, 6), segment = 1, annexe = "II")
           rb <- run_engine(methode = "reserve2", triangle = tri499, segment = 1, annexe = "II",
                            nature_donnees = "brutes", B = B_MIN_USAGE)
           vide <- function(v) "repere_profondeur" %in% names(v) && identical(v$repere_profondeur, character(0))
           !rn$ok && vide(rn$validation) && !rt$ok && vide(rt$validation) &&
             !vd$ok && vide(vd) && !vs$validation$ok && vide(vs$validation) &&
             !rc$ok && vide(rc$validation) && vide(mw_valider_triangle("a")) &&
             !rb$ok && identical(rb$validation$repere_profondeur, REPERE_I8) &&
             REPERE_I8 %in% rb$validation$avertissements
         })

## --- Lignes et colonnes vides des fichiers lus (#483) -------------------------
# Regle commune aux series et au triangle, posee par
# .retirer_lignes_colonnes_vides() : lignes vides de fin retirees ; ligne vide
# intercalee ou en tete refusee (motifs distincts) ; colonne vide sans en-tete
# en bord retiree, sauf au bord gauche du triangle, apres i s'il existe et
# precede les donnees (#520) ; triangle : colonne vide intercalee ou portant
# un en-tete refusee ; meme motif quel que soit le chemin (openxlsx, lecteur
# interne, data.frame d'un CSV lu en texte avec ses lignes vides).
xt483 <- 100:108; yt483 <- 60 + (0:8)
ser483 <- data.frame(xt = xt483, yt = yt483)
avec_vide <- function(d, k) d[append(seq_len(nrow(d)), NA, after = k - 1), , drop = FALSE]
# Forme d'un CSV lu en texte (colClasses = "character", blank.lines.skip = FALSE)
en_texte <- function(d) { d[] <- lapply(d, function(v) ifelse(is.na(v), "", as.character(v))); d }
# Colonne vide de nom nom inseree apres la colonne k
col_vide <- function(d, k, nom) {
  d2 <- cbind(d[, seq_len(k), drop = FALSE], NA, d[, setdiff(seq_len(ncol(d)), seq_len(k)), drop = FALSE])
  names(d2)[k + 1] <- nom; d2
}
MOTIF483 <- "Ligne(s) vide(s) intercalee(s) (ligne(s) de donnees 4) : une ligne vide est refusee comme annee manquante presumee"
verifier("Lignes vides (#483) : ligne vide intercalee dans des series sans t refusee, motif citant B(2)(b) et C(2)(b)",
         {
           r <- engine_lire_donnees_csv(avec_vide(ser483, 4))
           !r$ok && length(r$erreurs) == 1 && contient(r$erreurs, MOTIF483) &&
             contient(r$erreurs, "B(2)(b) et C(2)(b)") && is.null(r$xt)
         })
verifier("Lignes vides (#483) : meme motif pour un data.frame de chaines (CSV lu en texte, cellules vides ou blanches)",
         {
           d <- en_texte(avec_vide(ser483, 4)); d$yt[4] <- "  "
           identical(engine_lire_donnees_csv(d)$erreurs,
                     engine_lire_donnees_csv(avec_vide(ser483, 4))$erreurs)
         })
verifier("Lignes vides (#483) : ligne vide en tete (sous l'en-tete) refusee par un motif distinct (\"en tete\")",
         {
           e <- engine_lire_donnees_csv(avec_vide(ser483, 1))$erreurs
           length(e) == 1 && contient(e, "Ligne(s) vide(s) en tete, sous l'en-tete (ligne(s) de donnees 1)") &&
             !contient(e, "intercalee")
         })
verifier("Lignes vides (#483) : lignes vides de fin retirees sans refus, series identiques",
         {
           r0 <- engine_lire_donnees_csv(ser483)
           d <- rbind(ser483, NA, NA)
           identical(engine_lire_donnees_csv(d), r0) &&
             identical(engine_lire_donnees_csv(en_texte(d)), r0)
         })
verifier("Lignes vides (#483) : fichier avec colonne t sans ligne vide inchange (tri, trou d'annee refuse)",
         {
           d <- data.frame(t = c(2003, 2001, 2002, 2004:2009), xt = xt483, yt = yt483)
           r <- engine_lire_donnees_csv(d)
           b <- engine_lire_donnees_csv(data.frame(t = c(2001:2003, 2005:2010), xt = xt483, yt = yt483))
           isTRUE(r$ok) && identical(r$xt, c(101, 102, 100, 103:108)) &&
             !b$ok && contient(b$erreurs, "non consecutives")
         })
verifier("Lignes vides (#483) : fichier avec colonne t a ligne vide intercalee refuse par le meme motif",
         {
           d <- avec_vide(data.frame(t = 2001:2009, xt = xt483, yt = yt483), 4)
           identical(engine_lire_donnees_csv(d)$erreurs,
                     engine_lire_donnees_csv(avec_vide(ser483, 4))$erreurs)
         })
verifier("Lignes vides (#483) : tableau fait de lignes vides seules refuse comme vide",
         contient(engine_lire_donnees_csv(ser483[1:2, ][NA_integer_, ])$erreurs, "Fichier vide"))
verifier("Colonnes vides (#483) : series, colonne vide sans en-tete retiree (bord ou intercalee), series identiques",
         {
           r0 <- engine_lire_donnees_csv(ser483)
           all(vapply(list(col_vide(ser483, 0, "X1"), col_vide(ser483, 1, "X2"), col_vide(ser483, 2, "V3"),
                           en_texte(col_vide(ser483, 1, ""))),
                      function(d) identical(engine_lire_donnees_csv(d), r0), logical(1)))
         })
tri483 <- fichier_tri(triangle(6))
verifier("Lignes vides (#483) : triangle a ligne vide intercalee refuse (colonne i comprise), D(2)(b) cite, CSV texte compris",
         {
           r <- engine_lire_triangle(avec_vide(tri483, 4))
           r2 <- engine_lire_triangle(en_texte(avec_vide(tri483, 4)))
           !r$ok && is.null(r$triangle) &&
             contient(r$erreurs, "Ligne(s) vide(s) intercalee(s) dans le triangle (ligne(s) de donnees 4)") &&
             contient(r$erreurs, "D(2)(b)") && identical(r2$erreurs, r$erreurs)
         })
verifier("Lignes vides (#483) : triangle a ligne vide en tete refuse par le motif \"en tete\"",
         contient(engine_lire_triangle(avec_vide(tri483, 1))$erreurs,
                  "Ligne(s) vide(s) en tete dans le triangle, sous l'en-tete (ligne(s) de donnees 1)"))
verifier("Lignes vides (#483) : triangle a lignes vides de fin lu comme sans elles",
         {
           r0 <- engine_lire_triangle(tri483)
           isTRUE(r0$ok) && identical(engine_lire_triangle(rbind(tri483, NA, NA)), r0) &&
             isTRUE(all.equal(engine_lire_triangle(en_texte(rbind(tri483, NA)))$triangle, r0$triangle,
                              tolerance = 1e-15))
         })
# Bord gauche du triangle (#520, regle R-a) : une colonne vide sans en-tete
# entre i et j0 n'est plus retiree (cas col_vide(tri483, 1, "V2"), accepte
# par #483, desormais refuse par le motif de #520, test suivant).
verifier("Colonnes vides (#483, #520) : triangle, colonne vide sans en-tete en bord (gauche avant i, droite) retiree",
         {
           r0 <- engine_lire_triangle(tri483)
           # forme texte : valeurs ecrites par as.character() (15 chiffres), d'ou all.equal()
           all(vapply(list(col_vide(tri483, 0, "X1"), col_vide(tri483, 7, "X8")),
                      function(d) identical(engine_lire_triangle(d), r0), logical(1))) &&
             isTRUE(all.equal(engine_lire_triangle(en_texte(col_vide(tri483, 7, ""))), r0,
                              tolerance = 1e-15)) &&
             isTRUE(all.equal(engine_lire_triangle(en_texte(col_vide(tri483, 0, ""))), r0,
                              tolerance = 1e-15))
         })
# Issue #520 (regle R-a, decision du mainteneur D1 du 11/11/2026 ; texte fixe
# par l'avis amont d'actuary sur K2, par. 1.1) : colonne vide sans en-tete
# avant la premiere colonne de developpement renseignee, et apres i si i
# existe, refusee comme annee de developpement 0 manquante presumee, avec ou
# sans colonne i ; le motif tient lieu de "Triangle non carre". Colonne
# numerotee par sa position dans le tableau lu, colonne i comprise.
motif520 <- function(cols)
  sprintf(paste("Colonne(s) vide(s) sans en-tete avant la premiere colonne renseignee du triangle (colonne(s) %s) :",
                "annee de developpement 0 manquante presumee ; la renseigner, ou retirer la colonne vide",
                "si le triangle commence bien a l'annee de developpement 0."), cols)
tri520 <- fichier_tri(triangle(8))
# Colonne j0 videe, sans en-tete ("" : CSV lu avec check.names = FALSE)
c0_520 <- function(avec_i = TRUE, nom = "") {
  d <- tri520; d$j0 <- NA; names(d)[2] <- nom
  if (avec_i) d else d[, -1, drop = FALSE]
}
# n colonnes vides sans en-tete inserees apres la colonne k
vides520 <- function(d, k, n) {
  v <- as.data.frame(matrix(NA, nrow(d), n))
  d2 <- cbind(d[, seq_len(k), drop = FALSE], v, d[, setdiff(seq_len(ncol(d)), seq_len(k)), drop = FALSE])
  names(d2) <- append(names(d), rep("", n), after = k); d2
}
verifier("Colonne 0 vide (#520) : triangle 8 x 8 a colonne 0 vide sans en-tete refuse, sans i (colonne 1) et avec i (colonne 2), motif seul, CSV texte compris",
         {
           a <- engine_lire_triangle(c0_520(FALSE)); b <- engine_lire_triangle(c0_520(TRUE))
           !a$ok && is.null(a$triangle) && identical(a$erreurs, motif520("1")) &&
             !b$ok && is.null(b$triangle) && identical(b$erreurs, motif520("2")) &&
             identical(engine_lire_triangle(en_texte(c0_520(FALSE)))$erreurs, a$erreurs) &&
             identical(engine_lire_triangle(en_texte(c0_520(TRUE)))$erreurs, b$erreurs) &&
             identical(engine_lire_triangle(c0_520(FALSE, "X1"))$erreurs, a$erreurs) &&
             identical(engine_lire_triangle(c0_520(TRUE, "V2"))$erreurs, b$erreurs)
         })
verifier("Colonne 0 vide (#520) : colonne vide sans en-tete entre i et j0 refusee (accepte par #483), triangle 8 x 8 complet decale sans i refuse",
         {
           identical(engine_lire_triangle(col_vide(tri483, 1, "V2"))$erreurs, motif520("2")) &&
             identical(engine_lire_triangle(vides520(tri520[, -1], 0, 1))$erreurs, motif520("1"))
         })
verifier("Colonne 0 vide (#520) : deux colonnes vides sans en-tete a gauche refusees et citees, sans i (1, 2) et avec i (2, 3) ; colonne avant i seule non citee",
         {
           identical(engine_lire_triangle(vides520(tri520[, -1], 0, 2))$erreurs, motif520("1, 2")) &&
             identical(engine_lire_triangle(vides520(tri520, 1, 2))$erreurs, motif520("2, 3")) &&
             identical(engine_lire_triangle(vides520(vides520(tri520, 1, 1), 0, 1))$erreurs, motif520("3"))
         })
verifier("Colonne 0 vide (#520) : colonne vide avant i retiree sans message ; colonne 0 vide portant un en-tete refusee par LE-06 inchange, sans le motif de #520",
         {
           r0 <- engine_lire_triangle(tri520)
           e_i <- engine_lire_triangle(c0_520(TRUE, "j0"))$erreurs
           e_s <- engine_lire_triangle(c0_520(FALSE, "j0"))$erreurs
           isTRUE(r0$ok) && identical(engine_lire_triangle(vides520(tri520, 0, 1)), r0) &&
             identical(e_i, paste("Colonne(s) vide(s) portant un en-tete dans le triangle (colonne(s) 2,",
                                  "d'en-tete(s) j0) : annee de developpement sans valeur ; la renseigner",
                                  "ou retirer la colonne.")) &&
             identical(e_s, sub("colonne(s) 2,", "colonne(s) 1,", e_i, fixed = TRUE))
         })
# Precision (B) d'actuary sur R-a : seule une colonne placee avant une
# colonne i qui precede elle-meme les donnees est retiree sans message ; i en
# fin de tableau ne protege aucune colonne vide de gauche.
verifier("Colonne 0 vide (#520, precision (B)) : i en fin de tableau, colonne 0 vide sans en-tete (\"\", j1..j7, i) refusee colonne 1, au lieu de \"Triangle non carre\"",
         {
           d <- c0_520(TRUE); d <- d[, c(2:9, 1)]
           identical(names(d), c("", paste0("j", 1:7), "i")) &&
             identical(engine_lire_triangle(d)$erreurs, motif520("1"))
         })
verifier("Colonne 0 vide (#520, precision (B)) : 8 x 8 complet, i en fin, colonne vide a gauche refusee (colonne 1)",
         identical(engine_lire_triangle(vides520(tri520[, c(2:9, 1)], 0, 1))$erreurs, motif520("1")))
verifier("Colonne 0 vide (#520, precision (B)) : colonne vide a gauche, i entre j6 et j7 (\"\", j0..j6, i, j7) refusee (colonne 1)",
         {
           d <- vides520(tri520[, c(2:8, 1, 9)], 0, 1)
           identical(names(d), c("", paste0("j", 0:6), "i", "j7")) &&
             identical(engine_lire_triangle(d)$erreurs, motif520("1"))
         })
verifier("Colonne 0 vide (#520) : vrai triangle non carre (colonne j7 absente) garde le motif \"Triangle non carre\"",
         {
           e <- engine_lire_triangle(tri520[, -9])$erreurs
           length(e) == 1L && startsWith(e, "Triangle non carre (8 annees d'accident, 7 annees de developpement)")
         })
verifier("Colonnes vides (#483) : triangle, colonne vide intercalee refusee (annee de developpement manquante), en-tete ou non",
         {
           a <- engine_lire_triangle(col_vide(tri483, 3, "X4"))
           b <- engine_lire_triangle(col_vide(tri483, 3, "j9"))
           !a$ok && contient(a$erreurs, "Colonne(s) vide(s) intercalee(s) dans le triangle (colonne(s) 4)") &&
             contient(a$erreurs, "annee de developpement manquante presumee") && identical(b$erreurs, a$erreurs)
         })
verifier("Colonnes vides (#483) : triangle, colonne vide en bord portant un en-tete refusee, en-tete cite",
         {
           r <- engine_lire_triangle(col_vide(tri483, 7, "j6"))
           !r$ok && contient(r$erreurs, "Colonne(s) vide(s) portant un en-tete dans le triangle (colonne(s) 8, d'en-tete(s) j6)")
         })
# Reserve de la revue de #483 : "X<n>" / "V<n>" n'est un en-tete genere qu'a
# sa position n. Un triangle CSV a en-tetes "0" a "6", colonne "6" vide, lu
# par read.csv avec check.names = TRUE ("X6" en 8e colonne), etait retire sans
# message alors que le meme tableau en xlsx (en-tete "6") etait refuse.
verifier("Colonnes vides (#483) : en-tete \"X<n>\" hors de sa position (en-tete \"6\" lu \"X6\" par read.csv) refuse comme en-tete reel, comme en xlsx",
         {
           d <- col_vide(tri483, 7, "6"); names(d) <- c("i", 0:5, "6")
           f <- tempfile(fileext = ".csv")
           utils::write.csv(d, f, row.names = FALSE, na = "")
           a <- utils::read.csv(f, stringsAsFactors = FALSE)          # check.names = TRUE
           b <- utils::read.csv(f, colClasses = "character", blank.lines.skip = FALSE,
                                check.names = FALSE, na.strings = character(0))
           unlink(f)
           ra <- engine_lire_triangle(a); rb <- engine_lire_triangle(b); rd <- engine_lire_triangle(d)
           identical(names(a)[8], "X6") && identical(names(b)[8], "6") &&
             !ra$ok && contient(ra$erreurs, "Colonne(s) vide(s) portant un en-tete dans le triangle (colonne(s) 8, d'en-tete(s) X6)") &&
             !rb$ok && identical(rb$erreurs, rd$erreurs) &&
             contient(rd$erreurs, "Colonne(s) vide(s) portant un en-tete dans le triangle (colonne(s) 8, d'en-tete(s) 6)") &&
             identical(.entete_absent(c("X1", "V2", "X2", "V1", "X", "X.1", "", NA)),
                       c(TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE))
         })
# En-tetes non UTF-8 (#483, avec #99) : un CSV lu en texte avec
# check.names = FALSE (application) garde un en-tete Windows-1252 ou les
# octets d'un fichier binaire ; les motifs qui le citent restent de l'UTF-8
# valide en locale UTF-8 (en-tete declare Latin-1, octets inchanges), sans
# avertissement R. Hors locale UTF-8, comportement inchange (non verifie ici).
if (isTRUE(l10n_info()[["UTF-8"]])) {
  e1252_483 <- rawToChar(c(charToRaw("ann"), as.raw(0xe9), charToRaw("e")))
  sans_car_483 <- rawToChar(as.raw(c(0x61, 0x81, 0x62)))
  avert483 <- function(expr) {
    w <- character(0)
    v <- withCallingHandlers(expr, warning = function(x) {
      w <<- c(w, conditionMessage(x)); invokeRestart("muffleWarning") })
    list(v = v, w = w)
  }
  verifier("En-tetes non UTF-8 (#483, #99) : motifs \"Colonnes presentes\" et \"portant un en-tete\" en UTF-8 valide, en-tete Windows-1252 cite \"annee\" accentue, sans avertissement",
           {
             d <- data.frame(a = c("1", "2"), b = c("3", "4"), stringsAsFactors = FALSE)
             names(d) <- c(e1252_483, "primes")
             s1 <- avert483(engine_lire_donnees_csv(d))
             tri <- en_texte(col_vide(tri483, 7, sans_car_483)); names(tri)[8] <- e1252_483
             s2 <- avert483(engine_lire_triangle(tri))
             tri[2, 8] <- "x"; names(tri)[8] <- sans_car_483
             s3 <- avert483(engine_lire_triangle(tri))
             !s1$v$ok && validUTF8(s1$v$erreurs) &&
               contient(s1$v$erreurs, "Colonnes presentes : année, primes.") &&
               !s2$v$ok && validUTF8(s2$v$erreurs) &&
               contient(s2$v$erreurs, "(colonne(s) 8, d'en-tete(s) année)") &&
               !s3$v$ok && validUTF8(s3$v$erreurs) && contient(s3$v$erreurs, "Cellule(s) non numerique(s)") &&
               !length(c(s1$w, s2$w, s3$w))
           })
  verifier("En-tetes non UTF-8 (#483) : triangle accepte a en-tete de developpement \"a<81>b\", lu comme l'application, sans avertissement et identique au triangle a en-tetes ASCII",
           {
             f <- tempfile(fileext = ".csv")
             d <- tri483; names(d)[4] <- "ZZ"
             utils::write.csv(d, f, row.names = FALSE, na = "")
             l <- readLines(f); l[1] <- sub("\"ZZ\"", sans_car_483, l[1], fixed = TRUE, useBytes = TRUE)
             writeLines(l, f, useBytes = TRUE)
             lu <- utils::read.csv(f, colClasses = "character", blank.lines.skip = FALSE,
                                   check.names = FALSE, na.strings = character(0))
             unlink(f)
             s4 <- avert483(engine_lire_triangle(lu))
             !validUTF8(names(lu)[4]) && isTRUE(s4$v$ok) && !length(s4$w) &&
               isTRUE(all.equal(s4$v$triangle, engine_lire_triangle(tri483)$triangle, tolerance = 1e-15))
           })
}
# Cellule texte "NA" (#483, decision par defaut de la session, soumise au
# mainteneur) : toujours refusee (alignee sur xlsx, na.strings =
# character(0)), le motif le dit par une phrase fixe ; absente sans "NA".
verifier("Cellule texte \"NA\" (#483) : refus motive par une phrase fixe, series et triangle ; phrase absente pour une autre cellule non numerique",
         {
           s_na <- engine_lire_donnees_csv(data.frame(xt = c("100", " NA ", "102", "103", "104"),
                                                      yt = c("60", "61", "62", "63", "64"), stringsAsFactors = FALSE))
           s_x <- engine_lire_donnees_csv(data.frame(xt = c("100", "x", "102", "103", "104"),
                                                     yt = c("60", "61", "62", "63", "64"), stringsAsFactors = FALSE))
           t_txt <- en_texte(tri483); t_txt$j2[2] <- "NA"
           t_x <- en_texte(tri483); t_x$j2[2] <- "x"
           r_na <- engine_lire_triangle(t_txt); r_x <- engine_lire_triangle(t_x)
           identical(s_na$erreurs, paste("Certaines valeurs des colonnes xt ou yt ne sont pas numeriques (colonne xt : ligne(s) de donnees 2).",
                                         "Une cellule \"NA\" est lue comme du texte, non comme une valeur manquante : renseigner la valeur.")) &&
             identical(s_x$erreurs, "Certaines valeurs des colonnes xt ou yt ne sont pas numeriques (colonne xt : ligne(s) de donnees 2).") &&
             identical(r_na$erreurs, paste("Cellule(s) non numerique(s) en (i = 1, j = 2) (i : annee d'accident, j : annee de developpement).",
                                           "Une cellule \"NA\" est lue comme du texte : renseigner la valeur, ou laisser vide une cellule non observee.")) &&
             identical(r_x$erreurs, "Cellule(s) non numerique(s) en (i = 1, j = 2) (i : annee d'accident, j : annee de developpement).")
         })
# Issue #527, groupe lecteurs (LE-06, LE-07, LE-13) : texte complet de chaque
# motif change, sur le gabarit du tableau du par. 7.2 de l'avis amont
# d'actuary, par appel reel du lecteur (engine_lire_donnees_csv(),
# engine_lire_triangle()) sur un tableau lu en texte, comme a l'import.
ser_527 <- data.frame(t = as.character(2015:2022),
                      xt = as.character(c(100, 110, 125, 130, 145, 150, 165, 170)),
                      yt = as.character(c(70, 80, 85, 95, 100, 102, 120, 118)),
                      stringsAsFactors = FALSE)
tri_527 <- local({
  d <- as.data.frame(tri_usage); names(d) <- as.character(0:7)
  d[] <- lapply(d, function(v) ifelse(is.na(v), "", as.character(v)))
  cbind(i = as.character(0:7), d, stringsAsFactors = FALSE)
})
PHRASE_NA_SERIE_527 <- paste("Une cellule \"NA\" est lue comme du texte, non comme une valeur",
                             "manquante : renseigner la valeur.")
PHRASE_NA_TRI_527 <- paste("Une cellule \"NA\" est lue comme du texte : renseigner la valeur, ou",
                           "laisser vide une cellule non observee.")
verifier("engine_lire_triangle : LE-06, une puis deux colonnes vides a en-tete au bord -> textes complets (#527)",
         {
           d1 <- tri_527; d1[["7"]] <- ""
           d2 <- tri_527; d2[["8"]] <- ""; d2[["9"]] <- ""
           identical(engine_lire_triangle(d1)$erreurs,
                     paste("Colonne(s) vide(s) portant un en-tete dans le triangle (colonne(s) 9,",
                           "d'en-tete(s) 7) : annee de developpement sans valeur ; la renseigner ou",
                           "retirer la colonne.")) &&
             identical(engine_lire_triangle(d2)$erreurs,
                       paste("Colonne(s) vide(s) portant un en-tete dans le triangle (colonne(s) 10, 11,",
                             "d'en-tete(s) 8, 9) : annee de developpement sans valeur ; la renseigner ou",
                             "retirer la colonne."))
         })
# #550 (O2) : la liste des en-tetes de LE-06 est coupee a cinq par liste(),
# comme celle des numeros de colonne, et le reste est dit (" et N autre(s)") ;
# chaque en-tete est echappe par .echapper_texte() (tabulation -> \t, espace
# insecable -> \u00a0). Six colonnes vides a en-tete : "10, 11, 12, 13, 14 et
# 1 autre(s)" deux fois ; sept : "et 2 autre(s)" deux fois.
verifier("engine_lire_triangle : LE-06, six puis sept colonnes vides a en-tete au bord -> les deux listes signalent le reste ; en-tetes echappes (#550)",
         {
           ajoute <- function(noms) {
             d <- tri_527
             for (n in noms) d[[n]] <- ""
             d
           }
           suite <- function(col, ent) paste0("Colonne(s) vide(s) portant un en-tete dans le triangle (colonne(s) ",
                                              col, ", d'en-tete(s) ", ent, ") : annee de developpement sans valeur ; ",
                                              "la renseigner ou retirer la colonne.")
           plain <- paste0("vide", 1:5)
           e6 <- engine_lire_triangle(ajoute(c(plain, "vide6")))$erreurs
           e7 <- engine_lire_triangle(ajoute(c(plain, "vide6", "vide7")))$erreurs
           ec <- engine_lire_triangle(ajoute(c("vide1", "v\tide2", paste0("vide3", intToUtf8(0xA0)),
                                               "vide4", "vide5", "vide6")))$erreurs
           identical(e6, suite("10, 11, 12, 13, 14 et 1 autre(s)", "vide1, vide2, vide3, vide4, vide5 et 1 autre(s)")) &&
             identical(e7, suite("10, 11, 12, 13, 14 et 2 autre(s)", "vide1, vide2, vide3, vide4, vide5 et 2 autre(s)")) &&
             identical(ec, suite("10, 11, 12, 13, 14 et 1 autre(s)",
                                 "vide1, v\\tide2, vide3\\u00a0, vide4, vide5 et 1 autre(s)"))
         })
verifier("engine_lire_donnees_csv : LE-07, une colonne, puis deux colonnes a plus de cinq cellules et cellule \"NA\" -> textes complets (#527)",
         {
           s1 <- ser_527; s1$xt[3] <- "abc"
           s2 <- ser_527; s2$xt[c(1, 2, 3, 5, 6, 7, 8)] <- "x"; s2$yt[4] <- "NA"
           identical(engine_lire_donnees_csv(s1)$erreurs,
                     paste("Certaines valeurs des colonnes xt ou yt ne sont pas numeriques (colonne xt :",
                           "ligne(s) de donnees 3).")) &&
             identical(engine_lire_donnees_csv(s2)$erreurs,
                       paste("Certaines valeurs des colonnes xt ou yt ne sont pas numeriques (colonne xt :",
                             "ligne(s) de donnees 1, 2, 3, 5, 6 et 2 autre(s) ; colonne yt : ligne(s) de",
                             "donnees 4).", PHRASE_NA_SERIE_527))
         })
verifier("engine_lire_triangle : LE-13, une cellule, puis sept cellules dont une \"NA\" -> textes complets (#527)",
         {
           d1 <- tri_527; d1[2, "3"] <- "xyz"
           d2 <- tri_527; d2[2, "3"] <- "a"; d2[3, "0"] <- "b"; d2[1, "5"] <- "c"; d2[4, "1"] <- "d"
           d2[5, "2"] <- "e"; d2[6, "1"] <- "f"; d2[3, "4"] <- "NA"
           identical(engine_lire_triangle(d1)$erreurs,
                     paste("Cellule(s) non numerique(s) en (i = 1, j = 3) (i : annee d'accident, j :",
                           "annee de developpement).")) &&
             identical(engine_lire_triangle(d2)$erreurs,
                       paste("Cellule(s) non numerique(s) en (i = 2, j = 0), (i = 3, j = 1), (i = 5, j = 1),",
                             "(i = 4, j = 2), (i = 1, j = 3) et 2 autre(s) (i : annee d'accident, j : annee",
                             "de developpement).", PHRASE_NA_TRI_527))
         })
# Issue #527, avertissements (AV-01, AV-03, AV-08) : texte complet de chaque
# avertissement change, sur le gabarit du tableau du par. 7.2 de l'avis amont
# d'actuary, par run_engine() reel (ok = TRUE, avertissement non bloquant) ;
# AV-08 aussi par engine_lire_triangle(), qui le rend dans
# avertissements_lecture (meme texte, #518).
avert_527 <- function(r, debut) grep(debut, r$validation$avertissements, fixed = TRUE, value = TRUE)
ln_527 <- function(xx, yy) run_engine(xt = xx, yt = yy, methode = "premium", segment = 1,
                                      B = B_MIN_USAGE, nature_donnees = "brutes")
SUITE_AV08_527 <- paste("(i : annee d'accident, j : annee de developpement) : hors de la partie",
                        "observee du triangle, ces cellules ne sont ni lues par le calcul, ni",
                        "restituees dans son resultat, ni comptees parmi les cellules observees ;",
                        "verifier qu'il ne s'agit pas de valeurs projetees.")
verifier("run_engine : AV-01, ratio y_t/x_t hors de la plage plausible -> texte complet, calcul fait (#527)",
         {
           r <- ln_527(x, y * 1000)
           isTRUE(r$ok) && identical(avert_527(r, "Ratio"),
                                     "Ratio y_t/x_t hors de la plage plausible [0.1 ; 5[ : verifier les unites.")
         })
verifier("run_engine : AV-03, couples dupliques -> texte complet, calcul fait (#527)",
         {
           r <- ln_527(c(x, x[1]), c(y, y[1]))
           isTRUE(r$ok) && identical(avert_527(r, "Couples"), "Couples (x_t, y_t) dupliques detectes.")
         })
verifier("run_engine reserve2 et engine_lire_triangle : AV-08, une cellule puis sept cellules sous la diagonale -> texte complet, meme texte sur les deux chemins (#527)",
         {
           t1 <- tri_usage; t1[8, 8] <- 5
           t7 <- tri_usage
           for (k in list(c(2, 8), c(3, 7), c(3, 8), c(4, 6), c(4, 7), c(5, 5), c(8, 2))) t7[k[1], k[2]] <- 5
           a1 <- paste("Cellule(s) renseignee(s) sous la diagonale (i + j > I) en (i = 7, j = 7)",
                       SUITE_AV08_527)
           a7 <- paste("Cellule(s) renseignee(s) sous la diagonale (i + j > I) en (i = 1, j = 7),",
                       "(i = 2, j = 6), (i = 2, j = 7), (i = 3, j = 5), (i = 3, j = 6) et 2 autre(s)",
                       SUITE_AV08_527)
           en_df <- function(t) {
             d <- as.data.frame(t); names(d) <- as.character(0:7)
             d[] <- lapply(d, function(v) ifelse(is.na(v), "", as.character(v)))
             cbind(i = as.character(0:7), d, stringsAsFactors = FALSE)
           }
           r1 <- run_engine(methode = "reserve2", triangle = t1, segment = 1, B = B_MIN_USAGE)
           r7 <- run_engine(methode = "reserve2", triangle = t7, segment = 1, B = B_MIN_USAGE)
           isTRUE(r1$ok) && isTRUE(r7$ok) &&
             identical(avert_527(r1, "sous la diagonale"), a1) &&
             identical(avert_527(r7, "sous la diagonale"), a7) &&
             identical(engine_lire_triangle(en_df(t1))$avertissements_lecture, a1) &&
             identical(engine_lire_triangle(en_df(t7))$avertissements_lecture, a7)
         })
verifier("engine_lire_triangle : colonnes de nom duplique toutes gardees (selection par position, #483)",
         {
           d <- fichier_tri(t5); names(d) <- c("i", rep("j", 5))
           r <- engine_lire_triangle(d)
           isTRUE(r$ok) && identical(r$triangle, t5)
         })
# Les deux chemins de engine_lire_xlsx() : openxlsx s'il est installe, et le
# lecteur interne force (requireNamespace simule dans l'environnement du
# moteur). Classeurs ecrits par l'ecrivain interne (commande zip), puis
# retouches dans leur XML (decalage de colonnes, cellules mises en forme sans
# valeur <c r=... s=.../>).
if (nzchar(Sys.which("zip"))) {
  env483 <- environment(run_engine)
  sans_openxlsx483 <- function(expr) {
    assign("requireNamespace", function(package, ...) FALSE, envir = env483)
    on.exit(rm("requireNamespace", envir = env483), add = TRUE)
    force(expr)
  }
  avec_openxlsx483 <- requireNamespace("openxlsx", quietly = TRUE)
  if (!avec_openxlsx483) cat("  [saute] lignes vides (#483), chemin openxlsx : paquet non installe\n")
  # retouche : fonction appliquee au XML de la feuille (une chaine)
  xlsx483 <- function(d, retouche = identity) {
    f <- tempfile(fileext = ".xlsx")
    sans_openxlsx483(engine_ecrire_xlsx(d, f))
    x <- tempfile("x483_"); on.exit(unlink(x, recursive = TRUE), add = TRUE)
    utils::unzip(f, exdir = x)
    fs <- file.path(x, "xl", "worksheets", "sheet1.xml")
    writeLines(retouche(paste(readLines(fs, warn = FALSE), collapse = "")), fs, useBytes = TRUE)
    unlink(f); od <- setwd(x); on.exit(setwd(od), add = TRUE, after = FALSE)
    utils::zip(f, c("[Content_Types].xml", "_rels", "xl"), flags = "-r9Xq")
    f
  }
  # Decale d'une colonne vers la droite les cellules de colonne >= de
  # (lettres A a Y).
  decaler <- function(de = "A") function(s) {
    m <- gregexpr('r="[A-Z][0-9]+"', s)[[1]]
    regmatches(s, list(m)) <- list(vapply(regmatches(s, list(m))[[1]], function(r) {
      l <- substr(r, 4, 4)
      if (l >= de) sub(l, LETTERS[match(l, LETTERS) + 1L], r, fixed = TRUE) else r
    }, character(1)))
    s
  }
  # Cellules mises en forme sans valeur (<c r=... s="0"/>) : une colonne de fin
  # col sur chaque ligne, et deux lignes de fin apres la ligne nl.
  formes_fin <- function(col, nl) function(s) {
    s <- gsub('(<row r="([0-9]+)">.*?)</row>', paste0('\\1<c r="', col, '\\2" s="0"/></row>'), s, perl = TRUE)
    lignes <- paste0(vapply(nl + 1:2, function(i) sprintf('<row r="%d"><c r="A%d" s="0"/><c r="%s%d" s="0"/></row>',
                                                          i, i, col, i), character(1)), collapse = "")
    sub("</sheetData>", paste0(lignes, "</sheetData>"), s, fixed = TRUE)
  }
  chemins483 <- function(f, lire) {
    # f (appel de xlsx483(), qui pose et retire lui-meme la substitution) est
    # evalue ici, hors de sans_openxlsx483() : evaluee a l'interieur, la
    # promesse retirait la substitution exterieure avant son on.exit(rm())
    # (avertissement "object 'requireNamespace' not found", constat 5 de
    # la revue finale de K1).
    force(f)
    out <- list(interne = lire(sans_openxlsx483(engine_lire_xlsx(f))))
    if (avec_openxlsx483) out$openxlsx <- lire(engine_lire_xlsx(f))
    unlink(f)
    out
  }
  tous <- function(rs, test) all(vapply(rs, test, logical(1)))
  ref_ser <- engine_lire_donnees_csv(ser483); ref_tri <- engine_lire_triangle(tri483)
  r7 <- chemins483(xlsx483(avec_vide(ser483, 4)), engine_lire_donnees_csv)
  r8 <- chemins483(xlsx483(rbind(ser483, NA, NA)), engine_lire_donnees_csv)
  rt <- chemins483(xlsx483(data.frame(t = c(2003, 2001, 2002, 2004:2009), xt = xt483, yt = yt483)),
                   engine_lire_donnees_csv)
  rforme <- chemins483(xlsx483(ser483, formes_fin("D", 10)), engine_lire_donnees_csv)
  rsdec <- chemins483(xlsx483(ser483, decaler("A")), engine_lire_donnees_csv)
  rv <- chemins483(xlsx483(avec_vide(tri483, 4)), engine_lire_triangle)
  rf <- chemins483(xlsx483(rbind(tri483, NA)), engine_lire_triangle)
  rtdec <- chemins483(xlsx483(tri483, decaler("A")), engine_lire_triangle)
  rtforme <- chemins483(xlsx483(tri483, formes_fin("J", 7)), engine_lire_triangle)
  rtinter <- chemins483(xlsx483(tri483, decaler("D")), engine_lire_triangle)
  rna <- chemins483(xlsx483(within(tri483, { j5 <- as.character(j5); j5[2] <- "NA" })), engine_lire_triangle)
  d6_483 <- col_vide(tri483, 7, "6"); names(d6_483) <- c("i", 0:5, "6")
  r6 <- chemins483(xlsx483(d6_483), engine_lire_triangle)
  verifier("Lignes vides (#483) : xlsx sans t a ligne vide intercalee (cas t7) refuse, meme motif sur chaque chemin",
           tous(r7, function(r) !r$ok && identical(r$erreurs,
                engine_lire_donnees_csv(avec_vide(ser483, 4))$erreurs)))
  verifier("Lignes vides (#483) : xlsx a lignes vides de fin accepte, series identiques sur chaque chemin",
           tous(r8, function(r) identical(r, ref_ser)))
  verifier("Lignes vides (#483) : xlsx avec colonne t lu et trie a l'identique sur chaque chemin",
           tous(rt, function(r) isTRUE(r$ok) && identical(r$xt, c(101, 102, 100, 103:108))))
  verifier("Lignes et colonnes vides (#483) : xlsx de series a lignes et colonne de fin mises en forme sans valeur, accepte sur chaque chemin",
           tous(rforme, function(r) identical(r, ref_ser)))
  verifier("Colonnes vides (#483) : xlsx de series decale en colonne B, accepte sur chaque chemin",
           tous(rsdec, function(r) identical(r, ref_ser)))
  verifier("Lignes vides (#483) : xlsx de triangle a ligne vide intercalee refuse, meme motif sur chaque chemin ; lignes vides de fin retirees",
           tous(rv, function(r) !r$ok && identical(r$erreurs,
                engine_lire_triangle(avec_vide(tri483, 4))$erreurs)) &&
             tous(rf, function(r) identical(r, ref_tri)))
  # Temoin de #520 (precision (B)) : colonne A vide avant i en colonne B, i
  # precedant les donnees : toujours retiree sans message.
  verifier("Colonnes vides (#483, #520) : xlsx de triangle decale en colonne B (i en B), accepte a l'identique sur chaque chemin",
           tous(rtdec, function(r) identical(r, ref_tri)))
  # Issue #520 : memes motifs que le CSV lu en texte, sur chaque chemin. Un
  # triangle sans i decale en colonne B a les cellules d'un 8 x 8 a colonne 0
  # vide sans en-tete (mesure M1) : refuse.
  r520s <- chemins483(xlsx483(tri520[, 3:9], decaler("A")), engine_lire_triangle)
  r520i <- chemins483(xlsx483(tri520[, -2], decaler("B")), engine_lire_triangle)
  r520d <- chemins483(xlsx483(tri520[, 3:9], function(s) decaler("A")(decaler("A")(s))), engine_lire_triangle)
  r520e <- chemins483(xlsx483(c0_520(TRUE, "j0")), engine_lire_triangle)
  verifier("Colonne 0 vide (#520) : xlsx de triangle 8 x 8 a colonne 0 vide sans en-tete refuse sur chaque chemin, sans i (colonne A) et avec i (colonne B), motif du CSV",
           tous(r520s, function(r) !r$ok && identical(r$erreurs, engine_lire_triangle(c0_520(FALSE))$erreurs)) &&
             tous(r520i, function(r) !r$ok && identical(r$erreurs, engine_lire_triangle(c0_520(TRUE))$erreurs)))
  verifier("Colonne 0 vide (#520) : xlsx a deux colonnes vides a gauche sans i refuse sur chaque chemin (colonnes 1, 2)",
           tous(r520d, function(r) !r$ok && identical(r$erreurs, motif520("1, 2"))))
  verifier("Colonne 0 vide (#520) : xlsx a colonne 0 vide portant l'en-tete j0 refuse par LE-06 sur chaque chemin, motif du CSV",
           tous(r520e, function(r) !r$ok && identical(r$erreurs, engine_lire_triangle(c0_520(TRUE, "j0"))$erreurs)))
  verifier("Lignes et colonnes vides (#483) : xlsx de triangle a lignes et colonne de fin mises en forme sans valeur, accepte sur chaque chemin",
           tous(rtforme, function(r) identical(r, ref_tri)))
  verifier("Colonnes vides (#483) : xlsx de triangle a colonne vide intercalee refuse, meme motif sur chaque chemin",
           tous(rtinter, function(r) !r$ok &&
                identical(r$erreurs, engine_lire_triangle(col_vide(tri483, 3, "X4"))$erreurs)))
  verifier("Colonnes vides (#483) : xlsx de triangle a colonne de fin vide d'en-tete \"6\" refuse sur chaque chemin, meme motif que le CSV lu en texte",
           tous(r6, function(r) !r$ok && identical(r$erreurs, engine_lire_triangle(d6_483)$erreurs)))
  verifier("xlsx (#483) : cellule texte \"NA\" lue en chaine sur chaque chemin, refusee avec sa position dans le triangle",
           tous(rna, function(r) !r$ok && contient(r$erreurs, "Cellule(s) non numerique(s) en (i = 1, j = 5)")))
  # Lecteur interne (#490) : seule une colonne de cellules nombre est rendue en
  # numerique ; une cellule texte (inlineStr ecrit par l'ecrivain interne, ou
  # t="str" pose par retouche) garde la colonne en caractere, et "0x10" est
  # refuse en aval par .cellules_en_nombre() avec sa position.
  ser490 <- data.frame(xt = c("100", "0x10", "102", "103", "104"), yt = 60:64, stringsAsFactors = FALSE)
  motif490 <- "Certaines valeurs des colonnes xt ou yt ne sont pas numeriques (colonne xt : ligne(s) de donnees 2)."
  d490 <- chemins483(xlsx483(ser490), identity)
  str490 <- function(s) {
    s <- sub('<c r="A3"><v>101</v></c>', '<c r="A3" t="str"><v>0x10</v></c>', s, fixed = TRUE)
    sub('<c r="B2"><v>60</v></c>', '<c r="B2" t="n"><v>60</v></c>', s, fixed = TRUE)
  }
  dstr490 <- chemins483(xlsx483(data.frame(xt = 100:104, yt = 60:64), str490), identity)
  dinf490 <- chemins483(xlsx483(data.frame(xt = c(100, Inf, 102), yt = c(60, 61, -Inf))), identity)
  verifier("xlsx, lecteur interne (#490) : colonne a cellule texte \"0x10\" rendue en caractere, colonne de nombres en numerique",
           identical(d490$interne$xt, ser490$xt) && identical(d490$interne$yt, as.numeric(60:64)))
  verifier("xlsx (#490) : \"0x10\" en cellule texte refuse avec sa position sur chaque chemin, meme motif que le CSV lu en texte",
           tous(d490, function(d) identical(engine_lire_donnees_csv(d)$erreurs, motif490)) &&
             identical(engine_lire_donnees_csv(ser490)$erreurs, motif490))
  verifier("xlsx, lecteur interne (#490) : cellule t=\"str\" \"0x10\" garde sa colonne en caractere, refusee ; cellule t=\"n\" lue en nombre",
           identical(dstr490$interne$xt, c("100", "0x10", "102", "103", "104")) &&
             identical(dstr490$interne$yt, as.numeric(60:64)) &&
             identical(engine_lire_donnees_csv(dstr490$interne)$erreurs, motif490))
  verifier("xlsx, lecteur interne (#490) : +-Inf ecrits en chaine gardent leur colonne en caractere, nombres de la colonne en chaine",
           identical(dinf490$interne$xt, c("100", "Inf", "102")) &&
             identical(dinf490$interne$yt, c("60", "61", "-Inf")))
  # Cellule booleenne t="b" : rendue "TRUE"/"FALSE" (valeur brute 1/0 lue
  # comme un nombre auparavant), refusee en aval sur chaque chemin.
  bool490 <- function(s) sub('<c r="A3"><v>101</v></c>', '<c r="A3" t="b"><v>1</v></c>', s, fixed = TRUE)
  dbool490 <- chemins483(xlsx483(data.frame(xt = 100:104, yt = 60:64), bool490), identity)
  verifier("xlsx, lecteur interne (#490) : cellule booleenne t=\"b\" rendue \"TRUE\", colonne en caractere, refusee sur chaque chemin",
           identical(dbool490$interne$xt, c("100", "TRUE", "102", "103", "104")) &&
             tous(dbool490, function(d) identical(engine_lire_donnees_csv(d)$erreurs,
                  "Certaines valeurs des colonnes xt ou yt ne sont pas numeriques (colonne xt : ligne(s) de donnees 2).")))
  # Cellule nombre forgee <v>0x10</v> : colonne laissee en caractere par le
  # lecteur interne (regle de .cellules_en_nombre()), refusee en aval avec sa
  # position ; exposants complets ("6E+1", "6.1e1") lus en nombre.
  hex490 <- function(s) {
    s <- sub('<c r="A3"><v>101</v></c>', '<c r="A3"><v>0x10</v></c>', s, fixed = TRUE)
    s <- sub('<c r="B2"><v>60</v></c>', '<c r="B2"><v>6E+1</v></c>', s, fixed = TRUE)
    sub('<c r="B3"><v>61</v></c>', '<c r="B3"><v>6.1e1</v></c>', s, fixed = TRUE)
  }
  dhex490 <- chemins483(xlsx483(data.frame(xt = 100:104, yt = 60:64), hex490), identity)
  verifier("xlsx, lecteur interne (#490) : cellule nombre forgee \"0x10\" garde sa colonne en caractere, refusee avec sa position ; exposants complets lus en nombre",
           identical(dhex490$interne$xt, c("100", "0x10", "102", "103", "104")) &&
             identical(dhex490$interne$yt, as.numeric(60:64)) &&
             identical(engine_lire_donnees_csv(dhex490$interne)$erreurs, motif490))

  # --- #487 : feuille lue, entites XML, chaine enrichie, cellule sans r, blancs
  # d'en-tete. Classeurs ecrits a la main (plusieurs feuilles, workbook.xml et
  # rels), lus par les deux chemins ; les parites avec openxlsx ne tournent
  # qu'avec le paquet installe (sautees sinon, comme celles de #483).
  classeur487 <- function(feuilles, shared = NULL, avant = "") {
    d <- tempfile("c487_"); dir.create(d)
    on.exit(unlink(d, recursive = TRUE), add = TRUE)
    ecrire <- function(rel, txt) {
      p <- file.path(d, rel); dir.create(dirname(p), recursive = TRUE, showWarnings = FALSE)
      writeLines(txt, p, useBytes = TRUE)
    }
    h <- '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    ns <- 'xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"'
    rt <- 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
    rid <- seq_along(feuilles) + 10L
    ecrire("[Content_Types].xml", paste0(h, '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">',
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>',
      '<Default Extension="xml" ContentType="application/xml"/></Types>'))
    ecrire("_rels/.rels", paste0(h, '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
      '<Relationship Id="rId1" Type="', rt, '/officeDocument" Target="xl/workbook.xml"/></Relationships>'))
    ecrire("xl/workbook.xml", paste0(h, '<workbook ', ns, ' xmlns:r="', rt, '"><sheets>',
      paste(sprintf('<sheet name="%s" sheetId="%d" r:id="rId%d"/>',
                    vapply(feuilles, `[[`, "", "nom"), seq_along(feuilles), rid), collapse = ""),
      '</sheets></workbook>'))
    ecrire("xl/_rels/workbook.xml.rels", paste0(h, '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
      paste(sprintf('<Relationship Id="rId%d" Type="%s/worksheet" Target="%s"/>',
                    rid, rt, vapply(feuilles, function(fe)
                      if (is.null(fe$cible)) paste0("worksheets/", fe$fichier) else fe$cible, "")), collapse = ""),
      if (!is.null(shared)) paste0('<Relationship Id="rId99" Type="', rt, '/sharedStrings" Target="sharedStrings.xml"/>'),
      '</Relationships>'))
    for (fe in feuilles)
      if (!isTRUE(fe$absente))
        ecrire(file.path("xl", "worksheets", fe$fichier),
               paste0(h, '<worksheet ', ns, '>', avant, '<sheetData>', fe$xml, '</sheetData></worksheet>'))
    if (!is.null(shared)) ecrire("xl/sharedStrings.xml", paste0(h, '<sst ', ns, '>', shared, '</sst>'))
    f <- tempfile(fileext = ".xlsx")
    od <- setwd(d); on.exit(setwd(od), add = TRUE, after = FALSE)
    utils::zip(f, c("[Content_Types].xml", "_rels", "xl"), flags = "-r9Xq")
    f
  }
  # tous() sur une liste complete : un chemin qui rend NULL (element supprime
  # par l'affectation dans chemins483()) ne passe pas inapercu
  tous487 <- function(r, test) length(r) == 1L + avec_openxlsx483 && tous(r, test)
  ligne487 <- function(i, cellules) sprintf('<row r="%d">%s</row>', i, paste(cellules, collapse = ""))
  nb487 <- function(ref, v) sprintf('<c r="%s"><v>%s</v></c>', ref, v)
  en487 <- function(ref, t) sprintf('<c r="%s" t="inlineStr"><is>%s</is></c>', ref, t)
  ps487 <- function(ref, k) sprintf('<c r="%s" t="s"><v>%d</v></c>', ref, k)   # chaine partagee k (base 0)
  # feuille de series t, xt, yt dont xt vaut base + 1 et base + 3
  donnees487 <- function(base) paste0(
    ligne487(1, c(en487("A1", "<t>t</t>"), en487("B1", "<t>xt</t>"), en487("C1", "<t>yt</t>"))),
    ligne487(2, c(nb487("A2", 2001), nb487("B2", base + 1), nb487("C2", base + 2))),
    ligne487(3, c(nb487("A3", 2002), nb487("B3", base + 3), nb487("C3", base + 4))))
  # lecture qui rend le message du refus au lieu de lever l'erreur (la promesse
  # est forcee dans tryCatch)
  lire487 <- function(d) tryCatch(d, error = function(e) conditionMessage(e))
  premier487 <- function(r) vapply(r, function(d) as.numeric(d$xt[1]), numeric(1))
  base487 <- function(r, b) tous487(r, function(d) is.data.frame(d) && identical(names(d), c("t", "xt", "yt")) &&
                                                  identical(as.numeric(d$xt), b + c(1, 3)))
  CELLULE_SANS_R <- "Classeur illisible : cellule sans reference de position (attribut r) dans la feuille lue ; l'outil ne deduit pas sa position. Enregistrer de nouveau le classeur depuis un tableur."
  # Feuille : la premiere du classeur (xl/workbook.xml), non le premier fichier
  rA <- chemins483(classeur487(list(list(nom = "Donnees", fichier = "sheet2.xml", xml = donnees487(200)),
                                    list(nom = "Brouillon", fichier = "sheet1.xml", xml = donnees487(100)))), lire487)
  rB <- chemins483(classeur487(list(list(nom = "Donnees", fichier = "sheet2.xml", xml = donnees487(200)),
                                    list(nom = "Autre", fichier = "sheet10.xml", xml = donnees487(100)))), lire487)
  rC <- chemins483(classeur487(list(list(nom = "Donnees", fichier = "sheet10.xml", xml = donnees487(200)),
                                    list(nom = "Autre", fichier = "sheet2.xml", xml = donnees487(100)))), lire487)
  rD <- chemins483(classeur487(lapply(11:1, function(k) list(nom = paste0("F", k), fichier = sprintf("sheet%d.xml", k),
                                                            xml = donnees487(1000 * k)))), lire487)
  verifier("xlsx (#487) : donnees en sheet2.xml, premiere feuille du classeur, devant sheet1.xml : feuille du classeur lue sur chaque chemin (xt = 201)",
           base487(rA, 200))
  verifier("xlsx (#487) : sheet2.xml premiere et sheet10.xml deuxieme, puis l'inverse : feuille du classeur lue sur chaque chemin",
           base487(rB, 200) && base487(rC, 200))
  verifier("xlsx (#487) : onze feuilles en ordre inverse : la premiere du classeur (sheet11.xml) est lue sur chaque chemin (xt = 11001)",
           base487(rD, 11000))
  rS <- chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = donnees487(0), absente = TRUE))), lire487)
  verifier("xlsx (#487) : cible de la premiere feuille absente du classeur : refus \"aucune feuille trouvee\" sur chaque chemin",
           tous487(rS, function(d) identical(d, "Classeur illisible : aucune feuille trouvee.")))
  # Cellule sans attribut r (avec ou sans autres attributs) : refus commun, avant openxlsx
  sans_r <- function(cellule, ...) {
    chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = paste0(
      ligne487(1, c(en487("A1", "<t>t</t>"), en487("B1", "<t>xt</t>"), en487("C1", "<t>yt</t>"))),
      ligne487(2, c(nb487("A2", 2001), cellule, nb487("C2", 6)))))), ...), lire487)
  }
  verifier("xlsx (#487) : cellule <c><v>5</v></c> sans aucun attribut : refus au texte fixe sur chaque chemin (valeur auparavant perdue sans message)",
           tous487(sans_r("<c><v>5</v></c>"), function(d) identical(d, CELLULE_SANS_R)))
  verifier("xlsx (#487) : cellule sans r mais avec d'autres attributs (<c s=\"0\">, <c t=\"n\">, <c s=\"1\"/>) : meme refus sur chaque chemin",
           tous487(sans_r('<c s="0"><v>5</v></c>'), function(d) identical(d, CELLULE_SANS_R)) &&
             tous487(sans_r('<c t="n"><v>5</v></c>'), function(d) identical(d, CELLULE_SANS_R)) &&
             tous487(sans_r('<c s="1"/>'), function(d) identical(d, CELLULE_SANS_R)))
  rcols <- chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = donnees487(0))),
                                  avant = '<cols><col min="1" max="3" width="9" customWidth="1"/></cols>'), lire487)
  verifier("xlsx (#487) : la balise <cols><col .../> d'une feuille n'est pas prise pour une cellule : lecture inchangee sur chaque chemin",
           base487(rcols, 0))
  # Cible de la premiere feuille : un dossier n'est pas une feuille, et une
  # cible qui remonte (".." avec / ou \) n'est pas suivie ; meme refus sur
  # chaque chemin.
  rdos <- chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = donnees487(0),
                                           cible = "worksheets"))), lire487)
  rrem <- chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = donnees487(0),
                                           cible = "..\\..\\x.xml"))), lire487)
  rrem2 <- chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = donnees487(0),
                                            cible = "../../x.xml"))), lire487)
  verifier("xlsx (#487) : cible de la premiere feuille qui est un dossier, ou qui remonte (\"..\\\\..\\\\x.xml\", \"../../x.xml\") : refus \"aucune feuille trouvee\" sur chaque chemin",
           tous487(rdos, function(d) identical(d, "Classeur illisible : aucune feuille trouvee.")) &&
             tous487(rrem, function(d) identical(d, "Classeur illisible : aucune feuille trouvee.")) &&
             tous487(rrem2, function(d) identical(d, "Classeur illisible : aucune feuille trouvee.")))
  # Entree d'archive "../evil487.txt" : utils::unzip() (R 4.3.3, mesure) l'ecrit
  # hors du dossier d'extraction ; le lecteur la refuse avant toute extraction,
  # sur chaque chemin, et rien n'est ecrit hors de son dossier temporaire.
  evil487 <- file.path(tempdir(), "evil487.txt")
  unlink(evil487)
  zslip487 <- function() {
    f <- classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = donnees487(0))))
    w <- tempfile("w487_"); dir.create(file.path(w, "sub"), recursive = TRUE)
    writeLines("x", file.path(w, "evil487.txt"))
    od <- setwd(file.path(w, "sub")); on.exit({ setwd(od); unlink(w, recursive = TRUE) })
    utils::zip(f, "../evil487.txt", flags = "-q")
    f
  }
  rsl <- chemins483(zslip487(), lire487)
  verifier("xlsx (#487) : classeur dont une entree d'archive remonte (\"../evil487.txt\") : refuse sur chaque chemin, aucun fichier ecrit hors du dossier de lecture",
           tous487(rsl, function(d) is.character(d) && grepl("sort du dossier de lecture", d, fixed = TRUE)) &&
             !file.exists(evil487))
  unlink(evil487)
  # Balise <c suivie d'un blanc autre que l'espace (TAB, CR, LF) : refusee d'un
  # texte propre sur chaque chemin, avant openxlsx (qui perd la cellule sans
  # message, ou rend NULL si toutes ont cette forme) ; cas mixte compris.
  BALISE_C <- "Classeur illisible : balise de cellule de forme non reconnue (blanc autre qu'une espace apres \"<c\") dans la feuille lue. Enregistrer de nouveau le classeur depuis un tableur."
  rbl_c <- lapply(c(TAB = "\t", CR = "\r", LF = "\n"), function(bl) list(
    toutes = chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml",
                                              xml = gsub("<c r=", paste0("<c", bl, "r="), donnees487(0), fixed = TRUE)))), lire487),
    une = chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml",
                                           xml = sub('<c r="B2">', paste0("<c", bl, 'r="B2">'), donnees487(0), fixed = TRUE)))), lire487)))
  verifier("xlsx (#487) : balise <c suivie de TAB, CR ou LF (toutes les cellules, ou une seule) : refus au texte fixe sur chaque chemin",
           all(vapply(rbl_c, function(x) tous487(x$toutes, function(d) identical(d, BALISE_C)) &&
                                          tous487(x$une, function(d) identical(d, BALISE_C)), logical(1))))
  rapo <- chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = sub('<c r="B2">', "<c r='B2'>",
                                                                                    donnees487(0), fixed = TRUE)))), lire487)
  rbl <- chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = sub('<c r="B2">', '<c r = "B2">',
                                                                                   donnees487(0), fixed = TRUE)))), lire487)
  verifier("xlsx (#487) : attribut r sous la forme r='B2' ou r = \"B2\" (XML legal) refuse comme cellule sans reference, texte fixe, sur chaque chemin",
           tous487(rapo, function(d) identical(d, CELLULE_SANS_R)) && tous487(rbl, function(d) identical(d, CELLULE_SANS_R)))
  # Revue finale de K2 (#487) : classeurs ecrits a la main, fichier par
  # fichier (workbook.xml et relations libres), lus par les deux chemins.
  brut487 <- function(wbx, relsx, feuilles = list("xl/worksheets/sheet1.xml" = NULL)) {
    d <- tempfile("b487_"); dir.create(d)
    on.exit(unlink(d, recursive = TRUE), add = TRUE)
    h <- '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    ns <- "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    fichiers <- c(list(
      "[Content_Types].xml" = paste0(h, '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">',
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>',
        '<Default Extension="xml" ContentType="application/xml"/></Types>'),
      "_rels/.rels" = paste0(h, '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>'),
      "xl/workbook.xml" = paste0(h, wbx), "xl/_rels/workbook.xml.rels" = paste0(h, relsx)),
      lapply(feuilles, function(x) paste0(h, if (is.null(x)) paste0('<worksheet xmlns="', ns, '"><sheetData>', donnees487(0),
                                                                      '</sheetData></worksheet>') else x)))
    for (n in names(fichiers)) {
      q <- file.path(d, n); dir.create(dirname(q), recursive = TRUE, showWarnings = FALSE)
      writeLines(fichiers[[n]], q, useBytes = TRUE)
    }
    f <- tempfile(fileext = ".xlsx")
    od <- setwd(d); on.exit(setwd(od), add = TRUE, after = FALSE)
    utils::zip(f, c("[Content_Types].xml", "_rels", "xl"), flags = "-r9Xq")
    f
  }
  rt487 <- "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  wb487 <- function(sheets, p = "") paste0('<', p, 'workbook xmlns', if (nzchar(p)) paste0(":", sub(":", "", p)),
    '="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="', rt487, '"><', p, 'sheets>', sheets,
    '</', p, 'sheets></', p, 'workbook>')
  rels487 <- function(liens, p = "") paste0('<', p, 'Relationships xmlns', if (nzchar(p)) paste0(":", sub(":", "", p)),
    '="http://schemas.openxmlformats.org/package/2006/relationships">', liens, '</', p, 'Relationships>')
  lien487 <- function(id, cible, type = "worksheet", p = "", q = '"')
    paste0('<', p, 'Relationship Id=', q, id, q, ' Type=', q, rt487, '/', type, q, ' Target=', q, cible, q, '/>')
  sh487 <- '<sheet name="D" sheetId="1" r:id="rId1"/>'
  li487 <- lien487("rId1", "worksheets/sheet1.xml")
  # Lecteur interne seul ; le chemin openxlsx rend une erreur R (classeur que
  # openxlsx 4.2.9 ne lit pas, mesure) sans la classe usp_refus_lecture.
  interne_seul487 <- function(r) is.data.frame(r$interne) && identical(names(r$interne), c("t", "xt", "yt")) &&
    identical(as.numeric(r$interne$xt), c(1, 3)) &&
    (!avec_openxlsx483 || (is.character(r$openxlsx) && !identical(r$openxlsx, "Classeur illisible : aucune feuille trouvee.")))
  rpx <- chemins483(brut487(wb487('<x:sheet name="D" sheetId="1" r:id="rId1"/>', "x:"), rels487(li487)), lire487)
  rpr <- chemins483(brut487(wb487(sh487), rels487(lien487("rId1", "worksheets/sheet1.xml", p = "p:"), "p:")), lire487)
  rap <- chemins483(brut487(wb487("<sheet name='D' sheetId='1' r:id='rId1'/>"), rels487(lien487("rId1", "worksheets/sheet1.xml", q = "'"))), lire487)
  reg <- chemins483(brut487(wb487('<sheet name="D" sheetId="1" r:id = "rId1"/>'), rels487(li487)), lire487)
  verifier("xlsx, lecteur interne (#487) : balises <x:sheet> et <p:Relationship> prefixees, attributs entre apostrophes, blancs autour de = : premiere feuille lue ; openxlsx 4.2.9 ne les lit pas (erreur R, non un refus)",
           all(vapply(list(rpx, rpr, rap, reg), interne_seul487, logical(1))))
  rnx <- chemins483(brut487(wb487('<sheet name="x id=" sheetId="1" r:id="rId1"/>'), rels487(li487)), lire487)
  rna2 <- chemins483(brut487(wb487('<sheet name="a r:id=\'rId2\' b" sheetId="1" r:id="rId1"/><sheet name="B" sheetId="2" r:id="rId2"/>'),
                             rels487(paste0(li487, lien487("rId2", "worksheets/sheet2.xml"))),
                             list("xl/worksheets/sheet1.xml" = NULL,
                                  "xl/worksheets/sheet2.xml" = paste0('<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>',
                                                                      donnees487(500), '</sheetData></worksheet>'))), lire487)
  verifier("xlsx (#487) : attribut lu entier (name=\"x id=\" ne capte plus id=, r:id='rId2' dans la valeur de name ignore) : premiere feuille lue sur chaque chemin",
           base487(rnx, 0) && base487(rna2, 0) &&
             identical(.xlsx_attribut('<sheet name="x id=" sheetId="7" r:id="rId1"/>', "id"), "rId1") &&
             identical(.xlsx_attribut("<sheet name='a&amp;b' sheetId='7'/>", "name"), "a&b") &&
             identical(.xlsx_attribut('<sheet name="D" sheetId="7"/>', "id"), NA_character_))
  rabs <- chemins483(brut487(wb487(sh487), rels487(lien487("rId1", "/xl/worksheets/sheet1.xml"))), lire487)
  rdbl <- chemins483(brut487(wb487(sh487), rels487(lien487("rId1", "//xl/worksheets/sheet1.xml"))), lire487)
  verifier("xlsx (#487) : cible \"/xl/worksheets/sheet1.xml\" (nom de partie absolu, forme d'openpyxl) lue sur chaque chemin ; \"//xl/...\" refusee \"aucune feuille trouvee\" ; regle unique .xlsx_chemin_sort()",
           base487(rabs, 0) && tous487(rdbl, function(d) identical(d, "Classeur illisible : aucune feuille trouvee.")) &&
             identical(.xlsx_chemin_sort(c("xl/a.xml", "../a", "a/../b", "a\\..\\b", "/a", "\\a", "C:a", "a..b", "..a")),
                       c(FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE)))
  # Feuille de graphique en premier onglet : openxlsx::read.xlsx(sheet = 1) la
  # lit et rend NULL (mesure, openxlsx 4.2.9) ; la premiere feuille de calcul
  # est lue sur chaque chemin (openxlsx appele avec son rang).
  cs487 <- '<chartsheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetViews><sheetView workbookViewId="0"/></sheetViews></chartsheet>'
  rch <- chemins483(brut487(wb487('<sheet name="G" sheetId="1" r:id="rId1"/><sheet name="G2" sheetId="2" r:id="rId3"/><sheet name="D" sheetId="3" r:id="rId2"/>'),
                            rels487(paste0(lien487("rId2", "worksheets/sheet1.xml"), lien487("rId1", "chartsheets/sheet1.xml", "chartsheet"),
                                           lien487("rId3", "chartsheets/sheet2.xml", "chartsheet"))),
                            list("xl/worksheets/sheet1.xml" = NULL, "xl/chartsheets/sheet1.xml" = cs487, "xl/chartsheets/sheet2.xml" = cs487)), lire487)
  rch0 <- chemins483(brut487(wb487('<sheet name="G" sheetId="1" r:id="rId1"/>'), rels487(lien487("rId1", "chartsheets/sheet1.xml", "chartsheet")),
                             list("xl/chartsheets/sheet1.xml" = cs487)), lire487)
  verifier("xlsx (#487) : deux feuilles de graphique avant la feuille de calcul : la feuille de calcul est lue sur chaque chemin ; classeur sans feuille de calcul refuse \"aucune feuille trouvee\"",
           base487(rch, 0) && tous487(rch0, function(d) identical(d, "Classeur illisible : aucune feuille trouvee.")))
  # Attributs r et t lus dans la seule balise ouvrante (.xlsx_cellules()) :
  # un texte r="B9" ou t="s" dans une chaine en ligne ne deplace ni ne retype
  # la cellule (le lecteur interne placait la valeur en B9).
  rgl <- chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = paste0(
    ligne487(1, c(en487("A1", "<t>xt</t>"), en487("B1", "<t>yt</t>"))),
    ligne487(2, c(en487("A2", '<t>x r="B9"</t>'), nb487("B2", 2))),
    ligne487(3, c(en487("A3", '<t>q t="s"</t>'), nb487("B3", 4))))))), lire487)
  verifier("xlsx (#487) : chaine en ligne portant r=\"B9\" ou t=\"s\" lue a sa place et en texte sur chaque chemin (deux lignes de donnees)",
           tous487(rgl, function(d) is.data.frame(d) && identical(d$xt, c('x r="B9"', 'q t="s"')) &&
                     identical(as.numeric(d$yt), c(2, 4))))
  # Attributs de cellule compares par leur nom entier (revue de l'audit) : un
  # attribut prefixe x:r ou x:t place avant r et t n'est pas lu a leur place ;
  # openxlsx 4.2.9 place, lui, la valeur en Z9 (mesure, non fige ici).
  rxr <- lire487(sans_openxlsx483(engine_lire_xlsx(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = paste0(
    ligne487(1, c(en487("A1", "<t>xt</t>"), en487("B1", "<t>yt</t>"))),
    ligne487(2, c('<c x:r="Z9" r="A2" x:t="s" t="n"><v>5</v></c>', nb487("B2", 6))))))))))
  verifier("xlsx, lecteur interne (#487) : <c x:r=\"Z9\" r=\"A2\" x:t=\"s\" t=\"n\"> lue en A2, en nombre (attributs r et t compares par leur nom entier)",
           is.data.frame(rxr) && identical(names(rxr), c("xt", "yt")) && identical(rxr$xt, 5) && identical(rxr$yt, 6) &&
             identical(.xlsx_cellules('<c x:r="Z9" r="A1" t="n"><v>1</v></c>')$ref, "A1") &&
             identical(.xlsx_attribut('<sheet x:id="rId4" name="D"/>', "id"), "rId4"))
  # Entites XML. Chaines partagees : entites nommees lues pareil par les deux
  # chemins ; le reste (references numeriques, chaines en ligne, "&amp;lt;" que
  # openxlsx decode deux fois) n'est lu juste que par le lecteur interne
  # (divergences nommees dans l'en-tete d'engine_lire_xlsx()).
  ent_ps <- c("a&amp;b", "s&lt;t&gt;", "q&quot;x&apos;y")
  rE <- chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = paste0(
    ligne487(1, c(ps487("A1", 0), ps487("B1", 1), ps487("C1", 2))),
    ligne487(2, c(nb487("A2", 1), nb487("B2", 2), nb487("C2", 3)))))),
    shared = paste0("<si><t>", ent_ps, "</t></si>", collapse = "")), function(d) names(d))
  verifier("xlsx (#487) : entites nommees des chaines partagees decodees, memes en-tetes sur chaque chemin",
           tous487(rE, function(n) identical(n, c("a&b", "s<t>", "q\"x'y"))))
  interne487 <- function(xml, shared = NULL)
    lire487(sans_openxlsx483(engine_lire_xlsx(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = xml)),
                                                          shared = shared))))
  nI <- names(interne487(paste0(
    ligne487(1, c(en487("A1", "<t>a&amp;b</t>"), en487("B1", "<t>&#233;t&#xE9;</t>"),
                  en487("C1", "<t>&lt;x&gt; &quot;q&quot; &apos;a&apos;</t>"), en487("D1", "<t>&amp;lt;|&#38;lt;|&#x41;</t>"),
                  en487("E1", "<t>&#0;&#xD800;&#x110000;&#99999999999;</t>"))),
    ligne487(2, c(nb487("A2", 1), nb487("B2", 2), nb487("C2", 3), nb487("D2", 4), nb487("E2", 5))))))
  nS <- names(interne487(paste0(ligne487(1, c(ps487("A1", 0), ps487("B1", 1))), ligne487(2, c(nb487("A2", 1), nb487("B2", 2)))),
                         shared = "<si><t>&#233;t&#xE9;</t></si><si><t>&amp;lt;|&#38;lt;|&#x41;</t></si>"))
  verifier("xlsx, lecteur interne (#487) : entites nommees et references numeriques decodees (chaines en ligne et partagees), en une seule passe",
           identical(nI, c("a&b", "\u00e9t\u00e9", "<x> \"q\" 'a'", "&lt;|&lt;|A",
                           "&#0;&#xD800;&#x110000;&#99999999999;")) &&
             identical(nS, c("\u00e9t\u00e9", "&lt;|&lt;|A")))
  # Chaine enrichie en ligne : segments concatenes par le lecteur interne
  # (openxlsx la rend NA) ; en chaine partagee, les deux chemins concatenent.
  enr <- '<r><t>x</t></r><r><rPr><b/></rPr><t>t</t></r>'
  renr <- interne487(paste0(
    ligne487(1, c(en487("A1", enr), en487("B1", "<r><t>y</t></r><r><t xml:space=\"preserve\"> t</t></r>"))),
    ligne487(2, c(en487("A2", "<r><t>ab</t></r><r><t>cd</t></r>"), nb487("B2", 2)))))
  verifier("xlsx, lecteur interne (#487) : chaine en ligne enrichie lue entiere (segments concatenes), en en-tete comme en corps",
           identical(names(renr), c("xt", "y t")) && identical(renr$xt, "abcd"))
  rP <- chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = paste0(
    ligne487(1, c(ps487("A1", 0), ps487("B1", 1))), ligne487(2, c(nb487("A2", 1), nb487("B2", 2)))))),
    shared = paste0("<si>", enr, "</si><si><r><t>y</t></r><r><t>t</t></r></si>")), function(d) names(d))
  verifier("xlsx (#487) : chaine partagee enrichie lue entiere par chaque chemin",
           tous487(rP, function(n) identical(n, c("xt", "yt"))))
  # Blancs d'en-tete : blancs de bord retires, suite de blancs ramenee a une
  # espace (regle mesuree sur openxlsx, sep.names = " ") ; l'espace insecable
  # n'est pas un blanc. Noms rendus uniques par un prefixe.
  nb <- intToUtf8(160L)   # espace insecable
  grille487 <- c("u1 x", "u2\tx", "u3\nx", "u4  x", "u5 \t x", "u6\r\nx", " u7", "u8 ", "\t u9\n ", paste0("u10", nb, "x"),
                 paste0(nb, "u11"), paste0("u12", nb), "u13 x y", " ")
  attendu487 <- c("u1 x", "u2 x", "u3 x", "u4 x", "u5 x", "u6 x", "u7", "u8", "u9", paste0("u10", nb, "x"),
                  paste0(nb, "u11"), paste0("u12", nb), "u13 x y", "V14")
  col487 <- function(k) if (k <= 26) LETTERS[k] else paste0("A", LETTERS[k - 26])
  rW <- chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = paste0(
    ligne487(1, vapply(seq_along(grille487), function(k) ps487(paste0(col487(k), "1"), k - 1L), "")),
    ligne487(2, vapply(seq_along(grille487), function(k) nb487(paste0(col487(k), "2"), k), ""))))),
    shared = paste0('<si><t xml:space="preserve">', grille487, '</t></si>', collapse = "")), function(d) names(d))
  verifier("xlsx, lecteur interne (#487) : blancs de bord retires et suite de blancs ramenee a une espace dans la ligne d'en-tete ; espace insecable gardee",
           identical(rW$interne, attendu487))
  if (avec_openxlsx483)
    verifier("xlsx (#487) : blancs d'en-tete lus pareil par openxlsx (sep.names = \" \") et le lecteur interne, hors en-tete de blancs seuls (\"\" pour openxlsx, V<col> ici)",
             identical(rW$interne[-14], rW$openxlsx[-14]) && identical(rW$openxlsx[-14], attendu487[-14]))
  # En-tetes en chaine en ligne (classeur ecrit par l'ecrivain interne) : blancs mis en forme pareil sur chaque chemin
  ent487 <- function(s) sub('<t>yt</t>', '<t>yt  </t>', sub('<t>xt</t>', '<t> x  t </t>', s, fixed = TRUE), fixed = TRUE)
  rM <- chemins483(xlsx483(ser483, ent487), function(d) names(d))
  verifier("xlsx (#487) : en-tetes \" x  t \" et \"yt  \" lus \"x t\" et \"yt\" sur chaque chemin",
           tous487(rM, function(n) identical(n, c("x t", "yt"))))
  # Acceptation : un en-tete " xt" ou "yt  " est accepte en xlsx sur chaque chemin
  # (il est refuse en CSV : divergence CSV - xlsx nommee dans l'en-tete
  # d'engine_lire_xlsx(), decision D3 du mainteneur)
  rX <- chemins483(xlsx483(ser483, function(s) sub('<t>yt</t>', '<t>yt  </t>', sub('<t>xt</t>', '<t> xt</t>', s, fixed = TRUE), fixed = TRUE)),
                   engine_lire_donnees_csv)
  verifier("xlsx (#487) : en-tetes \" xt\" et \"yt  \" acceptes, series identiques, sur chaque chemin",
           tous487(rX, function(r) identical(r, ref_ser)))

  # --- #522 : l'en-tete du tableau est en ligne 1. Une ligne 1 sans aucune
  # valeur (absente, ou cellules mises en forme sans valeur) est refusee au
  # texte fixe, sur chaque chemin, series et triangle ; openxlsx sautait les
  # lignes vides de tete (il acceptait le fichier), le lecteur interne
  # prenait la ligne vide pour l'en-tete.
  LIGNE1_522 <- "Ligne 1 du fichier sans aucune valeur : l'en-tete du tableau doit etre en ligne 1, sans ligne au-dessus ; supprimer la ou les lignes vides au-dessus de l'en-tete."
  # Descend de n lignes toutes les lignes <row r="k"> et cellules <c r="Xk">
  descendre522 <- function(n) function(s) {
    m <- gregexpr('<(row|c) r="[A-Z]*[0-9]+"', s)
    regmatches(s, m) <- lapply(regmatches(s, m), function(tk) vapply(tk, function(t) {
      k <- as.integer(sub('.*[^0-9]([0-9]+)"$', "\\1", t))
      sub('[0-9]+"$', paste0(k + n, '"'), t)
    }, "", USE.NAMES = FALSE))
    s
  }
  avant522 <- function(xml) function(s) sub("<sheetData>", paste0("<sheetData>", xml), s, fixed = TRUE)
  forme1_522 <- '<row r="1"><c r="A1" s="1"/><c r="B1" s="1"/></row>'
  titre1_522 <- '<row r="1"><c r="A1" t="inlineStr"><is><t>Export ACME</t></is></c></row>'
  refus522 <- function(r) tous487(r, function(d) identical(d, LIGNE1_522))
  lire522 <- function(d) tryCatch(d, error = function(e) conditionMessage(e))
  verifier("xlsx (#522) : series dont l'en-tete est en ligne 2, puis en ligne 3 (ligne 1 absente) : refus au texte fixe sur chaque chemin",
           refus522(chemins483(xlsx483(ser483, descendre522(1)), lire522)) &&
             refus522(chemins483(xlsx483(ser483, descendre522(2)), lire522)))
  verifier("xlsx (#522) : triangle dont l'en-tete est en ligne 2, puis en ligne 3 (ligne 1 absente) : meme refus sur chaque chemin",
           refus522(chemins483(xlsx483(tri483, descendre522(1)), lire522)) &&
             refus522(chemins483(xlsx483(tri483, descendre522(2)), lire522)))
  verifier("xlsx (#522) : ligne 1 faite de cellules mises en forme sans valeur (<c r=\"A1\" s=\"1\"/>), en-tete en ligne 2 ou 3 : meme refus, series et triangle, sur chaque chemin",
           refus522(chemins483(xlsx483(ser483, function(s) avant522(forme1_522)(descendre522(1)(s))), lire522)) &&
             refus522(chemins483(xlsx483(ser483, function(s) avant522(forme1_522)(descendre522(2)(s))), lire522)) &&
             refus522(chemins483(xlsx483(tri483, function(s) avant522(forme1_522)(descendre522(1)(s))), lire522)))
  # Hors du refus : en-tete en ligne 1 (lecture inchangee) ; titre seul en A1
  # (la ligne 1 porte une valeur : pas de motif propre, refus par colonne
  # manquante, meme texte sur chaque chemin, noms generes cites "(vide)") ;
  # feuille sans aucune cellule ; entete = FALSE (la ligne 1 est une ligne de
  # donnees, qui peut etre vide).
  ser3_522 <- data.frame(t = seq_along(xt483), xt = xt483, yt = yt483)
  rtitre <- chemins483(xlsx483(ser3_522, function(s) avant522(titre1_522)(descendre522(1)(s))), engine_lire_donnees_csv)
  verifier("xlsx (#522) : titre seul en A1, en-tete en ligne 2 : pas de refus de la ligne 1, refus par colonne manquante, memes noms \"(vide)\" sur chaque chemin",
           tous487(rtitre, function(r) !r$ok && identical(r$erreurs,
             "Colonne(s) manquante(s) : xt, yt. Colonnes attendues : t, xt, yt (format d'export de l'application). Colonnes presentes : Export ACME, (vide), (vide).")))
  verifier("xlsx (#522) : en-tete en ligne 1 : lecture inchangee, series et triangle identiques sur chaque chemin",
           tous487(chemins483(xlsx483(ser483), engine_lire_donnees_csv), function(r) identical(r, ref_ser)) &&
             tous487(chemins483(xlsx483(tri483), engine_lire_triangle), function(r) identical(r, ref_tri)))
  # openxlsx rend NULL pour une feuille sans cellule (l'element serait supprime
  # par chemins483()) : "NULL" le represente.
  rvide <- chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = ""))),
                      function(d) { d <- suppressWarnings(lire522(d)); if (is.null(d)) "NULL" else d })
  verifier("xlsx (#522) : feuille sans aucune cellule : pas le refus de la ligne 1 (tableau vide : \"Fichier vide ou illisible comme tableau.\"), sur chaque chemin",
           tous487(rvide, function(d) !identical(d, LIGNE1_522) &&
                     identical(engine_lire_donnees_csv(if (identical(d, "NULL")) NULL else d)$erreurs,
                               "Fichier vide ou illisible comme tableau.")))
  f522 <- xlsx483(ser483, descendre522(2))
  e522 <- list(interne = lire522(sans_openxlsx483(engine_lire_xlsx(f522, entete = FALSE))))
  if (avec_openxlsx483) e522$openxlsx <- lire522(engine_lire_xlsx(f522, entete = FALSE))
  unlink(f522)
  verifier("xlsx (#522) : entete = FALSE : pas de refus de la ligne 1, un data.frame sur chaque chemin",
           tous487(e522, is.data.frame))
  # Ligne 1 de chaines vides ou de blancs (decision du mainteneur du
  # 12/11/2026, option (b)) : refusee au texte de #522 sur chaque chemin,
  # chaines partagees comme chaines en ligne ; une cellule nombre ou
  # booleenne reste une valeur ; une feuille faite seulement de blancs garde
  # ses refus (tableau vide).
  corps522b <- paste0(ligne487(2, c(nb487("A2", 1), nb487("B2", 2))), ligne487(3, c(nb487("A3", 3), nb487("B3", 4))))
  bl522 <- function(ligne1, shared = NULL, corps = corps522b)
    chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = paste0(ligne487(1, ligne1), corps))), shared = shared), lire522)
  verifier("xlsx (#522, option (b)) : ligne 1 de blancs en chaines partagees (\"  \", \"&#32;\"), en chaines en ligne (espace, TAB) ou de chaines vides : refus au texte de #522 sur chaque chemin",
           refus522(bl522(c(ps487("A1", 0), ps487("B1", 0)), shared = '<si><t xml:space="preserve">  </t></si>')) &&
             refus522(bl522(c(ps487("A1", 0), ps487("B1", 0)), shared = "<si><t>&#32;</t></si>")) &&
             refus522(bl522(c(en487("A1", '<t xml:space="preserve"> </t>'), en487("B1", "<t>\t</t>")))) &&
             refus522(bl522(c(en487("A1", "<t></t>"), en487("B1", "<t></t>")))))
  verifier("xlsx (#522, option (b)) : ligne 1 portant un nombre 0 ou un booleen parmi des blancs : pas de refus de la ligne 1 sur chaque chemin",
           tous487(bl522(c(nb487("A1", 0), en487("B1", "<t> </t>"))), is.data.frame) &&
             tous487(bl522(c('<c r="A1" t="b"><v>0</v></c>', en487("B1", "<t> </t>"))), is.data.frame))
  vide522b <- bl522(c(ps487("A1", 0), ps487("B1", 0)), shared = '<si><t xml:space="preserve"> </t></si>',
                    corps = ligne487(2, c(ps487("A2", 0), ps487("B2", 0))))
  verifier("xlsx (#522, option (b)) : feuille faite seulement de blancs : pas le refus de la ligne 1 ; triangle \"Fichier vide ou illisible comme tableau.\", series meme motif, sur chaque chemin",
           tous487(vide522b, is.data.frame) &&
             tous487(vide522b, function(d) identical(engine_lire_triangle(d)$erreurs, "Fichier vide ou illisible comme tableau.")) &&
             length(unique(lapply(vide522b, function(d) engine_lire_donnees_csv(d)$erreurs))) == 1L &&
             identical(tryCatch(.xlsx_controler_ligne_entete('<row r="1"><c r="A1" t="s"><v>0</v></c></row><row r="2"><c r="A2"><v>1</v></c></row>',
                                                            partagees = " "), error = conditionMessage), LIGNE1_522) &&
             is.null(.xlsx_controler_ligne_entete('<row r="1"><c r="A1" t="s"><v>0</v></c></row><row r="2"><c r="A2"><v>1</v></c></row>',
                                                 partagees = "x")))
  # Classe de la condition : les refus motives (ligne 1 #522, cellule sans r et
  # balise <c de #487) sont de classe "usp_refus_lecture", lue par
  # l'application ; feuille introuvable : erreur ordinaire.
  classe522 <- function(f) { force(f)
    out <- list(interne = tryCatch(sans_openxlsx483(engine_lire_xlsx(f)), error = function(e) class(e)))
    if (avec_openxlsx483) out$openxlsx <- tryCatch(engine_lire_xlsx(f), error = function(e) class(e))
    unlink(f); out }
  REFUS522 <- c("usp_refus_lecture", "error", "condition")
  verifier("xlsx (#522, #487) : refus de la ligne 1, de la cellule sans r et de la balise <c TAB : classe usp_refus_lecture sur chaque chemin ; feuille introuvable : erreur sans cette classe",
           tous487(classe522(xlsx483(ser483, descendre522(1))), function(k) identical(k, REFUS522)) &&
             tous487(classe522(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = paste0(
               ligne487(1, c(en487("A1", "<t>xt</t>"), en487("B1", "<t>yt</t>"))),
               ligne487(2, c(nb487("A2", 1), "<c><v>5</v></c>"))))))), function(k) identical(k, REFUS522)) &&
             tous487(classe522(classeur487(list(list(nom = "D", fichier = "sheet1.xml",
               xml = sub('<c r="B2">', '<c\tr="B2">', donnees487(0), fixed = TRUE))))), function(k) identical(k, REFUS522)) &&
             tous487(classe522(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = donnees487(0), absente = TRUE)))),
                     function(k) is.character(k) && "error" %in% k && !"usp_refus_lecture" %in% k))
  # Reference de cellule en minuscules (r="a1", reserve de l'audit) : la ligne
  # 1 est reconnue, pas de refus "ligne 1" ; le lecteur interne lit la
  # feuille (reference mise en majuscules par .xlsx_cellules(), #487 ; il
  # levait une erreur R) ; openxlsx 4.2.9 leve une erreur R ordinaire.
  rmin <- chemins483(classeur487(list(list(nom = "D", fichier = "sheet1.xml", xml = paste0(
    '<row r="1"><c r="a1" t="inlineStr"><is><t>xt</t></is></c><c r="b1" t="inlineStr"><is><t>yt</t></is></c></row>',
    '<row r="2"><c r="a2"><v>1</v></c><c r="b2"><v>2</v></c></row><row r="3"><c r="a3"><v>3</v></c><c r="b3"><v>4</v></c></row>')))),
    function(d) tryCatch(d, error = function(e) class(e)))
  verifier("xlsx (#522, #487) : references en minuscules (r=\"a1\") : pas de refus de la ligne 1 sur chaque chemin ; lecteur interne : feuille lue (xt = 1, 3 ; yt = 2, 4) ; openxlsx : erreur R ordinaire",
           tous487(rmin, function(k) !identical(k, REFUS522)) &&
             is.data.frame(rmin$interne) && identical(names(rmin$interne), c("xt", "yt")) &&
             identical(rmin$interne$xt, c(1, 3)) && identical(rmin$interne$yt, c(2, 4)) &&
             (!avec_openxlsx483 || (is.character(rmin$openxlsx) && "error" %in% rmin$openxlsx &&
                                      !"usp_refus_lecture" %in% rmin$openxlsx)) &&
             identical(tryCatch(.xlsx_controler_ligne_entete('<row r="1"><c r="a1"><v>1</v></c></row><row r="2"><c r="a2"><v>2</v></c></row>'),
                                error = function(e) "refus"), NULL))
} else cat("  [saute] lignes et colonnes vides (#483), lecture xlsx : commande zip indisponible\n")

## --- CSV dont la ligne 1 ne porte que des separateurs (#522, extension aux CSV)
# Decision du mainteneur du 12/11/2026 : un CSV dont la ligne 1 ne contient
# que des separateurs (",,,,,") est refuse avec le texte du classeur, motif
# "erreurs" d'engine_lire_donnees_csv() et d'engine_lire_triangle()
# (.ligne1_sans_valeur()). Lecture de l'application (lire_tableau()).
lire_csv522 <- function(txt) {
  f <- tempfile(fileext = ".csv"); on.exit(unlink(f))
  writeBin(charToRaw(enc2utf8(txt)), f)
  utils::read.csv(f, colClasses = "character", blank.lines.skip = FALSE, check.names = FALSE,
                  na.strings = character(0), row.names = NULL)
}
MOTIF522 <- "Ligne 1 du fichier sans aucune valeur : l'en-tete du tableau doit etre en ligne 1, sans ligne au-dessus ; supprimer la ou les lignes vides au-dessus de l'en-tete."
tri522 <- "i,j0,j1,j2,j3,j4\n0,100,150,170,180,185\n1,110,160,180,190,\n2,120,170,190,,\n3,130,180,,,\n4,140,,,,\n"
ser522 <- "t,xt,yt\n1,10,2\n2,11,2\n3,12,3\n4,13,3\n5,14,4\n"
num522 <- "100,150,170,180,185\n110,160,180,190,\n120,170,190,,\n130,180,,,\n140,,,,\n"
refuse522 <- function(df) identical(engine_lire_donnees_csv(df)$erreurs, MOTIF522) &&
  identical(engine_lire_triangle(df)$erreurs, MOTIF522) && !engine_lire_triangle(df)$ok
verifier("CSV (#522) : ligne 1 \",,,\" au-dessus d'un en-tete texte (series t,xt,yt ; triangle i,j0..) : refus au texte du classeur, series et triangle",
         refuse522(lire_csv522(paste0(",,\n", ser522))) && refuse522(lire_csv522(paste0(",,,,,\n", tri522))) &&
           identical(MOTIF522, MOTIF_LIGNE1_VIDE))
verifier("CSV (#522) : ligne 1 \",,,\" au-dessus d'un en-tete numerique (0,1,2,3,4) ou d'un triangle sans en-tete : refus (auparavant triangle non carre, ou triangle accepte)",
         refuse522(lire_csv522(paste0(",,,,,\n0,1,2,3,4\n", num522))) && refuse522(lire_csv522(paste0(",,,,\n", num522))))
verifier("CSV (#522) : ligne 1 \",,,\" avec BOM, de blancs \" , , \" ou de guillemets vides : meme refus",
         refuse522(lire_csv522(paste0("﻿,,\n", ser522))) && refuse522(lire_csv522(paste0(" , , \n", ser522))) &&
           refuse522(lire_csv522(paste0('"","",""\n', ser522))))
verifier("CSV (#522, option (b)) : en-tetes cites faits seulement de blancs [[:space:]] (\" \", TAB) : meme refus ; en-tetes faits d'une espace insecable (hors [[:space:]] sous C.UTF-8) : en-tetes reels, pas ce refus",
         refuse522(lire_csv522(paste0('" "," "," "\n', ser522))) &&
           refuse522(lire_csv522(paste0('"\t","  ",""\n', ser522))) &&
           !identical(engine_lire_triangle(lire_csv522(paste0('" "," "," "," "," "\n', num522)))$erreurs, MOTIF522))
verifier("CSV (#522) : ligne 1 \",,,\" sans aucune valeur dessous : pas ce refus (tableau vide : \"Fichier vide ou illisible comme tableau.\")",
         identical(engine_lire_donnees_csv(lire_csv522(",,\n"))$erreurs, "Fichier vide ou illisible comme tableau.") &&
           identical(engine_lire_triangle(lire_csv522(",,\n,,\n"))$erreurs, "Fichier vide ou illisible comme tableau."))
m522 <- as.matrix(utils::read.csv(text = tri522))[, -1]; dimnames(m522) <- NULL
x522 <- as.data.frame(m522); names(x522) <- paste0("X", 1:5)
verifier("CSV (#522) : pas de faux refus : series xt,yt sans t ; triangle i,j0.. ; en-tete \"i\" suivi d'en-tetes vides ; matrice sans noms et noms generes V<k> / X<k>",
         isTRUE(engine_lire_donnees_csv(lire_csv522(sub("t,xt,yt", "xt,yt", gsub("\n[0-9],", "\n", ser522))))$ok) &&
           isTRUE(engine_lire_triangle(lire_csv522(tri522))$ok) &&
           isTRUE(engine_lire_triangle(lire_csv522(sub("i,j0,j1,j2,j3,j4", "i,,,,,", tri522)))$ok) &&
           isTRUE(engine_lire_triangle(m522)$ok) && isTRUE(engine_lire_triangle(as.data.frame(m522))$ok) &&
           isTRUE(engine_lire_triangle(x522)$ok))
verifier("CSV (#522) : motifs LE-02, LE-03 et LE-13 inchanges (en-tete y, ligne vide sous l'en-tete, cellule non numerique)",
         grepl("^Colonne\\(s\\) manquante\\(s\\) : yt\\.", engine_lire_donnees_csv(lire_csv522("t,xt,y\n1,2,3\n"))$erreurs) &&
           grepl("^Ligne\\(s\\) vide\\(s\\) en tete, sous l'en-tete",
                 engine_lire_donnees_csv(lire_csv522(paste0("t,xt,yt\n,,\n", sub("^[^\n]*\n", "", ser522))))$erreurs) &&
           identical(engine_lire_triangle(lire_csv522(sub("185", "xyz", tri522)))$erreurs,
                     "Cellule(s) non numerique(s) en (i = 0, j = 4) (i : annee d'accident, j : annee de developpement)."))

## --- Colonnes presentes : caracteres echappes, noms absents cites "(vide)" (#522)
# Liste des en-tetes de engine_lire_donnees_csv() ecrite par .echapper_texte() :
# caracteres de controle ecrits \001, \t, \n, \033, blancs et controles non
# ASCII \uXXXX, octet 0x89 declare Latin-1 lu comme Windows-1252 (U+2030) ;
# nom que
# .entete_absent() juge absent ("", NA, "X<k>" ou "V<k>" a sa position) cite
# "(vide)".
cols522 <- function(noms) {
  d <- as.data.frame(matrix("1", 1L, length(noms)), stringsAsFactors = FALSE)
  names(d) <- noms
  r <- engine_lire_donnees_csv(d)
  sub("^.*Colonnes presentes : (.*)\\.$", "\\1", r$erreurs)
}
octet89_522 <- rawToChar(as.raw(c(0x61, 0x89, 0x62)))          # "a<89>b", encodage non declare
latin1_522 <- octet89_522; Encoding(latin1_522) <- "latin1"    # declare Latin-1
verifier("Colonnes presentes (#522) : caracteres de controle ASCII ecrits \\001, \\t, \\n, \\033, sans guillemets",
         identical(cols522(c("a\001b", "x\tt\n", "y\033[31mt")), "a\\001b, x\\tt\\n, y\\033[31mt") &&
           identical(cols522(c("a\\b", "q\"r", "d\ref")), "a\\\\b, q\"r, d\\ref"))
# Octet 0x89 declare Latin-1 (ou non declare, en locale UTF-8, ou
# .declarer_latin1() le declare) : enc2utf8() le lit comme Windows-1252, U+2030
# (pour mille), caractere imprimable cite tel quel, et non comme le controle
# U+0089 ; 0xA0 devient l'espace insecable (ecrite \u00a0) ; 0x81, sans
# caractere en Windows-1252, reste ecrit "<81>" par R (mesures, R 4.3.3,
# C.UTF-8, comme .nettoyer_cellules(), #99). Le controle U+0089 lui-meme, en
# UTF-8 valide, est ecrit \u0089.
l1_522 <- function(b) { x <- rawToChar(as.raw(c(0x61, b, 0x62))); Encoding(x) <- "latin1"; x }
verifier("Colonnes presentes (#522) : octet 0x89 declare Latin-1 lu comme Windows-1252 (U+2030, cite tel quel), 0xA0 ecrit \\u00a0, 0x81 cite <81> ; \"e\" accentue inchange",
         identical(cols522(c(latin1_522, "ann\u00e9e", "x")), "a\u2030b, ann\u00e9e, x") &&
           identical(cols522(c(l1_522(0xa0), l1_522(0x81), l1_522(0xe9))), "a\\u00a0b, a<81>b, a\u00e9b") &&
           (!isTRUE(l10n_info()[["UTF-8"]]) ||
              identical(cols522(c(octet89_522, "x", "y")), "a\u2030b, x, y")))
verifier("Colonnes presentes (#522) : controle C1 U+0089 en UTF-8 valide ecrit \\u0089",
         identical(cols522(c("a\u0089b", "x", "y")), "a\\u0089b, x, y"))
verifier("Colonnes presentes (#522) : blancs, controles et caracteres de format non ASCII ecrits \\uXXXX (\\UXXXXXXXX au-dela de U+FFFF)",
         identical(cols522(c("a\u00a0b", "a\u200bb", "\u2028")), "a\\u00a0b, a\\u200bb, \\u2028") &&
           identical(cols522(c(intToUtf8(0xE0001), "\u00e9", "x")), "\\U000e0001, \u00e9, x"))
verifier("Colonnes presentes (#522) : nom absent cite \"(vide)\" (\"\", NA, \"X<k>\" et \"V<k>\" a leur position), nom reel \"X5\" ou \"V1\" hors position garde ; tous les noms \"\" : refus de la ligne 1 (extension aux CSV)",
         identical(cols522(c("Export ACME", "", NA)), "Export ACME, (vide), (vide)") &&
           identical(cols522(c("t", "X2", "V3")), "t, (vide), (vide)") &&
           identical(cols522(c("t", "X5", "V1")), "t, X5, V1") &&
           identical(cols522(c("", NA, "X3")), "(vide), (vide), (vide)") &&
           identical(cols522(c("", "", "")), MOTIF_LIGNE1_VIDE))
verifier("Colonnes presentes (#522) : en-tete a controle et nom absent dans la meme liste ; motif UTF-8 valide",
         {
           r <- engine_lire_donnees_csv(setNames(data.frame("1", "2", "3", stringsAsFactors = FALSE),
                                                 c("x\001", "", latin1_522)))
           validUTF8(r$erreurs) && contient(r$erreurs, "Colonnes presentes : x\\001, (vide), a\u2030b.")
         })
# Fonction partagee : avec guillemets, la forme de citer() de mw_valider_triangle()
verifier(".echapper_texte() (#522) : guillemets = TRUE rend la forme de citer() (guillemet echappe \\\", blancs non ASCII \\uXXXX), FALSE la meme sans guillemets",
         identical(.echapper_texte(c("a\"b\t", "2022\u00a0", "x"), guillemets = TRUE),
                   c("\"a\\\"b\\t\"", "\"2022\\u00a0\"", "\"x\"")) &&
           identical(.echapper_texte(c("a\"b\t", "2022\u00a0", "x")), c("a\"b\\t", "2022\\u00a0", "x")))

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
                         "; bareme reglementaire du segment II-2 : court (G(2)), c = 100%"),
                   ds, fixed = TRUE) &&
             grepl(paste("bareme long saisi (valeurs de G(1)) : saisie declaree comme derogation,",
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
             contient(r$erreurs, "Cellule observee manquante : annee d'accident i = 0, annee de developpement j = 0.") &&
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
# Series de longueurs differentes avec T (issue #482) : la troncature a T
# coupait les deux series sur les indices de xt ; yt plus long passait la
# validation (yt mal apparie, valeurs recentes ecartees), yt plus court etait
# refuse pour "Valeurs manquantes". Contrat : aucune troncature, refus par le
# motif de longueur, meme validation avec ou sans T, dans
# engine_valider_serie_retenue() (apercu de l'application) et run_engine().
verifier("#482 : xt et yt de longueurs differentes avec T valide : refus par le motif de longueur, meme validation que sans T, serie non tronquee, moteur et run_engine()",
         all(vapply(list(c(10L, 12L), c(10L, 9L), c(12L, 10L)), function(nn) {
           xt <- xc[seq_len(nn[1])]; yt <- yc[seq_len(nn[2])]
           motif <- sprintf("xt (%d valeurs) et yt (%d valeurs) doivent avoir la meme longueur.",
                            nn[1], nn[2])
           s8 <- engine_valider_serie_retenue(xt, yt, T = 8, methode = "premium",
                                              nature_donnees = "brutes", segment = 1)
           s0 <- engine_valider_serie_retenue(xt, yt, methode = "premium",
                                              nature_donnees = "brutes", segment = 1)
           r8 <- run_engine(xt, yt, methode = "premium", segment = 1, annexe = "II",
                            T = 8, B = 99, nature_donnees = "brutes")
           r0 <- run_engine(xt, yt, methode = "premium", segment = 1, annexe = "II",
                            B = 99, nature_donnees = "brutes")
           !s8$validation$ok && identical(s8$validation, s0$validation) &&
             identical(s8$xt, xt) && identical(s8$yt, yt) &&
             identical(s8$validation$erreurs, motif) &&
             !isTRUE(r8$ok) && !isTRUE(r0$ok) &&
             identical(r8$validation, s8$validation) &&
             identical(r0$validation, s0$validation)
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
                                                   "perte moyenne (85.005)") &&
             !isTRUE(rh$ok) && identical(rh$validation, sh$validation) &&
             !engine_valider_donnees(xb, yb, delta_equiv = 70)$ok &&
             sb$validation$ok && isTRUE(rb$ok) && identical(rb$validation, sb$validation)
         })
verifier("#154 : avertissements calcules sur les T retenues (ratio et amplitude des annees ecartees absents, T = 8 affiche)",
         {
           xw <- c(1, 100, x); yw <- c(1e4, 50, y)
           an <- engine_valider_donnees(xw, yw)$avertissements
           at <- sr154(xw, yw)$validation$avertissements
           contient(an, "Ratio y_t/x_t hors de la plage") && contient(an, "Amplitude des volumes") &&
             !contient(an, "T = 8") &&
             !contient(at, "Ratio y_t/x_t hors de la plage") && !contient(at, "Amplitude des volumes") &&
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
               is.list(tri) && !tri$ok && contient(tri$erreurs, "Cellule(s) non numerique(s) en (i = 0, j = 0)")
           })
           identical(r, "locale UTF-8 indisponible") || isTRUE(r)
         })
# Issue #490 (audit entrees-sorties, constats C6 et C11) : .cellules_en_nombre()
# refuse le point quand dec != ".", l'hexadecimal et l'exposant incomplet, que
# as.numeric() lit comme des nombres ("1.500" avec dec = "," valait 1,5 : facteur
# 1 000 sans refus ; "0x10" valait 16).
verifier(".cellules_en_nombre() : decimales ordinaires inchangees (dec = \".\" et dec = \",\", exposant complet, signe +, .5, 5.) (#490)",
         {
           ord <- c("1.5", "+1", "-2", "1e3", "1E-3", "1e+3", ".5", "5.", "0", "00012", "1.e3", " 7", "7 ")
           virg <- c("1,5", "980,5", "-0,25", "1e3", ",5", "5,", "42")
           identical(.cellules_en_nombre(ord), suppressWarnings(as.numeric(ord))) &&
             !anyNA(.cellules_en_nombre(ord)) &&
             identical(.cellules_en_nombre(virg, ","), c(1.5, 980.5, -0.25, 1000, 0.5, 5, 42)) &&
             identical(.cellules_en_nombre(c(NA, "x", ""), ","), rep(NA_real_, 3)) &&
             identical(.cellules_en_nombre(character(0), ","), numeric(0))
         })
verifier(".cellules_en_nombre() : point refuse quand dec != \".\", y compris avec exposant ; accepte quand dec = \".\" (#490)",
         {
           pts <- c("1.500", "980.5", "2.5e3", ".5", "5.")
           all(is.na(.cellules_en_nombre(pts, ","))) && !anyNA(.cellules_en_nombre(pts, ".")) &&
             identical(.cellules_en_nombre(c("1.500", "2,5"), ","), c(NA, 2.5))
         })
verifier(".cellules_en_nombre() : hexadecimal (signe, blancs de tete, exposant binaire) et exposant incomplet refuses ; Inf et NaN gardes (#490)",
         {
           hexa <- c("0x10", "0X1F", "-0x10", "+0x10", " 0x10", "\t0x1", "0x1p3", "0x.8", "0x", "0x1e3")
           incomplet <- c("1E", "1e+", "1e-", "1e ", "2.5e")
           all(is.na(.cellules_en_nombre(hexa))) && all(is.na(.cellules_en_nombre(hexa, ","))) &&
             all(is.na(.cellules_en_nombre(incomplet))) &&
             identical(.cellules_en_nombre(c("Inf", "-Inf", "NaN")), c(Inf, -Inf, NaN)) &&
             # 0 seul, "x0", "10x" : non concernes par le motif d'hexadecimal
             identical(.cellules_en_nombre(c("0", "0.5", "x0", "10x")), c(0, 0.5, NA, NA))
         })
verifier("Lecture vecteur : \"1.500;2.100;980,5\" avec dec = \",\" refuse (cellule citee), \"1500;2100;980,5\" lu ; point en milieu de serie refuse avec sa position (#490, C6)",
         {
           lit <- function(l, sep = ",", dec = ".") {
             f <- tempfile(); writeLines(l, f, useBytes = TRUE)
             tryCatch(usp_lire_vecteur(f, sep, dec), error = function(e) conditionMessage(e))
           }
           a <- lit("1.500;2.100;980,5", ";", ",")
           b <- lit(c("x", "1,5", "2.100", "3"), ";", ",")
           c <- lit(c("1.500", "2.100", "980,5"), ";", ",")
           identical(lit("1500;2100;980,5", ";", ","), c(1500, 2100, 980.5)) &&
             identical(lit(c("x", "1.5", "2.100", "3")), c(1.5, 2.1, 3)) &&
             is.character(a) && contient(a, "\"1.500\"") && contient(a, "separateur decimal attendu : \",\"") &&
             is.character(b) && contient(b, "position 2") && contient(b, "\"2.100\"") &&
             is.character(c) && contient(c, "\"1.500\"")
         })
verifier("Lecture vecteur : hexadecimal refuse dans toutes les formes (colonne, ligne, ligne avec en-tetes), avec la cellule citee (#490, C11)",
         {
           lit <- function(l, sep = ",", dec = ".") {
             f <- tempfile(); writeLines(l, f, useBytes = TRUE)
             tryCatch(usp_lire_vecteur(f, sep, dec), error = function(e) conditionMessage(e))
           }
           col <- lit(c("x", "10", "0x10", "30"))
           tete <- lit(c("0x10", "11", "12"))
           lig <- lit("10,0x10,30")
           ent <- lit(c("a2017,a2018,a2019", "10,0x10,30"))
           is.character(col) && contient(col, "position 2") && contient(col, "\"0x10\"") &&
             is.character(tete) && contient(tete, "\"0x10\"") && contient(tete, "en position d'en-tete") &&
             is.character(lig) && contient(lig, "\"0x10\"") &&
             is.character(ent) && contient(ent, "position 2") && contient(ent, "\"0x10\"")
         })
verifier("Lecture t, xt, yt et triangle : hexadecimal refuse avec la position de la cellule, decimale ordinaire inchangee (#490, C11)",
         {
           d <- engine_lire_donnees_csv(data.frame(t = 1:5, xt = c("1", "0x10", "3", "4", "5"),
                                                   yt = c("1", "2", "3", "4", "0X1"), stringsAsFactors = FALSE))
           ok <- engine_lire_donnees_csv(data.frame(t = 1:5, xt = c("1.5", "1e2", "3", "4", "5"),
                                                    yt = 1:5, stringsAsFactors = FALSE))
           tri <- fichier_tri(t5); tri$j1 <- as.character(tri$j1); tri$j1[3] <- "0x10"
           r <- engine_lire_triangle(tri)
           !d$ok && contient(d$erreurs, "colonne xt : ligne(s) de donnees 2") && contient(d$erreurs, "colonne yt : ligne(s) de donnees 5") &&
             isTRUE(ok$ok) && identical(ok$xt, c(1.5, 100, 3, 4, 5)) &&
             !r$ok && contient(r$erreurs, "Cellule(s) non numerique(s) en (i = 2, j = 1)") && is.null(r$triangle)
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

## --- Pertes constantes (#189) ----------------------------------------------
# Jeu de l'issue : x = (100, ..., 700), y = 70 x 8. Avant #189 : constante
# stat Inf (INFO sans motif), TOST stat Inf, p = 1, ECHEC, pente et Fisher
# NaN avec "Pente identifiable", R2 NaN au motif R12. Predicat unique
# usp_pertes_constantes() (tolerance TOL_DELTA_BORD) ; les six lignes de
# la regression de y sur x (ligne Student comprise, #423) sont non
# applicables au motif propre ; les 41 autres lignes hors lecture
# conjointe et sigma_USP sont inchanges (comparaison a l'execution ou le
# predicat est neutralise). Libelles ecrits en dur (specification
# d'actuary).
x189 <- c(100, 150, 200, 300, 400, 500, 600, 700)
y189 <- rep(70, 8)
LIGNES_REG189 <- c(LIGNES_R12_168, LIGNE_R2_168)
detail_pc189 <- function(y) sprintf(paste(
  "regression de y sur x : pertes y_t constantes a la tolerance relative",
  "TOL_DELTA_BORD = %g pres (etendue relative = %.2g) : variance de y nulle",
  "a cette tolerance pres, regression de y sur x sans objet (convention de",
  "restitution), test non applicable"), 1e-6, diff(range(y)) / mean(y))
detail_r2_pc189 <- function(y) sprintf(paste(
  "pertes y_t constantes a la tolerance relative TOL_DELTA_BORD = %g pres",
  "(etendue relative = %.2g) : variance totale nulle a cette tolerance pres,",
  "R2 sans objet"), 1e-6, diff(range(y)) / mean(y))
avt_pc189 <- function(y) sprintf(paste(
  "Pertes y_t constantes a la tolerance relative TOL_DELTA_BORD = %g pres",
  "(etendue relative = %.2g) : regression de y sur x sans objet (constante,",
  "TOST, pente, Fisher et R2 non applicables) ; verifier la saisie."),
  1e-6, diff(range(y)) / mean(y))
lancer189 <- function(xx, yy, methode = "premium") suppressWarnings(
  run_engine(xt = xx, yt = yy, methode = methode, segment = 1, annexe = "II",
             nature_donnees = if (methode == "premium") "brutes",
             B = B_MIN_USAGE, seed = 20260831))
# Les six lignes au motif pertes constantes (ligne Student, #423) : non applicables, INFO, sans
# p ni statistique ni estimation, inoperant FALSE, detail exact ; chaine
# vide si conforme, sinon la liste des lignes fautives.
lignes_pc189 <- function(tt, y) {
  pb <- character(0)
  for (nm in LIGNES_REG189) {
    l <- ligne153(tt, nm)
    att <- if (nm == LIGNE_R2_168) detail_r2_pc189(y) else detail_pc189(y)
    if (!(identical(l$type, "non applicable") && identical(l$verdict, "INFO") &&
          is.na(l$p_retenue) && is.na(l$nature_p) && identical(l$inoperant, FALSE) &&
          is.na(l$stat) && is.na(l$estim) && is.na(l$p_asymptotique) &&
          identical(l$detail, att) && !grepl("identifiable", l$detail, ignore.case = TRUE)))
      pb <- c(pb, nm)
  }
  pb
}
verifier("usp_pertes_constantes() : rep(70, 8) TRUE, etendue relative 1e-6 TRUE, 1,0001e-6 FALSE, y153 FALSE ; meme reponse a x 1e-50 et x 1e50 (#189, U1)",
         {
           cas <- list(y189, 70 * (1 + c(0, 1e-6, rep(0, 6))) / (1 + 1e-6 / 8),
                       70 * (1 + c(0, 1.0001e-6, rep(0, 6))), y153)
           # Second cas : la division par 1 + 1e-6 / 8 ramene la moyenne a 70,
           # etendue relative 1e-6 / (1 + 1,25e-7), juste sous le bord, sans
           # dependre de l'arrondi d'une etendue egale a 1e-6.
           att <- c(TRUE, TRUE, FALSE, FALSE)
           obt <- vapply(cas, usp_pertes_constantes, logical(1))
           ech <- all(vapply(c(1e-50, 1e50), function(k)
             identical(vapply(cas, function(v) usp_pertes_constantes(v * k), logical(1)), att),
             logical(1)))
           ref <- vapply(cas, function(v) diff(range(v)) <= 1e-6 * mean(v), logical(1))
           identical(obt, att) && identical(ref, att) && ech
         })
res189 <- list(premium = lancer189(x189, y189, "premium"),
               reserve1 = lancer189(x189, y189, "reserve1"))
neutre189 <- avec_injection("usp_pertes_constantes", function(...) FALSE,
                            list(premium = lancer189(x189, y189, "premium"),
                                 reserve1 = lancer189(x189, y189, "reserve1")))
verifier("run_engine, jeu de l'issue (y = 70 x 8), premium et reserve1 : constante, TOST, pente (Pitman et Student, #423), Fisher et R2 non applicables au motif pertes constantes (INFO, p, stat, estim NA, inoperant FALSE) ; 41 autres lignes (LB1r retiree, #303 ; trois lignes retirees, #302), parametre_final et sigma_USP identical a l'execution au predicat neutralise, Spearman ratio / volume identique hors detail et sans renvoi (#189, U2 ; #215)",
         {
           pb <- character(0)
           for (m in names(res189)) {
             r <- res189[[m]]; r0 <- neutre189[[m]]
             if (!isTRUE(r$ok) || !isTRUE(r0$ok)) { pb <- c(pb, paste(m, "ok")); next }
             r$tests <- sans_famille297(r$tests); r0$tests <- sans_famille297(r0$tests)
             p <- lignes_pc189(r$tests, y189)
             if (length(p)) pb <- c(pb, paste(m, p))
             noms <- vapply(r$tests, function(l) l$test, ""); noms0 <- vapply(r0$tests, function(l) l$test, "")
             autres <- !noms %in% c(LIGNES_REG189, NOM_SV215)
             if (!identical(noms, noms0) || sum(autres) != 41L) pb <- c(pb, paste(m, "liste des lignes"))
             else if (!identical(r$tests[autres], r0$tests[autres])) pb <- c(pb, paste(m, "autres lignes"))
             else if (!sv_sans_renvoi215(ligne153(r$tests, NOM_SV215), ligne153(r0$tests, NOM_SV215)))
               pb <- c(pb, paste(m, "ligne Spearman ratio / volume"))
             if (!identical(r$parametre_final, r0$parametre_final)) pb <- c(pb, paste(m, "parametre_final"))
           }
           if (length(pb)) paste(pb, collapse = " ; ") else TRUE
         })
# Volumes et pertes constants : decision du mainteneur du 08/10/2026, #188 :
# le refus "maximum de vraisemblance non atteint" l'emporte dans
# run_engine() (ratios egaux, gamma sur la borne basse). La priorite R13 des
# six lignes est verifiee par appel direct a usp_tests() ; l'avertissement
# pertes constantes reste porte par le refus (U3 bis).
verifier("Volumes et pertes constants, usp_tests() en appel direct : les six lignes portent le motif R13 (priorite volumes constants) (#189, U3 ; #188)",
         {
           f <- usp_ajuster(rep(110, 8), y189)
           b <- suppressWarnings(usp_bootstrap(f, B = B_MIN_USAGE))
           tt <- tryCatch(suppressWarnings(usp_tests(f, b, methode = "premium")), error = function(e) e)
           !inherits(tt, "error") &&
             all(vapply(LIGNES_REG189, function(nm) {
               l <- ligne153(tt, nm)
               identical(l$type, "non applicable") && startsWith(l$detail, "volumes x_t constants")
             }, logical(1)))
         })
verifier("Volumes et pertes constants, run_engine() : ok = FALSE au motif borne basse, avertissement pertes constantes conserve (decision du mainteneur du 08/10/2026, #188 ; #189, U3 bis)",
         {
           r <- lancer189(rep(110, 8), y189)
           identical(r$ok, FALSE) && is.null(r$validation$erreur_r) &&
             identical(tail(r$validation$erreurs, 1), motif188("basse", "premium")) &&
             avt_pc189(y189) %in% r$validation$avertissements
         })
verifier("Priorite pertes constantes > marge et > x ecarte (R12) : y constant sous injection de summary() sans x -> TOST 'pertes constantes', six lignes au motif pertes constantes ; appel direct a marge invalide et y constant -> 'pertes constantes' (#189, U4)",
         {
           f <- usp_ajuster(x153, y189); b <- suppressWarnings(usp_bootstrap(f, B = B_MIN_USAGE))
           ref <- names(test_tost_intercept(x153, y153, pi153))
           r12 <- avec_r12_168(moteur168("test_tost_intercept")(x153, y189, f$pi))
           tt <- tryCatch(suppressWarnings(avec_r12_168(usp_tests(f, b, methode = "premium"))),
                          error = function(e) e)
           !inherits(tt, "error") && identical(r12$non_applicable, "pertes constantes") &&
             isTRUE(avec_summary_sans_x153(tost_coherent153(r12, ref, x153, y189, f$pi))) &&
             ligne_tost_coherente153(ligne153(tt, LIGNE_TOST153), r12, x153) &&
             !length(lignes_pc189(tt, y189)) &&
             identical(test_tost_intercept(x153, y189, f$pi, theta = -1)$non_applicable, "pertes constantes") &&
             identical(test_tost_intercept(x153, y189, f$pi, delta_abs = -1)$non_applicable, "pertes constantes") &&
             identical(names(test_tost_intercept(x153, y189, f$pi)), ref) &&
             identical(test_tost_intercept(x153, y153, pi153, theta = -1)$non_applicable, "marge") &&
             !exists("summary", envir = environment(run_engine), inherits = FALSE)
         })
verifier("Bord de la tolerance : etendue relative 1e-7 -> six lignes au motif pertes constantes ; 2e-6 -> lignes calculees, constante et TOST de type test (#189, U5)",
         {
           y7 <- 70 * (1 + c(0, 1e-7, rep(0, 6))); y6 <- 70 * (1 + c(0, 2e-6, rep(0, 6)))
           r7 <- lancer189(x189, y7); r6 <- lancer189(x189, y6)
           c7 <- diff(range(y7)) / mean(y7) <= 1e-6; c6 <- diff(range(y6)) / mean(y6) > 1e-6
           l6 <- lapply(LIGNES_REG189, function(nm) ligne153(r6$tests, nm))
           c7 && c6 && isTRUE(r7$ok) && isTRUE(r6$ok) && !length(lignes_pc189(r7$tests, y7)) &&
             identical(l6[[1]]$type, "test") && identical(l6[[2]]$type, "test") &&
             !any(vapply(l6, function(l) grepl("pertes y_t constantes", l$detail, fixed = TRUE), logical(1))) &&
             !any(grepl("Pertes y_t constantes", r6$validation$avertissements, fixed = TRUE))
         })
verifier("engine_valider_donnees() : avertissement pertes constantes (texte exact) present a y = 70 x 8 avec ok = TRUE, absent pour y153 ; porte par run_engine()$validation ; identique dans engine_valider_serie_retenue() (#189, U6)",
         {
           v <- engine_valider_donnees(x189, y189)
           v0 <- engine_valider_donnees(x153, y153)
           s <- engine_valider_serie_retenue(c(50, x189), c(90, y189), T = 8)$validation
           isTRUE(v$ok) && avt_pc189(y189) %in% v$avertissements &&
             !any(grepl("Pertes y_t constantes", v0$avertissements, fixed = TRUE)) &&
             all(vapply(res189, function(r) avt_pc189(y189) %in% r$validation$avertissements, logical(1))) &&
             identical(s$avertissements, v$avertissements) &&
             !any(grepl("Pertes y_t constantes",
                        engine_valider_serie_retenue(c(50, x189), c(90, y189))$validation$avertissements,
                        fixed = TRUE))
         })
verifier("Catalogue Monte-Carlo, y constant : statistique Intercept NA a l'observe sans erreur, p Monte-Carlo de la ligne constante NA (#189, U7)",
         {
           st <- tryCatch(USP_CATALOGUE_MC$Intercept$calc(list(x = x189, y = y189)), error = function(e) e)
           !inherits(st, "error") && identical(st, NA_real_) &&
             all(vapply(res189, function(r)
               is.na(ligne153(r$tests, "Nullite de la constante (proportionnalite stricte)")$p_mc),
               logical(1)))
         })

## --- Maximum de vraisemblance non atteint (E1g, #188) -------------------------
# Decisions du mainteneur du 08/10/2026 (option A) : run_engine() refuse
# (ok = FALSE, motif de usp_valider_ajustement()) quand gamma estime est sur
# une borne de BORNES_GAMMA (a TOL_DELTA_BORD pres ; gamma non fini classe
# borne basse) et qu'aucun demarrage a l'optimum ne satisfait la condition
# KKT ; classe quasi proportionnelle refusee ; le refus l'emporte a volumes
# et pertes constants. Refus au format du refus des donnees : ok,
# validation, metadata (horodatage seul), sans erreur_r ni resultat partiel.
# Volumes et pertes de test usuels du fichier, recopies : x est reaffecte
# plus haut dans le fichier (bloc de engine_lire_donnees_csv()).
xs188 <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
ys188 <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
w188 <- engine_sous_graine(15520, stats::rnorm(8))
lancer188 <- function(xx, yy, methode) suppressWarnings(
  run_engine(xt = xx, yt = yy, methode = methode, segment = 1, annexe = "II",
             nature_donnees = if (methode == "premium") "brutes",
             B = B_MIN_USAGE, seed = 20260831))
refus188 <- function(r, borne, methode)
  identical(r$ok, FALSE) && identical(names(r), c("ok", "validation", "metadata")) &&
    is.null(r$validation$erreur_r) && identical(names(r$metadata), c("horodatage", "methode")) &&
    identical(r$metadata$methode, methode) &&
    is.null(r$metadata$permutation_pente) &&
    identical(tail(r$validation$erreurs, 1), motif188(borne, methode))
jeux188 <- list(
  "0,7 x"                    = list(xs188, 0.7 * xs188, "basse"),
  "0,7 x exp(1e-9 w)"        = list(xs188, 0.7 * xs188 * exp(1e-9 * w188), "basse"),
  "x = 2^(0:7), y = x / 2"   = list(2^(0:7), 2^(0:7) / 2, "basse"),
  "x153, y = 0,7 x153"       = list(x153, 0.7 * x153, "basse"),
  "rep(100, 8) / rep(70, 8)" = list(rep(100, 8), rep(70, 8), "basse"),
  "x exp(3 w)"               = list(xs188, xs188 * exp(3 * w188), "haute"))
verifier("run_engine, premium et reserve1 : series proportionnelles, quasi proportionnelle, constantes (borne basse) et dispersion extreme (borne haute) -> ok = FALSE, sans erreur R ni erreur_r, names ok / validation / metadata, metadata = horodatage et methode (#405), sans permutation_pente, motif exact (#188)",
         {
           pb <- character(0)
           for (nm in names(jeux188)) for (m in c("premium", "reserve1")) {
             j <- jeux188[[nm]]
             r <- tryCatch(lancer188(j[[1]], j[[2]], m), error = function(e) e)
             if (inherits(r, "error") || !refus188(r, j[[3]], m)) pb <- c(pb, paste(nm, m))
           }
           if (length(pb)) paste(pb, collapse = " ; ") else TRUE
         })
# Frontiere en forme fermee : a ratios y_t/x_t = 0,7 exp(eps w_t), w centre
# reduit, delta = 1 et gamma = log(sqrt(expm1(eps^2 var(w)))) (variance de
# population) ; gamma atteint la borne basse en eps0 ci-dessous. Mesure :
# eps0 = 6,5684393e-6 sur les donnees de test. delta = 1 est verifie a
# TOL_DELTA_BORD pres, non au bit pres (sortie d'optimiseur ; revue finale
# d'E1g, /code-review).
wf188 <- as.numeric(scale(log(ys188 / xs188)))
eps0_188 <- sqrt(log1p(exp(2 * BORNES_GAMMA[1]))) / sqrt(mean((wf188 - mean(wf188))^2))
verifier("Frontiere en forme fermee (eps0 = 6,568e-6) : y = 0,7 x exp(eps w) accepte a eps0 (1 + 1e-3) (delta = 1), refuse au motif borne basse a eps0 (1 - 1e-3), premium et reserve1 (#188)",
         {
           y_in <- 0.7 * xs188 * exp(eps0_188 * (1 + 1e-3) * wf188)
           y_out <- 0.7 * xs188 * exp(eps0_188 * (1 - 1e-3) * wf188)
           f_in <- usp_ajuster(xs188, y_in)
           proche(eps0_188, 6.5684393e-6, rel = 1e-7) && isTRUE(abs(f_in$delta - 1) <= TOL_DELTA_BORD) &&
             all(vapply(c("premium", "reserve1"), function(m)
               isTRUE(lancer188(xs188, y_in, m)$ok) && refus188(lancer188(xs188, y_out, m), "basse", m),
               logical(1)))
         })
# Ajustements fictifs : seuls gamma et kkt_au_moins_un sont lus. Le cas
# (-12, KKT oui) n'est couvert que par cette voie : usp_kkt_satisfaite() rend
# FALSE des que gamma est sur une borne, et la conjonction n'agit que si un
# autre demarrage a l'optimum a un gamma interieur (audit du 08/10/2026).
verifier("usp_valider_ajustement(), ajustements fictifs : (-12, KKT non) refus ; (-12, KKT oui) accepte ; (-5, non) accepte ; (3, non) refus ; (NaN, non) refus borne basse ; (-12 + 2e-6, non) accepte (#188)",
         {
           v <- function(g, k, m = "premium") usp_valider_ajustement(list(gamma = g, kkt_au_moins_un = k), m)
           r1 <- v(-12, FALSE); r6 <- v(NaN, FALSE, "reserve1"); r4 <- v(3, FALSE)
           identical(r1, list(ok = FALSE, erreurs = motif188("basse", "premium"))) &&
             identical(v(-12, TRUE), list(ok = TRUE, erreurs = character(0))) &&
             isTRUE(v(-5, FALSE)$ok) &&
             identical(r4, list(ok = FALSE, erreurs = motif188("haute", "premium"))) &&
             identical(r6, list(ok = FALSE, erreurs = motif188("basse", "reserve1"))) &&
             isTRUE(v(-12 + 2e-6, FALSE)$ok)
         })
verifier("Volumes constants, pertes variables (x = 100 x 8, y des donnees de test) : run_engine ok = TRUE ; usp_valider_ajustement() ok, premium et reserve1 (#188)",
         {
           f <- usp_ajuster(rep(100, 8), ys188)
           isTRUE(lancer188(rep(100, 8), ys188, "premium")$ok) &&
             isTRUE(usp_valider_ajustement(f, "premium")$ok) &&
             isTRUE(usp_valider_ajustement(f, "reserve1")$ok)
         })
verifier("Pertes constantes et refus : x153, y = 70 x 8 accepte (ratios disperses) ; volumes et pertes constants refuses, avertissement pertes constantes conserve, premium et reserve1 (#188 ; #189)",
         {
           rr <- lapply(c("premium", "reserve1"), function(m) lancer188(rep(110, 8), y189, m))
           isTRUE(lancer188(x153, y189, "premium")$ok) &&
             refus188(rr[[1]], "basse", "premium") && refus188(rr[[2]], "basse", "reserve1") &&
             all(vapply(rr, function(r) avt_pc189(y189) %in% r$validation$avertissements, logical(1)))
         })
# Cas de non-regression (tests/outils_tests.R, CAS) : les quatre cas
# lognormaux (premium, reserve1, premium_ii6, premium_net) partagent
# tests/donnees/donnees_ln.csv ; reserve2 (Merz-Wuthrich) n'a pas
# d'ajustement lognormal et n'est pas concerne.
verifier("usp_valider_ajustement() : ok sur les donnees des cas de non-regression lognormaux (premium, reserve1, premium_ii6, premium_net) et sur les donnees de test (#188)",
         {
           ln <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
           fl <- usp_ajuster(ln$xt, ln$yt); ft <- usp_ajuster(xs188, ys188)
           all(vapply(list(fl, ft), function(f)
             identical(usp_valider_ajustement(f, "premium"), list(ok = TRUE, erreurs = character(0))) &&
               identical(usp_valider_ajustement(f, "reserve1"), list(ok = TRUE, erreurs = character(0))),
             logical(1)))
         })

## --- Refus juge sur l'ensemble des demarrages a l'optimum (Fc, #227) ---------
# Decisions du mainteneur du 17/10/2026 (Q-Fb-11, Q-D1-Fc-1 (a), Q-D1-Fc-2) :
# refus si au moins un demarrage a l'optimum a gamma sur une borne
# (fit$gamma_bord_au_moins_un, ou gamma retenu) et si aucun ne satisfait
# KKT. Forme 1 du motif (retenu sur une borne) : motif188(), inchange ;
# forme 2 (retenu interieur) : reconstruite ici morceau par morceau, au
# texte de la section 2.4 de docs/specifications/fc-validation-ajustement.md,
# independamment de usp_valider_ajustement().
motif227 <- function(methode = c("premium", "reserve1")) {
  methode <- match.arg(methode)
  prem <- methode == "premium"; sec <- if (prem) "B" else "C"
  tt <- sprintf(paste("Maximum de vraisemblance non etabli (annexe XVII, %s(6)) : parmi les",
                      "demarrages qui atteignent l'objectif minimal a la tolerance de l'outil,",
                      "au moins un a gamma sur une borne du domaine de recherche [-12 ; 3]",
                      "(BORNES_GAMMA, bornes de l'outil, non reglementaires) et aucun ne",
                      "satisfait la condition du premier ordre (KKT) ; le demarrage retenu, de",
                      "gamma interieur, n'est pas un point stationnaire certifie, et les valeurs",
                      "delta et gamma qui minimisent le montant de %s(6), dont depend le",
                      "parametre de %s(4), ne sont pas determinees dans ce domaine. Cause :",
                      "objectif egal, a cette tolerance, au demarrage retenu et sur la borne",
                      "(ratios y_t/x_t quasi egaux pres de la borne basse ; dispersion des",
                      "ratios extreme pres de la borne haute)."),
                sec, sec, sec)
  ff <- sprintf(paste("L'outil ne calcule pas de parametre sur ces donnees (article 220,",
                      "paragraphe 1, point %s), qui ne permettent d'etablir ni la",
                      "distribution log-normale ni l'adequation de l'estimation de la",
                      "vraisemblance maximum (%s, iii et iv ; article 219, paragraphe 1,",
                      "point d))."),
                if (prem) "a)" else "b)", if (prem) "B(2)(g)" else "C(2)(e)")
  rr <- "La methode du risque de reserve no 2 reste ouverte (meme point)."
  vv <- sprintf(paste("Verifier que y_t est observe (%s(1)(a)) et non deduit de x_t par un",
                      "coefficient fixe, ainsi que les unites, la correspondance des annees et",
                      "les valeurs aberrantes (%s(1) et %s(2)(a))."),
                sec, sec, sec)
  paste(c(tt, ff, if (!prem) rr, vv), collapse = " ")
}
# Ajustements fictifs a trois champs (gamma, kkt_au_moins_un,
# gamma_bord_au_moins_un) ; v2() a deux champs (champ absent).
v227 <- function(g, k, b, m) usp_valider_ajustement(
  list(gamma = g, kkt_au_moins_un = k, gamma_bord_au_moins_un = b), m)
v2_227 <- function(g, k, m) usp_valider_ajustement(list(gamma = g, kkt_au_moins_un = k), m)
OK227 <- list(ok = TRUE, erreurs = character(0))
verifier("usp_valider_ajustement(), critere (a) : (-12, KKT non, bord oui) refus forme 1 ; (-11,5, non, oui) refus forme 2 ; idem borne haute (3 forme 1, 2,5 forme 2) ; premium et reserve1 (#227)",
         all(vapply(c("premium", "reserve1"), function(m)
           identical(v227(-12, FALSE, TRUE, m), list(ok = FALSE, erreurs = motif188("basse", m))) &&
             identical(v227(-11.5, FALSE, TRUE, m), list(ok = FALSE, erreurs = motif227(m))) &&
             identical(v227(3, FALSE, TRUE, m), list(ok = FALSE, erreurs = motif188("haute", m))) &&
             identical(v227(2.5, FALSE, TRUE, m), list(ok = FALSE, erreurs = motif227(m))),
           logical(1))))
verifier("usp_valider_ajustement(), critere (b) : (-11,5, KKT oui, bord oui), (-12, oui, oui) et (-11,5, non, bord non) acceptes, premium et reserve1 (#227)",
         all(vapply(c("premium", "reserve1"), function(m)
           identical(v227(-11.5, TRUE, TRUE, m), OK227) &&
             identical(v227(-12, TRUE, TRUE, m), OK227) &&
             identical(v227(-11.5, FALSE, FALSE, m), OK227),
           logical(1))))
verifier("usp_valider_ajustement(), critere (c) : champ absent ou incoherent -> (-12, non) refus forme 1 ; (-11,5, non) accepte ; (-12, non, bord non) refus forme 1 ; (NaN, non) refus borne basse, premium et reserve1 (#227)",
         all(vapply(c("premium", "reserve1"), function(m)
           identical(v2_227(-12, FALSE, m), list(ok = FALSE, erreurs = motif188("basse", m))) &&
             identical(v2_227(-11.5, FALSE, m), OK227) &&
             identical(v227(-12, FALSE, FALSE, m), list(ok = FALSE, erreurs = motif188("basse", m))) &&
             identical(v2_227(NaN, FALSE, m), list(ok = FALSE, erreurs = motif188("basse", m))),
           logical(1))))
verifier("usp_ajuster(), critere (d) : gamma_bord_au_moins_un logique de longueur 1, dernier champ ; FALSE sur J1 (donnees_ln.csv) et J2 (donnees_ln_interieur.csv) ; TRUE sur y = 0,7 x, refus forme 1 inchange (#227)",
         {
           ln <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
           li <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln_interieur.csv"))
           f1 <- usp_ajuster(ln$xt, ln$yt); f2 <- usp_ajuster(li$xt, li$yt)
           fp <- usp_ajuster(xs188, 0.7 * xs188)
           all(vapply(list(f1, f2, fp), function(f)
             is.logical(f$gamma_bord_au_moins_un) && length(f$gamma_bord_au_moins_un) == 1L &&
               identical(utils::tail(names(f), 1), "gamma_bord_au_moins_un"), logical(1))) &&
             identical(f1$gamma_bord_au_moins_un, FALSE) && identical(f2$gamma_bord_au_moins_un, FALSE) &&
             identical(fp$gamma_bord_au_moins_un, TRUE) &&
             all(vapply(c("premium", "reserve1"), function(m)
               identical(usp_valider_ajustement(fp, m), list(ok = FALSE, erreurs = motif188("basse", m))),
               logical(1)))
         })
verifier("run_engine(), critere (d) : res$ajustement se termine par kkt_au_moins_un puis gamma_bord_au_moins_un (FALSE), premium (J1) et reserve1 (J2) (#227)",
         {
           ln <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
           li <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln_interieur.csv"))
           r1 <- lancer188(ln$xt, ln$yt, "premium"); r2 <- lancer188(li$xt, li$yt, "reserve1")
           all(vapply(list(r1, r2), function(r)
             isTRUE(r$ok) &&
               identical(utils::tail(names(r$ajustement), 2), c("kkt_au_moins_un", "gamma_bord_au_moins_un")) &&
               identical(r$ajustement$gamma_bord_au_moins_un, FALSE), logical(1)))
         })

## --- Avertissement "volumes constants" (Fc, #213) ----------------------------
# Decisions du mainteneur du 17/10/2026 (Q-D1-Fc-4, Q-D1-Fc-5 (b)) :
# engine_valider_donnees() avertit, sans refus, quand usp_volumes_constants()
# est vrai sur la serie retenue, immediatement avant l'avertissement des
# pertes constantes (#189) ; a pertes constantes (hors volumes constants), la
# ligne Spearman ratio / volume, calculee, porte une phrase de contexte fixe.
# J1 : donnees_ln.csv (= xs188, ys188), etendue relative des volumes 0,258.
avt_vc213 <- function(x) sprintf(paste(
  "Volumes x_t constants a la tolerance relative TOL_DELTA_BORD = %g pres",
  "(etendue relative = %.2g) : delta non identifie (la vraisemblance n'en",
  "depend pas a cette tolerance pres) ; regression et partition sur le volume",
  "sans objet (constante, TOST, pente, Fisher, R2, RESET, Spearman ratio /",
  "volume, Breusch-Pagan (Koenker et 1979), White, Goldfeld-Quandt,",
  "Brown-Forsythe et Smirnov non applicables) ; verifier la saisie."),
  TOL_DELTA_BORD, diff(range(x)) / mean(x))
a_vc213 <- function(avt) any(startsWith(avt, "Volumes x_t constants"))
# Texte de #514 (specification d'actuary, U8) : il remplace la base de la
# ligne, sans point final (detail_r7() le pose).
PHRASE_SV213 <- paste(
  "Pertes y_t constantes (voir l'avertissement sur les donnees) : le ratio varie en",
  "sens inverse du volume, et un ECHEC ou une ALERTE traduit des pertes non",
  "proportionnelles au volume.")
x213 <- rep(100, 8)
res213 <- list(premium = lancer189(x213, ys188, "premium"),
               reserve1 = lancer189(x213, ys188, "reserve1"))
# Correspondance un a un des noms cites par l'avertissement et des lignes de
# la regle R13 (Breusch-Pagan : deux lignes ; pente : Pitman et Student,
# #423).
CITES213 <- list(
  "constante" = "Nullite de la constante (proportionnalite stricte)",
  "TOST" = "Equivalence de la constante a zero (TOST)",
  "pente" = c("Test de Pitman sur la pente (lien positif pertes / volume)",
              "Test de Student sur la pente (modele auxiliaire MCO)"),
  "Fisher" = "Test de Fisher (significativite globale)",
  "R2" = "Coefficient de determination R2",
  "RESET" = "RESET (forme fonctionnelle)",
  "Spearman ratio / volume" = "Independance ratio S/P vs volume",
  "Breusch-Pagan (Koenker et 1979)" =
    c("Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)",
      "Heteroscedasticite vs volume - Breusch-Pagan original (non robuste)"),
  "White" = "Heteroscedasticite (forme quadratique)",
  "Goldfeld-Quandt" = "Egalite des variances petits vs gros volumes",
  "Brown-Forsythe" = "Homogeneite des dispersions (mediane)",
  "Smirnov" = "Egalite des lois petits vs gros volumes (2 ech.)")
verifier("Critere (a) : x = 100 x 8, y de J1, premium et reserve1 : run_engine ok = TRUE ; avertissement volumes constants present, texte exact, un de plus qu'au predicat neutralise dans engine_valider_donnees() (#213)",
         {
           v <- engine_valider_donnees(x213, ys188, segment = 1, annexe = "II")
           v0 <- avec_injection("usp_volumes_constants", function(...) FALSE,
                                engine_valider_donnees(x213, ys188, segment = 1, annexe = "II"))
           isTRUE(v$ok) && avt_vc213(x213) %in% v$avertissements &&
             length(v$avertissements) == length(v0$avertissements) + 1L &&
             identical(setdiff(v$avertissements, avt_vc213(x213)), v0$avertissements) &&
             all(vapply(res213, function(r) isTRUE(r$ok) &&
                          identical(r$validation$avertissements, v$avertissements), logical(1)))
         })
verifier("Critere (b) : noms cites par l'avertissement = lignes non applicables au motif R13, un a un (14 lignes, Breusch-Pagan et pente en comptent deux, #423), premium et reserve1 (#213)",
         {
           a <- avt_vc213(x213)
           liste <- sub(" non applicables\\).*$", "", sub("^.*sur le volume sans objet \\(", "", a))
           # "Breusch-Pagan (Koenker et 1979)" contient " et " : decoupage
           # sur le seul " et " final, puis sur les virgules.
           cites <- strsplit(sub(" et Smirnov$", ", Smirnov", liste), ", ", fixed = TRUE)[[1]]
           identical(cites, names(CITES213)) && length(unlist(CITES213)) == 14L &&
             all(vapply(res213, function(r) {
               na <- Filter(function(l) identical(l$type, "non applicable") &&
                              startsWith(l$detail, "volumes x_t constants"), r$tests)
               noms <- vapply(na, function(l) l$test, "")
               length(na) == 14L && !anyDuplicated(noms) &&
                 setequal(noms, unlist(CITES213, use.names = FALSE))
             }, logical(1)))
         })
verifier("Critere (c) : avertissement absent aux volumes de J1 (etendue 0,258), present a l'etendue relative 1e-7, absent a 2e-6, y de J1 (#213)",
         {
           x7 <- 100 * (1 + c(0, 1e-7, rep(0, 6))); x6 <- 100 * (1 + c(0, 2e-6, rep(0, 6)))
           v7 <- engine_valider_donnees(x7, ys188)
           !a_vc213(engine_valider_donnees(xs188, ys188)$avertissements) &&
             isTRUE(v7$ok) && avt_vc213(x7) %in% v7$avertissements &&
             !a_vc213(engine_valider_donnees(x6, ys188)$avertissements) &&
             diff(range(x7)) / mean(x7) <= TOL_DELTA_BORD && diff(range(x6)) / mean(x6) > TOL_DELTA_BORD
         })
verifier("Critere (d) : serie de 9 annees, la premiere a volume 50 : avertissement present sur les T = 8 retenues, absent sur la serie entiere ; run_engine(T = 8) l'emet (#213)",
         {
           xx <- c(50, x213); yy <- c(90, ys188)
           s8 <- engine_valider_serie_retenue(xx, yy, T = 8)$validation
           s9 <- engine_valider_serie_retenue(xx, yy)$validation
           r8 <- suppressWarnings(run_engine(xt = xx, yt = yy, T = 8, methode = "premium",
                                             segment = 1, annexe = "II", nature_donnees = "brutes",
                                             B = B_MIN_USAGE, seed = 20260831))
           avt_vc213(x213) %in% s8$avertissements && !a_vc213(s9$avertissements) &&
             isTRUE(r8$ok) && avt_vc213(x213) %in% r8$validation$avertissements
         })
verifier("Critere (e) : donnees refusees a volumes constants (y non positif ; T = 4) : ok = FALSE, avertissement absent (#213)",
         {
           v1 <- engine_valider_donnees(x213, replace(ys188, 2, -1))
           v2 <- engine_valider_donnees(rep(100, 4), ys188[1:4])
           identical(v1$ok, FALSE) && identical(v2$ok, FALSE) &&
             !a_vc213(v1$avertissements) && !a_vc213(v2$avertissements)
         })
verifier("Ordre : volumes et pertes constants (x = 110 x 8, y = 70 x 8) -> avertissement volumes constants immediatement avant celui des pertes constantes (#213 ; #189)",
         {
           a <- engine_valider_donnees(rep(110, 8), y189)$avertissements
           i <- match(avt_vc213(rep(110, 8)), a); j <- match(avt_pc189(y189), a)
           is.finite(i) && is.finite(j) && j == i + 1L
         })
verifier("Phrase de contexte Spearman ratio / volume (#213, Q-D1-Fc-5 (b)) : presente une fois a pertes constantes (y = 70 x 8, premium et reserve1), type et verdict inchanges au predicat neutralise, detail = la phrase, qui remplace la base depuis #514 (sans renvoi #215, la constante etant non applicable) ; absente sur J1 et a volumes constants (ligne non applicable)",
         {
           ok_pc <- all(vapply(names(res189), function(m) {
             l <- ligne153(res189[[m]]$tests, NOM_SV215); l0 <- ligne153(neutre189[[m]]$tests, NOM_SV215)
             identical(l$type, "test") && identical(l$type, l0$type) && identical(l$verdict, l0$verdict) &&
               lengths(regmatches(l$detail, gregexpr(PHRASE_SV213, l$detail, fixed = TRUE))) == 1L &&
               !grepl(PHRASE_SV213, l0$detail, fixed = TRUE) &&
               # Texte propre de #514 : la phrase seule, precedee de la mention
               # de regime (delta a la borne 1 sur ce jeu).
               endsWith(l$detail, PHRASE_SV213)
           }, logical(1)))
           rj <- lancer189(xs188, ys188)
           ok_pc && !grepl(PHRASE_SV213, ligne153(rj$tests, NOM_SV215)$detail, fixed = TRUE) &&
             all(vapply(res213, function(r) {
               l <- ligne153(r$tests, NOM_SV215)
               identical(l$type, "non applicable") && !grepl(PHRASE_SV213, l$detail, fixed = TRUE)
             }, logical(1)))
         })


## --- Exports de donnees relus au bit (#488) -----------------------------------
# engine_ecrire_csv() (export CSV des donnees de l'application) et
# engine_ecrire_xlsx() (ecrivain interne seul, avec ou sans openxlsx ;
# compression par le paquet zip s'il est installe, sinon utils::zip()). Le CSV
# est relu comme le fait lire_tableau() d'app.R (read.csv en texte, aucune
# chaine NA), le classeur par chaque chemin d'engine_lire_xlsx() disponible,
# puis par engine_lire_donnees_csv() / engine_lire_triangle().
env488 <- environment(run_engine)
# Paquets declares absents pour le moteur (substitution de requireNamespace
# dans son environnement, ADR 0016), retiree en sortie.
sans488 <- function(paquets, expr) {
  assign("requireNamespace", function(package, ...)
    if (package %in% paquets) FALSE else base::requireNamespace(package, ...), envir = env488)
  on.exit(rm("requireNamespace", envir = env488), add = TRUE)
  force(expr)
}
lire_csv488 <- function(f) utils::read.csv(f, colClasses = "character", blank.lines.skip = FALSE,
                                           check.names = FALSE, na.strings = character(0),
                                           row.names = NULL)
ecrire_csv488 <- function(d) { f <- tempfile(fileext = ".csv"); engine_ecrire_csv(d, f); f }
grille488 <- c(0.1, 1/3, 2001, 1e-300, 1.7976931348623157e308, 0.1 + 0.2, 5e-324, NA)
g488 <- data.frame(t = 1:8, xt = grille488, yt = c(7, rev(grille488[-8])))
lu488 <- engine_lire_donnees_csv(lire_csv488(f488 <- ecrire_csv488(g488)))
verifier("engine_ecrire_csv() : grille (0.1, 1/3, 2001, 1e-300, 1.7976931348623157e308, 0.1+0.2, 5e-324, NA) relue identical() par engine_lire_donnees_csv() (#488)",
         identical(lu488$xt, g488$xt) && identical(lu488$yt, g488$yt))
verifier("engine_ecrire_csv() : 15 chiffres si la relecture est exacte, sinon 17 ; 1.7976931348623157e308 ecrit en entier, NA en cellule vide (#488)",
         identical(readLines(f488)[c(1:3, 6, 9)],
                   c('"t","xt","yt"', "1,0.1,7", "2,0.33333333333333331,4.94065645841247e-324",
                     "5,1.7976931348623157e+308,1e-300", "8,,0.1")))
verifier("engine_ecrire_csv() : texte identique sous OutDec = \",\" (point decimal) (#488)",
         { op <- options(OutDec = ","); on.exit(options(op), add = TRUE)
           identical(readLines(ecrire_csv488(g488)), readLines(f488)) })
inf488 <- data.frame(t = 1:3, xt = c(Inf, -Inf, NaN), yt = c(1, 2, 3))
li488 <- engine_lire_donnees_csv(lire_csv488(fi488 <- ecrire_csv488(inf488)))
verifier("engine_ecrire_csv() : +-Inf ecrits \"Inf\" / \"-Inf\" et relus +-Inf ; NaN ecrit vide et relu NA (#488)",
         identical(readLines(fi488)[2:4], c("1,Inf,1", "2,-Inf,2", "3,,3")) &&
           identical(li488$xt, c(Inf, -Inf, NA)))
# Format de utils::write.csv(row.names = FALSE, na = "") garde : texte
# identique sur les donnees des six cas (tests/donnees/) et sur un tableau a
# chaines (guillemet interne, NA, facteur, logique, entier).
donnees488 <- lapply(c("donnees_ln.csv", "donnees_ln_interieur.csv", "triangle_mw.csv"),
                     function(n) utils::read.csv(file.path(RACINE, "tests", "donnees", n)))
chaines488 <- data.frame(a = c("x", 'di"t', NA), f = factor(c("u", NA, "v")), l = c(TRUE, NA, FALSE),
                         n = c(1L, NA, 3L), check.names = FALSE, stringsAsFactors = FALSE)
verifier("engine_ecrire_csv() : texte identique a celui de write.csv(row.names = FALSE, na = \"\") sur les donnees des six cas et un tableau a chaines (#488)",
         all(vapply(c(donnees488, list(chaines488)), function(d) {
           g <- tempfile(fileext = ".csv"); utils::write.csv(d, g, row.names = FALSE, na = "")
           identical(readLines(ecrire_csv488(d)), readLines(g))
         }, logical(1))))
# Jeux relus : donnees des six cas, en double ; serie et triangle perturbes
# (decimales a 17 chiffres, que write.csv ne restituait pas).
tri488 <- unname(as.matrix(donnees488[[3]][, -1])); storage.mode(tri488) <- "double"
export_tri488 <- function(m) { d <- data.frame(i = 0:(nrow(m) - 1L), m)
                               names(d) <- c("i", paste0("j", 0:(ncol(m) - 1L))); d }
serie488 <- function(d) data.frame(t = seq_len(nrow(d)), xt = as.double(d$xt), yt = as.double(d$yt))
jeux488 <- list(ln = serie488(donnees488[[1]]), ln_interieur = serie488(donnees488[[2]]),
                ln_pert = data.frame(t = 1:8, xt = as.double(donnees488[[1]]$xt) * pi / 3,
                                     yt = as.double(donnees488[[1]]$yt) / 7),
                tri = export_tri488(tri488), tri_pert = export_tri488(tri488 * pi / 3))
relu488 <- function(df, d) if ("i" %in% names(d)) {
  r <- engine_lire_triangle(df); m <- as.matrix(d[, -1]); dimnames(m) <- NULL
  isTRUE(r$ok) && identical(r$triangle, m)
} else { r <- engine_lire_donnees_csv(df); isTRUE(r$ok) && identical(r$xt, d$xt) && identical(r$yt, d$yt) }
verifier("engine_ecrire_csv() : donnees des six cas et jeux perturbes relus identical() par engine_lire_donnees_csv() / engine_lire_triangle() (#488)",
         all(vapply(jeux488, function(d) relu488(lire_csv488(ecrire_csv488(d)), d), logical(1))))
# Voies d'ecriture xlsx : paquet zip (s'il est installe), utils::zip() (paquet
# zip declare absent, commande zip requise) ; chemins de lecture : interne
# (openxlsx declare absent), openxlsx (s'il est installe).
voies488 <- list()
if (base::requireNamespace("zip", quietly = TRUE)) voies488$paquet_zip <- character(0) else
  cat("  [saute] export xlsx (#488), voie du paquet zip : paquet non installe\n")
if (nzchar(Sys.which("zip"))) voies488$utils_zip <- "zip" else
  cat("  [saute] export xlsx (#488), voie utils::zip() : commande zip indisponible\n")
lecteurs488 <- list(interne = "openxlsx")
if (base::requireNamespace("openxlsx", quietly = TRUE)) lecteurs488$openxlsx <- character(0) else
  cat("  [saute] export xlsx (#488), lecture par openxlsx : paquet non installe\n")
for (v488 in names(voies488)) {
  ecrire_x488 <- function(d) { f <- tempfile(fileext = ".xlsx"); sans488(voies488[[v488]], engine_ecrire_xlsx(d, f)); f }
  fg488 <- ecrire_x488(g488); fi488x <- ecrire_x488(inf488)
  verifier(sprintf("engine_ecrire_xlsx(), voie %s : [Content_Types].xml en premiere entree de l'archive (#488)", v488),
           identical(utils::unzip(fg488, list = TRUE)$Name[1], "[Content_Types].xml"))
  for (l488 in names(lecteurs488)) {
    lire_x488 <- function(f) { force(f); sans488(lecteurs488[[l488]], engine_lire_xlsx(f)) }
    verifier(sprintf("engine_ecrire_xlsx(), voie %s, lecture %s : grille relue identical(), +-Inf relus +-Inf, NaN relu NA (#488)", v488, l488),
             { r <- engine_lire_donnees_csv(lire_x488(fg488)); ri <- engine_lire_donnees_csv(lire_x488(fi488x))
               identical(r$xt, g488$xt) && identical(r$yt, g488$yt) && identical(ri$xt, c(Inf, -Inf, NA)) })
    verifier(sprintf("engine_ecrire_xlsx(), voie %s, lecture %s : donnees des six cas et jeux perturbes relus identical() (#488)", v488, l488),
             all(vapply(jeux488, function(d) relu488(lire_x488(ecrire_x488(d)), d), logical(1))))
  }
}
# Divergence documentee (en-tetes d'engine_ecrire_xlsx() et d'engine_lire_xlsx()) :
# chaines en ligne portant &, <, > et colonne logique, relues differemment par
# les deux chemins (mesure, openxlsx 4.2.9) ; la sortie d'openxlsx n'est pas
# retouchee. Comportement fige sur la premiere voie d'ecriture disponible.
if (length(voies488)) {
  div488 <- data.frame(c("a<b&c", "x>y", "simple"), c(TRUE, FALSE, NA), c(1.5, 2, 3),
                       stringsAsFactors = FALSE)
  names(div488) <- c("l&b", "l", "n")
  fd488 <- tempfile(fileext = ".xlsx")
  sans488(voies488[[1]], engine_ecrire_xlsx(div488, fd488))
  verifier("engine_ecrire_xlsx(), lecture interne : chaines et en-tete a &, <, > relus tels quels ; colonne logique relue en chaines \"TRUE\" / \"FALSE\" (#488)",
           identical(sans488("openxlsx", engine_lire_xlsx(fd488)),
                     data.frame(`l&b` = div488[[1]], l = c("TRUE", "FALSE", NA), n = div488$n,
                                check.names = FALSE, stringsAsFactors = FALSE)))
  if (base::requireNamespace("openxlsx", quietly = TRUE)) {
    verifier("engine_ecrire_xlsx(), lecture openxlsx : chaines et en-tete a &, <, > relus echappes (a&lt;b&amp;c), colonne logique relue en logique, sortie non retouchee (#488)",
             { o <- engine_lire_xlsx(fd488)
               identical(names(o), c("l&amp;b", "l", "n")) &&
                 identical(o[[1]], c("a&lt;b&amp;c", "x&gt;y", "simple")) &&
                 identical(o$l, c(TRUE, FALSE, NA)) && identical(o$n, div488$n) })
  } else cat("  [saute] divergence &, <, > et logique (#488), chemin openxlsx : paquet non installe\n")
}
verifier("engine_ecrire_xlsx() / engine_ecrire_csv() : requireNamespace() simule retire, moteur intact (#488)",
         !exists("requireNamespace", envir = env488, inherits = FALSE))
verifier("engine_ecrire_xlsx() : ni paquet zip ni commande zip -> erreur R ordinaire (pas usp_refus_lecture), motif nomme, aucun fichier ecrit (#488)",
         {
           f <- tempfile(fileext = ".xlsx")
           ancien <- Sys.getenv("R_ZIPCMD", unset = NA)
           Sys.setenv(R_ZIPCMD = "commande_zip_absente_usp488")
           on.exit(if (is.na(ancien)) Sys.unsetenv("R_ZIPCMD") else Sys.setenv(R_ZIPCMD = ancien), add = TRUE)
           e <- tryCatch(sans488("zip", engine_ecrire_xlsx(g488, f)), error = function(e) e)
           inherits(e, "error") && !inherits(e, "usp_refus_lecture") && !file.exists(f) &&
             grepl("ni le paquet R zip ni la commande zip du systeme ne sont disponibles",
                   conditionMessage(e), fixed = TRUE)
         })
# Repli de compression (revue finale de K2) : zip::zipr() en echec (paquet
# zip ancien, sans l'argument include_directories), simule par une
# substitution de "::" dans l'environnement du moteur (ADR 0016), retiree en
# sortie ; utils::zip() prend le relais si la commande existe, sinon l'erreur
# nomme les deux echecs, sans fichier laisse.
zipr_en_echec488 <- function(expr) {
  assign("::", function(pkg, name) {
    pkg <- as.character(substitute(pkg)); name <- as.character(substitute(name))
    if (pkg == "zip" && name == "zipr") function(...) stop("unused argument (include_directories = FALSE)")
    else getExportedValue(pkg, name)
  }, envir = env488)
  on.exit(rm("::", envir = env488), add = TRUE)
  force(expr)
}
if (base::requireNamespace("zip", quietly = TRUE)) {
  if (nzchar(Sys.which("zip"))) {
    verifier("engine_ecrire_xlsx() : zip::zipr() en echec et commande zip presente -> repli sur utils::zip(), classeur relu identical() (#488)",
             { f <- tempfile(fileext = ".xlsx"); zipr_en_echec488(engine_ecrire_xlsx(g488, f))
               r <- engine_lire_donnees_csv(sans488("openxlsx", engine_lire_xlsx(f)))
               identical(r$xt, g488$xt) && identical(r$yt, g488$yt) })
  } else cat("  [saute] repli de zip::zipr() sur utils::zip() (#488) : commande zip indisponible\n")
  verifier("engine_ecrire_xlsx() : zip::zipr() en echec et commande zip absente -> erreur R ordinaire nommant les deux echecs, aucun fichier ecrit (#488)",
           {
             f <- tempfile(fileext = ".xlsx")
             ancien <- Sys.getenv("R_ZIPCMD", unset = NA)
             Sys.setenv(R_ZIPCMD = "commande_zip_absente_usp488")
             on.exit(if (is.na(ancien)) Sys.unsetenv("R_ZIPCMD") else Sys.setenv(R_ZIPCMD = ancien), add = TRUE)
             e <- tryCatch(zipr_en_echec488(engine_ecrire_xlsx(g488, f)), error = function(e) e)
             inherits(e, "error") && !inherits(e, "usp_refus_lecture") && !file.exists(f) &&
               identical(conditionMessage(e), paste("Echec de la creation du fichier .xlsx (paquet zip : unused argument",
                                                    "(include_directories = FALSE) ; commande zip indisponible)."))
           })
  verifier("engine_ecrire_xlsx() : substitution de \"::\" retiree, moteur intact (#488)",
           !exists("::", envir = env488, inherits = FALSE))
} else cat("  [saute] repli de zip::zipr() (#488) : paquet zip non installe\n")
# Empreinte "donnees" du rapport fige (engine_empreinte()) egale apres
# reimport de chaque export (serie perturbee, premium, B = 99).
if (length(voies488)) {
  d488 <- jeux488$ln_pert
  calc488 <- function(xt, yt) run_engine(xt = xt, yt = yt, methode = "premium", segment = 1,
                                         annexe = "II", nature_donnees = "brutes", B = 99)
  e0_488 <- engine_empreinte(calc488(d488$xt, d488$yt))$donnees
  rc488 <- engine_lire_donnees_csv(lire_csv488(ecrire_csv488(d488)))
  fx488 <- tempfile(fileext = ".xlsx"); engine_ecrire_xlsx(d488, fx488)
  rx488 <- engine_lire_donnees_csv(engine_lire_xlsx(fx488))
  verifier("Empreinte \"donnees\" (engine_empreinte()) egale apres reimport de l'export CSV et de l'export xlsx (#488)",
           is.character(e0_488) && !is.na(e0_488) &&
             identical(engine_empreinte(calc488(rc488$xt, rc488$yt))$donnees, e0_488) &&
             identical(engine_empreinte(calc488(rx488$xt, rx488$yt))$donnees, e0_488))
} else cat("  [saute] empreinte apres reimport xlsx (#488) : aucune voie d'ecriture xlsx\n")

fin_fichier()
