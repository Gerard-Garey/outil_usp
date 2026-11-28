###############################################################################
#  tests/mesure_correlation_cvm_ad_t8.R  --  DEPENDANCE DE W2 (CRAMER-VON
#  MISES) ET A2 (ANDERSON-DARLING) SOUS LA LOI QUI DEFINIT LEURS p DE
#  MONTE-CARLO, JEUX J1 ET J2, A T = 8 (issue #420, point 2)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils et tools, livres avec R). Il ne modifie ni
#  R/engine.R, ni tests/reference/, ni le B par defaut de run_engine() (999).
#  Sortie en markdown sur la console ; fichier ecrit SEULEMENT avec
#  --ecrire. Libelles non ASCII en echappements \u (fichier source ASCII).
#
#  Protocole : avis d'actuary de l'etape 1 de S9
#  (docs/revues/20261127-s9-mesures/actuary-protocoles-etape-1.md, par. 2 ;
#  point 1 de #420 deja solde par tests/unitaires/test_mk_spearman.R), ecrit
#  avant toute execution de ce script.
#
#  Quantite et nature (avis, par. 2.1). Dependance entre W2 (stat_cvm(),
#  statistique CvM du catalogue USP_CATALOGUE_MC) et A2 (stat_ad(),
#  statistique AD) calculees sur les residus reajustes z* des replications,
#  SOUS LA LOI QUI DEFINIT LEURS p DE MONTE-CARLO :
#    J1 = cas premium de CAS (tests/outils_tests.R ; delta estime au bord,
#         variante V1 de la p Monte-Carlo) ;
#    J2 = cas premium_interieur (delta estime interieur, variante V3b, loi
#         conditionnelle au regime interieur de delta**, ADR 0014).
#  Nature : approximation Monte-Carlo d'une fonctionnelle de la loi
#  bootstrap, CONDITIONNELLE aux parametres ajustes ; constat de simulation
#  sur deux jeux, a T = 8. Rien n'est dit sous les alternatives.
#
#  Voie (avis, par. 2.2) : aucune simulation nouvelle. Les replications sont
#  celles de bootstrap$stats_boot, matrice passee a .mc_p_values() par
#  usp_bootstrap() (R/engine.R), flux V3b compris : V1, B lignes, ligne NA
#  si la replication est ecartee ; V3b, les tirages retenus au regime
#  interieur. Chaque execution est l'appel de run_engine() du cas, tel
#  qu'ecrit dans CAS, dont seuls les arguments B et seed sont poses (corps
#  de la fonction du cas modifie par body(), comme
#  tests/mesure_b_dossier_t8.R, sans copie des donnees ni des autres
#  parametres) : B = 9 999, seed = 20260831 (graine du dossier, defaut de
#  run_engine() ; flux V3b de J2 : usp_graine_flux_regime(20260831) =
#  20 800 000). Tous les tirages sont ceux de usp_bootstrap(), sous
#  engine_sous_graine() ; le script n'en ajoute aucun.
#
#  Grandeurs, par jeu, sur les lignes de stats_boot ou CvM ET AD sont
#  finies (lignes ecartees comptees : ligne entierement non finie, ou une
#  seule des deux statistiques non finie) :
#    1. rho de Spearman (cor(method = "spearman"), rangs moyens en cas
#       d'ex aequo), grandeur principale : les decisions p_mc ne dependent
#       que des rangs ;
#    2. r de Pearson, grandeur secondaire, sensible a la queue de A2 ;
#    3. concordance des rejets sous H0 : p de chaque replication i par rang
#       "laisser-un-de-cote" parmi les n - 1 autres, sens de rejet du
#       catalogue ("haut" pour CvM et AD, verifie) :
#         p_i = (1 + #{j != i : s_j >= s_i}) / n,
#       meme forme que engine_p_mc() avec la replication i en observee ;
#       rejet si p_i < alpha (regle des verdicts de add(), sens "ne pas
#       rejeter" : ALERTE si p < alpha) ; a alpha = 0,10 et 0,05 : taux de
#       rejet de chaque statistique, taux de rejet conjoint,
#       P(rejet CvM | rejet AD) et P(rejet AD | rejet CvM), et leur minimum
#       (grandeur du critere, avis Q2) ; reperes : 1 si dependance parfaite
#       (comonotonie), environ alpha si independance.
#       Sans ex aequo sur une statistique, ses p laisser-un-de-cote sont une
#       permutation de {1/n, ..., n/n} : son taux de rejet marginal vaut
#       exactement (ceiling(n alpha) - 1) / n, par construction (affiche sans
#       ET, avis Q4 : l'ET jackknife n'y refleterait que l'inegalite des
#       tailles des groupes, n_g = 499 ou 500 lignes, d'ou des
#       sous-echantillons jackknife de n - 499 ou n - 500 lignes) ; sans ex
#       aequo sur les deux, les deux
#       conditionnelles sont egales par construction, sur l'echantillon entier
#       comme dans chaque sous-echantillon jackknife (une seule ligne en T3,
#       avis Q2). L'ET du taux conjoint, lui, est garde.
#  Erreur Monte-Carlo (fonction de B ; avis, par. 2.3) : jackknife par
#  groupes, G = 20 groupes CONSECUTIFS de lignes retenues (groupe de la
#  ligne k sur n : ceiling(k G / n), tailles egales a une unite pres) ;
#  chaque grandeur est recalculee sur les n - n_g lignes hors du groupe g
#  (p laisser-un-de-cote comprises, recalculees sur ce sous-echantillon) ;
#  ET = sqrt((G - 1) / G * somme_g (theta_(-g) - moyenne)^2), formule non
#  ponderee (tailles egales a une unite pres ; avis Q3). Deterministe,
#  aucune graine. Un sous-echantillon (ou l'echantillon entier) sans aucun
#  rejet d'une des deux statistiques rend une conditionnelle indefinie :
#  jackknife degenere, arret par stop() sans aucune lecture (avis Q5). Les replications retenues sont i.i.d. conditionnellement
#  aux donnees, V3b compris (acceptation-rejet) : avis, par. 2.3. Aucune
#  erreur d'echantillonnage en R (un seul jeu de donnees par cas) : la
#  dependance a theta ajuste est une conditionnalite, documentee par deux
#  jeux seulement.
#
#  Controles (code de sortie 1 et --ecrire refuse si l'un echoue) :
#    (c1) sens de rejet de CvM et AD au catalogue USP_CATALOGUE_MC egal a
#         "haut" (forme de p_i ci-dessus) ;
#    (c2) p_mc recalculee depuis stats_boot, (1 + #{s >= obs}) / (n_j + 1)
#         sur les n_j valeurs finies de la colonne, identique (identical())
#         a bootstrap$p_mc du moteur, a engine_p_mc(stats_boot[, j], obs,
#         "haut")$p_mc et a la p Monte-Carlo de la ligne de
#         engine_table_tests() (mc_nom), et n_j identique a
#         bootstrap$B_effectif ; motif_mc absent ;
#    (c3) p laisser-un-de-cote par les rangs identiques au comptage direct
#         sur les 200 premieres lignes retenues de chaque jeu ;
#    (c4) metadata : seed, B, et graine du flux V3b egales au plan ;
#    (c5) par jeu, si W2 et A2 sont sans ex aequo parmi les lignes retenues :
#         nombre de rejets de chaque statistique egal a #{k dans 1..n :
#         k / n < alpha} (= ceiling(n alpha) - 1) aux deux alpha, et
#         P(rejet CvM | rejet AD) et P(rejet AD | rejet CvM) identiques
#         (identical()) sur l'echantillon entier et sur chacun des G
#         sous-echantillons jackknife ; sans objet (conforme, signale) s'il y
#         a des ex aequo.
#  Constats rapportes sans controle : variante V1 / V3b de chaque jeu
#  (attendue V1 pour J1, V3b pour J2 ; avis, par. 2.1), delta estime,
#  sigma_USP, valeurs observees de W2 et A2 et lignes de tests associees.
#
#  Critere de lecture (avis, par. 2.4, complete par les reponses Q1 et Q2
#  d'actuary, docs/revues/20261127-s9-mesures/actuary-questions-420-367.md,
#  rendues avant toute execution complete ; conventions declarees, sans
#  fondement theorique), lu automatiquement en T5, dans cet ordre. CMIN
#  designe min(P(rejet CvM | rejet AD), P(rejet AD | rejet CvM)) a
#  alpha = 0,10 (egales par construction en l'absence d'ex aequo ; sinon,
#  critere sur la plus petite des deux) :
#    - rho_S < 0,70 sur un jeu au moins : CONTREDITE (PM-3) ;
#    - sinon 0,70 <= rho_S < 0,90 sur un jeu au moins : DEPENDANCE FORTE,
#      NON QUASI REDONDANTE (phrase a nuancer, PM-3) ;
#    - sinon, si sur J1 ET J2 rho_S - 2 ET >= 0,90 et CMIN - 2 ET >= 0,75 :
#      QUASI-REDONDANCE SOUS H0 ETABLIE ;
#    - sinon, si CMIN estime < 0,75 sur un jeu au moins : DEPENDANCE FORTE,
#      NON QUASI REDONDANTE (CONCORDANCE DES REJETS SOUS 0,75), phrase a
#      nuancer, PM-3 (Q1, branche 1) ;
#    - sinon (estimations au-dessus des seuils, une borne a 2 ET manquee) :
#      QUASI-REDONDANCE NON ETABLIE A B = 9 999, PM-3 ; la phrase du .tex est
#      remplacee par les valeurs chiffrees (estimation +/- ET), sans etre dite
#      contredite (Q1, branche 2). Pas de relance a B plus grand une fois le
#      resultat vu (M42).
#  ET jackknife a G = 20 groupes : environ 19 degres de liberte, incertitude
#  relative de l'ET d'environ 1/sqrt(38), soit 16 % (approximation du khi-2,
#  avis Q3) ; la borne "- 2 ET" est une convention a +/- 0,3 ET pres (ecrit
#  sous T5).
#  Portee (avis, par. 2.5) : rien sous les alternatives (ou la ponderation
#  des queues de A2 les distingue) ; ne dit pas qu'un seul verdict suffit en
#  puissance ; conditionnel a J1 et J2, a T = 8.
#
#  Usage (depuis la racine du depot ; LC_ALL=C.UTF-8 sous Linux, #113) :
#      Rscript tests/mesure_correlation_cvm_ad_t8.R [--ecrire [--remplacer]] [--essai]
#  --remplacer sans --ecrire : refus d'usage (code 1), avant tout autre
#    controle.
#  --ecrire : ecrit docs/tableaux/<AAAAMMJJ>-issue420-correlation-cvm-ad.md
#    (date d'execution). REFUSE (code 1, rien d'ecrit), des l'analyse des
#    options, avant tout calcul, puis de nouveau avant d'ecrire (memes
#    gardes que tests/mesure_b_dossier_t8.R) : dossier docs/tableaux absent ;
#    commit non propre ou script non suivi ; code hors du depot ; garde
#    d'ecrasement garde_ecrasement() sans --remplacer ; --essai ; controle en
#    echec.
#  --essai : plan reduit (B = 299), NON representatif et NON versionnable ;
#    verifie le script en moins d'une minute et imprime la duree extrapolee
#    de l'execution complete (proportionnelle a B, majorant : la part fixe
#    de run_engine() est extrapolee avec le reste).
#  Code de sortie : 0 si les controles tiennent, 1 sinon.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/mesure_correlation_cvm_ad_t8.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113) --------------------------------
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
OPTIONS_DRAPEAU <- c("--ecrire", "--remplacer", "--essai")
for (a in ARGS) if (!a %in% OPTIONS_DRAPEAU) stop("option inconnue : ", a)
ECRIRE    <- "--ecrire" %in% ARGS
REMPLACER <- "--remplacer" %in% ARGS
ESSAI     <- "--essai" %in% ARGS
# Refus d'usage avant tout autre controle et tout chargement (#173).
if (REMPLACER && !ECRIRE) {
  message("--remplacer : reserve a --ecrire")
  quit(status = 1L)
}
if (ECRIRE && ESSAI) {
  message("--ecrire : refuse avec --essai (plan reduit, non versionnable)")
  quit(status = 1L)
}

