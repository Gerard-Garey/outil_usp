###############################################################################
#  tests/mesure_b_dossier_t8.R  --  CALCUL DU DOSSIER A B = 4 999 : DUREE
#  D'EXECUTION ET STABILITE DES VERDICTS SUR LES SIX CAS DE REFERENCE
#  (issue #325)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils, tools et parallel, livres avec R). Il ne modifie ni
#  R/engine.R, ni tests/reference/, ni le B par defaut de run_engine() (999).
#  Sortie en markdown sur la console ; fichier ecrit SEULEMENT avec
#  --ecrire. Libelles non ASCII en echappements \u (fichier source ASCII).
#
#  Plan (issue #325 ; decision Q-Ff-5 du 17/10/2026 : B = 9 999 sur reserve2
#  seul) : les six cas de CAS (tests/outils_tests.R : premium, reserve1,
#  reserve2, premium_ii6, premium_net, premium_interieur), chacun a
#  B = 999 puis B = 4 999, plus reserve2 a B = 9 999. Chaque execution est
#  l'appel de run_engine() du cas, tel qu'ecrit dans CAS, dont seul
#  l'argument B est pose (corps de la fonction du cas modifie par body(),
#  sans copie des donnees ni des autres parametres) : meme graine (celle du
#  cas, 20260831 par defaut), meme alpha, memes donnees. Ordre : toutes les
#  executions a B = 999, puis a B = 4 999, puis reserve2 a B = 9 999 (une
#  sortie interrompue garde les B les plus petits complets ; avancement sur
#  la sortie d'erreur apres chaque execution, avec l'estimation de la duree
#  restante, proportionnelle a B, apres la passe a B = 999).
#
#  Prechauffage : chaque cas une fois a B = B_MIN_USAGE (99) avant les executions, non
#  chronometre et non restitue (couts uniques de la session R).
#  Grandeurs, par cas et par B :
#    - duree : temps ecoule (Sys.time()) et temps CPU du processus
#      (proc.time(), utilisateur + systeme), charge moyenne du systeme sur
#      1 min (/proc/loadavg, NA hors Linux) avant et apres ; les deux
#      temps sont ceux de la machine sous la charge restituee, sans
#      correction ;
#    - sigma_USP (parametre_final$sigma_usp) ;
#    - par ligne de engine_table_tests() (cle famille | test | variante) :
#      type, p retenue, nature de la p retenue, err_mc (champ err_mc de la
#      ligne, tel que le moteur le calcule, affiche seulement quand la p
#      retenue est Monte-Carlo : nature_p contenant "Monte-Carlo"), verdict,
#      champ inoperant et mention de #244 (detail terminant par
#      PHRASE_VERDICT_SENSIBLE_MC, meme lecture que .usp_poser_renvois() et
#      R/display_helpers.R) ;
#    - ecart au seuil le plus proche, en err_mc (T3) : |p - s| / err_mc, s
#      parcourant les seuils de la regle de #244 (add(), R/engine.R :
#      {alpha/2, alpha} en sens "ne pas rejeter", {alpha,
#      SEUIL_ECHEC_SENS_REJETER} en sens "rejeter"), atteignables seulement
#      (plancher p_min_mc s'il est fini, sinon 2 / (B + 1), majorant de la
#      granularite g_mc a B effectif = B, k <= 2 ; CHOIX DU SCRIPT, g_mc
#      n'etant pas restitue par ligne). Controle (c) : la condition
#      min |p - s| < 2 err_mc ainsi recalculee doit coincider, ligne par
#      ligne, avec la mention de #244 posee par le moteur ; echec : T0, code
#      de sortie 1, --ecrire refuse ;
#    - graines secondaires de res$metadata (seed_loi_nulle_sw,
#      seed_flux_regime, methode de permutation_pente), par cas (T0) ;
#    - reserve2 : triangles simules retires (bootstrap$cumuls_retires) et
#      plafond de retirage atteint (bootstrap$plafond_cumuls).
#  Lignes nommees : celles dont le verdict differe entre deux B du meme cas
#  (T3) ; les autres changements d'etat (type, inoperant, nature de la p,
#  mention de #244) sont listes a part (T4).
#  Controle (a) (hors --essai) : chaque execution a B = 999 est comparee a
#  sa reference tests/reference/<cas>.rds par comparer_objets() a la
#  tolerance TOLERANCE, apres nettoyer() et neutraliser_instables() (comme
#  test_reproductibilite.R) : le protocole reproduit le calcul de reference.
#  Echec : signale en T0, code de sortie 1, --ecrire refuse.
#  Constat (b) : les 999 premieres valeurs de bootstrap$sigma_boot a B > 999
#  sont-elles identiques (identical()) a celles de l'execution a B = 999 du
#  meme cas ? Mesure restituee en T1, sans controle (le moteur ne le
#  garantit pas par contrat). Imbrication verifiee sur sigma_boot SEUL : ni
#  le flux complementaire de la p conditionnelle au regime
#  (premium_interieur, graine seed_flux_regime), ni les autres tirages.
#  Groupes de cas aux lignes identiques (T3) : identical() sur test,
#  variante, p, err_mc, verdict et mention de #244, a chaque B (la famille
#  est exclue : son libelle cite la section de l'annexe XVII, B ou C, et
#  differe entre premium et reserve1 a lignes egales, mesure sous --essai) ; T3 compte en outre les
#  changements de verdict distincts (meme test, variante, suite de verdicts
#  et suite de p).
#
#  Statut des valeurs : une seule graine par cas. Un verdict qui change
#  entre deux B est un COMPORTEMENT OBSERVE sur cette graine, pas une
#  propriete du jeu de donnees : la p-value Monte-Carlo retenue est une
#  estimation, d'erreur err_mc fonction de B (erreur Monte-Carlo), distincte
#  de l'erreur d'approximation de la loi de la statistique a T = 8, que B ne
#  reduit pas.
#
#  Usage (depuis la racine du depot ; LC_ALL=C.UTF-8 sous Linux, #113) :
#      Rscript tests/mesure_b_dossier_t8.R [--ecrire [--remplacer]] [--essai]
#  --remplacer sans --ecrire : refus d'usage (code 1), avant tout autre
#    controle.
#  --ecrire : ecrit docs/tableaux/<AAAAMMJJ>-issue325-b-dossier.md (date
#    d'execution). REFUSE (code 1, rien d'ecrit), des l'analyse des
#    options, avant tout calcul, puis de nouveau avant d'ecrire (#205,
#    #173, comme tests/enumeration_spearman_ex_aequo.R) : dossier
#    docs/tableaux absent ; commit non propre ou script non suivi
#    (motifs_non_versionnable(commit_depot())) ; code hors du depot ; garde
#    d'ecrasement garde_ecrasement() sans --remplacer (avec --remplacer, le
#    T0 cite le fichier remplace et son md5 d'avant) ; --essai ; controle
#    (a) en echec.
#  --essai : plan reduit (B = 99 et 199, reserve2 en plus a 399), NON
#    versionnable, sans controle (a) ; verifie le script en quelques
#    minutes.
#  Code de sortie : 0 si le controle (a) tient (ou --essai), 1 sinon.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/mesure_b_dossier_t8.R"

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
# tests/outils_tests.R dans un environnement dedie : RACINE, CAS, nettoyer(),
# neutraliser_instables(), comparer_objets(), chemin_reference(),
# commit_depot(), garde_ecrasement(), empreinte_sans_commentaires(), et le
# moteur qu'il charge (run_engine(), engine_table_tests(),
# PHRASE_VERDICT_SENSIBLE_MC).
OT <- new.env()
sys.source(file.path(if (file.exists("tests/outils_tests.R")) "tests" else
                     if (file.exists("outils_tests.R")) "." else
                     stop("lancer depuis la racine du depot"), "outils_tests.R"), envir = OT)
