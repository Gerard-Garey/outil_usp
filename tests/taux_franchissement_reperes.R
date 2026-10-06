###############################################################################
#  tests/taux_franchissement_reperes.R  --  TAUX DE FRANCHISSEMENT DES REPERES
#  DES DIAGNOSTICS SOUS LE MODELE AJUSTE (issue #72)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  Sortie en markdown sur la console (UTF-8) ; fichier ecrit SEULEMENT sur
#  option explicite (--ecrire, --sortie ; #171).
#  R base + stats (tools::md5sum() pour les empreintes du code, #171 ; tools
#  est livre avec R).
#
#  Objet : la decision M7 (#24) s'appuyait sur 60 replications (+/- 6 points)
#  pour dire que quatre reperes des diagnostics (Cook 4/T, IC 50 %, jackknife
#  10 %, R2 0,5) sont franchis par le modele vrai dans 50 a 80 % des cas a
#  T = 8. Ce script mesure, sur R replications (defaut 2 000) simulees sous le
#  modele AJUSTE au jeu (usp_simuler(), le generateur du bootstrap
#  parametrique), la frequence de franchissement de chaque repere, avec son
#  intervalle de Clopper-Pearson a 95 % (incertitude Monte-Carlo sur le taux,
#  fonction de R ; elle ne dit rien de l'erreur d'approximation en T).
#  Tableaux : T1, reperes des diagnostics (taux simules) ; T1 bis, regle
#  de restitution R4 (convention, #44 : pente et Fisher restitues en
#  diagnostic) et position de delta chapeau (au bord, dont bord 0, dont
#  bord 1), taux simules, qui ne sont pas des reperes de diagnostic ; repere
#  des leviers 2k/T hors des taux simules : les hat values de lm(y ~ x - 1)
#  ne dependent que de X, fixe dans les replications, et le franchissement
#  est donc deterministe (le script verifie que la valeur de chaque replication
#  est identique a celle du jeu observe, sinon controle d'integrite en
#  echec) ; T2, classement des lignes de usp_tests().
#
#  Volet Merz-Wuthrich (issue #89, decision du mainteneur ; option
#  --seulement mw, qui ne lance QUE ce volet ; sans elle, seul le volet
#  lognormal ci-dessous est lance, inchange) : taux de franchissement du
#  repere de lecture |DFBETAS| > REPERE_DFBETAS_MW / sqrt(n_j) = 2/sqrt(n_j)
#  de mw_influence() (champ fort_dfbetas) et, pour comparaison, du repere
#  absolu |DFBETAS| > 2, sous le modele ajuste au triangle du cas reserve2
#  (.tri de tests/outils_tests.R). Plan de simulation :
#    - modele de Mack ajuste par mw_ajuster() (f chapeau, sigma2 chapeau,
#      sigma2_{J-1} extrapole par le moteur) ;
#    - C(i,j+1) = f_j C(i,j) + sigma_j sqrt(C(i,j)) eps(i,j), eps ~ N(0,1)
#      iid, sur les cellules observees du triangle (j + 1 <= I - i) ; premiere
#      colonne observee fixee ; R replications (defaut 2 000) ;
#    - 28 eps tires par essai (ordre : ligne i croissante, puis colonne) ;
#      un essai ou une cellule simulee est <= 0 (ou non finie) est rejete,
#      compte et redessine (nouvel essai, meme flux) ;
#    - tous les triangles sont tires d'un seul flux, sous engine_sous_graine()
#      avec la graine --graine (defaut 20260927), avant tout calcul ;
#    - par replication : mw_ajuster() puis mw_influence() (fonctions du
#      moteur, aucune reimplementation) ; lecture de fort_dfbetas, dfbetas et
#      repere_dfbetas ; controle par replication : fort_dfbetas ==
#      (!is.na(dfbetas) & |dfbetas| > repere_dfbetas) et repere_dfbetas ==
#      REPERE_DFBETAS_MW / sqrt(n_j).
#  Sorties M1 (taux par cellule regroupes par n_j = 7..3, n_j = 2 : DFBETAS
#  NA par construction, et global n_j >= 3, pour les deux reperes, avec IC de
#  Clopper-Pearson 95 % : incertitude Monte-Carlo seulement, et qui suppose
#  des cellules independantes, ce que ne sont pas les cellules d'une meme
#  colonne ni d'un meme triangle : IC indicatif), M2 (nombre de cellules
#  colorees par triangle : moyenne, IC asymptotique de la moyenne sur les R
#  triangles iid, quantiles, distribution), proportion de DFBETAS NA hors
#  n_j = 2. Controle d'integrite : sur le triangle observe, mw_influence()
#  colore exactement les cellules (0,2), (0,3) et (1,4) (spec. E2 reduite,
#  #89) ; sigma2 chapeau fini et >= 0 ; controle par replication ci-dessus.
#  --tranche et --combiner : volet lognormal seulement (refus avec
#  --seulement mw) ; --ecrire / --sortie : fichier <AAAAMMJJ>-issue<N>-MW.md.
#
#  Chaque replication est traitee comme run_engine() traite un jeu observe
#  (methode prime, segment 1 de l'annexe II, donnees brutes, alpha = 0,10) :
#    usp_ajuster() (54 demarrages), usp_parametre(), usp_jackknife() et
#    l'ecart relatif max sur sigma_USP, l'IC bootstrap 90 % de sigma_USP et
#    sa largeur relative, puis usp_tests() avec robustesse : les reperes sont
#    lus sur les lignes de la table produite par le moteur ACTUEL (lignes
#    Cook, leviers, R2, jackknife, IC ; pente et Fisher restitues en
#    diagnostic quand la pente n'est pas identifiable, regle R4 de #44 ;
#    lignes non applicables, #59 ; tests inoperants restitues INFO, regle R1
#    de #44).
#  Deux ecarts a run_engine(), controles sur le jeu observe (controle
#  d'integrite ci-dessous) :
#    - l'IC bootstrap de chaque replication est reconstruit par la boucle de
#      usp_bootstrap() reduite a ce dont l'IC depend (usp_simuler() et
#      usp_ajuster_rapide() sous engine_sous_graine(), sans les statistiques
#      du catalogue, ~30 fois plus couteuses) : sigma_boot n'en differe que
#      si les statistiques d'une replication interne echouent alors que le
#      reajustement aboutit ;
#    - usp_tests() recoit les statistiques observees du catalogue et des
#      p-values Monte-Carlo fictives (0,5) : type, estimation, statistique
#      et inoperance (p_min, lois discretes) n'en dependent pas ; les
#      verdicts des lignes "test" en dependent et ne sont pas exploites.
#  Lignes hors perimetre (LIGNES_HORS_PERIMETRE, issue #45) : la largeur de
#  l'IC bootstrap a delta fixe et les deux rapports de vraisemblance aux
#  bornes delta = 0 et delta = 1 ne sont pas reconstruites par traiter()
#  (elles demandent le bootstrap restreint et le bootstrap des LR) ; aucun
#  repere n'y porte. Le controle d'integrite compare res$tests prive de ces
#  trois lignes, nommees explicitement (et exige qu'elles y figurent chacune
#  une fois) ; elles sont absentes de T2 et declarees en T0 et dans CONTEXTE.
#
#  Alea : tout tirage passe par engine_sous_graine() avec une graine
#  explicite. Les R jeux simules sont tires d'un seul flux (graine --graine),
#  avant tout calcul ; l'IC de la replication b utilise la graine
#  --graine-ic + b (graines distinctes : pas de bruit Monte-Carlo commun aux
#  replications). Le resultat ne depend donc pas du decoupage en tranches.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/taux_franchissement_reperes.R [--R 2000]
#          [--graine 20260927] [--graine-ic 20260831] [--B-ic 999]
#          [--jeu J1|J2] [--tranche i/K]
#          [--ecrire [--remplacer] | --sortie DOSSIER] [--issue N]
#      Rscript tests/taux_franchissement_reperes.R --seulement mw [--R 2000]
#          [--graine 20260927]
#          [--ecrire [--remplacer] | --sortie DOSSIER] [--issue N]
#      Rscript tests/taux_franchissement_reperes.R --combiner f1 f2 ...
#          [--ecrire [--remplacer] | --sortie DOSSIER] [--issue N]
#  --tranche i/K : ne traite que la i-eme de K tranches de replications
#  consecutives et imprime, en plus des tableaux partiels, des lignes machine :
#  PARAMETRES, TRANCHE, CONTEXTE (contenu de T0 hors durees et hors bornes de
#  la tranche : jeu, modele ajuste, configuration, sigma_USP observe,
#  graines, B, generateur, commit, plateforme de calcul -- R, systeme,
#  machine, BLAS, LAPACK, #171 --, empreintes md5 de R/engine.R, de
#  tests/outils_tests.R charge et du script execute -- #171, elargie --,
#  leviers), INTEGRITE (OK ou ECHEC),
#  NCOMPTES (nombre de lignes COMPTE annoncees), les comptes bruts (COMPTE)
#  et, en derniere ligne, FIN (nombre de lignes COMPTE ecrites). Rediriger la
#  sortie de chaque tranche vers un fichier HORS du depot, puis --combiner
#  additionne les comptes des K fichiers et imprime T0 et les tableaux
#  complets, identiques a ceux d'une execution d'un seul tenant. --combiner
#  refuse (code de sortie 1, sans tableau) : une tranche sans ligne
#  INTEGRITE ou en ECHEC ; une sortie incomplete (FIN absente ou pas en
#  derniere ligne, nombre de lignes COMPTE different de NCOMPTES ou de FIN :
#  troncature) ; des PARAMETRES ou un CONTEXTE differents entre tranches
#  (plateforme de calcul et empreintes du code comprises : des tranches
#  calculees sous des BLAS ou LAPACK differents, ou avec un moteur, un
#  tests/outils_tests.R ou un script differents au meme commit, ne se
#  combinent pas, #171) ; des tranches qui ne
#  couvrent pas 1..R exactement une fois.
#  Commit : sortie de "git rev-parse HEAD" (suivie de "(arbre de travail
#  modifie)" si "git status --porcelain --untracked-files=no" n'est pas
#  vide), "inconnu" si git n'est pas disponible.
#  --ecrire (--combiner, ou execution d'un seul tenant sans --tranche ; #171,
#  decision du mainteneur du 30/09/2026) : ecrit la sortie de la console dans
#  docs/tableaux/<AAAAMMJJ>-issue<N>-<jeu>.md, date du jour, N donne par
#  --issue N, obligatoire avec --ecrire et --sortie (issue de rattachement :
#  #122 pour les tableaux regeneres du 30/09/2026, produits par redirection) ;
#  un fichier cible existant n'est jamais ecrase (refus), sauf un fichier
#  suivi par git avec --remplacer (garde d'ecrasement, #173,
#  garde_ecrasement() de tests/outils_tests.R : sans --remplacer, refus qui
#  nomme le fichier suivi ; refus aussi d'un fichier existant dont git ne
#  peut dire s'il est suivi ; --remplacer avec --ecrire seulement, refus
#  d'usage sinon ; le T0 du fichier ecrit cite alors le fichier remplace et
#  son md5 d'avant) ; REFUSE (code 1,
#  rien d'ecrit) si le commit des tranches, ou celui de la combinaison ou de
#  l'execution, n'est pas un SHA nu ("(arbre de travail modifie)", "(script
#  non suivi)" ou "inconnu"), ou si tests/outils_tests.R ou le script
#  executes sont hors du depot (empreintes). --sortie DOSSIER : meme nom
#  dans DOSSIER, qui doit etre HORS du depot (refus sous la racine : --ecrire
#  est le seul chemin qui ecrit dans le depot). T0 : ligne "Versionnable
#  (--ecrire)" et, pour --combiner, empreintes du combinateur. Aucun fichier
#  n'est ecrit si le controle d'integrite echoue. La sortie d'une execution
#  d'un seul tenant porte, comme celle de --combiner, la ligne "Parametres :"
#  lue par tests/calibration_mc_t8.R (controles (e3) et (e4)).
#  Fonctions reprises par copie declaree de tests/calibration_mc_t8.R :
#  plateforme_calcul(), empreintes_code() (copie adaptee),
#  motifs_non_versionnable(), sous_depot() et ecrire_fichier() (copie
#  adaptee : nom du fichier, motifs en argument).
#  Duree mesuree (poste du mainteneur, R 4.3.1, 27/09/2026) : 0,6 a 0,7 s par
#  replication a --B-ic 999 ; 2 000 replications en 8 tranches : 1 312 s.
#  Code de sortie : 0 si les controles d'integrite tiennent, 1 sinon ; en
#  mode --combiner, 0 si la combinaison est acceptee, 1 si elle est refusee.
#  La lecture des taux (rubrique 6 des fiches, statut de constat de
#  simulation) revient a actuary et a docwriter.
###############################################################################

