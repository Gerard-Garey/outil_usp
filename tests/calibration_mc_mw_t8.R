###############################################################################
#  tests/calibration_mc_mw_t8.R  --  NIVEAU REEL A T = 8 DES P-VALUES
#  MONTE-CARLO DE MERZ-WUTHRICH (issue #206, avec #119 a cout marginal)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils et tools, livres avec R : utils::sessionInfo(),
#  tools::md5sum()). Il ne modifie ni R/engine.R ni tests/reference/.
#  Sortie en markdown sur la console (UTF-8, y compris sous LC_ALL=C : la
#  categorie LC_CTYPE est basculee sur une locale UTF-8 au demarrage si
#  necessaire, #113, #242) ; fichiers ecrits SEULEMENT sur option explicite
#  (--sortie-tranche, --ecrire, --sortie, --brut). Tous les libelles non
#  ASCII du script sont ecrits en echappements \u (fichier source ASCII).
#
#  Protocole : specification d'actuary
#  docs/specifications/206-calibration-mc-merz-wuthrich.md, approuvee telle
#  quelle par le mainteneur au point d'arret B1 (annotation du 10/10/2026,
#  Q-206-B1-1 a 9). Renvois aux paragraphes de la specification :
#    par. 1 : les 13 cles de MW_CATALOGUE_MC (noms et sens LUS au catalogue,
#             compares au tableau du par. 1, controle (b)) ;
#    par. 2 : DGP de Mack ajuste a reserve2 (f, sigma2 de mw_ajuster(), premiere
#             colonne fixee), generateur gen_triangle_h0() (JAMAIS nomme
#             mw_simuler_triangle : il masquerait celui du moteur), lois N
#             (rnorm), E (loi uniforme sur les 27 valeurs du pool redresse de
#             reserve2, divisees par leur ecart-type de population), A
#             ((G - 2)/sqrt(2), G ~ Gamma(2) par inversion) ; triangle refuse
#             (cellule <= 0, mw_valider_triangle(), mw_valider_ajustement(),
#             ou erreur de mw_ajuster() / mw_msep(), qui donnerait ok = FALSE
#             dans run_engine()) compte avec son motif, sans retirage ;
#    par. 3 : par triangle admis, mw_bootstrap(aj, B = 999, seed = S) puis
#             mw_tests(aj, boot, alpha = 0,10) ; pool brut d'avant #46 par
#             injection de .mw_pool_residus dans l'environnement du moteur
#             (expression de b827726^, restauree par finally, technique de
#             e88b6e6), sur le meme triangle et la meme graine (appariement) ;
#    par. 4 : oracle (N0 = 20 000 triangles par loi, statistiques par
#             stats_oracle(aj), ensembles figes de aj) ; reference rho
#             (taille lissee a B = 999, regle unique pour toutes les
#             statistiques) ; temoin K3 (p_or = engine_p_mc(S0, s_obs, sens),
#             calculee a la combinaison sur la statistique observee de la
#             ligne REP) ;
#    par. 5 : critere K1 a K5, profils Pi0 a Pi5 et R1 a R3, texte reporte
#             SANS MODIFICATION dans TEXTE_CRITERE_206 (controle (t)) et au
#             T0, evalue mecaniquement SANS CONCLURE ;
#    par. 6 : controles (a), (b), (g), (i1), (i2), (i3), (i4), (s), (d) ;
#    par. 7 : graines (toutes sous engine_sous_graine()) ;
#    par. 8 : echelle L0 a L5, regle N_max (--prevol) ;
#    par. 9 : #119 (regressions agregees, T6 ; sous-mesure N, T7) ;
#    par. 11 : modes, sorties T0 a T7, criteres de #242.
#
#  Catalogue lu et sens attendus (controle (b), R21, #354). Le tableau de #206
#  (docs/tableaux/20261011-issue206-calibration-mw.md) mesure le moteur
#  d'avant #276, #300, #301 et #307 ; le catalogue a depuis change :
#    - Calendrier (#276, decision Q-Fd-1, 14/10/2026) : queue basse ("bas"),
#      et non la forme bilaterale du tableau (tests/mesure_calendaire_t8.R,
#      docs/tableaux/20261016-issue276-calendaire.md) ;
#    - BP (#301, Q-D2-Fi-1, 21/10/2026) : cle conservee, statistique FWr (n R^2
#      partiel a effets fixes de colonne sur les residus redresses, colonnes
#      n_j >= 3, mw_test_heteroscedasticite_intra()) ;
#    - Grubbs remplacee, a la meme position, par MinP4 (#300, Q-D2-Fi-2,
#      21/10/2026 : minimum des p de Student des residus studentises externes,
#      colonnes n_j >= 4, queue basse, mw_test_cellule_aberrante()) ;
#    - PenteIntra (#307, Q-D1-Fj-3) : cle conservee, statistique = t de la pente
#      RELATIVE (.mw_pente_relative()), et non la pente absolue de #119.
#  SENS_SPEC porte les treize sens attendus AU MOTEUR ACTUEL ; les colonnes BP,
#  MinP4, PenteIntra et Calendrier des sorties de ce script ne sont donc pas
#  celles du tableau de #206 pour les statistiques ci-dessus : une remesure de
#  #206 passe par une decision. Le nombre de lignes de mw_tests() sur reserve2
#  (NL_MAX) est lu dans la reference versionnee, non fige.
#
#  Statut des valeurs : CONSTAT DE SIMULATION SOUS UN PLAN (modele de Mack
#  ajuste a reserve2), pas un resultat general (par. 0). Aucun theoreme ne
#  couvre ce test bootstrap a T = 8 ; Dwass (1957) et Hope (1968) ne fondent
#  que le temoin oracle.
#
#  Modes (un seul par execution) :
#      Rscript tests/calibration_mc_mw_t8.R --loi N|E|A --b b1:b2
#          --pools redresse[,brut] [--sortie-tranche FICHIER
#          [--reprendre PARTIELLE]] [--essai]
#      Rscript tests/calibration_mc_mw_t8.R --oracle --loi N|E|A [--N0 20000]
#          [--sortie-tranche FICHIER [--reprendre PARTIELLE]] [--essai]
#      Rscript tests/calibration_mc_mw_t8.R --sous-mesure-N --b b1:b2
#          [--sortie-tranche FICHIER [--reprendre PARTIELLE]] [--essai]
#      Rscript tests/calibration_mc_mw_t8.R --prevol [--unites 1]
#          [--campagne 297 [--prevol-ln FICHIER]]
#      Rscript tests/calibration_mc_mw_t8.R --plan L0|L1|L2|L3|L4|L5
#          [--campagne 206|297]   (L0 a L4 seulement pour 297)
#      Rscript tests/calibration_mc_mw_t8.R --controle-289 [--coeurs N]
#          [--ecrire [--remplacer]] [--essai --b b1:b2]
#      Rscript tests/calibration_mc_mw_t8.R --combiner f1 f2 ... | DOSSIER
#          (--niveau Lk | --reduit) [--campagne 206|297]
#          [--journal JOURNAL.md]
#          [--ecrire [--remplacer] --brut FICHIER --journal JOURNAL.md
#           | --sortie DOSSIER [--brut FICHIER]]
#  (--prevol-unite : mode interne de --prevol, une unite de debit.)
#  --controle-289 (#289, specification de Fi, par. 5) : controle des ensembles
#  figes a l'observe de la courbure (#270) et de l'ordonnee a l'origine
#  (#273), sans bootstrap complet. Volet 1 : sur les triangles du plan de #206
#  (niveau L0 : N 2 000, E 2 000, A 1 000, memes graines), ensembles de
#  .mw_ensembles_figes(aj) et K des deux verifications. Volet 2 : b = 1..50 de
#  chaque loi (150 triangles), mw_bootstrap() a B = 999 aux graines de #206
#  avec un CATALOGUE REDUIT injecte dans MW_CATALOGUE_MC de l'environnement du
#  moteur (Sonde, Origine, Courbure ; restaure par finally ; la boucle de
#  tirage n'est pas recopiee, #340) : la sonde compte, par replication, les
#  colonnes retenues a moins de 2 (ordonnee) ou 3 (courbure) valeurs
#  distinctes (predicat de #290) et les statistiques NA par cause. Sortie en
#  markdown sur la console ; --ecrire l'ecrit dans docs/tableaux/ (arbre
#  propre exige, comme --combiner --ecrire) ; --coeurs : processus
#  (mclapply, defaut min(4, detectCores()) ; 1 sous Windows) ; --essai --b
#  b1:b2 : plan reduit (marque, refuse par --ecrire).
#  Tranche : b de b1 a b2 (1 <= b1 <= b2 <= 2 000 ; loi A : pas de pool
#  brut ; sous-mesure N : b2 <= 500). Une tranche REFUSE (code 1, avant tout
#  calcul) un commit non propre ou un code hors du depot
#  (motifs_non_versionnable()), sauf --essai (essai de mise au point, marque
#  en T0, refuse par --combiner --ecrire).
#  --sortie-tranche FICHIER : sortie complete (lignes machine et markdown)
#  HORS du depot, jamais ecrasee ; ecriture AU FIL DE L'EAU : en-tete
#  (PARAMETRES, TRANCHE, CONTEXTE, CLES, COLS) apres les controles
#  generaux, puis une ligne de donnees par triangle (REP, ORA ou SM, flush),
#  puis le markdown, DUREE, REPRISE eventuelle, MD5_VALEURS (oracle),
#  INTEGRITE, NLIG et FIN (derniere ligne). Une ligne ne depend que de (mode,
#  loi, b) et de ses graines (L-229-4).
#  --reprendre PARTIELLE (avec --sortie-tranche NOUVEAU) : relit une sortie
#  sans FIN (jamais modifiee), exige un en-tete identique, reprend ses
#  lignes de donnees completes et ne calcule que les manquantes ; une
#  derniere ligne non terminee par un saut de ligne (ecriture interrompue)
#  est ecartee et recalculee ; sont toujours recalcules, et doivent redonner
#  la ligne reprise hors durees (controle (reprise), INTEGRITE ECHEC sinon) :
#  le premier triangle admis (echantillon des controles (i1), (i2), (s)), la
#  derniere ligne reprise et un echantillon regulier de lignes reprises
#  (N_ECH_REPRISE_ORACLE en mode oracle, N_ECH_REPRISE_TRANCHE en mode
#  tranche depuis #248 ; aucun en sous-mesure N) : une ligne interieure
#  alteree n'est detectee que si elle tombe dans cet echantillon.
#  --prevol (par. 8) : sans rien ecrire, mesure c_b (mw_bootstrap() a
#  B = 999 et mw_tests(), cache de la loi nulle de Shapiro-Wilk chaud), le
#  debit agrege a 1, 2, 3 et 4 processus concurrents (sous-processus
#  --prevol-unite), le cout d'un triangle oracle et d'un triangle de la
#  sous-mesure N, les motifs de refus des triangles des trois lois ; en
#  deduit F, N_max et la duree planifiee de chaque niveau, et le niveau
#  retenu (premier niveau tenu en 20 h d'horloge) ; imprime le plan de ses
#  tranches (format du lanceur) et les lignes a reporter au JOURNAL.
#  --plan Lk : plan des tranches du niveau (lignes "nom<TAB>arguments", lues
#  par tests/outillage/lancer_tranches.sh), ordre de priorite du par. 11.
#  --combiner : lit les sorties (chemins, ou un DOSSIER dont il prend les
#  fichiers tranche-<loi>-<b1>-<b2>.txt, oracle-<loi>.txt et
#  sm-<b1>-<b2>.txt), recalcule les tableaux. --niveau Lk fixe les R du
#  par. 8 (et N0 = 20 000, sous-mesure N sur 1..500) ; --reduit les lit sur
#  la couverture (essais ; refuse par --ecrire). REFUS (code 1, sans
#  tableau) : sortie sans INTEGRITE OK ou sans FIN en derniere ligne,
#  nombre de lignes different de NLIG ; ligne au statut erreur ;
#  PARAMETRES, commit, plateforme, empreintes (#231), generateur, DGP ou
#  correspondance ligne <-> cle differents ; couverture de 1..R_(loi, pool)
#  (et 1..500 pour la sous-mesure) qui n'est pas exactement une fois ; loi
#  du niveau sans oracle, ou oracle de taille differente ; invariant (d)
#  faux (dont une p de #119 hors de [0, 1] ou illisible, #248) ; md5 des
#  valeurs de l'oracle different de MD5_VALEURS ; avec --journal : pour une
#  sortie, ligne "- Sortie <nom> : md5 <md5>" (en debut de ligne) absente,
#  multiple ou de md5 different de celui du fichier (#248 : un md5 cite
#  ailleurs ne suffit plus), ligne "- Empreinte sans commentaires : <md5>"
#  absente, multiple ou differente,
#  ligne "- Niveau : Lk" differente de --niveau. Lignes attendues au
#  JOURNAL (une chacune) : "- Debit : <texte>" (avec ou sans accent),
#  "- Niveau : Lk", "- Empreinte sans commentaires : <md5>", et une par
#  sortie : "- Sortie <nom> : md5 <md5>[, suite libre]" (format de
#  tests/outillage/synchroniser_sauvegarde.sh).
#  --ecrire (avec --combiner, --niveau, --journal et --brut obligatoires) :
#  ecrit dans docs/tableaux/ (date du jour), nouveaux et jamais patches :
#    <AAAAMMJJ>-issue206-calibration-mw.md et -calibration-mw-brut.tsv,
#    <AAAAMMJJ>-issue119-mw.md (T6, T7),
#    <AAAAMMJJ>-issue206-journal-mesure.md (copie du JOURNAL),
#    <AAAAMMJJ>-issue206-journal-combinaison.md (journal de la combinaison,
#    D-g de #242).
#  Copie des valeurs brutes hors du depot (--brut) ecrite AVANT les fichiers
#  versionnes. --ecrire REFUSE : commit de la combinaison ou des sorties non
#  propre, code hors du depot, sortie --essai, --reduit, plan du niveau
#  incomplet, garde_ecrasement() (#173) sans --remplacer, chemin absolu ou
#  /tmp dans un fichier a ecrire (D-a de #242). Gardes anticipees (#205).
#  --sortie DOSSIER : memes fichiers HORS du depot (jamais ecrases),
#  ecrits avec la copie --brut par lot (#248) : tous produits dans des
#  dossiers temporaires voisins de leurs cibles, md5 des copies controles, puis
#  renommes ; une erreur ne laisse aucun d'eux (ni temporaire) en place.
#
#
#  CAMPAGNE DE FK (#297, specification docs/specifications/
#  fk-lecture-conjointe.md, par. 5, decisions du mainteneur du 25/10/2026,
#  Q-D1-Fk-8) : --campagne 297 (modes --plan, --prevol, --combiner ; defaut
#  206, mesure de #206 ci-dessus). Les tranches et les oracles sont communs aux
#  deux campagnes (memes graines, memes triangles) ; leurs sorties portent en
#  plus, depuis #297 :
#    - par triangle admis (pool redresse), les lignes de lecture conjointe de
#      mw_tests() (engine_p_famille()) pour M1 a M4 et la ligne globale LC :
#      etat (L : ligne et p ; N : ligne sans p, B effectif de famille <
#      B_MIN_DEGENERESCENCE, texte T-3b ; A : pas de ligne, k <= 1 ; X :
#      incoherence ; S : bootstrap$stats_boot absent), k (nombre de tests
#      membres, regle du par. 1.3 reecrite dans le script), B effectif de
#      famille (lignes completes de stats_boot sur les membres), p, err_mc et
#      m_obs de la ligne, plus petite p_mc des membres ; types des lignes
#      (typ_R) pour T4 ;
#    - controle (k) : etats L, N ou A seulement, coherents avec k et le B
#      effectif (une ligne absente parce que stats_boot manque n'est jamais
#      confondue avec une ligne absente parce que k <= 1 : etat S, INTEGRITE
#      ECHEC ; reserve d'actuary du 25/10/2026) ;
#    - controle K-F3 (par. 5.3) : sur le premier triangle admis de chaque
#      tranche, p de famille, m_obs, err_mc et k recalcules dans le script en R
#      de base (fk_recalcul() : comptes par findInterval() sur les colonnes
#      triees, sans rank(), ecriture independante d'engine_p_famille() et de
#      .engine_minp_rangs()), identical() aux champs de chaque ligne ; ligne
#      globale exigee ; un echec met INTEGRITE a ECHEC ;
#    - controle (t297) : texte du critere de Fk (par. 5.3, K-F1 a K-F4,
#      profils Phi0 a Phi5) reporte SANS MODIFICATION dans TEXTE_CRITERE_FK,
#      present tel quel dans la specification ;
#    - controle (fr) (par. 5.4) : ensemble "a la frontiere" lu dans la
#      reference versionnee (lignes de tests/reference/reserve2.rds dont le
#      detail se termine par PHRASE_VERDICT_SENSIBLE_MC), l'inegalite
#      |p_mc - s| < 2 err_mc (s atteignable, regle de #244) recalculee depuis
#      p_mc et err_mc ; tout desaccord est un ECHEC (tranches) ou un REFUS
#      (--combiner). Il remplace la liste ecrite en dur (BP, Origine, HomogF).
#  --plan Lk --campagne 297 : plan du par. 5.2 (L0 a L4 : lois N et E, pool
#  redresse seul, R = 2 000 ou 1 000 ; oracles N et E a N0 = 20 000 ; ni pool
#  brut, ni loi A, ni sous-mesure N), suivi des tranches lognormales
#  (tests/calibration_mc_t8.R, J1 et J2, R = 2 000 ou 1 000, sorties
#  ln-J<1|2>-R<R>-<b1>-<b2>.txt) ; ligne "nom<TAB>arguments<TAB>script" pour
#  ces dernieres (troisieme champ lu par tests/outillage/lancer_tranches.sh).
#  --prevol --campagne 297 [--prevol-ln FICHIER] : couts et debit de ce
#  script (lois N et E) ; avec la sortie de "tests/calibration_mc_t8.R
#  --prevol" (ligne PREVOL_LN), duree planifiee de chaque niveau L0 a L4 a
#  4 processus et premier niveau tenu en 10 h (budget du par. 5.2), borne
#  "duree planifiee + 0,75 x duree d'une tranche MW" (ordonnancement en
#  liste, [H]) comparee au plafond, lignes du JOURNAL (Niveau, Debit, Borne,
#  Commit, Empreinte) ; sans elle, niveau non determine. Avec --journal, la
#  combinaison 297 exige les lignes Commit et Empreinte et les compare aux
#  sorties.
#  --combiner ... --campagne 297 (--niveau Lk | --reduit) : couverture du
#  niveau de Fk (pool brut, loi A et sous-mesure N refuses), puis
#  <AAAAMMJJ>-issue297-calibration-famille-mw.md : provenance, criteres de Fk
#  et de #206 reportes, evaluation mecanique de K-F1 a K-F4 et des profils
#  Phi (sans conclure), tables des p de famille (K-F1, composition, K-F2,
#  K-F4), puis remesure par cle de #206 (rho, K1 a K5, T1, T3, T4, T5,
#  inchangees) ; -calibration-famille-mw-brut.tsv, -journal-mesure.md
#  (copie du JOURNAL de la campagne) et -journal-combinaison-mw.md ;
#  --ecrire, --sortie, --brut et --journal comme pour #206.
#
#  Fonctions reprises par copie declaree de tests/p_conditionnelle_regime_t8.R
#  (ce script execute son calcul au chargement) : plateforme_calcul(),
#  meme_fichier(), empreintes_code(), sous_depot(), ligne_md(), entete_md(),
#  num(), ic_cp(), md5_fichier(), chemin_cite(), suivi_git(),
#  nettoyer_champ(), refuser(), proteger(), lecture() (sans la regle L6 de
#  #229, absente de la specification de #206), mcnemar(), structure des
#  sorties de tranche, de --reprendre et de --combiner ; ecrire_console()
#  modifiee (sortie UTF-8 sous LC_ALL=C). commit_depot(),
#  motifs_non_versionnable(), garde_ecrasement(), ligne_remplacement(),
#  inserer_t0(), empreinte_sans_commentaires(), executer_cas(),
#  comparer_objets() : tests/outils_tests.R.
#  Code de sortie : 0 si les controles d'integrite tiennent, 1 sinon ; en
#  mode --combiner, 0 si la combinaison est acceptee, 1 si elle est refusee.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/calibration_mc_mw_t8.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113, critere de #242) -------------
# Sous une locale non UTF-8 (C, POSIX), les chaines \u du script ne sont pas
# marquees UTF-8 et toute conversion les abime ("<U+00E9>", "<c3><a9>"). La
# seule categorie LC_CTYPE est basculee sur une locale UTF-8 disponible
# (aucun effet sur les calculs : ni LC_NUMERIC ni LC_COLLATE ne changent).
LOCALE_ORIGINE <- Sys.getlocale("LC_CTYPE")
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break
LOCALE_TRAVAIL <- Sys.getlocale("LC_CTYPE")

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
OPTIONS_VALEUR <- c("--loi", "--b", "--pools", "--N0", "--sortie-tranche", "--reprendre", "--journal",
                    "--sortie", "--brut", "--niveau", "--unites", "--plan", "--coeurs", "--campagne", "--prevol-ln")
OPTIONS_DRAPEAU <- c("--oracle", "--sous-mesure-N", "--prevol", "--prevol-unite", "--essai", "--ecrire",
                     "--remplacer", "--reduit", "--controle-289")
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
OPT_LOI       <- lire_option("--loi", NA_character_)
OPT_B         <- lire_option("--b", NA_character_)
OPT_POOLS     <- lire_option("--pools", NA_character_)
OPT_N0        <- lire_option("--N0", NA_character_)
OPT_SORTIE_TR <- lire_option("--sortie-tranche", NA_character_)
OPT_REPRENDRE <- lire_option("--reprendre", NA_character_)
OPT_JOURNAL   <- lire_option("--journal", NA_character_)
OPT_SORTIE    <- lire_option("--sortie", NA_character_)
OPT_BRUT      <- lire_option("--brut", NA_character_)
OPT_NIVEAU    <- lire_option("--niveau", NA_character_)
OPT_UNITES    <- lire_option("--unites", "1")
OPT_PLAN      <- lire_option("--plan", NA_character_)
OPT_COEURS    <- lire_option("--coeurs", NA_character_)
OPT_CAMPAGNE  <- lire_option("--campagne", "206")
OPT_PREVOL_LN <- lire_option("--prevol-ln", NA_character_)
OPT_ORACLE    <- "--oracle" %in% ARGS
OPT_SM        <- "--sous-mesure-N" %in% ARGS
OPT_PREVOL    <- "--prevol" %in% ARGS
OPT_UNITE     <- "--prevol-unite" %in% ARGS
OPT_ESSAI     <- "--essai" %in% ARGS
OPT_ECRIRE    <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_REDUIT    <- "--reduit" %in% ARGS
OPT_C289      <- "--controle-289" %in% ARGS

# --remplacer sans --ecrire : refus d'usage, avant tout (libelle commun aux
# scripts de mesure qui ont --ecrire, #173 ; tests/unitaires/test_garde_ecrasement.R).
if (OPT_REMPLACER && !OPT_ECRIRE) stop("--remplacer : reserve a --ecrire (remplacement d'un tableau suivi par git, #173)")
MODE <- if (MODE_COMBINER) "combiner" else if (OPT_UNITE) "unite" else if (OPT_PREVOL) "prevol" else
  if (OPT_C289) "c289" else if (!is.na(OPT_PLAN)) "plan" else if (OPT_ORACLE) "oracle" else if (OPT_SM) "sm" else
  if (!is.na(OPT_LOI)) "tranche" else NA_character_
if (is.na(MODE)) stop("aucun mode : --loi (tranche), --oracle, --sous-mesure-N, --prevol, --plan, --controle-289 ou --combiner")
n_modes <- sum(MODE_COMBINER, OPT_UNITE, OPT_PREVOL, !is.na(OPT_PLAN), OPT_ORACLE, OPT_SM, OPT_C289)
if (n_modes > 1L) stop("un mode et un seul : --oracle, --sous-mesure-N, --prevol, --plan, --controle-289, --combiner")
LOIS <- c("N", "E", "A")
NIVEAUX_NOMS <- paste0("L", 0:5)
reserve <- function(opts, modes) for (o in opts) if (o %in% ARGS && !MODE %in% modes)
  stop(o, " : reserve au(x) mode(s) ", paste(modes, collapse = ", "))
reserve(c("--b"), c("tranche", "sm", "unite", "c289"))
reserve(c("--pools"), "tranche")
reserve(c("--N0"), "oracle")
reserve(c("--sortie-tranche", "--reprendre"), c("tranche", "oracle", "sm"))
reserve(c("--essai"), c("tranche", "oracle", "sm", "c289"))
reserve(c("--journal", "--sortie", "--brut", "--reduit", "--niveau"), "combiner")
reserve(c("--ecrire", "--remplacer"), c("combiner", "c289"))
reserve(c("--coeurs"), "c289")
reserve(c("--unites"), "prevol")
reserve(c("--loi"), c("tranche", "oracle", "unite"))
# Campagne (#297) : plan, pre-vol et combinaison seulement ; les tranches et
# les oracles sont communs aux deux campagnes.
reserve(c("--campagne"), c("plan", "prevol", "combiner"))
reserve(c("--prevol-ln"), "prevol")
if (!OPT_CAMPAGNE %in% c("206", "297")) stop("--campagne : 206 ou 297")
CAMPAGNE <- OPT_CAMPAGNE
if (!is.na(OPT_PREVOL_LN) && CAMPAGNE != "297") stop("--prevol-ln : reserve a --campagne 297")
if (!is.na(OPT_PREVOL_LN) && !file.exists(OPT_PREVOL_LN)) stop("--prevol-ln : fichier introuvable : ", OPT_PREVOL_LN)
if (MODE == "combiner" && !length(FICHIERS_COMB)) stop("--combiner : aucun fichier")
if (MODE == "combiner" && sum(!is.na(OPT_NIVEAU), OPT_REDUIT) != 1L) stop("--combiner : --niveau Lk ou --reduit (un seul)")
# Niveaux de la campagne : L0 a L5 (#206, par. 8) ; L0 a L4 (Fk, par. 5.2).
NIVEAUX_NOMS_C <- if (CAMPAGNE == "297") paste0("L", 0:4) else NIVEAUX_NOMS
if (!is.na(OPT_NIVEAU) && !OPT_NIVEAU %in% NIVEAUX_NOMS_C) stop("--niveau : ", paste(range(NIVEAUX_NOMS_C), collapse = " a "))
if (!is.na(OPT_PLAN) && !OPT_PLAN %in% NIVEAUX_NOMS_C) stop("--plan : ", paste(range(NIVEAUX_NOMS_C), collapse = " a "))
if (OPT_ECRIRE && MODE == "combiner" && is.na(OPT_BRUT)) stop("--ecrire : --brut FICHIER obligatoire (copie des valeurs brutes hors du depot)")
if (OPT_ECRIRE && MODE == "combiner" && is.na(OPT_JOURNAL)) stop("--ecrire : --journal FICHIER obligatoire (debit, niveau et empreinte #231 du JOURNAL)")
if (OPT_ECRIRE && OPT_REDUIT) stop("--ecrire : refuse avec --reduit (parametres reduits, non versionnables)")
if (OPT_ECRIRE && !is.na(OPT_SORTIE)) stop("--ecrire et --sortie sont exclusifs")
if (!is.na(OPT_SORTIE) && !dir.exists(OPT_SORTIE)) stop("--sortie : dossier introuvable : ", OPT_SORTIE)
if (!is.na(OPT_LOI) && !OPT_LOI %in% LOIS) stop("--loi : N, E ou A")
if (MODE %in% c("tranche", "oracle", "unite") && is.na(OPT_LOI)) stop("--loi N, E ou A obligatoire")
if (MODE %in% c("tranche", "sm", "unite") && is.na(OPT_B)) stop("--b b1:b2 obligatoire")
if (MODE == "tranche" && is.na(OPT_POOLS)) stop("--pools redresse ou redresse,brut obligatoire")
if (!is.na(OPT_POOLS) && !OPT_POOLS %in% c("redresse", "redresse,brut")) stop("--pools : redresse ou redresse,brut")
if (identical(OPT_LOI, "A") && identical(OPT_POOLS, "redresse,brut")) stop("--pools : pas de pool brut pour la loi A (par. 8)")
B_MAX_SPEC <- 2000L; R_SM_SPEC <- 500L; N0_SPEC <- 20000L
B_REPL_289 <- 50L                 # triangles par loi du volet 2 de --controle-289 (#289)
B1 <- B2 <- NA_integer_
if (!is.na(OPT_B)) {
  m <- regmatches(OPT_B, regexec("^([0-9]+):([0-9]+)$", OPT_B))[[1]]
  if (length(m) != 3L) stop("--b : forme b1:b2 attendue")
  B1 <- as.integer(m[2]); B2 <- as.integer(m[3])
  if (B1 < 1L || B2 < B1 || B2 > B_MAX_SPEC) stop("--b : 1 <= b1 <= b2 <= 2000 (plages du par. 7)")
  if (MODE == "sm" && B2 > R_SM_SPEC) stop("--b : sous-mesure N sur b <= 500 (par. 9)")
  if (MODE == "c289" && !OPT_ESSAI) stop("--b : reserve a --essai pour --controle-289 (plan fixe : b = 1..50 de chaque loi)")
  if (MODE == "c289" && B2 > B_REPL_289) stop("--b : --controle-289 sur b <= ", B_REPL_289)
}
if (MODE == "c289" && OPT_ESSAI && is.na(OPT_B)) stop("--controle-289 --essai : --b b1:b2 obligatoire (plan reduit)")
if (MODE == "c289" && OPT_ESSAI && OPT_ECRIRE) stop("--ecrire : refuse avec --essai (plan reduit, non versionnable)")
N_COEURS <- if (is.na(OPT_COEURS)) NA_integer_ else suppressWarnings(as.integer(OPT_COEURS))
if (!is.na(OPT_COEURS) && (is.na(N_COEURS) || N_COEURS < 1L)) stop("--coeurs : entier >= 1")
N0 <- if (is.na(OPT_N0)) N0_SPEC else suppressWarnings(as.integer(OPT_N0))
if (is.na(N0) || N0 < 1L || N0 > N0_SPEC) stop("--N0 : entier de 1 a 20 000")
UNITES <- suppressWarnings(as.integer(OPT_UNITES))
if (is.na(UNITES) || UNITES < 1L) stop("--unites : entier >= 1")
if (!is.na(OPT_REPRENDRE)) {
  if (is.na(OPT_SORTIE_TR)) stop("--reprendre : --sortie-tranche FICHIER obligatoire (nouveau fichier)")
  if (!file.exists(OPT_REPRENDRE)) stop("--reprendre : fichier introuvable : ", OPT_REPRENDRE)
  if (file.exists(OPT_SORTIE_TR) && normalizePath(OPT_REPRENDRE) == normalizePath(OPT_SORTIE_TR))
    stop("--reprendre : --sortie-tranche doit designer un autre fichier que la sortie partielle")
}

# --- Chargement du moteur et des outils --------------------------------------
FICHIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) f else NA_character_
})
DOSSIER_SCRIPT <- if (!is.na(FICHIER_SCRIPT)) dirname(FICHIER_SCRIPT) else
  if (file.exists("tests/outils_tests.R")) "tests" else "."
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))

# --- Outils (copies declarees de tests/p_conditionnelle_regime_t8.R) ---------
# plateforme_calcul() modifiee : BLAS et LAPACK cites par le NOM de leur
# bibliotheque (libblas.so.3.12.0...), qui suffit a les identifier, et non
# par leur chemin absolu (par. 11 : aucun chemin absolu au T0).
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(basename(extSoftVersion()[["BLAS"]])), txt(basename(La_library())), txt(La_version()))
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
# Sortie UTF-8 : sous une locale UTF-8 (LC_CTYPE bascule ci-dessus), les
# chaines sont deja en UTF-8 ; a defaut de locale UTF-8 disponible, les
# chaines non marquees (litteraux \u du script) sont marquees UTF-8 avant
# l'ecriture octet par octet (jamais converties).
utf8 <- function(x) {
  x <- as.character(x)
  if (!isTRUE(l10n_info()[["UTF-8"]])) { k <- Encoding(x) == "unknown"; Encoding(x)[k] <- "UTF-8"; x } else enc2utf8(x)
}
ecrire_console <- function(x) writeLines(utf8(x), useBytes = TRUE)
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
num <- function(x, d = 3) if (length(x) != 1L || is.na(x)) "\u2014" else sub(".", ",", sprintf(paste0("%.", d, "f"), x), fixed = TRUE)
ic_cp <- function(k, n) if (n > 0) {
  ci <- stats::binom.test(k, n)$conf.int
  c(ci[1], ci[2])
} else c(NA_real_, NA_real_)
# IC non arrondis a 4 decimales (#242, D-e) : 5 decimales a l'affichage,
# valeurs exactes (k, n) dans les valeurs brutes.
D_IC <- 5L
txt_ic <- function(ci, d = D_IC) if (anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", num(ci[1], d), num(ci[2], d))
md5_fichier <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
# Chemin cite : relatif au depot, sinon NOM DE FICHIER seul (#242, D-a :
# aucun chemin absolu ni /tmp dans un tableau).
chemin_cite <- function(f) {
  if (is.na(f) || !file.exists(f)) return(basename(as.character(f)))
  a <- normalizePath(f, winslash = "/", mustWork = TRUE)
  r <- normalizePath(RACINE, winslash = "/", mustWork = TRUE)
  if (startsWith(a, paste0(r, "/"))) substring(a, nchar(r) + 2L) else basename(a)
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
secondes <- function(t0) as.numeric(difftime(Sys.time(), t0, units = "secs"))
f17 <- function(v) ifelse(is.finite(v), sprintf("%.17g", v), "NA")
liste_cel <- function(x, n = 10) if (!length(x)) "aucune" else
  paste(c(utils::head(x, n), if (length(x) > n) sprintf("... (%d en tout)", length(x))), collapse = " ; ")
fmt_p <- function(p) if (!is.finite(p)) "\u2014" else sub(".", ",", sprintf("%.3g", p), fixed = TRUE)
# Chemin absolu ou /tmp dans un texte destine a un fichier (#242, D-a).
chemins_absolus <- function(lignes) {
  k <- grepl("/tmp", lignes, fixed = TRUE) |
    grepl("(^|[ (|`'\"=])(/(home|root|usr|var|mnt|opt|Users|private|srv|media)/|[A-Za-z]:[\\\\/])", lignes, perl = TRUE)
  lignes[k]
}

SPEC <- file.path("docs", "specifications", "206-calibration-mc-merz-wuthrich.md")
# Specification de Fk (#297, par. 5) : critere K-F1 a K-F4 et profils Phi0 a
# Phi5 (controle (t297)) ; ses empreintes figurent avec celles de SPEC dans
# chaque sortie (sorties communes aux deux campagnes).
SPEC_FK <- file.path("docs", "specifications", "fk-lecture-conjointe.md")
SPECS_LUES <- c(SPEC, SPEC_FK)
# Textes des specifications (controles (t) et (t297), --combiner de la
# campagne 297) et presence d'un bloc de lignes, a l'identique.
lire_spec <- function(f) if (file.exists(file.path(RACINE, f))) readLines(file.path(RACINE, f), warn = FALSE, encoding = "UTF-8") else character(0)
TXT_SPEC <- lire_spec(SPEC)
TXT_SPEC_FK <- lire_spec(SPEC_FK)
present_bloc <- function(bloc, txt = TXT_SPEC) {
  i <- which(txt == bloc[1])
  any(vapply(i, function(k) k + length(bloc) - 1L <= length(txt) && identical(txt[k:(k + length(bloc) - 1L)], bloc), logical(1)))
}

###############################################################################
#  GARDES ANTICIPEES (#205, #173) : evaluees AVANT tout calcul (le premier
#  calcul est l'ajustement de reserve2 du DGP, plus bas), et reprises avant
#  d'ecrire. --ecrire : commit et code de la combinaison, dossier
#  docs/tableaux/, garde d'ecrasement des cinq cibles ; --brut, --sortie ;
#  sortie de calcul : commit propre et code du depot (sauf --essai),
#  --sortie-tranche hors du depot et jamais ecrasee.
###############################################################################
DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
# Campagne de Fk (#297, par. 5.6) : quatre fichiers (sans T6 ni T7 de #119,
# sous-mesure N hors plan) ; le JOURNAL de la campagne (volets lognormal et
# Merz-Wuthrich) est copie ici seulement.
NOMS_SORTIE <- if (CAMPAGNE == "297")
  c(md = sprintf("%s-issue297-calibration-famille-mw.md", DATE_SORTIE),
    brut = sprintf("%s-issue297-calibration-famille-mw-brut.tsv", DATE_SORTIE),
    journal = sprintf("%s-issue297-journal-mesure.md", DATE_SORTIE),
    jcomb = sprintf("%s-issue297-journal-combinaison-mw.md", DATE_SORTIE)) else
  c(md = sprintf("%s-issue206-calibration-mw.md", DATE_SORTIE),
    brut = sprintf("%s-issue206-calibration-mw-brut.tsv", DATE_SORTIE),
    md119 = sprintf("%s-issue119-mw.md", DATE_SORTIE),
    journal = sprintf("%s-issue206-journal-mesure.md", DATE_SORTIE),
    jcomb = sprintf("%s-issue206-journal-combinaison.md", DATE_SORTIE))
CIBLES <- file.path(RACINE, "docs", "tableaux", NOMS_SORTIE); names(CIBLES) <- names(NOMS_SORTIE)
if (MODE == "combiner" && OPT_ECRIRE) {
  nv0 <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, SPECS_LUES), "de la combinaison")
  if (length(nv0)) refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv0, collapse = " ; "),
                           " -- relancer sur un arbre propre, ou --sortie DOSSIER hors du depot")
  if (!dir.exists(file.path(RACINE, "docs", "tableaux"))) stop("dossier de sortie introuvable : docs/tableaux")
  garde_ecrasement(CIBLES, OPT_REMPLACER, RACINE)
}
if (MODE == "combiner" && !is.na(OPT_BRUT)) {
  if (!dir.exists(dirname(OPT_BRUT))) stop("--brut : dossier introuvable")
  if (sous_depot(dirname(OPT_BRUT))) stop("--brut : chemin sous le depot refuse (copie hors du depot)")
  if (file.exists(OPT_BRUT)) stop("--brut : fichier existant, jamais ecrase")
}
if (MODE == "combiner" && !is.na(OPT_SORTIE)) {
  if (sous_depot(OPT_SORTIE)) stop("--sortie : dossier sous le depot refuse (--ecrire est le seul chemin qui ecrit dans le depot)")
  if (any(file.exists(file.path(OPT_SORTIE, NOMS_SORTIE)))) stop("--sortie : fichier(s) deja present(s), jamais ecrase(s)")
}
# --controle-289 --ecrire (#289) : un seul tableau, de nom fixe par la date du
# jour ; memes gardes que --combiner --ecrire (arbre propre, code du depot,
# garde d'ecrasement #173), avant tout calcul.
NOM_289 <- sprintf("%s-issue289-ensembles-figes-mw.md", DATE_SORTIE)
CIBLE_289 <- file.path(RACINE, "docs", "tableaux", NOM_289)
if (MODE == "c289" && OPT_ECRIRE) {
  nv289 <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, SPECS_LUES), "de l'execution")
  if (length(nv289)) {
    message("--controle-289 : --ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv289, collapse = " ; "),
            " -- relancer sur un arbre propre, ou sans --ecrire (sortie console)")
    quit(status = 1L)
  }
  if (!dir.exists(file.path(RACINE, "docs", "tableaux"))) stop("dossier de sortie introuvable : docs/tableaux")
  garde_ecrasement(CIBLE_289, OPT_REMPLACER, RACINE)
}
if (MODE %in% c("tranche", "oracle", "sm")) {
  if (!OPT_ESSAI) {
    nvt <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, SPECS_LUES), "de la sortie")
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

# Environnement ou le moteur est charge (injection du pool brut, par. 3) ;
# affecte apres les gardes anticipees (#205).
ENV_MOTEUR <- environment(mw_bootstrap)

###############################################################################
#  PROTOCOLE (constantes de la specification)
###############################################################################
METHODE <- "reserve2"; SEGMENT <- 1; ANNEXE <- "II"
ALPHA <- 0.10; SEUILS <- c(0.10, 0.05); IA <- c("a10", "a05")
# Double, comme le B par defaut de run_engine() : mw_bootstrap() restitue B tel
# quel, et un entier rendrait $bootstrap non identical() a celui de
# run_engine() (champ B de type integer contre double, mesure, controle (i2)).
B_BOOT <- 999
IDX_LOI <- c(N = 1L, E = 2L, A = 3L)
# Graines (par. 7), toutes sous engine_sous_graine().
GRAINE_TRI <- 20840000; GRAINE_BOOT <- 20870000; GRAINE_ORA <- 20900000
PAS_LOI <- 10000; PAS_LOI_ORA <- 20000
GRAINE_R2 <- 20260831            # cas reserve2 de tests/outils_tests.R (controles (a), (i1), (i2))
graine_tri  <- function(loi, b) GRAINE_TRI + PAS_LOI * (IDX_LOI[[loi]] - 1L) + b
graine_boot <- function(loi, b) GRAINE_BOOT + PAS_LOI * (IDX_LOI[[loi]] - 1L) + b
graine_ora  <- function(loi, k) GRAINE_ORA + PAS_LOI_ORA * (IDX_LOI[[loi]] - 1L) + k
# Echelle de reduction (par. 8) : R par (loi, pool) ; A absente a L3, L4, L5.
NIVEAUX <- list(
  L0 = c(N_red = 2000, E_red = 2000, N_brut = 1000, E_brut = 1000, A_red = 1000),
  L1 = c(N_red = 2000, E_red = 2000, N_brut = 1000, E_brut = 1000, A_red = 500),
  L2 = c(N_red = 2000, E_red = 2000, N_brut = 500, E_brut = 500, A_red = 500),
  L3 = c(N_red = 2000, E_red = 2000, N_brut = 500, E_brut = 500, A_red = 0),
  L4 = c(N_red = 1500, E_red = 1500, N_brut = 500, E_brut = 500, A_red = 0),
  L5 = c(N_red = 1000, E_red = 1000, N_brut = 500, E_brut = 500, A_red = 0))
LIB_NIVEAUX <- c(L0 = "\u2014", L1 = "A \u00e0 R = 500", L2 = "brut \u00e0 R = 500 par loi", L3 = "A retir\u00e9e (et son oracle)",
                 L4 = "redress\u00e9 N et E \u00e0 R = 1 500", L5 = "redress\u00e9 N et E \u00e0 R = 1 000 (minimum)")
BOOTSTRAPS_SPEC <- c(L0 = 7000, L1 = 6500, L2 = 5500, L3 = 5000, L4 = 4000, L5 = 3000)
BUDGET_H <- 20                    # heures d'horloge planifiees (par. 8)
TAILLE_PAIRE <- 125L; TAILLE_SEULE <- 250L   # triangles par tranche (par. 11)
SEUIL_K4 <- 0.01; SEUIL_REFUS <- 0.01; NIVEAU_HOLM <- 0.05
# Campagne de Fk (#297, specification de Fk, par. 5.2) : R par loi (pool
# redresse seul) et par jeu lognormal (tests/calibration_mc_t8.R) ; oracles N
# et E a N0 = 20 000 a tous les niveaux ; ni pool brut, ni loi A, ni
# sous-mesure N. Chaque niveau retire un element du precedent (L1 : MW E a
# R = 1 000 ; L2 : LN J1 a R = 1 000 ; L3 : MW N a R = 1 000 ; L4 : LN J2 a
# R = 1 000). Budget plafond : 10 h d'horloge sur 4 coeurs.
NIVEAUX_297 <- list(
  L0 = c(N = 2000, E = 2000, J1 = 2000, J2 = 2000),
  L1 = c(N = 2000, E = 1000, J1 = 2000, J2 = 2000),
  L2 = c(N = 2000, E = 1000, J1 = 1000, J2 = 2000),
  L3 = c(N = 1000, E = 1000, J1 = 1000, J2 = 2000),
  L4 = c(N = 1000, E = 1000, J1 = 1000, J2 = 1000))
LIB_NIVEAUX_297 <- c(L0 = "\u2014", L1 = "MW E \u00e0 R = 1 000", L2 = "LN J1 \u00e0 R = 1 000", L3 = "MW N \u00e0 R = 1 000",
                     L4 = "LN J2 \u00e0 R = 1 000 (minimum)")
BUDGET_H_297 <- 10
SCRIPT_LN <- "tests/calibration_mc_t8.R"
TAILLE_LN <- 250L                 # replications par tranche lognormale (plan de Fk)
# Sens de rejet des treize cles au moteur de ce commit (compare au catalogue,
# controle (b)) : tableau du par. 1 de la specification, tenu a jour des
# changements du catalogue (R21, #354). Calendrier : "bas" depuis #276 ;
# MinP4 ("bas") a la place de Grubbs depuis #300 ; BP (variante FWr, #301) et
# PenteIntra (pente relative, #307) gardent leur cle et leur sens.
SENS_SPEC <- c(PenteIntra = "deux", Origine = "haut", HomogF = "haut", Courbure = "haut", Alpha = "haut",
               BP = "haut", ExpVar = "haut", Calendrier = "bas", KruskalAcc = "haut", CorrDev = "deux",
               DW = "deux", Runs = "deux", MinP4 = "bas")
CLES <- names(MW_CATALOGUE_MC)
NS <- length(CLES)
QUEUE <- vapply(CLES, function(s) MW_CATALOGUE_MC[[s]]$queue, "")
# Codes des motifs d'absence d'une p (engine_p_mc(), .mc_p_values()).
CODES_MOTIF <- c(o = MOTIF_MC_OBS_NON_FINIE, z = MOTIF_MC_AUCUNE_REPLIC, i = MOTIF_MC_REPLIC_INSUFFISANTES,
                 d = MOTIF_MC_DISPERSION_NULLE, c = MOTIF_MC_CONDITION, a = MOTIF_MC_ATOME_HORS_OBS)
LIB_MOTIF <- c(o = "obs. non finie", z = "B eff. = 0", i = "B eff. < B_MIN_DEGENERESCENCE", d = "dispersion nulle",
               c = "condition du catalogue", a = "atome hors obs.", "?" = "motif inconnu")
code_motif <- function(m) ifelse(is.na(m), "-", ifelse(m %in% CODES_MOTIF, names(CODES_MOTIF)[match(m, CODES_MOTIF)], "?"))
code_verdict <- function(v) if (is.null(v) || is.na(v)) "-" else switch(v, OK = "O", ALERTE = "A", ECHEC = "E", INFO = "I", "X")
code_nature <- function(n) if (is.null(n) || is.na(n)) "-" else if (n == "exacte") "x" else
  if (startsWith(n, "Monte-Carlo")) "m" else if (startsWith(n, "asymptotique")) "a" else "f"

# --- Texte du critere (par. 5), reporte SANS MODIFICATION (controle (t)) -----
TEXTE_CRITERE_206 <- c(
  "## 5. Crit\u00e8re, fix\u00e9 avant toute ex\u00e9cution",
  "",
  "Ce texte est report\u00e9 sans modification dans le script et au T0.",
  "",
  "**Grandeurs.**",
  "- D\u00e9cision D = 1 si p_mc < \u03b1.",
  "- **Une p absente compte comme un non-rejet.** Elle est compt\u00e9e \u00e0 part dans chaque cellule (#242), avec le taux sur les seules p d\u00e9finies en colonne descriptive.",
  "- Population : les triangles admis, b \u2208 1..R_(\u2113,pool).",
  "- \u03c4 = k/n, avec IC de Clopper-Pearson \u00e0 95 %.",
  "- **Classes de #166, avec \u03c1 pour r\u00e9f\u00e9rence** :",
  "  - *compatible* : \u03c1 \u2208 IC ;",
  "  - *\u00e9cart mineur* : estimation dans la bande de Bradley [\u03c1/2 ; 3\u03c1/2] ;",
  "  - *\u00e9cart non tranch\u00e9* : estimation hors de la bande, IC la recoupant ;",
  "  - *distorsion mat\u00e9rielle* : IC disjoint de la bande, avec son c\u00f4t\u00e9, lib\u00e9ral ou conservateur.",
  "- Classes calcul\u00e9es sur les valeurs **non arrondies** (#242, D-e).",
  "",
  "**Conditions** (\u00e9valu\u00e9es m\u00e9caniquement, **sans conclusion** dans le tableau) :",
  "- **K1, niveau, pool redress\u00e9** (crit\u00e8re principal) : classe de chaque (\u2113, s, \u03b1), pour \u2113 \u2208 {N, E}, et A si ex\u00e9cut\u00e9e.",
  "- **K2, brut contre redress\u00e9** : pour b \u2264 R_brut et pour chaque (\u2113, \u03b1), McNemar exact bilat\u00e9ral (binomiale de param\u00e8tre 1/2 sur n01 + n10) et Holm (1979) \u00e0 0,05 sur la famille des 13 cl\u00e9s. On rapporte les classes du pool brut et les \u00e9carts |\u03c4 \u2212 \u03c1| des deux pools sur les m\u00eames triangles.",
  "- **K3, t\u00e9moins** : pour chaque (\u2113, \u03b1), test binomial exact de \u03c4_or contre sa taille, Holm sur 13. **Un t\u00e9moin significatif suspend la lecture** jusqu'\u00e0 explication.",
  "- **K4, p absentes** : part des triangles o\u00f9 au moins une des 13 p_mc manque. Au plus 1 % par (\u2113, pool) ; au-del\u00e0, point de d\u00e9cision.",
  "- **K5, B effectif** (descriptif) : distribution, minimum, part < 999, motifs (`motif_mc`).",
  "",
  "**Profils de lecture propos\u00e9s pour B3** (actuary propose, le mainteneur tranche) :",
  "",
  "| Profil | Condition | Lecture propos\u00e9e |",
  "|---|---|---|",
  "| \u03a00 | K3 ou K4 en d\u00e9faut, non expliqu\u00e9 | Lecture suspendue ; mesure \u00e0 reprendre |",
  "| \u03a01 | Sous N et E, les 13 lignes sont compatibles ou en \u00e9cart mineur aux deux seuils | Constat document\u00e9 seul (rubrique 7, `sec:calibration-mc` volet MW) ; aucune \u00e9volution du moteur |",
  "| \u03a02 | Pas de distorsion mat\u00e9rielle, mais des \u00e9carts non tranch\u00e9s | Constat document\u00e9 avec ses IC ; aucune \u00e9volution |",
  "| \u03a03 | Distorsion mat\u00e9rielle **conservatrice** sur une ligne (IC sous \u03c1/2) | Les OK de la ligne sont une preuve faible (puissance), et une p de `reserve2` proche du seuil est probablement trop grande. Documenter ; issue B4 \u00e9ventuelle (correction de niveau), sans engagement de m\u00e9thode |",
  "| \u03a04 | Distorsion mat\u00e9rielle **lib\u00e9rale** sur une ligne, pour une loi | Les ALERTE et ECHEC de la ligne surestiment la preuve, en particulier les ECHEC de `reserve2` (Courbure, Alpha, Calendrier, DW). Issue B4 propos\u00e9e (correction de niveau ou passage en diagnostic) ; d\u00e9cision du mainteneur |",
  "| \u03a05 | Classes de sens oppos\u00e9s entre lois pour une ligne | Niveau non robuste \u00e0 la loi des erreurs, qu'aucune correction calibr\u00e9e sur une seule loi ne r\u00e8gle : documenter |",
  "",
  "**Effet de #46 (K2).**",
  "- R1 : aucun McNemar significatif apr\u00e8s Holm. Le redressement est sans effet mesurable sur le niveau.",
  "- R2 : effet significatif, qui rapproche \u03c4 de \u03c1. #46 est confort\u00e9e.",
  "- R3 : effet qui \u00e9loigne \u03c4 de \u03c1. Point du mainteneur : la variante B de #46 est \u00e0 revoir par une issue B4, pas dans cette branche.",
  "",
  "**Lignes \u00ab \u00e0 la fronti\u00e8re \u00bb de `reserve2`** (BP 0,103 ; Origine 0,085 ; HomogF 0,080) : elles sont lues avec leur \u03c4.",
  "- Compatible : le verdict est celui d'un test calibr\u00e9, au bruit Monte-Carlo pr\u00e8s, et c'est l'objet de Q-206-9, tranch\u00e9e en B3.",
  "- Conservateur : la p de `reserve2` surestime l'absence de preuve.",
  "- Lib\u00e9ral : l'inverse.",
  "- T4 donne, sous H0, la fr\u00e9quence des cas |p_mc \u2212 \u03b1| < 2 err_mc par ligne, c'est-\u00e0-dire la fr\u00e9quence \u00e0 laquelle le signalement propos\u00e9 se d\u00e9clencherait.",
  "",
  "**Multiplicit\u00e9 sous H0** (T4, descriptif) : part des triangles \u00e0 au moins une ALERTE ou un ECHEC, et \u00e0 au moins un ECHEC, sur les 13 lignes MC et sur toutes les lignes \u00e0 verdict. Le rep\u00e8re 1 \u2212 (1 \u2212 \u03b1)^13 est un ordre de grandeur, pas une r\u00e9f\u00e9rence.")
TITRE_B1 <- "## Annotation du 10/10/2026 : point d'arr\u00eat B1 franchi"

###############################################################################
#  LECTURE CONJOINTE (#297) : CRITERE DE FK, MEMBRES, ETATS, CONTROLE K-F3
###############################################################################
# Copie declaree dans tests/calibration_mc_t8.R : TEXTE_CRITERE_FK, RHO_F,
# fk_champ(), fk_num(), fk_membres(), fk_etats(), fk_recalcul(),
# profils_fk() (memes corps).
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

###############################################################################
#  DGP SOUS H0 (par. 2)
###############################################################################
AJ0 <- mw_ajuster(.tri)
JD0 <- .mw_colonnes_degenerees(AJ0)
POOL0 <- .mw_pool_residus(AJ0, JD0)
SD_POP0 <- sqrt(mean((POOL0 - mean(POOL0))^2))
POOL_E <- POOL0 / SD_POP0
moments <- function(x) {
  m <- mean(x); s <- sqrt(mean((x - m)^2))
  c(n = length(x), moyenne = m, ecart_type = s, asymetrie = mean((x - m)^3) / s^3,
    exces_kurtosis = mean((x - m)^4) / s^4 - 3, min = min(x), max = max(x))
}
# Tireur des epsilon de la loi (moyenne 0, variance 1).
tireur <- function(loi) switch(loi,
  N = function(n) stats::rnorm(n),
  E = function(n) sample(POOL_E, n, replace = TRUE),
  A = function(n) (stats::qgamma(stats::runif(n), 2) - 2) / sqrt(2))
# Generateur du DGP : meme recursion, meme expression, meme ordre de
# consommation des epsilon et meme arret que mw_simuler_triangle() (controle
# (g)) ; seul le tirage des epsilon change. Depuis #257 (aligne par #271) :
# triangle rendu des le premier cumul simule non fini ou <= 0, cellule a NA
# (jamais NaN : aucune racine carree d'un cumul negatif) et colonnes
# suivantes non tirees ; admettre() le refuse (motif "cellule <= 0"), sans
# retirage (par. 2). Nom distinct (par. 2) : une fonction mw_simuler_triangle
# definie ici masquerait celle qu'appelle mw_bootstrap().
gen_triangle_h0 <- function(aj, tirer) {
  I <- aj$I; J <- aj$J
  tri <- matrix(NA_real_, I + 1, J + 1)
  tri[, 1] <- aj$tri[, 1]
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    sg <- sqrt(aj$sigma2[j + 1])
    if (!is.finite(sg)) sg <- 0
    e <- tirer(length(idx))
    Cij <- tri[idx + 1, j + 1]
    nv <- Cij * aj$f[j + 1] + e * sg * sqrt(Cij)
    inval <- !is.finite(nv) | nv <= 0
    if (any(inval)) {
      nv[inval] <- NA_real_
      tri[idx + 1, j + 2] <- nv
      return(tri)
    }
    tri[idx + 1, j + 2] <- nv
  }
  tri
}
# Admission d'un triangle simule (par. 2) : motif de refus, ou ajustement.
# Cellule observee a NA (cumul simule non fini ou <= 0) : critere de
# .mw_triangle_incomplet() du moteur, celui de mw_bootstrap() (#257).
admettre <- function(tri) {
  if (.mw_triangle_incomplet(tri)) return(list(ok = FALSE, motif = "cellule <= 0"))
  v <- mw_valider_triangle(tri, segment = SEGMENT, annexe = ANNEXE)
  if (!isTRUE(v$ok)) return(list(ok = FALSE, motif = nettoyer_champ(paste("mw_valider_triangle :", paste(v$erreurs, collapse = " ; ")))))
  aj <- tryCatch(mw_ajuster(tri), error = function(e) e)
  if (inherits(aj, "error")) return(list(ok = FALSE, motif = nettoyer_champ(paste("mw_ajuster en erreur :", conditionMessage(aj)))))
  ms <- tryCatch(mw_msep(aj), error = function(e) e)
  if (inherits(ms, "error")) return(list(ok = FALSE, motif = nettoyer_champ(paste("mw_msep en erreur :", conditionMessage(ms)))))
  va <- mw_valider_ajustement(aj, ms$msep)
  if (!isTRUE(va$ok)) return(list(ok = FALSE, motif = nettoyer_champ(paste("mw_valider_ajustement :", paste(va$erreurs, collapse = " ; ")))))
  list(ok = TRUE, motif = NA_character_, aj = aj)
}
# Chemin oracle (par. 4) : statistiques d'un triangle comme une observee.
# jd passe explicitement, jni (colonnes non identifiables de la courbure,
# #270) et jno (de l'ordonnee a l'origine, #273) recalcules par le defaut de
# .mw_ensembles_figes() (#278), soit .mw_colonnes_courbure_non_identifiables(aj,
# jd) et .mw_colonnes_origine_non_identifiables(aj, jd) : les fonctions memes
# que mw_bootstrap() appelle pour figer jni et jno a l'observe. Le volet "oracle" de
# (i1) n'est donc pas un recalcul independant de jni (#280) : il verifie
# que la loi oracle est calculee avec la definition de la statistique
# observee de mw_bootstrap() (meme jd, meme jni par le chemin par defaut).
# La reecriture independante de jni (.jni_oracle()) est dans
# tests/unitaires/test_tables_mw.R (#270).
# .mw_stats() sans replique : evaluation observee (#300 : MinP4 NA si une cellule a une influence non bornee).
stats_oracle <- function(aj) .mw_stats(aj, .mw_ensembles_figes(aj, .mw_colonnes_degenerees(aj)))

# --- Pool brut d'avant #46 (par. 3, C-206-4) ----------------------------------
# Expression de b827726^:R/engine.R, mw_bootstrap() : res <- mw_residus(aj,
# jd) ; pool <- res$residu ; pool <- pool - mean(pool). Injectee dans
# l'environnement du moteur a la place de .mw_pool_residus, restauree par
# finally (technique de e88b6e6) ; aucun parametre ajoute au moteur.
POOL_ORIG <- get(".mw_pool_residus", envir = ENV_MOTEUR)
POOL_BRUT <- function(aj, j_degeneres = NULL) {
  res <- mw_residus(aj, j_degeneres)
  pool <- res$residu
  pool - mean(pool)
}
environment(POOL_BRUT) <- ENV_MOTEUR
avec_pool_brut <- function(expr) {
  assign(".mw_pool_residus", POOL_BRUT, envir = ENV_MOTEUR)
  tryCatch(expr, finally = assign(".mw_pool_residus", POOL_ORIG, envir = ENV_MOTEUR))
}
pool_restaure <- function() identical(get(".mw_pool_residus", envir = ENV_MOTEUR), POOL_ORIG)

# --- Regressions de #119 (par. 9) ---------------------------------------------
# (1) regression agregee SANS effet de colonne, poids C / sigma2_j ; (2)
# regression A effet de colonne, poids C seul ; t de la pente et p de
# Student bilaterale (summary.lm()). Residus de mw_residus(aj), comme M1.
regressions_119 <- function(aj) {
  na <- c(t_agr = NA_real_, p_agr = NA_real_, t_ceff = NA_real_, p_ceff = NA_real_)
  res <- mw_residus(aj)
  if (nrow(res) < 4 || stats::sd(res$C) == 0 || any(!is.finite(res$sigma_j)) || any(res$sigma_j <= 0)) return(na)
  d <- data.frame(F = res$F, C = res$C, j = res$j, w = res$C / res$sigma_j^2)
  pente <- function(m) {
    if (inherits(m, "try-error")) return(c(NA_real_, NA_real_))
    co <- suppressWarnings(summary(m))$coefficients
    if (!"C" %in% rownames(co)) c(NA_real_, NA_real_) else unname(co["C", 3:4])
  }
  a <- pente(try(stats::lm(F ~ C, weights = w, data = d), silent = TRUE))
  b <- if (length(unique(d$j)) >= 2L) pente(try(stats::lm(F ~ factor(j) + C, weights = C, data = d), silent = TRUE)) else c(NA_real_, NA_real_)
  c(t_agr = a[1], p_agr = a[2], t_ceff = b[1], p_ceff = b[2])
}

###############################################################################
#  COLONNES DES LIGNES MACHINE
###############################################################################
# Nombre de lignes de mw_tests() sur reserve2 : lu dans la reference versionnee
# (controle (a) : le moteur la reproduit ; controle (b) : LIGNES du moteur vivant
# a le meme nombre), jamais fige dans le script (R21, #354 : 19 fige, 21 lignes
# depuis #308).
NL_MAX <- length(readRDS(chemin_reference("reserve2"))$tests)
# Colonnes de lecture conjointe (#297), en fin de ligne : typ_R (types des
# lignes de mw_tests(), pool redresse, ordre de LIGNES : t test de sens "ne
# pas rejeter", r test de sens "rejeter", d diagnostic, n non applicable,
# - absente ; code_type()), puis
# par cle de famille (M1 a M4, puis la ligne globale LC) : etf (etat, voir
# fk_etats()), kf (k), bf (B effectif de famille), pf, ef et sf (p, err_mc et
# m_obs de la ligne), minf (plus petite p_mc des membres). Les cles sont
# ecrites ici et relues par FAM_MW (source unique).
COLS_TRANCHE <- c("b", "statut", "motif", "jd", "brut", "dur_R", "dur_B", "duree", "t_agr", "p_agr", "t_ceff", "p_ceff",
                  "verd_R", "verd_B", "nat_R", "nat_B",
                  paste0("obs:", CLES),
                  as.vector(t(outer(CLES, c("pR", "eR", "BR", "mR", "pB", "eB", "BB", "mB"), function(s, c) paste0(c, ":", s)))),
                  paste0("pas:", sprintf("%02d", seq_len(NL_MAX))), paste0("pex:", sprintf("%02d", seq_len(NL_MAX))),
                  "typ_R",
                  as.vector(t(outer(c("M1", "M2", "M3", "M4", "LC"), c("etf", "kf", "bf", "pf", "ef", "sf", "minf"),
                                    function(f, c) paste0(c, ":", f)))))
FAM_MW <- unique(sub("^etf:", "", grep("^etf:", COLS_TRANCHE, value = TRUE)))
stopifnot(identical(FAM_MW[length(FAM_MW)], PREFIXE_LECTURE_CONJOINTE))
# Libelle d'une ligne de mw_tests() : champ test ; pour une ligne de lecture
# conjointe (engine_p_famille(), meme champ test pour toutes les familles),
# suivi de la cle de sa famille entre crochets, pour des libelles distincts
# (controle (b), correspondance des colonnes verd_R, nat_R, typ_R, pas:, pex:).
libelle_ligne <- function(l) if (identical(fk_champ(l, "fonction"), "engine_p_famille"))
  sprintf("%s [%s]", l$test, substr(l$famille, 1L, 2L)) else l$test
# Ensemble "a la frontiere" (specification de Fk, par. 5.4 ; annotation du
# 24/10/2026 de la specification de #206, point 4) : lignes de
# tests/reference/reserve2.rds de type test, sens "ne pas rejeter", dont le
# detail se termine par PHRASE_VERDICT_SENSIBLE_MC (regle de #244 posee par
# add()), lues dans la reference versionnee comme NL_MAX, et non dans une
# liste ecrite en dur. Controle : l'inegalite est recalculee depuis p_mc et
# err_mc de chaque ligne (type test, pas de p exacte finie, p_mc finie,
# err_mc finie et > 0 ; |p_mc - s| < 2 err_mc pour un seuil s atteignable de
# la regle des verdicts, {alpha/2, alpha} en sens "ne pas rejeter",
# {alpha, SEUIL_ECHEC_SENS_REJETER} en sens "rejeter" ; s atteignable si le
# plancher, p_min_mc de la ligne s'il est fini, granularite_stat de la cle
# sinon, NA hors bootstrap, est NA ou < s) ; ok = FALSE au moindre desaccord
# entre la phrase et l'inegalite recalculee. Ecart documente a add() : la
# condition "aucun verdict fourni par l'appelant" n'est pas lisible dans la
# reference (aucun champ) ; aucun appel d'add() du moteur ne fournit de
# verdict a une ligne de type test (recherche de "verdict =" dans
# R/engine.R, 25/10/2026 : controles numeriques et enregistrement par add()
# seulement), de sorte que la condition est sans effet sur les lignes lues.
frontiere_reference <- function() {
  r <- readRDS(chemin_reference("reserve2"))
  L <- r$tests; gs <- r$bootstrap$granularite_stat
  phrase <- vapply(L, function(l) { d <- fk_champ(l, "detail"); !is.na(d) && endsWith(d, PHRASE_VERDICT_SENSIBLE_MC) }, logical(1))
  recalc <- vapply(L, function(l) {
    pm <- fk_num(l, "p_mc"); em <- fk_num(l, "err_mc"); mc <- fk_champ(l, "mc_nom"); pmm <- fk_num(l, "p_min_mc")
    if (!identical(fk_champ(l, "type"), "test") || is.finite(fk_num(l, "p_exacte")) || !is.finite(pm) || !is.finite(em) || em <= 0)
      return(FALSE)
    s <- if (identical(fk_champ(l, "sens"), "rejeter")) c(ALPHA, SEUIL_ECHEC_SENS_REJETER) else c(ALPHA / 2, ALPHA)
    g <- if (!is.na(mc) && mc %in% names(gs)) unname(gs[[mc]]) else NA_real_
    pl <- if (is.finite(pmm)) pmm else g
    s <- s[is.na(pl) | pl < s]
    any(abs(pm - s) < 2 * em)
  }, logical(1))
  fr <- phrase & vapply(L, function(l) identical(fk_champ(l, "type"), "test") && identical(fk_champ(l, "sens"), "ne pas rejeter"), logical(1))
  cles <- vapply(L[fr], fk_champ, "", "mc_nom")
  ecart <- which(phrase != recalc)
  list(ok = !length(ecart) && !anyNA(cles), cles = unname(cles),
       txt = sprintf(paste("ensemble \u00ab \u00e0 la fronti\u00e8re \u00bb lu dans tests/reference/reserve2.rds (lignes de type test, sens \u00ab ne pas rejeter \u00bb,",
                           "detail termin\u00e9 par PHRASE_VERDICT_SENSIBLE_MC) : %s ; in\u00e9galit\u00e9 |p_mc \u2212 s| < 2 err_mc recalcul\u00e9e (s atteignable) :",
                           "%s"),
                     if (length(cles)) paste(sprintf("%s (p_mc %s, err_mc %s)", cles, vapply(L[fr], function(l) num(fk_num(l, "p_mc"), 3), ""),
                                                     vapply(L[fr], function(l) num(fk_num(l, "err_mc"), 4), "")), collapse = ", ") else "vide",
                     if (length(ecart)) paste("D\u00c9SACCORD sur", paste(vapply(L[ecart], libelle_ligne, ""), collapse = " ; ")) else
                       "accord sur toutes les lignes"))
}
COLS_ORACLE <- c("k", "statut", "motif", "jd", paste0("obs:", CLES))
COLS_SM <- c("b", "statut", "motif", "jd", "nW", "nD", "n_jd_diff", "W_obs", "D_obs", "pW_bas", "pW_haut", "pD_bas", "pD_haut", "duree")
COLS <- list(tranche = COLS_TRANCHE, oracle = COLS_ORACLE, sm = COLS_SM)
ETQ <- c(tranche = "REP", oracle = "ORA", sm = "SM")
CARACTERE <- c("statut", "motif", "jd", "brut", "verd_R", "verd_B", "nat_R", "nat_B", paste0(c("mR:", "mB:"), rep(CLES, each = 2)),
               "typ_R", paste0("etf:", FAM_MW))
en_table <- function(champs, cols) {
  if (!length(champs)) {
    d <- as.data.frame(matrix(character(0), 0, length(cols), dimnames = list(NULL, cols)), stringsAsFactors = FALSE)
  } else {
    M <- do.call(rbind, champs); colnames(M) <- cols
    d <- as.data.frame(M, stringsAsFactors = FALSE)
  }
  for (k in setdiff(cols, CARACTERE)) d[[k]] <- suppressWarnings(as.numeric(d[[k]]))
  d
}
# Invariants (d) d'une p : B_eff <= 999 ; p sur la grille k/(B_eff + 1)
# (x 2 en bilateral, plafonnee a 1).
sur_grille <- function(p, B, queue) {
  if (!is.finite(p)) return(TRUE)
  if (!is.finite(B) || B < 1 || B > B_BOOT) return(FALSE)
  k <- if (queue == "deux") 2 else 1
  x <- p * (B + 1) / k
  p == 1 || abs(x - round(x)) < 1e-6
}

###############################################################################
#  REFERENCE rho, TEMOIN, LECTURE D'UN TAUX (par. 4 et 5)
###############################################################################
# Taille lissee du test de Monte-Carlo ideal a B repliques tirees dans F0,
# regle ">=" d'engine_p_mc() (par. 4) :
#   haut : moyenne sur F0 de P(Bin(B, q+(s)) <= ceil(a (B + 1)) - 2),
#          q+(s) = P0(S >= s) ;
#   bas  : symetrique (q-(s) = P0(S <= s)) ;
#   deux : somme des deux termes a ceil(a (B + 1)/2) - 2 (evenements
#          disjoints).
# S : statistiques FINIES de l'echantillon oracle ; n_tot : triangles oracle
# admis (une statistique non finie y compte comme un non-rejet, comme une p
# absente dans le critere ; q+ et q- sont lues sur les valeurs finies, comme
# le B effectif d'engine_p_mc()).
taille_lissee <- function(S, queue, B, a, n_tot = length(S)) {
  n <- length(S)
  if (!n || !n_tot) return(NA_real_)
  Ss <- sort(S)
  q_hi <- (n - findInterval(S, Ss, left.open = TRUE)) / n
  q_lo <- findInterval(S, Ss) / n
  c1 <- ceiling(round(a * (B + 1), 9)) - 2; c2 <- ceiling(round(a * (B + 1) / 2, 9)) - 2
  t <- switch(queue, haut = stats::pbinom(c1, B, q_hi), bas = stats::pbinom(c1, B, q_lo),
              deux = stats::pbinom(c2, B, q_hi) + stats::pbinom(c2, B, q_lo))
  sum(t) / n_tot
}
# Lecture d'un taux contre la reference rho (classes de #166, par. 5) :
# compatible (rho dans l'IC) ; distorsion materielle (IC disjoint de la
# bande [rho/2 ; 3 rho/2], avec son cote) ; ecart mineur (taux dans la
# bande) ; ecart non tranche (sinon). Valeurs non arrondies (D-e).
CLASSES <- c("compatible", "\u00e9cart mineur", "\u00e9cart non tranch\u00e9", "distorsion mat\u00e9rielle")
lecture <- function(k, n, ref) {
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
txt_lec <- function(c_) sprintf("%s %s", num(c_$taux, D_IC), txt_ic(c_$ci))
txt_classe <- function(c_) if (c_$disj) sprintf("%s (**%s**)", c_$classe, c_$cote) else c_$classe
# McNemar exact (test binomial bilateral de parametre 1/2 sur les paires
# discordantes) ; p = 1 sans paire discordante.
mcnemar <- function(d1, d2) {
  n01 <- sum(d1 & !d2); n10 <- sum(!d1 & d2); n <- n01 + n10
  c(n01 = n01, n10 = n10, p = if (n) stats::binom.test(n01, n, 0.5)$p.value else 1)
}
# Cellule d'un taux : p (vecteur sur la population), seuil a ; une p absente
# compte comme un non-rejet et est comptee a part (#242).
cellule <- function(p, a, ref) {
  fin <- is.finite(p); k <- sum(fin & p < a)
  x <- lecture(k, length(p), ref)
  x$absentes <- sum(!fin); x$taux_def <- if (any(fin)) k / sum(fin) else NA_real_
  x
}
lib_ia <- function(ia) c(a10 = "0,10", a05 = "0,05")[[ia]]
lib_cle <- function(s) sprintf("%s (%s)", s, QUEUE[[s]])

###############################################################################
#  TABLEAUX (tranche partielle et --combiner)
###############################################################################
# DS : liste(tr = {loi : table REP}, ora = {loi : table ORA}, sm = table SM,
#   R = R par (loi, pool), lignes = libelles des lignes de mw_tests(),
#   cle_ligne = indice de ligne de chaque cle, essai, reduit).
# Population (par. 5) : triangles admis de 1..R_(loi, pool).
pop <- function(D, pool) {
  if (is.null(D) || !nrow(D)) return(D)
  k <- D$statut == "admis"
  if (pool == "brut") k <- k & D$brut == "oui"
  D[k, , drop = FALSE]
}
mat_p <- function(D, ch) { M <- as.matrix(D[, paste0(ch, ":", CLES), drop = FALSE]); dimnames(M) <- list(NULL, CLES); M }
# Oracle : statistiques finies, rho, taille du temoin, diagnostics d'atomes.
resume_oracle <- function(O) {
  adm <- O[O$statut == "admis", , drop = FALSE]
  n_adm <- nrow(adm)
  lapply(stats::setNames(nm = CLES), function(s) {
    S <- adm[[paste0("obs:", s)]]; S <- S[is.finite(S)]
    tab <- if (length(S)) table(S) else integer(0)
    list(n_adm = n_adm, n_fin = length(S), n_nonfini = n_adm - length(S), distinctes = length(tab),
         atome = if (length(S)) max(tab) / length(S) else NA_real_,
         rho = vapply(SEUILS, function(a) taille_lissee(S, QUEUE[[s]], B_BOOT, a, n_adm), 1),
         # Taille du temoin (K3, annotation 2 (b)) : meme regle qu'a rho, a
         # B = nombre de statistiques finies ; meme denominateur n_adm
         # (statistique non finie comptee comme non-rejet, comme pour rho).
         taille_or = vapply(SEUILS, function(a) taille_lissee(S, QUEUE[[s]], length(S), a, n_adm), 1),
         nominal_or = vapply(SEUILS, function(a) if (QUEUE[[s]] == "deux") 2 * (ceiling(round(a * (length(S) + 1) / 2, 9)) - 1) / (length(S) + 1) else
           (ceiling(round(a * (length(S) + 1), 9)) - 1) / (length(S) + 1), 1),
         S0 = adm[[paste0("obs:", s)]])
  })
}
# rho approche (annotation 2 (a)) : au-dela de 1 % de statistiques oracle
# non finies pour une cle, rho suppose B = 999 repliques finies et n'est
# qu'approche (le B effectif d'engine_p_mc() serait plus petit).
SEUIL_RHO_APPROCHE <- 0.01
rho_approche <- function(o) o$n_adm > 0 && o$n_nonfini / o$n_adm > SEUIL_RHO_APPROCHE
cles_rho_approche <- function(OR) unlist(lapply(intersect(LOIS, names(OR)), function(loi)
  vapply(Filter(function(s) rho_approche(OR[[loi]][[s]]), CLES), function(s)
    sprintf("%s %s (%d / %d non finies)", loi, s, OR[[loi]][[s]]$n_nonfini, OR[[loi]][[s]]$n_adm), "")))
REF_RHO <- function(OR, loi) {
  M <- matrix(NA_real_, NS, 2, dimnames = list(CLES, IA))
  if (!is.null(OR[[loi]])) for (s in CLES) M[s, ] <- OR[[loi]][[s]]$rho
  M
}
# p du temoin oracle d'un triangle mesure (par. 4, K3).
p_oracle <- function(OR, loi, D) {
  P <- matrix(NA_real_, nrow(D), NS, dimnames = list(NULL, CLES))
  if (is.null(OR[[loi]]) || !nrow(D)) return(P)
  for (s in CLES) {
    S0 <- OR[[loi]][[s]]$S0
    P[, s] <- vapply(D[[paste0("obs:", s)]], function(o) engine_p_mc(S0, o, QUEUE[[s]])$p_mc, 1)
  }
  P
}

tableau_rho <- function(OR, DS) {
  L <- c("### R\u00e9f\u00e9rence \u03c1 et diagnostics de l'oracle (par. 4)", "",
         paste("\u03c1 : taille liss\u00e9e \u00e0 B = 999 du test de Monte-Carlo id\u00e9al tirant ses r\u00e9pliques dans F0 (r\u00e8gle \u00ab \u2265 \u00bb",
               "d'engine_p_mc(), une r\u00e8gle unique pour toutes les statistiques, aucune classification a priori) ; statistique",
               "oracle non finie compt\u00e9e comme non-rejet. Erreur de \u03c1 due \u00e0 N0 : de l'ordre de 0,002 \u00e0 \u03b1 = 0,10 [H], distincte",
               "de l'IC sur \u03c4 (fonction de R) et de err_mc (fonction de B). Taille du t\u00e9moin : m\u00eame r\u00e8gle \u00e0 B = N0 fini,",
               "m\u00eame d\u00e9nominateur (oracle admis ; statistique non finie compt\u00e9e comme non-rejet, comme pour \u03c1) ; nominale continue",
               "\u00e0 B = nombre de statistiques finies entre parenth\u00e8ses (un \u00e9cart taille < nominale peut venir des",
               "non finies ou des atomes). \u03c1 marqu\u00e9 \u00ab approch\u00e9 \u00bb au-del\u00e0 de 1 % de statistiques oracle non finies pour la cl\u00e9",
               "(\u03c1 suppose alors B = 999 r\u00e9pliques finies ; annotation du 10/10/2026 de la sp\u00e9cification, point 2 (a))."), "",
         entete_md(c("Loi", "Cl\u00e9 (sens)", "oracle admis", "non finies", "valeurs distinctes", "masse du plus gros atome",
                     "\u03c1 0,10", "\u03c1 0,05", "taille t\u00e9moin 0,10 (nominale)", "taille t\u00e9moin 0,05 (nominale)")))
  for (loi in intersect(LOIS, names(OR))) for (s in CLES) {
    o <- OR[[loi]][[s]]
    ap <- if (rho_approche(o)) " (**approch\u00e9**)" else ""
    L <- c(L, ligne_md(loi, lib_cle(s), o$n_adm, o$n_nonfini, o$distinctes, num(o$atome, 5), paste0(num(o$rho[1], 5), ap), paste0(num(o$rho[2], 5), ap),
                       sprintf("%s (%s)", num(o$taille_or[1], 5), num(o$nominal_or[1], 5)),
                       sprintf("%s (%s)", num(o$taille_or[2], 5), num(o$nominal_or[2], 5))))
  }
  c(L, "")
}

# T1 / T1 bis : taux par (loi, cle, alpha).
cellules_pool <- function(DS, OR, pool) {
  out <- list()
  for (loi in intersect(LOIS, names(DS$tr))) {
    D <- pop(DS$tr[[loi]], pool)
    if (is.null(D)) next
    P <- mat_p(D, if (pool == "brut") "pB" else "pR"); REF <- REF_RHO(OR, loi)
    for (s in CLES) for (ia in IA) {
      c_ <- cellule(P[, s], SEUILS[match(ia, IA)], REF[s, ia])
      out[[length(out) + 1L]] <- list(loi = loi, s = s, ia = ia, ref = REF[s, ia], c = c_)
    }
  }
  out
}
tableau_t1 <- function(CEL, titre) {
  L <- c(titre, "",
         paste("Par seuil : n triangles admis, p absentes (compt\u00e9es comme non-rejet), k rejets (p_mc < \u03b1), taux k / n et IC de",
               "Clopper-Pearson \u00e0 95 % (5 d\u00e9cimales), classe de #166 contre \u03c1 (c\u00f4t\u00e9 en gras si l'IC est disjoint de la bande",
               "[\u03c1/2 ; 3\u03c1/2]), taux sur les seules p d\u00e9finies (descriptif)."), "",
         entete_md(c("Loi", "Cl\u00e9 (sens)", "n", "abs. 0,10", "\u03c1 0,10", "k 0,10", "taux [IC] 0,10", "classe 0,10", "taux d\u00e9f. 0,10",
                     "abs. 0,05", "\u03c1 0,05", "k 0,05", "taux [IC] 0,05", "classe 0,05", "taux d\u00e9f. 0,05")))
  cle <- vapply(CEL, function(x) paste(x$loi, x$s), "")
  for (u in unique(cle)) {
    x <- CEL[cle == u]
    cols <- unlist(lapply(x, function(z) c(z$c$absentes, num(z$ref, 5), z$c$k, txt_lec(z$c), txt_classe(z$c), num(z$c$taux_def, D_IC))))
    L <- c(L, ligne_md(x[[1]]$loi, lib_cle(x[[1]]$s), x[[1]]$c$n, paste(cols, collapse = " | ")))
  }
  c(L, "")
}
# T2 : McNemar brut contre redresse, sur les memes triangles (b <= R_brut).
mcnemar_pools <- function(DS, OR) {
  out <- list()
  for (loi in intersect(c("N", "E"), names(DS$tr))) {
    D <- pop(DS$tr[[loi]], "brut")
    if (is.null(D) || !nrow(D)) next
    PR <- mat_p(D, "pR"); PB <- mat_p(D, "pB"); REF <- REF_RHO(OR, loi)
    for (ia in IA) {
      a <- SEUILS[match(ia, IA)]
      r <- t(vapply(CLES, function(s) mcnemar(is.finite(PR[, s]) & PR[, s] < a, is.finite(PB[, s]) & PB[, s] < a), numeric(3)))
      tR <- colMeans(is.finite(PR) & PR < a); tB <- colMeans(is.finite(PB) & PB < a)
      out[[length(out) + 1L]] <- data.frame(loi = loi, ia = ia, s = CLES, n = nrow(D), n01 = r[, "n01"], n10 = r[, "n10"], p = r[, "p"],
                                            p_holm = stats::p.adjust(r[, "p"], "holm"), tau_R = tR, tau_B = tB, rho = REF[, ia],
                                            stringsAsFactors = FALSE)
    }
  }
  if (length(out)) do.call(rbind, out) else NULL
}
tableau_t2 <- function(MC) {
  L <- c("### T2 \u2014 pool brut contre pool redress\u00e9 (#46), m\u00eames triangles et m\u00eames graines (b \u2264 R_brut)", "",
         paste("McNemar exact bilat\u00e9ral (binomiale de param\u00e8tre 1/2 sur n01 + n10 ; n01 : redress\u00e9 rejette, brut non ;",
               "n10 : brut rejette, redress\u00e9 non), Holm (1979) au niveau 0,05 sur la famille des 13 cl\u00e9s par (loi, \u03b1) ;",
               "\u00e9carts |\u03c4 \u2212 \u03c1| des deux pools sur les m\u00eames triangles. Lecture R1 \u00e0 R3 : \u00e9valuation m\u00e9canique en fin de tableau."), "")
  if (is.null(MC)) return(c(L, "Pool brut absent de cette sortie.", ""))
  L <- c(L, entete_md(c("Loi", "\u03b1", "Cl\u00e9 (sens)", "n", "n01 / n10", "p", "p Holm", "significatif", "\u03c4 redress\u00e9", "\u03c4 brut",
                        "\u03c1", "\\|\u03c4_R \u2212 \u03c1\\|", "\\|\u03c4_B \u2212 \u03c1\\|")))
  for (i in seq_len(nrow(MC))) {
    x <- MC[i, ]
    L <- c(L, ligne_md(x$loi, lib_ia(x$ia), lib_cle(x$s), x$n, sprintf("%d / %d", x$n01, x$n10), fmt_p(x$p), fmt_p(x$p_holm),
                       if (x$p_holm < NIVEAU_HOLM) "oui" else "non", num(x$tau_R, D_IC), num(x$tau_B, D_IC), num(x$rho, 5),
                       num(abs(x$tau_R - x$rho), D_IC), num(abs(x$tau_B - x$rho), D_IC)))
  }
  c(L, "")
}
# T3 : temoins oracle (K3).
temoins <- function(DS, OR) {
  out <- list()
  for (loi in intersect(LOIS, names(DS$tr))) {
    if (is.null(OR[[loi]])) next
    D <- pop(DS$tr[[loi]], "redresse")
    if (!nrow(D)) next
    P <- p_oracle(OR, loi, D)
    for (ia in IA) {
      a <- SEUILS[match(ia, IA)]; j <- match(ia, IA)
      k <- colSums(is.finite(P) & P < a); ab <- colSums(!is.finite(P))
      tl <- vapply(CLES, function(s) OR[[loi]][[s]]$taille_or[j], 1)
      p <- vapply(CLES, function(s) if (is.finite(tl[[s]])) stats::binom.test(k[[s]], nrow(D), tl[[s]])$p.value else NA_real_, 1)
      out[[length(out) + 1L]] <- data.frame(loi = loi, ia = ia, s = CLES, n = nrow(D), absentes = ab, k = k, taille = tl, p = p,
                                            p_holm = stats::p.adjust(p, "holm"), stringsAsFactors = FALSE)
    }
  }
  if (length(out)) do.call(rbind, out) else NULL
}
tableau_t3 <- function(TM) {
  L <- c("### T3 \u2014 t\u00e9moins oracle (K3)", "",
         paste("p_or = engine_p_mc(S0, s_obs, sens) contre l'\u00e9chantillon oracle de la loi (N0 triangles i.i.d. du m\u00eame DGP) ;",
               "test binomial exact bilat\u00e9ral du taux \u03c4_or contre la taille du t\u00e9moin (tableau de \u03c1), Holm sur les 13 cl\u00e9s par",
               "(loi, \u03b1). Un t\u00e9moin significatif suspend la lecture jusqu'\u00e0 explication (par. 5).",
               "Limite d\u00e9clar\u00e9e (annotation du 10/10/2026 de la sp\u00e9cification, point 2) : un seul \u00e9chantillon oracle sert \u00e0 tous",
               "les triangles mesur\u00e9s ; Var(\u03c4_or) vaut donc environ \u03b1(1 \u2212 \u03b1)(1/n + 1/N0), et non \u03b1(1 \u2212 \u03b1)/n. \u00c0 n = 2 000",
               "et N0 = 20 000, l'\u00e9cart-type est multipli\u00e9 par environ 1,05 et le binomial nominal \u00e0 5 % rejette environ 6 % du temps",
               "quand la mesure est correcte [calcul d'ordre de grandeur, non simul\u00e9]. Ce l\u00e9ger exc\u00e8s de signalement n'est pas",
               "corrig\u00e9 ; il entre dans le jugement \u00ab non expliqu\u00e9 \u00bb de \u03a00."), "")
  if (is.null(TM)) return(c(L, "Oracle absent de cette sortie : t\u00e9moins non calcul\u00e9s.", ""))
  L <- c(L, entete_md(c("Loi", "\u03b1", "Cl\u00e9 (sens)", "n", "p_or absentes", "k", "\u03c4_or [IC]", "taille", "p binomiale", "p Holm", "significatif")))
  for (i in seq_len(nrow(TM))) {
    x <- TM[i, ]
    L <- c(L, ligne_md(x$loi, lib_ia(x$ia), lib_cle(x$s), x$n, x$absentes, x$k, sprintf("%s %s", num(x$k / x$n, D_IC), txt_ic(ic_cp(x$k, x$n))),
                       num(x$taille, 5), fmt_p(x$p), fmt_p(x$p_holm), if (isTRUE(x$p_holm < NIVEAU_HOLM)) "**oui**" else "non"))
  }
  c(L, "")
}
# T4 : verdicts, multiplicite, frequence de |p_mc - alpha| < 2 err_mc.
tableau_t4 <- function(DS) {
  # n = nombre de cles dont la ligne porte un verdict (O, A ou E) sur au moins
  # un triangle admis, tous pools et toutes lois : celles des colonnes "lignes
  # MC a verdict" ; une ligne INFO (diagnostic) n'y compte pas.
  vd <- unlist(lapply(intersect(LOIS, names(DS$tr)), function(l) c(pop(DS$tr[[l]], "redresse")$verd_R, pop(DS$tr[[l]], "brut")$verd_B)))
  n_mc <- sum(vapply(DS$cle_ligne, function(i) any(substring(vd, i, i) %in% c("O", "A", "E")), logical(1)))
  L <- c("### T4 \u2014 verdicts sous H0, multiplicit\u00e9, voisinage du seuil", "",
         paste("Fr\u00e9quences sur les triangles admis : ALERTE ou ECHEC (A ou E) et ECHEC (E) par ligne de mw_tests() (lignes INFO",
               "exclues du d\u00e9nominateur) ; part des triangles \u00e0 au moins une ALERTE ou un ECHEC, et \u00e0 au moins un ECHEC, sur les lignes",
               "Monte-Carlo \u00e0 verdict (une ligne Monte-Carlo INFO, diagnostic, n'y compte pas) et sur toutes les lignes \u00e0 verdict (rep\u00e8re",
               sprintf("1 \u2212 (1 \u2212 \u03b1)^n avec n = %d lignes Monte-Carlo \u00e0 verdict : %s \u00e0 \u03b1 = 0,10, ordre de grandeur et non r\u00e9f\u00e9rence) ;", n_mc, num(1 - 0.9^n_mc, 4)),
               "fr\u00e9quence de |p_mc \u2212 \u03b1| < 2 err_mc par cl\u00e9 (signalement propos\u00e9 de Q-206-9), aux deux seuils, sur les p d\u00e9finies."), "")
  idx_mc <- DS$cle_ligne
  for (pool in c("redresse", "brut")) {
    vc <- if (pool == "brut") "verd_B" else "verd_R"
    lois <- intersect(LOIS, names(DS$tr))
    lois <- lois[vapply(lois, function(l) nrow(pop(DS$tr[[l]], pool)) > 0, logical(1))]
    if (!length(lois)) next
    L <- c(L, sprintf("**Pool %s.**", if (pool == "brut") "brut" else "redress\u00e9"), "",
           entete_md(c("Ligne de mw_tests()", "cl\u00e9", paste("loi", lois, ": A ou E / E (n)"))))
    for (i in seq_along(DS$lignes)) {
      cols <- vapply(lois, function(l) {
        v <- substr(pop(DS$tr[[l]], pool)[[vc]], i, i); v <- v[v %in% c("O", "A", "E")]
        if (!length(v)) "\u2014" else sprintf("%s / %s (%d)", num(mean(v %in% c("A", "E")), D_IC), num(mean(v == "E"), D_IC), length(v))
      }, "")
      L <- c(L, ligne_md(DS$lignes[i], if (i %in% idx_mc) names(idx_mc)[match(i, idx_mc)] else "", paste(cols, collapse = " | ")))
    }
    L <- c(L, "", entete_md(c("Loi", "n", "\u2265 1 A ou E (lignes MC \u00e0 verdict)", "\u2265 1 E (lignes MC \u00e0 verdict)", "\u2265 1 A ou E (toutes lignes \u00e0 verdict)",
                              "\u2265 1 E (toutes lignes \u00e0 verdict)")))
    for (l in lois) {
      v <- pop(DS$tr[[l]], pool)[[vc]]
      vm <- vapply(v, function(x) paste(substring(x, idx_mc, idx_mc), collapse = ""), "", USE.NAMES = FALSE)
      L <- c(L, ligne_md(l, length(v), num(mean(grepl("[AE]", vm)), D_IC), num(mean(grepl("E", vm, fixed = TRUE)), D_IC),
                         num(mean(grepl("[AE]", v)), D_IC), num(mean(grepl("E", v, fixed = TRUE)), D_IC)))
    }
    L <- c(L, "", entete_md(c("Loi", "Cl\u00e9", "p d\u00e9finies", "\\|p \u2212 0,10\\| < 2 err_mc", "\\|p \u2212 0,05\\| < 2 err_mc")))
    for (l in lois) {
      D <- pop(DS$tr[[l]], pool); P <- mat_p(D, if (pool == "brut") "pB" else "pR"); E <- mat_p(D, if (pool == "brut") "eB" else "eR")
      for (s in CLES) {
        f <- is.finite(P[, s]) & is.finite(E[, s])
        L <- c(L, ligne_md(l, s, sum(f), num(if (any(f)) mean(abs(P[f, s] - 0.10) < 2 * E[f, s]) else NA, D_IC),
                           num(if (any(f)) mean(abs(P[f, s] - 0.05) < 2 * E[f, s]) else NA, D_IC)))
      }
    }
    L <- c(L, "")
  }
  L
}
# T5 : B effectif, p absentes, motifs, refus, durees.
tableau_t5 <- function(DS) {
  L <- c("### T5 \u2014 B effectif, p absentes, triangles refus\u00e9s, dur\u00e9es", "")
  L <- c(L, entete_md(c("Loi", "Pool", "n admis", "B eff. min", "B eff. m\u00e9diane", "part des (triangle, cl\u00e9) \u00e0 B eff. < 999",
                        "triangles \u00e0 \u2265 1 p absente (K4)", "p absentes par motif", "dur\u00e9e par triangle (s) : moy. [m\u00e9d. ; max]")))
  for (l in intersect(LOIS, names(DS$tr))) for (pool in c("redresse", "brut")) {
    D <- pop(DS$tr[[l]], pool)
    if (is.null(D) || !nrow(D)) next
    pf <- if (pool == "brut") c("pB", "BB", "mB", "dur_B") else c("pR", "BR", "mR", "dur_R")
    Bm <- mat_p(D, pf[2]); P <- mat_p(D, pf[1]); M <- mat_p(D, pf[3])
    mo <- M[M != "-"]
    txt_mo <- if (!length(mo)) "aucune" else { t <- table(mo); paste(sprintf("%s %d", ifelse(names(t) %in% names(LIB_MOTIF), LIB_MOTIF[names(t)], names(t)), as.integer(t)), collapse = ", ") }
    k4 <- mean(apply(!is.finite(P), 1, any))
    du <- D[[pf[4]]]
    L <- c(L, ligne_md(l, if (pool == "brut") "brut" else "redress\u00e9", nrow(D), sprintf("%.0f", min(Bm)), sprintf("%.0f", stats::median(Bm)),
                       num(mean(Bm < B_BOOT), 5), sprintf("%d (%s)", sum(apply(!is.finite(P), 1, any)), num(k4, 5)), txt_mo,
                       sprintf("%s [%s ; %s]", num(mean(du), 1), num(stats::median(du), 1), num(max(du), 1))))
  }
  L <- c(L, "", entete_md(c("Loi", "triangles", "admis", "refus\u00e9s", "part refus\u00e9e", "motifs de refus", "en erreur")))
  for (l in intersect(LOIS, names(DS$tr))) {
    D <- DS$tr[[l]]; rf <- D$statut == "refuse"
    mo <- if (any(rf)) { t <- table(D$motif[rf]); paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") } else "aucun"
    L <- c(L, ligne_md(l, nrow(D), sum(D$statut == "admis"), sum(rf), num(mean(rf), 5), mo, sum(D$statut == "erreur")))
  }
  for (l in intersect(LOIS, names(DS$ora))) {
    O <- DS$ora[[l]]; rf <- O$statut == "refuse"
    mo <- if (any(rf)) { t <- table(O$motif[rf]); paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") } else "aucun"
    L <- c(L, ligne_md(sprintf("%s (oracle)", l), nrow(O), sum(O$statut == "admis"), sum(rf), num(mean(rf), 5), mo, sum(O$statut == "erreur")))
  }
  c(L, "")
}
# T6 (#119) : regressions agregees, p asymptotiques, lignes M5 (pool
# redresse ; ces p ne dependent pas du pool).
tableau_t6 <- function(DS) {
  L <- c("### T6 (#119) \u2014 p nominales sous H0, triangles 8 \u00d7 8 du plan reserve2", "",
         paste("Taux de rejet k / n [IC de Clopper-Pearson \u00e0 95 %] aux seuils 0,10 et 0,05 sur les triangles admis du pool redress\u00e9",
               "(p absente = non-rejet, compt\u00e9e). (1) r\u00e9gression agr\u00e9g\u00e9e SANS effet de colonne lm(F ~ C, poids C / \u03c3\u0302\u00b2_j),",
               "p de Student bilat\u00e9rale ; (2) r\u00e9gression \u00e0 effet de colonne lm(F ~ factor(j) + C), poids C seul ; (3) p asymptotique",
               "de chaque ligne de mw_tests() qui en a une (dont PenteIntra, Student \u00e0 effet fixe) ; (4) lignes M5 (Shapiro-Wilk : p",
               "exacte ; Lilliefors : p asymptotique). Avec le bootstrap, la relation m\u00e9canique de (1) serait reproduite dans les",
               "r\u00e9pliques : l'affirmation de #119 ne peut porter que sur la p nominale [H, argument] (par. 9)."), "",
         entete_md(c("Loi", "Grandeur", "n", "p absentes", "taux 0,10 [IC]", "taux 0,05 [IC]")))
  ligne_taux <- function(l, lib, p) {
    n <- length(p); fin <- is.finite(p)
    cel <- vapply(SEUILS, function(a) { k <- sum(fin & p < a); sprintf("%s %s", num(k / n, D_IC), txt_ic(ic_cp(k, n))) }, "")
    ligne_md(l, lib, n, sum(!fin), cel[1], cel[2])
  }
  for (l in intersect(LOIS, names(DS$tr))) {
    D <- pop(DS$tr[[l]], "redresse")
    if (!nrow(D)) next
    L <- c(L, ligne_taux(l, "(1) r\u00e9gression agr\u00e9g\u00e9e sans effet de colonne", D$p_agr),
           ligne_taux(l, "(2) effet de colonne, poids C seul", D$p_ceff))
    for (i in seq_along(DS$lignes)) {
      pa <- D[[sprintf("pas:%02d", i)]]; pe <- D[[sprintf("pex:%02d", i)]]
      if (any(is.finite(pa))) L <- c(L, ligne_taux(l, sprintf("(3) p asymptotique : %s", DS$lignes[i]), pa))
      if (any(is.finite(pe))) L <- c(L, ligne_taux(l, sprintf("(4) p exacte : %s", DS$lignes[i]), pe))
    }
  }
  c(L, "")
}
# T7 (#119) : sous-mesure N.
tableau_t7 <- function(DS) {
  L <- c("### T7 (#119) \u2014 sous-mesure N : normalit\u00e9 des r\u00e9sidus dans le bootstrap", "",
         paste("Loi N, pool redress\u00e9, b \u2264 500 : les 999 triangles bootstrap de mw_bootstrap() sont r\u00e9g\u00e9n\u00e9r\u00e9s sous la graine du",
               "triangle (contr\u00f4le (s)) et r\u00e9ajust\u00e9s ; W de Shapiro-Wilk (.shapiro_sur()) et D de Lilliefors (stat_lilliefors()) sur",
               "les r\u00e9sidus de Mack (ensemble des colonnes d\u00e9g\u00e9n\u00e9r\u00e9es fig\u00e9 \u00e0 l'observ\u00e9, comme le contexte du bootstrap) ; p_mc",
               "par engine_p_mc() en queue basse et en queue haute ; taux k / n [IC 95 %], p absente = non-rejet."), "")
  S <- DS$sm
  if (is.null(S) || !nrow(S)) return(c(L, "Sous-mesure N absente de cette sortie.", ""))
  A <- S[S$statut == "admis", , drop = FALSE]
  # Repliques dont l'ensemble des colonnes degenerees recalcule differe de
  # l'ensemble fige (annotation 4 de la specification) : attendu 0.
  nj <- A$n_jd_diff; tj <- sum(nj > 0, na.rm = TRUE)
  L <- c(L, sprintf("Triangles : %d, admis %d, refus\u00e9s %d ; B effectif W : min %.0f, m\u00e9diane %.0f ; D : min %.0f, m\u00e9diane %.0f.",
                    nrow(S), nrow(A), sum(S$statut == "refuse"), min(A$nW), stats::median(A$nW), min(A$nD), stats::median(A$nD)), "",
         sprintf("R\u00e9pliques dont l'ensemble des colonnes d\u00e9g\u00e9n\u00e9r\u00e9es recalcul\u00e9 diff\u00e8re de l'ensemble fig\u00e9 \u00e0 l'observ\u00e9 (annotation du 10/10/2026 de la sp\u00e9cification, point 4 ; attendu 0) : %s r\u00e9plique(s) sur les %d triangle(s) admis, dont %d triangle(s) \u00e0 compte non nul%s.",
                 if (anyNA(nj)) "illisible" else sprintf("%.0f", sum(nj)), nrow(A), tj,
                 if (anyNA(nj) || tj > 0) " \u2014 **compte non nul : point de d\u00e9cision (actuary)**" else ""), "",
         entete_md(c("Statistique", "queue", "n", "p absentes", "taux 0,10 [IC]", "taux 0,05 [IC]")))
  for (x in list(c("W (Shapiro-Wilk)", "bas", "pW_bas"), c("W (Shapiro-Wilk)", "haut", "pW_haut"),
                 c("D (Lilliefors)", "bas", "pD_bas"), c("D (Lilliefors)", "haut", "pD_haut"))) {
    p <- A[[x[3]]]; n <- length(p); fin <- is.finite(p)
    cel <- vapply(SEUILS, function(a) { k <- sum(fin & p < a); sprintf("%s %s", num(k / n, D_IC), txt_ic(ic_cp(k, n))) }, "")
    L <- c(L, ligne_md(x[1], x[2], n, sum(!fin), cel[1], cel[2]))
  }
  c(L, "")
}

###############################################################################
#  EVALUATION MECANIQUE DE K1 A K5, PROFILS Pi ET R (SANS CONCLURE)
###############################################################################
evaluation <- function(DS, OR, CEL_R, MC, TM) {
  L <- c("### \u00c9valuation m\u00e9canique de K1 \u00e0 K5, profils \u03a0 et R (sans conclusion)", "",
         "Les \u00e9tats ci-dessous sont calcul\u00e9s par le script ; la lecture (et la part \u00ab non expliqu\u00e9 \u00bb de \u03a00) revient \u00e0 actuary, la cons\u00e9quence au mainteneur (B3).", "")
  lois_k1 <- unique(vapply(CEL_R, `[[`, "", "loi"))
  cel_txt <- function(x) sprintf("%s %s %s", x$loi, x$s, lib_ia(x$ia))
  classe <- vapply(CEL_R, function(x) x$c$classe, "")
  cote <- vapply(CEL_R, function(x) if (x$c$disj) x$c$cote else NA_character_, "")
  # K1
  k1 <- vapply(lois_k1, function(l) { k <- vapply(CEL_R, `[[`, "", "loi") == l
    t <- table(factor(classe[k], levels = c(CLASSES, unique(classe[k][!classe[k] %in% CLASSES]))))
    paste(sprintf("%s %d", names(t), as.integer(t)), collapse = ", ") }, "")
  L <- c(L, entete_md(c("Condition", "\u00c9tat m\u00e9canique", "D\u00e9tail")),
         ligne_md("K1 (niveau, pool redress\u00e9)", if (length(lois_k1)) "\u00e9valu\u00e9e" else "non \u00e9valuable",
                  if (length(lois_k1)) paste(sprintf("%s : %s", lois_k1, k1), collapse = " ; ") else "aucune loi"))
  # K2
  sig2 <- if (!is.null(MC)) MC[MC$p_holm < NIVEAU_HOLM, , drop = FALSE] else NULL
  # R2 si |tau_R - rho| < |tau_B - rho| (le redressement rapproche tau de rho),
  # R3 si >, indetermine si egal (ni l'un ni l'autre).
  rcl <- if (!is.null(sig2) && nrow(sig2)) { dR <- abs(sig2$tau_R - sig2$rho); dB <- abs(sig2$tau_B - sig2$rho)
    ifelse(dR < dB, "R2", ifelse(dR > dB, "R3", "ind\u00e9termin\u00e9 (\u00e9carts \u00e9gaux)")) } else character(0)
  L <- c(L, ligne_md("K2 (brut contre redress\u00e9, McNemar, Holm)", if (is.null(MC)) "non \u00e9valuable (pool brut absent)" else
    if (!nrow(sig2)) "aucun McNemar significatif apr\u00e8s Holm" else sprintf("%d McNemar significatif(s) apr\u00e8s Holm", nrow(sig2)),
    if (is.null(sig2) || !nrow(sig2)) "\u2014" else liste_cel(sprintf("%s %s %s (%d/%d, p Holm %s ; \\|\u03c4_R \u2212 \u03c1\\| %s, \\|\u03c4_B \u2212 \u03c1\\| %s : %s)",
                                                                  sig2$loi, sig2$s, vapply(sig2$ia, lib_ia, ""), sig2$n01, sig2$n10, vapply(sig2$p_holm, fmt_p, ""),
                                                                  vapply(abs(sig2$tau_R - sig2$rho), num, "", d = D_IC), vapply(abs(sig2$tau_B - sig2$rho), num, "", d = D_IC), rcl), 52)))
  # K3
  sig3 <- if (!is.null(TM)) TM[is.finite(TM$p_holm) & TM$p_holm < NIVEAU_HOLM, , drop = FALSE] else NULL
  L <- c(L, ligne_md("K3 (t\u00e9moins oracle)", if (is.null(TM)) "non \u00e9valuable (oracle absent)" else
    if (!nrow(sig3)) "aucun t\u00e9moin significatif" else "**t\u00e9moin(s) significatif(s) : lecture suspendue jusqu'\u00e0 explication**",
    if (is.null(sig3) || !nrow(sig3)) "\u2014" else liste_cel(sprintf("%s %s %s (k = %d / %d, taille %s, p Holm %s)", sig3$loi, sig3$s,
                                                                  vapply(sig3$ia, lib_ia, ""), sig3$k, sig3$n, vapply(sig3$taille, num, "", d = 5),
                                                                  vapply(sig3$p_holm, fmt_p, "")), 52)))
  # K4
  k4 <- character(0); k4_def <- FALSE
  for (l in intersect(LOIS, names(DS$tr))) for (pool in c("redresse", "brut")) {
    D <- pop(DS$tr[[l]], pool)
    if (is.null(D) || !nrow(D)) next
    P <- mat_p(D, if (pool == "brut") "pB" else "pR")
    part <- mean(apply(!is.finite(P), 1, any)); k4_def <- k4_def || part > SEUIL_K4
    k4 <- c(k4, sprintf("%s %s %s (%d / %d)", l, if (pool == "brut") "brut" else "redress\u00e9", num(part, 5), sum(apply(!is.finite(P), 1, any)), nrow(D)))
  }
  L <- c(L, ligne_md("K4 (p absentes, au plus 1 % par (loi, pool))", if (!length(k4)) "non \u00e9valuable" else if (k4_def) "**au-del\u00e0 de 1 % : point de d\u00e9cision**" else "remplie",
                     paste(k4, collapse = " ; ")))
  L <- c(L, ligne_md("K5 (B effectif, descriptif)", "descriptif", "voir T5"))
  # Refus au-dela de 1 % (par. 2)
  rf <- vapply(intersect(LOIS, names(DS$tr)), function(l) mean(DS$tr[[l]]$statut == "refuse"), 1)
  L <- c(L, ligne_md("Refus des triangles (au-del\u00e0 de 1 % : signal\u00e9, par. 2)", if (any(rf > SEUIL_REFUS)) "**signal\u00e9**" else "sous 1 %",
                     paste(sprintf("%s %s", names(rf), vapply(rf, num, "", d = 5)), collapse = " ; ")), "")
  # Profils Pi
  ln <- vapply(CEL_R, `[[`, "", "loi")
  ne <- ln %in% c("N", "E")
  ok_ne <- all(c("N", "E") %in% ln)
  pi <- character(0)
  pi0 <- (!is.null(sig3) && nrow(sig3) > 0) || k4_def
  dist <- classe == CLASSES[4]
  cons <- CEL_R[dist & cote == "conservateur"]; lib <- CEL_R[dist & cote %in% "lib\u00e9ral"]
  # Pi5 : pour une meme cle et un meme seuil, des lois de cotes opposes.
  # Lecture STRICTE retenue au profil (annotation du 10/10/2026 de la
  # specification, point 3) : distorsions materielles de cotes opposes
  # entre deux lois. Lecture large (classes non compatibles dont le taux
  # est de part et d'autre de rho) : indication descriptive, hors profil,
  # rapportee sous le tableau des profils.
  sens_cel <- vapply(CEL_R, function(x) if (!x$c$evaluable || x$c$classe == CLASSES[1]) NA_character_ else
    if (x$c$taux > x$ref) "lib\u00e9ral" else "conservateur", "")
  cle_ia <- vapply(CEL_R, function(x) paste(x$s, x$ia), "")
  p5s <- p5l <- character(0)
  for (u in unique(cle_ia)) {
    k <- cle_ia == u
    if (all(c("conservateur", "lib\u00e9ral") %in% cote[k & dist])) p5s <- c(p5s, u)
    if (all(c("conservateur", "lib\u00e9ral") %in% sens_cel[k])) p5l <- c(p5l, u)
  }
  fmt_u <- function(u) vapply(strsplit(u, " ", fixed = TRUE), function(z) sprintf("%s %s", z[1], lib_ia(z[2])), "")
  L <- c(L, entete_md(c("Profil", "Condition m\u00e9canique", "Pr\u00e9sent", "Cellules")),
         ligne_md("\u03a00", "K3 ou K4 en d\u00e9faut (\u00ab non expliqu\u00e9 \u00bb : jugement d'actuary)", if (pi0) "**oui**" else "non",
                  if (pi0) "voir K3 et K4" else "\u2014"),
         ligne_md("\u03a01", "sous N et E, les 13 lignes compatibles ou en \u00e9cart mineur aux deux seuils",
                  if (!ok_ne) "non \u00e9valuable (N et E non toutes deux pr\u00e9sentes)" else if (all(classe[ne] %in% CLASSES[1:2])) "**oui**" else "non",
                  if (ok_ne) liste_cel(vapply(CEL_R[ne & !classe %in% CLASSES[1:2]], cel_txt, ""), 30) else "\u2014"),
         ligne_md("\u03a02", "aucune distorsion mat\u00e9rielle, mais des \u00e9carts non tranch\u00e9s",
                  if (!any(dist) && any(classe == CLASSES[3])) "**oui**" else "non",
                  liste_cel(vapply(CEL_R[classe == CLASSES[3]], cel_txt, ""), 30)),
         ligne_md("\u03a03", "distorsion mat\u00e9rielle conservatrice (IC sous \u03c1/2)", if (length(cons)) "**oui**" else "non",
                  liste_cel(vapply(cons, cel_txt, ""), 30)),
         ligne_md("\u03a04", "distorsion mat\u00e9rielle lib\u00e9rale", if (length(lib)) "**oui**" else "non", liste_cel(vapply(lib, cel_txt, ""), 30)),
         ligne_md("\u03a05", "m\u00eame cl\u00e9 et m\u00eame seuil : distorsions mat\u00e9rielles de c\u00f4t\u00e9s oppos\u00e9s (lib\u00e9ral et conservateur) entre deux lois",
                  if (length(p5s)) "**oui**" else "non", liste_cel(fmt_u(p5s), 30)), "",
         sprintf("Indication descriptive, hors profil (lecture large de \u03a05, annotation du 10/10/2026 de la sp\u00e9cification, point 3) : m\u00eame cl\u00e9 et m\u00eame seuil, classes non compatibles de part et d'autre de \u03c1 entre lois : %s.",
                 if (length(p5l)) liste_cel(fmt_u(p5l), 30) else "aucune"), "")
  # R1 a R3
  L <- c(L, entete_md(c("Effet de #46 (K2)", "Pr\u00e9sent", "Cellules")),
         ligne_md("R1 : aucun McNemar significatif apr\u00e8s Holm", if (is.null(MC)) "non \u00e9valuable" else if (!nrow(sig2)) "**oui**" else "non", "\u2014"),
         ligne_md("R2 : effet significatif qui rapproche \u03c4 de \u03c1 (\\|\u03c4_R \u2212 \u03c1\\| < \\|\u03c4_B \u2212 \u03c1\\|)", if (any(rcl == "R2")) "**oui**" else "non",
                  if (any(rcl == "R2")) liste_cel(sprintf("%s %s %s", sig2$loi[rcl == "R2"], sig2$s[rcl == "R2"], vapply(sig2$ia[rcl == "R2"], lib_ia, "")), 26) else "\u2014"),
         ligne_md("R3 : effet significatif qui \u00e9loigne \u03c4 de \u03c1", if (any(rcl == "R3")) "**oui**" else "non",
                  if (any(rcl == "R3")) liste_cel(sprintf("%s %s %s", sig2$loi[rcl == "R3"], sig2$s[rcl == "R3"], vapply(sig2$ia[rcl == "R3"], lib_ia, "")), 26) else "\u2014"), "")
  # Lignes a la frontiere de reserve2 (par. 5 ; ensemble lu dans la reference
  # versionnee par frontiere_reference(), specification de Fk, par. 5.4)
  FR <- frontiere_reference()
  fr <- CEL_R[vapply(CEL_R, function(x) x$s %in% FR$cles, logical(1))]
  L <- c(L, sprintf("Lignes \u00ab \u00e0 la fronti\u00e8re \u00bb de reserve2 (%s), classe par loi et seuil : %s.", FR$txt,
                    if (length(fr)) liste_cel(vapply(fr, function(x) sprintf("%s %s %s : %s", x$loi, x$s, lib_ia(x$ia), x$c$classe), ""), 30)
                    else "aucune"), "")
  L
}

###############################################################################
#  TABLEAUX DE LA LECTURE CONJOINTE (#297, specification de Fk, par. 5.3)
###############################################################################
lib_fam <- function(f) if (f == FAM_MW[length(FAM_MW)]) sprintf("%s (globale)", f) else f
# K-F1 : cellules par loi, famille (ou ligne globale) et seuil. Population :
# triangles admis (pool redresse) ou la ligne est presente (etat L ou N) ;
# une p absente (etat N, texte T-3b) compte comme un non-rejet, comptee a
# part (cellule()) ; reference rho_F, classes de #166 et #206 (lecture()),
# sur les valeurs non arrondies.
cellules_fk <- function(DS) {
  out <- list()
  for (loi in intersect(LOIS, names(DS$tr))) {
    D <- pop(DS$tr[[loi]], "redresse")
    if (is.null(D) || !nrow(D)) next
    for (f in FAM_MW) {
      pr <- D[[paste0("etf:", f)]] %in% c("L", "N")
      for (ia in IA)
        out[[length(out) + 1L]] <- list(unite = loi, f = f, ia = ia, ref = RHO_F[[ia]], n_adm = nrow(D),
                                        c = cellule(D[[paste0("pf:", f)]][pr], SEUILS[match(ia, IA)], RHO_F[[ia]]))
    }
  }
  out
}
tableau_fk1 <- function(CEL) {
  L <- c("### T-F1 \u2014 niveau sous H0 des p de famille et de la p globale (K-F1)", "",
         paste("Par loi, famille et seuil : n triangles admis o\u00f9 la ligne est pr\u00e9sente (k \u2265 2), dont les p absentes (B effectif de famille",
               "< 50, texte T-3b ; compt\u00e9es comme non-rejet) ; k rejets (p < \u03b1) ; taux k / n et IC de Clopper-Pearson \u00e0 95 % (5 d\u00e9cimales ;",
               "classe sur les valeurs non arrondies) ; r\u00e9f\u00e9rence \u03c1_F, taille du test de Monte-Carlo id\u00e9al \u00e0 B_eff = 999 pour une statistique",
               "sans atome (majorant en pr\u00e9sence d'atomes) ; classe de #166 et #206 (c\u00f4t\u00e9 en gras si l'IC est disjoint de la bande",
               "[\u03c1_F/2 ; 3\u03c1_F/2])."), "",
         entete_md(c("Loi", "Famille", "admis", "n (ligne pr\u00e9sente)", "abs. T-3b", "\u03c1_F 0,10", "k 0,10", "taux [IC] 0,10", "classe 0,10",
                     "\u03c1_F 0,05", "k 0,05", "taux [IC] 0,05", "classe 0,05")))
  cle <- vapply(CEL, function(x) paste(x$unite, x$f), "")
  for (u in unique(cle)) {
    x <- CEL[cle == u]
    cols <- unlist(lapply(x, function(z) c(num(z$ref, 3), z$c$k, txt_lec(z$c), txt_classe(z$c))))
    L <- c(L, ligne_md(x[[1]]$unite, lib_fam(x[[1]]$f), x[[1]]$n_adm, x[[1]]$c$n, x[[1]]$c$absentes, paste(cols, collapse = " | ")))
  }
  c(L, "")
}
# Composition (par. 5.3, Grandeurs) : distribution de k, part des triangles
# ou la ligne existe, absences T-3b, B effectif de famille, masse de la p de
# famille au plancher 1/(B effectif + 1).
tableau_fk2 <- function(DS) {
  L <- c("### T-F2 \u2014 composition des familles : k, pr\u00e9sence de la ligne, B effectif, plancher", "",
         paste("Sur les triangles admis (pool redress\u00e9) : k, nombre de tests membres (r\u00e8gle du par. 1.3 de la sp\u00e9cification de Fk, recompt\u00e9e",
               "par le script) ; ligne pr\u00e9sente si k \u2265 2 (Q-D1-Fk-2 (a)), absente pour k \u2264 1 ; pr\u00e9sente sans p si le B effectif de famille",
               "(r\u00e9plications o\u00f9 les statistiques de tous les membres sont finies) est < 50 (T-3b) ; masse au plancher : part des p de famille",
               "d\u00e9finies \u00e9gales \u00e0 1/(B effectif de famille + 1)."), "",
         entete_md(c("Loi", "Famille", "admis", "distribution de k (k : triangles)", "ligne pr\u00e9sente (part)", "dont sans p (T-3b)",
                     "B effectif de famille : min [m\u00e9diane]", "p d\u00e9finies", "masse au plancher")))
  for (loi in intersect(LOIS, names(DS$tr))) {
    D <- pop(DS$tr[[loi]], "redresse")
    if (is.null(D) || !nrow(D)) next
    for (f in FAM_MW) {
      et <- D[[paste0("etf:", f)]]; k <- D[[paste0("kf:", f)]]; bf <- D[[paste0("bf:", f)]]; p <- D[[paste0("pf:", f)]]
      tk <- table(k); pr <- et %in% c("L", "N"); def <- is.finite(p)
      pl <- if (any(def)) mean(abs(p[def] - 1 / (bf[def] + 1)) < 1e-12) else NA_real_
      L <- c(L, ligne_md(loi, lib_fam(f), nrow(D), paste(sprintf("%s : %d", names(tk), as.integer(tk)), collapse = " ; "),
                         sprintf("%d (%s)", sum(pr), num(mean(pr), D_IC)), sum(et %in% "N"),
                         if (any(pr)) sprintf("%.0f [%.0f]", min(bf[pr]), stats::median(bf[pr])) else "\u2014", sum(def), num(pl, D_IC)))
    }
  }
  c(L, "")
}
# K-F2 (descriptif, T4) : multiplicite sur les lignes de type test (typ_R t
# et r), puis sur les seules lignes de sens "ne pas rejeter" (t ; avis
# d'actuary du 25/10/2026, point 1), p globale < alpha, et par famille, au
# moins un membre de p_mc < alpha contre p de famille < alpha.
au_moins <- function(v, t, codes, types = c("t", "r")) mapply(function(a, b) {
  va <- strsplit(a, "", fixed = TRUE)[[1]]; tb <- strsplit(b, "", fixed = TRUE)[[1]]
  length(va) == length(tb) && any(va[tb %in% types] %in% codes)
}, v, t, USE.NAMES = FALSE)
tableau_fk3 <- function(DS) {
  lc <- FAM_MW[length(FAM_MW)]
  L <- c("### T-F3 \u2014 multiplicit\u00e9 sous H0 et lecture conjointe (K-F2, descriptif)", "",
         paste("Sur les triangles admis (pool redress\u00e9) : part \u00e0 au moins une ALERTE ou un ECHEC, et \u00e0 au moins un ECHEC, parmi les lignes",
               "de type test de mw_tests() (types et verdicts lus \u00e0 chaque triangle), puis parmi les seules lignes de sens \u00ab ne pas",
               "rejeter \u00bb (les deux lignes de sens \u00ab rejeter \u00bb, TOST et Pitman, sont lognormales : colonnes \u00e9gales ici) ;",
               "part \u00e0 p globale < \u03b1 (p absente : non-rejet) ; par",
               "famille, part \u00e0 au moins un test membre de p_mc < \u03b1 (plus petite p_mc des membres) contre part \u00e0 p de famille < \u03b1 (ligne",
               "absente ou sans p : non-rejet). Taux descriptifs, sans r\u00e9f\u00e9rence ni classe."), "",
         entete_md(c("Loi", "n", "\u2265 1 A ou E (tests)", "\u2265 1 A ou E (tests \u00ab ne pas rejeter \u00bb)", "\u2265 1 E (tests)",
                     "\u2265 1 E (tests \u00ab ne pas rejeter \u00bb)", "p globale < 0,10", "p globale < 0,05")))
  lois <- Filter(function(l) !is.null(pop(DS$tr[[l]], "redresse")) && nrow(pop(DS$tr[[l]], "redresse")) > 0, intersect(LOIS, names(DS$tr)))
  for (loi in lois) {
    D <- pop(DS$tr[[loi]], "redresse"); pg <- D[[paste0("pf:", lc)]]
    L <- c(L, ligne_md(loi, nrow(D), num(mean(au_moins(D$verd_R, D$typ_R, c("A", "E"))), D_IC),
                       num(mean(au_moins(D$verd_R, D$typ_R, c("A", "E"), "t")), D_IC), num(mean(au_moins(D$verd_R, D$typ_R, "E")), D_IC),
                       num(mean(au_moins(D$verd_R, D$typ_R, "E", "t")), D_IC),
                       num(mean(is.finite(pg) & pg < 0.10), D_IC), num(mean(is.finite(pg) & pg < 0.05), D_IC)))
  }
  L <- c(L, "", entete_md(c("Loi", "Famille", "n", "\u2265 1 membre p_mc < 0,10", "p de famille < 0,10", "\u2265 1 membre p_mc < 0,05",
                            "p de famille < 0,05")))
  for (loi in lois) for (f in FAM_MW) {
    D <- pop(DS$tr[[loi]], "redresse"); mi <- D[[paste0("minf:", f)]]; p <- D[[paste0("pf:", f)]]
    q <- function(x, a) num(mean(is.finite(x) & x < a), D_IC)
    L <- c(L, ligne_md(loi, lib_fam(f), nrow(D), q(mi, 0.10), q(p, 0.10), q(mi, 0.05), q(p, 0.05)))
  }
  c(L, "")
}
# K-F4 (frontiere, descriptif) : frequence de |p - s| < 2 err_mc, s dans
# {alpha ; alpha/2}, pour chaque p de famille definie ; par cle : T4.
tableau_fk4 <- function(DS) {
  L <- c("### T-F4 \u2014 voisinage des seuils des p de famille (K-F4, descriptif)", "",
         paste("Fr\u00e9quence sous H0 de |p \u2212 s| < 2 err_mc, s \u2208 {0,10 ; 0,05}, sur les p de famille d\u00e9finies (err_mc = \u221a(p (1 \u2212 p)/B_eff),",
               "queue simple) ; la m\u00eame fr\u00e9quence par cl\u00e9 du catalogue est en T4 (remesure de #206)."), "",
         entete_md(c("Loi", "Famille", "p d\u00e9finies", "\\|p \u2212 0,10\\| < 2 err_mc", "\\|p \u2212 0,05\\| < 2 err_mc")))
  for (loi in intersect(LOIS, names(DS$tr))) {
    D <- pop(DS$tr[[loi]], "redresse")
    if (is.null(D) || !nrow(D)) next
    for (f in FAM_MW) {
      p <- D[[paste0("pf:", f)]]; e <- D[[paste0("ef:", f)]]; d <- is.finite(p) & is.finite(e)
      L <- c(L, ligne_md(loi, lib_fam(f), sum(d), num(if (any(d)) mean(abs(p[d] - 0.10) < 2 * e[d]) else NA_real_, D_IC),
                         num(if (any(d)) mean(abs(p[d] - 0.05) < 2 * e[d]) else NA_real_, D_IC)))
    }
  }
  c(L, "")
}
# Etat de K3 et K4 de #206 (Phi0), meme regle que evaluation().
etat_k3_k4 <- function(DS, TM) {
  sig3 <- if (!is.null(TM)) TM[is.finite(TM$p_holm) & TM$p_holm < NIVEAU_HOLM, , drop = FALSE] else NULL
  k4 <- vapply(intersect(LOIS, names(DS$tr)), function(l) {
    D <- pop(DS$tr[[l]], "redresse"); if (is.null(D) || !nrow(D)) 0 else mean(apply(!is.finite(mat_p(D, "pR")), 1, any)) }, 1)
  def3 <- !is.null(sig3) && nrow(sig3) > 0; def4 <- any(k4 > SEUIL_K4)
  list(defaut = def3 || def4, txt = sprintf("K-F3 : rempli (INTEGRITE OK et ligne (K-F3) OK dans chaque sortie de tranche) ; K3 : %s ; K4 : %s",
                                           if (is.null(TM)) "non \u00e9valuable (oracle absent)" else if (def3) "**t\u00e9moin(s) significatif(s)**" else "aucun t\u00e9moin significatif",
                                           if (def4) "**au-del\u00e0 de 1 %**" else "remplie"))
}
evaluation_fk <- function(CEL, ph0) {
  ev <- Filter(function(x) isTRUE(x$c$evaluable), CEL)
  un <- unique(vapply(CEL, `[[`, "", "unite"))
  k1 <- vapply(un, function(u) { cl <- vapply(Filter(function(x) x$unite == u, ev), function(x) x$c$classe, "")
    t <- table(factor(cl, levels = c(CLASSES, setdiff(unique(cl), CLASSES)))); paste(sprintf("%s %d", names(t), as.integer(t)), collapse = ", ") }, "")
  c("### \u00c9valuation m\u00e9canique de K-F1 \u00e0 K-F4 et des profils \u03a6 (sans conclusion)", "",
    "\u00c9tats calcul\u00e9s par le script ; la lecture revient \u00e0 actuary, la d\u00e9cision \u00e9ventuelle au mainteneur (D2-Fk, Q-D1-Fk-9 : d\u00e9cision requise sous \u03a60, \u03a64 ou \u03a65 seulement).", "",
    entete_md(c("Condition", "\u00c9tat m\u00e9canique", "D\u00e9tail")),
    ligne_md("K-F1 (principal)", if (length(ev)) "\u00e9valu\u00e9e" else "non \u00e9valuable", if (length(un)) paste(sprintf("%s : %s", un, k1), collapse = " ; ") else "aucune loi"),
    ligne_md("K-F2 (descriptif, T4)", "descriptif", "voir T-F3 et T4"),
    ligne_md("K-F3 (int\u00e9grit\u00e9)", "remplie", "INTEGRITE OK et contr\u00f4le (K-F3) OK dans chaque sortie de tranche (refus de --combiner sinon)"),
    ligne_md("K-F4 (fronti\u00e8re, descriptif)", "descriptif", "voir T-F4 ; par cl\u00e9 : T4"),
    "", profils_fk(CEL, ph0$defaut, ph0$txt), TXT_PROFIL_GLOBAL, "")
}

###############################################################################
#  LECTURE D'UNE SORTIE (--combiner, --reprendre)
###############################################################################
CLES_CONTEXTE <- c("mode", "loi", "dgp", "configuration", "graines", "collisions", "generateur", "commit", "plateforme",
                   "empreintes", "empreinte_sc", "reference", "lignes", "cle_ligne", "essai", "locale")
CLES_COMMUNES <- c("dgp", "configuration", "graines", "collisions", "generateur", "commit", "plateforme", "empreintes",
                   "empreinte_sc", "reference", "lignes", "cle_ligne", "essai")
LIBELLES_CONTEXTE <- c(
  mode = "Mode", loi = "Loi des erreurs", dgp = "DGP sous H0 (par. 2)", configuration = "Configuration",
  graines = "Graines (par. 7)", collisions = "Graines : recherche des collisions (graines calcul\u00e9es comprises)",
  generateur = "G\u00e9n\u00e9rateur", commit = "Commit", plateforme = "Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)",
  empreintes = "Empreintes md5 du code ex\u00e9cut\u00e9", empreinte_sc = "Empreinte sans commentaires de R/engine.R (#231) et md5 du fichier entier",
  reference = "Contr\u00f4le (a) : reserve2 contre tests/reference/reserve2.rds", lignes = "Lignes de mw_tests() (ordre de reserve2)",
  cle_ligne = "Correspondance cl\u00e9 \u2192 ligne (contr\u00f4le (b))", essai = "Essai (--essai, non versionnable)",
  locale = "Locale LC_CTYPE (origine \u2192 travail)")
md5_lignes <- function(l) {
  f <- tempfile("md5_"); on.exit(unlink(f))
  con <- file(f, open = "wb"); writeLines(utf8(l), con, useBytes = TRUE); close(con)
  unname(tools::md5sum(f))
}
lire_sortie <- function(f) {
  if (!file.exists(f)) refuser(basename(f), " introuvable")
  l <- readLines(f, warn = FALSE, encoding = "UTF-8")
  nf <- basename(f)
  champs <- function(etq) strsplit(sub(paste0("^", etq, "\t"), "", grep(paste0("^", etq, "\t"), l, value = TRUE)), "\t", fixed = TRUE)
  unique1 <- function(etq) {
    x <- champs(etq)
    if (length(x) != 1L) refuser(nf, " : ", length(x), " ligne(s) ", etq, " (une attendue) -- sortie incomplete ?")
    x[[1]]
  }
  integ <- champs("INTEGRITE")
  if (length(integ) != 1L) refuser(nf, " : ligne INTEGRITE absente ou multiple")
  if (!identical(integ[[1]], "OK")) refuser(nf, " : controle d'integrite en ECHEC")
  nv <- l[nzchar(trimws(l))]
  if (!length(nv) || !startsWith(nv[length(nv)], "FIN\t")) refuser(nf, " : la ligne FIN n'est pas la derniere ligne -- sortie tronquee ou modifiee")
  par <- paste(unique1("PARAMETRES"), collapse = "\t")
  mode <- sub("^mode=([a-z]+);.*$", "\\1", par)
  if (!mode %in% names(COLS)) refuser(nf, " : mode illisible dans PARAMETRES")
  loi <- sub("^.*;loi=([NEA]);.*$", "\\1", par)
  tr <- unique1("TRANCHE")
  if (length(tr) != 3L) refuser(nf, " : ligne TRANCHE illisible")
  ctx <- champs("CONTEXTE")
  if (!length(ctx) || any(lengths(ctx) != 2L)) refuser(nf, " : lignes CONTEXTE absentes ou illisibles")
  ctx <- stats::setNames(vapply(ctx, `[`, "", 2L), vapply(ctx, `[`, "", 1L))
  if (!setequal(names(ctx), CLES_CONTEXTE) || anyDuplicated(names(ctx))) refuser(nf, " : lignes CONTEXTE incompletes")
  cl <- unique1("CLES"); co <- unique1("COLS")
  if (!identical(cl, sprintf("%s=%s", CLES, QUEUE))) refuser(nf, " : CLES differentes du catalogue MW_CATALOGUE_MC de ce moteur")
  if (!identical(co, COLS[[mode]])) refuser(nf, " : COLS differentes de celles du script")
  rp <- champs(ETQ[[mode]])
  n_l <- suppressWarnings(as.integer(unique1("NLIG"))); fin <- suppressWarnings(as.integer(unique1("FIN")))
  if (is.na(n_l) || length(rp) != n_l || !identical(fin, n_l))
    refuser(nf, sprintf(" : %d ligne(s) de donnees lue(s), NLIG = %s, FIN = %s -- sortie tronquee ou modifiee", length(rp), n_l, fin))
  if (any(lengths(rp) != length(co))) refuser(nf, " : ligne de donnees de longueur differente de COLS")
  du <- suppressWarnings(as.numeric(unique1("DUREE")))
  if (length(du) != 2L || anyNA(du)) refuser(nf, " : ligne DUREE illisible")
  md5v <- if (mode == "oracle") {
    x <- unique1("MD5_VALEURS")
    lo <- grep(paste0("^", ETQ[[mode]], "\t"), l, value = TRUE)
    if (!identical(x, md5_lignes(lo))) refuser(nf, " : md5 des valeurs de l'oracle different de MD5_VALEURS")
    x
  } else NA_character_
  list(fichier = f, nom = nf, parametres = par, mode = mode, loi = loi, debut = as.integer(tr[1]), fin = as.integer(tr[2]),
       pools = tr[3], contexte = ctx[CLES_CONTEXTE], donnees = rp, duree = du, md5 = md5_fichier(f), md5_valeurs = md5v,
       echantillon = paste(unlist(champs("ECHANTILLON")), collapse = " "),
       reprise = vapply(champs("REPRISE"), paste, "", collapse = " "),
       # lignes du controle K-F3 en succes (#297), lues dans le markdown
       kf3 = sum(grepl("^- \\(K-F3\\) .*: OK$", l)))
}
# Invariants (d) d'une sortie, lus sur les champs (tranche) : B_eff <= 999,
# p sur la grille ; statut connu ; p hors catalogue Monte-Carlo dans [0, 1]
# (#248, constat m2) : p des regressions de #119 (p_agr, p_ceff), p
# asymptotiques et exactes des lignes (pas:, pex:), p de la sous-mesure N.
# Lecture sur les champs BRUTS (avant as.numeric(), qui changerait une
# valeur corrompue, "0,7", "1.5x", "abc", en NA) : seul le marqueur
# d'absence "NA" est admis (f17() l'ecrit pour toute valeur non finie, et
# champs_tranche(), champs_sm() et champs_erreur() pour les lignes refusees
# ou en erreur ; aucun autre marqueur n'est produit dans ces colonnes) ;
# toute autre valeur doit etre un nombre decimal (forme de sprintf("%.17g"))
# compris dans [0, 1]. Sont donc refuses : champ vide, "NaN", "Inf", "-Inf",
# virgule decimale, texte, et toute valeur hors de [0, 1].
COLS_P01 <- list(tranche = c("p_agr", "p_ceff", grep("^(pas|pex):", COLS_TRANCHE, value = TRUE)),
                 sm = c("pW_bas", "pW_haut", "pD_bas", "pD_haut"), oracle = character(0))
RE_NOMBRE <- "^-?[0-9]+(\\.[0-9]+)?([eE][-+]?[0-9]+)?$"
p_hors_01 <- function(donnees, cols_mode, cols) {
  if (!length(donnees) || !length(cols)) return(character(0))
  M <- do.call(rbind, donnees); colnames(M) <- cols_mode
  cols[vapply(cols, function(k) {
    x <- M[, k]; ab <- x == "NA"
    v <- suppressWarnings(as.numeric(x))
    any(!ab & (!grepl(RE_NOMBRE, x) | is.na(v) | v < 0 | v > 1))
  }, logical(1))]
}
# Invariants des colonnes de lecture conjointe (#297), sur les triangles
# admis : etat L, N ou A seulement (X : incoherence ; S : stats_boot absent ;
# refuses) ; A : k <= 1, sans p ; L : k >= 2, B effectif de famille >=
# B_MIN_DEGENERESCENCE, p dans [0, 1] sur la grille k/(B effectif + 1),
# err_mc et m_obs finies ; N : k >= 2, B effectif < B_MIN_DEGENERESCENCE, ni
# p, ni err_mc, ni m_obs ; k de la ligne globale >= k de chaque famille.
# Appliques aux sorties de tranche (controle (d)) et a --combiner de la
# campagne 297 ; la combinaison de #206 ne lit pas ces colonnes.
invariants_familles <- function(D) {
  A <- D[D$statut == "admis", , drop = FALSE]
  if (!nrow(A)) return(character(0))
  err <- character(0)
  col <- function(ch, f) A[[paste0(ch, ":", f)]]
  for (f in FAM_MW) {
    et <- col("etf", f); k <- col("kf", f); bf <- col("bf", f); p <- col("pf", f); e <- col("ef", f); m <- col("sf", f)
    x <- p * (bf + 1)
    ok <- (et %in% "A" & k %in% 0:1 & !is.finite(p)) |
      (et %in% "L" & k >= 2 & bf >= B_MIN_DEGENERESCENCE & is.finite(p) & p >= 0 & p <= 1 & abs(x - round(x)) < 1e-6 &
         is.finite(e) & is.finite(m)) |
      (et %in% "N" & k >= 2 & bf < B_MIN_DEGENERESCENCE & !is.finite(p) & !is.finite(e) & !is.finite(m))
    ok <- ok %in% TRUE
    if (!all(ok)) err <- c(err, sprintf("lecture conjointe %s : \u00e9tat ou champs incoh\u00e9rents (b = %s ; \u00e9tats %s)", f,
                                        paste(utils::head(A$b[!ok], 5), collapse = ", "), paste(unique(et[!ok]), collapse = ", ")))
  }
  lc <- FAM_MW[length(FAM_MW)]
  for (f in setdiff(FAM_MW, lc)) if (any(!(col("kf", lc) >= col("kf", f)) %in% TRUE))
    err <- c(err, sprintf("lecture conjointe : k de %s inf\u00e9rieur \u00e0 celui de %s", lc, f))
  err
}
invariants_sortie <- function(p) {
  err <- character(0)
  D <- en_table(p$donnees, COLS[[p$mode]])
  b <- if (p$mode == "oracle") D$k else D$b
  if (!identical(as.integer(sort(b)), seq.int(p$debut, p$fin))) err <- c(err, "indices des lignes differents de debut..fin")
  if (!all(D$statut %in% c("admis", "refuse"))) err <- c(err, "statut inconnu")
  h01 <- p_hors_01(p$donnees, COLS[[p$mode]], COLS_P01[[p$mode]])
  if (length(h01)) err <- c(err, sprintf("p hors de [0, 1] ou illisible (%s)", paste(h01, collapse = ", ")))
  if (p$mode == "tranche") {
    A <- D[D$statut == "admis", , drop = FALSE]
    for (pf in c("R", "B")) {
      Ak <- if (pf == "B") A[A$brut == "oui", , drop = FALSE] else A
      if (!nrow(Ak)) next
      P <- mat_p(Ak, paste0("p", pf)); Bm <- mat_p(Ak, paste0("B", pf))
      ok <- all(vapply(CLES, function(s) all(mapply(sur_grille, P[, s], Bm[, s], MoreArgs = list(queue = QUEUE[[s]]))), logical(1)))
      if (!ok) err <- c(err, sprintf("invariant (d) faux (pool %s : B_eff > 999 ou p hors grille)", pf))
      M <- mat_p(Ak, paste0("m", pf))
      if (!all(M %in% c(names(CODES_MOTIF), "-"))) err <- c(err, sprintf("motif d'absence inconnu (pool %s)", pf))
    }
    if (any(D$brut == "oui") && !identical(p$pools, "redresse,brut")) err <- c(err, "pool brut hors d'une tranche redresse,brut")
    if (identical(p$pools, "redresse,brut") && any(A$brut != "oui")) err <- c(err, "pool brut absent d'un triangle admis")
    if (isTRUE(p$familles)) err <- c(err, invariants_familles(D))
  }
  if (p$mode == "sm") {
    A <- D[D$statut == "admis", , drop = FALSE]
    if (any(A$nW > B_BOOT | A$nD > B_BOOT)) err <- c(err, "invariant (d) faux (B_eff > 999)")
  }
  err
}

# Ligne du JOURNAL d'une sortie (#248) : exactement une ligne
# "- Sortie <nom> : md5 <md5>" (en debut de ligne, suite libre apres une
# virgule ou un blanc, format de synchroniser_sauvegarde.sh), de md5 egal a
# celui du fichier. NULL si conforme, sinon le motif du refus. Meme regle
# que tests/outillage/controler_md5.sh.
ecart_journal_sortie <- function(jl, nom, md5) {
  m <- regmatches(jl, regexec("^- Sortie (\\S+) : md5 ([0-9a-f]{32})([,[:space:]]|$)", jl))
  m <- Filter(function(x) length(x) && identical(x[2], nom), m)
  if (length(m) != 1L)
    return(sprintf("%d ligne(s) \"- Sortie %s : md5 <md5>\" au JOURNAL (une attendue)", length(m), nom))
  if (!identical(m[[1]][3], md5))
    return(sprintf("md5 de %s au JOURNAL (%s) different de celui du fichier (%s)", nom, m[[1]][3], md5))
  NULL
}

# Ecriture par lot (#248, --combiner --sortie et --brut) : ecrire(cible,
# lignes) et copier(source, cible, md5) produisent le fichier dans un
# dossier temporaire voisin de la cible (tempfile() du dossier de la cible :
# le renommage reste sur le meme systeme de fichiers) ; seuls les fichiers
# copies (copier()) ont leur md5 controle contre une valeur attendue, les
# fichiers ecrits (ecrire()) ne le sont pas. valider() verifie que toutes
# les cibles sont encore absentes, puis les renomme une a une
# (file.rename()) et retire les temporaires ; annuler() retire les cibles
# deja renommees par ce lot et les temporaires. Toute anomalie leve une
# erreur (stop()), jamais un quit() : l'appelant annule avant de refuser.
# Limite : entre la verification d'absence et chaque file.rename() reste
# une courte fenetre de course ; une cible creee pendant cette fenetre par
# un autre processus serait ecrasee sous POSIX (file.rename() remplace la
# destination) puis retiree par annuler() en cas d'erreur ulterieure.
ecriture_par_lot <- function() {
  tmp <- character(0); faits <- character(0); cibles <- character(0)
  temporaire <- function(cible) {
    d <- dirname(cible)
    if (is.na(tmp[d])) {
      t <- tempfile(".lot248-", tmpdir = d)
      if (!dir.create(t)) stop("dossier temporaire non cree a cote de ", basename(cible))
      tmp[d] <<- t
    }
    file.path(tmp[[d]], basename(cible))
  }
  ajouter <- function(cible) {
    if (cible %in% cibles) stop("cible en double : ", basename(cible))
    if (file.exists(cible)) stop("cible deja presente, jamais ecrasee : ", basename(cible))
    cibles <<- c(cibles, cible)
    temporaire(cible)
  }
  list(
    ecrire = function(cible, lignes) {
      f <- ajouter(cible)
      con <- file(f, open = "wb"); on.exit(close(con))
      writeLines(utf8(lignes), con, useBytes = TRUE)
    },
    copier = function(src, cible, md5_attendu) {
      f <- ajouter(cible)
      if (!isTRUE(file.copy(src, f)) || !identical(md5_fichier(f), md5_attendu)) stop("copie refusee ou md5 different : ", basename(cible))
    },
    cibles = function() cibles,
    temporaire = function(cible) file.path(tmp[[dirname(cible)]], basename(cible)),
    valider = function() {
      deja <- cibles[file.exists(cibles)]
      if (length(deja)) stop("cible(s) apparue(s) pendant la combinaison, jamais ecrasee(s) : ", paste(basename(deja), collapse = ", "))
      for (cible in cibles) {
        if (!file.rename(file.path(tmp[[dirname(cible)]], basename(cible)), cible)) stop("renommage refuse : ", basename(cible))
        faits <<- c(faits, cible)
      }
      unlink(unname(tmp), recursive = TRUE)
      invisible(TRUE)
    },
    annuler = function() {
      unlink(faits)
      unlink(unname(tmp), recursive = TRUE)
      invisible(TRUE)
    })
}

###############################################################################
#  MODE --combiner
###############################################################################
MOTIF_FICHIERS <- "^(tranche-[NEA]-[0-9]{4}-[0-9]{4}|oracle-[NEA]|sm-[0-9]{4}-[0-9]{4})\\.txt$"
if (MODE == "combiner") {
  T_COMB0 <- Sys.time()
  fichiers <- unlist(lapply(FICHIERS_COMB, function(f) if (dir.exists(f))
    sort(list.files(f, pattern = MOTIF_FICHIERS, full.names = TRUE)) else f))
  if (!length(fichiers)) refuser("aucun fichier de sortie")
  if (anyDuplicated(basename(fichiers))) refuser("noms de fichiers en double")
  parts <- lapply(fichiers, lire_sortie)
  errs <- unlist(lapply(parts, function(p) {
    k <- vapply(p$donnees, function(x) identical(x[2], "erreur"), logical(1))
    if (any(k)) sprintf("%s ligne %s : %s", p$nom, vapply(p$donnees[k], `[`, "", 1L), vapply(p$donnees[k], `[`, "", 3L)) else character(0)
  }))
  if (length(errs)) refuser(length(errs), " ligne(s) au statut erreur (sorties a relancer apres correction) : ", paste(errs, collapse = " ; "))
  for (k in CLES_COMMUNES) if (length(unique(vapply(parts, function(p) p$contexte[[k]], ""))) != 1L)
    refuser("contexte (", k, ") different entre les sorties")
  modes_p <- vapply(parts, `[[`, "", "mode"); lois_p <- vapply(parts, `[[`, "", "loi")
  for (g in unique(paste(modes_p, lois_p))) {
    pg <- parts[paste(modes_p, lois_p) == g]
    if (length(unique(vapply(pg, `[[`, "", "parametres"))) != 1L) refuser("PARAMETRES differents entre les sorties de ", g)
  }
  for (p in parts) {
    p$familles <- CAMPAGNE == "297"
    e <- invariants_sortie(p); if (length(e)) refuser(p$nom, " : ", paste(e, collapse = " ; "))
  }
  # Campagne 297 : chaque sortie de tranche porte le controle K-F3 en succes
  # (une ligne) ; texte du critere de Fk present dans la specification.
  if (CAMPAGNE == "297") {
    for (p in parts) if (p$mode == "tranche" && p$kf3 != 1L)
      refuser(p$nom, " : ", p$kf3, " ligne(s) \"- (K-F3) ... : OK\" (une attendue) -- sortie anterieure a #297 ou controle K-F3 en echec")
    if (!present_bloc(TEXTE_CRITERE_FK, TXT_SPEC_FK)) refuser("(t297) texte du critere de Fk absent ou modifie dans ", SPEC_FK)
  }
  # Ensemble "a la frontiere" lu dans la reference (par. 5.4 de la
  # specification de Fk) : tout desaccord avec l'inegalite recalculee refuse.
  FR_C <- frontiere_reference()
  if (!FR_C$ok) refuser("(fr) ", FR_C$txt)
  # JOURNAL : md5 de chaque sortie, debit, niveau, empreinte (#231).
  TXT_JOURNAL <- "non fourni"; TXT_DEBIT <- "non fourni (--journal absent)"; TXT_EMP_J <- "non fourni (--journal absent)"; NIV_J <- NA_character_
  if (!is.na(OPT_JOURNAL)) {
    if (!file.exists(OPT_JOURNAL)) refuser("--journal introuvable")
    jl <- readLines(OPT_JOURNAL, warn = FALSE, encoding = "UTF-8")
    for (p in parts) {
      e <- ecart_journal_sortie(jl, p$nom, p$md5)
      if (!is.null(e)) refuser("--journal : ", e)
    }
    ld <- Filter(length, regmatches(jl, regexec("^\\s*- D(\u00e9|e)bit : (.*\\S)\\s*$", jl)))
    if (length(ld) != 1L) refuser("--journal : ", length(ld), " ligne(s) \"- Debit : <texte>\" (une attendue)")
    le <- Filter(length, regmatches(jl, regexec("^\\s*- Empreinte sans commentaires : ([0-9a-f]{32})\\s*$", jl)))
    if (length(le) != 1L) refuser("--journal : ", length(le), " ligne(s) \"- Empreinte sans commentaires : <md5>\" (une attendue)")
    emp <- sub(" .*$", "", parts[[1]]$contexte[["empreinte_sc"]])
    if (!identical(le[[1]][2], emp)) refuser("--journal : (i3) empreinte du JOURNAL ", le[[1]][2], " differente de celle des sorties ", emp)
    # Campagne 297 (audit m4) : commit du pre-vol porte au JOURNAL ("- Commit :
    # <sha>", une ligne) egal a celui des sorties (contexte identique entre
    # sorties, verifie plus haut) ; refus sinon.
    if (CAMPAGNE == "297") {
      lc_ <- Filter(length, regmatches(jl, regexec("^\\s*- Commit : ([0-9a-f]{40})\\s*$", jl)))
      if (length(lc_) != 1L) refuser("--journal : ", length(lc_), " ligne(s) \"- Commit : <sha>\" (une attendue, ecrite par le pre-vol)")
      com <- sub(" .*$", "", parts[[1]]$contexte[["commit"]])
      if (!identical(lc_[[1]][2], com)) refuser("--journal : commit du JOURNAL ", lc_[[1]][2], " different de celui des sorties ", com)
    }
    ln <- Filter(length, regmatches(jl, regexec("^\\s*- Niveau : (L[0-5])\\s*$", jl)))
    if (length(ln) > 1L) refuser("--journal : plusieurs lignes \"- Niveau : Lk\"")
    NIV_J <- if (length(ln)) ln[[1]][2] else NA_character_
    if (!is.na(OPT_NIVEAU) && !identical(NIV_J, OPT_NIVEAU)) refuser("--journal : ligne \"- Niveau : ", OPT_NIVEAU, "\" absente ou differente (", NIV_J, ")")
    TXT_DEBIT <- gsub("|", "\\|", ld[[1]][3], fixed = TRUE)
    TXT_EMP_J <- sprintf("%s, \u00e9gale \u00e0 celle des sorties (contr\u00f4le (i3))", le[[1]][2])
    TXT_JOURNAL <- sprintf("%s (md5 %s) : md5 des %d sorties conformes ; lignes du d\u00e9bit et de l'empreinte (#231) lues ; niveau : %s",
                           basename(OPT_JOURNAL), md5_fichier(OPT_JOURNAL), length(parts), if (is.na(NIV_J)) "ligne absente" else NIV_J)
  }
  # Donnees par groupe et couverture.
  DS <- list(tr = list(), ora = list(), sm = NULL, essai = parts[[1]]$contexte[["essai"]])
  ctx1 <- parts[[1]]$contexte
  DS$lignes <- strsplit(ctx1[["lignes"]], " ; ", fixed = TRUE)[[1]]
  cl <- strsplit(strsplit(ctx1[["cle_ligne"]], " ; ", fixed = TRUE)[[1]], "=", fixed = TRUE)
  DS$cle_ligne <- stats::setNames(as.integer(vapply(cl, `[`, "", 2L)), vapply(cl, `[`, "", 1L))
  for (l in LOIS) {
    pt <- parts[modes_p == "tranche" & lois_p == l]
    if (length(pt)) {
      D <- en_table(do.call(c, lapply(pt, `[[`, "donnees")), COLS_TRANCHE)
      if (anyDuplicated(D$b)) refuser("loi ", l, " : triangles en double entre tranches")
      DS$tr[[l]] <- D[order(D$b), , drop = FALSE]
    }
    po <- parts[modes_p == "oracle" & lois_p == l]
    if (length(po) > 1L) refuser("loi ", l, " : plusieurs oracles")
    if (length(po)) { O <- en_table(po[[1]]$donnees, COLS_ORACLE); DS$ora[[l]] <- O[order(O$k), , drop = FALSE] }
  }
  ps <- parts[modes_p == "sm"]
  if (length(ps)) {
    S <- en_table(do.call(c, lapply(ps, `[[`, "donnees")), COLS_SM)
    if (anyDuplicated(S$b)) refuser("sous-mesure N : triangles en double")
    DS$sm <- S[order(S$b), , drop = FALSE]
  }
  couvre <- function(b, R) !anyDuplicated(b) && setequal(b, seq_len(R))
  # Campagne 297 (par. 5.2 de la specification de Fk) : pool redresse seul,
  # lois N et E, oracles N et E ; ni pool brut, ni loi A, ni sous-mesure N.
  if (CAMPAGNE == "297") {
    if (any(vapply(parts, function(p) identical(p$pools, "redresse,brut"), logical(1))))
      refuser("campagne 297 : pool brut hors plan (par. 5.2 de la specification de Fk)")
    if ("A" %in% c(names(DS$tr), names(DS$ora))) refuser("campagne 297 : loi A hors plan (par. 5.2)")
    if (!is.null(DS$sm)) refuser("campagne 297 : sous-mesure N hors plan (par. 5.2)")
  }
  if (!is.na(OPT_NIVEAU)) {
    RN <- if (CAMPAGNE == "297") {
      x <- NIVEAUX_297[[OPT_NIVEAU]]
      c(N_red = x[["N"]], E_red = x[["E"]], N_brut = 0, E_brut = 0, A_red = 0)
    } else NIVEAUX[[OPT_NIVEAU]]
    lois_niv <- c("N", "E", if (RN[["A_red"]] > 0) "A")
    if (!setequal(names(DS$tr), lois_niv)) refuser("lois des tranches (", paste(names(DS$tr), collapse = ", "), ") differentes de celles du niveau ", OPT_NIVEAU)
    for (l in lois_niv) {
      Rr <- RN[[paste0(l, "_red")]]; Rb <- if (l %in% c("N", "E")) RN[[paste0(l, "_brut")]] else 0
      if (!couvre(DS$tr[[l]]$b, Rr)) refuser("loi ", l, " : les tranches ne couvrent pas 1..", Rr, " exactement une fois")
      # Pool brut : plages des tranches appariees (--pools redresse,brut).
      bb <- unlist(lapply(parts[modes_p == "tranche" & lois_p == l & vapply(parts, `[[`, "", "pools") == "redresse,brut"],
                          function(p) seq.int(p$debut, p$fin)))
      if (!couvre(if (is.null(bb)) integer(0) else bb, Rb))
        refuser("loi ", l, " : les tranches appariees ne couvrent pas 1..", Rb, " exactement une fois")
      if (is.null(DS$ora[[l]])) refuser("loi ", l, " : oracle absent")
      if (nrow(DS$ora[[l]]) != N0_SPEC) refuser("loi ", l, " : oracle de ", nrow(DS$ora[[l]]), " triangles (", N0_SPEC, " attendus)")
    }
    if (length(setdiff(names(DS$ora), lois_niv))) refuser("oracle d'une loi hors du niveau ", OPT_NIVEAU)
    if (CAMPAGNE != "297" && (is.null(DS$sm) || !couvre(DS$sm$b, R_SM_SPEC))) refuser("sous-mesure N : 1..", R_SM_SPEC, " non couverte exactement une fois")
    DS$R <- RN
  } else {
    RN <- c(N_red = 0, E_red = 0, N_brut = 0, E_brut = 0, A_red = 0)
    for (l in names(DS$tr)) {
      b <- DS$tr[[l]]$b
      if (!couvre(b, max(b))) refuser("loi ", l, " (--reduit) : couverture de 1..", max(b), " incomplete ou multiple")
      RN[[paste0(l, "_red")]] <- max(b)
      bb <- unlist(lapply(parts[modes_p == "tranche" & lois_p == l & vapply(parts, `[[`, "", "pools") == "redresse,brut"], function(p) seq.int(p$debut, p$fin)))
      if (length(bb)) { if (!couvre(bb, max(bb))) refuser("loi ", l, " (--reduit) : couverture du pool brut incomplete"); RN[[paste0(l, "_brut")]] <- max(bb) }
    }
    if (!is.null(DS$sm) && !couvre(DS$sm$b, max(DS$sm$b))) refuser("sous-mesure N (--reduit) : couverture incomplete")
    DS$R <- RN
  }
  # (i3) et motifs de non-versionnement.
  COMMIT_COMB <- commit_depot(SCRIPT)
  EMPREINTES_COMB <- empreintes_code(SCRIPT, SPECS_LUES)
  EMP_COMB <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
  nv <- c(motifs_non_versionnable(ctx1[["commit"]], ctx1[["empreintes"]]),
          motifs_non_versionnable(COMMIT_COMB, EMPREINTES_COMB, "de la combinaison"),
          if (!startsWith(ctx1[["empreinte_sc"]], EMP_COMB)) sprintf("empreinte (#231) de la combinaison %s diff\u00e9rente de celle des sorties", EMP_COMB),
          if (!identical(ctx1[["essai"]], "non")) "sorties d'essai (--essai)",
          if (OPT_REDUIT) "param\u00e8tres r\u00e9duits (--reduit)")
  if (OPT_ECRIRE && length(nv)) refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "))
  # Calculs.
  OR <- lapply(DS$ora, resume_oracle)
  CEL_R <- cellules_pool(DS, OR, "redresse"); CEL_B <- cellules_pool(DS, OR, "brut")
  MC <- mcnemar_pools(DS, OR); TM <- temoins(DS, OR)
  # Valeurs brutes : lignes de donnees des tranches et de la sous-mesure
  # (l'echantillon oracle n'est pas versionne, par. 4 ; md5 de ses valeurs en T0).
  # Campagne 297 : sans colonnes de la sous-mesure N (hors plan).
  N_SM_BRUT <- if (CAMPAGNE == "297") 0L else length(COLS_SM) - 1L
  COLS_BRUT <- c("type", "loi", COLS_TRANCHE, if (N_SM_BRUT) paste0("sm:", COLS_SM[-1]))
  brut_tr <- unlist(lapply(names(DS$tr), function(l) { pt <- parts[modes_p == "tranche" & lois_p == l]
    x <- do.call(c, lapply(pt, `[[`, "donnees")); x <- x[order(as.integer(vapply(x, `[`, "", 1L)))]
    vapply(x, function(r) paste(c("rep", l, r, rep("NA", N_SM_BRUT)), collapse = "\t"), "") }))
  brut_sm <- if (length(ps)) { x <- do.call(c, lapply(ps, `[[`, "donnees")); x <- x[order(as.integer(vapply(x, `[`, "", 1L)))]
    vapply(x, function(r) { v <- rep("NA", length(COLS_TRANCHE)); v[1] <- r[1]; paste(c("sm", "N", v, r[-1]), collapse = "\t") }, "") } else character(0)
  BRUT <- c(paste(COLS_BRUT, collapse = "\t"), brut_tr, brut_sm)
  F_BRUT_TMP <- tempfile("mw206_brut_", fileext = ".tsv")
  con <- file(F_BRUT_TMP, open = "wb"); writeLines(utf8(BRUT), con, useBytes = TRUE); close(con)
  MD5_BRUT <- md5_fichier(F_BRUT_TMP)
  # T0
  plan_txt <- if (!is.na(OPT_NIVEAU) && CAMPAGNE == "297")
    sprintf("%s (%s ; plan de la sp\u00e9cification de Fk, par. 5.2) : N = %d, E = %d (pool redress\u00e9 seul) ; N0 = %d par loi ; ni pool brut, ni loi A, ni sous-mesure N",
            OPT_NIVEAU, LIB_NIVEAUX_297[[OPT_NIVEAU]], DS$R[["N_red"]], DS$R[["E_red"]], N0_SPEC) else
    if (!is.na(OPT_NIVEAU)) sprintf("%s (%s) : %s ; N0 = %d par loi ; sous-mesure N sur 1..%d", OPT_NIVEAU, LIB_NIVEAUX[[OPT_NIVEAU]],
                                               paste(sprintf("%s = %d", names(DS$R), DS$R), collapse = ", "), N0_SPEC, R_SM_SPEC) else
    sprintf("--reduit (param\u00e8tres r\u00e9duits, non versionnable) : %s ; oracles %s ; sous-mesure N %s", paste(sprintf("%s = %d", names(DS$R), DS$R), collapse = ", "),
            if (length(DS$ora)) paste(sprintf("%s N0 = %d", names(DS$ora), vapply(DS$ora, nrow, 1L)), collapse = ", ") else "absents",
            if (is.null(DS$sm)) "absente" else sprintf("1..%d", nrow(DS$sm)))
  t0 <- c(entete_md(c("Grandeur", "Valeur")),
          vapply(CLES_COMMUNES, function(k) ligne_md(LIBELLES_CONTEXTE[[k]], ctx1[[k]]), ""),
          ligne_md("Locale LC_CTYPE des sorties (origine \u2192 travail)", paste(unique(vapply(parts, function(p) p$contexte[["locale"]], "")), collapse = " ; ")),
          ligne_md(if (CAMPAGNE == "297") "Niveau de l'\u00e9chelle (sp\u00e9cification de Fk, par. 5.2) et R" else "Niveau de l'\u00e9chelle (par. 8) et R", plan_txt),
          ligne_md("D\u00e9bit (ligne du JOURNAL)", TXT_DEBIT),
          ligne_md("Triangles refus\u00e9s par loi (par. 2 : signal\u00e9 au-del\u00e0 de 1 %)",
                   paste(c(vapply(names(DS$tr), function(l) { r <- mean(DS$tr[[l]]$statut == "refuse")
                     sprintf("%s %d / %d (%s)%s", l, sum(DS$tr[[l]]$statut == "refuse"), nrow(DS$tr[[l]]), num(r, 5), if (r > SEUIL_REFUS) " **SIGNAL\u00c9**" else "") }, ""),
                     vapply(names(DS$ora), function(l) { r <- mean(DS$ora[[l]]$statut == "refuse")
                     sprintf("oracle %s %d / %d (%s)%s", l, sum(DS$ora[[l]]$statut == "refuse"), nrow(DS$ora[[l]]), num(r, 5), if (r > SEUIL_REFUS) " **SIGNAL\u00c9**" else "") }, "")),
                         collapse = " ; ")),
          ligne_md("\u03c1 approch\u00e9 (plus de 1 % de statistiques oracle non finies pour la cl\u00e9 ; annotation du 10/10/2026, point 2 (a))",
                   if (!length(DS$ora)) "\u2014 (oracle absent)" else liste_cel(cles_rho_approche(OR), 39)),
          ligne_md("Sorties combin\u00e9es (nom, md5, plage, \u00e9chantillon des contr\u00f4les)",
                   paste(vapply(parts, function(p) sprintf("%s %s (%s %s, %d-%d%s%s)", p$nom, p$md5, p$mode, p$loi, p$debut, p$fin,
                                                           if (nzchar(p$echantillon)) sprintf(", \u00e9chantillon %s", p$echantillon) else "",
                                                           if (length(p$reprise)) sprintf(", reprise : %s", p$reprise) else ""), ""), collapse = " ; ")),
          ligne_md("\u00c9chantillons oracle (non versionn\u00e9s, r\u00e9g\u00e9n\u00e9rables par leurs graines) : md5 des valeurs",
                   if (length(DS$ora)) paste(vapply(parts[modes_p == "oracle"], function(p) sprintf("%s : %s (fichier %s)", p$loi, p$md5_valeurs, p$md5), ""), collapse = " ; ") else "aucun"),
          ligne_md("JOURNAL", TXT_JOURNAL),
          ligne_md("Empreinte sans commentaires (#231) du JOURNAL", TXT_EMP_J),
          ligne_md("Commit de la combinaison", COMMIT_COMB), ligne_md("Empreintes md5 du combinateur", EMPREINTES_COMB),
          ligne_md("Empreinte sans commentaires de R/engine.R \u00e0 la combinaison (#231)", EMP_COMB),
          ligne_md("Valeurs brutes", sprintf("%s : md5 %s, %d lignes (copie hors du d\u00e9p\u00f4t : --brut)", NOMS_SORTIE[["brut"]], MD5_BRUT, length(BRUT) - 1L)),
          ligne_md("Journal de la combinaison", NOMS_SORTIE[["jcomb"]]),
          ligne_md("Versionnable (--ecrire)", if (length(nv)) paste("non :", paste(nv, collapse = " ; ")) else "oui"),
          ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", sprintf("OK dans les %d sorties ; invariants (d) relus sur les champs ; couvertures exactes ; (i3) : empreinte \u00e9gale dans les sorties%s",
                                                          length(parts), if (startsWith(ctx1[["empreinte_sc"]], EMP_COMB)) " et \u00e0 la combinaison" else ", DIFF\u00c9RENTE \u00e0 la combinaison")))
  titre <- if (CAMPAGNE == "297")
    "## Mesure #297 (Fk) : niveau r\u00e9el \u00e0 T = 8 des p de famille et de la p globale de Merz-W\u00fcthrich, et remesure de #206" else
    "## Mesure #206 : niveau r\u00e9el \u00e0 T = 8 des p-values Monte-Carlo de Merz-W\u00fcthrich (+ #119)"
  aide <- c("### Aide \u00e0 la lecture", "",
            paste("Statut : **constat de simulation sous un plan** (mod\u00e8le de Mack ajust\u00e9 \u00e0 reserve2), pas un r\u00e9sultat g\u00e9n\u00e9ral ; il ne se",
                  "transpose ni \u00e0 une autre g\u00e9om\u00e9trie de triangle ni \u00e0 un autre param\u00e9trage. Aucun th\u00e9or\u00e8me ne couvre ce test bootstrap",
                  "\u00e0 T = 8 ; Dwass (1957) et Hope (1968) ne fondent que le t\u00e9moin oracle. IC : Clopper-Pearson \u00e0 95 %, incertitude",
                  "Monte-Carlo sur le taux (fonction de R), distincte de l'erreur de \u03c1 (fonction de N0) et de err_mc (fonction de B = 999,",
                  "donn\u00e9e du test calibr\u00e9). Bande de Bradley : convention de lecture (#166), pas th\u00e9or\u00e8me."), "",
            "**Crit\u00e8re de la sp\u00e9cification (par. 5), report\u00e9 sans modification, \u00e9valu\u00e9 m\u00e9caniquement sans conclure :**", "",
            paste(">", TEXTE_CRITERE_206), "")
  if (CAMPAGNE == "297") aide <- c(aide[1:(which(aide == "")[2])],
    paste("Lecture conjointe (#297) : p de famille et p globale minP en une \u00e9tape (engine_p_famille()), diagnostics sans verdict ;",
          "leur niveau sous H0 est un **constat de simulation sous ce plan**, la p de famille \u00e9tant une p plug-in, non exacte, comme",
          "chaque p Monte-Carlo (sp\u00e9cification de Fk, par. 1.1). R\u00e9f\u00e9rence \u03c1_F = 0,099 et 0,049 (par. 5.3), majorant en pr\u00e9sence",
          "d'atomes de la plus petite p ; la remesure par cl\u00e9 (\u03c1, K1 \u00e0 K5) suit la sp\u00e9cification de #206, inchang\u00e9e."), "",
    "**Crit\u00e8re de la sp\u00e9cification de Fk (par. 5.3), report\u00e9 sans modification, \u00e9valu\u00e9 m\u00e9caniquement sans conclure :**", "",
    paste(">", TEXTE_CRITERE_FK), "",
    "**Crit\u00e8re de la sp\u00e9cification de #206 (par. 5), pour la remesure par cl\u00e9, report\u00e9 sans modification :**", "",
    paste(">", TEXTE_CRITERE_206), "",
    paste("Annotation du 24/10/2026 de la sp\u00e9cification de #206, point 4 : la liste \u00ab \u00e0 la fronti\u00e8re \u00bb du crit\u00e8re ci-dessus",
          "(BP, Origine, HomogF) est retir\u00e9e ; l'ensemble est d\u00e9sormais lu dans la r\u00e9f\u00e9rence versionn\u00e9e (r\u00e8gle de #244),",
          "liste calcul\u00e9e dans l'\u00e9valuation de K1 \u00e0 K5 plus bas."), "")
  if (CAMPAGNE == "297") {
    CEL_FK <- cellules_fk(DS)
    sortie <- c(sprintf("%s -- combinaison de %d sortie(s)", titre, length(parts)), "",
                "### T0 \u2014 provenance (identique dans toutes les sorties, v\u00e9rifi\u00e9)", "", t0, "", aide,
                evaluation_fk(CEL_FK, etat_k3_k4(DS, TM)),
                tableau_fk1(CEL_FK), tableau_fk2(DS), tableau_fk3(DS), tableau_fk4(DS),
                "## Remesure par cl\u00e9 de #206 (K1 \u00e0 K5, sp\u00e9cification de #206, par. 5, inchang\u00e9s)", "",
                tableau_rho(OR, DS),
                evaluation(DS, OR, CEL_R, MC, TM),
                tableau_t1(CEL_R, "### T1 \u2014 niveau du pool redress\u00e9 (crit\u00e8re principal K1)"),
                tableau_t3(TM), tableau_t4(DS), tableau_t5(DS))
    sortie119 <- character(0)
  } else {
  sortie <- c(sprintf("%s -- combinaison de %d sortie(s)", titre, length(parts)), "",
              "### T0 \u2014 provenance (identique dans toutes les sorties, v\u00e9rifi\u00e9)", "", t0, "", aide,
              tableau_rho(OR, DS),
              evaluation(DS, OR, CEL_R, MC, TM),
              tableau_t1(CEL_R, "### T1 \u2014 niveau du pool redress\u00e9 (crit\u00e8re principal K1)"),
              tableau_t1(CEL_B, "### T1 bis \u2014 niveau du pool brut d'avant #46 (b \u2264 R_brut)"),
              tableau_t2(MC), tableau_t3(TM), tableau_t4(DS), tableau_t5(DS))
  sortie119 <- c("## Mesure #119 (avec #206) : p nominales et normalit\u00e9 dans le bootstrap, triangles 8 \u00d7 8 sous H0", "",
                 sprintf("Provenance : celle du tableau %s (m\u00eame combinaison ; commit %s ; empreinte (#231) %s ; valeurs brutes %s, md5 %s).",
                         NOMS_SORTIE[["md"]], ctx1[["commit"]], sub(" .*$", "", ctx1[["empreinte_sc"]]), NOMS_SORTIE[["brut"]], MD5_BRUT), "",
                 "### T0 \u2014 provenance", "", entete_md(c("Grandeur", "Valeur")),
                 ligne_md(LIBELLES_CONTEXTE[["dgp"]], ctx1[["dgp"]]), ligne_md("Niveau et R", plan_txt),
                 ligne_md("Versionnable (--ecrire)", if (length(nv)) paste("non :", paste(nv, collapse = " ; ")) else "oui"), "",
                 paste("Valeurs 10 \u00d7 10 de la documentation (600 et 160 triangles) **retir\u00e9es et remplac\u00e9es** par ces mesures \u00e0 8 \u00d7 8,",
                       "le protocole d'origine \u00e9tant introuvable (par. 9) ; la valeur de puissance \u00ab 100 % \u00bb n'est pas reproduite (Q-206-B1-6)."), "",
                 tableau_t6(DS), tableau_t7(DS))
  }
  ecrire_console(sortie)
  if (length(sortie119)) ecrire_console(sortie119)
  # D-a de #242 : aucun chemin absolu ni /tmp dans un fichier a ecrire.
  abs_l <- chemins_absolus(c(sortie, sortie119))
  if (length(abs_l)) {
    message("--combiner : chemin absolu ou /tmp dans la sortie (D-a de #242) : ", length(abs_l), " ligne(s)")
    if (OPT_ECRIRE || !is.na(OPT_SORTIE)) refuser("ecriture refusee : chemin absolu ou /tmp dans un tableau")
  }
  ecrire <- function(f, lignes) { con <- file(f, open = "wb"); writeLines(utf8(lignes), con, useBytes = TRUE); close(con) }
  copier <- function(src, f, md5_attendu, ecraser = FALSE) {
    if (!file.copy(src, f, overwrite = ecraser) || !identical(md5_fichier(f), md5_attendu)) refuser("copie refusee ou md5 different : ", basename(f))
    message("ecrit (md5 ", md5_attendu, ") : ", basename(f))
  }
  journal_comb <- function(sorties) c(if (CAMPAGNE == "297") "# Journal de la combinaison de la mesure #297 (Fk), volet Merz-W\u00fcthrich" else
                                         "# Journal de la combinaison de la mesure #206 (+ #119)", "",
    sprintf("- D\u00e9but (UTC) : %s ; fin (UTC) : %s", format(T_COMB0, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")),
    sprintf("- Commande : Rscript %s %s", SCRIPT, paste(vapply(ARGS, function(a) if (file.exists(a) || dir.exists(a)) basename(a) else a, ""), collapse = " ")),
    sprintf("- Commit de la combinaison : %s", COMMIT_COMB), sprintf("- Plateforme : %s", plateforme_calcul()),
    sprintf("- Locale LC_CTYPE : %s \u2192 %s", LOCALE_ORIGINE, LOCALE_TRAVAIL),
    sprintf("- Empreinte sans commentaires : %s", EMP_COMB),
    sprintf("- JOURNAL de la mesure : %s", TXT_JOURNAL),
    "- Sorties lues (toutes INTEGRITE OK, FIN en derni\u00e8re ligne, couvertures exactes, aucun refus) :",
    paste0("  - ", vapply(parts, function(p) sprintf("%s md5 %s", p$nom, p$md5), "")),
    "- Fichiers \u00e9crits :", paste0("  - ", sorties), "")
  if (OPT_ECRIRE) {
    nv1 <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, SPECS_LUES), "de la combinaison")
    if (length(nv1)) refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv1, collapse = " ; "))
    rem <- garde_ecrasement(CIBLES, OPT_REMPLACER, RACINE)
    copier(F_BRUT_TMP, OPT_BRUT, MD5_BRUT)
    copier(F_BRUT_TMP, CIBLES[["brut"]], MD5_BRUT, ecraser = TRUE)
    ecrire(CIBLES[["md"]], inserer_t0(sortie, c(ligne_remplacement(rem, CIBLES[["md"]]), ligne_remplacement(rem, CIBLES[["brut"]]))))
    if ("md119" %in% names(CIBLES)) ecrire(CIBLES[["md119"]], inserer_t0(sortie119, ligne_remplacement(rem, CIBLES[["md119"]])))
    copier(OPT_JOURNAL, CIBLES[["journal"]], md5_fichier(OPT_JOURNAL), ecraser = TRUE)
    ecr <- vapply(intersect(c("md", "brut", "md119", "journal"), names(CIBLES)), function(k) sprintf("%s md5 %s", NOMS_SORTIE[[k]], md5_fichier(CIBLES[[k]])), "")
    ecrire(CIBLES[["jcomb"]], journal_comb(ecr))
    message("ecrit : ", paste(NOMS_SORTIE, collapse = ", "))
  } else if (!is.na(OPT_SORTIE) || !is.na(OPT_BRUT)) {
    # Ecriture par lot (#248) : chaque fichier est produit dans un dossier
    # temporaire voisin de sa cible (meme systeme de fichiers), md5 controle,
    # puis tous sont renommes vers leurs cibles, encore absentes ; toute
    # erreur retire les temporaires et les cibles deja renommees (jamais un
    # fichier preexistant) avant le refus : aucun etat mixte.
    lot <- ecriture_par_lot()
    tryCatch({
      if (!is.na(OPT_BRUT)) lot$copier(F_BRUT_TMP, OPT_BRUT, MD5_BRUT)
      if (!is.na(OPT_SORTIE)) {
        cib <- file.path(OPT_SORTIE, NOMS_SORTIE); names(cib) <- names(NOMS_SORTIE)
        lot$copier(F_BRUT_TMP, cib[["brut"]], MD5_BRUT)
        lot$ecrire(cib[["md"]], sortie); if ("md119" %in% names(cib)) lot$ecrire(cib[["md119"]], sortie119)
        if (!is.na(OPT_JOURNAL)) lot$copier(OPT_JOURNAL, cib[["journal"]], md5_fichier(OPT_JOURNAL))
        k_ecr <- intersect(c("md", "brut", "md119", "journal"), names(cib)[cib %in% lot$cibles()])
        ecr <- vapply(k_ecr, function(k) sprintf("%s md5 %s", NOMS_SORTIE[[k]], md5_fichier(lot$temporaire(cib[[k]]))), "")
        lot$ecrire(cib[["jcomb"]], journal_comb(ecr))
      }
      lot$valider()
    }, error = function(e) { lot$annuler(); refuser("ecriture par lot annulee, rien d'ecrit : ", conditionMessage(e)) })
    for (f in lot$cibles()) message("ecrit (md5 ", md5_fichier(f), ") : ", basename(f))
  }
  unlink(F_BRUT_TMP)
  quit(status = 0L)
}

###############################################################################
#  PLAN DES TRANCHES (--plan, --prevol ; par. 8 et 11)
###############################################################################
# Ordre de priorite (par. 11) : oracles, tranches appariees N et E
# alternees (125 triangles, 250 bootstraps), redresse seul N et E (250
# triangles), A, sous-mesure N. Une ligne : nom de la sortie, TAB, arguments.
plan_tranches <- function(niv) {
  R <- NIVEAUX[[niv]]
  blocs <- function(a, b, t) if (b < a) list() else lapply(seq(a, b, by = t), function(x) c(x, min(x + t - 1, b)))
  tr <- function(l, x, pools) sprintf("tranche-%s-%04d-%04d.txt\t--loi %s --b %d:%d --pools %s", l, x[1], x[2], l, x[1], x[2], pools)
  lois <- c("N", "E", if (R[["A_red"]] > 0) "A")
  out <- sprintf("oracle-%s.txt\t--oracle --loi %s", lois, lois)
  for (x in blocs(1, R[["N_brut"]], TAILLE_PAIRE)) out <- c(out, tr("N", x, "redresse,brut"), tr("E", x, "redresse,brut"))
  for (x in blocs(R[["N_brut"]] + 1, R[["N_red"]], TAILLE_SEULE)) out <- c(out, tr("N", x, "redresse"), tr("E", x, "redresse"))
  if (R[["A_red"]] > 0) for (x in blocs(1, R[["A_red"]], TAILLE_SEULE)) out <- c(out, tr("A", x, "redresse"))
  for (x in blocs(1, R_SM_SPEC, TAILLE_SEULE)) out <- c(out, sprintf("sm-%04d-%04d.txt\t--sous-mesure-N --b %d:%d", x[1], x[2], x[1], x[2]))
  out
}
# Plan de la campagne 297 (specification de Fk, par. 5.2) : oracles N et E,
# tranches Merz-Wuthrich N et E alternees (pool redresse, TAILLE_SEULE
# triangles), puis tranches lognormales J1 et J2 alternees
# (tests/calibration_mc_t8.R --jeu J --R R --tranche i/K, TAILLE_LN
# replications chacune ; troisieme champ : script, lu par
# tests/outillage/lancer_tranches.sh). Les R du niveau doivent etre
# multiples de TAILLE_SEULE et de TAILLE_LN (controle ci-dessous).
plan_tranches_297 <- function(niv) {
  R <- NIVEAUX_297[[niv]]
  blocs <- function(a, b, t) if (b < a) list() else lapply(seq(a, b, by = t), function(x) c(x, min(x + t - 1, b)))
  tr <- function(l, x) sprintf("tranche-%s-%04d-%04d.txt\t--loi %s --b %d:%d --pools redresse", l, x[1], x[2], l, x[1], x[2])
  ln <- function(j, i) { K <- R[[j]] %/% TAILLE_LN
    sprintf("ln-%s-R%d-%04d-%04d.txt\t--jeu %s --R %d --tranche %d/%d\t%s", j, R[[j]], (i - 1L) * TAILLE_LN + 1L, i * TAILLE_LN, j, R[[j]], i, K,
            SCRIPT_LN) }
  out <- sprintf("oracle-%s.txt\t--oracle --loi %s", c("N", "E"), c("N", "E"))
  bn <- blocs(1, R[["N"]], TAILLE_SEULE); be <- blocs(1, R[["E"]], TAILLE_SEULE)
  for (i in seq_len(max(length(bn), length(be))))
    out <- c(out, if (i <= length(bn)) tr("N", bn[[i]]), if (i <= length(be)) tr("E", be[[i]]))
  k1 <- R[["J1"]] %/% TAILLE_LN; k2 <- R[["J2"]] %/% TAILLE_LN
  for (i in seq_len(max(k1, k2))) out <- c(out, if (i <= k1) ln("J1", i), if (i <= k2) ln("J2", i))
  out
}
stopifnot(all(vapply(NIVEAUX_297, function(R) all(R[c("N", "E")] %% TAILLE_SEULE == 0) && all(R[c("J1", "J2")] %% TAILLE_LN == 0), logical(1))))
stopifnot(identical(vapply(NIVEAUX, function(R) sum(R), 1), BOOTSTRAPS_SPEC))
if (MODE == "plan") {
  writeLines(if (CAMPAGNE == "297") plan_tranches_297(OPT_PLAN) else plan_tranches(OPT_PLAN))
  quit(status = 0L)
}

###############################################################################
#  CALCUL D'UN TRIANGLE (tranche, sous-mesure N, oracle)
###############################################################################
# Tranche : triangle b de la loi, admission, pool redresse (et brut), #119.
# ctl : echantillon des controles (i1), (i2).
traiter_triangle <- function(loi, b, avec_brut, ctl = FALSE) {
  t0 <- Sys.time()
  tri <- engine_sous_graine(graine_tri(loi, b), gen_triangle_h0(AJ0, tireur(loi)))
  ad <- admettre(tri)
  if (!ad$ok) return(list(statut = "refuse", motif = ad$motif, duree = secondes(t0)))
  aj <- ad$aj; jd <- .mw_colonnes_degenerees(aj); g <- graine_boot(loi, b)
  t1 <- Sys.time()
  bR <- mw_bootstrap(aj, B = B_BOOT, seed = g); tR <- mw_tests(aj, bR, ALPHA)
  out <- list(statut = "admis", motif = NA_character_, tri = tri, aj = aj, jd = jd, bR = bR, tR = tR, dR = secondes(t1),
              i4 = character(0))
  if (avec_brut) {
    t2 <- Sys.time()
    bB <- avec_pool_brut(mw_bootstrap(aj, B = B_BOOT, seed = g))
    if (!pool_restaure()) out$i4 <- c(out$i4, "restauration")
    tB <- mw_tests(aj, bB, ALPHA)
    out$bB <- bB; out$tB <- tB; out$dB <- secondes(t2)
    if (length(POOL_ORIG(aj, jd)) != length(POOL_BRUT(aj, jd))) out$i4 <- c(out$i4, "longueurs des pools")
  }
  out$r119 <- regressions_119(aj)
  # Lecture conjointe (#297) : etats des lignes de famille du pool redresse ;
  # controle K-F3 sur l'echantillon des controles (premier triangle admis).
  out$fam <- fk_etats(tR, bR, FAM_MW)
  if (ctl) out$kf3 <- fk_recalcul(tR, bR, MW_CATALOGUE_MC, FAM_MW)
  if (ctl) {
    # Volet stats_obs : ensembles figes a l'observe et passes comme dans
    # mw_bootstrap() (jd, #56, #60 ; jni, colonnes non identifiables de la
    # courbure, #270 ; jno, colonnes non identifiables de l'ordonnee a
    # l'origine, #273). Volet oracle : stats_oracle(), jni et jno par le
    # defaut de .mw_ensembles_figes() (memes fonctions : pas un recalcul
    # independant, voir stats_oracle()). Ensembles passes en un objet (#278).
    so <- as.list(.mw_stats(aj, .mw_ensembles_figes(aj, jd, .mw_colonnes_courbure_non_identifiables(aj, jd),
                                                    .mw_colonnes_origine_non_identifiables(aj, jd))))
    out$i1 <- c(stats_obs = identical(bR$stats_obs, so), oracle = identical(as.list(stats_oracle(aj)), bR$stats_obs))
    re <- run_engine(methode = METHODE, triangle = tri, segment = SEGMENT, annexe = ANNEXE, seed = g)
    i2 <- c(tests_R = identical(re$tests, tR), bootstrap_R = identical(re$bootstrap, bR))
    if (avec_brut) {
      rb <- avec_pool_brut(run_engine(methode = METHODE, triangle = tri, segment = SEGMENT, annexe = ANNEXE, seed = g))
      if (!pool_restaure()) out$i4 <- c(out$i4, "restauration (run_engine)")
      i2 <- c(i2, tests_B = identical(rb$tests, tB), bootstrap_B = identical(rb$bootstrap, bB))
    }
    out$i2 <- i2
  }
  out$duree <- secondes(t0)
  out
}
# Type d'une ligne (typ_R) : t test de sens "ne pas rejeter", r test de sens
# "rejeter" (K-F2 restreint, avis d'actuary du 25/10/2026, point 1), d
# diagnostic, n non applicable, - ligne absente.
code_type <- function(t, sens = NA_character_) if (is.null(t) || is.na(t)) "-" else
  switch(t, test = if (identical(sens, "rejeter")) "r" else "t", diagnostic = "d", "non applicable" = "n", "x")
codes_tests <- function(tests) {
  nm <- vapply(tests, libelle_ligne, ""); k <- match(LIGNES, nm)
  list(v = paste(vapply(k, function(i) if (is.na(i)) "-" else code_verdict(tests[[i]]$verdict), ""), collapse = ""),
       n = paste(vapply(k, function(i) if (is.na(i)) "-" else code_nature(tests[[i]]$nature_p), ""), collapse = ""),
       t = paste(vapply(k, function(i) if (is.na(i)) "-" else code_type(tests[[i]]$type, fk_champ(tests[[i]], "sens")), ""), collapse = ""),
       pas = vapply(k, function(i) if (is.na(i)) NA_real_ else tests[[i]]$p_asymptotique, 1),
       pex = vapply(k, function(i) if (is.na(i)) NA_real_ else tests[[i]]$p_exacte, 1))
}
champs_tranche <- function(b, r) {
  vide <- function(n, x = "NA") rep(x, n)
  if (r$statut != "admis") {
    v <- c(b, r$statut, nettoyer_champ(if (is.na(r$motif)) "-" else r$motif), "-", "non", "NA", "NA", sprintf("%.3f", r$duree),
           vide(4), "-", "-", "-", "-", vide(NS), rep(c(vide(3), "-", vide(3), "-"), NS), vide(2 * NL_MAX),
           "-", rep(c("-", vide(6)), length(FAM_MW)))
    return(unname(v))
  }
  cR <- codes_tests(r$tR); br <- !is.null(r$bB)
  cB <- if (br) codes_tests(r$tB) else list(v = "-", n = "-")
  pool <- function(bt, s) if (is.null(bt)) c(vide(3), "-") else
    c(f17(bt$p_mc[[s]]), f17(bt$err_mc[[s]]), sprintf("%.0f", bt$B_effectif[[s]]), code_motif(bt$motif_mc[[s]]))
  v <- c(b, "admis", "-", if (length(r$jd)) paste(r$jd, collapse = ",") else "-", if (br) "oui" else "non",
         sprintf("%.3f", r$dR), if (br) sprintf("%.3f", r$dB) else "NA", sprintf("%.3f", r$duree), f17(r$r119),
         cR$v, cB$v, cR$n, cB$n,
         vapply(CLES, function(s) f17(r$bR$stats_obs[[s]]), ""),
         unlist(lapply(CLES, function(s) c(pool(r$bR, s), pool(r$bB, s)))),
         f17(c(cR$pas, rep(NA_real_, NL_MAX - length(cR$pas)))), f17(c(cR$pex, rep(NA_real_, NL_MAX - length(cR$pex)))),
         cR$t,
         unlist(lapply(FAM_MW, function(f) { x <- r$fam$f[[f]]
           c(x$etat, sprintf("%d", x$k), f17(x$bf), f17(x$p), f17(x$e), f17(x$m), f17(x$minp)) })))
  unname(v)
}
# Triangles bootstrap de mw_bootstrap(), dans son flux (#271) : B
# replications tirees en sequence par .mw_tirer_triangle_valide() du moteur,
# avec retirage des triangles a cumul non strictement positif (#257) et le
# meme plafond FACTEUR_B_MAX_MW (B + 1) triangles au total ; NULL pour une
# replication au plafond (NA dans mw_bootstrap()). A appeler sous la graine
# du bootstrap (engine_sous_graine()).
tirer_triangles_boot <- function(aj, pool, B) {
  n_max <- FACTEUR_B_MAX_MW * (as.numeric(B) + 1); n_tires <- 0
  lapply(seq_len(B), function(i) {
    tir <- .mw_tirer_triangle_valide(aj, pool, n_max - n_tires)
    n_tires <<- n_tires + tir$n
    tir$tri
  })
}
# Sous-mesure N (par. 9) : triangle b de la loi N, regeneration des 999
# triangles bootstrap de mw_bootstrap() par tirer_triangles_boot() (seul
# sample() consomme de l'alea ; les triangles sont tous tires d'abord, sous
# la graine du bootstrap, retirage de #257 compris),
# reajustement, W et D sur les residus de Mack (colonnes degenerees figees a
# l'observe). n_jd_diff : nombre de repliques reajustees dont l'ensemble des
# colonnes degenerees recalcule differe de l'ensemble fige (annotation du
# 10/10/2026 de la specification, point 4 ; attendu 0, un compte non nul
# est un point de decision). ctl : controle (s).
traiter_sm <- function(b, ctl = FALSE) {
  t0 <- Sys.time()
  tri <- engine_sous_graine(graine_tri("N", b), gen_triangle_h0(AJ0, tireur("N")))
  ad <- admettre(tri)
  if (!ad$ok) return(list(statut = "refuse", motif = ad$motif, duree = secondes(t0)))
  aj <- ad$aj; jd <- .mw_colonnes_degenerees(aj); g <- graine_boot("N", b)
  pool <- .mw_pool_residus(aj, jd)
  tris <- engine_sous_graine(g, tirer_triangles_boot(aj, pool, B_BOOT))
  ajs <- lapply(tris, function(tb) {
    # filet : tirer_triangles_boot() ne rend que des triangles valides ou NULL
    if (is.null(tb) || .mw_triangle_incomplet(tb)) return(NULL)
    ab <- try(mw_ajuster(tb), silent = TRUE)
    if (inherits(ab, "try-error")) NULL else ab
  })
  wd <- function(a) {
    r <- try(mw_residus(a, jd)$residu, silent = TRUE)
    if (inherits(r, "try-error")) return(c(NA_real_, NA_real_))
    c(.shapiro_sur(r)$stat, stat_lilliefors(r))
  }
  sim <- t(vapply(ajs, function(a) if (is.null(a)) c(NA_real_, NA_real_) else wd(a), numeric(2)))
  obs <- wd(aj)
  pw <- c(engine_p_mc(sim[, 1], obs[1], "bas")$p_mc, engine_p_mc(sim[, 1], obs[1], "haut")$p_mc)
  pd <- c(engine_p_mc(sim[, 2], obs[2], "bas")$p_mc, engine_p_mc(sim[, 2], obs[2], "haut")$p_mc)
  n_jd_diff <- sum(vapply(ajs, function(a) !is.null(a) && !identical(.mw_colonnes_degenerees(a), jd), logical(1)))
  out <- list(statut = "admis", motif = NA_character_, jd = jd, nW = sum(is.finite(sim[, 1])), nD = sum(is.finite(sim[, 2])),
              n_jd_diff = n_jd_diff, obs = obs, pw = pw, pd = pd)
  if (ctl) {
    # (s) : statistiques du catalogue sur les triangles regeneres (memes
    # rejets que mw_bootstrap()) -> p_mc identiques a celles du moteur.
    # Le retirage de #257 n'y est pas exerce sous le pool reel (aucun
    # triangle retire, 999 tirages pour 999 replications, triangles 1 et 2
    # de la loi N, mesure du 14/10/2026, #271) ;
    # l'identite de gen_triangle_h0() avec mw_simuler_triangle() a cumul
    # invalide, et des fonctions .mw_tirer_triangle_valide() et
    # mw_bootstrap() avec celles du moteur relu, est verifiee par (g).
    # Colonnes non identifiables de la courbure et de l'ordonnee a l'origine
    # figees a l'observe comme dans mw_bootstrap() (#270, #280, #273) ; jni
    # et jno vides sur les triangles des lois continues : alignement verifie
    # par lecture, couvert dans le moteur par les tests de #270 et #273, pas
    # par (s).
    jni <- .mw_colonnes_courbure_non_identifiables(aj, jd)
    jno <- .mw_colonnes_origine_non_identifiables(aj, jd)
    figes <- .mw_ensembles_figes(aj, jd, jni, jno)   # objet unique (#278)
    S <- t(vapply(ajs, function(a) {
      if (is.null(a)) return(rep(NA_real_, NS))
      sb <- try(.mw_stats(a, figes, replique = TRUE), silent = TRUE)
      if (inherits(sb, "try-error")) rep(NA_real_, NS) else unname(sb[CLES])
    }, numeric(NS)))
    colnames(S) <- CLES
    e_obs <- .mw_contexte_mc(aj, figes)
    mc <- .mc_p_values(S, .mc_evaluer(MW_CATALOGUE_MC, e_obs), MW_CATALOGUE_MC, e_obs)
    bt <- mw_bootstrap(aj, B = B_BOOT, seed = g)
    out$s <- c(p_mc = identical(mc$p_mc, bt$p_mc), B_effectif = identical(mc$B_effectif, bt$B_effectif))
  }
  out$duree <- secondes(t0)
  out
}
champs_sm <- function(b, r) {
  if (r$statut != "admis") return(unname(c(b, r$statut, nettoyer_champ(if (is.na(r$motif)) "-" else r$motif), "-", rep("NA", 9), sprintf("%.3f", r$duree))))
  unname(c(b, "admis", "-", if (length(r$jd)) paste(r$jd, collapse = ",") else "-", r$nW, r$nD, r$n_jd_diff, f17(r$obs), f17(r$pw), f17(r$pd),
           sprintf("%.3f", r$duree)))
}
traiter_oracle <- function(loi, k) {
  tri <- engine_sous_graine(graine_ora(loi, k), gen_triangle_h0(AJ0, tireur(loi)))
  ad <- admettre(tri)
  if (!ad$ok) return(unname(c(k, "refuse", ad$motif, "-", rep("NA", NS))))
  jd <- .mw_colonnes_degenerees(ad$aj)
  s <- stats_oracle(ad$aj)
  unname(c(k, "admis", "-", if (length(jd)) paste(jd, collapse = ",") else "-", f17(unname(s[CLES]))))
}
# Champ d'erreur (statut "erreur") : la sortie continue, --combiner refuse.
champs_erreur <- function(mode, b, msg, duree) {
  n <- length(COLS[[mode]])
  v <- rep("NA", n); v[1] <- b; v[2] <- "erreur"; v[3] <- nettoyer_champ(if (nzchar(msg)) msg else "(message vide)")
  if ("duree" %in% COLS[[mode]]) v[match("duree", COLS[[mode]])] <- sprintf("%.3f", duree)
  v
}

###############################################################################
#  MODE INTERNE --prevol-unite : une unite de debit (mw_bootstrap() + mw_tests())
###############################################################################
if (MODE == "unite") {
  for (b in seq.int(B1, B2)) {
    tri <- engine_sous_graine(graine_tri(OPT_LOI, b), gen_triangle_h0(AJ0, tireur(OPT_LOI)))
    ad <- admettre(tri)
    if (!ad$ok) { writeLines(sprintf("REFUS\t%d", b)); next }
    t1 <- Sys.time(); bt <- mw_bootstrap(ad$aj, B = B_BOOT, seed = graine_boot(OPT_LOI, b)); d_b <- secondes(t1)
    invisible(mw_tests(ad$aj, bt, ALPHA))                 # cache de la loi nulle de Shapiro-Wilk
    t2 <- Sys.time(); invisible(mw_tests(ad$aj, bt, ALPHA)); invisible(regressions_119(ad$aj)); d_t <- secondes(t2)
    writeLines(sprintf("UNITE\t%d\t%.3f\t%.3f\t%.3f", b, d_b + d_t, d_b, d_t))
  }
  writeLines("FIN")
  quit(status = 0L)
}

###############################################################################
#  CONTROLES GENERAUX (par. 6) : (t), (b), (a), (g), (i4), (graines), (i3)
###############################################################################
COMMIT <- commit_depot(SCRIPT)
EMPREINTES <- empreintes_code(SCRIPT, SPECS_LUES)
EMPREINTE_SC <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
MD5_MOTEUR <- md5_fichier(file.path(RACINE, "R", "engine.R"))
INTEGRITE <- character(0); CONTROLES <- character(0)
controle <- function(ok, libelle) {
  ok <- isTRUE(ok)
  if (!ok) INTEGRITE <<- c(INTEGRITE, libelle)
  CONTROLES <<- c(CONTROLES, sprintf("%s : %s", libelle, if (ok) "OK" else "\u00c9CHEC"))
  invisible(ok)
}
# (graines) : plages du script disjointes entre elles ; litteraux de graine du
# depot (nombres de huit chiffres commencant par 2, suffixe L compris, dans
# R/engine.R, tests/*.R hors ce script et tests/unitaires/*.R ; l'ecriture
# scientifique n'est pas recherchee) : pour chaque litteral L, l'intervalle
# [L ; L + 20 000] (graines calculees par decalage : b <= 2 000, reseaux de
# #229) disjoint des plages ; SEED_LOI_NULLE_SW, graine de reserve2 et
# reseau 20260831 + 1000 k <= 20760831 de tests/puissance_t8.R hors des
# plages. Les litteraux AU-DESSUS des plages sont listes au T0 (annotation
# du 10/10/2026 de la specification, point 1, qui remplace le critere
# "plus grand litteral + marge" du par. 7 par ce controle).
# Bornes declarees (R21, #350) : une affectation de la forme EXACTE
#   PLAGE_<nom> <- c(L1, L2)   [commentaire eventuel]
# (ex. PLAGE_206 <- c(20840001, 20960000) de tests/mesure_calendaire_t8.R, l. 304)
# declare les deux bornes d'une plage, non des graines tirees : seuls les deux
# litteraux du c(L1, L2) sont ecartes de la recherche (litteraux_graines()).
# Tout autre litteral de la meme ligne (";" suivi d'une instruction, commentaire,
# comparaison "==", affectation d'un seul litteral, c() a plus de deux termes)
# reste compte ; une ligne qui n'a pas cette forme exacte n'est pas ecartee.
# Liste blanche explicite des reemplois DECLARES (R21, #350) : tests/puissance_mw_t8.R
# (#309, volet A) reprend a dessein les trois graines de base de #206, pour
# mesurer sur les memes triangles et les memes bootstraps (appariement ; sa
# ligne GRAINE_TRI <- ... et son commentaire "Graines du volet A : celles de
# #206" le declarent). Ces trois litteraux sont ecartes DANS CE FICHIER seul :
# dans tout autre fichier ils restent des collisions.
REEMPLOIS_DECLARES <- list(puissance_mw_t8.R = c(GRAINE_TRI, GRAINE_BOOT, GRAINE_ORA))
litteraux_graines <- function(l, ecartes = numeric(0)) {
  est_plage <- grepl("^[[:space:]]*PLAGE_[A-Za-z0-9_]+[[:space:]]*<-[[:space:]]*c\\([[:space:]]*[0-9]+L?[[:space:]]*,[[:space:]]*[0-9]+L?[[:space:]]*\\)[[:space:]]*(#.*)?$", l)
  l[est_plage] <- sub("c\\([^)]*\\)", "", l[est_plage])
  v <- as.numeric(unlist(regmatches(l, gregexpr("(?<![0-9A-Za-z.])2[0-9]{7}(?=L?(?![0-9A-Za-z.]))", l, perl = TRUE))))
  v[!v %in% ecartes]
}
PLAGES <- rbind(triangles = c(graine_tri("N", 1), graine_tri("A", B_MAX_SPEC)),
                bootstrap = c(graine_boot("N", 1), graine_boot("A", B_MAX_SPEC)),
                oracle = c(graine_ora("N", 1), graine_ora("A", N0_SPEC)))
DECALAGE_MAX <- 20000
controle_graines <- function(racine = RACINE) {
  fs <- c(file.path(racine, "R", "engine.R"), list.files(file.path(racine, "tests"), pattern = "\\.R$", full.names = TRUE),
          list.files(file.path(racine, "tests", "unitaires"), pattern = "\\.R$", full.names = TRUE))
  fs <- fs[basename(fs) != basename(SCRIPT)]
  lit <- sort(unique(unlist(lapply(fs, function(f)
    litteraux_graines(readLines(f, warn = FALSE), REEMPLOIS_DECLARES[[basename(f)]])))))
  touche <- function(a, b) any(a <= PLAGES[, 2] & b >= PLAGES[, 1])
  coll <- lit[vapply(lit, function(v) touche(v, v + DECALAGE_MAX), logical(1))]
  dessus <- lit[lit > max(PLAGES[, 2])]
  disj <- PLAGES["triangles", 2] < PLAGES["bootstrap", 1] && PLAGES["bootstrap", 2] < PLAGES["oracle", 1]
  ext <- c(SEED_LOI_NULLE_SW, GRAINE_R2, 20260831 + 1000 * 500)
  hors_ext <- !any(vapply(ext, function(v) touche(v, v), logical(1)))
  list(ok = disj && !length(coll) && hors_ext,
       txt = sprintf("plages triangles %.0f-%.0f, bootstrap %.0f-%.0f, oracle %.0f-%.0f (disjointes : %s) ; %d litt\u00e9raux de graine dans %d fichiers (R/engine.R, tests/*.R, tests/unitaires/*.R), de %.0f \u00e0 %.0f ; litt\u00e9raux L dont [L ; L + %.0f] touche une plage : %s ; litt\u00e9raux au-dessus des plages (sans collision ; annotation du 10/10/2026 de la sp\u00e9cification, point 1) : %s ; litt\u00e9raux \u00e9cart\u00e9s de la recherche : lignes affectant PLAGE_* (bornes de plage, R21 #350) et r\u00e9emploi d\u00e9clar\u00e9 des trois graines de base de #206 par tests/puissance_mw_t8.R ; litt\u00e9raux en \u00e9criture scientifique non recherch\u00e9s ; SEED_LOI_NULLE_SW %.0f, graine de reserve2 %.0f et r\u00e9seau 20260831 + 1000 k \u2264 20760831 de tests/puissance_t8.R hors des plages : %s",
                     PLAGES[1, 1], PLAGES[1, 2], PLAGES[2, 1], PLAGES[2, 2], PLAGES[3, 1], PLAGES[3, 2], if (disj) "oui" else "NON",
                     length(lit), length(fs), min(lit), max(lit), DECALAGE_MAX, if (length(coll)) paste(sprintf("%.0f", coll), collapse = ", ") else "aucun",
                     if (length(dessus)) paste(sprintf("%.0f", dessus), collapse = ", ") else "aucun", SEED_LOI_NULLE_SW, GRAINE_R2, if (hors_ext) "oui" else "NON"))
}
# (g) : generateur identique a mw_simuler_triangle() (100 graines) ; fonctions
# du moteur identiques a celles du fichier relu hors injection. Volet sous
# pool dilate (#271) : sur les memes 100 graines, epsilon tires dans
# FACTEUR_G_DILATE * POOL0, qui rend des triangles a cumul simule non fini
# ou <= 0 (mesure du 14/10/2026 : 0 / 100 sur POOL0, 48 / 100 a 30) ; exige
# l'identite ET au moins un tel triangle, faute de quoi l'arret au premier
# cumul invalide (#257) ne serait pas exerce.
FACTEUR_G_DILATE <- 30
controle_g <- function() {
  meme_g <- function(pool) vapply(seq_len(100), function(i) {
    g <- graine_tri("N", i)
    a <- engine_sous_graine(g, gen_triangle_h0(AJ0, function(n) sample(pool, n, replace = TRUE)))
    b <- engine_sous_graine(g, mw_simuler_triangle(AJ0, pool))
    c(identique = identical(a, b), incomplet = .mw_triangle_incomplet(b))
  }, logical(2))
  ok <- meme_g(POOL0)["identique", ]
  dil <- meme_g(FACTEUR_G_DILATE * POOL0)
  e0 <- new.env()
  sys.source(file.path(RACINE, "R", "engine.R"), envir = e0, keep.source = FALSE)
  meme <- function(nm) { a <- get(nm, envir = ENV_MOTEUR); b <- get(nm, envir = e0)
    identical(formals(a), formals(b)) && identical(body(a), body(b)) }
  fns <- c("mw_simuler_triangle", ".mw_simuler_triangle_etat", ".mw_tirer_triangle_valide", ".mw_triangle_incomplet",
           ".mw_pool_residus", "mw_bootstrap")
  ok_fns <- all(vapply(fns, meme, logical(1)))
  list(ok = all(ok) && all(dil["identique", ]) && any(dil["incomplet", ]) && ok_fns,
       txt = sprintf("gen_triangle_h0() (\u03b5 tir\u00e9s par sample(pool)) = mw_simuler_triangle() sous la m\u00eame graine, identical(), sur %d / 100 graines (graines des triangles N, b = 1..100) ; sous pool dilat\u00e9 %g fois (#271) : %d / 100, dont %d triangle(s) \u00e0 cumul simul\u00e9 non fini ou \u2264 0 (au moins un exig\u00e9) ; %s de l'environnement identiques (formals, body) \u00e0 celles de R/engine.R relu : %s",
                     sum(ok), FACTEUR_G_DILATE, sum(dil["identique", ]), sum(dil["incomplet", ]), paste(fns, collapse = ", "), if (ok_fns) "oui" else "NON"))
}
# (i4) : corps injecte conforme a l'expression de b827726^ (git show),
# evaluee sur reserve2 ; injection active pendant l'appel ; restauration.
controle_i4 <- function() {
  src <- tryCatch(suppressWarnings(system2("git", c("-C", shQuote(RACINE), "show", "b827726^:R/engine.R"), stdout = TRUE, stderr = FALSE)),
                  error = function(e) character(0))
  ex <- tryCatch(parse(text = src, keep.source = FALSE), error = function(e) NULL)
  fn <- if (is.null(ex)) NULL else Filter(function(e) is.call(e) && identical(e[[1]], as.name("<-")) && identical(e[[2]], as.name("mw_bootstrap")), as.list(ex))
  attendu <- c("res <- mw_residus(aj, jd)", "pool <- res$residu", "pool <- pool - mean(pool)")
  trouve <- if (length(fn) == 1L) { d <- trimws(deparse(fn[[1]][[3]], width.cutoff = 500L)); attendu %in% d } else rep(FALSE, 3)
  ok_expr <- FALSE
  if (all(trouve)) {
    e <- new.env(parent = ENV_MOTEUR); assign("aj", AJ0, envir = e); assign("jd", JD0, envir = e)
    for (x in attendu) eval(parse(text = x)[[1]], envir = e)
    ok_expr <- identical(get("pool", envir = e), POOL_BRUT(AJ0, JD0))
  }
  actif <- avec_pool_brut(identical(get(".mw_pool_residus", envir = ENV_MOTEUR), POOL_BRUT))
  rest <- pool_restaure()
  lg <- length(POOL_BRUT(AJ0, JD0)) == length(POOL_ORIG(AJ0, JD0))
  list(ok = all(trouve) && ok_expr && actif && rest && lg,
       txt = sprintf("expression du pool de mw_bootstrap() de b827726^:R/engine.R (git show) : %s ; corps inject\u00e9 identique \u00e0 cette expression \u00e9valu\u00e9e sur reserve2 : %s ; injection active pendant l'appel : %s ; .mw_pool_residus restaur\u00e9e (identical()) : %s ; longueurs des deux pools sur reserve2 \u00e9gales (%d) : %s",
                     if (all(trouve)) paste(attendu, collapse = " ; ") else "ILLISIBLE", if (ok_expr) "oui" else "NON", if (actif) "oui" else "NON",
                     if (rest) "oui" else "NON", length(POOL0), if (lg) "oui" else "NON"))
}
virgule <- function(x) sub(".", ",", x, fixed = TRUE)
TXT_DGP <- sprintf("mod\u00e8le de Mack ajust\u00e9 \u00e0 reserve2 (mw_ajuster(), tests/donnees/triangle_mw.csv), I = J = %d ; f\u0302 = (%s) ; \u03c3\u0302\u00b2 = (%s), dont \u03c3\u0302\u00b2_%d extrapol\u00e9 ; premi\u00e8re colonne fix\u00e9e (%s) ; colonnes d\u00e9g\u00e9n\u00e9r\u00e9es de reserve2 : %s ; conformes aux valeurs arrondies du par. 2 : %s ; lois : N (stats::rnorm), E (loi uniforme sur les %d valeurs de .mw_pool_residus(aj0, jd0) divis\u00e9es par leur \u00e9cart-type de population %s ; pool : asym\u00e9trie %s, exc\u00e8s de kurtosis %s, bornes [%s ; %s], bornes apr\u00e8s division [%s ; %s]), A ((G \u2212 2)/\u221a2, G ~ Gamma(2) par stats::qgamma(stats::runif(n), 2)) ; g\u00e9n\u00e9rateur gen_triangle_h0()",
                   AJ0$I, paste(virgule(sprintf("%.5f", AJ0$f)), collapse = " ; "), paste(virgule(sprintf("%.5g", AJ0$sigma2)), collapse = " ; "), AJ0$J - 1L,
                   paste(virgule(sprintf("%.4f", AJ0$tri[, 1])), collapse = " ; "), if (length(JD0)) paste(JD0, collapse = ", ") else "aucune",
                   if (isTRUE(all(sprintf("%.5f", AJ0$f) == c("3.20372", "1.65175", "1.32525", "1.15042", "1.09469", "1.06455", "1.02841")) &&
                              all(sprintf("%.5g", AJ0$sigma2) == c("0.72404", "0.71209", "0.69814", "0.31478", "0.097325", "0.18967", "0.097325")))) "oui" else "NON",
                   length(POOL0), num(SD_POP0, 4), num(moments(POOL0)[["asymetrie"]], 3), num(moments(POOL0)[["exces_kurtosis"]], 3),
                   num(min(POOL0), 3), num(max(POOL0), 3), num(min(POOL_E), 3), num(max(POOL_E), 3))
TXT_CONFIG <- sprintf("m\u00e9thode %s, segment %d de l'annexe %s ; B = %d (donn\u00e9e du test calibr\u00e9) ; \u03b1 des verdicts = %s ; seuils mesur\u00e9s 0,10 et 0,05 ; chemin mesur\u00e9 mw_bootstrap() + mw_tests() (identit\u00e9 \u00e0 run_engine() : contr\u00f4le (i2)) ; B_MIN_DEGENERESCENCE = %d",
                      METHODE, SEGMENT, ANNEXE, B_BOOT, num(ALPHA, 2), B_MIN_DEGENERESCENCE)
TXT_GRAINES <- sprintf("triangle b, loi \u2113 : %.0f + %.0f (\u2113 \u2212 1) + b ; bootstrap b, loi \u2113 (les deux pools) : %.0f + %.0f (\u2113 \u2212 1) + b ; oracle k, loi \u2113 : %.0f + %.0f (\u2113 \u2212 1) + k ; \u2113 = 1 (N), 2 (E), 3 (A) ; contr\u00f4les sur reserve2 : %.0f",
                       GRAINE_TRI, PAS_LOI, GRAINE_BOOT, PAS_LOI, GRAINE_ORA, PAS_LOI_ORA, GRAINE_R2)

###############################################################################
#  MODE --controle-289 (#289 ; specification de Fi, par. 5, S-Fi-4)
###############################################################################
# Les niveaux de #206 sont anterieurs a #270 (courbure) et #273 (ordonnee a
# l'origine), qui figent a l'observe des ensembles de colonnes non
# identifiables et remplacent une colonne ecartee sans trace par une
# statistique NA. Le controle verifie deux choses, sans bootstrap complet :
#   volet 1 (observe) : sur les triangles du plan de #206 (niveau L0, memes
#     graines), les ensembles de .mw_ensembles_figes(aj) (colonnes non
#     identifiables de la courbure et de l'ordonnee a l'origine vides ;
#     colonnes degenerees : voir T1) et K constant ;
#   volet 2 (replications) : b = 1..B_REPL_289 de chaque loi, mw_bootstrap() a
#     B = 999 aux graines de #206, catalogue REDUIT {Sonde, Origine,
#     Courbure} injecte dans MW_CATALOGUE_MC de l'environnement du moteur
#     (rendu par finally) : la boucle de tirage de mw_bootstrap() n'est pas
#     recopiee (constat de #340). La sonde est une entree du catalogue
#     (.mc_entree()) appelee par le moteur sur le contexte observe puis sur
#     chaque replication reajustee ; elle consigne, dans un registre, par
#     appel et par verification (O : ordonnee, C : courbure) : colonnes
#     retenues (hors colonnes figees), colonnes a moins de 2 (O) ou 3 (C)
#     valeurs distinctes (predicat unique de #290, .mw_colonnes_non_
#     identifiables(), sur la replication, colonnes degenerees ecartees),
#     colonnes degenerees, colonnes que la regression ponderee (O, lm()) ou
#     la forme close (C, depuis #253 : plus de lm()) ecarte, et la cause de
#     la statistique NA. La cause est le premier cas rencontre en j croissant,
#     comme dans la boucle de la verification ; la sonde recalcule la
#     statistique du test pour s'assurer que ses causes redonnent les NA du
#     moteur (incoherences, attendues nulles).
CAS_289 <- list(O = list(n_min = 3L, k = 2L, jni = "origine_non_identifiables"),
                C = list(n_min = 4L, k = 3L, jni = "non_identifiables"))
CHAMPS_289 <- c("n_ret", "n_peu", "n_deg", "n_ecart", "n_ecart_hors", "na", "cause", "incoh", "err")
# Causes : 0 statistique finie ; 1 colonne retenue degeneree ; 2 colonne
# retenue que lm() (O) ou la forme close (C) ecarte ; 3 autre (par exemple
# aucune colonne retenue) ; 4 erreur du test.
sonde_cas_289 <- function(aj, figes, cas) {
  I <- aj$I; J <- aj$J; jd <- figes$degeneres; jni <- figes[[cas$jni]]
  j <- 0:(J - 1L)
  ret <- j[(I - j) >= cas$n_min & !(j %in% jd) & !(j %in% jni)]
  peu <- setdiff(.mw_colonnes_non_identifiables(aj, jd, cas$n_min, cas$k), jni)
  deg <- vapply(ret, function(k) .mw_colonne_degeneree(aj, k), logical(1))
  erreur <- 0L
  ecart <- vapply(seq_along(ret), function(i) {
    if (deg[i]) return(FALSE)
    k <- ret[i]; idx <- 0:(I - k - 1)
    C0 <- aj$tri[idx + 1, k + 1]; C1 <- aj$tri[idx + 1, k + 2]
    v <- tryCatch(
      if (cas$k == 2L) {
        m <- try(.mw_summary_lm(stats::lm(C1 ~ C0, weights = 1 / C0)), silent = TRUE)
        inherits(m, "try-error") || nrow(m$coefficients) < 2
      } else is.null(.mw_courbure_colonne(C0, C1)),
      error = function(e) NA)
    if (is.na(v)) { erreur <<- erreur + 1L; TRUE } else v
  }, logical(1))
  st <- try(if (cas$k == 2L) mw_test_ordonnee_origine(aj, jd, jni)$stat else mw_test_courbure(aj, jd, jni)$stat, silent = TRUE)
  err_test <- inherits(st, "try-error")
  na <- err_test || !is.finite(st)
  premiere <- NA_integer_
  for (i in seq_along(ret)) if (deg[i]) { premiere <- 1L; break } else if (ecart[i]) { premiere <- 2L; break }
  cause <- if (err_test) 4L else if (!na) 0L else if (!is.na(premiere)) premiere else 3L
  c(n_ret = length(ret), n_peu = length(peu), n_deg = sum(deg), n_ecart = sum(ecart),
    n_ecart_hors = sum(ecart & !(ret %in% peu)), na = as.integer(na), cause = cause,
    incoh = as.integer(!na && !is.na(premiere)), err = erreur + as.integer(err_test))
}
# Entree de catalogue : appel du moteur (contexte observe puis replications) ;
# le registre est un environnement (fermeture). Valeur rendue : nombre de
# colonnes a trop peu de valeurs distinctes, pour les deux verifications.
sonde_289 <- function(registre) function(e) {
  r <- tryCatch(unlist(lapply(names(CAS_289), function(nm) {
    v <- sonde_cas_289(e$aj, e$figes, CAS_289[[nm]]); names(v) <- paste0(names(v), "_", nm); v
  })), error = function(err) NULL)
  registre$n <- registre$n + 1L
  registre$lignes[[registre$n]] <- r
  if (is.null(r)) { registre$erreurs <- registre$erreurs + 1L; return(0) }
  sum(r[paste0("n_peu_", names(CAS_289))])
}
CAT_ORIG <- get("MW_CATALOGUE_MC", envir = ENV_MOTEUR)
catalogue_289 <- function(registre) c(list(Sonde = .mc_entree(sonde_289(registre), "haut")), CAT_ORIG[c("Origine", "Courbure")])
avec_catalogue_289 <- function(cat, expr) {
  assign("MW_CATALOGUE_MC", cat, envir = ENV_MOTEUR)
  tryCatch(expr, finally = assign("MW_CATALOGUE_MC", CAT_ORIG, envir = ENV_MOTEUR))
}
catalogue_restaure <- function() identical(get("MW_CATALOGUE_MC", envir = ENV_MOTEUR), CAT_ORIG)
nouveau_registre_289 <- function() { r <- new.env(); r$n <- 0L; r$erreurs <- 0L; r$lignes <- list(); r }
matrice_registre_289 <- function(r) {
  if (!r$n) return(NULL)
  ok <- !vapply(r$lignes, is.null, logical(1))
  if (!any(ok)) return(NULL)
  m <- do.call(rbind, r$lignes[ok]); rownames(m) <- NULL; m
}
# bootstrap de reference du script, catalogue complet, et bootstrap avec
# catalogue reduit : meme appel mw_bootstrap(aj, B, seed).
bootstrap_sonde_289 <- function(aj, graine, B = B_BOOT) {
  reg <- nouveau_registre_289()
  bt <- avec_catalogue_289(catalogue_289(reg), mw_bootstrap(aj, B = B, seed = graine))
  list(bt = bt, reg = reg)
}
# Rapprochement de la sonde et du moteur pour un bootstrap (#289, audit C4) :
# aucune erreur de la sonde ni ligne perdue du registre, sonde appelee B + 1
# fois (observe, puis une fois par replication evaluee) sauf plafond de retirage
# atteint (replications non evaluees), et, pour chaque verification, B effectif
# du moteur = replications evaluees - statistiques NA comptees par la sonde.
reconcilier_289 <- function(bt, reg, B = B_BOOT) {
  M <- matrice_registre_289(reg)
  if (is.null(M) || reg$erreurs > 0L || nrow(M) != reg$n) return(FALSE)
  cle <- c(O = "Origine", C = "Courbure")
  (reg$n == B + 1 || isTRUE(bt$plafond_cumuls)) &&
    all(vapply(names(cle), function(nm) isTRUE(unname(bt$B_effectif[[cle[[nm]]]]) == (reg$n - 1L) - sum(M[-1L, paste0("na_", nm)])), logical(1)))
}
CLES_289 <- c("Origine", "Courbure")
champs_id_289 <- c("p_mc", "err_mc", "B_effectif", "motif_mc", "granularite_stat", "p_min_mc", "stats_obs")
identite_289 <- function(complet, reduit)
  all(vapply(champs_id_289, function(ch) identical(complet[[ch]][CLES_289], reduit[[ch]][CLES_289]), logical(1))) &&
  all(vapply(c("sigma_boot", "B", "granularite", "cumuls_retires", "plafond_cumuls"), function(ch) identical(complet[[ch]], reduit[[ch]]), logical(1)))

if (MODE == "c289") {
  t_c <- Sys.time()
  N_PROC <- if (.Platform$OS.type == "windows") 1L else if (is.na(N_COEURS)) max(1L, min(4L, parallel::detectCores())) else N_COEURS
  if (.Platform$OS.type == "windows" && !is.na(N_COEURS) && N_COEURS > 1L)
    message("--coeurs ignore sous Windows (mclapply) : un processus")
  appliquer_289 <- function(X, f, prescheduling = TRUE) {
    g <- function(x) tryCatch(f(x), error = function(e) list(statut = "erreur", loi = x$loi, b = x$b, motif = nettoyer_champ(conditionMessage(e))))
    if (N_PROC > 1L) parallel::mclapply(X, g, mc.cores = N_PROC, mc.preschedule = prescheduling) else lapply(X, g)
  }
  BS_OBS <- if (OPT_ESSAI) stats::setNames(rep(list(B1:B2), 3L), LOIS) else
    list(N = seq_len(NIVEAUX$L0[["N_red"]]), E = seq_len(NIVEAUX$L0[["E_red"]]), A = seq_len(NIVEAUX$L0[["A_red"]]))
  BS_REP <- if (OPT_ESSAI) B1:B2 else seq_len(B_REPL_289)
  message("--controle-289 : ", N_PROC, " processus ; observe ", sum(lengths(BS_OBS)), " triangles ; replications ",
          length(LOIS) * length(BS_REP), " triangles a B = ", B_BOOT)

  # --- Controles generaux (reserve2) -------------------------------------------
  cat_ok <- all(CLES_289 %in% names(CAT_ORIG)) && all(QUEUE[CLES_289] == "haut") &&
    all(vapply(CAT_ORIG[CLES_289], function(x) is.null(x$degenere) && is.null(x$non_definie) && is.null(x$extremes), logical(1)))
  controle(cat_ok, sprintf("(b289) Origine et Courbure lues dans MW_CATALOGUE_MC (%d cl\u00e9s au total), queue haute, entr\u00e9es sans degenere, non_definie ni extremes", NS))
  RES_A <- executer_cas("reserve2")
  cmp_a <- comparer_objets(neutraliser_instables(readRDS(chemin_reference("reserve2"))), neutraliser_instables(RES_A), tol = TOLERANCE)
  TXT_A <- sprintf("%s ; %d feuille(s), %d non strictement identique(s), \u00e9cart maximal %s", if (cmp_a$conforme) "conforme" else "NON CONFORME",
                   cmp_a$n_feuilles, cmp_a$n_differentes, formatC(cmp_a$ecart_max, format = "e", digits = 3))
  controle(cmp_a$conforme && identical(unlist(RES_A$metadata[c("B", "alpha", "seed")]), c(B = as.numeric(B_BOOT), alpha = ALPHA, seed = GRAINE_R2)),
           sprintf("(a) reserve2, run_engine(seed = %.0f), conforme \u00e0 tests/reference/reserve2.rds (comparer_objets(), tol\u00e9rance %g) : %s", GRAINE_R2, TOLERANCE, TXT_A))
  cg <- controle_g(); controle(cg$ok, paste("(g)", cg$txt))
  # (graines) : bloquant dans tous les modes, sans tolerance (les bornes
  # PLAGE_* de tests/mesure_calendaire_t8.R sont ecartees de la recherche par
  # litteraux_graines(), R21, #350). Aucune source d'alea n'est ajoutee par ce
  # mode : graines de #206, engine_sous_graine().
  cgr <- controle_graines(); controle(cgr$ok, paste("(graines)", cgr$txt))
  TXT_I3 <- sprintf("empreinte sans commentaires de R/engine.R %s ; md5 de R/engine.R %s, de %s %s, de tests/outils_tests.R %s",
                    EMPREINTE_SC, MD5_MOTEUR, SCRIPT, md5_fichier(FICHIER_SCRIPT), md5_fichier(file.path(DOSSIER_SCRIPT, "outils_tests.R")))
  controle(grepl("^[0-9a-f]{32}$", EMPREINTE_SC), paste("(i3)", TXT_I3))

  # --- Controle positif de la sonde ------------------------------------------------
  # Triangles construits a partir de reserve2 (colonne j = 1, lignes 0 a 5,
  # modifiee ; ou colonne j = 2 degeneree), ensembles figes de reserve2 (vides
  # hors la colonne j = 6) :
  # (1) colonne constante : O et C la comptent a moins de k valeurs distinctes et
  # l'ecartent, statistique NA ; (2) deux valeurs distinctes : O l'accepte, C
  # la compte et l'ecarte ; (3) dispersion relative de 1e-9 (six valeurs
  # distinctes) : le predicat de #290 ne la compte pas, lm() (O) l'ecarte (rang
  # numerique, option (A) de #273), statistique NA ; C la garde ; (4) colonne
  # j = 2 degeneree (C(i,3) = 1,5 C(i,2)) : cause 1. Verifie que la sonde sait
  # compter ce qu'elle cherche.
  figes_pos <- .mw_ensembles_figes(AJ0)
  mod_col1 <- function(f) function(t) { t[1:6, 2] <- f(t[1:6, 2]); t }
  pos <- lapply(list(constante = mod_col1(function(x) rep(1000, 6)),
                     deux = mod_col1(function(x) c(1000, 1000, 1000, 1100, 1100, 1100)),
                     quasi = mod_col1(function(x) 1000 * (1 + 1e-9 * (1:6))),
                     degeneree = function(t) { t[1:5, 4] <- 1.5 * t[1:5, 3]; t }),
                function(m) { aj <- mw_ajuster(m(.tri)); unlist(lapply(names(CAS_289), function(nm) { v <- sonde_cas_289(aj, figes_pos, CAS_289[[nm]]); names(v) <- paste0(names(v), "_", nm); v })) })
  attendu_pos <- list(
    constante = c(n_peu_O = 1, n_deg_O = 0, n_ecart_O = 1, n_ecart_hors_O = 0, na_O = 1, cause_O = 2, incoh_O = 0, n_peu_C = 1, n_deg_C = 0, n_ecart_C = 1, n_ecart_hors_C = 0, na_C = 1, cause_C = 2, incoh_C = 0),
    deux = c(n_peu_O = 0, n_ecart_O = 0, na_O = 0, cause_O = 0, incoh_O = 0, n_peu_C = 1, n_ecart_C = 1, n_ecart_hors_C = 0, na_C = 1, cause_C = 2, incoh_C = 0),
    quasi = c(n_peu_O = 0, n_ecart_O = 1, n_ecart_hors_O = 1, na_O = 1, cause_O = 2, incoh_O = 0, n_peu_C = 0, n_ecart_C = 0, na_C = 0, cause_C = 0, incoh_C = 0),
    degeneree = c(n_peu_O = 0, n_deg_O = 1, n_ecart_O = 0, na_O = 1, cause_O = 1, incoh_O = 0, n_peu_C = 0, n_deg_C = 1, n_ecart_C = 0, na_C = 1, cause_C = 1, incoh_C = 0))
  ok_pos <- all(vapply(names(attendu_pos), function(nm) all(pos[[nm]][names(attendu_pos[[nm]])] == attendu_pos[[nm]]), logical(1)))
  controle(ok_pos, sprintf("(sonde+289) contr\u00f4le positif de la sonde sur quatre triangles construits (colonne j = 1 constante ; \u00e0 deux valeurs ; \u00e0 dispersion relative 1e-9 ; colonne j = 2 d\u00e9g\u00e9n\u00e9r\u00e9e, facteurs tous \u00e9gaux \u00e0 1,5) : champs attendus (n_peu, n_deg, n_ecart, n_ecart_hors, na, cause, incoh de O et C) : %s", if (ok_pos) "tous conformes" else "NON CONFORMES"))
  # Chemin du moteur : mw_bootstrap() avec le catalogue reduit ET un vivier de
  # residus nul injecte (.mw_pool_residus, technique de avec_pool_brut(),
  # restauree par finally) sur reserve2, B = 20. Chaque replication a alors
  # tous ses facteurs egaux a f_j : toutes les colonnes retenues sont
  # degenerees (colonnes figees de reserve2 : {6} seulement). Verifie que
  # l'objet e$figes lu par la sonde dans le moteur donne des evenements, que le
  # B effectif du moteur (0) s'accorde avec les NA de la sonde, et que la
  # sonde ne voit rien a l'observe.
  B_POS <- 20L
  avec_pool_nul_289 <- function(expr) {
    assign(".mw_pool_residus", function(aj, j_degeneres = NULL) numeric(length(POOL_ORIG(aj, j_degeneres))), envir = ENV_MOTEUR)
    tryCatch(expr, finally = assign(".mw_pool_residus", POOL_ORIG, envir = ENV_MOTEUR))
  }
  ep <- avec_pool_nul_289(bootstrap_sonde_289(AJ0, GRAINE_R2, B = B_POS))
  Mp <- matrice_registre_289(ep$reg)
  ok_moteur <- !is.null(Mp) && nrow(Mp) == B_POS + 1L && ep$reg$erreurs == 0L && reconcilier_289(ep$bt, ep$reg, B_POS) &&
    pool_restaure() && catalogue_restaure() &&
    all(vapply(names(CAS_289), function(nm) {
      R <- Mp[-1L, , drop = FALSE]; f <- function(ch) R[, paste0(ch, "_", nm)]
      all(f("n_ret") > 0) && all(f("n_deg") == f("n_ret")) && all(f("na") == 1) && all(f("cause") == 1) && all(f("incoh") == 0) &&
        Mp[1L, paste0("n_deg_", nm)] == 0 && Mp[1L, paste0("na_", nm)] == 0
    }, logical(1))) &&
    all(unlist(ep$bt$B_effectif[CLES_289]) == 0)
  controle(ok_moteur, sprintf("(sonde+289, moteur) mw_bootstrap() sur reserve2, B = %d, catalogue r\u00e9duit et vivier de r\u00e9sidus nul inject\u00e9s : toutes les colonnes retenues des %d r\u00e9plications sont d\u00e9g\u00e9n\u00e9r\u00e9es (cause 1) pour O et C, statistiques NA partout et B effectif d'Origine et de Courbure nul (accord avec la sonde), rien \u00e0 l'observ\u00e9, vivier et catalogue restaur\u00e9s (identical()) : %s", B_POS, B_POS, if (ok_moteur) "oui" else "NON"))

  # --- Identite de l'injection (reserve2 et un triangle du plan) ---------------
  # Avec le catalogue complet (mw_bootstrap() seul) et avec le catalogue reduit
  # (sonde injectee) : les champs des cles Origine et Courbure, la
  # distribution des sigma_boot (tirages) et les booleens du retirage sont
  # identical() ; la sonde est appelee B + 1 fois sur reserve2 (observe, puis
  # une fois par replication) sans aucune erreur.
  aj_r2 <- RES_A$ajustement
  plein_r2 <- mw_bootstrap(aj_r2, B = B_BOOT, seed = GRAINE_R2)
  inj_r2 <- bootstrap_sonde_289(aj_r2, GRAINE_R2)
  id_r2 <- identite_289(plein_r2, inj_r2$bt)
  tri_id <- engine_sous_graine(graine_tri("N", 1L), gen_triangle_h0(AJ0, tireur("N")))
  ad_id <- admettre(tri_id)
  plein_id <- mw_bootstrap(ad_id$aj, B = B_BOOT, seed = graine_boot("N", 1L))
  inj_id <- bootstrap_sonde_289(ad_id$aj, graine_boot("N", 1L))
  id_tri <- ad_id$ok && identite_289(plein_id, inj_id$bt)
  M_r2 <- matrice_registre_289(inj_r2$reg); M_id <- matrice_registre_289(inj_id$reg)
  appels_ok <- inj_r2$reg$n == B_BOOT + 1 && inj_id$reg$n == B_BOOT + 1 && !inj_r2$reg$erreurs && !inj_id$reg$erreurs
  controle(id_r2 && id_tri && catalogue_restaure() && appels_ok,
           sprintf("(i2-289) injection du catalogue r\u00e9duit {Sonde, Origine, Courbure} : sur reserve2 (graine %.0f) et sur le triangle N, b = 1 (graine %.0f), p_mc, err_mc, B_effectif, motif_mc, granularite_stat, p_min_mc et stats_obs des cl\u00e9s Origine et Courbure, sigma_boot, B, granularite, cumuls_retires et plafond_cumuls identiques (identical()) \u00e0 ceux de mw_bootstrap() sans injection (reserve2 : %s ; triangle : %s) ; MW_CATALOGUE_MC restaur\u00e9 (identical()) : %s ; sonde appel\u00e9e %d et %d fois (B + 1 = %d attendu), %d et %d erreur(s) de la sonde",
                   GRAINE_R2, graine_boot("N", 1L), if (id_r2) "oui" else "NON", if (id_tri) "oui" else "NON", if (catalogue_restaure()) "oui" else "NON",
                   inj_r2$reg$n, inj_id$reg$n, B_BOOT + 1, inj_r2$reg$erreurs, inj_id$reg$erreurs))
  incoh_ctl <- sum(M_r2[, paste0("incoh_", names(CAS_289))]) + sum(M_id[, paste0("incoh_", names(CAS_289))])
  rec_ctl <- reconcilier_289(inj_r2$bt, inj_r2$reg) && reconcilier_289(inj_id$bt, inj_id$reg)
  controle(incoh_ctl == 0L && rec_ctl, sprintf("(coh289) coh\u00e9rence de la sonde avec le moteur sur reserve2 et le triangle N, b = 1 (%d appels) : %d incoh\u00e9rence(s) (cause pr\u00e9dite par la sonde avec statistique finie du moteur) ; rapprochement B effectif du moteur = r\u00e9plications \u00e9valu\u00e9es \u2212 statistiques NA de la sonde, pour Origine et Courbure : %s", nrow(M_r2) + nrow(M_id), incoh_ctl, if (rec_ctl) "oui" else "NON"))
  t_ctl <- secondes(t_c)
  message("--controle-289 : controles generaux et identite de l'injection : ", sprintf("%.0f", t_ctl), " s")

  # --- Volet 1 : a l'observe -----------------------------------------------------
  observe_289 <- function(x) {
    tri <- engine_sous_graine(graine_tri(x$loi, x$b), gen_triangle_h0(AJ0, tireur(x$loi)))
    ad <- admettre(tri)
    if (!ad$ok) return(list(statut = "refuse", loi = x$loi, b = x$b, motif = ad$motif))
    aj <- ad$aj; figes <- .mw_ensembles_figes(aj)
    kO <- mw_test_ordonnee_origine(aj, figes$degeneres, figes$origine_non_identifiables)
    kC <- mw_test_courbure(aj, figes$degeneres, figes$non_identifiables)
    kk <- function(r) if (is.null(r$K)) NA_integer_ else as.integer(r$K)
    list(statut = "admis", loi = x$loi, b = x$b, degeneres = figes$degeneres, non_identifiables = figes$non_identifiables,
         origine_non_identifiables = figes$origine_non_identifiables, K_O = kk(kO), K_C = kk(kC),
         stat_O = is.finite(kO$stat), stat_C = is.finite(kC$stat))
  }
  t_v1 <- Sys.time()
  X1 <- unlist(lapply(LOIS, function(l) lapply(BS_OBS[[l]], function(b) list(loi = l, b = b))), recursive = FALSE)
  R1 <- appliquer_289(X1, observe_289)
  R1 <- lapply(R1, function(r) if (is.list(r) && !is.null(r$statut)) r else list(statut = "erreur", loi = NA_character_, b = NA_integer_, motif = "echec du processus"))
  statut1 <- vapply(R1, function(r) r$statut, "")
  d_v1 <- secondes(t_v1)
  message("--controle-289 : volet 1 (observe) : ", length(X1), " triangles, ", sprintf("%.0f", d_v1), " s")
  ens_txt <- function(v) if (length(v)) paste(v, collapse = ",") else "\u2205"
  lignes_v1 <- lapply(LOIS, function(l) {
    r <- R1[vapply(R1, function(x) identical(x$loi, l), logical(1))]
    st <- vapply(r, function(x) x$statut, "")
    adm <- r[st == "admis"]
    tab <- function(champ) {
      v <- vapply(adm, function(x) { y <- x[[champ]]; if (length(y) == 1L && is.na(y)) "NA" else ens_txt(y) }, "")
      if (!length(v)) return("\u2014")
      t <- table(v); paste(sprintf("%s : %d", names(t), as.integer(t)), collapse = " ; ")
    }
    nv <- function(champ) sum(vapply(adm, function(x) length(x[[champ]]) > 0L, logical(1)))
    list(l = l, n = length(r), adm = length(adm), ref = sum(st == "refuse"), err = sum(st == "erreur"),
         jd = tab("degeneres"), nv_ni = nv("non_identifiables"), nv_no = nv("origine_non_identifiables"),
         KO = tab("K_O"), KC = tab("K_C"),
         statO = sum(vapply(adm, function(x) !isTRUE(x$stat_O), logical(1))), statC = sum(vapply(adm, function(x) !isTRUE(x$stat_C), logical(1))),
         motifs = if (sum(st == "refuse")) { t <- table(vapply(r[st == "refuse"], function(x) x$motif, "")); paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") } else "aucun",
         K_O = vapply(adm, function(x) x$K_O, 1L), K_C = vapply(adm, function(x) x$K_C, 1L),
         jd_v = vapply(adm, function(x) ens_txt(x$degeneres), ""))
  })
  names(lignes_v1) <- LOIS
  n_adm1 <- sum(vapply(lignes_v1, function(x) x$adm, 1L)); n_err1 <- sum(statut1 == "erreur")
  nv_ni_tot <- sum(vapply(lignes_v1, function(x) x$nv_ni, 1L)); nv_no_tot <- sum(vapply(lignes_v1, function(x) x$nv_no, 1L))
  jd_tous <- unique(unlist(lapply(lignes_v1, function(x) x$jd_v)))
  KO_tous <- unique(unlist(lapply(lignes_v1, function(x) x$K_O))); KC_tous <- unique(unlist(lapply(lignes_v1, function(x) x$K_C)))
  JD_STRUCT <- as.integer(AJ0$J - 1L)      # colonne j = J - 1 : un seul facteur, degeneree par construction
  v1_nul <- n_adm1 > 0L && nv_ni_tot == 0L && nv_no_tot == 0L && identical(jd_tous, as.character(JD_STRUCT))
  v1_K <- length(KO_tous) == 1L && length(KC_tous) == 1L && !anyNA(c(KO_tous, KC_tous))
  controle(n_err1 == 0L, sprintf("(v1) volet 1 : %d triangle(s) en erreur de calcul sur %d", n_err1, length(X1)))

  # --- Volet 2 : replications ------------------------------------------------------
  replication_289 <- function(x) {
    t0 <- Sys.time()
    tri <- engine_sous_graine(graine_tri(x$loi, x$b), gen_triangle_h0(AJ0, tireur(x$loi)))
    ad <- admettre(tri)
    if (!ad$ok) return(list(statut = "refuse", loi = x$loi, b = x$b, motif = ad$motif))
    r <- bootstrap_sonde_289(ad$aj, graine_boot(x$loi, x$b))
    list(statut = "admis", loi = x$loi, b = x$b, p = r$bt$p_mc[CLES_289], err = r$bt$err_mc[CLES_289], Be = r$bt$B_effectif[CLES_289],
         motif = r$bt$motif_mc[CLES_289], plafond = r$bt$plafond_cumuls, cumuls = r$bt$cumuls_retires,
         n_appels = r$reg$n, erreurs = r$reg$erreurs, M = matrice_registre_289(r$reg), restaure = catalogue_restaure(),
         rec = reconcilier_289(r$bt, r$reg),
         duree = secondes(t0))
  }
  t_v2 <- Sys.time()
  X2 <- unlist(lapply(LOIS, function(l) lapply(BS_REP, function(b) list(loi = l, b = b))), recursive = FALSE)
  R2 <- appliquer_289(X2, replication_289, prescheduling = FALSE)
  d_v2 <- secondes(t_v2)
  message("--controle-289 : volet 2 (replications) : ", length(X2), " triangles, ", sprintf("%.0f", d_v2), " s")
  R2 <- lapply(R2, function(r) if (is.list(r) && !is.null(r$statut)) r else list(statut = "erreur", loi = NA_character_, b = NA_integer_, motif = "echec du processus"))
  st2 <- vapply(R2, function(r) r$statut, "")
  adm2 <- R2[st2 == "admis"]
  n_rec_ko <- sum(!vapply(adm2, function(r) isTRUE(r$rec), logical(1)))
  controle(!any(st2 == "erreur") && catalogue_restaure() && all(vapply(adm2, function(r) isTRUE(r$restaure), logical(1))) && n_rec_ko == 0L,
           sprintf("(v2) volet 2 : %d triangle(s) en erreur de calcul sur %d ; MW_CATALOGUE_MC identique \u00e0 l'original (identical()) apr\u00e8s chaque triangle et \u00e0 la fin ; %d triangle(s) dont le registre de la sonde ne s'accorde pas avec le moteur (aucune erreur de la sonde, B + 1 appels sauf plafond de retirage, B effectif d'Origine et de Courbure = r\u00e9plications \u00e9valu\u00e9es \u2212 NA de la sonde)", sum(st2 == "erreur"), length(X2), n_rec_ko))
  # agregation par loi et verification
  agreg <- function(l, nm) {
    r <- R2[st2 == "admis" & vapply(R2, function(x) identical(x$loi, l), logical(1))]
    M <- do.call(rbind, lapply(r, function(x) x$M[-1L, , drop = FALSE]))      # replications seules
    Mo <- do.call(rbind, lapply(r, function(x) x$M[1L, , drop = FALSE]))      # observe
    g <- function(ch) M[, paste0(ch, "_", nm)]
    go <- function(ch) Mo[, paste0(ch, "_", nm)]
    cs <- g("cause")
    list(l = l, nm = nm, tri = length(r), rep = nrow(M), ret = sum(g("n_ret")),
         peu_c = sum(g("n_peu")), peu_r = sum(g("n_peu") > 0), deg_c = sum(g("n_deg")), deg_r = sum(g("n_deg") > 0),
         ec_c = sum(g("n_ecart")), ec_r = sum(g("n_ecart") > 0), eh_c = sum(g("n_ecart_hors")), eh_r = sum(g("n_ecart_hors") > 0),
         na = sum(g("na")), c1 = sum(cs == 1), c2 = sum(cs == 2), c3 = sum(cs == 3), c4 = sum(cs == 4), incoh = sum(g("incoh")), err = sum(g("err")),
         obs_peu = sum(go("n_peu")), obs_deg = sum(go("n_deg")), obs_ec = sum(go("n_ecart")), obs_na = sum(go("na")))
  }
  AG <- unlist(lapply(LOIS, function(l) lapply(names(CAS_289), function(nm) agreg(l, nm))), recursive = FALSE)
  tot <- function(ch, nm) sum(vapply(AG[vapply(AG, function(a) a$nm == nm, logical(1))], function(a) a[[ch]], 1))
  n_rep_tot <- sum(vapply(adm2, function(x) nrow(x$M) - 1L, 1L))
  controle(sum(vapply(AG, function(a) a$incoh + a$err, 1)) == 0, sprintf("(coh289-v2) coh\u00e9rence de la sonde avec le moteur sur les %d r\u00e9plications du volet 2 : %d incoh\u00e9rence(s), %d erreur(s) de la sonde ou du test", n_rep_tot, sum(vapply(AG, function(a) a$incoh, 1)), sum(vapply(AG, function(a) a$err, 1))))
  borne95 <- function(k, n) if (n > 0) stats::qbeta(0.95, k + 1, n - k) else NA_real_
  fmt_e <- function(x) if (!is.finite(x)) "\u2014" else sub(".", ",", sprintf("%.1e", x), fixed = TRUE)
  # B effectif et retirage
  lignes_Be <- unlist(lapply(LOIS, function(l) lapply(CLES_289, function(k) {
    r <- adm2[vapply(adm2, function(x) identical(x$loi, l), logical(1))]
    be <- vapply(r, function(x) as.numeric(x$Be[[k]]), 1)
    list(l = l, k = k, n = length(r), min = if (length(be)) min(be) else NA_real_, moy = if (length(be)) mean(be) else NA_real_,
         n_inf = sum(be < B_BOOT), plafond = sum(vapply(r, function(x) isTRUE(x$plafond), logical(1))),
         cumuls = sum(vapply(r, function(x) isTRUE(x$cumuls), logical(1))),
         motifs = sum(vapply(r, function(x) !is.na(x$motif[[k]]), logical(1))))
  })), recursive = FALSE)
  # --- Comparaison descriptive aux colonnes pR: du brut de #206 --------------------
  BRUT_206 <- file.path(RACINE, "docs", "tableaux", "20261011-issue206-calibration-mw-brut.tsv")
  MD_206 <- file.path(RACINE, "docs", "tableaux", "20261011-issue206-calibration-mw.md")
  brut <- if (file.exists(BRUT_206)) utils::read.delim(BRUT_206, sep = "\t", header = TRUE, quote = "", colClasses = "character", check.names = FALSE) else NULL
  commit_206 <- if (file.exists(MD_206)) { l <- readLines(MD_206, warn = FALSE, encoding = "UTF-8"); sub("^\\| Commit \\| (.*) \\|$", "\\1", l[grepl("^\\| Commit \\| ", l)][1]) } else NA_character_
  md5_206 <- if (file.exists(MD_206)) { l <- readLines(MD_206, warn = FALSE, encoding = "UTF-8"); sub("^.*R/engine.R ([0-9a-f]{32}).*$", "\\1", l[grepl("^\\| Empreintes md5 du code ex.cut. \\|", l)][1]) } else NA_character_
  cmp <- NULL
  if (!is.null(brut)) {
    br <- brut[brut$type == "rep", , drop = FALSE]
    cmp <- do.call(rbind, lapply(adm2, function(x) do.call(rbind, lapply(CLES_289, function(k) {
      i <- which(br$loi == x$loi & br$b == as.character(x$b))
      if (length(i) != 1L) return(data.frame(loi = x$loi, b = x$b, cle = k, p_ref = NA_real_, p_new = unname(x$p[[k]]), B_ref = NA_real_, B_new = unname(as.numeric(x$Be[[k]])), stringsAsFactors = FALSE))
      data.frame(loi = x$loi, b = x$b, cle = k, p_ref = suppressWarnings(as.numeric(br[i, paste0("pR:", k)])), p_new = unname(x$p[[k]]),
                 B_ref = suppressWarnings(as.numeric(br[i, paste0("BR:", k)])), B_new = unname(as.numeric(x$Be[[k]])), stringsAsFactors = FALSE)
    }))))
    cmp$diff <- cmp$p_new - cmp$p_ref
    cmp$egal <- (is.na(cmp$p_ref) & is.na(cmp$p_new) & is.na(cmp$B_ref)) | (!is.na(cmp$diff) & abs(cmp$diff) <= 1e-12 & cmp$B_ref == cmp$B_new)
    cmp$egal[is.na(cmp$egal)] <- FALSE
  }

  # --- Tableaux ----------------------------------------------------------------------
  DUREE_289 <- c(t_ctl, d_v1, d_v2, secondes(t_debut))
  PAIRES_289 <- list()
  ajout_289 <- function(lib, val) PAIRES_289[[length(PAIRES_289) + 1L]] <<- c(lib, val)
  ajout_289("Mode", sprintf("--controle-289 (#289, sp\u00e9cification de Fi, par. 5)%s", if (OPT_ESSAI) " -- ESSAI, plan r\u00e9duit, non versionnable" else ""))
  ajout_289("DGP sous H0 (par. 2 de #206)", TXT_DGP)
  ajout_289("Configuration", TXT_CONFIG)
  ajout_289("Plan", sprintf("volet 1 (observ\u00e9) : %s ; volet 2 (r\u00e9plications) : b = %d..%d de chaque loi, %d triangles, B = %d, catalogue r\u00e9duit {Sonde, Origine, Courbure} inject\u00e9 dans MW_CATALOGUE_MC",
                            paste(sprintf("%s %d (b = %d..%d)", LOIS, lengths(BS_OBS), vapply(BS_OBS, min, 1L), vapply(BS_OBS, max, 1L)), collapse = ", "),
                            min(BS_REP), max(BS_REP), length(X2), B_BOOT))
  ajout_289("Graines (par. 7 de #206)", TXT_GRAINES)
  ajout_289("Graines : recherche des collisions", cgr$txt)
  ajout_289("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", "))
  ajout_289("Commit", COMMIT)
  ajout_289("Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)", plateforme_calcul())
  ajout_289("Processus (mclapply)", as.character(N_PROC))
  ajout_289("Empreintes md5 du code ex\u00e9cut\u00e9", EMPREINTES)
  ajout_289("Empreinte sans commentaires de R/engine.R (#231) et md5 du fichier entier", sprintf("%s (md5 du fichier entier %s)", EMPREINTE_SC, MD5_MOTEUR))
  ajout_289("Contr\u00f4le (a) : reserve2 contre tests/reference/reserve2.rds", TXT_A)
  ajout_289("Brut de #206 (comparaison descriptive)", if (is.null(brut)) "introuvable" else sprintf("%s (md5 %s), commit de #206 %s, md5 de R/engine.R de #206 %s",
                                                                                                 chemin_cite(BRUT_206), md5_fichier(BRUT_206), commit_206, md5_206))
  ajout_289("Locale LC_CTYPE (origine \u2192 travail)", sprintf("%s \u2192 %s", LOCALE_ORIGINE, LOCALE_TRAVAIL))
  ajout_289("Dur\u00e9e (s)", sprintf("contr\u00f4les g\u00e9n\u00e9raux et identit\u00e9 de l'injection %.0f ; volet 1 %.0f ; volet 2 %.0f ; total %.0f", DUREE_289[1], DUREE_289[2], DUREE_289[3], DUREE_289[4]))
  ajout_289("Contr\u00f4les d'int\u00e9grit\u00e9", if (length(INTEGRITE)) "\u00c9CHEC" else "OK")
  T1 <- c("### T1 \u2014 volet 1 : ensembles fig\u00e9s et K \u00e0 l'observ\u00e9 (triangles du plan de #206)", "",
          "Ensembles de `.mw_ensembles_figes(aj)` et K des deux v\u00e9rifications, calcul\u00e9s comme `mw_bootstrap()` les fige (d\u00e9faut du moteur, sur le triangle admis). La colonne `degeneres` liste les valeurs distinctes observ\u00e9es de l'ensemble avec leur effectif ; `\u2205` : ensemble vide.", "",
          entete_md(c("Loi", "triangles", "admis", "refus\u00e9s", "en erreur", "`degeneres` (valeurs : effectif)", "`non_identifiables` non vide (courbure)",
                      "`origine_non_identifiables` non vide", "K ordonn\u00e9e (valeur : effectif)", "K courbure (valeur : effectif)", "statistique observ\u00e9e NA (O ; C)")),
          vapply(lignes_v1, function(x) ligne_md(x$l, x$n, x$adm, x$ref, x$err, x$jd, x$nv_ni, x$nv_no, x$KO, x$KC, sprintf("%d ; %d", x$statO, x$statC)), ""), "",
          sprintf("Motifs de refus : %s.", paste(sprintf("%s : %s", LOIS, vapply(lignes_v1, function(x) x$motifs, "")), collapse = " ; ")), "",
          sprintf("Constat : sur %d triangles admis, ensemble des colonnes non identifiables de la courbure non vide dans %d triangle(s), ensemble de l'ordonn\u00e9e \u00e0 l'origine non vide dans %d ; ensemble `degeneres` : %s (colonne j = %d, un seul facteur, n_j = 1, d\u00e9g\u00e9n\u00e9r\u00e9e au sens de `.mw_colonne_degeneree()`) ; K ordonn\u00e9e : %s ; K courbure : %s. Les deux ensembles de #270 et #273 sont %s.",
                  n_adm1, nv_ni_tot, nv_no_tot, paste(jd_tous, collapse = " ; "), JD_STRUCT, paste(KO_tous, collapse = ", "), paste(KC_tous, collapse = ", "),
                  if (v1_nul) "vides sur tous les triangles admis" else "NON VIDES sur au moins un triangle admis (contr\u00f4le non nul)"),
          sprintf("Sp\u00e9cification (par. 5, point 1) : K = 5 pour l'ordonn\u00e9e, K = 4 pour la courbure ; K %s sur tous les triangles admis%s.",
                  if (v1_K) "constant" else "NON constant",
                  if (v1_K) sprintf(" (observ\u00e9 : %d et %d)", KO_tous, KC_tous) else ""), "")
  lib_nm <- c(O = "ordonn\u00e9e (n_j \u2265 3, < 2 valeurs distinctes)", C = "courbure (n_j \u2265 4, < 3 valeurs distinctes)")
  T2 <- c("### T2 \u2014 volet 2 : colonnes retenues que la r\u00e9plication rend non identifiables", "",
          sprintf("Colonnes retenues = colonnes de n_j au moins 3 (O) ou 4 (C) hors des colonnes fig\u00e9es \u00e0 l'observ\u00e9. Une colonne retenue est compt\u00e9e **d\u00e9g\u00e9n\u00e9r\u00e9e** (pr\u00e9dicat de #56, sur la r\u00e9plication), **\u00e0 moins de 2 (O) ou 3 (C) valeurs distinctes** (pr\u00e9dicat de #290 appel\u00e9 sur la r\u00e9plication ; les colonnes d\u00e9g\u00e9n\u00e9r\u00e9es en sont \u00e9cart\u00e9es, les deux comptes sont donc disjoints), ou **\u00e9cart\u00e9e** par la r\u00e9gression pond\u00e9r\u00e9e `lm()` (O) ou par la forme close de #253 (C, sans `lm()`) ; \u00ab \u00e9cart\u00e9e hors <k valeurs \u00bb = \u00e9cart\u00e9e sans \u00eatre \u00e0 moins de k valeurs distinctes (rang num\u00e9rique). R\u00e9plications \u00e9valu\u00e9es par le moteur : %d (sur %d triangles admis).", n_rep_tot, length(adm2)), "",
          entete_md(c("Loi", "v\u00e9rification", "triangles", "r\u00e9plications", "colonnes retenues", "colonnes < k valeurs distinctes (r\u00e9plications)",
                      "colonnes d\u00e9g\u00e9n\u00e9r\u00e9es (r\u00e9plications)", "colonnes \u00e9cart\u00e9es (r\u00e9plications)", "dont hors < k valeurs (r\u00e9plications)", "observ\u00e9 : < k / d\u00e9g. / \u00e9cart. / NA")),
          vapply(AG, function(a) ligne_md(a$l, lib_nm[[a$nm]], a$tri, a$rep, a$ret, sprintf("%d (%d)", a$peu_c, a$peu_r), sprintf("%d (%d)", a$deg_c, a$deg_r),
                                          sprintf("%d (%d)", a$ec_c, a$ec_r), sprintf("%d (%d)", a$eh_c, a$eh_r), sprintf("%d / %d / %d / %d", a$obs_peu, a$obs_deg, a$obs_ec, a$obs_na)), ""), "",
          "### T3 \u2014 volet 2 : statistiques NA par cause", "",
          "Cause = premier cas rencontr\u00e9 en j croissant parmi les colonnes retenues (ordre de la boucle de la v\u00e9rification) : colonne d\u00e9g\u00e9n\u00e9r\u00e9e, colonne \u00e9cart\u00e9e par `lm()` ou la forme close ; \u00ab autre \u00bb : statistique NA sans colonne fautive (par exemple aucune colonne retenue) ; \u00ab erreur \u00bb : erreur du test. Incoh\u00e9rences : la sonde pr\u00e9dit une cause alors que la statistique du moteur est finie (attendu 0).", "",
          entete_md(c("Loi", "v\u00e9rification", "r\u00e9plications", "statistiques NA", "colonne d\u00e9g\u00e9n\u00e9r\u00e9e", "colonne \u00e9cart\u00e9e (lm() / forme close)", "autre", "erreur du test", "incoh\u00e9rences")),
          vapply(AG, function(a) ligne_md(a$l, lib_nm[[a$nm]], a$rep, a$na, a$c1, a$c2, a$c3, a$c4, a$incoh), ""), "")
  ev_peu <- tot("peu_r", "O") + tot("peu_r", "C"); ev_deg <- tot("deg_r", "O") + tot("deg_r", "C"); ev_ec <- tot("ec_r", "O") + tot("ec_r", "C")
  ev_na <- tot("na", "O") + tot("na", "C")
  n_rep_v <- tot("rep", "O"); ntests <- 2L
  lecture <- function(nm, lib) {
    n <- tot("rep", nm); k1 <- tot("peu_r", nm); k2 <- tot("na", nm); k3 <- tot("ec_r", nm); k4 <- tot("deg_r", nm)
    sprintf("%s : %d r\u00e9plication(s) \u00e9valu\u00e9e(s) ; r\u00e9plications avec au moins une colonne \u00e0 moins de %d valeurs distinctes : %d (taux observ\u00e9 %s, borne sup\u00e9rieure unilat\u00e9rale exacte \u00e0 95 %% %s%s) ; avec une colonne d\u00e9g\u00e9n\u00e9r\u00e9e : %d ; avec une colonne \u00e9cart\u00e9e : %d ; statistiques NA : %d (borne sup\u00e9rieure %s).",
            lib, n, CAS_289[[nm]]$k, k1, fmt_e(k1 / n), fmt_e(borne95(k1, n)), if (k1 == 0L) sprintf(" ; r\u00e8gle de trois 3/n = %s", fmt_e(3 / n)) else "", k4, k3, k2, fmt_e(borne95(k2, n)))
  }
  T3b <- c("### T4 \u2014 B effectif et retirage (cl\u00e9s Origine et Courbure)", "",
           entete_md(c("Loi", "cl\u00e9", "triangles", "B effectif minimal", "B effectif moyen", "triangles avec B effectif < 999", "triangles avec motif d'absence de p", "plafond de retirage atteint (#257)", "triangles avec triangle simul\u00e9 retir\u00e9 (#257)")),
           vapply(lignes_Be, function(x) ligne_md(x$l, x$k, x$n, num(x$min, 0), num(x$moy, 3), x$n_inf, x$motifs, x$plafond, x$cumuls), ""), "")
  # triangles touches par au moins un evenement (colonne a trop peu de valeurs distinctes, degeneree
  # ou ecartee, ou statistique NA, pour l'une ou l'autre verification), au total et par loi
  tri_touche <- vapply(adm2, function(x) any(x$M[-1L, grep("^(n_peu|n_deg|n_ecart|na)_", colnames(x$M)), drop = FALSE] > 0), logical(1))
  loi_tri <- vapply(adm2, function(x) x$loi, "")
  n_tri <- length(adm2); k_tri <- sum(tri_touche)
  txt_par_loi <- paste(vapply(LOIS, function(l) sprintf("%s %d sur %d (borne %s)", l, sum(tri_touche[loi_tri == l]), sum(loi_tri == l), fmt_e(borne95(sum(tri_touche[loi_tri == l]), sum(loi_tri == l)))), ""), collapse = " ; ")
  T5 <- c("### T5 \u2014 lecture", "",
          sprintf("**Recensement \u00e0 l'observ\u00e9 (volet 1)** : %d triangles admis du plan de #206 (aucun \u00e9chantillonnage) ; ensembles de #270 et #273 non vides dans %d + %d d'entre eux.", n_adm1, nv_ni_tot, nv_no_tot),
          "", "**\u00c9chantillon de r\u00e9plications (volet 2)**, sous l'hypoth\u00e8se d'ind\u00e9pendance des r\u00e9plications (que le tirage par triangle ne v\u00e9rifie pas : les r\u00e9plications d'un triangle partagent son vivier de r\u00e9sidus) :", "",
          lecture("O", "Ordonn\u00e9e \u00e0 l'origine"), "", lecture("C", "Courbure"), "",
          sprintf("Total des deux v\u00e9rifications : %d r\u00e9plications \u00e9valu\u00e9es chacune ; %d (r\u00e9plication, v\u00e9rification) avec colonne \u00e0 trop peu de valeurs distinctes, %d avec colonne d\u00e9g\u00e9n\u00e9r\u00e9e, %d avec colonne \u00e9cart\u00e9e, %d statistiques NA.",
                  n_rep_v, ev_peu, ev_deg, ev_ec, ev_na),
          "", sprintf("**Borne par triangle, sans hypoth\u00e8se d'ind\u00e9pendance des r\u00e9plications** : triangles touch\u00e9s par au moins un \u00e9v\u00e9nement : %d sur %d, borne sup\u00e9rieure unilat\u00e9rale exacte \u00e0 95 %% %s ; par loi : %s.", k_tri, n_tri, fmt_e(borne95(k_tri, n_tri)), txt_par_loi),
          "", sprintf("**Contr\u00f4le %s.**", if (v1_nul && v1_K && ev_peu == 0L && ev_ec == 0L && ev_na == 0L && ev_deg == 0L) "nul sur les deux volets" else "NON NUL (point de d\u00e9cision, sp\u00e9cification de Fi, par. 5, point 4)"),
          "", sprintf("Statut : constat de simulation sous le plan de #206 (mod\u00e8le de Mack ajust\u00e9 \u00e0 reserve2, g\u00e9om\u00e9trie 8 \u00d7 8) ; volet 1 : les %d triangles du plan de #206 ; volet 2 : %d d'entre eux (b = %d \u00e0 %d par loi). Z\u00e9ro \u00e9v\u00e9nement ne prouve pas l'absence d'\u00e9v\u00e9nement, il en borne le taux. La borne unilat\u00e9rale exacte \u00e0 95 %% est q_{0,95} de la loi b\u00eata(k + 1, n \u2212 k) ; la r\u00e8gle de trois (3/n) en est l'approximation pour k = 0. Le z\u00e9ro du volet 2 est attendu par construction [H] : premi\u00e8re colonne fix\u00e9e \u00e0 huit valeurs distinctes, colonnes suivantes simul\u00e9es \u00e0 partir d'erreurs continues (N, A) ou d'un vivier de 27 valeurs (E), sans co\u00efncidence exacte attendue ; hypoth\u00e8se non d\u00e9montr\u00e9e, et les bornes ci-dessus ne disent rien d'un plan o\u00f9 cette construction ne tiendrait pas. Cette mesure ne porte ni sur le niveau des p_mc ni sur les autres statistiques.", n_adm1, n_tri, min(BS_REP), max(BS_REP)), "")
  T6 <- c("### T6 \u2014 comparaison descriptive aux colonnes `pR:` du brut de #206", "")
  if (is.null(cmp)) T6 <- c(T6, "Brut de #206 introuvable.", "") else {
    T6 <- c(T6, "Comparaison descriptive, **pas un crit\u00e8re** : #206 a \u00e9t\u00e9 mesur\u00e9 sur un autre commit du moteur (voir T0), et des modifications post\u00e9rieures (par exemple #253, forme close de la courbure) ont pu changer des bits. Une ligne est \u00ab \u00e9gale \u00bb si |p_new \u2212 p_ref| \u2264 1e-12 et si les B effectifs co\u00efncident.", "",
            entete_md(c("Loi", "cl\u00e9", "triangles compar\u00e9s", "\u00e9gaux", "diff\u00e9rents", "\u00e9cart absolu maximal")),
            unlist(lapply(LOIS, function(l) vapply(CLES_289, function(k) {
              s <- cmp[cmp$loi == l & cmp$cle == k, ]
              ligne_md(l, k, nrow(s), sum(s$egal), sum(!s$egal), fmt_e(if (any(is.finite(s$diff))) max(abs(s$diff), na.rm = TRUE) else NA_real_))
            }, ""))), "")
    dif <- cmp[!cmp$egal, ]
    if (nrow(dif)) {
      T6 <- c(T6, sprintf("Diff\u00e9rences list\u00e9es (%d)%s :", nrow(dif), if (nrow(dif) > 60L) ", 60 premi\u00e8res" else ""), "",
              entete_md(c("Loi", "b", "cl\u00e9", "p (#206)", "p (cette mesure)", "diff\u00e9rence", "B effectif (#206)", "B effectif (cette mesure)")),
              vapply(seq_len(min(nrow(dif), 60L)), function(i) ligne_md(dif$loi[i], dif$b[i], dif$cle[i], fmt_p(dif$p_ref[i]), fmt_p(dif$p_new[i]),
                                                                       if (is.finite(dif$diff[i])) sub(".", ",", sprintf("%+.3g", dif$diff[i]), fixed = TRUE) else "\u2014",
                                                                       dif$B_ref[i], dif$B_new[i]), ""), "")
    } else T6 <- c(T6, "Aucune diff\u00e9rence : les p_mc d'Origine et de Courbure des triangles compar\u00e9s sont identiques \u00e0 celles de #206 (|\u00e9cart| \u2264 1e-12, B effectifs \u00e9gaux).", "")
  }
  S <- c(sprintf("## Contr\u00f4le #289 : ensembles fig\u00e9s de M1 (courbure, ordonn\u00e9e \u00e0 l'origine) \u00e0 T = 8, Merz-W\u00fcthrich%s", if (OPT_ESSAI) " -- ESSAI" else ""), "",
         "### T0 \u2014 provenance", "", entete_md(c("Grandeur", "Valeur")),
         vapply(PAIRES_289, function(p) ligne_md(p[1], nettoyer_champ(p[2])), ""), "",
         T1, T2, T3b, T5, T6,
         "### Contr\u00f4les d'int\u00e9grit\u00e9", "", paste("-", CONTROLES), "",
         sprintf("Bilan : %s", if (length(INTEGRITE)) sprintf("\u00c9CHEC (%d contr\u00f4le(s))", length(INTEGRITE)) else "OK"), "")
  S <- S[!is.na(S)]
  ecrire_console(S)
  if (OPT_ECRIRE) {
    nv_f <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, SPECS_LUES), "de l'execution")
    if (length(nv_f) || length(INTEGRITE) || length(chemins_absolus(utf8(S)))) {
      message("--ecrire refuse : ", paste(c(nv_f, if (length(INTEGRITE)) "controles d'integrite en ECHEC", if (length(chemins_absolus(utf8(S)))) "chemin absolu ou /tmp dans le tableau"), collapse = " ; "))
      quit(status = 1L)
    }
    garde_ecrasement(CIBLE_289, OPT_REMPLACER, RACINE)
    con <- file(CIBLE_289, open = "wb"); writeLines(utf8(S), con, useBytes = TRUE); close(con)
    message("ecrit (md5 ", md5_fichier(CIBLE_289), ") : ", chemin_cite(CIBLE_289))
  }
  quit(status = if (length(INTEGRITE)) 1L else 0L)
}

###############################################################################
#  MODE --prevol (par. 8)
###############################################################################
# Debit a 1, 2, 3 et 4 processus concurrents (--prevol-unite, loi N) : duree
# par unite (mw_bootstrap() a B = 999 + mw_tests() + regressions de #119) de
# chaque processus ; UNITES unites par processus.
mesurer_debit <- function() {
  RSCRIPT <- file.path(R.home("bin"), "Rscript")
  if (is.na(FICHIER_SCRIPT)) stop("--prevol : chemin du script introuvable (lancer par Rscript)")
  dossier <- tempfile("prevol206_"); dir.create(dossier)
  on.exit(unlink(dossier, recursive = TRUE))
  CB <- list()
  for (k in 1:4) {
    fs <- file.path(dossier, sprintf("k%d-%d.txt", k, seq_len(k)))
    for (i in seq_len(k)) {
      b1 <- (i - 1L) * UNITES + 1L
      system2(RSCRIPT, c(shQuote(FICHIER_SCRIPT), "--prevol-unite", "--loi", "N", "--b", sprintf("%d:%d", b1, b1 + UNITES - 1L)),
              stdout = fs[i], stderr = sub("\\.txt$", ".err", fs[i]), wait = FALSE)
    }
    t_lim <- Sys.time() + 3600
    repeat {
      fini <- vapply(fs, function(f) file.exists(f) && any(readLines(f, warn = FALSE) == "FIN"), logical(1))
      if (all(fini) || Sys.time() > t_lim) break
      Sys.sleep(2)
    }
    if (!all(fini)) stop("--prevol : unite(s) de debit non terminee(s) en 1 h (k = ", k, ")")
    CB[[k]] <- unlist(lapply(fs, function(f) { x <- grep("^UNITE\t", readLines(f), value = TRUE); as.numeric(vapply(strsplit(x, "\t"), `[`, "", 3L)) }))
  }
  CB
}
# Pre-vol de la campagne 297 (specification de Fk, par. 5.2 et 5.5, point
# 5) : admission des triangles des lois N et E, couts unitaires, debit a 1
# a 4 processus de ce script ; avec --prevol-ln (sortie de
# "tests/calibration_mc_t8.R --prevol", ligne PREVOL_LN : c_J1, c_J2, P1 a
# P4, cout des controles d'une tranche lognormale), duree planifiee de
# chaque niveau L0 a L4 a 4 processus,
#   duree = [(R_N + R_E) c_b + F_mw] / (P_4 x 3 600)
#         + [R_J1 c_J1 + R_J2 c_J2 + n_ln c_ctl] / (P_4,ln x 3 600),
# F_mw = 2 N0 t_oracle + n_tr (5 c_b + c_gen) + 2 (c_b + c_gen) (regle de
# #206 sans pool brut ni sous-mesure N), et premier niveau tenu en
# BUDGET_H_297 heures (sous L4 : decision du mainteneur). Rien d'ecrit.
if (MODE == "prevol" && CAMPAGNE == "297") {
  ecrire_console(c("## Pr\u00e9-vol de la mesure #297 (Fk), volet Merz-W\u00fcthrich (rien d'\u00e9crit)", "",
                   sprintf("Commit : %s ; plateforme : %s ; c\u0153urs (parallel::detectCores()) : %s ; d\u00e9but %s UTC", COMMIT, plateforme_calcul(),
                           tryCatch(parallel::detectCores(), error = function(e) "?"), format(Sys.time(), "%Y-%m-%dT%H:%M:%S", tz = "UTC")), ""))
  L <- c("### Triangles des lois N et E : admission (motifs de refus)", "", entete_md(c("Loi", "triangles", "refus\u00e9s", "motifs", "s par triangle")))
  for (l in c("N", "E")) {
    Rl <- max(vapply(NIVEAUX_297, function(R) R[[l]], 1))
    t0 <- Sys.time()
    mo <- vapply(seq_len(Rl), function(b) admettre(engine_sous_graine(graine_tri(l, b), gen_triangle_h0(AJ0, tireur(l))))$motif, "")
    d <- secondes(t0); rf <- !is.na(mo)
    L <- c(L, ligne_md(l, Rl, sum(rf), if (any(rf)) { t <- table(mo[rf]); paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") } else "aucun",
                       num(d / Rl, 4)))
  }
  ecrire_console(c(L, ""))
  t0 <- Sys.time(); invisible(lapply(seq_len(50), function(k) traiter_oracle("N", k))); t_or <- secondes(t0) / 50
  t0 <- Sys.time(); invisible(controle_g()); invisible(controle_i4()); invisible(controle_graines())
  invisible(empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))); c_gen <- secondes(t0)
  CB <- mesurer_debit()
  c_b <- mean(CB[[1]]); P_k <- vapply(1:4, function(k) k * c_b / mean(CB[[k]]), 1)
  ecrire_console(c("### D\u00e9bit du volet Merz-W\u00fcthrich", "",
                   sprintf("c_b (mw_bootstrap() \u00e0 B = 999 + mw_tests() + r\u00e9gressions de #119, un processus, %d unit\u00e9(s)) : %s s ; triangle oracle : %s s ; contr\u00f4les l\u00e9gers ((g), (i4), (graines), (i3)) : %s s.",
                           length(CB[[1]]), num(c_b, 2), num(t_or, 4), num(c_gen, 1)), "",
                   entete_md(c("processus concurrents", "dur\u00e9e par unit\u00e9 (s) : moyenne [min ; max]", "d\u00e9bit agr\u00e9g\u00e9 P_k = k c_b / moyenne")),
                   vapply(1:4, function(k) ligne_md(k, sprintf("%s [%s ; %s]", num(mean(CB[[k]]), 2), num(min(CB[[k]]), 2), num(max(CB[[k]]), 2)), num(P_k[k], 3)), ""), ""))
  LN <- NULL
  if (!is.na(OPT_PREVOL_LN)) {
    x <- grep("^PREVOL_LN\t", readLines(OPT_PREVOL_LN, warn = FALSE), value = TRUE)
    v <- if (length(x) == 1L) suppressWarnings(as.numeric(strsplit(x, "\t", fixed = TRUE)[[1]][-1])) else numeric(0)
    if (length(v) != 7L || anyNA(v) || any(v <= 0)) stop("--prevol-ln : ligne PREVOL_LN absente, multiple ou illisible (7 nombres positifs attendus)")
    LN <- list(c_J1 = v[1], c_J2 = v[2], P = v[3:6], c_ctl = v[7])
  }
  # Duree d'une tranche Merz-Wuthrich (TAILLE_SEULE triangles a la duree
  # mesuree a 4 processus, plus ses controles) ; borne de la duree d'horloge
  # = duree planifiee + 0,75 x duree d'une tranche : borne d'ordonnancement en
  # liste, hypothese [H] (avis d'actuary du 25/10/2026, point 5), comparee au
  # plafond, sans changer la regle de choix du niveau (par. 5.2).
  h_tranche <- (TAILLE_SEULE * mean(CB[[4]]) + 5 * c_b + c_gen) / 3600
  niv <- lapply(names(NIVEAUX_297), function(nv) {
    R <- NIVEAUX_297[[nv]]; pl <- plan_tranches_297(nv); ar <- sub("^[^\t]*\t", "", pl)
    n_tr <- sum(grepl("^--loi", ar)); n_ora <- sum(grepl("^--oracle", ar)); n_ln <- sum(grepl("^--jeu", ar))
    F_mw <- n_ora * N0_SPEC * t_or + n_tr * (5 * c_b + c_gen) + n_ora * (c_b + c_gen)
    h_mw <- ((R[["N"]] + R[["E"]]) * c_b + F_mw) / (P_k[4] * 3600)
    h_ln <- if (is.null(LN)) NA_real_ else (R[["J1"]] * LN$c_J1 + R[["J2"]] * LN$c_J2 + n_ln * LN$c_ctl) / (LN$P[4] * 3600)
    list(niv = nv, R = R, n_fic = length(pl), F_mw = F_mw, h_mw = h_mw, h_ln = h_ln, duree = h_mw + h_ln,
         borne = h_mw + h_ln + 0.75 * h_tranche)
  })
  ok <- vapply(niv, function(x) isTRUE(x$duree <= BUDGET_H_297), logical(1))
  ret <- if (any(ok)) niv[[which(ok)[1]]] else NULL
  ecrire_console(c(sprintf("### \u00c9chelle L0 \u00e0 L4 (sp\u00e9cification de Fk, par. 5.2) : dur\u00e9e planifi\u00e9e \u00e0 4 processus, budget %d h", BUDGET_H_297), "",
                   if (is.null(LN)) "**Volet lognormal absent (--prevol-ln) : dur\u00e9es lognormales et niveau non d\u00e9termin\u00e9s.**" else
                     sprintf("Volet lognormal (%s) : c_J1 = %s s, c_J2 = %s s par r\u00e9plication (un processus) ; P_4 = %s ; contr\u00f4les d'une tranche : %s s.",
                             basename(OPT_PREVOL_LN), num(LN$c_J1, 2), num(LN$c_J2, 2), num(LN$P[4], 3), num(LN$c_ctl, 1)), "",
                   entete_md(c("Niveau", "changement", "R (N, E, J1, J2)", "sorties (plan)", "F_mw (h CPU)", "MW (h d'horloge)", "LN (h d'horloge)",
                               "dur\u00e9e planifi\u00e9e (h)", sprintf("tient en %d h", BUDGET_H_297),
                               "borne : planifi\u00e9e + 0,75 tranche MW (h) [H]", sprintf("borne \u2264 %d h", BUDGET_H_297))),
                   vapply(niv, function(x) ligne_md(x$niv, LIB_NIVEAUX_297[[x$niv]], paste(x$R, collapse = ", "), x$n_fic, num(x$F_mw / 3600, 2),
                                                    num(x$h_mw, 2), num(x$h_ln, 2), num(x$duree, 2),
                                                    if (is.na(x$duree)) "\u2014" else if (x$duree <= BUDGET_H_297) "oui" else "non",
                                                    num(x$borne, 2), if (is.na(x$borne)) "\u2014" else if (x$borne <= BUDGET_H_297) "oui" else "non"), ""), "",
                   sprintf(paste("Dur\u00e9e d'une tranche Merz-W\u00fcthrich au pr\u00e9-vol (%d triangles \u00e0 la dur\u00e9e mesur\u00e9e \u00e0 4 processus,",
                                 "contr\u00f4les compris) : %s h. Borne = dur\u00e9e planifi\u00e9e + 0,75 \u00d7 cette dur\u00e9e : borne d'ordonnancement en liste,",
                                 "hypoth\u00e8se [H] ; la r\u00e8gle de choix du niveau (par. 5.2) porte sur la dur\u00e9e planifi\u00e9e."), TAILLE_SEULE, num(h_tranche, 2)), "",
                   if (is.null(LN)) "Niveau non d\u00e9termin\u00e9 (--prevol-ln requis)." else if (is.null(ret))
                     sprintf("**Aucun niveau ne tient en %d h : sous L4, d\u00e9cision du mainteneur (par. 5.2).**", BUDGET_H_297) else
                     sprintf("**Niveau retenu : %s** (%s) ; dur\u00e9e planifi\u00e9e %s h d'horloge sur 4 processus.", ret$niv, LIB_NIVEAUX_297[[ret$niv]], num(ret$duree, 2)), ""))
  if (!is.null(ret)) ecrire_console(c("### Lignes \u00e0 reporter au JOURNAL", "", "```",
                                      sprintf("- Niveau : %s", ret$niv),
                                      sprintf("- D\u00e9bit : MW c_b = %s s, P_k = %s ; LN c_J1 = %s s, c_J2 = %s s, P_k = %s ; dur\u00e9e planifi\u00e9e %s h \u00e0 4 processus (pr\u00e9-vol du %s, commit %s)",
                                              num(c_b, 2), paste(vapply(P_k, num, "", d = 3), collapse = " / "), num(LN$c_J1, 2), num(LN$c_J2, 2),
                                              paste(vapply(LN$P, num, "", d = 3), collapse = " / "), num(ret$duree, 2),
                                              format(Sys.time(), "%Y-%m-%d", tz = "UTC"), substr(COMMIT, 1, 7)),
                                      sprintf("- Borne d'ordonnancement : dur\u00e9e planifi\u00e9e + 0,75 \u00d7 dur\u00e9e d'une tranche MW (%s h) = %s h, %s %d h (borne d'ordonnancement en liste, hypoth\u00e8se [H])",
                                              num(h_tranche, 2), num(ret$borne, 2), if (ret$borne <= BUDGET_H_297) "sous le plafond de" else "AU-DEL\u00c0 du plafond de", BUDGET_H_297),
                                      sprintf("- Commit : %s", sub(" .*$", "", COMMIT)),
                                      sprintf("- Empreinte sans commentaires : %s", EMPREINTE_SC), "```", "",
                                      sprintf("### Plan des tranches du niveau %s (format de tests/outillage/lancer_tranches.sh)", ret$niv), "", "```",
                                      plan_tranches_297(ret$niv), "```"))
  quit(status = 0L)
}
if (MODE == "prevol") {
  ecrire_console(c("## Pr\u00e9-vol de la mesure #206 (rien d'\u00e9crit)", "",
                   sprintf("Commit : %s ; plateforme : %s ; c\u0153urs (parallel::detectCores()) : %s ; d\u00e9but %s UTC", COMMIT, plateforme_calcul(),
                           tryCatch(parallel::detectCores(), error = function(e) "?"), format(Sys.time(), "%Y-%m-%dT%H:%M:%S", tz = "UTC")), ""))
  # 1. Motifs de refus des triangles des trois lois (R maximal du par. 8).
  L <- c("### Triangles des trois lois : admission (motifs de refus)", "", entete_md(c("Loi", "triangles", "refus\u00e9s", "motifs", "s par triangle")))
  for (l in LOIS) {
    Rl <- max(vapply(NIVEAUX, function(R) R[[paste0(l, "_red")]], 1))
    t0 <- Sys.time()
    mo <- vapply(seq_len(Rl), function(b) admettre(engine_sous_graine(graine_tri(l, b), gen_triangle_h0(AJ0, tireur(l))))$motif, "")
    d <- secondes(t0)
    rf <- !is.na(mo)
    L <- c(L, ligne_md(l, Rl, sum(rf), if (any(rf)) { t <- table(mo[rf]); paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") } else "aucun",
                       num(d / Rl, 4)))
  }
  ecrire_console(c(L, ""))
  # 2. Couts unitaires : triangle oracle, triangle de la sous-mesure N,
  # controles legers.
  t0 <- Sys.time(); invisible(lapply(seq_len(50), function(k) traiter_oracle("N", k))); t_or <- secondes(t0) / 50
  invisible(mw_tests(AJ0, mw_bootstrap(AJ0, B = 20L, seed = GRAINE_R2), ALPHA))   # cache de Shapiro-Wilk
  t0 <- Sys.time(); invisible(traiter_sm(1L)); c_sm <- secondes(t0)
  t0 <- Sys.time(); invisible(controle_g()); invisible(controle_i4()); invisible(controle_graines())
  invisible(empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))); c_gen <- secondes(t0)
  # 3. Debit a 1, 2, 3 et 4 processus concurrents (--prevol-unite).
  CB <- mesurer_debit()
  c_b <- mean(CB[[1]])
  P_k <- vapply(1:4, function(k) k * c_b / mean(CB[[k]]), 1)
  k_ret <- which.max(P_k); P <- P_k[k_ret]
  ecrire_console(c("### D\u00e9bit (par. 8)", "",
                   sprintf("c_b (mw_bootstrap() \u00e0 B = 999 + mw_tests() + r\u00e9gressions de #119, un processus, %d unit\u00e9(s)) : %s s ; triangle oracle : %s s ; triangle de la sous-mesure N : %s s ; contr\u00f4les l\u00e9gers ((g), (i4), (graines), (i3)) : %s s.",
                           length(CB[[1]]), num(c_b, 2), num(t_or, 4), num(c_sm, 1), num(c_gen, 1)), "",
                   entete_md(c("processus concurrents", "dur\u00e9e par unit\u00e9 (s) : moyenne [min ; max]", "d\u00e9bit agr\u00e9g\u00e9 P_k = k c_b / moyenne")),
                   vapply(1:4, function(k) ligne_md(k, sprintf("%s [%s ; %s]", num(mean(CB[[k]]), 2), num(min(CB[[k]]), 2), num(max(CB[[k]]), 2)), num(P_k[k], 3)), ""),
                   "", sprintf("Retenu : %d processus, P = %s.", k_ret, num(P, 3)), ""))
  # 4. Niveaux : F, N_max, duree planifiee ; premier niveau tenu en 20 h.
  # F (s CPU) : oracles (N0 x triangle oracle par loi), sous-mesure N (500
  # triangles + controle (s), environ deux c_b), controles des sorties
  # ((a) : un c_b ; tranches : en plus (i1)/(i2) sur reserve2, trois c_b,
  # et sur le premier triangle, un c_b par pool ; controles legers).
  niv <- lapply(NIVEAUX_NOMS, function(nv) {
    pl <- plan_tranches(nv); ar <- sub("^[^\t]*\t", "", pl)
    n_tr <- sum(grepl("^--loi", ar)); n_par <- sum(grepl("redresse,brut", ar, fixed = TRUE))
    n_ora <- sum(grepl("^--oracle", ar)); n_sm <- sum(grepl("^--sous-mesure-N", ar))
    F <- n_ora * N0_SPEC * t_or + R_SM_SPEC * c_sm + 2 * c_b + n_tr * (5 * c_b + c_gen) + n_par * c_b + (n_ora + n_sm) * (c_b + c_gen)
    N <- BOOTSTRAPS_SPEC[[nv]]
    list(niv = nv, N = N, F = F, n_fic = length(pl), duree = (N * c_b + F) / (P * 3600), N_max = (BUDGET_H * 3600 * P - F) / c_b)
  })
  ok <- vapply(niv, function(x) x$N <= x$N_max, logical(1))
  ret <- if (any(ok)) niv[[which(ok)[1]]] else NULL
  ecrire_console(c("### \u00c9chelle de r\u00e9duction (par. 8) : N_max = (20 h \u00d7 P \u00d7 3 600 \u2212 F) / c_b", "",
                   entete_md(c("Niveau", "changement", "bootstraps", "sorties (plan)", "F (h CPU)", "N_max", "dur\u00e9e planifi\u00e9e (h d'horloge)", "tient en 20 h")),
                   vapply(niv, function(x) ligne_md(x$niv, LIB_NIVEAUX[[x$niv]], x$N, x$n_fic, num(x$F / 3600, 2), sprintf("%.0f", x$N_max), num(x$duree, 2),
                                                    if (x$N <= x$N_max) "oui" else "non"), ""), "",
                   if (is.null(ret)) "**Aucun niveau ne tient en 20 h : sous L5, B2 n'est pas d\u00e9l\u00e9gable (retour au mainteneur, option (C) de Q-206-2 ou budget prolong\u00e9).**" else
                     sprintf("**Niveau retenu : %s** (%s) ; %d bootstraps ; F = %s h CPU ; N_max = %.0f ; dur\u00e9e planifi\u00e9e %s h d'horloge sur %d processus.",
                             ret$niv, LIB_NIVEAUX[[ret$niv]], ret$N, num(ret$F / 3600, 2), ret$N_max, num(ret$duree, 2), k_ret), ""))
  if (!is.null(ret)) ecrire_console(c("### Lignes \u00e0 reporter au JOURNAL", "", "```",
                                      sprintf("- Niveau : %s", ret$niv),
                                      sprintf("- D\u00e9bit : c_b = %s s ; P = %s (%d processus ; P_k = %s) ; F = %s h CPU ; N_max = %.0f ; dur\u00e9e planifi\u00e9e %s h (pr\u00e9-vol du %s, commit %s)",
                                              num(c_b, 2), num(P, 3), k_ret, paste(vapply(P_k, num, "", d = 3), collapse = " / "), num(ret$F / 3600, 2), ret$N_max,
                                              num(ret$duree, 2), format(Sys.time(), "%Y-%m-%d", tz = "UTC"), substr(COMMIT, 1, 7)),
                                      sprintf("- Empreinte sans commentaires : %s", EMPREINTE_SC), "```", "",
                                      sprintf("### Plan des tranches du niveau %s (format de tests/outillage/lancer_tranches.sh)", ret$niv), "", "```",
                                      plan_tranches(ret$niv), "```"))
  quit(status = 0L)
}

###############################################################################
#  SORTIES DE CALCUL : tranche, oracle, sous-mesure N
###############################################################################
# (t) texte du critere
controle(present_bloc(TEXTE_CRITERE_206) && TITRE_B1 %in% TXT_SPEC,
         sprintf("(t) texte du crit\u00e8re (par. 5, %d lignes) identique \u00e0 %s (md5 %s) ; titre de l'annotation B1 du 10/10/2026 pr\u00e9sent",
                 length(TEXTE_CRITERE_206), SPEC, md5_fichier(file.path(RACINE, SPEC))))
# (t297) texte du critere de Fk (#297) ; (fr) ensemble "a la frontiere" lu
# dans la reference (specification de Fk, par. 5.4).
controle(present_bloc(TEXTE_CRITERE_FK, TXT_SPEC_FK),
         sprintf("(t297) texte du crit\u00e8re de Fk (par. 5.3, K-F1 \u00e0 K-F4, profils \u03a60 \u00e0 \u03a65, %d lignes) identique \u00e0 %s (md5 %s)",
                 length(TEXTE_CRITERE_FK), SPEC_FK, md5_fichier(file.path(RACINE, SPEC_FK))))
FR0 <- frontiere_reference()
controle(FR0$ok, paste("(fr)", FR0$txt))
# (b) catalogue
controle(NS == 13L && setequal(CLES, names(SENS_SPEC)) && identical(unname(QUEUE[names(SENS_SPEC)]), unname(SENS_SPEC)),
         sprintf("(b) %d cl\u00e9s lues dans MW_CATALOGUE_MC (%s), sens conformes \u00e0 ceux de ce moteur (Calendrier : bas depuis #276 ; MinP4 \u00e0 la place de Grubbs depuis #300)", NS,
                 paste(sprintf("%s %s", CLES, QUEUE), collapse = ", ")))
# (a) reserve2 contre la reference
RES_A <- executer_cas("reserve2")
cmp_a <- comparer_objets(neutraliser_instables(readRDS(chemin_reference("reserve2"))), neutraliser_instables(RES_A), tol = TOLERANCE)
TXT_A <- sprintf("%s ; %d feuille(s), %d non strictement identique(s), \u00e9cart maximal %s", if (cmp_a$conforme) "conforme" else "NON CONFORME",
                 cmp_a$n_feuilles, cmp_a$n_differentes, formatC(cmp_a$ecart_max, format = "e", digits = 3))
controle(cmp_a$conforme && identical(unlist(RES_A$metadata[c("B", "alpha", "seed")]), c(B = as.numeric(B_BOOT), alpha = ALPHA, seed = GRAINE_R2)),
         sprintf("(a) reserve2, run_engine(seed = %.0f), conforme \u00e0 tests/reference/reserve2.rds (comparer_objets(), tol\u00e9rance %g) ; B, \u03b1 et graine = ceux du script : %s",
                 GRAINE_R2, TOLERANCE, TXT_A))
# (b) correspondance ligne <-> cle sur reserve2 (p_mc de la ligne = p_mc[cle])
# Libelles distincts : lignes de lecture conjointe suivies de leur cle de
# famille (libelle_ligne(), #297) ; correspondance cle -> ligne cherchee hors
# de ces lignes (leur p_mc est une p de famille, non une p du catalogue).
LIGNES <- vapply(RES_A$tests, libelle_ligne, "")
CLE_LIGNE <- vapply(CLES, function(s) {
  k <- which(vapply(RES_A$tests, function(x) !identical(fk_champ(x, "fonction"), "engine_p_famille") &&
                      identical(x$p_mc, unname(RES_A$bootstrap$p_mc[[s]])), logical(1)))
  if (length(k) == 1L) k else NA_integer_
}, 1L)
controle(length(LIGNES) == NL_MAX && !anyDuplicated(LIGNES) && !anyNA(CLE_LIGNE) && !anyDuplicated(CLE_LIGNE) &&
           !anyDuplicated(unname(RES_A$bootstrap$p_mc)),
         sprintf("(b) %d lignes de mw_tests() sur reserve2, libell\u00e9s distincts ; 13 p_mc distinctes ; chaque cl\u00e9 port\u00e9e par une ligne et une seule (p_mc de la ligne = p_mc[cl\u00e9]) : %s",
                 length(LIGNES), paste(sprintf("%s \u2192 %s", CLES, CLE_LIGNE), collapse = ", ")))
TXT_LIGNES <- paste(LIGNES, collapse = " ; ")
TXT_CLE_LIGNE <- paste(sprintf("%s=%d", CLES, CLE_LIGNE), collapse = " ; ")
# (g), (i4), (graines), (i3)
cg <- controle_g(); controle(cg$ok, paste("(g)", cg$txt))
ci4 <- controle_i4(); controle(ci4$ok, paste("(i4)", ci4$txt))
cgr <- controle_graines(); controle(cgr$ok, paste("(graines)", cgr$txt))
TXT_I3 <- sprintf("empreinte sans commentaires de R/engine.R %s ; md5 de R/engine.R %s, de %s %s, de tests/outils_tests.R %s",
                  EMPREINTE_SC, MD5_MOTEUR, SCRIPT, md5_fichier(FICHIER_SCRIPT), md5_fichier(file.path(DOSSIER_SCRIPT, "outils_tests.R")))
controle(grepl("^[0-9a-f]{32}$", EMPREINTE_SC), paste("(i3)", TXT_I3))
# (i1), (i2) sur reserve2 (tranches) : chemin du script = run_engine(),
# pour le pool redresse (RES_A) et pour le pool brut (injection active).
# Volet stats_obs : jd et jni passes, jno (#273) par le defaut de
# .mw_ensembles_figes(), soit .mw_colonnes_origine_non_identifiables(aj, jd).
if (MODE == "tranche") {
  aj_r2 <- RES_A$ajustement; jd_r2 <- .mw_colonnes_degenerees(aj_r2)
  jni_r2 <- .mw_colonnes_courbure_non_identifiables(aj_r2, jd_r2)
  b_r2 <- mw_bootstrap(aj_r2, B = B_BOOT, seed = GRAINE_R2); t_r2 <- mw_tests(aj_r2, b_r2, ALPHA)
  i1_r2 <- identical(RES_A$bootstrap$stats_obs, as.list(.mw_stats(aj_r2, .mw_ensembles_figes(aj_r2, jd_r2, jni_r2)))) && identical(as.list(stats_oracle(aj_r2)), RES_A$bootstrap$stats_obs)
  controle(i1_r2, "(i1) reserve2 : bootstrap$stats_obs de run_engine() identique (identical()) \u00e0 .mw_stats(aj, .mw_ensembles_figes(aj, jd, jni)) recalcul\u00e9 (ensembles fig\u00e9s \u00e0 l'observ\u00e9 : jd et jni pass\u00e9s, #270 ; jno, colonnes non identifiables de l'ordonn\u00e9e \u00e0 l'origine, par le d\u00e9faut de .mw_ensembles_figes(), #273) et au chemin oracle stats_oracle() (jd pass\u00e9, jni et jno par le d\u00e9faut de .mw_ensembles_figes(), m\u00eames fonctions que mw_bootstrap() : d\u00e9finition de la loi oracle, pas un recalcul ind\u00e9pendant de jni ni de jno)")
  if (identical(OPT_POOLS, "redresse,brut")) {
    re_b <- avec_pool_brut(run_engine(methode = METHODE, triangle = .tri, segment = SEGMENT, annexe = ANNEXE, seed = GRAINE_R2))
    b_r2b <- avec_pool_brut(mw_bootstrap(aj_r2, B = B_BOOT, seed = GRAINE_R2)); t_r2b <- mw_tests(aj_r2, b_r2b, ALPHA)
    i2b <- identical(re_b$tests, t_r2b) && identical(re_b$bootstrap, b_r2b) && pool_restaure()
  } else i2b <- NA
  controle(identical(RES_A$tests, t_r2) && identical(RES_A$bootstrap, b_r2) && !isFALSE(i2b),
           sprintf("(i2) reserve2 : $tests et $bootstrap de run_engine() identiques (identical()) au chemin du script mw_bootstrap() + mw_tests(), pool redress\u00e9%s",
                   if (is.na(i2b)) " (pool brut : tranche sans pool brut)" else " et pool brut (injection active, restauration v\u00e9rifi\u00e9e)"))
}
t_ctrl <- secondes(t_debut)

# --- En-tete machine (ecrit AVANT les donnees) --------------------------------
if (MODE == "oracle") { DEBUT <- 1L; FIN <- N0 } else { DEBUT <- B1; FIN <- B2 }
LOI <- if (MODE == "sm") "N" else OPT_LOI
PAR <- switch(MODE,
  tranche = sprintf("mode=tranche;loi=%s;B=%d;alpha=%g;graine_tri=%.0f+%.0f(l-1)+b;graine_boot=%.0f+%.0f(l-1)+b;methode=%s;segment=%d;annexe=%s",
                    LOI, B_BOOT, ALPHA, GRAINE_TRI, PAS_LOI, GRAINE_BOOT, PAS_LOI, METHODE, SEGMENT, ANNEXE),
  oracle = sprintf("mode=oracle;loi=%s;N0=%d;graine_oracle=%.0f+%.0f(l-1)+k;methode=%s", LOI, N0, GRAINE_ORA, PAS_LOI_ORA, METHODE),
  sm = sprintf("mode=sm;loi=N;B=%d;graine_tri=%.0f+%.0f(l-1)+b;graine_boot=%.0f+%.0f(l-1)+b;methode=%s;b_max=%d", B_BOOT, GRAINE_TRI, PAS_LOI,
               GRAINE_BOOT, PAS_LOI, METHODE, R_SM_SPEC))
CTX <- c(mode = MODE, loi = LOI, dgp = TXT_DGP, configuration = TXT_CONFIG, graines = TXT_GRAINES, collisions = cgr$txt,
         generateur = paste(ENGINE_RNG_KIND, collapse = ", "), commit = COMMIT, plateforme = plateforme_calcul(), empreintes = EMPREINTES,
         empreinte_sc = sprintf("%s (md5 du fichier entier %s)", EMPREINTE_SC, MD5_MOTEUR), reference = TXT_A, lignes = TXT_LIGNES,
         cle_ligne = TXT_CLE_LIGNE, essai = if (OPT_ESSAI) "oui" else "non", locale = sprintf("%s \u2192 %s", LOCALE_ORIGINE, LOCALE_TRAVAIL))
stopifnot(identical(names(CTX), CLES_CONTEXTE))
ENTETE <- utf8(c(paste0("PARAMETRES\t", PAR), sprintf("TRANCHE\t%d\t%d\t%s", DEBUT, FIN, if (MODE == "tranche") OPT_POOLS else "-"),
                 sprintf("CONTEXTE\t%s\t%s", names(CTX), vapply(CTX, nettoyer_champ, "")),
                 paste0("CLES\t", paste(sprintf("%s=%s", CLES, QUEUE), collapse = "\t")),
                 paste0("COLS\t", paste(COLS[[MODE]], collapse = "\t"))))

# --- Reprise d'une sortie partielle (--reprendre) ------------------------------
# Lignes reprises recalculees d'office (M1 de l'audit de #206) : une ligne
# tronquee au milieu d'un champ garde le bon nombre de champs ; elle est
# ecartee si le fichier ne finit pas par un saut de ligne, et la derniere
# ligne reprise, plus un echantillon regulier de lignes reprises (mode
# oracle et, depuis #248 (constat m1), mode tranche : une ligne interieure
# alteree n'etait pas recalculee), sont recalculees et comparees hors
# durees. Echantillon regulier : N lignes d'indices regulierement espaces
# dans les lignes reprises triees, la premiere et la derniere comprises.
# Mode sm : aucun echantillon (cout d'un triangle de la sous-mesure).
N_ECH_REPRISE_ORACLE <- 50L
N_ECH_REPRISE_TRANCHE <- 10L
N_ECH_REPRISE <- c(tranche = N_ECH_REPRISE_TRANCHE, oracle = N_ECH_REPRISE_ORACLE, sm = 0L)
lignes_recalcul_reprise <- function(b_ok, mode) {
  if (!length(b_ok)) return(integer(0))
  bo <- sort(b_ok); n <- min(N_ECH_REPRISE[[mode]], length(bo))
  ech <- if (n > 0L) bo[unique(round(seq(1, length(bo), length.out = n)))] else integer(0)
  unique(c(b_ok[length(b_ok)], ech))
}
REPRIS <- list(); N_IGNOREES <- 0L; N_NON_TERMINEE <- 0L; TXT_REPRISE <- NULL; B_RECALC_FORCE <- integer(0)
if (!is.na(OPT_REPRENDRE)) {
  la <- readLines(OPT_REPRENDRE, warn = FALSE, encoding = "UTF-8")
  taille_a <- file.size(OPT_REPRENDRE)
  octet_fin <- if (taille_a > 0) readBin(OPT_REPRENDRE, "raw", n = taille_a)[taille_a] else raw(0)
  if (length(la) && !identical(octet_fin, as.raw(10L))) { la <- la[-length(la)]; N_NON_TERMINEE <- 1L }
  en_a <- la[grepl("^(PARAMETRES|TRANCHE|CONTEXTE|CLES|COLS)\t", la)]
  if (!identical(en_a, ENTETE)) {
    diff_c <- unique(sub("^CONTEXTE\t([^\t]*)\t.*$", "\\1", grep("^CONTEXTE\t", c(setdiff(en_a, ENTETE), setdiff(ENTETE, en_a)), value = TRUE)))
    message("--reprendre : REFUS -- en-tete de la sortie partielle different de celui de cette execution",
            if (length(diff_c)) paste0(" (CONTEXTE : ", paste(diff_c, collapse = ", "), ")") else "")
    quit(status = 1L)
  }
  if (any(startsWith(la, "FIN\t"))) { message("--reprendre : REFUS -- la sortie porte une ligne FIN : rien a reprendre"); quit(status = 1L) }
  rp <- strsplit(sub(paste0("^", ETQ[[MODE]], "\t"), "", la[startsWith(la, paste0(ETQ[[MODE]], "\t"))]), "\t", fixed = TRUE)
  bs <- suppressWarnings(as.integer(vapply(rp, `[`, "", 1L)))
  ok <- lengths(rp) == length(COLS[[MODE]]) & !is.na(bs) & bs >= DEBUT & bs <= FIN &
    vapply(rp, function(x) length(x) >= 2L && x[2] %in% c("admis", "refuse"), logical(1))
  if (anyDuplicated(bs[ok])) { message("--reprendre : REFUS -- lignes en double"); quit(status = 1L) }
  REPRIS <- stats::setNames(rp[ok], bs[ok]); N_IGNOREES <- sum(!ok) + N_NON_TERMINEE
  B_RECALC_FORCE <- lignes_recalcul_reprise(bs[ok], MODE)
  TXT_REPRISE <- c(basename(OPT_REPRENDRE), md5_fichier(OPT_REPRENDRE))
}

# --- Donnees -------------------------------------------------------------------
CON <- if (is.na(OPT_SORTIE_TR)) stdout() else file(OPT_SORTIE_TR, open = "wb")
emettre <- function(x) { writeLines(utf8(x), CON, useBytes = TRUE); flush(CON) }
emettre(ENTETE)
DATA <- list(); ERREURS <- character(0); ECH <- NA_integer_
N_REPRIS <- 0L; N_RECALC <- 0L; ECH_REPRISE <- character(0)
I1 <- I2 <- S_CTL <- NULL; I4_ECH <- character(0); D_ECH <- character(0); B_ECH <- character(0)
KF3 <- NULL; F_ECH <- character(0)
hors_duree <- function(mode) !grepl("^dur", COLS[[mode]]) & COLS[[mode]] != "duree"
for (b in seq.int(DEBUT, FIN)) {
  ch_old <- REPRIS[[as.character(b)]]
  echant <- MODE != "oracle" && is.na(ECH)
  if (!is.null(ch_old) && !(echant && identical(ch_old[2], "admis")) && !(b %in% B_RECALC_FORCE)) {
    ch <- ch_old; N_REPRIS <- N_REPRIS + 1L
  } else {
    t_r <- Sys.time()
    res <- tryCatch(switch(MODE,
      tranche = { r <- traiter_triangle(LOI, b, identical(OPT_POOLS, "redresse,brut"), ctl = echant); list(r = r, ch = champs_tranche(b, r)) },
      sm = { r <- traiter_sm(b, ctl = echant); list(r = r, ch = champs_sm(b, r)) },
      oracle = list(r = NULL, ch = traiter_oracle(LOI, b))), error = function(e) e)
    if (inherits(res, "error")) {
      ch <- champs_erreur(MODE, b, conditionMessage(res), secondes(t_r)); ERREURS <- c(ERREURS, sprintf("%d : %s", b, ch[3]))
    } else {
      ch <- res$ch; r <- res$r
      if (!is.null(r) && identical(r$statut, "admis")) {
        if (echant) {
          ECH <- b
          if (MODE == "tranche") { I1 <- r$i1; I2 <- r$i2; KF3 <- r$kf3 } else S_CTL <- r$s
        }
        if (MODE == "tranche") {
          if (length(r$i4)) I4_ECH <- c(I4_ECH, sprintf("%d (%s)", b, paste(r$i4, collapse = ", ")))
          okb <- identical(names(r$bR$p_mc), CLES) && identical(names(r$bR$motif_mc), CLES) && all(code_motif(r$bR$motif_mc) != "?") &&
            (is.null(r$bB) || (identical(names(r$bB$p_mc), CLES) && all(code_motif(r$bB$motif_mc) != "?")))
          if (!okb) B_ECH <- c(B_ECH, as.character(b))
          okd <- all(vapply(CLES, function(s) sur_grille(r$bR$p_mc[[s]], r$bR$B_effectif[[s]], QUEUE[[s]]) &&
                              (is.null(r$bB) || sur_grille(r$bB$p_mc[[s]], r$bB$B_effectif[[s]], QUEUE[[s]])), logical(1)))
          if (!okd) D_ECH <- c(D_ECH, as.character(b))
          if (!fk_etats_ok(r$fam))
            F_ECH <- c(F_ECH, sprintf("%d (%s%s)", b, paste(sprintf("%s %s", names(r$fam$f), vapply(r$fam$f, `[[`, "", "etat")), collapse = ", "),
                                      if (length(r$fam$inconnues)) paste0(" ; familles inconnues ", paste(r$fam$inconnues, collapse = ", ")) else ""))
        }
      }
      if (!is.null(ch_old)) {
        N_RECALC <- N_RECALC + 1L
        k <- hors_duree(MODE)
        if (!identical(unname(ch[k]), unname(ch_old[k]))) ECH_REPRISE <- c(ECH_REPRISE, as.character(b))
      }
    }
  }
  DATA[[length(DATA) + 1L]] <- ch
  emettre(paste0(ETQ[[MODE]], "\t", paste(ch, collapse = "\t")))
}

# --- Controles de la sortie ----------------------------------------------------
D <- en_table(DATA, COLS[[MODE]])
n_adm <- sum(D$statut == "admis"); n_ref <- sum(D$statut == "refuse"); n_err <- sum(D$statut == "erreur")
if (MODE == "tranche") {
  controle(!is.null(I1) && all(I1), sprintf("(i1) premier triangle admis de la tranche (b = %s) : boot$stats_obs identique (identical()) \u00e0 .mw_stats(aj_b, .mw_ensembles_figes(aj_b, jd_b, jni_b, jno_b)) recalcul\u00e9 (ensembles fig\u00e9s \u00e0 l'observ\u00e9, tous trois pass\u00e9s : jd, jni de la courbure, #270, jno de l'ordonn\u00e9e \u00e0 l'origine, #273) et au chemin oracle stats_oracle() (jd pass\u00e9, jni et jno par le d\u00e9faut de .mw_ensembles_figes(), m\u00eames fonctions que mw_bootstrap() : d\u00e9finition de la loi oracle, pas un recalcul ind\u00e9pendant de jni ni de jno)%s",
                                            ECH, if (is.null(I1)) " (aucun triangle admis calcul\u00e9)" else if (all(I1)) "" else paste0(" ; diff\u00e9rences : ", paste(names(I1)[!I1], collapse = ", "))))
  controle(!is.null(I2) && all(I2), sprintf("(i2) premier triangle admis (b = %s) : $tests et $bootstrap de run_engine(methode = \"reserve2\", triangle = tri_b, segment = 1, annexe = \"II\", seed = S(\u2113, b)) identiques au chemin du script (%s)",
                                            ECH, if (is.null(I2)) "aucun triangle admis calcul\u00e9" else paste(sprintf("%s %s", names(I2), ifelse(I2, "oui", "NON")), collapse = ", ")))
  controle(!length(I4_ECH), sprintf("(i4) restauration de .mw_pool_residus apr\u00e8s chaque appel inject\u00e9 et longueurs des deux pools \u00e9gales, \u00e0 chaque triangle calcul\u00e9 du pool brut%s",
                                    if (length(I4_ECH)) paste0(" : \u00e9checs ", paste(I4_ECH, collapse = " ; ")) else ""))
  controle(!length(B_ECH), sprintf("(b) noms des p = 13 cl\u00e9s du catalogue, dans son ordre, et motifs d'absence connus, \u00e0 chaque triangle calcul\u00e9%s", if (length(B_ECH)) paste0(" : \u00e9checs ", liste_cel(B_ECH, 20)) else ""))
  controle(!length(F_ECH), sprintf(paste("(k) lignes de lecture conjointe (#297) de chaque triangle calcul\u00e9 (pool redress\u00e9, cl\u00e9s %s) :",
                                         "\u00e9tats L, N ou A seulement, coh\u00e9rents avec k et le B effectif de famille recompt\u00e9s par le script",
                                         "(\u00e9tat S : bootstrap$stats_boot absent, jamais confondu avec une ligne absente pour k \u2264 1)%s"),
                                   paste(FAM_MW, collapse = ", "), if (length(F_ECH)) paste0(" : \u00e9checs ", liste_cel(F_ECH, 10)) else ""))
  controle(!is.null(KF3) && isTRUE(KF3$ok),
           sprintf(paste("(K-F3) premier triangle admis de la tranche (b = %s) : p de famille, m_obs, err_mc et k recalcul\u00e9s dans le script",
                         "(fk_recalcul(), R de base, \u00e9criture ind\u00e9pendante d'engine_p_famille()) depuis bootstrap$stats_boot,",
                         "stats_obs, le catalogue et les lignes, identiques (identical()) aux champs des lignes : %s"),
                   ECH, if (is.null(KF3)) "aucun triangle admis calcul\u00e9" else KF3$txt))
  e_inv <- invariants_sortie(list(mode = "tranche", donnees = DATA, debut = DEBUT, fin = FIN, pools = OPT_POOLS, familles = TRUE))
  controle(!length(D_ECH) && !length(e_inv[!grepl("statut inconnu", e_inv)]),
           sprintf("(d) B_eff \u2264 999 et p sur la grille k/(B_eff + 1) (\u00d7 2 en bilat\u00e9ral, plafonn\u00e9e \u00e0 1), sur les objets et sur les champs de chaque ligne REP ; p des r\u00e9gressions de #119, p asymptotiques et exactes dans [0, 1] (#248) ; admis + refus\u00e9s + en erreur = %d%s",
                   FIN - DEBUT + 1L, if (length(c(D_ECH, e_inv))) paste0(" : ", paste(c(D_ECH, e_inv), collapse = " ; ")) else ""))
}
if (MODE == "sm") {
  controle(!is.null(S_CTL) && all(S_CTL), sprintf("(s) premier triangle admis (b = %s) : les 999 triangles bootstrap r\u00e9g\u00e9n\u00e9r\u00e9s par .mw_tirer_triangle_valide() (retirage et plafond de mw_bootstrap(), #257, #271 ; retirage non exerc\u00e9 sous le pool r\u00e9el, arr\u00eat au premier cumul invalide et identit\u00e9 de .mw_tirer_triangle_valide() v\u00e9rifi\u00e9s par (g)) sous S(N, b) redonnent par .mw_stats() (jd, jni et jno fig\u00e9s \u00e0 l'observ\u00e9, #270, #273) les p_mc et B effectifs de mw_bootstrap() (identical()) : %s",
                                                  ECH, if (is.null(S_CTL)) "aucun triangle admis calcul\u00e9" else paste(sprintf("%s %s", names(S_CTL), ifelse(S_CTL, "oui", "NON")), collapse = ", ")))
  e_inv <- invariants_sortie(list(mode = "sm", donnees = DATA, debut = DEBUT, fin = FIN, pools = "-"))
  controle(!length(e_inv[!grepl("statut inconnu", e_inv)]), sprintf("(d) B_eff \u2264 999 et p dans [0, 1] (#248) sur chaque ligne SM ; admis + refus\u00e9s + en erreur = %d%s", FIN - DEBUT + 1L,
                                                                    if (length(e_inv)) paste0(" : ", paste(e_inv, collapse = " ; ")) else ""))
}
if (MODE == "oracle") {
  e_inv <- invariants_sortie(list(mode = "oracle", donnees = DATA, debut = DEBUT, fin = FIN, pools = "-"))
  controle(!length(e_inv[!grepl("statut inconnu", e_inv)]), sprintf("(d) lignes ORA : k = 1..%d, une fois chacune%s", N0, if (length(e_inv)) paste0(" : ", paste(e_inv, collapse = " ; ")) else ""))
}
if (!is.null(TXT_REPRISE))
  controle(!length(ECH_REPRISE), sprintf("(reprise) %s (md5 %s) : en-t\u00eate identique ; %d ligne(s) reprise(s) telle(s) quelle(s), %d recalcul\u00e9e(s) (\u00e9chantillon des contr\u00f4les, derni\u00e8re ligne reprise%s) et identique(s) hors dur\u00e9es, %d ligne(s) illisible(s), tronqu\u00e9e(s) ou en erreur ignor\u00e9e(s), dont %d derni\u00e8re ligne non termin\u00e9e par un saut de ligne \u00e9cart\u00e9e%s",
                                         TXT_REPRISE[1], TXT_REPRISE[2], N_REPRIS, N_RECALC - length(ECH_REPRISE),
                                         if (N_ECH_REPRISE[[MODE]] > 0L) sprintf(", \u00e9chantillon r\u00e9gulier d'au plus %d lignes", N_ECH_REPRISE[[MODE]]) else "",
                                         N_IGNOREES, N_NON_TERMINEE,
                                         if (length(ECH_REPRISE)) paste0(" ; diff\u00e9rentes : ", paste(ECH_REPRISE, collapse = ", ")) else ""))
if (length(ECH_REPRISE))
  message("--reprendre : ECHEC -- ligne(s) reprise(s) differente(s) de leur recalcul hors durees (b = ", paste(ECH_REPRISE, collapse = ", "),
          ") : sortie partielle corrompue, INTEGRITE ECHEC")
CONTROLES <- c(CONTROLES, sprintf("(erreurs) %d ligne(s) au statut erreur (non bloquant pour la sortie ; --combiner la refuse)%s", n_err,
                                  if (length(ERREURS)) paste0(" : ", paste(ERREURS, collapse = " ; ")) else ""))

# --- Markdown de la sortie -------------------------------------------------------
DUREE <- c(t_ctrl, secondes(t_debut))
titre <- switch(MODE, tranche = sprintf("tranche, loi %s, b = %d..%d, pools %s", LOI, DEBUT, FIN, OPT_POOLS),
                oracle = sprintf("oracle, loi %s, N0 = %d", LOI, N0), sm = sprintf("sous-mesure N, b = %d..%d", DEBUT, FIN))
S <- c(sprintf("## Mesure #206 : niveau r\u00e9el \u00e0 T = 8 des p-values Monte-Carlo de Merz-W\u00fcthrich -- %s", titre), "",
       sprintf("Param\u00e8tres : %s", PAR), "",
       "### T0 -- provenance", "", entete_md(c("Grandeur", "Valeur")),
       vapply(CLES_CONTEXTE, function(k) ligne_md(LIBELLES_CONTEXTE[[k]], nettoyer_champ(CTX[[k]])), ""),
       ligne_md("Triangles", sprintf("%d (admis %d, refus\u00e9s %d, en erreur %d) ; \u00e9chantillon des contr\u00f4les : %s", FIN - DEBUT + 1L, n_adm, n_ref, n_err,
                                     if (is.na(ECH)) "\u2014" else ECH)),
       if (!is.null(TXT_REPRISE)) ligne_md("Reprise (--reprendre)", sprintf("%s (md5 %s) : %d ligne(s) reprise(s), %d recalcul\u00e9e(s), %d ignor\u00e9e(s)",
                                                                          TXT_REPRISE[1], TXT_REPRISE[2], N_REPRIS, N_RECALC, N_IGNOREES)),
       ligne_md("Dur\u00e9e (s)", sprintf("contr\u00f4les g\u00e9n\u00e9raux %.0f ; total %.0f%s", DUREE[1], DUREE[2],
                                         if (MODE != "oracle" && n_adm) sprintf(" ; par triangle admis : moyenne %s", num(mean(D$duree[D$statut == "admis"]), 1)) else "")),
       ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", if (length(INTEGRITE)) "\u00c9CHEC" else "OK"), "",
       "Tableaux PARTIELS (une sortie, sans \u03c1 ni t\u00e9moins) : combiner les sorties par --combiner.", "")
if (OPT_ESSAI) S <- c(S, "**Essai (--essai) : non versionnable.**", "")
DSt <- list(tr = list(), ora = list(), sm = NULL, lignes = LIGNES, cle_ligne = CLE_LIGNE)
if (MODE == "tranche") { DSt$tr[[LOI]] <- D
  S <- c(S, tableau_t1(cellules_pool(DSt, list(), "redresse"), "### T1 (partiel) \u2014 pool redress\u00e9"),
         if (identical(OPT_POOLS, "redresse,brut")) tableau_t1(cellules_pool(DSt, list(), "brut"), "### T1 bis (partiel) \u2014 pool brut"), tableau_t5(DSt),
         tableau_fk1(cellules_fk(DSt)), tableau_fk2(DSt)) }
if (MODE == "oracle") { DSt$ora[[LOI]] <- D; S <- c(S, tableau_rho(lapply(DSt$ora, resume_oracle), DSt), tableau_t5(DSt)) }
if (MODE == "sm") { DSt$sm <- D; S <- c(S, tableau_t7(DSt)) }
S <- c(S, "### Contr\u00f4les d'int\u00e9grit\u00e9", "", paste("-", CONTROLES), "",
       sprintf("Bilan : %s", if (length(INTEGRITE)) sprintf("\u00c9CHEC (%d contr\u00f4le(s))", length(INTEGRITE)) else "OK"), "")
FIN_MACHINE <- c(paste0("DUREE\t", paste(sprintf("%.3f", DUREE), collapse = "\t")),
                 if (!is.na(ECH)) sprintf("ECHANTILLON\t%d", ECH),
                 if (!is.null(TXT_REPRISE)) sprintf("REPRISE\t%s\t%s\t%d\t%d\t%d", TXT_REPRISE[1], TXT_REPRISE[2], N_REPRIS, N_RECALC, N_IGNOREES),
                 if (MODE == "oracle") sprintf("MD5_VALEURS\t%s", md5_lignes(paste0(ETQ[[MODE]], "\t", vapply(DATA, paste, "", collapse = "\t")))),
                 paste0("INTEGRITE\t", if (length(INTEGRITE)) "ECHEC" else "OK"),
                 sprintf("NLIG\t%d", length(DATA)), sprintf("FIN\t%d", length(DATA)))
emettre(c("", S, FIN_MACHINE))
if (!is.na(OPT_SORTIE_TR)) {
  close(CON)
  ecrire_console(S)
  message("ecrit (sortie, md5 ", md5_fichier(OPT_SORTIE_TR), ") : ", basename(OPT_SORTIE_TR))
}
quit(status = if (length(INTEGRITE)) 1L else 0L)
