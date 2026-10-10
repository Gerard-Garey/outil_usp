###############################################################################
#  tests/p_conditionnelle_regime_t8.R  --  MESURE EMBOITEE DE LA P-VALUE
#  MONTE-CARLO CONDITIONNELLE AU REGIME DE DELTA CHAPEAU, A T = 8
#  (issue #229, etapes 5 et 6)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils et tools, livres avec R : utils::sessionInfo(),
#  tools::md5sum()). Il ne modifie ni R/engine.R ni tests/reference/.
#  Sortie en markdown sur la console (UTF-8) ; fichiers ecrits SEULEMENT sur
#  option explicite (--sortie-tranche, --ecrire, --sortie, --brut).
#
#  Protocole : specification d'actuary
#  docs/specifications/229-p-conditionnelle-regime.md, approuvee par le
#  mainteneur au point d'arret A1 (annotation du 09/10/2026) : par. 1
#  (variantes V1, V3a, V3b, V3h ; familles F_T, F_R, F_8), par. 2 (critere C1
#  a C5 et profils D1 a D5, evalues mecaniquement SANS CONCLURE), par. 3
#  (jeux J1, J2, J3, R, graines), par. 5 (realisation de V3b, levier P1),
#  par. 6 (partie P), par. 7 (leviers P1, P3, P4 ; controles), par. 8
#  (tranches, sorties). Le texte des par. 2.1 et 2.2 est reporte sans
#  modification dans TEXTE_CRITERE_229 (copie declaree de
#  tests/grille_regime_t8.R ; controle (t)). Points ouverts lus selon
#  l'annotation d'actuary "lecture des points ouverts de la grille" (L0 a
#  L14) quand elle vaut pour l'etape 6 : L6 (bande non applicable si la
#  reference est inferieure a 2/n), L8 (scenarios de P, ordre des tirages et
#  md5), L9 (C1b au seuil alpha a la lettre), L13 (V3a et lois discretes :
#  descriptives dans C1a et C2b). L4 (probabilite de rejet predite) ne sert
#  pas : la mesure est a B fini reel. L10 (deux lectures d'un McNemar
#  PREDIT) : a l'etape 6, les decisions sont mesurees et le McNemar exact
#  porte sur les paires discordantes mesurees, seule lecture disponible.
#  Annotations du 10/10/2026 : L15 (lecture de C5 : temoin significatif
#  explique si la difference V3b - V1 mesuree a le signe predit par la
#  grille et reste a moins de e* de la prediction), L16 (portee de L15 :
#  chaque jeu, J1 aux bords, chaque seuil ; difference predite pi(V3b) -
#  pi(V1) du T1 predit de la grille ; e* du jeu et du seuil, J3 : celui de
#  J2 ; difference absente ou nulle : non explique), L17 (ajouts de (h1) :
#  tirages ajoutes de la region r_b ; hors regime, aucune statistique sous
#  P1), L18 (C1 et C4 en defaut, C2 et C3 remplies : signale hors de la
#  table du par. 2.3, sans profil ni conclusion), L19 (C3 : absences
#  ventilees par motif dans le detail ; o, c, x refuses par (b)), L20 (C2a
#  sur J3 vide, m3 = 0 : remplie, signalee dans le tableau des profils).
#  Tableau de la grille de reference : docs/tableaux/20261010-issue229-
#  grille.md (par defaut, le plus recent).
#
#  Statut des valeurs : CONSTAT DE SIMULATION SOUS DES MODELES AJUSTES (J1,
#  J2), SOUS UN MODELE SYNTHETIQUE (J3) ET SOUS SIX ALTERNATIVES (P), pas un
#  resultat general. Aucune reference ne fonde V3 a T = 8 (specification,
#  par. 10).
#
#  Variantes (par. 1), toutes sur les memes y** de la replication b :
#    V1  : rejeu de usp_bootstrap(fit*_b, B = 999, seed = 20260831 + b)
#          (memes appels, meme ordre, meme graine) ; p par .mc_p_values() sur
#          le catalogue complet USP_CATALOGUE_MC, contexte observe (conditions
#          degenere et non_definie) ; levier P3 : usp_ajuster_contraint() (sans
#          alea, bootstrap restreint de #45, hors perimetre) omis du rejeu, et
#          retabli sur l'echantillon de (i2) ;
#    V3a : parmi les tirages retenus de V1, ceux dont le regime de delta** est
#          celui de delta*_b (TOL_DELTA_BORD) ; meme calcul de p ;
#    V3b : V3a completee, sous engine_sous_graine(20800000 + b), par des
#          tirages y = usp_simuler(fit*_b), reajustes par
#          usp_ajuster_rapide(x, y, delta*_b, gamma*_b), jusqu'a 999 retenus
#          dans le regime ou jusqu'a 25 000 tirages au total (999 de V1
#          compris) ; levier P1 : un reajustement en echec ou de regime
#          different fait passer au tirage suivant SANS calcul des
#          statistiques ; une erreur des statistiques fait passer au suivant ;
#          p absente (motif d'engine_p_mc()) si le B effectif est inferieur a
#          B_MIN_DEGENERESCENCE. Rapportes : tirages, retenus, motif d'arret
#          (cible si et seulement si 999 retenus) ;
#    V3h : V3b si delta*_b est interieur, V1 sinon, sans tirage
#          supplementaire (calculee a la combinaison, colonnes de V1 et V3b).
#  Jeu observe (J1, J2 ; T3) : b = 0, bootstrap sous 20260831, flux de V3b
#  sous 20800000 + 0 (graine declaree en T0).
#  T2 (sans toucher au moteur, par. 7) : usp_tests(fit*_b, boot_v,
#  alpha = 0,10, theta_equiv = 0,10, methode = "premium", lr_delta = NULL,
#  permutation_pente = usp_permutation_pente(x, y*_b, B = 999,
#  seed = 20260831 + b, unilateral = .pitman_unilateral())), boot_v etant la
#  liste de V1 dont p_mc, err_mc, B_effectif, granularite_stat et motif_mc
#  sont ceux de la variante ; delta_equiv et robustesse absents (comme
#  run_engine() a delta_equiv NULL). Lignes de T2 : les 48 lignes du
#  perimetre (51 lignes de run_engine() moins les deux lignes du rapport de
#  vraisemblance sur delta et la largeur de l'IC a delta fixe, #45) ; les
#  lignes du jackknife et de la largeur de l'IC bootstrap 90 %, que
#  usp_tests() n'ecrit que si run_engine() a pose ces grandeurs dans fit,
#  sont absentes de ce chemin (code "-") : diagnostics sans p retenue (aucune
#  p retenue dans les valeurs brutes de #221), leur verdict ne depend pas de
#  la variante. La regle R4 en vigueur au commit mesure est citee en T0.
#  Partie P : jeux des six scenarios (par. 6) sur le modele ajuste de J2,
#  generes EXACTEMENT comme tests/grille_regime_t8.R (generer_scenario(),
#  copie declaree ; annotation, L8) : sous engine_sous_graine(20810000 + s),
#  d'abord la matrice des epsilon, R_P x 8, remplie ligne par ligne (rnorm()
#  pour H et C, rchisq(nu) pour A), puis pour C seulement le vecteur des t*
#  (sample.int(8, R_P, replace = TRUE)) ; matrices TOUJOURS tirees a
#  R_P = 1 000 complet, une tranche y prend ses lignes ; md5 des epsilon, des
#  t* et des Y compares a ceux du T0 de la grille (controle (l8)).
#  Intensites : constantes INTENSITES en tete (ajustables par la decision A2
#  sans toucher au reste), citees en T0. Bootstrap et flux de V3b de la
#  replication b : memes graines que les jeux (20260831 + b, 20800000 + b).
#  T2 n'est pas calcule en partie P (puissance des p_mc seulement).
#
#  Controles d'integrite (une tranche en echec ecrit INTEGRITE ECHEC, et
#  --combiner refuse) :
#    (a)  J1 observe par run_engine(seed = 20260831) (executer_cas("premium"))
#         conforme a tests/reference/premium.rds (regenere par P2) par
#         comparer_objets() apres neutraliser_instables() ;
#    (b)  noms et sens de rejet lus dans USP_CATALOGUE_MC (34) ; F_T et F_R
#         en partition des 34 ; F_8 et les ensembles cibles dans F_R ; noms
#         des p de chaque variante = catalogue, dans son ordre ; motifs
#         d'absence connus (codes de CODES_MOTIF) ; p de V3a ou de V3b
#         absente alors que celle de V1 existe (cellules comptees par C3) :
#         motif ni o, ni c, ni x (motifs communs a V1) ; 51 lignes de usp_tests()
#         sur J1 observe, libelles distincts, 48 lignes du perimetre de T2 ;
#    (c)  jeux simules identiques (identical()) a l'expression YSIM de #72
#         (tests/taux_franchissement_reperes.R, lue par parse(), liste
#         blanche de noms, environnement isole ; J3 : FIT0_J3 synthetique) ;
#         J1, J2 : regime de delta*_b (ou ecartee) identique a celui des
#         valeurs brutes de #221 ; J3 : identique a celui de la couche
#         verite des valeurs brutes de la grille (c-J3 ; --grille-brut, md5
#         egal a celui du T0 du tableau de la grille) ;
#    (i1) J1, J2 : p de V1 = p_mc des valeurs brutes de #221 (%.17g) au bit
#         pres, pour chaque (b, s) ; une discordance n'est admise que si elle
#         est expliquee et listee : recalcul du rejeu avec la
#         contre-implementation lm() / anova() des six statistiques de P2
#         (CAT_CONTRE, contre_*() de tests/outils_tests.R), qui doit redonner
#         la p de #221, avec pour cause (1) une quasi-egalite (h2) de la
#         statistique (de P2) ou (2) un changement de retention d'un tirage
#         (retenues differentes entre le rejeu et son recalcul) ; sinon
#         echec bloquant ;
#    (i2) identical() avec usp_bootstrap() (stats_obs, p_mc, err_mc,
#         B_effectif, granularite_stat, motif_mc, sigma_boot, delta_boot,
#         gamma_boot, sigma_boot_restreint, n_echec_restreint, z_boot) du
#         rejeu complet (usp_ajuster_contraint() retabli), et rejeu complet
#         identique au rejeu allege (P3 : memes statistiques simulees et
#         memes delta**), sur l'echantillon : jeu observe (J1, J2), premiere
#         replication traitee et premiere replication interieure de la
#         tranche ; J1 observe : p de V1 aussi identiques aux p_mc de
#         run_engine() du controle (a) ;
#    (i3) empreinte sans commentaires de R/engine.R (#231,
#         empreinte_sans_commentaires()) egale a celle du (g5) du tableau de
#         la grille (--grille, par defaut le plus recent
#         docs/tableaux/<AAAAMMJJ>-issue229-grille.md), puis, par --combiner,
#         egale dans toutes les tranches et a la combinaison, et, avec
#         --journal, egale a celle de la ligne "Empreinte sans
#         commentaires" du JOURNAL (refus sinon) ; md5 du
#         fichier entier cite ; md5 du moteur du T0 de #221 cite pour memoire ;
#    (s1) sur l'echantillon de (i2) : V3b recalculee SANS P1 (34 statistiques
#         a chaque tirage reajuste) ; p, tirages et B effectifs identiques ;
#    (h1) premiere replication traitee de la tranche : sur tous ses tirages
#         reajustes (V1 et ajouts de V3b evalues) et sur son contexte
#         observe, les six fonctions de P2 (test_breusch_pagan_original(),
#         test_breusch_pagan(), test_white(), test_brown_forsythe(),
#         test_reset(), .usp_lm_pondere()) egales a leur contre-implementation
#         a 1e-12 relatif pres, NA et motifs identiques (regle de
#         tests/unitaires/test_regressions_qr.R, copie declaree) ;
#    (h2) pour chaque replication et chacune des six statistiques de P2
#         (BP, BP79, White, BF, RESET, Intercept) : nombre de tirages (V1
#         retenus et ajouts de V3b) tels que |S_sim - S_obs| <=
#         1e-9 max(1, |S_obs|), ecrit dans la ligne REP et rapporte en T3 ;
#    (v3a) J1, J2 : p de V3a = p3 des valeurs brutes de #175 sur les couples
#         (b, s) communs (jeu observe compris), B3 egal ; discordance admise
#         si le recalcul du rejeu a la maniere de #175 (retention sur le
#         sous-catalogue du regime de #175, contre-implementation de P2)
#         redonne p3 et B3, avec pour cause (h2) ou l'angle mort du
#         sous-catalogue (retenues differentes) ; listee ;
#    (t2) J1, J2 : p retenues des 48 lignes de T2 recalculees avec V1 =
#         p_retenue des valeurs brutes de #221, au bit pres ; une discordance
#         n'est admise que sur une ligne dont la statistique Monte-Carlo a
#         une discordance (i1) expliquee dans la meme replication ;
#    (l8) partie P : md5 des epsilon, des t* et des Y du scenario egaux a
#         ceux du T0 du tableau de la grille ;
#    (t)  texte du critere identique a la specification ; titres des
#         annotations du 09/10/2026 (A1 ; L0 a L14) et du 10/10/2026 (A2 et
#         L15 ; points ouverts du script, L16 a L20) presents ;
#    (graines) aucune collision non declaree entre les graines du script ;
#         collisions heritees declarees (replications 96 et 70) ;
#    (d)  invariants : |A| <= 999, B effectifs <= retenues, tirages <=
#         25 000, arret "cible" si et seulement si |A| = 999, comptes des
#         tirages de V3b coherents, retenues de V1 = 999 - echecs.
#
#  Critere (par. 2), evalue a la combinaison, SANS CONCLURE (verdict :
#  actuary ; cible : mainteneur, A3). Decision D_v(b) = 1 si p_v(b) < alpha,
#  p absente = non-rejet. Population : J2 et J3, replications traitees
#  (statut "traitee") ; exclues et comptees en T3 : les replications
#  ecartees (refus de #188, ou erreur de usp_ajuster() : statut "ecartee")
#  et les replications en erreur (statut "erreur" : toute autre erreur du
#  traitement d'une replication, usp_tests() compris, rattrapee par
#  tryCatch ; ligne REP avec b, regime de delta*_b s'il est connu, "-"
#  sinon, et message d'erreur dans la colonne discordances, sans tabulation
#  ni saut de ligne). Une replication en erreur n'arrete pas la tranche et
#  ne met pas INTEGRITE en ECHEC ; --combiner refuse toute tranche qui en
#  contient, et les liste (b, message). Le pre-vol --prevol les cherche
#  avant la mesure ;
#  J1 : replications a delta* au bord (interieur descriptif). Taux k / n,
#  IC de Clopper-Pearson a 95 %, classes de #166 (bande de Bradley
#  [ref/2 ; 3 ref/2], ref = alpha, ou taille lissee de #166 a B = 999 pour
#  une loi discrete, lue dans le T0 des tableaux de #221 ; bande non
#  applicable si ref < 2/n, L6). McNemar exact (test binomial bilateral de
#  parametre 1/2 sur les paires discordantes), Holm au niveau 0,05 par
#  famille : (jeu, alpha) sur F_R pour C1b et T1, (jeu, regime, alpha) sur
#  F_R pour T1 bis, (jeu, alpha) sur F_T pour C5, (scenario, alpha) sur F_R
#  pour C4a, (scenario, alpha = 0,10, ensemble cible) a delta* interieur
#  pour C4b ; les statistiques de F_T de T1 et T1 bis forment leur propre
#  famille, descriptive. Profils D1 a D5 par variante (par. 2.3) ; en partie
#  regime, C4 est "en attente" et le profil n'est que partiel ; en partie
#  puissance, C1 a C3 sont relus dans les valeurs brutes de la partie regime
#  (--regime-brut, par defaut le plus recent
#  docs/tableaux/<AAAAMMJJ>-issue229-p-conditionnelle-regime-brut.tsv).
#
#  Alea : tout tirage passe par engine_sous_graine() (generateur
#  ENGINE_RNG_KIND) : jeux de J1, J2, J3 sous 20260927 (expression YSIM de
#  #72) ; bootstrap de la replication b sous 20260831 + b ; flux de V3b
#  sous 20800000 + b ; scenario s de P sous 20810000 + s. Aucune statistique
#  ne consomme d'alea du flux appelant (sw_loi_nulle() restaure l'etat) ; les
#  appels hors du chemin du moteur (contre-implementation, comparaisons de
#  (h1)) sont en outre proteges (.Random.seed restaure). Une replication ne
#  depend que de (jeu ou scenario, b) : une tranche relancee sur la meme
#  plateforme est la meme tranche. Collisions heritees de #166 (declarees en
#  T0) : la graine du bootstrap de la replication 96 est 20260927 (jeux), celle
#  de la replication 70 est SEED_LOI_NULLE_SW.
#
#  Usage (depuis la racine du depot, dans un git worktree au commit propre
#  cite) :
#      Rscript tests/p_conditionnelle_regime_t8.R --jeu J1|J2|J3 --tranche i/K
#          [--R 2000] [--sortie-tranche FICHIER [--reprendre PARTIELLE]]
#          [--grille TABLEAU.md] [--grille-brut FICHIER.tsv] [--essai]
#      Rscript tests/p_conditionnelle_regime_t8.R --scenario H0|H3|C3|C4|A4|A2 --tranche i/K
#          [--R-P 1000] [--sortie-tranche FICHIER [--reprendre PARTIELLE]]
#          [--grille TABLEAU.md] [--essai]
#      Rscript tests/p_conditionnelle_regime_t8.R --debit [--regime-debit interieur|bord0|bord1]
#      Rscript tests/p_conditionnelle_regime_t8.R --prevol --jeu J1|J2|J3 [--R 2000]
#      Rscript tests/p_conditionnelle_regime_t8.R --combiner f1 f2 ... | DOSSIER
#          --partie regime|puissance [--journal JOURNAL.md]
#          [--ecrire [--remplacer] --brut FICHIER --journal JOURNAL.md
#           | --sortie DOSSIER [--brut FICHIER]]
#          [--regime-brut FICHIER.tsv]
#  Tranche : i/K couvre b de floor((i - 1) R / K) + 1 a floor(i R / K).
#  Elle REFUSE (code 1, avant tout calcul) un commit non propre ou un code
#  hors du depot (motifs_non_versionnable()), sauf --essai (essai de mise
#  au point, marque en T0, refuse par --combiner --ecrire). --R, --R-P :
#  parametres reduits (essais ; --ecrire exige R = 2 000 et R_P = 1 000).
#  --sortie-tranche FICHIER : sortie complete de la tranche (markdown et
#  lignes machine) dans FICHIER, HORS du depot, jamais ecrase ; sans elle,
#  sur la console. Ecriture AU FIL DE L'EAU : l'en-tete machine
#  (PARAMETRES, TRANCHE, CONTEXTE, STATS, REPCOLS, OBS) des la fin des
#  controles generaux et du jeu observe, puis une ligne REP par replication
#  (flush), puis le markdown de la tranche, puis DUREE, REPRISE eventuelle,
#  INTEGRITE, NREP et FIN (derniere ligne). Une tranche interrompue laisse
#  son en-tete et ses replications faites. Nommage dans la sauvegarde
#  (par. 8) : sauvegarde/issue229/<jeu|scenario>-<ii>de<KK>.txt.
#  --reprendre PARTIELLE (avec --sortie-tranche NOUVEAU, autre fichier) :
#  relit une sortie de tranche partielle (sans ligne FIN ; jamais modifiee),
#  exige un en-tete identique a celui de l'execution (parametres, tranche,
#  contexte : commit, plateforme, empreintes du code, empreinte #231,
#  generateur, sources ; catalogue, colonnes, jeu observe), reprend telles
#  quelles ses lignes REP lisibles de la tranche (une replication ne depend
#  que de (jeu ou scenario, b) : resultat identique sur la meme plateforme)
#  et ne calcule que les replications manquantes ; une ligne tronquee est
#  ignoree et recalculee. Les replications de l'echantillon de (h1), (i2),
#  (s1) sont toujours recalculees, et doivent redonner la ligne reprise hors
#  duree (controle (reprise)). Ligne machine REPRISE (fichier, md5, reprises,
#  recalculees, ignorees), citee par --combiner en T0.
#  --grille : tableau de la grille (controles (i3), (l8), md5 des valeurs
#  brutes de la grille) ; --grille-brut : valeurs brutes de la grille
#  (obligatoire pour J3, controle (c-J3)).
#  --debit (levier P4) : trois replications de J2 du regime demande
#  (interieur par defaut), premieres de la suite YSIM, traitees comme dans
#  une tranche (sans les controles d'echantillon) ; duree par replication.
#  Lancer 2, 3 et 4 executions concurrentes pour le debit agrege.
#  --prevol --jeu J (pre-vol, sans bootstrap, rien d'ecrit) : sur les R jeux
#  simules de J (suite YSIM, R = --R, 2 000 par defaut), usp_ajuster() et
#  usp_valider_ajustement(), puis, pour une replication validee,
#  usp_permutation_pente(B = 999, seed = 20260831 + b) comme la mesure,
#  puis usp_tests() (memes arguments que T2) deux fois : (1) liste
#  bootstrap factice, statistiques observees du catalogue et p de V1
#  reduites a des valeurs valides (J1, J2 : p_mc des valeurs brutes de #221
#  de la replication ; J3, sans valeurs brutes de #221 : celles de J2 au
#  meme b ; p absente remplacee par 0,5, p bornee a [k/(B + 1) ; 1], k = 2
#  en sens "deux", 1 sinon ; statistique observee non finie : p absente,
#  motif d'obs. non finie) ; (2) toutes les p absentes (cas R3 : B effectif
#  B_MIN_DEGENERESCENCE - 1, motif des replications insuffisantes). Rapporte
#  le nombre d'erreurs par fonction et les b concernes. Code 0 sans erreur,
#  1 sinon.
#  Lignes machine d'une tranche : PARAMETRES, TRANCHE, CONTEXTE, STATS,
#  REPCOLS, OBS (jeu observe ; "sans objet" pour J3 et P), une ligne REP
#  par replication, puis DUREE, REPRISE (si --reprendre), INTEGRITE, NREP,
#  FIN (derniere ligne). Les controles (b), (c), (d), (i1), (t2), (v3a)
#  sont evalues sur les champs de chaque ligne REP (calculee ou reprise),
#  (b) et (d) aussi sur les objets des replications calculees.
#  --combiner lit les fichiers de tranches (chemins, ou un DOSSIER dont il
#  prend les fichiers <jeu|scenario>-<ii>de<KK>.txt) de la partie demandee et
#  recalcule les tableaux par les memes fonctions qu'une tranche. Il REFUSE
#  (code 1, sans tableau) : une tranche sans INTEGRITE OK ou sans FIN en
#  derniere ligne ; un nombre de REP different de NREP ou de FIN ; une
#  tranche d'une autre partie ; des PARAMETRES, un CONTEXTE, des STATS, des
#  REPCOLS ou une ligne OBS differents entre tranches d'un meme jeu ou
#  scenario ; un commit, une plateforme, une empreinte (#231), un
#  generateur ou des empreintes de code differents entre toutes les
#  tranches ; une couverture de 1..R qui n'est pas exactement une fois ; un
#  invariant du corps faux ; une replication au statut "erreur" (liste des
#  b et messages) ; avec --journal, un md5 de tranche absent du JOURNAL ou
#  different (ligne du JOURNAL qui porte le nom du fichier et son md5), une
#  ligne "Debit P4" absente ou multiple, une ligne "Empreinte sans
#  commentaires" absente, multiple ou d'empreinte differente de celle des
#  tranches (controle (i3)). Format attendu des deux lignes du JOURNAL
#  (markdown, une ligne chacune ; "Debit" avec ou sans accent) :
#      - Debit P4 : <texte libre, cite tel quel en T0>
#      - Empreinte sans commentaires : <md5 de 32 caracteres hexadecimaux>
#  --journal est obligatoire avec --ecrire (refus d'usage sinon).
#  --ecrire (avec --combiner) : ecrit dans docs/tableaux/ (date du jour) le
#  tableau ET ses valeurs brutes :
#    partie regime    : <AAAAMMJJ>-issue229-p-conditionnelle-regime.md et
#                       <AAAAMMJJ>-issue229-p-conditionnelle-regime-brut.tsv ;
#    partie puissance : <AAAAMMJJ>-issue229-p-conditionnelle-puissance.md et
#                       <AAAAMMJJ>-issue229-p-conditionnelle-puissance-brut.tsv
#  (brut versionne : decision du mainteneur a A1, Q-A1-9), nouveaux et
#  jamais patches. --brut FICHIER est obligatoire (refus d'usage sinon) :
#  copie des valeurs brutes HORS du depot (branche de sauvegarde), ecrite
#  AVANT le brut versionne et le tableau. --ecrire REFUSE (code 1, rien
#  d'ecrit) : commit des tranches ou de la combinaison non propre, code hors
#  du depot, tranche --essai, jeux J1, J2, J3 (ou six scenarios) non tous
#  presents ou parametres reduits, sources de #221, de #175 ou de la grille
#  non suivies par git ou modifiees depuis les tranches (md5), un fichier
#  cible suivi par git sans --remplacer (garde_ecrasement(), #173). Gardes
#  anticipees (#205) : commit et code de la combinaison, dossier
#  docs/tableaux/ et garde d'ecrasement evalues des l'analyse des options,
#  avant la lecture des tranches, puis de nouveau avant d'ecrire.
#  --remplacer : avec --ecrire seulement (le T0 cite le fichier remplace et
#  son md5 d'avant). --sortie DOSSIER : tableau et valeurs brutes, memes
#  noms, dans DOSSIER, HORS du depot (jamais ecrases).
#
#  Fonctions reprises par copie declaree (ces scripts executent leur calcul
#  au chargement et ne peuvent pas etre sources) : de
#  tests/conservatisme_interieur_t8.R : plateforme_calcul(), meme_fichier(),
#  empreintes_code(), sous_depot(), ecrire_console(), ligne_md(),
#  entete_md(), num(), ic_cp(), txt_ic(), code_regime(), md5_fichier(),
#  chemin_cite(), suivi_git(), lire_j2(), nettoyer_champ(), controle (c)
#  (liste blanche NOMS_E2), controle (a), proteger(), structure du rejeu et
#  du controle (i2), lecture des sorties de tranche ; de
#  tests/grille_regime_t8.R : TEXTE_CRITERE_229, F_T, F_8, CIBLES,
#  SCENARIOS, LOI_STAT, LIB_LOI, lissees(), fit_synth(),
#  generer_scenario(), md5_valeurs() ; de tests/calibration_mc_t8.R :
#  STAT_LIGNE ; de tests/unitaires/test_regressions_qr.R : meme_num(),
#  concorde(), arguments des six paires. commit_depot(),
#  motifs_non_versionnable(), garde_ecrasement(), ligne_remplacement(),
#  inserer_t0(), empreinte_sans_commentaires(), contre_*() :
#  tests/outils_tests.R.
#  Code de sortie : 0 si les controles d'integrite tiennent, 1 sinon ; en
#  mode --combiner, 0 si la combinaison est acceptee, 1 si elle est refusee.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/p_conditionnelle_regime_t8.R"

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
OPTIONS_VALEUR <- c("--jeu", "--scenario", "--R", "--R-P", "--tranche", "--sortie-tranche", "--grille",
                    "--grille-brut", "--partie", "--journal", "--sortie", "--brut", "--regime-brut",
                    "--regime-debit", "--reprendre")