# --- Outils partages et moteur -------------------------------------------------
# tests/outils_tests.R dans un environnement dedie : RACINE, CAS,
# commit_depot(), motifs_non_versionnable(), garde_ecrasement(),
# ligne_remplacement(), empreinte_sans_commentaires(), echapper(), et le
# moteur qu'il charge (run_engine(), engine_table_tests(), engine_p_mc(),
# USP_CATALOGUE_MC, usp_graine_flux_regime()).
OT <- new.env()
sys.source(file.path(if (file.exists("tests/outils_tests.R")) "tests" else
                     if (file.exists("outils_tests.R")) "." else
                     stop("lancer depuis la racine du depot"), "outils_tests.R"), envir = OT)
RACINE <- OT$RACINE
FICHIER_MOTEUR <- file.path(RACINE, "R", "engine.R")

# --- Gardes de --ecrire (#205, #173) -------------------------------------------
# Copie declaree de tests/mesure_b_dossier_t8.R (empreintes_code(),
# gardes_ecrire()) : gardes ANTICIPEES avant tout calcul, puis FINALES avant
# d'ecrire.
DATE <- format(Sys.Date(), "%Y%m%d")
CIBLE_MD <- file.path(RACINE, "docs", "tableaux", paste0(DATE, "-issue420-correlation-cvm-ad.md"))
empreintes_code <- function() {
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  md5 <- function(x) if (!length(x) || !file.exists(x)) "absent" else unname(tools::md5sum(x))
  dans <- length(f) == 1L && identical(normalizePath(f, winslash = "/", mustWork = FALSE),
                                       normalizePath(file.path(RACINE, SCRIPT), winslash = "/", mustWork = FALSE))
  sprintf("%s %s%s ; tests/outils_tests.R %s", SCRIPT, md5(f), if (dans) "" else " (hors d\u00e9p\u00f4t)",
          md5(file.path(RACINE, "tests", "outils_tests.R")))
}
gardes_ecrire <- function(quand) {
  if (!dir.exists(file.path(RACINE, "docs", "tableaux"))) stop("dossier de sortie introuvable : docs/tableaux")
  nv <- OT$motifs_non_versionnable(OT$commit_depot(SCRIPT), empreintes_code(), quand)
  if (length(nv)) {
    message("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
            " -- aucun fichier ecrit")
    quit(status = 1L)
  }
  OT$garde_ecrasement(CIBLE_MD, remplacer = REMPLACER, racine = RACINE)
}
REMPLACES <- NULL
if (ECRIRE) REMPLACES <- gardes_ecrire("de l'ex\u00e9cution")
COMMIT <- OT$commit_depot(SCRIPT)
MD5_MOTEUR <- unname(tools::md5sum(FICHIER_MOTEUR))

