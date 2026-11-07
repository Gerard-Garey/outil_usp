###############################################################################
#  tests/mesure_independance_tj_t8.R  --  INDEPENDANCE DES t_j ET LOI DES
#  p-VALUES DE L'ORDONNEE A L'ORIGINE ET DE LA COURBURE (M1) SOUS UN MODELE DE
#  MACK GAUSSIEN, A T = 8 (issue #448, suite du point 2 de #424)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (parallel, tools, utils livres avec R). Il ne modifie ni
#  R/engine.R ni tests/reference/ : il appelle mw_test_ordonnee_origine() et
#  mw_test_courbure() du moteur, inchangees, et lit le tableau "detail" qu'elles
#  rendent (colonnes j, n, t, p), sans jamais le recalculer. Aucun bootstrap :
#  les p-values lues sont les p chi2(2K) de la combinaison de Fisher du moteur
#  (.fisher_combine()), p de la ligne ; les t_j et les p_j sont ceux des
#  colonnes. Tous les libelles non ASCII sont ecrits en echappements \u
#  (fichier source ASCII).
#
#  Objet. Les fiches mw:m1a et mw:m1c du .tex donnent la p-value chi2(2K) de ces
#  deux lignes comme EXACTE sous erreurs conditionnelles gaussiennes et annees
#  independantes (raisonnement d'actuary non publie : les t_j sont des
#  Student(n_j - 2) pour l'ordonnee, Student(n_j - 3) pour la courbure, supposes
#  independants, donc X = -2 sum ln p_j suit un chi2(2K)). Le script verse la
#  MESURE de cette propriete : loi de la p de la ligne, loi de chaque t_j,
#  independance des t_j (Spearman sur t_j et sur |t_j|), sous un modele de Mack
#  gaussien ajuste a reserve2. Statut : CONSTAT DE SIMULATION SOUS UN PLAN,
#  de compatibilite, pas une demonstration ni un resultat general.
#
#  Plan fixe par actuary, accepte par le mainteneur le 06/11/2026 (issue #448).
#    Modele generateur : Mack gaussien ajuste a reserve2 (tests/donnees/
#      triangle_mw.csv, mw_ajuster()), f et sigma^2 de reserve2 non reestimes ;
#      generateur gen_triangle_h0() (copie declaree de
#      tests/puissance_mw_t8.R / tests/calibration_mc_mw_t8.R, loi N =
#      stats::rnorm) ; un triangle simule dont un cumul est <= 0 est COMPTE puis
#      ECARTE (aucun retirage).
#    Plans de la premiere colonne fixee (lignes 0..7, definition de #309,
#      tests/puissance_mw_t8.R : KAPPA_P2, PERM_P3) :
#        P1 = premiere colonne observee de reserve2 ;
#        P2 = Cbar0 + 3,4 (C0 - Cbar0) ;
#        P3 = P2[c(2, 8, 6, 4, 3, 5, 7, 1)].
#    N = 100 000 triangles tires par plan.
#    Graine d'un triangle : engine_sous_graine(448000000 + 1000000 k + b, ...),
#      k = 1, 2, 3 pour P1, P2, P3 et b = 1..N ; essai pilote : k = 0, b <=
#      2000. Aucun autre alea que ces tirages (engine_sous_graine(), generateur
#      ENGINE_RNG_KIND) : le resultat ne depend pas du nombre de coeurs.
#    Statistiques, par plan et par ligne : taux de rejet de la p chi2(2K) a 0,10
#      0,05 et 0,01 ; KS de p contre U(0,1) ; KS de chaque t_j contre
#      Student(n_j - 2) (ordonnee) ou Student(n_j - 3) (courbure) ; Spearman
#      entre t_j et t_k et entre |t_j| et |t_k|, toutes paires ; repartition de
#      K, triangles ecartes, duree.
#    Controle des degres de liberte (hors critere) : la p_j rendue par le moteur
#      est comparee a 2 P(T_df > |t_j|) avec df = n_j - 2 (ordonnee, regression
#      ponderee a deux parametres, summary.lm()) ou n_j - 3 (courbure, forme
#      close de .mw_courbure_colonne()) ; l'ecart absolu maximal est rapporte.
#    CRITERES, fixes avant l'execution. Niveau 0,05/m par controle, m = nombre
#      de controles de la ligne : m = 3 + 1 + K + 2 K (K - 1)/2, soit 29 pour
#      l'ordonnee (K = 5 : 3 taux, 1 KS de p, 5 KS de t_j, 20 Spearman) et 20
#      pour la courbure (K = 4 : 3 + 1 + 4 + 12) ; m est recalcule sur le K le
#      plus frequent mesure, et le tableau le dit s'il differe de K = 5 / 4.
#      - un taux est compatible si l'intervalle de Clopper-Pearson de niveau
#        1 - 0,05/m contient alpha ;
#      - un KS est compatible si sa p-value est >= 0,05/m ;
#      - une correlation est compatible si |rho| <= z_{1 - 0,025/m} /
#        sqrt(n - 1), n = nombre de triangles admis qui portent les deux
#        colonnes ;
#      - le critere est tenu si aucun controle ne rejette. C'est un constat de
#        compatibilite, pas une demonstration.
#
#  Triangles ecartes ou non retenus, comptes separement : cumul <= 0 (generateur),
#  mw_ajuster() en erreur, statistique de la ligne non definie (p NA : colonne
#  degeneree ou non identifiable dans la replication). K est la longueur du
#  tableau "detail" rendu : il peut etre inferieur au K prevu, et sa repartition
#  est donnee.
#
#  Usage (depuis la racine du depot ; LC_ALL=C.UTF-8 sous Linux, #113) :
#      Rscript tests/mesure_independance_tj_t8.R --pilote [--coeurs 3]
#      Rscript tests/mesure_independance_tj_t8.R [--coeurs 3]
#      Rscript tests/mesure_independance_tj_t8.R --ecrire [--coeurs 3]
#  --pilote : essai chronometre, k = 0, b <= 2000, trois plans (memes graines
#    pour les trois plans), NON versionnable (--ecrire refuse) ; imprime la
#    duree par triangle et la duree projetee de la mesure complete.
#  --coeurs n : processus paralleles (parallel::mclapply, une tache par bloc de
#    2 500 triangles d'un plan ; defaut 3 ; 1 sous Windows).
#  --ecrire : ecrit docs/tableaux/<AAAAMMJJ>-issue448-independance-tj.md (date
#    d'execution). REFUSE : pilote, fichier cible deja suivi par git
#    (garde_ecrasement(), #173). Contrairement aux autres scripts de mesure, un
#    arbre de travail modifie ou un script non suivi NE refuse PAS l'ecriture :
#    la ligne "Commit" du tableau cite alors le resultat de commit_depot()
#    tel quel (avec la mention d'arbre modifie ou de script non suivi) et le
#    md5 du script, que l'on verifie contre le script commite ensuite.
#  Duree : voir la ligne "Duree" de la sortie.
#  Code de sortie : 0 si l'execution va a son terme (le critere est un constat,
#  il ne conditionne pas le code de sortie), 1 en cas de controle d'implementation
#  en echec (generateur, ou graines hors plage).
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/mesure_independance_tj_t8.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113) ------------------------------
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break

