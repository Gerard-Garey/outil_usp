###############################################################################
#  tests/double_bootstrap_mw.R  --  DOUBLE BOOTSTRAP MERZ-WUTHRICH : FREQUENCE
#  DE LA P DE MONTE-CARLO OBSERVEE DANS SA LOI SIMULEE (issue #246)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils, tools et parallel, livres avec R). Il ne modifie ni
#  R/, ni app.R, ni tests/reference/ ; ni le moteur ni l'application ne le
#  lisent ni ne l'appellent (controle (m)) ; il ne change ni sigma_USP, ni une
#  p retenue, ni un verdict (P14). Le moteur est charge par
#  tests/outils_tests.R, donc par charger_moteur() (ADR 0016).
#  Sortie en markdown sur la console (UTF-8, y compris sous LC_ALL=C : la
#  categorie LC_CTYPE est basculee sur une locale UTF-8 au demarrage si
#  necessaire, #113, #242) ; fichiers ecrits SEULEMENT sur option explicite
#  (--ecrire, --sortie). Tous les libelles non ASCII du script sont ecrits en
#  echappements \u (fichier source ASCII).
#
#  Protocole : specification d'actuary
#  docs/revues/20261119-s5-bootstrap-mw/actuary-1c-protocole-246.md, P1 a P14
#  et decisions du mainteneur du 19/11/2026 :
#    D-1 (a) : aucune citation de reference sur l'origine du principe, ni ici
#              ni dans la sortie ; le principe est decrit par son operation ;
#    D-2 (a) : la sortie d'un triangle du dossier reste hors du depot
#              (--sortie) ; seule celle de reserve2 va dans docs/tableaux/
#              (--ecrire) ;
#    D-3     : R = 1 000 par defaut, plafond 2 000 ; alerte si
#              |sd_pop - 1| > 0,05 ; bande descriptive
#              F(p_obs -/+ 2 err_mc) affichee ; aucune loi N ni A ;
#    D-4 (a) : sur reserve2 sous la loi E, comptes identiques au bit pres au
#              brut de #297 ; pour les 9 cles inchangees depuis #206,
#              identiques aussi au brut de #206 (controle (r2)).
#
#  Ce que le script fait (P3 a P9) : pour un triangle donne, lit les p de
#  Monte-Carlo observees p_obs du moteur (run_engine()) ; ajuste le modele de
#  Mack au triangle ; simule R triangles sous ce modele avec des erreurs tirees
#  dans le pool de residus redresse et divise par son ecart-type de population
#  (loi E de #206) ; applique a chacun le test bootstrap du moteur
#  (mw_bootstrap() a B = 999, puis mw_tests()) ; rend, par cle de
#  MW_CATALOGUE_MC, la frequence des p simulees au plus egales a p_obs, avec
#  son intervalle de Clopper-Pearson, plus les niveaux du test bootstrap sous
#  ce modele (produits du meme calcul). Statut epistemique : TXT_STATUT,
#  reproduit en tete de la sortie ; la frequence est un CONSTAT DE SIMULATION
#  sous un modele et une loi, jamais une p exacte ni une p retenue.
#
#  Modes (un seul par execution) :
#      Rscript tests/double_bootstrap_mw.R --essai [--R n] [options]
#          calcul complet, console seulement, sortie marquee ESSAI (non
#          versionnable, aucun controle d'arbre propre) ;
#      Rscript tests/double_bootstrap_mw.R --ecrire [--R n] [options]
#          reserve2 seul (D-2) : ecrit dans docs/tableaux/ (date du jour) le
#          tableau <AAAAMMJJ>-issue246-double-bootstrap-reserve2.md et les
#          valeurs brutes ...-brut.tsv (une ligne par r), fichiers nouveaux,
#          jamais ecrases (garde d'ecrasement de #173) ; arbre propre et
#          script suivi exiges, code du depot ;
#      Rscript tests/double_bootstrap_mw.R --sortie DOSSIER [--triangle F ...]
#          memes fichiers dans un dossier HORS du depot (jamais ecrases) ;
#          seul chemin des triangles du dossier (D-2) ;
#      Rscript tests/double_bootstrap_mw.R --prevol [--unites 3] [options]
#          sans rien ecrire : duree de run_engine() sur le triangle donne,
#          motifs de refus des R triangles, cout c_b (mw_bootstrap() a
#          B = 999 + mw_tests()) et debit agrege a 1, 2, 3 et 4 processus
#          (sous-processus --prevol-unite), duree prevue pour R = 1 000 et
#          R = 2 000 ; a refaire pour chaque triangle (le cout depend de ses
#          dimensions). Imprime la ligne a reporter par --debit-prevol.
#  (--prevol-unite --r-unite a:b : mode interne de --prevol.)
#  Options communes : --triangle FICHIER (CSV au format de
#  tests/donnees/triangle_mw.csv ; defaut reserve2), --segment, --annexe,
#  --date-reference (obligatoires avec --triangle ; defaut reserve2 : 1, II,
#  DATE_REFERENCE_TESTS), --seed (graine du calcul observe, defaut 20260831),
#  --R (defaut 1 000, plafond 2 000), --coeurs (processus, mclapply ; defaut
#  min(4, detectCores()) ; 1 sous Windows), --debit-prevol TEXTE (ligne du
#  pre-vol, reportee telle quelle en provenance).
#  Sans --essai, --ecrire ou --sortie est obligatoire.
#
#  Graines (P7), toutes sous engine_sous_graine() : plan de #206 pour la loi E
#  (triangle r : base + r ; bootstrap interne r : base + r ; r <= 2 000). Les
#  deux plages sont REEMPLOYEES a dessein de #206 (appariement : le triangle de
#  reserve2 reproduit les lignes E des bruts de #206 et #297) ; elles sont
#  declarees par les deux affectations PLAGE_* ci-dessous, que le controle
#  (graines) de tests/calibration_mc_mw_t8.R ecarte de sa recherche de
#  litteraux (R21, #350). Aucun autre litteral de graine n'est ecrit ici.
#  Une ligne ne depend que de r et de ses graines : la sortie ne depend pas de
#  --coeurs (controle (rep)).
#
#  Controles d'integrite (P11) : (g), (i1) et (m) AVANT tout tirage du plan ;
#  (i2), (rep) et (r2) sur les lignes calculees. Un seul echec : ligne
#  "INTEGRITE ECHEC", aucune ecriture, code de sortie 1.
#    (g)   gen_triangle_h0() (epsilon tires par sample(pool)) identique a
#          mw_simuler_triangle() sous la meme graine, 100 graines (forme de
#          #206 par. 6, pool dilate de #271 compris) ;
#    (i1)  point observe : $bootstrap et $tests de run_engine() identiques au
#          chemin direct mw_bootstrap() + mw_tests() (memes ensembles figes,
#          meme graine) ; p_obs en particulier ;
#    (i2)  sur un echantillon de lignes (premier r admis, dernier r admis, 5
#          r regulierement repartis) : run_engine(triangle = tri_r, seed =
#          graine du bootstrap de r) donne $tests et $bootstrap identiques au
#          chemin du script ;
#    (rep) ces memes lignes, recalculees dans une seconde passe (taches
#          distinctes de la boucle principale), redonnent la ligne calculee
#          dans la boucle, hors duree ; la reproductibilite de deux executions
#          et l'identite entre --coeurs 1 et --coeurs 4 se verifient en
#          comparant les sorties console hors section "Execution" (voir plus
#          bas) ;
#    (r2)  reserve2 (triangle identique a tests/donnees/triangle_mw.csv,
#          segment 1, annexe II) : vecteurs de p simulees et comptes
#          #{p* <= p_obs} des r <= R identiques a ceux du brut de #297
#          (docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv,
#          lignes type = rep, loi = E, colonnes pR:<cle>) et, pour les 9 cles
#          dont la statistique est inchangee depuis #206, du brut de #206
#          (20261011-issue206-calibration-mw-brut.tsv) ; Calendrier, BP,
#          MinP4 et PenteIntra : comparaison a #206 sans objet (statistique
#          ou sens change) ; a R = 2 000 et graine par defaut, comptes et p_obs
#          de l'oracle du par. 5 du protocole retrouves exactement. Ce
#          controle prouve que l'outil realise le plan de #206 et #297, ce
#          n'est pas une validation independante de la methode ;
#    (m)   aucune occurrence du nom de ce script dans R/, app.R, .github/.
#  La sortie console porte la section finale "Execution" (date, durees,
#  processus, debit) : seule partie qui varie entre deux executions a
#  arguments egaux (hors --coeurs).
#
#  Code de sortie : 0 si les controles d'integrite tiennent, 1 sinon.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/double_bootstrap_mw.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113, critere de #242) -------------
LOCALE_ORIGINE <- Sys.getlocale("LC_CTYPE")
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break
LOCALE_TRAVAIL <- Sys.getlocale("LC_CTYPE")

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
OPTIONS_VALEUR <- c("--triangle", "--segment", "--annexe", "--date-reference", "--seed", "--R", "--coeurs",
                    "--sortie", "--unites", "--debit-prevol", "--r-unite")
