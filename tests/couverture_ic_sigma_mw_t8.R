###############################################################################
#  tests/couverture_ic_sigma_mw_t8.R  --  COUVERTURE A T = 8 DE L'INTERVALLE
#  BOOTSTRAP DE SIGMA, METHODE MERZ-WUTHRICH (issue #387, branche S5,
#  etape 4), ET VOLET A.5 (ii) DE #492 (taux de rejet des p de Monte-Carlo
#  sur les triangles admis d'un profil volatil)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats ; parallel, utils et tools (livres avec R). Il ne modifie
#  ni R/, ni app.R, ni tests/reference/ ; ni le moteur ni l'application ne le
#  lisent (controle 12). Les intervalles, la boucle allegee, n_sans_sigma, la
#  p conditionnelle et sigma_B sont calcules ICI, jamais dans le moteur ;
#  aucun effet sur sigma_USP, une p-value ou un verdict (P1). Le moteur est
#  charge par tests/outils_tests.R, donc par charger_moteur() (ADR 0016), qui
#  porte aussi commit_depot(), motifs_non_versionnable(), garde_ecrasement(),
#  empreinte_sans_commentaires(), TOLERANCE, DATE_REFERENCE_TESTS et .tri.
#  Fichier source ASCII : tous les libelles non ASCII sont ecrits en
#  echappements \u ; sortie en UTF-8, y compris sous LC_ALL=C (la categorie
#  LC_CTYPE est basculee sur une locale UTF-8 au demarrage si necessaire).
#
#  Protocole : rapport d'actuary
#  docs/revues/20261119-s5-bootstrap-mw/actuary-1b-protocole-387.md, P1 a
#  P11 et par. 3, et decisions du mainteneur du 19/11/2026 (fin du meme
#  fichier) : Q-1b-1 (A) cible principale sigma_A (sigma chapeau du triangle
#  generateur), sigma_B descriptive ; Q-1b-2 (b) chemin hybride (boucle
#  allegee sur P1, P2, P3 et P5 avec le controle 5, mw_bootstrap() complet
#  sur P4) ; profils, niveaux L0 a L2 (3 h), critere K-M1 a K-M5, profils
#  Omega0 a Omega4, Omega2' et V approuves tels quels ; Q-1b-5 (A) oracle
#  conditionnel, McNemar avec la p conditionnelle, temoin, profils Lambda.
#  Le critere et les profils du par. 3 sont reportes SANS MODIFICATION dans
#  TEXTE_CRITERE_387 (controle 11, (t387) : presence a l'identique dans le
#  rapport verse) ; le statut epistemique du par. 1 est reproduit tel quel en
#  tete de la sortie (TEXTE_STATUT_387, meme controle).
#
#  Statut des valeurs : CONSTAT DE SIMULATION sous le modele de Mack ajuste a
#  un triangle generateur, une loi d'erreurs et T = 8 ; pas un resultat
#  general. Classes et profils evalues mecaniquement, SANS CONCLURE : la
#  lecture revient a actuary, la decision (D2) au mainteneur.
#
#  Plan (P2). Generateurs : reserve2 (tests/donnees/triangle_mw.csv, plan de
#  #206) et la fixture volatile de A.0 de 1a (#492) : lue dans
#  tests/donnees/triangle_mw_volatil.csv si ce fichier existe, sinon dans le
#  dput embarque (FIXTURE_DPUT) ; leur egalite est verifiee au T0 (controle
#  "fixture"). Profils : P1 reserve2 / E (principal), P2 reserve2 / N
#  (principal), P3 reserve2 / A (descriptif), P4 fixture / E (secondaire,
#  volet A.5 (ii)), P5 fixture / N (descriptif). E : pool redresse du
#  generateur divise par son ecart-type de population ; N : rnorm ;
#  A : (Gamma(2) - 2)/sqrt(2). Generateur gen_triangle_h0() et admission
#  admettre() : copies declarees de tests/calibration_mc_mw_t8.R (admettre()
#  rend en plus un code de motif ; "M4" = reserve chain-ladder <= 0).
#  Triangle refuse : compte avec son motif, sans nouveau tirage.
#
#  Par triangle simule r du profil p (P4, P5) :
#    1. tri = gen_triangle_h0(aj0, loi) sous engine_sous_graine(G_tri(p, r)) ;
#    2. admettre(tri) ; refus compte ;
#    3. sigma chapeau = sqrt(MSEP)/R ; sigma_B (P3) par recomposer() ;
#    4. boucle allegee (boucle_allegee(), transcription de la boucle de
#       mw_bootstrap() sans .mw_stats()) a B, graine G_boot(p, r) : sigma*
#       aligne sur b, masque des sigma* finis ;
#    5. P4 (et premier triangle admis de chaque tranche de P1, P2, P3, P5) :
#       mw_bootstrap(aj, B, G_boot(p, r), figes) complet ; controles 5, 8 et,
#       sur P4, 14 ; P4 : p_mc du moteur et p conditionnelle (P8) ;
#    6. intervalles I1, I2, I4 a 90 % et 95 % sur sigma* (plus de 20 valeurs).
#  Graines (P6), toutes sous engine_sous_graine() : triangle r du profil p :
#  387 000 000 + 1 000 000 (p - 1) + r ; bootstrap : 387 500 000 +
#  1 000 000 (p - 1) + r ; oracle de P4 : 392 000 000 + k ; pre-vol :
#  393 000 000 + ... (sous-plages declarees ci-dessous) ; r, k <= 100 000.
#  Graines de #206 (controle 9 seulement) : bornes PLAGE_C9_*.
#
#  Intervalles (P4 du protocole), sur l'echelle de sigma, quantiles de type 7
#  des sigma* finis, niveau 1 - 2 alpha : I1 percentile [q_a ; q_(1-a)] ;
#  I2 "basic" [2 s - q_(1-a) ; 2 s - q_a] ; I4 "basic" log [s^2/q_(1-a) ;
#  s^2/q_a] (borne haute +Inf si q_a = 0, comptee a part) ; s = sigma chapeau
#  du triangle simule. Couverture : borne basse <= cible <= borne haute.
#
#  Controles d'integrite (P11 ; un seul echec : INTEGRITE ECHEC) : 1 md5,
#  SHA et empreinte #231 ; 2 sigma_A ; 3 percentile contre ic_bootstrap ;
#  4 bornes independantes ; 5 boucle allegee contre mw_bootstrap() ; 6 (g) ;
#  7 (i2) ; 8 n_sans_sigma ; 9 p_mc du brut de #297 ; 10 graines ; 11 (t387) ;
#  12 (m) ; 13 sigma_B ; 14 .mc_p_values(). Plus "fixture" (egalite du
#  fichier et du dput). Controles 2, 3, 6, 8 (fixture), 9, 10, 11, 12 et
#  "fixture" AVANT tout tirage du plan : un echec arrete le script.
#
#  Modes :
#    --essai [--R n] [--processus k] [--travail D] : R = 4 par profil (40
#      pour l'oracle), B = 199 ; dossier temporaire ; sortie marquee ESSAI ;
#      --ecrire refuse.
#    --prevol [--unites 3] : couts a 1, 2, 3 et 4 processus concurrents
#      (memes unites dans chaque processus, graines du pre-vol), taux
#      d'admission sur les graines du pre-vol, duree planifiee de L0, L1, L2
#      a 4 processus et niveau retenu (P7 : premier niveau tenant dans 3 h
#      d'horloge ; sous L2, retour au mainteneur) ; rien d'ecrit.
#    mesure : --niveau Lk ou --R (n, ou six entiers P1,P2,P3,P4,P5,oracle),
#      ecrit au JOURNAL avant tout calcul ; [--processus k] ; [--travail D] ;
#      [--ecrire [--remplacer]].
#  Reprise (M42 (b)) : tranches de 100 triangles consecutifs d'un profil (et
#  de l'oracle), ecrites dans le dossier de travail (hors du depot) des
#  qu'elles sont completes (temporaire puis renommage) ; une relance avec le
#  meme dossier reprend aux tranches absentes ; une tranche dont le contexte
#  (B, SHA, md5 du moteur et du script, empreinte #231, plateforme) differe
#  du contexte courant arrete le script (pas de melange). Dossier par
#  defaut : <parent de la racine>/issue387-travail-<niveau ou R>.
#  Sorties (dossier de travail ; avec --ecrire, copiees dans docs/tableaux/
#  si INTEGRITE OK) : <AAAAMMJJ>-issue387-couverture-ic-sigma-mw.md,
#  <AAAAMMJJ>-issue387-couverture-ic-sigma-mw-brut.tsv (une ligne par
#  triangle tire, %.17g, sans duree), <AAAAMMJJ>-issue387-journal-mesure.md ;
#  AAAAMMJJ : date (UTC) du premier lancement, lue au JOURNAL. L'oracle reste
#  dans le dossier de travail (oracle-P4.tsv), son md5 au T0. --ecrire exige
#  un commit propre (motifs_non_versionnable()) et garde_ecrasement().
#
#  Usage (racine du depot, LC_ALL=C.UTF-8 sous Linux) :
#      Rscript tests/couverture_ic_sigma_mw_t8.R --essai
#      Rscript tests/couverture_ic_sigma_mw_t8.R --prevol [--unites 3]
#      Rscript tests/couverture_ic_sigma_mw_t8.R --niveau L0 --processus 4
#          [--travail DOSSIER] [--ecrire [--remplacer]]
#  La section finale "Execution" de la sortie (dates, durees, processus) est
#  la seule partie qui varie entre deux executions a arguments egaux.
#  Derniere ligne de la console : INTEGRITE OK ou INTEGRITE ECHEC. Code de
#  sortie : 0 si INTEGRITE OK, 1 sinon (et sur tout refus).
###############################################################################

t_debut <- Sys.time()

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113, critere de #242) -------------
LOCALE_ORIGINE <- Sys.getlocale("LC_CTYPE")
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break
LOCALE_TRAVAIL <- Sys.getlocale("LC_CTYPE")

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
CONNUES <- c("--essai", "--prevol", "--R", "--niveau", "--processus", "--travail", "--ecrire",
             "--remplacer", "--unites")
AVEC_VALEUR <- c("--R", "--niveau", "--processus", "--travail", "--unites")
refuser <- function(...) { message("REFUS : ", ...); quit(status = 1L) }
local({
  i <- 1L
  while (i <= length(ARGS)) {
    if (!ARGS[i] %in% CONNUES) refuser("option inconnue : ", ARGS[i])
    if (ARGS[i] %in% AVEC_VALEUR && i == length(ARGS)) refuser("option ", ARGS[i], " sans valeur")
    i <- i + if (ARGS[i] %in% AVEC_VALEUR) 2L else 1L
  }
})
lire_option <- function(nom, defaut) {
  i <- match(nom, ARGS)
  if (is.na(i)) defaut else ARGS[i + 1L]
}
OPT_ESSAI     <- "--essai" %in% ARGS
OPT_PREVOL    <- "--prevol" %in% ARGS
OPT_ECRIRE    <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_R_TXT     <- lire_option("--R", NA_character_)
OPT_NIVEAU    <- lire_option("--niveau", NA_character_)
OPT_TRAVAIL   <- lire_option("--travail", NA_character_)
OPT_UNITES    <- suppressWarnings(as.integer(lire_option("--unites", "3")))
COEURS <- tryCatch(parallel::detectCores(), error = function(e) NA_integer_)
OPT_PROC <- suppressWarnings(as.integer(lire_option("--processus",
              as.character(if (.Platform$OS.type == "windows") 1L else max(1L, min(4L, COEURS, na.rm = TRUE))))))
MODE <- if (OPT_PREVOL) "prevol" else if (OPT_ESSAI) "essai" else "mesure"
if (OPT_PREVOL && OPT_ESSAI) refuser("--prevol et --essai sont exclusifs")
if (OPT_PREVOL && any(c("--R", "--niveau", "--ecrire", "--remplacer", "--travail", "--processus") %in% ARGS))
  refuser("--prevol : seule l'option --unites est admise")
if (MODE != "prevol" && "--unites" %in% ARGS) refuser("--unites : reserve a --prevol")
if (OPT_ESSAI && OPT_ECRIRE) refuser("--ecrire refuse sous --essai (sorties non versionnables)")
if (OPT_ESSAI && !is.na(OPT_NIVEAU)) refuser("--niveau : reserve a la mesure")
if (OPT_REMPLACER && !OPT_ECRIRE) refuser("--remplacer : reserve a --ecrire")
if (MODE == "mesure" && is.na(OPT_R_TXT) && is.na(OPT_NIVEAU))
  refuser("mesure : --niveau Lk ou --R obligatoire (fixe par le pre-vol, P7)")
if (is.na(OPT_UNITES) || OPT_UNITES < 1L || OPT_UNITES > 50L) refuser("--unites : entier de 1 a 50")
if (is.na(OPT_PROC) || OPT_PROC < 1L) refuser("--processus : entier >= 1")
if (.Platform$OS.type == "windows" && OPT_PROC > 1L) refuser("--processus > 1 : fork indisponible sous Windows")

# --- Protocole (constantes, P2 a P7) -----------------------------------------
# B en double, comme le B par defaut de run_engine() : mw_bootstrap() restitue
# B tel quel, et un entier rendrait $bootstrap non identical() a celui de
# run_engine() (controle 7).
B_MESURE <- 999
B_ESSAI  <- 199
NOMS_R <- c("P1", "P2", "P3", "P4", "P5", "OR")
R_ESSAI <- c(P1 = 4L, P2 = 4L, P3 = 4L, P4 = 4L, P5 = 4L, OR = 40L)
R_MAX <- 100000L                                          # P6 : r, k <= 100 000
TAILLE_TRANCHE <- 100L
# Niveaux (P7) : triangles TIRES par profil, et de l'oracle de P4.
NIVEAUX <- list(L0 = c(P1 = 2000L, P2 = 2000L, P3 = 1000L, P4 = 1700L, P5 = 3400L, OR = 17000L),
                L1 = c(P1 = 2000L, P2 = 2000L, P3 = 1000L, P4 = 1200L, P5 = 3400L, OR = 17000L),
                L2 = c(P1 = 1000L, P2 = 1000L, P3 = 0L, P4 = 850L, P5 = 0L, OR = 17000L))
BUDGET_S <- 3 * 3600                                      # P7 : 3 h d'horloge
K_BUDGET <- 4L                                            # P7 : sur 4 processus
ALPHA_NIV <- c("90" = 0.05, "95" = 0.025)                 # alpha par queue
RHO_NIV <- 2 * ALPHA_NIV                                  # non-couverture nominale
SEUILS_MC <- c(a10 = 0.10, a05 = 0.05)                    # P8 : seuils des p_mc
NIVEAU_HOLM <- 0.05
TOL_IND <- 1e-12                                          # controle 4
SEUIL_OMEGA0 <- 0.01                                      # profil Omega0
SEUIL_KV4 <- 0.01                                         # K-V4
MIN_SIGMA <- 20L                                          # intervalle si plus de 20 sigma*
CODES <- c("I1", "I2", "I4")
LIB_CODES <- c(I1 = "I1 percentile", I2 = "I2 \u00ab basic \u00bb", I4 = "I4 \u00ab basic \u00bb log")
PROFILS <- data.frame(code = c("P1", "P2", "P3", "P4", "P5"),
                      gen = c("reserve2", "reserve2", "reserve2", "fixture", "fixture"),
                      loi = c("E", "N", "A", "E", "N"),
                      role = c("crit\u00e8re principal (K-M1)", "crit\u00e8re principal (K-M1)", "descriptif (K-M3)",
                               "crit\u00e8re secondaire (K-M2) ; volet A.5 (ii)", "descriptif (K-M3)"),
                      chemin = c("allege", "allege", "allege", "complet", "allege"),
                      stringsAsFactors = FALSE)
STRATES <- c("0", "]0 ; 0,05]", "]0,05 ; 0,20]", "> 0,20")
# Graines (P6). Bases ecrites en entier ; aucune ne tombe dans les plages de
# huit chiffres recherchees par le controle (graines) de
# tests/calibration_mc_mw_t8.R.
GRAINE_TRI  <- 387000000; GRAINE_BOOT <- 387500000; PAS_PROFIL <- 1000000
GRAINE_ORA  <- 392000000
GRAINE_PV   <- 393000000                                  # pre-vol
graine_tri  <- function(p, r) GRAINE_TRI + PAS_PROFIL * (p - 1) + r
graine_boot <- function(p, r) GRAINE_BOOT + PAS_PROFIL * (p - 1) + r
graine_ora  <- function(k) GRAINE_ORA + k
# Pre-vol (sous-plages de [393 000 001 ; 393 100 000], non fixees par le
# protocole) : triangle u du profil p : 393 000 000 + 10 000 (p - 1) + u ;
# bootstrap : 393 050 000 + 10 000 (p - 1) + u ; u <= 10 000.
graine_pv_tri  <- function(p, u) GRAINE_PV + 10000 * (p - 1) + u
graine_pv_boot <- function(p, u) GRAINE_PV + 50000 + 10000 * (p - 1) + u
# Graines de #206, loi E, b = 1 et 2 (controle 9 seulement ; triangle :
# 20 840 000 + 10 000 + b ; bootstrap : 20 870 000 + 10 000 + b). Bornes
# declarees sous la forme PLAGE_<nom> <- c(L1, L2) (R21, #350).
PLAGE_C9_TRI <- c(20850001, 20850002)
PLAGE_C9_BOOT <- c(20880001, 20880002)
# Plages des mesures anterieures (P6), pour la disjonction (controle 10).
PLAGE_EXT_206 <- c(20840001, 20960000)      # #206 et #297, Merz-Wuthrich
PLAGE_EXT_297LN <- c(20260831, 20262831)    # #297 lognormale : 20 260 831 + b, b <= 2 000, et 20 260 927
PLAGE_EXT_305 <- c(305000000, 305939169)    # #305 : 305 000 000 a 305 889 169 + R, R <= 50 000
DECALAGE_LITTERAL <- 20000                  # annotation du 10/10/2026 de #206, point 1
PROTOCOLE <- "docs/revues/20261119-s5-bootstrap-mw/actuary-1b-protocole-387.md"
SPEC_1A <- "docs/revues/20261119-s5-bootstrap-mw/actuary-1a-specification-492-avis-b1.md"
FICHIER_FIXTURE <- "tests/donnees/triangle_mw_volatil.csv"
SCRIPT_DEPOT <- "tests/couverture_ic_sigma_mw_t8.R"
BRUT_297 <- "docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv"
# Fixture volatile de A.0 de 1a (#492), dput reproduit a l'identique.
FIXTURE_DPUT <- structure(c(1022, 1190, 1017, 1017, 1126, 1015, 852, 960, 998, 1383, 1132, 1143, 1230, 1121, 927, NA,
                            1069, 1445, 1128, 1261, 1139, 1053, NA, NA, 1120, 1447, 1119, 1321, 1252, NA, NA, NA, 1266,
                            1491, 1094, 1291, NA, NA, NA, NA, 1336, 1486, 1228, NA, NA, NA, NA, NA, 1199, 1490, NA, NA,
                            NA, NA, NA, NA, 1179, NA, NA, NA, NA, NA, NA, NA), dim = c(8L, 8L))
# Valeurs de n_sans_sigma sur la fixture (1a, A.7, Linux, graine par defaut).
NSS_FIXTURE <- c("199" = 77L, "999" = 453L)

# --- Chargement du moteur et des outils --------------------------------------
FICHIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) f else NA_character_
})
DOSSIER_SCRIPT <- if (!is.na(FICHIER_SCRIPT)) dirname(FICHIER_SCRIPT) else
  if (file.exists("tests/outils_tests.R")) "tests" else "."
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))
SEED_DEFAUT <- eval(formals(run_engine)$seed)
CLES <- names(MW_CATALOGUE_MC)
NS <- length(CLES)
QUEUE <- vapply(CLES, function(s) MW_CATALOGUE_MC[[s]]$queue, "")
CODES_MOTIF <- c(o = MOTIF_MC_OBS_NON_FINIE, z = MOTIF_MC_AUCUNE_REPLIC, i = MOTIF_MC_REPLIC_INSUFFISANTES,
                 d = MOTIF_MC_DISPERSION_NULLE, c = MOTIF_MC_CONDITION, a = MOTIF_MC_ATOME_HORS_OBS)
code_motif <- function(m) ifelse(is.na(m), "-", ifelse(m %in% CODES_MOTIF, names(CODES_MOTIF)[match(m, CODES_MOTIF)], "?"))

# --- Outils de forme ---------------------------------------------------------
utf8 <- function(x) {
  x <- as.character(x)
  if (!isTRUE(l10n_info()[["UTF-8"]])) { k <- Encoding(x) == "unknown"; Encoding(x)[k] <- "UTF-8"; x } else enc2utf8(x)
}
ecrire_console <- function(x) writeLines(utf8(x), useBytes = TRUE)
ecrire_fichier <- function(f, lignes, mode = "wb") {
  con <- file(f, open = mode); on.exit(close(con))
  writeLines(utf8(lignes), con, sep = "\n", useBytes = TRUE)
}
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
num <- function(x, d = 4) if (length(x) != 1L || is.na(x)) "\u2014" else if (is.infinite(x)) (if (x > 0) "+\u221e" else "\u2212\u221e") else
  sub(".", ",", sprintf(paste0("%.", d, "f"), x), fixed = TRUE)
