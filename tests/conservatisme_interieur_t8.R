###############################################################################
#  tests/conservatisme_interieur_t8.R  --  CONSERVATISME DES P-VALUES
#  MONTE-CARLO AU REGIME DELTA CHAPEAU INTERIEUR, A T = 8 (issue #175)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils et tools, livres avec R : utils::sessionInfo(),
#  tools::md5sum()). Il ne modifie ni R/engine.R ni tests/reference/.
#  Sortie en markdown sur la console (UTF-8) ; fichiers ecrits SEULEMENT par
#  --combiner, sur option explicite (--ecrire, --sortie, --brut), et
#  seulement si la combinaison est acceptee.
#
#  Protocole : specification d'actuary du 08/10/2026 (issue #175,
#  commentaire 6058041254, section "#175"), decisions du mainteneur (PR #228,
#  commentaire 6058031276) : option A, trois p-values sur les memes y** ;
#  critere de verdict revise avant l'execution (PR #228, commentaire
#  6060869720, decision du mainteneur du 08/10/2026), reporte sans
#  modification dans TEXTE_CRITERE_228 et evalue par evaluer_critere().
#
#  Statut des valeurs : CONSTAT DE SIMULATION SOUS DEUX MODELES AJUSTES, pas
#  un resultat general. Les replications b (jeux y*_b) sont celles de la
#  calibration de #166 / #221 (tests/calibration_mc_t8.R) : y*_b tire sous le
#  modele ajuste au jeu observe, flux unique sous GRAINE_JEUX = 20260927
#  (expression YSIM de tests/taux_franchissement_reperes.R, #72) ; ajustement
#  fit*_b = usp_ajuster(x, y*_b) et refus de #188 (usp_valider_ajustement()),
#  comme run_engine(). Pour chaque replication du perimetre, le bootstrap de
#  usp_bootstrap(fit*_b, B = 999, seed = 20260831 + b) est REJOUE (memes y**,
#  meme ordre des appels) et trois p-values Monte-Carlo sont calculees sur
#  les memes y** :
#    1. moteur : reajustement usp_ajuster_rapide(x, y**, delta*_b, gamma*_b),
#       celui de usp_bootstrap() (controle (i1), (i2)) ;
#    2. delta fixe : reajustement usp_ajuster_contraint(x, y**, delta*_b,
#       gamma*_b) (celui du bootstrap restreint de #45), sur les MEMES
#       replications internes retenues que la variante 1 (question Q1 de
#       l'audit) ; les replications internes ecartees par la variante 1 ne sont
#       pas rejouees a delta fixe et sont comptees a part (T2) ;
#    3. conditionnelle au regime : les replications internes retenues dont
#       delta** est dans le meme regime que delta*_b (seuils TOL_DELTA_BORD
#       de #72) ; p absente (motif d'engine_p_mc(), compte) quand le B
#       effectif est inferieur a B_MIN_DEGENERESCENCE. Aucune reference ne
#       fonde cette variante a T = 8.
#  Les trois p-values sont calculees par .mc_p_values() (engine_p_mc()) du
#  moteur, statistique observee commune (celle de fit*_b), sens de rejet lu
#  dans USP_CATALOGUE_MC.
#
#  Perimetre (PERIMETRE) : sur les replications interieures, les huit
#  statistiques de #175 (BP, BP79, GQ, BF, Grubbs, Grubbsr, DAgo, JB) et
#  deux temoins (AD, White) ; GQ dans les trois regimes de J2 et au bord 0
#  de J1 ; RESET au bord 0 de J2 et de J1. J1 est descriptif (75 replications
#  interieures). Replications de J1 au bord 1 : non rejouees (hors
#  perimetre), ajustees seulement (controle (c)). Les jeux observes J1 et J2
#  (T3) sont rejoues sur les onze statistiques. Dans une replication, les
#  trois variantes et les comptes d'echecs portent sur les seules
#  statistiques du perimetre de son regime (sous-catalogue de
#  USP_CATALOGUE_MC, meme fonction calc) ; une replication interne est
#  retenue si son reajustement rapide et ces statistiques aboutissent (dans
#  usp_bootstrap(), si les 34 statistiques aboutissent : meme ensemble sauf
#  erreur d'une statistique hors perimetre, angle mort declare dans l'aide a
#  la lecture ; la p de la variante 1 peut alors differer de celle de #221,
#  controle (i1)). Le jeu observe, la premiere replication rejouee de chaque
#  tranche et la premiere replication interieure de chaque tranche (si ce
#  n'est pas la meme) suivent en outre le chemin du moteur sur le catalogue
#  complet (controles (i1) et (i2)) ; leurs valeurs des tableaux restent
#  celles du sous-catalogue (constat m2 de l'audit : tableaux d'une
#  execution d'un seul tenant et en tranches identiques).
#
#  Tableaux :
#    T0  : provenance (commit, plateforme, empreintes md5, graines, sources
#          des valeurs brutes de #221 et leur md5) ;
#    T1  (alpha = 0,10) et T1' (alpha = 0,05) : par jeu, regime de
#          delta*, statistique et variante : replications rejouees n_rep,
#          p definies n, k = #{p < alpha}, taux sur n (descriptif) et taux
#          sur les rejouees k / n_rep (p absente = non-rejet ; grandeur du
#          critere), IC de Clopper-Pearson a 95 % de chacun, lecture de la
#          bande et classe de #166, mediane de p, B effectif, p absentes et
#          leur motif, part des delta** aux bords ;
#    T2  : mecanisme, descriptif : composition des delta** par regime de
#          delta*, echecs des reajustements, replications internes ecartees
#          par le moteur, comparaison appariee des p, taux du moteur
#          restreint aux replications ou p3 est definie ;
#    T3  : jeux observes.
#  Aide a la lecture avec le critere de verdict revise, fixe avant
#  l'execution (TEXTE_CRITERE_228), et son evaluation mecanique sur J2 a
#  alpha = 0,10 (evaluer_critere()), sans conclure : le verdict revient a
#  actuary.
#  Incertitude : intervalle de Clopper-Pearson a 95 % (stats::binom.test()),
#  incertitude Monte-Carlo sur le taux, fonction du nombre de replications ;
#  elle ne dit rien de l'erreur d'approximation en T. L'erreur liee a B fait
#  partie de la procedure mesuree.
#
#  Controles d'integrite (code de sortie 1 si l'un echoue) :
#    (a)  J1 observe par run_engine(seed = 20260831) (executer_cas("premium")
#         de tests/outils_tests.R) conforme a tests/reference/premium.rds par
#         comparer_objets() apres neutraliser_instables() ;
#    (b)  les onze statistiques et leur sens de rejet sont lus dans
#         USP_CATALOGUE_MC ; noms des p de chaque variante = sous-catalogue,
#         dans son ordre, a chaque replication ;
#    (c)  YSIM identique (identical()) a l'expression YSIM de #72, lue par
#         parse() (liste blanche de noms, environnement isole, comme le (e2)
#         de tests/calibration_mc_t8.R) ; regime de delta*_b (ou "ecartee")
#         identique a celui des valeurs brutes de #221, a chaque replication
#         de la tranche ;
#    (i1) p moteur rejouee = p_mc des valeurs brutes de #221 (colonnes
#         p_mc:<stat>, ecrites en %.17g), au bit pres, pour chaque
#         statistique de la variante 1 de chaque replication rejouee et,
#         sur l'echantillon de (i2), pour les 34 statistiques du chemin du
#         moteur ;
#    (i2) identical() avec usp_bootstrap() (stats_obs, p_mc, err_mc,
#         B_effectif, granularite_stat, motif_mc, sigma_boot, delta_boot,
#         gamma_boot, sigma_boot_restreint, n_echec_restreint, z_boot) du
#         chemin du moteur sur le catalogue complet, sur l'echantillon :
#         jeu observe, premiere replication rejouee et premiere replication
#         interieure de la tranche, comme tests/comparer_ajusteurs_bootstrap.R
#         (S5) ; sur J1 observe, p_mc aussi identiques a celles de
#         run_engine() du controle (a) ;
#    (i3) md5 de R/engine.R egal a celui du T0 du tableau de #221 (ligne
#         "Empreintes md5 du code execute") ; parametres de ce tableau (jeu,
#         graines, B, alpha, theta_equiv) egaux a ceux du script, R egal au
#         nombre de lignes des valeurs brutes ;
#    (d)  les echecs des deux reajustements (et des statistiques qui les
#         suivent) sont comptes a chaque replication ; invariants : retenues
#         de la variante 1 = B - echecs (rapide, statistiques (1)), retenues
#         de la variante 2 = retenues de la variante 1 - echecs (contraint,
#         statistiques (2)) et contenues dans celles-ci, B effectifs bornes
#         par les retenues ;
#  plus deux controles de coherence : RESET et Grubbsr ne dependent pas de
#  l'ajustement (calc identique sur un contexte observe a z et pi
#  modifies), et leurs valeurs simulees sont identiques entre les variantes
#  1 et 2 sur les replications internes retenues par les deux.
#
#  Alea : aucun tirage propre. Les y* sont ceux de #72 (engine_sous_graine()
#  sous GRAINE_JEUX) ; les y** ceux de usp_bootstrap() (engine_sous_graine()
#  sous GRAINE_BOOT + b ; jeu observe : GRAINE_BOOT). Les appels ajoutes au
#  rejeu hors du chemin du moteur (statistiques du sous-catalogue quand le
#  catalogue complet echoue, reajustement a delta fixe d'une replication
#  retenue sur le sous-catalogue seulement, statistiques de la variante 2)
#  sont proteges : .Random.seed est restaure apres eux, de sorte que la
#  suite des y** est celle du moteur meme si l'un d'eux consommait de
#  l'alea (controle (i2)). Collisions de
#  graines heritees de #166 (declarees en T0, non bloquantes) : a R >= 96, la
#  graine du bootstrap de la replication 96 est GRAINE_JEUX ; a R >= 70,
#  celle de la replication 70 est SEED_LOI_NULLE_SW.
#
#  Usage (depuis la racine du depot, de preference dans un git worktree au
#  commit propre cite) :
#      Rscript tests/conservatisme_interieur_t8.R --jeu J1|J2 [--R 2000] [--tranche i/K]
#          [--brut-221 FICHIER.tsv] [--tableau-221 FICHIER.md]
#      Rscript tests/conservatisme_interieur_t8.R --combiner f1 f2 ...
#          [--ecrire [--remplacer] | --sortie DOSSIER] [--brut FICHIER]
#  Pas d'option de B, de graine ni de perimetre (aucun levier).
#  --brut-221, --tableau-221 : valeurs brutes de #221 (sortie --brut de
#  tests/calibration_mc_t8.R --combiner) et tableau de #221 (son T0 donne le
#  md5 du moteur, (i3)) du jeu de la tranche. Par defaut : le plus recent
#  docs/tableaux/<AAAAMMJJ>-issue166-brut-<jeu>.tsv et le tableau
#  docs/tableaux/<AAAAMMJJ>-issue166-calibration-<jeu>.md de meme date (avant
#  le commit de #221 : ceux du 30/09/2026, calcules sur un autre moteur, ou
#  (i3) echoue).
#  Chaque tranche imprime T0, les tableaux (PARTIELS), les controles, puis
#  des lignes machine : PARAMETRES, TRANCHE, CONTEXTE, STATS, REPCOLS, OBS
#  (jeu observe), DUREE, INTEGRITE, NREP, une ligne REP par replication et,
#  en derniere ligne, FIN (nombre de REP). Rediriger la sortie de chaque
#  tranche vers un fichier HORS du depot ; --combiner relit les lignes REP
#  et OBS des tranches (d'un ou des deux jeux) et recalcule les tableaux par
#  la meme fonction qu'une tranche (tableaux d'un seul tenant identiques).
#  --combiner refuse (code 1, sans tableau) : une tranche sans INTEGRITE ou en
#  ECHEC ; une sortie incomplete (FIN absente ou pas en derniere ligne,
#  nombre de REP different de NREP ou de FIN) ; des PARAMETRES, un CONTEXTE,
#  des STATS, des REPCOLS ou une ligne OBS differents entre tranches d'un
#  meme jeu ; commit, plateforme, empreintes ou generateur differents entre
#  jeux ; des tranches qui ne couvrent pas 1..R exactement une fois ; un
#  invariant du corps faux (b = debut..fin, statut coherent avec le regime
#  et le perimetre, (i1) OK sur chaque replication rejouee).
#  --ecrire (--combiner seulement) : ecrit
#  docs/tableaux/<AAAAMMJJ>-issue175-conservatisme-interieur.md (date du
#  jour de la combinaison), jamais patche. REFUSE (code 1, rien d'ecrit) si :
#  le commit des tranches ou de la combinaison n'est pas propre ou si le code
#  execute n'est pas celui du depot (motifs_non_versionnable()) ; J1 et J2 ne
#  sont pas tous deux presents ; R differe du nombre de replications des
#  valeurs brutes de #221 ; ces valeurs brutes ou le tableau de #221 ne sont
#  pas suivis par git ou ont change depuis les tranches (md5). Gardes
#  anticipees (#205) : commit et code de la combinaison, dossier
#  docs/tableaux/ et garde d'ecrasement (garde_ecrasement(), #173) evalues
#  des l'analyse des options, avant la lecture des tranches, puis de nouveau
#  avant d'ecrire. --remplacer : avec --ecrire seulement (T0 cite le fichier
#  remplace et son md5 d'avant). --sortie DOSSIER : meme nom dans DOSSIER,
#  HORS du depot. --brut FICHIER : valeurs brutes combinees (colonne jeu,
#  puis REPCOLS ; jeux observes en b = 0), HORS du depot, jamais ecrase.
#  Commit : commit_depot() de tests/outils_tests.R, lu au debut du calcul.
#
#  Cout (conteneur Linux 4 coeurs, R 4.3.3, 08/10/2026, mesure sous la
#  charge de quatre executions longues de #221 : charge moyenne 4,9 ;
#  lignes Duree de T0 des essais a R = 5 et 6) : par replication rejouee sur
#  le sous-catalogue, interieur 18,7 a 20,7 s, bord 0 12,0 a 12,2 s ; bord 1
#  (GQ seul) 2,4 s (rejouer() seul, replication 2 de J2) ; premiere
#  replication rejouee et premiere replication interieure d'une tranche
#  (catalogue complet et usp_bootstrap() de (i2)) environ 40 a 60 s chacune
#  (essais de la reprise du 08/10/2026, J2 a R = 6 et J1 a R = 5, meme
#  charge : replication interieure en mode complet 57 a 60 s) ;
#  controles et jeu observe 103 a 115 s par tranche ; replication non
#  rejouee 0,1 s. Estimation (meme charge) : J2, 464 x 19,3 + 814 x 12,2 +
#  722 x 2,5 = 20 700 s ; J1, 75 x 19,3 + 930 x 12,2 = 12 800 s ; environ
#  10 h de CPU au total, tranches comprises. Executions completes, J2 en 8
#  tranches et J1 en 4 (environ 45 a 60 min chacune), 4 en parallele au
#  plus, dans un git worktree au commit propre cite :
#      D=/chemin/hors/depot
#      for i in 1 2 3 4; do LC_ALL=C.UTF-8 Rscript tests/conservatisme_interieur_t8.R \
#        --jeu J2 --tranche $i/8 > $D/c175-J2-$i.txt & done; wait
#      for i in 5 6 7 8; do LC_ALL=C.UTF-8 Rscript tests/conservatisme_interieur_t8.R \
#        --jeu J2 --tranche $i/8 > $D/c175-J2-$i.txt & done; wait
#      for i in 1 2 3 4; do LC_ALL=C.UTF-8 Rscript tests/conservatisme_interieur_t8.R \
#        --jeu J1 --tranche $i/4 > $D/c175-J1-$i.txt & done; wait
#      LC_ALL=C.UTF-8 Rscript tests/conservatisme_interieur_t8.R --combiner $D/c175-J*.txt \
#        --ecrire --brut $D/c175-brut.tsv
#  Recette : --jeu J1 --R 5 rend le code 0 en environ 3,8 min (1 replication
#  interieure, 2 au bord 0, 2 non rejouees ; (i2) sur les replications 3 et
#  5), avec --brut-221 et
#  --tableau-221 produits par tests/calibration_mc_t8.R --jeu J1 --R 5 puis
#  --combiner ... --sortie DOSSIER --brut FICHIER (meme moteur : (i1) et (i3)
#  tiennent) ; avec les valeurs du 30/09/2026 par defaut, (i3) echoue (autre
#  moteur) et (i1) echoue sur la replication rejouee sur le catalogue
#  complet.
#  Reexecution du tableau du 09/10/2026
#  (docs/tableaux/20261009-issue175-conservatisme-interieur.md) : dans un git
#  worktree au commit 139031d, commit d'execution cite en T0 (md5 de
#  R/engine.R 344a4e03751e97b14e5ca1b733b856c6, celui du T0 du tableau de
#  #221). A partir du commit 8ae7bc9 (commentaire du bloc 4 de R/engine.R,
#  aucun calcul modifie), le md5 de R/engine.R ne correspond plus a ce T0 :
#  (i3) echoue par construction (ligne INTEGRITE a ECHEC), sans que le calcul
#  change. Une nouvelle mesure a un commit ulterieur suppose une nouvelle
#  mesure de #221 sur ce moteur (ou une evolution du controle (i3),
#  decision du mainteneur).
#  Fonctions reprises par copie declaree (ces scripts executent leur calcul
#  au chargement et ne peuvent pas etre sources) : de
#  tests/calibration_mc_t8.R : lire_option(), plateforme_calcul(),
#  meme_fichier(), empreintes_code(), sous_depot(), ecrire_console(),
#  ligne_md(), entete_md(), num(), ic_cp(), txt_ic(), lire_j2(), code_regime(),
#  bornes d'une tranche, controle (e2) (devenu (c)), collisions de graines,
#  controle (a) ; de tests/comparer_ajusteurs_bootstrap.R : structure du
#  rejeu du bootstrap (rejouer(), adaptee aux trois variantes) et controle S5
#  (devenu (i2)). commit_depot(), motifs_non_versionnable(),
#  garde_ecrasement(), ligne_remplacement(), inserer_t0() : tests/outils_tests.R.
#  Code de sortie : 0 si les controles d'integrite tiennent, 1 sinon ; en
#  mode --combiner, 0 si la combinaison est acceptee, 1 si elle est refusee.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/conservatisme_interieur_t8.R"