OPTIONS_DRAPEAU <- c("--ecrire", "--remplacer", "--essai", "--debit", "--prevol")
MODE_COMBINER <- FALSE
FICHIERS_COMB <- character(0)
local({
  i <- 1L
  while (i <= length(ARGS)) {
    a <- ARGS[i]
    if (a == "--combiner") {
      j <- i + 1L
      while (j <= length(ARGS) && !startsWith(ARGS[j], "--")) j <- j + 1L
      MODE_COMBINER <<- TRUE
      FICHIERS_COMB <<- ARGS[seq_len(j - i - 1L) + i]
      i <- j
    } else if (a %in% OPTIONS_VALEUR) {
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
entier <- function(nom, defaut) {
  v <- suppressWarnings(as.integer(lire_option(nom, as.character(defaut))))
  if (is.na(v) || v < 1L) stop(nom, " : entier >= 1")
  v
}
OPT_ECRIRE    <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_ESSAI     <- "--essai" %in% ARGS
OPT_DEBIT     <- "--debit" %in% ARGS
OPT_PREVOL    <- "--prevol" %in% ARGS
if (OPT_REMPLACER && !OPT_ECRIRE) stop("--remplacer : reserve a --ecrire (remplacement d'un tableau suivi par git, #173)")
# --ecrire sans --brut : le tableau citerait des valeurs brutes dont aucune
# copie n'est conservee hors du depot (comme tests/grille_regime_t8.R).
if (OPT_ECRIRE && !("--brut" %in% ARGS))
  stop("--ecrire : --brut FICHIER obligatoire (copie des valeurs brutes hors du depot, branche de sauvegarde)")
# --ecrire sans --journal : le T0 versionne ne citerait ni le debit P4 ni
# l'empreinte (#231) du JOURNAL (controle (i3)).
if (OPT_ECRIRE && !("--journal" %in% ARGS))
  stop("--ecrire : --journal FICHIER obligatoire (debit P4 et empreinte (#231) du JOURNAL, cites en T0 ; controle (i3))")
R_SPEC <- 2000L; RP_SPEC <- 1000L
OPT_JEU       <- lire_option("--jeu", NA_character_)
OPT_SCEN      <- lire_option("--scenario", NA_character_)
OPT_R         <- entier("--R", R_SPEC)
OPT_RP        <- entier("--R-P", RP_SPEC)
OPT_TRANCHE   <- lire_option("--tranche", NA_character_)
OPT_SORTIE_TR <- lire_option("--sortie-tranche", NA_character_)
OPT_GRILLE    <- lire_option("--grille", NA_character_)
OPT_GRILLE_BRUT <- lire_option("--grille-brut", NA_character_)
OPT_PARTIE    <- lire_option("--partie", NA_character_)
OPT_JOURNAL   <- lire_option("--journal", NA_character_)
OPT_SORTIE    <- lire_option("--sortie", NA_character_)
OPT_BRUT      <- lire_option("--brut", NA_character_)
OPT_REGIME_BRUT <- lire_option("--regime-brut", NA_character_)
OPT_REGIME_DEBIT <- lire_option("--regime-debit", "interieur")
OPT_REPRENDRE <- lire_option("--reprendre", NA_character_)
CODES_SCEN <- c("H0", "H3", "C3", "C4", "A4", "A2")
modes <- c(jeu = !is.na(OPT_JEU), scenario = !is.na(OPT_SCEN), combiner = MODE_COMBINER, debit = OPT_DEBIT)
if (sum(modes) != 1L) stop("un mode et un seul : --jeu, --scenario, --combiner ou --debit")
if (MODE_COMBINER && !length(FICHIERS_COMB)) stop("--combiner : aucun fichier")
if (!MODE_COMBINER && (OPT_ECRIRE || !is.na(OPT_SORTIE) || !is.na(OPT_BRUT) || !is.na(OPT_JOURNAL) ||
                       !is.na(OPT_PARTIE) || !is.na(OPT_REGIME_BRUT)))
  stop("--ecrire, --sortie, --brut, --journal, --partie et --regime-brut sont reserves a --combiner")
if (MODE_COMBINER && any(c("--jeu", "--scenario", "--R", "--R-P", "--tranche", "--sortie-tranche", "--grille",
                           "--grille-brut", "--essai", "--regime-debit", "--reprendre") %in% ARGS))
  stop("--R, --R-P, --tranche, --sortie-tranche, --grille, --grille-brut, --essai, --regime-debit et --reprendre sont reserves aux tranches")
if (MODE_COMBINER && !isTRUE(OPT_PARTIE %in% c("regime", "puissance")))
  stop("--combiner : --partie regime ou --partie puissance obligatoire")
if (!is.na(OPT_REGIME_BRUT) && !identical(OPT_PARTIE, "puissance")) stop("--regime-brut : reserve a --partie puissance")
if (OPT_ECRIRE && !is.na(OPT_SORTIE)) stop("--ecrire et --sortie sont exclusifs")
if (!is.na(OPT_SORTIE) && !dir.exists(OPT_SORTIE)) stop("--sortie : dossier introuvable : ", OPT_SORTIE)
if (!is.na(OPT_JEU) && !OPT_JEU %in% c("J1", "J2", "J3")) stop("--jeu : J1, J2 ou J3")
if (!is.na(OPT_SCEN) && !OPT_SCEN %in% CODES_SCEN) stop("--scenario : ", paste(CODES_SCEN, collapse = ", "))
if (OPT_DEBIT && any(c("--tranche", "--sortie-tranche", "--essai", "--reprendre") %in% ARGS))
  stop("--debit : ni --tranche, ni --sortie-tranche, ni --essai, ni --reprendre")
# --prevol : avec --jeu seulement ; rien d'ecrit.
if (OPT_PREVOL && is.na(OPT_JEU)) stop("--prevol : --jeu J1, J2 ou J3 obligatoire")
if (OPT_PREVOL && any(c("--tranche", "--sortie-tranche", "--essai", "--reprendre", "--grille", "--grille-brut") %in% ARGS))
  stop("--prevol : ni --tranche, ni --sortie-tranche, ni --essai, ni --reprendre, ni --grille, ni --grille-brut")
# --reprendre : la sortie partielle est relue, jamais modifiee ; la tranche
# reprise est ecrite dans un NOUVEAU fichier (--sortie-tranche).
if (!is.na(OPT_REPRENDRE)) {
  if (is.na(OPT_SORTIE_TR)) stop("--reprendre : --sortie-tranche FICHIER obligatoire (nouveau fichier ; la sortie partielle n'est jamais modifiee)")
  if (!file.exists(OPT_REPRENDRE)) stop("--reprendre : fichier introuvable : ", OPT_REPRENDRE)
  if (file.exists(OPT_SORTIE_TR) && normalizePath(OPT_REPRENDRE) == normalizePath(OPT_SORTIE_TR))
    stop("--reprendre : --sortie-tranche doit designer un autre fichier que la sortie partielle")
}
if (!OPT_DEBIT && "--regime-debit" %in% ARGS) stop("--regime-debit : reserve a --debit")
if (!OPT_REGIME_DEBIT %in% c("interieur", "bord0", "bord1")) stop("--regime-debit : interieur, bord0 ou bord1")
if (OPT_R > R_SPEC) stop("--R : au plus 2 000 (valeurs brutes de #221 et #175)")
if (OPT_RP > RP_SPEC) stop("--R-P : au plus 1 000 (matrices des scenarios tirees a R_P = 1 000 complet, L8)")
if (!is.na(OPT_JEU) && "--R-P" %in% ARGS) stop("--R-P : reserve a --scenario")
if (!is.na(OPT_SCEN) && "--R" %in% ARGS) stop("--R : reserve a --jeu (--R-P pour un scenario)")
if (!is.na(OPT_SCEN) && "--grille-brut" %in% ARGS) stop("--grille-brut : reserve a --jeu J3")

# --- Chargement du moteur et des outils --------------------------------------
FICHIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) f else NA_character_
})
DOSSIER_SCRIPT <- if (!is.na(FICHIER_SCRIPT)) dirname(FICHIER_SCRIPT) else
  if (file.exists("tests/outils_tests.R")) "tests" else "."
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))

# --- Outils (copies declarees de tests/conservatisme_interieur_t8.R) ----------
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
chemin_cite <- function(f) {
  if (is.na(f) || !file.exists(f)) return(as.character(f))
  a <- normalizePath(f, winslash = "/", mustWork = TRUE)
  r <- normalizePath(RACINE, winslash = "/", mustWork = TRUE)
  if (startsWith(a, paste0(r, "/"))) substring(a, nchar(r) + 2L) else a
}
suivi_git <- function(f) {
  if (is.na(f) || !file.exists(f) || !sous_depot(dirname(f))) return("non")
  code <- tryCatch(suppressWarnings(system2("git", c("--literal-pathspecs", "-C", shQuote(RACINE), "ls-files",
                                                    "--error-unmatch", "--", shQuote(chemin_cite(f))),
                                            stdout = FALSE, stderr = FALSE)),
                   error = function(e) NA_integer_)
  if (identical(as.integer(code), 0L)) "oui" else if (identical(as.integer(code), 1L)) "non" else "indetermine"
}
nettoyer_champ <- function(s) gsub("[\t\r\n]+", " ", s)
refuser <- function(...) {
  message("--combiner : REFUS -- ", ...)
  quit(status = 1L)
}

SCRIPT_72 <- file.path("tests", "taux_franchissement_reperes.R")
SPEC <- file.path("docs", "specifications", "229-p-conditionnelle-regime.md")

# --- Sorties et gardes anticipees (#205, #173) ---------------------------------
DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
NOMS_SORTIE <- list(
  regime = c(md = sprintf("%s-issue229-p-conditionnelle-regime.md", DATE_SORTIE),
             brut = sprintf("%s-issue229-p-conditionnelle-regime-brut.tsv", DATE_SORTIE)),
  puissance = c(md = sprintf("%s-issue229-p-conditionnelle-puissance.md", DATE_SORTIE),
                brut = sprintf("%s-issue229-p-conditionnelle-puissance-brut.tsv", DATE_SORTIE)))
CIBLES_ECRIRE <- if (MODE_COMBINER) file.path(RACINE, "docs", "tableaux", NOMS_SORTIE[[OPT_PARTIE]]) else character(0)
if (MODE_COMBINER) names(CIBLES_ECRIRE) <- c("md", "brut")
# --ecrire : commit et code de la combinaison, dossier docs/tableaux/ et
# garde d'ecrasement des deux cibles, avant la lecture des tranches ; repris
# avant d'ecrire.
if (OPT_ECRIRE) {
  nv0 <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, c(SCRIPT_72, SPEC)), "de la combinaison")
  if (length(nv0)) {
    message("--combiner : REFUS -- --ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv0, collapse = " ; "),
            " -- relancer sur un arbre propre, ou utiliser --sortie DOSSIER hors du depot")
    quit(status = 1L)
  }
  if (!dir.exists(file.path(RACINE, "docs", "tableaux")))
    stop("dossier de sortie introuvable : ", file.path(RACINE, "docs", "tableaux"))
  garde_ecrasement(CIBLES_ECRIRE, OPT_REMPLACER, RACINE)
}
if (!is.na(OPT_BRUT)) {
  if (!dir.exists(dirname(OPT_BRUT))) stop("--brut : dossier introuvable : ", dirname(OPT_BRUT))
  if (sous_depot(dirname(OPT_BRUT))) stop("--brut : chemin sous le depot refuse (copie hors du depot, branche de sauvegarde) : ", OPT_BRUT)
  if (file.exists(OPT_BRUT)) stop("--brut : fichier existant, jamais ecrase : ", OPT_BRUT)
}
if (!is.na(OPT_SORTIE)) {
  if (sous_depot(OPT_SORTIE)) stop("--sortie : dossier sous le depot refuse (--ecrire est le seul chemin qui ecrit dans le depot) : ", OPT_SORTIE)
  ex <- file.path(OPT_SORTIE, NOMS_SORTIE[[OPT_PARTIE]])
  if (any(file.exists(ex))) stop("--sortie : fichier(s) deja present(s), jamais ecrase(s) : ", paste(ex[file.exists(ex)], collapse = ", "))
}
if (!is.na(OPT_SORTIE_TR)) {
  if (!dir.exists(dirname(OPT_SORTIE_TR))) stop("--sortie-tranche : dossier introuvable : ", dirname(OPT_SORTIE_TR))
  if (sous_depot(dirname(OPT_SORTIE_TR))) stop("--sortie-tranche : chemin sous le depot refuse : ", OPT_SORTIE_TR)
  if (file.exists(OPT_SORTIE_TR)) stop("--sortie-tranche : fichier existant, jamais ecrase : ", OPT_SORTIE_TR)
}
# Tranche : refus d'un commit non propre ou d'un code hors du depot, avant
# tout calcul (sauf --essai, non combinable par --ecrire).
if ((!is.na(OPT_JEU) || !is.na(OPT_SCEN)) && !OPT_ESSAI && !OPT_PREVOL) {
  nvt <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, c(SCRIPT_72, SPEC)), "de la tranche")
  if (length(nvt)) {
    message("tranche refusee : ", paste(nvt, collapse = " ; "),
            " -- lancer dans un git worktree au commit propre cite, ou --essai (essai non combinable par --ecrire)")
    quit(status = 1L)
  }
}

# --- Protocole (constantes de la specification) -------------------------------
METHODE <- "premium"; SEGMENT <- 1; ANNEXE <- "II"; NATURE <- "brutes"
ALPHA <- 0.10; THETA_EQUIV <- 0.10
SEUILS <- c(0.10, 0.05); IA <- c("a10", "a05")
B_BOOT <- 999L; B_CIBLE <- 999L; B_MAX <- 25000L
GRAINE_JEUX <- 20260927           # jeux de J1, J2, J3 (par. 3.1, 3.2)
GRAINE_BOOT <- 20260831           # bootstrap de la replication b : + b
GRAINE_V3B <- 20800000            # flux de V3b de la replication b : + b (par. 3.3)
GRAINE_P <- 20810000              # scenarios de P : + s (par. 3.3)
GRAINE_GRILLE <- 20820000         # couche de reference de la grille (collisions seulement)
T_ <- 8L
X3 <- c(10, 10.5, 95, 92, 11, 11.5, 98, 90)
DELTA3 <- 0.60; BETA3 <- 0.70; SIGMA3 <- 0.10; GAMMA3 <- log(SIGMA3 / BETA3)
# Familles (par. 1) ; F_R = catalogue moins F_T.
F_T <- c("AD", "CvM", "KS", "SW", "Lillie", "Intercept", "CUSUM", "LB1", "Runs", "Runsr", "Smirnov", "CoxStuart")
F_8 <- c("BP", "BP79", "GQ", "BF", "Grubbs", "Grubbsr", "DAgo", "JB")
# Intensites des scenarios de P (par. 6), ajustables par la decision A2 :
# H, exposant k de Var(Y) proportionnelle a x^k ; C, lambda de la
# contamination ; A, degres de liberte nu du chi2 centre reduit.
# Decision A2 (annotation du 10/10/2026 de la specification) : A8 (nu = 8)
# remplace par A4 (nu = 4), meme rang s = 5, meme graine 20810005.
INTENSITES <- c(H0 = 0, H3 = 3, C3 = 3, C4 = 4, A4 = 4, A2 = 2)
# md5 (methode L8) des jeux d'un scenario fixe par la decision A2, cites par
# l'annotation du 10/10/2026 : (l8) les exige en plus de ceux du tableau de
# la grille (absents du tableau du 09/10, qui porte A8).
MD5_L8_A2 <- list(A4 = c(E = "24b220ddef224d38e19eb4bb2a947b18", ts = NA_character_, Y = "04c46e144ac2e23ea5959a28ad0d761d"))
SCENARIOS <- data.frame(code = CODES_SCEN, s = 1:6, famille = c("H", "H", "C", "C", "A", "A"),
                        par = unname(INTENSITES[CODES_SCEN]), stringsAsFactors = FALSE)
LIB_SCEN <- stats::setNames(sprintf("%s, %s = %s", SCENARIOS$famille,
                                    c(H = "k", C = "\u03bb", A = "\u03bd")[SCENARIOS$famille], format(SCENARIOS$par)),
                            SCENARIOS$code)
CIBLES <- list(H = c("BP", "BP79", "White", "GQ", "BF"), C = c("Grubbs", "Grubbsr", "DAgo", "JB", "SF"),
               A = c("DAgo", "JB", "SF", "Grubbs", "Grubbsr"))
STATS_P2 <- c("BP", "BP79", "White", "BF", "RESET", "Intercept")
TOL_H2 <- 1e-9; REL_QR <- 1e-12
NIVEAU_HOLM <- 0.05; N_EVALUABLE <- 100L; SEUIL_C3 <- 0.01
REG <- c("bord0", "interieur", "bord1")
LIB_REG <- c(bord0 = "\u03b4\u0302* = 0", interieur = "\u03b4\u0302* int\u00e9rieur", bord1 = "\u03b4\u0302* = 1")
VARIANTES <- c("V1", "V3a", "V3b", "V3h"); VARIANTES_CRIT <- c("V3b", "V3a", "V3h")
JEUX <- c("J1", "J2", "J3")
NOMS_E2 <- c("engine_sous_graine", "OPT_GRAINE", "t", "vapply", "seq_len", "OPT_R", "function",
             "usp_simuler", "FIT0", "numeric", "T_", "{", "(")
# Lois discretes (copie declaree de tests/grille_regime_t8.R).
LOI_STAT <- c(Runs = "suites", Runsr = "suites", MK = "mk", Smirnov = "smirnov",
              SpearVol = "spearman", SpearTps = "spearman", CoxStuart = "coxstuart")
LIB_LOI <- c(suites = "suites (Swed-Eisenhart, 4 et 4)", mk = "Mann-Kendall (loi mahonienne)",
             smirnov = "Smirnov (4 et 4)", spearman = "Spearman (loi de permutation)",
             coxstuart = "Cox-Stuart (Binomiale(4, 1/2))")
DISCRETES <- names(LOI_STAT)
# Statistique du catalogue -> ligne de usp_tests() qui lit sa p_mc (copie
# declaree de tests/calibration_mc_t8.R) : explication des discordances (t2).
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
# Lignes de run_engine() hors du perimetre de T2 (#45) : rapport de
# vraisemblance sur delta et largeur de l'IC a delta fixe.
hors_t2 <- function(lignes) startsWith(lignes, "Rapport de vraisemblance") |
  lignes == "Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime)"
STATS <- names(USP_CATALOGUE_MC)
NS <- length(STATS)
F_R <- setdiff(STATS, F_T)
QUEUE <- vapply(STATS, function(s) USP_CATALOGUE_MC[[s]]$queue, "")
# Codes des motifs d'absence d'une p (engine_p_mc(), .mc_p_values()).
CODES_MOTIF <- c(o = MOTIF_MC_OBS_NON_FINIE, z = MOTIF_MC_AUCUNE_REPLIC, i = MOTIF_MC_REPLIC_INSUFFISANTES,
                 d = MOTIF_MC_DISPERSION_NULLE, c = MOTIF_MC_CONDITION, a = MOTIF_MC_ATOME_HORS_OBS,
                 x = "statistique observee non definie : ex aequo")
LIB_MOTIF <- c(o = "obs. non finie", z = "B eff. = 0", i = "B eff. < B_MIN_DEGENERESCENCE", d = "dispersion nulle",
               c = "condition du catalogue", a = "atome hors obs.", x = "non d\u00e9finie (ex aequo)", "?" = "motif inconnu")
code_motif <- function(m) ifelse(is.na(m), "-", ifelse(m %in% CODES_MOTIF, names(CODES_MOTIF)[match(m, CODES_MOTIF)], "?"))
code_verdict <- function(v) if (is.null(v) || is.na(v)) "-" else switch(v, OK = "O", ALERTE = "A", ECHEC = "E", INFO = "I", "X")
code_nature <- function(n) if (is.null(n) || is.na(n)) "-" else if (n == "exacte") "x" else
  if (startsWith(n, "Monte-Carlo")) "m" else if (startsWith(n, "asymptotique")) "a" else "f"

# --- Texte du critere (specification, par. 2.1-2.2 ; copie declaree de
# tests/grille_regime_t8.R, reporte sans modification, controle (t)) ---------
TEXTE_CRITERE_229 <- c(
  "### 2.1 Grandeurs",
  "",
  "- **D\u00e9cision.** Pour un jeu j, un seuil \u03b1 \u2208 {0,10 ; 0,05}, une statistique s et une variante v : D_v(b) = 1 si p_v(b) < \u03b1. **Une p absente compte comme un non-rejet** dans T1, T1 bis et P.",
  "- **Population du crit\u00e8re.**",
  "  - J2 et J3 : les R r\u00e9plications.",
  "  - **J1 : les seules r\u00e9plications dont \u03b4\u0302* est au bord** (bord 0 \u222a bord 1 ; 1 925 sur 2 000 dans #221 **[V]**).",
  "  - Les 75 r\u00e9plications int\u00e9rieures de J1 sont calcul\u00e9es pour les trois variantes et rapport\u00e9es \u00e0 titre **descriptif**, hors crit\u00e8re. C'est la lecture propos\u00e9e de \u00ab J1 aux bords seulement \u00bb : Q-A1-2.",
  "- **Taux marginal** \u03c4_v = k / n, avec l'IC de Clopper-Pearson \u00e0 95 % et les classes de #166 : compatible ; \u00e9cart mineur ; \u00e9cart non tranch\u00e9 ; distorsion mat\u00e9rielle (IC disjoint de la bande de Bradley [\u03b1/2 ; 3\u03b1/2]), avec son c\u00f4t\u00e9.",
  "  - Lois discr\u00e8tes (\u2020) : r\u00e9f\u00e9rence liss\u00e9e de #166 \u00e0 B = 999 pour V1 et V3b.",
  "  - Pour V3a, les r\u00e9f\u00e9rences discr\u00e8tes sont **descriptives**, son B effectif \u00e9tant variable.",
  "- **Taux par r\u00e9gime** \u03c4_v^r : m\u00eame d\u00e9finition sur les r\u00e9plications dont r(\u03b4\u0302*) = r. Une cellule est \u00e9valuable si n^r \u2265 100 ; sinon elle est \u00ab non \u00e9valuable \u00bb.",
  "- **Comparaison appari\u00e9e** de v \u00e0 V1 sur les m\u00eames r\u00e9plications :",
  "  - n01 : v rejette, V1 non ; n10 : V1 rejette, v non ;",
  "  - **test de McNemar exact** : test binomial bilat\u00e9ral de param\u00e8tre 1/2 sur les n01 + n10 paires discordantes, comme pour #221 (`.tex`, \u00a7 `sec:calibration-mc`) **[V]** ;",
  "  - **multiplicit\u00e9** : correction de Holm (1979) au niveau 0,05, \u00e0 l'int\u00e9rieur de chaque famille de tests d\u00e9sign\u00e9e ci-dessous (Q-A1-5).",
  "",
  "### 2.2 Conditions",
  "",
  "Chaque condition est \u00e9valu\u00e9e m\u00e9caniquement pour **V3b, V3a et V3h si retenue**, et pour V1 quand elle a un sens absolu.",
  "",
  "**C1, calibration marginale (en appari\u00e9).** Sur J1 (bords), J2 et J3, aux deux seuils :",
  "- **(C1a), absolu, sur les 34 statistiques** : la variante n'a pas de distorsion mat\u00e9rielle marginale, sauf si V1 en a une du m\u00eame c\u00f4t\u00e9, et alors sans l'aggraver (r\u00e8gle (b) de #175 : pas de disjonction du c\u00f4t\u00e9 oppos\u00e9, pas de taux au-del\u00e0 de l'IC de V1 du c\u00f4t\u00e9 de la distorsion).",
  "- **(C1b), aggravation lib\u00e9rale, sur F_R** (Holm par famille (jeu, \u03b1), 22 tests) : on ne doit pas avoir \u00e0 la fois un McNemar significatif apr\u00e8s Holm, n01 > n10, et une borne basse de l'IC de \u03c4_v sup\u00e9rieure \u00e0 \u03b1.",
  "- **(C1c), descriptif** : aggravation conservatrice (McNemar significatif, n10 > n01, borne haute de l'IC de \u03c4_v inf\u00e9rieure \u00e0 \u03b1). Elle n'est pas \u00e9liminatoire, son co\u00fbt relevant de C4 ; c'est l'asym\u00e9trie de la condition 1 d'origine.",
  "",
  "**C2, calibration conditionnelle** (cellules \u00e9valuables) :",
  "- **(C2a), correction, au sens de #175, \u00e0 \u03b1 = 0,10.**",
  "  - Au r\u00e9gime int\u00e9rieur de J2 : au moins 5 des 8 statistiques de F_8 ont un IC de V1 disjoint de la bande et un IC de la variante non disjoint.",
  "  - Au r\u00e9gime int\u00e9rieur de J3 : m\u00eame r\u00e8gle, avec un seuil de min(5, m\u2083), o\u00f9 m\u2083 est le nombre de statistiques de F_8 dont l'IC de V1 y est disjoint.",
  "- **(C2b), aucune distorsion cr\u00e9\u00e9e, invers\u00e9e ni aggrav\u00e9e**, sur toutes les cellules (J1 bord 0 et bord 1 ; J2 et J3, trois r\u00e9gimes) \u00d7 F_R \u00d7 deux seuils. R\u00e8gles (a) et (b) de #175 : si l'IC de V1 n'est pas disjoint, celui de la variante ne l'est pas non plus ; s'il l'est, la variante n'est pas disjointe du c\u00f4t\u00e9 oppos\u00e9 et son taux ne d\u00e9passe pas l'IC de V1 du c\u00f4t\u00e9 de la distorsion.",
  "- Le McNemar par r\u00e9gime est rapport\u00e9 (Holm par famille (jeu, r\u00e9gime, \u03b1)), sans entrer dans C2.",
  "",
  "**C3, p absentes.** Par jeu (J1 sur ses bords), la part des r\u00e9plications o\u00f9 la p de la variante manque pour au moins une statistique de F_R, **alors que celle de V1 existe**, est au plus 1 %. Les motifs communs \u00e0 V1 (statistique d\u00e9g\u00e9n\u00e9r\u00e9e, observ\u00e9e non finie) sont exclus.",
  "",
  "**C4, puissance (partie P, \u00a7 6).**",
  "- **(C4a), non-inf\u00e9riorit\u00e9.** Pour chaque sc\u00e9nario et chaque seuil, aucune statistique de F_R n'a de McNemar significatif apr\u00e8s Holm (famille (sc\u00e9nario, \u03b1), 22 tests) avec n10 > n01. On compte toutes les r\u00e9plications du sc\u00e9nario.",
  "- **(C4b), gain.** Pour au moins une famille d'alternatives, au moins une statistique de son ensemble cible (\u00a7 6) a, **sur les r\u00e9plications \u00e0 \u03b4\u0302* int\u00e9rieur**, un McNemar significatif apr\u00e8s Holm (famille (sc\u00e9nario, \u03b1 = 0,10, ensemble cible)) avec n01 > n10.",
  "- **(C4c), descriptif** : puissance par r\u00e9gime, bords compris, et taux bruts rapport\u00e9s avec le niveau mesur\u00e9 de chaque variante (T1 du m\u00eame jeu).",
  "",
  "**C5, t\u00e9moins (validit\u00e9 de la mesure, et non condition sur une variante).** Pour chaque jeu et chaque seuil, McNemar V3b contre V1 sur les 12 statistiques de F_T, avec Holm sur la famille. Un t\u00e9moin significatif est un **point d'examen avant la lecture d'A3** : soit d\u00e9faut de la mesure, soit l'ind\u00e9pendance au r\u00e9gime ne tient pas pour ce t\u00e9moin.")
TITRES_ANNOTATIONS <- c("## Annotation du 9 octobre 2026 : d\u00e9cisions du mainteneur au point d'arr\u00eat A1",
                        "## Annotation du 9 octobre 2026 : lecture des points ouverts de la grille",
                        "## Annotation du 10 octobre 2026 : d\u00e9cision au point d'arr\u00eat A2 (sous d\u00e9l\u00e9gation)",
                        "## Annotation du 10 octobre 2026 : points ouverts du script de mesure")
PROFILS_D <- c(D1 = "C1, C2, C3, C4 remplies : la variante domine V1 quelle que soit la cible",
               D2 = "C2, C3, C4 remplies ; C1 en d\u00e9faut : arbitrage de cible",
               D3 = "C1, C2, C3 remplies ; C4 en d\u00e9faut : arbitrage entre calibration conditionnelle et puissance",
               D4 = "C2 en d\u00e9faut : la variante n'atteint pas la cible qui la motive",
               D5 = "C3 en d\u00e9faut : variante non impl\u00e9mentable telle quelle")