txt_ic <- function(ci, d = 4) if (anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", num(ci[1], d), num(ci[2], d))
fmt_p <- function(p) if (!is.finite(p)) "\u2014" else sub(".", ",", sprintf("%.3g", p), fixed = TRUE)
md5_fichier <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
secs <- function(t0) as.numeric(difftime(Sys.time(), t0, units = "secs"))
horodatage <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
nettoyer_champ <- function(s) gsub("[\t\r\n]+", " ", s)
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(basename(extSoftVersion()[["BLAS"]])), txt(basename(La_library())), txt(La_version()))
}
sha_head <- function() {
  h <- tryCatch(suppressWarnings(system2("git", c("-C", shQuote(RACINE), "rev-parse", "HEAD"),
                                         stdout = TRUE, stderr = FALSE)), error = function(e) character(0))
  if (length(h) == 1L && grepl("^[0-9a-f]{40}$", h)) h else "inconnu"
}
meme_fichier <- function(a, b) !is.na(a) && file.exists(a) && file.exists(b) &&
  identical(normalizePath(a), normalizePath(b))
empreintes_code <- function() {
  lieu <- function(f, ref) if (meme_fichier(f, file.path(RACINE, ref))) "d\u00e9p\u00f4t" else "hors d\u00e9p\u00f4t"
  outils <- file.path(DOSSIER_SCRIPT, "outils_tests.R")
  paste(c(sprintf("R/engine.R %s", md5_fichier(file.path(RACINE, "R", "engine.R"))),
          sprintf("tests/outils_tests.R charg\u00e9 (%s) %s", lieu(outils, "tests/outils_tests.R"), md5_fichier(outils)),
          sprintf("script ex\u00e9cut\u00e9 (%s) %s", lieu(FICHIER_SCRIPT, SCRIPT_DEPOT), md5_fichier(FICHIER_SCRIPT))),
        collapse = " ; ")
}
chemin_absolu <- function(chemin) {
  p <- chemin; reste <- character(0)
  while (!file.exists(p) && dirname(p) != p) { reste <- c(basename(p), reste); p <- dirname(p) }
  base <- normalizePath(p, winslash = "/", mustWork = TRUE)
  if (length(reste)) paste(c(sub("/$", "", base), reste), collapse = "/") else base
}
sous_depot <- function(chemin) {
  d <- chemin_absolu(chemin)
  r <- normalizePath(RACINE, winslash = "/", mustWork = TRUE)
  if (.Platform$OS.type == "windows") { d <- tolower(d); r <- tolower(r) }
  identical(d, r) || startsWith(d, paste0(r, "/"))
}
# Lignes portant un chemin absolu ou /tmp (critere de #242) : refus d'ecrire.
chemins_absolus <- function(lignes) {
  k <- grepl("/tmp", lignes, fixed = TRUE) |
    grepl("(^|[ (|`'\"=])(/(home|root|usr|var|mnt|opt|Users|private|srv|media)/|[A-Za-z]:[\\\\/])", lignes, perl = TRUE)
  lignes[k]
}
# Arguments cites (JOURNAL, T0) : valeur de --travail masquee.
args_cites <- function() {
  a <- ARGS
  i <- match("--travail", a); if (!is.na(i)) a[i + 1L] <- "(dossier hors du d\u00e9p\u00f4t)"
  if (length(a)) paste(a, collapse = " ") else "(aucun)"
}

# --- Contexte au debut du calcul (controle 1) --------------------------------
MD5_MOTEUR_DEBUT <- md5_fichier(file.path(RACINE, "R", "engine.R"))
SHA_DEBUT <- sha_head()
COMMIT_DEBUT <- commit_depot(SCRIPT_DEPOT)
MD5_SCRIPT <- md5_fichier(FICHIER_SCRIPT)
EMPREINTE_DEBUT <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
PLATEFORME <- plateforme_calcul()
EMPREINTES <- empreintes_code()

###############################################################################
#  GENERATEURS, LOIS, ADMISSION (P2)
###############################################################################
lire_triangle_csv <- function(f) {
  df <- utils::read.csv(f)
  m <- as.matrix(df[, setdiff(names(df), "i"), drop = FALSE])
  storage.mode(m) <- "double"
  unname(m)
}
restreindre <- function(tri) { tri[row(tri) + col(tri) - 2L > nrow(tri) - 1L] <- NA; tri }
FIXTURE_FICHIER_PRESENT <- file.exists(file.path(RACINE, FICHIER_FIXTURE))
FIXTURE_LUE <- if (FIXTURE_FICHIER_PRESENT) lire_triangle_csv(file.path(RACINE, FICHIER_FIXTURE)) else NULL
TRI_FIXTURE <- if (FIXTURE_FICHIER_PRESENT) FIXTURE_LUE else FIXTURE_DPUT
moments <- function(x) {
  m <- mean(x); s <- sqrt(mean((x - m)^2))
  c(n = length(x), moyenne = m, ecart_type = s, asymetrie = mean((x - m)^3) / s^3,
    exces_kurtosis = mean((x - m)^4) / s^4 - 3, min = min(x), max = max(x))
}
preparer_generateur <- function(tri) {
  tri <- restreindre(tri)
  aj <- mw_ajuster(tri)
  jd <- .mw_colonnes_degenerees(aj)
  pool <- .mw_pool_residus(aj, jd)
  sd_pop <- sqrt(mean((pool - mean(pool))^2))
  ms <- mw_msep(aj)$msep
  list(tri = tri, aj = aj, jd = jd, pool = pool, sd_pop = sd_pop, pool_E = pool / sd_pop,
       msep = ms, sigma_A = sqrt(ms) / aj$reserve)
}
GEN <- list(reserve2 = preparer_generateur(.tri), fixture = preparer_generateur(TRI_FIXTURE))
tireur <- function(gen, loi) {
  pE <- GEN[[gen]]$pool_E
  switch(loi,
         N = function(n) stats::rnorm(n),
         E = function(n) sample(pE, n, replace = TRUE),
         A = function(n) (stats::qgamma(stats::runif(n), 2) - 2) / sqrt(2))
}
TIREURS <- lapply(seq_len(nrow(PROFILS)), function(p) tireur(PROFILS$gen[p], PROFILS$loi[p]))
SIGMA_A <- vapply(seq_len(nrow(PROFILS)), function(p) GEN[[PROFILS$gen[p]]]$sigma_A, 1)
names(SIGMA_A) <- PROFILS$code
# Generateur : copie declaree de gen_triangle_h0() de tests/calibration_mc_mw_t8.R
# (meme recursion, meme expression, meme ordre de consommation des epsilon,
# meme arret au premier cumul simule non fini ou <= 0, #257). JAMAIS nomme
# mw_simuler_triangle. Le controle 6 en prouve l'identite.
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
triangle_profil <- function(p, graine) engine_sous_graine(graine, gen_triangle_h0(GEN[[PROFILS$gen[p]]]$aj, TIREURS[[p]]))
# Admission : copie declaree de admettre() de tests/calibration_mc_mw_t8.R
# (segment 1, annexe II), avec un code de motif : "cellule" (cumul simule
# <= 0), "triangle" (mw_valider_triangle()), "ajuster", "msep" (erreur),
# "M4" (refus de mw_valider_ajustement() a reserve finie <= 0), "ajustement"
# (autre refus de mw_valider_ajustement()). Rend aussi la MSEP.
admettre <- function(tri) {
  if (.mw_triangle_incomplet(tri)) return(list(ok = FALSE, code = "cellule", motif = "cellule <= 0"))
  v <- mw_valider_triangle(tri, segment = 1, annexe = "II")
  if (!isTRUE(v$ok)) return(list(ok = FALSE, code = "triangle", motif = nettoyer_champ(paste("mw_valider_triangle :", paste(v$erreurs, collapse = " ; ")))))
  aj <- tryCatch(mw_ajuster(tri), error = function(e) e)
  if (inherits(aj, "error")) return(list(ok = FALSE, code = "ajuster", motif = nettoyer_champ(paste("mw_ajuster en erreur :", conditionMessage(aj)))))
  ms <- tryCatch(mw_msep(aj), error = function(e) e)
  if (inherits(ms, "error")) return(list(ok = FALSE, code = "msep", motif = nettoyer_champ(paste("mw_msep en erreur :", conditionMessage(ms)))))
  va <- mw_valider_ajustement(aj, ms$msep)
  if (!isTRUE(va$ok)) {
    m4 <- is.finite(aj$reserve) && aj$reserve <= 0
    return(list(ok = FALSE, code = if (m4) "M4" else "ajustement",
                motif = nettoyer_champ(paste("mw_valider_ajustement :", paste(va$erreurs, collapse = " ; ")))))
  }
  list(ok = TRUE, code = "-", motif = NA_character_, aj = aj, msep = ms$msep)
}
# Statistiques observees par le chemin de l'oracle (copie de stats_oracle() de
# tests/calibration_mc_mw_t8.R).
stats_oracle <- function(aj) .mw_stats(aj, .mw_ensembles_figes(aj, .mw_colonnes_degenerees(aj)))
# Boucle allegee (P2, Q-1b-2 (b)) : transcription de la boucle de
# mw_bootstrap() (memes tirages, dans le meme ordre, sous la meme graine :
# pool redresse sur figes$degeneres, retirage par
# .mw_tirer_triangle_valide() sous le plafond FACTEUR_B_MAX_MW (B + 1),
# mw_ajuster(), puis sigma* = sqrt(MSEP)/R si MSEP finie et R > 0), SANS
# .mw_stats() ni p-value. Rend sigma* aligne sur b (NA sinon), l'indicateur
# des replications ajustees, et les deux booleens du retirage. L'ecart au
# moteur n'existe que si .mw_stats() echoue sur une replication : le
# controle 5 le met en echec.
boucle_allegee <- function(aj, B, seed, figes) {
  engine_sous_graine(seed, {
    pool <- .mw_pool_residus(aj, figes$degeneres)
    n_max <- FACTEUR_B_MAX_MW * (as.numeric(B) + 1)
    n_tires <- 0; retires <- FALSE; plafond <- FALSE
    sig <- rep(NA_real_, B); ajuste <- rep(FALSE, B)
    for (b in seq_len(B)) {
      tir <- .mw_tirer_triangle_valide(aj, pool, n_max - n_tires)
      n_tires <- n_tires + tir$n
      if (tir$rejets > 0) retires <- TRUE
      if (is.null(tir$tri)) { plafond <- TRUE; next }
      ab <- try(mw_ajuster(tir$tri), silent = TRUE)
      if (inherits(ab, "try-error")) next
      ajuste[b] <- TRUE
      mb <- try(mw_msep(ab), silent = TRUE)
      if (!inherits(mb, "try-error") && is.finite(mb$msep) && ab$reserve > 0)
        sig[b] <- sqrt(mb$msep) / ab$reserve
    }
    list(sig = sig, ajuste = ajuste, retires = retires, plafond = plafond)
  })
}
# sigma_B (P3) : copie de l'ajustement aj d'un triangle avec f <- f, sigma2
# <- s2 ; Q, C_chapeau, ultime, reserve_par_annee et reserve recalcules avec
# f par les expressions de mw_ajuster() ; tri, S, Sp et dernier_observe
# gardes. Controle 13 : recomposer(aj, aj$f, aj$sigma2) redonne la MSEP et R
# de mw_ajuster() et mw_msep() (identical()).
recomposer <- function(aj, f, s2) {
  I <- aj$I; J <- aj$J
  Ch <- aj$tri
  for (i in 0:I) {
    d <- I - i
    if (d < J) for (j in (d + 1):J)
      Ch[i + 1, j + 1] <- Ch[i + 1, j] * f[j]
  }
  a <- aj
  a$f <- f; a$sigma2 <- s2; a$Q <- s2 / f^2; a$C_chapeau <- Ch
  a$ultime <- Ch[, J + 1]
  a$reserve_par_annee <- a$ultime - aj$dernier_observe
  a$reserve <- sum(a$ultime - aj$dernier_observe)
  a
}

# --- Parametre de l'echelle sigma_USP (controles 3 et 7) ---------------------
SIGMA_STD <- usp_parametre_standard("reserve2", 1, "II", NULL, NULL, DATE_REFERENCE_TESTS, NULL, NULL)$sigma_standard
BAREME <- usp_bareme_segment(1, "II")
CRED <- usp_credibilite(8L, BAREME)
PROBS_IC <- c(.025, .05, .5, .95, .975)
ic_script <- function(s) if (length(s) > MIN_SIGMA)
  stats::quantile(CRED * s + (1 - CRED) * SIGMA_STD, PROBS_IC, type = 7, names = FALSE) else NULL

# --- Intervalles (P4 du protocole) -------------------------------------------
NOMS_BORNES <- unlist(lapply(CODES, function(k) unlist(lapply(names(ALPHA_NIV), function(n)
  paste(k, n, c("bas", "haut"), sep = "_")))))
PROBS <- c(ALPHA_NIV[["95"]], ALPHA_NIV[["90"]], 1 - ALPHA_NIV[["90"]], 1 - ALPHA_NIV[["95"]])
bornes_intervalles <- function(s, sh) {
  q <- stats::quantile(s, PROBS, type = 7, names = FALSE)
  b <- stats::setNames(rep(NA_real_, length(NOMS_BORNES)), NOMS_BORNES)
  for (n in names(ALPHA_NIV)) {
    lo <- if (n == "90") q[2] else q[1]; hi <- if (n == "90") q[3] else q[4]
    b[paste0("I1_", n, "_", c("bas", "haut"))] <- c(lo, hi)
    b[paste0("I2_", n, "_", c("bas", "haut"))] <- c(2 * sh - hi, 2 * sh - lo)
    b[paste0("I4_", n, "_", c("bas", "haut"))] <- c(sh^2 / hi, if (lo == 0) Inf else sh^2 / lo)
  }
  b
}
# Ecriture independante (controle 4) : statistiques d'ordre et interpolation
# de type 7 en clair, h = (n - 1) p + 1 ; I2 sous la forme s + (s - q) ; I4
# sous la forme exp(2 log s - log q).
q7_clair <- function(v, p) {
  x <- sort(v); n <- length(x)
  vapply(p, function(pp) {
    h <- (n - 1) * pp + 1; j <- floor(h)
    if (j >= n) x[n] else x[j] + (h - j) * (x[j + 1L] - x[j])
  }, numeric(1))
}
bornes_independantes <- function(s, sh) {
  out <- numeric(0)
  for (k in CODES) for (n in names(ALPHA_NIV)) {
    a <- ALPHA_NIV[[n]]
    ql <- q7_clair(s, a); qh <- q7_clair(s, 1 - a)
    out <- c(out, switch(k, I1 = c(ql, qh), I2 = c(sh + (sh - qh), sh + (sh - ql)),
                         I4 = exp(2 * log(sh) - log(c(qh, ql)))))
  }
  stats::setNames(out, NOMS_BORNES)
}
ecart_relatif_max <- function(a, b) {
  if (!identical(is.na(a), is.na(b))) return(Inf)
  k <- !is.na(a)
  if (!any(k)) return(0)
  a <- a[k]; b <- b[k]
  e <- abs(a - b) / pmax(abs(a), abs(b))
  e[a == b] <- 0
  max(e)
}

###############################################################################
#  UN TRIANGLE SIMULE, UN TRIANGLE ORACLE
###############################################################################
COLONNES <- c("profil", "r", "g_tri", "g_boot", "statut", "motif_code", "R_hat", "msep", "sigma_hat",
              "n_lignes", "B_eff_sigma", "nss_leger", "n_sans_sigma", "retires", "plafond", "complet",
              "moy_sigma_star", "rang", NOMS_BORNES, "ecart_ind", "R_B", "msep_B", "sigma_B",
              "ctl5", "ctl8", "nss_champ", "ctl13", "ctl14", "obs_coh", "B_eff_min",
              paste0("obs:", CLES), paste0("p:", CLES), paste0("m:", CLES), paste0("pc:", CLES),
              "message", "duree_s")
COLONNES_BRUT <- setdiff(COLONNES, "duree_s")
COL_TEXTE <- c("profil", "statut", "motif_code", "message", paste0("m:", CLES))
COLONNES_ORA <- c("k", "g_tri", "statut", "motif_code", paste0("obs:", CLES), "duree_s")
COL_TEXTE_ORA <- c("statut", "motif_code")
STATUTS <- c("ok", "sans_intervalle", "refus", "echec_bootstrap", "echec_autre")

# Ligne d'un triangle r du profil p. complet : mw_bootstrap() en plus de la
# boucle allegee (P4 ; premier triangle admis d'une tranche ailleurs).
# garder : rend aussi le triangle, $bootstrap et sigma* (controle 7).
un_triangle <- function(p, r, B, complet = FALSE, garder = FALSE, g_tri = graine_tri(p, r), g_boot = graine_boot(p, r)) {
  t1 <- proc.time()[["elapsed"]]
  L <- stats::setNames(as.list(rep(NA, length(COLONNES))), COLONNES)
  L$profil <- PROFILS$code[p]; L$r <- r; L$g_tri <- g_tri; L$g_boot <- g_boot; L$motif_code <- "-"
  objets <- NULL
  fin <- function(statut, code = "-", msg = NA_character_) {
    L$statut <- statut; L$motif_code <- code; L$message <- msg
    L$duree_s <- proc.time()[["elapsed"]] - t1
    if (garder) list(ligne = L, objets = objets) else L
  }
  tryCatch({
    tri <- triangle_profil(p, g_tri)
    ad <- admettre(tri)
    if (!ad$ok) return(fin("refus", ad$code, ad$motif))
    aj <- ad$aj; ms <- ad$msep; sh <- sqrt(ms) / aj$reserve
    L$R_hat <- aj$reserve; L$msep <- ms; L$sigma_hat <- sh
    g0 <- GEN[[PROFILS$gen[p]]]$aj
    aB <- recomposer(aj, g0$f, g0$sigma2)
    mB <- tryCatch(mw_msep(aB)$msep, error = function(e) NA_real_)
    L$R_B <- aB$reserve; L$msep_B <- mB
    L$sigma_B <- if (is.finite(aB$reserve) && aB$reserve > 0 && is.finite(mB) && mB >= 0) sqrt(mB) / aB$reserve else NA_real_
    a2 <- recomposer(aj, aj$f, aj$sigma2)
    L$ctl13 <- as.integer(identical(mw_msep(a2)$msep, ms) && identical(a2$reserve, aj$reserve))
    figes <- .mw_ensembles_figes(aj)
    lg <- boucle_allegee(aj, B, g_boot, figes)
    s <- lg$sig[is.finite(lg$sig)]
    L$n_lignes <- sum(lg$ajuste); L$B_eff_sigma <- length(s)
    L$nss_leger <- L$n_lignes - length(s); L$n_sans_sigma <- L$nss_leger
    L$retires <- as.integer(lg$retires); L$plafond <- as.integer(lg$plafond); L$complet <- as.integer(complet)
    if (complet) {
      bt <- try(mw_bootstrap(aj, B = B, seed = g_boot, figes = figes), silent = TRUE)
      if (inherits(bt, "try-error")) return(fin("echec_bootstrap", "-", nettoyer_champ(conditionMessage(attr(bt, "condition")))))
      L$ctl5 <- as.integer(identical(bt$sigma_boot, s))
      # n_sans_sigma selon A.2 / P5 (iii) : lignes de stats_boot a au moins une
      # valeur finie et sigma* non fini, sur le masque de la boucle allegee.
      lig <- rowSums(is.finite(bt$stats_boot)) > 0
      nss_m <- sum(lig & !is.finite(lg$sig))
      champ <- bt$n_sans_sigma
      L$nss_champ <- if (is.null(champ)) NA_real_ else as.numeric(champ)
      L$ctl8 <- as.integer(nss_m == sum(lig) - length(bt$sigma_boot) &&
                             (is.null(champ) || (length(champ) == 1L && isTRUE(champ == nss_m))))
      L$n_sans_sigma <- nss_m
      if (PROFILS$code[p] == "P4") {
        e_obs <- .mw_contexte_mc(aj, figes, new.env(parent = emptyenv()))
        obs <- unlist(bt$stats_obs)
        L$ctl14 <- as.integer(identical(.mc_p_values(bt$stats_boot, obs, MW_CATALOGUE_MC, e_obs)$p_mc, bt$p_mc))
        so <- stats_oracle(aj)
        L$obs_coh <- as.integer(identical(unname(so[CLES]), unname(obs[CLES])))
        pc <- .mc_p_values(bt$stats_boot[is.finite(lg$sig), , drop = FALSE], obs, MW_CATALOGUE_MC, e_obs)$p_mc
        for (k in CLES) {
          L[[paste0("obs:", k)]] <- unname(obs[[k]]); L[[paste0("p:", k)]] <- unname(bt$p_mc[[k]])
          L[[paste0("m:", k)]] <- unname(code_motif(bt$motif_mc[[k]])); L[[paste0("pc:", k)]] <- unname(pc[[k]])
        }
        L$B_eff_min <- min(bt$B_effectif)
      }
      if (garder) objets <- list(tri = tri, bt = bt, s = s)
    } else if (garder) objets <- list(tri = tri, bt = NULL, s = s)
    if (length(s) <= MIN_SIGMA) return(fin("sans_intervalle"))
    L$moy_sigma_star <- mean(s); L$rang <- mean(s < sh)
    b <- bornes_intervalles(s, sh)
    for (nm in NOMS_BORNES) L[[nm]] <- b[[nm]]
    L$ecart_ind <- ecart_relatif_max(b, bornes_independantes(s, sh))
    fin("ok")
  }, error = function(e) fin("echec_autre", "-", nettoyer_champ(conditionMessage(e))))
}
# Triangle k de l'oracle de P4 (P8) : generateur de P4, admission, puis
# statistiques par le chemin de l'oracle (stats_oracle()).
un_oracle <- function(k, graine = graine_ora(k)) {
  t1 <- proc.time()[["elapsed"]]
  L <- stats::setNames(as.list(rep(NA, length(COLONNES_ORA))), COLONNES_ORA)
  L$k <- k; L$g_tri <- graine; L$motif_code <- "-"
  ad <- admettre(triangle_profil(4L, graine))
  if (!ad$ok) { L$statut <- "refus"; L$motif_code <- ad$code } else {
    so <- tryCatch(stats_oracle(ad$aj), error = function(e) NULL)
    L$statut <- if (is.null(so)) "echec_stats" else "admis"
    if (!is.null(so)) for (s in CLES) L[[paste0("obs:", s)]] <- unname(so[[s]])
  }
  L$duree_s <- proc.time()[["elapsed"]] - t1
  L
}