# --- Plan ----------------------------------------------------------------------
JEUX <- c(J1 = "premium", J2 = "premium_interieur")
VARIANTE_ATTENDUE <- c(J1 = "V1", J2 = "V3b")     # avis, par. 2.1 (constat, sans controle)
B_COMPLET <- 9999
B_PLAN <- if (ESSAI) 299 else B_COMPLET
SEED <- 20260831                                  # graine du dossier
G_JACK <- 20L
ALPHAS <- c(0.10, 0.05)
STATS <- c("CvM", "AD")
N_C3 <- 200L                                      # lignes du controle (c3)

# Appel du cas avec les seuls arguments B et seed poses : le corps de la
# fonction du cas doit etre un appel direct de run_engine() sans argument B
# ni seed (verifie ; meme lecture que appel_cas() de
# tests/mesure_b_dossier_t8.R).
appel_cas <- function(nom, B, seed) {
  f <- OT$CAS[[nom]]
  corps <- body(f)
  if (!is.call(corps) || !identical(corps[[1L]], quote(run_engine)) || !is.null(corps$B) || !is.null(corps$seed))
    stop("cas ", nom, " : corps inattendu (appel direct de run_engine() sans argument B ni seed attendu)")
  corps$B <- B
  corps$seed <- seed
  body(f) <- corps
  f()
}

# p laisser-un-de-cote, sens "haut" : (1 + #{j != i : s_j >= s_i}) / n.
# rank(ties.method = "min") = 1 + #{j : s_j < s_i}, donc
# #{j != i : s_j >= s_i} = n - rank.
p_loo <- function(s) {
  n <- length(s)
  (1 + n - rank(s, ties.method = "min")) / n
}

# Grandeurs sur un echantillon apparie (w = W2, a = A2), vecteur nomme.
grandeurs <- function(w, a) {
  pw <- p_loo(w); pa <- p_loo(a)
  out <- c(spearman = stats::cor(w, a, method = "spearman"), pearson = stats::cor(w, a, method = "pearson"))
  for (al in ALPHAS) {
    rw <- pw < al; ra <- pa < al
    suf <- sprintf("_%03d", round(100 * al))
    out[paste0("rej_cvm", suf)] <- mean(rw)
    out[paste0("rej_ad", suf)] <- mean(ra)
    out[paste0("rej_conj", suf)] <- mean(rw & ra)
    # Q5 : une conditionnelle sans rejet au denominateur est indefinie
    # (jackknife degenere) : arret, aucune lecture imprimee.
    if (sum(ra) == 0 || sum(rw) == 0)
      stop(sprintf("jackknife degenere : aucun rejet %s a alpha = %s sur un echantillon de %d lignes ; aucune lecture",
                   if (sum(ra) == 0) "AD" else "CvM", format(al), length(w)))
    out[paste0("cvm_sachant_ad", suf)] <- sum(rw & ra) / sum(ra)
    out[paste0("ad_sachant_cvm", suf)] <- sum(rw & ra) / sum(rw)
    out[paste0("cond_min", suf)] <- min(out[[paste0("cvm_sachant_ad", suf)]], out[[paste0("ad_sachant_cvm", suf)]])
  }
  out
}

