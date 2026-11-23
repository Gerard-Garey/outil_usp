###############################################################################
#  tests/msep_trapeze_mw.R  --  CONFRONTATION DE LA MSEP DE MERZ-WUTHRICH
#  SUR UN TRAPEZE I > J A CL_MSEPs (ChainLadder 0.2.21), CRITERE C1
#  (issue #567, branche S6, etape 5 (a))
#
#  ETAT DEPUIS LA LEVEE DE MW-04 (annotation de l'etape 6, C4, issue #567) :
#  mesure executee au commit 766b9de (moteur de md5 faf36c54..., garde MW-04
#  en place ; docs/tableaux/20261120-issue567-msep-trapeze.md). Depuis
#  f9eaff7 (etape 6, C3), run_engine() calcule un trapeze : deux libelles de
#  la sortie (statut : "garde MW-04 en place" ; ligne Moteur : "run_engine()
#  refuse un trapeze (MW-04) jusqu'a D2") ne sont plus exacts. Le script
#  n'est donc plus rejouable tel quel : rejoue, il ecrirait ces deux
#  libelles ; sa logique est gardee telle qu'a la mesure, pour la
#  tracabilite de la mesure de 766b9de. Script de md5 6e74e6c9... a la
#  mesure ; seule la presente annotation a change cette empreinte.
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats ; utils et tools (livres avec R : untar(), read.dcf(),
#  md5sum()). Il ne modifie ni R/, ni app.R, ni tests/reference/. Le moteur
#  est charge par tests/outils_tests.R, donc par charger_moteur() (ADR 0016),
#  qui porte aussi commit_depot(), motifs_non_versionnable(),
#  garde_ecrasement() et empreinte_sans_commentaires(). Fichier source ASCII :
#  les libelles non ASCII sont ecrits en echappements \u ; sortie en UTF-8, y
#  compris sous LC_ALL=C.
#
#  Protocole : specification d'actuary
#  docs/revues/20261120-s6-trapeze/actuary-2a-specification-567.md, par. 1.3
#  (critere C1 : jeux, tolerance 1e-12 relative, valeurs attendues) ;
#  decision Q-2a-5 du mainteneur (20/11/2026) : CL_MSEPs est LUE dans
#  l'archive CRAN ChainLadder_0.2.21.tar.gz (chemin en argument, md5 fixe
#  MD5_ARCHIVE_CL), jamais copiee dans le depot (licence GPL >= 2).
#  CL_MSEPs est une fonction interne de ChainLadder (R/MWChainLadder.R, en-tete
#  "Author: Mario Wuthrich") : implementation de l'auteur, citee comme telle,
#  non formule publiee (par. 1.1). Elle somme sur les annees I - J + 1..I
#  (convention (B)) : elle traite le trapeze de facon native.
#
#  Calcul, par jeu (tri, matrice (I + 1) x (J + 1)) :
#    1. transcrire() : f_j (D(4)(c)), sigma2_j (premiere ligne de D(5)(d)(ii),
#       j <= J - 2), sigma2_(J-1) de la regle de minimum (D(5)(d)(ii)),
#       estimateur direct de sigma2_(J-1) (premiere ligne en j = J - 1,
#       I > J seulement), Q_j = sigma2_j / f_j^2, alpha_j = C(I - j, j) / S'_j,
#       triangle complete par les f_j ; ECRITURE INDEPENDANTE du moteur (aucun
#       objet du moteur lu ; copie declaree d'ajuster_trapeze() de
#       tests/unitaires/generer_valeurs_externes.R, section "Trapezes I > J",
#       etendue aux carres : estimateur direct NA) ;
#    2. CL_MSEPs(complet, I + 1, J + 1, param) : MSEP totale (ligne I + 2,
#       colonne 2) et reserve totale (ligne I + 2, colonne 1) ;
#    3. moteur : mw_ajuster(tri), mw_msep(aj)$msep, aj$reserve, aj$f,
#       aj$sigma2, aj$sigma2_Jm1_direct (absent pour un carre, exige NULL).
#  Critere (par. 1.3) : MSEP et R du moteur contre CL_MSEPs, f, sigma2_j (j =
#  0..J - 1, regle comprise) et estimateur direct du moteur contre la
#  transcription, ecart relatif <= 1e-12 ; en plus, pour les six trapezes du
#  tableau du par. 1.3, MSEP, R, sigma2_(J-1) de la regle et estimateur
#  direct du moteur contre les valeurs de ce tableau (15 chiffres
#  significatifs), meme tolerance.
#  Jeux : tests/donnees/triangle_mw.csv (reserve2) 8 x 8, 8 x 7, 8 x 6,
#  8 x 5 ; GenIns (Taylor et Ashe 1983) 10 x 10, 10 x 9, 10 x 7, 10 x 5,
#  matrice ecrite ci-dessous (celle de test_merz_wuthrich_trapeze.R),
#  comparee a data/GenIns.RData de la meme archive (controle "GenIns").
#  Le dernier jeu du par. 1.3 (premier triangle admis de chaque tranche de
#  l'etude de niveau) est le controle (c1) de tests/niveau_mw_trapeze_t8.R.
#
#  Usage (racine du depot, LC_ALL=C.UTF-8 sous Linux) :
#      Rscript tests/msep_trapeze_mw.R --archive-cl CHEMIN/ChainLadder_0.2.21.tar.gz
#          [--ecrire [--remplacer]]
#  Sortie markdown sur la console ; --ecrire l'ecrit dans
#  docs/tableaux/<AAAAMMJJ>-issue567-msep-trapeze.md (date UTC du jour ;
#  arbre propre exige, garde_ecrasement() ; aucun chemin absolu ecrit :
#  l'archive est citee par son nom et son md5).
#  Derniere ligne : INTEGRITE OK (archive, extraction, GenIns et C1 sur les
#  huit jeux) ou INTEGRITE ECHEC. Code de sortie 0 si INTEGRITE OK, 1 sinon.
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
CONNUES <- c("--archive-cl", "--ecrire", "--remplacer")
AVEC_VALEUR <- "--archive-cl"
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
OPT_ARCHIVE   <- lire_option("--archive-cl", NA_character_)
OPT_ECRIRE    <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
if (OPT_REMPLACER && !OPT_ECRIRE) refuser("--remplacer : reserve a --ecrire")
if (is.na(OPT_ARCHIVE)) refuser("--archive-cl CHEMIN obligatoire (archive CRAN ChainLadder_0.2.21.tar.gz, Q-2a-5)")
if (!file.exists(OPT_ARCHIVE)) refuser("--archive-cl : fichier introuvable")

# --- Constantes du protocole (par. 1.3) --------------------------------------
TOL_C1 <- 1e-12
MD5_ARCHIVE_CL <- "2a1fc0fcc593ec99529a40399274a088"
SCRIPT_DEPOT <- "tests/msep_trapeze_mw.R"
SPEC <- "docs/revues/20261120-s6-trapeze/actuary-2a-specification-567.md"
# Valeurs attendues (par. 1.3, tableau mesure par le prototype) : MSEP, R,
# sigma2_(J-1) de la regle, sigma2_(J-1) estimateur direct.
ATTENDU_13 <- list(
  "triangle_mw 8x7" = c(19915.3947059509, 8490.81633282289, 0.0300913181729469, 0.189673662669698),
  "triangle_mw 8x6" = c(17334.2597283566, 7273.53169003966, 0.141927830391250, 0.0973247604368617),
  "triangle_mw 8x5" = c(15763.5410314709, 5885.87803675476, 0.684464137043688, 0.314778798976253),
  "GenIns 10x9"     = c(2764721031511.53, 17825075.6984623, 24.3674453780781, 1147.36596842866),
  "GenIns 10x7"     = c(2220973209004.33, 12983205.6743162, 12418.5249545645, 8185.77162000963),
  "GenIns 10x5"     = c(1405527865679.78, 8599219.11811852, 37736.8550479964, 15182.9026809764))
# GenIns (Taylor et Ashe 1983), matrice de tests/unitaires/test_merz_wuthrich_trapeze.R.
GENINS <- matrix(c(357848, 352118, 290507, 310608, 443160, 396132, 440832, 359480, 376686, 344014,
  1124788, 1236139, 1292306, 1418858, 1136350, 1333217, 1288463, 1421128, 1363294, NA,
  1735330, 2170033, 2218525, 2195047, 2128333, 2180715, 2419861, 2864498, NA, NA,
  2218270, 3353322, 3235179, 3757447, 2897821, 2985752, 3483130, NA, NA, NA,
  2745596, 3799067, 3985995, 4029929, 3402672, 3691712, NA, NA, NA, NA,
  3319994, 4120063, 4132918, 4381982, 3873311, NA, NA, NA, NA, NA,
  3466336, 4647867, 4628910, 4588268, NA, NA, NA, NA, NA, NA,
  3606286, 4914039, 4909315, NA, NA, NA, NA, NA, NA, NA,
  3833515, 5339085, NA, NA, NA, NA, NA, NA, NA, NA,
  3901463, NA, NA, NA, NA, NA, NA, NA, NA, NA), 10, 10)

# --- Chargement du moteur et des outils --------------------------------------
FICHIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) f else NA_character_
})
DOSSIER_SCRIPT <- if (!is.na(FICHIER_SCRIPT)) dirname(FICHIER_SCRIPT) else
  if (file.exists("tests/outils_tests.R")) "tests" else "."
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))