# --- Ecriture et lecture des lignes ------------------------------------------
format_val <- function(v, col, texte) {
  if (col %in% texte) return(if (is.null(v) || is.na(v)) "NA" else gsub("[\t\r\n]+", " ", as.character(v)))
  if (is.null(v) || is.na(v)) "NA" else sprintf("%.17g", as.numeric(v))
}
format_ligne <- function(L, cols = COLONNES, texte = COL_TEXTE)
  paste(vapply(cols, function(c) format_val(L[[c]], c, texte), ""), collapse = "\t")
lire_lignes <- function(lignes, cols = COLONNES, texte = COL_TEXTE) {
  if (!length(lignes)) return(NULL)
  m <- do.call(rbind, strsplit(lignes, "\t", fixed = TRUE))
  if (ncol(m) != length(cols)) stop("nombre de colonnes inattendu")
  df <- as.data.frame(m, stringsAsFactors = FALSE); names(df) <- cols
  for (c in setdiff(cols, texte)) df[[c]] <- suppressWarnings(as.numeric(df[[c]]))
  for (c in intersect(cols, texte)) df[[c]][df[[c]] == "NA"] <- NA_character_
  df
}

###############################################################################
#  MODE --prevol (P7, P10)
###############################################################################
if (MODE == "prevol") {
  U <- OPT_UNITES
  ecrire_console(c("## Pr\u00e9-vol de la mesure #387 (S5, \u00e9tape 4) -- rien d'\u00e9crit", "",
                   sprintf("Commit : %s ; md5 R/engine.R : %s ; plateforme : %s ; c\u0153urs (parallel::detectCores()) : %s ; d\u00e9but %s",
                           COMMIT_DEBUT, MD5_MOTEUR_DEBUT, PLATEFORME, COEURS, horodatage()), ""))
  # 1. Taux d'admission et cout d'admission (un processus) sur les graines du
  # pre-vol : P1 (200 triangles), P4 et P5 (1 000 triangles chacun).
  N_ADM <- c(P1 = 200L, P4 = 1000L, P5 = 1000L)
  ADM <- lapply(names(N_ADM), function(cd) {
    p <- match(cd, PROFILS$code); t0 <- Sys.time()
    codes <- vapply(seq_len(N_ADM[[cd]]), function(u) admettre(triangle_profil(p, graine_pv_tri(p, u)))$code, "")
    list(p = p, codes = codes, a = mean(codes == "-"), c_adm = secs(t0) / N_ADM[[cd]], u_adm = which(codes == "-"))
  })
  names(ADM) <- names(N_ADM)
  if (length(ADM$P1$u_adm) < U || length(ADM$P4$u_adm) < U || length(ADM$P5$u_adm) < U)
    stop("--prevol : moins de ", U, " triangles admis sur les graines du pr\u00e9-vol")
  # 2. run_engine() sur la fixture (un processus) : cout c_re.
  t0 <- Sys.time()
  invisible(run_engine(methode = "reserve2", triangle = TRI_FIXTURE, segment = 1, annexe = "II", date_reference = DATE_REFERENCE_TESTS))
  c_re <- secs(t0)
  # 3. Unite de debit (dans chaque processus, les memes U unites) : P1 allege,
  # P5 allege, P4 complet, P1 complet (controle 5), 25 triangles d'oracle.
  unite <- function(i) {
    out <- list()
    for (u in seq_len(U)) {
      u1 <- ADM$P1$u_adm[u]; u4 <- ADM$P4$u_adm[u]; u5 <- ADM$P5$u_adm[u]
      d <- c(l1 = un_triangle(1L, u1, B_MESURE, g_tri = graine_pv_tri(1L, u1), g_boot = graine_pv_boot(1L, u1))$duree_s,
             l5 = un_triangle(5L, u5, B_MESURE, g_tri = graine_pv_tri(5L, u5), g_boot = graine_pv_boot(5L, u5))$duree_s,
             c4 = un_triangle(4L, u4, B_MESURE, complet = TRUE, g_tri = graine_pv_tri(4L, u4), g_boot = graine_pv_boot(4L, u4))$duree_s,
             c1 = un_triangle(1L, u1, B_MESURE, complet = TRUE, g_tri = graine_pv_tri(1L, u1), g_boot = graine_pv_boot(1L, u1))$duree_s)
      t0 <- proc.time()[["elapsed"]]
      for (k in 2000L + 25L * (u - 1L) + seq_len(25L)) invisible(un_oracle(k, graine_pv_tri(4L, k)))
      d[["or"]] <- (proc.time()[["elapsed"]] - t0) / 25
      out[[u]] <- d
    }
    do.call(rbind, out)
  }
  KMAX <- max(1L, min(4L, COEURS, na.rm = TRUE))
  CB <- list(); MUR <- numeric(KMAX)
  for (k in seq_len(KMAX)) {
    t0 <- Sys.time()
    res <- parallel::mclapply(seq_len(k), unite, mc.cores = k, mc.preschedule = FALSE)
    MUR[k] <- secs(t0)
    if (any(vapply(res, function(x) !is.matrix(x), logical(1)))) stop("--prevol : processus en erreur (k = ", k, ")")
    CB[[k]] <- do.call(rbind, res)
  }
  tot <- function(m) m[, "l1"] + m[, "l5"] + m[, "c4"] + m[, "c1"] + 25 * m[, "or"]
  P_k <- vapply(seq_len(KMAX), function(k) k * mean(tot(CB[[1]])) / mean(tot(CB[[k]])), 1)
  c1 <- colMeans(CB[[1]])
  # Duree planifiee (s d'horloge) d'un niveau a k processus [H : debit lineaire
  # par triangle, queues de groupes non comptees] : partie sequentielle
  # (controles avant tirage : run_engine() sur la fixture, mw_bootstrap() a
  # B = 199 sur la fixture, deux bootstraps du controle 9) + partie parallele
  # (triangles des profils, oracle, premier triangle admis de chaque tranche
  # des profils allegees, controle 7) divisee par le debit P_k.
  cpu_triangle <- function(cd) {
    a <- ADM[[cd]]$a; ca <- ADM[[cd]]$c_adm
    switch(cd, P1 = (1 - a) * ca + a * c1[["l1"]], P5 = (1 - a) * ca + a * c1[["l5"]], P4 = (1 - a) * ca + a * c1[["c4"]])
  }
  duree_plan <- function(Rv, k) {
    a1 <- cpu_triangle("P1")
    n_ctl5 <- sum(ceiling(Rv[c("P1", "P2", "P3", "P5")] / TAILLE_TRANCHE))
    par <- (Rv[["P1"]] + Rv[["P2"]] + Rv[["P3"]]) * a1 + Rv[["P5"]] * cpu_triangle("P5") + Rv[["P4"]] * cpu_triangle("P4") +
      Rv[["OR"]] * c1[["or"]] + n_ctl5 * max(0, c1[["c1"]] - c1[["l1"]]) + 5 * (c1[["c4"]] + c_re) + 2 * (c1[["c1"]] + c_re)
    seq_ <- c_re + 0.25 * c1[["c4"]] + 2 * c1[["c1"]]
    seq_ + par / P_k[k]
  }
  k_plan <- min(K_BUDGET, KMAX)
  plan <- vapply(names(NIVEAUX), function(l) duree_plan(NIVEAUX[[l]], k_plan), 1)
  tient <- plan <= BUDGET_S
  niveau <- if (any(tient)) names(NIVEAUX)[which(tient)[1]] else NA_character_
  f2 <- function(m, cc) sprintf("%s [%s ; %s]", num(mean(m[, cc]), 2), num(min(m[, cc]), 2), num(max(m[, cc]), 2))
  ecrire_console(c("### Admission sur les graines du pr\u00e9-vol (un processus)", "",
                   entete_md(c("Profil", "triangles tir\u00e9s", "admis", "taux d'admission", "motifs de refus", "s par triangle (admission)")),
                   vapply(names(ADM), function(cd) {
                     x <- ADM[[cd]]; t <- table(x$codes[x$codes != "-"])
                     ligne_md(cd, length(x$codes), sum(x$codes == "-"), num(x$a, 3),
                              if (length(t)) paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") else "aucun", num(x$c_adm, 4))
                   }, ""), "",
                   sprintf("run_engine() sur la fixture (B = 999, un processus) : %s s.", num(c_re, 2)), "",
                   "### Co\u00fbts unitaires (secondes, dur\u00e9e murale dans chaque processus)", "",
                   sprintf("Unit\u00e9 : P1 all\u00e9g\u00e9, P5 all\u00e9g\u00e9, P4 complet (mw_bootstrap() + boucle all\u00e9g\u00e9e), P1 complet (contr\u00f4le 5), 25 triangles d'oracle ; %d unit\u00e9(s) par processus, les m\u00eames dans chaque processus.", U), "",
                   entete_md(c("processus concurrents", "dur\u00e9e murale de la phase (s)", "P1 all\u00e9g\u00e9", "P5 all\u00e9g\u00e9", "P4 complet",
                               "P1 complet", "oracle (par triangle tir\u00e9)", "d\u00e9bit agr\u00e9g\u00e9 P_k")),
                   vapply(seq_len(KMAX), function(k) ligne_md(k, num(MUR[k], 1), f2(CB[[k]], "l1"), f2(CB[[k]], "l5"), f2(CB[[k]], "c4"),
                                                              f2(CB[[k]], "c1"), f2(CB[[k]], "or"), num(P_k[k], 3)), ""), "",
                   sprintf("### Niveaux (P7 : premier niveau dont la dur\u00e9e planifi\u00e9e tient dans 3 h d'horloge sur %d processus ; sous L2, retour au mainteneur)", K_BUDGET), "",
                   entete_md(c("Niveau", "P1", "P2", "P3", "P4 (tir\u00e9s)", "P5", "oracle (tir\u00e9s)", sprintf("dur\u00e9e planifi\u00e9e \u00e0 %d processus (h)", k_plan), "dans le budget")),
                   vapply(names(NIVEAUX), function(l) { R_ <- NIVEAUX[[l]]
                     ligne_md(l, R_[["P1"]], R_[["P2"]], R_[["P3"]], R_[["P4"]], R_[["P5"]], R_[["OR"]], num(plan[[l]] / 3600, 2),
                              if (tient[[l]]) "oui" else "non") }, ""), "",
                   if (k_plan < K_BUDGET) sprintf("**Moins de %d c\u0153urs : dur\u00e9e planifi\u00e9e \u00e0 %d processus seulement.**", K_BUDGET, k_plan) else character(0),
                   if (!is.na(niveau))
                     sprintf("**Niveau retenu : %s, dur\u00e9e planifi\u00e9e %s h \u00e0 %d processus** (hypoth\u00e8se [H] : d\u00e9bit lin\u00e9aire par triangle, queues de groupes non compt\u00e9es ; la charge de la machine n'est pas contr\u00f4l\u00e9e).",
                             niveau, num(plan[[niveau]] / 3600, 2), k_plan)
                   else "**Aucun niveau ne tient dans 3 h, y compris L2 : retour au mainteneur (Q-1b-8).**",
                   "", sprintf("Commande de la mesure (arbre propre, #492 commit\u00e9e) : LC_ALL=C.UTF-8 Rscript %s --niveau %s --processus %d --ecrire",
                               SCRIPT_DEPOT, if (is.na(niveau)) "?" else niveau, k_plan),
                   "", sprintf("PREVOL387\t%s\t%s\t%s\t%s\t%s\t%s", paste(sprintf("%.4f", c1), collapse = "\t"),
                               paste(sprintf("%.4f", P_k), collapse = "\t"), paste(sprintf("%.3f", vapply(ADM, function(x) x$a, 1)), collapse = "\t"),
                               sprintf("%.3f", c_re), paste(sprintf("%.0f", plan), collapse = "\t"), if (is.na(niveau)) "NA" else niveau),
                   sprintf("Dur\u00e9e du pr\u00e9-vol : %s s.", num(secs(t_debut), 0))))
  quit(status = 0L)
}

###############################################################################
#  ESSAI ET MESURE : PARAMETRES, GARDES DE --ecrire, JOURNAL (avant tout
#  calcul couteux, #205)
###############################################################################
B_RUN <- if (OPT_ESSAI) B_ESSAI else B_MESURE
lire_R <- function(txt) {
  if (grepl("^[0-9]+$", txt)) { n <- as.integer(txt); return(c(P1 = n, P2 = n, P3 = n, P4 = n, P5 = n, OR = 10L * n)) }
  v <- suppressWarnings(as.integer(strsplit(txt, ",", fixed = TRUE)[[1]]))
  if (length(v) != 6L || anyNA(v)) refuser("--R : un entier, ou six entiers P1,P2,P3,P4,P5,oracle separes par des virgules")
  stats::setNames(v, NOMS_R)
}
R_RUN <- if (!is.na(OPT_R_TXT)) lire_R(OPT_R_TXT) else if (!is.na(OPT_NIVEAU)) {
  if (!OPT_NIVEAU %in% names(NIVEAUX)) refuser("--niveau : L0, L1 ou L2")
  NIVEAUX[[OPT_NIVEAU]]
} else R_ESSAI
if (!is.na(OPT_NIVEAU)) {
  if (!OPT_NIVEAU %in% names(NIVEAUX)) refuser("--niveau : L0, L1 ou L2")
  if (!identical(unname(NIVEAUX[[OPT_NIVEAU]]), unname(R_RUN))) refuser("--niveau ", OPT_NIVEAU, " : R different de --R")
}
if (any(R_RUN < 0L) || any(R_RUN > R_MAX) || sum(R_RUN[1:5]) < 1L) refuser("--R : entiers de 0 a ", R_MAX, ", au moins un triangle")
txt_R <- function(R_) paste(sprintf("%s=%d", names(R_), R_), collapse = ",")
if (OPT_ECRIRE) {
  nv <- motifs_non_versionnable(COMMIT_DEBUT, EMPREINTES, "de la mesure")
  if (length(nv)) refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
                          " -- lancer depuis un arbre au commit propre")
  if (!dir.exists(file.path(RACINE, "docs", "tableaux"))) refuser("dossier de sortie introuvable : docs/tableaux")
}
SUFFIXE <- if (!is.na(OPT_NIVEAU)) OPT_NIVEAU else paste0("R", paste(R_RUN, collapse = "-"))
TRAVAIL <- if (!is.na(OPT_TRAVAIL)) OPT_TRAVAIL else if (OPT_ESSAI) tempfile("essai387_", tmpdir = dirname(tempdir())) else
  file.path(dirname(normalizePath(RACINE, winslash = "/")), sprintf("issue387-travail-%s", SUFFIXE))
if (sous_depot(TRAVAIL)) refuser("--travail : dossier sous le depot refuse")
if (!dir.exists(TRAVAIL)) dir.create(TRAVAIL, recursive = TRUE)
TRAVAIL <- normalizePath(TRAVAIL, winslash = "/")
JOURNAL_T <- file.path(TRAVAIL, "JOURNAL.md")
CTX <- c(B = B_RUN, sha = SHA_DEBUT, md5_moteur = MD5_MOTEUR_DEBUT, md5_script = MD5_SCRIPT, empreinte = EMPREINTE_DEBUT,
         plateforme = PLATEFORME, essai = if (OPT_ESSAI) "oui" else "non", taille_tranche = TAILLE_TRANCHE)
txt_ctx <- function(ctx) paste(names(ctx), ctx, sep = "=", collapse = " || ")
lire_journal <- function() {
  jl <- readLines(JOURNAL_T, warn = FALSE, encoding = "UTF-8")
  champ <- function(cle) {
    m <- regmatches(jl, regexec(paste0("^- ", cle, " : (.*)$"), jl))
    v <- vapply(m[lengths(m) == 2L], `[`, "", 2L)
    if (length(v)) v[1] else NA_character_
  }
  list(lignes = jl, R = champ("R par profil"), sha = champ("SHA \\(git rev-parse HEAD\\) au lancement"),
       md5 = champ("md5 R/engine\\.R au lancement"), date = champ("Date des sorties"),
       ctx = champ("Contexte des tranches"), lancement = champ("Lancement"),
       empreinte = champ("Empreinte sans commentaires de R/engine\\.R"))
}
if (!file.exists(JOURNAL_T)) {
  ecrire_fichier(JOURNAL_T, c(
    sprintf("# JOURNAL de la mesure #387 (S5, \u00e9tape 4 : couverture \u00e0 T = 8 de l'intervalle bootstrap de \u03c3, Merz-W\u00fcthrich)%s",
            if (OPT_ESSAI) " -- ESSAI, non versionnable" else ""), "",
    sprintf("- Lancement : %s", horodatage()),
    sprintf("- Date des sorties : %s", format(Sys.time(), "%Y%m%d", tz = "UTC")),
    sprintf("- R par profil : %s", txt_R(R_RUN)),
    sprintf("- Niveau : %s", if (is.na(OPT_NIVEAU)) "non d\u00e9clar\u00e9 (--niveau absent)" else sprintf("%s (pr\u00e9-vol, P7)", OPT_NIVEAU)),
    sprintf("- B : %s", format(B_RUN)),
    sprintf("- Processus : %d ; taille des tranches : %d", OPT_PROC, TAILLE_TRANCHE),
    sprintf("- SHA (git rev-parse HEAD) au lancement : %s", SHA_DEBUT),
    sprintf("- Commit (commit_depot()) : %s", COMMIT_DEBUT),
    sprintf("- md5 R/engine.R au lancement : %s", MD5_MOTEUR_DEBUT),
    sprintf("- Empreinte sans commentaires de R/engine.R : %s", EMPREINTE_DEBUT),
    sprintf("- Empreintes md5 du code ex\u00e9cut\u00e9 : %s", EMPREINTES),
    sprintf("- md5 protocole (%s) : %s", PROTOCOLE, md5_fichier(file.path(RACINE, PROTOCOLE))),
    sprintf("- Plateforme : %s", PLATEFORME),
    sprintf("- Locale : LC_ALL=%s ; LC_CTYPE=%s", Sys.getenv("LC_ALL"), LOCALE_TRAVAIL),
    sprintf("- Dossier de travail : %s (hors du d\u00e9p\u00f4t)", basename(TRAVAIL)),
    sprintf("- Commande : Rscript %s %s", SCRIPT_DEPOT, args_cites()),
    sprintf("- Contexte des tranches : %s", txt_ctx(CTX))))
} else {
  J0 <- lire_journal()
  if (!identical(J0$R, txt_R(R_RUN))) refuser("reprise : R du JOURNAL (", J0$R, ") different de ", txt_R(R_RUN))
  if (!identical(J0$ctx, txt_ctx(CTX))) refuser("reprise : contexte du JOURNAL different du contexte courant -- autre --travail")
  ecrire_fichier(JOURNAL_T, sprintf("- Reprise : %s ; commande : Rscript %s %s", horodatage(), SCRIPT_DEPOT, args_cites()), mode = "ab")
}
J0 <- lire_journal()
DATE_SORTIES <- J0$date
NOM_MD  <- sprintf("%s-issue387-couverture-ic-sigma-mw.md", DATE_SORTIES)
NOM_TSV <- sprintf("%s-issue387-couverture-ic-sigma-mw-brut.tsv", DATE_SORTIES)
NOM_JNL <- sprintf("%s-issue387-journal-mesure.md", DATE_SORTIES)
CIBLES <- file.path(RACINE, "docs", "tableaux", c(NOM_MD, NOM_TSV, NOM_JNL))
REMPLACES <- NULL
if (OPT_ECRIRE) REMPLACES <- garde_ecrasement(CIBLES, remplacer = OPT_REMPLACER)

