###############################################################################
#  tests/unitaires/test_p_mc_regime_partie_2.R  --  P-VALUE MONTE-CARLO
#  CONDITIONNELLE AU REGIME DE DELTA ESTIME (issue #240, ADR 0014, variante V3h),
#  seconde partie
#
#  Specification, oracle, fonctions visees : voir l'en-tete de
#  test_p_mc_regime.R, dont ce fichier est la seconde moitie.
#
#  test_p_mc_regime_partie_2.R : seconde moitie de test_p_mc_regime.R, coupe
#  en deux fichiers (issue #561, etape 4 de S8) pour raccourcir le chemin
#  critique d'un lot de la CI. Ce fichier porte U2, U5, U6, U9, U10, U12, U13
#  et U16 ; U1, U3, U4, U7, U8, U11, U14 et U15 sont dans test_p_mc_regime.R.
#  Les jeux, l'oracle et les fonctions de controle communs sont dans
#  outils_p_mc_regime.R, charge par les deux fichiers. Les sections gardent leur
#  texte, leur ordre relatif et leurs assertions ; U10, U12 et U16 lisent
#  boot_u2 de U2, U9 et U10 lisent lignes_mc de U5.
#  Duree : environ 75 s (mesure locale du 26/11/2026, quatre processus a la fois).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_p_mc_regime_partie_2.R")

.racine <- if (exists("RACINE", inherits = TRUE)) RACINE else "."
source(file.path(.racine, "tests", "unitaires", "outils_p_mc_regime.R"), local = TRUE)

# =============================================================================
# U2 -- identite avec V3b de #229, interieur, arret a la cible
# =============================================================================
cas_u2 <- list(
  list(nom = "J2 b = 0 (observe)", jeu = "J2", b = 0, x = x2, y = y2,
       tir = 4490, a = 203, rej = c(0, 2695, 0)),
  list(nom = "J2 b = 6", jeu = "J2", b = 6, x = YB$J2_6$x, y = YB$J2_6$y,
       tir = 4348, a = 233, rej = c(0, 2583, 0)),
  list(nom = "J3 b = 3", jeu = "J3", b = 3, x = YB$J3_3$x, y = YB$J3_3$y,
       tir = 2091, a = 480, rej = c(0, 573, 0)))
boot_u2 <- list()
for (cc in cas_u2) {
  fit <- usp_ajuster(cc$x, cc$y)
  o <- oracle(cc$jeu, cc$b, "V3b")
  verifier(sprintf("U2 %s : garde, delta estime = colonne delta du TSV (1e-9 relatif) et interieur", cc$nom),
           isTRUE(proche(fit$delta, o$num("delta"), rel = 1e-9)) && interieur(fit$delta, cc$x))
  bt <- usp_bootstrap(fit, B = 999, seed = 20260831 + cc$b)
  if (cc$b == 0) boot_u2$J2 <- list(fit = fit, boot = bt)
  verifier(sprintf("U2 %s : p_mc, B_effectif, motif_mc identical() a p_V3b, B_V3b, m_V3b de #229", cc$nom),
           egal_oracle(bt, o))
  verifier(sprintf("U2 %s : err_mc et granularite_stat = leur formule", cc$nom), formules_ok(bt))
  verifier(sprintf("U2 %s : p_mc_regime (tirages %d, retenus_v1 %d, retenus 999, rejets (%s), arret cible, graine %d)",
                   cc$nom, cc$tir, cc$a, paste(cc$rej, collapse = ", "), 20800000 + cc$b),
           {
             r <- bt$p_mc_regime
             identical(names(r), NOMS_REGIME) &&
               identical(r$regime_obs, "interieur") && identical(r$variante, "V3b") &&
               identical(r$motif_v1, NA_character_) &&
               identical(r$graine_flux, 20800000 + cc$b) &&
               identical(r$B_cible, 999) && identical(r$B_max, 25000) &&
               identical(r$tirages, cc$tir) && identical(r$tirages, o$num("tir_v3b")) &&
               identical(r$retenus_v1, cc$a) && identical(r$retenus_v1, o$num("a_v1")) &&
               identical(r$retenus, 999) && identical(r$retenus, o$num("ret_v3b")) &&
               identical(r$rejets_flux, c(reajustement = cc$rej[1], hors_regime = cc$rej[2],
                                          statistiques = cc$rej[3])) &&
               identical(unname(r$rejets_flux), c(o$num("ech_rapide_v3b"), o$num("hors_v3b"),
                                                  o$num("ech_stats_v3b"))) &&
               identical(r$arret, "cible")
           })
  if (cc$b == 0)
    verifier("U2 J2 b = 0 : p_mc[\"GQ\"] = 0,017999999999999999",
             identical(sprintf("%.17g", bt$p_mc[["GQ"]]), "0.017999999999999999"))
  verifier_invariants(sprintf("U2 %s", cc$nom), bt, cc$x)
}