# --- Outils de forme ---------------------------------------------------------
utf8 <- function(x) {
  x <- as.character(x)
  if (!isTRUE(l10n_info()[["UTF-8"]])) { k <- Encoding(x) == "unknown"; Encoding(x)[k] <- "UTF-8"; x } else enc2utf8(x)
}
ecrire_console <- function(x) writeLines(utf8(x), useBytes = TRUE)
ecrire_fichier <- function(f, lignes) {
  con <- file(f, open = "wb"); on.exit(close(con))
  writeLines(utf8(lignes), con, sep = "\n", useBytes = TRUE)
}
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
md5_fichier <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
horodatage <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
g15 <- function(x) if (length(x) != 1L || is.na(x)) "\u2014" else sprintf("%.15g", x)
e3 <- function(x) if (length(x) != 1L || is.na(x)) "\u2014" else if (is.infinite(x)) "\u221e" else sprintf("%.2e", x)
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
chemins_absolus <- function(lignes) {
  k <- grepl("/tmp", lignes, fixed = TRUE) |
    grepl("(^|[ (|`'\"=])(/(home|root|usr|var|mnt|opt|Users|private|srv|media)/|[A-Za-z]:[\\\\/])", lignes, perl = TRUE)
  lignes[k]
}
# Ecart relatif |a - b| / max(|a|, |b|), 0 si a == b ; Inf si l'un n'est pas
# fini ou si les longueurs different (ecart maximal sur un vecteur).
ecart_rel <- function(a, b) {
  if (is.null(a) || is.null(b) || length(a) != length(b) || !length(a)) return(Inf)
  if (any(!is.finite(a)) || any(!is.finite(b))) return(Inf)
  e <- abs(a - b) / pmax(abs(a), abs(b)); e[a == b] <- 0
  max(e)
}

