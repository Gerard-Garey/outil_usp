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
# Le verdict force (ALERTE a R2 < 0,5) a ete retire par #24 (ADR 0001,
# amendement du 23/09/2026) : un diagnostic sort INFO, sens NA.
verifier("Issue #39 (4) : R2 de type diagnostic (type et detail), INFO et sens NA (#24)",
         {
           l1 <- ligne_test(fit, "Coefficient de determination R2")
           l0 <- ligne_test(fit0, "Coefficient de determination R2")
           types <- vapply(usp_tests(fit, boot_fictif()), function(l) l$type, character(1))
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
                         annexe = "II", B = 99)
res_ln_ii6 <- run_engine(xt = x, yt = y, methode = "premium", segment = 6,
                         annexe = "II", B = 99)
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
tab_fictif <- lignes_df(usp_tests(fit, boot_fictif()))
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
                        # de la table vers res$controles (#22, M11), reperes
                        # verifies dans test_controles_numeriques.R.
                        "Sensibilite au retrait d'une annee (jackknife)" = "10 % / 20 %",
                        "Largeur relative de l'IC bootstrap 90%" = "50 % / 80 %")
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
           for (nm in c(names(reperes), "Position de delta dans [0,1]"))
             if (grepl("seuil", dd[nm], fixed = TRUE)) pb <- c(pb, paste(nm, ": contient 'seuil'"))
           if (!any(vapply(c("AU BORD", "interieur", "VOLUMES CONSTANTS"), grepl, logical(1),
                           x = d_delta, fixed = TRUE)))
             pb <- c(pb, "Position de delta : ni 'AU BORD' ni 'interieur' ni 'VOLUMES CONSTANTS'")
           if (length(pb)) paste(pb, collapse = " ; ") else TRUE
         })
# Invariance a la table de l'annexe : entre les segments 1 et 6 de l'annexe II
# (meme bareme long, sigma_std differents), la part estimee sigma(delta,
# gamma) et ses ecarts ne dependent pas de la table ; les ecarts rapportes a
# sigma_USP en dependent par (1-c) sigma_std. Relation exacte, recalculee ici
# depuis res$jackknife, res$bootstrap$sigma_boot et res$parametre_final :
#   |d sigma_hat| / sigma_hat = ecart_jackknife * sigma_USP / (c sqrt((T+1)/(T-1)) sigma_hat)
# (et de meme pour la largeur de l'IC, le quantile commutant avec
# l'application affine croissante sigma -> c corr sigma + (1-c) sigma_std).
nombre_detail <- function(tb, nom, motif) {
  d <- tb$commentaire[tb$test == nom]
  as.numeric(sub(motif, "\\1", regmatches(d, regexpr(motif, d))))
}
NOM_JK <- "Sensibilite au retrait d'une annee (jackknife)"
NOM_IC <- "Largeur relative de l'IC bootstrap 90%"
M_JK_EST <- "([+-][0-9.]+)% sur la part estimee"
M_JK_USP <- "annee [0-9]+ : ([+-][0-9.]+)% sur sigma_USP"
M_IC_EST <- "= ([0-9.]+)% sur la part estimee"
M_IC_USP <- "^\\(q95 - q05\\) / sigma_USP = ([0-9.]+)%"
verifier("Jackknife et IC : part estimee identique entre II-1 et II-6, ecart sur sigma_USP different",
         {
           t1 <- tab_ln; t6 <- engine_table_tests(res_ln_ii6)
           v <- c(jk_est_1 = nombre_detail(t1, NOM_JK, M_JK_EST), jk_est_6 = nombre_detail(t6, NOM_JK, M_JK_EST),
                  jk_usp_1 = nombre_detail(t1, NOM_JK, M_JK_USP), jk_usp_6 = nombre_detail(t6, NOM_JK, M_JK_USP),
                  ic_est_1 = nombre_detail(t1, NOM_IC, M_IC_EST), ic_est_6 = nombre_detail(t6, NOM_IC, M_IC_EST),
                  ic_usp_1 = nombre_detail(t1, NOM_IC, M_IC_USP), ic_usp_6 = nombre_detail(t6, NOM_IC, M_IC_USP))
           if (length(v) != 8L || any(!is.finite(v))) "nombre non extrait du detail"
           else if (v[["jk_est_1"]] == v[["jk_est_6"]] && v[["ic_est_1"]] == v[["ic_est_6"]] &&
                    v[["jk_usp_1"]] != v[["jk_usp_6"]] && v[["ic_usp_1"]] != v[["ic_usp_6"]]) TRUE
           else paste(names(v), v, sep = " = ", collapse = " ; ")
         })
verifier("Jackknife et IC : part estimee = ecart sur sigma_USP * sigma_USP / (c corr sigma_hat), a 1e-10 (II-1, II-6)",
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
               isTRUE(proche(ic_est, e_ic * pf$sigma_usp / (cr * corr * sh), rel = 1e-10)) &&
               nombre_detail(tb, NOM_JK, M_JK_EST) == as.numeric(sprintf("%+.1f", 100 * jk_est)) &&
               nombre_detail(tb, NOM_IC, M_IC_EST) == as.numeric(sprintf("%.1f", 100 * ic_est))
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
           m <- message_erreur(f(fit, boot_fictif()))
           grepl("un verdict n'est admis que pour type = 'test' ou 'procedure de decision'", m, fixed = TRUE) &&
             grepl("Leviers (hat values)", m, fixed = TRUE)
         })