# =============================================================================
# U5 et U6 -- B_max atteint (enveloppe de usp_ajuster_rapide() : appel k ->
# delta := 0,5 si k %% m == 0, sinon 1)
# =============================================================================
rapide_force <- function(m) {
  e <- new.env(); e$k <- 0L
  e$fn <- function(...) {
    e$k <- e$k + 1L
    f <- orig("usp_ajuster_rapide")(...)
    f$delta <- if (e$k %% m == 0L) 0.5 else 1
    f
  }
  e
}
lignes_mc <- function(tests) Filter(function(l) is.character(l$nature_p) && !is.na(l$nature_p) &&
                                      grepl("^Monte-Carlo \\(bootstrap", l$nature_p), tests)

# U5 : retenus < 50 -> motif MOTIF_MC_REGIME_RARE.
local({
  e <- rapide_force(60L)
  bt <- boot_enveloppe(list(usp_ajuster_rapide = e$fn))(f2, B = 99, seed = 20260831)
  r <- bt$p_mc_regime
  verifier("U5 p_mc_regime : tirages 2500, retenus_v1 1, retenus 41, rejets (0, 2361, 0), arret B_max",
           identical(r$tirages, 2500) && identical(r$B_max, 2500) && identical(r$retenus_v1, 1) &&
             identical(r$retenus, 41) &&
             identical(r$rejets_flux, c(reajustement = 0, hors_regime = 2361, statistiques = 0)) &&
             identical(r$arret, "B_max") && identical(e$k, 2500L))
  verifier("U5 les 31 motif_mc (LB1r retiree, #303 ; LB1 et BP2 retirees, #302) = MOTIF_MC_REGIME_RARE ; p_mc et err_mc NA",
           identical(unname(bt$motif_mc), rep(MOTIF_MC_REGIME_RARE, 31L)) &&
             all(is.na(bt$p_mc)) && all(is.na(bt$err_mc)))
  verifier("U5 MOTIF_MC_REGIME_RARE : texte exact, ASCII, hors des motifs degeneres",
           identical(MOTIF_MC_REGIME_RARE, paste(
             "regime interieur de delta estime rare : B_max = 25 (B + 1) tirages atteints",
             "avec moins de B_MIN_DEGENERESCENCE = 50 tirages retenus")) &&
             !grepl("[^ -~]", MOTIF_MC_REGIME_RARE))
  verifier_invariants("U5", bt, x2)
  tt <- usp_tests(f2, bt, 0.10, methode = "premium")
  # (i) reecrit a #181 (ADR 0003 annote le 12/10/2026, point 2) : plus de
  # repli nomme sur la p non simulee ; la ligne est un diagnostic.
  pre_rare <- paste0("Monte-Carlo indisponible : ", MOTIF_MC_REGIME_RARE,
                     ", p non simulee (loi du champ loi) non retenue.")
  diag_rare <- Filter(function(l) startsWith(l$detail, pre_rare), tt)
  verifier("U5 usp_tests() (i) : sans repli (#181), lignes a p non simulee en diagnostic INFO, p conservee, non inoperant (au moins une)",
           length(diag_rare) >= 1L &&
             all(vapply(diag_rare, function(l) identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
                                               identical(l$inoperant, FALSE) && !is.finite(l$p_exacte) &&
                                               is.finite(l$p_asymptotique) && is.na(l$p_retenue) &&
                                               is.na(l$nature_p), logical(1))) &&
             !any(vapply(tt, function(l) is.character(l$nature_p) && !is.na(l$nature_p) &&
                                         startsWith(l$nature_p, "asymptotique (Monte-Carlo"), logical(1))))
  verifier("U5 usp_tests() : aucune ligne a nature Monte-Carlo du bootstrap (p_mc toutes NA)",
           length(lignes_mc(tt)) == 0L)
  verifier("U5 usp_tests() (ii) : Nullite de la constante en diagnostic, sans p retenue",
           {
             l <- Filter(function(l) identical(l$test, "Nullite de la constante (proportionnalite stricte)"), tt)
             length(l) == 1L && identical(l[[1]]$type, "diagnostic") && is.na(l[[1]]$p_retenue) &&
               grepl(MOTIF_MC_REGIME_RARE, l[[1]]$detail, fixed = TRUE)
           })
  # Sur J2 (pi_t variable, regle R7), aucune ligne du catalogue n'a de p
  # exacte attribuee : la seule ligne a p exacte est la pente (permutation,
  # hors catalogue). Le cas d'une ligne du catalogue a p exacte sous
  # MOTIF_MC_REGIME_RARE est couvert par U12.
  verifier("U5 usp_tests() (iii) : les lignes a p exacte la gardent (au moins une)",
           {
             ex <- Filter(function(l) is.finite(l$p_exacte) && identical(l$type, "test"), tt)
             length(ex) >= 1L &&
               all(vapply(ex, function(l) grepl("^exacte", l$nature_p) &&
                                          identical(l$p_retenue, l$p_exacte), logical(1)))
           })
})