# --- Contexte (debut) --------------------------------------------------------
MD5_MOTEUR <- md5_fichier(file.path(RACINE, "R", "engine.R"))
EMPREINTE <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
SHA <- sha_head()
COMMIT <- commit_depot(SCRIPT_DEPOT)
EMPREINTES <- empreintes_code()
PLATEFORME <- plateforme_calcul()
DATE_SORTIE <- format(Sys.time(), "%Y%m%d", tz = "UTC")
NOM_SORTIE <- sprintf("%s-issue567-msep-trapeze.md", DATE_SORTIE)
CIBLE <- file.path(RACINE, "docs", "tableaux", NOM_SORTIE)
REMPLACES <- NULL
if (OPT_ECRIRE) {
  nv <- motifs_non_versionnable(COMMIT, EMPREINTES, "de l'ex\u00e9cution")
  if (length(nv)) refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
                          " -- relancer sur un arbre propre, ou sans --ecrire (sortie console)")
  if (!dir.exists(file.path(RACINE, "docs", "tableaux"))) refuser("dossier de sortie introuvable : docs/tableaux")
  REMPLACES <- garde_ecrasement(CIBLE, remplacer = OPT_REMPLACER)
}

###############################################################################
#  ARCHIVE CRAN : md5, EXTRACTION DE CL_MSEPs ET DE GenIns (Q-2a-5)
###############################################################################
# Copie declaree dans tests/niveau_mw_trapeze_t8.R (meme corps).
# Rend la fonction CL_MSEPs evaluee dans un environnement fils de baseenv()
# (aucun objet du moteur visible), le md5 de l'archive, du fichier
# R/MWChainLadder.R extrait et du texte de la fonction (lignes de
# "CL_MSEPs <- function" a la ligne qui precede "CDR.MackChainLadder"), la
# version lue dans DESCRIPTION, la presence de l'en-tete d'auteur et GenIns
# (data/GenIns.RData, charge dans un environnement vide). L'extraction se
# fait dans un dossier temporaire, supprime en sortie : rien n'est ecrit
# dans le depot.
charger_cl <- function(archive) {
  md5_a <- unname(tools::md5sum(archive))
  if (!identical(md5_a, MD5_ARCHIVE_CL)) return(list(ok = FALSE, md5_archive = md5_a, motif = "md5 de l'archive diff\u00e9rent"))
  d <- tempfile("cl567_"); dir.create(d)
  on.exit(unlink(d, recursive = TRUE), add = TRUE)
  fichiers <- c("ChainLadder/R/MWChainLadder.R", "ChainLadder/data/GenIns.RData", "ChainLadder/DESCRIPTION")
  r <- tryCatch(utils::untar(archive, files = fichiers, exdir = d), error = function(e) 1L)
  if (!identical(as.integer(r), 0L) || !all(file.exists(file.path(d, fichiers))))
    return(list(ok = FALSE, md5_archive = md5_a, motif = "extraction impossible"))
  f_src <- file.path(d, "ChainLadder", "R", "MWChainLadder.R")
  src <- readLines(f_src, warn = FALSE)
  i1 <- grep("^CL_MSEPs <- function", src); i2 <- grep("^CDR.MackChainLadder", src)
  if (length(i1) != 1L || length(i2) != 1L || i2 <= i1)
    return(list(ok = FALSE, md5_archive = md5_a, motif = "CL_MSEPs introuvable dans R/MWChainLadder.R"))
  txt <- src[i1:(i2 - 1L)]
  f_txt <- file.path(d, "CL_MSEPs.txt"); writeLines(txt, f_txt)
  env <- new.env(parent = baseenv())
  eval(parse(text = txt, keep.source = FALSE), envir = env)
  desc <- read.dcf(file.path(d, "ChainLadder", "DESCRIPTION"), fields = c("Package", "Version", "Date/Publication"))
  e_g <- new.env(parent = emptyenv())
  load(file.path(d, "ChainLadder", "data", "GenIns.RData"), envir = e_g)
  g <- if (exists("GenIns", envir = e_g, inherits = FALSE)) get("GenIns", envir = e_g) else NULL
  gm <- if (is.null(g)) NULL else matrix(as.numeric(unclass(g)), nrow(g), ncol(g))
  list(ok = is.function(env$CL_MSEPs), CL_MSEPs = env$CL_MSEPs, md5_archive = md5_a,
       md5_fichier = unname(tools::md5sum(f_src)), md5_fonction = unname(tools::md5sum(f_txt)),
       lignes = c(i1, i2 - 1L), version = unname(desc[1, "Version"]), paquet = unname(desc[1, "Package"]),
       publication = unname(desc[1, "Date/Publication"]),
       auteur = any(grepl("Author: Mario Wuthrich", txt, fixed = TRUE)), genins = gm, motif = NA_character_)
}

