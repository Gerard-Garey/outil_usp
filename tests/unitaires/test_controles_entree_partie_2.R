###############################################################################
#  tests/unitaires/test_controles_entree_partie_2.R  --  CONTROLES D'ENTREE,
#  seconde partie
#
#  Seconde moitie de test_controles_entree.R (voir son en-tete pour les
#  fonctions visees et la reference), coupee en deux fichiers (issue #561, etape
#  4 de S8) pour raccourcir le chemin critique d'un lot de la CI. Sections :
#  donnees a l'echelle extreme (#88, #145), distance de Cook a toute echelle et
#  controles d'usage (#153 et suivants), pertes constantes (#189), maximum de
#  vraisemblance non atteint (#188), refus juge sur l'ensemble des demarrages
#  (#227), avertissement "volumes constants" (#213). Le texte, l'ordre
#  relatif et les assertions des sections sont ceux de test_controles_entree.R
#  d'avant la coupe ; x, y et contient sont recopies de son en-tete.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_controles_entree_partie_2.R")

x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
contient <- function(txt, motif) any(grepl(motif, txt, fixed = TRUE))

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
             nature_donnees = "brutes", date_reference = DATE_REFERENCE_TESTS))
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
  v1 <- sprintf("Verifier que y_t est observe (%s(1)(a)) et non deduit de x_t par un coefficient fixe.", sec)
  v2 <- sprintf("Verifier les unites, la correspondance des annees et les valeurs aberrantes (%s(1) et %s(2)(a)).",
                sec, sec)
  paste(c(tt, if (borne == "basse") c1 else c2, ff,
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
           r <- tryCatch(run_engine(methode = "reserve2", triangle = tri, segment = 1, B = B_MIN_USAGE,
                                    date_reference = DATE_REFERENCE_TESTS),
                         error = function(err) err,
                         finally = assign("mw_bootstrap", orig, envir = e))
           !inherits(r, "error") && identical(r$ok, FALSE) && !"methode" %in% names(r) &&
             identical(r$metadata$methode, "reserve2") &&
             contient(r$validation$erreurs, "Defaut de calcul intercepte dans la fonction mw_bootstrap() du moteur :") &&
             identical(r$validation$erreur_r$origine, "mw_bootstrap")
         })
verifier("run_engine : erreurs d'usage -> erreur R explicite, non interceptee (annexe III, methode 'prime', segment 99, reserve2 sans triangle, xt manquant, B = -1, 0 ou 98, seed NA, bareme 'x')",
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", annexe = "III", segment = 1,
                                B = B_MIN_USAGE, nature_donnees = "brutes",
                                date_reference = DATE_REFERENCE_TESTS)) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "prime", segment = 1, B = B_MIN_USAGE,
                                date_reference = DATE_REFERENCE_TESTS)) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", segment = 99, B = B_MIN_USAGE,
                                nature_donnees = "brutes", date_reference = DATE_REFERENCE_TESTS)) &&
         leve_erreur(run_engine(methode = "reserve2", B = B_MIN_USAGE,
                                date_reference = DATE_REFERENCE_TESTS)) &&
         leve_erreur(run_engine(yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                                nature_donnees = "brutes", date_reference = DATE_REFERENCE_TESTS)) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = -1,
                                nature_donnees = "brutes", date_reference = DATE_REFERENCE_TESTS)) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = 0,
                                nature_donnees = "brutes", date_reference = DATE_REFERENCE_TESTS)) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = 98,
                                nature_donnees = "brutes", date_reference = DATE_REFERENCE_TESTS)) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                                seed = NA, nature_donnees = "brutes",
                                date_reference = DATE_REFERENCE_TESTS)) &&
         leve_erreur(run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                                bareme = "x", nature_donnees = "brutes",
                                date_reference = DATE_REFERENCE_TESTS)))

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
                                                B = B_MIN_USAGE, nature_donnees = "brutes",
                                                date_reference = DATE_REFERENCE_TESTS), ...)