# --- Options (avant tout chargement du moteur) -------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
local({
  i <- 1L
  while (i <= length(ARGS)) {
    a <- ARGS[i]
    if (a == "--coeurs") {
      if (i == length(ARGS)) stop("option --coeurs sans valeur")
      i <- i + 2L
    } else if (a %in% c("--pilote", "--ecrire")) i <- i + 1L
    else stop("option inconnue : ", a)
  }
})
OPT_PILOTE <- "--pilote" %in% ARGS
OPT_ECRIRE <- "--ecrire" %in% ARGS
if (OPT_ECRIRE && OPT_PILOTE) stop("--ecrire : refuse avec --pilote (essai, non versionnable)")
COEURS <- if ("--coeurs" %in% ARGS) suppressWarnings(as.integer(ARGS[match("--coeurs", ARGS) + 1L])) else 3L
if (is.na(COEURS) || COEURS < 1L) stop("--coeurs : entier >= 1 attendu")
if (.Platform$OS.type == "windows") COEURS <- 1L

# --- Chargement du moteur et des outils --------------------------------------
DOSSIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) dirname(f) else if (file.exists("tests/outils_tests.R")) "tests" else "."
})
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))

DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
NOM_FICHIER <- sprintf("%s-issue448-independance-tj.md", DATE_SORTIE)
CHEMIN_ECRIT <- file.path(RACINE, "docs", "tableaux", NOM_FICHIER)
if (OPT_ECRIRE) {
  if (!dir.exists(file.path(RACINE, "docs", "tableaux"))) stop("dossier de sortie introuvable : docs/tableaux")
  garde_ecrasement(CHEMIN_ECRIT, FALSE, RACINE)
}
COMMIT <- commit_depot(SCRIPT)
FICHIER_EXEC <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
MD5_SCRIPT <- if (length(FICHIER_EXEC) == 1L && file.exists(FICHIER_EXEC)) unname(tools::md5sum(FICHIER_EXEC)) else "inconnu"
MD5_MOTEUR <- unname(tools::md5sum(file.path(RACINE, "R", "engine.R")))

plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(basename(extSoftVersion()[["BLAS"]])), txt(basename(La_library())), txt(La_version()))
}
ecrire_console <- function(x) writeLines(enc2utf8(x), useBytes = TRUE)

# --- Mise en forme -----------------------------------------------------------
virg <- function(s) sub(".", ",", s, fixed = TRUE)
num <- function(x, d = 4) if (length(x) != 1L || is.na(x)) "\u2014" else virg(sprintf(paste0("%.", d, "f"), x))
pval <- function(p) if (length(p) != 1L || is.na(p)) "\u2014" else if (p < 1e-4) virg(sprintf("%.1e", p)) else num(p, 4)
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
oui_non <- function(ok) if (isTRUE(ok)) "oui" else "**non**"
fmt_entier <- function(n) formatC(n, format = "d", big.mark = "\u202f")
vec_md <- function(v, d = 4) paste(vapply(v, num, "", d = d), collapse = " ; ")