###############################################################################
#  TRANSCRIPTION INDEPENDANTE ET CRITERE C1
###############################################################################
# Copie declaree dans tests/niveau_mw_trapeze_t8.R (meme corps). D(4)(c) et
# D(5)(d)(ii) en indices 0, ecrits a partir du texte, sans lire d'objet du
# moteur ; carre : estimateur direct NA (aucune annee au-dela de J).
transcrire <- function(tri) {
  I <- nrow(tri) - 1; J <- ncol(tri) - 1
  f <- s2 <- numeric(J)
  for (j in 0:(J - 1)) { r <- 0:(I - j - 1)
    f[j + 1] <- sum(tri[r + 1, j + 2]) / sum(tri[r + 1, j + 1]) }
  for (j in 0:(J - 2)) { r <- 0:(I - j - 1)
    s2[j + 1] <- sum(tri[r + 1, j + 1] * (tri[r + 1, j + 2] / tri[r + 1, j + 1] - f[j + 1])^2) /
      (I - j - 1) }
  s2[J] <- min(s2[J - 1], s2[J - 2], s2[J - 1]^2 / s2[J - 2])
  s2d <- if (I > J) {
    r <- 0:(I - J)
    sum(tri[r + 1, J] * (tri[r + 1, J + 1] / tri[r + 1, J] - f[J])^2) / (I - J)
  } else NA_real_
  complet <- tri
  for (i in 0:I) { d <- I - i
    if (d < J) for (j in (d + 1):J) complet[i + 1, j + 1] <- complet[i + 1, j] * f[j] }
  Sp <- vapply(0:(J - 1), function(j) sum(tri[(0:(I - j)) + 1, j + 1]), numeric(1))
  alpha <- vapply(0:(J - 1), function(j) tri[I - j + 1, j + 1], numeric(1)) / Sp
  list(I = I, J = J, f = f, s2 = s2, s2d = s2d, complet = complet,
       param = data.frame(f = f, sigma2 = s2, ratio = s2 / f^2, alpha = alpha))
}
# Critere C1 sur un triangle (copie declaree dans tests/niveau_mw_trapeze_t8.R) :
# MSEP et R du moteur contre CL_MSEPs ; f, sigma2 et estimateur direct du
# moteur contre la transcription ; ecarts relatifs et booleen ok (<= TOL_C1).
c1_triangle <- function(tri, cl_msep, aj = mw_ajuster(tri), msep = mw_msep(aj)$msep) {
  t <- transcrire(tri)
  r <- cl_msep(t$complet, nrow(tri), ncol(tri), t$param)
  m_cl <- r[nrow(tri) + 1L, 2L]; r_cl <- r[nrow(tri) + 1L, 1L]
  e <- c(msep = ecart_rel(msep, m_cl), R = ecart_rel(aj$reserve, r_cl),
         f = ecart_rel(aj$f, t$f), s2 = ecart_rel(aj$sigma2, t$s2),
         dir = if (t$I > t$J) ecart_rel(aj$sigma2_Jm1_direct, t$s2d) else if (is.null(aj$sigma2_Jm1_direct)) 0 else Inf)
  list(ok = all(e <= TOL_C1), e = e, msep = msep, msep_cl = m_cl, R = aj$reserve, R_cl = r_cl,
       s2_regle = aj$sigma2[aj$J], s2_dir = if (is.null(aj$sigma2_Jm1_direct)) NA_real_ else aj$sigma2_Jm1_direct,
       s2_regle_t = t$s2[t$J], s2_dir_t = t$s2d)
}