# --- Options (lire_option() : copie de tests/calibration_mc_t8.R) ------------
ARGS <- commandArgs(trailingOnly = TRUE)
OPTIONS_APRES_COMBINER <- c("--ecrire", "--remplacer", "--sortie", "--brut")
i_comb <- match("--combiner", ARGS)
FICHIERS_COMB <- if (is.na(i_comb)) character(0) else {
  reste <- ARGS[-seq_len(i_comb)]
  j <- match(OPTIONS_APRES_COMBINER, reste)
  fin <- if (all(is.na(j))) length(reste) else min(j, na.rm = TRUE) - 1L
  reste[seq_len(fin)]
}
if (!is.na(i_comb) && !length(FICHIERS_COMB)) stop("--combiner : aucun fichier")
lire_option <- function(nom, defaut) {
  i <- match(nom, ARGS)
  if (is.na(i)) return(defaut)
  if (i == length(ARGS)) stop("option ", nom, " sans valeur")
  ARGS[i + 1L]
}
OPT_JEU       <- lire_option("--jeu", NA_character_)
OPT_R         <- suppressWarnings(as.integer(lire_option("--R", "2000")))
OPT_TRANCHE   <- lire_option("--tranche", NA_character_)
OPT_BRUT221   <- lire_option("--brut-221", NA_character_)
OPT_TAB221    <- lire_option("--tableau-221", NA_character_)
OPT_ECRIRE    <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_SORTIE    <- lire_option("--sortie", NA_character_)
OPT_BRUT      <- lire_option("--brut", NA_character_)
if (OPT_REMPLACER && !OPT_ECRIRE) stop("--remplacer : reserve a --ecrire (remplacement d'un tableau suivi par git, #173)")
if ((OPT_ECRIRE || !is.na(OPT_SORTIE) || !is.na(OPT_BRUT)) && is.na(i_comb))
  stop("--ecrire, --sortie et --brut sont reserves a --combiner")
if (is.na(i_comb) && !isTRUE(OPT_JEU %in% c("J1", "J2"))) stop("--jeu : J1 ou J2 (obligatoire hors --combiner)")
if (!is.na(i_comb) && (!is.na(OPT_JEU) || !is.na(OPT_TRANCHE) || !is.na(OPT_BRUT221) || !is.na(OPT_TAB221) ||
                       "--R" %in% ARGS))
  stop("--jeu, --R, --tranche, --brut-221 et --tableau-221 sont reserves aux tranches (pas a --combiner)")
if (!is.finite(OPT_R) || OPT_R < 1L) stop("--R : entier >= 1")
if (OPT_ECRIRE && !is.na(OPT_SORTIE)) stop("--ecrire et --sortie sont exclusifs")
if (!is.na(OPT_SORTIE) && !dir.exists(OPT_SORTIE)) stop("--sortie : dossier introuvable : ", OPT_SORTIE)

# --- Protocole (constantes ; aucune option : aucun levier) ---------------------
METHODE <- "premium"; SEGMENT <- 1; ANNEXE <- "II"; NATURE <- "brutes"
ALPHA <- 0.10; ALPHA2 <- ALPHA / 2; THETA_EQUIV <- 0.10
SEUILS <- c(ALPHA, ALPHA2)
B_BOOT <- 999L
GRAINE_JEUX <- 20260927
GRAINE_BOOT <- 20260831
T_ <- 8L
SCRIPT_72 <- file.path("tests", "taux_franchissement_reperes.R")
# Statistiques de #175 et temoins (noms de USP_CATALOGUE_MC).
STATS_8 <- c("BP", "BP79", "GQ", "BF", "Grubbs", "Grubbsr", "DAgo", "JB")
TEMOINS <- c("AD", "White")
# Statistiques qui ne dependent pas de l'ajustement (specification
# d'actuary ; controle de coherence) : x et y seuls.
STATS_SANS_AJUSTEMENT <- c("RESET", "Grubbsr")
# Perimetre : jeu -> regime de delta* -> statistiques (specification
# d'actuary). Un regime absent n'est pas rejoue.
PERIMETRE <- list(
  J1 = list(interieur = c(STATS_8, TEMOINS), bord0 = c("GQ", "RESET")),
  J2 = list(interieur = c(STATS_8, TEMOINS), bord0 = c("GQ", "RESET"), bord1 = "GQ"))
REGIMES <- c(interieur = "\u03b4\u0302* int\u00e9rieur", bord0 = "\u03b4\u0302* = 0", bord1 = "\u03b4\u0302* = 1")
VARIANTES <- c("1" = "moteur (usp_ajuster_rapide())", "2" = "\u03b4 fix\u00e9 (usp_ajuster_contraint())",
               "3" = "conditionnelle au r\u00e9gime")
# Liste blanche des noms de l'expression YSIM de #72 (controle (c), copie du
# (e2) de tests/calibration_mc_t8.R).
NOMS_E2 <- c("engine_sous_graine", "OPT_GRAINE", "t", "vapply", "seq_len", "OPT_R", "function",
             "usp_simuler", "FIT0", "numeric", "T_", "{", "(")

# --- Chargement du moteur et des outils --------------------------------------
FICHIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) f else NA_character_
})
DOSSIER_SCRIPT <- if (!is.na(FICHIER_SCRIPT)) dirname(FICHIER_SCRIPT) else
  if (file.exists("tests/outils_tests.R")) "tests" else "."
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))
# Les statistiques du perimetre, dans l'ordre du catalogue (controle (b)).
STATS_175 <- names(USP_CATALOGUE_MC)[names(USP_CATALOGUE_MC) %in% unique(unlist(PERIMETRE))]

# --- Outils (copies declarees de tests/calibration_mc_t8.R) --------------------
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(extSoftVersion()["BLAS"]), txt(La_library()), txt(La_version()))
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
ecrire_console <- function(x) writeLines(enc2utf8(x), useBytes = TRUE)
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
num <- function(x, d = 3) if (length(x) != 1L || is.na(x)) "\u2014" else sub(".", ",", sprintf(paste0("%.", d, "f"), x), fixed = TRUE)
ic_cp <- function(k, n) if (n > 0) {
  ci <- stats::binom.test(k, n)$conf.int
  c(ci[1], ci[2])
} else c(NA_real_, NA_real_)
txt_ic <- function(ci, d = 4) if (anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", num(ci[1], d), num(ci[2], d))
code_regime <- function(delta) if (delta >= 1 - TOL_DELTA_BORD) "bord1" else
  if (delta <= TOL_DELTA_BORD) "bord0" else "interieur"
md5_fichier <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
# Chemin cite : relatif a la racine s'il est sous le depot, absolu sinon.
chemin_cite <- function(f) {
  if (is.na(f) || !file.exists(f)) return(as.character(f))
  a <- normalizePath(f, winslash = "/", mustWork = TRUE)
  r <- normalizePath(RACINE, winslash = "/", mustWork = TRUE)
  if (startsWith(a, paste0(r, "/"))) substring(a, nchar(r) + 2L) else a
}
# Suivi par git d'un fichier : "oui", "non" (ou hors du depot), "indetermine".
suivi_git <- function(f) {
  if (is.na(f) || !file.exists(f) || !sous_depot(dirname(f))) return("non")
  code <- tryCatch(suppressWarnings(system2("git", c("--literal-pathspecs", "-C", shQuote(RACINE), "ls-files",
                                                    "--error-unmatch", "--", shQuote(chemin_cite(f))),
                                            stdout = FALSE, stderr = FALSE)),
                   error = function(e) NA_integer_)
  if (identical(as.integer(code), 0L)) "oui" else if (identical(as.integer(code), 1L)) "non" else "indetermine"
}
nettoyer_champ <- function(s) gsub("[\t\r\n]+", " ", s)

DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
NOM_SORTIE <- sprintf("%s-issue175-conservatisme-interieur.md", DATE_SORTIE)
CIBLE_ECRIRE <- file.path(RACINE, "docs", "tableaux", NOM_SORTIE)

# Gardes anticipees de --ecrire (#205), des l'analyse des options, avant la
# lecture des tranches : commit et code de la combinaison, dossier
# docs/tableaux/, garde d'ecrasement ; reprises avant d'ecrire.
if (OPT_ECRIRE) {
  nv0 <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, SCRIPT_72), "de la combinaison")
  if (length(nv0)) {
    message("--combiner : REFUS -- --ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv0, collapse = " ; "),
            " -- relancer sur un arbre propre, ou utiliser --sortie DOSSIER hors du depot")
    quit(status = 1L)
  }
  if (!dir.exists(file.path(RACINE, "docs", "tableaux")))
    stop("dossier de sortie introuvable : ", file.path(RACINE, "docs", "tableaux"))
  garde_ecrasement(CIBLE_ECRIRE, OPT_REMPLACER, RACINE)
}

###############################################################################
#  TABLEAUX A PARTIR DES VALEURS BRUTES (tranche et --combiner)
###############################################################################
# Colonnes d'une ligne REP / OBS.
COLS_FIXES <- c("b", "regime", "statut", "delta", "mode", "i1", "echec_rapide", "echec_stats1",
                "echec_contraint", "echec_stats2", "dd_bord0", "dd_bord1", "dd_interieur")
CHAMPS_STAT <- c("p1", "p2", "p3", "B1", "B2", "B3", "m1", "m2", "m3")
REPCOLS <- c(COLS_FIXES, as.vector(t(outer(STATS_175, CHAMPS_STAT, function(s, c) paste0(c, ":", s)))))
COLS_NUM <- c("b", "delta", "echec_rapide", "echec_stats1", "echec_contraint", "echec_stats2", "dd_bord0",
              "dd_bord1", "dd_interieur",
              as.vector(outer(c("p1", "p2", "p3", "B1", "B2", "B3"), STATS_175, paste, sep = ":")))
