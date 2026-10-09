###############################################################################
#  tests/grille_regime_t8.R  --  GRILLE SEMI-ANALYTIQUE DE LA MESURE DE LA
#  P-VALUE MONTE-CARLO CONDITIONNELLE AU REGIME DE DELTA CHAPEAU, A T = 8
#  (issue #229, etape 4)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils, tools et parallel, livres avec R :
#  utils::sessionInfo(), tools::md5sum(), parallel::mclapply()). Il ne modifie
#  ni R/engine.R ni tests/reference/. Sortie en markdown sur la console
#  (UTF-8) ; fichiers ecrits SEULEMENT sur option explicite (--ecrire,
#  --sortie).
#
#  Protocole : specification d'actuary
#  docs/specifications/229-p-conditionnelle-regime.md, approuvee par le
#  mainteneur au point d'arret A1 (annotation du 09/10/2026) : paragraphe 4
#  (definition, validation (g1) a (g5), sorties, regle A2), paragraphe 1
#  (regimes, familles F_T, F_R, F_8), paragraphe 2 (conditions C1 a C4, dont
#  la grille donne la PREDICTION), paragraphe 3 (jeux J1, J2, J3 et graines),
#  paragraphe 6 (scenarios de la partie P), paragraphe 9 (couts). Le texte
#  des paragraphes 2.1 et 2.2 (critere) et 4.4 (regle A2) est reporte sans
#  modification dans TEXTE_CRITERE_229 et TEXTE_REGLE_A2 ; le controle (t)
#  verifie qu'il figure tel quel dans la specification versionnee. Les
#  points que les par. 2 et 4 laissent ouverts sont lus selon l'annotation
#  d'actuary "Annotation du 9 octobre 2026 : lecture des points ouverts de la
#  grille" (L0 a L14, fin de la specification), qui fait foi ; le controle
#  (t) verifie la presence de sa ligne-titre.
#
#  Statut des valeurs : PREDICTION SEMI-ANALYTIQUE, pas une mesure. Elle
#  repose sur l'approximation de la consultation (specification, par. 4.1,
#  [NV]) : a petit sigma, la nuisance effective de la loi bootstrap est delta
#  seul ; la loi de reference d'une replication b est donc lue dans une grille
#  en delta a gamma fixe (gamma_ref du jeu), au lieu d'etre simulee sous
#  fit*_b. La grille ne prend pas la decision A2 : elle tabule chaque
#  condition predite, sa marge e* et la classe "echec franc / pas d'echec
#  franc" (par. 4.4), et la ligne correspondante de la table de
#  recommandations, SANS CONCLURE (decision du mainteneur).
#
#  Definition (specification, par. 4.1) :
#    - couche de reference, par profil de volumes p (1 : x de J1 ; 2 : x de
#      J2 ; 3 : x3 de J3) et par noeud delta_i (NOEUDS : 0 ; 0,05 ; 0,15 ;
#      ... ; 0,95 ; 1) : M jeux simules par usp_simuler() sous (beta_ref,
#      gamma_ref, delta_i), flux unique sous engine_sous_graine(20820000 +
#      100 p + i) (matrice M x 8 tiree d'abord, ligne par ligne, avant tout
#      calcul) ; reajustement usp_ajuster_rapide(x, y, delta_i, gamma_ref)
#      (celui du bootstrap) ; regime ; 34 statistiques par
#      .stats_bootstrapables() (celles du bootstrap). Un reajustement ou une
#      evaluation en erreur ecarte le tirage (compte) ; une statistique non
#      finie est ignoree pour cette statistique seule (comme engine_p_mc()).
#      On en tire, par noeud, la loi marginale F_delta, les lois par regime
#      F_delta|r et q_delta(r) = P(r | delta) ;
#    - couche "verite", par jeu : les R premieres lignes de l'expression YSIM
#      de #72 (flux unique sous 20260927, sous le modele FIT0 du jeu ; J3 :
#      FIT0_J3 synthetique du par. 3.2), soit les jeux de #221, #175 et de
#      l'etape 6 ; ajustement usp_ajuster() et refus de #188
#      (usp_valider_ajustement()), comme run_engine() ; delta*_b, r_b et
#      S_obs,b (34 statistiques, .mc_evaluer() sur le contexte observe) ;
#    - queues interpolees : hi = P(S >= S_obs) et lo = P(S <= S_obs),
#      queues empiriques de la loi du noeud ; interpolation lineaire en delta
#      entre les deux noeuds encadrants (delta*_b interieur), noeud exact aux
#      bords. Loi marginale : poids w_k ; loi conditionnelle au regime r_b :
#      poids w_k q_k(r_b) (annotation, L7 : loi conditionnelle de
#      l'interpolee de la loi jointe de (S, r)) ; poids tous nuls : absente ;
#    - p tildes, a B infini (par. 4.1) : sens de rejet lu au catalogue
#      ("haut" : hi ; "bas" : lo ; "deux" : min(1, 2 min(hi, lo))), limite
#      B -> infini de engine_p_mc() ; p1 tilde (marginale), p3 tilde
#      (conditionnelle). Elles servent a T1 et T1 bis a B infini, a (g2), au
#      McNemar au point et aux valeurs brutes ;
#    - probabilite de rejet a B fini (annotation, L4), grandeur de toute
#      comparaison a une mesure ou a une reference ((g1), (g3), C1 a C4, C4c,
#      ligne des intensites) : pi = P(p_mc < alpha | hi, lo), K suivant une
#      Binomiale(B, queue) ; "haut" P(K_hi <= k1), "bas" P(K_lo <= k1),
#      "deux" P(K_hi <= k2) + P(K_lo <= k2) ; k1, k2 plus grands k tels que
#      (1 + k)/(B + 1) < alpha et 2 (1 + k)/(B + 1) < alpha, par enumeration
#      de l'expression de engine_p_mc() (k_seuils()). B : 999 pour V1,
#      arrondi(999 q chapeau) pour V3a, min(999, arrondi(25 000 q chapeau))
#      pour V3b, V3h comme V3b a l'interieur et comme V1 aux bords ; p
#      absente (pi = 0, non-rejet) si ce B est inferieur a
#      B_MIN_DEGENERESCENCE (50) ou si les queues manquent ;
#    - q chapeau_b = q_delta*_b(r_b), interpole lineairement ; tirages de V3b
#      min(999 / q chapeau, 25 000) ;
#    - couche des alternatives : jeux des six scenarios de P (par. 6), sur
#      le modele ajuste de J2, R_P = 1 000 par scenario, flux sous
#      engine_sous_graine(20810000 + s) ; queues lues dans la couche de
#      reference du profil J2. Les matrices sont TOUJOURS tirees a R_P = 1 000
#      complet (annotation, L8), quel que soit --R-P, qui en prend les
#      premieres lignes ; le T0 cite le md5 des tirages bruts epsilon (avant
#      la transformation chi2 de A), des t* (C) et des jeux Y (valeurs en
#      %.17g, une par ligne, matrice lue ligne par ligne). ORDRE DES TIRAGES dans chaque flux (fixe ici,
#      a reprendre a l'identique par le script de l'etape 5) : d'abord la
#      matrice des epsilon, R_P x 8, remplie ligne par ligne (replication b :
#      tirages 8 (b - 1) + 1 a 8 b) ; rnorm() pour H et C, rchisq(nu) pour A ;
#      puis, pour C seulement, le vecteur des t* : sample.int(8, R_P,
#      replace = TRUE). Modeles (ln Y_t = mu_t + s_t epsilon_t ; x, beta,
#      gamma et pi_t de l'ajustement de J2) :
#        H (k) : CV_t = exp(gamma) (x_t / moyenne(x))^((k - 2) / 2),
#                s_t^2 = ln(1 + CV_t^2), mu_t = ln(beta x_t) - s_t^2 / 2 ;
#        C (lambda) : mu_t = ln(beta x_t) - 1 / (2 pi_t), s_t = 1 / sqrt(pi_t)
#                (modele ajuste) ; ln Y_t* augmente de lambda / sqrt(pi_t*) ;
#        A (nu) : meme mu_t et s_t, epsilon = (chi2_nu - nu) / sqrt(2 nu).
#
#  Validation (specification, par. 4.2), avant toute prediction :
#    (g1) ecarts predit - mesure : 102 cellules de T1 bis de #221 par jeu et
#         par seuil (34 statistiques x 3 regimes, J1 et J2), 34 cellules de T1
#         par jeu et par seuil, cellules V1 et V3a de #175 (J2 : 13 cellules ;
#         J1 : bord 0, et l'interieur a titre descriptif), aux deux seuils.
#         Taux mesures recalcules depuis les valeurs brutes de #221 (p_mc,
#         taux sur les p definies, comme T1 et T1 bis de #221) et de #175
#         (p1, p3, taux sur les rejouees, p absente = non-rejet), sur les
#         memes replications 1..R ; taux predits : moyenne de pi (L4) de V1
#         (B = 999) ou de V3a (B = arrondi(999 q chapeau)) sur les memes
#         replications ;
#    (g2) concordance appariee des decisions a B infini, p1 tilde contre p_mc
#         de #221 et decision predite de V3a contre p3 de #175 ;
#    (g3) marge e*_{j,alpha} (annotation, L5) = ecart absolu maximal de (g1)
#         sur les cellules EVALUABLES (n >= 100), hors cellules descriptives
#         de #175 : c'est elle qui FAIT FOI pour A2 (E_STAR). Le maximum
#         litteral sur toutes les cellules (E_STAR_LIT, n < 100 compris) est
#         rapporte a cote. J3 et les scenarios reprennent la marge de J2 ;
#    (g4) regimes de J3 sur la couche verite, IC de Clopper-Pearson ;
#    (g5) empreinte sans commentaires de R/engine.R (#231,
#         empreinte_sans_commentaires() de tests/outils_tests.R) et md5 du
#         fichier entier, cites (ils doivent etre ceux de l'etape 6).
#
#  Conditions predites (par. 2.2), lues selon l'annotation du 09/10/2026 :
#    - au point (L0) : texte du par. 2.2 applique aux taux predits pi, avec
#      l'IC de Clopper-Pearson des comptes predits k = arrondi(n pi) ;
#    - echec franc (par. 4.4, L0, L1) : defaut au point ET defaut quand chaque
#      grandeur predite (taux, ou difference de taux apparies comptee comme
#      une seule grandeur) est deplacee de e* dans le sens favorable a la
#      variante, sans IC, pour tout etat plausible de V1 (sans distorsion si
#      ref/2 - e* <= t1 <= 3 ref/2 + e* ; conservateur si t1 < ref/2 + e* ;
#      liberal si t1 > 3 ref/2 - e*).
#  Bande de Bradley [ref/2 ; 3 ref/2] ; ref = alpha pour une statistique
#  continue, taille lissee a B = 999 de #166 pour une loi discrete (lue dans
#  le T0 des tableaux de #221). Bande non applicable si ref < 2/n (regle de
#  #166, L6) : la cellule n'entre pas en defaut de C1a ni de C2b (listee).
#    C1a, C2b (regles (a) et (b) de #175) : au point, cote de l'IC de V1 et
#         de l'IC de la variante ; en defaut si V1 sans distorsion et
#         variante disjointe, ou V1 disjointe d'un cote et variante disjointe
#         du cote oppose ou de taux au-dela de l'IC de V1 de ce cote. C2b par
#         cellule (jeu, regime) evaluable. Pour V3a, statistiques a loi
#         discrete (LOI_STAT) descriptives, exclues et listees (L13).
#    C1b : au point, McNemar au point significatif apres Holm (22 de F_R),
#         n01 > n10 et borne basse de l'IC de tau_v > alpha (alpha a la
#         lettre, L9) ; franc : de plus tau_v - alpha > e*, tau_v - tau_V1 > e*
#         et McNemar significatif sous les deux lectures (L10).
#    C1c : descriptif (McNemar au point, n10 > n01, borne haute < alpha).
#    C2a : J2 et J3 interieur, alpha = 0,10, F_8 ; au point, nombre de
#         statistiques a IC de V1 disjoint et IC de la variante non disjoint
#         >= 5 (J3 : min(5, m3), m3 = nombre a IC de V1 disjoint) ; franc (L1)
#         : J2, |P inter V| < 5 ; J3, |P inter V| < min(5, |R union (P inter
#         V)|), condition vide (jamais franche) si R union (P inter V) est
#         vide ; R : V1 hors bande de plus de e* ; P : V1 peut-etre hors bande
#         (t1 < ref/2 + e* ou > 3 ref/2 - e*) ; V : variante a moins de e* de
#         la bande.
#    C3 : part des replications (J1 aux bords, J2, J3) ou la p de la variante
#         est predite absente pour au moins une statistique de F_R alors que
#         celle de V1 existe ; en defaut si > 1 % ; franc si > 1 % + e*, e*
#         etant le plus grand des deux seuils du jeu (L1).
#    C4a : par scenario et seuil, McNemar au point (22 de F_R, Holm)
#         significatif avec n10 > n01 ; franc : de plus significatif sous la
#         lecture d'independance (L10) et perte pi_V1 - pi_v > e*.
#    C4b : a delta* interieur, alpha = 0,10, Holm sur la cible du scenario :
#         remplie si une statistique cible d'un scenario a un McNemar n01 >
#         n10 significatif sous les deux lectures ("decelable", L10) ; franc
#         si de plus le gain predit est inferieur a -e* pour toutes les
#         cibles de tous les scenarios.
#    McNemar predit (L10) : test binomial exact bilateral de parametre 1/2 ;
#    au point, sur les decisions a B infini appariees ; lecture robuste, sur
#    les comptes attendus sous independance des erreurs Monte-Carlo,
#    n01 = arrondi somme pi_v (1 - pi_V1), n10 = arrondi somme pi_V1 (1 - pi_v).
#    Cellule evaluable si n >= 100 (par. 2.1) ; sinon "non evaluable".
#    e* indisponible (aucune cellule evaluable dans (g1), --R reduit) : les
#    conditions qui en dependent sont "non evaluables".
#  Regle A2 (L2, L3, L14) : ligne "(g1) hors tolerance" prioritaire ; ligne
#  d'arret "C2 en echec franc (J2 ou J3 interieur)" (C2a, ou C2b aux cellules
#  interieures de J2 et J3) declenchee pour V3b et V3h, et pour V3a seule
#  rapportee comme profil D4 de V3a (la mesure se poursuit) ; echec franc de
#  C2b aux bords rapporte comme "D4 predit pour <variante> ; V3h non
#  concernee", sans declencher l'arret ; autres lignes cumulees ; "C1 seule"
#  sans autre echec franc pour la meme variante ; "C4 remplie avec une marge
#  > 2 e*" a la lettre (C4a et C4b remplies au point, C4b decelable, perte
#  < -2 e* pour toute statistique de F_R, tout scenario et tout seuil, gain
#  > 2 e* a l'interieur pour au moins une cible), avec la perte maximale et
#  le gain maximal affiches ; ligne des intensites par scenario, alpha =
#  0,10, toutes replications, pi de V1.
#
#  Controles d'integrite (code de sortie 1 si l'un echoue ; --ecrire refuse) :
#    (b)  34 statistiques au catalogue USP_CATALOGUE_MC ; F_T et F_R en
#         partition des 34 ; F_8 et les ensembles cibles dans F_R ;
#    (c)  jeux de J1 et J2 identiques (identical()) a ceux de l'expression
#         YSIM de #72 (tests/taux_franchissement_reperes.R, lue par parse(),
#         liste blanche de noms, environnement isole, comme
#         tests/conservatisme_interieur_t8.R) ; regime de delta*_b identique
#         a celui des valeurs brutes de #221 et a celui des valeurs brutes de
#         #175 sur les replications communes ; delta*_b a la tolerance
#         TOLERANCE (1e-6) de comparer_objets() de celui de #175, ecart
#         maximal rapporte (l'ajustement depend de la plateforme) ;
#    (s)  sources de #221 et #175 lisibles ; comptes (n, k) de T1 bis de #221
#         recalcules depuis ses valeurs brutes egaux a ceux de son tableau ;
#         tailles lissees des lois discretes identiques dans les tableaux de
#         J1 et J2 ; pi (L4) sur la loi mahonienne exacte (T = 8,
#         .mk_loi_exacte()) egale aux tailles lissee (B = 999) et atteignable
#         (B infini) de Mann-Kendall du T0 de #221, a 1e-5 pres ;
#    (m)  modeles : gamma_ref de J1 et J2 a 5e-6 des valeurs de la
#         specification (-1,93433 ; -2,31999) ; J3 : x3, delta0, beta0,
#         sigma0 = 0,10 ;
#    (t)  textes du critere et de la regle A2 identiques a la specification ;
#         ligne-titre de l'annotation du 09/10/2026 (L0 a L14) presente ;
#    (graines) aucune collision non declaree entre les graines du script et
#         celles de la mesure (bootstrap 20260831 + b, flux de V3b
#         20800000 + b, b <= 2 000 ; SEED_LOI_NULLE_SW) ; collisions heritees
#         declarees (replications 96 et 70) ; aucune graine litterale de
#         R/engine.R, tests/*.R ou tests/unitaires/*.R dans les plages de
#         #229 (recherche des litteraux, non exhaustive pour les graines
#         calculees) ;
#    (d)  invariants : tirages retenus + ecartes = M a chaque noeud ; somme
#         des q_delta(r) = 1 ; aucune tache parallele en erreur.
#
#  Alea : tout tirage passe par engine_sous_graine() (generateur
#  ENGINE_RNG_KIND), sous les graines de la specification (par. 3) :
#  jeux de J1, J2 et J3 sous 20260927 ; noeud i du profil p sous
#  20820000 + 100 p + i ; scenario s sous 20810000 + s. Chaque tache
#  parallele (noeud, paquet de replications) tire sous sa graine ou relit des
#  jeux tires avant la parallelisation : les resultats ne dependent pas du
#  nombre de coeurs (verifie sur le test de fumee : sorties identiques a 1 et
#  4 coeurs, durees exceptees).
#
#  Parallelisation : parallel::mclapply() (fork ; --coeurs N, 1 par defaut),
#  plutot que des tranches et --combiner : l'execution complete est courte
#  (de l'ordre d'une demi-heure de CPU, mesure du test de fumee), elle
#  ecrit directement ses sorties (specification, par. 4.3 et regle 7 de la
#  branche de sauvegarde), et les taches sont deterministes par graine.
#  Sous Windows (pas de fork), --coeurs doit valoir 1.
#
#  Usage (depuis la racine du depot, de preference dans un git worktree au
#  commit propre cite) :
#      LC_ALL=C.UTF-8 Rscript tests/grille_regime_t8.R [--coeurs 4]
#          [--ecrire [--remplacer] | --sortie DOSSIER] [--brut FICHIER]
#  Parametres reduits (test de fumee seulement ; --ecrire les refuse) :
#      --M m (tirages par noeud, 3 000), --R r (replications de la couche
#      verite par jeu, 2 000), --R-P r (replications par scenario, 1 000).
#  Sorties (date du jour) : --ecrire ecrit le tableau
#  docs/tableaux/<AAAAMMJJ>-issue229-grille.md SEUL ; les valeurs brutes
#  <AAAAMMJJ>-issue229-grille-brut.tsv (environ 9,8 Mo) vont sur la branche de
#  sauvegarde (sauvegarde/issue229/), en attendant l'accord du mainteneur
#  (annotation, L12) : --brut FICHIER les ecrit HORS du depot, jamais
#  ecrasees ; leur md5 et leur taille sont cites dans le T0 du tableau.
#  --ecrire sans --brut est refuse des l'analyse des options (le T0
#  citerait des valeurs brutes que rien ne conserve).
#  --ecrire REFUSE (code 1, rien d'ecrit)
#  si : --brut absent ; parametres differents de ceux de la specification ; commit non
#  propre ou code hors du depot (motifs_non_versionnable()) ; sources de
#  #221 ou #175 non suivies par git ; controles d'integrite en echec ; un
#  fichier cible suivi par git sans --remplacer (garde_ecrasement(), #173).
#  Gardes anticipees des l'analyse des options (commit, code, dossier,
#  sources suivies par git, ecrasement), reprises avant d'ecrire.
#  --sortie DOSSIER : tableau et valeurs brutes, memes noms, dans DOSSIER,
#  HORS du depot (valeurs brutes jamais ecrasees).
#  Valeurs brutes (-grille-brut.tsv) : une ligne par replication des couches
#  verite (J1, J2, J3) et des alternatives : couche, jeu, b, regime, delta
#  (%.17g), q chapeau, puis p1 tilde et p3 tilde de chaque statistique
#  (%.10g, au-dela de la resolution 1 / M des queues empiriques).
#
#  Fonctions reprises par copie declaree (ces scripts executent leur calcul
#  au chargement et ne peuvent pas etre sources) : de
#  tests/conservatisme_interieur_t8.R : lire_option(), plateforme_calcul(),
#  meme_fichier(), empreintes_code(), sous_depot(), ecrire_console(),
#  ligne_md(), entete_md(), num(), ic_cp(), txt_ic(), code_regime(),
#  md5_fichier(), chemin_cite(), suivi_git(), lire_j2(), controle (c) (liste
#  blanche NOMS_E2) ; de tests/calibration_mc_t8.R : LOI_STAT, LIB_LOI.
#  commit_depot(), motifs_non_versionnable(), garde_ecrasement(),
#  ligne_remplacement(), inserer_t0(), empreinte_sans_commentaires() :
#  tests/outils_tests.R.
#  Code de sortie : 0 si les controles d'integrite tiennent, 1 sinon.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/grille_regime_t8.R"

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
OPTIONS_VALEUR <- c("--M", "--R", "--R-P", "--coeurs", "--sortie", "--brut")
OPTIONS_DRAPEAU <- c("--ecrire", "--remplacer")
local({
  i <- 1L
  while (i <= length(ARGS)) {
    a <- ARGS[i]
    if (a %in% OPTIONS_VALEUR) i <- i + 2L
    else if (a %in% OPTIONS_DRAPEAU) i <- i + 1L
    else stop("option inconnue : ", a)
  }
})
lire_option <- function(nom, defaut) {
  i <- match(nom, ARGS)
  if (is.na(i)) return(defaut)
  if (i == length(ARGS)) stop("option ", nom, " sans valeur")
  ARGS[i + 1L]
}
entier <- function(nom, defaut) {
  v <- suppressWarnings(as.integer(lire_option(nom, as.character(defaut))))
  if (is.na(v) || v < 1L) stop(nom, " : entier >= 1")
  v
}
# Parametres de la specification (par. 4.1, 3.2, 6).
M_SPEC <- 3000L; R_SPEC <- 2000L; RP_SPEC <- 1000L
OPT_M <- entier("--M", M_SPEC)
OPT_R <- entier("--R", R_SPEC)
OPT_RP <- entier("--R-P", RP_SPEC)
OPT_COEURS <- entier("--coeurs", 1L)
OPT_ECRIRE <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_SORTIE <- lire_option("--sortie", NA_character_)
OPT_BRUT <- lire_option("--brut", NA_character_)
if (OPT_REMPLACER && !OPT_ECRIRE) stop("--remplacer : reserve a --ecrire (#173)")
if (OPT_ECRIRE && !is.na(OPT_SORTIE)) stop("--ecrire et --sortie sont exclusifs")
# --ecrire sans --brut : le T0 citerait le md5 de valeurs brutes que rien ne
# conserve (constat M1 de l'audit) ; refus d'usage, avant tout calcul.
if (OPT_ECRIRE && is.na(OPT_BRUT))
  stop("--ecrire : --brut FICHIER obligatoire (valeurs brutes citees par le T0, conservees hors du depot, branche de sauvegarde, L12)")