###############################################################################
#  CALCUL
###############################################################################
CL <- charger_cl(OPT_ARCHIVE)
CTRL <- list()
INTEGRITE <- character(0)
controle <- function(code, ok, detail) {
  CTRL[[length(CTRL) + 1L]] <<- list(code = code, ok = isTRUE(ok), detail = detail)
  if (!isTRUE(ok)) INTEGRITE <<- c(INTEGRITE, code)
}
controle("archive", isTRUE(CL$ok) && isTRUE(CL$auteur) && identical(CL$version, "0.2.21"),
         if (!isTRUE(CL$ok)) sprintf("%s (md5 lu %s, attendu %s)", CL$motif, CL$md5_archive, MD5_ARCHIVE_CL) else
           sprintf("%s (md5 %s = attendu) ; paquet %s %s (DESCRIPTION, publi\u00e9 %s) ; R/MWChainLadder.R md5 %s ; CL_MSEPs lignes %d \u00e0 %d (texte md5 %s), en-t\u00eate \u00ab Author: Mario Wuthrich \u00bb : %s ; fonction \u00e9valu\u00e9e dans un environnement fils de baseenv(), extraction dans un dossier temporaire supprim\u00e9",
                   basename(OPT_ARCHIVE), CL$md5_archive, CL$paquet, CL$version, CL$publication, CL$md5_fichier,
                   CL$lignes[1], CL$lignes[2], CL$md5_fonction, if (isTRUE(CL$auteur)) "pr\u00e9sent" else "ABSENT"))