###############################################################################
#  LIGNES MACHINE : COLONNES ET LECTURE
###############################################################################
COLS_FIXES <- c("b", "statut", "regime", "delta", "gamma", "dd_bord0", "dd_interieur", "dd_bord1", "ech_rapide",
                "ech_stats", "a_v1", "tir_v3b", "ret_v3b", "ech_rapide_v3b", "hors_v3b", "ech_stats_v3b", "arret",
                "i1", "t2", "v3a", "verd_V1", "verd_V3a", "verd_V3b", "nat_V1", "nat_V3a", "nat_V3b",
                paste0("h2:", STATS_P2), "duree", "discordances")
CHAMPS_STAT <- c("p_V1", "p_V3a", "p_V3b", "B_V1", "B_V3a", "B_V3b", "m_V1", "m_V3a", "m_V3b")
REPCOLS <- c(COLS_FIXES, as.vector(t(outer(STATS, CHAMPS_STAT, function(s, c) paste0(c, ":", s)))))
COLS_NUM <- c("b", "delta", "gamma", "dd_bord0", "dd_interieur", "dd_bord1", "ech_rapide", "ech_stats", "a_v1",
              "tir_v3b", "ret_v3b", "ech_rapide_v3b", "hors_v3b", "ech_stats_v3b", paste0("h2:", STATS_P2), "duree",
              as.vector(outer(c("p_V1", "p_V3a", "p_V3b", "B_V1", "B_V3a", "B_V3b"), STATS, paste, sep = ":")))
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
# Matrices (replications x statistiques) des p, des B effectifs et des
# motifs de chaque variante ; V3h : V3b a delta* interieur, V1 aux bords.
matrices <- function(D) {
  mat <- function(ch) { M <- as.matrix(D[, paste0(ch, ":", STATS), drop = FALSE]); dimnames(M) <- list(NULL, STATS); M }
  int <- matrix(D$statut == "traitee" & D$regime == "interieur", nrow(D), NS)
  P <- list(V1 = mat("p_V1"), V3a = mat("p_V3a"), V3b = mat("p_V3b"))
  B <- list(V1 = mat("B_V1"), V3a = mat("B_V3a"), V3b = mat("B_V3b"))
  M <- list(V1 = mat("m_V1"), V3a = mat("m_V3a"), V3b = mat("m_V3b"))
  P$V3h <- ifelse(int, P$V3b, P$V1); B$V3h <- ifelse(int, B$V3b, B$V1); M$V3h <- ifelse(int, M$V3b, M$V1)
  for (v in VARIANTES) dimnames(P[[v]]) <- dimnames(B[[v]]) <- dimnames(M[[v]]) <- list(NULL, STATS)
  verd <- list(V1 = D$verd_V1, V3a = D$verd_V3a, V3b = D$verd_V3b,
               V3h = ifelse(D$regime == "interieur", D$verd_V3b, D$verd_V1))
  nat <- list(V1 = D$nat_V1, V3a = D$nat_V3a, V3b = D$nat_V3b,
              V3h = ifelse(D$regime == "interieur", D$nat_V3b, D$nat_V1))
  list(P = P, B = B, M = M, verd = verd, nat = nat, regime = D$regime, statut = D$statut, n = nrow(D))
}

###############################################################################
#  LECTURE D'UN TAUX, CELLULES, McNEMAR (tranche et --combiner)
###############################################################################
# Lecture d'un taux contre une reference (regle de #166) : reference dans
# l'IC (compatible) ; sinon IC disjoint de la bande [ref/2 ; 3 ref/2]
# (distorsion materielle, avec son cote) ; sinon taux dans la bande (ecart
# mineur) ; sinon ecart non tranche. Bande non applicable si ref < 2/n (L6) :
# lecture binaire, compatible ou ecart a examiner, jamais de distorsion.
CLASSES <- c("compatible", "\u00e9cart mineur", "\u00e9cart non tranch\u00e9", "distorsion mat\u00e9rielle")
lecture <- function(k, n, ref) {
  if (n == 0) return(list(k = k, n = 0, taux = NA_real_, ci = c(NA_real_, NA_real_), evaluable = FALSE, bna = NA,
                          disj = FALSE, cote = NA_character_, classe = "non \u00e9valuable"))
  ci <- ic_cp(k, n); t <- k / n
  ref_ic <- ref >= ci[1] && ref <= ci[2]
  bna <- ref < 2 / n
  cote <- if (bna) NA_character_ else if (ci[2] < ref / 2) "conservateur" else if (ci[1] > 3 * ref / 2) "lib\u00e9ral" else NA_character_
  classe <- if (ref_ic) CLASSES[1] else if (bna) "\u00e9cart \u00e0 examiner (bande non applicable)" else
    if (!is.na(cote)) CLASSES[4] else if (t >= ref / 2 && t <= 3 * ref / 2) CLASSES[2] else CLASSES[3]
  list(k = k, n = n, taux = t, ci = ci, evaluable = TRUE, bna = bna, disj = !is.na(cote), cote = cote, classe = classe)
}
txt_lec <- function(c_) if (!c_$evaluable) "\u2014" else
  sprintf("%s %s%s", num(c_$taux, 4), txt_ic(c_$ci), if (c_$disj) sprintf(" **%s**", c_$cote) else "")
# Defaut des regles (a) et (b) de #175 d'une cellule de la variante x contre
# V1 (m) : "" si aucun, sinon le motif (creee, inversee, aggravee).
defaut_ab <- function(m, x) {
  if (!m$disj) return(if (x$disj) sprintf("cr\u00e9\u00e9e (%s)", x$cote) else "")
  if (x$disj && x$cote != m$cote) return(sprintf("invers\u00e9e (%s \u2192 %s)", m$cote, x$cote))
  if (m$cote == "conservateur" && x$taux < m$ci[1]) return("aggrav\u00e9e (taux sous la borne basse de l'IC de V1)")
  if (m$cote == "lib\u00e9ral" && x$taux > m$ci[2]) return("aggrav\u00e9e (taux au-dessus de la borne haute de l'IC de V1)")
  ""
}
# McNemar exact (test binomial bilateral de parametre 1/2 sur les paires
# discordantes) ; p = 1 sans paire discordante.
mcnemar <- function(dv, d1) {
  n01 <- sum(dv & !d1); n10 <- sum(!dv & d1); n <- n01 + n10
  c(n01 = n01, n10 = n10, p = if (n) stats::binom.test(n01, n, 0.5)$p.value else 1)
}
# Famille de McNemar (variante v contre V1) sur des statistiques, Holm.
famille_mcn <- function(MX, v, a, rows, st) {
  r <- t(vapply(st, function(s) {
    dv <- MX$P[[v]][rows, s]; d1 <- MX$P$V1[rows, s]
    mcnemar(is.finite(dv) & dv < a, is.finite(d1) & d1 < a)
  }, numeric(3)))
  data.frame(stat = st, n01 = r[, "n01"], n10 = r[, "n10"], p = r[, "p"],
             p_holm = stats::p.adjust(r[, "p"], "holm"), stringsAsFactors = FALSE)
}
# Reference d'une statistique au seuil a (REF : statistique x seuil).
cellule <- function(MX, rows, s, v, ia, REF) {
  a <- SEUILS[match(ia, IA)]
  p <- MX$P[[v]][rows, s]
  lecture(sum(is.finite(p) & p < a), sum(rows), REF[s, ia])
}
# Population du critere (par. 2.1) : J1, replications au bord ; J2, J3 et
# scenarios, replications traitees ; quoi : un regime, ou "toutes". Une
# replication en erreur (statut "erreur", regime eventuellement connu) n'en
# fait jamais partie.
lignes_pop <- function(j, MX, quoi = "critere") {
  tr <- MX$statut == "traitee" & MX$regime %in% REG
  if (quoi == "critere") { if (j == "J1") tr & MX$regime != "interieur" else tr }
  else if (quoi == "toutes") tr else tr & MX$regime == quoi
}
# Vectorisee : appelee sur une colonne (McNemar significatifs, C5) comme sur
# un jeu seul.
lib_pop <- function(j) vapply(j, function(x) if (x == "J1") "J1 (bords)" else
  if (x %in% names(LIB_SCEN)) sprintf("%s (%s)", x, LIB_SCEN[[x]]) else x, "", USE.NAMES = FALSE)
lib_ia <- function(ia) c(a10 = "0,10", a05 = "0,05")[[ia]]
# p-value (McNemar apres Holm) a trois chiffres significatifs, sans remplissage.
fmt_p <- function(p) sub(".", ",", sprintf("%.3g", p), fixed = TRUE)
liste_cel <- function(x, n = 10) if (!length(x)) "aucune" else
  paste(c(utils::head(x, n), if (length(x) > n) sprintf("... (%d en tout)", length(x))), collapse = " ; ")

###############################################################################
#  TABLEAUX DE LA PARTIE REGIME (T1, T1 bis, criteres, T2, T3)
###############################################################################
tableau_t1 <- function(DM, REF) {
  L <- c("### T1 -- taux marginaux de rejet par jeu, statistique et variante (population du crit\u00e8re ; p absente = non-rejet)", "",
         paste("Par seuil : k, taux k / n et IC de Clopper-Pearson \u00e0 95 % (c\u00f4t\u00e9 en gras si l'IC est disjoint de la bande",
               "[r\u00e9f/2 ; 3 r\u00e9f/2]), classe de #166, McNemar contre V1 (n01 / n10, p apr\u00e8s Holm : famille (jeu, \u03b1, variante) sur",
               "F_R pour une statistique de F_R, sur F_T pour un t\u00e9moin). \u2020 : loi discr\u00e8te, r\u00e9f\u00e9rence liss\u00e9e de #166 \u00e0",
               "B = 999 (descriptive pour V3a, L13)."), "",
         entete_md(c("Jeu", "Statistique (sens)", "famille", "Variante", "n", "r\u00e9f. 0,10", "k", "taux [IC] 0,10", "classe 0,10",
                     "McNemar 0,10", "r\u00e9f. 0,05", "k", "taux [IC] 0,05", "classe 0,05", "McNemar 0,05")))
  for (j in intersect(JEUX, names(DM))) {
    MX <- DM[[j]]; rows <- lignes_pop(j, MX)
    mc <- lapply(stats::setNames(nm = IA), function(ia) lapply(stats::setNames(nm = VARIANTES[-1]), function(v) {
      a <- SEUILS[match(ia, IA)]
      rbind(famille_mcn(MX, v, a, rows, F_R), famille_mcn(MX, v, a, rows, F_T))
    }))
    for (s in STATS) for (v in VARIANTES) {
      cols <- unlist(lapply(IA, function(ia) {
        c_ <- cellule(MX, rows, s, v, ia, REF)
        m <- if (v == "V1") "\u2014" else { x <- mc[[ia]][[v]]; x <- x[x$stat == s, ]
          sprintf("%d / %d, %s", x$n01, x$n10, fmt_p(x$p_holm)) }
        c(num(REF[s, ia], 4), c_$k, txt_lec(c_), c_$classe, m)
      }))
      L <- c(L, ligne_md(lib_pop(j), sprintf("%s (%s)%s", s, QUEUE[[s]], if (s %in% DISCRETES) " \u2020" else ""),
                         paste(c(if (s %in% F_T) "F_T" else "F_R", if (s %in% F_8) "F_8"), collapse = ", "), v, sum(rows),
                         paste(cols, collapse = " | ")))
    }
  }
  c(L, "")
}
tableau_t1bis <- function(DM, REF) {
  L <- c("### T1 bis -- taux par r\u00e9gime de \u03b4\u0302* (\u00e9valuable si n \u2265 100 ; McNemar : Holm par famille (jeu, r\u00e9gime, \u03b1, variante), F_R et F_T s\u00e9par\u00e9es)", "",
         entete_md(c("Jeu", "R\u00e9gime", "Statistique", "Variante", "n", "\u00e9valuable", "taux [IC] 0,10", "classe 0,10", "McNemar 0,10",
                     "taux [IC] 0,05", "classe 0,05", "McNemar 0,05")))
  for (j in intersect(JEUX, names(DM))) for (r in REG) {
    MX <- DM[[j]]; rows <- lignes_pop(j, MX, r)
    if (!any(rows)) next
    mc <- lapply(stats::setNames(nm = IA), function(ia) lapply(stats::setNames(nm = VARIANTES[-1]), function(v) {
      a <- SEUILS[match(ia, IA)]
      rbind(famille_mcn(MX, v, a, rows, F_R), famille_mcn(MX, v, a, rows, F_T))
    }))
    for (s in STATS) for (v in VARIANTES) {
      cols <- unlist(lapply(IA, function(ia) {
        c_ <- cellule(MX, rows, s, v, ia, REF)
        m <- if (v == "V1") "\u2014" else { x <- mc[[ia]][[v]]; x <- x[x$stat == s, ]
          sprintf("%d / %d, %s", x$n01, x$n10, fmt_p(x$p_holm)) }
        c(txt_lec(c_), c_$classe, m)
      }))
      L <- c(L, ligne_md(j, LIB_REG[[r]], s, v, sum(rows), if (sum(rows) >= N_EVALUABLE) "oui" else "non", paste(cols, collapse = " | ")))
    }
  }
  c(L, "")
}

# Evaluation mecanique des conditions C1, C2, C3, C5 (partie regime) ; C4
# (partie puissance). Etat : "remplie", "en defaut", "non evaluable".
ETAT <- c(ok = "remplie", ko = "en d\u00e9faut", ne = "non \u00e9valuable")
# Champ vide : TRUE pour la seule ligne C2a de J3 dont la condition est vide
# (m3 = 0), lu par profils().
conditions_regime <- function(DM, REF) {
  C <- list()
  ajout <- function(cond, v, etat, detail, vide = FALSE) C[[length(C) + 1L]] <<- data.frame(cond = cond, variante = v, etat = etat,
                                                                                           detail = detail, vide = vide, stringsAsFactors = FALSE)
  jeux <- intersect(JEUX, names(DM))
  manque <- setdiff(JEUX, jeux)
  txt_manque <- if (length(manque)) sprintf(" ; jeux absents de cette sortie : %s", paste(manque, collapse = ", ")) else ""
  # C1a (V1 : sens absolu, distorsions listees)
  # n_ev : cellules effectivement evaluees ; aucune -> non evaluable.
  for (v in c("V1", VARIANTES_CRIT)) {
    def <- bna <- desc <- character(0); n_ev <- 0L
    for (j in jeux) for (ia in IA) {
      MX <- DM[[j]]; rows <- lignes_pop(j, MX)
      for (s in STATS) {
        m <- cellule(MX, rows, s, "V1", ia, REF)
        if (!m$evaluable) next
        if (isTRUE(m$bna)) { bna <- c(bna, sprintf("%s %s %s", lib_pop(j), s, lib_ia(ia))); next }
        if (v == "V1") { n_ev <- n_ev + 1L; if (m$disj) def <- c(def, sprintf("%s %s %s (%s)", lib_pop(j), s, lib_ia(ia), m$cote)); next }
        if (v == "V3a" && s %in% DISCRETES) { desc <- c(desc, s); next }
        n_ev <- n_ev + 1L
        d <- defaut_ab(m, cellule(MX, rows, s, v, ia, REF))
        if (nzchar(d)) def <- c(def, sprintf("%s %s %s : %s", lib_pop(j), s, lib_ia(ia), d))
      }
    }
    etat <- if (!n_ev) ETAT[["ne"]] else if (v == "V1") (if (length(def)) "distorsions de V1 (sens absolu)" else "aucune distorsion de V1") else
      if (length(def)) ETAT[["ko"]] else ETAT[["ok"]]
    ajout("C1a", v, etat, sprintf("%s : %s%s%s%s", if (v == "V1") "distorsions mat\u00e9rielles marginales" else "cellules en d\u00e9faut",
                                   liste_cel(def), if (length(bna)) sprintf(" ; bande non applicable (L6) : %s", liste_cel(unique(bna))) else "",
                                   if (length(desc)) sprintf(" ; descriptives pour V3a (loi discr\u00e8te, L13) : %s", paste(unique(desc), collapse = ", ")) else "",
                                   txt_manque))
  }
  # C1b, C1c
  for (v in VARIANTES_CRIT) {
    def <- cons <- character(0); n_ev <- 0L
    for (j in jeux) for (ia in IA) {
      MX <- DM[[j]]; rows <- lignes_pop(j, MX); a <- SEUILS[match(ia, IA)]
      if (!any(rows)) next
      n_ev <- n_ev + 1L
      mc <- famille_mcn(MX, v, a, rows, F_R)
      for (i in seq_len(nrow(mc))) {
        x <- cellule(MX, rows, mc$stat[i], v, ia, REF)
        sig <- mc$p_holm[i] < NIVEAU_HOLM
        if (sig && mc$n01[i] > mc$n10[i] && isTRUE(x$ci[1] > a))
          def <- c(def, sprintf("%s %s %s (%d/%d, p Holm %s)", lib_pop(j), mc$stat[i], lib_ia(ia), mc$n01[i], mc$n10[i],
                                fmt_p(mc$p_holm[i])))
        if (sig && mc$n10[i] > mc$n01[i] && isTRUE(x$ci[2] < a))
          cons <- c(cons, sprintf("%s %s %s (%d/%d)", lib_pop(j), mc$stat[i], lib_ia(ia), mc$n01[i], mc$n10[i]))
      }
    }
    ajout("C1b", v, if (!n_ev) ETAT[["ne"]] else if (length(def)) ETAT[["ko"]] else ETAT[["ok"]],
          sprintf("aggravation lib\u00e9rale (McNemar Holm < 0,05, n01 > n10, borne basse > \u03b1, L9) : %s%s", liste_cel(def), txt_manque))
    ajout("C1c (descriptif)", v, if (length(cons)) "aggravation conservatrice" else "aucune", liste_cel(cons))
  }
  # C2a
  for (v in VARIANTES_CRIT) for (j in intersect(c("J2", "J3"), jeux)) {
    MX <- DM[[j]]; rows <- lignes_pop(j, MX, "interieur"); n <- sum(rows)
    if (n < N_EVALUABLE) { ajout(sprintf("C2a (%s int\u00e9rieur)", j), v, ETAT[["ne"]], sprintf("n = %d < %d", n, N_EVALUABLE)); next }
    hors1 <- vapply(F_8, function(s) cellule(MX, rows, s, "V1", "a10", REF)$disj, logical(1))
    dans <- vapply(F_8, function(s) !cellule(MX, rows, s, v, "a10", REF)$disj, logical(1))
    nb <- sum(hors1 & dans); m3 <- sum(hors1)
    seuil <- if (j == "J2") 5L else min(5L, m3)
    ajout(sprintf("C2a (%s int\u00e9rieur)", j), v, if (nb >= seuil) ETAT[["ok"]] else ETAT[["ko"]], vide = j == "J3" && m3 == 0L, detail =
          sprintf("n = %d ; IC de V1 disjoint et IC de la variante non disjoint : %d (%s), seuil %d%s", n, nb,
                  if (nb) paste(F_8[hors1 & dans], collapse = ", ") else "aucune", seuil,
                  if (j == "J3") sprintf(" (m3 = %d%s)", m3, if (m3 == 0L) ", condition vide" else "") else ""))
  }
  for (v in VARIANTES_CRIT) for (j in setdiff(c("J2", "J3"), jeux)) ajout(sprintf("C2a (%s int\u00e9rieur)", j), v, ETAT[["ne"]], "jeu absent de cette sortie")
  # C2b
  CEL <- list(J1 = c("bord0", "bord1"), J2 = REG, J3 = REG)
  for (v in VARIANTES_CRIT) {
    def <- ne <- bna <- desc <- character(0); n_ev <- 0L
    for (j in jeux) for (r in CEL[[j]]) {
      MX <- DM[[j]]; rows <- lignes_pop(j, MX, r)
      if (sum(rows) < N_EVALUABLE) { ne <- c(ne, sprintf("%s %s (n = %d)", j, LIB_REG[[r]], sum(rows))); next }
      for (ia in IA) for (s in F_R) {
        m <- cellule(MX, rows, s, "V1", ia, REF)
        if (isTRUE(m$bna)) { bna <- c(bna, sprintf("%s %s %s %s", j, LIB_REG[[r]], s, lib_ia(ia))); next }
        if (v == "V3a" && s %in% DISCRETES) { desc <- c(desc, s); next }
        n_ev <- n_ev + 1L
        d <- defaut_ab(m, cellule(MX, rows, s, v, ia, REF))
        if (nzchar(d)) def <- c(def, sprintf("%s %s %s %s : %s", j, LIB_REG[[r]], s, lib_ia(ia), d))
      }
    }
    ajout("C2b", v, if (!n_ev) ETAT[["ne"]] else if (length(def)) ETAT[["ko"]] else ETAT[["ok"]],
          sprintf("cellules en d\u00e9faut : %s ; cellules non \u00e9valuables (n < 100) : %s%s%s%s", liste_cel(def), liste_cel(ne),
                  if (length(bna)) sprintf(" ; bande non applicable (L6) : %s", liste_cel(bna)) else "",
                  if (length(desc)) sprintf(" ; descriptives pour V3a (L13) : %s", paste(unique(desc), collapse = ", ")) else "", txt_manque))
  }
  # C3
  # Detail (L19) : cellules replication x statistique comptees dans ab,
  # ventilees par motif d'absence de la variante (MOTIFS_C3 : B effectif
  # inferieur a B_MIN_DEGENERESCENCE ou nul, dispersion nulle, atome hors de
  # l'observee ; o, c, x y sont refuses par le controle (b),
  # verifier_ligne()).
  MOTIFS_C3 <- c("i", "z", "d", "a")
  for (v in VARIANTES_CRIT) {
    parts <- character(0); ko <- FALSE; n_ev <- 0L
    for (j in jeux) {
      MX <- DM[[j]]; rows <- lignes_pop(j, MX)
      ab <- !is.finite(MX$P[[v]][rows, F_R, drop = FALSE]) & is.finite(MX$P$V1[rows, F_R, drop = FALSE])
      n_ev <- n_ev + sum(rows)
      part <- if (any(rows)) mean(apply(ab, 1, any)) else NA_real_
      ko <- ko || isTRUE(part > SEUIL_C3)
      mo <- MX$M[[v]][rows, F_R, drop = FALSE][ab]
      txt_mo <- paste(sprintf("%s %d", LIB_MOTIF[MOTIFS_C3], vapply(MOTIFS_C3, function(k) sum(mo == k), 1L)), collapse = ", ")
      autres <- setdiff(unique(mo), MOTIFS_C3)
      if (length(autres)) txt_mo <- paste0(txt_mo, ", ", paste(sprintf("%s %d", ifelse(autres %in% names(LIB_MOTIF), LIB_MOTIF[autres], autres),
                                                                        vapply(autres, function(k) sum(mo == k), 1L)), collapse = ", "))
      parts <- c(parts, sprintf("%s %s (%d r\u00e9pl. ; motifs : %s)", lib_pop(j), num(part, 4), sum(apply(ab, 1, any)), txt_mo))
    }
    ajout("C3", v, if (!n_ev) ETAT[["ne"]] else if (ko) ETAT[["ko"]] else ETAT[["ok"]],
          sprintf("part des r\u00e9plications o\u00f9 la p manque pour au moins une statistique de F_R alors que celle de V1 existe (seuil 1 %%) : %s%s",
                  paste(parts, collapse = " ; "), txt_manque))
  }
  # C5, lu selon L15 (annotation du 10/10/2026) : un temoin significatif est
  # explique si sa difference V3b - V1 mesuree a le signe predit par la
  # grille et reste a moins de e* de la prediction ; sinon il suspend la
  # lecture (par. 2.3).
  L5 <- temoins_l15(DM, jeux)
  sig <- L5[L5$significatif, , drop = FALSE]
  txt5 <- if (nrow(sig)) sprintf("%s %s %s (%d/%d, p Holm %s ; V3b \u2212 V1 mesur\u00e9 %s, pr\u00e9dit %s, \u00e9cart %s, e* %s : %s)",
                                 lib_pop(sig$jeu), sig$stat, vapply(sig$ia, lib_ia, ""), sig$n01, sig$n10, vapply(sig$p_holm, fmt_p, ""),
                                 vapply(sig$d_mes, num, "", d = 4), vapply(sig$d_pred, num, "", d = 4), vapply(sig$ecart, num, "", d = 4),
                                 vapply(sig$estar, num, "", d = 4), ifelse(sig$explique, "expliqu\u00e9 (L15)", "NON expliqu\u00e9")) else character(0)
  ajout("C5 (t\u00e9moins, V3b contre V1)", "V3b",
        if (!nrow(sig)) "aucun t\u00e9moin significatif" else if (all(sig$explique)) "t\u00e9moins significatifs tous expliqu\u00e9s (L15)" else
          "**point d'examen avant A3**",
        sprintf("t\u00e9moins significatifs apr\u00e8s Holm : %s ; pr\u00e9dictions : %s%s", liste_cel(txt5, 40), PRED_C5_TXT, txt_manque))
  do.call(rbind, C)
}
# Temoins de C5 (F_T) par jeu et par seuil : McNemar V3b contre V1 (Holm sur
# F_T), difference mesuree des taux V3b - V1 (population du critere),
# difference predite par la grille (T1 predit, pi a B fini : colonnes V1 et
# V3b), ecart, e* du jeu et du seuil (J3 : celui de J2), signe concordant,
# explication L15.
temoins_l15 <- function(DM, jeux) {
  out <- list()
  for (j in jeux) for (ia in IA) {
    MX <- DM[[j]]; rows <- lignes_pop(j, MX); a <- SEUILS[match(ia, IA)]
    mc <- famille_mcn(MX, "V3b", a, rows, F_T)
    n <- sum(rows)
    tau <- function(v, s) { p <- MX$P[[v]][rows, s]; if (n) sum(is.finite(p) & p < a) / n else NA_real_ }
    for (i in seq_len(nrow(mc))) {
      s <- mc$stat[i]
      d_mes <- tau("V3b", s) - tau("V1", s)
      pr <- if (is.null(PRED_C5)) NULL else PRED_C5$t1[PRED_C5$t1$jeu == j & PRED_C5$t1$stat == s, , drop = FALSE]
      d_pred <- if (!is.null(pr) && nrow(pr) == 1L) pr[[paste0("V3b_", ia)]] - pr[[paste0("V1_", ia)]] else NA_real_
      es <- if (is.null(PRED_C5)) NA_real_ else PRED_C5$estar[if (j == "J1") "J1" else "J2", ia]
      ecart <- d_mes - d_pred
      signe <- isTRUE(sign(d_mes) == sign(d_pred))
      out[[length(out) + 1L]] <- data.frame(jeu = j, ia = ia, stat = s, n01 = mc$n01[i], n10 = mc$n10[i], p_holm = mc$p_holm[i],
                                            significatif = mc$p_holm[i] < NIVEAU_HOLM, d_mes = d_mes, d_pred = d_pred, ecart = ecart,
                                            estar = es, signe = signe, explique = signe && isTRUE(abs(ecart) < es),
                                            stringsAsFactors = FALSE)
    }
  }
  if (length(out)) do.call(rbind, out) else
    data.frame(jeu = character(0), ia = character(0), stat = character(0), n01 = numeric(0), n10 = numeric(0), p_holm = numeric(0),
               significatif = logical(0), d_mes = numeric(0), d_pred = numeric(0), ecart = numeric(0), estar = numeric(0),
               signe = logical(0), explique = logical(0))
}
tableau_l15 <- function(DM) {
  L5 <- temoins_l15(DM, intersect(JEUX, names(DM)))
  L <- c("### C5 -- t\u00e9moins (F_T) : diff\u00e9rence V3b \u2212 V1 mesur\u00e9e et pr\u00e9dite par la grille (L15)", "",
         paste("Population du crit\u00e8re ; McNemar V3b contre V1, Holm sur F_T par (jeu, \u03b1) ; pr\u00e9diction : T1 pr\u00e9dit du tableau de la grille",
               "(\u03c0 \u00e0 B fini, colonnes V3b et V1) ; e* du jeu et du seuil (J3 : celui de J2). Un t\u00e9moin significatif est expliqu\u00e9 si le",
               "signe mesur\u00e9 est le signe pr\u00e9dit et si l'\u00e9cart est inf\u00e9rieur \u00e0 e* ; sinon il suspend la lecture (par. 2.3).",
               sprintf("Pr\u00e9dictions : %s.", PRED_C5_TXT)), "",
         entete_md(c("Jeu", "\u03b1", "T\u00e9moin", "n01 / n10", "p Holm", "significatif", "V3b \u2212 V1 mesur\u00e9", "pr\u00e9dit",
                     "\u00e9cart", "e*", "signe concordant", "lecture L15")))
  for (i in seq_len(nrow(L5))) {
    x <- L5[i, ]
    L <- c(L, ligne_md(lib_pop(x$jeu), lib_ia(x$ia), x$stat, sprintf("%d / %d", x$n01, x$n10), fmt_p(x$p_holm), if (x$significatif) "oui" else "non",
                       num(x$d_mes, 4), num(x$d_pred, 4), num(x$ecart, 4), num(x$estar, 4), if (x$signe) "oui" else "non",
                       if (!x$significatif) "\u2014" else if (x$explique) "expliqu\u00e9" else "**NON expliqu\u00e9 : suspend la lecture**"))
  }
  c(L, "")
}
# Etat d'une condition agregee (C1 = C1a et C1b ; C2 = C2a et C2b ; C4 =
# C4a et C4b) pour une variante.
etat_agrege <- function(COND, prefixes, v) {
  x <- COND[COND$variante == v & vapply(COND$cond, function(c) any(startsWith(c, prefixes)), logical(1)) &
               !grepl("descriptif", COND$cond), "etat"]
  if (!length(x)) return(ETAT[["ne"]])
  if (any(x == ETAT[["ko"]])) ETAT[["ko"]] else if (any(x == ETAT[["ne"]])) ETAT[["ne"]] else ETAT[["ok"]]
}
# Profils D1 a D5 (par. 2.3), mecaniques ; C4 "en attente" en partie regime.
profils <- function(COND, avec_c4) {
  L <- c(entete_md(c("Variante", "C1", "C2", "C3", "C4", "Profil(s) (par. 2.3)")))
  for (v in VARIANTES_CRIT) {
    e <- c(C1 = etat_agrege(COND, c("C1a", "C1b"), v), C2 = etat_agrege(COND, c("C2a", "C2b"), v),
           C3 = etat_agrege(COND, "C3", v), C4 = if (avec_c4) etat_agrege(COND, c("C4a", "C4b"), v) else "en attente (partie P)")
    ok <- function(k) e[[k]] == ETAT[["ok"]]; ko <- function(k) e[[k]] == ETAT[["ko"]]
    p <- character(0)
    if (ko("C3")) p <- c(p, "D5")
    if (ko("C2")) p <- c(p, "D4")
    if (avec_c4 && ok("C1") && ok("C2") && ok("C3") && ok("C4")) p <- c(p, "D1")
    if (avec_c4 && ko("C1") && ok("C2") && ok("C3") && ok("C4")) p <- c(p, "D2")
    if (avec_c4 && ok("C1") && ok("C2") && ok("C3") && ko("C4")) p <- c(p, "D3")
    # partie regime : une condition non evaluable (hors C4, en attente)
    # rend le profil non determine avant toute attente de C4
    txt <- if (length(p)) paste(sprintf("**%s** (%s)", p, PROFILS_D[p]), collapse = " ; ") else
      if (!avec_c4 && any(e[c("C1", "C2", "C3")] == ETAT[["ne"]])) "non d\u00e9termin\u00e9 (condition non \u00e9valuable)" else
      if (!avec_c4 && !any(c(ko("C2"), ko("C3")))) "en attente de C4 (partie P) : D1, D2 ou D3 selon C1 et C4" else
      if (any(e == ETAT[["ne"]])) "non d\u00e9termin\u00e9 (condition non \u00e9valuable)" else
      "hors de la table du par. 2.3 (C1 et C4 en d\u00e9faut, C2 et C3 remplies)"
    # C2a sur J3 vide (m3 = 0) : signale (champ vide de conditions_regime())
    if (isTRUE(any(COND$vide & COND$variante == v & startsWith(COND$cond, "C2a (J3"))))
      txt <- paste0(txt, " ; C2a sur J3 vide (m\u2083 = 0) : correction \u00e9tablie sur J2 seul")
    L <- c(L, ligne_md(v, e[["C1"]], e[["C2"]], e[["C3"]], e[["C4"]], txt))
  }
  c(L, "", "Compl\u00e9ments du par. 2.3 : si V3a a le m\u00eame profil que V3b, elle devient la candidate moins co\u00fbteuse ; un t\u00e9moin de C5 en d\u00e9faut et non expliqu\u00e9 suspend la lecture ; T2 est rapport\u00e9 sans crit\u00e8re.", "")
}
tableau_conditions <- function(COND) c(entete_md(c("Condition", "Variante", "\u00c9tat (m\u00e9canique)", "D\u00e9tail")),
                                       vapply(seq_len(nrow(COND)), function(i) ligne_md(COND$cond[i], COND$variante[i], COND$etat[i], COND$detail[i]), ""), "")

