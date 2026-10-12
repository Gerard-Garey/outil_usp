###############################################################################
#  tests/unitaires/test_p_mc_regime.R  --  P-VALUE MONTE-CARLO CONDITIONNELLE
#  AU REGIME DE DELTA ESTIME (issue #240, ADR 0014, variante V3h)
#
#  Specification : docs/specifications/240-p-mc-conditionnelle-regime.md,
#  par. 7 (tests U1 a U14), approuvee au point d'arret C1 le 11/10/2026.
#  Fonctions visees : usp_graine_flux_regime(), usp_bootstrap() (variante V1
#  au bord, V3b a delta estime interieur, champ p_mc_regime), usp_tests()
#  (nature), run_engine() (metadata$seed_flux_regime).
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
#  Duree : environ trois minutes (U3 seul, 25 000 tirages, environ 40 s ;
#  decision Q-240-3 : tout dans la batterie).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_p_mc_regime.R")

.racine <- if (exists("RACINE", inherits = TRUE)) RACINE else "."
M <- .Machine$integer.max
D <- DECALAGE_GRAINE_FLUX_REGIME
NOMS <- names(USP_CATALOGUE_MC)
NATURE_V1 <- "Monte-Carlo (bootstrap parametrique)"
NATURE_V3B <- "Monte-Carlo (bootstrap parametrique, conditionnel au regime interieur de delta estime)"

# --- Jeux --------------------------------------------------------------------
ln <- utils::read.csv(file.path(.racine, "tests", "donnees", "donnees_ln.csv"))
ln_int <- utils::read.csv(file.path(.racine, "tests", "donnees", "donnees_ln_interieur.csv"))
x1 <- ln$xt; y1 <- ln$yt                     # J1 (delta estime au bord 1)
x2 <- ln_int$xt; y2 <- ln_int$yt             # J2 (delta estime interieur)
X3 <- c(10, 10.5, 95, 92, 11, 11.5, 98, 90)  # J3 (volumes de #229)
f1 <- usp_ajuster(x1, y1)
f2 <- usp_ajuster(x2, y2)

# Replications de #229 (voir l'en-tete).
YB <- list(
  J1_1455 = list(x = x1, b = 1455, y = c(80.061271676886193, 62.506419725192131, 75.947508440386684,
    73.078214305038301, 81.70127631154007, 88.287475207907406, 89.71478845147162, 107.19756511252216)),
  J2_4 = list(x = x2, b = 4, y = c(44.9952816617376, 68.671824247331728, 88.434948551293857,
    129.02904874526519, 217.52838760815064, 111.50971443959662, 63.765564834860868, 36.45958959698352)),
  J2_6 = list(x = x2, b = 6, y = c(37.007405538728321, 46.640215036944987, 87.817339087519045,
    123.64394930630607, 215.61735430446251, 101.69214043039975, 62.388574576083919, 39.106043696171419)),
  J3_1 = list(x = X3, b = 1, y = c(6.6898385700639604, 6.1195114028360624, 59.04195616451873,
    77.549344341516218, 6.8878468875173695, 8.0294716707321783, 56.679976751298213, 55.161793338530977)),
  J3_3 = list(x = X3, b = 3, y = c(8.2013717927157597, 9.4758151928087724, 63.375443265627297,
    56.511679325477516, 5.8558446197601635, 6.7317908127359969, 77.283439894193251, 64.90282965077138)))

# --- Oracle : valeurs brutes de #229 -----------------------------------------
TSV <- utils::read.delim(file.path(.racine, "docs", "tableaux",
                                   "20261010-issue229-p-conditionnelle-regime-brut.tsv"),
                         colClasses = "character", check.names = FALSE)
ligne_tsv <- function(jeu, b) {
  r <- TSV[TSV$jeu == jeu & TSV$b == as.character(b), , drop = FALSE]
  if (nrow(r) != 1L) stop("TSV de #229 : ligne ", jeu, " b = ", b, " introuvable ou multiple")
  r
}
oracle <- function(jeu, b, v) {
  r <- ligne_tsv(jeu, b)
  m <- unname(unlist(r[paste0("m_", v, ":", NOMS)]))
  list(p = stats::setNames(as.numeric(unlist(r[paste0("p_", v, ":", NOMS)])), NOMS),
       B = stats::setNames(as.numeric(unlist(r[paste0("B_", v, ":", NOMS)])), NOMS),
       m = stats::setNames(ifelse(m == "-", NA_character_, paste0("code #229 : ", m)), NOMS),
       num = function(col) as.numeric(r[[col]]))
}
cle <- function(k) strsplit(k, "_")[[1]][1]

