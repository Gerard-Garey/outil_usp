###############################################################################
#  tests/constats_puissance_t8.R  --  CONSTATS DE NIVEAU ET DE PUISSANCE A
#  T = 8 (issues #114, #118, #174, #219, #220 et #335)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  Sortie en markdown sur la console (UTF-8). Il n'ecrit aucun fichier, sauf
#  sur demande explicite (option --ecrire DOSSIER, parties tost, normalite,
#  tost-frontiere, pitman et esd seulement, voir "Usage"). R base + stats.
#
#  Objet : deux constats cites dans le projet sans que leur script ait ete
#  versionne (C1, C2 : decision du mainteneur du 27/09/2026, issue #114), et
#  deux mesures nouvelles (C3, C4 : decisions du mainteneur du 30/09/2026 sur
#  la note d'actuary, issue #118, commentaires 5904968834 et 5904984418) qui
#  remplacent trois valeurs retirees faute de protocole (TOST "46 % a T = 8",
#  Shapiro-Wilk "quelques dizaines de pour cent", D'Agostino "exploitable
#  vers T >= 20") ; C3 et C4 ne reproduisent pas ces valeurs.
#
#  C1. Puissance du test des suites contre Durbin-Watson exact (commentaire
#      d'actuary du 23/09/2026 sur l'issue #44) : "20 000 AR(1) gaussiens de
#      longueur 8, alpha = 0,10, indicatif, hors modele USP ; rho = 0,3 /
#      0,5 / 0,7 / 0,9 -> suites 0,080 / 0,118 / 0,175 / 0,247, Durbin-Watson
#      exact 0,163 / 0,268 / 0,395 / 0,529". Statut : CONSTAT DE SIMULATION,
#      HORS MODELE REGLEMENTAIRE (l'annexe XVII suppose des annees
#      independantes ; l'AR(1) est une alternative choisie pour mesurer la
#      puissance, pas un modele du dossier).
#      Protocole retenu (le commentaire ne precise ni l'initialisation ni la
#      regression sous-jacente) :
#        - e_1..e_8 i.i.d. N(0,1) ; variante principale STATIONNAIRE,
#          u_1 = e_1 / sqrt(1 - rho^2), u_t = rho u_{t-1} + e_t ; variante
#          secondaire DEPART NUL, u_1 = e_1 (non stationnaire, variance
#          croissante) ; memes innovations pour tous les rho et les deux
#          variantes (nombres aleatoires communs) ;
#        - les deux tests sont appliques a la serie u elle-meme, par les
#          fonctions du moteur : runs_p_exacte() (loi de Swed & Eisenhart aux
#          effectifs de part et d'autre de la mediane, doublement, M8) et
#          dw_p_exacte() (statistique sur la serie CENTREE, soit les residus
#          de la regression sur la seule constante ; loi exacte d'Imhof ; p
#          bilaterale 2 min(P(DW <= d), P(DW >= d))). Le moteur les applique
#          aux residus standardises z ; a pi chapeau constant, z est une
#          transformation affine croissante des log-ratios (usp_noyau()), et
#          les deux p-values sont invariantes par une telle transformation
#          (controle d'integrite ci-dessous) : appliquer les tests a u revient
#          a traiter u comme les log-ratios d'un jeu a pi constant ;
#        - rejet si p < alpha (verdict different de OK dans add()) ;
#        - ligne rho = 0 ajoutee (niveau : 4/70 = 0,0571 exactement pour les
#          suites a T = 8 sans ex aequo, alpha pour Durbin-Watson).
#
#  C2. "0 rejet sur 3 000 a 5 %" du Kolmogorov-Smirnov contre N(0,1)
#      (detail de la ligne dans usp_tests() ; fiche et tableau 1 du .tex).
#      Le protocole n'est pas ecrit ; trois lectures sont mesurees, plus une
#      ligne de reference :
#        K0 (reference, parametres CONNUS) : echantillons N(0,1) de taille 8,
#           D contre N(0,1) sans standardisation ;
#        K1 (residus du moteur, lecture du detail : "standardises par le
#           MODELE") : jeux simules sous le modele ajuste au jeu J1
#           (tests/donnees/donnees_ln.csv) par usp_simuler(), le generateur du
#           bootstrap parametrique, reajustes par usp_ajuster(), D = stat_ks()
#           sur les residus z du reajustement (statistique du catalogue KS) ;
#        K2 (lecture de la fiche : "parametres estimes") : echantillons N(0,1)
#           standardises par la moyenne et l'ecart-type empiriques (s en T-1) ;
#        K3 : idem, ecart-type du maximum de vraisemblance (s en T), soit les
#           z du moteur quand pi chapeau est constant (usp_noyau()).
#      p-value : formule de Kolmogorov de la ligne de usp_tests(), transcrite
#      dans p_kolmogorov() (transcription controlee contre run_engine() sur
#      J1) ; rejet si p < 0,05. Statut : constat de simulation du niveau
#      (K1 : sous le modele reglementaire ajuste ; K0, K2, K3 : sous
#      l'hypothese de normalite i.i.d.).
#      Convergence des reajustements K1 : un reajustement est ECARTE seulement
#      s'il echoue (erreur de usp_ajuster()) ou rend des z non finis ; ceux
#      dont l'optimum retenu a un code optim() `convergence` != 0 (arret sur
#      maxit, 1, ou message L-BFGS-B, 52) sont GARDES dans le taux, comme le
#      moteur les garde dans run_engine(), mais comptes et signales dans la
#      sortie : nombre, codes, rejets parmi eux, nombre de reajustements sans
#      aucun demarrage a l'optimum de code 0 (n_starts_optimum_code0 = 0) et
#      minimum de n_starts_optimum (demarrages a l'optimum, sur 54).
#
#  C3. Probabilite de conclure a l'equivalence par le TOST de la constante
#      (test_tost_intercept(), marge Delta = theta * moyenne(y), theta = 0,10,
#      valeur par defaut de run_engine()) sous le modele reglementaire
#      ajuste (constante a = 0 vraie). Statut : CONSTAT DE SIMULATION SOUS LE
#      MODELE AJUSTE (propriete du plan de volumes du jeu, non du seul T).
#      Depuis #215 (modele auxiliaire pondere, protocole d'actuary du
#      07/10/2026) : chaque jeu y* est REAJUSTE par usp_ajuster(x, y*), comme
#      dans run_engine(), et le TOST est calcule aux poids GLS de ce
#      reajustement (test_tost_intercept(x, y*, fit*$pi, theta)) ; avant
#      #215, sans reajustement (TOST MCO, ne dependant que de x et y*),
#      tableau docs/tableaux/20260930-issue118-tost.md.
#      Protocole (note d'actuary, section 4 ; reajustement : #215) :
#        - jeux J1 (tests/donnees/donnees_ln.csv, delta chapeau = 1) et J2
#          (xi, yi de tests/unitaires/test_controles_numeriques.R, delta
#          chapeau interieur), T = 8 ; modele ajuste par usp_ajuster() sur
#          le jeu observe ;
#        - R jeux y* par usp_simuler(fit) (generateur du bootstrap
#          parametrique), x fixe, tires en un seul flux par jeu (graine
#          --graine + 3 pour J1, --graine + 4 pour J2), tous tires avant
#          toute evaluation (flux inchange par #215) ;
#        - chaque y* reajuste par usp_ajuster(x, y*) ; un reajustement en
#          erreur est ECARTE, compte et restitue (le taux porte sur les
#          reajustements reussis) ;
#        - p = test_tost_intercept(x, y*, fit*$pi, theta = 0.10)$p ;
#          conclusion d'equivalence si p < alpha, alpha = 0,10 et 0,05 ; IC
#          de Clopper-Pearson ; plus petite p observee ;
#        - descripteurs deterministes du jeu observe : CV(x) (ecart-type en
#          T - 1 sur moyenne), levier pondere de l'origine xbar_w^2 / S_xx,w
#          aux poids GLS du jeu observe (usp_poids_gls(x, fit$pi) ramenes a
#          une moyenne de 1, ce qui redonne xbar^2 / S_xx a poids constants),
#          se(a)/Delta pondere du jeu observe contre 1/t_{1-alpha, T-2}. Conclure exige
#          Delta - |a| > t_{1-alpha, T-2} se(a) (regle du maximum), donc
#          se(a)/Delta < 1/t_{1-alpha, T-2} (condition necessaire) ; la
#          proportion de jeux simules qui la remplissent est donnee a titre
#          descriptif ;
#        - controles d'integrite : p egale a la p_asymptotique de la ligne
#          TOST de engine_table_tests(run_engine(...)) sur le jeu observe et
#          sur le premier jeu simule (J1 et J2) ; aucune p manquante parmi
#          les reajustements reussis ;
#          equivalence exacte, jeu par jeu, entre p < alpha et
#          Delta - |a| > t se(a) ; coherence du generateur (premier jeu du
#          flux identique a un tirage isole sous la meme graine, RNGkind() et
#          .Random.seed de l'appelant restaures).
#
#  C4. Puissance de Shapiro-Wilk (W) et de l'asymetrie de D'Agostino (Z) a
#      T = 8, echantillons i.i.d., HORS MODELE REGLEMENTAIRE. Statut : CONSTAT
#      DE SIMULATION sous des alternatives choisies.
#      Protocole (note d'actuary, section 4) :
#        - R echantillons de taille 8 par loi, nombres aleatoires communs :
#          une matrice d'uniformes tiree sous --graine + 5, transformee par
#          les fonctions quantiles de N(0,1) (niveau), t a 5 et 3 degres de
#          liberte, exp(1) et lognormale(0 ; 0,5) ;
#        - W par .shapiro_sur() ; p de W par sw_p_loi_nulle(W, 8) (loi nulle
#          simulee du moteur, p exacte de la ligne secondaire a pi chapeau
#          constant) et par la normalisation de Royston (p de
#          stats::shapiro.test(), p_asymptotique de la ligne principale) ; Z
#          et p de test_dagostino_skew() (p_asymptotique de la ligne) ;
#        - second tableau D'Agostino a T = 20, uniformes sous --graine + 6,
#          memes lois ;
#        - rejet si p < alpha, alpha = 0,10 et 0,05 ; IC de Clopper-Pearson ;
#        - portee : W et Z sont invariants par transformation affine
#          croissante ; a pi chapeau constant, les residus z du moteur sont
#          une telle transformation des log-ratios : la mesure vaut EXACTEMENT
#          pour les p ci-dessus quand les log-ratios sont i.i.d. de la loi
#          indiquee et pi chapeau constant ; pour les p Monte-Carlo retenues
#          par le moteur (lignes principales), elle n'est qu'APPROCHEE ;
#        - controles d'integrite : invariance affine (W, Z et leurs p) sur un
#          echantillon de chaque loi ; transcription contre run_engine() sur
#          J1 (W, p de Royston, Z et p de D'Agostino ; p par loi nulle
#          jusqu'a #302, qui retire sa ligne ; W et Z
#          des z egaux a ceux des log-ratios, pi chapeau constant) ; aucune p
#          manquante ;
#        - niveaux (ligne N(0,1)) : INFORMATIFS, aucun code de sortie n'en
#          depend (avis d'actuary du 30/09/2026). Pour la p par loi nulle
#          simulee, la loi nulle est figee (SEED_LOI_NULLE_SW, N = 20 000
#          tirages) : la vraie probabilite de rejet differe de alpha d'une
#          erreur de quantile d'ordre sqrt(alpha (1 - alpha) / N) (~0,002 a
#          alpha = 0,10), et tout critere en k ecarts-types sur R finirait par
#          echouer quand R croit. La sortie restitue k/R, l'IC de
#          Clopper-Pearson et cet ordre de grandeur ; la transcription de
#          sw_p_loi_nulle() reste controlee de facon deterministe contre
#          run_engine(). Les niveaux de Royston et de D'Agostino sont mesures
#          et commentes a partir des valeurs calculees, sans controle (p
#          approchees) ; la p retenue par le moteur sur la ligne D'Agostino
#          est Monte-Carlo (mc_nom "DAgo"), la p N(0,1) n'y est que
#          p_asymptotique ;
#        - contre t5 et t3, lois symetriques, le taux de rejet de D'Agostino
#          (asymetrie) n'est pas une puissance contre l'asymetrie mais une
#          distorsion de niveau sous queues lourdes : les tableaux parlent de
#          "taux de rejet".
#      C4.c (issue #335, decisions d'actuary) : p de Royston
#      de Shapiro-Francia, lue dans test_shapiro_francia() du moteur (aucune
#      copie de formule). Statut : CONSTAT DE SIMULATION pour toute la
#      sous-table.
#        - aucun tirage supplementaire, boucle separee (mesurer_normalite()
#          et ALPHAS_118 inchanges) : T = 8 sur la matrice de C4.a, T = 20
#          sur celle de C4.b, T = 5 = colonnes 1 a 5 de la matrice T = 8,
#          T = 10 = colonnes 1 a 10 de la matrice T = 20 ; echantillons
#          emboites (taux correles entre T = 5 et 8 et entre T = 10 et 20 ;
#          IC de deux T d'une meme matrice non comparables comme
#          independants ; T = 8 et T = 10 de matrices distinctes) ;
#        - niveau sous N(0,1) a T = 5, 8, 10 et 20 (T = 5, 10 et 20 pour le
#          seul desaccord des sources sur la borne basse du domaine de
#          validite de la transformation, 5 contre 10) ; puissance contre
#          t5, t3, exp(1) et LN(0 ; 0,5) a T = 8 seulement ; alpha = 0,10,
#          0,05 et 0,01 (ALPHAS_SF) ; IC de Clopper-Pearson ;
#        - la p de Royston est une approximation a n fini dont aucun niveau
#          exact n'est connu ; la p retenue de la ligne Shapiro-Francia du
#          moteur est la p Monte-Carlo (mc_nom "SF"), la p de Royston n'en
#          est que la p_asymptotique ;
#        - portee (formulation de C7) : coincide, echantillon par
#          echantillon, avec la ligne du moteur quand pi chapeau est
#          constant (W' invariant par transformation affine croissante) ;
#          n'est pas la frequence conditionnelle a l'evenement "pi chapeau
#          constant" ; a pi chapeau variable, rien ne justifie de
#          l'appliquer ;
#        - mise en garde de multiplicite propre : 4 T x 3 alpha = 12 IC de
#          niveau (les lignes de puissance n'y entrent pas) ; celle de
#          C4.a-C4.b (4 lignes x 2 alpha) inchangee ; niveaux INFORMATIFS ;
#        - rapprochement non bloquant avec la mesure hors depot d'actuary
#          du 17/10/2026 (R = 200 000, T = 8 ; protocole non versionne,
#          graine non publiee) : sa valeur dans l'IC de C4.c, oui ou non ;
#        - controles d'integrite : transcription contre run_engine() sur J1
#          (statistique et p_asymptotique de la ligne Shapiro-Francia =
#          test_shapiro_francia(z) a 1e-10 ; W' des z egal a celui des
#          log-ratios) ; invariance affine de W' et de sa p (premier
#          echantillon de chaque loi et de chaque T) ; aucune NA ; controle
#          BLOQUANT : a R = 20 000 et graine 20260927, lignes des tableaux
#          C4.a et C4.b identiques au caractere pres a celles de
#          docs/tableaux/20260930-issue118-normalite.md ("non comparable",
#          sans effet sur le code de sortie, sinon).
#
#  C5. Niveau du TOST de la constante a la frontiere a = +/- Delta (issue
#      #219 ; specification d'actuary, issue #175, commentaire 6058041254,
#      section "#219" ; decisions du mainteneur, PR #228, commentaire
#      6058031276, Q-4). Statut : CONSTAT DE SIMULATION du taux de conclusion
#      A TORT a l'equivalence, sous un generateur a constante (le modele de
#      l'annexe XVII n'en a pas). Partie executee seule (--partie
#      tost-frontiere), hors de --partie tout (duree).
#      Protocole :
#        - jeux J1 et J2 de C3 ; FIT0 = usp_ajuster() sur le jeu observe ;
#          L* = usp_simuler(FIT0), R jeux par jeu, x fixe, dans les FLUX DE C3
#          (graine --graine + 3 pour J1, + 4 pour J2, meme expression), tires
#          avant toute evaluation, communs aux trois valeurs de a ;
#        - Y*_t = a + L*_t : E[Y_t] = a + beta x_t, variance reglementaire
#          exacte (celle de L*) ; Delta = theta E[Ybar], theta = 0,10 ;
#          a+ = theta beta xbar / (1 - theta), a- = -theta beta xbar /
#          (1 + theta) (a = +/- theta E[Ybar]) ; a = 0 en colonne de
#          reference (memes y* que C3 : probabilite de conclure, non niveau) ;
#        - y* <= 0 (possible a a-) : ecarte et compte ; sinon reajustement
#          par usp_ajuster(x, y*) : erreur ecartee et comptee ; refus de #188
#          (usp_valider_ajustement(fit*, "premium")$ok FALSE, comme
#          run_engine()) ecarte et compte ; les taux portent sur les
#          replications retenues communes aux six cellules ; dans chaque
#          cellule, cas non applicables et erreurs du test retires du
#          denominateur et comptes ;
#        - regle de lecture du denominateur (decision du mainteneur, PR
#          #228, commentaire 6062485163) : le taux est conditionnel au rendu
#          d'un resultat par l'outil (denominateur commun = replications
#          retenues ; comparaisons W0/W1/W2 appariees) ; pour un couple
#          (jeu, a) avec e > 0 replications ecartees (y* <= 0, erreurs,
#          refus de #188), la lecture verifie que la classe reste la meme
#          avec le taux majorant (k + e) / (n + e) (colonne "Classe avec le
#          majorant" de C5.a : "classe stable" ou "change") ;
#        - six cellules, toutes par test_tost_intercept() : poids W1 (outil,
#          fit*$pi), W2 (oracle, FIT0$pi), W0 (MCO d'avant #215 : pi0 =
#          1 / log1p((xbar / x)^2), d'ou des poids usp_poids_gls() constants,
#          controle max|w/w_1 - 1| < 1e-12) ; marge estimee Delta* = theta
#          moyenne(y*) (celle de l'outil) ou fixee a priori, delta_abs =
#          theta E[Ybar] = theta (a + beta xbar) (= |a| aux frontieres) ;
#          resultat "non applicable" ou erreur du test compte par cellule ;
#        - conclusion si p < alpha, alpha = 0,10 et 0,05 ; IC de
#          Clopper-Pearson ; lecture : tenu si la borne basse de l'IC <=
#          alpha ; depassement mineur si l'IC est au-dessus de alpha et
#          l'estimation <= 1,5 alpha ; distorsion materielle si la borne
#          basse > 1,5 alpha ; depassement non tranche (classe ajoutee par
#          le mainteneur, PR #228, commentaire 6062485163) si la borne basse
#          est dans ]alpha ; 1,5 alpha] et l'estimation > 1,5 alpha
#          (depassement significatif, materialite non etablie a R donne).
#          Suites : tenu et depassement mineur, aucune ; distorsion
#          materielle et depassement non tranche, mainteneur, renvoi a #216
#          et #217 ;
#        - ligne de rapprochement avec C3 : a = 0, W1, marge estimee, taux sur
#          les reajustements reussis refus de #188 compris (C3 n'applique pas
#          usp_valider_ajustement()) : egal au tableau C3.a de --partie tost
#          a R et graine egaux ; a R = 20 000 et --graine 20260927, une ligne
#          compare C5.c au tableau versionne
#          docs/tableaux/20261007-issue215-tost.md (commit a7724d4) :
#          "identique" ou l'ecart, non bloquant (hors controles) ;
#        - controles d'integrite : premiere p de chaque cellule (premiere
#          replication retenue, par jeu et valeur de a) egale a la
#          p_asymptotique de la ligne TOST de run_engine() pour W1 (marge
#          estimee : theta_equiv par defaut ; marge a priori : delta_equiv =
#          delta_abs), et a un TOST transcrit par lm() (poids
#          1 / (x^2 expm1(1/pi)), ou sans poids pour W0) pour W2 et W0,
#          run_engine() ne calculant pas ces poids ; equivalence exacte, jeu
#          par jeu, entre p < alpha et Delta - |a| > t se(a) ; poids W0
#          constants ; marge a priori restituee egale a theta (a + beta xbar)
#          (et a |a| aux frontieres) ; premier L* identique a un tirage isole
#          sous la meme graine ; RNGkind() et .Random.seed de l'appelant
#          restaures.
#
#  C6. Test de Pitman sur la pente (usp_permutation_pente(), #169) a T = 8 :
#      verdicts, puissances, tailles sous des hypotheses nulles faibles et
#      variantes de sens (issue #220 ; specification d'actuary, issue #175,
#      commentaire 6058041254, section "#220"). Statut : CONSTATS DE
#      SIMULATION. Les valeurs citees jusqu'ici (.tex : "environ 63/25/12 %" ;
#      ADR 0002 amende le 06/10/2026, points 4 et 5 : 0,641, 0,116, 0,471,
#      0,256, 0,095 a 0,272, 0,092 a 0,093, 0,510 / 0,997, 0,003 / 0,000,
#      0,487 / 0,450 ; issue #220 : 0,644, 0,641, 0,646) n'ont pas de script
#      versionne et leur protocole est perdu : C6 le redefinit sans pretendre
#      le reproduire ; les nouvelles valeurs remplacent les anciennes, et le
#      tableau C6.f dit seulement si chaque ancienne valeur tombe dans le
#      nouvel IC. Partie executee seule (--partie pitman), hors de --partie
#      tout (duree).
#      Commun : alpha = defaut de run_engine() (0,10) ; p = p de permutation
#      unilaterale de usp_permutation_pente(x, y) (enumeration des T!
#      appariements a T = 8, sens SENS_PITMAN_PENTE) ; verdicts du sens
#      "rejeter" (engine_registre_tests()) : OK si p < alpha, ALERTE si
#      p < SEUIL_ECHEC_SENS_REJETER, ECHEC sinon ; R1 (p_min >= alpha) et
#      non-applicabilite (t non fini) appliquees comme usp_tests() (attendues
#      nulles a T = 8, colonnes comptees) ; p de Student unilaterale
#      pt(t, T - 2, lower.tail = FALSE), t = test_lm_complet(x, y)$t_pente.
#      G1 (verdicts sous le modele ajuste) : jeux J1 et J2 de C3, x fixe,
#        FIT0 = usp_ajuster() sur le jeu observe ; R jeux y* simules par
#        l'expression de #72 (affectation de YSIM de
#        tests/taux_franchissement_reperes.R, relue et comparee : controle),
#        un seul flux par jeu sous --graine (20260927 par defaut), meme graine
#        pour J1 et J2 : les 2 000 premiers jeux sont ceux de #221 ;
#        P1, sans R4 : modalite de la p ; P2, avec R4 : y* reajuste par
#        usp_ajuster(x, y*), diagnostic si la puissance unilaterale approchee
#        usp_identifiabilite_pente(x, beta*, sigma*, alpha, unilateral = TRUE)
#        < SEUIL_PUISSANCE_PENTE_R4 (comme usp_tests() avant D1-Fb) ;
#        reajustement en erreur exclu de P2 et compte ; refus de #188, #227 (usp_valider_ajustement())
#        compte, non exclu (comme traiter() de #72) ; distribution sur les
#        modalites OK, ALERTE, ECHEC, diagnostic (R4) (plus R1 et non
#        applicable), et conditionnelle aux lignes de P2 restees "test" ;
#        refus de #188 : s'il y en a, chaque taux de P2 est lu a k_refus / n
#        pres (avis A6 d'actuary) ;
#      G2 (puissances, sans R4, memes y*) : P(p < alpha) de la permutation et
#        du Student unilateral ; pi_b observe = usp_identifiabilite_pente()
#        unilaterale au modele ajuste au jeu observe (deterministe) ;
#      G3 (tailles sous des H0 faibles, sans R4, --R-h0 replications par
#        scenario, 10 000 par defaut) : Y_t = mu + (x_t / xbar)^k eps_t,
#        k dans {0 ; 0,5 ; 1 ; 2 ; 3}, eps i.i.d. N(0, 1), memes eps pour
#        tous les k et les deux jeux (--graine + 11) ; marche aleatoire
#        Y_t = mu + somme_{s <= t} e_s (--graine + 12) ; AR(1) stationnaire
#        rho = 0,7, u_1 = e_1 / sqrt(1 - rho^2) (--graine + 13) ; volumes de J1
#        (CV(x) = 9,74 %) et de J2 (64,19 %) ; mu = 0 (r invariant par
#        transformation affine croissante de y) ; reference exacte a k = 0
#        (H0 i.i.d., echangeable, T! valeurs de r distinctes) : 4031/40320,
#        ligne "dans l'IC" informative (hors controles) ;
#      G4 (variantes de sens, sans R4) : sur les y* de G1, unilateral (moteur),
#        bilateral pur (p_bilateral de usp_permutation_pente()) et bilateral
#        avec regle de signe (ECHEC si r < 0, verdict de p_bilateral sinon) ;
#        pente negative : y* simules par usp_simuler() au modele ajuste
#        deplace aux volumes reflechis x' = min x + max x - x (beta inchange,
#        pi' = usp_pi(delta, gamma, x')), un flux par jeu sous --graine + 14
#        (meme graine pour J1 et J2), test de r(x, y*) sous les trois
#        variantes, plus la ligne "P2 avec R4" (R4 par reajustement de chaque
#        jeu, avis A5) ; signe de r (C6.d bis, avis A4) : pour G1 et G4 pente
#        negative, replications ou r < 0 et, parmi elles, p <
#        SEUIL_ECHEC_SENS_REJETER et p < alpha ; P(r* >= 0) sous la loi de
#        permutation des jeux observes,
#        par enumeration (r_enumeration(), copie declaree du calcul de
#        usp_permutation_pente(), controlee), deterministe ;
#      matrices de G3 et jeux de G1 et G4 tires en une fois, par ligne : les
#      jeux d'une execution a R plus petit sont les premiers ;
#      controles d'integrite : expression de #72 identique ; premier jeu de
#      chaque flux de G1 et G4 identique a un tirage isole ; aucune p de
#      permutation manquante ; p, type et verdict (modalite P1, sans R4 :
#      regle du moteur depuis D1-Fb, #218, #230) de la premiere replication
#      de G1 et de G4 pente negative, de la premiere replication de G1 que
#      R4 classait diagnostic s'il y en a une (sinon ligne non bloquante) et
#      des replications de G1 dont la puissance approchee est la plus proche
#      de SEUIL_PUISSANCE_PENTE_R4 de chaque cote, identiques a p_exacte,
#      type et verdict de la ligne Pitman de run_engine() (J1 et J2) ; P2
#      (avec R4, diag_r4()) n'est plus qu'une reproduction historique de la
#      regle des mesures anterieures, sans controle croise avec le moteur ;
#      aucun refus de #188 dans P2 sur les replications 1 a min(R, 2 000)
#      (jeux de #221) ; enumeration transcrite egale a
#      usp_permutation_pente() sur les jeux observes ; invariance affine de G3
#      ((3 x, 1000 + 7 y) : p de permutation identiques, p de Student egales a
#      1e-10, 100 premieres replications de chaque scenario) ; RNGkind() et
#      .Random.seed de l'appelant restaures ; controle croise de R4 avec #221
#      (--ref-221, facultatif) : compte R4 de P2 sur les replications d'un
#      fichier de #221 (tranche de tests/taux_franchissement_reperes.R,
#      COMPTE k|pente ; tableau combine de ce script, ligne R4 de T1 bis ;
#      tranche de tests/calibration_mc_t8.R, COMPTE de la ligne Pitman de
#      type diagnostic ; graine des jeux egale a --graine) egal au compte du
#      fichier ; references lues et validees avant le calcul ; fichier absent
#      ou illisible (repertoire compris), alpha different de celui de C6, n
#      different de fin - debut + 1 ou replications hors de 1..R : ligne "non
#      comparable", sans effet sur le code de sortie ; avec --ecrire et
#      R >= 2 000, --ref-221 est obligatoire, chaque reference doit etre
#      lisible et J1 et J2 compares (refus avant calcul sinon).
#      C6.f : plages du .tex (0,095 a 0,106 ; 0,20 a 0,27) en min-max des
#      tailles de G3 (k dans {1 ; 2 ; 3}, puis six scenarios hors k = 0),
#      rattachement presume, sans verdict d'IC ; reference de G3 a k = 0 :
#      taille exacte 4031/40320 (permutation) et alpha (Student, eps normaux).
#
#  C7. Niveau de la regle ESD generalisee de Rosner a T = 8 (issue #174 ;
#      l'issue, du 30/09/2026, cite une mesure anterieure, hors depot et non
#      versionnee : 0,152 et 0,099 ; la mesure du 15/10/2026,
#      docs/revues/20261015-pertinence-tests-graphiques/mesures/bloc-4/sim.R,
#      commit e990a9f, l'a reproduite (0,1515 ; 0,0992) et est recalculee en
#      C7.c). Statut, trois cas :
#      C7.0, valeurs critiques DETERMINISTES ; premiere etape seule sous
#      i.i.d. normal, niveau EXACTEMENT alpha (RESULTAT EXACT, demonstration
#      ci-dessous ; la colonne simulee en est le controle) ; tout le reste,
#      CONSTAT DE SIMULATION. Partie executee seule (--partie esd), hors de
#      --partie tout (duree du volet C7.b).
#      Demonstration (premiere etape, i.i.d. normal, n = T = 8,
#      u_t = (x_t - xbar) / s) : (i) pour un indice t fixe,
#      u -> u sqrt(n (n - 2) / ((n - 1)^2 - n u^2)) est strictement
#      croissante sur [0, (n - 1) / sqrt(n)), et l'image de |u_t| suit
#      exactement la loi de |t(n - 2)| (loi de la fiche Grubbs) ; lambda1
#      est l'image reciproque de t_{1 - alpha/(2n), n - 2}, donc
#      P(|u_t| > lambda1) = alpha / n ; (ii) somme des u_t^2 = n - 1 = 7 et
#      2 lambda1^2 > 7 (8,255 a alpha = 0,10 ; 9,045 a 0,05 ; controle
#      bloquant, lambda1 lu dans test_rosner()) : deux depassements
#      simultanes sont impossibles ; (iii) les n evenements sont disjoints et
#      P(R1 > lambda1) = alpha ; la colonne simulee en est le controle (non
#      bloquant : "alpha dans l'IC de la premiere etape : oui / non").
#      Protocole :
#        - toutes les quantites sont lues dans la sortie de test_rosner() du
#          moteur (nb_outliers = k chapeau, R, lambda), sans copie de sa
#          formule ; k par defaut, floor(T / 4) = 2 a T = 8 (controle) ;
#          alpha = defaut de run_engine() (0,10) et 0,05 ; verdict de la
#          ligne du moteur : ALERTE si k chapeau = 1, ECHEC si 2 ;
#        - par alpha : P(k chapeau >= 1) (ALERTE ou ECHEC), P(k chapeau = 2)
#          (ECHEC), P(k chapeau = 1), premiere etape seule P(R1 > lambda1),
#          et P(R2 > lambda2, R1 <= lambda1), part que la seconde etape
#          (n = 7) ajoute a la premiere ; IC de Clopper-Pearson ; valeurs
#          critiques lambda1, lambda2 (deterministes) restituees ;
#        - C7.a : R echantillons i.i.d. N(0,1) de taille 8, un flux sous
#          --graine + 7, matrice remplie par ligne (les echantillons d'une
#          execution a R plus petit sont les premiers) ; portee : C7.a est
#          la frequence de decision de la regle sur huit observations i.i.d.
#          normales ; elle coincide, replication par replication, avec la
#          ligne du moteur lorsque pi chapeau est constant (z affine
#          croissante des log-ratios) ; elle n'est pas la frequence
#          conditionnelle a l'evenement "pi chapeau constant", qui depend des
#          donnees ; a pi chapeau variable, z n'est pas i.i.d. et C7.a ne
#          s'applique pas ;
#        - C7.b : sous le modele ajuste a J1 et a J2 (jeux de C3), --R-modele
#          jeux y* par jeu (defaut : --R),
#          du flux de #72 (EXPR_YSIM_72, graine --graine, meme graine pour
#          J1 et J2 : les 2 000 premiers jeux sont ceux de #166 et #221),
#          reajustes par usp_ajuster(x, y*), test_rosner() sur les residus z
#          du reajustement (comme usp_tests()) ; reajustement en erreur ou z
#          non finis ecartes et comptes ; nombre de reajustements a pi
#          chapeau constant restitue ;
#        - C7.c : mesure du 15/10/2026 recalculee (sim.R ci-dessus, section
#          2 : engine_sous_graine(20261015, matrix(rnorm(1e5 * 8), 1e5, 8)),
#          lignes 1 a 50 000, test_rosner(v, k = 2, alpha = 0.10)) ; k / n et
#          IC de cette mesure et de C7.a a alpha = 0,10 pour P(k chapeau >= 1),
#          P(k chapeau = 2) et la premiere etape ; estimation de C7.a dans
#          l'IC du 15/10 ; z et p bilaterale du test de deux proportions
#          independantes (flux distincts, proportion commune en pool,
#          approximation normale) ; phrase de lecture construite sur ces
#          valeurs (ecart nominal p < 0,05, Bonferroni sur les trois
#          comparaisons, alpha = 0,10 dans l'IC du 15/10 de la premiere
#          etape) ;
#        - C7.d (non bloquant) : repartition OK / ALERTE / ECHEC de C7.b a
#          alpha = 0,10 sur les replications 1 a 2 000 contre celle de la
#          ligne ESD de #166 (docs/tableaux/20261008-issue166-calibration-
#          J1.md et -J2.md, commit 139031d : J1 1721 / 172 / 107, J2
#          1778 / 123 / 99 ; run_engine() complet, meme flux de jeux) ;
#          "identique" ou "ecart" ; "non comparable" si --R-modele < 2 000 ou
#          --graine different de 20260927 ;
#        - controles d'integrite : k = 2, R et lambda finis sur toutes les
#          replications ; identites de lecture k chapeau >= 1 <=> (R1 >
#          lambda1 ou R2 > lambda2) et k chapeau = 2 <=> R2 > lambda2 sur
#          toutes les replications ; invariance de k chapeau et de R par
#          v -> 3 + 0,2 v et v -> -5 - 7 v (100 premiers echantillons i.i.d.) ;
#          estimation et verdict de la ligne ESD de run_engine() egaux a
#          test_rosner(usp_ajuster(x, y)$z) sur J1 et J2 observes et sur le
#          premier jeu simule de chacun ; J1 observe (pi chapeau constant) :
#          R identique sur z et sur les log-ratios ; expression de #72 relue
#          et identique ; premier tirage de chaque flux identique a un tirage
#          isole ; RNGkind() et .Random.seed de l'appelant restaures ;
#          2 lambda1^2 > T - 1 pour chaque alpha ; C7.c : ENGINE_RNG_KIND
#          egal aux types par defaut de R et engine_sous_graine(20261015, .)
#          egal a set.seed(20261015), taux du 15/10 arrondis a 4 decimales
#          egaux a 0,1515 ; 0,0623 ; 0,0992 (docs/revues/20261015-pertinence-
#          tests-graphiques/bloc-4.md, section 4.4).
#      Tableau versionne (arbre propre) :
#          Rscript tests/constats_puissance_t8.R --partie esd --R 1000000
#              --R-modele 20000 --ecrire docs/tableaux
#      duree mesuree de cette configuration (sans --ecrire, 17-18/10/2026) :
#      1 376 s, dont 101 s pour C7.a, 1 261 s pour C7.b (0,032 s par
#      replication et par jeu) et 13 s de controles, sur un conteneur de
#      4 coeurs partages (charge moyenne sur 1 min entre 4,1 et 6,2 pendant
#      l'execution) ; Linux, R 4.3.3.
#
#  Incertitude : intervalle de Clopper-Pearson a 95 % sur chaque taux
#  (erreur Monte-Carlo, fonction de R ; elle ne dit rien de l'erreur
#  d'approximation en T). Compatibilite avec la valeur publiee :
#    C1 : la valeur publiee est elle-meme une estimation Monte-Carlo sur
#      20 000 tirages (arrondie au millieme, erreur d'arrondi <= 0,0005,
#      petite devant l'ecart-type ~0,003) ; les deux estimations sont
#      comparees par l'ecart normalise z de deux proportions independantes
#      (ecart_z()), compatibles si |z| <= 1,96 (niveau 5 % par comparaison,
#      huit comparaisons non corrigees pour la multiplicite) ;
#    C2 : taux publie 0 / 3 000 ; test exact de Fisher bilateral
#      (stats::fisher.test()) sur le tableau 2 x 2 (k, n - k ; 0, 3 000) de la
#      reproduction et du constat publie, compatible si p >= 0,05 (les deux
#      echantillons sont traites comme independants ; lectures K0 a K3 non
#      corrigees pour la multiplicite).
#    C3, C4, C5 : mesures nouvelles, sans valeur publiee a comparer ; IC seul.
#    C6 : IC seul ; ancienne valeur dans le nouvel IC ou non (C6.f), sans
#      test de compatibilite (protocole d'origine perdu).
#    C7 : IC ; mesure du 15/10/2026 recalculee contre C7.a (C7.c) : C7.a
#      dans l'IC du 15/10 ou non, et test de deux proportions independantes
#      (z, p bilaterale ; Bonferroni sur trois comparaisons dans la phrase
#      de lecture).
#
#  Alea : tout tirage passe par engine_sous_graine() avec une graine
#  explicite : innovations AR(1) sous --graine ; echantillons K0, K2, K3 sous
#  --graine + 1 ; jeux simules de K1 sous --graine + 2 ; jeux y* de C3 sous
#  --graine + 3 (J1) et --graine + 4 (J2) ; uniformes de C4 sous --graine + 5
#  (T = 8) et --graine + 6 (T = 20), repris par C4.c sans flux propre
#  (colonnes 1 a 5 et 1 a 10 pour T = 5 et 10) ; C5 reprend les flux de C3 (--graine + 3
#  et + 4), sans flux propre ; C6 : jeux du modele ajuste sous --graine
#  (flux de #72), G3 sous --graine + 11 a + 13, pente negative sous
#  --graine + 14 ; C7 : echantillons i.i.d. sous --graine + 7, jeux du
#  modele ajuste sous --graine (flux de #72) ; chaque flux tire en une fois avant tout
#  calcul. Les parties sont independantes : ajouter C3 et C4 ne change ni les
#  tirages ni la sortie de --partie ar1 et de --partie ks a graine egale
#  (hors lignes de duree ; sous --partie tout, seul le titre change et les
#  sections C3 et C4 s'ajoutent apres C2). La reproduction du fichier
#  versionne de #114 (docs/tableaux/20260927-issue114-constats-puissance.md)
#  se compare section par section (corps de C1 et de C2) : le titre, le
#  commit et les durees different. La loi nulle de
#  W vient du cache du moteur (sw_loi_nulle(), graine SEED_LOI_NULLE_SW).
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/constats_puissance_t8.R [--R 20000] [--R-ks 3000]
#          [--graine 20260927] [--partie tout|ar1|ks|tost|normalite|tost-frontiere|pitman|esd]
#          [--R-h0 10000] [--ref-221 FICHIER[,FICHIER...]] [--R-modele R]
#          [--ecrire DOSSIER [--remplacer]]
#  --partie tout : C1 a C4 ; C5 seulement par --partie tost-frontiere, C6
#  seulement par --partie pitman, C7 seulement par --partie esd.
#  --R vaut pour C1 (par rho), C3 (par jeu), C4 (par loi et par T), C5
#  (par jeu et par valeur de a), C6 (G1, G2, G4, par jeu) et C7.a ;
#  --R-modele (--partie esd seulement, refus d'usage sinon ; defaut : --R)
#  pour C7.b (par jeu) ; --R-h0 pour G3
#  de C6 (par scenario et par jeu) ; --ref-221 (--partie pitman seulement,
#  refus d'usage sinon) : sorties de #221 pour le controle croise de R4,
#  obligatoire avec --ecrire quand R >= 2 000 (refus avant calcul sinon).
#  --ecrire DOSSIER : ecrit en plus, si les controles d'integrite tiennent,
#  DOSSIER/<AAAAMMJJ>-issue215-tost.md (issue118 avant #215),
#  <AAAAMMJJ>-issue118-normalite.md et/ou
#  <AAAAMMJJ>-issue219-tost-frontiere.md et/ou
#  <AAAAMMJJ>-issue220-pitman.md et/ou <AAAAMMJJ>-issue174-esd.md (date du
#  jour), pour les parties tost, normalite, tost-frontiere, pitman et esd
#  executees ; sans cette
#  option, rien n'est ecrit. Les fichiers versionnes de docs/tableaux/ se
#  produisent sur un arbre de travail propre (commit cite resoluble), par
#  --partie tost --ecrire docs/tableaux, --partie normalite --ecrire
#  docs/tableaux, --partie tost-frontiere --ecrire docs/tableaux, --partie
#  pitman --ecrire docs/tableaux et --partie esd --ecrire docs/tableaux. Garde de l'arbre propre (#205,
#  motifs_non_versionnable() de tests/outils_tests.R) : pour les parties qui
#  ecrivent et un DOSSIER sous la racine du depot (ecrit versionnable ; un
#  DOSSIER hors du depot n'est pas garde), --ecrire est REFUSE (code 1, rien
#  d'ecrit) si le commit lu au debut du calcul (commit_depot(), cite par le
#  T0 de la console et des fichiers) n'est pas un SHA nu (arbre de travail
#  modifie, script non suivi ou git indisponible) ; evaluee des l'analyse
#  des options, avant tout calcul, puis de nouveau avant l'ecriture, sur ce
#  commit et sur le commit courant. Garde d'ecrasement (#173, garde_ecrasement() de
#  tests/outils_tests.R, avant toute ecriture) : --ecrire est REFUSE (code
#  1, aucun des fichiers de l'execution ecrit) si l'un des fichiers cibles
#  est suivi par git, ou existe sans que git puisse dire s'il l'est (un
#  fichier hors du depot n'est pas suivi : comportement inchange) ;
#  --remplacer (avec --ecrire seulement, refus d'usage sinon) autorise le
#  remplacement d'un fichier suivi, et le tableau de contexte du fichier
#  ecrit cite alors le fichier remplace et son md5 d'avant. La garde est
#  evaluee une premiere fois des l'analyse des options, avant tout calcul
#  (chemins connus par la partie, le dossier et la date), puis de nouveau
#  avant l'ecriture (#205).
#  Duree mesuree : voir la ligne "Duree" de la sortie (C1 et C2 : 72 s et
#  124 s le 27/09/2026 ; a R = 20 000, C3 : 44 s et C4 : 28 s le 30/09/2026,
#  soit 44 s et 33 s d'execution pour --partie tost et --partie normalite ;
#  C4.c : 13,6 s a R = 20 000 le 18/10/2026, --partie normalite 42 s en
#  tout, dont C4 hors C4.c : 23 s ; Linux, R 4.3.3 ;
#  C5 : 0,068 s par replication, par jeu et par valeur de a, plus environ
#  50 s de controles, mesure a R = 200 le 08/10/2026, soit environ 2,3 h
#  sur un coeur a R = 20 000 ; C6 : 0,063 s par replication et par jeu pour
#  G1, G2 et les variantes de G4 (reajustement de R4 compris), 0,064 s pour
#  G4 pente negative (reajustement de R4 compris depuis l'avis A5), 0,0078 s
#  par replication, par scenario et par jeu pour G3, plus environ 33 s de
#  controles, mesure a R = --R-h0 = 200 le 08/10/2026 sur un conteneur dont
#  les 4 coeurs etaient occupes, soit environ 1,7 h sur un coeur a
#  R = 20 000 et --R-h0 = 10 000 ; Linux, R 4.3.3 ; C7 : 1 306 s a
#  R = --R-modele = 20 000 le 17/10/2026, dont 2 s pour C7.a et 1 294 s pour
#  C7.b, soit 0,032 s par replication et par jeu, et 9 s de controles, sur un
#  conteneur de 4 coeurs partages ; Linux, R 4.3.3).
#  Code de sortie : 0 si les controles d'integrite tiennent, 1 sinon.
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
OPT_R      <- as.integer(lire_option("--R", "20000"))
OPT_R_KS   <- as.integer(lire_option("--R-ks", "3000"))
OPT_GRAINE <- as.numeric(lire_option("--graine", "20260927"))
OPT_PARTIE <- lire_option("--partie", "tout")
OPT_ECRIRE <- lire_option("--ecrire", NA_character_)
OPT_REMPLACER <- "--remplacer" %in% ARGS
# Partie pitman (#220) : replications par scenario de G3 et references de
# #221 pour le controle croise de R4 (facultatives).
OPT_R_H0   <- as.integer(lire_option("--R-h0", "10000"))
OPT_REF_221 <- lire_option("--ref-221", NA_character_)
# Partie esd (#174) : jeux du modele ajuste par jeu pour C7.b (defaut : --R).
OPT_R_MODELE <- as.integer(lire_option("--R-modele", as.character(OPT_R)))
if (!OPT_PARTIE %in% c("tout", "ar1", "ks", "tost", "normalite", "tost-frontiere", "pitman", "esd"))
  stop("--partie : tout, ar1, ks, tost, normalite, tost-frontiere, pitman ou esd")
