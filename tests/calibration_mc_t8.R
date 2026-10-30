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
#    T1     : les 31 statistiques de USP_CATALOGUE_MC ; frequence de
#             p_mc < 0,10 et de p_mc < 0,05, que la p_mc soit retenue ou non,
#             parmi les replications ou elle est calculee ;
#    T1 bis : la meme mesure par regime de delta chapeau* du reajustement
#             (bord 1 : pi chapeau* constant ; bord 0 ; interieur) ;
#    T2     : niveau des verdicts des 47 lignes : frequence de p retenue
#             < alpha et < alpha/2 parmi les replications ou la ligne a une p
#             retenue (niveau conditionnel ; regles R1, R3, R4, R7 et R13
#             comprises) ; ligne ESD (diagnostic par decision depuis #304,
#             sans p-value ni verdict) : frequence de k chapeau >= 1 et de
#             k chapeau = 2 (colonne estimation) sur les replications
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
#    - ligne ESD (diagnostic par decision depuis #304 : verdict INFO ; k
#      chapeau lu dans la colonne estimation, l'ancien verdict ALERTE ou
#      ECHEC etant k chapeau >= 1, ECHEC k chapeau = 2) : k chapeau >= 1
#      contre 0,10, niveau nominal de la procedure de Rosner (valeurs
#      critiques a 1 - alpha/(2 n_i)), exactitude non etablie a T = 8 ;
#      k chapeau = 2 sans reference.
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
#  Multiplicite : 124 intervalles en T1 sur J1 et J2 (31 statistiques x 2
#  seuils x 2 jeux), environ 6 exclusions attendues par hasard.
#
#  Controles d'integrite (code de sortie 1 si l'un echoue) :
#    (a)  J1 observe par run_engine(seed = 20260831) (executer_cas("premium")
#         de tests/outils_tests.R) conforme a tests/reference/premium.rds par
#         comparer_objets(), apres neutraliser_instables() (meme comparaison
#         que tests/test_reproductibilite.R) ;
#    (b)  les noms de res$bootstrap$p_mc et de res$bootstrap$motif_mc sont
#         exactement les 31 de USP_CATALOGUE_MC, dans son ordre, a chaque
#         replication ; toute p_mc absente porte un motif ;
#    (c)  47 lignes par replication, de memes libelles et dans le meme ordre
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
#  plus des controles de coherence du script : 31 statistiques au catalogue ;
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
#  Lecture conjointe (#297, specification docs/specifications/
#  fk-lecture-conjointe.md, par. 5 ; decisions du mainteneur du 25/10/2026) :
#  depuis #297, usp_tests() pose apres ses lignes une ligne de diagnostic par
#  famille d'au moins deux tests (B. a G.) et une ligne globale (LC)
#  (engine_p_famille()) ; leur presence depend des donnees (exception a
#  l'invariant I5). Le script les traite a part :
#    - LIGNES (T2, controle (c)) : les 47 lignes hors lecture conjointe, de
#      memes libelles et dans le meme ordre a chaque replication ;
#    - par replication et par cle de famille (B. a G., LC) : etat (1 : ligne
#      et p ; 2 : ligne sans p, B effectif de famille < 50, texte T-3b ; 0 :
#      pas de ligne, k <= 1 ; -1 : incoherence ; -2 : bootstrap$stats_boot
#      absent), k, B effectif de famille, p, err_mc, m_obs, plus petite p_mc
#      des membres (colonnes REP etf:, kf:, bf:, pf:, ef:, sf:, minf:) ; comptes
#      f|cle|... (K-F1, composition, K-F2, K-F4), mult|ae et mult|e (au moins
#      une ALERTE ou un ECHEC, au moins un ECHEC, parmi les lignes de type
#      test), mult|ae_npr et mult|e_npr (idem, lignes de sens "ne pas
#      rejeter" seules), fr|statistique|... (|p_mc - s| < 2 err_mc par
#      statistique du catalogue, K-F4) ; colonnes REP e_mc: et B_eff: (err_mc
#      et B effectif de chaque statistique, controlees par --combiner) ;
#    - controle (k) : etats 0, 1 ou 2 seulement, coherents avec k et le B
#      effectif recomptes par le script (etat -2 : stats_boot absent, jamais
#      confondu avec une ligne absente pour k <= 1 ; INTEGRITE ECHEC) ;
#    - controle (K-F3), sur la premiere replication traitee de chaque
#      execution : p de famille, m_obs, err_mc et k recalcules dans le script
#      en R de base (fk_recalcul(), copie declaree de
#      tests/calibration_mc_mw_t8.R, ecriture independante
#      d'engine_p_famille()), identical() aux champs des lignes ;
#    - controle (t297) : texte du critere de Fk (par. 5.3) reporte SANS
#      MODIFICATION dans TEXTE_CRITERE_FK et present dans la specification ;
#    - T2 etendu aux lignes ajoutees (diagnostics, INFO).
#  --combiner ... --campagne 297 [--niveau Lk] [--journal JOURNAL.md] : J1 et
#  J2 dans une meme combinaison (comptes et controles par jeu), puis
#  <AAAAMMJJ>-issue297-calibration-famille-ln.md (provenance, critere de Fk,
#  evaluation mecanique de K-F1 a K-F4 et des profils Phi sans conclure,
#  tables T-F1 a T-F4, puis T1 a T3 de chaque jeu), son brut
#  -calibration-famille-ln-brut.tsv (lignes REP des deux jeux, colonne jeu)
#  et -journal-combinaison-ln.md. --niveau Lk : R de J1 et de J2 fixes par
#  le plan de Fk (par. 5.2 : L0 et L1 2 000 et 2 000 ; L2 et L3 1 000 et
#  2 000 ; L4 1 000 et 1 000) ; --ecrire exige --niveau, --journal (une
#  ligne "- Sortie <nom> : md5 <md5>" par sortie, ligne "- Niveau : Lk") et
#  --brut. Le JOURNAL de la campagne est copie par la combinaison de
#  tests/calibration_mc_mw_t8.R (--campagne 297), pas ici.
#  --essai (M41 (c), meme semantique que tests/calibration_mc_mw_t8.R et
#  tests/p_conditionnelle_regime_t8.R) : execution d'essai, R par defaut 2
#  (au lieu de 2 000), marquee dans le contexte (champ essai) et au
#  markdown, sortie non versionnable : --combiner la combine mais --ecrire la
#  refuse. Sans --essai, une execution REFUSE (code 1, avant tout calcul) un
#  commit non propre ou un code hors du depot (motifs_non_versionnable()).
#  --sortie-tranche FICHIER : sortie complete (markdown et lignes machine)
#  ecrite dans FICHIER, HORS du depot, jamais ecrase, a la fin du calcul
#  (format de tests/outillage/lancer_tranches.sh : derniere ligne FIN ; pas
#  de --reprendre, une sortie interrompue est recalculee) ; le markdown est
#  aussi imprime sur la console.
#  --prevol [--unites 5] : cout des controles d'une execution, puis debit a
#  1, 2, 3 et 4 processus concurrents (sous-processus --prevol-unite, chacun
#  traitant UNITES replications de J1 puis de J2 par run_engine() complet) ;
#  imprime c_J1, c_J2 (s par replication, un processus), P_k et la ligne
#  machine PREVOL_LN, lue par "tests/calibration_mc_mw_t8.R --prevol
#  --campagne 297 --prevol-ln FICHIER". Rien d'ecrit.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/calibration_mc_t8.R [--jeu J1|J2] [--R 2000] [--tranche i/K]
#          [--essai] [--sortie-tranche FICHIER]
#      Rscript tests/calibration_mc_t8.R --combiner f1 f2 ... | DOSSIER
#          [--campagne 166|297 [--niveau Lk] [--journal JOURNAL.md]]
#          [--ecrire [--remplacer] | --sortie DOSSIER] [--brut FICHIER]
#      Rscript tests/calibration_mc_t8.R --prevol [--unites 5]
#  (--prevol-unite --b b1:b2 : mode interne de --prevol.) DOSSIER : fichiers
#  ln-J<1|2>-R<R>-<b1>-<b2>.txt du plan de la campagne 297 (R dans le nom :
#  deux niveaux qui different par R ne se melangent pas dans un dossier).
#  Pas d'option de B ni de graine : B = 999 et les graines sont celles du
#  protocole (decision Q1 : aucun levier).
#  --tranche i/K : ne traite que la i-eme de K tranches de replications
#  consecutives. Chaque execution (tranche ou non) imprime T0, les tableaux
#  (PARTIELS pour une tranche), les controles, puis des lignes machine :
#  PARAMETRES, TRANCHE, CONTEXTE (contenu de T0 hors durees et hors bornes de
#  la tranche, dont la plateforme de calcul et les empreintes md5 du code),
#  STATS, LIGNES, REPCOLS (colonnes des lignes REP), DUREE, INTEGRITE (OK ou
#  ECHEC), NCOMPTES, les comptes bruts (COMPTE), NREP, une ligne REP par
#  replication (b, regime ou "ecartee", 31 p_mc dans l'ordre de STATS, 47 p
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
#  reg72 = rep, l|ligne|n = ok pour les 47 lignes, n + absentes = ok pour les
#  31 p_mc, lignes REP = rep, b des REP = debut..fin, regimes et ecartees des
#  REP = comptes, n, k1 et k2 des 31 p_mc (par regime) et des 47 p retenues
#  recomptes sur les lignes REP = comptes ; au total, somme des rep = R) ;
#  les controles (e3) ou (e4) en echec.
#  --ecrire (--combiner seulement) : ecrit
#  docs/tableaux/<AAAAMMJJ>-issue166-calibration-<jeu>.md, date du jour de la
#  combinaison ; REFUSE (code 1, rien d'ecrit) si le commit des tranches, ou
#  celui de la combinaison elle-meme, porte "(arbre de travail modifie)",
#  "(script non suivi)" ou "inconnu", ou si tests/outils_tests.R ou le script
#  executes (par les tranches ou par la combinaison) n'etaient pas ceux du
#  depot (empreintes : "hors depot" ; empreintes du combinateur imprimees en
#  T0) ; le refus qui tient a la combinaison elle-meme (commit, empreintes)
#  et l'absence de docs/tableaux/ sont evalues des l'analyse des options,
#  avant tout calcul, puis de nouveau avant d'ecrire (#205). --sortie
#  DOSSIER : meme nom dans DOSSIER, qui doit etre HORS du depot (un dossier
#  sous la racine du depot est refuse : --ecrire est le seul
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
#  Recette : --essai (R = 2) rend le code 0 en moins d'une minute (mesure du
#  compte rendu de #166, alors --R 2 ; ligne Duree de T0).
#  Fonctions reprises par copie declaree (ces scripts executent leur calcul au
#  chargement et ne peuvent pas etre sources) :
#    - de tests/taux_franchissement_reperes.R : lire_option(), ligne_md(),
#      entete_md(), ecrire_console(), lire_j2() (copies) ; lire_comptes() et
#      refuser() (copies adaptees : lignes STATS, LIGNES, REPCOLS, DUREE, REP) ;
#      bornes d'une tranche et combinaison des comptes (copies) ;
#    - de tests/puissance_t8.R : num(), txt_ic() (copies), ic_cp() (copie,
#      niveau fixe a 95 %), analyse de --combiner suivie d'options et
#      ecrire_fichier() (copies adaptees : nom du fichier, refus de --ecrire ;
#      ecrire_fichier() est devenue ecrire_fichiers() dans tests/puissance_t8.R, #173),
#      tailles des suites, de Smirnov et de Mann-Kendall par enumeration
#      (reprises dans lois_discretes()).
#  plateforme_calcul() et empreintes_code() sont copiees (#171) dans
#  tests/taux_franchissement_reperes.R et tests/puissance_t8.R
#  (plateforme_calcul() aussi dans tests/constats_puissance_t8.R).
#  commit_depot() et motifs_non_versionnable() : definition unique dans
#  tests/outils_tests.R (#205).
#  Code de sortie : 0 si les controles d'integrite tiennent, 1 sinon ; en
#  mode --combiner, 0 si la combinaison est acceptee, 1 si elle est refusee.
###############################################################################

t_debut <- Sys.time()