###############################################################################
#  CONTROLES AVANT TOUT TIRAGE DU PLAN : 11, "fixture", 2, 3, 6, 8 (fixture),
#  9, 10, 12, 13 et 14 (generateurs, fixture)
###############################################################################
INTEGRITE <- character(0)
CTRL <- list()
controle <- function(code, ok, detail) {
  CTRL[[length(CTRL) + 1L]] <<- list(code = code, ok = isTRUE(ok), detail = detail)
  if (!isTRUE(ok)) INTEGRITE <<- c(INTEGRITE, code)
}
# Controle 11 (t387) : par. 3 (critere et profils) et par. 1 (statut) du
# rapport verse, presents a l'identique (copies ci-dessous).
TEXTE_CRITERE_387 <- c(
  "## 3. Crit\u00e8re et profils, fix\u00e9s avant toute ex\u00e9cution (point 6 du brief ; \u00e0 reporter sans modification dans le script et au T0)",
  "",
  "> **Crit\u00e8re.** Taux de non-couverture \u03c4 de chaque (profil, intervalle, niveau), cible \u03c3_A, compar\u00e9 au nominal \u03c1 = 0,10 (90 %) ou 0,05 (95 %). Classes de #166, #206, Fk et #305, bande **ferm\u00e9e** [\u03c1/2 ; 3\u03c1/2] : *compatible* (\u03c1 \u2208 IC(\u03c4)) ; *\u00e9cart mineur* (\u03c4\u0302 dans la bande, sans \u00eatre compatible) ; *non tranch\u00e9* (\u03c4\u0302 hors de la bande, IC qui la recoupe) ; *distorsion mat\u00e9rielle lib\u00e9rale* (IC disjoint de la bande, au-dessus) ; *distorsion mat\u00e9rielle conservatrice* (IC disjoint, au-dessous). IC de Clopper-Pearson \u00e0 95 % ; classes sur les valeurs non arrondies ; une estimation sur un bord est dans la bande ; **aucune extension de R apr\u00e8s lecture** ; un \u00ab non tranch\u00e9 \u00bb reste non tranch\u00e9.",
  "> - **K-M1** (principal) : classe \u00e0 90 % de I1, I2 et I4 sur P1 et P2.",
  "> - **K-M2** (secondaire, port\u00e9e conditionnelle) : classe \u00e0 90 % de I1, I2 et I4 sur les triangles admis de P4.",
  "> - **K-M3** (descriptif) : 95 % ; queues s\u00e9par\u00e9es contre \u03c1/2 ; cible \u03c3_B ; P3 et P5 ; couverture de P4 et P5 par strate de \u03c0\u0302 = `n_sans_sigma`/B (0 ; ]0 ; 0,05] ; ]0,05 ; 0,20] ; > 0,20) ; largeurs (m\u00e9diane et quantiles divis\u00e9s par \u03c3_A ; pas de moyenne sur P4 et P5) ; bornes basses \u2264 0 de I2 ; bornes hautes infinies de I4 ; biais (m\u00e9diane de \u03c3\u0302/\u03c3_A ; moyenne de \u03c3\u0302/moyenne(\u03c3\\*) sur P1 \u00e0 P3 seulement ; m\u00e9diane du rang de \u03c3\u0302 dans \u03c3\\*).",
  "> - **K-M4** (int\u00e9grit\u00e9) : contr\u00f4les 1 \u00e0 14 de P11.",
  "> - **K-M5** (fronti\u00e8re, descriptif) : l'IC touche-t-il un bord de la bande.",
  ">",
  "> **Profils de lecture pour D2** (`actuary` propose, le mainteneur tranche ; ordre : \u03a90, \u03a94, \u03a91 \u00e0 \u03a93, puis modificateur V) :",
  ">",
  "> | Profil | Condition | Lecture propos\u00e9e |",
  "> |---|---|---|",
  "> | \u03a90 | K-M4 en d\u00e9faut ; ou, sur P1 ou P2, refus ou triangles sans intervalle au-del\u00e0 de 1 % ; ou, sur P4, refus d'un autre motif que M4 au-del\u00e0 de 1 % | lecture suspendue ; mesure \u00e0 reprendre |",
  "> | \u03a94 | I1 en distorsion de c\u00f4t\u00e9s oppos\u00e9s entre P1 et P2 | d\u00e9cision du mainteneur ; aucune extension |",
  "> | \u03a91 | I1 compatible ou en \u00e9cart mineur sur P1 et P2 | percentile conserv\u00e9 ; couverture \u00e9crite ; \u00ab basic \u00bb non \u00e9tendu par d\u00e9faut |",
  "> | \u03a92 | I1 ni compatible ni en \u00e9cart mineur sur au moins un des deux profils, et I4 compatible ou en \u00e9cart mineur sur P1 et P2 | **d\u00e9cision du mainteneur** : extension de I4 \u00e0 Merz-W\u00fcthrich en regard du percentile, jamais \u00e0 sa place (Q-42-10) ; note requalifi\u00e9e comme en lognormale |",
  "> | \u03a92\u2032 | m\u00eame cas pour I1, I4 non retenu, mais I2 compatible ou en \u00e9cart mineur sur P1 et P2 | d\u00e9cision du mainteneur ; I2 n'\u00e9tant pas restitu\u00e9 en lognormale (Q-D2-Fn-2), aucune restitution sans d\u00e9cision expresse |",
  "> | \u03a93 | I1 dans ce m\u00eame cas, et ni I2 ni I4 compatible ou en \u00e9cart mineur sur P1 et P2 | aucun \u00ab basic \u00bb ; note requalifi\u00e9e (percentile sous le nominal) ; issue propos\u00e9e pour un autre intervalle |",
  ">",
  "> **Modificateur V (K-M2)**, sous \u03a91 ou \u03a92, pour l'intervalle ou les intervalles retenus (I1, plus I4 sous \u03a92). V-a : compatible ou en \u00e9cart mineur sur P4, aucune limite de plus que la phrase conditionnelle de #492. V-b : non tranch\u00e9 ou en distorsion sur P4 : l'extension n'est pas remise en cause, mais la limite est \u00e9crite (note quand `n_sans_sigma` > 0, et fiche) avec la couverture par strate de \u03c0\u0302 ; le mainteneur d\u00e9cide s'il rouvre l'option (b) de 1a (seuil de retrait) au vu des strates. Aucun seuil n'est pos\u00e9 par d\u00e9faut.",
  ">",
  "> **Volet A.5 (ii)** (P4, triangles admis). **K-V1** : classe de #206 de \u03c4 contre \u03c1 (oracle conditionnel) pour chaque cl\u00e9 et chaque \u03b1. **K-V2** : McNemar exact entre la p du moteur et la p conditionnelle, Holm sur 13 par \u03b1. **K-V3** : t\u00e9moin, r\u00e8gle b\u00eata-binomiale du 05/11/2026. **K-V4** : p absentes au plus 1 % ; distribution de \u03c0\u0302. Profils : **\u039b0**, K-V3 non expliqu\u00e9 ou K-V4 en d\u00e9faut : lecture suspendue ; **\u039b1**, 13 cl\u00e9s compatibles ou en \u00e9cart mineur aux deux seuils et aucun McNemar significatif : limite (i) de 1a \u00e9crite comme \u00ab niveau mesur\u00e9 sur un profil volatil, sans distorsion \u00bb ; **\u039b2**, aucune distorsion mat\u00e9rielle, des non tranch\u00e9s, aucun McNemar significatif : constat avec ses IC ; **\u039b3**, une distorsion mat\u00e9rielle ou un McNemar significatif : limite \u00e9crite et issue propos\u00e9e (p conditionnelle, hors S5), sans changer aucune p ni aucun verdict dans S5.")
TEXTE_STATUT_387 <- c(
  "## 1. Statut \u00e9pist\u00e9mique (\u00e0 \u00e9crire tel quel en t\u00eate de la sortie)",
  "",
  "La couverture mesur\u00e9e est un **constat de simulation**, sous trois conditions : le mod\u00e8le de Mack ajust\u00e9 \u00e0 un triangle g\u00e9n\u00e9rateur (f\u0302, \u03c3\u0302\u00b2 extrapol\u00e9 compris, premi\u00e8re colonne fix\u00e9e), une loi d'erreurs donn\u00e9e, et T = 8. Elle porte sur la proc\u00e9dure du moteur \u00e0 B = 999, conditionnellement \u00e0 l'admission du triangle (M4) et \u00e0 R* > 0 dans le bootstrap.",
  "",
  "Ce n'est pas un r\u00e9sultat g\u00e9n\u00e9ral. Aucun th\u00e9or\u00e8me ne couvre ces intervalles \u00e0 triangle fixe (I = 7). Les ordres de pr\u00e9cision asymptotiques de Davison et Hinkley (1997, \u00a7 5.2-5.3 ; relev\u00e9 R27.2 du d\u00e9p\u00f4t) ne fondent rien \u00e0 T = 8. Aucune source relue par le d\u00e9p\u00f4t ne chiffre cette couverture \u00e0 n = 8 (sp\u00e9cification D1-Fn, \u00a7 6). Je n'ai pas fait de recherche bibliographique nouvelle : la mesure est la seule preuve vis\u00e9e.",
  "",
  "Erreurs \u00e0 distinguer :",
  "- l'erreur Monte-Carlo en N, encadr\u00e9e par l'intervalle de Clopper-Pearson ;",
  "- l'effet de B, inclus dans la proc\u00e9dure mesur\u00e9e et non isol\u00e9 ;",
  "- l'\u00e9cart au niveau nominal, qui est l'objet mesur\u00e9 (erreur \u00e0 T = 8) ;",
  "- l'erreur de substitution (plan et loi au lieu de la v\u00e9rit\u00e9), non quantifi\u00e9e.")
present_bloc <- function(bloc, txt) {
  i <- which(txt == bloc[1])
  any(vapply(i, function(k) k + length(bloc) - 1L <= length(txt) && identical(txt[k:(k + length(bloc) - 1L)], bloc), logical(1)))
}
T387 <- local({
  f <- file.path(RACINE, PROTOCOLE)
  txt <- if (file.exists(f)) readLines(f, warn = FALSE, encoding = "UTF-8") else character(0)
  c(critere = present_bloc(TEXTE_CRITERE_387, txt), statut = present_bloc(TEXTE_STATUT_387, txt))
})
if (!all(T387))
  refuser("(t387) : par. 3 ou par. 1 absent ou modifie dans ", PROTOCOLE, " -- le critere reporte dans le script ne concorde plus avec le rapport verse")
controle("11 (t387)", all(T387), sprintf("par. 3 (crit\u00e8re et profils, %d lignes) %s ; par. 1 (statut \u00e9pist\u00e9mique) %s, dans %s (md5 %s) ; v\u00e9rifi\u00e9 avant la boucle de calcul",
                                          length(TEXTE_CRITERE_387), if (T387[["critere"]]) "pr\u00e9sent \u00e0 l'identique" else "ABSENT OU MODIFI\u00c9",
                                          if (T387[["statut"]]) "pr\u00e9sent \u00e0 l'identique" else "ABSENT OU MODIFI\u00c9", PROTOCOLE, md5_fichier(file.path(RACINE, PROTOCOLE))))
# Fixture : fichier versionne par #492 contre le dput de A.0.
controle("fixture", !FIXTURE_FICHIER_PRESENT || identical(FIXTURE_LUE, FIXTURE_DPUT),
         if (FIXTURE_FICHIER_PRESENT) sprintf("%s pr\u00e9sent (md5 %s) ; identique au dput de A.0 (identical()) : %s ; g\u00e9n\u00e9rateur de P4 et P5 lu dans le fichier",
                                              FICHIER_FIXTURE, md5_fichier(file.path(RACINE, FICHIER_FIXTURE)), if (identical(FIXTURE_LUE, FIXTURE_DPUT)) "oui" else "NON")
         else sprintf("%s absent : g\u00e9n\u00e9rateur de P4 et P5 lu dans le dput de A.0 embarqu\u00e9 (FIXTURE_DPUT) ; \u00e9galit\u00e9 \u00e0 v\u00e9rifier quand #492 versionne le fichier", FICHIER_FIXTURE))
# Point observe de la fixture (controles 2, 3, 8, 14).
t_re <- Sys.time()
RES_FX <- run_engine(methode = "reserve2", triangle = TRI_FIXTURE, segment = 1, annexe = "II", date_reference = DATE_REFERENCE_TESTS)
DUREE_RE <- secs(t_re)
REF_R2 <- readRDS(chemin_reference("reserve2"))
# Controle 2 : sigma_A.
local({
  e1 <- abs(SIGMA_A[["P1"]] - REF_R2$parametre_final$sigma_estime) / abs(REF_R2$parametre_final$sigma_estime)
  e4 <- if (isTRUE(RES_FX$ok)) abs(SIGMA_A[["P4"]] - RES_FX$parametre_final$sigma_estime) / abs(RES_FX$parametre_final$sigma_estime) else NA_real_
  controle("2", is.finite(e1) && e1 <= TOLERANCE && is.finite(e4) && e4 <= TOLERANCE,
           sprintf("\u03c3_A de P1 \u00e0 P3 = %.10g ; reserve2.rds : parametre_final$sigma_estime = %.10g (\u00e9cart relatif %.3e) ; \u03c3_A de P4 et P5 = %.10g ; run_engine() sur la fixture : %s (\u00e9cart relatif %.3e) ; TOLERANCE %g",
                   SIGMA_A[["P1"]], REF_R2$parametre_final$sigma_estime, e1, SIGMA_A[["P4"]],
                   if (isTRUE(RES_FX$ok)) sprintf("%.10g", RES_FX$parametre_final$sigma_estime) else "ok = FALSE", e4, TOLERANCE))
})
# Controle 3 : percentile du script sur l'echelle de sigma_USP.
local({
  pf <- REF_R2$parametre_final
  par_ok <- identical(CRED, pf$credibilite) && identical(SIGMA_STD, pf$sigma_standard)
  a <- identical(ic_script(REF_R2$bootstrap$sigma_boot), unname(as.numeric(REF_R2$ic_bootstrap)))
  b <- isTRUE(RES_FX$ok) && identical(ic_script(RES_FX$bootstrap$sigma_boot), unname(as.numeric(RES_FX$ic_bootstrap))) &&
    identical(CRED, RES_FX$parametre_final$credibilite) && identical(SIGMA_STD, RES_FX$parametre_final$sigma_standard)
  controle("3", par_ok && a && b,
           sprintf("c = %s, \u03c3 standard = %s (usp_credibilite(8, \"%s\"), usp_parametre_standard()) identiques \u00e0 reserve2.rds : %s ; c \u03c3* + (1 \u2212 c) \u03c3 standard, quantiles de type 7 (%s) : reserve2.rds %s ; fixture (run_engine()) %s",
                   format(CRED), format(SIGMA_STD), BAREME, if (par_ok) "oui" else "NON", paste(PROBS_IC, collapse = ", "),
                   if (a) "identical" else "DIFF\u00c9RENT", if (b) "identical" else "DIFF\u00c9RENT"))
})
# Controle 6 (g) : generateur identique a mw_simuler_triangle() (100 graines
# par generateur : triangles r = 1..100 de P1 pour reserve2, de P4 pour la
# fixture), pool non dilate puis dilate (#271 : premier facteur qui rend au
# moins un triangle a cumul simule non fini ou <= 0, exige) ; fonctions du
# moteur identiques a celles de R/engine.R relu.
FACTEURS_G <- c(1, 30, 100, 300, 1000)
local({
  det <- character(0); tout <- TRUE
  for (gn in c("reserve2", "fixture")) {
    g <- GEN[[gn]]; p <- if (gn == "reserve2") 1L else 4L
    meme_g <- function(pool) vapply(seq_len(100), function(i) {
      gr <- graine_tri(p, i)
      a <- engine_sous_graine(gr, gen_triangle_h0(g$aj, function(n) sample(pool, n, replace = TRUE)))
      b <- engine_sous_graine(gr, mw_simuler_triangle(g$aj, pool))
      c(identique = identical(a, b), incomplet = .mw_triangle_incomplet(b))
    }, logical(2))
    base <- meme_g(g$pool)["identique", ]
    for (fd in FACTEURS_G[-1]) { dil <- meme_g(fd * g$pool); if (any(dil["incomplet", ])) break }
    ok <- all(base) && all(dil["identique", ]) && any(dil["incomplet", ])
    tout <- tout && ok
    det <- c(det, sprintf("%s : %d / 100 identiques ; pool dilat\u00e9 %g fois : %d / 100 identiques, dont %d triangle(s) \u00e0 cumul simul\u00e9 non fini ou \u2264 0",
                          gn, sum(base), fd, sum(dil["identique", ]), sum(dil["incomplet", ])))
  }
  e0 <- new.env()
  sys.source(file.path(RACINE, "R", "engine.R"), envir = e0, keep.source = FALSE)
  env_m <- environment(mw_bootstrap)
  meme <- function(nm) { a <- get(nm, envir = env_m); b <- get(nm, envir = e0)
    identical(formals(a), formals(b)) && identical(body(a), body(b)) }
  fns <- c("mw_simuler_triangle", ".mw_simuler_triangle_etat", ".mw_tirer_triangle_valide", ".mw_triangle_incomplet",
           ".mw_pool_residus", "mw_bootstrap", "mw_ajuster", "mw_msep")
  ok_fns <- all(vapply(fns, meme, logical(1)))
  controle("6 (g)", tout && ok_fns, sprintf("gen_triangle_h0() (\u03b5 tir\u00e9s par sample(pool)) = mw_simuler_triangle() sous la m\u00eame graine (identical()) : %s ; %s de l'environnement identiques (formals, body) \u00e0 celles de R/engine.R relu : %s",
                                           paste(det, collapse = " ; "), paste(fns, collapse = ", "), if (ok_fns) "oui" else "NON"))
})
# Controle 8 (fixture) : n_sans_sigma a B = 199 et 999, graine par defaut.
local({
  aj <- GEN$fixture$aj; fg <- .mw_ensembles_figes(aj)
  det <- character(0); tout <- isTRUE(RES_FX$ok)
  for (Bf in c(199, 999)) {
    bt <- if (Bf == 999) RES_FX$bootstrap else mw_bootstrap(aj, B = Bf, seed = SEED_DEFAUT, figes = fg)
    lg <- boucle_allegee(aj, Bf, SEED_DEFAUT, fg)
    lig <- rowSums(is.finite(bt$stats_boot)) > 0
    nss_m <- sum(lig & !is.finite(lg$sig)); nss_l <- sum(lg$ajuste) - sum(is.finite(lg$sig))
    champ <- bt$n_sans_sigma
    attendu <- NSS_FIXTURE[[as.character(Bf)]]
    ok <- nss_m == attendu && nss_l == attendu && nss_m == sum(lig) - length(bt$sigma_boot) &&
      identical(lg$sig[is.finite(lg$sig)], bt$sigma_boot) && (is.null(champ) || isTRUE(champ == nss_m))
    tout <- tout && ok
    det <- c(det, sprintf("B = %d : masque %d, boucle all\u00e9g\u00e9e %d, lignes calcul\u00e9es \u2212 length(sigma_boot) = %d, attendu %d (1a) ; champ bootstrap$n_sans_sigma : %s",
                          Bf, nss_m, nss_l, sum(lig) - length(bt$sigma_boot), attendu,
                          if (is.null(champ)) "absent du moteur (#492 non int\u00e9gr\u00e9e) : comparaison au champ non faite (P5 (iii))" else sprintf("%s (%s)", format(champ), if (isTRUE(champ == nss_m)) "\u00e9gal" else "DIFF\u00c9RENT")))
  }
  CTRL8_FIXTURE <<- list(ok = tout, txt = paste(det, collapse = " ; "))
})
# Controle 9 : p_mc des lignes E b = 1 et 2 du brut de #297, sous les graines de
# #206 (forme de 1c, tests/double_bootstrap_mw.R, controle (r2)).
local({
  f <- file.path(RACINE, BRUT_297)
  if (!file.exists(f)) { controle("9", FALSE, sprintf("%s introuvable", BRUT_297)); return(invisible()) }
  br <- utils::read.delim(f, colClasses = "character", check.names = FALSE, quote = "", comment.char = "", stringsAsFactors = FALSE)
  E <- br[br$type == "rep" & br$loi == "E", , drop = FALSE]
  g <- GEN$reserve2; tE <- function(n) sample(g$pool_E, n, replace = TRUE)
  det <- character(0); tout <- TRUE
  for (b in 1:2) {
    tri <- engine_sous_graine(PLAGE_C9_TRI[1] - 1 + b, gen_triangle_h0(g$aj, tE))
    ad <- admettre(tri)
    l <- E[as.integer(E$b) == b, , drop = FALSE]
    if (!ad$ok || nrow(l) != 1L || l$statut != "admis") { tout <- FALSE; det <- c(det, sprintf("b = %d : admission ou ligne du brut en d\u00e9faut", b)); next }
    bt <- mw_bootstrap(ad$aj, B = B_MESURE, seed = PLAGE_C9_BOOT[1] - 1 + b, figes = .mw_ensembles_figes(ad$aj))
    vb <- suppressWarnings(as.numeric(unlist(l[1, paste0("pR:", CLES)])))
    ok <- identical(unname(vb), unname(bt$p_mc[CLES]))
    tout <- tout && ok
    det <- c(det, sprintf("b = %d (graines %.0f et %.0f) : %d / %d p_mc identiques", b, PLAGE_C9_TRI[1] - 1 + b, PLAGE_C9_BOOT[1] - 1 + b,
                          sum(vb == bt$p_mc[CLES], na.rm = TRUE) + sum(is.na(vb) & is.na(bt$p_mc[CLES])), NS))
  }
  controle("9", tout, sprintf("%s, lignes rep, loi E, colonnes pR:<cl\u00e9> : %s (identical())", BRUT_297, paste(det, collapse = " ; ")))
})
# Controle 10 : plages de graines disjointes (P6), et litteraux du depot.
PLAGES <- local({
  P <- list()
  for (p in seq_len(nrow(PROFILS))) {
    P[[sprintf("tri_%s", PROFILS$code[p])]] <- c(graine_tri(p, 1), graine_tri(p, R_MAX))
    P[[sprintf("boot_%s", PROFILS$code[p])]] <- c(graine_boot(p, 1), graine_boot(p, R_MAX))
  }
  P$oracle <- c(graine_ora(1), graine_ora(R_MAX))
  P$prevol <- c(graine_pv_tri(1, 1), graine_pv_boot(5, 10000))
  do.call(rbind, P)
})
local({
  M <- PLAGES; disj <- TRUE
  for (a in seq_len(nrow(M) - 1L)) for (b in (a + 1L):nrow(M))
    if (M[a, 1] <= M[b, 2] && M[b, 1] <= M[a, 2]) disj <- FALSE
  ext <- rbind(`#206/#297 MW` = PLAGE_EXT_206, `#297 LN` = PLAGE_EXT_297LN, `#305` = PLAGE_EXT_305)
  touche <- function(lo, hi) any(lo <= M[, 2] & hi >= M[, 1])
  ext_ok <- !any(vapply(seq_len(nrow(ext)), function(i) touche(ext[i, 1], ext[i, 2]), logical(1)))
  c9_hors <- !touche(min(PLAGE_C9_TRI), max(PLAGE_C9_BOOT))
  max_ok <- max(M) <= .Machine$integer.max
  fs <- c(file.path(RACINE, "R", "engine.R"), list.files(file.path(RACINE, "tests"), pattern = "\\.R$", full.names = TRUE),
          list.files(file.path(RACINE, "tests", "unitaires"), pattern = "\\.R$", full.names = TRUE))
  fs <- fs[basename(fs) != basename(SCRIPT_DEPOT)]
  lit <- sort(unique(unlist(lapply(fs, function(f) {
    l <- readLines(f, warn = FALSE)
    as.numeric(unlist(regmatches(l, gregexpr("(?<![0-9A-Za-z._])[0-9]{8,10}(?=L?(?![0-9A-Za-z._]))", l, perl = TRUE))))
  }))))
  coll <- lit[vapply(lit, function(v) touche(v, v + DECALAGE_LITTERAL), logical(1))]
  neuf <- lit[lit >= 1e8 & lit < 1e10]
  dessus <- lit[lit > max(M)]
  controle("10", disj && ext_ok && c9_hors && max_ok && !length(coll),
           sprintf(paste("plages de la mesure (triangles, bootstraps des 5 profils, oracle, pr\u00e9-vol) de %.0f \u00e0 %.0f, disjointes entre elles : %s ;",
                         "disjointes de #206/#297 MW %.0f-%.0f, #297 LN %.0f-%.0f, #305 %.0f-%.0f : %s ; graines du contr\u00f4le 9 hors des plages : %s ;",
                         "maximum \u2264 2^31 \u2212 1 : %s ; %d litt\u00e9raux entiers de 8 \u00e0 10 chiffres dans %d fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R ; \u00e9criture scientifique non recherch\u00e9e), dont %d \u00e0 9 ou 10 chiffres (%s) ;",
                         "litt\u00e9raux L dont [L ; L + %.0f] touche une plage : %s ; litt\u00e9raux au-dessus des plages : %s"),
                   min(M), max(M), if (disj) "oui" else "NON", PLAGE_EXT_206[1], PLAGE_EXT_206[2], PLAGE_EXT_297LN[1], PLAGE_EXT_297LN[2],
                   PLAGE_EXT_305[1], PLAGE_EXT_305[2], if (ext_ok) "oui" else "NON", if (c9_hors) "oui" else "NON", if (max_ok) "oui" else "NON",
                   length(lit), length(fs), length(neuf), if (length(neuf)) paste(sprintf("%.0f", neuf), collapse = ", ") else "aucun",
                   DECALAGE_LITTERAL, if (length(coll)) paste(sprintf("%.0f", coll), collapse = ", ") else "aucun",
                   if (length(dessus)) paste(sprintf("%.0f", dessus), collapse = ", ") else "aucun"))
})
# Controle 12 (m) : aucune occurrence du nom du script dans R/, app.R, .github/.
local({
  fs <- c(list.files(file.path(RACINE, "R"), recursive = TRUE, full.names = TRUE), file.path(RACINE, "app.R"),
          list.files(file.path(RACINE, ".github"), recursive = TRUE, full.names = TRUE, all.files = TRUE))
  fs <- fs[file.exists(fs) & !dir.exists(fs)]
  lit <- function(f) tryCatch(readLines(f, warn = FALSE, skipNul = TRUE), error = function(e) NA_character_)
  trouve <- fs[vapply(fs, function(f) { x <- lit(f); anyNA(x) || any(grepl("couverture_ic_sigma_mw", x, fixed = TRUE)) }, logical(1))]
  controle("12 (m)", !length(trouve), sprintf("aucune occurrence de \u00ab couverture_ic_sigma_mw \u00bb dans R/, app.R et .github/ (%d fichiers lus) ; en d\u00e9faut : %s",
                                              length(fs), if (length(trouve)) paste(basename(trouve), collapse = ", ") else "aucun"))
})
# Controles 13 et 14 sur les generateurs et la fixture observee.
CTRL13_GEN <- vapply(GEN, function(g) { a2 <- recomposer(g$aj, g$aj$f, g$aj$sigma2)
  identical(mw_msep(a2)$msep, g$msep) && identical(a2$reserve, g$aj$reserve) }, logical(1))
