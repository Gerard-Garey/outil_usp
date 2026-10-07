###############################################################################
#  tests/calibration_mc_t8.R  --  CALIBRATION DES P-VALUES MONTE-CARLO A T = 8
#  SOUS LE MODELE AJUSTE, SUR LE MOTEUR ACTUEL (issue #166)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils::sessionInfo() et utils::combn() ; tools::md5sum()
#  pour les empreintes du code ; utils et tools sont livres avec R).
#  Sortie en markdown sur la console (UTF-8) ; fichiers ecrits SEULEMENT par
#  --combiner, sur option explicite (--ecrire, --sortie, --brut), et
#  seulement si la combinaison est acceptee.
#
#  Protocole : celui d'actuary (issue #122, commentaire 5905003573, preambule
#  (a') d'E1c) avec les decisions du mainteneur du 30/09/2026 (#122,
#  commentaire 5905011303 : Q1, aucun levier ; R = 2 000, B = 999,
#  run_engine() complet, J1 et J2) ; mesure rattachee a l'issue #166 par la
#  decision du mainteneur du 30/09/2026 (#122, commentaire 5905135878) ;
#  reponses d'actuary du 30/09/2026 aux questions de coder (references des
#  lois discretes, denominateur de T2, bande de Bradley, lignes sans niveau,
#  ligne ESD, controle (e4), valeurs brutes).
#
#  Statut des valeurs : CONSTAT DE SIMULATION SOUS DEUX MODELES AJUSTES, pas
#  un resultat general. La mesure porte sur le niveau reel de la procedure du
#  dossier quand le modele reglementaire est vrai, a T = 8 : usp_ajuster(),
#  usp_bootstrap() a B = 999, engine_p_mc(), verdict de add(). "Compatible"
#  signifie "aucune distorsion detectee a la precision Monte-Carlo", jamais
#  "exact". La lecture en trois etats (compatible, ecart mineur, distorsion
#  materielle) revient a actuary.
#
#  Cadre : T = 8, alpha = 0,10 ; configuration de #72 (methode prime,
#  segment 1 de l'annexe II, donnees brutes, theta_equiv = 0,10) ; jeux
#    J1 : tests/donnees/donnees_ln.csv (delta chapeau = 1, pi chapeau
#         constant) ;
#    J2 : xi, yi de tests/unitaires/test_controles_numeriques.R (delta
#         chapeau = 0,664, pi chapeau variable) ;
#  generateur des R jeux : usp_simuler(FIT0), FIT0 = usp_ajuster() sur le jeu
#  observe (generateur du bootstrap parametrique). Chaque replication b est
#  traitee par run_engine() COMPLET (B = 999, graine GRAINE_BOOT + b) : aucune
#  reconstruction, aucune transcription.
#
#  Tableaux (lus sur engine_table_tests() et res$bootstrap) :
#    T1     : les 34 statistiques de USP_CATALOGUE_MC ; frequence de
#             p_mc < 0,10 et de p_mc < 0,05, que la p_mc soit retenue ou non,
#             parmi les replications ou elle est calculee ;
#    T1 bis : la meme mesure par regime de delta chapeau* du reajustement
#             (bord 1 : pi chapeau* constant ; bord 0 ; interieur) ;
#    T2     : niveau des verdicts des 51 lignes : frequence de p retenue
#             < alpha et < alpha/2 parmi les replications ou la ligne a une p
#             retenue (niveau conditionnel ; regles R1, R3, R4, R7 et R13
#             comprises) ; ligne ESD (procedure de decision sans p-value) :
#             frequence de ALERTE ou ECHEC et de ECHEC sur les replications
#             traitees ; puis composition (types, natures de la p retenue,
#             verdicts : frequence inconditionnelle des verdicts) ;
#    T3     : effectifs par regime (run_engine() et code de #72),
#             replications ecartees et leur motif, motif_mc, controles de la
#             famille H, p_mc des deux lignes du rapport de vraisemblance
#             (#45, hors objet de T1 et T2 : elles ne figurent qu'ici) ; une
#             replication dont le rapport de vraisemblance n'est pas
#             calculable sur ses donnees observees (y*) a une borne est
#             traitee, LR non applicable, et non plus ecartee (#161) : comptee
#             a part par borne (cle lrnc|borne), hors motifs Monte-Carlo du
#             LR et hors replications internes ecartees,
#             largeur de l'IC bootstrap (controle (e4)), replications internes
#             du bootstrap ecartees.
#  Incertitude : intervalle de Clopper-Pearson a 95 % (stats::binom.test()),
#  incertitude Monte-Carlo sur le taux, fonction de R ; elle ne dit rien de
#  l'erreur d'approximation en T. L'erreur liee a B fait partie de la
#  procedure mesuree.
#  References (reponses d'actuary du 30/09/2026) :
#    - statistique continue : le seuil (0,10 ; 0,05) ; sous echangeabilite,
#      P(p_mc < a) vaut en fait (ceil(a(B+1)) - 1)/(B+1) = 0,099 et 0,049 en
#      queue simple, 2 (ceil(a(B+1)/2) - 1)/(B+1) = 0,098 et 0,048 en
#      bilateral (niveau_mc_continu()), ecart negligeable devant l'IC ;
#    - loi de reference discrete (suites, Mann-Kendall, Smirnov, Spearman,
#      Cox-Stuart), par lois_discretes(), enumeration a T = 8 sans ex aequo
#      avec les fonctions du moteur (statistiques du catalogue, p exactes des
#      lignes) : taille ATTEIGNABLE P(p exacte < a) et taille LISSEE
#      P(p_mc < a) a B = 999, calculee exactement :
#        sens "deux" : P(Bin(B, pi_hi) <= c_a) + P(Bin(B, pi_lo) <= c_a),
#                      c_a = ceil(a(B+1)/2) - 2 (48 et 23) ;
#        sens "haut" : P(Bin(B, pi_hi) <= c'_a), c'_a = ceil(a(B+1)) - 2
#                      (98 et 48) ;
#      pi_hi(r) = P(S* >= r), pi_lo(r) = P(S* <= r), moyennes sur les atomes
#      de la loi echangeable ; inegalite stricte de add() ; sens lu dans
#      USP_CATALOGUE_MC. T1 et T1 bis : taille lissee. T2 : melange
#      (n_ex s_att + n_mc s_MC) / (n_ex + n_mc) sur les comptes de natures
#      de la ligne, reference APPROCHEE (echangeabilite, selection par le
#      regime) ; une p retenue d'une autre nature (repli asymptotique nomme,
#      regle R3 : attendu 0 a T = 8 sans ex aequo) compte dans np et dans les
#      rejets, non dans la reference, alors suivie de "(n hors ref. = k)" ;
#    - lignes sans niveau : test de Pitman sur la pente (H0
#      d'echangeabilite, y independant de x, fausse sous le modele
#      reglementaire a volumes variables, #169), TOST (H0 |a| >= Delta fausse
#      sous le modele ajuste, a = 0) : sens "rejeter", pas de reference ; la
#      ligne Fisher, diagnostic sans p retenue depuis #169, tombe dans
#      "sans objet (aucune p retenue)" ;
#    - ligne ESD : ALERTE ou ECHEC (k chapeau >= 1) contre 0,10, niveau
#      nominal de la procedure de Rosner (valeurs critiques a 1 - alpha/(2
#      n_i)), exactitude non etablie a T = 8 ; ECHEC (k chapeau = 2) sans
#      reference.
#  Aide a la lecture, sans conclure : pour chaque IC, reference dans l'IC
#  (oui / non) et position par rapport a la bande liberale de Bradley (1978),
#  [ref/2 ; 3 ref/2] ([0,05 ; 0,15] a 0,10, [0,025 ; 0,075] a 0,05 : le
#  rapport 0,5-1,5 est celui de Bradley a tout seuil ; pour une reference
#  discrete, transposition en rapport a la taille de reference, convention du
#  script) : convention, pas theoreme. Regle de lecture() (actuary,
#  30/09/2026) : la bande n'est ecrite que si la reference est hors de l'IC ;
#  elle est "non applicable" si la reference est inferieure a 2/n (n :
#  denominateur du taux, np en T2), sa demi-largeur etant alors sous la
#  resolution 1/n du taux ; une reference nulle n'est pas ramenee a {0}.
#  Multiplicite : 136 intervalles en T1 sur J1 et J2 (34 statistiques x 2
#  seuils x 2 jeux), environ 7 exclusions attendues par hasard.
#
#  Controles d'integrite (code de sortie 1 si l'un echoue) :
#    (a)  J1 observe par run_engine(seed = 20260831) (executer_cas("premium")
#         de tests/outils_tests.R) conforme a tests/reference/premium.rds par
#         comparer_objets(), apres neutraliser_instables() (meme comparaison
#         que tests/test_reproductibilite.R) ;
#    (b)  les noms de res$bootstrap$p_mc et de res$bootstrap$motif_mc sont
#         exactement les 34 de USP_CATALOGUE_MC, dans son ordre, a chaque
#         replication ; toute p_mc absente porte un motif ;
#    (c)  51 lignes par replication, de memes libelles et dans le meme ordre
#         que sur J1 observe (libelles distincts). Critere strict : le
#         jackknife (deterministe) et l'IC bootstrap (graine 20260831 + b) de
#         chaque replication sont ceux de #72, dont les tableaux les
#         restituent 2 000 fois sur 2 000 ; l'IC a delta fixe, hors perimetre
#         de #72, en depend aussi. Si les graines changeaient, (c) devrait
#         tolerer l'absence de ces trois lignes conditionnelles et les lister
#         en T3 ;
#    (d)  toute replication ecartee (erreur de run_engine() ou ok = FALSE) est
#         listee en T3 avec son motif (motif non vide) ;
#    (e)  replications identiques a celles de #72
#         (tests/taux_franchissement_reperes.R, tableaux regeneres
#         docs/tableaux/20260930-issue122-J1.md et -J2.md) :
#         (e1) a chaque replication, delta chapeau* de run_engine() identique
#              (identical()) a celui du code de #72, usp_ajuster(x, y*), et
#              regime par les memes seuils (bord 0 : delta <= TOL_DELTA_BORD ;
#              bord 1 : delta >= 1 - TOL_DELTA_BORD) ;
#         (e2) les R jeux simules identiques (identical()) a ceux qu'evalue
#              l'expression d'affectation de YSIM du script de #72, lue par
#              parse() (sans executer ce script) : ses noms (all.names())
#              doivent appartenir a une liste blanche (NOMS_E2), et elle est
#              evaluee dans un environnement qui ne contient que ces liaisons
#              (parent emptyenv()), avec les memes graine, R et FIT0 ;
#         (e3) et (e4) a R = 2 000 et graine des jeux 20260927 (execution d'un
#              seul tenant ou --combiner) : (e3) effectifs de delta chapeau*
#              au bord 0 et au bord 1 par le code de #72, (e4) effectifs de la
#              largeur relative de l'IC bootstrap 90 % au-dessus de 0,50 et de
#              0,80 (ligne "Largeur relative de l'IC bootstrap 90%"), egaux a
#              ceux du tableau de #72 du meme jeu ; a R = 2 000, un tableau de
#              #72 absent, illisible ou d'un autre jeu, R ou graine est un
#              echec ; non applicables a un autre R (dit dans la sortie) ;
#    (f)  references ancrees au moteur : sur J1 observe (pi chapeau constant,
#         p exactes attribuees), la p exacte de chacune des sept lignes a loi
#         discrete appartient a l'ensemble des p des atomes enumeres par
#         lois_discretes() (a 1e-9 pres) ; tailles des suites : atteignable
#         4/70 et 0, lissee 0,05713 et 0,00968 (a 5e-6 pres) ;
#  plus des controles de coherence du script : 34 statistiques au catalogue ;
#  correspondance statistique -> ligne (STAT_LIGNE) verifiee sur J1 observe
#  (p_mc de la ligne identique a celle du bootstrap) ; lignes nommees par les
#  constantes presentes ; volumes du jeu non constants (pi chapeau* constant
#  si et seulement si delta chapeau* au bord 1) ; sigma_USP de T0 identique a
#  celui de run_engine() sur J1.
#
#  Alea : tout tirage passe par engine_sous_graine() (generateur
#  ENGINE_RNG_KIND). Les R jeux sont tires d'un seul flux sous GRAINE_JEUX =
#  20260927, avant tout calcul, par le chemin de code de #72 (controle (e2)) :
#  ils ne dependent pas du decoupage en tranches, et les jeux 1..R sont les R
#  premiers des 2 000 de #72. Le bootstrap (et le rapport de vraisemblance,
#  meme graine, #45) de la replication b est celui de run_engine(seed =
#  GRAINE_BOOT + b), GRAINE_BOOT = 20260831 (graine de l'IC de #72) ; J1
#  observe, controle (a) : graine 20260831 (b = 0). Graines imposees par le
#  protocole et conservees (reponse d'actuary du 30/09/2026) ; GARDE DE
#  COLLISION non bloquante, contrairement a tests/puissance_t8.R : a R >= 96,
#  la graine du bootstrap de la replication 96 est GRAINE_JEUX (son bootstrap
#  reutilise les normales du flux des jeux, dont celles de son propre jeu en
#  replication interne 96) ; a R >= 70, celle de la replication 70 est
#  SEED_LOI_NULLE_SW (loi nulle de Shapiro-Wilk du moteur). Les collisions et
#  leur effet borne sont declares en T0 (contexte, donc controle de
#  --combiner) ; leur effet n'est pas corrige.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/calibration_mc_t8.R [--jeu J1|J2] [--R 2000] [--tranche i/K]
#      Rscript tests/calibration_mc_t8.R --combiner f1 f2 ... [--ecrire [--remplacer] | --sortie DOSSIER]
#          [--brut FICHIER]
#  Pas d'option de B ni de graine : B = 999 et les graines sont celles du
#  protocole (decision Q1 : aucun levier).
#  --tranche i/K : ne traite que la i-eme de K tranches de replications
#  consecutives. Chaque execution (tranche ou non) imprime T0, les tableaux
#  (PARTIELS pour une tranche), les controles, puis des lignes machine :
#  PARAMETRES, TRANCHE, CONTEXTE (contenu de T0 hors durees et hors bornes de
#  la tranche, dont la plateforme de calcul et les empreintes md5 du code),
#  STATS, LIGNES, REPCOLS (colonnes des lignes REP), DUREE, INTEGRITE (OK ou
#  ECHEC), NCOMPTES, les comptes bruts (COMPTE), NREP, une ligne REP par
#  replication (b, regime ou "ecartee", 34 p_mc dans l'ordre de STATS, 51 p
#  retenues dans l'ordre de LIGNES ; NA si absente) et, en derniere ligne,
#  FIN (nombre de COMPTE). Rediriger la sortie de chaque tranche vers un
#  fichier HORS du depot, puis --combiner additionne les comptes et imprime
#  T0 et les tableaux complets, identiques a ceux d'une execution d'un seul
#  tenant (seules les lignes de duree et de commit different). --combiner
#  refuse (code de sortie 1, sans tableau) : une tranche sans ligne
#  INTEGRITE ou en ECHEC ; une sortie incomplete (FIN absente ou pas en
#  derniere ligne, nombre de COMPTE different de NCOMPTES ou de FIN, nombre de
#  REP different de NREP : troncature) ; une cle COMPTE en double ; des
#  PARAMETRES, un CONTEXTE (plateforme, BLAS, LAPACK, #171 ; empreintes md5
#  de R/engine.R, de tests/outils_tests.R charge, du script execute et de
#  tests/taux_franchissement_reperes.R), des STATS, des LIGNES ou des REPCOLS
#  differents entre tranches ; des tailles des lois discretes differentes de
#  celles qu'il recalcule ; des tranches qui ne couvrent pas 1..R exactement
#  une fois ; un invariant du corps d'une tranche faux (invariants_tranche() :
#  rep = fin - debut + 1, ok + ecartees = rep, somme des reg = ok, somme des
#  reg72 = rep, l|ligne|n = ok pour les 51 lignes, n + absentes = ok pour les
#  34 p_mc, lignes REP = rep, b des REP = debut..fin, regimes et ecartees des
#  REP = comptes, n, k1 et k2 des 34 p_mc (par regime) et des 51 p retenues
#  recomptes sur les lignes REP = comptes ; au total, somme des rep = R) ;
#  les controles (e3) ou (e4) en echec.
#  --ecrire (--combiner seulement) : ecrit
#  docs/tableaux/<AAAAMMJJ>-issue166-calibration-<jeu>.md, date du jour de la
#  combinaison ; REFUSE (code 1, rien d'ecrit) si le commit des tranches, ou
#  celui de la combinaison elle-meme, porte "(arbre de travail modifie)",
#  "(script non suivi)" ou "inconnu", ou si tests/outils_tests.R ou le script
#  executes (par les tranches ou par la combinaison) n'etaient pas ceux du
#  depot (empreintes : "hors depot" ; empreintes du combinateur imprimees en
#  T0). --sortie DOSSIER : meme nom dans DOSSIER, qui doit etre HORS du depot
#  (un dossier sous la racine du depot est refuse : --ecrire est le seul
#  chemin qui ecrit dans le depot) ; la ligne "Versionnable" de T0 dit si
#  --ecrire l'aurait accepte. Les fichiers de docs/tableaux/ sont regeneres,
#  jamais patches. Garde d'ecrasement (#173, garde_ecrasement() de
#  tests/outils_tests.R, evaluee apres les refus precedents et avant toute
#  ecriture, --brut compris) : --ecrire est REFUSE (code 1, rien d'ecrit) si
#  le fichier cible est suivi par git, ou existe sans que git puisse dire
#  s'il l'est ; --remplacer (avec --ecrire seulement, refus d'usage sinon)
#  autorise le remplacement d'un fichier suivi, et le T0 du fichier ecrit
#  cite alors le fichier remplace et son md5 d'avant.
#  --brut FICHIER (--combiner seulement) : ecrit les lignes REP combinees,
#  triees par b, sous l'en-tete REPCOLS (valeurs separees par des
#  tabulations), HORS du depot : un chemin sous la racine du depot est refuse
#  tant que le mainteneur n'a pas decide de versionner ces valeurs, et un
#  fichier existant n'est jamais ecrase (refus).
#  Commit : sortie de "git rev-parse HEAD", lue au debut du calcul (moteur
#  charge), suivie de "(arbre de travail modifie)" si "git status --porcelain
#  --untracked-files=no" n'est pas vide et de "(script non suivi)" si ce
#  script n'est pas versionne ; "inconnu" si git est indisponible.
#  Cout (conteneur Linux 4 coeurs, R 4.3.3, 30/09/2026) : 23,5 s par
#  replication (mesure de la session principale, citee par le brief de
#  #166) ; 15 a 16 s mesurees par replication, en sequentiel comme a trois
#  executions paralleles ; controle (a) et controles de coherence : 17 a
#  19 s (mesures du compte rendu de #166). Executions completes : R = 2 000
#  par jeu en tranches d'au plus ~250 replications (250 x 23,5 s = 98 min),
#  par exemple 8 tranches par jeu, 4 en parallele :
#      D=/chemin/hors/depot
#      for i in 1 2 3 4; do LC_ALL=C.UTF-8 Rscript tests/calibration_mc_t8.R \
#        --jeu J1 --tranche $i/8 > $D/J1-$i.txt & done; wait
#      for i in 5 6 7 8; do LC_ALL=C.UTF-8 Rscript tests/calibration_mc_t8.R \
#        --jeu J1 --tranche $i/8 > $D/J1-$i.txt & done; wait
#      LC_ALL=C.UTF-8 Rscript tests/calibration_mc_t8.R --combiner $D/J1-*.txt --ecrire \
#        --brut $D/J1-brut.tsv
#  Recette : --R 2 rend le code 0 en moins d'une minute (mesure du compte
#  rendu de #166 ; ligne Duree de T0).
#  Fonctions reprises par copie declaree (ces scripts executent leur calcul au
#  chargement et ne peuvent pas etre sources) :
#    - de tests/taux_franchissement_reperes.R : lire_option(), ligne_md(),
#      entete_md(), ecrire_console(), lire_j2() (copies) ; lire_comptes() et
#      refuser() (copies adaptees : lignes STATS, LIGNES, REPCOLS, DUREE, REP) ;
#      bornes d'une tranche et combinaison des comptes (copies) ;
#    - de tests/puissance_t8.R : git_depot() et commit_depot() (copies
#      adaptees : nom du script), num(), txt_ic() (copies), ic_cp() (copie,
#      niveau fixe a 95 %), analyse de --combiner suivie d'options et
#      ecrire_fichier() (copies adaptees : nom du fichier, refus de --ecrire ;
#      ecrire_fichier() est devenue ecrire_fichiers() dans tests/puissance_t8.R, #173),
#      tailles des suites, de Smirnov et de Mann-Kendall par enumeration
#      (reprises dans lois_discretes()).
#  plateforme_calcul() et empreintes_code() sont copiees (#171) dans
#  tests/taux_franchissement_reperes.R et tests/puissance_t8.R
#  (plateforme_calcul() aussi dans tests/constats_puissance_t8.R).
#  Code de sortie : 0 si les controles d'integrite tiennent, 1 sinon ; en
#  mode --combiner, 0 si la combinaison est acceptee, 1 si elle est refusee.
###############################################################################