# U5 bis : B_cible < B_MIN_DEGENERESCENCE (decision du 11/10/2026, precision
# de Q-A4-9). B = 30, B_max = 25 x 31 = 775 ; l'enveloppe m = 60 rend delta**
# interieur aux appels 60, 120, ..., 720 seulement, d'ou 12 retenus < 30 :
# B_max est atteint (arret B_max, 775 appels comptes). La cause de
# l'indisponibilite est B, pas la rarete : MOTIF_MC_REPLIC_INSUFFISANTES reste.
local({
  e <- rapide_force(60L)
  bt <- boot_enveloppe(list(usp_ajuster_rapide = e$fn))(f2, B = 30, seed = 20260831)
  r <- bt$p_mc_regime
  verifier("U5 bis B = 30 : V3b, B_cible 30, B_max 775 atteint (775 appels), retenus 12 < 50",
           identical(r$variante, "V3b") && identical(r$B_cible, 30) && identical(r$B_max, 775) &&
             identical(r$tirages, 775) && identical(r$arret, "B_max") && identical(e$k, 775L) &&
             identical(r$retenus, 12))
  verifier("U5 bis B = 30 : les 31 motif_mc (LB1r retiree, #303 ; LB1 et BP2 retirees, #302) = MOTIF_MC_REPLIC_INSUFFISANTES, aucun MOTIF_MC_REGIME_RARE",
           identical(unname(bt$motif_mc), rep(MOTIF_MC_REPLIC_INSUFFISANTES, 31L)) &&
             !any(bt$motif_mc %in% MOTIF_MC_REGIME_RARE))
})

