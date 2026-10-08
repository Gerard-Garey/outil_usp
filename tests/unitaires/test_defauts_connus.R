###############################################################################
#  tests/unitaires/test_defauts_connus.R  --  DEFAUTS OUVERTS (ISSUE #4)
#
#  Chaque defaut connu est documente par un test "echec attendu" : le test
#  decrit le comportement CORRECT et echoue tant que le defaut subsiste. Quand
#  une issue est resolue, le test passe, est signale "succes inattendu" et fait
#  echouer la batterie : il faut alors le transformer en test ordinaire.
#  Les tests ordinaires de ce fichier verifient la coherence actuelle des noms
#  Monte-Carlo, dont depend l'absence d'erreur silencieuse, et la gestion de
#  l'etat du generateur aleatoire (issue #42, ADR 0004).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_defauts_connus.R")

x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
fit <- usp_ajuster(x, y)                       # delta = 1 (au bord)
s_obs <- .stats_bootstrapables(fit$x, fit$y, fit$z, fit$pi)
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
           tt <- usp_tests(fit, boot_fictif(), methode = "premium")
           ok <- TRUE
           # Lignes de type "test" seulement : toute autre ligne n'a aucune p
           # retenue (ADR 0001, M7), y compris un test inoperant (p_min >=
           # alpha) ou une pente non identifiable restitues en diagnostic (#44).
           for (l in Filter(function(l) l$type == "test", tt)) {
             attendu <- if (is.finite(l$p_exacte)) l$p_exacte
                        else if (is.finite(l$p_mc)) l$p_mc else l$p_asymptotique
             ok <- ok && (identical(is.na(attendu), is.na(l$p_retenue)) &&
                          (is.na(attendu) || attendu == l$p_retenue)) &&
                   (is.na(l$p_retenue) || (l$p_retenue >= 0 && l$p_retenue <= 1))
           }
           # Toute ligne non-test : ni p retenue ni nature (M7, constat 5
           # d'audit de #44).
           for (l in Filter(function(l) l$type != "test", tt))
             ok <- ok && is.na(l$p_retenue) && is.na(l$nature_p)
           ok
         })
# Issue #41 (ADR 0003, point 3) : ancien echec attendu de l'issue #4, devenu
# test ordinaire. add() de engine_registre_tests() refuse une statistique
# Monte-Carlo absente du bootstrap ou inconnue du catalogue, au lieu du repli
# silencieux sur la p-value asymptotique.
verifier("add() refuse un mc_nom absent du bootstrap (erreur explicite)",
         leve_erreur(usp_tests(fit, boot_fictif(sans = "RESET"), methode = "premium")))
verifier("add() refuse un mc_nom inconnu du catalogue (erreur explicite)",
         {
           reg <- engine_registre_tests(boot_fictif(), USP_CATALOGUE_MC, 0.10, "Monte-Carlo")
           leve_erreur(reg$add("F", "t", "r", fonction = "usp_tests", mc_nom = "Inconnue"))
         })
verifier("mw_tests() refuse un mc_nom absent du bootstrap (erreur explicite)",
         {
           p <- stats::setNames(rep(0.5, length(s_mw)), names(s_mw))
           p <- p[setdiff(names(p), "Calendrier")]
           leve_erreur(mw_tests(mw_ajuster(tri_mw),
                                list(stats_obs = as.list(s_mw), p_mc = p, err_mc = p * 0 + 0.01)))
         })
verifier("Catalogues Monte-Carlo : les statistiques simulees sont exactement celles du catalogue, dans son ordre",
         identical(names(s_obs), names(USP_CATALOGUE_MC)) &&
           identical(names(s_mw), names(MW_CATALOGUE_MC)))
verifier(".mc_evaluer : une entree de longueur 0 (NULL) ou 2 leve une erreur qui nomme la statistique",
         {
           msg <- function(val) {
             cat_f <- list(A = .mc_entree(function(e) 1, "haut"),
                           Fautive = .mc_entree(function(e) val, "haut"))
             tryCatch({ .mc_evaluer(cat_f, list()); "" }, error = function(err) conditionMessage(err))
           }
           m0 <- msg(NULL); m2 <- msg(c(1, 2))
           grepl("Fautive", m0, fixed = TRUE) && grepl("Fautive", m2, fixed = TRUE) &&
             identical(.mc_evaluer(list(A = .mc_entree(function(e) NA_real_, "bas")), list()),
                       c(A = NA_real_))
         })
verifier("Catalogues Monte-Carlo : sens de rejet dans {haut, bas, deux} pour chaque entree",
         all(vapply(c(USP_CATALOGUE_MC, MW_CATALOGUE_MC),
                    function(e) e$queue %in% c("haut", "bas", "deux"), logical(1))))
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
                          usp_tests(f, boot_fictif(), methode = "premium"))
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
                                     usp_tests(f, boot_fictif(), methode = "premium"))[[1]]$detail
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
  Filter(function(l) l$test == nom, usp_tests(f, boot_fictif(), methode = "premium"))[[1]]
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
                  xbar = mean(x), convergence = 0L, part_starts_convergents = 1,
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
           tt <- usp_tests(fit, boot_fictif(), methode = "premium")
           h0 <- vapply(tt, function(l) if (is.na(l$H0)) "" else l$H0, character(1))
           nm <- vapply(tt, function(l) l$test, character(1))
           bp <- h0[nm == "Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)"]
           sw <- h0[nm == "Shapiro-Wilk sur residus standardises"]
           if (any(grepl("normalises", h0, fixed = TRUE)))
             paste("H0 en 'normalises' :", paste(nm[grepl("normalises", h0, fixed = TRUE)], collapse = ", "))
           else identical(bp, "c1 = 0 : la variance des residus standardises ne depend pas du volume") &&
             identical(sw, "les residus standardises suivent une loi normale")
         })
# Le verdict force (ALERTE a R2 < 0,5) a ete retire par #24 (ADR 0001,
# amendement du 23/09/2026) : un diagnostic sort INFO, sens NA.
verifier("Issue #39 (4) : R2 de type diagnostic (type et detail), INFO et sens NA (#24)",
         {
           l1 <- ligne_test(fit, "Coefficient de determination R2")
           l0 <- ligne_test(fit0, "Coefficient de determination R2")
           types <- vapply(usp_tests(fit, boot_fictif(), methode = "premium"), function(l) l$type, character(1))
           identical(l1$type, "diagnostic") && identical(l0$type, "diagnostic") &&
             !"indicateur" %in% types &&
             grepl("Diagnostic, pas un test", l1$detail, fixed = TRUE) &&
             grepl("Diagnostic, pas un test", l0$detail, fixed = TRUE) &&
             !grepl("Indicateur", l1$detail, fixed = TRUE) &&
             identical(l1$verdict, "INFO") && is.na(l1$sens) &&
             identical(l0$verdict, "INFO") && is.na(l0$sens)
         })
