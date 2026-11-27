###############################################################################
#  tests/unitaires/test_p_mc_regime.R  --  P-VALUE MONTE-CARLO CONDITIONNELLE
#  AU REGIME DE DELTA ESTIME (issue #240, ADR 0014, variante V3h)
#
#  Specification : docs/specifications/240-p-mc-conditionnelle-regime.md,
#  par. 7 (tests U1 a U14), approuvee au point d'arret C1 le 11/10/2026.
#  Fonctions visees : usp_graine_flux_regime(), usp_bootstrap() (variante V1
#  au bord, V3b a delta estime interieur, champ p_mc_regime), usp_tests()
#  (nature), run_engine() (metadata$seed_flux_regime) ; U15 : transcription
#  rejeu_p_mc_v3h() de tests/outils_tests.R (#262) ; U16 : progression du
#  flux complementaire sous progres = TRUE (#255).
#
#  Oracle (U2 a U4) : valeurs brutes de la mesure de #229,
#  docs/tableaux/20261010-issue229-p-conditionnelle-regime-brut.tsv (valeurs
#  %.17g, motif "-" = NA). Egalites EXACTES (identical()) : une p est un
#  rapport de comptes ; un echec ne se corrige pas par une tolerance
#  (specification, par. 7, regle sur l'identite avec #229).
#
#  Replications y*_b recopiees en dur au format %.17g, extraites une fois par
#  le generateur de #229 (tests/p_conditionnelle_regime_t8.R, l. 2004-2006) :
#    Y <- engine_sous_graine(20260927, t(vapply(seq_len(R), function(b)
#           usp_simuler(FIT0), numeric(8))))
#  ligne b, avec FIT0 = usp_ajuster(xt, yt) de donnees_ln.csv (J1),
#  usp_ajuster(xi, yi) (J2), fit_synth(0,70, X3, 0,60, log(0,10 / 0,70))
#  (J3) ; garde : usp_ajuster(x, y_b)$delta egale la colonne delta du TSV a
#  1e-9 pres en relatif.
#
#  Coupe en deux fichiers (issue #561, etape 4 de S8), sans perte : ce fichier
#  porte U1, U3, U4, U7, U8, U11, U14 et U15 ; test_p_mc_regime_partie_2.R porte
#  U2, U5, U6, U9, U10, U12, U13 et U16 (U10, U12 et U16 lisent boot_u2 de U2 ;
#  U9 et U10 lisent lignes_mc de U5 : ces sections restent ensemble). Les jeux,
#  l'oracle et les fonctions de controle communs sont dans outils_p_mc_regime.R,
#  charge par les deux fichiers.
#  Duree : environ 75 s par fichier (mesure locale du 26/11/2026, quatre
#  processus a la fois ; U3 seul, 25 000 tirages, environ 40 s ; decision
#  Q-240-3 : tout dans la batterie).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_p_mc_regime.R")

.racine <- if (exists("RACINE", inherits = TRUE)) RACINE else "."
source(file.path(.racine, "tests", "unitaires", "outils_p_mc_regime.R"), local = TRUE)

# =============================================================================
# U1 -- graine du flux
# =============================================================================
graines <- c(20260831, 0, -1, -M, M - D, M - D + 1, M)
attendues <- c(20800000, D, D - 1, -M + D, M, -M, D - M - 1)
verifier("U1 usp_graine_flux_regime() : valeurs attendues (20800000 ; D ; D - 1 ; -M + D ; M ; -M ; D - M - 1)",
         {
           g <- vapply(graines, usp_graine_flux_regime, numeric(1))
           identical(g, attendues) && identical(D - M - 1, -2146944479)
         })
verifier("U1 graine du flux : g != seed, |g| <= M, entiere, double, engine_sous_graine(g, runif(1)) sans erreur",
         all(vapply(graines, function(s) {
           g <- usp_graine_flux_regime(s)
           is.double(g) && g != s && abs(g) <= M && g == round(g) &&
             !leve_erreur(engine_sous_graine(g, stats::runif(1)))
         }, logical(1))))
