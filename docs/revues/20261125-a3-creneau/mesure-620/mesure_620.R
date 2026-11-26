###############################################################################
#  mesure_620.R -- mesure de #620 (A3, etape 3)
#
#  Question : sur un trapeze dont la colonne J-1 est degeneree a l'observe,
#  la p-value de Monte-Carlo d'Alpha est majoree. Deux pistes sont
#  prototypees et comparees au moteur tel quel (V0) :
#    Va : Alpha recoit l'ensemble fige des colonnes degenerees (piste (a)) ;
#    Vb : la colonne J-1 degeneree est simulee par l'estimateur direct
#         (piste (b)).
#
#  Specification : docs/revues/20261125-a3-creneau/actuary-1-specification-620.md,
#  section 3 (criteres de decision : section 2, ecrits avant la mesure ;
#  PA-1 approuve par le mainteneur). Base : mesure_617.R (#617).
#
#  Commande, depuis la racine du depot :
#    LC_ALL=C.UTF-8 Rscript docs/revues/20261125-a3-creneau/mesure-620/mesure_620.R \
#      > docs/revues/20261125-a3-creneau/mesure-620/sortie_mesure_620.txt 2>&1
#  Options (defauts) : --B=999 --graine=20260831 --graine2=20261125
#                      --triangles=T0,T1,T2,T3,K1,KA,R2,R2T
#  --essai : pre-vol (B = 99), en-tete "ESSAI, NON VERSABLE" ; les durees
#  ne sont pas imprimees, pour que deux pre-vols se comparent au bit.
#
#  Le script ne modifie aucun fichier du depot. Il charge le moteur par
#  charger_moteur() (ADR 0016) ; les variantes et les crochets de lecture
#  sont des substitutions dans environment(run_engine), retirees par
#  tryCatch(finally =) apres chaque execution, meme en cas d'erreur. Il ne
#  tire rien lui-meme : toute l'aleatoire passe par run_engine(seed =), donc
#  par engine_sous_graine().
###############################################################################

T_DEBUT <- Sys.time()
options(width = 200)   # impression des triangles sur une seule bande

# --- Constantes du protocole (par. 3 de la specification) ---------------------
MD5_ENGINE_ATTENDU <- "723277ddfa5736d7411838d15d8dad00"   # I3
TOL_DEG     <- 1e-12       # tolerance du predicat ; quasi-egalite de Gb1 et Ga1
DATE_REF    <- "2026-12-31"
ALPHA_V     <- 0.10        # seuil des verdicts compares (M-b, M-d, Gb2)
N_I9        <- 50L         # I9, Va : premieres replications du journal
B_PROTOCOLE <- 999
B_ESSAI     <- 99
GRAINE_DEF  <- 20260831
GRAINE2_DEF <- 20261125
TRI_TOUS    <- c("T0", "T1", "T2", "T3", "K1", "KA", "R2", "R2T")
TRI_JOURNAL <- c("T0", "T1", "T2", "K1")        # par. 3.2, journal (V0)
TRI_ISSUE   <- c("T0", "T1", "T2")              # Gb1, Ga1, I4
TRI_GB2     <- c("T0", "T1", "T2", "T3")
TRI_GB4     <- c("T1", "T2", "T3")
TRI_GB3_RES <- c("R2", "R2T", "K1", "KA")
TRI_GA3_RES <- c("R2", "R2T", "T3")
TRI_MH      <- c("T1", "T2")                    # M-h, graine secondaire
TRI_I5B     <- c("T0", "T1", "T2", "R2T")       # critere 3 de l'etape 3
REF_FICHIERS <- c(R2 = "tests/reference/reserve2.rds",
                  R2T = "tests/reference/reserve2_trapeze.rds")
# I4 : reproduction de #617 (N_moteur, N_sans, p_moteur, p_sans a 3 decimales).
I4_ATTENDU <- list(T1 = c(7, 6, 0.008, 0.007), T2 = c(22, 9, 0.023, 0.010),
                   T0 = c(15, 15, 0.016, 0.016))
# M-f : rapport Sum n / Sum' n attendu (numerateur, denominateur).
RAPPORT_ATTENDU <- list(T1 = c(25, 22), T2 = c(22, 18), K1 = c(25, 20))
# I6 : preconditions du tableau du par. 3.3 (regle et direct a la precision
# imprimee dans le tableau ; NULL : non verifie ; "absent" : champ absent).
I6_ATTENDU <- list(
  T1  = list(I = 7, J = 5, deg = 4L, cas = "degenere", regle = "0.141928", direct = "0", alpha = 0:4),
  T2  = list(I = 7, J = 4, deg = 3L, cas = "degenere", regle = "0.684464", direct = "0", alpha = 0:3),
  T0  = list(I = 7, J = 5, deg = c(2L, 4L), cas = "degenere", regle = "7.8e-29", direct = "1.2e-28",
             alpha = NULL),
  T3  = list(I = 7, J = 6, deg = 5L, cas = "degenere", regle = "0.0300913", direct = "0", alpha = 0:4),
  K1  = list(I = 7, J = 7, deg = c(2L, 6L), cas = "carre", regle = "0.0974525", direct = "absent",
             alpha = 0:4),
  KA  = list(I = 7, J = 7, deg = c(0:4, 6L), cas = "carre", regle = NULL, direct = "absent",
             alpha = 0:4, alpha_toutes_figees = TRUE),
  R2  = list(I = 7, J = 7, deg = 6L, cas = "carre", regle = "0.0973248", direct = "absent", alpha = 0:4),
  R2T = list(I = 7, J = 5, deg = integer(0), cas = "simulation", regle = "0.141928",
             direct = "0.0973248", alpha = 0:4))

# --- Arguments ----------------------------------------------------------------
lire_args <- function(args) {
  o <- list(B = B_PROTOCOLE, graine = GRAINE_DEF, graine2 = GRAINE2_DEF,
            triangles = TRI_TOUS, essai = FALSE)
  b_saisi <- FALSE
  for (a in args) {
    if (identical(a, "--essai")) o$essai <- TRUE
    else if (grepl("^--B=", a)) {
      o$B <- suppressWarnings(as.numeric(sub("^--B=", "", a))); b_saisi <- TRUE
    } else if (grepl("^--graine=", a)) o$graine <- suppressWarnings(as.numeric(sub("^--graine=", "", a)))
    else if (grepl("^--graine2=", a)) o$graine2 <- suppressWarnings(as.numeric(sub("^--graine2=", "", a)))
    else if (grepl("^--triangles=", a))
      o$triangles <- strsplit(sub("^--triangles=", "", a), ",", fixed = TRUE)[[1]]
    else stop("argument inconnu : ", a)
  }
  if (o$essai && b_saisi) stop("--essai fixe B = ", B_ESSAI, " : ne pas le combiner avec --B")
  if (o$essai) o$B <- B_ESSAI
  if (length(o$B) != 1L || !is.finite(o$B) || o$B < 1 || o$B != round(o$B))
    stop("--B doit etre un entier >= 1")
  for (g in c("graine", "graine2"))
    if (length(o[[g]]) != 1L || !is.finite(o[[g]])) stop("--", g, " doit etre un nombre")
  if (!length(o$triangles) || anyDuplicated(o$triangles) || !all(o$triangles %in% TRI_TOUS))
    stop("--triangles : sous-ensemble sans doublon de ", paste(TRI_TOUS, collapse = ","))
  o$triangles <- TRI_TOUS[TRI_TOUS %in% o$triangles]   # ordre du protocole
  o
}
OPT <- lire_args(commandArgs(trailingOnly = TRUE))
VERSABLE <- !OPT$essai && OPT$B == B_PROTOCOLE && OPT$graine == GRAINE_DEF &&
  OPT$graine2 == GRAINE2_DEF && identical(OPT$triangles, TRI_TOUS)
DEFAUT_REF <- OPT$B == B_PROTOCOLE && OPT$graine == GRAINE_DEF   # I4, I5 evaluables

# --- Racine et moteur ---------------------------------------------------------
if (!file.exists("R/engine.R"))
  stop("lancer depuis la racine du depot (R/engine.R introuvable)")
GRAINE_GLOBALE_0 <- if (exists(".Random.seed", envir = globalenv(), inherits = FALSE))
  get(".Random.seed", envir = globalenv()) else NULL                    # I8
source("R/charger_moteur.R")
charger_moteur()
env <- environment(run_engine)

# Liaisons substituees (variantes et crochets) : originaux pris une fois.
NOMS_LIAISONS <- c("mw_famille_alpha", "MW_CATALOGUE_MC", ".mw_simulation_sigma_direct",
                   ".mw_stats", ".mw_tirer_triangle_valide")
ORIG <- mget(NOMS_LIAISONS, envir = env, inherits = FALSE)

# --- Utilitaires de sortie (ASCII) --------------------------------------------
sortie <- function(...) cat(..., "\n", sep = "")
titre  <- function(s) sortie("\n", s, "\n", strrep("-", nchar(s)))
grand_titre <- function(s) sortie("\n", strrep("=", 79), "\n", s, "\n", strrep("=", 79))
# Formats element par element (aucun alignement commun entre elements).
f17    <- function(x) if (is.null(x)) "absent" else if (!length(x)) "-" else
  vapply(x, function(v) format(v, digits = 17), "", USE.NAMES = FALSE)
f6     <- function(x) if (is.null(x)) "absent" else if (!length(x)) "-" else
  vapply(x, function(v) format(v, digits = 6), "", USE.NAMES = FALSE)