# Lignes (vecteurs de champs) -> data.frame, colonnes numeriques converties
# (valeurs ecrites en %.17g, relues sans perte).
en_table <- function(champs) {
  if (!length(champs)) {
    d <- as.data.frame(matrix(character(0), 0, length(REPCOLS), dimnames = list(NULL, REPCOLS)), stringsAsFactors = FALSE)
  } else {
    M <- do.call(rbind, champs); colnames(M) <- REPCOLS
    d <- as.data.frame(M, stringsAsFactors = FALSE)
  }
  for (k in COLS_NUM) d[[k]] <- suppressWarnings(as.numeric(d[[k]]))
  d
}
# Motifs d'absence abreges (constantes du moteur).
abreger_motif <- function(m) {
  table_m <- c(stats::setNames("B eff. < B_MIN_DEGENERESCENCE", MOTIF_MC_REPLIC_INSUFFISANTES),
               stats::setNames("B eff. = 0", MOTIF_MC_AUCUNE_REPLIC),
               stats::setNames("dispersion nulle", MOTIF_MC_DISPERSION_NULLE),
               stats::setNames("atome hors obs.", MOTIF_MC_ATOME_HORS_OBS),
               stats::setNames("obs. non finie", MOTIF_MC_OBS_NON_FINIE),
               stats::setNames("condition du catalogue", MOTIF_MC_CONDITION))
  ifelse(m %in% names(table_m), table_m[m], m)
}
# Lecture d'un taux contre alpha (aide a la lecture, sans conclure), regle
# de #166 : reference alpha dans l'IC ; sinon position par rapport a la
# bande de Bradley [alpha/2 ; 3 alpha/2] ; disjonction de l'IC et de la
# bande toujours ecrite, avec son cote (critere de verdict). Classe de #166
# (CLASSES, ordonnees) : compatible si alpha est dans l'IC ; sinon
# distorsion materielle si l'IC est disjoint de la bande ; sinon ecart
# mineur si le taux est dans la bande ; sinon ecart non tranche.
CLASSES <- c("compatible", "\u00e9cart mineur", "\u00e9cart non tranch\u00e9", "distorsion mat\u00e9rielle")
lecture <- function(k, n, a) {
  if (n == 0) return(c(k = sprintf("%.0f", k), taux = "\u2014", ic = "\u2014", ref_ic = "\u2014", bande = "\u2014",
                       disjoint = "\u2014", cote = NA_character_, classe = NA_character_))
  ci <- ic_cp(k, n); est <- k / n
  ref_ic <- a >= ci[1] && a <= ci[2]
  cote <- if (ci[2] < a / 2) "conservateur" else if (ci[1] > 3 * a / 2) "lib\u00e9ral" else NA_character_
  disjoint <- !is.na(cote)
  bande <- if (ref_ic) "\u2014" else if (disjoint) "IC enti\u00e8rement hors" else
    if (est >= a / 2 && est <= 3 * a / 2) "dans" else "estimation hors"
  classe <- if (ref_ic) CLASSES[1] else if (disjoint) CLASSES[4] else if (bande == "dans") CLASSES[2] else CLASSES[3]
  c(k = sprintf("%.0f", k), taux = num(est, 4), ic = txt_ic(ci), ref_ic = if (ref_ic) "oui" else "**non**",
    bande = bande, disjoint = if (disjoint) sprintf("**oui** (%s)", cote) else "non", cote = cote, classe = classe)
}
# Cellule (jeu, regime, statistique, variante) : grandeurs de T1 et du
# critere. Critere : k / n_rep, n_rep = replications rejouees du regime
# (denominateur commun aux trois variantes, p absente = non-rejet), IC de
# Clopper-Pearson sur (k, n_rep). Descriptif : k / n sur les seules p
# definies. Cellule evaluable si n_rep > 0, sinon "non evaluable" ; a
# n = 0 (aucune p definie), k = 0 (decision du mainteneur du 08/10).
cellule_t1 <- function(D, r, s, v, a) {
  x <- D[D$statut == "rejouee" & D$regime == r, , drop = FALSE]
  p <- x[[sprintf("p%s:%s", v, s)]]; Bv <- x[[sprintf("B%s:%s", v, s)]]; m <- x[[sprintf("m%s:%s", v, s)]]
  fin <- is.finite(p)
  n_rep <- nrow(x); n <- sum(fin); k <- sum(fin & p < a)
  lec <- lecture(k, n_rep, a)
  abs_m <- table(abreger_motif(m[!fin]))
  tot <- x$dd_bord0 + x$dd_bord1 + x$dd_interieur
  list(n_rep = n_rep, n = n, k = k, evaluable = n_rep > 0,
       taux = if (n_rep) k / n_rep else NA_real_, ci = ic_cp(k, n_rep), lec = lec,
       disj = !is.na(lec[["cote"]]), cote = unname(lec[["cote"]]), classe = unname(lec[["classe"]]),
       taux_n = if (n) k / n else NA_real_, ci_n = ic_cp(k, n),
       med = if (n) stats::median(p[fin]) else NA_real_,
       B = if (nrow(x)) c(stats::median(Bv), min(Bv), max(Bv)) else rep(NA_real_, 3),
       absentes = if (length(abs_m)) paste(sprintf("%d (%s)", as.integer(abs_m), names(abs_m)), collapse = " ; ") else "0",
       bords = if (nrow(x)) mean((x$dd_bord0 + x$dd_bord1) / tot) else NA_real_)
}
ordre_jeux <- function(jeux) intersect(c("J2", "J1"), jeux)
# Titres de T1 et T1' (communs aux tranches et a --combiner).
TITRE_T1 <- "### T1 -- \u03b1 = 0,10 : fr\u00e9quence de p < 0,10 par jeu, r\u00e9gime, statistique et variante"
TITRE_T1B <- "### T1' -- \u03b1 = 0,05 : fr\u00e9quence de p < 0,05 par jeu, r\u00e9gime, statistique et variante"
# Duree (ligne DUREE : controles, puis secondes et nombre de replications
# par regime rejoue et pour les replications non rejouees ou ecartees).
texte_duree <- function(du) {
  par <- function(s, n, lib) sprintf("%s %.0f s (%.0f r\u00e9pl., %s s par r\u00e9plication)", lib, s, n,
                                     if (n > 0) num(s / n, 1) else "\u2014")
  paste(c(sprintf("contr\u00f4les et jeu observ\u00e9 %.0f s", du[1]), par(du[2], du[3], "int\u00e9rieur"),
          par(du[4], du[5], "bord 0"), par(du[6], du[7], "bord 1"), par(du[8], du[9], "non rejou\u00e9es ou \u00e9cart\u00e9es")),
        collapse = " ; ")
}

tableau_t1 <- function(DL, a, titre) {
  L <- c(titre, "",
         entete_md(c("Jeu", "R\u00e9gime", "Statistique (sens)", "Variante", "rejou\u00e9es (n_rep)", "p d\u00e9finies (n)",
                     sprintf("< %s : k", num(a, 2)), "taux sur n (k / n)", "IC 95 % sur n",
                     "taux sur les rejou\u00e9es (k / n_rep, p absente = non-rejet)", "IC 95 % sur les rejou\u00e9es",
                     "\u03b1 dans l'IC (rejou\u00e9es)", "bande [\u03b1/2 ; 3\u03b1/2] (rejou\u00e9es)", "IC disjoint de la bande (rejou\u00e9es)",
                     "classe de #166 (rejou\u00e9es)", "m\u00e9diane de p", "B effectif : m\u00e9diane [min ; max]",
                     "p absentes (motif)", "part des \u03b4\u0302** aux bords (moyenne)")))
  for (j in ordre_jeux(names(DL))) for (r in names(PERIMETRE[[j]])) for (s in intersect(STATS_175, PERIMETRE[[j]][[r]]))
    for (v in names(VARIANTES)) {
      c_ <- cellule_t1(DL[[j]], r, s, v, a)
      L <- c(L, ligne_md(j, REGIMES[[r]], sprintf("%s (%s)", s, USP_CATALOGUE_MC[[s]]$queue), VARIANTES[[v]],
                         c_$n_rep, c_$n, c_$lec[["k"]], num(c_$taux_n, 4), txt_ic(c_$ci_n), c_$lec[["taux"]], c_$lec[["ic"]],
                         c_$lec[["ref_ic"]], c_$lec[["bande"]], c_$lec[["disjoint"]],
                         if (c_$evaluable) c_$classe else "non \u00e9valuable", num(c_$med, 4),
                         if (anyNA(c_$B)) "\u2014" else sprintf("%.0f [%.0f ; %.0f]", c_$B[1], c_$B[2], c_$B[3]),
                         c_$absentes, num(c_$bords, 3)))
    }
  c(L, "")
}

# Evaluation mecanique du critere de verdict revise (PR #228, commentaire
# 6060869720, TEXTE_CRITERE_228) : J2, alpha = 0,10, bande [0,05 ; 0,15],
# taux et IC sur les rejouees (cellule_t1()). Etat de chaque condition :
# "remplie", "non remplie" ou "non evaluable" (cellules non evaluables qui
# empechent de trancher ; une cellule non evaluable ne remplit jamais (1)
# ni (2), constat m1 de l'audit).
# Cellules de la condition (2) : regime et statistique.
CELLULES_C2 <- rbind(cbind("interieur", c(STATS_8, TEMOINS)), c("bord0", "GQ"), c("bord1", "GQ"), c("bord0", "RESET"))
# Defaut d'une cellule de (2) pour une variante : "" si aucun, NA si non
# evaluable, sinon le motif (creee, inversee, aggravee).
defaut_c2 <- function(m, x) {
  if (!m$evaluable || !x$evaluable) return(NA_character_)
  if (!m$disj) return(if (x$disj) sprintf("cr\u00e9\u00e9e (%s)", x$cote) else "")
  if (x$disj && x$cote != m$cote) return(sprintf("invers\u00e9e (%s \u2192 %s)", m$cote, x$cote))
  if (m$cote == "conservateur" && x$taux < m$ci[1]) return("aggrav\u00e9e (taux sous la borne basse de l'IC du moteur)")
  if (m$cote == "lib\u00e9ral" && x$taux > m$ci[2]) return("aggrav\u00e9e (taux au-dessus de la borne haute de l'IC du moteur)")
  ""
}
evaluer_critere <- function(DL) {
  if (!"J2" %in% names(DL)) return(c("Crit\u00e8re non \u00e9valu\u00e9 : J2 absent de cette sortie.", ""))
  D <- DL$J2
  cel <- function(r, s, v) cellule_t1(D, r, s, v, ALPHA)
  lib_cel <- function(r, s) sprintf("%s (%s)", s, REGIMES[[r]])
  txt_cel <- function(c_) if (!c_$evaluable) "non \u00e9valuable" else
    sprintf("%s %s, %s", c_$lec[["taux"]], c_$lec[["ic"]], c_$classe)
  L <- c("**\u00c9valuation m\u00e9canique du crit\u00e8re r\u00e9vis\u00e9** (J2, \u03b1 = 0,10, taux et IC sur les rejou\u00e9es) :", "",
         entete_md(c("Variante", "(1) statistiques sur 8 : IC du moteur disjoint, IC de la variante non disjoint",
                     "(1) \u00e9tat", "(2) cellules en d\u00e9faut (sur 13)", "(2) \u00e9tat",
                     "(3) AD et White : classe moteur \u2192 variante", "(3) \u00e9tat", "Trois conditions")))
  for (v in c("2", "3")) {
    # (1)
    r1 <- vapply(STATS_8, function(s) {
      m <- cel("interieur", s, "1"); x <- cel("interieur", s, v)
      if (!m$evaluable) NA else if (!m$disj) FALSE else if (!x$evaluable) NA else !x$disj
    }, logical(1))
    n1 <- sum(r1, na.rm = TRUE); ne1 <- sum(is.na(r1))
    e1 <- if (n1 >= 5L) "remplie" else if (n1 + ne1 >= 5L) "non \u00e9valuable" else "non remplie"
    # (2)
    d2 <- vapply(seq_len(nrow(CELLULES_C2)), function(i) {
      r <- CELLULES_C2[i, 1]; s <- CELLULES_C2[i, 2]
      defaut_c2(cel(r, s, "1"), cel(r, s, v))
    }, "")
    lib2 <- vapply(seq_len(nrow(CELLULES_C2)), function(i) lib_cel(CELLULES_C2[i, 1], CELLULES_C2[i, 2]), "")
    k2 <- which(!is.na(d2) & nzchar(d2))
    e2 <- if (length(k2)) "non remplie" else if (anyNA(d2)) "non \u00e9valuable" else "remplie"
    # (3)
    r3 <- vapply(TEMOINS, function(s) {
      m <- cel("interieur", s, "1"); x <- cel("interieur", s, v)
      if (!m$evaluable || !x$evaluable) NA else match(x$classe, CLASSES) <= match(m$classe, CLASSES)
    }, logical(1))
    e3 <- if (any(!r3, na.rm = TRUE)) "non remplie" else if (anyNA(r3)) "non \u00e9valuable" else "remplie"
    txt3 <- paste(vapply(TEMOINS, function(s) {
      m <- cel("interieur", s, "1"); x <- cel("interieur", s, v)
      sprintf("%s : %s \u2192 %s", s, if (m$evaluable) m$classe else "non \u00e9valuable", if (x$evaluable) x$classe else "non \u00e9valuable")
    }, ""), collapse = " ; ")
    etats <- c(e1, e2, e3)
    glob <- if (all(etats == "remplie")) "**remplies** (\u00ab proposer une \u00e9volution \u00bb)" else
      if (any(etats == "non remplie")) "non remplies" else "non \u00e9valuables"
    L <- c(L, ligne_md(VARIANTES[[v]],
                       sprintf("%d (%s)%s", n1, if (n1) paste(STATS_8[which(r1)], collapse = ", ") else "aucune",
                               if (ne1) sprintf(" ; non \u00e9valuables : %s", paste(STATS_8[is.na(r1)], collapse = ", ")) else ""),
                       e1,
                       paste(c(if (length(k2)) paste(sprintf("%s : %s", lib2[k2], d2[k2]), collapse = " ; ") else "aucune",
                               if (anyNA(d2)) sprintf("non \u00e9valuables : %s", paste(lib2[is.na(d2)], collapse = ", "))),
                             collapse = " ; "),
                       e2, txt3, e3, glob))
  }
  # Detail des treize cellules de (2) (taux sur les rejouees, IC, classe).
  L <- c(L, "", "Cellules de la condition (2), taux sur les rejou\u00e9es [IC 95 %] et classe de #166 :", "",
         entete_md(c("Cellule", "rejou\u00e9es", "moteur", "\u03b4 fix\u00e9", "d\u00e9faut (2)", "conditionnelle au r\u00e9gime", "d\u00e9faut (2)")))
  for (i in seq_len(nrow(CELLULES_C2))) {
    r <- CELLULES_C2[i, 1]; s <- CELLULES_C2[i, 2]
    m <- cel(r, s, "1"); x2 <- cel(r, s, "2"); x3 <- cel(r, s, "3")
    df <- function(x) { d <- defaut_c2(m, x); if (is.na(d)) "non \u00e9valuable" else if (nzchar(d)) d else "aucun" }
    L <- c(L, ligne_md(lib_cel(r, s), m$n_rep, txt_cel(m), txt_cel(x2), df(x2), txt_cel(x3), df(x3)))
  }
  c(L, "")
}