verifier("U1 graine du flux : refus de 2^31, 1,5, NA, Inf (et non scalaire, non numerique)",
         leve_erreur(usp_graine_flux_regime(2^31)) && leve_erreur(usp_graine_flux_regime(-2^31)) &&
           leve_erreur(usp_graine_flux_regime(1.5)) && leve_erreur(usp_graine_flux_regime(NA)) &&
           leve_erreur(usp_graine_flux_regime(NA_real_)) && leve_erreur(usp_graine_flux_regime(Inf)) &&
           leve_erreur(usp_graine_flux_regime(c(1, 2))) && leve_erreur(usp_graine_flux_regime("1")))
# Suggestion d'actuary (etape 4 de la branche A4) : seed non entier refuse par
# usp_bootstrap() lui-meme, et non seulement par usp_graine_flux_regime() ;
# appel court (B = 3, J2 observe).
verifier("U1 usp_bootstrap() sur J2 observe, B = 3 : seed = 1,5 refuse (erreur de usp_graine_flux_regime())",
         {
           e <- tryCatch(usp_bootstrap(f2, B = 3, seed = 1.5), error = function(e) e)
           inherits(e, "error") && grepl("^usp_graine_flux_regime\\(\\) : seed doit etre", conditionMessage(e))
         })
verifier("U1 usp_bootstrap() sur J2 observe a seed = M, B = 99 : sans erreur, graine du flux D - M - 1, flux pose",
         {
           bm <- usp_bootstrap(f2, B = 99, seed = M)
           identical(bm$p_mc_regime$graine_flux, D - M - 1) && identical(bm$p_mc_regime$variante, "V3b") &&
             bm$p_mc_regime$tirages > 99
         })

# =============================================================================
# U3 -- identite, B_max atteint, retenus >= 50 (J1 b = 1455)
# =============================================================================
local({
  cc <- YB$J1_1455
  fit <- usp_ajuster(cc$x, cc$y)
  o <- oracle("J1", 1455, "V3b")
  verifier("U3 J1 b = 1455 : garde, delta estime = colonne delta du TSV (1e-9 relatif), interieur (0,2344)",
           isTRUE(proche(fit$delta, o$num("delta"), rel = 1e-9)) && interieur(fit$delta, cc$x) &&
             abs(fit$delta - 0.2344) < 1e-4)
  bt <- usp_bootstrap(fit, B = 999, seed = 20260831 + 1455)
  verifier("U3 J1 b = 1455 : p_mc, B_effectif, motif_mc identical() a p_V3b, B_V3b, m_V3b de #229 (motifs NA)",
           isTRUE(egal_oracle(bt, o)) && all(is.na(bt$motif_mc)) && all(is.finite(bt$p_mc)))
  verifier("U3 J1 b = 1455 : err_mc et granularite_stat = leur formule", formules_ok(bt))
  verifier("U3 J1 b = 1455 : p_mc_regime (tirages 25000, retenus_v1 34, retenus 930, rejets (0, 23105, 0), arret B_max)",
           {
             r <- bt$p_mc_regime
             identical(r$tirages, 25000) && identical(r$tirages, o$num("tir_v3b")) &&
               identical(r$retenus_v1, 34) && identical(r$retenus, 930) &&
               identical(r$retenus, o$num("ret_v3b")) &&
               identical(r$rejets_flux, c(reajustement = 0, hors_regime = 23105, statistiques = 0)) &&
               identical(r$arret, "B_max") && identical(r$graine_flux, 20800000 + 1455)
           })
  verifier_invariants("U3 J1 b = 1455", bt, cc$x)
})