ok_ko  <- function(x) if (is.na(x)) "SANS OBJET" else if (isTRUE(x)) "OK" else "ECHEC"
ok_nev <- function(x) if (is.na(x)) "NON EVALUABLE" else ok_ko(x)
vec    <- function(x) if (!length(x)) "{}" else paste0("{", paste(x, collapse = ", "), "}")
duree  <- function(t) if (OPT$essai) "(duree omise en essai)" else
  sprintf("%.1f s", as.numeric(difftime(Sys.time(), t, units = "secs")))
# Conjonction de controles : NA (sans objet) ignore ; NA si tout est NA.
tous <- function(x) {
  x <- unlist(x)
  if (!length(x) || all(is.na(x))) return(NA)
  all(x[!is.na(x)])
}

# Champs retires avant toute comparaison identical() : horodatage, duree et
# version de R (recopie de nettoyer(), tests/outils_tests.R).
nettoyer <- function(res) {
  if (is.list(res$metadata)) res$metadata[c("horodatage", "duree_sec", "version_R")] <- NULL
  res
}

# --- Lecture et construction des triangles (par. 3.3) -------------------------
# Lecture comme tests/outils_tests.R (code recopie).
lire_csv_triangle <- function(fichier) {
  df <- utils::read.csv(file.path("tests", "donnees", fichier))
  m <- as.matrix(df[, setdiff(names(df), "i")])
  storage.mode(m) <- "double"
  unname(m)
}
# Colonne J-1 rendue degeneree : C(i,J) := C(i,J-1) * f_(J-1), i = 0..I-J
# (f_(J-1) du triangle recu), comme T1 et T2 de mesure_617.R.
degenerer_derniere <- function(tri) {
  aj <- mw_ajuster(tri); I <- aj$I; J <- aj$J
  for (i in 0:(I - J)) tri[i + 1, J + 1] <- tri[i + 1, J] * aj$f[J]
  tri
}
# Colonne j (j <= J-2) rendue degeneree : pour i = 0..I-j-1, les colonnes
# j+1..J de la ligne i sont multipliees par f_j * C(i,j) / C(i,j+1) (f_j du
# triangle recu) ; les facteurs des colonnes suivantes sont inchanges. C'est
# l'operation de T0 dans mesure_617.R (j = 2, i = 0..4), ecrite pour tout j.
degenerer_colonne <- function(tri, j) {
  aj <- mw_ajuster(tri); fj <- aj$f[j + 1]; nc <- ncol(tri)
  for (i in 0:(aj$I - j - 1)) {
    r <- fj * tri[i + 1, j + 1] / tri[i + 1, j + 2]
    tri[i + 1, (j + 2):nc] <- tri[i + 1, (j + 2):nc] * r
  }
  tri
}
construire_triangles <- function() {
  tri_trap <- lire_csv_triangle("triangle_mw_trapeze.csv")
  tri_mw   <- lire_csv_triangle("triangle_mw.csv")
  T1 <- degenerer_derniere(tri_trap)
  T2 <- degenerer_derniere(tri_mw[, 1:5])
  T0 <- degenerer_colonne(T1, 2L)
  T3 <- degenerer_derniere(tri_mw[, 1:7])
  K1 <- degenerer_colonne(tri_mw, 2L)
  # KA : colonnes 0 a 4 rendues degenerees l'une apres l'autre, dans l'ordre
  # j = 0, 1, ..., 4, f_j etant lu a chaque pas sur le triangle courant.
  KA <- tri_mw
  for (j in 0:4) KA <- degenerer_colonne(KA, j)
  list(T0 = T0, T1 = T1, T2 = T2, T3 = T3, K1 = K1, KA = KA, R2 = tri_mw, R2T = tri_trap)
}
# Construction de T0 recopiee de mesure_617.R, l. 94-100 (controle de
# l'ecriture generale ci-dessus, imprime avec I6).
t0_comme_617 <- function(T1) {
  aj1 <- mw_ajuster(T1); f2 <- aj1$f[3]; T0 <- T1
  for (i in 0:4) {
    r <- f2 * T0[i + 1, 3] / T0[i + 1, 4]
    T0[i + 1, 4:6] <- T0[i + 1, 4:6] * r
  }
  T0
}

# --- Variantes (par. 3.2) -----------------------------------------------------
# Va : corps impose par la specification, par. 3.2 (prototype (a-i) : A = NA
# sans colonne restante).
alpha_va <- function(aj, j_degeneres = NULL) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  jd <- .mw_j_exclues(aj, j_degeneres)
  blocs <- list()
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 3 || j %in% jd) next
    C0 <- tri[idx + 1, j + 1]; F <- tri[idx + 1, j + 2] / C0
    f <- vapply(c(0, 1, 2), function(a) sum(C0^a * F) / sum(C0^a), numeric(1))
    blocs[[length(blocs) + 1L]] <- list(j = j, n = length(idx), f0 = f[1], f1 = f[2],
                                        f2 = f[3], amplitude = (max(f) - min(f)) / f[2])
  }
  det <- .mw_empiler(blocs)
  if (!nrow(det)) return(list(stat = NA_real_, detail = det))
  list(stat = sum(det$n * det$amplitude) / sum(det$n), detail = det)
}
environment(alpha_va) <- env
calc_alpha_va <- function(e) mw_famille_alpha(e$aj, e$figes$degeneres)$stat
environment(calc_alpha_va) <- env
catalogue_va <- ORIG$MW_CATALOGUE_MC
catalogue_va$Alpha <- .mc_entree(calc_alpha_va, "haut")
# Vb : tout trapeze simule avec son estimateur direct.
sim_direct_vb <- function(aj) !is.null(aj[["sigma2_Jm1_direct"]])
environment(sim_direct_vb) <- env
VARIANTES <- list(V0 = list(),
                  Va = list(mw_famille_alpha = alpha_va, MW_CATALOGUE_MC = catalogue_va),
                  Vb = list(.mw_simulation_sigma_direct = sim_direct_vb))

# --- Crochets de lecture (aucun tirage, aucun calcul change) ------------------
# Journal (V0 ; T0, T1, T2, K1) : triangle, ensembles figes et statistiques
# de chaque replication, comme dans mesure_617.R.
crochet_journal <- function(j) function(aj, figes = NULL, replique = FALSE, combn = NULL) {
  r <- ORIG$.mw_stats(aj, figes, replique, combn)
  if (isTRUE(replique))
    j$stats[[length(j$stats) + 1L]] <- list(tri = aj$tri, figes = figes, stats = r)
  r
}
# Vb : predicat de la colonne J-1 de chaque replication (Gb4) et sigma2_(J-1)
# recu par .mw_tirer_triangle_valide() (I9).
crochet_vb_stats <- function(j) function(aj, figes = NULL, replique = FALSE, combn = NULL) {
  r <- ORIG$.mw_stats(aj, figes, replique, combn)
  if (isTRUE(replique)) j$deg <- c(j$deg, .mw_colonne_degeneree(aj, aj$J - 1L))
  r
}
crochet_vb_tirer <- function(j) function(aj, pool, reste) {
  j$sig <- c(j$sig, aj$sigma2[aj$J])
  ORIG$.mw_tirer_triangle_valide(aj, pool, reste)
}

# --- Execution d'une variante -------------------------------------------------
# liaisons : substitutions de la variante et crochets ; retirees en toute
# circonstance. restaure (I2) : chaque liaison de NOMS_LIAISONS identique a
# l'originale apres l'execution.
executer <- function(tri, graine, liaisons = list(), moteur = NULL) {
  t0 <- Sys.time()
  appel <- function(f) f(methode = "reserve2", triangle = tri, segment = 1, annexe = "II",
                         date_reference = DATE_REF, B = OPT$B, seed = graine)
  res <- tryCatch({
    if (is.null(moteur)) {
      for (n in names(liaisons)) assign(n, liaisons[[n]], envir = env)
      appel(run_engine)
    } else appel(moteur$run_engine)
  }, error = function(e) e,
  finally = for (n in names(liaisons)) assign(n, ORIG[[n]], envir = env))
  restaure <- all(vapply(NOMS_LIAISONS, function(n)
    identical(get(n, envir = env, inherits = FALSE), ORIG[[n]]), logical(1)))
  err <- inherits(res, "error")
  list(res = if (err) NULL else nettoyer(res), erreur = if (err) conditionMessage(res) else NA_character_,
       ok = !err && isTRUE(res$ok), restaure = restaure, t = t0,
       secs = as.numeric(difftime(Sys.time(), t0, units = "secs")), graine = graine)
}

# --- Controle I3 (md5 du moteur, etat du depot) -------------------------------
controle_i3 <- function() {
  md5 <- unname(tools::md5sum("R/engine.R"))
  st <- tryCatch(system2("git", c("status", "--porcelain", "--", "R/", "tests/", "app.R"),
                         stdout = TRUE, stderr = TRUE),
                 error = function(e) paste("git indisponible :", conditionMessage(e)))
  git_ok <- length(st) == 0L && is.null(attr(st, "status"))
  list(md5 = md5, md5_ok = identical(md5, MD5_ENGINE_ATTENDU), git = st, git_ok = git_ok,
       ok = identical(md5, MD5_ENGINE_ATTENDU) && git_ok)
}