t_debut <- Sys.time()

# --- Options ------------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
lire_option <- function(nom, defaut) {
  i <- match(nom, ARGS)
  if (is.na(i)) return(defaut)
  if (i == length(ARGS)) stop("option ", nom, " sans valeur")
  ARGS[i + 1L]
}
OPT_R         <- as.integer(lire_option("--R", "2000"))
OPT_GRAINE    <- as.numeric(lire_option("--graine", "20260927"))
OPT_GRAINE_IC <- as.numeric(lire_option("--graine-ic", "20260831"))
OPT_B_IC      <- as.integer(lire_option("--B-ic", "999"))
OPT_JEU       <- lire_option("--jeu", "J1")
OPT_TRANCHE   <- lire_option("--tranche", NA_character_)
i_comb <- match("--combiner", ARGS)
FICHIERS_COMB <- if (is.na(i_comb)) character(0) else {
  reste <- ARGS[-seq_len(i_comb)]
  # les options --ecrire, --remplacer, --sortie DOSSIER et --issue N peuvent suivre la liste
  j <- match(c("--ecrire", "--remplacer", "--sortie", "--issue"), reste)
  fin <- if (all(is.na(j))) length(reste) else min(j, na.rm = TRUE) - 1L
  reste[seq_len(fin)]
}
if (!is.na(i_comb) && !length(FICHIERS_COMB)) stop("--combiner : aucun fichier")
OPT_ECRIRE <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_SORTIE <- lire_option("--sortie", NA_character_)
# --issue N : issue de rattachement du tableau ecrit (nom du fichier),
# obligatoire avec --ecrire et --sortie, sans valeur par defaut (constat T1
# d'audit : pas d'ecrasement silencieux des tableaux de #122).
OPT_ISSUE <- lire_option("--issue", NA_character_)
if ((OPT_ECRIRE || !is.na(OPT_SORTIE)) && (is.na(OPT_ISSUE) || !grepl("^[1-9][0-9]*$", OPT_ISSUE)))
  stop("--ecrire et --sortie exigent --issue N (N entier positif, issue de rattachement du tableau)")
if (OPT_ECRIRE && !is.na(OPT_SORTIE)) stop("--ecrire et --sortie sont exclusifs")
if (OPT_REMPLACER && !OPT_ECRIRE) stop("--remplacer : reserve a --ecrire (remplacement d'un tableau suivi par git, #173)")
if ((OPT_ECRIRE || !is.na(OPT_SORTIE)) && !is.na(OPT_TRANCHE))
  stop("--tranche : sortie partielle, --ecrire et --sortie reserves a --combiner ou a une execution d'un seul tenant")
if (!is.na(OPT_SORTIE) && !dir.exists(OPT_SORTIE)) stop("--sortie : dossier introuvable : ", OPT_SORTIE)
if (!OPT_JEU %in% c("J1", "J2")) stop("--jeu : J1 ou J2")
# --seulement mw : volet Merz-Wuthrich seul (#89) ; "ln" : volet lognormal
# seul (comportement par defaut, inchange).
OPT_SEULEMENT <- lire_option("--seulement", "ln")
if (!OPT_SEULEMENT %in% c("ln", "mw")) stop("--seulement : ln ou mw")
VOLET_MW <- identical(OPT_SEULEMENT, "mw")
if (VOLET_MW) {
  if (!is.na(OPT_TRANCHE) || !is.na(i_comb)) stop("--seulement mw : --tranche et --combiner reserves au volet lognormal")
  hors_mw <- intersect(c("--jeu", "--graine-ic", "--B-ic"), ARGS)
  if (length(hors_mw)) stop("--seulement mw : option(s) du volet lognormal sans objet : ", paste(hors_mw, collapse = ", "))
}
# Nom du volet dans le fichier ecrit (--ecrire, --sortie).
NOM_FICHIER <- if (VOLET_MW) "MW" else OPT_JEU
if (!is.finite(OPT_R) || OPT_R < 1L) stop("--R : entier >= 1")

# Configuration de run_engine() reproduite (cas de reference "premium").
METHODE <- "premium"; SEGMENT <- 1; ANNEXE <- "II"; NATURE <- "brutes"
ALPHA <- 0.10; THETA_EQUIV <- 0.10