# Issue #31, cas de l'issue : delta a 1 - tau/2 avec des volumes variables.
# L'ancien drapeau (etendue des pi_t <= 1e-9 en relatif) classait ce cas
# "au bord mais pi_t n'est PAS constant" et affirmait une valeur "ni nulle ni
# egale a T/(T-1)" ; a delta = 1 - 2 tau, delta n'est plus au bord.
fit_regime <- function(d) {
  c(usp_noyau(d, fit$gamma, x, y),
    list(delta = d, gamma = fit$gamma, T = length(x), x = x, y = y, xbar = mean(x),
         convergence = 0L, part_starts_convergents = 1,
         delta_au_bord = usp_regime(d, x)$delta_au_bord))
}
details_regime <- function(f) {
  tt <- usp_tests(f, boot_fictif(), methode = "premium")
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
                       xbar = mean(xv), convergence = 0L,
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

## --- Issue #24 : toute ligne non-test sort INFO, sens NA (ADR 0001, M7) ------
# Amendement du 23/09/2026 de l'ADR 0001 : seule une ligne de type "test" ou
# "procedure de decision" (ESD) porte un verdict ; toute autre ligne sort
# INFO, sens NA, et son seuil conventionnel n'est plus qu'un repere nomme
# dans le detail. Invariant symetrique de celui de test_merz_wuthrich.R,
# verifie sur une batterie sans jackknife ni IC (usp_tests + bootstrap
# fictif) et sur un run_engine() complet (B = 99), qui les contient.
res_ln_ii1 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1,
                         annexe = "II", B = 99, nature_donnees = "brutes")
res_ln_ii6 <- run_engine(xt = x, yt = y, methode = "premium", segment = 6,
                         annexe = "II", B = 99, nature_donnees = "brutes")
tab_ln <- engine_table_tests(res_ln_ii1)
lignes_df <- function(L) data.frame(
  test = vapply(L, function(l) l$test, character(1)),
  type = vapply(L, function(l) l$type, character(1)),
  verdict = vapply(L, function(l) l$verdict, character(1)),
  sens_du_test = vapply(L, function(l) l$sens, character(1)),
  p_retenue = vapply(L, function(l) l$p_retenue, numeric(1)),
  nature_p = vapply(L, function(l) l$nature_p, character(1)),
  commentaire = vapply(L, function(l) l$detail, character(1)),
  stringsAsFactors = FALSE)
tab_fictif <- lignes_df(usp_tests(fit, boot_fictif(), methode = "premium"))
invariant_non_test <- function(tb) {
  k <- !tb$type %in% c("test", "procedure de decision")
  faux <- k & !(tb$verdict == "INFO" & is.na(tb$sens_du_test) &
                  is.na(tb$p_retenue) & is.na(tb$nature_p))
  if (!any(k)) "aucune ligne non-test : invariant non exerce"
  else if (!any(faux)) TRUE
  else paste("ligne non-test hors INFO / sens NA / p_retenue NA / nature_p NA :",
             paste(sprintf("%s -> %s / %s / %s / %s", tb$test[faux], tb$verdict[faux],
                           tb$sens_du_test[faux], tb$p_retenue[faux], tb$nature_p[faux]),
                   collapse = " ; "))
}
verifier("usp_tests : toute ligne type != 'test' hors 'procedure de decision' sort INFO, sens, p_retenue et nature_p NA (bootstrap fictif)",
         invariant_non_test(tab_fictif))
verifier("usp_tests : toute ligne type != 'test' hors 'procedure de decision' sort INFO, sens, p_retenue et nature_p NA (run_engine, B = 99)",
         {
           r <- invariant_non_test(tab_ln)
           if (!isTRUE(r)) r
           else all(c("Sensibilite au retrait d'une annee (jackknife)",
                      "Largeur relative de l'IC bootstrap 90%") %in% tab_ln$test)
         })
verifier("ESD lognormal (procedure de decision) : verdict OK / ALERTE / ECHEC, sens 'ne pas rejeter'",
         {
           ok <- TRUE
           for (tb in list(tab_fictif, tab_ln)) {
             e <- tb[tb$type == "procedure de decision", ]
             ok <- ok && nrow(e) == 1L &&
               identical(e$test, "Valeurs aberrantes multiples (ESD generalise)") &&
               e$verdict %in% c("OK", "ALERTE", "ECHEC") &&
               identical(e$sens_du_test, "ne pas rejeter")
           }
           ok
         })
verifier("usp_tests : types en usage dans {test, diagnostic, non applicable, procedure de decision}",
         {
           ty <- unique(c(tab_fictif$type, tab_ln$type))
           hors <- setdiff(ty, c("test", "diagnostic", "non applicable", "procedure de decision"))
           if (length(hors)) paste("type hors vocabulaire :", paste(hors, collapse = ", ")) else TRUE
         })
verifier("Diagnostics lognormaux : repere nomme dans le detail, jamais 'seuil' (#24)",
         {
           reperes <- c("Coefficient de determination R2" = "R2 < 0.5",
                        "Points influents (distance de Cook)" = "4/T",
                        "Leviers (hat values)" = "2k/T",
                        # Condition du premier ordre et multi-demarrages : sortis
                        # de la table vers res$controles (#22, M11). Jackknife
                        # et IC : libelles concis (#76), reperes 10 % / 20 % et
                        # 50 % / 80 % dans les fiches du .tex seulement ; ils
                        # restent soumis a l'interdiction de 'seuil' ci-dessous.
                        NULL)
           dd <- stats::setNames(tab_ln$commentaire, tab_ln$test)
           pb <- character(0)
           for (nm in names(reperes)) {
             d <- dd[nm]
             if (is.na(d)) { pb <- c(pb, paste(nm, ": ligne absente")); next }
             if (!grepl("repere", d, fixed = TRUE)) pb <- c(pb, paste(nm, ": pas de 'repere'"))
             if (!grepl(reperes[[nm]], d, fixed = TRUE))
               pb <- c(pb, sprintf("%s : '%s' absent", nm, reperes[[nm]]))
           }
           d_delta <- dd["Position de delta dans [0,1]"]
           for (nm in c(names(reperes), "Position de delta dans [0,1]",
                        "Sensibilite au retrait d'une annee (jackknife)",
                        "Largeur relative de l'IC bootstrap 90%"))
             if (grepl("seuil", dd[nm], fixed = TRUE)) pb <- c(pb, paste(nm, ": contient 'seuil'"))
           if (!any(vapply(c("AU BORD", "interieur", "VOLUMES CONSTANTS"), grepl, logical(1),
                           x = d_delta, fixed = TRUE)))
             pb <- c(pb, "Position de delta : ni 'AU BORD' ni 'interieur' ni 'VOLUMES CONSTANTS'")
           if (length(pb)) paste(pb, collapse = " ; ") else TRUE
         })