RACINE <- OT$RACINE
FICHIER_MOTEUR <- file.path(RACINE, "R", "engine.R")

# --- Gardes de --ecrire (#205, #173) -------------------------------------------
# Cible fixee par la date du jour. Gardes ANTICIPEES avant tout calcul, puis
# gardes FINALES avant d'ecrire (l'etat du depot peut changer pendant le
# calcul). Fonctions et ordre de tests/enumeration_spearman_ex_aequo.R.
DATE <- format(Sys.Date(), "%Y%m%d")
CIBLE_MD <- file.path(RACINE, "docs", "tableaux", paste0(DATE, "-issue325-b-dossier.md"))
# Empreintes du code execute : md5 de ce script et de tests/outils_tests.R ;
# "hors depot" si le script execute n'est pas celui du depot.
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
NOMS_CAS <- names(OT$CAS)
B_COMMUNS <- if (ESSAI) c(99, 199) else c(999, 4999)
B_R2 <- if (ESSAI) 399 else 9999
B_REF <- 999          # B des references (defaut de run_engine())
PLAN <- rbind(expand.grid(cas = NOMS_CAS, B = B_COMMUNS, stringsAsFactors = FALSE)[, c("cas", "B")],
              data.frame(cas = "reserve2", B = B_R2, stringsAsFactors = FALSE))
PLAN <- PLAN[order(PLAN$B, match(PLAN$cas, NOMS_CAS)), ]
rownames(PLAN) <- NULL

# Appel du cas avec le seul argument B pose : le corps de la fonction du cas
# doit etre un appel direct de run_engine() sans argument B (verifie).
appel_cas <- function(nom, B) {
  f <- OT$CAS[[nom]]
  corps <- body(f)
  if (!is.call(corps) || !identical(corps[[1L]], quote(run_engine)) || !is.null(corps$B))
    stop("cas ", nom, " : corps inattendu (appel direct de run_engine() sans argument B attendu)")
  corps$B <- B
  body(f) <- corps
  f()
}

