###############################################################################
#  tests/mesure_calendaire_t8.R  --  TEST CALENDAIRE DE MACK A T = 8 :
#  FORME BILATERALE ("deux") CONTRE FORME UNILATERALE ("bas") (issue #276)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils, tools et parallel, livres avec R). Il ne modifie ni
#  R/engine.R, ni tests/reference/, ni le catalogue MW_CATALOGUE_MC : la forme
#  "bas" est construite LOCALEMENT par copie de l'entree Calendrier du
#  catalogue avec la queue "bas" (ENT_BAS). Tous les libelles non ASCII sont
#  ecrits en echappements \u (fichier source ASCII).
#
#  Protocole : docs/specifications/fd-test-calendaire.md, par. 2.3 (etape 2
#  du par. 8), decisions du mainteneur du 14/10/2026 (annotation D1-Fd :
#  Q-Fd-2 adoptee, scenario de compensation inclus). Renvois :
#    par. 2.1 : reproduction de la boucle de tirage de mw_bootstrap()
#               (meme graine, meme pool .mw_pool_residus(), meme
#               .mw_tirer_triangle_valide(), meme plafond FACTEUR_B_MAX_MW
#               (B + 1)), statistique calendaire seule, ensembles figes de
#               .mw_ensembles_figes(aj) ;
#    par. 2.2 : alternatives, effet multiplicatif sur les INCREMENTS de
#               l'exercice t = i + k du triangle simule sous H0, puis
#               recumule (dernier t = 7 ; median t = 4 ; derive
#               (1 + g)^max(0, t - 3) ; compensation t = 6, facteur
#               1 + (-1)^i theta) ;
#    par. 2.3 : plan, oracle, graines, controles (a) et (i2), sorties T0 a T6,
#               critere K1 (texte recopie tel quel dans TEXTE_K1 et au T0,
#               evalue mecaniquement) ;
#    DGP de #206 (docs/specifications/206-calibration-mc-merz-wuthrich.md,
#    par. 2) : modele de Mack ajuste a reserve2, premiere colonne fixee, lois
#    N, E et A, generateur gen_triangle_h0() et admission admettre(), copies
#    de tests/calibration_mc_mw_t8.R.
#
#  Statut des valeurs : CONSTAT DE SIMULATION SOUS UN PLAN (modele de Mack
#  ajuste a reserve2), pas un resultat general. Aucun theoreme ne couvre ce
#  test bootstrap a T = 8.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/mesure_calendaire_t8.R --travail DOSSIER [--coeurs 4]
#          [--ecrire [--remplacer]]
#      Rscript tests/mesure_calendaire_t8.R --essai --travail DOSSIER [--R 2]
#          [--N0 200] [--B 999] [--coeurs 4]
#      Rscript tests/mesure_calendaire_t8.R --controle-i2prime BRUT.tsv
#          [--B 999]
#  --travail DOSSIER (OBLIGATOIRE hors --controle-i2prime, refus explicite
#    s'il manque ; aucun chemin par defaut dans le script) : repertoire de
#    travail HORS du depot (cree au besoin), qui recoit une sauvegarde par
#    tranche (tranche-<cellule>-<b1>-<b2>.rds, oracle-<loi>-<k1>-<k2>.rds)
#    et, sans --ecrire, les deux fichiers de sortie.
#  Reprise : une execution relancee sur le meme DOSSIER reprend les tranches
#    deja sauvegardees dont la signature (parametres, md5 du script,
#    empreinte sans commentaires de R/engine.R) est identique, et ne calcule
#    que les manquantes ; une sauvegarde de signature differente est REFUSEE
#    (arret). Un echantillon regulier de tranches reprises (N_ECH_REPRISE) est
#    recalcule sur sa premiere ligne et compare hors duree (arret sinon).
#    Les tranches de l'essai ont leur propre sous-dossier (signature
#    differente).
#  --coeurs n : processus paralleles (parallel::mclapply, une tranche par
#    tache ; 1 sous Windows).
#  --ecrire : ecrit docs/tableaux/<AAAAMMJJ>-issue276-calendaire.md et
#    -brut.tsv (date d'execution). REFUSE : essai, commit non propre ou
#    script non suivi (motifs_non_versionnable()), tableau existant sans
#    --remplacer (garde_ecrasement(), #173), chemin absolu ou /tmp dans le
#    tableau. Sans --ecrire, les memes fichiers sont ecrits dans
#    DOSSIER/sortie/ (jamais ecrases).
#  --essai : plan reduit (R triangles par cellule, N0 par loi, B
#    replications), NON versionnable ; imprime la duree par triangle et
#    l'estimation de la duree complete.
#  --controle-i2prime BRUT.tsv : controle (i2') de l'etape 3 de Fd (a lancer
#    par audit sur le moteur MODIFIE, entree Calendrier du catalogue en queue
#    "bas") ; mode a part, sans calcul de tranche ni ecriture : la garde
#    "queue == deux" et le controle (a) sont sautes (la garde est remplacee
#    par "queue == bas") ; reserve2 (graine 20260831, B = 999) et chaque
#    triangle marque i2 = OK du fichier de valeurs brutes BRUT.tsv sont
#    regeneres par leurs graines (cellule, b ; graines relues dans le fichier
#    et comparees au calcul) et mw_bootstrap(aj, B, graine) du moteur doit
#    rendre, cle Calendrier, p_mc et p_min_mc identiques (identical()) a la
#    forme "bas" du script (reserve2 : calcul du script ; triangles du plan :
#    colonnes p_bas et pmm_bas du fichier) ; stop() au premier ecart. --B :
#    B de l'execution qui a produit BRUT.tsv (defaut 999).
#
#  Controles (arret par stop() si l'un echoue ; spec par. 2.3) :
#    (a)  reserve2 (triangle de tests/outils_tests.R, graine 20260831,
#         B = 999) : p_mc et p_min_mc "deux" du script identiques a ceux de
#         tests/reference/reserve2.rds (bootstrap$p_mc et $p_min_mc, cle
#         Calendrier), et egales a 0,004 et 0,002 ;
#    (i2) reserve2 et premier triangle admis de chaque tranche de 50 (un
#         triangle sur 50 du plan) : p "deux", p_min_mc "deux" et B effectif
#         du script identiques (identical()) a ceux de
#         mw_bootstrap(aj, B, graine) du moteur, cle Calendrier ;
#    (graines) plages du script disjointes entre elles, de la plage de #206
#         (20 840 001 - 20 960 000) et de tous les litteraux de graine du
#         depot (recherche de collisions de #206, decalage de 20 000 et
#         graine du flux de regime comprises) ;
#    (reprise) voir plus haut.
#
#  Fonctions reprises par copie de tests/calibration_mc_mw_t8.R (non
#  modifie) : plateforme_calcul(), meme_fichier(), empreintes_code(),
#  sous_depot(), utf8(), ecrire_console(), ligne_md(), entete_md(), num(),
#  ic_cp(), txt_ic(), md5_fichier(), secondes(), f17(), chemins_absolus(),
#  moments(), tireur(), gen_triangle_h0(), admettre(), taille_lissee(),
#  lecture(), mcnemar(), controle des graines (adapte). commit_depot(),
#  motifs_non_versionnable(), garde_ecrasement(), ligne_remplacement(),
#  inserer_t0(), empreinte_sans_commentaires(), chemin_reference(), .tri :
#  tests/outils_tests.R (qui charge R/engine.R par source()).
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/mesure_calendaire_t8.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113, #242 ; copie de #206) --------
LOCALE_ORIGINE <- Sys.getlocale("LC_CTYPE")
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break
LOCALE_TRAVAIL <- Sys.getlocale("LC_CTYPE")

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
OPTIONS_VALEUR <- c("--travail", "--coeurs", "--R", "--N0", "--B", "--controle-i2prime")
OPTIONS_DRAPEAU <- c("--essai", "--ecrire", "--remplacer")
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
entier_opt <- function(nom, defaut, min = 1L) {
  v <- suppressWarnings(as.integer(lire_option(nom, defaut)))
  if (is.na(v) || v < min) stop(nom, " : entier >= ", min, " attendu")
  v
}
OPT_ESSAI     <- "--essai" %in% ARGS
OPT_ECRIRE    <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_TRAVAIL   <- lire_option("--travail", NA_character_)
OPT_I2PRIME   <- lire_option("--controle-i2prime", NA_character_)
MODE_I2PRIME  <- !is.na(OPT_I2PRIME)
COEURS        <- entier_opt("--coeurs", "4")
if (.Platform$OS.type == "windows") COEURS <- 1L
if (OPT_REMPLACER && !OPT_ECRIRE) stop("--remplacer : reserve a --ecrire (remplacement d'un tableau suivi par git, #173)")
if (OPT_ECRIRE && OPT_ESSAI) stop("--ecrire : refuse avec --essai (plan reduit, non versionnable)")
if (MODE_I2PRIME) {
  autres <- intersect(ARGS, c("--travail", "--coeurs", "--R", "--N0", "--essai", "--ecrire"))
  if (length(autres)) stop("--controle-i2prime : options sans objet dans ce mode : ", paste(autres, collapse = ", "))
  if (!file.exists(OPT_I2PRIME)) stop("--controle-i2prime : fichier introuvable : ", OPT_I2PRIME)
} else {
  if (is.na(OPT_TRAVAIL)) stop("--travail DOSSIER obligatoire (repertoire de travail hors du depot ; aucun chemin par defaut)")
  if (!OPT_ESSAI && any(c("--R", "--N0", "--B") %in% ARGS)) stop("--R, --N0, --B : reserves a --essai (--B aussi a --controle-i2prime)")
}

# --- Chargement du moteur et des outils --------------------------------------
FICHIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) f else NA_character_
})
DOSSIER_SCRIPT <- if (!is.na(FICHIER_SCRIPT)) dirname(FICHIER_SCRIPT) else
  if (file.exists("tests/outils_tests.R")) "tests" else "."
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))   # charge R/engine.R (source())

# --- Outils (copies de tests/calibration_mc_mw_t8.R) -------------------------
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(basename(extSoftVersion()[["BLAS"]])), txt(basename(La_library())), txt(La_version()))
}
meme_fichier <- function(a, b) !is.na(a) && file.exists(a) && file.exists(b) &&
  identical(normalizePath(a), normalizePath(b))