t_debut <- Sys.time()

# --- Options (lire_option() : copie de tests/taux_franchissement_reperes.R) ---
ARGS <- commandArgs(trailingOnly = TRUE)
OPTIONS_APRES_COMBINER <- c("--ecrire", "--remplacer", "--sortie", "--brut")
i_comb <- match("--combiner", ARGS)
FICHIERS_COMB <- if (is.na(i_comb)) character(0) else {
  reste <- ARGS[-seq_len(i_comb)]
  # les options --ecrire, --remplacer, --sortie DOSSIER et --brut FICHIER peuvent suivre la liste
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
OPT_JEU     <- lire_option("--jeu", "J1")
OPT_R       <- suppressWarnings(as.integer(lire_option("--R", "2000")))
OPT_TRANCHE <- lire_option("--tranche", NA_character_)
OPT_ECRIRE  <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_SORTIE  <- lire_option("--sortie", NA_character_)
OPT_BRUT    <- lire_option("--brut", NA_character_)
if (!OPT_JEU %in% c("J1", "J2")) stop("--jeu : J1 ou J2")
if (!is.finite(OPT_R) || OPT_R < 1L) stop("--R : entier >= 1")
if (OPT_ECRIRE && !is.na(OPT_SORTIE)) stop("--ecrire et --sortie sont exclusifs")
if (OPT_REMPLACER && !OPT_ECRIRE) stop("--remplacer : reserve a --ecrire (remplacement d'un tableau suivi par git, #173)")
if ((OPT_ECRIRE || !is.na(OPT_SORTIE) || !is.na(OPT_BRUT)) && is.na(i_comb))
  stop("--ecrire, --sortie et --brut sont reserves a --combiner (tableaux produits par --combiner)")
if (!is.na(OPT_SORTIE) && !dir.exists(OPT_SORTIE)) stop("--sortie : dossier introuvable : ", OPT_SORTIE)

# --- Protocole (constantes ; aucune option : decision Q1, aucun levier) -------
METHODE <- "premium"; SEGMENT <- 1; ANNEXE <- "II"; NATURE <- "brutes"
ALPHA <- 0.10; ALPHA2 <- ALPHA / 2; THETA_EQUIV <- 0.10
SEUILS <- c(ALPHA, ALPHA2)
B_BOOT <- 999L
GRAINE_JEUX <- 20260927
GRAINE_BOOT <- 20260831
T_ <- 8L
N_STATS <- 34L
N_LIGNES <- 51L
SCRIPT_72 <- file.path("tests", "taux_franchissement_reperes.R")
TABLEAUX_72 <- c(J1 = "docs/tableaux/20260930-issue122-J1.md",
                 J2 = "docs/tableaux/20260930-issue122-J2.md")
R_72 <- 2000L                      # replications des tableaux de #72
# Liste blanche des noms de l'expression YSIM de #72 (controle (e2)) : ceux
# qu'elle contient (mesure : all.names() de l'expression du 30/09/2026) et
# les accolades et parentheses.
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

# --- Outils (copies declarees, voir l'en-tete) -----------------------------------
git_depot <- function(...) tryCatch(suppressWarnings(system2("git", c("-C", RACINE, ...), stdout = TRUE,
                                                             stderr = FALSE)),
                                    error = function(e) NULL)
# Commit du depot, complete de "(arbre de travail modifie)" et de "(script non
# suivi)" (definition de tests/puissance_t8.R).
commit_depot <- function() {
  h <- git_depot("rev-parse", "HEAD")
  if (length(h) != 1L || !grepl("^[0-9a-f]{40}$", h)) return("inconnu")
  if (length(git_depot("status", "--porcelain", "--untracked-files=no"))) h <- paste(h, "(arbre de travail modifi\u00e9)")
  suivi <- tryCatch(suppressWarnings(system2("git", c("-C", RACINE, "ls-files", "--error-unmatch",
                                                      "tests/calibration_mc_t8.R"),
                                             stdout = FALSE, stderr = FALSE)),
                    error = function(e) 1L)
  if (!identical(as.integer(suivi), 0L)) h <- paste(h, "(script non suivi)")
  h
}
# Plateforme de calcul (#171) : R, systeme, machine, BLAS, LAPACK. Champ du
# contexte : des tranches calculees sur des plateformes differentes ne se
# combinent pas (certains comptes dependent de l'optimiseur : regime de
# delta chapeau*, reajustements du bootstrap).
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(extSoftVersion()["BLAS"]), txt(La_library()), txt(La_version()))
}
# Empreintes md5 du code execute (constat F1 d'audit, #166 ; #171) : moteur
# du depot, tests/outils_tests.R effectivement charge (celui du dossier du
# script), script execute (chemin --file=) et, pour ce script seul,
# tests/taux_franchissement_reperes.R lu par (e2) ; "depot" ou "hors depot"
# selon que le fichier charge est celui du depot. Champ du contexte : un code
# different au meme commit (copie modifiee de outils_tests.R ou du moteur)
# change le contexte, et --combiner refuse.
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
# Motifs qui interdisent --ecrire (tableau versionne) : commit non propre ou
# code hors du depot ; quoi : "des tranches" ou "de la combinaison".
motifs_non_versionnable <- function(commit, empreintes, quoi = "des tranches") {
  m <- character(0)
  if (!grepl("^[0-9a-f]{40}$", commit))
    m <- c(m, sprintf("commit %s \u00ab %s \u00bb (arbre de travail modifi\u00e9, script non suivi ou git indisponible)", quoi, commit))
  if (grepl("hors d\u00e9p\u00f4t", empreintes, fixed = TRUE))
    m <- c(m, sprintf("tests/outils_tests.R ou script ex\u00e9cut\u00e9s %s hors du d\u00e9p\u00f4t", quoi))
  m
}
# Chemin (existant) sous la racine du depot (constat R2 d'audit) : --sortie et
# --brut doivent viser hors du depot ; --ecrire est le seul chemin qui ecrit
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
ecrire_console <- function(x) writeLines(enc2utf8(x), useBytes = TRUE)
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
num <- function(x, d = 3) if (is.na(x)) "\u2014" else sub(".", ",", sprintf(paste0("%.", d, "f"), x), fixed = TRUE)
ic_cp <- function(k, n) if (n > 0) {
  ci <- stats::binom.test(k, n)$conf.int
  c(ci[1], ci[2])
} else c(NA_real_, NA_real_)
txt_ic <- function(ci, d = 4) if (anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", num(ci[1], d), num(ci[2], d))
# Cle de compte sans separateur ni tabulation.
nettoyer_cle <- function(s) gsub("[|\t\r\n]+", " ", s)

# --- Correspondances et classements (constantes, controlees sur J1 observe) ---
# Statistique du catalogue -> ligne de usp_tests() qui lit sa p_mc (mc_nom).
STAT_LIGNE <- c(
  AD = "Anderson-Darling", CvM = "Cramer-von Mises", KS = "Kolmogorov-Smirnov contre N(0,1)",
  SW = "Shapiro-Wilk sur residus standardises", SF = "Shapiro-Francia", JB = "Jarque-Bera",
  DW = "Autocorrelation d'ordre 1 (Durbin-Watson)", LB1 = "Ljung-Box (retard 1)",
  supF = "Rupture de niveau (sup-F)", CUSUM = "Stabilite cumulee (OLS-CUSUM)",
  Grubbs = "Valeur aberrante isolee (Grubbs)", Lillie = "Lilliefors (KS a parametres estimes)",
  Intercept = "Nullite de la constante (proportionnalite stricte)", RESET = "RESET (forme fonctionnelle)",
  BP = "Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)",
  BP79 = "Heteroscedasticite vs volume - Breusch-Pagan original (non robuste)",
  White = "Heteroscedasticite (forme quadratique)", GQ = "Egalite des variances petits vs gros volumes",
  BF = "Homogeneite des dispersions (mediane)", Smirnov = "Egalite des lois petits vs gros volumes (2 ech.)",
  LB2 = "Ljung-Box (retard 2)", BP2 = "Box-Pierce (retard 2)", Runs = "Test des suites (aleatoire des signes)",
  MK = "Tendance monotone du ratio S/P", SpearVol = "Independance ratio S/P vs volume",
  SpearTps = "Correlation ratio S/P vs temps", DAgo = "Asymetrie (D'Agostino, T >= 8)",
  CoxStuart = "Tendance par signes du ratio S/P",
  DWr = "Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts",
  LB1r = "Ljung-Box (retard 1) sur ratios bruts", Runsr = "Test des suites sur ratios bruts",
  supFr = "Rupture de niveau (sup-F) sur ratios bruts",
  CUSUMr = "Stabilite cumulee (OLS-CUSUM) sur ratios bruts",
  Grubbsr = "Valeur aberrante isolee (Grubbs) sur ratios bruts")
# Statistiques a loi de reference discrete -> loi (references : tailles
# atteignable et lissee, lois_discretes()).
LOI_STAT <- c(Runs = "suites", Runsr = "suites", MK = "mk", Smirnov = "smirnov",
              SpearVol = "spearman", SpearTps = "spearman", CoxStuart = "coxstuart")
LOI_LIGNE <- stats::setNames(unname(LOI_STAT), unname(STAT_LIGNE[names(LOI_STAT)]))
LIB_LOI <- c(suites = "suites (Swed-Eisenhart, 4 et 4)", mk = "Mann-Kendall (loi mahonienne)",
             smirnov = "Smirnov (4 et 4)", spearman = "Spearman (loi de permutation)",
             coxstuart = "Cox-Stuart (Binomiale(4, 1/2))")
# Lignes sans niveau (sens "rejeter", H0 fausse sous le modele ajuste). La
# ligne Fisher, diagnostic sans sens ni p retenue depuis #169, n'y figure
# plus.
LIGNES_SANS_NIVEAU <- c(
  "Test de Pitman sur la pente (lien positif pertes / volume)" =
    "sans objet (H0 d'\u00e9changeabilit\u00e9, y ind\u00e9pendant de x, fausse sous le mod\u00e8le r\u00e9glementaire \u00e0 volumes variables ; sens \u00ab rejeter \u00bb)",
  "Equivalence de la constante a zero (TOST)" =
    "sans objet (H0 \\|a\\| \u2265 \u0394 fausse sous le mod\u00e8le ajust\u00e9, a = 0 ; sens \u00ab rejeter \u00bb)")
LIGNE_ESD <- "Valeurs aberrantes multiples (ESD generalise)"
LIGNE_IC  <- "Largeur relative de l'IC bootstrap 90%"
LIGNES_LR <- c(borne0 = "Rapport de vraisemblance : \u03b4 = 0", borne1 = "Rapport de vraisemblance : \u03b4 = 1")
REGIMES <- c(bord1 = "\u03b4\u0302* = 1 (\u03c0\u0302* constant)", bord0 = "\u03b4\u0302* = 0 (\u03c0\u0302* variable)",
             interieur = "\u03b4\u0302* int\u00e9rieur (\u03c0\u0302* variable)")
# Regime par les seuils de #72 (reperes bord0 et bord1 de
# tests/taux_franchissement_reperes.R).
code_regime <- function(delta) if (delta >= 1 - TOL_DELTA_BORD) "bord1" else
  if (delta <= TOL_DELTA_BORD) "bord0" else "interieur"

# --- Lois discretes : atomes, tailles atteignable et lissee (T = 8) ------------
# Enumeration des issues equiprobables sous la loi echangeable, sans ex
# aequo, avec les fonctions du moteur : statistique Monte-Carlo par la
# fonction calc du catalogue (ou une fonction strictement croissante de
# celle-ci, verifiee), p exacte par la fonction de la ligne. Chaque loi rend
# ses atomes (v : valeur, f : probabilite, pe : p exacte), le sens de rejet
# (lu au catalogue), la taille atteignable P(pe < a) et la taille lissee
# P(p_mc < a) a B = B_BOOT (formules de l'en-tete). Suites, Smirnov,
# Mann-Kendall : enumerations reprises de tests/puissance_t8.R.
niveau_mc_continu <- function(a, queue, B = B_BOOT)
  if (queue == "deux") 2 * (ceiling(round(a * (B + 1) / 2, 9)) - 1) / (B + 1) else
    (ceiling(round(a * (B + 1), 9)) - 1) / (B + 1)
lois_discretes <- function(n = T_, B = B_BOOT) {
  c_uni <- ceiling(round(SEUILS * (B + 1), 9)) - 2
  c_bil <- ceiling(round(SEUILS * (B + 1) / 2, 9)) - 2
  # Regroupe des issues equiprobables par valeur de la statistique ; la p
  # exacte doit etre la meme dans un atome.
  atomes <- function(v, pe) {
    u <- sort(unique(round(v, 9))); k <- match(round(v, 9), u)
    p <- vapply(seq_along(u), function(i) {
      x <- pe[k == i]
      if (diff(range(x)) > 1e-12) stop("lois_discretes() : p exacte non constante sur un atome")
      x[1]
    }, numeric(1))
    list(v = u, f = tabulate(k, length(u)) / length(v), pe = p)
  }
  completer <- function(at, stat) {
    queue <- USP_CATALOGUE_MC[[stat]]$queue
    hi <- vapply(at$v, function(r) sum(at$f[at$v >= r]), numeric(1))
    lo <- vapply(at$v, function(r) sum(at$f[at$v <= r]), numeric(1))
    at$queue <- queue
    at$atteignable <- vapply(SEUILS, function(s) sum(at$f[at$pe < s]), numeric(1))
    at$lissee <- vapply(seq_along(SEUILS), function(j) switch(queue,
      haut = sum(at$f * stats::pbinom(c_uni[j], B, hi)),
      bas  = sum(at$f * stats::pbinom(c_uni[j], B, lo)),
      deux = sum(at$f * (stats::pbinom(c_bil[j], B, hi) + stats::pbinom(c_bil[j], B, lo)))), numeric(1))
    at
  }
  cmb <- utils::combn(n, n / 2)
  # Suites : signes +-1 aux positions de cmb, plus un decalage infime (ni ex
  # aequo ni valeur a la mediane) ; statistique du catalogue Runs.
  sq <- lapply(seq_len(ncol(cmb)), function(j) { v <- rep(-1, n); v[cmb[, j]] <- 1; v + seq_len(n) * 1e-3 })
  suites <- completer(atomes(vapply(sq, function(v) USP_CATALOGUE_MC$Runs$calc(list(z = v)), numeric(1)),
                             vapply(sq, runs_p_exacte, numeric(1))), "Runs")
  # Smirnov : partitions (4, 4) des rangs, statistique D et p de ks.test()
  # (ceux du catalogue et de la ligne).
  ks <- lapply(seq_len(ncol(cmb)), function(j) {
    g <- seq_len(n) %in% cmb[, j]
    stats::ks.test(seq_len(n)[g], seq_len(n)[!g])
  })
  smirnov <- completer(atomes(vapply(ks, function(o) unname(o$statistic), numeric(1)),
                              vapply(ks, `[[`, numeric(1), "p.value")), "Smirnov")
  # Permutations de 1..n : Spearman (S = somme des d^2, statistique du
  # catalogue) et Mann-Kendall (S de Kendall ; statistique du catalogue Z,
  # strictement croissante en S, verifie).
  perms <- function(k) {
    if (k == 1L) return(matrix(1L, 1L, 1L))
    p <- perms(k - 1L)
    do.call(rbind, lapply(seq_len(k), function(i) cbind(i, p + (p >= i))))
  }
  P <- perms(n)
  S_sp <- rowSums((P - matrix(seq_len(n), nrow(P), n, byrow = TRUE))^2)
  S_mk <- Reduce(`+`, lapply(utils::combn(n, 2, simplify = FALSE), function(ij) sign(P[, ij[2]] - P[, ij[1]])))
  rep_de <- function(S) { u <- sort(unique(S)); list(u = u, i = match(u, S), i2 = length(S) + 1L - match(u, rev(S))) }
  r_sp <- rep_de(S_sp)
  p_sp <- function(i) suppressWarnings(stats::cor.test(P[i, ], seq_len(n), method = "spearman", exact = TRUE)$p.value)
  pe_sp <- vapply(r_sp$i, p_sp, numeric(1))
  if (!identical(pe_sp, vapply(r_sp$i2, p_sp, numeric(1)))) stop("lois_discretes() : p de Spearman non fonction de S seule")
  if (!isTRUE(all.equal(vapply(r_sp$i, function(i) USP_CATALOGUE_MC$SpearTps$calc(list(r = P[i, ])), numeric(1)),
                        as.numeric(r_sp$u))))
    stop("lois_discretes() : S de Spearman different de la statistique du catalogue")
  spearman <- completer(list(v = r_sp$u, f = tabulate(match(S_sp, r_sp$u), length(r_sp$u)) / nrow(P), pe = pe_sp),
                        "SpearVol")
  r_mk <- rep_de(S_mk)
  z_mk <- vapply(r_mk$i, function(i) USP_CATALOGUE_MC$MK$calc(list(r = P[i, ])), numeric(1))
  if (any(diff(z_mk) <= 0)) stop("lois_discretes() : Z de Mann-Kendall non strictement croissant en S")
  pe_mk <- vapply(r_mk$i, function(i) mk_p_exacte(P[i, ]), numeric(1))
  f_mk <- tabulate(match(S_mk, r_mk$u), length(r_mk$u)) / nrow(P)
  d <- .mk_loi_exacte(n)
  if (!isTRUE(all.equal(f_mk, d$prob[match(r_mk$u, d$S)]))) stop("lois_discretes() : loi de S de Kendall != .mk_loi_exacte()")
  mk <- completer(list(v = r_mk$u, f = f_mk, pe = pe_mk), "MK")
  # Cox-Stuart : 2^4 signes equiprobables des differences ; statistique du
  # catalogue |K - 2|, p de test_cox_stuart().
  sg <- as.matrix(expand.grid(rep(list(c(-0.5, 0.5)), n / 2)))
  vc <- lapply(seq_len(nrow(sg)), function(i) c(seq_len(n / 2), seq_len(n / 2) + sg[i, ]))
  coxstuart <- completer(atomes(vapply(vc, function(v) USP_CATALOGUE_MC$CoxStuart$calc(list(r = v)), numeric(1)),
                                vapply(vc, function(v) test_cox_stuart(v)$p, numeric(1))), "CoxStuart")
  L <- list(suites = suites, mk = mk, smirnov = smirnov, spearman = spearman, coxstuart = coxstuart)
  for (s in names(LOI_STAT)) if (!identical(USP_CATALOGUE_MC[[s]]$queue, L[[LOI_STAT[[s]]]]$queue))
    stop("lois_discretes() : sens de rejet de ", s, " different de celui de sa loi")
  L
}
TAILLES <- lois_discretes()
txt_tailles <- function(tl) paste(vapply(names(LIB_LOI), function(k)
  sprintf("%s : atteignable %s et %s, liss\u00e9e %s et %s", LIB_LOI[[k]], num(tl[[k]]$atteignable[1], 5),
          num(tl[[k]]$atteignable[2], 5), num(tl[[k]]$lissee[1], 5), num(tl[[k]]$lissee[2], 5)), ""), collapse = " ; ")
# References (voir l'en-tete) : T1 et T1 bis, taille lissee pour une loi
# discrete, seuil sinon.
ref_stat <- function(s, j) if (s %in% names(LOI_STAT)) TAILLES[[LOI_STAT[[s]]]]$lissee[j] else SEUILS[j]
txt_ref <- function(ref, marque = "") if (is.na(ref)) "\u2014" else paste0(num(ref, 4), marque)

# --- Lecture d'un taux (aide a la lecture, sans conclure) -----------------------
# k rejets sur n (n : denominateur du taux, np en T2), reference ref : taux,
# IC de Clopper-Pearson a 95 %, reference dans l'IC, position par rapport a
# la bande de Bradley [ref/2 ; 3 ref/2], ecrite seulement quand elle sert
# (regle fixee par actuary le 30/09/2026) : non applicable si ref < 2/n,
# non ecrite si la reference est dans l'IC.
lecture <- function(k, n, ref) {
  if (n == 0) return(c(k = sprintf("%.0f", k), taux = "\u2014", ic = "\u2014", ref_ic = "\u2014", bande = "\u2014"))
  ci <- ic_cp(k, n); est <- k / n
  ref_ic <- if (is.na(ref)) "\u2014" else if (ref >= ci[1] && ref <= ci[2]) "oui" else "**non**"
  bande <- if (is.na(ref)) "\u2014"
    else if (ref < 2 / n) "non applicable (r\u00e9f. < 2/n)"
    else if (ref_ic == "oui") "\u2014"
    else if (ci[2] < ref / 2 || ci[1] > 3 * ref / 2) "IC enti\u00e8rement hors"
    else if (est >= ref / 2 && est <= 3 * ref / 2) "dans"
    else "estimation hors"
  c(k = sprintf("%.0f", k), taux = num(est, 4), ic = txt_ic(ci), ref_ic = ref_ic, bande = bande)
}

# --- Effectifs du tableau de #72 (controles (e3) et (e4)) ----------------------
effectifs_72 <- function(jeu) {
  f <- file.path(RACINE, TABLEAUX_72[[jeu]])
  if (!file.exists(f)) return(list(erreur = paste("tableau de #72 introuvable :", TABLEAUX_72[[jeu]])))
  l <- enc2utf8(readLines(f, warn = FALSE, encoding = "UTF-8"))
  par <- l[startsWith(l, "Param\u00e8tres : ")]
  if (length(par) != 1L) return(list(erreur = paste("ligne Param\u00e8tres absente ou multiple dans", TABLEAUX_72[[jeu]])))
  val <- function(cle) {
    m <- regmatches(par, regexec(sprintf("[ ;]%s=([^;]*)", cle), par))[[1]]
    if (length(m) == 2L) m[2] else NA_character_
  }
  cellules <- function(prefixe) {
    x <- l[startsWith(l, prefixe)]
    if (length(x) != 1L) return(NULL)
    y <- strsplit(x, " | ", fixed = TRUE)[[1]]
    if (length(y) < 5L) NULL else suppressWarnings(as.numeric(y[4:5]))
  }
  e <- list(bord0 = cellules("| dont \u03b4\u0302 au bord 0 |"), bord1 = cellules("| dont \u03b4\u0302 au bord 1 "),
            ic50 = cellules("| IC bootstrap 90 % : largeur relative au-dessus | 50 % |"),
            ic80 = cellules("| IC bootstrap 90 % : largeur relative au-dessus | 80 % |"))
  if (any(vapply(e, is.null, logical(1))))
    return(list(erreur = paste("lignes des bords 0 et 1 ou de l'IC bootstrap introuvables dans", TABLEAUX_72[[jeu]])))
  c(list(jeu = val("jeu"), R = suppressWarnings(as.integer(val("R"))),
         graine = suppressWarnings(as.numeric(val("graine")))), e)
}
# Controles (e3) et (e4) sur des comptes complets (R replications) : rend
# list(e3 = list(ok, texte), e4 = list(ok, texte)) ; ok = NA si non
# applicable (R different de R_72). A R = R_72, un tableau de #72 absent,
# illisible ou d'un autre jeu, R ou graine est un echec.
controles_72 <- function(cpt, R, jeu) {
  g <- function(k) if (k %in% names(cpt)) cpt[[k]] else 0
  e <- effectifs_72(jeu)
  if (!is.null(e$erreur)) {
    x <- if (R == R_72) list(ok = FALSE, texte = paste("\u00c9CHEC :", e$erreur)) else
      list(ok = NA, texte = paste("non applicable (R =", R, ") ;", e$erreur))
    return(list(e3 = x, e4 = x))
  }
  if (!identical(e$jeu, jeu) || !identical(e$R, R) || !isTRUE(e$graine == GRAINE_JEUX)) {
    # A R = R_72, un tableau de #72 d'un autre jeu, R ou graine est un echec
    # (constat T3 d'audit), comme un tableau absent.
    x <- list(ok = if (R == R_72) FALSE else NA,
              texte = sprintf(paste("%s : tableau de #72 \u00e0 jeu=%s, R=%s, graine=%s ;",
                                    "ici jeu=%s, R=%d, graine=%.0f"),
                              if (R == R_72) "\u00c9CHEC" else "non applicable",
                              e$jeu, e$R, e$graine, jeu, R, GRAINE_JEUX))
    return(list(e3 = x, e4 = x))
  }
  ici3 <- c(g("reg72|bord0"), g("reg72|bord1"))
  ok3 <- identical(ici3, c(e$bord0[1], e$bord1[1])) && identical(c(e$bord0[2], e$bord1[2]), rep(as.numeric(R), 2)) &&
    g("reg72|erreur") == 0
  ici4 <- c(g("ic|k50"), g("ic|k80"), g("ic|n"))
  ok4 <- identical(ici4, c(e$ic50[1], e$ic80[1], e$ic50[2])) && identical(e$ic80[2], e$ic50[2])
  list(e3 = list(ok = ok3, texte = sprintf(paste("%s : \u03b4\u0302* au bord 0 : %.0f (tableau de #72 : %.0f sur %.0f) ;",
                                                 "au bord 1 : %.0f (tableau de #72 : %.0f sur %.0f) ; usp_ajuster() en erreur : %.0f ; %s"),
                                           if (ok3) "OK" else "\u00c9CHEC", ici3[1], e$bord0[1], e$bord0[2], ici3[2], e$bord1[1],
                                           e$bord1[2], g("reg72|erreur"), TABLEAUX_72[[jeu]])),
       e4 = list(ok = ok4, texte = sprintf(paste("%s : largeur relative de l'IC bootstrap 90 %% au-dessus de 0,50 : %.0f sur %.0f",
                                                 "(tableau de #72 : %.0f sur %.0f) ; au-dessus de 0,80 : %.0f (tableau de #72 : %.0f sur %.0f) ; %s"),
                                           if (ok4) "OK" else "\u00c9CHEC", ici4[1], ici4[3], e$ic50[1], e$ic50[2], ici4[2],
                                           e$ic80[1], e$ic80[2], TABLEAUX_72[[jeu]])))
}

###############################################################################
#  TABLEAUX A PARTIR DES COMPTES (execution directe, tranche, --combiner)
###############################################################################
# cpt : vecteur nomme de comptes ; stats : nom -> queue ; lignes : libelles
# des 51 lignes dans l'ordre de la table. Cles :
#   rep, ok ; ecart|b|motif ; reg|r et reg72|r (r : bord1, bord0, interieur,
#   erreur) ; mc|s|r|n, mc|s|r|k1, mc|s|r|k2 ; mmc|s|motif ;
#   l|ligne|n, np, k1, k2, t|type, inop, nat|classe, v|verdict ;
#   h|controle|verdict ; lr|borne|r|n, k1, k2 ; lrm|borne|motif ;
#   ic|n, ic|k50, ic|k80 ; bperdu, bperdu_rep, rechec, lrechec|borne ;
#   lrnc|borne (LR non calculable sur l'observe, #161).
tableaux <- function(cpt, stats, lignes) {
  g <- function(k) if (k %in% names(cpt)) cpt[[k]] else 0
  n_ok <- g("ok")
  s_mc <- function(s, r, q) if (is.null(r)) sum(vapply(names(REGIMES), function(rr) g(sprintf("mc|%s|%s|%s", s, rr, q)), numeric(1))) else
    g(sprintf("mc|%s|%s|%s", s, r, q))
  cols_niv <- function(j) c(sprintf("< %s : k", num(SEUILS[j], 2)), "taux", "IC 95 %", "r\u00e9f.",
                            "r\u00e9f. dans l'IC", "bande [r\u00e9f/2 ; 3r\u00e9f/2]")
  excl_t1 <- 0
  nmc <- vapply(SEUILS, function(a) c(haut = niveau_mc_continu(a, "haut"), deux = niveau_mc_continu(a, "deux")), numeric(2))
  # --- T1
  L <- c("### T1 -- calibration de p_mc : les 34 statistiques de USP_CATALOGUE_MC (p_mc retenue ou non)", "",
         entete_md(c("Statistique", "Ligne de usp_tests()", "Queue", "n", cols_niv(1), cols_niv(2), "p_mc absente")))
  for (s in names(stats)) {
    n <- s_mc(s, NULL, "n"); disc <- s %in% names(LOI_STAT)
    cel <- lapply(1:2, function(j) {
      r <- ref_stat(s, j); lc <- lecture(s_mc(s, NULL, paste0("k", j)), n, r)
      c(lc[["k"]], lc[["taux"]], lc[["ic"]], txt_ref(r, if (disc) " \u2020" else ""), lc[["ref_ic"]], lc[["bande"]])
    })
    excl_t1 <- excl_t1 + sum(vapply(cel, function(v) identical(v[5], "**non**"), logical(1)))
    L <- c(L, ligne_md(s, STAT_LIGNE[[s]], stats[[s]], n, paste(cel[[1]], collapse = " | "),
                       paste(cel[[2]], collapse = " | "), n_ok - n))
  }
  L <- c(L, "", sprintf(paste("n : r\u00e9plications trait\u00e9es (%.0f) o\u00f9 la p_mc est calcul\u00e9e ; p_mc absente : r\u00e9plications",
                              "trait\u00e9es sans p_mc (motif en T3). Statistique continue : r\u00e9f\u00e9rence = seuil ; sous",
                              "\u00e9changeabilit\u00e9, P(p_mc < seuil) vaut en fait %s et %s en queue simple, %s et %s en",
                              "bilat\u00e9ral (B = %d), \u00e9cart n\u00e9gligeable devant l'IC.",
                              "\u2020 Loi de r\u00e9f\u00e9rence discr\u00e8te : r\u00e9f\u00e9rence = taille liss\u00e9e P(p_mc < seuil) sous la loi",
                              "\u00e9changeable \u00e0 T = 8 sans ex aequo et B = %d (T0), qui tient compte du bruit Monte-Carlo",
                              "de la p_mc autour des atomes de la loi."),
                        n_ok, num(nmc["haut", 1], 3), num(nmc["haut", 2], 3), num(nmc["deux", 1], 3),
                        num(nmc["deux", 2], 3), B_BOOT, B_BOOT),
         "", sprintf(paste("Multiplicit\u00e9 : T1 compte %d intervalles (34 statistiques \u00d7 2 seuils) ; ici %d excluent la",
                           "r\u00e9f\u00e9rence. Sur J1 et J2 r\u00e9unis, 136 intervalles : environ 7 exclusions (5 %% de 136) sont",
                           "attendues par hasard m\u00eame si toutes les r\u00e9f\u00e9rences sont justes (intervalles corr\u00e9l\u00e9s entre eux ;",
                           "ordre de grandeur, pas un test). T1 bis et T2 ajoutent leurs propres intervalles."),
                     2L * length(stats), excl_t1), "")
  # --- T1 bis
  L <- c(L, "### T1 bis -- calibration de p_mc par r\u00e9gime de \u03b4\u0302* du r\u00e9ajustement (r\u00e9f\u00e9rences de T1)", "",
         entete_md(c("Statistique", "R\u00e9gime", "n", cols_niv(1)[-4], cols_niv(2)[-4])))
  for (s in names(stats)) for (r in names(REGIMES)) {
    n <- s_mc(s, r, "n")
    cel <- vapply(1:2, function(j) {
      lc <- lecture(s_mc(s, r, paste0("k", j)), n, ref_stat(s, j))
      paste(lc[c("k", "taux", "ic", "ref_ic", "bande")], collapse = " | ")
    }, "")
    L <- c(L, ligne_md(s, REGIMES[[r]], n, cel[1], cel[2]))
  }
  L <- c(L, "", paste("R\u00e9gime du r\u00e9ajustement de run_engine() sur le jeu simul\u00e9 (seuils TOL_DELTA_BORD de #72) ;",
                      "effectifs en T3. Volumes non constants (contr\u00f4l\u00e9) : \u03c0\u0302* constant si et seulement si",
                      "\u03b4\u0302* au bord 1. R\u00e8gle R7 : \u00e0 \u03c0\u0302* constant, les lignes \u00e0 loi exacte retiennent la p",
                      "exacte ; ailleurs, la p_mc. Les taux par r\u00e9gime sont conditionnels \u00e0 un \u00e9v\u00e9nement fonction",
                      "des donn\u00e9es et n'ont pas de r\u00e9f\u00e9rence exacte m\u00eame pour une p_mc parfaitement calibr\u00e9e :",
                      "T1 bis localise un \u00e9cart, il ne teste pas la calibration par r\u00e9gime."), "")
  # --- T2
  L <- c(L, "### T2 -- niveau des verdicts des 51 lignes : fr\u00e9quence de p retenue < \u03b1 et < \u03b1/2 parmi les p retenues (r\u00e8gles R1, R3, R4, R7, R13 comprises)", "",
         entete_md(c("Ligne", "n", "p retenue", cols_niv(1), cols_niv(2))))
  for (li in lignes) {
    cl <- nettoyer_cle(li)
    gl <- function(suf) g(sprintf("l|%s|%s", cl, suf))
    n <- gl("n"); np <- gl("np")
    if (identical(li, LIGNE_ESD)) {
      # Procedure de decision sans p-value : ALERTE ou ECHEC (k chapeau >= 1)
      # contre le niveau nominal 0,10 ; ECHEC (k chapeau = 2) sans reference.
      c1 <- lecture(gl("v|ALERTE") + gl("v|ECHEC"), n, ALPHA); c2 <- lecture(gl("v|ECHEC"), n, NA_real_)
      L <- c(L, ligne_md(li, n, "\u2014 (proc\u00e9dure sans p-value)",
                         paste(c(c1[c("k", "taux", "ic")], txt_ref(ALPHA, " \u2021"), c1[c("ref_ic", "bande")]), collapse = " | "),
                         paste(c(c2[c("k", "taux", "ic")], "\u2014", "\u2014", "\u2014"), collapse = " | ")))
      next
    }
    disc <- li %in% names(LOI_LIGNE)
    sans <- if (li %in% names(LIGNES_SANS_NIVEAU)) LIGNES_SANS_NIVEAU[[li]] else
      if (np == 0) "sans objet (aucune p retenue)" else NA_character_
    # Loi discrete : melange des references selon la nature de la p retenue
    # (approche) ; les p d'une autre nature (n_hors) comptent dans np et
    # dans les rejets, non dans la reference.
    n_ex <- gl("nat|exacte"); n_mc <- gl("nat|mc"); n_hors <- np - n_ex - n_mc
    cel <- vapply(1:2, function(j) {
      r <- if (!is.na(sans)) NA_real_ else if (!disc) SEUILS[j] else if (n_ex + n_mc > 0) {
        lo <- TAILLES[[LOI_LIGNE[[li]]]]
        (n_ex * lo$atteignable[j] + n_mc * lo$lissee[j]) / (n_ex + n_mc)
      } else NA_real_
      lc <- lecture(gl(paste0("k", j)), np, r)
      txt <- if (!is.na(sans)) sans else
        paste0(txt_ref(r, if (disc) " \u2020" else ""), if (disc && n_hors > 0) sprintf(" (n hors r\u00e9f. = %.0f)", n_hors) else "")
      paste(c(lc[c("k", "taux", "ic")], txt, lc[c("ref_ic", "bande")]), collapse = " | ")
    }, "")
    L <- c(L, ligne_md(li, n, np, cel[1], cel[2]))
  }
  L <- c(L, "", paste("n : r\u00e9plications trait\u00e9es ; p retenue : r\u00e9plications o\u00f9 la ligne a une p retenue. Taux =",
                      "rejets / p retenues (niveau conditionnel \u00e0 l'existence d'une p retenue) ; la fr\u00e9quence",
                      "inconditionnelle du verdict, rejets / n, se lit dans T2 (suite), colonnes ALERTE et ECHEC.",
                      "Sens \u00ab ne pas rejeter \u00bb : p < \u03b1 donne ALERTE ou ECHEC, p < \u03b1/2 ECHEC. Pour les deux lignes",
                      "en sens \u00ab rejeter \u00bb (pente, TOST), p < \u03b1 est un OK : les colonnes donnent une",
                      "puissance conditionnelle, sans r\u00e9f\u00e9rence."), "",
         paste("\u2020 Loi de r\u00e9f\u00e9rence discr\u00e8te : r\u00e9f\u00e9rence = (n_exacte \u00d7 taille atteignable + n_MC \u00d7 taille liss\u00e9e)",
               "/ (n_exacte + n_MC), sur les natures de la p retenue compt\u00e9es en T2 (suite) ; r\u00e9f\u00e9rence",
               "**approch\u00e9e** : elle suppose l'\u00e9changeabilit\u00e9 et ignore la s\u00e9lection par le r\u00e9gime (\u00e0 \u03c0\u0302* variable,",
               "la p retenue de ces lignes est la p_mc, r\u00e8gle R7, dont le niveau n'est qu'approch\u00e9 par la taille",
               "liss\u00e9e). Une p retenue d'une autre nature (repli asymptotique nomm\u00e9, r\u00e8gle R3 ; attendu 0 \u00e0 T = 8",
               "sans ex \u00e6quo) compte dans np et dans les rejets, non dans la r\u00e9f\u00e9rence, alors suivie de",
               "\u00ab (n hors r\u00e9f. = k) \u00bb."), "",
         paste("\u2021 Ligne ESD (proc\u00e9dure de d\u00e9cision, sans p-value) : premi\u00e8re colonne, ALERTE ou ECHEC, mesure",
               "P(k\u0302 \u2265 1), sur les r\u00e9plications trait\u00e9es, contre 0,10, niveau nominal de la proc\u00e9dure de Rosner,",
               "valeurs critiques \u00e0 1 \u2212 \u03b1/(2 n_i) ; exactitude non \u00e9tablie \u00e0 T = 8 ni sur z = P\u03b5. Seconde",
               "colonne : ECHEC, mesure P(k\u0302 = 2), sans niveau nominal."), "",
         "### T2 (suite) -- composition des lignes : types, nature de la p retenue, verdicts", "",
         entete_md(c("Ligne", "n", "test", "diagnostic", "dont inop\u00e9rant (R1)", "non applicable",
                     "proc\u00e9dure de d\u00e9cision", "p exacte", "p Monte-Carlo", "p asymptotique", "autre p",
                     "aucune p", "OK", "ALERTE", "ECHEC", "INFO")))
  for (li in lignes) {
    k <- function(suf) sprintf("%.0f", g(sprintf("l|%s|%s", nettoyer_cle(li), suf)))
    L <- c(L, ligne_md(li, k("n"), k("t|test"), k("t|diagnostic"), k("inop"), k("t|non applicable"),
                       k("t|procedure de decision"), k("nat|exacte"), k("nat|mc"), k("nat|asympt"), k("nat|autre"),
                       k("nat|aucune"), k("v|OK"), k("v|ALERTE"), k("v|ECHEC"), k("v|INFO")))
  }
  L <- c(L, "", paste("Nature : champ nature_p de la ligne (exacte ; Monte-Carlo ; asymptotique, repli nomm\u00e9",
                      "compris ; autre : p sous le mod\u00e8le auxiliaire pond\u00e9r\u00e9 du TOST, exacte par permutation de Pitman sur la pente).",
                      "Inop\u00e9rant : d\u00e9tail pr\u00e9fix\u00e9 \u00ab TEST INOPERANT \u00bb (r\u00e8gle R1), compt\u00e9 aussi en diagnostic."), "")
  # --- T3
  L <- c(L, "### T3 -- r\u00e9gimes, r\u00e9plications \u00e9cart\u00e9es, motifs, contr\u00f4les de la famille H, rapport de vraisemblance, IC bootstrap", "",
         "R\u00e9gimes de \u03b4\u0302* :", "",
         entete_md(c("R\u00e9gime", "run_engine() (r\u00e9plications trait\u00e9es)", "code de #72 : usp_ajuster(x, y*) (toutes)")))
  for (r in c(names(REGIMES), "erreur"))
    L <- c(L, ligne_md(if (r == "erreur") "usp_ajuster() en erreur" else REGIMES[[r]],
                       sprintf("%.0f", g(paste0("reg|", r))), sprintf("%.0f", g(paste0("reg72|", r)))))
  L <- c(L, ligne_md("Total", sprintf("%.0f", n_ok), sprintf("%.0f", g("rep"))), "")
  ec <- grep("^ecart\\|", names(cpt), value = TRUE)
  L <- c(L, sprintf("R\u00e9plications \u00e9cart\u00e9es (erreur de run_engine() ou ok = FALSE) : %d sur %.0f.", length(ec), g("rep")), "")
  if (length(ec)) {
    p <- strsplit(ec, "|", fixed = TRUE)
    b <- as.integer(vapply(p, `[`, "", 2L))
    L <- c(L, entete_md(c("R\u00e9plication b", "Motif")),
           vapply(order(b), function(i) ligne_md(b[i], paste(p[[i]][-(1:2)], collapse = " ")), ""), "")
  }
  mm <- grep("^mmc\\|", names(cpt), value = TRUE)
  L <- c(L, "Motifs d'absence de p_mc (motif_mc, r\u00e9plications trait\u00e9es) :", "")
  L <- c(L, if (!length(mm)) "aucun." else c(entete_md(c("Statistique", "Motif", "Nombre")),
    vapply(mm, function(k) { p <- strsplit(k, "|", fixed = TRUE)[[1]]; ligne_md(p[2], p[3], sprintf("%.0f", cpt[[k]])) }, "")), "")
  hh <- grep("^h\\|", names(cpt), value = TRUE)
  ctl <- unique(vapply(strsplit(hh, "|", fixed = TRUE), `[`, "", 2L))
  L <- c(L, "Contr\u00f4les num\u00e9riques de la famille H (res$controles, verdicts) :", "",
         entete_md(c("Contr\u00f4le", "OK", "ALERTE", "ECHEC", "autre")))
  for (cn in ctl) {
    v <- hh[startsWith(hh, paste0("h|", cn, "|"))]
    vv <- substring(v, nchar(cn) + 4L)
    L <- c(L, ligne_md(cn, sprintf("%.0f", g(sprintf("h|%s|OK", cn))), sprintf("%.0f", g(sprintf("h|%s|ALERTE", cn))),
                       sprintf("%.0f", g(sprintf("h|%s|ECHEC", cn))),
                       sprintf("%.0f", sum(cpt[v[!vv %in% c("OK", "ALERTE", "ECHEC")]]))))
  }
  L <- c(L, "", "p_mc des deux lignes du rapport de vraisemblance (#45 ; hors objet de T1 et T2, sans r\u00e9f\u00e9rence) :", "",
         entete_md(c("Ligne", "R\u00e9gime de \u03b4\u0302*", "n", "< 0,10 : k", "taux", "IC 95 %", "< 0,05 : k", "taux", "IC 95 %")))
  for (bn in names(LIGNES_LR)) for (r in c(names(REGIMES), "tous")) {
    q <- function(x) if (r == "tous") sum(vapply(names(REGIMES), function(rr) g(sprintf("lr|%s|%s|%s", bn, rr, x)), numeric(1))) else
      g(sprintf("lr|%s|%s|%s", bn, r, x))
    n <- q("n"); c1 <- lecture(q("k1"), n, NA_real_); c2 <- lecture(q("k2"), n, NA_real_)
    L <- c(L, ligne_md(LIGNES_LR[[bn]], if (r == "tous") "tous" else REGIMES[[r]], n,
                       paste(c1[c("k", "taux", "ic")], collapse = " | "), paste(c2[c("k", "taux", "ic")], collapse = " | ")))
  }
  lm_ <- grep("^lrm\\|", names(cpt), value = TRUE)
  L <- c(L, "", paste0("Motifs d'absence de p_mc du rapport de vraisemblance : ",
                       if (!length(lm_)) "aucun." else paste(vapply(lm_, function(k) {
                         p <- strsplit(k, "|", fixed = TRUE)[[1]]
                         sprintf("%s, %s : %.0f", LIGNES_LR[[p[2]]], p[3], cpt[[k]]) }, ""), collapse = " ; ")), "",
         sprintf(paste("Largeur relative de l'IC bootstrap 90 %% (contr\u00f4le (e4)) : au-dessus de 0,50 dans %.0f r\u00e9plication(s),",
                       "au-dessus de 0,80 dans %.0f, sur %.0f o\u00f9 elle est finie."), g("ic|k50"), g("ic|k80"), g("ic|n")), "",
         sprintf(paste("Bootstrap interne : %.0f r\u00e9plication(s) \u00e9cart\u00e9e(s) par usp_bootstrap() sur %.0f (B = %d par",
                       "r\u00e9plication trait\u00e9e), dans %.0f r\u00e9plication(s) ; bootstrap restreint (#45) : %.0f \u00e9chec(s) du",
                       "r\u00e9ajustement contraint ; rapport de vraisemblance : %.0f (\u03b4 = 0) et %.0f (\u03b4 = 1) r\u00e9plication(s)",
                       "\u00e9cart\u00e9e(s) ; rapport de vraisemblance non calculable sur l'observ\u00e9 (r\u00e9plication trait\u00e9e,",
                       "ligne non applicable, #161) : %.0f (\u03b4 = 0), %.0f (\u03b4 = 1)."),
                 g("bperdu"), n_ok * B_BOOT, B_BOOT, g("bperdu_rep"), g("rechec"), g("lrechec|borne0"), g("lrechec|borne1"),
                 g("lrnc|borne0"), g("lrnc|borne1")), "")
  list(lignes = L, excl_t1 = excl_t1)
}

aide_lecture <- function() c(
  "### Aide \u00e0 la lecture (sans conclusion)", "",
  paste("Statut : **constat de simulation sous le mod\u00e8le ajust\u00e9 au jeu** (usp_simuler(FIT0)), pas un r\u00e9sultat",
        "g\u00e9n\u00e9ral. Chaque r\u00e9plication est trait\u00e9e par run_engine() complet (B = 999) : la mesure porte sur la",
        "proc\u00e9dure du dossier (r\u00e9ajustement, bootstrap param\u00e9trique, engine_p_mc(), verdict de add()). Protocole",
        "d'actuary (#122, commentaire 5905003573 ; d\u00e9cisions du mainteneur, commentaire 5905011303 ; issue #166)."), "",
  paste("IC : Clopper-Pearson \u00e0 95 %, incertitude Monte-Carlo sur le taux (fonction de R), pas l'erreur",
        "d'approximation en T ; l'erreur li\u00e9e \u00e0 B fait partie de la proc\u00e9dure mesur\u00e9e. \u00ab oui \u00bb dans",
        "\u00ab r\u00e9f. dans l'IC \u00bb se lit \u00ab compatible \u00bb au sens de \u00ab aucune distorsion d\u00e9tect\u00e9e \u00e0 la pr\u00e9cision",
        "Monte-Carlo \u00bb, jamais \u00ab exact \u00bb."), "",
  paste("Bande de Bradley (1978), crit\u00e8re lib\u00e9ral [r\u00e9f/2 ; 3r\u00e9f/2] : **convention, pas th\u00e9or\u00e8me** (J. V. Bradley,",
        "\u00ab Robustness? \u00bb, *British Journal of Mathematical and Statistical Psychology* 31(2), 1978, p. 144-152).",
        "Le rapport 0,5-1,5 au niveau nominal est la r\u00e8gle de Bradley elle-m\u00eame \u00e0 tout seuil : [0,05 ; 0,15] \u00e0",
        "0,10, [0,025 ; 0,075] \u00e0 0,05. Pour une r\u00e9f\u00e9rence discr\u00e8te (\u2020), la bande est la transposition en rapport",
        "du crit\u00e8re de Bradley \u00e0 la taille de r\u00e9f\u00e9rence (convention du script). Colonne \u00ab bande \u00bb, \u00e9crite",
        "seulement si la r\u00e9f\u00e9rence est hors de l'IC : \u00ab dans \u00bb : estimation dans la bande ; \u00ab estimation hors \u00bb :",
        "estimation hors de la bande, IC la recoupant ; \u00ab IC enti\u00e8rement hors \u00bb : IC disjoint de la bande ;",
        "\u00ab non applicable (r\u00e9f. < 2/n) \u00bb : voir ci-dessous ; \u00ab \u2014 \u00bb : r\u00e9f\u00e9rence dans l'IC, ou pas de r\u00e9f\u00e9rence."), "",
  paste("Lecture, par actuary, \u00e0 partir des colonnes \u00ab r\u00e9f. dans l'IC \u00bb et \u00ab bande \u00bb : (1) l'IC contient la",
        "r\u00e9f\u00e9rence : **compatible** (la bande n'est pas \u00e9crite) ; (2) sinon, estimation dans la bande : **\u00e9cart",
        "mineur**, consign\u00e9 en rubrique 7 ; (3) IC disjoint de la bande : **distorsion mat\u00e9rielle**, point de",
        "d\u00e9cision du mainteneur ; (4) sinon (estimation hors de la bande, IC la recoupant) : **\u00e9cart non",
        "tranch\u00e9**, distorsion possible non \u00e9tablie \u00e0 la pr\u00e9cision Monte-Carlo, consign\u00e9 en rubrique 7 avec",
        "l'IC, \u00e0 \u00e9clairer par T1 bis et les valeurs brutes, sans d\u00e9cision d\u00e9clench\u00e9e. Bande non applicable",
        "quand la r\u00e9f\u00e9rence est inf\u00e9rieure \u00e0 2/n (sa demi-largeur ref/2 est sous la r\u00e9solution 1/n du taux ;",
        "Cox-Stuart) : lecture binaire, compatible ou **\u00e9cart \u00e0 examiner** (k et IC cit\u00e9s), sans \u00e9chelle",
        "mineur / mat\u00e9riel ni d\u00e9cision d\u00e9clench\u00e9e ; une r\u00e9f\u00e9rence nulle n'est pas ramen\u00e9e \u00e0 une bande {0}."), "")

LIBELLES_CONTEXTE <- c(
  jeu = "Jeu", modele = "Mod\u00e8le ajust\u00e9 (usp_ajuster())", configuration = "Configuration de run_engine()",
  sigma_usp = "\u03c3_USP observ\u00e9 (usp_parametre() sur le mod\u00e8le ajust\u00e9)", graines = "Graines",
  collisions = "Graines en collision (d\u00e9clar\u00e9es, non bloquantes)", generateur = "G\u00e9n\u00e9rateur",
  commit = "Commit", plateforme = "Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)",
  empreintes = "Empreintes md5 du code ex\u00e9cut\u00e9",
  reference = "Contr\u00f4le (a) : J1 observ\u00e9 contre tests/reference/premium.rds",
  tailles = "Tailles des lois discr\u00e8tes, P(p < 0,10) et P(p < 0,05) (T = 8, sans ex aequo)")
lignes_contexte <- function(ctx) vapply(names(LIBELLES_CONTEXTE), function(k)
  ligne_md(LIBELLES_CONTEXTE[[k]], ctx[[k]]), "")

DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
# Avec --ecrire, garde d'ecrasement (#173) avant l'ecriture ; le T0 d'un
# fichier remplace (--remplacer) le cite.
ecrire_fichier <- function(jeu, lignes) {
  if (!OPT_ECRIRE && is.na(OPT_SORTIE)) return(invisible(NULL))
  dossier <- if (OPT_ECRIRE) file.path(RACINE, "docs", "tableaux") else OPT_SORTIE
  if (!dir.exists(dossier)) stop("dossier de sortie introuvable : ", dossier)
  f <- file.path(dossier, sprintf("%s-issue166-calibration-%s.md", DATE_SORTIE, jeu))
  if (OPT_ECRIRE) lignes <- inserer_t0(lignes, ligne_remplacement(garde_ecrasement(f, OPT_REMPLACER, RACINE), f))
  con <- file(f, open = "wb")
  writeLines(enc2utf8(lignes), con, useBytes = TRUE)
  close(con)
  message("\u00e9crit : ", f)
}

###############################################################################
#  MODE --combiner
###############################################################################
refuser <- function(...) {
  message("--combiner : REFUS -- ", ...)
  quit(status = 1L)
}
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
  cles <- vapply(cp, `[`, "", 1L)
  if (anyDuplicated(cles)) refuser(f, " : cle(s) COMPTE en double : ", paste(unique(cles[duplicated(cles)]), collapse = ", "))
  ctx <- champs("CONTEXTE")
  if (!length(ctx) || any(lengths(ctx) != 2L)) refuser(f, " : lignes CONTEXTE absentes ou illisibles")
  ctx <- stats::setNames(vapply(ctx, `[`, "", 2L), vapply(ctx, `[`, "", 1L))
  if (!setequal(names(ctx), names(LIBELLES_CONTEXTE)) || anyDuplicated(names(ctx)))
    refuser(f, " : lignes CONTEXTE incompletes (attendues : ", paste(names(LIBELLES_CONTEXTE), collapse = ", "), ")")
  du <- suppressWarnings(as.numeric(unique1("DUREE")))
  if (length(du) != 3L || anyNA(du)) refuser(f, " : ligne DUREE illisible")
  st <- unique1("STATS")
  rc <- unique1("REPCOLS")
  n_rep <- suppressWarnings(as.integer(unique1("NREP")))
  rp <- champs("REP")
  if (is.na(n_rep) || length(rp) != n_rep) refuser(f, sprintf(" : %d ligne(s) REP lue(s), NREP = %s -- sortie tronquee ou modifiee",
                                                              length(rp), n_rep))
  if (any(lengths(rp) != length(rc))) refuser(f, " : ligne REP de longueur differente de REPCOLS")
  list(fichier = f, parametres = par, debut = as.integer(tr[1]), fin = as.integer(tr[2]),
       contexte = ctx[names(LIBELLES_CONTEXTE)],
       stats = stats::setNames(sub("^.*=", "", st), sub("=.*$", "", st)), lignes = unique1("LIGNES"),
       repcols = rc, rep = rp, duree = du,
       comptes = stats::setNames(as.numeric(vapply(cp, `[`, "", 2L)), cles))
}
# Invariants du corps d'une tranche (constat F2 d'audit) : texte des
# invariants faux, character(0) si tous tiennent.
invariants_tranche <- function(p) {
  cp <- p$comptes; nm <- names(cp)
  g <- function(k) if (k %in% nm) cp[[k]] else 0
  somme <- function(prefixe, suffixe = "") sum(cp[startsWith(nm, prefixe) & endsWith(nm, suffixe)])
  err <- character(0)
  rep <- g("rep"); ok <- g("ok"); ne <- somme("ecart|")
  if (rep != p$fin - p$debut + 1) err <- c(err, sprintf("rep = %.0f, fin - debut + 1 = %d", rep, p$fin - p$debut + 1L))
  if (ok + ne != rep) err <- c(err, sprintf("ok + ecartees = %.0f, rep = %.0f", ok + ne, rep))
  if (somme("reg|") != ok) err <- c(err, sprintf("somme des reg = %.0f, ok = %.0f", somme("reg|"), ok))
  if (somme("reg72|") != rep) err <- c(err, sprintf("somme des reg72 = %.0f, rep = %.0f", somme("reg72|"), rep))
  bl <- p$lignes[vapply(p$lignes, function(li) g(sprintf("l|%s|n", nettoyer_cle(li))) != ok, logical(1))]
  if (length(bl)) err <- c(err, paste("l|ligne|n different de ok :", paste(bl, collapse = ", ")))
  bs <- names(p$stats)[vapply(names(p$stats), function(s)
    somme(sprintf("mc|%s|", s), "|n") + somme(sprintf("mmc|%s|", s)) != ok, logical(1))]
  if (length(bs)) err <- c(err, paste("n + p_mc absentes different de ok :", paste(bs, collapse = ", ")))
  if (length(p$rep) != rep) err <- c(err, sprintf("%d ligne(s) REP, rep = %.0f", length(p$rep), rep))
  b <- suppressWarnings(as.integer(vapply(p$rep, `[`, "", 1L)))
  rg <- vapply(p$rep, `[`, "", 2L)
  if (anyNA(b) || !identical(sort(b), seq.int(p$debut, p$fin)))
    err <- c(err, "b des lignes REP differents de debut..fin")
  for (r in c(names(REGIMES), "ecartee")) {
    attendu <- if (r == "ecartee") ne else g(paste0("reg|", r))
    if (sum(rg == r) != attendu) err <- c(err, sprintf("lignes REP de regime %s : %d, comptes : %.0f", r, sum(rg == r), attendu))
  }
  if (!all(rg %in% c(names(REGIMES), "ecartee"))) err <- c(err, "regime inconnu dans une ligne REP")
  be <- suppressWarnings(as.integer(sub("^ecart\\|([0-9]+)\\|.*$", "\\1", nm[startsWith(nm, "ecart|")])))
  if (!identical(sort(be), sort(b[rg == "ecartee"]))) err <- c(err, "replications ecartees des REP differentes de celles des comptes")
  # Recoupement des lignes REP avec les comptes (constat R3 d'audit) : n, k1
  # et k2 recomptes sur les valeurs brutes (ecrites en %.17g, relues sans
  # perte) pour les 34 p_mc, par regime, et pour les 51 p retenues.
  if (length(p$rep) && identical(length(p$repcols), unique(lengths(p$rep)))) {
    M <- do.call(rbind, p$rep); colnames(M) <- p$repcols
    tr <- M[, "regime"] != "ecartee"
    val <- function(col) suppressWarnings(as.numeric(M[tr, col]))
    rgt <- M[tr, "regime"]
    trois <- function(v) c(n = sum(is.finite(v)), k1 = sum(is.finite(v) & v < ALPHA), k2 = sum(is.finite(v) & v < ALPHA2))
    ds <- character(0)
    for (s in names(p$stats)) {
      v <- val(paste0("p_mc:", s))
      for (r in names(REGIMES)) {
        x <- trois(v[rgt == r])
        cp_x <- vapply(names(x), function(q) g(sprintf("mc|%s|%s|%s", s, r, q)), numeric(1))
        if (!identical(as.numeric(x), unname(cp_x))) ds <- c(ds, sprintf("p_mc %s (%s)", s, r))
      }
    }
    for (li in p$lignes) {
      x <- trois(val(paste0("p_retenue:", li)))
      cp_x <- vapply(c("np", "k1", "k2"), function(q) g(sprintf("l|%s|%s", nettoyer_cle(li), q)), numeric(1))
      if (!identical(as.numeric(x), unname(cp_x))) ds <- c(ds, sprintf("p retenue %s", li))
    }
    if (length(ds)) err <- c(err, paste("lignes REP differentes des comptes (n, k1, k2) :", paste(ds, collapse = ", ")))
  }
  err
}