CTRL14_FX <- isTRUE(RES_FX$ok) && local({
  aj <- GEN$fixture$aj; fg <- .mw_ensembles_figes(aj)
  e_obs <- .mw_contexte_mc(aj, fg, new.env(parent = emptyenv()))
  obs <- unlist(RES_FX$bootstrap$stats_obs)
  identical(.mc_p_values(RES_FX$bootstrap$stats_boot, obs, MW_CATALOGUE_MC, e_obs)$p_mc, RES_FX$bootstrap$p_mc) &&
    identical(unname(stats_oracle(aj)[CLES]), unname(obs[CLES]))
})
AVANT <- c(INTEGRITE, if (!CTRL8_FIXTURE$ok) "8", if (!all(CTRL13_GEN)) "13", if (!CTRL14_FX) "14")
if (length(AVANT)) {
  ecrire_console(c("## INTEGRITE ECHEC avant tout tirage du plan", "",
                   vapply(CTRL, function(k) sprintf("- %s : %s -- %s", k$code, if (k$ok) "OK" else "\u00c9CHEC", k$detail), ""),
                   sprintf("- 8 (fixture) : %s -- %s", if (CTRL8_FIXTURE$ok) "OK" else "\u00c9CHEC", CTRL8_FIXTURE$txt),
                   sprintf("- 13 (g\u00e9n\u00e9rateurs) : %s ; 14 (fixture) : %s", paste(names(CTRL13_GEN), CTRL13_GEN, collapse = ", "), CTRL14_FX), "",
                   sprintf("INTEGRITE ECHEC : %s", paste(unique(AVANT), collapse = ", "))))
  quit(status = 1L)
}

###############################################################################
#  CALCUL PAR TRANCHES (reprise M42 (b))
###############################################################################
tranches_de <- function(R_) if (R_ < 1L) list() else
  lapply(seq(1L, R_, by = TAILLE_TRANCHE), function(a) c(a, min(a + TAILLE_TRANCHE - 1L, R_)))
fichier_tranche <- function(cd, tr) file.path(TRAVAIL, sprintf("%s-r%06d-%06d.tsv", cd, tr[1], tr[2]))
lire_tranche <- function(f, cd, tr, cols, texte) {
  l <- readLines(f, warn = FALSE, encoding = "UTF-8")
  n <- tr[2] - tr[1] + 1L
  if (length(l) != n + 3L || l[1] != paste0("#CONTEXTE\t", txt_ctx(CTX)) || l[2] != paste(cols, collapse = "\t") ||
      l[length(l)] != sprintf("#FIN\t%d", n))
    refuser("tranche ", basename(f), " : contexte, en-tete ou fin differents du calcul courant -- pas de melange (autre --travail)")
  df <- lire_lignes(l[3:(n + 2L)], cols, texte)
  id <- if (cd == "OR") df$k else df$r
  if (!identical(as.integer(id), seq.int(tr[1], tr[2])) || (cd != "OR" && !identical(df$profil, rep(cd, n))))
    refuser("tranche ", basename(f), " : triangles inattendus")
  df
}
ecrire_tranche <- function(f, lignes, cols, n) {
  tmp <- paste0(f, ".tmp")
  ecrire_fichier(tmp, c(paste0("#CONTEXTE\t", txt_ctx(CTX)), paste(cols, collapse = "\t"), lignes, sprintf("#FIN\t%d", n)))
  if (!file.rename(tmp, f)) stop("renommage impossible : ", basename(tmp))
}
# Premier triangle admis d'une tranche (controle 5 des profils alleges) :
# admission recalculee par le maitre (cout negligeable), meme triangle.
premier_admis <- function(p, tr) {
  for (r in seq.int(tr[1], tr[2])) if (admettre(triangle_profil(p, graine_tri(p, r)))$ok) return(r)
  NA_integer_
}
N_CALC <- 0L; N_TR_CALC <- 0L; T_CALC <- 0
# Groupes de tranches traitees par un seul appel de mclapply (ordonnancement
# dynamique) : OPT_PROC tranches pour les profils alleges (taches de 5
# triangles, triangle du controle 5 seul), une tranche pour P4 (une tache par
# triangle), 10 tranches pour l'oracle (taches de 25 triangles). Chaque ligne
# ne depend que de ses graines : le resultat ne depend ni des groupes ni du
# nombre de processus.
for (cd in c(PROFILS$code, "OR")) {
  trs <- tranches_de(R_RUN[[cd]])
  manquantes <- Filter(function(tr) !file.exists(fichier_tranche(cd, tr)), trs)
  if (!length(manquantes)) next
  p <- if (cd == "OR") NA_integer_ else match(cd, PROFILS$code)
  taille_g <- if (cd == "OR") 10L else if (PROFILS$chemin[p] == "complet") 1L else OPT_PROC
  groupes <- split(manquantes, ceiling(seq_along(manquantes) / taille_g))
  for (gr in groupes) {
    t0 <- Sys.time()
    taches <- list()
    for (tr in gr) {
      rs <- seq.int(tr[1], tr[2])
      if (cd == "OR") {
        for (v in split(rs, ceiling(seq_along(rs) / 25L))) taches[[length(taches) + 1L]] <- list(rs = v, ctl = NA_integer_)
      } else if (PROFILS$chemin[p] == "complet") {
        for (r in rs) taches[[length(taches) + 1L]] <- list(rs = r, ctl = r)
      } else {
        r5 <- premier_admis(p, tr)
        if (!is.na(r5)) taches[[length(taches) + 1L]] <- list(rs = r5, ctl = r5)
        reste <- setdiff(rs, r5)
        for (v in split(reste, ceiling(seq_along(reste) / 5L))) taches[[length(taches) + 1L]] <- list(rs = v, ctl = NA_integer_)
      }
    }
    res <- parallel::mclapply(taches, function(t) {
      if (cd == "OR") lapply(t$rs, un_oracle) else
        lapply(t$rs, function(r) un_triangle(p, r, B_RUN, complet = identical(r, t$ctl)))
    }, mc.cores = OPT_PROC, mc.preschedule = FALSE)
    ok <- vapply(res, function(x) is.list(x) && length(x) && all(vapply(x, is.list, logical(1))), logical(1))
    if (!all(ok)) stop("groupe de tranches de ", cd, " : processus en erreur ; relancer pour reprendre")
    lignes <- unlist(res, recursive = FALSE)
    ids <- vapply(lignes, function(L) as.integer(if (cd == "OR") L$k else L$r), 1L)
    for (tr in gr) {
      sel <- lignes[ids >= tr[1] & ids <= tr[2]]
      sel <- sel[order(vapply(sel, function(L) as.integer(if (cd == "OR") L$k else L$r), 1L))]
      if (cd == "OR") ecrire_tranche(fichier_tranche(cd, tr), vapply(sel, format_ligne, "", cols = COLONNES_ORA, texte = COL_TEXTE_ORA), COLONNES_ORA, length(sel))
      else ecrire_tranche(fichier_tranche(cd, tr), vapply(sel, format_ligne, ""), COLONNES, length(sel))
      N_CALC <- N_CALC + length(sel); N_TR_CALC <- N_TR_CALC + 1L
    }
    T_CALC <- T_CALC + secs(t0)
    message(sprintf("%s : %s, %d tranche(s) calculee(s) (%.0f s)", horodatage(), cd, length(gr), secs(t0)))
  }
}
TR <- list(); TRO <- list(); FICHIERS_TR <- character(0)
for (cd in PROFILS$code) for (tr in tranches_de(R_RUN[[cd]])) {
  f <- fichier_tranche(cd, tr)
  TR[[length(TR) + 1L]] <- cbind(lire_tranche(f, cd, tr, COLONNES, COL_TEXTE), tranche = basename(f), stringsAsFactors = FALSE)
  FICHIERS_TR <- c(FICHIERS_TR, f)
}
for (tr in tranches_de(R_RUN[["OR"]])) {
  f <- fichier_tranche("OR", tr)
  TRO[[length(TRO) + 1L]] <- lire_tranche(f, "OR", tr, COLONNES_ORA, COL_TEXTE_ORA)
  FICHIERS_TR <- c(FICHIERS_TR, f)
}
D <- do.call(rbind, TR)
ORA <- if (length(TRO)) do.call(rbind, TRO) else NULL
# Valeurs de l'oracle (non versionnees) : fichier du dossier de travail, md5 au T0.
F_ORACLE <- file.path(TRAVAIL, "oracle-P4.tsv")
ecrire_fichier(F_ORACLE, c(paste(setdiff(COLONNES_ORA, "duree_s"), collapse = "\t"),
                           if (!is.null(ORA)) vapply(seq_len(nrow(ORA)), function(i)
                             format_ligne(as.list(ORA[i, , drop = FALSE]), setdiff(COLONNES_ORA, "duree_s"), COL_TEXTE_ORA), "")))
MD5_ORACLE <- md5_fichier(F_ORACLE)

###############################################################################
#  CONTROLES SUR LES LIGNES CALCULEES : 4, 5, 7, 8, 13, 14, puis 1
###############################################################################
ADM <- D[D$statut %in% c("ok", "sans_intervalle"), , drop = FALSE]
ACC <- D[D$statut == "ok", , drop = FALSE]
# Controle 4 : bornes independantes, premier triangle a intervalle de chaque
# tranche et tous les triangles a intervalle ; bornes ordonnees (borne basse
# <= borne haute, I1, I2, I4, aux deux niveaux) sur tous les triangles a
# intervalle : des bornes inversees arretent le script avant l'agregation
# (INTEGRITE ECHEC).
BORNES_ORDONNEES <- all(vapply(CODES, function(k) all(vapply(names(ALPHA_NIV), function(n) {
  lo <- ACC[[paste0(k, "_", n, "_bas")]]; hi <- ACC[[paste0(k, "_", n, "_haut")]]
  all(!is.na(lo) & !is.na(hi) & lo <= hi)
}, logical(1))), logical(1)))
local({
  det <- character(0); tout <- TRUE
  for (tn in unique(D$tranche)) {
    d <- D[D$tranche == tn & D$statut == "ok", , drop = FALSE]
    if (!nrow(d)) { tout <- FALSE; det <- c(det, sprintf("%s : aucun triangle \u00e0 intervalle, contr\u00f4le non fait", tn)); next }
    e <- d$ecart_ind[1]; ok <- is.finite(e) && e <= TOL_IND
    tout <- tout && ok
    det <- c(det, sprintf("%s (r = %d) : %.2e", tn, as.integer(d$r[1]), e))
  }
  tous <- nrow(ACC) > 0L && all(is.finite(ACC$ecart_ind) & ACC$ecart_ind <= TOL_IND)
  controle("4", tout && tous && BORNES_ORDONNEES,
           sprintf("bornes de I1, I2, I4 aux deux niveaux recalcul\u00e9es par une \u00e9criture ind\u00e9pendante (statistiques d'ordre, type 7 en clair, I4 = exp(2 log \u03c3\u0302 \u2212 log q)), seuil %g relatif, premier triangle \u00e0 intervalle de chaque tranche : %s ; tous les triangles \u00e0 intervalle : %d / %d sous le seuil (\u00e9cart maximal %.2e) ; borne basse \u2264 borne haute (I1, I2, I4, deux niveaux) sur tous les triangles \u00e0 intervalle : %s",
                   TOL_IND, paste(det, collapse = " ; "), sum(is.finite(ACC$ecart_ind) & ACC$ecart_ind <= TOL_IND), nrow(ACC),
                   if (nrow(ACC)) max(ACC$ecart_ind) else NA_real_, if (BORNES_ORDONNEES) "oui" else "NON (agr\u00e9gation non faite)"))
})
# Controle 5 : sigma* de la boucle allegee contre mw_bootstrap().
local({
  det <- character(0); tout <- TRUE
  for (cd in PROFILS$code) {
    d <- D[D$profil == cd, , drop = FALSE]
    if (!nrow(d)) next
    if (cd == "P4") {
      a <- d[d$statut != "refus", , drop = FALSE]
      ok <- nrow(a) > 0L && all(a$ctl5 %in% 1)
      det <- c(det, sprintf("P4 : %d / %d triangles admis (chacun)", sum(a$ctl5 %in% 1), nrow(a)))
    } else {
      par_tr <- vapply(unique(d$tranche), function(tn) { x <- d[d$tranche == tn & d$complet %in% 1, , drop = FALSE]
        nrow(x) == 1L && isTRUE(x$ctl5 == 1) }, logical(1))
      ok <- all(par_tr)
      det <- c(det, sprintf("%s : %d / %d tranches (premier triangle admis)", cd, sum(par_tr), length(par_tr)))
    }
    tout <- tout && ok
  }
  controle("5", tout, sprintf("sigma_boot de la boucle all\u00e9g\u00e9e identical() \u00e0 celui de mw_bootstrap() : %s", paste(det, collapse = " ; ")))
})
# Controle 8 : n_sans_sigma (P5 (iii)) sur chaque triangle a bootstrap complet.
local({
  d <- D[D$complet %in% 1 & D$statut %in% c("ok", "sans_intervalle"), , drop = FALSE]
  champ <- sum(is.finite(d$nss_champ))
  deux <- !is.na(d$n_sans_sigma) & !is.na(d$nss_leger)
  ok <- CTRL8_FIXTURE$ok && nrow(d) > 0L && all(d$ctl8 %in% 1) && any(deux) && all(d$n_sans_sigma[deux] == d$nss_leger[deux])
  controle("8", ok, sprintf("fixture (graine %.0f) : %s ; plan : %d / %d triangles \u00e0 bootstrap complet o\u00f9 n_sans_sigma (masque de la boucle all\u00e9g\u00e9e sur les lignes de stats_boot \u00e0 au moins une valeur finie) = lignes calcul\u00e9es \u2212 length(sigma_boot)%s ; \u00e9cart entre n_sans_sigma du masque et de la boucle all\u00e9g\u00e9e seule : %d triangle(s)",
                            SEED_DEFAUT, CTRL8_FIXTURE$txt, sum(d$ctl8 %in% 1), nrow(d),
                            if (champ) sprintf(", et = bootstrap$n_sans_sigma (champ pr\u00e9sent sur %d)", champ) else " ; champ bootstrap$n_sans_sigma absent du moteur : comparaison au champ non faite (P5 (iii))",
                            sum(d$n_sans_sigma != d$nss_leger, na.rm = TRUE)))
})
# Controle 13 : reconstruction de sigma_B.
controle("13", all(CTRL13_GEN) && nrow(ADM) > 0L && all(ADM$ctl13 %in% 1),
         sprintf("recomposer(aj, f chapeau, \u03c3\u0302\u00b2) redonne MSEP et R identical() : g\u00e9n\u00e9rateurs %s ; %d / %d triangles admis ; \u03c3_B : R_B \u2264 0 ou MSEP_B non finie sur %d triangle(s) (compt\u00e9(s) \u00e0 part)",
                 paste(sprintf("%s %s", names(CTRL13_GEN), ifelse(CTRL13_GEN, "oui", "NON")), collapse = ", "),
                 sum(ADM$ctl13 %in% 1), nrow(ADM), sum(!is.finite(ADM$sigma_B))))
