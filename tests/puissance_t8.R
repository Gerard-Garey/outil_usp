###############################################################################
#  tests/puissance_t8.R  --  PUISSANCE A T = 8 DE DOUZE LIGNES DE usp_tests()
#  SOUS DES ALTERNATIVES CONSTRUITES SUR LE MODELE AJUSTE (issues #116, #313,
#  #274)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (tools::md5sum() pour le controle d'integrite du depot et
#  les empreintes du code, #171 ; tools est livre avec R). Sortie en markdown sur la console (UTF-8) ;
#  fichiers ecrits SEULEMENT sur option explicite (--ecrire, --sortie).
#
#  Statut des valeurs : CONSTATS DE SIMULATION sous des alternatives choisies,
#  hors modele reglementaire (statut 4 de docs/exigences.md, par. 2 ; l'annexe
#  XVII suppose des annees independantes et un modele lognormal a beta
#  constant), sauf la puissance de Durbin-Watson sous AR(1) par la methode
#  d'Imhof : approximation numerique d'une quantite exacte (statut 3).
#  Specification : commentaire d'actuary du 30/09/2026 sur #116
#  (5904949481) ; decisions du mainteneur du meme jour (5904983887) : volet B
#  complet (cinq points, J1 et J2, R = 500, B = 999), puissance de DW par
#  Imhof laissee a l'appreciation de coder (calculee, non bloquante),
#  alternative V ajoutee, graine par defaut 20260930.
#
#  Lignes couvertes (cle du catalogue USP_CATALOGUE_MC -> ligne de
#  usp_tests()) : Runs (suites sur z_t), Runsr (suites sur ratios bruts u_t),
#  DW (Durbin-Watson sur z_t), DWr (Durbin-Watson sur ratios bruts ; volet B
#  seulement), MK (Mann-Kendall sur r_t), Smirnov (deux echantillons, partition
#  x_t > med(x)). Rejet : p-value < alpha (verdict ALERTE ou ECHEC).
#  Lignes ajoutees par #313 (volet A ; issue R-17 de la revue de pertinence
#  du 15/10/2026) : supF, CUSUM, Grubbs (sup-F, OLS-CUSUM, Grubbs sur z_t)
#  et supFr, CUSUMr, Grubbsr (memes statistiques sur ratios bruts centres
#  u_t), famille F de usp_tests(). Depuis #274, le volet B couvre aussi ces
#  six lignes (douze lignes, LIG_B), aux cinq points du volet B.
#
#  Alternatives : le modele ajuste FIT0 au jeu (usp_ajuster()) est garde
#  (beta chapeau, pi chapeau_t, x_t) ; seul epsilon est remplace. Avec
#  mu_t = ln(beta x_t) - 1/(2 pi_t) et s_t = sqrt(1/pi_t) (usp_simuler()),
#  y*_t = exp(mu_t + s_t eps'_t), eps' = phi(e), e_1..e_8 i.i.d. N(0,1) ; les
#  amplitudes sont en unites de l'ecart-type de ln r_t (s_t) :
#    N (nulle)         : eps' = e, soit exactement usp_simuler(FIT0) (controle) ;
#    A (autocorr.)     : AR(1) stationnaire de variance unite,
#                        eps'_1 = e_1, eps'_t = rho eps'_{t-1} + sqrt(1 - rho^2) e_t,
#                        rho dans {-0,5 ; 0,3 ; 0,5 ; 0,7 ; 0,9} ; a pi constant,
#                        eps' = sqrt(1 - rho^2) u, u l'AR(1) de C1.a
#                        (tests/constats_puissance_t8.R) : meme loi des p ;
#    T (tendance)      : eps'_t = e_t + D (t - tbar) / (T - 1), tbar = (T + 1)/2,
#                        D dans {1, 2, 3} (derive centree de D ecarts-types entre
#                        la 1re et la 8e annee, specification) ; au volet A (pi
#                        constant, tests invariants par translation) le centrage
#                        est sans effet ; au volet B il ne l'est pas quand pi
#                        chapeau varie (J2 : le decalage s_t tbar D / 7 depend de
#                        t), d'ou le choix de la forme centree de la specification ;
#    R (rupture)       : eps'_t = e_t + Delta 1{t > t0}, (t0, Delta) dans
#                        {(4, 1), (4, 2), (4, 3), (6, 2)} ;
#    V (vol., A seul)  : eps'_t = kappa e_t si x_t > med(x), e_t sinon,
#                        kappa dans {2, 3} ;
#    T1.75 (A seul, #313) : tendance D = 1,75, soit 0,25 ecart-type par an,
#                        point de la revue R-17 (rapprochement, tableau S4) ;
#    C (contam., A seul, #313) : une annee a lambda ecarts-types,
#                        eps'_t = e_t + lambda 1{t = t_c(b)}, lambda dans
#                        {3, 4, 5} ; annee contaminee de la replication b
#                        t_c(b) = 1 + (b - 1) mod T, deterministe : chaque
#                        annee l'est dans R / T replications (a 1 pres), sans
#                        source d'alea nouvelle (la revue tirait l'annee au
#                        hasard ; loi uniforme sur les annees dans les deux
#                        cas) ;
#    C- (contam. vers le bas, A seul, #313) : eps'_t = e_t - lambda 1{t =
#                        t_c(b)}, memes lambda et t_c(b) que C. Symetrie : sup-F,
#                        CUSUM et Grubbs sont pairs en v (stat(-v) = stat(v)),
#                        l*(-e) = -l*(e) et -e a la loi de e : sur les lignes z,
#                        C- et C ont la meme loi (controle non bloquant : IC a
#                        99,9 % qui se recouvrent) ; les lignes sur ratios bruts
#                        ne sont pas invariantes et dependent du sens.
#  Nombres aleatoires communs : une seule matrice e par volet, tiree avant
#  tout calcul, ligne b = 8 tirages consecutifs (ordre de usp_simuler()).
#
#  VOLET A (principal, jeu J1 seul, 22 points, R = --R, alpha = 0,10 et 0,05) :
#    p exactes des fonctions du moteur, regime pi constant, SANS reajustement :
#    runs_p_exacte(l*) et runs_p_exacte(u*), dw_p_exacte(l*), mk_p_exacte(r*),
#    stats::ks.test() sur la partition de l* (l* aplati a TOL_EX_AEQUO comme
#    dans usp_tests()), avec r* = y*/x, l* = ln r* - moyenne(ln r*),
#    u* = r* - moyenne(r*). Ces lois sont invariantes par transformation
#    affine croissante et ln est croissant : sur J1 (pi chapeau constant, z
#    affine croissant de ln r), la p calculee est celle que retiendrait le
#    moteur a pi* constant (controle sur J1 observe ci-dessous). Puissance de
#    DW sous AR(1) par Imhof, a pi constant : P(DW <= d_bas) + P(DW >= d_haut)
#    sous eps' ~ N(0, Sigma_rho), d_bas et d_haut quantiles alpha/2 et
#    1 - alpha/2 de la loi nulle de dw_p_exacte(), chaque probabilite par
#    .imhof_p_sup0() sur les valeurs propres de
#    Sigma^(1/2) M (A - d I) M Sigma^(1/2) (M : centrage, A : matrice de DW),
#    calculee par dw_puissance_ar1() (R/engine.R, #170).
#    Lignes de stabilite (#313) : ces six statistiques n'ont pas de loi exacte
#    dans le moteur ; la p retenue par usp_tests() est Monte-Carlo. Au volet
#    A, p Monte-Carlo a pi constant, sans reajustement : statistiques
#    calculees par les entrees du catalogue USP_CATALOGUE_MC (.mc_evaluer()
#    sur .usp_contexte_mc(x, y*, l*, pi chapeau), z remplace par l*, image
#    affine croissante de z a pi constant, ces statistiques etant invariantes
#    par transformation affine), p = (1 + #{S0 >= s}) / (R0 + 1), formule de
#    engine_p_mc() en queue haute (sens lu au catalogue), sur une loi nulle
#    S0 de R0 = --R-nulle series y0 = usp_simuler(FIT0) sans reajustement,
#    tirees sous engine_sous_graine(--graine + 2), independantes de la
#    matrice e. Comptage par findInterval() sur S0 triee (cout) ; identite
#    a engine_p_mc() controlee (critere 3). Cette loi est celle de la
#    statistique sous le modele a pi constant ; la loi Monte-Carlo du moteur
#    reajuste chaque replication (delta** au bord 0, au bord 1 ou
#    interieur), et n'est donc pas exactement la meme : l'ecart est mesure
#    sur la boucle bootstrap de J1 observe (tableau S5, non bloquant). Le
#    test du volet A est celui a B infini a l'erreur de S0 pres (R0 grand) :
#    Effet de B seul (tableau S7, #313, reserve C1 d'actuary) : a B fini, la
#    p du moteur (1 + K) / (B + 1), K ~ Binomiale(B, u), u = #{S0 >= s} / R0,
#    rejette si K <= k = ceiling(alpha (B + 1)) - 2 ; taux_B = moyenne sur les
#    replications de pbinom(k, B, u_i), u_i = ((R0 + 1) p_i - 1) / R0 : calcul
#    exact conditionnel a la loi S0, sans alea nouveau ; hors reajustement.
#
#  VOLET B (controle, jeux J1 et J2, 5 points N, A(0,5), A(0,9), T(2),
#  R(t0 = 4, Delta = 2), R = --R-chaine, B = --B, alpha = 0,10 ; douze
#  lignes depuis #274 : les six de #116 et les six de stabilite de #313 ;
#  remesure sous le moteur courant, V3h et p_min_mc, issue #274) : p retenue
#  par la chaine reduite, pour chaque replication b :
#    1. usp_ajuster(x, y*) (reajustement complet ; en erreur : replication
#       ecartee, motif compte) ;
#    2. boucle bootstrap de usp_bootstrap() reduite aux douze statistiques
#       de LIG_B (six avant #274 ; boucle_reduite(), catalogue en argument :
#       reutilisable avec le catalogue complet), sous
#       engine_sous_graine(--graine-ic + 1000 b) : usp_simuler() puis
#       usp_ajuster_rapide() depuis l'optimum, replication interne ecartee si
#       le reajustement ou l'une des DOUZE statistiques echoue (les mesures
#       de cout et d'ecart qui suivent, du 30/09 et du 13/10/2026, portent
#       sur les six statistiques d'avant #274). Ecart connu a usp_bootstrap(), qui ecarte aussi une
#       replication interne dont une AUTRE statistique du catalogue complet
#       echoue : non compte dans les replications (cout : catalogue complet
#       14,8 ms contre 0,97 ms pour les six, mesure du 30/09/2026, soit ~ +15 s
#       par replication a B = 999) ; controle seulement sur les jeux observes
#       (sigma_boot et z_boot identiques a ceux de usp_bootstrap()) et signale
#       dans la sortie (B3). Seul
#       usp_simuler() consomme de l'alea (usp_ajuster_rapide() et
#       usp_ajuster_contraint() sont deterministes) : les y** sont ceux de
#       usp_bootstrap() au bit pres (controle sur le jeu observe) ;
#    3. p Monte-Carlo par .mc_p_values() (engine_p_mc(), queue du catalogue,
#       conditions du catalogue evaluees sur l'observe), selon la variante
#       V3h de usp_bootstrap() (#240, ADR 0014 ; transcrite par
#       rejeu_p_mc_v3h() de tests/outils_tests.R depuis #262) : a delta
#       chapeau interieur et volumes non constants, p conditionnelle au
#       regime interieur (V3b), sur les replications de la boucle dont
#       delta** est interieur, completees par le flux distinct de
#       usp_bootstrap() (graine usp_graine_flux_regime()), dont les tirages
#       ne calculent que les six statistiques ; V1 sinon. Meme limite qu'au
#       point 2 : usp_bootstrap() ecarte un tirage du flux dont une AUTRE
#       statistique du catalogue complet echoue, la chaine reduite le
#       retiendrait ; la matrice des tirages retenus differerait alors de ce
#       tirage et, l'arret a la cible venant un tirage plus tot, du dernier
#       (les y** suivants sont inchanges : seul usp_simuler() consomme de
#       l'alea). Non corrige (revue finale de R13, #262) : catalogue
#       complet de l'ordre de 5 a 7 ms par tirage contre 0,9 a 1 ms pour
#       les six (deux mesures, machine chargee), soit, sur J2
#       observe a B = 999 (V3b, 4 490 tirages dont 3 491 du flux), chaine
#       7,6 a 8,7 s avec les six contre 11,1 a 11,9 s avec le catalogue
#       complet (+ 3,5 s environ, + 45 %), lignes des six identiques ; cas
#       jamais observe : 0 tirage du flux sur 5 460 (J2 observe et 6 jeux
#       simules sous l'ajustement de J2, tous a delta chapeau* interieur,
#       B = 999) ou les six aboutissent et le catalogue complet echoue
#       (mesures du 13/10/2026, conteneur Linux, R 4.3.3). Passer au
#       catalogue complet : retirer l'argument evaluer de l'appel de
#       rejeu_p_mc_v3h() dans chaine() (defaut : .stats_bootstrapables()) ;
#    4. p retenue et verdict par usp_tests() lui-meme (accord d'actuary du
#       30/09/2026), avec un objet bootstrap dont usp_tests() ne lit que les
#       champs stats_obs (catalogue complet, sur l'observe), p_mc, err_mc,
#       motif_mc, p_min_mc (plancher Monte-Carlo de la regle R1, #125) et
#       p_mc_regime$variante (nature de la p) ; seules les six p_mc,
#       err_mc, motif_mc et p_min_mc sont calcules (les autres NA, motif
#       MOTIF_MC_AUCUNE_REPLIC depuis #181 ; leurs lignes ne sont pas
#       lues). La regle R7 (p exacte a pi constant, Monte-Carlo sinon ;
#       DWr toujours Monte-Carlo) et les regles R1, R3 et R13 ne sont donc
#       pas transcrites mais appliquees par le moteur ; cout mesure de
#       usp_tests() : 26 ms par appel (30/09/2026, conteneur Linux,
#       R 4.3.3), contre 2,0 a 2,7 s pour la boucle reduite a B = 999 et, a
#       delta chapeau* interieur, le flux V3b en sus : 4,8 a 5,2 s sur J2
#       observe (3 491 tirages du flux, 1,4 a 1,5 ms par tirage), jusqu'a
#       FACTEUR_B_MAX_REGIME (B + 1) tirages en tout (mesures du 13/10/2026,
#       conteneur Linux, R 4.3.3).
#    Ventilation : ALERTE et ECHEC, et regime du reajustement (delta chapeau*
#    au bord 1 : pi constant ; au bord 0 ; interieur).
#    Depuis #274 (restitution, sans changement de la chaine) : un test
#    inoperant (champ inoperant de la ligne, regle R1, #129 ; plancher p_min
#    ou p_min_mc, #125) est compte a part, et non plus parmi les p
#    manquantes ; nature de la p retenue ventilee exacte / Monte-Carlo V1 /
#    Monte-Carlo V3b (NATURE_MC_REGIME_INTERIEUR) ; variante par regime et
#    arret du flux V3b (cible ou plafond) comptes ; tableaux B5 (chaine des
#    verdicts a delta chapeau* interieur : OK, ALERTE, ECHEC, INFO
#    inoperant, sans p retenue) et B6 (part des tests inoperants par point
#    et ligne, IC de Clopper-Pearson, par regime) ; colonne de B1 : taux de
#    rejet avec les inoperants comptes non-rejets (taux des verdicts ALERTE
#    ou ECHEC restitues).
#
#  Criteres BLOQUANTS (code de sortie 1 si l'un echoue) :
#    1. niveau du volet A : l'IC de Clopper-Pearson BILATERAL A 99,9 % du taux
#       de la ligne N contient la taille exacte, pour cinq verifications :
#       suites 4/70 (alpha = 0,10) ; DW alpha (0,10 et 0,05) ; Mann-Kendall
#       0,06101 et 0,03115 ; Smirnov 2/70 (meme evenement aux deux alpha,
#       verifie une fois). Tailles recalculees par enumeration avec les
#       fonctions du moteur et rapprochees de la specification. Le niveau
#       99,9 % par verification limite le risque de faux echec d'un controle
#       juste (decision d'actuary du 30/09/2026) ; la sortie publie l'IC a
#       95 %. Suites a alpha = 0,05 : test inoperant (regle R1, p_min = 4/70
#       >= 0,05), hors critere 1 ; assertion d'integrite : taux exactement 0 ;
#    2. identite Runs / Runsr au volet A, replication par replication ;
#    3. transcription contre run_engine() sur J1 et J2 observes (B = --B,
#       graine --graine-ic) : les douze lignes de engine_table_tests() de la
#       chaine sont identiques a celles de run_engine() (identical(), sauf la
#       p exacte de DW : all.equal() a 1e-10), sigma_boot et z_boot
#       identiques ; volet A : p exactes sur l, u, r de J1 observe egales aux
#       p_exacte de run_engine() ; ligne N identique a usp_simuler(FIT0) ;
#    4. niveau du volet B : sur la ligne N, borne inferieure UNILATERALE A
#       99,9 % de Clopper-Pearson <= alpha pour chaque ligne (sinon constat de
#       sur-rejet : point d'arret, a remonter a actuary) ; evalue sur une
#       execution d'un seul tenant ou apres --combiner, jamais sur une tranche
#       seule ; si n est trop petit pour que la borne puisse depasser alpha
#       meme avec n rejets sur n, la ligne est dite "inoperant (n trop
#       petit)" et non "verifie" ;
#    5. aucune p manquante hors motif compte (une ligne de type test sans p
#       retenue ni motif Monte-Carlo fait echouer) ; une replication ecartee
#       ne compte ni comme rejet ni comme non-rejet ; comptes coherents
#       (#274) : par point, ligne et regime, OK + ALERTE + ECHEC + INFO
#       inoperant + sans p retenue = replications non ecartees, et aucun
#       verdict INFO avec une p retenue ;
#    6. depot intact : aucune modification de R/ ni de tests/reference/ par
#       rapport a HEAD (git status) et empreintes md5 identiques au debut et a
#       la fin de l'execution.
#  Rapportes, non bloquants (decision du mainteneur) : compatibilite avec
#  C1.a (ecart normalise z, |z| <= 1,96) ; puissance de DW par Imhof dans
#  l'IC du volet A, ses controles (rho = 0 : alpha) et ses echecs numeriques
#  (uniroot() ou integration, dans dw_puissance_ar1()) ; ventilation par
#  regime. Aucun n'entre dans le code de
#  sortie.
#  Lignes de stabilite (#313), au critere 3 (bloquant) : statistiques de J1
#  observe par le catalogue sur l* et u egales a boot$stats_obs de
#  run_engine() (u : identical() ; l* : all.equal() a 1e-10) ; p par
#  findInterval() identiques a engine_p_mc() sur les 200 premieres
#  replications de la ligne N ; z_boot des B premieres replications de la
#  boucle bootstrap de controle identiques a ceux de usp_bootstrap().
#  Rapportes, non bloquants (#313, choix de coder a soumettre a actuary) :
#  niveau de la ligne N (taille (ceiling(alpha (R0 + 1)) - 1) / (R0 + 1) du
#  test a loi nulle S0, marginalement sur S0, dans l'IC de Clopper-Pearson
#  bilateral a 99,9 %) ; rapprochement avec les valeurs de la revue R-17
#  (S4) ; ecart entre la loi nulle sans reajustement et la loi bootstrap du
#  moteur sur J1 observe (S5).
#  Incertitude publiee : IC de Clopper-Pearson a 95 % (stats::binom.test()),
#  incertitude Monte-Carlo fonction de R ; elle ne dit rien de l'erreur
#  d'approximation en T.
#
#  Alea : tout tirage passe par engine_sous_graine() (generateur
#  ENGINE_RNG_KIND) : matrice e du volet A sous --graine, du volet B sous
#  --graine + 1 (la meme pour J1 et J2), loi nulle S0 des lignes de
#  stabilite sous --graine + 2 (#313), boucle bootstrap de controle de S5
#  sous --graine-ic (celle de run_engine(), B = --B-controle replications,
#  dont les B premieres sont celles de usp_bootstrap()), boucle bootstrap de la replication b
#  (b = 1..R_chaine) sous --graine-ic + 1000 b (commune aux cinq points) ;
#  controles de transcription sur l'observe sous --graine-ic (graine de
#  run_engine()). Garde d'arret : les graines des matrices e et de S0
#  (--graine a --graine + 2) ne doivent pas figurer parmi --graine-ic + 1000 (0..R_chaine)
#  (flux identiques sinon) ; stop() explicite. Le resultat ne depend pas du
#  decoupage en tranches.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/puissance_t8.R [--volet tout|A|B] [--R 20000]
#          [--R-nulle 100000] [--B-controle 9999]
#          [--R-chaine 500] [--B 999] [--graine 20260930]
#          [--graine-ic 20260831] [--jeu tous|J1|J2] [--tranche i/K]
#          [--ecrire [--remplacer] | --sortie DOSSIER]
#      Rscript tests/puissance_t8.R --combiner f1 f2 ... [--ecrire [--remplacer] | --sortie DOSSIER]
#  --ecrire : ecrit docs/tableaux/<AAAAMMJJ>-issue116-exact-J1.md et
#  <AAAAMMJJ>-issue313-stabilite-J1.md (volet A ; lignes de stabilite, #313),
#  -issue116-chaine-J1.md et -chaine-J2.md (volet B ; nom garde depuis #274,
#  la date distingue la remesure), date du jour de l'execution, a
#  faire sur un arbre propre : --ecrire est REFUSE (code 1, rien d'ecrit) si
#  le commit (celui des tranches pour --combiner, et celui de la
#  combinaison elle-meme) porte "(arbre de travail modifie)", "(script non
#  suivi)" ou "inconnu", ou si tests/outils_tests.R ou le script executes
#  ne sont pas ceux du depot (empreintes "hors depot" ; empreintes du
#  combinateur imprimees en T0 ; #171, elargie : le critere 6 ne couvre que
#  R/ et tests/reference/) ; --sortie DOSSIER : memes noms dans DOSSIER, qui
#  doit etre HORS du depot (un dossier sous la racine du depot est refuse :
#  --ecrire est le seul chemin qui ecrit dans le depot). Le refus qui tient
#  au commit et aux empreintes courants (de l'execution, ou de la
#  combinaison) et l'absence du dossier cible sont evalues des l'analyse
#  des options, avant tout calcul, puis de nouveau au moment d'ecrire
#  (#205).
#  Garde d'ecrasement (#173, garde_ecrasement() de tests/outils_tests.R,
#  evaluee au moment d'ecrire apres les refus precedents) : --ecrire est
#  REFUSE (code 1, aucun des fichiers de l'execution ecrit) si l'un des
#  fichiers cibles est suivi par git, ou existe sans que git puisse dire
#  s'il l'est ; --remplacer (avec --ecrire seulement, refus d'usage sinon)
#  autorise le remplacement d'un fichier suivi, et le T0 du fichier ecrit
#  cite alors le fichier remplace et son md5 d'avant. Hors --combiner, la
#  meme garde est aussi appelee des l'analyse des options, sur les memes
#  chemins (date du debut de l'execution), avant tout calcul : un tableau
#  suivi est refuse en quelques secondes et non apres le calcul (constat m2
#  d'audit de #173) ; la garde finale reste (le depot peut changer pendant
#  le calcul). --combiner n'a que la garde finale (lecture et somme des
#  comptes des tranches, sans simulation).
#  Aucun fichier n'est ecrit si un critere bloquant echoue.
#  --tranche i/K (volet B, un seul jeu : --volet B --jeu J1 ou J2) : ne
#  traite que la i-eme de K tranches de replications consecutives et
#  imprime, apres les tableaux partiels, des lignes machine PARAMETRES,
#  TRANCHE, CONTEXTE, INTEGRITE, NCOMPTES, COMPTE, FIN (format de
#  tests/taux_franchissement_reperes.R). Rediriger chaque tranche vers un
#  fichier HORS du depot, puis --combiner additionne les comptes d'un meme
#  jeu. --combiner refuse (code 1, sans tableau) : une tranche sans ligne
#  INTEGRITE ou en ECHEC ; une sortie incomplete (FIN absente ou pas en
#  derniere ligne, nombre de COMPTE different de NCOMPTES ou de FIN) ; des
#  PARAMETRES ou un CONTEXTE differents (plateforme de calcul comprise :
#  R, systeme, machine, BLAS, LAPACK, #171 ; empreintes md5 de R/engine.R,
#  de tests/outils_tests.R charge et du script execute, #171 elargie) ; des
#  tranches qui ne couvrent pas 1..R exactement une fois.
#  Fonctions reprises par copie declaree (ces scripts executent leur calcul au
#  chargement et ne peuvent pas etre sources) :
#    - de tests/taux_franchissement_reperes.R : lire_option(), ligne_md(),
#      entete_md(), ecrire_console(), lire_j2() (copies) ; lire_comptes() et
#      refuser() (copies adaptees : cles de CONTEXTE propres a ce script) ;
#      l'analyse de --combiner (copie adaptee : la liste des fichiers peut
#      etre suivie de --ecrire ou --sortie DOSSIER) ;
#    - de tests/constats_puissance_t8.R : num(), ecart_z(),
#      compat() et les valeurs publiees de C1 (copies) ; ic_cp() et txt_ic()
#      (copies adaptees : niveau de confiance en argument, n = 0 admis) ;
#    - de tests/calibration_mc_t8.R : plateforme_calcul() (copie, #171),
#      empreintes_code() (copie adaptee : aucun fichier lu en plus) ;
#    - de tests/outils_tests.R (definition unique, #205) : commit_depot()
#      et motifs_non_versionnable().
#  La puissance de DW par Imhof n'est plus une copie : dw_puissance_ar1()
#  (R/engine.R, #170) partage la construction A/M de dw_p_exacte().
#  Duree mesuree (conteneur Linux, R 4.3.3, 30/09/2026, petits R ; les
#  executions completes consignent la leur dans T0 et dans le bilan) :
#  volet A 1,4 a 1,6 ms par serie et par point (15 points x 20 000 : de
#  l'ordre de 7 a 8 min ; depuis #313, six statistiques de plus, a 19
#  points (avant C-) : 2,7 ms par serie et par point, volet A complet 1 074 s dont loi
#  nulle S0 (R0 = 100 000) 23 s et boucle S5 (B = 9 999) 14 s, mesure du
#  17/10/2026, meme conteneur, R 4.3.3, machine chargee) ; volet B 2,5 a 2,8 s par replication et par point
#  a B = 999 (5 points x 500 : de l'ordre de 1,8 h par jeu en sequentiel,
#  soit ~ 14 min par tranche en 8 tranches paralleles) ; controles de
#  transcription : un run_engine() par jeu, ~ 20 s. Depuis #262 (flux V3b
#  de la p Monte-Carlo, point 3 du volet B), une replication a delta
#  chapeau* interieur coute en plus son flux, jusqu'a FACTEUR_B_MAX_REGIME
#  (B + 1) tirages : mesure du 13/10/2026 (meme conteneur, --volet B
#  --R-chaine 5 --B 999) : J1 2,37 s par replication et par point (aucune
#  des 25 replications a delta chapeau* interieur), J2 3,23 s (4 sur 25),
#  soit ~ 5 s de plus par replication interieure ; controles 16 s (J1) et
#  29 s (J2). La duree d'une execution complete depend donc de la part de
#  replications a delta chapeau* interieur, et de la rarete du regime
#  interieur sous leur ajustement (nombre de tirages du flux).
#  Depuis #274 (douze statistiques ; mesure du 18/10/2026, meme conteneur,
#  R 4.3.3, machine chargee : trois coeurs sur quatre pris par d'autres
#  mesures, --volet B --B 999) : J1 2,60 s par replication et par point
#  (--R-chaine 4), J2 3,76 s (--R-chaine 6, 5 replications sur 30 a delta
#  chapeau* interieur) ; controles 17 s (J1) et 27 s (J2). Execution
#  complete (--R-chaine 500) : de l'ordre de 1,8 h (J1) et 2,6 h (J2) en
#  sequentiel sur un coeur.
#  Critere de recette (decision d'actuary du 30/09/2026) : --R 200
#  --R-chaine 2 rend le code 0 en moins de trois minutes, controles compris
#  (mesure : voir le compte rendu de #116 ; 106 a 114 s avant la reprise ;
#  148 s depuis #313 a 19 points, 152 s a 22 points (charge 3), mesures du
#  17/10/2026, dont S0 et boucle S5 environ 38 s).
#  Code de sortie : 0 si les criteres bloquants tiennent, 1 sinon ; en mode
#  --combiner, 1 aussi si la combinaison est refusee.
###############################################################################

