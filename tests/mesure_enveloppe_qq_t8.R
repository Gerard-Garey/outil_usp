###############################################################################
#  tests/mesure_enveloppe_qq_t8.R  --  BANDE SIMULTANEE DE L'ENVELOPPE DU
#  QQ-PLOT : RANG k*, TAUX AUTO-EVALUE ET TAUX HORS ECHANTILLON SELON LA
#  REGLE DE RANG, SUR J1 (issue #385)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils et tools, livres avec R). Il ne modifie ni
#  R/engine.R ni tests/reference/ et n'ecrit aucun fichier : sortie en
#  markdown sur la console. Aucune graine nouvelle dans le moteur : les
#  tirages sont ceux de usp_bootstrap() aux graines declarees ci-dessous.
#
#  Plan (criteres d'acceptation de #385, commentaire du 28/10/2026 ; meme
#  protocole que la table de mesures de engine_enveloppe_qq() avant #385) :
#  J1 = tests/donnees/donnees_ln.csv, fit = usp_ajuster(x, y) ; pour chaque
#  taille B de B_PLAN et chaque graine g de GRAINES :
#    z_boot = usp_bootstrap(fit, B, seed = g)$z_boot (residus reajustes,
#    refit = TRUE, ceux de run_engine()) ; S = statistiques d'ordre des
#    lignes entierement finies (B_eff lignes), comme engine_enveloppe_qq() ;
#    deux regles de rang pour la bande simultanee [Sc[k, ], Sc[B_eff + 1 - k, ]]
#    (Sc = S triee par colonne), taux maximal ENVELOPPE_QQ_TAUX_MAX :
#      - "ancienne" (moteur jusqu'a #385, reproduite ici par
#        k_ancienne_regle()) : une ligne sort si une valeur est
#        STRICTEMENT hors de la bande ;
#      - "DH1997_4.17" (moteur depuis #385) : engine_rang_simultane_dh(S),
#        fonction du moteur, appelee sans le seuil ENVELOPPE_QQ_B_MIN_SIM
#        (le moteur ne forme la bande qu'a B_eff >= 500 : sous ce seuil, la
#        mesure decrit la regle, pas une sortie du moteur).
#    Taux auto-evalue : taux de la regle au rang k*, sur les lignes de S qui
#    construisent la bande. Taux hors echantillon : proportion des lignes de
#    S_ind (statistiques d'ordre d'un bootstrap independant,
#    usp_bootstrap(fit, B_IND, seed = GRAINE_IND)) ayant au moins une valeur
#    strictement hors de la bande (courbe nouvelle ; un ex aequo exact avec
#    une borne y est de probabilite nulle). k* NA : bande non formee, taux NA.
#  Controles d'integrite (un echec : code de sortie 1) :
#    (c1) md5 de R/engine.R identique au debut et a la fin ;
#    (c2) sur bootstrap$z_boot de tests/reference/premium.rds : regle
#         ancienne k* = 8, regle (4.17) k* = 7 (valeurs du moteur avant et
#         apres #385, mesure du 28/10/2026) ; et la reference est
#         reproduite par la regle qu'elle porte : sans champ regle_rang
#         (reference anterieure a #385), k et bornes simultanees de la
#         regle ancienne ; avec regle_rang = "DH1997_4.17", ceux de
#         engine_enveloppe_qq() ;
#    (c3) a B_eff >= ENVELOPPE_QQ_B_MIN_SIM : k et bornes simultanees de
#         engine_enveloppe_qq() identical() a ceux de
#         engine_rang_simultane_dh(S).
#  Constat restitue sans controle : nombre de couples (B, graine) ou
#  k*_ancienne = k*_(4.17) + 1 et ou les taux auto-evalues sont egaux
#  (equivalence attendue sans ex aequo dans S, avis d'actuary du
#  28/10/2026), et nombre de colonnes de S avec ex aequo.
#
#  Statut des valeurs : COMPORTEMENT OBSERVE PAR SIMULATION dans le monde du
#  bootstrap (modele ajuste a J1), sur un seul jeu de donnees, pas un
#  resultat general ; la couverture a T = 8 sous le vrai modele n'est pas
#  mesuree ici.
#
#  Usage (depuis la racine du depot ; LC_ALL=C.UTF-8 sous Linux, #113) :
#      Rscript tests/mesure_enveloppe_qq_t8.R [--essai]
#  --essai : plan reduit (graines 1001 et 1002, B = 100 et 500, bootstrap
#    independant de B = 1 000), NON versionnable ; verifie le script en
#    quelques secondes.
#  Plan complet : graines 1001 a 1008, B = 100, 200, 300, 400, 500, 1 000,
#    bootstrap independant de B = 8 000 (graine 424242) ; environ deux
#    minutes.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/mesure_enveloppe_qq_t8.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113) --------------------------------
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
for (a in ARGS) if (!a %in% "--essai") stop("option inconnue : ", a)
ESSAI <- "--essai" %in% ARGS

