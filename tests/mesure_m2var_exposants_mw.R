###############################################################################
#  tests/mesure_m2var_exposants_mw.R  --  LOI DE L'ECART DE var(r) A LA
#  REFERENCE (N - k)/(N - 1) SOUS TROIS EXPOSANTS DE VARIANCE (issue #503)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils, tools et parallel, livres avec R : utils::
#  sessionInfo(), tools::md5sum(), parallel::mclapply()). Il charge le moteur
#  par source("R/charger_moteur.R"); charger_moteur() (ADR 0016), ne modifie ni
#  R/engine.R ni tests/reference/ (lecture seule de reserve2.rds), et n'a pas
#  d'option --ecrire : il ecrit sur la console et n'ecrit un fichier que sur
#  l'option explicite --sortie FICHIER (jamais ecrase). Tous les libelles non
#  ASCII du script sont ecrits en echappements \u (fichier source ASCII) ;
#  sortie UTF-8 y compris sous LC_ALL=C (la categorie LC_CTYPE est basculee
#  sur une locale UTF-8 au demarrage si necessaire, #113).
#
#  Objet. La ligne M2 "Variance unitaire des residus de Mack" de mw_tests()
#  rend var(r) et sa valeur de reference (N - k)/(N - 1) : l'ecart vaut
#  exactement - N moyenne(r)^2 / (N - 1) (identite de la fiche mw:m2var). La
#  fiche mw:m2var (rubriques 4 et 6) cite la loi de cet ecart sous une variance
#  de C(i,j+1) en C(i,j)^0, C(i,j)^1 ou C(i,j)^2, et l'etendue de var(r) sur le
#  bootstrap de reserve2 ; ce script en est le support versionne (issue #503 ;
#  les chiffres du 08/11/2026 venaient d'une graine non consignee).
#
#  Statut des valeurs : CONSTAT DE SIMULATION SOUS UN PLAN (modele de Mack a
#  erreurs gaussiennes ajuste a reserve2, geometrie 8 x 8), aucun theoreme.
#
#  Modele generateur : COPIE DECLAREE de gen_triangle_scen(aj, tirer, delta = 0,
#  kappa = K, gamma = 0) de tests/puissance_mw_t8.R (meme recursion, meme ordre
#  de consommation des epsilon, meme arret au premier cumul invalide) :
#    C(i,j+1) = f_j C(i,j) + e sigma_j sqrt(C(i,j)^K Cb_j^(1 - K)),  e ~ N(0,1),
#  Cb_j = moyenne des C(0..I-j-1, j) SIMULES de la colonne. f_j et sigma_j^2
#  sont ceux de reserve2 (non reestimes). K dans {0, 1, 2}. La copie est
#  controlee mecaniquement (controle (copie)) : formals et corps de chaque
#  fonction copiee comparees (identical()) a celles du fichier relu par
#  parse(), jamais execute.
#  Plans (tests/puissance_mw_t8.R) : P1, premiere colonne de reserve2 ; P2,
#  premiere colonne mean(C0) + 3,4 (C0 - mean(C0)). Pas de P3.
#  Effectif : N_TRI = 2 000 triangles TIRES par cellule (plan, K), b = 1..2000.
#  Graines : triangle b du plan p (P1 = 1, P2 = 2) : 20261111 + 10000 (p - 1)
#  + b, COMMUNE AUX TROIS EXPOSANTS (nombres aleatoires communs) : la
#  comparaison entre exposants est APPARIEE, les trois colonnes d'un plan ne
#  sont pas independantes. Chaque tirage passe par engine_sous_graine(g, ...),
#  generateur ENGINE_RNG_KIND. Un triangle est admis par admettre() (copie
#  declaree : triangle complet, mw_valider_triangle(), mw_ajuster(), mw_msep(),
#  mw_valider_ajustement()) ; les refus sont comptes par motif.
#  Grandeurs par triangle admis, comme mw_tests() : figes <- .mw_ensembles_
#  figes(aj), res <- mw_residus(aj, figes$degeneres), r <- res$residu,
#  N = length(r), k = nombre de colonnes j distinctes, v = stats::var(r),
#  reference (N - k)/(N - 1), ecart = v - reference, defaut d'identite
#  |ecart + N mean(r)^2/(N - 1)|.
#  Sorties : T1 par cellule (plan, exposant) ; T2 comparaison appariee entre
#  exposants (maxima des differences, statistique D de Kolmogorov-Smirnov
#  DESCRIPTIVE, lecture mecanique du critere des IC disjoints) ; T2b parts a
#  |ecart| > 1e-3 appariees (triangles au-dela du seuil pour un seul exposant,
#  test exact de McNemar INDICATIF, sans seuil pre-specifie : ajout a la
#  specification de l'avis amont de K4, valide par actuary (validation de
#  #503)) ; T3 volet R.
#
#  Controles BLOQUANTS (code de sortie 1, aucun fichier ecrit s'ils echouent) :
#    (copie) copies declarees identiques a tests/puissance_mw_t8.R ;
#    (sc)    a K = 1, le generateur rend, a graine egale, le meme triangle que
#            la copie declaree de gen_triangle_h0() (identical(), graines des
#            100 premiers triangles de chaque plan) ;
#    (r2)    sur reserve2 lui-meme, la reference et mean(r) recalculees
#            donnent les deux nombres imprimes dans le detail de la reference
#            tests/reference/reserve2.rds : format(ref, digits = 6) et
#            format(mean(r), digits = 3) ;
#    (id)    defaut d'identite maximal sur tous les triangles admis <= 1e-12 ;
#    (flux)  volet R : le flux de triangles du volet R est celui de
#            mw_bootstrap() (sigma_boot recalcule identique).
#
#  Volet R (support de la rubrique 4 de mw:m2var) : B = 999 triangles du
#  bootstrap de residus de reserve2, tires par .mw_tirer_triangle_valide() sur
#  le vivier de .mw_pool_residus() sous engine_sous_graine(20260831, ...)
#  (seed par defaut de mw_bootstrap()), var(r) recalculee sur chacun avec les
#  colonnes degenerees figees a l'observe ; min, max et etendue restitues.
#
#  Usage (depuis la racine du depot) :
#      LC_ALL=C.UTF-8 Rscript tests/mesure_m2var_exposants_mw.R
#          [--n 2000] [--coeurs N] [--sans-volet-r] [--sortie FICHIER]
#  --n N : triangles tires par cellule (defaut 2000) ; une autre valeur, ou
#    --sans-volet-r, rend la sortie PROVISOIRE (marquee) et refuse --sortie.
#  --coeurs N : processus de parallel::mclapply() (defaut min(4, detectCores());
#    1 sous Windows). Le resultat ne depend ni du nombre de processus ni de
#    l'ordre (tout tirage passe par engine_sous_graine(), graines explicites).
#  --sortie FICHIER : ecrit aussi le tableau markdown dans FICHIER (dossier
#    existant, fichier jamais ecrase) ; destine a
#    docs/tableaux/<aaaammjj>-issue503-m2var-exposants.md.
#  Deux executions de suite, memes options, donnent une sortie identique, a
#  trois lignes pres du tableau d'en-tete : Commande, Processus, Duree.
#  Code de sortie : 0 si les controles tiennent, 1 sinon.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/mesure_m2var_exposants_mw.R"
SCRIPT_GEN <- "tests/puissance_mw_t8.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113) --------------------------------
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
OPTIONS_VALEUR <- c("--n", "--coeurs", "--sortie")
OPTIONS_DRAPEAU <- c("--sans-volet-r")
local({
  i <- 1L
  while (i <= length(ARGS)) {
    a <- ARGS[i]
    if (a %in% OPTIONS_VALEUR) {
      if (i == length(ARGS)) stop("option ", a, " sans valeur")
      i <- i + 2L
    } else if (a %in% OPTIONS_DRAPEAU) i <- i + 1L
    else stop("option inconnue : ", a)
  }
})
lire_option <- function(nom, defaut) {
  i <- match(nom, ARGS)
  if (is.na(i)) defaut else ARGS[i + 1L]
}
N_TRI_SPEC <- 2000L
N_TRI <- suppressWarnings(as.integer(lire_option("--n", as.character(N_TRI_SPEC))))
COEURS <- suppressWarnings(as.integer(lire_option("--coeurs",
            as.character(if (.Platform$OS.type == "windows") 1L else
              min(4L, max(1L, parallel::detectCores(), na.rm = TRUE))))))