if (!is.na(OPT_SORTIE) && !dir.exists(OPT_SORTIE)) stop("--sortie : dossier introuvable : ", OPT_SORTIE)
if (OPT_COEURS > 1L && .Platform$OS.type == "windows") stop("--coeurs > 1 : fork indisponible sous Windows")
PARAMETRES_SPEC <- OPT_M == M_SPEC && OPT_R == R_SPEC && OPT_RP == RP_SPEC
if (OPT_ECRIRE && !PARAMETRES_SPEC)
  stop("--ecrire : parametres reduits (--M, --R, --R-P) refuses ; tableau versionne aux parametres de la specification seulement")
if (OPT_R > 2000L) stop("--R : au plus 2 000 (valeurs brutes de #221 et #175)")
if (OPT_RP > RP_SPEC) stop("--R-P : au plus 1 000 (matrices des scenarios tirees a R_P = 1 000 complet, L8)")

# --- Protocole (constantes de la specification) -------------------------------
METHODE <- "premium"
T_ <- 8L
SEUILS <- c(0.10, 0.05)
B_BOOT <- 999L; B_MAX <- 25000L
GRAINE_JEUX <- 20260927           # jeux de J1, J2, J3 (par. 3.1, 3.2)
GRAINE_BOOT <- 20260831           # bootstrap de la mesure (collisions seulement)
GRAINE_V3B <- 20800000            # flux de V3b de la mesure (collisions seulement)
GRAINE_P <- 20810000              # scenarios de P (par. 3.3)
GRAINE_GRILLE <- 20820000         # couche de reference (par. 3.3)
NOEUDS <- c(0, 0.05, 0.15, 0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.85, 0.95, 1)
PROFILS <- c(J1 = 1L, J2 = 2L, J3 = 3L)
# J3 (par. 3.2) : plan synthetique en deux grappes, sans jeu observe.
X3 <- c(10, 10.5, 95, 92, 11, 11.5, 98, 90)
DELTA3 <- 0.60; BETA3 <- 0.70; SIGMA3 <- 0.10; GAMMA3 <- log(SIGMA3 / BETA3)
# gamma_ref de J1 et J2 cites par la specification (T0 de #221), controle (m).
GAMMA_SPEC <- c(J1 = -1.93433, J2 = -2.31999)
# Familles (par. 1) : F_T, douze temoins ; F_8, huit statistiques de #175 ;
# F_R = catalogue moins F_T.
F_T <- c("AD", "CvM", "KS", "SW", "Lillie", "Intercept", "CUSUM", "LB1", "Runs", "Runsr", "Smirnov", "CoxStuart")
F_8 <- c("BP", "BP79", "GQ", "BF", "Grubbs", "Grubbsr", "DAgo", "JB")
# Scenarios de P (par. 6) : code, rang s, famille, parametre.
SCENARIOS <- data.frame(code = c("H0", "H3", "C3", "C4", "A8", "A2"), s = 1:6,
                        famille = c("H", "H", "C", "C", "A", "A"), par = c(0, 3, 3, 4, 8, 2),
                        stringsAsFactors = FALSE)
LIB_SCEN <- c(H0 = "H, k = 0", H3 = "H, k = 3", C3 = "C, \u03bb = 3", C4 = "C, \u03bb = 4", A8 = "A, \u03bd = 8", A2 = "A, \u03bd = 2")
CIBLES <- list(H = c("BP", "BP79", "White", "GQ", "BF"), C = c("Grubbs", "Grubbsr", "DAgo", "JB", "SF"),
               A = c("DAgo", "JB", "SF", "Grubbs", "Grubbsr"))
NIVEAU_HOLM <- 0.05
N_EVALUABLE <- 100L
SEUIL_C3 <- 0.01
TOL_ESTAR <- 0.05                  # (g1) hors tolerance : e* > 0,05 sur J2
BANDE_PUISSANCE <- c(0.2, 0.8)
REG <- c("bord0", "interieur", "bord1")
LIB_REG <- c(bord0 = "\u03b4\u0302* = 0", interieur = "\u03b4\u0302* int\u00e9rieur", bord1 = "\u03b4\u0302* = 1")
VARIANTES <- c("V1", "V3a", "V3b", "V3h")
VARIANTES_CRIT <- c("V3b", "V3a", "V3h")
SCRIPT_72 <- file.path("tests", "taux_franchissement_reperes.R")
SPEC <- file.path("docs", "specifications", "229-p-conditionnelle-regime.md")
NOMS_E2 <- c("engine_sous_graine", "OPT_GRAINE", "t", "vapply", "seq_len", "OPT_R", "function",
             "usp_simuler", "FIT0", "numeric", "T_", "{", "(")
# Lois discretes (copie declaree de tests/calibration_mc_t8.R).
LOI_STAT <- c(Runs = "suites", Runsr = "suites", MK = "mk", Smirnov = "smirnov",
              SpearVol = "spearman", SpearTps = "spearman", CoxStuart = "coxstuart")
LIB_LOI <- c(suites = "suites (Swed-Eisenhart, 4 et 4)", mk = "Mann-Kendall (loi mahonienne)",
             smirnov = "Smirnov (4 et 4)", spearman = "Spearman (loi de permutation)",
             coxstuart = "Cox-Stuart (Binomiale(4, 1/2))")

# --- Chargement du moteur et des outils --------------------------------------
FICHIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) f else NA_character_
})
DOSSIER_SCRIPT <- if (!is.na(FICHIER_SCRIPT)) dirname(FICHIER_SCRIPT) else
  if (file.exists("tests/outils_tests.R")) "tests" else "."
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))
STATS <- names(USP_CATALOGUE_MC)
NS <- length(STATS)
F_R <- setdiff(STATS, F_T)
QUEUE <- vapply(STATS, function(s) USP_CATALOGUE_MC[[s]]$queue, "")

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

# --- Sorties et gardes anticipees de --ecrire (#205, #173) ---------------------
DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
NOMS_SORTIE <- c(md = sprintf("%s-issue229-grille.md", DATE_SORTIE),
                 brut = sprintf("%s-issue229-grille-brut.tsv", DATE_SORTIE))
# --ecrire : le tableau seul (le brut va sur la branche de sauvegarde, L12).
CIBLES_ECRIRE <- file.path(RACINE, "docs", "tableaux", NOMS_SORTIE[["md"]])
if (!is.na(OPT_BRUT)) {
  if (!dir.exists(dirname(OPT_BRUT))) stop("--brut : dossier introuvable : ", dirname(OPT_BRUT))
  if (sous_depot(dirname(OPT_BRUT))) stop("--brut : chemin sous le depot refuse (branche de sauvegarde, L12) : ", OPT_BRUT)
  if (file.exists(OPT_BRUT)) stop("--brut : fichier existant, jamais ecrase : ", OPT_BRUT)
}
if (!is.na(OPT_SORTIE) && file.exists(file.path(OPT_SORTIE, NOMS_SORTIE[["brut"]])))
  stop("--sortie : valeurs brutes deja presentes, jamais ecrasees : ", file.path(OPT_SORTIE, NOMS_SORTIE[["brut"]]))
if (!is.na(OPT_SORTIE) && sous_depot(OPT_SORTIE))
  stop("--sortie : dossier sous le depot refuse (--ecrire est le seul chemin qui ecrit dans le depot) : ", OPT_SORTIE)
# Sources de #221 et #175 : le plus recent fichier de chaque motif.
derniere <- function(motif) {
  d <- file.path(RACINE, "docs", "tableaux")
  f <- sort(list.files(d, pattern = motif))
  if (length(f)) file.path(d, f[length(f)]) else NA_character_
}
F_BRUT221 <- c(J1 = derniere("^[0-9]{8}-issue166-brut-J1\\.tsv$"), J2 = derniere("^[0-9]{8}-issue166-brut-J2\\.tsv$"))
F_TAB221 <- vapply(F_BRUT221, function(f) sub("-issue166-brut-", "-issue166-calibration-", sub("\\.tsv$", ".md", f)), "")
F_BRUT175 <- derniere("^[0-9]{8}-issue175-brut\\.tsv$")
SOURCES <- c(F_BRUT221, F_TAB221, F_BRUT175)
names(SOURCES) <- c("brut221_J1", "brut221_J2", "tableau221_J1", "tableau221_J2", "brut175")
if (OPT_ECRIRE) {
  nv0 <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, SCRIPT_72), "de l'ex\u00e9cution")
  if (length(nv0)) {
    message("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv0, collapse = " ; "),
            " -- relancer sur un arbre propre, ou utiliser --sortie DOSSIER hors du depot")
    quit(status = 1L)
  }
  if (!dir.exists(file.path(RACINE, "docs", "tableaux")))
    stop("dossier de sortie introuvable : ", file.path(RACINE, "docs", "tableaux"))
  # sources de #221 et #175 suivies par git (constat m4 de l'audit : garde
  # anticipee, reprise avant d'ecrire)
  suivi0 <- vapply(SOURCES, suivi_git, "")
  if (any(suivi0 != "oui")) {
    message("--ecrire refuse : sources de #221 ou #175 absentes ou non suivies par git : ",
            paste(names(SOURCES)[suivi0 != "oui"], collapse = ", "))
    quit(status = 1L)
  }
  garde_ecrasement(CIBLES_ECRIRE, OPT_REMPLACER, RACINE)
}

# --- Textes du critere et de la regle A2 (specification, par. 2.1-2.2, 4.4) ---
# Reportes sans modification (controle (t)).
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
TEXTE_REGLE_A2 <- c(
  "### 4.4 R\u00e8gle d'arr\u00eat A2",
  "",
  "**\u00c9chec pr\u00e9dit franc** : la grandeur pr\u00e9dite franchit le seuil de la condition de plus de e*. Par exemple, taux pr\u00e9dit < \u03b1/2 \u2212 e* ou > 3\u03b1/2 + e*, ou diff\u00e9rence de puissance pr\u00e9dite V1 \u2212 V3 > e*. Tout \u00e9chec franc est un **point de d\u00e9cision du mainteneur** (arr\u00eat ou r\u00e9duction) ; recommandation par cas :",
  "",
  "| Pr\u00e9diction | Recommandation d'`actuary` |",
  "|---|---|",
  "| (g1) hors tol\u00e9rance : e* > 0,05 sur J2 | La grille ne pr\u00e9dit pas : A2 se lit sans elle, mesure compl\u00e8te. |",
  "| C2 en \u00e9chec franc (J2 ou J3 int\u00e9rieur) | **Arr\u00eat** de la mesure embo\u00eet\u00e9e : V3 n'atteint pas sa cible. Conclure \u00ab conserver et documenter \u00bb sur #175 et la grille. |",
  "| C3 en \u00e9chec franc sur un jeu | **R\u00e9duction** : jeu en cause en descriptif, ou B_max revu (d\u00e9cision). |",
  "| C1 seule en \u00e9chec franc | **Poursuite compl\u00e8te** : c'est l'arbitrage de cible (D2) que la mesure doit chiffrer. |",
  "| C4 en \u00e9chec franc (perte de puissance aux bords) | **Poursuite** ; V3h retenue (si Q-A1-4 l'a \u00e9cart\u00e9e, la rouvrir) ; P \u00e9tendue \u00e0 J3 si C4b n'est pas pr\u00e9dite d\u00e9celable sur J2. |",
  "| Aucun \u00e9chec franc, C4 remplie avec une marge > 2 e* | **R\u00e9duction possible de P** : un sc\u00e9nario par famille. |",
  "| Puissance pr\u00e9dite de V1 hors de [0,2 ; 0,8] pour toute la cible d'une famille | Intensit\u00e9 de la famille ajust\u00e9e avant l'\u00e9tape 6, la d\u00e9cision du mainteneur \u00e0 A2 fixant les nouvelles valeurs. |")