# --- Outils partages et moteur -------------------------------------------------
# tests/outils_tests.R dans un environnement dedie : RACINE,
# chemin_reference(), commit_depot() et le moteur qu'il charge
# (charger_moteur(), ADR 0016).
OT <- new.env()
sys.source(file.path(if (file.exists("tests/outils_tests.R")) "tests" else
                     if (file.exists("outils_tests.R")) "." else
                     stop("lancer depuis la racine du depot"), "outils_tests.R"), envir = OT)
RACINE <- OT$RACINE
FICHIER_MOTEUR <- file.path(RACINE, "R", "engine.R")
MD5_DEBUT <- unname(tools::md5sum(FICHIER_MOTEUR))
COMMIT <- OT$commit_depot(SCRIPT)

# --- Plan ----------------------------------------------------------------------
GRAINES <- if (ESSAI) 1001:1002 else 1001:1008
B_PLAN <- if (ESSAI) c(100L, 500L) else c(100L, 200L, 300L, 400L, 500L, 1000L)
B_IND <- if (ESSAI) 1000L else 8000L
GRAINE_IND <- 424242L
TAUX_MAX <- OT$ENVELOPPE_QQ_TAUX_MAX

# --- Regles de rang ------------------------------------------------------------
ordres <- function(zb) t(apply(zb[apply(is.finite(zb), 1L, all), , drop = FALSE], 1L, sort))
# Regle du moteur avant #385 (engine_enveloppe_qq() a 8a564e9), reproduite :
# sortie STRICTE de la bande construite sur toutes les lignes.
k_ancienne_regle <- function(S) {
  B <- nrow(S); Sc <- apply(S, 2L, sort)
  hors <- function(bas, haut) mean(rowSums(S < rep(bas, each = B) | S > rep(haut, each = B)) > 0)
  r <- list(k = NA_integer_, taux = NA_real_, sim_bas = rep(NA_real_, ncol(S)),
            sim_haut = rep(NA_real_, ncol(S)))
  for (k in seq_len(B %/% 2L)) {
    tk <- hors(Sc[k, ], Sc[B + 1L - k, ])
    if (tk > TAUX_MAX) break
    r$k <- k; r$taux <- tk; r$sim_bas <- Sc[k, ]; r$sim_haut <- Sc[B + 1L - k, ]
  }
  r
}
taux_hors_echantillon <- function(S_ind, r) {
  if (is.na(r$k)) return(NA_real_)
  n <- nrow(S_ind)
  mean(rowSums(S_ind < rep(r$sim_bas, each = n) | S_ind > rep(r$sim_haut, each = n)) > 0)
}

# --- Jeu J1 et bootstrap independant --------------------------------------------
j1 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
fit <- OT$usp_ajuster(j1$xt, j1$yt)
S_ind <- ordres(OT$usp_bootstrap(fit, B = B_IND, seed = GRAINE_IND)$z_boot)