if (length(FICHIERS_COMB)) {
  # Gardes des chemins d'ecriture (constat R2 d'audit) : --sortie et --brut
  # hors du depot, --brut sans ecrasement.
  if (!is.na(OPT_SORTIE) && sous_depot(OPT_SORTIE))
    refuser("--sortie : dossier sous le depot refuse (--ecrire est le seul chemin qui ecrit dans le depot) : ", OPT_SORTIE)
  if (!is.na(OPT_BRUT)) {
    if (!dir.exists(dirname(OPT_BRUT))) refuser("--brut : dossier introuvable : ", dirname(OPT_BRUT))
    if (sous_depot(dirname(OPT_BRUT)))
      refuser("--brut : chemin sous le depot refuse (versionnement des valeurs brutes non decide par le mainteneur) : ", OPT_BRUT)
    if (file.exists(OPT_BRUT)) refuser("--brut : fichier existant, jamais ecrase : ", OPT_BRUT)
  }
  parts <- lapply(FICHIERS_COMB, lire_comptes)
  par <- unique(vapply(parts, `[[`, "", "parametres"))
  if (length(par) != 1L) refuser("parametres differents entre les fichiers (un seul jeu par combinaison)")
  ctx <- unique(lapply(parts, `[[`, "contexte"))
  if (length(ctx) != 1L) {
    k_diff <- names(LIBELLES_CONTEXTE)[vapply(names(LIBELLES_CONTEXTE), function(k)
      length(unique(vapply(parts, function(p) p$contexte[[k]], ""))) > 1L, logical(1))]
    refuser("contexte (T0) different entre les tranches : ", paste(k_diff, collapse = ", "))
  }
  ctx <- ctx[[1]]
  if (length(unique(lapply(parts, `[[`, "stats"))) != 1L) refuser("lignes STATS differentes entre les tranches")
  if (length(unique(lapply(parts, `[[`, "lignes"))) != 1L) refuser("lignes LIGNES differentes entre les tranches")
  if (length(unique(lapply(parts, `[[`, "repcols"))) != 1L) refuser("lignes REPCOLS differentes entre les tranches")
  if (!identical(ctx[["tailles"]], txt_tailles(TAILLES)))
    refuser("tailles des lois discretes des tranches differentes de celles recalculees par --combiner : ",
            ctx[["tailles"]], " contre ", txt_tailles(TAILLES))
  R_tot <- as.integer(sub("^.*;R=([0-9]+);.*$", "\\1", par))
  jeu_c <- sub("^jeu=(J[12]);.*$", "\\1", par)
  idx <- unlist(lapply(parts, function(p) seq.int(p$debut, p$fin)))
  if (anyDuplicated(idx) || !setequal(idx, seq_len(R_tot)))
    refuser("les tranches ne couvrent pas 1..", R_tot, " exactement une fois")
  for (p in parts) {
    e <- invariants_tranche(p)
    if (length(e)) refuser(p$fichier, " : invariant(s) du corps faux -- ", paste(e, collapse = " ; "))
  }
  cles <- unique(unlist(lapply(parts, function(p) names(p$comptes))))
  cpt <- stats::setNames(vapply(cles, function(k) sum(vapply(parts, function(p)
    if (k %in% names(p$comptes)) p$comptes[[k]] else 0, numeric(1))), numeric(1)), cles)
  if (cpt[["rep"]] != R_tot) refuser(sprintf("somme des rep = %.0f, R = %d", cpt[["rep"]], R_tot))
  c72 <- controles_72(cpt, R_tot, jeu_c)
  if (isFALSE(c72$e3$ok)) refuser("controle (e3) en ECHEC -- ", c72$e3$texte)
  if (isFALSE(c72$e4$ok)) refuser("controle (e4) en ECHEC -- ", c72$e4$texte)
  # --ecrire exige un commit propre et le code du depot pour les tranches ET
  # pour la combinaison elle-meme (constat R1 d'audit).
  COMMIT_COMB <- commit_depot()
  EMPREINTES_COMB <- empreintes_code("tests/calibration_mc_t8.R", SCRIPT_72)
  nv <- c(motifs_non_versionnable(ctx[["commit"]], ctx[["empreintes"]]),
          motifs_non_versionnable(COMMIT_COMB, EMPREINTES_COMB, "de la combinaison"))
  if (OPT_ECRIRE && length(nv))
    refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
            " -- relancer sur un arbre propre, ou utiliser --sortie DOSSIER hors du depot")
  tb <- tableaux(cpt, parts[[1]]$stats, parts[[1]]$lignes)
  du <- Reduce(`+`, lapply(parts, `[[`, "duree"))
  sortie <- c(sprintf("## Calibration des p-values Monte-Carlo \u00e0 T = 8, jeu %s -- combinaison de %d tranche(s) (issue #166)",
                      jeu_c, length(parts)), "",
              sprintf("Param\u00e8tres : %s", par), "",
              "### T0 -- contexte (identique dans toutes les tranches, v\u00e9rifi\u00e9)", "",
              entete_md(c("Grandeur", "Valeur")),
              lignes_contexte(ctx),
              ligne_md("R\u00e9plications", sprintf("%d (%d tranche(s) : %s)", R_tot, length(parts),
                                                  paste(vapply(parts, function(p) sprintf("%d-%d", p$debut, p$fin), ""),
                                                        collapse = ", "))),
              ligne_md("Dur\u00e9e cumul\u00e9e des tranches (s)",
                       sprintf("contr\u00f4les %.0f ; r\u00e9plications %.0f (%.1f s par r\u00e9plication)", du[1], du[2],
                               du[2] / max(du[3], 1))),
              ligne_md("Commit de la combinaison", COMMIT_COMB),
              ligne_md("Empreintes md5 du combinateur", EMPREINTES_COMB),
              ligne_md("Versionnable (--ecrire)", if (length(nv)) paste("non :", paste(nv, collapse = " ; ")) else "oui"),
              ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", sprintf("OK dans les %d tranche(s), invariants du corps v\u00e9rifi\u00e9s ; (e3) : %s ; (e4) : %s",
                                                          length(parts), c72$e3$texte, c72$e4$texte)), "",
              aide_lecture(), tb$lignes,
              "### Contr\u00f4les d'int\u00e9grit\u00e9", "",
              sprintf("- (a) \u00e0 (d), (e1), (e2), (f) et contr\u00f4les de coh\u00e9rence : OK dans les %d tranche(s) (ligne INTEGRITE)", length(parts)),
              sprintf("- Invariants du corps des tranches (comptes et lignes REP) : OK dans les %d tranche(s) ; somme des rep = R = %d", length(parts), R_tot),
              sprintf("- (e3) effectifs des r\u00e9gimes contre le tableau de #72 : %s", c72$e3$texte),
              sprintf("- (e4) largeur de l'IC bootstrap contre le tableau de #72 : %s", c72$e4$texte), "")
  ecrire_console(sortie)
  ecrire_fichier(jeu_c, sortie)
  if (!is.na(OPT_BRUT)) {
    rp <- do.call(c, lapply(parts, `[[`, "rep"))
    rp <- rp[order(as.integer(vapply(rp, `[`, "", 1L)))]
    con <- file(OPT_BRUT, open = "wb")
    writeLines(enc2utf8(c(paste(parts[[1]]$repcols, collapse = "\t"), vapply(rp, paste, "", collapse = "\t"))),
               con, useBytes = TRUE)
    close(con)
    message("\u00e9crit (valeurs brutes, ", length(rp), " r\u00e9plications) : ", OPT_BRUT)
  }
  quit(status = 0L)
}