# Invariance a la table de l'annexe : entre les segments 1 et 6 de l'annexe II
# (meme bareme long, sigma_std differents), les ecarts rapportes a la part
# estimee sigma(delta, gamma) ne dependent pas de la table ; ceux rapportes a
# sigma_USP (estim) en dependent par (1-c) sigma_std. Relation exacte,
# recalculee ici depuis res$jackknife, res$bootstrap$sigma_boot et
# res$parametre_final :
#   |d sigma_hat| / sigma_hat = ecart_jackknife * sigma_USP / (c sqrt((T+1)/(T-1)) sigma_hat)
# (et de meme pour la largeur de l'IC, le quantile commutant avec
# l'application affine croissante sigma -> c corr sigma + (1-c) sigma_std).
# Issue #76 : les ecarts sur la part estimee ne sont plus imprimes dans le
# detail (libelles concis) ; la relation est verifiee sur estim seul, et le
# detail ne porte plus aucun pourcentage.
NOM_JK <- "Sensibilite au retrait d'une annee (jackknife)"
NOM_IC <- "Largeur relative de l'IC bootstrap 90%"
DETAIL_IC <- "Intervalle bootstrap du parametre retenu : res$ic_bootstrap."
estim_ligne <- function(tb, nom) tb$estimation[tb$test == nom]
verifier("Jackknife et IC : ecart sur sigma_USP (estim) different entre II-1 et II-6, detail sans pourcentage ni part estimee (#76)",
         {
           t1 <- tab_ln; t6 <- engine_table_tests(res_ln_ii6)
           d <- c(t1$commentaire[t1$test %in% c(NOM_JK, NOM_IC)], t6$commentaire[t6$test %in% c(NOM_JK, NOM_IC)])
           length(d) == 4L && estim_ligne(t1, NOM_JK) != estim_ligne(t6, NOM_JK) &&
             estim_ligne(t1, NOM_IC) != estim_ligne(t6, NOM_IC) &&
             !any(grepl("%|part estimee", d)) &&
             identical(t1$commentaire[t1$test == NOM_IC], DETAIL_IC) &&
             identical(t6$commentaire[t6$test == NOM_IC], DETAIL_IC)
         })
verifier("Jackknife et IC : part estimee = ecart sur sigma_USP (estim) * sigma_USP / (c corr sigma_hat), a 1e-10 (II-1, II-6)",
         {
           ok <- TRUE
           for (r in list(res_ln_ii1, res_ln_ii6)) {
             tb <- engine_table_tests(r); pf <- r$parametre_final
             T <- length(r$donnees$xt); corr <- sqrt((T + 1) / (T - 1))
             sh <- pf$sigma_estime_brut; cr <- pf$credibilite
             J <- r$jackknife; i <- which.max(abs(J$sigma_usp - pf$sigma_usp))
             jk_est <- (J$sigma[i] - sh) / sh
             e_jk <- tb$estimation[tb$test == NOM_JK]
             ic_est <- unname(diff(stats::quantile(r$bootstrap$sigma_boot, c(.05, .95)))) / sh
             e_ic <- tb$estimation[tb$test == NOM_IC]
             ok <- ok && T == 8L &&
               isTRUE(proche(abs(jk_est), e_jk * pf$sigma_usp / (cr * corr * sh), rel = 1e-10)) &&
               isTRUE(proche(ic_est, e_ic * pf$sigma_usp / (cr * corr * sh), rel = 1e-10))
           }
           ok
         })

# Gardes de add() (revue d'audit du commit #24) : un verdict force sur un
# diagnostic, ou une procedure de decision sans verdict, sont des erreurs de
# programmation. Le corps de usp_tests() est modifie ici par texte (deparse)
# pour reinjecter un tel appel, puis reevalue dans l'environnement du moteur.
usp_tests_modifie <- function(avant, apres) {
  txt <- paste(deparse(usp_tests), collapse = "\n")
  if (!grepl(avant, txt, fixed = TRUE)) stop("motif absent du corps de usp_tests : ", avant)
  f <- eval(parse(text = sub(avant, apres, txt, fixed = TRUE)))
  environment(f) <- environment(usp_tests)
  f
}
message_erreur <- function(expr) tryCatch({ expr; "" }, error = function(e) conditionMessage(e))
verifier("add() (usp_tests) refuse un verdict force sur un diagnostic (Leviers, verdict = 'OK')",
         {
           f <- usp_tests_modifie('type = "diagnostic", estim_nom = "max h_t"',
                                  'type = "diagnostic", verdict = "OK", estim_nom = "max h_t"')
           m <- message_erreur(f(fit, boot_fictif(), methode = "premium"))
           grepl("un verdict n'est admis que pour type = 'test' ou 'procedure de decision'", m, fixed = TRUE) &&
             grepl("Leviers (hat values)", m, fixed = TRUE)
         })
verifier("add() (usp_tests) refuse une procedure de decision sans verdict (ESD)",
         {
           f <- usp_tests_modifie("verdict = if (ro$nb_outliers >= 2)",
                                  "verdict = if (TRUE) NULL else if (ro$nb_outliers >= 2)")
           m <- message_erreur(f(fit, boot_fictif(), methode = "premium"))
           grepl("une ligne de type 'procedure de decision' doit fournir son verdict", m, fixed = TRUE) &&
             grepl("Valeurs aberrantes multiples (ESD generalise)", m, fixed = TRUE)
         })

# Provenance des lignes (#111, regles A1, A2, A4) : add() exige fonction,
# chaine non vide nommant une fonction de l'environnement du moteur
# (exists(mode = "function", inherits = FALSE) : "cor.test", fonction de
# stats, et "ANNEXE_II", constante du moteur, sont refusees ; ".shapiro_sur",
# fonction interne du moteur, est admise).
verifier("add() (#111) refuse fonction absente, non chaine, vide ou inconnue du moteur ; admet .shapiro_sur",
         {
           reg <- engine_registre_tests(boot_fictif(), USP_CATALOGUE_MC, 0.10, "Monte-Carlo")
           m_abs <- message_erreur(reg$add("F", "t", "r", type = "diagnostic"))
           m_num <- message_erreur(reg$add("F", "t", "r", type = "diagnostic", fonction = 1))
           m_vide <- message_erreur(reg$add("F", "t", "r", type = "diagnostic", fonction = ""))
           m_na <- message_erreur(reg$add("F", "t", "r", type = "diagnostic", fonction = NA_character_))
           m_cor <- message_erreur(reg$add("F", "t", "r", type = "diagnostic", fonction = "cor.test"))
           m_cst <- message_erreur(reg$add("F", "t", "r", type = "diagnostic", fonction = "ANNEXE_II"))
           m_ok <- message_erreur(reg$add("F", "t", "r", type = "diagnostic", fonction = ".shapiro_sur"))
           l <- reg$lignes()
           grepl("argument fonction absent", m_abs, fixed = TRUE) &&
             grepl("chaine non vide", m_num, fixed = TRUE) &&
             grepl("chaine non vide", m_vide, fixed = TRUE) &&
             grepl("chaine non vide", m_na, fixed = TRUE) &&
             grepl("fonction inconnue du moteur : cor.test", m_cor, fixed = TRUE) &&
             grepl("fonction inconnue du moteur : ANNEXE_II", m_cst, fixed = TRUE) &&
             identical(m_ok, "") && length(l) == 1L &&
             identical(utils::tail(names(l[[1]]), 3), c("p_min", "fonction", "inoperant")) &&
             identical(l[[1]]$fonction, ".shapiro_sur")
         })
