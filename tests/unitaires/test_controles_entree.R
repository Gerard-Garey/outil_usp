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

## --- Donnees a l'echelle extreme (issue #88) ---------------------------------
# Defaut releve par audit (audit leger de #33) : des donnees finies et
# strictement positives mais a l'echelle extreme passaient la validation et
# faisaient lever une erreur R en cours de calcul (xt x 1e298 : lm.fit() de
# test_white(), regresseur x^2 infini, jusqu'a l'issue #110 ; yt x 1e-300 :
# test logique sur NA dans le detail de la distance de Cook). Depuis #110,
# RESET et White regressent sur la base reduite s = (x - moyenne) / etendue :
# xt x 1e298 et xt x 1e200 aboutissent (ok = TRUE, residus z egaux a ceux de
# l'echelle 1). Decision du mainteneur (26/09/2026)
# : filet limite au calcul qui suit une validation reussie ; l'erreur y est
# un DEFAUT DE CALCUL INTERCEPTE (ok = FALSE, motif neutre, diagnostic dans
# validation$erreur_r) ; les erreurs d'usage restent des erreurs R. Aucun
# seuil d'echelle. Les motifs compares sont les textes fixes du moteur, en
# ASCII, jamais le message traduit de conditionMessage().
MOTIF_DEFAUT <- "Defaut de calcul intercepte"
calcul_extreme <- function(xt, yt) suppressWarnings(
  run_engine(xt = xt, yt = yt, methode = "premium", segment = 1, B = B_MIN_USAGE,
             nature_donnees = "brutes"))
verifier("run_engine : yt x 1e-300, xt et yt x 1e-300 -> ok = FALSE, defaut intercepte, sans erreur R (#88)",
         all(vapply(list(list(x, y * 1e-300), list(x * 1e-300, y * 1e-300)), function(d) {
           r <- tryCatch(calcul_extreme(d[[1]], d[[2]]), error = function(e) e)
           er <- r$validation$erreur_r
           !inherits(r, "error") && identical(r$ok, FALSE) && inherits(r, "usp_engine") &&
             contient(r$validation$erreurs, MOTIF_DEFAUT) &&
             is.list(er) && identical(names(er), c("message", "appel", "origine", "pile")) &&
             is.character(er$message) && length(er$pile) >= 1L &&
             is.character(er$origine) && length(er$origine) == 1L && er$origine %in% er$pile &&
             identical(r$methode, "premium") && identical(r$metadata$methode, "premium")
         }, logical(1))))
verifier("run_engine : xt x 1e298 et xt x 1e200 -> ok = TRUE, residus z egaux a ceux de l'echelle 1 (base reduite de RESET et White, #110)",
         {
           z1 <- calcul_extreme(x, y)$ajustement$z
           all(vapply(c(1e298, 1e200), function(cc) {
             r <- tryCatch(calcul_extreme(x * cc, y), error = function(e) e)
             !inherits(r, "error") && identical(r$ok, TRUE) &&
               isTRUE(all.equal(r$ajustement$z, z1))
           }, logical(1)))
         })
# Origine = derniere fonction de la pile definie dans le moteur. yt x 1e-300 :
# l'erreur nait du if (any(ck > 4 / T)) ecrit dans usp_tests(), passe en
# argument de sprintf() dans add() et evalue paresseusement dans le cadre de
# sprintf() ; add() est une fermeture creee par engine_registre_tests(), non
# une fonction de l'environnement du moteur : l'origine est usp_tests.
# Plus de scenario connu d'erreur nee dans une fonction de test appelee par
# le bootstrap (xt x 1e298, lm.fit() dans test_white(), resolu par #110).
verifier("run_engine : origine reelle de l'erreur, fonction du moteur (yt x 1e-300 : usp_tests, pile usp_tests > add > sprintf)",
         {
           b <- calcul_extreme(x, y * 1e-300)$validation
           identical(b$erreur_r$pile, c("usp_tests", "add", "sprintf")) &&
             identical(b$erreur_r$origine, "usp_tests") &&
             contient(b$erreurs, "(erreur R dans usp_tests())")
         })
verifier("run_engine : xt x 1e-300 (cas cite par l'issue) -> aucune erreur R, ok logique",
         {
           r <- tryCatch(calcul_extreme(x * 1e-300, y), error = function(e) e)
           !inherits(r, "error") && is.logical(r$ok) && length(r$ok) == 1L && !is.na(r$ok)
         })
verifier("run_engine : generateur et graine de l'appelant restaures apres un defaut intercepte",
         {
           kind0 <- RNGkind()
           suppressWarnings(RNGkind("Wichmann-Hill", "Box-Muller", "Rounding"))
           set.seed(7); avant <- .Random.seed; k_avant <- RNGkind()
           r <- calcul_extreme(x, y * 1e-300)
           ok <- identical(r$ok, FALSE) && identical(.Random.seed, avant) &&
             identical(RNGkind(), k_avant)
           suppressWarnings(RNGkind(kind0[1], kind0[2], kind0[3]))
           ok
         })
verifier("run_engine : options(usp.engine.lever_erreurs = TRUE) releve l'erreur au lieu de l'intercepter",
         {
           ancien <- options(usp.engine.lever_erreurs = TRUE)
           leve <- leve_erreur(calcul_extreme(x, y * 1e-300))
           options(ancien)
           leve && identical(calcul_extreme(x, y * 1e-300)$ok, FALSE)
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
  r$add("F", "t", "ref", mc_nom = "A")
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