charge <- function() {
  if (!file.exists("/proc/loadavg")) return(NA_real_)
  as.numeric(strsplit(readLines("/proc/loadavg", n = 1L, warn = FALSE), " ")[[1L]][1L])
}
COEURS <- tryCatch(parallel::detectCores(), error = function(e) NA_integer_)

# Extraction ligne par ligne d'un resultat.
# Ecart au seuil atteignable le plus proche, en err_mc, selon la regle de
# #244 (voir l'en-tete) ; d = NA hors ligne de type test a p retenue
# Monte-Carlo d'err_mc finie > 0. c244 : condition de #244 recalculee.
distance_seuil <- function(p, err, sens, pmm, type, mc, alpha, B) {
  vide <- list(d = NA_real_, s = NA_real_, c244 = FALSE)
  if (!(identical(type, "test") && mc && is.finite(p) && is.finite(err) && err > 0)) return(vide)
  seuils <- if (identical(sens, "rejeter")) c(alpha, OT$SEUIL_ECHEC_SENS_REJETER) else c(alpha / 2, alpha)
  pl <- if (is.finite(pmm)) pmm else 2 / (B + 1)
  seuils <- seuils[pl < seuils]
  if (!length(seuils)) return(vide)
  d <- abs(p - seuils) / err
  j <- which.min(d)
  list(d = d[j], s = seuils[j], c244 = any(abs(p - seuils) < 2 * err))
}
extraire_lignes <- function(res) {
  tt <- OT$engine_table_tests(res)
  ph <- OT$PHRASE_VERDICT_SENSIBLE_MC
  mc <- !is.na(tt$nature_p) & grepl("Monte-Carlo", tt$nature_p, fixed = TRUE)
  ds <- lapply(seq_len(nrow(tt)), function(i)
    distance_seuil(tt$p_retenue[i], tt$erreur_MC[i], tt$sens_du_test[i], tt$p_min_mc[i], tt$type[i], mc[i],
                   res$metadata$alpha, res$metadata$B))
  data.frame(cle = paste(tt$famille, tt$test, tt$variante, sep = " | "),
             famille = tt$famille, test = tt$test, variante = tt$variante,
             type = tt$type, p = tt$p_retenue, nature = tt$nature_p, mc = mc,
             err = ifelse(mc, tt$erreur_MC, NA_real_),
             verdict = tt$verdict, inoperant = tt$inoperant,
             s244 = !is.na(tt$commentaire) & endsWith(tt$commentaire, ph),
             d_seuil = vapply(ds, `[[`, 0, "d"), seuil = vapply(ds, `[[`, 0, "s"),
             c244 = vapply(ds, `[[`, TRUE, "c244"),
             stringsAsFactors = FALSE)
}
# Graines du resultat (res$metadata), en texte.
graines_txt <- function(m) {
  x <- sprintf("seed %.0f", m$seed)
  if (!is.null(m$seed_loi_nulle_sw)) x <- c(x, sprintf("seed_loi_nulle_sw %.0f", m$seed_loi_nulle_sw))
  if (!is.null(m$seed_flux_regime)) x <- c(x, sprintf("seed_flux_regime %.0f", m$seed_flux_regime))
  if (!is.null(m$permutation_pente$methode))
    x <- c(x, sprintf("permutation_pente : %s", m$permutation_pente$methode))
  if (!is.null(m$generateur$kind))
    x <- c(x, sprintf("g\u00e9n\u00e9rateur %s", paste(unlist(m$generateur), collapse = "/")))
  paste(x, collapse = ", ")
}

# --- Prechauffage ---------------------------------------------------------------
# Chaque cas une fois a B = B_PRECHAUFFAGE, non chronometre et non restitue :
# les couts uniques d'une session R (cache de sw_loi_nulle(), compilation a
# la volee des fonctions) ne sont pas imputes a la premiere execution
# chronometree.
B_PRECHAUFFAGE <- OT$B_MIN_USAGE
for (nom in NOMS_CAS) invisible(appel_cas(nom, B_PRECHAUFFAGE))