# --- Chargement du moteur et des outils --------------------------------------
DOSSIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) dirname(f) else if (file.exists("tests/outils_tests.R")) "tests" else "."
})
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))
# --B-ic est passe a run_engine() : il doit etre au moins B_MIN_USAGE du moteur
# (erreur d'usage en dessous ; constat C1 de la revue finale d'E1), seuil qui
# couvre celui de l'IC bootstrap (plus de 20 replications).
if (!is.finite(OPT_B_IC) || OPT_B_IC < B_MIN_USAGE)
  stop(sprintf("--B-ic : entier >= B_MIN_USAGE = %d (minimum admis par run_engine())", B_MIN_USAGE))

# Commit du depot (voir l'en-tete) ; "inconnu" si git est indisponible.
commit_depot <- function() {
  git <- function(...) tryCatch(suppressWarnings(system2("git", c("-C", RACINE, ...), stdout = TRUE, stderr = FALSE)),
                                error = function(e) character(0))
  h <- git("rev-parse", "HEAD")
  if (length(h) != 1L || !grepl("^[0-9a-f]{40}$", h)) return("inconnu")
  if (length(git("status", "--porcelain", "--untracked-files=no"))) paste(h, "(arbre de travail modifi\u00e9)") else h
}

# Plateforme de calcul (#171) : R, systeme, machine, BLAS, LAPACK (copie de
# tests/calibration_mc_t8.R). Champ du contexte : des tranches calculees sur
# des plateformes differentes ne se combinent pas (certains comptes dependent
# de l'optimiseur : regime de delta chapeau, reperes proches d'un seuil).
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(extSoftVersion()["BLAS"]), txt(La_library()), txt(La_version()))
}

# Empreintes md5 du code execute (#171, elargie par le mainteneur le
# 30/09/2026 ; copie adaptee de empreintes_code() de
# tests/calibration_mc_t8.R : script lu dans --file=, aucun fichier lu en
# plus) : moteur du depot, tests/outils_tests.R effectivement charge (celui
# du dossier du script), script execute ; "depot" ou "hors depot" selon que
# le fichier charge est celui du depot. Champ du contexte : un code different
# au meme commit (copie modifiee de outils_tests.R ou du moteur) change le
# contexte, et --combiner refuse. Lues au debut du calcul.
empreintes_code <- function(script_depot) {
  fichier <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  fichier <- if (length(fichier) == 1L) fichier else NA_character_
  meme <- function(a, b) !is.na(a) && file.exists(a) && file.exists(b) &&
    identical(normalizePath(a), normalizePath(b))
  md5 <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
  lieu <- function(f, ref) if (meme(f, file.path(RACINE, ref))) "d\u00e9p\u00f4t" else "hors d\u00e9p\u00f4t"
  outils <- file.path(DOSSIER_SCRIPT, "outils_tests.R")
  paste(c(sprintf("R/engine.R %s", md5(file.path(RACINE, "R", "engine.R"))),
          sprintf("tests/outils_tests.R charg\u00e9 (%s) %s", lieu(outils, "tests/outils_tests.R"), md5(outils)),
          sprintf("script ex\u00e9cut\u00e9 (%s) %s", lieu(fichier, script_depot), md5(fichier))), collapse = " ; ")
}
EMPREINTES <- empreintes_code("tests/taux_franchissement_reperes.R")

# Motifs qui interdisent --ecrire (tableau versionne) : commit non propre ou
# code hors du depot ; quoi : "des tranches", "de la combinaison" ou "de
# l'execution" (copie de tests/calibration_mc_t8.R).
motifs_non_versionnable <- function(commit, empreintes, quoi = "des tranches") {
  m <- character(0)
  if (!grepl("^[0-9a-f]{40}$", commit))
    m <- c(m, sprintf("commit %s \u00ab %s \u00bb (arbre de travail modifi\u00e9, script non suivi ou git indisponible)", quoi, commit))
  if (grepl("hors d\u00e9p\u00f4t", empreintes, fixed = TRUE))
    m <- c(m, sprintf("tests/outils_tests.R ou script ex\u00e9cut\u00e9s %s hors du d\u00e9p\u00f4t", quoi))
  m
}
# Chemin (existant) sous la racine du depot (copie de tests/calibration_mc_t8.R) :
# --sortie doit viser hors du depot ; --ecrire est le seul chemin qui ecrit
# dans le depot.
sous_depot <- function(chemin) {
  # separateur "/" sur toutes les plateformes (normalizePath() rend des "\\"
  # sous Windows, ou .Platform$file.sep vaut pourtant "/") ; casse ignoree
  # sous Windows, dont le systeme de fichiers ne la distingue pas
  d <- normalizePath(chemin, winslash = "/", mustWork = TRUE)
  r <- normalizePath(RACINE, winslash = "/", mustWork = TRUE)
  if (.Platform$OS.type == "windows") { d <- tolower(d); r <- tolower(r) }
  identical(d, r) || startsWith(d, paste0(r, "/"))
}
if (!is.na(OPT_SORTIE) && sous_depot(OPT_SORTIE))
  stop("--sortie : dossier sous le depot refuse (--ecrire est le seul chemin qui ecrit dans le depot) : ", OPT_SORTIE)
# Ecriture du tableau (--ecrire ou --sortie) ; nv : motifs de non-versionnement
# (--ecrire refuse, code 1, rien d'ecrit, s'il y en a).
DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
# Fichier cible ; refus (code 1) s'il existe deja : jamais d'ecrasement
# (constat T1 d'audit). Verifie des le debut, avant tout calcul, et de
# nouveau au moment d'ecrire. Avec --ecrire, garde d'ecrasement d'abord
# (#173) : refus d'un fichier suivi par git sans --remplacer ; avec
# --remplacer, seul un fichier suivi est remplace (un fichier existant non
# suivi reste refuse) ; attribut "remplaces" : fichier remplace et md5
# d'avant, cites par le T0.
cible_fichier <- function(jeu) {
  dossier <- if (OPT_ECRIRE) file.path(RACINE, "docs", "tableaux") else OPT_SORTIE
  f <- file.path(dossier, sprintf("%s-issue%s-%s.md", DATE_SORTIE, OPT_ISSUE, jeu))
  remplaces <- if (OPT_ECRIRE) garde_ecrasement(f, OPT_REMPLACER, RACINE) else NULL
  if (file.exists(f) && !length(ligne_remplacement(remplaces, f))) {
    message("--ecrire / --sortie refuse : fichier existant, jamais ecrase : ", f)
    quit(status = 1L)
  }
  structure(f, remplaces = remplaces)
}
ecrire_fichier <- function(jeu, lignes, nv) {
  if (!OPT_ECRIRE && is.na(OPT_SORTIE)) return(invisible(NULL))
  if (OPT_ECRIRE && length(nv)) {
    message("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
            " -- aucun fichier ecrit ; relancer sur un arbre propre, ou --sortie DOSSIER hors du depot")
    quit(status = 1L)
  }
  f <- cible_fichier(jeu)
  if (OPT_ECRIRE) lignes <- inserer_t0(lignes, ligne_remplacement(attr(f, "remplaces"), f))
  f <- as.vector(f)
  con <- file(f, open = "wb")
  writeLines(enc2utf8(lignes), con, useBytes = TRUE)
  close(con)
  message("\u00e9crit : ", f)
}
if ((OPT_ECRIRE || !is.na(OPT_SORTIE)) && !length(FICHIERS_COMB)) invisible(cible_fichier(NOM_FICHIER))
txt_versionnable <- function(nv) if (length(nv)) paste("non :", paste(nv, collapse = " ; ")) else "oui"

# Console en UTF-8 quelle que soit la locale (meme definition que
# tests/comparer_ajusteurs_bootstrap.R).
ecrire_console <- function(x) writeLines(enc2utf8(x), useBytes = TRUE)

# --- Mise en forme -------------------------------------------------------------
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
pct <- function(k, n) if (n > 0) sprintf("%.1f %%", 100 * k / n) else "NA"
ic_cp <- function(k, n) if (n > 0) {
  ci <- stats::binom.test(k, n)$conf.int
  sprintf("[%.1f %% ; %.1f %%]", 100 * ci[1], 100 * ci[2])
} else "NA"