# Controle 14 : .mc_p_values() redonne boot$p_mc (P4), et statistiques observees
# du chemin de l'oracle identiques a celles du bootstrap (validite du temoin).
local({
  d <- D[D$profil == "P4" & D$statut %in% c("ok", "sans_intervalle"), , drop = FALSE]
  ok <- CTRL14_FX && (nrow(d) == 0L || (all(d$ctl14 %in% 1) && all(d$obs_coh %in% 1)))
  controle("14", ok, sprintf(".mc_p_values(stats_boot, obs, MW_CATALOGUE_MC, contexte observ\u00e9) identical() \u00e0 boot$p_mc, et statistiques observ\u00e9es de stats_oracle() identical() \u00e0 boot$stats_obs : fixture %s ; P4 : %d / %d et %d / %d triangles admis",
                             if (CTRL14_FX) "oui" else "NON", sum(d$ctl14 %in% 1), nrow(d), sum(d$obs_coh %in% 1), nrow(d)))
})
# Controle 7 (i2) : 5 triangles de P4 et 2 de P1 (premier, dernier et
# reguliers parmi les admis) ; run_engine() redonne $bootstrap et
# $ic_bootstrap identical() au chemin du script, et la ligne recalculee est
# identique a la ligne de la tranche, hors duree.
echantillon <- function(r_adm, n) if (!length(r_adm)) integer(0) else r_adm[unique(round(seq(1, length(r_adm), length.out = n)))]
R7 <- rbind(if (any(D$profil == "P4")) cbind(p = 4L, r = echantillon(as.integer(ADM$r[ADM$profil == "P4"]), 5L)),
            if (any(D$profil == "P1")) cbind(p = 1L, r = echantillon(as.integer(ADM$r[ADM$profil == "P1"]), 2L)))
t_c7 <- Sys.time()
C7 <- parallel::mclapply(seq_len(NROW(R7)), function(i) {
  p <- as.integer(unname(R7[i, "p"])); r <- as.integer(unname(R7[i, "r"]))
  x <- un_triangle(p, r, B_RUN, complet = TRUE, garder = TRUE)
  re <- run_engine(methode = "reserve2", triangle = x$objets$tri, segment = 1, annexe = "II", B = B_RUN,
                   seed = graine_boot(p, r), date_reference = DATE_REFERENCE_TESTS)
  ref <- D[D$profil == PROFILS$code[p] & D$r == r, , drop = FALSE]
  l <- x$ligne
  if (p != 4L) l$complet <- ref$complet           # P1 : ligne de tranche a bootstrap complet ou non
  if (p != 4L && !isTRUE(ref$complet == 1)) for (cc in c("ctl5", "ctl8", "nss_champ")) l[[cc]] <- NA
  if (p != 4L && !isTRUE(ref$complet == 1)) l$n_sans_sigma <- l$nss_leger
  rep_ok <- identical(format_ligne(l, COLONNES_BRUT), format_ligne(as.list(ref), COLONNES_BRUT))
  ic_s <- ic_script(x$objets$s)
  list(p = p, r = r, ok_re = isTRUE(re$ok), boot = identical(re$bootstrap, x$objets$bt),
       ic = identical(if (is.null(ic_s)) NULL else ic_s, if (is.null(re$ic_bootstrap)) NULL else unname(as.numeric(re$ic_bootstrap))),
       rep = rep_ok)
}, mc.cores = OPT_PROC, mc.preschedule = FALSE)
DUREE_C7 <- secs(t_c7)
local({
  okv <- function(ch) all(vapply(C7, function(x) is.list(x) && isTRUE(x[[ch]]), logical(1)))
  n4 <- sum(R7[, "p"] == 4L); n1 <- sum(R7[, "p"] == 1L)
  # 5 de P4 et 2 de P1 (P11) ; moins sous --essai si moins de triangles admis.
  n_att <- min(5L, sum(ADM$profil == "P4")) + min(2L, sum(ADM$profil == "P1"))
  ok <- NROW(R7) == n_att && n_att > 0L && (OPT_ESSAI || n_att == 7L) && okv("ok_re") && okv("boot") && okv("ic") && okv("rep")
  controle("7 (i2)", ok, sprintf("run_engine(methode = \"reserve2\", triangle = tri_r, segment = 1, annexe = \"II\", B, seed = graine du bootstrap, date_reference = DATE_REFERENCE_TESTS) sur %d triangle(s) de P4 (r = %s) et %d de P1 (r = %s) : $bootstrap identical() \u00e0 mw_bootstrap() du script %s ; $ic_bootstrap identical() au percentile du script (\u03c3* de la boucle all\u00e9g\u00e9e) %s ; ligne recalcul\u00e9e identique \u00e0 celle de la tranche, hors dur\u00e9e : %s",
                                 n4, paste(R7[R7[, "p"] == 4L, "r"], collapse = ", "), n1, paste(R7[R7[, "p"] == 1L, "r"], collapse = ", "),
                                 if (okv("ok_re") && okv("boot")) "oui" else "NON", if (okv("ic")) "oui" else "NON", if (okv("rep")) "oui" else "NON"))
})
# Controle 1 : fin du calcul.
MD5_MOTEUR_FIN <- md5_fichier(file.path(RACINE, "R", "engine.R"))
SHA_FIN <- sha_head()
EMPREINTE_FIN <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
local({
  ctx_tr <- unique(unname(vapply(FICHIERS_TR, function(f) readLines(f, n = 1L, warn = FALSE), "")))
  ok_ctx <- length(ctx_tr) == 1L && identical(ctx_tr, paste0("#CONTEXTE\t", txt_ctx(CTX)))
  ok <- MD5_MOTEUR_DEBUT == MD5_MOTEUR_FIN && SHA_DEBUT == SHA_FIN && SHA_DEBUT != "inconnu" && EMPREINTE_DEBUT == EMPREINTE_FIN &&
    identical(J0$sha, SHA_DEBUT) && identical(J0$md5, MD5_MOTEUR_DEBUT) && identical(J0$empreinte, EMPREINTE_DEBUT) && ok_ctx
  controle("1", ok, sprintf("md5 R/engine.R d\u00e9but %s, fin %s, JOURNAL %s ; SHA d\u00e9but %s, fin %s, JOURNAL %s ; empreinte #231 d\u00e9but %s, fin %s, JOURNAL %s ; contexte (B, SHA, md5 du moteur et du script, empreinte, plateforme) identique dans les %d tranche(s) : %s",
                            MD5_MOTEUR_DEBUT, MD5_MOTEUR_FIN, J0$md5, SHA_DEBUT, SHA_FIN, J0$sha, EMPREINTE_DEBUT, EMPREINTE_FIN, J0$empreinte,
                            length(FICHIERS_TR), if (ok_ctx) "oui" else "NON"))
})
ORDRE_CTRL <- c("1", "2", "3", "4", "5", "6 (g)", "7 (i2)", "8", "9", "10", "11 (t387)", "12 (m)", "13", "14", "fixture")
CTRL <- CTRL[order(match(vapply(CTRL, function(k) k$code, ""), ORDRE_CTRL))]
# Bornes inversees (controle 4) : arret avant l'agregation.
if (!BORNES_ORDONNEES) {
  ecrire_console(c("## INTEGRITE ECHEC avant l'agr\u00e9gation : bornes invers\u00e9es (contr\u00f4le 4)", "",
                   vapply(CTRL, function(k) sprintf("- %s : %s -- %s", k$code, if (k$ok) "OK" else "\u00c9CHEC", k$detail), ""), "",
                   sprintf("INTEGRITE ECHEC : %s", paste(INTEGRITE, collapse = ", "))))
  quit(status = 1L)
}

###############################################################################
#  AGREGATION : COUVERTURE (K-M1 a K-M3, K-M5)
###############################################################################
ic_cp <- function(k, n) {
  if (n <= 0) return(c(NA_real_, NA_real_))
  c(if (k == 0) 0 else stats::qbeta(0.025, k, n - k + 1), if (k == n) 1 else stats::qbeta(0.975, k + 1, n - k))
}
CLASSES <- c(comp = "compatible", mineur = "\u00e9cart mineur", nt = "non tranch\u00e9",
             lib = "distorsion mat\u00e9rielle lib\u00e9rale (sous-couverture)", cons = "distorsion mat\u00e9rielle conservatrice")
# Classe d'un taux k/n contre rho (bande fermee [rho/2 ; 3 rho/2]) : copie de
# classer() de tests/couverture_ic_sigma_t8.R.
classer <- function(k, n, rho) {
  if (n == 0) return(list(taux = NA_real_, ci = c(NA_real_, NA_real_), classe = "non \u00e9valuable (n = 0)", code = NA_character_, bord = NA_character_))
  t <- k / n; ci <- ic_cp(k, n); bas <- rho / 2; haut <- 3 * rho / 2
  code <- if (ci[1] <= rho && rho <= ci[2]) "comp" else if (ci[1] > haut) "lib" else if (ci[2] < bas) "cons" else
    if (t >= bas && t <= haut) "mineur" else "nt"
  touche <- c(if (ci[1] <= bas && bas <= ci[2]) "\u03c1/2", if (ci[1] <= haut && haut <= ci[2]) "3\u03c1/2")
  list(taux = t, ci = ci, classe = CLASSES[[code]], code = code,
       bord = if (length(touche)) paste0("oui (", paste(touche, collapse = ", "), ")") else "non")
}
cellule_cov <- function(cd, code, niv, cible = "A", sous = NULL) {
  d <- ACC[ACC$profil == cd, , drop = FALSE]
  if (!is.null(sous)) d <- d[sous(d), , drop = FALSE]
  lo <- d[[paste0(code, "_", niv, "_bas")]]; hi <- d[[paste0(code, "_", niv, "_haut")]]
  s0 <- if (cible == "A") rep(SIGMA_A[[cd]], nrow(d)) else d$sigma_B
  k_ <- !is.na(lo) & !is.na(hi) & is.finite(s0)
  lo <- lo[k_]; hi <- hi[k_]; s0 <- s0[k_]; n <- length(lo)
  # Non-couverture : !(lo <= s0 <= hi) (jamais plus de n) ; queues separees.
  nc <- sum(!(lo <= s0 & s0 <= hi)); nb <- sum(s0 < lo); nh <- sum(s0 > hi); rho <- RHO_NIV[[niv]]
  w <- (hi - lo) / SIGMA_A[[cd]]
  qw <- if (n) suppressWarnings(stats::quantile(w, c(.1, .5, .9), type = 7, names = FALSE)) else rep(NA_real_, 3)
  qw[is.nan(qw)] <- Inf
  list(n = n, nb = nb, nh = nh, cl = classer(nc, n, rho), cb = classer(nb, n, rho / 2), ch = classer(nh, n, rho / 2),
       cov = if (n) 1 - nc / n else NA_real_, cov_ci = if (n) 1 - rev(ic_cp(nc, n)) else c(NA_real_, NA_real_),
       larg = qw, larg_moy = if (n && cd %in% c("P1", "P2", "P3")) mean(w) else NA_real_,
       neg = sum(lo <= 0), inf = sum(is.infinite(hi)))
}
PR_ACTIFS <- PROFILS$code[R_RUN[PROFILS$code] > 0L]
CEL <- list()
for (cd in PR_ACTIFS) for (code in CODES) for (niv in names(ALPHA_NIV)) CEL[[paste(cd, code, niv)]] <- cellule_cov(cd, code, niv)
strate <- function(pi) ifelse(pi == 0, STRATES[1], ifelse(pi <= 0.05, STRATES[2], ifelse(pi <= 0.20, STRATES[3], STRATES[4])))
REFUS <- lapply(stats::setNames(nm = PR_ACTIFS), function(cd) table(factor(D$statut[D$profil == cd], levels = STATUTS)))
MOTIFS <- lapply(stats::setNames(nm = PR_ACTIFS), function(cd) { m <- D$motif_code[D$profil == cd & D$statut == "refus"]; table(m) })
part_non_ok <- function(cd) (sum(REFUS[[cd]]) - REFUS[[cd]][["ok"]]) / R_RUN[[cd]]
part_p4_autre <- if ("P4" %in% PR_ACTIFS) {
  d <- D[D$profil == "P4", , drop = FALSE]
  (sum(d$statut == "refus" & d$motif_code != "M4") + sum(d$statut %in% c("echec_bootstrap", "echec_autre"))) / R_RUN[["P4"]]
} else NA_real_

###############################################################################
#  VOLET A.5 (ii) : P4, ORACLE CONDITIONNEL, McNEMAR, TEMOIN (P8)
###############################################################################
# Copies declarees de tests/calibration_mc_mw_t8.R : taille_lissee() (par. 4
# de #206 ; rho a B = 999, statistique oracle non finie comptee comme
# non-rejet), lecture() (classes de #166 avec rho), mcnemar(),
# m_rejet_oracle(), atome_cheval(), p_betabinom(), p_oracle_region(),
# classer_k3() (regle beta-binomiale de l'annotation du 05/11/2026 de #206).
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
CLASSES_206 <- c("compatible", "\u00e9cart mineur", "\u00e9cart non tranch\u00e9", "distorsion mat\u00e9rielle")
lecture <- function(k, n, ref) {
  if (n == 0 || !is.finite(ref))
    return(list(k = k, n = n, taux = if (n) k / n else NA_real_, ci = if (n) ic_cp(k, n) else c(NA_real_, NA_real_),
                evaluable = FALSE, disj = FALSE, cote = NA_character_,
                classe = if (n == 0) "non \u00e9valuable (n = 0)" else "non \u00e9valuable (\u03c1 absente)"))
  ci <- ic_cp(k, n); t <- k / n
  ref_ic <- ref >= ci[1] && ref <= ci[2]
  cote <- if (ci[2] < ref / 2) "conservateur" else if (ci[1] > 3 * ref / 2) "lib\u00e9ral" else NA_character_
  classe <- if (ref_ic) CLASSES_206[1] else if (!is.na(cote)) CLASSES_206[4] else
    if (t >= ref / 2 && t <= 3 * ref / 2) CLASSES_206[2] else CLASSES_206[3]
  list(k = k, n = n, taux = t, ci = ci, evaluable = TRUE, disj = !is.na(cote), cote = cote, classe = classe)
}
mcnemar <- function(d1, d2) {
  n01 <- sum(d1 & !d2); n10 <- sum(!d1 & d2); n <- n01 + n10
  c(n01 = n01, n10 = n10, p = if (n) stats::binom.test(n01, n, 0.5)$p.value else 1)
}
m_rejet_oracle <- function(S0, queue, a) {
  S <- sort(S0[is.finite(S0)]); N <- length(S)
  if (!N || N < B_MIN_DEGENERESCENCE || diff(range(S)) <= TOL_DISPERSION_MC * max(1, abs(S[1]))) return(NA_real_)
  v <- unique(S)
  n_le <- findInterval(v, S)
  n_ge <- N - findInterval(v, S, left.open = TRUE)
  cnt <- n_le - c(0L, utils::head(n_le, -1L))
  p_bas <- (1 + n_le) / (N + 1); p_haut <- (1 + n_ge) / (N + 1)
  p <- pmin(switch(queue, haut = p_haut, bas = p_bas, deux = 2 * pmin(p_haut, p_bas)), 1)
  sum(cnt[p < a])
}
atome_cheval <- function(S0, queue, a, n_tot = sum(is.finite(S0))) {
  S <- S0[is.finite(S0)]; N <- length(S)
  vide <- data.frame(cote = character(0), valeur = numeric(0), masse = numeric(0), avant = numeric(0), avec = numeric(0),
                     decision = character(0), credit = numeric(0), stringsAsFactors = FALSE)
  if (!N) return(vide)
  v <- sort(unique(S)); cnt <- tabulate(match(S, v), length(v))
  seuil <- round((if (queue == "deux") a / 2 else a) * (N + 1), 9)
  c_t <- ceiling(round((if (queue == "deux") a / 2 else a) * (N + 1), 9)) - 2
  cotes <- list(basse = cumsum(cnt), haute = N - cumsum(cnt) + cnt)
  cotes <- cotes[switch(queue, bas = "basse", haut = "haute", deux = c("basse", "haute"))]
  out <- lapply(names(cotes), function(ct) {
    avec <- cotes[[ct]]; avant <- avec - cnt
    j <- which(cnt >= 2L & 1 + avant < seuil & seuil <= 1 + avec)
    if (!length(j)) return(NULL)
    p <- engine_p_mc(S0, v[j[1]], queue)$p_mc
    data.frame(cote = ct, valeur = v[j[1]], masse = cnt[j[1]] / N, avant = avant[j[1]] / N, avec = avec[j[1]] / N,
               decision = if (is.finite(p) && p < a) "rejet\u00e9 par l'oracle" else "non rejet\u00e9 par l'oracle",
               credit = cnt[j[1]] / n_tot * stats::pbinom(c_t, N, avec[j[1]] / N), stringsAsFactors = FALSE)
  })
  out <- Filter(Negate(is.null), out)
  if (length(out)) do.call(rbind, out) else vide
}
p_betabinom <- function(k, n, a, b) {
  x <- 0:n; lp <- lchoose(n, x) + lbeta(x + a, n - x + b) - lbeta(a, b)
  lse <- function(z) { m <- max(z); m + log(sum(exp(z - m))) }
  min(1, 2 * exp(min(lse(lp[seq_len(k + 1L)]), lse(lp[(k + 1L):(n + 1L)]))))
}
p_oracle_region <- function(k, n, m_r, N, t) {
  if (!is.finite(m_r) || !is.finite(N)) return(NA_real_)
  a <- m_r + t; b <- N + 1 - a
  if (a <= 0 || b <= 0) return(NA_real_)
  p_betabinom(k, n, a, b)
}
CLASSES_K3 <- c(i = "(i)", ii = "(ii)", non = "non expliqu\u00e9", aucun = "\u2014")
classer_k3 <- function(signal, p_holm_part, n_atomes) {
  vapply(seq_along(signal), function(i) {
    if (!isTRUE(signal[i])) return(CLASSES_K3[["aucun"]])
    if (is.finite(p_holm_part[i]) && p_holm_part[i] >= NIVEAU_HOLM) {
      if (n_atomes[i] > 0L) CLASSES_K3[["ii"]] else CLASSES_K3[["i"]]
    } else CLASSES_K3[["non"]]
  }, "")
}
P4A <- D[D$profil == "P4" & D$statut %in% c("ok", "sans_intervalle"), , drop = FALSE]
mat <- function(d, pre) { M <- as.matrix(d[, paste0(pre, ":", CLES), drop = FALSE]); dimnames(M) <- list(NULL, CLES); M }
ORA_ADM <- if (is.null(ORA)) NULL else ORA[ORA$statut %in% c("admis", "echec_stats"), , drop = FALSE]
N_OR_ADM <- if (is.null(ORA_ADM)) 0L else nrow(ORA_ADM)
RESUME_OR <- lapply(stats::setNames(nm = CLES), function(s) {
  S0 <- if (N_OR_ADM) ORA_ADM[[paste0("obs:", s)]] else numeric(0)
  S <- S0[is.finite(S0)]
  vv <- sort(unique(S)); cnt <- if (length(S)) tabulate(match(S, vv), length(vv)) else integer(0)
  list(S0 = S0, n_fin = length(S), n_nonfini = N_OR_ADM - length(S), distinctes = length(vv),
       atome = if (length(S)) max(cnt) / length(S) else NA_real_,
       rho = vapply(SEUILS_MC, function(a) taille_lissee(S, QUEUE[[s]], B_RUN, a, N_OR_ADM), 1),
       taille_or = vapply(SEUILS_MC, function(a) taille_lissee(S, QUEUE[[s]], length(S), a, N_OR_ADM), 1))
})
VOLET <- if (nrow(P4A)) local({
  PE <- mat(P4A, "p"); PC <- mat(P4A, "pc"); OBS <- mat(P4A, "obs"); n <- nrow(P4A)
  kv1 <- list(); kv2 <- list(); kv3 <- list()
  P <- if (N_OR_ADM) vapply(CLES, function(s) vapply(OBS[, s], function(o) engine_p_mc(RESUME_OR[[s]]$S0, o, QUEUE[[s]])$p_mc, 1), numeric(n)) else NULL
  if (!is.null(P) && !is.matrix(P)) P <- matrix(P, nrow = n, dimnames = list(NULL, CLES))
  for (ia in names(SEUILS_MC)) {
    a <- SEUILS_MC[[ia]]
    for (s in CLES) {
      ref <- RESUME_OR[[s]]$rho[[ia]]
      fe <- is.finite(PE[, s]); fc <- is.finite(PC[, s])
      kv1[[length(kv1) + 1L]] <- list(ia = ia, s = s, ref = ref, e = lecture(sum(fe & PE[, s] < a), n, ref),
                                      c = lecture(sum(fc & PC[, s] < a), n, ref), abs_e = sum(!fe), abs_c = sum(!fc),
                                      tdef = if (any(fe)) sum(fe & PE[, s] < a) / sum(fe) else NA_real_)
    }
    m <- t(vapply(CLES, function(s) mcnemar(is.finite(PE[, s]) & PE[, s] < a, is.finite(PC[, s]) & PC[, s] < a), numeric(3)))
    kv2[[ia]] <- data.frame(ia = ia, s = CLES, n01 = m[, "n01"], n10 = m[, "n10"], p = m[, "p"],
                            p_holm = stats::p.adjust(m[, "p"], "holm", n = NS), stringsAsFactors = FALSE)
    if (N_OR_ADM) {
      j <- match(ia, names(SEUILS_MC))
      k <- colSums(is.finite(P) & P < a); ab <- colSums(!is.finite(P))
      tl <- vapply(CLES, function(s) RESUME_OR[[s]]$taille_or[j], 1)
      p <- vapply(CLES, function(s) if (is.finite(tl[[s]])) stats::binom.test(k[[s]], n, tl[[s]])$p.value else NA_real_, 1)
      p_holm <- stats::p.adjust(p, "holm", n = length(p))
      m_r <- vapply(CLES, function(s) m_rejet_oracle(RESUME_OR[[s]]$S0, QUEUE[[s]], a), 1)
      n_f <- vapply(CLES, function(s) RESUME_OR[[s]]$n_fin, 1)
      tq <- ifelse(QUEUE[CLES] == "deux", 2, 1)
      p_part <- vapply(seq_along(CLES), function(i) p_oracle_region(k[[i]], n, m_r[[i]], n_f[[i]], tq[[i]]), 1)
      p_holm_part <- stats::p.adjust(p_part, "holm", n = length(p_part))
      at <- lapply(CLES, function(s) atome_cheval(RESUME_OR[[s]]$S0, QUEUE[[s]], a, N_OR_ADM))
      n_at <- vapply(at, nrow, 1L)
      signal <- is.finite(p_holm) & p_holm < NIVEAU_HOLM
      kv3[[ia]] <- data.frame(ia = ia, s = CLES, n = n, absentes = ab, k = k, taille = tl, p = p, p_holm = p_holm, m_r = m_r,
                              N_or = n_f, p_holm_part = p_holm_part, n_atomes = n_at,
                              classe = classer_k3(signal, p_holm_part, n_at), signal = signal, stringsAsFactors = FALSE)
    }
  }
  list(n = n, kv1 = kv1, kv2 = do.call(rbind, kv2), kv3 = if (length(kv3)) do.call(rbind, kv3) else NULL,
       absentes = sum(rowSums(!is.finite(PE)) > 0))
}) else NULL