# Les cinq cas de tests/outils_tests.R (CAS), a B = 99 pour la duree : la
# liste des lignes et leur fonction ne dependent pas de B (chaine litterale a
# chaque appel d'add()). Chaque ligne porte une fonction non vide, definie
# dans l'environnement du moteur, suivie du seul champ inoperant (#129,
# point 3) ; engine_table_tests() l'expose en avant-derniere colonne.
verifier("Cinq cas (#111) : chaque ligne porte une fonction du moteur, avant-dernier champ (puis inoperant) ; colonne fonction de engine_table_tests()",
         {
           ln <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
           env_moteur <- environment(engine_registre_tests)
           cas <- list(
             premium = run_engine(xt = ln$xt, yt = ln$yt, methode = "premium", segment = 1, annexe = "II",
                                  nature_donnees = "brutes", B = 99),
             reserve1 = run_engine(xt = ln$xt, yt = ln$yt, methode = "reserve1", segment = 1, annexe = "II",
                                   B = 99),
             reserve2 = run_engine(methode = "reserve2", triangle = tri_mw, segment = 1, annexe = "II", B = 99),
             premium_ii6 = run_engine(xt = ln$xt, yt = ln$yt, methode = "premium", segment = 6, annexe = "II",
                                      nature_donnees = "brutes", B = 99),
             premium_net = run_engine(xt = ln$xt, yt = ln$yt, methode = "premium", segment = 1, annexe = "II",
                                      nature_donnees = "nettes", B = 99))
           all(vapply(cas, function(r) {
             f <- vapply(r$tests, function(t) if (is.character(t$fonction)) t$fonction else NA_character_, "")
             tb <- engine_table_tests(r)
             isTRUE(r$ok) && length(f) > 0L && !anyNA(f) && all(nzchar(f)) &&
               all(vapply(f, exists, NA, envir = env_moteur, inherits = FALSE)) &&
               all(vapply(r$tests, function(t) identical(utils::tail(names(t), 2), c("fonction", "inoperant")),
                          NA)) &&
               identical(utils::tail(names(tb), 2), c("fonction", "inoperant")) &&
               identical(tb$fonction, unname(f))
           }, NA))
         })
# Branche robustesse = NULL : usp_tests() appele directement avec un fit
# portant ecart_jackknife et largeur_ic, sans les elements du detail.
verifier("Jackknife et IC sans robustesse : 'Annee la plus influente non determinee.' et renvoi a res$ic_bootstrap (#76)",
         {
           f <- fit; f$ecart_jackknife <- 0.123; f$largeur_ic <- 0.456
           tb <- lignes_df(usp_tests(f, boot_fictif(), methode = "premium"))
           dj <- tb$commentaire[tb$test == NOM_JK]; di <- tb$commentaire[tb$test == NOM_IC]
           length(dj) == 1L && length(di) == 1L &&
             identical(dj, "Annee la plus influente non determinee.") &&
             identical(di, DETAIL_IC) &&
             all(tb$estimation[match(c(NOM_JK, NOM_IC), tb$test)] == c(0.123, 0.456)) &&
             all(tb$verdict[tb$test %in% c(NOM_JK, NOM_IC)] == "INFO")
         })
verifier("Jackknife : annee et sens du detail = argmax |d| et signe de d[i], estim = |d[i]| / sigma_USP, depuis res$jackknife",
         {
           ok <- TRUE
           for (r in list(res_ln_ii1, res_ln_ii6)) {
             tb <- engine_table_tests(r); pf <- r$parametre_final
             d <- r$jackknife$sigma_usp - pf$sigma_usp; i <- which.max(abs(d))
             dj <- tb$commentaire[tb$test == NOM_JK]
             sens_jk <- if (d[i] < 0) "en baisse" else "en hausse"
             ok <- ok && identical(dj, sprintf("Annee la plus influente : %d (sigma_USP %s).", i, sens_jk)) &&
               isTRUE(proche(estim_ligne(tb, NOM_JK), abs(d[i]) / pf$sigma_usp, rel = 1e-12))
           }
           ok
         })
# Libelle concis du jackknife (#76), trois sens : robustesse fournie
# directement a usp_tests() (annee 3, ecart signe negatif, positif, nul).
verifier("Jackknife : 'Annee la plus influente : 3 (sigma_USP en baisse / en hausse / inchange).' selon le signe (#76)",
         {
           f <- fit; f$ecart_jackknife <- 0.1; f$largeur_ic <- 0.4
           dj <- vapply(c(-0.1, 0.1, 0), function(s) {
             tb <- lignes_df(usp_tests(f, boot_fictif(), methode = "premium", robustesse = list(jack_annee = 3L, jack_usp = s)))
             tb$commentaire[tb$test == NOM_JK]
           }, character(1))
           identical(dj, sprintf("Annee la plus influente : 3 (sigma_USP %s).",
                                 c("en baisse", "en hausse", "inchange")))
         })
# Issue #24 (decision du mainteneur du 24/09/2026) : les nombres issus de
# l'optimiseur ou du bootstrap deja restitues ailleurs dans le resultat ne
# sont pas imprimes dans le detail (derive de plateforme jusqu'a 3,5e-7 en
# relatif). Controle direct : aucune des valeurs formatees comme l'ancien
# libelle n'apparait dans le detail de sa ligne.
verifier("Libelles JB, jackknife et IC : ni bornes de l'IC, ni largeur, ni ecart sur sigma_USP, ni asymetrie / aplatissement (#24)",
         {
           pb <- character(0)
           for (r in list(res_ln_ii1, res_ln_ii6)) {
             tb <- engine_table_tests(r); pf <- r$parametre_final
             d <- r$jackknife$sigma_usp - pf$sigma_usp; i <- which.max(abs(d))
             jb <- test_jarque_bera(r$ajustement$z)
             dj <- tb$commentaire[tb$test == NOM_JK]; di <- tb$commentaire[tb$test == NOM_IC]
             dd <- tb$commentaire[tb$test == "Jarque-Bera"]
             interdits <- list(
               list(di, sprintf("%.4f", r$ic_bootstrap[c(2, 4)])),
               list(di, sprintf("%.1f%%", 100 * r$ajustement$largeur_ic)),
               list(di, "IC 90 % de sigma_USP : ["),
               list(dj, sprintf("%+.1f%%", 100 * d[i] / pf$sigma_usp)),
               list(dd, sprintf(c("%+.3f", "%.3f"), c(jb$skew, jb$kurt))))
             for (it in interdits) for (motif in it[[2]])
               if (grepl(motif, it[[1]], fixed = TRUE)) pb <- c(pb, motif)
             if (length(dj) != 1L || length(di) != 1L || length(dd) != 1L) pb <- c(pb, "ligne absente")
           }
           if (length(pb)) paste("imprime :", paste(unique(pb), collapse = " ; ")) else TRUE
         })