# --- Options (lire_option() : copie de tests/taux_franchissement_reperes.R) ---
ARGS <- commandArgs(trailingOnly = TRUE)
OPTIONS_APRES_COMBINER <- c("--ecrire", "--remplacer", "--sortie", "--brut", "--campagne", "--niveau", "--journal")
i_comb <- match("--combiner", ARGS)
FICHIERS_COMB <- if (is.na(i_comb)) character(0) else {
  reste <- ARGS[-seq_len(i_comb)]
  # les options --ecrire, --remplacer, --sortie DOSSIER, --brut FICHIER,
  # --campagne, --niveau et --journal peuvent suivre la liste
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
OPT_ESSAI   <- "--essai" %in% ARGS
OPT_PREVOL  <- "--prevol" %in% ARGS
OPT_UNITE   <- "--prevol-unite" %in% ARGS
OPT_JEU     <- lire_option("--jeu", "J1")
# --essai (M41 (c)) : R reduit, 2 par defaut.
OPT_R       <- suppressWarnings(as.integer(lire_option("--R", if (OPT_ESSAI) "2" else "2000")))
OPT_TRANCHE <- lire_option("--tranche", NA_character_)
OPT_ECRIRE  <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_SORTIE  <- lire_option("--sortie", NA_character_)
OPT_BRUT    <- lire_option("--brut", NA_character_)
OPT_SORTIE_TR <- lire_option("--sortie-tranche", NA_character_)
OPT_CAMPAGNE <- lire_option("--campagne", "166")
OPT_NIVEAU  <- lire_option("--niveau", NA_character_)
OPT_JOURNAL <- lire_option("--journal", NA_character_)
# --unites : 5 replications de J1 et de J2 par processus au pre-vol (audit
# m2 de #297 : c_J2 depend du regime de delta chapeau* ; environ 10 min).
OPT_UNITES  <- suppressWarnings(as.integer(lire_option("--unites", "5")))
OPT_B       <- lire_option("--b", NA_character_)
MODE_LN <- if (!is.na(i_comb)) "combiner" else if (OPT_UNITE) "unite" else if (OPT_PREVOL) "prevol" else "execution"
if (sum(!is.na(i_comb), OPT_UNITE, OPT_PREVOL) > 1L) stop("un mode et un seul : --combiner, --prevol")
if (MODE_LN != "execution" && (OPT_ESSAI || !is.na(OPT_SORTIE_TR) || !is.na(OPT_TRANCHE)))
  stop("--essai, --sortie-tranche et --tranche sont reserves a une execution (ni --combiner, ni --prevol)")
if (MODE_LN != "combiner" && any(c("--campagne", "--niveau", "--journal") %in% ARGS))
  stop("--campagne, --niveau et --journal sont reserves a --combiner")
if (!OPT_CAMPAGNE %in% c("166", "297")) stop("--campagne : 166 ou 297")
if (OPT_CAMPAGNE != "297" && (!is.na(OPT_NIVEAU) || !is.na(OPT_JOURNAL))) stop("--niveau et --journal : reserves a --campagne 297")
if (!is.na(OPT_NIVEAU) && !OPT_NIVEAU %in% paste0("L", 0:4)) stop("--niveau : L0 a L4 (plan de Fk, par. 5.2)")
if (MODE_LN != "prevol" && "--unites" %in% ARGS) stop("--unites : reserve a --prevol")
if (MODE_LN != "unite" && !is.na(OPT_B)) stop("--b : reserve au mode interne --prevol-unite")
if (is.na(OPT_UNITES) || OPT_UNITES < 1L) stop("--unites : entier >= 1")
if (!OPT_JEU %in% c("J1", "J2")) stop("--jeu : J1 ou J2")
if (!is.finite(OPT_R) || OPT_R < 1L) stop("--R : entier >= 1")
if (OPT_ECRIRE && !is.na(OPT_SORTIE)) stop("--ecrire et --sortie sont exclusifs")
if (OPT_REMPLACER && !OPT_ECRIRE) stop("--remplacer : reserve a --ecrire (remplacement d'un tableau suivi par git, #173)")
if ((OPT_ECRIRE || !is.na(OPT_SORTIE) || !is.na(OPT_BRUT)) && is.na(i_comb))
  stop("--ecrire, --sortie et --brut sont reserves a --combiner (tableaux produits par --combiner)")
if (!is.na(OPT_SORTIE) && !dir.exists(OPT_SORTIE)) stop("--sortie : dossier introuvable : ", OPT_SORTIE)
# Campagne 297 : --ecrire exige le niveau du plan, le JOURNAL et la copie
# brute hors du depot (comme tests/calibration_mc_mw_t8.R).
if (OPT_ECRIRE && OPT_CAMPAGNE == "297" && is.na(OPT_NIVEAU)) stop("--ecrire : --niveau Lk obligatoire avec --campagne 297")
if (OPT_ECRIRE && OPT_CAMPAGNE == "297" && is.na(OPT_JOURNAL)) stop("--ecrire : --journal FICHIER obligatoire avec --campagne 297")
if (OPT_ECRIRE && OPT_CAMPAGNE == "297" && is.na(OPT_BRUT)) stop("--ecrire : --brut FICHIER obligatoire avec --campagne 297")

# --- Protocole (constantes ; aucune option : decision Q1, aucun levier) -------
METHODE <- "premium"; SEGMENT <- 1; ANNEXE <- "II"; NATURE <- "brutes"
ALPHA <- 0.10; ALPHA2 <- ALPHA / 2; THETA_EQUIV <- 0.10
SEUILS <- c(ALPHA, ALPHA2)
B_BOOT <- 999L
GRAINE_JEUX <- 20260927
GRAINE_BOOT <- 20260831
T_ <- 8L
# 31 statistiques et 47 lignes depuis les retraits de Ljung-Box (1) sur
# ratios bruts (entree LB1r, #303), de Shapiro-Wilk a loi nulle simulee, de
# Ljung-Box (1) et de Box-Pierce (2) (entrees LB1 et BP2, #302).
N_STATS <- 31L
N_LIGNES <- 47L
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
# commit_depot() et motifs_non_versionnable() : tests/outils_tests.R (#205).
# Plateforme de calcul (#171) : R, systeme, machine, BLAS, LAPACK. Champ du
# contexte : des tranches calculees sur des plateformes differentes ne se
# combinent pas (certains comptes dependent de l'optimiseur : regime de
# delta chapeau*, reajustements du bootstrap). BLAS et LAPACK cites par le
# NOM de leur bibliotheque, sans chemin absolu (D-a de #242, campagne 297 ;
# comme tests/calibration_mc_mw_t8.R).
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(basename(extSoftVersion()[["BLAS"]])), txt(basename(La_library())), txt(La_version()))
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
# Gardes anticipees de --ecrire (#205), des l'analyse des options, avant les
# lois discretes et la lecture des tranches : commit et code de la
# combinaison (commit courant propre, code du depot) et dossier
# docs/tableaux/ ; memes refus qu'au moment d'ecrire, ou ils sont repris
# (l'etat du depot peut changer entre-temps), avec ceux des tranches, lus
# dans leurs fichiers.
if (OPT_ECRIRE) {
  nv0 <- motifs_non_versionnable(commit_depot("tests/calibration_mc_t8.R"),
                                 empreintes_code("tests/calibration_mc_t8.R", SCRIPT_72), "de la combinaison")
  if (length(nv0)) {
    message("--combiner : REFUS -- --ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv0, collapse = " ; "),
            " -- relancer sur un arbre propre, ou utiliser --sortie DOSSIER hors du depot")
    quit(status = 1L)
  }
  if (!dir.exists(file.path(RACINE, "docs", "tableaux")))
    stop("dossier de sortie introuvable : ", file.path(RACINE, "docs", "tableaux"))
}
# Execution (tranche ou d'un seul tenant) : sortie versionnable seulement sur
# un commit propre et le code du depot, sinon refus avant tout calcul, sauf
# --essai (M41 (c), meme regle que tests/calibration_mc_mw_t8.R) ;
# --sortie-tranche hors du depot, jamais ecrasee.
if (MODE_LN == "execution") {
  if (!OPT_ESSAI) {
    nvt <- motifs_non_versionnable(commit_depot("tests/calibration_mc_t8.R"),
                                   empreintes_code("tests/calibration_mc_t8.R", SCRIPT_72), "de la sortie")
    if (length(nvt)) {
      message("sortie refusee : ", paste(nvt, collapse = " ; "), " -- lancer dans un git worktree au commit propre cite, ou --essai")
      quit(status = 1L)
    }
  }
  if (!is.na(OPT_SORTIE_TR)) {
    if (!dir.exists(dirname(OPT_SORTIE_TR))) stop("--sortie-tranche : dossier introuvable")
    if (sous_depot(dirname(OPT_SORTIE_TR))) stop("--sortie-tranche : chemin sous le depot refuse")
    if (file.exists(OPT_SORTIE_TR)) stop("--sortie-tranche : fichier existant, jamais ecrase")
  }
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

# Classes de #166 et #206 contre une reference (rho_F, par. 5.3) : copie de
# lecture() de tests/calibration_mc_mw_t8.R, renommee (ce script a sa propre
# lecture(), aide a la lecture de T1 et T2) ; valeurs non arrondies.
D_IC <- 5L
CLASSES <- c("compatible", "\u00e9cart mineur", "\u00e9cart non tranch\u00e9", "distorsion mat\u00e9rielle")
lecture_classe <- function(k, n, ref) {
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
txt_lec <- function(c_) sprintf("%s %s", num(c_$taux, D_IC), txt_ic(c_$ci, D_IC))
txt_classe <- function(c_) if (c_$disj) sprintf("%s (**%s**)", c_$classe, c_$cote) else c_$classe
liste_cel <- function(x, n = 10) if (!length(x)) "aucune" else
  paste(c(utils::head(x, n), if (length(x) > n) sprintf("... (%d en tout)", length(x))), collapse = " ; ")
# Cles des lignes de lecture conjointe de usp_tests() (#297) : familles B. a
# G. (G. sans test dans les cas de reference : etat 0 attendu), puis la ligne
# globale.
FAM_LN <- c("B.", "C.", "D.", "E.", "F.", "G.", PREFIXE_LECTURE_CONJOINTE)
# Specification de Fk (#297) : critere K-F1 a K-F4 et profils (controle
# (t297)) ; presence d'un bloc de lignes, a l'identique (copie de
# present_bloc() de tests/calibration_mc_mw_t8.R).
SPEC_FK <- file.path("docs", "specifications", "fk-lecture-conjointe.md")
present_bloc <- function(bloc, txt) {
  i <- which(txt == bloc[1])
  any(vapply(i, function(k) k + length(bloc) - 1L <= length(txt) && identical(txt[k:(k + length(bloc) - 1L)], bloc), logical(1)))
}
CODE_ETAT <- c(L = 1, N = 2, A = 0, X = -1, S = -2)
# Libelle d'une ligne de lecture conjointe dans T2 : champ test de
# engine_p_famille() (le meme pour toutes les familles), suivi de la cle.
lib_ligne_fk <- function(f) if (f == FAM_LN[length(FAM_LN)])
  sprintf("p globale (minP, lecture conjointe de la batterie) [%s]", f) else sprintf("p de famille (minP, lecture conjointe) [%s]", f)

###############################################################################
#  LECTURE CONJOINTE (#297) : CRITERE DE FK, MEMBRES, ETATS, CONTROLE K-F3
###############################################################################
# Copie declaree de tests/calibration_mc_mw_t8.R (memes corps) :
# TEXTE_CRITERE_FK, RHO_F, fk_champ(), fk_num(), fk_membres(), fk_etats(),
# fk_etats_ok(), fk_recalcul(), profils_fk() ; CLASSES, lecture_classe()
# (copie de lecture() de ce script), txt_lec(), txt_classe() et liste_cel()
# (copies).
# Texte du critere de Fk (specification de Fk, par. 5.3, approuve tel quel
# par le mainteneur, Q-D1-Fk-8), reporte SANS MODIFICATION (controle (t297))
# et au T0 des tableaux de la campagne 297.
TEXTE_CRITERE_FK <- c(
  "### 5.3 Crit\u00e8re, fix\u00e9 avant toute ex\u00e9cution (report\u00e9 sans modification dans les scripts et au T0)",
  "",
  "**Grandeurs.**",
  "- Pour chaque jeu simul\u00e9 d, chaque famille f dont la ligne est pr\u00e9sente (k_f \u2265 2, ou \u2265 1 sous Q-D1-Fk-2 (b)) et chaque \u03b1 \u2208 {0,10 ; 0,05} : D = 1 si p_f,d < \u03b1.",
  "- Une p de famille absente (T-3b) compte comme un non-rejet, compt\u00e9e \u00e0 part (#242).",
  "- \u03c4_f(\u03b1) = (\u03a3 D) / n_f, o\u00f9 n_f est le nombre de jeux o\u00f9 la ligne est pr\u00e9sente. IC de Clopper-Pearson \u00e0 95 %, calcul\u00e9 sur les valeurs non arrondies.",
  "- La composition de la famille varie avec le jeu. Elle est rapport\u00e9e : distribution de k_f et part des jeux o\u00f9 la ligne existe.",
  "",
  "**R\u00e9f\u00e9rence \u03c1_F(\u03b1)** : la taille du test de Monte-Carlo id\u00e9al \u00e0 B_eff = 999, pour une statistique sans atome, P((1 + K)/1000 < \u03b1) = (\u23081 000 \u03b1\u2309 \u2212 1)/1 000. Elle vaut **0,099** et **0,049** [V, arithm\u00e9tique]. Avec des atomes de m, nombreux pr\u00e8s du plancher, le test id\u00e9al est plus conservateur : \u03c1_F en est un **majorant** [V, raisonnement du \u00a7 2.1]. La masse de p_f au plancher 1/(B_eff + 1) est rapport\u00e9e.",
  "",
  "**Classes**, celles de #166 et #206 avec \u03c1_F :",
  "- *compatible* : \u03c1_F \u2208 IC ;",
  "- *\u00e9cart mineur* : estimation dans [\u03c1_F/2 ; 3\u03c1_F/2] ;",
  "- *non tranch\u00e9* : estimation hors de la bande, IC qui la recoupe ;",
  "- *distorsion mat\u00e9rielle* : IC disjoint de la bande, c\u00f4t\u00e9 lib\u00e9ral ou conservateur.",
  "",
  "**Conditions** (\u00e9valu\u00e9es m\u00e9caniquement, sans conclusion dans le tableau) :",
  "- **K-F1** (principal) : classe de \u03c4_f(\u03b1) pour chaque (jeu ou loi, famille ou globale, \u03b1).",
  "- **K-F2** (descriptif, T4) : part des jeux \u00e0 au moins une ALERTE ou un ECHEC et \u00e0 au moins un ECHEC, sur les tests ; part des jeux \u00e0 p globale < \u03b1 ; par famille, part \u00e0 au moins un test membre \u00e0 p < \u03b1 contre part \u00e0 p_f < \u03b1.",
  "- **K-F3** (int\u00e9grit\u00e9) : les contr\u00f4les existants des deux scripts, plus un contr\u00f4le nouveau. Sur le premier jeu de chaque tranche, p_f et m_obs recalcul\u00e9s **dans le script**, en R de base, depuis `bootstrap$stats_boot`, `stats_obs`, le catalogue et les lignes, par une \u00e9criture ind\u00e9pendante d'`engine_p_famille()`, doivent \u00eatre `identical()` aux champs de la ligne. Un \u00e9chec met INTEGRITE \u00e0 ECHEC.",
  "- **K-F4** (fronti\u00e8re, descriptif) : par cl\u00e9 et pour chaque p de famille, la fr\u00e9quence sous H0 de |p \u2212 s| < 2 err_mc, pour s \u2208 {\u03b1 ; \u03b1/2} (T4 de #206, \u00e9tendu).",
  "- **Merz-W\u00fcthrich, remesure par cl\u00e9** : K1 \u00e0 K5 de la sp\u00e9cification de #206, \u00a7 5, inchang\u00e9s, avec ses annotations du 10 et du 11/10/2026. La cl\u00e9 Runs, dont la ligne est un diagnostic depuis #312, est lue \u00e0 titre descriptif.",
  "",
  "**Profils de lecture pour D2-Fk** (actuary propose, le mainteneur tranche) :",
  "",
  "| Profil | Condition | Lecture propos\u00e9e |",
  "|---|---|---|",
  "| \u03a60 | K-F3, ou K3 ou K4 de #206, en d\u00e9faut sans explication | Lecture suspendue ; mesure \u00e0 reprendre |",
  "| \u03a61 | Toutes les p de famille et la p globale compatibles ou en \u00e9cart mineur, aux deux \u03b1, sous chaque jeu et chaque loi | Diagnostic conserv\u00e9 ; niveau document\u00e9 comme constat ; **aucune d\u00e9cision** |",
  "| \u03a62 | Pas de distorsion mat\u00e9rielle, mais des \u00e9carts non tranch\u00e9s | Idem, avec les IC |",
  "| \u03a63 | Distorsion mat\u00e9rielle **conservatrice** seulement | Conserv\u00e9 ; la documentation dit qu'une p de famille \u00e9lev\u00e9e est une preuve faible ; aucune d\u00e9cision |",
  "| \u03a64 | Distorsion mat\u00e9rielle **lib\u00e9rale** pour au moins une (famille, jeu ou loi, \u03b1) | **D\u00e9cision du mainteneur** : garder avec une phrase fixe sourc\u00e9e par la mesure, retirer la ou les lignes, ou reformuler |",
  "| \u03a65 | Distorsions de c\u00f4t\u00e9s oppos\u00e9s entre jeux ou lois pour une m\u00eame famille | **D\u00e9cision du mainteneur** ; documenter, aucune correction calibr\u00e9e sur un seul plan |",
  "",
  "Pour les cl\u00e9s Merz-W\u00fcthrich, un \u03a03 ou un \u03a04 (profils de #206) donne lieu \u00e0 une **issue propos\u00e9e**, sans changement de verdict en Fk. L'issue est rapport\u00e9e \u00e0 D2-Fk \u00e0 titre d'information.")
# Reference rho_F (par. 5.3) : taille du test de Monte-Carlo ideal a
# B_eff = 999 pour une statistique sans atome, (ceil(1 000 alpha) - 1)/1 000.
RHO_F <- c(a10 = 0.099, a05 = 0.049)
stopifnot(identical(unname(RHO_F), (ceiling(round(1000 * c(0.10, 0.05), 9)) - 1) / 1000))
# Champs d'une ligne de resultat : caractere (NA si absent, de longueur
# differente de 1 ou NA) et numerique.
fk_champ <- function(l, nm) {
  v <- l[[nm]]
  if (is.null(v) || length(v) != 1L || is.na(v)) NA_character_ else as.character(v)
}
fk_num <- function(l, nm) {
  v <- l[[nm]]
  if (is.null(v) || length(v) != 1L) NA_real_ else suppressWarnings(as.numeric(v))
}
# Membres des familles, regle du par. 1.3 de la specification de Fk REECRITE
# ici (ecriture independante d'engine_p_famille()) : ligne de type "test",
# variante "principale", sens "ne pas rejeter", mc_nom renseigne et p_mc
# finie ; membres dedoublonnes par mc_nom, dans l'ordre des lignes ; famille
# = deux premiers caracteres du champ famille ; derniere cle de fam : ligne
# globale (reunion de tous les membres, familles d'un seul test comprises).
# Rend membres (cle -> mc_nom), minp (cle -> plus petite p_mc des membres,
# NA sans membre) et hors (prefixes de membres absents de fam).
fk_membres <- function(lignes, fam) {
  ch <- function(nm) vapply(lignes, fk_champ, "", nm)
  pm <- vapply(lignes, fk_num, 1, "p_mc")
  mc <- ch("mc_nom"); pref <- substr(ch("famille"), 1L, 2L)
  memb <- ch("type") %in% "test" & ch("variante") %in% "principale" & ch("sens") %in% "ne pas rejeter" &
    !is.na(mc) & is.finite(pm) & !ch("fonction") %in% "engine_p_famille"
  globale <- fam[length(fam)]
  sel <- lapply(fam, function(f) if (f == globale) memb else memb & pref %in% f)
  list(membres = stats::setNames(lapply(sel, function(k) unique(mc[k])), fam),
       minp = stats::setNames(vapply(sel, function(k) if (any(k)) min(pm[k]) else NA_real_, 1), fam),
       hors = setdiff(unique(pref[memb]), fam))
}
# Etat de chaque ligne de lecture conjointe d'un resultat (lignes de
# engine_p_famille(), cle = deux premiers caracteres de leur famille) :
#   S : bootstrap$stats_boot absent (aucune ligne de famille ne peut etre
#       calculee : jamais confondu avec A, reserve d'actuary du 25/10/2026) ;
#   A : pas de ligne et k <= 1 (Q-D1-Fk-2 (a)) ;
#   L : ligne de type diagnostic, INFO, k >= 2 (estim = k), B effectif de
#       famille >= B_MIN_DEGENERESCENCE, p, err_mc et m_obs finies ;
#   N : idem, B effectif < B_MIN_DEGENERESCENCE, p, err_mc et m_obs absentes
#       (texte T-3b) ;
#   X : tout autre cas (incoherence : ligne absente a k >= 2, ligne a k <= 1,
#       estim different de k, B effectif et p incoherents, ligne en double).
# B effectif de famille : lignes de stats_boot ou toutes les colonnes des
# membres sont finies (par. 3), recompte ici. Rend f (cle -> etat, k, bf, p,
# e, m, minp), inconnues (cles de lignes de famille hors de fam) et hors.
fk_etats <- function(lignes, boot, fam) {
  mb <- fk_membres(lignes, fam)
  S <- boot$stats_boot
  fo <- vapply(lignes, fk_champ, "", "fonction")
  cle <- substr(vapply(lignes, fk_champ, "", "famille"), 1L, 2L)
  lf <- which(fo %in% "engine_p_famille")
  f_out <- lapply(fam, function(f) {
    m <- mb$membres[[f]]; k <- length(m)
    i <- lf[cle[lf] %in% f]
    bf <- if (is.null(S) || !k || !all(m %in% colnames(S))) NA_real_ else
      as.numeric(sum(rowSums(!is.finite(S[, m, drop = FALSE])) == 0L))
    l <- if (length(i) == 1L) lignes[[i]] else NULL
    v <- function(nm) if (is.null(l)) NA_real_ else fk_num(l, nm)
    p <- v("p_mc"); e <- v("err_mc"); st <- v("stat")
    diag_info <- !is.null(l) && identical(fk_champ(l, "type"), "diagnostic") && identical(fk_champ(l, "verdict"), "INFO")
    etat <- if (is.null(S)) "S" else if (length(i) > 1L) "X" else if (is.null(l)) { if (k <= 1L) "A" else "X" }
      else if (k < 2L || !diag_info || !identical(v("estim"), as.numeric(k)) || is.na(bf)) "X"
      else if (is.finite(p)) { if (bf >= B_MIN_DEGENERESCENCE && is.finite(e) && is.finite(st)) "L" else "X" }
      else if (bf < B_MIN_DEGENERESCENCE && !is.finite(e) && !is.finite(st)) "N" else "X"
    list(etat = etat, k = k, bf = bf, p = p, e = e, m = st, minp = mb$minp[[f]])
  })
  list(f = stats::setNames(f_out, fam), inconnues = setdiff(unique(cle[lf]), fam), hors = mb$hors)
}
fk_etats_ok <- function(x) all(vapply(x$f, function(z) z$etat %in% c("L", "N", "A"), logical(1))) && !length(x$inconnues)
# Controle K-F3 (par. 5.3) : p de famille, m_obs, err_mc et k de chaque ligne
# de lecture conjointe recalcules en R de base depuis bootstrap$stats_boot,
# bootstrap$stats_obs, le catalogue (sens de rejet) et les lignes (membres
# par fk_membres()), par une ecriture INDEPENDANTE d'engine_p_famille() et de
# .engine_minp_rangs() : pour chaque membre, items 0 (observe) a n
# (replications completes), N = n + 1, comptes entiers par findInterval() sur
# la colonne triee (c- = #{<= v}, c+ = N - #{< v}, sans rank()) ; numerateur
# c+ (haut), c- (bas) ou min(2 min(c+, c-), N) (deux) ; m = minimum par item
# (pmin) ; p = #{m <= m(0)} / N, m_obs = m(0) / N, err_mc = sqrt(p (1 - p) /
# n). Comparaison identical() aux champs p_mc, stat, err_mc et estim de la
# ligne (etat L) ; etat N : p, stat et err_mc absents, n < B_MIN_DEGENERESCENCE.
# OK si toutes les lignes presentes concordent, aucune n'est incoherente et la
# ligne globale (derniere cle de fam) est presente et controlee.
fk_recalcul <- function(lignes, boot, catalogue, fam) {
  et <- fk_etats(lignes, boot, fam); mb <- fk_membres(lignes, fam)
  S <- boot$stats_boot
  fo <- vapply(lignes, fk_champ, "", "fonction")
  cle <- substr(vapply(lignes, fk_champ, "", "famille"), 1L, 2L)
  txt <- character(0); ok <- fk_etats_ok(et); n_l <- 0L
  for (f in fam) {
    x <- et$f[[f]]
    if (!x$etat %in% c("L", "N")) next
    l <- lignes[[which(fo %in% "engine_p_famille" & cle %in% f)]]
    m <- mb$membres[[f]]
    X0 <- S[, m, drop = FALSE]
    X <- X0[rowSums(!is.finite(X0)) == 0L, , drop = FALSE]
    n <- nrow(X); N <- n + 1L
    if (n < B_MIN_DEGENERESCENCE) {
      v <- c(p = is.na(fk_num(l, "p_mc")), m_obs = is.na(fk_num(l, "stat")), err_mc = is.na(fk_num(l, "err_mc")),
             k = identical(fk_num(l, "estim"), as.numeric(length(m))))
    } else {
      A <- rbind(vapply(m, function(c) as.numeric(boot$stats_obs[[c]]), 1), unname(X))
      cpt <- lapply(seq_along(m), function(j) {
        v <- A[, j]; tri <- sort(v)
        bas <- findInterval(v, tri)
        haut <- N - findInterval(v, tri, left.open = TRUE)
        switch(catalogue[[m[j]]]$queue, haut = haut, bas = bas, deux = pmin(2L * pmin(haut, bas), N))
      })
      mm <- do.call(pmin, cpt)
      p <- sum(mm <= mm[1L]) / N
      v <- c(p = identical(p, fk_num(l, "p_mc")), m_obs = identical(mm[1L] / N, fk_num(l, "stat")),
             err_mc = identical(sqrt(p * (1 - p) / n), fk_num(l, "err_mc")),
             k = identical(fk_num(l, "estim"), as.numeric(length(m))))
    }
    n_l <- n_l + 1L; ok <- ok && all(v)
    txt <- c(txt, sprintf("%s (\u00e9tat %s, k = %d, B effectif de famille %d) : %s", f, x$etat, length(m), n,
                          if (all(v)) "identiques" else paste("DIFF\u00c9RENTS :", paste(names(v)[!v], collapse = ", "))))
  }
  glob <- et$f[[fam[length(fam)]]]$etat %in% c("L", "N")
  list(ok = ok && glob, n = n_l,
       txt = sprintf("%d ligne(s) contr\u00f4l\u00e9e(s)%s ; %s%s", n_l, if (glob) ", ligne globale comprise" else ", LIGNE GLOBALE ABSENTE",
                     if (length(txt)) paste(txt, collapse = " ; ") else "aucune ligne de lecture conjointe",
                     if (fk_etats_ok(et)) "" else sprintf(" ; \u00e9tats incoh\u00e9rents : %s",
                       paste(sprintf("%s %s", names(et$f), vapply(et$f, `[[`, "", "etat")), collapse = ", "))))
}
# Profils Phi0 a Phi5 (par. 5.3), evalues mecaniquement SANS CONCLURE sur des
# cellules list(unite, f, ia, c) (c : lecture() contre rho_F) ; cellules non
# evaluables (aucune ligne presente) listees a part, hors profils. Phi5 :
# meme famille, distorsions materielles de cotes opposes entre deux unites
# (jeux ou lois). phi0 : etat du controle K-F3 et de K3 / K4 de #206. Sans
# cellule evaluable, aucun profil Phi1 a Phi5 n'est present : Phi1 est
# "non evaluable", jamais "oui". Chaque volet (lognormal, Merz-Wuthrich)
# rend ses profils ; LC lognormale et LC Merz-Wuthrich sont deux familles
# distinctes, Phi5 reste interne a un volet (avis d'actuary du 25/10/2026,
# point 3) : TXT_PROFIL_GLOBAL le rappelle sous le tableau.
TXT_PROFIL_GLOBAL <- paste(
  "Profils propres \u00e0 ce volet : la ligne globale LC de la m\u00e9thode lognormale et celle de Merz-W\u00fcthrich sont deux familles",
  "distinctes, et \u03a65 reste interne \u00e0 un volet. Profil global de D2-Fk = union des profils pr\u00e9sents dans les deux volets ;",
  "d\u00e9cision requise si \u03a60, \u03a64 ou \u03a65 appara\u00eet dans l'un ou l'autre.")
profils_fk <- function(cells, phi0, txt_phi0) {
  ev <- Filter(function(x) isTRUE(x$c$evaluable), cells)
  ne <- Filter(function(x) !isTRUE(x$c$evaluable), cells)
  cl <- vapply(ev, function(x) x$c$classe, "")
  co <- vapply(ev, function(x) if (isTRUE(x$c$disj)) x$c$cote else NA_character_, "")
  dist <- cl == CLASSES[4]; lib <- dist & co %in% "lib\u00e9ral"; cons <- dist & co %in% "conservateur"
  fu <- vapply(ev, `[[`, "", "f"); un <- vapply(ev, `[[`, "", "unite")
  txt_cel <- function(x) sprintf("%s %s %s", x$unite, x$f, c(a10 = "0,10", a05 = "0,05")[[x$ia]])
  p5 <- unique(fu[vapply(seq_along(ev), function(i) lib[i] && any(cons & fu == fu[i] & un != un[i]), logical(1))])
  oui <- function(b) if (b) "**oui**" else "non"
  c(entete_md(c("Profil", "Condition m\u00e9canique", "Pr\u00e9sent", "Cellules")),
    ligne_md("\u03a60", "K-F3, ou K3 ou K4 de #206, en d\u00e9faut (\u00ab sans explication \u00bb : jugement d'actuary)", oui(phi0), txt_phi0),
    ligne_md("\u03a61", "toutes les p de famille et la p globale compatibles ou en \u00e9cart mineur, aux deux \u03b1, sous chaque jeu ou loi",
             if (!length(ev)) "non \u00e9valuable (aucune cellule \u00e9valuable)" else oui(all(cl %in% CLASSES[1:2])),
             liste_cel(vapply(ev[!cl %in% CLASSES[1:2]], txt_cel, ""), 30)),
    ligne_md("\u03a62", "pas de distorsion mat\u00e9rielle, des \u00e9carts non tranch\u00e9s", oui(!any(dist) && any(cl == CLASSES[3])),
             liste_cel(vapply(ev[cl == CLASSES[3]], txt_cel, ""), 30)),
    ligne_md("\u03a63", "distorsion mat\u00e9rielle conservatrice seulement", oui(any(cons) && !any(lib)), liste_cel(vapply(ev[cons], txt_cel, ""), 30)),
    ligne_md("\u03a64", "distorsion mat\u00e9rielle lib\u00e9rale pour au moins une (famille, jeu ou loi, \u03b1)", oui(any(lib)),
             liste_cel(vapply(ev[lib], txt_cel, ""), 30)),
    ligne_md("\u03a65", "m\u00eame famille : distorsions de c\u00f4t\u00e9s oppos\u00e9s entre jeux ou lois", oui(length(p5) > 0),
             if (length(p5)) paste(p5, collapse = ", ") else "\u2014"), "",
    sprintf("Cellules non \u00e9valuables (aucune ligne de la famille sous le jeu ou la loi, hors profils) : %s.",
            if (length(ne)) liste_cel(vapply(ne, txt_cel, ""), 30) else "aucune"), "")
}

# --- Correspondances et classements (constantes, controlees sur J1 observe) ---
# Statistique du catalogue -> ligne de usp_tests() qui lit sa p_mc (mc_nom).
STAT_LIGNE <- c(
  AD = "Anderson-Darling", CvM = "Cramer-von Mises", KS = "Kolmogorov-Smirnov contre N(0,1)",
  SW = "Shapiro-Wilk sur residus standardises", SF = "Shapiro-Francia", JB = "Jarque-Bera",
  DW = "Autocorrelation d'ordre 1 (Durbin-Watson)",
  supF = "Rupture de niveau (sup-F)", CUSUM = "Stabilite cumulee (OLS-CUSUM)",
  Grubbs = "Valeur aberrante isolee (Grubbs)", Lillie = "Lilliefors (KS a parametres estimes)",
  Intercept = "Nullite de la constante (proportionnalite stricte)", RESET = "RESET (forme fonctionnelle)",
  BP = "Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)",
  BP79 = "Heteroscedasticite vs volume - Breusch-Pagan original (non robuste)",
  White = "Heteroscedasticite (forme quadratique)", GQ = "Egalite des variances petits vs gros volumes",
  BF = "Homogeneite des dispersions (mediane)", Smirnov = "Egalite des lois petits vs gros volumes (2 ech.)",
  LB2 = "Ljung-Box (retard 2)", Runs = "Test des suites (aleatoire des signes)",
  MK = "Tendance monotone du ratio S/P", SpearVol = "Independance ratio S/P vs volume",
  SpearTps = "Correlation ratio S/P vs temps", DAgo = "Asymetrie (D'Agostino, T >= 8)",
  CoxStuart = "Tendance par signes du ratio S/P",
  DWr = "Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts",
  Runsr = "Test des suites sur ratios bruts",
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
# des 47 lignes dans l'ordre de la table. Cles :
#   rep, ok ; ecart|b|motif ; reg|r et reg72|r (r : bord1, bord0, interieur,
#   erreur) ; mc|s|r|n, mc|s|r|k1, mc|s|r|k2 ; mmc|s|motif ;
#   l|ligne|n, np, k1, k2, t|type, inop, nat|classe, v|verdict ;
#   l|ligne ESD|kesd1, kesd2 (k chapeau >= 1, k chapeau = 2 : colonne
#   estimation, #304 ; absentes des comptes anterieurs a #304, ou la ligne
#   ESD portait v|ALERTE (k chapeau = 1) et v|ECHEC (k chapeau = 2) : T2
#   somme les deux formes, exacte pour des comptes anciens, nouveaux ou
#   combines) ;
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
  L <- c(sprintf("### T1 -- calibration de p_mc : les %d statistiques de USP_CATALOGUE_MC (p_mc retenue ou non)", N_STATS), "",
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
         "", sprintf(paste("Multiplicit\u00e9 : T1 compte %d intervalles (%d statistiques \u00d7 2 seuils) ; ici %d excluent la",
                           "r\u00e9f\u00e9rence. Sur J1 et J2 r\u00e9unis, %d intervalles : environ %d exclusions (5 %% de %d) sont",
                           "attendues par hasard m\u00eame si toutes les r\u00e9f\u00e9rences sont justes (intervalles corr\u00e9l\u00e9s entre eux ;",
                           "ordre de grandeur, pas un test). T1 bis et T2 ajoutent leurs propres intervalles."),
                     2L * length(stats), length(stats), excl_t1, 4L * length(stats),
                     round(0.05 * 4L * length(stats)), 4L * length(stats)), "")
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
  L <- c(L, sprintf("### T2 -- niveau des verdicts des %d lignes (puis des lignes de lecture conjointe, #297) : fr\u00e9quence de p retenue < \u03b1 et < \u03b1/2 parmi les p retenues (r\u00e8gles R1, R3, R4, R7, R13 comprises)", N_LIGNES), "",
         entete_md(c("Ligne", "n", "p retenue", cols_niv(1), cols_niv(2))))
  for (li in lignes) {
    cl <- nettoyer_cle(li)
    gl <- function(suf) g(sprintf("l|%s|%s", cl, suf))
    n <- gl("n"); np <- gl("np")
    if (identical(li, LIGNE_ESD)) {
      # Diagnostic par decision (#304), sans p-value ni verdict : k chapeau
      # >= 1 (colonne estimation) contre le niveau nominal 0,10 ; k chapeau
      # = 2 sans reference. Meme evenement que l'ancien verdict ALERTE ou
      # ECHEC (resp. ECHEC), fonction deterministe de k chapeau : les comptes
      # anterieurs a #304 (v|ALERTE, v|ECHEC, sans kesd) restent lisibles ;
      # depuis #304, la ligne ESD est toujours v|INFO.
      c1 <- lecture(gl("kesd1") + gl("v|ALERTE") + gl("v|ECHEC"), n, ALPHA)
      c2 <- lecture(gl("kesd2") + gl("v|ECHEC"), n, NA_real_)
      L <- c(L, ligne_md(li, n, "diagnostic par decision (#304) : frequence de k\u0302 >= 1",
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
  # Lignes de lecture conjointe (#297) : diagnostics sans p retenue ; n :
  # replications ou la ligne est presente (sa presence depend des donnees) ;
  # niveau de la p de famille : T-F1.
  for (f in FAM_LN) {
    n <- g(sprintf("f|%s|n", f))
    cel <- paste(c(lecture(0, 0, NA_real_)[c("k", "taux", "ic")], "sans objet (diagnostic, aucune p retenue ; niveau de la p : T-F1)",
                   "\u2014", "\u2014"), collapse = " | ")
    L <- c(L, ligne_md(lib_ligne_fk(f), n, 0, cel, cel))
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
         paste("\u2021 Ligne ESD (diagnostic par d\u00e9cision depuis #304, sans p-value ni verdict) : premi\u00e8re colonne, k\u0302 \u2265 1",
               "(colonne estimation), mesure P(k\u0302 \u2265 1), sur les r\u00e9plications trait\u00e9es, contre 0,10, niveau nominal de la proc\u00e9dure de Rosner,",
               "valeurs critiques \u00e0 1 \u2212 \u03b1/(2 n_i) ; exactitude non \u00e9tablie \u00e0 T = 8 ni sur z = P\u03b5. Seconde",
               "colonne : k\u0302 = 2, mesure P(k\u0302 = 2), sans niveau nominal."), "",
         "### T2 (suite) -- composition des lignes : types, nature de la p retenue, verdicts", "",
         entete_md(c("Ligne", "n", "test", "diagnostic", "dont inop\u00e9rant (R1)", "non applicable",
                     "p exacte", "p Monte-Carlo", "p asymptotique", "autre p",
                     "aucune p", "OK", "ALERTE", "ECHEC", "INFO")))
  ligne_t2s <- function(lib, pre) {
    k <- function(suf) sprintf("%.0f", g(sprintf("%s|%s", pre, suf)))
    ligne_md(lib, k("n"), k("t|test"), k("t|diagnostic"), k("inop"), k("t|non applicable"),
             k("nat|exacte"), k("nat|mc"), k("nat|asympt"), k("nat|autre"),
             k("nat|aucune"), k("v|OK"), k("v|ALERTE"), k("v|ECHEC"), k("v|INFO"))
  }
  for (li in lignes) L <- c(L, ligne_t2s(li, sprintf("l|%s", nettoyer_cle(li))))
  # Lignes de lecture conjointe (#297), presentes selon les donnees.
  for (f in FAM_LN) L <- c(L, ligne_t2s(lib_ligne_fk(f), sprintf("f|%s", f)))
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

###############################################################################
#  TABLEAUX DE LA LECTURE CONJOINTE (#297, specification de Fk, par. 5.3)
###############################################################################
# CJ : liste nommee jeu -> comptes (cpt) ; cles f|<famille>|n, na, k1, k2,
# pl, fr1, fr2, m1, m2, kf|<k> ; mult|ae, mult|e (lignes de type test),
# mult|ae_npr, mult|e_npr (lignes de sens "ne pas rejeter") ;
# fr|<statistique>|n, 1, 2.
gj <- function(cp, k) if (k %in% names(cp)) cp[[k]] else 0
part <- function(a, b) if (b > 0) num(a / b, D_IC) else "\u2014"
lib_fam_ln <- function(f) if (f == FAM_LN[length(FAM_LN)]) sprintf("%s (globale)", f) else f
# K-F1 : population, replications traitees ou la ligne est presente (k >= 2) ;
# une p absente (T-3b) compte comme un non-rejet, comptee a part ;
# reference rho_F, classes de #166 et #206 (lecture_classe()).
cellules_fk_ln <- function(CJ) {
  out <- list()
  for (j in names(CJ)) for (f in FAM_LN) for (ia in c("a10", "a05")) {
    cp <- CJ[[j]]
    c_ <- lecture_classe(gj(cp, sprintf("f|%s|%s", f, if (ia == "a10") "k1" else "k2")), gj(cp, sprintf("f|%s|n", f)), RHO_F[[ia]])
    c_$absentes <- gj(cp, sprintf("f|%s|na", f))
    out[[length(out) + 1L]] <- list(unite = j, f = f, ia = ia, ref = RHO_F[[ia]], c = c_, n_ok = gj(cp, "ok"))
  }
  out
}
tableau_fk1_ln <- function(CEL) {
  L <- c("### T-F1 \u2014 niveau sous H0 des p de famille et de la p globale (K-F1)", "",
         paste("Par jeu, famille et seuil : n r\u00e9plications trait\u00e9es o\u00f9 la ligne est pr\u00e9sente (k \u2265 2), dont les p absentes (B effectif de",
               "famille < 50, texte T-3b ; compt\u00e9es comme non-rejet) ; k rejets (p < \u03b1) ; taux k / n et IC de Clopper-Pearson \u00e0 95 % (5",
               "d\u00e9cimales ; classe sur les valeurs non arrondies) ; r\u00e9f\u00e9rence \u03c1_F, taille du test de Monte-Carlo id\u00e9al \u00e0 B_eff = 999 pour",
               "une statistique sans atome (majorant en pr\u00e9sence d'atomes) ; classe de #166 et #206 (c\u00f4t\u00e9 en gras si l'IC est disjoint de",
               "la bande [\u03c1_F/2 ; 3\u03c1_F/2])."), "",
         entete_md(c("Jeu", "Famille", "trait\u00e9es", "n (ligne pr\u00e9sente)", "abs. T-3b", "\u03c1_F 0,10", "k 0,10", "taux [IC] 0,10", "classe 0,10",
                     "\u03c1_F 0,05", "k 0,05", "taux [IC] 0,05", "classe 0,05")))
  cle <- vapply(CEL, function(x) paste(x$unite, x$f), "")
  for (u in unique(cle)) {
    x <- CEL[cle == u]
    cols <- unlist(lapply(x, function(z) c(num(z$ref, 3), sprintf("%.0f", z$c$k), txt_lec(z$c), txt_classe(z$c))))
    L <- c(L, ligne_md(x[[1]]$unite, lib_fam_ln(x[[1]]$f), sprintf("%.0f", x[[1]]$n_ok), sprintf("%.0f", x[[1]]$c$n),
                       sprintf("%.0f", x[[1]]$c$absentes), paste(cols, collapse = " | ")))
  }
  c(L, "")
}
tableau_fk2_ln <- function(CJ) {
  L <- c("### T-F2 \u2014 composition des familles : k, pr\u00e9sence de la ligne, plancher", "",
         paste("Sur les r\u00e9plications trait\u00e9es : k, nombre de tests membres (r\u00e8gle du par. 1.3 de la sp\u00e9cification de Fk, recompt\u00e9e par le",
               "script) ; ligne pr\u00e9sente si k \u2265 2 (Q-D1-Fk-2 (a)), absente pour k \u2264 1 ; pr\u00e9sente sans p si le B effectif de famille est",
               "< 50 (T-3b) ; masse au plancher : part des p de famille d\u00e9finies \u00e9gales \u00e0 1/(B effectif de famille + 1)."), "",
         entete_md(c("Jeu", "Famille", "trait\u00e9es", "distribution de k (k : r\u00e9plications)", "ligne pr\u00e9sente (part)", "dont sans p (T-3b)",
                     "p d\u00e9finies", "masse au plancher")))
  for (j in names(CJ)) for (f in FAM_LN) {
    cp <- CJ[[j]]; ok <- gj(cp, "ok")
    kk <- grep(sprintf("^f\\|%s\\|kf\\|", gsub(".", "\\.", f, fixed = TRUE)), names(cp), value = TRUE)
    kv <- as.integer(sub("^.*\\|", "", kk)); kk <- kk[order(kv)]; kv <- sort(kv)
    n <- gj(cp, sprintf("f|%s|n", f)); na <- gj(cp, sprintf("f|%s|na", f))
    L <- c(L, ligne_md(j, lib_fam_ln(f), sprintf("%.0f", ok), paste(sprintf("%d : %.0f", kv, cp[kk]), collapse = " ; "),
                       sprintf("%.0f (%s)", n, part(n, ok)), sprintf("%.0f", na), sprintf("%.0f", n - na),
                       part(gj(cp, sprintf("f|%s|pl", f)), n - na)))
  }
  c(L, "")
}
tableau_fk3_ln <- function(CJ) {
  lc <- FAM_LN[length(FAM_LN)]
  L <- c("### T-F3 \u2014 multiplicit\u00e9 sous H0 et lecture conjointe (K-F2, descriptif)", "",
         paste("Sur les r\u00e9plications trait\u00e9es : part \u00e0 au moins une ALERTE ou un ECHEC, et \u00e0 au moins un ECHEC, parmi les lignes de type",
               "test, puis parmi les seules lignes de sens \u00ab ne pas rejeter \u00bb (sans le TOST ni le test de Pitman, de sens \u00ab rejeter \u00bb :",
               "leur ALERTE ou leur ECHEC est le non-rejet d'une hypoth\u00e8se nulle contraire au mod\u00e8le (constante non n\u00e9gligeable ; absence de lien pertes / volume),",
               "c'est-\u00e0-dire une propri\u00e9t\u00e9 du mod\u00e8le non d\u00e9montr\u00e9e et non le rejet d'une hypoth\u00e8se du mod\u00e8le ; sous le mod\u00e8le simul\u00e9,",
               "leur fr\u00e9quence rel\u00e8ve de la puissance de ces tests, non de leur niveau) ; part \u00e0 p globale < \u03b1 (p absente : non-rejet) ; par famille, part \u00e0 au moins un test membre de p_mc < \u03b1 (plus petite",
               "p_mc des membres) contre part \u00e0 p de famille < \u03b1 (ligne absente ou sans p : non-rejet). Taux descriptifs, sans r\u00e9f\u00e9rence",
               "ni classe."), "",
         entete_md(c("Jeu", "n", "\u2265 1 A ou E (tests)", "\u2265 1 A ou E (tests \u00ab ne pas rejeter \u00bb)", "\u2265 1 E (tests)",
                     "\u2265 1 E (tests \u00ab ne pas rejeter \u00bb)", "p globale < 0,10", "p globale < 0,05")))
  for (j in names(CJ)) { cp <- CJ[[j]]; ok <- gj(cp, "ok")
    L <- c(L, ligne_md(j, sprintf("%.0f", ok), part(gj(cp, "mult|ae"), ok), part(gj(cp, "mult|ae_npr"), ok), part(gj(cp, "mult|e"), ok),
                       part(gj(cp, "mult|e_npr"), ok),
                       part(gj(cp, sprintf("f|%s|k1", lc)), ok), part(gj(cp, sprintf("f|%s|k2", lc)), ok))) }
  L <- c(L, "", entete_md(c("Jeu", "Famille", "n", "\u2265 1 membre p_mc < 0,10", "p de famille < 0,10", "\u2265 1 membre p_mc < 0,05",
                            "p de famille < 0,05")))
  for (j in names(CJ)) for (f in FAM_LN) { cp <- CJ[[j]]; ok <- gj(cp, "ok"); q <- function(s) part(gj(cp, sprintf("f|%s|%s", f, s)), ok)
    L <- c(L, ligne_md(j, lib_fam_ln(f), sprintf("%.0f", ok), q("m1"), q("k1"), q("m2"), q("k2"))) }
  c(L, "")
}
tableau_fk4_ln <- function(CJ, stats) {
  L <- c("### T-F4 \u2014 voisinage des seuils (K-F4, descriptif)", "",
         paste("Fr\u00e9quence sous H0 de |p \u2212 s| < 2 err_mc, s \u2208 {0,10 ; 0,05} : sur les p de famille d\u00e9finies (err_mc = \u221a(p (1 \u2212 p)/B_eff),",
               "queue simple), puis par statistique du catalogue sur les p_mc d\u00e9finies (err_mc d'engine_p_mc()). Les lignes par statistique",
               "ignorent la bascule de la r\u00e8gle R1 et l'atteignabilit\u00e9 du seuil (plancher de la p) : ce n'est pas l'ensemble \u00ab \u00e0 la",
               "fronti\u00e8re \u00bb de #244 (r\u00e8gle d'add(), PHRASE_VERDICT_SENSIBLE_MC), seulement la fr\u00e9quence de la condition sur p_mc et err_mc."), "",
         entete_md(c("Jeu", "Famille ou statistique", "p d\u00e9finies", "\\|p \u2212 0,10\\| < 2 err_mc", "\\|p \u2212 0,05\\| < 2 err_mc")))
  for (j in names(CJ)) { cp <- CJ[[j]]
    for (f in FAM_LN) { d <- gj(cp, sprintf("f|%s|n", f)) - gj(cp, sprintf("f|%s|na", f))
      L <- c(L, ligne_md(j, lib_fam_ln(f), sprintf("%.0f", d), part(gj(cp, sprintf("f|%s|fr1", f)), d), part(gj(cp, sprintf("f|%s|fr2", f)), d))) }
    for (s_ in stats) { d <- gj(cp, sprintf("fr|%s|n", s_))
      L <- c(L, ligne_md(j, s_, sprintf("%.0f", d), part(gj(cp, sprintf("fr|%s|1", s_)), d), part(gj(cp, sprintf("fr|%s|2", s_)), d))) } }
  c(L, "")
}
evaluation_fk_ln <- function(CEL) {
  ev <- Filter(function(x) isTRUE(x$c$evaluable), CEL)
  un <- unique(vapply(CEL, `[[`, "", "unite"))
  k1 <- vapply(un, function(u) { cl <- vapply(Filter(function(x) x$unite == u, ev), function(x) x$c$classe, "")
    t <- table(factor(cl, levels = c(CLASSES, setdiff(unique(cl), CLASSES)))); paste(sprintf("%s %d", names(t), as.integer(t)), collapse = ", ") }, "")
  c("### \u00c9valuation m\u00e9canique de K-F1 \u00e0 K-F4 et des profils \u03a6 (sans conclusion)", "",
    "\u00c9tats calcul\u00e9s par le script ; la lecture revient \u00e0 actuary, la d\u00e9cision \u00e9ventuelle au mainteneur (D2-Fk, Q-D1-Fk-9 : d\u00e9cision requise sous \u03a60, \u03a64 ou \u03a65 seulement). Volet lognormal : K3 et K4 de #206 sans objet.", "",
    entete_md(c("Condition", "\u00c9tat m\u00e9canique", "D\u00e9tail")),
    ligne_md("K-F1 (principal)", if (length(ev)) "\u00e9valu\u00e9e" else "non \u00e9valuable", if (length(un)) paste(sprintf("%s : %s", un, k1), collapse = " ; ") else "aucun jeu"),
    ligne_md("K-F2 (descriptif, T4)", "descriptif", "voir T-F3"),
    ligne_md("K-F3 (int\u00e9grit\u00e9)", "remplie", "INTEGRITE OK et contr\u00f4le (K-F3) OK dans chaque sortie (refus de --combiner sinon)"),
    ligne_md("K-F4 (fronti\u00e8re, descriptif)", "descriptif", "voir T-F4"),
    "", profils_fk(CEL, FALSE, "K-F3 rempli (INTEGRITE OK et ligne (K-F3) OK dans chaque sortie) ; K3 et K4 de #206 sans objet pour le volet lognormal"),
    TXT_PROFIL_GLOBAL, "")
}

LIBELLES_CONTEXTE <- c(
  jeu = "Jeu", modele = "Mod\u00e8le ajust\u00e9 (usp_ajuster())", configuration = "Configuration de run_engine()",
  sigma_usp = "\u03c3_USP observ\u00e9 (usp_parametre() sur le mod\u00e8le ajust\u00e9)", graines = "Graines",
  collisions = "Graines en collision (d\u00e9clar\u00e9es, non bloquantes)", generateur = "G\u00e9n\u00e9rateur",
  commit = "Commit", plateforme = "Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)",
  empreintes = "Empreintes md5 du code ex\u00e9cut\u00e9",
  reference = "Contr\u00f4le (a) : J1 observ\u00e9 contre tests/reference/premium.rds",
  tailles = "Tailles des lois discr\u00e8tes, P(p < 0,10) et P(p < 0,05) (T = 8, sans ex aequo)",
  essai = "Essai (--essai, non versionnable)",
  empreinte_sc = "Empreinte sans commentaires de R/engine.R (#231)")
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

# Jeu J2 (lire_j2() : copie de tests/taux_franchissement_reperes.R), lu par
# l'execution et par --prevol-unite.
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
       comptes = stats::setNames(as.numeric(vapply(cp, `[`, "", 2L)), cles),
       # lignes du controle K-F3 en succes (#297), lues dans le markdown
       kf3 = sum(grepl("^- \\(K-F3\\) .*: OK$", l)))
}
# Ligne du JOURNAL d'une sortie (#248) : exactement une ligne
# "- Sortie <nom> : md5 <md5>" de md5 egal a celui du fichier ; NULL si
# conforme (copie de tests/calibration_mc_mw_t8.R).
ecart_journal_sortie <- function(jl, nom, md5) {
  m <- regmatches(jl, regexec("^- Sortie (\\S+) : md5 ([0-9a-f]{32})([,[:space:]]|$)", jl))
  m <- Filter(function(x) length(x) && identical(x[2], nom), m)
  if (length(m) != 1L)
    return(sprintf("%d ligne(s) \"- Sortie %s : md5 <md5>\" au JOURNAL (une attendue)", length(m), nom))
  if (!identical(m[[1]][3], md5))
    return(sprintf("md5 de %s au JOURNAL (%s) different de celui du fichier (%s)", nom, m[[1]][3], md5))
  NULL
}
# Chemin absolu ou /tmp dans un texte destine a un fichier (#242, D-a ;
# copie de tests/calibration_mc_mw_t8.R).
chemins_absolus <- function(lignes) {
  k <- grepl("/tmp", lignes, fixed = TRUE) |
    grepl("(^|[ (|`'\"=])(/(home|root|usr|var|mnt|opt|Users|private|srv|media)/|[A-Za-z]:[\\\\/])", lignes, perl = TRUE)
  lignes[k]
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
  # perte) pour les 31 p_mc, par regime, et pour les 47 p retenues.
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
    # err_mc et B effectif (#297) : B effectif entier de 0 a B ; p_mc finie ->
    # err_mc finie, B effectif >= 1 et p_mc sur la grille k/(B_eff + 1) (x 2
    # en bilateral, plafonnee a 1) ; p_mc absente -> err_mc absente.
    if (all(paste0(c("e_mc:", "B_eff:"), rep(names(p$stats), each = 2)) %in% p$repcols)) for (s in names(p$stats)) {
      pm <- val(paste0("p_mc:", s)); em <- val(paste0("e_mc:", s)); bb <- val(paste0("B_eff:", s))
      kq <- if (identical(p$stats[[s]], "deux")) 2 else 1; x <- pm * (bb + 1) / kq
      okg <- is.finite(bb) & bb >= 0 & bb <= B_BOOT & bb == round(bb) &
        ifelse(is.finite(pm), is.finite(em) & bb >= 1 & (pm == 1 | abs(x - round(x)) < 1e-6), !is.finite(em))
      if (!all(okg %in% TRUE)) ds <- c(ds, sprintf("err_mc ou B effectif de %s", s))
    } else ds <- c(ds, "colonnes e_mc: et B_eff: (#297) absentes de REPCOLS")
    # Lecture conjointe (#297) : etats 0, 1 ou 2 seulement sur les
    # replications traitees ; lignes presentes (1, 2), absences T-3b (2) et
    # rejets des p de famille recomptes sur les lignes REP = comptes.
    if (all(paste0("etf:", FAM_LN) %in% p$repcols)) for (f in FAM_LN) {
      et <- val(paste0("etf:", f)); pf <- val(paste0("pf:", f))
      if (!all(et %in% c(0, 1, 2))) ds <- c(ds, sprintf("etat de la ligne de famille %s hors de 0, 1, 2", f))
      x <- c(sum(et %in% c(1, 2)), sum(et %in% 2), sum(is.finite(pf) & pf < ALPHA), sum(is.finite(pf) & pf < ALPHA2))
      cp_x <- vapply(c("n", "na", "k1", "k2"), function(q) g(sprintf("f|%s|%s", f, q)), numeric(1))
      if (!identical(as.numeric(x), unname(cp_x))) ds <- c(ds, sprintf("lecture conjointe %s (n, T-3b, k1, k2)", f))
    } else ds <- c(ds, "colonnes de lecture conjointe (#297) absentes de REPCOLS")
    if (length(ds)) err <- c(err, paste("lignes REP differentes des comptes (n, k1, k2) :", paste(ds, collapse = ", ")))
  }
  # Comptes de lecture conjointe (#297) : distribution de k sur ok
  # replications par famille ; multiplicite au plus ok.
  for (f in FAM_LN) if (somme(sprintf("f|%s|kf|", f)) != ok)
    err <- c(err, sprintf("distribution de k de la famille %s : %.0f, ok = %.0f", f, somme(sprintf("f|%s|kf|", f)), ok))
  if (g("mult|ae") > ok || g("mult|e") > g("mult|ae") || g("mult|ae_npr") > g("mult|ae") || g("mult|e_npr") > g("mult|e") ||
      g("mult|e_npr") > g("mult|ae_npr"))
    err <- c(err, "comptes de multiplicite (mult|ae, mult|e, mult|ae_npr, mult|e_npr) incoherents")
  err
}

if (length(FICHIERS_COMB)) {
  T_COMB0 <- Sys.time()
  # Gardes des chemins d'ecriture (constat R2 d'audit) : --sortie et --brut
  # hors du depot, --brut sans ecrasement.
  if (!is.na(OPT_SORTIE) && sous_depot(OPT_SORTIE))
    refuser("--sortie : dossier sous le depot refuse (--ecrire est le seul chemin qui ecrit dans le depot) : ", OPT_SORTIE)
  if (!is.na(OPT_BRUT)) {
    if (!dir.exists(dirname(OPT_BRUT))) refuser("--brut : dossier introuvable : ", dirname(OPT_BRUT))
    if (sous_depot(dirname(OPT_BRUT)))
      refuser("--brut : chemin sous le depot refuse (copie hors du depot ; --ecrire versionne le brut de la campagne 297) : ", OPT_BRUT)
    if (file.exists(OPT_BRUT)) refuser("--brut : fichier existant, jamais ecrase : ", OPT_BRUT)
  }
  # Fichiers : chemins, ou DOSSIER (sorties ln-J<1|2>-R<R>-<b1>-<b2>.txt du plan
  # de la campagne 297, tests/calibration_mc_mw_t8.R --plan Lk --campagne 297).
  fichiers <- unlist(lapply(FICHIERS_COMB, function(f) if (dir.exists(f))
    sort(list.files(f, pattern = "^ln-J[12]-R[0-9]+-[0-9]{4}-[0-9]{4}\\.txt$", full.names = TRUE)) else f))
  if (!length(fichiers)) refuser("aucun fichier de sortie")
  if (anyDuplicated(basename(fichiers))) refuser("noms de fichiers en double")
  parts <- lapply(fichiers, lire_comptes)
  jeux_p <- vapply(parts, function(p) sub("^jeu=(J[12]);.*$", "\\1", p$parametres), "")
  if (OPT_CAMPAGNE != "297" && length(unique(jeux_p)) != 1L)
    refuser("parametres differents entre les fichiers (un seul jeu par combinaison ; J1 et J2 ensemble : --campagne 297)")
  if (length(unique(lapply(parts, `[[`, "stats"))) != 1L) refuser("lignes STATS differentes entre les tranches")
  if (length(unique(lapply(parts, `[[`, "lignes"))) != 1L) refuser("lignes LIGNES differentes entre les tranches")
  if (length(unique(lapply(parts, `[[`, "repcols"))) != 1L) refuser("lignes REPCOLS differentes entre les tranches")
  # Contexte commun aux jeux (code, plateforme, generateur, configuration,
  # graines, reference, tailles, essai) ; le reste (jeu, modele, sigma_USP,
  # collisions) est propre a chaque jeu.
  CTX_COMMUN <- c("configuration", "graines", "generateur", "commit", "plateforme", "empreintes", "reference", "tailles", "essai",
                  "empreinte_sc")
  k_diff <- CTX_COMMUN[vapply(CTX_COMMUN, function(k) length(unique(vapply(parts, function(p) p$contexte[[k]], ""))) > 1L, logical(1))]
  if (length(k_diff)) refuser("contexte (T0) different entre les tranches : ", paste(k_diff, collapse = ", "))
  ctx0 <- parts[[1]]$contexte
  if (!identical(ctx0[["tailles"]], txt_tailles(TAILLES)))
    refuser("tailles des lois discretes des tranches differentes de celles recalculees par --combiner : ",
            ctx0[["tailles"]], " contre ", txt_tailles(TAILLES))
  # Campagne 297 : controle K-F3 en succes dans chaque sortie (une ligne).
  if (OPT_CAMPAGNE == "297") for (p in parts) if (p$kf3 != 1L)
    refuser(basename(p$fichier), " : ", p$kf3, " ligne(s) \"- (K-F3) ... : OK\" (une attendue) -- sortie anterieure a #297 ou controle K-F3 en echec")
  # Par jeu : parametres et contexte identiques, couverture de 1..R, invariants,
  # comptes additionnes, controles (e3) et (e4).
  JX <- lapply(stats::setNames(nm = sort(unique(jeux_p))), function(j) {
    pj <- parts[jeux_p == j]
    par <- unique(vapply(pj, `[[`, "", "parametres"))
    if (length(par) != 1L) refuser("parametres differents entre les fichiers du jeu ", j)
    ctx <- unique(lapply(pj, `[[`, "contexte"))
    if (length(ctx) != 1L) {
      kd <- names(LIBELLES_CONTEXTE)[vapply(names(LIBELLES_CONTEXTE), function(k)
        length(unique(vapply(pj, function(p) p$contexte[[k]], ""))) > 1L, logical(1))]
      refuser("contexte (T0) different entre les tranches du jeu ", j, " : ", paste(kd, collapse = ", "))
    }
    R_tot <- as.integer(sub("^.*;R=([0-9]+);.*$", "\\1", par))
    idx <- unlist(lapply(pj, function(p) seq.int(p$debut, p$fin)))
    if (anyDuplicated(idx) || !setequal(idx, seq_len(R_tot)))
      refuser("jeu ", j, " : les tranches ne couvrent pas 1..", R_tot, " exactement une fois")
    for (p in pj) {
      e <- invariants_tranche(p)
      if (length(e)) refuser(p$fichier, " : invariant(s) du corps faux -- ", paste(e, collapse = " ; "))
    }
    cles <- unique(unlist(lapply(pj, function(p) names(p$comptes))))
    cpt <- stats::setNames(vapply(cles, function(k) sum(vapply(pj, function(p)
      if (k %in% names(p$comptes)) p$comptes[[k]] else 0, numeric(1))), numeric(1)), cles)
    if (cpt[["rep"]] != R_tot) refuser(sprintf("jeu %s : somme des rep = %.0f, R = %d", j, cpt[["rep"]], R_tot))
    c72 <- controles_72(cpt, R_tot, j)
    if (isFALSE(c72$e3$ok)) refuser("jeu ", j, " : controle (e3) en ECHEC -- ", c72$e3$texte)
    if (isFALSE(c72$e4$ok)) refuser("jeu ", j, " : controle (e4) en ECHEC -- ", c72$e4$texte)
    list(jeu = j, par = par, ctx = ctx[[1]], R = R_tot, parts = pj, cpt = cpt, c72 = c72, du = Reduce(`+`, lapply(pj, `[[`, "duree")))
  })
  # Niveau du plan de Fk (par. 5.2) : J1 et J2, R du niveau.
  R_NIV_LN <- list(L0 = c(J1 = 2000L, J2 = 2000L), L1 = c(J1 = 2000L, J2 = 2000L), L2 = c(J1 = 1000L, J2 = 2000L),
                   L3 = c(J1 = 1000L, J2 = 2000L), L4 = c(J1 = 1000L, J2 = 1000L))
  if (!is.na(OPT_NIVEAU)) {
    rn <- R_NIV_LN[[OPT_NIVEAU]]
    if (!setequal(names(JX), names(rn))) refuser("--niveau ", OPT_NIVEAU, " : jeux J1 et J2 attendus (lus : ", paste(names(JX), collapse = ", "), ")")
    for (j in names(rn)) if (JX[[j]]$R != rn[[j]]) refuser("--niveau ", OPT_NIVEAU, " : R du jeu ", j, " = ", JX[[j]]$R, " (", rn[[j]], " attendu)")
  }
  # JOURNAL (campagne 297) : une ligne "- Sortie <nom> : md5 <md5>" par
  # sortie (ecart_journal_sortie(), copie de tests/calibration_mc_mw_t8.R),
  # ligne "- Niveau : Lk" egale a --niveau.
  TXT_JOURNAL <- "non fourni"
  if (!is.na(OPT_JOURNAL)) {
    if (!file.exists(OPT_JOURNAL)) refuser("--journal introuvable")
    jl <- readLines(OPT_JOURNAL, warn = FALSE, encoding = "UTF-8")
    for (p in parts) { e <- ecart_journal_sortie(jl, basename(p$fichier), unname(tools::md5sum(p$fichier))); if (!is.null(e)) refuser("--journal : ", e) }
    ln_ <- Filter(length, regmatches(jl, regexec("^\\s*- Niveau : (L[0-5])\\s*$", jl)))
    if (length(ln_) > 1L) refuser("--journal : plusieurs lignes \"- Niveau : Lk\"")
    niv_j <- if (length(ln_)) ln_[[1]][2] else NA_character_
    # Commit et empreinte sans commentaires (#231) portes au JOURNAL par le
    # pre-vol (audit m4 de #297) : une ligne chacun, egaux a ceux des sorties.
    lc_ <- Filter(length, regmatches(jl, regexec("^\\s*- Commit : ([0-9a-f]{40})\\s*$", jl)))
    le_ <- Filter(length, regmatches(jl, regexec("^\\s*- Empreinte sans commentaires : ([0-9a-f]{32})\\s*$", jl)))
    if (length(lc_) != 1L) refuser("--journal : ", length(lc_), " ligne(s) \"- Commit : <sha>\" (une attendue, ecrite par le pre-vol)")
    if (length(le_) != 1L) refuser("--journal : ", length(le_), " ligne(s) \"- Empreinte sans commentaires : <md5>\" (une attendue)")
    if (!identical(lc_[[1]][2], sub(" .*$", "", ctx0[["commit"]])))
      refuser("--journal : commit du JOURNAL ", lc_[[1]][2], " different de celui des sorties ", sub(" .*$", "", ctx0[["commit"]]))
    if (!identical(le_[[1]][2], ctx0[["empreinte_sc"]]))
      refuser("--journal : empreinte du JOURNAL ", le_[[1]][2], " differente de celle des sorties ", ctx0[["empreinte_sc"]])
    if (!is.na(OPT_NIVEAU) && !identical(niv_j, OPT_NIVEAU)) refuser("--journal : ligne \"- Niveau : ", OPT_NIVEAU, "\" absente ou differente (", niv_j, ")")
    TXT_JOURNAL <- sprintf("%s (md5 %s) : md5 des %d sorties conformes ; niveau : %s", basename(OPT_JOURNAL), unname(tools::md5sum(OPT_JOURNAL)),
                           length(parts), if (is.na(niv_j)) "ligne absente" else niv_j)
  }
  # --ecrire exige un commit propre et le code du depot pour les tranches ET
  # pour la combinaison elle-meme (constat R1 d'audit) ; sorties d'essai et
  # combinaison de la campagne 297 sans --niveau non versionnables.
  COMMIT_COMB <- commit_depot("tests/calibration_mc_t8.R")
  EMPREINTES_COMB <- empreintes_code("tests/calibration_mc_t8.R", SCRIPT_72)
  nv <- c(motifs_non_versionnable(ctx0[["commit"]], ctx0[["empreintes"]]),
          motifs_non_versionnable(COMMIT_COMB, EMPREINTES_COMB, "de la combinaison"),
          if (!identical(ctx0[["essai"]], "non")) "sorties d'essai (--essai)",
          if (OPT_CAMPAGNE == "297" && is.na(OPT_NIVEAU)) "param\u00e8tres r\u00e9duits (sans --niveau)")
  if (OPT_ECRIRE && length(nv))
    refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
            " -- relancer sur un arbre propre, ou utiliser --sortie DOSSIER hors du depot")
  stats0 <- parts[[1]]$stats; lignes0 <- parts[[1]]$lignes; repcols0 <- parts[[1]]$repcols
  t0_jeu <- function(x) c(lignes_contexte(x$ctx),
    ligne_md("R\u00e9plications", sprintf("%d (%d tranche(s) : %s)", x$R, length(x$parts),
                                          paste(vapply(x$parts, function(p) sprintf("%d-%d", p$debut, p$fin), ""), collapse = ", "))),
    ligne_md("Dur\u00e9e cumul\u00e9e des tranches (s)", sprintf("contr\u00f4les %.0f ; r\u00e9plications %.0f (%.1f s par r\u00e9plication)",
                                                                    x$du[1], x$du[2], x$du[2] / max(x$du[3], 1))))
  if (OPT_CAMPAGNE != "297") {
    x <- JX[[1]]
    tb <- tableaux(x$cpt, stats0, lignes0)
    sortie <- c(sprintf("## Calibration des p-values Monte-Carlo \u00e0 T = 8, jeu %s -- combinaison de %d tranche(s) (issue #166)",
                        x$jeu, length(parts)), "",
                sprintf("Param\u00e8tres : %s", x$par), "",
                "### T0 -- contexte (identique dans toutes les tranches, v\u00e9rifi\u00e9)", "",
                entete_md(c("Grandeur", "Valeur")), t0_jeu(x),
                ligne_md("Commit de la combinaison", COMMIT_COMB),
                ligne_md("Empreintes md5 du combinateur", EMPREINTES_COMB),
                ligne_md("Versionnable (--ecrire)", if (length(nv)) paste("non :", paste(nv, collapse = " ; ")) else "oui"),
                ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", sprintf("OK dans les %d tranche(s), invariants du corps v\u00e9rifi\u00e9s ; (e3) : %s ; (e4) : %s",
                                                                length(parts), x$c72$e3$texte, x$c72$e4$texte)), "",
                aide_lecture(), tb$lignes,
                "### Contr\u00f4les d'int\u00e9grit\u00e9", "",
                sprintf("- (a) \u00e0 (d), (e1), (e2), (f), (k), (K-F3), (t297) et contr\u00f4les de coh\u00e9rence : OK dans les %d tranche(s) (ligne INTEGRITE)", length(parts)),
                sprintf("- Invariants du corps des tranches (comptes et lignes REP) : OK dans les %d tranche(s) ; somme des rep = R = %d", length(parts), x$R),
                sprintf("- (e3) effectifs des r\u00e9gimes contre le tableau de #72 : %s", x$c72$e3$texte),
                sprintf("- (e4) largeur de l'IC bootstrap contre le tableau de #72 : %s", x$c72$e4$texte), "")
    ecrire_console(sortie)
    ecrire_fichier(x$jeu, sortie)
    if (!is.na(OPT_BRUT)) {
      rp <- do.call(c, lapply(parts, `[[`, "rep"))
      rp <- rp[order(as.integer(vapply(rp, `[`, "", 1L)))]
      con <- file(OPT_BRUT, open = "wb")
      writeLines(enc2utf8(c(paste(repcols0, collapse = "\t"), vapply(rp, paste, "", collapse = "\t"))), con, useBytes = TRUE)
      close(con)
      message("\u00e9crit (valeurs brutes, ", length(rp), " r\u00e9plications) : ", OPT_BRUT)
    }
    quit(status = 0L)
  }
  # --- Campagne 297 : tableau unique J1 et J2 ---------------------------------
  NOMS_297 <- c(md = sprintf("%s-issue297-calibration-famille-ln.md", DATE_SORTIE),
                brut = sprintf("%s-issue297-calibration-famille-ln-brut.tsv", DATE_SORTIE),
                jcomb = sprintf("%s-issue297-journal-combinaison-ln.md", DATE_SORTIE))
  BRUT <- c(paste(c("jeu", repcols0), collapse = "\t"), unlist(lapply(names(JX), function(j) {
    rp <- do.call(c, lapply(JX[[j]]$parts, `[[`, "rep")); rp <- rp[order(as.integer(vapply(rp, `[`, "", 1L)))]
    vapply(rp, function(r) paste(c(j, r), collapse = "\t"), "") }), use.names = FALSE))
  F_BRUT_TMP <- tempfile("ln297_brut_", fileext = ".tsv")
  con <- file(F_BRUT_TMP, open = "wb"); writeLines(enc2utf8(BRUT), con, useBytes = TRUE); close(con)
  MD5_BRUT <- unname(tools::md5sum(F_BRUT_TMP))
  CJ <- lapply(JX, `[[`, "cpt")
  CEL <- cellules_fk_ln(CJ)
  plan_txt <- if (is.na(OPT_NIVEAU)) sprintf("sans --niveau (param\u00e8tres r\u00e9duits, non versionnable) : %s",
                                             paste(sprintf("%s R = %d", names(JX), vapply(JX, `[[`, 1L, "R")), collapse = ", ")) else
    sprintf("%s (plan de la sp\u00e9cification de Fk, par. 5.2) : %s", OPT_NIVEAU, paste(sprintf("%s R = %d", names(JX), vapply(JX, `[[`, 1L, "R")), collapse = ", "))
  t0 <- c(entete_md(c("Grandeur", "Valeur")),
          vapply(CTX_COMMUN, function(k) ligne_md(LIBELLES_CONTEXTE[[k]], ctx0[[k]]), ""),
          ligne_md("Niveau de l'\u00e9chelle et R", plan_txt),
          unlist(lapply(JX, function(x) c(ligne_md(sprintf("%s : param\u00e8tres", x$jeu), x$par),
            vapply(setdiff(names(LIBELLES_CONTEXTE), CTX_COMMUN), function(k) ligne_md(sprintf("%s : %s", x$jeu, LIBELLES_CONTEXTE[[k]]), x$ctx[[k]]), ""),
            ligne_md(sprintf("%s : r\u00e9plications", x$jeu), sprintf("%d (%d tranche(s) : %s)", x$R, length(x$parts),
                                                                            paste(vapply(x$parts, function(p) sprintf("%s %d-%d", basename(p$fichier), p$debut, p$fin), ""), collapse = ", "))),
            ligne_md(sprintf("%s : dur\u00e9e cumul\u00e9e (s)", x$jeu), sprintf("contr\u00f4les %.0f ; r\u00e9plications %.0f (%.1f s par r\u00e9plication)",
                                                                               x$du[1], x$du[2], x$du[2] / max(x$du[3], 1))),
            ligne_md(sprintf("%s : (e3) et (e4)", x$jeu), sprintf("%s ; %s", x$c72$e3$texte, x$c72$e4$texte)))), use.names = FALSE),
          ligne_md("Sorties combin\u00e9es (nom, md5)", paste(vapply(parts, function(p) sprintf("%s %s", basename(p$fichier), unname(tools::md5sum(p$fichier))), ""), collapse = " ; ")),
          ligne_md("JOURNAL", TXT_JOURNAL),
          ligne_md("Commit de la combinaison", COMMIT_COMB), ligne_md("Empreintes md5 du combinateur", EMPREINTES_COMB),
          ligne_md("Valeurs brutes", sprintf("%s : md5 %s, %d lignes (copie hors du d\u00e9p\u00f4t : --brut)", NOMS_297[["brut"]], MD5_BRUT, length(BRUT) - 1L)),
          ligne_md("Journal de la combinaison", NOMS_297[["jcomb"]]),
          ligne_md("Versionnable (--ecrire)", if (length(nv)) paste("non :", paste(nv, collapse = " ; ")) else "oui"),
          ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", sprintf("OK dans les %d sorties (dont (k), (K-F3) et (t297)) ; invariants du corps v\u00e9rifi\u00e9s ; couvertures exactes par jeu", length(parts))))
  sortie <- c(sprintf("## Mesure #297 (Fk) : niveau r\u00e9el \u00e0 T = 8 des p de famille et de la p globale, m\u00e9thode lognormale (%s) -- combinaison de %d sortie(s)",
                      paste(names(JX), collapse = ", "), length(parts)), "",
              "### T0 \u2014 provenance (contexte commun v\u00e9rifi\u00e9 identique dans toutes les sorties)", "", t0, "",
              "### Aide \u00e0 la lecture", "",
              paste("Statut : **constat de simulation sous les mod\u00e8les ajust\u00e9s aux jeux J1 et J2** (usp_simuler(FIT0)), pas un r\u00e9sultat",
                    "g\u00e9n\u00e9ral. Lecture conjointe (#297) : p de famille et p globale minP en une \u00e9tape (engine_p_famille()), diagnostics sans",
                    "verdict, p plug-in non exactes (sp\u00e9cification de Fk, par. 1.1) ; r\u00e9f\u00e9rence \u03c1_F = 0,099 et 0,049 (par. 5.3), majorant en",
                    "pr\u00e9sence d'atomes de la plus petite p. IC : Clopper-Pearson \u00e0 95 %, incertitude Monte-Carlo sur le taux (fonction de R)."), "",
              "**Crit\u00e8re de la sp\u00e9cification de Fk (par. 5.3), report\u00e9 sans modification, \u00e9valu\u00e9 m\u00e9caniquement sans conclure :**", "",
              paste(">", TEXTE_CRITERE_FK), "",
              evaluation_fk_ln(CEL), tableau_fk1_ln(CEL), tableau_fk2_ln(CJ), tableau_fk3_ln(CJ), tableau_fk4_ln(CJ, names(stats0)),
              unlist(lapply(JX, function(x) c(sprintf("## Jeu %s : tableaux de #166 sur la m\u00eame ex\u00e9cution (T1, T1 bis, T2 \u00e9tendu, T3)", x$jeu), "",
                                               tableaux(x$cpt, stats0, lignes0)$lignes)), use.names = FALSE),
              aide_lecture())
  ecrire_console(sortie)
  if (length(chemins_absolus(sortie)) && (OPT_ECRIRE || !is.na(OPT_SORTIE)))
    refuser("ecriture refusee : chemin absolu ou /tmp dans le tableau (D-a de #242)")
  journal_comb <- function(ecrits) c("# Journal de la combinaison de la mesure #297 (Fk), volet lognormal", "",
    sprintf("- D\u00e9but (UTC) : %s ; fin (UTC) : %s", format(T_COMB0, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")),
    sprintf("- Commande : Rscript tests/calibration_mc_t8.R %s", paste(vapply(ARGS, function(a) if (file.exists(a) || dir.exists(a)) basename(a) else a, ""), collapse = " ")),
    sprintf("- Commit de la combinaison : %s", COMMIT_COMB), sprintf("- Plateforme : %s", plateforme_calcul()),
    sprintf("- JOURNAL de la mesure : %s", TXT_JOURNAL),
    "- Sorties lues (toutes INTEGRITE OK, FIN en derni\u00e8re ligne, couvertures exactes par jeu, aucun refus) :",
    paste0("  - ", vapply(parts, function(p) sprintf("%s md5 %s", basename(p$fichier), unname(tools::md5sum(p$fichier))), "")),
    "- Fichiers \u00e9crits :", paste0("  - ", ecrits), "")
  ecrire_f <- function(f, lignes) { con <- file(f, open = "wb"); writeLines(enc2utf8(lignes), con, useBytes = TRUE); close(con) }
  if (OPT_ECRIRE) {
    nv1 <- motifs_non_versionnable(commit_depot("tests/calibration_mc_t8.R"), empreintes_code("tests/calibration_mc_t8.R", SCRIPT_72), "de la combinaison")
    if (length(nv1)) refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv1, collapse = " ; "))
    cib <- file.path(RACINE, "docs", "tableaux", NOMS_297); names(cib) <- names(NOMS_297)
    rem <- garde_ecrasement(cib, OPT_REMPLACER, RACINE)
    if (!file.copy(F_BRUT_TMP, OPT_BRUT) || !identical(unname(tools::md5sum(OPT_BRUT)), MD5_BRUT)) refuser("copie --brut refusee ou md5 different")
    if (!file.copy(F_BRUT_TMP, cib[["brut"]], overwrite = TRUE) || !identical(unname(tools::md5sum(cib[["brut"]])), MD5_BRUT)) refuser("copie du brut refusee")
    ecrire_f(cib[["md"]], inserer_t0(sortie, c(ligne_remplacement(rem, cib[["md"]]), ligne_remplacement(rem, cib[["brut"]]))))
    ecrire_f(cib[["jcomb"]], journal_comb(vapply(c("md", "brut"), function(k) sprintf("%s md5 %s", NOMS_297[[k]], unname(tools::md5sum(cib[[k]]))), "")))
    message("\u00e9crit : ", paste(NOMS_297, collapse = ", "))
  } else {
    if (!is.na(OPT_SORTIE)) {
      cib <- file.path(OPT_SORTIE, NOMS_297); names(cib) <- names(NOMS_297)
      if (any(file.exists(cib))) refuser("--sortie : fichier(s) deja present(s), jamais ecrase(s)")
    }
    if (!is.na(OPT_BRUT)) { if (!file.copy(F_BRUT_TMP, OPT_BRUT)) refuser("copie --brut refusee"); message("\u00e9crit (valeurs brutes) : ", basename(OPT_BRUT)) }
    if (!is.na(OPT_SORTIE)) {
      file.copy(F_BRUT_TMP, cib[["brut"]]); ecrire_f(cib[["md"]], sortie)
      ecrire_f(cib[["jcomb"]], journal_comb(vapply(c("md", "brut"), function(k) sprintf("%s md5 %s", NOMS_297[[k]], unname(tools::md5sum(cib[[k]]))), "")))
      message("\u00e9crit : ", paste(NOMS_297, collapse = ", "), " (hors du d\u00e9p\u00f4t, non versionnable)")
    }
  }
  unlink(F_BRUT_TMP)
  quit(status = 0L)
}

###############################################################################
#  MODES --prevol-unite ET --prevol (pre-vol de la campagne 297, #297)
###############################################################################
# Unite de debit : replications b1..b2 de J1 puis de J2, chacune traitee par
# run_engine() complet (B = 999, graine GRAINE_BOOT + b) sur les jeux simules
# du meme flux que l'execution (GRAINE_JEUX, usp_simuler() du modele ajuste) ;
# une ligne "UNITE<TAB>jeu<TAB>b<TAB>duree (s)" par replication, FIN en
# derniere ligne.
if (MODE_LN == "unite") {
  m <- regmatches(OPT_B, regexec("^([0-9]+):([0-9]+)$", OPT_B))[[1]]
  if (length(m) != 3L) stop("--b : forme b1:b2 attendue")
  b1 <- as.integer(m[2]); b2 <- as.integer(m[3])
  if (b1 < 1L || b2 < b1) stop("--b : 1 <= b1 <= b2")
  for (j in c("J1", "J2")) {
    d <- if (j == "J1") list(x = .ln$xt, y = .ln$yt) else lire_j2()
    fit <- usp_ajuster(d$x, d$y)
    ys <- engine_sous_graine(GRAINE_JEUX, t(vapply(seq_len(b2), function(b) usp_simuler(fit), numeric(T_))))
    for (b in seq.int(b1, b2)) {
      t1 <- Sys.time()
      invisible(tryCatch(run_engine(xt = d$x, yt = ys[b, ], methode = METHODE, segment = SEGMENT, annexe = ANNEXE,
                                    nature_donnees = NATURE, B = B_BOOT, alpha = ALPHA, theta_equiv = THETA_EQUIV,
                                    seed = GRAINE_BOOT + b), error = function(e) NULL))
      writeLines(sprintf("UNITE\t%s\t%d\t%.3f", j, b, as.numeric(difftime(Sys.time(), t1, units = "secs"))))
    }
  }
  writeLines("FIN")
  quit(status = 0L)
}
# Pre-vol (specification de Fk, par. 5.5, point 5) : cout des controles
# d'une execution hors replications (lois discretes, controle (a), jeux
# simules et (e2) a R = 2 000), puis debit a 1, 2, 3 et 4 processus
# concurrents (les memes UNITES replications de J1 puis de J2 dans chaque
# processus) ; c_J1, c_J2 : duree moyenne par replication a
# un processus ; P_k = k x duree moyenne a un processus / duree moyenne a k
# processus. Ligne machine "PREVOL_LN<TAB>c_J1<TAB>c_J2<TAB>P1<TAB>P2<TAB>P3
# <TAB>P4<TAB>c_ctl", lue par tests/calibration_mc_mw_t8.R --prevol
# --campagne 297 --prevol-ln FICHIER. Rien d'ecrit (sortie console).
if (MODE_LN == "prevol") {
  secs <- function(t0) as.numeric(difftime(Sys.time(), t0, units = "secs"))
  ecrire_console(c("## Pr\u00e9-vol de la mesure #297 (Fk), volet lognormal (rien d'\u00e9crit)", "",
                   sprintf("Commit : %s ; plateforme : %s ; c\u0153urs (parallel::detectCores()) : %s ; d\u00e9but %s UTC",
                           commit_depot("tests/calibration_mc_t8.R"), plateforme_calcul(), tryCatch(parallel::detectCores(), error = function(e) "?"),
                           format(Sys.time(), "%Y-%m-%dT%H:%M:%S", tz = "UTC")), ""))
  t0 <- Sys.time(); invisible(lois_discretes()); t_lois <- secs(t0)
  t0 <- Sys.time(); ra <- executer_cas("premium")
  invisible(comparer_objets(neutraliser_instables(readRDS(chemin_reference("premium"))), neutraliser_instables(ra), tol = TOLERANCE))
  invisible(engine_table_tests(ra)); t_a <- secs(t0)
  t0 <- Sys.time(); fit <- usp_ajuster(.ln$xt, .ln$yt)
  invisible(engine_sous_graine(GRAINE_JEUX, t(vapply(seq_len(2000L), function(b) usp_simuler(fit), numeric(T_))))); t_y <- secs(t0)
  c_ctl <- t_lois + t_a + 2 * t_y
  RSCRIPT <- file.path(R.home("bin"), "Rscript")
  if (is.na(FICHIER_SCRIPT)) stop("--prevol : chemin du script introuvable (lancer par Rscript)")
  dossier <- tempfile("prevol297ln_"); dir.create(dossier)
  CB <- list()
  for (k in 1:4) {
    fs <- file.path(dossier, sprintf("k%d-%d.txt", k, seq_len(k)))
    # Memes replications 1..UNITES dans chaque processus : les durees de
    # replication varient beaucoup d'un jeu simule a l'autre (de 7 a 38 s
    # mesures au pre-vol du 25/10/2026, regime de delta chapeau*) ; des
    # indices differents par processus biaisaient P_k (P_4 = 4,55 mesure).
    for (i in seq_len(k)) {
      system2(RSCRIPT, c(shQuote(FICHIER_SCRIPT), "--prevol-unite", "--b", sprintf("1:%d", OPT_UNITES)),
              stdout = fs[i], stderr = sub("\\.txt$", ".err", fs[i]), wait = FALSE)
    }
    t_lim <- Sys.time() + 3600
    repeat {
      fini <- vapply(fs, function(f) file.exists(f) && any(readLines(f, warn = FALSE) == "FIN"), logical(1))
      if (all(fini) || Sys.time() > t_lim) break
      Sys.sleep(2)
    }
    if (!all(fini)) stop("--prevol : unite(s) de debit non terminee(s) en 1 h (k = ", k, ")")
    u <- do.call(rbind, lapply(fs, function(f) do.call(rbind, strsplit(grep("^UNITE\t", readLines(f), value = TRUE), "\t", fixed = TRUE))))
    CB[[k]] <- data.frame(jeu = u[, 2], d = as.numeric(u[, 4]), stringsAsFactors = FALSE)
  }
  unlink(dossier, recursive = TRUE)
  c_j <- vapply(c("J1", "J2"), function(j) mean(CB[[1]]$d[CB[[1]]$jeu == j]), 1)
  P_k <- vapply(1:4, function(k) k * mean(CB[[1]]$d) / mean(CB[[k]]$d), 1)
  ecrire_console(c("### Co\u00fbts et d\u00e9bit du volet lognormal", "",
                   sprintf(paste("Contr\u00f4les d'une ex\u00e9cution hors r\u00e9plications : %s s (lois discr\u00e8tes %s s ; contr\u00f4le (a) %s s ; jeux simul\u00e9s \u00e0",
                                 "R = 2 000, deux fois pour (e2), %s s). c_J1 = %s s et c_J2 = %s s par r\u00e9plication (run_engine() complet, un",
                                 "processus, %d r\u00e9plication(s) par jeu)."),
                           num(c_ctl, 1), num(t_lois, 1), num(t_a, 1), num(t_y, 1), num(c_j[["J1"]], 2), num(c_j[["J2"]], 2), OPT_UNITES), "",
                   entete_md(c("processus concurrents", "dur\u00e9e par r\u00e9plication (s) : moyenne [min ; max]", "d\u00e9bit agr\u00e9g\u00e9 P_k")),
                   vapply(1:4, function(k) ligne_md(k, sprintf("%s [%s ; %s]", num(mean(CB[[k]]$d), 2), num(min(CB[[k]]$d), 2), num(max(CB[[k]]$d), 2)),
                                                    num(P_k[k], 3)), ""), "",
                   "Ligne machine (fichier \u00e0 passer \u00e0 tests/calibration_mc_mw_t8.R --prevol --campagne 297 --prevol-ln) :", ""))
  writeLines(paste(c("PREVOL_LN", sprintf("%.4f", c(c_j[["J1"]], c_j[["J2"]], P_k, c_ctl))), collapse = "\t"))
  quit(status = 0L)
}

###############################################################################
#  EXECUTION (d'un seul tenant ou tranche)
###############################################################################
# Commit lu au debut du calcul (moteur et script charges), et non a la fin :
# une tranche longue ne doit pas consigner un commit fait pendant son calcul.
COMMIT <- commit_depot("tests/calibration_mc_t8.R")
EMPREINTES <- empreintes_code("tests/calibration_mc_t8.R", SCRIPT_72)
INTEGRITE <- character(0)          # libelles des controles en echec
CONTROLES <- character(0)          # lignes "libelle : OK / ECHEC"
controle <- function(ok, libelle) {
  ok <- isTRUE(ok)
  if (!ok) INTEGRITE <<- c(INTEGRITE, libelle)
  CONTROLES <<- c(CONTROLES, sprintf("%s : %s", libelle, if (ok) "OK" else "\u00c9CHEC"))
  invisible(ok)
}

# --- Jeu et modele ajuste (lire_j2() : definie plus haut)
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
    sw = paste("r\u00e9plication %d : sans effet sur la branche lognormale depuis #302 (aucune ligne n'emploie",
               "la loi nulle de Shapiro-Wilk) ; collision d\u00e9clar\u00e9e pour la lecture des tableaux ant\u00e9rieurs"))
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
# Lignes hors lecture conjointe (#297 : les lignes de engine_p_famille(),
# posees apres les autres et presentes selon les donnees, sont traitees a
# part, cles f|<famille>).
TAB_A <- engine_table_tests(RES_A)
TAB_A <- TAB_A[!TAB_A$fonction %in% "engine_p_famille", , drop = FALSE]
LIGNES <- TAB_A$test
FE_A <- fk_etats(RES_A$tests, RES_A$bootstrap, FAM_LN)
controle(fk_etats_ok(FE_A) && !anyNA(match(names(FE_A$f), FAM_LN)),
         sprintf("(k) J1 observ\u00e9 : lignes de lecture conjointe coh\u00e9rentes (\u00e9tats %s)",
                 paste(sprintf("%s %s (k = %d)", names(FE_A$f), vapply(FE_A$f, `[[`, "", "etat"), vapply(FE_A$f, `[[`, 1L, "k")), collapse = ", ")))
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
           identical(TAB_A$type[match(LIGNE_ESD, LIGNES)], "diagnostic") &&
           identical(TAB_A$verdict[match(LIGNE_ESD, LIGNES)], "INFO"),
         "Coh\u00e9rence : lignes et statistiques nomm\u00e9es par les constantes du script pr\u00e9sentes (ESD : diagnostic par d\u00e9cision, INFO, #304)")
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
# (t297) texte du critere de Fk (specification de Fk, par. 5.3), reporte
# sans modification.
TXT_SPEC_FK <- if (file.exists(file.path(RACINE, SPEC_FK))) readLines(file.path(RACINE, SPEC_FK), warn = FALSE, encoding = "UTF-8") else character(0)
controle(present_bloc(TEXTE_CRITERE_FK, TXT_SPEC_FK),
         sprintf("(t297) texte du crit\u00e8re de Fk (par. 5.3, K-F1 \u00e0 K-F4, profils \u03a60 \u00e0 \u03a65, %d lignes) identique \u00e0 %s (md5 %s)",
                 length(TEXTE_CRITERE_FK), SPEC_FK, unname(tools::md5sum(file.path(RACINE, SPEC_FK)))))