# --- Accesseurs ---------------------------------------------------------------
lignes_mc <- function(res, cle) Filter(function(l) identical(l$mc_nom, cle), res$tests)
ligne_mc <- function(res, cle) { l <- lignes_mc(res, cle); if (length(l)) l[[1]] else NULL }
lignes_famille <- function(res) Filter(function(l) identical(l$fonction, "engine_p_famille"), res$tests)
cle_famille <- function(l) if (identical(l$famille, FAMILLE_LECTURE_CONJOINTE)) "LC" else substr(l$famille, 1, 2)
p_famille <- function(res, cle) {
  for (l in lignes_famille(res)) if (identical(cle_famille(l), cle)) return(l$p_mc)
  NA_real_
}
# Decomposition de la p de famille (M-c) : engine_p_famille() reappele sur les
# lignes et le bootstrap du resultat (le catalogue ne fournit que les sens de
# rejet, identiques dans les trois variantes).
decomposer_familles <- function(res) {
  fs <- engine_p_famille(res$tests, res$bootstrap, MW_CATALOGUE_MC)
  out <- lapply(fs, function(f) list(
    cle = if (identical(f$args$fam, FAMILLE_LECTURE_CONJOINTE)) "LC" else substr(f$args$fam, 1, 2),
    p = f$args$p_mc_ext, m_obs = f$args$stat, membres = f$membres, B_eff = f$B_eff,
    N = f$N, num_obs = f$num_obs, num_m_obs = f$num_m_obs, num_p = f$num_p))
  stats::setNames(out, vapply(out, function(o) o$cle, ""))
}
# Intervalles d'alpha ou le verdict d'une ligne "ne pas rejeter" differe entre
# deux p (regle de add() : ECHEC si p < alpha/2, ALERTE si alpha/2 <= p <
# alpha, OK sinon) : ]p1 ; p2] U ]2 p1 ; 2 p2], bornes a ]bas ; haut[.
intervalles_alpha <- function(pa, pb, bas, haut) {
  if (!is.finite(pa) || !is.finite(pb)) return("sans objet (p non finie)")
  if (pa == pb) return("aucun (p egales)")
  p1 <- min(pa, pb); p2 <- max(pa, pb)
  iv <- list(c(p1, p2), c(2 * p1, 2 * p2))
  if (iv[[2]][1] <= iv[[1]][2]) iv <- list(c(p1, 2 * p2))     # reunion
  txt <- character(0)
  for (x in iv) {
    lo <- max(x[1], bas); hi <- min(x[2], haut)
    if (lo < hi) txt <- c(txt, sprintf("]%s ; %s%s", f6(lo), f6(hi), if (hi < x[2]) "[" else "]"))
  }
  if (!length(txt)) "aucun dans l'intervalle" else paste(txt, collapse = " U ")
}
# Arrondi a la precision imprimee dans le tableau du par. 3.3 (I6).
chiffres_signif <- function(s) {
  m <- sub("[eE].*$", "", s); m <- gsub("[.-]", "", m); m <- sub("^0+", "", m)
  max(1L, nchar(m))
}
conforme_arrondi <- function(x, s) {
  if (is.null(x) || !is.finite(x)) return(FALSE)
  att <- as.numeric(s)
  if (att == 0) return(x == 0)
  isTRUE(all.equal(signif(x, chiffres_signif(s)), att, tolerance = 1e-12))
}
sans <- function(det, jd) {
  if (!nrow(det)) return(NA_real_)
  d <- det[!(det$j %in% jd), , drop = FALSE]
  if (!nrow(d)) NA_real_ else sum(d$n * d$amplitude) / sum(d$n)
}
imprimer_detail_alpha <- function(det, marge = "    ") {
  if (!nrow(det)) { sortie(marge, "(table vide)"); return(invisible()) }
  for (k in seq_len(nrow(det)))
    sortie(marge, sprintf("j = %d ; n = %d ; f0 = %s ; f1 = %s ; f2 = %s ; amplitude = %s",
                          det$j[k], det$n[k], f17(det$f0[k]), f17(det$f1[k]), f17(det$f2[k]),
                          f17(det$amplitude[k])))
}

###############################################################################
#  PHASE 1 : EXECUTIONS
###############################################################################
tris <- construire_triangles()
I3_DEBUT <- controle_i3()
RUNS <- list()
JOURNAL <- list()
JVB <- list()
# Ordre des executions (par. 3.4, I1 : V0 au debut et a la fin, apres toutes
# les variantes) : 1. V0 et V0 avec journal de tous les triangles ; 2. Va et
# Vb de tous les triangles, puis Vb sans crochets sur T1 ; 3. M-h ; 4. V0 de
# fin de tous les triangles ; 5. moteur charge a part.
for (nm in OPT$triangles) {
  tri <- tris[[nm]]
  RUNS[[nm]] <- list()
  RUNS[[nm]]$V0 <- executer(tri, OPT$graine)
  if (nm %in% TRI_JOURNAL) {
    jr <- new.env(); jr$stats <- list()
    RUNS[[nm]]$V0j <- executer(tri, OPT$graine, list(.mw_stats = crochet_journal(jr)))
    JOURNAL[[nm]] <- jr$stats
  }
}
for (nm in OPT$triangles) {
  tri <- tris[[nm]]
  RUNS[[nm]]$Va <- executer(tri, OPT$graine, VARIANTES$Va)
  jb <- new.env(); jb$sig <- numeric(0); jb$deg <- logical(0)
  RUNS[[nm]]$Vb <- executer(tri, OPT$graine,
                            c(VARIANTES$Vb, list(.mw_stats = crochet_vb_stats(jb),
                                                 .mw_tirer_triangle_valide = crochet_vb_tirer(jb))))
  JVB[[nm]] <- list(sig = jb$sig, deg = jb$deg)
}
# I9 (crochets de Vb sans effet) : Vb sans crochets sur T1.
RUN_VB_NU <- if ("T1" %in% OPT$triangles) executer(tris$T1, OPT$graine, VARIANTES$Vb) else NULL
# M-h : graine secondaire.
MH <- list()
for (nm in intersect(TRI_MH, OPT$triangles)) {
  MH[[nm]] <- list(V0 = executer(tris[[nm]], OPT$graine2),
                   Va = executer(tris[[nm]], OPT$graine2, VARIANTES$Va),
                   Vb = executer(tris[[nm]], OPT$graine2, VARIANTES$Vb))
}
# I1 : V0 rejoue apres toutes les variantes.
for (nm in OPT$triangles) RUNS[[nm]]$V0f <- executer(tris[[nm]], OPT$graine)
# Critere 3 de l'etape 3 : moteur charge a part, jamais substitue.
I5B <- list()
tri_i5b <- intersect(TRI_I5B, OPT$triangles)
if (length(tri_i5b)) {
  moteur_frais <- charger_moteur(dans = NULL)
  for (nm in tri_i5b) I5B[[nm]] <- executer(tris[[nm]], OPT$graine, moteur = moteur_frais)
}
I3_FIN <- controle_i3()
GRAINE_GLOBALE_1 <- if (exists(".Random.seed", envir = globalenv(), inherits = FALSE))
  get(".Random.seed", envir = globalenv()) else NULL

###############################################################################
#  PHASE 2 : MESURES ET CONTROLES
###############################################################################
sortie("MESURE DE #620 -- A3, etape 3 -- specification actuary-1-specification-620.md, par. 3")
if (OPT$essai) sortie("*** ESSAI, NON VERSABLE (B = ", OPT$B, ") ***")
if (!OPT$essai && !VERSABLE) sortie("*** NON VERSABLE (parametres hors protocole) ***")
sortie("B = ", OPT$B, " ; graine = ", format(OPT$graine, scientific = FALSE),
       " ; graine secondaire = ", format(OPT$graine2, scientific = FALSE),
       " ; triangles = ", paste(OPT$triangles, collapse = ","))
sortie("I3 au depart : md5 de R/engine.R = ", I3_DEBUT$md5, " : ", ok_ko(I3_DEBUT$md5_ok),
       " ; git status --porcelain -- R/ tests/ app.R vide : ", ok_ko(I3_DEBUT$git_ok))
sortie("Variantes : V0 (moteur tel quel) ; Va (mw_famille_alpha et entree Alpha de ",
       "MW_CATALOGUE_MC substituees) ; Vb (.mw_simulation_sigma_direct substituee).")

CLES <- names(ORIG$MW_CATALOGUE_MC)
CLES12 <- setdiff(CLES, "Alpha")
QUEUES <- vapply(ORIG$MW_CATALOGUE_MC, function(e) e$queue, "")
CTRL <- list(I1 = list(), I2 = list(), I6 = list(), I7 = list(), I8 = list(), I9 = list(),
             I4 = list())
G <- list(Gb1 = list(), Gb2 = list(), Gb3 = list(), Gb4 = list(),
          Ga1 = list(), Ga2 = list(), Ga3 = list(), Ga4 = list())
INFO <- list()   # grandeurs reprises par la synthese