# --- Parametres ---------------------------------------------------------------
N_TRI <- if (OPT_PILOTE) 2000L else 100000L
BLOC <- 2500L                                 # triangles par tache
GRAINE_BASE <- 448000000                      # + 1000000 k + b
K_PLAN <- if (OPT_PILOTE) c(P1 = 0L, P2 = 0L, P3 = 0L) else c(P1 = 1L, P2 = 2L, P3 = 3L)
PLANS <- names(K_PLAN)
LIGNES <- c(ord = "ordonn\u00e9e \u00e0 l'origine", cour = "courbure")
K_PREVU <- c(ord = 5L, cour = 4L)             # colonnes j = 0..4 (n_j >= 3) et j = 0..3 (n_j >= 4)
DF_RETRAIT <- c(ord = 2L, cour = 3L)          # df = n_j - DF_RETRAIT
SEUILS <- c(0.10, 0.05, 0.01)
NIVEAU <- 0.05                                # niveau global par ligne, partage en 0,05/m par controle
KAPPA_P2 <- 3.4
PERM_P3 <- c(2, 8, 6, 4, 3, 5, 7, 1)
TOL_DF <- 1e-9                                # controle des degres de liberte, ecart absolu sur p_j
stopifnot(GRAINE_BASE + 1000000 * 3 + 100000 < .Machine$integer.max)

# --- Modele generateur (copies declarees de tests/puissance_mw_t8.R) ---------
AJ0 <- mw_ajuster(.tri)
stopifnot(AJ0$I == 7L, AJ0$J == 7L)
tirer_n <- function(n) stats::rnorm(n)
# Generateur du DGP de #206 : memes operations, meme ordre de consommation des
# epsilon, arret au premier cumul invalide (tri renvoye avec NA).
gen_triangle_h0 <- function(aj, tirer) {
  I <- aj$I; J <- aj$J
  tri <- matrix(NA_real_, I + 1, J + 1)
  tri[, 1] <- aj$tri[, 1]
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    sg <- sqrt(aj$sigma2[j + 1])
    if (!is.finite(sg)) sg <- 0
    e <- tirer(length(idx))
    Cij <- tri[idx + 1, j + 1]
    nv <- Cij * aj$f[j + 1] + e * sg * sqrt(Cij)
    inval <- !is.finite(nv) | nv <= 0
    if (any(inval)) {
      nv[inval] <- NA_real_
      tri[idx + 1, j + 2] <- nv
      return(tri)
    }
    tri[idx + 1, j + 2] <- nv
  }
  tri
}
C0_P1 <- AJ0$tri[, 1]
C0_P2 <- mean(C0_P1) + KAPPA_P2 * (C0_P1 - mean(C0_P1))
C0_P3 <- C0_P2[PERM_P3]
COL0 <- list(P1 = C0_P1, P2 = C0_P2, P3 = C0_P3)
AJ_PLAN <- lapply(COL0, function(col) { a <- AJ0; a$tri[, 1] <- col; a })
graine_tri <- function(plan, b) GRAINE_BASE + 1000000 * K_PLAN[[plan]] + b

# Controles de mise en place (stop() si l'un echoue) : plans et generateur.
local({
  ok <- abs(C0_P2[1] - 204) < 1e-9 && abs(C0_P2[8] - 476) < 1e-9 && abs(mean(C0_P2) - mean(C0_P1)) < 1e-9 &&
    identical(sort(PERM_P3), 1:8 + 0) && identical(COL0$P3, C0_P2[c(2, 8, 6, 4, 3, 5, 7, 1)])
  if (!ok) stop("plans P1, P2, P3 : definition de #309 non reproduite")
  # La premiere colonne du triangle genere est le plan ; le generateur est deterministe a graine fixee.
  t1 <- engine_sous_graine(1L, gen_triangle_h0(AJ_PLAN$P2, tirer_n))
  t2 <- engine_sous_graine(1L, gen_triangle_h0(AJ_PLAN$P2, tirer_n))
  if (!identical(t1, t2) || !identical(t1[, 1], C0_P2)) stop("gen_triangle_h0() : controle de determinisme ou de premiere colonne en echec")
})