# Jackknife par groupes consecutifs : estimation sur l'echantillon entier,
# ET jackknife de chaque grandeur.
jackknife <- function(w, a, G) {
  n <- length(w)
  g <- ceiling(seq_len(n) * G / n)
  est <- grandeurs(w, a)
  th <- vapply(seq_len(G), function(k) grandeurs(w[g != k], a[g != k]), est)
  et <- sqrt((G - 1) / G * rowSums((th - rowMeans(th))^2))
  list(est = est, et = et, th = th, tailles = as.vector(table(factor(g, levels = seq_len(G)))))
}

avance <- function(...) cat(sprintf(...), "\n", sep = "", file = stderr())

# --- Executions et calculs -----------------------------------------------------
CTRL <- list()
controle <- function(code, ok, detail) CTRL[[length(CTRL) + 1L]] <<- list(code = code, ok = isTRUE(ok), detail = detail)
controle("(c1)", all(vapply(STATS, function(j) identical(OT$USP_CATALOGUE_MC[[j]]$queue, "haut"), TRUE)),
         sprintf("sens de rejet au catalogue : %s", paste(sprintf("%s %s", STATS, vapply(STATS, function(j)
           paste(OT$USP_CATALOGUE_MC[[j]]$queue, collapse = "/"), "")), collapse = ", ")))

RES <- list()
for (jeu in names(JEUX)) {
  nom <- JEUX[[jeu]]
  cpu0 <- proc.time(); t0 <- Sys.time()
  res <- appel_cas(nom, B_PLAN, SEED)
  t1 <- Sys.time(); cpu1 <- proc.time()
  if (!isTRUE(res$ok)) stop("cas ", nom, " : run_engine() a renvoye ok = FALSE\n", OT$decrire_refus(res))
  bt <- res$bootstrap
  S <- bt$stats_boot
  if (is.null(S) || !all(STATS %in% colnames(S))) stop("cas ", nom, " : colonnes CvM et AD absentes de bootstrap$stats_boot")
  w_all <- S[, "CvM"]; a_all <- S[, "AD"]
  fin_w <- is.finite(w_all); fin_a <- is.finite(a_all)
  garde <- fin_w & fin_a
  n_aucune <- sum(!fin_w & !fin_a); n_une <- sum(xor(fin_w, fin_a))
  # ex aequo parmi les lignes retenues (valeurs repetees), par statistique
  exaeq <- c(CvM = sum(garde) - length(unique(w_all[garde])), AD = sum(garde) - length(unique(a_all[garde])))
  w <- unname(w_all[garde]); a <- unname(a_all[garde])
  # (c2) p_mc recalculee depuis stats_boot, comparee au moteur.
  tt <- OT$engine_table_tests(res)
  c2 <- lapply(STATS, function(j) {
    s <- S[, j]; s <- s[is.finite(s)]
    obs <- bt$stats_obs[[j]]
    p <- (1 + sum(s >= obs)) / (length(s) + 1)
    pe <- OT$engine_p_mc(S[, j], obs, "haut")$p_mc
    k <- which(tt$mc_nom %in% j)
    p_ligne <- if (length(k) == 1L) tt$p_monte_carlo[k] else NA_real_
    list(j = j, obs = obs, p = p, n = length(s),
         ok = identical(p, unname(bt$p_mc[[j]])) && identical(p, pe) && length(k) == 1L && identical(p, p_ligne) &&
           identical(as.numeric(length(s)), unname(as.numeric(bt$B_effectif[[j]]))) && is.na(bt$motif_mc[[j]]),
         ligne = if (length(k) == 1L) tt[k, c("test", "type", "p_retenue", "nature_p", "erreur_MC", "verdict")] else NULL,
         err = unname(bt$err_mc[[j]]))
  })
  names(c2) <- STATS
  # (c3) p laisser-un-de-cote : rangs contre comptage direct.
  m <- min(N_C3, length(w))
  c3 <- all(vapply(list(w, a), function(s) {
    pr <- p_loo(s)[seq_len(m)]
    pd <- vapply(seq_len(m), function(i) (1 + sum(s[-i] >= s[i])) / length(s), 0)
    identical(pr, pd)
  }, TRUE))
  meta <- res$metadata
  flux_att <- OT$usp_graine_flux_regime(SEED)
  c4 <- identical(as.numeric(meta$seed), SEED) && identical(as.numeric(meta$B), as.numeric(B_PLAN)) &&
    identical(as.numeric(meta$seed_flux_regime), flux_att) && identical(as.numeric(bt$p_mc_regime$graine_flux), flux_att)
  jk <- jackknife(w, a, G_JACK)
  # (c5) sans ex aequo : rejets marginaux et conditionnelles par construction.
  sans_exaeq <- all(exaeq == 0)
  c5 <- if (!sans_exaeq) TRUE else all(vapply(ALPHAS, function(al) {
    attendu <- sum(seq_len(length(w)) / length(w) < al)
    suf <- sprintf("_%03d", round(100 * al))
    ga <- paste0("cvm_sachant_ad", suf); gc <- paste0("ad_sachant_cvm", suf)
    sum(p_loo(w) < al) == attendu && sum(p_loo(a) < al) == attendu &&
      identical(jk$est[[ga]], jk$est[[gc]]) && identical(unname(jk$th[ga, ]), unname(jk$th[gc, ]))
  }, TRUE))
  RES[[jeu]] <- list(jeu = jeu, cas = nom, ecoule = as.numeric(difftime(t1, t0, units = "secs")),
                     cpu = unname((cpu1 - cpu0)[["user.self"]] + (cpu1 - cpu0)[["sys.self"]]),
                     delta = res$ajustement$delta, sigma_usp = res$parametre_final$sigma_usp,
                     variante = bt$p_mc_regime$variante, regime = bt$p_mc_regime$regime_obs,
                     tirages = bt$p_mc_regime$tirages, retenus = bt$p_mc_regime$retenus, arret = bt$p_mc_regime$arret,
                     lignes = nrow(S), n_aucune = n_aucune, n_une = n_une, n = length(w), exaeq = exaeq,
                     c2 = c2, c3 = c3, c4 = c4, c5 = c5, sans_exaeq = sans_exaeq, jk = jk,
                     graines = sprintf("seed %.0f, seed_flux_regime %.0f%s, g\u00e9n\u00e9rateur %s", meta$seed, meta$seed_flux_regime,
                                       if (!is.null(meta$seed_loi_nulle_sw)) sprintf(", seed_loi_nulle_sw %.0f", meta$seed_loi_nulle_sw) else "",
                                       paste(unlist(meta$generateur), collapse = "/")))
  controle(sprintf("(c2) %s", jeu), all(vapply(c2, `[[`, TRUE, "ok")),
           paste(vapply(c2, function(x) sprintf("%s : p recalcul\u00e9e %s sur %d valeurs finies", x$j, format(x$p, digits = 17), x$n), ""),
                 collapse = " ; "))
  controle(sprintf("(c3) %s", jeu), c3, sprintf("p laisser-un-de-c\u00f4t\u00e9 par les rangs = comptage direct, %d premi\u00e8res lignes retenues, W\u00b2 et A\u00b2", m))
  controle(sprintf("(c4) %s", jeu), c4, sprintf("seed %.0f, B %.0f, graine du flux %.0f (attendue %.0f)", meta$seed, meta$B,
                                                 meta$seed_flux_regime, flux_att))
  controle(sprintf("(c5) %s", jeu), c5,
           if (sans_exaeq) sprintf(paste0("sans ex aequo : rejets marginaux = #{k : k/n < \u03b1} (%s) et conditionnelles identiques,",
                                          " \u00e9chantillon entier et %d sous-\u00e9chantillons"),
                                   paste(vapply(ALPHAS, function(al) sprintf("%d \u00e0 \u03b1 = %s", sum(seq_len(length(w)) / length(w) < al), format(al)), ""),
                                         collapse = ", "), G_JACK)
           else sprintf("sans objet : ex aequo (W\u00b2 %d ; A\u00b2 %d)", exaeq[["CvM"]], exaeq[["AD"]]))
  rm(res); invisible(gc(verbose = FALSE))
  avance("[%s] %s (%s) B = %.0f : %.1f s ecoules, %.1f s CPU ; n = %d ; rho_S = %.4f",
         format(Sys.time(), "%H:%M:%S"), jeu, nom, B_PLAN, RES[[jeu]]$ecoule, RES[[jeu]]$cpu, RES[[jeu]]$n,
         RES[[jeu]]$jk$est[["spearman"]])
}
CTRL_OK <- all(vapply(CTRL, `[[`, TRUE, "ok"))
if (ECRIRE && !CTRL_OK) {
  message("--ecrire refuse : controle en echec -- aucun fichier ecrit")
  for (k in CTRL) if (!k$ok) message("  ", k$code, " : ", k$detail)
  quit(status = 1L)
}