# U6 : retenus >= 50 -> pas de substitution.
local({
  e <- rapide_force(40L)
  bt <- boot_enveloppe(list(usp_ajuster_rapide = e$fn))(f2, B = 99, seed = 20260831)
  r <- bt$p_mc_regime
  verifier("U6 p_mc_regime : retenus_v1 2, retenus 62, arret B_max, tirages 2500",
           identical(r$retenus_v1, 2) && identical(r$retenus, 62) && identical(r$arret, "B_max") &&
             identical(r$tirages, 2500) &&
             identical(r$rejets_flux, c(reajustement = 0, hors_regime = 2341, statistiques = 0)))
  fin <- is.finite(unlist(bt$stats_obs))
  verifier("U6 motif_mc NA pour les statistiques finies ; aucun MOTIF_MC_REGIME_RARE",
           all(is.na(bt$motif_mc[fin])) && !any(bt$motif_mc %in% MOTIF_MC_REGIME_RARE) &&
             all(is.finite(bt$p_mc[fin])))
  verifier("U6 granularite_stat = 1/(B_eff + 1) ou 2/(B_eff + 1), B_eff <= 62",
           formules_ok(bt) && all(bt$B_effectif <= 62))
  verifier_invariants("U6", bt, x2)
  tt <- usp_tests(f2, bt, 0.10, methode = "premium")
  mc <- lignes_mc(tt)
  verifier("U6 usp_tests() : nature conditionnelle sur les lignes a p Monte-Carlo retenue (au moins une)",
           length(mc) >= 1L && all(vapply(mc, function(l) identical(l$nature_p, NATURE_V3B), logical(1))))
})

# =============================================================================
# U9 -- V1 hors du bord (refit = FALSE ; volumes constants)
# =============================================================================
local({
  cpt <- compteur_rapide()
  bt <- boot_enveloppe(list(usp_ajuster_rapide = cpt$fn))(f2, B = 99, seed = 20260831, refit = FALSE)
  tt <- usp_tests(f2, bt, 0.10, methode = "premium")
  verifier("U9 (a) J2 observe, refit = FALSE : V1, motif refit = FALSE, regime interieur, usp_ajuster_rapide() au plus B fois, nature non suffixee",
           contrat_v1(bt, "interieur", "refit = FALSE : delta** non reestime", 20260831, 99) &&
             cpt$n <= 99L && length(lignes_mc(tt)) >= 1L &&
             all(vapply(lignes_mc(tt), function(l) identical(l$nature_p, NATURE_V1), logical(1))))
})
local({
  xc <- rep(100, 8)
  fit <- usp_ajuster(xc, y1)
  pi_avant <- fit$pi
  fit$delta <- 0.5
  cpt <- compteur_rapide()
  bt <- boot_enveloppe(list(usp_ajuster_rapide = cpt$fn))(fit, B = 99, seed = 20260831)
  tt <- usp_tests(fit, bt, 0.10, methode = "premium")
  verifier("U9 (b) volumes constants, delta pose a 0,5 : V1, motif volumes constants, regime interieur, usp_ajuster_rapide() au plus B fois, nature non suffixee",
           usp_regime(0.5, xc)$volumes_constants &&
             identical(usp_pi(0.5, fit$gamma, xc, mean(xc)), pi_avant) &&
             contrat_v1(bt, "interieur", "volumes constants : regime de delta non identifie", 20260831, 99) &&
             cpt$n <= 99L &&
             all(vapply(lignes_mc(tt), function(l) identical(l$nature_p, NATURE_V1), logical(1))))
})

# U9 (c) : volumes constants avec delta estime au bord (usp_ajuster() rend
# delta = 0 sur rep(100, 8)). Le motif volumes constants prime sur le bord
# (decision du 11/10/2026) ; regime_obs decrit delta estime : bord0.
local({
  xc <- rep(100, 8)
  fit <- usp_ajuster(xc, y1)
  bt <- usp_bootstrap(fit, B = 99, seed = 20260831)
  verifier("U9 (c) volumes constants, delta estime au bord 0 par usp_ajuster() : V1, motif volumes constants, regime bord0",
           identical(fit$delta, 0) && usp_regime(fit$delta, xc)$delta_au_bord &&
             usp_regime(fit$delta, xc)$volumes_constants &&
             contrat_v1(bt, "bord0", "volumes constants : regime de delta non identifie", 20260831, 99))
})