tableau_t2 <- function(DL) {
  L <- c("### T2 -- m\u00e9canisme (descriptif)", "",
         "Composition des \u03b4\u0302** du moteur (r\u00e9plications internes retenues) et \u00e9checs des r\u00e9ajustements :", "",
         entete_md(c("Jeu", "R\u00e9gime de \u03b4\u0302*", "rejou\u00e9es", "\u03b4\u0302** = 0 (moyenne)", "\u03b4\u0302** int\u00e9rieur (moyenne)",
                     "\u03b4\u0302** = 1 (moyenne)", "\u03b4\u0302** du r\u00e9gime de \u03b4\u0302* : m\u00e9diane [min ; max]",
                     "\u00e9checs usp_ajuster_rapide()", "\u00e9checs statistiques (1)",
                     "r\u00e9plications internes \u00e9cart\u00e9es par la variante 1 (sous-catalogue ; variantes non calcul\u00e9es)",
                     "\u00e9checs usp_ajuster_contraint() (parmi les retenues)", "\u00e9checs statistiques (2)")))
  for (j in ordre_jeux(names(DL))) for (r in names(PERIMETRE[[j]])) {
    x <- DL[[j]][DL[[j]]$statut == "rejouee" & DL[[j]]$regime == r, , drop = FALSE]
    tot <- x$dd_bord0 + x$dd_bord1 + x$dd_interieur
    own <- x[[paste0("dd_", r)]]
    m <- function(v) if (nrow(x)) num(mean(v / tot), 3) else "\u2014"
    L <- c(L, ligne_md(j, REGIMES[[r]], nrow(x), m(x$dd_bord0), m(x$dd_interieur), m(x$dd_bord1),
                       if (nrow(x)) sprintf("%.0f [%.0f ; %.0f]", stats::median(own), min(own), max(own)) else "\u2014",
                       sum(x$echec_rapide), sum(x$echec_stats1), sum(x$echec_rapide + x$echec_stats1),
                       sum(x$echec_contraint), sum(x$echec_stats2)))
  }
  L <- c(L, "", "Comparaison appari\u00e9e des p (r\u00e9plications o\u00f9 les deux p sont calcul\u00e9es) :", "",
         entete_md(c("Jeu", "R\u00e9gime", "Statistique", "paires (2, 1)", "p2 > p1", "p2 = p1", "p2 < p1",
                     "m\u00e9diane de p2 \u2212 p1", "paires (3, 1)", "p3 > p1", "p3 = p1", "p3 < p1", "m\u00e9diane de p3 \u2212 p1")))
  for (j in ordre_jeux(names(DL))) for (r in names(PERIMETRE[[j]])) for (s in intersect(STATS_175, PERIMETRE[[j]][[r]])) {
    x <- DL[[j]][DL[[j]]$statut == "rejouee" & DL[[j]]$regime == r, , drop = FALSE]
    p1 <- x[[paste0("p1:", s)]]
    cmp <- function(v) {
      pv <- x[[sprintf("p%s:%s", v, s)]]; ok <- is.finite(p1) & is.finite(pv)
      d <- pv[ok] - p1[ok]
      c(sum(ok), sum(d > 0), sum(d == 0), sum(d < 0), if (any(ok)) num(stats::median(d), 4) else "\u2014")
    }
    L <- c(L, ligne_md(j, REGIMES[[r]], s, paste(cmp("2"), collapse = " | "), paste(cmp("3"), collapse = " | ")))
  }
  # Variante 3 : taux du moteur restreint aux replications ou p3 est
  # definie (lecture descriptive du critere revise).
  L <- c(L, "", sprintf("Variante 3 : taux du moteur (variante 1, p absente = non-rejet) restreint aux r\u00e9plications o\u00f9 p3 est d\u00e9finie, \u03b1 = %s :",
                        num(ALPHA, 2)), "",
         entete_md(c("Jeu", "R\u00e9gime", "Statistique", "rejou\u00e9es", "p3 d\u00e9finie (n)", sprintf("p1 < %s : k", num(ALPHA, 2)),
                     "taux du moteur", "IC 95 %")))
  for (j in ordre_jeux(names(DL))) for (r in names(PERIMETRE[[j]])) for (s in intersect(STATS_175, PERIMETRE[[j]][[r]])) {
    x <- DL[[j]][DL[[j]]$statut == "rejouee" & DL[[j]]$regime == r, , drop = FALSE]
    d3 <- is.finite(x[[paste0("p3:", s)]]); p1 <- x[[paste0("p1:", s)]][d3]
    n <- sum(d3); k <- sum(is.finite(p1) & p1 < ALPHA)
    L <- c(L, ligne_md(j, REGIMES[[r]], s, nrow(x), n, k, if (n) num(k / n, 4) else "\u2014", txt_ic(ic_cp(k, n))))
  }
  c(L, "", paste("Variante 1 : p de usp_bootstrap() (moteur), sous-catalogue du r\u00e9gime ; 2 : \u03b4 fix\u00e9 \u00e0 \u03b4\u0302*_b, sur les",
                 "m\u00eames r\u00e9plications internes retenues que la variante 1 (les r\u00e9plications internes \u00e9cart\u00e9es par la variante 1 ne",
                 "sont pas rejou\u00e9es \u00e0 \u03b4 fix\u00e9) ; 3 : r\u00e9plications internes retenues dont \u03b4\u0302** est dans le r\u00e9gime de",
                 "\u03b4\u0302*_b. RESET et Grubbsr ne d\u00e9pendent pas de l'ajustement : p2 = p1 si aucun r\u00e9ajustement \u00e0 \u03b4 fix\u00e9",
                 "n'\u00e9choue (contr\u00f4le de coh\u00e9rence)."), "")
}

tableau_t3 <- function(OL) {
  L <- c("### T3 -- jeux observ\u00e9s (bootstrap de run_engine(), graine 20260831)", "")
  for (j in ordre_jeux(names(OL))) {
    o <- OL[[j]]
    tot <- o$dd_bord0 + o$dd_bord1 + o$dd_interieur
    L <- c(L, sprintf(paste("%s : \u03b4\u0302 = %s (%s) ; \u03b4\u0302** : %.0f au bord 0, %.0f int\u00e9rieurs, %.0f au bord 1 (sur %.0f",
                            "retenues) ; \u00e9checs : usp_ajuster_rapide() %.0f, statistiques (1) %.0f, usp_ajuster_contraint() %.0f,",
                            "statistiques (2) %.0f."),
                      j, num(o$delta, 6), REGIMES[[o$regime]], o$dd_bord0, o$dd_interieur, o$dd_bord1, tot, o$echec_rapide,
                      o$echec_stats1, o$echec_contraint, o$echec_stats2), "",
           entete_md(c("Statistique (sens)", paste0("p", 1:3, " (B effectif)"), "motif d'absence")))
    for (s in STATS_175) {
      cel <- vapply(1:3, function(v) {
        p <- o[[sprintf("p%d:%s", v, s)]]
        sprintf("%s (%.0f)", if (is.finite(p)) num(p, 4) else "\u2014", o[[sprintf("B%d:%s", v, s)]])
      }, "")
      mot <- vapply(1:3, function(v) o[[sprintf("m%d:%s", v, s)]], "")
      mot <- mot[mot != "NA"]
      L <- c(L, ligne_md(sprintf("%s (%s)", s, USP_CATALOGUE_MC[[s]]$queue), cel[1], cel[2], cel[3],
                         if (length(mot)) paste(unique(abreger_motif(mot)), collapse = " ; ") else "\u2014"))
    }
    L <- c(L, "")
  }
  L
}

# Texte du commentaire 6060869720 de la PR #228 (critere de verdict revise,
# decision du mainteneur du 08/10/2026), reporte sans modification (lignes 1
# a 32 du corps, sans le pied de page) ; cite en citation markdown dans
# aide_lecture().
TEXTE_CRITERE_228 <- c(
  "## #175 : crit\u00e8re de verdict r\u00e9vis\u00e9 avant l'ex\u00e9cution (d\u00e9cision du mainteneur, 08/10/2026)",
  "",
  "`actuary-approfondi` propose une r\u00e9vision en r\u00e9ponse aux questions de `coder` sur `tests/conservatisme_interieur_t8.R`, et le mainteneur l'approuve. Elle modifie le crit\u00e8re approuv\u00e9 dans le commentaire 6058031276. Le texte est report\u00e9 dans le script et commit\u00e9 **avant** le lancement des tranches, ce qui le fixe d'avance.",
  "",
  "**Motifs**",
  "- La variante conditionnelle \u00e9tait jug\u00e9e sur les seules p d\u00e9finies. C'est un sous-ensemble choisi par les donn\u00e9es, avec un IC plus large, ce qui biaise le jugement en faveur de \u00ab proposer \u00bb.",
  "- RESET au bord 0 est d\u00e9j\u00e0 disjoint de la bande pour le moteur au 30/09, et p2 \u2261 p1 pour cette statistique. La lecture absolue de la condition (2) \u00e9liminait donc la variante \u03b4 fix\u00e9 avant toute mesure.",
  "",
  "**Crit\u00e8re r\u00e9vis\u00e9**",
  "",
  "*Grandeurs.*",
  "- Le crit\u00e8re se lit sur J2, \u00e0 \u03b1 = 0,10 ; T1' (\u03b1 = 0,05) et J1 sont descriptifs.",
  "- Pour une cellule (r\u00e9gime, statistique, variante) :",
  "  - n_rep est le nombre de r\u00e9plications rejou\u00e9es du r\u00e9gime, le m\u00eame pour les trois variantes ;",
  "  - k est le nombre de p d\u00e9finies et inf\u00e9rieures \u00e0 0,10 ; une p absente compte comme un non-rejet ;",
  "  - le taux vaut k / n_rep ;",
  "  - l'IC est celui de Clopper-Pearson \u00e0 95 % sur (k, n_rep).",
  "- La bande est [0,05 ; 0,15].",
  "- Les classes de #166 sont, dans l'ordre : compatible, \u00e9cart mineur, \u00e9cart non tranch\u00e9, distorsion mat\u00e9rielle (IC disjoint).",
  "",
  "*\u00ab Proposer une \u00e9volution \u00bb* si une variante (2 ou 3) remplit les trois conditions suivantes.",
  "1. **Correction.** Parmi les huit statistiques au r\u00e9gime int\u00e9rieur, au moins 5 ont un IC du moteur disjoint de la bande et un IC de la variante non disjoint.",
  "2. **Aucune distorsion cr\u00e9\u00e9e, invers\u00e9e ni aggrav\u00e9e** sur les treize cellules de J2 : les huit statistiques, AD et White au r\u00e9gime int\u00e9rieur ; GQ aux r\u00e9gimes \u03b4\u0302* = 0 et \u03b4\u0302* = 1 ; RESET \u00e0 \u03b4\u0302* = 0.",
  "   - (a) Si l'IC du moteur n'est pas disjoint de la bande, celui de la variante ne l'est pas non plus.",
  "   - (b) S'il l'est, celui de la variante n'est pas disjoint du c\u00f4t\u00e9 oppos\u00e9, et son taux ne d\u00e9passe pas l'IC du moteur du c\u00f4t\u00e9 de la distorsion.",
  "3. **T\u00e9moins.** Pour AD et White, la classe de la variante n'est pas pire que celle du moteur.",
  "",
  "Sinon, *\u00ab conserver et documenter \u00bb*.",
  "",
  "*Lectures descriptives, hors crit\u00e8re :* taux sur les seules p d\u00e9finies (k / n) ; pour la variante 3, taux du moteur restreint aux r\u00e9plications o\u00f9 p3 est d\u00e9finie ; J1 ; \u03b1 = 0,05.",
  "",
  "**Autres changements.** (i2) est \u00e9tendu \u00e0 la premi\u00e8re r\u00e9plication int\u00e9rieure de chaque tranche. Les deux constats mineurs de l'audit l\u00e9ger sont corrig\u00e9s dans la m\u00eame reprise : cellule \u00e0 n = 0 jug\u00e9e \u00ab non \u00e9valuable \u00bb, variantes 2 et 3 calcul\u00e9es sur le sous-catalogue du r\u00e9gime.")