# --- Executions ----------------------------------------------------------------
EXEC <- vector("list", nrow(PLAN))
SIGMA_BOOT_REF <- list()    # sigma_boot a B minimal, par cas (constat (b))
avance <- function(...) cat(sprintf(...), "\n", sep = "", file = stderr())
for (k in seq_len(nrow(PLAN))) {
  nom <- PLAN$cas[k]; B <- PLAN$B[k]
  ch0 <- charge(); cpu0 <- proc.time(); t0 <- Sys.time()
  res <- appel_cas(nom, B)
  t1 <- Sys.time(); cpu1 <- proc.time(); ch1 <- charge()
  if (!isTRUE(res$ok)) stop("cas ", nom, ", B = ", B, " : run_engine() a renvoye ok = FALSE\n", OT$decrire_refus(res))
  if (!identical(as.numeric(res$metadata$B), as.numeric(B))) stop("cas ", nom, " : metadata$B different de B")
  ctrl <- NULL
  if (!ESSAI && B == B_REF) {
    ref_f <- OT$chemin_reference(nom)
    ctrl <- if (!file.exists(ref_f)) list(conforme = FALSE, texte = paste("r\u00e9f\u00e9rence absente :", ref_f)) else {
      cmp <- OT$comparer_objets(OT$neutraliser_instables(readRDS(ref_f)),
                                OT$neutraliser_instables(OT$nettoyer(res)), tol = OT$TOLERANCE)
      list(conforme = cmp$conforme, texte = OT$resumer_comparaison(cmp)[1L],
           md5 = unname(tools::md5sum(ref_f)))
    }
  }
  sb <- res$bootstrap$sigma_boot
  if (B == min(PLAN$B)) SIGMA_BOOT_REF[[nom]] <- sb
  imbrique <- if (B == min(PLAN$B) || is.null(SIGMA_BOOT_REF[[nom]])) NA else {
    r0 <- SIGMA_BOOT_REF[[nom]]
    length(sb) >= length(r0) && identical(sb[seq_along(r0)], r0)
  }
  cpu <- (cpu1 - cpu0)
  EXEC[[k]] <- list(cas = nom, B = B, ecoule = as.numeric(difftime(t1, t0, units = "secs")),
                    cpu = unname(cpu[["user.self"]] + cpu[["sys.self"]]),
                    charge_avant = ch0, charge_apres = ch1,
                    sigma_usp = res$parametre_final$sigma_usp, seed = res$metadata$seed,
                    graines = graines_txt(res$metadata),
                    alpha = res$metadata$alpha, lignes = extraire_lignes(res), ctrl = ctrl,
                    imbrique = imbrique,
                    cumuls_retires = if (!is.null(res$bootstrap$cumuls_retires)) sum(res$bootstrap$cumuls_retires) else NA,
                    plafond_cumuls = if (!is.null(res$bootstrap$plafond_cumuls)) any(res$bootstrap$plafond_cumuls) else NA)
  rm(res); invisible(gc(verbose = FALSE))
  avance("[%s] %-17s B = %5.0f : %7.1f s ecoules, %7.1f s CPU, charge %.2f -> %.2f, sigma_USP = %.10f%s",
         format(Sys.time(), "%H:%M:%S"), nom, B, EXEC[[k]]$ecoule, EXEC[[k]]$cpu, ch0, ch1, EXEC[[k]]$sigma_usp,
         if (is.null(ctrl)) "" else paste0(" ; controle (a) : ", ctrl$texte))
  if (k < nrow(PLAN) && PLAN$B[k + 1L] != B && B == min(PLAN$B)) {
    fait <- vapply(EXEC[seq_len(k)], `[[`, 0, "ecoule"); names(fait) <- PLAN$cas[seq_len(k)]
    reste <- sum(fait[PLAN$cas[-seq_len(k)]] * PLAN$B[-seq_len(k)] / B)
    avance("estimation de la duree restante (proportionnelle a B, charge courante) : %.0f s (%.1f h)", reste, reste / 3600)
  }
}

# --- Agregats ------------------------------------------------------------------
CTRL <- Filter(Negate(is.null), lapply(EXEC, `[[`, "ctrl"))
CTRL_OK <- ESSAI || (length(CTRL) == length(NOMS_CAS) && all(vapply(CTRL, `[[`, TRUE, "conforme")))
# Controle (c) : condition de #244 recalculee = mention posee par le moteur.
ECARTS_C <- unlist(lapply(EXEC, function(e) {
  k <- which(e$lignes$c244 != e$lignes$s244)
  if (length(k)) sprintf("%s, B = %.0f, ligne %d (%s)", e$cas, e$B, k, e$lignes$test[k]) else character(0)
}))
CTRL_C_OK <- !length(ECARTS_C)
if (ECRIRE && !(CTRL_OK && CTRL_C_OK)) {
  message("--ecrire refuse : controle (a) ou (c) en echec -- aucun fichier ecrit")
  quit(status = 1L)
}
B_DU_CAS <- function(nom) PLAN$B[PLAN$cas == nom]
EXEC_DE <- function(nom, B) EXEC[[which(PLAN$cas == nom & PLAN$B == B)]]