usage_mw <- function(...) appel_usage(list(methode = "reserve2", triangle = tri_usage,
                                           segment = 1, B = B_MIN_USAGE,
                                           date_reference = DATE_REFERENCE_TESTS), ...)
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
# Issue #583 (c) : l'application transmet input$B entier (10L) ; le motif ne
# cite plus "10L" mais "10", comme pour le double 10 (premium et reserve2).
# alpha garde son point decimal (contrat de #133 et de #439).
verifier("run_engine : B = 10L et B = 10 -> meme message, commencant par \"B = 10 : \" (premium, reserve2 ; #583)",
         {
           m <- function(f, B) tryCatch({ f(B = B); NA_character_ }, error = conditionMessage)
           mp <- m(usage_premium, 10L); mw <- m(usage_mw, 10L)
           identical(mp, m(usage_premium, 10)) && identical(mw, m(usage_mw, 10)) &&
             startsWith(mp, "B = 10 : ") && startsWith(mw, "B = 10 : ") &&
             !grepl("10L", mp, fixed = TRUE) && !grepl("10L", mw, fixed = TRUE)
         })
verifier("run_engine : alpha = 0,3 -> motif cite \"alpha = 0.3 : \", point decimal conserve (#133, #583)",
         startsWith(message_usage(alpha = 0.3), "alpha = 0.3 : "))

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
            nature_donnees = "brutes", date_reference = DATE_REFERENCE_TESTS)
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
  s <- list(..., date_reference = DATE_REFERENCE_TESTS)
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
                            theta_equiv = NA, date_reference = DATE_REFERENCE_TESTS)
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
           r <- run_engine(xt = x, yt = y, segment = 1, B = B_MIN_USAGE, nature_donnees = "brutes",
                           date_reference = DATE_REFERENCE_TESTS)
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
                                        B = B_MIN_USAGE, triangle = tri_usage,
                                        date_reference = DATE_REFERENCE_TESTS))
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
                           nature_donnees = "brutes", date_reference = DATE_REFERENCE_TESTS)
           ancien <- options(usp.engine.lever_erreurs = TRUE)
           b <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = B_MIN_USAGE,
                           nature_donnees = "brutes", date_reference = DATE_REFERENCE_TESTS)
           options(ancien)
           identical(sans_temps(a), sans_temps(b))
         })

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
             B = B_MIN_USAGE, seed = 20260831, date_reference = DATE_REFERENCE_TESTS))
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
             B = B_MIN_USAGE, seed = 20260831, date_reference = DATE_REFERENCE_TESTS))
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
  vv <- sprintf(paste("Verifier que y_t est observe (%s(1)(a)) et non deduit de x_t par un",
                      "coefficient fixe, ainsi que les unites, la correspondance des annees et",
                      "les valeurs aberrantes (%s(1) et %s(2)(a))."),
                sec, sec, sec)
  paste(c(tt, ff, vv), collapse = " ")
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
# #573 (texte vise par le mainteneur le 14/11/2026, suppression pure) : le
# motif de refus ne qualifie plus la methode du risque de reserve no 2 de
# "reste ouverte", dans les deux formes et aux deux bornes ; la phrase de
# l'article 220(1) est suivie directement de la phrase "Verifier...".
verifier("usp_valider_ajustement(), reserve1 : motif sans la phrase \"reste ouverte\" (formes 1 et 2, deux bornes), article 220(1)(b) suivi de \"Verifier\" (#573)",
         {
           mm <- c(v227(-12, FALSE, TRUE, "reserve1")$erreurs, v227(-11.5, FALSE, TRUE, "reserve1")$erreurs,
                   v227(3, FALSE, TRUE, "reserve1")$erreurs, v227(2.5, FALSE, TRUE, "reserve1")$erreurs)
           length(mm) == 4L && !any(grepl("reste ouverte", mm, fixed = TRUE)) &&
             !any(grepl("reserve no 2", mm, fixed = TRUE)) &&
             all(grepl("point d)). Verifier ", mm, fixed = TRUE))
         })
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
                                             B = B_MIN_USAGE, seed = 20260831,
                                             date_reference = DATE_REFERENCE_TESTS))
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

fin_fichier()