# --- Calcul d'un triangle -----------------------------------------------------
# Vecteur de 23 valeurs : 1 statut (0 ok, 1 cumul <= 0, 2 ajustement en erreur),
# ordonnee : K, p, t (5 colonnes j = 0..4), p_j (5) ; courbure : K, p, t (4), p_j (4).
LARG <- 1L + (2L + 2L * K_PREVU[["ord"]]) + (2L + 2L * K_PREVU[["cour"]])
extraire <- function(r, kmax) {
  d <- r$detail
  t <- rep(NA_real_, kmax); pj <- rep(NA_real_, kmax)
  if (is.data.frame(d) && nrow(d)) { t[d$j + 1L] <- d$t; pj[d$j + 1L] <- d$p }
  K <- if (is.null(r$K)) 0 else as.numeric(r$K)
  c(K, if (is.null(r$p)) NA_real_ else r$p, t, pj)
}
un_triangle <- function(plan, b) {
  tri <- engine_sous_graine(graine_tri(plan, b), gen_triangle_h0(AJ_PLAN[[plan]], tirer_n))
  if (.mw_triangle_incomplet(tri)) return(c(1, rep(NA_real_, LARG - 1L)))
  aj <- tryCatch(mw_ajuster(tri), error = function(e) NULL)
  if (is.null(aj)) return(c(2, rep(NA_real_, LARG - 1L)))
  o <- mw_test_ordonnee_origine(aj)
  cb <- mw_test_courbure(aj)
  c(0, extraire(o, K_PREVU[["ord"]]), extraire(cb, K_PREVU[["cour"]]))
}
un_bloc <- function(plan, b1, b2) do.call(rbind, lapply(b1:b2, function(b) un_triangle(plan, b)))

# --- Execution (parallele par bloc ; le resultat ne depend pas du nombre de coeurs)
taches <- do.call(rbind, lapply(PLANS, function(pl) {
  b1 <- seq(1L, N_TRI, by = BLOC)
  data.frame(plan = pl, b1 = b1, b2 = pmin(b1 + BLOC - 1L, N_TRI), stringsAsFactors = FALSE)
}))
message(sprintf("Calcul : %d plans x %d triangles, %d coeur(s), %d taches", length(PLANS), N_TRI, COEURS, nrow(taches)))
t_calcul0 <- Sys.time()
sorties <- parallel::mclapply(seq_len(nrow(taches)),
                              function(i) un_bloc(taches$plan[i], taches$b1[i], taches$b2[i]),
                              mc.cores = COEURS, mc.preschedule = FALSE)
if (any(vapply(sorties, function(s) inherits(s, "try-error") || is.null(s), TRUE)))
  stop("tache(s) parallele(s) en echec : ", paste(which(vapply(sorties, function(s) inherits(s, "try-error") || is.null(s), TRUE)), collapse = ", "))
duree_calcul <- as.numeric(difftime(Sys.time(), t_calcul0, units = "secs"))
MAT <- lapply(stats::setNames(PLANS, PLANS), function(pl)
  do.call(rbind, sorties[taches$plan == pl]))
for (pl in PLANS) if (nrow(MAT[[pl]]) != N_TRI) stop("plan ", pl, " : ", nrow(MAT[[pl]]), " lignes au lieu de ", N_TRI)

