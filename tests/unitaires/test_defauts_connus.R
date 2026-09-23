###############################################################################
#  tests/unitaires/test_defauts_connus.R  --  DEFAUTS OUVERTS (ISSUE #4)
#
#  Chaque defaut connu est documente par un test "echec attendu" : le test
#  decrit le comportement CORRECT et echoue tant que le defaut subsiste. Quand
#  une issue est resolue, le test passe, est signale "succes inattendu" et fait
#  echouer la batterie : il faut alors le transformer en test ordinaire.
#  Les tests ordinaires de ce fichier verifient la coherence actuelle des noms
#  Monte-Carlo, dont depend l'absence d'erreur silencieuse.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_defauts_connus.R")

x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
fit <- usp_ajuster(x, y)                       # delta = 1 (au bord)
s_obs <- .stats_bootstrapables(fit$x, fit$y, fit$z)
# Objet bootstrap fictif (aucune simulation) : toutes les p Monte-Carlo a 0,5.
boot_fictif <- function(sans = character(0)) {
  p <- stats::setNames(rep(0.5, length(s_obs)), names(s_obs))
  p <- p[setdiff(names(p), sans)]
  list(stats_obs = as.list(s_obs), p_mc = p, err_mc = p * 0 + 0.01)
}
mc_noms <- function(f) {
  txt <- paste(deparse(f), collapse = " ")
  unique(gsub("mc_nom = |\"", "", regmatches(txt, gregexpr("mc_nom = \"[^\"]+\"", txt))[[1]]))
}
noms_ln <- mc_noms(usp_tests); noms_mw <- mc_noms(mw_tests)
tri_mw <- local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
s_mw <- .mw_stats(mw_ajuster(tri_mw))

## --- Issue #4, piste 1 : noms Monte-Carlo -------------------------------------
verifier("Lognormal : chaque mc_nom de usp_tests() est une statistique simulee",
         if (all(noms_ln %in% names(s_obs))) TRUE
         else paste("inconnus :", paste(setdiff(noms_ln, names(s_obs)), collapse = ", ")))
verifier("Merz-Wuthrich : chaque mc_nom de mw_tests() est une statistique simulee",
         if (all(noms_mw %in% names(s_mw))) TRUE
         else paste("inconnus :", paste(setdiff(noms_mw, names(s_mw)), collapse = ", ")))
verifier("usp_tests() sur un bootstrap complet : hierarchie exacte > Monte-Carlo > asymptotique",
         {
           tt <- usp_tests(fit, boot_fictif())
           ok <- TRUE
           for (l in tt) {
             attendu <- if (is.finite(l$p_exacte)) l$p_exacte
                        else if (is.finite(l$p_mc)) l$p_mc else l$p_asymptotique
             ok <- ok && (identical(is.na(attendu), is.na(l$p_retenue)) &&
                          (is.na(attendu) || attendu == l$p_retenue)) &&
                   (is.na(l$p_retenue) || (l$p_retenue >= 0 && l$p_retenue <= 1))
           }
           ok
         })
echec_attendu("add() refuse un mc_nom absent du bootstrap (erreur explicite)",
              "issue #4 : gp() renvoie NA, repli silencieux sur la p asymptotique",
              leve_erreur(usp_tests(fit, boot_fictif(sans = "RESET"))))
verifier("Toute statistique simulee est exploitee par un test (pas d'orpheline)",
         {
           orph <- setdiff(names(s_obs), noms_ln)
           if (length(orph)) paste("orphelines :", paste(orph, collapse = ", ")) else TRUE
         })