# --- Reperes ---------------------------------------------------------------------
# cle : identifiant des comptes ; groupe : "diag" (repere d'un diagnostic,
# tableau T1) ou "regle" (regle de restitution R4 ou position de delta
# chapeau, tableau T1 bis : pas des reperes de diagnostic) ; seuil et source :
# affiches. Le seuil 4/T est celui que usp_tests() imprime ; 10 % est
# REPERE_INFLUENCE_SIGMA du moteur ; 20 %, 50 % et 80 % sont les reperes
# conventionnels des fiches (commentaire de usp_tests(), famille G) ; 1/2 est
# SEUIL_PUISSANCE_PENTE (regle de restitution R4, #44, convention). Le repere
# 2k/T des leviers est traite a part (deterministe a X fixes, voir l'en-tete).
LIGNE_COOK  <- "Points influents (distance de Cook)"
LIGNE_LEV   <- "Leviers (hat values)"
LIGNE_R2    <- "Coefficient de determination R2"
LIGNE_PENTE <- "Test de Student sur la pente (lm(y~x))"
LIGNE_FISH  <- "Test de Fisher (significativite globale)"
LIGNE_JACK  <- "Sensibilite au retrait d'une annee (jackknife)"
LIGNE_IC    <- "Largeur relative de l'IC bootstrap 90%"
# Lignes de usp_tests() ajoutees par l'issue #45, non reconstruites par
# traiter() et hors perimetre (aucun repere n'y porte ; voir l'en-tete) :
# libelles "test" exacts du moteur.
LIGNES_HORS_PERIMETRE <- c(
  "Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime)",
  "Rapport de vraisemblance : delta = 0 (variance lineaire en volume)",
  "Rapport de vraisemblance : delta = 1 (variance quadratique en volume)")
REPERES <- list(
  list(cle = "cook", groupe = "diag", libelle = "Distance de Cook : au moins une observation au-dessus",
       seuil = "4/T", source = "usp_tests() (d\u00e9tail de la ligne)"),
  list(cle = "r2", groupe = "diag", libelle = "R\u00b2 de lm(y ~ x) en dessous", seuil = "0,5",
       source = "usp_tests() (d\u00e9tail de la ligne)"),
  list(cle = "pente", groupe = "regle",
       libelle = "R\u00e8gle de restitution R4 (convention, #44) : Student pente et Fisher restitu\u00e9s en diagnostic",
       seuil = "puissance approch\u00e9e < 1/2", source = "SEUIL_PUISSANCE_PENTE (r\u00e8gle R4, #44)"),
  list(cle = "jack10", groupe = "diag", libelle = "Jackknife : \u00e9cart relatif max sur \u03c3_USP au-dessus", seuil = "10 %",
       source = "REPERE_INFLUENCE_SIGMA ; fiche du jackknife"),
  list(cle = "jack20", groupe = "diag", libelle = "Jackknife : \u00e9cart relatif max sur \u03c3_USP au-dessus", seuil = "20 %",
       source = "fiche du jackknife"),
  list(cle = "ic50", groupe = "diag", libelle = "IC bootstrap 90 % : largeur relative au-dessus", seuil = "50 %",
       source = "fiche de l'IC bootstrap"),
  list(cle = "ic80", groupe = "diag", libelle = "IC bootstrap 90 % : largeur relative au-dessus", seuil = "80 %",
       source = "fiche de l'IC bootstrap"),
  list(cle = "bord", groupe = "regle", libelle = "Position de \u03b4\u0302 : solution au bord (0 ou 1)",
       seuil = "TOL_DELTA_BORD", source = "usp_regime()"),
  list(cle = "bord0", groupe = "regle", libelle = "dont \u03b4\u0302 au bord 0",
       seuil = "\u03b4\u0302 \u2264 TOL_DELTA_BORD", source = "usp_regime()"),
  list(cle = "bord1", groupe = "regle", libelle = "dont \u03b4\u0302 au bord 1 (\u03c0\u0302 constant)",
       seuil = "\u03b4\u0302 \u2265 1 \u2212 TOL_DELTA_BORD", source = "usp_regime()")
)

# Libelles de T0 pour les lignes machine CONTEXTE (cle ASCII -> libelle).
LIBELLES_CONTEXTE <- c(
  jeu = "Jeu", modele = "Mod\u00e8le ajust\u00e9 (usp_ajuster())", configuration = "Configuration",
  sigma_usp = "\u03c3_USP observ\u00e9 (run_engine())", graines = "Graines", B_ic = "B de l'IC bootstrap",
  generateur = "G\u00e9n\u00e9rateur", commit = "Commit",
  plateforme = "Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)",
  empreintes = "Empreintes md5 du code ex\u00e9cut\u00e9",
  leviers = "Leviers (rep\u00e8re 2k/T, jeu observ\u00e9)",
  hors_perimetre = "Lignes de usp_tests() hors p\u00e9rim\u00e8tre (#45)")

# --- Mode --combiner ---------------------------------------------------------------
# Refus de la combinaison : message et code de sortie 1, aucun tableau.
refuser <- function(...) {
  message("--combiner : REFUS -- ", ...)
  quit(status = 1L)
}

# Lecture d'une sortie de tranche ; refus si elle est incomplete ou en echec.
lire_comptes <- function(f) {
  if (!file.exists(f)) refuser(f, " introuvable")
  l <- readLines(f, warn = FALSE, encoding = "UTF-8")
  champs <- function(etq) strsplit(sub(paste0("^", etq, "\t"), "", grep(paste0("^", etq, "\t"), l, value = TRUE)), "\t")
  unique1 <- function(etq) {
    x <- champs(etq)
    if (length(x) != 1L) refuser(f, " : ", length(x), " ligne(s) ", etq, " (une attendue) -- sortie de tranche incomplete ?")
    x[[1]]
  }
  par <- unique1("PARAMETRES")
  tr <- unique1("TRANCHE")
  integ <- champs("INTEGRITE")
  if (length(integ) != 1L) refuser(f, " : ligne INTEGRITE absente ou multiple")
  if (!identical(integ[[1]], "OK")) refuser(f, " : controle d'integrite de la tranche en ECHEC (INTEGRITE\t", integ[[1]][1], ")")
  n_ann <- suppressWarnings(as.integer(unique1("NCOMPTES")))
  fin <- unique1("FIN")
  non_vides <- l[nzchar(trimws(l))]
  if (!length(non_vides) || !startsWith(non_vides[length(non_vides)], "FIN\t"))
    refuser(f, " : la ligne FIN n'est pas la derniere ligne -- sortie tronquee ou modifiee")
  cp <- champs("COMPTE")
  if (is.na(n_ann) || length(cp) != n_ann || !identical(as.integer(fin), n_ann))
    refuser(f, sprintf(" : %d ligne(s) COMPTE lue(s), NCOMPTES = %s, FIN = %s -- sortie tronquee ou modifiee",
                       length(cp), n_ann, fin))
  if (any(lengths(cp) != 2L) || anyNA(suppressWarnings(as.numeric(vapply(cp, `[`, "", 2L)))))
    refuser(f, " : ligne COMPTE illisible")
  ctx <- champs("CONTEXTE")
  if (!length(ctx) || any(lengths(ctx) != 2L)) refuser(f, " : lignes CONTEXTE absentes ou illisibles")
  ctx <- stats::setNames(vapply(ctx, `[`, "", 2L), vapply(ctx, `[`, "", 1L))
  if (!setequal(names(ctx), names(LIBELLES_CONTEXTE)) || anyDuplicated(names(ctx)))
    refuser(f, " : lignes CONTEXTE incompletes (attendues : ", paste(names(LIBELLES_CONTEXTE), collapse = ", "), ")")
  list(parametres = par, debut = as.integer(tr[1]), fin = as.integer(tr[2]), contexte = ctx[names(LIBELLES_CONTEXTE)],
       comptes = stats::setNames(as.numeric(vapply(cp, `[`, "", 2L)), vapply(cp, `[`, "", 1L)))
}

# Lignes de T0 tirees du contexte (vecteur nomme par les cles de
# LIBELLES_CONTEXTE).
lignes_contexte <- function(ctx) vapply(names(LIBELLES_CONTEXTE), function(k)
  ligne_md(LIBELLES_CONTEXTE[[k]], ctx[[k]]), "")