# --- Formats ------------------------------------------------------------------
f4 <- function(x) ifelse(is.na(x), "\u2014", formatC(x, format = "f", digits = 4))
f5 <- function(x) ifelse(is.na(x), "\u2014", formatC(x, format = "f", digits = 5))
fs <- function(x) ifelse(is.na(x), "\u2014", formatC(x, format = "f", digits = 1))
fb <- function(B) formatC(B, format = "d", big.mark = "\u00a0")
# alpha au format decimal francais (0,10 ; 0,05)
fa <- function(x) sub(".", ",", formatC(x, format = "f", digits = 2), fixed = TRUE)

# --- Lecture du critere (avis, par. 2.4) ---------------------------------------
est <- function(jeu, g) RES[[jeu]]$jk$est[[g]]
et <- function(jeu, g) RES[[jeu]]$jk$et[[g]]
RHO <- vapply(names(JEUX), est, 0, g = "spearman")
BORNE_RHO <- vapply(names(JEUX), function(j) est(j, "spearman") - 2 * et(j, "spearman"), 0)
COND <- vapply(names(JEUX), est, 0, g = "cond_min_010")
BORNE_COND <- vapply(names(JEUX), function(j) est(j, "cond_min_010") - 2 * et(j, "cond_min_010"), 0)
LIB_CMIN <- "min(P(rejet CvM | rejet AD), P(rejet AD | rejet CvM))"
LECTURE <- if (any(RHO < 0.70)) {
  sprintf("**Contredite** (PM-3) : \u03c1_S < 0,70 sur %s.", paste(names(JEUX)[RHO < 0.70], collapse = " et "))
} else if (any(RHO < 0.90)) {
  sprintf("**D\u00e9pendance forte, non quasi redondante** (phrase \u00e0 nuancer, PM-3) : 0,70 \u2264 \u03c1_S < 0,90 sur %s.",
          paste(names(JEUX)[RHO < 0.90], collapse = " et "))
} else if (all(BORNE_RHO >= 0.90) && all(BORNE_COND >= 0.75)) {
  sprintf("**Quasi-redondance sous H0 \u00e9tablie** : sur J1 et J2, \u03c1_S \u2212 2 ET \u2265 0,90 et %s \u2212 2 ET \u2265 0,75 \u00e0 \u03b1 = 0,10.", LIB_CMIN)
} else if (any(COND < 0.75)) {
  # Q1, branche 1 : decisions non concordantes malgre rho_S >= 0,90.
  sprintf(paste0("**D\u00e9pendance forte, non quasi redondante (concordance des rejets sous 0,75)** (phrase \u00e0 nuancer, PM-3) :",
                 " \u03c1_S \u2265 0,90 sur J1 et J2, mais %s estim\u00e9e < 0,75 \u00e0 \u03b1 = 0,10 sur %s."),
          LIB_CMIN, paste(names(JEUX)[COND < 0.75], collapse = " et "))
} else {
  # Q1, branche 2 : estimations au-dessus des seuils, une borne a 2 ET manquee.
  sprintf(paste0("**Quasi-redondance non \u00e9tablie \u00e0 B = %s** (PM-3) : estimations au-dessus des seuils sur J1 et J2,",
                 " mais une borne \u00e0 2 ET au moins n'est pas atteinte ; \u03c1_S : %s ; %s \u00e0 \u03b1 = 0,10 : %s.",
                 " La phrase \u00ab presque deux fois la m\u00eame information \u00bb est remplac\u00e9e par ces valeurs chiffr\u00e9es,",
                 " sans \u00eatre dite contredite."),
          fb(B_PLAN),
          paste(sprintf("%s %s \u00b1 %s", names(JEUX), f4(RHO), f5(vapply(names(JEUX), et, 0, g = "spearman"))), collapse = ", "),
          LIB_CMIN,
          paste(sprintf("%s %s \u00b1 %s", names(JEUX), f4(COND), f5(vapply(names(JEUX), et, 0, g = "cond_min_010"))), collapse = ", "))
}