t_debut <- Sys.time()

# --- Options (lire_option() : copie de tests/taux_franchissement_reperes.R) ---
ARGS <- commandArgs(trailingOnly = TRUE)
i_comb <- match("--combiner", ARGS)
FICHIERS_COMB <- if (is.na(i_comb)) character(0) else {
  reste <- ARGS[-seq_len(i_comb)]
  # les options --ecrire, --remplacer et --sortie DOSSIER peuvent suivre la liste
  j <- match(c("--ecrire", "--remplacer", "--sortie"), reste)
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
OPT_VOLET     <- lire_option("--volet", "tout")
OPT_R         <- as.integer(lire_option("--R", "20000"))
OPT_R_CHAINE  <- as.integer(lire_option("--R-chaine", "500"))
OPT_R_NULLE   <- as.integer(lire_option("--R-nulle", "100000"))
OPT_B_CTRL    <- as.integer(lire_option("--B-controle", "9999"))
OPT_B         <- as.integer(lire_option("--B", "999"))
OPT_GRAINE    <- as.numeric(lire_option("--graine", "20260930"))
OPT_GRAINE_IC <- as.numeric(lire_option("--graine-ic", "20260831"))
OPT_JEU       <- lire_option("--jeu", "tous")
OPT_TRANCHE   <- lire_option("--tranche", NA_character_)
OPT_ECRIRE    <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_SORTIE    <- lire_option("--sortie", NA_character_)
if (!OPT_VOLET %in% c("tout", "A", "B")) stop("--volet : tout, A ou B")
if (!OPT_JEU %in% c("tous", "J1", "J2")) stop("--jeu : tous, J1 ou J2")
if (!is.finite(OPT_R) || OPT_R < 1L) stop("--R : entier >= 1")
if (!is.finite(OPT_R_CHAINE) || OPT_R_CHAINE < 1L) stop("--R-chaine : entier >= 1")
if (!is.finite(OPT_R_NULLE) || OPT_R_NULLE < 1000L) stop("--R-nulle : entier >= 1000")
if (!is.finite(OPT_GRAINE) || !is.finite(OPT_GRAINE_IC)) stop("--graine, --graine-ic : nombres")
if (OPT_ECRIRE && !is.na(OPT_SORTIE)) stop("--ecrire et --sortie sont exclusifs")
if (OPT_REMPLACER && !OPT_ECRIRE) stop("--remplacer : reserve a --ecrire (remplacement d'un tableau suivi par git, #173)")
if (!is.na(OPT_SORTIE) && !dir.exists(OPT_SORTIE)) stop("--sortie : dossier introuvable : ", OPT_SORTIE)
# Garde de graines (voir l'en-tete) : les flux des matrices e et de la loi
# nulle S0 (#313) ne doivent pas etre ceux d'une boucle bootstrap
# (graine_ic + 1000 b, b = 0 pour l'observe).
local({
  g_boot <- OPT_GRAINE_IC + 1000 * (0:OPT_R_CHAINE)
  g_e <- OPT_GRAINE + 0:2
  if (any(g_e %in% g_boot))
    stop(sprintf(paste("graines en collision : la graine %s des matrices e et de S0 (--graine %s a --graine + 2)",
                       "est aussi celle d'une boucle bootstrap (--graine-ic + 1000 b, b = 0..%d) ;",
                       "changer --graine ou --graine-ic"),
                 paste(format(g_e[g_e %in% g_boot], scientific = FALSE), collapse = ", "),
                 format(OPT_GRAINE, scientific = FALSE), OPT_R_CHAINE))
})
if (!is.na(OPT_TRANCHE)) {
  if (OPT_VOLET != "B" || OPT_JEU == "tous")
    stop("--tranche : volet B et un seul jeu (--volet B --jeu J1 ou J2)")
  if (OPT_ECRIRE || !is.na(OPT_SORTIE))
    stop("--tranche : sortie partielle, --ecrire et --sortie reserves a --combiner")
}

# Configuration de run_engine() reproduite (cas de reference "premium" ; sans
# effet sur les six lignes).
METHODE <- "premium"; SEGMENT <- 1; ANNEXE <- "II"; NATURE <- "brutes"
ALPHA <- 0.10; ALPHA2 <- 0.05; THETA_EQUIV <- 0.10
T_ <- 8L

# --- Chargement du moteur et des outils --------------------------------------
DOSSIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) dirname(f) else if (file.exists("tests/outils_tests.R")) "tests" else "."
})
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))
if (!is.finite(OPT_B) || OPT_B < B_MIN_USAGE)
  stop(sprintf("--B : entier >= B_MIN_USAGE = %d (minimum admis par run_engine())", B_MIN_USAGE))
if (!is.finite(OPT_B_CTRL) || OPT_B_CTRL < OPT_B)
  stop("--B-controle : entier >= --B (les B premieres replications sont controlees contre usp_bootstrap())")

# --- Outils (copies declarees, voir l'en-tete) -----------------------------------
git_depot <- function(...) tryCatch(suppressWarnings(system2("git", c("-C", RACINE, ...), stdout = TRUE,
                                                             stderr = FALSE)),
                                    error = function(e) NULL)
# commit_depot() et motifs_non_versionnable() : tests/outils_tests.R (#205).
# Plateforme de calcul (#171) : R, systeme, machine, BLAS, LAPACK (copie de
# tests/calibration_mc_t8.R). Ligne de T0 des deux volets ; au volet B, champ
# du contexte : des tranches calculees sur des plateformes differentes ne se
# combinent pas (les reajustements dependent de l'optimiseur).
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
EMPREINTES <- empreintes_code("tests/puissance_t8.R")

# Chemin (existant) sous la racine du depot (copie de tests/calibration_mc_t8.R,
# constat R2 d'audit) : --sortie doit viser hors du depot ; --ecrire est le
# seul chemin qui ecrit dans le depot.
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

# --- Chemins des tableaux ecrits (seule source : ecrire_fichiers() et controle
# anticipe) ------------------------------------------------------------------------
# Date du debut de l'execution, dans le nom des fichiers ecrits.
DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
# Jeux du volet B d'une execution directe.
JEUX_B <- if (OPT_JEU == "tous") c("J1", "J2") else OPT_JEU
# Suffixes des fichiers d'une execution directe (hors --combiner), dans
# l'ordre de a_ecrire en fin d'execution (controle par stopifnot() a
# l'ecriture).
SUFFIXES_EXECUTION <- c(if (OPT_VOLET %in% c("tout", "A")) c("exact-J1", "stabilite-J1"),
                        if (OPT_VOLET %in% c("tout", "B")) paste0("chaine-", JEUX_B))