tableau_t2 <- function(DM, LIGNES_T2) {
  L <- c("### T2 -- verdicts des lignes de usp_tests() (sans crit\u00e8re ; population du crit\u00e8re)", "",
         paste("Par ligne et par variante : fr\u00e9quence de ALERTE ou ECHEC, fr\u00e9quence de ECHEC, sur les r\u00e9plications o\u00f9 la ligne est",
               "\u00e9crite ; replis asymptotiques (r\u00e8gle R3 : p retenue de nature asymptotique alors que celle de V1 est Monte-Carlo) compt\u00e9s",
               "\u00e0 part. Lignes du jackknife et de la largeur de l'IC bootstrap 90 % absentes de ce chemin (diagnostics sans p retenue,",
               "verdict ind\u00e9pendant de la variante)."), "",
         entete_md(c("Jeu", "Ligne", "n", paste(VARIANTES, "A ou E / E"), "replis R3 (V3a ; V3b ; V3h)")))
  for (j in intersect(JEUX, names(DM))) {
    MX <- DM[[j]]; rows <- lignes_pop(j, MX)
    V <- lapply(MX$verd, function(x) x[rows]); N <- lapply(MX$nat, function(x) x[rows])
    if (!length(V$V1) || all(V$V1 == "-")) next
    for (i in seq_along(LIGNES_T2)) {
      ch <- lapply(V, function(x) substr(x, i, i)); nt <- lapply(N, function(x) substr(x, i, i))
      n <- sum(ch$V1 != "-")
      if (!n) next
      cols <- vapply(VARIANTES, function(v) sprintf("%s / %s", num(mean(ch[[v]] %in% c("A", "E")), 4), num(mean(ch[[v]] == "E"), 4)), "")
      rep3 <- vapply(c("V3a", "V3b", "V3h"), function(v) sum(nt[[v]] == "a" & nt$V1 == "m"), 1)
      L <- c(L, ligne_md(lib_pop(j), LIGNES_T2[i], n, paste(cols, collapse = " | "), paste(rep3, collapse = " ; ")))
    }
  }
  L <- c(L, "", "Agr\u00e9gats par r\u00e9plication (au moins une ligne en ALERTE ou ECHEC ; au moins une en ECHEC), par jeu et par r\u00e9gime :", "",
         entete_md(c("Jeu", "R\u00e9gime", "n", paste(VARIANTES, "\u2265 1 A ou E / \u2265 1 E"))))
  for (j in intersect(JEUX, names(DM))) for (r in c("toutes", REG)) {
    MX <- DM[[j]]; rows <- lignes_pop(j, MX, r)
    if (!any(rows) || all(MX$verd$V1[rows] == "-")) next
    cols <- vapply(VARIANTES, function(v) { x <- MX$verd[[v]][rows]
      sprintf("%s / %s", num(mean(grepl("[AE]", x)), 4), num(mean(grepl("E", x, fixed = TRUE)), 4)) }, "")
    L <- c(L, ligne_md(j, if (r == "toutes") "tous" else LIB_REG[[r]], sum(rows), paste(cols, collapse = " | ")))
  }
  c(L, "")
}

tableau_t3 <- function(DL, DM, OL) {
  L <- c("### T3 -- B effectifs, tirages de V3b, p absentes, quasi-\u00e9galit\u00e9s (h2) et dur\u00e9es par r\u00e9gime", "",
         entete_md(c("Jeu", "R\u00e9gime", "n", "retenues de V1 : m\u00e9d. [min ; max]", "|A| de V3a : m\u00e9d. [min ; max]",
                     "|A| de V3b : m\u00e9d. [min ; max]", "tirages de V3b : moyenne [m\u00e9d. ; max]", "B_max atteint",
                     "p absentes V1 ; V3a ; V3b (cellules r\u00e9plication x statistique, motifs)", "(h2) r\u00e9pl. avec \u2265 1 quasi-\u00e9galit\u00e9 (BP, BP79, White, BF, RESET, Intercept)",
                     "dur\u00e9e par r\u00e9plication (s) : moyenne [m\u00e9d. ; max]")))
  mmm <- function(v) if (!length(v)) "\u2014" else sprintf("%.0f [%.0f ; %.0f]", stats::median(v), min(v), max(v))
  for (j in intersect(c(JEUX, CODES_SCEN), names(DL))) for (r in c(REG, "ecartee", "erreur")) {
    D <- DL[[j]]; MX <- DM[[j]]
    k <- if (r %in% REG) D$statut == "traitee" & D$regime == r else D$statut == r
    if (!any(k)) next
    if (r == "ecartee") { L <- c(L, ligne_md(lib_pop(j), "\u00e9cart\u00e9es (refus de #188 ou erreur de usp_ajuster())", sum(k), paste(rep("\u2014", 7), collapse = " | "),
                                             sprintf("%s", num(mean(D$duree[k]), 2)))); next }
    if (r == "erreur") { L <- c(L, ligne_md(lib_pop(j), sprintf("en erreur (statut erreur, hors population ; refus\u00e9es par --combiner) : %s",
                                                                liste_cel(sprintf("b = %.0f (%s) : %s", D$b[k], D$regime[k], D$discordances[k]), 20)),
                                            sum(k), paste(rep("\u2014", 7), collapse = " | "), sprintf("%s", num(mean(D$duree[k]), 2)))); next }
    ab <- vapply(c("V1", "V3a", "V3b"), function(v) {
      m <- MX$M[[v]][k, , drop = FALSE]; m <- m[m != "-"]
      if (!length(m)) "0" else { t <- table(m); sprintf("%d (%s)", length(m), paste(sprintf("%s %d", LIB_MOTIF[names(t)], as.integer(t)), collapse = ", ")) }
    }, "")
    h2 <- vapply(STATS_P2, function(s) sum(D[[paste0("h2:", s)]][k] > 0), 1)
    L <- c(L, ligne_md(lib_pop(j), LIB_REG[[r]], sum(k), mmm(B_BOOT - D$ech_rapide[k] - D$ech_stats[k]),
                       mmm(D$a_v1[k]), mmm(D$ret_v3b[k]),
                       sprintf("%.0f [%.0f ; %.0f]", mean(D$tir_v3b[k]), stats::median(D$tir_v3b[k]), max(D$tir_v3b[k])),
                       sprintf("%d (%s)", sum(D$arret[k] == "B_max"), num(mean(D$arret[k] == "B_max"), 4)),
                       paste(ab, collapse = " ; "), paste(h2, collapse = " ; "),
                       sprintf("%s [%s ; %s]", num(mean(D$duree[k]), 2), num(stats::median(D$duree[k]), 2), num(max(D$duree[k]), 2))))
  }
  L <- c(L, "")
  for (j in names(OL)) {
    o <- OL[[j]]
    if (!nrow(o)) next
    L <- c(L, sprintf("**Jeu observ\u00e9 %s** (b = 0, bootstrap sous %.0f, flux de V3b sous %.0f) : \u03b4\u0302 = %s (%s) ; \u03b4\u0302** : %.0f au bord 0, %.0f int\u00e9rieurs, %.0f au bord 1 ; V3b : %.0f tirages, %.0f retenus, arr\u00eat %s.",
                      j, GRAINE_BOOT, GRAINE_V3B, num(o$delta, 6), LIB_REG[[o$regime]], o$dd_bord0, o$dd_interieur, o$dd_bord1,
                      o$tir_v3b, o$ret_v3b, o$arret), "",
           entete_md(c("Statistique (sens)", "p V1 (B)", "p V3a (B)", "p V3b (B)", "motifs d'absence")))
    for (s in STATS) {
      cel <- vapply(c("V1", "V3a", "V3b"), function(v) {
        p <- o[[sprintf("p_%s:%s", v, s)]]
        sprintf("%s (%.0f)", if (is.finite(p)) num(p, 4) else "\u2014", o[[sprintf("B_%s:%s", v, s)]])
      }, "")
      mo <- vapply(c("V1", "V3a", "V3b"), function(v) o[[sprintf("m_%s:%s", v, s)]], "")
      mo <- unique(mo[mo != "-"])
      L <- c(L, ligne_md(sprintf("%s (%s)", s, QUEUE[[s]]), cel[1], cel[2], cel[3], if (length(mo)) paste(LIB_MOTIF[mo], collapse = " ; ") else "\u2014"))
    }
    L <- c(L, "")
  }
  L
}

aide_lecture <- function() c(
  "### Aide \u00e0 la lecture", "",
  paste("Statut : **constat de simulation** sous les mod\u00e8les ajust\u00e9s \u00e0 J1 et J2 et sous le mod\u00e8le synth\u00e9tique J3, pas un r\u00e9sultat",
        "g\u00e9n\u00e9ral. V1 : p_mc du moteur (rejeu de usp_bootstrap(), contr\u00f4les (i1), (i2)) ; V3a : tirages de V1 dont \u03b4\u0302** est dans le",
        "r\u00e9gime de \u03b4\u0302*_b ; V3b : V3a compl\u00e9t\u00e9e par un flux distinct jusqu'\u00e0 999 retenus ou 25 000 tirages ; V3h : V3b \u00e0 \u03b4\u0302*",
        "int\u00e9rieur, V1 aux bords. **Aucune r\u00e9f\u00e9rence ne fonde V3 \u00e0 T = 8.**"), "",
  paste("IC : Clopper-Pearson \u00e0 95 %, incertitude Monte-Carlo sur le taux (fonction du nombre de r\u00e9plications), pas l'erreur",
        "d'approximation en T. L'erreur li\u00e9e \u00e0 B fait partie de la proc\u00e9dure mesur\u00e9e. Taux par r\u00e9gime : conditionnels \u00e0 un \u00e9v\u00e9nement",
        "fonction des donn\u00e9es. Bande de Bradley (1978) : convention, pas th\u00e9or\u00e8me (r\u00e8gle de lecture de #166) ; bande non",
        "applicable si la r\u00e9f\u00e9rence est inf\u00e9rieure \u00e0 2/n (L6). Population : J1 aux bords (int\u00e9rieur descriptif, T1 bis) ; J2 et J3,",
        "r\u00e9plications trait\u00e9es (\u00e9cart\u00e9es par le refus de #188 ou une erreur de usp_ajuster(), ou au statut erreur : T3)."), "",
  paste("McNemar exact, Holm au niveau 0,05 par famille (par. 2.1, Q-A1-5). \u00c0 l'\u00e9tape 6, les d\u00e9cisions sont mesur\u00e9es : la",
        "lecture \u00ab au point \u00bb et la lecture \u00ab sous ind\u00e9pendance \u00bb de L10, qui portent sur un McNemar pr\u00e9dit par la grille, se r\u00e9duisent",
        "au test exact sur les paires discordantes mesur\u00e9es.",
        "C5 se lit selon L15 (annotation du 10/10/2026) : un t\u00e9moin significatif est expliqu\u00e9 si sa diff\u00e9rence V3b \u2212 V1",
        "mesur\u00e9e a le signe pr\u00e9dit par la grille et reste \u00e0 moins de e* de la pr\u00e9diction ; sinon il suspend la lecture."), "",
  "**Crit\u00e8re de la sp\u00e9cification (par. 2.1 et 2.2), report\u00e9 sans modification, \u00e9valu\u00e9 m\u00e9caniquement sans conclure :**", "",
  paste(">", TEXTE_CRITERE_229), "")

tableaux_regime <- function(DL, OL, REF, LIGNES_T2) {
  DM <- lapply(DL, matrices)
  COND <- conditions_regime(DM, REF)
  c("### \u00c9valuation m\u00e9canique des conditions C1, C2, C3, C5 (sans conclure ; C4 : partie P)", "",
    tableau_conditions(COND), "**Profils (par. 2.3), partiels avant la partie P :**", "", profils(COND, FALSE), tableau_l15(DM),
    tableau_t1(DM, REF), tableau_t1bis(DM, REF), tableau_t2(DM, LIGNES_T2), tableau_t3(DL, DM, OL))
}

###############################################################################
#  TABLEAUX DE LA PARTIE PUISSANCE (P, C4, profils)
###############################################################################
conditions_c4 <- function(DP) {
  C <- list()
  ajout <- function(cond, v, etat, detail) C[[length(C) + 1L]] <<- data.frame(cond = cond, variante = v, etat = etat,
                                                                              detail = detail, vide = FALSE, stringsAsFactors = FALSE)
  scs <- intersect(CODES_SCEN, names(DP))
  manque <- setdiff(CODES_SCEN, scs)
  txt_manque <- if (length(manque)) sprintf(" ; sc\u00e9narios absents : %s", paste(manque, collapse = ", ")) else ""
  for (v in VARIANTES_CRIT) {
    def <- character(0); n_ev <- 0L
    for (sc in scs) for (ia in IA) {
      MX <- DP[[sc]]; rows <- lignes_pop(sc, MX, "toutes")
      if (!any(rows)) next
      n_ev <- n_ev + 1L
      mc <- famille_mcn(MX, v, SEUILS[match(ia, IA)], rows, F_R)
      k <- mc$p_holm < NIVEAU_HOLM & mc$n10 > mc$n01
      if (any(k)) def <- c(def, sprintf("%s %s %s (%d/%d, p Holm %s)", sc, mc$stat[k], lib_ia(ia), mc$n01[k], mc$n10[k],
                                        fmt_p(mc$p_holm[k])))
    }
    ajout("C4a", v, if (!n_ev) ETAT[["ne"]] else if (length(def)) ETAT[["ko"]] else ETAT[["ok"]],
          sprintf("perte significative (McNemar Holm < 0,05, n10 > n01, F_R, toutes r\u00e9plications) : %s%s", liste_cel(def), txt_manque))
    gain <- character(0); n_ev <- 0L
    for (sc in scs) {
      MX <- DP[[sc]]; rows <- lignes_pop(sc, MX, "interieur")
      if (!any(rows)) next
      n_ev <- n_ev + 1L
      cib <- CIBLES[[SCENARIOS$famille[SCENARIOS$code == sc]]]
      mc <- famille_mcn(MX, v, 0.10, rows, cib)
      k <- mc$p_holm < NIVEAU_HOLM & mc$n01 > mc$n10
      if (any(k)) gain <- c(gain, sprintf("%s %s (%d/%d, p Holm %s)", sc, mc$stat[k], mc$n01[k], mc$n10[k],
                                          fmt_p(mc$p_holm[k])))
    }
    ajout("C4b", v, if (!n_ev) ETAT[["ne"]] else if (length(gain)) ETAT[["ok"]] else ETAT[["ko"]],
          sprintf("gain significatif \u00e0 \u03b4\u0302* int\u00e9rieur (\u03b1 = 0,10, Holm sur l'ensemble cible, n01 > n10) : %s%s", liste_cel(gain), txt_manque))
  }
  do.call(rbind, C)
}
tableaux_puissance <- function(DP, DLR, REF) {
  DM <- lapply(DP, matrices)
  C4 <- conditions_c4(DM)
  L <- c("### Partie P -- conditions C4 et profils (sans conclure)", "", tableau_conditions(C4))
  if (!is.null(DLR)) {
    DMR <- lapply(DLR, matrices)
    COND <- rbind(conditions_regime(DMR, REF), C4)
    L <- c(L, "**Profils (par. 2.3) : C1 \u00e0 C3 relus dans les valeurs brutes de la partie r\u00e9gime, C4 de cette partie :**", "", profils(COND, TRUE))
  } else L <- c(L, "Profils non \u00e9valu\u00e9s : valeurs brutes de la partie r\u00e9gime indisponibles.", "")
  # Niveaux de J2 (T1, population du critere) pour C4c.
  niv <- if (!is.null(DLR) && "J2" %in% names(DLR)) { MX <- matrices(DLR$J2); rows <- lignes_pop("J2", MX)
    lapply(stats::setNames(nm = IA), function(ia) vapply(VARIANTES, function(v) vapply(STATS, function(s) {
      p <- MX$P[[v]][rows, s]; mean(is.finite(p) & p < SEUILS[match(ia, IA)]) }, 1), numeric(NS))) } else NULL
  L <- c(L, "### P1 -- puissance par sc\u00e9nario, statistique et variante (toutes r\u00e9plications trait\u00e9es ; p absente = non-rejet)", "",
         paste("Taux de rejet [IC 95 %], McNemar contre V1 (n01 / n10, p Holm : famille (sc\u00e9nario, \u03b1, variante) sur F_R ; F_T s\u00e9par\u00e9e,",
               "descriptive) ; niveau de la variante sur J2 (T1 de la partie r\u00e9gime) entre parenth\u00e8ses."), "",
         entete_md(c("Sc\u00e9nario", "Statistique", "cible", "Variante", "n", "puissance 0,10 [IC] (niveau J2)", "McNemar 0,10",
                     "puissance 0,05 [IC] (niveau J2)", "McNemar 0,05")))
  for (sc in intersect(CODES_SCEN, names(DM))) {
    MX <- DM[[sc]]; rows <- lignes_pop(sc, MX, "toutes"); cib <- CIBLES[[SCENARIOS$famille[SCENARIOS$code == sc]]]
    mc <- lapply(stats::setNames(nm = IA), function(ia) lapply(stats::setNames(nm = VARIANTES[-1]), function(v) {
      a <- SEUILS[match(ia, IA)]; rbind(famille_mcn(MX, v, a, rows, F_R), famille_mcn(MX, v, a, rows, F_T)) }))
    for (s in STATS) for (v in VARIANTES) {
      cols <- unlist(lapply(IA, function(ia) {
        a <- SEUILS[match(ia, IA)]; p <- MX$P[[v]][rows, s]; k <- sum(is.finite(p) & p < a); n <- sum(rows)
        m <- if (v == "V1") "\u2014" else { x <- mc[[ia]][[v]]; x <- x[x$stat == s, ]
          sprintf("%d / %d, %s", x$n01, x$n10, fmt_p(x$p_holm)) }
        c(sprintf("%s %s (%s)", num(if (n) k / n else NA, 4), txt_ic(ic_cp(k, n)), if (is.null(niv)) "\u2014" else num(niv[[ia]][s, v], 4)), m)
      }))
      L <- c(L, ligne_md(lib_pop(sc), s, if (s %in% cib) "oui" else "", v, sum(rows), paste(cols, collapse = " | ")))
    }
  }
  L <- c(L, "", "### C4c (descriptif) -- puissance de l'ensemble cible par r\u00e9gime de \u03b4\u0302* (\u03b1 = 0,10 ; tous / \u03b4\u0302* = 0 / int\u00e9rieur / \u03b4\u0302* = 1)", "",
         entete_md(c("Sc\u00e9nario", "Statistique", "n (tous ; 0 ; int. ; 1)", "V1", "V3a", "V3b", "V3h")))
  for (sc in intersect(CODES_SCEN, names(DM))) {
    MX <- DM[[sc]]; cib <- CIBLES[[SCENARIOS$famille[SCENARIOS$code == sc]]]
    rs <- list(tout = lignes_pop(sc, MX, "toutes"), bord0 = lignes_pop(sc, MX, "bord0"),
               interieur = lignes_pop(sc, MX, "interieur"), bord1 = lignes_pop(sc, MX, "bord1"))
    for (s in cib)
      L <- c(L, ligne_md(lib_pop(sc), s, paste(vapply(rs, sum, 1L), collapse = " ; "),
                         paste(vapply(VARIANTES, function(v) paste(vapply(rs, function(r) {
                           p <- MX$P[[v]][r, s]; if (any(r)) num(mean(is.finite(p) & p < 0.10), 3) else "\u2014" }, ""), collapse = " ; "), ""),
                               collapse = " | ")))
  }
  c(L, "", tableau_t3(DP, DM, list()))
}

###############################################################################
#  SOURCES : TABLEAU DE LA GRILLE, VALEURS BRUTES DE #221 ET DE #175
###############################################################################
derniere <- function(motif) {
  d <- file.path(RACINE, "docs", "tableaux")
  f <- sort(list.files(d, pattern = motif))
  if (length(f)) file.path(d, f[length(f)]) else NA_character_
}
lire_tsv <- function(f) {
  l <- readLines(f, warn = FALSE, encoding = "UTF-8")
  en <- strsplit(l[1], "\t", fixed = TRUE)[[1]]
  M <- do.call(rbind, strsplit(l[-1], "\t", fixed = TRUE))
  if (is.null(M) || ncol(M) != length(en)) stop("valeurs brutes illisibles : ", f)
  colnames(M) <- en
  M
}
# Tableau de la grille : empreinte (g5), md5 des valeurs brutes (L12),
# md5 des scenarios (L8), parametres.
lire_grille <- function(f) {
  vide <- list(ok = FALSE, g5 = NA_character_, brut_md5 = NA_character_, l8 = list(), param_spec = FALSE)
  if (is.na(f) || !file.exists(f)) return(vide)
  l <- enc2utf8(readLines(f, warn = FALSE, encoding = "UTF-8"))
  ligne <- function(debut) { x <- l[startsWith(l, debut)]; if (length(x) == 1L) x else NA_character_ }
  hex <- function(x, motif) if (is.na(x)) NA_character_ else { m <- regmatches(x, regexec(motif, x))[[1]]; if (length(m) >= 2L) m[2] else NA_character_ }
  g5 <- hex(ligne("| (g5) Empreinte sans commentaires de R/engine.R (#231) | "), "^\\| [^|]* \\| ([0-9a-f]{32}) ")
  bm <- hex(ligne("| Valeurs brutes de la grille (L12) | "), "md5 ([0-9a-f]{32})")
  l8l <- ligne("| Jeux des sc\u00e9narios de P (L8) | ")
  l8 <- lapply(stats::setNames(nm = CODES_SCEN), function(sc) {
    if (is.na(l8l)) return(NULL)
    m <- regmatches(l8l, regexec(sprintf("%s : md5 \u03b5 ([0-9a-f]{32})(, md5 t\\* ([0-9a-f]{32}))?, md5 Y ([0-9a-f]{32})", sc), l8l))[[1]]
    if (length(m) != 5L) NULL else c(E = m[2], ts = if (nzchar(m[4])) m[4] else NA_character_, Y = m[5])
  })
  par <- l[startsWith(l, "Param\u00e8tres : ")]
  ps <- length(par) == 1L && grepl("^Param\u00e8tres : M=3000;", par) && grepl(";R=2000;R_P=1000;", par, fixed = TRUE)
  list(ok = !is.na(g5), g5 = g5, brut_md5 = bm, l8 = l8, param_spec = ps)
}
# Predictions de la grille pour C5 (L15) : T1 predit (pi a B fini, V1 et
# V3b, aux deux seuils) et marges e* (cellules evaluables, L5) du tableau
# de la grille. NULL si illisibles (aucun temoin significatif ne peut alors
# etre explique).
lire_pred_c5 <- function(f) {
  if (is.na(f) || !file.exists(f)) return(NULL)
  l <- enc2utf8(readLines(f, warn = FALSE, encoding = "UTF-8"))
  i <- grep("^### T1 pr\u00e9dit", l)
  if (length(i) != 1L) return(NULL)
  j <- grep("^### ", l); j <- min(c(j[j > i], length(l) + 1L)) - 1L
  t <- l[i:j]; t <- t[startsWith(t, "| J") & !startsWith(t, "| Jeu |")]
  ch <- lapply(t, function(x) strsplit(sub(" \\|$", "", sub("^\\| ", "", x)), " | ", fixed = TRUE)[[1]])
  if (!length(ch) || any(lengths(ch) != 18L)) return(NULL)
  nb <- function(k) as.numeric(sub(",", ".", vapply(ch, `[`, "", k), fixed = TRUE))
  t1 <- data.frame(jeu = sub(" .*$", "", vapply(ch, `[`, "", 1L)), stat = sub(" \\(.*$", "", vapply(ch, `[`, "", 2L)),
                   V1_a10 = nb(6L), V3b_a10 = nb(8L), V1_a05 = nb(13L), V3b_a05 = nb(15L), stringsAsFactors = FALSE)
  m <- l[startsWith(l, "Marges e* (cellules \u00e9valuables, L5) : ")]
  if (length(m) != 1L) return(NULL)
  r <- regmatches(m, regexec("J1 ([0-9,]+) \\(0,10\\) et ([0-9,]+) \\(0,05\\) ; J2, J3 et P ([0-9,]+) \\(0,10\\) et ([0-9,]+) \\(0,05\\)", m))[[1]]
  if (length(r) != 5L) return(NULL)
  e <- as.numeric(sub(",", ".", r[2:5], fixed = TRUE))
  if (anyNA(e) || anyNA(t1[, -(1:2)])) return(NULL)
  list(t1 = t1, estar = matrix(e, 2, 2, byrow = TRUE, dimnames = list(c("J1", "J2"), IA)),
       txt = sprintf("%s (md5 %s) : T1 pr\u00e9dit, %d lignes ; e* J1 %s / %s, J2 et J3 %s / %s", chemin_cite(f), md5_fichier(f), nrow(t1),
                     num(e[1], 4), num(e[2], 4), num(e[3], 4), num(e[4], 4)))
}
PRED_C5 <- NULL; PRED_C5_TXT <- "tableau de la grille illisible : aucun t\u00e9moin significatif ne peut \u00eatre expliqu\u00e9"
charger_pred_c5 <- function(f) {
  p <- lire_pred_c5(f)
  PRED_C5 <<- p
  if (!is.null(p)) PRED_C5_TXT <<- p$txt
}