# --- Analyse d'une ligne d'un plan --------------------------------------------
colonnes <- function(ligne) {
  off <- if (ligne == "ord") 2L else 2L + (2L + 2L * K_PREVU[["ord"]])
  km <- K_PREVU[[ligne]]
  list(K = off, p = off + 1L, t = off + 1L + seq_len(km), pj = off + 1L + km + seq_len(km))
}
z_spearman <- function(m) stats::qnorm(1 - NIVEAU / 2 / m)
analyser <- function(M, ligne) {
  cl <- colonnes(ligne); km <- K_PREVU[[ligne]]
  tire <- nrow(M)
  n_cumul <- sum(M[, 1] == 1); n_ajust <- sum(M[, 1] == 2)
  A <- M[M[, 1] == 0, , drop = FALSE]
  ok_stat <- is.finite(A[, cl$p])
  n_na <- sum(!ok_stat)
  A <- A[ok_stat, , drop = FALSE]
  n <- nrow(A)
  Kv <- A[, cl$K]
  tabK <- table(Kv)
  K_modal <- as.integer(names(tabK)[which.max(tabK)])
  m <- 3L + 1L + K_modal + 2L * choose(K_modal, 2L)
  niv <- NIVEAU / m
  p <- A[, cl$p]
  # Taux de rejet et intervalles de Clopper-Pearson de niveau 1 - 0,05/m.
  taux <- lapply(SEUILS, function(a) {
    x <- sum(p < a)
    ic <- stats::binom.test(x, n, p = a, conf.level = 1 - niv)$conf.int
    list(a = a, x = x, taux = x / n, ic = ic, ok = ic[1] <= a && a <= ic[2])
  })
  ks_p <- suppressWarnings(stats::ks.test(p, "punif"))
  Tm <- A[, cl$t, drop = FALSE]
  Pj <- A[, cl$pj, drop = FALSE]
  ks_t <- lapply(seq_len(km), function(j) {
    nj <- AJ0$I - (j - 1L); df <- nj - DF_RETRAIT[[ligne]]
    ok <- is.finite(Tm[, j]); u <- stats::pt(Tm[ok, j], df)
    kt <- suppressWarnings(stats::ks.test(u, "punif"))
    ecart <- if (any(ok)) max(abs(Pj[ok, j] - 2 * stats::pt(-abs(Tm[ok, j]), df))) else NA_real_
    list(j = j - 1L, nj = nj, df = df, n = sum(ok), D = unname(kt$statistic), p = kt$p.value,
         ok = kt$p.value >= niv, ecart_df = ecart)
  })
  # Spearman entre colonnes : toutes paires, sur t puis sur |t|.
  paires <- utils::combn(km, 2L)
  rho_paires <- function(X) {
    do.call(rbind, lapply(seq_len(ncol(paires)), function(i) {
      a <- paires[1, i]; b <- paires[2, i]
      ok <- is.finite(X[, a]) & is.finite(X[, b])
      r <- stats::cor(X[ok, a], X[ok, b], method = "spearman")
      np <- sum(ok); seuil <- z_spearman(m) / sqrt(np - 1)
      data.frame(a = a - 1L, b = b - 1L, n = np, rho = r, seuil = seuil, ratio = abs(r) / seuil)
    }))
  }
  rt <- rho_paires(Tm); ra <- rho_paires(abs(Tm))
  resume_rho <- function(r) {
    i <- which.max(r$ratio)
    list(max = max(abs(r$rho)), paire = c(r$a[i], r$b[i]), rho_ratio_max = r$rho[i], seuil = r$seuil[i],
         n_rej = sum(r$ratio > 1), npaires = nrow(r), ok = all(r$ratio <= 1))
  }
  rho_t <- resume_rho(rt); rho_a <- resume_rho(ra)
  ok_ctrl <- c(vapply(taux, `[[`, TRUE, "ok"), ks_p$p.value >= niv, vapply(ks_t, `[[`, TRUE, "ok"),
               rho_t$n_rej == 0, rho_a$n_rej == 0)
  n_ctrl_rejetes <- sum(!vapply(taux, `[[`, TRUE, "ok")) + as.integer(ks_p$p.value < niv) +
    sum(!vapply(ks_t, `[[`, TRUE, "ok")) + rho_t$n_rej + rho_a$n_rej
  list(tire = tire, n_cumul = n_cumul, n_ajust = n_ajust, n_na = n_na, n = n, tabK = tabK, K_modal = K_modal,
       m = m, niv = niv, taux = taux, ks_p = list(D = unname(ks_p$statistic), p = ks_p$p.value, ok = ks_p$p.value >= niv),
       ks_t = ks_t, rho_t = rho_t, rho_a = rho_a, n_ctrl_rejetes = n_ctrl_rejetes,
       tenu = n_ctrl_rejetes == 0L,
       ecart_df = suppressWarnings(max(vapply(ks_t, `[[`, 0, "ecart_df"), na.rm = TRUE)))
}
RES <- lapply(PLANS, function(pl) lapply(stats::setNames(names(LIGNES), names(LIGNES)), function(l) analyser(MAT[[pl]], l)))
names(RES) <- PLANS

# Controle d'implementation : les p_j du moteur sont celles d'un Student a n_j - 2
# (ordonnee) ou n_j - 3 (courbure) degres de liberte.
ECART_DF_MAX <- max(vapply(PLANS, function(pl) max(vapply(names(LIGNES), function(l) RES[[pl]][[l]]$ecart_df, 0)), 0))
DF_OK <- is.finite(ECART_DF_MAX) && ECART_DF_MAX <= TOL_DF

duree_totale <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
fmt_duree <- function(s) virg(if (s >= 3600) sprintf("%.2f h", s / 3600) else if (s >= 60) sprintf("%.1f min", s / 60) else sprintf("%.1f s", s))

# --- Pilote : duree projetee, resume console, aucun fichier --------------------
if (OPT_PILOTE) {
  ntot <- length(PLANS) * N_TRI
  proj <- duree_calcul * (100000 / N_TRI)
  ecrire_console(c(
    "## Essai pilote (k = 0, b <= 2000, trois plans, NON versionnable)", "",
    sprintf("- Dur\u00e9e du calcul : %s pour %d triangles (%s par triangle, %d c\u0153ur(s)).",
            fmt_duree(duree_calcul), ntot, sprintf("%.2f ms", 1000 * duree_calcul / ntot * COEURS), COEURS),
    sprintf("- Dur\u00e9e projet\u00e9e de la mesure compl\u00e8te (3 plans x 100 000 triangles, %d c\u0153ur(s)) : %s.",
            COEURS, fmt_duree(proj)),
    sprintf("- Contr\u00f4le des degr\u00e9s de libert\u00e9 : \u00e9cart absolu maximal sur p_j = %s (tol\u00e9rance %s) : %s.",
            sprintf("%.2e", ECART_DF_MAX), sprintf("%.0e", TOL_DF), if (DF_OK) "tenu" else "EN \u00c9CHEC"), ""))
  for (pl in PLANS) for (l in names(LIGNES)) {
    r <- RES[[pl]][[l]]
    ecrire_console(sprintf("%s, %s : tir\u00e9s %d, \u00e9cart\u00e9s cumul %d, ajustement %d, stat. non d\u00e9finie %d, admis %d ; K : %s ; m = %d ; taux %s ; KS p = %s ; max|rho(t)| = %s ; max|rho(|t|)| = %s ; contr\u00f4les rejet\u00e9s : %d",
                           pl, LIGNES[[l]], r$tire, r$n_cumul, r$n_ajust, r$n_na, r$n,
                           paste(sprintf("K=%s : %d", names(r$tabK), as.integer(r$tabK)), collapse = ", "), r$m,
                           paste(vapply(r$taux, function(t) num(t$taux, 4), ""), collapse = " / "),
                           pval(r$ks_p$p), num(r$rho_t$max, 4), num(r$rho_a$max, 4), r$n_ctrl_rejetes))
  }
  ecrire_console(c("", sprintf("Dur\u00e9e totale : %s.", fmt_duree(duree_totale))))
  quit(status = if (DF_OK) 0L else 1L)
}