aide_lecture <- function() c(
  "### Aide \u00e0 la lecture", "",
  paste("Statut : **constat de simulation sous le mod\u00e8le ajust\u00e9 au jeu** (usp_simuler(FIT0)), pas un r\u00e9sultat",
        "g\u00e9n\u00e9ral. R\u00e9plications de la calibration de #166 / #221 ; bootstrap de chaque r\u00e9plication rejou\u00e9 (m\u00eames y**,",
        "contr\u00f4les (i1) et (i2)), trois p-values sur les m\u00eames y** : 1, moteur (usp_ajuster_rapide()) ; 2, \u03b4 fix\u00e9",
        "\u00e0 \u03b4\u0302*_b (usp_ajuster_contraint()), sur les m\u00eames r\u00e9plications internes retenues que la variante 1 ; 3,",
        "conditionnelle au r\u00e9gime (r\u00e9plications internes retenues dont \u03b4\u0302** est dans le r\u00e9gime de \u03b4\u0302*_b ; p absente",
        sprintf("si le B effectif est inf\u00e9rieur \u00e0 B_MIN_DEGENERESCENCE = %d). **Aucune r\u00e9f\u00e9rence ne fonde la variante 3",
                B_MIN_DEGENERESCENCE),
        "\u00e0 T = 8.** J1 est descriptif."), "",
  paste("IC : Clopper-Pearson \u00e0 95 %, incertitude Monte-Carlo sur le taux (fonction du nombre de r\u00e9plications), pas",
        "l'erreur d'approximation en T. Taux par r\u00e9gime : conditionnels \u00e0 un \u00e9v\u00e9nement fonction des donn\u00e9es, sans",
        "r\u00e9f\u00e9rence exacte m\u00eame pour une p parfaitement calibr\u00e9e ; \u00ab \u03b1 dans l'IC \u00bb se lit \u00ab aucune distorsion",
        "d\u00e9tect\u00e9e \u00e0 la pr\u00e9cision Monte-Carlo \u00bb, jamais \u00ab exact \u00bb. Bande de Bradley (1978) [\u03b1/2 ; 3\u03b1/2] :",
        "convention, pas th\u00e9or\u00e8me (r\u00e8gle de lecture de #166). Taux du crit\u00e8re : k / n_rep, n_rep \u00e9tant le nombre de",
        "r\u00e9plications rejou\u00e9es du r\u00e9gime, d\u00e9nominateur commun aux trois variantes, une p absente comptant comme un",
        "non-rejet ; le taux sur les seules p d\u00e9finies (k / n, colonne \u00ab taux sur n \u00bb) est descriptif, n \u00e9tant choisi",
        "par les donn\u00e9es (la variante 3 est s\u00e9lectionn\u00e9e par son B effectif)."), "",
  paste("**Crit\u00e8re de verdict, fix\u00e9 avant l'ex\u00e9cution** : crit\u00e8re r\u00e9vis\u00e9 du commentaire 6060869720 de la PR #228",
        "(d\u00e9cision du mainteneur du 08/10/2026), qui modifie celui de la sp\u00e9cification d'actuary (#175, commentaire",
        "6058041254) approuv\u00e9 dans le commentaire 6058031276 de la PR #228 ; texte report\u00e9 sans modification :"), "",
  ifelse(nzchar(TEXTE_CRITERE_228), paste(">", TEXTE_CRITERE_228), ">"), "",
  paste("Suites pr\u00e9vues par la sp\u00e9cification d'actuary : \u00ab proposer une \u00e9volution \u00bb ouvre une issue nouvelle, avec",
        "une calibration compl\u00e8te avant tout changement du moteur ; \u00ab conserver et documenter \u00bb porte dans les",
        "rubriques 7 des fiches la mention \u00ab perte de puissance conditionnelle au r\u00e9gime int\u00e9rieur \u00bb."), "",
  paste("\u00c9valuation m\u00e9canique ci-dessous, **sans conclure** (le verdict revient \u00e0 actuary), avec les lectures",
        "conformes au crit\u00e8re : \u00ab disjoint de la bande \u00bb (hors bande) = IC \u00e0 95 % sur les rejou\u00e9es disjoint de",
        "[0,05 ; 0,15], c\u00f4t\u00e9 conservateur (borne haute < 0,05) ou lib\u00e9ral (borne basse > 0,15) ; r\u00e9gimes mesur\u00e9s =",
        "ceux de J2, soit les treize cellules de la condition (2) ; t\u00e9moins par classes de #166 (compatible : 0,10",
        "dans l'IC ; sinon distorsion mat\u00e9rielle : IC disjoint de la bande ; sinon \u00e9cart mineur : taux dans la",
        "bande ; sinon \u00e9cart non tranch\u00e9). Une cellule sans r\u00e9plication rejou\u00e9e (n_rep = 0) est \u00ab non",
        "\u00e9valuable \u00bb ; une cellule sans aucune p d\u00e9finie (n = 0) est \u00e9valu\u00e9e avec k = 0 (une p absente",
        "compte comme un non-rejet), et T1 l'indique par n = 0. Une cellule non \u00e9valuable ne remplit jamais (1) ni (2), ni",
        "(3) ; une condition dont les cellules \u00e9valuables ne suffisent pas \u00e0 trancher est \u00ab non \u00e9valuable \u00bb."), "",
  paste("**Angle mort du sous-catalogue.** Dans une r\u00e9plication, les trois variantes ne calculent que les statistiques",
        "du p\u00e9rim\u00e8tre de son r\u00e9gime : une r\u00e9plication interne y est retenue si le r\u00e9ajustement rapide et ces",
        "statistiques aboutissent, alors que usp_bootstrap() exige que les 34 statistiques du catalogue aboutissent.",
        "Si une statistique hors p\u00e9rim\u00e8tre \u00e9chouait seule, la r\u00e9tention diff\u00e9rerait de celle du moteur, et la p de la",
        "variante 1 pourrait alors diff\u00e9rer de celle de #221 (contr\u00f4le (i1)). Sur les essais de mise au point",
        "(J2 \u00e0 R = 6, J1 \u00e0 R = 5), aucun \u00e9chec de r\u00e9ajustement ni de statistique n'a \u00e9t\u00e9 compt\u00e9 (T2, T3)."), "")

###############################################################################
#  LIGNES MACHINE : LECTURE D'UNE SORTIE DE TRANCHE
###############################################################################
refuser <- function(...) {
  message("--combiner : REFUS -- ", ...)
  quit(status = 1L)
}
CLES_CONTEXTE <- c("jeu", "modele", "configuration", "perimetre", "graines", "collisions", "generateur", "commit",
                   "plateforme", "empreintes", "reference", "brut221_chemin", "brut221_md5", "brut221_suivi",
                   "brut221_R", "tableau221_chemin", "tableau221_md5", "tableau221_suivi", "i3")
CLES_COMMUNES <- c("generateur", "commit", "plateforme", "empreintes", "reference", "configuration", "perimetre")
LIBELLES_CONTEXTE <- c(
  jeu = "Jeu", modele = "Mod\u00e8le ajust\u00e9 (usp_ajuster())", configuration = "Configuration",
  perimetre = "P\u00e9rim\u00e8tre (jeu, r\u00e9gime de \u03b4\u0302*, statistiques)", graines = "Graines",
  collisions = "Graines en collision (d\u00e9clar\u00e9es, non bloquantes)", generateur = "G\u00e9n\u00e9rateur",
  commit = "Commit", plateforme = "Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)",
  empreintes = "Empreintes md5 du code ex\u00e9cut\u00e9",
  reference = "Contr\u00f4le (a) : J1 observ\u00e9 contre tests/reference/premium.rds",
  brut221_chemin = "Valeurs brutes de #221", brut221_md5 = "md5 des valeurs brutes de #221",
  brut221_suivi = "Valeurs brutes de #221 suivies par git", brut221_R = "R\u00e9plications des valeurs brutes de #221",
  tableau221_chemin = "Tableau de #221 (T0 : md5 du moteur)", tableau221_md5 = "md5 du tableau de #221",
  tableau221_suivi = "Tableau de #221 suivi par git", i3 = "Contr\u00f4le (i3)")

lire_sortie <- function(f) {
  if (!file.exists(f)) refuser(f, " introuvable")
  l <- readLines(f, warn = FALSE, encoding = "UTF-8")
  champs <- function(etq) strsplit(sub(paste0("^", etq, "\t"), "", grep(paste0("^", etq, "\t"), l, value = TRUE)), "\t")
  unique1 <- function(etq) {
    x <- champs(etq)
    if (length(x) != 1L) refuser(f, " : ", length(x), " ligne(s) ", etq, " (une attendue) -- sortie de tranche incomplete ?")
    x[[1]]
  }
  integ <- champs("INTEGRITE")
  if (length(integ) != 1L) refuser(f, " : ligne INTEGRITE absente ou multiple")
  if (!identical(integ[[1]], "OK")) refuser(f, " : controle d'integrite de la tranche en ECHEC")
  non_vides <- l[nzchar(trimws(l))]
  if (!length(non_vides) || !startsWith(non_vides[length(non_vides)], "FIN\t"))
    refuser(f, " : la ligne FIN n'est pas la derniere ligne -- sortie tronquee ou modifiee")
  par <- unique1("PARAMETRES"); tr <- unique1("TRANCHE")
  ctx <- champs("CONTEXTE")
  if (!length(ctx) || any(lengths(ctx) != 2L)) refuser(f, " : lignes CONTEXTE absentes ou illisibles")
  ctx <- stats::setNames(vapply(ctx, `[`, "", 2L), vapply(ctx, `[`, "", 1L))
  if (!setequal(names(ctx), CLES_CONTEXTE) || anyDuplicated(names(ctx)))
    refuser(f, " : lignes CONTEXTE incompletes (attendues : ", paste(CLES_CONTEXTE, collapse = ", "), ")")
  st <- unique1("STATS"); rc <- unique1("REPCOLS")
  if (!identical(rc, REPCOLS)) refuser(f, " : REPCOLS differentes de celles du script")
  obs <- unique1("OBS")
  if (length(obs) != length(REPCOLS)) refuser(f, " : ligne OBS de longueur differente de REPCOLS")
  du <- suppressWarnings(as.numeric(unique1("DUREE")))
  if (length(du) != 9L || anyNA(du)) refuser(f, " : ligne DUREE illisible")
  n_rep <- suppressWarnings(as.integer(unique1("NREP")))
  rp <- champs("REP")
  fin <- suppressWarnings(as.integer(unique1("FIN")))
  if (is.na(n_rep) || length(rp) != n_rep || !identical(fin, n_rep))
    refuser(f, sprintf(" : %d ligne(s) REP lue(s), NREP = %s, FIN = %s -- sortie tronquee ou modifiee", length(rp), n_rep, fin))
  if (any(lengths(rp) != length(REPCOLS))) refuser(f, " : ligne REP de longueur differente de REPCOLS")
  jeu <- sub("^jeu=(J[12]);.*$", "\\1", par)
  list(fichier = f, parametres = par, jeu = jeu, R = as.integer(sub("^.*;R=([0-9]+);.*$", "\\1", par)),
       debut = as.integer(tr[1]), fin = as.integer(tr[2]), contexte = ctx[CLES_CONTEXTE], stats = st,
       obs = obs, duree = du, rep = rp)
}
# Invariants du corps d'une tranche : texte des invariants faux.
invariants_tranche <- function(p) {
  err <- character(0)
  d <- en_table(p$rep)
  if (!identical(as.integer(sort(d$b)), seq.int(p$debut, p$fin))) err <- c(err, "b des lignes REP differents de debut..fin")
  per <- PERIMETRE[[p$jeu]]
  attendu <- ifelse(d$regime == "ecartee", "ecartee", ifelse(d$regime %in% names(per), "rejouee", "non rejouee"))
  if (!identical(d$statut, attendu)) err <- c(err, "statut incoherent avec le regime et le perimetre")
  rj <- d$statut == "rejouee"
  if (any(d$i1[rj] != "OK")) err <- c(err, "(i1) non OK sur une replication rejouee")
  for (r in names(per)) {
    x <- d[rj & d$regime == r, , drop = FALSE]
    hors <- setdiff(STATS_175, per[[r]])
    if (nrow(x) && (any(x[, paste0("m1:", per[[r]])] == "-") || any(x[, paste0("m1:", hors)] != "-")))
      err <- c(err, sprintf("statistiques calculees differentes du perimetre (regime %s)", r))
  }
  err
}