# =============================================================================
# U10 -- nature
# =============================================================================
local({
  tt2 <- usp_tests(boot_u2$J2$fit, boot_u2$J2$boot, 0.10, methode = "premium")
  mc2 <- Filter(function(l) !is.na(l$nature_p) && grepl("^Monte-Carlo", l$nature_p) &&
                              !grepl("permutations", l$nature_p), tt2)
  verifier("U10 J2 (V3b) : toute ligne a nature Monte-Carlo du bootstrap vaut exactement le texte du par. 4.2 (au moins une)",
           identical(NATURE_MC_REGIME_INTERIEUR, NATURE_V3B) && length(mc2) >= 1L &&
             all(vapply(mc2, function(l) identical(l$nature_p, NATURE_V3B), logical(1))))
  b1 <- usp_bootstrap(f1, B = 99, seed = 20260831)
  tt1 <- usp_tests(f1, b1, 0.10, methode = "premium")
  verifier("U10 J1 (V1) : nature Monte-Carlo non suffixee (au moins une)",
           length(lignes_mc(tt1)) >= 1L &&
             all(vapply(lignes_mc(tt1), function(l) identical(l$nature_p, NATURE_V1), logical(1))))
  bs <- boot_u2$J2$boot; bs$p_mc_regime <- NULL
  tts <- usp_tests(boot_u2$J2$fit, bs, 0.10, methode = "premium")
  verifier("U10 J2, liste bootstrap sans p_mc_regime : nature non suffixee (retrocompatibilite)",
           length(lignes_mc(tts)) >= 1L &&
             all(vapply(lignes_mc(tts), function(l) identical(l$nature_p, NATURE_V1), logical(1))))
})

# =============================================================================
# U12 -- classement d'add() (motif non degenere ; diagnostic sans repli
# depuis #181)
# =============================================================================
local({
  bt <- boot_u2$J2$boot
  bt$p_mc[["GQ"]] <- NA_real_; bt$err_mc[["GQ"]] <- NA_real_
  bt$motif_mc[["GQ"]] <- MOTIF_MC_REGIME_RARE
  ligne <- function(...) {
    reg <- engine_registre_tests(bt, USP_CATALOGUE_MC, 0.10, nature_mc = NATURE_V3B)
    reg$add("B. test", "ligne GQ", "ref", mc_nom = "GQ", fonction = "usp_tests", ...)
    reg$lignes()[[1]]
  }
  l1 <- ligne(p_as = 0.2)
  l2 <- ligne(p_as = 0.2, libelle_p_as = "p de Student sous le modele auxiliaire pondere")
  l3 <- ligne(p_ex = 0.3, p_as = 0.2)
  verifier("U12 p non simulee fournie : diagnostic sans repli (#181), p conservee non retenue",
           identical(l1$type, "diagnostic") && identical(l1$verdict, "INFO") && is.na(l1$p_retenue) &&
             is.na(l1$nature_p) && identical(l1$p_asymptotique, 0.2) && identical(l1$inoperant, FALSE) &&
             startsWith(l1$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_REGIME_RARE,
                                          ", p non simulee (loi du champ loi) non retenue.")))
  verifier("U12 diagnostic au libelle de l'appelant (constante)",
           identical(l2$type, "diagnostic") && is.na(l2$p_retenue) &&
             startsWith(l2$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_REGIME_RARE,
                                          ", p de Student sous le modele auxiliaire pondere non retenue")))
  verifier("U12 p exacte retenue si fournie",
           identical(l3$type, "test") && identical(l3$p_retenue, 0.3) && identical(l3$nature_p, "exacte"))
  # Liste unique des motifs degeneres, MOTIFS_MC_DEGENERES, lue par add()
  # depuis #358 (avant : copie locale motifs_degeneres d'add()).
  verifier("U12 MOTIF_MC_REGIME_RARE hors des motifs degeneres d'add() (MOTIFS_MC_DEGENERES)",
           {
             src <- paste(deparse(engine_registre_tests), collapse = "\n")
             grepl("MOTIFS_MC_DEGENERES", src, fixed = TRUE) &&
               !grepl("MOTIF_MC_REGIME_RARE", src, fixed = TRUE) &&
               !MOTIF_MC_REGIME_RARE %in% MOTIFS_MC_DEGENERES
           })
})