## --- Issues #3 et #5 : centrage et variance unitaire restitues en diagnostics -
# La moyenne et la variance des z sont rivees par l'estimation, mais les
# egalites somme(z) = 0 et somme(z^2) = T ne valent que si pi_t est CONSTANT
# (delta = 1 ou volumes constants), non des que delta est au bord : le jeu
# tronque a T = 5 ci-dessous donne delta = 0 avec des pi_t variables.
# ADR 0001 : les deux verifications restent affichees, comme diagnostics.
# Issue #31 : les drapeaux delta_au_bord et pi_constant partagent la tolerance
# unique TOL_DELTA_BORD ; la constance de pi_t n'est plus exigee au bit pres
# (un arret de l'optimiseur a delta = 1 - 1e-7 la romprait d'environ 1e-8)
# mais bornee par tau * etendue(xbar / x_t).
tau <- TOL_DELTA_BORD
fit0 <- usp_ajuster(x[1:5], y[1:5])            # delta = 0, pi_t non constant
verifier("pi_t constant (delta = 1) : moyenne des z nulle et somme des z^2 egale a T",
         isTRUE(fit$delta_au_bord) && 1 - fit$delta <= tau &&
           isTRUE(usp_regime(fit$delta, fit$x)$pi_constant) &&
           diff(range(fit$pi)) / mean(fit$pi) <= tau * diff(range(fit$xbar / fit$x)) &&
           abs(mean(fit$z)) < 1e-12 &&
           isTRUE(proche(sum(fit$z^2), fit$T, rel = 1e-5)))
verifier("delta = 0 avec volumes variables : pi_t NON constant, aucune des deux egalites",
         isTRUE(fit0$delta_au_bord) && fit0$delta <= tau &&
           !isTRUE(usp_regime(fit0$delta, fit0$x)$pi_constant) &&
           diff(range(fit0$pi)) / mean(fit0$pi) > 0.01 &&
           abs(mean(fit0$z)) > 1e-3 && abs(sum(fit0$z^2) - fit0$T) > 1e-3 &&
           abs(sum(sqrt(fit0$pi) * fit0$z)) < 1e-8)
verifier("Centrage et variance unitaire : diagnostics INFO, sans p-value retenue",
         {
           ok <- TRUE
           for (f in list(fit, fit0)) {
             ll <- Filter(function(l) l$test %in% c("Centrage des residus standardises",
                                                    "Variance unitaire des residus standardises"),
                          usp_tests(f, boot_fictif()))
             ok <- ok && length(ll) == 2 &&
               all(vapply(ll, function(l)
                 identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
                   is.na(l$p_retenue) && is.na(l$nature_p) && is.na(l$p_mc) &&
                   is.na(l$p_exacte) && is.na(l$p_asymptotique) &&
                   is.finite(l$estim) && nzchar(l$detail), logical(1)))
           }
           ok
         })
verifier("Libelle du diagnostic : constance de pi_t, non position de delta au bord",
         {
           txt <- function(f) Filter(function(l) l$test == "Centrage des residus standardises",
                                     usp_tests(f, boot_fictif()))[[1]]$detail
           d1 <- txt(fit); d0 <- txt(fit0)
           if (!grepl("Ici pi_t est constant (delta = 1", d1, fixed = TRUE))
             "delta = 1 : le libelle ne dit pas que pi_t est constant"
           else if (!grepl("n'est PAS constant", d0, fixed = TRUE))
             paste("delta = 0 : libelle errone ->", d0)
           else TRUE
         })
# Issue #39 : libelles alignes sur CONTEXT.md ("Grandeur rivee par
# l'estimation", "Diagnostic"). Une assertion par point de l'issue.
ligne_test <- function(f, nom)
  Filter(function(l) l$test == nom, usp_tests(f, boot_fictif()))[[1]]
verifier("Issue #39 (1) : le detail de la variance nomme la condition en gamma, optimum interieur",
         {
           dd <- vapply(list(fit, fit0), function(f)
             ligne_test(f, "Variance unitaire des residus standardises")$detail, character(1))
           ok <- grepl("condition du premier ordre en gamma", dd, fixed = TRUE) &
                 grepl("optimum interieur en gamma", dd, fixed = TRUE) &
                 !grepl("les conditions du premier ordre donnent", dd, fixed = TRUE)
           if (all(ok)) TRUE else paste("libelle :", paste(dd[!ok], collapse = " | "))
         })
# Audit de #39, m3 : le preambule emploie le terme de CONTEXT.md.
verifier("Issue #39 (m3) : centrage et variance, preambule 'Grandeur rivee par l'estimation'",
         {
           dd <- unlist(lapply(list(fit, fit0), function(f)
             vapply(c("Centrage des residus standardises",
                      "Variance unitaire des residus standardises"),
                    function(n) ligne_test(f, n)$detail, character(1))))
           ok <- startsWith(dd, "Grandeur rivee par l'estimation :") &
                 !grepl("Grandeur contrainte", dd, fixed = TRUE)
           if (all(ok)) TRUE else paste("libelle :", paste(dd[!ok], collapse = " | "))
         })