###############################################################################
#  PROFILS Omega, V et Lambda, EVALUES MECANIQUEMENT (SANS DECISION)
###############################################################################
cl90 <- function(cd, code) { x <- CEL[[paste(cd, code, "90")]]; if (is.null(x)) NA_character_ else x$cl$code }
okc <- function(cd) !is.na(cd) && cd %in% c("comp", "mineur")
lib_classe <- function(cd) if (is.na(cd)) "non \u00e9valuable" else CLASSES[[cd]]
PROFIL <- local({
  km4 <- !length(INTEGRITE)
  hors <- c(if ("P1" %in% PR_ACTIFS && part_non_ok("P1") > SEUIL_OMEGA0) "P1", if ("P2" %in% PR_ACTIFS && part_non_ok("P2") > SEUIL_OMEGA0) "P2",
            if (isTRUE(part_p4_autre > SEUIL_OMEGA0)) "P4 (autre motif que M4)")
  i1 <- c(P1 = cl90("P1", "I1"), P2 = cl90("P2", "I1"))
  opp <- all(i1 %in% c("lib", "cons")) && i1[["P1"]] != i1[["P2"]]
  ok2 <- function(code) okc(cl90("P1", code)) && okc(cl90("P2", code))
  suite <- if (opp) "\u03a94" else if (ok2("I1")) "\u03a91" else if (ok2("I4")) "\u03a92" else if (ok2("I2")) "\u03a92\u2032" else "\u03a93"
  p <- if (!km4 || length(hors)) "\u03a90" else suite
  retenus <- if (suite == "\u03a91") "I1" else if (suite == "\u03a92") c("I1", "I4") else character(0)
  # Modificateur V (reponse d'actuary a Q9) : classe absente sur P4 (n = 0) :
  # V non evaluable ; sinon V-a si toutes compatibles ou en ecart mineur, V-b.
  v <- if (length(retenus)) {
    cl <- vapply(retenus, function(c_) cl90("P4", c_), "")
    if (any(is.na(cl))) "V non \u00e9valuable (n = 0 sur P4)" else if (all(vapply(cl, okc, logical(1)))) "V-a" else "V-b"
  } else "sans objet"
  list(profil = p, suite = suite, km4 = km4, hors = hors, i1 = i1, opp = opp, ok_i2 = ok2("I2"), ok_i4 = ok2("I4"),
       retenus = retenus, v = v)
})
LAMBDA <- if (is.null(VOLET)) list(profil = "non \u00e9valuable (aucun triangle admis de P4)") else local({
  kv3_non <- !is.null(VOLET$kv3) && any(VOLET$kv3$classe == CLASSES_K3[["non"]])
  kv3_absent <- is.null(VOLET$kv3)
  kv4 <- VOLET$absentes / VOLET$n <= SEUIL_KV4
  cls <- vapply(VOLET$kv1, function(x) x$e$classe, "")
  dist <- any(vapply(VOLET$kv1, function(x) isTRUE(x$e$disj), logical(1)))
  mcn <- any(VOLET$kv2$p_holm < NIVEAU_HOLM)
  tous_ok <- all(cls %in% CLASSES_206[1:2])
  # Etat distinct juste apres Lambda0 (reponse d'actuary a Q5) : une cle non
  # evaluable (rho absente) suspend la lecture du volet.
  ne <- startsWith(cls, "non \u00e9valuable")
  n_ne <- sum(ne)
  cles_ne <- vapply(VOLET$kv1[ne], function(x) sprintf("%s (\u03b1 = %s)", x$s, num(SEUILS_MC[[x$ia]], 2)), "")
  p <- if (kv3_non || kv3_absent || !kv4) "\u039b0"
       else if (n_ne > 0) "\u039b non \u00e9valuable"
       else if (dist || mcn) "\u039b3"
       else if (tous_ok) "\u039b1"
       else "\u039b2"
  list(profil = p, kv3_non = kv3_non, kv3_absent = kv3_absent, kv4 = kv4, dist = dist, mcn = mcn, tous_ok = tous_ok,
       n_nt = sum(cls == CLASSES_206[3]), n_ne = n_ne, cles_ne = cles_ne)
})

###############################################################################
#  SORTIE MARKDOWN
###############################################################################
`%+%` <- function(a, b) paste0(a, b)
# B_eff de la p conditionnelle sur P4 (reponse d'actuary a Q8) : nombre de
# lignes a sigma* fini, min, quartiles (type 7) et max.
P4A_BEFF <- if (nrow(P4A)) vapply(stats::quantile(P4A$B_eff_sigma, c(0, .25, .5, .75, 1), type = 7, names = FALSE), num, "", d = 1) else rep("\u2014", 5)
txt_cel_cov <- function(c_) if (!c_$n) "\u2014" else sprintf("%s %s", num(c_$cov), txt_ic(c_$cov_ci))
txt_cl <- function(cl) if (is.na(cl$taux)) "\u2014" else sprintf("%s %s", num(cl$taux), txt_ic(cl$ci))
txt_lec <- function(c_) if (is.na(c_$taux)) "\u2014" else sprintf("%s %s", num(c_$taux, 5), txt_ic(c_$ci, 5))
txt_cl206 <- function(c_) if (c_$disj) sprintf("%s (**%s**)", c_$classe, c_$cote) else c_$classe
fit_txt <- function(gn) {
  g <- GEN[[gn]]
  sprintf("R\u0302 = %.6g ; MSEP = %.6g ; \u03c3_A = %.7g ; f\u0302 = (%s) ; pool n = %d, sd_pop = %.5f ; colonnes d\u00e9g\u00e9n\u00e9r\u00e9es : %s",
          g$aj$reserve, g$msep, g$sigma_A, paste(sprintf("%.6g", g$aj$f), collapse = " ; "), length(g$pool), g$sd_pop,
          if (length(g$jd)) paste(g$jd, collapse = ", ") else "aucune")
}
lib_profil <- function(p) sprintf("%s : %s, loi %s ; %s", PROFILS$code[p], PROFILS$gen[p], PROFILS$loi[p], PROFILS$role[p])
S <- c(sprintf("## Mesure #387 (S5, \u00e9tape 4) : couverture \u00e0 T = 8 de l'intervalle bootstrap de \u03c3, m\u00e9thode Merz-W\u00fcthrich, et volet A.5 (ii) de #492%s",
               if (OPT_ESSAI) " -- ESSAI (--essai), non versionnable" else ""), "",
       "### Statut \u00e9pist\u00e9mique (protocole, par. 1, reproduit tel quel)", "", TEXTE_STATUT_387, "",
       "### T0 \u2014 provenance", "",
       entete_md(c("Grandeur", "Valeur")),
       ligne_md("Protocole", sprintf("%s, P1 \u00e0 P11 et par. 3 ; d\u00e9cisions du mainteneur du 19/11/2026 (Q-1b-1 (A), Q-1b-2 (b), Q-1b-3, 4, 6, 8, Q-1b-5 (A), Q-1b-7) ; md5 %s",
                                      PROTOCOLE, md5_fichier(file.path(RACINE, PROTOCOLE)))),
       ligne_md("Sp\u00e9cification de la fixture et de n_sans_sigma", sprintf("%s, A.0 et A.2 ; md5 %s", SPEC_1A, md5_fichier(file.path(RACINE, SPEC_1A)))),
       ligne_md("Mode", if (OPT_ESSAI) "essai (--essai) : non versionnable" else "mesure"),
       ligne_md("R par profil (tir\u00e9s) ; B ; niveau", sprintf("%s ; %s ; %s", txt_R(R_RUN), format(B_RUN), if (is.na(OPT_NIVEAU)) "non d\u00e9clar\u00e9" else OPT_NIVEAU)),
       ligne_md("Profils", paste(vapply(seq_len(nrow(PROFILS)), lib_profil, ""), collapse = " ; ")),
       ligne_md("G\u00e9n\u00e9rateur reserve2", sprintf("tests/donnees/triangle_mw.csv (md5 %s) ; %s", md5_fichier(file.path(RACINE, "tests", "donnees", "triangle_mw.csv")), fit_txt("reserve2"))),
       ligne_md("G\u00e9n\u00e9rateur fixture", sprintf("%s ; %s", if (FIXTURE_FICHIER_PRESENT) sprintf("%s (md5 %s)", FICHIER_FIXTURE, md5_fichier(file.path(RACINE, FICHIER_FIXTURE))) else
         "dput de A.0 embarqu\u00e9 (fichier de #492 absent)", fit_txt("fixture"))),
       ligne_md("Lois", "E : tirage uniforme dans le pool redress\u00e9 du g\u00e9n\u00e9rateur (.mw_pool_residus(aj0, jd0)) divis\u00e9 par son \u00e9cart-type de population ; N : stats::rnorm ; A : (G \u2212 2)/\u221a2, G ~ Gamma(2) par stats::qgamma(stats::runif(n), 2)"),
       ligne_md("Chemin", "gen_triangle_h0(aj0, loi) sous engine_sous_graine(G_tri) ; admettre() (mw_valider_triangle(), mw_ajuster(), mw_msep(), mw_valider_ajustement() ; segment 1, annexe II) ; boucle all\u00e9g\u00e9e \u00e0 B, graine G_boot ; P4, et premier triangle admis de chaque tranche ailleurs : mw_bootstrap(aj, B, G_boot, .mw_ensembles_figes(aj)) complet (Q-1b-2 (b))"),
       ligne_md("Graines", "triangle r du profil p : 387 000 000 + 1 000 000 (p \u2212 1) + r ; bootstrap : 387 500 000 + 1 000 000 (p \u2212 1) + r ; oracle de P4 : 392 000 000 + k ; pr\u00e9-vol : 393 000 000 + 10 000 (p \u2212 1) + u et 393 050 000 + 10 000 (p \u2212 1) + u ; contr\u00f4le 9 : graines de #206 (loi E, b = 1, 2) ; disjonction : contr\u00f4le 10"),
       ligne_md("G\u00e9n\u00e9rateur al\u00e9atoire", paste(ENGINE_RNG_KIND, collapse = ", ")),
       ligne_md("Cible", "\u03c3_A (cible principale, Q-1b-1 (A)) = \u03c3\u0302 du triangle g\u00e9n\u00e9rateur ; \u03c3_B (descriptive) = \u221aMSEP/R de mw_msep() sur la copie de l'ajustement du triangle simul\u00e9 \u00e0 (f, \u03c3\u00b2) du g\u00e9n\u00e9rateur (P3)"),
       ligne_md("Intervalles", "quantiles de type 7 des \u03c3* finis ; I1 [q_\u03b1 ; q_(1\u2212\u03b1)] ; I2 [2\u03c3\u0302 \u2212 q_(1\u2212\u03b1) ; 2\u03c3\u0302 \u2212 q_\u03b1] ; I4 [\u03c3\u0302\u00b2/q_(1\u2212\u03b1) ; \u03c3\u0302\u00b2/q_\u03b1] ; 90 % (\u03b1 = 0,05) et 95 % (\u03b1 = 0,025) ; intervalle form\u00e9 si plus de 20 \u03c3* finis"),
       ligne_md("Oracle de P4", sprintf("%d triangles tir\u00e9s, %d admis ; valeurs non versionn\u00e9es (oracle-P4.tsv du dossier de travail), md5 %s", R_RUN[["OR"]], N_OR_ADM, MD5_ORACLE)),
       ligne_md("SHA, git rev-parse HEAD (d\u00e9but ; fin)", sprintf("%s ; %s", SHA_DEBUT, SHA_FIN)),
       ligne_md("Commit (commit_depot(), au d\u00e9but)", COMMIT_DEBUT),
       ligne_md("md5 R/engine.R (d\u00e9but ; fin)", sprintf("%s ; %s", MD5_MOTEUR_DEBUT, MD5_MOTEUR_FIN)),
       ligne_md("Empreinte sans commentaires de R/engine.R (#231 ; d\u00e9but ; fin)", sprintf("%s ; %s", EMPREINTE_DEBUT, EMPREINTE_FIN)),
       ligne_md("Empreintes md5 du code ex\u00e9cut\u00e9", EMPREINTES),
       ligne_md("Champ bootstrap$n_sans_sigma (#492)", if (any(is.finite(D$nss_champ))) "pr\u00e9sent dans le moteur : compar\u00e9 (contr\u00f4le 8)" else "absent du moteur : non compar\u00e9 (contr\u00f4le 8, P5 (iii))"),
       ligne_md("Plateforme de calcul", PLATEFORME),
       ligne_md("Locale (LC_CTYPE)", sprintf("%s \u2192 %s", LOCALE_ORIGINE, LOCALE_TRAVAIL)),
       ligne_md("Tranches", sprintf("%d (taille %d), profils et oracle", length(FICHIERS_TR), TAILLE_TRANCHE)),
       ligne_md("JOURNAL ; valeurs brutes", sprintf("%s ; %s (une ligne par triangle tir\u00e9, %%.17g)", NOM_JNL, NOM_TSV)),
       ligne_md("Versionnable (--ecrire)", if (length(motifs_non_versionnable(COMMIT_DEBUT, EMPREINTES, "de la mesure")) || OPT_ESSAI) "non" else "oui"),
       ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", if (length(INTEGRITE)) paste("\u00c9CHEC :", paste(INTEGRITE, collapse = ", ")) else "OK"),
       "",
       "### Aide \u00e0 la lecture", "",
       paste("\u03c4 = part des triangles admis \u00e0 intervalle o\u00f9 la cible est hors de l'intervalle ; IC de Clopper-Pearson \u00e0 95 % (qbeta), erreur Monte-Carlo du taux (fonction du nombre de triangles).",
             "L'effet de B est inclus dans la proc\u00e9dure mesur\u00e9e et non isol\u00e9. Couverture conditionnelle \u00e0 l'admission (M4 : R\u0302 > 0) et, pour les \u03c3*, \u00e0 R* > 0.",
             "Classes et profils calcul\u00e9s m\u00e9caniquement, sur les valeurs non arrondies, **sans conclure** : la lecture revient \u00e0 actuary, la d\u00e9cision (D2) au mainteneur."), "",
       "**Crit\u00e8re et profils du protocole (par. 3), report\u00e9s sans modification :**", "",
       TEXTE_CRITERE_387, "")
if (length(REMPLACES)) S <- inserer_t0(S, ligne_remplacement(REMPLACES, CIBLES[1]))
# Controles.
S <- c(S, "### Contr\u00f4les d'int\u00e9grit\u00e9 (K-M4 : P11, contr\u00f4les 1 \u00e0 14, plus le contr\u00f4le de la fixture)", "",
       entete_md(c("Contr\u00f4le", "R\u00e9sultat", "D\u00e9tail")),
       vapply(CTRL, function(k) ligne_md(k$code, if (k$ok) "OK" else "\u00c9CHEC", k$detail), ""), "")
# T1, T2 : K-M1, K-M2.
tableau_k <- function(titre, cds) {
  L <- c(titre, "", entete_md(c("Profil", "Intervalle", "n", "couverture [IC 95 %]", "\u03c4\u0302 [IC CP 95 %]", "classe (\u03c4, \u03c1 = 0,10)", "K-M5 : IC touche un bord")))
  for (cd in intersect(cds, PR_ACTIFS)) for (code in CODES) {
    c_ <- CEL[[paste(cd, code, "90")]]
    L <- c(L, ligne_md(cd, LIB_CODES[[code]], c_$n, txt_cel_cov(c_), txt_cl(c_$cl), c_$cl$classe, c_$cl$bord))
  }
  c(L, "")
}
S <- c(S, tableau_k("### T1 \u2014 K-M1 (principal) : classe \u00e0 90 % de I1, I2 et I4 sur P1 et P2, cible \u03c3_A", c("P1", "P2")),
       tableau_k("### T2 \u2014 K-M2 (secondaire, port\u00e9e conditionnelle) : classe \u00e0 90 % de I1, I2 et I4 sur les triangles admis de P4, cible \u03c3_A", "P4"))
# T3 : toutes les cellules.
S <- c(S, "### T3 \u2014 couverture par profil, intervalle et niveau, cible \u03c3_A (K-M1 \u00e0 K-M3, K-M5)", "",
       paste("Queues s\u00e9par\u00e9es (K-M3) : part de \u03c3_A sous la borne basse et au-dessus de la borne haute, classe contre \u03c1/2 (bande [\u03c1/4 ; 3\u03c1/4]).",
             "Largeurs divis\u00e9es par \u03c3_A : quantiles 10 %, 50 %, 90 % ; moyenne sur P1 \u00e0 P3 seulement (P4, P5 : non informative, protocole par. 4)."), "",
       entete_md(c("Profil", "Intervalle", "Niveau", "n", "couverture [IC 95 %]", "\u03c4\u0302 [IC]", "classe (\u03c4, \u03c1)", "K-M5",
                   "sous la borne basse [IC] ; classe (\u03c1/2)", "au-dessus de la borne haute [IC] ; classe (\u03c1/2)",
                   "largeur / \u03c3_A : q10 ; m\u00e9diane ; q90", "largeur moyenne / \u03c3_A", "bornes basses \u2264 0", "bornes hautes infinies")))