for (nm in OPT$triangles) {
  grand_titre(sprintf("TRIANGLE %s", nm))
  tri <- tris[[nm]]
  aj <- mw_ajuster(tri); I <- aj$I; J <- aj$J
  figes <- .mw_ensembles_figes(aj); jd <- figes$degeneres
  regle <- aj$sigma2[J]; direct <- aj[["sigma2_Jm1_direct"]]
  cas <- .mw_cas_sigma_direct(aj)
  fa_obs <- mw_famille_alpha(aj)
  att <- I6_ATTENDU[[nm]]
  rr <- RUNS[[nm]]
  INFO[[nm]] <- list()

  # En-tete ------------------------------------------------------------------
  sortie("Triangle (format 17 chiffres), I = ", I, ", J = ", J, " :")
  m <- tri; dimnames(m) <- list(paste0("i", 0:I), paste0("j", 0:J))
  print(format(m, digits = 17), quote = FALSE)
  sortie("sigma2_j (j = 0..J-1) : ", paste(f17(aj$sigma2), collapse = " ; "))
  sortie("sigma2_(J-1), regle de minimum : ", f17(regle))
  sortie("sigma2_(J-1), estimateur direct : ", f17(direct))
  sortie("figes$degeneres : ", vec(jd), " ; figes$non_identifiables : ", vec(figes$non_identifiables),
         " ; figes$origine_non_identifiables : ", vec(figes$origine_non_identifiables))
  sortie("n_j (j = 0..J-1) : ", paste(I - 0:(J - 1), collapse = " ; "), " ; cas = ", cas)

  # I6, I7 -------------------------------------------------------------------
  titre("Preconditions (I6) et ensembles figes (I7)")
  i6 <- list(
    IJ = I == att$I && J == att$J,
    deg = identical(jd, as.integer(att$deg)),
    cas = identical(cas, att$cas),
    regle = if (is.null(att$regle)) NA else conforme_arrondi(regle, att$regle),
    direct = if (identical(att$direct, "absent")) is.null(direct) else conforme_arrondi(direct, att$direct),
    alpha = if (is.null(att$alpha)) NA else identical(as.integer(fa_obs$detail$j), as.integer(att$alpha)),
    figees = if (isTRUE(att$alpha_toutes_figees)) all(fa_obs$detail$j %in% jd) else NA)
  if (nm == "T0") i6$construction_617 <- identical(tri, t0_comme_617(tris$T1))
  sortie("I6 : I, J = ", I, ", ", J, " (attendu ", att$I, ", ", att$J, ") : ", ok_ko(i6$IJ))
  sortie("I6 : degeneres = ", vec(jd), " (attendu ", vec(att$deg), ") : ", ok_ko(i6$deg))
  sortie("I6 : cas = ", cas, " (attendu ", att$cas, ") : ", ok_ko(i6$cas))
  sortie("I6 : regle = ", f6(regle), " (attendu ", if (is.null(att$regle)) "non fixe" else att$regle, ") : ",
         ok_ko(i6$regle))
  sortie("I6 : direct = ", f6(direct), " (attendu ", att$direct, ") : ", ok_ko(i6$direct))
  sortie("I6 : colonnes d'Alpha = ", vec(fa_obs$detail$j), " (attendu ",
         if (is.null(att$alpha)) "non fixe" else vec(att$alpha), ") : ", ok_ko(i6$alpha))
  if (!is.na(i6$figees)) sortie("I6 : colonnes d'Alpha toutes figees : ", ok_ko(i6$figees))
  if (!is.null(i6$construction_617))
    sortie("I6 : T0 identique a la construction de mesure_617.R : ", ok_ko(i6$construction_617))
  CTRL$I6[[nm]] <- tous(i6)
  CTRL$I7[[nm]] <- identical(.mw_colonnes_degenerees(aj), jd)
  sortie("I7 : .mw_colonnes_degenerees(aj) identical a figes$degeneres : ", ok_ko(CTRL$I7[[nm]]))

  # Executions ---------------------------------------------------------------
  titre("Executions")
  for (k in names(rr)) {
    x <- rr[[k]]
    sortie(sprintf("%-4s", k), " : ", if (!is.na(x$erreur)) paste("ERREUR :", x$erreur)
           else if (!x$ok) "ok = FALSE" else "ok = TRUE",
           " ; liaisons restaurees : ", ok_ko(x$restaure),
           if (OPT$essai) "" else sprintf(" ; %.1f s", x$secs))
  }
  CTRL$I2[[nm]] <- all(vapply(rr, function(x) x$restaure, logical(1)))
  tous_ok <- all(vapply(rr[c("V0", "Va", "Vb", "V0f")], function(x) x$ok, logical(1)))
  # I8 : graine et B lus dans les metadonnees de chaque execution aboutie
  # (ok = TRUE) ; une execution en echec releve des mesures, non de I8.
  CTRL$I8[[nm]] <- all(vapply(rr, function(x) !isTRUE(x$ok) ||
    (identical(x$res$metadata$seed, x$graine) && identical(x$res$metadata$B, OPT$B)), logical(1)))
  r0 <- rr$V0$res; ra <- rr$Va$res; rb <- rr$Vb$res
  # I1 ---------------------------------------------------------------------
  i1 <- c(debut_fin = !is.null(r0) && identical(r0, rr$V0f$res))
  if (!is.null(rr$V0j)) i1["journal"] <- !is.null(r0) && identical(r0, rr$V0j$res)
  CTRL$I1[[nm]] <- all(i1)
  sortie("I1 : V0 au debut identical a V0 a la fin : ", ok_ko(i1[["debut_fin"]]),
         if (!is.null(rr$V0j)) paste0(" ; V0 avec journal identical a V0 sans journal : ",
                                       ok_ko(i1[["journal"]])) else "")
  sortie("I8 : metadata$seed et metadata$B egaux a la graine et a B passes : ", ok_ko(CTRL$I8[[nm]]))
  # Echec de Va (erreur ou ok = FALSE) : Ga4 a FALSE sur KA ; Gb3 et Gb4,
  # qui ne lisent pas Va, restent evalues si V0, Vb et V0 de fin ont abouti.
  va_ok <- isTRUE(rr$Va$ok)
  if (nm == "KA" && !va_ok) {
    G$Ga4[[nm]] <- FALSE
    sortie("Ga4 : Va sur KA en erreur ou ok = FALSE : ECHEC")
  }
  if (!tous_ok) {
    ok_sans_va <- all(vapply(rr[c("V0", "Vb", "V0f")], function(x) x$ok, logical(1)))
    if (ok_sans_va && !va_ok) {
      sortie("Va en echec (", if (is.na(rr$Va$erreur)) "ok = FALSE" else paste("ERREUR :", rr$Va$erreur),
             ") : mesures de ce triangle non calculees, sauf Gb3 et Gb4.")
      G$Gb3[[paste0(nm, "_sigma_usp")]] <- identical(r0$parametre_final$sigma_usp,
                                                     rb$parametre_final$sigma_usp)
      sortie("Vb : sigma_USP identical : ", ok_ko(G$Gb3[[paste0(nm, "_sigma_usp")]]))
      if (nm %in% TRI_GB3_RES) {
        G$Gb3[[paste0(nm, "_res")]] <- identical(r0, rb)
        sortie("Vb : res identical a V0 : ", ok_ko(G$Gb3[[paste0(nm, "_res")]]))
      }
      if (nm %in% TRI_GB4) {
        jv <- JVB[[nm]]
        G$Gb4[[nm]] <- length(jv$deg) > 0L && all(jv$deg)
        sortie("Gb4 : colonne J-1 degeneree dans les replications de Vb : ", sum(jv$deg), " / ",
               length(jv$deg), " : ", ok_ko(G$Gb4[[nm]]))
      }
    } else sortie("EXECUTION INCOMPLETE : mesures de ce triangle non calculees.")
    next
  }
  b0 <- r0$bootstrap; ba <- ra$bootstrap; bb <- rb$bootstrap

  # M-a ----------------------------------------------------------------------
  titre("M-a : p_mc, err_mc, B_effectif, stats_obs ; colonnes de stats_boot identical a V0")
  sortie(sprintf("%-11s %-5s | %-10s %-10s %-10s | %-9s %-9s %-9s | %-4s %-4s %-4s | %-6s %-6s",
                 "cle", "queue", "p V0", "p Va", "p Vb", "err V0", "err Va", "err Vb",
                 "BeV0", "BeVa", "BeVb", "colVa", "colVb"))
  for (cl in CLES) {
    sortie(sprintf("%-11s %-5s | %-10s %-10s %-10s | %-9s %-9s %-9s | %-4s %-4s %-4s | %-6s %-6s",
                   cl, QUEUES[[cl]], f6(b0$p_mc[[cl]]), f6(ba$p_mc[[cl]]), f6(bb$p_mc[[cl]]),
                   f6(signif(b0$err_mc[[cl]], 4)), f6(signif(ba$err_mc[[cl]], 4)),
                   f6(signif(bb$err_mc[[cl]], 4)),
                   b0$B_effectif[[cl]], ba$B_effectif[[cl]], bb$B_effectif[[cl]],
                   ok_ko(identical(b0$stats_boot[, cl], ba$stats_boot[, cl])),
                   ok_ko(identical(b0$stats_boot[, cl], bb$stats_boot[, cl]))))
  }
  sortie("stats_obs (17 chiffres) :")
  for (cl in CLES)
    sortie(sprintf("  %-11s V0 %s ; Va %s ; Vb %s", cl, f17(b0$stats_obs[[cl]]),
                   f17(ba$stats_obs[[cl]]), f17(bb$stats_obs[[cl]])))
  mot <- function(b) { v <- b$motif_mc[["Alpha"]]; if (is.null(v) || is.na(v)) "aucun" else v }
  sortie("motif_mc[[\"Alpha\"]] : V0 ", mot(b0), " ; Va ", mot(ba), " ; Vb ", mot(bb))

  # M-b ----------------------------------------------------------------------
  titre("M-b : ligne Alpha")
  for (v in c("V0", "Va", "Vb")) {
    res <- rr[[v]]$res; la <- lignes_mc(res, "Alpha")
    if (!length(la)) { sortie(v, " : ligne Alpha absente"); next }
    l <- la[[1]]
    sortie(v, " : stat = ", f17(l$stat), " ; p_retenue = ", f6(l$p_retenue), " ; nature_p = ",
           if (is.na(l$nature_p)) "NA" else l$nature_p, " ; type = ", l$type, " ; verdict (",
           ALPHA_V, ") = ", l$verdict, " ; inoperant = ", l$inoperant,
           if (length(la) > 1L) paste0(" ; (", length(la), " lignes de cle Alpha)") else "")
    sortie("     detail : ", l$detail)
  }

  # M-c ----------------------------------------------------------------------
  titre("M-c : p de famille et p globale (decomposition minP)")
  dec <- lapply(list(V0 = r0, Va = ra, Vb = rb), decomposer_familles)
  for (v in names(dec)) {
    lf <- lignes_famille(rr[[v]]$res)
    for (cf in names(dec[[v]])) {
      d <- dec[[v]][[cf]]
      p_ligne <- NA_real_
      for (l in lf) if (identical(cle_famille(l), cf)) p_ligne <- l$p_mc
      gagnants <- if (is.null(d$num_obs)) "-" else names(d$num_obs)[d$num_obs == d$num_m_obs]
      sortie(sprintf("%s %-3s : p = %s ; m_obs = %s ; B_eff = %s ; N = %s ; num_p = %s ; num_m_obs = %s",
                     v, cf, f6(d$p), f6(d$m_obs), d$B_eff, d$N, d$num_p, d$num_m_obs),
             " ; minimum atteint par ", paste(gagnants, collapse = ", "),
             " ; p de la ligne identical : ", ok_ko(identical(p_ligne, d$p)))
      sortie("       membres : ", paste(d$membres, collapse = ", "))
      if (!is.null(d$num_obs))
        sortie("       num_obs : ", paste(sprintf("%s = %d", names(d$num_obs), d$num_obs), collapse = " ; "))
    }
  }
  for (v in c("Va", "Vb")) {
    sans_alpha <- names(dec$V0)[vapply(dec$V0, function(d) !("Alpha" %in% d$membres), logical(1))]
    eg <- vapply(sans_alpha, function(cf) identical(dec$V0[[cf]], dec[[v]][[cf]]), logical(1))
    sortie("Familles sans Alpha (", paste(sans_alpha, collapse = ", "), ") identical entre V0 et ", v,
           " : ", ok_ko(all(eg)))
  }
  INFO[[nm]]$fam <- lapply(dec, function(d) c(M1 = if (is.null(d$M1)) NA_real_ else d$M1$p,
                                              LC = if (is.null(d$LC)) NA_real_ else d$LC$p))

  # M-d ----------------------------------------------------------------------
  titre("M-d : verdicts d'Alpha a alpha saisi")
  pA <- c(V0 = b0$p_mc[["Alpha"]], Va = ba$p_mc[["Alpha"]], Vb = bb$p_mc[["Alpha"]])
  a_min <- 4 / (OPT$B + 1)
  sortie("p d'Alpha : V0 ", f6(pA[["V0"]]), " ; Va ", f6(pA[["Va"]]), " ; Vb ", f6(pA[["Vb"]]),
         " ; repere de l'application : alpha <= 4/(B+1) = ", f6(a_min), " inadmissible a B = ", OPT$B)
  for (v in c("Va", "Vb")) {
    sortie(v, " contre V0, alpha dans ]0 ; ", SEUIL_ECHEC_SENS_REJETER, "[ : ",
           intervalles_alpha(pA[["V0"]], pA[[v]], 0, SEUIL_ECHEC_SENS_REJETER),
           " ; dont admissible a B (alpha > 4/(B+1)) : ",
           intervalles_alpha(pA[["V0"]], pA[[v]], a_min, SEUIL_ECHEC_SENS_REJETER))
    ver0 <- vapply(r0$tests, function(l) l$verdict, ""); verv <- vapply(rr[[v]]$res$tests, function(l) l$verdict, "")
    nom0 <- vapply(r0$tests, function(l) paste(l$famille, l$test), ""); nomv <- vapply(rr[[v]]$res$tests, function(l) paste(l$famille, l$test), "")
    ia <- which(vapply(r0$tests, function(l) identical(l$mc_nom, "Alpha"), logical(1)))
    garde <- setdiff(seq_along(ver0), ia)
    autres <- identical(nom0, nomv) && identical(ver0[garde], verv[garde])
    sortie("    verdicts (", ALPHA_V, ") de toutes les autres lignes identiques entre V0 et ", v, " : ",
           ok_ko(autres))
  }
  INFO[[nm]]$pA <- pA
  INFO[[nm]]$verdict_alpha <- vapply(list(V0 = r0, Va = ra, Vb = rb), function(res) {
    l <- ligne_mc(res, "Alpha"); if (is.null(l)) NA_character_ else l$verdict }, "")

  # M-e ----------------------------------------------------------------------
  titre("M-e : sigma_USP, sigma_boot, ic_bootstrap")
  resume_sb <- function(res) {
    s <- res$bootstrap$sigma_boot
    c(longueur = length(s), moyenne = if (length(s)) mean(s) else NA_real_,
      stats::setNames(if (length(s)) stats::quantile(s, c(0.05, 0.5, 0.95), type = 7, names = FALSE)
                      else rep(NA_real_, 3), c("q05", "q50", "q95")))
  }
  sb_r <- lapply(list(V0 = r0, Va = ra, Vb = rb), resume_sb)
  for (v in c("V0", "Va", "Vb")) {
    res <- rr[[v]]$res
    sortie(v, " : sigma_USP = ", f17(res$parametre_final$sigma_usp), " ; sigma_boot : ",
           paste(sprintf("%s = %s", names(sb_r[[v]]), f6(sb_r[[v]])), collapse = " ; "))
    sortie("     ic_bootstrap : ", paste(sprintf("%s = %s", names(res$ic_bootstrap), f6(res$ic_bootstrap)),
                                         collapse = " ; "),
           " ; n_sans_sigma = ", res$bootstrap$n_sans_sigma, " ; cumuls_retires = ",
           res$bootstrap$cumuls_retires, " ; plafond_cumuls = ", res$bootstrap$plafond_cumuls)
  }
  for (v in c("Va", "Vb")) {
    res <- rr[[v]]$res
    er_sb <- sb_r[[v]][-1] / sb_r$V0[-1] - 1
    er_ic <- res$ic_bootstrap / r0$ic_bootstrap - 1
    sortie("ecarts relatifs ", v, "/V0 - 1 : sigma_boot : ",
           paste(sprintf("%s %s", names(er_sb), f6(er_sb)), collapse = " ; "),
           " ; ic : ", paste(sprintf("%s %s", names(er_ic), f6(er_ic)), collapse = " ; "))
    sortie("    sigma_USP identical a V0 : ", ok_ko(identical(res$parametre_final$sigma_usp,
                                                              r0$parametre_final$sigma_usp)),
           " ; sigma_boot identical : ", ok_ko(identical(res$bootstrap$sigma_boot, b0$sigma_boot)),
           " ; ic_bootstrap identical : ", ok_ko(identical(res$ic_bootstrap, r0$ic_bootstrap)))
  }
  INFO[[nm]]$er_sb_vb <- sb_r$Vb[-1] / sb_r$V0[-1] - 1
  INFO[[nm]]$er_ic_vb <- rb$ic_bootstrap / r0$ic_bootstrap - 1

  # M-f ----------------------------------------------------------------------
  titre("M-f : valeur de A")
  A0 <- b0$stats_obs$Alpha; Aa <- ba$stats_obs$Alpha
  sn <- sum(fa_obs$detail$n); snp <- sum(fa_obs$detail$n[!(fa_obs$detail$j %in% jd)])
  sortie("A_obs V0 = ", f17(A0), " ; A_obs Va = ", f17(Aa), " ; Sum n = ", sn, " ; Sum' n = ", snp)
  if (is.finite(A0) && is.finite(Aa)) {
    rap <- Aa / A0; ecr <- rap / (sn / snp) - 1
    sortie("A_obs(Va) / A_obs(V0) = ", f17(rap), " ; Sum n / Sum' n = ", f17(sn / snp),
           " ; ecart relatif = ", f6(ecr), " (<= ", TOL_DEG, " : ", ok_ko(abs(ecr) <= TOL_DEG), ")")
    if (!is.null(RAPPORT_ATTENDU[[nm]]))
      sortie("Sum n / Sum' n egal a ", RAPPORT_ATTENDU[[nm]][1], "/", RAPPORT_ATTENDU[[nm]][2],
             " (par. 3.5, M-f) : ", ok_ko(sn == RAPPORT_ATTENDU[[nm]][1] && snp == RAPPORT_ATTENDU[[nm]][2]))
    INFO[[nm]]$ecart_rapport <- ecr
  } else sortie("rapport sans objet (A_obs non fini)")
  sortie("detail de mw_famille_alpha(aj), V0 :"); imprimer_detail_alpha(fa_obs$detail)
  sortie("detail de la variante Va sur aj (ensemble fige figes$degeneres) :")
  imprimer_detail_alpha(alpha_va(aj, jd)$detail)

  # M-g ----------------------------------------------------------------------
  titre("M-g : replications ou l'indicateur A* >= A_obs differe entre Vb et Va")
  ind_va <- ba$stats_boot[, "Alpha"] >= Aa
  ind_vb <- bb$stats_boot[, "Alpha"] >= bb$stats_obs$Alpha
  if (!is.finite(Aa)) sortie("sans objet (A_obs de Va non fini)") else {
    disc <- which(xor(ind_va, ind_vb) | xor(is.na(ind_va), is.na(ind_vb)))
    sortie("discordances : ", length(disc))
    for (b in head(disc, 30L))
      sortie(sprintf("  rep %d : A* Va = %s ; A* Vb = %s ; |A*_Va - A_obs_Va| / A_obs_Va = %s",
                     b, f17(ba$stats_boot[b, "Alpha"]), f17(bb$stats_boot[b, "Alpha"]),
                     f6(abs(ba$stats_boot[b, "Alpha"] - Aa) / Aa)))
    if (length(disc) > 30L) sortie("  ... et ", length(disc) - 30L, " autre(s)")
  }

  # Journal (V0) : p_sans, I4, Gb1, Ga1, I9 (Va) ------------------------------
  if (nm %in% names(JOURNAL)) {
    titre("Journal de V0 : p_sans, I4, Gb1, Ga1, I9 (Va)")
    jl <- JOURNAL[[nm]]; R <- length(jl)
    sb <- b0$stats_boot; vus <- which(rowSums(!is.na(sb)) > 0)
    coh <- R == length(vus) && all(vapply(seq_len(R), function(k)
      identical(unname(as.numeric(jl[[k]]$stats[CLES])), unname(as.numeric(sb[vus[k], CLES]))), logical(1)))
    sortie("journal : |R| = ", R, " ; lignes non NA de stats_boot = ", length(vus),
           " ; 13 statistiques identiques au stats_boot de V0 : ", ok_ko(coh))
    CTRL$I1[[paste0(nm, "_journal")]] <- coh
    fa_l <- lapply(jl, function(e) mw_famille_alpha(mw_ajuster(e$tri)))
    As_obs <- sans(fa_obs$detail, jd)
    As_star <- vapply(fa_l, function(fa) sans(fa$detail, jd), numeric(1))
    As_full <- rep(NA_real_, nrow(sb)); As_full[vus] <- As_star
    mc_s <- engine_p_mc(As_star, As_obs, "haut")
    p_s <- mc_s$p_mc; p_m <- b0$p_mc[["Alpha"]]
    N_m <- sum(sb[, "Alpha"] >= A0, na.rm = TRUE); N_s <- sum(As_star >= As_obs, na.rm = TRUE)
    sortie("A^sans_obs = ", f17(As_obs), " ; p_sans = ", f6(p_s), " (err_mc ", f6(mc_s$err_mc),
           ", B_eff ", mc_s$B_effectif, ") ; p_moteur (V0) = ", f6(p_m))
    sortie("N_moteur = ", N_m, " ; N_sans = ", N_s)
    INFO[[nm]]$p_sans <- p_s
    if (nm %in% names(I4_ATTENDU)) {
      a4 <- I4_ATTENDU[[nm]]
      i4 <- if (!DEFAUT_REF) NA else
        N_m == a4[1] && N_s == a4[2] && abs(round(p_m, 3) - a4[3]) < 1e-12 &&
        abs(round(p_s, 3) - a4[4]) < 1e-12
      CTRL$I4[[nm]] <- i4
      sortie("I4 (attendu N_moteur = ", a4[1], ", N_sans = ", a4[2], ", p = ", a4[3], " contre ", a4[4],
             ") : ", ok_ko(i4), if (is.na(i4)) " (B ou graine hors protocole)" else "")
    }
    # Gb1 et Ga1 (domaine de l'issue) : indicateur sans, recalcule sur le journal.
    ind_s <- As_full >= As_obs
    quasi <- function(b) is.finite(As_full[b]) && abs(As_full[b] - As_obs) <= TOL_DEG * As_obs
    if (nm %in% TRI_ISSUE) {
      d_b <- which(xor(ind_vb, ind_s) | xor(is.na(ind_vb), is.na(ind_s)))
      gb1 <- all(vapply(d_b, quasi, logical(1)))
      G$Gb1[[nm]] <- gb1
      sortie("Gb1 : p_Alpha(Vb) = ", f6(pA[["Vb"]]), " ; p_sans = ", f6(p_s), " ; identical : ",
             ok_ko(identical(pA[["Vb"]], p_s)), " ; replications discordantes : ", length(d_b),
             " ; toutes quasi-egales : ", ok_ko(gb1))
      for (b in head(d_b, 30L))
        sortie(sprintf("  rep %d : A^sans* = %s ; A* Vb = %s ; |A^sans* - A^sans_obs| / A^sans_obs = %s",
                       b, f17(As_full[b]), f17(bb$stats_boot[b, "Alpha"]),
                       f6(abs(As_full[b] - As_obs) / As_obs)))
      G$Ga1[[nm]] <- identical(pA[["Va"]], p_s)
      sortie("Ga1 : p_Alpha(Va) = ", f6(pA[["Va"]]), " identical a p_sans : ", ok_ko(G$Ga1[[nm]]))
    }
    if (nm == "K1") {
      ind_0 <- b0$stats_boot[, "Alpha"] >= A0
      d_a <- which(xor(ind_va, ind_0) | xor(is.na(ind_va), is.na(ind_0)))
      quasi_a <- function(b) is.finite(ba$stats_boot[b, "Alpha"]) &&
        abs(ba$stats_boot[b, "Alpha"] - Aa) <= TOL_DEG * Aa
      G$Ga1[[nm]] <- all(vapply(d_a, quasi_a, logical(1)))
      sortie("Ga1 (K1) : p_Alpha(Va) = ", f6(pA[["Va"]]), " ; p_Alpha(V0) = ", f6(pA[["V0"]]),
             " ; identical : ", ok_ko(identical(pA[["Va"]], pA[["V0"]])), " ; replications discordantes : ",
             length(d_a), " ; toutes quasi-egales : ", ok_ko(G$Ga1[[nm]]))
      for (b in head(d_a, 30L))
        sortie(sprintf("  rep %d : A* Va = %s ; A* V0 = %s ; |A*_Va - A_obs_Va| / A_obs_Va = %s", b,
                       f17(ba$stats_boot[b, "Alpha"]), f17(b0$stats_boot[b, "Alpha"]),
                       f6(abs(ba$stats_boot[b, "Alpha"] - Aa) / Aa)))
    }
    # I9 (Va) : la variante, appliquee aux premieres replications du journal,
    # redonne la colonne Alpha du stats_boot de Va.
    n9 <- min(N_I9, R)
    i9a <- n9 > 0 && all(vapply(seq_len(n9), function(k)
      identical(unname(as.numeric(alpha_va(mw_ajuster(jl[[k]]$tri), jl[[k]]$figes$degeneres)$stat)),
                unname(as.numeric(ba$stats_boot[vus[k], "Alpha"]))), logical(1)))
    n_diff <- sum(!mapply(identical, b0$stats_boot[, "Alpha"], ba$stats_boot[, "Alpha"]))
    sortie("I9 (Va) : variante sur les ", n9, " premieres replications du journal = colonne Alpha de Va : ",
           ok_ko(i9a), " ; (info) lignes ou la colonne Alpha differe entre V0 et Va : ", n_diff)
    CTRL$I9[[paste0(nm, "_Va")]] <- i9a
  }

  # Crochets de Vb : I9 (Vb), Gb4 --------------------------------------------
  titre("Crochets de Vb : I9 (Vb), Gb4")
  jv <- JVB[[nm]]
  cible <- if (is.null(direct)) regle else direct
  i9b <- length(jv$sig) > 0L && all(vapply(jv$sig, function(s) identical(s, cible), logical(1)))
  CTRL$I9[[paste0(nm, "_Vb")]] <- i9b
  sortie("I9 (Vb) : aj$sigma2[J] recu par .mw_tirer_triangle_valide() = ",
         if (is.null(direct)) "regle (carre, pas d'estimateur direct)" else "estimateur direct",
         " (", f17(cible), ") a chaque appel : ", ok_ko(i9b), " (", length(jv$sig), " appels)")
  ndeg <- sum(jv$deg); nrep <- length(jv$deg)
  sortie("colonne J-1 degeneree (.mw_colonne_degeneree) dans les replications de Vb : ", ndeg, " / ", nrep)
  if (nm %in% TRI_GB4) {
    G$Gb4[[nm]] <- nrep > 0L && ndeg == nrep
    sortie("Gb4 : 100 % : ", ok_ko(G$Gb4[[nm]]))
  }

  # Gb2, Gb3, Ga2, Ga3, Ga4 ----------------------------------------------------
  titre("Comparaisons de variantes (Gb2, Gb3, Ga2, Ga3, Ga4)")
  verd <- function(res, cl) { l <- ligne_mc(res, cl); if (is.null(l)) NA_character_ else l$verdict }
  meme12 <- function(rv) {
    bv <- rv$bootstrap
    c(p = identical(b0$p_mc[CLES12], bv$p_mc[CLES12]),
      verdicts = identical(vapply(CLES12, function(cl) verd(r0, cl), ""),
                           vapply(CLES12, function(cl) verd(rv, cl), "")),
      colonnes = identical(b0$stats_boot[, CLES12], bv$stats_boot[, CLES12]))
  }
  m12b <- meme12(rb); m12a <- meme12(ra)
  sortie("Vb : 12 autres cles : p_mc ", ok_ko(m12b[["p"]]), " ; verdicts ", ok_ko(m12b[["verdicts"]]),
         " ; colonnes de stats_boot ", ok_ko(m12b[["colonnes"]]))
  if (nm %in% TRI_GB2) G$Gb2[[nm]] <- all(m12b)
  su_b <- identical(r0$parametre_final$sigma_usp, rb$parametre_final$sigma_usp)
  G$Gb3[[paste0(nm, "_sigma_usp")]] <- su_b
  sortie("Vb : sigma_USP identical : ", ok_ko(su_b))
  res_b <- identical(r0, rb)
  sortie("Vb : res identical a V0 : ", ok_ko(res_b))
  if (nm %in% TRI_GB3_RES) G$Gb3[[paste0(nm, "_res")]] <- res_b
  ga2 <- c(m12a[c("p", "colonnes")],
           sigma_boot = identical(b0$sigma_boot, ba$sigma_boot),
           ic = identical(r0$ic_bootstrap, ra$ic_bootstrap),
           sigma_usp = identical(r0$parametre_final$sigma_usp, ra$parametre_final$sigma_usp))
  G$Ga2[[nm]] <- all(ga2)
  sortie("Va : 12 autres cles : p_mc ", ok_ko(ga2[["p"]]), " ; colonnes ", ok_ko(ga2[["colonnes"]]),
         " ; sigma_boot ", ok_ko(ga2[["sigma_boot"]]), " ; ic_bootstrap ", ok_ko(ga2[["ic"]]),
         " ; sigma_USP ", ok_ko(ga2[["sigma_usp"]]), " ; (info) verdicts des 12 : ", ok_ko(m12a[["verdicts"]]))
  res_a <- identical(r0, ra)
  sortie("Va : res identical a V0 : ", ok_ko(res_a))
  if (nm %in% TRI_GA3_RES) G$Ga3[[nm]] <- res_a
  if (!res_b && !(nm %in% TRI_GB3_RES)) {
    # Artefact connu du prototype Vb (par. 3.2) : textes M6 et usage_sigma.
    # La ligne Alpha, dont le detail suit la p de Monte-Carlo (phrase de #244
    # sur un verdict proche d'un seuil), est imprimee a part : effet attendu
    # de Vb, non artefact.
    ch <- ch_alpha <- character(0)
    for (k in seq_along(r0$tests)) if (!identical(r0$tests[[k]]$detail, rb$tests[[k]]$detail)) {
      lib <- paste(r0$tests[[k]]$famille, "/", r0$tests[[k]]$test)
      if (identical(r0$tests[[k]]$mc_nom, "Alpha")) ch_alpha <- c(ch_alpha, lib) else ch <- c(ch, lib)
    }
    sortie("Vb : lignes dont le detail change (artefact connu des textes M6 et usage_sigma, exclu des ",
           "comparaisons) : ", if (length(ch)) paste(ch, collapse = " | ") else "aucune")
    sortie("Vb : ligne Alpha dont le detail change (effet attendu de Vb sur la p d'Alpha) : ",
           if (length(ch_alpha)) paste(ch_alpha, collapse = " | ") else "aucune")
    sortie("Vb : plots_data$usage_sigma identical : ",
           ok_ko(identical(r0$plots_data$usage_sigma, rb$plots_data$usage_sigma)))
  }
  if (nm == "KA") {
    la <- ligne_mc(ra, "Alpha"); l0 <- ligne_mc(r0, "Alpha")
    G$Ga4[[nm]] <- !is.null(la) && identical(la$type, "non applicable") && is.na(la$p_retenue) &&
      is.na(rr$Va$erreur)
    sortie("Ga4 : Va sur KA : type = ", if (is.null(la)) "absent" else la$type, " ; p_retenue = ",
           if (is.null(la)) "absent" else f6(la$p_retenue), " ; sans erreur : ", ok_ko(is.na(rr$Va$erreur)),
           " : ", ok_ko(G$Ga4[[nm]]))
    sortie("     V0 sur KA : type = ", l0$type, " ; p_retenue = ", f6(l0$p_retenue), " ; inoperant = ",
           l0$inoperant, " ; motif = ", mot(b0))
    INFO$KA_V0 <- list(type = l0$type, inoperant = l0$inoperant, motif = mot(b0))
    INFO$KA_Va <- list(type = if (is.null(la)) NA_character_ else la$type)
  }
}

