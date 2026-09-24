###############################################################################
#  tests/unitaires/test_comparateur.R  --  COMPARATEUR DE NON-REGRESSION
#  (issue #14, point 1 ; ADR 0006, second amendement)
#
#  Teste comparer_objets() et ecart_feuille() de tests/outils_tests.R sur des
#  objets construits a la main : critere element par element a la tolerance
#  TOLERANCE (1e-6), bascule vers l'absolu pour une reference nulle, valeurs
#  non finies, chemins absents ou ajoutes, structure (attributs) de l'objet.
#
#  Reference : la regle ecrite dans l'ADR 0006 (second amendement, point 4),
#  appliquee a la main sur des valeurs choisies de part et d'autre du seuil,
#  et all.equal(tolerance = 1e-8), le critere agrege remplace, pour montrer
#  le cas qu'il laissait passer.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_comparateur.R")

# outils_tests.R est source dans un environnement dedie, comme le fait
# test_patcher_reference.R : le moteur qu'il charge n'atteint pas
# l'environnement global.
.dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
outils_env <- new.env(parent = globalenv())
sys.source(file.path(.dossier, "..", "outils_tests.R"), envir = outils_env)
comparer <- outils_env$comparer_objets
ecart_f  <- outils_env$ecart_feuille

verifier("La tolerance de non-regression est 1e-6 (decision M9)",
         identical(outils_env$TOLERANCE, 1e-6))

## --- Une feuille perturbee parmi des milliers --------------------------------
# Objet deterministe (aucun tirage) : 5 000 valeurs d'ordre 1, plus quelques
# champs d'autres types, pour que la comparaison traverse tout l'arbre.
x <- 1.5 + sin(seq_len(5000))
ref <- list(sigma = 0.111452435874631, boot = list(draws = x),
            tests = list(list(test = "DW", p = 0.25, verdict = "OK")),
            tab = data.frame(a = 1:3, b = c(0.1, 0.2, 0.3)))
k <- 4321L
perturbe <- function(eps) { o <- ref; o$boot$draws[k] <- o$boot$draws[k] * (1 + eps); o }

verifier("Objet compare a lui-meme : conforme, aucune feuille differente, ecart maximal nul",
         { r <- comparer(ref, ref)
           r$conforme && r$n_differentes == 0L && r$n_ecarts == 0L && r$ecart_max == 0 &&
             r$n_feuilles == 1L + 5000L + 3L + 6L })

# all.equal.numeric ne moyenne que sur les elements DIFFERENTS d'un meme
# vecteur (countEQ = FALSE) : seule, une feuille perturbee y est jugee
# isolement. La dilution se produit quand les autres elements du vecteur
# derivent aussi, ce qui est le cas reel (44 % des feuilles de premium.rds
# different entre plateformes, issue #14) : ici, derive de 5e-9 sur tous les
# tirages et une feuille perturbee de 2e-6.
verifier("Feuille perturbee de 2e-6 parmi 5 000 qui derivent de 5e-9 : detectee et nommee, la ou all.equal(1e-8) agrege l'accepte",
         { o <- ref; o$boot$draws <- o$boot$draws * (1 + 5e-9)
           o$boot$draws[k] <- ref$boot$draws[k] * (1 + 2e-6); r <- comparer(ref, o)
           isTRUE(all.equal(ref, o, tolerance = 1e-8)) &&
             !r$conforme && r$n_ecarts == 1L && r$n_differentes == 5000L &&
             identical(r$ecarts$chemin, sprintf("boot$draws[%d]", k)) &&
             identical(r$ecarts$mesure, "relatif") &&
             abs(r$ecarts$ecart - 2e-6) < 1e-12 })

verifier("Feuille perturbee de 5e-7 : acceptee, mais comptee comme non identique et mesuree",
         { r <- comparer(ref, perturbe(5e-7))
           r$conforme && r$n_ecarts == 0L && r$n_differentes == 1L &&
             identical(r$feuille_max, sprintf("boot$draws[%d]", k)) &&
             identical(r$mesure_max, "relatif") && abs(r$ecart_max - 5e-7) < 1e-12 })

verifier("Derive diffuse de 5e-7 sur toutes les feuilles : acceptee (aucune moyenne, chaque valeur sous le seuil)",
         { o <- ref; o$boot$draws <- o$boot$draws * (1 + 5e-7)
           r <- comparer(ref, o); r$conforme && r$n_differentes == 5000L })

## --- Reference nulle ou quasi nulle : bascule vers l'absolu ---------------
verifier("Reference nulle, valeur 1e-16 (arrondi) : conforme en absolu",
         { j <- ecart_f(0, 1e-16); j$conforme && identical(j$mesure, "absolu") })