if (OPT_REMPLACER && is.na(OPT_ECRIRE)) stop("--remplacer : reserve a --ecrire (remplacement d'un tableau suivi par git, #173)")
if (!is.na(OPT_ECRIRE) && !dir.exists(OPT_ECRIRE)) stop("--ecrire : dossier inexistant : ", OPT_ECRIRE)
if (!is.finite(OPT_R) || OPT_R < 1L) stop("--R : entier >= 1")
if (!is.finite(OPT_R_KS) || OPT_R_KS < 1L) stop("--R-ks : entier >= 1")
if (!is.finite(OPT_GRAINE)) stop("--graine : nombre")
if (!is.finite(OPT_R_H0) || OPT_R_H0 < 1L) stop("--R-h0 : entier >= 1")
if (!is.na(OPT_REF_221) && OPT_PARTIE != "pitman") stop("--ref-221 : reserve a --partie pitman")
if ("--R-modele" %in% ARGS && OPT_PARTIE != "esd") stop("--R-modele : reserve a --partie esd")
if (!is.finite(OPT_R_MODELE) || OPT_R_MODELE < 1L) stop("--R-modele : entier >= 1")
# Ecriture du tableau de C6 a R >= 2 000 (jeux de #221) : controle croise de
# R4 obligatoire (constat m4 de l'audit de #220) ; refus avant tout calcul.
if (!is.na(OPT_ECRIRE) && OPT_PARTIE == "pitman" && OPT_R >= 2000L && is.na(OPT_REF_221))
  stop("--ecrire avec --partie pitman et --R >= 2000 : --ref-221 obligatoire (sorties de #221 pour J1 et J2)")

T_ <- 8L
ALPHA_AR1 <- 0.10
ALPHA_KS <- 0.05
# Constat publie de C2 : 0 rejet sur 3 000.
K_PUB_KS <- 0L
N_PUB_KS <- 3000L
RHOS <- c(0, 0.3, 0.5, 0.7, 0.9)
# Valeurs publiees (commentaire d'actuary du 23/09/2026 sur #44) ; NA : non publiee.
PUB_SUITES <- c(NA, 0.080, 0.118, 0.175, 0.247)
PUB_DW     <- c(NA, 0.163, 0.268, 0.395, 0.529)

# --- Chargement du moteur et des outils --------------------------------------
DOSSIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) dirname(f) else if (file.exists("tests/outils_tests.R")) "tests" else "."
})
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))

# commit_depot() et motifs_non_versionnable() : tests/outils_tests.R (#205).

# Commit lu une fois, au debut du calcul (#205) : cite par le T0 de la
# console et par celui de chaque fichier ecrit ; une execution longue ne
# consigne pas un commit fait pendant son calcul.
COMMIT <- commit_depot("tests/constats_puissance_t8.R")
# Garde anticipee de l'arbre propre (#205) : avec --ecrire vers un DOSSIER
# sous la racine du depot (ecrit versionnable ; hors du depot, aucune garde,
# comme --sortie des autres scripts) et une partie qui ecrit, avant tout
# calcul, refus (code 1, rien d'ecrit) si le commit n'est pas un SHA nu
# (arbre de travail modifie, script non suivi ou git indisponible) ; reprise
# avant l'ecriture, sur ce commit et sur le commit courant (l'etat du depot
# peut changer pendant le calcul). Aucune ligne d'empreintes dans ce script
# (empreintes = "" : seul le motif du commit s'applique).
# sous_depot() : copie de tests/taux_franchissement_reperes.R (chemin
# existant sous la racine du depot).
sous_depot <- function(chemin) {
  # separateur "/" sur toutes les plateformes (normalizePath() rend des "\\"
  # sous Windows, ou .Platform$file.sep vaut pourtant "/") ; casse ignoree
  # sous Windows, dont le systeme de fichiers ne la distingue pas
  d <- normalizePath(chemin, winslash = "/", mustWork = TRUE)
  r <- normalizePath(RACINE, winslash = "/", mustWork = TRUE)
  if (.Platform$OS.type == "windows") { d <- tolower(d); r <- tolower(r) }
  identical(d, r) || startsWith(d, paste0(r, "/"))
}
refus_non_versionnable <- function(nv) {
  message("--ecrire refuse (tableau versionne) : ", paste(nv, collapse = " ; "),
          " -- aucun fichier ecrit ; relancer sur un arbre propre")
  quit(status = 1L)
}
ECRIRE_VERSIONNABLE <- !is.na(OPT_ECRIRE) && sous_depot(OPT_ECRIRE)

# Garde d'ecrasement anticipee (#205) : les chemins cibles de --ecrire ne
# dependent que des options (partie, dossier) et de la date ; controles ici,
# avant tout calcul (code 1, rien d'ecrit, si un fichier cible suivi par git
# n'est pas a remplacer), puis de nouveau avant l'ecriture (le depot peut
# changer pendant le calcul ; date de l'ecriture, qui peut differer de
# celle-ci si l'execution passe minuit). Seule source des chemins :
# chemins_118().
ISSUE_118 <- c(tost = "215", normalite = "118", "tost-frontiere" = "219", pitman = "220", esd = "174")
chemins_118 <- function(parties) stats::setNames(
  file.path(OPT_ECRIRE, sprintf("%s-issue%s-%s.md", format(Sys.Date(), "%Y%m%d"), ISSUE_118[parties], parties)),
  parties)
PARTIES_118 <- c(if (OPT_PARTIE %in% c("tout", "tost")) "tost", if (OPT_PARTIE %in% c("tout", "normalite")) "normalite",
                 if (OPT_PARTIE == "tost-frontiere") "tost-frontiere", if (OPT_PARTIE == "pitman") "pitman",
                 if (OPT_PARTIE == "esd") "esd")
if (ECRIRE_VERSIONNABLE && length(PARTIES_118)) {
  nv0 <- motifs_non_versionnable(COMMIT, "", "de l'ex\u00e9cution")
  if (length(nv0)) refus_non_versionnable(nv0)
}
if (!is.na(OPT_ECRIRE) && length(PARTIES_118)) garde_ecrasement(chemins_118(PARTIES_118), OPT_REMPLACER, RACINE)

# Plateforme de calcul (#171) : R, systeme, machine, BLAS, LAPACK (copie
# declaree de plateforme_calcul() de tests/calibration_mc_t8.R), ligne de T0.
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(extSoftVersion()["BLAS"]), txt(La_library()), txt(La_version()))
}

# Console en UTF-8 quelle que soit la locale (meme definition que
# tests/taux_franchissement_reperes.R).
ecrire_console <- function(x) writeLines(enc2utf8(x), useBytes = TRUE)

# --- Mise en forme -------------------------------------------------------------
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
num <- function(x, d = 3) if (is.na(x)) "\u2014" else sub(".", ",", sprintf(paste0("%.", d, "f"), x), fixed = TRUE)
ic_cp <- function(k, n) {
  ci <- stats::binom.test(k, n)$conf.int
  c(ci[1], ci[2])
}
txt_ic <- function(ci) sprintf("[%s ; %s]", num(ci[1]), num(ci[2]))
# Ecart normalise entre deux estimations independantes d'une meme proportion
# (reproduction sur R tirages, publication sur R_PUB) : z = (p1 - p2) /
# sqrt(pbar (1 - pbar) (1/R + 1/R_PUB)), pbar ponderee ; compatible si |z| <= 1,96.
R_PUB <- 20000
ecart_z <- function(k, n, pub) {
  pbar <- (k + pub * R_PUB) / (n + R_PUB)
  (k / n - pub) / sqrt(pbar * (1 - pbar) * (1 / n + 1 / R_PUB))
}
compat <- function(pub, k, n) if (is.na(pub)) c("\u2014", "\u2014") else {
  z <- ecart_z(k, n, pub)
  c(sub(".", ",", sprintf("%+.2f", z), fixed = TRUE), if (abs(z) <= stats::qnorm(0.975)) "oui" else "**non**")
}

INTEGRITE <- TRUE
controle <- function(ok, libelle) {
  if (!isTRUE(ok)) INTEGRITE <<- FALSE
  sprintf("%s : %s", libelle, if (isTRUE(ok)) "OK" else "ECHEC")
}

# p-value de Kolmogorov de la ligne "Kolmogorov-Smirnov contre N(0,1)" de
# usp_tests() (transcription ; controlee contre run_engine() plus bas).
p_kolmogorov <- function(dd, T) {
  if (is.finite(dd)) .p_borne(2 * sum((-1)^(0:99) * exp(-2 * (1:100)^2 * T * dd^2))) else NA_real_
}

# Titre : inchange pour les parties de #114 (sortie de ar1 et ks identique a
# graine egale a celle du script avant #118).
TITRE_ISSUES <- switch(OPT_PARTIE, ar1 = , ks = "issue #114", tost = , normalite = "issue #118",
                       "tost-frontiere" = "issue #219", pitman = "issue #220", esd = "issue #174",
                       "issues #114 et #118")