# --- Controle (c2) sur la reference premium -------------------------------------
controles <- character(0)
ref <- readRDS(OT$chemin_reference("premium"))
S_ref <- ordres(ref$bootstrap$z_boot)
r_anc_ref <- k_ancienne_regle(S_ref)
e_ref <- OT$engine_enveloppe_qq(ref$bootstrap$z_boot, ncol(ref$bootstrap$z_boot))
o_ref <- order(order(ref$plots_data$qqnorm$theorique))
porte <- ref$plots_data$qq_enveloppe$regle_rang
if (is.null(porte)) {
  rep_ok <- identical(r_anc_ref$k, ref$plots_data$qq_enveloppe$k) &&
    identical(r_anc_ref$sim_bas[o_ref], ref$plots_data$qqnorm$env_sim_bas) &&
    identical(r_anc_ref$sim_haut[o_ref], ref$plots_data$qqnorm$env_sim_haut)
  regle_ref <- "ancienne (référence sans regle_rang)"
} else {
  rep_ok <- identical(porte, "DH1997_4.17") &&
    identical(e_ref$info$k, ref$plots_data$qq_enveloppe$k) &&
    identical(unname(e_ref$bandes[o_ref, "sim_bas"]), ref$plots_data$qqnorm$env_sim_bas) &&
    identical(unname(e_ref$bandes[o_ref, "sim_haut"]), ref$plots_data$qqnorm$env_sim_haut)
  regle_ref <- paste0("regle_rang = ", porte)
}
c2 <- identical(r_anc_ref$k, 8L) && identical(e_ref$info$k, 7L) && rep_ok
controles["c2"] <- sprintf("(c2) référence premium : ancienne k* = %s, (4.17) k* = %s, reproduite par la règle %s : %s",
                           r_anc_ref$k, e_ref$info$k, regle_ref, if (c2) "OK" else "ECHEC")

# --- Mesure --------------------------------------------------------------------
lignes <- list(); c3 <- TRUE; n_ea <- 0L
for (B in B_PLAN) for (g in GRAINES) {
  zb <- OT$usp_bootstrap(fit, B = B, seed = g)$z_boot
  S <- ordres(zb)
  n_ea <- n_ea + sum(apply(S, 2L, anyDuplicated) > 0L)
  ra <- k_ancienne_regle(S)
  rn <- OT$engine_rang_simultane_dh(S)
  if (nrow(S) >= OT$ENVELOPPE_QQ_B_MIN_SIM) {
    e <- OT$engine_enveloppe_qq(zb, ncol(zb))
    c3 <- c3 && identical(e$info$k, rn$k) &&
      identical(unname(e$bandes[, "sim_bas"]), if (is.na(rn$k)) rep(NA_real_, ncol(S)) else rn$sim_bas) &&
      identical(unname(e$bandes[, "sim_haut"]), if (is.na(rn$k)) rep(NA_real_, ncol(S)) else rn$sim_haut)
  }
  lignes[[length(lignes) + 1L]] <- data.frame(
    B = B, graine = g, B_eff = nrow(S),
    k_anc = ra$k, auto_anc = ra$taux, hors_anc = taux_hors_echantillon(S_ind, ra),
    k_dh = rn$k, auto_dh = rn$taux, hors_dh = taux_hors_echantillon(S_ind, rn))
}
D <- do.call(rbind, lignes)
controles["c3"] <- sprintf("(c3) B_eff >= %d : engine_enveloppe_qq() = engine_rang_simultane_dh(S) : %s",
                           OT$ENVELOPPE_QQ_B_MIN_SIM, if (c3) "OK" else "ECHEC")
MD5_FIN <- unname(tools::md5sum(FICHIER_MOTEUR))
c1 <- identical(MD5_DEBUT, MD5_FIN)
controles["c1"] <- sprintf("(c1) md5 de R/engine.R début = fin (%s) : %s", MD5_DEBUT, if (c1) "OK" else "ECHEC")