OPT_SORTIE <- lire_option("--sortie", NA_character_)
SANS_VOLET_R <- "--sans-volet-r" %in% ARGS
if (is.na(N_TRI) || N_TRI < 1L) stop("--n : entier >= 1")
if (is.na(COEURS) || COEURS < 1L) stop("--coeurs : entier >= 1")
if (.Platform$OS.type == "windows") COEURS <- 1L
PROVISOIRE <- N_TRI != N_TRI_SPEC || SANS_VOLET_R
if (!is.na(OPT_SORTIE)) {
  if (PROVISOIRE) stop("--sortie : refuse avec --n different de ", N_TRI_SPEC, " ou --sans-volet-r (sortie provisoire)")
  if (!dir.exists(dirname(OPT_SORTIE))) stop("--sortie : dossier introuvable : ", dirname(OPT_SORTIE))
  if (file.exists(OPT_SORTIE)) stop("--sortie : fichier existant, jamais ecrase : ", OPT_SORTIE)
}

# --- Moteur (ADR 0016) ---------------------------------------------------------
if (!file.exists("R/engine.R")) stop("lancer depuis la racine du depot (R/engine.R introuvable)")
source("R/charger_moteur.R")
charger_moteur()

# --- Constantes du protocole -----------------------------------------------------
METHODE <- "reserve2"; SEGMENT <- 1; ANNEXE <- "II"
KAPPA_P2 <- 3.4                         # amplification de la premiere colonne (P2)
EXPOSANTS <- c(0, 1, 2)
PLANS <- c("P1", "P2")
GRAINE_M2VAR <- 20261111L
PAS_PLAN <- 10000L
SEUIL_ECART <- 1e-3                     # part des triangles admis a |ecart| > 1e-3
SEUIL_ID <- 1e-12                       # controle (id)
GRAINE_VOLET_R <- 20260831L             # seed par defaut de mw_bootstrap()
B_VOLET_R <- 999L
TAILLE_LOT <- 50L
graine_m2var <- function(plan, b) GRAINE_M2VAR + PAS_PLAN * (match(plan, PLANS) - 1L) + b