###############################################################################
#  CONTROLES GLOBAUX
###############################################################################
grand_titre("CONTROLES GLOBAUX")
titre("I5 : V0 = moteur (references ; moteur charge a part)")
I5 <- list()
if (DEFAUT_REF && any(names(REF_FICHIERS) %in% OPT$triangles)) {
  ot <- new.env()
  sys.source("tests/outils_tests.R", envir = ot)
  for (nm in intersect(names(REF_FICHIERS), OPT$triangles)) {
    ref <- readRDS(REF_FICHIERS[[nm]]); r0 <- RUNS[[nm]]$V0$res
    cmp <- ot$comparer_objets(ref, r0)
    egaux <- c(p_mc = identical(unname(unlist(ref$bootstrap$p_mc)), unname(unlist(r0$bootstrap$p_mc))),
               verdicts = identical(vapply(ref$tests, function(l) l$verdict, ""),
                                    vapply(r0$tests, function(l) l$verdict, "")),
               sigma_usp = identical(ref$parametre_final$sigma_usp, r0$parametre_final$sigma_usp))
    I5[[nm]] <- isTRUE(cmp$conforme) && all(egaux)
    sortie("I5 ", nm, " : comparer_objets(", REF_FICHIERS[[nm]], ") : ",
           paste(ot$resumer_comparaison(cmp, 5L), collapse = " | "))
    sortie("     p_mc egales : ", ok_ko(egaux[["p_mc"]]), " ; verdicts egaux : ", ok_ko(egaux[["verdicts"]]),
           " ; sigma_USP egal : ", ok_ko(egaux[["sigma_usp"]]), " : ", ok_ko(I5[[nm]]))
  }
} else sortie("I5 (references) : SANS OBJET (B ou graine hors protocole, ou R2 et R2T absents)")
for (nm in names(I5B)) {
  x <- I5B[[nm]]; r0 <- RUNS[[nm]]$V0$res
  eg <- !is.null(x$res) && !is.null(r0) &&
    identical(x$res$bootstrap$p_mc[CLES], r0$bootstrap$p_mc[CLES])
  I5[[paste0(nm, "_frais")]] <- eg
  sortie("I5 ", nm, " : p_mc des 13 cles (Alpha et les douze autres) de V0 identical a celles d'un ",
         "moteur charge a part, jamais substitue : ", ok_ko(eg),
         if (OPT$essai || is.null(x$res)) "" else sprintf(" (%.1f s)", x$secs))
}