# Comparaison exacte d'un bootstrap a l'oracle ; rend TRUE ou un message qui
# nomme la statistique en cause (premier ecart).
egal_oracle <- function(bt, o) {
  for (s in NOMS) {
    if (!identical(unname(bt$p_mc[[s]]), unname(o$p[[s]])))
      return(sprintf("p_mc[%s] : obtenu %.17g, oracle %.17g", s, bt$p_mc[[s]], o$p[[s]]))
    if (!identical(unname(bt$B_effectif[[s]]), unname(o$B[[s]])))
      return(sprintf("B_effectif[%s] : obtenu %.17g, oracle %.17g", s, bt$B_effectif[[s]], o$B[[s]]))
    if (!identical(unname(bt$motif_mc[[s]]), unname(o$m[[s]])))
      return(sprintf("motif_mc[%s] : obtenu %s, oracle %s", s, bt$motif_mc[[s]], o$m[[s]]))
  }
  identical(names(bt$p_mc), NOMS) && identical(names(bt$B_effectif), NOMS) &&
    identical(names(bt$motif_mc), NOMS)
}

# err_mc et granularite_stat recalcules par leur formule (engine_p_mc()).
k_queue <- ifelse(vapply(USP_CATALOGUE_MC, `[[`, "", "queue") == "deux", 2, 1)
formules_ok <- function(bt) {
  p <- bt$p_mc; Be <- bt$B_effectif
  e <- sqrt(p * (k_queue - p) / pmax(Be, 1))
  g <- ifelse(Be > 0, k_queue / (Be + 1), NA_real_)
  identical(unname(bt$err_mc), unname(e)) && identical(unname(bt$granularite_stat), unname(g))
}

# Invariants I1 a I7 sous V3b (specification, par. 3.2).
interieur <- function(d, x) is.finite(d) && !usp_regime(d, x)$delta_au_bord
invariants_ok <- function(bt, x) {
  r <- bt$p_mc_regime; B <- bt$B
  i6 <- sum(vapply(bt$delta_boot, interieur, logical(1), x = x))
  c(I1 = r$tirages - B == sum(r$rejets_flux) + r$retenus - r$retenus_v1,
    I2 = r$retenus <= r$B_cible && r$tirages <= r$B_max,
    I3 = (r$arret == "cible") == (r$retenus == r$B_cible),
    I4 = r$arret != "B_max" || r$tirages == r$B_max,
    I5 = all(bt$B_effectif <= r$retenus),
    I6 = r$retenus_v1 == i6,
    I7 = r$retenus_v1 != r$B_cible || r$tirages == B)
}
verifier_invariants <- function(nom, bt, x) {
  inv <- invariants_ok(bt, x)
  verifier(paste(nom, ": invariants I1 a I7"),
           if (all(inv)) TRUE else paste("invariants faux :", paste(names(inv)[!inv], collapse = ", ")))
}

# Contrat de p_mc_regime (onze elements, ordre, types).
NOMS_REGIME <- c("regime_obs", "variante", "motif_v1", "graine_flux", "B_cible", "B_max",
                 "tirages", "retenus_v1", "retenus", "rejets_flux", "arret")
contrat_v1 <- function(bt, regime_obs, motif_v1, seed, B) {
  identical(bt$p_mc_regime, list(
    regime_obs = regime_obs, variante = "V1", motif_v1 = motif_v1,
    graine_flux = usp_graine_flux_regime(seed), B_cible = NA_real_, B_max = NA_real_,
    tirages = as.numeric(B), retenus_v1 = NA_real_, retenus = NA_real_,
    rejets_flux = c(reajustement = NA_real_, hors_regime = NA_real_, statistiques = NA_real_),
    arret = NA_character_))
}