# =============================================================================
# U4 -- identite avec V1 au bord
# =============================================================================
for (k in c("J2_4", "J3_1")) {
  cc <- YB[[k]]; jeu <- cle(k)
  fit <- usp_ajuster(cc$x, cc$y)
  o <- oracle(jeu, cc$b, "V1")
  reg_att <- if (fit$delta >= 0.5) "bord1" else "bord0"
  verifier(sprintf("U4 %s b = %d : garde, delta estime = colonne delta du TSV, au bord (%s)", jeu, cc$b, reg_att),
           isTRUE(proche(fit$delta, o$num("delta"), rel = 1e-9, abs = 1e-12)) &&
             usp_regime(fit$delta, cc$x)$delta_au_bord &&
             identical(reg_att, ligne_tsv(jeu, cc$b)$regime))
  cpt <- compteur_rapide()
  bt <- boot_enveloppe(list(usp_ajuster_rapide = cpt$fn))(fit, B = 999, seed = 20260831 + cc$b)
  verifier(sprintf("U4 %s b = %d : p_mc, B_effectif, motif_mc identical() a p_V1, B_V1, m_V1 de #229", jeu, cc$b),
           egal_oracle(bt, o))
  verifier(sprintf("U4 %s b = %d : p_mc_regime au contrat V1 (%s, delta estime au bord, tirages 999)", jeu, cc$b, reg_att),
           contrat_v1(bt, reg_att, "delta estime au bord", 20260831 + cc$b, 999))
  verifier(sprintf("U4 %s b = %d : usp_ajuster_rapide() appelee exactement B = 999 fois", jeu, cc$b),
           identical(cpt$n, 999L))
}
local({
  cpt <- compteur_rapide()
  bt <- boot_enveloppe(list(usp_ajuster_rapide = cpt$fn))(f1, B = 99, seed = 20260831)
  b0 <- usp_bootstrap(f1, B = 99, seed = 20260831)
  verifier("U4 J1 observe, B = 99 : contrat V1 (bord1, delta estime au bord), usp_ajuster_rapide() appelee 99 fois, copie enveloppee identique au moteur",
           contrat_v1(bt, "bord1", "delta estime au bord", 20260831, 99) && identical(cpt$n, 99L) &&
             identical(bt, b0))
})