###############################################################################
#  MODE --combiner
###############################################################################
if (length(FICHIERS_COMB)) {
  if (!is.na(OPT_SORTIE) && sous_depot(OPT_SORTIE))
    refuser("--sortie : dossier sous le depot refuse (--ecrire est le seul chemin qui ecrit dans le depot) : ", OPT_SORTIE)
  if (!is.na(OPT_BRUT)) {
    if (!dir.exists(dirname(OPT_BRUT))) refuser("--brut : dossier introuvable : ", dirname(OPT_BRUT))
    if (sous_depot(dirname(OPT_BRUT)))
      refuser("--brut : chemin sous le depot refuse (copie dans docs/tableaux/ sur decision du mainteneur) : ", OPT_BRUT)
    if (file.exists(OPT_BRUT)) refuser("--brut : fichier existant, jamais ecrase : ", OPT_BRUT)
  }
  parts <- lapply(FICHIERS_COMB, lire_sortie)
  jeux <- unique(vapply(parts, `[[`, "", "jeu"))
  if (!all(jeux %in% c("J1", "J2"))) refuser("jeu illisible dans PARAMETRES")
  # Champs communs aux deux jeux.
  for (k in CLES_COMMUNES) if (length(unique(vapply(parts, function(p) p$contexte[[k]], ""))) != 1L)
    refuser("contexte (", k, ") different entre les tranches")
  if (length(unique(lapply(parts, `[[`, "stats"))) != 1L) refuser("lignes STATS differentes entre les tranches")
  DL <- list(); OL <- list(); CTX <- list(); RJ <- integer(0); DUR <- list()
  for (j in jeux) {
    pj <- parts[vapply(parts, function(p) p$jeu == j, logical(1))]
    if (length(unique(vapply(pj, `[[`, "", "parametres"))) != 1L) refuser("parametres differents entre les tranches de ", j)
    if (length(unique(lapply(pj, `[[`, "contexte"))) != 1L) {
      kd <- CLES_CONTEXTE[vapply(CLES_CONTEXTE, function(k) length(unique(vapply(pj, function(p) p$contexte[[k]], ""))) > 1L, logical(1))]
      refuser("contexte (T0) different entre les tranches de ", j, " : ", paste(kd, collapse = ", "))
    }
    if (length(unique(lapply(pj, `[[`, "obs"))) != 1L) refuser("ligne OBS (jeu observe) differente entre les tranches de ", j)
    R_j <- pj[[1]]$R
    idx <- unlist(lapply(pj, function(p) seq.int(p$debut, p$fin)))
    if (anyDuplicated(idx) || !setequal(idx, seq_len(R_j))) refuser("les tranches de ", j, " ne couvrent pas 1..", R_j, " exactement une fois")
    for (p in pj) {
      e <- invariants_tranche(p)
      if (length(e)) refuser(p$fichier, " : invariant(s) du corps faux -- ", paste(e, collapse = " ; "))
    }
    d <- en_table(do.call(c, lapply(pj, `[[`, "rep")))
    DL[[j]] <- d[order(d$b), , drop = FALSE]
    OL[[j]] <- en_table(list(pj[[1]]$obs))
    CTX[[j]] <- pj[[1]]$contexte
    RJ[j] <- R_j
    DUR[[j]] <- Reduce(`+`, lapply(pj, `[[`, "duree"))
  }
  COMMIT_COMB <- commit_depot(SCRIPT)
  EMPREINTES_COMB <- empreintes_code(SCRIPT, SCRIPT_72)
  nv <- c(motifs_non_versionnable(CTX[[1]][["commit"]], CTX[[1]][["empreintes"]]),
          motifs_non_versionnable(COMMIT_COMB, EMPREINTES_COMB, "de la combinaison"))
  if (!setequal(jeux, c("J1", "J2"))) nv <- c(nv, "J1 et J2 ne sont pas tous deux combin\u00e9s")
  for (j in jeux) {
    cx <- CTX[[j]]
    if (!identical(as.integer(cx[["brut221_R"]]), RJ[[j]]))
      nv <- c(nv, sprintf("%s : R = %d, valeurs brutes de #221 \u00e0 %s r\u00e9plications", j, RJ[[j]], cx[["brut221_R"]]))
    for (q in c("brut221", "tableau221")) {
      f <- file.path(RACINE, cx[[paste0(q, "_chemin")]])
      if (!identical(cx[[paste0(q, "_suivi")]], "oui") || !identical(suivi_git(f), "oui"))
        nv <- c(nv, sprintf("%s : %s non suivi par git", j, cx[[paste0(q, "_chemin")]]))
      else if (!identical(md5_fichier(f), cx[[paste0(q, "_md5")]]))
        nv <- c(nv, sprintf("%s : %s modifi\u00e9 depuis les tranches (md5)", j, cx[[paste0(q, "_chemin")]]))
    }
  }
  if (OPT_ECRIRE && length(nv))
    refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
            " -- relancer sur un arbre propre, ou utiliser --sortie DOSSIER hors du depot")
  # T0
  t0 <- c(entete_md(c("Grandeur", "Valeur")),
          vapply(CLES_COMMUNES, function(k) ligne_md(LIBELLES_CONTEXTE[[k]], CTX[[1]][[k]]), ""))
  for (j in ordre_jeux(jeux)) {
    t0 <- c(t0, vapply(setdiff(CLES_CONTEXTE, CLES_COMMUNES), function(k)
      ligne_md(sprintf("%s : %s", j, LIBELLES_CONTEXTE[[k]]), CTX[[j]][[k]]), ""))
    du <- DUR[[j]]
    t0 <- c(t0, ligne_md(sprintf("%s : R\u00e9plications", j), sprintf("%d (%s)", RJ[[j]],
                         paste(vapply(parts[vapply(parts, function(p) p$jeu == j, logical(1))],
                                      function(p) sprintf("%d-%d", p$debut, p$fin), ""), collapse = ", "))),
            ligne_md(sprintf("%s : Dur\u00e9e cumul\u00e9e (s)", j), texte_duree(du)))
  }
  t0 <- c(t0, ligne_md("Commit de la combinaison", COMMIT_COMB), ligne_md("Empreintes md5 du combinateur", EMPREINTES_COMB),
          ligne_md("Versionnable (--ecrire)", if (length(nv)) paste("non :", paste(nv, collapse = " ; ")) else "oui"),
          ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", sprintf("OK dans les %d tranche(s) ((a), (b), (c), (i1), (i2), (i3), (d), coh\u00e9rence), invariants du corps v\u00e9rifi\u00e9s",
                                                               length(parts))))
  sortie <- c(sprintf("## Conservatisme des p-values Monte-Carlo au r\u00e9gime \u03b4\u0302 int\u00e9rieur, T = 8 -- combinaison de %d tranche(s) (issue #175)",
                      length(parts)), "",
              sprintf("Param\u00e8tres : %s", paste(vapply(ordre_jeux(jeux), function(j)
                parts[vapply(parts, function(p) p$jeu == j, logical(1))][[1]]$parametres, ""), collapse = " | ")), "",
              "### T0 -- provenance (identique dans les tranches de chaque jeu, v\u00e9rifi\u00e9)", "", t0, "",
              aide_lecture(), evaluer_critere(DL),
              tableau_t1(DL, ALPHA, TITRE_T1),
              tableau_t1(DL, ALPHA2, TITRE_T1B),
              tableau_t2(DL), tableau_t3(OL))
  ecrire_console(sortie)
  if (OPT_ECRIRE || !is.na(OPT_SORTIE)) {
    f <- if (OPT_ECRIRE) CIBLE_ECRIRE else file.path(OPT_SORTIE, NOM_SORTIE)
    if (OPT_ECRIRE) {
      # Gardes reprises avant d'ecrire (l'etat du depot a pu changer).
      nv1 <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, SCRIPT_72), "de la combinaison")
      if (length(nv1)) refuser("--ecrire refuse : ", paste(nv1, collapse = " ; "))
      sortie <- inserer_t0(sortie, ligne_remplacement(garde_ecrasement(f, OPT_REMPLACER, RACINE), f))
    }
    con <- file(f, open = "wb"); writeLines(enc2utf8(sortie), con, useBytes = TRUE); close(con)
    message("\u00e9crit : ", f)
  }
  if (!is.na(OPT_BRUT)) {
    lignes <- unlist(lapply(ordre_jeux(jeux), function(j) {
      pj <- parts[vapply(parts, function(p) p$jeu == j, logical(1))]
      rp <- c(list(pj[[1]]$obs), do.call(c, lapply(pj, `[[`, "rep")))
      rp <- rp[order(as.integer(vapply(rp, `[`, "", 1L)))]
      vapply(rp, function(x) paste(c(j, x), collapse = "\t"), "")
    }))
    con <- file(OPT_BRUT, open = "wb")
    writeLines(enc2utf8(c(paste(c("jeu", REPCOLS), collapse = "\t"), lignes)), con, useBytes = TRUE)
    close(con)
    message("\u00e9crit (valeurs brutes, ", length(lignes), " lignes) : ", OPT_BRUT)
  }
  quit(status = 0L)
}

###############################################################################
#  EXECUTION (d'un seul tenant ou tranche)
###############################################################################
# Commit lu au debut du calcul (moteur et script charges).
COMMIT <- commit_depot(SCRIPT)
EMPREINTES <- empreintes_code(SCRIPT, SCRIPT_72)
INTEGRITE <- character(0)          # libelles des controles en echec
CONTROLES <- character(0)          # lignes "libelle : OK / ECHEC"
controle <- function(ok, libelle) {
  ok <- isTRUE(ok)
  if (!ok) INTEGRITE <<- c(INTEGRITE, libelle)
  CONTROLES <<- c(CONTROLES, sprintf("%s : %s", libelle, if (ok) "OK" else "\u00c9CHEC"))
  invisible(ok)
}
liste_b <- function(v) if (length(v)) paste0(" : r\u00e9plication(s) ", paste(utils::head(unique(v), 20), collapse = ", "),
                                              if (length(unique(v)) > 20) ", ..." else "") else ""

# --- Jeu et modele ajuste (lire_j2() : copie de tests/calibration_mc_t8.R) ------
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
X <- JEU$x
stopifnot(length(X) == T_, length(JEU$y) == T_)
FIT0 <- usp_ajuster(X, JEU$y)
PER <- PERIMETRE[[OPT_JEU]]

# Tranche (bornes : copie de tests/calibration_mc_t8.R)
if (is.na(OPT_TRANCHE)) { DEBUT <- 1L; FIN <- OPT_R } else {
  m <- regmatches(OPT_TRANCHE, regexec("^([0-9]+)/([0-9]+)$", OPT_TRANCHE))[[1]]
  if (length(m) != 3L) stop("--tranche : forme i/K attendue")
  i <- as.integer(m[2]); K <- as.integer(m[3])
  if (K < 1L || i < 1L || i > K || K > OPT_R) stop("--tranche : 1 <= i <= K <= R")
  DEBUT <- as.integer(floor((i - 1) * OPT_R / K)) + 1L; FIN <- as.integer(floor(i * OPT_R / K))
}
t_c <- Sys.time()

# --- Sources de #221 : valeurs brutes et tableau (controles (c), (i1), (i3)) ----
derniere_source <- function(type, ext) {
  d <- file.path(RACINE, "docs", "tableaux")
  f <- sort(list.files(d, pattern = sprintf("^[0-9]{8}-issue166-%s-%s\\.%s$", type, OPT_JEU, ext)))
  if (length(f)) file.path(d, f[length(f)]) else NA_character_
}
F_BRUT221 <- if (!is.na(OPT_BRUT221)) OPT_BRUT221 else derniere_source("brut", "tsv")
F_TAB221 <- if (!is.na(OPT_TAB221)) OPT_TAB221 else if (!is.na(OPT_BRUT221)) NA_character_ else {
  f <- sub("-issue166-brut-", "-issue166-calibration-", sub("\\.tsv$", ".md", F_BRUT221))
  if (!is.na(f) && file.exists(f)) f else NA_character_
}
if (is.na(F_BRUT221) || !file.exists(F_BRUT221)) stop("valeurs brutes de #221 introuvables (--brut-221) : ", F_BRUT221)
if (is.na(F_TAB221) || !file.exists(F_TAB221)) stop("tableau de #221 introuvable (--tableau-221) : ", F_TAB221)
BRUT221 <- local({
  l <- readLines(F_BRUT221, warn = FALSE, encoding = "UTF-8")
  en <- strsplit(l[1], "\t", fixed = TRUE)[[1]]
  M <- do.call(rbind, strsplit(l[-1], "\t", fixed = TRUE))
  if (is.null(M) || ncol(M) != length(en)) stop("valeurs brutes de #221 illisibles : ", F_BRUT221)
  colnames(M) <- en
  if (!all(c("b", "regime", paste0("p_mc:", names(USP_CATALOGUE_MC))) %in% en))
    stop("valeurs brutes de #221 : colonnes b, regime ou p_mc:<stat> absentes : ", F_BRUT221)
  if (!identical(as.integer(M[, "b"]), seq_len(nrow(M)))) stop("valeurs brutes de #221 : b different de 1..R : ", F_BRUT221)
  M
})
if (OPT_R > nrow(BRUT221)) stop(sprintf("--R = %d au-dela des %d replications des valeurs brutes de #221", OPT_R, nrow(BRUT221)))
# (i3) : md5 du moteur et parametres du tableau de #221.
I3 <- local({
  l <- enc2utf8(readLines(F_TAB221, warn = FALSE, encoding = "UTF-8"))
  emp <- l[startsWith(l, "| Empreintes md5 du code ex\u00e9cut\u00e9 |")]
  md5_t <- if (length(emp) == 1L) regmatches(emp, regexec("R/engine\\.R ([0-9a-f]{32})", emp))[[1]][2] else NA_character_
  par <- l[startsWith(l, "Param\u00e8tres : ")]
  val <- function(cle) {
    if (length(par) != 1L) return(NA_character_)
    m <- regmatches(par, regexec(sprintf("[ ;]%s=([^;]*)", cle), par))[[1]]
    if (length(m) == 2L) m[2] else NA_character_
  }
  md5_e <- md5_fichier(file.path(RACINE, "R", "engine.R"))
  attendu <- c(jeu = OPT_JEU, R = as.character(nrow(BRUT221)), graine_jeux = sprintf("%.0f", GRAINE_JEUX),
               graine_boot = sprintf("%.0f", GRAINE_BOOT), B = as.character(B_BOOT), alpha = format(ALPHA),
               theta_equiv = format(THETA_EQUIV))
  lu <- vapply(names(attendu), val, "")
  ok_md5 <- identical(md5_t, md5_e); ok_par <- identical(unname(lu), unname(attendu))
  list(ok = ok_md5 && ok_par,
       texte = sprintf("%s : md5 de R/engine.R %s, T0 du tableau de #221 %s ; param\u00e8tres du tableau %s",
                       if (ok_md5 && ok_par) "OK" else "\u00c9CHEC", md5_e, md5_t,
                       if (ok_par) "conformes" else paste("diff\u00e9rents :", paste(sprintf("%s=%s (attendu %s)", names(lu), lu, attendu)[lu != attendu | is.na(lu)], collapse = ", "))))
})
controle(I3$ok, paste("(i3)", I3$texte))

# --- (c) Les R jeux simules, d'un seul flux : expression YSIM de #72 -----------
OPT_GRAINE <- GRAINE_JEUX
YSIM <- engine_sous_graine(OPT_GRAINE, t(vapply(seq_len(OPT_R), function(b) usp_simuler(FIT0), numeric(T_))))
ysim_72 <- tryCatch({
  ex <- as.list(parse(file.path(RACINE, SCRIPT_72), keep.source = FALSE))
  cible <- Filter(function(e) is.call(e) && identical(e[[1]], as.name("<-")) &&
                    identical(e[[2]], as.name("YSIM")), ex)
  if (length(cible) != 1L) stop(length(cible), " affectation(s) de YSIM au niveau superieur (une attendue)")
  rhs <- cible[[1]][[3]]
  hors <- setdiff(all.names(rhs), NOMS_E2)
  if (length(hors)) stop("nom(s) hors de la liste blanche NOMS_E2 : ", paste(hors, collapse = ", "))
  env <- new.env(parent = emptyenv())
  liaisons <- list(engine_sous_graine = engine_sous_graine, usp_simuler = usp_simuler,
                   t = base::t, vapply = base::vapply, seq_len = base::seq_len, numeric = base::numeric,
                   "function" = base::`function`, "{" = base::`{`, "(" = base::`(`,
                   OPT_GRAINE = GRAINE_JEUX, OPT_R = OPT_R, FIT0 = FIT0, T_ = T_)
  stopifnot(setequal(names(liaisons), NOMS_E2))
  for (nm in names(liaisons)) assign(nm, liaisons[[nm]], envir = env)
  eval(rhs, env)
}, error = function(e) e)
controle(!inherits(ysim_72, "error") && identical(ysim_72, YSIM),
         sprintf("(c) %d jeux simul\u00e9s identiques \u00e0 ceux de l'expression YSIM de %s (noms en liste blanche, environnement isol\u00e9)%s",
                 OPT_R, SCRIPT_72, if (inherits(ysim_72, "error")) paste0(" (", conditionMessage(ysim_72), ")") else ""))