###############################################################################
#  EXECUTION (d'un seul tenant ou tranche)
###############################################################################
# Commit lu au debut du calcul (moteur et script charges), et non a la fin :
# une tranche longue ne doit pas consigner un commit fait pendant son calcul.
COMMIT <- commit_depot()
EMPREINTES <- empreintes_code("tests/calibration_mc_t8.R", SCRIPT_72)
INTEGRITE <- character(0)          # libelles des controles en echec
CONTROLES <- character(0)          # lignes "libelle : OK / ECHEC"
controle <- function(ok, libelle) {
  ok <- isTRUE(ok)
  if (!ok) INTEGRITE <<- c(INTEGRITE, libelle)
  CONTROLES <<- c(CONTROLES, sprintf("%s : %s", libelle, if (ok) "OK" else "\u00c9CHEC"))
  invisible(ok)
}

# --- Jeu et modele ajuste (lire_j2() : copie de tests/taux_franchissement_reperes.R)
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
SIGMA_STD <- usp_parametre_standard(METHODE, SEGMENT, ANNEXE, NATURE, NULL)$sigma_standard
BAREME <- usp_bareme_segment(SEGMENT, ANNEXE)
PARAM0 <- usp_parametre(FIT0, SIGMA_STD, BAREME)
controle(!usp_volumes_constants(X),
         "Coh\u00e9rence : volumes du jeu non constants (\u03c0\u0302* constant si et seulement si \u03b4\u0302* au bord 1)")