sortie <- c(
  sprintf("## Constats de niveau et de puissance \u00e0 T = 8 (%s)", TITRE_ISSUES), "",
  paste0(sprintf("Param\u00e8tres : R=%d ; R_ks=%d ; graine=%s ; partie=%s ; T=%d", OPT_R, OPT_R_KS,
                 format(OPT_GRAINE, scientific = FALSE), OPT_PARTIE, T_),
         if (OPT_PARTIE == "pitman") sprintf(" ; R_h0=%d", OPT_R_H0),
         if (OPT_PARTIE == "esd") sprintf(" ; R_modele=%d", OPT_R_MODELE)), "",
  entete_md(c("Grandeur", "Valeur")),
  ligne_md("Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)", plateforme_calcul()),
  ligne_md("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
  ligne_md("Commit", COMMIT),
  ligne_md("Script", "tests/constats_puissance_t8.R (hors CI ; protocole dans l'en-t\u00eate)"), "")
controles <- character(0)

# --- C1 : AR(1), suites contre Durbin-Watson ----------------------------------
if (OPT_PARTIE %in% c("tout", "ar1")) {
  E <- engine_sous_graine(OPT_GRAINE, matrix(stats::rnorm(OPT_R * T_), nrow = OPT_R))
  serie_ar1 <- function(e, rho, stationnaire) {
    u <- numeric(length(e))
    u[1] <- if (stationnaire) e[1] / sqrt(1 - rho^2) else e[1]
    for (t in 2:length(e)) u[t] <- rho * u[t - 1] + e[t]
    u
  }
  # Controle d'invariance affine (z du moteur a pi constant = a + b u, b > 0).
  u1 <- serie_ar1(E[1, ], 0.5, TRUE)
  controles <- c(controles, controle(
    isTRUE(all.equal(dw_p_exacte(u1), dw_p_exacte(3 + 0.2 * u1), tolerance = 1e-8)) &&
      identical(runs_p_exacte(u1), runs_p_exacte(3 + 0.2 * u1)),
    "C1, invariance affine des p exactes (dw_p_exacte(), runs_p_exacte())"))
  mesurer <- function(stationnaire) {
    t(vapply(RHOS, function(rho) {
      p <- vapply(seq_len(OPT_R), function(i) {
        u <- serie_ar1(E[i, ], rho, stationnaire)
        c(runs_p_exacte(u), dw_p_exacte(u))
      }, numeric(2))
      c(k_suites = sum(p[1, ] < ALPHA_AR1), na_suites = sum(!is.finite(p[1, ])),
        k_dw = sum(p[2, ] < ALPHA_AR1), na_dw = sum(!is.finite(p[2, ])))
    }, numeric(4)))
  }
  t1 <- Sys.time()
  M_st <- mesurer(TRUE)
  M_nul <- mesurer(FALSE)
  duree_ar1 <- as.numeric(difftime(Sys.time(), t1, units = "secs"))
  controles <- c(controles, controle(all(c(M_st[, c("na_suites", "na_dw")], M_nul[, c("na_suites", "na_dw")]) == 0),
                                     "C1, aucune p-value manquante"))
  tableau_ar1 <- function(M, titre, avec_pub) {
    cols <- c("\u03c1", "Suites : taux", "IC 95 % (C-P)", if (avec_pub) c("Publi\u00e9", "z", "Compatible"),
              "DW exact : taux", "IC 95 % (C-P)", if (avec_pub) c("Publi\u00e9", "z", "Compatible"))
    lignes <- vapply(seq_along(RHOS), function(j) {
      cs <- ic_cp(M[j, "k_suites"], OPT_R); cd <- ic_cp(M[j, "k_dw"], OPT_R)
      v <- c(num(RHOS[j], 1), num(M[j, "k_suites"] / OPT_R), txt_ic(cs),
             if (avec_pub) c(num(PUB_SUITES[j]), compat(PUB_SUITES[j], M[j, "k_suites"], OPT_R)),
             num(M[j, "k_dw"] / OPT_R), txt_ic(cd),
             if (avec_pub) c(num(PUB_DW[j]), compat(PUB_DW[j], M[j, "k_dw"], OPT_R)))
      ligne_md(paste(v, collapse = " | "))
    }, "")
    c(titre, "", entete_md(cols), lignes, "")
  }
  sortie <- c(sortie,
    "### C1 -- Puissance du test des suites et de Durbin-Watson exact, AR(1) gaussien, T = 8, \u03b1 = 0,10", "",
    paste("Statut : **constat de simulation, hors mod\u00e8le r\u00e9glementaire** (l'annexe XVII suppose",
          "des ann\u00e9es ind\u00e9pendantes ; l'AR(1) est l'alternative choisie pour mesurer la puissance).",
          "Tests appliqu\u00e9s \u00e0 la s\u00e9rie par les fonctions du moteur runs_p_exacte() (loi de",
          "Swed & Eisenhart, doublement) et dw_p_exacte() (s\u00e9rie centr\u00e9e : r\u00e9sidus de la",
          "r\u00e9gression sur la constante ; loi exacte d'Imhof ; p bilat\u00e9rale par doublement) ;",
          "rejet si p < \u03b1. Ligne \u03c1 = 0 : niveau (suites : 4/70 = 0,0571 exactement ; DW : 0,10). Colonnes z et Compatible : \u00e9cart normalis\u00e9 de deux proportions ind\u00e9pendantes (reproduction, publication sur 20 000 tirages) ; compatible si |z| \u2264 1,96."), "",
    sprintf("R\u00e9plications : %d par valeur de \u03c1 (innovations communes \u00e0 tous les \u03c1 et aux deux variantes, graine %s).",
            OPT_R, format(OPT_GRAINE, scientific = FALSE)), "",
    tableau_ar1(M_st, "**C1.a -- variante principale : AR(1) stationnaire** (u_1 = e_1 / \u221a(1 \u2212 \u03c1\u00b2))", TRUE),
    tableau_ar1(M_nul, "**C1.b -- variante secondaire : d\u00e9part nul** (u_1 = e_1)", TRUE),
    sprintf("Dur\u00e9e de C1 : %.0f s.", duree_ar1), "")
}

# --- C2 : Kolmogorov-Smirnov contre N(0,1), niveau a 5 % -----------------------
if (OPT_PARTIE %in% c("tout", "ks")) {
  # Controle de la transcription de p_kolmogorov() et de stat_ks() contre la
  # ligne produite par run_engine() sur J1 (p non simulee independante de B).
  res0 <- run_engine(xt = .ln$xt, yt = .ln$yt, methode = "premium", segment = 1, annexe = "II",
                     nature_donnees = "brutes", B = 99, seed = 20260831)
  tab0 <- engine_table_tests(res0)
  l_ks <- tab0[tab0$test == "Kolmogorov-Smirnov contre N(0,1)", ]
  FIT0 <- usp_ajuster(.ln$xt, .ln$yt)
  controles <- c(controles, controle(
    nrow(l_ks) == 1L && isTRUE(all.equal(l_ks$stat, stat_ks(FIT0$z), tolerance = 1e-10)) &&
      isTRUE(all.equal(l_ks$p_asymptotique, p_kolmogorov(stat_ks(FIT0$z), T_), tolerance = 1e-10)),
    "C2, transcription de la p de Kolmogorov et de stat_ks(fit$z) (contre run_engine(), J1)"))

  t2 <- Sys.time()
  Z <- engine_sous_graine(OPT_GRAINE + 1, matrix(stats::rnorm(OPT_R_KS * T_), nrow = OPT_R_KS))
  sd_mv <- function(v) sqrt(mean((v - mean(v))^2))
  p_k0 <- apply(Z, 1, function(v) p_kolmogorov(stat_ks(v), T_))
  p_k2 <- apply(Z, 1, function(v) p_kolmogorov(stat_ks((v - mean(v)) / stats::sd(v)), T_))
  p_k3 <- apply(Z, 1, function(v) p_kolmogorov(stat_ks((v - mean(v)) / sd_mv(v)), T_))
  Y <- engine_sous_graine(OPT_GRAINE + 2, lapply(seq_len(OPT_R_KS), function(b) usp_simuler(FIT0)))
  aj <- lapply(Y, function(y) tryCatch(usp_ajuster(.ln$xt, y), error = function(e) NULL))
  ok_aj <- vapply(aj, function(f) !is.null(f) && all(is.finite(f$z)), logical(1))
  p_k1 <- vapply(aj[ok_aj], function(f) p_kolmogorov(stat_ks(f$z), T_), numeric(1))
  pi_cst <- vapply(aj[ok_aj], function(f) isTRUE(diff(range(f$pi)) <= 1e-12 * max(f$pi)), logical(1))
  # Convergence des reajustements gardes (voir l'en-tete) : code optim() de
  # l'optimum retenu, demarrages a l'optimum (tous codes, puis code 0).
  conv_k1 <- vapply(aj[ok_aj], function(f) as.integer(f$convergence), integer(1))
  n_opt_k1 <- vapply(aj[ok_aj], function(f) as.integer(f$n_starts_optimum), integer(1))
  n_opt0_k1 <- vapply(aj[ok_aj], function(f) as.integer(f$n_starts_optimum_code0), integer(1))
  duree_ks <- as.numeric(difftime(Sys.time(), t2, units = "secs"))

  ligne_ks <- function(code, libelle, p) {
    n <- sum(is.finite(p)); k <- sum(p[is.finite(p)] < ALPHA_KS); ci <- ic_cp(k, n)
    p_f <- stats::fisher.test(matrix(c(k, n - k, K_PUB_KS, N_PUB_KS - K_PUB_KS), nrow = 2L, byrow = TRUE))$p.value
    ligne_md(code, libelle, sprintf("%d / %d", k, n), num(k / n, 4), txt_ic(ci), num(p_f, 4),
             if (p_f >= 0.05) "oui" else "**non**")
  }
  sortie <- c(sortie,
    "### C2 -- Niveau du Kolmogorov-Smirnov contre N(0,1) \u00e0 5 %, T = 8 (\u00ab 0 rejet sur 3 000 \u00bb)", "",
    paste("Statut : constat de simulation du niveau. p-value : formule de Kolmogorov de la ligne de",
          "usp_tests() (transcription contr\u00f4l\u00e9e) ; D = stat_ks() du moteur ; rejet si p < 0,05.",
          "Le protocole d'origine n'est pas \u00e9crit : quatre lectures sont mesur\u00e9es. Colonne",
          "\u00ab Compatible \u00bb : test exact de Fisher bilat\u00e9ral sur le tableau 2 \u00d7 2 (k, n \u2212 k ; 0, 3 000)",
          "de la reproduction et du constat publi\u00e9 ; compatible si p \u2265 0,05 (quatre comparaisons non corrig\u00e9es",
          "pour la multiplicit\u00e9)."), "",
    entete_md(c("Lecture", "\u00c9chantillons", "Rejets / R", "Taux", "IC 95 % (C-P)", "p Fisher contre 0 / 3 000", "Compatible")),
    ligne_ks("K0", "N(0,1) i.i.d., param\u00e8tres CONNUS (r\u00e9f\u00e9rence)", p_k0),
    ligne_ks("K1", sprintf("r\u00e9sidus z de usp_ajuster() sur jeux simul\u00e9s sous le mod\u00e8le ajust\u00e9 \u00e0 J1 (usp_simuler()) ; \u03c0\u0302 constant dans %d / %d r\u00e9ajustements", sum(pi_cst), sum(ok_aj)), p_k1),
    ligne_ks("K2", "N(0,1) i.i.d. standardis\u00e9s par moyenne et \u00e9cart-type empiriques (s en T \u2212 1)", p_k2),
    ligne_ks("K3", "N(0,1) i.i.d. standardis\u00e9s par moyenne et \u00e9cart-type du MV (s en T) = z du moteur \u00e0 \u03c0\u0302 constant", p_k3),
    "",
    sprintf("R\u00e9ajustements K1 \u00e9chou\u00e9s ou non finis (\u00e9cart\u00e9s) : %d / %d. Graines : K0, K2, K3 %s ; K1 %s.",
            sum(!ok_aj), OPT_R_KS, format(OPT_GRAINE + 1, scientific = FALSE),
            format(OPT_GRAINE + 2, scientific = FALSE)),
    sprintf(paste("Convergence des r\u00e9ajustements K1 gard\u00e9s (inclus dans le taux) : code optim() de l'optimum",
                  "retenu \u2260 0 dans %d / %d (codes : %s), dont %d rejet(s) \u00e0 5 %% ; aucun d\u00e9marrage \u00e0 l'optimum",
                  "de code 0 dans %d / %d ; d\u00e9marrages \u00e0 l'optimum : minimum %s sur 54."),
            sum(conv_k1 != 0L), length(conv_k1),
            if (any(conv_k1 != 0L)) {
              tb <- table(conv_k1[conv_k1 != 0L])
              paste(sprintf("%s : %d", names(tb), as.integer(tb)), collapse = ", ")
            } else "\u2014",
            sum(p_k1[conv_k1 != 0L] < ALPHA_KS),
            sum(n_opt0_k1 == 0L), length(n_opt0_k1),
            if (length(n_opt_k1)) as.character(min(n_opt_k1)) else "\u2014"),
    sprintf("Plus petite p-value observ\u00e9e : K0 %s ; K1 %s ; K2 %s ; K3 %s.",
            num(min(p_k0), 4), num(min(p_k1), 4), num(min(p_k2), 4), num(min(p_k3), 4)),
    sprintf("Dur\u00e9e de C2 : %.0f s.", duree_ks), "")
}

# --- Outils communs a C3 et C4 (issue #118) -----------------------------------
ALPHAS_118 <- c(0.10, 0.05)
# p-value en texte : quatre decimales, notation scientifique sous 1e-3.
num_p <- function(x) if (is.na(x)) "\u2014" else if (x < 1e-3)
  sub(".", ",", sprintf("%.2e", x), fixed = TRUE) else num(x, 4)
# Taux de rejet (ou de conclusion) p < alpha, avec son IC de Clopper-Pearson.
cellules_taux <- function(p, alpha) {
  k <- sum(p < alpha); n <- length(p)
  ci <- ic_cp(k, n)
  c(sprintf("%d / %d", k, n), num(k / n, 4), sprintf("[%s ; %s]", num(ci[1], 4), num(ci[2], 4)))
}
# Parties dont un fichier est demande (--ecrire) : lignes de la section et
# controles propres (la duree est dans la section).
FICHIERS_118 <- list()

# --- Outils communs a C3 et C5 (TOST de la constante, #118, #215, #219) -------
THETA_TOST <- 0.10
# Jeu J2 : copie declaree de lire_j2() de tests/taux_franchissement_reperes.R
# (memes lignes xi, yi de tests/unitaires/test_controles_numeriques.R).
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
# Jeux J1 et J2 et leurs graines (flux de C3, repris tels quels par C5).
jeux_tost <- function() {
  j2 <- lire_j2()
  list(
    list(code = "J1", x = .ln$xt, y = .ln$yt, graine = OPT_GRAINE + 3,
         libelle = "tests/donnees/donnees_ln.csv (jeu des cas de r\u00e9f\u00e9rence)"),
    list(code = "J2", x = j2$x, y = j2$y, graine = OPT_GRAINE + 4,
         libelle = "xi, yi de tests/unitaires/test_controles_numeriques.R"))
}
# p_asymptotique de la ligne TOST de run_engine() (B = 99, graine 20260831 ;
# la p du TOST ne depend ni de B ni de la graine) ; NA si la ligne manque.
p_tost_moteur <- function(x, y, delta_equiv = NULL) {
  tb <- engine_table_tests(run_engine(xt = x, yt = y, methode = "premium", segment = 1,
                                      annexe = "II", nature_donnees = "brutes",
                                      B = 99, seed = 20260831, delta_equiv = delta_equiv))
  l <- tb[tb$test == "Equivalence de la constante a zero (TOST)", ]
  if (nrow(l) == 1L) l$p_asymptotique else NA_real_
}

# --- C3 : TOST de la constante, probabilite de conclure (issue #118) ----------
if (OPT_PARTIE %in% c("tout", "tost")) {
  JEUX_TOST <- jeux_tost()
  ctrl_tost <- character(0)
  t3 <- Sys.time()
  # Etat du generateur de l'appelant, pour le controle de restauration.
  rng_avant <- list(RNGkind(), get0(".Random.seed", envir = globalenv(), inherits = FALSE))
  MES_TOST <- lapply(JEUX_TOST, function(J) {
    x <- J$x; Tj <- length(x)
    fit <- usp_ajuster(x, J$y)
    # Tirages d'abord (flux inchange par #215), evaluation ensuite.
    Y <- engine_sous_graine(J$graine, lapply(seq_len(OPT_R), function(b) usp_simuler(fit)))
    # #215 : reajustement de chaque y* (comme run_engine()), TOST aux poids
    # GLS du reajustement ; echec du reajustement -> colonne NA, comptee.
    M <- vapply(Y, function(y) {
      fs <- tryCatch(usp_ajuster(x, y), error = function(e) NULL)
      if (is.null(fs)) return(c(p = NA_real_, a = NA_real_, se = NA_real_, delta = NA_real_, ok = 0))
      r <- test_tost_intercept(x, y, fs$pi, theta = THETA_TOST)
      c(p = r$p, a = r$a, se = r$se, delta = r$delta, ok = 1)
    }, numeric(5))
    obs <- test_tost_intercept(x, J$y, fit$pi, theta = THETA_TOST)
    # Controle de transcription : ligne TOST de run_engine() (theta_equiv par
    # defaut, 0,10) sur le jeu observe et sur le premier jeu simule.
    p_moteur <- vapply(list(J$y, Y[[1]]), function(y) p_tost_moteur(x, y), numeric(1))
    list(J = J, T = Tj, fit = fit, M = M, obs = obs, p_moteur = p_moteur,
         y1 = Y[[1]], y1_isole = engine_sous_graine(J$graine, usp_simuler(fit)))
  })
  rng_apres <- list(RNGkind(), get0(".Random.seed", envir = globalenv(), inherits = FALSE))
  duree_tost <- as.numeric(difftime(Sys.time(), t3, units = "secs"))

  for (m in MES_TOST) {
    cj <- m$J$code; reussi <- m$M["ok", ] == 1; p <- m$M["p", reussi]
    ctrl_tost <- c(ctrl_tost, controle(
      isTRUE(all.equal(m$p_moteur, unname(c(m$obs$p, m$M["p", 1])), tolerance = 1e-10)),
      sprintf("C3 %s, p de test_tost_intercept() = p_asymptotique de la ligne TOST de run_engine() (jeu observ\u00e9 et premier jeu simul\u00e9)", cj)))
    ctrl_tost <- c(ctrl_tost, controle(all(is.finite(p)),
      sprintf("C3 %s, aucune p-value manquante parmi les r\u00e9ajustements r\u00e9ussis (%d \u00e9chec(s) de r\u00e9ajustement sur %d)",
              cj, sum(!reussi), length(reussi))))
    # p < alpha <=> Delta - |a| > t_{1-alpha, T-2} se (regle du maximum).
    ok_eq <- all(vapply(ALPHAS_118, function(al) {
      tq <- stats::qt(1 - al, m$T - 2)
      identical(p < al, m$M["delta", reussi] - abs(m$M["a", reussi]) > tq * m$M["se", reussi])
    }, logical(1)))
    ctrl_tost <- c(ctrl_tost, controle(ok_eq,
      sprintf("C3 %s, conclusion (p < \u03b1) \u00e9quivalente \u00e0 \u0394 \u2212 |\u00e2| > t(1 \u2212 \u03b1, T \u2212 2) se(\u00e2), jeu par jeu", cj)))
    ctrl_tost <- c(ctrl_tost, controle(identical(m$y1, m$y1_isole),
      sprintf("C3 %s, premier jeu du flux identique \u00e0 un tirage isol\u00e9 sous la m\u00eame graine", cj)))
  }
  ctrl_tost <- c(ctrl_tost, controle(identical(rng_avant, rng_apres),
    "C3, RNGkind() et .Random.seed de l'appelant restaur\u00e9s apr\u00e8s les tirages"))

  lignes_conclusion <- unlist(lapply(MES_TOST, function(m) {
    reussi <- m$M["ok", ] == 1; p <- m$M["p", reussi]
    vapply(ALPHAS_118, function(al) ligne_md(m$J$code, num(al, 2), paste(cellules_taux(p, al), collapse = " | "),
                                             num_p(min(p)), sum(!reussi)), "")
  }))
  lignes_descr <- vapply(MES_TOST, function(m) {
    x <- m$J$x; reussi <- m$M["ok", ] == 1
    r_sim <- m$M["se", reussi] / m$M["delta", reussi]
    seuils <- 1 / stats::qt(1 - ALPHAS_118, m$T - 2)
    # Levier pondere de l'origine (#215) aux poids GLS du jeu observe,
    # ramenes a une moyenne de 1 (a poids constants : xbar^2 / S_xx).
    w <- usp_poids_gls(x, m$fit$pi); w <- w / mean(w)
    xw <- sum(w * x) / sum(w)
    ligne_md(m$J$code, m$T, num(m$fit$delta, 4), num(stats::sd(x) / mean(x), 4),
             num(xw^2 / sum(w * (x - xw)^2), 3), num(m$obs$se / m$obs$delta, 4),
             num(seuils[1], 4), num(seuils[2], 4),
             num(mean(r_sim < seuils[1]), 4), num(mean(r_sim < seuils[2]), 4),
             num(stats::median(r_sim), 4))
  }, "")
  section_tost <- c(
    "### C3 -- TOST de la constante : probabilit\u00e9 de conclure \u00e0 l'\u00e9quivalence sous le mod\u00e8le ajust\u00e9, T = 8", "",
    paste("Statut : **constat de simulation sous le mod\u00e8le r\u00e9glementaire ajust\u00e9** (constante a = 0 vraie ;",
          "propri\u00e9t\u00e9 du plan de volumes du jeu, non du seul T). Jeux y* simul\u00e9s par usp_simuler() au mod\u00e8le",
          "ajust\u00e9 au jeu observ\u00e9 (x fixe), chacun r\u00e9ajust\u00e9 par usp_ajuster(x, y*) comme dans run_engine() ;",
          "p = test_tost_intercept(x, y*, fit*$pi, theta = 0,10)$p, mod\u00e8le auxiliaire pond\u00e9r\u00e9 aux poids GLS du",
          "r\u00e9ajustement (#215) (marge \u0394 = 0,10 \u00d7 moyenne de y*, valeur par d\u00e9faut de run_engine()) ;",
          "conclusion d'\u00e9quivalence si p < \u03b1 ; taux sur les r\u00e9ajustements r\u00e9ussis, \u00e9checs compt\u00e9s.",
          "Conclure exige \u0394 \u2212 |\u00e2| > t(1 \u2212 \u03b1, T \u2212 2) se(\u00e2), donc se(\u00e2)/\u0394 < 1/t(1 \u2212 \u03b1, T \u2212 2)",
          "(condition n\u00e9cessaire) ; se(\u00e2) cro\u00eet avec le levier pond\u00e9r\u00e9 de l'origine x\u0304_w\u00b2/S_xx,w.",
          "Avant #215 (TOST MCO, sans r\u00e9ajustement) : docs/tableaux/20260930-issue118-tost.md."), "",
    sprintf("R\u00e9plications : %d par jeu. Graines : J1 %s ; J2 %s.", OPT_R,
            format(OPT_GRAINE + 3, scientific = FALSE), format(OPT_GRAINE + 4, scientific = FALSE)), "",
    "**C3.a -- Taux de conclusion d'\u00e9quivalence (p < \u03b1)**", "",
    entete_md(c("Jeu", "\u03b1", "Conclusions / r\u00e9ajustements r\u00e9ussis", "Taux", "IC 95 % (C-P)", "p minimale",
                "\u00c9checs de r\u00e9ajustement")),
    lignes_conclusion, "",
    paste("**C3.b -- Descripteurs du plan de volumes** (d\u00e9terministes sur le jeu observ\u00e9 ; trois derni\u00e8res",
          "colonnes : sur les jeux simul\u00e9s, descriptives ; se*/\u0394* < 1/t est une condition n\u00e9cessaire,",
          "non suffisante, de conclusion)"), "",
    entete_md(c("Jeu", "T", "\u03b4\u0302", "CV(x) (\u00e9cart-type en T \u2212 1)",
                "x\u0304_w\u00b2/S_xx,w (poids GLS de l'observ\u00e9, moyenne 1)",
                "se(\u00e2)/\u0394 observ\u00e9", "1/t(0,90 ; T \u2212 2)", "1/t(0,95 ; T \u2212 2)",
                "Part se*/\u0394* < 1/t(0,90) (condition n\u00e9cessaire, non suffisante)",
                "Part se*/\u0394* < 1/t(0,95) (condition n\u00e9cessaire, non suffisante)", "M\u00e9diane se*/\u0394*")),
    lignes_descr, "",
    paste0("Jeux : ", paste(vapply(MES_TOST, function(m) sprintf("%s : %s", m$J$code, m$J$libelle), ""),
                          collapse = " ; "), "."),
    sprintf("Dur\u00e9e de C3 : %.0f s.", duree_tost), "")
  sortie <- c(sortie, section_tost)
  controles <- c(controles, ctrl_tost)
  FICHIERS_118$tost <- list(section = section_tost, controles = ctrl_tost)
}

# --- C4 : Shapiro-Wilk et D'Agostino, puissance i.i.d. (issue #118) ----------
if (OPT_PARTIE %in% c("tout", "normalite")) {
  LOIS <- list(
    list(code = "N(0,1)", libelle = "N(0,1) (niveau)", q = function(u) stats::qnorm(u)),
    list(code = "t5", libelle = "t de Student, 5 ddl", q = function(u) stats::qt(u, 5)),
    list(code = "t3", libelle = "t de Student, 3 ddl", q = function(u) stats::qt(u, 3)),
    list(code = "exp", libelle = "exponentielle exp(1)", q = function(u) stats::qexp(u)),
    list(code = "LN", libelle = "lognormale (0 ; 0,5)", q = function(u) stats::qlnorm(u, 0, 0.5)))
  ctrl_norm <- character(0)
  t4 <- Sys.time()
  U8  <- engine_sous_graine(OPT_GRAINE + 5, matrix(stats::runif(OPT_R * 8L), nrow = OPT_R))
  U20 <- engine_sous_graine(OPT_GRAINE + 6, matrix(stats::runif(OPT_R * 20L), nrow = OPT_R))
  mesurer_normalite <- function(v) {
    sw <- .shapiro_sur(v); ds <- test_dagostino_skew(v)
    c(W = sw$stat, p_nulle = sw_p_loi_nulle(sw$stat, length(v)), p_royston = sw$p,
      Z = ds$stat, p_dago = ds$p)
  }
  MES8 <- lapply(LOIS, function(L) {
    V <- L$q(U8)
    t(apply(V, 1, mesurer_normalite))
  })
  MES20 <- lapply(LOIS, function(L) {
    V <- L$q(U20)
    vapply(seq_len(nrow(V)), function(i) test_dagostino_skew(V[i, ])$p, numeric(1))
  })
  duree_norm <- as.numeric(difftime(Sys.time(), t4, units = "secs"))
  N_NULLE <- length(sw_loi_nulle(8L))

  # Invariance affine croissante (W, Z et leurs p) sur le premier echantillon
  # de chaque loi.
  inv_ok <- all(vapply(LOIS, function(L) {
    v <- L$q(U8[1, ])
    isTRUE(all.equal(mesurer_normalite(v), mesurer_normalite(3 + 0.2 * v), tolerance = 1e-8))
  }, logical(1)))
  ctrl_norm <- c(ctrl_norm, controle(inv_ok,
    "C4, invariance affine croissante de W, Z et de leurs p (premier \u00e9chantillon de chaque loi, T = 8)"))
  # Niveaux sous N(0,1) : INFORMATIFS, sans controle ni effet sur le code de
  # sortie (avis d'actuary du 30/09/2026, voir l'en-tete). Pour chaque alpha :
  # ecart k/R - alpha en points et position de alpha par rapport a l'IC de
  # Clopper-Pearson, calcules sur les valeurs mesurees.
  txt_niveau <- function(p) paste(vapply(ALPHAS_118, function(al) {
    k <- sum(p < al); n <- length(p); ci <- ic_cp(k, n)
    pos <- if (al < ci[1]) "lib\u00e9ral, IC excluant \u03b1" else if (al > ci[2])
      "conservateur, IC excluant \u03b1" else "IC contenant \u03b1"
    sprintf("%s points \u00e0 \u03b1 = %s (%s)", sub(".", ",", sprintf("%+.2f", 100 * (k / n - al)), fixed = TRUE),
            num(al, 2), pos)
  }, ""), collapse = " ; ")
  # Transcription contre run_engine() sur J1 (pi chapeau constant).
  res1 <- run_engine(xt = .ln$xt, yt = .ln$yt, methode = "premium", segment = 1, annexe = "II",
                     nature_donnees = "brutes", B = 99, seed = 20260831)
  tb1 <- engine_table_tests(res1)
  ligne <- function(nom) tb1[tb1$test == nom, ]
  l_sw  <- ligne("Shapiro-Wilk sur residus standardises")
  l_ds  <- ligne("Asymetrie (D'Agostino, T >= 8)")
  fit1 <- usp_ajuster(.ln$xt, .ln$yt)
  m_z <- mesurer_normalite(fit1$z)
  m_lr <- mesurer_normalite(log(.ln$yt / .ln$xt))
  # La ligne Shapiro-Wilk a loi nulle simulee est retiree de run_engine()
  # (#302) : la p par loi nulle (sw_p_loi_nulle(), fonction du moteur) n'est
  # plus confrontee a une ligne ; W, qui la determine, l'est toujours.
  trans_ok <- nrow(l_sw) == 1L && nrow(l_ds) == 1L &&
    isTRUE(diff(range(fit1$pi)) <= 1e-12 * max(fit1$pi)) &&
    isTRUE(all.equal(c(l_sw$statistique, l_sw$p_asymptotique,
                       l_ds$statistique, l_ds$p_asymptotique),
                     unname(m_z[c("W", "p_royston", "Z", "p_dago")]), tolerance = 1e-10)) &&
    isTRUE(all.equal(m_z[c("W", "Z")], m_lr[c("W", "Z")], tolerance = 1e-8))
  ctrl_norm <- c(ctrl_norm, controle(trans_ok, paste(
    "C4, transcription contre run_engine() sur J1 (W, p de Royston, Z et p de",
    "D'Agostino ; \u03c0\u0302 constant ; W et Z des r\u00e9sidus z \u00e9gaux \u00e0 ceux des log-ratios)")))
  ctrl_norm <- c(ctrl_norm, controle(
    all(vapply(MES8, function(M) all(is.finite(M)), logical(1))) &&
      all(vapply(MES20, function(p) all(is.finite(p)), logical(1))),
    "C4, aucune statistique ni p-value manquante (T = 8 et T = 20)"))

  # --- C4.c : Shapiro-Francia, p de Royston de test_shapiro_francia() (#335)
  # Boucle separee, sans tirage supplementaire : T = 8 sur U8, T = 20 sur
  # U20, T = 5 = colonnes 1 a 5 de U8, T = 10 = colonnes 1 a 10 de U20.
  # Niveau (N(0,1)) aux quatre T, puissance a T = 8 seulement. Ni
  # mesurer_normalite() ni ALPHAS_118 ne changent (C4.a et C4.b identiques,
  # controle bloquant plus bas).
  ALPHAS_SF <- c(0.10, 0.05, 0.01)
  T_SF <- list(
    list(T = 5L,  U = U8[, 1:5, drop = FALSE],   src = "colonnes 1 \u00e0 5 de la matrice T = 8"),
    list(T = 8L,  U = U8,                        src = "matrice T = 8 (celle de C4.a)"),
    list(T = 10L, U = U20[, 1:10, drop = FALSE], src = "colonnes 1 \u00e0 10 de la matrice T = 20"),
    list(T = 20L, U = U20,                       src = "matrice T = 20 (celle de C4.b)"))
  t4c <- Sys.time()
  # W' et p de Royston, une ligne par echantillon (colonnes stat, p).
  mesurer_sf <- function(V) t(apply(V, 1, function(v) unlist(test_shapiro_francia(v))[c("stat", "p")]))
  SF_NIV <- lapply(T_SF, function(tt) mesurer_sf(LOIS[[1]]$q(tt$U)))
  SF_PUI <- lapply(LOIS[-1], function(L) mesurer_sf(L$q(U8)))
  duree_sf <- as.numeric(difftime(Sys.time(), t4c, units = "secs"))

  # Invariance affine croissante de W' et de sa p : premier echantillon de
  # chaque loi et de chaque T.
  inv_sf <- all(vapply(LOIS, function(L) all(vapply(T_SF, function(tt) {
    v <- L$q(tt$U[1, ])
    isTRUE(all.equal(unlist(test_shapiro_francia(v)), unlist(test_shapiro_francia(3 + 0.2 * v)),
                     tolerance = 1e-8))
  }, logical(1))), logical(1)))
  ctrl_norm <- c(ctrl_norm, controle(inv_sf, paste(
    "C4.c, invariance affine croissante de W' et de sa p de Royston (premier \u00e9chantillon de chaque loi,",
    "T = 5, 8, 10 et 20)")))
  # Transcription contre run_engine() sur J1 (res1, fit1 ci-dessus).
  l_sf  <- ligne("Shapiro-Francia")
  sf_z  <- test_shapiro_francia(fit1$z)
  sf_lr <- test_shapiro_francia(log(.ln$yt / .ln$xt))
  trans_sf <- nrow(l_sf) == 1L &&
    isTRUE(diff(range(fit1$pi)) <= 1e-12 * max(fit1$pi)) &&
    isTRUE(all.equal(c(l_sf$statistique, l_sf$p_asymptotique), c(sf_z$stat, sf_z$p), tolerance = 1e-10)) &&
    isTRUE(all.equal(sf_z$stat, sf_lr$stat, tolerance = 1e-10))
  ctrl_norm <- c(ctrl_norm, controle(trans_sf, paste(
    "C4.c, transcription contre run_engine() sur J1 (statistique et p_asymptotique de la ligne Shapiro-Francia",
    "= test_shapiro_francia(z) \u00e0 1e-10 ; \u03c0\u0302 constant ; W' des r\u00e9sidus z \u00e9gal \u00e0 celui des log-ratios)")))
  ctrl_norm <- c(ctrl_norm, controle(
    all(vapply(c(SF_NIV, SF_PUI), function(M) all(is.finite(M)), logical(1))),
    "C4.c, aucune statistique W' ni p de Royston manquante (niveau \u00e0 T = 5, 8, 10 et 20 ; puissance \u00e0 T = 8)"))

  TESTS8 <- list(
    list(col = "p_nulle", libelle = "Shapiro-Wilk, p par loi nulle simul\u00e9e (sw_p_loi_nulle())"),
    list(col = "p_royston", libelle = "Shapiro-Wilk, p de Royston (shapiro.test())"),
    list(col = "p_dago", libelle = "D'Agostino (asym\u00e9trie), p N(0,1) approch\u00e9e"))
  lignes8 <- unlist(lapply(seq_along(LOIS), function(j) vapply(TESTS8, function(te) {
    p <- MES8[[j]][, te$col]
    ligne_md(LOIS[[j]]$libelle, te$libelle, paste(cellules_taux(p, 0.10), collapse = " | "),
             paste(cellules_taux(p, 0.05), collapse = " | "), num_p(min(p)))
  }, "")))
  lignes20 <- vapply(seq_along(LOIS), function(j) {
    p <- MES20[[j]]
    ligne_md(LOIS[[j]]$libelle, paste(cellules_taux(p, 0.10), collapse = " | "),
             paste(cellules_taux(p, 0.05), collapse = " | "), num_p(min(p)))
  }, "")
  cols_taux <- c("Rejets / R (\u03b1 = 0,10)", "Taux", "IC 95 % (C-P)",
                 "Rejets / R (\u03b1 = 0,05)", "Taux", "IC 95 % (C-P)", "p minimale")

  # Controle BLOQUANT (#335) : lignes des tableaux C4.a et C4.b (en-tete
  # compris) identiques au caractere pres a celles du fichier versionne de
  # #118, seulement a R = 20 000 et graine 20260927 ; sinon "non comparable",
  # sans effet sur le code de sortie.
  REF_C4 <- file.path(RACINE, "docs", "tableaux", "20260930-issue118-normalite.md")
  extraire_table <- function(l, titre) {
    i <- which(startsWith(l, titre))
    if (length(i) != 1L) return(NULL)
    j <- i + 2L; k <- j
    while (k <= length(l) && startsWith(l[k], "|")) k <- k + 1L
    if (k == j) character(0) else l[j:(k - 1L)]
  }
  tab_c4a <- enc2utf8(c(entete_md(c("Loi", "Test", cols_taux)), lignes8))
  tab_c4b <- enc2utf8(c(entete_md(c("Loi", cols_taux)), lignes20))
  if (OPT_R == 20000L && OPT_GRAINE == 20260927) {
    l_ref <- if (file.exists(REF_C4)) enc2utf8(readLines(REF_C4, encoding = "UTF-8", warn = FALSE)) else character(0)
    ref_a <- extraire_table(l_ref, "**C4.a -- ")
    ref_b <- extraire_table(l_ref, "**C4.b -- ")
    ctrl_norm <- c(ctrl_norm, controle(
      !is.null(ref_a) && !is.null(ref_b) && identical(tab_c4a, ref_a) && identical(tab_c4b, ref_b),
      sprintf(paste("C4.c sans effet sur C4 : lignes des tableaux C4.a (%d) et C4.b (%d), en-t\u00eates compris,",
                    "identiques au caract\u00e8re pr\u00e8s \u00e0 celles de docs/tableaux/20260930-issue118-normalite.md"),
              length(tab_c4a), length(tab_c4b))))
  } else {
    ctrl_norm <- c(ctrl_norm, paste(
      "C4.c sans effet sur C4 : comparaison des tableaux C4.a et C4.b \u00e0 docs/tableaux/20260930-issue118-normalite.md",
      "non comparable (R \u2260 20 000 ou graine \u2260 20260927) ; sans effet sur le code de sortie"))
  }

  # Tableaux de C4.c. Niveau : une ligne par T et par alpha, ecart au nominal
  # et position de alpha par rapport a l'IC (informatifs). Ecart en points a
  # trois decimales (pas de 100 / R points : exact a R = 20 000, ou un ecart
  # de -0,005 point s'affichait "-0,00" a deux decimales) ; ecart nul affiche
  # sans signe.
  ecart_pts <- function(x) if (round(x, 3) == 0) "0,000" else sub(".", ",", sprintf("%+.3f", x), fixed = TRUE)
  lignes_sf_niv <- unlist(lapply(seq_along(T_SF), function(i) vapply(ALPHAS_SF, function(al) {
    p <- SF_NIV[[i]][, "p"]; k <- sum(p < al); n <- length(p); ci <- ic_cp(k, n)
    pos <- if (al < ci[1]) "lib\u00e9ral, IC excluant \u03b1" else if (al > ci[2])
      "conservateur, IC excluant \u03b1" else "IC contenant \u03b1"
    ligne_md(T_SF[[i]]$T, T_SF[[i]]$src, num(al, 2), paste(cellules_taux(p, al), collapse = " | "),
             ecart_pts(100 * (k / n - al)), pos, num_p(min(p)))
  }, "")))
  lignes_sf_pui <- vapply(seq_along(SF_PUI), function(j) {
    p <- SF_PUI[[j]][, "p"]
    ligne_md(LOIS[[j + 1L]]$libelle,
             paste(vapply(ALPHAS_SF, function(al) paste(cellules_taux(p, al), collapse = " | "), ""), collapse = " | "),
             num_p(min(p)))
  }, "")
  cols_taux_sf <- c(unlist(lapply(ALPHAS_SF, function(al)
    c(sprintf("Rejets / R (\u03b1 = %s)", num(al, 2)), "Taux", "IC 95 % (C-P)"))), "p minimale")
  # Rapprochement non bloquant avec la mesure d'actuary du 17/10/2026 (hors
  # depot, R = 200 000, T = 8, protocole non versionne) : sa valeur est-elle
  # dans l'IC de C4.c a T = 8 ?
  ACTUARY_SF <- list(
    list(alpha = 0.10, taux = 0.1096, ic = c(0.1083, 0.1110)),
    list(alpha = 0.05, taux = 0.0559, ic = c(0.0549, 0.0570)),
    list(alpha = 0.01, taux = 0.0099, ic = c(0.0095, 0.0103)))
  i8 <- which(vapply(T_SF, function(tt) tt$T, integer(1)) == 8L)
  lignes_sf_act <- vapply(ACTUARY_SF, function(a) {
    p <- SF_NIV[[i8]][, "p"]; k <- sum(p < a$alpha); n <- length(p); ci <- ic_cp(k, n)
    ligne_md(num(a$alpha, 2), sprintf("%s [%s ; %s]", num(a$taux, 4), num(a$ic[1], 4), num(a$ic[2], 4)),
             sprintf("%s [%s ; %s]", num(k / n, 4), num(ci[1], 4), num(ci[2], 4)),
             if (ci[1] <= a$taux && a$taux <= ci[2]) "oui" else "**non**")
  }, "")
  section_sf <- c(
    "**C4.c -- Shapiro-Francia, p de Royston (test_shapiro_francia()) : niveau sous N(0,1) \u00e0 T = 5, 8, 10 et 20, puissance \u00e0 T = 8**", "",
    paste("Statut : **constat de simulation** pour toute la sous-table C4.c (niveau, puissance, rapprochement),",
          "\u00e9chantillons i.i.d., hors mod\u00e8le r\u00e9glementaire. W' et sa p par test_shapiro_francia() du moteur (aucune",
          "copie de formule) ; rejet si p < \u03b1. La p de Royston est une approximation \u00e0 n fini dont aucun niveau",
          "exact n'est connu (constantes attribu\u00e9es \u00e0 Royston (1993), Statistics in Medicine 12, 181-184, d'apr\u00e8s",
          "des sources secondaires, article non relu). Sur la ligne Shapiro-Francia du moteur, la p retenue est la",
          "p Monte-Carlo (bootstrap param\u00e9trique, mc_nom \"SF\") ; la p de Royston mesur\u00e9e ici n'y est que",
          "p_asymptotique."), "",
    paste("\u00c9chantillons : aucun tirage suppl\u00e9mentaire (T = 8 et T = 20 : matrices d'uniformes de C4.a et C4.b ;",
          "T = 5 : colonnes 1 \u00e0 5 de la matrice T = 8 ; T = 10 : colonnes 1 \u00e0 10 de la matrice T = 20). Ces",
          "\u00e9chantillons sont embo\u00eet\u00e9s : les taux de T = 5 et de T = 8, comme ceux de T = 10 et de T = 20, sont",
          "corr\u00e9l\u00e9s, et les IC de deux T d'une m\u00eame matrice ne se comparent pas comme des IC ind\u00e9pendants ;",
          "T = 8 et T = 10 viennent de matrices distinctes. T = 5, 10 et 20 ne sont mesur\u00e9s que pour le niveau,",
          "au regard du d\u00e9saccord des sources sur la borne basse du domaine de validit\u00e9 de la transformation",
          "(5 contre 10) ; la puissance n'est mesur\u00e9e qu'\u00e0 T = 8."), "",
    paste("Port\u00e9e : W' est invariant par transformation affine croissante (contr\u00f4le), et, \u00e0 \u03c0\u0302 constant, les",
          "r\u00e9sidus z du moteur sont une telle transformation des log-ratios. La mesure co\u00efncide donc, \u00e9chantillon",
          "par \u00e9chantillon, avec la p_asymptotique de la ligne Shapiro-Francia du moteur quand \u03c0\u0302 est constant",
          "et les log-ratios i.i.d. de la loi indiqu\u00e9e. Elle n'est pas la fr\u00e9quence conditionnelle \u00e0",
          "l'\u00e9v\u00e9nement \"\u03c0\u0302 constant\", qui d\u00e9pend des donn\u00e9es. \u00c0 \u03c0\u0302 variable, rien ne justifie de l'appliquer."), "",
    "Niveau sous N(0,1), **informatif** : aucun code de sortie n'en d\u00e9pend.", "",
    entete_md(c("T", "\u00c9chantillons", "\u03b1", "Rejets / R", "Taux", "IC 95 % (C-P)",
                "\u00c9cart au nominal (points)", "Position de \u03b1", "p minimale")),
    lignes_sf_niv, "",
    "Puissance \u00e0 T = 8 (matrice de C4.a) :", "",
    entete_md(c("Loi", cols_taux_sf)), lignes_sf_pui, "",
    local({
      n_ic <- length(T_SF) * length(ALPHAS_SF)
      demi <- function(R) paste(vapply(ALPHAS_SF, function(al)
        sprintf("\u00b1%s point \u00e0 \u03b1 = %s", num(100 * stats::qnorm(0.975) * sqrt(al * (1 - al) / R), 2),
                num(al, 2)), ""), collapse = " ; ")
      sprintf(paste("Mise en garde propre \u00e0 C4.c : %d IC de niveau \u00e0 95 %% (%d valeurs de T \u00d7 %d valeurs de \u03b1),",
                    "sans correction de multiplicit\u00e9 ; les lignes de puissance n'y entrent pas. Sous des niveaux exacts,",
                    "%s IC excluant \u03b1 sont attendus en moyenne par hasard (probabilit\u00e9 d'au moins un : %s %%, calcul\u00e9e",
                    "comme si les %d IC \u00e9taient ind\u00e9pendants, ce que les \u00e9chantillons et les \u03b1 embo\u00eet\u00e9s ne r\u00e9alisent",
                    "pas). Le qualificatif \u00ab lib\u00e9ral \u00bb ou \u00ab conservateur \u00bb n'est un constat qu'\u00e0 R = 20 000, avec",
                    "une demi-largeur d'IC d'environ %s ; au R de cette ex\u00e9cution (R = %d) : %s."),
              n_ic, length(T_SF), length(ALPHAS_SF), num(0.05 * n_ic, 1), num(100 * (1 - 0.95^n_ic), 0),
              n_ic, demi(20000), OPT_R, demi(OPT_R))
    }), "",
    paste("Rapprochement, **non bloquant**, avec la mesure d'actuary du 17/10/2026 (hors d\u00e9p\u00f4t, R = 200 000",
          "\u00e9chantillons i.i.d. N(0,1) de taille 8) ; son protocole n'est pas versionn\u00e9 (graine non publi\u00e9e) :"), "",
    entete_md(c("\u03b1", "Mesure d'actuary, taux [IC 95 %]", sprintf("C4.c, T = 8 (R = %d), taux [IC 95 %% C-P]", OPT_R),
                "Valeur d'actuary dans l'IC de C4.c")),
    lignes_sf_act, "",
    sprintf("Dur\u00e9e de C4.c : %s s (W' et p de Royston ; aucun tirage).", num(duree_sf, 1)), "")

  section_norm <- c(
    "### C4 -- Taux de rejet de Shapiro-Wilk et de l'asym\u00e9trie de D'Agostino, \u00e9chantillons i.i.d., T = 8 (et D'Agostino \u00e0 T = 20)", "",
    paste("Statut : **constat de simulation, hors mod\u00e8le r\u00e9glementaire**, sous des alternatives choisies",
          "(\u00e9chantillons i.i.d. de chaque loi ; ligne N(0,1) : niveau). Nombres al\u00e9atoires communs : une m\u00eame",
          "matrice d'uniformes, transform\u00e9e par la fonction quantile de chaque loi. W par .shapiro_sur() ;",
          "p par sw_p_loi_nulle(W, 8) (loi nulle simul\u00e9e du moteur) et par la normalisation de Royston",
          "(shapiro.test()) ; Z et p de test_dagostino_skew() ; rejet si p < \u03b1."), "",
    paste("Port\u00e9e : W et Z sont invariants par transformation affine croissante, et, \u00e0 \u03c0\u0302 constant, les",
          "r\u00e9sidus z du moteur sont une telle transformation des log-ratios. La mesure vaut donc **exactement**",
          "pour les p ci-dessus (p exacte de la ligne secondaire Shapiro-Wilk, p_asymptotique des lignes",
          "principales Shapiro-Wilk et D'Agostino) quand les log-ratios sont i.i.d. de la loi indiqu\u00e9e et \u03c0\u0302",
          "constant ; pour les **p Monte-Carlo retenues** par le moteur sur les lignes principales (bootstrap",
          "param\u00e9trique), elle n'est qu'**approch\u00e9e**. \u00c0 \u03c0\u0302 variable, elle ne s'applique pas."), "",
    sprintf("R\u00e9plications : %d par loi et par T. Graines : T = 8 %s ; T = 20 %s ; loi nulle de W : %d tirages (SEED_LOI_NULLE_SW = %s).",
            OPT_R, format(OPT_GRAINE + 5, scientific = FALSE), format(OPT_GRAINE + 6, scientific = FALSE),
            N_NULLE, format(SEED_LOI_NULLE_SW, scientific = FALSE)), "",
    "**C4.a -- T = 8 : taux de rejet de Shapiro-Wilk et de D'Agostino**", "",
    entete_md(c("Loi", "Test", cols_taux)), lignes8, "",
    "**C4.b -- T = 20 : taux de rejet de D'Agostino (asym\u00e9trie), p N(0,1) approch\u00e9e**", "",
    entete_md(c("Loi", cols_taux)), lignes20, "",
    paste("Lecture : t5 et t3 sont sym\u00e9triques ; contre elles, le taux de rejet de D'Agostino (asym\u00e9trie)",
          "n'est pas une puissance contre l'asym\u00e9trie mais une distorsion de niveau sous queues lourdes.",
          "Sur la ligne D'Agostino du moteur, la p retenue est Monte-Carlo (bootstrap param\u00e9trique, mc_nom",
          "\"DAgo\") ; la p N(0,1) mesur\u00e9e ici n'y est que p_asymptotique."), "",
    paste("Niveaux (ligne N(0,1)), **informatifs** : aucun code de sortie n'en d\u00e9pend."),
    sprintf(paste("- Shapiro-Wilk, p par loi nulle simul\u00e9e : %s. La loi nulle est fig\u00e9e (SEED_LOI_NULLE_SW,",
                  "N = %d tirages) : l'\u00e9cart de la vraie probabilit\u00e9 de rejet au niveau nominal est une erreur",
                  "de quantile d'ordre \u221a(\u03b1(1 \u2212 \u03b1)/N) (%s), qu'aucun R ne",
                  "r\u00e9duit ; sw_p_loi_nulle() n'a plus de ligne dans run_engine() (Shapiro-Wilk \u00e0 loi nulle",
                  "simul\u00e9e retir\u00e9e, #302) : seule W, qui la d\u00e9termine, est contr\u00f4l\u00e9e contre run_engine()",
                  "(contr\u00f4les d'int\u00e9grit\u00e9)."),
            txt_niveau(MES8[[1]][, "p_nulle"]), N_NULLE,
            paste(vapply(ALPHAS_118, function(al) sprintf("%s \u00e0 \u03b1 = %s", num(sqrt(al * (1 - al) / N_NULLE), 4),
                                                           num(al, 2)), ""), collapse = " ; ")),
    sprintf("- Shapiro-Wilk, p de Royston (approch\u00e9e), mesur\u00e9 sans contr\u00f4le : %s.", txt_niveau(MES8[[1]][, "p_royston"])),
    sprintf("- D'Agostino, p N(0,1) approch\u00e9e, mesur\u00e9 sans contr\u00f4le : T = 8 : %s ; T = 20 : %s.",
            txt_niveau(MES8[[1]][, "p_dago"]), txt_niveau(MES20[[1]])),
    # Mise en garde de lecture (avis d'actuary du 30/09/2026, Q-A2) : nombres
    # d'IC qualifies et demi-largeurs calcules, non ecrits en dur.
    local({
      n_lignes <- 4L                          # SW loi nulle, Royston, D'Agostino T = 8 et T = 20
      n_ic <- n_lignes * length(ALPHAS_118)
      demi <- function(R) paste(vapply(ALPHAS_118, function(al)
        sprintf("\u00b1%s point \u00e0 \u03b1 = %s", num(100 * stats::qnorm(0.975) * sqrt(al * (1 - al) / R), 2),
                num(al, 2)), ""), collapse = " ; ")
      sprintf(paste("Mise en garde : %d IC \u00e0 95 %% (%d lignes \u00d7 %d valeurs de \u03b1), sans correction de",
                    "multiplicit\u00e9 ; sous des niveaux exacts, %s IC excluant \u03b1 sont attendus en moyenne par hasard",
                    "(probabilit\u00e9 d'au moins un : %s %%). Le qualificatif \u00ab lib\u00e9ral \u00bb ou \u00ab conservateur \u00bb",
                    "n'est un constat qu'\u00e0 R = 20 000 (fichiers de docs/tableaux/), avec une demi-largeur d'IC",
                    "d'environ %s ; au R de cette ex\u00e9cution (R = %d) : %s. \u00c0 R faible, il ne vaut pas conclusion."),
              n_ic, n_lignes, length(ALPHAS_118), num(0.05 * n_ic, 1), num(100 * (1 - 0.95^n_ic), 0),
              demi(20000), OPT_R, demi(OPT_R))
    }), "",
    section_sf,
    sprintf("Dur\u00e9e de C4 : %.0f s.", duree_norm), "")
  sortie <- c(sortie, section_norm)
  controles <- c(controles, ctrl_norm)
  FICHIERS_118$normalite <- list(section = section_norm, controles = ctrl_norm)
}

# --- C5 : niveau du TOST de la constante a la frontiere a = +/- Delta (#219) --
# Protocole dans l'en-tete (C5). Partie executee seule (--partie
# tost-frontiere), hors de --partie tout.
if (OPT_PARTIE == "tost-frontiere") {
  JEUX_FR <- jeux_tost()
  POIDS_FR <- c(W1 = "outil, fit*$pi", W2 = "oracle, FIT0$pi", W0 = "MCO d'avant #215, poids constants")
  MARGES_FR <- c(estimee = "\u0394* = \u03b8 \u00b7 \u0233*", a_priori = "delta_abs = \u03b8 \u00b7 E[\u0232]")
  FRONT_FR <- c(moins = "a\u208b = \u2212\u03b8\u03b2x\u0304/(1+\u03b8)", zero = "a = 0",
                plus = "a\u208a = \u03b8\u03b2x\u0304/(1\u2212\u03b8)")
  # Cellules (poids x marge), dans l'ordre de stockage.
  CELL_FR <- expand.grid(marge = names(MARGES_FR), poids = names(POIDS_FR), stringsAsFactors = FALSE)
  CELL_FR <- CELL_FR[, c("poids", "marge")]
  ctrl_fr <- character(0)
  t5 <- Sys.time()
  rng_avant_fr <- list(RNGkind(), get0(".Random.seed", envir = globalenv(), inherits = FALSE))
  MES_FR <- lapply(JEUX_FR, function(J) {
    x <- J$x; Tj <- length(x)
    FIT0 <- usp_ajuster(x, J$y)
    # Flux de C3 (meme graine, meme expression) : L* = usp_simuler(FIT0),
    # tous tires avant toute evaluation ; communs aux trois valeurs de a.
    L <- engine_sous_graine(J$graine, lapply(seq_len(OPT_R), function(b) usp_simuler(FIT0)))
    # W0 : pi0 tel que (x/xbar)^2 expm1(1/pi0) = 1, d'ou des poids
    # usp_poids_gls() constants (TOST MCO d'avant #215).
    pi0 <- 1 / log1p((mean(x) / x)^2)
    w0 <- usp_poids_gls(x, pi0)
    bx <- FIT0$beta * mean(x)
    A <- c(moins = -THETA_TOST * bx / (1 + THETA_TOST), zero = 0, plus = THETA_TOST * bx / (1 - THETA_TOST))
    par_a <- lapply(names(A), function(na) {
      a <- A[[na]]
      dabs <- THETA_TOST * (a + bx)        # theta E[Ybar] ; = |a| aux frontieres
      # statut : ok, refus (#188, #227), erreur (usp_ajuster()), ynonpos (y* <= 0)
      statut <- character(OPT_R)
      # V[cellule, grandeur, b] ; code : 0 calcule, 1 non applicable, 2 erreur
      V <- array(NA_real_, c(nrow(CELL_FR), 5L, OPT_R),
                 dimnames = list(paste(CELL_FR$poids, CELL_FR$marge), c("p", "a", "se", "delta", "code"), NULL))
      for (b in seq_len(OPT_R)) {
        y <- a + L[[b]]
        if (any(!is.finite(y)) || any(y <= 0)) { statut[b] <- "ynonpos"; next }
        fs <- tryCatch(usp_ajuster(x, y), error = function(e) NULL)
        if (is.null(fs)) { statut[b] <- "erreur"; next }
        statut[b] <- if (isTRUE(usp_valider_ajustement(fs, "premium")$ok)) "ok" else "refus"
        pis <- list(W1 = fs$pi, W2 = FIT0$pi, W0 = pi0)
        for (k in seq_len(nrow(CELL_FR))) {
          r <- tryCatch(test_tost_intercept(x, y, pis[[CELL_FR$poids[k]]], theta = THETA_TOST,
                                            delta_abs = if (CELL_FR$marge[k] == "a_priori") dabs),
                        error = function(e) NULL)
          V[k, , b] <- if (is.null(r)) c(NA, NA, NA, NA, 2)
                       else if (!is.na(r$non_applicable)) c(NA, NA, NA, NA, 1)
                       else c(r$p, r$a, r$se, r$delta, 0)
        }
      }
      list(a = a, dabs = dabs, statut = statut, V = V,
           b1 = match("ok", statut), y1 = if (!is.na(match("ok", statut))) a + L[[match("ok", statut)]])
    })
    names(par_a) <- names(A)
    list(J = J, T = Tj, FIT0 = FIT0, pi0 = pi0, w0 = w0, bx = bx, par_a = par_a,
         L1 = L[[1]], L1_isole = engine_sous_graine(J$graine, usp_simuler(FIT0)))
  })
  duree_fr <- as.numeric(difftime(Sys.time(), t5, units = "secs"))

  # TOST transcrit independamment de test_tost_intercept() (controle des
  # cellules W0 et W2, que run_engine() ne calcule pas) : lm() pondere aux
  # poids w (constants pour W0), regle du maximum, t(T - 2).
  tost_transcrit <- function(x, y, w, Delta) {
    co <- summary(stats::lm(y ~ x, weights = w))$coefficients
    a <- co[1, 1]; se <- co[1, 2]
    max(stats::pt((a + Delta) / se, length(x) - 2, lower.tail = FALSE),
        stats::pt((a - Delta) / se, length(x) - 2, lower.tail = TRUE))
  }
  NOM_A <- c(moins = "a\u208b", zero = "a = 0", plus = "a\u208a")
  for (m in MES_FR) {
    cj <- m$J$code; x <- m$J$x
    ctrl_fr <- c(ctrl_fr, controle(!is.null(m$w0) && max(abs(m$w0 / m$w0[1] - 1)) < 1e-12,
      sprintf("C5 %s, W0 : poids usp_poids_gls(x, pi0) constants, max|w/w\u2081 \u2212 1| < 1e-12 (mesur\u00e9 : %s)",
              cj, if (is.null(m$w0)) "poids invalides" else format(max(abs(m$w0 / m$w0[1] - 1)), digits = 3))))
    ctrl_fr <- c(ctrl_fr, controle(identical(m$L1, m$L1_isole),
      sprintf("C5 %s, premier L* du flux identique \u00e0 un tirage isol\u00e9 sous la m\u00eame graine (flux de C3)", cj)))
    for (na in names(m$par_a)) {
      pa <- m$par_a[[na]]; b1 <- pa$b1
      # Premiere p de chaque cellule (premiere replication retenue) : W1
      # contre la ligne TOST de run_engine() (marge estimee : theta_equiv par
      # defaut ; marge a priori : delta_equiv = dabs) ; W0 et W2 contre la
      # transcription independante.
      ok_prem <- !is.na(b1) && all(vapply(seq_len(nrow(CELL_FR)), function(k) {
        p1 <- pa$V[k, "p", b1]
        Dk <- if (CELL_FR$marge[k] == "a_priori") pa$dabs else THETA_TOST * mean(pa$y1)
        ref <- switch(CELL_FR$poids[k],
          W1 = tryCatch(p_tost_moteur(x, pa$y1, if (CELL_FR$marge[k] == "a_priori") pa$dabs),
                        error = function(e) NA_real_),
          W2 = tost_transcrit(x, pa$y1, 1 / (x^2 * expm1(1 / m$FIT0$pi)), Dk),
          W0 = tost_transcrit(x, pa$y1, NULL, Dk))
        isTRUE(all.equal(p1, ref, tolerance = 1e-10))
      }, logical(1)))
      ctrl_fr <- c(ctrl_fr, controle(ok_prem,
        sprintf(paste("C5 %s, %s, premi\u00e8re p de chaque cellule (r\u00e9plication %s) = p_asymptotique de la",
                      "ligne TOST de run_engine() (W1, deux marges) ou TOST transcrit par lm() (W0, W2)"),
                cj, NOM_A[[na]], format(b1))))
      # p < alpha <=> Delta - |a| > t_{1-alpha, T-2} se, cellule par cellule.
      ok_eq <- all(vapply(seq_len(nrow(CELL_FR)), function(k) {
        f <- is.finite(pa$V[k, "p", ])
        all(vapply(ALPHAS_118, function(al) identical(
          pa$V[k, "p", f] < al,
          pa$V[k, "delta", f] - abs(pa$V[k, "a", f]) > stats::qt(1 - al, m$T - 2) * pa$V[k, "se", f]), logical(1)))
      }, logical(1)))
      ctrl_fr <- c(ctrl_fr, controle(ok_eq,
        sprintf("C5 %s, %s, conclusion (p < \u03b1) \u00e9quivalente \u00e0 \u0394 \u2212 |\u00e2| > t(1 \u2212 \u03b1, T \u2212 2) se(\u00e2), r\u00e9plication par r\u00e9plication", cj, NOM_A[[na]])))
      # Marge a priori : delta restitue = theta E[Ybar] ; aux frontieres, |a|.
      dm <- pa$V[CELL_FR$marge == "a_priori", "delta", ]
      ok_marge <- all(dm[is.finite(dm)] == pa$dabs) &&
        (na == "zero" || isTRUE(all.equal(pa$dabs, abs(pa$a), tolerance = 1e-12)))
      ctrl_fr <- c(ctrl_fr, controle(ok_marge,
        sprintf("C5 %s, %s, marge fix\u00e9e a priori = \u03b8(a + \u03b2x\u0304)%s", cj, NOM_A[[na]],
                if (na == "zero") "" else " = |a|")))
    }
  }
  # Releve apres la boucle de controles (appels de run_engine() compris).
  rng_apres_fr <- list(RNGkind(), get0(".Random.seed", envir = globalenv(), inherits = FALSE))
  duree_ctrl_fr <- as.numeric(difftime(Sys.time(), t5, units = "secs")) - duree_fr
  ctrl_fr <- c(ctrl_fr, controle(identical(rng_avant_fr, rng_apres_fr),
    "C5, RNGkind() et .Random.seed de l'appelant restaur\u00e9s apr\u00e8s les tirages et les contr\u00f4les (run_engine() compris)"))

  # Lecture d'un taux a la frontiere (specification d'actuary, #175,
  # commentaire 6058041254) : tenu si la borne basse de l'IC <= alpha ;
  # depassement mineur si l'IC est au-dessus de alpha et l'estimation
  # <= 1,5 alpha ; distorsion materielle si la borne basse > 1,5 alpha ;
  # depassement non tranche (classe ajoutee par le mainteneur, PR #228,
  # commentaire 6062485163) si la borne basse est dans ]alpha ; 1,5 alpha] et
  # l'estimation > 1,5 alpha.
  lecture_fr <- function(k, n, al) {
    if (n == 0L) return("\u2014")
    ci <- ic_cp(k, n)
    if (ci[1] <= al) "tenu"
    else if (ci[1] > 1.5 * al) "**distorsion mat\u00e9rielle**"
    else if (k / n <= 1.5 * al) "d\u00e9passement mineur"
    else "**d\u00e9passement non tranch\u00e9**"
  }
  # Regle du majorant (meme commentaire) : e replications ecartees pour le
  # couple (jeu, a) ; si e > 0, classe recalculee au taux (k + e) / (n + e).
  majorant_fr <- function(k, n, e, al) {
    if (e == 0L) return("e = 0")
    c0 <- lecture_fr(k, n, al); c1 <- lecture_fr(k + e, n + e, al)
    if (identical(c0, c1)) sprintf("classe stable (e = %d)", e)
    else sprintf("**change avec le majorant** (e = %d : %s)", e, gsub("**", "", c1, fixed = TRUE))
  }
  cell_txt <- function(p, al) {
    k <- sum(p < al); n <- length(p)
    if (n == 0L) return(c("0 / 0", "\u2014", "\u2014"))
    ci <- ic_cp(k, n)
    c(sprintf("%d / %d", k, n), num(k / n, 4), sprintf("[%s ; %s]", num(ci[1], 4), num(ci[2], 4)))
  }
  ORDRE_A <- c("moins", "plus", "zero")
  lignes_fr <- unlist(lapply(MES_FR, function(m) unlist(lapply(ORDRE_A, function(na) {
    pa <- m$par_a[[na]]; ok <- pa$statut == "ok"; e <- sum(!ok)
    vapply(seq_len(nrow(CELL_FR)), function(k) {
      p <- pa$V[k, "p", ok]; f <- is.finite(p)
      lect <- function(al) if (na == "zero") "puissance (a = 0)" else lecture_fr(sum(p[f] < al), sum(f), al)
      maj <- function(al) if (na == "zero") "\u2014" else majorant_fr(sum(p[f] < al), sum(f), e, al)
      ligne_md(m$J$code, FRONT_FR[[na]], num(pa$a, 4), CELL_FR$poids[k], MARGES_FR[[CELL_FR$marge[k]]],
               paste(cell_txt(p[f], 0.10), collapse = " | "), lect(0.10), maj(0.10),
               paste(cell_txt(p[f], 0.05), collapse = " | "), lect(0.05), maj(0.05),
               sum(pa$V[k, "code", ok] == 1), sum(pa$V[k, "code", ok] == 2))
    }, "")
  }))))
  lignes_statut <- unlist(lapply(MES_FR, function(m) vapply(ORDRE_A, function(na) {
    s <- m$par_a[[na]]$statut
    ligne_md(m$J$code, FRONT_FR[[na]], num(m$par_a[[na]]$a, 4), num(m$par_a[[na]]$dabs, 4), length(s),
             sum(s == "ynonpos"), sum(s == "erreur"), sum(s == "refus"), sum(s == "ok"))
  }, "")))
  # a = 0, W1, marge estimee, a la maniere de C3 : denominateur des
  # reajustements reussis, refus de #188 compris (C3 n'applique pas
  # usp_valider_ajustement()) ; meme flux, meme calcul : egal au tableau C3.a
  # de --partie tost a R et graine egaux.
  lignes_c3 <- unlist(lapply(MES_FR, function(m) {
    pa <- m$par_a[["zero"]]; reussi <- pa$statut %in% c("ok", "refus")
    p <- pa$V["W1 estimee", "p", reussi]
    vapply(ALPHAS_118, function(al) ligne_md(m$J$code, num(al, 2), paste(cellules_taux(p, al), collapse = " | "),
                                             num_p(min(p)), sum(!reussi)), "")
  }))
  # Rapprochement de C5.c avec le tableau versionne de C3 (avis d'actuary) :
  # a R = 20 000 et --graine 20260927 seulement ; non bloquant (hors
  # controles). Comptes du tableau C3.a de
  # docs/tableaux/20261007-issue215-tost.md (commit a7724d4).
  REF_C3_215 <- data.frame(jeu = c("J1", "J1", "J2", "J2"), alpha = c(0.10, 0.05, 0.10, 0.05),
                           k = c(0L, 0L, 8708L, 4098L), n = 20000L, stringsAsFactors = FALSE)
  rapprochement_c5c <- function(comptes, R, graine) {
    if (R != 20000L || graine != 20260927) return(character(0))
    ecarts <- unlist(lapply(seq_len(nrow(REF_C3_215)), function(i) {
      r <- REF_C3_215[i, ]
      j <- which(comptes$jeu == r$jeu & abs(comptes$alpha - r$alpha) < 1e-12)
      if (length(j) != 1L) return(sprintf("%s, \u03b1 = %s : absent de C5.c", r$jeu, num(r$alpha, 2)))
      if (isTRUE(comptes$k[j] == r$k && comptes$n[j] == r$n)) return(NULL)
      sprintf("%s, \u03b1 = %s : C5.c %s / %s, tableau %d / %d", r$jeu, num(r$alpha, 2),
              format(comptes$k[j]), format(comptes$n[j]), r$k, r$n)
    }))
    c(paste("Rapprochement de C5.c avec le tableau C3.a de docs/tableaux/20261007-issue215-tost.md (commit a7724d4 ;",
            "J1 0 / 20000 \u00e0 \u03b1 = 0,10 et 0,05 ; J2 8708 / 20000 \u00e0 0,10 et 4098 / 20000 \u00e0 0,05 ;",
            "non bloquant) :",
            if (length(ecarts)) paste0("**\u00e9cart** : ", paste(ecarts, collapse = " ; "), ".") else "identique."), "")
  }
  comptes_c5c <- do.call(rbind, lapply(MES_FR, function(m) {
    pa <- m$par_a[["zero"]]; reussi <- pa$statut %in% c("ok", "refus")
    p <- pa$V["W1 estimee", "p", reussi]
    data.frame(jeu = m$J$code, alpha = ALPHAS_118, k = vapply(ALPHAS_118, function(al) sum(p < al), integer(1)),
               n = sum(reussi), stringsAsFactors = FALSE)
  }))
  ligne_rappr_fr <- rapprochement_c5c(comptes_c5c, OPT_R, OPT_GRAINE)
  section_fr <- c(
    "### C5 -- TOST de la constante : niveau \u00e0 la fronti\u00e8re a = \u00b1\u0394, T = 8 (issue #219)", "",
    paste("Statut : **constat de simulation** du taux de conclusion **\u00e0 tort** \u00e0 l'\u00e9quivalence quand la",
          "constante vraie vaut \u00b1\u0394, \u0394 = \u03b8 E[\u0232], \u03b8 = 0,10. G\u00e9n\u00e9rateur : Y*_t = a + L*_t, L* =",
          "usp_simuler(FIT0), FIT0 = usp_ajuster() sur le jeu observ\u00e9 (x fixe) : E[Y_t] = a + \u03b2x_t et",
          "variance r\u00e9glementaire exacte. a\u208a = \u03b8\u03b2x\u0304/(1 \u2212 \u03b8) et a\u208b = \u2212\u03b8\u03b2x\u0304/(1 + \u03b8) placent a sur",
          "\u00b1\u03b8 E[\u0232]. Chaque y* est r\u00e9ajust\u00e9 par usp_ajuster() ; refus de #188 (usp_valider_ajustement()),",
          "erreurs et y* \u2264 0 \u00e9cart\u00e9s et compt\u00e9s ; le taux porte sur les r\u00e9plications retenues",
          "communes aux six cellules ; dans chaque cellule, cas non applicables et erreurs du test retir\u00e9s du",
          "d\u00e9nominateur et compt\u00e9s. p = test_tost_intercept(x, y*, \u03c0, \u03b8 = 0,10[, delta_abs]) : poids W1 (outil,",
          "fit*$pi), W2 (oracle, FIT0$pi), W0 (poids constants : TOST MCO d'avant #215) ; marge estim\u00e9e",
          "\u0394* = \u03b8\u0233* (celle de l'outil) ou fix\u00e9e a priori, delta_abs = \u03b8 E[\u0232] = \u03b8(a + \u03b2x\u0304).",
          "Conclusion si p < \u03b1. Lecture (sp\u00e9cification d'actuary, #175, commentaire 6058041254) : tenu si",
          "la borne basse de l'IC \u2264 \u03b1 ; d\u00e9passement mineur si l'IC est au-dessus de \u03b1 et l'estimation",
          "\u2264 1,5\u03b1 ; distorsion mat\u00e9rielle si la borne basse > 1,5\u03b1 ; d\u00e9passement non tranch\u00e9",
          "(classe ajout\u00e9e par le mainteneur, PR #228, commentaire 6062485163) si la borne basse est dans",
          "]\u03b1 ; 1,5\u03b1] et l'estimation > 1,5\u03b1 : d\u00e9passement significatif, mat\u00e9rialit\u00e9 non \u00e9tablie \u00e0 R",
          "donn\u00e9. Suites : tenu et d\u00e9passement mineur, aucune ; distorsion mat\u00e9rielle et d\u00e9passement non",
          "tranch\u00e9, d\u00e9cision du mainteneur, renvoi \u00e0 #216 et #217. Colonne a = 0 : probabilit\u00e9 de",
          "conclure (puissance), non un niveau."), "",
    paste("R\u00e8gle de lecture du d\u00e9nominateur (m\u00eame commentaire) : le taux est conditionnel au rendu d'un",
          "r\u00e9sultat par l'outil (d\u00e9nominateur commun = r\u00e9plications retenues ; comparaisons W0/W1/W2",
          "appari\u00e9es). Pour un couple (jeu, a) avec e > 0 r\u00e9plications \u00e9cart\u00e9es (y* \u2264 0, erreurs, refus",
          "de #188 ; C5.b), la colonne \u00ab Classe avec le majorant \u00bb v\u00e9rifie que la classe reste la m\u00eame",
          "avec le taux majorant (k + e)/(n + e) : \u00ab classe stable \u00bb, ou \u00ab change avec le majorant \u00bb et",
          "la classe obtenue ; \u00ab e = 0 \u00bb sans r\u00e9plication \u00e9cart\u00e9e."), "",
    sprintf("R\u00e9plications : %d par jeu et par valeur de a (L* communs aux trois valeurs). Graines : flux de C3, J1 %s ; J2 %s.",
            OPT_R, format(OPT_GRAINE + 3, scientific = FALSE), format(OPT_GRAINE + 4, scientific = FALSE)), "",
    "**C5.a -- Taux de conclusion d'\u00e9quivalence (p < \u03b1), par jeu, valeur de a, poids et marge**", "",
    entete_md(c("Jeu", "a", "Valeur de a", "Poids", "Marge",
                "Conclusions (\u03b1 = 0,10)", "Taux", "IC 95 % (C-P)", "Lecture", "Classe avec le majorant",
                "Conclusions (\u03b1 = 0,05)", "Taux", "IC 95 % (C-P)", "Lecture", "Classe avec le majorant",
                "Non applicables", "Erreurs du test")),
    lignes_fr, "",
    "**C5.b -- R\u00e9plications \u00e9cart\u00e9es, par jeu et valeur de a**", "",
    entete_md(c("Jeu", "a", "Valeur de a", "Marge a priori \u03b8 E[\u0232]", "R", "y* \u2264 0",
                "Erreurs de r\u00e9ajustement", "Refus de #188", "Retenues")),
    lignes_statut, "",
    paste("**C5.c -- a = 0, W1, marge estim\u00e9e, \u00e0 la mani\u00e8re de C3** (r\u00e9ajustements r\u00e9ussis, refus de #188",
          "compris ; m\u00eame flux et m\u00eame calcul que C3 : \u00e9gal au tableau C3.a de --partie tost \u00e0 R et graine \u00e9gaux)"), "",
    entete_md(c("Jeu", "\u03b1", "Conclusions / r\u00e9ajustements r\u00e9ussis", "Taux", "IC 95 % (C-P)", "p minimale",
                "\u00c9checs de r\u00e9ajustement ou y* \u2264 0")),
    lignes_c3, "", ligne_rappr_fr,
    paste0("Jeux : ", paste(vapply(MES_FR, function(m) sprintf("%s : %s ; \u03b2x\u0304 = %s", m$J$code, m$J$libelle,
                                                                num(m$bx, 4)), ""), collapse = " ; "), "."),
    sprintf(paste("Dur\u00e9e de C5 : %.0f s de simulation (%s s par r\u00e9plication, par jeu et par valeur de a)",
                  "et %.0f s de contr\u00f4les (dont run_engine())."), duree_fr,
            num(duree_fr / (OPT_R * length(MES_FR) * 3), 4), duree_ctrl_fr), "")
  sortie <- c(sortie, section_fr)
  controles <- c(controles, ctrl_fr)
  FICHIERS_118[["tost-frontiere"]] <- list(section = section_fr, controles = ctrl_fr)
}

# --- Outils communs a C6 et C7 (flux de #72, #220, #174) ---------------------
# Expression des jeux simules de #72 (tests/taux_franchissement_reperes.R,
# affectation de YSIM) : meme flux que #221 (2 000 premiers jeux) et #166 ;
# le texte du script de #72 est relu et compare (controle de C6 et de C7).
# Evaluee dans un environnement ou FIT0 est le modele ajuste au jeu observe.
EXPR_YSIM_72 <- quote(engine_sous_graine(OPT_GRAINE, t(vapply(seq_len(OPT_R), function(b) usp_simuler(FIT0), numeric(T_)))))
expr_72_lue <- tryCatch({
  l72 <- readLines(file.path(RACINE, "tests", "taux_franchissement_reperes.R"), warn = FALSE)
  li <- grep("^YSIM <- ", l72, value = TRUE)
  if (length(li) == 1L) parse(text = li)[[1]][[3]] else NULL
}, error = function(e) NULL)

# --- C6 : test de Pitman sur la pente, simulations a T = 8 (#220) ------------
# Protocole dans l'en-tete (C6). Partie executee seule (--partie pitman), hors
# de --partie tout (duree).
if (OPT_PARTIE == "pitman") {
  # Seuil et sens du moteur : alpha par defaut de run_engine(), verdicts du
  # sens "rejeter" de engine_registre_tests() (OK si p < alpha, ALERTE si
  # p < SEUIL_ECHEC_SENS_REJETER, ECHEC sinon) ; R4 : SEUIL_PUISSANCE_PENTE_R4.
  ALPHA_PIT <- eval(formals(run_engine)$alpha)
  # Regle R4 retiree par D1-Fb (#218, #230) ; reproduit la regle des mesures
  # anterieures.
  SEUIL_PUISSANCE_PENTE_R4 <- 0.5
  LIGNE_PITMAN <- "Test de Pitman sur la pente (lien positif pertes / volume)"
  MODALITES_PIT <- c("OK", "ALERTE", "ECHEC", "diagnostic (R4)", "inop\u00e9rant (R1)", "non applicable")
  verdict_rejeter <- function(p) ifelse(p < ALPHA_PIT, "OK", ifelse(p < SEUIL_ECHEC_SENS_REJETER, "ALERTE", "ECHEC"))
  # Modalite de la ligne Pitman : non applicable (t non fini) ; diagnostic
  # par R4 (type fixe par usp_tests() avant add()) ; inoperant par R1
  # (p_min >= alpha, add()) ; verdict sinon. diag_r4 = FALSE pour P1.
  modalite_pitman <- function(p, p_min, t, diag_r4) {
    m <- verdict_rejeter(p)
    m[is.finite(p_min) & p_min >= ALPHA_PIT] <- "inop\u00e9rant (R1)"
    m[diag_r4 %in% TRUE] <- "diagnostic (R4)"
    m[!is.finite(t)] <- "non applicable"
    m[is.na(diag_r4)] <- NA_character_
    unname(m)
  }
  # Type et verdict de la ligne du moteur attendus pour une modalite ; unname()
  # : une modalite nommee (vecteur de longueur 1 a --R 1) ferait echouer
  # identical() (constat m1 de l'audit de #220).
  type_de <- function(m) switch(unname(m), OK = , ALERTE = , ECHEC = "test", "non applicable" = "non applicable", "diagnostic")
  verdict_de <- function(m) if (m %in% c("OK", "ALERTE", "ECHEC")) unname(m) else "INFO"
  # Une replication : p unilaterale, p bilaterale et r de permutation
  # (usp_permutation_pente(), sens du moteur), p_min, t de la pente de
  # test_lm_complet() et sa p de Student unilaterale, t(T - 2).
  pitman_rep <- function(x, y) {
    pp <- usp_permutation_pente(x, y, unilateral = .pitman_unilateral())
    tt <- test_lm_complet(x, y)$t_pente
    c(p = pp$p, p_bi = pp$p_bilateral, r = pp$r, p_min = pp$p_min, t = tt,
      p_st = if (is.finite(tt)) stats::pt(tt, length(x) - 2, lower.tail = FALSE) else NA_real_)
  }
  # R4 sur un reajustement : puissance unilaterale approchee de
  # usp_identifiabilite_pente() aux beta et sigma de usp_ajuster(x, y*),
  # comme usp_tests() ; NA si le reajustement echoue. refus : refus de #188
  # (usp_valider_ajustement(), compte, non ecarte).
  r4_rep <- function(x, y) {
    fs <- tryCatch(usp_ajuster(x, y), error = function(e) NULL)
    if (is.null(fs)) return(c(puissance = NA_real_, echec = 1, refus = NA_real_))
    pu <- usp_identifiabilite_pente(x, fs$beta, fs$sigma, ALPHA_PIT, unilateral = .pitman_unilateral())$puissance
    c(puissance = pu, echec = 0, refus = as.numeric(!isTRUE(usp_valider_ajustement(fs, "premium")$ok)))
  }
  # Diagnostic R4 de chaque replication (seule regle du script, G1 et G4) :
  # NA si le reajustement echoue, TRUE si la puissance approchee est
  # inferieure a SEUIL_PUISSANCE_PENTE_R4 ; q : sortie de r4_rep() (vecteur) ou
  # matrice de ces sorties, une ligne par replication.
  diag_r4 <- function(q) {
    if (is.null(dim(q))) q <- t(q)
    unname(ifelse(q[, "echec"] == 1, NA, is.finite(q[, "puissance"]) & q[, "puissance"] < SEUIL_PUISSANCE_PENTE_R4))
  }
  # Ligne Pitman de run_engine() (B = 99, graine 20260831 : la p
  # d'enumeration ne depend ni de B ni de la graine) : p_exacte, type,
  # verdict ; NULL si la ligne manque (donnees refusees).
  ligne_pitman_moteur <- function(x, y) {
    res <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II",
                      nature_donnees = "brutes", B = 99, seed = 20260831)
    if (!isTRUE(res$ok)) return(NULL)
    tb <- engine_table_tests(res)
    l <- tb[tb$test == LIGNE_PITMAN, ]
    if (nrow(l) == 1L) l else NULL
  }
  # Correlations des T! appariements, ligne 1 = identite : meme preparation
  # que usp_permutation_pente() (centrage, division par max|.|,
  # normalisation, engine_permutations()), mais produit de la matrice T! x T
  # entiere, la ou le moteur calcule par blocs (.usp_r_permutations(), #222) ;
  # les deux calculs sont identiques au bit pres sous le BLAS de reference
  # (mesure de #222). Controlee sur J1 et J2 observes.
  r_enumeration <- function(x, y) {
    xc <- x - mean(x); yc <- y - mean(y)
    xc <- xc / max(abs(xc)); yc <- yc / max(abs(yc))
    xc <- xc / sqrt(sum(xc^2)); yc <- yc / sqrt(sum(yc^2))
    P <- engine_permutations(length(x))
    as.vector(matrix(yc[P], nrow(P)) %*% xc)
  }
  cell_k <- function(k, n) if (n == 0L) "0 / 0" else {
    ci <- ic_cp(k, n)
    sprintf("%s / %s ; %s [%s ; %s]", format(k), format(n), num(k / n, 4), num(ci[1], 4), num(ci[2], 4))
  }
  cv_x <- function(x) stats::sd(x) / mean(x)

  JEUX_PIT <- lapply(jeux_tost(), function(J) J[c("code", "x", "y", "libelle")])
  CODES_PIT <- vapply(JEUX_PIT, `[[`, "", "code")
  # Controle croise de R4 avec #221 (--ref-221, facultatif) : sortie de
  # tests/taux_franchissement_reperes.R (tranche : COMPTE k|pente ; tableau
  # combine : ligne R4 de T1 bis) ou tranche de tests/calibration_mc_t8.R
  # (COMPTE l|<ligne Pitman>|t|diagnostic). Comptes R4 des replications
  # debut..fin du fichier (meme graine des jeux exigee) contre ceux de P2 sur
  # les memes replications. Absent : ligne "non effectue", sans effet sur le
  # code de sortie ; present et lisible : controle bloquant. Lu et valide
  # AVANT le calcul (constat m3 de l'audit de #220) : fichier illisible
  # (repertoire, erreur de lecture) "non comparable" ; alpha different de
  # ALPHA_PIT, ou n different de fin - debut + 1, refuses ("non comparable").
  lire_ref_221_brut <- function(f, err) {
    if (!file.exists(f)) return(err("fichier introuvable"))
    if (dir.exists(f)) return(err("r\u00e9pertoire, non un fichier"))
    l <- readLines(f, warn = FALSE, encoding = "UTF-8")
    par <- sub("^PARAMETRES\t", "", grep("^PARAMETRES\t", l, value = TRUE))
    tranche <- length(par) > 0L
    if (!tranche) par <- sub("^Param\u00e8tres : ", "", grep("^Param\u00e8tres : jeu=", l, value = TRUE))
    if (length(par) != 1L) return(err("ligne de param\u00e8tres absente ou multiple"))
    kv <- strsplit(strsplit(par, ";", fixed = TRUE)[[1]], "=", fixed = TRUE)
    kv <- stats::setNames(vapply(kv, function(z) if (length(z) == 2L) z[2] else NA_character_, ""),
                          vapply(kv, `[`, "", 1L))
    g <- suppressWarnings(as.numeric(if (!is.na(kv["graine"])) kv[["graine"]] else kv["graine_jeux"]))
    Rf <- suppressWarnings(as.integer(kv["R"]))
    jeu <- unname(kv["jeu"])
    a <- suppressWarnings(as.numeric(kv["alpha"]))
    if (!isTRUE(g == OPT_GRAINE)) return(err("graine des jeux diff\u00e9rente de --graine"))
    if (!isTRUE(a == ALPHA_PIT))
      return(err(sprintf("alpha = %s, diff\u00e9rent de ALPHA_PIT = %s", if (is.na(a)) "absent" else format(a), format(ALPHA_PIT))))
    if (!jeu %in% CODES_PIT || is.na(Rf)) return(err("jeu ou R illisible"))
    if (tranche) {
      tr <- strsplit(sub("^TRANCHE\t", "", grep("^TRANCHE\t", l, value = TRUE)), "\t")
      if (length(tr) != 1L) return(err("ligne TRANCHE absente ou multiple"))
      if (!any(startsWith(l, "FIN\t"))) return(err("sortie incompl\u00e8te (ligne FIN absente)"))
      if (!identical(sub("^INTEGRITE\t", "", grep("^INTEGRITE\t", l, value = TRUE)), "OK"))
        return(err("contr\u00f4le d'int\u00e9grit\u00e9 de la tranche absent ou en \u00e9chec"))
      cp <- strsplit(sub("^COMPTE\t", "", grep("^COMPTE\t", l, value = TRUE)), "\t")
      cp <- stats::setNames(suppressWarnings(as.numeric(vapply(cp, function(z) z[length(z)], ""))),
                            vapply(cp, `[`, "", 1L))
      cles <- if ("n|pente" %in% names(cp)) c(k = "k|pente", n = "n|pente", src = "taux_franchissement_reperes.R")
              else c(k = sprintf("l|%s|t|diagnostic", LIGNE_PITMAN), n = sprintf("l|%s|n", LIGNE_PITMAN),
                     src = "calibration_mc_t8.R")
      if (!cles[["n"]] %in% names(cp)) return(err("aucun compte de la ligne Pitman"))
      k <- if (cles[["k"]] %in% names(cp)) cp[[cles[["k"]]]] else 0
      deb <- as.integer(tr[[1]][1]); fin <- as.integer(tr[[1]][2]); src <- cles[["src"]]
      nf <- cp[[cles[["n"]]]]
    } else {
      li <- grep("^\\| R\u00e8gle de restitution R4", l, value = TRUE)
      if (length(li) != 1L || !grepl("Pitman", li, fixed = TRUE))
        return(err("ligne R4 de T1 bis absente, multiple ou ant\u00e9rieure \u00e0 #169"))
      ch <- trimws(strsplit(li, "|", fixed = TRUE)[[1]])
      k <- suppressWarnings(as.numeric(ch[5])); deb <- 1L; fin <- Rf; src <- "taux_franchissement_reperes.R (tableau)"
      nf <- suppressWarnings(as.numeric(ch[6]))
      if (!is.finite(k)) return(err("compte R4 illisible"))
    }
    if (is.na(deb) || is.na(fin) || deb < 1L || fin > OPT_R)
      return(err(sprintf("r\u00e9plications %s-%s hors de 1..R = %d", deb, fin, OPT_R)))
    if (!isTRUE(nf == fin - deb + 1))
      return(err(sprintf("n = %s diff\u00e9rent de fin - d\u00e9but + 1 = %d", format(nf), fin - deb + 1L)))
    list(fichier = f, erreur = NULL, jeu = jeu, debut = deb, fin = fin, k = k, source = src)
  }
  lire_ref_221 <- function(f) {
    err <- function(m) list(fichier = f, erreur = m)
    tryCatch(suppressWarnings(lire_ref_221_brut(f, err)),
             error = function(e) err(paste("illisible :", conditionMessage(e))))
  }
  REFS_221 <- if (is.na(OPT_REF_221)) list() else lapply(strsplit(OPT_REF_221, ",", fixed = TRUE)[[1]], lire_ref_221)
  for (r in REFS_221) message("C6, --ref-221 (lu avant le calcul) : ", basename(r$fichier), " : ",
                               if (is.null(r$erreur)) sprintf("jeu %s, r\u00e9plications %d-%d", r$jeu, r$debut, r$fin)
                               else paste("non comparable,", r$erreur))
  # --ecrire a R >= 2 000 : J1 et J2 compares, chaque reference lisible
  # (constat m4) ; le compte egal est ensuite un controle bloquant.
  if (!is.na(OPT_ECRIRE) && OPT_R >= 2000L) {
    lus <- Filter(function(r) is.null(r$erreur), REFS_221)
    if (length(lus) < length(REFS_221) || !all(c("J1", "J2") %in% vapply(lus, `[[`, "", "jeu")))
      stop("--ecrire avec --partie pitman et --R >= 2000 : chaque r\u00e9f\u00e9rence --ref-221 doit \u00eatre lisible ",
           "et J1 et J2 doivent \u00eatre compar\u00e9s (aucun calcul lanc\u00e9)")
  }


  ctrl_pit <- character(0)
  t6 <- Sys.time()
  rng_avant_pit <- list(RNGkind(), get0(".Random.seed", envir = globalenv(), inherits = FALSE))

  # G1, G2, G4 (variantes de sens) : flux de #72 ; G4 (pente negative) :
  # flux --graine + 14, meme graine pour les deux jeux (comme G1).
  t_g1 <- Sys.time()
  MES_PIT <- lapply(JEUX_PIT, function(J) {
    x <- J$x
    if (length(x) != T_) stop("C6 : jeu ", J$code, " de longueur ", length(x), ", T = ", T_, " attendu")
    FIT0 <- usp_ajuster(x, J$y)
    YSIM <- eval(EXPR_YSIM_72)
    # Une ligne par replication (G1 P1, G2, G4 variantes), puis R4 (G1 P2).
    M <- t(vapply(seq_len(OPT_R), function(b) pitman_rep(x, YSIM[b, ]), numeric(6)))
    Q <- t(vapply(seq_len(OPT_R), function(b) r4_rep(x, YSIM[b, ]), numeric(3)))
    list(J = J, FIT0 = FIT0, YSIM = YSIM, M = M, Q = Q,
         y1_isole = engine_sous_graine(OPT_GRAINE, usp_simuler(FIT0)))
  })
  names(MES_PIT) <- vapply(JEUX_PIT, `[[`, "", "code")
  duree_g1 <- as.numeric(difftime(Sys.time(), t_g1, units = "secs"))

  t_g4 <- Sys.time()
  NEG_PIT <- lapply(MES_PIT, function(m) {
    x <- m$J$x; FIT0 <- m$FIT0
    # Volumes reflechis x' = min x + max x - x : modele ajuste deplace en x'
    # (E[Y_t] = beta x'_t, pi' = usp_pi(delta, gamma, x')), teste contre x.
    xr <- min(x) + max(x) - x
    fit_r <- FIT0; fit_r$x <- xr; fit_r$pi <- usp_pi(FIT0$delta, FIT0$gamma, xr)
    Yn <- engine_sous_graine(OPT_GRAINE + 14, t(vapply(seq_len(OPT_R), function(b) usp_simuler(fit_r), numeric(T_))))
    M <- t(vapply(seq_len(OPT_R), function(b) pitman_rep(x, Yn[b, ]), numeric(6)))
    # R4 par reajustement de chaque jeu (ligne "pente negative, P2 avec R4"
    # de C6.d, avis A5 d'actuary).
    Q <- t(vapply(seq_len(OPT_R), function(b) r4_rep(x, Yn[b, ]), numeric(3)))
    list(xr = xr, Yn = Yn, M = M, Q = Q, y1_isole = engine_sous_graine(OPT_GRAINE + 14, usp_simuler(fit_r)))
  })
  duree_g4 <- as.numeric(difftime(Sys.time(), t_g4, units = "secs"))

  # G3 : Y_t = mu + (x_t / xbar)^k eps_t, eps i.i.d. N(0, 1), memes eps pour
  # tous les k et les deux jeux (graine --graine + 11) ; marche aleatoire
  # Y_t = mu + somme_{s <= t} e_s (graine + 12) ; AR(1) stationnaire rho =
  # 0,7, u_1 = e_1 / sqrt(1 - rho^2) (graine + 13). mu = 0 (r invariant par
  # transformation affine croissante de y : controle). Matrices remplies par
  # ligne : les jeux d'un R plus petit sont les premiers.
  KS_G3 <- c(0, 0.5, 1, 2, 3)
  RHO_G3 <- 0.7
  t_g3 <- Sys.time()
  E11 <- engine_sous_graine(OPT_GRAINE + 11, matrix(stats::rnorm(OPT_R_H0 * T_), nrow = OPT_R_H0, byrow = TRUE))
  E12 <- engine_sous_graine(OPT_GRAINE + 12, matrix(stats::rnorm(OPT_R_H0 * T_), nrow = OPT_R_H0, byrow = TRUE))
  E13 <- engine_sous_graine(OPT_GRAINE + 13, matrix(stats::rnorm(OPT_R_H0 * T_), nrow = OPT_R_H0, byrow = TRUE))
  Y_RW <- t(apply(E12, 1L, cumsum))
  Y_AR <- E13
  Y_AR[, 1] <- E13[, 1] / sqrt(1 - RHO_G3^2)
  for (j in 2:T_) Y_AR[, j] <- RHO_G3 * Y_AR[, j - 1] + E13[, j]
  SCEN_G3 <- c(paste0("k=", KS_G3), "marche", "ar1")
  LIB_G3 <- c(sprintf("\u00e9cart-type \u221d (x/x\u0304)^k, k = %s", sub(".", ",", as.character(KS_G3), fixed = TRUE)),
              "marche al\u00e9atoire (tendance commune)", sprintf("AR(1) stationnaire, \u03c1 = %s", num(RHO_G3, 1)))
  G3_PIT <- lapply(MES_PIT, function(m) {
    x <- m$J$x
    ys <- c(lapply(KS_G3, function(k) sweep(E11, 2L, (x / mean(x))^k, `*`)), list(Y_RW, Y_AR))
    names(ys) <- SCEN_G3
    lapply(ys, function(Y) {
      M <- t(vapply(seq_len(nrow(Y)), function(b) pitman_rep(x, Y[b, ]), numeric(6)))
      # Invariance affine (controle) : p de permutation et p de Student de
      # (3 x, 1000 + 7 y) sur les min(R_h0, 100) premieres replications.
      nb <- min(nrow(Y), 100L)
      Ma <- t(vapply(seq_len(nb), function(b) pitman_rep(3 * x, 1000 + 7 * Y[b, ]), numeric(6)))
      list(M = M, inv_p = identical(unname(M[seq_len(nb), "p"]), unname(Ma[, "p"])),
           inv_st = isTRUE(all.equal(unname(M[seq_len(nb), "p_st"]), unname(Ma[, "p_st"]), tolerance = 1e-10)))
    })
  })
  duree_g3 <- as.numeric(difftime(Sys.time(), t_g3, units = "secs"))
  duree_pit <- as.numeric(difftime(Sys.time(), t6, units = "secs"))

  # --- Controles d'integrite (C6) ---
  ctrl_pit <- c(ctrl_pit, controle(!is.null(expr_72_lue) && identical(deparse(expr_72_lue), deparse(EXPR_YSIM_72)),
    "C6, expression des jeux simul\u00e9s identique \u00e0 l'affectation de YSIM de tests/taux_franchissement_reperes.R (#72, flux de #221)"))
  # Modalites (P1 sans R4 : regle du moteur depuis D1-Fb ; P2 avec R4 :
  # reproduction historique, SEUIL_PUISSANCE_PENTE_R4).
  for (cj in names(MES_PIT)) {
    m <- MES_PIT[[cj]]; M <- m$M; Q <- m$Q
    m$diag <- diag_r4(Q)
    m$P1 <- modalite_pitman(M[, "p"], M[, "p_min"], M[, "t"], rep(FALSE, nrow(M)))
    m$P2 <- modalite_pitman(M[, "p"], M[, "p_min"], M[, "t"], m$diag)
    MES_PIT[[cj]] <- m
    ng <- NEG_PIT[[cj]]; ng$diag <- diag_r4(ng$Q)
    ng$P1 <- modalite_pitman(ng$M[, "p"], ng$M[, "p_min"], ng$M[, "t"], rep(FALSE, nrow(ng$M)))
    ng$P2 <- modalite_pitman(ng$M[, "p"], ng$M[, "p_min"], ng$M[, "t"], ng$diag)
    NEG_PIT[[cj]] <- ng
    ctrl_pit <- c(ctrl_pit, controle(identical(m$YSIM[1, ], m$y1_isole),
      sprintf("C6 %s, premier jeu du flux (graine %s) identique \u00e0 un tirage isol\u00e9 sous la m\u00eame graine", cj,
              format(OPT_GRAINE, scientific = FALSE))))
    ctrl_pit <- c(ctrl_pit, controle(identical(NEG_PIT[[cj]]$Yn[1, ], NEG_PIT[[cj]]$y1_isole),
      sprintf("C6 %s, pente n\u00e9gative : premier jeu du flux (graine %s) identique \u00e0 un tirage isol\u00e9", cj,
              format(OPT_GRAINE + 14, scientific = FALSE))))
    ctrl_pit <- c(ctrl_pit, controle(all(is.finite(M[, c("p", "p_bi", "p_min")])) &&
                                       all(is.finite(NEG_PIT[[cj]]$M[, c("p", "p_bi", "p_min")])),
      sprintf("C6 %s, aucune p de permutation manquante (G1, G2, G4)", cj)))
    # p, type et verdict de la premiere replication (G1 ; G4 pente negative)
    # = ligne Pitman de run_engine(), comparee a la modalite P1 (sans R4) :
    # depuis D1-Fb (#218, #230), le moteur n'applique plus R4 et seule R1 le
    # bascule. Replications supplementaires (constat m2), simples controles
    # d'identite de p, type et verdict : premiere replication de G1 que R4
    # classait diagnostic ; replications de G1 dont la puissance approchee
    # est la plus proche de SEUIL_PUISSANCE_PENTE_R4 de chaque cote. diag_r4()
    # (P2, reproduction historique) n'a plus de controle croise avec le
    # moteur.
    rep_g1 <- function(b, lib) list(lib = sprintf("G1, %s (r\u00e9plication %d)", lib, b), y = m$YSIM[b, ],
                                    p = M[b, "p"], mod = m$P1[b])
    prem <- list(list(lib = "G1, premi\u00e8re r\u00e9plication", y = m$YSIM[1, ], p = M[1, "p"], mod = m$P1[1]),
                 list(lib = "G4 (pente n\u00e9gative), premi\u00e8re r\u00e9plication", y = ng$Yn[1, ],
                      p = ng$M[1, "p"], mod = ng$P1[1]))
    b_diag <- which(m$diag %in% TRUE)
    if (length(b_diag)) prem <- c(prem, list(rep_g1(b_diag[1], "premi\u00e8re r\u00e9plication que R4 classait diagnostic, contr\u00f4le d'identit\u00e9")))
    else MES_PIT[[cj]]$sans_diag <- sprintf(paste("C6 %s, G1 : aucune r\u00e9plication que R4 classait diagnostic parmi %d r\u00e9plications",
                                                  "(contr\u00f4le d'identit\u00e9 suppl\u00e9mentaire non fait ; non bloquant)"), cj, nrow(M))
    pu <- Q[, "puissance"]
    b_sous <- which(is.finite(pu) & pu < SEUIL_PUISSANCE_PENTE_R4); b_sur <- which(is.finite(pu) & pu >= SEUIL_PUISSANCE_PENTE_R4)
    if (length(b_sous)) prem <- c(prem, list(rep_g1(b_sous[which.max(pu[b_sous])], sprintf(
      "contr\u00f4le d'identit\u00e9, puissance approch\u00e9e la plus proche sous le seuil historique de R4, %s", num(max(pu[b_sous]), 4)))))
    if (length(b_sur)) prem <- c(prem, list(rep_g1(b_sur[which.min(pu[b_sur])], sprintf(
      "contr\u00f4le d'identit\u00e9, puissance approch\u00e9e la plus proche au-dessus du seuil historique de R4, %s", num(min(pu[b_sur]), 4)))))
    for (pr in prem) {
      lm_ <- tryCatch(ligne_pitman_moteur(m$J$x, pr$y), error = function(e) NULL)
      ok <- !is.null(lm_) && !is.na(pr$mod) && identical(unname(lm_$p_exacte), unname(pr$p)) &&
        identical(lm_$type, type_de(pr$mod)) && identical(lm_$verdict, verdict_de(pr$mod))
      ctrl_pit <- c(ctrl_pit, controle(ok, sprintf(paste(
        "C6 %s, %s : p de usp_permutation_pente(), type et verdict du script sans R4 (P1)",
        "(%s ; p = %s) identiques \u00e0 p_exacte, type et verdict de la ligne Pitman de run_engine() (%s)"),
        cj, pr$lib, if (is.na(pr$mod)) "r\u00e9ajustement en \u00e9chec" else pr$mod, num_p(pr$p),
        if (is.null(lm_)) "ligne absente" else sprintf("%s, %s, p = %s", lm_$type, lm_$verdict, num_p(lm_$p_exacte)))))
    }
    # Enumeration transcrite : p unilaterale de r_enumeration() = p de
    # usp_permutation_pente() sur le jeu observe.
    rp <- r_enumeration(m$J$x, m$J$y)
    p_tr <- sum(rp >= rp[1] - TOL_EX_AEQUO) / length(rp)
    MES_PIT[[cj]]$r_obs_enum <- rp
    ctrl_pit <- c(ctrl_pit, controle(identical(p_tr, usp_permutation_pente(m$J$x, m$J$y)$p),
      sprintf("C6 %s, \u00e9num\u00e9ration transcrite (r_enumeration()) : p unilat\u00e9rale = p de usp_permutation_pente() sur le jeu observ\u00e9", cj)))
    inv <- vapply(G3_PIT[[cj]], function(g) g$inv_p && g$inv_st, logical(1))
    ctrl_pit <- c(ctrl_pit, controle(all(inv),
      sprintf(paste("C6 %s, G3, invariance affine : p de permutation identiques et p de Student \u00e9gales (1e-10)",
                    "pour (3x, 1000 + 7y) sur les %d premi\u00e8res r\u00e9plications de chaque sc\u00e9nario%s"),
              cj, min(OPT_R_H0, 100L), if (all(inv)) "" else paste0(" (\u00e9chec : ", paste(SCEN_G3[!inv], collapse = ", "), ")"))))
    # Refus de #188 dans P2 (avis A6) : aucun sur les jeux de #221 (b <= 2 000).
    nb_221 <- min(nrow(Q), 2000L)
    k_refus_221 <- sum(Q[seq_len(nb_221), "refus"] == 1, na.rm = TRUE)
    ctrl_pit <- c(ctrl_pit, controle(k_refus_221 == 0, sprintf(
      "C6 %s, P2 : aucun refus de #188 (usp_valider_ajustement()) sur les r\u00e9plications 1-%d (jeux de #221) : %d refus",
      cj, nb_221, k_refus_221)))
    ctrl_pit <- c(ctrl_pit, controle(all(vapply(G3_PIT[[cj]], function(g) all(is.finite(g$M[, "p"])), logical(1))),
      sprintf("C6 %s, G3, aucune p de permutation manquante", cj)))
  }
  rng_apres_pit <- list(RNGkind(), get0(".Random.seed", envir = globalenv(), inherits = FALSE))
  ctrl_pit <- c(ctrl_pit, controle(identical(rng_avant_pit, rng_apres_pit),
    "C6, RNGkind() et .Random.seed de l'appelant restaur\u00e9s apr\u00e8s les tirages et les contr\u00f4les (run_engine() compris)"))

  lignes_ref <- if (is.na(OPT_REF_221)) {
    "Contr\u00f4le crois\u00e9 de R4 avec #221 : non effectu\u00e9 (aucune r\u00e9f\u00e9rence --ref-221 ; sans effet sur le code de sortie)."
  } else unlist(lapply(REFS_221, function(r) {
    f <- r$fichier
    if (!is.null(r$erreur))
      return(sprintf("Contr\u00f4le crois\u00e9 de R4 avec #221 : %s non comparable (%s) ; sans effet sur le code de sortie.",
                     basename(f), r$erreur))
    d <- MES_PIT[[r$jeu]]$diag[r$debut:r$fin]
    k_s <- sum(d, na.rm = TRUE)
    ctrl_pit <<- c(ctrl_pit, controle(k_s == r$k && !anyNA(d), sprintf(
      "C6 %s, compte R4 des r\u00e9plications %d-%d (P2) = compte de #221 (%s, %s) : script %d, r\u00e9f\u00e9rence %.0f%s",
      r$jeu, r$debut, r$fin, basename(f), r$source, k_s, r$k,
      if (anyNA(d)) sprintf(", %d r\u00e9ajustement(s) en \u00e9chec", sum(is.na(d))) else "")))
    NULL
  }))

  # --- Tableaux ---
  ligne_modalites <- function(cj, prot, mod) {
    n <- sum(!is.na(mod))
    ligne_md(cj, prot, format(n),
             paste(vapply(MODALITES_PIT, function(mo) cell_k(sum(mod == mo, na.rm = TRUE), n), ""), collapse = " | "))
  }
  lignes_g1 <- unlist(lapply(names(MES_PIT), function(cj) {
    m <- MES_PIT[[cj]]; test <- m$P2 %in% c("OK", "ALERTE", "ECHEC")
    c(ligne_modalites(cj, "P1 : sans R4", m$P1),
      ligne_modalites(cj, "P2 : avec R4", m$P2),
      ligne_modalites(cj, "P2, conditionnel aux lignes rest\u00e9es \u00ab test \u00bb", m$P2[test]))
  }))
  lignes_g1_aj <- vapply(names(MES_PIT), function(cj) {
    Q <- MES_PIT[[cj]]$Q
    ligne_md(cj, format(nrow(Q)), format(sum(Q[, "echec"] == 1)), format(sum(Q[, "refus"] == 1, na.rm = TRUE)),
             num(stats::median(Q[, "puissance"], na.rm = TRUE), 4))
  }, "")
  # Refus de #188 (avis A6) : comptes, non exclus de P2 ; s'il y en a, chaque
  # taux de modalite de P2 est connu a k_refus / n pres.
  lignes_refus <- unlist(lapply(names(MES_PIT), function(cj) {
    m <- MES_PIT[[cj]]; kr <- sum(m$Q[, "refus"] == 1, na.rm = TRUE); n <- sum(!is.na(m$P2))
    if (kr == 0) return(NULL)
    sprintf(paste("%s : %d refus de #188 sur %d r\u00e9ajustements de P2 (compt\u00e9s, non exclus) ; chaque taux de modalit\u00e9",
                  "de P2 (OK, ALERTE, ECHEC, diagnostic (R4)) peut varier d'au plus %d / %d = %s si ces lignes \u00e9taient \u00e9cart\u00e9es."),
            cj, kr, n, kr, n, num(kr / n, 4))
  }))
  lignes_refus <- c(if (length(lignes_refus)) lignes_refus
                    else "Refus de #188 dans P2 : aucun (J1 et J2).",
                    unlist(lapply(MES_PIT, `[[`, "sans_diag")))
  lignes_g2 <- vapply(names(MES_PIT), function(cj) {
    m <- MES_PIT[[cj]]; M <- m$M
    pib <- usp_identifiabilite_pente(m$J$x, m$FIT0$beta, m$FIT0$sigma, ALPHA_PIT, unilateral = .pitman_unilateral())$puissance
    ligne_md(cj, num(100 * cv_x(m$J$x), 2), num(pib, 4),
             cell_k(sum(M[, "p"] < ALPHA_PIT), nrow(M)),
             cell_k(sum(M[, "p_st"] < ALPHA_PIT, na.rm = TRUE), sum(is.finite(M[, "p_st"]))))
  }, "")
  REF_K0 <- 4031 / 40320
  lignes_g3 <- unlist(lapply(names(MES_PIT), function(cj) {
    x <- MES_PIT[[cj]]$J$x
    vapply(seq_along(SCEN_G3), function(i) {
      M <- G3_PIT[[cj]][[i]]$M; k <- sum(M[, "p"] < ALPHA_PIT); n <- nrow(M)
      ref <- if (SCEN_G3[i] == "k=0") {
        ci <- ic_cp(k, n)
        ks <- sum(M[, "p_st"] < ALPHA_PIT, na.rm = TRUE); ns <- sum(is.finite(M[, "p_st"])); cs <- ic_cp(ks, ns)
        sprintf("permutation : exacte 4031/40320 = %s ; dans l'IC : %s ; Student : exacte %s (\u03b5 normaux, t(T \u2212 2)) ; dans l'IC : %s",
                num(REF_K0, 4), if (ci[1] <= REF_K0 && REF_K0 <= ci[2]) "oui" else "**non**",
                num(ALPHA_PIT, 2), if (ns > 0 && cs[1] <= ALPHA_PIT && ALPHA_PIT <= cs[2]) "oui" else "**non**")
      } else "\u2014"
      ligne_md(cj, num(100 * cv_x(x), 2), LIB_G3[i], cell_k(k, n),
               cell_k(sum(M[, "p_st"] < ALPHA_PIT, na.rm = TRUE), sum(is.finite(M[, "p_st"]))), ref)
    }, "")
  }))
  # G4 : variantes de sens. Unilateral (moteur) ; bilateral pur (p_bilateral) ;
  # bilateral avec regle de signe (ECHEC si r < 0, verdict de p_bilateral
  # sinon) ; toutes sans R4.
  variantes <- function(M) list(
    "unilat\u00e9ral (moteur)" = verdict_rejeter(M[, "p"]),
    "bilat\u00e9ral pur" = verdict_rejeter(M[, "p_bi"]),
    "bilat\u00e9ral avec r\u00e8gle de signe (ECHEC si r < 0)" = ifelse(M[, "r"] < 0, "ECHEC", verdict_rejeter(M[, "p_bi"])))
  lignes_g4 <- function(gen, getM) unlist(lapply(names(MES_PIT), function(cj) {
    V <- variantes(getM(cj)); n <- nrow(getM(cj))
    vapply(names(V), function(v) ligne_md(cj, gen, v, format(n),
      paste(vapply(c("OK", "ALERTE", "ECHEC"), function(mo) cell_k(sum(V[[v]] == mo), n), ""), collapse = " | "),
      "\u2014", "\u2014"), "")
  }))
  lignes_g4a <- lignes_g4("mod\u00e8le ajust\u00e9 (flux de G1)", function(cj) MES_PIT[[cj]]$M)
  lignes_g4b <- lignes_g4("pente n\u00e9gative (volumes r\u00e9fl\u00e9chis)", function(cj) NEG_PIT[[cj]]$M)
  # Pente negative, P2 avec R4 (avis A5) : modalite_pitman() sur les R jeux,
  # R4 par reajustement ; n = reajustements reussis.
  lignes_g4p2 <- vapply(names(MES_PIT), function(cj) {
    P <- NEG_PIT[[cj]]$P2; n <- sum(!is.na(P)); cpt_m <- function(mo) cell_k(sum(P %in% mo), n)
    ligne_md(cj, "pente n\u00e9gative (volumes r\u00e9fl\u00e9chis)", "unilat\u00e9ral (moteur), P2 avec R4", format(n),
             cpt_m("OK"), cpt_m("ALERTE"), cpt_m("ECHEC"), cpt_m("diagnostic (R4)"),
             cpt_m(c("inop\u00e9rant (R1)", "non applicable")))
  }, "")
  # Signe de r (avis A4) : G1 et G4 pente negative, replications ou r < 0 et,
  # parmi elles, celles ou p < SEUIL_ECHEC_SENS_REJETER (verdict autre
  # qu'ECHEC sans R4).
  lignes_signe <- unlist(lapply(names(MES_PIT), function(cj) {
    vapply(list(list("mod\u00e8le ajust\u00e9 (G1)", MES_PIT[[cj]]$M), list("pente n\u00e9gative (G4)", NEG_PIT[[cj]]$M)),
           function(z) {
             M <- z[[2]]; neg <- M[, "r"] < 0
             ligne_md(cj, z[[1]], cell_k(sum(neg), nrow(M)),
                      cell_k(sum(M[neg, "p"] < SEUIL_ECHEC_SENS_REJETER), sum(neg)),
                      cell_k(sum(M[neg, "p"] < ALPHA_PIT), sum(neg)))
           }, "")
  }))
  lignes_g4c <- vapply(names(MES_PIT), function(cj) {
    rp <- MES_PIT[[cj]]$r_obs_enum
    ligne_md(cj, num(rp[1], 4), num(usp_permutation_pente(MES_PIT[[cj]]$J$x, MES_PIT[[cj]]$J$y)$p, 4),
             sprintf("%d / %d", sum(rp >= 0), length(rp)), num(mean(rp >= 0), 4))
  }, "")

  # Anciennes valeurs (#220, ADR 0002 amende le 06/10/2026, .tex) : dans le
  # nouvel IC ou non ; deterministes : egalite a l'arrondi publie.
  dans_ic <- function(v, k, n) { ci <- ic_cp(k, n); if (ci[1] <= v && v <= ci[2]) "oui" else "**non**" }
  anc <- function(v, src, lib, kn) ligne_md(num(v, 3), src, lib, cell_k(kn[1], kn[2]), dans_ic(v, kn[1], kn[2]))
  anc_det <- function(v, src, lib, val) ligne_md(num(v, 3), src, lib, num(val, 4),
    sprintf("valeur d\u00e9terministe ; arrondi au milli\u00e8me : %s", if (round(val, 3) == v) "\u00e9gal" else "**diff\u00e9rent**"))
  cpt <- function(mod, mo) c(sum(mod == mo, na.rm = TRUE), sum(!is.na(mod)))
  # Plages du .tex (l. 6177-6178, avis A2) : min-max des tailles de
  # permutation de G3 sur k dans {1 ; 2 ; 3}, scenario de chaque extreme, et
  # min-max sur les six scenarios autres que k = 0 ; sans verdict d'IC.
  plage <- function(v, cj) {
    tx <- vapply(SCEN_G3, function(sc) { M <- G3_PIT[[cj]][[sc]]$M; mean(M[, "p"] < ALPHA_PIT) }, numeric(1))
    lib <- stats::setNames(c(paste0("k = ", sub(".", ",", as.character(KS_G3), fixed = TRUE)), "marche al\u00e9atoire", "AR(1)"), SCEN_G3)
    mm <- function(sc) sprintf("%s (%s) \u00e0 %s (%s)", num(min(tx[sc]), 4), lib[sc][which.min(tx[sc])],
                               num(max(tx[sc]), 4), lib[sc][which.max(tx[sc])])
    ligne_md(v, ".tex (l. 6177-6178, CV(x) \u2248 10 % / 64 %)",
             sprintf("G3 %s, tailles de permutation (CV(x) = %s %%)", cj, num(100 * cv_x(MES_PIT[[cj]]$J$x), 2)),
             sprintf("k \u2208 {1 ; 2 ; 3} : %s ; six sc\u00e9narios hors k = 0 : %s", mm(c("k=1", "k=2", "k=3")),
                     mm(setdiff(SCEN_G3, "k=0"))),
             "rattachement pr\u00e9sum\u00e9, protocole perdu ; sans verdict d'IC")
  }
  lignes_anc <- if (!all(c("J1", "J2") %in% names(MES_PIT))) character(0) else {
    m1 <- MES_PIT$J1; m2 <- MES_PIT$J2
    v1 <- variantes(m1$M); n1 <- variantes(NEG_PIT$J1$M); n2 <- variantes(NEG_PIT$J2$M)
    g3 <- function(cj, sc) { M <- G3_PIT[[cj]][[sc]]$M; c(sum(M[, "p"] < ALPHA_PIT), nrow(M)) }
    pib1 <- usp_identifiabilite_pente(m1$J$x, m1$FIT0$beta, m1$FIT0$sigma, ALPHA_PIT,
                                      unilateral = .pitman_unilateral())$puissance
    src_tex <- ".tex (\u00ab environ 63/25/12 % \u00bb)"
    c(unlist(lapply(list(list(0.63, "OK"), list(0.25, "ALERTE"), list(0.12, "ECHEC")), function(z) c(
        anc(z[[1]], src_tex, sprintf("G1 J1, P1, %s", z[[2]]), cpt(m1$P1, z[[2]])),
        anc(z[[1]], src_tex, sprintf("G1 J1, P2, %s", z[[2]]), cpt(m1$P2, z[[2]])),
        anc(z[[1]], src_tex, sprintf("G1 J1, P2 conditionnel aux lignes \u00ab test \u00bb, %s", z[[2]]),
            cpt(m1$P2[m1$P2 %in% c("OK", "ALERTE", "ECHEC")], z[[2]]))))),
      anc(0.641, "ADR 0002, point 4", "G1 J1, P1, OK", cpt(m1$P1, "OK")),
      anc(0.116, "ADR 0002, point 4", "G1 J1, P1, ECHEC", cpt(m1$P1, "ECHEC")),
      anc(0.471, "ADR 0002, point 4 (ii)", "G4 J1, bilat\u00e9ral avec r\u00e8gle de signe, OK", cpt(v1[[3]], "OK")),
      anc(0.256, "ADR 0002, point 4 (ii)", "G4 J1, bilat\u00e9ral avec r\u00e8gle de signe, ECHEC", cpt(v1[[3]], "ECHEC")),
      anc(0.644, "#220 (puissance, Student)", "G2 J1, Student unilat\u00e9ral, p < 0,10",
          c(sum(m1$M[, "p_st"] < ALPHA_PIT, na.rm = TRUE), sum(is.finite(m1$M[, "p_st"])))),
      anc(0.641, "#220 (puissance, permutation)", "G2 J1, permutation, p < 0,10",
          c(sum(m1$M[, "p"] < ALPHA_PIT), nrow(m1$M))),
      anc_det(0.646, "#220 (\u03c0\u0302_b)", "G2 J1, \u03c0\u0302_b observ\u00e9", pib1),
      anc(0.092, "ADR 0002, point 5 (H0 i.i.d.)", "G3 J1, k = 0 (rattachement J1/J2 inconnu)", g3("J1", "k=0")),
      anc(0.092, "ADR 0002, point 5 (H0 i.i.d.)", "G3 J2, k = 0 (rattachement J1/J2 inconnu)", g3("J2", "k=0")),
      anc(0.093, "ADR 0002, point 5 (H0 i.i.d.)", "G3 J1, k = 0 (rattachement J1/J2 inconnu)", g3("J1", "k=0")),
      anc(0.093, "ADR 0002, point 5 (H0 i.i.d.)", "G3 J2, k = 0 (rattachement J1/J2 inconnu)", g3("J2", "k=0")),
      plage("0,095 \u00e0 0,106", "J1"), plage("0,20 \u00e0 0,27", "J2"),
      anc(0.095, "ADR 0002, point 5 (sd \u221d x, J1)", "G3 J1, k = 1", g3("J1", "k=1")),
      anc(0.272, "ADR 0002, point 5 (sd \u221d x\u00b3, J2)", "G3 J2, k = 3", g3("J2", "k=3")),
      anc(0.510, "ADR 0002, point 4 (i)", "G4 J1, pente n\u00e9gative, bilat\u00e9ral pur, OK", cpt(n1[[2]], "OK")),
      anc(0.997, "ADR 0002, point 4 (i)", "G4 J2, pente n\u00e9gative, bilat\u00e9ral pur, OK", cpt(n2[[2]], "OK")),
      anc(0.003, "ADR 0002, point 4 (i)", "G4 J1, pente n\u00e9gative, unilat\u00e9ral, OK", cpt(n1[[1]], "OK")),
      anc(0.000, "ADR 0002, point 4 (i)", "G4 J2, pente n\u00e9gative, unilat\u00e9ral, OK", cpt(n2[[1]], "OK")),
      anc_det(0.487, "ADR 0002, point 4", "G4 J1 observ\u00e9, P(r* \u2265 0) (\u00e9num\u00e9ration)", mean(m1$r_obs_enum >= 0)),
      anc_det(0.450, "ADR 0002, point 4", "G4 J2 observ\u00e9, P(r* \u2265 0) (\u00e9num\u00e9ration)", mean(m2$r_obs_enum >= 0)))
  }

  n_jeux <- length(MES_PIT)
  cout <- function(d, n) num(d / n, 4)
  section_pit <- c(
    "### C6 -- Test de Pitman sur la pente : verdicts, puissances, tailles sous des H0 faibles et variantes de sens, T = 8 (issue #220)", "",
    paste("Statut : **constats de simulation** (G1, G2, G4 : sous le mod\u00e8le r\u00e9glementaire ajust\u00e9 ou d\u00e9plac\u00e9 ;",
          "G3 : sous des hypoth\u00e8ses nulles faibles hors mod\u00e8le r\u00e9glementaire), non des r\u00e9sultats. p = p de",
          "permutation unilat\u00e9rale de usp_permutation_pente() (\u00e9num\u00e9ration des T! appariements, sens du moteur) ;",
          sprintf("\u03b1 = %s (d\u00e9faut de run_engine()) ; verdicts du sens \u00ab rejeter \u00bb : OK si p < \u03b1, ALERTE si",
                  num(ALPHA_PIT, 2)),
          sprintf("p < %s (SEUIL_ECHEC_SENS_REJETER), ECHEC sinon. R4 : diagnostic si la puissance unilat\u00e9rale approch\u00e9e",
                  num(SEUIL_ECHEC_SENS_REJETER, 2)),
          "de usp_identifiabilite_pente(x, \u03b2\u0302*, \u03c3\u0302*, \u03b1, unilateral = TRUE), aux param\u00e8tres du",
          "r\u00e9ajustement usp_ajuster(x, y*), est inf\u00e9rieure \u00e0 SEUIL_PUISSANCE_PENTE_R4 = 1/2. Les nouvelles valeurs",
          "remplacent les anciennes (C6.f dit seulement si chacune tombe dans le nouvel IC). Protocole dans l'en-t\u00eate",
          "du script. Le protocole d'origine (sp\u00e9cification du 06/10/2026) est introuvable : celui-ci le red\u00e9finit,",
          "sans pr\u00e9tendre le reproduire."), "",
    sprintf(paste("R\u00e9plications : G1, G2, G4 : %d par jeu ; G3 : %d par sc\u00e9nario et par jeu. Graines : jeux du",
                  "mod\u00e8le ajust\u00e9 %s (flux de #72 et #221, m\u00eame graine pour J1 et J2 ; les 2 000 premiers jeux",
                  "sont ceux de #221) ; G3 %s (\u03b5 h\u00e9t\u00e9rosc\u00e9dastiques), %s (marche al\u00e9atoire), %s (AR(1)) ;",
                  "G4 pente n\u00e9gative %s (m\u00eame graine pour J1 et J2)."),
            OPT_R, OPT_R_H0, format(OPT_GRAINE, scientific = FALSE), format(OPT_GRAINE + 11, scientific = FALSE),
            format(OPT_GRAINE + 12, scientific = FALSE), format(OPT_GRAINE + 13, scientific = FALSE),
            format(OPT_GRAINE + 14, scientific = FALSE)), "",
    "**C6.a -- G1 : modalit\u00e9s de la ligne Pitman sous le mod\u00e8le ajust\u00e9 (k / n ; taux [IC 95 % C-P])**", "",
    entete_md(c("Jeu", "Protocole", "n", MODALITES_PIT)),
    lignes_g1, "",
    paste("P1 : sans R4 (verdict de la p de permutation ; R1 et non-applicabilit\u00e9 appliqu\u00e9es, attendues nulles \u00e0",
          "T = 8). P2 : avec R4 sur le r\u00e9ajustement ; n = r\u00e9ajustements r\u00e9ussis. Ligne conditionnelle : parmi",
          "les lignes de P2 rest\u00e9es de type test."), "",
    "**C6.a bis -- G1 : r\u00e9ajustements de P2**", "",
    entete_md(c("Jeu", "R", "R\u00e9ajustements en \u00e9chec (exclus de P2)",
                "Refus de #188 (usp_valider_ajustement(), compt\u00e9s, non exclus)", "M\u00e9diane de \u03c0\u0302_b*")),
    lignes_g1_aj, "",
    lignes_refus, "",
    lignes_ref, "",
    "**C6.b -- G2 : puissances sous le mod\u00e8le ajust\u00e9, sans R4 (rejet si p < \u03b1)**", "",
    entete_md(c("Jeu", "CV(x) (%, \u00e9cart-type en T \u2212 1)", "\u03c0\u0302_b observ\u00e9 (approximation, d\u00e9terministe)",
                "Permutation (k / n ; taux [IC])", "Student unilat\u00e9ral, pt(t, T \u2212 2) (k / n ; taux [IC])")),
    lignes_g2, "",
    "**C6.c -- G3 : tailles sous des hypoth\u00e8ses nulles faibles, sans R4 (rejet si p < \u03b1)**", "",
    entete_md(c("Jeu", "CV(x) (%)", "Sc\u00e9nario", "Permutation (k / n ; taux [IC])",
                "Student unilat\u00e9ral (k / n ; taux [IC])", "R\u00e9f\u00e9rence")),
    lignes_g3, "",
    paste("Y_t = \u03bc + (x_t/x\u0304)^k \u03b5_t, \u03b5_t i.i.d. N(0, 1), m\u00eames \u03b5 pour tous les k et les deux jeux ;",
          "marche al\u00e9atoire Y_t = \u03bc + \u03a3_{s \u2264 t} e_s ; AR(1) stationnaire u_1 = e_1/\u221a(1 \u2212 \u03c1\u00b2) ;",
          "\u03bc = 0 (r invariant par transformation affine croissante de y : contr\u00f4le). k = 0 : H0 i.i.d.,",
          "\u00e9changeable ; la taille de la p d'\u00e9num\u00e9ration y vaut exactement 4031/40320 si les T! valeurs de r",
          "sont distinctes. Les autres sc\u00e9narios rompent l'\u00e9changeabilit\u00e9 sans lien de moyenne avec x."), "",
    "**C6.d -- G4 : variantes de sens, sans R4 sauf la ligne \u00ab P2 avec R4 \u00bb (k / n ; taux [IC])**", "",
    entete_md(c("Jeu", "G\u00e9n\u00e9rateur", "Variante", "n", "OK", "ALERTE", "ECHEC", "diagnostic (R4)",
                "inop\u00e9rant (R1) ou non applicable")),
    lignes_g4a, lignes_g4b, lignes_g4p2, "",
    paste("Bilat\u00e9ral pur : verdicts de la p bilat\u00e9rale de permutation (p_bilateral, |r|). Bilat\u00e9ral avec r\u00e8gle",
          "de signe : ECHEC si r < 0, verdict de p_bilateral sinon. Pente n\u00e9gative : jeux simul\u00e9s au mod\u00e8le ajust\u00e9",
          "d\u00e9plac\u00e9 aux volumes r\u00e9fl\u00e9chis x' = min x + max x \u2212 x (E[Y_t] = \u03b2x'_t, \u03c0' = usp_pi(\u03b4\u0302, \u03b3\u0302, x')),",
          "test de r(x, y*). Ligne \u00ab P2 avec R4 \u00bb : modalit\u00e9 de la ligne Pitman avec R4 sur le r\u00e9ajustement",
          "usp_ajuster(x, y*) de chaque jeu ; n = r\u00e9ajustements r\u00e9ussis."), "",
    "**C6.d bis -- Signe de r : r\u00e9plications o\u00f9 r < 0 et, parmi elles, p unilat\u00e9rale sous les seuils (sans R4)**", "",
    entete_md(c("Jeu", "G\u00e9n\u00e9rateur", "r < 0 (k / n ; taux [IC])",
                sprintf("parmi r < 0 : p < %s (SEUIL_ECHEC_SENS_REJETER), verdict autre qu'ECHEC", num(SEUIL_ECHEC_SENS_REJETER, 2)),
                sprintf("parmi r < 0 : p < \u03b1 = %s (OK)", num(ALPHA_PIT, 2)))),
    lignes_signe, "",
    "**C6.e -- G4 : P(r* \u2265 0) sous la loi de permutation des jeux observ\u00e9s (\u00e9num\u00e9ration, d\u00e9terministe)**", "",
    entete_md(c("Jeu", "r observ\u00e9", "p unilat\u00e9rale observ\u00e9e", "Appariements r* \u2265 0", "P(r* \u2265 0)")),
    lignes_g4c, "",
    "**C6.f -- Anciennes valeurs (non versionn\u00e9es) : dans le nouvel IC ?**", "",
    entete_md(c("Ancienne valeur", "Source", "Nouvelle grandeur", "Nouvelle valeur (k / n ; taux [IC])", "Dans l'IC")),
    lignes_anc, "",
    paste("Les anciennes valeurs ont leur propre erreur Monte-Carlo (R = 4 000 au point 4 de l'ADR 0002, R = 2 000 au",
          "point 5, inconnue pour le .tex) : un \u00ab non \u00bb n'\u00e9tablit pas une incompatibilit\u00e9."), "",
    paste0("Jeux : ", paste(vapply(MES_PIT, function(m) sprintf("%s : %s", m$J$code, m$J$libelle), ""), collapse = " ; "), "."),
    sprintf(paste("Dur\u00e9e de C6 : %.0f s de simulation (G1, G2 et variantes de G4 : %.0f s, soit %s s par r\u00e9plication",
                  "et par jeu, r\u00e9ajustement de R4 compris ; G4 pente n\u00e9gative, R4 compris : %.0f s, %s s ; G3 : %.0f s, %s s par",
                  "r\u00e9plication, par sc\u00e9nario et par jeu) et %.0f s de contr\u00f4les (dont run_engine())."),
            duree_pit, duree_g1, cout(duree_g1, OPT_R * n_jeux), duree_g4, cout(duree_g4, OPT_R * n_jeux),
            duree_g3, cout(duree_g3, OPT_R_H0 * n_jeux * length(SCEN_G3)),
            as.numeric(difftime(Sys.time(), t6, units = "secs")) - duree_pit), "")
  sortie <- c(sortie, section_pit)
  controles <- c(controles, ctrl_pit)
  FICHIERS_118$pitman <- list(section = section_pit, controles = ctrl_pit)
}

