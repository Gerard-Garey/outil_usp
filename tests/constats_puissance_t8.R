###############################################################################
#  tests/constats_puissance_t8.R  --  CONSTATS DE NIVEAU ET DE PUISSANCE A
#  T = 8 (issues #114, #118 et #219)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  Sortie en markdown sur la console (UTF-8). Il n'ecrit aucun fichier, sauf
#  sur demande explicite (option --ecrire DOSSIER, parties tost, normalite et
#  tost-frontiere seulement, voir "Usage"). R base + stats.
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
#          J1 (W, p de Royston, p par loi nulle, Z et p de D'Agostino ; W et Z
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
#
#  Alea : tout tirage passe par engine_sous_graine() avec une graine
#  explicite : innovations AR(1) sous --graine ; echantillons K0, K2, K3 sous
#  --graine + 1 ; jeux simules de K1 sous --graine + 2 ; jeux y* de C3 sous
#  --graine + 3 (J1) et --graine + 4 (J2) ; uniformes de C4 sous --graine + 5
#  (T = 8) et --graine + 6 (T = 20) ; C5 reprend les flux de C3 (--graine + 3
#  et + 4), sans flux propre ; chaque flux tire en une fois avant tout
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
#          [--graine 20260927] [--partie tout|ar1|ks|tost|normalite|tost-frontiere]
#          [--ecrire DOSSIER [--remplacer]]
#  --partie tout : C1 a C4 ; C5 seulement par --partie tost-frontiere.
#  --R vaut pour C1 (par rho), C3 (par jeu), C4 (par loi et par T) et C5
#  (par jeu et par valeur de a).
#  --ecrire DOSSIER : ecrit en plus, si les controles d'integrite tiennent,
#  DOSSIER/<AAAAMMJJ>-issue215-tost.md (issue118 avant #215),
#  <AAAAMMJJ>-issue118-normalite.md et/ou
#  <AAAAMMJJ>-issue219-tost-frontiere.md (date du jour),
#  pour les parties tost, normalite et tost-frontiere executees ; sans cette
#  option, rien n'est ecrit. Les fichiers versionnes de docs/tableaux/ se
#  produisent sur un arbre de travail propre (commit cite resoluble), par
#  --partie tost --ecrire docs/tableaux, --partie normalite --ecrire
#  docs/tableaux et --partie tost-frontiere --ecrire docs/tableaux. Garde d'ecrasement (#173, garde_ecrasement() de
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
#  C5 : 0,068 s par replication, par jeu et par valeur de a, plus environ
#  50 s de controles, mesure a R = 200 le 08/10/2026, soit environ 2,3 h
#  sur un coeur a R = 20 000 ; Linux, R 4.3.3).
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
if (!OPT_PARTIE %in% c("tout", "ar1", "ks", "tost", "normalite", "tost-frontiere"))
  stop("--partie : tout, ar1, ks, tost, normalite ou tost-frontiere")
if (OPT_REMPLACER && is.na(OPT_ECRIRE)) stop("--remplacer : reserve a --ecrire (remplacement d'un tableau suivi par git, #173)")
if (!is.na(OPT_ECRIRE) && !dir.exists(OPT_ECRIRE)) stop("--ecrire : dossier inexistant : ", OPT_ECRIRE)
if (!is.finite(OPT_R) || OPT_R < 1L) stop("--R : entier >= 1")
if (!is.finite(OPT_R_KS) || OPT_R_KS < 1L) stop("--R-ks : entier >= 1")
if (!is.finite(OPT_GRAINE)) stop("--graine : nombre")

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

# commit_depot() : tests/outils_tests.R (#205).

# Garde d'ecrasement anticipee (#205) : les chemins cibles de --ecrire ne
# dependent que des options (partie, dossier) et de la date ; controles ici,
# avant tout calcul (code 1, rien d'ecrit, si un fichier cible suivi par git
# n'est pas a remplacer), puis de nouveau avant l'ecriture (le depot peut
# changer pendant le calcul ; date de l'ecriture, qui peut differer de
# celle-ci si l'execution passe minuit). Seule source des chemins :
# chemins_118().
ISSUE_118 <- c(tost = "215", normalite = "118", "tost-frontiere" = "219")
chemins_118 <- function(parties) stats::setNames(
  file.path(OPT_ECRIRE, sprintf("%s-issue%s-%s.md", format(Sys.Date(), "%Y%m%d"), ISSUE_118[parties], parties)),
  parties)
PARTIES_118 <- c(if (OPT_PARTIE %in% c("tout", "tost")) "tost", if (OPT_PARTIE %in% c("tout", "normalite")) "normalite",
                 if (OPT_PARTIE == "tost-frontiere") "tost-frontiere")
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
                       "tost-frontiere" = "issue #219", "issues #114 et #118")