titre("I1, I2, I3, I8, I9 (synthese)")
if (!is.null(RUN_VB_NU)) {
  i9c <- !is.null(RUN_VB_NU$res) && identical(RUN_VB_NU$res, RUNS$T1$Vb$res)
  CTRL$I9$T1_crochets_sans_effet <- i9c
  CTRL$I2$T1_vb_nu <- RUN_VB_NU$restaure
  sortie("I9 : Vb sur T1 sans crochets identical a Vb avec crochets (crochets de lecture sans effet) : ",
         ok_ko(i9c))
}
for (nm in names(MH)) CTRL$I2[[paste0(nm, "_Mh")]] <- all(vapply(MH[[nm]], function(x) x$restaure, logical(1)))
for (nm in names(I5B)) CTRL$I2[[paste0(nm, "_frais")]] <- I5B[[nm]]$restaure
CTRL$I8$graine_globale <- identical(GRAINE_GLOBALE_0, GRAINE_GLOBALE_1)
CTRL$I8$B <- if (OPT$essai) NA else OPT$B == B_PROTOCOLE
sortie("I8 : .Random.seed de l'environnement global inchange (le script ne tire rien) : ",
       ok_ko(CTRL$I8$graine_globale), " ; B = ", OPT$B, " = 999 : ", ok_ko(CTRL$I8$B))