dossier_sortie <- function() if (OPT_ECRIRE) file.path(RACINE, "docs", "tableaux") else OPT_SORTIE
# Issue du nom : #313 pour le tableau des lignes de stabilite, #116 sinon
# (volet B compris depuis #274 : le nom -issue116-chaine-J*.md est garde,
# controle par tests/unitaires/test_garde_ecrasement.R ; la date distingue
# la remesure de #274 des tableaux du 30/09/2026, gardes tels quels).
issue_sortie <- function(suffixes) ifelse(startsWith(suffixes, "stabilite"), "issue313", "issue116")
chemins_sortie <- function(suffixes) file.path(dossier_sortie(), sprintf("%s-%s-%s.md", DATE_SORTIE,
                                                                         issue_sortie(suffixes), suffixes))
# Gardes anticipees de l'arbre propre et du dossier cible (#205) : avant tout
# calcul, memes refus que ecrire_fichiers(), qui les reprend (l'etat du
# depot peut changer pendant le calcul) ; commit et empreintes courants,
# ceux de l'execution ou, pour --combiner, de la combinaison (ceux des
# tranches, lus dans leurs fichiers, restent controles a l'ecriture).
if (OPT_ECRIRE) {
  nv0 <- motifs_non_versionnable(commit_depot("tests/puissance_t8.R"), EMPREINTES,
                                 if (length(FICHIERS_COMB)) "de la combinaison" else "de l'ex\u00e9cution")
  if (length(nv0)) {
    message("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv0, collapse = " ; "),
            " -- aucun fichier ecrit ; relancer sur un arbre propre, ou --sortie DOSSIER hors du depot")
    quit(status = 1L)
  }
}
if ((OPT_ECRIRE || !is.na(OPT_SORTIE)) && !dir.exists(dossier_sortie()))
  stop("dossier de sortie introuvable : ", dossier_sortie())
# Garde d'ecrasement anticipee (#173, constat m2 d'audit) : hors --combiner,
# avant tout calcul ; sans --remplacer, un fichier cible suivi par git est
# refuse ici (code 1, rien d'ecrit). Avec --remplacer, rien n'est imprime
# ni retenu : la garde finale de ecrire_fichiers() releve les md5 d'avant.
if (OPT_ECRIRE && !length(FICHIERS_COMB))
  garde_ecrasement(chemins_sortie(SUFFIXES_EXECUTION), OPT_REMPLACER, RACINE)