verifier("Reference 1e-16, valeur -2e-16 : conforme en absolu (ecart relatif 3, sans objet)",
         { j <- ecart_f(1e-16, -2e-16); j$conforme && identical(j$mesure, "absolu") })
verifier("Reference nulle, valeur 2e-6 : ecart en absolu",
         { j <- ecart_f(0, 2e-6); !j$conforme && identical(j$mesure, "absolu") })
verifier("Reference 1e-6 (egale au seuil) : jugee en absolu ; 1,9e-6 conforme, 2,1e-6 en ecart",
         { j1 <- ecart_f(1e-6, 1.9e-6); j2 <- ecart_f(1e-6, 2.1e-6)
           j1$conforme && !j2$conforme && identical(j1$mesure, "absolu") })
verifier("Reference 2e-6 : jugee en relatif",
         { j <- ecart_f(2e-6, 2e-6 * (1 + 2e-6)); !j$conforme && identical(j$mesure, "relatif") })

# Implementation independante : pour une feuille finie, la regle est celle de
# all.equal.numeric appliquee a UNE valeur (difference relative si
# |reference| > tol, absolue sinon). Grille de references et d'ecarts de part
# et d'autre du seuil, en relatif comme en absolu.
verifier("Feuille finie : meme verdict que all.equal(ref, val, tolerance = 1e-6) sur une grille de 169 couples",
         { refs <- c(0, 1e-16, -3e-9, 5e-7, 1e-6, 1.5e-6, -2e-6, 1e-3, 0.11, -1, 7.5, 1e4, -1e12)
           facteurs <- c(0, 1e-9, 3e-7, 9.99e-7, 1.01e-6, 2e-6, 1e-3, -1e-9, -9.99e-7, -1.01e-6, -1e-3, 1, -2)
           all(vapply(refs, function(a) all(vapply(facteurs, function(f) {
             b <- if (abs(a) > 1e-6) a * (1 + f) else a + f
             identical(ecart_f(a, b, 1e-6)$conforme, isTRUE(all.equal(a, b, tolerance = 1e-6)))
           }, logical(1))), logical(1))) })

## --- Valeurs non finies -----------------------------------------------------
verifier("NA de reference contre une valeur : ecart",
         { j <- ecart_f(NA_real_, 1); !j$conforme && identical(j$mesure, "non fini") })
verifier("Valeur de reference contre NA : ecart",
         { j <- ecart_f(1, NA_real_); !j$conforme && identical(j$mesure, "non fini") })
verifier("NA contre NaN : ecart ; NA contre NA, Inf contre Inf : conformes",
         !ecart_f(NA_real_, NaN)$conforme && ecart_f(NA_real_, NA_real_)$conforme &&
           ecart_f(Inf, Inf)$conforme && !ecart_f(Inf, -Inf)$conforme && !ecart_f(Inf, 1e300)$conforme)
verifier("NA dans un objet : detecte par comparer_objets",
         { o <- ref; o$tests[[1]]$p <- NA_real_; r <- comparer(ref, o)
           !r$conforme && identical(r$ecarts$chemin, "tests[[1]]$p") })

## --- Feuilles non numeriques --------------------------------------------
verifier("Chaine modifiee : ecart ; entier contre double de meme valeur : ecart (type change)",
         { o <- ref; o$tests[[1]]$verdict <- "REJET"
           !comparer(ref, o)$conforme && !ecart_f(1L, 1)$conforme && !ecart_f(TRUE, 1)$conforme })

## --- Chemins absents ou ajoutes ---------------------------------------------
verifier("Feuille manquante : ecart 'absente'",
         { o <- ref; o$tests[[1]]$p <- NULL; r <- comparer(ref, o)
           !r$conforme && "tests[[1]]$p" %in% r$ecarts$chemin[r$ecarts$mesure == "absente"] })
verifier("Feuille ajoutee : ecart 'ajoutee'",
         { o <- ref; o$tests[[1]]$err_mc <- 0.01; r <- comparer(ref, o)
           !r$conforme && "tests[[1]]$err_mc" %in% r$ecarts$chemin[r$ecarts$mesure == "ajoutee"] })
verifier("Tirage bootstrap en moins : ecart",
         { o <- ref; o$boot$draws <- o$boot$draws[-5000]; !comparer(ref, o)$conforme })