# Tranche (bornes : copie de tests/taux_franchissement_reperes.R)
if (is.na(OPT_TRANCHE)) { DEBUT <- 1L; FIN <- OPT_R } else {
  m <- regmatches(OPT_TRANCHE, regexec("^([0-9]+)/([0-9]+)$", OPT_TRANCHE))[[1]]
  if (length(m) != 3L) stop("--tranche : forme i/K attendue")
  i <- as.integer(m[2]); K <- as.integer(m[3])
  if (K < 1L || i < 1L || i > K || K > OPT_R) stop("--tranche : 1 <= i <= K <= R")
  DEBUT <- as.integer(floor((i - 1) * OPT_R / K)) + 1L; FIN <- as.integer(floor(i * OPT_R / K))
}

# Les R jeux simules, d'un seul flux, avant tout calcul : meme expression que
# tests/taux_franchissement_reperes.R (#72), controlee en (e2).
OPT_GRAINE <- GRAINE_JEUX
YSIM <- engine_sous_graine(OPT_GRAINE, t(vapply(seq_len(OPT_R), function(b) usp_simuler(FIT0), numeric(T_))))

# (e2) : l'expression d'affectation de YSIM du script de #72, lue par parse()
# (sans executer ce script) ; ses noms doivent appartenir a NOMS_E2 (constat
# F3 d'audit : pas de code arbitraire) ; evaluee dans un environnement de
# parent emptyenv() qui ne contient que ces liaisons (memes OPT_GRAINE,
# OPT_R, FIT0 et T_ ; fonctions du moteur et de base), sans heriter des
# globales du script.
t_c <- Sys.time()
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
         sprintf("(e2) %d jeux simul\u00e9s identiques \u00e0 ceux de l'expression YSIM de %s (noms en liste blanche, environnement isol\u00e9)%s",
                 OPT_R, SCRIPT_72, if (inherits(ysim_72, "error")) paste0(" (", conditionMessage(ysim_72), ")") else ""))