if (!isTRUE(CL$ok)) {
  ecrire_console(c("## INTEGRITE ECHEC : archive ChainLadder", "", sprintf("- archive : %s", CTRL[[1]]$detail), "", "INTEGRITE ECHEC"))
  quit(status = 1L)
}
controle("GenIns", identical(CL$genins, GENINS),
         sprintf("matrice GenIns du script (celle de tests/unitaires/test_merz_wuthrich_trapeze.R) identical() \u00e0 data/GenIns.RData de l'archive (valeurs, dimensions %s) : %s",
                 if (is.null(CL$genins)) "absentes" else paste(dim(CL$genins), collapse = " x "),
                 if (identical(CL$genins, GENINS)) "oui" else "NON"))
JEUX <- list("triangle_mw 8x8" = .tri, "triangle_mw 8x7" = .tri[, 1:7], "triangle_mw 8x6" = .tri[, 1:6],
             "triangle_mw 8x5" = .tri[, 1:5], "GenIns 10x10" = GENINS, "GenIns 10x9" = GENINS[, 1:9],
             "GenIns 10x7" = GENINS[, 1:7], "GenIns 10x5" = GENINS[, 1:5])
RES <- lapply(JEUX, function(tri) c1_triangle(tri, CL$CL_MSEPs))
ATT <- lapply(names(JEUX), function(nm) {
  a <- ATTENDU_13[[nm]]; x <- RES[[nm]]
  if (is.null(a)) return(NULL)
  e <- c(msep = ecart_rel(x$msep, a[1]), R = ecart_rel(x$R, a[2]), s2_regle = ecart_rel(x$s2_regle, a[3]), s2_dir = ecart_rel(x$s2_dir, a[4]))
  list(ok = all(e <= TOL_C1), e = e)
})
names(ATT) <- names(JEUX)
OK_JEU <- vapply(names(JEUX), function(nm) RES[[nm]]$ok && (is.null(ATT[[nm]]) || ATT[[nm]]$ok), logical(1))
controle("C1", all(OK_JEU), sprintf("%d jeu(x) sur %d dans la tol\u00e9rance %g relative (moteur contre CL_MSEPs et contre la transcription ; six trap\u00e8zes aussi contre le tableau du par. 1.3)%s",
                                     sum(OK_JEU), length(OK_JEU), TOL_C1,
                                     if (all(OK_JEU)) "" else sprintf(" ; hors tol\u00e9rance : %s", paste(names(JEUX)[!OK_JEU], collapse = ", "))))
MD5_MOTEUR_FIN <- md5_fichier(file.path(RACINE, "R", "engine.R"))
SHA_FIN <- sha_head()
controle("contexte", identical(MD5_MOTEUR, MD5_MOTEUR_FIN) && identical(SHA, SHA_FIN) && SHA != "inconnu",
         sprintf("md5 R/engine.R d\u00e9but %s, fin %s ; SHA d\u00e9but %s, fin %s", MD5_MOTEUR, MD5_MOTEUR_FIN, SHA, SHA_FIN))