OPTIONS_DRAPEAU <- c("--essai", "--prevol", "--ecrire", "--prevol-unite")
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
  if (is.na(i)) return(defaut)
  ARGS[i + 1L]
}
OPT_TRIANGLE <- lire_option("--triangle", NA_character_)
OPT_SEGMENT  <- lire_option("--segment", NA_character_)
OPT_ANNEXE   <- lire_option("--annexe", NA_character_)
OPT_DATE_REF <- lire_option("--date-reference", NA_character_)
OPT_SEED     <- lire_option("--seed", "20260831")
OPT_R        <- lire_option("--R", "1000")
OPT_COEURS   <- lire_option("--coeurs", NA_character_)
OPT_SORTIE   <- lire_option("--sortie", NA_character_)
OPT_UNITES   <- lire_option("--unites", "3")
OPT_DEBIT    <- lire_option("--debit-prevol", NA_character_)
OPT_R_UNITE  <- lire_option("--r-unite", NA_character_)
OPT_ESSAI    <- "--essai" %in% ARGS
OPT_PREVOL   <- "--prevol" %in% ARGS
OPT_ECRIRE   <- "--ecrire" %in% ARGS
OPT_UNITE    <- "--prevol-unite" %in% ARGS
MODE <- if (OPT_UNITE) "unite" else if (OPT_PREVOL) "prevol" else "mesure"
if (OPT_UNITE && OPT_PREVOL) stop("un mode et un seul : --prevol ou --prevol-unite")
reserve <- function(opts, modes) for (o in opts) if (o %in% ARGS && !MODE %in% modes)
  stop(o, " : reserve au(x) mode(s) ", paste(modes, collapse = ", "))
reserve(c("--essai", "--ecrire", "--sortie", "--debit-prevol"), "mesure")
reserve(c("--unites"), "prevol")
reserve(c("--r-unite"), "unite")
if (OPT_ESSAI && (OPT_ECRIRE || !is.na(OPT_SORTIE))) stop("--essai : console seulement (sortie marquee), refuse avec --ecrire et --sortie")
if (OPT_ECRIRE && !is.na(OPT_SORTIE)) stop("--ecrire et --sortie sont exclusifs")
if (MODE == "mesure" && !OPT_ESSAI && !OPT_ECRIRE && is.na(OPT_SORTIE))
  stop("sans --essai : --ecrire (reserve2, docs/tableaux/) ou --sortie DOSSIER (hors du depot) obligatoire")
# D-2 (a) : seul reserve2, plan canonique (ni triangle, ni segment, ni annexe passes),
# va dans docs/tableaux/ ; un triangle du dossier ne sort que hors du depot.
if (OPT_ECRIRE && (!is.na(OPT_TRIANGLE) || !is.na(OPT_SEGMENT) || !is.na(OPT_ANNEXE)))
  stop("--ecrire : reserve2 seul, sans --triangle, --segment ni --annexe (D-2 (a)) ; un triangle du dossier sort par --sortie, hors du depot")
if (!is.na(OPT_TRIANGLE) && !file.exists(OPT_TRIANGLE)) stop("--triangle : fichier introuvable : ", OPT_TRIANGLE)
if (!is.na(OPT_TRIANGLE) && (is.na(OPT_SEGMENT) || is.na(OPT_ANNEXE) || is.na(OPT_DATE_REF)))
  stop("--triangle : --segment, --annexe et --date-reference obligatoires (aucun defaut pour un triangle du dossier)")
SEGMENT <- if (is.na(OPT_SEGMENT)) 1 else suppressWarnings(as.numeric(OPT_SEGMENT))
if (is.na(SEGMENT)) stop("--segment : nombre attendu")
ANNEXE <- if (is.na(OPT_ANNEXE)) "II" else OPT_ANNEXE
SEED <- suppressWarnings(as.numeric(OPT_SEED))
if (is.na(SEED) || SEED != round(SEED)) stop("--seed : entier attendu")
R_TOT <- if (grepl("^[0-9]+$", OPT_R)) suppressWarnings(as.integer(OPT_R)) else NA_integer_
R_PLAFOND <- 2000L
if (is.na(R_TOT) || R_TOT < 1L || R_TOT > R_PLAFOND) stop("--R : entier de 1 a ", R_PLAFOND, " (plages de graines de #206, P7)")
N_COEURS <- if (is.na(OPT_COEURS) || !grepl("^[0-9]+$", OPT_COEURS)) NA_integer_ else suppressWarnings(as.integer(OPT_COEURS))
if (!is.na(OPT_COEURS) && (is.na(N_COEURS) || N_COEURS < 1L)) stop("--coeurs : entier >= 1")
UNITES <- suppressWarnings(as.integer(OPT_UNITES))
if (is.na(UNITES) || UNITES < 1L) stop("--unites : entier >= 1")
if (!is.na(OPT_R_UNITE) && !grepl("^[0-9]+:[0-9]+$", OPT_R_UNITE)) stop("--r-unite : forme a:b attendue")
if (MODE == "unite" && is.na(OPT_R_UNITE)) stop("--prevol-unite : --r-unite a:b obligatoire")

# --- Chargement du moteur et des outils --------------------------------------
FICHIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) f else NA_character_
})
DOSSIER_SCRIPT <- if (!is.na(FICHIER_SCRIPT)) dirname(FICHIER_SCRIPT) else
  if (file.exists("tests/outils_tests.R")) "tests" else "."
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))

# --- Outils (copies declarees de tests/calibration_mc_mw_t8.R) ---------------
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(basename(extSoftVersion()[["BLAS"]])), txt(basename(La_library())), txt(La_version()))
}
meme_fichier <- function(a, b) !is.na(a) && file.exists(a) && file.exists(b) &&
  identical(normalizePath(a), normalizePath(b))
empreintes_code <- function(script_depot) {
  md5 <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
  lieu <- function(f, ref) if (meme_fichier(f, file.path(RACINE, ref))) "d\u00e9p\u00f4t" else "hors d\u00e9p\u00f4t"
  outils <- file.path(DOSSIER_SCRIPT, "outils_tests.R")
  paste(c(sprintf("R/engine.R %s", md5(file.path(RACINE, "R", "engine.R"))),
          sprintf("tests/outils_tests.R charg\u00e9 (%s) %s", lieu(outils, "tests/outils_tests.R"), md5(outils)),
          sprintf("script ex\u00e9cut\u00e9 (%s) %s", lieu(FICHIER_SCRIPT, script_depot), md5(FICHIER_SCRIPT))),
        collapse = " ; ")
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
D_F <- 4L                                   # decimales des frequences et de leurs intervalles
txt_ic <- function(ci, d = D_F) if (anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", num(ci[1], d), num(ci[2], d))
md5_fichier <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
chemin_cite <- function(f) {
  if (is.na(f) || !file.exists(f)) return(basename(as.character(f)))
  a <- normalizePath(f, winslash = "/", mustWork = TRUE)
  r <- normalizePath(RACINE, winslash = "/", mustWork = TRUE)
  if (startsWith(a, paste0(r, "/"))) substring(a, nchar(r) + 2L) else basename(a)
}
nettoyer_champ <- function(s) gsub("[\t\r\n]+", " ", s)
secondes <- function(t0) as.numeric(difftime(Sys.time(), t0, units = "secs"))
f17 <- function(v) ifelse(is.finite(v), sprintf("%.17g", v), "NA")
chemins_absolus <- function(lignes) {
  k <- grepl("/tmp", lignes, fixed = TRUE) |
    grepl("(^|[ (|`'\"=])(/(home|root|usr|var|mnt|opt|Users|private|srv|media)/|[A-Za-z]:[\\\\/])", lignes, perl = TRUE)
  lignes[k]
}

# --- Triangle d'entree ---------------------------------------------------------
# Meme lecture que .tri de tests/outils_tests.R (format de
# tests/donnees/triangle_mw.csv : colonne i, puis j0 a jJ).
lire_triangle <- function(f) {
  df <- tryCatch(utils::read.csv(f), error = function(e) stop("--triangle : fichier illisible (", conditionMessage(e), ")"))
  if (!"i" %in% names(df)) stop("--triangle : colonne i attendue (format de tests/donnees/triangle_mw.csv)")
  m <- as.matrix(df[, setdiff(names(df), "i"), drop = FALSE])
  storage.mode(m) <- "double"
  unname(m)
}
FICHIER_TRI <- if (is.na(OPT_TRIANGLE)) file.path(RACINE, "tests", "donnees", "triangle_mw.csv") else OPT_TRIANGLE
TRI_IN <- lire_triangle(FICHIER_TRI)
DEFAUT_RESERVE2 <- is.na(OPT_TRIANGLE)
DATE_REF <- if (!is.na(OPT_DATE_REF)) OPT_DATE_REF else DATE_REFERENCE_TESTS
LIBELLE <- if (DEFAUT_RESERVE2) "reserve2" else gsub("[^A-Za-z0-9_-]", "_", sub("[.][^.]*$", "", basename(OPT_TRIANGLE)))

###############################################################################
#  GARDES ANTICIPEES (#205, #173) : evaluees AVANT tout calcul
###############################################################################
DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
NOMS_SORTIE <- c(md = sprintf("%s-issue246-double-bootstrap-%s.md", DATE_SORTIE, LIBELLE),
                 brut = sprintf("%s-issue246-double-bootstrap-%s-brut.tsv", DATE_SORTIE, LIBELLE))
DOSSIER_CIBLE <- if (OPT_ECRIRE) file.path(RACINE, "docs", "tableaux") else OPT_SORTIE
CIBLES <- if (is.na(DOSSIER_CIBLE)) character(0) else stats::setNames(file.path(DOSSIER_CIBLE, NOMS_SORTIE), names(NOMS_SORTIE))
if (MODE == "mesure" && !OPT_ESSAI) {
  nv0 <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT), "de l'ex\u00e9cution")
  if (length(nv0)) {
    message("sortie refusee : ", paste(nv0, collapse = " ; "), " -- lancer sur un arbre propre au commit cite, ou --essai")
    quit(status = 1L)
  }
  if (OPT_ECRIRE) {
    if (!dir.exists(DOSSIER_CIBLE)) stop("dossier de sortie introuvable : docs/tableaux")
    garde_ecrasement(CIBLES, FALSE, RACINE)
  } else {
    if (!dir.exists(OPT_SORTIE)) stop("--sortie : dossier introuvable : ", OPT_SORTIE)
    if (sous_depot(OPT_SORTIE)) stop("--sortie : dossier sous le depot refuse (--ecrire est le seul chemin qui ecrit dans le depot)")
  }
  if (any(file.exists(CIBLES))) stop("sortie refusee : fichier(s) deja present(s), jamais ecrase(s) : ", paste(basename(CIBLES[file.exists(CIBLES)]), collapse = ", "))
}