# --- C7 : niveau de la regle ESD (Rosner) a T = 8 (#174) ----------------------
# Protocole dans l'en-tete (C7). Partie executee seule (--partie esd), hors de
# --partie tout (duree du volet sous le modele ajuste). Toutes les quantites
# sont lues dans la sortie de test_rosner() du moteur (nb_outliers, R,
# lambda) : aucune copie de sa formule.
if (OPT_PARTIE == "esd") {
  ctrl_esd <- character(0)
  t7 <- Sys.time()
  rng_avant_esd <- list(RNGkind(), get0(".Random.seed", envir = globalenv(), inherits = FALSE))
  ALPHA_ESD_MOTEUR <- eval(formals(run_engine)$alpha)
  ALPHAS_ESD <- unique(c(ALPHA_ESD_MOTEUR, 0.05))
  LIGNE_ESD <- "Valeurs aberrantes multiples (ESD generalise)"
  # Une replication : pour chaque alpha, k chapeau (nb_outliers), depassement
  # de la premiere et de la seconde etape (R[i] > lambda[i]) ; R et lambda
  # finis (controle). k par defaut de test_rosner() : max(1, floor(T / 4)).
  esd_rep <- function(v) {
    unlist(lapply(ALPHAS_ESD, function(al) {
      ro <- test_rosner(v, alpha = al)
      c(k = ro$nb_outliers, e1 = ro$R[1] > ro$lambda[1], e2 = ro$R[2] > ro$lambda[2],
        nk = length(ro$R), fini = all(is.finite(c(ro$R, ro$lambda))))
    }))
  }
  noms_esd <- function(al) paste0(c("k", "e1", "e2", "nk", "fini"), "_", format(al))
  mat_esd <- function(L) {
    M <- t(vapply(L, esd_rep, numeric(5 * length(ALPHAS_ESD))))
    colnames(M) <- unlist(lapply(ALPHAS_ESD, noms_esd))
    M
  }

  # C7.a : echantillons i.i.d. N(0,1), un flux sous --graine + 7, tire en une
  # fois avant tout calcul, rempli par ligne (echantillon i = tirages
  # (i - 1) T + 1 a i T : les echantillons d'une execution a R plus petit sont
  # les premiers).
  t_iid <- Sys.time()
  Z_ESD <- engine_sous_graine(OPT_GRAINE + 7, matrix(stats::rnorm(OPT_R * T_), nrow = OPT_R, byrow = TRUE))
  M_IID <- mat_esd(lapply(seq_len(OPT_R), function(i) Z_ESD[i, ]))
  duree_iid <- as.numeric(difftime(Sys.time(), t_iid, units = "secs"))
  z1_isole <- engine_sous_graine(OPT_GRAINE + 7, stats::rnorm(T_))

  # C7.b : sous le modele ajuste a J1 et J2 (flux de #72, #166, #221), y*
  # reajuste par usp_ajuster(x, y*), test_rosner() sur les residus z du
  # reajustement (comme usp_tests()) ; reajustement en erreur ou z non finis
  # ecartes et comptes.
  t_mod <- Sys.time()
  JEUX_ESD <- lapply(jeux_tost(), function(J) J[c("code", "x", "y", "libelle")])
  MES_ESD <- lapply(JEUX_ESD, function(J) {
    x <- J$x
    if (length(x) != T_) stop("C7 : jeu ", J$code, " de longueur ", length(x), ", T = ", T_, " attendu")
    FIT0 <- usp_ajuster(x, J$y)
    # Flux de #72 a OPT_R_MODELE jeux (EXPR_YSIM_72 lit OPT_R).
    YSIM <- local({ OPT_R <- OPT_R_MODELE; eval(EXPR_YSIM_72) })
    fits <- lapply(seq_len(OPT_R_MODELE), function(b) tryCatch(usp_ajuster(x, YSIM[b, ]), error = function(e) NULL))
    ok <- vapply(fits, function(f) !is.null(f) && all(is.finite(f$z)), logical(1))
    M <- matrix(NA_real_, OPT_R_MODELE, 5L * length(ALPHAS_ESD), dimnames = list(NULL, unlist(lapply(ALPHAS_ESD, noms_esd))))
    if (any(ok)) M[ok, ] <- mat_esd(lapply(fits[ok], function(f) f$z))
    pi_cst <- vapply(fits, function(f) !is.null(f) && isTRUE(diff(range(f$pi)) <= 1e-12 * max(f$pi)), logical(1))
    list(J = J, FIT0 = FIT0, YSIM = YSIM, M = M, ok = ok, pi_cst = pi_cst,
         y1_isole = engine_sous_graine(OPT_GRAINE, usp_simuler(FIT0)))
  })
  names(MES_ESD) <- vapply(JEUX_ESD, `[[`, "", "code")
  duree_mod <- as.numeric(difftime(Sys.time(), t_mod, units = "secs"))
  duree_esd <- as.numeric(difftime(Sys.time(), t7, units = "secs"))

  # --- Controles d'integrite (bloquants) ---
  col <- function(nom, al) paste0(nom, "_", format(al))
  # Valeurs critiques (deterministes, lues dans test_rosner()) : colonne j =
  # ALPHAS_ESD[j], lignes lambda1 (n = 8) et lambda2 (n = 7).
  lam <- vapply(ALPHAS_ESD, function(al) test_rosner(Z_ESD[1, ], alpha = al)$lambda, numeric(2))
  # Premiere etape, resultat exact (voir l'en-tete) : la demonstration exige
  # 2 lambda1^2 > T - 1 (deux depassements simultanes impossibles).
  ctrl_esd <- c(ctrl_esd, controle(all(2 * lam[1, ]^2 > T_ - 1), sprintf(
    "C7, premi\u00e8re \u00e9tape exacte : 2\u03bb\u2081\u00b2 > T \u2212 1 = %d pour chaque \u03b1 (%s)", T_ - 1L,
    paste(sprintf("%s \u00e0 \u03b1 = %s", vapply(2 * lam[1, ]^2, num, "", d = 3), vapply(ALPHAS_ESD, num, "", d = 2)),
          collapse = " ; "))))
  # k par defaut = floor(T / 4) = 2 a T = 8 ; R et lambda finis.
  ctrl_esd <- c(ctrl_esd, controle(
    all(vapply(ALPHAS_ESD, function(al) all(M_IID[, col("nk", al)] == 2) && all(M_IID[, col("fini", al)] == 1), logical(1))) &&
      all(vapply(MES_ESD, function(m) all(vapply(ALPHAS_ESD, function(al) all(m$M[m$ok, col("nk", al)] == 2) &&
                                                   all(m$M[m$ok, col("fini", al)] == 1), logical(1))), logical(1))),
    "C7, k par d\u00e9faut de test_rosner() \u00e9gal \u00e0 2 = \u230aT/4\u230b \u00e0 T = 8 ; R et \u03bb finis (toutes les r\u00e9plications, C7.a et C7.b)"))
  # Identites de lecture : k chapeau >= 1 <=> etape 1 ou etape 2 depassee ;
  # k chapeau = 2 <=> etape 2 depassee (k = 2 : le plus grand i tel que
  # R[i] > lambda[i]).
  ident <- function(M) all(vapply(ALPHAS_ESD, function(al) {
    k <- M[, col("k", al)]; e1 <- M[, col("e1", al)] == 1; e2 <- M[, col("e2", al)] == 1
    identical(k >= 1, e1 | e2) && identical(k == 2, e2) && all(k %in% 0:2)
  }, logical(1)))
  ctrl_esd <- c(ctrl_esd, controle(ident(M_IID) && all(vapply(MES_ESD, function(m) ident(m$M[m$ok, , drop = FALSE]), logical(1))),
    "C7, identit\u00e9s de lecture sur toutes les r\u00e9plications : k\u0302 \u2265 1 \u21d4 (R\u2081 > \u03bb\u2081 ou R\u2082 > \u03bb\u2082) ; k\u0302 = 2 \u21d4 R\u2082 > \u03bb\u2082"))
  # Invariance affine (croissante et decroissante) de nb_outliers et de R sur
  # les 100 premiers echantillons i.i.d.
  inv_esd <- all(vapply(seq_len(min(100L, OPT_R)), function(i) {
    v <- Z_ESD[i, ]
    all(vapply(ALPHAS_ESD, function(al) {
      a <- test_rosner(v, alpha = al); b <- test_rosner(3 + 0.2 * v, alpha = al); c2 <- test_rosner(-5 - 7 * v, alpha = al)
      a$nb_outliers == b$nb_outliers && a$nb_outliers == c2$nb_outliers &&
        isTRUE(all.equal(a$R, b$R, tolerance = 1e-10)) && isTRUE(all.equal(a$R, c2$R, tolerance = 1e-10))
    }, logical(1)))
  }, logical(1)))
  ctrl_esd <- c(ctrl_esd, controle(inv_esd, sprintf(
    "C7, invariance de k\u0302 et de R par v \u2192 3 + 0,2 v et v \u2192 \u22125 \u2212 7 v (%d premiers \u00e9chantillons i.i.d.)",
    min(100L, OPT_R))))
  # Transcription contre run_engine() (alpha par defaut) : estimation et
  # verdict de la ligne ESD sur le jeu observe et le premier jeu simule de
  # chaque jeu, contre test_rosner(usp_ajuster(x, y)$z).
  verdict_esd <- function(k) if (k >= 2) "ECHEC" else if (k == 1) "ALERTE" else "OK"
  trans_esd <- all(vapply(MES_ESD, function(m) all(vapply(list(m$J$y, m$YSIM[1, ]), function(y) {
    tb <- engine_table_tests(run_engine(xt = m$J$x, yt = y, methode = "premium", segment = 1, annexe = "II",
                                        nature_donnees = "brutes", B = 99, seed = 20260831))
    l <- tb[tb$test == LIGNE_ESD, ]
    k <- test_rosner(usp_ajuster(m$J$x, y)$z, alpha = ALPHA_ESD_MOTEUR)$nb_outliers
    nrow(l) == 1L && identical(as.numeric(l$estimation), as.numeric(k)) && identical(l$verdict, verdict_esd(k))
  }, logical(1))), logical(1)))
  ctrl_esd <- c(ctrl_esd, controle(trans_esd, sprintf(paste(
    "C7, transcription contre run_engine() (\u03b1 = %s) : estimation et verdict de la ligne ESD \u00e9gaux \u00e0",
    "test_rosner(usp_ajuster(x, y)$z) sur J1 et J2 observ\u00e9s et sur le premier jeu simul\u00e9 de chacun"), num(ALPHA_ESD_MOTEUR, 2))))
  # A pi chapeau constant (J1 observe), R de test_rosner() identique sur les
  # residus z et sur les log-ratios (portee de C7.a).
  f1 <- MES_ESD[["J1"]]$FIT0
  ctrl_esd <- c(ctrl_esd, controle(
    isTRUE(diff(range(f1$pi)) <= 1e-12 * max(f1$pi)) &&
      isTRUE(all.equal(test_rosner(f1$z)$R, test_rosner(log(MES_ESD[["J1"]]$J$y / MES_ESD[["J1"]]$J$x))$R, tolerance = 1e-8)),
    "C7, J1 observ\u00e9 (\u03c0\u0302 constant) : R de test_rosner() identique sur les r\u00e9sidus z et sur les log-ratios"))
  # Flux : expression de #72 ; premier tirage identique a un tirage isole ;
  # generateur de l'appelant restaure.
  ctrl_esd <- c(ctrl_esd, controle(!is.null(expr_72_lue) && identical(deparse(expr_72_lue), deparse(EXPR_YSIM_72)),
    "C7, expression des jeux simul\u00e9s identique \u00e0 l'affectation de YSIM de tests/taux_franchissement_reperes.R (#72, flux de #166 et #221)"))
  ctrl_esd <- c(ctrl_esd, controle(identical(Z_ESD[1, ], z1_isole),
    sprintf("C7.a, premier \u00e9chantillon du flux (graine %s) identique \u00e0 un tirage isol\u00e9", format(OPT_GRAINE + 7, scientific = FALSE))))
  for (cj in names(MES_ESD))
    ctrl_esd <- c(ctrl_esd, controle(identical(MES_ESD[[cj]]$YSIM[1, ], MES_ESD[[cj]]$y1_isole),
      sprintf("C7.b %s, premier jeu du flux (graine %s) identique \u00e0 un tirage isol\u00e9", cj, format(OPT_GRAINE, scientific = FALSE))))
  # C7.c : mesure du 15/10/2026 (revue de pertinence des tests,
  # docs/revues/20261015-pertinence-tests-graphiques/mesures/bloc-4/sim.R,
  # commit e990a9f, section 2 : set.seed(20261015), matrice 1e5 x 8 remplie
  # par colonne, lignes 1 a 50 000, test_rosner(v, k = 2, alpha = 0.10)),
  # recalculee ici sous engine_sous_graine().
  GRAINE_1510 <- 20261015
  Z_1510 <- engine_sous_graine(GRAINE_1510, matrix(stats::rnorm(1e5 * 8), 1e5, 8))
  M_1510 <- t(vapply(seq_len(50000L), function(i) {
    ro <- test_rosner(Z_1510[i, ], k = 2, alpha = 0.10)
    c(k = ro$nb_outliers, e1 = ro$R[1] > ro$lambda[1])
  }, numeric(2)))
  rm(Z_1510)
  # Generateur : engine_sous_graine(g, .) equivaut a set.seed(g) d'une
  # session aux types par defaut de R (>= 3.6.0 : Mersenne-Twister,
  # Inversion, Rejection), egaux a ENGINE_RNG_KIND ; set.seed() est appele
  # dans engine_sous_graine() pour que l'etat de l'appelant soit restaure.
  gen_1510 <- identical(unname(ENGINE_RNG_KIND), c("Mersenne-Twister", "Inversion", "Rejection")) &&
    identical(engine_sous_graine(1, { set.seed(GRAINE_1510); stats::rnorm(16) }),
              engine_sous_graine(GRAINE_1510, stats::rnorm(16)))
  ctrl_esd <- c(ctrl_esd, controle(gen_1510, paste(
    "C7.c, g\u00e9n\u00e9rateur : ENGINE_RNG_KIND = types par d\u00e9faut de R, et engine_sous_graine(20261015, .)",
    "\u00e9gal \u00e0 set.seed(20261015) (16 premiers tirages)")))
  TAUX_1510 <- c(mean(M_1510[, "k"] >= 1), mean(M_1510[, "k"] == 2), mean(M_1510[, "e1"] == 1))
  REF_1510 <- c(0.1515, 0.0623, 0.0992)
  ctrl_esd <- c(ctrl_esd, controle(isTRUE(all(abs(round(TAUX_1510, 4) - REF_1510) < 1e-9)), sprintf(paste(
    "C7.c, mesure du 15/10/2026 recalcul\u00e9e : P(k\u0302 \u2265 1), P(k\u0302 = 2), premi\u00e8re \u00e9tape = %s (arrondis \u00e0",
    "4 d\u00e9cimales ; bloc-4.md \u00a7 4.4 : 0,1515 ; 0,0623 ; 0,0992)"),
    paste(vapply(TAUX_1510, num, "", d = 4), collapse = " ; "))))
  rng_apres_esd <- list(RNGkind(), get0(".Random.seed", envir = globalenv(), inherits = FALSE))
  ctrl_esd <- c(ctrl_esd, controle(identical(rng_avant_esd, rng_apres_esd),
    "C7, RNGkind() et .Random.seed de l'appelant restaur\u00e9s"))

  # --- Tableaux ---
  cell_esd <- function(ind) {
    n <- length(ind); k <- sum(ind); ci <- ic_cp(k, n)
    sprintf("%d / %d ; %s [%s ; %s]", k, n, num(k / n, 4), num(ci[1], 4), num(ci[2], 4))
  }
  LOI_IID <- "i.i.d. N(0, 1), T = 8"
  loi_mod <- function(cj) sprintf("mod\u00e8le ajust\u00e9 \u00e0 %s (usp_simuler()), z du r\u00e9ajustement usp_ajuster(x, y*)", cj)
  lignes_esd <- function(M, loi) unlist(lapply(ALPHAS_ESD, function(al) {
    k <- M[, col("k", al)]; e1 <- M[, col("e1", al)] == 1; e2 <- M[, col("e2", al)] == 1
    ligne_md(loi, num(al, 2), cell_esd(k >= 1), cell_esd(k == 2), cell_esd(k == 1), cell_esd(e1),
             cell_esd(e2 & !e1))
  }))
  cols_esd <- c("Loi simul\u00e9e", "\u03b1", "P(k\u0302 \u2265 1) : ALERTE ou ECHEC", "P(k\u0302 = 2) : ECHEC", "P(k\u0302 = 1) : ALERTE",
                "Premi\u00e8re \u00e9tape seule : P(R\u2081 > \u03bb\u2081)", "Seconde \u00e9tape seule d\u00e9passe : P(R\u2082 > \u03bb\u2082, R\u2081 \u2264 \u03bb\u2081)")
  lignes_lam <- vapply(seq_along(ALPHAS_ESD), function(j)
    ligne_md(num(ALPHAS_ESD[j], 2), num(lam[1, j], 4), num(lam[2, j], 4)), "")
  # C7.c : mesure du 15/10/2026 (recalculee, controlee) contre C7.a a
  # alpha = 0,10 ; IC a cinq decimales (une borne arrondie a quatre peut
  # masquer la position d'une estimation).
  cell5 <- function(ind) {
    n <- length(ind); k <- sum(ind); ci <- ic_cp(k, n)
    list(txt = sprintf("%d / %d ; %s [%s ; %s]", k, n, num(k / n, 4), num(ci[1], 5), num(ci[2], 5)), p = k / n, ci = ci)
  }
  dans <- function(x, ci) if (x >= ci[1] && x <= ci[2]) "oui" else "**non**"
  Q_1510 <- list(
    list(nom = "P(k\u0302 \u2265 1)", a = M_1510[, "k"] >= 1, b = M_IID[, col("k", 0.1)] >= 1),
    list(nom = "P(k\u0302 = 2)", a = M_1510[, "k"] == 2, b = M_IID[, col("k", 0.1)] == 2),
    list(nom = "premi\u00e8re \u00e9tape seule, P(R\u2081 > \u03bb\u2081)", a = M_1510[, "e1"] == 1, b = M_IID[, col("e1", 0.1)] == 1))
  # Comparaison des deux estimations par le test de deux proportions
  # independantes (flux distincts : graine 20261015 contre --graine + 7),
  # proportion commune en pool ; p bilaterale par la loi normale.
  z_2prop <- function(a, b) {
    n1 <- length(a); n2 <- length(b); pb <- (sum(a) + sum(b)) / (n1 + n2)
    (mean(a) - mean(b)) / sqrt(pb * (1 - pb) * (1 / n1 + 1 / n2))
  }
  ZC_1510 <- vapply(Q_1510, function(q) z_2prop(q$a, q$b), 0)
  P_1510 <- 2 * stats::pnorm(-abs(ZC_1510))
  lignes_pub <- vapply(seq_along(Q_1510), function(j) {
    q <- Q_1510[[j]]; a <- cell5(q$a); b <- cell5(q$b)
    ligne_md(q$nom, a$txt, b$txt, dans(b$p, a$ci), sub(".", ",", sprintf("%+.2f", ZC_1510[j]), fixed = TRUE),
             num(P_1510[j], 3))
  }, "")
  # Phrase de lecture, construite sur les valeurs calculees (ecart nominal :
  # p < 0,05 sans correction ; Bonferroni sur les trois comparaisons).
  ic_e1_1510 <- ic_cp(sum(Q_1510[[3]]$a), length(Q_1510[[3]]$a))
  nom_1510 <- c("P(k\u0302 \u2265 1)", "P(k\u0302 = 2)", "la premi\u00e8re \u00e9tape")
  nominaux <- which(P_1510 < 0.05)
  LECTURE_1510 <- paste0(
    "Lecture : ",
    if (all(pmin(1, 3 * P_1510) >= 0.05)) "aucun \u00e9cart \u00e9tabli entre la mesure du 15/10 et C7.a (Bonferroni sur trois comparaisons, niveau 5 %)" else
      "**\u00e9cart \u00e9tabli** apr\u00e8s Bonferroni sur trois comparaisons (niveau 5 %)",
    if (!length(nominaux)) " ; aucun \u00e9cart nominal (p \u2265 0,05 sur les trois grandeurs)" else
      paste0(" ; ", if (length(nominaux) == 1L) "le seul \u00e9cart nominal (p < 0,05 sans correction), sur " else "\u00e9carts nominaux (p < 0,05 sans correction) sur ",
             paste(vapply(nominaux, function(j) sprintf("%s (z \u2248 %s, p \u2248 %s, \u2248 %s apr\u00e8s Bonferroni)",
                                                        nom_1510[j], num(ZC_1510[j], 2), num(P_1510[j], 3), num(min(1, 3 * P_1510[j]), 2)), ""),
                   collapse = " ; "),
             if (all(pmin(1, 3 * P_1510[nominaux]) >= 0.05))
               (if (length(nominaux) == 1L) ", est compatible avec le hasard" else ", sont compatibles avec le hasard") else ""),
    sprintf(" ; l'IC du 15/10 pour la premi\u00e8re \u00e9tape [%s ; %s] %s la valeur exacte \u03b1 = 0,10.",
            num(ic_e1_1510[1], 5), num(ic_e1_1510[2], 5),
            if (0.10 >= ic_e1_1510[1] && 0.10 <= ic_e1_1510[2]) "contient" else "**ne contient pas**"))
  # Rapprochement avec #166 (docs/tableaux/20261008-issue166-calibration-J1.md
  # et -J2.md, commit 139031d, ligne ESD de la repartition des modalites :
  # OK / ALERTE / ECHEC sur les replications 1 a 2 000, run_engine() complet,
  # meme flux de jeux) : non bloquant (le moteur a evolue depuis).
  REF_166 <- list(J1 = c(OK = 1721, ALERTE = 172, ECHEC = 107), J2 = c(OK = 1778, ALERTE = 123, ECHEC = 99))
  lignes_166 <- vapply(names(MES_ESD), function(cj) {
    m <- MES_ESD[[cj]]
    if (OPT_R_MODELE < 2000L || OPT_GRAINE != 20260927)
      return(ligne_md(cj, paste(REF_166[[cj]], collapse = " / "), "\u2014",
                      "non comparable (R_modele < 2 000 ou graine \u2260 20260927)"))
    ok2 <- m$ok[1:2000]; k <- m$M[1:2000, col("k", ALPHA_ESD_MOTEUR)]
    nous <- c(OK = sum(k[ok2] == 0), ALERTE = sum(k[ok2] == 1), ECHEC = sum(k[ok2] == 2))
    ligne_md(cj, paste(REF_166[[cj]], collapse = " / "),
             sprintf("%s (\u00e9cart\u00e9s : %d)", paste(nous, collapse = " / "), sum(!ok2)),
             if (all(ok2) && identical(as.numeric(nous), as.numeric(REF_166[[cj]]))) "identique" else "**\u00e9cart**")
  }, "")
  lignes_mod_info <- vapply(names(MES_ESD), function(cj) {
    m <- MES_ESD[[cj]]
    sprintf("%s : r\u00e9ajustements \u00e9cart\u00e9s (erreur ou z non finis) %d / %d ; \u03c0\u0302 constant dans %d / %d r\u00e9ajustements retenus ; \u03b4\u0302 observ\u00e9 = %s.",
            cj, sum(!m$ok), OPT_R_MODELE, sum(m$pi_cst[m$ok]), sum(m$ok), num(m$FIT0$delta, 4))
  }, "")

  section_esd <- c(
    "### C7 -- Niveau de la r\u00e8gle ESD g\u00e9n\u00e9ralis\u00e9e (test_rosner()) \u00e0 T = 8", "",
    paste("Statut, trois cas. (1) C7.0 : valeurs **d\u00e9terministes** lues dans test_rosner(). (2) Premi\u00e8re \u00e9tape",
          "seule sous i.i.d. normal : niveau **exactement \u03b1** (r\u00e9sultat exact, d\u00e9monstration ci-dessous) ; la colonne",
          "simul\u00e9e \u00ab Premi\u00e8re \u00e9tape seule \u00bb de C7.a en est le contr\u00f4le. (3) Tout le reste (P(k\u0302 \u2265 1), P(k\u0302 = 2),",
          "P(k\u0302 = 1), seconde \u00e9tape ; C7.a et C7.b) : **constat de simulation**. C7.a : sous l'hypoth\u00e8se",
          "d'\u00e9chantillons i.i.d. N(0, 1) de taille 8 ; C7.b : sous le mod\u00e8le r\u00e9glementaire ajust\u00e9 \u00e0 J1 et \u00e0 J2.",
          "Toutes les quantit\u00e9s sont lues dans la",
          "sortie de test_rosner() du moteur (nb_outliers = k\u0302, R, \u03bb), sans copie de sa formule ; k = \u230aT/4\u230b = 2",
          "(d\u00e9faut de test_rosner()). Verdict de la ligne du moteur : ALERTE si k\u0302 = 1, ECHEC si k\u0302 = 2. Il n'y a",
          "pas de p-value : chaque taux est une fr\u00e9quence de d\u00e9cision, avec son IC de Clopper-Pearson \u00e0 95 %",
          "(erreur Monte-Carlo, fonction de R ; elle ne dit rien de l'erreur d'approximation en T)."), "",
    paste("Port\u00e9e de C7.a : C7.a est la fr\u00e9quence de d\u00e9cision de la r\u00e8gle sur huit observations i.i.d. normales.",
          "Elle co\u00efncide, r\u00e9plication par r\u00e9plication, avec la ligne du moteur lorsque \u03c0\u0302 est constant (z affine",
          "croissante des log-ratios). Elle n'est pas la fr\u00e9quence conditionnelle \u00e0 l'\u00e9v\u00e9nement \"\u03c0\u0302 constant\",",
          "qui d\u00e9pend des donn\u00e9es. \u00c0 \u03c0\u0302 variable, z n'est pas i.i.d. et C7.a ne s'applique pas."), "",
    sprintf(paste("R\u00e9plications : C7.a %d ; C7.b %d par jeu. Graines : C7.a %s ; C7.b %s (flux de #72, m\u00eame graine pour",
                  "J1 et J2 ; les 2 000 premiers jeux sont ceux de #166 et #221)."),
            OPT_R, OPT_R_MODELE, format(OPT_GRAINE + 7, scientific = FALSE), format(OPT_GRAINE, scientific = FALSE)), "",
    "**C7.0 -- Valeurs critiques de test_rosner() \u00e0 T = 8 (d\u00e9terministes)**", "",
    entete_md(c("\u03b1", "\u03bb\u2081 (n = 8)", "\u03bb\u2082 (n = 7, apr\u00e8s retrait du point le plus extr\u00eame)")), lignes_lam, "",
    "**C7.a -- Fr\u00e9quences de d\u00e9cision sous i.i.d. N(0, 1) (k / n ; taux [IC 95 % C-P])**", "",
    entete_md(cols_esd), lignes_esd(M_IID, LOI_IID), "",
    sprintf(paste("D\u00e9monstration (premi\u00e8re \u00e9tape seule, i.i.d. normal, n = T = 8, u_t = (x_t \u2212 x\u0304)/s ; r\u00e9sultat exact) :",
                  "(i) pour un indice t fix\u00e9, u \u21a6 u\u00b7\u221a(n(n \u2212 2)/((n \u2212 1)\u00b2 \u2212 n u\u00b2)) est strictement croissante sur",
                  "[0, (n \u2212 1)/\u221an), et l'image de |u_t| suit exactement la loi de |t(n \u2212 2)| sous i.i.d. normal (loi de",
                  "la fiche Grubbs) ; \u03bb\u2081 est l'image r\u00e9ciproque de t_{1 \u2212 \u03b1/(2n), n \u2212 2}, donc P(|u_t| > \u03bb\u2081) = \u03b1/n.",
                  "(ii) \u03a3 u_t\u00b2 = n \u2212 1 = 7 et 2\u03bb\u2081\u00b2 > 7 (%s ; contr\u00f4le bloquant) : deux d\u00e9passements simultan\u00e9s sont",
                  "impossibles. (iii) Les n \u00e9v\u00e9nements {|u_t| > \u03bb\u2081} sont donc disjoints et P(R\u2081 > \u03bb\u2081) = \u03b1 ; la colonne",
                  "simul\u00e9e \u00ab Premi\u00e8re \u00e9tape seule \u00bb en est le contr\u00f4le (non bloquant ; \u03b1 dans l'IC de la premi\u00e8re \u00e9tape : %s)."),
            paste(sprintf("%s \u00e0 \u03b1 = %s", vapply(2 * lam[1, ]^2, num, "", d = 3), vapply(ALPHAS_ESD, num, "", d = 2)),
                  collapse = " ; "),
            paste(vapply(ALPHAS_ESD, function(al) {
              ci <- ic_cp(sum(M_IID[, col("e1", al)] == 1), nrow(M_IID))
              sprintf("%s \u00e0 \u03b1 = %s", if (al >= ci[1] && al <= ci[2]) "oui" else "**non**", num(al, 2))
            }, ""), collapse = " ; ")), "",
    paste("Lecture : P(k\u0302 \u2265 1) = P(R\u2081 > \u03bb\u2081) + P(R\u2082 > \u03bb\u2082, R\u2081 \u2264 \u03bb\u2081) (identit\u00e9 contr\u00f4l\u00e9e r\u00e9plication par",
          "r\u00e9plication) : la derni\u00e8re colonne est la part de P(k\u0302 \u2265 1) que la seconde \u00e9tape (n = 7) ajoute \u00e0 la",
          "premi\u00e8re. La premi\u00e8re \u00e9tape seule est la r\u00e8gle \u00ab R\u2081 > \u03bb\u2081 \u00bb de test_rosner() (valeur critique \u00e0",
          "1 \u2212 \u03b1/(2n) de Student), non la ligne Grubbs du moteur (test_grubbs(), p-value \u00e0 borne de Bonferroni)."), "",
    "**C7.b -- Fr\u00e9quences de d\u00e9cision sous le mod\u00e8le ajust\u00e9 (k / n ; taux [IC 95 % C-P])**", "",
    entete_md(cols_esd),
    unlist(lapply(names(MES_ESD), function(cj) lignes_esd(MES_ESD[[cj]]$M[MES_ESD[[cj]]$ok, , drop = FALSE], loi_mod(cj)))), "",
    paste("-", lignes_mod_info), "",
    paste0("Jeux : ", paste(vapply(MES_ESD, function(m) sprintf("%s : %s", m$J$code, m$J$libelle), ""), collapse = " ; "), "."), "",
    "**C7.c -- Mesure du 15/10/2026 (i.i.d. N(0, 1), T = 8, k = 2, \u03b1 = 0,10), recalcul\u00e9e, contre C7.a (k / n ; taux [IC 95 % C-P])**", "",
    paste("Mesure du 15/10/2026 : revue de pertinence des tests,",
          "docs/revues/20261015-pertinence-tests-graphiques/mesures/bloc-4/sim.R (commit e990a9f), section 2 : set.seed(20261015), matrice 100 000 \u00d7 8 remplie par colonne,",
          "lignes 1 \u00e0 50 000, test_rosner(v, k = 2, alpha = 0.10) ; recalcul\u00e9e ici sous engine_sous_graine(20261015, .)",
          "(g\u00e9n\u00e9rateur \u00e9quivalent : contr\u00f4le), taux arrondis \u00e0 4 d\u00e9cimales \u00e9gaux \u00e0 ceux de bloc-4.md \u00a7 4.4 (contr\u00f4le",
          "bloquant). L'issue #174 (30/09/2026) cite une mesure ant\u00e9rieure, hors d\u00e9p\u00f4t et non versionn\u00e9e",
          "(P(k\u0302 \u2265 1) = 0,152 ; premi\u00e8re \u00e9tape 0,099), que la mesure du 15/10 a reproduite (0,1515 ; 0,0992,",
          "bloc-4.md \u00a7 4.4)."), "",
    entete_md(c("Grandeur", "Mesure du 15/10/2026 (R = 50 000)", sprintf("C7.a (R = %d)", OPT_R),
                "C7.a dans l'IC du 15/10", "z (15/10 \u2212 C7.a)", "p bilat\u00e9rale")),
    lignes_pub, "",
    paste("z : test de deux proportions ind\u00e9pendantes (flux distincts, proportion commune estim\u00e9e en pool),",
          "z = (p\u2081 \u2212 p\u2082) / \u221a(p\u0304 (1 \u2212 p\u0304) (1/n\u2081 + 1/n\u2082)) ; p bilat\u00e9rale = 2 (1 \u2212 \u03a6(|z|))",
          "(approximation normale)."), "",
    LECTURE_1510, "",
    "**C7.d -- Rapprochement avec #166 (ligne ESD, r\u00e9plications 1 \u00e0 2 000, run_engine() complet ; non bloquant)**", "",
    entete_md(c("Jeu", "OK / ALERTE / ECHEC de #166 (docs/tableaux/20261008-issue166-calibration-<jeu>.md, commit 139031d)",
                "OK / ALERTE / ECHEC de C7.b, r\u00e9plications 1 \u00e0 2 000", "R\u00e9sultat")),
    lignes_166, "",
    sprintf(paste("Dur\u00e9e de C7 : %.0f s de simulation (C7.a : %.0f s ; C7.b : %.0f s, soit %s s par r\u00e9plication et par",
                  "jeu, r\u00e9ajustement compris) et %.0f s de contr\u00f4les (dont run_engine())."),
            duree_esd, duree_iid, duree_mod, num(duree_mod / (OPT_R_MODELE * length(MES_ESD)), 4),
            as.numeric(difftime(Sys.time(), t7, units = "secs")) - duree_esd), "")
  sortie <- c(sortie, section_esd)
  controles <- c(controles, ctrl_esd)
  FICHIERS_118$esd <- list(section = section_esd, controles = ctrl_esd)
}