# --- Sortie markdown ------------------------------------------------------------
Sx <- character(0)
add <- function(...) Sx <<- c(Sx, ...)

tableau_plan_ligne <- function(pl, l) {
  r <- RES[[pl]][[l]]; km <- K_PREVU[[l]]
  txtK <- paste(sprintf("K = %s : %s (%s %%)", names(r$tabK), fmt_entier(as.integer(r$tabK)),
                        virg(sprintf("%.2f", 100 * as.integer(r$tabK) / r$n))), collapse = " ; ")
  out <- c(sprintf("### %s \u2014 %s", pl, LIGNES[[l]]), "",
           sprintf("Triangles tir\u00e9s : %s ; \u00e9cart\u00e9s, cumul \u2264 0 : %s ; \u00e9cart\u00e9s, ajustement en erreur : %s ; statistique de la ligne non d\u00e9finie : %s ; **admis : %s**. R\u00e9partition de K : %s. K le plus fr\u00e9quent : %d (pr\u00e9vu : %d)%s ; m = %d, niveau par contr\u00f4le 0,05/m = %s.",
                   fmt_entier(r$tire), fmt_entier(r$n_cumul), fmt_entier(r$n_ajust), fmt_entier(r$n_na), fmt_entier(r$n), txtK,
                   r$K_modal, km, if (r$K_modal == km) "" else " \u2014 **m ajust\u00e9**", r$m, virg(sprintf("%.2e", r$niv))), "",
           entete_md(c("Contr\u00f4le", "Observ\u00e9", "R\u00e9f\u00e9rence (niveau 1 \u2212 0,05/m)", "Compatible")))
  for (t in r$taux)
    out <- c(out, ligne_md(sprintf("taux de rejet de la p \u03c7\u00b2(2K) \u00e0 %s", num(t$a, 2)),
                           sprintf("%s / %s = %s", fmt_entier(t$x), fmt_entier(r$n), num(t$taux, 5)),
                           sprintf("Clopper\u2013Pearson [%s ; %s] \u220b %s", num(t$ic[1], 5), num(t$ic[2], 5), num(t$a, 2)),
                           oui_non(t$ok)))
  out <- c(out, ligne_md("KS de p contre U(0, 1)", sprintf("D = %s, p = %s", num(r$ks_p$D, 5), pval(r$ks_p$p)),
                         sprintf("p \u2265 %s", virg(sprintf("%.2e", r$niv))), oui_non(r$ks_p$ok)))
  for (kt in r$ks_t)
    out <- c(out, ligne_md(sprintf("KS de t_%d contre Student(%d) (n_j = %d)", kt$j, kt$df, kt$nj),
                           sprintf("D = %s, p = %s", num(kt$D, 5), pval(kt$p)),
                           sprintf("p \u2265 %s", virg(sprintf("%.2e", r$niv))), oui_non(kt$ok)))
  for (cas in list(list("t", r$rho_t, "max abs \u03c1(t_j, t_k)"), list("a", r$rho_a, "max abs \u03c1(abs t_j, abs t_k)")))
    out <- c(out, ligne_md(sprintf("Spearman, %d paires : %s", cas[[2]]$npaires, cas[[3]]),
                           sprintf("%s (paire (%d, %d))", num(abs(cas[[2]]$max), 5), cas[[2]]$paire[1], cas[[2]]$paire[2]),
                           sprintf("seuil %s ; paires hors seuil : %d", num(cas[[2]]$seuil, 5), cas[[2]]$n_rej),
                           oui_non(cas[[2]]$ok)))
  c(out, "", sprintf("Contr\u00f4le des degr\u00e9s de libert\u00e9 (hors crit\u00e8re) : \u00e9cart absolu maximal entre p_j du moteur et 2 P(T_df > |t_j|), df = n_j \u2212 %d : %s.",
                     DF_RETRAIT[[l]], virg(sprintf("%.2e", r$ecart_df))),
    "", sprintf("**Crit\u00e8re %s** (%d contr\u00f4le(s) rejet\u00e9(s) sur %d).", if (r$tenu) "tenu" else "NON tenu", r$n_ctrl_rejetes, r$m), "")
}