###############################################################################
#  PROTOCOLE (constantes)
###############################################################################
METHODE <- "reserve2"
ALPHA <- 0.10
# Double, comme le B par defaut de run_engine() : mw_bootstrap() restitue B tel
# quel, et un entier rendrait $bootstrap non identical() a celui de
# run_engine() (champ B de type integer contre double ; controle (i2)).
B_BOOT <- 999
# Plages de graines de #206 pour la loi E (P7), reemployees a dessein : voir
# l'en-tete. Deux affectations de la forme exacte PLAGE_<nom> <- c(L1, L2).
PLAGE_246_TRI <- c(20850001, 20852000)    # triangles r = 1 .. 2000 (graine = borne basse - 1 + r)
PLAGE_246_BOOT <- c(20880001, 20882000)   # bootstraps r = 1 .. 2000 (graine = borne basse - 1 + r)
GRAINE_TRI <- PLAGE_246_TRI[1] - 1
GRAINE_BOOT <- PLAGE_246_BOOT[1] - 1
graine_tri  <- function(r) GRAINE_TRI + r
graine_boot <- function(r) GRAINE_BOOT + r
SEUIL_SD_POP <- 0.05                      # D-3 : alerte si |sd_pop - 1| depasse ce seuil
SEUIL_REFUS <- 0.01                       # P6 : signalement au-dela de 1 % de refus
NIVEAUX_ALPHA <- c(0.10, 0.05)            # P9 : seuils des niveaux produits du meme calcul
# Cles dont la statistique ou le sens a change depuis #206 : comparaison a
# #206 sans objet (Calendrier #276, BP #301, PenteIntra #307, MinP4 #300).
CLES_SANS_206 <- c("Calendrier", "BP", "MinP4", "PenteIntra")
BRUT_297 <- "20261026-issue297-calibration-famille-mw-brut.tsv"
BRUT_206 <- "20261011-issue206-calibration-mw-brut.tsv"
# Oracle du par. 5 du protocole (constat de simulation, loi E, brut de #297, R = 2 000,
# aucune p* manquante) : p_obs de run_engine() a la graine par defaut, et
# #{p* <= p_obs}. N'est qu'un oracle d'implementation (controle (r2)).
ORACLE_R <- 2000L; ORACLE_SEED <- 20260831
ORACLE <- data.frame(
  cle = c("Calendrier", "CorrDev", "BP", "MinP4", "DW", "Runs", "PenteIntra", "Origine", "HomogF", "Courbure", "Alpha", "ExpVar", "KruskalAcc"),
  p_obs = c(0.002, 0.170, 0.285, 0.898, 0.032, 0.374, 0.090, 0.085, 0.080, 0.030, 0.005, 0.428, 0.300),
  k = c(6L, 330L, 593L, 1779L, 65L, 555L, 202L, 173L, 137L, 45L, 7L, 842L, 612L), stringsAsFactors = FALSE)

###############################################################################
#  MODELE AJUSTE, LOI E ET GENERATEUR (P4 a P6)
###############################################################################
# Meme restriction que .run_engine_mw() : cellules i + j > I mises a NA.
TRI_OBS <- TRI_IN
TRI_OBS[row(TRI_OBS) + col(TRI_OBS) - 2L > nrow(TRI_OBS) - 1L] <- NA
DUREE_RE <- NA_real_
if (MODE != "unite") {
  # Point observe (P3) : run_engine() sur le triangle donne ; ok = FALSE : arret motive.
  t_re0 <- Sys.time()
  RES0 <- run_engine(methode = METHODE, triangle = TRI_IN, segment = SEGMENT, annexe = ANNEXE, seed = SEED,
                     date_reference = DATE_REF)
  DUREE_RE <- secondes(t_re0)
  if (!isTRUE(RES0$ok)) {
    message("arret : run_engine() rend ok = FALSE sur ce triangle : ",
            paste(c(RES0$validation$erreurs, "(aucune erreur restituee)")[seq_len(max(1L, length(RES0$validation$erreurs)))], collapse = " ; "))
    quit(status = 1L)
  }
}
AJ0 <- mw_ajuster(TRI_OBS)
JD0 <- .mw_colonnes_degenerees(AJ0)
POOL0 <- .mw_pool_residus(AJ0, JD0)
if (!length(POOL0)) stop("arret : pool de residus vide (aucun residu retenu par mw_residus())")
SD_POP0 <- sqrt(mean((POOL0 - mean(POOL0))^2))
if (!is.finite(SD_POP0) || SD_POP0 <= 0) stop("arret : ecart-type de population du pool nul ou non fini")
POOL_E <- POOL0 / SD_POP0
moments <- function(x) {
  m <- mean(x); s <- sqrt(mean((x - m)^2))
  c(n = length(x), moyenne = m, ecart_type = s, asymetrie = mean((x - m)^3) / s^3,
    exces_kurtosis = mean((x - m)^4) / s^4 - 3, min = min(x), max = max(x))
}
# Tireur des epsilon de la loi E (moyenne 0, variance 1 sur le pool redresse).
tirer_E <- function(n) sample(POOL_E, n, replace = TRUE)
# Generateur : copie de gen_triangle_h0() de tests/calibration_mc_mw_t8.R (meme
# recursion, meme expression, meme ordre de consommation des epsilon, meme arret
# au premier cumul simule non fini ou <= 0, #257). JAMAIS nomme
# mw_simuler_triangle : il masquerait celui du moteur. Le controle (g) en
# prouve l'identite avec mw_simuler_triangle().
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
# Admission d'un triangle simule (P6) : motif de refus, ou ajustement. Copie de
# admettre() de tests/calibration_mc_mw_t8.R, avec les segment et annexe du
# point observe.
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
triangle_r <- function(r) engine_sous_graine(graine_tri(r), gen_triangle_h0(AJ0, tirer_E))

# Cles, sens et motifs d'absence lus au moteur (P3) : jamais figes ici.
CLES <- names(MW_CATALOGUE_MC)
NS <- length(CLES)
QUEUE <- vapply(CLES, function(s) MW_CATALOGUE_MC[[s]]$queue, "")
CODES_MOTIF <- c(o = MOTIF_MC_OBS_NON_FINIE, z = MOTIF_MC_AUCUNE_REPLIC, i = MOTIF_MC_REPLIC_INSUFFISANTES,
                 d = MOTIF_MC_DISPERSION_NULLE, c = MOTIF_MC_CONDITION, a = MOTIF_MC_ATOME_HORS_OBS)
code_motif <- function(m) ifelse(is.na(m), "-", ifelse(m %in% CODES_MOTIF, names(CODES_MOTIF)[match(m, CODES_MOTIF)], "?"))

# Ligne r (P8) : triangle simule sous E (graine du triangle), admission,
# mw_bootstrap() a B = 999 (graine du bootstrap), puis mw_tests() a alpha =
# 0,10, avec les memes ensembles figes que run_engine() (.run_engine_mw()).
# Par cle : p*, err_mc, B effectif, motif (code) ; plus cumuls_retires et
# plafond_cumuls. complet = TRUE garde le triangle, $bootstrap et $tests
# (controles (i2) et (rep)).
traiter_r <- function(r, complet = FALSE) {
  t0 <- Sys.time()
  tri <- triangle_r(r)
  ad <- admettre(tri)
  if (!ad$ok) return(list(r = r, statut = "refuse", motif = ad$motif, duree = secondes(t0)))
  aj <- ad$aj
  figes <- .mw_ensembles_figes(aj)
  bt <- mw_bootstrap(aj, B = B_BOOT, seed = graine_boot(r), figes = figes)
  te <- mw_tests(aj, bt, ALPHA, figes = figes)
  out <- list(r = r, statut = "admis", motif = NA_character_,
              p = unname(bt$p_mc[CLES]), e = unname(bt$err_mc[CLES]), B = unname(bt$B_effectif[CLES]),
              m = unname(code_motif(bt$motif_mc[CLES])),
              cumuls_retires = isTRUE(bt$cumuls_retires), plafond_cumuls = isTRUE(bt$plafond_cumuls),
              noms_ok = identical(names(bt$p_mc), CLES) && identical(names(bt$err_mc), CLES) &&
                identical(names(bt$B_effectif), CLES) && identical(names(bt$motif_mc), CLES),
              duree = secondes(t0))
  if (complet) { out$tri <- tri; out$bt <- bt; out$te <- te }
  out
}
ligne_cmp <- function(l) l[setdiff(names(l), c("duree", "tri", "bt", "te"))]

# Processus : mclapply, ordonnancement dynamique (une replication par tache) ;
# le resultat ne depend pas du nombre de processus (une ligne ne depend que de
# r et de ses graines, engine_sous_graine() restaurant l'etat de l'appelant).
N_PROC <- if (.Platform$OS.type == "windows") 1L else if (is.na(N_COEURS)) {
  dc <- parallel::detectCores(); if (is.na(dc)) 1L else max(1L, min(4L, dc))
} else N_COEURS
if (.Platform$OS.type == "windows" && !is.na(N_COEURS) && N_COEURS > 1L)
  message("--coeurs ignore sous Windows (mclapply) : un processus")