###############################################################################
#  CONTROLES ET SOURCES
###############################################################################
COMMIT <- commit_depot(SCRIPT)
EMPREINTES <- empreintes_code(SCRIPT, SCRIPT_72)
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
liste_b <- function(v) if (length(v)) paste0(" : r\u00e9plication(s) ", paste(utils::head(unique(v), 20), collapse = ", "),
                                              if (length(unique(v)) > 20) ", ..." else "") else ""

# (b) Catalogue et familles.
controle(NS == 34L && all(F_T %in% STATS) && length(F_R) == 22L && !length(intersect(F_T, F_R)) &&
           setequal(union(F_T, F_R), STATS) && all(F_8 %in% F_R) && all(unlist(CIBLES) %in% F_R),
         sprintf("(b) %d statistiques au catalogue USP_CATALOGUE_MC ; F_T (%d) et F_R (%d) en partition ; F_8 et les ensembles cibles de P dans F_R",
                 NS, length(F_T), length(F_R)))

# (t) Textes reportes identiques a la specification.
TXT_SPEC <- enc2utf8(readLines(file.path(RACINE, SPEC), warn = FALSE, encoding = "UTF-8"))
present_bloc <- function(bloc) {
  i <- which(TXT_SPEC == bloc[1])
  any(vapply(i, function(k) k + length(bloc) - 1L <= length(TXT_SPEC) &&
               identical(TXT_SPEC[k:(k + length(bloc) - 1L)], bloc), logical(1)))
}
TITRE_ANNOTATION <- "## Annotation du 9 octobre 2026 : lecture des points ouverts de la grille"
controle(present_bloc(TEXTE_CRITERE_229) && present_bloc(TEXTE_REGLE_A2) && any(TXT_SPEC == TITRE_ANNOTATION),
         sprintf("(t) textes du crit\u00e8re (par. 2.1-2.2, %d lignes) et de la r\u00e8gle A2 (par. 4.4, %d lignes) identiques \u00e0 %s (md5 %s) ; annotation \u00ab %s \u00bb pr\u00e9sente",
                 length(TEXTE_CRITERE_229), length(TEXTE_REGLE_A2), SPEC, md5_fichier(file.path(RACINE, SPEC)), sub("^## ", "", TITRE_ANNOTATION)))

if (any(is.na(SOURCES) | !file.exists(SOURCES))) stop("sources de #221 ou #175 introuvables dans docs/tableaux/")
lire_tsv <- function(f) {
  l <- readLines(f, warn = FALSE, encoding = "UTF-8")
  en <- strsplit(l[1], "\t", fixed = TRUE)[[1]]
  M <- do.call(rbind, strsplit(l[-1], "\t", fixed = TRUE))
  if (is.null(M) || ncol(M) != length(en)) stop("valeurs brutes illisibles : ", f)
  colnames(M) <- en
  M
}
BRUT221 <- lapply(F_BRUT221, function(f) {
  M <- lire_tsv(f)
  if (!all(c("b", "regime", paste0("p_mc:", STATS)) %in% colnames(M)) || !identical(as.integer(M[, "b"]), seq_len(nrow(M))))
    stop("valeurs brutes de #221 : colonnes b, regime, p_mc:<stat> absentes ou b different de 1..R : ", f)
  list(regime = unname(M[, "regime"]),
       p = matrix(suppressWarnings(as.numeric(M[, paste0("p_mc:", STATS)])), nrow(M), NS, dimnames = list(NULL, STATS)))
})
BRUT175 <- local({
  M <- lire_tsv(F_BRUT175)
  st <- unique(sub("^p1:", "", grep("^p1:", colnames(M), value = TRUE)))
  list(M = M, stats = st)
})
# Tailles lissees des lois discretes (T0 des tableaux de #221).
lissees <- function(f, quoi = "lissee") {
  l <- enc2utf8(readLines(f, warn = FALSE, encoding = "UTF-8"))
  li <- l[startsWith(l, "| Tailles des lois discr\u00e8tes")]
  if (length(li) != 1L) return(NULL)
  v <- vapply(names(LIB_LOI), function(k) {
    m <- regmatches(li, regexec(paste0(gsub("([()])", "\\\\\\1", LIB_LOI[[k]]),
                                      if (quoi == "lissee") " : atteignable [0-9,]+ et [0-9,]+, liss\u00e9e ([0-9,]+) et ([0-9,]+)"
                                      else " : atteignable ([0-9,]+) et ([0-9,]+), liss\u00e9e [0-9,]+ et [0-9,]+"), li))[[1]]
    if (length(m) != 3L) return(c(NA_real_, NA_real_))
    as.numeric(sub(",", ".", m[2:3], fixed = TRUE))
  }, numeric(2))
  if (anyNA(v)) NULL else v
}
LISS <- lapply(F_TAB221, lissees)
ATT <- lapply(F_TAB221, lissees, quoi = "atteignable")
controle(!is.null(LISS$J1) && identical(LISS$J1, LISS$J2),
         sprintf("(s) tailles liss\u00e9es \u00e0 B = 999 des cinq lois discr\u00e8tes lues dans le T0 des tableaux de #221 (J1 et J2 identiques) : %s",
                 if (is.null(LISS$J2)) "illisibles" else paste(sprintf("%s %s et %s", names(LIB_LOI), vapply(LISS$J2[1, ], num, "", d = 5), vapply(LISS$J2[2, ], num, "", d = 5)), collapse = " ; ")))
REF <- vapply(seq_along(SEUILS), function(a) vapply(STATS, function(s)
  if (s %in% names(LOI_STAT) && !is.null(LISS$J2)) LISS$J2[a, LOI_STAT[[s]]] else SEUILS[a], 1), numeric(NS))
dimnames(REF) <- list(STATS, c("a10", "a05"))
# (s) Comptes de T1 bis de #221 : brut contre tableau.
LIB_REG_221 <- c(bord1 = "\u03b4\u0302* = 1 (\u03c0\u0302* constant)", bord0 = "\u03b4\u0302* = 0 (\u03c0\u0302* variable)", interieur = "\u03b4\u0302* int\u00e9rieur (\u03c0\u0302* variable)")
t1bis_221 <- function(f) {
  l <- enc2utf8(readLines(f, warn = FALSE, encoding = "UTF-8"))
  i <- grep("^### T1 bis", l); if (length(i) != 1L) return(NULL)
  j <- grep("^### ", l); j <- min(c(j[j > i], length(l) + 1L)) - 1L
  t <- l[i:j]; t <- t[startsWith(t, "| ") & !startsWith(t, "| ---") & !startsWith(t, "| Statistique")]
  ch <- lapply(t, function(x) strsplit(sub(" \\|$", "", sub("^\\| ", "", x)), " | ", fixed = TRUE)[[1]])
  data.frame(stat = vapply(ch, `[`, "", 1), regime = names(LIB_REG_221)[match(vapply(ch, `[`, "", 2), LIB_REG_221)],
             n = as.integer(vapply(ch, `[`, "", 3)), k10 = as.integer(vapply(ch, `[`, "", 4)),
             k05 = as.integer(vapply(ch, `[`, "", 9)), stringsAsFactors = FALSE)
}
ok_t1bis <- vapply(names(BRUT221), function(j) {
  tb <- t1bis_221(F_TAB221[[j]]); B <- BRUT221[[j]]
  if (is.null(tb) || nrow(tb) != 3L * NS || anyNA(tb$regime)) return(FALSE)
  all(vapply(seq_len(nrow(tb)), function(i) {
    p <- B$p[B$regime == tb$regime[i], tb$stat[i]]; f <- is.finite(p)
    sum(f) == tb$n[i] && sum(f & p < 0.10) == tb$k10[i] && sum(f & p < 0.05) == tb$k05[i]
  }, logical(1)))
}, logical(1))
controle(all(ok_t1bis), sprintf("(s) comptes (n, k \u00e0 0,10 et \u00e0 0,05) des %d cellules de T1 bis de #221 recalcul\u00e9s depuis ses valeurs brutes \u00e9gaux \u00e0 ceux de son tableau : %s",
                                3L * NS, paste(sprintf("%s %s", names(ok_t1bis), ifelse(ok_t1bis, "OK", "\u00c9CHEC")), collapse = ", ")))

# --- Jeux et modeles -----------------------------------------------------------
JEUX <- list(J1 = list(x = .ln$xt, y = .ln$yt, libelle = "J1 : tests/donnees/donnees_ln.csv"),
             J2 = c(lire_j2(), libelle = "J2 : xi, yi de tests/unitaires/test_controles_numeriques.R"))
fit_synth <- function(beta, x, delta, gamma)
  list(beta = beta, x = x, pi = usp_pi(delta, gamma, x, mean(x)), T = length(x), delta = delta, gamma = gamma, xbar = mean(x))
FIT0 <- list(J1 = usp_ajuster(JEUX$J1$x, JEUX$J1$y), J2 = usp_ajuster(JEUX$J2$x, JEUX$J2$y),
             J3 = fit_synth(BETA3, X3, DELTA3, GAMMA3))
X_PROFIL <- lapply(FIT0, `[[`, "x")
GAMMA_REF <- vapply(FIT0, `[[`, 1, "gamma")
BETA_REF <- vapply(FIT0, `[[`, 1, "beta")
controle(all(abs(GAMMA_REF[c("J1", "J2")] - GAMMA_SPEC) <= 5e-6) && identical(X3, FIT0$J3$x) &&
           abs(BETA3 * exp(GAMMA3) - SIGMA3) < 1e-15 && max(X3) / min(X3) < 10,
         sprintf("(m) \u03b3_ref : J1 %.6f, J2 %.6f (sp\u00e9cification : %.5f et %.5f, \u00e0 5e-6) ; J3 : x3 = (%s), \u03b40 = %s, \u03b20 = %s, \u03b30 = ln(\u03c30 / \u03b20) = %.6f, \u03c30 = %s, amplitude %s",
                 GAMMA_REF[["J1"]], GAMMA_REF[["J2"]], GAMMA_SPEC[["J1"]], GAMMA_SPEC[["J2"]],
                 paste(format(X3), collapse = " ; "), format(DELTA3), format(BETA3), GAMMA3, format(SIGMA3), num(max(X3) / min(X3), 2)))

# (c) Jeux de la couche verite : expression YSIM de #72.
OPT_GRAINE <- GRAINE_JEUX
YSIM <- lapply(FIT0, function(f) engine_sous_graine(OPT_GRAINE, t(vapply(seq_len(OPT_R), function(b) usp_simuler(f), numeric(T_)))))
ysim_72 <- function(fit) tryCatch({
  ex <- as.list(parse(file.path(RACINE, SCRIPT_72), keep.source = FALSE))
  cible <- Filter(function(e) is.call(e) && identical(e[[1]], as.name("<-")) && identical(e[[2]], as.name("YSIM")), ex)
  if (length(cible) != 1L) stop(length(cible), " affectation(s) de YSIM au niveau superieur (une attendue)")
  rhs <- cible[[1]][[3]]
  hors <- setdiff(all.names(rhs), NOMS_E2)
  if (length(hors)) stop("nom(s) hors de la liste blanche NOMS_E2 : ", paste(hors, collapse = ", "))
  env <- new.env(parent = emptyenv())
  liaisons <- list(engine_sous_graine = engine_sous_graine, usp_simuler = usp_simuler,
                   t = base::t, vapply = base::vapply, seq_len = base::seq_len, numeric = base::numeric,
                   "function" = base::`function`, "{" = base::`{`, "(" = base::`(`,
                   OPT_GRAINE = GRAINE_JEUX, OPT_R = OPT_R, FIT0 = fit, T_ = T_)
  stopifnot(setequal(names(liaisons), NOMS_E2))
  for (nm in names(liaisons)) assign(nm, liaisons[[nm]], envir = env)
  eval(rhs, env)
}, error = function(e) e)
ok_ysim <- vapply(c("J1", "J2", "J3"), function(j) { y <- ysim_72(FIT0[[j]]); !inherits(y, "error") && identical(y, YSIM[[j]]) }, logical(1))
controle(all(ok_ysim), sprintf("(c) %d jeux par jeu (J1, J2, J3) identiques \u00e0 ceux de l'expression YSIM de %s (noms en liste blanche, environnement isol\u00e9) : %s",
                               OPT_R, SCRIPT_72, paste(sprintf("%s %s", names(ok_ysim), ifelse(ok_ysim, "OK", "\u00c9CHEC")), collapse = ", ")))