# Jackknife entierement non calcule (tous les reajustements en echec) : la
# table est produite et ne porte pas de ligne jackknife (auparavant : estim
# -Inf, detail "-Inf%"). usp_jackknife est redefini le temps de l'appel.
verifier("run_engine : jackknife entierement NA -> table produite, pas de ligne jackknife ni de -Inf",
         {
           usp_jackknife_orig <- usp_jackknife
           e <- environment(run_engine)
           assign("usp_jackknife", function(fit, sigma_standard, bareme) {
             o <- usp_jackknife_orig(fit, sigma_standard, bareme)
             o[, c("sigma", "sigma_usp", "delta", "gamma")] <- NA_real_
             o
           }, envir = e)
           r <- tryCatch(run_engine(xt = x, yt = y, methode = "premium", segment = 1,
                                    annexe = "II", B = 99, nature_donnees = "brutes"),
                         finally = assign("usp_jackknife", usp_jackknife_orig, envir = e))
           tb <- engine_table_tests(r)
           isTRUE(r$ok) && all(is.na(r$jackknife$sigma_usp)) && nrow(tb) > 0 &&
             !NOM_JK %in% tb$test && NOM_IC %in% tb$test &&
             !any(grepl("Inf", tb$commentaire, fixed = TRUE)) &&
             !any(is.infinite(tb$estimation))
         })

## --- Issue #58 : volumes constants ------------------------------------------
# A x_t constant, a_t = 1 pour tout t : pi_t ne depend plus de delta, la
# vraisemblance est plate en delta, qui n'est pas identifie. La regression
# y ~ x du TOST n'est pas definie. Avant #58 : detail TOST character(0)
# (p_bas / p_haut NULL dans sprintf), engine_table_tests() plantait
# ("arguments imply differing number of rows: 1, 0"), et la ligne delta
# disait "SOLUTION AU BORD" (vrai pour une mauvaise raison).
x_cst <- rep(110, 8)
NOM_TOST <- "Equivalence de la constante a zero (TOST)"
NOM_DELTA <- "Position de delta dans [0,1]"
LIB_DELTA_CST <- "VOLUMES CONSTANTS : la vraisemblance ne depend pas de delta, qui n'est pas identifie"
for (m in c("premium", "reserve1")) {
  r_cst <- run_engine(xt = x_cst, yt = y, methode = m, segment = 1, annexe = "II", B = 99,
                      nature_donnees = if (m == "premium") "brutes")
  tb_cst <- tryCatch(engine_table_tests(r_cst), error = function(e) e)
  verifier(sprintf("Volumes constants (%s) : run_engine ok et engine_table_tests() produit la table (#58)", m),
           if (!isTRUE(r_cst$ok)) "run_engine : ok FALSE"
           else if (inherits(tb_cst, "error")) paste("table :", conditionMessage(tb_cst))
           else nrow(tb_cst) == length(r_cst$tests))
  verifier(sprintf("Volumes constants (%s) : TOST non applicable, INFO, p_retenue NA, detail nommant les volumes constants (#58)", m),
           {
             if (inherits(tb_cst, "error")) "table non produite"
             else {
               l <- tb_cst[tb_cst$test == NOM_TOST, ]
               nrow(l) == 1 && l$type == "non applicable" && l$verdict == "INFO" &&
                 is.na(l$p_retenue) && is.na(l$nature_p) && is.na(l$sens_du_test) &&
                 # Motif unique de la regle R13 (#59), qui remplace le libelle de #58.
                 startsWith(l$commentaire, "volumes x_t constants a la tolerance relative TOL_DELTA_BORD")
             }
           })
  verifier(sprintf("Volumes constants (%s) : ligne delta INFO, libelle de non-identification (#58)", m),
           {
             if (inherits(tb_cst, "error")) "table non produite"
             else {
               l <- tb_cst[tb_cst$test == NOM_DELTA, ]
               if (nrow(l) != 1) "ligne delta absente"
               else if (l$verdict != "INFO") paste("verdict", l$verdict)
               else if (!startsWith(l$commentaire, LIB_DELTA_CST)) paste("detail :", l$commentaire)
               else TRUE
             }
           })
}
# Invariant : chaque champ texte d'une ligne de usp_tests() est de longueur 1
# (et chaque champ numerique aussi), sur les configurations limites :
# volumes constants, delta = 0 (fit0), delta = 1 (fit), marge TOST invalide.
verifier("usp_tests : chaque champ de chaque ligne est de longueur 1 (volumes constants, delta = 0, delta = 1, marge invalide)",
         {
           fit_cst <- usp_ajuster(x_cst, y)
           cas <- list("volumes constants" = usp_tests(fit_cst, boot_fictif(), methode = "premium"),
                       "delta = 0" = usp_tests(fit0, boot_fictif(), methode = "premium"),
                       "delta = 1" = usp_tests(fit, boot_fictif(), methode = "premium"),
                       "delta_equiv = -1" = usp_tests(fit, boot_fictif(), methode = "premium", delta_equiv = -1),
                       "theta_equiv = 0" = usp_tests(fit, boot_fictif(), methode = "premium", theta_equiv = 0))
           pb <- character(0)
           for (nm in names(cas)) for (l in cas[[nm]]) {
             lg <- vapply(l, length, integer(1))
             if (any(lg != 1))
               pb <- c(pb, sprintf("%s / %s : %s", nm, l$test,
                                   paste(names(lg)[lg != 1], collapse = ", ")))
             if (!nzchar(l$detail) && l$type == "non applicable")
               pb <- c(pb, sprintf("%s / %s : detail vide", nm, l$test))
           }
           if (length(pb)) paste(pb, collapse = " ; ") else TRUE
         })
verifier("TOST a marge invalide : non applicable, detail nommant la marge (#58)",
         {
           dd <- vapply(list(usp_tests(fit, boot_fictif(), methode = "premium", delta_equiv = -1),
                             usp_tests(fit, boot_fictif(), methode = "premium", delta_equiv = NA),
                             usp_tests(fit, boot_fictif(), methode = "premium", delta_equiv = Inf),
                             usp_tests(fit, boot_fictif(), methode = "premium", theta_equiv = 0),
                             usp_tests(fit, boot_fictif(), methode = "premium", theta_equiv = Inf)),
                        function(L) {
                          l <- Filter(function(l) l$test == NOM_TOST, L)[[1]]
                          if (l$type != "non applicable" || l$verdict != "INFO") "type/verdict"
                          else l$detail
                        }, character(1))
           if (all(grepl("marge", dd, fixed = TRUE) & grepl("non applicable", dd, fixed = TRUE))) TRUE
           else paste(dd, collapse = " | ")
         })