verifier("add() (usp_tests) refuse une procedure de decision sans verdict (ESD)",
         {
           f <- usp_tests_modifie("verdict = if (ro$nb_outliers >= 2)",
                                  "verdict = if (TRUE) NULL else if (ro$nb_outliers >= 2)")
           m <- message_erreur(f(fit, boot_fictif()))
           grepl("une ligne de type 'procedure de decision' doit fournir son verdict", m, fixed = TRUE) &&
             grepl("Valeurs aberrantes multiples (ESD generalise)", m, fixed = TRUE)
         })
# Branche robustesse = NULL : usp_tests() appele directement avec un fit
# portant ecart_jackknife et largeur_ic, sans les elements du detail.
verifier("Jackknife et IC sans robustesse : detail sur sigma_USP seul, repere nomme, pas de part estimee",
         {
           f <- fit; f$ecart_jackknife <- 0.123; f$largeur_ic <- 0.456
           tb <- lignes_df(usp_tests(f, boot_fictif()))
           dj <- tb$commentaire[tb$test == NOM_JK]; di <- tb$commentaire[tb$test == NOM_IC]
           length(dj) == 1L && length(di) == 1L &&
             identical(dj, paste("ecart maximal sur sigma_USP = +12.3% (repere conventionnel",
                                 "10 % / 20 % ; depend de la table de l'annexe par (1-c) sigma_std)")) &&
             identical(di, paste("(q95 - q05) / sigma_USP = 45.6% (repere conventionnel 50 % / 80 % ;",
                                 "depend de la table de l'annexe par (1-c) sigma_std)")) &&
             all(tb$verdict[tb$test %in% c(NOM_JK, NOM_IC)] == "INFO")
         })
verifier("Jackknife : annee et signe du detail = argmax |d| et round(100 d[i] / sigma_USP, 1), depuis res$jackknife",
         {
           ok <- TRUE
           for (r in list(res_ln_ii1, res_ln_ii6)) {
             tb <- engine_table_tests(r); pf <- r$parametre_final
             d <- r$jackknife$sigma_usp - pf$sigma_usp; i <- which.max(abs(d))
             dj <- tb$commentaire[tb$test == NOM_JK]
             an <- as.integer(sub("^retrait de l'annee ([0-9]+) :.*$", "\\1", dj))
             ok <- ok && identical(an, i) &&
               nombre_detail(tb, NOM_JK, M_JK_USP) == round(100 * d[i] / pf$sigma_usp, 1)
           }
           ok
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
                                    annexe = "II", B = 99),
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
  r_cst <- run_engine(xt = x_cst, yt = y, methode = m, segment = 1, annexe = "II", B = 99)
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
                 grepl("volumes constants", l$commentaire, fixed = TRUE) &&
                 grepl("non applicable", l$commentaire, fixed = TRUE)
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
           cas <- list("volumes constants" = usp_tests(fit_cst, boot_fictif()),
                       "delta = 0" = usp_tests(fit0, boot_fictif()),
                       "delta = 1" = usp_tests(fit, boot_fictif()),
                       "delta_equiv = -1" = usp_tests(fit, boot_fictif(), delta_equiv = -1),
                       "theta_equiv = 0" = usp_tests(fit, boot_fictif(), theta_equiv = 0))
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
           dd <- vapply(list(usp_tests(fit, boot_fictif(), delta_equiv = -1),
                             usp_tests(fit, boot_fictif(), delta_equiv = NA),
                             usp_tests(fit, boot_fictif(), delta_equiv = Inf),
                             usp_tests(fit, boot_fictif(), theta_equiv = 0),
                             usp_tests(fit, boot_fictif(), theta_equiv = Inf)),
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
           n_ok <- names(test_tost_intercept(x, y))
           n_cst <- names(test_tost_intercept(x_cst, y))
           n_mg <- names(test_tost_intercept(x, y, theta = 0))
           identical(n_cst, n_ok) && identical(n_mg, n_ok) &&
             test_tost_intercept(x_cst, y)$ddl == length(x_cst) - 2
         })
verifier("TOST : volumes constants priment sur la marge invalide (theta_equiv = 0 a x constant) (#58)",
         {
           l <- Filter(function(l) l$test == NOM_TOST,
                       usp_tests(usp_ajuster(x_cst, y), boot_fictif(), theta_equiv = 0))[[1]]
           l$type == "non applicable" && grepl("volumes constants", l$detail, fixed = TRUE) &&
             !grepl("marge", l$detail, fixed = TRUE)
         })
verifier("TOST : theta_equiv <= 0 avec delta_equiv fixe -> test calcule, theta ignore (#58)",
         {
           a <- test_tost_intercept(x, y, theta = 0, delta_abs = 5)
           b <- test_tost_intercept(x, y, theta = 0.10, delta_abs = 5)
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