add(sprintf("## Ind\u00e9pendance des t_j et loi des p-values de l'ordonn\u00e9e \u00e0 l'origine et de la courbure (M1) \u00e0 T = 8, mod\u00e8le de Mack gaussien (issue #448)"), "",
    "Statut : **constat de simulation sous un plan** (mod\u00e8le de Mack gaussien ajust\u00e9 \u00e0 `reserve2`, plans P1 \u00e0 P3 de #309), de compatibilit\u00e9 avec le r\u00e9sultat \u00ab p \u03c7\u00b2(2K) exacte sous erreurs conditionnelles gaussiennes et ann\u00e9es ind\u00e9pendantes \u00bb des fiches `mw:m1a` et `mw:m1c`, **pas une d\u00e9monstration** ni un r\u00e9sultat g\u00e9n\u00e9ral. Aucun bootstrap : les p lues sont les p \u03c7\u00b2(2K) de la combinaison de Fisher du moteur (`mw_test_ordonnee_origine()`, `mw_test_courbure()`), les t_j et p_j sont lus dans leur tableau `detail`.", "")
add("### En-t\u00eate", "",
    ligne_md("Param\u00e8tre | Valeur"), ligne_md("--- | ---"),
    ligne_md("Date", format(Sys.Date(), "%d/%m/%Y")),
    ligne_md("Plan", "plan d'`actuary`, accept\u00e9 par le mainteneur le 06/11/2026 (issue #448) ; script `tests/mesure_independance_tj_t8.R`"),
    ligne_md("Commit", sprintf("`%s`%s", COMMIT, if (grepl("^[0-9a-f]{40}$", COMMIT)) "" else
              " \u2014 ex\u00e9cution sur un arbre de travail non propre ou un script non encore suivi ; le md5 du script ci-dessous identifie le code ex\u00e9cut\u00e9")),
    ligne_md("md5 du script", sprintf("`%s`", MD5_SCRIPT)),
    ligne_md("md5 de `R/engine.R`", sprintf("`%s`", MD5_MOTEUR)),
    ligne_md("Plateforme", plateforme_calcul()),
    ligne_md("Locale", Sys.getlocale("LC_CTYPE")),
    ligne_md("G\u00e9n\u00e9rateur", sprintf("`engine_sous_graine()`, `ENGINE_RNG_KIND` = %s", paste(unlist(ENGINE_RNG_KIND), collapse = ", "))),
    ligne_md("Graines", sprintf("une par triangle : `%d + 1000000 k + b`, k = 1, 2, 3 pour P1, P2, P3, b = 1..N (plage %s \u00e0 %s) ; essai pilote : k = 0, b \u2264 2 000 ; aucun autre al\u00e9a",
                                as.integer(GRAINE_BASE), fmt_entier(GRAINE_BASE + 1000001), fmt_entier(GRAINE_BASE + 3000000 + N_TRI))),
    ligne_md("N", sprintf("%s triangles tir\u00e9s par plan, %s au total", fmt_entier(N_TRI), fmt_entier(N_TRI * length(PLANS)))),
    ligne_md("Dur\u00e9e", sprintf("calcul : %s (%d c\u0153ur(s), `parallel::mclapply`, blocs de %s triangles) ; ex\u00e9cution compl\u00e8te : %s ; le r\u00e9sultat ne d\u00e9pend pas du nombre de c\u0153urs (graine par triangle)",
                                   fmt_duree(duree_calcul), COEURS, fmt_entier(BLOC), fmt_duree(duree_totale))),
    ligne_md("Mod\u00e8le g\u00e9n\u00e9rateur", sprintf("Mack gaussien ajust\u00e9 \u00e0 `reserve2` (`mw_ajuster()` sur `tests/donnees/triangle_mw.csv`), I = J = %d ; f\u0302 = (%s) ; \u03c3\u0302\u00b2 = (%s), non r\u00e9estim\u00e9s ; g\u00e9n\u00e9rateur `gen_triangle_h0()` (copie d\u00e9clar\u00e9e de `tests/puissance_mw_t8.R`), \u03b5 ~ N(0, 1) par `stats::rnorm` ; triangle \u00e0 cumul \u2264 0 compt\u00e9 puis \u00e9cart\u00e9",
                                          AJ0$I, vec_md(AJ0$f, 6), vec_md(AJ0$sigma2, 4))),
    ligne_md("Plans (premi\u00e8re colonne fix\u00e9e, lignes 0..7)", sprintf("P1 = (%s) ; P2 = C\u0304\u2080 + 3,4 (C\u2080 \u2212 C\u0304\u2080) = (%s) ; P3 = P2[c(2, 8, 6, 4, 3, 5, 7, 1)] = (%s)",
                                                              vec_md(C0_P1, 4), vec_md(C0_P2, 4), vec_md(C0_P3, 4))),
    ligne_md("Lignes", sprintf("ordonn\u00e9e \u00e0 l'origine : colonnes j = 0..4 (n_j = 7..3), K = 5, t_j ~ Student(n_j \u2212 2) ; courbure : colonnes j = 0..3 (n_j = 7..4), K = 4, t_j ~ Student(n_j \u2212 3)")),
    ligne_md("Contr\u00f4le des degr\u00e9s de libert\u00e9", sprintf("p_j du moteur \u2194 2 P(T_df > abs t_j), df = n_j \u2212 2 (ordonn\u00e9e) ou n_j \u2212 3 (courbure) : \u00e9cart absolu maximal %s sur les six (plan, ligne), tol\u00e9rance %s : %s",
                                                      virg(sprintf("%.2e", ECART_DF_MAX)), virg(sprintf("%.0e", TOL_DF)), if (DF_OK) "tenu" else "**EN \u00c9CHEC**")), "")