# --- Tableaux a partir des comptes -------------------------------------------------
# cpt : vecteur nomme de comptes ("k|cle", "n|cle", "type|ligne|type",
# "inop|ligne", "nl|ligne", "k|lev_diff" et "n|lev_diff" : replications dont
# la valeur max h_t differe de celle du jeu observe) ; lev : texte du
# contexte "leviers".
tableau_reperes <- function(cpt, groupe) {
  g <- function(n) if (n %in% names(cpt)) cpt[[n]] else 0
  # T1 bis : la regle R4 n'est pas un repere (CONTEXT.md, "Indice
  # d'identifiabilite de la pente") ; premiere colonne nommee en consequence.
  L <- entete_md(c(if (identical(groupe, "diag")) "Rep\u00e8re" else "R\u00e8gle ou position",
                   "Seuil", "Source du seuil", "Franchi", "n", "Taux", "IC 95 % (Clopper-Pearson)"))
  for (r in REPERES) if (identical(r$groupe, groupe)) {
    k <- g(paste0("k|", r$cle)); n <- g(paste0("n|", r$cle))
    L <- c(L, ligne_md(r$libelle, r$seuil, r$source, k, n, pct(k, n), ic_cp(k, n)))
  }
  L
}
tableaux <- function(cpt, R, lev) {
  g <- function(n) if (n %in% names(cpt)) cpt[[n]] else 0
  note_n <- sprintf(paste("n : r\u00e9plications o\u00f9 la grandeur existe et porte une valeur finie",
                          "(sur %d). IC : incertitude Monte-Carlo sur le taux (fonction de R), pas",
                          "l'erreur d'approximation en T."), R)
  L <- c("### T1 -- taux de franchissement des rep\u00e8res des diagnostics (constat de simulation sous le mod\u00e8le ajust\u00e9)", "",
         tableau_reperes(cpt, "diag"), "", note_n, "",
         sprintf(paste("Leviers (rep\u00e8re 2k/T, k = 1) : d\u00e9terministe \u00e0 X fix\u00e9s (%s), hors des taux simul\u00e9s ;",
                       "valeur des r\u00e9plications identique \u00e0 celle du jeu observ\u00e9 : %.0f sur %.0f."),
                 lev, g("n|lev_diff") - g("k|lev_diff"), g("n|lev_diff")), "",
         "### T1 bis -- r\u00e8gle de restitution R4 et position de \u03b4\u0302 (constat de simulation sous le mod\u00e8le ajust\u00e9 ; pas des rep\u00e8res de diagnostic)", "",
         tableau_reperes(cpt, "regle"), "", note_n, "")
  lignes <- unique(sub("^nl\\|", "", grep("^nl\\|", names(cpt), value = TRUE)))
  types <- c("test", "diagnostic", "non applicable", "procedure de decision")
  L <- c(L, "### T2 -- classement des lignes de usp_tests() sur les r\u00e9plications (lignes non restitu\u00e9es \"test\" au moins une fois)", "",
         entete_md(c("Ligne", "n", "test", "diagnostic", "dont inop\u00e9rant (INFO)", "non applicable",
                     "proc\u00e9dure de d\u00e9cision")))
  for (li in lignes) {
    n <- g(paste0("nl|", li)); kt <- vapply(types, function(ty) g(paste0("type|", li, "|", ty)), numeric(1))
    ki <- g(paste0("inop|", li))
    if (kt[["test"]] == n && ki == 0) next
    L <- c(L, ligne_md(li, n, pct(kt[["test"]], n), pct(kt[["diagnostic"]], n), pct(ki, n),
                       pct(kt[["non applicable"]], n), pct(kt[["procedure de decision"]], n)))
  }
  c(L, "", "Inop\u00e9rant : ligne de type test dont p_min \u2265 \u03b1, restitu\u00e9e diagnostic INFO (r\u00e8gle R1, #44) ; compt\u00e9e aussi dans la colonne diagnostic.", "",
    paste0("Hors p\u00e9rim\u00e8tre, non reconstruites dans les r\u00e9plications et absentes de T2 (aucun rep\u00e8re n'y porte ; #45) : ",
           paste0("\"", LIGNES_HORS_PERIMETRE, "\"", collapse = ", "), "."), "")
}