CTRL$I3 <- list(debut = I3_DEBUT$ok, fin = I3_FIN$ok)
sortie("I3 a la fin : md5 de R/engine.R = ", I3_FIN$md5, " : ", ok_ko(I3_FIN$md5_ok),
       " ; git status vide : ", ok_ko(I3_FIN$git_ok))
if (!I3_FIN$git_ok) sortie("  git : ", paste(I3_FIN$git, collapse = " | "))
CTRL$I5 <- I5
noms_i <- c("I1", "I2", "I3", "I4", "I5", "I6", "I7", "I8", "I9")
etat_i <- vapply(noms_i, function(k) tous(CTRL[[k]]), logical(1))
for (k in noms_i) {
  x <- unlist(CTRL[[k]])
  sortie(sprintf("%-3s : %s", k, ok_ko(etat_i[[k]])),
         if (length(x)) paste0("  (", paste(sprintf("%s %s", names(x), vapply(x, ok_ko, "")), collapse = " ; "), ")")
         else "  (aucun element)")
}
R0 <- isTRUE(tous(etat_i)) && !anyNA(unlist(CTRL[noms_i]))   # aucun controle sans objet
R0_EVALUABLE <- isTRUE(tous(etat_i))   # verts sur les controles evaluables
sortie("R0 (I1 a I9 verts) : ", if (isTRUE(R0)) "VERT" else if (R0_EVALUABLE)
  "VERT SUR LES CONTROLES EVALUABLES (certains sans objet : non versable)" else "ROUGE",
  if (!VERSABLE) " (NON VERSABLE)" else "")