appliquer <- function(X, f) {
  g <- function(x) tryCatch(f(x), error = function(e) list(r = x, statut = "erreur", motif = nettoyer_champ(conditionMessage(e)), duree = NA_real_))
  res <- if (N_PROC > 1L) parallel::mclapply(X, g, mc.cores = N_PROC, mc.preschedule = FALSE) else lapply(X, g)
  # un processus de travail mort rend un objet qui n'est pas une liste
  mapply(function(x, y) if (is.list(y)) y else list(r = x, statut = "erreur", motif = "processus de travail interrompu", duree = NA_real_),
         X, res, SIMPLIFY = FALSE, USE.NAMES = FALSE)
}

###############################################################################
#  MODE INTERNE --prevol-unite : une unite de debit (mw_bootstrap() + mw_tests())
###############################################################################
if (MODE == "unite") {
  m <- as.integer(strsplit(OPT_R_UNITE, ":", fixed = TRUE)[[1]])
  for (r in seq.int(m[1], m[2])) {
    ad <- admettre(triangle_r(r))
    if (!ad$ok) { writeLines(sprintf("REFUS\t%d", r)); next }
    t1 <- Sys.time(); fg <- .mw_ensembles_figes(ad$aj)
    bt <- mw_bootstrap(ad$aj, B = B_BOOT, seed = graine_boot(r), figes = fg); d_b <- secondes(t1)
    invisible(mw_tests(ad$aj, bt, ALPHA, figes = fg))      # cache de la loi nulle de Shapiro-Wilk
    t2 <- Sys.time(); invisible(mw_tests(ad$aj, bt, ALPHA, figes = fg)); d_t <- secondes(t2)
    writeLines(sprintf("UNITE\t%d\t%.3f\t%.3f\t%.3f", r, d_b + d_t, d_b, d_t))
  }
  writeLines("FIN")
  quit(status = 0L)
}

###############################################################################
#  CONTROLES D'INTEGRITE (P11)
###############################################################################
COMMIT <- commit_depot(SCRIPT)
EMPREINTES <- empreintes_code(SCRIPT)
EMPREINTE_SC <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
MD5_MOTEUR <- md5_fichier(file.path(RACINE, "R", "engine.R"))
INTEGRITE <- character(0); CONTROLES <- character(0)
controle <- function(ok, libelle) {
  ok <- isTRUE(ok)
  if (!ok) INTEGRITE <<- c(INTEGRITE, libelle)
  CONTROLES <<- c(CONTROLES, sprintf("%s : %s", libelle, if (ok) "OK" else "\u00c9CHEC"))
  invisible(ok)
}
# (g) : generateur identique a mw_simuler_triangle() sous la meme graine (100
# graines des triangles, r = 1 a 100) ; volet sous pool dilate (#271) : sur les
# memes graines, epsilon tires dans un pool multiplie par un facteur de
# FACTEURS_G_DILATE (le premier qui rend au moins un triangle a cumul simule
# non fini ou <= 0 ; 30 sur reserve2 selon #206), exige l'identite ET au moins
# un tel triangle, sans quoi l'arret au premier cumul invalide (#257) ne serait
# pas exerce ; fonctions du moteur de l'environnement identiques a celles de
# R/engine.R relu (formals et body).
FACTEURS_G_DILATE <- c(30, 100, 300, 1000)
controle_g <- function() {
  meme_g <- function(pool) vapply(seq_len(100), function(i) {
    g <- graine_tri(i)
    a <- engine_sous_graine(g, gen_triangle_h0(AJ0, function(n) sample(pool, n, replace = TRUE)))
    b <- engine_sous_graine(g, mw_simuler_triangle(AJ0, pool))
    c(identique = identical(a, b), incomplet = .mw_triangle_incomplet(b))
  }, logical(2))
  ok <- meme_g(POOL0)["identique", ]
  for (fd in FACTEURS_G_DILATE) { dil <- meme_g(fd * POOL0); if (any(dil["incomplet", ])) break }
  e0 <- new.env()
  sys.source(file.path(RACINE, "R", "engine.R"), envir = e0, keep.source = FALSE)
  env_m <- environment(mw_bootstrap)
  meme <- function(nm) { a <- get(nm, envir = env_m); b <- get(nm, envir = e0)
    identical(formals(a), formals(b)) && identical(body(a), body(b)) }
  fns <- c("mw_simuler_triangle", ".mw_simuler_triangle_etat", ".mw_tirer_triangle_valide", ".mw_triangle_incomplet",
           ".mw_pool_residus", "mw_bootstrap")
  ok_fns <- all(vapply(fns, meme, logical(1)))
  list(ok = all(ok) && all(dil["identique", ]) && any(dil["incomplet", ]) && ok_fns,
       txt = sprintf("gen_triangle_h0() (\u03b5 tir\u00e9s par sample(pool)) = mw_simuler_triangle() sous la m\u00eame graine, identical(), sur %d / 100 graines (triangles r = 1..100) ; sous pool dilat\u00e9 %g fois (#271) : %d / 100, dont %d triangle(s) \u00e0 cumul simul\u00e9 non fini ou \u2264 0 (au moins un exig\u00e9) ; %s de l'environnement identiques (formals, body) \u00e0 celles de R/engine.R relu : %s",
                     sum(ok), fd, sum(dil["identique", ]), sum(dil["incomplet", ]), paste(fns, collapse = ", "), if (ok_fns) "oui" else "NON"))
}
# (m) : aucune occurrence du nom du script dans R/, app.R, .github/.
controle_m <- function() {
  fs <- c(list.files(file.path(RACINE, "R"), recursive = TRUE, full.names = TRUE),
          file.path(RACINE, "app.R"),
          list.files(file.path(RACINE, ".github"), recursive = TRUE, full.names = TRUE, all.files = TRUE))
  fs <- fs[file.exists(fs) & !dir.exists(fs)]
  lit <- function(f) tryCatch(readLines(f, warn = FALSE, skipNul = TRUE), error = function(e) NA_character_)
  trouve <- fs[vapply(fs, function(f) { x <- lit(f); anyNA(x) || any(grepl("double_bootstrap_mw", x, fixed = TRUE)) }, logical(1))]
  list(ok = !length(trouve),
       txt = sprintf("aucune occurrence de \u00ab double_bootstrap_mw \u00bb dans R/, app.R et .github/ (%d fichiers lus) ; fichier(s) en d\u00e9faut : %s",
                     length(fs), if (length(trouve)) paste(chemin_cite(trouve), collapse = ", ") else "aucun"))
}

###############################################################################
#  MODE --prevol (P12) : rien d'ecrit
###############################################################################
# Debit a 1, 2, 3 et 4 processus concurrents (--prevol-unite) : duree de
# l'unite (mw_bootstrap() + mw_tests(), cache de Shapiro-Wilk chaud) mesuree
# dans chacun des k processus, UNITES triangles par processus.
mesurer_debit <- function() {
  RSCRIPT <- file.path(R.home("bin"), "Rscript")
  if (is.na(FICHIER_SCRIPT)) stop("--prevol : chemin du script introuvable (lancer par Rscript)")
  dossier <- tempfile("prevol246_"); dir.create(dossier)
  on.exit(unlink(dossier, recursive = TRUE))
  # arguments de l'enfant : ceux du parent, sans --prevol ni --unites
  base <- ARGS; k0 <- which(base == "--unites"); if (length(k0)) base <- base[-c(k0, k0 + 1L)]
  base <- setdiff(base, "--prevol")
  CB <- list()
  for (k in 1:4) {
    fs <- file.path(dossier, sprintf("k%d-%d.txt", k, seq_len(k)))
    for (i in seq_len(k)) {
      r1 <- (i - 1L) * UNITES + 1L
      system2(RSCRIPT, c(shQuote(FICHIER_SCRIPT), shQuote(base), "--prevol-unite", "--r-unite", sprintf("%d:%d", r1, r1 + UNITES - 1L)),
              stdout = fs[i], stderr = sub("\\.txt$", ".err", fs[i]), wait = FALSE)
    }
    t_lim <- Sys.time() + 3600
    repeat {
      fini <- vapply(fs, function(f) file.exists(f) && any(readLines(f, warn = FALSE) == "FIN"), logical(1))
      if (all(fini) || Sys.time() > t_lim) break
      Sys.sleep(2)
    }
    if (!all(fini)) stop("--prevol : unite(s) de debit non terminee(s) en 1 h (k = ", k, ")")
    CB[[k]] <- unlist(lapply(fs, function(f) { x <- grep("^UNITE\t", readLines(f), value = TRUE); as.numeric(vapply(strsplit(x, "\t"), `[`, "", 3L)) }))
  }
  CB
}
# Echantillon des controles (i2) et (rep) : premier r admis, dernier r admis et
# 5 r regulierement repartis parmi les r admis.
echantillon_controles <- function(r_adm) if (!length(r_adm)) integer(0) else
  r_adm[unique(round(seq(1, length(r_adm), length.out = 7)))]