if (OPT_JEU == "J1")
  controle(identical(PARAM0$sigma_usp, RES_A$parametre_final$sigma_usp),
           "Coh\u00e9rence : \u03c3_USP de T0 (usp_parametre()) identique \u00e0 celui de run_engine() sur J1 observ\u00e9")
t_controle <- as.numeric(difftime(Sys.time(), t_c, units = "secs"))

# --- Replications ----------------------------------------------------------------------
cpt <- numeric(0)
ajoute <- function(cle, v = 1) { cpt[cle] <<- (if (cle %in% names(cpt)) cpt[[cle]] else 0) + v }
echecs_b <- list(b = integer(0), e1 = integer(0), c = integer(0), k = integer(0))
KF3 <- NULL                        # controle K-F3 (#297), premiere replication traitee
classe_nature <- function(nat) if (is.na(nat)) "aucune" else if (identical(nat, "exacte")) "exacte" else
  if (startsWith(nat, "Monte-Carlo")) "mc" else if (startsWith(nat, "asymptotique")) "asympt" else "autre"
# Colonnes de lecture conjointe (#297) en fin de ligne REP : par cle de
# famille, etat (CODE_ETAT), k, B effectif de famille, p, err_mc, m_obs de
# la ligne, plus petite p_mc des membres.
COLS_FK <- as.vector(t(outer(FAM_LN, c("etf", "kf", "bf", "pf", "ef", "sf", "minf"), function(f, c) paste0(c, ":", f))))
# err_mc et B effectif de chaque statistique (#297, avis d'actuary du
# 25/10/2026, point 2 ; symetrie avec eR: et BR: du volet Merz-Wuthrich),
# apres les p_mc.
REPCOLS <- c("b", "regime", paste0("p_mc:", names(USP_CATALOGUE_MC)), paste0("e_mc:", names(USP_CATALOGUE_MC)),
             paste0("B_eff:", names(USP_CATALOGUE_MC)), paste0("p_retenue:", LIGNES), COLS_FK)