###############################################################################
#  SORTIE
###############################################################################
S <- c("## Mesure #567 (S6, \u00e9tape 5 (a)) : MSEP de Merz-W\u00fcthrich sur un trap\u00e8ze I > J, confront\u00e9e \u00e0 CL_MSEPs (ChainLadder 0.2.21), crit\u00e8re C1", "",
       "### Statut", "",
       paste("Concordance num\u00e9rique entre deux impl\u00e9mentations et une transcription : le moteur (fonctions internes, garde MW-04 en place),",
             "CL_MSEPs, fonction interne de ChainLadder 0.2.21 portant l'en-t\u00eate \u00ab Author: Mario Wuthrich \u00bb (impl\u00e9mentation de l'auteur,",
             "**non formule publi\u00e9e** ; aucune source imprimant le cas I > J n'a \u00e9t\u00e9 relue, sp\u00e9cification 2a, par. 1.1), et une transcription",
             "de D(4)(c) et D(5)(d)(ii) \u00e9crite dans ce script sans lire le moteur. Approximation num\u00e9rique au sens de l'arithm\u00e9tique",
             "flottante (\u00e9carts relatifs mesur\u00e9s), non r\u00e9sultat exact ; elle \u00e9tablit que le moteur calcule la convention (B) de CL_MSEPs,",
             "pas que cette convention est celle du r\u00e8glement (lecture de `regulatory`, \u00e9tape 1)."), "",
       "### T0 \u2014 provenance", "",
       entete_md(c("Grandeur", "Valeur")),
       ligne_md("Protocole", sprintf("%s, par. 1.3 (crit\u00e8re C1, tol\u00e9rance %g relative) ; d\u00e9cision Q-2a-5 du mainteneur (20/11/2026) ; md5 %s", SPEC, TOL_C1, md5_fichier(file.path(RACINE, SPEC)))),
       ligne_md("Archive CRAN", sprintf("%s, md5 %s (attendu %s), lue en argument, jamais copi\u00e9e dans le d\u00e9p\u00f4t", basename(OPT_ARCHIVE), CL$md5_archive, MD5_ARCHIVE_CL)),
       ligne_md("Fonction lue", sprintf("CL_MSEPs, ChainLadder/R/MWChainLadder.R (md5 %s), lignes %d \u00e0 %d, texte md5 %s ; paquet %s, publi\u00e9 %s", CL$md5_fichier, CL$lignes[1], CL$lignes[2], CL$md5_fonction, CL$version, CL$publication)),
       ligne_md("Jeux", sprintf("tests/donnees/triangle_mw.csv (reserve2, md5 %s) : 8 x 8, et 8 x 7, 8 x 6, 8 x 5 par retrait des derni\u00e8res colonnes ; GenIns (Taylor et Ashe 1983) : 10 x 10, 10 x 9, 10 x 7, 10 x 5", md5_fichier(file.path(RACINE, "tests", "donnees", "triangle_mw.csv")))),
       ligne_md("Param\u00e8tres pass\u00e9s \u00e0 CL_MSEPs", "transcription ind\u00e9pendante : f_j (D(4)(c)), \u03c3\u00b2_j (premi\u00e8re ligne de D(5)(d)(ii), j \u2264 J \u2212 2), \u03c3\u00b2_(J\u22121) de la r\u00e8gle de minimum, Q_j = \u03c3\u00b2_j / f_j\u00b2, \u03b1_j = C(I \u2212 j, j) / S\u2032_j, triangle compl\u00e9t\u00e9 par les f_j ; estimateur direct de \u03c3\u00b2_(J\u22121) : premi\u00e8re ligne de D(5)(d)(ii) en j = J \u2212 1 (I > J)"),
       ligne_md("Moteur", "mw_ajuster(), mw_msep() (charger_moteur(), ADR 0016) ; run_engine() refuse un trap\u00e8ze (MW-04) jusqu'\u00e0 D2"),
       ligne_md("SHA, git rev-parse HEAD (d\u00e9but ; fin)", sprintf("%s ; %s", SHA, SHA_FIN)),
       ligne_md("Commit (commit_depot())", COMMIT),
       ligne_md("md5 R/engine.R", MD5_MOTEUR),
       ligne_md("Empreinte sans commentaires de R/engine.R (#231)", EMPREINTE),
       ligne_md("Empreintes md5 du code ex\u00e9cut\u00e9", EMPREINTES),
       ligne_md("Plateforme de calcul", PLATEFORME),
       ligne_md("Locale (LC_CTYPE)", sprintf("%s \u2192 %s", LOCALE_ORIGINE, LOCALE_TRAVAIL)),
       ligne_md("Date (UTC)", horodatage()),
       ligne_md("Versionnable (--ecrire)", if (length(motifs_non_versionnable(COMMIT, EMPREINTES, "de l'ex\u00e9cution"))) "non" else "oui"), "")