if (MODE == "prevol") {
  ecrire_console(c("## Pr\u00e9-vol du double bootstrap Merz-W\u00fcthrich, #246 (rien d'\u00e9crit)", "",
                   sprintf("Commit : %s ; plateforme : %s ; c\u0153urs (parallel::detectCores()) : %s ; d\u00e9but %s UTC", COMMIT, plateforme_calcul(),
                           tryCatch(parallel::detectCores(), error = function(e) "?"), format(Sys.time(), "%Y-%m-%dT%H:%M:%S", tz = "UTC")), "",
                   sprintf("Triangle : %s (%d \u00d7 %d) ; segment %g, annexe %s ; R = %d ; run_engine() sur ce triangle : %s s (point observ\u00e9 ; \u00ab ok \u00bb).",
                           if (DEFAUT_RESERVE2) "reserve2 (tests/donnees/triangle_mw.csv)" else chemin_cite(OPT_TRIANGLE),
                           AJ0$I + 1L, AJ0$J + 1L, SEGMENT, ANNEXE, R_TOT, num(DUREE_RE, 1)), ""))
  # 1. Motifs de refus des R triangles (P6).
  t0 <- Sys.time()
  mo <- vapply(seq_len(R_TOT), function(r) admettre(triangle_r(r))$motif, "")
  d_adm <- secondes(t0); rf <- !is.na(mo)
  ecrire_console(c("### Triangles simul\u00e9s : admission (motifs de refus)", "", entete_md(c("triangles", "refus\u00e9s", "motifs", "s par triangle")),
                   ligne_md(R_TOT, sum(rf), if (any(rf)) { t <- table(mo[rf]); paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") } else "aucun",
                            num(d_adm / R_TOT, 4)), ""))
  # 2. Couts fixes : controles (g), empreinte, lecture des bruts.
  invisible(mw_tests(AJ0, mw_bootstrap(AJ0, B = 20L, seed = SEED), ALPHA))     # cache de Shapiro-Wilk
  t0 <- Sys.time(); invisible(controle_g()); invisible(controle_m())
  invisible(empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))); c_ctl <- secondes(t0)
  # 3. Debit a 1, 2, 3 et 4 processus.
  CB <- mesurer_debit()
  c_b <- mean(CB[[1]])
  P_k <- vapply(1:4, function(k) k * c_b / mean(CB[[k]]), 1)
  ecrire_console(c("### D\u00e9bit", "",
                   sprintf("c_b (mw_bootstrap() \u00e0 B = 999 + mw_tests(), un processus, %d unit\u00e9(s)) : %s s ; run_engine() sur le triangle : %s s ; contr\u00f4les l\u00e9gers ((g), (m), empreinte) : %s s.",
                           length(CB[[1]]), num(c_b, 2), num(DUREE_RE, 2), num(c_ctl, 1)), "",
                   entete_md(c("processus concurrents", "dur\u00e9e par unit\u00e9 (s) : moyenne [min ; max]", "d\u00e9bit agr\u00e9g\u00e9 P_k = k c_b / moyenne")),
                   vapply(1:4, function(k) ligne_md(k, sprintf("%s [%s ; %s]", num(mean(CB[[k]]), 2), num(min(CB[[k]]), 2), num(max(CB[[k]]), 2)), num(P_k[k], 3)), ""), ""))
  # 4. Duree prevue : F_k + R c_b / P_k, avec F_k = point observe (run_engine()) + chemin direct
  # de (i1) + controles legers + echantillon de (i2) et (rep) (7 lignes, chacune c_b + run_engine(),
  # au debit P_k), le tout en secondes d'horloge.
  n_ech <- min(7L, R_TOT)
  F_k <- function(k) DUREE_RE + c_b + c_ctl + n_ech * (c_b + DUREE_RE) / P_k[k]
  duree_h <- function(R, k) (F_k(k) + R * c_b / P_k[k]) / 3600
  k_run <- min(4L, N_PROC)
  ecrire_console(c("### Dur\u00e9e pr\u00e9vue (h d'horloge)", "",
                   entete_md(c("processus", "F (s) : observ\u00e9, (i1), (g), (i2), (rep)", "R = 1 000", "R = 2 000")),
                   vapply(1:4, function(k) ligne_md(if (k == k_run) sprintf("**%d**", k) else k, num(F_k(k), 0), num(duree_h(1000, k), 2), num(duree_h(2000, k), 2)), ""), "",
                   sprintf("Processus du lancement (--coeurs, d\u00e9faut min(4, detectCores())) : %d%s. Dur\u00e9e pr\u00e9vue \u00e0 R = %d : **%s h**. Extrapolation lin\u00e9aire en R du d\u00e9bit mesur\u00e9 sur %d triangle(s) par processus ; la dur\u00e9e r\u00e9elle d\u00e9pend aussi de la charge de la machine.",
                           N_PROC, if (N_PROC > 4L) " (au-del\u00e0 de 4 : d\u00e9bit non mesur\u00e9, ligne k = 4 retenue)" else "", R_TOT, num(duree_h(R_TOT, k_run), 2), UNITES), ""))
  ecrire_console(c("### Ligne \u00e0 reporter (--debit-prevol)", "", "```",
                   sprintf("pr\u00e9-vol du %s, commit %s : c_b = %s s, run_engine() = %s s, P_k = %s ; dur\u00e9e pr\u00e9vue \u00e0 %d processus : %s h (R = 1 000), %s h (R = 2 000)",
                           format(Sys.time(), "%Y-%m-%d", tz = "UTC"), substr(COMMIT, 1, 7), num(c_b, 2), num(DUREE_RE, 1),
                           paste(vapply(P_k, num, "", d = 3), collapse = " / "), k_run, num(duree_h(1000, k_run), 2), num(duree_h(2000, k_run), 2)), "```"))
  quit(status = 0L)
}

# --- Point observe : p_obs, err_mc et nature de la p retenue (P3) ----------------
BOOT0 <- RES0$bootstrap
controle(identical(names(BOOT0$p_mc), CLES) && identical(names(BOOT0$err_mc), CLES) && identical(names(BOOT0$B_effectif), CLES),
         sprintf("(cat) les %d cl\u00e9s de $bootstrap du point observ\u00e9 sont celles de MW_CATALOGUE_MC, dans le m\u00eame ordre (noms et sens lus au catalogue)", NS))
P_OBS <- BOOT0$p_mc[CLES]; E_OBS <- BOOT0$err_mc[CLES]
info_cle <- function(k) {
  idx <- which(vapply(RES0$tests, function(t) identical(t$mc_nom, k), logical(1)))
  if (length(idx) != 1L) return(list(retenue = FALSE, nature = sprintf("%d ligne(s) de mw_tests() pour cette cl\u00e9", length(idx)), verdict = NA_character_, sens = NA_character_))
  l <- RES0$tests[[idx]]
  retenue <- identical(l$type, "test") && isFALSE(l$inoperant) && is.finite(l$p_retenue) && is.finite(P_OBS[[k]]) &&
    identical(unname(l$p_retenue), unname(P_OBS[[k]]))
  nature <- if (retenue) sprintf("p_mc retenue (%s)", l$verdict) else if (isTRUE(l$inoperant)) "test inop\u00e9rant : p_mc non retenue" else
    if (identical(l$type, "diagnostic")) "diagnostic : p_mc non retenue" else "p_mc non retenue"
  list(retenue = retenue, nature = nature, verdict = l$verdict, sens = l$sens)
}
INFO <- stats::setNames(lapply(CLES, info_cle), CLES)

# (i1) : point observe, run_engine() contre le chemin direct (memes ensembles
# figes, meme graine). p_obs en particulier, puis les deux objets entiers ;
# l'ajustement de run_engine() contre mw_ajuster(triangle restreint).
chemin_direct_obs <- function() {
  fg <- .mw_ensembles_figes(AJ0)
  bt <- mw_bootstrap(AJ0, B = 999, seed = SEED, figes = fg)
  list(bt = bt, te = mw_tests(AJ0, bt, ALPHA, figes = fg))
}
DIR0 <- chemin_direct_obs()
controle(identical(P_OBS, DIR0$bt$p_mc[CLES]) && identical(RES0$bootstrap, DIR0$bt) && identical(RES0$tests, DIR0$te) &&
           identical(RES0$ajustement, AJ0),
         sprintf("(i1) point observ\u00e9 : p_obs lue dans run_engine() identique \u00e0 celle de mw_bootstrap() + mw_tests() (m\u00eames ensembles fig\u00e9s, graine %.0f), identical() sur p_obs, $bootstrap, $tests et l'ajustement", SEED))
cg <- controle_g(); controle(cg$ok, paste("(g)", cg$txt))
cm <- controle_m(); controle(cm$ok, paste("(m)", cm$txt))
if (length(INTEGRITE)) {
  ecrire_console(c("## INTEGRITE ECHEC avant tout tirage du plan (P11)", "", paste0("- ", CONTROLES), "",
                   sprintf("INTEGRITE ECHEC : %s", paste(INTEGRITE, collapse = " ; "))))
  quit(status = 1L)
}

###############################################################################
#  CALCUL DES R LIGNES (P8)
###############################################################################
message("double bootstrap #246 : ", N_PROC, " processus ; R = ", R_TOT, " triangles ; B = ", B_BOOT)
t_calc <- Sys.time()
LIGNES <- appliquer(seq_len(R_TOT), function(r) {
  l <- traiter_r(r)
  if (r %% 50L == 0L) message(sprintf("  r = %d traite (%s)", r, format(Sys.time(), "%H:%M:%S")))
  l
})
DUREE_CALC <- secondes(t_calc)
STATUTS <- vapply(LIGNES, function(l) l$statut, "")
controle(!any(STATUTS == "erreur"), sprintf("(erreur) aucune ligne en erreur : %d ligne(s) en erreur%s", sum(STATUTS == "erreur"),
         if (any(STATUTS == "erreur")) paste0(" (", paste(unique(vapply(LIGNES[STATUTS == "erreur"], function(l) l$motif, "")), collapse = " ; "), ")") else ""))