## --- Structure : ce qu'aplatir() ne voit pas ---------------------------------
verifier("dim changee, feuilles identiques : ecart de structure",
         { a <- list(m = matrix(1:6 / 7, 2)); b <- list(m = matrix(1:6 / 7, 3))
           identical(outils_env$aplatir(a), outils_env$aplatir(b)) &&
             { r <- comparer(a, b); !r$conforme && identical(r$structure, "m") && r$n_ecarts == 0L } })
verifier("class changee (data.frame -> liste), feuilles identiques : ecart de structure",
         { o <- ref; o$tab <- as.list(o$tab); r <- comparer(ref, o)
           !r$conforme && "tab" %in% r$structure })
verifier("row.names changes : ecart de structure",
         { o <- ref; row.names(o$tab) <- c("x", "y", "z"); r <- comparer(ref, o)
           !r$conforme && "tab" %in% r$structure })
verifier("Liste vide ajoutee (aucune feuille) : ecart de structure",
         { o <- ref; o$vide <- list(); r <- comparer(ref, o)
           identical(outils_env$aplatir(ref), outils_env$aplatir(o)) && !r$conforme })
verifier("Nom d'un scalaire change (invisible dans le chemin) : ecart",
         { a <- list(s = c(u = 1)); b <- list(s = c(v = 1)); !comparer(a, b)$conforme })

## --- Cas limites (constats d'audit, verifies a la main puis figes ici) ----
verifier("NA_integer_ contre NA_real_ : ecart (type change)",
         { j <- ecart_f(NA_integer_, NA_real_); !j$conforme && identical(j$mesure, "non numerique") })
verifier("NA logique contre NA_real_ : ecart",
         { j <- ecart_f(NA, NA_real_); !j$conforme && identical(j$mesure, "non numerique") })
verifier("Longueur 0 contre longueur 1 : ecart, dans une feuille comme dans un objet",
         !ecart_f(numeric(0), 1)$conforme && !ecart_f(character(0), "a")$conforme &&
           !comparer(list(a = numeric(0)), list(a = 0))$conforme)
verifier("Facteur : niveaux changes (memes etiquettes) -> ecart ; facteur contre caractere -> ecart",
         { f1 <- list(f = factor(c("a", "b"))); f2 <- list(f = factor(c("a", "b"), levels = c("b", "a")))
           r1 <- comparer(f1, f2); r2 <- comparer(f1, list(f = c("a", "b")))
           !r1$conforme && "f" %in% r1$structure && !r2$conforme && "f" %in% r2$structure })
verifier("Chemins dupliques dans aplatir() (deux entrees 'a') : un changement sur la seconde est detecte",
         { a <- list(a = 1, a = 2); b <- list(a = 1, a = 3)
           anyDuplicated(names(outils_env$aplatir(a))) > 0L && !comparer(a, b)$conforme &&
             comparer(a, a)$conforme })
verifier("Nom contenant '$' qui masque une imbrication (a$b contre a puis b) : ecart de structure",
         { a <- stats::setNames(list(1), "a$b"); b <- list(a = list(b = 1))
           identical(outils_env$aplatir(a), outils_env$aplatir(b)) &&
             { r <- comparer(a, b); !r$conforme && length(r$structure) > 0L } })
verifier("data.frame avec une ligne en plus : ecart (feuilles ajoutees et row.names)",
         { o <- ref; o$tab <- rbind(o$tab, data.frame(a = 4L, b = 0.4)); r <- comparer(ref, o)
           !r$conforme && any(r$ecarts$mesure == "ajoutee") && "tab" %in% r$structure })
verifier("data.frame avec une colonne renommee : ecart (chemins absents et ajoutes)",
         { o <- ref; names(o$tab)[2] <- "c"; r <- comparer(ref, o)
           !r$conforme && all(c("absente", "ajoutee") %in% r$ecarts$mesure) })

## --- Seuil d'affichage et bascule relatif / absolu (comparer_references.R) -
# --seuil 0 abaisse tol a 0 sans deplacer la bascule (TOLERANCE) : le bruit
# d'arrondi d'une grandeur nulle reste mesure en absolu, et l'ecart maximal
# est celui de la vraie derive relative.
verifier("tol = 0 : toute feuille non identique listee, bascule inchangee, ecart maximal = derive relative",
         { o <- ref; o$zero <- -2e-16; r0 <- ref; r0$zero <- 1e-16
           o$boot$draws[k] <- ref$boot$draws[k] * (1 + 5e-7)
           r <- comparer(r0, o, tol = 0)
           !r$conforme && r$n_ecarts == 2L && r$n_ecarts == r$n_differentes &&
             identical(r$ecarts$mesure[r$ecarts$chemin == "zero"], "absolu") &&
             identical(r$mesure_max, "relatif") && abs(r$ecart_max - 5e-7) < 1e-12 &&
             comparer(r0, o)$conforme })