# Collisions de graines (declarees, non bloquantes : graines du protocole,
# conservees), avec leur effet borne (reponse d'actuary du 30/09/2026,
# precisee pour une p_mc bilaterale).
COLLISIONS <- local({
  b <- 0:OPT_R
  g <- GRAINE_BOOT + b
  # cles ASCII : un nom accentue ne se traduit pas sous une locale POSIX (#113)
  autres <- c(jeux = GRAINE_JEUX, sw = SEED_LOI_NULLE_SW)
  lib <- c(jeux = "graine des jeux simul\u00e9s", sw = "SEED_LOI_NULLE_SW (loi nulle de Shapiro-Wilk)")
  effet <- c(
    jeux = paste("effet born\u00e9 : r\u00e9plication %d, \\|\u0394p_mc\\| \u2264 1/(B+1) = %s en queue simple et 2/(B+1) = %s en",
                 "bilat\u00e9ral, sur ses seules p_mc (au plus 1/R sur un taux), ses %d autres r\u00e9plications internes",
                 "restant ind\u00e9pendantes de y_%d"),
    sw = paste("r\u00e9plication %d, lois marginales de p_mc et p_exacte inchang\u00e9es (seule leur loi jointe est",
               "touch\u00e9e, non mesur\u00e9e)"))
  x <- unlist(lapply(names(autres), function(nm) {
    i <- which(g == autres[[nm]])
    if (!length(i)) return(character(0))
    e <- if (nm == "jeux") sprintf(effet[["jeux"]], b[i], num(1 / (B_BOOT + 1), 3), num(2 / (B_BOOT + 1), 3), B_BOOT - 1L, b[i]) else
      sprintf(effet[["sw"]], b[i])
    sprintf("r\u00e9plication %d : graine du bootstrap %.0f = %s (%s)", b[i], g[i], lib[[nm]], e)
  }))
  if (length(x)) paste(x, collapse = " ; ") else sprintf("aucune pour b = 0..%d", OPT_R)
})