duree <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
sortie <- c(sortie, "### Contr\u00f4les d'int\u00e9grit\u00e9", "", paste("-", controles), "",
            sprintf("Dur\u00e9e totale : %.0f s.", duree))
ecrire_console(sortie)

# --- Fichiers de docs/tableaux/ (seulement sur --ecrire, issue #118) ----------
if (!is.na(OPT_ECRIRE) && !length(FICHIERS_118))
  message("--ecrire ignore : aucun fichier pour --partie ", OPT_PARTIE, " (seules tost, normalite, tost-frontiere, pitman et esd en ecrivent)")
if (!is.na(OPT_ECRIRE) && length(FICHIERS_118)) {
  # tous les chemins controles par la garde d'ecrasement (#173) avant toute
  # ecriture
  # Issue du fichier : #215 pour la partie tost depuis le modele auxiliaire
  # pondere (l'ancien tableau 20260930-issue118-tost.md est garde), #219 pour
  # la partie tost-frontiere, #220 pour la partie pitman, #174 pour la partie
  # esd, #118 sinon.
  CHEMINS_118 <- chemins_118(names(FICHIERS_118))
  if (!INTEGRITE) {
    message("--ecrire : controles d'integrite en echec, aucun fichier ecrit")
  } else {
    # Gardes reprises avant d'ecrire (#205) : commit du debut du calcul, et
    # commit courant (l'etat du depot a pu changer pendant le calcul).
    if (ECRIRE_VERSIONNABLE) {
      nv1 <- c(motifs_non_versionnable(COMMIT, "", "de l'ex\u00e9cution"),
               motifs_non_versionnable(commit_depot("tests/constats_puissance_t8.R"), "", "\u00e0 l'\u00e9criture"))
      if (length(nv1)) refus_non_versionnable(nv1)
    }
    REMPLACES <- garde_ecrasement(CHEMINS_118, OPT_REMPLACER, RACINE)
    for (nom in names(FICHIERS_118)) {
      f <- FICHIERS_118[[nom]]
      chemin <- CHEMINS_118[[nom]]
      lignes <- c(
        sprintf("## Constats de niveau et de puissance \u00e0 T = 8 (issue #%s)", ISSUE_118[[nom]]), "",
        paste0(sprintf("Param\u00e8tres : R=%d ; graine=%s ; partie=%s ; T=%s", OPT_R,
                       format(OPT_GRAINE, scientific = FALSE), nom, if (nom == "normalite") "5, 8, 10 et 20" else "8"),
               if (nom == "pitman") sprintf(" ; R_h0=%d", OPT_R_H0),
               if (nom == "esd") sprintf(" ; R_modele=%d", OPT_R_MODELE)), "",
        entete_md(c("Grandeur", "Valeur")),
        ligne_md("Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)", plateforme_calcul()),
        ligne_md("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
        ligne_md("Commit", COMMIT),
        ligne_md("Script", sprintf("tests/constats_puissance_t8.R --partie %s (hors CI ; protocole dans l'en-t\u00eate)", nom)),
        ligne_remplacement(REMPLACES, chemin), "",
        f$section, "### Contr\u00f4les d'int\u00e9grit\u00e9", "", paste("-", f$controles), "")
      con <- file(chemin, open = "wb")
      writeLines(enc2utf8(lignes), con, useBytes = TRUE)
      close(con)
      message("ecrit : ", chemin)
    }
  }
}
quit(status = if (INTEGRITE) 0L else 1L)