# Collisions de graines (copie de tests/calibration_mc_t8.R, texte abrege).
COLLISIONS <- local({
  b <- 0:OPT_R
  g <- GRAINE_BOOT + b
  autres <- c(jeux = GRAINE_JEUX, sw = SEED_LOI_NULLE_SW)
  lib <- c(jeux = "graine des jeux simul\u00e9s", sw = "SEED_LOI_NULLE_SW (loi nulle de Shapiro-Wilk)")
  x <- unlist(lapply(names(autres), function(nm) {
    i <- which(g == autres[[nm]])
    if (!length(i)) return(character(0))
    sprintf("r\u00e9plication %d : graine du bootstrap %.0f = %s (h\u00e9rit\u00e9e de #166, effet d\u00e9crit dans son T0)", b[i], g[i], lib[[nm]])
  }))
  if (length(x)) paste(x, collapse = " ; ") else sprintf("aucune pour b = 0..%d", OPT_R)
})

# --- (a) J1 observe contre la reference premium (copie de calibration_mc_t8.R) --
RES_A <- executer_cas("premium")
cmp_a <- comparer_objets(neutraliser_instables(readRDS(chemin_reference("premium"))),
                         neutraliser_instables(RES_A), tol = TOLERANCE)
TXT_A <- sprintf("%s ; %d feuille(s), %d non strictement identique(s), \u00e9cart maximal %s",
                 if (cmp_a$conforme) "conforme" else "NON CONFORME", cmp_a$n_feuilles, cmp_a$n_differentes,
                 formatC(cmp_a$ecart_max, format = "e", digits = 3))
controle(cmp_a$conforme, sprintf("(a) J1 observ\u00e9, run_engine(seed = %.0f), conforme \u00e0 tests/reference/premium.rds (comparer_objets(), tol\u00e9rance %g)%s",
                                 GRAINE_BOOT, TOLERANCE,
                                 if (cmp_a$conforme) "" else paste0(" : ", paste(resumer_comparaison(cmp_a, 5L), collapse = " ; "))))
controle(identical(unlist(RES_A$metadata[c("B", "alpha", "seed", "theta_equiv")]),
                   c(B = as.numeric(B_BOOT), alpha = ALPHA, seed = GRAINE_BOOT, theta_equiv = THETA_EQUIV)),
         "(a) configuration du cas premium (B, \u03b1, graine, theta_equiv) = celle du script")

# --- (b) Statistiques et sens de rejet lus dans USP_CATALOGUE_MC -----------------
controle(all(unique(unlist(PERIMETRE)) %in% names(USP_CATALOGUE_MC)) && length(STATS_175) == 11L &&
           all(c(STATS_8, TEMOINS, "RESET") %in% STATS_175),
         sprintf("(b) les %d statistiques du p\u00e9rim\u00e8tre sont au catalogue USP_CATALOGUE_MC ; sens lus au catalogue : %s",
                 length(STATS_175), paste(sprintf("%s %s", STATS_175, vapply(STATS_175, function(s) USP_CATALOGUE_MC[[s]]$queue, "")),
                                          collapse = ", ")))
# Coherence : RESET et Grubbsr ne dependent ni de z ni de pi (contexte
# observe de J2 et J1 a z et pi modifies).
controle(all(vapply(STATS_SANS_AJUSTEMENT, function(s) {
  e <- .usp_contexte_mc(FIT0$x, FIT0$y, FIT0$z, FIT0$pi)
  e2 <- e; e2$z <- rev(e$z) * 1.5; e2$pi <- e$pi * 2
  identical(USP_CATALOGUE_MC[[s]]$calc(e), USP_CATALOGUE_MC[[s]]$calc(e2))
}, logical(1))), sprintf("Coh\u00e9rence : %s ne d\u00e9pendent pas de l'ajustement (calc identique \u00e0 z et \u03c0 modifi\u00e9s, jeu observ\u00e9)",
                       paste(STATS_SANS_AJUSTEMENT, collapse = " et ")))