# --- Sortie --------------------------------------------------------------------
pc <- function(v) ifelse(is.na(v), "NA", formatC(100 * v, format = "f", digits = 1, decimal.mark = ","))
plage <- function(v) {
  v <- v[!is.na(v)]
  if (!length(v)) return("NA")
  if (min(v) == max(v)) pc(min(v)) else paste(pc(min(v)), "à", pc(max(v)))
}
plage_k <- function(k) {
  if (all(is.na(k))) return("NA")
  s <- k[!is.na(k)]; t <- if (min(s) == max(s)) as.character(min(s)) else paste0(min(s), "-", max(s))
  if (anyNA(k)) paste0(t, " (NA x ", sum(is.na(k)), ")") else t
}
moy <- function(v) if (all(is.na(v))) "NA" else paste0(pc(mean(v, na.rm = TRUE)), if (anyNA(v)) "*" else "")
cat("# Enveloppe du QQ-plot : règle de rang de la bande simultanée (#385)\n\n")
if (ESSAI) cat("**ESSAI (--essai) : plan réduit, NON versionnable.**\n\n")
cat(sprintf("- Commit : %s\n- R : %s\n- Jeu : J1 (tests/donnees/donnees_ln.csv), T = %d\n",
            COMMIT, R.version.string, nrow(j1)))
cat(sprintf("- Graines : %s ; bootstrap indépendant B = %d, graine %d (B_eff = %d)\n",
            paste(range(GRAINES), collapse = " à "), B_IND, GRAINE_IND, nrow(S_ind)))
cat(sprintf("- Taux en %% ; plages min à max sur les graines ; moyenne entre parenthèses (* : moyenne sur les k* non NA)\n\n"))
cat("| B | B_eff | k* ancienne | taux auto ancienne | hors échantillon ancienne | k* (4.17) | taux auto (4.17) | hors échantillon (4.17) |\n")
cat("|---|---|---|---|---|---|---|---|\n")
for (B in B_PLAN) {
  d <- D[D$B == B, ]
  cat(sprintf("| %d | %s | %s | %s | %s (%s) | %s | %s | %s (%s) |\n", B,
              if (min(d$B_eff) == max(d$B_eff)) d$B_eff[1] else paste0(min(d$B_eff), "-", max(d$B_eff)),
              plage_k(d$k_anc), plage(d$auto_anc), plage(d$hors_anc), moy(d$hors_anc),
              plage_k(d$k_dh), plage(d$auto_dh), plage(d$hors_dh), moy(d$hors_dh)))
}
eq <- !is.na(D$k_dh) & !is.na(D$k_anc)
cat(sprintf("\nConstat : k*_ancienne = k*_(4.17) + 1 sur %d des %d couples (B, graine) où les deux existent ; taux auto-évalués égaux (identical) sur %d ; k*_(4.17) NA sur %d couples ; colonnes de S avec ex aequo : %d.\n",
            sum(D$k_anc[eq] == D$k_dh[eq] + 1L), sum(eq),
            sum(vapply(which(eq), function(i) identical(D$auto_anc[i], D$auto_dh[i]), logical(1))),
            sum(is.na(D$k_dh)), n_ea))
cat("\n## Valeurs par graine\n\n")
print(transform(D, auto_anc = round(auto_anc, 4), hors_anc = round(hors_anc, 4),
                auto_dh = round(auto_dh, 4), hors_dh = round(hors_dh, 4)), row.names = FALSE)
cat("\n## Contrôles\n\n")
for (l in controles[c("c1", "c2", "c3")]) cat("- ", l, "\n", sep = "")
cat(sprintf("\nDurée : %.1f s\n", as.numeric(difftime(Sys.time(), t_debut, units = "secs"))))
quit(status = if (c1 && c2 && c3) 0L else 1L)