# Tailles lissees des lois discretes (T0 des tableaux de #221 ; copie
# declaree de tests/grille_regime_t8.R).
lissees <- function(f) {
  if (is.na(f) || !file.exists(f)) return(NULL)
  l <- enc2utf8(readLines(f, warn = FALSE, encoding = "UTF-8"))
  li <- l[startsWith(l, "| Tailles des lois discr\u00e8tes")]
  if (length(li) != 1L) return(NULL)
  v <- vapply(names(LIB_LOI), function(k) {
    m <- regmatches(li, regexec(paste0(gsub("([()])", "\\\\\\1", LIB_LOI[[k]]),
                                      " : atteignable [0-9,]+ et [0-9,]+, liss\u00e9e ([0-9,]+) et ([0-9,]+)"), li))[[1]]
    if (length(m) != 3L) return(c(NA_real_, NA_real_))
    as.numeric(sub(",", ".", m[2:3], fixed = TRUE))
  }, numeric(2))
  if (anyNA(v)) NULL else v
}
F_BRUT221 <- c(J1 = derniere("^[0-9]{8}-issue166-brut-J1\\.tsv$"), J2 = derniere("^[0-9]{8}-issue166-brut-J2\\.tsv$"))
F_TAB221 <- vapply(F_BRUT221, function(f) if (is.na(f)) NA_character_ else
  sub("-issue166-brut-", "-issue166-calibration-", sub("\\.tsv$", ".md", f)), "")
F_BRUT175 <- derniere("^[0-9]{8}-issue175-brut\\.tsv$")
REF_STATS <- function() {
  liss <- lissees(F_TAB221[["J2"]])
  R <- vapply(seq_along(SEUILS), function(a) vapply(STATS, function(s)
    if (s %in% DISCRETES && !is.null(liss)) liss[a, LOI_STAT[[s]]] else SEUILS[a], 1), numeric(NS))
  dimnames(R) <- list(STATS, IA)
  list(REF = R, ok = !is.null(liss), liss = liss)
}

###############################################################################
#  LECTURE D'UNE SORTIE DE TRANCHE (--combiner)
###############################################################################
CLES_CONTEXTE <- c("partie", "groupe", "modele", "configuration", "graines", "collisions", "generateur", "commit",
                   "plateforme", "empreintes", "empreinte_sc", "grille", "reference", "sources", "scenario_l8",
                   "regle_r4", "lignes_t2", "essai", "i3")
CLES_COMMUNES <- c("partie", "generateur", "commit", "plateforme", "empreintes", "empreinte_sc", "grille", "reference",
                   "configuration", "regle_r4", "lignes_t2", "essai")
LIBELLES_CONTEXTE <- c(
  partie = "Partie", groupe = "Jeu ou sc\u00e9nario", modele = "Mod\u00e8le", configuration = "Configuration", graines = "Graines",
  collisions = "Graines en collision (d\u00e9clar\u00e9es, non bloquantes)", generateur = "G\u00e9n\u00e9rateur", commit = "Commit",
  plateforme = "Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)", empreintes = "Empreintes md5 du code ex\u00e9cut\u00e9",
  empreinte_sc = "Empreinte sans commentaires de R/engine.R (#231) et md5 du fichier entier",
  grille = "Tableau de la grille (\u00e9tape 4)", reference = "Contr\u00f4le (a) : J1 observ\u00e9 contre tests/reference/premium.rds",
  sources = "Sources (valeurs brutes de #221 et de #175, tableaux de #221, valeurs brutes de la grille)",
  scenario_l8 = "Jeux du sc\u00e9nario (L8)", regle_r4 = "R\u00e8gle R4 au commit mesur\u00e9 (C-229-5)",
  lignes_t2 = "Lignes de T2 (p\u00e9rim\u00e8tre)", essai = "Essai (--essai, non versionnable)", i3 = "Contr\u00f4le (i3)")

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
  par <- unique1("PARAMETRES"); tr <- suppressWarnings(as.integer(unique1("TRANCHE")))
  ctx <- champs("CONTEXTE")
  if (!length(ctx) || any(lengths(ctx) != 2L)) refuser(f, " : lignes CONTEXTE absentes ou illisibles")
  ctx <- stats::setNames(vapply(ctx, `[`, "", 2L), vapply(ctx, `[`, "", 1L))
  if (!setequal(names(ctx), CLES_CONTEXTE) || anyDuplicated(names(ctx)))
    refuser(f, " : lignes CONTEXTE incompletes (attendues : ", paste(CLES_CONTEXTE, collapse = ", "), ")")
  st <- unique1("STATS"); rc <- unique1("REPCOLS")
  if (!identical(rc, REPCOLS)) refuser(f, " : REPCOLS differentes de celles du script")
  obs <- unique1("OBS")
  if (!(identical(obs, "sans objet") || length(obs) == length(REPCOLS))) refuser(f, " : ligne OBS illisible")
  du <- suppressWarnings(as.numeric(unique1("DUREE")))
  if (length(du) != 2L || anyNA(du)) refuser(f, " : ligne DUREE illisible")
  n_rep <- suppressWarnings(as.integer(unique1("NREP")))
  rp <- champs("REP")
  fin <- suppressWarnings(as.integer(unique1("FIN")))
  if (is.na(n_rep) || length(rp) != n_rep || !identical(fin, n_rep))
    refuser(f, sprintf(" : %d ligne(s) REP lue(s), NREP = %s, FIN = %s -- sortie tronquee ou modifiee", length(rp), n_rep, fin))
  if (any(lengths(rp) != length(REPCOLS))) refuser(f, " : ligne REP de longueur differente de REPCOLS")
  if (length(tr) != 2L || anyNA(tr)) refuser(f, " : ligne TRANCHE illisible")
  partie <- sub("^partie=([a-z]+);.*$", "\\1", par)
  groupe <- sub("^partie=[a-z]+;groupe=([A-Z0-9]+);.*$", "\\1", par)
  R <- as.integer(sub("^.*;R=([0-9]+);.*$", "\\1", par))
  list(fichier = f, parametres = par, partie = partie, groupe = groupe, R = R, debut = tr[1], fin = tr[2],
       contexte = ctx[CLES_CONTEXTE], stats = st, obs = obs, duree = du, rep = rp, md5 = md5_fichier(f),
       reprise = vapply(champs("REPRISE"), paste, "", collapse = " "))
}
# Controles d'une ligne REP, lus sur ses seuls champs (tranche, reprise et
# --combiner) : (d) invariants de V1, V3a, V3b ; (b) motifs d'absence
# connus, et ni o, ni c, ni x pour une p de V3a ou V3b absente quand celle
# de V1 existe ; verdicts "?" (incoherence) en partie regime ; etats (i1),
# (t2), (v3a). Ligne au statut "erreur" : regime dans REG ou "-".
verifier_ligne <- function(ch, partie) {
  v <- stats::setNames(ch, REPCOLS)
  n <- function(k) suppressWarnings(as.numeric(v[k]))
  out <- list(b = suppressWarnings(as.integer(v[["b"]])), statut = v[["statut"]], regime = v[["regime"]],
              i1 = v[["i1"]], t2 = v[["t2"]], v3a = v[["v3a"]], d_ok = TRUE, b_ok = TRUE, err_t2 = FALSE)
  if (identical(v[["statut"]], "erreur")) {
    out$d_ok <- v[["regime"]] %in% c(REG, "-")
    return(out)
  }
  if (!identical(v[["statut"]], "traitee")) {
    out$d_ok <- identical(v[["statut"]], "ecartee") && identical(v[["regime"]], "ecartee")
    return(out)
  }
  ret1 <- B_BOOT - n("ech_rapide") - n("ech_stats")
  dd <- n(c("dd_bord0", "dd_interieur", "dd_bord1")); names(dd) <- REG
  a <- n("a_v1"); ret <- n("ret_v3b"); tir <- n("tir_v3b")
  bv <- function(x) n(paste0("B_", x, ":", STATS))
  out$d_ok <- isTRUE(v[["regime"]] %in% REG && !anyNA(c(ret1, dd, a, ret, tir)) && sum(dd) == ret1 &&
                       a == dd[[v[["regime"]]]] && ret >= a && ret <= B_CIBLE && tir >= B_BOOT && tir <= B_MAX &&
                       v[["arret"]] %in% c("cible", "B_max") && (v[["arret"]] == "cible") == (ret == B_CIBLE) &&
                       (tir - B_BOOT) == (n("ech_rapide_v3b") + n("hors_v3b") + n("ech_stats_v3b") + ret - a) &&
                       all(bv("V1") <= ret1) && all(bv("V3a") <= a) && all(bv("V3b") <= ret))
  out$b_ok <- all(v[paste0(rep(c("m_V1", "m_V3a", "m_V3b"), each = NS), ":", STATS)] %in% c(names(CODES_MOTIF), "-"))
  # (b), C3 : une p de V3a ou de V3b absente alors que celle de V1 existe ne
  # peut avoir pour motif ni o (obs. non finie), ni c (condition du
  # catalogue), ni x (non definie) : motifs communs a V1, qui a alors une p.
  p1 <- n(paste0("p_V1:", F_R))
  for (w in c("V3a", "V3b")) {
    ab <- !is.finite(n(paste0("p_", w, ":", F_R))) & is.finite(p1)
    if (any(v[paste0("m_", w, ":", F_R)][ab] %in% c("o", "c", "x"))) out$b_ok <- FALSE
  }
  out$err_t2 <- identical(partie, "regime") && any(grepl("?", v[c("verd_V1", "verd_V3a", "verd_V3b")], fixed = TRUE))
  out
}
invariants_tranche <- function(p) {
  err <- character(0)
  d <- en_table(p$rep)
  if (!identical(as.integer(sort(d$b)), seq.int(p$debut, p$fin))) err <- c(err, "b des lignes REP differents de debut..fin")
  tr <- d$statut == "traitee"
  if (!identical(d$statut %in% c("traitee", "ecartee"), rep(TRUE, nrow(d))) ||
      any(tr & !d$regime %in% REG) || any(!tr & d$regime != "ecartee")) err <- c(err, "statut incoherent avec le regime")
  if (any(c(d$i1, d$t2, d$v3a) == "ECHEC")) err <- c(err, "controle (i1), (t2) ou (v3a) en ECHEC sur une replication")
  if (any(tr & (d$ret_v3b > B_CIBLE | d$tir_v3b > B_MAX | (d$arret == "cible") != (d$ret_v3b == B_CIBLE))))
    err <- c(err, "invariant (d) de V3b faux")
  vl <- lapply(p$rep, verifier_ligne, partie = p$partie)
  if (!all(vapply(vl, `[[`, TRUE, "d_ok"))) err <- c(err, "invariant (d) faux (lecture des champs de la ligne REP)")
  if (!all(vapply(vl, `[[`, TRUE, "b_ok"))) err <- c(err, "motif d'absence inconnu, ou o, c ou x pour une p de V3a ou V3b absente quand celle de V1 existe (b)")
  if (any(vapply(vl, `[[`, TRUE, "err_t2"))) err <- c(err, "usp_tests() en erreur (t2)")
  err
}

###############################################################################
#  MODE --combiner
###############################################################################
if (MODE_COMBINER) {
  # Fichiers : chemins, ou dossiers (fichiers <groupe>-<ii>de<KK>.txt).
  fichiers <- unlist(lapply(FICHIERS_COMB, function(f) if (dir.exists(f))
    sort(list.files(f, pattern = "^(J[123]|H0|H3|C3|C4|A4|A2)-[0-9]+de[0-9]+\\.txt$", full.names = TRUE)) else f))
  if (!length(fichiers)) refuser("aucun fichier de tranche")
  parts <- lapply(fichiers, lire_sortie)
  # Replications au statut "erreur" : toute tranche qui en contient est
  # refusee ; liste (fichier, b, message).
  errs <- unlist(lapply(parts, function(p) {
    k <- vapply(p$rep, function(x) identical(x[2], "erreur"), logical(1))
    if (any(k)) vapply(p$rep[k], function(x) sprintf("%s b = %s (r\u00e9gime %s) : %s", basename(p$fichier), x[1], x[3],
                                                     x[match("discordances", REPCOLS)]), "") else character(0)
  }))
  if (length(errs)) refuser(length(errs), " replication(s) au statut erreur (tranche(s) a relancer apres correction) : ",
                            paste(errs, collapse = " ; "))
  if (any(vapply(parts, `[[`, "", "partie") != OPT_PARTIE)) refuser("tranche(s) d'une autre partie que --partie ", OPT_PARTIE)
  for (k in CLES_COMMUNES) if (length(unique(vapply(parts, function(p) p$contexte[[k]], ""))) != 1L)
    refuser("contexte (", k, ") different entre les tranches")
  if (length(unique(lapply(parts, `[[`, "stats"))) != 1L) refuser("lignes STATS differentes entre les tranches")
  # JOURNAL : md5 de chaque tranche, debit P4 et empreinte (#231, controle
  # (i3)). Lignes attendues : "- Debit P4 : <texte>" (Debit avec ou sans
  # accent) et "- Empreinte sans commentaires : <md5>", une fois chacune.
  TXT_JOURNAL <- "non fourni"; TXT_DEBIT <- "non fourni (--journal absent)"; TXT_EMP_J <- "non fourni (--journal absent)"
  if (!is.na(OPT_JOURNAL)) {
    if (!file.exists(OPT_JOURNAL)) refuser("--journal introuvable : ", OPT_JOURNAL)
    jl <- readLines(OPT_JOURNAL, warn = FALSE, encoding = "UTF-8")
    for (p in parts) {
      li <- jl[grepl(basename(p$fichier), jl, fixed = TRUE)]
      md <- unique(unlist(regmatches(li, gregexpr("\\b[0-9a-f]{32}\\b", li))))
      if (!length(li) || !p$md5 %in% md)
        refuser("--journal : md5 de ", basename(p$fichier), " (", p$md5, ") absent du JOURNAL ou different (", paste(md, collapse = ", "), ")")
    }
    jl <- enc2utf8(jl)
    ld <- regmatches(jl, regexec("^\\s*- D(\u00e9|e)bit P4 : (.*\\S)\\s*$", jl))
    ld <- Filter(length, ld)
    if (length(ld) != 1L) refuser("--journal : ", length(ld), " ligne(s) \"- Debit P4 : <texte>\" dans le JOURNAL (une attendue)")
    le <- regmatches(jl, regexec("^\\s*- Empreinte sans commentaires : ([0-9a-f]{32})\\s*$", jl))
    le <- Filter(length, le)
    if (length(le) != 1L) refuser("--journal : ", length(le), " ligne(s) \"- Empreinte sans commentaires : <md5>\" dans le JOURNAL (une attendue)")
    emp <- sub(" .*$", "", parts[[1]]$contexte[["empreinte_sc"]])
    if (!identical(le[[1]][2], emp))
      refuser("--journal : (i3) empreinte sans commentaires du JOURNAL ", le[[1]][2], " differente de celle des tranches ", emp)
    TXT_DEBIT <- gsub("|", "\\|", ld[[1]][3], fixed = TRUE)
    TXT_EMP_J <- sprintf("%s, \u00e9gale \u00e0 celle des tranches (contr\u00f4le (i3))", le[[1]][2])
    TXT_JOURNAL <- sprintf("%s (md5 %s) : md5 des %d tranches conformes ; lignes du d\u00e9bit P4 et de l'empreinte (#231) lues", chemin_cite(OPT_JOURNAL),
                           md5_fichier(OPT_JOURNAL), length(parts))
  }
  groupes <- unique(vapply(parts, `[[`, "", "groupe"))
  attendus <- if (OPT_PARTIE == "regime") JEUX else CODES_SCEN
  if (!all(groupes %in% attendus)) refuser("groupe illisible dans PARAMETRES")
  DL <- list(); OL <- list(); CTX <- list(); RG <- integer(0); DUR <- list(); BRUTS <- list()
  for (g in intersect(attendus, groupes)) {
    pg <- parts[vapply(parts, function(p) p$groupe == g, logical(1))]
    if (length(unique(vapply(pg, `[[`, "", "parametres"))) != 1L) refuser("parametres differents entre les tranches de ", g)
    if (length(unique(lapply(pg, `[[`, "contexte"))) != 1L) {
      kd <- CLES_CONTEXTE[vapply(CLES_CONTEXTE, function(k) length(unique(vapply(pg, function(p) p$contexte[[k]], ""))) > 1L, logical(1))]
      refuser("contexte (T0) different entre les tranches de ", g, " : ", paste(kd, collapse = ", "))
    }
    if (length(unique(lapply(pg, `[[`, "obs"))) != 1L) refuser("ligne OBS (jeu observe) differente entre les tranches de ", g)
    R_g <- pg[[1]]$R
    idx <- unlist(lapply(pg, function(p) seq.int(p$debut, p$fin)))
    if (anyDuplicated(idx) || !setequal(idx, seq_len(R_g))) refuser("les tranches de ", g, " ne couvrent pas 1..", R_g, " exactement une fois")
    for (p in pg) {
      e <- invariants_tranche(p)
      if (length(e)) refuser(p$fichier, " : invariant(s) du corps faux -- ", paste(e, collapse = " ; "))
    }
    d <- en_table(do.call(c, lapply(pg, `[[`, "rep")))
    DL[[g]] <- d[order(d$b), , drop = FALSE]
    OL[[g]] <- if (identical(pg[[1]]$obs, "sans objet")) en_table(list()) else en_table(list(pg[[1]]$obs))
    CTX[[g]] <- pg[[1]]$contexte
    RG[g] <- R_g
    DUR[[g]] <- Reduce(`+`, lapply(pg, `[[`, "duree"))
    rp <- c(if (identical(pg[[1]]$obs, "sans objet")) list() else list(pg[[1]]$obs), do.call(c, lapply(pg, `[[`, "rep")))
    rp <- rp[order(as.integer(vapply(rp, `[`, "", 1L)))]
    BRUTS[[g]] <- vapply(rp, function(x) paste(c(g, x), collapse = "\t"), "")
  }
  COMMIT_COMB <- commit_depot(SCRIPT)
  EMPREINTES_COMB <- empreintes_code(SCRIPT, c(SCRIPT_72, SPEC))
  EMP_COMB <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
  ctx1 <- CTX[[1]]
  nv <- c(motifs_non_versionnable(ctx1[["commit"]], ctx1[["empreintes"]]),
          motifs_non_versionnable(COMMIT_COMB, EMPREINTES_COMB, "de la combinaison"),
          if (!startsWith(ctx1[["empreinte_sc"]], EMP_COMB)) sprintf("empreinte (#231) de la combinaison %s diff\u00e9rente de celle des tranches", EMP_COMB),
          if (!identical(ctx1[["essai"]], "non")) "tranches d'essai (--essai)",
          if (!setequal(groupes, attendus)) sprintf("%s ne sont pas tous combin\u00e9s", paste(attendus, collapse = ", ")),
          if (any(RG != if (OPT_PARTIE == "regime") R_SPEC else RP_SPEC)) "param\u00e8tres r\u00e9duits (--R ou --R-P)")
  # Sources citees par les tranches : suivies par git et inchangees (md5).
  src <- unique(unlist(lapply(CTX, function(cx) { z <- paste(cx[["sources"]], cx[["grille"]])
    regmatches(z, gregexpr("docs/tableaux/[^ ]+ \\(md5 [0-9a-f]{32}", z)) })))
  for (s in src) {
    f <- file.path(RACINE, sub(" \\(md5.*$", "", s)); m <- sub("^.*md5 ", "", s)
    if (!identical(suivi_git(f), "oui")) nv <- c(nv, sprintf("%s non suivi par git", chemin_cite(f)))
    else if (!identical(md5_fichier(f), m)) nv <- c(nv, sprintf("%s modifi\u00e9 depuis les tranches (md5)", chemin_cite(f)))
  }
  F_GRILLE_C <- sub(" \\(md5.*$", "", ctx1[["grille"]])
  charger_pred_c5(if (grepl("^(/|[A-Za-z]:)", F_GRILLE_C)) F_GRILLE_C else file.path(RACINE, F_GRILLE_C))
  if (!identical(suivi_git(file.path(RACINE, F_GRILLE_C)), "oui")) nv <- c(nv, sprintf("tableau de la grille %s non suivi par git", F_GRILLE_C))
  if (OPT_ECRIRE && length(nv))
    refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
            " -- relancer sur un arbre propre, ou utiliser --sortie DOSSIER hors du depot")
  RF <- REF_STATS()
  LIGNES_T2 <- strsplit(ctx1[["lignes_t2"]], " ; ", fixed = TRUE)[[1]]
  # Discordances listees (i1), (v3a), (t2).
  disc <- unlist(lapply(names(DL), function(g) { d <- DL[[g]]; k <- d$discordances != "-"
    if (any(k)) sprintf("%s b = %s : %s", g, d$b[k], d$discordances[k]) else character(0) }))
  disc_obs <- unlist(lapply(names(OL), function(g) { o <- OL[[g]]
    if (nrow(o) && o$discordances != "-") sprintf("%s observ\u00e9 : %s", g, o$discordances) else character(0) }))
  # Valeurs brutes (construites avant le T0, qui cite leur md5).
  col1 <- if (OPT_PARTIE == "regime") "jeu" else "scenario"
  BRUT <- c(paste(c(col1, REPCOLS), collapse = "\t"), unlist(BRUTS[intersect(attendus, names(BRUTS))]))
  F_BRUT_TMP <- tempfile("p229_brut_", fileext = ".tsv")
  con <- file(F_BRUT_TMP, open = "wb"); writeLines(enc2utf8(BRUT), con, useBytes = TRUE); close(con)
  MD5_BRUT <- md5_fichier(F_BRUT_TMP)
  # Partie puissance : valeurs brutes de la partie regime (C1 a C3, niveaux).
  DLR <- NULL; TXT_RB <- "sans objet"
  if (OPT_PARTIE == "puissance") {
    frb <- if (!is.na(OPT_REGIME_BRUT)) OPT_REGIME_BRUT else derniere("^[0-9]{8}-issue229-p-conditionnelle-regime-brut\\.tsv$")
    if (!is.na(frb) && file.exists(frb)) {
      M <- lire_tsv(frb)
      if (!identical(colnames(M), c("jeu", REPCOLS))) refuser("--regime-brut : colonnes differentes de celles du script : ", frb)
      DLR <- lapply(stats::setNames(nm = intersect(JEUX, unique(M[, "jeu"]))), function(j) {
        x <- M[M[, "jeu"] == j & M[, "b"] != "0", -1, drop = FALSE]
        en_table(lapply(seq_len(nrow(x)), function(i) unname(x[i, ])))
      })
      TXT_RB <- sprintf("%s (md5 %s, suivi par git : %s)", chemin_cite(frb), md5_fichier(frb), suivi_git(frb))
      if (!identical(suivi_git(frb), "oui")) nv <- c(nv, "valeurs brutes de la partie r\u00e9gime non suivies par git")
    } else TXT_RB <- "introuvables (profils non \u00e9valu\u00e9s)"
    if (OPT_ECRIRE && is.null(DLR)) refuser("--ecrire refuse : valeurs brutes de la partie regime introuvables (--regime-brut)")
  }
  # T0
  t0 <- c(entete_md(c("Grandeur", "Valeur")),
          vapply(CLES_COMMUNES, function(k) ligne_md(LIBELLES_CONTEXTE[[k]], ctx1[[k]]), ""))
  for (g in names(DL)) {
    t0 <- c(t0, vapply(setdiff(CLES_CONTEXTE, CLES_COMMUNES), function(k) ligne_md(sprintf("%s : %s", g, LIBELLES_CONTEXTE[[k]]), CTX[[g]][[k]]), ""),
            ligne_md(sprintf("%s : R\u00e9plications", g), sprintf("%d (tranches %s)", RG[[g]],
                     paste(vapply(parts[vapply(parts, function(p) p$groupe == g, logical(1))], function(p) sprintf("%d-%d", p$debut, p$fin), ""), collapse = ", "))),
            ligne_md(sprintf("%s : Dur\u00e9e cumul\u00e9e (s)", g), sprintf("contr\u00f4les %.0f ; total %.0f ; r\u00e9plications %.0f",
                                                                            DUR[[g]][1], DUR[[g]][2], sum(DL[[g]]$duree))))
  }
  t0 <- c(t0, ligne_md("Fichiers de tranches (md5)", paste(vapply(parts, function(p) sprintf("%s %s", basename(p$fichier), p$md5), ""), collapse = " ; ")),
          ligne_md("JOURNAL", TXT_JOURNAL),
          ligne_md("D\u00e9bit P4 (ligne du JOURNAL)", TXT_DEBIT),
          ligne_md("Empreinte sans commentaires (#231) du JOURNAL", TXT_EMP_J),
          ligne_md("Reprises (--reprendre : sortie partielle relue, r\u00e9plications faites conserv\u00e9es)",
                   liste_cel(unlist(lapply(parts, function(p) if (length(p$reprise)) sprintf("%s : %s", basename(p$fichier), p$reprise))), 50)),
          ligne_md("Commit de la combinaison", COMMIT_COMB), ligne_md("Empreintes md5 du combinateur", EMPREINTES_COMB),
          ligne_md("Empreinte sans commentaires de R/engine.R \u00e0 la combinaison (#231)", EMP_COMB),
          ligne_md("R\u00e9f\u00e9rences des lois discr\u00e8tes (tailles liss\u00e9es de #166 \u00e0 B = 999, T0 du tableau de #221 de J2)",
                   if (RF$ok) paste(sprintf("%s %s et %s", names(LIB_LOI), vapply(RF$liss[1, ], num, "", d = 5), vapply(RF$liss[2, ], num, "", d = 5)), collapse = " ; ") else "illisibles"),
          ligne_md("Valeurs brutes de cette sortie", sprintf("%s : md5 %s, %d lignes de r\u00e9plications (copie hors du d\u00e9p\u00f4t : --brut)",
                                                           NOMS_SORTIE[[OPT_PARTIE]][["brut"]], MD5_BRUT, length(BRUT) - 1L)),
          if (OPT_PARTIE == "puissance") ligne_md("Valeurs brutes de la partie r\u00e9gime (C1 \u00e0 C3, niveaux de J2)", TXT_RB),
          ligne_md("Intensit\u00e9s des sc\u00e9narios de P (constantes INTENSITES)", paste(sprintf("%s : %s", names(LIB_SCEN), LIB_SCEN), collapse = " ; ")),
          ligne_md("Discordances list\u00e9es (i1), (v3a), (t2) (expliqu\u00e9es)", liste_cel(c(disc_obs, disc), 200)),
          ligne_md("Versionnable (--ecrire)", if (length(nv)) paste("non :", paste(nv, collapse = " ; ")) else "oui"),
          ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", sprintf("OK dans les %d tranche(s), invariants du corps v\u00e9rifi\u00e9s", length(parts))))
  titre <- if (OPT_PARTIE == "regime")
    "## Mesure #229 : p-value Monte-Carlo conditionnelle au r\u00e9gime de \u03b4\u0302, T = 8 -- niveaux (T0 \u00e0 T3)" else
    "## Mesure #229 : p-value Monte-Carlo conditionnelle au r\u00e9gime de \u03b4\u0302, T = 8 -- puissance (partie P)"
  sortie <- c(sprintf("%s -- combinaison de %d tranche(s)", titre, length(parts)), "",
              sprintf("Param\u00e8tres : %s", paste(vapply(names(DL), function(g)
                parts[vapply(parts, function(p) p$groupe == g, logical(1))][[1]]$parametres, ""), collapse = " | ")), "",
              "### T0 -- provenance (identique dans les tranches de chaque groupe, v\u00e9rifi\u00e9)", "", t0, "",
              aide_lecture(),
              if (OPT_PARTIE == "regime") tableaux_regime(DL, OL, RF$REF, LIGNES_T2) else tableaux_puissance(DL, DLR, RF$REF))
  ecrire_console(sortie)
  ecrire <- function(f, lignes) { con <- file(f, open = "wb"); writeLines(enc2utf8(lignes), con, useBytes = TRUE); close(con) }
  # ecraser : cible de docs/tableaux/ deja controlee par garde_ecrasement()
  # (--remplacer) ; jamais hors du depot.
  copier_brut <- function(f, ecraser = FALSE) {
    if (!file.copy(F_BRUT_TMP, f, overwrite = ecraser) || !identical(md5_fichier(f), MD5_BRUT))
      refuser("valeurs brutes : copie refusee ou md5 different : ", f)
    message("\u00e9crit (valeurs brutes, md5 ", MD5_BRUT, ") : ", f)
  }
  if (OPT_ECRIRE) {
    # Gardes reprises avant d'ecrire (l'etat du depot a pu changer).
    nv1 <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, c(SCRIPT_72, SPEC)), "de la combinaison")
    if (length(nv1)) refuser("--ecrire refuse : ", paste(nv1, collapse = " ; "))
    rem <- garde_ecrasement(CIBLES_ECRIRE, OPT_REMPLACER, RACINE)
    # Copie hors du depot AVANT les fichiers versionnes, brut AVANT le tableau.
    copier_brut(OPT_BRUT)
    copier_brut(CIBLES_ECRIRE[["brut"]], ecraser = TRUE)
    ecrire(CIBLES_ECRIRE[["md"]], inserer_t0(sortie, c(ligne_remplacement(rem, CIBLES_ECRIRE[["md"]]),
                                                       ligne_remplacement(rem, CIBLES_ECRIRE[["brut"]]))))
    message("\u00e9crit : ", CIBLES_ECRIRE[["md"]])
  } else {
    if (!is.na(OPT_BRUT)) copier_brut(OPT_BRUT)
    if (!is.na(OPT_SORTIE)) {
      copier_brut(file.path(OPT_SORTIE, NOMS_SORTIE[[OPT_PARTIE]][["brut"]]))
      ecrire(file.path(OPT_SORTIE, NOMS_SORTIE[[OPT_PARTIE]][["md"]]), sortie)
      message("\u00e9crit : ", file.path(OPT_SORTIE, NOMS_SORTIE[[OPT_PARTIE]][["md"]]))
    }
  }
  unlink(F_BRUT_TMP)
  quit(status = 0L)
}