# --- (a) J1 observe contre la reference premium -----------------------------------
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
TAB_A <- engine_table_tests(RES_A)
LIGNES <- TAB_A$test
STATS_Q <- vapply(USP_CATALOGUE_MC, `[[`, "", "queue")
controle(length(USP_CATALOGUE_MC) == N_STATS && identical(names(RES_A$bootstrap$p_mc), names(USP_CATALOGUE_MC)),
         sprintf("(b) J1 observ\u00e9 : %d statistiques au catalogue (attendu %d), noms de bootstrap$p_mc = catalogue",
                 length(USP_CATALOGUE_MC), N_STATS))
controle(length(LIGNES) == N_LIGNES && !anyDuplicated(LIGNES),
         sprintf("(c) J1 observ\u00e9 : %d lignes (attendu %d), libell\u00e9s distincts", length(LIGNES), N_LIGNES))
controle(setequal(names(STAT_LIGNE), names(USP_CATALOGUE_MC)) && all(STAT_LIGNE %in% LIGNES) &&
           all(vapply(names(STAT_LIGNE), function(s)
             identical(TAB_A$p_monte_carlo[match(STAT_LIGNE[[s]], LIGNES)], unname(RES_A$bootstrap$p_mc[[s]])), logical(1))),
         "Coh\u00e9rence : correspondance STAT_LIGNE (statistique -> ligne) v\u00e9rifi\u00e9e sur J1 observ\u00e9 (p_mc de la ligne = p_mc du bootstrap)")
controle(all(names(LIGNES_SANS_NIVEAU) %in% LIGNES) && all(names(LOI_LIGNE) %in% LIGNES) &&
           all(c(LIGNE_ESD, LIGNE_IC) %in% LIGNES) && all(names(LOI_STAT) %in% names(USP_CATALOGUE_MC)) &&
           identical(TAB_A$type[match(LIGNE_ESD, LIGNES)], "procedure de decision"),
         "Coh\u00e9rence : lignes et statistiques nomm\u00e9es par les constantes du script pr\u00e9sentes (ESD : proc\u00e9dure de d\u00e9cision)")
# (f) References ancrees au moteur (constat F6 d'audit).
f_atomes <- vapply(names(LOI_LIGNE), function(li) {
  p <- TAB_A$p_exacte[match(li, LIGNES)]
  is.finite(p) && any(abs(TAILLES[[LOI_LIGNE[[li]]]]$pe - p) <= 1e-9)
}, logical(1))
controle(all(f_atomes),
         sprintf("(f) J1 observ\u00e9 : p exacte des %d lignes \u00e0 loi discr\u00e8te parmi les p des atomes de lois_discretes()%s",
                 length(f_atomes), if (all(f_atomes)) "" else paste0(" ; hors atomes : ", paste(names(f_atomes)[!f_atomes], collapse = ", "))))
controle(isTRUE(all.equal(TAILLES$suites$atteignable, c(4 / 70, 0), tolerance = 1e-12)) &&
           all(abs(TAILLES$suites$lissee - c(0.05713, 0.00968)) < 5e-6),
         sprintf("(f) taille des suites \u00e0 T = 8 : atteignable %s et %s (4/70 et 0), liss\u00e9e %s et %s (0,05713 et 0,00968)",
                 num(TAILLES$suites$atteignable[1], 6), num(TAILLES$suites$atteignable[2], 6),
                 num(TAILLES$suites$lissee[1], 6), num(TAILLES$suites$lissee[2], 6)))
if (OPT_JEU == "J1")
  controle(identical(PARAM0$sigma_usp, RES_A$parametre_final$sigma_usp),
           "Coh\u00e9rence : \u03c3_USP de T0 (usp_parametre()) identique \u00e0 celui de run_engine() sur J1 observ\u00e9")
t_controle <- as.numeric(difftime(Sys.time(), t_c, units = "secs"))