sortie <- c(
  sprintf("## Constats de niveau et de puissance \u00e0 T = 8 (%s)", TITRE_ISSUES), "",
  sprintf("Param\u00e8tres : R=%d ; R_ks=%d ; graine=%s ; partie=%s ; T=%d", OPT_R, OPT_R_KS,
          format(OPT_GRAINE, scientific = FALSE), OPT_PARTIE, T_), "",
  entete_md(c("Grandeur", "Valeur")),
  ligne_md("Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)", plateforme_calcul()),
  ligne_md("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
  ligne_md("Commit", commit_depot("tests/constats_puissance_t8.R")),
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
  l_swn <- ligne("Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston)")
  l_ds  <- ligne("Asymetrie (D'Agostino, T >= 8)")
  fit1 <- usp_ajuster(.ln$xt, .ln$yt)
  m_z <- mesurer_normalite(fit1$z)
  m_lr <- mesurer_normalite(log(.ln$yt / .ln$xt))
  trans_ok <- nrow(l_sw) == 1L && nrow(l_swn) == 1L && nrow(l_ds) == 1L &&
    isTRUE(diff(range(fit1$pi)) <= 1e-12 * max(fit1$pi)) &&
    isTRUE(all.equal(c(l_sw$statistique, l_sw$p_asymptotique, l_swn$p_exacte,
                       l_ds$statistique, l_ds$p_asymptotique),
                     unname(m_z[c("W", "p_royston", "p_nulle", "Z", "p_dago")]), tolerance = 1e-10)) &&
    isTRUE(all.equal(m_z[c("W", "Z")], m_lr[c("W", "Z")], tolerance = 1e-8))
  ctrl_norm <- c(ctrl_norm, controle(trans_ok, paste(
    "C4, transcription contre run_engine() sur J1 (W, p de Royston, p par loi nulle, Z et p de",
    "D'Agostino ; \u03c0\u0302 constant ; W et Z des r\u00e9sidus z \u00e9gaux \u00e0 ceux des log-ratios)")))
  ctrl_norm <- c(ctrl_norm, controle(
    all(vapply(MES8, function(M) all(is.finite(M)), logical(1))) &&
      all(vapply(MES20, function(p) all(is.finite(p)), logical(1))),
    "C4, aucune statistique ni p-value manquante (T = 8 et T = 20)"))

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
                  "r\u00e9duit ; la transcription de sw_p_loi_nulle() est contr\u00f4l\u00e9e contre run_engine() (contr\u00f4les d'int\u00e9grit\u00e9)."),
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
      # statut : ok, refus (#188), erreur (usp_ajuster()), ynonpos (y* <= 0)
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
      maj <- function(al) if (na == "zero") "—" else majorant_fr(sum(p[f] < al), sum(f), e, al)
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

duree <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
sortie <- c(sortie, "### Contr\u00f4les d'int\u00e9grit\u00e9", "", paste("-", controles), "",
            sprintf("Dur\u00e9e totale : %.0f s.", duree))
ecrire_console(sortie)

# --- Fichiers de docs/tableaux/ (seulement sur --ecrire, issue #118) ----------
if (!is.na(OPT_ECRIRE) && !length(FICHIERS_118))
  message("--ecrire ignore : aucun fichier pour --partie ", OPT_PARTIE, " (seules tost, normalite et tost-frontiere en ecrivent)")
if (!is.na(OPT_ECRIRE) && length(FICHIERS_118)) {
  # tous les chemins controles par la garde d'ecrasement (#173) avant toute
  # ecriture
  # Issue du fichier : #215 pour la partie tost depuis le modele auxiliaire
  # pondere (l'ancien tableau 20260930-issue118-tost.md est garde), #219 pour
  # la partie tost-frontiere, #118 sinon.
  CHEMINS_118 <- chemins_118(names(FICHIERS_118))
  if (!INTEGRITE) {
    message("--ecrire : controles d'integrite en echec, aucun fichier ecrit")
  } else {
    REMPLACES <- garde_ecrasement(CHEMINS_118, OPT_REMPLACER, RACINE)
    for (nom in names(FICHIERS_118)) {
      f <- FICHIERS_118[[nom]]
      chemin <- CHEMINS_118[[nom]]
      lignes <- c(
        sprintf("## Constats de niveau et de puissance \u00e0 T = 8 (issue #%s)", ISSUE_118[[nom]]), "",
        sprintf("Param\u00e8tres : R=%d ; graine=%s ; partie=%s ; T=%s", OPT_R,
                format(OPT_GRAINE, scientific = FALSE), nom, if (nom == "normalite") "8 et 20" else "8"), "",
        entete_md(c("Grandeur", "Valeur")),
        ligne_md("Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)", plateforme_calcul()),
        ligne_md("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
        ligne_md("Commit", commit_depot("tests/constats_puissance_t8.R")),
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