# --- Sorties --------------------------------------------------------------------
if (ECRIRE) REMPLACES <- gardes_ecrire("de l'ex\u00e9cution")
DUREE <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
si <- Sys.info()
ech <- function(x) OT$echapper(OT$une_ligne(ifelse(is.na(x), "\u2014", as.character(x))))
EXTRAP <- vapply(RES, function(r) r$ecoule * B_COMPLET / B_PLAN, 0)

md <- c(
  "# Corr\u00e9lation de W\u00b2 (Cram\u00e9r\u2013von Mises) et A\u00b2 (Anderson\u2013Darling) sous la loi de leurs p de Monte-Carlo, jeux J1 et J2, \u00e0 T = 8 (issue #420, point 2)",
  "",
  if (ESSAI) c("> **--essai : plan r\u00e9duit (B = 299), valeurs NON repr\u00e9sentatives, NON versionnables.**", "") else NULL,
  "### T0 \u2014 Ex\u00e9cution",
  "",
  "| Grandeur | Valeur |", "|---|---|",
  sprintf("| Date | %s |", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  sprintf("| Script | `%s`%s |", SCRIPT, if (ESSAI) " --essai (plan r\u00e9duit, NON repr\u00e9sentatif, NON versionnable)" else ""),
  sprintf("| Commit | `%s` |", COMMIT),
  sprintf("| Empreintes du code | %s |", empreintes_code()),
  sprintf("| Moteur | `R/engine.R`, md5 `%s`, empreinte sans commentaires `%s` |", MD5_MOTEUR,
          OT$empreinte_sans_commentaires(FICHIER_MOTEUR)),
  sprintf("| R | %s, %s, %s, %s |", R.version.string, utils::sessionInfo()$running, si[["sysname"]], si[["machine"]]),
  sprintf("| BLAS / LAPACK | %s / %s |", ech(utils::sessionInfo()$BLAS), ech(utils::sessionInfo()$LAPACK)),
  OT$ligne_remplacement(REMPLACES, CIBLE_MD),
  sprintf("| Plan | J1 = cas `premium`, J2 = cas `premium_interieur` (`CAS`, `tests/outils_tests.R`) ; `run_engine()` du cas, seuls B = %s et seed = %.0f pos\u00e9s ; aucune simulation hors de `usp_bootstrap()` |",
          fb(B_PLAN), SEED),
  sprintf("| Graines (`res$metadata`) | %s |", paste(vapply(RES, function(r) sprintf("%s : %s", r$jeu, r$graines), ""), collapse = " ; ")),
  sprintf("| Erreur Monte-Carlo | jackknife par groupes, G = %d groupes cons\u00e9cutifs de lignes retenues ; tailles : %s |", G_JACK,
          paste(vapply(RES, function(r) sprintf("%s %d \u00e0 %d", r$jeu, min(r$jk$tailles), max(r$jk$tailles)), ""), collapse = ", ")),
  sprintf("| \u03b1 de la concordance des rejets | %s (rejet si p < \u03b1) |", paste(fa(ALPHAS), collapse = " ; ")),
  sprintf("| Contr\u00f4les | %s |", if (CTRL_OK) "tous conformes (T4)" else "**\u00c9CHEC** (T4)"),
  sprintf("| Dur\u00e9e totale du script | %s s |", fs(DUREE)),
  if (ESSAI) sprintf("| Dur\u00e9e extrapol\u00e9e de l'ex\u00e9cution compl\u00e8te (B = %s, proportionnelle \u00e0 B, majorant) | %s : %s s ; total %s s (%s min) |",
                     fb(B_COMPLET), paste(names(EXTRAP), collapse = " et "), paste(fs(EXTRAP), collapse = " et "),
                     fs(sum(EXTRAP)), fs(sum(EXTRAP) / 60)) else NULL,
  "",
  "Statut des valeurs : approximation Monte-Carlo d'une fonctionnelle de la loi bootstrap, conditionnelle aux param\u00e8tres ajust\u00e9s de chaque jeu ;",
  "constat de simulation sur deux jeux, \u00e0 T = 8. ET : erreur Monte-Carlo (fonction de B), par jackknife par groupes ; aucune erreur d'\u00e9chantillonnage en R (un seul jeu de donn\u00e9es par cas).",
  "Loi : celle qui d\u00e9finit les p de Monte-Carlo de CvM et AD (`bootstrap$stats_boot`, variante V1 ou V3b de la p Monte-Carlo, ADR 0014), non une loi sous les alternatives.",
  "",
  "### T1 \u2014 Jeux, lois et r\u00e9plications",
  "",
  "| Jeu | Cas | \u03b4\u0302 | \u03c3_USP | Variante de la p Monte-Carlo (attendue) | R\u00e9gime de \u03b4\u0302 | Tirages / retenus (V3b) | Lignes de `stats_boot` | \u00c9cart\u00e9es : W\u00b2 et A\u00b2 non finies | \u00c9cart\u00e9es : une seule non finie | n retenu | Ex aequo (W\u00b2 ; A\u00b2) | Temps \u00e9coul\u00e9 (s) | Temps CPU (s) |",
  "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
for (r in RES)
  md <- c(md, sprintf("| %s | `%s` | %s | %.10f | %s (%s) | %s | %s | %d | %d | %d | %d | %d ; %d | %s | %s |", r$jeu, r$cas,
                      formatC(r$delta, format = "f", digits = 6), r$sigma_usp, r$variante, VARIANTE_ATTENDUE[[r$jeu]], r$regime,
                      if (identical(r$variante, "V3b")) sprintf("%.0f / %.0f (arr\u00eat : %s)", r$tirages, r$retenus, r$arret) else "\u2014",
                      r$lignes, r$n_aucune, r$n_une, r$n, r$exaeq[["CvM"]], r$exaeq[["AD"]], fs(r$ecoule), fs(r$cpu)))

md <- c(md, "", "### T2 \u2014 Valeurs observ\u00e9es et lignes de tests", "",
        "| Jeu | Statistique | Valeur observ\u00e9e | p Monte-Carlo | err_mc | Test | Type | p retenue | Verdict |",
        "|---|---|---|---|---|---|---|---|---|")
for (r in RES) for (j in STATS) {
  x <- r$c2[[j]]; l <- x$ligne
  md <- c(md, sprintf("| %s | %s | %s | %s | %s | %s | %s | %s | %s |", r$jeu, if (j == "CvM") "W\u00b2 (CvM)" else "A\u00b2 (AD)",
                      formatC(x$obs, format = "g", digits = 10), f4(x$p), f4(x$err),
                      if (is.null(l)) "\u2014" else ech(l$test), if (is.null(l)) "\u2014" else ech(l$type),
                      if (is.null(l)) "\u2014" else f4(l$p_retenue), if (is.null(l)) "\u2014" else ech(l$verdict)))
}

LIB <- c(spearman = "\u03c1 de Spearman (grandeur principale)", pearson = "r de Pearson (grandeur secondaire)")
for (al in ALPHAS) {
  suf <- sprintf("_%03d", round(100 * al)); a_txt <- fa(al)
  LIB[paste0("rej_cvm", suf)] <- sprintf("P(rejet CvM), \u03b1 = %s", a_txt)
  LIB[paste0("rej_ad", suf)] <- sprintf("P(rejet AD), \u03b1 = %s", a_txt)
  LIB[paste0("rej_conj", suf)] <- sprintf("P(rejet CvM et rejet AD), \u03b1 = %s", a_txt)
  LIB[paste0("cvm_sachant_ad", suf)] <- sprintf("P(rejet CvM | rejet AD), \u03b1 = %s", a_txt)
  LIB[paste0("ad_sachant_cvm", suf)] <- sprintf("P(rejet AD | rejet CvM), \u03b1 = %s", a_txt)
  LIB[paste0("cond_min", suf)] <- sprintf("%s, \u03b1 = %s (grandeur du crit\u00e8re)", LIB_CMIN, a_txt)
}
# Q2 : sans ex aequo sur J1 ET J2, les deux conditionnelles sont egales par
# construction sur chaque jeu (controle (c5)) : une seule ligne. Des qu'un
# jeu a des ex aequo, les deux lignes et leur minimum sont imprimes (les
# cellules du jeu sans ex aequo y sont egales entre elles).
SANS_EXAEQ <- vapply(RES, `[[`, TRUE, "sans_exaeq")
if (all(SANS_EXAEQ)) for (al in ALPHAS) {
  suf <- sprintf("_%03d", round(100 * al))
  LIB[paste0("cvm_sachant_ad", suf)] <- sprintf(paste0("P(rejet CvM | rejet AD) = P(rejet AD | rejet CvM), \u03b1 = %s",
                                                       " (\u00e9gales par construction, aucun ex aequo en T1)"), fa(al))
  LIB <- LIB[setdiff(names(LIB), paste0(c("ad_sachant_cvm", "cond_min"), suf))]
}
# Cellule de T3 : estimation +/- ET ; taux marginal d'une statistique sans
# ex aequo sur le jeu : valeur fixee par construction, sans ET (Q4).
cellule <- function(jeu, g) {
  st <- if (grepl("^rej_cvm_", g)) "CvM" else if (grepl("^rej_ad_", g)) "AD" else NA
  if (!is.na(st) && RES[[jeu]]$exaeq[[st]] == 0)
    sprintf("%s = (\u2308n\u03b1\u2309 \u2212 1)/n \u2014 par construction", f4(est(jeu, g)))
  else sprintf("%s \u00b1 %s", f4(est(jeu, g)), f5(et(jeu, g)))
}
REPERE <- function(g) {
  al <- if (grepl("_010$", g)) fa(0.10) else if (grepl("_005$", g)) fa(0.05) else NA
  if (g %in% c("spearman", "pearson")) "1 si d\u00e9pendance parfaite, 0 si ind\u00e9pendance"
  else if (grepl("^rej_(cvm|ad)_", g)) sprintf("\u2248 %s par construction (p laisser-un-de-c\u00f4t\u00e9)", al)
  else if (grepl("^rej_conj_", g)) sprintf("%s si comonotonie, \u2248 %s\u00b2 si ind\u00e9pendance", al, al)
  else sprintf("1 si comonotonie, \u2248 %s si ind\u00e9pendance", al)
}
md <- c(md, "", sprintf("### T3 \u2014 D\u00e9pendance de W\u00b2 et A\u00b2 sous la loi bootstrap : estimation \u00b1 ET (jackknife, G = %d)", G_JACK), "",
        "| Grandeur | J1 | J2 | Rep\u00e8re |", "|---|---|---|---|")
for (g in names(LIB))
  md <- c(md, sprintf("| %s | %s | %s | %s |", ech(LIB[[g]]), cellule("J1", g), cellule("J2", g), REPERE(g)))
md <- c(md, "",
        "p laisser-un-de-c\u00f4t\u00e9 de la r\u00e9plication i : (1 + #{j \u2260 i : s_j \u2265 s_i}) / n, n lignes retenues ; rejet si p < \u03b1 (r\u00e8gle des verdicts, sens \u00ab ne pas rejeter \u00bb).",
        paste0("Sans ex aequo sur une statistique (T1), ses p laisser-un-de-c\u00f4t\u00e9 sont une permutation de {1/n, ..., n/n} : elle compte exactement \u2308n\u03b1\u2309 \u2212 1 rejets, ",
               "et son taux marginal (\u2308n\u03b1\u2309 \u2212 1)/n est fix\u00e9 par construction, sans ET (l'ET jackknife n'y refl\u00e9terait que les tailles des sous-\u00e9chantillons). ",
               "Sans ex aequo sur W\u00b2 et A\u00b2, P(rejet CvM | rejet AD) et P(rejet AD | rejet CvM) sont \u00e9gales par construction (contr\u00f4le (c5)) ; ",
               "sinon, le crit\u00e8re porte sur la plus petite des deux. L'ET du taux conjoint est une erreur Monte-Carlo r\u00e9elle."),
        "ET : \u00e9cart-type jackknife par groupes cons\u00e9cutifs, erreur Monte-Carlo seule (fonction de B) ; la d\u00e9pendance aux param\u00e8tres ajust\u00e9s n'est pas une erreur mais une conditionnalit\u00e9.")

md <- c(md, "", "### T4 \u2014 Contr\u00f4les", "", "| Contr\u00f4le | R\u00e9sultat | D\u00e9tail |", "|---|---|---|",
        vapply(CTRL, function(k) sprintf("| %s | %s | %s |", k$code, if (k$ok) "conforme" else "**\u00c9CHEC**", ech(k$detail)), ""),
        "",
        "(c1) sens de rejet au catalogue `USP_CATALOGUE_MC` ; (c2) p_mc recalcul\u00e9e depuis `stats_boot` identique \u00e0 `bootstrap$p_mc`, \u00e0 `engine_p_mc()` et \u00e0 la ligne de `engine_table_tests()`, B effectif identique, sans motif ;",
        "(c3) p laisser-un-de-c\u00f4t\u00e9 par les rangs identiques au comptage direct ; (c4) graine, B et graine du flux V3b conformes au plan ;",
        "(c5) sans ex aequo : rejets marginaux \u00e9gaux \u00e0 \u2308n\u03b1\u2309 \u2212 1 et conditionnelles identiques (`identical()`), \u00e9chantillon entier et sous-\u00e9chantillons jackknife.")

md <- c(md, "", "### T5 \u2014 Lecture du crit\u00e8re (avis d'actuary, par. 2.4, compl\u00e9t\u00e9 par ses r\u00e9ponses Q1 et Q2)", "",
        if (ESSAI) "*--essai : lecture m\u00e9canique sur un plan r\u00e9duit, sans valeur.*" else NULL,
        LECTURE, "",
        sprintf("\u03c1_S : %s ; \u03c1_S \u2212 2 ET : %s ; %s \u00e0 \u03b1 = 0,10 : %s ; moins 2 ET : %s.",
                paste(sprintf("%s %s", names(JEUX), f4(RHO)), collapse = ", "),
                paste(sprintf("%s %s", names(JEUX), f4(BORNE_RHO)), collapse = ", "),
                LIB_CMIN,
                paste(sprintf("%s %s", names(JEUX), f4(COND)), collapse = ", "),
                paste(sprintf("%s %s", names(JEUX), f4(BORNE_COND)), collapse = ", ")),
        paste0("Crit\u00e8re de concordance sur ", LIB_CMIN, " : \u00e9gales par construction en l'absence d'ex aequo (T1) ; sinon, crit\u00e8re sur la plus petite des deux."),
        "Seuils 0,90, 0,75 et 0,70 : conventions d\u00e9clar\u00e9es par l'avis, sans fondement th\u00e9orique.",
        sprintf(paste0("ET jackknife \u00e0 G = %d groupes : environ %d degr\u00e9s de libert\u00e9, incertitude relative de l'ET d'environ 1/\u221a%d \u2248 %.0f %% ",
                       "(approximation du \u03c7\u00b2) ; la borne \u00ab \u2212 2 ET \u00bb est donc une convention \u00e0 \u00b1 0,3 ET pr\u00e8s."),
                G_JACK, G_JACK - 1L, 2L * (G_JACK - 1L), 100 / sqrt(2 * (G_JACK - 1))),
        "Port\u00e9e : rien sous les alternatives, o\u00f9 la pond\u00e9ration des queues de A\u00b2 les distingue ; la mesure ne dit pas qu'un seul verdict suffit en puissance ; conditionnelle \u00e0 J1 et J2, \u00e0 T = 8.")

ecrire_console <- function(x) writeLines(enc2utf8(x), con = stdout(), useBytes = TRUE)
ecrire_console(md)
if (ESSAI)
  avance("duree extrapolee de l'execution complete (B = %.0f, proportionnelle a B) : %s ; total %.0f s (%.1f min)",
         B_COMPLET, paste(sprintf("%s %.0f s", names(EXTRAP), EXTRAP), collapse = ", "), sum(EXTRAP), sum(EXTRAP) / 60)
if (ECRIRE) {
  con <- file(CIBLE_MD, open = "wb"); writeLines(enc2utf8(md), con, useBytes = TRUE); close(con)
  cat(sprintf("\nEcrit : %s\n", CIBLE_MD), file = stderr())
}
for (k in CTRL) if (!k$ok) message("controle ", k$code, " en echec : ", k$detail)
quit(status = if (CTRL_OK) 0L else 1L)