empreintes_code <- function(script_depot, lus = character(0)) {
  md5 <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
  lieu <- function(f, ref) if (meme_fichier(f, file.path(RACINE, ref))) "d\u00e9p\u00f4t" else "hors d\u00e9p\u00f4t"
  outils <- file.path(DOSSIER_SCRIPT, "outils_tests.R")
  paste(c(sprintf("R/engine.R %s", md5(file.path(RACINE, "R", "engine.R"))),
          sprintf("tests/outils_tests.R charg\u00e9 (%s) %s", lieu(outils, "tests/outils_tests.R"), md5(outils)),
          sprintf("script ex\u00e9cut\u00e9 (%s) %s", lieu(FICHIER_SCRIPT, script_depot), md5(FICHIER_SCRIPT)),
          vapply(lus, function(f) sprintf("%s %s", f, md5(file.path(RACINE, f))), "")), collapse = " ; ")
}
sous_depot <- function(chemin) {
  d <- normalizePath(chemin, winslash = "/", mustWork = TRUE)
  r <- normalizePath(RACINE, winslash = "/", mustWork = TRUE)
  if (.Platform$OS.type == "windows") { d <- tolower(d); r <- tolower(r) }
  identical(d, r) || startsWith(d, paste0(r, "/"))
}
utf8 <- function(x) {
  x <- as.character(x)
  if (!isTRUE(l10n_info()[["UTF-8"]])) { k <- Encoding(x) == "unknown"; Encoding(x)[k] <- "UTF-8"; x } else enc2utf8(x)
}
ecrire_console <- function(x) writeLines(utf8(x), useBytes = TRUE)
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
num <- function(x, d = 3) if (length(x) != 1L || is.na(x)) "\u2014" else sub(".", ",", sprintf(paste0("%.", d, "f"), x), fixed = TRUE)
ic_cp <- function(k, n) if (n > 0) {
  ci <- stats::binom.test(k, n)$conf.int
  c(ci[1], ci[2])
} else c(NA_real_, NA_real_)
D_IC <- 5L
txt_ic <- function(ci, d = D_IC) if (anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", num(ci[1], d), num(ci[2], d))
md5_fichier <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
secondes <- function(t0) as.numeric(difftime(Sys.time(), t0, units = "secs"))
f17 <- function(v) ifelse(is.finite(v), sprintf("%.17g", v), "NA")
g6 <- function(v) ifelse(is.finite(v), sprintf("%.6g", v), "NA")
fmt_p <- function(p) if (!is.finite(p)) "\u2014" else sub(".", ",", sprintf("%.3g", p), fixed = TRUE)
nettoyer_champ <- function(s) gsub("[\t\r\n]+", " ", s)
chemins_absolus <- function(lignes) {
  k <- grepl("/tmp", lignes, fixed = TRUE) |
    grepl("(^|[ (|`'\"=])(/(home|root|usr|var|mnt|opt|Users|private|srv|media)/|[A-Za-z]:[\\\\/])", lignes, perl = TRUE)
  lignes[k]
}
SPEC <- file.path("docs", "specifications", "fd-test-calendaire.md")
SPEC_206 <- file.path("docs", "specifications", "206-calibration-mc-merz-wuthrich.md")

###############################################################################
#  CRITERE K1 (spec par. 2.3), ecrit AVANT toute execution et recopie TEL QUEL
#  au T0 ; evalue mecaniquement par evaluer_k1().
###############################################################################
# Texte de la specification, par. 2.3 (trois puces), mot pour mot, marques
# d'emphase comprises, puces jointes par une espace.
TEXTE_K1 <- paste(
  "**K1, d\u00e9cisif** : pour la forme \u00ab bas \u00bb, sous N et sous E, aux deux seuils, classe *compatible* ou",
  "*\u00e9cart mineur* par rapport \u00e0 \u03c1_bas (classes de #166). Une *distorsion mat\u00e9rielle lib\u00e9rale* \u21d2",
  "**arr\u00eat au point D2-Fd** : #276 n'est pas impl\u00e9ment\u00e9e, et le mainteneur d\u00e9cide sur le tableau. Une",
  "distorsion conservatrice est document\u00e9e sans arr\u00eat.")
# Precision d'actuary du 16/10/2026, posee avant execution (lue par
# evaluer_k1() ; distincte du texte de K1 au T0).
TEXTE_PRECISION_K1 <- paste(
  "Pr\u00e9cision d'actuary du 16/10/2026, avant ex\u00e9cution : pour chaque cellule \u00ab bas \u00bb (N, E, deux seuils) en",
  "\u00e9cart non tranch\u00e9, le c\u00f4t\u00e9 est lu en comparant le taux \u00e0 \u03c1_bas. C\u00f4t\u00e9 lib\u00e9ral (taux > \u03c1_bas) : point",
  "d'arr\u00eat D2-Fd (\u00e9cart non tranch\u00e9, c\u00f4t\u00e9 lib\u00e9ral), soumis \u00e0 la lecture d'actuary et \u00e0 la d\u00e9cision du",
  "mainteneur. C\u00f4t\u00e9 conservateur (taux < \u03c1_bas) : document\u00e9 sans arr\u00eat.")

###############################################################################
#  PROTOCOLE (constantes de la specification, par. 2.3)
###############################################################################
METHODE <- "reserve2"; SEGMENT <- 1; ANNEXE <- "II"
ALPHA <- 0.10                       # alpha des verdicts (defaut de run_engine())
SEUILS <- c(0.10, 0.05); IA <- c("a10", "a05")
lib_ia <- function(ia) c(a10 = "0,10", a05 = "0,05")[[ia]]
GRAINE_R2 <- 20260831               # cas reserve2 de tests/outils_tests.R (controles (a), (i2))
REPERE_97 <- 0.10                   # repere par diagonale de Mack (1997), T3
FORMES <- c("deux", "bas")
TAILLE_TRANCHE <- 50L               # triangles par tranche ; (i2) sur le premier admis de chacune
TAILLE_TRANCHE_ORA <- 1000L         # triangles oracle par tranche
N_ECH_REPRISE <- 5L                 # tranches reprises recalculees (premiere ligne)
# Cellules du plan (tableau du par. 2.3). Indice c : rang dans CELLULES
# (graines). scenario : H0, dernier (t = 7), median (t = 4), derive
# (a partir de t = 4), compensation (t = 6, alternee).
CELLULES <- data.frame(
  cle      = c("H0-N", "H0-E", "H0-A", "dernier-005", "dernier-010", "median-005", "median-010",
               "derive-003", "derive-005", "compensation-010"),
  scenario = c("H0", "H0", "H0", "dernier", "dernier", "median", "median", "derive", "derive", "compensation"),
  loi      = c("N", "E", "A", "N", "N", "N", "N", "N", "N", "N"),
  param    = c(NA, NA, NA, 0.05, 0.10, 0.05, 0.10, 0.03, 0.05, 0.10),
  R        = c(2000L, 2000L, 1000L, 1000L, 1000L, 1000L, 1000L, 1000L, 1000L, 1000L),
  stringsAsFactors = FALSE)
LOIS <- c("N", "E", "A")
IDX_LOI <- c(N = 1L, E = 2L, A = 3L)
N0_SPEC <- 20000L; B_SPEC <- 999
R_MAX <- max(CELLULES$R)
if (MODE_I2PRIME) {
  N0 <- N0_SPEC
  B_BOOT <- as.numeric(entier_opt("--B", "999", 50L))
} else if (OPT_ESSAI) {
  R_ESSAI <- entier_opt("--R", "2"); N0 <- entier_opt("--N0", "200"); B_BOOT <- as.numeric(entier_opt("--B", "999", 50L))
  if (R_ESSAI > R_MAX || N0 > N0_SPEC || B_BOOT > B_SPEC) stop("--essai : R <= ", R_MAX, ", N0 <= ", N0_SPEC, ", B <= ", B_SPEC)
  CELLULES$R <- pmin(CELLULES$R, R_ESSAI)
} else {
  N0 <- N0_SPEC
  # Double, comme le B par defaut de run_engine() (mw_bootstrap() restitue B
  # tel quel ; meme choix que tests/calibration_mc_mw_t8.R).
  B_BOOT <- B_SPEC
}
lib_scenario <- function(cl) {
  x <- CELLULES[CELLULES$cle == cl, ]
  switch(x$scenario,
         H0 = sprintf("H0, loi %s", x$loi),
         dernier = sprintf("dernier exercice (t = 7), \u03b8 = %s", num(x$param, 2)),
         median = sprintf("exercice m\u00e9dian (t = 4), \u03b8 = %s", num(x$param, 2)),
         derive = sprintf("d\u00e9rive \u00e0 partir de t = 4, g = %s", num(x$param, 2)),
         compensation = sprintf("compensation (t = 6, altern\u00e9e, ligne 0 : 1 + \u03b8), \u03b8 = %s", num(x$param, 2)))
}

# --- Graines (par. 2.3) : plages disjointes de #206 et des litteraux --------
# triangle b de la cellule c : GRAINE_TRI + PAS * (c - 1) + b ;
# bootstrap : GRAINE_BOOT + PAS * (c - 1) + b ; oracle k de la loi l :
# GRAINE_ORA + PAS_ORA * (l - 1) + k. Toutes sous engine_sous_graine().
GRAINE_TRI <- 21000000; GRAINE_BOOT <- 21100000; GRAINE_ORA <- 21200000
PAS <- 10000; PAS_ORA <- 20000
graine_tri  <- function(c, b) GRAINE_TRI + PAS * (c - 1) + b
graine_boot <- function(c, b) GRAINE_BOOT + PAS * (c - 1) + b
graine_ora  <- function(loi, k) GRAINE_ORA + PAS_ORA * (IDX_LOI[[loi]] - 1L) + k
PLAGE_206 <- c(20840001, 20960000)

###############################################################################
#  DGP SOUS H0 (copie de #206, par. 2 de sa specification)
###############################################################################
AJ0 <- mw_ajuster(.tri)
JD0 <- .mw_colonnes_degenerees(AJ0)
POOL0 <- .mw_pool_residus(AJ0, JD0)
SD_POP0 <- sqrt(mean((POOL0 - mean(POOL0))^2))
POOL_E <- POOL0 / SD_POP0
tireur <- function(loi) switch(loi,
  N = function(n) stats::rnorm(n),
  E = function(n) sample(POOL_E, n, replace = TRUE),
  A = function(n) (stats::qgamma(stats::runif(n), 2) - 2) / sqrt(2))
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

# --- Alternatives (spec par. 2.2) ---------------------------------------------
# Effet multiplicatif sur les increments X(i, k) = C(i, k) - C(i, k - 1)
# (X(i, 0) = C(i, 0)) de l'exercice t = i + k, i et k numerotes a partir de 0,
# applique au triangle simule sous H0, puis recumule le long de chaque ligne.
# Toutes les cellules observees (i + k <= I) sont concernees, premiere
# colonne comprise. H0 : triangle rendu tel quel (aucune recumulation, pour
# ne pas changer ses bits). Triangle incomplet (cumul simule invalide, #257) :
# rendu tel quel, admettre() le refuse.
facteur_exercice <- function(scenario, param, t, i) switch(scenario,
  dernier = if (t == 7) 1 + param else 1,
  median = if (t == 4) 1 + param else 1,
  derive = (1 + param)^max(0, t - 3),
  compensation = if (t == 6) 1 + (-1)^i * param else 1,
  stop("scenario inconnu : ", scenario))
appliquer_effet <- function(tri, scenario, param) {
  if (scenario == "H0" || .mw_triangle_incomplet(tri)) return(tri)
  n <- nrow(tri)
  out <- tri
  for (i in 0:(n - 1)) {
    k <- 0:(ncol(tri) - 1 - i)
    C <- tri[i + 1, k + 1]
    X <- c(C[1], diff(C))
    fac <- vapply(i + k, function(t) facteur_exercice(scenario, param, t, i), 1)
    out[i + 1, k + 1] <- cumsum(X * fac)
  }
  out
}

###############################################################################
#  STATISTIQUE CALENDAIRE, FORMES "deux" ET "bas"
###############################################################################
# Entree du catalogue du moteur (forme "deux") et copie locale en queue basse
# (forme "bas") : meme fonction de calcul, memes extremites (.mw_calendrier_
# extremes(), qui rend c(bas, haut) ; engine_p_mc() lit "bas" en queue basse).
ENT_DEUX <- MW_CATALOGUE_MC$Calendrier
if (!MODE_I2PRIME && !identical(ENT_DEUX$queue, "deux")) stop("entree Calendrier du catalogue : queue \"deux\" attendue (moteur d'avant #276)")
if (MODE_I2PRIME && !identical(ENT_DEUX$queue, "bas")) stop("--controle-i2prime : entree Calendrier du catalogue en queue \"bas\" attendue (moteur modifie par #276)")
ENT_BAS <- .mc_entree(ENT_DEUX$calc, "bas", extremes = ENT_DEUX$extremes)
ENTREES <- list(deux = ENT_DEUX, bas = ENT_BAS)
extremites <- function(ent, e) {
  ex <- ent$extremes(e)
  if (!(is.numeric(ex) && length(ex) == 2L) && !(is.logical(ex) && length(ex) == 2L && all(is.na(ex))))
    stop("extremes(Calendrier) : c(bas, haut) attendu")
  as.numeric(ex)
}
# P(Z_k <= z_k) sous Binomiale(n_k, 1/2), Z_k = min(L_k, n_k - L_k).
p_diagonale <- function(n, z) { l <- 0:n; sum(stats::dbinom(l, n, 0.5)[pmin(l, n - l) <= z]) }

# Replications de mw_bootstrap(), statistique calendaire seule (spec par.
# 2.1) : meme graine, meme pool (.mw_pool_residus(aj, figes$degeneres)), meme
# boucle de .mw_tirer_triangle_valide() avec le plafond FACTEUR_B_MAX_MW
# (B + 1), meme rejet d'une replication si mw_ajuster() echoue. Seul sample()
# (dans .mw_simuler_triangle_etat()) consomme de l'alea : ni mw_ajuster(), ni
# la statistique, ni les calculs du moteur omis ici (autres statistiques,
# mw_msep()) n'en consomment, ce que le controle (i2) verifie par identite des
# p. Ecart possible non couvert : dans mw_bootstrap(), une erreur d'une AUTRE
# statistique de .mw_stats() ou de mw_residus() (contexte) ecarte aussi la
# replication du calendrier ; (i2) le detecterait sur l'echantillon.
replications_calendrier <- function(aj, figes, B, seed) {
  pool <- .mw_pool_residus(aj, figes$degeneres)
  engine_sous_graine(seed, {
    sim <- rep(NA_real_, B)
    n_max <- FACTEUR_B_MAX_MW * (as.numeric(B) + 1)
    n_tires <- 0; retires <- FALSE; plafond <- FALSE
    for (b in seq_len(B)) {
      tir <- .mw_tirer_triangle_valide(aj, pool, n_max - n_tires)
      n_tires <- n_tires + tir$n
      if (tir$rejets > 0) retires <- TRUE
      if (is.null(tir$tri)) { plafond <- TRUE; next }
      ab <- try(mw_ajuster(tir$tri), silent = TRUE)
      if (inherits(ab, "try-error")) next
      sb <- try(ENT_DEUX$calc(list(aj = ab, figes = figes)), silent = TRUE)
      if (inherits(sb, "try-error")) next
      sim[b] <- sb
    }
    list(sim = sim, n_tires = n_tires, retires = retires, plafond = plafond)
  })
}

# Calcul complet d'un triangle admis : observee, p des deux formes, Z, n_k.
COLS_LIGNE <- c("cle", "b", "graine_tri", "graine_boot", "statut", "motif", "stat", "Z", "E", "V", "n_k", "z_k",
                "p_diag", "n_rep97", "p_as_deux", "p_as_bas", "p_deux", "p_bas", "pmm_deux", "pmm_bas",
                "err_deux", "err_bas", "B_eff", "n_tires", "retires", "plafond", "i2", "duree")
calcul_triangle <- function(aj, B, seed) {
  figes <- .mw_ensembles_figes(aj)
  e_obs <- .mw_contexte_mc(aj, figes)
  cal <- mw_test_annees_calendaires(aj, figes$degeneres)
  obs <- ENT_DEUX$calc(e_obs)
  rp <- replications_calendrier(aj, figes, B, seed)
  pf <- lapply(ENTREES, function(ent) engine_p_mc(rp$sim, obs, ent$queue, extremites(ent, e_obs)))
  A <- cal$detail
  n_k <- if (is.null(A)) numeric(0) else unname(A[, "n"])
  z_k <- if (is.null(A)) numeric(0) else unname(A[, "Z"])
  pd <- if (length(n_k)) mapply(p_diagonale, n_k, z_k) else numeric(0)
  list(stat = obs, Z = if (is.null(cal$Z)) NA_real_ else cal$Z, E = if (is.null(cal$E)) NA_real_ else cal$E,
       V = if (is.null(cal$V)) NA_real_ else cal$V, n_k = n_k, z_k = z_k, p_diag = pd,
       n_rep97 = sum(pd <= REPERE_97),
       p_as_deux = cal$p, p_as_bas = .p_borne(stats::pnorm(obs)),
       p_deux = pf$deux$p_mc, p_bas = pf$bas$p_mc, pmm_deux = pf$deux$p_min_mc, pmm_bas = pf$bas$p_min_mc,
       err_deux = pf$deux$err_mc, err_bas = pf$bas$err_mc, B_eff = pf$deux$B_effectif,
       n_tires = rp$n_tires, retires = rp$retires, plafond = rp$plafond)
}
# (i2) : identite avec mw_bootstrap() du moteur (cle Calendrier).
controle_i2 <- function(aj, B, seed, r) {
  bt <- mw_bootstrap(aj, B = B, seed = seed)
  c(p = identical(unname(bt$p_mc[["Calendrier"]]), r$p_deux),
    p_min_mc = identical(unname(bt$p_min_mc[["Calendrier"]]), r$pmm_deux),
    B_eff = identical(unname(bt$B_effectif[["Calendrier"]]), r$B_eff))
}
ligne_triangle <- function(cl, b, i2) {
  t0 <- Sys.time()
  c_ <- match(cl, CELLULES$cle); x <- CELLULES[c_, ]
  gt <- graine_tri(c_, b); gb <- graine_boot(c_, b)
  tri <- engine_sous_graine(gt, gen_triangle_h0(AJ0, tireur(x$loi)))
  tri <- appliquer_effet(tri, x$scenario, x$param)
  ad <- admettre(tri)
  base <- list(cle = cl, b = b, graine_tri = gt, graine_boot = gb)
  if (!ad$ok) {
    v <- c(base, statut = "refuse", motif = ad$motif)
    v[setdiff(COLS_LIGNE, names(v))] <- NA
    v$duree <- secondes(t0)
    return(v[COLS_LIGNE])
  }
  r <- calcul_triangle(ad$aj, B_BOOT, gb)
  ci2 <- NA_character_
  if (i2) {
    k <- controle_i2(ad$aj, B_BOOT, gb, r)
    ci2 <- if (all(k)) "OK" else paste("ECHEC", paste(names(k)[!k], collapse = ","))
  }
  v <- c(base, statut = "admis", motif = NA_character_,
         r[c("stat", "Z", "E", "V")],
         n_k = paste(r$n_k, collapse = ","), z_k = paste(r$z_k, collapse = ","),
         p_diag = paste(f17(r$p_diag), collapse = ","),
         r[c("n_rep97", "p_as_deux", "p_as_bas", "p_deux", "p_bas", "pmm_deux", "pmm_bas", "err_deux", "err_bas",
             "B_eff", "n_tires", "retires", "plafond")],
         i2 = ci2, duree = secondes(t0))
  v[COLS_LIGNE]
}
COLS_ORACLE <- c("loi", "k", "statut", "motif", "stat", "duree")
ligne_oracle <- function(loi, k) {
  t0 <- Sys.time()
  tri <- engine_sous_graine(graine_ora(loi, k), gen_triangle_h0(AJ0, tireur(loi)))
  ad <- admettre(tri)
  if (!ad$ok) return(list(loi = loi, k = k, statut = "refuse", motif = ad$motif, stat = NA_real_, duree = secondes(t0)))
  e <- .mw_contexte_mc(ad$aj, .mw_ensembles_figes(ad$aj))
  list(loi = loi, k = k, statut = "admis", motif = NA_character_, stat = ENT_DEUX$calc(e), duree = secondes(t0))
}
en_df <- function(lignes, cols) {
  d <- as.data.frame(lapply(stats::setNames(nm = cols), function(k) unlist(lapply(lignes, function(l) {
    v <- l[[k]]; if (is.null(v) || length(v) != 1L) NA else v }))), stringsAsFactors = FALSE)
  d
}

###############################################################################
#  MODE --controle-i2prime (controle (i2') de l'etape 3 de Fd)
###############################################################################
# Moteur modifie : MW_CATALOGUE_MC$Calendrier en queue "bas" (garde plus
# haut) ; ENT_DEUX porte alors la queue "bas" mais sa fonction de calcul et
# ses extremites sont celles de la mesure. ENT_BAS (copie locale) sert de
# forme "bas" du script, comme a la mesure.
if (MODE_I2PRIME) {
  ecarts <- character(0)
  verifier_i2p <- function(lib, aj, seed, p_attendu, pmm_attendu) {
    bt <- mw_bootstrap(aj, B = B_BOOT, seed = seed)
    ok <- identical(unname(bt$p_mc[["Calendrier"]]), p_attendu) && identical(unname(bt$p_min_mc[["Calendrier"]]), pmm_attendu)
    message(sprintf("(i2') %s : moteur p %s, p_min_mc %s ; script (forme bas) p %s, p_min_mc %s : %s", lib,
                    g6(bt$p_mc[["Calendrier"]]), g6(bt$p_min_mc[["Calendrier"]]), g6(p_attendu), g6(pmm_attendu), if (ok) "OK" else "ECART"))
    if (!ok) stop("(i2') ecart sur ", lib, call. = FALSE)
  }
  aj_r2 <- mw_ajuster(.tri)
  r_r2 <- calcul_triangle(aj_r2, B_SPEC, GRAINE_R2)
  B_LU <- B_BOOT; B_BOOT <- B_SPEC
  verifier_i2p(sprintf("reserve2 (graine %.0f, B = 999)", GRAINE_R2), aj_r2, GRAINE_R2, r_r2$p_bas, r_r2$pmm_bas)
  B_BOOT <- B_LU
  Bt <- utils::read.delim(OPT_I2PRIME, colClasses = "character", na.strings = character(0))
  manq <- setdiff(c("cle", "b", "graine_tri", "graine_boot", "statut", "i2", "p_bas", "pmm_bas"), names(Bt))
  if (length(manq)) stop("--controle-i2prime : colonnes absentes du fichier : ", paste(manq, collapse = ", "))
  Bt <- Bt[Bt$i2 == "OK", , drop = FALSE]
  if (!nrow(Bt)) stop("--controle-i2prime : aucun triangle marque i2 = OK dans le fichier")
  lit <- function(x) if (identical(x, "NA")) NA_real_ else as.numeric(x)
  for (i in seq_len(nrow(Bt))) {
    x <- Bt[i, ]; c_ <- match(x$cle, CELLULES$cle); b <- as.numeric(x$b)
    if (is.na(c_)) stop("--controle-i2prime : cellule inconnue : ", x$cle)
    if (graine_tri(c_, b) != as.numeric(x$graine_tri) || graine_boot(c_, b) != as.numeric(x$graine_boot))
      stop("--controle-i2prime : graines du fichier differentes de celles du script (", x$cle, ", b = ", b, ")")
    tri <- appliquer_effet(engine_sous_graine(graine_tri(c_, b), gen_triangle_h0(AJ0, tireur(CELLULES$loi[c_]))),
                           CELLULES$scenario[c_], CELLULES$param[c_])
    ad <- admettre(tri)
    if (!ad$ok) stop("--controle-i2prime : triangle ", x$cle, " b = ", b, " refuse a la regeneration : ", ad$motif)
    verifier_i2p(sprintf("%s b = %.0f (B = %.0f)", x$cle, b, B_BOOT), ad$aj, graine_boot(c_, b), lit(x$p_bas), lit(x$pmm_bas))
  }
  message(sprintf("(i2') OK : reserve2 et %d triangle(s) du plan, p_mc et p_min_mc du moteur modifie identiques a la forme \"bas\" du script", nrow(Bt)))
  quit(status = 0L)
}

###############################################################################
#  PROVENANCE ET CONTROLES GENERAUX
###############################################################################
COMMIT <- commit_depot(SCRIPT)
EMPREINTES <- empreintes_code(SCRIPT, c(SPEC, SPEC_206))
EMPREINTE_SC <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
MD5_SCRIPT <- md5_fichier(FICHIER_SCRIPT)
NV <- c(motifs_non_versionnable(COMMIT, EMPREINTES, "de l'ex\u00e9cution"), if (OPT_ESSAI) "essai (--essai)")
DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
NOMS_SORTIE <- c(md = sprintf("%s-issue276-calendaire.md", DATE_SORTIE), brut = sprintf("%s-issue276-calendaire-brut.tsv", DATE_SORTIE))
# Gardes anticipees (#205, #173) : avant tout calcul long.
CIBLES <- file.path(RACINE, "docs", "tableaux", NOMS_SORTIE); names(CIBLES) <- names(NOMS_SORTIE)
if (OPT_ECRIRE) {
  if (length(NV)) stop("--ecrire refuse (tableau versionne) : ", paste(NV, collapse = " ; "))
  garde_ecrasement(CIBLES, OPT_REMPLACER, RACINE)
}
# Ecriture d'un fichier (UTF-8, octets) : definie APRES la garde anticipee
# (ordre controle par tests/unitaires/test_garde_ecrasement.R pour les
# scripts qui ont --ecrire).
ecrire_fichier <- function(f, lignes) { con <- file(f, open = "wb"); on.exit(close(con)); writeLines(utf8(lignes), con, useBytes = TRUE) }
dir.create(OPT_TRAVAIL, recursive = TRUE, showWarnings = FALSE)
if (!dir.exists(OPT_TRAVAIL)) stop("--travail : dossier non cree : ", OPT_TRAVAIL)
if (sous_depot(OPT_TRAVAIL)) stop("--travail : dossier sous le depot refuse (sauvegardes hors du depot)")
DOSSIER_TR <- file.path(OPT_TRAVAIL, if (OPT_ESSAI) sprintf("essai-R%d-N%d-B%d", CELLULES$R[1], N0, B_BOOT) else "complet")
dir.create(DOSSIER_TR, recursive = TRUE, showWarnings = FALSE)

CONTROLES <- character(0)
controle <- function(ok, libelle) {
  CONTROLES <<- c(CONTROLES, sprintf("%s : %s", libelle, if (isTRUE(ok)) "OK" else "\u00c9CHEC"))
  if (!isTRUE(ok)) { ecrire_console(paste("-", CONTROLES)); stop("controle en ECHEC : ", libelle, call. = FALSE) }
  invisible(TRUE)
}

# (graines) : recherche des collisions de #206 (litteraux de huit chiffres
# commencant par 2, suffixe L compris, dans R/engine.R, tests/*.R hors ce
# script et tests/unitaires/*.R ; pour chaque litteral L, [L ; L + 20 000]
# et L + DECALAGE_GRAINE_FLUX_REGIME (graine du flux de regime, #240) hors
# des plages), plus la plage de #206 et le reseau 20260831 + 1000 k <=
# 20760831 de tests/puissance_t8.R.
PLAGES <- rbind(triangles = c(graine_tri(1, 1), graine_tri(nrow(CELLULES), R_MAX)),
                bootstrap = c(graine_boot(1, 1), graine_boot(nrow(CELLULES), R_MAX)),
                oracle = c(graine_ora("N", 1), graine_ora("A", N0_SPEC)))
DECALAGE_MAX <- 20000
controle_graines <- function() {
  fs <- c(file.path(RACINE, "R", "engine.R"), list.files(file.path(RACINE, "tests"), pattern = "\\.R$", full.names = TRUE),
          list.files(file.path(RACINE, "tests", "unitaires"), pattern = "\\.R$", full.names = TRUE))
  fs <- fs[basename(fs) != basename(SCRIPT)]
  lit <- sort(unique(as.numeric(unlist(lapply(fs, function(f) {
    l <- readLines(f, warn = FALSE)
    regmatches(l, gregexpr("(?<![0-9A-Za-z.])2[0-9]{7}(?=L?(?![0-9A-Za-z.]))", l, perl = TRUE))
  })))))
  touche <- function(a, b) any(a <= PLAGES[, 2] & b >= PLAGES[, 1])
  coll <- lit[vapply(lit, function(v) touche(v, v + DECALAGE_MAX) || touche(v + DECALAGE_GRAINE_FLUX_REGIME, v + DECALAGE_GRAINE_FLUX_REGIME), logical(1))]
  o <- order(PLAGES[, 1]); P <- PLAGES[o, ]
  disj <- all(P[-1, 1] > P[-nrow(P), 2])
  hors_206 <- !touche(PLAGE_206[1], PLAGE_206[2])
  ext <- c(SEED_LOI_NULLE_SW, GRAINE_R2, 20260831 + 1000 * 500)
  hors_ext <- !any(vapply(ext, function(v) touche(v, v), logical(1)))
  list(ok = disj && hors_206 && !length(coll) && hors_ext,
       txt = sprintf("plages triangles %.0f-%.0f, bootstrap %.0f-%.0f, oracle %.0f-%.0f (disjointes : %s) ; plage de #206 %.0f-%.0f disjointe : %s ; %d litt\u00e9raux de graine dans %d fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R), de %.0f \u00e0 %.0f ; litt\u00e9raux L dont [L ; L + %.0f] ou L + %.0f (flux de r\u00e9gime) touche une plage : %s ; SEED_LOI_NULLE_SW %.0f, graine de reserve2 %.0f et r\u00e9seau 20260831 + 1000 k \u2264 20760831 de tests/puissance_t8.R hors des plages : %s",
                     PLAGES[1, 1], PLAGES[1, 2], PLAGES[2, 1], PLAGES[2, 2], PLAGES[3, 1], PLAGES[3, 2], if (disj) "oui" else "NON",
                     PLAGE_206[1], PLAGE_206[2], if (hors_206) "oui" else "NON", length(lit), length(fs), min(lit), max(lit),
                     DECALAGE_MAX, DECALAGE_GRAINE_FLUX_REGIME, if (length(coll)) paste(sprintf("%.0f", coll), collapse = ", ") else "aucun",
                     SEED_LOI_NULLE_SW, GRAINE_R2, if (hors_ext) "oui" else "NON"))
}
cgr <- controle_graines(); controle(cgr$ok, paste("(graines)", cgr$txt))

# (a) et (i2) sur reserve2 (B = 999 de la reference, graine 20260831).
REF_R2 <- readRDS(chemin_reference("reserve2"))
AJ_R2 <- mw_ajuster(.tri)
R_R2 <- calcul_triangle(AJ_R2, B_SPEC, GRAINE_R2)
ref_p <- unname(REF_R2$bootstrap$p_mc[["Calendrier"]]); ref_pmm <- unname(REF_R2$bootstrap$p_min_mc[["Calendrier"]])
controle(identical(R_R2$p_deux, ref_p) && identical(R_R2$pmm_deux, ref_pmm) &&
           all(abs(c(ref_p, ref_pmm) - c(0.004, 0.002)) < 1e-12),
         sprintf("(a) reserve2 (seed %.0f, B = 999) : p_mc \u00ab deux \u00bb du script %s, r\u00e9f\u00e9rence %s ; p_min_mc \u00ab deux \u00bb du script %s, r\u00e9f\u00e9rence %s (tests/reference/reserve2.rds, md5 %s ; attendu 0,004 et 0,002) ; forme \u00ab bas \u00bb : p_mc %s, p_min_mc %s ; B effectif %.0f",
                 GRAINE_R2, g6(R_R2$p_deux), g6(ref_p), g6(R_R2$pmm_deux), g6(ref_pmm),
                 md5_fichier(chemin_reference("reserve2")), g6(R_R2$p_bas), g6(R_R2$pmm_bas), R_R2$B_eff))
I2_R2 <- controle_i2(AJ_R2, B_SPEC, GRAINE_R2, R_R2)
controle(all(I2_R2), sprintf("(i2) reserve2 : p \u00ab deux \u00bb, p_min_mc \u00ab deux \u00bb et B effectif du script identiques (identical()) \u00e0 mw_bootstrap(aj, 999, %.0f) du moteur, cl\u00e9 Calendrier : %s",
                             GRAINE_R2, paste(sprintf("%s %s", names(I2_R2), ifelse(I2_R2, "oui", "NON")), collapse = ", ")))
T_CTRL <- secondes(t_debut)

###############################################################################
#  TRANCHES (calcul parallele, sauvegarde, reprise)
###############################################################################
SIGNATURE <- list(script = MD5_SCRIPT, moteur = EMPREINTE_SC, B = B_BOOT, N0 = N0, R = stats::setNames(CELLULES$R, CELLULES$cle),
                  graines = c(GRAINE_TRI, GRAINE_BOOT, GRAINE_ORA, PAS, PAS_ORA), taille = c(TAILLE_TRANCHE, TAILLE_TRANCHE_ORA),
                  generateur = ENGINE_RNG_KIND)
blocs <- function(n, t) lapply(seq(1L, n, by = t), function(a) c(a, min(a + t - 1L, n)))
TACHES <- c(
  unlist(lapply(seq_len(nrow(CELLULES)), function(c_) lapply(blocs(CELLULES$R[c_], TAILLE_TRANCHE), function(x)
    list(type = "tri", cle = CELLULES$cle[c_], b1 = x[1], b2 = x[2],
         fichier = sprintf("tranche-%s-%04d-%04d.rds", CELLULES$cle[c_], x[1], x[2])))), recursive = FALSE),
  unlist(lapply(LOIS, function(l) lapply(blocs(N0, TAILLE_TRANCHE_ORA), function(x)
    list(type = "ora", cle = l, b1 = x[1], b2 = x[2], fichier = sprintf("oracle-%s-%05d-%05d.rds", l, x[1], x[2])))), recursive = FALSE))
calculer_tache <- function(ta) {
  t0 <- Sys.time()
  if (ta$type == "tri") {
    lignes <- list(); fait_i2 <- FALSE
    for (b in seq.int(ta$b1, ta$b2)) {
      l <- ligne_triangle(ta$cle, b, i2 = !fait_i2)
      if (identical(l$statut, "admis") && !fait_i2) fait_i2 <- TRUE
      lignes[[length(lignes) + 1L]] <- l
    }
    d <- en_df(lignes, COLS_LIGNE)
  } else {
    d <- en_df(lapply(seq.int(ta$b1, ta$b2), function(k) ligne_oracle(ta$cle, k)), COLS_ORACLE)
  }
  list(signature = SIGNATURE, tache = ta[c("type", "cle", "b1", "b2")], donnees = d, duree = secondes(t0))
}
sauver <- function(obj, f) {
  tmp <- paste0(f, ".tmp", Sys.getpid())
  saveRDS(obj, tmp)
  if (!file.rename(tmp, f)) stop("renommage refuse : ", basename(f))
}
# Reprise : sauvegardes existantes, signature identique exigee.
existe <- vapply(TACHES, function(ta) file.exists(file.path(DOSSIER_TR, ta$fichier)), logical(1))
REPRISES <- list()
for (k in which(existe)) {
  o <- readRDS(file.path(DOSSIER_TR, TACHES[[k]]$fichier))
  if (!identical(o$signature, SIGNATURE) || !identical(o$tache, TACHES[[k]][c("type", "cle", "b1", "b2")]))
    stop("reprise refusee : sauvegarde ", TACHES[[k]]$fichier, " de signature differente (script, moteur ou parametres) ; ",
         "la deplacer ou changer de --travail")
  REPRISES[[TACHES[[k]]$fichier]] <- o
}
# Echantillon regulier des tranches reprises : premiere ligne recalculee,
# comparee hors duree (et hors (i2), calcule seulement en tranche).
TXT_REPRISE <- "aucune tranche reprise"
if (length(REPRISES)) {
  ks <- which(existe)[unique(round(seq(1, sum(existe), length.out = min(N_ECH_REPRISE, sum(existe)))))]
  diff_r <- character(0)
  for (k in ks) {
    ta <- TACHES[[k]]; o <- REPRISES[[ta$fichier]]
    if (ta$type == "tri") {
      l <- en_df(list(ligne_triangle(ta$cle, ta$b1, i2 = FALSE)), COLS_LIGNE)
      a <- o$donnees[1, setdiff(COLS_LIGNE, c("duree", "i2"))]; b <- l[1, setdiff(COLS_LIGNE, c("duree", "i2"))]
    } else {
      l <- en_df(list(ligne_oracle(ta$cle, ta$b1)), COLS_ORACLE)
      a <- o$donnees[1, setdiff(COLS_ORACLE, "duree")]; b <- l[1, setdiff(COLS_ORACLE, "duree")]
    }
    rownames(a) <- rownames(b) <- NULL
    if (!identical(a, b)) diff_r <- c(diff_r, ta$fichier)
  }
  controle(!length(diff_r), sprintf("(reprise) %d tranche(s) reprise(s), signature identique ; premi\u00e8re ligne de %d tranche(s) reprise(s) recalcul\u00e9e et identique hors dur\u00e9e%s",
                                    length(REPRISES), length(ks), if (length(diff_r)) paste0(" ; diff\u00e9rentes : ", paste(diff_r, collapse = ", ")) else ""))
  TXT_REPRISE <- sprintf("%d tranche(s) reprise(s) sur %d, %d recalcul\u00e9e(s) sur leur premi\u00e8re ligne et identique(s)", length(REPRISES), length(TACHES), length(ks))
}
A_FAIRE <- TACHES[!existe]
message(sprintf("tranches : %d en tout, %d reprises, %d a calculer sur %d coeur(s) ; repertoire de travail : %s",
                length(TACHES), sum(existe), length(A_FAIRE), COEURS, DOSSIER_TR))
t_calc <- Sys.time()
executer <- function(ta) {
  r <- tryCatch(calculer_tache(ta), error = function(e) e)
  if (inherits(r, "error")) return(sprintf("%s : %s", ta$fichier, conditionMessage(r)))
  sauver(r, file.path(DOSSIER_TR, ta$fichier))
  NULL
}
if (length(A_FAIRE)) {
  res <- if (COEURS > 1L) parallel::mclapply(A_FAIRE, executer, mc.cores = COEURS, mc.preschedule = FALSE) else lapply(A_FAIRE, executer)
  err <- unlist(Filter(Negate(is.null), lapply(res, function(x) if (inherits(x, "try-error")) as.character(x) else x)))
  if (length(err)) stop("tranche(s) en erreur (sauvegardes des autres conservees, relancer pour reprendre) : ", paste(err, collapse = " ; "))
}
DUREE_HORLOGE <- secondes(t_calc)

###############################################################################
#  COMBINAISON
###############################################################################
lire_tache <- function(ta) {
  o <- readRDS(file.path(DOSSIER_TR, ta$fichier))
  if (!identical(o$signature, SIGNATURE)) stop("signature differente : ", ta$fichier)
  o
}
OBJ <- lapply(TACHES, lire_tache)
TYPES <- vapply(TACHES, `[[`, "", "type")
DUREES_TR <- vapply(OBJ, `[[`, 1, "duree")
D <- do.call(rbind, lapply(OBJ[TYPES == "tri"], `[[`, "donnees"))
O <- do.call(rbind, lapply(OBJ[TYPES == "ora"], `[[`, "donnees"))
rownames(D) <- rownames(O) <- NULL
for (k in c("b", "graine_tri", "graine_boot", "stat", "Z", "E", "V", "n_rep97", "p_as_deux", "p_as_bas", "p_deux", "p_bas",
            "pmm_deux", "pmm_bas", "err_deux", "err_bas", "B_eff", "n_tires", "duree")) D[[k]] <- as.numeric(D[[k]])
D$retires <- as.logical(D$retires); D$plafond <- as.logical(D$plafond)
O$k <- as.numeric(O$k); O$stat <- as.numeric(O$stat); O$duree <- as.numeric(O$duree)
# Couverture exacte du plan.
for (c_ in seq_len(nrow(CELLULES))) {
  b <- D$b[D$cle == CELLULES$cle[c_]]
  if (anyDuplicated(b) || !setequal(b, seq_len(CELLULES$R[c_]))) stop("cellule ", CELLULES$cle[c_], " : couverture 1..R inexacte")
}
for (l in LOIS) { k <- O$k[O$loi == l]; if (anyDuplicated(k) || !setequal(k, seq_len(N0))) stop("oracle ", l, " : couverture 1..N0 inexacte") }
# (i2) sur un triangle sur 50 du plan.
I2 <- D$i2[!is.na(D$i2)]
controle(length(I2) > 0 && all(I2 == "OK"),
         sprintf("(i2) premier triangle admis de chaque tranche de %d (%d triangles du plan) : p \u00ab deux \u00bb, p_min_mc \u00ab deux \u00bb et B effectif du script identiques (identical()) \u00e0 mw_bootstrap(aj, B, graine) du moteur%s",
                 TAILLE_TRANCHE, length(I2), if (all(I2 == "OK")) "" else paste0(" ; \u00e9checs : ", paste(unique(I2[I2 != "OK"]), collapse = " ; "))))
# Invariants : B_eff <= B, p sur la grille, p "bas" et p_min_mc dans [0, 1].
adm <- D$statut == "admis"
sur_grille <- function(p, B, k) !is.finite(p) || p == 1 || abs(p * (B + 1) / k - round(p * (B + 1) / k)) < 1e-6
inv <- all(D$B_eff[adm] <= B_BOOT) && all(mapply(sur_grille, D$p_deux[adm], D$B_eff[adm], 2)) &&
  all(mapply(sur_grille, D$p_bas[adm], D$B_eff[adm], 1)) &&
  all(D$pmm_bas[adm] <= D$p_bas[adm] | !is.finite(D$pmm_bas[adm])) && all(D$pmm_deux[adm] <= D$p_deux[adm] | !is.finite(D$pmm_deux[adm]))
controle(inv, "(d) B effectif \u2264 B ; p \u00ab deux \u00bb sur la grille 2k/(B_eff + 1) (plafonn\u00e9e \u00e0 1), p \u00ab bas \u00bb sur k/(B_eff + 1) ; p_min_mc \u2264 p_mc dans chaque forme")

# --- Oracle : rho, valeurs distinctes, plus gros atome ------------------------
# Copie de taille_lissee() de #206 : taille lissee a B du test de Monte-Carlo
# ideal tirant ses B repliques dans F0, regle ">=" d'engine_p_mc().
taille_lissee <- function(S, queue, B, a, n_tot = length(S)) {
  n <- length(S)
  if (!n || !n_tot) return(NA_real_)
  Ss <- sort(S)
  q_hi <- (n - findInterval(S, Ss, left.open = TRUE)) / n
  q_lo <- findInterval(S, Ss) / n
  c1 <- ceiling(round(a * (B + 1), 9)) - 2; c2 <- ceiling(round(a * (B + 1) / 2, 9)) - 2
  t <- switch(queue, haut = stats::pbinom(c1, B, q_hi), bas = stats::pbinom(c1, B, q_lo),
              deux = stats::pbinom(c2, B, q_hi) + stats::pbinom(c2, B, q_lo))
  sum(t) / n_tot
}
ORACLE <- lapply(stats::setNames(nm = LOIS), function(l) {
  x <- O[O$loi == l, ]; na <- sum(x$statut == "admis")
  S <- x$stat[x$statut == "admis"]; S <- S[is.finite(S)]
  tab <- table(S)
  list(n = nrow(x), n_adm = na, n_fin = length(S), distinctes = length(tab), atome = if (length(S)) max(tab) / length(S) else NA_real_,
       rho = sapply(FORMES, function(f) vapply(SEUILS, function(a) taille_lissee(S, f, B_BOOT, a, na), 1)),
       niv_as = sapply(FORMES, function(f) vapply(SEUILS, function(a) {
         p <- if (f == "deux") 2 * (1 - stats::pnorm(abs(S))) else stats::pnorm(S)
         sum(p < a) / na }, 1)),
       S = S)
})
MD5_ORACLE <- vapply(LOIS, function(l) {
  f <- tempfile(); on.exit(unlink(f)); x <- O[O$loi == l, ]; x <- x[order(x$k), ]
  ecrire_fichier(f, sprintf("%d\t%s\t%s", x$k, x$statut, f17(x$stat))); md5_fichier(f) }, "")

# --- Lecture d'un taux (classes de #166 ; copie de lecture() de #206) --------
CLASSES <- c("compatible", "\u00e9cart mineur", "\u00e9cart non tranch\u00e9", "distorsion mat\u00e9rielle")
lecture <- function(k, n, ref) {
  if (n == 0 || !is.finite(ref))
    return(list(k = k, n = n, taux = if (n) k / n else NA_real_, ci = if (n) ic_cp(k, n) else c(NA_real_, NA_real_),
                evaluable = FALSE, disj = FALSE, cote = NA_character_,
                classe = if (n == 0) "non \u00e9valuable (n = 0)" else "non \u00e9valuable (\u03c1 absente)"))
  ci <- ic_cp(k, n); t <- k / n
  ref_ic <- ref >= ci[1] && ref <= ci[2]
  cote <- if (ci[2] < ref / 2) "conservateur" else if (ci[1] > 3 * ref / 2) "lib\u00e9ral" else NA_character_
  classe <- if (ref_ic) CLASSES[1] else if (!is.na(cote)) CLASSES[4] else
    if (t >= ref / 2 && t <= 3 * ref / 2) CLASSES[2] else CLASSES[3]
  list(k = k, n = n, taux = t, ci = ci, evaluable = TRUE, disj = !is.na(cote), cote = cote, classe = classe)
}
txt_classe <- function(c_) if (c_$disj) sprintf("%s (**%s**)", c_$classe, c_$cote) else c_$classe
mcnemar <- function(d1, d2) {
  n01 <- sum(d1 & !d2); n10 <- sum(!d1 & d2); n <- n01 + n10
  c(n01 = n01, n10 = n10, p = if (n) stats::binom.test(n01, n, 0.5)$p.value else 1)
}
# Population d'une cellule : triangles admis ; une p absente compte comme un
# non-rejet (#242), comptee a part.
pop <- function(cl) D[D$cle == cl & D$statut == "admis", , drop = FALSE]
rejet <- function(p, a) is.finite(p) & p < a
col_p <- function(f) paste0("p_", f)

# --- T1 : niveau sous H0 -----------------------------------------------------
CEL_T1 <- list()
for (cl in c("H0-N", "H0-E", "H0-A")) {
  l <- CELLULES$loi[CELLULES$cle == cl]; x <- pop(cl)
  for (f in FORMES) for (j in seq_along(SEUILS)) {
    a <- SEUILS[j]; p <- x[[col_p(f)]]
    CEL_T1[[length(CEL_T1) + 1L]] <- list(loi = l, forme = f, ia = IA[j], rho = ORACLE[[l]]$rho[j, f], abs = sum(!is.finite(p)),
                                          c = lecture(sum(rejet(p, a)), nrow(x), ORACLE[[l]]$rho[j, f]))
  }
}
evaluer_k1 <- function() {
  k1 <- Filter(function(z) z$forme == "bas" && z$loi %in% c("N", "E"), CEL_T1)
  if (!length(k1) || any(!vapply(k1, function(z) z$c$evaluable, logical(1)))) return("non \u00e9valuable (cellule sans \u03c1 ou sans triangle)")
  cl <- vapply(k1, function(z) z$c$classe, ""); co <- vapply(k1, function(z) if (z$c$disj) z$c$cote else "", "")
  # Ecart non tranche : cote lu en comparant le taux a rho_bas (precision
  # d'actuary du 16/10/2026, TEXTE_PRECISION_K1).
  nt <- vapply(k1, function(z) if (z$c$classe == CLASSES[3]) (if (z$c$taux > z$rho) "lib\u00e9ral" else "conservateur") else "", "")
  det <- paste(vapply(seq_along(k1), function(i) { z <- k1[[i]]
    sprintf("%s %s : %s%s", z$loi, lib_ia(z$ia), txt_classe(z$c), if (nzchar(nt[i])) sprintf(" (c\u00f4t\u00e9 %s)", nt[i]) else "") }, ""),
    collapse = " ; ")
  if (any(co == "lib\u00e9ral")) return(sprintf("**\u00c9CHEC : distorsion mat\u00e9rielle lib\u00e9rale \u21d2 arr\u00eat au point D2-Fd** (%s)", det))
  if (any(nt == "lib\u00e9ral"))
    return(sprintf("**point d'arr\u00eat D2-Fd (\u00e9cart non tranch\u00e9, c\u00f4t\u00e9 lib\u00e9ral), soumis \u00e0 la lecture d'actuary et \u00e0 la d\u00e9cision du mainteneur** (%s)", det))
  if (all(cl %in% CLASSES[1:2])) return(sprintf("**rempli** (%s)", det))
  sprintf("**non rempli c\u00f4t\u00e9 conservateur** : %s, document\u00e9 sans arr\u00eat (%s)",
          paste(c(if (any(co == "conservateur")) "distorsion mat\u00e9rielle conservatrice",
                  if (any(nt == "conservateur")) "\u00e9cart non tranch\u00e9 c\u00f4t\u00e9 conservateur"), collapse = " et "), det)
}
ETAT_K1 <- evaluer_k1()

tab_t1 <- function() {
  L <- c("### T1 \u2014 niveau sous H0 (loi \u00d7 forme \u00d7 seuil)", "",
         paste("Taux de rejet k / n (p_mc < \u03b1) sur les triangles admis, p absente compt\u00e9e comme non-rejet ; IC de Clopper-Pearson",
               "\u00e0 95 % ; \u03c1 : taille liss\u00e9e \u00e0 B du test de Monte-Carlo id\u00e9al tirant ses r\u00e9pliques dans la loi oracle F0",
               "(r\u00e8gle de #206, forme de la ligne) ; classe de #166 contre \u03c1 (c\u00f4t\u00e9 en gras si l'IC est disjoint de la bande",
               "[\u03c1/2 ; 3\u03c1/2]), calcul\u00e9e sur les valeurs non arrondies. K1 lit les lignes \u00ab bas \u00bb sous N et E ; la loi A est",
               "descriptive."), "",
         entete_md(c("Loi", "Forme", "Seuil", "n", "p absentes", "k", "taux [IC 95 %]", "\u03c1", "classe")))
  for (z in CEL_T1) L <- c(L, ligne_md(z$loi, z$forme, lib_ia(z$ia), z$c$n, z$abs, z$c$k, sprintf("%s %s", num(z$c$taux, D_IC), txt_ic(z$c$ci)),
                                       num(z$rho, 5), txt_classe(z$c)))
  L <- c(L, "", "**Loi oracle F0 de la statistique observ\u00e9e (N0 triangles par loi, sans bootstrap).**", "",
         entete_md(c("Loi", "N0", "admis", "statistiques finies", "valeurs distinctes", "masse du plus gros atome",
                     "\u03c1 deux 0,10", "\u03c1 deux 0,05", "\u03c1 bas 0,10", "\u03c1 bas 0,05")))
  for (l in LOIS) { o <- ORACLE[[l]]
    L <- c(L, ligne_md(l, o$n, o$n_adm, o$n_fin, o$distinctes, num(o$atome, 5), num(o$rho[1, "deux"], 5), num(o$rho[2, "deux"], 5),
                       num(o$rho[1, "bas"], 5), num(o$rho[2, "bas"], 5))) }
  c(L, "")
}
# --- T2 : puissance ----------------------------------------------------------
ALTS <- CELLULES$cle[CELLULES$scenario != "H0"]
tab_t2 <- function() {
  L <- c("### T2 \u2014 puissance (sc\u00e9nario \u00d7 forme \u00d7 seuil), loi N", "",
         paste("Taux de rejet k / n [IC de Clopper-Pearson \u00e0 95 %] ; paires discordantes sur les m\u00eames triangles et les m\u00eames",
               "r\u00e9plications (\u00ab bas seul \u00bb : la forme bas rejette, la forme deux non ; \u00ab deux seul \u00bb : l'inverse) ; McNemar exact",
               "bilat\u00e9ral (binomiale de param\u00e8tre 1/2 sur les paires discordantes). K2 : descriptif, aucun seuil."), "",
         entete_md(c("Sc\u00e9nario", "Seuil", "n", "taux deux [IC]", "taux bas [IC]", "bas seul / deux seul", "McNemar p")))
  for (cl in ALTS) { x <- pop(cl)
    for (j in seq_along(SEUILS)) { a <- SEUILS[j]
      rd <- rejet(x$p_deux, a); rb <- rejet(x$p_bas, a); m <- mcnemar(rb, rd)
      L <- c(L, ligne_md(lib_scenario(cl), lib_ia(IA[j]), nrow(x), sprintf("%s %s", num(mean(rd), D_IC), txt_ic(ic_cp(sum(rd), nrow(x)))),
                         sprintf("%s %s", num(mean(rb), D_IC), txt_ic(ic_cp(sum(rb), nrow(x)))), sprintf("%d / %d", m[["n01"]], m[["n10"]]), fmt_p(m[["p"]]))) } }
  c(L, "")
}
# --- T3 : regle de 1997 ------------------------------------------------------
tab_t3 <- function() {
  L <- c("### T3 \u2014 r\u00e8gle de Mack (1997) appliqu\u00e9e \u00e0 toutes les diagonales (descriptif, #275)", "",
         paste("Part des triangles admis o\u00f9 au moins une diagonale retenue (n_k \u2265 2) a P(Z_k \u2264 z_k) \u2264 10 % sous Binomiale(n_k, 1/2),",
               "sans correction de multiplicit\u00e9 ; nombre moyen de diagonales signal\u00e9es ; diagonales pouvant porter le rep\u00e8re (n_k \u2265 5)."), "",
         entete_md(c("Cellule", "n", "\u2265 1 diagonale signal\u00e9e [IC]", "diagonales signal\u00e9es (moyenne)", "diagonales \u00e0 n_k \u2265 5 (m\u00e9diane)")))
  for (cl in CELLULES$cle) { x <- pop(cl)
    n5 <- vapply(strsplit(x$n_k, ",", fixed = TRUE), function(v) sum(as.numeric(v) >= 5), 1)
    k <- sum(x$n_rep97 >= 1)
    L <- c(L, ligne_md(lib_scenario(cl), nrow(x), sprintf("%s %s", num(k / nrow(x), D_IC), txt_ic(ic_cp(k, nrow(x)))), num(mean(x$n_rep97), 3),
                       if (length(n5)) sprintf("%.0f", stats::median(n5)) else "\u2014")) }
  c(L, "")
}
# --- T4 : p_min_mc -----------------------------------------------------------
tab_t4 <- function() {
  L <- c("### T4 \u2014 plancher Monte-Carlo p_min_mc des deux formes", "",
         sprintf(paste("Maximum de p_min_mc sur les triangles admis \u00e0 p_mc finie, et parts > \u03b1/2 et > \u03b1 (\u03b1 = %s, \u03b1 des verdicts ;",
                       "entre parenth\u00e8ses, parts \u2265, comparaison de la r\u00e8gle R1 d'add())."), num(ALPHA, 2)), "",
         entete_md(c("Cellule", "Forme", "n (p_min_mc finie)", "maximum", "part > \u03b1/2 (\u2265)", "part > \u03b1 (\u2265)")))
  for (cl in CELLULES$cle) { x <- pop(cl)
    for (f in FORMES) { v <- x[[paste0("pmm_", f)]]; v <- v[is.finite(v)]
      pr <- function(s) if (!length(v)) "\u2014" else sprintf("%s (%s)", num(mean(v > s), D_IC), num(mean(v >= s), D_IC))
      L <- c(L, ligne_md(lib_scenario(cl), f, length(v), if (length(v)) num(max(v), 4) else "\u2014", pr(ALPHA / 2), pr(ALPHA))) } }
  c(L, "")
}
# --- T5 : transitions de verdict ---------------------------------------------
# Regle d'add() (sens "ne pas rejeter") : p absente -> INFO (diagnostic,
# #181) ; p_min_mc >= alpha -> TEST INOPERANT (R1, branche Monte-Carlo) ;
# sinon ECHEC si p < alpha/2, ALERTE si p < alpha, OK sinon.
VERDICTS <- c("OK", "ALERTE", "ECHEC", "INOPERANT", "INFO")
verdict <- function(p, pmm) ifelse(!is.finite(p), "INFO", ifelse(is.finite(pmm) & pmm >= ALPHA, "INOPERANT",
                                   ifelse(p < ALPHA / 2, "ECHEC", ifelse(p < ALPHA, "ALERTE", "OK"))))
tab_t5 <- function() {
  L <- c("### T5 \u2014 transitions de verdict \u00ab deux \u00bb \u2192 \u00ab bas \u00bb (descriptif)", "",
         sprintf(paste("R\u00e8gle d'add() \u00e0 \u03b1 = %s : ECHEC si p < \u03b1/2, ALERTE si p < \u03b1, OK sinon ; TEST INOPERANT si p_min_mc \u2265 \u03b1",
                       "(r\u00e8gle R1, branche Monte-Carlo) ; INFO si la p Monte-Carlo manque. Ligne : verdict de la forme deux ; colonne :",
                       "verdict de la forme bas ; effectifs de triangles admis."), num(ALPHA, 2)), "")
  for (cl in CELLULES$cle) { x <- pop(cl)
    vd <- factor(verdict(x$p_deux, x$pmm_deux), levels = VERDICTS); vb <- factor(verdict(x$p_bas, x$pmm_bas), levels = VERDICTS)
    tb <- table(vd, vb)
    keep_r <- rowSums(tb) > 0 | VERDICTS %in% VERDICTS[1:3]; keep_c <- colSums(tb) > 0 | VERDICTS %in% VERDICTS[1:3]
    L <- c(L, sprintf("**%s** (n = %d).", lib_scenario(cl), nrow(x)), "", entete_md(c("deux (ligne) / bas (colonne)", VERDICTS[keep_c])))
    for (r in VERDICTS[keep_r]) L <- c(L, ligne_md(r, paste(tb[r, keep_c], collapse = " | ")))
    L <- c(L, "") }
  L
}
# --- T6 : p asymptotiques ----------------------------------------------------
tab_t6 <- function() {
  L <- c("### T6 \u2014 niveau des p asymptotiques sous H0", "",
         paste("p bilat\u00e9rale 2(1 \u2212 \u03a6(|Z*|)) (forme actuelle du moteur) et p unilat\u00e9rale \u03a6(Z*) (Q-Fd-3) : taux de rejet k / n",
               "[IC 95 %] sur les triangles mesur\u00e9s, et taux sur l'\u00e9chantillon oracle (N0 triangles, statistique seule ;",
               "d\u00e9nominateur : triangles oracle admis)."), "",
         entete_md(c("Loi", "Forme", "Seuil", "n", "taux [IC]", "taux oracle (N0)")))
  for (cl in c("H0-N", "H0-E", "H0-A")) { l <- CELLULES$loi[CELLULES$cle == cl]; x <- pop(cl)
    for (f in FORMES) for (j in seq_along(SEUILS)) {
      p <- x[[paste0("p_as_", f)]]; k <- sum(rejet(p, SEUILS[j]))
      L <- c(L, ligne_md(l, f, lib_ia(IA[j]), nrow(x), sprintf("%s %s", num(k / nrow(x), D_IC), txt_ic(ic_cp(k, nrow(x)))),
                         num(ORACLE[[l]]$niv_as[j, f], D_IC))) } }
  c(L, "")
}

###############################################################################
#  SORTIES
###############################################################################
COLS_BRUT <- COLS_LIGNE
BRUT <- c(paste(c("scenario", "loi", "param", COLS_BRUT), collapse = "\t"),
          vapply(seq_len(nrow(D)), function(i) {
            x <- D[i, ]; ce <- CELLULES[CELLULES$cle == x$cle, ]
            v <- vapply(COLS_BRUT, function(k) { z <- x[[k]]
              if (is.numeric(z)) f17(z) else if (is.logical(z)) ifelse(is.na(z), "NA", ifelse(z, "TRUE", "FALSE")) else ifelse(is.na(z), "NA", nettoyer_champ(z)) }, "")
            paste(c(ce$scenario, ce$loi, if (is.na(ce$param)) "NA" else f17(ce$param), v), collapse = "\t") }, ""))
F_BRUT_TMP <- tempfile("brut276_", fileext = ".tsv"); ecrire_fichier(F_BRUT_TMP, BRUT); MD5_BRUT <- md5_fichier(F_BRUT_TMP)
duree_moy <- function(cl) { x <- pop(cl); if (nrow(x)) mean(x$duree) else NA_real_ }
T_TRI <- mean(D$duree[D$statut == "admis" & is.na(D$i2)])
T_TRI_I2 <- if (any(!is.na(D$i2))) mean(D$duree[!is.na(D$i2)]) else NA_real_
T_ORA <- mean(O$duree)
N_TRI_SPEC <- sum(c(2000, 2000, 1000, rep(1000, 7))); N_I2_SPEC <- sum(ceiling(c(2000, 2000, 1000, rep(1000, 7)) / TAILLE_TRANCHE))
CPU_SPEC <- (N_TRI_SPEC - N_I2_SPEC) * T_TRI * B_SPEC / B_BOOT + N_I2_SPEC * T_TRI_I2 * B_SPEC / B_BOOT + 3 * N0_SPEC * T_ORA
TXT_DUREE <- sprintf(paste("contr\u00f4les g\u00e9n\u00e9raux %.0f s ; calcul des tranches %.0f s d'horloge sur %d c\u0153ur(s) (%d tranche(s) calcul\u00e9e(s), %d reprise(s)) ;",
                           "somme des dur\u00e9es des tranches %.0f s CPU ; par triangle admis (B = %.0f) : %s s sans (i2), %s s avec (i2) ; par triangle oracle : %s s ;",
                           "estimation du plan complet (B = 999, %d triangles, 3 \u00d7 %d oracle) : %s h CPU, soit %s h d'horloge sur 4 c\u0153urs (efficacit\u00e9 parall\u00e8le suppos\u00e9e 1)"),
                     T_CTRL, DUREE_HORLOGE, COEURS, length(A_FAIRE), sum(existe), sum(DUREES_TR), B_BOOT, num(T_TRI, 3), num(T_TRI_I2, 3), num(T_ORA, 4),
                     N_TRI_SPEC, N0_SPEC, num(CPU_SPEC / 3600, 2), num(CPU_SPEC / 3600 / 4, 2))
plan_txt <- sprintf("%s ; N0 = %d par loi (N, E, A) ; B = %.0f ; seuils 0,10 et 0,05 ; \u03b1 des verdicts %s",
                    paste(sprintf("%s R = %d", vapply(CELLULES$cle, lib_scenario, ""), CELLULES$R), collapse = " ; "), N0, B_BOOT, num(ALPHA, 2))
TXT_GRAINES <- sprintf("triangle b, cellule c : %.0f + %.0f (c \u2212 1) + b ; bootstrap : %.0f + %.0f (c \u2212 1) + b ; oracle k, loi \u2113 : %.0f + %.0f (\u2113 \u2212 1) + k (\u2113 = 1 N, 2 E, 3 A) ; c = rang de la cellule : %s ; contr\u00f4les sur reserve2 : %.0f ; toutes sous engine_sous_graine()",
                       GRAINE_TRI, PAS, GRAINE_BOOT, PAS, GRAINE_ORA, PAS_ORA, paste(sprintf("%d %s", seq_len(nrow(CELLULES)), CELLULES$cle), collapse = ", "), GRAINE_R2)
refus <- vapply(CELLULES$cle, function(cl) { x <- D[D$cle == cl, ]; sprintf("%s %d / %d", cl, sum(x$statut == "refuse"), nrow(x)) }, "")
refus_or <- vapply(LOIS, function(l) sprintf("oracle %s %d / %d", l, ORACLE[[l]]$n - ORACLE[[l]]$n_adm, ORACLE[[l]]$n), "")
beff <- sprintf("minimum %.0f ; part des triangles admis \u00e0 B effectif < B : %s ; triangles \u00e0 cumul retir\u00e9 (#257) : %d ; plafond atteint : %d",
                min(D$B_eff[adm]), num(mean(D$B_eff[adm] < B_BOOT), 5), sum(D$retires[adm]), sum(D$plafond[adm]))
T0 <- c(entete_md(c("Grandeur", "Valeur")),
        ligne_md("Commit", COMMIT),
        ligne_md("Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)", plateforme_calcul()),
        ligne_md("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
        ligne_md("Empreintes md5 du code ex\u00e9cut\u00e9", EMPREINTES),
        ligne_md("Empreinte sans commentaires de R/engine.R (#231)", EMPREINTE_SC),
        ligne_md("Locale LC_CTYPE (origine \u2192 travail)", sprintf("%s \u2192 %s", LOCALE_ORIGINE, LOCALE_TRAVAIL)),
        ligne_md("DGP (#206, par. 2)", sprintf("mod\u00e8le de Mack ajust\u00e9 \u00e0 reserve2 (tests/donnees/triangle_mw.csv), I = J = %d, premi\u00e8re colonne fix\u00e9e ; f\u0302 = (%s) ; \u03c3\u0302\u00b2 = (%s) ; lois N (stats::rnorm), E (loi uniforme sur les %d valeurs de .mw_pool_residus(aj0, jd0) divis\u00e9es par leur \u00e9cart-type de population %s), A ((G \u2212 2)/\u221a2, G ~ Gamma(2) par inversion) ; alternatives : effet multiplicatif sur les incr\u00e9ments de l'exercice t = i + k (i, k \u00e0 partir de 0, premi\u00e8re colonne comprise), puis recumul (spec par. 2.2)",
                                               AJ0$I, paste(sub(".", ",", sprintf("%.5f", AJ0$f), fixed = TRUE), collapse = " ; "),
                                               paste(sub(".", ",", sprintf("%.5g", AJ0$sigma2), fixed = TRUE), collapse = " ; "), length(POOL0), num(SD_POP0, 4))),
        ligne_md("Plan (spec par. 2.3)", plan_txt),
        ligne_md("Graines", TXT_GRAINES),
        ligne_md("Graines : recherche des collisions", cgr$txt),
        ligne_md("Triangles refus\u00e9s", paste(c(refus, refus_or), collapse = " ; ")),
        ligne_md("B effectif (forme deux et bas : m\u00eames r\u00e9plications)", beff),
        ligne_md("\u00c9chantillons oracle (non versionn\u00e9s, r\u00e9g\u00e9n\u00e9rables par leurs graines) : md5 des valeurs", paste(sprintf("%s %s", LOIS, MD5_ORACLE), collapse = " ; ")),
        ligne_md("Reprise", TXT_REPRISE),
        ligne_md("Dur\u00e9e", TXT_DUREE),
        ligne_md("Valeurs brutes", sprintf("%s : md5 %s, %d lignes", NOMS_SORTIE[["brut"]], MD5_BRUT, length(BRUT) - 1L)),
        ligne_md("Versionnable (--ecrire)", if (length(NV)) paste("non :", paste(NV, collapse = " ; ")) else "oui"),
        ligne_md("Crit\u00e8re K1 (texte recopi\u00e9 tel quel, fix\u00e9 avant ex\u00e9cution)", TEXTE_K1),
        ligne_md("Pr\u00e9cision d'actuary sur K1 (fix\u00e9e avant ex\u00e9cution, distincte du texte de K1)", TEXTE_PRECISION_K1),
        ligne_md("K1 : \u00e9valuation m\u00e9canique", ETAT_K1),
        ligne_md("Contr\u00f4les", paste(gsub("|", "\\|", CONTROLES, fixed = TRUE), collapse = " ; ")))
SORTIE <- c("## Mesure #276 : test calendaire de Mack \u00e0 T = 8, forme bilat\u00e9rale (\u00ab deux \u00bb) contre forme unilat\u00e9rale (\u00ab bas \u00bb)", "",
            paste("Statut : **constat de simulation sous un plan** (mod\u00e8le de Mack ajust\u00e9 \u00e0 reserve2, DGP de #206), pas un r\u00e9sultat",
                  "g\u00e9n\u00e9ral ; il ne se transpose ni \u00e0 une autre g\u00e9om\u00e9trie de triangle ni \u00e0 un autre param\u00e9trage. Aucun th\u00e9or\u00e8me ne",
                  "couvre ce test bootstrap \u00e0 T = 8. Protocole : docs/specifications/fd-test-calendaire.md, par. 2.3. Les deux formes sont",
                  "calcul\u00e9es par engine_p_mc() sur les m\u00eames r\u00e9plications, reproduction de la boucle de mw_bootstrap() : identit\u00e9",
                  "v\u00e9rifi\u00e9e par (i2) sur un triangle sur 50 ; \u00e9cart possible non couvert : erreur d'une autre statistique de",
                  ".mw_stats() (mesur\u00e9 \u00e0 l'audit : 0 sur 41 958 r\u00e9plications) ; la forme",
                  "\u00ab bas \u00bb est une copie locale de l'entr\u00e9e Calendrier du catalogue, moteur inchang\u00e9. IC : Clopper-Pearson \u00e0 95 %,",
                  "incertitude sur le taux (fonction de R), distincte de l'erreur de \u03c1 (fonction de N0) et de err_mc (fonction de B).",
                  "Bande de Bradley : convention de lecture (#166), pas th\u00e9or\u00e8me."), "",
            if (OPT_ESSAI) c("**Essai (--essai) : plan r\u00e9duit, non versionnable.**", ""),
            "### T0 \u2014 provenance", "", T0, "", tab_t1(), tab_t2(), tab_t3(), tab_t4(), tab_t5(), tab_t6())
ecrire_console(SORTIE)
abs_l <- chemins_absolus(SORTIE)
if (length(abs_l)) {
  message("chemin absolu ou /tmp dans le tableau (D-a de #242) : ", length(abs_l), " ligne(s)")
  if (OPT_ECRIRE) stop("--ecrire refuse : chemin absolu ou /tmp dans le tableau")
}
if (OPT_ECRIRE) {
  nv1 <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, c(SPEC, SPEC_206)), "de l'\u00e9criture")
  if (length(nv1)) stop("--ecrire refuse : ", paste(nv1, collapse = " ; "))
  rem <- garde_ecrasement(CIBLES, OPT_REMPLACER, RACINE)
  if (!file.copy(F_BRUT_TMP, CIBLES[["brut"]], overwrite = TRUE) || !identical(md5_fichier(CIBLES[["brut"]]), MD5_BRUT)) stop("copie des valeurs brutes refusee")
  ecrire_fichier(CIBLES[["md"]], inserer_t0(SORTIE, c(ligne_remplacement(rem, CIBLES[["md"]]), ligne_remplacement(rem, CIBLES[["brut"]]))))
  message("ecrit : ", paste(NOMS_SORTIE, collapse = ", "))
} else {
  ds <- file.path(DOSSIER_TR, "sortie"); dir.create(ds, showWarnings = FALSE)
  cib <- file.path(ds, NOMS_SORTIE)
  if (any(file.exists(cib))) {
    message("sortie deja presente dans ", ds, " (jamais ecrasee) : fichiers non reecrits")
  } else {
    if (!file.copy(F_BRUT_TMP, cib[2]) || !identical(md5_fichier(cib[2]), MD5_BRUT)) stop("copie des valeurs brutes refusee")
    ecrire_fichier(cib[1], SORTIE)
    message("ecrit (hors depot) : ", paste(cib, collapse = ", "))
  }
}
unlink(F_BRUT_TMP)
message(sprintf("K1 : %s", ETAT_K1))
message(sprintf("duree : %s", TXT_DUREE))