# Tableau large par cas : une ligne par cle, colonnes par B. Les cles
# doivent etre les memes, dans le meme ordre, pour tous les B d'un cas.
fp <- function(x) ifelse(is.na(x), "\u2014", formatC(x, format = "f", digits = 4))
fe <- fp
fb <- function(B) formatC(B, format = "d", big.mark = "\u00a0")
ech <- function(x) OT$echapper(OT$une_ligne(ifelse(is.na(x), "\u2014", x)))
CHANGE_V <- list(); CHANGE_A <- list()
lignes_cas <- function(nom) {
  Bs <- B_DU_CAS(nom)
  L <- lapply(Bs, function(B) EXEC_DE(nom, B)$lignes)
  for (j in seq_along(L)[-1L])
    if (!identical(L[[j]]$cle, L[[1L]]$cle))
      stop("cas ", nom, " : lignes de engine_table_tests() differentes entre B = ", Bs[1L], " et B = ", Bs[j])
  L
}
etat <- function(l, i) sprintf("%s%s%s, %s", l$type[i], if (isTRUE(l$inoperant[i])) " (inop\u00e9rant)" else "",
                               if (l$s244[i]) ", #244" else "", ech(l$nature[i]))
T2 <- character(0)
for (nom in NOMS_CAS) {
  Bs <- B_DU_CAS(nom); L <- lignes_cas(nom); l1 <- L[[1L]]
  cols <- unlist(lapply(Bs, function(B) sprintf(c("p (B = %s)", "err_mc (B = %s)", "Verdict (B = %s)", "#244 (B = %s)"),
                                                fb(B))))
  T2 <- c(T2, "", sprintf("#### Cas `%s` (graine %.0f)", nom, EXEC_DE(nom, Bs[1L])$seed), "",
          paste0("| # | Famille | Test | Variante | Type | Nature de la p retenue | ", paste(cols, collapse = " | "),
                 " | Verdict change |"),
          paste0("|", paste(rep("---", 7L + length(cols)), collapse = "|"), "|"))
  for (i in seq_len(nrow(l1))) {
    v <- vapply(L, function(l) l$verdict[i], "")
    vals <- unlist(lapply(L, function(l) c(fp(l$p[i]), fe(l$err[i]), ech(l$verdict[i]), if (l$s244[i]) "oui" else "")))
    chg_v <- length(unique(v)) > 1L
    # nature de la p : celle du premier B ; ses changements vont en T4
    T2 <- c(T2, sprintf("| %d | %s | %s | %s | %s | %s | %s | %s |", i, ech(l1$famille[i]), ech(l1$test[i]),
                        ech(l1$variante[i]), ech(l1$type[i]), ech(l1$nature[i]), paste(vals, collapse = " | "),
                        if (chg_v) "**oui**" else ""))
    if (chg_v) {
      sig <- paste(l1$test[i], l1$variante[i], paste(v, collapse = "/"),
                   paste(vapply(L, function(l) format(l$p[i], digits = 17), ""), collapse = "/"))
      CHANGE_V[[length(CHANGE_V) + 1L]] <- list(sig = sig, txt = sprintf("| `%s` | %d | %s | %s | %s | %s | %s |", nom, i, ech(l1$test[i]),
                                                   ech(l1$variante[i]),
                                                   paste(sprintf("%s (B = %s)", v, vapply(Bs, fb, "")), collapse = " \u2192 "),
                                                   paste(sprintf("%s \u00b1 %s", fp(vapply(L, function(l) l$p[i], 0)),
                                                                 fe(vapply(L, function(l) l$err[i], 0))), collapse = " \u2192 "),
                                                   paste(vapply(L, function(l) if (is.na(l$d_seuil[i])) "\u2014" else
                                                     sprintf("%s (s = %s)", formatC(l$d_seuil[i], format = "f", digits = 2),
                                                             format(l$seuil[i])), ""), collapse = " \u2192 ")))
    }
    e <- vapply(seq_along(L), function(j) etat(L[[j]], i), "")
    if (length(unique(e)) > 1L)
      CHANGE_A[[length(CHANGE_A) + 1L]] <- sprintf("| `%s` | %d | %s | %s | %s |", nom, i, ech(l1$test[i]),
                                                   ech(l1$variante[i]),
                                                   paste(sprintf("%s (B = %s)", e, vapply(Bs, fb, "")), collapse = " \u2192 "))
  }
}

# Groupes de cas aux lignes identiques a chaque B (test, variante, p,
# err_mc, verdict, mention de #244 ; famille exclue, voir l'en-tete) ; seuls
# les groupes de plus d'un cas sont restitues.
vue <- function(nom) lapply(B_DU_CAS(nom), function(B)
  EXEC_DE(nom, B)$lignes[, c("test", "variante", "p", "err", "verdict", "s244")])
GROUPES <- list(); reste_g <- NOMS_CAS
while (length(reste_g)) {
  g <- reste_g[vapply(reste_g, function(n) identical(B_DU_CAS(n), B_DU_CAS(reste_g[1L])) &&
                                            identical(vue(n), vue(reste_g[1L])), TRUE)]
  if (length(g) > 1L) GROUPES[[length(GROUPES) + 1L]] <- g
  reste_g <- setdiff(reste_g, g)
}
N_CHG_DISTINCTS <- length(unique(vapply(CHANGE_V, `[[`, "", "sig")))