# --- Replications ----------------------------------------------------------------------
cpt <- numeric(0)
ajoute <- function(cle, v = 1) { cpt[cle] <<- (if (cle %in% names(cpt)) cpt[[cle]] else 0) + v }
echecs_b <- list(b = integer(0), e1 = integer(0), c = integer(0))
classe_nature <- function(nat) if (is.na(nat)) "aucune" else if (identical(nat, "exacte")) "exacte" else
  if (startsWith(nat, "Monte-Carlo")) "mc" else if (startsWith(nat, "asymptotique")) "asympt" else "autre"
REPCOLS <- c("b", "regime", paste0("p_mc:", names(USP_CATALOGUE_MC)), paste0("p_retenue:", LIGNES))
REP <- character(0)
ligne_rep <- function(b, regime, p_mc, p_ret)
  paste(c(b, regime, sprintf("%.17g", c(p_mc, p_ret))), collapse = "\t")
t_r <- Sys.time()
for (b in seq.int(DEBUT, FIN)) {
  y <- YSIM[b, ]
  ajoute("rep")
  # (e1) regime par le code de #72 : usp_ajuster(x, y*), seuils bord0 / bord1.
  f72 <- tryCatch(usp_ajuster(X, y), error = function(e) e)
  r72 <- if (inherits(f72, "error")) "erreur" else code_regime(f72$delta)
  ajoute(paste0("reg72|", r72))
  res <- tryCatch(run_engine(xt = X, yt = y, methode = METHODE, segment = SEGMENT, annexe = ANNEXE,
                             nature_donnees = NATURE, B = B_BOOT, alpha = ALPHA, theta_equiv = THETA_EQUIV,
                             seed = GRAINE_BOOT + b), error = function(e) e)
  motif <- if (inherits(res, "error")) paste("erreur de run_engine() :", conditionMessage(res)) else
    if (!isTRUE(res$ok)) paste("ok = FALSE :", decrire_refus(res)) else NA_character_
  if (!is.na(motif)) {
    motif <- substr(trimws(nettoyer_cle(motif)), 1, 300)
    if (!nzchar(motif)) motif <- "(motif vide)"
    ajoute(sprintf("ecart|%d|%s", b, motif))
    REP <- c(REP, ligne_rep(b, "ecartee", rep(NA_real_, N_STATS), rep(NA_real_, length(LIGNES))))
    next
  }
  ajoute("ok")
  reg <- code_regime(res$ajustement$delta)
  if (inherits(f72, "error") || !identical(f72$delta, res$ajustement$delta)) echecs_b$e1 <- c(echecs_b$e1, b)
  ajoute(paste0("reg|", reg))
  # (b) et T1.
  bt <- res$bootstrap
  if (!identical(names(bt$p_mc), names(USP_CATALOGUE_MC)) || !identical(names(bt$motif_mc), names(USP_CATALOGUE_MC)))
    echecs_b$b <- c(echecs_b$b, b)
  for (s in names(USP_CATALOGUE_MC)) {
    p <- unname(bt$p_mc[s])
    if (is.finite(p)) {
      ajoute(sprintf("mc|%s|%s|n", s, reg))
      if (p < ALPHA) ajoute(sprintf("mc|%s|%s|k1", s, reg))
      if (p < ALPHA2) ajoute(sprintf("mc|%s|%s|k2", s, reg))
    } else {
      m <- unname(bt$motif_mc[s])
      if (is.na(m) || !nzchar(m)) { echecs_b$b <- c(echecs_b$b, b); m <- "(aucun motif)" }
      ajoute(sprintf("mmc|%s|%s", s, nettoyer_cle(m)))
    }
  }
  # (c) et T2.
  tab <- engine_table_tests(res)
  if (!identical(tab$test, LIGNES)) echecs_b$c <- c(echecs_b$c, b)
  for (k in seq_len(nrow(tab))) {
    li <- nettoyer_cle(tab$test[k])
    ajoute(sprintf("l|%s|n", li))
    ajoute(sprintf("l|%s|t|%s", li, tab$type[k]))
    if (!is.na(tab$commentaire[k]) && startsWith(tab$commentaire[k], "TEST INOPERANT")) ajoute(sprintf("l|%s|inop", li))
    ajoute(sprintf("l|%s|nat|%s", li, classe_nature(tab$nature_p[k])))
    ajoute(sprintf("l|%s|v|%s", li, nettoyer_cle(tab$verdict[k])))
    p <- tab$p_retenue[k]
    if (is.finite(p)) {
      ajoute(sprintf("l|%s|np", li))
      if (p < ALPHA) ajoute(sprintf("l|%s|k1", li))
      if (p < ALPHA2) ajoute(sprintf("l|%s|k2", li))
    }
  }
  # (e4) largeur relative de l'IC bootstrap 90 % (ligne lue par #72).
  w <- tab$estimation[match(LIGNE_IC, tab$test)]
  if (is.finite(w)) {
    ajoute("ic|n")
    if (w > 0.50) ajoute("ic|k50")
    if (w > 0.80) ajoute("ic|k80")
  }
  # T3 : famille H, rapport de vraisemblance, bootstrap interne.
  for (ct in res$controles) if (startsWith(ct$famille, "H."))
    ajoute(sprintf("h|%s|%s", nettoyer_cle(ct$test), nettoyer_cle(ct$verdict)))
  for (bn in names(LIGNES_LR)) {
    lr <- res$lr_delta[[bn]]
    # LR non calculable sur les donnees observees de la replication (#161) :
    # replication traitee, ligne LR non applicable (avant #161, erreur de
    # run_engine() et replication ecartee). Comptee sous lrnc|borne, ni dans
    # lrm| (motifs Monte-Carlo) ni dans lrechec| (n_echec NA, aucune
    # replication interne tentee ; une cle COMPTE doit rester finie).
    if (!is.finite(lr$lr)) { ajoute(paste0("lrnc|", bn)); next }
    if (is.finite(lr$p_mc)) {
      ajoute(sprintf("lr|%s|%s|n", bn, reg))
      if (lr$p_mc < ALPHA) ajoute(sprintf("lr|%s|%s|k1", bn, reg))
      if (lr$p_mc < ALPHA2) ajoute(sprintf("lr|%s|%s|k2", bn, reg))
    } else ajoute(sprintf("lrm|%s|%s", bn, nettoyer_cle(if (is.na(lr$motif_mc)) "(aucun motif)" else lr$motif_mc)))
    ajoute(paste0("lrechec|", bn), lr$n_echec)
  }
  perdu <- B_BOOT - length(bt$sigma_boot)
  ajoute("bperdu", perdu)
  if (perdu > 0) ajoute("bperdu_rep")
  ajoute("rechec", bt$n_echec_restreint)
  # Valeurs brutes (ligne REP) : p_mc dans l'ordre du catalogue, p retenues
  # dans l'ordre de LIGNES (NA si la ligne manque, controle (c)).
  REP <- c(REP, ligne_rep(b, reg, unname(bt$p_mc[names(USP_CATALOGUE_MC)]), tab$p_retenue[match(LIGNES, tab$test)]))
}
t_rep <- as.numeric(difftime(Sys.time(), t_r, units = "secs"))
n_rep <- FIN - DEBUT + 1L
liste_b <- function(v) if (length(v)) paste0(" : r\u00e9plication(s) ", paste(utils::head(unique(v), 20), collapse = ", "),
                                              if (length(unique(v)) > 20) ", ..." else "") else ""
controle(!length(echecs_b$b), sprintf("(b) noms de bootstrap$p_mc et motif_mc = les %d du catalogue, p_mc absente avec motif, \u00e0 chaque r\u00e9plication trait\u00e9e%s",
                                      N_STATS, liste_b(echecs_b$b)))
controle(!length(echecs_b$c), sprintf("(c) %d lignes, m\u00eames libell\u00e9s et m\u00eame ordre que J1 observ\u00e9, \u00e0 chaque r\u00e9plication trait\u00e9e%s",
                                      N_LIGNES, liste_b(echecs_b$c)))
ec <- grep("^ecart\\|", names(cpt), value = TRUE)
controle(all(nzchar(sub("^ecart\\|[0-9]+\\|", "", ec))),
         sprintf("(d) r\u00e9plications \u00e9cart\u00e9es list\u00e9es en T3 avec leur motif (%d)", length(ec)))
controle(!length(echecs_b$e1), sprintf("(e1) \u03b4\u0302* de run_engine() identique \u00e0 celui du code de #72 (usp_ajuster(x, y*)), \u00e0 chaque r\u00e9plication trait\u00e9e%s",
                                       liste_b(echecs_b$e1)))
COMPLET <- is.na(OPT_TRANCHE)
C72 <- if (COMPLET) controles_72(cpt, OPT_R, OPT_JEU) else {
  x <- list(ok = NA, texte = "non \u00e9valu\u00e9 dans une tranche (effectifs partiels) : \u00e9valu\u00e9 par --combiner")
  list(e3 = x, e4 = x)
}
for (k in c("e3", "e4")) {
  lib <- sprintf("(%s) %s contre le tableau de #72 :", k,
                 if (k == "e3") "effectifs des r\u00e9gimes" else "largeur de l'IC bootstrap")
  if (!is.na(C72[[k]]$ok)) controle(C72[[k]]$ok, paste(lib, C72[[k]]$texte)) else
    CONTROLES <- c(CONTROLES, paste(lib, C72[[k]]$texte))
}

# --- Sortie ------------------------------------------------------------------------------
PAR <- sprintf("jeu=%s;R=%d;graine_jeux=%.0f;graine_boot=%.0f;B=%d;methode=%s;segment=%d;annexe=%s;nature=%s;alpha=%g;theta_equiv=%g",
               OPT_JEU, OPT_R, GRAINE_JEUX, GRAINE_BOOT, B_BOOT, METHODE, SEGMENT, ANNEXE, NATURE, ALPHA, THETA_EQUIV)
CTX <- c(
  jeu = JEU$libelle,
  modele = sprintf("\u03b4\u0302 = %.6g ; \u03b3\u0302 = %.6g ; \u03b2\u0302 = %.6g ; \u03c3\u0302 = %.6g ; \u03c0\u0302 constant : %s",
                   FIT0$delta, FIT0$gamma, FIT0$beta, FIT0$sigma, usp_regime(FIT0$delta, X)$pi_constant),
  configuration = sprintf(paste("m\u00e9thode %s, segment %d de l'annexe %s, donn\u00e9es %s, \u03b1 = %g, theta_equiv = %g,",
                                "\u03c3 standard = %g, bar\u00e8me %s, B = %d"),
                          METHODE, SEGMENT, ANNEXE, NATURE, ALPHA, THETA_EQUIV, SIGMA_STD, BAREME, B_BOOT),
  sigma_usp = sprintf("%.6g", PARAM0$sigma_usp),
  graines = sprintf(paste("jeux simul\u00e9s : un flux sous %.0f (chemin de #72) ; bootstrap et rapport de vraisemblance",
                          "de la r\u00e9plication b : %.0f + b ; J1 observ\u00e9 (a) : %.0f"), GRAINE_JEUX, GRAINE_BOOT, GRAINE_BOOT),
  collisions = COLLISIONS,
  generateur = paste(ENGINE_RNG_KIND, collapse = ", "),
  commit = COMMIT,
  plateforme = plateforme_calcul(),
  empreintes = EMPREINTES,
  reference = TXT_A,
  tailles = txt_tailles(TAILLES))
stopifnot(identical(names(CTX), names(LIBELLES_CONTEXTE)))
tb <- tableaux(cpt, STATS_Q, LIGNES)
S <- c(sprintf("## Calibration des p-values Monte-Carlo \u00e0 T = 8, jeu %s (issue #166)", OPT_JEU), "",
       sprintf("Param\u00e8tres : %s", PAR), "",
       "### T0 -- contexte", "",
       entete_md(c("Grandeur", "Valeur")),
       lignes_contexte(CTX),
       ligne_md("R\u00e9plications", sprintf("%d (trait\u00e9es ici : %d \u00e0 %d)", OPT_R, DEBUT, FIN)),
       ligne_md("Dur\u00e9e (s)", sprintf("contr\u00f4les %.1f ; r\u00e9plications %.1f (%.1f s par r\u00e9plication) ; total %.1f",
                                         t_controle, t_rep, t_rep / n_rep,
                                         as.numeric(difftime(Sys.time(), t_debut, units = "secs")))),
       ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", if (length(INTEGRITE)) "\u00c9CHEC" else "OK"), "")
if (!COMPLET) S <- c(S, "Tableaux PARTIELS (une tranche) : combiner les sorties des K tranches par --combiner.", "")
S <- c(S, aide_lecture(), tb$lignes,
       "### Contr\u00f4les d'int\u00e9grit\u00e9", "", paste("-", CONTROLES), "",
       sprintf("Bilan : %s", if (length(INTEGRITE)) sprintf("\u00c9CHEC (%d contr\u00f4le(s))", length(INTEGRITE)) else "OK"), "")
ecrire_console(S)
ecrire_console(c(paste0("PARAMETRES\t", PAR), sprintf("TRANCHE\t%d\t%d", DEBUT, FIN),
                 sprintf("CONTEXTE\t%s\t%s", names(CTX), CTX),
                 paste0("STATS\t", paste(sprintf("%s=%s", names(STATS_Q), STATS_Q), collapse = "\t")),
                 paste0("LIGNES\t", paste(LIGNES, collapse = "\t")),
                 paste0("REPCOLS\t", paste(REPCOLS, collapse = "\t")),
                 sprintf("DUREE\t%.3f\t%.3f\t%d", t_controle, t_rep, n_rep),
                 paste0("INTEGRITE\t", if (length(INTEGRITE)) "ECHEC" else "OK"),
                 sprintf("NCOMPTES\t%d", length(cpt)),
                 sprintf("COMPTE\t%s\t%.0f", names(cpt), cpt),
                 sprintf("NREP\t%d", length(REP)),
                 paste0("REP\t", REP),
                 sprintf("FIN\t%d", length(cpt))))
quit(status = if (length(INTEGRITE)) 1L else 0L)