# --- Volet Merz-Wuthrich (issue #89 ; --seulement mw) -----------------------------
# Plan de simulation : voir l'en-tete. Le volet s'execute ici et termine le
# script (quit) ; le volet lognormal qui suit n'est pas lance.
# Triangle simule sous le modele de Mack ajuste aj, a partir d'un vecteur eps
# de longueur sum_{i=0}^{I-1} (I - i) ; NULL si une cellule simulee est <= 0
# ou non finie (essai rejete).
mw_simuler_triangle <- function(aj, eps) {
  I <- aj$I; tri <- aj$tri; s <- sqrt(aj$sigma2); k <- 0L
  for (i in 0:(I - 1L)) for (j in 0:(I - i - 1L)) {
    k <- k + 1L
    v <- aj$f[j + 1] * tri[i + 1, j + 1] + s[j + 1] * sqrt(tri[i + 1, j + 1]) * eps[k]
    if (!is.finite(v) || v <= 0) return(NULL)
    tri[i + 1, j + 2] <- v
  }
  tri
}
ligne_md_v <- function(v) ligne_md(paste(v, collapse = " | "))
volet_mw <- function() {
  integ <- character(0)
  t0 <- Sys.time()
  TRI <- .tri
  AJ0 <- mw_ajuster(TRI)
  I <- AJ0$I
  if (!all(is.finite(AJ0$f)) || !all(is.finite(AJ0$sigma2)) || any(AJ0$sigma2 < 0))
    integ <- c(integ, "triangle observe : f chapeau ou sigma2 chapeau non fini ou negatif")
  INF0 <- mw_influence(AJ0)
  colorees0 <- sprintf("(%d,%d)", INF0$i[INF0$fort_dfbetas], INF0$j[INF0$fort_dfbetas])
  ATTENDUES <- c("(0,2)", "(0,3)", "(1,4)")
  if (!identical(sort(colorees0), sort(ATTENDUES)))
    integ <- c(integ, sprintf("triangle observe : cellules colorees %s, attendues %s",
                              paste(colorees0, collapse = " "), paste(ATTENDUES, collapse = " ")))
  CELL <- paste(INF0$i, INF0$j)
  N_J <- vapply(INF0$j, function(j) I - j, numeric(1))
  n_eps <- as.integer(I * (I + 1) / 2)
  # Tirages : un seul flux, avant tout calcul.
  sim <- engine_sous_graine(OPT_GRAINE, {
    tris <- vector("list", OPT_R); rejets <- 0L
    for (b in seq_len(OPT_R)) repeat {
      tb <- mw_simuler_triangle(AJ0, stats::rnorm(n_eps))
      if (!is.null(tb)) { tris[[b]] <- tb; break }
      rejets <- rejets + 1L
    }
    list(tris = tris, rejets = rejets)
  })
  t_tirage <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  t0 <- Sys.time()
  DFB <- matrix(NA_real_, OPT_R, length(CELL)); FORT <- matrix(FALSE, OPT_R, length(CELL))
  NB <- matrix(FALSE, OPT_R, length(CELL))
  n_contrat <- 0L; n_cellules <- 0L
  for (b in seq_len(OPT_R)) {
    inf <- mw_influence(mw_ajuster(sim$tris[[b]]))
    if (!identical(paste(inf$i, inf$j), CELL)) { n_cellules <- n_cellules + 1L; next }
    if (!identical(inf$fort_dfbetas, !is.na(inf$dfbetas) & abs(inf$dfbetas) > inf$repere_dfbetas) ||
        !isTRUE(all.equal(inf$repere_dfbetas, REPERE_DFBETAS_MW / sqrt(N_J), tolerance = 0)) ||
        !is.logical(inf$dfbetas_non_borne) || anyNA(inf$dfbetas_non_borne) ||
        any(inf$dfbetas_non_borne & !is.na(inf$dfbetas)))
      n_contrat <- n_contrat + 1L
    DFB[b, ] <- inf$dfbetas; FORT[b, ] <- inf$fort_dfbetas; NB[b, ] <- inf$dfbetas_non_borne
  }
  t_rep <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  if (n_cellules) integ <- c(integ, sprintf("%d replication(s) : cellules de mw_influence() differentes de celles du triangle observe", n_cellules))
  if (n_contrat) integ <- c(integ, sprintf("%d replication(s) : fort_dfbetas, repere_dfbetas ou dfbetas_non_borne hors contrat (|DFBETAS| > %g/sqrt(n_j), NA = FALSE ; non borne logique, sans NA, DFBETAS NA)",
                                           n_contrat, REPERE_DFBETAS_MW))
  ABS2 <- !is.na(DFB) & abs(DFB) > 2
  # M1 : taux par n_j et global (n_j >= 3).
  ligne_taux <- function(lib, cols) {
    n_cel <- OPT_R * length(cols); d <- DFB[, cols, drop = FALSE]
    n_def <- sum(!is.na(d)); k1 <- sum(FORT[, cols]); k2 <- sum(ABS2[, cols])
    ligne_md(lib, length(cols), n_cel, sprintf("%d (%s)", n_cel - n_def, pct(n_cel - n_def, n_cel)),
             k1, pct(k1, n_def), ic_cp(k1, n_def), k2, pct(k2, n_def), ic_cp(k2, n_def))
  }
  L1 <- entete_md(c("n_j", "Cellules par triangle", "Cellules (R × cellules)", "DFBETAS NA",
                    "Franchi 2/√n_j", "Taux 2/√n_j", "IC 95 % (Clopper-Pearson)",
                    "Franchi |DFBETAS| > 2", "Taux absolu 2", "IC 95 % (Clopper-Pearson)"))
  for (n in sort(unique(N_J[N_J >= 3]), decreasing = TRUE)) L1 <- c(L1, ligne_taux(as.character(n), which(N_J == n)))
  L1 <- c(L1, ligne_taux("global (n_j ≥ 3)", which(N_J >= 3)))
  c2 <- which(N_J == 2)
  na2 <- sum(is.na(DFB[, c2])); fort2 <- sum(FORT[, c2])
  c3 <- which(N_J >= 3)
  na3 <- sum(is.na(DFB[, c3])); nb3 <- sum(NB[, c3]); nb3_tri <- sum(rowSums(NB) > 0)
  # M2 : cellules colorees par triangle.
  nb <- rowSums(FORT); nb2 <- rowSums(ABS2)
  resume <- function(v) {
    q <- stats::quantile(v, c(0, .05, .25, .5, .75, .95, 1), names = FALSE, type = 7)
    m <- mean(v); e <- stats::sd(v) / sqrt(length(v))
    c(sprintf("%.3f", m), sprintf("[%.3f ; %.3f]", m - 1.96 * e, m + 1.96 * e), sprintf("%.3f", stats::sd(v)),
      paste(sprintf("%g", q), collapse = " / "))
  }
  L2 <- c(entete_md(c("Repère", "Moyenne", "IC 95 % de la moyenne (asymptotique, R triangles iid)", "Écart-type",
                      "min / 5 % / 25 % / médiane / 75 % / 95 % / max")),
          ligne_md_v(c("2/√n_j (fort_dfbetas)", resume(nb))),
          ligne_md_v(c("absolu 2", resume(nb2))))
  dist <- table(factor(nb, levels = 0:max(nb)))
  L3 <- c(entete_md(c("Cellules colorées (2/√n_j)", names(dist))),
          ligne_md_v(c("Triangles", as.vector(dist))),
          ligne_md_v(c("Part", vapply(as.vector(dist), function(k) pct(k, OPT_R), ""))))
  PAR <- sprintf("volet=mw;triangle=reserve2;R=%d;graine=%.0f;repere=%g/sqrt(n_j)", OPT_R, OPT_GRAINE, REPERE_DFBETAS_MW)
  NV <- motifs_non_versionnable(commit_depot(), EMPREINTES, "de l'exécution")
  t_tot <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
  sortie <- c(
    "## Taux de franchissement du repère DFBETAS de mw_influence() sous le modèle de Mack ajusté (issue #89)", "",
    sprintf("Paramètres : %s", PAR), "",
    "### T0 -- contexte", "",
    entete_md(c("Grandeur", "Valeur")),
    ligne_md("Triangle", sprintf("reserve2 : tests/donnees/triangle_mw.csv (.tri de tests/outils_tests.R), I = J = %d", I)),
    ligne_md("Modèle ajusté (mw_ajuster())", sprintf("f̂_j = %s ; σ̂²_j = %s",
                                                              paste(sprintf("%.6g", AJ0$f), collapse = ", "),
                                                              paste(sprintf("%.6g", AJ0$sigma2), collapse = ", "))),
    ligne_md("Simulation", paste("C(i,j+1) = f̂_j C(i,j) + σ̂_j √C(i,j) ε, ε ~ N(0,1) iid ;",
                                 "première colonne observée fixée ; essai rejeté et redessiné si une cellule simulée est ≤ 0")),
    ligne_md("Repère de lecture", sprintf("|DFBETAS| > REPERE_DFBETAS_MW / √n_j, REPERE_DFBETAS_MW = %g", REPERE_DFBETAS_MW)),
    ligne_md("Cellules colorées sur le triangle observé", paste(colorees0, collapse = " ")),
    ligne_md("Graine (jeux simulés)", sprintf("%.0f, sous engine_sous_graine()", OPT_GRAINE)),
    ligne_md("Générateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
    ligne_md("Réplications", sprintf("%d", OPT_R)),
    ligne_md("Essais rejetés et redessinés (cellule ≤ 0)", sprintf("%d", sim$rejets)),
    ligne_md("Commit", commit_depot()),
    ligne_md("Plateforme de calcul (R, système, machine, BLAS, LAPACK)", plateforme_calcul()),
    ligne_md("Empreintes md5 du code exécuté", EMPREINTES),
    ligne_md("Durée (s)", sprintf("tirages %.1f ; réplications %.1f ; total %.1f", t_tirage, t_rep, t_tot)),
    ligne_md("Versionnable (--ecrire)", txt_versionnable(NV)),
    ligne_md("Contrôle d'intégrité", if (length(integ)) "ÉCHEC" else "OK"), "",
    "### M1 -- taux de franchissement par cellule, par n_j (constat de simulation sous le modèle ajusté)", "",
    L1, "",
    sprintf(paste("n_j = 2 : %d cellule(s) par triangle, DFBETAS NA par construction (s²_(i) sans degré de liberté) :",
                  "NA %d sur %d, colorées %d. DFBETAS NA hors n_j = 2 : voir la colonne « DFBETAS NA » (ligne globale)."),
            length(c2), na2, OPT_R * length(c2), fort2),
    sprintf(paste("n_j ≥ 3 : DFBETAS NA %d sur %d ; dont DFBETAS non borné (dfbetas_non_borne) %d,",
                  "dans %d triangle(s)."), na3, OPT_R * length(c3), nb3, nb3_tri),
    paste("Taux : sur les cellules où DFBETAS est défini. IC : incertitude Monte-Carlo sur le taux (fonction de R),",
          "pas l'erreur d'approximation en T ; Clopper-Pearson suppose des cellules indépendantes, ce que ne sont",
          "pas les cellules d'une même colonne ni d'un même triangle : IC indicatif."), "",
    "### M2 -- nombre de cellules colorées par triangle (sur les cellules n_j ≥ 3)", "",
    L2, "", L3, "",
    if (length(integ)) c("Contrôle d'intégrité : ÉCHEC", paste("-", integ), ""))
  ecrire_console(sortie)
  if (!length(integ)) ecrire_fichier(NOM_FICHIER, sortie, NV)
  quit(status = if (length(integ)) 1L else 0L)
}
if (VOLET_MW) volet_mw()

if (length(FICHIERS_COMB)) {
  parts <- lapply(FICHIERS_COMB, lire_comptes)
  par <- unique(vapply(parts, `[[`, "", "parametres"))
  if (length(par) != 1L) refuser("parametres differents entre les fichiers")
  ctx <- unique(lapply(parts, `[[`, "contexte"))
  if (length(ctx) != 1L) {
    k_diff <- names(LIBELLES_CONTEXTE)[vapply(names(LIBELLES_CONTEXTE), function(k)
      length(unique(vapply(parts, function(p) p$contexte[[k]], ""))) > 1L, logical(1))]
    refuser("contexte (T0) different entre les tranches : ", paste(k_diff, collapse = ", "))
  }
  ctx <- ctx[[1]]
  R_tot <- as.integer(sub("^.*;R=([0-9]+);.*$", "\\1", par))
  idx <- unlist(lapply(parts, function(p) seq.int(p$debut, p$fin)))
  if (anyDuplicated(idx) || !setequal(idx, seq_len(R_tot)))
    refuser("les tranches ne couvrent pas 1..", R_tot, " exactement une fois")
  cles <- unique(unlist(lapply(parts, function(p) names(p$comptes))))
  cpt <- stats::setNames(vapply(cles, function(k) sum(vapply(parts, function(p)
    if (k %in% names(p$comptes)) p$comptes[[k]] else 0, numeric(1))), numeric(1)), cles)
  commit_comb <- commit_depot()
  nv <- c(motifs_non_versionnable(ctx[["commit"]], ctx[["empreintes"]]),
          motifs_non_versionnable(commit_comb, EMPREINTES, "de la combinaison"))
  if (OPT_ECRIRE && length(nv))
    refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
            " -- relancer sur un arbre propre, ou utiliser --sortie DOSSIER hors du depot")
  # fichier cible (et garde d'ecrasement, #173) apres le refus precedent
  if (OPT_ECRIRE || !is.na(OPT_SORTIE)) invisible(cible_fichier(sub("^jeu=(J[12]);.*$", "\\1", par)))
  sortie <- c(c(sprintf("## Taux de franchissement des rep\u00e8res -- combinaison de %d tranche(s)", length(parts)), "",
                   sprintf("Param\u00e8tres : %s", par), "",
                   "### T0 -- contexte (identique dans toutes les tranches, v\u00e9rifi\u00e9)", "",
                   entete_md(c("Grandeur", "Valeur")),
                   lignes_contexte(ctx),
                   ligne_md("R\u00e9plications", sprintf("%d (%d tranche(s) : %s)", R_tot, length(parts),
                                                          paste(vapply(parts, function(p) sprintf("%d-%d", p$debut, p$fin), ""),
                                                                collapse = ", "))),
                   ligne_md("Commit de la combinaison", commit_comb),
                   ligne_md("Empreintes md5 du combinateur", EMPREINTES),
                   ligne_md("Versionnable (--ecrire)", txt_versionnable(nv)),
                   ligne_md("Contr\u00f4le d'int\u00e9grit\u00e9", sprintf("OK dans les %d tranche(s) (agr\u00e9g\u00e9 : OK)", length(parts))), ""),
              tableaux(cpt, R_tot, ctx[["leviers"]]))
  ecrire_console(sortie)
  ecrire_fichier(sub("^jeu=(J[12]);.*$", "\\1", par), sortie, nv)
  quit(status = 0L)
}