# Ecart avec la revue du 15/10 (C5 d'actuary) : ligne HomogF de reserve2 au
# B de reference (au B minimal sous --essai).
B_C5 <- if (B_REF %in% B_DU_CAS("reserve2")) B_REF else min(B_DU_CAS("reserve2"))
L_C5 <- EXEC_DE("reserve2", B_C5)$lignes
I_C5 <- which(L_C5$test == "Homogeneite de f_j entre annees de survenance")
NOTE_C5 <- if (length(I_C5) != 1L) "Ligne HomogF de `reserve2` introuvable : note de comparaison \u00e0 la revue du 15/10 non produite." else
  sprintf(paste0("\u00c9cart avec la revue du 15/10 (PR #296, bloc 5), qui comptait trois lignes de `reserve2` \u00e0 moins de deux err_mc d'un seuil \u00e0 B = 999 :",
                 " cette mesure en compte %d \u00e0 B = %s (mention #244). La troisi\u00e8me, HomogF (ligne %d, p = %s \u00b1 %s), est \u00e0 %s err_mc de %s et %s err_mc de %s :",
                 " elle %s le crit\u00e8re strict |p \u2212 s| < 2 err_mc de #244 (`add()`, `R/engine.R`).",
                 " La revue du 15/10 comptait cette ligne parmi les lignes \u00e0 moins de deux erreurs Monte-Carlo du seuil ;",
                 " le crit\u00e8re strict de #244 pos\u00e9 par le moteur l'exclut (distances ci-dessus). L'origine du compte de la revue n'est pas \u00e9tablie.%s"),
          sum(L_C5$s244), fb(B_C5), I_C5, fp(L_C5$p[I_C5]), fp(L_C5$err[I_C5]),
          formatC(abs(L_C5$p[I_C5] - EXEC_DE("reserve2", B_C5)$alpha) / L_C5$err[I_C5], format = "f", digits = 2),
          format(EXEC_DE("reserve2", B_C5)$alpha),
          formatC(abs(L_C5$p[I_C5] - EXEC_DE("reserve2", B_C5)$alpha / 2) / L_C5$err[I_C5], format = "f", digits = 2),
          format(EXEC_DE("reserve2", B_C5)$alpha / 2),
          if (L_C5$s244[I_C5]) "remplit" else "ne remplit pas",
          if (B_C5 != B_REF) sprintf(" (--essai : valeurs \u00e0 B = %s, non comparables \u00e0 la revue.)", fb(B_C5)) else "")

# --- Sorties --------------------------------------------------------------------
if (ECRIRE) REMPLACES <- gardes_ecrire("de l'ex\u00e9cution")
DUREE <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
si <- Sys.info()
fs <- function(x) ifelse(is.na(x), "\u2014", formatC(x, format = "f", digits = 1))
fc <- function(x) ifelse(is.na(x), "\u2014", formatC(x, format = "f", digits = 2))
txt_ctrl <- if (ESSAI) "non ex\u00e9cut\u00e9 (--essai)" else
  paste(vapply(NOMS_CAS, function(nom) {
    c0 <- EXEC_DE(nom, B_REF)$ctrl
    sprintf("%s : %s%s", nom, ech(c0$texte), if (is.null(c0$md5)) "" else sprintf(" (r\u00e9f\u00e9rence md5 %s)", c0$md5))
  }, ""), collapse = " ; ")