###############################################################################
#  CRITERES D'ADMISSIBILITE (par. 2)
###############################################################################
grand_titre("CRITERES D'ADMISSIBILITE (par. 2) -- lecture mecanique, a l'etape 5 par actuary")
requis <- list(Gb1 = TRI_ISSUE, Gb2 = TRI_GB2, Gb4 = TRI_GB4, Ga1 = c(TRI_ISSUE, "K1"),
               Ga2 = TRI_TOUS, Ga3 = TRI_GA3_RES, Ga4 = "KA",
               Gb3 = c(paste0(TRI_TOUS, "_sigma_usp"), paste0(TRI_GB3_RES, "_res")))
etat_g <- vapply(names(G), function(k) {
  x <- unlist(G[[k]])
  manquants <- setdiff(requis[[k]], names(x))
  if (length(manquants)) NA else all(x)
}, logical(1))
for (k in names(G)) {
  x <- unlist(G[[k]])
  sortie(sprintf("%-3s : %s", k, if (is.na(etat_g[[k]])) "NON EVALUABLE (triangle requis absent ou execution incomplete)"
                 else ok_ko(etat_g[[k]])),
         if (length(x)) paste0("  (", paste(sprintf("%s %s", names(x), vapply(x, ok_ko, "")), collapse = " ; "), ")") else "")
}
adm_b <- all(etat_g[c("Gb1", "Gb2", "Gb3", "Gb4")])
adm_a <- all(etat_g[c("Ga1", "Ga2", "Ga3", "Ga4")])
sortie("(b) admissible : ", ok_nev(adm_b), " ; (a) admissible : ", ok_nev(adm_a))
choix <- if (!R0_EVALUABLE) "aucune conclusion (R0 rouge)" else if (is.na(adm_b)) "non evaluable" else
  if (adm_b) "(b)" else if (is.na(adm_a)) "non evaluable" else if (adm_a) "(a)" else "(c)"
sortie("Regle de choix (b) > (a) > (c), appliquee mecaniquement : ", choix,
       if (!VERSABLE) " (NON VERSABLE)" else "")

###############################################################################
#  PREDICTIONS H1 A H6 (par. 3.6), information
###############################################################################
grand_titre("PREDICTIONS H1 A H6 (par. 3.6) -- information, lecture a l'etape 5")
gi <- function(nm, ...) { x <- INFO[[nm]]; for (k in list(...)) { if (is.null(x)) return(NULL); x <- x[[k]] }; x }
for (nm in intersect(TRI_ISSUE, OPT$triangles)) {
  sortie("H1 ", nm, " : p_Alpha(Va) = ", f6(gi(nm, "pA", "Va")), " ; p_sans = ", f6(gi(nm, "p_sans")))
  sortie("H2 ", nm, " : p_Alpha(Vb) = ", f6(gi(nm, "pA", "Vb")))
  sortie("H3 ", nm, " : p famille M1 : V0 ", f6(gi(nm, "fam", "V0", "M1")), " ; Va ", f6(gi(nm, "fam", "Va", "M1")),
         " ; Vb ", f6(gi(nm, "fam", "Vb", "M1")), " | p globale : V0 ", f6(gi(nm, "fam", "V0", "LC")),
         " ; Va ", f6(gi(nm, "fam", "Va", "LC")), " ; Vb ", f6(gi(nm, "fam", "Vb", "LC")),
         " | Va = Vb : ", ok_ko(identical(gi(nm, "fam", "Va"), gi(nm, "fam", "Vb"))))
}
if ("K1" %in% OPT$triangles)
  sortie("H1 K1 : p_Alpha V0 ", f6(gi("K1", "pA", "V0")), " ; Va ", f6(gi("K1", "pA", "Va")),
         " ; ecart relatif du rapport des A_obs a Sum n / Sum' n : ", f6(gi("K1", "ecart_rapport")))
for (nm in intersect(c("T0", "T1", "T2", "T3"), OPT$triangles))
  sortie("H2 ", nm, " : ecarts relatifs Vb/V0 - 1 : sigma_boot ",
         paste(sprintf("%s %s", names(gi(nm, "er_sb_vb")), f6(gi(nm, "er_sb_vb"))), collapse = " ; "),
         " ; ic ", paste(sprintf("%s %s", names(gi(nm, "er_ic_vb")), f6(gi(nm, "er_ic_vb"))), collapse = " ; "))
sortie("H4 : voir Ga3 (R2, R2T, T3 sous Va) et Gb3 (R2, R2T, K1, KA sous Vb) ci-dessus.")
if (!is.null(INFO$KA_V0))
  sortie("H5 : V0 sur KA : type = ", INFO$KA_V0$type, " ; inoperant = ", INFO$KA_V0$inoperant,
         " ; motif = ", INFO$KA_V0$motif, " (prediction : ", MOTIF_MC_DISPERSION_NULLE,
         ", inoperant = TRUE) ; Va : type = ", INFO$KA_Va$type, " (prediction : non applicable)")
for (nm in intersect(c("T1", "T2"), OPT$triangles))
  sortie("H6 ", nm, " : verdict d'Alpha (", ALPHA_V, ") : ",
         paste(sprintf("%s %s", names(gi(nm, "verdict_alpha")), gi(nm, "verdict_alpha")), collapse = " ; "))

###############################################################################
#  M-h : GRAINE SECONDAIRE
###############################################################################
grand_titre(sprintf("M-h : graine secondaire %s (T1, T2 ; V0, Va, Vb)", format(OPT$graine2, scientific = FALSE)))
for (nm in names(MH)) {
  for (v in c("V0", "Va", "Vb")) {
    x <- MH[[nm]][[v]]
    if (is.null(x$res)) { sortie(nm, " ", v, " : ERREUR : ", x$erreur); next }
    sortie(sprintf("%-3s %s : p Alpha = %s ; p famille M1 = %s ; p globale = %s ; graine = %s%s", nm, v,
                   f6(x$res$bootstrap$p_mc[["Alpha"]]), f6(p_famille(x$res, "M1")), f6(p_famille(x$res, "LC")),
                   format(x$res$metadata$seed, scientific = FALSE),
                   if (OPT$essai) "" else sprintf(" ; %.1f s", x$secs)))
  }
}

###############################################################################
#  SYNTHESE ET PIED
###############################################################################
grand_titre("SYNTHESE")
sortie(sprintf("%-4s | %-10s %-10s %-10s %-10s | %-10s %-10s %-10s | %-10s %-10s %-10s", "tri",
               "pA V0", "pA Va", "pA Vb", "p_sans", "M1 V0", "M1 Va", "M1 Vb", "LC V0", "LC Va", "LC Vb"))
for (nm in OPT$triangles) {
  if (is.null(INFO[[nm]]$pA)) { sortie(nm, " : mesures non calculees"); next }
  sortie(sprintf("%-4s | %-10s %-10s %-10s %-10s | %-10s %-10s %-10s | %-10s %-10s %-10s", nm,
                 f6(gi(nm, "pA", "V0")), f6(gi(nm, "pA", "Va")), f6(gi(nm, "pA", "Vb")),
                 if (is.null(gi(nm, "p_sans"))) "-" else f6(gi(nm, "p_sans")),
                 f6(gi(nm, "fam", "V0", "M1")), f6(gi(nm, "fam", "Va", "M1")), f6(gi(nm, "fam", "Vb", "M1")),
                 f6(gi(nm, "fam", "V0", "LC")), f6(gi(nm, "fam", "Va", "LC")), f6(gi(nm, "fam", "Vb", "LC"))))
}
sortie("R0 : ", if (isTRUE(R0)) "VERT" else if (R0_EVALUABLE) "VERT SUR LES CONTROLES EVALUABLES" else "ROUGE", " ; (b) admissible : ", ok_nev(adm_b),
       " ; (a) admissible : ", ok_nev(adm_a), " ; choix mecanique : ", choix,
       if (OPT$essai) " (ESSAI, NON VERSABLE)" else if (!VERSABLE) " (NON VERSABLE)" else "")

titre("PIED")
chemin_script <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])
sha <- tryCatch(system2("git", c("rev-parse", "HEAD"), stdout = TRUE, stderr = FALSE),
                error = function(e) "indisponible")
sortie("duree totale : ", duree(T_DEBUT))
sortie(R.version.string)
sortie("RNGkind() : ", paste(RNGkind(), collapse = ", "))
sortie("graine = ", format(OPT$graine, scientific = FALSE), " ; graine secondaire = ",
       format(OPT$graine2, scientific = FALSE), " ; B = ", OPT$B)
sortie("git rev-parse HEAD : ", paste(sha, collapse = " "))
sortie("md5 R/engine.R : ", unname(tools::md5sum("R/engine.R")))
sortie("md5 R/charger_moteur.R : ", unname(tools::md5sum("R/charger_moteur.R")))
sortie("md5 mesure_620.R : ", if (is.na(chemin_script) || !file.exists(chemin_script)) "indisponible"
                               else unname(tools::md5sum(chemin_script)))