if (length(REMPLACES)) S <- inserer_t0(S, ligne_remplacement(REMPLACES, CIBLE))
S <- c(S, sprintf("### R\u00e9sultats (crit\u00e8re C1, \u00e9carts relatifs, tol\u00e9rance %g)", TOL_C1), "",
       entete_md(c("Jeu", "MSEP, moteur", "MSEP, CL_MSEPs", "\u00e9cart MSEP", "R, moteur", "\u00e9cart R (CL_MSEPs)",
                   "\u00e9cart f (transcription)", "\u00e9cart \u03c3\u00b2_j, j = 0..J\u22121 (transcription)", "\u03c3\u00b2_(J\u22121), r\u00e8gle", "\u03c3\u00b2_(J\u22121), direct",
                   "\u00e9cart direct (transcription)", "\u00e9cart max. au tableau du par. 1.3", "C1")),
       vapply(names(JEUX), function(nm) { x <- RES[[nm]]; a <- ATT[[nm]]
         ligne_md(nm, g15(x$msep), g15(x$msep_cl), e3(x$e[["msep"]]), g15(x$R), e3(x$e[["R"]]), e3(x$e[["f"]]), e3(x$e[["s2"]]),
                  g15(x$s2_regle), if (is.na(x$s2_dir)) "\u2014 (carr\u00e9 : champ absent)" else g15(x$s2_dir),
                  if (is.na(x$s2_dir)) sprintf("%s (champ NULL exig\u00e9)", e3(x$e[["dir"]])) else e3(x$e[["dir"]]),
                  if (is.null(a)) "\u2014 (hors tableau)" else e3(max(a$e)), if (OK_JEU[[nm]]) "OK" else "**\u00c9CHEC**") }, ""), "",
       "\u00c9carts : |a \u2212 b| / max(|a|, |b|), 0 si a = b ; maximum sur les composantes pour f et \u03c3\u00b2_j ; \u221e si une valeur est absente ou non finie. Les valeurs du tableau du par. 1.3 sont \u00e0 15 chiffres significatifs.", "",
       "### Contr\u00f4les", "",
       entete_md(c("Contr\u00f4le", "R\u00e9sultat", "D\u00e9tail")),
       vapply(CTRL, function(k) ligne_md(k$code, if (k$ok) "OK" else "\u00c9CHEC", k$detail), ""), "",
       sprintf("Crit\u00e8re C1 : %s (%d jeu(x) sur %d). Dur\u00e9e : %.1f s.", if (all(OK_JEU)) "OK" else "\u00c9CHEC", sum(OK_JEU), length(OK_JEU),
               as.numeric(difftime(Sys.time(), t_debut, units = "secs"))), "")
ecrire_console(S)
REFUS <- FALSE
if (OPT_ECRIRE) {
  ab <- chemins_absolus(S)
  nv <- motifs_non_versionnable(commit_depot(SCRIPT_DEPOT), empreintes_code(), "de l'ex\u00e9cution")
  if (length(INTEGRITE)) { message("--ecrire refuse : INTEGRITE ECHEC"); REFUS <- TRUE }
  else if (length(ab)) { message("--ecrire refuse : chemin absolu ou /tmp dans la sortie : ", paste(utils::head(ab, 3), collapse = " | ")); REFUS <- TRUE }
  else if (length(nv)) { message("--ecrire refuse au moment d'ecrire : ", paste(nv, collapse = " ; ")); REFUS <- TRUE }
  else {
    garde_ecrasement(CIBLE, remplacer = OPT_REMPLACER)
    tmp <- tempfile(pattern = paste0(".", NOM_SORTIE, "."), tmpdir = dirname(CIBLE))
    ecrire_fichier(tmp, S)
    if (!isTRUE(file.rename(tmp, CIBLE))) { unlink(tmp); message("--ecrire : ecriture impossible"); REFUS <- TRUE }
    else ecrire_console(sprintf("\u00c9crit : docs/tableaux/%s (md5 %s)", NOM_SORTIE, md5_fichier(CIBLE)))
  }
}
ecrire_console(paste("INTEGRITE", if (length(INTEGRITE)) "ECHEC" else "OK"))
quit(status = if (length(INTEGRITE) || REFUS) 1L else 0L)