md <- c(
  "# Calcul du dossier \u00e0 B = 4\u00a0999 : dur\u00e9e d'ex\u00e9cution et stabilit\u00e9 des verdicts sur les six cas (issue #325)",
  "",
  "### T0 \u2014 Ex\u00e9cution",
  "",
  "| Grandeur | Valeur |", "|---|---|",
  sprintf("| Date | %s |", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  sprintf("| Script | `%s`%s |", SCRIPT, if (ESSAI) " --essai (plan r\u00e9duit, NON versionnable)" else ""),
  sprintf("| Commit | `%s` |", COMMIT),
  sprintf("| Empreintes du code | %s |", empreintes_code()),
  sprintf("| Moteur | `R/engine.R`, md5 `%s`, empreinte sans commentaires `%s` |", MD5_MOTEUR,
          OT$empreinte_sans_commentaires(FICHIER_MOTEUR)),
  sprintf("| R | %s, %s, %s, %s ; c\u0153urs (`parallel::detectCores()`) : %s |", R.version.string,
          utils::sessionInfo()$running, si[["sysname"]], si[["machine"]], COEURS),
  sprintf("| BLAS / LAPACK | %s / %s |", ech(utils::sessionInfo()$BLAS), ech(utils::sessionInfo()$LAPACK)),
  OT$ligne_remplacement(REMPLACES, CIBLE_MD),
  sprintf("| Plan | six cas de `CAS` (`tests/outils_tests.R`) \u00e0 B = %s et %s, `reserve2` en plus \u00e0 B = %s ; appel du cas avec le seul argument B pos\u00e9 ; une ex\u00e9cution \u00e0 la fois, dans un seul processus |",
          fb(B_COMMUNS[1L]), fb(B_COMMUNS[2L]), fb(B_R2)),
  sprintf("| Graines (`res$metadata`, au B minimal ; inchang\u00e9es entre les B) | %s |",
          paste(vapply(NOMS_CAS, function(nom) sprintf("%s : %s", nom, EXEC_DE(nom, min(B_DU_CAS(nom)))$graines), ""),
                collapse = " ; ")),
  sprintf("| Graines identiques entre les B d'un m\u00eame cas | %s |",
          if (all(vapply(NOMS_CAS, function(nom) length(unique(vapply(B_DU_CAS(nom), function(B) EXEC_DE(nom, B)$graines, ""))) == 1L, TRUE)))
            "oui" else "NON"),
  sprintf("| \u03b1 | %s |", paste(unique(vapply(EXEC, function(e) format(e$alpha), "")), collapse = ", ")),
  sprintf("| Contr\u00f4le (a) : ex\u00e9cution \u00e0 B = 999 contre sa r\u00e9f\u00e9rence (`comparer_objets()`, tol\u00e9rance %g) | %s |",
          OT$TOLERANCE, txt_ctrl),
  sprintf("| Contr\u00f4le (c) : condition de #244 recalcul\u00e9e (\u00e9cart au seuil, T3) = mention pos\u00e9e par le moteur, sur toutes les lignes | %s |",
          if (CTRL_C_OK) "conforme" else paste("\u00c9CHEC :", paste(ECARTS_C, collapse = " ; "))),
  sprintf("| Charge moyenne sur 1 min (`/proc/loadavg`), min \u2013 max sur les ex\u00e9cutions | %s \u2013 %s |",
          fc(suppressWarnings(min(unlist(lapply(EXEC, function(e) c(e$charge_avant, e$charge_apres))), na.rm = TRUE))),
          fc(suppressWarnings(max(unlist(lapply(EXEC, function(e) c(e$charge_avant, e$charge_apres))), na.rm = TRUE)))),
  sprintf("| Dur\u00e9e totale du script | %s s |", fs(DUREE)),
  "",
  "Statut des valeurs : une seule graine par cas ; p retenue, err_mc et verdict tels que les rend `run_engine()`.",
  "Un verdict qui change d'un B \u00e0 l'autre est un comportement observ\u00e9 sur cette graine : la p-value Monte-Carlo est une estimation",
  "d'erreur Monte-Carlo err_mc (fonction de B), distincte de l'erreur d'approximation de la loi de la statistique \u00e0 T = 8, que B ne r\u00e9duit pas.",
  "Temps \u00e9coul\u00e9 et temps CPU : mesur\u00e9s sous la charge restitu\u00e9e (colonne Charge), sans correction ; non mesur\u00e9s sur machine non charg\u00e9e.",
  "Mention #244 : le `detail` de la ligne se termine par la phrase de sensibilit\u00e9 du verdict (p \u00e0 moins de 2 err_mc d'un seuil atteignable).",
  "err_mc n'est affich\u00e9e que lorsque la p retenue est Monte-Carlo.",
  "Imbrication des tirages (T1) : v\u00e9rifi\u00e9e sur `sigma_boot` seul ; le flux compl\u00e9mentaire de la p conditionnelle au r\u00e9gime (`premium_interieur`, graine `seed_flux_regime`) et les autres tirages ne sont pas contr\u00f4l\u00e9s.",
  "",
  "### T1 \u2014 Dur\u00e9e et \u03c3_USP par cas et par B",
  "",
  "| Cas | B | Temps \u00e9coul\u00e9 (s) | Temps CPU (s) | Rapport CPU / CPU \u00e0 B minimal | Charge avant \u2192 apr\u00e8s | \u03c3_USP | Premi\u00e8res valeurs de `sigma_boot` identiques \u00e0 celles du B minimal | Triangles retir\u00e9s (`cumuls_retires`) | Plafond atteint |",
  "|---|---|---|---|---|---|---|---|---|---|")
for (k in seq_along(EXEC)) {
  e <- EXEC[[k]]
  cpu0 <- EXEC_DE(e$cas, min(B_DU_CAS(e$cas)))$cpu
  md <- c(md, sprintf("| `%s` | %s | %s | %s | %s | %s \u2192 %s | %.10f | %s | %s | %s |", e$cas, fb(e$B), fs(e$ecoule), fs(e$cpu),
                      fc(e$cpu / cpu0), fc(e$charge_avant), fc(e$charge_apres), e$sigma_usp,
                      if (is.na(e$imbrique)) "\u2014" else if (e$imbrique) "oui" else "non",
                      if (is.na(e$cumuls_retires)) "\u2014" else format(e$cumuls_retires),
                      if (is.na(e$plafond_cumuls)) "\u2014" else if (e$plafond_cumuls) "oui" else "non"))
}
md <- c(md, sprintf("| Total | | %s | %s | | | | | | |", fs(sum(vapply(EXEC, `[[`, 0, "ecoule"))),
                    fs(sum(vapply(EXEC, `[[`, 0, "cpu")))),
        "",
        sprintf("Temps CPU : grandeur de r\u00e9f\u00e9rence de la dur\u00e9e, mesur\u00e9e sur machine charg\u00e9e (charge %s \u00e0 %s sur %s c\u0153urs).",
                fc(suppressWarnings(min(unlist(lapply(EXEC, function(e) c(e$charge_avant, e$charge_apres))), na.rm = TRUE))),
                fc(suppressWarnings(max(unlist(lapply(EXEC, function(e) c(e$charge_avant, e$charge_apres))), na.rm = TRUE))),
                COEURS))

# Synthese par cas et B : decomptes de verdicts, lignes a p Monte-Carlo
# retenue, mentions de #244.
md <- c(md, "", "### T1 bis \u2014 D\u00e9comptes par cas et par B", "",
        "| Cas | B | Lignes | OK | ALERTE | ECHEC | INFO | Autres verdicts | p retenue Monte-Carlo | Mentions #244 | Lignes inop\u00e9rantes |",
        "|---|---|---|---|---|---|---|---|---|---|---|")
for (e in EXEC) {
  l <- e$lignes; v <- l$verdict
  mc <- !is.na(l$nature) & grepl("Monte-Carlo", l$nature, fixed = TRUE)
  md <- c(md, sprintf("| `%s` | %s | %d | %d | %d | %d | %d | %d | %d | %d | %d |", e$cas, fb(e$B), nrow(l),
                      sum(v %in% "OK"), sum(v %in% "ALERTE"), sum(v %in% "ECHEC"), sum(v %in% "INFO"),
                      sum(!v %in% c("OK", "ALERTE", "ECHEC", "INFO")), sum(mc), sum(l$s244), sum(l$inoperant %in% TRUE)))
}

md <- c(md, "", "### T2 \u2014 Lignes de tests, par cas", "",
        "p : p retenue ; err_mc : erreur Monte-Carlo de la ligne ; nature de la p retenue lue au B minimal (changements en T4).",
        T2,
        "", "### T3 \u2014 Lignes dont le verdict change entre deux B", "",
        "| Cas | # | Test | Variante | Verdicts | p retenue \u00b1 err_mc | \u00c9cart au seuil atteignable le plus proche, en err_mc, par B |",
        "|---|---|---|---|---|---|---|")
md <- c(md, if (length(CHANGE_V)) vapply(CHANGE_V, `[[`, "", "txt") else "| \u2014 | | aucune | | | | |",
        "",
        "\u00c9cart au seuil : |p \u2212 s| / err_mc, s seuil atteignable le plus proche de la r\u00e8gle de #244 (\u03b1/2 ou \u03b1 en sens \u00ab ne pas rejeter \u00bb ; \u03b1 ou 0,30 en sens \u00ab rejeter \u00bb).",
        sprintf("Cas aux lignes de tests identiques \u00e0 chaque B (`identical()` sur test, variante, p, err_mc, verdict, mention #244 ; la famille, qui cite la section B ou C de l'annexe XVII, est exclue) : %s.",
                if (length(GROUPES)) paste(vapply(GROUPES, function(g) paste(sprintf("`%s`", g), collapse = ", "), ""), collapse = " ; ") else "aucun"),
        "`premium`, `reserve1`, `premium_ii6` et `premium_net` partagent les m\u00eames donn\u00e9es (`.ln$xt`, `.ln$yt`, `CAS` de `tests/outils_tests.R`).",
        sprintf("Changements de verdict distincts (m\u00eame test, variante, suite de verdicts et suite de p) : %d sur %d lignes de T3.",
                N_CHG_DISTINCTS, length(CHANGE_V)),
        "", NOTE_C5,
        "", "### T4 \u2014 Autres changements d'\u00e9tat entre deux B (type, inop\u00e9rant, mention #244, nature de la p)", "",
        "| Cas | # | Test | Variante | \u00c9tats |", "|---|---|---|---|---|",
        if (length(CHANGE_A)) unlist(CHANGE_A) else "| \u2014 | | aucun | | |")

ecrire_console <- function(x) writeLines(enc2utf8(x), con = stdout(), useBytes = TRUE)
ecrire_console(md)

if (ECRIRE) {
  con <- file(CIBLE_MD, open = "wb"); writeLines(enc2utf8(md), con, useBytes = TRUE); close(con)
  cat(sprintf("\nEcrit : %s\n", CIBLE_MD), file = stderr())
}
if (!CTRL_OK) {
  message("controle (a) en echec : une execution a B = 999 differe de sa reference")
  quit(status = 1L)
}
quit(status = 0L)