ecrire_console <- function(x) writeLines(enc2utf8(x), useBytes = TRUE)
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
num <- function(x, d = 3) if (is.na(x)) "\u2014" else sub(".", ",", sprintf(paste0("%.", d, "f"), x), fixed = TRUE)
ic_cp <- function(k, n, niveau = 0.95) if (n > 0) {
  ci <- stats::binom.test(k, n, conf.level = niveau)$conf.int
  c(ci[1], ci[2])
} else c(NA_real_, NA_real_)
txt_ic <- function(ci) if (anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", num(ci[1]), num(ci[2]))
taux <- function(k, n) if (n > 0) num(k / n) else "\u2014"
# Borne inferieure unilaterale de Clopper-Pearson (critere 4), NA si n = 0.
borne_inf <- function(k, n, niveau = 0.999) if (n > 0)
  stats::binom.test(k, n, alternative = "greater", conf.level = niveau)$conf.int[1] else NA_real_
# Ecart normalise entre deux estimations independantes d'une meme proportion
# (reproduction sur n tirages, publication sur R_PUB) ; compatible si |z| <= 1,96.
R_PUB <- 20000
ecart_z <- function(k, n, pub) {
  pbar <- (k + pub * R_PUB) / (n + R_PUB)
  (k / n - pub) / sqrt(pbar * (1 - pbar) * (1 / n + 1 / R_PUB))
}
compat <- function(pub, k, n) if (is.na(pub)) c("\u2014", "\u2014") else {
  z <- ecart_z(k, n, pub)
  c(sub(".", ",", sprintf("%+.2f", z), fixed = TRUE), if (abs(z) <= stats::qnorm(0.975)) "oui" else "**non**")
}
# Constat C1.a publie (commentaire d'actuary du 23/09/2026 sur #44 ; reproduit
# par tests/constats_puissance_t8.R), alpha = 0,10, AR(1) stationnaire.
C1_RHO    <- c(0.3, 0.5, 0.7, 0.9)
C1_SUITES <- c(0.080, 0.118, 0.175, 0.247)
C1_DW     <- c(0.163, 0.268, 0.395, 0.529)

INTEGRITE <- character(0)          # libelles des criteres en echec
DUREE_CONTROLES <- 0               # secondes passees dans les controles de transcription
CONTROLES <- character(0)          # lignes "libelle : OK / ECHEC"
# statut_ok : texte imprime a la place de "OK" (critere 4 inoperant) ;
# bloquant = FALSE : controle rapporte, sans effet sur le code de sortie.
controle <- function(ok, libelle, statut_ok = "OK", bloquant = TRUE) {
  ok <- isTRUE(ok)
  if (!ok && bloquant) INTEGRITE <<- c(INTEGRITE, libelle)
  CONTROLES <<- c(CONTROLES, sprintf("%s : %s", libelle,
                                     if (ok) statut_ok else if (bloquant) "ECHEC" else "ECHEC (non bloquant)"))
  invisible(ok)
}
# Texte du critere 4 (resultat de tableaux_chaine()).
texte_crit4 <- function(tb) {
  if (length(tb$echecs4))
    return(paste("ECHEC -- constat de sur-rejet, point d'arr\u00eat \u00e0 remonter \u00e0 actuary :",
                 paste(tb$echecs4, collapse = " ; ")))
  paste0(if (length(tb$ok4)) paste0("v\u00e9rifi\u00e9 (", paste(tb$ok4, collapse = ", "), ")") else "aucune ligne v\u00e9rifi\u00e9e",
         if (length(tb$inop4)) paste0(" ; inop\u00e9rant (n trop petit) : ", paste(tb$inop4, collapse = ", ")) else "")
}

# --- Critere 6 : depot intact (R/ et tests/reference/) ----------------------------
empreintes_depot <- function() {
  f <- c(list.files(file.path(RACINE, "R"), recursive = TRUE, full.names = TRUE),
         list.files(file.path(RACINE, "tests", "reference"), recursive = TRUE, full.names = TRUE))
  tools::md5sum(sort(f))
}
etat_git_depot <- function() {
  s <- git_depot("status", "--porcelain", "--", "R", "tests/reference")
  if (is.null(s)) NA_character_ else paste(s, collapse = " ; ")
}
verifier_depot <- function(md5_debut, moment) {
  g <- etat_git_depot()
  controle(!is.na(g) && !nzchar(g),
           sprintf("Crit\u00e8re 6, d\u00e9p\u00f4t intact (%s) : git status de R/ et tests/reference/ vide%s",
                   moment, if (is.na(g)) " (git indisponible)" else if (nzchar(g)) paste0(" (", g, ")") else ""))
  if (!is.null(md5_debut))
    controle(identical(md5_debut, empreintes_depot()),
             sprintf("Crit\u00e8re 6, d\u00e9p\u00f4t intact (%s) : md5 de R/ et tests/reference/ inchang\u00e9s depuis le d\u00e9but", moment))
}

# --- Lignes couvertes ------------------------------------------------------------
SIX <- c("Runs", "Runsr", "DW", "DWr", "MK", "Smirnov")
LIGNES <- c(
  Runs    = "Test des suites (aleatoire des signes)",
  Runsr   = "Test des suites sur ratios bruts",
  DW      = "Autocorrelation d'ordre 1 (Durbin-Watson)",
  DWr     = "Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts",
  MK      = "Tendance monotone du ratio S/P",
  Smirnov = "Egalite des lois petits vs gros volumes (2 ech.)")
LIB_COURT <- c(Runs = "Suites (z)", Runsr = "Suites (ratios bruts)", DW = "Durbin-Watson (z)",
               DWr = "Durbin-Watson (ratios bruts)", MK = "Mann-Kendall", Smirnov = "Smirnov")
# Lignes de stabilite (#313, volet A) : cles du catalogue USP_CATALOGUE_MC.
STAB <- c("supF", "CUSUM", "Grubbs", "supFr", "CUSUMr", "Grubbsr")
CAT_STAB <- USP_CATALOGUE_MC[STAB]
LIB_STAB <- c(supF = "sup-F (z)", CUSUM = "OLS-CUSUM (z)", Grubbs = "Grubbs (z)",
              supFr = "sup-F (ratios bruts)", CUSUMr = "OLS-CUSUM (ratios bruts)", Grubbsr = "Grubbs (ratios bruts)")
# Lignes du volet B (#274) : les six lignes de #116 et les six lignes de
# stabilite de #313, chaine reduite du moteur courant (V3h, p_min_mc).
LIG_B <- c(SIX, STAB)
LIGNES <- c(LIGNES,
  supF    = "Rupture de niveau (sup-F)",
  CUSUM   = "Stabilite cumulee (OLS-CUSUM)",
  Grubbs  = "Valeur aberrante isolee (Grubbs)",
  supFr   = "Rupture de niveau (sup-F) sur ratios bruts",
  CUSUMr  = "Stabilite cumulee (OLS-CUSUM) sur ratios bruts",
  Grubbsr = "Valeur aberrante isolee (Grubbs) sur ratios bruts")
LIB_COURT <- c(LIB_COURT, LIB_STAB)
REGIMES <- c(bord1 = "\u03b4\u0302* = 1 (\u03c0\u0302* constant)", bord0 = "\u03b4\u0302* = 0",
             interieur = "\u03b4\u0302* int\u00e9rieur")

# --- Alternatives ------------------------------------------------------------------
# Un point : cle ASCII, libelle, fonction e -> eps' (x_t du jeu et indice b
# de la replication en argument ; b n'est lu que par le scenario C, #313).
point <- function(cle, lib, phi) list(cle = cle, lib = lib, phi = phi)
ar1 <- function(rho) function(e, x, b) {
  v <- numeric(length(e)); v[1] <- e[1]
  for (t in 2:length(e)) v[t] <- rho * v[t - 1] + sqrt(1 - rho^2) * e[t]
  v
}
tendance <- function(D) function(e, x, b) e + D * (seq_along(e) - (length(e) + 1) / 2) / (length(e) - 1)
POINTS_A <- c(
  list(point("N", "N (nulle)", function(e, x, b) e)),
  lapply(c(-0.5, 0.3, 0.5, 0.7, 0.9), function(r)
    point(sprintf("A%+.1f", r), sprintf("A (AR(1), \u03c1 = %s)", num(r, 1)), ar1(r))),
  lapply(1:3, function(D) point(sprintf("T%d", D), sprintf("T (tendance, D = %d)", D), tendance(D))),
  # #313 : derive de 0,25 ecart-type par an (revue R-17), D = 7 x 0,25.
  list(point("T1.75", "T (tendance, D = 1,75 : 0,25 \u03c3 par an)", tendance(1.75))),
  lapply(list(c(4, 1), c(4, 2), c(4, 3), c(6, 2)), function(p)
    point(sprintf("R%d_%d", p[1], p[2]), sprintf("R (rupture, t\u2080 = %d, \u0394 = %d)", p[1], p[2]),
          function(e, x, b) e + p[2] * (seq_along(e) > p[1]))),
  lapply(2:3, function(k) point(sprintf("V%d", k), sprintf("V (volume, \u03ba = %d)", k),
                                function(e, x, b) ifelse(x > stats::median(x), k * e, e))),
  # #313 : contamination d'une annee, t_c(b) = 1 + (b - 1) mod T (en-tete).
  lapply(3:5, function(l) point(sprintf("C%d", l), sprintf("C (contamination, \u03bb = %d)", l),
                                function(e, x, b) e + l * (seq_along(e) == 1L + (b - 1L) %% length(e)))),
  # #313 (reserve C2 d'actuary) : contamination vers le bas, meme t_c(b).
  lapply(3:5, function(l) point(sprintf("Cm%d", l), sprintf("C\u2212 (contamination vers le bas, \u03bb = %d)", l),
                                function(e, x, b) e - l * (seq_along(e) == 1L + (b - 1L) %% length(e)))))
names(POINTS_A) <- vapply(POINTS_A, `[[`, "", "cle")
POINTS_B <- POINTS_A[c("N", "A+0.5", "A+0.9", "T2", "R4_2")]

# y* sous l'alternative : exp(mu + s eps'), memes operations que usp_simuler()
# (rnorm(T, mu, s) = mu + s * norm_rand() sous Inversion).
simuler_alt <- function(fit, eps) {
  mu <- log(fit$beta * fit$x) - 1 / (2 * fit$pi)
  exp(mu + sqrt(1 / fit$pi) * eps)
}
# Matrice e (R x T), ligne b = T tirages consecutifs, sous graine explicite.
tirer_e <- function(graine, R) engine_sous_graine(graine, matrix(stats::rnorm(R * T_), nrow = R, byrow = TRUE))

# --- Jeux (lire_j2() : copie de tests/taux_franchissement_reperes.R) ---------------
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
charger_jeu <- function(j) {
  jeu <- if (j == "J1")
    list(nom = "J1", x = .ln$xt, y = .ln$yt, libelle = "J1 : tests/donnees/donnees_ln.csv (jeu des cas de r\u00e9f\u00e9rence)") else
    c(list(nom = "J2"), lire_j2(), libelle = "J2 : xi, yi de tests/unitaires/test_controles_numeriques.R (\u03b4 estim\u00e9 int\u00e9rieur)")
  # Le protocole (tailles exactes, alternatives, partition) est ecrit pour T = 8.
  stopifnot(length(jeu$x) == T_, length(jeu$y) == T_)
  jeu
}
txt_modele <- function(fit) sprintf("\u03b4\u0302 = %.6g ; \u03b3\u0302 = %.6g ; \u03b2\u0302 = %.6g ; \u03c3\u0302 = %.6g ; \u03c0\u0302 constant : %s",
                                    fit$delta, fit$gamma, fit$beta, fit$sigma, usp_regime(fit$delta, fit$x)$pi_constant)
code_regime <- function(fit) if (fit$delta >= 1 - TOL_DELTA_BORD) "bord1" else
  if (fit$delta <= TOL_DELTA_BORD) "bord0" else "interieur"

# run_engine() sur le jeu observe (controles de transcription).
engine_observe <- function(jeu) run_engine(xt = jeu$x, yt = jeu$y, methode = METHODE, segment = SEGMENT,
                                           annexe = ANNEXE, nature_donnees = NATURE, B = OPT_B,
                                           alpha = ALPHA, theta_equiv = THETA_EQUIV, seed = OPT_GRAINE_IC)
# Lignes de LIGNES (douze : six de #116, six de stabilite de #313) dans une
# table de engine_table_tests().
lignes_tests <- function(tab) {
  i <- match(LIGNES, tab$test)
  if (anyNA(i) || any(vapply(LIGNES, function(l) sum(tab$test == l), numeric(1)) != 1))
    stop("lignes de usp_tests() introuvables ou multiples : script a mettre a jour (LIGNES)")
  rownames(tab) <- NULL
  stats::setNames(lapply(i, function(k) tab[k, , drop = FALSE]), names(LIGNES))
}

# --- Criteres, empreintes du depot au debut -----------------------------------------
MD5_DEBUT <- if (!length(FICHIERS_COMB)) empreintes_depot() else NULL
if (!length(FICHIERS_COMB)) verifier_depot(NULL, "d\u00e9but")

# --- Ecriture des fichiers (seulement sur option et si tout est OK) ------------------
# commit et empreintes : ceux du code qui a calcule le tableau (des tranches
# pour --combiner) ; --ecrire refuse s'ils ne sont pas ceux d'un commit propre
# du depot (#171, elargie) ; combinaison = TRUE : la combinaison elle-meme
# (commit et empreintes courants) doit l'etre aussi (constat R1 d'audit).
# fichiers : liste nommee suffixe -> lignes, tous les fichiers de
# l'execution ; avec --ecrire, la garde d'ecrasement (#173) controle tous
# leurs chemins avant d'en ecrire un seul (de nouveau : le controle
# anticipe a precede le calcul), et le T0 de chaque fichier remplace
# (--remplacer) le cite.
ecrire_fichiers <- function(fichiers, commit = commit_depot("tests/puissance_t8.R"), empreintes = EMPREINTES,
                            combinaison = FALSE) {
  if (!OPT_ECRIRE && is.na(OPT_SORTIE)) return(invisible(NULL))
  if (OPT_ECRIRE) {
    nv <- c(motifs_non_versionnable(commit, empreintes, if (combinaison) "des tranches" else "de l'ex\u00e9cution"),
            if (combinaison) motifs_non_versionnable(commit_depot("tests/puissance_t8.R"), EMPREINTES, "de la combinaison"))
    if (length(nv)) {
      message("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
              " -- aucun fichier ecrit ; relancer sur un arbre propre, ou --sortie DOSSIER hors du depot")
      quit(status = 1L)
    }
  }
  dossier <- dossier_sortie()
  if (!dir.exists(dossier)) stop("dossier de sortie introuvable : ", dossier)
  chemins <- chemins_sortie(names(fichiers))
  remplaces <- if (OPT_ECRIRE) garde_ecrasement(chemins, OPT_REMPLACER, RACINE) else NULL
  for (i in seq_along(fichiers)) {
    lignes <- fichiers[[i]]
    if (OPT_ECRIRE) lignes <- inserer_t0(lignes, ligne_remplacement(remplaces, chemins[i]))
    con <- file(chemins[i], open = "wb")
    writeLines(enc2utf8(lignes), con, useBytes = TRUE)
    close(con)
    message("\u00e9crit : ", chemins[i])
  }
}

###############################################################################
#  VOLET B : outils communs (execution directe, tranches et --combiner)
###############################################################################

# Boucle de usp_bootstrap() reduite aux statistiques de `catalogue`, sous
# engine_sous_graine(graine) : memes tirages (usp_simuler()), meme
# reajustement (usp_ajuster_rapide() depuis l'optimum). Une replication
# interne est ecartee si le reajustement echoue ou si l'une des statistiques
# de `catalogue` echoue ; usp_bootstrap() l'ecarte aussi quand une AUTRE
# statistique du catalogue complet echoue, cas que cette boucle ne voit pas
# avec les six statistiques (non compte : cout, voir l'en-tete ; controle
# sur les jeux observes seulement). Avec le catalogue complet, les regles
# d'ecartement sont celles de usp_bootstrap(). Rend sim (B x statistiques),
# sigma et z des replications (NA si ecartee), pour le controle d'integrite
# contre usp_bootstrap(), et retenu et delta** des replications, lus par la
# variante V3h de la p Monte-Carlo (rejeu_p_mc_v3h(), #262).
boucle_reduite <- function(fit, graine, B, catalogue) {
  engine_sous_graine(graine, {
    sim <- matrix(NA_real_, B, length(catalogue), dimnames = list(NULL, names(catalogue)))
    sig <- dl <- rep(NA_real_, B)
    ok <- rep(FALSE, B)
    zb <- matrix(NA_real_, B, length(fit$x))
    for (b in seq_len(B)) {
      yb <- usp_simuler(fit)
      fb <- try(usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
      if (inherits(fb, "try-error")) next
      sb <- try(.mc_evaluer(catalogue, .usp_contexte_mc(fit$x, yb, fb$z, fb$pi)), silent = TRUE)
      if (inherits(sb, "try-error")) next
      sim[b, ] <- sb
      zb[b, ] <- fb$z
      sig[b] <- fb$sigma
      dl[b] <- fb$delta
      ok[b] <- TRUE
    }
    list(sim = sim, sigma_boot = sig[is.finite(sig)], z_boot = zb, retenu = ok, delta = dl)
  })
}

# Chaine reduite d'une replication : reajustement, boucle reduite, p_mc des
# douze statistiques de LIG_B (six de #116, six de stabilite de #313 depuis
# #274 ; variante V3h de usp_bootstrap() : V3b a delta estime interieur et
# volumes non constants, flux complementaire limite aux douze statistiques ;
# V1 sinon ; rejeu_p_mc_v3h() de tests/outils_tests.R, #262), usp_tests(). Rend NULL + motif si le reajustement echoue. Limite du flux
# (tirage dont une autre statistique du catalogue complet echoue, retenu ici
# et ecarte par usp_bootstrap()), cout et mesure : en-tete, volet B, point 3.
chaine <- function(x, y, graine, B) {
  fb <- tryCatch(usp_ajuster(x, y), error = function(e) e)
  if (inherits(fb, "error")) return(list(ecart = "usp_ajuster() en erreur"))
  e_obs <- .usp_contexte_mc(fb$x, fb$y, fb$z, fb$pi)
  so <- tryCatch(.mc_evaluer(USP_CATALOGUE_MC, e_obs), error = function(e) e)
  if (inherits(so, "error")) return(list(ecart = "statistiques observ\u00e9es en erreur"))
  bt <- boucle_reduite(fb, graine, B, USP_CATALOGUE_MC[LIG_B])
  mc <- rejeu_p_mc_v3h(fb, bt$sim, bt$retenu, bt$delta, so[LIG_B], e_obs, B, graine,
                       evaluer = function(yb, f) .mc_evaluer(USP_CATALOGUE_MC[LIG_B],
                                                             .usp_contexte_mc(fb$x, yb, f$z, f$pi)))
  p_mc <- err_mc <- p_min_mc <- so * NA_real_
  # Statistiques hors des douze, non simulees par la boucle reduite : motif
  # MOTIF_MC_AUCUNE_REPLIC explicite, add() refusant une p Monte-Carlo
  # absente sans motif (#181) ; leurs lignes ne sont pas lues.
  motif <- stats::setNames(rep(MOTIF_MC_AUCUNE_REPLIC, length(so)), names(so))
  p_mc[LIG_B] <- mc$p_mc; err_mc[LIG_B] <- mc$err_mc; motif[LIG_B] <- mc$motif_mc
  # Plancher Monte-Carlo (#125) : sans lui, add() appliquerait la branche de
  # la regle R1 qui lit p_min (#262, complement de la revue finale d'E2b).
  p_min_mc[LIG_B] <- mc$p_min_mc
  boot <- list(stats_obs = as.list(so), p_mc = p_mc, err_mc = err_mc, motif_mc = motif,
               p_min_mc = p_min_mc, p_mc_regime = mc$p_mc_regime)
  tt <- usp_tests(fb, boot, ALPHA, theta_equiv = THETA_EQUIV, methode = METHODE)
  list(fit = fb, tests = tt, lignes = lignes_tests(engine_table_tests(list(tests = tt))),
       motif_mc = mc$motif_mc, boucle = bt, regime = code_regime(fb),
       # variante de la p Monte-Carlo (V1 ou V3b, #240) et arret du flux V3b
       # ("cible" ou "B_max"), comptes par compter_chaine() (#274)
       variante = mc$p_mc_regime$variante,
       arret = if (is.null(mc$p_mc_regime$arret)) NA_character_ else mc$p_mc_regime$arret)
}

# Comptes d'une replication (cles "|" ; aucun tabulateur).
nettoyer_cle <- function(s) gsub("[|\t\r\n]", " ", s)
compter_chaine <- function(cpt, pt, ch) {
  ajoute <- function(cle, v = 1) { cpt[cle] <<- (if (cle %in% names(cpt)) cpt[[cle]] else 0) + v }
  ajoute(paste0("n|", pt))
  if (!is.null(ch$ecart)) { ajoute(paste0("ecart|", pt, "|", nettoyer_cle(ch$ecart))); return(cpt) }
  ajoute(paste0("reg|", pt, "|", ch$regime))
  # Variante de la p Monte-Carlo par regime (#274) : V3b attendue a delta
  # chapeau* interieur (volumes non constants), V1 sinon ; arret du flux V3b.
  ajoute(sprintf("var|%s|%s|%s", pt, ch$regime, nettoyer_cle(ch$variante)))
  if (!is.na(ch$arret)) ajoute(sprintf("arret|%s|%s", pt, nettoyer_cle(ch$arret)))
  ajoute(paste0("bperdu|", pt), sum(!is.finite(ch$boucle$z_boot[, 1])))
  for (k in LIG_B) {
    l <- ch$lignes[[k]]
    # Motif Monte-Carlo compte des qu'il existe, p retenue ou non (B3).
    if (!is.na(ch$motif_mc[[k]])) ajoute(sprintf("mmc|%s|%s|%s", pt, k, nettoyer_cle(ch$motif_mc[[k]])))
    if (isTRUE(l$inoperant)) {
      # Test inoperant (regle R1, champ inoperant, #129 ; #274) : diagnostic
      # INFO, sans p retenue ; plancher lu par R1 : p_min_mc (branche
      # Monte-Carlo, #125, champ p_min_mc fini) ou p_min (loi de reference).
      ajoute(sprintf("inop|%s|%s|%s", pt, k, ch$regime))
      ajoute(sprintf("inopbase|%s|%s|%s", pt, k, if (is.finite(l$p_min_mc)) "p_min_mc" else "p_min"))
    } else if (is.finite(l$p_retenue)) {
      ajoute(sprintf("v|%s|%s|%s|%s", pt, k, ch$regime, l$verdict))
      # Nature de la p retenue : exacte, Monte-Carlo V1, Monte-Carlo
      # conditionnelle au regime interieur (V3b, NATURE_MC_REGIME_INTERIEUR), autre.
      nat <- if (identical(l$nature_p, "exacte")) "exacte"
             else if (identical(l$nature_p, NATURE_MC_REGIME_INTERIEUR)) "mcv3b"
             else if (startsWith(l$nature_p, "Monte-Carlo")) "mc" else "autre"
      ajoute(sprintf("nat|%s|%s|%s", pt, k, nat))
    } else {
      ajoute(sprintf("nareg|%s|%s|%s", pt, k, ch$regime))
      m <- ch$motif_mc[[k]]
      motif <- if (!identical(l$type, "test"))
        sprintf("ligne %s : %s", l$type, substr(sub("[.;:].*$", "", l$commentaire), 1, 80))
      else if (!is.na(m)) sprintf("Monte-Carlo : %s", m) else NA_character_
      if (is.na(motif)) ajoute(sprintf("sansmotif|%s|%s", pt, k))
      else ajoute(sprintf("na|%s|%s|%s", pt, k, nettoyer_cle(motif)))
    }
  }
  cpt
}

# Tableaux du volet B a partir des comptes ; rend aussi les echecs des
# criteres 4 et 5 (evalues seulement si `complet`). Depuis #274 : douze
# lignes (LIG_B), tests inoperants (regle R1) comptes a part, nature de la p
# retenue ventilee V1 / V3b, chaine des verdicts a delta chapeau* interieur
# (B5) et part des tests inoperants (B6).
tableaux_chaine <- function(cpt, R, B, complet) {
  g <- function(n) if (n %in% names(cpt)) cpt[[n]] else 0
  kv <- function(pt, k, reg = names(REGIMES), v) sum(vapply(reg, function(r)
    sum(vapply(v, function(vv) g(sprintf("v|%s|%s|%s|%s", pt, k, r, vv)), numeric(1))), numeric(1)))
  # tests inoperants et p manquantes, par regime
  ki <- function(pt, k, reg = names(REGIMES)) sum(vapply(reg, function(r) g(sprintf("inop|%s|%s|%s", pt, k, r)), numeric(1)))
  km <- function(pt, k, reg = names(REGIMES)) sum(vapply(reg, function(r) g(sprintf("nareg|%s|%s|%s", pt, k, r)), numeric(1)))
  # replications non ecartees du point, par regime
  nreg <- function(pt, reg = names(REGIMES)) sum(vapply(reg, function(r) g(sprintf("reg|%s|%s", pt, r)), numeric(1)))
  NAT <- c("exacte", "mc", "mcv3b", "autre")
  txt_nat <- function(pt, k) paste(vapply(NAT, function(nt) sprintf("%.0f", g(sprintf("nat|%s|%s|%s", pt, k, nt))), ""),
                                   collapse = " / ")
  L <- c("### B1 -- taux de rejet de la p retenue (p < \u03b1 = 0,10 : verdict ALERTE ou ECHEC)", "",
         entete_md(c("Point", "Ligne", "n", "Rejets", "Taux", "IC 95 % (C-P)", "dont ALERTE", "dont ECHEC",
                     "p exacte / MC V1 / MC V3b / autre", "Inop\u00e9rants (R1, INFO)",
                     "Taux, inop\u00e9rants compt\u00e9s non-rejets", "IC 95 % (C-P)", "p manquantes (motif en B3)")))
  echecs4 <- inop4 <- ok4 <- character(0)
  crit4 <- character(0)
  for (pt in names(POINTS_B)) for (k in LIG_B) {
    n <- kv(pt, k, v = c("OK", "ALERTE", "ECHEC")); ka <- kv(pt, k, v = "ALERTE"); ke <- kv(pt, k, v = "ECHEC")
    ci <- ic_cp(ka + ke, n)
    na_k <- sum(cpt[grepl(sprintf("^(na|sansmotif)\\|%s\\|%s(\\||$)", gsub("([.+])", "\\\\\\1", pt), k), names(cpt))])
    ni <- ki(pt, k)
    L <- c(L, ligne_md(POINTS_B[[pt]]$lib, LIB_COURT[[k]], n, ka + ke, taux(ka + ke, n), txt_ic(ci), ka, ke,
                       txt_nat(pt, k), ni, taux(ka + ke, n + ni), txt_ic(ic_cp(ka + ke, n + ni)), na_k))
    if (complet && pt == "N") {
      # Critere 4 : borne inferieure unilaterale a 99,9 % ; inoperant si
      # meme n rejets sur n ne la porteraient pas au-dessus de alpha.
      lb <- borne_inf(ka + ke, n); lb_max <- borne_inf(n, n)
      st <- if (n == 0 || lb_max <= ALPHA) "inop\u00e9rant (n trop petit)"
            else if (lb > ALPHA) "**ECHEC** (sur-rejet)" else "v\u00e9rifi\u00e9"
      crit4 <- c(crit4, ligne_md(LIB_COURT[[k]], n, ka + ke, num(lb, 4), num(lb_max, 4), st))
      if (n == 0 || lb_max <= ALPHA) inop4 <- c(inop4, LIB_COURT[[k]])
      else if (lb > ALPHA) echecs4 <- c(echecs4, sprintf("%s (borne inf\u00e9rieure %s > \u03b1)", LIB_COURT[[k]], num(lb, 4)))
      else ok4 <- c(ok4, LIB_COURT[[k]])
    }
  }
  L <- c(L, "", sprintf(paste("n : r\u00e9plications (sur %d par point) o\u00f9 la ligne a une p retenue ; une r\u00e9plication",
                              "\u00e9cart\u00e9e, un test inop\u00e9rant ou une p manquante ne compte ni comme rejet ni comme",
                              "non-rejet dans le taux. Colonne \u00ab inop\u00e9rants compt\u00e9s non-rejets \u00bb : taux sur n +",
                              "inop\u00e9rants (un test inop\u00e9rant, restitu\u00e9 en diagnostic INFO par la r\u00e8gle R1, ne peut pas",
                              "rejeter), soit le taux de verdicts ALERTE ou ECHEC restitu\u00e9s par le moteur.",
                              "IC : incertitude Monte-Carlo sur le taux (fonction de R), pas l'erreur",
                              "d'approximation en T. La p retenue est exacte \u00e0 \u03c0\u0302* constant (r\u00e8gle R7 ;",
                              "jamais pour les ratios bruts de Durbin-Watson ni pour les six lignes de stabilit\u00e9),",
                              "Monte-Carlo \u00e0 B = %d sinon : V1 (toutes les r\u00e9plications du bootstrap) \u00e0 \u03b4\u0302* au bord,",
                              "V3b (conditionnelle au r\u00e9gime int\u00e9rieur, #240) \u00e0 \u03b4\u0302* int\u00e9rieur et volumes non",
                              "constants (variante V3h du moteur)."), R, B), "",
         "### B2 -- ventilation par r\u00e9gime du r\u00e9ajustement (taux de rejet, rejets / n)", "",
         entete_md(c("Point", "R\u00e9gime", "R\u00e9plications", "Variante V1 / V3b", LIB_COURT[LIG_B])))
  for (pt in names(POINTS_B)) for (r in names(REGIMES)) {
    nr <- g(sprintf("reg|%s|%s", pt, r))
    cel <- vapply(LIG_B, function(k) {
      n <- kv(pt, k, r, c("OK", "ALERTE", "ECHEC")); kk <- kv(pt, k, r, c("ALERTE", "ECHEC"))
      if (n > 0) sprintf("%s (%.0f / %.0f)", num(kk / n), kk, n) else "\u2014"
    }, "")
    L <- c(L, ligne_md(POINTS_B[[pt]]$lib, REGIMES[[r]], nr,
                       sprintf("%.0f / %.0f", g(sprintf("var|%s|%s|V1", pt, r)), g(sprintf("var|%s|%s|V3b", pt, r))),
                       paste(cel, collapse = " | ")))
  }
  arr <- vapply(names(POINTS_B), function(pt) sprintf("%s : %.0f / %.0f", POINTS_B[[pt]]$lib,
                                                       g(sprintf("arret|%s|cible", pt)), g(sprintf("arret|%s|B_max", pt))), "")
  L <- c(L, "", paste0("Arr\u00eat du flux V3b (cible B atteinte / plafond FACTEUR_B_MAX_REGIME (B + 1) atteint), par point : ",
                       paste(arr, collapse = " ; "), "."), "")
  L <- c(L, "", "### B3 -- r\u00e9plications \u00e9cart\u00e9es et p manquantes (motifs compt\u00e9s)", "")
  cles_m <- grep("^(ecart|na|sansmotif)\\|", names(cpt), value = TRUE)
  if (!length(cles_m)) L <- c(L, "Aucune r\u00e9plication \u00e9cart\u00e9e, aucune p manquante.")
  else {
    L <- c(L, entete_md(c("Nature", "Point", "Ligne", "Motif", "Nombre")))
    for (cl in cles_m) {
      p <- strsplit(cl, "|", fixed = TRUE)[[1]]
      L <- c(L, switch(p[1],
        ecart = ligne_md("r\u00e9plication \u00e9cart\u00e9e", POINTS_B[[p[2]]]$lib, "toutes", p[3], cpt[[cl]]),
        na = ligne_md("p manquante", POINTS_B[[p[2]]]$lib, LIB_COURT[[p[3]]], p[4], cpt[[cl]]),
        sansmotif = ligne_md("**p manquante sans motif**", POINTS_B[[p[2]]]$lib, LIB_COURT[[p[3]]], "\u2014", cpt[[cl]])))
    }
  }
  cles_mmc <- grep("^mmc\\|", names(cpt), value = TRUE)
  L <- c(L, "", "Motifs Monte-Carlo (motif_mc non NA, que la p retenue existe ou non) :", "")
  if (!length(cles_mmc)) L <- c(L, "aucun.")
  else {
    L <- c(L, entete_md(c("Point", "Ligne", "Motif", "Nombre")))
    for (cl in cles_mmc) {
      p <- strsplit(cl, "|", fixed = TRUE)[[1]]
      L <- c(L, ligne_md(POINTS_B[[p[2]]]$lib, LIB_COURT[[p[3]]], p[4], cpt[[cl]]))
    }
  }
  bp <- sum(cpt[grep("^bperdu\\|", names(cpt))])
  L <- c(L, "", sprintf(paste("R\u00e9plications internes du bootstrap \u00e9cart\u00e9es (r\u00e9ajustement ou l'une des douze",
                              "statistiques en erreur), tous points confondus : %.0f. \u00c9cart connu \u00e0 usp_bootstrap(),",
                              "non compt\u00e9 : une r\u00e9plication interne o\u00f9 une autre statistique du catalogue complet",
                              "\u00e9chouerait est gard\u00e9e ici et \u00e9cart\u00e9e par usp_bootstrap() (identit\u00e9 contr\u00f4l\u00e9e sur",
                              "les jeux observ\u00e9s seulement)."), bp), "")
  # B5 (#274) : chaine des verdicts a delta chapeau* interieur, ou le moteur
  # retient la p conditionnelle au regime (V3b) ; repartition des verdicts
  # restitues (OK, ALERTE, ECHEC, INFO inoperant, sans p retenue).
  L <- c(L, "### B5 -- cha\u00eene des verdicts \u00e0 \u03b4\u0302* int\u00e9rieur (p conditionnelle au r\u00e9gime, V3b ; #274)", "",
         entete_md(c("Point", "Ligne", "R\u00e9plications \u00e0 \u03b4\u0302* int\u00e9rieur", "OK", "ALERTE", "ECHEC",
                     "INFO (inop\u00e9rant, R1)", "Sans p retenue", "Taux de rejet (p retenue)", "IC 95 % (C-P)",
                     "p exacte / MC V1 / MC V3b / autre (tous r\u00e9gimes)")))
  for (pt in names(POINTS_B)) for (k in LIG_B) {
    r <- "interieur"
    ko <- kv(pt, k, r, "OK"); ka <- kv(pt, k, r, "ALERTE"); ke <- kv(pt, k, r, "ECHEC")
    L <- c(L, ligne_md(POINTS_B[[pt]]$lib, LIB_COURT[[k]], nreg(pt, r), ko, ka, ke, ki(pt, k, r), km(pt, k, r),
                       taux(ka + ke, ko + ka + ke), txt_ic(ic_cp(ka + ke, ko + ka + ke)), txt_nat(pt, k)))
  }
  L <- c(L, "", paste("R\u00e9plications \u00e0 \u03b4\u0302* int\u00e9rieur = OK + ALERTE + ECHEC + INFO + sans p retenue (contr\u00f4le",
                      "d'int\u00e9grit\u00e9). Sans p retenue : Monte-Carlo indisponible (motif en B3, par exemple r\u00e9gime",
                      "int\u00e9rieur trop rare sous l'ajustement de la r\u00e9plication), ligne restitu\u00e9e en diagnostic."), "",
         "### B6 -- part des tests inop\u00e9rants (r\u00e8gle R1, champ inoperant ; #274)", "",
         entete_md(c("Point", "Ligne", "R\u00e9plications non \u00e9cart\u00e9es", "Inop\u00e9rants", "Part", "IC 95 % (C-P)",
                     paste0("dont ", REGIMES), "Plancher lu par R1 : p_min / p_min_mc")))
  for (pt in names(POINTS_B)) for (k in LIG_B) {
    nn <- nreg(pt); ni <- ki(pt, k)
    par_r <- vapply(names(REGIMES), function(r) sprintf("%.0f / %.0f", ki(pt, k, r), nreg(pt, r)), "")
    L <- c(L, ligne_md(POINTS_B[[pt]]$lib, LIB_COURT[[k]], nn, ni, taux(ni, nn), txt_ic(ic_cp(ni, nn)),
                       paste(par_r, collapse = " | "),
                       sprintf("%.0f / %.0f", g(sprintf("inopbase|%s|%s|p_min", pt, k)),
                               g(sprintf("inopbase|%s|%s|p_min_mc", pt, k)))))
  }
  L <- c(L, "", paste("Inop\u00e9rant : la r\u00e8gle R1 bascule la ligne en diagnostic INFO, sans verdict, quand la plus petite",
                      "p-value atteignable est \u2265 \u03b1 : p_min (loi de r\u00e9f\u00e9rence, p exacte retenue) ou p_min_mc",
                      "(plancher Monte-Carlo sur les r\u00e9plications tir\u00e9es, p Monte-Carlo retenue, #125). Colonnes",
                      "\u00ab dont \u00bb : inop\u00e9rants / r\u00e9plications du r\u00e9gime de \u03b4\u0302*."), "")
  # Integrite des comptes (#274) : par point, ligne et regime, OK + ALERTE +
  # ECHEC + INFO inoperant + sans p retenue = replications du regime.
  echecs_cpt <- character(0)
  for (pt in names(POINTS_B)) for (k in LIG_B) for (r in names(REGIMES))
    if (kv(pt, k, r, c("OK", "ALERTE", "ECHEC")) + ki(pt, k, r) + km(pt, k, r) != nreg(pt, r) ||
        kv(pt, k, r, "INFO") != 0)
      echecs_cpt <- c(echecs_cpt, sprintf("%s/%s/%s", pt, k, r))
  if (complet)
    L <- c(L, "### B4 -- crit\u00e8re 4 : niveau de la ligne N (borne inf\u00e9rieure unilat\u00e9rale de Clopper-Pearson \u00e0 99,9 % \u2264 \u03b1)", "",
           entete_md(c("Ligne", "n", "Rejets", "Borne inf. 99,9 %", "Borne max. (n rejets sur n)", "Statut")),
           crit4, "",
           "Inop\u00e9rant (n trop petit) : m\u00eame n rejets sur n ne porteraient pas la borne au-dessus de \u03b1 ; la ligne n'est pas v\u00e9rifi\u00e9e.", "")
  echecs5 <- grep("^sansmotif\\|", names(cpt), value = TRUE)
  list(lignes = L, echecs4 = echecs4, inop4 = inop4, ok4 = ok4, echecs5 = echecs5, echecs_cpt = echecs_cpt)
}

statut_b <- function() paste(
  "Statut : **constat de simulation sous des alternatives choisies, hors mod\u00e8le r\u00e9glementaire** (issues #116",
  "et #274, volet B). Chaque r\u00e9plication suit la cha\u00eene du moteur courant, r\u00e9duite : usp_ajuster(), boucle",
  "bootstrap de usp_bootstrap() r\u00e9duite aux douze statistiques (six de #116, six de stabilit\u00e9 de #313),",
  "p Monte-Carlo par engine_p_mc() selon la variante V3h (V3b \u00e0 \u03b4\u0302* int\u00e9rieur, #240), plancher",
  "Monte-Carlo p_min_mc de la r\u00e8gle R1 (#125), p retenue et verdict par usp_tests(). Alternatives sur le mod\u00e8le ajust\u00e9 au jeu (\u03b2\u0302, \u03c0\u0302_t, x_t gard\u00e9s ; \u03b5",
  "remplac\u00e9, amplitudes en \u00e9carts-types de ln r_t) : protocole dans l'en-t\u00eate de tests/puissance_t8.R.",
  "La ligne N donne le niveau observ\u00e9 de la p retenue.")

LIBELLES_CONTEXTE <- c(
  jeu = "Jeu", modele = "Mod\u00e8le ajust\u00e9 (usp_ajuster())", configuration = "Configuration",
  points = "Points", graines = "Graines", B = "B du bootstrap", generateur = "G\u00e9n\u00e9rateur",
  commit = "Commit", plateforme = "Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)",
  empreintes = "Empreintes md5 du code ex\u00e9cut\u00e9")

# --- Mode --combiner (lire_comptes(), refuser() : copies adaptees de
# tests/taux_franchissement_reperes.R) -------------------------------------------------
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
  ctx <- champs("CONTEXTE")
  if (!length(ctx) || any(lengths(ctx) != 2L)) refuser(f, " : lignes CONTEXTE absentes ou illisibles")
  ctx <- stats::setNames(vapply(ctx, `[`, "", 2L), vapply(ctx, `[`, "", 1L))
  if (!setequal(names(ctx), names(LIBELLES_CONTEXTE)) || anyDuplicated(names(ctx)))
    refuser(f, " : lignes CONTEXTE incompletes (attendues : ", paste(names(LIBELLES_CONTEXTE), collapse = ", "), ")")
  list(parametres = par, debut = as.integer(tr[1]), fin = as.integer(tr[2]), contexte = ctx[names(LIBELLES_CONTEXTE)],
       comptes = stats::setNames(as.numeric(vapply(cp, `[`, "", 2L)), vapply(cp, `[`, "", 1L)))
}
lignes_contexte <- function(ctx) vapply(names(LIBELLES_CONTEXTE), function(k)
  ligne_md(LIBELLES_CONTEXTE[[k]], ctx[[k]]), "")

if (length(FICHIERS_COMB)) {
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
  R_tot <- as.integer(sub("^.*;R_chaine=([0-9]+);.*$", "\\1", par))
  jeu_c <- sub("^.*jeu=(J[12]);.*$", "\\1", par)
  idx <- unlist(lapply(parts, function(p) seq.int(p$debut, p$fin)))
  if (anyDuplicated(idx) || !setequal(idx, seq_len(R_tot)))
    refuser("les tranches ne couvrent pas 1..", R_tot, " exactement une fois")
  cles <- unique(unlist(lapply(parts, function(p) names(p$comptes))))
  cpt <- stats::setNames(vapply(cles, function(k) sum(vapply(parts, function(p)
    if (k %in% names(p$comptes)) p$comptes[[k]] else 0, numeric(1))), numeric(1)), cles)
  B_c <- as.integer(sub("^.*;B=([0-9]+);.*$", "\\1", par))
  tb <- tableaux_chaine(cpt, R_tot, B_c, TRUE)
  ok4 <- !length(tb$echecs4); ok5 <- !length(tb$echecs5) && !length(tb$echecs_cpt)
  sortie <- c(sprintf("## Puissance \u00e0 T = 8, volet B (cha\u00eene r\u00e9duite), jeu %s -- combinaison de %d tranche(s) (issues #116, #274)",
                      jeu_c, length(parts)), "",
              sprintf("Param\u00e8tres : %s", par), "", statut_b(), "",
              "### T0 -- contexte (identique dans toutes les tranches, v\u00e9rifi\u00e9)", "",
              entete_md(c("Grandeur", "Valeur")),
              lignes_contexte(ctx),
              ligne_md("R\u00e9plications par point", sprintf("%d (%d tranche(s) : %s)", R_tot, length(parts),
                                                             paste(vapply(parts, function(p) sprintf("%d-%d", p$debut, p$fin), ""),
                                                                   collapse = ", "))),
              ligne_md("Commit de la combinaison", commit_depot("tests/puissance_t8.R")),
              ligne_md("Empreintes md5 du combinateur", EMPREINTES),
              ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9 des tranches (crit\u00e8res 3, 5, 6 ; ligne N = usp_simuler())",
                       sprintf("OK dans les %d tranche(s)", length(parts))), "",
              tb$lignes,
              "### Crit\u00e8res bloquants \u00e9valu\u00e9s \u00e0 la combinaison", "",
              sprintf("- Crit\u00e8re 4, niveau du volet B (ligne N, borne inf\u00e9rieure unilat\u00e9rale 99,9 %% \u2264 \u03b1) : %s",
                      texte_crit4(tb)),
              sprintf("- Crit\u00e8re 5, aucune p manquante hors motif compt\u00e9, comptes coh\u00e9rents (#274) : %s",
                      if (ok5) "OK" else paste("ECHEC :", paste(c(tb$echecs5, tb$echecs_cpt), collapse = " ; "))), "")
  ecrire_console(sortie)
  if (ok4 && ok5) ecrire_fichiers(stats::setNames(list(sortie), paste0("chaine-", jeu_c)), ctx[["commit"]],
                                  ctx[["empreintes"]], combinaison = TRUE)
  quit(status = if (ok4 && ok5) 0L else 1L)
}