for (cd in PR_ACTIFS) for (code in CODES) for (niv in names(ALPHA_NIV)) {
  c_ <- CEL[[paste(cd, code, niv)]]
  S <- c(S, ligne_md(cd, LIB_CODES[[code]], paste0(niv, " %"), c_$n, txt_cel_cov(c_), txt_cl(c_$cl), c_$cl$classe, c_$cl$bord,
                     sprintf("%s ; %s", txt_cl(c_$cb), c_$cb$classe), sprintf("%s ; %s", txt_cl(c_$ch), c_$ch$classe),
                     sprintf("%s ; %s ; %s", num(c_$larg[1]), num(c_$larg[2]), num(c_$larg[3])), num(c_$larg_moy), c_$neg, c_$inf))
}
# T4 : cible sigma_B.
S <- c(S, "", "### T4 \u2014 couverture de \u03c3_B (cible descriptive, K-M3)", "",
       "\u03c3_B(r) = \u221aMSEP/R de mw_msep() sur la copie de l'ajustement du triangle r \u00e0 (f, \u03c3\u00b2) du g\u00e9n\u00e9rateur (P3, interpr\u00e9tation sans source) ; triangles \u00e0 R_B \u2264 0 ou MSEP_B non finie compt\u00e9s \u00e0 part.", "",
       entete_md(c("Profil", "Intervalle", "Niveau", "n", "couverture de \u03c3_B [IC 95 %]", "\u03c4\u0302 [IC]", "classe (\u03c4, \u03c1), descriptive", "R_B \u2264 0 ou MSEP_B non finie")))
for (cd in PR_ACTIFS) for (code in CODES) for (niv in names(ALPHA_NIV)) {
  c_ <- cellule_cov(cd, code, niv, cible = "B")
  S <- c(S, ligne_md(cd, LIB_CODES[[code]], paste0(niv, " %"), c_$n, txt_cel_cov(c_), txt_cl(c_$cl), c_$cl$classe,
                     sum(ACC$profil == cd & !is.finite(ACC$sigma_B))))
}
# T5 : strates de pi chapeau.
S <- c(S, "", "### T5 \u2014 couverture de \u03c3_A par strate de \u03c0\u0302 = n_sans_sigma / B (P4 et P5, K-M3, descriptif)", "",
       entete_md(c("Profil", "Intervalle", "Niveau", paste0("\u03c0\u0302 ", STRATES, " : n ; couverture [IC]"))))
for (cd in intersect(c("P4", "P5"), PR_ACTIFS)) for (code in CODES) for (niv in names(ALPHA_NIV)) {
  cel <- vapply(STRATES, function(st) { c_ <- cellule_cov(cd, code, niv, sous = function(d) strate(d$n_sans_sigma / B_RUN) == st)
    sprintf("%d ; %s", c_$n, txt_cel_cov(c_)) }, "")
  S <- c(S, do.call(ligne_md, c(list(cd, LIB_CODES[[code]], paste0(niv, " %")), as.list(cel))))
}
# T6 : biais.
S <- c(S, "", "### T6 \u2014 biais (K-M3, descriptif)", "",
       entete_md(c("Profil", "n", "m\u00e9diane de \u03c3\u0302/\u03c3_A", "moyenne de \u03c3\u0302/moyenne(\u03c3*) (P1 \u00e0 P3)", "m\u00e9diane du rang de \u03c3\u0302 dans \u03c3* (#{\u03c3* < \u03c3\u0302}/B_eff)")))
for (cd in PR_ACTIFS) {
  d <- ACC[ACC$profil == cd, , drop = FALSE]
  S <- c(S, ligne_md(cd, nrow(d), num(if (nrow(d)) stats::median(d$sigma_hat / SIGMA_A[[cd]]) else NA),
                     num(if (nrow(d) && cd %in% c("P1", "P2", "P3")) mean(d$sigma_hat / d$moy_sigma_star) else NA),
                     num(if (nrow(d)) stats::median(d$rang) else NA)))
}
# T7 : admission, refus, n_sans_sigma.
q_pi <- function(v) if (!length(v)) "\u2014" else paste(vapply(stats::quantile(v, c(0, .1, .25, .5, .75, .9, 1), type = 7, names = FALSE), num, "", d = 4), collapse = " ; ")
S <- c(S, "", "### T7 \u2014 admission, refus, triangles sans intervalle, n_sans_sigma", "",
       entete_md(c("Profil", "tir\u00e9s", paste("statut", STATUTS), "motifs de refus", "non retenus / tir\u00e9s (\u03a90 : P1, P2)",
                   "\u03c0\u0302 : min ; q10 ; q25 ; m\u00e9diane ; q75 ; q90 ; max", "\u03c0\u0302 = 0 ; > 0,05 ; > 0,20", "retirage (cumuls) ; plafond")))
for (cd in PR_ACTIFS) {
  t_ <- REFUS[[cd]]; m_ <- MOTIFS[[cd]]; a <- ADM[ADM$profil == cd, , drop = FALSE]; pi_ <- a$n_sans_sigma / B_RUN
  S <- c(S, ligne_md(cd, R_RUN[[cd]], paste(as.integer(t_), collapse = " | "),
                     if (length(m_)) paste(sprintf("%s (%d)", names(m_), as.integer(m_)), collapse = " ; ") else "aucun",
                     num(part_non_ok(cd)), q_pi(pi_),
                     if (length(pi_)) sprintf("%s ; %s ; %s", num(mean(pi_ == 0)), num(mean(pi_ > 0.05)), num(mean(pi_ > 0.20))) else "\u2014",
                     sprintf("%d ; %d", sum(a$retires %in% 1), sum(a$plafond %in% 1))))
}
if ("P4" %in% PR_ACTIFS) S <- c(S, "", sprintf("P4 : refus d'un autre motif que M4 et \u00e9checs / tir\u00e9s (\u03a90) : %s.", num(part_p4_autre)))
msgs <- unique(D$message[!is.na(D$message) & D$statut %in% c("echec_bootstrap", "echec_autre")])
if (length(msgs)) S <- c(S, "", paste0("\u00c9checs rencontr\u00e9s : ", paste(utils::head(msgs, 10), collapse = " ; ")))
# T8 : volet A.5 (ii).
S <- c(S, "", "### T8 \u2014 volet A.5 (ii) de #492 : taux de rejet des 13 p de Monte-Carlo sur les triangles admis de P4 (Q-1b-5 (A))", "")
if (is.null(VOLET)) S <- c(S, "Aucun triangle admis de P4 : volet non \u00e9valuable.", "") else {
  S <- c(S, paste(sprintf("Population : %d triangles admis de P4 \u00e0 bootstrap complet. D\u00e9cision : p < \u03b1 ; une p absente compte comme un non-rejet (compt\u00e9e \u00e0 part).", VOLET$n),
                  sprintf("\u03c1 : taille liss\u00e9e du test de Monte-Carlo id\u00e9al \u00e0 B = %s (r\u00e8gle de #206, par. 4), calcul\u00e9e sur l'oracle de P4 restreint aux triangles admis (%d sur %d tir\u00e9s) ; statistique oracle non finie compt\u00e9e comme non-rejet.", format(B_RUN), N_OR_ADM, R_RUN[["OR"]]),
                  "p conditionnelle : .mc_p_values() sur les seules lignes de stats_boot \u00e0 \u03c3* fini (masque de P5 (iii)), calcul\u00e9e dans ce script seulement ; elle ne change ni p ni verdict du moteur."), "",
         "**Oracle et \u03c1**", "",
         entete_md(c("Cl\u00e9 (sens)", "oracle admis", "non finies", "valeurs distinctes", "masse du plus gros atome", "\u03c1 0,10", "\u03c1 0,05", "taille t\u00e9moin 0,10", "taille t\u00e9moin 0,05")),
         vapply(CLES, function(s) { o <- RESUME_OR[[s]]
           ligne_md(sprintf("%s (%s)", s, QUEUE[[s]]), N_OR_ADM, o$n_nonfini, o$distinctes, num(o$atome, 5),
                    paste0(num(o$rho[[1]], 5), if (N_OR_ADM && o$n_nonfini / N_OR_ADM > 0.01) " (**approch\u00e9**)" else ""),
                    paste0(num(o$rho[[2]], 5), if (N_OR_ADM && o$n_nonfini / N_OR_ADM > 0.01) " (**approch\u00e9**)" else ""),
                    num(o$taille_or[[1]], 5), num(o$taille_or[[2]], 5)) }, ""), "",
         "**K-V1 : classe de #206 de \u03c4 contre \u03c1 ; p conditionnelle en regard (descriptive)**", "",
         entete_md(c("\u03b1", "Cl\u00e9 (sens)", "n", "p absentes (moteur ; cond.)", "\u03c1", "\u03c4 moteur [IC]", "classe K-V1", "\u03c4 sur p d\u00e9finies", "\u03c4 conditionnelle [IC]",
                     sprintf("classe de \u03c4 conditionnelle (descriptif : \u03c1 \u00e0 B = %s, p conditionnelle \u00e0 B_eff variable, \u00e9cart de r\u00e9f\u00e9rence non corrig\u00e9)", format(B_RUN)))),
         vapply(VOLET$kv1, function(x) ligne_md(num(SEUILS_MC[[x$ia]], 2), sprintf("%s (%s)", x$s, QUEUE[[x$s]]), x$e$n, sprintf("%d ; %d", x$abs_e, x$abs_c),
                                                num(x$ref, 5), txt_lec(x$e), txt_cl206(x$e), num(x$tdef, 5), txt_lec(x$c), txt_cl206(x$c)), ""),
         ligne_md("\u2014", "B_eff de la p conditionnelle sur P4 (lignes \u00e0 \u03c3* fini)", VOLET$n, "\u2014", "\u2014", "\u2014", "\u2014", "\u2014",
                  sprintf("min %s ; q25 %s ; m\u00e9diane %s ; q75 %s ; max %s", P4A_BEFF[1], P4A_BEFF[2], P4A_BEFF[3], P4A_BEFF[4], P4A_BEFF[5]), "\u2014"), "",
         "**K-V2 : McNemar exact (binomiale 1/2 sur n01 + n10 ; n01 : le moteur rejette, la p conditionnelle non), Holm sur 13 par \u03b1**", "",
         entete_md(c("\u03b1", "Cl\u00e9 (sens)", "n01 / n10", "p", "p Holm", "significatif (0,05)")),
         vapply(seq_len(nrow(VOLET$kv2)), function(i) { x <- VOLET$kv2[i, ]
           ligne_md(num(SEUILS_MC[[x$ia]], 2), sprintf("%s (%s)", x$s, QUEUE[[x$s]]), sprintf("%d / %d", x$n01, x$n10), fmt_p(x$p), fmt_p(x$p_holm),
                    if (x$p_holm < NIVEAU_HOLM) "**oui**" else "non") }, ""), "",
         "**K-V3 : t\u00e9moin oracle** (p_or = engine_p_mc(S0, s_obs, sens) contre l'oracle ; binomial exact contre la taille du t\u00e9moin, Holm sur 13 par \u03b1 ; signal expliqu\u00e9 si la p de Holm b\u00eata-binomiale sur la r\u00e9gion de rejet r\u00e9alis\u00e9e de l'oracle est au moins 0,05, r\u00e8gle de l'annotation du 05/11/2026 de #206)", "",
         if (is.null(VOLET$kv3)) "Oracle absent : t\u00e9moin non calcul\u00e9." else
           c(entete_md(c("\u03b1", "Cl\u00e9 (sens)", "n", "p_or absentes", "k", "\u03c4_or", "taille", "p Holm binomiale", "m_r / N", "p Holm b\u00eata-binomiale", "atomes \u00e0 cheval", "K-V3")),
             vapply(seq_len(nrow(VOLET$kv3)), function(i) { x <- VOLET$kv3[i, ]
               ligne_md(num(SEUILS_MC[[x$ia]], 2), sprintf("%s (%s)", x$s, QUEUE[[x$s]]), x$n, x$absentes, x$k, num(x$k / x$n, 5), num(x$taille, 5),
                        fmt_p(x$p_holm), if (is.finite(x$m_r)) sprintf("%s / %d", format(x$m_r), x$N_or) else "\u2014", fmt_p(x$p_holm_part), x$n_atomes, x$classe) }, "")), "",
         sprintf("**K-V4** : triangles admis de P4 \u00e0 au moins une p_mc absente : %d / %d (%s ; seuil %s). Distribution de \u03c0\u0302 : tableau T7, ligne P4.",
                 VOLET$absentes, VOLET$n, num(VOLET$absentes / VOLET$n), num(SEUIL_KV4, 2)), "")
}
# Profils.
S <- c(S, "### Profils de lecture pour D2, \u00e9valu\u00e9s m\u00e9caniquement, sans d\u00e9cision", "",
       entete_md(c("\u00c9l\u00e9ment", "Valeur")),
       ligne_md("K-M4 (contr\u00f4les d'int\u00e9grit\u00e9)", if (PROFIL$km4) "rempli" else sprintf("en d\u00e9faut (%s)", paste(INTEGRITE, collapse = ", "))),
       ligne_md("non retenus au-del\u00e0 de 1 % (P1, P2 : refus, \u00e9checs, sans intervalle ; P4 : autre motif que M4)",
                if (length(PROFIL$hors)) paste(PROFIL$hors, collapse = ", ") else
                  sprintf("non (P1 %s ; P2 %s ; P4 autre motif %s)", num(if ("P1" %in% PR_ACTIFS) part_non_ok("P1") else NA),
                          num(if ("P2" %in% PR_ACTIFS) part_non_ok("P2") else NA), num(part_p4_autre))),
       ligne_md("classe de I1 \u00e0 90 %", sprintf("P1 %s ; P2 %s", lib_classe(PROFIL$i1[["P1"]]), lib_classe(PROFIL$i1[["P2"]]))),
       ligne_md("I1 en distorsion de c\u00f4t\u00e9s oppos\u00e9s (\u03a94)", if (PROFIL$opp) "oui" else "non"),
       ligne_md("I4 compatible ou en \u00e9cart mineur sur P1 et P2", if (PROFIL$ok_i4) "oui" else "non"),
       ligne_md("I2 compatible ou en \u00e9cart mineur sur P1 et P2", if (PROFIL$ok_i2) "oui" else "non"),
       ligne_md("**Profil \u03a9 (lecture propos\u00e9e)**", if (PROFIL$profil == "\u03a90" && PROFIL$suite != "\u03a90")
         sprintf("**\u03a90** ; hors \u03a90 : %s", PROFIL$suite) else sprintf("**%s**", PROFIL$profil)),
       ligne_md("Modificateur V (K-M2, sous \u03a91 ou \u03a92)", if (length(PROFIL$retenus)) sprintf("%s (intervalle(s) retenu(s) : %s ; classe sur P4 : %s)%s", PROFIL$v,
         paste(PROFIL$retenus, collapse = ", "), paste(vapply(PROFIL$retenus, function(c_) sprintf("%s %s", c_, lib_classe(cl90("P4", c_))), ""), collapse = " ; "),
         if (startsWith(PROFIL$v, "V non")) " ; K-M2 non lu ; extension non remise en cause ; d\u00e9cision du mainteneur \u00e0 D2" else "") else "sans objet"),
       ligne_md("**Profil \u039b (volet A.5 (ii))**", if (is.null(VOLET)) LAMBDA$profil else
         sprintf("**%s** (K-V3 non expliqu\u00e9 : %s ; K-V4 rempli : %s ; distorsion mat\u00e9rielle K-V1 : %s ; McNemar significatif : %s ; cl\u00e9s non tranch\u00e9es : %d ; non \u00e9valuables : %d)",
                 LAMBDA$profil, if (LAMBDA$kv3_absent) "t\u00e9moin absent" else if (LAMBDA$kv3_non) "oui" else "non", if (LAMBDA$kv4) "oui" else "non",
                 if (LAMBDA$dist) "oui" else "non", if (LAMBDA$mcn) "oui" else "non", LAMBDA$n_nt, LAMBDA$n_ne) %+%
           if (identical(LAMBDA$profil, "\u039b non \u00e9valuable"))
             sprintf(" ; cl\u00e9s en cause : %s, motif \u00ab \u03c1 absente \u00bb ; lecture du volet suspendue, retour au mainteneur", paste(LAMBDA$cles_ne, collapse = ", ")) else ""),
       "", "Les profils sont des lectures propos\u00e9es : D2 revient au mainteneur.", "",
       sprintf("Bilan : %s", if (length(INTEGRITE)) sprintf("\u00c9CHEC (%s)", paste(INTEGRITE, collapse = ", ")) else "OK"), "")
duree_cumulee <- sum(D$duree_s, na.rm = TRUE) + if (!is.null(ORA)) sum(ORA$duree_s, na.rm = TRUE) else 0
S_EXEC <- c("### Ex\u00e9cution (varie d'une ex\u00e9cution \u00e0 l'autre)", "",
            sprintf("- Lancement (JOURNAL) : %s ; fin : %s", J0$lancement, horodatage()),
            sprintf("- Processus : %d ; triangles calcul\u00e9s par cette ex\u00e9cution : %d, %d tranche(s), %s s d'horloge ; tranches reprises : %d",
                    OPT_PROC, N_CALC, N_TR_CALC, num(T_CALC, 0), length(FICHIERS_TR) - N_TR_CALC),
            sprintf("- Dur\u00e9e cumul\u00e9e des triangles (somme des processus) : %s s ; run_engine() sur la fixture : %s s ; contr\u00f4le 7 : %s s ; dur\u00e9e totale : %s s",
                    num(duree_cumulee, 0), num(DUREE_RE, 1), num(DUREE_C7, 1), num(secs(t_debut), 0)), "")

###############################################################################
#  ECRITURE
###############################################################################
brut <- c(paste(COLONNES_BRUT, collapse = "\t"),
          vapply(seq_len(nrow(D)), function(i) format_ligne(as.list(D[i, , drop = FALSE]), COLONNES_BRUT), ""))
MD_FINAL <- c(S, S_EXEC)
f_md <- file.path(TRAVAIL, NOM_MD); f_tsv <- file.path(TRAVAIL, NOM_TSV)
ecrire_fichier(f_md, MD_FINAL)
ecrire_fichier(f_tsv, brut)
ecrire_fichier(JOURNAL_T, c(sprintf("- Fin : %s ; SHA \u00e0 la fin %s ; md5 R/engine.R \u00e0 la fin %s ; INTEGRITE %s",
                                    horodatage(), SHA_FIN, MD5_MOTEUR_FIN, if (length(INTEGRITE)) "ECHEC" else "OK"),
                            sprintf("- Sortie %s : md5 %s", NOM_MD, md5_fichier(f_md)),
                            sprintf("- Sortie %s : md5 %s", NOM_TSV, md5_fichier(f_tsv)),
                            sprintf("- Oracle (oracle-P4.tsv, non versionn\u00e9) : md5 %s", MD5_ORACLE)), mode = "ab")
ecrire_console(MD_FINAL)
ecrire_console(sprintf("Sorties (dossier de travail, hors du d\u00e9p\u00f4t) : %s ; %s ; %s", f_md, f_tsv, JOURNAL_T))
REFUS_ECRITURE <- FALSE
copier_fichier <- function(src, dst) {
  tmp <- tempfile(pattern = paste0(".", basename(dst), "."), tmpdir = dirname(dst))
  on.exit(if (file.exists(tmp)) unlink(tmp), add = TRUE)
  tryCatch({
    oct <- readBin(src, "raw", n = file.size(src))
    con <- file(tmp, open = "wb")
    tryCatch(writeBin(oct, con), finally = close(con))
    identical(unname(tools::md5sum(tmp)), unname(tools::md5sum(src))) && isTRUE(suppressWarnings(file.rename(tmp, dst)))
  }, error = function(e) FALSE)
}
if (OPT_ECRIRE) {
  ab <- chemins_absolus(c(readLines(f_md, warn = FALSE, encoding = "UTF-8"), readLines(JOURNAL_T, warn = FALSE, encoding = "UTF-8")))
  if (length(INTEGRITE)) {
    REFUS_ECRITURE <- TRUE
    message("--ecrire refuse : INTEGRITE ECHEC (", paste(INTEGRITE, collapse = ", "), ") ; sorties laissees dans le dossier de travail")
  } else if (length(ab)) {
    REFUS_ECRITURE <- TRUE
    message("--ecrire refuse : chemin absolu ou /tmp dans une sortie : ", paste(utils::head(ab, 3), collapse = " | "))
  } else {
    nv <- motifs_non_versionnable(commit_depot(SCRIPT_DEPOT), empreintes_code(), "de la mesure")
    if (length(nv)) { message("--ecrire refuse au moment d'ecrire : ", paste(nv, collapse = " ; ")); REFUS_ECRITURE <- TRUE } else {
      garde_ecrasement(CIBLES, remplacer = OPT_REMPLACER)
      if (!all(mapply(copier_fichier, c(f_md, f_tsv, JOURNAL_T), CIBLES))) {
        message("--ecrire : copie incomplete vers docs/tableaux"); REFUS_ECRITURE <- TRUE
      } else ecrire_console(sprintf("\u00c9crit : %s", paste(file.path("docs", "tableaux", basename(CIBLES)), collapse = " ; ")))
    }
  }
}
ecrire_console(paste("INTEGRITE", if (length(INTEGRITE)) "ECHEC" else "OK"))
quit(status = if (length(INTEGRITE) || REFUS_ECRITURE) 1L else 0L)