add("### Crit\u00e8res, fix\u00e9s avant l'ex\u00e9cution", "",
    "- Niveau 0,05/m par contr\u00f4le ; m = 3 (taux) + 1 (KS de p) + K (KS des t_j) + K(K \u2212 1) (Spearman sur t et sur |t|, K(K \u2212 1)/2 paires chacun) : m = 29 pour l'ordonn\u00e9e (K = 5), m = 20 pour la courbure (K = 4) ; m est recalcul\u00e9 sur le K le plus fr\u00e9quent mesur\u00e9 et signal\u00e9 s'il diff\u00e8re.",
    "- Un taux est compatible si l'intervalle de Clopper\u2013Pearson de niveau 1 \u2212 0,05/m contient \u03b1 (0,10 ; 0,05 ; 0,01).",
    "- Un KS (p contre U(0, 1) ; chaque t_j contre sa Student, par la transformation pt(t_j, df)) est compatible si sa p-value est \u2265 0,05/m ; p-value asymptotique de `ks.test()` (n > 100).",
    "- Une corr\u00e9lation de Spearman est compatible si |\u03c1| \u2264 z\u2081\u208b\u2080,\u2080\u2082\u2085/\u2098 / \u221a(n \u2212 1), n = triangles admis portant les deux colonnes.",
    "- Le crit\u00e8re est tenu si aucun contr\u00f4le ne rejette. C'est un constat de compatibilit\u00e9, pas une d\u00e9monstration.", "")

add("### Synth\u00e8se", "",
    entete_md(c("Plan", "Ligne", "Admis", "K le plus fr\u00e9quent", "m", "Taux \u00e0 0,10 / 0,05 / 0,01", "KS de p (p-value)", "max abs \u03c1(t) (seuil)", "max abs \u03c1(abs t) (seuil)", "Contr\u00f4les rejet\u00e9s", "Crit\u00e8re")))
for (pl in PLANS) for (l in names(LIGNES)) {
  r <- RES[[pl]][[l]]
  add(ligne_md(pl, LIGNES[[l]], fmt_entier(r$n), r$K_modal, r$m,
               paste(vapply(r$taux, function(t) num(t$taux, 4), ""), collapse = " / "),
               pval(r$ks_p$p),
               sprintf("%s (%s)", num(r$rho_t$max, 4), num(r$rho_t$seuil, 4)),
               sprintf("%s (%s)", num(r$rho_a$max, 4), num(r$rho_a$seuil, 4)),
               r$n_ctrl_rejetes, if (r$tenu) "**tenu**" else "**non tenu**"))
}
add("")
n_tenus <- sum(vapply(PLANS, function(pl) sum(vapply(names(LIGNES), function(l) RES[[pl]][[l]]$tenu, TRUE)), 0L))
add(sprintf("Crit\u00e8re tenu pour %d des %d couples (plan, ligne).", n_tenus, length(PLANS) * length(LIGNES)), "")
for (pl in PLANS) for (l in names(LIGNES)) add(tableau_plan_ligne(pl, l))

add("### Limites", "",
    "- Un constat de compatibilit\u00e9 \u00e0 N = 100 000 par plan : un \u00e9cart plus petit que la puissance de la mesure ne s'y voit pas, et une corr\u00e9lation de Spearman nulle n'\u00e9tablit pas l'ind\u00e9pendance des t_j.",
    "- Sous le seul mod\u00e8le de Mack gaussien ajust\u00e9 \u00e0 `reserve2` (f et \u03c3\u00b2 fix\u00e9s) et les trois plans de la premi\u00e8re colonne : aucun r\u00e9sultat pour une autre forme de triangle, ni sous des erreurs non gaussiennes.",
    "- Les triangles \u00e0 cumul \u2264 0 sont \u00e9cart\u00e9s, non retir\u00e9s : la loi mesur\u00e9e est celle conditionnelle \u00e0 des cumuls strictement positifs (effet de l'\u00e9cart non mesur\u00e9 s\u00e9par\u00e9ment).",
    "- Les niveaux 0,05/m sont des seuils de Bonferroni par ligne ; il n'est pas fait de correction entre les six couples (plan, ligne).", "")

sortie <- Sx
ecrire_console(c(sortie, sprintf("Dur\u00e9e totale : %s.", fmt_duree(duree_totale))))
if (OPT_ECRIRE) {
  garde_ecrasement(CHEMIN_ECRIT, FALSE, RACINE)
  con <- file(CHEMIN_ECRIT, "wb")
  writeLines(enc2utf8(sortie), con, useBytes = TRUE)
  close(con)
  message("Tableau \u00e9crit : docs/tableaux/", NOM_FICHIER)
}
quit(status = if (DF_OK) 0L else 1L)