verifier("TOST : branches non applicable et calculee ont les memes noms de champs, ddl = T - 2 (#58)",
         {
           n_ok <- names(test_tost_intercept(x, y, fit$pi))
           n_cst <- names(test_tost_intercept(x_cst, y, fit$pi))
           n_mg <- names(test_tost_intercept(x, y, fit$pi, theta = 0))
           identical(n_cst, n_ok) && identical(n_mg, n_ok) &&
             test_tost_intercept(x_cst, y, fit$pi)$ddl == length(x_cst) - 2
         })
verifier("TOST : volumes constants priment sur la marge invalide (theta_equiv = 0 a x constant) (#58)",
         {
           l <- Filter(function(l) l$test == NOM_TOST,
                       usp_tests(usp_ajuster(x_cst, y), boot_fictif(), methode = "premium", theta_equiv = 0))[[1]]
           l$type == "non applicable" && grepl("volumes x_t constants", l$detail, fixed = TRUE) &&
             !grepl("marge", l$detail, fixed = TRUE)
         })
verifier("TOST : theta_equiv <= 0 avec delta_equiv fixe -> test calcule, theta ignore (#58)",
         {
           a <- test_tost_intercept(x, y, fit$pi, theta = 0, delta_abs = 5)
           b <- test_tost_intercept(x, y, fit$pi, theta = 0.10, delta_abs = 5)
           is.finite(a$p) && is.na(a$non_applicable) && identical(a, b)
         })
verifier("Volumes constants a la tolerance pres (etendue relative 5e-7) : libelle 'presque pas', tolerance nommee (#58)",
         {
           x_b <- 110 * (1 + c(0, 5e-7, rep(0, 6)))
           f_b <- usp_ajuster(x_b, y)
           d <- ligne_test(f_b, NOM_DELTA)$detail
           isTRUE(usp_regime(f_b$delta, x_b)$volumes_dans_bande) &&
             startsWith(d, "VOLUMES CONSTANTS a la tolerance TOL_DELTA_BORD") &&
             grepl("ne depend presque pas de delta, qui n'est pas identifie", d, fixed = TRUE)
         })
verifier("Volumes constants : vraisemblance plate en delta (objectif identique sur [0, 1] a gamma fixe)",
         {
           fit_cst <- usp_ajuster(x_cst, y)
           v <- vapply(seq(0, 1, by = 0.125), function(d)
             usp_objectif(c(d, fit_cst$gamma), x = x_cst, y = y, xbar = mean(x_cst)), numeric(1))
           isTRUE(usp_regime(fit_cst$delta, x_cst)$volumes_constants) && diff(range(v)) == 0
         })

## --- Issue #4, piste 2 (#42, ADR 0004) : etat du generateur aleatoire --------
# Anciens echecs attendus de l'issue #4, devenus tests ordinaires avec la
# fonction unique engine_sous_graine() (#42), et proprietes nouvelles : toute
# simulation restaure l'etat du generateur de l'appelant, run_engine() compris,
# et le resultat ne depend pas de cet etat. Chaque test repose un etat connu
# (set.seed) pour les suivants.
retirer_graine <- function()
  if (exists(".Random.seed", envir = globalenv())) rm(".Random.seed", envir = globalenv())
etat_graine <- function()
  if (exists(".Random.seed", envir = globalenv())) get(".Random.seed", envir = globalenv()) else NULL
verifier("sw_loi_nulle() ne cree pas de .Random.seed s'il n'en existait pas",
         {
           retirer_graine()
           sw_loi_nulle(10, B_null = 200, seed = 11)
           r <- !exists(".Random.seed", envir = globalenv())
           set.seed(401)
           r
         })
verifier("usp_bootstrap() restaure l'etat du generateur de l'appelant",
         {
           set.seed(402); avant <- .Random.seed
           usp_bootstrap(fit, B = 3, seed = 1)
           identical(avant, .Random.seed)
         })
verifier("mw_bootstrap() restaure l'etat du generateur de l'appelant, et n'en cree pas",
         {
           aj_mw <- mw_ajuster(tri_mw)
           set.seed(403); avant <- .Random.seed
           mw_bootstrap(aj_mw, B = 3, seed = 1)
           r1 <- identical(avant, .Random.seed)
           retirer_graine()
           mw_bootstrap(aj_mw, B = 3, seed = 1)
           r2 <- !exists(".Random.seed", envir = globalenv())
           set.seed(404)
           r1 && r2
         })
verifier("engine_sous_graine() : memes tirages que set.seed(seed) suivi de l'expression",
         {
           set.seed(405)
           a <- engine_sous_graine(7, stats::runif(5))
           set.seed(7); b <- stats::runif(5)
           identical(a, b)
         })
verifier("engine_sous_graine() : etat restaure (ou retire) meme si l'expression leve une erreur",
         {
           set.seed(406); avant <- .Random.seed
           msg <- function(expr) tryCatch({ expr; "" }, error = function(e) conditionMessage(e))
           e1 <- identical(msg(engine_sous_graine(7, { stats::runif(1); stop("essai") })), "essai")
           r1 <- identical(avant, .Random.seed)
           retirer_graine()
           e2 <- identical(msg(engine_sous_graine(7, { stats::runif(1); stop("essai") })), "essai")
           r2 <- !exists(".Random.seed", envir = globalenv())
           set.seed(407)
           e1 && r1 && e2 && r2
         })
# Propriete de l'ADR 0004, point 3 : run_engine() laisse l'etat du generateur
# de l'appelant intact (existant ou absent), pour les trois methodes, et deux
# appels a parametres egaux restent identiques quel que soit cet etat.
# B = B_MIN_USAGE (minimum admis par run_engine()) pour la duree ; horodatage
# et duree retires comme dans nettoyer().
appels_run <- list(
  premium  = function() run_engine(xt = x, yt = y, methode = "premium",
                                   segment = 1, annexe = "II", B = B_MIN_USAGE, seed = 5,
                                   nature_donnees = "brutes"),
  reserve1 = function() run_engine(xt = x, yt = y, methode = "reserve1",
                                   segment = 1, annexe = "II", B = B_MIN_USAGE, seed = 5),
  reserve2 = function() run_engine(methode = "reserve2", triangle = tri_mw,
                                   segment = 1, annexe = "II", B = B_MIN_USAGE, seed = 5))