REP <- character(0)
ligne_rep <- function(b, regime, p_mc, p_ret, fk = rep(NA_real_, length(COLS_FK)), e_mc = rep(NA_real_, N_STATS),
                      b_eff = rep(NA_real_, N_STATS))
  paste(c(b, regime, sprintf("%.17g", c(p_mc, e_mc, b_eff, p_ret, fk))), collapse = "\t")
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
  # (c) et T2. Lignes de lecture conjointe (#297) a part : cle f|<famille>,
  # sans n ni p retenue (n compte ci-dessous, par l'etat de la ligne).
  tab <- engine_table_tests(res)
  lfk <- tab$fonction %in% "engine_p_famille"
  if (!identical(tab$test[!lfk], LIGNES)) echecs_b$c <- c(echecs_b$c, b)
  for (k in seq_len(nrow(tab))) {
    li <- if (lfk[k]) sprintf("f|%s", substr(tab$famille[k], 1L, 2L)) else sprintf("l|%s", nettoyer_cle(tab$test[k]))
    if (!lfk[k]) ajoute(sprintf("%s|n", li))
    ajoute(sprintf("%s|t|%s", li, tab$type[k]))
    if (!is.na(tab$commentaire[k]) && startsWith(tab$commentaire[k], "TEST INOPERANT")) ajoute(sprintf("%s|inop", li))
    ajoute(sprintf("%s|nat|%s", li, classe_nature(tab$nature_p[k])))
    ajoute(sprintf("%s|v|%s", li, nettoyer_cle(tab$verdict[k])))
    if (lfk[k]) next
    # Ligne ESD (#304) : k chapeau lu dans la colonne estimation (k = 2 a
    # T = 8 : k chapeau = 2 <=> k chapeau >= 2).
    if (identical(tab$test[k], LIGNE_ESD) && is.finite(tab$estimation[k])) {
      if (tab$estimation[k] >= 1) ajoute(sprintf("%s|kesd1", li))
      if (tab$estimation[k] >= 2) ajoute(sprintf("%s|kesd2", li))
    }
    p <- tab$p_retenue[k]
    if (is.finite(p)) {
      ajoute(sprintf("%s|np", li))
      if (p < ALPHA) ajoute(sprintf("%s|k1", li))
      if (p < ALPHA2) ajoute(sprintf("%s|k2", li))
    }
  }
  # K-F2 (#297) : au moins une ALERTE ou un ECHEC, au moins un ECHEC, parmi
  # les lignes de type test.
  if (any(tab$type == "test" & tab$verdict %in% c("ALERTE", "ECHEC"))) ajoute("mult|ae")
  if (any(tab$type == "test" & tab$verdict %in% "ECHEC")) ajoute("mult|e")
  # Restreint aux lignes de sens "ne pas rejeter" (avis d'actuary du
  # 25/10/2026, point 1 : hors TOST et Pitman, seules lignes de sens
  # "rejeter").
  npr <- tab$type == "test" & tab$sens_du_test %in% "ne pas rejeter"
  if (any(npr & tab$verdict %in% c("ALERTE", "ECHEC"))) ajoute("mult|ae_npr")
  if (any(npr & tab$verdict %in% "ECHEC")) ajoute("mult|e_npr")
  # Lecture conjointe (#297) : etat de chaque ligne de famille (fk_etats(),
  # controle (k)), K-F1 (n, absences T-3b, rejets), composition (k, masse au
  # plancher), K-F2 (plus petite p_mc des membres < alpha), K-F4 (|p - s| <
  # 2 err_mc) ; controle K-F3 sur la premiere replication traitee.
  fe <- fk_etats(res$tests, bt, FAM_LN)
  if (!fk_etats_ok(fe)) echecs_b$k <- c(echecs_b$k, b)
  if (is.null(KF3)) KF3 <- c(list(b = b), fk_recalcul(res$tests, bt, USP_CATALOGUE_MC, FAM_LN))
  for (f in FAM_LN) {
    x <- fe$f[[f]]
    ajoute(sprintf("f|%s|kf|%d", f, x$k))
    if (x$etat %in% c("L", "N")) {
      ajoute(sprintf("f|%s|n", f))
      if (x$etat == "N") ajoute(sprintf("f|%s|na", f)) else {
        if (x$p < ALPHA) ajoute(sprintf("f|%s|k1", f))
        if (x$p < ALPHA2) ajoute(sprintf("f|%s|k2", f))
        if (abs(x$p - 1 / (x$bf + 1)) < 1e-12) ajoute(sprintf("f|%s|pl", f))
        if (abs(x$p - ALPHA) < 2 * x$e) ajoute(sprintf("f|%s|fr1", f))
        if (abs(x$p - ALPHA2) < 2 * x$e) ajoute(sprintf("f|%s|fr2", f))
      }
    }
    if (is.finite(x$minp) && x$minp < ALPHA) ajoute(sprintf("f|%s|m1", f))
    if (is.finite(x$minp) && x$minp < ALPHA2) ajoute(sprintf("f|%s|m2", f))
  }
  # K-F4 par statistique du catalogue (#297) : |p_mc - s| < 2 err_mc.
  for (s_ in names(USP_CATALOGUE_MC)) {
    p <- unname(bt$p_mc[s_]); e <- unname(bt$err_mc[s_])
    if (is.finite(p) && is.finite(e)) {
      ajoute(sprintf("fr|%s|n", s_))
      if (abs(p - ALPHA) < 2 * e) ajoute(sprintf("fr|%s|1", s_))
      if (abs(p - ALPHA2) < 2 * e) ajoute(sprintf("fr|%s|2", s_))
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
  REP <- c(REP, ligne_rep(b, reg, unname(bt$p_mc[names(USP_CATALOGUE_MC)]), tab$p_retenue[!lfk][match(LIGNES, tab$test[!lfk])],
                          unlist(lapply(FAM_LN, function(f) { x <- fe$f[[f]]
                            c(CODE_ETAT[[x$etat]], x$k, x$bf, x$p, x$e, x$m, x$minp) })),
                          unname(bt$err_mc[names(USP_CATALOGUE_MC)]), unname(bt$B_effectif[names(USP_CATALOGUE_MC)])))
}
t_rep <- as.numeric(difftime(Sys.time(), t_r, units = "secs"))
n_rep <- FIN - DEBUT + 1L
liste_b <- function(v) if (length(v)) paste0(" : r\u00e9plication(s) ", paste(utils::head(unique(v), 20), collapse = ", "),
                                              if (length(unique(v)) > 20) ", ..." else "") else ""
controle(!length(echecs_b$b), sprintf("(b) noms de bootstrap$p_mc et motif_mc = les %d du catalogue, p_mc absente avec motif, \u00e0 chaque r\u00e9plication trait\u00e9e%s",
                                      N_STATS, liste_b(echecs_b$b)))
controle(!length(echecs_b$c), sprintf("(c) %d lignes hors lecture conjointe, m\u00eames libell\u00e9s et m\u00eame ordre que J1 observ\u00e9, \u00e0 chaque r\u00e9plication trait\u00e9e%s",
                                      N_LIGNES, liste_b(echecs_b$c)))
controle(!length(echecs_b$k),
         sprintf(paste("(k) lignes de lecture conjointe (#297, cl\u00e9s %s) : \u00e9tats 1 (ligne et p), 2 (ligne sans p, T-3b) ou 0 (pas de ligne, k \u2264 1)",
                       "seulement, coh\u00e9rents avec k et le B effectif de famille recompt\u00e9s par le script (\u00e9tat -2 : bootstrap$stats_boot",
                       "absent, jamais confondu avec une ligne absente pour k \u2264 1), \u00e0 chaque r\u00e9plication trait\u00e9e%s"),
                 paste(FAM_LN, collapse = ", "), liste_b(echecs_b$k)))
controle(!is.null(KF3) && isTRUE(KF3$ok),
         sprintf(paste("(K-F3) premi\u00e8re r\u00e9plication trait\u00e9e (b = %s) : p de famille, m_obs, err_mc et k recalcul\u00e9s dans le script",
                       "(fk_recalcul(), R de base, \u00e9criture ind\u00e9pendante d'engine_p_famille()) depuis bootstrap$stats_boot, stats_obs,",
                       "le catalogue et les lignes, identiques (identical()) aux champs des lignes : %s"),
                 if (is.null(KF3)) "\u2014" else KF3$b, if (is.null(KF3)) "aucune r\u00e9plication trait\u00e9e" else KF3$txt))
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
  tailles = txt_tailles(TAILLES),
  essai = if (OPT_ESSAI) "oui" else "non",
  empreinte_sc = empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R")))
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
if (OPT_ESSAI) S <- c(S, "**Essai (--essai) : non versionnable.**", "")
CEL_FK1 <- cellules_fk_ln(stats::setNames(list(cpt), OPT_JEU))
S <- c(S, aide_lecture(), tb$lignes, tableau_fk1_ln(CEL_FK1), tableau_fk2_ln(stats::setNames(list(cpt), OPT_JEU)),
       "### Contr\u00f4les d'int\u00e9grit\u00e9", "", paste("-", CONTROLES), "",
       sprintf("Bilan : %s", if (length(INTEGRITE)) sprintf("\u00c9CHEC (%d contr\u00f4le(s))", length(INTEGRITE)) else "OK"), "")
MACHINE <- c(paste0("PARAMETRES\t", PAR), sprintf("TRANCHE\t%d\t%d", DEBUT, FIN),
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
                 sprintf("FIN\t%d", length(cpt)))
# --sortie-tranche : sortie complete dans le fichier (ecrite d'un bloc, a la
# fin ; FIN en derniere ligne), markdown aussi sur la console.
ecrire_console(S)
if (is.na(OPT_SORTIE_TR)) ecrire_console(MACHINE) else {
  if (file.exists(OPT_SORTIE_TR)) stop("--sortie-tranche : fichier apparu pendant le calcul, jamais ecrase")
  con <- file(OPT_SORTIE_TR, open = "wb"); writeLines(enc2utf8(c(S, MACHINE)), con, useBytes = TRUE); close(con)
  message("ecrit (sortie, md5 ", unname(tools::md5sum(OPT_SORTIE_TR)), ") : ", basename(OPT_SORTIE_TR))
}
quit(status = if (length(INTEGRITE)) 1L else 0L)