verifier("Issue #39 (2) : pi_t non constant, la variance renvoie a la condition en gamma, non a la contrainte ponderee",
         {
           # fit0 : delta = 0 au bord ; fit_int : delta = 1 - 2 tau, interieur
           d_int <- 1 - 2 * tau
           fit_int <- c(usp_noyau(d_int, fit$gamma, x, y),
             list(delta = d_int, gamma = fit$gamma, T = length(x), x = x, y = y,
                  xbar = mean(x), foc = 0, convergence = 0L, part_starts_convergents = 1,
                  delta_au_bord = usp_regime(d_int, x)$delta_au_bord))
           ff <- list(fit0, fit_int)
           dv <- vapply(ff, function(f)
             ligne_test(f, "Variance unitaire des residus standardises")$detail, character(1))
           dc <- vapply(ff, function(f)
             ligne_test(f, "Centrage des residus standardises")$detail, character(1))
           if (any(grepl("seule la contrainte ponderee subsiste", dv, fixed = TRUE)))
             "variance : 'seule la contrainte ponderee subsiste' encore servi"
           else if (!all(grepl("la relation qui subsiste est la condition du premier ordre en gamma",
                               dv, fixed = TRUE)))
             paste("variance :", paste(dv, collapse = " | "))
           else if (!all(grepl("seule la contrainte ponderee subsiste", dc, fixed = TRUE)))
             "centrage : la contrainte ponderee n'est plus nommee"
           # Audit m5 : la condition en gamma rive var(z) sans determiner
           # somme(z_t^2) ; var(z) ne "mesure" donc aucun ecart de reference.
           else if (!all(grepl("var(z) reste rivee par cette condition mais n'est pas determinee par elle ; son ecart a T/(T-1) n'a pas de valeur de reference",
                               dv, fixed = TRUE)) ||
                    any(grepl("mesure l'ecart", dv, fixed = TRUE)))
             paste("variance (m5) :", paste(dv, collapse = " | "))
           # Audit m2 : T/(T-1) ne concerne que la variance.
           else if (any(grepl("T/(T-1)", dc, fixed = TRUE)) ||
                    !grepl("n'est donc pas nulle", dc[1], fixed = TRUE))
             paste("centrage (m2) :", paste(dc, collapse = " | "))
           else TRUE
         })
# Propriete invoquee par le commentaire de contrainte() (issue #39) : la
# condition du premier ordre en gamma s'ecrit
# somme(k_t (z_t^2 - z_t / sqrt(pi_t) - 1)) = 0, k_t = pi_t (1 - exp(-1/pi_t)),
# et ne fixe pas somme(z_t^2) quand pi_t varie. Tolerance 1e-4 : l'ecart
# mesure a l'arret de usp_ajuster() est -3,3e-06 sur fit0.
verifier("Issue #39 : condition en gamma verifiee a delta = 0 (pi_t variable), somme(z_t^2) != T",
         {
           k <- fit0$pi * (1 - exp(-1 / fit0$pi))
           cg <- sum(k * (fit0$z^2 - fit0$z / sqrt(fit0$pi) - 1))
           abs(cg) < 1e-4 && abs(sum(fit0$z^2) - fit0$T) > 1e-3
         })
verifier("Issue #39 (3) : H0 de Breusch-Pagan (Koenker) et de normalite en residus standardises",
         {
           tt <- usp_tests(fit, boot_fictif())
           h0 <- vapply(tt, function(l) if (is.na(l$H0)) "" else l$H0, character(1))
           nm <- vapply(tt, function(l) l$test, character(1))
           bp <- h0[nm == "Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)"]
           sw <- h0[nm == "Shapiro-Wilk sur residus standardises"]
           if (any(grepl("normalises", h0, fixed = TRUE)))
             paste("H0 en 'normalises' :", paste(nm[grepl("normalises", h0, fixed = TRUE)], collapse = ", "))
           else identical(bp, "c1 = 0 : la variance des residus standardises ne depend pas du volume") &&
             identical(sw, "les residus standardises suivent une loi normale")
         })