# Scenarios de P : jeux tires avant la parallelisation (ordre fixe en tete).
generer_scenario <- function(sc, R) {
  f <- FIT0$J2; x <- f$x; pi <- f$pi; beta <- f$beta
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
# md5 d'un objet numerique : valeurs en %.17g, une par ligne (matrice lue
# ligne par ligne), fichier temporaire, tools::md5sum() (L8).
md5_valeurs <- function(x) {
  f <- tempfile("md5_"); on.exit(unlink(f))
  v <- if (is.matrix(x)) as.vector(t(x)) else x
  ecrire_txt <- file(f, open = "wb"); writeLines(sprintf("%.17g", v), ecrire_txt); close(ecrire_txt)
  unname(tools::md5sum(f))
}
# Tirage toujours a R_P complet (RP_SPEC = 1 000, L8), quel que soit --R-P :
# une execution reduite ou une tranche de l'etape 6 y prend ses lignes.
YALT <- lapply(stats::setNames(seq_len(nrow(SCENARIOS)), SCENARIOS$code), function(i) {
  g <- generer_scenario(SCENARIOS[i, ], RP_SPEC)
  list(Y = g$Y[seq_len(OPT_RP), , drop = FALSE], md5_E = md5_valeurs(g$E), md5_Y = md5_valeurs(g$Y),
       md5_ts = if (is.null(g$ts)) NULL else md5_valeurs(g$ts))
})

# (graines) Collisions et recherche des litteraux.
GRAINES <- local({
  g <- list(
    jeux = data.frame(flux = "jeux de J1, J2, J3", graine = GRAINE_JEUX),
    grille = data.frame(flux = sprintf("couche de r\u00e9f\u00e9rence, profil %d, n\u0153ud %d", rep(1:3, each = 12), rep(1:12, 3)),
                        graine = GRAINE_GRILLE + 100 * rep(1:3, each = 12) + rep(1:12, 3)),
    scen = data.frame(flux = sprintf("sc\u00e9nario %d de P%s", 1:9, ifelse(1:9 > 6, " (option P-J3, r\u00e9serv\u00e9e)", "")), graine = GRAINE_P + 1:9),
    boot = data.frame(flux = sprintf("bootstrap de la mesure, r\u00e9plication %d", 0:2000), graine = GRAINE_BOOT + 0:2000),
    v3b = data.frame(flux = sprintf("flux de V3b de la mesure, r\u00e9plication %d", 1:2000), graine = GRAINE_V3B + 1:2000),
    sw = data.frame(flux = "SEED_LOI_NULLE_SW", graine = SEED_LOI_NULLE_SW))
  do.call(rbind, g)
})
COLLISIONS <- local({
  d <- GRAINES$graine[duplicated(GRAINES$graine)]
  lapply(unique(d), function(v) GRAINES$flux[GRAINES$graine == v])
})
DECLAREES <- list(c("jeux de J1, J2, J3", "bootstrap de la mesure, r\u00e9plication 96"),
                  c("bootstrap de la mesure, r\u00e9plication 70", "SEED_LOI_NULLE_SW"))
non_declarees <- Filter(function(cl) !any(vapply(DECLAREES, function(d) setequal(d, cl), logical(1))), COLLISIONS)
LITTERAUX <- local({
  fs <- c(file.path(RACINE, "R", "engine.R"), list.files(file.path(RACINE, "tests"), pattern = "\\.R$", full.names = TRUE),
          list.files(file.path(RACINE, "tests", "unitaires"), pattern = "\\.R$", full.names = TRUE))
  fs <- fs[!vapply(fs, meme_fichier, logical(1), b = file.path(RACINE, SCRIPT))]
  v <- unlist(lapply(fs, function(f) {
    l <- readLines(f, warn = FALSE)
    as.numeric(unlist(regmatches(l, gregexpr("\\b20[0-9]{6}\\b", l, perl = TRUE))))
  }))
  list(max = if (length(v)) max(v) else NA_real_, dans = sort(unique(v[v >= GRAINE_V3B & v < GRAINE_GRILLE + 1000])),
       n_fichiers = length(fs))
})
controle(!length(non_declarees) && !length(LITTERAUX$dans),
         sprintf("(graines) %d graines list\u00e9es (script et mesure) : collisions d\u00e9clar\u00e9es (h\u00e9rit\u00e9es de #166) : %s ; non d\u00e9clar\u00e9es : %s ; litt\u00e9raux 20xxxxxx de %d fichiers (R/engine.R, tests/*.R, tests/unitaires/*.R, hors ce script) : maximum %.0f (dates comprises), dans les plages de #229 [%.0f ; %.0f[ : %s",
                 nrow(GRAINES), paste(vapply(COLLISIONS[!COLLISIONS %in% non_declarees], paste, "", collapse = " = "), collapse = " ; "),
                 if (length(non_declarees)) paste(vapply(non_declarees, paste, "", collapse = " = "), collapse = " ; ") else "aucune",
                 LITTERAUX$n_fichiers, LITTERAUX$max, GRAINE_V3B, GRAINE_GRILLE + 1000,
                 if (length(LITTERAUX$dans)) paste(LITTERAUX$dans, collapse = ", ") else "aucun"))

###############################################################################
#  CALCUL (taches paralleles : noeuds, paquets de replications)
###############################################################################
tache_noeud <- function(j, i) {
  t0 <- Sys.time()
  x <- X_PROFIL[[j]]; d <- NOEUDS[i]; g <- GAMMA_REF[[j]]
  fit <- fit_synth(BETA_REF[[j]], x, d, g)
  graine <- GRAINE_GRILLE + 100 * PROFILS[[j]] + i
  Y <- engine_sous_graine(graine, t(vapply(seq_len(OPT_M), function(m) usp_simuler(fit), numeric(T_))))
  S <- matrix(NA_real_, OPT_M, NS, dimnames = list(NULL, STATS))
  reg <- rep(NA_character_, OPT_M)
  ech <- c(rapide = 0L, stats = 0L)
  for (m in seq_len(OPT_M)) {
    f <- try(usp_ajuster_rapide(x, Y[m, ], d, g), silent = TRUE)
    if (inherits(f, "try-error")) { ech[["rapide"]] <- ech[["rapide"]] + 1L; next }
    s <- try(.stats_bootstrapables(x, Y[m, ], f$z, f$pi), silent = TRUE)
    if (inherits(s, "try-error")) { ech[["stats"]] <- ech[["stats"]] + 1L; next }
    S[m, ] <- s[STATS]; reg[m] <- code_regime(f$delta)
  }
  k <- !is.na(reg)
  list(type = "noeud", jeu = j, i = i, delta = d, graine = graine, S = S[k, , drop = FALSE], reg = reg[k], ech = ech,
       duree = as.numeric(difftime(Sys.time(), t0, units = "secs")))
}
# Une replication : ajustement comme run_engine(), regime, statistiques observees.
traiter_jeu <- function(x, y) {
  fit <- tryCatch(usp_ajuster(x, y), error = function(e) e)
  va <- if (inherits(fit, "error")) list(ok = FALSE) else usp_valider_ajustement(fit, METHODE)
  vide <- stats::setNames(rep(NA_real_, NS), STATS)
  if (!isTRUE(va$ok)) return(list(regime = "ecartee", motif = if (inherits(fit, "error")) "ajustement" else "refus",
                                   delta = if (inherits(fit, "error")) NA_real_ else fit$delta, sobs = vide))
  so <- tryCatch(.mc_evaluer(USP_CATALOGUE_MC, .usp_contexte_mc(x, y, fit$z, fit$pi)), error = function(e) NULL)
  if (is.null(so)) return(list(regime = "ecartee", motif = "statistiques", delta = fit$delta, sobs = vide))
  list(regime = code_regime(fit$delta), delta = fit$delta, sobs = so[STATS])
}
tache_paquet <- function(type, jeu, bs) {
  t0 <- Sys.time()
  x <- if (type == "verite") X_PROFIL[[jeu]] else X_PROFIL$J2
  Y <- if (type == "verite") YSIM[[jeu]] else YALT[[jeu]]$Y
  r <- lapply(bs, function(b) c(list(b = b), traiter_jeu(x, Y[b, ])))
  list(type = type, jeu = jeu, res = r, duree = as.numeric(difftime(Sys.time(), t0, units = "secs")))
}
TAILLE_PAQUET <- 50L
paquets <- function(R) split(seq_len(R), ceiling(seq_len(R) / TAILLE_PAQUET))
TACHES <- c(
  unlist(lapply(names(PROFILS), function(j) lapply(seq_along(NOEUDS), function(i) list(type = "noeud", jeu = j, i = i))), recursive = FALSE),
  unlist(lapply(names(PROFILS), function(j) lapply(paquets(OPT_R), function(bs) list(type = "verite", jeu = j, bs = bs))), recursive = FALSE),
  unlist(lapply(SCENARIOS$code, function(s) lapply(paquets(OPT_RP), function(bs) list(type = "alternative", jeu = s, bs = bs))), recursive = FALSE))
executer <- function(tk) if (tk$type == "noeud") tache_noeud(tk$jeu, tk$i) else tache_paquet(tk$type, tk$jeu, tk$bs)
t_calc <- Sys.time()
RES <- if (OPT_COEURS > 1L) parallel::mclapply(TACHES, executer, mc.cores = OPT_COEURS, mc.preschedule = FALSE) else
  lapply(TACHES, executer)
DUREE_HORLOGE <- as.numeric(difftime(Sys.time(), t_calc, units = "secs"))
en_erreur <- which(!vapply(RES, function(r) is.list(r) && !inherits(r, "try-error") && !is.null(r$type), logical(1)))
if (length(en_erreur)) {
  message("taches en erreur : ", paste(en_erreur, collapse = ", "), " ; premiere : ", as.character(RES[[en_erreur[1]]]))
  controle(FALSE, sprintf("(d) %d t\u00e2che(s) parall\u00e8le(s) en erreur", length(en_erreur)))
  ecrire_console(c("### Contr\u00f4les d'int\u00e9grit\u00e9", "", paste("-", CONTROLES)))
  quit(status = 1L)
}

# --- Couche de reference : lois par noeud --------------------------------------
NOEUD_RES <- Filter(function(r) r$type == "noeud", RES)
tri_stats <- function(S) stats::setNames(lapply(STATS, function(s) { v <- S[, s]; sort(v[is.finite(v)]) }), STATS)
PREP <- lapply(stats::setNames(nm = names(PROFILS)), function(j) {
  lapply(seq_along(NOEUDS), function(i) {
    nd <- NOEUD_RES[[which(vapply(NOEUD_RES, function(r) r$jeu == j && r$i == i, logical(1)))]]
    n_r <- vapply(REG, function(r) sum(nd$reg == r), numeric(1))
    list(delta = nd$delta, graine = nd$graine, n = nrow(nd$S), n_r = n_r, q = n_r / max(nrow(nd$S), 1),
         ech = nd$ech, duree = nd$duree, marg = tri_stats(nd$S),
         cond = lapply(stats::setNames(nm = REG), function(r) tri_stats(nd$S[nd$reg == r, , drop = FALSE])))
  })
})
ok_d <- all(vapply(PREP, function(P) all(vapply(P, function(nd)
  nd$n + sum(nd$ech) == OPT_M && nd$n > 0 && abs(sum(nd$q) - 1) < 1e-12, logical(1))), logical(1)))
controle(ok_d, sprintf("(d) chaque n\u0153ud : tirages retenus + \u00e9cart\u00e9s = M = %d, au moins un tirage retenu, somme des q_\u03b4(r) = 1 ; %d t\u00e2ches parall\u00e8les sans erreur",
                       OPT_M, length(TACHES)))

# Queues empiriques d'un echantillon trie v en s : P(S >= s), P(S <= s).
queues <- function(v, s) {
  n <- length(v)
  c((n - findInterval(s, v, left.open = TRUE)) / n, findInterval(s, v) / n)
}
poids_noeuds <- function(delta, regime) {
  K <- length(NOEUDS)
  if (regime == "bord0") return(list(k = 1L, w = 1))
  if (regime == "bord1") return(list(k = K, w = 1))
  k <- min(max(findInterval(delta, NOEUDS), 1L), K - 1L)
  u <- (delta - NOEUDS[k]) / (NOEUDS[k + 1L] - NOEUDS[k])
  list(k = c(k, k + 1L), w = c(1 - u, u))
}
# Queues (hi, lo) interpolees : moyenne des queues des noeuds ponderee par w
# (renormalise sur les noeuds de poids non nul ayant au moins une valeur
# finie). Loi marginale : w = poids lineaires en delta. Loi conditionnelle
# au regime r (annotation, L7) : w_k q_k(r), soit la loi conditionnelle de
# l'interpolee lineaire de la loi jointe de (S, r) ; poids tous nuls : NA.
queues_interp <- function(echs, w, s) {
  ok <- w > 0 & vapply(echs, length, 1L) > 0L
  if (!any(ok) || !is.finite(s)) return(c(NA_real_, NA_real_))
  w <- w[ok] / sum(w[ok])
  hl <- vapply(echs[ok], queues, numeric(2), s = s)
  c(sum(w * hl[1, ]), sum(w * hl[2, ]))
}
# p a B infini (limite de engine_p_mc()) a partir des queues.
p_infini <- function(hi, lo, queue) switch(queue, haut = hi, bas = lo, deux = pmin(1, 2 * pmin(hi, lo)))
predire <- function(P, delta, regime, sobs) {
  pw <- poids_noeuds(delta, regime)
  nds <- P[pw$k]
  qk <- vapply(nds, function(nd) nd$q[[regime]], 1)
  q <- sum(pw$w * qk)
  h1 <- vapply(STATS, function(s) queues_interp(lapply(nds, function(nd) nd$marg[[s]]), pw$w, sobs[[s]]), numeric(2))
  h3 <- vapply(STATS, function(s) queues_interp(lapply(nds, function(nd) nd$cond[[regime]][[s]]), pw$w * qk, sobs[[s]]), numeric(2))
  list(q = q, h1 = h1[1, ], l1 = h1[2, ], h3 = h3[1, ], l3 = h3[2, ])
}

# --- Populations (couche verite et alternatives) --------------------------------
construire <- function(type, jeu, profil) {
  rr <- do.call(c, lapply(Filter(function(r) r$type == type && r$jeu == jeu, RES), `[[`, "res"))
  rr <- unname(rr[order(vapply(rr, `[[`, 1, "b"))])
  n <- length(rr)
  vide <- matrix(NA_real_, n, NS, dimnames = list(NULL, STATS))
  H1 <- L1 <- H3 <- L3 <- vide; q <- rep(NA_real_, n)
  reg <- vapply(rr, `[[`, "", "regime")
  for (k in which(reg != "ecartee")) {
    pr <- predire(PREP[[profil]], rr[[k]]$delta, reg[k], rr[[k]]$sobs)
    H1[k, ] <- pr$h1; L1[k, ] <- pr$l1; H3[k, ] <- pr$h3; L3[k, ] <- pr$l3; q[k] <- pr$q
  }
  pinf <- function(H, L) { P <- vide; for (s in STATS) P[, s] <- p_infini(H[, s], L[, s], QUEUE[[s]]); P }
  list(b = vapply(rr, `[[`, 1, "b"), regime = reg, delta = vapply(rr, `[[`, 1, "delta"), q = q,
       motif = vapply(rr, function(r) if (is.null(r$motif)) "" else r$motif, ""),
       H1 = H1, L1 = L1, H3 = H3, L3 = L3, P1 = pinf(H1, L1), P3 = pinf(H3, L3),
       duree = sum(vapply(Filter(function(r) r$type == type && r$jeu == jeu, RES), `[[`, 1, "duree")))
}
POP <- c(lapply(stats::setNames(nm = names(PROFILS)), function(j) construire("verite", j, j)),
         lapply(stats::setNames(nm = SCENARIOS$code), function(s) construire("alternative", s, "J2")))

# (c) Regimes de J1 et J2 contre #221, delta* contre #175.
ech_c <- list()
for (j in c("J1", "J2")) {
  d <- which(POP[[j]]$regime != BRUT221[[j]]$regime[seq_len(OPT_R)])
  ech_c[[j]] <- d
}
controle(!length(unlist(ech_c)), sprintf("(c) r\u00e9gime de \u03b4\u0302*_b (couche v\u00e9rit\u00e9) identique \u00e0 celui des valeurs brutes de #221, r\u00e9plications 1..%d : J1%s ; J2%s",
                                         OPT_R, liste_b(ech_c$J1), liste_b(ech_c$J2)))
# delta*_b contre #175 (constat m1 de l'audit) : regime identique
# (bloquant, par. 7 (c)) ; delta a la tolerance TOLERANCE de
# comparer_objets() (relative si |reference| > TOLERANCE, absolue sinon :
# l'ajustement depend de la plateforme par optim()), ecart maximal rapporte.
d175 <- local({
  M <- BRUT175$M
  k <- M[, "statut"] != "observe" & as.integer(M[, "b"]) <= OPT_R
  reg <- character(0); tol <- character(0); n <- 0L; emax <- 0
  for (i in which(k)) {
    j <- M[i, "jeu"]; b <- as.integer(M[i, "b"]); n <- n + 1L
    if (!identical(unname(POP[[j]]$regime[b]), unname(M[i, "regime"]))) reg <- c(reg, sprintf("%s %d", j, b))
    ref <- as.numeric(M[i, "delta"]); val <- POP[[j]]$delta[b]
    e <- if (!is.finite(ref)) Inf else abs(val - ref) / if (abs(ref) > TOLERANCE) abs(ref) else 1
    if (!is.finite(e)) e <- Inf
    emax <- max(emax, e)
    if (e > TOLERANCE) tol <- c(tol, sprintf("%s %d", j, b))
  }
  list(n = n, reg = reg, tol = tol, emax = emax)
})
controle(!length(d175$reg) && !length(d175$tol),
         sprintf(paste("(c) couche v\u00e9rit\u00e9 contre les valeurs brutes de #175, %d r\u00e9plications communes : r\u00e9gime de \u03b4\u0302*_b identique%s ;",
                       "\u03b4\u0302*_b \u00e0 la tol\u00e9rance %g de comparer_objets() (relative, absolue si |r\u00e9f\u00e9rence| \u2264 %g), \u00e9cart maximal %s%s"),
                 d175$n, if (length(d175$reg)) paste0(" sauf ", paste(utils::head(d175$reg, 20), collapse = ", ")) else "",
                 TOLERANCE, TOLERANCE, formatC(d175$emax, format = "e", digits = 3),
                 if (length(d175$tol)) paste0(" ; au-del\u00e0 : ", paste(utils::head(d175$tol, 20), collapse = ", ")) else ""))

###############################################################################
#  PROBABILITES DE REJET A B FINI, DECISIONS A B INFINI, VALIDATION
###############################################################################
# k1 et k2 (annotation, L4) : plus grands k tels que (1 + k)/(B + 1) < alpha
# et 2 (1 + k)/(B + 1) < alpha, evalues par l'expression de engine_p_mc()
# (enumeration de k = 0..B ; -1 si aucun) ; memorises par (B, alpha).
K_CACHE <- new.env()
k_seuils <- function(B, a) {
  cle <- sprintf("%.0f_%.17g", B, a)
  r <- K_CACHE[[cle]]
  if (!is.null(r)) return(r)
  k <- 0:B
  p <- (1 + k) / (B + 1)
  r <- c(k1 = max(c(-1L, k[pmin(p, 1) < a])), k2 = max(c(-1L, k[pmin(2 * p, 1) < a])))
  assign(cle, r, envir = K_CACHE)
  r
}
# Probabilite de rejet pi = P(p_mc < alpha | queues hi, lo) a B tirages
# (annotation, L4) : K ~ Binomiale(B, queue) ; "haut" P(K_hi <= k1) ;
# "bas" P(K_lo <= k1) ; "deux" P(K_hi <= k2) + P(K_lo <= k2). B inferieur a
# B_MIN_DEGENERESCENCE, ou queues absentes : p absente, pi = 0 (non-rejet).
pi_rejet <- function(hi, lo, queue, B, a) {
  # queues interpolees bornees a [0, 1] : une somme ponderee peut depasser 1
  # d'un arrondi (pbinom() rendrait NaN)
  hi <- pmin(pmax(hi, 0), 1); lo <- pmin(pmax(lo, 0), 1)
  out <- numeric(length(hi))
  ok <- is.finite(hi) & is.finite(lo) & is.finite(B) & B >= B_MIN_DEGENERESCENCE
  for (Bu in unique(B[ok])) {
    i <- ok & B == Bu; k <- k_seuils(Bu, a)
    out[i] <- switch(queue,
                     haut = stats::pbinom(k[["k1"]], Bu, hi[i]),
                     bas = stats::pbinom(k[["k1"]], Bu, lo[i]),
                     deux = stats::pbinom(k[["k2"]], Bu, hi[i]) + stats::pbinom(k[["k2"]], Bu, lo[i]))
  }
  out
}
# (s) pi sur la loi mahonienne exacte (T = 8) : tailles lissee (B = 999) et
# atteignable (B infini) du T0 de #221, a 1e-5 pres.
CTRL_MK <- local({
  d <- .mk_loi_exacte(T_)
  hi <- vapply(d$S, function(r) sum(d$prob[d$S >= r]), 1); lo <- vapply(d$S, function(r) sum(d$prob[d$S <= r]), 1)
  liss <- vapply(SEUILS, function(a) sum(d$prob * pi_rejet(hi, lo, QUEUE[["MK"]], rep(B_BOOT, length(hi)), a)), 1)
  att <- vapply(SEUILS, function(a) sum(d$prob[p_infini(hi, lo, QUEUE[["MK"]]) < a]), 1)
  ref_l <- if (is.null(LISS$J2)) c(NA, NA) else LISS$J2[, "mk"]
  ref_a <- if (is.null(ATT$J2)) c(NA, NA) else ATT$J2[, "mk"]
  list(ok = all(abs(liss - ref_l) <= 1e-5) && all(abs(att - ref_a) <= 1e-5), liss = liss, att = att, ref_l = ref_l, ref_a = ref_a)
})
controle(CTRL_MK$ok, sprintf(paste("(s) \u03c0 (annotation, L4) sur la loi mahonienne exacte (T = 8, sens %s) : liss\u00e9e \u00e0 B = 999 %s et %s",
                                   "(T0 de #221 : %s et %s), B infini %s et %s (atteignable du T0 de #221 : %s et %s), \u00e0 1e-5 pr\u00e8s"),
                             QUEUE[["MK"]], num(CTRL_MK$liss[1], 6), num(CTRL_MK$liss[2], 6), num(CTRL_MK$ref_l[1], 5), num(CTRL_MK$ref_l[2], 5),
                             num(CTRL_MK$att[1], 6), num(CTRL_MK$att[2], 6), num(CTRL_MK$ref_a[1], 5), num(CTRL_MK$ref_a[2], 5)))

interieur_mat <- function(D) matrix(D$regime == "interieur", length(D$regime), NS, dimnames = list(NULL, STATS))
# B de chaque variante (annotation, L4) : V1 999 ; V3a arrondi(999 q) ;
# V3b min(999, arrondi(25 000 q)) ; V3h comme V3b a l'interieur, V1 aux bords.
B_variante <- function(D, v) {
  b1 <- rep(B_BOOT, length(D$q)); ba <- round(B_BOOT * D$q); bb <- pmin(B_BOOT, round(B_MAX * D$q))
  switch(v, V1 = b1, V3a = ba, V3b = bb, V3h = ifelse(D$regime == "interieur", bb, b1))
}
# Loi de la variante par ligne : conditionnelle (H3, L3) ou marginale (H1, L1).
utilise_cond <- function(D, v) switch(v, V1 = rep(FALSE, length(D$q)), V3a = , V3b = rep(TRUE, length(D$q)),
                                       V3h = D$regime == "interieur")
absentes <- function(D, v) {
  B <- B_variante(D, v); c3 <- utilise_cond(D, v)
  H <- ifelse(matrix(c3, length(c3), NS), D$H3, D$H1)
  dimnames(H) <- list(NULL, STATS)
  !is.finite(H) | !matrix(is.finite(B) & B >= B_MIN_DEGENERESCENCE, length(B), NS)
}
proba <- function(D, v, a) {
  B <- B_variante(D, v); c3 <- utilise_cond(D, v)
  M <- matrix(0, length(B), NS, dimnames = list(NULL, STATS))
  for (s in STATS)
    M[, s] <- pi_rejet(ifelse(c3, D$H3[, s], D$H1[, s]), ifelse(c3, D$L3[, s], D$L1[, s]), QUEUE[[s]], B, a)
  M
}
# Decisions a B infini (p tilde < alpha ; p absente = non-rejet) : T1 et
# T1 bis a B infini, (g2), McNemar au point (annotation, L10).
decisions <- function(D, v, a) {
  c3 <- matrix(utilise_cond(D, v), length(D$q), NS)
  P <- ifelse(c3, D$P3, D$P1)
  dec <- !absentes(D, v) & is.finite(P) & P < a
  dec[is.na(dec)] <- FALSE
  dimnames(dec) <- list(NULL, STATS)
  dec
}
lignes <- function(j, quoi = "critere") {
  D <- POP[[j]]; v <- D$regime != "ecartee"
  if (quoi == "critere" && j == "J1") v & D$regime != "interieur" else if (quoi %in% REG) D$regime == quoi else v
}
IA <- c("a10", "a05")
DEC <- lapply(POP, function(D) lapply(stats::setNames(nm = VARIANTES), function(v)
  lapply(stats::setNames(SEUILS, IA), function(a) decisions(D, v, a))))
PI <- lapply(POP, function(D) lapply(stats::setNames(nm = VARIANTES), function(v)
  lapply(stats::setNames(SEUILS, IA), function(a) proba(D, v, a))))
moyennes <- function(M, rows) if (!any(rows)) stats::setNames(rep(NA_real_, NS), STATS) else colMeans(M[rows, , drop = FALSE])
taux_pop <- function(j, v, ia, rows) moyennes(PI[[j]][[v]][[ia]], rows)       # pi, a B fini
taux_inf <- function(j, v, ia, rows) moyennes(DEC[[j]][[v]][[ia]], rows)      # B infini

# (g1) Cellules predit (pi a B fini) - mesure.
G1 <- list()
ajouter_g1 <- function(jeu, source, cellule, regime, stat, ia, mes, pre, n, e_star = TRUE)
  G1[[length(G1) + 1L]] <<- data.frame(jeu = jeu, source = source, cellule = cellule, regime = regime, stat = stat, ia = ia,
                                        mesure = mes, predit = pre, n = n, e_star = e_star, stringsAsFactors = FALSE)
for (j in c("J1", "J2")) {
  B <- BRUT221[[j]]; D <- POP[[j]]; R <- seq_len(OPT_R)
  pm <- B$p[R, , drop = FALSE]; rg <- B$regime[R]
  for (ia in IA) {
    a <- SEUILS[match(ia, IA)]; Pv1 <- PI[[j]]$V1[[ia]]
    for (s in STATS) for (r in c("tout", REG)) {
      rows <- if (r == "tout") rep(TRUE, OPT_R) else rg == r
      fm <- rows & is.finite(pm[, s]); fp <- rows & is.finite(D$P1[, s])
      ajouter_g1(j, "#221", if (r == "tout") "T1" else "T1 bis", r, s, ia,
                 if (any(fm)) mean(pm[fm, s] < a) else NA_real_, if (any(fp)) mean(Pv1[fp, s]) else NA_real_, sum(fm))
    }
  }
}
CEL175 <- list(J2 = rbind(cbind("interieur", c(F_8, "AD", "White")), c("bord0", "GQ"), c("bord1", "GQ"), c("bord0", "RESET")),
               J1 = rbind(c("bord0", "GQ"), c("bord0", "RESET"), cbind("interieur", c(F_8, "AD", "White"))))
for (j in c("J2", "J1")) {
  M <- BRUT175$M
  for (ia in IA) {
    a <- SEUILS[match(ia, IA)]
    for (i in seq_len(nrow(CEL175[[j]]))) {
      r <- CEL175[[j]][i, 1]; s <- CEL175[[j]][i, 2]
      k <- M[, "jeu"] == j & M[, "statut"] == "rejouee" & M[, "regime"] == r & as.integer(M[, "b"]) <= OPT_R
      b <- as.integer(M[k, "b"])
      descr <- j == "J1" && r == "interieur"
      for (v in c("1", "3")) {
        p <- suppressWarnings(as.numeric(M[k, sprintf("p%s:%s", v, s)]))
        mes <- if (length(p)) mean(is.finite(p) & p < a) else NA_real_
        pre <- if (length(b)) mean(PI[[j]][[if (v == "1") "V1" else "V3a"]][[ia]][b, s]) else NA_real_
        ajouter_g1(j, "#175", if (v == "1") "V1" else "V3a", r, s, ia, mes, pre, length(b), e_star = !descr)
      }
    }
  }
}
G1 <- do.call(rbind, G1)
G1$ecart <- G1$predit - G1$mesure
# e* (annotation, L5) : ecart absolu maximal sur les cellules evaluables
# (n >= 100), hors cellules descriptives de #175 ; FAIT FOI pour A2. Le
# maximum litteral (toutes les cellules, n < 100 comprises) est rapporte.
max_ecart <- function(j, ia, evaluables) {
  x <- G1[G1$jeu == j & G1$ia == ia & G1$e_star & is.finite(G1$ecart) & (!evaluables | G1$n >= N_EVALUABLE), "ecart"]
  if (length(x)) max(abs(x)) else NA_real_
}
E_STAR <- vapply(c("J1", "J2"), function(j) vapply(IA, max_ecart, 1, j = j, evaluables = TRUE), numeric(2))
E_STAR_LIT <- vapply(c("J1", "J2"), function(j) vapply(IA, max_ecart, 1, j = j, evaluables = FALSE), numeric(2))
estar <- function(j, ia) E_STAR[[ia, if (j == "J1") "J1" else "J2"]]

###############################################################################
#  CONDITIONS PREDITES (annotation du 09/10/2026, L0 a L3, L6, L9, L10, L13)
###############################################################################
# Au point (L0) : comptes predits k = arrondi(n tau), IC de Clopper-Pearson
# sur (k, n) ; cote d'un IC : conservateur si sa borne haute est sous
# ref/2, liberal si sa borne basse depasse 3 ref/2. Echec franc : defaut au
# point ET defaut quand chaque grandeur (taux ou difference) est deplacee
# de e* dans le sens favorable, sans IC, pour tout etat plausible de V1.
ic_pred <- function(t, n) if (!is.finite(t) || n < 1) c(NA_real_, NA_real_) else ic_cp(round(n * t), n)
cote_ic <- function(ci, lo, hi) if (anyNA(ci)) NA_character_ else if (ci[2] < lo) "cons" else if (ci[1] > hi) "lib" else "aucun"
cote <- function(t, lo, hi, m) if (!is.finite(t)) NA_character_ else if (t < lo - m) "cons" else if (t > hi + m) "lib" else "aucun"
oppose <- function(s) if (s == "cons") "lib" else "cons"
defaut_ab <- function(t1, tv, lo, hi, e, n) {
  if (!is.finite(t1) || !is.finite(tv) || !is.finite(e)) return(c(point = NA, franc = NA))
  c1 <- ic_pred(t1, n)
  s1 <- cote_ic(c1, lo, hi); sv <- cote_ic(ic_pred(tv, n), lo, hi)
  pt <- if (s1 == "aucun") sv != "aucun" else sv == oppose(s1) || (s1 == "cons" && tv < c1[1]) || (s1 == "lib" && tv > c1[2])
  etats <- c(if (t1 >= lo - e && t1 <= hi + e) "aucun", if (t1 < lo + e) "cons", if (t1 > hi - e) "lib")
  svf <- cote(tv, lo, hi, e)
  dep <- all(vapply(etats, function(s) if (s == "aucun") svf != "aucun" else
    svf == oppose(s) || (s == "cons" && t1 - tv > e) || (s == "lib" && tv - t1 > e), logical(1)))
  c(point = pt, franc = pt && dep)
}
# McNemar predit (L10) : au point, decisions a B infini ; lecture robuste,
# comptes attendus sous independance des erreurs Monte-Carlo :
# n01 = arrondi somme pi_v (1 - pi_V1), n10 = arrondi somme pi_V1 (1 - pi_v).
mcn <- function(n01, n10) { n <- n01 + n10; c(n01 = n01, n10 = n10, p = if (n) stats::binom.test(n01, n, 0.5)$p.value else 1) }
famille_mcn <- function(j, v, ia, rows, stats_f) {
  pt <- t(vapply(stats_f, function(s) { dv <- DEC[[j]][[v]][[ia]][rows, s]; d1 <- DEC[[j]]$V1[[ia]][rows, s]
                                          mcn(sum(dv & !d1), sum(!dv & d1)) }, numeric(3)))
  ind <- t(vapply(stats_f, function(s) { pv <- PI[[j]][[v]][[ia]][rows, s]; p1 <- PI[[j]]$V1[[ia]][rows, s]
                                           mcn(round(sum(pv * (1 - p1))), round(sum(p1 * (1 - pv)))) }, numeric(3)))
  data.frame(stat = stats_f, n01 = pt[, "n01"], n10 = pt[, "n10"], p_holm = stats::p.adjust(pt[, "p"], "holm"),
             n01_i = ind[, "n01"], n10_i = ind[, "n10"], p_holm_i = stats::p.adjust(ind[, "p"], "holm"), stringsAsFactors = FALSE)
}
sig_sens <- function(mc, sens, lecture) {
  if (lecture == "point") mc$p_holm < NIVEAU_HOLM & (if (sens == "01") mc$n01 > mc$n10 else mc$n10 > mc$n01)
  else mc$p_holm_i < NIVEAU_HOLM & (if (sens == "01") mc$n01_i > mc$n10_i else mc$n10_i > mc$n01_i)
}
txt_mcn <- function(mc, k) if (!any(k)) "aucune" else
  paste(sprintf("%s (point %d/%d, p Holm %s ; ind\u00e9pendance %d/%d, p Holm %s)", mc$stat[k], mc$n01[k], mc$n10[k],
                formatC(mc$p_holm[k], format = "g", digits = 3), mc$n01_i[k], mc$n10_i[k], formatC(mc$p_holm_i[k], format = "g", digits = 3)),
        collapse = " ; ")
COND <- list()
ajouter_cond <- function(cond, pop, ia, v, point, franc, detail)
  COND[[length(COND) + 1L]] <<- data.frame(cond = cond, pop = pop, ia = ia, variante = v, point = point, franc = franc,
                                            detail = detail, stringsAsFactors = FALSE)
# e* indisponible (aucune cellule evaluable de (g1), --R reduit ; constat m3
# de l'audit) : condition "non evaluable".
TXT_NE <- "e* indisponible : aucune cellule \u00e9valuable (n \u2265 100) dans (g1)"
non_evaluable_estar <- function(conds, pop, ia) for (v in VARIANTES_CRIT) for (cn in conds) ajouter_cond(cn, pop, ia, v, "non \u00e9valuable", "\u2014", TXT_NE)
lib_cel <- function(s, r = NULL) if (is.null(r)) s else sprintf("%s (%s)", s, LIB_REG[[r]])
# Bande non applicable quand la reference est inferieure a 2/n (regle de
# lecture de #166, annotation L6) : la cellule n'entre pas en defaut de C1a
# ou de C2b (Cox-Stuart).
txt_bna <- function(bna) if (length(bna)) sprintf(" ; bande non applicable (r\u00e9f. < 2/n, r\u00e8gle de #166, L6) : %s", paste(bna, collapse = ", ")) else ""
# V3a et lois discretes (L13) : descriptives dans C1a et C2b.
DISCRETES <- names(LOI_STAT)
txt_desc <- function(v) if (v == "V3a") sprintf(" ; descriptives pour V3a (loi discr\u00e8te, L13) : %s", paste(DISCRETES, collapse = ", ")) else ""
liste_cel <- function(x, n = 8) if (!length(x)) "aucune" else paste(c(utils::head(x, n), if (length(x) > n) sprintf("... (%d en tout)", length(x))), collapse = " ; ")
JEUX_CRIT <- c("J1", "J2", "J3")
lib_pop <- function(j) if (j == "J1") "J1 (bords)" else if (j %in% names(LIB_SCEN)) sprintf("%s (%s)", j, LIB_SCEN[[j]]) else j
# Cellules a defaut (a) / (b) d'un ensemble de statistiques.
cellules_ab <- function(j, v, ia, rows, stats_c) {
  e <- estar(j, ia); n <- sum(rows)
  t1 <- taux_pop(j, "V1", ia, rows); tv <- taux_pop(j, v, ia, rows)
  bna <- stats_c[REF[stats_c, ia] < 2 / n]
  desc <- if (v == "V3a") intersect(stats_c, DISCRETES) else character(0)
  ev <- setdiff(stats_c, c(bna, desc))
  ab <- if (length(ev)) t(vapply(ev, function(s) defaut_ab(t1[[s]], tv[[s]], REF[s, ia] / 2, 3 * REF[s, ia] / 2, e, n), logical(2))) else
    matrix(logical(0), 0, 2, dimnames = list(NULL, c("point", "franc")))
  list(pt = ev[which(ab[, "point"])], fr = ev[which(ab[, "franc"])], bna = bna, desc = desc)
}
for (j in JEUX_CRIT) for (ia in IA) {
  e <- estar(j, ia); rows <- lignes(j); n <- sum(rows)
  if (!is.finite(e)) { non_evaluable_estar(c("C1a", "C1b"), lib_pop(j), ia); next }
  t1 <- taux_pop(j, "V1", ia, rows)
  a <- SEUILS[match(ia, IA)]
  for (v in VARIANTES_CRIT) {
    tv <- taux_pop(j, v, ia, rows)
    # C1a
    cab <- cellules_ab(j, v, ia, rows, STATS)
    ajouter_cond("C1a", lib_pop(j), ia, v, if (length(cab$pt)) "en d\u00e9faut" else "remplie", if (length(cab$fr)) "\u00e9chec franc" else "pas d'\u00e9chec franc",
                 sprintf("n = %d ; en d\u00e9faut au point : %s ; \u00e9chec franc : %s%s%s", n, liste_cel(cab$pt), liste_cel(cab$fr),
                         txt_bna(cab$bna), if (length(cab$desc)) txt_desc(v) else ""))
    # C1b, C1c
    mc <- famille_mcn(j, v, ia, rows, F_R)
    bas <- vapply(mc$stat, function(s) ic_pred(tv[[s]], n)[1], 1); haut <- vapply(mc$stat, function(s) ic_pred(tv[[s]], n)[2], 1)
    k_pt <- sig_sens(mc, "01", "point") & is.finite(bas) & bas > a
    k_fr <- k_pt & sig_sens(mc, "01", "indep") & tv[mc$stat] - a > e & tv[mc$stat] - t1[mc$stat] > e
    ajouter_cond("C1b", lib_pop(j), ia, v, if (any(k_pt)) "en d\u00e9faut" else "remplie", if (any(k_fr)) "\u00e9chec franc" else "pas d'\u00e9chec franc",
                 sprintf("McNemar n01 > n10 significatif apr\u00e8s Holm (22) : au point %d, sous ind\u00e9pendance %d ; en d\u00e9faut au point : %s ; \u00e9chec franc : %s",
                         sum(sig_sens(mc, "01", "point")), sum(sig_sens(mc, "01", "indep")), txt_mcn(mc, k_pt), liste_cel(mc$stat[k_fr])))
    k_c <- sig_sens(mc, "10", "point") & is.finite(haut) & haut < a
    ajouter_cond("C1c (descriptif)", lib_pop(j), ia, v, if (any(k_c)) "aggravation conservatrice" else "aucune", "\u2014",
                 sprintf("statistiques : %s", txt_mcn(mc, k_c)))
  }
}
# C2a : J2 et J3 interieur, alpha = 0,10, F_8 (L1 ; J3 : M5).
for (j in c("J2", "J3")) {
  ia <- "a10"; e <- estar(j, ia); rows <- lignes(j, "interieur"); n <- sum(rows)
  if (!is.finite(e)) { non_evaluable_estar("C2a", sprintf("%s int\u00e9rieur", j), ia); next }
  t1 <- taux_pop(j, "V1", ia, rows)
  for (v in VARIANTES_CRIT) {
    if (n < N_EVALUABLE) {
      ajouter_cond("C2a", sprintf("%s int\u00e9rieur", j), ia, v, "non \u00e9valuable", "\u2014", sprintf("n = %d < %d", n, N_EVALUABLE)); next
    }
    tv <- taux_pop(j, v, ia, rows)
    lo <- REF[F_8, ia] / 2; hi <- 3 * REF[F_8, ia] / 2
    hors1 <- vapply(seq_along(F_8), function(i) cote_ic(ic_pred(t1[[F_8[i]]], n), lo[i], hi[i]) != "aucun", logical(1))
    dans_v <- vapply(seq_along(F_8), function(i) cote_ic(ic_pred(tv[[F_8[i]]], n), lo[i], hi[i]) == "aucun", logical(1))
    n_pt <- sum(hors1 & dans_v); m3 <- sum(hors1)
    seuil_pt <- if (j == "J2") 5L else min(5L, m3)
    Rr <- t1[F_8] < lo - e | t1[F_8] > hi + e
    Pp <- t1[F_8] < lo + e | t1[F_8] > hi - e
    Vv <- tv[F_8] >= lo - e & tv[F_8] <= hi + e
    n_pv <- sum(Pp & Vv)
    seuil_fr <- if (j == "J2") 5L else min(5L, sum(Rr | (Pp & Vv)))
    defaut <- n_pt < seuil_pt
    franc <- defaut && n_pv < seuil_fr && (j == "J2" || any(Rr | (Pp & Vv)))
    ajouter_cond("C2a", sprintf("%s int\u00e9rieur", j), ia, v, if (defaut) "en d\u00e9faut" else "remplie",
                 if (franc) "\u00e9chec franc" else "pas d'\u00e9chec franc",
                 sprintf("n = %d ; corrig\u00e9es au point (IC) : %d (%s), seuil %d%s ; \u00e0 e* : |P \u2229 V| = %d (%s), seuil %d%s",
                         n, n_pt, liste_cel(F_8[hors1 & dans_v]), seuil_pt, if (j == "J3") sprintf(" (m3 = %d)", m3) else "",
                         n_pv, liste_cel(F_8[Pp & Vv]), seuil_fr, if (j == "J3") sprintf(" (|R \u222a (P \u2229 V)| = %d)", sum(Rr | (Pp & Vv))) else ""))
  }
}
# C2b : par cellule (jeu, regime) evaluable, F_R, deux seuils.
CEL_C2B <- list(J1 = c("bord0", "bord1"), J2 = REG, J3 = REG)
for (j in names(CEL_C2B)) for (r in CEL_C2B[[j]]) for (ia in IA) {
  rows <- lignes(j, r); pop <- sprintf("%s %s", j, LIB_REG[[r]])
  if (!is.finite(estar(j, ia))) { non_evaluable_estar("C2b", pop, ia); next }
  for (v in VARIANTES_CRIT) {
    if (sum(rows) < N_EVALUABLE) {
      ajouter_cond("C2b", pop, ia, v, "non \u00e9valuable", "\u2014", sprintf("n = %d < %d", sum(rows), N_EVALUABLE)); next
    }
    cab <- cellules_ab(j, v, ia, rows, F_R)
    ajouter_cond("C2b", pop, ia, v, if (length(cab$pt)) "en d\u00e9faut" else "remplie", if (length(cab$fr)) "\u00e9chec franc" else "pas d'\u00e9chec franc",
                 sprintf("n = %d ; en d\u00e9faut au point : %s ; \u00e9chec franc : %s%s%s", sum(rows), liste_cel(cab$pt), liste_cel(cab$fr),
                         txt_bna(cab$bna), if (length(cab$desc)) txt_desc(v) else ""))
  }
}
# C3 : p absentes predites (B effectif predit < 50).
for (j in JEUX_CRIT) {
  rows <- lignes(j); a1 <- absentes(POP[[j]], "V1")
  e <- max(estar(j, "a10"), estar(j, "a05"))
  if (!is.finite(e)) { non_evaluable_estar("C3", lib_pop(j), "\u2014"); next }
  for (v in VARIANTES_CRIT) {
    av <- absentes(POP[[j]], v)
    part <- if (any(rows)) mean(apply((av & !a1)[rows, F_R, drop = FALSE], 1, any)) else NA_real_
    ajouter_cond("C3", lib_pop(j), "\u2014", v, if (is.na(part)) "non \u00e9valuable" else if (part > SEUIL_C3) "en d\u00e9faut" else "remplie",
                 if (isTRUE(part > SEUIL_C3 + e)) "\u00e9chec franc" else "pas d'\u00e9chec franc",
                 sprintf("part pr\u00e9dite : %s (seuil %s ; e* = %s)", num(part, 4), num(SEUIL_C3, 2), num(e, 4)))
  }
}
# C4 : puissance (alternatives), pi a B fini.
PUIS <- list()
for (sc in SCENARIOS$code) for (ia in IA) {
  e <- estar("J2", ia); rows <- lignes(sc, "tout")
  if (!is.finite(e)) { non_evaluable_estar("C4a", lib_pop(sc), ia); next }
  p1 <- taux_pop(sc, "V1", ia, rows)
  for (v in VARIANTES_CRIT) {
    pv <- taux_pop(sc, v, ia, rows)
    mc <- famille_mcn(sc, v, ia, rows, F_R)
    k_pt <- sig_sens(mc, "10", "point")
    k_fr <- k_pt & sig_sens(mc, "10", "indep") & p1[mc$stat] - pv[mc$stat] > e
    ajouter_cond("C4a", lib_pop(sc), ia, v, if (any(k_pt)) "en d\u00e9faut" else "remplie", if (any(k_fr)) "\u00e9chec franc" else "pas d'\u00e9chec franc",
                 sprintf("perte maximale pr\u00e9dite (V1 \u2212 variante, F_R) : %s ; en d\u00e9faut au point : %s ; \u00e9chec franc : %s",
                         num(max(p1[F_R] - pv[F_R]), 4), txt_mcn(mc, k_pt), liste_cel(mc$stat[k_fr])))
    PUIS[[length(PUIS) + 1L]] <- list(sc = sc, ia = ia, v = v, perte_max = max(p1[F_R] - pv[F_R]))
  }
}
C4B <- list()
for (v in VARIANTES_CRIT) {
  e <- estar("J2", "a10"); dec <- dec_pt <- character(0); gains <- c()
  if (!is.finite(e)) { C4B[[v]] <- list(decelable = FALSE, gmax = NA_real_)
    ajouter_cond("C4b", "P (6 sc\u00e9narios, \u03b4\u0302* int\u00e9rieur)", "a10", v, "non \u00e9valuable", "\u2014", TXT_NE); next }
  for (sc in SCENARIOS$code) {
    cib <- CIBLES[[SCENARIOS$famille[SCENARIOS$code == sc]]]
    rows <- lignes(sc, "interieur")
    if (!any(rows)) next
    mc <- famille_mcn(sc, v, "a10", rows, cib)
    g <- taux_pop(sc, v, "a10", rows)[cib] - taux_pop(sc, "V1", "a10", rows)[cib]
    gains <- c(gains, stats::setNames(g, paste(sc, cib)))
    k_p <- sig_sens(mc, "01", "point"); k_d <- k_p & sig_sens(mc, "01", "indep")
    if (any(k_p)) dec_pt <- c(dec_pt, paste(sc, mc$stat[k_p]))
    if (any(k_d)) dec <- c(dec, paste(sc, mc$stat[k_d]))
  }
  gmax <- if (length(gains)) max(gains) else NA_real_
  C4B[[v]] <- list(decelable = length(dec) > 0, gmax = gmax)
  ajouter_cond("C4b", "P (6 sc\u00e9narios, \u03b4\u0302* int\u00e9rieur)", "a10", v, if (is.na(gmax)) "non \u00e9valuable" else if (length(dec)) "remplie" else "en d\u00e9faut",
               if (!length(dec) && isTRUE(gmax < -e)) "\u00e9chec franc" else "pas d'\u00e9chec franc",
               sprintf("gain d\u00e9celable sous les deux lectures (L10) : %s ; au point seulement : %s ; gain maximal pr\u00e9dit : %s (%s)",
                       liste_cel(dec), liste_cel(setdiff(dec_pt, dec)), num(gmax, 4), if (length(gains)) names(gains)[which.max(gains)] else "\u2014"))
}
COND <- do.call(rbind, COND)

###############################################################################
#  SORTIE
###############################################################################
lib_ia <- function(ia) ifelse(ia == "a10", "0,10", ifelse(ia == "a05", "0,05", ia))
PAR <- sprintf("M=%d;noeuds=%s;R=%d;R_P=%d;graine_jeux=%.0f;graine_grille=%.0f+100p+i;graine_P=%.0f+s;B=%d;B_max=%d;methode=%s;coeurs=%d",
               OPT_M, paste(NOEUDS, collapse = ","), OPT_R, OPT_RP, GRAINE_JEUX, GRAINE_GRILLE, GRAINE_P, B_BOOT, B_MAX, METHODE, OPT_COEURS)
duree_noeuds <- sum(vapply(NOEUD_RES, `[[`, 1, "duree"))
n_tir <- length(NOEUD_RES) * OPT_M
duree_ver <- sum(vapply(POP[names(PROFILS)], `[[`, 1, "duree")); n_ver <- 3L * OPT_R
duree_alt <- sum(vapply(POP[SCENARIOS$code], `[[`, 1, "duree")); n_alt <- nrow(SCENARIOS) * OPT_RP
cpu_complet <- duree_noeuds / n_tir * 36 * M_SPEC + duree_ver / n_ver * 3 * R_SPEC + duree_alt / n_alt * 6 * RP_SPEC
TXT_DUREE <- sprintf(paste("couche de r\u00e9f\u00e9rence %.0f s (%d tirages, %s ms par tirage) ; couche v\u00e9rit\u00e9 %.0f s (%d r\u00e9plications, %s ms par r\u00e9plication) ;",
                           "alternatives %.0f s (%d r\u00e9plications, %s ms par r\u00e9plication) ; CPU cumul\u00e9 des t\u00e2ches %.0f s, horloge %.0f s sur %d c\u0153ur(s) ;",
                           "extrapolation aux param\u00e8tres de la sp\u00e9cification (M = %d, R = %d, R_P = %d) : %.0f s de CPU (%s h)"),
                     duree_noeuds, n_tir, num(1000 * duree_noeuds / n_tir, 2), duree_ver, n_ver, num(1000 * duree_ver / n_ver, 1),
                     duree_alt, n_alt, num(1000 * duree_alt / n_alt, 1), duree_noeuds + duree_ver + duree_alt, DUREE_HORLOGE, OPT_COEURS,
                     M_SPEC, R_SPEC, RP_SPEC, cpu_complet, num(cpu_complet / 3600, 2))

# Valeurs brutes (annotation, L12) : construites avant le T0, qui cite leur
# md5 et leur taille ; fichier temporaire ecrit par ecrire(), copie tel quel.
fmt <- function(x, f) ifelse(is.finite(x), sprintf(f, x), "NA")
ecrire <- function(f, lignes) { con <- file(f, open = "wb"); writeLines(enc2utf8(lignes), con, useBytes = TRUE); close(con) }
BRUT <- c(paste(c("couche", "jeu", "b", "regime", "delta", "q", as.vector(t(outer(STATS, c("p1", "p3"), function(s, p) paste0(p, ":", s))))),
                collapse = "\t"),
          unlist(lapply(names(POP), function(j) {
            D <- POP[[j]]; couche <- if (j %in% names(PROFILS)) "verite" else "alternative"
            vapply(seq_along(D$b), function(k) paste(c(couche, j, D$b[k], D$regime[k], fmt(D$delta[k], "%.17g"), fmt(D$q[k], "%.17g"),
                                                       as.vector(rbind(fmt(D$P1[k, ], "%.10g"), fmt(D$P3[k, ], "%.10g")))), collapse = "\t"), "")
          })))
F_BRUT_TMP <- tempfile("grille_brut_", fileext = ".tsv")
ecrire(F_BRUT_TMP, BRUT)
MD5_BRUT <- md5_fichier(F_BRUT_TMP); TAILLE_BRUT <- file.size(F_BRUT_TMP)

CTX_LIB <- c(
  "Commit",
  "Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)",
  "Empreintes md5 du code ex\u00e9cut\u00e9",
  "(g5) Empreinte sans commentaires de R/engine.R (#231)",
  "G\u00e9n\u00e9rateur",
  "Param\u00e8tres",
  "Mod\u00e8les et couche de r\u00e9f\u00e9rence",
  "Graines",
  "Jeux des sc\u00e9narios de P (L8)",
  "Sources",
  "Valeurs brutes de la grille (L12)",
  "Dur\u00e9e")
CTX <- stats::setNames(c(
  COMMIT,
  plateforme_calcul(),
  EMPREINTES,
  sprintf("%s (md5 du fichier entier %s) ; doit \u00eatre celle de l'\u00e9tape 6", EMPREINTE_SC, MD5_MOTEUR),
  paste(ENGINE_RNG_KIND, collapse = ", "),
  sprintf("M = %d jeux par n\u0153ud%s ; %d n\u0153uds \u03b4 = %s ; R = %d r\u00e9plications par jeu (couche v\u00e9rit\u00e9)%s ; R_P = %d par sc\u00e9nario%s ; B = %d, B_max = %d, B_MIN_DEGENERESCENCE = %d ; TOL_DELTA_BORD = %g",
          OPT_M, if (OPT_M != M_SPEC) " (R\u00c9DUIT)" else "", length(NOEUDS), paste(vapply(NOEUDS, num, "", d = 2), collapse = " ; "),
          OPT_R, if (OPT_R != R_SPEC) " (R\u00c9DUIT)" else "", OPT_RP, if (OPT_RP != RP_SPEC) " (R\u00c9DUIT)" else "",
          B_BOOT, B_MAX, B_MIN_DEGENERESCENCE, TOL_DELTA_BORD),
  paste(c(
    vapply(c("J1", "J2"), function(j) sprintf("%s : usp_ajuster() sur %s, \u03b4\u0302 = %.6g, \u03b3\u0302 = \u03b3_ref = %.6g, \u03b2\u0302 = %.6g, \u03c3\u0302 = %.6g", j, JEUX[[j]]$libelle,
                                              FIT0[[j]]$delta, FIT0[[j]]$gamma, FIT0[[j]]$beta, FIT0[[j]]$sigma), ""),
    sprintf("J3 : FIT0_J3 synth\u00e9tique, x3 = (%s), \u03b40 = %s, \u03b20 = %s, \u03b30 = \u03b3_ref = %.6f (\u03c30 = %s), aucun jeu observ\u00e9",
            paste(format(X3), collapse = " ; "), format(DELTA3), format(BETA3), GAMMA3, format(SIGMA3))), collapse = " ; "),
  sprintf("jeux de J1, J2, J3 : un flux sous %.0f (expression YSIM de #72) ; n\u0153ud i du profil p (J1 : 1, J2 : 2, J3 : 3) : %.0f + 100 p + i ; sc\u00e9nario s de P : %.0f + s (s = 1 \u00e0 6 ; 7 \u00e0 9 r\u00e9serv\u00e9es \u00e0 l'option P-J3)",
          GRAINE_JEUX, GRAINE_GRILLE, GRAINE_P),
  paste(c(sprintf(paste("tir\u00e9s \u00e0 R_P = %d complet, %d premi\u00e8res lignes utilis\u00e9es ; md5 (valeurs en %%.17g, une par ligne, matrice lue ligne",
                        "par ligne) des tirages bruts \u03b5 (rnorm, ou rchisq avant la transformation de A), des t* (C) et des jeux Y"), RP_SPEC, OPT_RP),
          vapply(SCENARIOS$code, function(s) sprintf("%s : md5 \u03b5 %s%s, md5 Y %s", s, YALT[[s]]$md5_E,
                                                     if (is.null(YALT[[s]]$md5_ts)) "" else sprintf(", md5 t* %s", YALT[[s]]$md5_ts),
                                                     YALT[[s]]$md5_Y), "")), collapse = " ; "),
  paste(vapply(names(SOURCES), function(k) sprintf("%s (md5 %s, suivi par git : %s)", chemin_cite(SOURCES[[k]]),
                                                 md5_fichier(SOURCES[[k]]), suivi_git(SOURCES[[k]])), ""), collapse = " ; "),
  sprintf("%s : md5 %s, %.0f octets, %d lignes de r\u00e9plications (versionn\u00e9es sur la branche de sauvegarde, sauvegarde/issue229/, en attendant l'accord du mainteneur)",
          NOMS_SORTIE[["brut"]], MD5_BRUT, TAILLE_BRUT, length(BRUT) - 1L),
  TXT_DUREE), CTX_LIB)
SUIVI_SRC <- vapply(SOURCES, suivi_git, "")

S <- c(sprintf("## Grille semi-analytique de la mesure #229 : p-value Monte-Carlo conditionnelle au r\u00e9gime de \u03b4\u0302, T = 8 (issue #229, \u00e9tape 4)"), "",
       sprintf("Param\u00e8tres : %s", PAR), "",
       "### T0 -- provenance", "",
       entete_md(c("Grandeur", "Valeur")),
       vapply(names(CTX), function(k) ligne_md(k, CTX[[k]]), ""),
       ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", if (length(INTEGRITE)) "\u00c9CHEC" else "OK"), "")
if (!PARAMETRES_SPEC) S <- c(S, "**Param\u00e8tres R\u00c9DUITS (test de fum\u00e9e) : valeurs sans port\u00e9e, non versionnables.**", "")
S <- c(S, "### Aide \u00e0 la lecture", "",
       paste("Statut : **pr\u00e9diction semi-analytique**, pas une mesure. La loi de r\u00e9f\u00e9rence de la r\u00e9plication b est lue dans une grille en \u03b4",
             "\u00e0 \u03b3 fix\u00e9 (\u03b3_ref du jeu), sous l'approximation de la consultation (sp\u00e9cification, par. 4.1, non v\u00e9rifi\u00e9e) selon laquelle,",
             "\u00e0 petit \u03c3, la nuisance effective est \u03b4 seule. Queues empiriques de M tirages par n\u0153ud, interpol\u00e9es lin\u00e9airement en \u03b4",
             "(n\u0153ud exact aux bords) ; loi conditionnelle au r\u00e9gime pond\u00e9r\u00e9e par w_k q_k(r) (annotation du 09/10/2026, L7)."), "",
       paste("**Valeur de B (annotation, L4).** Les p tildes sont \u00e0 B infini, et T1, T1 bis et (g2) gardent des colonnes \u00e0 B infini. Toute",
             "comparaison \u00e0 une mesure ou \u00e0 une r\u00e9f\u00e9rence ((g1), (g3), C1 \u00e0 C4, ligne des intensit\u00e9s de A2) porte sur la probabilit\u00e9 de",
             "rejet pr\u00e9dite \u03c0 = P(p_mc < \u03b1 | hi, lo) \u00e0 B tirages (999 pour V1, arrondi(999 q\u0302) pour V3a, min(999, arrondi(25 000 q\u0302))",
             "pour V3b, V3h comme V3b \u00e0 l'int\u00e9rieur et comme V1 aux bords) ; p absente si ce B est inf\u00e9rieur \u00e0 50."), "",
       paste("**Lecture d'une condition (L0).** Au point : texte du par. 2.2 sur les taux pr\u00e9dits, avec l'IC de Clopper-Pearson des",
             "comptes pr\u00e9dits arrondi(n \u03c0). \u00c9chec franc (par. 4.4) : d\u00e9faut au point, qui persiste quand chaque grandeur pr\u00e9dite (taux ou",
             "diff\u00e9rence) est d\u00e9plac\u00e9e de e* dans le sens favorable \u00e0 la variante, sans IC, pour tout \u00e9tat plausible de V1.",
             "e* : \u00e9cart absolu maximal de (g1) sur les cellules \u00e9valuables (n \u2265 100, L5), qui fait foi ; le maximum litt\u00e9ral est rapport\u00e9."), "",
       paste("**McNemar pr\u00e9dit (L10).** Au point : d\u00e9cisions \u00e0 B infini. Lecture robuste : comptes attendus sous ind\u00e9pendance des",
             "erreurs Monte-Carlo, n01 = arrondi \u03a3 \u03c0_v (1 \u2212 \u03c0_V1), n10 = arrondi \u03a3 \u03c0_V1 (1 \u2212 \u03c0_v). Un McNemar qui fait \u00e9chouer une",
             "condition (\u00e9chec franc de C1b, C4a) ou r\u00e9ussir C4b ne compte que s'il est significatif sous les deux lectures."), "",
       paste("La grille **pr\u00e9dit et ne d\u00e9cide pas** : la table de la r\u00e8gle A2 indique la ligne d\u00e9clench\u00e9e et la recommandation",
             "d'actuary qui lui correspond, **sans conclure** (application sous d\u00e9l\u00e9gation : annotation, L14)."), "",
       "**Crit\u00e8re de la sp\u00e9cification (par. 2.1 et 2.2), report\u00e9 sans modification :**", "",
       paste(">", TEXTE_CRITERE_229), "",
       "**R\u00e8gle A2 (par. 4.4), report\u00e9e sans modification :**", "",
       paste(">", TEXTE_REGLE_A2), "")

# Regimes par noeud et par profil.
S <- c(S, "### Couche de r\u00e9f\u00e9rence : probabilit\u00e9s des r\u00e9gimes par n\u0153ud et par profil", "",
       entete_md(c("Profil", "\u03b4 (n\u0153ud)", "graine", "retenus", "\u00e9cart\u00e9s (r\u00e9ajustement ; statistiques)",
                   "q(\u03b4\u0302* = 0)", "q(int\u00e9rieur)", "q(\u03b4\u0302* = 1)", "dur\u00e9e (s)")))
for (j in names(PROFILS)) for (nd in PREP[[j]])
  S <- c(S, ligne_md(j, num(nd$delta, 2), sprintf("%.0f", nd$graine), nd$n, sprintf("%d ; %d", nd$ech[["rapide"]], nd$ech[["stats"]]),
                     num(nd$q[["bord0"]], 4), num(nd$q[["interieur"]], 4), num(nd$q[["bord1"]], 4), num(nd$duree, 1)))
S <- c(S, "")

# Validation (g1) a (g4).
S <- c(S, "### Validation de la grille", "",
       paste("**(g1) et (g3) -- \u00e9carts pr\u00e9dit (\u03c0 \u00e0 B = 999 ; V3a : arrondi(999 q\u0302)) \u2212 mesur\u00e9 et marge e*** (J3 et la partie P",
             "reprennent la marge de J2 ; e* fait foi, L5) :"), "",
       entete_md(c("Jeu", "Seuil", "cellules (marge)", "dont \u00e9valuables (n \u2265 100)", "\u00e9cart absolu moyen (\u00e9valuables)", "**e*** (\u00e9valuables, fait foi)",
                   "cellule du maximum (\u00e9valuables)", "maximum litt\u00e9ral (toutes cellules)", "hors tol\u00e9rance (e* > 0,05 sur J2)")))
for (j in c("J1", "J2")) for (ia in IA) {
  x <- G1[G1$jeu == j & G1$ia == ia & G1$e_star & is.finite(G1$ecart), ]
  ev <- x[x$n >= N_EVALUABLE, ]
  im <- which.max(abs(ev$ecart))
  S <- c(S, ligne_md(j, lib_ia(ia), nrow(x), nrow(ev), if (nrow(ev)) num(mean(abs(ev$ecart)), 4) else "\u2014", num(E_STAR[[ia, j]], 4),
                     if (length(im)) sprintf("%s %s %s (%s ; n = %d)", ev$source[im], ev$cellule[im], lib_cel(ev$stat[im], if (ev$regime[im] %in% REG) ev$regime[im]),
                                            num(ev$ecart[im], 4), ev$n[im]) else "\u2014",
                     num(E_STAR_LIT[[ia, j]], 4),
                     if (j == "J2") (if (isTRUE(E_STAR[[ia, j]] > TOL_ESTAR)) "**oui**" else "non") else "\u2014"))
}
S <- c(S, "", "D\u00e9tail (g1), cellules de #221 (taux sur les p d\u00e9finies ; pr\u00e9dit : \u03c0 de V1 \u00e0 B = 999) :", "",
       entete_md(c("Jeu", "Statistique", "R\u00e9gime", "n", "mesur\u00e9 0,10", "pr\u00e9dit 0,10", "\u00e9cart 0,10", "mesur\u00e9 0,05", "pr\u00e9dit 0,05", "\u00e9cart 0,05")))
for (j in c("J1", "J2")) for (s in STATS) for (r in c("tout", REG)) {
  x <- G1[G1$jeu == j & G1$source == "#221" & G1$stat == s & G1$regime == r, ]
  a <- x[x$ia == "a10", ]; b <- x[x$ia == "a05", ]
  S <- c(S, ligne_md(j, s, if (r == "tout") "tous (T1)" else LIB_REG[[r]], a$n, num(a$mesure, 4), num(a$predit, 4), num(a$ecart, 4),
                     num(b$mesure, 4), num(b$predit, 4), num(b$ecart, 4)))
}
S <- c(S, "", "D\u00e9tail (g1), cellules de #175 (taux sur les rejou\u00e9es, p absente = non-rejet ; J1 int\u00e9rieur : descriptif, hors marge) :", "",
       entete_md(c("Jeu", "Cellule", "Variante", "n", "mesur\u00e9 0,10", "pr\u00e9dit 0,10", "\u00e9cart 0,10", "mesur\u00e9 0,05", "pr\u00e9dit 0,05", "\u00e9cart 0,05", "dans e*")))
for (j in c("J2", "J1")) for (i in seq_len(nrow(CEL175[[j]]))) for (v in c("V1", "V3a")) {
  r <- CEL175[[j]][i, 1]; s <- CEL175[[j]][i, 2]
  x <- G1[G1$jeu == j & G1$source == "#175" & G1$stat == s & G1$regime == r & G1$cellule == v, ]
  a <- x[x$ia == "a10", ]; b <- x[x$ia == "a05", ]
  S <- c(S, ligne_md(j, lib_cel(s, r), v, a$n, num(a$mesure, 4), num(a$predit, 4), num(a$ecart, 4), num(b$mesure, 4), num(b$predit, 4),
                     num(b$ecart, 4), if (!a$e_star) "non (descriptif)" else if (a$n >= N_EVALUABLE) "oui" else "non (n < 100)"))
}
# (g2)
S <- c(S, "", "**(g2) -- concordance appari\u00e9e des d\u00e9cisions \u00e0 B infini** (paires o\u00f9 les deux p sont d\u00e9finies ; n01 : la grille rejette, la mesure non) :", "",
       entete_md(c("Jeu", "Comparaison", "Seuil", "paires", "concordance", "n01", "n10", "concordance minimale par statistique")))
for (j in c("J1", "J2")) for (ia in IA) {
  a <- SEUILS[match(ia, IA)]; R <- seq_len(OPT_R)
  pm <- BRUT221[[j]]$p[R, , drop = FALSE]; pp <- POP[[j]]$P1
  ok <- is.finite(pm) & is.finite(pp); dm <- pm < a; dp <- pp < a
  conc_s <- vapply(STATS, function(s) if (any(ok[, s])) mean(dm[ok[, s], s] == dp[ok[, s], s]) else NA_real_, 1)
  S <- c(S, ligne_md(j, "p1 tilde contre p_mc de #221", lib_ia(ia), sum(ok), num(mean(dm[ok] == dp[ok]), 4),
                     sum(dp[ok] & !dm[ok]), sum(!dp[ok] & dm[ok]), sprintf("%s (%s)", num(min(conc_s, na.rm = TRUE), 4), STATS[which.min(conc_s)])))
}
for (j in c("J2", "J1")) for (ia in IA) {
  a <- SEUILS[match(ia, IA)]; M <- BRUT175$M; tot <- 0; ag <- 0; n01 <- 0; n10 <- 0
  for (i in seq_len(nrow(CEL175[[j]]))) {
    r <- CEL175[[j]][i, 1]; s <- CEL175[[j]][i, 2]
    k <- M[, "jeu"] == j & M[, "statut"] == "rejouee" & M[, "regime"] == r & as.integer(M[, "b"]) <= OPT_R
    b <- as.integer(M[k, "b"]); p3 <- suppressWarnings(as.numeric(M[k, paste0("p3:", s)]))
    dm <- is.finite(p3) & p3 < a; dp <- DEC[[j]]$V3a[[ia]][b, s]
    tot <- tot + length(b); ag <- ag + sum(dm == dp); n01 <- n01 + sum(dp & !dm); n10 <- n10 + sum(!dp & dm)
  }
  S <- c(S, ligne_md(j, "V3a pr\u00e9dite contre p3 de #175 (p absente = non-rejet)", lib_ia(ia), tot, num(if (tot) ag / tot else NA, 4), n01, n10, "\u2014"))
}
# (g4)
S <- c(S, "", "**(g4) -- r\u00e9gimes de J3 sur la couche v\u00e9rit\u00e9** (IC de Clopper-Pearson \u00e0 95 %) :", "",
       entete_md(c("R\u00e9gime", "k", "n", "proportion", "IC 95 %")))
rv <- POP$J3$regime; nv <- sum(rv != "ecartee")
for (r in REG) S <- c(S, ligne_md(LIB_REG[[r]], sum(rv == r), nv, num(sum(rv == r) / nv, 4), txt_ic(ic_cp(sum(rv == r), nv))))
S <- c(S, ligne_md("\u00e9cart\u00e9es (refus de #188 ou erreur)", sum(rv == "ecartee"), length(rv), "\u2014", "\u2014"), "",
       sprintf("**(g5)** empreinte sans commentaires de R/engine.R : %s (md5 du fichier entier %s) ; \u00e0 comparer \u00e0 celle de l'\u00e9tape 6.", EMPREINTE_SC, MD5_MOTEUR), "")

# T1 et T1 bis predits.
S <- c(S, "### T1 pr\u00e9dit -- taux marginaux de rejet (\u03c0 \u00e0 B fini ; colonnes \u221e : B infini ; J1 : r\u00e9plications \u00e0 \u03b4\u0302* au bord ; p absente = non-rejet)", "",
       entete_md(c("Jeu", "Statistique (sens)", "famille", "n", "r\u00e9f. 0,10", "V1", "V3a", "V3b", "V3h", "V1 \u221e", "V3b \u221e",
                   "r\u00e9f. 0,05", "V1", "V3a", "V3b", "V3h", "V1 \u221e", "V3b \u221e")))
fam_de <- function(s) paste(c(if (s %in% F_T) "F_T" else "F_R", if (s %in% F_8) "F_8"), collapse = ", ")
for (j in JEUX_CRIT) {
  rows <- lignes(j)
  tx <- lapply(IA, function(ia) vapply(VARIANTES, function(v) taux_pop(j, v, ia, rows), numeric(NS)))
  ti <- lapply(IA, function(ia) vapply(c("V1", "V3b"), function(v) taux_inf(j, v, ia, rows), numeric(NS)))
  for (s in STATS) {
    col <- function(i) c(num(REF[s, i], 4), vapply(VARIANTES, function(v) num(tx[[i]][s, v], 4), ""), vapply(c("V1", "V3b"), function(v) num(ti[[i]][s, v], 4), ""))
    S <- c(S, ligne_md(lib_pop(j), sprintf("%s (%s)%s", s, QUEUE[[s]], if (s %in% DISCRETES) " \u2020" else ""), fam_de(s), sum(rows),
                       paste(col(1), collapse = " | "), paste(col(2), collapse = " | ")))
  }
}
S <- c(S, "", "\u2020 Loi de r\u00e9f\u00e9rence discr\u00e8te : r\u00e9f\u00e9rence = taille liss\u00e9e \u00e0 B = 999 (T0 des tableaux de #221).", "",
       "### T1 bis pr\u00e9dit -- taux par r\u00e9gime de \u03b4\u0302* (\u03c0 \u00e0 B fini ; \u221e : B infini ; V3h = V3b \u00e0 l'int\u00e9rieur, V1 aux bords)", "",
       entete_md(c("Jeu", "R\u00e9gime", "Statistique", "n", "\u00e9valuable", "V1 0,10", "V3a 0,10", "V3b 0,10", "V1 \u221e 0,10", "V3b \u221e 0,10",
                   "V1 0,05", "V3a 0,05", "V3b 0,05", "V1 \u221e 0,05", "V3b \u221e 0,05")))
for (j in JEUX_CRIT) for (r in REG) {
  rows <- lignes(j, r)
  tx <- lapply(IA, function(ia) vapply(c("V1", "V3a", "V3b"), function(v) taux_pop(j, v, ia, rows), numeric(NS)))
  ti <- lapply(IA, function(ia) vapply(c("V1", "V3b"), function(v) taux_inf(j, v, ia, rows), numeric(NS)))
  for (s in STATS) {
    col <- function(i) c(vapply(c("V1", "V3a", "V3b"), function(v) num(tx[[i]][s, v], 4), ""), vapply(c("V1", "V3b"), function(v) num(ti[[i]][s, v], 4), ""))
    S <- c(S, ligne_md(j, LIB_REG[[r]], s, sum(rows), if (sum(rows) >= N_EVALUABLE) "oui" else "non",
                       paste(col(1), collapse = " | "), paste(col(2), collapse = " | ")))
  }
}
S <- c(S, "")

# Conditions predites.
S <- c(S, "### Conditions C1 \u00e0 C4 pr\u00e9dites (avec la marge e*)", "",
       sprintf("Marges e* (cellules \u00e9valuables, L5) : J1 %s (0,10) et %s (0,05) ; J2, J3 et P %s (0,10) et %s (0,05).",
               num(E_STAR[["a10", "J1"]], 4), num(E_STAR[["a05", "J1"]], 4), num(E_STAR[["a10", "J2"]], 4), num(E_STAR[["a05", "J2"]], 4)), "",
       entete_md(c("Condition", "Population", "Seuil", "Variante", "pr\u00e9diction au point", "classe (par. 4.4)", "d\u00e9tail")))
for (i in seq_len(nrow(COND)))
  S <- c(S, ligne_md(COND$cond[i], COND$pop[i], lib_ia(COND$ia[i]), COND$variante[i], COND$point[i],
                     if (COND$franc[i] == "\u00e9chec franc") "**\u00e9chec franc**" else COND$franc[i], COND$detail[i]))
S <- c(S, "", "**C4c (descriptif) -- puissance pr\u00e9dite \u03c0 de l'ensemble cible, par r\u00e9gime de \u03b4\u0302*** (\u03b1 = 0,10 ; tous / \u03b4\u0302* = 0 / int\u00e9rieur / \u03b4\u0302* = 1) :", "",
       entete_md(c("Sc\u00e9nario", "Statistique", "n (tous ; 0 ; int. ; 1)", "V1", "V3a", "V3b", "V3h")))
for (sc in SCENARIOS$code) {
  cib <- CIBLES[[SCENARIOS$famille[SCENARIOS$code == sc]]]
  rs <- list(tout = lignes(sc, "tout"), bord0 = lignes(sc, "bord0"), interieur = lignes(sc, "interieur"), bord1 = lignes(sc, "bord1"))
  for (s in cib)
    S <- c(S, ligne_md(lib_pop(sc), s, paste(vapply(rs, sum, 1L), collapse = " ; "),
                       paste(vapply(VARIANTES, function(v) paste(vapply(rs, function(r) num(taux_pop(sc, v, "a10", r)[[s]], 3), ""), collapse = " ; "), ""),
                             collapse = " | ")))
}
S <- c(S, "", "**R\u00e9plications \u00e9cart\u00e9es par sc\u00e9nario de P** (refus de #188, erreur de usp_ajuster() ou des statistiques observ\u00e9es) :", "",
       entete_md(c("Sc\u00e9nario", "r\u00e9plications", "\u00e9cart\u00e9es", "dont refus de #188", "dont erreur de usp_ajuster()", "dont erreur des statistiques")))
for (sc in SCENARIOS$code) {
  m <- POP[[sc]]$motif
  S <- c(S, ligne_md(lib_pop(sc), length(m), sum(POP[[sc]]$regime == "ecartee"), sum(m == "refus"), sum(m == "ajustement"), sum(m == "statistiques")))
}
S <- c(S, "")

# Couts et p absentes predits.
S <- c(S, "### Co\u00fbts et p absentes pr\u00e9dits (V3b : tirages \u2248 min(999 / q\u0302, 25 000), 999 de V1 compris)", "",
       entete_md(c("Jeu", "R\u00e9gime", "n", "q\u0302 m\u00e9dian [min ; max]", "q observ\u00e9 m\u00e9dian (#175, m\u00eames r\u00e9plications)", "q\u0302 m\u00e9dian sur ces r\u00e9plications",
                   "tirages de V3b (moyenne)", "B_max atteint", "p absente pr\u00e9dite V3a (arrondi(999 q\u0302) < 50)",
                   "p absente pr\u00e9dite V3b (min(999, arrondi(25 000 q\u0302)) < 50)")))
for (j in JEUX_CRIT) for (r in REG) {
  rows <- lignes(j, r); q <- POP[[j]]$q[rows]
  if (!length(q)) next
  qo <- "\u2014"; qp <- "\u2014"
  if (j != "J3") {
    M <- BRUT175$M; k <- M[, "jeu"] == j & M[, "statut"] == "rejouee" & M[, "regime"] == r & as.integer(M[, "b"]) <= OPT_R
    if (any(k)) {
      dd <- matrix(as.numeric(M[k, c("dd_bord0", "dd_interieur", "dd_bord1")]), sum(k), 3, dimnames = list(NULL, REG))
      qo <- num(stats::median(dd[, r] / rowSums(dd)), 4); qp <- num(stats::median(POP[[j]]$q[as.integer(M[k, "b"])]), 4)
    }
  }
  tir <- pmin(ifelse(q > 0, B_BOOT / q, Inf), B_MAX)
  S <- c(S, ligne_md(j, LIB_REG[[r]], length(q), sprintf("%s [%s ; %s]", num(stats::median(q), 4), num(min(q), 4), num(max(q), 4)),
                     qo, qp, num(mean(tir), 0), num(mean(B_BOOT / q > B_MAX), 4), num(mean(round(B_BOOT * q) < B_MIN_DEGENERESCENCE), 4),
                     num(mean(pmin(B_BOOT, round(B_MAX * q)) < B_MIN_DEGENERESCENCE), 4)))
}
S <- c(S, "")

# Regle A2 (annotation, L2, L3, L14).
fr <- function(cond, v, pop = NULL) {
  x <- COND[COND$cond %in% cond & COND$variante == v & COND$franc == "\u00e9chec franc", , drop = FALSE]
  if (!is.null(pop)) x <- x[x$pop %in% pop, , drop = FALSE]
  x
}
cite <- function(x, avec_seuil = TRUE) paste(unique(trimws(paste(x$cond, x$pop, if (avec_seuil) lib_ia(x$ia) else ""))), collapse = " ; ")
oui_non <- function(x, avec_seuil = TRUE) if (nrow(x)) sprintf("**oui** (%s)", cite(x, avec_seuil)) else "non"
POP_INT <- sprintf("%s %s", c("J2", "J3"), LIB_REG[["interieur"]])
POP_BORDS <- c(sprintf("J1 %s", LIB_REG[c("bord0", "bord1")]), sprintf("%s %s", rep(c("J2", "J3"), each = 2), LIB_REG[c("bord0", "bord1")]))
lignes_a2 <- list()
for (v in VARIANTES_CRIT) {
  c1 <- fr(c("C1a", "C1b"), v); c3 <- fr("C3", v)
  c2_int <- rbind(fr("C2a", v), fr("C2b", v, POP_INT))
  c2_bords <- fr("C2b", v, POP_BORDS)
  c2_tout <- rbind(fr("C2a", v), fr("C2b", v))
  c4 <- rbind(fr("C4a", v), fr("C4b", v))
  pp <- Filter(function(p) p$v == v, PUIS)
  perte_ok <- length(pp) > 0L && all(vapply(pp, function(p) isTRUE(p$perte_max < -2 * E_STAR[[p$ia, "J2"]]), logical(1)))
  perte <- if (length(pp)) max(vapply(pp, `[[`, 1, "perte_max")) else NA_real_
  rempl <- all(COND$point[COND$cond %in% c("C4a", "C4b") & COND$variante == v] == "remplie")
  marge_ok <- rempl && C4B[[v]]$decelable && perte_ok && isTRUE(C4B[[v]]$gmax > 2 * E_STAR[["a10", "J2"]])
  aucun <- !nrow(rbind(c1, c2_tout, c3, c4))
  arret <- if (!nrow(c2_int)) "non" else if (v == "V3a")
    sprintf("**oui** pour V3a (%s) : profil D4 pr\u00e9dit pour V3a, la mesure se poursuit (ligne d'arr\u00eat r\u00e9serv\u00e9e \u00e0 V3b et V3h, L3)", cite(c2_int)) else
    oui_non(c2_int)
  ne_j2 <- anyNA(E_STAR[, "J2"])
  lignes_a2[[v]] <- if (ne_j2) c("non \u00e9valuable (e* de J2 indisponible : aucune cellule \u00e9valuable)",
                                 rep("non \u00e9valuable (e* indisponible : conditions non \u00e9valuables)", 6L)) else c(
    if (anyNA(E_STAR[, "J2"])) "non \u00e9valuable (e* de J2 indisponible : aucune cellule \u00e9valuable)" else
    if (any(E_STAR[, "J2"] > TOL_ESTAR)) sprintf("**oui** (e* de J2 : %s et %s)", num(E_STAR[1, "J2"], 4), num(E_STAR[2, "J2"], 4)) else
      sprintf("non (e* de J2 : %s et %s)", num(E_STAR[1, "J2"], 4), num(E_STAR[2, "J2"], 4)),
    arret,
    if (!nrow(c2_bords)) "non" else if (v == "V3h") sprintf("**oui** (%s) : V3h vaut V1 aux bords, \u00e0 examiner", cite(c2_bords)) else
      sprintf("**oui** (%s) : D4 pr\u00e9dit pour %s ; V3h non concern\u00e9e", cite(c2_bords), v),
    oui_non(c3, avec_seuil = FALSE),
    if (nrow(c1) && !nrow(rbind(c2_tout, c3, c4))) oui_non(c1) else if (nrow(c1)) "non (C1 en \u00e9chec franc, avec un autre \u00e9chec franc pour la m\u00eame variante)" else "non",
    paste0(oui_non(c4), sprintf(" ; C4b pr\u00e9dite d\u00e9celable sur J2 (deux lectures, L10) : %s", if (C4B[[v]]$decelable) "oui" else "non")),
    sprintf("%s (perte maximale pr\u00e9dite %s ; gain maximal pr\u00e9dit \u00e0 l'int\u00e9rieur %s ; 2 e* de J2 : %s et %s)",
            if (aucun && marge_ok) "**oui**" else "non", num(perte, 4), num(C4B[[v]]$gmax, 4),
            num(2 * E_STAR[1, "J2"], 4), num(2 * E_STAR[2, "J2"], 4)))
}
hors_bande <- vapply(SCENARIOS$code, function(sc) {
  cib <- CIBLES[[SCENARIOS$famille[SCENARIOS$code == sc]]]
  p <- taux_pop(sc, "V1", "a10", lignes(sc, "tout"))[cib]
  all(p < BANDE_PUISSANCE[1] | p > BANDE_PUISSANCE[2])
}, logical(1))
txt_bande <- sprintf("%s (sc\u00e9narios dont toute la cible a une puissance pr\u00e9dite \u03c0 de V1 hors de [0,2 ; 0,8] \u00e0 \u03b1 = 0,10, toutes r\u00e9plications : %s)",
                     if (any(hors_bande)) "**oui**" else "non", if (any(hors_bande)) paste(SCENARIOS$code[hors_bande], collapse = ", ") else "aucun")
LIB_A2 <- c("(g1) hors tol\u00e9rance : e* > 0,05 sur J2", "C2 en \u00e9chec franc (J2 ou J3 int\u00e9rieur)", NA_character_,
            "C3 en \u00e9chec franc sur un jeu", "C1 seule en \u00e9chec franc", "C4 en \u00e9chec franc (perte de puissance aux bords)",
            "Aucun \u00e9chec franc, C4 remplie avec une marge > 2 e*")
REC_A2 <- vapply(LIB_A2, function(l) {
  if (is.na(l)) return("Pas de ligne propre au par. 4.4 : profil D4 pr\u00e9dit pour la variante (L3), sans d\u00e9clencher la ligne d'arr\u00eat.")
  li <- TEXTE_REGLE_A2[startsWith(TEXTE_REGLE_A2, paste0("| ", l, " |"))]
  if (length(li) == 1L) sub(" \\|$", "", substring(li, nchar(paste0("| ", l, " | ")) + 1L)) else "\u2014"
}, "")
LIB_A2[3] <- "C2b en \u00e9chec franc aux bords (J1, J2, J3 ; L3)"
li_b <- TEXTE_REGLE_A2[startsWith(TEXTE_REGLE_A2, "| Puissance pr\u00e9dite de V1")]
REC_BANDE <- if (length(li_b) == 1L) sub(" \\|$", "", sub("^\\| [^|]* \\| ", "", li_b)) else "\u2014"
S <- c(S, "### R\u00e8gle A2 -- pr\u00e9dictions et recommandations correspondantes (sans conclure)", "",
       paste("Pour chaque ligne de la table du par. 4.4 : d\u00e9clench\u00e9e ou non par la pr\u00e9diction, pour V3b, V3a et V3h, et la",
             "recommandation d'actuary qui lui correspond (texte de la sp\u00e9cification). **La grille ne tranche pas.**"), "",
       paste("Ordre de lecture (annotation, L14) : la ligne \u00ab (g1) hors tol\u00e9rance \u00bb prime (la grille ne pr\u00e9dit plus) ; vient ensuite",
             "la ligne d'arr\u00eat, d\u00e9clench\u00e9e pour V3b et V3h (L3 ; d\u00e9clench\u00e9e pour V3a seule, elle signale un profil D4 de V3a et la",
             "mesure se poursuit) ; les autres lignes se cumulent. \u00ab C1 seule \u00bb s'entend sans autre \u00e9chec franc pour la m\u00eame variante.",
             "La ligne des intensit\u00e9s se lit par sc\u00e9nario, \u00e0 \u03b1 = 0,10, sur toutes les r\u00e9plications, avec \u03c0 de V1. Une recommandation",
             "d'arr\u00eat est une d\u00e9cision provisoire, r\u00e9visable par le mainteneur."), "",
       entete_md(c("Pr\u00e9diction (par. 4.4)", "V3b", "V3a", "V3h", "Recommandation d'actuary (sp\u00e9cification)")))
for (i in seq_along(LIB_A2))
  S <- c(S, ligne_md(LIB_A2[i], lignes_a2$V3b[i], lignes_a2$V3a[i], lignes_a2$V3h[i], REC_A2[[i]]))
S <- c(S, ligne_md("Puissance pr\u00e9dite de V1 hors de [0,2 ; 0,8] pour toute la cible d'une famille", txt_bande, "idem", "idem", REC_BANDE), "")

S <- c(S, "### Contr\u00f4les d'int\u00e9grit\u00e9", "", paste("-", CONTROLES), "",
       sprintf("Bilan : %s", if (length(INTEGRITE)) sprintf("\u00c9CHEC (%d contr\u00f4le(s))", length(INTEGRITE)) else "OK"), "")
ecrire_console(S)

# Ecriture : --ecrire, le tableau seul dans docs/tableaux/ (le brut va sur la
# branche de sauvegarde, L12 : --brut FICHIER hors du depot) ; --sortie, les
# deux fichiers dans DOSSIER.
copier_brut <- function(f) {
  if (!file.copy(F_BRUT_TMP, f, overwrite = FALSE) || !identical(md5_fichier(f), MD5_BRUT)) stop("valeurs brutes : copie refusee ou md5 different : ", f)
  message("\u00e9crit (valeurs brutes, md5 ", MD5_BRUT, ") : ", f)
}
if (OPT_ECRIRE) {
  nv1 <- c(motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, SCRIPT_72), "de l'ex\u00e9cution"),
           if (!identical(COMMIT, commit_depot(SCRIPT))) "commit chang\u00e9 pendant l'ex\u00e9cution",
           if (length(INTEGRITE)) "contr\u00f4les d'int\u00e9grit\u00e9 en \u00e9chec",
           if (any(SUIVI_SRC != "oui")) sprintf("sources non suivies par git : %s", paste(names(SUIVI_SRC)[SUIVI_SRC != "oui"], collapse = ", ")))
  if (length(nv1)) {
    message("--ecrire refuse : ", paste(nv1, collapse = " ; "))
    quit(status = 1L)
  }
  rem <- garde_ecrasement(CIBLES_ECRIRE, OPT_REMPLACER, RACINE)
  # Valeurs brutes copiees AVANT le tableau : un echec de copie interrompt
  # l'execution sans laisser dans le depot un tableau qui citerait le md5
  # d'un brut que rien ne conserve (L12).
  stopifnot(!is.na(OPT_BRUT))
  copier_brut(OPT_BRUT)
  ecrire(CIBLES_ECRIRE, inserer_t0(S, ligne_remplacement(rem, CIBLES_ECRIRE)))
  message("\u00e9crit : ", CIBLES_ECRIRE)
} else if (!is.na(OPT_SORTIE)) {
  ecrire(file.path(OPT_SORTIE, NOMS_SORTIE[["md"]]), S)
  message("\u00e9crit : ", file.path(OPT_SORTIE, NOMS_SORTIE[["md"]]))
  copier_brut(file.path(OPT_SORTIE, NOMS_SORTIE[["brut"]]))
}
if (!OPT_ECRIRE && !is.na(OPT_BRUT)) copier_brut(OPT_BRUT)
unlink(F_BRUT_TMP)
quit(status = if (length(INTEGRITE)) 1L else 0L)