###############################################################################
#  CALCUL D'UNE REPLICATION (tranche et --debit)
###############################################################################
# .Random.seed de l'appelant restaure (supprime s'il n'existait pas).
proteger <- function(expr) {
  a <- exists(".Random.seed", envir = globalenv(), inherits = FALSE)
  rs <- if (a) get(".Random.seed", envir = globalenv())
  on.exit(if (a) assign(".Random.seed", rs, envir = globalenv()) else
    if (exists(".Random.seed", envir = globalenv(), inherits = FALSE)) rm(".Random.seed", envir = globalenv()))
  expr
}
# Contre-implementation des six statistiques de P2 (tests/outils_tests.R) :
# catalogue CAT_CONTRE, identique a USP_CATALOGUE_MC hors BP, BP79, White,
# BF, RESET et Intercept (meme sens de rejet, memes conditions).
contre_intercept <- function(x, y, pi) {
  if (usp_volumes_constants(x) || usp_pertes_constantes(y)) return(NA_real_)
  m <- suppressWarnings(contre_lm_pondere(x, y, pi))
  if (is.null(m) || !"x" %in% rownames(m$coefficients)) return(NA_real_)
  m$coefficients[1, 3]
}
CAT_CONTRE <- USP_CATALOGUE_MC
CAT_CONTRE$BP$calc <- function(e) suppressWarnings(contre_bp(e$z^2, e$x))$stat
CAT_CONTRE$BP79$calc <- function(e) suppressWarnings(contre_bp79(e$z^2, e$x))$stat
CAT_CONTRE$White$calc <- function(e) suppressWarnings(contre_white(e$z^2, e$x))$stat
CAT_CONTRE$BF$calc <- function(e) suppressWarnings(contre_bf(e$z, e$x))$stat
CAT_CONTRE$RESET$calc <- function(e) suppressWarnings(contre_reset(e$x, e$y))$stat
CAT_CONTRE$Intercept$calc <- function(e) contre_intercept(e$x, e$y, e$pi)
# (h1) : six paires (moteur, contre-implementation), regle de
# tests/unitaires/test_regressions_qr.R (copie declaree de meme_num(),
# concorde() et des arguments).
PAIRES_P2 <- list(BP79 = list(f = test_breusch_pagan_original, g = contre_bp79), BP = list(f = test_breusch_pagan, g = contre_bp),
                  White = list(f = test_white, g = contre_white), BF = list(f = test_brown_forsythe, g = contre_bf),
                  RESET = list(f = test_reset, g = contre_reset), Pond = list(f = .usp_lm_pondere, g = contre_lm_pondere))
evaluer_p2 <- function(f, args) tryCatch(suppressWarnings(do.call(f, args)), error = function(e) e)
meme_num <- function(a, b) {
  if (!identical(typeof(a), typeof(b)) || length(a) != length(b)) return(FALSE)
  if (!identical(is.na(a), is.na(b)) || !identical(is.nan(a), is.nan(b))) return(FALSE)
  k <- !is.na(b)
  all(a[k] == b[k] | abs(a[k] - b[k]) <= REL_QR * abs(b[k]))
}
concorde <- function(nom, a, b) {
  if (inherits(a, "error") || inherits(b, "error")) return(inherits(a, "error") && inherits(b, "error"))
  if (nom == "Pond") {
    if (is.null(a) || is.null(b)) return(is.null(a) && is.null(b))
    ca <- a$coefficients; cb <- b$coefficients
    return(identical(dimnames(ca), dimnames(cb)) && meme_num(as.vector(ca), as.vector(cb)))
  }
  if (!identical(names(a), names(b))) return(FALSE)
  all(vapply(names(b), function(ch) {
    if (is.character(b[[ch]]) || is.character(a[[ch]])) identical(a[[ch]], b[[ch]]) else meme_num(a[[ch]], b[[ch]])
  }, logical(1)))
}
confronter_p2 <- function(x, y, z, pi) proteger({
  args <- list(BP79 = list(z^2, x), BP = list(z^2, x), White = list(z^2, x), BF = list(z, x), RESET = list(x, y), Pond = list(x, y, pi))
  names(PAIRES_P2)[!vapply(names(PAIRES_P2), function(nm)
    isTRUE(concorde(nm, evaluer_p2(PAIRES_P2[[nm]]$f, args[[nm]]), evaluer_p2(PAIRES_P2[[nm]]$g, args[[nm]]))), logical(1))]
})