# --- Outils de sortie ----------------------------------------------------------------
nettoyer_champ <- function(s) gsub("[\t\r\n]+", " ", s)
ecrire_console <- function(x) writeLines(enc2utf8(x), con = stdout(), useBytes = TRUE)
md5_fichier <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
fe <- function(x, d = 2) if (length(x) != 1L || is.na(x)) "\u2014" else
  sub(".", ",", formatC(x, format = "e", digits = d), fixed = TRUE)
fd <- function(x, d = 4) if (length(x) != 1L || is.na(x)) "\u2014" else
  sub(".", ",", formatC(x, format = "f", digits = d), fixed = TRUE)
ic_cp <- function(k, n) if (n > 0) stats::binom.test(k, n)$conf.int[1:2] else c(NA_real_, NA_real_)
txt_ic <- function(ci) if (anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", fd(ci[1], 5), fd(ci[2], 5))
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(basename(extSoftVersion()[["BLAS"]])), txt(basename(La_library())), txt(La_version()))
}
git <- function(...) suppressWarnings(system2("git", c(...), stdout = TRUE, stderr = FALSE))

# --- Donnees : reserve2 (lecture seule de la reference) ------------------------------
REF <- readRDS(file.path("tests", "reference", "reserve2.rds"))
AJ0 <- mw_ajuster(REF$ajustement$tri)
CONTROLE_AJ0 <- identical(AJ0$sigma2, REF$ajustement$sigma2)
if (!CONTROLE_AJ0) {
  message("ARRET : mw_ajuster() du triangle de reserve2.rds ne redonne pas ajustement$sigma2 (identical())")
  quit(status = 1L)
}

# --- Copies declarees de tests/puissance_mw_t8.R (controle (copie)) -----------------
# Tireur des epsilon de la loi N(0, 1) : restriction a la loi N du tireur(loi)
# de tests/puissance_mw_t8.R (non controlee par (copie), qui compare des
# fonctions entieres) ; meme appel, stats::rnorm(n).
tireur <- function(loi) switch(loi,
  N = function(n) stats::rnorm(n))