# --- Jeu et modele ajuste ----------------------------------------------------------
lire_j2 <- function() {
  f <- file.path(RACINE, "tests", "unitaires", "test_controles_numeriques.R")
  l <- readLines(f)
  env <- new.env()
  for (v in c("xi", "yi")) {
    li <- grep(sprintf("^%s <- c\\(", v), l, value = TRUE)
    if (length(li) != 1L) stop("J2 : ligne '", v, " <- c(' introuvable ou multiple dans ", f)
    eval(parse(text = li), envir = env)
  }
  list(x = env$xi, y = env$yi)
}
JEU <- if (OPT_JEU == "J1")
  list(x = .ln$xt, y = .ln$yt, libelle = "J1 : tests/donnees/donnees_ln.csv (jeu des cas de r\u00e9f\u00e9rence)") else
  c(lire_j2(), libelle = "J2 : xi, yi de tests/unitaires/test_controles_numeriques.R (\u03b4 estim\u00e9 int\u00e9rieur)")
X <- JEU$x; T_ <- length(X)
FIT0 <- usp_ajuster(X, JEU$y)
SIGMA_STD <- usp_parametre_standard(METHODE, SEGMENT, ANNEXE, NATURE, NULL)$sigma_standard
BAREME <- usp_bareme_segment(SEGMENT, ANNEXE)

# Tranche
if (is.na(OPT_TRANCHE)) { DEBUT <- 1L; FIN <- OPT_R } else {
  m <- regmatches(OPT_TRANCHE, regexec("^([0-9]+)/([0-9]+)$", OPT_TRANCHE))[[1]]
  if (length(m) != 3L) stop("--tranche : forme i/K attendue")
  i <- as.integer(m[2]); K <- as.integer(m[3])
  if (K < 1L || i < 1L || i > K || K > OPT_R) stop("--tranche : 1 <= i <= K <= R")
  DEBUT <- as.integer(floor((i - 1) * OPT_R / K)) + 1L; FIN <- as.integer(floor(i * OPT_R / K))
}

# Les R jeux simules, d'un seul flux, avant tout calcul (independants du
# decoupage en tranches).
YSIM <- engine_sous_graine(OPT_GRAINE, t(vapply(seq_len(OPT_R), function(b) usp_simuler(FIT0), numeric(T_))))

# --- Traitement d'une replication ------------------------------------------------------
# Largeur relative de l'IC bootstrap 90 % de sigma_USP : boucle de
# usp_bootstrap() (usp_simuler() puis usp_ajuster_rapide() depuis l'optimum,
# replication ecartee si le reajustement echoue), sans les statistiques du
# catalogue ; IC et largeur comme run_engine(). Rend aussi sigma_boot (controle
# d'integrite).
ic_bootstrap <- function(fit, param, graine, B) {
  sig <- engine_sous_graine(graine, {
    s <- rep(NA_real_, B)
    for (k in seq_len(B)) {
      yk <- usp_simuler(fit)
      f <- try(usp_ajuster_rapide(fit$x, yk, fit$delta, fit$gamma), silent = TRUE)
      if (inherits(f, "try-error")) next
      s[k] <- f$sigma
    }
    s
  })
  sig <- sig[is.finite(sig)]
  usp_b <- param$credibilite * sig * param$correction_taille + (1 - param$credibilite) * param$sigma_standard
  ic <- if (length(usp_b) > 20) stats::quantile(usp_b, c(.025, .05, .5, .95, .975)) else NULL
  list(sigma_boot = sig, largeur = if (!is.null(ic)) unname((ic[4] - ic[2]) / param$sigma_usp) else NULL)
}

# Table des tests d'un jeu (x, y) traitee comme par run_engine().
traiter <- function(x, y, graine_ic) {
  fb <- usp_ajuster(x, y)
  param <- usp_parametre(fb, SIGMA_STD, BAREME)
  jack <- usp_jackknife(fb, SIGMA_STD, BAREME)
  d_jack <- jack$sigma_usp - param$sigma_usp
  jack_calcule <- any(is.finite(d_jack))
  fb$ecart_jackknife <- if (jack_calcule) max(abs(d_jack), na.rm = TRUE) / param$sigma_usp else NULL
  icb <- ic_bootstrap(fb, param, graine_ic, OPT_B_IC)
  fb$largeur_ic <- icb$largeur
  i_jack <- if (jack_calcule) which.max(abs(d_jack)) else NULL
  rob <- list(jack_annee = i_jack, jack_usp = if (jack_calcule) d_jack[i_jack] / param$sigma_usp else NULL)
  so <- .mc_evaluer(USP_CATALOGUE_MC, .usp_contexte_mc(fb$x, fb$y, fb$z))
  boot <- list(stats_obs = as.list(so), p_mc = so * 0 + 0.5, err_mc = so * 0 + 0.01,
               motif_mc = stats::setNames(rep(NA_character_, length(so)), names(so)))
  tt <- usp_tests(fb, boot, ALPHA, theta_equiv = THETA_EQUIV, delta_equiv = NULL,
                  robustesse = rob, methode = METHODE)
  list(fit = fb, tests = tt, sigma_boot = icb$sigma_boot, regime = usp_regime(fb$delta, fb$x))
}

# Comptes d'une replication, ajoutes a cpt.
compter <- function(cpt, r) {
  ajoute <- function(cle, v) { cpt[cle] <<- (if (cle %in% names(cpt)) cpt[[cle]] else 0) + v }
  noms <- vapply(r$tests, `[[`, "", "test")
  ligne <- function(nm) { i <- match(nm, noms); if (is.na(i)) NULL else r$tests[[i]] }
  lu <- function(nm) { l <- ligne(nm); if (is.null(l) || !is.finite(l$estim)) NA_real_ else l$estim }
  repere <- function(cle, franchi) if (!is.na(franchi)) { ajoute(paste0("n|", cle), 1); ajoute(paste0("k|", cle), franchi) }
  for (nm in c(LIGNE_COOK, LIGNE_LEV, LIGNE_R2, LIGNE_PENTE, LIGNE_FISH))
    if (is.null(ligne(nm))) stop("ligne \"", nm, "\" absente de usp_tests() : script a mettre a jour")
  repere("cook", lu(LIGNE_COOK) > 4 / T_)
  # Leviers : pas un taux simule (deterministe a X fixes) ; on compte les
  # replications dont max h_t differe de celui du jeu observe (LEV_OBS).
  repere("lev_diff", !identical(lu(LIGNE_LEV), LEV_OBS))
  r2 <- ligne(LIGNE_R2)
  repere("r2", if (identical(r2$type, "diagnostic") && is.finite(r2$estim)) r2$estim < 0.5 else NA)
  tp <- ligne(LIGNE_PENTE)$type
  repere("pente", if (tp %in% c("test", "diagnostic")) tp == "diagnostic" else NA)
  j <- lu(LIGNE_JACK); repere("jack10", j > REPERE_INFLUENCE_SIGMA); repere("jack20", j > 0.20)
  w <- lu(LIGNE_IC); repere("ic50", w > 0.50); repere("ic80", w > 0.80)
  repere("bord", r$regime$delta_au_bord)
  repere("bord0", r$fit$delta <= TOL_DELTA_BORD)
  repere("bord1", r$fit$delta >= 1 - TOL_DELTA_BORD)
  for (l in r$tests) {
    ajoute(paste0("nl|", l$test), 1)
    ajoute(paste0("type|", l$test, "|", l$type), 1)
    if (!is.null(l$detail) && startsWith(l$detail, "TEST INOPERANT")) ajoute(paste0("inop|", l$test), 1)
  }
  cpt
}

