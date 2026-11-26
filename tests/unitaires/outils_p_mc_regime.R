###############################################################################
#  tests/unitaires/outils_p_mc_regime.R  --  AIDES COMMUNES DE
#  test_p_mc_regime.R ET test_p_mc_regime_partie_2.R (issue #561)
#
#  Fichier d'aides, pas un test : le lanceur ne retient que les fichiers
#  test_*.R. Charge par source(..., local = TRUE) au debut de chacun des deux
#  fichiers, apres debut_fichier() et la definition de .racine : jeux (J1, J2,
#  J3), oracle de #229, fonctions de comparaison et de controle des invariants,
#  enveloppes de comptage de usp_bootstrap(). Texte repris sans changement de
#  test_p_mc_regime.R d'avant la coupe (commit parent), hors .racine, defini par
#  chaque fichier.
###############################################################################

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