# Copie locale de usp_bootstrap() dont l'environnement masque des fonctions
# du moteur (enveloppes de comptage) ; le moteur n'est pas modifie.
env_moteur <- environment(usp_bootstrap)
orig <- function(nom) get(nom, envir = env_moteur)
boot_enveloppe <- function(fns) {
  env <- new.env(parent = env_moteur)
  for (nm in names(fns)) assign(nm, fns[[nm]], envir = env)
  f <- usp_bootstrap; environment(f) <- env
  f
}
# Compteur d'appels de usp_ajuster_rapide().
compteur_rapide <- function() {
  e <- new.env(); e$n <- 0L
  e$fn <- function(...) { e$n <- e$n + 1L; orig("usp_ajuster_rapide")(...) }
  e
}

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
  verifier("U5 les 34 motif_mc = MOTIF_MC_REGIME_RARE ; p_mc et err_mc NA",
           identical(unname(bt$motif_mc), rep(MOTIF_MC_REGIME_RARE, 34L)) &&
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
                     " ; p non simulee (loi du champ loi) non retenue (ADR 0001).")
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
  verifier("U5 bis B = 30 : les 34 motif_mc = MOTIF_MC_REPLIC_INSUFFISANTES, aucun MOTIF_MC_REGIME_RARE",
           identical(unname(bt$motif_mc), rep(MOTIF_MC_REPLIC_INSUFFISANTES, 34L)) &&
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
# U7 -- B != 999, contre-implementation (copie declaree de rejouer_v1(complet
# = TRUE) et de completer_v3b() de tests/p_conditionnelle_regime_t8.R,
# l. 1776-1832, parametrees par B : B_cible = B, B_max = 25 (B + 1), graine
# usp_graine_flux_regime(seed))
# =============================================================================
code_regime <- function(delta) if (delta >= 1 - TOL_DELTA_BORD) "bord1" else
  if (delta <= TOL_DELTA_BORD) "bord0" else "interieur"
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
      if (inherits(f, "try-error")) { cpt[["rapide"]] <- cpt[["rapide"]] + 1L; next }
      if (code_regime(f$delta) != r_b) { cpt[["hors"]] <- cpt[["hors"]] + 1L; next }
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
  r_b <- code_regime(fit$delta)
  rv <- rejouer_v1_u7(fit, seed, B)
  rd <- vapply(rv$delta, function(d) if (is.finite(d)) code_regime(d) else NA_character_, "")
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
      arret = v3$arret)))
}
for (cc in list(list(nom = "J2 observe, B = 199", x = x2, y = y2, B = 199, seed = 20260831),
                list(nom = "J3 b = 3, B = 99", x = YB$J3_3$x, y = YB$J3_3$y, B = 99, seed = 20260831 + 3))) {
  fit <- usp_ajuster(cc$x, cc$y)
  bt <- usp_bootstrap(fit, B = cc$B, seed = cc$seed)
  att <- attendu_u7(fit, cc$B, cc$seed)
  verifier(sprintf("U7 %s : identical() a la contre-implementation (p_mc, err_mc, B_effectif, granularite_stat, motif_mc, p_mc_regime, champs de V1)",
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
                                          " ; p non simulee (loi du champ loi) non retenue (ADR 0001).")))
  verifier("U12 diagnostic au libelle de l'appelant (constante)",
           identical(l2$type, "diagnostic") && is.na(l2$p_retenue) &&
             startsWith(l2$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_REGIME_RARE,
                                          " ; p de Student sous le modele auxiliaire pondere non retenue")))
  verifier("U12 p exacte retenue si fournie",
           identical(l3$type, "test") && identical(l3$p_retenue, 0.3) && identical(l3$nature_p, "exacte"))
  verifier("U12 MOTIF_MC_REGIME_RARE hors des motifs degeneres d'add() (texte de engine_registre_tests())",
           {
             src <- paste(deparse(engine_registre_tests), collapse = "\n")
             grepl("motifs_degeneres <- c(MOTIF_MC_DISPERSION_NULLE, MOTIF_MC_ATOME_HORS_OBS,", src, fixed = TRUE) &&
               !grepl("MOTIF_MC_REGIME_RARE", src, fixed = TRUE)
           })
})

# =============================================================================
# U13 -- metadata
# =============================================================================
local({
  r1 <- run_engine(xt = x1, yt = y1, methode = "premium", segment = 1, annexe = "II",
                   nature_donnees = "brutes", B = 99, seed = 20260831)
  nm <- names(r1$metadata)
  verifier("U13 run_engine() premium (J1) : metadata$seed_flux_regime = 20800000, juste apres permutation_pente, avant horodatage",
           isTRUE(r1$ok) && identical(r1$metadata$seed_flux_regime, 20800000) &&
             identical(match("seed_flux_regime", nm), match("permutation_pente", nm) + 1L) &&
             identical(match("horodatage", nm), match("seed_flux_regime", nm) + 1L) &&
             identical(r1$metadata$seed_flux_regime, r1$bootstrap$p_mc_regime$graine_flux))
  df <- utils::read.csv(file.path(.racine, "tests", "donnees", "triangle_mw.csv"))
  tri <- as.matrix(df[, setdiff(names(df), "i")]); storage.mode(tri) <- "double"; tri <- unname(tri)
  r2 <- run_engine(methode = "reserve2", triangle = tri, segment = 1, annexe = "II", B = 99, seed = 20260831)
  verifier("U13 run_engine() reserve2 : seed_flux_regime absent de metadata, p_mc_regime absent du bootstrap",
           isTRUE(r2$ok) && !("seed_flux_regime" %in% names(r2$metadata)) &&
             is.null(r2$bootstrap$p_mc_regime))
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

fin_fichier()