verifier("Issue #39 (4) : R2 de type diagnostic (type et detail), verdict force inchange (ALERTE a R2 < 0,5 ; #24)",
         {
           l1 <- ligne_test(fit, "Coefficient de determination R2")
           l0 <- ligne_test(fit0, "Coefficient de determination R2")
           types <- vapply(usp_tests(fit, boot_fictif()), function(l) l$type, character(1))
           identical(l1$type, "diagnostic") && identical(l0$type, "diagnostic") &&
             !"indicateur" %in% types &&
             grepl("Diagnostic, pas un test", l1$detail, fixed = TRUE) &&
             grepl("Diagnostic, pas un test", l0$detail, fixed = TRUE) &&
             !grepl("Indicateur", l1$detail, fixed = TRUE) &&
             identical(l1$verdict, if (l1$estim < 0.5) "ALERTE" else "OK") &&
             identical(l0$verdict, if (l0$estim < 0.5) "ALERTE" else "OK")
         })
# Issue #31, cas de l'issue : delta a 1 - tau/2 avec des volumes variables.
# L'ancien drapeau (etendue des pi_t <= 1e-9 en relatif) classait ce cas
# "au bord mais pi_t n'est PAS constant" et affirmait une valeur "ni nulle ni
# egale a T/(T-1)" ; a delta = 1 - 2 tau, delta n'est plus au bord.
fit_regime <- function(d) {
  c(usp_noyau(d, fit$gamma, x, y),
    list(delta = d, gamma = fit$gamma, T = length(x), x = x, y = y, xbar = mean(x),
         foc = 0, convergence = 0L, part_starts_convergents = 1,
         delta_au_bord = usp_regime(d, x)$delta_au_bord))
}
details_regime <- function(f) {
  tt <- usp_tests(f, boot_fictif())
  stats::setNames(vapply(tt, function(l) l$detail, character(1)),
                  vapply(tt, function(l) l$test, character(1)))
}
verifier("Libelles a delta = 1 - tau/2 (issue #31) : pi_t constant, controle sur ratios sans objet",
         {
           f <- fit_regime(1 - tau / 2)
           dd <- details_regime(f)
           diag <- dd[c("Centrage des residus standardises",
                        "Variance unitaire des residus standardises")]
           if (!isTRUE(f$delta_au_bord)) "delta_au_bord FALSE a 1 - tau/2"
           else if (!all(grepl("Ici pi_t n'est constant qu'a", diag, fixed = TRUE)))
             paste("libelle diagnostic :", paste(diag, collapse = " | "))
           else if (any(grepl("ni nulle ni egale a T/(T-1)", dd, fixed = TRUE)))
             "libelle 'ni nulle ni egale a T/(T-1)' encore servi"
           else if (!any(grepl("CONTROLE SANS OBJET", dd, fixed = TRUE)))
             "note_r absente"
           else TRUE
         })
verifier("Libelles a delta = 1 - 2 tau (issue #31) : delta interieur, pi_t non constant",
         {
           f <- fit_regime(1 - 2 * tau)
           dd <- details_regime(f)
           diag <- dd[c("Centrage des residus standardises",
                        "Variance unitaire des residus standardises")]
           if (isTRUE(f$delta_au_bord)) "delta_au_bord TRUE a 1 - 2 tau"
           else if (!all(grepl("interieur", diag, fixed = TRUE)))
             paste("libelle diagnostic :", paste(diag, collapse = " | "))
           else if (any(grepl("CONTROLE SANS OBJET", dd, fixed = TRUE)))
             "note_r servie alors que pi_t varie"
           else TRUE
         })