# =============================================================================
# U7 -- B != 999, contre-implementation (copie declaree de rejouer_v1(complet
# = TRUE) et de completer_v3b() de tests/p_conditionnelle_regime_t8.R,
# parametrees par B : B_cible = B, B_max = 25 (B + 1), graine
# usp_graine_flux_regime(seed) ; criteres de completer_v3b() alignes sur le
# moteur par #280 ; regime lu par regime_tirage() de tests/outils_tests.R,
# partagee avec ce script)
# =============================================================================
# tests/outils_tests.R source dans un environnement dedie (comme
# test_comparateur.R), lu par U7 (regime_tirage()) et U15 (rejeu_p_mc_v3h()).
OE <- local({
  .dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
    .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
    if (length(.f)) dirname(.f) else "tests/unitaires"
  }
  oe <- new.env(parent = globalenv())
  sys.source(file.path(.dossier, "..", "outils_tests.R"), envir = oe)
  oe
})
regime_tirage <- OE$regime_tirage
# Garde de regime_tirage() (#280) : delta_au_bord de usp_regime() ne lit pas
# les volumes, ce qui permet a regime_tirage() de l'appeler sur x = 1 ; la
# partition doit egaler celle de usp_regime(delta, x) pour des volumes
# variables (J2, J3) et constants (exacts, et dans la bande TOL_DELTA_BORD),
# sur un balayage de delta qui encadre les bords TOL_DELTA_BORD et
# 1 - TOL_DELTA_BORD au plus pres, et celle de code_regime() des scripts hors
# CI pour un delta fini.
local({
  e <- TOL_DELTA_BORD; u <- .Machine$double.eps
  d <- c(seq(-0.1, 1.1, by = 1e-3), 0, 1, 0.5, e, 1 - e, e * (1 + c(-1, 1) * u),
         (1 - e) + c(-1, 1) * u, e / 2, 1 - e / 2, -e, 1 + e)
  ref <- function(delta, x) if (!usp_regime(delta, x)$delta_au_bord) "interieur" else
    if (delta >= 0.5) "bord1" else "bord0"
  code_regime <- function(delta) if (delta >= 1 - e) "bord1" else if (delta <= e) "bord0" else "interieur"
  pt <- vapply(d, regime_tirage, "")
  xs <- list(x2, X3, rep(100, 8), 100 * (1 + rep(c(0, e / 2), 4)))
  verifier("U7 regime_tirage() : partition identique a usp_regime(delta, x) (volumes variables et constants) et a code_regime(), bords encadres",
           all(vapply(xs, function(x) identical(vapply(d, ref, "", x = x), pt), logical(1))) &&
             identical(vapply(d, code_regime, ""), pt) && all(c("bord0", "interieur", "bord1") %in% pt))
})
rejouer_v1_u7 <- function(fit, graine, B, cat_ = USP_CATALOGUE_MC) {
  e_obs <- .usp_contexte_mc(fit$x, fit$y, fit$z, fit$pi)
  nm <- names(cat_)
  sim <- matrix(NA_real_, B, length(nm), dimnames = list(NULL, nm))
  d <- rep(NA_real_, B)
  sig <- del <- gam <- sig_r <- rep(NA_real_, B); n_echec_r <- 0L; zb <- matrix(NA_real_, B, length(fit$x))
  engine_sous_graine(graine, {
    stats_obs <- .mc_evaluer(cat_, e_obs)
    for (b in seq_len(B)) {
      yb <- usp_simuler(fit)
      f <- try(usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
      if (inherits(f, "try-error")) next
      sb <- try(.mc_evaluer(cat_, .usp_contexte_mc(fit$x, yb, f$z, f$pi)), silent = TRUE)
      if (inherits(sb, "try-error")) next
      sim[b, ] <- sb[nm]; d[b] <- f$delta
      zb[b, ] <- f$z; sig[b] <- f$sigma
      if (!is.null(f$delta)) { del[b] <- f$delta; gam[b] <- f$gamma }
      fr <- try(usp_ajuster_contraint(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
      if (inherits(fr, "try-error")) n_echec_r <- n_echec_r + 1L else sig_r[b] <- fr$sigma
    }
  })
  list(e_obs = e_obs, stats_obs = stats_obs, sim = sim, delta = d, ok = is.finite(d),
       boot = list(sigma_boot = sig[is.finite(sig)], delta_boot = del[is.finite(del)],
                   gamma_boot = gam[is.finite(gam)], sigma_boot_restreint = sig_r[is.finite(sig_r)],
                   n_echec_restreint = n_echec_r, z_boot = zb))
}
completer_v3b_u7 <- function(fit, r_b, S_A, graine, B, cat_ = USP_CATALOGUE_MC) {
  B_CIBLE <- B; B_MAX <- 25L * (B + 1L)
  nm <- names(cat_)
  S <- matrix(NA_real_, B_CIBLE, length(nm), dimnames = list(NULL, nm))
  nA0 <- nrow(S_A); nA <- nA0
  if (nA) S[seq_len(nA), ] <- S_A[, nm]
  tir <- B; cpt <- c(rapide = 0L, hors = 0L, stats = 0L)
  if (nA < B_CIBLE) engine_sous_graine(graine, {
    while (nA < B_CIBLE && tir < B_MAX) {
      tir <- tir + 1L
      yb <- usp_simuler(fit)
      f <- try(usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
      if (inherits(f, "try-error") || !is.finite(f$delta)) { cpt[["rapide"]] <- cpt[["rapide"]] + 1L; next }
      if (regime_tirage(f$delta) != r_b) { cpt[["hors"]] <- cpt[["hors"]] + 1L; next }
      sb <- try(.mc_evaluer(cat_, .usp_contexte_mc(fit$x, yb, f$z, f$pi)), silent = TRUE)
      if (inherits(sb, "try-error")) { cpt[["stats"]] <- cpt[["stats"]] + 1L; next }
      nA <- nA + 1L
      S[nA, ] <- sb[nm]
    }
  })
  list(S = S[seq_len(nA), , drop = FALSE], nA0 = nA0, nA = nA, tir = tir, cpt = cpt,
       arret = if (nA == B_CIBLE) "cible" else "B_max", B_max = B_MAX)
}
attendu_u7 <- function(fit, B, seed) {
  r_b <- regime_tirage(fit$delta)
  rv <- rejouer_v1_u7(fit, seed, B)
  rd <- vapply(rv$delta, function(d) if (is.finite(d)) regime_tirage(d) else NA_character_, "")
  A <- rv$ok & !is.na(rd) & rd == r_b
  v3 <- completer_v3b_u7(fit, r_b, rv$sim[A, , drop = FALSE], usp_graine_flux_regime(seed), B)
  mc <- .mc_p_values(v3$S, rv$stats_obs, USP_CATALOGUE_MC, rv$e_obs)
  c(list(stats_obs = as.list(rv$stats_obs), p_mc = mc$p_mc, err_mc = mc$err_mc,
         B_effectif = mc$B_effectif, granularite = 1 / (B + 1),
         sigma_boot = rv$boot$sigma_boot, delta_boot = rv$boot$delta_boot,
         gamma_boot = rv$boot$gamma_boot, B = B,
         granularite_stat = mc$granularite, motif_mc = mc$motif_mc,
         sigma_boot_restreint = rv$boot$sigma_boot_restreint,
         n_echec_restreint = rv$boot$n_echec_restreint, z_boot = rv$boot$z_boot),
    list(p_mc_regime = list(
      regime_obs = r_b, variante = "V3b", motif_v1 = NA_character_,
      graine_flux = usp_graine_flux_regime(seed), B_cible = as.numeric(B),
      B_max = as.numeric(v3$B_max), tirages = as.numeric(v3$tir),
      retenus_v1 = as.numeric(v3$nA0), retenus = as.numeric(v3$nA),
      rejets_flux = c(reajustement = as.numeric(v3$cpt[["rapide"]]),
                      hors_regime = as.numeric(v3$cpt[["hors"]]),
                      statistiques = as.numeric(v3$cpt[["stats"]])),
      arret = v3$arret)),
    # Plancher Monte-Carlo (#125), sur la meme matrice V3b, puis la matrice
    # V3b elle-meme (#297, bootstrap$stats_boot, dernier element).
    list(p_min_mc = mc$p_min_mc, stats_boot = v3$S))
}
for (cc in list(list(nom = "J2 observe, B = 199", x = x2, y = y2, B = 199, seed = 20260831),
                list(nom = "J3 b = 3, B = 99", x = YB$J3_3$x, y = YB$J3_3$y, B = 99, seed = 20260831 + 3))) {
  fit <- usp_ajuster(cc$x, cc$y)
  bt <- usp_bootstrap(fit, B = cc$B, seed = cc$seed)
  att <- attendu_u7(fit, cc$B, cc$seed)
  verifier(sprintf("U7 %s : identical() a la contre-implementation (p_mc, err_mc, B_effectif, granularite_stat, motif_mc, p_mc_regime, p_min_mc, stats_boot, champs de V1)",
                   cc$nom),
           {
             diff <- names(att)[!vapply(names(att), function(n) identical(bt[[n]], att[[n]]), logical(1))]
             if (length(diff)) paste("champs differents :", paste(diff, collapse = ", "))
             else identical(names(bt), names(att)) && identical(bt$granularite, 1 / (cc$B + 1))
           })
}

# =============================================================================
# U8 -- levier P1 et perimetre du flux (journal d'appels)
# =============================================================================
local({
  j <- new.env(); j$log <- list()
  noter <- function(type, delta = NA_real_) j$log[[length(j$log) + 1L]] <- list(type = type, delta = delta)
  fns <- list(
    usp_ajuster_rapide = function(...) {
      f <- try(orig("usp_ajuster_rapide")(...), silent = TRUE)
      noter("rapide", if (inherits(f, "try-error")) NA_real_ else f$delta)
      if (inherits(f, "try-error")) stop(f) else f
    },
    .stats_bootstrapables = function(...) { noter("stats"); orig(".stats_bootstrapables")(...) },
    usp_ajuster_contraint = function(...) { noter("contraint"); orig("usp_ajuster_contraint")(...) })
  B <- 99
  bt <- boot_enveloppe(fns)(f2, B = B, seed = 20260831)
  types <- vapply(j$log, `[[`, "", "type")
  deltas <- vapply(j$log, `[[`, 0, "delta")
  i_rap <- which(types == "rapide")
  rang <- seq_along(i_rap)
  flux <- i_rap[rang > B]
  suivant <- vapply(flux, function(i) if (i < length(types)) types[i + 1L] else "", "")
  int_flux <- vapply(deltas[flux], interieur, logical(1), x = x2)
  r <- bt$p_mc_regime
  n_stats_flux <- sum(types == "stats" & seq_along(types) > i_rap[B + 1L])
  verifier("U8 flux : .stats_bootstrapables() appelee juste apres usp_ajuster_rapide() si et seulement si delta** est interieur",
           length(flux) > 0L && identical(suivant == "stats", int_flux) &&
             any(int_flux) && any(!int_flux))
  verifier("U8 aucun appel de usp_ajuster_contraint() apres le rang B",
           !any(types == "contraint" & seq_along(types) > i_rap[B + 1L]) &&
             sum(types == "contraint") <= B)
  verifier("U8 appels de statistiques dans le flux = retenus - retenus_v1 + rejets_flux[[\"statistiques\"]]",
           identical(as.numeric(n_stats_flux), r$retenus - r$retenus_v1 + r$rejets_flux[["statistiques"]]) &&
             identical(as.numeric(length(i_rap)), r$tirages))
})

# =============================================================================
# U11 -- reproductibilite, generateur de l'appelant
# =============================================================================
local({
  kind0 <- RNGkind()
  suppressWarnings(RNGkind("L'Ecuyer-CMRG", "Box-Muller", "Rounding"))
  set.seed(11); avant <- .Random.seed; k_avant <- RNGkind()
  a <- usp_bootstrap(f2, B = 99, seed = 20260831)
  ok_etat <- identical(.Random.seed, avant) && identical(RNGkind(), k_avant)
  suppressWarnings(RNGkind(kind0[1], kind0[2], kind0[3]))
  b <- usp_bootstrap(f2, B = 99, seed = 20260831)
  verifier("U11 J2 observe, B = 99 : deux appels identical() (generateur de l'appelant modifie avant le premier), V3b",
           identical(a, b) && identical(a$p_mc_regime$variante, "V3b"))
  verifier("U11 .Random.seed et RNGkind() de l'appelant restaures", ok_etat)
})

# =============================================================================
# U14 -- donnees du cas premium_interieur
# =============================================================================
verifier("U14 tests/donnees/donnees_ln_interieur.csv = xi, yi de test_controles_numeriques.R",
         {
           f <- file.path(.racine, "tests", "unitaires", "test_controles_numeriques.R")
           l <- readLines(f, warn = FALSE)
           env <- new.env()
           for (v in c("xi", "yi")) {
             li <- grep(sprintf("^%s <- c\\(", v), l, value = TRUE)
             if (length(li) != 1L) stop("ligne ", v, " introuvable ou multiple")
             eval(parse(text = li), envir = env)
           }
           identical(names(ln_int), c("t", "xt", "yt")) && identical(ln_int$t, 1:8) &&
             identical(as.numeric(ln_int$xt), env$xi) && identical(ln_int$yt, env$yi)
         })

# =============================================================================
# U15 -- rejeu_p_mc_v3h() de tests/outils_tests.R (#262, revue finale de R13)
# =============================================================================
# Garde-fou de la transcription de la variante V3h lue par les scripts hors
# CI qui rejouent la boucle de usp_bootstrap() (puissance_t8.R,
# comparer_ajusteurs_bootstrap.R) : boucle V1 rejouee ici (memes tirages,
# meme reajustement, memes regles d'ecart), puis rejeu_p_mc_v3h(), compare
# par identical() a usp_bootstrap(). B = 60 : au-dessus de
# B_MIN_DEGENERESCENCE, des p_mc et des p_min_mc finies (a B = 30, toutes les
# p_mc sont NA). outils_tests.R est lu dans l'environnement dedie OE, pose
# avant U7. Non couverts ici (mutants survivants mesures
# a la revue de R13) : arret a B_max et motif MOTIF_MC_REGIME_RARE (a J2,
# B = 60 : arret a la cible apres 320 tirages) ; branche V1 par volumes
# constants (aucun jeu a volumes constants) ; rejet d'un tirage du flux a
# delta** non fini ou dont les statistiques echouent (aucun tel tirage sur
# J2) ; controles hors CI de #262. Duree mesuree : environ 4 s (13/10/2026,
# conteneur Linux, R 4.3.3, chargement de outils_tests.R compris, deplace
# avant U7 par #280).
local({
  oe <- OE
  rejouer <- function(fit, B, seed) {
    e <- .usp_contexte_mc(fit$x, fit$y, fit$z, fit$pi)
    so <- .mc_evaluer(USP_CATALOGUE_MC, e)
    bt <- engine_sous_graine(seed, {
      sim <- matrix(NA_real_, B, length(so), dimnames = list(NULL, names(so)))
      ok <- rep(FALSE, B); dl <- rep(NA_real_, B)
      for (b in seq_len(B)) {
        yb <- usp_simuler(fit)
        f <- try(usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
        if (inherits(f, "try-error")) next
        sb <- try(.stats_bootstrapables(fit$x, yb, f$z, f$pi), silent = TRUE)
        if (inherits(sb, "try-error")) next
        sim[b, ] <- sb[names(so)]; ok[b] <- TRUE; dl[b] <- f$delta
      }
      list(sim = sim, ok = ok, dl = dl)
    })
    oe$rejeu_p_mc_v3h(fit, bt$sim, bt$ok, bt$dl, so, e, B, seed)
  }
  ecarts <- function(r, u, regime) {
    ch <- c("p_mc", "err_mc", "B_effectif", "motif_mc", "p_min_mc")
    k <- c(ch[!vapply(ch, function(n) identical(r[[n]], u[[n]]), TRUE)],
           if (!identical(r$granularite, u$granularite_stat)) "granularite",
           paste0("p_mc_regime$", regime[!vapply(regime, function(n)
             identical(r$p_mc_regime[[n]], u$p_mc_regime[[n]]), TRUE)]))
    k <- k[k != "p_mc_regime$"]
    if (length(k)) paste("differents :", paste(k, collapse = ", ")) else TRUE
  }
  B <- 60; graine <- 20260831
  u2 <- usp_bootstrap(f2, B = B, seed = graine); r2 <- rejouer(f2, B, graine)
  verifier("U15 rejeu_p_mc_v3h() sur J2 (V3b), B = 60 : flux pose, des p_mc et p_min_mc finies",
           identical(u2$p_mc_regime$variante, "V3b") && u2$p_mc_regime$tirages > B &&
             any(is.finite(u2$p_mc)) && any(is.finite(u2$p_min_mc)))
  verifier("U15 rejeu_p_mc_v3h() sur J2 (V3b), B = 60 : identical() a usp_bootstrap() (p_mc, err_mc, B_effectif, granularite, motif_mc, p_min_mc, variante, retenus_v1, retenus, tirages, arret)",
           ecarts(r2, u2, c("variante", "retenus_v1", "retenus", "tirages", "arret")))
  u1 <- usp_bootstrap(f1, B = B, seed = graine); r1 <- rejouer(f1, B, graine)
  verifier("U15 rejeu_p_mc_v3h() sur J1 (V1, delta estime au bord), B = 60 : variante V1, des p_mc finies",
           identical(u1$p_mc_regime$variante, "V1") && any(is.finite(u1$p_mc)))
  verifier("U15 rejeu_p_mc_v3h() sur J1 (V1), B = 60 : identical() a usp_bootstrap() (p_mc, err_mc, B_effectif, granularite, motif_mc, p_min_mc, variante)",
           ecarts(r1, u1, "variante"))
})
fin_fichier()