# =============================================================================
# U13 -- metadata
# =============================================================================
local({
  r1 <- run_engine(xt = x1, yt = y1, methode = "premium", segment = 1, annexe = "II",
                   nature_donnees = "brutes", B = 99, seed = 20260831, date_reference = DATE_REFERENCE_TESTS)
  nm <- names(r1$metadata)
  # Depuis #504 (ADR 0019, point 5), les quatre champs de la date de
  # reference du calcul suivent seed_flux_regime, avant horodatage.
  verifier("U13 run_engine() premium (J1) : metadata$seed_flux_regime = 20800000, juste apres permutation_pente, suivi des quatre champs de #504 puis de horodatage",
           isTRUE(r1$ok) && identical(r1$metadata$seed_flux_regime, 20800000) &&
             identical(match("seed_flux_regime", nm), match("permutation_pente", nm) + 1L) &&
             identical(match("date_reference", nm), match("seed_flux_regime", nm) + 1L) &&
             identical(match("horodatage", nm), match("seed_flux_regime", nm) + 5L) &&
             identical(r1$metadata$seed_flux_regime, r1$bootstrap$p_mc_regime$graine_flux))
  df <- utils::read.csv(file.path(.racine, "tests", "donnees", "triangle_mw.csv"))
  tri <- as.matrix(df[, setdiff(names(df), "i")]); storage.mode(tri) <- "double"; tri <- unname(tri)
  r2 <- run_engine(methode = "reserve2", triangle = tri, segment = 1, annexe = "II", B = 99, seed = 20260831,
                   date_reference = DATE_REFERENCE_TESTS)
  verifier("U13 run_engine() reserve2 : seed_flux_regime absent de metadata, p_mc_regime absent du bootstrap",
           isTRUE(r2$ok) && !("seed_flux_regime" %in% names(r2$metadata)) &&
             is.null(r2$bootstrap$p_mc_regime))
})

# =============================================================================
# U16 -- progression du flux complementaire (issue #255, decision Q-72-2 (a))
# =============================================================================
# Sous progres = TRUE, usp_bootstrap() imprime une ligne de points pour les B
# tirages de V1 (un tous les 100) puis, si le flux a tire au moins 1 000 fois,
# une ligne d'un point tous les 1 000 tirages du flux. cat() ne consomme aucun
# alea : la sortie est identical() a celle de progres = FALSE. Cas de la
# reference premium_interieur (J2 observe, B = 999, seed 20260831, sortie
# boot_u2$J2 a progres = FALSE) ; cas court B = 60 (flux de moins de 1 000
# tirages : aucune ligne du flux).
local({
  sortie <- utils::capture.output(
    bt <- usp_bootstrap(f2, B = 999, seed = 20260831, progres = TRUE))
  b0 <- boot_u2$J2$boot
  flux <- b0$p_mc_regime$tirages - 999
  verifier("U16 J2 observe, B = 999 (premium_interieur) : V3b, flux d'au moins 1 000 tirages",
           identical(b0$p_mc_regime$variante, "V3b") && flux >= 1000)
  verifier("U16 J2 observe, B = 999 : usp_bootstrap() identical() a progres = TRUE et FALSE",
           identical(bt, b0))
  verifier(sprintf("U16 J2 observe, B = 999 : sortie = 9 points (V1) puis floor(%d / 1000) points (flux)", flux),
           identical(sortie, c(strrep(".", 9L), strrep(".", floor(flux / 1000)))))
  sortie60 <- utils::capture.output(
    bt60 <- usp_bootstrap(f2, B = 60, seed = 20260831, progres = TRUE))
  b60 <- usp_bootstrap(f2, B = 60, seed = 20260831)
  verifier("U16 J2 observe, B = 60 : V3b, flux de 1 a 999 tirages, identical() a progres = TRUE et FALSE, aucune ligne du flux",
           identical(b60$p_mc_regime$variante, "V3b") &&
             b60$p_mc_regime$tirages - 60 >= 1 && b60$p_mc_regime$tirages - 60 < 1000 &&
             identical(bt60, b60) && identical(sortie60, ""))
})
fin_fichier()