verifier("ecart_feuille : tol et bascule separes (1e-16 -> -2e-16 en absolu meme avec tol = 0)",
         { j <- ecart_f(1e-16, -2e-16, tol = 0); !j$conforme && identical(j$mesure, "absolu") &&
             identical(ecart_f(1e-16, -2e-16, tol = 0, bascule = 0)$mesure, "relatif") })

## --- Reference reelle -------------------------------------------------------
verifier("Reference premium comparee a elle-meme : conforme, 0 feuille differente",
         { f <- outils_env$chemin_reference("premium")
           r <- comparer(readRDS(f), readRDS(f))
           r$conforme && r$n_differentes == 0L && r$n_feuilles > 10000L })

## --- Exclusion par conception (issue #22, decision du mainteneur) -----------
# ajustement$gradient et ajustement$gradient_projete : residus ~0 dependant du
# demarrage retenu, exclus de la comparaison ; hessien_gamma reste compare.
aj_ref <- list(ajustement = list(gradient = c(delta = -0.53, gamma = 1.0763e-05),
                                 gradient_projete = c(delta = 0, gamma = 1.0763e-05),
                                 hessien_gamma = 31.3464, pas_newton_gamma = -3.4e-07),
               tests = list(list(test = "t", p_mc = 0.5)))
neutr <- outils_env$neutraliser_instables
verifier("neutraliser_instables : une perturbation de gradient et gradient_projete n'est pas signalee",
         {
           b <- aj_ref
           b$ajustement$gradient[["gamma"]] <- -3.8e-07
           b$ajustement$gradient[["delta"]] <- -0.4
           b$ajustement$gradient_projete[["gamma"]] <- -3.8e-07
           brut <- comparer(aj_ref, b); r <- comparer(neutr(aj_ref), neutr(b))
           !brut$conforme && r$conforme && r$n_ecarts == 0L
         })
verifier("neutraliser_instables : une perturbation de hessien_gamma reste signalee",
         {
           b <- aj_ref; b$ajustement$hessien_gamma <- 31.3464 * (1 + 1e-4)
           r <- comparer(neutr(aj_ref), neutr(b))
           !r$conforme && r$n_ecarts == 1L
         })
# n_starts_optimum_code0 (ajout du 23/09/2026, decision du mainteneur) : depend
# du chemin d'optimisation (un demarrage bascule entre les codes 0 et 52 selon
# la machine), exclu ; n_starts_optimum reste compare.
aj_dem <- list(ajustement = list(n_starts_optimum = 54L, n_starts_optimum_code0 = 53L))
verifier("neutraliser_instables : n_starts_optimum_code0 54 contre 53 n'est pas signale",
         {
           b <- aj_dem; b$ajustement$n_starts_optimum_code0 <- 54L
           brut <- comparer(aj_dem, b); r <- comparer(neutr(aj_dem), neutr(b))
           !brut$conforme && r$conforme && r$n_ecarts == 0L
         })
verifier("neutraliser_instables : n_starts_optimum 54 contre 53 reste signale",
         {
           b <- aj_dem; b$ajustement$n_starts_optimum <- 53L
           r <- comparer(neutr(aj_dem), neutr(b))
           !r$conforme && r$n_ecarts == 1L
         })
# convergence (ajout du 24/09/2026, decision du mainteneur, option (a)) : code
# d'optim() du demarrage retenu (le premier a l'optimum, departage par l'ordre
# de la grille), qui depend du chemin d'optimisation, exclu de res$ajustement
# seulement ; un champ homonyme hors de res$ajustement reste compare.
aj_cv <- list(ajustement = list(convergence = 0L, n_starts_optimum = 54L),
              autre = list(convergence = 0L))
verifier("neutraliser_instables : ajustement$convergence 0 contre 52 n'est pas signale",
         {
           b <- aj_cv; b$ajustement$convergence <- 52L
           brut <- comparer(aj_cv, b); r <- comparer(neutr(aj_cv), neutr(b))
           !brut$conforme && r$conforme && r$n_ecarts == 0L
         })
verifier("neutraliser_instables : un champ convergence hors de res$ajustement reste signale",
         {
           b <- aj_cv; b$autre$convergence <- 52L
           r <- comparer(neutr(aj_cv), neutr(b))
           !r$conforme && r$n_ecarts == 1L
         })
verifier("neutraliser_instables : objet sans ajustement (Merz-Wuthrich) inchange",
         { o <- list(tests = list(list(test = "t", p_mc = 0.5))); identical(neutr(o), o) })

fin_fichier()