# --- Rejeu du bootstrap d'un ajustement (structure de usp_bootstrap()) -----------
# Chemin du moteur : memes appels que usp_bootstrap(), dans le meme ordre,
# sous la meme graine : y** <- usp_simuler(fit) ; reajustement rapide ;
# statistiques (catalogue complet si complet = TRUE, controle (i2) ;
# sous-catalogue noms sinon) ; si la replication est retenue, reajustement a
# delta fixe (bootstrap restreint de #45).
# Valeurs des tableaux, toujours sur le sous-catalogue noms, que complet soit
# vrai ou non (constat m2 de l'audit) : variante 1, replications internes
# retenues sur le sous-catalogue (reajustement rapide et statistiques
# aboutis) ; variante 2, statistiques au reajustement a delta fixe des
# MEMES replications (question Q1 de l'audit : les replications internes
# ecartees par le moteur ne sont pas rejouees a delta fixe, elles sont
# comptees a part) ; variante 3, replications de la variante 1 dont delta**
# est dans le regime de delta*. Comptes d'echecs sur le sous-catalogue. En
# mode complet, les statistiques du sous-catalogue sont extraites de celles
# du catalogue complet (calc evaluees statistique par statistique par
# .mc_evaluer()) ; si le catalogue complet echoue (statistique hors
# perimetre), elles sont evaluees sur le sous-catalogue. Appels hors du
# chemin du moteur (cette evaluation, reajustement a delta fixe d'une
# replication retenue sur le sous-catalogue seulement, statistiques de la
# variante 2) proteges : .Random.seed restaure.
proteger <- function(expr) {
  rs <- get(".Random.seed", envir = globalenv())
  on.exit(assign(".Random.seed", rs, envir = globalenv()))
  expr
}
rejouer <- function(fit, graine, noms, complet = FALSE) {
  cat_ <- USP_CATALOGUE_MC[names(USP_CATALOGUE_MC) %in% noms]
  cat_m <- if (complet) USP_CATALOGUE_MC else cat_
  ns <- names(cat_); nm <- names(cat_m)
  B <- B_BOOT
  e_obs <- .usp_contexte_mc(fit$x, fit$y, fit$z, fit$pi)
  simm <- matrix(NA_real_, B, length(nm), dimnames = list(NULL, nm))
  sim1 <- sim2 <- matrix(NA_real_, B, length(ns), dimnames = list(NULL, ns))
  d1 <- dm <- gm <- sm <- s_r <- rep(NA_real_, B)
  zb <- matrix(NA_real_, B, length(fit$x))
  ok1 <- ok2 <- rep(FALSE, B)
  n_ech <- c(rapide = 0L, stats1 = 0L, contraint = 0L, stats2 = 0L, restreint = 0L)
  engine_sous_graine(graine, {
    stats_obs_m <- .mc_evaluer(cat_m, e_obs)
    for (b in seq_len(B)) {
      yb <- usp_simuler(fit)
      f1 <- try(usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
      if (inherits(f1, "try-error")) { n_ech[["rapide"]] <- n_ech[["rapide"]] + 1L; next }
      e1 <- .usp_contexte_mc(fit$x, yb, f1$z, f1$pi)
      stm <- try(.mc_evaluer(cat_m, e1), silent = TRUE)
      f2 <- NULL
      if (!inherits(stm, "try-error")) {
        # Chemin du moteur : replication retenue, bootstrap restreint.
        simm[b, ] <- stm[nm]
        zb[b, ] <- f1$z; sm[b] <- f1$sigma; dm[b] <- f1$delta; gm[b] <- f1$gamma
        f2 <- try(usp_ajuster_contraint(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
        if (inherits(f2, "try-error")) n_ech[["restreint"]] <- n_ech[["restreint"]] + 1L else s_r[b] <- f2$sigma
        st <- stm[ns]
      } else st <- if (complet) proteger(try(.mc_evaluer(cat_, e1), silent = TRUE)) else stm
      if (inherits(st, "try-error")) { n_ech[["stats1"]] <- n_ech[["stats1"]] + 1L; next }
      # Variante 1 (sous-catalogue).
      sim1[b, ] <- st[ns]; ok1[b] <- TRUE; d1[b] <- f1$delta
      # Variante 2, sur la meme replication retenue.
      if (is.null(f2)) f2 <- proteger(try(usp_ajuster_contraint(fit$x, yb, fit$delta, fit$gamma), silent = TRUE))
      if (inherits(f2, "try-error")) { n_ech[["contraint"]] <- n_ech[["contraint"]] + 1L; next }
      s2 <- proteger(try(.mc_evaluer(cat_, .usp_contexte_mc(fit$x, yb, f2$z, f2$pi)), silent = TRUE))
      if (inherits(s2, "try-error")) { n_ech[["stats2"]] <- n_ech[["stats2"]] + 1L; next }
      sim2[b, ] <- s2[ns]; ok2[b] <- TRUE
    }
  })
  stats_obs <- stats_obs_m[ns]
  r_obs <- code_regime(fit$delta)
  rd <- vapply(d1, function(d) if (is.finite(d)) code_regime(d) else NA_character_, "")
  garde3 <- ok1 & !is.na(rd) & rd == r_obs
  list(noms = ns, stats_obs = stats_obs,
       mc = list("1" = .mc_p_values(sim1, stats_obs, cat_, e_obs),
                 "2" = .mc_p_values(sim2, stats_obs, cat_, e_obs),
                 "3" = .mc_p_values(sim1[garde3, , drop = FALSE], stats_obs, cat_, e_obs)),
       # Chemin du moteur sur le catalogue complet (controles (i1) et (i2)).
       moteur = if (complet) list(noms = nm, stats_obs = stats_obs_m, mc = .mc_p_values(simm, stats_obs_m, cat_m, e_obs),
                                  boot = list(sigma_boot = sm[is.finite(sm)], delta_boot = dm[is.finite(dm)],
                                              gamma_boot = gm[is.finite(gm)], sigma_boot_restreint = s_r[is.finite(s_r)],
                                              n_echec_restreint = n_ech[["restreint"]], z_boot = zb)),
       n_ech = n_ech, ok1 = ok1, ok2 = ok2,
       dd = c(bord0 = sum(rd[ok1] == "bord0"), bord1 = sum(rd[ok1] == "bord1"), interieur = sum(rd[ok1] == "interieur")),
       coherence = all(vapply(intersect(STATS_SANS_AJUSTEMENT, ns), function(s)
         identical(sim1[ok1 & ok2, s], sim2[ok1 & ok2, s]), logical(1))))
}
# (i2) : identical() avec usp_bootstrap() (chemin du moteur, catalogue
# complet ; rejeu en mode complet).
controle_i2 <- function(rj, fit, graine) {
  ub <- usp_bootstrap(fit, B = B_BOOT, seed = graine)
  mo <- rj$moteur; m1 <- mo$mc
  ch <- c(stats_obs = identical(as.list(mo$stats_obs), ub$stats_obs), p_mc = identical(m1$p_mc, ub$p_mc),
          err_mc = identical(m1$err_mc, ub$err_mc), B_effectif = identical(m1$B_effectif, ub$B_effectif),
          granularite_stat = identical(m1$granularite, ub$granularite_stat), motif_mc = identical(m1$motif_mc, ub$motif_mc),
          vapply(c("sigma_boot", "delta_boot", "gamma_boot", "sigma_boot_restreint", "n_echec_restreint", "z_boot"),
                 function(k) identical(mo$boot[[k]], ub[[k]]), logical(1)))
  names(ch)[!ch]
}
# Ligne REP / OBS (champs) d'une replication rejouee.
champs_rejeu <- function(b, regime, statut, delta, mode, i1, rj, noms) {
  fx <- c(b, regime, statut, sprintf("%.17g", delta), mode, i1,
          sprintf("%.0f", rj$n_ech[c("rapide", "stats1", "contraint", "stats2")]), sprintf("%.0f", rj$dd))
  st <- unlist(lapply(STATS_175, function(s) {
    if (!s %in% noms) return(c(rep("NA", 6), rep("-", 3)))
    v <- lapply(names(VARIANTES), function(k) rj$mc[[k]])
    c(vapply(v, function(m) sprintf("%.17g", m$p_mc[[s]]), ""), vapply(v, function(m) sprintf("%.17g", m$B_effectif[[s]]), ""),
      vapply(v, function(m) { x <- m$motif_mc[[s]]; if (is.na(x)) "NA" else nettoyer_champ(x) }, ""))
  }))
  c(fx, st)
}
champs_vides <- function(b, regime, statut, delta)
  c(b, regime, statut, sprintf("%.17g", delta), "-", "-", rep("NA", 7), rep(c(rep("NA", 6), rep("-", 3)), length(STATS_175)))

# --- Jeu observe (T3) : catalogue complet, (i2) ; J1 : p_mc de run_engine() ----
R_OBS <- rejouer(FIT0, GRAINE_BOOT, STATS_175, complet = TRUE)
e_obs_i2 <- controle_i2(R_OBS, FIT0, GRAINE_BOOT)
if (OPT_JEU == "J1" && !identical(R_OBS$moteur$mc$p_mc, RES_A$bootstrap$p_mc)) e_obs_i2 <- c(e_obs_i2, "p_mc de run_engine() (a)")
controle(!length(e_obs_i2), sprintf("(i2) %s observ\u00e9 : rejeu identique (identical()) \u00e0 usp_bootstrap(seed = %.0f)%s%s", OPT_JEU, GRAINE_BOOT,
                                    if (OPT_JEU == "J1") " et aux p_mc de run_engine() du contr\u00f4le (a)" else "",
                                    if (length(e_obs_i2)) paste0(" ; diff\u00e9rences : ", paste(e_obs_i2, collapse = ", ")) else ""))
controle(identical(R_OBS$moteur$noms, names(USP_CATALOGUE_MC)) && identical(names(R_OBS$moteur$mc$p_mc), names(USP_CATALOGUE_MC)) &&
           identical(R_OBS$noms, STATS_175) &&
           all(vapply(R_OBS$mc, function(m) identical(names(m$p_mc), STATS_175), logical(1))),
         paste("(b) jeu observ\u00e9 : noms des p du chemin du moteur = catalogue, ceux des trois variantes = les onze",
               "statistiques du p\u00e9rim\u00e8tre, dans l'ordre du catalogue"))
OBS <- champs_rejeu(0L, code_regime(FIT0$delta), "observe", FIT0$delta, "complet", "-", R_OBS, STATS_175)
t_controle <- as.numeric(difftime(Sys.time(), t_c, units = "secs"))

# --- Replications --------------------------------------------------------------------
REP <- list()
ech <- list(c = integer(0), i1 = integer(0), i2 = integer(0), b = integer(0), d = integer(0), coh = integer(0))
DUREE <- c(ctrl = t_controle, int_s = 0, int_n = 0, b0_s = 0, b0_n = 0, b1_s = 0, b1_n = 0, aut_s = 0, aut_n = 0)
premier_rejoue <- TRUE; premier_interieur <- TRUE
TXT_I2 <- character(0)
TXT_I1 <- character(0)
for (b in seq.int(DEBUT, FIN)) {
  t_b <- Sys.time()
  y <- YSIM[b, ]
  fit <- tryCatch(usp_ajuster(X, y), error = function(e) e)
  va <- if (inherits(fit, "error")) list(ok = FALSE) else usp_valider_ajustement(fit, METHODE)
  reg <- if (!isTRUE(va$ok)) "ecartee" else code_regime(fit$delta)
  dlt <- if (inherits(fit, "error")) NA_real_ else fit$delta
  if (!identical(reg, unname(BRUT221[b, "regime"]))) ech$c <- c(ech$c, b)
  if (!reg %in% names(PER)) {
    REP[[length(REP) + 1L]] <- champs_vides(b, reg, if (reg == "ecartee") "ecartee" else "non rejouee", dlt)
    DUREE[c("aut_s", "aut_n")] <- DUREE[c("aut_s", "aut_n")] + c(as.numeric(difftime(Sys.time(), t_b, units = "secs")), 1)
    next
  }
  noms <- PER[[reg]]
  # (i2) : premiere replication rejouee de la tranche et premiere
  # replication interieure (si ce n'est pas la meme).
  complet <- premier_rejoue || (reg == "interieur" && premier_interieur)
  premier_rejoue <- FALSE
  if (reg == "interieur") premier_interieur <- FALSE
  rj <- rejouer(fit, GRAINE_BOOT + b, noms, complet = complet)
  if (complet) {
    e2 <- controle_i2(rj, fit, GRAINE_BOOT + b)
    TXT_I2 <- c(TXT_I2, sprintf("r\u00e9plication %d (%s)", b, reg))
    if (length(e2)) ech$i2 <- c(ech$i2, b)
  }
  # (b) noms des p de chaque variante = sous-catalogue ; chemin du moteur
  # en mode complet = catalogue.
  att <- names(USP_CATALOGUE_MC)[names(USP_CATALOGUE_MC) %in% noms]
  if (!all(vapply(rj$mc, function(m) identical(names(m$p_mc), att) && identical(names(m$motif_mc), att), logical(1))) ||
      (complet && !identical(names(rj$moteur$mc$p_mc), names(USP_CATALOGUE_MC))))
    ech$b <- c(ech$b, b)
  # (i1) p moteur = p_mc des valeurs brutes de #221, au bit pres : variante 1
  # (sous-catalogue) et, en mode complet, chemin du moteur (catalogue).
  diff_i1 <- function(q, p) {
    p221 <- suppressWarnings(as.numeric(BRUT221[b, paste0("p_mc:", q)]))
    q[!mapply(identical, p221, unname(p[q]))]
  }
  d_i1 <- diff_i1(rj$noms, rj$mc[["1"]]$p_mc)
  if (complet) d_i1 <- union(d_i1, diff_i1(rj$moteur$noms, rj$moteur$mc$p_mc))
  i1 <- !length(d_i1)
  if (!i1) {
    ech$i1 <- c(ech$i1, b)
    TXT_I1 <- c(TXT_I1, sprintf("%d (%s)", b, paste(d_i1, collapse = ", ")))
  }
  # (d) echecs comptes ; invariants (variante 2 sur les replications
  # retenues par la variante 1).
  ret1 <- B_BOOT - rj$n_ech[["rapide"]] - rj$n_ech[["stats1"]]
  ret2 <- ret1 - rj$n_ech[["contraint"]] - rj$n_ech[["stats2"]]
  if (sum(rj$ok1) != ret1 || sum(rj$dd) != ret1 || sum(rj$ok2) != ret2 || any(rj$ok2 & !rj$ok1) ||
      any(rj$mc[["1"]]$B_effectif > ret1) || any(rj$mc[["2"]]$B_effectif > ret2) ||
      any(rj$mc[["3"]]$B_effectif > rj$dd[[reg]]))
    ech$d <- c(ech$d, b)
  if (!rj$coherence) ech$coh <- c(ech$coh, b)
  REP[[length(REP) + 1L]] <- champs_rejeu(b, reg, "rejouee", dlt, if (complet) "complet" else "sous-catalogue",
                                          if (i1) "OK" else "ECHEC", rj, noms)
  k <- switch(reg, interieur = c("int_s", "int_n"), bord0 = c("b0_s", "b0_n"), bord1 = c("b1_s", "b1_n"))
  DUREE[k] <- DUREE[k] + c(as.numeric(difftime(Sys.time(), t_b, units = "secs")), 1)
}
n_rj <- sum(vapply(REP, function(x) x[3] == "rejouee", logical(1)))
controle(!length(ech$c), sprintf("(c) r\u00e9gime de \u03b4\u0302*_b (ou r\u00e9plication \u00e9cart\u00e9e) identique \u00e0 celui des valeurs brutes de #221, \u00e0 chaque r\u00e9plication %d..%d%s",
                                 DEBUT, FIN, liste_b(ech$c)))
controle(!length(ech$i1), sprintf("(i1) p moteur rejou\u00e9e (variante 1, sous-catalogue ; chemin du moteur, catalogue complet, sur les r\u00e9plications du contr\u00f4le (i2)) = p_mc des valeurs brutes de #221 au bit pr\u00e8s (identical()), %d r\u00e9plication(s) rejou\u00e9e(s)%s",
                                  n_rj, if (length(TXT_I1)) paste0(" ; diff\u00e9rences (r\u00e9plication, statistiques) : ",
                                                                   paste(utils::head(TXT_I1, 20), collapse = " ; ")) else ""))
controle(!length(ech$i2), sprintf("(i2) rejeu identique (identical()) \u00e0 usp_bootstrap(), catalogue complet (premi\u00e8re r\u00e9plication rejou\u00e9e et premi\u00e8re r\u00e9plication int\u00e9rieure de la tranche) : %s%s",
                                  if (length(TXT_I2)) paste(TXT_I2, collapse = ", ") else "aucune r\u00e9plication rejou\u00e9e dans la tranche",
                                  liste_b(ech$i2)))
controle(!length(ech$b), sprintf("(b) noms des p des trois variantes = sous-catalogue du r\u00e9gime, dans l'ordre du catalogue, \u00e0 chaque r\u00e9plication rejou\u00e9e ; chemin du moteur = catalogue sur les r\u00e9plications du contr\u00f4le (i2)%s",
                                 liste_b(ech$b)))
controle(!length(ech$d), sprintf("(d) \u00e9checs des deux r\u00e9ajustements et des statistiques compt\u00e9s ; retenues de la variante 1 = B \u2212 \u00e9checs (rapide, statistiques (1)) ; retenues de la variante 2 = retenues de la variante 1 \u2212 \u00e9checs (contraint, statistiques (2)), contenues dans celles-ci ; B effectifs born\u00e9s par les retenues%s",
                                 liste_b(ech$d)))
controle(!length(ech$coh), sprintf("Coh\u00e9rence : valeurs simul\u00e9es de %s identiques entre les variantes 1 et 2 (r\u00e9plications internes retenues par les deux)%s",
                                   paste(STATS_SANS_AJUSTEMENT, collapse = " et "), liste_b(ech$coh)))

# --- Sortie ------------------------------------------------------------------------------
PAR <- sprintf("jeu=%s;R=%d;graine_jeux=%.0f;graine_boot=%.0f;B=%d;methode=%s;segment=%d;annexe=%s;nature=%s;alpha=%g;theta_equiv=%g",
               OPT_JEU, OPT_R, GRAINE_JEUX, GRAINE_BOOT, B_BOOT, METHODE, SEGMENT, ANNEXE, NATURE, ALPHA, THETA_EQUIV)
CTX <- c(
  jeu = JEU$libelle,
  modele = sprintf("\u03b4\u0302 = %.6g ; \u03b3\u0302 = %.6g ; \u03b2\u0302 = %.6g ; \u03c3\u0302 = %.6g", FIT0$delta, FIT0$gamma, FIT0$beta, FIT0$sigma),
  configuration = sprintf("m\u00e9thode %s, segment %d de l'annexe %s, donn\u00e9es %s, B = %d, \u03b1 = %g et %g ; B_MIN_DEGENERESCENCE = %d ; TOL_DELTA_BORD = %g",
                          METHODE, SEGMENT, ANNEXE, NATURE, B_BOOT, ALPHA, ALPHA2, B_MIN_DEGENERESCENCE, TOL_DELTA_BORD),
  perimetre = paste(vapply(names(PERIMETRE), function(j) sprintf("%s : %s", j, paste(vapply(names(PERIMETRE[[j]]), function(r)
    sprintf("%s (%s)", r, paste(PERIMETRE[[j]][[r]], collapse = ", ")), ""), collapse = " ; ")), ""), collapse = " | "),
  graines = sprintf("jeux simul\u00e9s : un flux sous %.0f (chemin de #72) ; bootstrap de la r\u00e9plication b : %.0f + b ; jeu observ\u00e9 : %.0f",
                    GRAINE_JEUX, GRAINE_BOOT, GRAINE_BOOT),
  collisions = COLLISIONS,
  generateur = paste(ENGINE_RNG_KIND, collapse = ", "),
  commit = COMMIT,
  plateforme = plateforme_calcul(),
  empreintes = EMPREINTES,
  reference = TXT_A,
  brut221_chemin = chemin_cite(F_BRUT221), brut221_md5 = md5_fichier(F_BRUT221), brut221_suivi = suivi_git(F_BRUT221),
  brut221_R = as.character(nrow(BRUT221)),
  tableau221_chemin = chemin_cite(F_TAB221), tableau221_md5 = md5_fichier(F_TAB221), tableau221_suivi = suivi_git(F_TAB221),
  i3 = I3$texte)
stopifnot(identical(names(CTX), CLES_CONTEXTE))
DL <- stats::setNames(list(en_table(REP)), OPT_JEU)
OL <- stats::setNames(list(en_table(list(OBS))), OPT_JEU)
S <- c(sprintf("## Conservatisme des p-values Monte-Carlo au r\u00e9gime \u03b4\u0302 int\u00e9rieur, T = 8, jeu %s (issue #175)", OPT_JEU), "",
       sprintf("Param\u00e8tres : %s", PAR), "",
       "### T0 -- provenance", "",
       entete_md(c("Grandeur", "Valeur")),
       vapply(CLES_CONTEXTE, function(k) ligne_md(LIBELLES_CONTEXTE[[k]], CTX[[k]]), ""),
       ligne_md("R\u00e9plications", sprintf("%d (trait\u00e9es ici : %d \u00e0 %d ; rejou\u00e9es : %d)", OPT_R, DEBUT, FIN, n_rj)),
       ligne_md("Dur\u00e9e", paste(texte_duree(DUREE), sprintf("; total %.0f s", as.numeric(difftime(Sys.time(), t_debut, units = "secs"))))),
       ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", if (length(INTEGRITE)) "\u00c9CHEC" else "OK"), "")
if (!is.na(OPT_TRANCHE)) S <- c(S, "Tableaux PARTIELS (une tranche) : combiner les sorties des K tranches par --combiner.", "")
S <- c(S, aide_lecture(), evaluer_critere(DL),
       tableau_t1(DL, ALPHA, TITRE_T1),
       tableau_t1(DL, ALPHA2, TITRE_T1B),
       tableau_t2(DL), tableau_t3(OL),
       "### Contr\u00f4les d'int\u00e9grit\u00e9", "", paste("-", CONTROLES), "",
       sprintf("Bilan : %s", if (length(INTEGRITE)) sprintf("\u00c9CHEC (%d contr\u00f4le(s))", length(INTEGRITE)) else "OK"), "")
ecrire_console(S)
ecrire_console(c(paste0("PARAMETRES\t", PAR), sprintf("TRANCHE\t%d\t%d", DEBUT, FIN),
                 sprintf("CONTEXTE\t%s\t%s", names(CTX), vapply(CTX, nettoyer_champ, "")),
                 paste0("STATS\t", paste(sprintf("%s=%s", STATS_175, vapply(STATS_175, function(s) USP_CATALOGUE_MC[[s]]$queue, "")),
                                         collapse = "\t")),
                 paste0("REPCOLS\t", paste(REPCOLS, collapse = "\t")),
                 paste0("OBS\t", paste(OBS, collapse = "\t")),
                 paste0("DUREE\t", paste(sprintf("%.3f", DUREE), collapse = "\t")),
                 paste0("INTEGRITE\t", if (length(INTEGRITE)) "ECHEC" else "OK"),
                 sprintf("NREP\t%d", length(REP)),
                 vapply(REP, function(x) paste0("REP\t", paste(x, collapse = "\t")), ""),
                 sprintf("FIN\t%d", length(REP))))
quit(status = if (length(INTEGRITE)) 1L else 0L)