###############################################################################
#  VOLET A
###############################################################################
SORTIE_A <- NULL
SORTIE_S <- NULL                   # lignes de stabilite (#313)
RES_OBS <- list()                  # run_engine() par jeu, partage avec le volet B
if (OPT_VOLET %in% c("tout", "A")) {
  t_a <- Sys.time()
  JEU_A <- charger_jeu("J1")
  X <- JEU_A$x
  FIT_A <- usp_ajuster(X, JEU_A$y)
  controle(isTRUE(usp_regime(FIT_A$delta, X)$pi_constant),
           "Volet A, pr\u00e9requis : \u03c0\u0302 constant sur J1 (usp_regime())")
  GRP <- X > stats::median(X)

  # Tailles exactes a T = 8 sans ex aequo, par enumeration avec les fonctions
  # du moteur, rapprochees de la specification (5 decimales).
  cmb <- utils::combn(T_, T_ / 2)
  taille_runs <- function(a) mean(apply(cmb, 2, function(c) {
    v <- rep(-1, T_); v[c] <- 1
    runs_p_exacte(v + seq_len(T_) * 1e-3) < a
  }))
  taille_sm <- function(a) mean(apply(cmb, 2, function(c) {
    g <- seq_len(T_) %in% c
    stats::ks.test(seq_len(T_)[g], seq_len(T_)[!g])$p.value < a
  }))
  taille_mk <- function(a) {
    d <- .mk_loi_exacte(T_)
    p <- vapply(d$S, function(s) sum(d$prob[abs(d$S) >= abs(s) - 1e-9]), numeric(1))
    sum(d$prob[p < a])
  }
  TAILLE <- rbind(
    Runs    = c(taille_runs(ALPHA), taille_runs(ALPHA2)),
    DW      = c(ALPHA, ALPHA2),
    MK      = c(taille_mk(ALPHA), taille_mk(ALPHA2)),
    Smirnov = c(taille_sm(ALPHA), taille_sm(ALPHA2)))
  TAILLE_SPEC <- rbind(Runs = c(4 / 70, 0), DW = c(0.100, 0.050), MK = c(0.06101, 0.03115),
                       Smirnov = c(2 / 70, 2 / 70))
  controle(all(abs(TAILLE - TAILLE_SPEC) < 5e-6),
           "Volet A, tailles exactes \u00e9num\u00e9r\u00e9es \u00e9gales \u00e0 celles de la sp\u00e9cification (\u00e0 5e-6)")

  # p exactes d'une serie y (regime pi constant, sans reajustement).
  p_exactes_a <- function(y) {
    r <- y / X; lr <- log(r); l <- lr - mean(lr); u <- r - mean(r)
    la <- engine_aplatir_ex_aequo(l)
    c(Runs = runs_p_exacte(l), Runsr = runs_p_exacte(u), DW = dw_p_exacte(l), MK = mk_p_exacte(r),
      Smirnov = if (anyDuplicated(la)) NA_real_ else
        suppressWarnings(stats::ks.test(la[GRP], la[!GRP])$p.value))
  }

  # Critere 3 (volet A) : p sur J1 observe = p_exacte de run_engine().
  t_ca <- Sys.time()
  RES_OBS$J1 <- engine_observe(JEU_A)
  l_obs <- lignes_tests(engine_table_tests(RES_OBS$J1))
  p_obs <- p_exactes_a(JEU_A$y)
  controle(identical(unname(p_obs[["Runs"]]), l_obs$Runs$p_exacte) &&
             identical(unname(p_obs[["Runsr"]]), l_obs$Runsr$p_exacte) &&
             isTRUE(all.equal(unname(p_obs[["DW"]]), l_obs$DW$p_exacte, tolerance = 1e-10)) &&
             identical(unname(p_obs[["MK"]]), l_obs$MK$p_exacte) &&
             identical(unname(p_obs[["Smirnov"]]), l_obs$Smirnov$p_exacte),
           "Crit\u00e8re 3, volet A : p exactes sur l, u, r de J1 observ\u00e9 = p_exacte de run_engine() (DW \u00e0 1e-10)")

  # --- Lignes de stabilite (#313) : loi nulle S0 et p Monte-Carlo ------------
  # Statistiques par les entrees du catalogue (z remplace par l*, voir
  # l'en-tete) ; transcription de la formule de engine_p_mc() valable en
  # queue haute, sans condition degenere ni extremes : verifie ici.
  stopifnot(all(vapply(CAT_STAB, function(en) identical(en$queue, "haut") && is.null(en$degenere) &&
                         is.null(en$non_definie) && is.null(en$extremes), logical(1))))
  stats_stab_a <- function(y) {
    lr <- log(y / X)
    .mc_evaluer(CAT_STAB, .usp_contexte_mc(X, y, lr - mean(lr), FIT_A$pi))
  }
  t_s0 <- Sys.time()
  S0 <- engine_sous_graine(OPT_GRAINE + 2, t(vapply(seq_len(OPT_R_NULLE), function(b)
    stats_stab_a(usp_simuler(FIT_A)), numeric(length(STAB)))))
  colnames(S0) <- STAB
  duree_s0 <- as.numeric(difftime(Sys.time(), t_s0, units = "secs"))
  controle(all(is.finite(S0)), sprintf("Volet A, lignes de stabilit\u00e9 : loi nulle S0 enti\u00e8rement finie (%d valeur(s) non finie(s))",
                                       sum(!is.finite(S0))))
  S0_TRI <- lapply(STAB, function(k) sort(S0[, k])); names(S0_TRI) <- STAB
  # p = (1 + #{S0 >= s}) / (R0 + 1) ; findInterval(left.open = TRUE) compte
  # les S0 < s. NA si s n'est pas finie.
  p_mc_s0 <- function(s, tri) ifelse(is.finite(s),
                                     (1 + length(tri) - findInterval(s, tri, left.open = TRUE)) / (length(tri) + 1),
                                     NA_real_)
  # Effet de B (S7, reserve C1 d'actuary) : p_i sur S0 -> u_i = #{S0 >= s} / R0
  # ; a B fini, rejet si K <= ceiling(alpha (B + 1)) - 2, K ~ Bin(B, u_i) ;
  # moyenne des probabilites exactes (aucun tirage).
  taux_b_fini <- function(p, a) {
    p <- p[is.finite(p)]
    u <- ((OPT_R_NULLE + 1) * p - 1) / OPT_R_NULLE
    mean(stats::pbinom(ceiling(a * (OPT_B + 1)) - 2, OPT_B, u))
  }
  p_stab_a <- function(y) {
    st <- stats_stab_a(y)
    vapply(STAB, function(k) p_mc_s0(st[[k]], S0_TRI[[k]]), numeric(1))
  }
  # Critere 3 (#313) : statistiques de J1 observe = boot$stats_obs de
  # run_engine() (u : identical() ; l* au lieu de z : all.equal() a 1e-10).
  st_obs <- stats_stab_a(JEU_A$y)
  so_re <- unlist(RES_OBS$J1$bootstrap$stats_obs[STAB])
  controle(identical(unname(st_obs[c("supFr", "CUSUMr", "Grubbsr")]), unname(so_re[c("supFr", "CUSUMr", "Grubbsr")])) &&
             isTRUE(all.equal(unname(st_obs[c("supF", "CUSUM", "Grubbs")]), unname(so_re[c("supF", "CUSUM", "Grubbs")]),
                              tolerance = 1e-10)),
           paste("Crit\u00e8re 3, volet A (#313) : statistiques de stabilit\u00e9 de J1 observ\u00e9 (catalogue sur l* et u)",
                 "= stats_obs de run_engine() (u identiques ; l* \u00e0 1e-10)"))
  P_OBS_STAB <- p_stab_a(JEU_A$y)

  # Matrice e unique, tiree avant tout calcul ; ligne N = usp_simuler(FIT_A).
  E_A <- tirer_e(OPT_GRAINE, OPT_R)
  Y_N <- t(apply(E_A, 1, function(e) simuler_alt(FIT_A, e)))
  controle(identical(Y_N, engine_sous_graine(OPT_GRAINE, t(vapply(seq_len(OPT_R), function(b) usp_simuler(FIT_A),
                                                                   numeric(T_))))),
           "Crit\u00e8re 3, volet A : ligne N identique \u00e0 usp_simuler(FIT0) (m\u00eame graine, au bit pr\u00e8s)")
  DUREE_CONTROLES <- DUREE_CONTROLES + as.numeric(difftime(Sys.time(), t_ca, units = "secs"))

  t_rep_a <- Sys.time()
  KA <- list()
  KS <- list()                       # lignes de stabilite (#313)
  n_runsr_diff <- 0
  ok_p_engine <- NA
  for (pt in names(POINTS_A)) {
    phi <- POINTS_A[[pt]]$phi
    P <- vapply(seq_len(OPT_R), function(b) {
      y <- simuler_alt(FIT_A, phi(E_A[b, ], X, b))
      c(p_exactes_a(y), p_stab_a(y))
    }, numeric(5 + length(STAB)))
    PS <- P[STAB, , drop = FALSE]; P <- P[1:5, , drop = FALSE]
    n_runsr_diff <- n_runsr_diff + sum(!mapply(identical, P["Runs", ], P["Runsr", ]))
    KA[[pt]] <- list(
      n  = apply(P, 1, function(p) sum(is.finite(p))),
      k1 = apply(P, 1, function(p) sum(p[is.finite(p)] < ALPHA)),
      k2 = apply(P, 1, function(p) sum(p[is.finite(p)] < ALPHA2)))
    KS[[pt]] <- list(
      n  = apply(PS, 1, function(p) sum(is.finite(p))),
      k1 = apply(PS, 1, function(p) sum(p[is.finite(p)] < ALPHA)),
      k2 = apply(PS, 1, function(p) sum(p[is.finite(p)] < ALPHA2)),
      # desaccords de rejet z / ratios bruts a alpha = 0,10
      dz = vapply(c("supF", "CUSUM", "Grubbs"), function(k)
        sum((PS[k, ] < ALPHA) != (PS[paste0(k, "r"), ] < ALPHA), na.rm = TRUE), numeric(1)),
      # effet de B (S7) : taux de rejet exact a B = OPT_B, conditionnel a S0
      tb1 = apply(PS, 1, taux_b_fini, a = ALPHA),
      tb2 = apply(PS, 1, taux_b_fini, a = ALPHA2))
    # Critere 3 (#313) : p par findInterval() = engine_p_mc() sur les 200
    # premieres replications de la ligne N (y recalcules, memes e).
    if (pt == "N") {
      ok_p_engine <- all(vapply(seq_len(min(200L, OPT_R)), function(b) {
        st <- stats_stab_a(simuler_alt(FIT_A, phi(E_A[b, ], X, b)))
        all(vapply(STAB, function(k) identical(engine_p_mc(S0[, k], st[[k]], CAT_STAB[[k]]$queue)$p_mc,
                                               unname(PS[k, b])), logical(1)))
      }, logical(1)))
    }
  }
  duree_rep_a <- as.numeric(difftime(Sys.time(), t_rep_a, units = "secs"))
  controle(isTRUE(ok_p_engine),
           sprintf("Crit\u00e8re 3, volet A (#313) : p des lignes de stabilit\u00e9 par findInterval() identiques \u00e0 engine_p_mc() (ligne N, %d r\u00e9plications)",
                   min(200L, OPT_R)))
  controle(n_runsr_diff == 0,
           sprintf("Crit\u00e8re 2, identit\u00e9 Runs / Runsr r\u00e9plication par r\u00e9plication (%.0f diff\u00e9rence(s) sur %d)",
                   n_runsr_diff, OPT_R * length(POINTS_A)))
  n_na_a <- sum(vapply(KA, function(k) sum(OPT_R - k$n), numeric(1)))
  controle(n_na_a == 0, sprintf("Crit\u00e8re 5, volet A : aucune p exacte manquante (%.0f manquante(s))", n_na_a))
  n_na_s <- sum(vapply(KS, function(k) sum(OPT_R - k$n), numeric(1)))
  controle(n_na_s == 0, sprintf("Crit\u00e8re 5, volet A (#313) : aucune p Monte-Carlo manquante sur les lignes de stabilit\u00e9 (%.0f manquante(s))", n_na_s))

  # Critere 1 : niveau de la ligne N.
  # IC bilateral a 99,9 % par verification (decision d'actuary du
  # 30/09/2026) ; la sortie publie aussi l'IC a 95 %. Cinq verifications :
  # suites a alpha = 0,05 inoperant (R1, p_min = 4/70), remplace par une
  # assertion d'integrite (taux exactement 0) ; Smirnov : meme evenement aux
  # deux alpha (taille 2/70), verifie une fois.
  niv <- character(0)
  for (k in rownames(TAILLE)) for (j in 1:2) {
    kk <- if (j == 1) KA$N$k1[[k]] else KA$N$k2[[k]]
    nn <- KA$N$n[[k]]
    a_txt <- num(c(ALPHA, ALPHA2)[j], 2)
    if (k == "Runs" && j == 2) {
      niv <- c(niv, ligne_md(LIB_COURT[[k]], a_txt, "inop\u00e9rant (R1, p_min = 4/70)\u00b9",
                             sprintf("%.0f / %.0f", kk, nn), num(kk / nn, 4), "\u2014", "\u2014", "hors crit\u00e8re 1"))
      controle(kk == 0, sprintf("Volet A, suites \u00e0 \u03b1 = 0,05 (inop\u00e9rant, R1) : taux exactement 0 (%.0f / %.0f)", kk, nn))
      next
    }
    ci95 <- ic_cp(kk, nn); ci <- ic_cp(kk, nn, 0.999)
    dans <- TAILLE[k, j] >= ci[1] && TAILLE[k, j] <= ci[2]
    verifie <- !(k == "Smirnov" && j == 2)
    niv <- c(niv, ligne_md(LIB_COURT[[k]], a_txt, num(TAILLE[k, j], 5),
                           sprintf("%.0f / %.0f", kk, nn), num(kk / nn, 4), txt_ic(ci95), txt_ic(ci),
                           if (!verifie) "m\u00eame \u00e9v\u00e9nement qu'\u00e0 \u03b1 = 0,10" else if (dans) "oui" else "**non**"))
    if (verifie)
      controle(dans, sprintf("Crit\u00e8re 1, niveau du volet A : %s, \u03b1 = %s, taille exacte %s dans l'IC \u00e0 99,9 %% %s",
                             LIB_COURT[[k]], a_txt, num(TAILLE[k, j], 5), txt_ic(ci)))
  }

  # Puissance de DW sous AR(1) par Imhof (statut 3 ; non bloquant, decision
  # du mainteneur : rapportee, hors code de sortie), calculee par
  # dw_puissance_ar1() (R/engine.R, #170), qui partage la construction A/M de
  # dw_p_exacte(). Un echec numerique (uniroot(), integration) est rapporte,
  # sans erreur R. Le recoupement par dw_p_exacte() aux points critiques, qui
  # reposait sur les vecteurs propres de la copie, est retire : les tests
  # unitaires de dw_puissance_ar1() (tests/unitaires/test_lois_exactes.R,
  # bloquants) controlent rho = 0 -> alpha, les valeurs publiees et un
  # recoupement par simulation.
  pts_ar <- c("N", grep("^A", names(POINTS_A), value = TRUE))
  rho_de <- function(pt) if (pt == "N") 0 else as.numeric(sub("^A", "", pt))
  IMHOF_ERREUR <- NULL
  imhof <- vapply(pts_ar, function(pt) tryCatch(dw_puissance_ar1(T_, rho_de(pt), ALPHA), error = function(e) {
    IMHOF_ERREUR <<- unique(c(IMHOF_ERREUR, conditionMessage(e))); NA_real_ }), numeric(1))
  controle(is.null(IMHOF_ERREUR), sprintf("Volet A, Imhof : dw_puissance_ar1() sans erreur%s",
                                          if (is.null(IMHOF_ERREUR)) "" else paste0(" (\u00e9chec : ", paste(IMHOF_ERREUR, collapse = " ; "), ")")),
           bloquant = FALSE)
  controle(all(is.finite(imhof)), sprintf("Volet A, Imhof : puissances calcul\u00e9es (%d / %d finies)",
                                          sum(is.finite(imhof)), length(imhof)), bloquant = FALSE)
  controle(isTRUE(abs(imhof[["N"]] - ALPHA) < 1e-6),
           sprintf("Volet A, puissance de DW par Imhof \u00e0 \u03c1 = 0 \u00e9gale \u00e0 \u03b1 (%s)", num(imhof[["N"]], 6)),
           bloquant = FALSE)

  # --- Lignes de stabilite (#313) : niveau, revue R-17, loi du moteur ------
  # Taille du test a loi nulle S0, marginalement sur S0 (statistique continue,
  # S0 et la replication i.i.d. sous la meme loi) : P((1 + K) / (R0 + 1) <
  # alpha) = (ceiling(alpha (R0 + 1)) - 1) / (R0 + 1).
  taille_s0 <- function(a) (ceiling(a * (OPT_R_NULLE + 1)) - 1) / (OPT_R_NULLE + 1)
  niv_s <- character(0)
  for (k in STAB) for (j in 1:2) {
    a <- c(ALPHA, ALPHA2)[j]
    kk <- if (j == 1) KS$N$k1[[k]] else KS$N$k2[[k]]; nn <- KS$N$n[[k]]
    ci95 <- ic_cp(kk, nn); ci <- ic_cp(kk, nn, 0.999); ta <- taille_s0(a)
    dans <- ta >= ci[1] && ta <= ci[2]
    niv_s <- c(niv_s, ligne_md(LIB_STAB[[k]], num(a, 2), num(ta, 5), sprintf("%.0f / %.0f", kk, nn), num(kk / nn, 4),
                               txt_ic(ci95), txt_ic(ci), if (dans) "oui" else "**non**"))
    controle(dans, sprintf("Volet A (#313), niveau de la ligne N : %s, \u03b1 = %s, taille %s dans l'IC \u00e0 99,9 %% %s",
                           LIB_STAB[[k]], num(a, 2), num(ta, 5), txt_ic(ci)), bloquant = FALSE)
  }
  # Effet de B (S7) : taux exact a B = OPT_B conditionnel a S0 contre S1.
  taille_b <- function(a) (ceiling(a * (OPT_B + 1)) - 1) / (OPT_B + 1)
  tab_b <- function(j) {
    a <- c(ALPHA, ALPHA2)[j]
    c(entete_md(c("Point", unlist(lapply(STAB, function(k) c(paste0(LIB_STAB[[k]], " : taux_B"), "\u0394"))))),
      vapply(names(POINTS_A), function(pt) {
        K <- KS[[pt]]; tb <- if (j == 1) K$tb1 else K$tb2; kk <- if (j == 1) K$k1 else K$k2
        v <- unlist(lapply(STAB, function(k) c(num(tb[[k]], 4),
                                               sub(".", ",", sprintf("%+.4f", tb[[k]] - kk[[k]] / K$n[[k]]), fixed = TRUE))))
        ligne_md(POINTS_A[[pt]]$lib, paste(v, collapse = " | "))
      }, ""))
  }
  for (k in STAB) for (j in 1:2) {
    a <- c(ALPHA, ALPHA2)[j]; tb <- if (j == 1) KS$N$tb1[[k]] else KS$N$tb2[[k]]; nn <- KS$N$n[[k]]
    ci <- ic_cp(round(tb * nn), nn, 0.999)
    controle(taille_b(a) >= ci[1] && taille_b(a) <= ci[2],
             sprintf("Volet A (#313), S7 ligne N : %s, \u03b1 = %s, taux_B %s, taille \u00e0 B = %d (%s) dans l'IC \u00e0 99,9 %% %s",
                     LIB_STAB[[k]], num(a, 2), num(tb, 4), OPT_B, num(taille_b(a), 4), txt_ic(ci)), bloquant = FALSE)
  }
  # Symetrie C- / C (reserve C2) : sur les lignes z, IC a 99,9 % qui se
  # recouvrent (meme loi, voir l'en-tete).
  for (l in 3:5) for (k in c("supF", "CUSUM", "Grubbs")) {
    cp <- KS[[sprintf("C%d", l)]]; cm <- KS[[sprintf("Cm%d", l)]]
    i1 <- ic_cp(cp$k1[[k]], cp$n[[k]], 0.999); i2 <- ic_cp(cm$k1[[k]], cm$n[[k]], 0.999)
    controle(i1[1] <= i2[2] && i2[1] <= i1[2],
             sprintf("Volet A (#313), sym\u00e9trie C\u2212 / C, %s, \u03bb = %d (\u03b1 = 0,10) : IC \u00e0 99,9 %% %s et %s se recouvrent",
                     LIB_STAB[[k]], l, txt_ic(i1), txt_ic(i2)), bloquant = FALSE)
  }
  # Rapprochement avec la revue R-17 (issue #313 ; i.i.d. normal, R = 20 000,
  # valeurs publiees a deux decimales) : point du volet A, statistique,
  # valeur publiee.
  REVUE <- list(
    list("R4_1", "supF", 0.26), list("R4_1", "CUSUM", 0.29),
    list("R4_2", "supF", 0.62), list("R4_2", "CUSUM", 0.70),
    list("R6_2", "supF", 0.47), list("R6_2", "CUSUM", 0.37),
    list("T1.75", "supF", 0.33), list("T1.75", "CUSUM", 0.34),
    list("C3", "Grubbs", 0.38), list("C4", "Grubbs", 0.64), list("C5", "Grubbs", 0.84),
    list("C3", "supF", 0.08), list("C4", "supF", 0.08), list("C5", "supF", 0.08),
    list("C3", "CUSUM", 0.08), list("C4", "CUSUM", 0.08), list("C5", "CUSUM", 0.08))
  rev_l <- vapply(REVUE, function(r) {
    pt <- r[[1]]; k <- r[[2]]; pub <- r[[3]]
    kk <- KS[[pt]]$k1[[k]]; nn <- KS[[pt]]$n[[k]]; ci <- ic_cp(kk, nn)
    borne <- startsWith(pt, "C") && k != "Grubbs"
    # Grubbs en C (reserve C3) : la revue simule un autre scenario (v_j + lambda,
    # note) ; comparaison sans objet.
    sans_objet <- startsWith(pt, "C") && k == "Grubbs"
    # Valeur publiee arrondie a 0,01 : compatible si l'intervalle d'arrondi
    # [pub - 0,005 ; pub + 0,005] rencontre l'IC a 95 % ; "<= 0,08" : borne
    # superieure de la revue, compatible si le taux ne la depasse pas.
    ok <- if (borne) kk / nn <= pub + 0.005 else ci[1] <= pub + 0.005 && ci[2] >= pub - 0.005
    ligne_md(POINTS_A[[pt]]$lib, LIB_STAB[[k]], if (borne) paste("\u2264", num(pub, 2)) else num(pub, 2),
             taux(kk, nn), txt_ic(ci),
             if (sans_objet) "sans objet : sc\u00e9nario diff\u00e9rent (note)" else if (ok) "oui" else "**non**")
  }, "")
  # Loi Monte-Carlo du moteur sur J1 observe (S5, non bloquant) : boucle de
  # usp_bootstrap() reduite aux six statistiques (boucle_reduite()), meme
  # graine que run_engine(), B = --B-controle ; les --B premieres
  # replications sont celles de usp_bootstrap() (controle bloquant, critere
  # 3). Taux de p < alpha, p calculee sur S0 : alpha a l'erreur de S0 pres si
  # la loi bootstrap (reajustee) est celle de S0 (sans reajustement).
  t_s5 <- Sys.time()
  BT5 <- boucle_reduite(FIT_A, OPT_GRAINE_IC, OPT_B_CTRL, CAT_STAB)
  controle(identical(BT5$z_boot[seq_len(OPT_B), , drop = FALSE], RES_OBS$J1$bootstrap$z_boot),
           sprintf(paste("Crit\u00e8re 3, volet A (#313) : z_boot des %d premi\u00e8res r\u00e9plications de la boucle de",
                         "contr\u00f4le (B = %d, graine %s) identiques \u00e0 ceux de usp_bootstrap() sur J1"),
                   OPT_B, OPT_B_CTRL, format(OPT_GRAINE_IC, scientific = FALSE)))
  reg5 <- vapply(BT5$delta[BT5$retenu], function(d)
    if (d >= 1 - TOL_DELTA_BORD) "bord1" else if (d <= TOL_DELTA_BORD) "bord0" else "interieur", "")
  n5 <- sum(BT5$retenu)
  s5_l <- vapply(STAB, function(k) {
    p5 <- p_mc_s0(BT5$sim[BT5$retenu, k], S0_TRI[[k]])
    v <- unlist(lapply(c(ALPHA, ALPHA2), function(a) {
      kk <- sum(p5 < a, na.rm = TRUE); nn <- sum(is.finite(p5))
      c(num(taille_s0(a), 4), taux(kk, nn), txt_ic(ic_cp(kk, nn)))
    }))
    # par regime de delta** (alpha = 0,10)
    vr <- vapply(names(REGIMES), function(r) {
      i <- reg5 == r; kk <- sum(p5[i] < ALPHA, na.rm = TRUE); nn <- sum(is.finite(p5[i]))
      if (nn > 0) sprintf("%s (%.0f / %.0f)", num(kk / nn), kk, nn) else "\u2014"
    }, "")
    ligne_md(LIB_STAB[[k]], paste(c(v, vr), collapse = " | "))
  }, "")
  duree_s5 <- as.numeric(difftime(Sys.time(), t_s5, units = "secs"))

  # Sortie du volet A.
  cols_a <- c("Point", unlist(lapply(c("Runs", "DW", "MK", "Smirnov"), function(k)
    c(paste0(LIB_COURT[[k]], " : taux"), "IC 95 % (C-P)"))))
  tab_a <- function(j) c(entete_md(cols_a), vapply(names(POINTS_A), function(pt) {
    kk <- if (j == 1) KA[[pt]]$k1 else KA[[pt]]$k2
    v <- unlist(lapply(c("Runs", "DW", "MK", "Smirnov"), function(k)
      if (k == "Runs" && j == 2) c("inop\u00e9rant (R1, p_min = 4/70)\u00b9", "\u2014")
      else c(taux(kk[[k]], KA[[pt]]$n[[k]]), txt_ic(ic_cp(kk[[k]], KA[[pt]]$n[[k]])))))
    ligne_md(POINTS_A[[pt]]$lib, paste(v, collapse = " | "))
  }, ""))
  c1 <- vapply(seq_along(C1_RHO), function(i) {
    pt <- sprintf("A%+.1f", C1_RHO[i]); K <- KA[[pt]]
    ligne_md(num(C1_RHO[i], 1), taux(K$k1[["Runs"]], K$n[["Runs"]]), num(C1_SUITES[i]),
             paste(compat(C1_SUITES[i], K$k1[["Runs"]], K$n[["Runs"]]), collapse = " | "),
             taux(K$k1[["DW"]], K$n[["DW"]]), num(C1_DW[i]),
             paste(compat(C1_DW[i], K$k1[["DW"]], K$n[["DW"]]), collapse = " | "))
  }, "")
  im <- vapply(pts_ar, function(pt) {
    K <- KA[[pt]]; ci <- ic_cp(K$k1[["DW"]], K$n[["DW"]])
    ligne_md(POINTS_A[[pt]]$lib, if (is.finite(imhof[[pt]])) num(imhof[[pt]], 4) else "\u00e9chec num\u00e9rique",
             taux(K$k1[["DW"]], K$n[["DW"]]), txt_ic(ci),
             if (!is.finite(imhof[[pt]])) "\u2014" else if (imhof[[pt]] >= ci[1] && imhof[[pt]] <= ci[2]) "oui" else "**non**")
  }, "")
  duree_a <- as.numeric(difftime(Sys.time(), t_a, units = "secs"))
  SORTIE_A <- c(
    "## Puissance \u00e0 T = 8 sous le mod\u00e8le ajust\u00e9, volet A : p exactes, r\u00e9gime \u03c0\u0302 constant, jeu J1 (issue #116)", "",
    sprintf("Param\u00e8tres : R=%d ; graine=%s ; \u03b1=0,10 (principal) et 0,05 ; T=%d", OPT_R,
            format(OPT_GRAINE, scientific = FALSE), T_), "",
    paste("Statut : **constat de simulation sous des alternatives choisies, hors mod\u00e8le r\u00e9glementaire**,",
          "sauf la colonne Imhof du tableau A5 (approximation num\u00e9rique d'une quantit\u00e9 exacte). p exactes des",
          "fonctions du moteur (runs_p_exacte(), dw_p_exacte(), mk_p_exacte(), ks.test() sur la partition",
          "x_t > m\u00e9d(x)) appliqu\u00e9es \u00e0 l* = ln r* \u2212 moyenne, u* = r* \u2212 moyenne et r*, sans r\u00e9ajustement : c'est",
          "la p que retiendrait le moteur \u00e0 \u03c0\u0302* constant (v\u00e9rifi\u00e9 sur J1 observ\u00e9). Rejet si p < \u03b1.",
          "Alternatives sur le mod\u00e8le ajust\u00e9 (\u03b2\u0302, \u03c0\u0302_t, x_t gard\u00e9s ; \u03b5 remplac\u00e9, amplitudes en",
          "\u00e9carts-types de ln r_t) : protocole dans l'en-t\u00eate de tests/puissance_t8.R. Nombres al\u00e9atoires",
          "communs aux vingt-deux points. IC : incertitude Monte-Carlo (fonction de R), pas l'erreur d'approximation en T."), "",
    "### T0 -- contexte", "",
    entete_md(c("Grandeur", "Valeur")),
    ligne_md("Jeu", JEU_A$libelle),
    ligne_md("Mod\u00e8le ajust\u00e9 (usp_ajuster())", txt_modele(FIT_A)),
    ligne_md("Partition de Smirnov (x_t > m\u00e9d(x))", paste0("{", paste(which(GRP), collapse = ", "), "}")),
    ligne_md("Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)", plateforme_calcul()),
    ligne_md("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
    ligne_md("Graine de la matrice e", format(OPT_GRAINE, scientific = FALSE)),
    ligne_md("Commit", commit_depot("tests/puissance_t8.R")),
    ligne_md("R\u00e9plications par point", as.character(OPT_R)),
    ligne_md("Dur\u00e9e (s)", sprintf("r\u00e9plications %.1f (%.2f ms par s\u00e9rie et par point) ; volet A total %.1f",
                                      duree_rep_a, 1000 * duree_rep_a / (OPT_R * length(POINTS_A)), duree_a)), "",
    "### A1 -- taux de rejet, \u03b1 = 0,10", "", tab_a(1), "",
    "La ligne des suites sur ratios bruts (Runsr) est identique \u00e0 celle des suites sur z r\u00e9plication par r\u00e9plication (crit\u00e8re 2) : elle n'est pas r\u00e9p\u00e9t\u00e9e.", "",
    "### A2 -- taux de rejet, \u03b1 = 0,05 (compl\u00e9ment)", "", tab_a(2), "", "\u00b9 Suites \u00e0 \u03b1 = 0,05 : test inop\u00e9rant (r\u00e8gle R1) ; \u00e0 T = 8 sans ex aequo, p_min = 4/70 = 0,0571 \u2265 0,05, aucune valeur observ\u00e9e ne peut donner p < 0,05 (le moteur restitue la ligne en diagnostic INFO) ; taux nul par construction, v\u00e9rifi\u00e9 (taux exactement 0) sur la ligne N, hors crit\u00e8re 1.", "",
    "### A3 -- niveau : ligne N contre la taille exacte (crit\u00e8re 1)", "",
    entete_md(c("Ligne", "\u03b1", "Taille exacte", "Rejets / n", "Taux", "IC 95 % (C-P)", "IC 99,9 % (C-P)",
                "Taille dans l'IC \u00e0 99,9 %")),
    niv, "", "\u00b9 Suites \u00e0 \u03b1 = 0,05 : test inop\u00e9rant (r\u00e8gle R1) ; \u00e0 T = 8 sans ex aequo, p_min = 4/70 = 0,0571 \u2265 0,05, aucune valeur observ\u00e9e ne peut donner p < 0,05 (le moteur restitue la ligne en diagnostic INFO) ; taux nul par construction, v\u00e9rifi\u00e9 (taux exactement 0) sur la ligne N, hors crit\u00e8re 1.", "",
    paste("Crit\u00e8re 1 : cinq v\u00e9rifications (suites \u00e0 0,10 ; Durbin-Watson \u00e0 0,10 et 0,05 ; Mann-Kendall \u00e0 0,10",
          "et 0,05 ; Smirnov une fois, m\u00eame \u00e9v\u00e9nement aux deux \u03b1), chacune par l'IC bilat\u00e9ral de Clopper-Pearson",
          "\u00e0 99,9 %, qui limite le risque de faux \u00e9chec d'un contr\u00f4le juste ; l'IC \u00e0 95 % est donn\u00e9 pour la lecture."), "",
    "Tailles exactes par \u00e9num\u00e9ration des 70 partitions (suites, Smirnov) et de la loi mahonienne (Mann-Kendall) \u00e0 T = 8 sans ex aequo ; Durbin-Watson : loi continue, taille \u03b1.", "",
    "### A4 -- compatibilit\u00e9 avec le constat C1.a (AR(1) stationnaire, \u03b1 = 0,10 ; non bloquant)", "",
    entete_md(c("\u03c1", "Suites : taux", "C1.a", "z", "Compatible", "DW : taux", "C1.a", "z", "Compatible")),
    c1, "",
    "\u00c0 \u03c0\u0302 constant, l'alternative A est l'AR(1) de C1.a \u00e0 un facteur positif pr\u00e8s (m\u00eame loi des p) ; z : \u00e9cart normalis\u00e9 de deux proportions ind\u00e9pendantes (C1.a sur 20 000 tirages), compatible si |z| \u2264 1,96, comparaisons non corrig\u00e9es pour la multiplicit\u00e9.", "",
    "### A5 -- puissance de Durbin-Watson sous AR(1) par Imhof (\u03b1 = 0,10 ; non bloquant)", "",
    entete_md(c("Point", "Imhof", "Volet A : taux", "IC 95 % (C-P)", "Imhof dans l'IC")),
    im, "",
    paste("Imhof : P(DW \u2264 d_bas) + P(DW \u2265 d_haut) sous \u03b5' ~ N(0, \u03a3_\u03c1), \u03a3_\u03c1 = (\u03c1^|i\u2212j|), d_bas et d_haut",
          "quantiles \u03b1/2 et 1 \u2212 \u03b1/2 de la loi nulle de dw_p_exacte(), chaque probabilit\u00e9 par .imhof_p_sup0()",
          "sur les valeurs propres de \u03a3^(1/2) M (A \u2212 d I) M \u03a3^(1/2) : approximation num\u00e9rique (int\u00e9gration",
          "d'Imhof) d'une quantit\u00e9 exacte, statut 3."), "")
  ecrire_console(SORTIE_A)

  # Sortie des lignes de stabilite (#313).
  cols_s <- c("Point", unlist(lapply(STAB, function(k) c(paste0(LIB_STAB[[k]], " : taux"), "IC 95 % (C-P)"))))
  tab_s <- function(j) c(entete_md(cols_s), vapply(names(POINTS_A), function(pt) {
    kk <- if (j == 1) KS[[pt]]$k1 else KS[[pt]]$k2
    v <- unlist(lapply(STAB, function(k) c(taux(kk[[k]], KS[[pt]]$n[[k]]), txt_ic(ic_cp(kk[[k]], KS[[pt]]$n[[k]])))))
    ligne_md(POINTS_A[[pt]]$lib, paste(v, collapse = " | "))
  }, ""))
  tab_dz <- c(entete_md(c("Point", "sup-F", "OLS-CUSUM", "Grubbs")), vapply(names(POINTS_A), function(pt)
    ligne_md(POINTS_A[[pt]]$lib, paste(vapply(c("supF", "CUSUM", "Grubbs"), function(k)
      sprintf("%s (%.0f)", num(KS[[pt]]$dz[[k]] / OPT_R, 4), KS[[pt]]$dz[[k]]), ""), collapse = " | ")), ""))
  SORTIE_S <- c(
    "## Puissance \u00e0 T = 8 de sup-F, OLS-CUSUM et Grubbs (z et ratios bruts), volet A : p Monte-Carlo \u00e0 \u03c0\u0302 constant, jeu J1 (issue #313)", "",
    sprintf("Param\u00e8tres : R=%d ; R0 (loi nulle)=%d ; B de contr\u00f4le=%d ; graine=%s ; graine-ic=%s ; \u03b1=0,10 (principal) et 0,05 ; T=%d",
            OPT_R, OPT_R_NULLE, OPT_B_CTRL, format(OPT_GRAINE, scientific = FALSE),
            format(OPT_GRAINE_IC, scientific = FALSE), T_), "",
    sprintf(paste("Statut : **constat de simulation sous des alternatives choisies, hors mod\u00e8le r\u00e9glementaire**.",
          "Statistiques calcul\u00e9es par les entr\u00e9es supF, CUSUM, Grubbs, supFr, CUSUMr, Grubbsr du catalogue",
          "USP_CATALOGUE_MC (stat_supF(), stat_cusum(), test_grubbs()) sur l* = ln r* \u2212 moyenne (\u00e0 la place de z,",
          "image affine croissante de z \u00e0 \u03c0\u0302 constant ; statistiques invariantes) et u* = r* \u2212 moyenne, sans",
          "r\u00e9ajustement. p Monte-Carlo = (1 + #{S0 \u2265 s}) / (R0 + 1), formule de engine_p_mc() en queue haute,",
          "sur une loi nulle S0 de R0 s\u00e9ries usp_simuler(FIT0) sans r\u00e9ajustement :",
          "puissance du test \u00e0 \u03b4 = 1 impos\u00e9 et loi nulle simul\u00e9e sans r\u00e9ajustement, B infini \u00e0 l'erreur de S0",
          "pr\u00e8s : r\u00e9f\u00e9rence id\u00e9alis\u00e9e de la ligne du moteur, non la puissance de la p-value retenue par le",
          "moteur ; s\u00e9ries alternatives non r\u00e9ajust\u00e9es (part des cas o\u00f9 \u03b4\u0302* serait int\u00e9rieur, o\u00f9 le moteur",
          "retient la p conditionnelle V3h, #240, non mesur\u00e9e).",
          "Effet de B seul (B = %d, hors r\u00e9ajustement) : tableau S7. La loi Monte-Carlo du moteur",
          "r\u00e9ajuste chaque r\u00e9plication : \u00e9cart mesur\u00e9 au tableau S5. Rejet si p < \u03b1.",
          "Les lignes sur ratios bruts ne sont pas invariantes : leur puissance d\u00e9pend du sens de l'\u00e9cart et de",
          "l'\u00e9cart-type de ln r_t, \u221a(1/\u03c0\u0302) = %s sur J1 (fonction croissante de \u03c3\u0302/\u03b2\u0302 = %s), et non de \u03c3\u0302 seul.",
          "Sur les lignes z, C\u2212 et C ont la m\u00eame loi (statistiques paires, sym\u00e9trie de",
          "la loi normale). Alternatives et nombres al\u00e9atoires communs : ceux du volet A de l'issue #116",
          "(en-t\u00eate de tests/puissance_t8.R), plus la tendance D = 1,75 et les contaminations C et C\u2212,",
          "vingt-deux points en tout. IC : incertitude Monte-Carlo (fonction de R), pas l'erreur",
          "d'approximation en T."), OPT_B,
            # echelle des ratios bruts (pi chapeau constant sur J1, controle en tete du volet A)
            num(sqrt(1 / FIT_A$pi[1]), 4), num(FIT_A$sigma / FIT_A$beta, 4)), "",
    "### T0 -- contexte", "",
    entete_md(c("Grandeur", "Valeur")),
    ligne_md("Jeu", JEU_A$libelle),
    ligne_md("Mod\u00e8le ajust\u00e9 (usp_ajuster())", txt_modele(FIT_A)),
    ligne_md("Loi nulle S0", sprintf("R0 = %d s\u00e9ries usp_simuler(FIT0), graine %s ; %.1f s", OPT_R_NULLE,
                                     format(OPT_GRAINE + 2, scientific = FALSE), duree_s0)),
    ligne_md(sprintf("J1 observ\u00e9 : p sur S0 / p_mc de run_engine() (B = %d)", OPT_B),
             paste(vapply(STAB, function(k) sprintf("%s %s / %s", k, num(P_OBS_STAB[[k]], 4),
                                                    num(RES_OBS$J1$bootstrap$p_mc[[k]], 4)), ""), collapse = " ; ")),
    ligne_md("Ann\u00e9e contamin\u00e9e (sc\u00e9narios C et C\u2212)", "t_c(b) = 1 + (b \u2212 1) mod 8"),
    ligne_md("Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)", plateforme_calcul()),
    ligne_md("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
    ligne_md("Graines", sprintf("matrice e %s ; S0 %s ; boucle de contr\u00f4le S5 %s",
                                format(OPT_GRAINE, scientific = FALSE), format(OPT_GRAINE + 2, scientific = FALSE),
                                format(OPT_GRAINE_IC, scientific = FALSE))),
    ligne_md("Commit", commit_depot("tests/puissance_t8.R")),
    ligne_md("R\u00e9plications par point", as.character(OPT_R)),
    ligne_md("Dur\u00e9e (s)", sprintf("loi nulle S0 %.1f ; r\u00e9plications du volet A (toutes lignes) %.1f ; boucle S5 %.1f ; volet A total %.1f",
                                      duree_s0, duree_rep_a, duree_s5, duree_a)), "",
    "### S1 -- taux de rejet, \u03b1 = 0,10", "", tab_s(1), "",
    "### S2 -- taux de rejet, \u03b1 = 0,05 (compl\u00e9ment)", "", tab_s(2), "",
    "### S3 -- niveau : ligne N contre la taille du test \u00e0 loi nulle S0 (non bloquant)", "",
    entete_md(c("Ligne", "\u03b1", "Taille", "Rejets / n", "Taux", "IC 95 % (C-P)", "IC 99,9 % (C-P)", "Taille dans l'IC \u00e0 99,9 %")),
    niv_s, "",
    paste("Taille : (\u2308\u03b1 (R0 + 1)\u2309 \u2212 1) / (R0 + 1), marginalement sur S0 (statistique continue). Les r\u00e9plications",
          "de la ligne N partagent S0 : l'IC binomial ignore la variabilit\u00e9 de S0 (\u00e9cart-type de l'ordre de",
          "\u221a(\u03b1(1 \u2212 \u03b1)/R0)), d'o\u00f9 un contr\u00f4le rapport\u00e9, hors code de sortie."), "",
    "### S4 -- rapprochement avec la revue R-17 (\u03b1 = 0,10 ; non bloquant)", "",
    entete_md(c("Point", "Ligne", "Revue (R = 20 000)", "Volet A : taux", "IC 95 % (C-P)", "Compatible")),
    rev_l, "",
    paste("Revue : docs/revues/20261015-pertinence-tests-graphiques/bloc-4.md (issue #313), i.i.d. normal, rejet si la",
          "statistique d\u00e9passe le quantile \u00e0 90 % d'une loi nulle simul\u00e9e de 100 000 s\u00e9ries ; valeurs \u00e0 deux",
          "d\u00e9cimales, compatibles si l'intervalle d'arrondi \u00b1 0,005 rencontre l'IC \u00e0 95 % ; \u00ab \u2264 0,08 \u00bb :",
          "borne de la revue, compatible si le taux ne la d\u00e9passe pas de plus de 0,005. Contamination : la revue",
          "remplace l'ann\u00e9e i par v_j + \u03bb, i et j tir\u00e9s au hasard ind\u00e9pendamment (v[sample(T, 1)] <-",
          "v[sample(T, 1)] + L dans son script sim.R), et non par v_i + \u03bb ; ici e_t + \u03bb pour l'ann\u00e9e t_c(b),",
          "d\u00e9terministe : les deux sc\u00e9narios diff\u00e8rent ; mesur\u00e9 hors d\u00e9p\u00f4t (#313, R = 20 000), le",
          "g\u00e9n\u00e9rateur de la revue donne pour Grubbs 0,381 / 0,647 / 0,837 et la contamination d'une ann\u00e9e",
          "0,358 / 0,614 / 0,822 (\u03bb = 3 / 4 / 5) : comparaison sans objet. D\u00e9rive, sup-F : m\u00eame sc\u00e9nario,",
          "\u00e9cart d'environ 2,5 \u00e9carts-types Monte-Carlo combin\u00e9s ; un rejeu hors d\u00e9p\u00f4t (3 \u00d7 50 000 s\u00e9ries)",
          "donne environ 0,342, entre les deux valeurs."), "",
    "### S5 -- loi Monte-Carlo du moteur (r\u00e9ajustement) contre la loi nulle S0 (sans r\u00e9ajustement), J1 observ\u00e9 (non bloquant)", "",
    sprintf("Boucle de usp_bootstrap() r\u00e9duite aux six statistiques, B = %d (%d retenues) ; r\u00e9gime de \u03b4** : bord 1 %s, bord 0 %s, int\u00e9rieur %s.",
            OPT_B_CTRL, n5, num(mean(reg5 == "bord1"), 3), num(mean(reg5 == "bord0"), 3), num(mean(reg5 == "interieur"), 3)), "",
    entete_md(c("Ligne", "Taille (\u03b1 = 0,10)", "Taux p < 0,10", "IC 95 % (C-P)", "Taille (\u03b1 = 0,05)", "Taux p < 0,05",
                "IC 95 % (C-P)", paste0("\u03b1 = 0,10, ", REGIMES[c("bord1", "bord0")]),
                "\u03b1 = 0,10, \u03b4\u0302* int\u00e9rieur (taux conditionnel descriptif)")),
    s5_l, "",
    paste("Taux, sur les r\u00e9plications de la boucle bootstrap du moteur, d'une p < \u03b1 calcul\u00e9e sur S0 : \u00e9gal \u00e0 la",
          "taille (\u00e0 l'erreur Monte-Carlo pr\u00e8s) si la loi bootstrap du moteur, qui r\u00e9ajuste \u03b4 et \u03b3 dans chaque",
          "r\u00e9plication, est celle de S0. Un \u00e9cart mesure la diff\u00e9rence entre le test du volet A et celui que",
          "retient le moteur sur J1 (V1, toutes r\u00e9plications). Colonne \u03b4\u0302* int\u00e9rieur : ce n'est pas le niveau",
          "d'un test du moteur : \u00e0 \u03b4\u0302 int\u00e9rieur, le moteur retient la p conditionnelle au r\u00e9gime (V3h, #240)."), "",
    "### S6 -- d\u00e9saccords de rejet z / ratios bruts (\u03b1 = 0,10 ; part des r\u00e9plications, nombre)", "",
    tab_dz, "",
    sprintf("### S7 -- effet de B : taux de rejet exact \u00e0 B = %d, conditionnel \u00e0 S0, et \u00e9cart \u0394 au taux de S1 (\u03b1 = 0,10)", OPT_B), "",
    tab_b(1), "",
    sprintf("### S8 -- effet de B, \u03b1 = 0,05 (compl\u00e9ment)"), "", tab_b(2), "",
    paste(sprintf(paste("taux_B : moyenne sur les r\u00e9plications de pbinom(k, B, u_i), k = \u2308\u03b1 (B + 1)\u2309 \u2212 2, B = %d,",
                        "u_i = ((R0 + 1) p_i \u2212 1) / R0 (p_i : p sur S0) ; la p du moteur (1 + K) / (B + 1) rejette si K \u2264 k,"), OPT_B),
          "K ~ Binomiale(B, u_i). Calcul exact conditionnel \u00e0 la loi S0, sans al\u00e9a nouveau ; effet de B seul, hors",
          sprintf("r\u00e9ajustement. Ligne N attendue : (\u2308\u03b1 (B + 1)\u2309 \u2212 1) / (B + 1) = %s (\u03b1 = 0,10), %s (\u03b1 = 0,05) ;",
                  num(taille_b(ALPHA), 4), num(taille_b(ALPHA2), 4)),
          "contr\u00f4le non bloquant."), "")
  ecrire_console(SORTIE_S)
}

###############################################################################
#  VOLET B
###############################################################################
SORTIES_B <- list()
if (OPT_VOLET %in% c("tout", "B")) {
  E_B <- tirer_e(OPT_GRAINE + 1, OPT_R_CHAINE)
  for (jn in JEUX_B) {
    t_b <- Sys.time()
    JEU <- charger_jeu(jn)
    X <- JEU$x
    FIT0 <- usp_ajuster(X, JEU$y)
    n_int0 <- length(INTEGRITE)
    # Tranche
    if (is.na(OPT_TRANCHE)) { DEBUT <- 1L; FIN <- OPT_R_CHAINE } else {
      m <- regmatches(OPT_TRANCHE, regexec("^([0-9]+)/([0-9]+)$", OPT_TRANCHE))[[1]]
      if (length(m) != 3L) stop("--tranche : forme i/K attendue")
      i <- as.integer(m[2]); K <- as.integer(m[3])
      if (K < 1L || i < 1L || i > K || K > OPT_R_CHAINE) stop("--tranche : 1 <= i <= K <= R-chaine")
      DEBUT <- as.integer(floor((i - 1) * OPT_R_CHAINE / K)) + 1L; FIN <- as.integer(floor(i * OPT_R_CHAINE / K))
    }
    # Critere 3 : chaine sur le jeu observe contre run_engine().
    t_c <- Sys.time()
    if (is.null(RES_OBS[[jn]])) RES_OBS[[jn]] <- engine_observe(JEU)
    res <- RES_OBS[[jn]]
    controle(isTRUE(res$ok), sprintf("Crit\u00e8re 3, %s : run_engine() sur le jeu observ\u00e9 ok", jn))
    ch0 <- chaine(X, JEU$y, OPT_GRAINE_IC, OPT_B)
    l_re <- lignes_tests(engine_table_tests(res))
    ok_l <- vapply(LIG_B, function(k) {
      a <- l_re[[k]]; b <- ch0$lignes[[k]]
      cols <- setdiff(names(a), "p_exacte")
      identical(unname(as.list(a[cols])), unname(as.list(b[cols]))) &&
        (if (k == "DW") isTRUE(all.equal(a$p_exacte, b$p_exacte, tolerance = 1e-10))
         else identical(a$p_exacte, b$p_exacte))
    }, logical(1))
    controle(all(ok_l), sprintf(paste("Crit\u00e8re 3, %s : douze lignes de engine_table_tests() de la cha\u00eene r\u00e9duite",
                                      "identiques \u00e0 celles de run_engine() (B = %d, graine %s)%s"),
                                jn, OPT_B, format(OPT_GRAINE_IC, scientific = FALSE),
                                if (all(ok_l)) "" else paste0(" ; diff\u00e9rentes : ", paste(LIG_B[!ok_l], collapse = ", "))))
    controle(identical(ch0$boucle$sigma_boot, res$bootstrap$sigma_boot) &&
               identical(ch0$boucle$z_boot, res$bootstrap$z_boot),
             sprintf("Crit\u00e8re 3, %s : sigma_boot et z_boot de la boucle r\u00e9duite identiques \u00e0 ceux de usp_bootstrap()", jn))
    Y_N <- t(apply(E_B, 1, function(e) simuler_alt(FIT0, e)))
    controle(identical(Y_N, engine_sous_graine(OPT_GRAINE + 1, t(vapply(seq_len(OPT_R_CHAINE),
                                                                         function(b) usp_simuler(FIT0), numeric(T_))))),
             sprintf("Crit\u00e8re 3, %s : ligne N identique \u00e0 usp_simuler(FIT0) (m\u00eame graine, au bit pr\u00e8s)", jn))
    t_controle <- as.numeric(difftime(Sys.time(), t_c, units = "secs"))
    DUREE_CONTROLES <- DUREE_CONTROLES + t_controle

    # Replications.
    t_r <- Sys.time()
    cpt <- numeric(0)
    for (b in seq.int(DEBUT, FIN)) for (pt in names(POINTS_B)) {
      y <- simuler_alt(FIT0, POINTS_B[[pt]]$phi(E_B[b, ], X, b))
      cpt <- compter_chaine(cpt, pt, chaine(X, y, OPT_GRAINE_IC + 1000 * b, OPT_B))
    }
    t_rep <- as.numeric(difftime(Sys.time(), t_r, units = "secs"))
    n_rep <- (FIN - DEBUT + 1L) * length(POINTS_B)
    complet <- is.na(OPT_TRANCHE)
    tb <- tableaux_chaine(cpt, FIN - DEBUT + 1L, OPT_B, complet)
    # Critere 5 (toujours) ; critere 4 (execution d'un seul tenant seulement).
    controle(!length(tb$echecs5), sprintf("Crit\u00e8re 5, %s : aucune p manquante hors motif compt\u00e9%s", jn,
                                          if (length(tb$echecs5)) paste0(" (", paste(tb$echecs5, collapse = ", "), ")") else ""))
    # Coherence des comptes (#274) : par point, ligne et regime, OK + ALERTE +
    # ECHEC + INFO inoperant + sans p retenue = replications non ecartees.
    controle(!length(tb$echecs_cpt), sprintf(paste("Crit\u00e8re 5, %s : comptes coh\u00e9rents par point, ligne et r\u00e9gime",
                                                   "(verdicts + inop\u00e9rants + p manquantes = r\u00e9plications)%s"), jn,
                                             if (length(tb$echecs_cpt)) paste0(" (", paste(tb$echecs_cpt, collapse = ", "), ")") else ""))
    if (complet)
      controle(!length(tb$echecs4), sprintf(paste("Crit\u00e8re 4, %s : niveau du volet B (ligne N, borne inf\u00e9rieure",
                                                  "unilat\u00e9rale 99,9 %% \u2264 \u03b1)%s"), jn,
                                            if (length(tb$echecs4)) paste(" --", texte_crit4(tb)) else ""),
               statut_ok = texte_crit4(tb))
    PAR <- sprintf("jeu=%s;R_chaine=%d;graine=%.0f;graine_ic=%.0f;B=%d;methode=%s;segment=%d;annexe=%s;nature=%s;alpha=%g",
                   jn, OPT_R_CHAINE, OPT_GRAINE, OPT_GRAINE_IC, OPT_B, METHODE, SEGMENT, ANNEXE, NATURE, ALPHA)
    CTX <- c(
      jeu = JEU$libelle, modele = txt_modele(FIT0),
      configuration = sprintf("m\u00e9thode %s, segment %d de l'annexe %s, donn\u00e9es %s, \u03b1 = %g (sans effet sur les douze lignes hors \u03b1)",
                              METHODE, SEGMENT, ANNEXE, NATURE, ALPHA),
      points = paste(vapply(POINTS_B, `[[`, "", "lib"), collapse = " ; "),
      graines = sprintf("matrice e %.0f ; bootstrap de la r\u00e9plication b : %.0f + 1000 b ; observ\u00e9 : %.0f", OPT_GRAINE + 1, OPT_GRAINE_IC, OPT_GRAINE_IC),
      B = as.character(OPT_B), generateur = paste(ENGINE_RNG_KIND, collapse = ", "),
      commit = commit_depot("tests/puissance_t8.R"),
      plateforme = plateforme_calcul(), empreintes = EMPREINTES)
    stopifnot(identical(names(CTX), names(LIBELLES_CONTEXTE)))
    ok_jeu <- length(INTEGRITE) == n_int0
    duree_b <- as.numeric(difftime(Sys.time(), t_b, units = "secs"))
    S <- c(sprintf("## Puissance \u00e0 T = 8, volet B (cha\u00eene r\u00e9duite), jeu %s (issues #116, #274)", jn), "",
           sprintf("Param\u00e8tres : %s", PAR), "", statut_b(), "",
           "### T0 -- contexte", "", entete_md(c("Grandeur", "Valeur")), lignes_contexte(CTX),
           ligne_md("R\u00e9plications par point", sprintf("%d (trait\u00e9es : %d \u00e0 %d)", OPT_R_CHAINE, DEBUT, FIN)),
           ligne_md("Dur\u00e9e (s)", sprintf("contr\u00f4les %.1f ; r\u00e9plications %.1f (%.2f s par r\u00e9plication et par point) ; total du jeu %.1f",
                                             t_controle, t_rep, t_rep / n_rep, duree_b)),
           ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9 du jeu", if (ok_jeu) "OK" else "\u00c9CHEC"), "")
    if (!complet) S <- c(S, "Tableaux PARTIELS (une tranche) : combiner les sorties des K tranches par --combiner.", "")
    S <- c(S, tb$lignes)
    SORTIES_B[[jn]] <- S
    ecrire_console(S)
    # Lignes machine d'une tranche, imprimees en fin d'execution, apres le
    # critere 6 de fin, que la ligne INTEGRITE couvre donc aussi.
    if (!complet) MACHINE <- list(PAR = PAR, CTX = CTX, cpt = cpt)
  }
}

# --- Fin : critere 6, controles, ecriture ----------------------------------------------
verifier_depot(MD5_DEBUT, "fin")
duree <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
BILAN <- c("### Contr\u00f4les d'int\u00e9grit\u00e9 et crit\u00e8res bloquants (toute l'ex\u00e9cution)", "", paste("-", CONTROLES), "",
           sprintf(paste("Dur\u00e9e totale : %.0f s, dont contr\u00f4les de transcription (run_engine() et cha\u00eene",
                         "sur les jeux observ\u00e9s, ligne N) %.0f s et hors contr\u00f4les %.0f s. Bilan : %s"),
                   duree, DUREE_CONTROLES, duree - DUREE_CONTROLES,
                   if (length(INTEGRITE)) sprintf("\u00c9CHEC (%d crit\u00e8re(s))", length(INTEGRITE)) else "OK"), "")
if (is.na(OPT_TRANCHE)) {
  ecrire_console(BILAN)
  if (!length(INTEGRITE)) {
    a_ecrire <- list()
    if (!is.null(SORTIE_A)) {
      a_ecrire[["exact-J1"]] <- c(SORTIE_A, BILAN)
      a_ecrire[["stabilite-J1"]] <- c(SORTIE_S, BILAN)
    }
    for (jn in names(SORTIES_B)) a_ecrire[[paste0("chaine-", jn)]] <- c(SORTIES_B[[jn]], BILAN)
    # chemins ecrits = chemins du controle anticipe
    stopifnot(identical(names(a_ecrire), SUFFIXES_EXECUTION))
    ecrire_fichiers(a_ecrire)
  }
} else {
  # Tranche : bilan, puis lignes machine (FIN en derniere ligne).
  ecrire_console(BILAN)
  ecrire_console(c(paste0("PARAMETRES\t", MACHINE$PAR), sprintf("TRANCHE\t%d\t%d", DEBUT, FIN),
                   sprintf("CONTEXTE\t%s\t%s", names(MACHINE$CTX), MACHINE$CTX),
                   paste0("INTEGRITE\t", if (!length(INTEGRITE)) "OK" else "ECHEC"),
                   sprintf("NCOMPTES\t%d", length(MACHINE$cpt)),
                   sprintf("COMPTE\t%s\t%.0f", names(MACHINE$cpt), MACHINE$cpt),
                   sprintf("FIN\t%d", length(MACHINE$cpt))))
}
quit(status = if (length(INTEGRITE)) 1L else 0L)