# --- Controle d'integrite sur le jeu observe -------------------------------------------
# run_engine() a B = --B-ic, graine --graine-ic, et traiter() a la meme graine
# doivent donner : le meme sigma_boot (identical) ; les memes lignes, types,
# statistiques et estimations (identical), res$tests etant prive des lignes
# LIGNES_HORS_PERIMETRE (#45), qui doivent y figurer chacune exactement une
# fois (sinon constante perimee : ECHEC).
integrite <- character(0)
t0 <- Sys.time()
res <- run_engine(xt = X, yt = JEU$y, methode = METHODE, segment = SEGMENT, annexe = ANNEXE,
                  nature_donnees = NATURE, B = OPT_B_IC, alpha = ALPHA, theta_equiv = THETA_EQUIV,
                  seed = OPT_GRAINE_IC)
obs <- traiter(X, JEU$y, OPT_GRAINE_IC)
if (!isTRUE(res$ok)) integrite <- c(integrite, "run_engine() sur le jeu observe : ok = FALSE")
if (!identical(obs$sigma_boot, res$bootstrap$sigma_boot))
  integrite <- c(integrite, "sigma_boot reconstruit different de res$bootstrap$sigma_boot")
champs <- c("test", "type", "stat", "estim")
noms_res <- vapply(res$tests, `[[`, "", "test")
n_hp <- vapply(LIGNES_HORS_PERIMETRE, function(nm) sum(noms_res == nm), numeric(1))
if (any(n_hp != 1))
  integrite <- c(integrite, paste("res$tests : ligne(s) hors perimetre (#45) absente(s) ou multiple(s) :",
                                  paste0("\"", LIGNES_HORS_PERIMETRE[n_hp != 1], "\"", collapse = ", ")))
tests_res <- res$tests[!noms_res %in% LIGNES_HORS_PERIMETRE]
if (length(obs$tests) != length(tests_res) ||
    !identical(lapply(obs$tests, `[`, champs), lapply(tests_res, `[`, champs)))
  integrite <- c(integrite, "usp_tests() reconstruit : lignes, types, statistiques ou estimations differents de res$tests (hors LIGNES_HORS_PERIMETRE)")
t_controle <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
# Repere des leviers sur le jeu observe (ligne de run_engine()).
LEV_OBS <- local({
  i <- match(LIGNE_LEV, vapply(res$tests, `[[`, "", "test"))
  if (is.na(i)) NA_real_ else res$tests[[i]]$estim
})
if (!is.finite(LEV_OBS)) integrite <- c(integrite, "ligne des leviers absente ou non finie sur le jeu observe")

# --- Replications ----------------------------------------------------------------------
t0 <- Sys.time()
cpt <- numeric(0)
for (b in seq.int(DEBUT, FIN))
  cpt <- compter(cpt, traiter(X, YSIM[b, ], OPT_GRAINE_IC + b))
t_rep <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
if (("k|lev_diff" %in% names(cpt)) && cpt[["k|lev_diff"]] > 0)
  integrite <- c(integrite, sprintf("leviers : max h_t different de celui du jeu observe dans %.0f replication(s) (repere suppose deterministe a X fixes)",
                                    cpt[["k|lev_diff"]]))

# --- Sortie ------------------------------------------------------------------------------
PAR <- sprintf("jeu=%s;R=%d;graine=%.0f;graine_ic=%.0f;B_ic=%d;methode=%s;segment=%d;annexe=%s;nature=%s;alpha=%g",
               OPT_JEU, OPT_R, OPT_GRAINE, OPT_GRAINE_IC, OPT_B_IC, METHODE, SEGMENT, ANNEXE, NATURE, ALPHA)
# Contexte de T0 hors durees et hors bornes de la tranche : identique entre
# tranches, verifie par --combiner (lignes CONTEXTE).
CTX <- c(
  jeu = JEU$libelle,
  modele = sprintf("\u03b4\u0302 = %.6g ; \u03b3\u0302 = %.6g ; \u03b2\u0302 = %.6g ; \u03c3\u0302 = %.6g ; \u03c0\u0302 constant : %s",
                   FIT0$delta, FIT0$gamma, FIT0$beta, FIT0$sigma, usp_regime(FIT0$delta, X)$pi_constant),
  configuration = sprintf("m\u00e9thode %s, segment %d de l'annexe %s, donn\u00e9es %s, \u03b1 = %g, \u03c3 standard = %g, bar\u00e8me %s",
                          METHODE, SEGMENT, ANNEXE, NATURE, ALPHA, SIGMA_STD, BAREME),
  sigma_usp = sprintf("%.6g", res$parametre_final$sigma_usp),
  graines = sprintf("jeux simul\u00e9s %.0f ; IC de la r\u00e9plication b : %.0f + b", OPT_GRAINE, OPT_GRAINE_IC),
  B_ic = as.character(OPT_B_IC),
  generateur = paste(ENGINE_RNG_KIND, collapse = ", "),
  commit = commit_depot(),
  plateforme = plateforme_calcul(),
  empreintes = EMPREINTES,
  leviers = sprintf("max h_t = %.4f ; seuil 2k/T = %.4f : %s", LEV_OBS, 2 / T_,
                    if (!is.finite(LEV_OBS)) "NA" else if (LEV_OBS > 2 / T_) "franchi" else "non franchi"),
  hors_perimetre = paste0(paste0("\"", LIGNES_HORS_PERIMETRE, "\"", collapse = " ; "),
                          " : exclues du contr\u00f4le d'int\u00e9grit\u00e9 et de T2, aucun rep\u00e8re n'y porte"))
stopifnot(identical(names(CTX), names(LIBELLES_CONTEXTE)))
NV <- motifs_non_versionnable(CTX[["commit"]], EMPREINTES, "de l'ex\u00e9cution")
L0 <- c("## Taux de franchissement des rep\u00e8res des diagnostics sous le mod\u00e8le ajust\u00e9 (issue #72)", "",
        sprintf("Param\u00e8tres : %s", PAR), "",
        "### T0 -- contexte", "",
        entete_md(c("Grandeur", "Valeur")),
        lignes_contexte(CTX),
        ligne_md("R\u00e9plications", sprintf("%d (trait\u00e9es : %d \u00e0 %d)", OPT_R, DEBUT, FIN)),
        ligne_md("Dur\u00e9e (s)", sprintf("contr\u00f4le %.1f ; r\u00e9plications %.1f ; total %.1f", t_controle, t_rep,
                                          as.numeric(difftime(Sys.time(), t_debut, units = "secs")))),
        ligne_md("Versionnable (--ecrire)", if (!is.na(OPT_TRANCHE)) "non : tranche (tableaux partiels)" else txt_versionnable(NV)),
        ligne_md("Contr\u00f4le d'int\u00e9grit\u00e9", if (length(integrite)) "\u00c9CHEC" else "OK"), "")
SORTIE <- c(L0,
            if (!is.na(OPT_TRANCHE)) c("Tableaux PARTIELS (une tranche) : combiner les sorties des K tranches par --combiner.", ""),
            tableaux(cpt, FIN - DEBUT + 1L, CTX[["leviers"]]),
            if (length(integrite)) c("Contr\u00f4le d'int\u00e9grit\u00e9 : \u00c9CHEC", paste("-", integrite), ""))
ecrire_console(SORTIE)
if (!length(integrite) && is.na(OPT_TRANCHE)) ecrire_fichier(OPT_JEU, SORTIE, NV)
if (!is.na(OPT_TRANCHE))
  ecrire_console(c(paste0("PARAMETRES\t", PAR), sprintf("TRANCHE\t%d\t%d", DEBUT, FIN),
                   sprintf("CONTEXTE\t%s\t%s", names(CTX), CTX),
                   paste0("INTEGRITE\t", if (length(integrite)) "ECHEC" else "OK"),
                   sprintf("NCOMPTES\t%d", length(cpt)),
                   sprintf("COMPTE\t%s\t%.0f", names(cpt), cpt),
                   sprintf("FIN\t%d", length(cpt))))
quit(status = if (length(integrite)) 1L else 0L)