sans_horodatage <- function(res) {
  res$metadata[c("horodatage", "duree_sec")] <- NULL
  res
}
for (m in names(appels_run)) local({
  appel <- appels_run[[m]]
  verifier(sprintf("run_engine(%s) laisse .Random.seed de l'appelant intact, et n'en cree pas", m),
           {
             set.seed(408); avant <- .Random.seed
             r_a <- appel()
             r1 <- isTRUE(r_a$ok) && identical(avant, .Random.seed)
             retirer_graine()
             appel()
             r2 <- !exists(".Random.seed", envir = globalenv())
             set.seed(409)
             r1 && r2
           })
  verifier(sprintf("run_engine(%s) : resultat identique quel que soit l'etat du generateur avant l'appel", m),
           {
             retirer_graine(); r_0 <- sans_horodatage(appel())
             set.seed(410);    r_1 <- sans_horodatage(appel())
             set.seed(411); invisible(stats::runif(100)); r_2 <- sans_horodatage(appel())
             identical(r_0, r_1) && identical(r_0, r_2)
           })
})
## --- Issue #37 : generateur fixe et consigne, cache de sw_loi_nulle() -------
# engine_sous_graine() pose la graine sous ENGINE_RNG_KIND quel que soit le
# RNGkind() de l'appelant, et restaure le reglage de l'appelant (kind et
# .Random.seed). Chaque test repose ensuite le generateur par defaut de R
# (sous_generateur()), pour ne pas contaminer les fichiers suivants.
sous_generateur <- function(kind, normal.kind = "Inversion", sample.kind = "Rejection", expr) {
  on.exit(suppressWarnings(RNGkind("Mersenne-Twister", "Inversion", "Rejection")), add = TRUE)
  suppressWarnings(RNGkind(kind = kind, normal.kind = normal.kind, sample.kind = sample.kind))
  expr
}
generateurs_appelant <- list(
  lecuyer  = list(kind = "L'Ecuyer-CMRG", normal.kind = "Inversion", sample.kind = "Rejection"),
  rounding = list(kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rounding"),
  knuth_bm = list(kind = "Knuth-TAOCP-2002", normal.kind = "Box-Muller", sample.kind = "Rejection"))
verifier("ENGINE_RNG_KIND : generateur par defaut de R (Mersenne-Twister, Inversion, Rejection)",
         identical(unname(ENGINE_RNG_KIND), c("Mersenne-Twister", "Inversion", "Rejection")) &&
           identical(names(ENGINE_RNG_KIND), c("kind", "normal.kind", "sample.kind")))
for (g in names(generateurs_appelant)) local({
  a <- generateurs_appelant[[g]]
  verifier(sprintf("engine_sous_graine() sous l'appelant %s : RNGkind() interne = ENGINE_RNG_KIND, tirages de set.seed(seed) par defaut", g),
           {
             set.seed(7); ref <- c(stats::runif(3), stats::rnorm(3), sample.int(1000, 3))
             interne <- sous_generateur(a$kind, a$normal.kind, a$sample.kind,
               engine_sous_graine(7, list(k = RNGkind(),
                                          v = c(stats::runif(3), stats::rnorm(3), sample.int(1000, 3)))))
             identical(interne$k, unname(ENGINE_RNG_KIND)) && identical(interne$v, ref)
           })
  # Sous Box-Muller, la reserve du second tirage normal (hors .Random.seed)
  # n'est pas restauree (limite documentee dans engine_sous_graine()) : le
  # test ne porte que sur RNGkind() et .Random.seed.
  verifier(sprintf("engine_sous_graine() restaure le generateur de l'appelant %s (RNGkind() et .Random.seed%s)", g,
                   if (a$normal.kind == "Box-Muller") " ; reserve normale de Box-Muller non restauree, hors test" else ""),
           sous_generateur(a$kind, a$normal.kind, a$sample.kind, {
             set.seed(415); k_avant <- RNGkind(); s_avant <- .Random.seed
             engine_sous_graine(7, stats::runif(5))
             identical(RNGkind(), k_avant) && identical(.Random.seed, s_avant)
           }))
})
verifier("engine_sous_graine() sans .Random.seed chez l'appelant en L'Ecuyer-CMRG : kind restaure, aucun .Random.seed cree",
         sous_generateur("L'Ecuyer-CMRG", expr = {
           retirer_graine()
           engine_sous_graine(7, stats::runif(5))
           r <- !exists(".Random.seed", envir = globalenv()) && identical(RNGkind()[1], "L'Ecuyer-CMRG")
           # le generateur de l'appelant est bien celui qui sert ensuite
           stats::runif(1)
           r && get(".Random.seed", envir = globalenv())[1] %% 100L == 7L
         }))
verifier("engine_sous_graine() : generateur de l'appelant restaure meme si l'expression leve une erreur",
         sous_generateur("L'Ecuyer-CMRG", expr = {
           set.seed(416); s_avant <- .Random.seed
           try(engine_sous_graine(7, { stats::runif(1); stop("essai") }), silent = TRUE)
           identical(RNGkind()[1], "L'Ecuyer-CMRG") && identical(.Random.seed, s_avant)
         }))
verifier("sw_cle_cache() : la cle du cache depend du generateur",
         {
           k1 <- sw_cle_cache(8, 20000, 20260901)
           k2 <- sw_cle_cache(8, 20000, 20260901, kind = c("L'Ecuyer-CMRG", "Inversion", "Rejection"))
           k3 <- sw_cle_cache(8, 20000, 20260901, kind = c("Mersenne-Twister", "Inversion", "Rounding"))
           identical(k1, sw_cle_cache(8, 20000, 20260901, kind = ENGINE_RNG_KIND)) &&
             length(unique(c(k1, k2, k3))) == 3L
         })
verifier("sw_loi_nulle() : loi identique qu'elle soit calculee sous L'Ecuyer-CMRG ou sous le generateur par defaut",
         {
           vider <- function() rm(list = grep("^n10_B500_s13", ls(.cache_sw), value = TRUE), envir = .cache_sw)
           vider(); w_l <- sous_generateur("L'Ecuyer-CMRG", expr = sw_loi_nulle(10, B_null = 500, seed = 13))
           vider(); w_m <- sw_loi_nulle(10, B_null = 500, seed = 13)
           vider()
           identical(w_l, w_m)
         })
# Critere d'acceptation de l'issue #37 : run_engine() rend des objets
# identical() (hors horodatage et duree) quel que soit RNGkind() avant l'appel,
# et laisse le generateur de l'appelant intact. Le cache de la loi nulle de
# Shapiro-Wilk est vide avant chaque appel sous un autre generateur, pour que
# la loi soit recalculee sous ce generateur (constat du 22/09 sur #37).
for (m in names(appels_run)) local({
  appel <- appels_run[[m]]
  r_def <- sans_horodatage(appel())
  for (g in names(generateurs_appelant)) {
    a <- generateurs_appelant[[g]]
    verifier(sprintf("run_engine(%s) sous l'appelant %s : resultat identique au generateur par defaut, generateur de l'appelant intact", m, g),
             sous_generateur(a$kind, a$normal.kind, a$sample.kind, {
               rm(list = ls(.cache_sw), envir = .cache_sw)
               set.seed(417); k_avant <- RNGkind(); s_avant <- .Random.seed
               r_g <- sans_horodatage(appel())
               identical(r_g, r_def) && identical(RNGkind(), k_avant) && identical(.Random.seed, s_avant)
             }))
  }
})
# ADR 0004, point 2 (decision du mainteneur du 25/09/2026) : generateur et
# graine fixe des simulations autres que le bootstrap consignes dans
# $metadata ; la valeur consignee est celle qui a servi (la loi nulle se
# recalcule a partir de metadata). Depuis l'issue #47, l'enveloppe du
# QQ-plot n'a plus de graine propre : seed_enveloppe_qq est absent pour les
# trois methodes, et l'enveloppe se recalcule a partir de bootstrap$z_boot
# (tests/unitaires/test_enveloppe_qq.R, test (ii)).
for (m in names(appels_run)) local({
  r <- appels_run[[m]]()
  verifier(sprintf("run_engine(%s) : generateur et graine consignes dans $metadata, sans seed_enveloppe_qq (#47)", m),
           {
             md <- r$metadata
             identical(md$generateur, as.list(ENGINE_RNG_KIND)) &&
               identical(md$seed, 5) && identical(md$seed_loi_nulle_sw, SEED_LOI_NULLE_SW) &&
               identical(md$seed_loi_nulle_sw, 20260901) &&
               !"seed_enveloppe_qq" %in% names(md)
           })
  if (m != "reserve2")
    verifier(sprintf("run_engine(%s) : enveloppe du QQ-plot recalculee a partir de bootstrap$z_boot (#47)", m),
             {
               zb <- r$bootstrap$z_boot
               S <- t(apply(zb[apply(is.finite(zb), 1, all), , drop = FALSE], 1, sort))
               env <- t(apply(S, 2, stats::quantile, probs = c(0.05, 0.95), type = 7))
               q <- r$plots_data$qqnorm
               o <- order(order(q$theorique))
               identical(q$env_bas, unname(env[o, 1])) && identical(q$env_haut, unname(env[o, 2]))
             })
})
verifier("sw_loi_nulle() par defaut = loi tiree sous metadata$seed_loi_nulle_sw",
         {
           rm(list = grep("^n9_B300_", ls(.cache_sw), value = TRUE), envir = .cache_sw)
           a <- sw_loi_nulle(9, B_null = 300)
           b <- sw_loi_nulle(9, B_null = 300, seed = appels_run$premium()$metadata$seed_loi_nulle_sw)
           w <- engine_sous_graine(20260901, replicate(300, unname(stats::shapiro.test(stats::rnorm(9))$statistic)))
           identical(a, b) && identical(a, sort(w[is.finite(w)]))
         })
# Constat C1 d'app-review sur #33 (decision du mainteneur du 25/09/2026) :
# booleens de coloration des graphiques d'influence calcules par le moteur.
# L'affichage comparait 100 * ecart a 100 * REPERE (pourcentages) ; le moteur
# compare les fractions : les deux doivent coincider sur les cas de test.
verifier("engine_influence() : fort_ecart_sigma = |ecart_sigma| > REPERE_INFLUENCE_SIGMA (et = ancienne comparaison en %)",
         {
           ok <- TRUE
           for (m in c("premium", "reserve1")) {
             d <- appels_run[[m]]()$plots_data$influence
             ok <- ok && is.logical(d$fort_ecart_sigma) &&
               identical(d$fort_ecart_sigma, abs(d$ecart_sigma) > REPERE_INFLUENCE_SIGMA) &&
               identical(d$fort_ecart_sigma, abs(100 * d$ecart_sigma) > 100 * REPERE_INFLUENCE_SIGMA)
           }
           # cas construit de part et d'autre du repere
           f <- usp_ajuster(x, y)
           dj <- engine_influence(f, list(sigma_usp = c(1.2, 0.95, 1.05, 0.85, 1, 1.11, 0.89, 1)), 1)
           ok && identical(dj$fort_ecart_sigma, c(TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, TRUE, FALSE))
         })
verifier("engine_influence() sans jackknife : ni ecart_sigma ni fort_ecart_sigma",
         {
           d <- engine_influence(usp_ajuster(x, y))
           is.null(d$ecart_sigma) && is.null(d$fort_ecart_sigma)
         })
verifier("mw_influence() : fort_dfbeta = |dfbeta_relatif| > REPERE_DFBETA_MW (et = ancienne comparaison en %)",
         {
           d <- appels_run$reserve2()$plots_data$influence
           d2 <- mw_influence(mw_ajuster(tri_mw))
           is.logical(d$fort_dfbeta) &&
             identical(d$fort_dfbeta, abs(d$dfbeta_relatif) > REPERE_DFBETA_MW) &&
             identical(d$fort_dfbeta, abs(100 * d$dfbeta_relatif) > 100 * REPERE_DFBETA_MW) &&
             identical(d2, d)
         })
verifier("mw_influence() : fort_dfbeta discrimine de part et d'autre du repere (triangle perturbe)",
         {
           t2 <- tri_mw; t2[1, 2] <- t2[1, 2] * 1.5
           d <- mw_influence(mw_ajuster(t2))
           any(d$fort_dfbeta) && !all(d$fort_dfbeta) &&
             identical(d$fort_dfbeta, abs(d$dfbeta_relatif) > REPERE_DFBETA_MW)
         })
# ADR 0004, point 4 : aucun alea hors calcul. Les dossiers temporaires de
# engine_ecrire_xlsx() / engine_lire_xlsx() viennent de tempfile() et sont
# supprimes en sortie. Le repli interne (sans openxlsx) a besoin de la
# commande zip pour ecrire : test saute, et signale, sans openxlsx ni zip.
if (requireNamespace("openxlsx", quietly = TRUE) || nzchar(Sys.which("zip"))) {
  verifier("engine_ecrire_xlsx() / engine_lire_xlsx() : aller-retour sans tirage ni dossier temporaire residuel",
           {
             residus <- function() list.files(tempdir(), pattern = "^(xlsx|unx)_")
             avant_d <- residus()
             set.seed(412); avant <- .Random.seed
             f <- tempfile(fileext = ".xlsx")
             df <- data.frame(t = 2001:2003, x = c(1.5, 2, 3), lib = c("a", "b", "c"),
                              stringsAsFactors = FALSE)
             engine_ecrire_xlsx(df, f)
             lu <- engine_lire_xlsx(f)
             unlink(f)
             identical(avant, .Random.seed) && identical(residus(), avant_d) &&
               identical(as.numeric(lu$x), df$x) && identical(as.character(lu$lib), df$lib)
           })
} else cat("  [saute] engine_ecrire_xlsx() / engine_lire_xlsx() : ni openxlsx ni zip\n")

fin_fichier()