# Rejeu du bootstrap de V1 (structure de usp_bootstrap() : memes appels,
# meme ordre, meme graine). cat_ : catalogue evalue a chaque tirage
# (retention : reajustement rapide et statistiques sans erreur). complet :
# usp_ajuster_contraint() et grandeurs de usp_bootstrap() (controle (i2)),
# omis sinon (P3, aucun alea consomme). h1 : comparaison des six fonctions
# de P2 a chaque tirage reajuste (protegee).
rejouer_v1 <- function(fit, graine, cat_ = USP_CATALOGUE_MC, complet = FALSE, h1 = FALSE) {
  e_obs <- .usp_contexte_mc(fit$x, fit$y, fit$z, fit$pi)
  B <- B_BOOT; nm <- names(cat_)
  sim <- matrix(NA_real_, B, length(nm), dimnames = list(NULL, nm))
  d <- rep(NA_real_, B); ech <- c(rapide = 0L, stats = 0L); ko_h1 <- character(0); n_h1 <- 0L
  sig <- del <- gam <- sig_r <- rep(NA_real_, B); n_echec_r <- 0L; zb <- matrix(NA_real_, B, length(fit$x))
  engine_sous_graine(graine, {
    stats_obs <- .mc_evaluer(cat_, e_obs)
    for (b in seq_len(B)) {
      yb <- usp_simuler(fit)
      f <- try(usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
      if (inherits(f, "try-error")) { ech[["rapide"]] <- ech[["rapide"]] + 1L; next }
      if (h1) { ko_h1 <- c(ko_h1, confronter_p2(fit$x, yb, f$z, f$pi)); n_h1 <- n_h1 + 1L }
      sb <- try(.mc_evaluer(cat_, .usp_contexte_mc(fit$x, yb, f$z, f$pi)), silent = TRUE)
      if (inherits(sb, "try-error")) { ech[["stats"]] <- ech[["stats"]] + 1L; next }
      sim[b, ] <- sb[nm]; d[b] <- f$delta
      if (complet) {
        zb[b, ] <- f$z; sig[b] <- f$sigma
        if (!is.null(f$delta)) { del[b] <- f$delta; gam[b] <- f$gamma }
        fr <- try(usp_ajuster_contraint(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
        if (inherits(fr, "try-error")) n_echec_r <- n_echec_r + 1L else sig_r[b] <- fr$sigma
      }
    }
  })
  ok <- is.finite(d)
  list(e_obs = e_obs, stats_obs = stats_obs, sim = sim, delta = d, ok = ok, ech = ech, ko_h1 = ko_h1, n_h1 = n_h1,
       boot = if (complet) list(sigma_boot = sig[is.finite(sig)], delta_boot = del[is.finite(del)], gamma_boot = gam[is.finite(gam)],
                                sigma_boot_restreint = sig_r[is.finite(sig_r)], n_echec_restreint = n_echec_r, z_boot = zb))
}
# Completion de V3b (par. 5) : S_A, statistiques des tirages de V1 retenus
# dans le regime r_b ; flux sous graine ; p1 = TRUE : levier P1 (aucune
# statistique hors regime) ; p1 = FALSE : statistiques a chaque tirage
# reajuste (controle (s1)).
completer_v3b <- function(fit, r_b, S_A, graine, cat_ = USP_CATALOGUE_MC, p1 = TRUE, h1 = FALSE) {
  nm <- names(cat_)
  S <- matrix(NA_real_, B_CIBLE, length(nm), dimnames = list(NULL, nm))
  nA0 <- nrow(S_A); nA <- nA0
  if (nA) S[seq_len(nA), ] <- S_A[, nm]
  tir <- B_BOOT; cpt <- c(rapide = 0L, hors = 0L, stats = 0L); ko_h1 <- character(0); n_h1 <- 0L
  if (nA < B_CIBLE) engine_sous_graine(graine, {
    while (nA < B_CIBLE && tir < B_MAX) {
      tir <- tir + 1L
      yb <- usp_simuler(fit)
      f <- try(usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
      if (inherits(f, "try-error")) { cpt[["rapide"]] <- cpt[["rapide"]] + 1L; next }
      if (!p1) sb <- try(.mc_evaluer(cat_, .usp_contexte_mc(fit$x, yb, f$z, f$pi)), silent = TRUE)
      if (code_regime(f$delta) != r_b) { cpt[["hors"]] <- cpt[["hors"]] + 1L; next }
      if (h1) { ko_h1 <- c(ko_h1, confronter_p2(fit$x, yb, f$z, f$pi)); n_h1 <- n_h1 + 1L }
      if (p1) sb <- try(.mc_evaluer(cat_, .usp_contexte_mc(fit$x, yb, f$z, f$pi)), silent = TRUE)
      if (inherits(sb, "try-error")) { cpt[["stats"]] <- cpt[["stats"]] + 1L; next }
      nA <- nA + 1L
      S[nA, ] <- sb[nm]
    }
  })
  list(S = S[seq_len(nA), , drop = FALSE], nA0 = nA0, nA = nA, tir = tir, cpt = cpt,
       arret = if (nA == B_CIBLE) "cible" else "B_max", ko_h1 = ko_h1, n_h1 = n_h1)
}
# Nombre de quasi-egalites (h2) par statistique de P2.
compter_h2 <- function(S, stats_obs) vapply(STATS_P2, function(s) {
  o <- stats_obs[[s]]
  if (!is.finite(o)) return(0)
  v <- S[, s]; sum(is.finite(v) & abs(v - o) <= TOL_H2 * max(1, abs(o)))
}, 1)
# Liste "bootstrap" d'une variante pour usp_tests() (champs lus par
# engine_registre_tests()).
boot_variante <- function(stats_obs, mc) list(stats_obs = as.list(stats_obs), p_mc = mc$p_mc, err_mc = mc$err_mc,
                                              B_effectif = mc$B_effectif, granularite = 1 / (B_BOOT + 1), B = B_BOOT,
                                              granularite_stat = mc$granularite, motif_mc = mc$motif_mc)
codes_t2 <- function(tests) {
  nm <- vapply(tests, `[[`, "", "test"); k <- match(LIGNES_T2, nm)
  list(v = paste(vapply(k, function(i) if (is.na(i)) "-" else code_verdict(tests[[i]]$verdict), ""), collapse = ""),
       n = paste(vapply(k, function(i) if (is.na(i)) "-" else code_nature(tests[[i]]$nature_p), ""), collapse = ""),
       p = vapply(k, function(i) if (is.na(i)) NA_real_ else tests[[i]]$p_retenue, 1))
}
# Traitement d'une replication (ou du jeu observe, b = 0). ctl : complet
# ((i2) et (s1)), h1 ; t2 : verdicts des lignes. Rend les champs de la
# ligne REP et les elements des controles.
traiter <- function(x, y, b, ctl = list(complet = FALSE, h1 = FALSE), t2 = TRUE) {
  t0 <- Sys.time()
  fit <- tryCatch(usp_ajuster(x, y), error = function(e) e)
  va <- if (inherits(fit, "error")) list(ok = FALSE) else usp_valider_ajustement(fit, METHODE)
  if (!isTRUE(va$ok))
    return(list(statut = "ecartee", regime = "ecartee", delta = if (inherits(fit, "error")) NA_real_ else fit$delta,
                gamma = if (inherits(fit, "error")) NA_real_ else fit$gamma, duree = as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  r_b <- code_regime(fit$delta)
  g_boot <- GRAINE_BOOT + b; g_v3b <- GRAINE_V3B + b
  rv <- rejouer_v1(fit, g_boot, h1 = isTRUE(ctl$h1))
  e_obs <- rv$e_obs
  mc1 <- .mc_p_values(rv$sim, rv$stats_obs, USP_CATALOGUE_MC, e_obs)
  rd <- vapply(rv$delta, function(d) if (is.finite(d)) code_regime(d) else NA_character_, "")
  A <- rv$ok & !is.na(rd) & rd == r_b
  mc3a <- .mc_p_values(rv$sim[A, , drop = FALSE], rv$stats_obs, USP_CATALOGUE_MC, e_obs)
  v3 <- completer_v3b(fit, r_b, rv$sim[A, , drop = FALSE], g_v3b, h1 = isTRUE(ctl$h1))
  mc3b <- .mc_p_values(v3$S, rv$stats_obs, USP_CATALOGUE_MC, e_obs)
  out <- list(statut = "traitee", regime = r_b, delta = fit$delta, gamma = fit$gamma, fit = fit, rv = rv, A = A, v3 = v3,
              mc = list(V1 = mc1, V3a = mc3a, V3b = mc3b),
              dd = c(bord0 = sum(rd[rv$ok] == "bord0"), interieur = sum(rd[rv$ok] == "interieur"), bord1 = sum(rd[rv$ok] == "bord1")))
  # h2 (ligne REP, T3) : tirages de V1 retenus et ajouts de V3b ; h2_v1 :
  # tirages de V1 seuls, cause (h2) d'une discordance (i1) (V1 n'utilise
  # aucun ajout de V3b).
  out$h2_v1 <- compter_h2(rv$sim[rv$ok, , drop = FALSE], rv$stats_obs)
  out$h2 <- out$h2_v1 + compter_h2(v3$S[seq_len(v3$nA) > v3$nA0, , drop = FALSE], rv$stats_obs)
  if (isTRUE(ctl$h1)) out$h1 <- list(ko = c(rv$ko_h1, v3$ko_h1, confronter_p2(x, y, fit$z, fit$pi)), n = rv$n_h1 + v3$n_h1 + 1L)
  if (isTRUE(ctl$complet)) {
    rc <- rejouer_v1(fit, g_boot, complet = TRUE)
    ub <- usp_bootstrap(fit, B = B_BOOT, seed = g_boot)
    mcc <- .mc_p_values(rc$sim, rc$stats_obs, USP_CATALOGUE_MC, e_obs)
    ch <- c(P3_sim = identical(rc$sim, rv$sim), P3_delta = identical(rc$delta, rv$delta),
            stats_obs = identical(as.list(rc$stats_obs), ub$stats_obs), p_mc = identical(mcc$p_mc, ub$p_mc),
            p_mc_V1 = identical(mc1$p_mc, ub$p_mc), err_mc = identical(mcc$err_mc, ub$err_mc),
            B_effectif = identical(mcc$B_effectif, ub$B_effectif), granularite_stat = identical(mcc$granularite, ub$granularite_stat),
            motif_mc = identical(mcc$motif_mc, ub$motif_mc),
            vapply(c("sigma_boot", "delta_boot", "gamma_boot", "sigma_boot_restreint", "n_echec_restreint", "z_boot"),
                   function(k) identical(rc$boot[[k]], ub[[k]]), logical(1)))
    out$i2 <- names(ch)[!ch]
    v3s <- completer_v3b(fit, r_b, rv$sim[A, , drop = FALSE], g_v3b, p1 = FALSE)
    mc3s <- .mc_p_values(v3s$S, rv$stats_obs, USP_CATALOGUE_MC, e_obs)
    out$s1 <- identical(mc3s$p_mc, mc3b$p_mc) && identical(v3s$tir, v3$tir) && identical(mc3s$B_effectif, mc3b$B_effectif) &&
      identical(v3s$nA, v3$nA)
  }
  if (t2) {
    perm <- if (!usp_volumes_constants(x) && !usp_pertes_constantes(y))
      usp_permutation_pente(x, y, B = B_BOOT, seed = g_boot, unilateral = .pitman_unilateral()) else NULL
    # une erreur de usp_tests() remonte (variante citee) : la replication
    # prend le statut "erreur" (tryCatch de la boucle des replications)
    out$t2 <- lapply(stats::setNames(nm = names(out$mc)), function(v)
      codes_t2(tryCatch(usp_tests(fit, boot_variante(rv$stats_obs, out$mc[[v]]), ALPHA, theta_equiv = THETA_EQUIV,
                                  methode = METHODE, lr_delta = NULL, permutation_pente = perm),
                        error = function(e) stop(sprintf("usp_tests() (%s) : %s", v, conditionMessage(e)), call. = FALSE))))
  }
  out$duree <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  out
}
# Champs de la ligne REP / OBS.
champs_rep <- function(b, r, i1 = "-", t2 = "-", v3a = "-", discord = character(0)) {
  f17 <- function(v) ifelse(is.finite(v), sprintf("%.17g", v), "NA")
  if (r$statut == "ecartee")
    return(unname(c(b, "ecartee", "ecartee", f17(r$delta), f17(r$gamma), rep("NA", 11), "-", "-", "-", "-", rep("-", 6),
                    rep("NA", length(STATS_P2)), sprintf("%.3f", r$duree), "-",
                    rep(c(rep("NA", 6), rep("-", 3)), NS))))
  # replication en erreur : regime de delta*_b s'il est connu ("-" sinon),
  # message dans la colonne discordances, sans tabulation ni saut de ligne
  if (r$statut == "erreur")
    return(unname(c(b, "erreur", r$regime, "NA", "NA", rep("NA", 11), "-", "-", "-", "-", rep("-", 6),
                    rep("NA", length(STATS_P2)), sprintf("%.3f", r$duree),
                    nettoyer_champ(sprintf("erreur : %s", if (nzchar(r$message)) r$message else "(message vide)")),
                    rep(c(rep("NA", 6), rep("-", 3)), NS))))
  m <- r$mc
  verd <- if (is.null(r$t2)) rep("-", 3) else vapply(r$t2, `[[`, "", "v")
  nat <- if (is.null(r$t2)) rep("-", 3) else vapply(r$t2, `[[`, "", "n")
  fx <- c(b, "traitee", r$regime, f17(r$delta), f17(r$gamma), sprintf("%.0f", r$dd[c("bord0", "interieur", "bord1")]),
          sprintf("%.0f", r$rv$ech[c("rapide", "stats")]), sprintf("%.0f", sum(r$A)), sprintf("%.0f", r$v3$tir),
          sprintf("%.0f", r$v3$nA), sprintf("%.0f", r$v3$cpt[c("rapide", "hors", "stats")]), r$v3$arret,
          i1, t2, v3a, verd, nat, sprintf("%.0f", r$h2), sprintf("%.3f", r$duree),
          if (length(discord)) nettoyer_champ(paste(discord, collapse = " ; ")) else "-")
  st <- unlist(lapply(STATS, function(s) c(vapply(m, function(x) f17(x$p_mc[[s]]), ""), vapply(m, function(x) sprintf("%.0f", x$B_effectif[[s]]), ""),
                                           vapply(m, function(x) code_motif(x$motif_mc[[s]]), ""))))
  # sans noms (verdicts et natures nommes par variante) : ligne comparee par
  # identical() a une ligne relue (--reprendre)
  unname(c(fx, st))
}

###############################################################################
#  EXECUTION (tranche ou --debit)
###############################################################################
COMMIT <- commit_depot(SCRIPT)
EMPREINTES <- empreintes_code(SCRIPT, c(SCRIPT_72, SPEC))
EMPREINTE_SC <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
MD5_MOTEUR <- md5_fichier(file.path(RACINE, "R", "engine.R"))
INTEGRITE <- character(0)
CONTROLES <- character(0)
controle <- function(ok, libelle) {
  ok <- isTRUE(ok)
  if (!ok) INTEGRITE <<- c(INTEGRITE, libelle)
  CONTROLES <<- c(CONTROLES, sprintf("%s : %s", libelle, if (ok) "OK" else "\u00c9CHEC"))
  invisible(ok)
}
liste_b <- function(v) if (length(v)) paste0(" : ", paste(utils::head(unique(v), 20), collapse = ", "),
                                              if (length(unique(v)) > 20) ", ..." else "") else ""
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
fit_synth <- function(beta, x, delta, gamma)
  list(beta = beta, x = x, pi = usp_pi(delta, gamma, x, mean(x)), T = length(x), delta = delta, gamma = gamma, xbar = mean(x))
J2_DONNEES <- lire_j2()
FIT_J2 <- usp_ajuster(J2_DONNEES$x, J2_DONNEES$y)
GROUPE <- if (OPT_DEBIT) "J2" else if (!is.na(OPT_JEU)) OPT_JEU else OPT_SCEN
PARTIE <- if (!is.na(OPT_SCEN)) "puissance" else "regime"

# --- --debit (levier P4) : trois replications de J2 du regime demande ------------
if (OPT_DEBIT) {
  RES_DEB <- executer_cas("premium")
  LIGNES_T2 <- local({ l <- vapply(RES_DEB$tests, `[[`, "", "test"); l[!hors_t2(l)] })
  OPT_GRAINE <- GRAINE_JEUX; OPT_R <- R_SPEC
  YD <- engine_sous_graine(OPT_GRAINE, t(vapply(seq_len(OPT_R), function(b) usp_simuler(FIT_J2), numeric(T_))))
  choisis <- integer(0)
  for (b in seq_len(OPT_R)) {
    f <- tryCatch(usp_ajuster(FIT_J2$x, YD[b, ]), error = function(e) NULL)
    if (!is.null(f) && isTRUE(usp_valider_ajustement(f, METHODE)$ok) && code_regime(f$delta) == OPT_REGIME_DEBIT) choisis <- c(choisis, b)
    if (length(choisis) == 3L) break
  }
  ecrire_console(c(sprintf("## D\u00e9bit (levier P4) : J2, r\u00e9gime %s, r\u00e9plications %s", OPT_REGIME_DEBIT, paste(choisis, collapse = ", ")), "",
                   sprintf("Commit : %s ; plateforme : %s ; d\u00e9but %s UTC", COMMIT, plateforme_calcul(), format(Sys.time(), "%Y-%m-%dT%H:%M:%S", tz = "UTC")), ""))
  dd <- numeric(0)
  for (b in choisis) {
    r <- traiter(FIT_J2$x, YD[b, ], b)
    dd <- c(dd, r$duree)
    ecrire_console(sprintf("DEBIT\t%d\t%s\t%.3f\ttirages_v3b=%.0f\tretenus_v3b=%.0f", b, r$regime, r$duree, r$v3$tir, r$v3$nA))
  }
  ecrire_console(sprintf("DEBIT_MOYEN\t%s\t%.3f\t%d", OPT_REGIME_DEBIT, mean(dd), length(dd)))
  quit(status = 0L)
}

# --- --prevol : pre-vol des erreurs par replication, sans bootstrap ---------------
# Sur les R jeux simules du jeu (suite YSIM, graine des jeux), sans rien
# ecrire : usp_ajuster(), usp_valider_ajustement(), usp_permutation_pente()
# (graine 20260831 + b, comme la mesure), usp_tests() avec (1) une liste
# bootstrap factice (statistiques observees du catalogue, p de V1 reduites
# a des valeurs valides) et (2) toutes les p absentes (cas R3).
if (OPT_PREVOL) {
  FIT0 <- switch(GROUPE, J1 = usp_ajuster(.ln$xt, .ln$yt), J2 = FIT_J2, J3 = fit_synth(BETA3, X3, DELTA3, GAMMA3))
  X <- FIT0$x
  Y <- engine_sous_graine(GRAINE_JEUX, t(vapply(seq_len(OPT_R), function(b) usp_simuler(FIT0), numeric(T_))))
  # p de V1 : valeurs brutes de #221 du jeu (J3 : celles de J2, meme b)
  src_p <- if (GROUPE %in% c("J1", "J2")) GROUPE else "J2"
  fb <- F_BRUT221[[src_p]]
  if (is.na(fb) || !file.exists(fb)) stop("--prevol : valeurs brutes de #221 introuvables pour ", src_p)
  M <- lire_tsv(fb)
  P221 <- matrix(suppressWarnings(as.numeric(M[, paste0("p_mc:", STATS)])), nrow(M), NS, dimnames = list(NULL, STATS))
  K_SENS <- ifelse(QUEUE == "deux", 2, 1)
  # Liste bootstrap factice (champs lus par engine_registre_tests(), comme
  # boot_variante()).
  boot_factice <- function(stats_obs, p, absentes) {
    obs_fin <- vapply(STATS, function(s) is.finite(stats_obs[[s]]), logical(1))
    if (absentes) {
      Be <- rep(B_MIN_DEGENERESCENCE - 1, NS)
      pv <- rep(NA_real_, NS)
      mo <- ifelse(obs_fin, MOTIF_MC_REPLIC_INSUFFISANTES, MOTIF_MC_OBS_NON_FINIE)
    } else {
      Be <- rep(B_BOOT, NS)
      pv <- ifelse(is.finite(p), pmin(pmax(p, K_SENS / (B_BOOT + 1)), 1), 0.5)
      pv[!obs_fin] <- NA_real_
      mo <- ifelse(obs_fin, NA_character_, MOTIF_MC_OBS_NON_FINIE)
    }
    mc <- list(p_mc = stats::setNames(pv, STATS), err_mc = stats::setNames(sqrt(pv * (K_SENS - pv) / Be), STATS),
               B_effectif = stats::setNames(Be, STATS), granularite = stats::setNames(K_SENS / (Be + 1), STATS),
               motif_mc = stats::setNames(mo, STATS))
    boot_variante(stats_obs, mc)
  }
  FONCTIONS_PV <- c("usp_ajuster", "usp_valider_ajustement", ".mc_evaluer (statistiques observees)", "usp_permutation_pente",
                    "usp_tests (p de V1 valides)", "usp_tests (p absentes, R3)")
  ERR_PV <- stats::setNames(vector("list", length(FONCTIONS_PV)), FONCTIONS_PV)
  noter <- function(f, b, e) ERR_PV[[f]] <<- c(ERR_PV[[f]], sprintf("%d (%s)", b, nettoyer_champ(conditionMessage(e))))
  essayer <- function(f, b, expr) tryCatch(expr, error = function(e) { noter(f, b, e); NULL })
  t_pv <- Sys.time(); n_val <- 0L; reg_pv <- character(0)
  for (b in seq_len(OPT_R)) {
    y <- Y[b, ]
    fit <- essayer(FONCTIONS_PV[1], b, usp_ajuster(X, y))
    if (is.null(fit)) next
    va <- essayer(FONCTIONS_PV[2], b, usp_valider_ajustement(fit, METHODE))
    if (!isTRUE(va$ok)) next
    n_val <- n_val + 1L; reg_pv <- c(reg_pv, code_regime(fit$delta))
    so <- essayer(FONCTIONS_PV[3], b, .mc_evaluer(USP_CATALOGUE_MC, .usp_contexte_mc(fit$x, fit$y, fit$z, fit$pi)))
    perm <- if (!usp_volumes_constants(X) && !usp_pertes_constantes(y))
      essayer(FONCTIONS_PV[4], b, usp_permutation_pente(X, y, B = B_BOOT, seed = GRAINE_BOOT + b, unilateral = .pitman_unilateral())) else NULL
    if (is.null(so)) next
    for (k in 1:2) essayer(FONCTIONS_PV[4 + k], b,
                           usp_tests(fit, boot_factice(so, P221[b, ], absentes = k == 2L), ALPHA, theta_equiv = THETA_EQUIV,
                                     methode = METHODE, lr_delta = NULL, permutation_pente = perm))
  }
  d_pv <- as.numeric(difftime(Sys.time(), t_pv, units = "secs"))
  n_err_pv <- vapply(ERR_PV, length, 1L)
  ecrire_console(c(sprintf("## Pré-vol (--prevol) : %s, R = %d (sans bootstrap, rien d'écrit)", GROUPE, OPT_R), "",
                   sprintf("Commit : %s ; plateforme : %s ; p de V1 : valeurs brutes de #221 de %s (%s, md5 %s)%s", COMMIT,
                           plateforme_calcul(), src_p, chemin_cite(fb), md5_fichier(fb), if (GROUPE == "J3") ", au même b (J3 n'a pas de valeurs brutes de #221)" else ""),
                   sprintf("Réplications validées : %d sur %d (régimes : %s) ; durée %.1f s (%.4f s par réplication)", n_val, OPT_R,
                           paste(sprintf("%s %d", REG, vapply(REG, function(r) sum(reg_pv == r), 1L)), collapse = ", "), d_pv, d_pv / OPT_R), "",
                   entete_md(c("Fonction", "erreurs", "réplications (b, message)")),
                   vapply(FONCTIONS_PV, function(f) ligne_md(f, n_err_pv[[f]], liste_cel(ERR_PV[[f]], 20)), ""), "",
                   sprintf("Bilan : %s", if (sum(n_err_pv)) sprintf("%d erreur(s)", sum(n_err_pv)) else "aucune erreur")))
  quit(status = if (sum(n_err_pv)) 1L else 0L)
}

# --- Controles generaux --------------------------------------------------------
# (b) catalogue et familles
controle(NS == 34L && all(F_T %in% STATS) && length(F_R) == 22L && !length(intersect(F_T, F_R)) &&
           setequal(union(F_T, F_R), STATS) && all(F_8 %in% F_R) && all(unlist(CIBLES) %in% F_R) && all(STATS_P2 %in% STATS),
         sprintf("(b) %d statistiques au catalogue USP_CATALOGUE_MC (sens lus au catalogue) ; F_T (%d) et F_R (%d) en partition ; F_8 et ensembles cibles dans F_R",
                 NS, length(F_T), length(F_R)))
# (t) textes de la specification
TXT_SPEC <- if (file.exists(file.path(RACINE, SPEC))) enc2utf8(readLines(file.path(RACINE, SPEC), warn = FALSE, encoding = "UTF-8")) else character(0)
present_bloc <- function(bloc) {
  i <- which(TXT_SPEC == bloc[1])
  any(vapply(i, function(k) k + length(bloc) - 1L <= length(TXT_SPEC) && identical(TXT_SPEC[k:(k + length(bloc) - 1L)], bloc), logical(1)))
}
controle(present_bloc(TEXTE_CRITERE_229) && all(TITRES_ANNOTATIONS %in% TXT_SPEC),
         sprintf("(t) texte du crit\u00e8re (par. 2.1-2.2, %d lignes) identique \u00e0 %s (md5 %s) ; titres des annotations du 09/10/2026 (A1 ; L0 \u00e0 L14) et du 10/10/2026 (A2 et L15 ; points ouverts du script, L16 \u00e0 L20) pr\u00e9sents (%d titres)",
                 length(TEXTE_CRITERE_229), SPEC, md5_fichier(file.path(RACINE, SPEC)), length(TITRES_ANNOTATIONS)))
# (graines)
GRAINES <- rbind(
  data.frame(flux = "jeux de J1, J2, J3", graine = GRAINE_JEUX),
  data.frame(flux = sprintf("bootstrap, r\u00e9plication %d", 0:2000), graine = GRAINE_BOOT + 0:2000),
  data.frame(flux = sprintf("flux de V3b, r\u00e9plication %d", 0:2000), graine = GRAINE_V3B + 0:2000),
  data.frame(flux = sprintf("sc\u00e9nario %d de P", 1:9), graine = GRAINE_P + 1:9),
  data.frame(flux = sprintf("grille, profil %d, n\u0153ud %d", rep(1:3, each = 12), rep(1:12, 3)),
             graine = GRAINE_GRILLE + 100 * rep(1:3, each = 12) + rep(1:12, 3)),
  data.frame(flux = "SEED_LOI_NULLE_SW", graine = SEED_LOI_NULLE_SW))
COLLISIONS <- local({ d <- GRAINES$graine[duplicated(GRAINES$graine)]; lapply(unique(d), function(v) GRAINES$flux[GRAINES$graine == v]) })
DECLAREES <- list(c("jeux de J1, J2, J3", "bootstrap, r\u00e9plication 96"), c("bootstrap, r\u00e9plication 70", "SEED_LOI_NULLE_SW"))
non_decl <- Filter(function(cl) !any(vapply(DECLAREES, function(d) setequal(d, cl), logical(1))), COLLISIONS)
TXT_COLL <- paste(vapply(COLLISIONS, paste, "", collapse = " = "), collapse = " ; ")
controle(!length(non_decl), sprintf("(graines) %d graines (jeux, bootstrap 0..2000, flux de V3b 0..2000, sc\u00e9narios 1..9, grille, SEED_LOI_NULLE_SW) : collisions d\u00e9clar\u00e9es (h\u00e9rit\u00e9es de #166) : %s ; non d\u00e9clar\u00e9es : %s",
                                    nrow(GRAINES), TXT_COLL, if (length(non_decl)) paste(vapply(non_decl, paste, "", collapse = " = "), collapse = " ; ") else "aucune"))
# Grille : (i3) et sources
F_GRILLE <- if (!is.na(OPT_GRILLE)) OPT_GRILLE else derniere("^[0-9]{8}-issue229-grille\\.md$")
GRILLE <- lire_grille(F_GRILLE)
charger_pred_c5(F_GRILLE)
TXT_GRILLE <- sprintf("%s (md5 %s, suivi par git : %s ; param\u00e8tres de la sp\u00e9cification : %s)", chemin_cite(F_GRILLE), md5_fichier(F_GRILLE),
                      suivi_git(F_GRILLE), if (GRILLE$param_spec) "oui" else "non")
md5_t0_221 <- local({
  f <- F_TAB221[["J2"]]
  if (is.na(f) || !file.exists(f)) return("illisible")
  l <- enc2utf8(readLines(f, warn = FALSE, encoding = "UTF-8")); e <- l[startsWith(l, "| Empreintes md5 du code ex\u00e9cut\u00e9 |")]
  m <- if (length(e) == 1L) regmatches(e, regexec("R/engine\\.R ([0-9a-f]{32})", e))[[1]] else character(0)
  if (length(m) == 2L) m[2] else "illisible"
})
TXT_I3 <- sprintf("%s : empreinte sans commentaires de R/engine.R %s, (g5) de la grille %s ; md5 du fichier entier %s ; md5 du moteur du T0 de #221 (pour m\u00e9moire, lien par (i1) et (c)) %s",
                  if (isTRUE(GRILLE$ok && GRILLE$g5 == EMPREINTE_SC && GRILLE$param_spec)) "OK" else "\u00c9CHEC", EMPREINTE_SC, GRILLE$g5, MD5_MOTEUR, md5_t0_221)
controle(GRILLE$ok && identical(GRILLE$g5, EMPREINTE_SC) && GRILLE$param_spec,
         sprintf("(i3) %s ; tableau de la grille %s", TXT_I3, TXT_GRILLE))
# (a) J1 observe contre la reference premium ; lignes de T2
RES_A <- executer_cas("premium")
cmp_a <- comparer_objets(neutraliser_instables(readRDS(chemin_reference("premium"))), neutraliser_instables(RES_A), tol = TOLERANCE)
TXT_A <- sprintf("%s ; %d feuille(s), %d non strictement identique(s), \u00e9cart maximal %s", if (cmp_a$conforme) "conforme" else "NON CONFORME",
                 cmp_a$n_feuilles, cmp_a$n_differentes, formatC(cmp_a$ecart_max, format = "e", digits = 3))
controle(cmp_a$conforme && identical(unlist(RES_A$metadata[c("B", "alpha", "seed", "theta_equiv")]),
                                     c(B = as.numeric(B_BOOT), alpha = ALPHA, seed = GRAINE_BOOT, theta_equiv = THETA_EQUIV)),
         sprintf("(a) J1 observ\u00e9, run_engine(seed = %.0f), conforme \u00e0 tests/reference/premium.rds (comparer_objets(), tol\u00e9rance %g) et configuration (B, \u03b1, graine, theta_equiv) = celle du script : %s%s",
                 GRAINE_BOOT, TOLERANCE, TXT_A, if (cmp_a$conforme) "" else paste0(" : ", paste(resumer_comparaison(cmp_a, 5L), collapse = " ; "))))
LIGNES_51 <- vapply(RES_A$tests, `[[`, "", "test")
LIGNES_T2 <- LIGNES_51[!hors_t2(LIGNES_51)]
controle(length(LIGNES_51) == 51L && !anyDuplicated(LIGNES_51) && length(LIGNES_T2) == 48L,
         sprintf("(b) %d lignes de usp_tests() sur J1 observ\u00e9, libell\u00e9s distincts ; %d lignes au p\u00e9rim\u00e8tre de T2 (hors rapport de vraisemblance sur \u03b4 et largeur de l'IC \u00e0 \u03b4 fixe, #45)",
                 length(LIGNES_51), length(LIGNES_T2)))
REGLE_R4 <- sprintf("SEUIL_PUISSANCE_PENTE = %s, SENS_PITMAN_PENTE = %s : ligne du test de Pitman sur la pente restitu\u00e9e en diagnostic si la puissance approch\u00e9e du test unilat\u00e9ral sous le mod\u00e8le ajust\u00e9 (usp_identifiabilite_pente()) est inf\u00e9rieure au seuil",
                    format(SEUIL_PUISSANCE_PENTE), SENS_PITMAN_PENTE)

# --- Jeux de la tranche ----------------------------------------------------------
if (is.na(OPT_TRANCHE)) { DEBUT <- 1L; FIN <- if (PARTIE == "regime") OPT_R else OPT_RP } else {
  m <- regmatches(OPT_TRANCHE, regexec("^([0-9]+)/([0-9]+)$", OPT_TRANCHE))[[1]]
  if (length(m) != 3L) stop("--tranche : forme i/K attendue")
  Rn <- if (PARTIE == "regime") OPT_R else OPT_RP
  i <- as.integer(m[2]); K <- as.integer(m[3])
  if (K < 1L || i < 1L || i > K || K > Rn) stop("--tranche : 1 <= i <= K <= R")
  DEBUT <- as.integer(floor((i - 1) * Rn / K)) + 1L; FIN <- as.integer(floor(i * Rn / K))
}
SOURCES <- character(0); TXT_L8 <- "sans objet"; X <- NULL; Y <- NULL; REG_REF <- NULL; BRUT221 <- NULL; B175 <- NULL
if (PARTIE == "regime") {
  FIT0 <- switch(GROUPE, J1 = usp_ajuster(.ln$xt, .ln$yt), J2 = FIT_J2, J3 = fit_synth(BETA3, X3, DELTA3, GAMMA3))
  LIB_JEU <- switch(GROUPE, J1 = "J1 : tests/donnees/donnees_ln.csv", J2 = "J2 : xi, yi de tests/unitaires/test_controles_numeriques.R",
                    J3 = sprintf("J3 : FIT0_J3 synth\u00e9tique, x3 = (%s), \u03b40 = %s, \u03b20 = %s, \u03b30 = ln(\u03c30 / \u03b20) = %.6f (\u03c30 = %s), aucun jeu observ\u00e9",
                                 paste(format(X3), collapse = " ; "), format(DELTA3), format(BETA3), GAMMA3, format(SIGMA3)))
  X <- FIT0$x
  OPT_GRAINE <- GRAINE_JEUX
  Y <- engine_sous_graine(OPT_GRAINE, t(vapply(seq_len(OPT_R), function(b) usp_simuler(FIT0), numeric(T_))))
  ysim_72 <- tryCatch({
    ex <- as.list(parse(file.path(RACINE, SCRIPT_72), keep.source = FALSE))
    cible <- Filter(function(e) is.call(e) && identical(e[[1]], as.name("<-")) && identical(e[[2]], as.name("YSIM")), ex)
    if (length(cible) != 1L) stop(length(cible), " affectation(s) de YSIM au niveau superieur (une attendue)")
    rhs <- cible[[1]][[3]]
    hors <- setdiff(all.names(rhs), NOMS_E2)
    if (length(hors)) stop("nom(s) hors de la liste blanche NOMS_E2 : ", paste(hors, collapse = ", "))
    env <- new.env(parent = emptyenv())
    liaisons <- list(engine_sous_graine = engine_sous_graine, usp_simuler = usp_simuler, t = base::t, vapply = base::vapply,
                     seq_len = base::seq_len, numeric = base::numeric, "function" = base::`function`, "{" = base::`{`,
                     "(" = base::`(`, OPT_GRAINE = GRAINE_JEUX, OPT_R = OPT_R, FIT0 = FIT0, T_ = T_)
    stopifnot(setequal(names(liaisons), NOMS_E2))
    for (nm in names(liaisons)) assign(nm, liaisons[[nm]], envir = env)
    eval(rhs, env)
  }, error = function(e) e)
  controle(!inherits(ysim_72, "error") && identical(ysim_72, Y),
           sprintf("(c) %d jeux simul\u00e9s de %s identiques \u00e0 ceux de l'expression YSIM de %s (noms en liste blanche, environnement isol\u00e9)%s",
                   OPT_R, GROUPE, SCRIPT_72, if (inherits(ysim_72, "error")) paste0(" (", conditionMessage(ysim_72), ")") else ""))
  if (GROUPE %in% c("J1", "J2")) {
    fb <- F_BRUT221[[GROUPE]]
    if (is.na(fb) || !file.exists(fb)) stop("valeurs brutes de #221 introuvables pour ", GROUPE)
    M <- lire_tsv(fb)
    if (!identical(as.integer(M[, "b"]), seq_len(nrow(M)))) stop("valeurs brutes de #221 : b different de 1..R : ", fb)
    BRUT221 <- list(regime = unname(M[, "regime"]),
                    p = matrix(suppressWarnings(as.numeric(M[, paste0("p_mc:", STATS)])), nrow(M), NS, dimnames = list(NULL, STATS)),
                    pr = M[, paste0("p_retenue:", LIGNES_T2), drop = FALSE])
    REG_REF <- BRUT221$regime
    controle(all(paste0("p_retenue:", LIGNES_T2) %in% colnames(M)) && ncol(M) == 2L + NS + 51L,
             sprintf("(t2) les %d lignes du p\u00e9rim\u00e8tre de T2 figurent dans les valeurs brutes de #221 (colonnes p_retenue:<ligne>)", length(LIGNES_T2)))
    M175 <- lire_tsv(F_BRUT175)
    B175 <- M175[M175[, "jeu"] == GROUPE, , drop = FALSE]
    SOURCES <- c(fb, F_TAB221[[GROUPE]], F_BRUT175)
  } else {
    if (is.na(OPT_GRILLE_BRUT) || !file.exists(OPT_GRILLE_BRUT)) stop("J3 : --grille-brut FICHIER obligatoire (controle (c-J3))")
    M <- lire_tsv(OPT_GRILLE_BRUT)
    k <- M[, "couche"] == "verite" & M[, "jeu"] == "J3"
    REG_REF <- unname(M[k, "regime"][order(as.integer(M[k, "b"]))])
    controle(identical(md5_fichier(OPT_GRILLE_BRUT), GRILLE$brut_md5) && length(REG_REF) >= OPT_R,
             sprintf("(c-J3) valeurs brutes de la grille %s : md5 %s, \u00e9gal \u00e0 celui du T0 du tableau de la grille (%s) ; %d r\u00e9plications de J3 (couche v\u00e9rit\u00e9)",
                     chemin_cite(OPT_GRILLE_BRUT), md5_fichier(OPT_GRILLE_BRUT), GRILLE$brut_md5, length(REG_REF)))
    SOURCES <- c(F_TAB221[["J2"]])
  }
} else {
  sc <- SCENARIOS[SCENARIOS$code == GROUPE, ]
  LIB_JEU <- sprintf("sc\u00e9nario %s (%s) sur le mod\u00e8le ajust\u00e9 de J2", GROUPE, LIB_SCEN[[GROUPE]])
  # Copie declaree de tests/grille_regime_t8.R (generer_scenario(),
  # md5_valeurs()), ordre des tirages fixe par L8.
  generer_scenario <- function(sc, R) {
    f <- FIT_J2; x <- f$x; pi <- f$pi; beta <- f$beta
    tir <- engine_sous_graine(GRAINE_P + sc$s, {
      E <- if (sc$famille == "A") matrix(stats::rchisq(R * T_, sc$par), R, T_, byrow = TRUE) else
        matrix(stats::rnorm(R * T_), R, T_, byrow = TRUE)
      ts <- if (sc$famille == "C") sample.int(T_, R, replace = TRUE) else NULL
      list(E = E, ts = ts)
    })
    E <- tir$E
    if (sc$famille == "H") {
      cv <- exp(f$gamma) * (x / mean(x))^((sc$par - 2) / 2)
      s2 <- log1p(cv^2)
      LY <- matrix(log(beta * x) - s2 / 2, R, T_, byrow = TRUE) + E * matrix(sqrt(s2), R, T_, byrow = TRUE)
    } else {
      if (sc$famille == "A") E <- (E - sc$par) / sqrt(2 * sc$par)
      LY <- matrix(log(beta * x) - 1 / (2 * pi), R, T_, byrow = TRUE) + E * matrix(1 / sqrt(pi), R, T_, byrow = TRUE)
      if (sc$famille == "C") {
        idx <- cbind(seq_len(R), tir$ts)
        LY[idx] <- LY[idx] + sc$par / sqrt(pi[tir$ts])
      }
    }
    list(Y = exp(LY), ts = tir$ts, E = tir$E)
  }
  md5_valeurs <- function(x) {
    f <- tempfile("md5_"); on.exit(unlink(f))
    v <- if (is.matrix(x)) as.vector(t(x)) else x
    ecrire_txt <- file(f, open = "wb"); writeLines(sprintf("%.17g", v), ecrire_txt); close(ecrire_txt)
    unname(tools::md5sum(f))
  }
  g <- generer_scenario(sc, RP_SPEC)
  md5s <- c(E = md5_valeurs(g$E), ts = if (is.null(g$ts)) NA_character_ else md5_valeurs(g$ts), Y = md5_valeurs(g$Y))
  ref8 <- GRILLE$l8[[GROUPE]]
  TXT_L8 <- sprintf("intensit\u00e9 %s ; tir\u00e9s \u00e0 R_P = %d complet sous %.0f ; md5 \u03b5 %s%s, md5 Y %s", LIB_SCEN[[GROUPE]], RP_SPEC, GRAINE_P + sc$s,
                    md5s[["E"]], if (is.na(md5s[["ts"]])) "" else sprintf(", md5 t* %s", md5s[["ts"]]), md5s[["Y"]])
  # References : tableau de la grille (si le scenario y figure) et md5 fixes
  # par la decision A2 (MD5_L8_A2) ; au moins une, et toutes egales.
  refs8 <- Filter(Negate(is.null), list(grille = ref8, decision_A2 = MD5_L8_A2[[GROUPE]]))
  controle(length(refs8) > 0L && all(vapply(refs8, function(r) identical(unname(md5s), unname(r)), logical(1))),
           sprintf("(l8) %s : md5 des \u03b5, des t* et des Y identiques \u00e0 ceux %s", TXT_L8,
                   if (!length(refs8)) "du T0 du tableau de la grille (illisibles ou absents) et de la d\u00e9cision A2 (sc\u00e9nario absent)" else
                     paste(vapply(names(refs8), function(k) sprintf("%s (%s)", c(grille = "du T0 du tableau de la grille",
                                                                                 decision_A2 = "de la d\u00e9cision A2 (annotation du 10/10/2026)")[[k]],
                                                                       paste(refs8[[k]][!is.na(refs8[[k]])], collapse = ", ")), ""), collapse = " et ")))
  X <- FIT_J2$x; Y <- g$Y
  SOURCES <- c(F_TAB221[["J2"]])
}
COLL_TXT <- if (length(COLLISIONS)) TXT_COLL else "aucune"

# --- Jeu observe (J1, J2 ; T3) ---------------------------------------------------
# Comparaison au bit pres et explication des discordances (i1), (v3a).
egal <- function(a, b) identical(as.numeric(a), as.numeric(b))
p_contre <- function(fit, graine, noms = STATS, r_b = NULL) {
  cat_ <- CAT_CONTRE[noms]
  rv <- rejouer_v1(fit, graine, cat_ = cat_)
  mc1 <- .mc_p_values(rv$sim, rv$stats_obs, cat_, rv$e_obs)
  if (is.null(r_b)) return(list(mc = mc1, ok = rv$ok))
  rd <- vapply(rv$delta, function(d) if (is.finite(d)) code_regime(d) else NA_character_, "")
  A <- rv$ok & !is.na(rd) & rd == r_b
  list(mc = .mc_p_values(rv$sim[A, , drop = FALSE], rv$stats_obs, cat_, rv$e_obs), ok = rv$ok)
}
# (v3a) : comparaison a #175 d'une replication (ligne b de B175).
verifier_v3a <- function(r, b, discord) {
  if (is.null(B175)) return(list(etat = "-", discord = discord))
  k <- which(as.integer(B175[, "b"]) == b & B175[, "statut"] %in% c("rejouee", "observe"))
  if (length(k) != 1L || r$statut != "traitee") return(list(etat = "-", discord = discord))
  noms <- sub("^p3:", "", grep("^p3:", colnames(B175), value = TRUE))
  noms <- noms[B175[k, paste0("m3:", noms)] != "-"]
  noms <- STATS[STATS %in% noms]
  if (!length(noms)) return(list(etat = "-", discord = discord))
  p175 <- suppressWarnings(as.numeric(B175[k, paste0("p3:", noms)])); B3 <- suppressWarnings(as.numeric(B175[k, paste0("B3:", noms)]))
  d <- noms[!mapply(egal, p175, r$mc$V3a$p_mc[noms]) | !mapply(egal, B3, r$mc$V3a$B_effectif[noms])]
  if (!length(d)) return(list(etat = "OK", discord = discord))
  rc <- p_contre(r$fit, GRAINE_BOOT + b, noms = noms, r_b = r$regime)
  etat <- "EXPL"
  for (s in d) {
    i <- match(s, noms)
    repro <- egal(rc$mc$p_mc[[s]], p175[i]) && egal(rc$mc$B_effectif[[s]], B3[i])
    cause <- if (s %in% STATS_P2 && r$h2_v1[[s]] > 0) "(h2)" else if (!identical(rc$ok, r$rv$ok)) "angle mort du sous-catalogue" else NA_character_
    if (!repro || is.na(cause)) etat <- "ECHEC"
    discord <- c(discord, sprintf("(v3a) %s : p3 de #175 %.17g (B3 %.0f), V3a %.17g (B %.0f), recalcul %s, %s", s, p175[i], B3[i],
                                  r$mc$V3a$p_mc[[s]], r$mc$V3a$B_effectif[[s]], if (repro) "reproduit #175" else "NE reproduit PAS #175",
                                  if (is.na(cause)) "cause non \u00e9tablie" else cause))
  }
  list(etat = etat, discord = discord)
}
OBS <- "sans objet"
if (PARTIE == "regime" && GROUPE %in% c("J1", "J2")) {
  JO <- if (GROUPE == "J1") list(x = .ln$xt, y = .ln$yt) else J2_DONNEES
  ro <- traiter(JO$x, JO$y, 0L, ctl = list(complet = TRUE, h1 = FALSE), t2 = FALSE)
  e_o <- ro$i2
  if (GROUPE == "J1" && !identical(ro$mc$V1$p_mc, RES_A$bootstrap$p_mc)) e_o <- c(e_o, "p_mc de run_engine() (a)")
  controle(!length(e_o), sprintf("(i2) %s observ\u00e9 : rejeu complet identique (identical()) \u00e0 usp_bootstrap(seed = %.0f), rejeu all\u00e9g\u00e9 (P3) identique au rejeu complet%s%s",
                                 GROUPE, GRAINE_BOOT, if (GROUPE == "J1") " ; p de V1 = p_mc de run_engine() du contr\u00f4le (a)" else "",
                                 if (length(e_o)) paste0(" ; diff\u00e9rences : ", paste(e_o, collapse = ", ")) else ""))
  controle(isTRUE(ro$s1), sprintf("(s1) %s observ\u00e9 : V3b sans P1 (statistiques \u00e0 chaque tirage) identique (p, tirages, B effectifs)", GROUPE))
  vo <- verifier_v3a(ro, 0L, character(0))
  controle(vo$etat != "ECHEC", sprintf("(v3a) %s observ\u00e9 : V3a = p3 de #175 (b = 0) au bit pr\u00e8s, B3 \u00e9gal (\u00e9tat %s)%s", GROUPE, vo$etat,
                                       if (length(vo$discord)) paste0(" ; ", paste(vo$discord, collapse = " ; ")) else ""))
  # duree du jeu observe hors de la ligne OBS (identique entre tranches,
  # verifie par --combiner) : comptee dans la ligne DUREE
  OBS <- champs_rep(0L, ro, v3a = vo$etat, discord = vo$discord)
  OBS[match("duree", REPCOLS)] <- "NA"
}
t_ctrl <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))

# --- En-tete machine (ecrit AVANT les replications) ----------------------------
# PARAMETRES, TRANCHE, CONTEXTE, STATS, REPCOLS, OBS ne dependent que des
# controles generaux et du jeu observe : ecrits des avant la premiere
# replication, puis une ligne REP par replication (flush), puis le markdown
# et la fin (DUREE, REPRISE eventuelle, INTEGRITE, NREP, FIN). Une tranche
# interrompue laisse ainsi son en-tete et ses replications faites, relus par
# --reprendre.
RF <- REF_STATS()
PAR <- sprintf("partie=%s;groupe=%s;R=%d;graine_jeux=%.0f;graine_boot=%.0f+b;graine_v3b=%.0f+b;graine_P=%.0f+s;B=%d;B_cible=%d;B_max=%d;methode=%s;segment=%d;annexe=%s;nature=%s;alpha=%g;theta_equiv=%g%s",
               PARTIE, GROUPE, if (PARTIE == "regime") OPT_R else OPT_RP, GRAINE_JEUX, GRAINE_BOOT, GRAINE_V3B, GRAINE_P, B_BOOT, B_CIBLE,
               B_MAX, METHODE, SEGMENT, ANNEXE, NATURE, ALPHA, THETA_EQUIV,
               if (PARTIE == "puissance") sprintf(";intensite=%s", format(INTENSITES[[GROUPE]])) else "")
CTX <- c(
  partie = PARTIE, groupe = LIB_JEU,
  modele = if (PARTIE == "regime" && GROUPE != "J3") sprintf("\u03b4\u0302 = %.6g ; \u03b3\u0302 = %.6g ; \u03b2\u0302 = %.6g ; \u03c3\u0302 = %.6g (usp_ajuster())", FIT0$delta, FIT0$gamma, FIT0$beta, FIT0$sigma) else
    if (PARTIE == "regime") sprintf("\u03b4 = %s ; \u03b3 = %.6f ; \u03b2 = %s (synth\u00e9tique)", format(DELTA3), GAMMA3, format(BETA3)) else
    sprintf("mod\u00e8le ajust\u00e9 de J2 : \u03b4\u0302 = %.6g ; \u03b3\u0302 = %.6g ; \u03b2\u0302 = %.6g", FIT_J2$delta, FIT_J2$gamma, FIT_J2$beta),
  configuration = sprintf("m\u00e9thode %s, segment %d de l'annexe %s, donn\u00e9es %s, B = %d, B_cible = %d, B_max = %d, \u03b1 = 0,10 et 0,05 ; B_MIN_DEGENERESCENCE = %d ; TOL_DELTA_BORD = %g ; tol\u00e9rance (h2) %g ; (h1) %g relatif",
                          METHODE, SEGMENT, ANNEXE, NATURE, B_BOOT, B_CIBLE, B_MAX, B_MIN_DEGENERESCENCE, TOL_DELTA_BORD, TOL_H2, REL_QR),
  graines = sprintf("%sbootstrap de la r\u00e9plication b : %.0f + b ; flux de V3b : %.0f + b%s",
                    if (PARTIE == "regime") sprintf("jeux : un flux sous %.0f (chemin de #72) ; ", GRAINE_JEUX) else sprintf("jeux du sc\u00e9nario : %.0f ; ", GRAINE_P + SCENARIOS$s[SCENARIOS$code == GROUPE]),
                    GRAINE_BOOT, GRAINE_V3B, if (PARTIE == "regime" && GROUPE != "J3") sprintf(" ; jeu observ\u00e9 : %.0f et %.0f", GRAINE_BOOT, GRAINE_V3B) else ""),
  collisions = COLL_TXT,
  generateur = paste(ENGINE_RNG_KIND, collapse = ", "),
  commit = COMMIT, plateforme = plateforme_calcul(), empreintes = EMPREINTES,
  empreinte_sc = sprintf("%s (md5 du fichier entier %s)", EMPREINTE_SC, MD5_MOTEUR),
  grille = TXT_GRILLE, reference = TXT_A,
  sources = paste(c(vapply(SOURCES[!is.na(SOURCES)], function(f) sprintf("%s (md5 %s, suivi par git : %s)", chemin_cite(f), md5_fichier(f), suivi_git(f)), ""),
                    if (identical(GROUPE, "J3")) sprintf("valeurs brutes de la grille %s (md5 %s)", chemin_cite(OPT_GRILLE_BRUT), md5_fichier(OPT_GRILLE_BRUT))), collapse = " ; "),
  scenario_l8 = TXT_L8, regle_r4 = REGLE_R4, lignes_t2 = paste(LIGNES_T2, collapse = " ; "),
  essai = if (OPT_ESSAI) "oui" else "non", i3 = TXT_I3)
stopifnot(identical(names(CTX), CLES_CONTEXTE))
ENTETE <- enc2utf8(c(paste0("PARAMETRES\t", PAR), sprintf("TRANCHE\t%d\t%d", DEBUT, FIN),
                     sprintf("CONTEXTE\t%s\t%s", names(CTX), vapply(CTX, nettoyer_champ, "")),
                     paste0("STATS\t", paste(sprintf("%s=%s", STATS, QUEUE), collapse = "\t")),
                     paste0("REPCOLS\t", paste(REPCOLS, collapse = "\t")),
                     paste0("OBS\t", paste(OBS, collapse = "\t"))))

# --- Reprise d'une sortie partielle (--reprendre) ------------------------------------
# En-tete de la sortie partielle identique a celui de cette execution
# (parametres, tranche, contexte : commit, plateforme, empreintes du code,
# empreinte #231, generateur, sources ; catalogue, colonnes, jeu observe) ;
# sinon refus. Lignes REP reprises : longueur de REPCOLS, b dans la tranche,
# statut lisible ; une ligne tronquee (interruption pendant l'ecriture) ou
# au statut "erreur" est ignoree et recalculee. Les replications de l'echantillon des controles
# (h1), (i2), (s1) sont toujours recalculees, et leur ligne doit etre
# identique a la ligne reprise hors duree (controle (reprise)).
REPRIS <- list(); N_IGNOREES <- 0L; TXT_REPRISE <- NULL
if (!is.na(OPT_REPRENDRE)) {
  la <- enc2utf8(readLines(OPT_REPRENDRE, warn = FALSE, encoding = "UTF-8"))
  en_a <- la[grepl("^(PARAMETRES|TRANCHE|CONTEXTE|STATS|REPCOLS|OBS)\t", la)]
  if (!identical(en_a, ENTETE)) {
    diff_e <- unique(sub("\t.*$", "", c(setdiff(en_a, ENTETE), setdiff(ENTETE, en_a))))
    diff_c <- unique(sub("^CONTEXTE\t([^\t]*)\t.*$", "\\1", grep("^CONTEXTE\t", c(setdiff(en_a, ENTETE), setdiff(ENTETE, en_a)), value = TRUE)))
    message("--reprendre : REFUS -- en-t\u00eate de ", OPT_REPRENDRE, " diff\u00e9rent de celui de cette ex\u00e9cution : ",
            paste(diff_e, collapse = ", "), if (length(diff_c)) paste0(" (CONTEXTE : ", paste(diff_c, collapse = ", "), ")") else "")
    quit(status = 1L)
  }
  if (any(startsWith(la, "FIN\t"))) {
    message("--reprendre : REFUS -- ", OPT_REPRENDRE, " porte une ligne FIN : sortie compl\u00e8te, rien \u00e0 reprendre")
    quit(status = 1L)
  }
  rp <- strsplit(sub("^REP\t", "", la[startsWith(la, "REP\t")]), "\t", fixed = TRUE)
  bs <- suppressWarnings(as.integer(vapply(rp, `[`, "", 1L)))
  ok <- lengths(rp) == length(REPCOLS) & !is.na(bs) & bs >= DEBUT & bs <= FIN &
    vapply(rp, function(x) length(x) >= 2L && x[2] %in% c("traitee", "ecartee"), logical(1))
  if (anyDuplicated(bs[ok])) {
    message("--reprendre : REFUS -- r\u00e9plication(s) en double dans ", OPT_REPRENDRE, " : ", paste(unique(bs[ok][duplicated(bs[ok])]), collapse = ", "))
    quit(status = 1L)
  }
  REPRIS <- stats::setNames(rp[ok], bs[ok]); N_IGNOREES <- sum(!ok)
  TXT_REPRISE <- c(basename(OPT_REPRENDRE), md5_fichier(OPT_REPRENDRE))
}

# --- Replications ------------------------------------------------------------------
CON <- if (is.na(OPT_SORTIE_TR)) stdout() else file(OPT_SORTIE_TR, open = "wb")
emettre <- function(x) { writeLines(enc2utf8(x), CON, useBytes = TRUE); flush(CON) }
emettre(ENTETE)
REP <- list()
ech <- list(i2 = integer(0), s1 = integer(0), b = integer(0), d = integer(0), reprise = integer(0))
TXT_ECH_I2 <- character(0)
echantillon <- character(0); TXT_H1 <- "aucune r\u00e9plication trait\u00e9e"; H1_OK <- NA
premier <- TRUE; premier_int <- TRUE
N_REPRIS <- 0L; N_RECALC_REPRIS <- 0L
# Calcul d'une replication SANS effet de bord (tryCatch de la boucle) :
# traiter(), puis controles (b), (d), (i1), (t2), (v3a) ; rend la ligne REP
# et les elements des controles d'echantillon, appliques par la boucle si
# et seulement si le calcul aboutit.
calculer_rep <- function(b, y, ctl) {
  r <- traiter(X, y, b, ctl = ctl, t2 = PARTIE == "regime")
  out <- list(statut = r$statut, regime = r$regime, h1 = NULL, i2 = NULL, s1 = NULL, ech_b = FALSE, ech_d = FALSE)
  discord <- character(0); i1 <- "-"; t2 <- "-"; v3a <- "-"
  if (r$statut == "traitee") {
    if (isTRUE(ctl$h1)) out$h1 <- r$h1
    if (isTRUE(ctl$complet)) { out$i2 <- r$i2; out$s1 <- isTRUE(r$s1) }
    # (b) noms et motifs (objets)
    out$ech_b <- !all(vapply(r$mc, function(m) identical(names(m$p_mc), STATS) && identical(names(m$motif_mc), STATS) &&
                               all(code_motif(m$motif_mc) != "?"), logical(1)))
    # (d) invariants (objets)
    ret1 <- B_BOOT - sum(r$rv$ech)
    v3 <- r$v3
    out$ech_d <- sum(r$rv$ok) != ret1 || sum(r$dd) != ret1 || sum(r$A) != r$dd[[r$regime]] || v3$nA > B_CIBLE || v3$tir > B_MAX ||
      (v3$arret == "cible") != (v3$nA == B_CIBLE) || (v3$tir - B_BOOT) != (sum(v3$cpt) + v3$nA - v3$nA0) ||
      any(r$mc$V1$B_effectif > ret1) || any(r$mc$V3a$B_effectif > sum(r$A)) || any(r$mc$V3b$B_effectif > v3$nA)
    # (i1), (t2), (v3a) : J1, J2
    if (!is.null(BRUT221)) {
      p221 <- BRUT221$p[b, ]
      d1 <- STATS[!mapply(egal, p221, r$mc$V1$p_mc[STATS])]
      expl <- character(0)
      if (length(d1)) {
        rc <- p_contre(r$fit, GRAINE_BOOT + b)
        for (s in d1) {
          repro <- egal(rc$mc$p_mc[[s]], p221[[s]])
          # cause (1) : quasi-egalites (h2) comptees sur les seuls tirages
          # de V1 (h2_v1), pas sur les ajouts de V3b
          cause <- if (s %in% STATS_P2 && r$h2_v1[[s]] > 0) "(1) quasi-égalité (h2)" else
            if (!identical(rc$ok, r$rv$ok)) "(2) changement de rétention" else NA_character_
          if (repro && !is.na(cause)) expl <- c(expl, s)
          discord <- c(discord, sprintf("(i1) %s : p de #221 %.17g, p de V1 %.17g, recalcul par la contre-implémentation %s, %s", s, p221[[s]],
                                        r$mc$V1$p_mc[[s]], if (repro) "reproduit #221" else "NE reproduit PAS #221",
                                        if (is.na(cause)) "cause non établie" else cause))
        }
        i1 <- if (length(setdiff(d1, expl))) "ECHEC" else "EXPL"
      } else i1 <- "OK"
      # (t2)
      pr <- suppressWarnings(as.numeric(BRUT221$pr[b, ]))
      dl <- which(!mapply(egal, pr, r$t2$V1$p))
      if (length(dl)) {
        st <- names(STAT_LIGNE)[match(LIGNES_T2[dl], STAT_LIGNE)]
        ok_l <- !is.na(st) & st %in% expl
        t2 <- if (all(ok_l)) "EXPL" else "ECHEC"
        discord <- c(discord, sprintf("(t2) %s : p retenue de #221 %.17g, de V1 %.17g, %s", LIGNES_T2[dl], pr[dl], r$t2$V1$p[dl],
                                      ifelse(ok_l, "expliquée par (i1)", "NON expliquée")))
      } else t2 <- "OK"
      vv <- verifier_v3a(r, b, discord); v3a <- vv$etat; discord <- vv$discord
    }
  }
  out$ch <- champs_rep(b, r, i1 = i1, t2 = t2, v3a = v3a, discord = discord)
  out
}
# Regime de delta*_b d'une replication en erreur, s'il est connu
# (usp_ajuster() et usp_valider_ajustement(), sans alea) ; "-" sinon.
regime_connu <- function(x, y) tryCatch({
  f <- usp_ajuster(x, y)
  if (isTRUE(usp_valider_ajustement(f, METHODE)$ok)) code_regime(f$delta) else "-"
}, error = function(e) "-")
ERREURS <- character(0)
for (b in seq.int(DEBUT, FIN)) {
  y <- Y[b, ]
  ch_old <- REPRIS[[as.character(b)]]
  # echantillon : premiere replication traitee (h1, i2, s1) et premiere
  # replication interieure (i2, s1) ; pre-ajustement (usp_ajuster(), sans
  # alea) tant que l'echantillon n'est pas complet.
  ctl <- list(complet = FALSE, h1 = FALSE)
  if (premier || premier_int) {
    pre <- tryCatch(usp_ajuster(X, y), error = function(e) NULL)
    pre_ok <- !is.null(pre) && isTRUE(tryCatch(usp_valider_ajustement(pre, METHODE)$ok, error = function(e) FALSE))
    pre_int <- pre_ok && code_regime(pre$delta) == "interieur"
    ctl <- list(complet = pre_ok && (premier || (pre_int && premier_int)), h1 = pre_ok && premier)
  }
  if (!is.null(ch_old) && !isTRUE(ctl$complet) && !isTRUE(ctl$h1)) {
    # Replication reprise telle quelle (elle ne depend que de (jeu, b)).
    ch <- ch_old
    N_REPRIS <- N_REPRIS + 1L
  } else {
    t_rep <- Sys.time()
    res <- tryCatch(calculer_rep(b, y, ctl), error = function(e) e)
    if (inherits(res, "error")) {
      # Replication en erreur : ligne REP au statut "erreur", la tranche
      # continue ; --combiner la refusera.
      msg <- nettoyer_champ(conditionMessage(res))
      ch <- champs_rep(b, list(statut = "erreur", regime = regime_connu(X, y), message = msg,
                               duree = as.numeric(difftime(Sys.time(), t_rep, units = "secs"))))
      ERREURS <- c(ERREURS, sprintf("%d (%s) : %s", b, ch[[3]], msg))
    } else {
      ch <- res$ch
      if (res$statut == "traitee") {
        if (!is.null(res$h1)) {
          H1_OK <- !length(res$h1$ko)
          TXT_H1 <- sprintf("réplication %d : %d contexte(s) comparé(s) (observé et tirages réajustés de V1 et de V3b), désaccords : %s",
                            b, res$h1$n, if (length(res$h1$ko)) paste(sprintf("%s (%d)", names(table(res$h1$ko)), as.integer(table(res$h1$ko))), collapse = ", ") else "aucun")
        }
        if (isTRUE(ctl$complet)) {
          echantillon <- c(echantillon, sprintf("%d (%s)", b, res$regime))
          if (length(res$i2)) { ech$i2 <- c(ech$i2, b); TXT_ECH_I2 <- c(TXT_ECH_I2, sprintf("%d (%s)", b, paste(res$i2, collapse = ", "))) }
          if (!isTRUE(res$s1)) ech$s1 <- c(ech$s1, b)
        }
        if (res$ech_b) ech$b <- c(ech$b, b)
        if (res$ech_d) ech$d <- c(ech$d, b)
      }
    }
    if (!is.null(ch_old)) {
      # replication de l'echantillon deja faite : recalculee, identique hors duree
      N_RECALC_REPRIS <- N_RECALC_REPRIS + 1L
      k <- REPCOLS != "duree"
      if (!identical(unname(ch[k]), unname(ch_old[k]))) ech$reprise <- c(ech$reprise, b)
    }
  }
  if (identical(ch[[2]], "traitee")) { premier <- FALSE; if (identical(ch[[3]], "interieur")) premier_int <- FALSE }
  REP[[length(REP) + 1L]] <- ch
  emettre(paste0("REP\t", paste(ch, collapse = "\t")))
}

# --- Controles des lignes REP (calculees ou reprises) ------------------------------
VL <- lapply(REP, verifier_ligne, partie = PARTIE)
b_de <- function(f) vapply(VL[vapply(VL, f, logical(1))], `[[`, 1L, "b")
tally <- function(k) { x <- vapply(VL, `[[`, "", k); c(OK = sum(x == "OK"), EXPL = sum(x == "EXPL"), ECHEC = sum(x == "ECHEC")) }
n_tr <- sum(vapply(VL, function(v) identical(v$statut, "traitee"), logical(1)))
n_err <- sum(vapply(VL, function(v) identical(v$statut, "erreur"), logical(1)))
# (c) : une replication en erreur de regime inconnu ("-") n'est pas comparee
regime_diff <- function(v) !(identical(v$statut, "erreur") && identical(v$regime, "-")) && !identical(v$regime, unname(REG_REF[v$b]))
if (!is.null(REG_REF))
  controle(!length(b_de(regime_diff)),
           sprintf("(c) r\u00e9gime de \u03b4\u0302*_b (ou r\u00e9plication \u00e9cart\u00e9e) identique \u00e0 celui des %s, r\u00e9plications %d..%d%s",
                   if (GROUPE == "J3") "valeurs brutes de la grille (couche v\u00e9rit\u00e9, c-J3)" else "valeurs brutes de #221",
                   DEBUT, FIN, liste_b(b_de(regime_diff))))
if (!is.null(BRUT221)) {
  n_i1 <- tally("i1"); n_t2 <- tally("t2"); n_v3a <- tally("v3a")
  controle(!n_i1[["ECHEC"]], sprintf("(i1) p de V1 = p_mc des valeurs brutes de #221 au bit pr\u00e8s : %d r\u00e9plication(s) OK, %d avec discordance(s) expliqu\u00e9e(s) et list\u00e9e(s), %d en \u00e9chec%s",
                                     n_i1[["OK"]], n_i1[["EXPL"]], n_i1[["ECHEC"]], liste_b(b_de(function(v) v$i1 == "ECHEC"))))
  controle(!n_t2[["ECHEC"]], sprintf("(t2) p retenues des %d lignes de T2 avec V1 = p_retenue des valeurs brutes de #221 au bit pr\u00e8s : %d OK, %d expliqu\u00e9e(s), %d en \u00e9chec%s",
                                     length(LIGNES_T2), n_t2[["OK"]], n_t2[["EXPL"]], n_t2[["ECHEC"]], liste_b(b_de(function(v) v$t2 == "ECHEC"))))
  controle(!n_v3a[["ECHEC"]], sprintf("(v3a) p de V3a = p3 des valeurs brutes de #175 (couples (b, s) communs, B3 \u00e9gal) : %d OK, %d expliqu\u00e9e(s), %d en \u00e9chec%s",
                                      n_v3a[["OK"]], n_v3a[["EXPL"]], n_v3a[["ECHEC"]], liste_b(b_de(function(v) v$v3a == "ECHEC"))))
}
controle(!length(ech$i2), sprintf("(i2) rejeu complet identique (identical()) \u00e0 usp_bootstrap() et rejeu all\u00e9g\u00e9 (P3) identique au rejeu complet, sur l'\u00e9chantillon de la tranche : %s%s",
                                  if (length(echantillon)) paste(echantillon, collapse = ", ") else "aucune r\u00e9plication trait\u00e9e", liste_b(TXT_ECH_I2)))
controle(!length(ech$s1), sprintf("(s1) V3b sans P1 identique (p, tirages, B effectifs) sur l'\u00e9chantillon de (i2)%s", liste_b(ech$s1)))
controle(!identical(H1_OK, FALSE),
         sprintf("(h1) six fonctions de P2 = contre-impl\u00e9mentation (1e-12 relatif, NA et motifs identiques), premi\u00e8re r\u00e9plication trait\u00e9e : %s", TXT_H1))
ech_b <- sort(unique(c(ech$b, b_de(function(v) !v$b_ok))))
controle(!length(ech_b), sprintf("(b) noms des p des variantes = catalogue, dans son ordre, et motifs d'absence connus, \u00e0 chaque r\u00e9plication trait\u00e9e ; p de V3a ou de V3b absente alors que celle de V1 existe (F_R, C3) : motif ni obs. non finie, ni condition du catalogue, ni non d\u00e9finie%s", liste_b(ech_b)))
ech_d <- sort(unique(c(ech$d, b_de(function(v) !v$d_ok))))
controle(!length(ech_d), sprintf("(d) invariants (|A| \u2264 999, tirages \u2264 25 000, arr\u00eat \u00ab cible \u00bb si et seulement si |A| = 999, comptes des tirages de V3b, retenues de V1 = 999 \u2212 \u00e9checs, B effectifs born\u00e9s ; sur les objets et sur les champs de chaque ligne REP)%s",
                                 liste_b(ech_d)))
# Replications en erreur (usp_tests() compris) : non bloquant pour la
# tranche (INTEGRITE inchangee), refusees par --combiner ; rapportees ici et
# en T3. Un verdict "?" (ancien codage d'une erreur de usp_tests()) reste
# une incoherence bloquante.
if (PARTIE == "regime") controle(!length(b_de(function(v) v$err_t2)),
                                 sprintf("(t2) aucun verdict \u00ab ? \u00bb dans les lignes REP%s", liste_b(b_de(function(v) v$err_t2))))
CONTROLES <- c(CONTROLES, sprintf("(erreurs) %d r\u00e9plication(s) au statut erreur (non bloquant pour la tranche ; --combiner refuse la tranche)%s",
                                  n_err, if (length(ERREURS)) paste0(" : ", paste(ERREURS, collapse = " ; ")) else ""))
if (!is.null(TXT_REPRISE))
  controle(!length(ech$reprise), sprintf("(reprise) %s (md5 %s) : en-t\u00eate identique ; %d r\u00e9plication(s) reprise(s) telle(s) quelle(s), %d de l'\u00e9chantillon recalcul\u00e9e(s) et identique(s) \u00e0 la ligne reprise hors dur\u00e9e, %d ligne(s) REP illisible(s), tronqu\u00e9e(s) ou au statut erreur ignor\u00e9e(s) et recalcul\u00e9e(s)%s",
                                         TXT_REPRISE[1], TXT_REPRISE[2], N_REPRIS, N_RECALC_REPRIS - length(ech$reprise), N_IGNOREES, liste_b(ech$reprise)))

# --- Sortie ------------------------------------------------------------------------
DUREE <- c(t_ctrl, as.numeric(difftime(Sys.time(), t_debut, units = "secs")))
DLt <- stats::setNames(list(en_table(REP)), GROUPE)
OLt <- if (identical(OBS, "sans objet")) list() else stats::setNames(list(en_table(list(OBS))), GROUPE)
S <- c(sprintf("## Mesure #229 : p-value Monte-Carlo conditionnelle au r\u00e9gime de \u03b4\u0302, T = 8 -- %s %s (tranche %s)", PARTIE, GROUPE,
               if (is.na(OPT_TRANCHE)) "unique" else OPT_TRANCHE), "",
       sprintf("Param\u00e8tres : %s", PAR), "",
       "### T0 -- provenance", "", entete_md(c("Grandeur", "Valeur")),
       vapply(CLES_CONTEXTE, function(k) ligne_md(LIBELLES_CONTEXTE[[k]], nettoyer_champ(CTX[[k]])), ""),
       ligne_md("R\u00e9plications", sprintf("%d (trait\u00e9es ici : %d \u00e0 %d ; trait\u00e9es : %d ; en erreur : %d)", if (PARTIE == "regime") OPT_R else OPT_RP, DEBUT, FIN, n_tr, n_err)),
       if (!is.null(TXT_REPRISE)) ligne_md("Reprise (--reprendre)", sprintf("%s (md5 %s) : %d r\u00e9plication(s) reprise(s), %d recalcul\u00e9e(s) (\u00e9chantillon des contr\u00f4les), %d ligne(s) ignor\u00e9e(s) ; dur\u00e9es des r\u00e9plications reprises : celles de la premi\u00e8re ex\u00e9cution ; dur\u00e9e totale : cette ex\u00e9cution seule",
                                                                          TXT_REPRISE[1], TXT_REPRISE[2], N_REPRIS, N_RECALC_REPRIS, N_IGNOREES)),
       ligne_md("Dur\u00e9e (s)", sprintf("contr\u00f4les et jeu observ\u00e9 %.0f ; total %.0f ; par r\u00e9plication : %s", DUREE[1], DUREE[2],
                                            paste(vapply(REG, function(rg) { d <- DLt[[1]]$duree[DLt[[1]]$statut == "traitee" & DLt[[1]]$regime == rg]
                                              sprintf("%s %s s (%d)", LIB_REG[[rg]], if (length(d)) num(mean(d), 1) else "\u2014", length(d)) }, ""), collapse = " ; "))),
       ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", if (length(INTEGRITE)) "\u00c9CHEC" else "OK"), "")
if (!is.na(OPT_TRANCHE)) S <- c(S, "Tableaux PARTIELS (une tranche) : combiner les sorties des K tranches par --combiner.", "")
if (OPT_ESSAI) S <- c(S, "**Essai (--essai) : non versionnable.**", "")
S <- c(S, if (PARTIE == "regime") tableaux_regime(DLt, OLt, RF$REF, LIGNES_T2) else tableaux_puissance(DLt, NULL, RF$REF),
       "### Contr\u00f4les d'int\u00e9grit\u00e9", "", paste("-", CONTROLES), "",
       sprintf("Bilan : %s", if (length(INTEGRITE)) sprintf("\u00c9CHEC (%d contr\u00f4le(s))", length(INTEGRITE)) else "OK"), "")
FIN_MACHINE <- c(paste0("DUREE\t", paste(sprintf("%.3f", DUREE), collapse = "\t")),
                 if (!is.null(TXT_REPRISE)) sprintf("REPRISE\t%s\t%s\t%d\t%d\t%d", TXT_REPRISE[1], TXT_REPRISE[2], N_REPRIS, N_RECALC_REPRIS, N_IGNOREES),
                 paste0("INTEGRITE\t", if (length(INTEGRITE)) "ECHEC" else "OK"),
                 sprintf("NREP\t%d", length(REP)),
                 sprintf("FIN\t%d", length(REP)))
emettre(c("", S, FIN_MACHINE))
if (!is.na(OPT_SORTIE_TR)) {
  close(CON)
  ecrire_console(S)
  message("\u00e9crit (sortie de tranche, md5 ", md5_fichier(OPT_SORTIE_TR), ") : ", OPT_SORTIE_TR)
}
quit(status = if (length(INTEGRITE)) 1L else 0L)