# Generateur du DGP de #206 -- copie declaree de tests/puissance_mw_t8.R.
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
# Admission d'un triangle simule -- copie declaree de tests/puissance_mw_t8.R.
admettre <- function(tri) {
  if (.mw_triangle_incomplet(tri)) return(list(ok = FALSE, motif = "cellule <= 0"))
  v <- mw_valider_triangle(tri, segment = SEGMENT, annexe = ANNEXE)
  if (!isTRUE(v$ok)) return(list(ok = FALSE, motif = nettoyer_champ(paste("mw_valider_triangle :", paste(v$erreurs, collapse = " ; ")))))
  aj <- tryCatch(mw_ajuster(tri), error = function(e) e)
  if (inherits(aj, "error")) return(list(ok = FALSE, motif = nettoyer_champ(paste("mw_ajuster en erreur :", conditionMessage(aj)))))
  ms <- tryCatch(mw_msep(aj), error = function(e) e)
  if (inherits(ms, "error")) return(list(ok = FALSE, motif = nettoyer_champ(paste("mw_msep en erreur :", conditionMessage(ms)))))
  va <- mw_valider_ajustement(aj, ms$msep)
  if (!isTRUE(va$ok)) return(list(ok = FALSE, motif = nettoyer_champ(paste("mw_valider_ajustement :", paste(va$erreurs, collapse = " ; ")))))
  list(ok = TRUE, motif = NA_character_, aj = aj)
}
# Generateur des scenarios de moyenne, de variance et de derive -- copie
# declaree de tests/puissance_mw_t8.R ; ici delta = 0 et gamma = 0 (moyenne du
# modele de Mack), seul kappa varie : variance sigma_j^2 C^kappa Cb_j^(1 - kappa).
gen_triangle_scen <- function(aj, tirer, delta = 0, kappa = 1, gamma = 0) {
  I <- aj$I; J <- aj$J
  tri <- matrix(NA_real_, I + 1, J + 1)
  tri[, 1] <- aj$tri[, 1]
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    sg <- sqrt(aj$sigma2[j + 1])
    if (!is.finite(sg)) sg <- 0
    e <- tirer(length(idx))
    Cij <- tri[idx + 1, j + 1]
    Cb <- mean(Cij)
    mu <- delta * aj$f[j + 1] * Cb + (aj$f[j + 1] * (1 - delta) + gamma * (sg / sqrt(Cb)) * (idx - (I - j - 1) / 2)) * Cij
    nv <- mu + e * sg * sqrt(Cij^kappa * Cb^(1 - kappa))
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

COPIES_FONCTIONS <- c("nettoyer_champ", "gen_triangle_h0", "admettre", "gen_triangle_scen")
COPIES_CONSTANTES <- c("METHODE", "SEGMENT", "ANNEXE", "KAPPA_P2")
controle_copie <- function() {
  ex <- tryCatch(parse(SCRIPT_GEN, keep.source = FALSE, encoding = "UTF-8"), error = function(e) NULL)
  if (is.null(ex)) return(list(ok = FALSE, txt = sprintf("%s illisible : copie non contr\u00f4lable", SCRIPT_GEN)))
  defs <- list()
  for (e in ex) if (is.call(e) && as.character(e[[1]])[1] %in% c("<-", "=") && is.name(e[[2]])) defs[[as.character(e[[2]])]] <- e[[3]]
  genv <- globalenv()
  ko_f <- COPIES_FONCTIONS[!vapply(COPIES_FONCTIONS, function(nm) {
    d <- defs[[nm]]; if (is.null(d)) return(FALSE)
    a <- tryCatch(eval(d, envir = genv), error = function(e) NULL); b <- get(nm, envir = genv)
    is.function(a) && identical(formals(a), formals(b)) && identical(body(a), body(b))
  }, logical(1))]
  ko_c <- COPIES_CONSTANTES[!vapply(COPIES_CONSTANTES, function(nm) {
    d <- defs[[nm]]; if (is.null(d)) return(FALSE)
    identical(tryCatch(eval(d, envir = genv), error = function(e) NULL), get(nm, envir = genv))
  }, logical(1))]
  list(ok = !length(ko_f) && !length(ko_c),
       txt = sprintf("%d fonctions et %d constantes de %s (md5 %s) identiques (formals, corps ; valeur) \u00e0 celles de ce script%s",
                     length(COPIES_FONCTIONS), length(COPIES_CONSTANTES), SCRIPT_GEN, md5_fichier(SCRIPT_GEN),
                     if (length(c(ko_f, ko_c))) paste0(" ; DIFF\u00c9RENTES OU ABSENTES : ", paste(c(ko_f, ko_c), collapse = ", ")) else ""))
}

# --- Plans (tests/puissance_mw_t8.R, par. 2.2) ---------------------------------------
C0_P1 <- AJ0$tri[, 1]
C0_P2 <- mean(C0_P1) + KAPPA_P2 * (C0_P1 - mean(C0_P1))
COL0 <- list(P1 = C0_P1, P2 = C0_P2)
AJ_PLAN <- lapply(stats::setNames(PLANS, PLANS), function(plan) { a <- AJ0; a$tri[, 1] <- COL0[[plan]]; a })

# --- Grandeurs d'un triangle admis (comme mw_tests()) --------------------------------
grandeurs <- function(aj) {
  figes <- .mw_ensembles_figes(aj)
  res <- mw_residus(aj, figes$degeneres)
  r <- res$residu; N <- length(r); k <- length(unique(res$j))
  if (N < 2L) return(list(ok = FALSE, motif = "moins de 2 r\u00e9sidus"))
  v <- stats::var(r); ref <- (N - k) / (N - 1); ecart <- v - ref
  list(ok = TRUE, ecart = ecart, defaut = abs(ecart + N * mean(r)^2 / (N - 1)), N = N, k = k)
}
mesurer_triangle <- function(plan, kappa, b) {
  tri <- engine_sous_graine(graine_m2var(plan, b),
                            gen_triangle_scen(AJ_PLAN[[plan]], tireur("N"), delta = 0, kappa = kappa, gamma = 0))
  adm <- admettre(tri)
  if (!adm$ok) return(list(ok = FALSE, motif = adm$motif))
  grandeurs(adm$aj)
}

# --- Controles avant la boucle ---------------------------------------------------------
controle_sc <- function() {
  ok <- vapply(PLANS, function(plan) sum(vapply(1:100, function(b) {
    g <- graine_m2var(plan, b)
    identical(engine_sous_graine(g, gen_triangle_scen(AJ_PLAN[[plan]], tireur("N"), delta = 0, kappa = 1, gamma = 0)),
              engine_sous_graine(g, gen_triangle_h0(AJ_PLAN[[plan]], tireur("N"))))
  }, logical(1))), 1L)
  list(ok = all(ok == 100L),
       txt = sprintf("\u00e0 K = 1, gen_triangle_scen() = gen_triangle_h0() sous la m\u00eame graine, identical(), sur %d / 100 graines de P1 et %d / 100 de P2 (b = 1..100)",
                     ok[["P1"]], ok[["P2"]]))
}
controle_r2 <- function() {
  det <- REF$tests[[which(vapply(REF$tests, function(t) identical(t$test, "Variance unitaire des residus de Mack"), TRUE))]]$detail
  figes <- .mw_ensembles_figes(AJ0)
  res <- mw_residus(AJ0, figes$degeneres); r <- res$residu; N <- length(r); k <- length(unique(res$j))
  ref_txt <- format((N - k) / (N - 1), digits = 6, decimal.mark = ".")
  moy_txt <- format(mean(r), digits = 3, decimal.mark = ".")
  ref_det <- sub(".*reference ([0-9.]+)[, )].*", "\\1", det)
  moy_det <- sub(".*ici ([^ ]+)\\. .*", "\\1", det)
  list(ok = identical(ref_txt, ref_det) && identical(moy_txt, moy_det), ref = (N - k) / (N - 1),
       txt = sprintf("reserve2 : N = %d, k = %d ; r\u00e9f\u00e9rence recalcul\u00e9e %s (detail : %s), moyenne des r\u00e9sidus recalcul\u00e9e %s (detail : %s)",
                     N, k, ref_txt, ref_det, moy_txt, moy_det))
}
CTL_COPIE <- controle_copie()
CTL_SC <- controle_sc()
CTL_R2 <- controle_r2()
avant <- list(copie = CTL_COPIE, sc = CTL_SC, r2 = CTL_R2)
if (!all(vapply(avant, function(x) isTRUE(x$ok), TRUE))) {
  for (nm in names(avant)) if (!isTRUE(avant[[nm]]$ok)) message("ARRET, contr\u00f4le (", nm, ") en \u00e9chec : ", avant[[nm]]$txt)
  quit(status = 1L)
}

# --- Boucle : plans x exposants x triangles ------------------------------------------
cat("Mesure :", length(PLANS) * length(EXPOSANTS) * N_TRI, "tirages (", N_TRI, "par cellule ),",
    COEURS, "processus\n", file = stderr())
lots <- split(seq_len(N_TRI), ceiling(seq_len(N_TRI) / TAILLE_LOT))
jobs <- unlist(lapply(PLANS, function(plan) lapply(seq_along(lots), function(l) list(plan = plan, b = lots[[l]]))),
               recursive = FALSE)
sorties <- parallel::mclapply(jobs, function(j) tryCatch(
  lapply(stats::setNames(EXPOSANTS, EXPOSANTS), function(kappa)
    lapply(j$b, function(b) mesurer_triangle(j$plan, kappa, b))),
  error = function(e) structure(conditionMessage(e), class = "echec")),
  mc.cores = COEURS, mc.preschedule = FALSE)
echecs <- vapply(sorties, function(x) inherits(x, "echec") || inherits(x, "try-error"), TRUE)
if (any(echecs)) {
  message("ARRET : ", paste(utils::head(unique(unlist(sorties[echecs])), 3), collapse = " ; "))
  quit(status = 1L)
}
# Par plan et exposant : liste des resultats dans l'ordre de b.
RES <- lapply(stats::setNames(PLANS, PLANS), function(plan) {
  idx <- which(vapply(jobs, function(j) j$plan == plan, TRUE))
  lapply(stats::setNames(as.character(EXPOSANTS), EXPOSANTS), function(kn)
    do.call(c, lapply(idx, function(i) sorties[[i]][[kn]])))
})

# --- Resume par cellule ----------------------------------------------------------------
resume_cellule <- function(lst) {
  adm <- vapply(lst, function(x) isTRUE(x$ok), TRUE)
  ecart <- vapply(lst[adm], function(x) x$ecart, 0)
  defaut <- vapply(lst[adm], function(x) x$defaut, 0)
  motifs <- table(vapply(lst[!adm], function(x) x$motif, ""))
  k <- sum(abs(ecart) > SEUIL_ECART)
  q <- stats::quantile(abs(ecart), c(0.5, 0.9, 0.99), names = FALSE)
  list(tires = length(lst), admis = sum(adm), motifs = motifs,
       max = max(abs(ecart)), q = q, moyenne = mean(ecart),
       k_sup = k, part = k / sum(adm), ic = ic_cp(k, sum(adm)),
       defaut = max(defaut), adm = adm, ecart = ecart)
}
CELL <- lapply(RES, function(p) lapply(p, resume_cellule))
# Comparaison appariee sur les triangles admis sous les trois exposants.
apparie <- function(plan) {
  e <- vapply(as.character(EXPOSANTS), function(kn) vapply(RES[[plan]][[kn]], function(x)
    if (isTRUE(x$ok)) x$ecart else NA_real_, 0), numeric(N_TRI))
  ok <- stats::complete.cases(e)
  # Statistique D de Kolmogorov-Smirnov entre les lois de |ecart| de deux exposants,
  # DESCRIPTIVE (echantillons non independants : aucune p-value lue).
  d_ks <- function(a, b) suppressWarnings(unname(stats::ks.test(abs(a), abs(b))$statistic))
  # Parts a |ecart| > 1e-3, comparaison appariee de deux exposants (i, j) : triangles
  # au-dela du seuil pour l'un seul ; test exact de McNemar bilateral (binom.test), a
  # titre INDICATIF (aucun seuil pre-specifie ; trois comparaisons par plan).
  mcn <- function(i, j) {
    x <- abs(e[ok, i]) > SEUIL_ECART; y <- abs(e[ok, j]) > SEUIL_ECART
    n_i <- sum(x & !y); n_j <- sum(!x & y)
    list(n_i = n_i, n_j = n_j, p = if (n_i + n_j > 0L) stats::binom.test(n_i, n_i + n_j)$p.value else NA_real_)
  }
  list(n = sum(ok), n_adm = colSums(!is.na(e)),
       max01 = max(abs(e[ok, 1] - e[ok, 2])), max21 = max(abs(e[ok, 3] - e[ok, 2])),
       ks01 = d_ks(e[ok, 1], e[ok, 2]), ks21 = d_ks(e[ok, 3], e[ok, 2]),
       mc01 = mcn(1, 2), mc21 = mcn(3, 2), mc02 = mcn(1, 3))
}
APP <- lapply(stats::setNames(PLANS, PLANS), apparie)
# Lecture mecanique du critere d'actuary : intervalles de Clopper-Pearson des parts
# a |ecart| > 1e-3 deux a deux sans intersection au sein d'un plan ?
disjoints <- function(plan) {
  ic <- lapply(CELL[[plan]], `[[`, "ic")
  pr <- utils::combn(length(ic), 2)
  any(apply(pr, 2, function(p) ic[[p[1]]][2] < ic[[p[2]]][1] || ic[[p[2]]][2] < ic[[p[1]]][1]))
}
DISJ <- vapply(PLANS, disjoints, TRUE)
DEFAUT_MAX <- max(vapply(CELL, function(p) max(vapply(p, `[[`, 0, "defaut")), 0))
CTL_ID <- list(ok = is.finite(DEFAUT_MAX) && DEFAUT_MAX <= SEUIL_ID,
               txt = sprintf("d\u00e9faut d'identit\u00e9 maximal sur les %d triangles admis : %s (seuil %s)",
                             sum(vapply(CELL, function(p) sum(vapply(p, `[[`, 0, "admis")), 0)),
                             fe(DEFAUT_MAX), fe(SEUIL_ID, 0)))

# --- Volet R : bootstrap de residus de reserve2 ----------------------------------------
volet_r <- function() {
  aj <- AJ0
  figes <- .mw_ensembles_figes(aj)
  pool <- .mw_pool_residus(aj, figes$degeneres)
  n_max <- FACTEUR_B_MAX_MW * (as.numeric(B_VOLET_R) + 1)
  v <- Nn <- kk <- defaut <- sig <- rep(NA_real_, B_VOLET_R)
  n_tires <- 0; echec_ajust <- 0L; plafond <- FALSE
  engine_sous_graine(GRAINE_VOLET_R, {
    for (b in seq_len(B_VOLET_R)) {
      tir <- .mw_tirer_triangle_valide(aj, pool, n_max - n_tires)
      n_tires <- n_tires + tir$n
      if (is.null(tir$tri)) { plafond <- TRUE; next }
      ab <- try(mw_ajuster(tir$tri), silent = TRUE)
      if (inherits(ab, "try-error")) { echec_ajust <- echec_ajust + 1L; next }
      res <- mw_residus(ab, figes$degeneres); r <- res$residu
      Nn[b] <- length(r); kk[b] <- length(unique(res$j))
      v[b] <- stats::var(r)
      defaut[b] <- abs(v[b] - (Nn[b] - kk[b]) / (Nn[b] - 1) + Nn[b] * mean(r)^2 / (Nn[b] - 1))
      mb <- try(mw_msep(ab), silent = TRUE)
      if (!inherits(mb, "try-error") && is.finite(mb$msep) && ab$reserve > 0) sig[b] <- sqrt(mb$msep) / ab$reserve
    }
  })
  bs <- mw_bootstrap(aj, B = B_VOLET_R, seed = GRAINE_VOLET_R, figes = figes)
  flux <- identical(sig[is.finite(sig)], bs$sigma_boot)
  list(v = v, N = Nn, k = kk, defaut = defaut, n_tires = n_tires, echec = echec_ajust, plafond = plafond,
       flux = flux, n_sig = sum(is.finite(sig)))
}
VR <- if (SANS_VOLET_R) NULL else volet_r()
CTL_FLUX <- if (is.null(VR)) NULL else list(ok = isTRUE(VR$flux),
  txt = sprintf("sigma_boot recalcul\u00e9 sur le flux du volet R identique (identical()) \u00e0 mw_bootstrap(aj, B = %d, seed = %d)$sigma_boot, sur %d valeurs",
                B_VOLET_R, GRAINE_VOLET_R, VR$n_sig))
CTL_ID_R <- if (is.null(VR)) NULL else list(ok = all(VR$defaut[is.finite(VR$defaut)] <= SEUIL_ID),
  txt = sprintf("volet R : d\u00e9faut d'identit\u00e9 maximal %s sur %d triangles (seuil %s)", fe(max(VR$defaut, na.rm = TRUE)),
                sum(is.finite(VR$defaut)), fe(SEUIL_ID, 0)))
apres <- Filter(Negate(is.null), list(id = CTL_ID, flux = CTL_FLUX, id_R = CTL_ID_R))
TOUS <- c(avant, apres)
STATUT_OK <- all(vapply(TOUS, function(x) isTRUE(x$ok), TRUE))

# --- Sortie markdown -------------------------------------------------------------------
duree <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
commit <- git("rev-parse", "HEAD")
propre <- length(git("status", "--porcelain")) == 0L
cmd <- paste(c(sprintf("LC_ALL=%s", Sys.getenv("LC_ALL", unset = "")), "Rscript", SCRIPT, ARGS), collapse = " ")
ok_txt <- function(x) if (isTRUE(x$ok)) "OK" else "\u00c9CHEC"

md <- c(
  "# Loi de l'\u00e9cart de var(r) \u00e0 la r\u00e9f\u00e9rence (N \u2212 k)/(N \u2212 1) sous trois exposants de variance (issue #503)",
  "",
  if (PROVISOIRE) "**SORTIE PROVISOIRE** (--n diff\u00e9rent de 2 000 ou --sans-volet-r) : ne pas verser.",
  if (PROVISOIRE) "",
  "| Grandeur | Valeur |", "|---|---|",
  sprintf("| Date | %s |", format(Sys.Date(), "%Y-%m-%d")),
  sprintf("| Commande | `%s` (depuis la racine du d\u00e9p\u00f4t) |", cmd),
  sprintf("| Script | `%s`, md5 `%s` |", SCRIPT, md5_fichier(SCRIPT)),
  sprintf("| Moteur | `R/engine.R`, md5 `%s` |", md5_fichier(file.path("R", "engine.R"))),
  sprintf("| Commit de base | `%s` (%s) |", if (length(commit)) commit[1] else "inconnu",
          if (propre) "arbre propre" else "arbre de travail modifi\u00e9 : script et moteur identifi\u00e9s par leur md5"),
  sprintf("| R, plateforme | %s |", plateforme_calcul()),
  sprintf("| G\u00e9n\u00e9rateur | %s, %s, %s |", ENGINE_RNG_KIND[["kind"]], ENGINE_RNG_KIND[["normal.kind"]], ENGINE_RNG_KIND[["sample.kind"]]),
  sprintf("| Graines | triangle b du plan p (P1 = 1, P2 = 2) : %d + %d (p \u2212 1) + b, commune aux trois exposants ; volet R : %d |",
          GRAINE_M2VAR, PAS_PLAN, GRAINE_VOLET_R),
  sprintf("| Effectifs | %d triangles tir\u00e9s par cellule (plan, exposant), soit %d tirages ; volet R : B = %d |",
          N_TRI, length(PLANS) * length(EXPOSANTS) * N_TRI, B_VOLET_R),
  sprintf("| Processus | %d |", COEURS),
  sprintf("| Dur\u00e9e | %.0f s |", duree),
  "",
  "Statut : constat de simulation sous un plan (mod\u00e8le de Mack gaussien ajust\u00e9 \u00e0 `reserve2`, g\u00e9om\u00e9trie 8 \u00d7 8) ; aucun th\u00e9or\u00e8me.",
  "Les IC de Clopper\u2013Pearson et les p de T2b ne mesurent que l'incertitude due au nombre fini de triangles tir\u00e9s (2 000 par cellule) ; ils ne disent rien d'un autre plan ni d'une autre g\u00e9om\u00e9trie.",
  "Mod\u00e8le : C(i,j+1) = f_j C(i,j) + e \u03c3_j \u221a(C(i,j)^\u03ba Cb_j^(1\u2212\u03ba)), e ~ N(0,1), Cb_j = moyenne des C(0..I\u2212j\u22121, j) simul\u00e9s de la colonne ; f_j et \u03c3_j\u00b2 de `reserve2` ;",
  "\u03ba \u2208 {0, 1, 2}. Plans de `tests/puissance_mw_t8.R` : P1, premi\u00e8re colonne de `reserve2` ; P2, premi\u00e8re colonne mean(C0) + 3,4 (C0 \u2212 mean(C0)).",
  "**Les trois exposants d'un m\u00eame plan partagent les m\u00eames graines (nombres al\u00e9atoires communs) : leurs colonnes ne sont pas ind\u00e9pendantes, et la comparaison est appari\u00e9e.**",
  "\u00c9cart = var(r) \u2212 (N \u2212 k)/(N \u2212 1) = \u2212 N moyenne(r)\u00b2/(N \u2212 1) (identit\u00e9 exacte de la fiche `mw:m2var`), calcul\u00e9 comme `mw_tests()` sur les r\u00e9sidus de `mw_residus()`.",
  "Quantiles de |\u00e9cart| : type 7 de `stats::quantile()`. IC : Clopper\u2013Pearson \u00e0 95 %. Nombres : notation scientifique, virgule d\u00e9cimale.",
  "",
  "## Contr\u00f4les (tous bloquants)", "",
  "| Contr\u00f4le | R\u00e9sultat | D\u00e9tail |", "|---|---|---|")
for (nm in names(TOUS)) md <- c(md, sprintf("| (%s) | %s | %s |", sub("id_R", "id, volet R", nm), ok_txt(TOUS[[nm]]), TOUS[[nm]]$txt))
md <- c(md, "",
  "## T1 \u2014 Loi de l'\u00e9cart par plan et par exposant", "",
  "| Plan | \u03ba | Tir\u00e9s | Admis | max \\|\u00e9cart\\| | q50 | q90 | q99 | \u00e9cart moyen | \\|\u00e9cart\\| > 1e-3 | Part | IC 95 % de la part | D\u00e9faut d'identit\u00e9 max |",
  "|---|---|---|---|---|---|---|---|---|---|---|---|---|")
for (plan in PLANS) for (kn in as.character(EXPOSANTS)) {
  c1 <- CELL[[plan]][[kn]]
  md <- c(md, sprintf("| %s | %s | %d | %d | %s | %s | %s | %s | %s | %d | %s | %s | %s |", plan, kn, c1$tires, c1$admis,
                      fe(c1$max), fe(c1$q[1]), fe(c1$q[2]), fe(c1$q[3]), fe(c1$moyenne), c1$k_sup, fd(c1$part, 5),
                      txt_ic(c1$ic), fe(c1$defaut)))
}
refus <- unlist(lapply(PLANS, function(plan) lapply(as.character(EXPOSANTS), function(kn) {
  m <- CELL[[plan]][[kn]]$motifs
  if (!length(m)) NULL else sprintf("- %s, \u03ba = %s : %s", plan, kn, paste(sprintf("%d \u00d7 \u00ab %s \u00bb", as.integer(m), names(m)), collapse = " ; "))
})))
md <- c(md, "", "Refus par motif (admettre()) :", "", if (length(refus)) refus else "Aucun refus : tous les triangles tir\u00e9s sont admis.")
md <- c(md, "",
  "## T2 \u2014 Comparaison appari\u00e9e entre exposants (triangles admis sous les trois exposants)", "",
  "| Plan | Triangles appari\u00e9s | max \\|\u00e9cart(\u03ba=0) \u2212 \u00e9cart(\u03ba=1)\\| | max \\|\u00e9cart(\u03ba=2) \u2212 \u00e9cart(\u03ba=1)\\| | D de KS, \\|\u00e9cart\\| \u03ba=0 contre \u03ba=1 | D de KS, \u03ba=2 contre \u03ba=1 | Crit\u00e8re de l'avis amont : IC de T1 disjoints (appariement ignor\u00e9) |",
  "|---|---|---|---|---|---|---|")
for (plan in PLANS) {
  a <- APP[[plan]]
  md <- c(md, sprintf("| %s | %d | %s | %s | %s | %s | %s |", plan, a$n, fe(a$max01), fe(a$max21), fd(a$ks01, 3), fd(a$ks21, 3),
                      if (DISJ[[plan]]) "oui" else "non"))
}
md <- c(md, "",
  "### T2b \u2014 Parts \u00e0 |\u00e9cart| > 1e-3 : comparaison appari\u00e9e", "",
  "| Plan | Comparaison | Seul au-del\u00e0 du seuil : 1er exposant | Seul au-del\u00e0 du seuil : 2e exposant | p bilat\u00e9ral du test exact de McNemar (indicatif) |",
  "|---|---|---|---|---|")
for (plan in PLANS) {
  a <- APP[[plan]]
  for (cp in list(list("\u03ba=0 contre \u03ba=1", a$mc01), list("\u03ba=2 contre \u03ba=1", a$mc21), list("\u03ba=0 contre \u03ba=2", a$mc02)))
    md <- c(md, sprintf("| %s | %s | %d | %d | %s |", plan, cp[[1]], cp[[2]]$n_i, cp[[2]]$n_j, fe(cp[[2]]$p)))
}
md <- c(md, "",
  "T2b : triangles appari\u00e9s (m\u00eames graines). Test exact de McNemar : loi binomiale de param\u00e8tre 1/2 sur les triangles discordants. Le p est indicatif : trois comparaisons par plan, sans seuil ni correction de multiplicit\u00e9 pr\u00e9-sp\u00e9cifi\u00e9s. Il porte sur le mod\u00e8le de simulation, non sur des donn\u00e9es observ\u00e9es : un p petit dit que le d\u00e9calage des parts entre exposants ne s'explique pas par le nombre fini de triangles tir\u00e9s, non qu'il est grand ; sa taille se lit dans T1.",
  "D de KS : statistique descriptive entre les lois empiriques de |\u00e9cart| de deux exposants (\u00e9chantillons non ind\u00e9pendants : aucune p-value n'en est tir\u00e9e).",
  "La derni\u00e8re colonne est la lecture m\u00e9canique du crit\u00e8re de l'avis amont de K4 (\u00a7 5.3) : \u00ab oui \u00bb si deux des trois IC de Clopper\u2013Pearson de la part \u00e0 |\u00e9cart| > 1e-3 sont disjoints au sein du plan. Ce crit\u00e8re ignore l'appariement et est conservateur : \u00ab non \u00bb ne signifie pas l'absence de diff\u00e9rence entre exposants ; la comparaison appari\u00e9e est en T2b.")
if (!is.null(VR)) {
  rv <- range(VR$v, na.rm = TRUE)
  md <- c(md, "",
    "## T3 \u2014 Volet R : bootstrap de r\u00e9sidus de `reserve2` (support de la rubrique 4 de `mw:m2var`)", "",
    sprintf("%d triangles par `.mw_tirer_triangle_valide()` sur le vivier de `.mw_pool_residus()`, `engine_sous_graine(%d, ...)` ; var(r) recalcul\u00e9e sur chacun, colonnes d\u00e9g\u00e9n\u00e9r\u00e9es fig\u00e9es \u00e0 l'observ\u00e9.",
            B_VOLET_R, GRAINE_VOLET_R),
    "",
    "| Grandeur | Valeur |", "|---|---|",
    sprintf("| Triangles tir\u00e9s (retir\u00e9s compris) / retenus | %d / %d |", as.integer(VR$n_tires), sum(is.finite(VR$v))),
    sprintf("| \u00c9checs de `mw_ajuster()` | %d |", VR$echec),
    sprintf("| Plafond de retirage atteint | %s |", if (VR$plafond) "oui" else "non"),
    sprintf("| (N, k) observ\u00e9s | %s |", paste(unique(sprintf("(%d, %d)", as.integer(VR$N[is.finite(VR$N)]), as.integer(VR$k[is.finite(VR$k)]))), collapse = " ; ")),
    sprintf("| R\u00e9f\u00e9rence (N \u2212 k)/(N \u2212 1) de `reserve2` | %s |", sub(".", ",", format(CTL_R2$ref, digits = 6), fixed = TRUE)),
    sprintf("| min var(r) | %s |", sub(".", ",", formatC(rv[1], format = "f", digits = 5), fixed = TRUE)),
    sprintf("| max var(r) | %s |", sub(".", ",", formatC(rv[2], format = "f", digits = 5), fixed = TRUE)),
    sprintf("| \u00c9tendue | %s |", fe(rv[2] - rv[1])))
}
md <- c(md, "", sprintf("**%s**", if (STATUT_OK) "Tous les contr\u00f4les tiennent." else "AU MOINS UN CONTR\u00d4LE EN \u00c9CHEC : ne pas verser."))

ecrire_console(md)
if (!is.na(OPT_SORTIE) && STATUT_OK) {
  if (file.exists(OPT_SORTIE)) stop("--sortie : fichier existant, jamais ecrase : ", OPT_SORTIE)
  con <- file(OPT_SORTIE, open = "wb"); writeLines(enc2utf8(md), con, useBytes = TRUE); close(con)
  cat(sprintf("\nEcrit : %s\n", OPT_SORTIE), file = stderr())
}
quit(status = if (STATUT_OK) 0L else 1L)