if (!any(STATUTS == "admis")) {
  ecrire_console(c("## INTEGRITE ECHEC : aucun triangle admis", "", paste0("- ", CONTROLES)))
  quit(status = 1L)
}
ADM <- LIGNES[STATUTS == "admis"]
R_ADM <- length(ADM)
R_REFUS <- sum(STATUTS == "refuse")
MOTIFS_REFUS <- if (R_REFUS) { t <- table(vapply(LIGNES[STATUTS == "refuse"], function(l) l$motif, "")); paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") } else "aucun"
controle(all(vapply(ADM, function(l) isTRUE(l$noms_ok), logical(1))), "(noms) les champs $p_mc, $err_mc, $B_effectif et $motif_mc de chaque ligne portent les cl\u00e9s du catalogue dans l'ordre")
P_STAR <- do.call(rbind, lapply(ADM, function(l) l$p)); colnames(P_STAR) <- CLES

# (i2) et (rep) sur l'echantillon : chemin du script recalcule ici (maitre, ou
# processus de travail propre a la tache), run_engine() sur le triangle simule.
R_ECH <- echantillon_controles(vapply(ADM, function(l) l$r, 1L))
ctl_ech <- appliquer(R_ECH, function(r) {
  a <- traiter_r(r, complet = TRUE)
  re <- run_engine(methode = METHODE, triangle = a$tri, segment = SEGMENT, annexe = ANNEXE, seed = graine_boot(r), date_reference = DATE_REF)
  list(r = r, statut = "ok", ok_re = isTRUE(re$ok), i2_tests = identical(re$tests, a$te), i2_boot = identical(re$bootstrap, a$bt),
       rep = identical(ligne_cmp(a), ligne_cmp(LIGNES[[r]])))
})
ech_ok <- function(champ) all(vapply(ctl_ech, function(x) identical(x$statut, "ok") && isTRUE(x[[champ]]), logical(1)))
controle(ech_ok("ok_re") && ech_ok("i2_tests") && ech_ok("i2_boot"),
         sprintf("(i2) %d ligne(s) (r = %s) : run_engine(triangle = tri_r, seed = graine du bootstrap de r) donne $tests et $bootstrap identical() au chemin du script",
                 length(R_ECH), paste(R_ECH, collapse = ", ")))
controle(ech_ok("rep"),
         sprintf("(rep) les m\u00eames %d ligne(s), recalcul\u00e9es dans une seconde passe (t\u00e2ches distinctes de la boucle principale), redonnent la ligne calcul\u00e9e dans la boucle, hors dur\u00e9e (identical()) ; deux ex\u00e9cutions et --coeurs 1 contre --coeurs 4 : comparer les sorties hors section \u00ab Ex\u00e9cution \u00bb",
                 length(R_ECH)))

# (r2) : reserve2 retrouvee (comptes identiques aux bruts de #297 et #206, oracle du par. 5).
R2_APPLICABLE <- identical(TRI_IN, .tri) && SEGMENT == 1 && identical(ANNEXE, "II")
lire_brut <- function(nom) {
  f <- file.path(RACINE, "docs", "tableaux", nom)
  if (!file.exists(f)) return(NULL)
  utils::read.delim(f, colClasses = "character", check.names = FALSE, quote = "", comment.char = "", stringsAsFactors = FALSE)
}
# Compare, sur r <= R, les p* de la loi E d'un brut a celles de ce calcul : vecteurs
# (identical, NA aux memes places) et comptes #{p* <= p_obs}.
comparer_brut <- function(br, cles) {
  E <- br[br$type == "rep" & br$loi == "E", , drop = FALSE]
  E <- E[order(as.integer(E$b)), , drop = FALSE]
  E <- E[as.integer(E$b) <= R_TOT, , drop = FALSE]
  ok_b <- identical(as.integer(E$b), seq_len(R_TOT))
  ok_adm <- ok_b && identical(unname(E$statut == "admis"), unname(STATUTS == "admis"))
  mien <- function(k) vapply(LIGNES, function(l) if (l$statut == "admis") l$p[match(k, CLES)] else NA_real_, 1)
  res <- lapply(cles, function(k) {
    col <- paste0("pR:", k)
    if (!ok_b || !col %in% names(E)) return(list(cle = k, ok = FALSE, k_mien = NA_integer_, k_brut = NA_integer_, texte = "colonne ou lignes absentes"))
    vb <- suppressWarnings(as.numeric(E[[col]])); vm <- mien(k)
    kb <- sum(vb <= P_OBS[[k]], na.rm = TRUE); km <- sum(vm <= P_OBS[[k]], na.rm = TRUE)
    list(cle = k, ok = identical(vb, vm) && kb == km, k_mien = km, k_brut = kb, texte = "")
  })
  list(ok = ok_adm && all(vapply(res, function(x) x$ok, NA)), ok_adm = ok_adm, n = nrow(E), res = res)
}
R2_LIGNES <- character(0)
if (!R2_APPLICABLE) {
  controle(TRUE, "(r2) sans objet : triangle, segment ou annexe diff\u00e9rents de reserve2 (aucune base de comparaison aux bruts de #297 et #206)")
} else {
  b297 <- lire_brut(BRUT_297); b206 <- lire_brut(BRUT_206)
  CLES_206 <- setdiff(CLES, CLES_SANS_206)
  if (is.null(b297) || is.null(b206)) {
    controle(FALSE, sprintf("(r2) brut introuvable dans docs/tableaux/ : %s", paste(c(BRUT_297[is.null(b297)], BRUT_206[is.null(b206)]), collapse = ", ")))
  } else {
    c297 <- comparer_brut(b297, CLES)
    c206 <- comparer_brut(b206, CLES_206)
    controle(c297$ok, sprintf("(r2) r <= %d : statuts d'admission, vecteurs de p* et comptes #{p* \u2264 p_obs} identiques au brut de #297 (%s, lignes rep, loi E, colonnes pR:<cl\u00e9>) pour les %d cl\u00e9s : %d / %d cl\u00e9s identiques%s",
                              R_TOT, BRUT_297, NS, sum(vapply(c297$res, function(x) x$ok, NA)), NS, if (c297$ok_adm) "" else " ; statuts d'admission DIFF\u00c9RENTS"))
    controle(c206$ok, sprintf("(r2) r <= %d : idem au brut de #206 (%s) pour les %d cl\u00e9s dont la statistique est inchang\u00e9e depuis #206 (%s) : %d / %d identiques%s",
                              R_TOT, BRUT_206, length(CLES_206), paste(CLES_206, collapse = ", "), sum(vapply(c206$res, function(x) x$ok, NA)), length(CLES_206),
                              if (c206$ok_adm) "" else " ; statuts d'admission DIFF\u00c9RENTS"))
    R2_LIGNES <- c(entete_md(c("Cl\u00e9", "#297 : comptes (ce calcul / brut)", "#297 : vecteur de p* identique", "#206 : comptes (ce calcul / brut)", "#206 : vecteur de p* identique")),
                   vapply(CLES, function(k) {
                     a <- c297$res[[match(k, CLES)]]
                     j <- match(k, CLES_206)
                     b <- if (is.na(j)) NULL else c206$res[[j]]
                     ligne_md(k, sprintf("%d / %d", a$k_mien, a$k_brut), if (a$ok) "oui" else "NON",
                              if (is.null(b)) "sans objet (statistique ou sens chang\u00e9 depuis #206)" else sprintf("%d / %d", b$k_mien, b$k_brut),
                              if (is.null(b)) "\u2014" else if (b$ok) "oui" else "NON")
                   }, ""))
    # Oracle du par. 5 : R = 2 000, graine par defaut.
    if (R_TOT == ORACLE_R && SEED == ORACLE_SEED) {
      k_orc <- vapply(ORACLE$cle, function(k) sum(P_STAR[, k] <= P_OBS[[k]], na.rm = TRUE), 1L)
      ok_orc <- setequal(ORACLE$cle, CLES) && R_ADM == ORACLE_R && !anyNA(P_STAR) &&
        all(abs(vapply(ORACLE$cle, function(k) P_OBS[[k]], 1) - ORACLE$p_obs) < 5e-4) && identical(unname(k_orc), ORACLE$k)
      controle(ok_orc, sprintf("(r2) R = %d, graine %.0f : p_obs et comptes #{p* \u2264 p_obs} de l'oracle du par. 5 du protocole retrouv\u00e9s (p_obs au point de grille pr\u00e8s, 5e-4 ; comptes exacts ; aucune p* manquante, %d / %d cl\u00e9s)",
                               ORACLE_R, ORACLE_SEED, sum(unname(k_orc) == ORACLE$k), nrow(ORACLE)))
    } else {
      CONTROLES <- c(CONTROLES, sprintf("(r2) oracle du par. 5 du protocole : sans objet (valable \u00e0 R = %d et graine %.0f ; ici R = %d, graine %.0f)", ORACLE_R, ORACLE_SEED, R_TOT, SEED))
    }
  }
}

###############################################################################
#  FREQUENCES, NIVEAUX, BANDE (P9)
###############################################################################
resume_cle <- function(k) {
  v <- P_STAR[, k]; po <- P_OBS[[k]]; er <- E_OBS[[k]]
  n <- length(v); n_na <- sum(is.na(v)); fini <- is.finite(po)
  k_le <- if (fini) sum(v <= po, na.rm = TRUE) else NA_integer_      # p* absente : pas un "<="
  k_lt <- if (fini) sum(v < po, na.rm = TRUE) else NA_integer_
  band <- if (fini && is.finite(er)) c(sum(v <= po - 2 * er, na.rm = TRUE), sum(v <= po + 2 * er, na.rm = TRUE)) / n else c(NA_real_, NA_real_)
  niveaux <- lapply(NIVEAUX_ALPHA, function(a) {
    ks <- c(sum(v < a / 2, na.rm = TRUE), sum(v < a, na.rm = TRUE))
    list(alpha = a, k = ks, ic = lapply(ks, ic_cp, n = n))
  })
  list(cle = k, p_obs = po, err = er, n = n, n_na = n_na, k_le = k_le, k_lt = k_lt,
       F = if (fini) k_le / n else NA_real_, ic = if (fini) ic_cp(k_le, n) else c(NA_real_, NA_real_),
       F_def = if (fini && n > n_na) k_le / (n - n_na) else NA_real_, band = band, niveaux = niveaux)
}
RES_CLES <- stats::setNames(lapply(CLES, resume_cle), CLES)

###############################################################################
#  MARKDOWN DE LA SORTIE
###############################################################################
TXT_STATUT <- c(
  "La fr\u00e9quence produite pour chaque cl\u00e9 vaut F\u0302\\*(p_obs) = #{r admis : p\\*_r \u2264 p_obs} / R_admis. C'est un **constat de simulation**, obtenu sous trois conditions : le mod\u00e8le de Mack ajust\u00e9 au triangle donn\u00e9 (f\u0302, \u03c3\u0302\u00b2, premi\u00e8re colonne fix\u00e9e), la loi d'erreurs E, et T = 8. Elle estime la probabilit\u00e9, dans ce mod\u00e8le et sous cette loi, que la p de Monte-Carlo du moteur soit au plus \u00e9gale \u00e0 la p observ\u00e9e.",
  "",
  "Ce qu'elle n'est pas :",
  "- ce n'est pas une p exacte ;",
  "- ce n'est pas une p retenue, et elle n'entre dans aucun verdict ;",
  "- elle ne vaut pas au-del\u00e0 de ce mod\u00e8le et de cette loi.",
  "",
  "Trois sources d'erreur sont \u00e0 distinguer :",
  "- (i) l'erreur Monte-Carlo de F\u0302\\*, fonction de R, encadr\u00e9e par l'intervalle de Clopper-Pearson ;",
  "- (ii) l'erreur Monte-Carlo de p_obs, fonction de B ;",
  "- (iii) l'erreur de substitution : \u03b8\u0302 remplace \u03b8, et E remplace la vraie loi. L'outil ne quantifie pas (iii).",
  "",
  "Aucun r\u00e9sultat exact ni aucune r\u00e9f\u00e9rence relue ne dit que F\u0302\\*(p_obs) est mieux calibr\u00e9e que p_obs \u00e0 T = 8. Les mesures de #206 et #297 montrent au contraire que le niveau d\u00e9pend fortement de la loi des erreurs. Une fr\u00e9quence \u00e9lev\u00e9e n'est pas une preuve d'ad\u00e9quation : la puissance n'est pas \u00e9tudi\u00e9e.")
args_citees <- function() {
  a <- ARGS
  i <- match("--coeurs", a); if (!is.na(i)) a <- a[-c(i, i + 1L)]
  i <- match("--debit-prevol", a); if (!is.na(i)) a <- a[-c(i, i + 1L)]
  i <- match("--triangle", a); if (!is.na(i)) a[i + 1L] <- chemin_cite(a[i + 1L])
  i <- match("--sortie", a); if (!is.na(i)) a[i + 1L] <- "(dossier hors d\u00e9p\u00f4t)"
  if (length(a)) paste(a, collapse = " ") else "(aucun : valeurs par d\u00e9faut)"
}
M_POOL <- moments(POOL0)
ALERTES <- c(
  if (R_REFUS / R_TOT > SEUIL_REFUS) sprintf("**ALERTE REFUS** : %d triangle(s) simul\u00e9(s) refus\u00e9(s) sur %d (%s %%, au-del\u00e0 de 1 %%) : %s.", R_REFUS, R_TOT, num(100 * R_REFUS / R_TOT, 2), MOTIFS_REFUS),
  if (abs(SD_POP0 - 1) > SEUIL_SD_POP) sprintf("**ALERTE POOL** : |sd_pop \u2212 1| = %s > %s ; la loi E diff\u00e8re de celle du bootstrap interne (pool non r\u00e9duit) par un facteur d'\u00e9chelle sd_pop sensible.", num(abs(SD_POP0 - 1), 4), num(SEUIL_SD_POP, 2)),
  if (any(is.na(P_STAR))) sprintf("**P* ABSENTES** : %d valeur(s) de p* absente(s) sur %d ; compt\u00e9es comme non-\u00ab \u2264 \u00bb (colonne \u00ab p* absentes \u00bb, fr\u00e9quence restreinte aux p d\u00e9finies en colonne descriptive).", sum(is.na(P_STAR)), length(P_STAR)),
  if (any(!is.finite(P_OBS))) sprintf("**P_OBS ABSENTE** pour : %s (fr\u00e9quence non d\u00e9finie).", paste(CLES[!is.finite(P_OBS)], collapse = ", ")),
  if (AJ0$I + 1L != 8L) sprintf("**T \u2260 8** : ce triangle compte %d ann\u00e9es d'accident ; le texte de statut ci-dessus vise T = 8 et ses conditions ne valent pas \u00e0 cette taille sans examen.", AJ0$I + 1L),
  if (any(vapply(INFO, function(x) identical(x$sens, "rejeter"), NA))) sprintf("**SENS \u00ab REJETER \u00bb** pour : %s ; les niveaux ci-dessous appliquent les seuils \u00ab ne pas rejeter \u00bb (\u03b1/2, \u03b1) et n'y sont pas ceux du verdict.", paste(CLES[vapply(INFO, function(x) identical(x$sens, "rejeter"), NA)], collapse = ", ")))
construire_md <- function() {
  prov <- c(entete_md(c("Grandeur", "Valeur")),
            ligne_md("Commit", COMMIT),
            ligne_md("Empreinte sans commentaires de R/engine.R (#231)", sprintf("%s (md5 du fichier entier %s)", EMPREINTE_SC, MD5_MOTEUR)),
            ligne_md("Code ex\u00e9cut\u00e9 (md5)", EMPREINTES),
            ligne_md("Triangle", sprintf("%s (md5 %s) ; %d \u00d7 %d ; segment %g, annexe %s, date de r\u00e9f\u00e9rence %s", if (DEFAUT_RESERVE2) "tests/donnees/triangle_mw.csv" else chemin_cite(OPT_TRIANGLE),
                                          md5_fichier(FICHIER_TRI), AJ0$I + 1L, AJ0$J + 1L, SEGMENT, ANNEXE, DATE_REF)),
            ligne_md("Mode", if (OPT_ESSAI) "**ESSAI** (console, non versionnable)" else if (OPT_ECRIRE) "\u00e9criture dans docs/tableaux/ (--ecrire)" else "\u00e9criture hors du d\u00e9p\u00f4t (--sortie)"),
            ligne_md("Arguments (hors --coeurs)", args_citees()),
            ligne_md("Graine du calcul observ\u00e9", sprintf("%.0f", SEED)),
            ligne_md("Plan de graines (P7, toutes sous engine_sous_graine())", sprintf("triangle r : %.0f + r ; bootstrap interne r : %.0f + r ; r = 1 .. R ; plages de #206 pour la loi E", GRAINE_TRI, GRAINE_BOOT)),
            ligne_md("Mesure", sprintf("R = %d triangles simul\u00e9s, dont %d admis et %d refus\u00e9s ; mw_bootstrap() \u00e0 B = %d (donn\u00e9e du test calibr\u00e9) puis mw_tests() \u00e0 \u03b1 = %s ; B_MIN_DEGENERESCENCE = %d", R_TOT, R_ADM, R_REFUS, B_BOOT, num(ALPHA, 2), B_MIN_DEGENERESCENCE)),
            ligne_md("Refus (P6)", MOTIFS_REFUS),
            ligne_md("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
            ligne_md("R, plateforme", plateforme_calcul()),
            ligne_md("Locale (LC_CTYPE)", sprintf("%s \u2192 %s", LOCALE_ORIGINE, LOCALE_TRAVAIL)),
            ligne_md("D\u00e9bit du pr\u00e9-vol", if (is.na(OPT_DEBIT)) "non renseign\u00e9 (--debit-prevol)" else OPT_DEBIT))
  pool <- c(sprintf("Mod\u00e8le : Mack ajust\u00e9 au triangle (mw_ajuster()), \u00e9cart-type de population du pool **%s** ; colonnes d\u00e9g\u00e9n\u00e9r\u00e9es : %s ; premi\u00e8re colonne fix\u00e9e.",
                    num(SD_POP0, 5), if (length(JD0)) paste(JD0, collapse = ", ") else "aucune"), "",
            entete_md(c("n", "moyenne", "sd_pop", "asym\u00e9trie", "exc\u00e8s de kurtosis", "min", "max")),
            ligne_md(M_POOL[["n"]], sub(".", ",", sprintf("%.2e", M_POOL[["moyenne"]]), fixed = TRUE), num(M_POOL[["ecart_type"]], 5), num(M_POOL[["asymetrie"]], 3),
                     num(M_POOL[["exces_kurtosis"]], 3), num(M_POOL[["min"]], 3), num(M_POOL[["max"]], 3)), "",
            "Pool = `.mw_pool_residus(aj, colonnes d\u00e9g\u00e9n\u00e9r\u00e9es)` ; loi E : tirage uniforme avec remise dans pool / sd_pop. `mw_bootstrap()` tire dans le pool non r\u00e9duit : E n'en diff\u00e8re que par le facteur d'\u00e9chelle sd_pop.")
  entete_f <- c("Cl\u00e9", "queue", "p_obs", "err_mc", "p retenue observ\u00e9e", "port\u00e9e", "k = #{p\\* \u2264 p_obs}", "F\u0302\\*(p_obs)",
                "IC 95 % (Clopper-Pearson)", "#{p\\* < p_obs}", "p\\* absentes", "F\u0302\\* sur p d\u00e9finies", "bande F\u0302\\*(p_obs \u2213 2 err_mc), descriptive")
  tab_f <- vapply(CLES, function(k) { x <- RES_CLES[[k]]; i <- INFO[[k]]
    ligne_md(k, QUEUE[[k]], num(x$p_obs, 3), num(x$err, 4), i$nature, if (isTRUE(i$retenue)) "constat" else "descriptive seulement",
             if (is.na(x$k_le)) "\u2014" else sprintf("%d / %d", x$k_le, x$n), num(x$F, D_F), txt_ic(x$ic),
             if (is.na(x$k_lt)) "\u2014" else sprintf("%d", x$k_lt), x$n_na, num(x$F_def, D_F),
             if (anyNA(x$band)) "\u2014" else sprintf("[%s ; %s]", num(x$band[1], D_F), num(x$band[2], D_F))) }, "")
  na <- length(NIVEAUX_ALPHA)
  ent_n <- c("Cl\u00e9", unlist(lapply(NIVEAUX_ALPHA, function(a) c(sprintf("\u03b1 = %s : p\\* < %s (ECHEC)", num(a, 2), num(a / 2, 3)), sprintf("\u03b1 = %s : p\\* < %s (ALERTE ou pire)", num(a, 2), num(a, 3))))))
  tab_n <- vapply(CLES, function(k) { x <- RES_CLES[[k]]
    do.call(ligne_md, c(list(k), unlist(lapply(x$niveaux, function(nv) lapply(1:2, function(j)
      sprintf("%s %s", num(nv$k[j] / x$n, D_F), txt_ic(nv$ic[[j]])))), recursive = FALSE))) }, "")
  c(sprintf("# Double bootstrap Merz-W\u00fcthrich : fr\u00e9quence de la p de Monte-Carlo observ\u00e9e dans sa loi simul\u00e9e (#246, loi E, %d triangles)", R_TOT), "",
    if (OPT_ESSAI) c("**ESSAI : sortie de mise au point, non versionnable (aucun contr\u00f4le d'arbre propre, \u00e9criture refus\u00e9e).**", ""),
    "## Statut \u00e9pist\u00e9mique", "", TXT_STATUT, "",
    "## Provenance", "", prov, "",
    if (length(ALERTES)) c("## Alertes", "", paste0("- ", ALERTES), ""),
    "## Contr\u00f4les d'int\u00e9grit\u00e9", "", paste0("- ", CONTROLES), "",
    if (length(R2_LIGNES)) c("### Crit\u00e8re de reserve2 retrouv\u00e9 (r2)", "", R2_LIGNES, "",
                             "Ce contr\u00f4le prouve que l'outil r\u00e9alise le plan de #206 et #297 ; ce n'est pas une validation ind\u00e9pendante de la m\u00e9thode.", ""),
    "## Pool et loi E", "", pool, "",
    "## Fr\u00e9quence de la p observ\u00e9e dans sa loi simul\u00e9e, par cl\u00e9", "",
    sprintf("F\u0302\\*(p_obs) = #{r admis : p\\*_r \u2264 p_obs} / R_admis, R_admis = %d, comparaison exacte de doubles sans tol\u00e9rance (p_obs et p\\*_r sortent de `mw_bootstrap()`, donc de `engine_p_mc()`, sur une grille de pas k/(B_eff + 1), k = 1 pour une queue, 2 pour deux queues). L'\u00e9cart entre k = #{p\\* \u2264 p_obs} et #{p\\* < p_obs} est la masse de l'atome situ\u00e9 en p_obs ; aucun mid-p n'est retenu. La bande F\u0302\\*(p_obs \u2213 2 err_mc) est descriptive de l'erreur Monte-Carlo de p_obs (source (ii)) ; ce n'est pas un intervalle de confiance. Pas d'ajustement de multiplicit\u00e9 sur les %d fr\u00e9quences. Une ligne \u00ab descriptive seulement \u00bb est un test inop\u00e9rant ou un diagnostic : sa p_mc n'est pas retenue, sa fr\u00e9quence n'est que descriptive.", R_ADM, NS), "",
    entete_md(entete_f), tab_f, "",
    "## Niveau du test bootstrap sous le mod\u00e8le ajust\u00e9 de ce triangle (produit du m\u00eame calcul)", "",
    sprintf("Fr\u00e9quences de p\\* < \u03b1/2 et de p\\* < \u03b1 sur les %d triangles admis (p\\* absente : non-rejet), avec intervalle de Clopper-Pearson \u00e0 95 %%. R\u00e8gle ECHEC/ALERTE de `add()` pour un test \u00ab ne pas rejeter \u00bb ; constat de simulation sous ce mod\u00e8le et cette loi, T = %d, source (iii) non quantifi\u00e9e.", R_ADM, AJ0$I + 1L), "",
    entete_md(ent_n), tab_n, "")
}
duree_totale <- function() secondes(t_debut)
section_execution <- function() c("## Ex\u00e9cution (varie d'une ex\u00e9cution \u00e0 l'autre ; non compar\u00e9e par (rep))", "",
  sprintf("- Date (UTC) : d\u00e9but %s, fin %s", format(t_debut, "%Y-%m-%dT%H:%M:%S", tz = "UTC"), format(Sys.time(), "%Y-%m-%dT%H:%M:%S", tz = "UTC")),
  sprintf("- Processus (mclapply) : %d", N_PROC),
  sprintf("- Dur\u00e9e : calcul des %d lignes %s s ; total %s s", R_TOT, num(DUREE_CALC, 1), num(duree_totale(), 1)),
  sprintf("- run_engine() sur le triangle (point observ\u00e9) : %s s ; dur\u00e9e moyenne d'une ligne admise (un processus de travail) : %s s ; d\u00e9bit agr\u00e9g\u00e9 : %s lignes par heure d'horloge",
          num(DUREE_RE, 1), num(mean(vapply(ADM, function(l) l$duree, 1)), 2), num(R_TOT / DUREE_CALC * 3600, 0)))

###############################################################################
#  SORTIES
###############################################################################
MD <- construire_md()
if (length(INTEGRITE)) {
  ecrire_console(c(MD, section_execution(), "", sprintf("INTEGRITE ECHEC : %s", paste(INTEGRITE, collapse = " ; "))))
  quit(status = 1L)
}
MD_FINAL <- c(MD, section_execution(), "", "INTEGRITE OK")
brut_tsv <- function() {
  cols <- c("r", "statut", "motif", "graine_tri", "graine_boot", "cumuls_retires", "plafond_cumuls", "duree",
            unlist(lapply(CLES, function(k) paste0(c("p", "e", "B", "m"), ":", k))))
  lig <- vapply(LIGNES, function(l) {
    if (l$statut != "admis") return(paste(c(l$r, l$statut, nettoyer_champ(l$motif), sprintf("%.0f", graine_tri(l$r)), "NA", "NA", "NA",
                                            sprintf("%.3f", l$duree), rep("NA", 4L * NS)), collapse = "\t"))
    paste(c(l$r, "admis", "-", sprintf("%.0f", graine_tri(l$r)), sprintf("%.0f", graine_boot(l$r)), if (l$cumuls_retires) "oui" else "non",
            if (l$plafond_cumuls) "oui" else "non", sprintf("%.3f", l$duree),
            unlist(lapply(seq_len(NS), function(j) c(f17(l$p[j]), f17(l$e[j]), sprintf("%.0f", l$B[j]), l$m[j])))), collapse = "\t")
  }, "")
  c(paste(cols, collapse = "\t"), lig)
}
# Ecriture : fichiers nouveaux, temporaires voisins puis renommes ; aucun chemin
# absolu ni /tmp dans un fichier ecrit (D-a de #242, P13).
ecrire_sorties <- function() {
  md_final <- MD_FINAL
  tsv <- brut_tsv()
  ab <- chemins_absolus(c(md_final, tsv))
  if (length(ab)) stop("ecriture refusee : chemin absolu ou /tmp dans un fichier a ecrire : ", paste(utils::head(ab, 3), collapse = " | "))
  tmp <- stats::setNames(file.path(DOSSIER_CIBLE, paste0(".tmp246-", NOMS_SORTIE)), names(NOMS_SORTIE))
  on.exit(unlink(tmp[file.exists(tmp)]), add = TRUE)
  con <- file(tmp[["md"]], open = "wb"); writeLines(utf8(md_final), con, useBytes = TRUE); close(con)
  con <- file(tmp[["brut"]], open = "wb"); writeLines(utf8(tsv), con, useBytes = TRUE); close(con)
  if (any(file.exists(CIBLES))) stop("ecriture refusee : fichier apparu pendant le calcul, jamais ecrase")
  if (!all(file.rename(tmp, CIBLES))) stop("ecriture : renommage des fichiers temporaires impossible")
  message("ecrit : ", paste(vapply(CIBLES, chemin_cite, ""), collapse = " ; "))
}
ecrire_console(MD_FINAL)
if (!OPT_ESSAI) ecrire_sorties()
quit(status = 0L)