# Revue de la PR #57 (issue #31) : dans la bande de tolerance de
# usp_regime() (pi_t constant a TOL_DELTA_BORD pres mais non exactement),
# moyenne(z) = 0 n'est plus une identite a la precision machine (mesure :
# 1,8e-9 a delta = 1 - 5e-7 contre -2,0e-16 a delta = 1), ni somme(z^2) = T
# un effet de la seule tolerance d'arret. Le libelle ne doit plus affirmer
# l'IDENTITE ni le "bruit d'arrondi" ; a delta = 1 exactement, il reste
# celui des references de non-regression, au caractere pres.
verifier("Revue PR #57 (issue #31) : delta = 1 - tau/2, centrage et variance nomment la tolerance, plus d'IDENTITE",
         {
           f <- fit_regime(1 - tau / 2)
           dd <- details_regime(f)
           dc <- dd[["Centrage des residus standardises"]]
           dv <- dd[["Variance unitaire des residus standardises"]]
           if (!(abs(mean(f$z)) > 1e-12)) paste("moyenne(z) =", mean(f$z), ": cas non discriminant")
           else if (isTRUE(usp_regime(f$delta, f$x)$pi_constant_exact))
             "pi_constant_exact TRUE a 1 - tau/2"
           else if (grepl("IDENTITE", dc, fixed = TRUE) || grepl("bruit d'arrondi", dc, fixed = TRUE))
             paste("centrage :", dc)
           else if (!grepl("n'est constant qu'a la tolerance TOL_DELTA_BORD = 1e-06 pres (1 - delta = 5e-07)",
                           dc, fixed = TRUE) ||
                    !grepl("ne renseigne PAS sur la convergence en gamma", dc, fixed = TRUE) ||
                    grepl("qualite de l'arret", dc, fixed = TRUE))
             paste("centrage, tolerance non nommee :", dc)
           else if (!grepl("n'est constant qu'a la tolerance TOL_DELTA_BORD", dv, fixed = TRUE) ||
                    !grepl("ne tient qu'a deux ecarts pres", dv, fixed = TRUE))
             paste("variance :", dv)
           else TRUE
         })
verifier("Revue PR #57 (issue #31) : volumes d'etendue relative tau/2 (delta = 0,37), tolerance nommee",
         {
           alt <- c(0.3, -1, 0.8, -0.2, 1, -0.6, 0.1, -0.4)
           xv <- 100 * (1 + alt * tau / 4)
           rg <- usp_regime(0.37, xv)
           f <- c(usp_noyau(0.37, fit$gamma, xv, y),
                  list(delta = 0.37, gamma = fit$gamma, T = length(xv), x = xv, y = y,
                       xbar = mean(xv), foc = 0, convergence = 0L,
                       part_starts_convergents = 1, delta_au_bord = rg$delta_au_bord))
           dc <- details_regime(f)[["Centrage des residus standardises"]]
           if (!isTRUE(rg$pi_constant) || isTRUE(rg$pi_constant_exact))
             "regime : pi_constant TRUE et pi_constant_exact FALSE attendus"
           else !grepl("IDENTITE", dc, fixed = TRUE) &&
             grepl("etendue relative des volumes = 5e-07", dc, fixed = TRUE)
         })
verifier("Revue PR #57 (issue #31) : delta = 1 exactement, centrage et variance identiques aux references",
         {
           ref <- readRDS(file.path(RACINE, "tests", "reference", "premium.rds"))
           rt <- stats::setNames(vapply(ref$tests, function(l) l$detail, character(1)),
                                 vapply(ref$tests, function(l) l$test, character(1)))
           nn <- c("Centrage des residus standardises", "Variance unitaire des residus standardises")
           dd <- details_regime(fit)
           isTRUE(usp_regime(fit$delta, fit$x)$pi_constant_exact) && fit$delta == 1 &&
             identical(unname(dd[nn]), unname(rt[nn])) &&
             grepl("IDENTITE algebrique", dd[[nn[1]]], fixed = TRUE)
         })
verifier("MeanZ, VarZ, LB2r et BP2r ne sont plus simulees",
         {
           restantes <- intersect(c("MeanZ", "VarZ", "LB2r", "BP2r"), names(s_obs))
           if (length(restantes))
             paste("encore simulees :", paste(restantes, collapse = ", ")) else TRUE
         })

## --- Issue #4, piste 2 : etat du generateur aleatoire -------------------------
echec_attendu("sw_loi_nulle() ne cree pas de .Random.seed s'il n'en existait pas",
              "issue #4 : l'etat n'est restaure que s'il existait",
              {
                if (exists(".Random.seed", envir = globalenv()))
                  rm(".Random.seed", envir = globalenv())
                sw_loi_nulle(10, B_null = 200, seed = 11)
                r <- !exists(".Random.seed", envir = globalenv())
                set.seed(401)
                r
              })
echec_attendu("usp_bootstrap() restaure l'etat du generateur de l'appelant",
              "issue #4 : set.seed(seed) sans restauration",
              {
                set.seed(402); avant <- .Random.seed
                usp_bootstrap(fit, B = 3, seed = 1)
                identical(avant, .Random.seed)
              })

fin_fichier()
