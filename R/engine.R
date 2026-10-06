###############################################################################
#  R/engine.R  --  MOTEUR DE CALCUL QUANTITATIF
#
#  Paramètres propres à l'entreprise (USP) - Solvabilité II
#  Règlement délégué (UE) 2015/35, articles 218-220 et annexe XVII
#  Méthodes "risque de prime" (section B) et "risque de réserve 1" (section C).
#
#  ARCHITECTURE
#  Ce fichier contient l'INTEGRALITE de la logique quantitative du projet :
#  preparation des donnees, controles de validite, estimation, statistiques de
#  test, p-values (exactes, asymptotiques, Monte-Carlo), bootstrap, jackknife,
#  profils de vraisemblance, calibration, parametre final, et les quantites
#  numeriques necessaires aux graphiques.
#
#  Il est utilisable SANS Shiny :
#      source("R/engine.R")
#      res <- run_engine(xt = ..., yt = ..., methode = "premium", segment = 1,
#                        nature_donnees = "brutes")   # ou "nettes" (issue #55)
#  Aucune dependance a input$/output$/reactive()/render*() n'y figure.
#  Dependances : R base + stats uniquement.
#
#  La couche Shiny ne doit contenir aucun calcul statistique ou actuariel.
#
#  NOTE SUR LA TAILLE D'ECHANTILLON
#  La profondeur d'interet du projet est T = 8. A cette taille, les lois
#  asymptotiques sont peu fiables. Le moteur calcule donc, pour chaque test et
#  lorsque c'est possible :
#    - une p-value EXACTE (loi combinatoire ou de permutation),
#    - une p-value ASYMPTOTIQUE (loi limite classique),
#    - une p-value MONTE-CARLO par bootstrap parametrique sous le modele ajuste.
#  Le champ `nature_p` de chaque test indique laquelle est retenue.
###############################################################################


## =============================================================================
## 0. PARAMÈTRES STANDARD ET FACTEURS DE CRÉDIBILITÉ
## =============================================================================

# SOURCE DES ECARTS-TYPES STANDARD (annexes II et XIV, issue #19)
# Version en vigueur : reglement delegue (UE) 2015/35 dans sa version
# consolidee du 14.11.2024 (fichier "TEXTE consolide_ 32015R0035 - FR -
# 14.11.2024.xhtml" a la racine du depot, qui fait foi). Les annexes II et XIV
# y portent le marqueur M6 : elles ont ete remplacees par le reglement delegue
# (UE) 2019/981 de la Commission du 8 mars 2019, JO L 161 du 18.6.2019, p. 1.
# Les valeurs de la version d'origine (JOUE L 12 du 17.1.2015, annexe II
# p. 230, annexe XIV p. 269) ont ete remplacees ici et ne sont pas conservees :
# neuf valeurs different (II-6, II-7, II-8 primes et reserve ; XIV-1 reserve,
# XIV-3 primes, XIV-4 reserve).
# LIMITE DE PERIMETRE : l'outil ne vaut que pour un calcul dont la date de
# reference est posterieure ou egale a la date d'application du reglement
# delegue (UE) 2019/981 (M6) : le sigma standard qui entre dans le melange de
# l'annexe XVII est celui en vigueur a la date de reference du calcul. Il ne
# permet pas de reproduire un calcul selon les valeurs de 2015.

# Ecarts-types standard de l'annexe II (non-vie), version consolidee, tableau
# sous le marqueur M6 de la ligne 36887 du xhtml (valeurs des segments 1 a 12
# aux lignes 36945 a 37135 ; segment 6 : l. 37030 / 37033, segment 7 :
# l. 37047 / 37050, segment 8 : l. 37064 / 37067). Dix-huit valeurs sur 24
# identiques a la version d'origine ; confrontation une a une par l'agent
# regulatory (issue #19).
ANNEXE_II <- data.frame(
  segment = 1:12,
  libelle = c(
    "RC automobile et reass. proportionnelle",
    "Autres assurances automobiles et reass. proportionnelle",
    "Maritime, aerien et transport et reass. proportionnelle",
    "Incendie et autres dommages aux biens et reass. proportionnelle",
    "RC generale et reass. proportionnelle",
    "Credit et cautionnement et reass. proportionnelle",
    "Protection juridique et reass. proportionnelle",
    "Assistance et reass. proportionnelle",
    "Pertes pecuniaires diverses et reass. proportionnelle",
    "Reass. non proportionnelle - accidents",
    "Reass. non proportionnelle - maritime, aerien, transport",
    "Reass. non proportionnelle - dommages aux biens"
  ),
  sigma_prime_brut = c(.10, .08, .15, .08, .14, .19, .083, .064, .13, .17, .17, .17),
  sigma_reserve    = c(.09, .08, .11, .10, .11, .172, .055, .22, .20, .20, .20, .20),
  # Facteur d'ajustement standard pour la reassurance non proportionnelle
  # (NP) : art. 117, paragraphe 3 (marqueur B, JOUE L 12/75), deuxieme
  # phrase ("Dans le cas des segments 1, 4 et 5 vises a l'annexe II, le
  # facteur d'ajustement pour la reassurance non proportionnelle est egal a
  # 80 %") et troisieme phrase ("Pour tous les autres segments vises a
  # l'annexe II, [...] est de 100 %"). Le renvoi aux segments 1, 4
  # et 5 reste exact apres le remplacement de l'annexe II par M6 (memes
  # intitules et lignes d'activite ; lecture de l'agent regulatory, issue #55).
  # Sert a la valeur standard du parametre a) i) de l'art. 218, paragraphe 1
  # (ecart type net = NP x ecart type brut), remplace sur donnees nettes
  # (usp_parametre_standard(), decision M13).
  np_standard      = c(.8, 1, 1, .8, .8, 1, 1, 1, 1, 1, 1, 1),
  stringsAsFactors = FALSE
)

# Ecarts-types standard de l'annexe XIV (sante non-SLT), version consolidee,
# tableau sous le marqueur M6 de la ligne 81342 du xhtml (valeurs aux lignes
# 81400 a 81454 ; segment 1 reserve : l. 81403, segment 3 primes : l. 81434,
# segment 4 reserve : l. 81454) ; cinq valeurs sur 8 identiques a la version
# d'origine. Voir la source commune ci-dessus. La colonne
# `lob` rappelle les lignes d'activite de l'annexe I dont se compose chaque
# segment.
ANNEXE_XIV <- data.frame(
  segment = 1:4,
  libelle = c(
    "Frais medicaux et reass. proportionnelle",
    "Protection du revenu et reass. proportionnelle",
    "Indemnisation des travailleurs et reass. proportionnelle",
    "Reassurance sante non proportionnelle"
  ),
  lob = c("1 et 13", "2 et 14", "3 et 15", "25"),
  sigma_prime_brut = c(.050, .085, .096, .17),
  sigma_reserve    = c(.057, .140, .110, .17),
  # Facteur NP par defaut : art. 148, paragraphe 3, deuxieme phrase (marqueur
  # B, JOUE L 12/94) : "Pour tous les segments vises a l'annexe XIV, le
  # facteur d'ajustement par defaut [...] est egal a 100 %" (issue #55).
  np_standard      = c(1, 1, 1, 1),
  stringsAsFactors = FALSE
)

# Catalogue unifié des segments, utilisé par l'interface et par
# usp_segment_infos(). L'annexe d'appartenance fait partie de la clé : les
# numéros de segment se recoupent entre les deux annexes.
SEGMENTS <- rbind(
  data.frame(annexe = "II", ANNEXE_II[, c("segment", "libelle")],
             sigma_prime_brut = ANNEXE_II$sigma_prime_brut,
             sigma_reserve = ANNEXE_II$sigma_reserve,
             np_standard = ANNEXE_II$np_standard, stringsAsFactors = FALSE),
  data.frame(annexe = "XIV", ANNEXE_XIV[, c("segment", "libelle")],
             sigma_prime_brut = ANNEXE_XIV$sigma_prime_brut,
             sigma_reserve = ANNEXE_XIV$sigma_reserve,
             np_standard = ANNEXE_XIV$np_standard, stringsAsFactors = FALSE)
)
SEGMENTS$cle <- paste0(SEGMENTS$annexe, "-", SEGMENTS$segment)

# Annexe XVII, section G - facteurs de crédibilité.
# Barème "long" : segments 1, 5 et 6 de l'annexe II.
CRED_LONG  <- c(`5` = .34, `6` = .43, `7` = .51, `8` = .59, `9` = .67,
                `10` = .74, `11` = .81, `12` = .87, `13` = .92, `14` = .96,
                `15` = 1.00)
# Barème "court" : autres segments de l'annexe II, segments de l'annexe XIV,
# et méthode risque de révision.
CRED_COURT <- c(`5` = .34, `6` = .51, `7` = .67, `8` = .81, `9` = .92,
                `10` = 1.00)

# Tolerance unique de regime des sections B et C (issue #31) : delta au bord
# de [0,1] et pi_t constant. Ce n'est PAS une valeur reglementaire mais une
# resolution numerique. Elle doit depasser la resolution du critere d'arret de
# L-BFGS-B sur delta. Depuis #63 (gradient analytique passe a optim(),
# factr divise par 1000, decision du mainteneur du 28/09/2026), la reduction
# relative factr * eps vaut 2,2e-14 pour l'ajustement complet usp_ajuster()
# (factr = 1e2) et 2,2e-12 pour le reajustement rapide usp_ajuster_rapide()
# (factr = 1e4) : les resolutions correspondantes sur delta, environ 1e-9 et
# 1e-7 avec les anciens reglages (1e5 et 1e7), baissent d'autant, l'objectif
# ne variant que de 2,3e-2 * (1 - delta) en relatif pres du bord sur les
# donnees de test. La justification tient donc a fortiori. Mesure (avis
# actuary du 28/09/2026 sur #63, reglage gradient analytique et factr / 1000) :
# sur 3 049 ajustements (1 051 jeux simules ajustes par usp_ajuster(),
# graine 20260924, et 2 x 999 reajustements bootstrap a trois demarrages de
# usp_ajuster_rapide() sur les jeux J1 et J2), aucune distance de delta au
# bord dans la fenetre (0 ; 1,7e-4) : le seuil 1e-6 ne separe donc aucun
# optimum interieur observe (0 sur 1 399 ajustements dans la mesure du
# 23/09/2026, anciens reglages). Valeur inchangee (decision du mainteneur du
# 28/09/2026). Unique source de cette tolerance : usp_ajuster()
# (delta_au_bord) et usp_regime() (pi_constant).
TOL_DELTA_BORD <- 1e-6

# Bornes de recherche de gamma dans usp_ajuster() (L-BFGS-B). Bornes
# NUMERIQUES, non reglementaires (le reglement ne borne que delta) : un gamma
# estime sur l'une d'elles signale que le maximum de vraisemblance n'est pas
# atteint (controle de la condition du premier ordre, issue #22). Source
# unique de ces bornes : usp_ajuster(), usp_ajuster_rapide(), usp_profil()
# et les libelles qui les citent (usp_tests(), par sprintf) les lisent ici
# (issue #22).
BORNES_GAMMA <- c(-12, 3)

# Tolerance de stats::optimize() sur gamma dans l'ajustement a delta fixe
# (usp_ajuster_contraint(), issue #45, specification d'actuary du
# 28/09/2026). Tolerance NUMERIQUE, non reglementaire. Source unique :
# usp_ajuster_contraint() ; usp_profil() garde la tolerance par defaut
# d'optimize(), ses valeurs ne bougent pas.
TOL_GAMMA_CONTRAINT <- 1e-8

# Reperes des controles numeriques de l'estimation lognormale (issue #22).
# Reperes NUMERIQUES, non reglementaires. Source unique : usp_ajuster()
# (ensemble des demarrages a l'optimum) et usp_kkt_satisfaite() (valeurs par
# defaut). Les libelles de usp_controles_numeriques() ne les impriment plus
# (issue #76) : la regle et ses reperes sont dans les fiches du .tex.
# - TOL_OPTIMUM : un demarrage est "a l'optimum" si son objectif est a moins
#   de TOL_OPTIMUM de l'objectif minimal ; meme ensemble pour la convergence
#   multi-demarrages (M15) et pour la condition de Kuhn-Tucker (M25).
# - REP_SIGMA_KKT : repere sur |erreur_sigma|, erreur relative de premier
#   ordre sur sigma qu'impliquerait le pas de Newton complet sur les
#   variables libres (issue #71, decision du mainteneur du 28/09/2026, qui
#   remplace le repere de M17 sur |pas de Newton en gamma|). Ancre sur M9
#   (tolerance de non-regression 1e-6, relative sur sigma), appliquee a la
#   grandeur qu'elle vise. Choix numerique, sans reference bibliographique.
#   Niveau mesure du residu apres #63 (gradient analytique, factr / 1000 ;
#   mesure de coder du 28/09/2026, 1 051 jeux simules, graine 20260924,
#   ecart du demarrage retenu a l'optimum de reference en |Delta gamma|) :
#   mediane 2,4e-13, 99e centile 1,1e-8, maximum 9,1e-8 ; il remplace le
#   plancher -h^2/3 ~ -3,3e-7 de la difference centree d'optim() (ndeps =
#   h = 1e-3), sans objet depuis #63.
# - REP_GD_KKT : repere sur |pg_delta|, regle unique au bord comme a
#   l'interieur (M16), maintenu a l'interieur comme garde de validite du
#   modele quadratique local (issue #71, Q71-3).
TOL_OPTIMUM   <- 1e-6
REP_SIGMA_KKT <- 1e-6
REP_GD_KKT    <- 1e-4

# Seuil d'ECHEC des tests en sens "rejeter" (engine_registre_tests()) : p <
# alpha donne OK, alpha <= p < SEUIL_ECHEC_SENS_REJETER donne ALERTE, au-dela
# ECHEC. Borne aussi le seuil alpha admis par run_engine() (suite de #88, avis
# d'actuary) : 0 < alpha < SEUIL_ECHEC_SENS_REJETER, faute de quoi la zone
# ALERTE disparait et le verdict ne suit plus la regle documentee.
SEUIL_ECHEC_SENS_REJETER <- 0.30

# Nombre minimal de replications bootstrap admis par run_engine() (constat C1
# de la revue finale d'E1, #44 ; .engine_verifier_usage()), pour les trois
# methodes. A B = B_MIN_USAGE = 99 : le plancher bilateral de la p-value
# Monte-Carlo, 2/(B+1) = 0,02, est sous alpha/2 = 0,05 au seuil par defaut
# alpha = 0,10 (pour alpha <= 0,04, la condition B + 1 > 4/alpha de
# engine_b_minimal() s'y ajoute, #127) ; la detection de
# degenerescence de engine_p_mc() est armee (B_MIN_DEGENERESCENCE = 50
# simulations finies, si au moins 50 des 99 sont finies) ; la ligne de largeur
# de l'IC bootstrap 90 % est presente (IC calcule au-dela de 20 tirages) ;
# c'est le minimum du champ B de l'application (app.R). Les appels directs de
# usp_bootstrap() et mw_bootstrap() ne sont pas bornes.
B_MIN_USAGE <- 99

# Tolerance relative de l'egalite entre sigma standard saisi et sigma
# standard reglementaire (colonne conforme de engine_derogations(), issue
# #93) : NP standard x sigma brut n'est pas toujours representable
# exactement (0,8 x 0,10), une comparaison par identical() dirait alors
# differente une saisie egale a la table.
TOLERANCE_CONFORME_SIGMA <- 1e-12

# --- Ex aequo des tests de rang et de signe (issue #112) ---------------------
# SEULE definition de l'ex aequo du moteur. Deux valeurs a et b sont ex aequo si
#     |a - b| <= TOL_EX_AEQUO * max(plancher, |a|, |b|),
# en deux regimes :
#   - plancher = 1 (defaut, celui de engine_p_mc()) pour r_t, z_t, u_t et les
#     residus de Mack : absolu a 1e-12 pour ces grandeurs d'ordre 1 (a z_t
#     voisin de 0, une tolerance purement relative serait denuee de sens) ;
#   - plancher = 0 pour les volumes x_t (.usp_aplatir_volumes()) : tolerance
#     purement relative, invariante d'unite (#110).
# Perimetre : les tests de rang et de signe de la branche lognormale
# (Cox-Stuart, Spearman ratio / volume et ratio / temps, Mann-Kendall,
# Smirnov sur z), le test des suites (Runs, Runsr et suites des residus de
# Mack), a l'observe comme dans les replications des catalogues Monte-Carlo,
# et .usp_nb_volumes_distincts() (#110) ; les statistiques de rang de
# Merz-Wuthrich (issue #152) : facteurs F(i,j) en plancher 0
# (mw_stat_correlation_dev(), mw_test_homogeneite_f(), classement L / S / *
# par la mediane de mw_test_annees_calendaires()), cumuls C(i,j) en
# plancher 0 et |residus| de Mack en plancher 1
# (mw_test_exposant_variance()), residus de Mack en plancher 1
# (mw_test_homogeneite_accident()).
# Restent a egalite EXACTE, sur x brut (un volume est saisi, non calcule) :
# la partition x > median(x) de Smirnov, de test_brown_forsythe() et de
# engine_plots_data(), et le tri par volume de test_goldfeld_quandt().
# Valeur (note d'actuary du 28/09/2026 sur #112, decision du mainteneur,
# garantie corrigee a la validation de fin de branche E1b) : le bruit
# d'arrondi de y_t / x_t est de l'ordre de 1e-16 relatif, celui de z_t de
# 1e-15 absolu ; deux ratios distincts de saisies a au plus cinq chiffres
# significatifs different d'au moins 1e-10 en relatif, donc d'au moins
# 1e-12 en absolu des que les ratios sont d'ordre 1e-2 ou plus (tolerance
# absolue sous 1 : plancher 1) ; a six chiffres l'ecart relatif minimal,
# 1e-12, coincide avec la tolerance et deux ratios distincts peuvent etre
# fusionnes (499999/999999 et 499998/999997). Pour z_t, aucune borne n'est
# etablie ; pour les residus de Mack (plancher 1, #152) non plus (marge
# mesuree d'environ 15 sous la tolerance sur reserve2).
# Aplatissement INTERNE aux tests de rang et de signe : chaque point d'entree
# aplatit ses propres arguments ; ni les donnees, ni usp_noyau(), ni les
# autres statistiques (AD, SW, DW, Grubbs, regressions auxiliaires...) ne
# sont aplaties. Apres aplatissement, deux valeurs sont ex aequo si et
# seulement si elles sont egales au bit pres : anyDuplicated(), table(),
# d != 0, sign(z - median(z)), cor.test() et ks.test() suivent alors tous la
# meme definition.
TOL_EX_AEQUO <- 1e-12
# Aplatit les ex aequo a la tolerance : la relation est fermee par chainage des
# valeurs triees adjacentes (groupes = plages maximales dont chaque ecart
# adjacent est sous la tolerance, definition deterministe malgre la
# non-transitivite d'une tolerance) ; chaque groupe recoit sa plus petite
# valeur. Ordre d'origine conserve. Entrees non finies : erreur.
# plancher : 1 par defaut (grandeurs d'ordre 1), 0 pour les volumes
# (.usp_aplatir_volumes()) ; aucune division, pas de debordement.
engine_aplatir_ex_aequo <- function(v, tol = TOL_EX_AEQUO, plancher = 1) {
  if (!all(is.finite(v))) stop("engine_aplatir_ex_aequo() : valeur non finie")
  o <- order(v); s <- v[o]; n <- length(s)
  if (n < 2) return(v)
  saut <- diff(s) > tol * pmax(plancher, abs(s[-1]), abs(s[-n]))
  g <- cumsum(c(TRUE, saut))                 # numero de groupe dans l'ordre trie
  rep_g <- s[!duplicated(g)]                  # plus petite valeur de chaque groupe
  w <- v; w[o] <- rep_g[g]; w
}
# TRUE si v contient au moins un ex aequo a la tolerance.
engine_ex_aequo <- function(v, tol = TOL_EX_AEQUO, plancher = 1)
  anyDuplicated(engine_aplatir_ex_aequo(v, tol, plancher)) > 0
# Volumes x_t : tolerance purement relative (plancher 0), seule fonction
# d'aplatissement des volumes (.usp_nb_volumes_distincts(), Spearman ratio /
# volume de usp_tests() et du catalogue SpearVol).
.usp_aplatir_volumes <- function(x) engine_aplatir_ex_aequo(x, plancher = 0)

usp_credibilite <- function(T, bareme = c("court", "long")) {
  bareme <- match.arg(bareme)
  tab <- if (bareme == "long") CRED_LONG else CRED_COURT
  # La duree est un nombre entier d'annees (section G, paragraphe 3 : "La
  # duree correspond" au "nombre d'annees d'accident" ou au "nombre
  # d'exercices pour lesquels des donnees sont disponibles", selon la
  # methode) ; une valeur non entiere, non finie ou multiple n'a pas
  # de ligne dans le bareme et est refusee explicitement (issue #33), au lieu
  # de renvoyer NA.
  if (!is.numeric(T) || length(T) != 1L || !is.finite(T) || T != round(T))
    stop("Annexe XVII, section G : la duree T doit etre un nombre entier d'annees (T = ",
         paste(format(T), collapse = ", "), ").")
  if (T < 5) stop("Annexe XVII : au moins 5 annees consecutives sont exigees (T = ", T, ").")
  Tc <- min(T, max(as.integer(names(tab))))
  unname(tab[as.character(Tc)])
}

# Annexe XVII, section G :
#   (1) bareme "long"  : segments 1, 5 et 6 de l'annexe II uniquement ;
#   (2) bareme "court" : segments 2 a 4 et 7 a 12 de l'annexe II, TOUS les
#       segments de l'annexe XIV (sante non-SLT), et la methode du risque de
#       revision.
# L'annexe d'appartenance est donc necessaire : le segment 1 de l'annexe XIV
# (frais medicaux) releve du bareme court, contrairement au segment 1 de
# l'annexe II (RC automobile).
# Annexe d'appartenance : "II" ou "XIV" exactement. Toute autre valeur ("xiv",
# "III", vecteur, NA) est refusee explicitement (issue #33) : elle etait
# auparavant traitee en silence comme l'annexe II.
.annexe_verifiee <- function(annexe) {
  if (!is.character(annexe) || length(annexe) != 1L || is.na(annexe) ||
      !annexe %in% c("II", "XIV"))
    stop("Annexe inconnue (", paste(format(annexe), collapse = ", "),
         ") : valeurs admises \"II\" (non-vie) ou \"XIV\" (sante non-SLT).")
  annexe
}

# Bareme de credibilite d'un segment (issue #133, avis d'actuary Q-E1d-4).
# Ordre des controles : annexe (.annexe_verifiee(), refusee meme sans
# segment), puis NULL -> "court" (convention des appelants sans segment,
# tracee "defaut" par .engine_trace_bareme()), puis numero de segment
# (.segment_verifie() : NA, texte, logique, facteur, nom, non entier,
# vecteur, vide refuses par une erreur d'usage qui nomme segment), puis
# existence du segment dans l'annexe (.segment_ligne()). Avant #133, ces
# valeurs rendaient "long" ("1", TRUE, factor(5), c(a = 1)), "court" (NA,
# 1.5, 99, et tout numero en annexe XIV, 5 compris) ou une erreur R qui ne
# nommait pas l'argument (c(1, 2), integer(0)) ; le chemin run_engine() n'est
# pas concerne, .engine_verifier_usage() validant segment avant cet appel.
# Un segment absent de l'annexe n'a pas de bareme dans la section G : le
# rendre "court" fabriquerait une determination reglementaire.
usp_bareme_segment <- function(segment, annexe = "II") {
  annexe <- .annexe_verifiee(annexe)
  if (is.null(segment)) return("court")
  segment <- .segment_verifie(segment)
  .segment_ligne(segment, annexe)
  if (identical(annexe, "XIV")) return("court")
  if (segment %in% c(1, 5, 6)) "long" else "court"
}

# Credibilite d'une duree sous le bareme APPLIQUE (issue #131, lecture R1 de
# regulatory, decision du mainteneur du 01/10/2026), partagee par le
# controle "Credibilite pleine atteinte" (usp_controle_donnees()) et les
# avertissements de credibilite partielle (engine_valider_donnees(),
# mw_valider_triangle()). Le bareme applique est celui qui entre dans
# sigma_USP, resolu comme dans run_engine() : bareme saisi s'il est fourni
# (derogation a la section G, #93, meme egal au bareme du segment), sinon
# bareme du segment (usp_bareme_segment() : G(1) long pour II-1, II-5,
# II-6 ; G(2) court pour les autres segments de l'annexe II et tous ceux de
# l'annexe XIV), sinon "court" par convention, sans segment (bareme non
# determine par la section G). duree : la duree de G(3), soit le T de
# l'estimation (premium, reserve1) ou I + 1 (reserve2), jamais le nombre
# d'annees fournies (lecture (A) de #104) ; entier >= 5 (usp_credibilite()).
# Retourne c, pleine (c == 1, seule condition de la credibilite pleine), le
# bareme applique, sa duree de credibilite pleine (15 en G(1), 10 en G(2),
# lue dans le bareme) et un libelle qui nomme le bareme, le point de la
# section G et son origine (segment, saisie, convention) ; avec un bareme
# saisi et un segment, le libelle donne aussi le bareme reglementaire du
# segment et son c. Libelle d'un bareme saisi aligne sur les etats de
# engine_parametre_standard() (saisi_egal, saisi_contraire,
# saisi_sans_segment). Bareme hors de "court" / "long" exactement, ou porteur
# d'attributs : erreur d'usage, comme dans .engine_verifier_usage()
# (usp_credibilite() accepterait une abreviation par match.arg()).
.engine_credibilite_appliquee <- function(duree, bareme = NULL, segment = NULL,
                                          annexe = "II") {
  annexe <- .annexe_verifiee(annexe)
  saisi <- !is.null(bareme)
  if (saisi && !(is.character(bareme) && length(bareme) == 1L && !is.na(bareme) &&
                 is.null(attributes(bareme)) && bareme %in% c("court", "long")))
    stop(sprintf(paste("bareme = %s : NULL, \"court\" ou \"long\" (sans attribut) est attendu",
                       "(annexe XVII, section G)."),
                 .engine_saisie(bareme)), call. = FALSE)
  regl <- if (!is.null(segment)) usp_bareme_segment(segment, annexe) else NULL
  appl <- if (saisi) bareme else if (!is.null(regl)) regl else "court"
  point <- function(b) if (b == "long") "G(1)" else "G(2)"
  pleine_a <- function(b) {
    tab <- if (b == "long") CRED_LONG else CRED_COURT
    min(as.integer(names(tab))[tab == 1])
  }
  cc <- usp_credibilite(duree, appl)
  seg <- if (!is.null(segment)) sprintf("%s-%d", annexe, as.integer(segment)) else NULL
  libelle <- if (saisi) {
    sprintf("bareme %s saisi (valeurs de %s) : %s", appl, point(appl),
            if (is.null(seg))
              "saisie declaree comme derogation, bareme reglementaire non determine"
            else if (identical(regl, appl))
              sprintf(paste("saisie declaree comme derogation (#93), egale au bareme",
                            "reglementaire du segment %s"), seg)
            else sprintf(paste("derogation au bareme de la section G (#93) ; bareme",
                               "reglementaire du segment %s : %s (%s), c = %.0f%%"),
                         seg, regl, point(regl), 100 * usp_credibilite(duree, regl)))
  } else if (!is.null(seg)) {
    sprintf("bareme %s du segment %s (annexe XVII, %s)", appl, seg, point(appl))
  } else {
    paste("bareme court par convention, non determine par la section G (aucun segment ;",
          "valeurs de G(2))")
  }
  list(c = cc, pleine = isTRUE(cc == 1), bareme = appl, pleine_a = pleine_a(appl),
       libelle = libelle)
}

# Valeur refusee citee dans un message d'erreur d'usage (issue #133) :
# deparse() garde les guillemets d'un texte et la forme c(...) d'un vecteur,
# mais arrondit un double a 15 chiffres significatifs, de sorte que
# 1 + 1e-15 etait cite 1, valeur que le message refuse en l'affichant comme
# valide. Un double que l'ecriture a 15 chiffres ne restitue pas exactement
# est donc cite a 17 chiffres (option digits17 de deparse(), qui restitue
# tout double) ; les autres gardent l'ecriture a 15 chiffres, afin que 0.3
# reste cite 0.3 et non 0.29999999999999999. Vide : "vide".
# La relecture est testee numeriquement, sur les valeurs debarrassees de
# leurs attributs (sprintf("%.15g") relu par as.double()), sans rien
# evaluer : relire le texte de deparse() par eval() executait le code d'un
# attribut de type langage (deparse() retire le quote()), constat C1 de
# l'audit de #133. NA, NaN, Inf, -Inf et -0 se relisent tels quels.
# Le passage a 17 chiffres se decide pour tout le vecteur : il suffit d'une
# valeur non restituee pour que toutes soient citees a 17 chiffres ; sans
# consequence, un vecteur etant de toute facon refuse par les appelants.
.engine_saisie <- function(v) {
  if (!length(v)) return("vide")
  relue <- TRUE
  if (is.double(v)) {
    u <- as.vector(unclass(v))
    u <- u[!is.na(u)]                 # NA, NaN : relus tels quels, sans conversion
    relue <- all(as.double(sprintf("%.15g", u)) == u)
  }
  ctl <- c("keepNA", "keepInteger", "niceNames", "showAttributes")
  if (!relue) ctl <- c(ctl, "digits17")
  paste(deparse(v, control = ctl), collapse = " ")
}

# Numero de segment (issue #105) : nombre scalaire fini entier, sans attribut
# (noms, dim). Toute autre valeur est une erreur d'usage nommant segment :
# vecteur (c(1, 2)), vide (integer(0)), NA, Inf, non entier (1.5), logique
# (TRUE), texte ("1"). Le texte est refuse et non converti (decision du
# mainteneur du 27/09/2026, Q-E0b-2), comme dans les autres controles de
# .engine_verifier_usage() : une conversion silencieuse masquerait l'erreur
# de l'appelant. Avant #105, c(1, 2) et integer(0) levaient une erreur R qui
# ne nommait pas l'argument, et "1", TRUE, c(a = 1) ou matrix(1) etaient
# acceptes (la valeur recue etait recopiee telle quelle dans le resultat).
# Un segment conforme mais absent de l'annexe garde le message d'origine de
# usp_segment_infos() ("Segment 13 inconnu dans l'annexe II.").
.segment_verifie <- function(segment) {
  if (!(is.numeric(segment) && length(segment) == 1L && is.null(attributes(segment)) &&
        is.finite(segment) && segment == round(segment)))
    stop(sprintf(paste("segment = %s : un nombre scalaire fini entier, sans attribut,",
                       "est attendu (numero de segment de l'annexe II ou XIV ; texte",
                       "refuse, sans conversion)."),
                 .engine_saisie(segment)),
         call. = FALSE)
  segment
}

# Ligne du segment dans le tableau de son annexe (ANNEXE_II ou ANNEXE_XIV),
# partagee par usp_segment_infos() et usp_bareme_segment() (issue #133) ; un
# segment absent de l'annexe est refuse avec le message d'origine de
# usp_segment_infos(). segment et annexe sont deja verifies par l'appelant.
.segment_ligne <- function(segment, annexe) {
  tab <- if (identical(annexe, "XIV")) ANNEXE_XIV else ANNEXE_II
  i <- match(segment, tab$segment)
  if (is.na(i)) stop(sprintf("Segment %s inconnu dans l'annexe %s.", segment, annexe),
                     call. = FALSE)
  i
}

# Renvoie les caracteristiques reglementaires d'un segment : libelle, ecarts
# types standard, facteur NP standard et bareme de credibilite applicable.
usp_segment_infos <- function(segment, annexe = "II") {
  segment <- .segment_verifie(segment)
  annexe <- .annexe_verifiee(annexe)
  tab <- if (identical(annexe, "XIV")) ANNEXE_XIV else ANNEXE_II
  i <- .segment_ligne(segment, annexe)
  list(annexe = annexe, segment = segment, libelle = tab$libelle[i],
       sigma_prime_brut = tab$sigma_prime_brut[i],
       sigma_reserve = tab$sigma_reserve[i],
       np_standard = tab$np_standard[i],
       bareme = usp_bareme_segment(segment, annexe))
}

# Nature des donnees de la methode du risque de primes (issue #55, decision
# M13 du mainteneur) : "brutes" (pertes agregees et primes acquises non
# ajustees de la reassurance) ou "nettes" (ajustees de la reassurance). La
# declaration est OBLIGATOIRE pour la methode "premium", sans valeur par
# defaut : c'est elle qui fixe le parametre standard remplace (annexe XVII,
# section B, paragraphe 2, points c) et d), dans leur version consolidee,
# marqueur M1 :
# les renvois de la version d'origine, JOUE L 12/272, y sont inverses).
NATURES_DONNEES <- c("brutes", "nettes")

# Declaration recevable : une chaine unique de NATURES_DONNEES (NULL, NA,
# vecteur, autre texte ou casse : refuses).
.nature_valide <- function(nature)
  is.character(nature) && length(nature) == 1L && !is.na(nature) &&
    nature %in% NATURES_DONNEES

# Controle de la nature declaree selon la methode (issue #55, decision M13 ;
# decisions du mainteneur du 25/09/2026 pour les methodes de reserve).
# Renvoie les motifs de refus (vecteur vide si la declaration est recevable) :
#   - "premium" : declaration obligatoire, "brutes" ou "nettes" ;
#   - "reserve1", "reserve2" : donnees nettes par exigence du texte (annexe
#     XVII, C(2)(c) ; D(2)(f)) : NULL (pas de declaration) ou "nettes"
#     acceptes, "brutes" refuse avec ce motif, toute autre valeur refusee
#     comme non reconnue ;
#   - methode NULL (controle d'une saisie ou d'un import hors calcul) : aucun
#     controle.
# Partage par engine_valider_donnees() (premium, reserve1), .run_engine_mw()
# (reserve2) et usp_parametre_standard() (appel direct).
.nature_erreurs <- function(methode, nature_donnees) {
  if (is.null(methode)) return(character(0))
  if (is.factor(methode)) methode <- as.character(methode)
  if (identical(methode, "premium")) {
    if (.nature_valide(nature_donnees)) return(character(0))
    return(paste(
      "Nature des donnees non declaree : pour la methode du risque de primes, declarer",
      "des donnees \"brutes\" (non ajustees de la reassurance, annexe XVII, B(2)(c) :",
      "sigma brut de l'annexe) ou \"nettes\" (ajustees de la reassurance, B(2)(d) :",
      "NP standard x sigma brut) ; aucune valeur par defaut (issue #55)."))
  }
  # Robustesse (audit de la reprise de #55) : une methode non scalaire ou non
  # textuelle n'est pas une methode de reserve, sans erreur R "condition has
  # length > 1" (run_engine() et app.R passent toujours un scalaire).
  if (!(is.character(methode) && length(methode) == 1L &&
        methode %in% c("reserve1", "reserve2"))) return(character(0))
  if (is.null(nature_donnees) || identical(nature_donnees, "nettes")) return(character(0))
  exigence <- if (identical(methode, "reserve1"))
    paste("annexe XVII, section C, paragraphe 2, point c) : donnees ajustees de la reassurance",
          "et des vehicules de titrisation, conformement aux contrats en place pour",
          "les douze mois a venir")
  else paste("annexe XVII, section D, paragraphe 2, point f) : montants de sinistres cumules",
             "ajustes de la reassurance et des vehicules de titrisation, conformement",
             "aux contrats en place pour les douze mois a venir")
  if (identical(nature_donnees, "brutes"))
    return(sprintf(paste("Donnees declarees \"brutes\" refusees : la methode du risque de",
                         "reserve no %s exige des donnees nettes de reassurance (%s) ;",
                         "declarer \"nettes\" ou ne rien declarer (issue #55)."),
                   if (identical(methode, "reserve1")) "1" else "2", exigence))
  sprintf(paste("Nature des donnees non reconnue (nature_donnees = %s) : pour la methode du",
                "risque de reserve no %s, seules \"nettes\" ou l'absence de declaration sont",
                "recevables (%s ; issue #55)."),
          paste(deparse(nature_donnees), collapse = " "),
          if (identical(methode, "reserve1")) "1" else "2", exigence)
}

# Parametre standard qui entre dans le melange de l'annexe XVII (B(4), C(4),
# D(4) : "le parametre standard a remplacer"), et sa tracabilite
# reglementaire. Lecture CONDITIONNELLE de la decision M13 (issue #55) :
#   - methode du risque de primes, donnees BRUTES (B(2)(c), M1) : parametre
#     remplace art. 218, paragraphe 1, point a) ii) (annexe II) ou c) ii)
#     (annexe XIV) ; valeur standard = sigma brut de l'annexe ;
#   - methode du risque de primes, donnees NETTES (B(2)(d), M1) : parametre
#     remplace point a) i) ou c) i) ; valeur standard = NP standard x sigma
#     brut (art. 117, paragraphe 3 ; art. 148, paragraphe 3). NP est le
#     facteur STANDARD de la colonne np_standard, jamais un NP propre a
#     l'entreprise (pas d'entree NP : M13) ;
#   - methodes de reserve (C, D) : parametre a) iv) ou c) iv), sigma(res,s)
#     de l'annexe, sans NP ; donnees nettes par exigence du texte (C(2)(c),
#     D(2)(f)) : NULL ou "nettes" acceptes, "brutes" refuse (erreur,
#     .nature_erreurs(), decision du mainteneur du 25/09/2026).
# sigma_standard : valeur saisie librement ; si elle est fournie, elle prime
# sur le segment (comportement conserve, decision du mainteneur du
# 24/09/2026) et le resultat la signale comme DEROGATION au parametre
# reglementaire (champ saisie), meme si elle egale la valeur de la table
# (decision du mainteneur du 25/09/2026).
# Donnees brutes et methodes de reserve : la valeur de la table est reprise
# telle quelle, sans multiplication, afin que le sigma standard soit le meme
# double qu'avant l'issue #55.
usp_parametre_standard <- function(methode = c("premium", "reserve1", "reserve2"),
                                   segment = NULL, annexe = "II",
                                   nature_donnees = NULL, sigma_standard = NULL) {
  methode <- match.arg(methode)
  annexe  <- .annexe_verifiee(annexe)
  infos <- if (!is.null(segment)) usp_segment_infos(segment, annexe) else NULL
  if (is.null(infos) && is.null(sigma_standard))
    stop("Fournir soit sigma_standard, soit segment (avec son annexe).")
  lettre  <- if (identical(annexe, "XIV")) "c)" else "a)"
  article <- if (identical(annexe, "XIV")) "art. 148" else "art. 117"
  err_nature <- .nature_erreurs(methode, nature_donnees)
  if (length(err_nature)) stop(err_nature)
  if (methode == "premium") {
    nettes <- identical(nature_donnees, "nettes")
    sigma_annexe <- if (!is.null(infos)) infos$sigma_prime_brut else NA_real_
    np <- if (!is.null(infos)) infos$np_standard else NA_real_
    sigma_regl <- if (is.null(infos)) NA_real_ else if (nettes) np * sigma_annexe else sigma_annexe
    point <- paste(lettre, if (nettes) "i)" else "ii)")
    parametre <- if (nettes)
      sprintf(paste("ecart type du risque de primes (%s, paragraphe 2, point a)),",
                    "valeur standard NP x ecart type brut (%s, paragraphe 3)"), article, article)
    else sprintf("ecart type du risque de primes brut (%s, paragraphe 3)", article)
    exigence <- if (nettes)
      paste("annexe XVII, section B, paragraphe 2, point d), chapeau modifie par le reglement",
            "delegue (UE) 2016/467 (M1) : pertes agregees ajustees des montants",
            "recouvrables au titre de la reassurance et des vehicules de titrisation,",
            "primes acquises ajustees des primes de reassurance, conformement aux",
            "contrats de reassurance et vehicules de titrisation en place pour les",
            "douze mois a venir")
    else paste("annexe XVII, section B, paragraphe 2, point c), remplace par le reglement delegue",
               "(UE) 2016/467 (M1) : pertes agregees et primes acquises non ajustees",
               "des montants recouvrables au titre de la reassurance et des vehicules",
               "de titrisation ni des primes de reassurance")
    nature <- nature_donnees
  } else {
    sigma_annexe <- if (!is.null(infos)) infos$sigma_reserve else NA_real_
    np <- NA_real_
    sigma_regl <- sigma_annexe
    point <- paste(lettre, "iv)")
    parametre <- sprintf("ecart type du risque de reserve sigma(res,s) de l'annexe %s", annexe)
    exigence <- if (methode == "reserve1")
      paste("annexe XVII, section C, paragraphe 2, point c) : donnees ajustees de la reassurance",
            "et des vehicules de titrisation, conformement aux contrats en place pour",
            "les douze mois a venir (exigence de la methode)")
    else paste("annexe XVII, section D, paragraphe 2, point f) : montants de sinistres cumules",
               "ajustes de la reassurance et des vehicules de titrisation, conformement",
               "aux contrats en place pour les douze mois a venir (exigence de la methode)")
    nature <- "nettes"
  }
  saisie <- !is.null(sigma_standard)
  list(methode = methode, annexe = annexe, segment = segment,
       nature_donnees = nature,
       point_art218 = sprintf("art. 218, paragraphe 1, point %s", point),
       parametre_remplace = parametre,
       exigence_donnees = exigence,
       sigma_annexe = sigma_annexe,
       np_standard = np,
       sigma_reglementaire = sigma_regl,
       sigma_standard = if (saisie) sigma_standard else sigma_regl,
       saisie = saisie)
}


## =============================================================================
## 1. LECTURE ET CONTRÔLES DE QUALITÉ DES DONNÉES (art. 19 et 219)
## =============================================================================

# Lecture d'un CSV "vecteur" (une serie annuelle). Formats acceptes, apres
# retrait des lignes et colonnes entierement vides de bord :
#  - une seule colonne, avec ou sans en-tete (premiere cellule non numerique) ;
#  - une seule ligne, avec ou sans en-tete en premiere cellule ;
#  - deux lignes dont la PREMIERE est une ligne d'en-tetes : elle est ecartee
#    et la seconde est lue comme une serie en ligne. La premiere ligne est une
#    ligne d'en-tetes (issue #103, regle commune d'actuary du 28/09/2026) si
#    (H1) aucune de ses cellules n'est numerique (cellules vides comprises,
#    ex. a2017;...;a2024) et aucune de ses cellules non vides n'a l'allure
#    d'une valeur manquante ou d'un nombre au sens de
#    .allure_manquante_ou_nombre() (predicat entier, issue #139, decision du
#    mainteneur du 28/09/2026 ; exception AAAA-AA comprise : "2017-18,2018-19"
#    reste une ligne d'en-tetes) ; une ligne sans cellule numerique mais avec
#    une telle cellule ("1 000;2 000" avec dec = ",", "1O4.2,1O2.5",
#    "NA,#N/A", "2017 primes,...") fait refuser le fichier, en citant la
#    premiere cellule fautive et sa colonne, au lieu d'etre ecartee sans
#    message comme auparavant ; ou si (H2) ses cellules non vides, hors la cellule
#    d'angle (premiere colonne, vide ou libelle sans chiffre hors
#    .allure_manquante_ou_nombre(), ex. "annee"), sont des annees a quatre
#    chiffres comprises entre 1900 et 2100, au nombre de deux au moins,
#    consecutives (de 1 en 1, toutes croissantes ou toutes decroissantes) :
#    .ligne_annees(). Le sens des annees n'est pas interprete : la serie est
#    rendue dans l'ordre du fichier, usp_charger(plus_recent_en_dernier)
#    fixant l'ordre chronologique (decision du mainteneur du 28/09/2026).
# Tout autre tableau de plusieurs lignes et plusieurs colonnes est refuse
# (pas d'aplatissement silencieux ; decision du 25/09/2026) ; pour un tableau
# de deux lignes, le message nomme la cause pour laquelle la premiere ligne
# n'est pas une ligne d'en-tetes. Les cellules
# sont lues comme du texte, sans retirer les lignes vides, afin que la
# position de chaque valeur soit conservee : une cellule vide ou non
# numerique AU MILIEU de la serie est refusee, car la retirer decalerait
# toutes les annees suivantes et desalignerait x et y (issue #33). Sont
# seulement ecartes : la ligne d'en-tetes ci-dessus, une premiere cellule non
# numerique (en-tete) et les cellules vides en tete de serie, entre l'en-tete
# et la premiere valeur, et en fin de serie (lues sans effet par l'ancien
# lecteur, qui sautait les lignes vides).
#
# Serie en ligne avec ligne d'en-tetes (issue #95, decision du mainteneur) :
# en-tetes et valeurs doivent etre alignes colonne par colonne. Hors colonne
# d'etiquette, chaque colonne porte un en-tete non vide et une valeur, ou ni
# l'un ni l'autre ; sinon une valeur manquante en tete ou en fin de serie
# (cellule vide de bord, ecartee ci-dessus) ou une valeur en surnombre
# passerait sans message. Le fichier est refuse en listant les colonnes
# fautives, avec les deux decomptes. L'etiquette de ligne (premiere cellule non
# vide de la serie, non numerique) n'est admise que si la cellule d'en-tete
# au-dessus d'elle est vide (regle stricte, issue #102, decision du
# mainteneur du 28/09/2026, qui revient sur l'admission du 26/09) : sous un
# en-tete non vide, elle est refusee, car une premiere valeur mal saisie
# ("1O4.2", "abc") y serait ecartee comme etiquette sans message. Sous (H2),
# la cellule d'angle ("annee", libelle sans chiffre) n'est pas un en-tete d'annee : elle
# compte comme une cellule d'en-tete vide, pour l'etiquette comme pour
# l'alignement (une valeur numerique au-dessous est une valeur sans en-tete).
#
# En-tete et etiquette (issues #95 et #102, avis d'actuary) : dans tous les
# formats, la premiere cellule non vide et non numerique, ecartee comme
# en-tete (formats en colonne et en ligne sans en-tetes) ou comme etiquette
# de ligne (format avec ligne d'en-tetes, sous une cellule d'en-tete vide),
# est refusee si elle a l'allure d'une valeur manquante ou d'un nombre
# (.allure_manquante_ou_nombre()) : l'ecarter ferait perdre une annee sans
# message.
usp_lire_vecteur <- function(chemin, sep = ",", dec = ".") {
  if (!file.exists(chemin)) stop("Fichier introuvable : ", chemin)
  brut <- utils::read.csv(chemin, header = FALSE, sep = sep, dec = dec,
                          colClasses = "character", blank.lines.skip = FALSE,
                          na.strings = character(0), strip.white = TRUE)
  m <- as.matrix(brut)
  m[is.na(m)] <- ""
  # Marque d'ordre des octets UTF-8 (EF BB BF, "UTF-8 avec BOM" d'Excel) :
  # hors locale UTF-8, read.csv la laisse en tete de la premiere cellule, qui
  # n'est alors plus numerique et serait prise pour un en-tete (premiere
  # valeur perdue sans message, issue #96). Retiree octet par octet, quelle
  # que soit la locale ; une locale UTF-8 l'a deja retiree.
  if (length(m)) m[1, 1] <- .sans_bom(m[1, 1])
  # Blancs de bord retires octet par octet, cellules non UTF-8 comprises
  # (issue #99 : trimws() levait une erreur R en locale UTF-8).
  m <- .nettoyer_cellules(m)
  # Lignes et colonnes entierement vides AVANT la premiere valeur ou APRES
  # la derniere (debut ou fin de fichier, separateur final) ecartees ; une
  # ligne ou une colonne vide intercalee est conservee (cellule vide, refusee
  # plus bas). Il doit rester une seule ligne ou une seule colonne, ou deux
  # lignes dont la premiere est une ligne d'en-tetes (ci-dessous).
  nz <- matrix(nzchar(m), nrow(m), ncol(m))
  bornes <- function(k) if (length(k)) seq(min(k), max(k)) else integer(0)
  # Numeros de colonne du fichier conserves pour les messages (colonnes de bord
  # vides retirees).
  cols <- bornes(which(colSums(nz) > 0))
  m <- m[bornes(which(rowSums(nz) > 0)), cols, drop = FALSE]
  en_nombre <- function(v) .cellules_en_nombre(v, dec)
  # Serie en ligne avec en-tete : 2 lignes dont la premiere est une ligne
  # d'en-tetes (H1 ou H2 ci-dessus) ; la ligne d'en-tetes est ecartee apres
  # controle de l'etiquette de ligne ; l'alignement colonne par colonne est
  # controle plus bas (#95).
  aligne <- NULL
  # perte : consequence d'un ecart sans message, citee dans le message ; la
  # ligne d'en-tetes (H1) passe sa propre formulation (issue #139).
  refus_allure <- function(x, ou,
                           perte = "l'ecarter comme en-tete ou etiquette ferait perdre une annee sans message.")
    stop(sprintf(paste("Lecture de %s : la cellule \"%s\" %s, a l'allure d'une valeur manquante",
                       "(NA, N/A, N.D., ND, NR, NC, NULL, tirets, ou cellule commencant par #, code",
                       "d'erreur Excel) ou d'un nombre (cellule qui commence par un chiffre, ou faite",
                       "de chiffres, espaces, points, virgules, apostrophes, signes ; separateur",
                       "decimal attendu : \"%s\") ;", "%s",
                       "Corriger la valeur ou le separateur decimal, ou renseigner un en-tete ou",
                       "une etiquette textuels."),
                 chemin, x, ou, dec, perte))
  annees <- NULL
  if (nrow(m) == 2 && ncol(m) > 1) {
    h1 <- all(is.na(en_nombre(m[1, ])))
    if (h1) {
      # (H1), predicat entier (issue #139) : une cellule non vide de la ligne
      # d'en-tetes qui a l'allure d'une valeur manquante ou d'un nombre fait
      # refuser le fichier ; ecarter la ligne ferait perdre sans message
      # jusqu'a une serie entiere mal saisie ("1 000;2 000", "1O4.2,1O2.5").
      # La premiere cellule fautive est citee avec sa colonne du fichier.
      fautive <- which(nzchar(m[1, ]) & .allure_manquante_ou_nombre(m[1, ]))
      if (length(fautive))
        refus_allure(m[1, fautive[1]],
                     sprintf("(colonne %d) dans la ligne d'en-tetes", cols[fautive[1]]),
                     paste("ecarter la ligne d'en-tetes qui la contient ferait perdre sans message,",
                           "si cette ligne est une serie mal saisie, toutes ses valeurs."))
    } else annees <- .ligne_annees(m[1, ], m[2, ], dec)
  }
  if (nrow(m) == 2 && ncol(m) > 1 && (h1 || annees$ok)) {
    ent <- m[1, ]; val <- m[2, ]
    # (H2) : cellule d'angle (libelle sans chiffre) traitee comme un en-tete vide.
    if (!h1 && annees$angle) ent[1] <- ""
    # Etiquette de ligne : premiere cellule non vide de la serie, non
    # numerique ; admise seulement sous une cellule d'en-tete vide (regle
    # stricte, #102) et sauf allure de valeur manquante ou de nombre ; exclue
    # du controle d'alignement.
    j1 <- which(nzchar(val))[1]
    if (!is.na(j1) && is.na(en_nombre(val[j1]))) {
      if (nzchar(ent[j1]))
        stop(sprintf(paste0("Serie en ligne de %s : la cellule \"%s\" (colonne %d) n'est pas numerique ",
                            "et l'en-tete \"%s\" au-dessus d'elle n'est pas vide. Si c'est une ",
                            "etiquette de ligne, laisser vide l'en-tete de sa colonne ; sinon corriger ",
                            "la valeur%s."),
                     chemin, val[j1], cols[j1], ent[j1],
                     if (.allure_manquante_ou_nombre(val[j1]))
                       sprintf(paste0(" (elle a l'allure d'une valeur manquante ou d'un nombre ; ",
                                      "separateur decimal attendu : \"%s\")"), dec)
                     else ""))
      if (.allure_manquante_ou_nombre(val[j1]))
        refus_allure(val[j1], sprintf("(colonne %d), en position d'etiquette de ligne", cols[j1]))
      garde <- setdiff(seq_along(val), j1)
    } else garde <- seq_along(val)
    aligne <- list(ent = ent[garde], val = val[garde], col = cols[garde])
    m <- m[2, , drop = FALSE]
  }
  if (nrow(m) > 1 && ncol(m) > 1)
    stop("Format non reconnu dans ", chemin, " : une serie sur une seule ligne ou ",
         "une seule colonne est attendue (", nrow(m), " lignes x ", ncol(m), " colonnes).",
         if (!is.null(annees))
           paste0(" Une premiere ligne d'en-tetes est reconnue si aucune de ses cellules n'est ",
                  "numerique, ou si ses cellules (hors la premiere) sont des annees a quatre ",
                  "chiffres consecutives ; ici : ", annees$cause, "."))
  cel <- as.vector(m)
  # Cellules vides de tete ignorees, puis en-tete (premiere cellule non vide
  # et non numerique), puis cellules vides entre l'en-tete et la premiere
  # valeur. Les positions rapportees plus bas partent de la premiere valeur.
  sans_vides_tete <- function(v) { while (length(v) && !nzchar(v[1])) v <- v[-1]; v }
  cel <- sans_vides_tete(cel)
  if (length(cel) && is.na(en_nombre(cel[1]))) {
    # En-tete des formats en colonne et en ligne sans en-tetes ; l'etiquette
    # du format avec en-tetes a ete controlee plus haut (meme predicat).
    if (is.null(aligne) && .allure_manquante_ou_nombre(cel[1]))
      refus_allure(cel[1], "en position d'en-tete (premiere cellule non vide)")
    cel <- sans_vides_tete(cel[-1])
  }
  # Cellules vides finales (fin de fichier) : ignorees.
  while (length(cel) && !nzchar(cel[length(cel)])) cel <- cel[-length(cel)]
  if (!length(cel)) stop("Aucune valeur numerique exploitable dans ", chemin)
  v <- en_nombre(cel)
  vides <- which(!nzchar(cel))
  if (length(vides))
    stop(sprintf(paste("Cellule(s) vide(s) en position %s de la serie (comptee depuis la premiere valeur) de %s :",
                       "une valeur manquante",
                       "au milieu de la serie decalerait les annees suivantes ; completer",
                       "ou retirer l'annee dans les deux fichiers."),
                 paste(vides, collapse = ", "), chemin))
  # Valeurs non finies (Inf, -Inf, NaN) refusees des la lecture, comme une
  # valeur non numerique.
  non_num <- which(is.na(v) | !is.finite(v))
  if (length(non_num))
    stop(sprintf("Valeur(s) non numerique(s) en position %s de la serie (comptee depuis la premiere valeur) de %s : %s.",
                 paste(non_num, collapse = ", "), chemin,
                 paste0("\"", cel[non_num], "\"", collapse = ", ")))
  # Alignement (#95) : hors etiquette, chaque colonne porte un en-tete non
  # vide ET une valeur, ou ni l'un ni l'autre. Les cellules vides au milieu de
  # la serie ont deja ete refusees ci-dessus (message #33).
  if (!is.null(aligne)) {
    he <- nzchar(aligne$ent); va <- nzchar(aligne$val)
    fautes <- c(
      sprintf("colonne %d : en-tete \"%s\" sans valeur", aligne$col[he & !va], aligne$ent[he & !va]),
      sprintf("colonne %d : valeur \"%s\" sans en-tete", aligne$col[!he & va], aligne$val[!he & va]))
    ordre <- order(c(aligne$col[he & !va], aligne$col[!he & va]))
    if (length(fautes))
      stop(sprintf(paste("Serie en ligne de %s : en-tetes et valeurs non alignes (%s ; %d valeur(s)",
                         "pour %d en-tete(s) non vide(s)). Une valeur manquante ou en surnombre",
                         "decalerait les annees ; completer la serie ou corriger la ligne",
                         "d'en-tetes (si la premiere colonne porte une etiquette de ligne, la",
                         "renseigner ou retirer son en-tete)."),
                   chemin, paste(fautes[ordre], collapse = " ; "), sum(va), sum(he)))
  }
  v
}

# Retire la marque d'ordre des octets UTF-8 (EF BB BF) en tete d'une chaine,
# en comparant les octets, independamment de la locale et de l'encodage
# declare de la chaine (issue #96).
.sans_bom <- function(s) {
  if (is.na(s)) return(s)
  r <- charToRaw(s)
  if (length(r) >= 3 && identical(r[1:3], as.raw(c(0xef, 0xbb, 0xbf)))) {
    out <- rawToChar(r[-(1:3)])
    Encoding(out) <- Encoding(s)
    out
  } else s
}

# Cellules non UTF-8 lues en locale UTF-8 (issue #99). Un CSV encode en
# Windows-1252 (ou Latin-1) qui contient un octet non ASCII ("ann<E9>e",
# espace insecable A0) donne, sous une locale UTF-8, des chaines d'encodage
# "unknown" dont les octets ne sont pas de l'UTF-8 valide : trimws() (via
# sub(perl = TRUE)) et as.numeric() levaient alors une erreur R brute
# ("input string 1 is invalid UTF-8", "invalid multibyte string"), avant tout
# controle. Hors locale UTF-8, ces cellules etaient deja lues sans erreur.
# .octets_non_utf8() : vrai pour une chaine non NA dont les octets ne sont pas
# de l'UTF-8 valide, en locale UTF-8 seulement (faux partout ailleurs, pour
# laisser inchange le comportement hors locale UTF-8).
.octets_non_utf8 <- function(x) {
  if (!isTRUE(l10n_info()[["UTF-8"]]) || !length(x)) return(rep(FALSE, length(x)))
  !is.na(x) & !validUTF8(x)
}

# Retire les blancs ASCII (espace, tabulation, retour chariot, saut de ligne)
# en tete et en fin de chaque cellule, comme trimws() avec son jeu de blancs
# par defaut, mais octet par octet (useBytes, motifs ASCII) : aucune erreur
# sur une cellule non UTF-8 (issue #99). L'encodage declare de chaque
# cellule et les attributs (dim) sont conserves. En locale UTF-8, une
# cellule non UTF-8 d'encodage "unknown" est en outre declaree Latin-1, sans
# changer ses octets : les messages qui la citent restent de l'UTF-8 valide
# ("annee" accentue, espace insecable) ; R y convertit les octets 80-9F
# selon Windows-1252, et non comme des caracteres de controle (mesure du
# 01/10/2026, R 4.3.3, locale C.UTF-8 : 80 -> U+20AC symbole euro,
# 85 -> U+2026, 96 -> U+2013, 9F -> U+0178 ; les octets 81, 8D, 8F, 90 et
# 9D, sans caractere en Windows-1252, restent ecrits "<81>"...). Les octets
# etant inchanges, .allure_manquante_ou_nombre() reconnait l'espace
# insecable Windows-1252 (octet A0 isole) en locale UTF-8 comme ailleurs.
.nettoyer_cellules <- function(x) {
  inv <- .octets_non_utf8(x) & Encoding(x) == "unknown"
  if (any(inv)) Encoding(x)[inv] <- "latin1"
  y <- sub("[ \t\r\n]+$", "", sub("^[ \t\r\n]+", "", x, useBytes = TRUE), useBytes = TRUE)
  # Encoding<- refuse une valeur de longueur nulle : entree vide rendue telle
  # que sub() la rend (attributs, dont dim, conserves).
  if (length(x)) Encoding(y) <- Encoding(x)
  y
}

# Conversion numerique des cellules texte (separateur decimal dec) : une
# cellule non UTF-8 en locale UTF-8 vaut NA (non numerique) sans appel a
# as.numeric(), qui leverait une erreur (issue #99) ; hors locale UTF-8, les
# memes cellules valaient deja NA (mesure du 28/09/2026, R 4.3.1, locale C :
# "1<A0>", "<A0>1", "1<85>"). Les autres cellules passent par as.numeric()
# comme auparavant.
.cellules_en_nombre <- function(v, dec = ".") {
  out <- rep(NA_real_, length(v))
  ok <- !.octets_non_utf8(v)
  w <- v[ok]
  if (dec != ".") w <- gsub(dec, ".", w, fixed = TRUE)
  out[ok] <- suppressWarnings(as.numeric(w))
  out
}

# Vrai si la cellule (deja passee par .nettoyer_cellules()) a l'allure d'une valeur
# manquante ou d'un nombre, et ne peut donc servir d'en-tete ni d'etiquette de
# ligne dans usp_lire_vecteur() (issue #95 ; regle commune d'actuary du
# 28/09/2026 et decisions du mainteneur du meme jour, issue #102). Espaces de
# bord retirees (espaces insecables comprises), casse ignoree, apres
# conversion des tirets et des points de suspension (ci-dessous) :
#  (a1) marqueur de la liste fermee NA, NAN, N/A, N.A., N.A, N.D., N.D, ND,
#       N/D, NR, N.R., NULL, NONE, S.O., S.O, S/O, NIL, N.C., N.C, NC, N/C ;
#  (a2) ou cellule commencant par "#" (codes d'erreur de calcul d'Excel dans
#       toutes les langues : #N/A, #DIV/0!, #VALEUR!, #REF!, #NOM?, #####...) ;
#  (a3) ou cellule faite uniquement, avec au moins un caractere, de "-",
#       tiret demi-cadratin U+2013, tiret cadratin U+2014, ".", points de
#       suspension U+2026 et "?" ("-", "--", ".", "?"...) ;
#  (b)  ou cellule faite uniquement de chiffres, d'espaces (ordinaire ou
#       insecable U+00A0 ou fine insecable U+202F), de ".", ",", "'", "+",
#       "-", avec au moins un chiffre (ex. "1,5" avec dec = ".", "1 234",
#       "1.234,5", "1,234.5", "12.2017", "+1", "'2017") ;
#  (b') ou cellule qui, apres une apostrophe, un signe "+" ou "-" et des
#       espaces de tete, commence par un chiffre ("1O4.2", "104.2 EUR",
#       "12a", "2017 primes", "-1O4", et, apres conversion des tirets,
#       "-104.2" ecrit avec U+2013 ou le signe moins U+2212) ;
#  exception a (b) et (b') (avis d'actuary, #95) : une etiquette d'exercice de
#  la forme AAAA-AA a AAAA-AAAA ("2017-18", "2017-2018", et leurs variantes
#  au tiret U+2013 ou U+2014) n'est pas refusee.
# "x", "a2017", "S1", "LoB12" ou "TRUE" restent admis. Comparaisons faites
# octet par octet (useBytes, motifs ASCII), sans conversion d'encodage : aucune
# erreur sur une cellule non UTF-8 lue en locale UTF-8, que usp_lire_vecteur()
# lui transmet depuis l'issue #99 (.nettoyer_cellules()). Les espaces
# insecables sont remplacees par une espace, les tirets U+2013, U+2014 et le
# signe moins U+2212 par "-", et les points de suspension U+2026 par ".", sur
# les octets bruts, en UTF-8 (C2 A0, E2 80 AF, E2 80 93, E2 80 94, E2 88 92,
# E2 80 A6) comme en Windows-1252 (A0, 96, 97, 85 ; ces octets isoles
# n'apparaissent en UTF-8 valide qu'apres
# un octet de tete, qui n'est pas remplace et exclut alors (a3)) : un
# litteral "\u00a0" dans gsub() donnait, sous une locale Windows-1252, un
# resultat qui changeait entre le premier appel et les suivants (mesure du
# 26/09/2026, R 4.3.1).
.allure_manquante_ou_nombre <- function(cel) {
  # Remplace chaque sequence de trois octets b3 par l'octet par.
  sub3 <- function(r, b3, par) {
    n <- length(r)
    if (n < 3) return(r)
    i <- which(r[1:(n - 2)] == b3[1] & r[2:(n - 1)] == b3[2] & r[3:n] == b3[3])
    if (length(i)) { r[i] <- par; r <- r[-c(i + 1L, i + 2L)] }
    r
  }
  # Une seule forme convertie x3, sur laquelle toutes les regles sont
  # evaluees, exception AAAA-AA(AA) comprise.
  octets <- function(s) {
    if (is.na(s)) return(NA_character_)
    r <- charToRaw(s)
    # U+202F (E2 80 AF) -> une espace
    r <- sub3(r, as.raw(c(0xe2, 0x80, 0xaf)), as.raw(0x20))
    suivant <- c(r[-1], as.raw(0))
    r <- r[!(r == as.raw(0xc2) & suivant == as.raw(0xa0))]
    r[r == as.raw(0xa0)] <- as.raw(0x20)
    # U+2013, U+2014, U+2212 -> "-" ; U+2026 -> "." ; puis Windows-1252 96, 97, 85
    r <- sub3(r, as.raw(c(0xe2, 0x80, 0x93)), as.raw(0x2d))
    r <- sub3(r, as.raw(c(0xe2, 0x80, 0x94)), as.raw(0x2d))
    r <- sub3(r, as.raw(c(0xe2, 0x88, 0x92)), as.raw(0x2d))
    r <- sub3(r, as.raw(c(0xe2, 0x80, 0xa6)), as.raw(0x2e))
    r[r == as.raw(0x96) | r == as.raw(0x97)] <- as.raw(0x2d)
    r[r == as.raw(0x85)] <- as.raw(0x2e)
    rawToChar(r)
  }
  x3 <- vapply(cel, octets, character(1), USE.NAMES = FALSE)
  x3 <- sub(" +$", "", sub("^ +", "", x3, useBytes = TRUE), useBytes = TRUE)
  a <- grepl(paste0("^(NA|NAN|N/A|N\\.A\\.|N\\.A|N\\.D\\.|N\\.D|ND|N/D|NR|N\\.R\\.|NULL|NONE|",
                    "S\\.O\\.|S\\.O|S/O|NIL|N\\.C\\.|N\\.C|NC|N/C)$"),
             x3, ignore.case = TRUE, useBytes = TRUE) |
    grepl("^#", x3, useBytes = TRUE) |
    grepl("^[-.?]+$", x3, useBytes = TRUE)
  b <- (grepl("^[0-9 .,'+-]*[0-9][0-9 .,'+-]*$", x3, useBytes = TRUE) |
          grepl("^ *'? *[+-]? *[0-9]", x3, useBytes = TRUE)) &
    !grepl("^[0-9]{4}-[0-9]{2,4}$", x3, useBytes = TRUE)
  unname(!is.na(cel) & (a | b))
}

# Premiere de deux lignes lue comme une ligne d'annees (motif H2 de
# usp_lire_vecteur(), issue #103, regle commune d'actuary du 28/09/2026) :
# ses cellules non vides, hors la cellule d'angle, sont des entiers a quatre
# chiffres (ecriture ^[0-9]{4}$) compris entre 1900 et 2100, au nombre de deux
# au moins, consecutifs (de 1 en 1, tous croissants ou tous decroissants). La
# cellule d'angle est la premiere cellule quand elle est vide, ou un libelle
# non numerique sans aucun chiffre et hors .allure_manquante_ou_nombre()
# ("annee", "exercice") ; une premiere cellule numerique est une annee comme
# les autres. Une premiere cellule ni angle ni numerique ("2016r", "2016*",
# "a2016", "NA", "Segment 1") fait refuser la ligne (cause "premiere cellule
# ni vide ni libelle sans chiffre") : prise pour une cellule d'angle, elle
# ferait ecarter comme etiquette la valeur au-dessous, et perdre une annee
# sans message (audit de #103). Les bornes et la consecutivite gardent refuses
# "1,2,3" / "4,5,6" (tableau numerique, pas d'aplatissement), les annees a
# deux chiffres et les annees non consecutives. Rend ok, angle (vrai si la
# premiere cellule est une cellule d'angle) et, si ok est faux, la premiere
# cause rencontree, reprise dans le message "Format non reconnu". val (seconde
# ligne) ne sert qu'a nommer le cas de deux lignes numeriques.
.ligne_annees <- function(ent, val, dec = ".") {
  en_nombre <- function(v) .cellules_en_nombre(v, dec)
  angle <- !nzchar(ent[1]) ||
    (is.na(en_nombre(ent[1])) && !.allure_manquante_ou_nombre(ent[1]) &&
       !grepl("[0-9]", ent[1], useBytes = TRUE))
  a <- if (angle) ent[-1] else ent
  a <- a[nzchar(a)]
  cause <- if (!angle && is.na(en_nombre(ent[1]))) {
    "premiere cellule ni vide ni libelle sans chiffre"
  } else if (!length(a)) {
    "aucune annee hors la premiere cellule"
  } else if (anyNA(en_nombre(a))) {
    "cellules numeriques melees a du texte"
  } else if (!all(grepl("^[0-9]{4}$", a, useBytes = TRUE))) {
    v <- val[nzchar(val)]
    if (length(v) && !anyNA(en_nombre(v)))
      "deux lignes numeriques, la premiere sans annees a quatre chiffres"
    else "cellules numeriques qui ne sont pas des annees a quatre chiffres"
  } else {
    n <- as.integer(a)
    d <- diff(n)
    if (any(n < 1900 | n > 2100)) "annees hors 1900-2100"
    else if (length(n) < 2) "une seule annee"
    else if (!(all(d == 1) || all(d == -1))) "entiers non consecutifs"
    else NA_character_
  }
  list(ok = is.na(cause), angle = angle, cause = cause)
}

# Retire la marque d'ordre des octets UTF-8 du premier nom de colonne d'un
# tableau lu par read.csv (header = TRUE) hors locale UTF-8, sous ses formes
# mesurees sur R 4.3.1 (Windows) : BOM brut EF BB BF (check.names = FALSE) ;
# "X..." sous LC_CTYPE = C (make.names remplace chaque octet par un point et
# prefixe X) ; octets EF 2E 2E sous une locale Windows-1252 (le premier octet
# y est une lettre, les deux suivants deviennent des points). La forme
# "X.U.FEFF." (make.names sur le caractere U+FEFF) est aussi reconnue, non
# observee sur ce poste. Le prefixe n'est retire que s'il reste un nom
# (issue #96).
.nom_sans_bom <- function(n) {
  if (!length(n) || is.na(n)) return(n)
  n <- .sans_bom(n)
  r <- charToRaw(n)
  for (p in list(as.raw(c(0xef, 0x2e, 0x2e)), charToRaw("X.U.FEFF."), charToRaw("X..."))) {
    k <- length(p)
    if (length(r) > k && identical(r[seq_len(k)], p)) return(rawToChar(r[-seq_len(k)]))
  }
  n
}

usp_charger <- function(fichier_x, fichier_y, T = NULL, plus_recent_en_dernier = TRUE,
                        sep = ",", dec = ".") {
  x <- usp_lire_vecteur(fichier_x, sep, dec)
  y <- usp_lire_vecteur(fichier_y, sep, dec)
  if (length(x) != length(y))
    stop("x (", length(x), ") et y (", length(y), ") n'ont pas la meme longueur.")
  if (!plus_recent_en_dernier) { x <- rev(x); y <- rev(y) }
  n <- length(x)
  if (!is.null(T)) {
    # T entier scalaire fini, 1 <= T <= n (issue #87 : un T non entier
    # tronquait la serie en silence) ; la duree minimale de 5 ans est
    # controlee par engine_valider_donnees().
    err_T <- engine_valider_profondeur(T, n, T_min = 1)
    if (length(err_T)) stop(err_T)
    idx <- (n - T + 1):n                     # on garde les T annees les plus recentes
    x <- x[idx]; y <- y[idx]
  }
  list(x = x, y = y, T = length(x))
}

# Plage plausible du ratio y/x (issue #145) : [RATIO_PLAUSIBLE_MIN ;
# RATIO_PLAUSIBLE_MAX[. Conventions de l'outil, SANS source reglementaire :
# un ratio hors de la plage signale une erreur d'unite probable (selon
# l'issue, facteurs 10 a 1000 dans les deux sens pour des ratios usuels ;
# seuil bas 0,1 retenu par le mainteneur le 28/09/2026, borne haute 5
# inchangee). Lues par
# l'avertissement de engine_valider_donnees() ET par la ligne A
# "Plausibilite du ratio y/x" de usp_controle_donnees() ; aucun refus n'en
# depend.
RATIO_PLAUSIBLE_MIN <- 0.1
RATIO_PLAUSIBLE_MAX <- 5

# Domaine numerique des montants (issue #145, specification du 02/10/2026) :
# toute valeur de la serie retenue hors de [DOMAINE_NUMERIQUE_MIN ;
# DOMAINE_NUMERIQUE_MAX], bornes incluses, est REFUSEE par
# engine_valider_donnees() (ok = FALSE, motif explicite), afin que le
# defaut de calcul intercepte (#88) ne soit plus le mode d'arret sur des
# donnees a l'echelle extreme. Le domaine est tres large devant tout
# montant monetaire et tres interieur a la plage hors de laquelle le
# moteur rendait ok = TRUE avec des verdicts faux (environ [1e-155 ;
# 1e151], mesure de la specification de #145, de l'ordre de
# sqrt(DBL_MIN) = 1,5e-154 et sqrt(DBL_MAX) = 1,3e154).
# sigma_USP et les tests etant invariants par un changement d'unite commun
# a xt et yt (et a delta_equiv s'il est fourni), le refus n'ote rien :
# il suffit de changer d'unite. Noms neutres vis-a-vis de la methode : les
# controles du triangle de Merz-Wuthrich les reprendront (#185).
DOMAINE_NUMERIQUE_MIN <- 1e-50
DOMAINE_NUMERIQUE_MAX <- 1e50

# Controles de qualite (famille A). Verdict OK / ECHEC sans niveau alpha.
# Un controle qui ne peut pas etre etabli (valeur manquante, serie vide) vaut
# ECHEC, jamais un jugement sur les seules valeurs disponibles, et son detail
# le dit au lieu d'imprimer NA comme un nombre ; sous T = 5, la ligne de
# credibilite sort ECHEC sans appeler le bareme, qui n'y est pas defini
# (issue #33, avis d'actuary du 24/09/2026). run_engine() valide en amont :
# ces cas ne s'y presentent pas.
# bareme / segment / annexe (issue #131) : bareme de credibilite applique,
# resolu comme dans run_engine() (bareme saisi s'il est fourni, sinon bareme
# du segment, sinon "court" par convention) ; run_engine() transmet le
# bareme saisi (NULL sinon), le segment et l'annexe de l'appel. Sans ces
# arguments, la ligne de credibilite lit le bareme court par convention.
usp_controle_donnees <- function(x, y, alpha = 0.10, bareme = NULL, segment = NULL,
                                 annexe = "II") {
  T <- length(x)
  res <- list()
  add <- function(nom, ok, detail) res[[length(res) + 1]] <<-
    list(famille = "A. Qualite des donnees", test = nom,
         stat = NA_real_, p = NA_real_, verdict = if (isTRUE(ok)) "OK" else "ECHEC",
         detail = detail)
  non_etabli <- "controle non etabli : valeur(s) manquante(s)"
  etabli <- function(...) all(vapply(list(...), function(v) length(v) > 0 && !anyNA(v), logical(1)))

  add("Profondeur minimale (annexe XVII, B/C(2)(b))", T >= 5,
      sprintf("T = %d annee(s) consecutive(s) ; minimum reglementaire = 5", T))
  add("Absence de valeurs manquantes", !any(is.na(c(x, y))),
      sprintf("%d NA detecte(s)", sum(is.na(c(x, y)))))
  add("Strict positivite de x_t", etabli(x) && all(x > 0),
      if (etabli(x)) sprintf("min(x) = %.6g", min(x)) else non_etabli)
  add("Strict positivite de y_t (requise par la lognormale)", etabli(y) && all(y > 0),
      if (etabli(y)) sprintf("min(y) = %.6g", min(y)) else non_etabli)
  if (etabli(x, y) && length(x) == length(y)) {
    dup <- sum(duplicated(data.frame(x, y)))
    add("Absence de doublons parfaits", dup == 0,
        sprintf("%d couple(s) (x,y) duplique(s)", dup))
    ratio <- y / x
    add("Plausibilite du ratio y/x",
        all(ratio >= RATIO_PLAUSIBLE_MIN & ratio < RATIO_PLAUSIBLE_MAX),
        sprintf("min = %.3f ; median = %.3f ; max = %.3f",
                min(ratio), stats::median(ratio), max(ratio)))
  } else {
    motif <- if (etabli(x, y)) "controle non etabli : x et y de longueurs differentes"
             else non_etabli
    add("Absence de doublons parfaits", FALSE, motif)
    add("Plausibilite du ratio y/x", FALSE, motif)
  }
  if (etabli(x)) {
    amp <- max(x) / min(x)
    add("Amplitude du volume (stabilite du perimetre)", amp < 10,
        sprintf("max(x)/min(x) = %.2f ; une amplitude elevee signale une rupture de perimetre", amp))
  } else add("Amplitude du volume (stabilite du perimetre)", FALSE, non_etabli)
  # Credibilite pleine (issue #131) : c(T, bareme applique) == 1, sous le
  # bareme qui entre dans sigma_USP (.engine_credibilite_appliquee()) ;
  # T >= 10 la donnait atteinte des T = 10 sur les segments du bareme long
  # G(1), qui ne l'atteignent qu'a T = 15.
  if (T >= 5) {
    cr <- .engine_credibilite_appliquee(T, bareme, segment, annexe)
    add("Credibilite pleine atteinte", cr$pleine,
        sprintf("T = %d ; c = %.0f%% ; %s ; credibilite pleine a partir de T = %d",
                T, 100 * cr$c, cr$libelle, cr$pleine_a))
  } else add("Credibilite pleine atteinte", FALSE,
             sprintf("T = %d ; bareme non defini sous T = 5 (annexe XVII, section G)", T))
  res
}


## =============================================================================
## 2. NOYAU DE CALCUL (annexe XVII, sections B et C, paragraphes 3 à 6)
## =============================================================================

# pi_t(delta, gamma) = 1 / ln( 1 + e^{2 gamma} * ( delta + (1-delta) * xbar / x_t ) )
usp_pi <- function(delta, gamma, x, xbar = mean(x)) {
  1 / log1p(exp(2 * gamma) * (delta + (1 - delta) * xbar / x))
}

# Toutes les quantités du modèle pour un couple (delta, gamma) donné.
usp_noyau <- function(delta, gamma, x, y, xbar = mean(x)) {
  T <- length(x)
  p <- usp_pi(delta, gamma, x, xbar)
  r <- log(y / x)
  # ln(beta) : fraction de l'exposant de sigma(delta, gamma), annexe XVII,
  # sections B et C, paragraphe 5 (beta n'est pas nomme par le texte ;
  # estimateur MV du niveau)
  ln_beta <- (T / 2 + sum(p * r)) / sum(p)
  v <- r + 1 / (2 * p) - ln_beta            # residus bruts (loi normale, var = 1/pi_t)
  list(
    pi      = p,
    ln_beta = ln_beta,
    beta    = exp(ln_beta),                 # ratio S/P moyen implicite
    v       = v,
    z       = v * sqrt(p),                  # residus standardises ~ N(0,1)
    sigma   = exp(gamma + ln_beta),         # fonction d'ecart-type sigma(delta, gamma)
    obj     = sum(p * v^2) - sum(log(p))    # -2 log-vraisemblance (a une constante pres)
  )
}

usp_objectif <- function(par, x, y, xbar) {
  d <- par[1]; g <- par[2]
  if (!is.finite(d) || !is.finite(g) || d < 0 || d > 1) return(1e12)
  o <- usp_noyau(d, g, x, y, xbar)$obj
  if (!is.finite(o)) 1e12 else o
}

# Gradient analytique de l'objectif profile O(delta, gamma) = usp_noyau()$obj
# (issue #22). ln(beta) etant le minimiseur de O a (delta, gamma) fixes (forme
# fermee de usp_noyau(), dO/d ln(beta) = -2 somme(pi_t v_t) = 0), la derivee
# totale se reduit a la derivee partielle a ln(beta) fixe (theoreme de
# l'enveloppe) :
#   dO/dpi_t = s_t / pi_t,  s_t = z_t^2 - 1 - z_t / sqrt(pi_t),
#   pi_t = 1 / ln(1 + e a_t),  a_t = delta + (1 - delta) xbar / x_t,
#   e = exp(2 gamma), d'ou
#   g_delta = somme(-pi_t e (1 - xbar / x_t) / (1 + e a_t) s_t),
#   g_gamma = somme(-pi_t 2 e a_t / (1 + e a_t) s_t).
# A pi_t constant (delta = 1 ou volumes constants), somme(z_t) = 0 et
# g_gamma = w (somme(z_t^2) - T), w = -pi 2 e a / (1 + e a) ; a volumes
# constants, g_delta = 0 (delta non identifie). Verifie contre la
# difference centree de usp_noyau()$obj (tests/unitaires/
# test_controles_numeriques.R).
usp_gradient <- function(delta, gamma, x, y, xbar = mean(x)) {
  k <- usp_noyau(delta, gamma, x, y, xbar)
  e <- exp(2 * gamma)
  a <- delta + (1 - delta) * xbar / x
  s <- k$z^2 - 1 - k$z / sqrt(k$pi)
  c(delta = sum(-k$pi * e * (1 - xbar / x) / (1 + e * a) * s),
    gamma = sum(-k$pi * 2 * e * a / (1 + e * a) * s))
}

# Gradient de l'objectif sous la forme attendue par stats::optim() (argument
# gr, issue #63, decision du mainteneur du 28/09/2026) : usp_gradient() au
# point par = c(delta, gamma). Passe a optim() dans usp_ajuster() et
# usp_ajuster_rapide(), il remplace la difference centree par defaut
# d'optim() (ndeps = 1e-3), dont le biais ~ -h^2/3 sur gamma fixait le
# plancher de precision de l'ajustement (~3,4e-7). La ou usp_objectif() rend
# sa penalite constante 1e12 (objectif non fini), le gradient rendu est nul,
# celui de cette penalite : le chemin de l'issue #33 (erreur explicite de
# usp_ajuster() quand l'objectif n'est fini en aucun point visite) est
# conserve. Un gradient non fini a objectif fini fait echouer optim()
# (erreur interceptee par try() dans les deux appelants).
usp_gradient_optim <- function(par, x, y, xbar) {
  g <- usp_gradient(par[1], par[2], x, y, xbar)
  if (all(is.finite(g)) || !identical(usp_objectif(par, x, y, xbar), 1e12)) g
  else c(delta = 0, gamma = 0)
}

# Gradient analytique de ln(sigma(delta, gamma)), sigma = usp_noyau()$sigma
# (issue #71, specification d'actuary du 28/09/2026, formule (b)).
# sigma = exp(gamma + ln(beta)), ln(beta) = (T/2 + somme(pi_t r_t)) /
# somme(pi_t), r_t = ln(y_t / x_t), d'ou
#   d ln(beta) / d theta = somme(d pi_t / d theta (r_t - ln(beta))) / somme(pi_t),
#   d pi_t / d gamma = -pi_t^2 2 e a_t / (1 + e a_t),
#   d pi_t / d delta = -pi_t^2 e (1 - xbar / x_t) / (1 + e a_t),
# avec a_t = delta + (1 - delta) xbar / x_t et e = exp(2 gamma) ; puis
# d ln(sigma) / d delta = d ln(beta) / d delta,
# d ln(sigma) / d gamma = 1 + d ln(beta) / d gamma.
# A pi_t constant : d ln(sigma) / d gamma = 1 + e / (1 + e) a delta = 1.
usp_grad_ln_sigma <- function(delta, gamma, x, y, xbar = mean(x)) {
  k <- usp_noyau(delta, gamma, x, y, xbar)
  e <- exp(2 * gamma)
  a <- delta + (1 - delta) * xbar / x
  r <- log(y / x)
  sp <- sum(k$pi)
  dp_g <- -k$pi^2 * 2 * e * a / (1 + e * a)
  dp_d <- -k$pi^2 * e * (1 - xbar / x) / (1 + e * a)
  c(delta = sum(dp_d * (r - k$ln_beta)) / sp,
    gamma = 1 + sum(dp_g * (r - k$ln_beta)) / sp)
}

# Hessienne 2 x 2 de l'objectif profile O(delta, gamma) (issue #71,
# specification d'actuary, formule (a)) : differences centrees du gradient
# analytique usp_gradient(), pas h dans les deux directions, symetrisee.
# H_gamma_gamma est identique au bit pres a l'ancien champ hessien_gamma
# (memes deux evaluations). Evaluer en delta +- h hors de [0, 1] est licite :
# a_t est affine en delta et reste > 0 tant que max(xbar / x_t, x_t / xbar)
# < 1 / h ; si un point decale donne un gradient non fini, les elements qui
# en dependent valent NA (anomalie "courbure non finie" du controle).
usp_hessienne <- function(delta, gamma, x, y, xbar = mean(x), h = 1e-4) {
  gp_g <- usp_gradient(delta, gamma + h, x, y, xbar)
  gm_g <- usp_gradient(delta, gamma - h, x, y, xbar)
  gp_d <- usp_gradient(delta + h, gamma, x, y, xbar)
  gm_d <- usp_gradient(delta - h, gamma, x, y, xbar)
  fini <- function(v) if (is.finite(v)) v else NA_real_
  h_gg <- fini((gp_g[["gamma"]] - gm_g[["gamma"]]) / (2 * h))
  h_dd <- fini((gp_d[["delta"]] - gm_d[["delta"]]) / (2 * h))
  h_dg <- fini(0.5 * ((gp_g[["delta"]] - gm_g[["delta"]]) / (2 * h) +
                      (gp_d[["gamma"]] - gm_d[["gamma"]]) / (2 * h)))
  matrix(c(h_dd, h_dg, h_dg, h_gg), 2, 2,
         dimnames = list(c("delta", "gamma"), c("delta", "gamma")))
}

# Variables libres et definie positivite de la sous-hessienne H_F (issue
# #71, specification d'actuary, formule (c) et (d)). gamma est toujours
# libre ; delta l'est si et seulement si les volumes ne sont pas constants
# et pg_delta est fini et non nul (a l'interieur toujours ; au bord
# seulement si le gradient pousse vers l'interieur) : le controle reste
# continu a la bascule du bord (M16).
# volumes_constants : usp_volumes_constants(x), predicat unique de
# usp_regime() (tolerance TOL_DELTA_BORD ; reprise de #71 apres audit, avis
# d'actuary du 29/09/2026). A volumes constants, delta n'est pas identifie
# (#58) : g_delta n'y est qu'un bruit d'arrondi et H_delta_delta ~ 1e-25,
# de sorte que det(H) prenait un signe aleatoire (mesure d'audit : 23 jeux
# sur 40 d'etendue relative 1e-15 a 1e-13 rendaient "courbure non
# strictement positive" et stat = NA). delta n'y est donc jamais libre.
# L'exception ne s'etend pas a pi_t constant a volumes variables (delta = 1),
# ou delta est identifie.
# def_pos : NA si un element de H_F n'est pas fini ; sinon H_gamma_gamma > 0
# (F = {gamma}) ou H_gamma_gamma > 0 et det(H) > 0 (F = {delta, gamma},
# critere de Sylvester).
usp_hessienne_libre <- function(H, pg, volumes_constants = FALSE) {
  libre_delta <- !isTRUE(volumes_constants) &&
    isTRUE(is.finite(pg[["delta"]]) && pg[["delta"]] != 0)
  hf <- if (libre_delta) as.vector(H) else H["gamma", "gamma"]
  def_pos <- if (!all(is.finite(hf))) NA
    else if (libre_delta) H["gamma", "gamma"] > 0 &&
      H["delta", "delta"] * H["gamma", "gamma"] - H["delta", "gamma"]^2 > 0
    else H["gamma", "gamma"] > 0
  list(libre_delta = libre_delta, def_pos = def_pos)
}

# Pas de Newton complet sur les variables libres, ecrete aux bornes de delta,
# et erreur relative de premier ordre sur sigma (issue #71, specification
# d'actuary, formules (c) a (e)). Fonction pure de H (usp_hessienne()), du
# gradient projete pg, de delta et de grad_ln_sigma (usp_grad_ln_sigma()).
#   - F = {gamma} : pas = (0, -pg_gamma / H_gamma_gamma) ;
#   - F = {delta, gamma} : pas libre -H^{-1} pg ; si delta + pas_delta sort
#     de [0, 1], ecretage : pas_delta = b - delta (b la borne franchie), puis
#     pas_gamma = -(pg_gamma + H_gamma_delta pas_delta) / H_gamma_gamma
#     (minimiseur du modele quadratique convexe sur la face delta = b ;
#     Nocedal et Wright 2006, chap. 16, projection du gradient) ;
#   - erreur_sigma = somme sur F de d ln(sigma) / d theta_i * pas_i.
# Pas, erreur_sigma et pas_ecrete valent NA si pg n'est pas fini ou si H_F
# n'est pas finie et definie positive. volumes_constants : voir
# usp_hessienne_libre() (delta jamais libre a volumes constants).
usp_pas_newton_borne <- function(H, pg, delta, grad_ln_sigma, volumes_constants = FALSE) {
  lib <- usp_hessienne_libre(H, pg, volumes_constants)
  na <- list(pas = c(delta = NA_real_, gamma = NA_real_), erreur_sigma = NA_real_,
             pas_ecrete = NA, libre_delta = lib$libre_delta, def_pos = lib$def_pos)
  if (!all(is.finite(pg)) || !isTRUE(lib$def_pos)) return(na)
  ecrete <- FALSE
  if (!lib$libre_delta) {
    pas <- c(delta = 0, gamma = -pg[["gamma"]] / H["gamma", "gamma"])
    err <- grad_ln_sigma[["gamma"]] * pas[["gamma"]]
  } else {
    # Inverse 2 x 2 ecrite explicitement (det > 0 par Sylvester) : solve()
    # levait une erreur ("system is computationally singular") a volumes
    # quasi constants, ou H_delta_delta ~ 1e-20 (mesure du 29/09/2026 sur
    # tests/unitaires/test_volumes_constants.R) ; le pas en delta, fini mais
    # tres grand (~1e10), y est ecrete a la borne ci-dessous.
    det <- H["delta", "delta"] * H["gamma", "gamma"] - H["delta", "gamma"]^2
    pas <- c(delta = -(H["gamma", "gamma"] * pg[["delta"]] - H["delta", "gamma"] * pg[["gamma"]]) / det,
             gamma = -(H["delta", "delta"] * pg[["gamma"]] - H["delta", "gamma"] * pg[["delta"]]) / det)
    if (delta + pas[["delta"]] < 0 || delta + pas[["delta"]] > 1) {
      b <- if (delta + pas[["delta"]] < 0) 0 else 1
      pas[["delta"]] <- b - delta
      pas[["gamma"]] <- -(pg[["gamma"]] + H["gamma", "delta"] * pas[["delta"]]) /
        H["gamma", "gamma"]
      ecrete <- TRUE
    }
    err <- grad_ln_sigma[["delta"]] * pas[["delta"]] +
      grad_ln_sigma[["gamma"]] * pas[["gamma"]]
  }
  if (!all(is.finite(c(pas, err)))) return(na)
  list(pas = pas, erreur_sigma = err, pas_ecrete = ecrete,
       libre_delta = lib$libre_delta, def_pos = lib$def_pos)
}

# Condition du premier ordre (Kuhn-Tucker) au point (delta, gamma), issues
# #22 et #71 :
#   - gradient : usp_gradient() ;
#   - gradient_projete : composante annulee si elle pousse hors du domaine au
#     bord (borne inferieure : min(g, 0) ; borne superieure : max(g, 0)),
#     inchangee a l'interieur. Bord jugee a TOL_DELTA_BORD pres, pour delta
#     dans [0, 1] comme pour gamma dans BORNES_GAMMA ;
#   - hessienne : usp_hessienne() (pas h) ; H_gamma_gamma est
#     hessienne["gamma", "gamma"] ;
#   - grad_ln_sigma : usp_grad_ln_sigma() ;
#   - pas_newton, erreur_sigma, pas_ecrete : usp_pas_newton_borne() ; le pas
#     en gamma est pas_newton[["gamma"]]. NA si la sous-hessienne des
#     variables libres n'est pas finie et definie positive, si le gradient
#     n'est pas fini, ou si gamma est sur une borne numerique (le pas n'y a
#     pas de sens : le maximum de vraisemblance n'est pas atteint).
# Les valeurs sont du bruit d'optimiseur (dependant de la plateforme) : elles
# ne sont restituees que dans des champs numeriques, jamais dans un libelle.
usp_condition_premier_ordre <- function(delta, gamma, x, y, xbar = mean(x),
                                        tol = TOL_DELTA_BORD, h = 1e-4) {
  g <- usp_gradient(delta, gamma, x, y, xbar)
  projeter <- function(gi, v, bas, haut) {
    if (!is.finite(gi)) gi
    else if (v <= bas + tol) min(gi, 0)
    else if (v >= haut - tol) max(gi, 0)
    else gi
  }
  pg <- c(delta = projeter(g[["delta"]], delta, 0, 1),
          gamma = projeter(g[["gamma"]], gamma, BORNES_GAMMA[1], BORNES_GAMMA[2]))
  H <- usp_hessienne(delta, gamma, x, y, xbar, h)
  gls <- usp_grad_ln_sigma(delta, gamma, x, y, xbar)
  gamma_bord <- !is.finite(gamma) || gamma <= BORNES_GAMMA[1] + tol ||
    gamma >= BORNES_GAMMA[2] - tol
  pn <- usp_pas_newton_borne(H, pg, delta, gls, usp_volumes_constants(x))
  if (gamma_bord) {
    pn$pas[] <- NA_real_; pn$erreur_sigma <- NA_real_; pn$pas_ecrete <- NA
  }
  list(gradient = g, gradient_projete = pg, hessienne = H, grad_ln_sigma = gls,
       pas_newton = pn$pas, erreur_sigma = pn$erreur_sigma, pas_ecrete = pn$pas_ecrete)
}

# Decision de Kuhn-Tucker pour UN demarrage (issue #22, decision du mainteneur
# du 24/09/2026 ; issue #71, decision du mainteneur du 28/09/2026 ;
# specifications d'actuary) : fonction pure de
# cpo = usp_condition_premier_ordre(delta_s, gamma_s, ...) et de gamma_s.
# TRUE si et seulement si, sur ce MEME point : gradient et gradient projete
# finis, gamma_s hors des bornes numeriques BORNES_GAMMA (a TOL_DELTA_BORD
# pres), sous-hessienne des variables libres finie et definie positive
# (usp_hessienne_libre(), volumes_constants = usp_volumes_constants(x) du
# jeu ajuste), pas de Newton fini, |erreur_sigma| <= rep_sigma et
# |pg_delta| <= rep_gd. Reperes par defaut REP_SIGMA_KKT (1e-6, ancre sur
# M9, #71) et REP_GD_KKT (1e-4, regle unique au bord comme a l'interieur,
# M16), definis en tete du moteur ; le libelle de usp_controles_numeriques()
# ne les imprime pas (issue #76) : la regle et ses reperes sont dans la fiche
# du .tex.
usp_kkt_satisfaite <- function(cpo, gamma, rep_sigma = REP_SIGMA_KKT, rep_gd = REP_GD_KKT,
                               volumes_constants = FALSE) {
  gamma_bord <- !is.finite(gamma) || gamma <= BORNES_GAMMA[1] + TOL_DELTA_BORD ||
    gamma >= BORNES_GAMMA[2] - TOL_DELTA_BORD
  grad_fini <- isTRUE(all(is.finite(c(cpo$gradient, cpo$gradient_projete))))
  grad_fini && !gamma_bord &&
    isTRUE(usp_hessienne_libre(cpo$hessienne, cpo$gradient_projete, volumes_constants)$def_pos) &&
    isTRUE(all(is.finite(cpo$pas_newton))) &&
    isTRUE(is.finite(cpo$erreur_sigma) && abs(cpo$erreur_sigma) <= rep_sigma) &&
    isTRUE(abs(cpo$gradient_projete[["delta"]]) <= rep_gd)
}

# Minimisation sous contrainte 0 <= delta <= 1 (annexe XVII, sections B et C,
# paragraphe 6),
# avec démarrages multiples pour éviter les optima locaux.
# controle : parametres de stats::optim() ; la valeur par defaut est celle
# du calcul. Un autre reglage ne sert qu'aux tests (ajustement deliberement
# non converge, issue #22).
# Gradient analytique passe a optim() (usp_gradient_optim(), issue #63) et
# factr = 1e2 (1e5 avant #63, divise par 1000 ; sans pgtol, inoperant a
# factr non nul ; decision du mainteneur du 28/09/2026 sur la mesure de coder
# et l'avis d'actuary, commentaires de #63). Le gradient seul supprime le
# biais de la difference centree (ndeps = 1e-3) mais laisse une queue de
# points d'arret limitee par factr au-dessus de 1e-6 en |Delta gamma| ;
# factr / 1000 la ramene sous 1e-7 (mesure de coder, 1 051 jeux simules,
# graine 20260924 : maximum 9,1e-8). En contrepartie, davantage de
# demarrages rendent le code 52 d'optim() au point deja atteint (bruit
# d'arrondi a factr * eps = 2,2e-14 en relatif) ; la regle "au moins un
# demarrage a l'optimum au code 0" du controle multi-demarrages est
# maintenue (decision du mainteneur du 28/09/2026).
usp_ajuster <- function(x, y, n_starts_delta = 9, verbose = FALSE,
                        controle = list(factr = 1e2, maxit = 500)) {
  xbar <- mean(x)
  grille_d <- seq(0, 1, length.out = n_starts_delta)
  grille_g <- log(c(0.01, 0.03, 0.06, 0.10, 0.20, 0.40))
  starts <- expand.grid(delta = grille_d, gamma = grille_g)
  best <- NULL
  vals <- rep(NA_real_, nrow(starts))
  codes <- rep(NA_integer_, nrow(starts))
  pars <- matrix(NA_real_, nrow(starts), 2)
  for (i in seq_len(nrow(starts))) {
    fit <- try(stats::optim(
      par = c(starts$delta[i], starts$gamma[i]),
      fn = usp_objectif, gr = usp_gradient_optim, x = x, y = y, xbar = xbar,
      method = "L-BFGS-B",
      lower = c(0, BORNES_GAMMA[1]), upper = c(1, BORNES_GAMMA[2]),
      control = controle), silent = TRUE)
    if (inherits(fit, "try-error")) next
    vals[i] <- fit$value
    codes[i] <- fit$convergence
    pars[i, ] <- fit$par
    # La marge 1e-10 retient le PREMIER demarrage a l'optimum en cas
    # d'egalite : elle stabilise gamma estime entre plateformes (ne pas la
    # modifier, decision du mainteneur, issue #22).
    if (is.null(best) || fit$value < best$value - 1e-10) best <- fit
  }
  if (is.null(best)) stop("Echec de l'optimisation (annexe XVII, sections B et C, paragraphe 6).")

  # Controle de convergence multi-demarrages (issue #22), mesure sur la meme
  # grille (aucune reoptimisation redondante) : nombre de demarrages
  # atteignant l'objectif minimal a TOL_OPTIMUM (1e-6) pres, parmi eux ceux
  # qui rendent le code 0 (precision de M11 : le code du seul demarrage retenu ne decide
  # pas ; mesure d'audit, le premier demarrage a l'optimum peut rendre 52
  # quand 53 autres, a 1,9e-12 pres, rendent 0), demarrages sans resultat
  # (erreur d'optim()), et part kappa parmi les demarrages aboutis.
  a_optimum <- abs(vals - best$value) < TOL_OPTIMUM
  part_convergents <- mean(a_optimum, na.rm = TRUE)
  n_optimum <- sum(a_optimum, na.rm = TRUE)
  n_optimum_code0 <- sum(a_optimum & codes == 0L, na.rm = TRUE)
  n_echec <- sum(is.na(vals))
  # Condition de Kuhn-Tucker jugee sur CHAQUE demarrage a l'optimum (meme
  # ensemble a_optimum que ci-dessus, aucune deuxieme notion d'optimum) :
  # le controle est reussi si au moins un demarrage la satisfait (regle
  # alignee sur M15, decision du mainteneur du 24/09/2026, issue #22). Le
  # verdict ne depend plus du demarrage retenu, departage par l'ordre de la
  # grille et variable selon la plateforme. Tous les demarrages sont evalues
  # (pas d'arret au premier succes, qui reintroduirait un ordre).
  idx <- which(!is.na(vals) & a_optimum)
  vol_cst <- usp_volumes_constants(x)
  kkt_ok <- vapply(idx, function(i) usp_kkt_satisfaite(
    usp_condition_premier_ordre(pars[i, 1], pars[i, 2], x, y, xbar), pars[i, 2],
    volumes_constants = vol_cst),
    logical(1))

  d <- best$par[1]; g <- best$par[2]
  k <- usp_noyau(d, g, x, y, xbar)
  # Objectif non fini au point retenu : usp_objectif() y rend la penalite
  # 1e12, et comme toute valeur finie lui serait preferee, il n'est fini en
  # aucun point visite (valeur infinie dans x ou y, par exemple). Erreur
  # explicite plutot qu'un sigma = Inf rendu comme un optimum (issue #33).
  if (!is.finite(k$obj))
    stop("Echec de l'optimisation (annexe XVII, sections B et C, paragraphe 6) : ",
         "l'objectif n'est fini en aucun ",
         "point visite ; verifier que x et y sont finis et strictement positifs.")
  # Condition du premier ordre (issue #22) : gradient analytique de l'objectif
  # profile, projete sur les bornes. L'ancienne grandeur
  # |somme(pi_t v_t)| / somme(pi_t) etait une identite de la forme fermee de
  # ln(beta), nulle pour tout couple (delta, gamma) : elle ne controlait pas
  # la convergence et a ete retiree.
  cpo <- usp_condition_premier_ordre(d, g, x, y, xbar)
  c(k, list(delta = d, gamma = g, T = length(x), x = x, y = y, xbar = xbar,
            gradient = cpo$gradient, gradient_projete = cpo$gradient_projete,
            # Champs de #71 (hessienne, grad_ln_sigma, pas_newton, erreur_sigma,
            # pas_ecrete), qui remplacent hessien_gamma et pas_newton_gamma
            # (decision du mainteneur du 28/09/2026, Q71-2) : ceux de
            # usp_condition_premier_ordre() au demarrage retenu.
            hessienne = cpo$hessienne, grad_ln_sigma = cpo$grad_ln_sigma,
            pas_newton = cpo$pas_newton, erreur_sigma = cpo$erreur_sigma,
            pas_ecrete = cpo$pas_ecrete,
            obj_min = best$value, convergence = best$convergence,
            part_starts_convergents = part_convergents,
            n_starts_optimum = n_optimum, n_starts_optimum_code0 = n_optimum_code0,
            n_starts_echec = n_echec,
            delta_au_bord = usp_regime(d, x)$delta_au_bord,
            # En DERNIERE position (patch chirurgical des references, voir
            # run_engine()).
            kkt_au_moins_un = any(kkt_ok)))
}

# Controles numeriques de l'estimation lognormale (issue #22, decision M11 du
# mainteneur) : condition du premier ordre et convergence multi-demarrages.
# Ce ne sont pas des tests statistiques : ils figurent dans res$controles
# (famille "H."), au format de usp_controle_donnees(), avec une semantique
# OK / ECHEC, et ne sont PAS bloquants (un ECHEC est restitue, le calcul est
# produit, comme "Credibilite pleine atteinte").
# Regle de stabilite inter-plateformes : le detail ne contient aucune valeur
# d'optimiseur (g, pg, H, pas de Newton, objectifs) ; ces valeurs sont dans
# les champs numeriques de fit (res$ajustement) et dans stat. Libelles
# concis (issue #76, textes retenus par le mainteneur) : y figurent
# seulement le respect de la regle (oui / non), les particularites du
# demarrage retenu (volumes constants, gradient non fini, courbure, gamma
# sur une borne) et des entiers stables (demarrages a l'optimum, sans
# resultat) ; la regle et ses reperes sont dans les fiches du .tex.
usp_controles_numeriques <- function(fit) {
  fam <- "H. Controles numeriques de l'estimation"
  res <- list()
  add <- function(nom, ok, stat, detail) res[[length(res) + 1]] <<-
    list(famille = fam, test = nom, stat = as.double(stat), p = NA_real_,
         verdict = if (ok) "OK" else "ECHEC", detail = detail)

  # --- Condition du premier ordre (KKT) -------------------------------------
  # Regle (decision du mainteneur du 24/09/2026, issue #22, constat 4 de la
  # revue finale d'audit ; specification d'actuary) : reussi si AU MOINS UN
  # demarrage a l'optimum (objectif a moins de TOL_OPTIMUM du minimum, meme ensemble
  # que M15) satisfait les conditions sur le MEME point
  # (usp_kkt_satisfaite()) ; decision calculee dans usp_ajuster()
  # (fit$kkt_au_moins_un). L'ancienne regle jugeait le seul demarrage
  # retenu, departage par l'ordre de la grille : mesure d'actuary (200 jeux
  # simules a delta interieur, graine 20260924, Linux, R 4.3.3), 2 faux
  # ECHEC sur 200 (|Delta gamma| du retenu 1,24e-6 et 1,39e-6), 0 sur 200
  # avec la nouvelle regle (max sur les jeux de min_s |Delta gamma_s| =
  # 1,96e-7).
  # Reperes (constantes REP_SIGMA_KKT et REP_GD_KKT, en tete du moteur, lues
  # par usp_kkt_satisfaite()) : |erreur_sigma| <= 1e-6, erreur relative de
  # premier ordre sur sigma qu'impliquerait le pas de Newton complet sur les
  # variables libres, ecrete aux bornes de delta (issue #71, decision du
  # mainteneur du 28/09/2026, qui remplace le repere de M17 sur le pas en
  # gamma a delta fixe, aveugle au terme croise H_delta_gamma) ; ancre sur
  # M9 (tolerance de non-regression 1e-6). |pg_delta| <= 1e-4, REGLE UNIQUE
  # au bord comme a l'interieur (decision du mainteneur apres audit : exiger
  # pg_delta = 0 au bord creait une discontinuite ; maintenue par #71).
  # Libelle concis (issue #76, textes retenus par le mainteneur, retouches
  # du 24/09/2026, inchanges par #71) : le respect de la regle (oui / non),
  # puis, s'il y a lieu, la phrase "Volumes constants : delta non
  # identifie.", puis UNE phrase "Demarrage retenu : " reunissant, separees
  # par " ; " et dans cet ordre, les anomalies du demarrage retenu :
  # gradient non fini, courbure (« non finie » si un element de la
  # sous-hessienne H_F des variables libres n'est pas fini, « non strictement
  # positive » si H_F est finie et non definie positive, critere de
  # Sylvester ; usp_hessienne_libre()), gamma sur une borne. La courbure
  # n'est pas mentionnee quand gamma est sur une borne (pas de Newton non
  # defini dans les deux cas). Ni repere, ni valeur d'optimiseur, ni
  # mention de l'ecretage : la regle, les reperes et leur justification sont
  # dans la fiche du .tex ; les valeurs du demarrage retenu dans
  # res$ajustement (gradient, gradient_projete, hessienne, grad_ln_sigma,
  # pas_newton, erreur_sigma, pas_ecrete) ; stat est l'erreur_sigma du
  # demarrage retenu (grandeur jugee, relative sur sigma ; NA si gamma est
  # sur une borne).
  g <- fit$gradient; pg <- fit$gradient_projete
  grad_fini <- all(is.finite(c(g, pg)))
  gamma_bord <- !is.finite(fit$gamma) ||
    fit$gamma <= BORNES_GAMMA[1] + TOL_DELTA_BORD || fit$gamma >= BORNES_GAMMA[2] - TOL_DELTA_BORD
  def_pos <- usp_hessienne_libre(fit$hessienne, pg, usp_volumes_constants(fit$x))$def_pos
  ok <- isTRUE(fit$kkt_au_moins_un)
  # Volumes constants (#58) : pi_t ne depend pas de delta, g_delta = 0 et
  # delta n'est pas identifie ; la valeur rendue par l'optimiseur (souvent 0)
  # est un artefact, que le libelle ne presente pas comme un bord.
  vol_cst <- isTRUE(usp_regime(fit$delta, fit$x)$volumes_constants)
  anomalies <- c(if (!grad_fini) "gradient non fini",
                 if (!gamma_bord && is.na(def_pos)) "courbure non finie",
                 if (!gamma_bord && isFALSE(def_pos)) "courbure non strictement positive",
                 if (gamma_bord) "gamma sur une borne")
  add("Condition du premier ordre (gradient projete, KKT)", ok, fit$erreur_sigma,
      paste(c(sprintf("Condition KKT verifiee par au moins un demarrage a l'optimum : %s.",
                      if (ok) "oui" else "non"),
              if (vol_cst) "Volumes constants : delta non identifie.",
              if (length(anomalies))
                paste0("Demarrage retenu : ", paste(anomalies, collapse = " ; "), ".")),
            collapse = " "))

  # --- Convergence multi-demarrages ------------------------------------------
  # Precision de M11 (decision du mainteneur apres audit) : reussi si au
  # moins UN demarrage a l'optimum (objectif a moins de TOL_OPTIMUM du
  # minimum) rend le code 0 et si au moins deux demarrages atteignent
  # l'optimum. Le detail n'imprime ni le NOMBRE de demarrages a l'optimum
  # au code 0 (decision du mainteneur, 23/09/2026) ni le CODE du demarrage
  # retenu (decision du mainteneur, 24/09/2026, issue #22) : l'un et l'autre
  # dependent du chemin d'optimisation. Un demarrage bascule entre les codes
  # 0 et 52 selon la machine (mesure : 52 a 54 demarrages au code 0 sur 101
  # perturbations relatives de 1e-12 des donnees de test, contre 54
  # demarrages a l'optimum dans tous les cas) ; le demarrage retenu est le
  # premier a moins de 1e-10 de l'objectif, departage par l'ordre de la
  # grille, et peut rendre 52 quand d'autres rendent 0 (cas d'audit 176 de
  # tests/unitaires/test_controles_numeriques.R). Sont imprimes (libelle
  # concis, issue #76) : le nombre de demarrages a l'optimum, le respect de
  # la condition sur le code 0 (oui / non ; « au code 0 » sans « au moins
  # un » quand un seul demarrage est a l'optimum) et, s'il est non nul, le nombre
  # de demarrages sans resultat (erreur d'optim()) ; ces deux entiers sont
  # compares aux references de non-regression. Les valeurs restent dans
  # res$ajustement (n_starts_optimum_code0, convergence) ; stat = part kappa
  # des demarrages aboutis a l'optimum, grandeur descriptive sans repere.
  n_opt <- as.integer(fit$n_starts_optimum)
  n_opt0 <- fit$n_starts_optimum_code0
  n_echec <- as.integer(fit$n_starts_echec)
  ok_m <- isTRUE(n_opt0 >= 1) && isTRUE(n_opt >= 2)
  add("Convergence multi-demarrages", ok_m, fit$part_starts_convergents,
      paste(c(sprintf("%s : %s.",
                      if (identical(n_opt, 1L)) "1 seul demarrage a l'optimum ; au code 0 d'optim()"
                      else sprintf("%d demarrages a l'optimum ; au moins un au code 0 d'optim()", n_opt),
                      if (isTRUE(n_opt0 >= 1)) "oui" else "non"),
              if (isTRUE(n_echec > 0L))
                sprintf("%d demarrage%s sans resultat.", n_echec, if (n_echec > 1L) "s" else "")),
            collapse = " "))
  res
}

# Volumes constants (issue #59, regle R11 de la specification commune #44 /
# #70 / #59) : SEULE definition du moteur, en relatif a la moyenne, a la
# tolerance de bord TOL_DELTA_BORD (CONTEXT.md "Volumes constants"). Lue par
# usp_regime() et par toute fonction qui regresse sur x ou partitionne par x
# (test_lm_complet(), test_intercept(), test_tost_intercept(), test_reset(),
# tests d'heteroscedasticite, Smirnov, Spearman ratio / volume, QQ-plot a deux
# echantillons) : aucune garde numerique sd(x) == 0 ne subsiste. Une garde
# exacte laissait passer les volumes quasi constants (etendue relative de
# 1e-12 a 2e-7), ou lm(y ~ x) ecarte x pour colinearite (erreur R dans
# test_lm_complet()) ou calcule sur le bruit d'arrondi.
usp_volumes_constants <- function(x, tol = TOL_DELTA_BORD)
  diff(range(x)) <= tol * mean(x)

# Nombre de volumes distincts k (issue #110) : les regressions auxiliaires
# polynomiales de degre 2 en x (RESET {x, x^2, x^3}, White {1, x, x^2}) sont
# de rang min(k, 3) ; a k < 3, test_reset() et test_white() sont non
# applicables. Deux volumes sont confondus s'ils sont ex aequo au sens de la
# definition partagee (engine_aplatir_ex_aequo(), TOL_EX_AEQUO, issue #112) :
# volumes egaux a 1e-12 relatif pres comptent pour un. Tolerance purement
# relative (.usp_aplatir_volumes(), plancher 0) : invariance d'unite de
# test_reset() et test_white() conservee (#110).
.usp_nb_volumes_distincts <- function(x) length(unique(.usp_aplatir_volumes(x)))

# Regime de l'ajustement lognormal (issue #31), fonction pure de (delta, x).
# pi_t = 1 / ln(1 + e^{2 gamma} (delta + (1 - delta) xbar / x_t)) est constant
# en t si et seulement si delta = 1 ou les volumes x_t sont constants : le
# drapeau pi_constant porte donc sur cette CAUSE, avec la tolerance unique
# TOL_DELTA_BORD, et non sur l'etendue observee des pi_t (seuil distinct qui
# laissait une zone "delta au bord mais pi_t non constant" pour delta dans
# (1 - 1e-6 ; 1 - 3,9e-9) sur les volumes du cas de test). delta au bord 0
# avec des volumes variables ne rend PAS pi_t constant.
# Signature (delta, x) plutot que (fit) : la fonction sert aussi dans
# usp_ajuster(), avant que l'objet fit n'existe, et se teste sans ajustement.
# Rien n'est ajoute a fit (stocke dans res$ajustement, structure des
# references de non-regression).
# pi_constant_exact distingue, parmi les cas pi_constant, la constance EXACTE
# (delta == 1, ou volumes rigoureusement egaux) de la constance a la
# tolerance pres. Dans le premier cas pi_t est le meme nombre flottant pour
# tout t (delta + 0 * xbar / x_t = 1, ou xbar / x_t identique en t) et
# moyenne(z) = 0 tient a la precision machine ; dans la bande de tolerance,
# non (mesure, donnees de test, gamma annulant exactement la derivee en
# gamma : moyenne(z) = 3,6e-3 * (1 - delta) et somme(z_t^2) - T =
# 2,7e-3 * (1 - delta) pour 1 - delta de 1e-8 a 1e-6 ; a delta = 0,37 et
# volumes d'etendue relative e de 2e-8 a 2e-7 : moyenne(z) = -3,0e-3 * e,
# somme(z_t^2) - T = 1,4e-3 * e ; -2,0e-16 et 1,8e-15 a la constance exacte).
# Les coefficients dependent des donnees ; seul l'ordre (1 - delta), ou e,
# est general. pi_constant_exact n'est lu que pour le libelle des diagnostics
# de usp_tests().
usp_regime <- function(delta, x, tol = TOL_DELTA_BORD) {
  delta_au_bord <- delta <= tol || delta >= 1 - tol
  volumes_constants <- usp_volumes_constants(x, tol)
  list(delta_au_bord = delta_au_bord,
       volumes_constants = volumes_constants,
       pi_constant = delta >= 1 - tol || volumes_constants,
       pi_constant_exact = delta == 1 || diff(range(x)) == 0,
       # Causes de la constance a la tolerance pres seulement (libelle des
       # diagnostics de usp_tests(), seule definition de la bande).
       delta_dans_bande = delta >= 1 - tol && delta != 1,
       volumes_dans_bande = volumes_constants && diff(range(x)) != 0)
}

# Paramètre propre final :
# sigma_USP = c * sigma(delta, gamma) * sqrt((T+1)/(T-1)) + (1 - c) * sigma_standard
usp_parametre <- function(fit, sigma_standard, bareme = "court") {
  T <- fit$T
  cred <- usp_credibilite(T, bareme)
  corr <- sqrt((T + 1) / (T - 1))
  sigma_ech <- fit$sigma * corr
  list(
    sigma_estime_brut   = fit$sigma,
    correction_taille   = corr,
    sigma_estime        = sigma_ech,
    credibilite         = cred,
    sigma_standard      = sigma_standard,
    sigma_usp           = cred * sigma_ech + (1 - cred) * sigma_standard,
    variation_relative  = (cred * sigma_ech + (1 - cred) * sigma_standard) / sigma_standard - 1
  )
}


## =============================================================================
## 3. STATISTIQUES DE TEST (implémentations base R, références citées)
## =============================================================================

.p_borne <- function(p) if (!is.finite(p)) NA_real_ else max(min(p, 1), 0)

# shapiro.test() leve une erreur si toutes les valeurs sont identiques ;
# encapsulation indispensable car cette fonction est appelee dans la boucle
# de bootstrap, ou une replication degeneree interromprait tout le calcul.
.shapiro_sur <- function(z) {
  r <- try(stats::shapiro.test(z), silent = TRUE)
  if (inherits(r, "try-error"))
    list(stat = NA_real_, p = NA_real_)
  else list(stat = unname(r$statistic), p = r$p.value)
}

# --- Normalité ---------------------------------------------------------------

# Anderson & Darling (1954), "A test of goodness of fit", JASA 49, 765-769.
stat_ad <- function(z) {
  z <- sort(z); n <- length(z)
  p <- stats::pnorm(z)
  p <- pmin(pmax(p, 1e-12), 1 - 1e-12)
  -n - mean((2 * seq_len(n) - 1) * (log(p) + log(1 - rev(p))))
}

# Cramér (1928) / von Mises (1931) ; forme de Stephens (1974), JASA 69, 730-737.
stat_cvm <- function(z) {
  z <- sort(z); n <- length(z)
  p <- stats::pnorm(z)
  1 / (12 * n) + sum((p - (2 * seq_len(n) - 1) / (2 * n))^2)
}

# p-value analytique d'Anderson-Darling, cas 3 (moyenne et variance estimees),
# approximations par morceaux de D'Agostino & Stephens (1986),
# Goodness-of-Fit Techniques, Marcel Dekker, tableau 4.9.
# Ce sont des ajustements empiriques, non un resultat exact : la p-value est
# fournie a titre de p-value NON simulee, la p-value de Monte-Carlo restant
# calculee en parallele.
# Plage : NA pour n < 8, comme l'implementation de reference nortest::ad.test
# (n > 7) ; la plage annoncee par la table 4.9 elle-meme n'a pas ete verifiee
# sur l'ouvrage (#44, regle R6, avis d'actuary Q6). Meme garde pour
# cvm_p_stephens().
ad_p_stephens <- function(A2, n) {
  if (!is.finite(A2) || n < 8) return(NA_real_)
  a <- A2 * (1 + 0.75 / n + 2.25 / n^2)
  p <- if (a < 0.200)      1 - exp(-13.436 + 101.14 * a - 223.73 * a^2)
       else if (a < 0.340) 1 - exp(-8.318 + 42.796 * a - 59.938 * a^2)
       else if (a < 0.600) exp(0.9177 - 4.279 * a - 1.38 * a^2)
       else if (a < 13)    exp(1.2937 - 5.709 * a + 0.0186 * a^2)
       else                0
  .p_borne(p)
}

# p-value analytique de Cramer-von Mises, cas 3, memes sources.
cvm_p_stephens <- function(W2, n) {
  if (!is.finite(W2) || n < 8) return(NA_real_)
  w <- W2 * (1 + 0.5 / n)
  p <- if (w < 0.0275)      1 - exp(-13.953 + 775.5 * w - 12542.61 * w^2)
       else if (w < 0.051)  1 - exp(-5.903 + 179.546 * w - 1515.29 * w^2)
       else if (w < 0.092)  exp(0.886 - 31.62 * w + 10.897 * w^2)
       else if (w < 1.1)    exp(1.111 - 34.242 * w + 12.832 * w^2)
       else                 7.37e-10
  .p_borne(p)
}

# --- Test de Lilliefors (1967) ----------------------------------------------
# Distinct du Kolmogorov-Smirnov contre N(0,1) deja present : ici la moyenne et
# l'ecart-type sont ESTIMES sur l'echantillon, ce qui est la situation reelle.
# La loi de reference n'est plus celle de Kolmogorov mais celle de Lilliefors,
# stochastiquement plus concentree.
stat_lilliefors <- function(z) {
  n <- length(z); m <- mean(z); s <- stats::sd(z)
  if (!is.finite(s) || s == 0) return(NA_real_)
  p <- stats::pnorm(sort((z - m) / s))
  max(pmax((1:n) / n - p, p - (0:(n - 1)) / n))
}

# p-value de Lilliefors : approximation de Dallal & Wilkinson (1986),
# The American Statistician 40(4), 294-296, prolongee au-dela de 0,10 par les
# polynomes de Stephens (1974). Meme implementation que nortest::lillie.test.
lillie_p <- function(D, n) {
  if (!is.finite(D) || n < 5) return(NA_real_)
  if (n <= 100) { Kd <- D; nd <- n } else { Kd <- D * (n / 100)^0.49; nd <- 100 }
  p <- exp(-7.01256 * Kd^2 * (nd + 2.78019) +
             2.99587 * Kd * sqrt(nd + 2.78019) - 0.122119 +
             0.974598 / sqrt(nd) + 1.67997 / nd)
  if (p > 0.1) {
    KK <- (sqrt(n) - 0.01 + 0.85 / sqrt(n)) * D
    p <- if (KK <= 0.302) 1
         else if (KK <= 0.5)  2.76773 - 19.828315 * KK + 80.709644 * KK^2 -
                              138.55152 * KK^3 + 81.218052 * KK^4
         else if (KK <= 0.9)  -4.901232 + 40.662806 * KK - 97.490286 * KK^2 +
                              94.029866 * KK^3 - 32.355711 * KK^4
         else if (KK <= 1.31) 6.198765 - 19.558097 * KK + 23.186922 * KK^2 -
                              12.234627 * KK^3 + 2.423045 * KK^4
         else 0
  }
  .p_borne(p)
}

# --- Execution sous graine locale (ADR 0004, issue #42) ----------------------
# Fonction unique par laquelle passe toute simulation du moteur
# (usp_bootstrap(), usp_lr_delta(), mw_bootstrap(), sw_loi_nulle()).
# Sauvegarde .Random.seed de l'environnement global (ou note son absence),
# pose la graine, evalue expr (evaluation differee : l'expression est evaluee
# dans l'environnement de l'appelant, apres set.seed()), puis restaure l'etat
# initial, ou retire .Random.seed s'il n'existait pas, y compris en cas
# d'erreur (on.exit). Le flux tire a l'interieur de expr est celui de
# set.seed(seed) : memes tirages qu'un set.seed(seed) suivi de expr.
#
# Generateur fixe (issue #37) : la graine est posee sous le generateur
# ENGINE_RNG_KIND, quel que soit RNGkind() chez l'appelant, et le reglage de
# l'appelant (RNGkind() comme .Random.seed) est restaure en sortie. Sans
# cela, un appelant sous RNGkind("L'Ecuyer-CMRG") ou sample.kind = "Rounding"
# obtenait d'autres tirages a graine egale (mesure de l'issue #37). Sous le
# reglage par defaut de R (celui de ENGINE_RNG_KIND), les tirages sont ceux
# de set.seed(seed). RNGkind() en simple lecture ne cree pas .Random.seed ;
# le reposer en sortie en cree un, retire ensuite s'il n'existait pas.
# Limite (preexistante) : sous normal.kind = "Box-Muller" chez l'appelant, R
# garde en reserve, hors .Random.seed, le second tirage normal de chaque
# paire ; cette reserve n'est pas restauree (R l'efface quand le generateur
# est repose), de sorte que le prochain rnorm() de l'appelant peut differer
# de celui qu'il aurait obtenu sans l'appel. Sans effet sur les resultats du
# moteur, qui tire toujours sous Inversion (ENGINE_RNG_KIND).
ENGINE_RNG_KIND <- c(kind = "Mersenne-Twister", normal.kind = "Inversion",
                     sample.kind = "Rejection")
# Graine fixe des simulations autres que le bootstrap (ADR 0004, point 2),
# consignee dans res$metadata : loi nulle de Shapiro-Wilk (sw_loi_nulle()).
# L'enveloppe du QQ-plot n'a plus de graine propre depuis l'issue #47 : elle
# est lue dans les replications de usp_bootstrap() (graine seed).
SEED_LOI_NULLE_SW <- 20260901
engine_sous_graine <- function(seed, expr) {
  genv <- globalenv()
  existait <- exists(".Random.seed", envir = genv, inherits = FALSE)
  avant <- if (existait) get(".Random.seed", envir = genv, inherits = FALSE) else NULL
  kind_avant <- RNGkind()
  on.exit({
    # sample.kind = "Rounding" emet un avertissement a chaque pose : le
    # reglage de l'appelant est repose tel quel, sans le repeter.
    suppressWarnings(RNGkind(kind = kind_avant[1], normal.kind = kind_avant[2],
                             sample.kind = kind_avant[3]))
    if (existait) assign(".Random.seed", avant, envir = genv)
    else if (exists(".Random.seed", envir = genv, inherits = FALSE))
      rm(".Random.seed", envir = genv)
  }, add = TRUE)
  set.seed(seed, kind = ENGINE_RNG_KIND[["kind"]],
           normal.kind = ENGINE_RNG_KIND[["normal.kind"]],
           sample.kind = ENGINE_RNG_KIND[["sample.kind"]])
  expr
}

# --- Shapiro-Wilk SANS la normalisation de Royston --------------------------
# shapiro.test() calcule W puis en tire une p-value par la transformation
# normalisante de Royston (1992), qui est un ajustement empirique. On propose
# ici une p-value obtenue par simulation directe de la LOI NULLE de W pour des
# echantillons normaux de meme taille. Cette loi ne depend d'aucun parametre
# (W est invariant par translation et par changement d'echelle), donc la
# simulation est independante du modele USP ajuste : ce n'est PAS un bootstrap
# parametrique, mais une evaluation numerique de la loi exacte de W sous H0.
# Le resultat est exact a l'erreur de Monte-Carlo pres, en 1/sqrt(B_null).
# Cle du cache : taille, nombre de tirages, graine et generateur (issue #37).
# Le generateur est celui que pose engine_sous_graine() (ENGINE_RNG_KIND), et
# non celui de l'appelant : la loi servie ne depend plus du RNGkind() actif
# au premier appel de la session ; le generateur figure dans la cle pour
# qu'une loi calculee sous un autre generateur ne puisse pas etre servie.
.cache_sw <- new.env(parent = emptyenv())
sw_cle_cache <- function(n, B_null, seed, kind = ENGINE_RNG_KIND)
  paste0("n", n, "_B", B_null, "_s", seed, "_", paste(kind, collapse = "/"))
sw_loi_nulle <- function(n, B_null = 20000, seed = SEED_LOI_NULLE_SW) {
  cle <- sw_cle_cache(n, B_null, seed)
  if (!is.null(.cache_sw[[cle]])) return(.cache_sw[[cle]])
  # Graine propre (SEED_LOI_NULLE_SW par defaut), etat de l'appelant restaure
  w <- engine_sous_graine(seed, replicate(B_null, {
    r <- try(stats::shapiro.test(stats::rnorm(n))$statistic, silent = TRUE)
    if (inherits(r, "try-error")) NA_real_ else unname(r)
  }))
  w <- sort(w[is.finite(w)])
  .cache_sw[[cle]] <- w
  w
}
sw_p_loi_nulle <- function(W, n, B_null = 20000) {
  if (!is.finite(W) || n < 3) return(NA_real_)
  w <- sw_loi_nulle(n, B_null)
  if (!length(w)) return(NA_real_)
  .p_borne((1 + sum(w <= W)) / (length(w) + 1))   # rejet en queue basse
}

# Kolmogorov (1933) - Smirnov (1948), version Lilliefors (1967) JASA 62, 399-402.
stat_ks <- function(z) {
  z <- sort(z); n <- length(z)
  p <- stats::pnorm(z)
  max(pmax(seq_len(n) / n - p, p - (seq_len(n) - 1) / n))
}

# Shapiro & Francia (1972), JASA 67, 215-216 ; p-value Royston (1993) Appl. Stat.
test_shapiro_francia <- function(z) {
  n <- length(z)
  if (n < 5 || n > 5000) return(list(stat = NA_real_, p = NA_real_))
  m <- stats::qnorm(stats::ppoints(n, a = 3/8))
  W <- stats::cor(sort(z), m)^2
  u <- log(n); v <- log(u)
  mu <- -1.2725 + 1.0521 * (v - u)
  sg <- 1.0308 - 0.26758 * (v + 2 / u)
  p <- 1 - stats::pnorm((log(1 - W) - mu) / sg)
  list(stat = W, p = .p_borne(p))
}

# Jarque & Bera (1980), Economics Letters 6, 255-259.
test_jarque_bera <- function(z) {
  n <- length(z); m <- mean(z)
  s <- mean((z - m)^3) / mean((z - m)^2)^1.5
  k <- mean((z - m)^4) / mean((z - m)^2)^2
  JB <- n / 6 * (s^2 + (k - 3)^2 / 4)
  list(stat = JB, p = .p_borne(1 - stats::pchisq(JB, 2)), skew = s, kurt = k)
}

# D'Agostino (1970), Biometrika 57, 679-681 (asymetrie).
test_dagostino_skew <- function(z) {
  n <- length(z)
  if (n < 8) return(list(stat = NA_real_, p = NA_real_))
  m <- mean(z); b1 <- mean((z - m)^3) / mean((z - m)^2)^1.5
  Y <- b1 * sqrt((n + 1) * (n + 3) / (6 * (n - 2)))
  b2 <- 3 * (n^2 + 27 * n - 70) * (n + 1) * (n + 3) /
        ((n - 2) * (n + 5) * (n + 7) * (n + 9))
  W2 <- -1 + sqrt(2 * (b2 - 1)); W <- sqrt(W2)
  del <- 1 / sqrt(log(W)); alp <- sqrt(2 / (W2 - 1))
  Z <- del * log(Y / alp + sqrt((Y / alp)^2 + 1))
  list(stat = Z, p = .p_borne(2 * (1 - stats::pnorm(abs(Z)))))
}

# Anscombe & Glynn (1983), Biometrika 70, 227-234 (aplatissement).
test_anscombe_kurt <- function(z) {
  n <- length(z)
  if (n < 20) return(list(stat = NA_real_, p = NA_real_))
  m <- mean(z); b2 <- mean((z - m)^4) / mean((z - m)^2)^2
  Eb2 <- 3 * (n - 1) / (n + 1)
  vb2 <- 24 * n * (n - 2) * (n - 3) / ((n + 1)^2 * (n + 3) * (n + 5))
  xx <- (b2 - Eb2) / sqrt(vb2)
  sb1 <- 6 * (n^2 - 5 * n + 2) / ((n + 7) * (n + 9)) *
         sqrt(6 * (n + 3) * (n + 5) / (n * (n - 2) * (n - 3)))
  A <- 6 + 8 / sb1 * (2 / sb1 + sqrt(1 + 4 / sb1^2))
  Z <- ((1 - 2 / (9 * A)) -
        ((1 - 2 / A) / (1 + xx * sqrt(2 / (A - 4))))^(1/3)) / sqrt(2 / (9 * A))
  list(stat = Z, p = .p_borne(2 * (1 - stats::pnorm(abs(Z)))))
}

# --- Indépendance / structure temporelle -------------------------------------

# Durbin & Watson (1950, 1951), Biometrika 37 et 38.
# CORRECTION : la statistique est definie sur des residus de MOYENNE NULLE (les
# residus MCO le sont par construction). Nos z_t sont contraints par
# sum(sqrt(pi_t) z_t) = 0 mais pas par sum(z_t) = 0 : sans centrage, le
# denominateur est gonfle de T*mean(z)^2 et DW est biaisee vers le bas. On
# centre donc explicitement, ce qui rend aussi la statistique coherente avec
# l'autocorrelation utilisee par Box.test().
stat_dw <- function(z) {
  zc <- z - mean(z)
  sum(diff(zc)^2) / sum(zc^2)
}

# Loi EXACTE de DW sous H0 : z ~ N(0, sigma^2 I).
# DW = z'Az / z'z avec A la matrice des differences secondes, dont les valeurs
# propres sont connues analytiquement : lambda_j = 2(1 - cos(pi j / n)),
# j = 0, ..., n-1 (verification numerique faite). On a donc
#     P(DW <= c) = P( z'(A - cI)z <= 0 )
# soit la queue d'une forme quadratique en variables normales, calculable
# exactement par la methode d'Imhof (1961), Biometrika 48, 419-426 :
#     P(Q > 0) = 1/2 + (1/pi) * integrale_0^inf sin(theta(u)) / (u rho(u)) du
# (Imhof 1961, P(Q > x) en x = 0 ; le signe "-" des versions anterieures
# rendait P(Q < 0), sans effet sur la p bilaterale, issue #33).
# Aucune approximation asymptotique n'intervient ; les bornes d_L/d_U de
# Durbin-Watson, etablies pour des residus MCO, ne sont pas utilisees.
.imhof_p_sup0 <- function(h) {
  integrand <- function(u) {
    theta <- 0.5 * colSums(atan(outer(h, u)))
    rho   <- exp(0.25 * colSums(log1p(outer(h^2, u^2))))
    sin(theta) / (u * rho)
  }
  v <- try(stats::integrate(integrand, 0, Inf, subdivisions = 2000L,
                            rel.tol = 1e-10)$value, silent = TRUE)
  if (inherits(v, "try-error")) return(NA_real_)
  min(max(0.5 + v / pi, 0), 1)
}

# p-value bilaterale exacte de Durbin-Watson (centrage compris : le centrage
# retire une dimension, on travaille sur les n-1 valeurs propres non nulles de
# A restreintes au sous-espace orthogonal au vecteur constant).
dw_p_exacte <- function(z) {
  n <- length(z)
  if (n < 4) return(NA_real_)
  d <- stat_dw(z)
  # matrice des differences secondes projetee sur le complement du vecteur 1
  A <- diag(c(1, rep(2, n - 2), 1))
  for (i in 1:(n - 1)) { A[i, i + 1] <- -1; A[i + 1, i] <- -1 }
  M <- diag(n) - matrix(1 / n, n, n)          # projecteur de centrage
  lam <- eigen(M %*% A %*% M, symmetric = TRUE, only.values = TRUE)$values
  lam <- sort(lam, decreasing = TRUE)[1:(n - 1)]   # on ecarte la valeur nulle
  # Q = z'(A - dI)z : P(Q > 0) = P(DW > d)
  p_sup <- .imhof_p_sup0(lam - d)
  if (!is.finite(p_sup)) return(NA_real_)
  .p_borne(2 * min(p_sup, 1 - p_sup))
}

# Wald & Wolfowitz (1940), Ann. Math. Statist. 11, 147-162 (test des suites).
# Ex aequo (#112) : z aplati a TOL_EX_AEQUO, une valeur a la tolerance de la
# mediane est ecartee comme une valeur egale.
test_runs <- function(z) {
  z <- engine_aplatir_ex_aequo(z)
  s <- sign(z - stats::median(z)); s <- s[s != 0]
  n <- length(s); n1 <- sum(s > 0); n2 <- sum(s < 0)
  if (n1 == 0 || n2 == 0) return(list(stat = NA_real_, p = NA_real_, runs = NA))
  R <- 1 + sum(diff(s) != 0)
  E <- 2 * n1 * n2 / n + 1
  V <- 2 * n1 * n2 * (2 * n1 * n2 - n) / (n^2 * (n - 1))
  Z <- (R - E) / sqrt(V)
  list(stat = Z, p = .p_borne(2 * (1 - stats::pnorm(abs(Z)))), runs = R)
}

# Cox & Stuart (1955), Biometrika 42, 80-95 (test de tendance par signes).
# n_p = n - ceiling(n / 2) paires (valeur centrale ecartee si n impair). Les
# differences nulles sont ecartees : m est le nombre de differences non nulles
# (m <= n_p) et, sous H0, K ~ Binomiale(m, 1/2) conditionnellement a m (#85).
# Difference nulle a la tolerance TOL_EX_AEQUO (#112) : v est aplati en tete ;
# la difference de deux flottants distincts n'etant jamais nulle, d != 0 suit
# alors exactement la definition partagee de l'ex aequo.
test_cox_stuart <- function(v) {
  v <- engine_aplatir_ex_aequo(v)
  n <- length(v); c0 <- ceiling(n / 2)
  d <- v[(c0 + 1):n] - v[1:(n - c0)]
  n_p <- length(d)
  d <- d[d != 0]
  m <- length(d)
  if (!m) return(list(stat = NA_real_, p = NA_real_, m = 0L, n_p = n_p))
  k <- sum(d > 0)
  list(stat = k, p = .p_borne(stats::binom.test(k, m, 0.5)$p.value),
       m = m, n_p = n_p)
}

# --- Lois EXACTES sous H0 (disponibles aux petites tailles, donc a T = 8) ----

# Distribution exacte du S de Kendall par la distribution mahonienne du nombre
# d'inversions : la fonction generatrice du nombre d'inversions d'une
# permutation de n elements est prod_{k=1}^{n} (1 + q + ... + q^{k-1})
# (Kendall & Gibbons, 1990, Rank Correlation Methods, 5e ed., ch. 4-5).
# Avec S = n(n-1)/2 - 2*inv, on en deduit la loi exacte de S sous H0.
.mk_loi_exacte <- function(n) {
  if (n < 2 || n > 12) return(NULL)          # au-dela : cout combinatoire inutile
  poly <- 1
  for (k in 2:n) poly <- .poly_mult(poly, rep(1, k))
  inv <- 0:(length(poly) - 1)
  list(S = n * (n - 1) / 2 - 2 * inv, prob = poly / sum(poly))
}
.poly_mult <- function(a, b) {
  r <- numeric(length(a) + length(b) - 1)
  for (i in seq_along(a)) r[i:(i + length(b) - 1)] <- r[i:(i + length(b) - 1)] + a[i] * b
  r
}

# p-value bilaterale exacte du test de Mann-Kendall (sans ex aequo).
# Ex aequo a la tolerance TOL_EX_AEQUO (#112) : v aplati en tete.
mk_p_exacte <- function(v) {
  v <- engine_aplatir_ex_aequo(v)
  n <- length(v)
  if (anyDuplicated(v) > 0) return(NA_real_)   # loi exacte invalide avec ex aequo
  d <- .mk_loi_exacte(n)
  if (is.null(d)) return(NA_real_)
  Sobs <- sum(vapply(1:(n - 1), function(i) sum(sign(v[(i + 1):n] - v[i])), numeric(1)))
  .p_borne(sum(d$prob[abs(d$S) >= abs(Sobs) - 1e-9]))
}

# Loi exacte du nombre de suites R (Wald-Wolfowitz), tabulee par
# Swed & Eisenhart (1943), Ann. Math. Statist. 14, 66-87.
#   P(R = 2k)   = 2 C(n1-1, k-1) C(n2-1, k-1) / C(n, n1)
#   P(R = 2k+1) = [C(n1-1,k) C(n2-1,k-1) + C(n1-1,k-1) C(n2-1,k)] / C(n, n1)
.runs_dens <- function(n1, n2) {
  n <- n1 + n2; rr <- 2:n; pr <- numeric(length(rr))
  for (idx in seq_along(rr)) {
    R <- rr[idx]
    if (R %% 2 == 0) {
      k <- R / 2
      pr[idx] <- 2 * choose(n1 - 1, k - 1) * choose(n2 - 1, k - 1)
    } else {
      k <- (R - 1) / 2
      pr[idx] <- choose(n1 - 1, k) * choose(n2 - 1, k - 1) +
                 choose(n1 - 1, k - 1) * choose(n2 - 1, k)
    }
  }
  list(R = rr, prob = pr / choose(n, n1))
}

# p-value bilaterale exacte du test des suites, convention du DOUBLEMENT
# (issue #29, decision M8 ; Gibbons & Pratt, 1975, Amer. Statist. 29, 20-25) :
#     p = min(1, 2 min(P(R <= R_obs), P(R >= R_obs)))
# C'est la convention du bootstrap (queue = "deux" dans usp_bootstrap()) et
# des autres lois exactes du moteur (dw_p_exacte(), mk_p_exacte()) : la p
# exacte et la p Monte-Carlo d'une meme ligne estiment la meme quantite.
# Elle remplace la methode de la densite (somme des probabilites des issues
# au plus aussi probables que l'observee), qui donnait p = 1 pour tout R
# modal. A T = 8 (n1 = n2 = 4), valeurs atteignables : 1 (R = 5), 52/70
# (R = 4, 6), 16/70 (R = 3, 7), 4/70 (R = 2, 8) ; a T = 5 (n1 = n2 = 2) :
# 2/3 (R = 2, 4), 1 (R = 3).
runs_p_exacte <- function(z) {
  z <- engine_aplatir_ex_aequo(z)             # ex aequo a la tolerance (#112)
  sg <- sign(z - stats::median(z)); sg <- sg[sg != 0]
  n1 <- sum(sg > 0); n2 <- sum(sg < 0)
  if (n1 < 1 || n2 < 1) return(NA_real_)
  Robs <- 1 + sum(diff(sg) != 0)
  d <- .runs_dens(n1, n2)
  if (!any(d$R == Robs)) return(NA_real_)
  .p_borne(2 * min(sum(d$prob[d$R <= Robs]), sum(d$prob[d$R >= Robs])))
}

# --- P-value minimale atteignable des lois de reference discretes (#44) ------
# Regle R1 de la specification commune #44 / #70 / #59 (ADR 0001, CONTEXT.md
# "Test inoperant") : p_min est la plus petite p-value que la statistique peut
# produire sur le jeu considere, calculee sur la loi de reference discrete aux
# effectifs observes, sous la convention bilaterale du doublement (M8). Si
# p_min >= alpha, aucune valeur observee ne peut donner p < alpha : le test
# est inoperant et add() le restitue en diagnostic (engine_registre_tests()).
# Valeurs a T = 8 sans ex aequo (enumeration exhaustive, tests unitaires) :
# suites 4/70 = 0,0571 ; Cox-Stuart 0,125 ; Smirnov 2/70 = 0,0286 ;
# Mann-Kendall et Spearman 2/8! = 5,0e-5.

# Suites : min sur le support de R (probabilites > 0) de
# 2 min(P(R <= r), P(R >= r)), loi de Swed & Eisenhart aux effectifs (n1, n2)
# de part et d'autre de la mediane. NA si un seul cote est represente.
runs_p_min <- function(n1, n2) {
  if (!is.finite(n1) || !is.finite(n2) || n1 < 1 || n2 < 1) return(NA_real_)
  d <- .runs_dens(n1, n2)
  sup <- d$R[d$prob > 0]
  p <- vapply(sup, function(r) 2 * min(sum(d$prob[d$R <= r]), sum(d$prob[d$R >= r])),
              numeric(1))
  .p_borne(min(p))
}
# Effectifs (n1, n2) de part et d'autre de la mediane, ceux de runs_p_exacte().
.runs_effectifs <- function(z) {
  z <- engine_aplatir_ex_aequo(z)             # ex aequo a la tolerance (#112)
  sg <- sign(z - stats::median(z)); sg <- sg[sg != 0]
  c(n1 = sum(sg > 0), n2 = sum(sg < 0))
}

# Cox-Stuart : K ~ Binomiale(m, 1/2) conditionnellement aux m differences non
# nulles (#85) ; la plus petite p bilaterale est celle de K = 0 ou K = m,
# 2 * 0,5^m, bornee a 1 (m = 0 : p_min = 1, test sans objet).
cox_stuart_p_min <- function(m) {
  if (!is.finite(m) || m < 0) return(NA_real_)
  min(1, 2 * 0.5^m)
}

# Smirnov a deux echantillons (ks.test exact, sans ex aequo) : la plus grande
# valeur D = 1 n'est atteinte que par les deux arrangements totalement separes,
# d'ou p_min = 2 / C(n1 + n2, n1) (ks.test(1:4, 5:8) : 2/70).
smirnov_p_min <- function(n1, n2) {
  if (!is.finite(n1) || !is.finite(n2) || n1 < 1 || n2 < 1) return(NA_real_)
  .p_borne(2 / choose(n1 + n2, n1))
}

# Mann-Kendall (loi mahonienne de S) et Spearman (loi de permutation, meme
# fonction pour les deux lignes) : la p bilaterale minimale est celle des deux
# permutations extremes, 2 / T!.
mk_p_min <- function(n) {
  if (!is.finite(n) || n < 2) return(NA_real_)
  .p_borne(2 / factorial(n))
}

# p-value exacte du test des suites sur ratios bruts (ligne Runsr de
# usp_tests() ; issue #29, decision M8, option A). La loi combinatoire de R
# suppose un arrangement equiprobable des signes de u_t = r_t - moyenne(r) :
# c'est le cas quand pi_t est constant (r_t i.i.d. sous le modele ajuste),
# non quand pi_t varie (r_t heteroscedastiques). Deux conditions, toutes deux
# exigees :
#   1. pi_constant (usp_regime(), tolerance TOL_DELTA_BORD) : la raison
#      actuarielle ;
#   2. identite effective des signes de z_t - med(z) et de u_t - med(u) : la
#      garantie exacte. A pi_t exactement constant elle decoule de 1 (z_t est
#      une transformation croissante de r_t) ; dans la bande de tolerance de
#      usp_regime() elle peut tomber (cas construit dans
#      tests/unitaires/test_lois_exactes.R : deux ratios centraux distants de
#      1e-10 en relatif, delta = 1 - TOL_DELTA_BORD / 2).
# La condition porte sur u = r - moyenne(r), le vecteur effectivement teste
# (celui de .stats_bootstrapables() et de la ligne Runsr), et non sur r : le
# centrage par la moyenne, en arithmetique flottante, peut faire basculer le
# signe d'une valeur egale ou quasi egale a la mediane (exemple dans les
# tests unitaires : 0 sur r, -1 sur u).
# Sinon NA : la ligne retombe sur la p Monte-Carlo par la hierarchie de add().
usp_runsr_p_exacte <- function(z, u, pi_constant) {
  if (!isTRUE(pi_constant) || !.signes_mediane_egaux(z, u)) return(NA_real_)
  runs_p_exacte(u)
}
# TRUE si les signes de a - med(a) et de b - med(b) coincident terme a terme,
# a et b aplatis a la tolerance TOL_EX_AEQUO (#112), comme dans test_runs().
.signes_mediane_egaux <- function(a, b) {
  a <- engine_aplatir_ex_aequo(a); b <- engine_aplatir_ex_aequo(b)
  length(a) == length(b) &&
    isTRUE(all(sign(a - stats::median(a)) == sign(b - stats::median(b))))
}

# Mann (1945) / Kendall (1975) - test de tendance monotone.
# Ex aequo a la tolerance TOL_EX_AEQUO (#112) : v aplati en tete (S et
# correction de variance table(v)).
test_mann_kendall <- function(v) {
  v <- engine_aplatir_ex_aequo(v)
  n <- length(v)
  S <- sum(vapply(1:(n - 1), function(i) sum(sign(v[(i + 1):n] - v[i])), numeric(1)))
  ties <- table(v); tt <- sum(ties * (ties - 1) * (2 * ties + 5))
  V <- (n * (n - 1) * (2 * n + 5) - tt) / 18
  Z <- if (S > 0) (S - 1) / sqrt(V) else if (S < 0) (S + 1) / sqrt(V) else 0
  list(stat = Z, p = .p_borne(2 * (1 - stats::pnorm(abs(Z)))), S = S)
}

# --- Hétéroscédasticité / structure de variance ------------------------------

# --- Breusch-Pagan, VERSION ORIGINALE de 1979 (non robuste) ------------------
# Breusch & Pagan (1979), Econometrica 47, 1287-1294, statistique du
# multiplicateur de Lagrange telle que publiee :
#     g_t = u_t^2 / sigma^2_chapeau   avec sigma^2_chapeau = moyenne(u_t^2)
#     LM  = (1/2) * somme des carres EXPLIQUES de la regression de g sur Z
# Sous H0 ET NORMALITE des erreurs, LM converge en loi vers chi2(q).
#
# ATTENTION : le facteur 1/2 et la loi chi2 reposent explicitement sur
# Var(u^2) = 2 sigma^4, propriete de la loi normale. Le test est donc
# NON ROBUSTE : sur des erreurs a queues lourdes, Var(u^2) > 2 sigma^4 et la
# statistique est gonflee, ce qui provoque un sur-rejet. C'est precisement ce
# defaut que la version studentisee de Koenker (1981) corrige, en remplacant le
# facteur 1/2 par une estimation empirique de la variance de u^2, ce qui conduit
# a LM = T R^2 (fonction test_breusch_pagan ci-dessous).
#
# Les deux versions sont conservees : l'originale parce qu'elle est celle qui
# est citee dans la litterature et attendue dans un dossier, la robuste parce
# qu'elle est la seule defendable si la normalite n'est pas acquise -- ce qui
# est justement l'objet de l'hypothese H3, testee separement.
test_breusch_pagan_original <- function(u2, reg) {
  n <- length(u2)
  if (usp_volumes_constants(reg) || mean(u2) <= 0)
    return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_))
  g <- u2 / mean(u2)
  aux <- stats::lm(g ~ reg)
  # Garde-fou R12 (#59, audit C2) : reg ecarte par lm() -> NA.
  if (is.na(stats::coef(aux)["reg"]))
    return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_))
  sce <- sum((stats::fitted(aux) - mean(g))^2)   # somme des carres expliques
  LM <- 0.5 * sce
  q <- 1
  list(stat = LM, p = .p_borne(1 - stats::pchisq(LM, q)), ddl = q)
}

# Garde commune des tests d'heteroscedasticite sur le volume (issue #59,
# regle R11) : a volumes constants (usp_volumes_constants(), tolerance
# TOL_DELTA_BORD), la regression auxiliaire sur reg ou la partition par reg
# est sans objet ; stat et p valent NA (memes noms de champs que la branche
# calculee), au lieu d'une statistique nulle (Breusch-Pagan de Koenker,
# White : LM = 0, p = 1), d'une comparaison des deux moities de la periode
# (Goldfeld-Quandt : order() garde l'ordre du temps sur des ex aequo) ou
# d'une partition par l'arrondi (Brown-Forsythe dans la bande).
# Garde-fou R12 (audit C2) des regressions auxiliaires de Breusch-Pagan
# (1979 et Koenker) : si lm() ecarte le coefficient de reg pour colinearite
# (hors de la bande : mesure a T = 200, x = rep(110, 200) sauf
# x[2] = 110 (1 + 1,1e-6), Koenker rendait LM = 0, p = 1), NA. White a ses
# propres gardes (issue #110, voir test_white()) : moins de trois volumes
# distincts, puis regression auxiliaire de rang deficient (tout coefficient
# ecarte par lm(), et non plus le seul coefficient de reg).

# Breusch & Pagan (1979), Econometrica 47, 1287-1294 ; version studentisee
# (robuste a la non-normalite) de Koenker (1981) : LM = n R^2.
test_breusch_pagan <- function(u2, reg) {
  if (usp_volumes_constants(reg)) return(list(stat = NA_real_, p = NA_real_))
  d <- data.frame(u2 = u2, reg = reg)
  m <- stats::lm(u2 ~ reg, data = d)
  if (is.na(stats::coef(m)["reg"])) return(list(stat = NA_real_, p = NA_real_))
  R2 <- summary(m)$r.squared
  LM <- length(u2) * R2
  list(stat = LM, p = .p_borne(1 - stats::pchisq(LM, 1)))
}

# Normalisation d'echelle des regressions auxiliaires de RESET et White
# (#110) : v / max(|v|). F de RESET est invariant par multiplication de x ou
# de y par une constante non nulle, et R^2 (donc LM) de White par
# multiplication de u2 : la normalisation ne change pas la statistique en
# arithmetique exacte. Raison : sans elle, les sommes de carres calculees
# par lm() / anova() sortent du domaine flottant aux echelles extremes
# (mesure d'audit, RESET avec x et y x 1e-160 a 1e-162 : F faux sans alerte,
# 0,241146 ; 0,241012 ; 0,2 exactement, contre 0,2411534 a l'echelle 1 ;
# x 1e-163 et au-dela : F = NaN par sous-depassement ; NaN aussi par
# debordement au-dela de x 1e160). v est rendu inchange si max(|v|) n'est
# pas fini et strictement positif (v identiquement nul : rien a normaliser).
.usp_normaliser_echelle <- function(v) {
  m <- max(abs(v))
  if (is.finite(m) && m > 0) v / m else v
}

# Mise a l'echelle exacte (#153) : v / 2^floor(log2(max(|v|))). A la
# difference de .usp_normaliser_echelle(), le diviseur est une puissance de
# 2 : la division est exacte en virgule flottante tant que le quotient
# n'est pas sous-normal, et une grandeur invariante par changement d'echelle
# calculee apres elle (distance de Cook, levier de y ~ x - 1) est identique
# au bit pres a celle calculee sur v brut (mesure #153, donnees de test et
# jeu de l'issue : D_t et h_t identical() ; la division par le maximum
# decale max D_t de 2e-16 et 4e-16 en relatif, les petits D_t jusqu'a
# 3e-13).
# v est rendu inchange si max(|v|) n'est pas fini et strictement positif.
.usp_echelle_exacte <- function(v) {
  m <- max(abs(v))
  if (is.finite(m) && m > 0) v / 2^floor(log2(m)) else v
}

# White (1980), Econometrica 48, 817-838 (forme auxiliaire quadratique).
# Issue #110. Base reduite : s = (reg - moyenne) / etendue ; {1, s, s^2}
# engendre le meme espace que {1, reg, reg^2} (changement de base affine),
# donc meme R^2 et meme LM en arithmetique exacte. Le diviseur est l'etendue
# et non sd() : sd() sous-deborde pour reg de l'ordre de 1e-300. Les colonnes
# ont une echelle comparable (|s| <= 1), ce qui evite que le pivotage de
# lm.fit (tol 1e-7) n'ecarte reg^2 par colinearite numerique quand
# l'etendue relative est petite (forme standard, mesure sur les donnees de
# test, x = 100 (1 + cv scale(1:8)) : reg^2 ecarte a l'etendue relative
# 8,6e-4, conserve a 2,9e-3 ; base reduite : LM inchange jusqu'a 2,9e-6).
# Gardes, dans cet ordre, chacune rendant stat = p = NA et son motif dans
# non_applicable (NA_character_ sur la branche calculee) :
#   (0) volumes constants (R11, #59) ;
#   (a) moins de trois volumes distincts : rang structurel k < 3, la
#       regression ne peut porter les deux degres de liberte de chi2(2) ;
#   (b) coefficient ecarte par lm() (rang deficient, colinearite exacte ou
#       numerique) : LM ne serait pas compare a la bonne loi ;
#   (c) statistique LM non finie (mesure : u2 identiquement nul, R^2 = 0/0,
#       LM = NaN) : non_applicable est NA si et seulement si LM est fini.
# u2 est normalise par .usp_normaliser_echelle() (R^2 invariant) ; reg n'a
# pas besoin de l'etre, s etant deja reduit.
test_white <- function(u2, reg) {
  na <- function(motif) list(stat = NA_real_, p = NA_real_, non_applicable = motif)
  if (usp_volumes_constants(reg)) return(na("volumes constants"))
  k <- .usp_nb_volumes_distincts(reg)
  if (k < 3)
    return(na(sprintf(paste("moins de trois volumes distincts (k = %d) : regression",
                            "auxiliaire de White {1, x, x^2} de rang %d, test non",
                            "applicable"), k, k)))
  s <- (reg - mean(reg)) / diff(range(reg))
  u2 <- .usp_normaliser_echelle(u2)
  m <- stats::lm(u2 ~ s + I(s^2))
  if (anyNA(stats::coef(m)))
    return(na(paste("regression auxiliaire de White de rang deficient : terme ecarte",
                    "par lm() pour colinearite, test non applicable")))
  LM <- length(u2) * summary(m)$r.squared
  if (!is.finite(LM)) return(na("statistique LM non finie : test non applicable"))
  list(stat = LM, p = .p_borne(1 - stats::pchisq(LM, 2)), non_applicable = NA_character_)
}

# Goldfeld & Quandt (1965), JASA 60, 539-547.
test_goldfeld_quandt <- function(u, reg) {
  if (usp_volumes_constants(reg)) return(list(stat = NA_real_, p = NA_real_))
  o <- order(reg); u <- u[o]; n <- length(u)
  h <- floor(n / 2)
  s1 <- sum(u[1:h]^2) / h
  s2 <- sum(u[(n - h + 1):n]^2) / h
  F <- s2 / s1
  list(stat = F, p = .p_borne(2 * min(stats::pf(F, h, h), 1 - stats::pf(F, h, h))))
}

# Brown & Forsythe (1974), JASA 69, 364-367 (variante robuste de Levene).
test_brown_forsythe <- function(u, reg) {
  if (usp_volumes_constants(reg)) return(list(stat = NA_real_, p = NA_real_))
  g <- factor(reg > stats::median(reg))
  if (nlevels(g) < 2) return(list(stat = NA_real_, p = NA_real_))
  dev <- unlist(tapply(u, g, function(v) abs(v - stats::median(v))))
  gg <- rep(levels(g), tapply(u, g, length))
  a <- stats::anova(stats::lm(dev ~ gg))
  list(stat = a[["F value"]][1], p = .p_borne(a[["Pr(>F)"]][1]))
}

# Regression simple non contrainte y = a + b*x + e (Student & Fisher, 1908/1922/1925)
# utilisee uniquement comme diagnostic exploratoire de H1 - le modele
# reglementaire lui-meme est y = beta*x + e, sans constante (cf. test_intercept).
test_lm_complet <- function(x, y) {
  # Volumes constants (usp_volumes_constants(), issue #59) => colonne
  # singuliere ou quasi singuliere : la pente n'est pas identifiee. On
  # renvoie des NA plutot que de laisser une erreur d'indexation remonter.
  # Garde-fou (regle R12) : si lm() ecarte malgre tout x pour colinearite
  # (ligne "x" absente de la matrice des coefficients), meme branche NA.
  # x_ecarte (#168) : TRUE sur cette seule branche du garde-fou, FALSE a
  # volumes constants et sur la branche calculee ; usp_tests() y lit le
  # motif du detail des lignes pente et Fisher.
  na_lm <- function(x_ecarte)
    list(pente = NA_real_, t_pente = NA_real_, p_pente = NA_real_,
         F = NA_real_, ddl1 = NA_integer_, ddl2 = NA_integer_,
         p_F = NA_real_, R2 = NA_real_, R2_ajuste = NA_real_,
         modele = stats::lm(y ~ 1), x_ecarte = x_ecarte)
  if (usp_volumes_constants(x)) return(na_lm(FALSE))
  m <- stats::lm(y ~ x)
  s <- summary(m)
  if (!"x" %in% rownames(s$coefficients)) return(na_lm(TRUE))
  list(
    pente        = s$coefficients["x", "Estimate"],
    t_pente      = s$coefficients["x", "t value"],
    p_pente      = s$coefficients["x", "Pr(>|t|)"],
    F            = unname(s$fstatistic[1]),
    ddl1         = unname(s$fstatistic[2]),
    ddl2         = unname(s$fstatistic[3]),
    # unname() : pf() heritait le nom "value" de s$fstatistic[1] (#44,
    # reprise, constat 3 d'audit : nom present ou absent selon le regime).
    p_F          = unname(stats::pf(s$fstatistic[1], s$fstatistic[2], s$fstatistic[3],
                             lower.tail = FALSE)),
    R2           = s$r.squared,
    R2_ajuste    = s$adj.r.squared,
    modele       = m,
    x_ecarte     = FALSE
  )
}

# --- Identifiabilite de la pente (#44, regle R4, option E) --------------------
# Sous le modele ajuste (a = 0, b = beta, Var(Y_t) = sigma^2 ((1 - delta) xbar
# x_t + delta x_t^2)), l'esperance du t de la pente de lm(y ~ x) vaut, au
# premier ordre, lambda = sqrt(S_xx) b / sigma_e avec S_xx = (T - 1) sd(x)^2 et
# sigma_e ~ sigma xbar, soit
#     lambda = sqrt(T - 1) * CV(x) * beta / sigma,   CV(x) = sd(x) / mean(x).
# La puissance du test bilateral au seuil alpha est approchee par celle d'une
# loi de Student decentree t(T - 2, lambda) :
#     pi_b = P(|t| > t_{1 - alpha/2, T - 2} | ncp = lambda)
# (stats::pt(, ncp =), deterministe, aucun alea). Statut : approximation au
# premier ordre sous le modele auxiliaire MCO, controlee par simulation sous le
# modele ajuste dans la specification d'actuary (#44 : 0,47 approche contre
# 0,48 simule sur les donnees de test ; 0,136 contre 0,133 a CV = 3 %).
# SEUIL_PUISSANCE_PENTE = 1/2 est une CONVENTION (repere : "le test a moins
# d'une chance sur deux de rejeter quand le modele est vrai"), non un seuil
# statistique : en dessous, les lignes "Student sur la pente" et "Fisher" sont
# restituees en diagnostic (usp_tests()).
SEUIL_PUISSANCE_PENTE <- 0.5
usp_identifiabilite_pente <- function(x, beta, sigma, alpha) {
  T <- length(x)
  if (T < 3 || !is.finite(beta) || !is.finite(sigma) || sigma <= 0 ||
      !is.finite(stats::sd(x)) || usp_volumes_constants(x))
    return(list(lambda = NA_real_, puissance = NA_real_))
  lambda <- sqrt(T - 1) * stats::sd(x) / mean(x) * beta / sigma
  q <- stats::qt(1 - alpha / 2, T - 2)
  puissance <- stats::pt(-q, T - 2, ncp = lambda) +
    stats::pt(q, T - 2, ncp = lambda, lower.tail = FALSE)
  list(lambda = lambda, puissance = puissance)
}

# RESET (Ramsey, 1969) sur le modele sans constante E[Y] = beta X.
# Issue #110. La forme standard ajoute f^2 et f^3, f = beta_hat x : l'espace
# engendre est {x, x^2, x^3}. On l'engendre ici par la base reduite
# {x, x s, x s^2}, s = (x - moyenne) / etendue (x {1, s, s^2} = x {1, x, x^2},
# changement de base affine) : meme modele, donc meme F en arithmetique
# exacte. Le diviseur est l'etendue et non sd() : sd() sous-deborde pour x de
# l'ordre de 1e-300. Les colonnes ont une echelle comparable (|s| <= 1), ce
# qui evite que le pivotage de lm.fit (tol 1e-7) n'ecarte f^3 par colinearite
# numerique quand l'etendue relative est petite (forme standard, mesure sur
# les donnees de test, x = 100 (1 + cv scale(1:8)) : f^3 ecarte a l'etendue
# relative 8,6e-4, conserve a 2,9e-3).
# Gardes, dans cet ordre, chacune rendant stat = p = NA et son motif dans
# non_applicable (NA_character_ sur la branche calculee) :
#   (0) volumes constants (R11, #59) ;
#   (a) moins de trois volumes distincts : rang structurel k < 3, anova()
#       comparerait sur k - 1 ddl sous le libelle F(2, T-3) ;
#   (b) coefficient ecarte par lm() (rang deficient, colinearite exacte ou
#       numerique) ;
#   (c) statistique F non finie apres anova() (mesure : y identiquement nul,
#       F = 0/0 = NaN ; cause historique, avant .usp_normaliser_echelle() :
#       sous-depassement des sommes de carres a x et y x 1e-163 et au-dela,
#       voir ci-dessus) : non_applicable est NA si et seulement si la
#       statistique est finie. Motif generique, comme la garde (c) de White.
# x et y sont normalises par .usp_normaliser_echelle() (F invariant) avant
# toute regression. Le garde-fou R12 sur le coefficient de x dans m0 est
# couvert par anyNA(coef(m1)) (m1 contient x) ; il est conserve par regle
# (#59).
test_reset <- function(x, y) {
  na <- function(motif) list(stat = NA_real_, p = NA_real_, non_applicable = motif)
  if (usp_volumes_constants(x)) return(na("volumes constants"))
  k <- .usp_nb_volumes_distincts(x)
  if (k < 3)
    return(na(sprintf(paste("moins de trois volumes distincts (k = %d) : regression",
                            "auxiliaire RESET {x, x^2, x^3} de rang %d, test non",
                            "applicable"), k, k)))
  # s, invariant d'echelle, est calcule sur x brut : la normalisation arrondit
  # chaque x_i (1 ulp), erreur que x - moyenne amplifie d'un facteur
  # 1 / etendue relative (mesure a l'etendue 2,9e-6 : F a 1,1e-10 relatif de
  # la forme poly(x, 2) si s est pris apres normalisation).
  s <- (x - mean(x)) / diff(range(x))
  x <- .usp_normaliser_echelle(x)
  y <- .usp_normaliser_echelle(y)
  m0 <- stats::lm(y ~ x - 1)                 # E[Y] = beta * X, sans constante
  m1 <- stats::lm(y ~ x + I(x * s) + I(x * s^2) - 1)
  if (is.na(stats::coef(m0)["x"]) || anyNA(stats::coef(m1)))
    return(na(paste("regression auxiliaire RESET de rang deficient : terme ecarte",
                    "par lm() pour colinearite, test non applicable")))
  a <- stats::anova(m0, m1)
  stat <- a[["F"]][2]
  if (!is.finite(stat))
    return(na("statistique F non finie : test non applicable"))
  list(stat = stat, p = .p_borne(a[["Pr(>F)"]][2]), non_applicable = NA_character_)
}

# --- Test d'equivalence sur la constante (TOST) ------------------------------
# Le test de Student usuel sur la constante a pour hypothese nulle a = 0 : son
# NON-rejet ne prouve rien (absence de preuve n'est pas preuve d'absence), ce
# qui est genant puisque c'est precisement la proportionnalite que le reglement
# exige d'etablir. Le test d'equivalence inverse la charge de la preuve :
#
#     H0 : |a| >= Delta      (la constante n'est PAS negligeable)
#     H1 : |a| <  Delta      (la constante est negligeable)
#
# Rejeter H0 fournit une preuve POSITIVE de proportionnalite pratique.
# Mise en oeuvre par deux tests unilateraux (Schuirmann, 1987) :
#     H0_bas : a <= -Delta   et   H0_haut : a >= +Delta
# la p-value du test d'equivalence etant le MAXIMUM des deux p-values
# unilaterales. Sous normalite des erreurs, chacune est EXACTE (loi de Student
# a T-2 degres de liberte) : aucune approximation asymptotique n'intervient.
#
# La marge Delta n'est pas statistique mais economique : elle doit etre fixee
# a priori. On la parametre en proportion theta de la perte annuelle moyenne,
# Delta = theta * mean(y), afin qu'elle soit invariante a l'unite monetaire.
# theta = 0.10 signifie : "une composante fixe inferieure a 10 % de la
# sinistralite annuelle moyenne est jugee negligeable".
# ATTENTION a l'exactitude : le test n'est EXACT (loi de Student) que si Delta
# est fixe A PRIORI, independamment des donnees. La marge par defaut
# Delta = theta*mean(y) est commode et invariante d'echelle, mais elle est
# aleatoire : l'exactitude devient alors approchee (la simulation montre que le
# niveau reste tenu, mais ce n'est plus un resultat exact). Pour un dossier
# ACPR, fixer `delta_abs` a une valeur arretee a priori et documentee.
# Branche non applicable (issue #58) : la liste porte les memes champs que la
# branche calculee (p_bas, p_haut a NA, et non absents : sprintf() sur NULL
# rendait un detail character(0) qui faisait planter engine_table_tests()) et
# le motif, "volumes constants" (regression y ~ x non definie) ou "marge"
# (sans delta_abs : theta non fini ou <= 0 ; avec delta_abs : delta_abs non
# fini ou <= 0 ; theta est alors ignore). Les volumes constants priment sur la
# marge. ddl = T - 2 y est renseigne : il ne depend que de T, pas de la
# regression, et le garder donne aux deux branches les memes noms de champs.
# theta = Inf donnait Delta = Inf, p = 0 et un verdict OK "preuve positive" :
# il est traite en marge invalide. Troisieme motif, "statistique non definie"
# (#153) : t_bas ou t_haut vaut NaN (voir la garde ci-dessous). Quatrieme
# motif, "x ecarte" (#168) : hors volumes constants, lm() a ecarte x pour
# colinearite (garde-fou R12) ; il etait auparavant confondu avec "volumes
# constants".
test_tost_intercept <- function(x, y, theta = 0.10, delta_abs = NULL) {
  # Volumes constants : critere unique usp_volumes_constants() (issue #59).
  motif <- if (usp_volumes_constants(x)) "volumes constants"
  else if ((is.null(delta_abs) && (!is.finite(theta) || theta <= 0)) ||
           (!is.null(delta_abs) && (!is.finite(delta_abs) || delta_abs <= 0))) "marge"
  else NA_character_
  non_applicable <- function(motif)
    list(stat = NA_real_, p = NA_real_, delta = NA_real_,
         a = NA_real_, se = NA_real_, t_bas = NA_real_, t_haut = NA_real_,
         p_bas = NA_real_, p_haut = NA_real_, ddl = length(x) - 2,
         marge_a_priori = FALSE, non_applicable = motif)
  if (!is.na(motif)) return(non_applicable(motif))
  m <- summary(stats::lm(y ~ x))
  # Garde-fou (regle R12, #59) : si lm() a ecarte x, coefficients[1, ] serait
  # la moyenne de y du modele y ~ 1 ; aucune p-value n'est calculee.
  if (!"x" %in% rownames(m$coefficients)) return(non_applicable("x ecarte"))
  a  <- m$coefficients[1, 1]; se <- m$coefficients[1, 2]
  ddl <- length(x) - 2
  marge_a_priori <- !is.null(delta_abs)
  Delta <- if (marge_a_priori) delta_abs else theta * mean(y)
  t_bas  <- (a + Delta) / se        # H0_bas  : a <= -Delta, rejet si t_bas grand
  t_haut <- (a - Delta) / se        # H0_haut : a >= +Delta, rejet si t_haut petit
  p_bas  <- stats::pt(t_bas,  ddl, lower.tail = FALSE)
  p_haut <- stats::pt(t_haut, ddl, lower.tail = TRUE)
  # Garde (#153), sur le modele de RESET et White (#110) : p_bas ou p_haut
  # non finie -> non applicable, au lieu de l'erreur R de
  # if (p_bas >= p_haut) sur NA. pt(+/-Inf) etant fini (0 ou 1), la garde ne
  # se declenche que si t_bas ou t_haut vaut NaN : statistique non definie.
  # Cas vise : entrees sous-normales (x et y x 1e-320, 5e-324). L'issue de
  # lm() y depend de la plateforme (BLAS, processeur, version de R). Mesure :
  # a = se = NaN sous le BLAS de reference et OpenBLAS 0.3.20 (noyaux Zen,
  # Haswell, SkylakeX) ; autre issue sur la CI (R 4.3.1, OpenBLAS 0.3.20,
  # EPYC 7763). Hors du domaine de #145 : run_engine() n'atteint pas cette
  # branche.
  if (!is.finite(p_bas) || !is.finite(p_haut))
    return(non_applicable("statistique non definie"))
  p <- max(p_bas, p_haut)           # regle du maximum (intersection-union)
  list(stat = if (p_bas >= p_haut) t_bas else t_haut,
       p = .p_borne(p), delta = Delta, a = a, se = se,
       t_bas = t_bas, t_haut = t_haut, p_bas = p_bas, p_haut = p_haut,
       ddl = ddl, marge_a_priori = marge_a_priori, non_applicable = NA_character_)
}

# Significativité de la constante : rejette la proportionnalité stricte.
test_intercept <- function(x, y) {
  # Volumes constants (usp_volumes_constants(), #59) ; garde-fou R12 : x
  # ecarte par lm() -> NA, jamais le t de la moyenne du modele y ~ 1.
  # x_ecarte (#168) : TRUE sur la seule branche du garde-fou R12 ; usp_tests()
  # y lit le motif du detail de la ligne constante.
  if (usp_volumes_constants(x))
    return(list(stat = NA_real_, p = NA_real_, x_ecarte = FALSE))
  m <- summary(stats::lm(y ~ x))
  if (!"x" %in% rownames(m$coefficients))
    return(list(stat = NA_real_, p = NA_real_, x_ecarte = TRUE))
  list(stat = m$coefficients[1, 3], p = .p_borne(m$coefficients[1, 4]), x_ecarte = FALSE)
}

# --- Ruptures et points influents --------------------------------------------

# Quandt (1960) / Chow (1960) : statistique sup-F de rupture de moyenne.
stat_supF <- function(v, trim = 0.15) {
  n <- length(v)
  b <- max(2, floor(trim * n)):min(n - 2, n - floor(trim * n))
  if (!length(b) || b[1] >= b[length(b)]) return(NA_real_)
  sst <- sum((v - mean(v))^2)
  if (!is.finite(sst) || sst <= 0) return(NA_real_)
  Fs <- vapply(b, function(k) {
    ssr <- sum((v[1:k] - mean(v[1:k]))^2) + sum((v[(k+1):n] - mean(v[(k+1):n]))^2)
    ((sst - ssr) / 1) / (ssr / (n - 2))
  }, numeric(1))
  max(Fs)
}

# Brown, Durbin & Evans (1975), JRSS B 37, 149-192 : OLS-CUSUM.
stat_cusum <- function(z) {
  n <- length(z); s <- stats::sd(z)
  if (!is.finite(s) || s == 0) return(NA_real_)
  max(abs(cumsum(z - mean(z))) / (s * sqrt(n)))
}

# Grubbs (1969), Technometrics 11, 1-21.
test_grubbs <- function(v) {
  n <- length(v); s <- stats::sd(v)
  if (!is.finite(s) || s == 0 || n < 3)
    return(list(stat = NA_real_, p = NA_real_, idx = NA))
  G <- max(abs(v - mean(v))) / s
  # G est borne par (n-1)/sqrt(n) ; a cette borne le denominateur s'annule
  # (0/0 numerique). On borne alors la p-value a sa valeur limite 0.
  den <- (n - 1)^2 - n * G^2
  if (den <= .Machine$double.eps * (n - 1)^2) {
    p <- 0
  } else {
    tt <- sqrt(n * (n - 2) * G^2 / den)
    p <- n * 2 * (1 - stats::pt(tt, n - 2))
  }
  list(stat = G, p = .p_borne(p), idx = which.max(abs(v - mean(v))))
}

# Rosner (1983), Technometrics 25, 165-172 : generalized ESD.
test_rosner <- function(v, k = NULL, alpha = 0.05) {
  # alpha est le niveau de la procedure de decision (il n'y a pas de p-value).
  n <- length(v); if (is.null(k)) k <- max(1, floor(n / 4))
  w <- v; idx <- seq_along(v); det <- integer(0)
  R <- numeric(k); lam <- numeric(k)
  for (i in 1:k) {
    if (length(w) < 3) { R[i] <- NA; lam[i] <- NA; next }
    m <- mean(w); s <- stats::sd(w)
    j <- which.max(abs(w - m))
    R[i] <- abs(w[j] - m) / s
    nn <- n - i + 1
    pp <- 1 - alpha / (2 * nn)
    tcrit <- stats::qt(pp, nn - 2)
    lam[i] <- (nn - 1) * tcrit / sqrt((nn - 2 + tcrit^2) * nn)
    det <- c(det, idx[j]); w <- w[-j]; idx <- idx[-j]
  }
  n_out <- suppressWarnings(max(c(0, which(R > lam)), na.rm = TRUE))
  list(nb_outliers = n_out,
       positions = if (n_out > 0) det[seq_len(n_out)] else integer(0),
       R = R, lambda = lam)
}


## =============================================================================
## 4. P-VALUES PAR BOOTSTRAP PARAMÉTRIQUE SOUS LE MODÈLE AJUSTÉ
##    (seules p-values réellement calibrées pour T de l'ordre de 5 à 15)
## =============================================================================

usp_simuler <- function(fit) {
  # Y_t | X_t ~ LogNormale(mu_t, 1/pi_t) avec mu_t = ln(beta x_t) - 1/(2 pi_t)
  mu <- log(fit$beta * fit$x) - 1 / (2 * fit$pi)
  exp(stats::rnorm(fit$T, mu, sqrt(1 / fit$pi)))
}

# Toutes les statistiques dont la loi sous H0 "le modele de l'annexe XVII est
# correct" peut etre simulee. IMPORTANT : le bootstrap parametrique simule sous
# le MODELE AJUSTE. Sont donc exclues les statistiques dont l'hypothese nulle
# n'est pas "le modele est correct" mais "beta = 0" (Student sur la pente,
# Fisher global) : pour celles-la, le modele ajuste appartient a H1 et une
# p-value de Monte-Carlo n'aurait aucun sens.
# Sont exclues egalement :
#   - MeanZ = moyenne(z) et VarZ = var(z), grandeurs rivees par l'estimation.
#     Les conditions du premier ordre de usp_ajuster() imposent toujours
#     somme(sqrt(pi_t) z_t) = 0 ; elles n'imposent somme(z_t) = 0 et
#     somme(z_t^2) = T que LORSQUE pi_t est CONSTANT, c'est-a-dire delta = 1
#     ou volumes x_t constants -- et non des que delta est au bord : a
#     delta = 0 avec des volumes variables, pi_t varie et aucune des deux
#     egalites ne tient (voir usp_tests(), qui distingue les trois cas).
#     Quand pi_t est constant, les deux egalites n'ont PAS le meme statut :
#     somme(z_t) = 0 decoule de la forme fermee de ln(beta) dans usp_noyau(),
#     c'est une identite algebrique vraie pour tout (delta, gamma) et donc a
#     la precision machine, tandis que somme(z_t^2) = T suppose la derivee en
#     gamma annulee et ne vaut qu'a la tolerance d'arret pres. Sur les donnees
#     de test (T = 8, delta = 1), mean(z) = -2,0e-16 -- un zero machine qui ne
#     depend pas de la convergence -- mais somme(z^2) - T = -5,4e-06, soit
#     6,8e-07 en relatif, qui en depend.
#     La p-value de Monte-Carlo n'a alors pas de sens, non parce que tout
#     serait du bruit d'arrondi, mais parce que la loi simulee est un
#     MELANGE : sur les 999 repliques des donnees de test (graine 20260831),
#     493 ont delta* = 1 et une moyenne des z* d'ecart-type 2,2e-16 (zero
#     machine), 460 ont delta* = 0 et un ecart-type de 1,7e-02 (composante
#     diffuse), 46 un delta* interieur. La statistique observee etant elle
#     aussi un zero machine, la p-value bilaterale se decide au signe du bruit
#     d'arrondi sur pres de la moitie des repliques : d'ou sa dependance a la
#     plateforme (issues #3 et #5, ADR 0001). Le centrage et la variance
#     unitaire sont restitues comme diagnostics par usp_tests().
#   - LB2r et BP2r, statistiques au retard 2 sur les ratios bruts : jamais
#     associees a un test affiche (issue #5) ; au retard 2, rho_2 ne repose
#     que sur T-2 produits et Box-Pierce est domine par Ljung-Box.
# --- Catalogue des statistiques Monte-Carlo (ADR 0003, issue #41) -------------
# Une entree par statistique simulee : sa fonction de calcul `calc` (appliquee
# au contexte e construit par .usp_contexte_mc() ou .mw_contexte_mc()), son
# sens de rejet `queue` ("haut", "bas" ou "deux") et sa condition de
# degenerescence `degenere`. Le calcul observe et simule
# (.stats_bootstrapables(), .mw_stats()), la p-value de Monte-Carlo
# (.mc_p_values(), engine_p_mc()) et l'association a une ligne de test
# (add(mc_nom = ) de engine_registre_tests()) lisent ce seul catalogue ; un
# nom absent du catalogue leve une erreur.
# `degenere` (ADR 0003 point 5, forme fixee par la specification de #44,
# regle R2) : NULL, ou une fonction du contexte OBSERVE (meme signature que
# `calc`, function(e)) rendant un logique de longueur 1 ; TRUE signifie "sur
# ces donnees, la statistique est fixee par l'estimation" (exemples
# historiques : MeanZ, VarZ a pi_t constant, retirees du bootstrap et
# restituees comme diagnostics par usp_tests(), issue #3, ADR 0001). Elle est
# evaluee une fois, sur l'observe, par .mc_p_values() ; la p Monte-Carlo est
# alors NA, avec le motif MOTIF_MC_CONDITION, et add() restitue la ligne en
# diagnostic. NULL pour toutes les entrees actuelles.
# `non_definie` : NULL, ou une fonction du contexte observe rendant le motif
# (chaine) pour lequel la statistique n'est pas definie sur ces donnees, ou
# NA_character_ ; lue seulement si la statistique observee n'est pas finie,
# elle remplace alors le motif generique MOTIF_MC_OBS_NON_FINIE (seul cas :
# Cox-Stuart avec ex aequo, #85). La p exacte eventuelle de la ligne n'en est
# pas affectee.
# L'ordre des entrees fixe celui des statistiques dans l'objet bootstrap.
.mc_entree <- function(calc, queue, degenere = NULL, non_definie = NULL) {
  if (length(queue) != 1L || !queue %in% c("haut", "bas", "deux"))
    stop("catalogue Monte-Carlo : sens de rejet inconnu : ", paste(queue, collapse = ", "))
  if (!is.null(degenere) && !is.function(degenere))
    stop("catalogue Monte-Carlo : degenere doit etre NULL ou une fonction du contexte")
  if (!is.null(non_definie) && !is.function(non_definie))
    stop("catalogue Monte-Carlo : non_definie doit etre NULL ou une fonction du contexte")
  list(calc = calc, queue = queue, degenere = degenere, non_definie = non_definie)
}

# Contexte commun aux fonctions de calcul du catalogue lognormal.
# r : ratios S/P bruts ; u : ratios bruts centres, base alternative pour les
# tests d'independance et de stabilite (voir usp_tests, argument base_residus).
# Ces ratios sont heteroscedastiques par construction des que pi_t varie,
# donc leurs p-values classiques ne sont qu'indicatives ; seule la p-value
# de Monte-Carlo est valide, le bootstrap simulant sous le modele ajuste.
# Exception : a pi_t constant, la ligne Runsr recoit la p-value exacte de
# la loi combinatoire de R (usp_runsr_p_exacte(), issue #29).
# Volumes constants (usp_volumes_constants(), #59, regle R14) : x etant fixe
# dans le bootstrap, le regime est le meme dans toutes les replications ; les
# statistiques qui regressent sur x ou partitionnent par x (Intercept, RESET,
# BP, BP79, White, GQ, BF, Smirnov, SpearVol) y valent NA, sans erreur, et
# leurs lignes sont "non applicable" par la regle R13 de usp_tests().
.usp_contexte_mc <- function(x, y, z) {
  r <- y / x
  list(x = x, y = y, z = z, r = r, u = r - mean(r), T = length(x))
}

USP_CATALOGUE_MC <- list(
  AD     = .mc_entree(function(e) stat_ad(e$z), "haut"),
  CvM    = .mc_entree(function(e) stat_cvm(e$z), "haut"),
  KS     = .mc_entree(function(e) stat_ks(e$z), "haut"),
  SW     = .mc_entree(function(e) .shapiro_sur(e$z)$stat, "bas"),
  SF     = .mc_entree(function(e) test_shapiro_francia(e$z)$stat, "bas"),
  JB     = .mc_entree(function(e) test_jarque_bera(e$z)$stat, "haut"),
  DW     = .mc_entree(function(e) stat_dw(e$z), "deux"),
  LB1    = .mc_entree(function(e)
    unname(stats::Box.test(e$z, lag = 1, type = "Ljung-Box")$statistic), "haut"),
  supF   = .mc_entree(function(e) stat_supF(e$z), "haut"),
  CUSUM  = .mc_entree(function(e) stat_cusum(e$z), "haut"),
  Grubbs = .mc_entree(function(e) test_grubbs(e$z)$stat, "haut"),
  Lillie = .mc_entree(function(e) stat_lilliefors(e$z), "haut"),
  # statistiques ajoutees : loi de reference seulement asymptotique
  Intercept = .mc_entree(function(e) test_intercept(e$x, e$y)$stat, "deux"),
  RESET  = .mc_entree(function(e) test_reset(e$x, e$y)$stat, "haut"),
  BP     = .mc_entree(function(e) test_breusch_pagan(e$z^2, e$x)$stat, "haut"),
  BP79   = .mc_entree(function(e) test_breusch_pagan_original(e$z^2, e$x)$stat, "haut"),
  White  = .mc_entree(function(e) test_white(e$z^2, e$x)$stat, "haut"),
  GQ     = .mc_entree(function(e) test_goldfeld_quandt(e$z, e$x)$stat, "deux"),
  BF     = .mc_entree(function(e) test_brown_forsythe(e$z, e$x)$stat, "haut"),
  Smirnov = .mc_entree(function(e) {
    sm <- NA_real_
    if (e$T >= 8 && !usp_volumes_constants(e$x)) {
      g <- e$x > stats::median(e$x)
      if (sum(g) >= 3 && sum(!g) >= 3)
        # z aplati a TOL_EX_AEQUO (#112), comme dans usp_tests()
        sm <- local({
          za <- engine_aplatir_ex_aequo(e$z)
          unname(suppressWarnings(stats::ks.test(za[g], za[!g])$statistic))
        })
    }
    sm
  }, "haut"),
  LB2    = .mc_entree(function(e)
    if (e$T >= 8) unname(stats::Box.test(e$z, lag = 2, type = "Ljung-Box")$statistic)
    else NA_real_, "haut"),
  BP2    = .mc_entree(function(e)
    if (e$T >= 8) unname(stats::Box.test(e$z, lag = 2, type = "Box-Pierce")$statistic)
    else NA_real_, "haut"),
  Runs   = .mc_entree(function(e) test_runs(e$z)$stat, "deux"),
  MK     = .mc_entree(function(e) test_mann_kendall(e$r)$stat, "deux"),
  # Spearman : la statistique simulee est S (statistique de test affichee par
  # usp_tests()), S = (T^3 - T) (1 - rho_s) / 6 dans stats::cor.test(),
  # fonction affine decroissante de rho_s : la region bilaterale est la meme
  # (mesure du 24/09/2026 sur les trois cas lognormaux de reference : p_mc
  # identiques au bit pres a celles calculees sur rho_s ; issue #41).
  # r et x aplatis a TOL_EX_AEQUO avant cor.test() (#112), comme dans
  # usp_tests() ; x en tolerance purement relative (.usp_aplatir_volumes()).
  SpearVol = .mc_entree(function(e)
    if (!usp_volumes_constants(e$x))
      suppressWarnings(unname(stats::cor.test(engine_aplatir_ex_aequo(e$r),
                                              .usp_aplatir_volumes(e$x),
                                              method = "spearman",
                                              exact = FALSE)$statistic)) else NA_real_,
    "deux"),
  SpearTps = .mc_entree(function(e)
    suppressWarnings(unname(stats::cor.test(engine_aplatir_ex_aequo(e$r), seq_along(e$r),
                                            method = "spearman", exact = FALSE)$statistic)),
    "deux"),
  DAgo   = .mc_entree(function(e) test_dagostino_skew(e$z)$stat, "deux"),
  # Cox-Stuart : la region de rejet bilaterale de K (nombre de differences
  # positives entre les deux moities) est pliee en |K - n_p / 2|, rejet en
  # queue haute, n_p = T - ceiling(T / 2) etant le nombre de paires. Sans
  # difference nulle (m = n_p), c'est le test binomial exact bilateral (loi
  # de K symetrique sous H0). La statistique n'est definie que sans ex aequo :
  # avec ex aequo, la loi simulee (K* ~ B(n_p, 1/2), replications continues)
  # n'est pas celle du K observe (B(m, 1/2)), donc pas de p_mc (NA ; #85).
  # La statistique affichee par usp_tests() reste K.
  # Motif d'indisponibilite (#44, complement du 27/09) : "statistique
  # observee non definie : ex aequo", distinct de l'absence de replication
  # finie ; la p exacte binomiale de la ligne reste retenue (a pi_t constant,
  # regle R7 de #70).
  CoxStuart = .mc_entree(function(e) {
    cx <- test_cox_stuart(e$r)
    if (is.finite(cx$stat) && cx$m == cx$n_p) abs(cx$stat - cx$n_p / 2) else NA_real_
  }, "haut", non_definie = function(e) {
    cx <- test_cox_stuart(e$r)
    if (cx$m < cx$n_p) "statistique observee non definie : ex aequo" else NA_character_
  }),
  # --- memes statistiques sur les ratios bruts centres (base "r") -----------
  DWr    = .mc_entree(function(e) stat_dw(e$u), "deux"),
  LB1r   = .mc_entree(function(e)
    unname(stats::Box.test(e$u, lag = 1, type = "Ljung-Box")$statistic), "haut"),
  Runsr  = .mc_entree(function(e) test_runs(e$u)$stat, "deux"),
  supFr  = .mc_entree(function(e) stat_supF(e$u), "haut"),
  CUSUMr = .mc_entree(function(e) stat_cusum(e$u), "haut"),
  Grubbsr = .mc_entree(function(e) test_grubbs(e$u)$stat, "haut")
)

# Evalue toutes les statistiques d'un catalogue sur un contexte. do.call(base::c, .)
# garde la semantique de c(AD = ..., CvM = ...) : vecteur numerique nomme dans
# l'ordre du catalogue. base:: est necessaire (#179) : do.call() evalue son
# premier argument comme une valeur, sans ecarter les objets qui ne sont pas des
# fonctions comme le fait un appel c(...) ; un objet c <- 5 de l'environnement
# global faisait echouer chaque evaluation, et run_engine() rendait ok = FALSE
# ("erreur R dans .mc_evaluer()") pour les deux methodes. Meme protection pour
# les autres do.call(base::cbind / base::rbind, .) du moteur ; les passages par
# match.fun() (apply, tapply, sapply, outer...) ne sont pas exposes. Une erreur
# de calcul se propage a l'appelant (dans le bootstrap, la replication est
# alors ecartee).
# Chaque entree doit rendre une valeur de longueur 1 (eventuellement NA) : une
# valeur NULL disparaitrait du vecteur et decalerait les noms, une valeur de
# longueur 2 en ajouterait. Toute autre longueur leve une erreur qui nomme la
# statistique ; dans le bootstrap, le try() existant ecarte la replication.
.mc_evaluer <- function(catalogue, e) {
  vals <- lapply(names(catalogue), function(nm) {
    v <- catalogue[[nm]]$calc(e)
    if (length(v) != 1L)
      stop("statistique Monte-Carlo ", nm, " : valeur de longueur ", length(v),
           " (longueur 1 attendue)")
    v
  })
  names(vals) <- names(catalogue)
  do.call(base::c, vals)
}

# Statistiques simulables de la methode lognormale (catalogue USP_CATALOGUE_MC).
.stats_bootstrapables <- function(x, y, z)
  .mc_evaluer(USP_CATALOGUE_MC, .usp_contexte_mc(x, y, z))

# --- P-value de Monte-Carlo d'une statistique ---------------------------------
# Fonction unique, partagee par usp_bootstrap() et mw_bootstrap().
#   sim   : valeurs simulees de la statistique (NA / non finies ignorees)
#   obs   : valeur observee
#   queue : sens du rejet, "haut", "bas" ou "deux" (lu au catalogue)
# Retour : p_mc (bornee a 1), err_mc, B_effectif (nombre de simulations finies),
# granularite (pas elementaire de p_mc, voir plus bas).
# p_mc = (1 + #{sim >= obs}) / (B_eff + 1) en queue haute, symetrique en queue
# basse, 2 * min des deux en bilateral. NA si aucune simulation finie ou si la
# valeur observee n'est pas finie.
# err_mc : ecart-type de Monte-Carlo de p_mc, en 1/sqrt(B), a distinguer
# strictement de l'erreur d'approximation liee a T (issue #40) :
#   - queue haute ou basse : sqrt(p (1 - p) / B_eff), ecart-type binomial
#     (N ~ Binomiale(B_eff, q), p estimateur plug-in de q) ;
#   - bilateral : sqrt(p (2 - p) / B_eff), p pris apres la borne pmin(p, 1).
#     Tant que le min des deux queues ne change pas de cote, p = 2 p_queue et
#     Var = 4 q (1 - q) / B = p (2 - p) / B. Une seule formule, sans cas
#     particulier au bord : pour p >= 0,9 c'est une borne conservatrice de
#     l'ecart-type exact (enumeration binomiale a B = 999), jusqu'a 1,66 fois
#     l'ecart-type exact en p = 1 (1 / sqrt(B) contre sqrt((1 - 2/pi) / B)).
# granularite : pas elementaire de p_mc, 1 / (B_eff + 1) en queue haute ou
# basse, 2 / (B_eff + 1) en bilateral ; NA si aucune simulation finie.
# motif (#44, regle R2 ; ADR 0003 point 5) : NA_character_ si p_mc est
# calculee ; sinon la cause de son absence, produite ICI et non devinee par
# l'appelant, dans cet ordre de priorite :
#   MOTIF_MC_OBS_NON_FINIE    : statistique observee non finie ;
#   MOTIF_MC_AUCUNE_REPLIC    : aucune simulation finie (B_effectif = 0) ;
#   MOTIF_MC_REPLIC_INSUFFISANTES : 0 < B_effectif < B_MIN_DEGENERESCENCE
#                               (#128, point 1 ; seuil fixe, independant
#                               d'alpha) : sous ce nombre de simulations
#                               finies, la detection de degenerescence
#                               ci-dessous est desarmee et, run_engine()
#                               imposant B >= B_MIN_USAGE = 99, plus de la
#                               moitie des simulations ont echoue ; p_mc = NA,
#                               traitee par add() comme MOTIF_MC_AUCUNE_REPLIC
#                               (repli nomme, ou test sans p-value) ;
#   MOTIF_MC_DISPERSION_NULLE : au moins B_MIN_DEGENERESCENCE simulations
#                               finies, d'etendue <= tol et dont la valeur
#                               commune coincide avec l'observee a tol pres
#                               (tol = TOL_DISPERSION_MC * max(1, |obs|)) :
#                               la loi simulee est degeneree en la valeur
#                               observee, la p-value compare du bruit
#                               d'arrondi ; p_mc = NA, jamais remplacee
#                               (ADR 0001) ;
#   MOTIF_MC_ATOME_HORS_OBS   : meme loi ponctuelle, mais l'observee est hors
#                               de l'atome (a plus de tol) : aucune simulation
#                               sous le modele ajuste ne reproduit la valeur
#                               observee ; p_mc = NA (reprise de #44, constat 1
#                               d'audit). L'INFO qui en resulte n'est pas
#                               neutre : le detail de la ligne est complete
#                               par DETAIL_MC_ATOME_HORS_OBS (#126, point 1 ;
#                               COMPLEMENTS_MOTIF_MC ci-dessous).
#                               L'ecart entre l'observee et l'atome n'est pas
#                               imprime (grandeur de bruit, test anti-bruit).
#                               Aucune tolerance distincte ne requalifie un
#                               petit ecart en MOTIF_MC_DISPERSION_NULLE (#126,
#                               point 2 non retenu, avis d'actuary Q-E1d-6,
#                               commentaire 5927249876 de #126).
# Sous B_MIN_DEGENERESCENCE simulations finies, une loi simulee constante
# peut n'etre qu'un effet de petit B : la loi ponctuelle n'y est pas testee,
# et p_mc n'est plus calculee (MOTIF_MC_REPLIC_INSUFFISANTES, #128) ; une
# ligne a p exacte la garde (B = 2 : Smirnov garde sa p exacte). Cette
# branche n'est atteinte par run_engine() que si moins de 50 des
# B >= B_MIN_USAGE = 99 simulations sont finies : run_engine() refuse
# B < B_MIN_USAGE (constat C1 de la revue finale d'E1) ; elle l'est par les
# appels directs de usp_bootstrap(), mw_bootstrap() ou engine_p_mc().
# Limite (a dire dans le .tex) : cette detection generique n'aurait PAS
# attrape le cas historique de MeanZ (melange a atome en la valeur observee,
# ADR 0001 amende) ; l'atome releve de la condition `degenere` du catalogue.
MOTIF_MC_OBS_NON_FINIE    <- "statistique observee non finie"
MOTIF_MC_AUCUNE_REPLIC    <- "aucune replication finie (B_effectif = 0)"
B_MIN_DEGENERESCENCE <- 50
MOTIF_MC_REPLIC_INSUFFISANTES <- sprintf(
  "replications finies insuffisantes (B_effectif < B_MIN_DEGENERESCENCE = %d)",
  B_MIN_DEGENERESCENCE)
MOTIF_MC_DISPERSION_NULLE <- "loi simulee de dispersion nulle"
MOTIF_MC_CONDITION        <- "statistique degeneree sur ces donnees (condition du catalogue)"
MOTIF_MC_ATOME_HORS_OBS   <- "loi simulee ponctuelle, statistique observee hors de l'atome"
DETAIL_MC_ATOME_HORS_OBS  <- paste(
  "Aucune simulation sous le modele ajuste ne reproduit la valeur observee :",
  "incompatibilite du modele avec les donnees ou asymetrie de calcul entre",
  "observe et simule, a examiner avant toute conclusion.")
# Complement du detail par motif Monte-Carlo (#126) : table nommee
# motif -> phrase, lue par .complement_motif_mc() dans add() et dans les
# lignes du rapport de vraisemblance sur delta de usp_tests() (p_mc_ext).
COMPLEMENTS_MOTIF_MC <- stats::setNames(DETAIL_MC_ATOME_HORS_OBS, MOTIF_MC_ATOME_HORS_OBS)
.complement_motif_mc <- function(motif) {
  if (length(motif) == 1L && !is.na(motif) && motif %in% names(COMPLEMENTS_MOTIF_MC))
    unname(COMPLEMENTS_MOTIF_MC[[motif]]) else character(0)
}
TOL_DISPERSION_MC <- 1e-12
engine_p_mc <- function(sim, obs, queue) {
  if (length(queue) != 1L || !queue %in% c("haut", "bas", "deux"))
    stop("engine_p_mc() : sens de rejet inconnu : ", paste(queue, collapse = ", "))
  fin <- is.finite(sim)
  B_eff <- as.numeric(sum(fin))
  s <- sim[fin]
  tol <- TOL_DISPERSION_MC * max(1, abs(obs))
  ponctuelle <- is.finite(obs) && length(s) >= B_MIN_DEGENERESCENCE &&
    diff(range(s)) <= tol
  motif <- if (!is.finite(obs)) MOTIF_MC_OBS_NON_FINIE
           else if (!length(s)) MOTIF_MC_AUCUNE_REPLIC
           else if (length(s) < B_MIN_DEGENERESCENCE) MOTIF_MC_REPLIC_INSUFFISANTES
           else if (ponctuelle && abs(obs - s[1]) <= tol) MOTIF_MC_DISPERSION_NULLE
           else if (ponctuelle) MOTIF_MC_ATOME_HORS_OBS
           else NA_character_
  p <- if (!is.na(motif)) NA_real_ else
    switch(queue,
           haut = (1 + sum(s >= obs)) / (length(s) + 1),
           bas  = (1 + sum(s <= obs)) / (length(s) + 1),
           deux = 2 * min((1 + sum(s >= obs)) / (length(s) + 1),
                          (1 + sum(s <= obs)) / (length(s) + 1)))
  p <- pmin(p, 1)
  k <- if (queue == "deux") 2 else 1
  list(p_mc = p, err_mc = sqrt(p * (k - p) / pmax(B_eff, 1)), B_effectif = B_eff,
       granularite = if (B_eff > 0) k / (B_eff + 1) else NA_real_,
       motif = motif)
}

# Applique engine_p_mc() a chaque colonne de la matrice des simulations, le
# sens du rejet etant lu au catalogue. Une statistique absente du catalogue
# leve une erreur.
# e : contexte OBSERVE (celui qui a produit obs) ; s'il est fourni, les
# conditions `degenere` et `non_definie` du catalogue y sont evaluees une
# fois (#44, regle R2) : degenere(e) TRUE -> p_mc et err_mc NA, motif
# MOTIF_MC_CONDITION (sauf motif d'engine_p_mc() deja pose, hors
# MOTIF_MC_REPLIC_INSUFFISANTES et MOTIF_MC_AUCUNE_REPLIC, que la condition
# remplace : elle porte sur les donnees observees, non sur le nombre de
# simulations finies, et une statistique degeneree n'a aucune p retenue,
# jamais de repli asymptotique (ADR 0001 ; #128). MOTIF_MC_OBS_NON_FINIE
# n'est pas remplace : la statistique observee n'existe pas) ; statistique
# observee non finie et non_definie(e) renseigne -> ce motif remplace le motif
# generique. Rend en plus motif_mc, vecteur nomme de chaines (NA si p_mc est
# calculee).
.mc_p_values <- function(sim, obs, catalogue, e = NULL) {
  noms <- colnames(sim)
  inconnus <- setdiff(noms, names(catalogue))
  if (length(inconnus))
    stop("statistique(s) Monte-Carlo absente(s) du catalogue : ",
         paste(inconnus, collapse = ", "))
  r <- lapply(noms, function(nm) {
    o <- engine_p_mc(sim[, nm], obs[[nm]], catalogue[[nm]]$queue)
    ent <- catalogue[[nm]]
    if (!is.null(e) && !is.null(ent$degenere) &&
        (is.na(o$motif) ||
         o$motif %in% c(MOTIF_MC_REPLIC_INSUFFISANTES, MOTIF_MC_AUCUNE_REPLIC))) {
      dg <- ent$degenere(e)
      if (!(is.logical(dg) && length(dg) == 1L && !is.na(dg)))
        stop("catalogue Monte-Carlo : degenere(", nm, ") doit rendre TRUE ou FALSE")
      if (dg) { o$p_mc <- NA_real_; o$err_mc <- NA_real_; o$motif <- MOTIF_MC_CONDITION }
    }
    if (!is.null(e) && !is.null(ent$non_definie) &&
        identical(o$motif, MOTIF_MC_OBS_NON_FINIE)) {
      nd <- ent$non_definie(e)
      if (!(is.character(nd) && length(nd) == 1L))
        stop("catalogue Monte-Carlo : non_definie(", nm, ") doit rendre une chaine")
      if (!is.na(nd)) o$motif <- nd
    }
    o
  })
  champ <- function(k) stats::setNames(vapply(r, function(o) o[[k]], numeric(1)), noms)
  list(p_mc = champ("p_mc"), err_mc = champ("err_mc"), B_effectif = champ("B_effectif"),
       granularite = champ("granularite"),
       motif_mc = stats::setNames(vapply(r, function(o) o$motif, character(1)), noms))
}

# --- Enregistrement des lignes de resultat des tests --------------------------
# Fonction unique, partagee par usp_tests() et mw_tests() (ADR 0003, point 2).
# Renvoie list(add, lignes) : add() enregistre une ligne, lignes() rend la
# liste des lignes enregistrees. Parametres :
#   boot      : objet bootstrap (p_mc et err_mc nommes)
#   catalogue : catalogue Monte-Carlo de la methode
#   alpha     : seuil des verdicts
#   nature_mc : libelle de la nature d'une p-value de Monte-Carlo retenue
# Grandeurs strictement separees dans chaque ligne :
#   stat        : STATISTIQUE DE TEST (loi de reference connue ou simulee)
#   estim       : ESTIMATION / grandeur descriptive (aucune loi de reference)
#   p_exacte / p_asymptotique / p_mc : les trois p-values possibles
#   p_retenue + nature_p : celle effectivement utilisee pour le verdict
#   err_mc      : erreur de Monte-Carlo (liee a B), a ne PAS confondre avec
#                 l'erreur d'approximation statistique (liee a T)
#   p_min       : p-value minimale atteignable (loi de reference discrete aux
#                 effectifs observes ; NA pour une loi continue), regle R1
#                 de #44 : voir plus bas
#   effectifs   : effectifs de la loi discrete, imprimes entre parentheses
#                 avec p_min ; si p_min est NA, la chaine est restituee telle
#                 quelle dans detail (elle porte alors le motif de l'absence
#                 de p_min ; #70)
#   fonction    : provenance de la ligne (#111), argument obligatoire, dernier
#                 champ de la ligne : nom de la fonction nommee du moteur qui
#                 calcule stat (a defaut estim), appelee directement ou par la
#                 fermeture calc du catalogue (DW -> stat_dw, Grubbsr ->
#                 test_grubbs) ; a defaut (calcul en ligne par stats:: dans le
#                 corps, fermeture anonyme du catalogue), "usp_tests" ou
#                 "mw_tests". usp_bootstrap et .mc_evaluer ne sont jamais une
#                 provenance. Chaine litterale a chaque appel, independante des
#                 donnees et du regime (une ligne non applicable garde la
#                 sienne). Refus : absente, non chaine, vide, ou inconnue de
#                 l'environnement du moteur (exists(mode = "function",
#                 inherits = FALSE)).
#   inoperant   : indicateur logique de test inoperant (#129, point 3), pose
#                 sur chaque ligne apres fonction : TRUE si et seulement si la
#                 bascule de la regle R1 ci-dessous a eu lieu (p_min >= alpha,
#                 detail prefixe "TEST INOPERANT"), FALSE sinon, jamais NA
#                 (ligne R3, ligne sans aucune p-value du point 2' de #128 :
#                 FALSE). Les affichages lisent ce champ, pas le prefixe.
# Motif d'indisponibilite Monte-Carlo (#44, regle R3) : si mc_nom est
# renseigne et p_mc absente, le motif est lu dans boot$motif_mc (produit par
# engine_p_mc() / .mc_p_values(), jamais devine) quand l'appelant n'en
# fournit pas, puis, pour une ligne de type "test" :
#   - motif de degenerescence (motifs_degeneres ci-dessous)
#     -> diagnostic (INFO), detail prefixe du motif, aucune p retenue, jamais
#     de repli sur une autre p-value (ADR 0001) ; le prefixe est suivi du
#     complement de COMPLEMENTS_MOTIF_MC s'il y en a un (#126) ;
#   - MOTIF_MC_OBS_NON_FINIE, sans p exacte -> "non applicable", detail
#     prefixe du motif ;
#   - autre motif (aucune replication finie, replications finies
#     insuffisantes, statistique non definie d'apres le catalogue), sans p
#     exacte, avec p asymptotique -> repli NOMME :
#     nature "asymptotique (Monte-Carlo indisponible : <motif>)", si
#     repli_asymptotique (defaut TRUE) ; sinon (repli_asymptotique = FALSE,
#     ligne "Nullite de la constante") -> diagnostic, detail prefixe
#     "Monte-Carlo indisponible : <motif> ; <libelle_p_as> non retenue".
# Une ligne a p exacte finie garde sa p exacte retenue (hierarchie), hors
# degenerescence (MOTIF_MC_DISPERSION_NULLE, MOTIF_MC_ATOME_HORS_OBS,
# MOTIF_MC_CONDITION), qui ecarte aussi la p exacte.
# Une ligne qui reste de type "test" sans aucune p-value garde type, verdict
# INFO, sens et p_retenue = NA ; son detail le dit en tete (#128, point 2').
# Une p Monte-Carlo retenue dont le plancher (granularite_stat) rend un
# verdict inatteignable au seuil alpha est mentionnee en fin de detail (#128,
# point d).
engine_registre_tests <- function(boot, catalogue, alpha, nature_mc) {
  pmc <- boot$p_mc; emc <- boot$err_mc; mmc <- boot$motif_mc
  gmc <- boot$granularite_stat
  motifs_degeneres <- c(MOTIF_MC_DISPERSION_NULLE, MOTIF_MC_ATOME_HORS_OBS,
                        MOTIF_MC_CONDITION)
  L <- list()
  add <- function(fam, nom, ref, type = "test",
                  H0 = NA_character_, H1 = NA_character_,
                  stat_nom = NA_character_, stat = NA_real_,
                  loi = NA_character_,
                  estim_nom = NA_character_, estim = NA_real_,
                  p_ex = NA_real_, p_as = NA_real_, mc_nom = NA_character_,
                  detail = "", verdict = NULL, sens = "ne pas rejeter",
                  motif_non_mc = NA_character_, nature_forcee = NA_character_,
                  base = "commun", variante = "principale",
                  p_min = NA_real_, effectifs = NA_character_,
                  repli_asymptotique = TRUE, libelle_p_as = "p asymptotique",
                  p_mc_ext = NA_real_, err_mc_ext = NA_real_, fonction) {
    # Provenance de la ligne (#111, regle A1) : fonction est obligatoire et
    # doit nommer une fonction definie dans l'environnement du moteur
    # (inherits = FALSE : une fonction de stats, "cor.test", est refusee ;
    # mode = "function" : une constante du moteur, "ANNEXE_II", aussi).
    # Une ligne sans provenance verifiable est une erreur de programmation.
    if (missing(fonction))
      stop("add() : argument fonction absent (", nom, ")", call. = FALSE)
    if (!is.character(fonction) || length(fonction) != 1L || is.na(fonction) ||
        !nzchar(fonction))
      stop("add() : fonction doit etre une chaine non vide (", nom, ")", call. = FALSE)
    if (!exists(fonction, envir = environment(engine_registre_tests), mode = "function",
                inherits = FALSE))
      stop("add() : fonction inconnue du moteur : ", fonction, " (", nom, ")", call. = FALSE)
    # Refus explicite (ADR 0003, point 3) : une statistique Monte-Carlo
    # inconnue du catalogue, ou absente de l'objet bootstrap, est une erreur
    # de programmation ; le repli silencieux sur l'asymptotique est interdit.
    if (!is.na(mc_nom)) {
      if (!mc_nom %in% names(catalogue))
        stop("add() : statistique Monte-Carlo inconnue du catalogue : ", mc_nom, " (", nom, ")")
      if (!mc_nom %in% names(pmc) || !mc_nom %in% names(emc))
        stop("add() : statistique Monte-Carlo absente du bootstrap : ", mc_nom, " (", nom, ")")
    }
    # p Monte-Carlo calculee hors du bootstrap principal (issue #45 : bootstrap
    # restreint du rapport de vraisemblance sur delta, usp_lr_delta()) :
    # admise seulement sans mc_nom, une ligne ne lisant jamais deux sources.
    # Le motif d'indisponibilite eventuel est mis dans detail par l'appelant.
    ext <- !is.na(p_mc_ext) || !is.na(err_mc_ext)
    if (ext && !is.na(mc_nom))
      stop("add() : p_mc_ext et mc_nom ne peuvent etre fournis ensemble (", nom, ")")
    p_mc <- if (!is.na(mc_nom)) unname(pmc[[mc_nom]]) else NA_real_
    e_mc <- if (!is.na(mc_nom)) unname(emc[[mc_nom]]) else NA_real_
    if (ext) { p_mc <- unname(p_mc_ext); e_mc <- unname(err_mc_ext) }
    # Regle R3 (#44) : motif d'indisponibilite lu au bootstrap.
    motif_boot <- if (!is.na(mc_nom) && !is.finite(p_mc) && !is.null(mmc) &&
                      mc_nom %in% names(mmc)) unname(mmc[[mc_nom]]) else NA_character_
    if (type == "test" && !is.na(motif_boot)) {
      if (motif_boot %in% motifs_degeneres) {
        type <- "diagnostic"
        detail <- trimws(paste(c(paste0(motif_boot, " : aucune p-value retenue (ADR 0001)."),
                                 .complement_motif_mc(motif_boot), detail), collapse = " "))
      } else if (!is.finite(p_ex) && identical(motif_boot, MOTIF_MC_OBS_NON_FINIE)) {
        type <- "non applicable"
        detail <- trimws(paste0(motif_boot, " : test non applicable. ", detail))
      } else if (!is.finite(p_ex) && is.na(motif_non_mc)) {
        if (isTRUE(repli_asymptotique)) {
          motif_non_mc <- paste("Monte-Carlo indisponible :", motif_boot)
        } else if (is.finite(p_as)) {
          # Repli interdit par l'appelant (#44, reprise, constat 2 d'audit) :
          # la p non simulee ne vaut pas sous le modele reglementaire, elle
          # n'est pas retenue a la place de la p Monte-Carlo absente.
          type <- "diagnostic"
          detail <- trimws(paste0("Monte-Carlo indisponible : ", motif_boot, " ; ",
                                  libelle_p_as, " non retenue (ADR 0001). ", detail))
        }
      }
    }
    # Ligne sans aucune p-value (p exacte, Monte-Carlo et asymptotique toutes
    # non finies) : aucun verdict n'est possible (#128, point 2', decision du
    # mainteneur du 01/10/2026).
    aucune_p <- !is.finite(p_ex) && !is.finite(p_mc) && !is.finite(p_as)
    # Plancher de la p Monte-Carlo du bootstrap quand elle sera retenue (pas
    # de p exacte, p_mc finie, hors p_mc_ext) : g = granularite_stat
    # (1/(B_eff + 1), 2/(B_eff + 1) en bilateral), plus petite valeur
    # possible de p_mc ; NA sinon. Lu par la regle R1 et par la mention du
    # plancher ci-dessous (#128, point d), dans la meme arithmetique.
    g_mc <- if (!is.finite(p_ex) && is.finite(p_mc) && !ext && !is.na(mc_nom) &&
                !is.null(gmc) && mc_nom %in% names(gmc)) unname(gmc[[mc_nom]]) else NA_real_
    plancher_echec <- is.finite(g_mc) && g_mc >= alpha / 2
    # Regle R1 (#44, ADR 0001, CONTEXT.md "Test inoperant") : p_min >= alpha
    # -> aucune valeur observee ne peut donner p < alpha, la ligne est
    # restituee en diagnostic (donc INFO, sans p retenue ni sens), ses
    # p-values calculees etant conservees ; alpha/2 <= p_min < alpha en sens
    # "ne pas rejeter" -> la ligne reste un test. Le critere ne depend pas du
    # sens : en sens "rejeter", un OK exige p < alpha.
    # p_min est calculee sur la loi de reference discrete (loi echangeable).
    # Avec une p exacte finie, c'est la p_min de la p retenue : ECHEC
    # inatteignable. Sans p exacte mais avec une p Monte-Carlo ou
    # asymptotique (pi_t variable, regle R7 : p Monte-Carlo retenue, simulee
    # sous le modele ajuste), p_min n'est pas une borne de la p retenue, qui
    # peut lui etre inferieure (erreur Monte-Carlo, non-echangeabilite) :
    # l'ECHEC reste possible et le detail le dit (#44, option 3 d'actuary,
    # decision du 27/09/2026). La bascule en test inoperant (p_min >= alpha)
    # est maintenue dans ce cas ; son libelle precise que p_min est celle de
    # la loi de reference echangeable. Si le plancher Monte-Carlo g_mc rend
    # deja l'ECHEC inatteignable (g_mc >= alpha/2), la suite "ECHEC possible"
    # est omise : seule la comparaison de p_min a alpha/2 est ecrite, la
    # mention du plancher suit (#128, constat M1 d'audit). Sans aucune p (ex.
    # Cox-Stuart a m = 0),
    # la bascule garde les libelles de la p exacte ; la phrase "ECHEC
    # inatteignable" n'est pas ajoutee (#128, point 2') : elle laisserait
    # croire OK ou ALERTE possibles, alors qu'aucun verdict ne l'est. Le
    # prefixe "TEST INOPERANT" reste en tete du detail ; la bascule pose en
    # outre inoperant = TRUE, que lit type_ligne() de display_helpers.R
    # (#129, point 3).
    inoperant <- FALSE
    if (type == "test" && is.finite(p_min)) {
      eff <- if (!is.na(effectifs)) paste0(" (", effectifs, ")") else ""
      # Meme condition que l'ancien suffixe d'approximation : p exacte absente,
      # p Monte-Carlo ou asymptotique presente.
      sans_p_ex <- !is.finite(p_ex) && (is.finite(p_mc) || is.finite(p_as))
      if (p_min >= alpha) {
        type <- "diagnostic"
        inoperant <- TRUE
        lib_pmin <- if (!sans_p_ex) "p-value minimale atteignable" else
          "p-value minimale atteignable sous la loi de reference echangeable"
        detail <- trimws(paste0(sprintf("TEST INOPERANT au seuil alpha = %g : %s = %.4f%s ; aucun verdict (ADR 0001).",
                                        alpha, lib_pmin, p_min, eff),
                                " ", detail))
      } else if (identical(sens, "ne pas rejeter") && p_min >= alpha / 2 && !aucune_p) {
        sep <- if (!nzchar(detail)) "" else if (grepl("\\.$", detail)) " " else " ; "
        # Sans p exacte, la suite du texte suit la p qui sera retenue par la
        # hierarchie ci-dessous (Monte-Carlo, sinon asymptotique).
        txt_r1 <- if (!sans_p_ex)
          sprintf("ECHEC inatteignable : p_min = %.4f >= alpha/2 = %g%s", p_min, alpha / 2, eff)
        else paste0(
          sprintf("p_min de la loi de reference echangeable = %.4f >= alpha/2 = %g%s", p_min, alpha / 2, eff),
          if (is.finite(p_mc) && plancher_echec)
            ""
          else if (is.finite(p_mc))
            paste(" ; la p-value Monte-Carlo retenue, simulee sous le modele ajuste, peut",
                  "lui etre inferieure (erreur Monte-Carlo, non-echangeabilite) : ECHEC possible")
          else
            paste(" ; la p-value asymptotique retenue, calculee hors de cette loi, peut",
                  "lui etre inferieure : ECHEC possible"))
        detail <- trimws(paste0(detail, sep, txt_r1))
      }
    }
    # Restitution du motif de l'absence de p_min (#70, 5a) : pour un test
    # sans p_min, la chaine effectifs, qui porte alors ce motif (ex aequo des
    # lignes de rangs), est ajoutee telle quelle au detail, avec le separateur
    # de la branche "ECHEC inatteignable". Les lignes non applicables ne sont
    # pas concernees.
    if (type == "test" && !is.finite(p_min) && !is.na(effectifs)) {
      sep <- if (!nzchar(detail)) "" else if (grepl("\\.$", detail)) " " else " ; "
      detail <- trimws(paste0(detail, sep, effectifs))
    }
    # Test sans aucune p-value (#128, point 2') : type, verdict INFO, sens et
    # p_retenue = NA inchanges (decision du 27/09/2026, "Test sans p-value
    # retenue") ; le detail le dit en tete, precede du motif Monte-Carlo
    # (motif_boot) s'il existe et n'y figure pas deja.
    if (type == "test" && aucune_p) {
      pre_mc <- if (!is.na(motif_boot) && !grepl(motif_boot, detail, fixed = TRUE))
        paste0("Monte-Carlo indisponible : ", motif_boot, " ; ") else ""
      detail <- trimws(paste0(pre_mc, "aucune p-value disponible sur ces donnees :",
                              " aucun verdict (ADR 0001). ", detail))
    }
    # Hierarchie adaptee a T faible : exacte > Monte-Carlo > asymptotique.
    if (is.finite(p_ex)) {
      p_ret <- p_ex; nature <- "exacte"
    } else if (is.finite(p_mc)) {
      p_ret <- p_mc; nature <- nature_mc
    } else if (is.finite(p_as)) {
      p_ret <- p_as
      nature <- if (!is.na(motif_non_mc))
        paste0("asymptotique (", motif_non_mc, ")") else "asymptotique"
    } else {
      p_ret <- NA_real_; nature <- NA_character_
    }
    if (!is.na(nature_forcee) && is.finite(p_ret)) nature <- nature_forcee
    # Plancher Monte-Carlo relatif a alpha (#128, point d ; residu du constat
    # C1 de la revue finale d'E1) : quand la p Monte-Carlo du bootstrap est
    # retenue, sa plus petite valeur possible est g_mc (ci-dessus). Comparee dans
    # l'arithmetique de la regle des verdicts ci-dessous : en sens "ne pas
    # rejeter", g >= alpha/2 rend l'ECHEC inatteignable (seul OK si
    # g >= alpha) ; en sens "rejeter", g >= alpha rend le OK inatteignable.
    # Mention seule : ni motif, ni changement de type, ni extension de R1
    # (decision du mainteneur du 01/10/2026). Sans objet pour p_mc_ext
    # (aucune granularite). Ni g_mc ni B effectif ne sont imprimes (regle
    # #76 : aucun nombre issu du bootstrap dans detail) ; ils restent lisibles
    # dans bootstrap$granularite_stat et bootstrap$B_effectif. alpha, qui est
    # un parametre, l'est.
    if (type == "test" && is.null(verdict) && is.finite(g_mc)) {
      txt_g <- if (identical(sens, "rejeter") && g_mc >= alpha)
        sprintf("plancher Monte-Carlo >= alpha = %g : OK inatteignable", alpha)
      else if (identical(sens, "ne pas rejeter") && g_mc >= alpha)
        sprintf("plancher Monte-Carlo >= alpha = %g : seul OK atteignable", alpha)
      else if (identical(sens, "ne pas rejeter") && g_mc >= alpha / 2)
        sprintf("plancher Monte-Carlo >= alpha/2 = %g : ECHEC inatteignable", alpha / 2)
      else NULL
      if (!is.null(txt_g)) {
        sep <- if (!nzchar(detail)) "" else if (grepl("\\.$", detail)) " " else " ; "
        detail <- trimws(paste0(detail, sep, txt_g))
      }
    }
    # ADR 0001 (amendement du 23/09/2026, M7) : seule une ligne de type "test"
    # ou "procedure de decision" porte un verdict. Toute autre ligne sort
    # INFO et son sens est NA ; un verdict fourni pour un autre type est une
    # erreur de programmation, refusee ici pour que l'invariant ne puisse pas
    # etre contourne par un appel.
    porte_verdict <- type %in% c("test", "procedure de decision")
    if (!is.null(verdict) && !porte_verdict)
      stop("add() : un verdict n'est admis que pour type = 'test' ou 'procedure de decision' (ADR 0001) : ", nom)
    # La procedure de decision (ESD) decide sans p-value : son verdict est
    # toujours fourni par l'appelant ; l'omettre est une erreur de programmation.
    if (type == "procedure de decision" && is.null(verdict))
      stop("add() : une ligne de type 'procedure de decision' doit fournir son verdict : ", nom)
    # Sans verdict, ni sens ni p-value retenue (ADR 0001, CONTEXT.md).
    if (!porte_verdict) {
      sens <- NA_character_; p_ret <- NA_real_; nature <- NA_character_
    }
    v <- if (!is.null(verdict)) verdict
    else if (type != "test" || !is.finite(p_ret)) "INFO"
    else if (sens == "rejeter") {
      if (p_ret < alpha) "OK" else if (p_ret < SEUIL_ECHEC_SENS_REJETER) "ALERTE" else "ECHEC"
    } else {
      if (p_ret < alpha / 2) "ECHEC" else if (p_ret < alpha) "ALERTE" else "OK"
    }
    L[[length(L) + 1]] <<- list(
      famille = fam, test = nom, reference = ref, type = type,
      base = base, variante = variante,
      H0 = H0, H1 = H1,
      stat_nom = stat_nom, stat = stat, loi = loi,
      estim_nom = estim_nom, estim = estim,
      p_exacte = p_ex, p_asymptotique = p_as, p_mc = p_mc, err_mc = e_mc,
      p_retenue = p_ret, nature_p = nature,
      verdict = v, detail = detail, sens = sens,
      # p_min en fin de ligne (#44, Q1 (a)) : un champ ajoute en fin de
      # conteneur ne deplace aucun champ existant des references.
      p_min = p_min,
      # fonction apres p_min (#111, regle A4), pour la meme raison.
      fonction = fonction,
      # inoperant apres fonction (#129, point 3), pour la meme raison.
      inoperant = inoperant)
  }
  list(add = add, lignes = function() L)
}

usp_bootstrap <- function(fit, B = 999, seed = 20260831, refit = TRUE,
                          progres = FALSE) {
  # Tirages sous graine locale (ADR 0004, #42) : etat de l'appelant restaure.
  # Contexte observe, conserve pour l'evaluation des conditions du catalogue
  # (degenere, non_definie) par .mc_p_values() (#44).
  e_obs <- .usp_contexte_mc(fit$x, fit$y, fit$z)
  engine_sous_graine(seed, {
    stats_obs <- .mc_evaluer(USP_CATALOGUE_MC, e_obs)
    noms <- names(stats_obs)
    sim <- matrix(NA_real_, B, length(noms), dimnames = list(NULL, noms))
    sig <- del <- gam <- sig_r <- rep(NA_real_, B)
    n_echec_r <- 0L
    # Residus reajustes de chaque replication retenue (issue #47), colonnes =
    # annees t (non triees) ; ligne NA si la replication est ecartee.
    zb <- matrix(NA_real_, B, length(fit$x))
    for (b in seq_len(B)) {
      yb <- usp_simuler(fit)
      fb <- if (refit) {
        f <- try(usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
        if (inherits(f, "try-error")) next else f
      } else usp_noyau(fit$delta, fit$gamma, fit$x, yb, fit$xbar)
      sb <- try(.stats_bootstrapables(fit$x, yb, fb$z), silent = TRUE)
      if (inherits(sb, "try-error")) next
      sim[b, ] <- sb[noms]
      zb[b, ] <- fb$z
      sig[b] <- fb$sigma
      if (!is.null(fb$delta)) { del[b] <- fb$delta; gam[b] <- fb$gamma }
      # Bootstrap restreint (issue #45) : sur les MEMES y*, reajustement a
      # delta fixe a sa valeur estimee (seul gamma reajuste), apres le
      # bootstrap principal. Aucun alea consomme. Un echec laisse sig_r[b] a
      # NA et n'ecarte la replication que du bootstrap restreint (compte dans
      # n_echec_restreint) ; le bootstrap principal n'en depend pas.
      fr <- try(usp_ajuster_contraint(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
      if (inherits(fr, "try-error")) n_echec_r <- n_echec_r + 1L
      else sig_r[b] <- fr$sigma
      if (progres && b %% 100 == 0) cat(".")
    }
    if (progres) cat("\n")
  })

  # P-values de Monte-Carlo, erreur de Monte-Carlo et B effectif, le sens du
  # rejet etant lu au catalogue USP_CATALOGUE_MC.
  mc <- .mc_p_values(sim, stats_obs, USP_CATALOGUE_MC, e_obs)

  # granularite : 1 / (B + 1) sur B nominal, pas elementaire unilateral (champ
  # affiche par app.R et display_helpers.R). granularite_stat : pas par
  # statistique, 1 / (B_eff + 1), ou 2 / (B_eff + 1) en bilateral (issue #40) ;
  # place en fin de liste pour ne pas deplacer les champs existants.
  # motif_mc (#44, regle R2) : motif d'indisponibilite de chaque p_mc (NA si
  # calculee), en fin de liste pour la meme raison.
  list(stats_obs = as.list(stats_obs), p_mc = mc$p_mc, err_mc = mc$err_mc,
       B_effectif = mc$B_effectif, granularite = 1 / (B + 1),
       sigma_boot = sig[is.finite(sig)],
       delta_boot = del[is.finite(del)], gamma_boot = gam[is.finite(gam)], B = B,
       granularite_stat = mc$granularite, motif_mc = mc$motif_mc,
       # Bootstrap restreint a delta fixe (issue #45), en fin de liste.
       sigma_boot_restreint = sig_r[is.finite(sig_r)],
       # Replications retenues par le bootstrap principal et ecartees du
       # restreint (echec du reajustement contraint).
       n_echec_restreint = n_echec_r,
       # Residus reajustes z* des replications (issue #47, option A) : matrice
       # B x T, ligne b remplie si et seulement si la replication b est
       # retenue (sim[b, ] rempli), NA sinon. Source de l'enveloppe du
       # QQ-plot (engine_enveloppe_qq()). En fin de liste.
       z_boot = zb)
}

# Reajustement rapide des replications bootstrap (usp_bootstrap()), unique
# reajusteur de la loi bootstrap. Trois demarrages, dans cet ordre :
# (d0, g0) (l'optimum observe), (0, g0) et (1, g0) ; objectif minimal
# retenu, avec la regle du PREMIER demarrage a moins de 1e-10 de l'objectif
# (celle de usp_ajuster()) (issue #109, correctif R3, decision du mainteneur
# du 28/09/2026). Motif : demarre a chaud du seul (d0, g0), l'ajusteur
# restait dans le bassin du bord de depart et manquait l'optimum de
# usp_ajuster() (ecart d'objectif > 1e-6) dans 0,37 % (J1) et 0,68 % (J2)
# des replications (mesure de #43, tests/comparer_ajusteurs_bootstrap.R).
# Gradient analytique et factr = 1e4 (1e7 avant #63, divise par 1000 ;
# decision du mainteneur du 28/09/2026, voir usp_ajuster()). Un demarrage
# en erreur ou a objectif non fini est ecarte ; erreur si aucun n'aboutit
# (replication ecartee par usp_bootstrap()).
usp_ajuster_rapide <- function(x, y, d0, g0) {
  xbar <- mean(x)
  best <- NULL
  for (d_dep in c(d0, 0, 1)) {
    f <- try(stats::optim(c(d_dep, g0), usp_objectif, gr = usp_gradient_optim,
                          x = x, y = y, xbar = xbar,
                          method = "L-BFGS-B",
                          lower = c(0, BORNES_GAMMA[1]), upper = c(1, BORNES_GAMMA[2]),
                          control = list(factr = 1e4, maxit = 200)), silent = TRUE)
    if (inherits(f, "try-error") || !is.finite(f$value)) next
    if (is.null(best) || f$value < best$value - 1e-10) best <- f
  }
  if (is.null(best)) stop("Reajustement rapide : aucun demarrage abouti.")
  k <- usp_noyau(best$par[1], best$par[2], x, y, xbar)
  c(k, list(delta = best$par[1], gamma = best$par[2], T = length(x),
            x = x, y = y, xbar = xbar))
}

# Ajustement du modele a delta FIXE (issue #45, specification d'actuary du
# 28/09/2026, par. 2.1) : gamma~ = argmin_gamma O(delta0, gamma) sur
# BORNES_GAMMA par stats::optimize() a la tolerance TOL_GAMMA_CONTRAINT ;
# ln(beta~) par la forme fermee de usp_noyau(). Regle du point admissible :
# si O(delta0, gamma_depart) < O(delta0, gamma~) - TOL_OPTIMUM, le point de
# depart est retenu (garde contre un echec d'optimize()). Retour de meme
# forme que usp_ajuster_rapide(), donc utilisable par usp_simuler().
# Erreur si l'objectif retenu n'est pas fini (usp_objectif() rend 1e12 pour
# un objectif non fini).
usp_ajuster_contraint <- function(x, y, delta0, gamma_depart) {
  xbar <- mean(x)
  f <- function(g) usp_objectif(c(delta0, g), x, y, xbar)
  o <- stats::optimize(f, interval = BORNES_GAMMA, tol = TOL_GAMMA_CONTRAINT)
  g <- o$minimum
  if (is.finite(gamma_depart) && f(gamma_depart) < o$objective - TOL_OPTIMUM)
    g <- gamma_depart
  k <- usp_noyau(delta0, g, x, y, xbar)
  if (!is.finite(k$obj) || !is.finite(k$sigma))
    stop("Ajustement a delta fixe : objectif non fini.")
  c(k, list(delta = delta0, gamma = g, T = length(x), x = x, y = y, xbar = xbar))
}

# p asymptotique du melange 1/2 chi2(0) + 1/2 chi2(1) pour un LR >= 0
# (issue #45) : 1 si LR = 0 (atome du melange), 0,5 P(chi2(1) > LR) sinon.
.p_melange_chernoff <- function(lr)
  if (lr == 0) 1 else 0.5 * stats::pchisq(lr, 1, lower.tail = FALSE)

# Rapport de vraisemblance sur delta aux bornes delta0 = 0 et delta0 = 1
# (issue #45, specification d'actuary du 28/09/2026, par. 2.2 ; decisions du
# mainteneur du 28/09/2026, Q1 a Q7). LR(delta0) = O(delta0, gamma~0) -
# obj_min, O etant -2 log-vraisemblance profilee en beta (usp_noyau()),
# ramene a 0 sous TOL_OPTIMUM (difference de deux optimisations). Loi sous
# H0 : delta = delta0 simulee par bootstrap parametrique RESTREINT, sous le
# modele contraint ajuste (gamma~0, beta~0) ; B et graine de l'appel, une
# pose de graine par borne (nombres aleatoires communs aux deux bornes ; a la
# borne ou se trouve delta estime, les y* sont ceux du bootstrap principal).
# Chaque replication : reajustement libre par usp_ajuster_rapide() (trois
# demarrages, depuis (fit_c$delta, fit_c$gamma) : a la borne ou se trouve
# delta estime, fit_c = fit et ce reajustement est celui du bootstrap
# principal) et reajustement contraint par usp_ajuster_contraint() ;
# LR* = max(0, O_c - O_libre), ramene a 0 sous TOL_OPTIMUM ; echec de l'un
# ou de l'autre -> replication ecartee (n_echec). n_refit_pire compte les
# replications ou le reajustement libre est plus mauvais que le contraint
# de plus de TOL_OPTIMUM (attendu 0). p_mc par engine_p_mc(), queue haute.
# p_asymptotique : melange 1/2 chi2(0) + 1/2 chi2(1) (Chernoff, 1954 ; Self
# et Liang, 1987), POUR MEMOIRE (.p_melange_chernoff()).
# Aucune p-value retenue ni verdict (lignes de diagnostic de usp_tests()).
# Echec sur les donnees OBSERVEES (#161, decision du mainteneur du
# 30/09/2026) : si l'ajustement contraint de la borne leve une erreur, ou si
# le LR observe n'est pas fini, la borne est rendue avec la meme liste de
# champs, valeurs a NA (delta0 conserve), sans bootstrap restreint
# (lr_boot vide, B_effectif = 0, motif_mc = MOTIF_MC_OBS_NON_FINIE par
# engine_p_mc(), n_refit_pire et n_echec NA : aucune replication tentee),
# au lieu d'interrompre run_engine() ; l'autre borne, qui pose sa propre
# graine, n'en depend pas. La ligne G de usp_tests() lit lr non fini et
# rend "non applicable" avec MOTIF_LR_DELTA_ECHEC.
MOTIF_LR_DELTA_ECHEC <- paste(
  "Rapport de vraisemblance non calculable sur les donnees observees",
  "(ajustement a delta fixe a la borne en echec) : diagnostic non applicable,",
  "aucun bootstrap restreint.")
usp_lr_delta <- function(fit, B = 999, seed = 20260831) {
  x <- fit$x; y <- fit$y
  borne_en_echec <- function(d0) {
    mc <- engine_p_mc(numeric(0), NA_real_, "haut")
    list(delta0 = d0, gamma_contraint = NA_real_, beta_contraint = NA_real_,
         sigma_contraint = NA_real_, obj_contraint = NA_real_, lr = NA_real_,
         p_asymptotique = NA_real_, p_mc = mc$p_mc, err_mc = mc$err_mc,
         B_effectif = mc$B_effectif, granularite = mc$granularite,
         motif_mc = mc$motif, part_lr_nul = NA_real_,
         n_refit_pire = NA_integer_, n_echec = NA_integer_, lr_boot = numeric(0))
  }
  une_borne <- function(d0) {
    au_bord <- abs(fit$delta - d0) <= TOL_DELTA_BORD
    fit_c <- if (au_bord) fit else
      try(usp_ajuster_contraint(x, y, d0, fit$gamma), silent = TRUE)
    if (inherits(fit_c, "try-error")) return(borne_en_echec(d0))
    obj_c <- fit_c$obj
    lr <- max(0, obj_c - fit$obj_min)
    if (!is.finite(lr)) return(borne_en_echec(d0))
    if (lr < TOL_OPTIMUM) lr <- 0
    p_as <- .p_melange_chernoff(lr)
    lr_b <- rep(NA_real_, B); n_pire <- 0L; n_echec <- 0L
    engine_sous_graine(seed, {
      for (b in seq_len(B)) {
        # usp_simuler() ne leve pas d'erreur (rnorm rend NaN, avec un
        # avertissement, si un parametre n'est pas fini) : un tirage non fini
        # est ecarte par les try() ci-dessous ou par la garde sur dif.
        yb <- usp_simuler(fit_c)
        fu <- try(usp_ajuster_rapide(x, yb, fit_c$delta, fit_c$gamma), silent = TRUE)
        fc <- try(usp_ajuster_contraint(x, yb, d0, fit_c$gamma), silent = TRUE)
        if (inherits(fu, "try-error") || inherits(fc, "try-error")) {
          n_echec <- n_echec + 1L; next
        }
        dif <- fc$obj - fu$obj
        if (!is.finite(dif)) { n_echec <- n_echec + 1L; next }
        if (-dif > TOL_OPTIMUM) n_pire <- n_pire + 1L
        l <- max(0, dif)
        lr_b[b] <- if (l < TOL_OPTIMUM) 0 else l
      }
    })
    lr_boot <- lr_b[is.finite(lr_b)]
    mc <- engine_p_mc(lr_boot, lr, "haut")
    list(delta0 = d0, gamma_contraint = fit_c$gamma, beta_contraint = fit_c$beta,
         sigma_contraint = fit_c$sigma, obj_contraint = obj_c, lr = lr,
         p_asymptotique = p_as, p_mc = mc$p_mc, err_mc = mc$err_mc,
         B_effectif = mc$B_effectif, granularite = mc$granularite,
         motif_mc = mc$motif,
         part_lr_nul = if (length(lr_boot)) mean(lr_boot == 0) else NA_real_,
         n_refit_pire = n_pire, n_echec = n_echec, lr_boot = lr_boot)
  }
  list(borne0 = une_borne(0), borne1 = une_borne(1), B = B, seed = seed,
       tol_nul = TOL_OPTIMUM)
}


## =============================================================================
## 5. ROBUSTESSE : JACKKNIFE, PROFIL DE VRAISEMBLANCE, TESTS DE RAPPORT
## =============================================================================

# Sensibilité au retrait d'une année. La crédibilité et la correction de taille
# sont maintenues à celles de l'échantillon complet : l'objectif est d'isoler
# l'effet de l'observation retirée sur l'estimation, non de rejouer les règles
# de l'annexe XVII sur un échantillon de T-1 années (qui pourrait passer sous
# le minimum de 5 années).
usp_jackknife <- function(fit, sigma_standard, bareme) {
  T <- fit$T
  cred <- usp_credibilite(T, bareme)
  corr <- sqrt((T + 1) / (T - 1))
  out <- data.frame(annee_retiree = 1:T, sigma = NA_real_, sigma_usp = NA_real_,
                    delta = NA_real_, gamma = NA_real_)
  for (i in 1:T) {
    xi <- fit$x[-i]; yi <- fit$y[-i]
    f <- try(usp_ajuster(xi, yi, n_starts_delta = 5), silent = TRUE)
    if (inherits(f, "try-error")) next
    out$sigma[i] <- f$sigma
    out$sigma_usp[i] <- cred * f$sigma * corr + (1 - cred) * sigma_standard
    out$delta[i] <- f$delta; out$gamma[i] <- f$gamma
  }
  out
}

# Echec isole (#161, decision du mainteneur du 30/09/2026) : un optimize()
# en erreur rend NA au point de grille concerne, au lieu d'interrompre
# run_engine() ; meme liste de champs, grilles inchangees. plots_data
# (profil_delta, profil_gamma) porte alors NA a ces points.
usp_profil <- function(fit, n = 41) {
  objectif_ou_na <- function(o)
    if (inherits(o, "try-error")) NA_real_ else o$objective
  gd <- seq(0, 1, length.out = n)
  pd <- vapply(gd, function(d) {
    objectif_ou_na(try(stats::optimize(
      function(g) usp_objectif(c(d, g), fit$x, fit$y, fit$xbar),
      interval = BORNES_GAMMA), silent = TRUE))
  }, numeric(1))
  gg <- seq(fit$gamma - 1.5, fit$gamma + 1.5, length.out = n)
  pg <- vapply(gg, function(g) {
    objectif_ou_na(try(stats::optimize(
      function(d) usp_objectif(c(d, g), fit$x, fit$y, fit$xbar),
      interval = c(0, 1)), silent = TRUE))
  }, numeric(1))
  # Le rapport de vraisemblance aux bornes de delta (anciens champs
  # lr_delta0 et lr_delta1, p chi2(1) naive jamais affichee) a une seule
  # definition, usp_lr_delta() (issue #45, decision Q4 du 28/09/2026).
  list(delta_grid = gd, delta_obj = pd, gamma_grid = gg, gamma_obj = pg)
}


## =============================================================================
## 6. BATTERIE DE TESTS COMPLÈTE
## =============================================================================

# Ligne "Points influents (distance de Cook)" de usp_tests() (#153) : type,
# estim et detail a partir des distances ck et de T. Garde "non applicable"
# sur le modele de RESET et White (#110) : une distance non finie rend la
# ligne non applicable avec son motif, estim = NA, au lieu de l'erreur R de
# if (any(ck > 4 / T)) sur NA. Cas vise : y exactement proportionnel a x
# (y = x/2). L'issue de lm() depend de la plateforme (BLAS, processeur,
# version de R) et des valeurs de x. Mesure pour x en puissances de 2
# (x = 2^(0:7), jeu des tests) : residus exactement nuls, D_t = 0/0 = NaN,
# sous le BLAS de reference et OpenBLAS 0.3.20 (noyaux Zen, Haswell) ; D_t
# fini sous OpenBLAS 0.3.20 (noyau SkylakeX). Pour un x quelconque, D_t
# fini issu du bruit d'arrondi (mesure, BLAS de reference, R 4.3.3,
# x = c(100, 150, 200, 300, 400, 500, 600, 700) : residus de l'ordre de
# 1e-16, max D_t = 0,2267, ligne "diagnostic" sans motif ; serie
# exactement proportionnelle : voir #188). x ecarte par lm() : jamais
# observe, issue possible.
.usp_ligne_cook <- function(ck, T) {
  if (!all(is.finite(ck)))
    return(list(type = "non applicable", estim = NA_real_,
                detail = paste("distance de Cook non finie (par exemple residus de",
                               "y = beta x tous nuls) : diagnostic non applicable")))
  list(type = "diagnostic", estim = max(ck),
       detail = sprintf("repere conventionnel 4/T = %.3f ; %d observation(s) au-dessus%s",
                        4 / T, sum(ck > 4 / T),
                        if (any(ck > 4 / T))
                          paste0(" (rangs ", paste(which(ck > 4 / T), collapse = ", "), ")") else ""))
}

# Domaine de validite (#153, critere amende du 02/10/2026) : run_engine()
# n'appelle usp_tests() que sur des series dont chaque valeur est dans
# [DOMAINE_NUMERIQUE_MIN ; DOMAINE_NUMERIQUE_MAX] (refus de #145 sinon). En
# appel direct hors de ce domaine, usp_tests() garantit seulement l'absence
# d'erreur R, pas la justesse des statistiques, des p-values ni des
# verdicts (mesure de #153, appel direct sur le jeu de l'issue et sur les
# donnees de test, x et y x 1e-164 et 1e-165 : TOST OK au lieu d'ALERTE ou
# d'ECHEC a l'echelle 1).
usp_tests <- function(fit, boot, alpha = 0.10,
                      theta_equiv = 0.10, delta_equiv = NULL,
                      robustesse = NULL, methode, lr_delta = NULL) {
  z <- fit$z; x <- fit$x; y <- fit$y; T <- fit$T
  # Citation des hypotheses H1-H4 dans le champ famille (issue #92) : les
  # quatre hypotheses sont au point B(2)(g) i. a iv. de l'annexe XVII pour la
  # methode du risque de primes, au point C(2)(e) i. a iv. pour la methode du
  # risque de reserve no 1 (B(2)(f) porte sur les depenses, C(2)(f) n'existe
  # pas). Le prefixe "B." a "E." reste la cle de GROUPES (display_helpers.R).
  # methode est obligatoire, sans valeur par defaut (revue finale de #88,
  # constat 3) : un defaut "premium" faisait citer B(2)(g) en silence a un
  # appel direct pour la reserve no 1.
  if (missing(methode))
    stop("usp_tests() : l'argument methode (\"premium\" ou \"reserve1\") est obligatoire.")
  if (!(is.character(methode) && length(methode) == 1L &&
        methode %in% c("premium", "reserve1")))
    stop("usp_tests() : methode doit valoir \"premium\" ou \"reserve1\".")
  pt_hyp <- if (methode == "premium") "B(2)(g)" else "C(2)(e)"
  cite_hyp <- function(i) sprintf("(annexe XVII %s(%s))", pt_hyp, i)
  fam_h4 <- paste("E. H4 - independance et validite du MV", cite_hyp("iv"))
  r <- y / x
  # Base alternative : ratios bruts centres. Voir la sous-section
  # "Choix de la base de residus" de la documentation.
  u <- r - mean(r)
  # Enregistrement des lignes de resultat : fonction partagee avec mw_tests()
  # (engine_registre_tests(), ADR 0003) ; une statistique Monte-Carlo absente
  # du catalogue ou du bootstrap leve une erreur.
  reg <- engine_registre_tests(boot, USP_CATALOGUE_MC, alpha,
                               nature_mc = "Monte-Carlo (bootstrap parametrique)")
  add <- reg$add
  # Regime de l'ajustement (usp_regime(), issue #31), calcule une seule fois
  # (#70) : il conditionne l'attribution des p exactes (regle R7 ci-dessous),
  # le libelle de la position de delta, des diagnostics de centrage et de
  # variance et de la ligne Runsr.
  regime <- usp_regime(fit$delta, fit$x)
  pi_constant <- regime$pi_constant
  # Regle R13 (#59, invariants I4 et I5) : a volumes constants
  # (usp_volumes_constants(), tolerance TOL_DELTA_BORD, seule definition), les
  # treize lignes qui regressent sur x ou partitionnent par x (constante,
  # TOST, pente, Fisher, R2, RESET, Spearman ratio / volume, Breusch-Pagan
  # Koenker et 1979, White, Goldfeld-Quandt, Brown-Forsythe, Smirnov) sont
  # restituees "non applicable" avec ce motif unique, au lieu d'etre
  # calculees sur le bruit d'arrondi, restituees en diagnostic par le motif
  # Monte-Carlo, ou absentes (Smirnov). Leurs fonctions rendent NA sous le
  # meme critere ; la liste des lignes ne depend pas du regime.
  vol_cst <- isTRUE(regime$volumes_constants)
  txt_vol_cst <- sprintf(paste("volumes x_t constants a la tolerance relative TOL_DELTA_BORD",
                               "= %g pres (etendue relative = %.2g) : regression / partition",
                               "sur le volume sans objet"),
                         TOL_DELTA_BORD, diff(range(x)) / mean(x))
  si_vol_cst <- function(type) if (vol_cst) "non applicable" else type
  detail_vol <- function(detail) if (vol_cst) txt_vol_cst else detail
  # Regle R12 (garde-fou, #168) : hors volumes constants, lm(y ~ x) peut
  # encore ecarter x pour colinearite numerique. Motif commun des lignes
  # constante, TOST, pente, Fisher (txt_r12_test) et R2 ; la priorite reste
  # au motif R13. detail_r12() rend txt_r12_test si la fonction de la ligne
  # signale le garde-fou (champ x_ecarte), detail_vol(detail) sinon.
  txt_r12 <- "x ecarte par lm() pour colinearite"
  txt_r12_test <- paste0("regression de y sur x : ", txt_r12, ", test non applicable")
  detail_r12 <- function(x_ecarte, detail)
    if (!vol_cst && isTRUE(x_ecarte)) txt_r12_test else detail_vol(detail)
  # Ecart a la constance exacte de pi_t dans la bande de tolerance ; chaine
  # vide hors de la bande. 1 - delta est affiche plutot que delta : "%g"
  # rendrait 1 - 5e-7 par "1".
  ecart_tol <- local({
    e <- character(0)
    if (regime$delta_dans_bande)
      e <- c(e, sprintf("1 - delta = %.2g", 1 - fit$delta))
    if (regime$volumes_dans_bande)
      e <- c(e, sprintf("etendue relative des volumes = %.2g",
                        diff(range(fit$x)) / mean(fit$x)))
    paste(e, collapse = ", ")
  })
  # Regle R7 (#70, ADR 0002) : les lois de reference exactes des huit lignes
  # Durbin-Watson, suites, Shapiro-Wilk (loi nulle simulee), Smirnov,
  # Spearman (volume, temps), Mann-Kendall et Cox-Stuart supposent des
  # observations echangeables (z_t, ou r_t, i.i.d. sous H0). C'est le cas a
  # pi_t constant ; a pi_t variable, z = P epsilon n'est pas echangeable et
  # les r_t ne sont pas identiquement distribues : aucune p exacte n'est
  # attribuee. L'argument p n'est evalue qu'a pi_t constant (evaluation
  # paresseuse : ni Imhof ni enumeration a pi_t variable), et la valeur est
  # alors celle d'avant #70 au bit pres.
  p_ex_si_pi_constant <- function(p) if (isTRUE(pi_constant)) p else NA_real_
  # Regle R8 (#70) : libelles des huit lignes selon le regime. Jonction de
  # deux textes selon la regle de la branche "ECHEC inatteignable" de add() :
  # " " apres un point final, " ; " sinon, rien si l'un des deux est vide.
  joindre <- function(a, b) {
    if (!nzchar(b)) return(a)
    if (!nzchar(a)) return(b)
    paste0(a, if (grepl("\\.$", a)) " " else " ; ", b)
  }
  txt_pi_variable <- paste("p exacte non attribuee : loi de reference exacte seulement",
                           "a pi_t constant (z = P epsilon non echangeable, r_t non",
                           "identiquement distribues).")
  txt_bande <- if (isTRUE(pi_constant) && !isTRUE(regime$pi_constant_exact))
    sprintf(paste("pi_t constant a la tolerance TOL_DELTA_BORD = %g pres (%s) : loi",
                  "de reference exacte a un ecart d'ordre (1 - delta), ou de l'etendue",
                  "relative des volumes, pres"), TOL_DELTA_BORD, ecart_tol) else ""
  # A pi_t exactement constant, le detail est rendu tel quel (octet pour
  # octet celui d'avant #70) ; a pi_t variable, il est prefixe de
  # txt_pi_variable ; dans la bande, suffixe de txt_bande, ligne par ligne
  # seulement si la p exacte p_ex de la ligne est attribuee (finie) : une
  # ligne sans p exacte (Spearman ou Mann-Kendall avec ex aequo, Spearman a
  # T > 9) ne dit pas qu'une loi exacte vaut a un ecart pres.
  detail_r7 <- function(detail = "", p_ex = NA_real_) {
    if (!isTRUE(pi_constant)) joindre(txt_pi_variable, detail)
    else if (is.finite(p_ex)) joindre(detail, txt_bande)
    else detail
  }

  # Phrase des lignes dont le detail nomme la p Monte-Carlo comme retenue
  # (RESET, OLS-CUSUM, suites sur ratios bruts ; #128, point c) : vraie
  # seulement si la p Monte-Carlo existe. Sinon add() se replie sur une
  # p-value nommee par nature_p, ou n'en retient aucune (motif de
  # degenerescence, ligne sans p-value) : le detail ne la nomme pas.
  mc_dispo <- function(nm) is.finite(boot$p_mc[[nm]])
  txt_mc_indispo <- function(debut) paste(debut, "est indisponible sur ces donnees ;",
                                          "la p-value retenue, s'il en est une, est nommee par nature_p")

  ## --- B. H1 : E[Y_t] lineaire proportionnelle en X_t ------------------------
  fam <- paste("B. H1 - linearite / proportionnalite", cite_hyp("i"))
  ti <- test_intercept(x, y); lmc <- test_lm_complet(x, y)
  # Regle R5 (#44, ADR 0002) : la loi t(T-2) du t de la constante n'est
  # exacte que sous le modele auxiliaire MCO (erreurs i.i.d. normales
  # homoscedastiques), que H2 et H3 contredisent : sa p-value est rangee dans
  # p_asymptotique, non retenue ; la p-value Monte-Carlo (statistique
  # Intercept, simulee sous le modele de l'annexe XVII, ou a = 0 est vrai)
  # est retenue.
  add(fam, "Nullite de la constante (proportionnalite stricte)",
      fonction = "test_intercept",
      "Student (1908), Biometrika 6",
      type = si_vol_cst(if (is.finite(ti$stat)) "test" else "non applicable"),
      H0 = "a = 0 (proportionnalite stricte)", H1 = "a != 0",
      stat_nom = "t", stat = ti$stat,
      loi = sprintf(paste("t(%d) exacte sous le modele auxiliaire MCO seulement (erreurs",
                          "i.i.d. normales homoscedastiques, contredites par H2 et H3) ;",
                          "non retenue"), T - 2),
      estim_nom = "constante a",
      estim = if (is.finite(ti$stat)) unname(stats::coef(lmc$modele)[1]) else NA_real_,
      p_as = ti$p, mc_nom = "Intercept",
      # Sans p Monte-Carlo (B_eff = 0), aucune p retenue : la p de Student ne
      # vaut que sous le modele auxiliaire MCO (#44, reprise, constat 2).
      repli_asymptotique = FALSE,
      libelle_p_as = "p de Student sous le modele auxiliaire MCO",
      detail = detail_r12(ti$x_ecarte,
                          paste("Le NON-rejet ne prouve pas la proportionnalite :",
                                "voir le test d'equivalence ci-dessous.")))
  tost <- test_tost_intercept(x, y, theta = theta_equiv, delta_abs = delta_equiv)
  add(fam, "Equivalence de la constante a zero (TOST)",
      fonction = "test_tost_intercept",
      "Schuirmann (1987), J. Pharmacokinet. Biopharm. 15",
      type = if (is.finite(tost$p)) "test" else "non applicable",
      H0 = "|a| >= Delta (la constante n'est PAS negligeable)",
      H1 = "|a| < Delta (constante negligeable : proportionnalite pratique)",
      stat_nom = "t (max des 2 unilateraux)", stat = tost$stat,
      # #44 (regle R5, TOST) : aucune p Monte-Carlo possible (H0 composite) ;
      # la p reste retenue, et nature et loi disent sous quel modele elle vaut.
      loi = if (isTRUE(tost$marge_a_priori))
        sprintf("t(%d) exacte sous le modele auxiliaire MCO (marge fixee a priori)", T - 2)
      else sprintf(paste("t(%d) sous le modele auxiliaire MCO ; marge estimee sur les",
                         "donnees -> exactitude approchee"), T - 2),
      estim_nom = "marge Delta", estim = tost$delta,
      p_ex = if (isTRUE(tost$marge_a_priori)) tost$p else NA_real_,
      p_as = if (isTRUE(tost$marge_a_priori)) NA_real_ else tost$p,
      nature_forcee = if (isTRUE(tost$marge_a_priori))
        "sous le modele auxiliaire MCO : t(T-2) exacte, marge fixee a priori"
      else "sous le modele auxiliaire MCO : loi de Student, marge estimee sur les donnees",
      sens = "rejeter",
      # Issue #58 : un detail de longueur 1 sur chaque branche.
      detail = switch(if (is.na(tost$non_applicable)) "calcule" else tost$non_applicable,
        # Motif unique de la regle R13 (#59) ; garde-fou R12 (x ecarte par
        # lm(), hors volumes constants) : motif distinct depuis #168.
        "volumes constants" = txt_vol_cst,
        "x ecarte" = txt_r12_test,
        "marge" = paste("marge Delta invalide (sans delta_equiv : theta_equiv non",
                        "fini ou <= 0 ; ou delta_equiv non fini ou <= 0) : test",
                        "non applicable"),
        # La valeur de Delta n'est pas imprimee (elle est dans estim) : sur
        # les donnees de test, 0,1 * moyenne(y) = 8,5005 tombe sur un point
        # de bascule de %.4g, et une perturbation relative de 1e-12 des
        # donnees faisait passer le texte de "8.501" a "8.5" (issue #22,
        # test anti-bruit).
        # Condition necessaire de conclusion (#165, formulation d'actuary
        # arretee par le mainteneur) : p = 1 - F_t((Delta - |a|)/se) >=
        # p_plancher = 1 - F_t(Delta/se), egalite en a = 0. La branche se
        # decide en comparant p_plancher a alpha et a SEUIL_ECHEC_SENS_REJETER,
        # seuils de la regle des verdicts (sens "rejeter") : le detail ne
        # contredit jamais le verdict. rho = t(1-alpha, T-2) x se / Delta,
        # imprime a %.2f, exprime la meme condition (rho < 1 <=> p_plancher <
        # alpha en arithmetique exacte) ; tout pres de 1, l'arrondi
        # d'affichage peut montrer 1.00 dans l'une ou l'autre branche.
        "calcule" = local({
          p_plancher <- stats::pt(tost$delta / tost$se, tost$ddl, lower.tail = FALSE)
          rho <- stats::qt(1 - alpha, tost$ddl) * tost$se / tost$delta
          txt_condition <- if (p_plancher < alpha)
            sprintf("Condition necessaire de conclusion remplie : t(1-alpha, T-2) x se(a) / Delta = %.2f < 1.",
                    rho)
          else paste0(sprintf(paste("Condition necessaire de conclusion non remplie :",
                                    "t(1-alpha, T-2) x se(a) / Delta = %.2f >= 1, soit",
                                    "se(a) >= Delta / t(1-alpha, T-2) : quelle que soit",
                                    "la constante estimee, p >= alpha"), rho),
                      if (p_plancher >= SEUIL_ECHEC_SENS_REJETER)
                        sprintf(" et meme p >= %g : OK et ALERTE inatteignables",
                                SEUIL_ECHEC_SENS_REJETER)
                      else " : OK inatteignable",
                      paste(". L'equivalence ne peut pas etre conclue avec ces donnees",
                            "(plan de volumes, dispersion residuelle) et cette marge :",
                            "ce verdict traduit une absence de preuve, non un ecart a",
                            "la proportionnalite."))
          paste(sprintf(paste("Rejeter H0 fournit une preuve POSITIVE de proportionnalite.",
                              "Delta = %s (valeur : estimation \"marge Delta\") ;",
                              "p_bas = %.4f, p_haut = %.4f."),
                        if (isTRUE(tost$marge_a_priori)) "marge fixee a priori"
                        else sprintf("%.0f %% de la moyenne de y", 100 * theta_equiv),
                        tost$p_bas, tost$p_haut),
                txt_condition)
        }),
        "statistique non definie" = paste("statistique t non definie (constante ou erreur-type",
                                          "de la regression de y sur x non calculable) :",
                                          "test non applicable"),
        stop("usp_tests : motif TOST inconnu : ", tost$non_applicable)))
  # Regle R4 (#44, option E) : identifiabilite de la pente. Si la puissance
  # approchee du test de la pente sous le modele ajuste est inferieure au
  # repere SEUIL_PUISSANCE_PENTE, un ECHEC decrit le plan d'experience (volumes
  # peu disperses), non un ecart au modele : les lignes pente et Fisher
  # (F = t^2, meme puissance) sont restituees en diagnostic. lambda et la
  # puissance approchee sont rappeles dans le detail dans les deux cas.
  # Quand elles restent des tests, la nature de leur p est celle du modele
  # auxiliaire MCO (la loi t n'est pas asymptotique ; H0 n'est pas simulable,
  # le modele ajuste appartenant a H1).
  idp <- usp_identifiabilite_pente(x, fit$beta, fit$sigma, alpha)
  pente_ident <- !is.finite(idp$puissance) || idp$puissance >= SEUIL_PUISSANCE_PENTE
  txt_ident <- if (!is.finite(idp$puissance)) "" else
    sprintf(paste("%s puissance approchee sous le modele ajuste = %.2f %s %.1f (repere",
                  "conventionnel), indice d'identifiabilite lambda = sqrt(T-1) CV(x)",
                  "beta / sigma = %.2f (approximation au premier ordre, loi de",
                  "Student decentree)."),
            if (pente_ident) "Pente identifiable par les donnees :"
            else "PENTE NON IDENTIFIABLE PAR LES DONNEES :",
            idp$puissance, if (pente_ident) ">=" else "<", SEUIL_PUISSANCE_PENTE,
            idp$lambda)
  nat_mco <- "sous le modele auxiliaire MCO : t(T-2) exacte (H0 non simulable : le modele ajuste appartient a H1)"
  # Ligne Fisher : sa loi de reference est F(1,T-2), non t(T-2) (#117) ;
  # meme p-value a l'arrondi pres (F = t^2 en regression simple).
  nat_mco_F <- "sous le modele auxiliaire MCO : F(1,T-2) exacte (H0 non simulable : le modele ajuste appartient a H1)"
  type_pente <- function(stat) if (!is.finite(stat)) "non applicable"
                               else if (pente_ident) "test" else "diagnostic"
  add(fam, "Test de Student sur la pente (lm(y~x))",
      fonction = "test_lm_complet",
      "Student (1908), Biometrika 6",
      type = type_pente(lmc$t_pente),
      H0 = "b = 0 (aucun lien volume / pertes)", H1 = "b != 0",
      stat_nom = "t", stat = lmc$t_pente,
      loi = sprintf(paste("t(%d) exacte sous le modele auxiliaire MCO (erreurs i.i.d.",
                          "normales homoscedastiques)"), T - 2),
      estim_nom = "pente b", estim = lmc$pente,
      p_as = lmc$p_pente, sens = "rejeter", nature_forcee = nat_mco,
      detail = detail_r12(lmc$x_ecarte, trimws(paste("Ici on souhaite REJETER H0.", txt_ident))))
  add(fam, "Test de Fisher (significativite globale)", "Fisher (1922, 1925)",
      fonction = "test_lm_complet",
      type = type_pente(lmc$F),
      H0 = "b = 0", H1 = "b != 0",
      stat_nom = "F", stat = lmc$F,
      loi = if (is.finite(lmc$F))
        sprintf("F(%d,%d) exacte sous le modele auxiliaire MCO", lmc$ddl1, lmc$ddl2)
      else NA_character_,
      p_as = lmc$p_F, sens = "rejeter", nature_forcee = nat_mco_F,
      detail = detail_r12(lmc$x_ecarte, trimws(paste("Equivaut a t^2 en regression simple.", txt_ident))))
  add(fam, "Coefficient de determination R2", "lm(y ~ x)",
      fonction = "test_lm_complet",
      type = if (is.finite(lmc$R2)) "diagnostic" else "non applicable",
      estim_nom = "R2", estim = lmc$R2,
      detail = if (is.finite(lmc$R2))
        sprintf("R2 ajuste = %.4f ; sous H0 (b=0) E[R2] = 1/(T-1) = %.3f ; repere conventionnel R2 < 0.5 : %s. Diagnostic, pas un test",
                lmc$R2_ajuste, 1 / (T - 1),
                if (lmc$R2 < 0.5) "en dessous" else "au-dessus")
      else detail_vol(paste(txt_r12, ": R2 non defini")))
  # Issue #110 : branche non applicable sur le modele de la ligne TOST ;
  # priorite volumes constants (R13, txt_vol_cst) > moins de trois volumes
  # distincts > rang deficient (motif rendu par test_reset()).
  tr <- test_reset(x, y)
  add(fam, "RESET (forme fonctionnelle)", "Ramsey (1969), JRSS B 31",
      fonction = "test_reset",
      type = if (vol_cst || !is.na(tr$non_applicable)) "non applicable" else "test",
      H0 = "gamma2 = gamma3 = 0 (forme lineaire correcte)",
      H1 = "forme fonctionnelle mal specifiee",
      stat_nom = "F", stat = tr$stat, loi = sprintf("F(2,%d) approx.", T - 3),
      p_as = tr$p, mc_nom = "RESET",
      detail = if (vol_cst) txt_vol_cst
      else if (!is.na(tr$non_applicable)) tr$non_applicable
      else paste("La loi F(2,T-3) n'est pas exacte sous le modele de l'annexe",
                 "XVII : elle suppose des erreurs additives normales",
                 "homoscedastiques dans y = beta x + eps, alors que Y_t est",
                 "lognormale de variance beta^2 x_t^2 (exp(1/pi_t) - 1) (erreur",
                 "multiplicative, asymetrique, heteroscedastique). Les regresseurs",
                 "auxiliaires engendrent {x, x^2, x^3}, espace fixe : la dependance",
                 "en y de f = beta_hat x n'est pas en cause (Milliken et Graybill,",
                 "1970).",
                 if (mc_dispo("RESET"))
                   "La p Monte-Carlo, simulee sous le modele ajuste, est retenue."
                 else
                   paste0(txt_mc_indispo("La p Monte-Carlo, simulee sous le modele ajuste,"), ".")))
  # p_min des lignes de rangs (Spearman, Mann-Kendall ; #44, reprise, avis
  # d'actuary Q5) : 2/T! n'est la p minimale que sans ex aequo ; avec ex
  # aequo (dans r, ou dans x pour Spearman-volume), la loi de permutation
  # conditionnelle n'est pas tabulee : ni p_min ni p exacte (#70, regle 2b ;
  # mk_p_exacte() rend deja NA avec ex aequo), et le motif, porte par
  # effectifs, est restitue dans detail par add() (p_min NA).
  # Ex aequo a la tolerance TOL_EX_AEQUO, definition partagee (#112) : r et x
  # sont aplatis une fois (r_ea, x_ea) pour cor.test() ; les autres lignes
  # (Mann-Kendall, Cox-Stuart, suites) aplatissent dans leurs fonctions. x est
  # aplati en tolerance purement relative (.usp_aplatir_volumes()). ex_aequo()
  # ne recoit que des vecteurs deja aplatis : apres aplatissement, ex aequo
  # equivaut a egalite au bit pres.
  r_ea <- engine_aplatir_ex_aequo(r); x_ea <- .usp_aplatir_volumes(x)
  ex_aequo <- function(...) any(vapply(list(...), function(v) anyDuplicated(v) > 0, logical(1)))
  pmin_rangs <- function(...) if (ex_aequo(...)) NA_real_ else mk_p_min(T)
  eff_rangs <- function(r, x = NULL) {
    er <- ex_aequo(r); ex <- !is.null(x) && ex_aequo(x)
    if (er || ex)
      sprintf(paste("T = %d ; ex aequo %s : loi de permutation conditionnelle non",
                    "tabulee, p_min et p exacte non attribuees"),
              T, if (er && ex) "dans r et x" else if (er) "dans r" else "dans x")
    else sprintf("T = %d, sans ex aequo", T)
  }
  # Regle 2c (#70) : cor.test(exact = TRUE) n'enumere la loi de permutation
  # que pour T <= 9 (prho.c, n_small = 9) ; au-dela il rend un developpement
  # d'Edgeworth (AS 89) : aucune p exacte. Avec ex aequo, cor.test(exact =
  # TRUE) rend la p asymptotique sous un avertissement : aucune p exacte non
  # plus, sans se fier a try() ni a l'avertissement. Le motif Edgeworth est
  # ecrit a T > 9 quel que soit l'etat des ex aequo (le motif ex aequo, porte
  # par effectifs, s'y ajoute alors).
  txt_edgeworth <- paste("T > 9 : cor.test(exact = TRUE) rend un developpement",
                         "d'Edgeworth (AS 89, prho.c, n_small = 9), non une loi exacte")
  p_spearman_exacte <- function(a, b, ...) {
    if (T > 9 || ex_aequo(...)) return(NA_real_)
    p_ex_si_pi_constant({
      o <- suppressWarnings(try(stats::cor.test(a, b, method = "spearman", exact = TRUE),
                                silent = TRUE))
      if (!inherits(o, "try-error")) o$p.value else NA_real_
    })
  }
  detail_spearman <- function(detail, p_ex)
    detail_r7(if (T > 9) joindre(detail, txt_edgeworth) else detail, p_ex)
  if (!vol_cst) {
    cs <- suppressWarnings(stats::cor.test(r_ea, x_ea, method = "spearman", exact = FALSE))
    p_sv <- p_spearman_exacte(r_ea, x_ea, r_ea, x_ea)
    add(fam, "Independance ratio S/P vs volume", "Spearman (1904) ; exact : Best & Roberts (1975), AS 89",
        fonction = "usp_tests",
        H0 = "independance (aucune association monotone)", H1 = "association monotone",
        stat_nom = "S", stat = unname(cs$statistic),
        loi = "permutation exacte (T <= 9, sans ex aequo)",
        estim_nom = "rho_s", estim = unname(cs$estimate),
        p_ex = p_sv,
        p_as = cs$p.value, mc_nom = "SpearVol",
        p_min = pmin_rangs(r_ea, x_ea), effectifs = eff_rangs(r_ea, x_ea),
        detail = detail_spearman("Une correlation signale un effet d'echelle non modelise",
                                 p_sv))
  } else {
    # Regle R13 (#59) : meme reference que la branche calculee (I5).
    add(fam, "Independance ratio S/P vs volume", "Spearman (1904) ; exact : Best & Roberts (1975), AS 89",
        fonction = "usp_tests",
        type = "non applicable",
        H0 = "independance (aucune association monotone)", H1 = "association monotone",
        stat_nom = "S", loi = "permutation exacte (T <= 9, sans ex aequo)",
        estim_nom = "rho_s", mc_nom = "SpearVol", detail = txt_vol_cst)
  }
  ct <- suppressWarnings(stats::cor.test(r_ea, seq_along(r), method = "spearman", exact = FALSE))
  p_st <- p_spearman_exacte(r_ea, seq_along(r), r_ea)
  add(fam, "Correlation ratio S/P vs temps", "Spearman (1904) ; exact : Best & Roberts (1975)",
      fonction = "usp_tests",
      H0 = "independance entre le ratio et le rang chronologique",
      H1 = "association monotone avec le temps",
      stat_nom = "S", stat = unname(ct$statistic),
      loi = "permutation exacte (T <= 9, sans ex aequo)",
      estim_nom = "rho_s", estim = unname(ct$estimate),
      p_ex = p_st,
      p_as = ct$p.value, mc_nom = "SpearTps",
      p_min = pmin_rangs(r_ea), effectifs = eff_rangs(r_ea),
      detail = detail_spearman("", p_st))
  mk <- test_mann_kendall(r)
  p_mk <- p_ex_si_pi_constant(mk_p_exacte(r))
  add(fam, "Tendance monotone du ratio S/P",
      fonction = "test_mann_kendall",
      "Mann (1945) ; loi exacte : Kendall & Gibbons (1990), ch. 4-5",
      H0 = "absence de tendance monotone (r_t i.i.d.)", H1 = "tendance monotone",
      stat_nom = "Z", stat = mk$stat,
      loi = "loi exacte de S (distribution mahonienne)",
      estim_nom = "S de Kendall", estim = mk$S,
      p_ex = p_mk, p_as = mk$p, mc_nom = "MK",
      p_min = pmin_rangs(r_ea), effectifs = eff_rangs(r_ea),
      detail = detail_r7("Une derive du S/P contredit la constance de beta", p_mk))
  cx <- test_cox_stuart(r)
  p_cx <- p_ex_si_pi_constant(cx$p)
  # m : differences non nulles, n_p : paires. Sans ex aequo (m = n_p), le
  # libelle est inchange ; avec ex aequo, les deux nombres sont affiches et
  # la p_mc n'est pas calculee (statistique NA au catalogue, #85).
  # p_min (cox_stuart_p_min()) : champ de la ligne et regle d'inoperance R1
  # de add() (#44) ; a m = 0, p_min = 1 y tombe sans cas particulier.
  p_min <- cox_stuart_p_min(cx$m)
  # La p minimale atteignable n'est plus imprimee ici : elle est dans le champ
  # p_min et dans le prefixe de la regle R1 (#44, reprise, avis d'actuary Q7).
  cx_detail <- if (cx$m == 0L)
    sprintf("aucune difference non nulle sur n_p = %d paires : K non defini", cx$n_p)
  else if (cx$m == cx$n_p)
    sprintf("m = %d paires", cx$m)
  else
    sprintf(paste("m = %d differences non nulles sur n_p = %d paires ;",
                  "p_mc non calculee (replications sans ex aequo)"),
            cx$m, cx$n_p)
  add(fam, "Tendance par signes du ratio S/P", "Cox & Stuart (1955), Biometrika 42",
      fonction = "test_cox_stuart",
      H0 = "P(D_t > 0) = 1/2 (absence de tendance)", H1 = "P(D_t > 0) != 1/2",
      stat_nom = "K", stat = cx$stat,
      loi = paste("Binomiale(m, 1/2) EXACTE, m differences non nulles ;",
                  "p_mc par |K - n_p/2|, n_p paires, queue haute"),
      p_ex = p_cx, mc_nom = "CoxStuart",
      p_min = p_min, effectifs = sprintf("m = %d differences non nulles", cx$m),
      detail = detail_r7(cx_detail, p_cx))

  ## --- C. H2 : variance quadratique en X_t -----------------------------------
  fam <- paste("C. H2 - structure de variance", cite_hyp("ii"))
  bp <- test_breusch_pagan(z^2, x)
  add(fam, "Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)",
      fonction = "test_breusch_pagan",
      "Breusch & Pagan (1979) ; studentisation de Koenker (1981)",
      type = si_vol_cst("test"),
      H0 = "c1 = 0 : la variance des residus standardises ne depend pas du volume",
      H1 = "variance residuelle dependante du volume",
      stat_nom = "LM", stat = bp$stat, loi = "chi2(1) asymptotique",
      p_as = bp$p, mc_nom = "BP",
      detail = detail_vol("Doit etre non significatif si la ponderation pi_t est correcte"))
  bp79 <- test_breusch_pagan_original(z^2, x)
  add(fam, "Heteroscedasticite vs volume - Breusch-Pagan original (non robuste)",
      fonction = "test_breusch_pagan_original",
      "Breusch & Pagan (1979), Econometrica 47",
      type = si_vol_cst("test"),
      variante = "secondaire",
      H0 = "c1 = 0 ET erreurs normales : variance residuelle independante du volume",
      H1 = "variance residuelle dependante du volume",
      stat_nom = "LM", stat = bp79$stat, loi = "chi2(1) asymptotique, SOUS NORMALITE",
      p_as = bp79$p, mc_nom = "BP79",
      detail = detail_vol(paste("Version publiee, avec le facteur 1/2 issu de Var(u^2) = 2 sigma^4.",
                                "NON ROBUSTE : sur-rejette si les erreurs ne sont pas normales.",
                                "A confronter systematiquement a la version de Koenker ci-dessus.")))
  # Issue #110 : meme restitution que RESET (priorite R13 > (a) > (b)).
  wh <- test_white(z^2, x)
  add(fam, "Heteroscedasticite (forme quadratique)", "White (1980), Econometrica 48",
      fonction = "test_white",
      type = if (vol_cst || !is.na(wh$non_applicable)) "non applicable" else "test",
      H0 = "c1 = c2 = 0", H1 = "heteroscedasticite residuelle de forme quadratique",
      stat_nom = "LM", stat = wh$stat, loi = "chi2(2) asymptotique",
      p_as = wh$p, mc_nom = "White",
      detail = if (vol_cst) txt_vol_cst
      else if (!is.na(wh$non_applicable)) wh$non_applicable
      else "")
  gq <- test_goldfeld_quandt(z, x)
  add(fam, "Egalite des variances petits vs gros volumes",
      fonction = "test_goldfeld_quandt",
      "Goldfeld & Quandt (1965), JASA 60",
      type = si_vol_cst("test"),
      H0 = "sigma1^2 = sigma2^2", H1 = "variances inegales entre les deux blocs",
      stat_nom = "F", stat = gq$stat,
      loi = sprintf("F(%d,%d) approx. (residus issus d'un ajustement global)",
                    floor(T / 2), floor(T / 2)),
      p_as = gq$p, mc_nom = "GQ", detail = detail_vol(""))
  bf <- test_brown_forsythe(z, x)
  add(fam, "Homogeneite des dispersions (mediane)",
      fonction = "test_brown_forsythe",
      "Brown & Forsythe (1974), JASA 69",
      type = si_vol_cst("test"),
      H0 = "egalite des dispersions entre les deux groupes",
      H1 = "dispersions inegales",
      stat_nom = "W", stat = bf$stat, loi = sprintf("F(1,%d) approx.", T - 2),
      p_as = bf$p, mc_nom = "BF", detail = detail_vol(""))
  # Smirnov (T >= 8) : la ligne existe dans tous les regimes (invariant I5,
  # #59) ; non applicable a volumes constants (regle R13) ou si la partition
  # par la mediane des volumes laisse un groupe de moins de trois annees (ex
  # aequo sur la mediane), au lieu d'etre absente.
  if (T >= 8) {
    grp <- if (vol_cst) NULL else x > stats::median(x)
    calculable <- !vol_cst && sum(grp) >= 3 && sum(!grp) >= 3
    # Ex aequo (#112, decision du mainteneur du 28/09/2026, option (i)) : z
    # aplati a TOL_EX_AEQUO avant ks.test() ; avec ex aequo, ks.test() rendrait
    # une p exacte conditionnelle (Schroer & Trenkler, 1995) dont 2/C(n1+n2,
    # n1) n'est pas la p minimale : ni p exacte ni p_min, motif dans
    # effectifs, p Monte-Carlo retenue (regle 2b de #70, comme Spearman et
    # Mann-Kendall). D et sa p_mc restent calcules.
    z_ea <- engine_aplatir_ex_aequo(z)
    ea_sm <- anyDuplicated(z_ea) > 0
    ks2 <- if (calculable) suppressWarnings(stats::ks.test(z_ea[grp], z_ea[!grp]))
    p_sm <- if (calculable && !ea_sm) p_ex_si_pi_constant(ks2$p.value) else NA_real_
    add(fam, "Egalite des lois petits vs gros volumes (2 ech.)", "Smirnov (1939)",
        fonction = "usp_tests",
        type = if (calculable) "test" else "non applicable",
        H0 = "F1 = F2 (memes lois)", H1 = "lois differentes",
        stat_nom = "D", stat = if (calculable) unname(ks2$statistic) else NA_real_,
        loi = "exacte combinatoire (ks.test, sans ex aequo)",
        p_ex = p_sm, mc_nom = "Smirnov",
        p_min = if (calculable && !ea_sm) smirnov_p_min(sum(grp), sum(!grp)) else NA_real_,
        effectifs = if (!calculable) NA_character_
                    else if (ea_sm)
                      sprintf(paste("n1 = %d, n2 = %d ; ex aequo dans z : loi",
                                    "conditionnelle non attribuee, p_min et p exacte",
                                    "non attribuees"), sum(grp), sum(!grp))
                    else sprintf("n1 = %d, n2 = %d", sum(grp), sum(!grp)),
        detail = if (vol_cst) txt_vol_cst
        else if (!calculable)
          sprintf(paste("partition par la mediane des volumes : groupes de %d et %d",
                        "annees (moins de 3 dans un groupe, ex aequo sur la mediane) :",
                        "test non applicable"), sum(grp), sum(!grp))
        else if (ea_sm) detail_r7("Voir aussi le QQ-plot a deux echantillons", p_sm)
        else detail_r7(sprintf(paste("Voir aussi le QQ-plot a deux echantillons ; p-value",
                                     "minimale atteignable = %.4f, atteinte seulement pour",
                                     "D = 1 (deux groupes totalement separes)"),
                               smirnov_p_min(sum(grp), sum(!grp))), p_sm))
  }
  # Issue #58 : a volumes constants (usp_regime(), tolerance TOL_DELTA_BORD),
  # a_t = 1 pour tout t, pi_t ne depend plus de delta et la vraisemblance est
  # plate en delta (mesure : usp_objectif() identique sur delta = 0, 0.125,
  # ..., 1 a x = rep(110, 8)). delta n'est pas identifie : la valeur est celle
  # du demarrage retenu par usp_ajuster() (delta de depart 0, premier de la
  # grille : les autres demarrages finissent a moins de 1e-12 de la meme valeur
  # de l'objectif, sous l'ecart 1e-10 exige pour remplacer le meilleur ;
  # mesure a x = rep(v, 8), v = 80, 110, 200, 5000 : delta final = 0 et
  # deplacement en delta d'un demarrage au plus 4e-13). Ce cas prime sur "AU BORD", vrai ici pour une mauvaise
  # raison. Dans la bande (volumes d'etendue relative e non nulle mais
  # <= TOL_DELTA_BORD), la vraisemblance depend encore tres faiblement de
  # delta (mesure, donnees premium, e = 5e-7, gamma = -1,8 : l'objectif
  # varie de 3,0e-7 entre delta = 0 et delta = 1) : le libelle le dit.
  suite_cst <- paste(", qui n'est pas identifie ; la valeur affichee est celle",
                     "ou l'optimiseur s'est arrete")
  # Citation par methode (issue #101) : B(6) pour les primes, C(6) pour la
  # reserve no 1.
  add(fam, "Position de delta dans [0,1]",
      fonction = "usp_ajuster",
      sprintf("Annexe XVII, section %s, paragraphe 6",
              if (methode == "premium") "B" else "C"),
      type = "diagnostic", estim_nom = "delta", estim = fit$delta,
      detail = if (isTRUE(regime$volumes_dans_bande))
        paste0(sprintf(paste("VOLUMES CONSTANTS a la tolerance TOL_DELTA_BORD = %g pres",
                             "(etendue relative = %.2g) : la vraisemblance ne depend",
                             "presque pas de delta"),
                       TOL_DELTA_BORD, diff(range(fit$x)) / mean(fit$x)), suite_cst)
      else if (isTRUE(regime$volumes_constants))
        paste0("VOLUMES CONSTANTS : la vraisemblance ne depend pas de delta", suite_cst)
      else if (isTRUE(fit$delta_au_bord))
        "SOLUTION AU BORD : structure de variance non identifiee par les donnees"
      else "interieur du domaine : melange des deux composantes identifie")

  ## --- D. H3 : lognormalite --------------------------------------------------
  fam <- paste("D. H3 - lognormalite", cite_hyp("iii"))
  H0n <- "les residus standardises suivent une loi normale"
  H1n <- "loi non normale"
  sw <- .shapiro_sur(z)
  add(fam, "Shapiro-Wilk sur residus standardises", "Shapiro & Wilk (1965), Biometrika 52",
      fonction = ".shapiro_sur",
      H0 = H0n, H1 = H1n, stat_nom = "W", stat = sw$stat,
      loi = "aucune forme fermee ; normalisation de Royston (1992)",
      p_as = sw$p, mc_nom = "SW")
  p_sw <- p_ex_si_pi_constant(sw_p_loi_nulle(sw$stat, T))
  add(fam, "Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston)",
      fonction = ".shapiro_sur",
      "Shapiro & Wilk (1965) ; loi nulle evaluee par simulation directe",
      variante = "secondaire",
      H0 = H0n, H1 = H1n, stat_nom = "W", stat = sw$stat,
      loi = "loi exacte de W sous normalite, evaluee numeriquement (20 000 tirages)",
      # Regle R9 amendee (#70) : a pi_t variable, W(P epsilon) n'a pas la loi
      # de W sous i.i.d. normal ; la ligne est non applicable, la p i.i.d.
      # n'est ni calculee ni rappelee (W reste dans stat).
      type = if (isTRUE(pi_constant)) "test" else "non applicable",
      p_ex = p_sw,
      detail = if (isTRUE(pi_constant))
        detail_r7(paste("W etant invariant par translation et changement d'echelle,",
                        "sa loi nulle ne depend d'aucun parametre : la simulation est",
                        "independante du modele USP ajuste (ce n'est pas un bootstrap)."), p_sw)
      else paste("loi nulle i.i.d. sans objet a pi_t variable (W(P epsilon) n'a pas",
                 "la loi de W sous i.i.d. normal) ; voir la ligne Shapiro-Wilk sur",
                 "residus standardises (p Monte-Carlo)"))
  sf <- test_shapiro_francia(z)
  add(fam, "Shapiro-Francia", "Shapiro & Francia (1972), JASA 67 ; Royston (1993)",
      fonction = "test_shapiro_francia",
      H0 = H0n, H1 = H1n, stat_nom = "W'", stat = sf$stat,
      loi = "aucune forme fermee ; normalisation de Royston (1993)",
      p_as = sf$p, mc_nom = "SF")
  # Regle R6 (#44) : l'ajustement de Stephens (cas 3 : moyenne et variance
  # estimees, standardisation par zbar et s_z, celle de nortest::ad.test) ne
  # s'applique pas a z, standardise par le MODELE (a pi_t constant, z_t =
  # sqrt(T/(T-1)) (v_t - vbar)/s_v, valeurs gonflees de sqrt(T/(T-1))). La p
  # non simulee est donc calculee sur la statistique re-standardisee,
  # (z - zbar)/s_z, rangee dans estim ; stat reste la statistique du
  # catalogue, base de la p Monte-Carlo retenue. Plage : nortest::ad.test
  # exige n > 7 ; en dessous, p non simulee NA avec le motif.
  zs <- if (is.finite(stats::sd(z)) && stats::sd(z) > 0) (z - mean(z)) / stats::sd(z) else NULL
  a2_std <- if (!is.null(zs)) stat_ad(zs) else NA_real_
  w2_std <- if (!is.null(zs)) stat_cvm(zs) else NA_real_
  hors_plage <- T < 8
  txt_plage <- if (hors_plage)
    sprintf(paste(" p non simulee NA : T = %d hors de la plage de l'implementation",
                  "de reference (n > 7)."), T) else ""
  loi_stephens <- function(st) sprintf(paste(
    "loi %s, cas parametres estimes ; p non simulee : ajustement de Stephens (cas 3)",
    "sur estim (statistique re-standardisee), non sur stat ; p_mc sur stat",
    "(statistique du catalogue)"), st)
  add(fam, "Anderson-Darling", "Anderson & Darling (1954), JASA 49",
      fonction = "stat_ad",
      H0 = H0n, H1 = H1n, stat_nom = "A2", stat = boot$stats_obs$AD,
      loi = loi_stephens("AD"),
      estim_nom = "A2 sur (z - zbar)/s_z", estim = a2_std,
      p_as = if (hors_plage) NA_real_ else ad_p_stephens(a2_std, T), mc_nom = "AD",
      detail = paste0("Sensible aux queues. p non simulee : ajustement empirique de",
                      " D'Agostino & Stephens (1986) sur la statistique re-standardisee.",
                      txt_plage))
  add(fam, "Cramer-von Mises", "Cramer (1928) / von Mises (1928) ; Stephens (1974)",
      fonction = "stat_cvm",
      H0 = H0n, H1 = H1n, stat_nom = "W2", stat = boot$stats_obs$CvM,
      loi = loi_stephens("CvM"),
      estim_nom = "W2 sur (z - zbar)/s_z", estim = w2_std,
      p_as = if (hors_plage) NA_real_ else cvm_p_stephens(w2_std, T), mc_nom = "CvM",
      detail = trimws(txt_plage))
  add(fam, "Kolmogorov-Smirnov contre N(0,1)", "Kolmogorov (1933) ; Smirnov (1948)",
      fonction = "stat_ks",
      H0 = H0n, H1 = H1n, stat_nom = "D", stat = boot$stats_obs$KS,
      variante = "secondaire",
      loi = "loi de Kolmogorov (valable a parametres CONNUS)",
      p_as = { dd <- boot$stats_obs$KS
               if (is.finite(dd)) .p_borne(2 * sum((-1)^(0:99) *
                 exp(-2 * (1:100)^2 * T * dd^2))) else NA_real_ },
      mc_nom = "KS",
      detail = paste("Les residus sont standardises par le MODELE, non par la moyenne",
                     "et l'ecart-type empiriques : la loi de Kolmogorov reste tres",
                     "conservatrice (simulation : 0 rejet sur 3 000 a 5 %).",
                     "Voir le test de Lilliefors ci-dessus."))
  Dl <- stat_lilliefors(z)
  add(fam, "Lilliefors (KS a parametres estimes)",
      fonction = "stat_lilliefors",
      "Lilliefors (1967), JASA 62 ; p-value : Dallal & Wilkinson (1986)",
      H0 = H0n, H1 = H1n, stat_nom = "D", stat = Dl,
      loi = "loi de Lilliefors (moyenne et ecart-type estimes)",
      p_as = lillie_p(Dl, T), mc_nom = "Lillie",
      detail = paste("Distinct du KS contre N(0,1) : la loi de reference tient compte",
                     "de l'estimation des parametres. Appliquer la loi de Kolmogorov",
                     "dans ce cas rend le test extremement conservateur."))
  jb <- test_jarque_bera(z)
  add(fam, "Jarque-Bera", "Jarque & Bera (1980, 1987)",
      fonction = "test_jarque_bera",
      H0 = "asymetrie nulle ET aplatissement egal a 3",
      H1 = "asymetrie ou aplatissement non normaux",
      stat_nom = "JB", stat = jb$stat, loi = "chi2(2) asymptotique",
      p_as = jb$p, mc_nom = "JB",
      # Asymetrie et aplatissement ne sont pas imprimes (issue #24, decision
      # du mainteneur du 24/09/2026, meme mecanisme que le Delta du TOST) :
      # calcules sur z, ils dependent de l'optimiseur et derivent d'une
      # plateforme a l'autre ; mesure sur les donnees de test (Linux, R
      # 4.3.3) : aplatissement 1,84047, a 1,4e-5 en relatif de la frontiere
      # d'arrondi de %.3f. Les valeurs restent dans estim des lignes
      # D'Agostino (asymetrie) et Anscombe-Glynn (aplatissement).
      detail = sprintf(paste("asymetrie et aplatissement : estimations des lignes",
                             "D'Agostino et Anscombe-Glynn (aplatissement borne",
                             "mecaniquement par ~T = %d)"), T))
  ds <- test_dagostino_skew(z)
  if (is.finite(ds$stat))
    add(fam, "Asymetrie (D'Agostino, T >= 8)", "D'Agostino (1970), Biometrika 57",
        fonction = "test_dagostino_skew",
        H0 = "coefficient d'asymetrie de la population nul", H1 = "asymetrie non nulle",
        stat_nom = "Z", stat = ds$stat, loi = "N(0,1) approx. (transformation de Johnson SU)",
        estim_nom = "asymetrie", estim = jb$skew, p_as = ds$p, mc_nom = "DAgo")
  else
    add(fam, "Asymetrie (D'Agostino, T >= 8)", "D'Agostino (1970), Biometrika 57",
        fonction = "test_dagostino_skew",
        type = "non applicable", estim_nom = "asymetrie", estim = jb$skew,
        detail = sprintf("T = %d < 8 : transformation normalisante non definie", T))
  ak <- test_anscombe_kurt(z)
  if (is.finite(ak$stat))
    add(fam, "Aplatissement (Anscombe-Glynn, T >= 20)", "Anscombe & Glynn (1983), Biometrika 70",
        fonction = "test_anscombe_kurt",
        H0 = "aplatissement de la population egal a 3", H1 = "aplatissement different de 3",
        stat_nom = "Z", stat = ak$stat, loi = "N(0,1) approx. (Wilson-Hilferty)",
        estim_nom = "aplatissement", estim = jb$kurt, p_as = ak$p)
  else
    add(fam, "Aplatissement (Anscombe-Glynn, T >= 20)", "Anscombe & Glynn (1983), Biometrika 70",
        fonction = "test_anscombe_kurt",
        type = "non applicable", estim_nom = "aplatissement", estim = jb$kurt,
        detail = sprintf("T = %d < 20 : test non defini", T))

  ## --- E. H4 : independance / validite du MV ---------------------------------
  fam <- fam_h4
  p_dw <- p_ex_si_pi_constant(dw_p_exacte(z))
  add(fam, "Autocorrelation d'ordre 1 (Durbin-Watson)", "Durbin & Watson (1950, 1951)",
      fonction = "stat_dw",
      base = "z",
      H0 = "rho = 0 (absence d'autocorrelation d'ordre 1)", H1 = "rho != 0",
      stat_nom = "DW", stat = boot$stats_obs$DW,
      loi = "forme quadratique en normales ; loi EXACTE par la methode d'Imhof (1961)",
      p_ex = p_dw, mc_nom = "DW",
      detail = detail_r7(paste("Statistique calculee sur residus CENTRES. Les bornes d_L/d_U,",
                               "etablies pour des residus MCO, ne sont pas utilisees : la loi",
                               "exacte est obtenue par integration numerique d'Imhof."), p_dw))
  lb1 <- stats::Box.test(z, lag = 1, type = "Ljung-Box")
  add(fam, "Ljung-Box (retard 1)", "Ljung & Box (1978), Biometrika 65",
      fonction = "usp_tests",
      base = "z",
      H0 = "rho_1 = 0", H1 = "autocorrelation au retard 1",
      stat_nom = "Q", stat = unname(lb1$statistic), loi = "chi2(1) asymptotique",
      p_as = lb1$p.value, mc_nom = "LB1")
  if (T >= 8) {
    lb2 <- stats::Box.test(z, lag = 2, type = "Ljung-Box")
    add(fam, "Ljung-Box (retard 2)", "Ljung & Box (1978), Biometrika 65",
        fonction = "usp_tests",
        H0 = "rho_1 = rho_2 = 0", H1 = "autocorrelation jusqu'au retard 2",
        stat_nom = "Q", stat = unname(lb2$statistic), loi = "chi2(2) asymptotique",
        p_as = lb2$p.value, mc_nom = "LB2")
    bp2 <- stats::Box.test(z, lag = 2, type = "Box-Pierce")
    add(fam, "Box-Pierce (retard 2)", "Box & Pierce (1970), JASA 65",
        fonction = "usp_tests",
        H0 = "rho_1 = rho_2 = 0", H1 = "autocorrelation jusqu'au retard 2",
        variante = "secondaire",
        stat_nom = "Q", stat = unname(bp2$statistic), loi = "chi2(2) asymptotique",
        p_as = bp2$p.value, mc_nom = "BP2")
  }
  # p_min (#44, regle R1) sur la loi de R aux effectifs (n1, n2) observes ;
  # un seul cote de la mediane represente : loi non definie, ligne non
  # applicable (et non INFO muet).
  ru <- test_runs(z); eff_z <- .runs_effectifs(z)
  p_ru <- p_ex_si_pi_constant(runs_p_exacte(z))
  add(fam, "Test des suites (aleatoire des signes)",
      fonction = "test_runs",
      base = "z",
      "Wald & Wolfowitz (1940) ; loi exacte : Swed & Eisenhart (1943)",
      type = if (is.finite(ru$stat)) "test" else "non applicable",
      H0 = "la suite des signes est un arrangement aleatoire",
      H1 = "arrangement non aleatoire (regroupement ou alternance)",
      stat_nom = "Z", stat = ru$stat, loi = "loi combinatoire EXACTE de R",
      estim_nom = "nb de suites R", estim = ru$runs,
      p_ex = p_ru, p_as = ru$p, mc_nom = "Runs",
      p_min = runs_p_min(eff_z[["n1"]], eff_z[["n2"]]),
      effectifs = sprintf("n1 = %d, n2 = %d", eff_z[["n1"]], eff_z[["n2"]]),
      detail = if (is.finite(ru$stat)) detail_r7("", p_ru) else
        "un seul cote de la mediane represente : loi de R non definie, test non applicable")
  # Centrage et variance unitaire : DIAGNOSTICS, sans verdict ni p-value
  # retenue (ADR 0001 ; issues #3 et #5). La condition du premier ordre en
  # ln(beta) impose TOUJOURS somme(sqrt(pi_t) z_t) = 0 (identite) et rive la
  # moyenne ; la condition en gamma, qui ne tient qu'a un optimum interieur,
  # rive la variance : les deux grandeurs sont rivees par l'estimation
  # (CONTEXT.md, "Grandeur rivee par l'estimation"). Elles ne se reduisent a
  # somme(z_t) = 0 et somme(z_t^2) = T que lorsque pi_t est CONSTANT, ce qui
  # suppose delta = 1 ou des volumes x_t constants. A delta = 0 avec des
  # volumes variables, pi_t varie : delta_au_bord ne suffit donc PAS a
  # conclure. La constance de pi_t est decidee sur sa cause (delta >= 1 - tol
  # ou volumes constants) par usp_regime(), avec la meme tolerance que
  # delta_au_bord (TOL_DELTA_BORD, issue #31).
  # Quatre cas sont distingues dans le libelle : pi_t exactement constant,
  # pi_t constant a la tolerance pres seulement (issue #31, revue de la
  # PR #57), delta au bord avec pi_t variable, delta interieur (voir aussi le
  # commentaire de .stats_bootstrapables() pour la loi simulee, qui est un
  # melange). regime et pi_constant sont calcules en tete de la fonction.
  # Le libelle du cas pi_t constant DIFFERE selon la grandeur, et c'est le
  # coeur du diagnostic. somme(z_t) = 0 decoule de la forme FERMEE de ln(beta)
  # dans usp_noyau() : c'est une IDENTITE algebrique, vraie pour tout couple
  # (delta, gamma), convergee ou non, donc vraie a la PRECISION MACHINE et
  # sans rapport avec l'arret de l'optimiseur (mesure : a (delta, gamma) =
  # (1 ; 3), tres loin de l'optimum, moyenne(z) = 1,6e-16 tandis que
  # somme(z^2) - T = -7,97). somme(z_t^2) = T suppose au contraire la derivee
  # en gamma effectivement annulee : elle ne tient qu'a la TOLERANCE D'ARRET
  # pres, et son ecart residuel est a ce jour le seul indicateur de
  # convergence en gamma de toute la restitution.
  # Servir le meme message aux deux lignes faisait affirmer a la colonne
  # "commentaire" de la table auditable, destinee au dossier, une chose
  # fausse sur le centrage.
  # switch() SANS defaut absorberait un nom errone en NULL, que paste() avale
  # sans bruit : le detail sortirait ampute de la phrase qui fait tout l'objet
  # de cette distinction, sans erreur ni avertissement (constat d'audit). Le
  # defaut leve donc une erreur. Le corps est entre accolades pour que le bloc
  # reste analysable s'il est un jour extrait de cette fonction.
  # Issue #39 : quand pi_t n'est pas constant, ce qui subsiste pour la
  # VARIANCE n'est pas la contrainte ponderee somme(sqrt(pi_t) z_t) = 0
  # (condition en ln(beta), qui porte sur la moyenne et ne dit rien de
  # somme(z_t^2)) mais la condition du premier ordre en gamma, relation
  # ponderee distincte. Avec pi_t = 1 / log1p(exp(2 gamma) a_t) (usp_pi(),
  # a_t = delta + (1 - delta) xbar / x_t),
  # elle s'ecrit somme(k_t (z_t^2 - z_t / sqrt(pi_t) - 1)) = 0, avec
  # k_t = pi_t (1 - exp(-1 / pi_t)) ; a pi_t constant, jointe a la condition
  # en ln(beta), elle donne somme(z_t^2) = T. Mesure (usp_ajuster(), donnees
  # de test, reglage anterieur a #63 : difference centree d'optim(),
  # factr = 1e5) : cette somme vaut -3,3e-06 a delta = 0, T = 5 (volumes
  # variables, somme(z_t^2) - T = -1,07e-02), -5,4e-06 a delta = 1 ; depuis
  # #63 (gradient analytique, factr = 1e2) : 8,5e-09 a delta = 0, T = 5, et
  # -5,1e-08 a delta = 1. Elle etait de l'ordre de 1e-07 a delta = 0, T = 5
  # apres raffinement de gamma
  # par optimize(tol = 1e-12) : -2,1e-07 sur l'intervalle [-5 ; 0],
  # +1,2e-07 sur [gamma chapeau - 0,1 ; gamma chapeau + 0,1] (mesures
  # distinctes selon l'intervalle). La formule n'est donnee qu'ici : le
  # libelle nomme la condition sans l'ecrire.
  dom_gamma <- sprintf("[%g, %g]", BORNES_GAMMA[1], BORNES_GAMMA[2])
  cond_gamma_ponderee <- paste(
    "pour la variance, la relation qui subsiste est la condition du premier",
    paste0("ordre en gamma (a un optimum interieur en gamma, domaine ", dom_gamma, "),"),
    "relation ponderee distincte de la contrainte somme(sqrt(pi_t) z_t) = 0",
    "(condition en ln(beta), qui porte sur la moyenne) ; elle ne fixe pas",
    "somme(z_t^2).")
  # Constance de pi_t a la tolerance pres seulement (delta dans la bande
  # [1 - TOL_DELTA_BORD ; 1), ou volumes d'etendue relative non nulle mais
  # <= TOL_DELTA_BORD) : l'identite sur moyenne(z) ne tient plus a la
  # precision machine. Mesure (donnees premium, gamma de l'ajustement) :
  # moyenne(z) = -2,0e-16 a delta = 1, mais 3,6e-10, 1,8e-9 et 3,2e-9 a
  # 1 - delta = 1e-7, 5e-7 et 9e-7, soit 3,6e-3 * (1 - delta) (meme valeur,
  # 3,575e-9 a 1 - delta = 1e-6, a gamma reoptimise : l'ecart ne renseigne
  # donc pas sur la convergence en gamma ; il suit la position de delta,
  # deja affichee). La variance n'est pas davantage exacte : a gamma
  # annulant la derivee en gamma a 1e-14 pres (uniroot), somme(z_t^2) - T =
  # 2,7e-3 * (1 - delta) au lieu de 0 ; cet ecart s'ajoute a celui de la
  # tolerance d'arret (-5,4e-6 sur l'ajustement des donnees de test avant
  # #63, -5,1e-8 depuis). Voir le
  # commentaire de usp_regime() pour le cas des volumes quasi constants.
  # ecart_tol est calcule en tete de la fonction.
  ordre_tol <- paste("d'ordre (1 - delta), ou de l'etendue relative des",
                     "volumes x_t,")
  tol_pres <- sprintf("Ici pi_t n'est constant qu'a la tolerance TOL_DELTA_BORD = %g pres (%s) :",
                      TOL_DELTA_BORD, ecart_tol)
  contrainte <- function(quoi) {
    if (isTRUE(pi_constant) && !isTRUE(regime$pi_constant_exact))
      switch(quoi,
        centrage = paste(tol_pres,
                         "seule somme(sqrt(pi_t) z_t) = 0 est une identite algebrique",
                         "(ln(beta) etant obtenu en forme fermee) ; moyenne(z) n'est",
                         "nulle qu'a un ecart", ordre_tol, "pres, du a la variation",
                         "residuelle de pi_t. Cet ecart ne resulte pas de l'annulation",
                         "d'une derivee : il est proportionnel a (1 - delta), ou a",
                         "l'etendue relative des volumes x_t, deja affiche, et ne",
                         "renseigne PAS sur la convergence en gamma."),
        variance = paste(tol_pres,
                         "var(z) = T/(T-1) suppose la derivee en gamma effectivement",
                         "annulee, donc un optimum INTERIEUR en gamma, et elle tombe si",
                         "gamma bute sur une borne de son domaine", paste0(dom_gamma, ". A un optimum"),
                         "interieur, l'egalite ne tient qu'a deux ecarts pres : la tolerance",
                         "d'arret de l'optimiseur, et un ecart", ordre_tol, "du a la",
                         "variation residuelle de pi_t. L'ecart residuel renseigne donc",
                         "sur la convergence en gamma, sous ces reserves."),
        stop("contrainte() : grandeur inconnue : ", quoi))
    else if (isTRUE(pi_constant))
      switch(quoi,
        centrage = paste("Ici pi_t est constant (delta = 1, ou volumes x_t constants) :",
                         "moyenne(z) = 0 est alors une IDENTITE algebrique, ln(beta)",
                         "etant obtenu en forme fermee. Elle tient a la precision",
                         "machine, que l'optimisation ait converge ou non, et la valeur",
                         "affichee n'est que du bruit d'arrondi : elle ne renseigne donc",
                         "PAS sur la qualite de l'arret de l'optimiseur."),
        variance = paste("Ici pi_t est constant (delta = 1, ou volumes x_t constants) :",
                         "var(z) = T/(T-1) suppose la derivee en gamma effectivement",
                         "annulee, donc un optimum INTERIEUR en gamma : l'egalite ne",
                         "tient qu'a la tolerance d'arret de l'optimiseur pres, et elle",
                         "tombe si gamma bute sur une borne de son domaine", paste0(dom_gamma, "."),
                         "L'ecart residuel renseigne donc sur la convergence en gamma,",
                         "sous cette reserve."),
        stop("contrainte() : grandeur inconnue : ", quoi))
    else if (isTRUE(fit$delta_au_bord))
      switch(quoi,
        centrage = paste("Ici delta est au bord de [0,1] mais pi_t n'est PAS constant :",
                         "seule la contrainte ponderee subsiste, la valeur affichee n'est",
                         "donc pas nulle ; elle mesure l'ecart entre",
                         "version ponderee et version non ponderee."),
        variance = paste("Ici delta est au bord de [0,1] mais pi_t n'est PAS constant :",
                         cond_gamma_ponderee, "var(z) reste rivee par cette condition mais",
                         "n'est pas determinee par elle ; son ecart a T/(T-1) n'a pas de",
                         "valeur de reference."),
        stop("contrainte() : grandeur inconnue : ", quoi))
    else
      switch(quoi,
        centrage = paste("Ici delta est interieur a [0,1] et pi_t n'est pas constant :",
                         "seule la contrainte ponderee subsiste ; la valeur affichee mesure",
                         "l'ecart entre version ponderee et version non ponderee."),
        variance = paste("Ici delta est interieur a [0,1] et pi_t n'est pas constant :",
                         cond_gamma_ponderee, "var(z) reste rivee par cette condition mais",
                         "n'est pas determinee par elle ; son ecart a T/(T-1) n'a pas de",
                         "valeur de reference."),
        stop("contrainte() : grandeur inconnue : ", quoi))
  }
  sans_p <- paste("Aucune p-value retenue : la grandeur est rivee par",
                  "l'estimation, elle est restituee comme diagnostic (ADR 0001).")
  add(fam, "Centrage des residus standardises", "Diagnostic de centrage (ADR 0001)",
      fonction = "usp_tests",
      type = "diagnostic", estim_nom = "moyenne(z)", estim = mean(z),
      detail = paste("Grandeur rivee par l'estimation :",
                     "somme(sqrt(pi_t) z_t) = 0 par condition du premier ordre,",
                     "d'ou moyenne(z) = 0 lorsque pi_t est constant.",
                     contrainte("centrage"), sans_p))
  add(fam, "Variance unitaire des residus standardises", "Diagnostic d'echelle (ADR 0001)",
      fonction = "usp_tests",
      type = "diagnostic", estim_nom = "var(z)", estim = stats::var(z),
      detail = paste("Grandeur rivee par l'estimation : la condition du",
                     "premier ordre en gamma, qui ne tient qu'a un optimum",
                     "interieur en gamma, donne, jointe a celle en ln(beta),",
                     "somme(z_t^2) = T lorsque pi_t est constant, soit",
                     "var(z) = T/(T-1).",
                     contrainte("variance"), sans_p))

  ## --- F. Stabilite, ruptures et points aberrants ----------------------------
  fam <- "F. Stabilite, ruptures et points aberrants"
  add(fam, "Rupture de niveau (sup-F)", "Quandt (1960) / Chow (1960) ; Andrews (1993)",
      fonction = "stat_supF",
      base = "z",
      H0 = "E[z_t] constant (absence de rupture)", H1 = "rupture de niveau a une date inconnue",
      stat_nom = "supF", stat = boot$stats_obs$supF,
      loi = "supremum de processus (Andrews) -> Monte-Carlo", mc_nom = "supF",
      detail = "La loi de Fisher est inapplicable : le point de rupture est estime")
  add(fam, "Stabilite cumulee (OLS-CUSUM)", "Brown, Durbin & Evans (1975), JRSS B 37",
      fonction = "stat_cusum",
      base = "z",
      H0 = "constance des parametres sur la periode", H1 = "derive graduelle",
      stat_nom = "CUSUM", stat = boot$stats_obs$CUSUM,
      loi = "sup |pont brownien| ; formule de Kolmogorov asymptotique",
      p_as = { cc <- boot$stats_obs$CUSUM
               if (is.finite(cc)) .p_borne(2 * sum((-1)^(0:99) *
                 exp(-2 * (1:100)^2 * cc^2))) else NA_real_ },
      mc_nom = "CUSUM",
      detail = if (mc_dispo("CUSUM"))
        "La formule asymptotique n'a aucune validite a T = 8 : p_mc retenue"
      else paste("La formule asymptotique n'a aucune validite a T = 8 ;",
                 txt_mc_indispo("p_mc")))
  gr <- test_grubbs(z)
  add(fam, "Valeur aberrante isolee (Grubbs)", "Grubbs (1950, 1969), Technometrics 11",
      fonction = "test_grubbs",
      base = "z",
      H0 = "aucune valeur aberrante (echantillon normal homogene)",
      H1 = "exactement une valeur aberrante",
      stat_nom = "G", stat = gr$stat,
      loi = "Student + borne de Bonferroni (conservatrice)",
      p_as = gr$p, mc_nom = "Grubbs",
      estim_nom = "rang de l'obs. extreme", estim = gr$idx,
      detail = sprintf("G est borne par (T-1)/sqrt(T) = %.3f", (T - 1) / sqrt(T)))
  ro <- test_rosner(z, alpha = alpha)
  add(fam, "Valeurs aberrantes multiples (ESD generalise)", "Rosner (1983), Technometrics 25",
      fonction = "test_rosner",
      type = "procedure de decision",
      H0 = "aucune valeur aberrante", H1 = "il existe i <= k valeurs aberrantes",
      estim_nom = "nb de valeurs aberrantes", estim = ro$nb_outliers,
      detail = sprintf("procedure a niveau alpha = %.2f (aucune p-value)%s", alpha,
                       if (ro$nb_outliers > 0)
                         paste0(" ; rangs ", paste(ro$positions, collapse = ", ")) else ""),
      verdict = if (ro$nb_outliers >= 2) "ECHEC"
                else if (ro$nb_outliers == 1) "ALERTE" else "OK")
  # Distance de Cook et leviers de y = beta x (#153) : x et y mis a l'echelle
  # exacte (.usp_echelle_exacte()), D_t et h_t etant invariants par x -> a x,
  # y -> b y. Sans elle, D_t devenait non fini a petite echelle (x et y x
  # 10^e, e <= -164 pour le jeu de l'issue, e <= -163 pour les donnees de
  # test) et if (any(ck > 4 / T)) levait une erreur R. La ligne et sa garde
  # "non applicable" sont construites par .usp_ligne_cook(). Les leviers hv
  # de ce meme modele alimentent aussi la ligne "Leviers (hat values)"
  # (famille F ci-dessous) : h_t ne depend que de x et est invariant par
  # x -> a x (identical() a l'echelle 1, mesure #153).
  xe <- .usp_echelle_exacte(x); ye <- .usp_echelle_exacte(y)
  mlm <- stats::lm(ye ~ xe - 1); ck <- stats::cooks.distance(mlm); hv <- stats::hatvalues(mlm)
  lc <- .usp_ligne_cook(ck, T)
  add(fam, "Points influents (distance de Cook)", "Cook (1977), Technometrics 19",
      fonction = "usp_tests",
      type = lc$type, estim_nom = "max D_t", estim = lc$estim, detail = lc$detail)
  ## --- Variante "ratios bruts" des tests d'independance et de stabilite -----
  # Memes statistiques appliquees aux ratios centres u_t = r_t - moyenne(r).
  # Interet : ces tests ne dependent d'aucun ajustement, ce qui les rend
  # interpretables economiquement (une valeur aberrante de u_t est un
  # boni/mali exceptionnel) et insensibles a une mauvaise specification du
  # modele. Limite : les u_t sont heteroscedastiques par construction
  # (Var(r_t) depend de x_t), donc les p-values classiques ne sont
  # qu'INDICATIVES ; seule la p-value de Monte-Carlo est valide, le bootstrap
  # simulant sous le modele ajuste (exception : Runsr a pi_t constant, p-value
  # exacte, issue #29 ; voir plus bas). Verification par simulation a T = 8 :
  # niveau tenu a 10,7 % et 5,0 % pour des seuils de 10 % et 5 %.
  loi_ind <- "loi classique INDICATIVE (ratios heteroscedastiques) -> Monte-Carlo"
  # QUAND pi_t EST CONSTANT, CETTE BASE PERD SON OBJET. ln(beta) se reduit
  # alors a 1/(2 pi) + moyenne(ln r), donc z_t = sqrt(pi) (ln r_t -
  # moyenne(ln r)) : z et u_t = r_t - moyenne(r) ne different plus que par la
  # transformation log, qui est monotone. La statistique des suites est par
  # consequent IDENTIQUE sur les deux bases -- les signes de r_t - med(r) et
  # de z_t - med(z) coincident exactement (mesure : -0,7637626 des deux
  # cotes) -- et les autres ne different qu'au second ordre en CV(r) (mesure
  # sur les donnees du depot : cor(z, u) = 0,998, cor(z, ln r) = 1).
  # Il n'y a pas d'artefact de ponderation a detecter la ou il n'y a pas de
  # ponderation : ces six lignes sont alors des quasi-doublons de leurs
  # homologues sur residus, et le detail le dit au relecteur plutot que de
  # lui laisser croire a six verifications independantes.
  note_r <- if (isTRUE(pi_constant))
    paste("CONTROLE SANS OBJET ICI : pi_t est constant (delta = 1, ou volumes",
          "x_t constants), il n'y a donc aucun artefact de ponderation a",
          "detecter. Cette ligne est un quasi-doublon de son homologue sur",
          "residus standardises, dont elle ne differe que par la transformation",
          "logarithmique.") else ""
  detail_r <- function(txt = "") trimws(paste(txt, note_r))
  # Ligne Runsr (issue #29, decision M8) : p-value exacte sous la double
  # condition de usp_runsr_p_exacte(), calculee une fois ; le champ loi et le
  # detail en suivent le regime (note_r n'est pas concatenee pour cette
  # ligne) :
  #   1  : p exacte attribuee (pi_t constant, signes identiques), avec la
  #        variante 1b si pi_t n'est constant qu'a la tolerance pres ;
  #   2  : pi_t constant mais au moins un signe differe entre u et z ;
  #   2b : pi_t constant, signes identiques, mais p exacte non definie (un
  #        seul cote de la mediane represente) ;
  #   3  : pi_t variable.
  p_ex_r <- usp_runsr_p_exacte(z, u, pi_constant)
  # #128 : la phrase "p-value EXACTE ... retenue" du regime 1 n'est vraie que
  # hors motif de degenerescence de la statistique Runsr, qui ecarte aussi la
  # p exacte dans add() (motifs_degeneres d'engine_registre_tests()). Runsr
  # n'a pas de condition degenere au catalogue, mais une loi simulee
  # ponctuelle (engine_p_mc()) n'est pas exclue par le code.
  m_runsr <- if (!is.null(boot$motif_mc) && "Runsr" %in% names(boot$motif_mc))
    unname(boot$motif_mc[["Runsr"]]) else NA_character_
  runsr_degenere <- !is.na(m_runsr) &&
    m_runsr %in% c(MOTIF_MC_DISPERSION_NULLE, MOTIF_MC_ATOME_HORS_OBS, MOTIF_MC_CONDITION)
  eff_u <- .runs_effectifs(u)
  detail_runsr <- if (is.finite(p_ex_r)) {
    d1 <- paste("CONTROLE SANS OBJET ICI : pi_t est constant (delta = 1, ou volumes",
                "x_t constants), il n'y a donc aucun artefact de ponderation a",
                "detecter. Cette ligne est un quasi-doublon de son homologue sur",
                "residus standardises : les signes de u_t - med(u) et de z_t - med(z)",
                "coincident (z_t est une transformation croissante de r_t), la",
                "statistique des suites est IDENTIQUE a celle de la ligne sur residus",
                "standardises. Les r_t etant i.i.d. sous le modele ajuste, la loi",
                "combinatoire de R s'applique aussi aux ratios bruts : la p-value",
                if (runsr_degenere)
                  "EXACTE est ecartee par le motif de degenerescence en tete (ADR 0001)."
                else paste("EXACTE est retenue (convention bilaterale du doublement, celle du",
                           "bootstrap), la meme que sur la ligne des suites sur residus",
                           # #128, point c : la phrase sur p_mc n'est ecrite que si
                           # p_mc existe ; absente, rien n'est ajoute (la p retenue,
                           # exacte, est deja nommee, et nature_p le dit).
                           if (mc_dispo("Runsr"))
                             paste("standardises (issue #29). La p-value Monte-Carlo de la colonne p_mc",
                                   "estime la meme quantite, a l'erreur Monte-Carlo pres.")
                           else "standardises (issue #29)."))
    if (!isTRUE(regime$pi_constant_exact))
      d1 <- paste(d1, sprintf(paste(
        "Ici pi_t n'est constant qu'a la tolerance TOL_DELTA_BORD = %g pres (%s) :",
        "les arrangements de signes ne sont equiprobables qu'a un ecart d'ordre",
        "(1 - delta), ou de l'etendue relative des volumes x_t, pres, inferieur a",
        "la precision d'affichage ; la p-value est exacte a cet ordre pres."),
        TOL_DELTA_BORD, ecart_tol))
    d1
  } else if (isTRUE(pi_constant) && !.signes_mediane_egaux(z, u)) {
    sprintf(paste(
      "CONTROLE SANS OBJET ICI : pi_t n'est constant qu'a la tolerance",
      "TOL_DELTA_BORD = %g pres (%s), il n'y a donc aucun artefact de ponderation",
      "a detecter, et cette ligne est un quasi-doublon de son homologue sur",
      "residus standardises. Toutefois la variation residuelle de pi_t suffit ici",
      "a inverser au moins un signe entre u_t - med(u) et z_t - med(z) : l'identite",
      "des deux lignes n'est plus garantie (la statistique des suites peut",
      "coincider ou non), la loi combinatoire de R n'est pas attribuee a cette",
      "ligne (issue #29, seconde condition de usp_runsr_p_exacte()) et la p-value",
      if (mc_dispo("Runsr")) "Monte-Carlo, simulee sous le modele ajuste, est retenue."
      else paste0(txt_mc_indispo("Monte-Carlo, simulee sous le modele ajuste,"), ".")),
      TOL_DELTA_BORD, ecart_tol)
  } else if (isTRUE(pi_constant)) {
    paste(note_r, "La loi combinatoire de R n'est pas definie ici (un seul cote",
          "de la mediane represente) : aucune p-value exacte (issue #29).")
  } else {
    paste("pi_t varie avec t : sous le modele ajuste, les r_t sont independants",
          "mais heteroscedastiques (echelle 1/sqrt(pi_t) et mediane propres a",
          "chaque annee), les arrangements des signes de u_t - med(u) ne sont pas",
          "equiprobables et la loi combinatoire de R n'est qu'une approximation,",
          "sans borne d'erreur connue a T = 8.",
          if (mc_dispo("Runsr"))
            "Seule la p-value Monte-Carlo, simulee sous le modele ajuste avec ses pi_t, est retenue ;"
          else
            paste(txt_mc_indispo("La p-value Monte-Carlo, simulee sous le modele ajuste avec ses pi_t,"), ";"),
          "la statistique differe en general de celle de la ligne des suites sur",
          "residus standardises (issue #29).")
  }
  add(fam_h4,
      fonction = "stat_dw",
      "Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts",
      "Durbin & Watson (1950, 1951)", base = "r",
      H0 = "absence d'autocorrelation d'ordre 1 du ratio S/P",
      H1 = "autocorrelation du ratio S/P",
      stat_nom = "DW", stat = boot$stats_obs$DWr, loi = loi_ind, mc_nom = "DWr",
      detail = detail_r())
  add(fam_h4,
      fonction = "usp_tests",
      "Ljung-Box (retard 1) sur ratios bruts", "Ljung & Box (1978), Biometrika 65",
      base = "r", H0 = "rho_1 = 0 pour le ratio S/P", H1 = "autocorrelation au retard 1",
      stat_nom = "Q", stat = boot$stats_obs$LB1r, loi = loi_ind, mc_nom = "LB1r",
      detail = detail_r())
  add(fam_h4,
      fonction = "test_runs",
      "Test des suites sur ratios bruts", "Wald & Wolfowitz (1940)",
      base = "r", H0 = "arrangement aleatoire des signes du ratio centre",
      H1 = "arrangement non aleatoire",
      stat_nom = "Z", stat = boot$stats_obs$Runsr,
      loi = if (is.finite(p_ex_r))
        "loi combinatoire EXACTE de R (pi_t constant : r_t i.i.d., signes identiques a ceux de z_t)"
      else loi_ind,
      # Issue #29 (M8) : p exacte seulement sous la double condition de
      # usp_runsr_p_exacte() ; sinon Monte-Carlo. Les cinq autres lignes de la
      # base "r" restent en Monte-Carlo dans tous les regimes (u_t non
      # gaussiens : ni Imhof ni loi normale).
      p_ex = p_ex_r, mc_nom = "Runsr",
      type = if (is.finite(boot$stats_obs$Runsr)) "test" else "non applicable",
      p_min = runs_p_min(eff_u[["n1"]], eff_u[["n2"]]),
      effectifs = sprintf("n1 = %d, n2 = %d", eff_u[["n1"]], eff_u[["n2"]]),
      detail = if (is.finite(boot$stats_obs$Runsr)) detail_runsr else
        paste("un seul cote de la mediane represente : loi de R non definie,",
              "test non applicable"))
  add(fam, "Rupture de niveau (sup-F) sur ratios bruts",
      fonction = "stat_supF",
      "Quandt (1960) / Chow (1960) ; Andrews (1993)", base = "r",
      H0 = "niveau du ratio S/P constant", H1 = "rupture de niveau du ratio S/P",
      stat_nom = "supF", stat = boot$stats_obs$supFr,
      loi = "supremum de processus -> Monte-Carlo", mc_nom = "supFr",
      detail = detail_r("Detecte un changement de regime du ratio, independamment du modele."))
  add(fam, "Stabilite cumulee (OLS-CUSUM) sur ratios bruts",
      fonction = "stat_cusum",
      "Brown, Durbin & Evans (1975), JRSS B 37", base = "r",
      H0 = "constance du niveau du ratio S/P", H1 = "derive graduelle",
      stat_nom = "CUSUM", stat = boot$stats_obs$CUSUMr,
      loi = "sup |pont brownien| -> Monte-Carlo", mc_nom = "CUSUMr",
      detail = detail_r())
  add(fam, "Valeur aberrante isolee (Grubbs) sur ratios bruts",
      fonction = "test_grubbs",
      "Grubbs (1950, 1969), Technometrics 11", base = "r",
      H0 = "aucun ratio S/P aberrant", H1 = "exactement un ratio aberrant",
      stat_nom = "G", stat = boot$stats_obs$Grubbsr, loi = loi_ind,
      estim_nom = "rang du ratio extreme",
      estim = { g <- test_grubbs(u); if (is.finite(g$stat)) g$idx else NA_real_ },
      mc_nom = "Grubbsr",
      detail = detail_r("Identifie l'annee au boni/mali le plus atypique, sans passer par le modele."))

  add(fam, "Leviers (hat values)", "Hoaglin & Welsch (1978), Amer. Statist. 32",
      fonction = "usp_tests",
      type = "diagnostic", estim_nom = "max h_t", estim = max(hv),
      detail = sprintf("repere conventionnel 2k/T = %.3f ; %d observation(s) au-dessus",
                       2 / T, sum(hv > 2 / T)))

  ## --- G. Robustesse de l'estimation -----------------------------------------
  fam <- "G. Robustesse de l'estimation"
  # La condition du premier ordre et la convergence multi-demarrages ne sont
  # pas des tests : elles figurent dans res$controles, famille "H."
  # (usp_controles_numeriques(), issue #22, decision M11).
  # Jackknife et IC : libelles concis (issue #76, textes retenus par le
  # mainteneur). Aucun nombre issu du bootstrap ou des reajustements du
  # jackknife n'est imprime, faute de quoi il deriverait d'une plateforme a
  # l'autre (issue #24 ; jusqu'a 3,5e-7 en relatif). Les valeurs sont
  # ailleurs : ecart relatif max sur sigma_USP et largeur (q95 - q05) /
  # sigma_USP dans estim, bornes de l'IC 90 % dans res$ic_bootstrap ; les
  # reperes conventionnels (10 % / 20 %, 50 % / 80 %) dans les fiches du
  # .tex. Le jackknife imprime l'annee la plus influente et le signe de
  # l'ecart sur sigma_USP a cette annee (entier et signe, stables), si
  # run_engine() a fourni `robustesse`. Les ecarts rapportes a la seule part
  # estimee sigma(delta, gamma), imprimes jusqu'ici faute d'etre stockes
  # ailleurs (risque accepte en M24), sont retires (issue #76).
  rb <- robustesse
  if (!is.null(fit$ecart_jackknife))
    add(fam, "Sensibilite au retrait d'une annee (jackknife)",
        fonction = "run_engine",
        "Quenouille (1949) / Tukey (1958)", type = "diagnostic",
        estim_nom = "ecart relatif max", estim = fit$ecart_jackknife,
        detail = if (!is.null(rb$jack_annee))
          sprintf("Annee la plus influente : %d (sigma_USP %s).", as.integer(rb$jack_annee),
                  if (rb$jack_usp < 0) "en baisse" else if (rb$jack_usp > 0) "en hausse"
                  else "inchange")
        else "Annee la plus influente non determinee.")
  if (!is.null(fit$largeur_ic))
    add(fam, "Largeur relative de l'IC bootstrap 90%", "Efron (1979), Ann. Statist. 7",
        fonction = "run_engine",
        type = "diagnostic",
        estim_nom = "largeur / sigma_USP", estim = fit$largeur_ic,
        detail = "Intervalle bootstrap du parametre retenu : res$ic_bootstrap.")
  # Issue #45 (specification d'actuary du 28/09/2026, par. 2.7 ; decisions
  # du mainteneur, Q1 et Q6) : IC bootstrap a delta fixe a sa valeur
  # estimee, puis rapport de vraisemblance aux bornes delta = 0 et delta = 1.
  # Diagnostics sans verdict ni p-value retenue (ADR 0001) ; la p
  # Monte-Carlo du bootstrap restreint est restituee dans p_mc (p_mc_ext de
  # add()), la p du melange de Chernoff dans p_asymptotique, pour memoire.
  # Aucun nombre issu du bootstrap dans detail (#24, #76).
  if (!is.null(fit$largeur_ic_restreint))
    add(fam, "Largeur relative de l'IC bootstrap 90% (delta fixe a delta estime)",
        fonction = "run_engine",
        "Efron (1979), Ann. Statist. 7 ; Andrews (2000), Econometrica 68",
        type = "diagnostic",
        estim_nom = "largeur / sigma_USP", estim = fit$largeur_ic_restreint,
        detail = paste("Bootstrap parametrique a delta fixe a sa valeur estimee (seul gamma",
                       "reajuste), memes replications que l'IC complet ; une replication",
                       "dont le reajustement contraint echoue est ecartee du seul bootstrap",
                       "restreint (res$bootstrap$n_echec_restreint). Incertitude",
                       "conditionnelle a la structure de variance retenue. Le bootstrap",
                       "complet, qui reajuste delta, n'est pas convergent quand delta est",
                       "au bord (Andrews, 2000). Bornes : res$ic_bootstrap_restreint."))
  if (!is.null(lr_delta)) {
    txt_lr <- paste("Aucun verdict (ADR 0001) : le LR mesure si les donnees distinguent",
                    "cette borne de l'optimum, non l'adequation du modele. Lecture : LR = 0,",
                    "borne atteinte par l'estimation ; p_mc elevee, borne aussi defendable",
                    "que delta estime ; p_mc faible, borne moins compatible avec les",
                    "donnees. La p asymptotique (melange de Chernoff) est rapportee pour",
                    "memoire et non retenue : ecart a la loi simulee mesure a T = 8 (fiche",
                    "du .tex).")
    loi_lr <- paste("sous H0 : loi simulee par bootstrap parametrique restreint (modele",
                    "contraint delta = delta0, B replications) ; asymptotique : melange",
                    "1/2 chi2(0) + 1/2 chi2(1), non retenue")
    libelles <- list(
      list(nom = "Rapport de vraisemblance : delta = 0 (variance lineaire en volume)",
           H0 = "delta = 0 (variance proportionnelle au volume)", H1 = "delta > 0",
           stat_nom = "LR(0)", b = lr_delta$borne0),
      list(nom = "Rapport de vraisemblance : delta = 1 (variance quadratique en volume)",
           H0 = "delta = 1 (variance proportionnelle au carre du volume)", H1 = "delta < 1",
           stat_nom = "LR(1)", b = lr_delta$borne1))
    for (li in libelles) {
      b <- li$b
      # Borne en echec sur l'observe (#161, usp_lr_delta()) : LR non fini,
      # ligne non applicable (INFO, aucune p-value) avec le motif fixe,
      # precede en volumes constants du rappel que le LR y serait nul.
      if (!is.finite(b$lr)) {
        add(fam, li$nom,
            fonction = "usp_lr_delta",
            "Chernoff (1954) ; Self & Liang (1987), JASA 82 ; Davison & Hinkley (1997), chap. 4",
            type = "non applicable", H0 = li$H0, H1 = li$H1,
            stat_nom = li$stat_nom, stat = NA_real_, loi = loi_lr,
            estim_nom = "sigma(delta0, gamma~)", estim = NA_real_,
            detail = if (isTRUE(regime$volumes_constants))
              paste("VOLUMES CONSTANTS : delta non identifie, LR nul par construction attendu",
                    "a cette borne mais non calcule.", MOTIF_LR_DELTA_ECHEC)
            else MOTIF_LR_DELTA_ECHEC)
        next
      }
      pref <- character(0)
      if (!is.finite(b$p_mc))
        pref <- c(pref, paste0(b$motif_mc, " : aucune p-value Monte-Carlo."),
                  .complement_motif_mc(b$motif_mc))
      if (isTRUE(regime$volumes_constants))
        pref <- c(pref, "VOLUMES CONSTANTS : delta non identifie, LR nul aux deux bornes par construction.")
      else if (abs(fit$delta - b$delta0) <= TOL_DELTA_BORD)
        pref <- c(pref, sprintf("SOLUTION AU BORD delta = %d : LR = 0 par construction.",
                                as.integer(b$delta0)))
      add(fam, li$nom,
          fonction = "usp_lr_delta",
          "Chernoff (1954) ; Self & Liang (1987), JASA 82 ; Davison & Hinkley (1997), chap. 4",
          type = "diagnostic", H0 = li$H0, H1 = li$H1,
          stat_nom = li$stat_nom, stat = b$lr, loi = loi_lr,
          estim_nom = "sigma(delta0, gamma~)", estim = b$sigma_contraint,
          p_as = b$p_asymptotique, p_mc_ext = b$p_mc, err_mc_ext = b$err_mc,
          detail = paste(c(pref, txt_lr), collapse = " "))
    }
  }
  reg$lignes()
}


## =============================================================================
## 7. LECTURE D'UN JEU DE DONNEES AU FORMAT D'EXPORT (t, xt, yt)
## =============================================================================

# Interprete un data.frame deja charge (colonnes attendues : t, xt, yt -- le
# format exact ecrit par le bouton d'export de l'application) et en extrait les
# vecteurs xt, yt, tries selon t si cette colonne est presente.
# La LECTURE du fichier (acces disque) reste du ressort de la couche Shiny ;
# cette fonction ne fait que l'interpretation structurelle du tableau une fois
# charge, ce qui la rend testable independamment de toute interface :
#     df  <- utils::read.csv("usp_donnees.csv")
#     res <- engine_lire_donnees_csv(df)
# Regles (issue #33, avis d'actuary du 24/09/2026) :
#  - une colonne facteur est convertie par ses VALEURS (texte), jamais par ses
#    codes internes ;
#  - la colonne t, si elle est presente, doit etre complete, numerique,
#    entiere, sans doublon et CONSECUTIVE (annexe XVII, B(2)(b) : "cinq
#    annees d'accident consecutives" ; C(2)(b) : "cinq exercices
#    consecutifs") ; elle est alors triee en croissant.
#    Sinon le fichier est refuse : aucun tri ni comblement silencieux. Les
#    tests de la famille H3 supposent des annees equidistantes ;
#  - sans colonne t, l'ordre du fichier est repute chronologique et la
#    consecutivite n'est pas verifiable.
.en_numerique <- function(v) {
  if (is.factor(v)) v <- as.character(v)
  # Cellule non UTF-8 en locale UTF-8 : non numerique, sans erreur R (#99).
  if (is.character(v)) return(.cellules_en_nombre(.nettoyer_cellules(v)))
  suppressWarnings(as.numeric(v))
}

engine_lire_donnees_csv <- function(df) {
  err <- character(0)
  if (!is.data.frame(df) || !nrow(df))
    return(list(ok = FALSE, erreurs = "Fichier vide ou illisible comme tableau.",
                xt = NULL, yt = NULL, n = 0L))
  # BOM d'un CSV lu hors locale UTF-8 : sans ce retrait, la colonne t
  # (premiere colonne) n'etait plus reconnue et le controle des annees ne
  # s'appliquait pas, sans message (issue #96).
  if (ncol(df)) names(df)[1] <- .nom_sans_bom(names(df)[1])
  noms <- names(df)
  manquantes <- setdiff(c("xt", "yt"), noms)
  if (length(manquantes)) {
    return(list(ok = FALSE,
                erreurs = sprintf(
                  "Colonne(s) manquante(s) : %s. Colonnes attendues : t, xt, yt (format d'export de l'application). Colonnes presentes : %s.",
                  paste(manquantes, collapse = ", "), paste(noms, collapse = ", ")),
                xt = NULL, yt = NULL, n = 0L))
  }
  xt <- .en_numerique(df$xt)
  yt <- .en_numerique(df$yt)
  if (anyNA(xt) || anyNA(yt))
    err <- c(err, "Certaines valeurs de xt ou yt ne sont pas numeriques.")
  if ("t" %in% noms) {
    to <- .en_numerique(df$t)
    if (anyNA(to))
      err <- c(err, sprintf(paste("Colonne t incomplete ou non numerique (ligne(s) %s) :",
                                  "chaque ligne doit porter son annee."),
                            paste(which(is.na(to)), collapse = ", ")))
    else if (any(!is.finite(to) | to != round(to)))
      err <- c(err, "Colonne t : les annees doivent etre des entiers finis.")
    else if (anyDuplicated(to))
      err <- c(err, sprintf("Colonne t : annee(s) dupliquee(s) (%s).",
                            paste(unique(to[duplicated(to)]), collapse = ", ")))
    else if (length(to) > 1 && any(diff(sort(to)) != 1))
      err <- c(err, sprintf(paste("Colonne t : annees non consecutives (%s) ; l'annexe XVII,",
                                  "B(2)(b) et C(2)(b), exige des annees consecutives."),
                            paste(sort(to), collapse = ", ")))
    else { o <- order(to); xt <- xt[o]; yt <- yt[o] }
  }
  list(ok = length(err) == 0, erreurs = err, xt = xt, yt = yt, n = length(xt))
}

# Conversion d'un tableau deja charge (data.frame ou matrice : une ligne par
# annee d'accident, une colonne par annee de developpement, colonne "i"
# facultative ignoree) en triangle de cumules, puis controle de recevabilite
# par mw_valider_triangle(). Fonction unique de conversion fichier ->
# triangle (issue #33, #4 piste 3) : l'interface n'a plus a convertir. Une
# cellule vide vaut NA (partie non observee) ; une cellule non vide et non
# numerique est refusee, jamais lue comme NA. Les colonnes facteur sont
# converties par leurs valeurs.
# Renvoie list(ok, erreurs, avertissements, triangle, I, J).
engine_lire_triangle <- function(df) {
  refus <- function(e) list(ok = FALSE, erreurs = e, avertissements = character(0),
                            triangle = NULL, I = NA, J = NA)
  if (is.matrix(df)) df <- as.data.frame(df, stringsAsFactors = FALSE)
  if (!is.data.frame(df) || !nrow(df) || !ncol(df))
    return(refus("Fichier vide ou illisible comme tableau."))
  # BOM d'un CSV lu hors locale UTF-8 : sans ce retrait, la colonne "i" n'etait
  # plus reconnue et le triangle etait refuse avec un motif trompeur (#96).
  names(df)[1] <- .nom_sans_bom(names(df)[1])
  df <- df[, setdiff(names(df), "i"), drop = FALSE]
  if (!ncol(df)) return(refus("Aucune colonne d'annee de developpement."))
  brut <- lapply(df, function(v) {
    if (is.factor(v)) v <- as.character(v)
    if (is.character(v)) v <- .nettoyer_cellules(v)
    v
  })
  num <- lapply(brut, .en_numerique)
  vide <- lapply(brut, function(v) is.na(v) | (is.character(v) & !nzchar(v)))
  illisible <- which(!do.call(base::cbind, vide) & is.na(do.call(base::cbind, num)), arr.ind = TRUE)
  if (length(illisible)) {
    k <- utils::head(illisible, 5)
    return(refus(sprintf("Cellule(s) non numerique(s) en %s%s.",
                         paste0("(i=", k[, 1] - 1L, ", j=", k[, 2] - 1L, ")", collapse = ", "),
                         if (nrow(illisible) > 5) sprintf(" et %d autre(s)", nrow(illisible) - 5) else "")))
  }
  m <- unname(do.call(base::cbind, num))
  storage.mode(m) <- "double"
  v <- mw_valider_triangle(m)
  list(ok = v$ok, erreurs = v$erreurs, avertissements = v$avertissements,
       triangle = if (v$ok) m else NULL, I = v$I, J = v$J)
}



## =============================================================================
## 7ter. ECHANGE AU FORMAT EXCEL (.xlsx)
##
## Un fichier .xlsx est une archive ZIP contenant du XML (norme ECMA-376,
## OOXML). Aucun paquet R specialise n'etant suppose disponible, le moteur
## embarque un lecteur et un ecrivain minimaux, suffisants pour des feuilles
## rectangulaires de nombres et de chaines, qui est exactement le besoin ici
## (series x_t / y_t, ou triangle de cumules).
##
## Si le paquet openxlsx est installe, il est utilise en priorite : son
## implementation est plus complete et mieux eprouvee. Les fonctions ci-dessous
## constituent un repli, non un remplacement.
## =============================================================================

.col_lettre <- function(i) {                       # 1 -> "A", 27 -> "AA"
  out <- character(0)
  while (i > 0) { r <- (i - 1) %% 26; out <- c(LETTERS[r + 1], out); i <- (i - 1) %/% 26 }
  paste(out, collapse = "")
}
.lettre_col <- function(s) {                       # "AA" -> 27
  ch <- utf8ToInt(toupper(s)) - 64L
  sum(ch * 26^rev(seq_along(ch) - 1))
}
.xml_echap <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}

# Ecrit un data.frame dans un classeur .xlsx a une feuille. Les colonnes
# numeriques sont ecrites comme nombres, les autres comme chaines en ligne
# (inlineStr), ce qui evite d'avoir a gerer une table de chaines partagees.
engine_ecrire_xlsx <- function(df, chemin, feuille = "Donnees") {
  if (requireNamespace("openxlsx", quietly = TRUE)) {
    openxlsx::write.xlsx(df, chemin, sheetName = feuille)
    return(invisible(chemin))
  }
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  nc <- ncol(df); nr <- nrow(df)
  cellule <- function(ligne, col, valeur) {
    ref <- paste0(.col_lettre(col), ligne)
    if (is.na(valeur)) return("")
    if (is.numeric(valeur))
      sprintf('<c r="%s"><v>%s</v></c>', ref, format(valeur, scientific = FALSE, trim = TRUE))
    else
      sprintf('<c r="%s" t="inlineStr"><is><t>%s</t></is></c>', ref, .xml_echap(as.character(valeur)))
  }
  lignes <- character(nr + 1)
  lignes[1] <- paste0('<row r="1">',
    paste(vapply(seq_len(nc), function(j) cellule(1, j, names(df)[j]), character(1)),
          collapse = ""), '</row>')
  for (i in seq_len(nr)) {
    cs <- vapply(seq_len(nc), function(j) {
      v <- df[[j]][i]
      cellule(i + 1, j, if (is.factor(v)) as.character(v) else v)
    }, character(1))
    lignes[i + 1] <- paste0('<row r="', i + 1, '">', paste(cs, collapse = ""), '</row>')
  }
  sheet <- paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">',
    '<sheetData>', paste(lignes, collapse = ""), '</sheetData></worksheet>')

  # Dossier temporaire propre a l'appel, supprime en sortie (ADR 0004, #42)
  d <- tempfile("xlsx_")
  on.exit(unlink(d, recursive = TRUE), add = TRUE)
  dir.create(file.path(d, "_rels"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(d, "xl", "_rels"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(d, "xl", "worksheets"), recursive = TRUE, showWarnings = FALSE)
  writeLines(paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">',
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>',
    '<Default Extension="xml" ContentType="application/xml"/>',
    '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>',
    '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>',
    '</Types>'), file.path(d, "[Content_Types].xml"), useBytes = TRUE)
  writeLines(paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>',
    '</Relationships>'), file.path(d, "_rels", ".rels"), useBytes = TRUE)
  writeLines(paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"',
    ' xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">',
    '<sheets><sheet name="', .xml_echap(feuille), '" sheetId="1" r:id="rId1"/></sheets></workbook>'),
    file.path(d, "xl", "workbook.xml"), useBytes = TRUE)
  writeLines(paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>',
    '</Relationships>'), file.path(d, "xl", "_rels", "workbook.xml.rels"), useBytes = TRUE)
  writeLines(sheet, file.path(d, "xl", "worksheets", "sheet1.xml"), useBytes = TRUE)

  # Retour au repertoire initial AVANT la suppression de d (after = FALSE) :
  # on ne supprime pas le repertoire courant.
  wd <- setwd(d); on.exit(setwd(wd), add = TRUE, after = FALSE)
  cible <- if (grepl("^(/|[A-Za-z]:)", chemin)) chemin else file.path(wd, chemin)
  if (file.exists(cible)) unlink(cible)
  st <- utils::zip(cible, c("[Content_Types].xml", "_rels", "xl"), flags = "-r9Xq")
  if (!identical(st, 0L)) stop("Echec de la creation du fichier .xlsx (commande zip indisponible ?).")
  invisible(cible)
}

# Lit la premiere feuille d'un classeur .xlsx et renvoie un data.frame, la
# premiere ligne etant traitee comme l'en-tete. Les colonnes entierement
# numeriques sont converties en numerique.
engine_lire_xlsx <- function(chemin, entete = TRUE) {
  if (requireNamespace("openxlsx", quietly = TRUE))
    return(openxlsx::read.xlsx(chemin, sheet = 1, colNames = entete))
  # Dossier temporaire propre a l'appel, supprime en sortie (ADR 0004, #42) :
  # aucun sharedStrings.xml residuel d'une lecture anterieure.
  d <- tempfile("unx_")
  on.exit(unlink(d, recursive = TRUE), add = TRUE)
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
  utils::unzip(chemin, exdir = d)
  f <- list.files(file.path(d, "xl", "worksheets"), pattern = "\\.xml$", full.names = TRUE)
  if (!length(f)) stop("Classeur illisible : aucune feuille trouvee.")
  xml <- paste(readLines(f[1], warn = FALSE, encoding = "UTF-8"), collapse = "")
  # table des chaines partagees, si presente
  fs <- file.path(d, "xl", "sharedStrings.xml")
  partagees <- character(0)
  if (file.exists(fs)) {
    sx <- paste(readLines(fs, warn = FALSE, encoding = "UTF-8"), collapse = "")
    si <- regmatches(sx, gregexpr("<si>.*?</si>", sx))[[1]]
    partagees <- vapply(si, function(x) {
      t <- regmatches(x, gregexpr("<t[^>]*>.*?</t>", x))[[1]]
      paste(gsub("<[^>]*>", "", t), collapse = "")
    }, character(1))
  }
  cells <- regmatches(xml, gregexpr('<c [^>]*?/>|<c [^>]*?>.*?</c>', xml))[[1]]
  if (!length(cells)) return(data.frame())
  ref <- sub('.*r="([A-Z]+)([0-9]+)".*', "\\1|\\2", cells)
  col <- vapply(sub("\\|.*", "", ref), .lettre_col, numeric(1))
  lig <- as.integer(sub(".*\\|", "", ref))
  typ <- ifelse(grepl('t="[^"]*"', cells), sub('.*t="([^"]*)".*', "\\1", cells), "n")
  val <- rep(NA_character_, length(cells))
  vv <- regmatches(cells, regexpr("<v>.*?</v>", cells))
  ok <- grepl("<v>", cells)
  val[ok] <- gsub("<[^>]*>", "", vv)
  isx <- grepl("<is>", cells)
  if (any(isx)) val[isx] <- gsub("<[^>]*>", "",
    regmatches(cells[isx], regexpr("<t[^>]*>.*?</t>", cells[isx])))
  s <- typ == "s" & !is.na(val)
  if (any(s)) val[s] <- partagees[as.integer(val[s]) + 1L]
  m <- matrix(NA_character_, max(lig), max(col))
  m[cbind(lig, col)] <- val
  if (entete) {
    nm <- m[1, ]; corps <- m[-1, , drop = FALSE]
    nm[is.na(nm) | nm == ""] <- paste0("V", which(is.na(nm) | nm == ""))
  } else { nm <- paste0("V", seq_len(ncol(m))); corps <- m }
  df <- as.data.frame(corps, stringsAsFactors = FALSE)
  names(df) <- make.unique(nm)
  for (j in seq_along(df)) {
    num <- suppressWarnings(as.numeric(df[[j]]))
    if (all(is.na(num) == is.na(df[[j]]))) df[[j]] <- num
  }
  df
}

## =============================================================================
## 7quater. EMPREINTES D'UN RESULTAT (RAPPORT FIGE)
##
## engine_empreinte(res) calcule deux empreintes md5 (tools::md5sum, paquet
## tools, distribue avec R)
## qui identifient ce qu'un rapport fige restitue. Elle n'est PAS appelee par
## run_engine() : le resultat du moteur n'en depend pas et les references de
## non-regression restent inchangees. Aucun tirage aleatoire (tempfile() et
## md5sum() ne touchent pas a .Random.seed).
##
## Statut des deux empreintes :
##  - donnees : md5 d'un texte canonique des donnees effectivement utilisees
##    par le calcul (res$donnees pour les methodes lognormales, res$triangle
##    pour Merz-Wuthrich), et non de la saisie courante. Chaque valeur est
##    ecrite par sprintf("%.17g"), qui suffit a identifier un double IEEE 754,
##    les valeurs manquantes par "NA", les lignes separees par LF ; le texte
##    est ecrit octet par octet (writeBin), sans conversion de fin de ligne.
##    L'empreinte ne depend donc que des valeurs ; le texte est renvoye
##    (texte_donnees) pour qu'un tiers la recalcule avec n'importe quel outil
##    md5. Constance entre plateformes : attendue, non verifiee.
##  - resultat : md5 de saveRDS(res, version = 3, compress = FALSE), apres
##    retrait de metadata$horodatage et metadata$duree_sec, seuls champs qui
##    changent d'un appel a l'autre a graine egale. Elle est stable sur une
##    meme machine, mais DEPEND DE LA PLATEFORME : les valeurs numeriques de
##    la branche lognormale different entre plateformes (ADR 0006), l'objet
##    contient metadata$version_R, et l'en-tete de serialisation version 3
##    consigne l'encodage natif de la session. Elle identifie donc l'objet sur
##    la machine qui l'a produit ; elle ne se compare pas d'une plateforme a
##    l'autre.
##
## Resultat refuse (res$ok = FALSE) : aucune donnee n'a ete utilisee par un
## calcul, donnees et texte_donnees valent donc NA ; resultat est l'empreinte
## de l'objet refuse lui-meme (ok, validation, metadata sans horodatage),
## stable a donnees egales. rapport_html() refuse un tel resultat.
## =============================================================================

engine_empreinte <- function(res) {
  md5_octets <- function(ecrire) {
    f <- tempfile("empreinte_")
    on.exit(unlink(f), add = TRUE)
    ecrire(f)
    unname(as.character(tools::md5sum(f)))
  }
  num <- function(v) ifelse(is.na(v), "NA", sprintf("%.17g", as.numeric(v)))

  # --- Texte canonique des donnees utilisees par le calcul ------------------
  texte <- NA_character_
  if (isTRUE(res$ok)) {
    if (identical(res$methode, "reserve2") && !is.null(res$triangle)) {
      tri <- as.matrix(res$triangle)
      lignes <- c(sprintf("triangle;%d;%d", nrow(tri), ncol(tri)),
                  apply(tri, 1, function(l) paste(num(l), collapse = ";")))
    } else if (!is.null(res$donnees$xt)) {
      d <- res$donnees
      lignes <- c("t;xt;yt", paste(d$t, num(d$xt), num(d$yt), sep = ";"))
    } else lignes <- NULL
    if (!is.null(lignes)) texte <- paste0(paste(lignes, collapse = "\n"), "\n")
  }
  md5_donnees <- if (is.na(texte)) NA_character_ else
    md5_octets(function(f) writeBin(charToRaw(enc2utf8(texte)), f))

  # --- Resultat serialise, hors champs d'execution --------------------------
  r <- res
  if (!is.null(r$metadata)) {
    r$metadata$horodatage <- NULL
    r$metadata$duree_sec  <- NULL
  }
  md5_resultat <- md5_octets(function(f) saveRDS(r, f, version = 3, compress = FALSE))

  list(algorithme = "md5",
       donnees = md5_donnees,
       resultat = md5_resultat,
       texte_donnees = texte,
       statut = c(
         donnees = paste("texte canonique des donnees du calcul (%.17g, NA, LF) ;",
                         "ne depend que des valeurs"),
         resultat = paste("saveRDS version 3 sans horodatage ni duree ; stable sur",
                          "une meme machine, depend de la plateforme (ADR 0006)")))
}

## =============================================================================
## 8. CONTROLES DE VALIDITE (cote MOTEUR, independants de toute interface)
## =============================================================================

# Verifie que le couple (xt, yt) est exploitable par les methodes de l'annexe
# XVII. Ce controle a une signification statistique et actuarielle : il est donc
# implemente ICI, afin que le moteur reste sur meme appele hors de Shiny.
# Retourne une liste : $ok (logique), $erreurs (bloquantes), $avertissements.
# theta_equiv / delta_equiv : marge du test d'equivalence de la constante
# (TOST), memes valeurs par defaut que run_engine(). Un parametre hors de son
# domaine est une erreur d'entree, refusee ici (issue #33, avis d'actuary du
# 24/09/2026) : theta reel fini, 0 < theta < 1 ; delta_equiv, s'il est
# fourni, reel fini, 0 < Delta < moyenne(yt), theta etant alors ignore (seul
# celui des deux qui sert est controle). Pour theta >= 1 (ou Delta >= ybar),
# H1 : |a| < Delta contient le modele a = ybar, b = 0, negation de la
# proportionnalite : un rejet de H0 ne se lirait plus "proportionnalite
# pratique". Aucune borne plus serree n'est imposee (choix du dossier).
# methode / nature_donnees (issue #55, decision M13) : pour la methode du
# risque de primes, la nature des donnees ("brutes" ou "nettes" de
# reassurance) doit etre declaree ; son absence est une erreur bloquante, sans
# valeur par defaut. Pour une methode de reserve, des donnees declarees
# "brutes" sont refusees (C(2)(c), D(2)(f) : donnees nettes exigees ; NULL ou
# "nettes" acceptes). Sans methode (controle d'une saisie ou d'un import,
# hors calcul), la nature n'est pas controlee (.nature_erreurs()).
# bareme / segment / annexe (issue #131) : bareme de credibilite applique,
# resolu comme dans run_engine() (.engine_credibilite_appliquee() : bareme
# saisi, sinon bareme du segment, sinon "court" par convention) ; une valeur
# invalide est une erreur bloquante, sans erreur R. L'avertissement de
# credibilite partielle repose sur c(T, bareme applique) < 1 (annexe XVII,
# section G) ; l'avertissement statistique (lois asymptotiques peu fiables,
# T < 10) est un repere non reglementaire, distinct et inchange.
# Domaine numerique et ratio (issue #145) : une valeur de xt ou de yt hors
# de [DOMAINE_NUMERIQUE_MIN ; DOMAINE_NUMERIQUE_MAX] est refusee ; un ratio
# y/x hors de [RATIO_PLAUSIBLE_MIN ; RATIO_PLAUSIBLE_MAX[ est un
# avertissement. Ce refus renverse le choix "aucun seuil d'echelle" de #88 ;
# appele par engine_valider_serie_retenue(), il ne porte que sur la serie
# retenue.
engine_valider_donnees <- function(xt, yt, T_min = 5, theta_equiv = 0.10,
                                   delta_equiv = NULL, methode = NULL,
                                   nature_donnees = NULL, bareme = NULL,
                                   segment = NULL, annexe = "II") {
  err <- .nature_erreurs(methode, nature_donnees); avt <- character(0)
  if (!is.numeric(xt) || !is.numeric(yt))
    err <- c(err, "xt et yt doivent etre numeriques.")
  if (length(xt) != length(yt))
    err <- c(err, sprintf("xt (%d valeurs) et yt (%d valeurs) doivent avoir la meme longueur.",
                          length(xt), length(yt)))
  if (anyNA(xt) || anyNA(yt))
    err <- c(err, "Valeurs manquantes : le calibrage exige des series completes (art. 19).")
  # Valeur infinie (issue #33) : anyNA(Inf) est FALSE et Inf > 0 ; sans ce
  # controle, run_engine() s'arretait sur une erreur R au lieu de refuser.
  if (is.numeric(xt) && is.numeric(yt) && any(is.infinite(c(xt, yt))))
    err <- c(err, "Valeurs infinies : xt et yt doivent etre des nombres finis.")
  if (length(xt) && any(xt <= 0, na.rm = TRUE))
    err <- c(err, "Toutes les valeurs de xt doivent etre strictement positives.")
  if (length(yt) && any(yt <= 0, na.rm = TRUE))
    err <- c(err, "Toutes les valeurs de yt doivent etre strictement positives (loi lognormale).")
  # Domaine numerique (issue #145) : valeurs finies strictement positives
  # hors de [DOMAINE_NUMERIQUE_MIN ; DOMAINE_NUMERIQUE_MAX], bornes incluses
  # (NA, infinies et non positives sont refusees ci-dessus, sans doublon).
  # Un motif par serie, qui cite la premiere valeur fautive
  # (.engine_saisie(), 17 chiffres si necessaire) et la borne franchie.
  for (nm in c("xt", "yt")) {
    v <- list(xt = xt, yt = yt)[[nm]]
    if (!is.numeric(v)) next
    hors <- which(is.finite(v) & v > 0 &
                  (v < DOMAINE_NUMERIQUE_MIN | v > DOMAINE_NUMERIQUE_MAX))
    if (!length(hors)) next
    v1 <- v[hors[1]]
    borne <- if (v1 < DOMAINE_NUMERIQUE_MIN)
      sprintf("< %g, borne inferieure", DOMAINE_NUMERIQUE_MIN)
      else sprintf("> %g, borne superieure", DOMAINE_NUMERIQUE_MAX)
    err <- c(err, sprintf(paste(
      "Valeur de %s hors du domaine numerique [%g ; %g] : %s = %s (%s)%s.",
      "sigma_USP et les tests sont invariants par un changement d'unite commun",
      "a xt et yt (et a delta_equiv s'il est fourni) : exprimer les montants",
      "dans une unite qui les ramene dans le domaine."),
      nm, DOMAINE_NUMERIQUE_MIN, DOMAINE_NUMERIQUE_MAX, nm, .engine_saisie(unname(v1)),
      borne, if (length(hors) > 1L) sprintf(" ; %d valeurs hors du domaine", length(hors)) else ""))
  }
  if (length(xt) < T_min)
    err <- c(err, sprintf("Annexe XVII, B/C(2)(b) : au moins %d annees consecutives (T = %d).",
                          T_min, length(xt)))
  # Marge du TOST. Un scalaire numerique fini est exige avant toute
  # comparaison (NA, vide, vecteur, texte : refuses, sans erreur R).
  scalaire_fini <- function(v) is.numeric(v) && length(v) == 1L && is.finite(v)
  # Valeur refusee restituee par .engine_saisie() (issue #180) : un texte
  # garde ses guillemets ("0.1"), un vecteur sa forme c(...), NULL ou vide
  # est cite "vide", et un double que 15 chiffres ne restituent pas est cite
  # a 17 chiffres (1 + 2^-52 etait cite 1 par l'ancienne saisie() locale,
  # deparse() a 15 chiffres).
  if (!is.null(delta_equiv)) {
    if (!scalaire_fini(delta_equiv) || delta_equiv <= 0)
      err <- c(err, sprintf(paste("Marge Delta du test d'equivalence (delta_equiv = %s) : un nombre",
                                  "fini strictement positif est attendu."),
                            .engine_saisie(delta_equiv)))
    else if (is.numeric(yt) && length(yt) && all(is.finite(yt)) &&
             delta_equiv >= mean(yt))
      err <- c(err, sprintf(paste("Marge Delta du test d'equivalence (delta_equiv = %s) superieure",
                                  "ou egale a la perte moyenne (%s) : l'equivalence ne se lirait plus",
                                  "comme une proportionnalite ; 0 < Delta < moyenne(yt) est attendu."),
                            format(delta_equiv), format(mean(yt), digits = 6)))
  } else if (!scalaire_fini(theta_equiv) || theta_equiv <= 0 || theta_equiv >= 1)
    err <- c(err, sprintf(paste("Marge theta du test d'equivalence (theta_equiv = %s) : un nombre",
                                "fini, 0 < theta < 1 (fraction de la perte moyenne), est attendu."),
                          .engine_saisie(theta_equiv)))
  # Bareme, segment et annexe (issue #131) : controles avant tout
  # avertissement ; une valeur invalide est refusee sans erreur R.
  msg <- tryCatch({ .engine_credibilite_appliquee(5, bareme, segment, annexe); NULL },
                  error = function(e) conditionMessage(e))
  if (!is.null(msg)) err <- c(err, msg)
  if (!length(err)) {
    r <- yt / xt
    # Plage plausible (issue #145) : conventions RATIO_PLAUSIBLE_MIN et
    # RATIO_PLAUSIBLE_MAX, communes a la ligne A de usp_controle_donnees().
    if (any(r < RATIO_PLAUSIBLE_MIN | r >= RATIO_PLAUSIBLE_MAX))
      avt <- c(avt, sprintf("Ratio y/x hors de la plage plausible [%g ; %g[ : verifier les unites.",
                            RATIO_PLAUSIBLE_MIN, RATIO_PLAUSIBLE_MAX))
    if (max(xt) / min(xt) >= 10)
      avt <- c(avt, "Amplitude des volumes >= 10 : rupture de perimetre possible.")
    if (anyDuplicated(data.frame(xt, yt)) > 0)
      avt <- c(avt, "Couples (xt, yt) dupliques detectes.")
    # Credibilite partielle (issue #131) : c(T, bareme applique) < 1, sous
    # le bareme qui entre dans sigma_USP ; length(xt) < 10 ne signalait rien
    # sur les segments du bareme long G(1) de T = 10 a 14.
    if (length(xt) >= 5) {
      cr <- .engine_credibilite_appliquee(length(xt), bareme, segment, annexe)
      if (!cr$pleine)
        avt <- c(avt, sprintf("T = %d : credibilite partielle, c = %.0f%% (%s ; pleine a partir de T = %d).",
                              length(xt), 100 * cr$c, cr$libelle, cr$pleine_a))
    }
    # Repere statistique, non reglementaire, seuil inchange (T < 10).
    if (length(xt) < 10)
      avt <- c(avt, sprintf(paste("T = %d : lois asymptotiques peu fiables.",
                                  "Privilegier les p-values exactes ou Monte-Carlo."),
                            length(xt)))
  }
  list(ok = length(err) == 0, erreurs = err, avertissements = avt, T = length(xt))
}

# Profondeur T demandee (issue #87) : les T annees les plus recentes d'une
# serie de n annees. NULL : toute la serie, aucune erreur. Sinon, un nombre
# entier scalaire fini, T_min <= T <= n, est exige (annexe XVII,
# B/C(2)(b) : au moins 5 annees) ; une valeur non numerique, vide, multiple,
# NA, infinie ou non entiere est refusee, faute de quoi l'indice
# (n - T + 1):n tronquait la serie en silence (T = 5.5 : 3.5:8, soit les
# annees 3 a 7). Retourne les motifs de refus (character(0) si T convient),
# sans erreur R. T_min = 1 pour un simple chargement (usp_charger()), la
# duree minimale y etant controlee plus tard par engine_valider_donnees().
# n est le nombre d'annees FOURNIES : les annees "disponibles" au sens de
# l'annexe XVII (sections B/C, paragraphe 3, et G, paragraphe 3) sont les T
# annees retenues (lecture (A) de l'issue #104, decision du mainteneur du
# 28/09/2026).
engine_valider_profondeur <- function(T, n, T_min = 5) {
  if (is.null(T)) return(character(0))
  # L'annexe XVII n'est citee que si la borne est la sienne (T_min >= 5) ;
  # pour un simple chargement (T_min = 1), les motifs sont neutres.
  source_T <- if (T_min >= 5) " (annexe XVII, B/C(2)(b))" else ""
  # T refuse cite par .engine_saisie() (issue #180) : deparse() a 15
  # chiffres citait 8 + 1.8e-15, refuse comme non entier, "T = 8".
  if (!is.numeric(T) || length(T) != 1L || !is.finite(T) || T != round(T))
    return(sprintf("Profondeur T = %s : un nombre entier d'annees est attendu%s ; la serie n'est pas tronquee.",
                   .engine_saisie(T), source_T))
  if (T > n)
    return(sprintf("Profondeur T = %s superieure au nombre d'annees fournies (%d).",
                   format(T), n))
  if (T < T_min)
    return(if (T_min >= 5)
      sprintf("Annexe XVII, B/C(2)(b) : au moins %d annees consecutives (T = %s).",
              T_min, format(T))
      else sprintf("Profondeur T = %s : T >= %d attendu.", format(T), T_min))
  character(0)
}

# Serie retenue et sa validation (issue #131) : etape 1 de run_engine()
# (methodes lognormales), extraite telle quelle pour que l'apercu de
# l'application valide la meme serie que le calcul, sans refaire la
# troncature. Profondeur T (issue #87) controlee AVANT toute troncature :
# une valeur non entiere, NA, non finie, multiple ou hors de [5 ; n] est
# refusee (ok = FALSE) ; elle etait auparavant ignoree (NA, Inf, texte) ou
# tronquait la serie en silence ((n - 5.5 + 1):n = 3.5:8 retient 5 annees
# et ecarte la plus recente). Refusee, la serie n'est pas tronquee et la
# validation des donnees porte sur la serie entiere. T accepte : les T
# annees les plus recentes (lecture (A) de #104 : la duree G(3) est le T
# retenu). Les autres arguments sont ceux de engine_valider_donnees().
# Retourne list(xt, yt, validation) : la serie retenue et sa validation.
engine_valider_serie_retenue <- function(xt, yt, T = NULL, theta_equiv = 0.10,
                                         delta_equiv = NULL, methode = NULL,
                                         nature_donnees = NULL, bareme = NULL,
                                         segment = NULL, annexe = "II") {
  n <- length(xt)
  err_T <- engine_valider_profondeur(T, n)
  if (!is.null(T) && !length(err_T)) {
    idx <- (n - T + 1):n; xt <- xt[idx]; yt <- yt[idx]
  }
  # Bareme saisi transmis tel quel (NULL sinon), avec le segment et l'annexe :
  # l'avertissement de credibilite partielle lit le bareme applique (#131).
  validation <- engine_valider_donnees(xt, yt, theta_equiv = theta_equiv,
                                       delta_equiv = delta_equiv, methode = methode,
                                       nature_donnees = nature_donnees, bareme = bareme,
                                       segment = segment, annexe = annexe)
  # T refuse : aucune serie n'est retenue ; les avertissements, qui portent
  # sur une serie retenue (longueur, ratios, amplitude), sont retires et la
  # longueur retenue validation$T vaut NA (audit de #87, constat 4).
  if (length(err_T)) {
    validation$ok <- FALSE
    validation$erreurs <- c(err_T, validation$erreurs)
    validation$avertissements <- character(0)
    validation$T <- NA_integer_
  }
  list(xt = xt, yt = yt, validation = validation)
}


## =============================================================================
## 9. QUANTITES NUMERIQUES DES GRAPHIQUES
## =============================================================================

# Toutes les quantites tracees sont calculees ICI. La couche d'affichage ne fait
# que les representer (choix des couleurs, titres, axes).

# Reperes de LECTURE des graphiques d'influence (issue #4, piste 3 ; valeurs
# jusqu'ici ecrites en dur dans l'affichage, conservees telles quelles). Le
# moteur en tire les booleens de coloration fort_ecart_sigma
# (engine_influence()) et fort_dfbeta (mw_influence()), que display_helpers.R
# lit sans comparaison (issue #33, constat C1 d'app-review). Ce ne sont ni des seuils
# reglementaires ni des niveaux de test ; aucun verdict n'en depend.
# - REPERE_INFLUENCE_SIGMA : |ecart relatif de sigma_USP| au retrait d'une
#   annee (jackknife) ; renvoie au repere conventionnel de 10 % de la fiche
#   jackknife, qui cite 10 % et 20 % : seul 10 % sert ici, a la couleur.
# - REPERE_DFBETA_MW : |variation relative de f_j| au retrait d'une cellule
#   du triangle (DFBETA de mw_influence()). Repere de lecture propre a
#   l'outil, herite de l'affichage, sans source, sans fondement statistique
#   ni reglementaire ; il ne produit aucun verdict et n'est pas le repere
#   2/sqrt(n) de Belsley-Kuh-Welsch, qui porte sur un DFBETAS standardise et
#   non sur une variation relative (issue #89).
REPERE_INFLUENCE_SIGMA <- 0.10
REPERE_DFBETA_MW <- 0.02
# Surface de la fonction objectif sur une grille (delta, gamma). Elle sert a
# visualiser la geometrie de l'optimisation, notamment lorsque delta est au
# bord : un plateau plat en delta signifie que la structure de variance n'est
# pas identifiee par les donnees, ce que le seul profil ne montre pas toujours.
engine_surface_objectif <- function(fit, n_delta = 45, n_gamma = 45,
                                    marge_gamma = 1.6) {
  gd <- seq(0, 1, length.out = n_delta)
  gg <- seq(fit$gamma - marge_gamma, fit$gamma + marge_gamma, length.out = n_gamma)
  M <- outer(gd, gg, Vectorize(function(d, g)
    usp_objectif(c(d, g), fit$x, fit$y, fit$xbar)))
  list(delta = gd, gamma = gg, objectif = M,
       delta_opt = fit$delta, gamma_opt = fit$gamma, objectif_opt = fit$obj_min,
       au_bord = isTRUE(fit$delta_au_bord),
       # Amplitude relative de l'objectif le long de delta, a gamma optimal :
       # mesure quantitative de la platitude (identifiabilite de delta).
       amplitude_delta = {
         v <- vapply(gd, function(d) usp_objectif(c(d, fit$gamma), fit$x, fit$y,
                                                  fit$xbar), numeric(1))
         diff(range(v))
       })
}

# --- Diagnostics d'influence de la regression (methode lognormale) -----------
# La regression de reference est le modele reglementaire contraint
# y_t = beta x_t (sans constante), a k = 1 parametre. Pour ce modele :
#   levier      h_t = x_t^2 / somme(x_i^2)        (somme des h_t = k = 1)
#   residu standardise  e_t / (s sqrt(1 - h_t))
#   distance de Cook    D_t = r_t^2 * h_t / (k (1 - h_t))
# On y ajoute la mesure d'influence la plus parlante pour le dossier :
# l'effet du retrait de chaque annee sur le parametre final sigma_USP, deja
# calcule par le jackknife.
# Le modele est ajuste sur x et y mis a l'echelle exacte
# (.usp_echelle_exacte(), #153) : levier, residu standardise et distance de
# Cook sont invariants par x -> a x, y -> b y, identiques au bit pres a ceux
# du calcul sur x et y bruts dans le domaine (mesure #153 : resultat
# identical() avant et apres sur les donnees de test et le jeu de l'issue)
# et egaux a ceux de la ligne Cook de usp_tests() ; sans elle,
# lm.influence() levait une erreur R sur des entrees sous-normales (x et y
# x 1e-320, 5e-324) et D_t etait non fini a petite echelle. Les colonnes x
# et y du resultat restent les donnees brutes.
engine_influence <- function(fit, jackknife = NULL, sigma_usp = NULL) {
  x <- fit$x; y <- fit$y; T <- fit$T
  xe <- .usp_echelle_exacte(x); ye <- .usp_echelle_exacte(y)
  m <- stats::lm(ye ~ xe - 1)
  k <- 1L
  h <- stats::hatvalues(m)
  e <- stats::residuals(m)
  s <- sqrt(sum(e^2) / (T - k))
  r_std <- e / (s * sqrt(pmax(1 - h, .Machine$double.eps)))
  cook <- stats::cooks.distance(m)
  d <- data.frame(
    t = seq_len(T), x = x, y = y,
    levier = unname(h), residu_std = unname(r_std), cook = unname(cook),
    z = fit$z,
    seuil_levier = 2 * k / T, seuil_cook = 4 / T,
    stringsAsFactors = FALSE)
  d$influent <- d$cook > d$seuil_cook
  d$fort_levier <- d$levier > d$seuil_levier
  if (!is.null(jackknife) && !is.null(sigma_usp)) {
    d$sigma_usp_sans_t <- jackknife$sigma_usp
    d$ecart_sigma <- (jackknife$sigma_usp - sigma_usp) / sigma_usp
    # Coloration du graphique d'influence sur sigma_USP (plot_influence_sigma()) :
    # |ecart relatif| au-dela du repere de lecture REPERE_INFLUENCE_SIGMA,
    # calcule ici comme fort_levier (issue #33, constat C1 d'app-review).
    d$fort_ecart_sigma <- abs(d$ecart_sigma) > REPERE_INFLUENCE_SIGMA
  }
  d
}

# Courbes d'iso-distance de Cook, tracees dans le plan (levier, residu
# standardise). Pour un niveau D fixe : r = +/- sqrt(D k (1 - h) / h).
engine_contours_cook <- function(T, k = 1L, niveaux = c(0.5, 1), n = 200) {
  hmax <- 0.99
  h <- seq(0.005, hmax, length.out = n)
  do.call(base::rbind, lapply(niveaux, function(D) {
    r <- sqrt(D * k * (1 - h) / h)
    rbind(data.frame(niveau = D, signe = "+", levier = h, residu = r),
          data.frame(niveau = D, signe = "-", levier = h, residu = -r))
  }))
}

# Enveloppe de simulation du QQ-plot (issue #47 ; note d'actuary du
# 28/09/2026, par. 2, option A, decisions du mainteneur du 28/09/2026).
# Construction d'Atkinson (1981) : bootstrap parametrique sous le modele
# ajuste, chaque echantillon simule etant reestime ; les z* sont les residus
# reajustes de usp_bootstrap() (champ z_boot, B x T, lignes NA pour les
# replications ecartees). S = statistiques d'ordre des B_eff lignes
# entierement finies.
#  - bande ponctuelle : quantiles 5 % et 95 % (type 7) de chaque colonne de S ;
#  - bande simultanee (Davison et Hinkley 1997, enveloppe globale de
#    boot::envelope()) : bande des k-iemes plus petite et plus grande valeurs
#    de chaque colonne de S ; k* = plus grand k tel que la proportion de
#    lignes de S ayant au moins une valeur STRICTEMENT hors de la bande soit
#    <= ENVELOPPE_QQ_TAUX_MAX. Les bandes sont emboitees (celle de k + 1
#    est dans celle de k), la proportion croit avec k : le balayage s'arrete
#    au premier k qui depasse le seuil.
# Niveau fixe de 90 % pour les deux bandes, sans lien avec alpha (decision
# Q3) ; probabilites et taux ecrits en litteraux (1 - 0.90 n'est pas 0.10 en
# virgule flottante). B_eff = nombre de lignes entierement finies de z_boot
# = nombre de replications retenues. Degenerescence : B_eff <
# ENVELOPPE_QQ_B_MIN -> quatre bandes NA et k NA ; B_eff <
# ENVELOPPE_QQ_B_MIN_SIM -> bande ponctuelle seule, simultanee NA et k NA.
# Seuil de 500 (decision d'actuary du 29/09/2026), fonde sur la granularite
# de k et non sur la calibration : sous 500 replications, k* <= 4 et la bande
# simultanee n'est que celle des 1 a 4 valeurs extremes de chaque colonne (a
# B_eff = 100, k* = 1 : bande [min, max], taux auto-evalue nul par
# construction). Mesures sur J1 (tests/donnees/donnees_ln.csv), 8 graines par
# taille (1001 a 1008), taux hors echantillon evalue sur un bootstrap
# independant de B = 8000 (graine 424242), meme algorithme que ci-dessous :
#   B_eff  k*   taux auto-evalue   taux hors echantillon (min-max, moyenne)
#   100    1    0                  9 a 18 %   (12,5 %)
#   200    2    5,5 a 7,5 %        9 a 15 %   (12,3 %)
#   300    3    7,7 a 9,3 %        10 a 15 %  (12,5 %)
#   400    3-4  7,3 a 10 %         11 a 15 %  (12,4 %)
#   500    4-5  8 a 9,8 %          9 a 14 %   (11,8 %)
#   1000   8-9  9 a 9,9 %          10 a 12 %  (10,6 %)
# Le taux auto-evalue est optimiste (bande calibree sur les replications qui
# la construisent) : 2,7 points en moyenne a B_eff = 500, 1 point a 1000. Le
# niveau reel de la bande simultanee est donc voisin de 88 % a B_eff = 500 et
# de 89 % au defaut B = 999, pour 90 % nominal ; la bande ponctuelle n'est pas
# concernee. Ces valeurs sont des mesures par simulation sur un seul jeu,
# pas un resultat general. Les taux (taux_global_ponctuel,
# taux_global_simultane) sont evalues sur les
# replications memes qui construisent les bandes (taux in-sample).
# Le cas "aucun k >= 1 admissible" est inatteignable : k = 1 toujours
# admissible, taux 0 par construction (a k = 1 la bande est [min, max] de
# chaque colonne, dont aucune ligne ne sort strictement) ; le if sur
# k_etoile ne sert que de garde. Sous refit = FALSE (appel direct de
# usp_bootstrap(), hors run_engine()), les z* sont des residus a parametres
# fixes et l'enveloppe n'est pas celle d'Atkinson. Aucune p-value ni verdict
# (aide graphique, ADR 0001). Rend list(bandes = matrice T x 4 dans l'ordre
# des statistiques d'ordre (colonnes bas, haut, sim_bas, sim_haut), info =
# description reprise dans plots_data$qq_enveloppe, dont le seuil
# B_min_simultane lu par l'affichage).
ENVELOPPE_QQ_NIVEAU <- 0.90
ENVELOPPE_QQ_PROBS <- c(0.05, 0.95)
ENVELOPPE_QQ_TAUX_MAX <- 0.10
ENVELOPPE_QQ_B_MIN <- 20L
ENVELOPPE_QQ_B_MIN_SIM <- 500L
engine_enveloppe_qq <- function(z_boot, T) {
  bandes <- matrix(NA_real_, T, 4L,
                   dimnames = list(NULL, c("bas", "haut", "sim_bas", "sim_haut")))
  garde <- if (is.null(z_boot)) logical(0) else apply(is.finite(z_boot), 1L, all)
  B_eff <- sum(garde)
  info <- list(source = "bootstrap", B_eff = B_eff,
               niveau_ponctuel = ENVELOPPE_QQ_NIVEAU,
               niveau_simultane = ENVELOPPE_QQ_NIVEAU,
               k = NA_integer_, taux_global_ponctuel = NA_real_,
               taux_global_simultane = NA_real_,
               B_min_simultane = ENVELOPPE_QQ_B_MIN_SIM)
  if (B_eff < ENVELOPPE_QQ_B_MIN) return(list(bandes = bandes, info = info))
  S <- t(apply(z_boot[garde, , drop = FALSE], 1L, sort))
  # Proportion des lignes de S ayant au moins une valeur strictement hors de
  # la bande [bas, haut] (bornes par colonne).
  taux_hors <- function(bas, haut)
    mean(rowSums(S < rep(bas, each = B_eff) | S > rep(haut, each = B_eff)) > 0)
  q <- apply(S, 2L, stats::quantile, probs = ENVELOPPE_QQ_PROBS, type = 7, names = FALSE)
  bandes[, "bas"] <- q[1L, ]; bandes[, "haut"] <- q[2L, ]
  info$taux_global_ponctuel <- taux_hors(q[1L, ], q[2L, ])
  if (B_eff < ENVELOPPE_QQ_B_MIN_SIM) return(list(bandes = bandes, info = info))
  Sc <- apply(S, 2L, sort)
  k_etoile <- NA_integer_; taux_k <- NA_real_
  for (k in seq_len(B_eff %/% 2L)) {
    tk <- taux_hors(Sc[k, ], Sc[B_eff + 1L - k, ])
    if (tk > ENVELOPPE_QQ_TAUX_MAX) break
    k_etoile <- k; taux_k <- tk
  }
  # Garde inatteignable : k = 1 toujours admissible, taux 0 par construction.
  if (!is.na(k_etoile)) {
    bandes[, "sim_bas"] <- Sc[k_etoile, ]
    bandes[, "sim_haut"] <- Sc[B_eff + 1L - k_etoile, ]
    info$k <- k_etoile; info$taux_global_simultane <- taux_k
  }
  list(bandes = bandes, info = info)
}

engine_plots_data <- function(fit, boot, profil, jackknife = NULL,
                              sigma_usp = NULL, lr_delta = NULL) {
  T <- fit$T; x <- fit$x; z <- fit$z
  qq <- stats::qqnorm(z, plot.it = FALSE)
  # Droite de reference du QQ-plot (quartiles), comme stats::qqline
  qy <- stats::quantile(z, c(0.25, 0.75)); qx <- stats::qnorm(c(0.25, 0.75))
  pente_qq <- diff(qy) / diff(qx); ord_qq <- qy[1] - pente_qq * qx[1]

  # Enveloppe de simulation du QQ-plot (issue #47) : lue dans les residus
  # reajustes du bootstrap parametrique (boot$z_boot), sans nouveau tirage.
  env <- engine_enveloppe_qq(boot$z_boot, T)
  o_qq <- order(order(qq$x))

  # QQ-plot a deux echantillons (faible vs fort volume)
  qq2 <- NULL
  # Partition par le volume : sans objet a volumes constants (#59).
  if (!usp_volumes_constants(x)) {
    g <- x > stats::median(x)
    if (sum(g) >= 3 && sum(!g) >= 3) {
      nn <- min(sum(g), sum(!g)); pr <- stats::ppoints(nn)
      qq2 <- data.frame(faible = stats::quantile(sort(z[!g]), pr, type = 7),
                        fort   = stats::quantile(sort(z[g]),  pr, type = 7))
    }
  }
  lo <- stats::lowess(x, sqrt(abs(z)))
  pd <- list(
    ajustement = data.frame(x = x, y = fit$y, ajuste = fit$beta * x),
    beta = fit$beta,
    ratio = data.frame(t = seq_len(T), ratio = fit$y / x, niveau = fit$beta),
    qqnorm = data.frame(theorique = qq$x, empirique = qq$y,
                        env_bas = env$bandes[o_qq, "bas"],
                        env_haut = env$bandes[o_qq, "haut"],
                        env_sim_bas = env$bandes[o_qq, "sim_bas"],
                        env_sim_haut = env$bandes[o_qq, "sim_haut"]),
    qqline = c(ordonnee = unname(ord_qq), pente = unname(pente_qq)),
    qq2ech = qq2,
    spread = data.frame(x = x, racine_abs_z = sqrt(abs(z))),
    spread_lisse = data.frame(x = lo$x, y = lo$y),
    residus = data.frame(x = x, z = z, t = seq_len(T)),
    profil_delta = data.frame(delta = profil$delta_grid, objectif = profil$delta_obj),
    profil_gamma = data.frame(gamma = profil$gamma_grid, objectif = profil$gamma_obj),
    surface = engine_surface_objectif(fit),
    influence = engine_influence(fit, jackknife, sigma_usp),
    contours_cook = engine_contours_cook(T),
    delta_estime = fit$delta, gamma_estime = fit$gamma,
    sigma_boot = boot$sigma_boot, delta_boot = boot$delta_boot
  )
  # Graphiques d'influence (#153), sur le modele de .usp_ligne_cook() : un
  # residu standardise ou une distance de Cook non fini (cas vise : y
  # exactement proportionnel a x, residus de y = beta x tous nuls, s = 0,
  # residu_std et D_t = 0/0 = NaN sur les T annees, mesure pour x en
  # puissances de 2, jeu des tests ; pour un x quelconque, D_t fini issu du
  # bruit d'arrondi, serie exactement proportionnelle : voir #188 ; issue
  # dependant de la plateforme et de x, mesures et issues possibles : voir
  # .usp_ligne_cook()) rend
  # les graphiques residus vs levier et Cook par annee sans objet ; le motif
  # est expose ici, l'affichage ne fait que le lire. Champ absent si tout est
  # fini (aucun effet sur les resultats ordinaires), place avant lr_delta et
  # qq_enveloppe, qui restent en fin de liste.
  if (!all(is.finite(pd$influence$residu_std)) || !all(is.finite(pd$influence$cook)))
    pd$influence_motif <- paste("Residu standardise ou distance de Cook non fini (par exemple",
                                "residus de y = beta x tous nuls) : graphique non disponible")
  # Reperes du rapport de vraisemblance sur delta (issue #45, decision Q3 du
  # 28/09/2026), en fin de liste, pour plot_profil_delta() seul (decision
  # Q5 : aucun repere sur plot_coupe_delta()) : repere asymptotique
  # obj_min + qchisq(0,80 ; 1), soit
  # le quantile a 90 % du melange 1/2 chi2(0) + 1/2 chi2(1) (aide de
  # lecture), et quantile a 90 % (type 7) du LR simule sous chaque borne par
  # le bootstrap restreint (NA sans replication finie).
  if (!is.null(lr_delta)) {
    q90 <- function(v) if (length(v))
      unname(stats::quantile(v, 0.90, type = 7)) else NA_real_
    pd$lr_delta <- list(
      obj_min = fit$obj_min,
      seuil_asymptotique = fit$obj_min + stats::qchisq(0.80, 1),
      q90_bootstrap = c(delta0 = fit$obj_min + q90(lr_delta$borne0$lr_boot),
                        delta1 = fit$obj_min + q90(lr_delta$borne1$lr_boot)),
      lr = c(delta0 = lr_delta$borne0$lr, delta1 = lr_delta$borne1$lr))
  }
  # Description de l'enveloppe du QQ-plot (issue #47), en fin de liste :
  # nombres calcules cites par l'aide et le rapport.
  pd$qq_enveloppe <- env$info
  pd
}


## =============================================================================
## 10. METHODE DU RISQUE DE RESERVE No 2 (MERZ-WUTHRICH)
##     Reglement delegue (UE) 2015/35, annexe XVII, section D.
##     Paragraphes 1 a 4 : transcription litterale ; leur texte et leurs
##     formules sont identiques dans la version d'origine (JOUE L 12 du
##     17.1.2015, p. 276-277) et dans la version consolidee au 14.11.2024
##     (aucune marque de modification dans la section D ; comparaison des
##     formules en rendu graphique le 22/09/2026).
##     Paragraphe 5 (MSEP, mw_msep()) : transcription de la VERSION CONSOLIDEE
##     en vigueur (EUR-Lex, CELEX 32015R0035, consolidee au 14.11.2024), qui
##     n'a pas de pagination au JOUE ; la formule d'origine (JOUE
##     L 12/277-278) en differe (ADR 0005).
##
##     NOTATION DU REGLEMENT (section D, paragraphe 3)
##       i = 0, ..., I : annees d'accident (0 = la plus ancienne)
##       j = 0, ..., J : annees de developpement
##       C(i,j)        : sinistres cumules
##     Le triangle est stocke dans une matrice (I+1) x (J+1), les cellules non
##     observees (i + j > I) valant NA.
##
##     RESTRICTION D'IMPLEMENTATION : on impose I = J (triangle carre). Le
##     paragraphe 2(e) autorise I >= J, mais la formule du paragraphe 4 fait
##     intervenir C(i, I-i), qui n'est definie que si I - i <= J. Le cas I > J
##     produirait un trapeze dont le texte ne precise pas le traitement ; il est
##     donc refuse explicitement plutot que traite par convention implicite.
## =============================================================================

# --- Controles de recevabilite : annexe XVII, section D, paragraphe 2 --------
# bareme / segment / annexe (issue #131) : bareme de credibilite applique,
# resolu comme dans run_engine() (.engine_credibilite_appliquee()) ; une
# valeur invalide est une erreur bloquante, sans erreur R. L'avertissement de
# credibilite partielle repose sur c(I + 1, bareme applique) < 1 (annexe
# XVII, section G ; duree G(3)(c)) ; l'avertissement statistique (variance
# tres bruitee en fin de triangle, I + 1 < 10) est un repere non
# reglementaire, distinct et inchange.
# Domaine numerique (issue #185) : une cellule observee hors de
# [DOMAINE_NUMERIQUE_MIN ; DOMAINE_NUMERIQUE_MAX], bornes incluses, est
# refusee (constantes de #145). Sans ce refus, run_engine() rendait ok = TRUE
# sans alerte avec un sigma_USP faux sous une echelle d'environ 1e-105
# (mesures de l'issue #185 ; bornes de l'ordre de DBL_MIN^(1/3) et
# DBL_MAX^(1/3), grandeurs de degre 3).
mw_valider_triangle <- function(tri, T_min = 5, bareme = NULL, segment = NULL,
                                annexe = "II") {
  err <- character(0); avt <- character(0)
  if (!is.matrix(tri) || !is.numeric(tri))
    return(list(ok = FALSE, erreurs = "Le triangle doit etre une matrice numerique.",
                I = NA, J = NA))
  I <- nrow(tri) - 1L; J <- ncol(tri) - 1L
  if (nrow(tri) < T_min)
    err <- c(err, sprintf("D(2)(b) : au moins %d annees d'accident consecutives (%d fournies).",
                          T_min, nrow(tri)))
  if (ncol(tri) < T_min)
    err <- c(err, sprintf("D(2)(c) : au moins %d annees de developpement pour la premiere annee d'accident (%d fournies).",
                          T_min, ncol(tri)))
  if (nrow(tri) < ncol(tri))
    err <- c(err, "D(2)(e) : le nombre d'annees d'accident ne peut etre inferieur au nombre d'annees de developpement.")
  if (I != J)
    err <- c(err, sprintf("Triangle non carre (I = %d, J = %d) : cas non couvert par la formule du paragraphe 4 (voir la note d'implementation).", I, J))
  if (!length(err)) {
    # Cellules observees finies strictement positives hors du domaine
    # numerique (issue #185), relevees dans la boucle, signalees apres elle.
    hors_i <- integer(0); hors_j <- integer(0)
    # Structure attendue : partie superieure gauche observee, reste manquant.
    for (i in 0:I) for (j in 0:J) {
      obs <- (i + j <= I)
      v <- tri[i + 1, j + 1]
      # Manquante (NA) et non finie (Inf, -Inf lus depuis un texte ; NaN fourni
      # dans une matrice numerique) sont deux motifs distincts (issue #33) :
      # "Inf" n'est pas une cellule vide.
      if (obs && is.na(v) && !is.nan(v))
        err <- c(err, sprintf("Cellule observee manquante en (i=%d, j=%d).", i, j))
      else if (obs && !is.finite(v))
        err <- c(err, sprintf("Valeur non finie en (i=%d, j=%d) : %s.", i, j, format(v)))
      if (obs && is.finite(v) && v <= 0)
        err <- c(err, sprintf("Cumul non strictement positif en (i=%d, j=%d).", i, j))
      # Domaine numerique (issue #185) : memes constantes et memes bornes
      # incluses que engine_valider_donnees() (#145). NA, non finies et non
      # positives sont refusees ci-dessus, sans doublon.
      if (obs && is.finite(v) && v > 0 &&
          (v < DOMAINE_NUMERIQUE_MIN || v > DOMAINE_NUMERIQUE_MAX)) {
        hors_i <- c(hors_i, i); hors_j <- c(hors_j, j)
      }
    }
    # Un seul motif par triangle, qui cite la premiere cellule fautive (ordre
    # i puis j), sa valeur (.engine_saisie(), 17 chiffres si necessaire), la
    # borne franchie et le nombre de cellules hors du domaine : un triangle a
    # une echelle extreme a toutes ses cellules hors du domaine, et un motif
    # par cellule repeterait le meme refus (comme engine_valider_donnees(),
    # un motif par serie).
    if (length(hors_i)) {
      v1 <- tri[hors_i[1] + 1, hors_j[1] + 1]
      borne <- if (v1 < DOMAINE_NUMERIQUE_MIN)
        sprintf("< %g, borne inferieure", DOMAINE_NUMERIQUE_MIN)
        else sprintf("> %g, borne superieure", DOMAINE_NUMERIQUE_MAX)
      err <- c(err, sprintf(paste(
        "Cumul hors du domaine numerique [%g ; %g] en (i=%d, j=%d) : %s (%s)%s.",
        "sigma_USP et les tests sont invariants par un changement d'unite commun",
        "a toutes les cellules du triangle : exprimer les cumuls dans une unite",
        "qui les ramene dans le domaine."),
        DOMAINE_NUMERIQUE_MIN, DOMAINE_NUMERIQUE_MAX, hors_i[1], hors_j[1],
        .engine_saisie(unname(v1)), borne,
        if (length(hors_i) > 1L)
          sprintf(" ; %d cellules observees hors du domaine", length(hors_i)) else ""))
    }
  }
  # Bareme, segment et annexe (issue #131) : controles apres les erreurs de
  # donnees, qu'ils ne masquent pas (comme dans engine_valider_donnees()), et
  # avant tout avertissement ; une valeur invalide est refusee sans erreur R.
  msg <- tryCatch({ .engine_credibilite_appliquee(5, bareme, segment, annexe); NULL },
                  error = function(e) conditionMessage(e))
  if (!is.null(msg)) err <- c(err, msg)
  if (!length(err)) {
    # Avertissement de nature ACTUARIELLE, sans fondement reglementaire : le
    # paragraphe 2(h)(iii) pose seulement que l'esperance du cumule d'une annee
    # de developpement est PROPORTIONNELLE a celle de la precedente, et ne
    # contraint pas le facteur f_j a etre >= 1. Le texte ne dit donc rien des
    # cumules decroissants. Un recul traduit un boni de liquidation ou un
    # recouvrement, licite : on le signale sans refuser.
    for (i in 0:I) {
      d <- I - i
      if (d >= 1) {
        v <- tri[i + 1, 1:(d + 1)]
        if (any(diff(v) < 0))
          avt <- c(avt, sprintf("Annee d'accident %d : cumul decroissant (recouvrement ou boni).", i))
      }
    }
    # Credibilite partielle (issue #131) : c(I + 1, bareme applique) < 1 ;
    # nrow(tri) < 10 ne signalait rien sur les segments du bareme long G(1)
    # de I + 1 = 10 a 14.
    if (nrow(tri) >= 5) {
      cr <- .engine_credibilite_appliquee(nrow(tri), bareme, segment, annexe)
      if (!cr$pleine)
        avt <- c(avt, sprintf(paste("I + 1 = %d annees d'accident (duree, G(3)(c)) : credibilite",
                                    "partielle, c = %.0f%% (%s ; pleine a partir de I + 1 = %d)."),
                              nrow(tri), 100 * cr$c, cr$libelle, cr$pleine_a))
    }
    # Repere statistique, non reglementaire, seuil inchange (I + 1 < 10).
    if (nrow(tri) < 10)
      avt <- c(avt, sprintf("I + 1 = %d annees d'accident : estimateurs de variance tres bruites en fin de triangle.",
                            nrow(tri)))
  }
  list(ok = length(err) == 0, erreurs = err, avertissements = avt, I = I, J = J)
}

# --- Facteurs de developpement et variances : paragraphes 4 et 5 -------------
# Renvoie f_chapeau, sigma2_chapeau, Q_chapeau, S, S', les cumules estimes
# C_chapeau et la reserve par annee d'accident.
mw_ajuster <- function(tri) {
  I <- nrow(tri) - 1L; J <- ncol(tri) - 1L

  # f_j = somme_{i=0}^{I-j-1} C(i,j+1) / somme_{i=0}^{I-j-1} C(i,j)   [par. 4(c)]
  f <- rep(NA_real_, J)                       # f[j+1] correspond a f_j
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    f[j + 1] <- sum(tri[idx + 1, j + 2]) / sum(tri[idx + 1, j + 1])
  }

  # sigma2_j, j = 0..J-2  [par. 5(d)(ii), premiere ligne]
  s2 <- rep(NA_real_, J)                      # s2[j+1] correspond a sigma2_j
  if (J >= 2) for (j in 0:(J - 2)) {
    idx <- 0:(I - j - 1)
    if (length(idx) >= 2)
      s2[j + 1] <- sum(tri[idx + 1, j + 1] *
                       (tri[idx + 1, j + 2] / tri[idx + 1, j + 1] - f[j + 1])^2) / (I - j - 1)
  }
  # sigma2_{J-1} = min(sigma2_{J-2}, sigma2_{J-3}, sigma2_{J-2}^2 / sigma2_{J-3})
  # [par. 5(d)(ii), seconde ligne]. Le sigma^4 du texte designe le carre de
  # sigma2_{J-2}, la formule etant l'extrapolation geometrique usuelle.
  #
  # CAS sigma2_{J-3} = 0 (colonne J-3 a facteurs individuels exactement egaux ;
  # une colonne degeneree au sens de .mw_colonne_degeneree() donne un
  # sigma2_{J-3} nul ou negligeable a la tolerance de l'outil). Le
  # troisieme argument divise alors par zero, mais la regle du texte reste
  # DETERMINEE et vaut 0 : par la premiere ligne de (d)(ii), sigma2_j est une
  # somme de carres ponderee par des C(i,j) > 0, donc les trois arguments sont
  # positifs ou nuls et le quotient est dans [0, +Inf] ; comme le DEUXIEME
  # argument vaut deja 0, le minimum est atteint en sigma2_{J-3} quelle que
  # soit la valeur donnee au quotient. L'indetermination arithmetique est sans
  # effet sur le minimum. Aucune clause de cas degenere ne figure ni a
  # l'annexe XVII ni aux articles 218-220 (a contrario : l'annexe XVIII ecrit
  # explicitement "d1 est egal a 1 lorsque SS ou SC est egal a zero"), et la
  # regle litterale est CONTINUE en zero -- pour b -> 0+, min(a, b, a^2/b)
  # tend vers 0. Le repli sur sigma2_{J-2} pratique auparavant n'etait pas
  # prescrit, retenait une valeur SUPERIEURE a la borne sigma2_{J-3} = 0
  # imposee par le texte, et introduisait une discontinuite (deux triangles
  # indiscernables a 1e-8 pres donnaient des sigma_USP ecartes de plusieurs
  # dizaines de pour cent). Voir l'issue #7 et mw_extrapolation_sigma2().
  #
  # Ecriture : on evalue le quotient seulement quand il est defini, en lui
  # substituant sinon +Inf (sa limite quand sigma2_{J-3} -> 0+ a sigma2_{J-2}
  # fixe non nul) ; le minimum litteral s'applique alors sans branche speciale
  # et donne 0 de lui-meme. Le cas symetrique sigma2_{J-2} = 0 avec
  # sigma2_{J-3} > 0 passe par la meme expression (quotient nul) et donne 0.
  if (J >= 3 && is.finite(s2[J - 1]) && is.finite(s2[J - 2])) {
    quotient <- if (s2[J - 2] > 0) s2[J - 1]^2 / s2[J - 2] else Inf
    s2[J] <- min(s2[J - 1], s2[J - 2], quotient)
  } else if (J >= 2 && is.finite(s2[J - 1])) {
    # Seul cas restant : J < 3 (sigma2_{J-3} n'existe pas) ou sigma2 non fini.
    # Le texte ne couvre pas J < 3 ; run_engine() ne peut pas l'atteindre
    # (mw_valider_triangle impose T >= 5 et I = J, donc J >= 4).
    s2[J] <- s2[J - 1]
  }

  # C_chapeau(i,j) : observe si j <= I-i, projete au-dela   [par. 4(c)]
  Ch <- tri
  for (i in 0:I) {
    d <- I - i
    if (d < J) for (j in (d + 1):J)
      Ch[i + 1, j + 1] <- Ch[i + 1, j] * f[j]
  }

  # Q_j = sigma2_j / f_j^2   [par. 5(d)]
  Q <- s2 / f^2
  # S_j = somme_{i=0}^{I-j-1} C(i,j) ;  S'_j = somme_{i=0}^{I-j} C(i,j)
  S <- Sp <- rep(NA_real_, J + 1)
  for (j in 0:J) {
    if (I - j - 1 >= 0) S[j + 1]  <- sum(tri[(0:(I - j - 1)) + 1, j + 1])
    Sp[j + 1] <- sum(tri[(0:(I - j)) + 1, j + 1])
  }

  derniers <- vapply(0:I, function(i) tri[i + 1, I - i + 1], numeric(1))
  ultimes  <- Ch[, J + 1]
  list(I = I, J = J, tri = tri, f = f, sigma2 = s2, Q = Q, S = S, Sp = Sp,
       C_chapeau = Ch, dernier_observe = derniers, ultime = ultimes,
       reserve_par_annee = ultimes - derniers,
       reserve = sum(ultimes - derniers))
}

# --- Colonne de developpement degeneree : predicat unique (issue #56) --------
# Une colonne j est DEGENEREE lorsque ses facteurs individuels
# F(i,j) = C(i,j+1) / C(i,j), i = 0..I-j-1, sont egaux a leur moyenne
# ponderee f_j a la tolerance relative tol de l'outil. Premier volet :
#     max_i |F(i,j) - f_j| / |f_j| <= tol   (tol = 1e-12 par defaut) ;
# second volet ci-dessous (aplatissement des ex aequo).
# C'est la propriete qui annule sigma2_j ; elle est testee sur les facteurs et
# non sur sigma2_j == 0, que l'arrondi rend en general strictement positif
# (voir mw_extrapolation_sigma2()). Le seuil est une convention de
# restitution, pas un seuil statistique (avis d'actuary sur #56) : environ
# 1e4 fois l'epsilon machine, plusieurs ordres de grandeur sous la dispersion
# d'une colonne reelle.
# Second volet du predicat (issue #60, constat C1 de l'audit de #152,
# decision du mainteneur du 05/10/2026) : la colonne est aussi degeneree
# quand ses facteurs, aplatis a tol par engine_aplatir_ex_aequo() en
# plancher 0 (tolerance relative, chainage des valeurs triees adjacentes),
# sont rendus tous egaux, avec un ecart a f_j qui peut depasser tol. Les
# statistiques de rang de M1 et M3 aplatissent les
# F(i,j) a la meme tolerance (#152) : une colonne de facteurs chaines par
# pas de moins de tol en relatif, dont l'ecart a f_j peut atteindre
# (n - 1) * tol, y devient constante (correlation de rang non definie) ; elle
# est donc traitee comme degeneree partout, et non seulement dans ces
# statistiques.
# UNE SEULE DEFINITION dans le moteur : mw_extrapolation_sigma2() (colonnes
# J-3 et J-2), les trois verifications colonne par colonne de M1
# (mw_test_ordonnee_origine(), mw_test_homogeneite_f(), mw_test_courbure()),
# le refus du triangle totalement degenere (#192) et l'exclusion des residus
# de Mack par mw_residus() (#60) appellent ce predicat.
# .mw_ecart_facteurs() rend le nombre de facteurs n, f_j, l'ecart relatif
# maximal (NA si la colonne n'a aucun facteur) et les facteurs F(i,j).
.mw_ecart_facteurs <- function(aj, j) {
  if (aj$I - j - 1 < 0) return(list(n = 0L, f = aj$f[j + 1], ecart = NA_real_,
                                    F = numeric(0)))
  idx <- 0:(aj$I - j - 1)
  Fij <- aj$tri[idx + 1, j + 2] / aj$tri[idx + 1, j + 1]
  list(n = length(idx), f = aj$f[j + 1],
       ecart = max(abs(Fij - aj$f[j + 1])) / abs(aj$f[j + 1]), F = Fij)
}
.mw_colonne_degeneree <- function(aj, j, tol = 1e-12) {
  e <- .mw_ecart_facteurs(aj, j)
  if (!is.finite(e$ecart)) return(FALSE)
  if (e$ecart <= tol) return(TRUE)
  # ecart fini : tous les F(i,j) sont finis (condition de l'aplatissement)
  length(unique(engine_aplatir_ex_aequo(e$F, tol = tol, plancher = 0))) == 1L
}
# Ensemble des colonnes j = 0..J-1 degenerees au sens du predicat ci-dessus
# (vecteur d'entiers, eventuellement vide). mw_bootstrap() le calcule UNE FOIS
# sur le triangle observe et le fige pour toutes les replications (#56).
.mw_colonnes_degenerees <- function(aj, tol = 1e-12) {
  j <- 0:(aj$J - 1L)
  as.integer(j[vapply(j, function(k) .mw_colonne_degeneree(aj, k, tol), logical(1))])
}
# Enonce du predicat dans les messages (issue #60, decision du mainteneur du
# 06/10/2026, constat C1-a de l'audit) : UNE SEULE chaine, reutilisee par
# l'avertissement des colonnes exclues (mw_valider_ajustement()), le motif de
# refus du triangle totalement degenere (#192) et .mw_phrase_exclusion() (M1).
# Elle nomme les deux volets du predicat : un ecart relatif a f_j d'au plus
# 1e-12 ne couvre pas une colonne de facteurs chaines par pas de moins de
# 1e-12, dont l'ecart peut atteindre (n - 1) * 1e-12 et que l'aplatissement
# rend tous egaux.
.MW_PREDICAT_DEGENERE_TEXTE <- paste0(
  "ecart relatif a f_j au plus 1e-12, ou facteurs que l'aplatissement des ",
  "ex aequo a cette tolerance rend tous egaux")
# Triangle totalement degenere (issue #192) : toutes les colonnes
# j = 0..J-2 sont degenerees au sens du predicat unique ci-dessus (#56),
# sans constante nouvelle : la tolerance 1e-12 est celle de
# .mw_colonne_degeneree(), convention de l'outil et non du texte : ecart
# relatif a f_j au plus 1e-12, ou facteurs que l'aplatissement des ex aequo a
# cette tolerance rend tous egaux (ecart jusqu'a (n - 1) * 1e-12). Pour des
# facteurs exactement egaux, en arithmetique exacte, sigma2_j = 0 pour
# j = 0..J-2 (D(5)(d)(ii)), donc sigma2_(J-1) = 0, MSEP = 0 et
# sigma(res,s,USP) = (1 - c) * sigma(res,s) par D(4) ; sinon sigma2_j et la
# MSEP sont nuls ou negligeables a la tolerance de l'outil (residus d'arrondi
# ou ecarts relatifs entre facteurs de l'ordre de 1e-12) et cette egalite tient
# a un ecart negligeable pres. La colonne J-1 (un seul facteur si I = J)
# n'entre pas dans le predicat. FALSE pour un objet d'ajustement reduit
# (I et reserve seuls, fonction publique) et pour J < 2 (aucune colonne a
# examiner).
.mw_triangle_totalement_degenere <- function(aj) {
  if (!is.list(aj) || !all(c("I", "J", "f", "tri") %in% names(aj))) return(FALSE)
  J <- aj$J
  if (length(J) != 1L || is.na(J) || J < 2L) return(FALSE)
  all(seq.int(0L, J - 2L) %in% .mw_colonnes_degenerees(aj))
}

# --- Lecture de l'extrapolation de sigma2_{J-1} : par. 5(d)(ii), 2e ligne ----
# Fonction de RESTITUTION, sans effet sur les calculs : elle recompose, a
# partir d'un ajustement deja produit par mw_ajuster(), les TROIS arguments du
# minimum du texte et celui qui est retenu, de sorte qu'un relecteur puisse
# refaire le calcul. Elle detecte aussi les cas degeneres sigma2_{J-3} = 0 et
# sigma2_{J-2} = 0, les deux seuls chemins vers sigma2_{J-1} = 0 : les trois
# arguments du minimum etant positifs ou nuls, le minimum est nul si et
# seulement si sigma2_{J-2} = 0 ou sigma2_{J-3} = 0 (le quotient est nul si et
# seulement si sigma2_{J-2} l'est, hors sous-depassement flottant, inatteignable
# pour une colonne non constante). Issue #21.
#
# DETECTION. Le critere ne porte PAS sur sigma2_{J-3} == 0 teste en virgule
# flottante : sigma2_{J-3} est une somme de carres d'ecarts F(i,j) - f_j, deux
# quantites proches l'une de l'autre, et l'arrondi accumule par les divisions
# et par la moyenne ponderee laisse en general un residu strictement positif
# (de l'ordre du carre de l'epsilon machine relatif a f_j^2) la ou la colonne
# est exactement constante. Le critere porte donc sur la PROPRIETE qui annule
# sigma2_{J-3}, a savoir l'egalite de tous les facteurs individuels de la
# colonne a leur moyenne ponderee :
#     max_i |F(i,j) - f_j| <= tol * f_j,   j = J-3 et j = J-2.
# Il est sans dimension (invariant par changement d'unite des cumules) et
# tol = 1e-12, soit environ 1e4 fois l'epsilon machine, laisse passer
# l'arrondi des divisions tout en restant plusieurs ordres de grandeur sous la
# dispersion d'une colonne reelle (coefficient de variation des facteurs de
# l'ordre de 1e-2 a 1e-1).
# Ce critere ne sert qu'au DIAGNOSTIC : la valeur, elle, est robuste sans lui,
# la regle litterale etant continue en zero (une colonne constante a 1e-12
# pres donne un minimum de l'ordre de 1e-21, numeriquement nul).
#
# CHAMPS. Les champs historiques colonne, nb_facteurs, ecart_relatif et
# f_colonne gardent leur sens "colonne J-3" ; les champs suffixes _Jm2 portent
# la meme information pour la colonne J-2, et degeneree_Jm3 / degeneree_Jm2
# le verdict du critere colonne par colonne. degeneree est leur UNION : il
# vaut TRUE des qu'une des deux colonnes est degeneree, c'est-a-dire des que
# sigma2_{J-1} est nul par degenerescence d'un argument du minimum. retenu
# est l'argmin litteral ; le detail du diagnostic M6
# (.mw_detail_extrapolation) nomme la cause.
mw_extrapolation_sigma2 <- function(aj, tol = 1e-12) {
  out <- list(J = NA_integer_, colonne = NA_integer_, nb_facteurs = NA_integer_,
              applicable = FALSE, valeur = NA_real_,
              sigma2_Jm2 = NA_real_, sigma2_Jm3 = NA_real_, quotient = NA_real_,
              retenu = NA_character_, degeneree = FALSE, ecart_relatif = NA_real_,
              f_colonne = NA_real_, f_Jm2 = NA_real_, f_Jm1 = NA_real_,
              developpement_acheve = NA,
              degeneree_Jm3 = FALSE, degeneree_Jm2 = FALSE,
              ecart_relatif_Jm2 = NA_real_, nb_facteurs_Jm2 = NA_integer_,
              f_colonne_Jm2 = NA_real_)
  # La fonction est publique et mw_valider_ajustement() peut recevoir un objet
  # d'ajustement reduit (I et reserve seuls) : il n'y a alors rien a restituer.
  if (!is.list(aj) || !all(c("I", "J", "sigma2", "f", "tri") %in% names(aj)))
    return(out)
  I <- aj$I; J <- aj$J; s2 <- aj$sigma2
  if (length(J) != 1 || is.na(J)) return(out)
  out$J <- J
  out$colonne <- J - 3L
  if (J >= 1 && length(s2) >= J) out$valeur <- s2[J]
  if (J < 3 || length(s2) < J || !is.finite(s2[J - 1]) || !is.finite(s2[J - 2]))
    return(out)
  out$applicable <- TRUE
  out$sigma2_Jm2 <- s2[J - 1]                  # sigma2_{J-2}
  out$sigma2_Jm3 <- s2[J - 2]                  # sigma2_{J-3}
  # Quotient sigma2_{J-2}^2 / sigma2_{J-3} : NA lorsqu'il n'est pas defini.
  out$quotient <- if (s2[J - 2] > 0) s2[J - 1]^2 / s2[J - 2] else NA_real_
  # Argument atteignant le minimum ; a egalite, le premier dans l'ordre du
  # texte. which.min ignore le quotient non defini, sans effet sur le minimum.
  out$retenu <- c("sigma2_(J-2)", "sigma2_(J-3)", "sigma2_(J-2)^2/sigma2_(J-3)")[
    which.min(c(out$sigma2_Jm2, out$sigma2_Jm3, out$quotient))]
  # Critere de degenerescence d'une colonne j : predicat unique
  # .mw_colonne_degeneree() (issue #56), ecart relatif maximal des facteurs
  # individuels F(i,j) a leur moyenne ponderee f_j (.mw_ecart_facteurs()).
  c3 <- .mw_ecart_facteurs(aj, J - 3L)         # colonne J-3 : sigma2_{J-3}
  out$nb_facteurs <- c3$n
  out$f_colonne <- c3$f
  out$ecart_relatif <- c3$ecart
  out$degeneree_Jm3 <- .mw_colonne_degeneree(aj, J - 3L, tol)
  c2 <- .mw_ecart_facteurs(aj, J - 2L)         # colonne J-2 : sigma2_{J-2}
  out$nb_facteurs_Jm2 <- c2$n
  out$f_colonne_Jm2 <- c2$f
  out$ecart_relatif_Jm2 <- c2$ecart
  out$degeneree_Jm2 <- .mw_colonne_degeneree(aj, J - 2L, tol)
  # Union : un seul des deux chemins suffit a annuler sigma2_{J-1}.
  out$degeneree <- out$degeneree_Jm3 || out$degeneree_Jm2
  out$f_Jm2 <- aj$f[J - 1]                     # f_{J-2}
  out$f_Jm1 <- aj$f[J]                         # f_{J-1}
  # "Developpement acheve" : les deux derniers facteurs valent 1, auquel cas
  # une variance nulle sur la derniere annee de developpement est coherente
  # avec les donnees. Sinon le triangle bouge encore et la variance omise
  # n'est pas nulle en realite.
  out$developpement_acheve <- isTRUE(abs(out$f_Jm2 - 1) <= tol) &&
                              isTRUE(abs(out$f_Jm1 - 1) <= tol)
  out
}

# Libelle du diagnostic M6 correspondant : les trois arguments du minimum et
# celui qui est retenu, pour que le calcul soit refaisable a la lecture.
.mw_detail_extrapolation <- function(ex) {
  base <- paste("Valeur non estimee mais extrapolee par la regle min(...) du reglement :",
                "elle ne repose que sur les dernieres colonnes estimees")
  if (!isTRUE(ex$applicable)) return(base)
  q <- if (is.na(ex$quotient))
    "non defini (sigma2_(J-3) = 0), sans effet : le minimum est atteint ailleurs"
  else format(ex$quotient, digits = 6)
  # base est du TEXTE LIBRE : il passe en argument %s, jamais dans la chaine de
  # format. L'interpoler dans le format ferait d'un simple "%" du libelle une
  # specification de conversion -- c'est exactement ce qui a produit un
  # "too few arguments" ailleurs sur cette branche (constat d'audit).
  # Arguments nommes comme atteignant le minimum (issue #21). ex$retenu reste
  # l'argmin litteral ; le libelle, lui, nomme la CAUSE :
  # - colonne J-2 degeneree : le quotient sigma2_(J-2)^2/sigma2_(J-3) n'est nul
  #   que parce que sigma2_(J-2) l'est ; il n'est pas compte comme argument
  #   distinct, meme lorsque l'arrondi le rend plus petit que sigma2_(J-2)
  #   (colonne constante a 1e-14 pres : sigma2_(J-2) ~ 1e-28, quotient ~ 1e-58,
  #   argmin litteral = quotient). Si la colonne J-3 est aussi degeneree, les
  #   deux variances nulles sont nommees ex aequo ;
  # - sinon : tous les arguments egaux au minimum a 1e-12 pres en relatif
  #   (|a - m| <= 1e-12 * m, donc egalite exacte si m = 0), dans l'ordre du
  #   texte, qualifies "ex aequo" s'ils sont plusieurs. Un minimum unique
  #   donne le libelle historique.
  noms <- c("sigma2_(J-2)", "sigma2_(J-3)", "sigma2_(J-2)^2/sigma2_(J-3)")
  if (isTRUE(ex$degeneree_Jm2) && isTRUE(ex$degeneree_Jm3)) {
    retenus <- "sigma2_(J-2) et sigma2_(J-3) (ex aequo)"
  } else if (isTRUE(ex$degeneree_Jm2)) {
    retenus <- paste0("sigma2_(J-2) (colonne J-2 degeneree ; le quotient ",
                      "sigma2_(J-2)^2/sigma2_(J-3), nul par voie de consequence, ",
                      "n'est pas compte comme argument distinct)")
  } else {
    args <- c(ex$sigma2_Jm2, ex$sigma2_Jm3, ex$quotient)
    m <- suppressWarnings(min(args, na.rm = TRUE))
    atteints <- noms[!is.na(args) & abs(args - m) <= 1e-12 * m]
    retenus <- if (length(atteints) <= 1) ex$retenu
      else paste0(paste(atteints[-length(atteints)], collapse = ", "), " et ",
                  atteints[length(atteints)], " (ex aequo)")
  }
  detail <- sprintf(paste0("%s. min(sigma2_(J-2) = %s ; sigma2_(J-3) = %s ; ",
                           "sigma2_(J-2)^2/sigma2_(J-3) = %s) = %s, minimum atteint par %s"),
                    base,
                    format(ex$sigma2_Jm2, digits = 6), format(ex$sigma2_Jm3, digits = 6),
                    q, format(ex$valeur, digits = 6), retenus)
  # "numeriquement nul" et non "= 0" : la detection porte sur les facteurs
  # individuels a la tolerance relative 1e-12 de l'outil (predicat
  # .mw_colonne_degeneree(), deux volets), si bien qu'une colonne constante a
  # 1e-14 pres donne un sigma2 de l'ordre de 1e-21, non nul. La valeur exacte
  # est imprimee quelques mots plus haut dans la meme chaine. Cette phrase
  # finale ne figure que dans les branches degenerees. Hors degenerescence, le
  # libelle ne peut changer que par la regle ex aequo ci-dessus, qui s'y
  # applique aussi ; pour un minimum unique (triangle de non-regression) il
  # est identique au libelle anterieur (reference reserve2.rds).
  d3 <- isTRUE(ex$degeneree_Jm3)
  d2 <- isTRUE(ex$degeneree_Jm2)
  if (d3 && d2)
    detail <- paste0(detail, ". Colonnes J-3 et J-2 a facteurs individuels egaux a f_j ",
                     "a la tolerance relative 1e-12 de l'outil ",
                     "(sigma2_(J-3) et sigma2_(J-2) numeriquement nuls) : ",
                     "voir l'avertissement sur les donnees")
  else if (d3)
    detail <- paste0(detail, ". Colonne J-3 a facteurs individuels egaux a f_j ",
                     "a la tolerance relative 1e-12 de l'outil ",
                     "(sigma2_(J-3) numeriquement nul) : voir l'avertissement sur les donnees")
  else if (d2)
    detail <- paste0(detail, ". Colonne J-2 a facteurs individuels egaux a f_j ",
                     "a la tolerance relative 1e-12 de l'outil ",
                     "(sigma2_(J-2) numeriquement nul) : voir l'avertissement sur les donnees")
  detail
}

# --- Erreur quadratique moyenne de prediction : paragraphe 5 -----------------
# Formule telle qu'imprimee au paragraphe 5 de la VERSION CONSOLIDEE en
# vigueur (ADR 0005). Dans la version d'origine, le paragraphe 5 couvre les
# p. 277-278 du JOUE L 12 du 17.1.2015 (pagination verifiee le 22/09/2026,
# issue #26) ; la formule qui y est imprimee differe de celle appliquee ici.
#
# MSEP = somme_{i=1}^{I} C^(i,J)^2
#          * ( Q_{I-i}/C(i,I-i)
#              + Q_{I-i}/S_{I-i} + somme_{j=I-i+1}^{J-1} (C(I-j,j)/S'_j)*(Q_j/S_j) )
#      + 2 * somme_{i=1}^{I} somme_{k=i+1}^{I} C^(i,J) * C^(k,J)
#          * ( Q_{I-i}/S_{I-i} + somme_{j=I-i+1}^{J-1} (C(I-j,j)/S'_j)*(Q_j/S_j) )
#
# Le crochet, note Delta_i ci-dessous, apparait DEUX fois : dans la premiere
# somme, a cote du terme de variance de processus Q_{I-i}/C(i,I-i), et dans la
# double somme, affectee du facteur 2. Les deux transcriptions internes
# anterieures (moteur et documentation) omettaient les termes diagonaux
# C^(i,J)^2 * Delta_i et le facteur 2 : voir l'issue #7, commentaire
# "M1 tranche sur piece", qui etablit la lettre du texte et verifie que la
# formule ci-dessus coincide avec l'erreur a un an de Merz-Wuthrich (2008)
# a 3e-15 pres sur le triangle de Taylor & Ashe (ChainLadder::CDR).
#
# DECOUPAGE RESTITUE (choix de presentation, pas une prescription du texte) :
#   terme_variance    = somme_i C^(i,J)^2 * Q_{I-i}/C(i,I-i)  -- variance de
#                       processus seule, attribuable annee par annee ;
#   terme_covariance  = somme_i C^(i,J)^2 * Delta_i
#                       + 2 * somme_{i<k} C^(i,J) C^(k,J) * Delta_i  -- erreur
#                       d'estimation, y compris ses termes diagonaux.
# La somme des deux est exactement la MSEP du texte. Ce decoupage
# processus / estimation a un sens statistique et laisse a terme_variance le
# sens qu'il avait deja, dont depend mw_contributions() (parts par annee du
# graphique des contributions).
mw_msep <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  Ch <- aj$C_chapeau; Q <- aj$Q; S <- aj$S; Sp <- aj$Sp
  Cu <- Ch[, J + 1]                                  # C^(i,J)
  Cd <- aj$dernier_observe                           # C(i, I-i)

  # Delta_i : crochet d'erreur d'estimation de l'annee d'accident i.
  # Attention : en R, a:b produit une sequence DESCENDANTE lorsque a > b. La
  # borne superieure de la somme en j doit donc etre testee avant la boucle.
  Delta <- function(i) {
    v <- Q[I - i + 1] / S[I - i + 1]
    if ((I - i + 1) <= (J - 1)) for (j in (I - i + 1):(J - 1))
      v <- v + (tri[I - j + 1, j + 1] / Sp[j + 1]) * (Q[j + 1] / S[j + 1])
    v
  }
  Dl <- vapply(1:I, Delta, numeric(1))               # Dl[i] = Delta_i

  # Variance de processus : somme_i C^(i,J)^2 * Q_{I-i} / C(i,I-i)
  t1 <- 0
  for (i in 1:I) t1 <- t1 + Cu[i + 1]^2 * Q[I - i + 1] / Cd[i + 1]

  # Erreur d'estimation : termes diagonaux C^(i,J)^2 * Delta_i ...
  t2 <- 0
  for (i in 1:I) t2 <- t2 + Cu[i + 1]^2 * Dl[i]
  # ... puis les termes croises, comptes une fois et doubles (meme piege sur
  # (i+1):I lorsque i = I : la borne est testee avant d'entrer dans la boucle).
  for (i in 1:I) if (i < I) for (k in (i + 1):I)
    t2 <- t2 + 2 * Cu[i + 1] * Cu[k + 1] * Dl[i]

  list(msep = t1 + t2, terme_variance = t1, terme_covariance = t2)
}

# --- Applicabilite de la methode no 2 : reserve et MSEP ----------------------
# Controle de validite metier qui ne peut pas figurer dans mw_valider_triangle()
# : la reserve chain-ladder totale R et la MSEP ne sont connues qu'APRES
# l'ajustement. Le paragraphe D(4) definit sigma(res,s,USP) a partir de
# racine(MSEP) / R, c'est-a-dire d'un COEFFICIENT DE VARIATION de la reserve :
# la grandeur n'est definie que pour R > 0. Avec R < 0 le rapport est negatif
# et le melange de credibilite produit un sigma_USP inferieur au sigma standard
# -- un allegement de capital fabrique par une division par un nombre negatif ;
# avec R = 0 il vaut NaN. Le refus est donc la seule conclusion actuarielle
# tenable : la methode n'est pas applicable au triangle fourni.
# Coherence interne : mw_bootstrap() ecarte deja toute replication dont la
# reserve simulee est <= 0 ; la regle de l'estimation ponctuelle ne peut pas
# etre plus permissive que celle de ses replications.
# Ne sont PAS des motifs de refus (decision M4, issue #7) : des reserves
# negatives sur certaines annees de survenance avec un total > 0 (bonis de
# liquidation, recours sur annees anciennes) et un f_j < 1 isole, qui restent
# couverts par l'avertissement de mw_valider_triangle() sur les cumules
# decroissants.
# Lignes de mw_tests() qui consomment mw_residus() (issue #21), par famille,
# avec leur nom exact. Liste etablie par MESURE et non par lecture : on
# remplace mw_residus() par des versions perturbees (colonne retiree, residus
# bruites, signes aleatoires, residu porte a 50, C et F bruites), le
# bootstrap etant fixe, et l'on releve les lignes dont la statistique,
# l'estimation ou une p-value change (23/09/2026). Les lignes calculees sur
# les facteurs F(i,j) n'y figurent pas. A tenir a jour si mw_tests() change :
# test_merz_wuthrich.R refait la mesure et exige l'egalite des deux listes.
.MW_LIGNES_RESIDUS <- list(
  M1 = "Absence de tendance des facteurs avec le cumul, a colonne donnee",
  M2 = c("Heteroscedasticite residuelle vs cumul",
         "Adequation de l'exposant de variance, colonne par colonne",
         "Variance unitaire des residus de Mack"),
  M3 = c("Homogeneite des residus entre annees de survenance",
         "Autocorrelation des residus (Durbin-Watson)",
         "Test des suites sur les residus de Mack"),
  M4 = c("Cellule aberrante du triangle (Grubbs)",
         "Cellules aberrantes multiples (ESD generalise)"),
  M5 = c("Shapiro-Wilk sur les residus de Mack",
         "Lilliefors sur les residus de Mack"))
.MW_LIGNES_RESIDUS_TEXTE <- paste(vapply(names(.MW_LIGNES_RESIDUS), function(fm)
  sprintf("%s (%s)", fm, paste0("\"", .MW_LIGNES_RESIDUS[[fm]], "\"", collapse = " ; ")),
  character(1)), collapse = ", ")

mw_valider_ajustement <- function(aj, msep) {
  err <- character(0)
  R <- aj$reserve
  if (!is.finite(R))
    err <- c(err, sprintf(paste0("Reserve chain-ladder totale non finie (R = %s) : ",
                                 "sigma(res,s,USP) est defini par D(4) comme racine(MSEP) / R ; ",
                                 "la methode du risque de reserve no 2 n'est pas applicable a ce triangle."),
                          format(R)))
  else if (R <= 0)
    err <- c(err, sprintf(paste0("Reserve chain-ladder totale negative ou nulle (R = %s) : ",
                                 "sigma(res,s,USP) est defini par D(4) comme racine(MSEP) / R et ",
                                 "n'a pas de sens pour R <= 0 ; la methode du risque de reserve no 2 ",
                                 "n'est pas applicable a ce triangle."),
                          format(R, digits = 6)))
  # Une MSEP negative est impossible sur un triangle valide (tous les termes de
  # mw_msep() sont positifs ou nuls), mais la fonction est publique : elle garde
  # le domaine de racine(MSEP) / R, donc elle refuse aussi ce cas plutot que de
  # laisser sqrt() produire un NaN assorti d'un simple avertissement.
  if (!is.finite(msep) || msep < 0)
    err <- c(err, sprintf(paste0("MSEP a un an non finie ou negative (MSEP = %s) : ",
                                 "sigma(res,s,USP) n'est pas calculable ; la methode du risque ",
                                 "de reserve no 2 n'est pas applicable a ce triangle."),
                          format(msep)))
  # Refus (issue #192, decision du mainteneur du 05/10/2026, Q-E2r-192-1,
  # option A) : triangle totalement degenere, .mw_triangle_totalement_degenere().
  # Le refus ne repose PAS sur le 0/0 de D(5)(d)(ii) (doctrine #7 : le texte ne
  # prevoit aucune clause de degenerescence et sa lettre donne MSEP = 0) ; il
  # est un choix de mise en oeuvre prudent qui applique des exigences de
  # donnees existantes, rendues obligatoires par l'article 219, par. 1, d) :
  # coherence avec les hypotheses sur la nature stochastique des cumules
  # (D(2)(h), en particulier iv) et representativite du risque de reserve
  # (D(2)(a)), inverifiables quand aucune variance n'est observee. La
  # tolerance 1e-12 du predicat est une convention de l'outil. Motif evalue
  # seulement en l'absence d'autre refus : avec R <= 0 (tous les f_j = 1, par
  # exemple), sigma(res,s,USP) n'est pas defini et le motif de la reserve
  # suffit. Un seul motif : les avertissements de colonnes (extrapolation de
  # sigma2_(J-1), colonnes exclues des residus) ne sont pas emis en plus
  # (Q-E2r-192-4). Triangles partiellement ou quasi degeneres (arrondi des
  # cumules) : inchanges, sous la doctrine de l'avertissement (Q-E2r-192-3).
  complet <- is.list(aj) && all(c("I", "J", "sigma2", "f", "tri") %in% names(aj))
  degenere <- !length(err) && complet && .mw_triangle_totalement_degenere(aj)
  if (degenere)
    err <- c(err, sprintf(paste0(
      "Triangle totalement degenere : pour chaque annee de developpement j = 0..J-2, ",
      "les facteurs individuels C(i,j+1)/C(i,j) sont identiques (a la tolerance ",
      "relative 1e-12 de l'outil pres : ", .MW_PREDICAT_DEGENERE_TEXTE, "). ",
      "Pour des facteurs exactement egaux, en arithmetique exacte, sigma2_j = 0 ",
      "(annexe XVII, D(5)(d)(ii)) et MSEP = 0 ; ici sigma2_j et la MSEP (valeur ",
      "calculee : %s) sont nuls ou negligeables a la tolerance de l'outil (residus ",
      "d'arrondi ou ecarts relatifs entre facteurs de l'ordre de 1e-12), aucun residu ",
      "de Mack n'est retenu et, par D(4), sigma(res,s,USP) = (1 - c) * sigma(res,s) a ",
      "un ecart negligeable pres, sans contribution significative des donnees. ",
      "Ces donnees ne permettent pas d'etablir leur coherence avec les hypotheses sur la ",
      "nature stochastique des montants de sinistres cumules (D(2)(h), en particulier iv : ",
      "variance proportionnelle au cumul precedent), ni leur representativite du risque ",
      "de reserve (D(2)(a)) ; exigences de donnees rendues obligatoires par l'article 219, ",
      "paragraphe 1, point d). L'outil n'applique donc pas a ce triangle la methode du ",
      "risque de reserve no 2 (article 220, paragraphe 1, point b)). Verifier qu'il ",
      "s'agit de paiements cumules observes (D(1)) et non de montants projetes ou lisses."),
      format(msep, digits = 3)))
  # Avertissement (et non refus) : sigma2_{J-1} = 0 par application litterale
  # du par. 5(d)(ii), ce qui arrive si et seulement si la colonne J-3 ou la
  # colonne J-2 est degeneree, facteurs individuels egaux a f_j a la tolerance
  # relative 1e-12 de l'outil (sigma2_{J-3} ou sigma2_{J-2} nul ou
  # numeriquement nul ; voir mw_extrapolation_sigma2). Le cas est licite au
  # regard du texte, qui ne prevoit aucune clause de degenerescence, mais il
  # doit etre VISIBLE : la MSEP ne porte alors aucune variance sur la derniere
  # annee de developpement. UN SEUL avertissement par triangle, de meme
  # squelette quel que soit le chemin (J-3, J-2 ou les deux) : seule la cause
  # varie (issues #7 et #21).
  avt <- character(0)
  ex <- mw_extrapolation_sigma2(aj)
  if (!degenere && isTRUE(ex$degeneree)) {
    # Cause : une proposition par colonne degeneree, dans l'ordre J-3, J-2.
    cols <- list()
    if (isTRUE(ex$degeneree_Jm3))
      cols[[length(cols) + 1]] <- list(nom = "J-3", j = ex$colonne, n = ex$nb_facteurs,
                                       f = ex$f_colonne, ecart = ex$ecart_relatif,
                                       s2 = ex$sigma2_Jm3)
    if (isTRUE(ex$degeneree_Jm2))
      cols[[length(cols) + 1]] <- list(nom = "J-2", j = ex$colonne + 1L,
                                       n = ex$nb_facteurs_Jm2, f = ex$f_colonne_Jm2,
                                       ecart = ex$ecart_relatif_Jm2, s2 = ex$sigma2_Jm2)
    et <- function(x) paste(x, collapse = " et ")
    entete <- et(vapply(cols, function(k) sprintf("j = %s = %d", k$nom, k$j), ""))
    facteurs <- et(vapply(cols, function(k) sprintf(paste0(
      "les %d facteurs individuels F(i,%d) valent f_%d = %s au sens de ce predicat ",
      "(ecart relatif maximal %.1e)"),
      k$n, k$j, k$j, format(k$f, digits = 8), k$ecart), ""))
    nuls <- et(vapply(cols, function(k) sprintf("sigma2_(%s) = %s", k$nom,
                                                 format(k$s2, digits = 3)), ""))
    # L'absence de residus de Mack des colonnes degenerees n'est plus dite
    # ici mais dans l'avertissement general sur les colonnes exclues (ci-
    # dessous), qui couvre toute colonne, J-3 et J-2 comprises, sans doublon
    # (issue #33).
    q <- if (is.na(ex$quotient)) "non defini" else format(ex$quotient, digits = 3)
    # Enonce du predicat UNE FOIS par message, meme si J-3 et J-2 sont toutes
    # deux degenerees (issue #60, decision du mainteneur du 06/10/2026).
    msg <- sprintf(paste0(
      "%s %s, a facteurs individuels egaux a f_j a la tolerance relative 1e-12 ",
      "de l'outil (", .MW_PREDICAT_DEGENERE_TEXTE, ") : %s, donc %s. ",
      "Par application litterale de l'annexe XVII, D(5)(d)(ii), seconde ligne, ",
      "sigma2_(J-1) = min(sigma2_(J-2), sigma2_(J-3), sigma2_(J-2)^2/sigma2_(J-3)) ",
      "= min(%s ; %s ; %s) = %s : ",
      "la MSEP ne porte donc AUCUNE variance sur la derniere annee de developpement. ",
      "Verifier l'origine des donnees (colonne recopiee d'une autre, paiements arretes, ",
      "cellules completees a la main)."),
      if (length(cols) > 1) "Colonnes de developpement" else "Colonne de developpement",
      entete, facteurs, nuls,
      format(ex$sigma2_Jm2, digits = 3), format(ex$sigma2_Jm3, digits = 3), q,
      format(ex$valeur, digits = 3))
    if (!isTRUE(ex$developpement_acheve))
      msg <- paste(msg, sprintf(paste0(
        "Le developpement n'est pourtant PAS acheve (f_(J-2) = %s, f_(J-1) = %s : ",
        "au moins l'un des deux differe de 1) : la variance omise sur la derniere annee de developpement ",
        "n'est pas nulle en realite, et sigma(res,s,USP) s'en trouve sous-estime."),
        format(ex$f_Jm2, digits = 8), format(ex$f_Jm1, digits = 8)))
    avt <- c(avt, msg)
  }
  # Avertissement (et non refus) : colonnes sans residu de Mack (issue #33,
  # avis d'actuary du 24/09/2026). mw_residus() ecarte toute colonne
  # degeneree (facteurs egaux a f_j a la tolerance relative 1e-12 de l'outil :
  # ecart relatif a f_j au plus 1e-12, ou facteurs que l'aplatissement des ex
  # aequo a cette tolerance rend tous egaux ; sigma2_j nul ou numeriquement
  # nul ; residu 0/0 si les facteurs sont exactement egaux, rapport d'ecarts
  # negligeables a la tolerance de l'outil sinon ; issue #60, formulation
  # decidee par le mainteneur le 05/10/2026, Q-E2r-60-2, avec la phrase sur le
  # pool du bootstrap, et le 06/10/2026, constat C1-a, pour l'enonce du
  # predicat) ; sous le modele D(2)(h), une colonne degeneree n'est pas un
  # motif de refus (developpement acheve, par exemple). UN SEUL
  # avertissement par triangle, qui nomme
  # chaque colonne exclue, compte les residus exclus et retenus et cite les
  # lignes de mw_tests() fondees sur ces residus.
  # Objet d'ajustement reduit (I et reserve seuls, fonction publique) : rien
  # a restituer, comme dans mw_extrapolation_sigma2().
  # Triangle totalement degenere refuse : un seul motif, pas d'avertissement
  # de colonnes (issue #192).
  rs <- if (complet && !degenere) mw_residus(aj) else NULL
  ex_col <- attr(rs, "colonnes_exclues")
  if (!is.null(ex_col) && nrow(ex_col)) {
    n_ex <- sum(ex_col$n_facteurs)
    avt <- c(avt, sprintf(paste0(
      "%s a facteurs individuels egaux a f_j a la tolerance relative 1e-12 de l'outil (",
      .MW_PREDICAT_DEGENERE_TEXTE, " ; sigma2_j nul ou numeriquement nul) : %s. ",
      "Le residu de Mack n'y est pas defini (0/0) si les facteurs sont exactement egaux ",
      "et n'est sinon que le rapport d'ecarts negligeables a la tolerance de l'outil ",
      "(residus d'arrondi ou ecarts relatifs de l'ordre de 1e-12) : ",
      "ces %d facteurs individuels sont exclus des residus de Mack ; %d residu(s) de ",
      "Mack sont retenus pour les lignes fondees sur ces residus, soit %s. ",
      "Le pool de reechantillonnage du bootstrap ne contient que les residus retenus ; ",
      "il sert aux p-values Monte-Carlo des lignes M1 a M4 et a l'intervalle de confiance ",
      "bootstrap de sigma. ",
      "Une colonne degeneree n'est pas un motif de refus (developpement ",
      "acheve, par exemple) ; verifier l'origine des donnees si ce n'est pas le cas."),
      if (nrow(ex_col) > 1) "Colonnes de developpement" else "Colonne de developpement",
      paste(sprintf("j = %d (%d facteurs)", ex_col$j, ex_col$n_facteurs), collapse = ", "),
      n_ex, nrow(rs), .MW_LIGNES_RESIDUS_TEXTE))
  }
  # Avertissement (et non refus) : reserve positive mais negligeable devant
  # son incertitude (issue #33, decision du mainteneur du 24/09/2026). D(4)
  # definit sigma(res,s,USP) = racine(MSEP) / R pour tout R > 0 sans plancher
  # ni plage : le repere sigma estime >= 1 (ecart-type a un an superieur a la
  # reserve elle-meme) est un repere de lecture, sans fondement reglementaire
  # ni statistique ; aucun sigma(res,s) des annexes II et XIV n'excede 0,22.
  # Aucun seuil sur R (grandeur monetaire) ; M4 (R <= 0 refuse) inchangee.
  if (!length(err) && R > 0 && sqrt(msep) / R >= 1) {
    ult <- if (length(aj$ultime)) sum(aj$ultime) else NA_real_
    part <- if (is.finite(ult) && ult > 0)
      sprintf(", soit %s %% de l'ultime total %s", format(100 * R / ult, digits = 3),
              format(ult, digits = 6)) else ""
    avt <- c(avt, sprintf(paste0(
      "Reserve chain-ladder positive mais faible devant son incertitude : sigma estime = ",
      "racine(MSEP) / R = %s >= 1 (R = %s%s). ",
      "Le parametre est defini (annexe XVII, D(4)) mais hors de toute plage ou le melange ",
      "par credibilite a un sens (aucun sigma(res,s) des annexes II et XIV n'excede 0,22). ",
      "Deux lectures : reserve residuelle d'un segment en run-off, ou triangle anormalement ",
      "volatil. Le repere 1 est un repere de lecture, sans fondement reglementaire ni ",
      "statistique ; le calcul n'est pas refuse."),
      format(sqrt(msep) / R, digits = 4), format(R, digits = 6), part))
  }
  list(ok = length(err) == 0, erreurs = err, avertissements = avt,
       reserve = R, msep = msep)
}

# --- Parametre propre : paragraphe 4 -----------------------------------------
# sigma(res,s,USP) = c * sqrt(MSEP) / somme_{i=0}^{I}(C^(i,J) - C(i,I-i))
#                    + (1 - c) * sigma(res,s)
# Les cas ou le rapport racine(MSEP) / R n'a pas de sens sont refuses ici par
# une erreur explicite, comme l'est deja une duree inferieure a 5 ans (via
# usp_credibilite). Le point d'entree run_engine() n'atteint jamais cette
# erreur : .run_engine_mw() appelle mw_valider_ajustement() en amont et
# renvoie ok = FALSE avec sa validation.
mw_parametre <- function(aj, msep, sigma_standard, bareme = "court") {
  T_cred <- aj$I + 1L                       # duree = nombre d'annees d'accident
  cred <- usp_credibilite(T_cred, bareme)   # section G(3)(c)
  reserve <- aj$reserve
  vc <- mw_valider_ajustement(aj, msep)
  if (!vc$ok) stop(paste(vc$erreurs, collapse = " "))
  sigma_est <- sqrt(msep) / reserve
  list(reserve = reserve, msep = msep, racine_msep = sqrt(msep),
       sigma_estime = sigma_est, credibilite = cred,
       sigma_standard = sigma_standard,
       sigma_usp = cred * sigma_est + (1 - cred) * sigma_standard,
       variation_relative = (cred * sigma_est + (1 - cred) * sigma_standard) /
                            sigma_standard - 1,
       duree_credibilite = T_cred)
}

# --- Residus standardises de Mack --------------------------------------------
# r(i,j) = sqrt(C(i,j)) * ( C(i,j+1)/C(i,j) - f_j ) / sigma_j
# Sous les hypotheses D(2)(h)(iii) et (iv), ces residus sont centres, de
# variance approximativement unitaire et mutuellement non correles. Ce sont eux
# qui servent de support aux tests des sections H1, H2 et H4 adaptees.
# Colonnes exclues (issue #33, avis d'actuary du 24/09/2026 ; issue #60,
# decision du mainteneur du 05/10/2026, variante (b)) : une colonne j a au
# moins deux facteurs est ecartee si sigma2_j n'est pas fini ou n'est pas
# strictement positif (une somme ponderee de carres : "<= 0" se lit "= 0"),
# OU si elle appartient a l'ensemble des colonnes degenerees : facteurs
# individuels egaux a f_j a la tolerance relative 1e-12 de l'outil (ecart
# relatif a f_j au plus 1e-12, ou facteurs que l'aplatissement des ex aequo a
# cette tolerance rend tous egaux, ecart jusqu'a (n - 1) * 1e-12), predicat
# unique .mw_colonne_degeneree() (#56, #60). Le residu y vaut 0/0 si les
# facteurs sont exactement egaux ; sinon, et en general par l'arrondi,
# sigma2_j est strictement positif (mesures : 4,9e-22 sur ta_bruit,
# 2,1e-28 sur t5, 9,7e-21 sur le triangle du constat C1, triangles des tests)
# et le residu calcule n'est alors qu'un bruit d'arrondi norme, que le
# critere sigma2_j = 0 exact laissait entrer dans les lignes fondees sur les
# residus et dans le pool du bootstrap.
# Ensemble des colonnes degenerees : j_degeneres s'il est fourni (ensemble
# FIGE au triangle observe par mw_bootstrap() et transmis aux statistiques
# de chaque replication, comme pour M1, #56 : la colonne exclue a l'observe
# l'est dans chaque replication, ou le facteur simule C * f_j / C peut
# differer de f_j au bit pres et donner un sigma2_j de bruit strictement
# positif -- mesure sur ta_deg des tests, colonne j = 4 : 18 replications sur
# 50, sigma2_4 au plus 2,6e-25 ; le nombre de residus est ainsi le meme a
# l'observe et dans les replications), sinon calcule sur aj lui-meme
# (.mw_colonnes_degenerees(), appel sur le triangle observe). Une colonne
# hors de l'ensemble fige reste ecartee dans une replication si son sigma2_j
# simule n'est pas strictement positif (residu non defini).
# L'exclusion n'est pas silencieuse : l'attribut "colonnes_exclues"
# (data.frame j, n_facteurs) la consigne, et mw_valider_ajustement() en fait
# un avertissement. .run_engine_mw() retire l'attribut avant de stocker les
# residus (aucun champ nouveau dans le resultat). La colonne J-1 (un seul
# facteur si I = J) n'a jamais de residu et n'est pas comptee comme exclue :
# le test du nombre de facteurs precede celui de la degenerescence, que la
# colonne J-1 verifie trivialement.
mw_residus <- function(aj, j_degeneres = NULL) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  jd <- .mw_j_exclues(aj, j_degeneres)
  out <- data.frame()
  exclues <- data.frame(j = integer(0), n_facteurs = integer(0))
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 2) next
    if (!is.finite(aj$sigma2[j + 1]) || aj$sigma2[j + 1] <= 0 || j %in% jd) {
      exclues[nrow(exclues) + 1L, ] <- list(as.integer(j), length(idx))
      next
    }
    Cij <- tri[idx + 1, j + 1]; Cij1 <- tri[idx + 1, j + 2]
    out <- rbind(out, data.frame(
      i = idx, j = j, calendrier = idx + j,
      C = Cij, F = Cij1 / Cij, f_chapeau = aj$f[j + 1],
      sigma_j = sqrt(aj$sigma2[j + 1]),
      residu = sqrt(Cij) * (Cij1 / Cij - aj$f[j + 1]) / sqrt(aj$sigma2[j + 1]),
      stringsAsFactors = FALSE))
  }
  attr(out, "colonnes_exclues") <- exclues
  out
}

# --- Test des effets d'annee calendaire (Mack) --------------------------------
# Mack (1994), "Which stochastic model is underlying the chain ladder method ?",
# Insurance: Mathematics and Economics 15, 133-138 ; repris dans Mack (1993),
# ASTIN Bulletin 23(2), 213-225.
# Principe : dans chaque colonne j, les facteurs observes sont classes en
# "grands" (L) et "petits" (S) par rapport a leur mediane ; sous H0 d'absence
# d'effet calendaire, la repartition des L et des S le long de chaque diagonale
# est purement aleatoire. On note Z_k = min(L_k, S_k) sur la diagonale k.
.mack_moments_Z <- function(n) {
  # Loi exacte de Z = min(L, S) lorsque n etiquettes sont reparties au hasard :
  # L ~ Binomiale(n, 1/2) et Z = min(L, n-L).
  if (n < 2) return(c(E = 0, V = 0))
  m <- floor((n - 1) / 2)
  E <- n / 2 - choose(n - 1, m) * n / 2^n
  V <- n * (n - 1) / 4 - choose(n - 1, m) * n * (n - 1) / 2^n + E - E^2
  c(E = E, V = max(V, 0))
}

# Colonnes degenerees (#60, extension de la decision Q-E2r-60-1 (b) du
# mainteneur, 06/10/2026) : une colonne de l'ensemble j_degeneres (fige a
# l'observe par mw_bootstrap(), calcule sur aj s'il n'est pas fourni,
# .mw_j_exclues()) ne recoit aucune etiquette L / S : toutes ses etiquettes
# valent "*". Le gel vaut aussi a l'observe : il peut y retirer une colonne
# que l'aplatissement seul n'aurait pas rendue constante (ecart relatif a
# f_j au plus 1e-12 sans fusion des ex aequo). Sans ce gel, une colonne
# degeneree a l'observe peut, dans une replication, recevoir des etiquettes
# L / S tirees du bruit d'arrondi de ses facteurs simules.
mw_test_annees_calendaires <- function(aj, j_degeneres = NULL) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  jd <- .mw_j_exclues(aj, j_degeneres)
  etiq <- data.frame()
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 2) next
    F <- tri[idx + 1, j + 2] / tri[idx + 1, j + 1]
    # Ex aequo a la tolerance TOL_EX_AEQUO (#152) : F aplati AVANT la mediane,
    # plancher 0 (rapport strictement positif, tolerance relative) ; une
    # valeur egale a la mediane a la tolerance recoit donc "*".
    F <- engine_aplatir_ex_aequo(F, plancher = 0)
    md <- stats::median(F)
    lab <- if (j %in% jd) rep("*", length(F)) else
      ifelse(F > md, "L", ifelse(F < md, "S", "*"))
    etiq <- rbind(etiq, data.frame(i = idx, j = j, diag = idx + j, lab = lab,
                                   stringsAsFactors = FALSE))
  }
  etiquettes <- etiq                         # toutes les etiquettes, "*" compris
  etiq <- etiq[etiq$lab != "*", , drop = FALSE]
  if (!nrow(etiq)) return(list(stat = NA_real_, p = NA_real_, Z = NA_real_,
                                etiquettes = etiquettes))
  agg <- lapply(split(etiq$lab, etiq$diag), function(v) {
    L <- sum(v == "L"); S <- sum(v == "S"); n <- L + S
    m <- .mack_moments_Z(n)
    c(Z = min(L, S), E = unname(m["E"]), V = unname(m["V"]), n = n)
  })
  A <- do.call(base::rbind, agg)
  A <- A[A[, "n"] >= 2, , drop = FALSE]
  if (!nrow(A)) return(list(stat = NA_real_, p = NA_real_, Z = NA_real_,
                             etiquettes = etiquettes))
  Z <- sum(A[, "Z"]); EZ <- sum(A[, "E"]); VZ <- sum(A[, "V"])
  if (!is.finite(VZ) || VZ <= 0) return(list(stat = NA_real_, p = NA_real_, Z = Z,
                                              etiquettes = etiquettes))
  st <- (Z - EZ) / sqrt(VZ)
  list(stat = st, p = .p_borne(2 * (1 - stats::pnorm(abs(st)))),
       Z = Z, E = EZ, V = VZ, detail = A, etiquettes = etiquettes)
}

# --- Test de correlation entre annees de developpement adjacentes (Mack) -----
# Mack (1997) / Mack (1993), ASTIN Bulletin 23(2). L'hypothese D(2)(h)(ii)
# suppose les facteurs de developpement successifs non correles. On mesure la
# correlation de rang de Spearman entre colonnes adjacentes, agregee sur le
# triangle. La loi sous H0 dependant de la geometrie du triangle, la p-value
# est obtenue par permutation (voir mw_bootstrap).
# Colonnes degenerees (#60, extension de la decision Q-E2r-60-1 (b) du
# mainteneur, 06/10/2026) : la paire (k - 1, k) est exclue si l'une de ses
# deux colonnes de facteurs appartient a l'ensemble j_degeneres (fige a
# l'observe par mw_bootstrap(), calcule sur aj s'il n'est pas fourni,
# .mw_j_exclues()), et non plus seulement si l'aplatissement des ex aequo la
# rend constante dans le triangle courant : les paires retenues sont ainsi
# les memes a l'observe et dans chaque replication au regard des colonnes
# degenerees. Le gel vaut aussi a l'observe, ou il peut retirer une paire
# que l'aplatissement seul aurait gardee (ecart au plus 1e-12 sans fusion). Une colonne hors de l'ensemble reste ecartee par la garde
# sd() == 0 si elle est constante apres aplatissement.
mw_stat_correlation_dev <- function(aj, j_degeneres = NULL) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  jd <- .mw_j_exclues(aj, j_degeneres)
  Ts <- w <- numeric(0); ea <- FALSE
  for (k in 1:(J - 1)) {
    idx <- 0:(I - k - 1)
    if (length(idx) < 3) next
    if ((k - 1L) %in% jd || k %in% jd) next
    Fk  <- tri[idx + 1, k + 1] / tri[idx + 1, k]        # colonne k-1 -> k
    Fk1 <- tri[idx + 1, k + 2] / tri[idx + 1, k + 1]    # colonne k -> k+1
    # Ex aequo a la tolerance TOL_EX_AEQUO (#152) : Fk et Fk1 aplatis
    # separement, plancher 0, avant la garde sd() == 0 et rank().
    Fk  <- engine_aplatir_ex_aequo(Fk,  plancher = 0)
    Fk1 <- engine_aplatir_ex_aequo(Fk1, plancher = 0)
    if (stats::sd(Fk) == 0 || stats::sd(Fk1) == 0) next
    rho <- suppressWarnings(stats::cor(rank(Fk), rank(Fk1)))
    if (!is.finite(rho)) next
    Ts <- c(Ts, rho); w <- c(w, length(idx) - 1)
    # Ex aequo apres aplatissement dans une paire retenue (#115) : rangs
    # moyens, loi de permutation conditionnelle non tabulee (p_min NA).
    ea <- ea || anyDuplicated(Fk) > 0 || anyDuplicated(Fk1) > 0
  }
  if (!length(Ts)) return(list(stat = NA_real_, T = NA_real_))
  list(stat = sum(w * Ts) / sum(w), T = Ts, poids = w, ex_aequo = ea)
}


# Pente commune de F(i,j) sur C(i,j) A EFFET DE COLONNE FIXE, ponderee par
# C(i,j) conformement a l'hypothese de variance M2. Renvoie la statistique de
# Student de la pente, ou NA si le modele n'est pas estimable.
.mw_lm_intra <- function(res) {
  if (nrow(res) < 4 || stats::sd(res$C) == 0) return(NULL)
  # Ponderation des MOINDRES CARRES GENERALISES : Var(F(i,j)) = sigma_j^2 /
  # C(i,j), donc le poids exact est C(i,j) / sigma_j^2. Ponderer par C(i,j)
  # seul serait insuffisant : sigma_j^2 varie de plusieurs ordres de grandeur
  # entre la premiere et la derniere colonne, l'echelle residuelle serait
  # dominee par les premieres et le test deviendrait inoperant (verifie par
  # simulation : aucun rejet sous H0).
  if (!("sigma_j" %in% names(res)) || any(!is.finite(res$sigma_j)) ||
      any(res$sigma_j <= 0)) return(NULL)
  res$w <- res$C / res$sigma_j^2
  if (length(unique(res$j)) < 2)
    m <- try(stats::lm(F ~ C, weights = w, data = res), silent = TRUE)
  else
    m <- try(stats::lm(F ~ factor(j) + C, weights = w, data = res), silent = TRUE)
  if (inherits(m, "try-error")) return(NULL)
  co <- summary(m)$coefficients
  if (!("C" %in% rownames(co))) return(NULL)
  co["C", ]
}
.mw_pente_intra <- function(res) {
  co <- .mw_lm_intra(res)
  if (is.null(co)) NA_real_ else unname(co[3])
}

# --- Tests specifiques de l'hypothese (iii) de l'annexe XVII, D(2)(h) --------
# L'enonce reglementaire porte "pour TOUTES les annees d'accident" :
#   E[C(i,j+1) | C(i,j)] = f_j C(i,j)
# Il comporte donc DEUX exigences distinctes, testables separement :
#   (a) une proportionnalite SANS CONSTANTE, colonne par colonne ;
#   (b) un facteur f_j COMMUN a toutes les annees d'accident de la colonne.
# Une regression unique agregee sur l'ensemble du triangle ne teste ni l'une ni
# l'autre : elle melange des colonnes d'echelles tres differentes.
#
# Remarque (Mack, 1993, section 3) : la regression ponderee de C(i,j+1) sur
# C(i,j) SANS constante et de poids 1/C(i,j) a pour estimateur des moindres
# carres exactement le facteur chain-ladder f_j. C'est donc la regression de
# reference, et ajouter une constante fournit le test naturel de (a).

# Combinaison de p-values independantes par la methode de Fisher (1932) :
#   X = -2 * somme(ln p_k) suit une loi du khi-deux a 2K degres de liberte.
# ATTENTION : les colonnes adjacentes partagent la colonne C(., j+1), de sorte
# que l'independance n'est qu'approchee. La p-value combinee est donc rapportee
# comme NON simulee et indicative ; la p-value de reference reste celle du
# bootstrap de residus.
# Aucune exclusion silencieuse (issue #90) : K est le nombre de p-values
# recues ; il ne varie plus que si l'appelant ecarte une colonne (lm() en
# echec, garde sd() == 0, colonne trop courte). Une p-value nulle
# (debordement de la loi de reference) est relevee au plancher
# .Machine$double.xmin (terme -2 ln p fini, environ 1416), au lieu d'ecarter
# la colonne qui porte la preuve la plus forte contre H0 ; une p-value non
# finie ou hors de [0, 1] rend la statistique NA (K inchange), que le
# bootstrap ecarte de B_effectif.
.fisher_combine <- function(p) {
  K <- length(p)
  if (K < 2 || any(!is.finite(p) | p < 0 | p > 1))
    return(list(stat = NA_real_, p = NA_real_, K = K))
  X <- -2 * sum(log(pmax(p, .Machine$double.xmin)))
  list(stat = X, p = .p_borne(1 - stats::pchisq(X, 2 * K)), K = K)
}

# P-value bilaterale de Spearman d'une colonne, pour les combinaisons de Fisher
# de HomogF (mw_test_homogeneite_f()) et d'ExpVar (mw_test_exposant_variance())
# (issue #90, decisions du mainteneur du 06/10/2026). a : deja aplati par
# l'appelant a TOL_EX_AEQUO, avec le plancher de sa grandeur (#152) ; b :
# aplati ici, plancher plancher_b (sans effet sur des entiers distincts).
# Apres aplatissement, un ex aequo est une egalite au bit pres (en-tete de
# TOL_EX_AEQUO), comme dans les statistiques de rang de #152.
#   - n <= 9 sans ex aequo : cor.test(exact = TRUE), loi de permutation
#     enumeree (prho.c, n_small = 9) ;
#   - sinon (n > 9, ou ex aequo) : cor.test(exact = FALSE), approximation de
#     Student, relevee au plancher 2/n!, valeur exacte de P(|rho| = 1) sans
#     ex aequo et simple plancher numerique avec ex aequo ; a |rho| = 1,
#     l'approximation rend p = 0 (n = 4) ou 1,7e-61 (n = 10), sous 2/n!.
# Resultat dans [2/n!, 1] (NA si cor.test() ne rend pas de p-value finie).
# Ces p_j ne sont PAS des p exactes au sens de l'ADR 0002 : elles n'entrent
# que dans la statistique X de Fisher, dont la p retenue reste Monte-Carlo.
.mw_spearman_p <- function(a, b, plancher_b = 1) {
  b <- engine_aplatir_ex_aequo(b, plancher = plancher_b)
  n <- length(a)
  exact <- n <= 9 && !anyDuplicated(a) && !anyDuplicated(b)
  p <- suppressWarnings(stats::cor.test(a, b, method = "spearman", exact = exact))$p.value
  if (!is.finite(p)) return(NA_real_)
  min(1, max(2 / factorial(n), p))
}

# Colonnes degenerees des verifications colonne par colonne de M1 (issue #56,
# avis d'actuary du 24/09/2026). Une colonne eligible (assez de facteurs pour
# la verification) mais degeneree au sens de .mw_colonne_degeneree() n'a pas
# de statistique definie (0/0) : elle est exclue de la combinaison de Fisher,
# comme une colonne trop courte. Dans le bootstrap, la regle a deux volets
# (option (a) d'actuary sur #56) :
#   1. l'ensemble des colonnes degenerees est determine UNE FOIS sur le
#      triangle observe (argument j_degeneres, transmis par mw_bootstrap() via
#      le contexte de .mw_contexte_mc()) ; chaque replication exclut
#      exactement ces colonnes, degenerees ou non dans le triangle simule :
#      au regard des colonnes degenerees, K est identique entre statistique
#      observee et simulee ; .fisher_combine() n'ecarte plus aucune p-value
#      (issue #90) : K ne varie plus que si l'appelant ecarte une colonne
#      (lm() en echec, garde sd() == 0) ;
#   2. une colonne retenue a l'observe mais degeneree dans la replication
#      n'est ni exclue (K changerait) ni soumise a lm() / cor.test() : la
#      statistique de la replication vaut NA et sort de B_effectif.
# Avec j_degeneres = NULL (appel sur le triangle observe, mw_tests()),
# l'ensemble est calcule sur aj lui-meme : f(aj) et
# f(aj, j_degeneres = .mw_colonnes_degenerees(aj)) sont identiques. Des
# donnees proportionnelles a 12 chiffres pres ne se rencontrent pas sur
# donnees reelles : ces cas sont des garde-fous numeriques. Le moteur detecte
# la degenerescence lui-meme avant tout appel a lm() : une colonne degeneree
# ne produit aucun avertissement R, et aucun n'est ni capture ni masque.
# Limite mesuree, acceptee par actuary (#56) : une colonne a peine
# au-dessus du seuil reste soumise a lm(), dont le critere "essentially
# perfect fit" de summary.lm() n'est pas relatif (variance residuelle
# ponderee, rss/ddl, comparee a 1e-30 fois le carre des valeurs ajustees non
# ponderees) ; sur Taylor & Ashe, colonne j = 4, cet avertissement sort a
# l'ecart relatif 1,02e-12 (observe et replications) et a 2,26e-12
# (replications seulement), plus a 1,13e-11. Les colonnes exclues
# sont rendues a part (element "exclues", data.frame j, n_facteurs ; element
# "eligibles", nombre de colonnes eligibles), sans ligne ni colonne nouvelle
# dans le tableau "detail" ; mw_tests() les restitue dans le libelle de la
# ligne, sans champ nouveau dans le resultat.
.mw_exclues_vide <- function()
  list(colonnes = data.frame(j = integer(0), n_facteurs = integer(0)), eligibles = 0L)
.mw_exclure <- function(ex, j, n) {
  ex$colonnes[nrow(ex$colonnes) + 1L, ] <- list(as.integer(j), as.integer(n))
  ex$eligibles <- ex$eligibles + 1L
  ex
}
# Phrase ajoutee au libelle ("detail") d'une ligne de M1, SEULEMENT si une
# colonne est exclue ; chaine vide sinon (libelle inchange). quoi : ce qui
# n'est pas defini sur la colonne ; preuve : ce que l'exclusion ne prouve pas.
.mw_phrase_exclusion <- function(r, quoi, preuve) {
  ex <- r$exclues
  if (is.null(ex) || !nrow(ex)) return("")
  K <- if (is.null(r$K)) 0L else r$K
  plur <- nrow(ex) > 1
  sprintf(paste0(
    "%s (facteurs individuels egaux a f_j a la tolerance relative 1e-12 de l'outil : ",
    .MW_PREDICAT_DEGENERE_TEXTE, " ; sigma2_j nul ou numeriquement nul) : %s ; %s, ",
    "%s hors de la combinaison ",
    "de Fisher ; K = %d colonne(s) testee(s) sur %d eligible(s). ",
    "L'exclusion ne vaut pas preuve %s."),
    if (plur) "Colonnes degenerees" else "Colonne degeneree",
    paste(sprintf("j = %d (%d facteurs)", ex$j, ex$n_facteurs), collapse = ", "),
    quoi, if (plur) "colonnes" else "colonne", K, r$eligibles, preuve)
}

# Ensemble des colonnes exclues d'une verification de M1 : j_degeneres s'il
# est fourni (ensemble fige a l'observe par mw_bootstrap()), sinon calcule sur
# aj lui-meme (appel observe).
.mw_j_exclues <- function(aj, j_degeneres) {
  if (is.null(j_degeneres)) .mw_colonnes_degenerees(aj) else as.integer(j_degeneres)
}
# Resultat d'une replication dans laquelle une colonne retenue a l'observe est
# degeneree (volet 2 de la regle ci-dessus) : statistique non definie, sans
# appel a lm() / cor.test() ; K = NA (et non un K different de l'observe).
.mw_stat_non_definie <- function(ex)
  list(stat = NA_real_, p = NA_real_, K = NA_integer_, detail = data.frame(),
       exclues = ex$colonnes, eligibles = ex$eligibles)

# Libelle de base, suivi de la phrase d'exclusion s'il y en a une : sans
# colonne exclue, le libelle est exactement le libelle de base.
.mw_avec_exclusion <- function(base, phrase) {
  if (!nzchar(phrase)) return(base)
  paste0(base, if (grepl("\\.$", base)) " " else ". ", phrase)
}

# (a) Nullite de l'ordonnee a l'origine, colonne par colonne.
# Regression ponderee C(i,j+1) = a_j + b_j C(i,j), poids 1/C(i,j).
mw_test_ordonnee_origine <- function(aj, j_degeneres = NULL) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  det <- data.frame()
  ex <- .mw_exclues_vide()
  jd <- .mw_j_exclues(aj, j_degeneres)
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 3) next                    # 2 parametres + 1 ddl minimum
    # Colonne degeneree (issue #56) : t_j = a_j / se(a_j) vaut 0/0, statistique
    # non definie ; colonne de l'ensemble fige exclue, colonne retenue mais
    # degeneree -> statistique NA, AVANT tout appel a lm().
    if (j %in% jd) { ex <- .mw_exclure(ex, j, length(idx)); next }
    ex$eligibles <- ex$eligibles + 1L
    if (.mw_colonne_degeneree(aj, j)) return(.mw_stat_non_definie(ex))
    C0 <- tri[idx + 1, j + 1]; C1 <- tri[idx + 1, j + 2]
    m <- try(summary(stats::lm(C1 ~ C0, weights = 1 / C0)), silent = TRUE)
    if (inherits(m, "try-error") || nrow(m$coefficients) < 2) next
    det <- rbind(det, data.frame(
      j = j, n = length(idx),
      a = m$coefficients[1, 1], se_a = m$coefficients[1, 2],
      t = m$coefficients[1, 3], p = m$coefficients[1, 4],
      b = m$coefficients[2, 1], f_cl = aj$f[j + 1], stringsAsFactors = FALSE))
  }
  if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det,
                              exclues = ex$colonnes, eligibles = ex$eligibles))
  fc <- .fisher_combine(det$p)
  list(stat = fc$stat, p = fc$p, K = fc$K, detail = det,
       t_max = det$t[which.max(abs(det$t))], j_max = det$j[which.max(abs(det$t))],
       exclues = ex$colonnes, eligibles = ex$eligibles)
}

# (b) Homogeneite de f_j entre annees de survenance.
# Si f_j est commun a toutes les annees d'accident, les facteurs individuels
# F(i,j) d'une meme colonne ne doivent presenter aucune tendance en i.
# Correlation de rang de Spearman entre F(i,j) et i, colonne par colonne.
mw_test_homogeneite_f <- function(aj, j_degeneres = NULL) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  det <- data.frame()
  ex <- .mw_exclues_vide()
  jd <- .mw_j_exclues(aj, j_degeneres)
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 4) next
    # Colonne degeneree (issue #56) : facteurs constants, correlation de rang
    # non definie. Le predicat unique remplace le test sd(F) == 0 exact, qui
    # laissait passer une colonne constante a 1e-14 pres. Colonne de l'ensemble
    # fige exclue, colonne retenue mais degeneree -> statistique NA.
    if (j %in% jd) { ex <- .mw_exclure(ex, j, length(idx)); next }
    ex$eligibles <- ex$eligibles + 1L
    if (.mw_colonne_degeneree(aj, j)) return(.mw_stat_non_definie(ex))
    # F aplati a TOL_EX_AEQUO avant cor.test() (#152), plancher 0.
    F <- engine_aplatir_ex_aequo(tri[idx + 1, j + 2] / tri[idx + 1, j + 1], plancher = 0)
    # p de la colonne par .mw_spearman_p() (issue #90) : loi de permutation a n <= 9 sans
    # ex aequo, jamais nulle ; rho reste celui de cor.test().
    ct <- suppressWarnings(stats::cor.test(F, idx, method = "spearman", exact = FALSE))
    # ex_aequo (#115) : ex aequo de F apres aplatissement (idx est sans ex
    # aequo), p_j hors loi de permutation, p_min NA (.mw_fisher_rangs_p_min()).
    det <- rbind(det, data.frame(j = j, n = length(idx),
      rho = unname(ct$estimate), p = .mw_spearman_p(F, idx),
      ex_aequo = anyDuplicated(F) > 0, stringsAsFactors = FALSE))
  }
  if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det,
                              exclues = ex$colonnes, eligibles = ex$eligibles))
  fc <- .fisher_combine(det$p)
  list(stat = fc$stat, p = fc$p, K = fc$K, detail = det,
       exclues = ex$colonnes, eligibles = ex$eligibles)
}

# (c) Absence de courbure : terme quadratique dans la regression ponderee.
# Une courbure significative contredit la LINEARITE, meme si la constante est
# nulle : E[C(i,j+1)|C(i,j)] ne serait alors pas proportionnelle a C(i,j).
mw_test_courbure <- function(aj, j_degeneres = NULL) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  det <- data.frame()
  ex <- .mw_exclues_vide()
  jd <- .mw_j_exclues(aj, j_degeneres)
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 4) next                    # 3 parametres + 1 ddl
    # Colonne degeneree (issue #56) : terme quadratique exactement nul, t = 0/0 ;
    # colonne de l'ensemble fige exclue, colonne retenue mais degeneree ->
    # statistique NA, AVANT tout appel a lm().
    if (j %in% jd) { ex <- .mw_exclure(ex, j, length(idx)); next }
    ex$eligibles <- ex$eligibles + 1L
    if (.mw_colonne_degeneree(aj, j)) return(.mw_stat_non_definie(ex))
    C0 <- tri[idx + 1, j + 1]; C1 <- tri[idx + 1, j + 2]
    if (stats::sd(C0) == 0) next
    m <- try(summary(stats::lm(C1 ~ C0 + I(C0^2), weights = 1 / C0)), silent = TRUE)
    if (inherits(m, "try-error") || nrow(m$coefficients) < 3) next
    det <- rbind(det, data.frame(j = j, n = length(idx),
      c2 = m$coefficients[3, 1], t = m$coefficients[3, 3],
      p = m$coefficients[3, 4], stringsAsFactors = FALSE))
  }
  if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det,
                              exclues = ex$colonnes, eligibles = ex$eligibles))
  fc <- .fisher_combine(det$p)
  list(stat = fc$stat, p = fc$p, K = fc$K, detail = det,
       exclues = ex$colonnes, eligibles = ex$eligibles)
}

# (d) Stabilite du facteur selon la ponderation : famille alpha.
#   f_j^(alpha) = somme_i C(i,j)^alpha F(i,j) / somme_i C(i,j)^alpha
#   alpha = 0 : moyenne simple des facteurs individuels
#   alpha = 1 : facteur chain-ladder du reglement
#   alpha = 2 : ponderation par le carre du volume
# Sous l'hypothese (iii), les trois estimateurs visent le MEME f_j : une
# divergence marquee signale que l'esperance n'est pas proportionnelle a
# C(i,j), ou que la ponderation en C(i,j) de l'hypothese (iv) est inadaptee.
# La statistique est l'amplitude relative moyenne, ponderee par les effectifs.
mw_famille_alpha <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  det <- data.frame()
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 3) next
    C0 <- tri[idx + 1, j + 1]; F <- tri[idx + 1, j + 2] / C0
    f <- vapply(c(0, 1, 2), function(a) sum(C0^a * F) / sum(C0^a), numeric(1))
    det <- rbind(det, data.frame(j = j, n = length(idx),
      f0 = f[1], f1 = f[2], f2 = f[3],
      amplitude = (max(f) - min(f)) / f[2], stringsAsFactors = FALSE))
  }
  if (!nrow(det)) return(list(stat = NA_real_, detail = det))
  list(stat = sum(det$n * det$amplitude) / sum(det$n), detail = det)
}

# (e) Adequation de l'exposant de variance (hypothese (iv), complement de M2).
# Si Var[C(i,j+1)|C(i,j)] = sigma_j^2 C(i,j), alors les residus standardises de
# Mack sont d'echelle constante DANS CHAQUE COLONNE : |r(i,j)| ne doit pas
# dependre de C(i,j). Correlation de rang colonne par colonne, combinee.
mw_test_exposant_variance <- function(aj, j_degeneres = NULL) {
  res <- mw_residus(aj, j_degeneres)
  if (!nrow(res)) return(list(stat = NA_real_, p = NA_real_, detail = data.frame()))
  det <- data.frame()
  for (j in unique(res$j)) {
    d <- res[res$j == j, ]
    # Ex aequo a la tolerance TOL_EX_AEQUO (#152), avant la garde sd() == 0
    # et cor.test() : C en plancher 0 (montant, tolerance relative), |r| en
    # plancher 1 (grandeur d'ordre 1, comme les residus de Mack de #112).
    # Colonne a C constants ou a |r| constants apres aplatissement :
    # correlation de rang non definie (ecart-type nul), colonne ecartee de la
    # combinaison de Fisher, comme une colonne trop courte (garde |r| ajoutee
    # par l'issue #60 : cor.test() rendait sinon rho = NA sans trace).
    Ca <- engine_aplatir_ex_aequo(d$C, plancher = 0)
    ra <- engine_aplatir_ex_aequo(abs(d$residu))
    if (nrow(d) < 4 || stats::sd(Ca) == 0 || stats::sd(ra) == 0) next
    # p de la colonne par .mw_spearman_p() (issue #90), comme HomogF ; Ca y
    # est aplati une seconde fois (plancher_b = 0), sans effet.
    ct <- suppressWarnings(stats::cor.test(ra, Ca,
                                           method = "spearman", exact = FALSE))
    # ex_aequo (#115) : comme dans mw_test_homogeneite_f().
    det <- rbind(det, data.frame(j = j, n = nrow(d),
      rho = unname(ct$estimate), p = .mw_spearman_p(ra, Ca, plancher_b = 0),
      ex_aequo = anyDuplicated(ra) > 0 || anyDuplicated(Ca) > 0,
      stringsAsFactors = FALSE))
  }
  if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det))
  fc <- .fisher_combine(det$p)
  list(stat = fc$stat, p = fc$p, K = fc$K, detail = det)
}

# (f) Homogeneite des residus entre annees de survenance (hypothese (i)).
# Si les annees d'accident sont stochastiquement independantes et suivent le
# meme modele, les residus de Mack ne doivent pas differer systematiquement
# d'une ligne a l'autre. Test de Kruskal-Wallis (1952), non parametrique.
# Un residu par annee de survenance (une seule colonne garde des residus, par
# exemple ; issue #60, decision du mainteneur du 06/10/2026, Q3) :
# H = N - 1 par construction (un residu par annee de survenance) : aucune
# p-value. La statistique est restituee (decision du mainteneur du
# 06/10/2026, Q2 d'actuary), p asymptotique NA, et le champ logique
# un_par_annee le signale a mw_tests() (libelle et loi).
mw_test_homogeneite_accident <- function(aj, j_degeneres = NULL) {
  res <- mw_residus(aj, j_degeneres)
  g <- factor(res$i)
  if (nlevels(g) < 3 || nrow(res) < 6)
    return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_, un_par_annee = FALSE))
  # Residus aplatis a TOL_EX_AEQUO avant kruskal.test() (#152), plancher 1.
  ra <- engine_aplatir_ex_aequo(res$residu)
  k <- try(stats::kruskal.test(ra, g), silent = TRUE)
  if (inherits(k, "try-error"))
    return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_, un_par_annee = FALSE))
  un <- nlevels(g) == nrow(res)
  p <- if (un) NA_real_ else .p_borne(k$p.value)
  # tailles des groupes et ex aequo des residus aplatis : p_min de la ligne
  # (#115, .mw_kruskal_p_min()), lues par mw_tests() seulement.
  list(stat = unname(k$statistic), p = p, ddl = unname(k$parameter), un_par_annee = un,
       tailles = as.vector(table(g)), ex_aequo = anyDuplicated(ra) > 0)
}

# --- p_min des lignes Merz-Wuthrich a loi de reference discrete (#115) --------
# Specification d'actuary (docs/specifications/e2-reduite.md, #115 (b)) ;
# decisions du mainteneur du 06/10/2026 (Q-E2r-115-2 a 4). Meme definition
# que pour la methode lognormale (CONTEXT.md, "Test inoperant") : plus petite
# p-value atteignable sous la loi de reference discrete (loi echangeable),
# aux effectifs observes, dans le sens du catalogue MW_CATALOGUE_MC, avec le
# doublement des lignes bilaterales (M8). AUCUNE de ces lois n'est exacte
# pour le modele de Mack (residus non echangeables, variances inegales,
# colonnes adjacentes dependantes) : p_min ne borne pas la p Monte-Carlo
# retenue, et add() le dit ("sous la loi de reference echangeable"). La
# regle R1 reste celle d'add(), sans regle propre a Merz-Wuthrich.
# Cles du catalogue a statistique discrete, seules a recevoir une p_min :
# Runs, Calendrier, CorrDev, HomogF, ExpVar, KruskalAcc (liste a reprendre
# si R1 change pour les lignes a p Monte-Carlo, #125).

# Effet calendaire (bilateral) : sur chaque diagonale retenue (n_k >= 2),
# L_k ~ Binomiale(n_k, 1/2), diagonales independantes, Z = somme min(L_k,
# n_k - L_k). C'est la loi binomiale independante de Mack (1994), celle des
# moments de .mack_moments_Z(), et NON la loi de permutation intra-colonne
# (dans une colonne, le nombre de L est fixe par la mediane, ce qui lie les
# diagonales) : choix de la specification (#115 (b)2), question Q1 de
# l'audit renvoyee a #125. Loi de Z par convolution exacte ; p_min = min sur
# le support de 2 min(P(Z <= z), P(Z >= z)), bornee a 1. NA si aucune
# diagonale.
.mw_calendrier_p_min <- function(n_k) {
  n_k <- n_k[is.finite(n_k) & n_k >= 2]
  if (!length(n_k)) return(NA_real_)
  d <- 1
  for (n in n_k) {
    z <- 0:floor(n / 2)
    pz <- ifelse(2 * z == n, choose(n, z), 2 * choose(n, z)) / 2^n
    # Convolution directe (sans FFT : aucune masse parasite hors du support).
    e <- numeric(length(d) + length(pz) - 1L)
    for (a in seq_along(pz)) {
      ix <- seq_along(d) + a - 1L
      e[ix] <- e[ix] + d * pz[a]
    }
    d <- e
  }
  sup <- which(d > 0)
  p <- vapply(sup, function(i) 2 * min(sum(d[seq_len(i)]), sum(d[i:length(d)])), numeric(1))
  .p_borne(min(p))
}

# Correlation entre colonnes adjacentes (bilateral) : statistique moyenne
# ponderee des rho_k de Spearman ; |T| maximal si et seulement si chaque
# rho_k vaut +1 (ou chacun -1). Loi de reference : permutations
# independantes des facteurs de chaque colonne. Les paires partagent une
# colonne et ne sont PAS independantes : la formule tient par
# conditionnement le long de la chaine. La paire k compare la colonne k
# restreinte a ses n_k premieres lignes a la colonne k+1, qui a exactement
# n_k facteurs ; quel que soit l'ordre des colonnes precedentes, rho_k = +1
# (resp. -1) exige que la colonne k+1 reproduise (resp. renverse) cet ordre
# restreint, avec probabilite 1/n_k!. D'ou p_min = min(1, 2 prod 1/n_k!),
# n_k = poids + 1 facteurs par paire (mw_stat_correlation_dev()). Sans ex
# aequo seulement.
.mw_corr_p_min <- function(n_k) {
  if (!length(n_k) || any(!is.finite(n_k) | n_k < 1)) return(NA_real_)
  .p_borne(2 * exp(-sum(lfactorial(n_k))))
}

# HomogF et ExpVar (queue haute) : X = -2 somme ln p_j, p_j de Spearman par
# .mw_spearman_p(), loi de permutation enumeree (n_j <= 9 sans ex aequo) :
# p_j = 2/n_j! a |rho_j| = 1 exactement et p_j > 2/n_j! sinon (strictement
# decroissante en |rho_j|, issue #90), colonnes permutees independamment.
# X maximal si et seulement si toutes les colonnes ont |rho_j| = 1, de
# probabilite 2/n_j! chacune : p_min = prod 2/n_j!. Au-dela de n_j = 9,
# p_j est l'approximation de Student relevee au plancher 2/n_j!, atteint par
# d'autres permutations que les deux extremes : p_min n'est pas attribuee.
.mw_fisher_rangs_p_min <- function(n_j) {
  if (length(n_j) < 2 || any(!is.finite(n_j) | n_j < 2 | n_j > 9)) return(NA_real_)
  .p_borne(exp(sum(log(2) - lfactorial(n_j))))
}

# Kruskal-Wallis entre annees de survenance (queue haute), sans ex aequo :
# forme close p_min = k! prod n_i! / N!, k groupes de tailles n_i, N = somme
# n_i. Demonstration. H est une fonction croissante de somme R_i^2 / n_i (R_i
# somme des rangs du groupe i). Avec r les rangs 1..N et W_i la somme des
# carres intra-groupe des rangs du groupe i (ecarts a leur moyenne),
# somme R_i^2 / n_i = somme r^2 - somme W_i, ou somme r^2 ne depend pas de
# l'affectation. Or W_i >= n_i (n_i^2 - 1) / 12 (variance minimale de n_i
# entiers distincts), avec egalite si et seulement si les rangs du groupe
# sont des entiers consecutifs. H est donc maximal exactement sur les
# affectations en blocs de rangs contigus, et les k! ordres des blocs le
# realisent tous (les bornes sont atteintes simultanement). Sur les
# N! / prod n_i! affectations equiprobables : p_min = k! prod n_i! / N!.
# Verifiee par enumeration exhaustive dans les tests unitaires
# (test_merz_wuthrich.R, issue #115). Calcul
# en logarithmes ; sous-depassement (N de l'ordre de 200) : NA, motif dans
# l'attribut "motif", repris par .mw_p_min_ligne().
.mw_kruskal_p_min <- function(tailles) {
  if (length(tailles) < 2 || any(!is.finite(tailles) | tailles < 1)) return(NA_real_)
  N <- sum(tailles)
  p <- exp(lfactorial(length(tailles)) + sum(lfactorial(tailles)) - lfactorial(N))
  if (!is.finite(p) || p <= 0)
    return(structure(NA_real_, motif = sprintf(paste(
      "p_min = k! prod n_i! / N! hors de la precision de la machine (N = %d) :",
      "p_min non calculable"), as.integer(N))))
  .p_borne(p)
}

# Arguments p_min et effectifs d'une ligne de mw_tests() (#115). defini :
# statistique observee finie (sinon p_min et effectifs NA : aucune p_min a
# motiver, detail inchange). n : effectifs de la loi de reference, passes a
# f_p_min ; libelle : leur nom dans effectifs (NULL : n nomme, "n1 = 13, n2 = 13",
# format des suites de usp_tests()). ex_aequo (lignes de rangs) :
# loi de permutation conditionnelle non tabulee, p_min NA ; n_max : au-dela,
# loi de reference non tabulee (p_j de Spearman a n_j > 9), p_min NA. Le
# motif est porte par effectifs, qu'add() ajoute au detail d'un test sans
# p_min (#70, 5a), comme eff_rangs dans usp_tests().
.mw_p_min_ligne <- function(defini, n, libelle, f_p_min, ex_aequo = FALSE, n_max = Inf) {
  if (!isTRUE(defini) || !length(n)) return(list(p_min = NA_real_, effectifs = NA_character_))
  eff <- if (is.null(libelle)) paste(sprintf("%s = %d", names(n), as.integer(n)), collapse = ", ")
         else sprintf("%s = %s", libelle, paste(n, collapse = ", "))
  if (isTRUE(ex_aequo))
    return(list(p_min = NA_real_, effectifs = paste(eff, "; ex aequo : loi de permutation",
                                                    "conditionnelle non tabulee, p_min non attribuee")))
  if (any(n > n_max))
    return(list(p_min = NA_real_, effectifs = sprintf(paste(
      "%s ; colonne de plus de %d facteurs : p_j de Spearman par approximation de",
      "Student relevee au plancher 2/n!, loi de reference non tabulee, p_min non attribuee"),
      eff, n_max)))
  # Valeur non finie rendue par f_p_min hors des cas motives ci-dessus
  # (constat C2 de l'audit) : motif explicite, celui de f_p_min s'il en
  # porte un (attribut "motif"), sinon motif generique.
  p <- f_p_min(n)
  if (!is.finite(p)) {
    mot <- attr(p, "motif")
    return(list(p_min = NA_real_, effectifs = paste(eff, " ; ",
      if (is.character(mot) && length(mot) == 1L) mot else
        "p_min non calculable sur ces effectifs, p_min non attribuee", sep = "")))
  }
  list(p_min = p, effectifs = eff)
}

# --- Bootstrap de Mack par reechantillonnage des residus ---------------------
# England & Verrall (2002), "Stochastic claims reserving in general insurance",
# British Actuarial Journal 8(3), 443-518 ; England (2002).
# Le modele de Mack ne specifie que les deux premiers moments : aucun bootstrap
# PARAMETRIQUE n'est possible, contrairement a la methode lognormale. On
# reechantillonne donc les residus standardises de Mack, ce qui ne suppose que
# leur echangeabilite. La p-value obtenue est donc de nature semi-parametrique.
mw_simuler_triangle <- function(aj, res_pool) {
  I <- aj$I; J <- aj$J
  tri <- matrix(NA_real_, I + 1, J + 1)
  tri[, 1] <- aj$tri[, 1]                       # premiere colonne conservee
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    sg <- sqrt(aj$sigma2[j + 1])
    if (!is.finite(sg)) sg <- 0
    e <- sample(res_pool, length(idx), replace = TRUE)
    Cij <- tri[idx + 1, j + 1]
    tri[idx + 1, j + 2] <- Cij * aj$f[j + 1] + e * sg * sqrt(Cij)
  }
  # Un cumul simule negatif ou decroissant rendrait les facteurs non definis :
  # on borne par une valeur stricitement positive, en le signalant au besoin.
  tri[!is.na(tri) & tri <= 0] <- NA_real_
  tri
}

# Pool de reechantillonnage du bootstrap de Mack (issue #46, decision du
# mainteneur du 06/10/2026, Q-E2r-46-1, variante B). Sous le modele de Mack a
# sigma_j connu, conditionnellement a C_{.,j}, le residu
#     r_ij = sqrt(C_ij) (F_ij - f^_j) / sigma_j
# a pour variance 1 - h_ij, ou h_ij = C_ij / S_j est le levier de la cellule
# dans l'estimation de f^_j (S_j = somme des C_ij de la colonne ; colonne
# "levier" de mw_influence()). Chaque residu est redresse :
#     r~_ij = r_ij / sqrt(1 - h_ij),
# 1 - h_ij etant calcule comme (S_j - C_ij) / S_j, somme des AUTRES cellules
# de la colonne divisee par S_j, et non comme 1 - C_ij / S_j : pour une
# cellule qui domine sa colonne (volumes de l'ordre de 1e16 fois les autres),
# 1 - C_ij / S_j vaut 0 en flottant et le pool deviendrait NaN (C2 de l'audit
# de #46). Avec n_j >= 2 et C_ij > 0 finis (validation), 1 - h_ij > 0 pour
# toute cellule retenue. Limite, anterieure a #46 et hors de cette fonction :
# pour une telle cellule, r_ij lui-meme perd ses chiffres par annulation dans
# F_ij - f^_j (mw_residus()), et le redressement agrandit cette erreur.
# Le pool est ensuite recentre : la contrainte d'estimation de f^_j est
# sum_i sqrt(C_ij) r_ij = 0, et non sum_i r_ij = 0, de sorte que la moyenne
# du pool redresse n'est pas nulle. Pour n_j = 2, |r~_ij| = 1 exactement avant
# recentrage (|r_ij| = sqrt(1 - h_ij) dans ce cas).
# Interpretation de l'outil (redressement par le levier des modeles lineaires
# ponderes), non formule du reglement. Seul le pool change : mw_residus(), les
# statistiques observees et repliquees et mw_simuler_triangle() ne sont pas
# modifies. Le pool ne contient que les residus retenus par mw_residus() avec
# l'ensemble j_degeneres des colonnes degenerees (fige a l'observe par
# mw_bootstrap(), calcule sur aj s'il n'est pas fourni ; #60).
.mw_pool_residus <- function(aj, j_degeneres = NULL) {
  res <- mw_residus(aj, j_degeneres)
  if (!nrow(res)) return(numeric(0))
  # 1 - h_ij = (S_j - C_ij) / S_j, sur les lignes 0..I-j-1 de la colonne j
  # (memes cellules que mw_residus() et mw_influence()).
  un_moins_h <- vapply(seq_len(nrow(res)), function(k) {
    col <- aj$tri[seq_len(aj$I - res$j[k]), res$j[k] + 1]
    sum(col[-(res$i[k] + 1)]) / sum(col)
  }, numeric(1))
  pool <- res$residu / sqrt(un_moins_h)
  pool - mean(pool)                               # recentrage
}

mw_bootstrap <- function(aj, B = 999, seed = 20260831) {
  # Tirages sous graine locale (ADR 0004, #42) : etat de l'appelant restaure.
  engine_sous_graine(seed, {
    # Colonnes degenerees determinees UNE FOIS sur le triangle observe et
    # figees pour la statistique observee et chaque replication : M1 (issue
    # #56) et residus de Mack de toutes les lignes qui en dependent (issue
    # #60, via le contexte de .mw_contexte_mc()).
    jd <- .mw_colonnes_degenerees(aj)
    # Pool : residus de Mack retenus du triangle observe, colonnes degenerees
    # exclues (#60), redresses par le levier puis recentres (#46).
    pool <- .mw_pool_residus(aj, jd)
    # Contexte observe conserve pour les conditions du catalogue (#44).
    e_obs <- .mw_contexte_mc(aj, jd)
    obs <- .mc_evaluer(MW_CATALOGUE_MC, e_obs)
    noms <- names(obs)
    sim <- matrix(NA_real_, B, length(noms), dimnames = list(NULL, noms))
    sig <- rep(NA_real_, B)
    for (b in seq_len(B)) {
      tb <- mw_simuler_triangle(aj, pool)
      if (anyNA(tb[upper.tri(tb, diag = TRUE)[, rev(seq_len(ncol(tb)))]])) next
      ab <- try(mw_ajuster(tb), silent = TRUE)
      if (inherits(ab, "try-error")) next
      sb <- try(.mw_stats(ab, jd), silent = TRUE)
      if (inherits(sb, "try-error")) next
      sim[b, ] <- sb[noms]
      mb <- try(mw_msep(ab), silent = TRUE)
      if (!inherits(mb, "try-error") && is.finite(mb$msep) && ab$reserve > 0)
        sig[b] <- sqrt(mb$msep) / ab$reserve
    }
  })
  # Les tests de NORMALITE sont volontairement exclus du bootstrap. Le
  # reechantillonnage tire dans la loi empirique des residus OBSERVES : son
  # hypothese nulle est "les residus suivent leur propre loi empirique", et non
  # "les residus sont normaux". Une p-value de Monte-Carlo y serait vide de
  # sens (verification par simulation : frequence de rejet nulle au lieu de
  # 5 %). La normalite n'est d'ailleurs PAS une hypothese du modele de Mack :
  # l'annexe XVII, D(2)(h), ne specifie que les deux premiers moments. Elle est
  # donc traitee comme un diagnostic descriptif, avec sa loi nulle propre.
  # P-values de Monte-Carlo, erreur de Monte-Carlo et B effectif, le sens du
  # rejet etant lu au catalogue MW_CATALOGUE_MC (fonction partagee avec
  # usp_bootstrap()).
  mc <- .mc_p_values(sim, obs, MW_CATALOGUE_MC, e_obs)
  # granularite (B nominal) et granularite_stat (par statistique, sur B_eff) :
  # comme dans usp_bootstrap() (issue #40) ; motif_mc (#44, regle R2) en fin
  # de liste.
  list(stats_obs = as.list(obs), p_mc = mc$p_mc,
       err_mc = mc$err_mc,
       B_effectif = mc$B_effectif, granularite = 1 / (B + 1),
       sigma_boot = sig[is.finite(sig)], B = B,
       granularite_stat = mc$granularite, motif_mc = mc$motif_mc)
}

# --- Catalogue Monte-Carlo de la methode Merz-Wuthrich (ADR 0003) -------------
# Meme structure que USP_CATALOGUE_MC (voir .mc_entree()) ; contexte construit
# par .mw_contexte_mc(). `degenere` : NULL pour toutes les entrees.
# Contexte : ajustement aj, ensemble j_degeneres des colonnes degenerees
# exclues des verifications colonne par colonne de M1 (issue #56) et des
# residus de Mack (issue #60) : fige a l'observe par mw_bootstrap(), calcule
# sur aj s'il n'est pas fourni ; residus de Mack (mw_residus(), calcules une
# fois avec cet ensemble) et leur vecteur r.
.mw_contexte_mc <- function(aj, j_degeneres = NULL) {
  jd <- .mw_j_exclues(aj, j_degeneres)
  res <- mw_residus(aj, jd)
  list(aj = aj, res = res, r = res$residu, j_degeneres = jd)
}

MW_CATALOGUE_MC <- list(
  # Ensemble fige des colonnes degenerees transmis (#60, extension de
  # Q-E2r-60-1 (b) du 06/10/2026), comme pour M1, ExpVar et KruskalAcc.
  Calendrier = .mc_entree(function(e) mw_test_annees_calendaires(e$aj, e$j_degeneres)$stat, "deux"),
  CorrDev    = .mc_entree(function(e) mw_stat_correlation_dev(e$aj, e$j_degeneres)$stat, "deux"),
  # Heteroscedasticite residuelle : les residus de Mack ne doivent plus
  # dependre de C(i,j) si la variance est bien proportionnelle a C(i,j).
  BP         = .mc_entree(function(e) {
    res <- e$res; r <- e$r
    if (nrow(res) > 3 && stats::sd(res$C) > 0)
      nrow(res) * summary(stats::lm(I(r^2) ~ res$C))$r.squared else NA_real_
  }, "haut"),
  Grubbs     = .mc_entree(function(e) test_grubbs(e$r)$stat, "haut"),
  DW         = .mc_entree(function(e) stat_dw(e$r), "deux"),
  Runs       = .mc_entree(function(e) test_runs(e$r)$stat, "deux"),
  # Regression auxiliaire testant la proportionnalite sur l'ensemble du
  # triangle. L'EFFET DE COLONNE EST INDISPENSABLE : le facteur f_j decroit
  # avec j alors que le cumule C(i,j) croit, de sorte qu'une regression
  # agregee sans terme d'annee de developpement capte cette relation mecanique
  # et rejette H0 de facon quasi systematique (verifie par simulation : 100 %
  # de rejets sous H0). L'ajout de facteur(j) ramene le test a ce qu'il
  # pretend mesurer : une dependance au volume A L'INTERIEUR de chaque
  # colonne. La statistique est la pente intra-colonne de .mw_pente_intra()
  # (cle renommee a l'issue #41 ; ADR 0003).
  PenteIntra = .mc_entree(function(e) .mw_pente_intra(e$res), "deux"),
  # Tests specifiques de l'hypothese (iii), colonne par colonne. Les
  # statistiques de Fisher et de Kruskal-Wallis rejettent en queue haute ;
  # l'amplitude de la famille alpha egalement.
  Origine    = .mc_entree(function(e) mw_test_ordonnee_origine(e$aj, e$j_degeneres)$stat, "haut"),
  HomogF     = .mc_entree(function(e) mw_test_homogeneite_f(e$aj, e$j_degeneres)$stat, "haut"),
  Courbure   = .mc_entree(function(e) mw_test_courbure(e$aj, e$j_degeneres)$stat, "haut"),
  Alpha      = .mc_entree(function(e) mw_famille_alpha(e$aj)$stat, "haut"),
  # Residus de Mack recalcules avec l'ensemble fige des colonnes degenerees
  # (issue #60), comme e$res.
  ExpVar     = .mc_entree(function(e) mw_test_exposant_variance(e$aj, e$j_degeneres)$stat, "haut"),
  KruskalAcc = .mc_entree(function(e) mw_test_homogeneite_accident(e$aj, e$j_degeneres)$stat, "haut")
)

# Statistiques bootstrapables de la methode Merz-Wuthrich (catalogue
# MW_CATALOGUE_MC). j_degeneres : ensemble fige des colonnes degenerees de M1
# (NULL : calcule sur aj).
.mw_stats <- function(aj, j_degeneres = NULL)
  .mc_evaluer(MW_CATALOGUE_MC, .mw_contexte_mc(aj, j_degeneres))

# --- Table des tests de la methode Merz-Wuthrich ------------------------------
# Meme structure de sortie que usp_tests() : chaque ligne porte H0, H1, la
# statistique, les p-values disponibles et la nature de celle qui est retenue.
mw_tests <- function(aj, boot, alpha = 0.10) {
  res <- mw_residus(aj); r <- res$residu; n <- length(r)
  # Enregistrement des lignes de resultat : fonction partagee avec usp_tests()
  # (engine_registre_tests(), ADR 0003) ; une statistique Monte-Carlo absente
  # du catalogue ou du bootstrap leve une erreur.
  reg <- engine_registre_tests(boot, MW_CATALOGUE_MC, alpha,
                               nature_mc = "Monte-Carlo (bootstrap de residus)")
  add <- reg$add

  ## --- M1 : proportionnalite des cumules (D(2)(h)(iii)) ---------------------
  fam <- "M1. proportionnalite des cumules (annexe XVII D(2)(h)(iii))"
  ti <- .mw_lm_intra(res)
  add(fam, "Absence de tendance des facteurs avec le cumul, a colonne donnee",
      fonction = ".mw_lm_intra",
      "Mack (1993), ASTIN Bulletin 23(2)",
      H0 = "a annee de developpement donnee, le facteur ne depend pas du niveau de C(i,j)",
      H1 = "les facteurs varient avec le volume a l'interieur d'une colonne",
      stat_nom = "t", stat = if (!is.null(ti)) unname(ti[3]) else NA_real_,
      loi = "t ponderee a effet de colonne fixe ; p de reference par Monte-Carlo",
      p_as = if (!is.null(ti)) unname(ti[4]) else NA_real_, mc_nom = "PenteIntra",
      detail = paste("Regression ponderee sur tout le triangle AVEC effet fixe d'annee de",
                     "developpement. Sans ce terme, la decroissance de f_j et la croissance",
                     "de C(i,j) creent une relation mecanique qui fait rejeter H0 dans la",
                     "quasi-totalite des cas."))

  # --- Tests colonne par colonne de l'hypothese (iii) ------------------------
  oo <- mw_test_ordonnee_origine(aj)
  add(fam, "Nullite de l'ordonnee a l'origine, colonne par colonne",
      fonction = "mw_test_ordonnee_origine",
      "Mack (1993), ASTIN Bulletin 23(2), section 3",
      H0 = "a_j = 0 pour toute annee de developpement j",
      H1 = "au moins une colonne presente une composante fixe",
      stat_nom = "X de Fisher", stat = oo$stat,
      loi = "chi2(2K) approx. (colonnes non independantes) -> Monte-Carlo",
      estim_nom = "colonnes testees", estim = if (is.null(oo$K)) NA_real_ else oo$K,
      p_as = oo$p, mc_nom = "Origine",
      detail = .mw_avec_exclusion(paste(
                     "La regression ponderee SANS constante et de poids 1/C(i,j) a pour",
                     "estimateur exactement f_j (identite de Mack, verifiee a 1e-16).",
                     "Ajouter une constante fournit donc le test naturel de la",
                     "proportionnalite, colonne par colonne."),
                   .mw_phrase_exclusion(oo, paste0(
                     "ordonnee a l'origine nulle pour des facteurs exactement egaux, statistique ",
                     "de Student non definie (0/0) ou reduite a des ecarts negligeables a la ",
                     "tolerance de l'outil"),
                     "de proportionnalite")))
  hf <- mw_test_homogeneite_f(aj)
  # p_min (#115) : .mw_fisher_rangs_p_min() sur les n_j des K colonnes combinees.
  pm_hf <- .mw_p_min_ligne(is.finite(hf$stat), hf$detail$n, "colonnes n_j",
                           .mw_fisher_rangs_p_min, any(hf$detail$ex_aequo), n_max = 9)
  add(fam, "Homogeneite de f_j entre annees de survenance",
      fonction = "mw_test_homogeneite_f",
      "Annexe XVII, D(2)(h)(iii) : 'pour toutes les annees d'accident'",
      H0 = "le facteur f_j est commun a toutes les annees de survenance",
      H1 = "les facteurs individuels derivent avec l'annee de survenance",
      stat_nom = "X de Fisher", stat = hf$stat,
      loi = "chi2(2K) approx. -> Monte-Carlo",
      estim_nom = "colonnes testees", estim = if (is.null(hf$K)) NA_real_ else hf$K,
      p_as = hf$p, mc_nom = "HomogF",
      p_min = pm_hf$p_min, effectifs = pm_hf$effectifs,
      detail = .mw_avec_exclusion(
        "Correlation de rang entre F(i,j) et i, colonne par colonne, combinee par Fisher",
        .mw_phrase_exclusion(hf,
          "facteurs individuels constants, correlation de rang non definie",
          "de l'homogeneite de f_j entre annees de survenance")))
  cb <- mw_test_courbure(aj)
  add(fam, "Absence de courbure de la regression",
      fonction = "mw_test_courbure",
      "Test du terme quadratique, dans l'esprit de Ramsey (1969)",
      H0 = "le terme en C(i,j)^2 est nul dans chaque colonne",
      H1 = "la relation entre cumules successifs n'est pas lineaire",
      stat_nom = "X de Fisher", stat = cb$stat,
      loi = "chi2(2K) approx. -> Monte-Carlo",
      estim_nom = "colonnes testees", estim = if (is.null(cb$K)) NA_real_ else cb$K,
      p_as = cb$p, mc_nom = "Courbure",
      detail = .mw_avec_exclusion(
        "Une courbure invalide la linearite meme si la constante est nulle",
        .mw_phrase_exclusion(cb,
          paste0("terme quadratique nul pour des facteurs exactement egaux, statistique de Student ",
                 "non definie (0/0) ou reduite a des ecarts negligeables a la tolerance de l'outil"),
          "de linearite")))
  al <- mw_famille_alpha(aj)
  add(fam, "Stabilite du facteur selon la ponderation (famille alpha)",
      fonction = "mw_famille_alpha",
      "Mack (1994), Insurance: Mathematics and Economics 15",
      H0 = "les estimateurs alpha = 0, 1 et 2 visent le meme f_j",
      H1 = "la valeur du facteur depend de la ponderation retenue",
      stat_nom = "amplitude relative", stat = al$stat,
      loi = "aucune loi analytique -> Monte-Carlo", mc_nom = "Alpha",
      detail = paste("alpha = 0 : moyenne simple des facteurs ; alpha = 1 : chain-ladder",
                     "du reglement ; alpha = 2 : ponderation par le carre du volume."))

  ## --- M2 : structure de variance (D(2)(h)(iv)) -----------------------------
  fam <- "M2. variance proportionnelle au cumul (annexe XVII D(2)(h)(iv))"
  bp <- if (n > 3 && stats::sd(res$C) > 0) {
    m <- stats::lm(I(r^2) ~ res$C); list(stat = n * summary(m)$r.squared,
      p = .p_borne(1 - stats::pchisq(n * summary(m)$r.squared, 1))) } else list(stat = NA_real_, p = NA_real_)
  add(fam, "Heteroscedasticite residuelle vs cumul",
      fonction = "mw_tests",
      "Breusch & Pagan (1979) / Koenker (1981), applique aux residus de Mack",
      H0 = "les residus de Mack ne dependent plus de C(i,j)",
      H1 = "la ponderation en C(i,j) ne capture pas la variance",
      stat_nom = "LM", stat = bp$stat, loi = "chi2(1) asymptotique",
      p_as = bp$p, mc_nom = "BP",
      detail = "Si Var(C(i,j+1)|C(i,j)) = sigma_j^2 C(i,j), les residus standardises sont d'echelle constante")
  ev <- mw_test_exposant_variance(aj)
  pm_ev <- .mw_p_min_ligne(is.finite(ev$stat), ev$detail$n, "colonnes n_j",
                           .mw_fisher_rangs_p_min, any(ev$detail$ex_aequo), n_max = 9)
  add(fam, "Adequation de l'exposant de variance, colonne par colonne",
      fonction = "mw_test_exposant_variance",
      "Annexe XVII, D(2)(h)(iv) ; complement de Breusch-Pagan",
      H0 = "|r(i,j)| ne depend pas de C(i,j) dans chaque colonne",
      H1 = "l'exposant 1 impose par le reglement est inadapte",
      stat_nom = "X de Fisher", stat = ev$stat,
      loi = "chi2(2K) approx. -> Monte-Carlo",
      estim_nom = "colonnes testees", estim = if (is.null(ev$K)) NA_real_ else ev$K,
      p_as = ev$p, mc_nom = "ExpVar",
      p_min = pm_ev$p_min, effectifs = pm_ev$effectifs,
      detail = paste("Si la variance est bien proportionnelle a C(i,j), les residus",
                     "standardises sont d'echelle constante a l'interieur de chaque colonne."))
  # La variance des residus de Mack est CONTRAINTE par construction, et sa
  # valeur de reference n'est pas 1. sigma2_j etant l'estimateur de Mack,
  #   somme_i r(i,j)^2 = somme_i C(i,j) (F(i,j) - f_j)^2 / sigma2_j = n_j - 1
  # EXACTEMENT dans chaque colonne (mesure sur le triangle de test : 6, 5, 4,
  # 3, 2, 1 pour n_j = 7, 6, 5, 4, 3, 2). La somme des carres vaut donc N - k,
  # ou k est le nombre de colonnes retenues, et la valeur attendue de var(r)
  # est (N - k)/(N - 1) -- 21/26 = 0,8077 sur un triangle 8x8, contre 0,8075
  # mesure. Comparer cette grandeur a 1 revenait a armer un seuil sur une
  # valeur que la construction fixe ailleurs.
  # ADR 0001 : un diagnostic n'a pas de verdict (affiche INFO). Le seuil de
  # 0,5 qui figurait ici n'est ni un niveau de test ni une regle de l'annexe
  # XVII ; il disparait, et la valeur de reference est restituee dans le
  # detail pour que le relecteur puisse la recalculer.
  k_col <- length(unique(res$j))
  var_attendue <- if (n > 1) (n - k_col) / (n - 1) else NA_real_
  add(fam, "Variance unitaire des residus de Mack", "Diagnostic d'echelle",
      fonction = "mw_tests",
      type = "diagnostic", estim_nom = "var(residus)", estim = stats::var(r),
      detail = sprintf(paste("Valeur de reference %s%s : sigma2_j etant",
                             "l'estimateur de Mack, somme_i r(i,j)^2 = n_j - 1",
                             "exactement dans chaque colonne, la somme des carres",
                             "vaut N - k = %d - %d = %d et var(r) est contrainte par",
                             "construction. Cette ligne ne teste donc PAS la structure",
                             "de variance -- mesure : une variance en C^2 au lieu de",
                             "C^1 laisse var(r) a 2,5e-03 de la reference, quand",
                             "l'identite tient a 1e-15. L'ecart a la reference vaut",
                             "exactement N moyenne(r)^2/(N-1) : ce que cette ligne",
                             "donne a lire est le CENTRAGE des residus, ici %s, et la",
                             "coherence interne de la standardisation. La structure de",
                             "variance est testee par Breusch-Pagan et par l'exposant",
                             "de variance par colonne."),
                       format(var_attendue, digits = 6),
                       # k = 1 : (N - k)/(N - 1) = 1, "et NON 1" serait faux (#60, R5)
                       if (k_col == 1L) "" else ", et NON 1", n, k_col, n - k_col,
                       format(mean(r), digits = 3)))

  ## --- M3 : independance des annees d'accident et de developpement ----------
  fam <- "M3. independance (annexe XVII D(2)(h)(i) et (ii))"
  cal <- mw_test_annees_calendaires(aj)
  # p_min (#115) : n_k des diagonales retenues (n_k >= 2) ; les etiquettes "*"
  # (ex aequo a la mediane) sont deja ecartees des n_k.
  pm_cal <- .mw_p_min_ligne(is.finite(cal$stat),
                            if (is.null(cal$detail)) numeric(0) else unname(cal$detail[, "n"]),
                            "diagonales n_k", .mw_calendrier_p_min)
  add(fam, "Effets d'annee calendaire (test de Mack)",
      fonction = "mw_test_annees_calendaires",
      "Mack (1994), Insurance: Mathematics and Economics 15, 133-138",
      H0 = "absence d'effet d'annee calendaire (diagonales homogenes)",
      H1 = "une ou plusieurs diagonales atypiques (inflation, changement de cadence)",
      stat_nom = "Z centre reduit", stat = cal$stat,
      loi = "N(0,1) approx. ; moments EXACTS de Z = min(L, n-L)",
      estim_nom = "Z observe", estim = cal$Z,
      p_as = cal$p, mc_nom = "Calendrier",
      p_min = pm_cal$p_min, effectifs = pm_cal$effectifs,
      detail = "Les diagonales representent les exercices comptables : un effet calendaire viole l'independance des annees d'accident")
  ka <- mw_test_homogeneite_accident(aj)
  pm_ka <- .mw_p_min_ligne(is.finite(ka$stat), ka$tailles, "residus par annee de survenance",
                           .mw_kruskal_p_min, isTRUE(ka$ex_aequo))
  add(fam, "Homogeneite des residus entre annees de survenance",
      fonction = "mw_test_homogeneite_accident",
      "Kruskal & Wallis (1952), JASA 47, 583-621",
      H0 = "les residus de Mack ont la meme distribution dans toutes les lignes",
      H1 = "au moins une annee de survenance se comporte differemment",
      stat_nom = "H", stat = ka$stat,
      loi = if (isTRUE(ka$un_par_annee)) "degeneree : H = N - 1 par construction" else
        sprintf("chi2(%s) approx. -> Monte-Carlo",
                ifelse(is.na(ka$ddl), "k-1", as.character(ka$ddl))),
      p_as = ka$p, mc_nom = "KruskalAcc",
      p_min = pm_ka$p_min, effectifs = pm_ka$effectifs,
      # Un residu par annee de survenance (#60, decision du mainteneur du
      # 06/10/2026) : la phrase precede le detail ; le motif R1 eventuel
      # reste en tete, pose par add().
      detail = paste0(if (isTRUE(ka$un_par_annee)) paste0(
        "Un residu de Mack par annee de survenance : H = N - 1 par construction ",
        "(groupes de taille 1), quelle que soit la donnee ; ",
        "H ne mesure rien ici. ") else "",
        "Traduction testable de l'independance des annees de survenance, D(2)(h)(i)"))
  cor <- mw_stat_correlation_dev(aj)
  pm_cor <- .mw_p_min_ligne(is.finite(cor$stat), cor$poids + 1, "paires de colonnes n_k",
                            .mw_corr_p_min, isTRUE(cor$ex_aequo))
  add(fam, "Correlation entre annees de developpement adjacentes",
      fonction = "mw_stat_correlation_dev",
      "Mack (1993, 1997), ASTIN Bulletin ; correlation de rang de Spearman",
      H0 = "facteurs de developpement successifs non correles",
      H1 = "correlation entre colonnes adjacentes",
      stat_nom = "rho agrege", stat = cor$stat,
      loi = "depend de la geometrie du triangle -> Monte-Carlo", mc_nom = "CorrDev",
      p_min = pm_cor$p_min, effectifs = pm_cor$effectifs,
      detail = "Une correlation positive signale une dependance entre cadences successives")
  add(fam, "Autocorrelation des residus (Durbin-Watson)",
      fonction = "stat_dw",
      "Durbin & Watson (1950, 1951)",
      H0 = "residus de Mack non autocorreles", H1 = "autocorrelation residuelle",
      stat_nom = "DW", stat = stat_dw(r),
      loi = "residus de triangle -> Monte-Carlo", mc_nom = "DW")
  ru <- test_runs(r)
  # p_min (#115) : runs_p_min() aux effectifs de part et d'autre de la mediane.
  eff_ru <- .runs_effectifs(r)
  pm_ru <- .mw_p_min_ligne(is.finite(ru$stat), eff_ru, NULL,
                           function(n) runs_p_min(n[[1]], n[[2]]))
  add(fam, "Test des suites sur les residus de Mack",
      fonction = "test_runs",
      "Wald & Wolfowitz (1940)",
      H0 = "arrangement aleatoire des signes des residus", H1 = "arrangement non aleatoire",
      stat_nom = "Z", stat = ru$stat, loi = "N(0,1) approx. -> Monte-Carlo",
      estim_nom = "nb de suites", estim = ru$runs,
      p_as = ru$p, mc_nom = "Runs",
      p_min = pm_ru$p_min, effectifs = pm_ru$effectifs)

  ## --- M4 : points aberrants ------------------------------------------------
  fam <- "M4. points aberrants et stabilite"
  gr <- test_grubbs(r)
  add(fam, "Cellule aberrante du triangle (Grubbs)",
      fonction = "test_grubbs",
      "Grubbs (1950, 1969), Technometrics 11",
      H0 = "aucun residu de Mack aberrant", H1 = "exactement un residu aberrant",
      stat_nom = "G", stat = gr$stat, loi = "Student + Bonferroni -> Monte-Carlo",
      estim_nom = "rang du residu extreme", estim = gr$idx,
      p_as = gr$p, mc_nom = "Grubbs",
      detail = if (is.finite(gr$idx) && gr$idx <= nrow(res))
        sprintf("residu le plus extreme : annee d'accident %d, developpement %d",
                res$i[gr$idx], res$j[gr$idx]) else "")
  ro <- test_rosner(r, alpha = alpha)
  add(fam, "Cellules aberrantes multiples (ESD generalise)",
      fonction = "test_rosner",
      "Rosner (1983), Technometrics 25", type = "procedure de decision",
      H0 = "aucun residu aberrant", H1 = "il existe i <= k residus aberrants",
      estim_nom = "nb de cellules aberrantes", estim = ro$nb_outliers,
      detail = sprintf("procedure a niveau alpha = %.2f (aucune p-value)", alpha),
      verdict = if (ro$nb_outliers >= 2) "ECHEC" else if (ro$nb_outliers == 1) "ALERTE" else "OK")

  ## --- M5 : normalite, DIAGNOSTIC seulement ---------------------------------
  fam <- "M5. normalite des residus (diagnostic, NON exige par le modele)"
  sw <- .shapiro_sur(r)
  add(fam, "Shapiro-Wilk sur les residus de Mack",
      fonction = ".shapiro_sur",
      "Shapiro & Wilk (1965) ; loi nulle evaluee par simulation directe",
      H0 = "les residus de Mack sont normaux", H1 = "loi non normale",
      stat_nom = "W", stat = sw$stat,
      loi = "loi exacte de W sous normalite, evaluee numeriquement",
      p_ex = sw_p_loi_nulle(sw$stat, n),
      detail = paste("L'annexe XVII, D(2)(h), ne specifie que les DEUX PREMIERS MOMENTS :",
                     "la normalite n'est pas requise par la methode. Ce test n'est pertinent",
                     "que si l'on souhaite exploiter la MSEP pour un quantile."))
  add(fam, "Lilliefors sur les residus de Mack",
      fonction = "stat_lilliefors",
      "Lilliefors (1967) ; p-value : Dallal & Wilkinson (1986)",
      variante = "secondaire",
      H0 = "les residus de Mack sont normaux", H1 = "loi non normale",
      stat_nom = "D", stat = stat_lilliefors(r),
      loi = "loi de Lilliefors (parametres estimes)",
      p_as = lillie_p(stat_lilliefors(r), n))

  ## --- M6 : robustesse de l'estimation --------------------------------------
  fam <- "M6. robustesse de l'estimation"
  # Restitution des trois arguments du minimum du texte et de celui qui est
  # retenu : c'est ce qui permet au relecteur de refaire le calcul a la main.
  ex <- mw_extrapolation_sigma2(aj)
  add(fam, "Extrapolation de sigma pour la derniere annee de developpement",
      fonction = "mw_ajuster",
      "Annexe XVII, D(5)(d)(ii), seconde ligne", type = "diagnostic",
      estim_nom = "sigma2_(J-1)", estim = aj$sigma2[aj$J],
      detail = .mw_detail_extrapolation(ex))
  # ADR 0001 : un diagnostic n'a pas de verdict (il est affiche INFO). Le seuil
  # de 40 % qui figurait ici n'est ni un niveau de test ni une regle de
  # l'annexe XVII : le rendre en ALERTE / OK donnait a une convention
  # d'affichage l'apparence d'une conclusion au seuil alpha, alors que la
  # ligne voisine de la meme famille sort bien en INFO. Le verdict n'est plus
  # force ; add() applique INFO de lui-meme. La part et le repere de 40 %
  # restent restitues dans le detail, ou leur statut est nomme.
  part_derniere <- aj$reserve_par_annee[aj$I + 1] / aj$reserve
  add(fam, "Part de la reserve portee par la derniere annee d'accident",
      fonction = "mw_tests",
      "Diagnostic de concentration", type = "diagnostic",
      estim_nom = "part", estim = part_derniere,
      detail = sprintf(paste("part = %.1f %% de la reserve totale. Une part elevee concentre la",
                             "MSEP sur la ligne la moins developpee du triangle, dont les",
                             "facteurs sont les plus extrapoles. Repere indicatif de 40 %%,",
                             "sans fondement reglementaire ni statistique : il n'emporte aucun",
                             "verdict."), 100 * part_derniere))
  reg$lignes()
}


## =============================================================================
## 11. ORCHESTRATEUR PRINCIPAL
## =============================================================================

# B minimal en fonction du seuil alpha (#127, note d'actuary et decisions du
# mainteneur du 28/09/2026). Le plancher de la p-value Monte-Carlo
# bilaterale (queue "deux" de engine_p_mc(), N = 0 depassement, B_eff = B)
# vaut 2 * (1 / (B + 1)) ; la regle des verdicts de engine_registre_tests()
# (sens "ne pas rejeter") rend ECHEC si p < alpha/2. L'ECHEC d'une ligne dont
# la seule p-value est Monte-Carlo n'est atteignable que si
# 2 * (1 / (B + 1)) < alpha / 2, soit B + 1 > 4/alpha (inegalite stricte : a
# egalite, p = alpha/2 donne ALERTE). La condition bilaterale, la plus
# contraignante, vaut pour toute la table (les deux catalogues ont des
# statistiques bilaterales ; les lignes unilaterales ont un plancher
# 1/(B + 1) < alpha/4). Elle est ecrite dans l'arithmetique flottante de la
# regle des verdicts, et non comme 4/alpha, pour qu'aucune divergence ne soit
# possible entre le controle d'entree et le verdict (mesure du 01/10/2026 :
# a alpha = 0,00128 et B = 3124, 4/alpha vaut 3124,9999999999995 en double,
# B + 1 > 4/alpha est vrai mais 2 * (1 / (B + 1)) < alpha / 2 est faux,
# 2/3125 etant egal a alpha/2 en double ; engine_b_minimal(0.00128) rend
# 3125). Limite : le controle porte sur B nominal ; le plancher reel est
# 2/(B_eff + 1).
# engine_b_minimal(alpha) : plus petit entier B >= 1 tel que
# 2 * (1 / (B + 1)) < alpha / 2 (borne pure d'alpha, sans le max avec
# B_MIN_USAGE). Ne sert qu'au message de engine_motif_b_alpha() : l'admission
# de B y est decidee directement par la condition, sans ce calcul. Recherche
# bornee autour de 4/alpha (au plus quatre essais) ; erreur explicite si
# 4/alpha n'est pas fini ou n'est pas < 2^52 (au-dela, b + 1 n'est plus
# exact en double : revue d'audit de #127, boucle sans fin a alpha = 1e-16)
# ou si aucun essai ne convient. alpha : nombre scalaire fini > 0.
engine_b_minimal <- function(alpha) {
  if (!is.numeric(alpha) || length(alpha) != 1L || !is.finite(alpha) || alpha <= 0)
    stop("engine_b_minimal() : alpha doit etre un nombre scalaire fini > 0.", call. = FALSE)
  q <- 4 / alpha
  if (!(is.finite(q) && q < 2^52))
    stop(sprintf(paste("engine_b_minimal() : 4/alpha = %g, non fini ou >= 2^52 : B minimal",
                       "non calculable exactement en double (alpha = %g)."),
                 q, alpha), call. = FALSE)
  b <- max(1, floor(q) - 1)
  for (k in 1:4) {
    if (2 * (1 / (b + 1)) < alpha / 2) return(b)
    b <- b + 1
  }
  stop(sprintf("engine_b_minimal() : B minimal introuvable pour alpha = %g.", alpha),
       call. = FALSE)
}

# Motif du refus de B au seuil alpha (#127) : NULL si 2 * (1 / (B + 1)) <
# alpha / 2 (condition testee directement, dans l'arithmetique de la regle
# des verdicts d'add(), sans calcul de B minimal ni boucle), sinon le message
# de l'erreur d'usage, chaine ASCII unique. Seule source du texte :
# .engine_verifier_usage() le leve par stop() ; app.R l'affiche tel quel
# avant le clic, sans recalculer la regle. Rend NULL hors du domaine de la
# regle (B non scalaire fini, alpha hors de ]0, SEUIL_ECHEC_SENS_REJETER[)
# et pour B < B_MIN_USAGE (decision du mainteneur du 28/09/2026, avis
# d'actuary) : ces saisies relevent des controles de B et d'alpha, faits
# avant, et le bandeau de l'application concorde ainsi avec l'erreur levee
# au clic. Le B minimal cite est formate par %.0f ; s'il n'est pas calculable
# (engine_b_minimal() en erreur, alpha tres petit), le message ne cite pas
# de valeur.
engine_motif_b_alpha <- function(B, alpha) {
  scalaire_fini <- function(v) is.numeric(v) && length(v) == 1L && is.finite(v)
  if (!scalaire_fini(B) || !scalaire_fini(alpha) || alpha <= 0 ||
      alpha >= SEUIL_ECHEC_SENS_REJETER || B < B_MIN_USAGE) return(NULL)
  if (2 * (1 / (B + 1)) < alpha / 2) return(NULL)
  b_min <- tryCatch(engine_b_minimal(alpha), error = function(e) NULL)
  seuil_b <- if (is.null(b_min)) "B trop petit pour ce seuil" else
    sprintf("soit B >= %.0f a ce seuil", b_min)
  # Valeurs citees par .engine_saisie(), comme par saisie() de
  # .engine_verifier_usage() (15 chiffres, 17 si l'ecriture a 15 chiffres ne
  # restitue pas la valeur, #133), apres conversion en double : un entier
  # (99L, forme possible d'une saisie numerique transmise par l'application)
  # est cite 99, comme le double 99.
  saisie <- function(v) .engine_saisie(as.double(v))
  sprintf(paste("B = %s et alpha = %s : B + 1 > 4/alpha est requis, %s",
                "(en plus de B >= B_MIN_USAGE = %.0f). Le plancher bilateral de la p-value",
                "Monte-Carlo, 2/(B+1) = %.4g, n'est pas inferieur a alpha/2 = %.4g :",
                "l'ECHEC des tests dont la seule p-value est Monte-Carlo serait",
                "inatteignable (regle des verdicts d'engine_registre_tests())."),
          saisie(B), saisie(alpha), seuil_b, B_MIN_USAGE,
          2 * (1 / (B + 1)), alpha / 2)
}

# Arguments d'usage de run_engine() resolus avant le calcul protege (issue
# #88) : une valeur invalide leve une erreur R explicite, comme avant #88,
# et n'est jamais rendue en defaut de calcul intercepte. Sont refusees les
# valeurs qui faisaient deja echouer le calcul (mesure sur la tete 5fe3d67 :
# B = -1, NA, Inf, "a", "5", NULL, c(9, 19) levaient une erreur dans le
# bootstrap ; seed NA dans set.seed()), plus B logique (TRUE etait calcule
# comme B = 1) ; B = 0 et B = 10.5 etaient calcules (refuses depuis le
# constat C1 de la revue finale d'E1 et le constat m1 de l'audit leger, #44).
# - B : nombre scalaire fini entier >= B_MIN_USAGE (constat m1, #44 : B = 99.5
#   etait accepte, consigne tel quel dans metadata$B et bootstrap$B, pour 99
#   tirages effectifs) ;
# - seed : nombre scalaire fini entier, |seed| <= .Machine$integer.max
#   (domaine de set.seed()) ; NULL est refuse (decision du mainteneur du
#   26/09/2026) : set.seed(NULL) reinitialise le generateur au hasard et rend
#   le calcul non reproductible ;
# - bareme : "court" ou "long" exactement (annexe XVII, section G), ou NULL
#   (deduit du segment) ;
# - alpha : nombre scalaire fini, 0 < alpha < SEUIL_ECHEC_SENS_REJETER (avis
#   d'actuary) : au-dela, la zone ALERTE des tests en sens rejeter disparait ;
# - B et alpha conjointement (#127) : B + 1 > 4/alpha, soit
#   B >= engine_b_minimal(alpha), en plus de B >= B_MIN_USAGE ; faute de quoi
#   l'ECHEC des lignes a p-value Monte-Carlo seule est inatteignable
#   (engine_motif_b_alpha()) ;
# - sigma_standard : NULL (valeur de l'annexe), ou nombre scalaire fini > 0 ;
# - segment et annexe (revue finale de #88, constat 4) : un segment fourni
#   doit etre un nombre scalaire fini entier sans attribut (#105,
#   .segment_verifie()) et exister dans l'annexe (usp_segment_infos()), et
#   il faut segment ou sigma_standard. Ces controles etaient faits apres la
#   validation des donnees, dans chaque branche : le meme appel levait une
#   erreur R sur des donnees valides et rendait ok = FALSE sur des donnees
#   refusees. Faits ici, ils levent une erreur R quelles que soient les
#   donnees.
# Aucune de ces valeurs ne doit porter d'attribut (noms, dim...) : refusee
# plutot que normalisee, car l'attribut etait propage tel quel dans le
# resultat (mesure sur la tete 743bb75 : B = c(a = 19), alpha = c(a = 0.1),
# bareme = c(a = "court") nommes dans metadata, seed = matrix(5) en matrice
# dans metadata$seed, sigma_standard = c(a = 0.1) nomme dans sigma_usp), et
# qu'une normalisation silencieuse masquerait l'erreur de l'appelant.
# Suite de #88 (decision du mainteneur du 26/09/2026) : alpha, sigma_standard
# et une graine invalides (NA, texte, vecteur, hors domaine) etaient rendus en
# defaut de calcul intercepte (alpha NA dans usp_tests(), mw_tests() ;
# sigma_standard "a" dans usp_parametre()), ou calcules (alpha 0, 1, -0,1 ;
# sigma_standard 0, -0,1, Inf, NA ; seed NULL, "5", 1.5, c(1, 2) ; bareme
# "co", c("court", "long"), completes par match.arg()), ou refuses par un
# message de R (seed NA, Inf, 3e9 ; bareme NA, 1, "moyen"). La graine n'est
# plus essayee sous engine_sous_graine() : toute valeur qui passe le controle
# est acceptee par set.seed(). theta_equiv n'est pas controle ici : dans la
# branche lognormale (premium et reserve1), il l'est par
# engine_valider_donnees() (refus ok = FALSE, issue #33), qui l'ignore quand
# delta_equiv est fourni ; seule la branche Merz-Wuthrich (reserve2) ne le lit
# pas.
.engine_verifier_usage <- function(B, seed, bareme, alpha = 0.10,
                                   sigma_standard = NULL, segment = NULL,
                                   annexe = "II") {
  saisie <- .engine_saisie
  sans_attribut <- function(v) is.null(attributes(v))
  scalaire_fini <- function(v) is.numeric(v) && length(v) == 1L && is.finite(v) &&
                                 sans_attribut(v)
  if (!scalaire_fini(B) || B != round(B) || B < B_MIN_USAGE)
    stop(sprintf(paste("B = %s : un nombre scalaire fini entier de replications, B >=",
                       "B_MIN_USAGE = %d, sans attribut, est attendu."),
                 saisie(B), B_MIN_USAGE), call. = FALSE)
  if (!scalaire_fini(seed) || seed != round(seed) || abs(seed) > .Machine$integer.max)
    stop(sprintf(paste("seed = %s : un nombre scalaire fini entier, |seed| <= %d, sans",
                       "attribut, est attendu (NULL refuse : calcul non reproductible)."),
                 saisie(seed), .Machine$integer.max), call. = FALSE)
  if (!is.null(bareme) &&
      !(is.character(bareme) && length(bareme) == 1L && !is.na(bareme) &&
        sans_attribut(bareme) && bareme %in% c("court", "long")))
    stop(sprintf(paste("bareme = %s : NULL, \"court\" ou \"long\" (sans attribut) est",
                       "attendu (bareme de credibilite de l'annexe XVII, section G)."),
                 saisie(bareme)), call. = FALSE)
  if (!scalaire_fini(alpha) || alpha <= 0 || alpha >= SEUIL_ECHEC_SENS_REJETER)
    stop(sprintf(paste("alpha = %s : un nombre scalaire fini, sans attribut,",
                       "0 < alpha < SEUIL_ECHEC_SENS_REJETER = %s, est attendu ; au-dela,",
                       "la zone ALERTE des tests en sens rejeter disparait et le verdict",
                       "ne suit plus la regle documentee."),
                 saisie(alpha), format(SEUIL_ECHEC_SENS_REJETER)), call. = FALSE)
  # B minimal fonction d'alpha (#127) : apres les controles de B et d'alpha,
  # dont les messages restent inchanges pour une valeur invalide isolement.
  motif_b_alpha <- engine_motif_b_alpha(B, alpha)
  if (!is.null(motif_b_alpha)) stop(motif_b_alpha, call. = FALSE)
  if (!is.null(sigma_standard) && (!scalaire_fini(sigma_standard) || sigma_standard <= 0))
    stop(sprintf(paste("sigma_standard = %s : NULL ou un nombre scalaire fini,",
                       "sans attribut, sigma_standard > 0, est attendu."),
                 saisie(sigma_standard)), call. = FALSE)
  # Segment : usp_segment_infos() leve l'erreur d'usage de .segment_verifie()
  # (valeur non scalaire, vide, NA, non entiere ou non numerique, #105), puis
  # celle du segment inconnu de l'annexe (message inchange).
  if (!is.null(segment)) usp_segment_infos(segment, annexe)
  else if (is.null(sigma_standard))
    stop("Fournir soit sigma_standard, soit segment (avec son annexe).")
  invisible(TRUE)
}

# Calcul protege (issue #88, decision du mainteneur du 26/09/2026 : filet
# limite au calcul). expr est le calcul qui suit une validation reussie
# (branche lognormale apres engine_valider_donnees(), branche Merz-Wuthrich
# apres mw_valider_triangle()). Une erreur R qui s'y produit est un DEFAUT
# DE CALCUL INTERCEPTE, non un refus de donnees : le resultat porte ok =
# FALSE, un motif neutre et fixe dans validation$erreurs (seul le nom de la
# fonction d'origine y est variable) et le diagnostic dans
# validation$erreur_r = list(message, appel, origine, pile) :
#   message : conditionMessage() (traduit selon la locale) ;
#   appel   : conditionCall(), deparse (premiere ligne), NA s'il n'y en a pas ;
#   pile    : noms des fonctions appelees depuis le calcul protege jusqu'au
#             point de l'erreur (sys.calls() capture par withCallingHandlers,
#             avant le deroulement de la pile), sans les cadres de
#             tryCatch() et de signalement ;
#   origine : derniere fonction de la pile DEFINIE DANS LE MOTEUR (son nom
#             designe, dans l'environnement de run_engine(), la fonction
#             meme qui s'executait dans ce cadre) ; a defaut, dernier
#             element de la pile. Les fonctions de R et les fermetures
#             creees en cours de calcul (add() de engine_registre_tests())
#             ne sont pas retenues : une erreur nee dans un argument
#             evalue paresseusement (argument de sprintf() dans add()) ou
#             dans une fonction de R appelee par le moteur (lm.fit()) est
#             attribuee a la fonction du moteur qui la porte.
# Resultat : meme forme que le refus de .run_engine_mw() (ok, validation,
# methode, metadata$horodatage, metadata$methode). Aucun resultat partiel.
# Les avertissements R ne sont pas captures. Option de developpement
# options(usp.engine.lever_erreurs = TRUE) : l'erreur est relevee telle
# quelle, sans interception. Les graines sont restaurees par
# engine_sous_graine() (on.exit) lors du deroulement de la pile.
.engine_calcul_protege <- function(methode, t0, validation, expr) {
  if (isTRUE(getOption("usp.engine.lever_erreurs", FALSE))) return(expr)
  niveau <- sys.nframe()
  pile <- character(0)
  du_moteur <- logical(0)
  env_moteur <- environment(run_engine)
  internes <- c("tryCatch", "tryCatchList", "tryCatchOne", "doTryCatch",
                "withCallingHandlers", ".handleSimpleError", "h", "stop",
                "signalCondition", ".signalSimpleWarning")
  tryCatch(
    withCallingHandlers(expr, error = function(e) {
      cs <- sys.calls()
      # Cadres propres au calcul : apres celui de .engine_calcul_protege(),
      # sans le dernier (ce gestionnaire).
      idx <- which(seq_along(cs) > niveau & seq_along(cs) < length(cs))
      cs <- cs[idx]
      # Nom de la fonction appelee ; "stats::lm" pour un appel qualifie.
      noms <- vapply(cs, function(cl) {
        f <- cl[[1]]
        if (is.name(f)) as.character(f)
        else if (is.call(f) && as.character(f[[1]])[1] %in% c("::", ":::"))
          paste(deparse(f), collapse = "")
        else "(fonction anonyme)"
      }, "")
      # Fonction du moteur : nom present dans l'environnement du moteur et
      # designant la fonction meme executee dans le cadre.
      moteur <- vapply(seq_along(cs), function(k) {
        exists(noms[k], envir = env_moteur, mode = "function", inherits = FALSE) &&
          identical(get(noms[k], envir = env_moteur, mode = "function", inherits = FALSE),
                    sys.function(idx[k]))
      }, logical(1))
      garde <- !noms %in% internes
      pile <<- noms[garde]
      du_moteur <<- moteur[garde]
    }),
    error = function(e) {
      appel <- conditionCall(e)
      origine <- if (any(du_moteur)) pile[max(which(du_moteur))]
                 else if (length(pile)) pile[length(pile)] else NA_character_
      motif <- paste0("Defaut de calcul intercepte",
                      if (!is.na(origine)) sprintf(" (erreur R dans %s())", origine) else " (erreur R)",
                      " : aucun resultat n'est produit ; diagnostic dans validation$erreur_r.")
      validation$ok <- FALSE
      validation$erreurs <- c(validation$erreurs, motif)
      validation$erreur_r <- list(
        message = conditionMessage(e),
        appel = if (is.null(appel)) NA_character_ else deparse(appel, nlines = 1L)[1],
        origine = origine,
        pile = pile)
      structure(list(ok = FALSE, validation = validation, methode = methode,
                     metadata = list(horodatage = t0, methode = methode)),
                class = "usp_engine")
    })
}

# run_engine() : lance toute la chaine de calcul a partir des donnees brutes et
# des parametres utilisateur, et retourne un objet structure contenant
# l'integralite des resultats necessaires a l'application.
#
# Arguments
#   xt, yt         vecteurs numeriques de meme longueur (primes / pertes, ou
#                  provision d'ouverture / montant de liquidation)
#   methode        "premium" ou "reserve1"
#   segment        segment de l'annexe II (1 a 12) ; sert a determiner
#                  sigma_standard et le bareme de credibilite
#   sigma_standard ecart-type standard ; s'il est fourni, il prime sur `segment`
#                  (saisie libre : derogation au parametre reglementaire,
#                  signalee par metadata$sigma_standard_saisi, issue #55) ;
#                  nombre scalaire fini > 0
#   nature_donnees "brutes" ou "nettes" (de reassurance) ; OBLIGATOIRE pour
#                  "premium", sans defaut (issue #55, M13) : sans elle, ok =
#                  FALSE ; methodes de reserve : NULL ou "nettes" acceptes,
#                  "brutes" refuse (ok = FALSE, C(2)(c), D(2)(f))
#   T              profondeur retenue (les T dernieres annees) ; NULL = tout ;
#                  sinon entier scalaire fini, 5 <= T <= nombre d'annees, et
#                  toute autre valeur donne ok = FALSE, sans troncature
#                  (engine_valider_profondeur(), issue #87) ; le nombre
#                  d'annees fournies est restitue par metadata$n_fournies, et
#                  une troncature (n_fournies > T) par une ligne "profondeur"
#                  de engine_derogations() (issue #104)
#   B              nombre de replications bootstrap / Monte-Carlo ; nombre
#                  scalaire fini entier >= B_MIN_USAGE = 99
#                  (.engine_verifier_usage())
#   alpha          seuil des verdicts, 0 < alpha < SEUIL_ECHEC_SENS_REJETER
#   seed           graine des simulations (reproductibilite) ; entier scalaire
#                  fini, |seed| <= .Machine$integer.max (NULL refuse)
#   bareme         "court" ou "long" exactement ; NULL = deduit du segment
#                  (usp_bareme_segment() ; "court" par convention sans
#                  segment, bareme non determine par la section G) ; saisie
#                  libre : derogation au bareme de la section G, signalee
#                  par metadata$bareme_saisi (issue #93), meme egale au
#                  bareme du segment
#
# Valeur : liste de classe "usp_engine" (voir la structure en fin de fonction).
# Erreurs (issue #88) : un argument d'usage invalide (methode, annexe,
# segment inconnu, ni segment ni sigma_standard, xt manquant, B, seed,
# bareme, alpha, sigma_standard, reserve no 2 sans triangle ;
# .engine_verifier_usage()) leve une erreur R explicite ; des
# donnees refusees par la validation donnent ok = FALSE ; une erreur R levee
# par le calcul qui suit une validation reussie est un DEFAUT DE CALCUL
# INTERCEPTE (.engine_calcul_protege()) : ok = FALSE, motif neutre dans
# validation$erreurs, diagnostic dans validation$erreur_r.
# Orchestrateur de la methode du risque de reserve no 2. Retourne un objet de
# meme classe et de meme forme generale que la branche lognormale, afin que la
# couche d'affichage puisse le consommer sans traitement particulier.
.run_engine_mw <- function(triangle, segment, annexe, sigma_standard,
                           B, alpha, seed, bareme, t0, nature_donnees = NULL) {
  if (is.null(triangle))
    stop("La methode du risque de reserve no 2 exige un triangle de paiements cumules.")
  triangle <- as.matrix(triangle)
  # Bareme saisi transmis tel quel (NULL sinon), avec le segment et l'annexe :
  # l'avertissement de credibilite partielle lit le bareme applique (#131).
  validation <- mw_valider_triangle(triangle, bareme = bareme, segment = segment,
                                    annexe = annexe)
  # Nature declaree (issue #55) : des donnees "brutes" sont refusees, D(2)(f)
  # exigeant des montants ajustes de la reassurance (.nature_erreurs()).
  err_nature <- .nature_erreurs("reserve2", nature_donnees)
  if (length(err_nature)) {
    validation$ok <- FALSE
    validation$erreurs <- c(err_nature, validation$erreurs)
  }
  if (!validation$ok)
    return(structure(list(ok = FALSE, validation = validation, methode = "reserve2",
                          metadata = list(horodatage = t0, methode = "reserve2")),
                     class = "usp_engine"))

  # Segment connu, ou sigma_standard fourni : deja verifie avant la
  # validation du triangle par .engine_verifier_usage() (constat 4 de la
  # revue finale de #88) ; le stop() ci-dessous n'est plus atteint depuis
  # run_engine().
  infos <- if (!is.null(segment)) usp_segment_infos(segment, annexe) else NULL
  # Saisie libre du sigma standard : derogation au parametre reglementaire,
  # restituee par metadata$sigma_standard_saisi (issue #55).
  saisi <- !is.null(sigma_standard)
  if (is.null(sigma_standard)) {
    if (is.null(infos)) stop("Fournir soit sigma_standard, soit segment (avec son annexe).")
    sigma_standard <- infos$sigma_reserve      # methode de reserve : sigma(res,s)
  }
  # Saisie libre du bareme : derogation au bareme de la section G, restituee
  # par metadata$bareme_saisi (issue #93), meme egale au bareme du segment.
  saisi_bareme <- !is.null(bareme)
  if (is.null(bareme)) bareme <- usp_bareme_segment(segment, annexe)

  # --- Calcul protege (issue #88) : ajustement et sorties, apres
  # mw_valider_triangle() et la resolution des arguments d'usage. Une erreur R
  # y est un defaut de calcul intercepte (.engine_calcul_protege()) ; le
  # refus de mw_valider_ajustement() garde son return() (ok = FALSE).
  # L'argument validation de .engine_calcul_protege() est une promesse
  # evaluee a sa premiere utilisation, a l'entree du gestionnaire d'erreur,
  # donc apres que le calcul l'a modifiee ici : un defaut intercepte garde
  # les avertissements de mw_valider_ajustement().
  .engine_calcul_protege("reserve2", t0, validation, {
    aj   <- mw_ajuster(triangle)
    msep <- mw_msep(aj)
    # Second controle de validite metier, impossible avant l'ajustement : la
    # reserve totale et la MSEP conditionnent l'existence meme de sigma(res,s,USP)
    # (voir mw_valider_ajustement). Il est place ici, avant tout calcul de
    # parametre ou de bootstrap, pour renvoyer ok = FALSE avec la validation
    # plutot que de lever une erreur, comme la branche lognormale le fait pour
    # des donnees invalides.
    vc <- mw_valider_ajustement(aj, msep$msep)
    # Les avertissements du second controle (extrapolation de sigma2_(J-1) sur
    # une colonne degeneree) rejoignent ceux du premier, que le triangle soit
    # accepte ou refuse.
    validation$avertissements <- c(validation$avertissements, vc$avertissements)
    if (!vc$ok) {
      validation$ok <- FALSE
      validation$erreurs <- c(validation$erreurs, vc$erreurs)
      return(structure(list(ok = FALSE, validation = validation, methode = "reserve2",
                            metadata = list(horodatage = t0, methode = "reserve2")),
                       class = "usp_engine"))
    }

    par  <- mw_parametre(aj, msep$msep, sigma_standard, bareme)
    boot <- mw_bootstrap(aj, B = B, seed = seed)
    tests <- mw_tests(aj, boot, alpha)
    res   <- mw_residus(aj)
    # L'exclusion de colonnes est restituee par l'avertissement de
    # mw_valider_ajustement() ; l'attribut n'est pas stocke dans le resultat
    # (structure des references inchangee, issue #33).
    attr(res, "colonnes_exclues") <- NULL

    ic <- if (length(boot$sigma_boot) > 20)
      stats::quantile(par$credibilite * boot$sigma_boot +
                      (1 - par$credibilite) * sigma_standard,
                      c(.025, .05, .5, .95, .975)) else NULL

    descriptif <- data.frame(
      grandeur = c("Annees d'accident (I+1)", "Annees de developpement (J+1)",
                   "Cellules observees", "Dernier cumul total", "Ultime total",
                   "Reserve totale", "racine(MSEP) a un an", "CV a un an"),
      valeur = c(aj$I + 1, aj$J + 1, sum(!is.na(triangle)),
                 sum(aj$dernier_observe), sum(aj$ultime), aj$reserve,
                 par$racine_msep, par$sigma_estime),
      stringsAsFactors = FALSE)

    calibration <- data.frame(
      etape = c("Reserve chain-ladder totale", "MSEP a un an",
                "racine(MSEP)", "sigma estime = racine(MSEP) / reserve",
                "facteur de credibilite c", "sigma standard (formule standard)",
                "sigma_USP = c*sigma_estime + (1-c)*sigma_standard"),
      valeur = c(aj$reserve, msep$msep, par$racine_msep, par$sigma_estime,
                 par$credibilite, sigma_standard, par$sigma_usp),
      stringsAsFactors = FALSE)

    candidats <- data.frame(
      variante = c("sigma standard (aucun USP)", "sigma estime seul (credibilite 100%)",
                   "sigma_USP retenu (annexe XVII)"),
      valeur = c(sigma_standard, par$sigma_estime, par$sigma_usp),
      retenu = c(FALSE, FALSE, TRUE), stringsAsFactors = FALSE)

    structure(list(
      ok = TRUE, methode = "reserve2",
      triangle = triangle,
      donnees = data.frame(i = res$i, j = res$j, C = res$C, F = res$F,
                           residu = res$residu),
      validation = validation,
      controles = list(list(test = "Structure du triangle", verdict = "OK",
                            detail = sprintf("I = %d, J = %d, %d cellules observees",
                                             aj$I, aj$J, sum(!is.na(triangle))))),
      statistiques_descriptives = descriptif,
      ajustement = aj, msep = msep, residus = res,
      tests = tests, bootstrap = boot, ic_bootstrap = ic,
      calibration = calibration, candidats = candidats,
      parametre_final = list(sigma_usp = par$sigma_usp,
                             sigma_estime = par$sigma_estime,
                             sigma_estime_brut = par$sigma_estime,
                             correction_taille = 1,
                             credibilite = par$credibilite,
                             sigma_standard = sigma_standard,
                             variation_relative = par$variation_relative),
      plots_data = mw_plots_data(aj, res, boot, msep),
      metadata = list(methode = "reserve2", segment = segment, annexe = annexe,
                      libelle_segment = if (!is.null(infos)) infos$libelle else NA_character_,
                      T = aj$I + 1L, I = aj$I, J = aj$J, B = B, alpha = alpha,
                      seed = seed, bareme = bareme, sigma_standard = sigma_standard,
                      # Place apres les champs anterieurs (issue #55), suivi des
                      # seuls champs de l'issue #37, de bareme_saisi (#93), puis des
                      # champs d'execution.
                      sigma_standard_saisi = saisi,
                      # Generateur pose par engine_sous_graine() et graine fixe
                      # de la loi nulle de Shapiro-Wilk (issue #37, ADR 0004
                      # point 2). Places apres les champs existants, avant les
                      # champs d'execution.
                      generateur = as.list(ENGINE_RNG_KIND),
                      seed_loi_nulle_sw = SEED_LOI_NULLE_SW,
                      # Bareme saisi (issue #93) : place apres les champs de
                      # l'issue #37, en dernier avant les champs d'execution
                      # (le patch des references ajoute la feuille en fin).
                      bareme_saisi = saisi_bareme,
                      # Annees d'accident fournies (issue #104) : lignes du
                      # triangle, jamais tronque (n_fournies = T = I + 1).
                      # Place apres bareme_saisi, avant les champs d'execution.
                      n_fournies = nrow(triangle),
                      horodatage = t0,
                      duree_sec = as.numeric(difftime(Sys.time(), t0, units = "secs")),
                      version_R = R.version.string)
    ), class = "usp_engine")
  })
}

# --- Diagnostics d'influence du triangle (methode Merz-Wuthrich) -------------
# Le facteur de developpement f_j est une moyenne ponderee des facteurs
# individuels F(i,j) = C(i,j+1)/C(i,j), de poids C(i,j) :
#     f_j = somme_i C(i,j) F(i,j) / somme_i C(i,j)
# Le LEVIER exact de la cellule (i,j) dans l'estimation de f_j est donc
#     h(i,j) = C(i,j) / somme_{i'} C(i',j),   de somme 1 par colonne.
# L'INFLUENCE exacte se mesure par le DFBETA obtenu en retirant la cellule :
#     f_j^(-i) = (somme C(.,j+1) - C(i,j+1)) / (somme C(.,j) - C(i,j))
# Ces deux quantites sont calculees exactement, sans reajustement iteratif.
mw_influence <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  out <- data.frame()
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 2) next
    Cij <- tri[idx + 1, j + 1]; Cij1 <- tri[idx + 1, j + 2]
    Sj <- sum(Cij); Sj1 <- sum(Cij1)
    h <- Cij / Sj
    f_sans <- (Sj1 - Cij1) / (Sj - Cij)
    resid <- if (is.finite(aj$sigma2[j + 1]) && aj$sigma2[j + 1] > 0)
      sqrt(Cij) * (Cij1 / Cij - aj$f[j + 1]) / sqrt(aj$sigma2[j + 1]) else rep(NA_real_, length(idx))
    out <- rbind(out, data.frame(
      i = idx, j = j, C = Cij, F = Cij1 / Cij,
      levier = h, seuil_levier = 2 / length(idx),
      f_chapeau = aj$f[j + 1], f_sans_cellule = f_sans,
      dfbeta_relatif = (f_sans - aj$f[j + 1]) / aj$f[j + 1],
      residu = resid, stringsAsFactors = FALSE))
  }
  out$fort_levier <- out$levier > out$seuil_levier
  # Coloration du graphique DFBETA (plot_mw_dfbeta()) : |variation relative
  # de f_j| au-dela du repere de lecture REPERE_DFBETA_MW (issue #33,
  # constat C1 d'app-review).
  out$fort_dfbeta <- abs(out$dfbeta_relatif) > REPERE_DFBETA_MW
  out
}

# Contribution de chaque annee de survenance a la reserve et au terme de
# variance de processus de la MSEP. Il s'agit d'une DECOMPOSITION exacte, non
# d'un leave-one-out : le terme d'erreur d'estimation de la MSEP comporte des
# termes croises, par nature partages entre paires d'annees, et n'est donc pas
# attribuable a une annee isolee. Le denominateur des parts est
# msep$terme_variance, c'est-a-dire la seule variance de processus (voir le
# decoupage documente en tete de mw_msep()), et non la MSEP totale.
mw_contributions <- function(aj, msep) {
  I <- aj$I; J <- aj$J
  Cu <- aj$C_chapeau[, J + 1]; Cd <- aj$dernier_observe
  vterme <- rep(0, I + 1)
  for (i in 1:I) vterme[i + 1] <- Cu[i + 1]^2 * aj$Q[I - i + 1] / Cd[i + 1]
  data.frame(
    i = 0:I,
    reserve = aj$reserve_par_annee,
    part_reserve = aj$reserve_par_annee / aj$reserve,
    terme_variance = vterme,
    part_terme_variance = if (msep$terme_variance > 0)
      vterme / msep$terme_variance else rep(NA_real_, I + 1),
    stringsAsFactors = FALSE)
}

# Quantites numeriques des graphiques de la methode Merz-Wuthrich.
mw_plots_data <- function(aj, res, boot, msep = NULL) {
  qq <- stats::qqnorm(res$residu, plot.it = FALSE)
  list(
    methode = "reserve2",
    facteurs = data.frame(j = 0:(aj$J - 1), f = aj$f,
                          sigma = sqrt(aj$sigma2)),
    reserve_par_annee = data.frame(i = 0:aj$I,
                                   dernier = aj$dernier_observe,
                                   ultime = aj$ultime,
                                   reserve = aj$reserve_par_annee),
    residus = res,
    residus_dev = data.frame(j = res$j, residu = res$residu),
    residus_acc = data.frame(i = res$i, residu = res$residu),
    residus_cal = data.frame(calendrier = res$calendrier, residu = res$residu),
    residus_C = data.frame(C = res$C, residu = res$residu),
    qqnorm = data.frame(theorique = qq$x, empirique = qq$y),
    # Donnees des regressions par annee de developpement : nuages C(i,j+1)
    # contre C(i,j), droite de proportionnalite f_j (sans constante) et droite
    # ajustee avec constante. Toutes les quantites sont calculees ici.
    regressions = local({
      out <- list()
      for (j in 0:(aj$J - 1)) {
        idx <- 0:(aj$I - j - 1)
        if (length(idx) < 2) next
        C0 <- aj$tri[idx + 1, j + 1]; C1 <- aj$tri[idx + 1, j + 2]
        a <- b <- NA_real_
        if (length(idx) >= 3) {
          m <- try(stats::lm(C1 ~ C0, weights = 1 / C0), silent = TRUE)
          if (!inherits(m, "try-error") && length(stats::coef(m)) == 2) {
            a <- unname(stats::coef(m)[1]); b <- unname(stats::coef(m)[2])
          }
        }
        out[[length(out) + 1]] <- list(j = j, i = idx, C0 = C0, C1 = C1,
          f = aj$f[j + 1], a = a, b = b, n = length(idx))
      }
      out
    }),
    alpha = mw_famille_alpha(aj)$detail,
    origine = mw_test_ordonnee_origine(aj)$detail,
    influence = mw_influence(aj),
    contributions = if (!is.null(msep)) mw_contributions(aj, msep) else NULL,
    sigma_boot = boot$sigma_boot
  )
}

run_engine <- function(xt, yt,
                       methode = c("premium", "reserve1", "reserve2"),
                       segment = NULL,
                       annexe = c("II", "XIV"),
                       triangle = NULL,
                       sigma_standard = NULL,
                       T = NULL,
                       B = 999,
                       alpha = 0.10,
                       theta_equiv = 0.10,
                       delta_equiv = NULL,
                       seed = 20260831,
                       bareme = NULL,
                       plus_recent_en_dernier = TRUE,
                       nature_donnees = NULL) {
  t0 <- Sys.time()
  methode <- match.arg(methode)
  annexe  <- match.arg(annexe)
  # Arguments d'usage resolus AVANT le calcul protege (issue #88) : une
  # valeur invalide reste une erreur R explicite, jamais un defaut de calcul
  # intercepte.
  .engine_verifier_usage(B, seed, bareme, alpha = alpha,
                         sigma_standard = sigma_standard, segment = segment,
                         annexe = annexe)

  # --- Branche Merz-Wuthrich (methode du risque de reserve no 2) ------------
  # Cette methode ne prend pas en entree deux vecteurs mais un TRIANGLE de
  # paiements cumules ; la chaine de calcul est entierement distincte.
  if (methode == "reserve2")
    return(.run_engine_mw(triangle = triangle, segment = segment, annexe = annexe,
                          sigma_standard = sigma_standard, B = B, alpha = alpha,
                          seed = seed, bareme = bareme, t0 = t0,
                          nature_donnees = nature_donnees))

  # --- 1. Donnees et controles de validite ---------------------------------
  if (!plus_recent_en_dernier) { xt <- rev(xt); yt <- rev(yt) }
  # Profondeur T et controles de validite : engine_valider_serie_retenue(),
  # partagee avec l'apercu de l'application (issue #131). n : nombre
  # d'annees fournies, restitue par metadata$n_fournies (issue #104).
  n <- length(xt)
  sr <- engine_valider_serie_retenue(xt, yt, T = T, theta_equiv = theta_equiv,
                                     delta_equiv = delta_equiv, methode = methode,
                                     nature_donnees = nature_donnees, bareme = bareme,
                                     segment = segment, annexe = annexe)
  xt <- sr$xt; yt <- sr$yt; validation <- sr$validation
  if (!validation$ok)
    return(structure(list(ok = FALSE, validation = validation,
                          metadata = list(horodatage = t0)), class = "usp_engine"))
  T <- length(xt)

  # --- 2. Parametre standard et bareme de credibilite -----------------------
  # Lecture conditionnelle de M13 (issue #55) : sigma brut sur donnees brutes,
  # NP standard x sigma brut sur donnees nettes (primes) ; sigma(res,s) pour
  # la methode de reserve no 1. Un sigma_standard saisi prime (derogation,
  # restituee par metadata$sigma_standard_saisi, pour les trois methodes).
  # Segment connu, ou sigma_standard fourni : deja verifie avant la
  # validation des donnees par .engine_verifier_usage() (constat 4 de la
  # revue finale de #88).
  infos <- if (!is.null(segment)) usp_segment_infos(segment, annexe) else NULL
  saisi <- !is.null(sigma_standard)
  sigma_standard <- usp_parametre_standard(methode, segment, annexe, nature_donnees,
                                           sigma_standard)$sigma_standard
  # Annexe XVII, section G(2) : les segments de l'annexe XIV relevent tous du
  # bareme court, quel que soit leur numero. Un bareme saisi prime :
  # derogation au bareme de la section G, restituee par
  # metadata$bareme_saisi (issue #93), meme egale au bareme du segment.
  saisi_bareme <- !is.null(bareme)
  if (is.null(bareme)) bareme <- usp_bareme_segment(segment, annexe)

  # --- Calcul protege (issue #88) : estimation et sorties, apres une
  # validation reussie. Une erreur R y est un defaut de calcul intercepte
  # (.engine_calcul_protege()), rendu en ok = FALSE.
  .engine_calcul_protege(methode, t0, validation, {
    # --- 3. Estimation, bootstrap, robustesse ---------------------------------
    # Bareme saisi (NULL sinon), segment et annexe : la ligne "Credibilite
    # pleine atteinte" lit le bareme applique, metadata$bareme (#131).
    controles <- usp_controle_donnees(xt, yt, alpha,
                                      bareme = if (saisi_bareme) bareme else NULL,
                                      segment = segment, annexe = annexe)
    fit   <- usp_ajuster(xt, yt)
    # Controles numeriques de l'estimation (famille H, non bloquants, #22)
    controles <- c(controles, usp_controles_numeriques(fit))
    boot  <- usp_bootstrap(fit, B = B, seed = seed, progres = FALSE)
    param <- usp_parametre(fit, sigma_standard, bareme)
    jack  <- usp_jackknife(fit, sigma_standard, bareme)
    prof  <- usp_profil(fit)
    # Rapport de vraisemblance aux bornes de delta, bootstrap restreint sous
    # chaque borne, B et graine de l'appel (issue #45, decision Q2).
    lrd   <- usp_lr_delta(fit, B = B, seed = seed)

    cred <- param$credibilite; corr <- param$correction_taille
    usp_b <- cred * boot$sigma_boot * corr + (1 - cred) * sigma_standard
    ic <- if (length(usp_b) > 20)
      stats::quantile(usp_b, c(.025, .05, .5, .95, .975)) else NULL
    # IC bootstrap a delta fixe a sa valeur estimee (issue #45, decision Q6 :
    # calcule aussi a delta interieur), meme regle que l'IC complet.
    usp_r <- cred * boot$sigma_boot_restreint * corr + (1 - cred) * sigma_standard
    ic_r <- if (length(usp_r) > 20)
      stats::quantile(usp_r, c(.025, .05, .5, .95, .975)) else NULL

    # Jackknife entierement non calcule (tous les reajustements en echec) : pas
    # de ligne jackknife (fit$ecart_jackknife NULL) plutot qu'un max a -Inf.
    d_jack <- jack$sigma_usp - param$sigma_usp
    jack_calcule <- any(is.finite(d_jack))
    fit$ecart_jackknife <- if (jack_calcule)
      max(abs(jack$sigma_usp - param$sigma_usp), na.rm = TRUE) / param$sigma_usp else NULL
    fit$largeur_ic <- if (!is.null(ic)) unname((ic[4] - ic[2]) / param$sigma_usp) else NULL
    fit$largeur_ic_restreint <- if (!is.null(ic_r))
      unname((ic_r[4] - ic_r[2]) / param$sigma_usp) else NULL
    # kkt_au_moins_un (#22) est replace en DERNIERE position de res$ajustement,
    # apres ecart_jackknife et largeur_ic apposes ci-dessus : le patcheur des
    # references (tests/patcher_reference.R) n'ajoute une feuille qu'en fin de
    # conteneur, et refuse le patch (verification "structure") sinon.
    fit <- fit[c(setdiff(names(fit), "kkt_au_moins_un"), "kkt_au_moins_un")]

    # Elements du detail de la ligne jackknife de usp_tests() : calcules ici,
    # transmis a usp_tests() et NON stockes dans fit ni dans le resultat.
    # jack_annee : annee de plus grand |ecart| sur sigma_USP ; jack_usp : ecart
    # signe a cette annee (seul son signe est imprime, issues #24 et #76).
    # NULL si aucun reajustement n'a abouti.
    i_jack <- if (jack_calcule) which.max(abs(d_jack)) else NULL
    robustesse <- list(
      jack_annee = i_jack,
      jack_usp   = if (jack_calcule) d_jack[i_jack] / param$sigma_usp else NULL)

    tests <- usp_tests(fit, boot, alpha, theta_equiv = theta_equiv,
                       delta_equiv = delta_equiv, robustesse = robustesse,
                       methode = methode, lr_delta = lrd)

    # --- 4. Statistiques descriptives -----------------------------------------
    r <- yt / xt
    descriptif <- data.frame(
      grandeur = c("T", "somme(xt)", "somme(yt)", "moyenne(xt)", "moyenne(yt)",
                   "ratio moyen y/x", "mediane du ratio", "ecart-type du ratio",
                   "coefficient de variation du ratio", "min du ratio", "max du ratio",
                   "amplitude max(x)/min(x)"),
      valeur = c(T, sum(xt), sum(yt), mean(xt), mean(yt), mean(r), stats::median(r),
                 stats::sd(r), stats::sd(r) / mean(r), min(r), max(r), max(xt) / min(xt)),
      stringsAsFactors = FALSE)

    # --- 5. Calibration : etapes explicites -----------------------------------
    calibration <- data.frame(
      etape = c("delta (parametre de melange)",
                "gamma (coefficient de variation logarithmique)",
                "beta (ratio moyen implicite)",
                "sigma(delta, gamma) estime",
                "correction de taille finie sqrt((T+1)/(T-1))",
                "sigma estime corrige",
                "facteur de credibilite c",
                "sigma standard (formule standard)",
                "sigma_USP = c*sigma_corrige + (1-c)*sigma_standard"),
      valeur = c(fit$delta, fit$gamma, fit$beta, param$sigma_estime_brut,
                 param$correction_taille, param$sigma_estime, param$credibilite,
                 param$sigma_standard, param$sigma_usp),
      stringsAsFactors = FALSE)

    candidats <- data.frame(
      variante = c("sigma standard (aucun USP)", "sigma estime seul (credibilite 100%)",
                   "sigma_USP retenu (annexe XVII)"),
      valeur = c(sigma_standard, param$sigma_estime, param$sigma_usp),
      retenu = c(FALSE, FALSE, TRUE), stringsAsFactors = FALSE)

    # --- 6. Objet de sortie ----------------------------------------------------
    structure(list(
      ok = TRUE,
      donnees = data.frame(t = seq_len(T), xt = xt, yt = yt, ratio = r),
      validation = validation,
      controles = controles,
      statistiques_descriptives = descriptif,
      ajustement = fit,
      tests = tests,
      bootstrap = boot,
      ic_bootstrap = ic,
      ic_bootstrap_restreint = ic_r,
      jackknife = jack,
      profil = prof,
      lr_delta = lrd,
      calibration = calibration,
      candidats = candidats,
      parametre_final = param,
      plots_data = engine_plots_data(fit, boot, prof, jack, param$sigma_usp,
                                     lr_delta = lrd),
      metadata = c(
        list(methode = methode, segment = segment, annexe = annexe,
             libelle_segment = if (!is.null(infos)) infos$libelle else NA_character_,
             T = T, B = B,
             alpha = alpha, seed = seed, bareme = bareme,
             theta_equiv = theta_equiv, delta_equiv = delta_equiv,
             sigma_standard = sigma_standard),
        # Issue #55. Nature declaree des donnees : methode du risque de primes
        # seulement (les methodes de reserve n'ont pas ce champ : donnees
        # nettes par exigence du texte, C(2)(c), D(2)(f)). Saisie libre du
        # sigma standard (derogation au parametre reglementaire) : drapeau
        # explicite pour les trois methodes. Places apres les champs
        # anterieurs, suivis des seuls champs de l'issue #37, de bareme_saisi
        # (#93), puis des champs d'execution (retires par nettoyer() des
        # tests).
        if (methode == "premium") list(nature_donnees = nature_donnees),
        list(sigma_standard_saisi = saisi),
        # Generateur pose par engine_sous_graine() et graine fixe des
        # simulations autres que le bootstrap (issue #37, ADR 0004 point 2) :
        # loi nulle de Shapiro-Wilk. Places apres les champs existants, avant
        # les champs d'execution. La graine de l'enveloppe du QQ-plot est
        # retiree (issue #47) : l'enveloppe depend de seed et de B.
        list(generateur = as.list(ENGINE_RNG_KIND),
             seed_loi_nulle_sw = SEED_LOI_NULLE_SW),
        # Bareme saisi (issue #93) : place apres les champs de l'issue #37, en
        # dernier avant les champs d'execution (le patch des references
        # ajoute la feuille en fin de metadata).
        list(bareme_saisi = saisi_bareme),
        # Annees fournies avant troncature a la profondeur T (issue #104,
        # decision du mainteneur du 28/09/2026) : n_fournies > T signale que
        # les n_fournies - T annees les plus anciennes ont ete ecartees
        # (ligne "profondeur" de engine_derogations()). La duree de
        # credibilite reste T (lecture (A) : annexe XVII, section G,
        # paragraphe 3). Place apres bareme_saisi, en dernier avant les champs
        # d'execution.
        list(n_fournies = n),
        list(horodatage = t0,
             duree_sec = as.numeric(difftime(Sys.time(), t0, units = "secs")),
             version_R = R.version.string))
    ), class = "usp_engine")
  })
}


# Parametre standard remplace et sa tracabilite (issue #55, decision M13),
# sous forme de data.frame pour la restitution (onglet Calibration, rapport
# fige) : nature declaree des donnees, point de l'art. 218, paragraphe 1,
# remplace, exigence relative aux donnees, sigma de l'annexe, NP standard,
# sigma standard reglementaire, sigma standard retenu dans le melange et son
# origine (parametre reglementaire ou saisie libre, derogation), puis le
# bareme de credibilite applicable, le bareme retenu et son origine (issue
# #93).
# Colonnes : grandeur ; valeur (numerique, NA pour une ligne de texte) ;
# texte (NA pour une ligne purement numerique).
# Tout est recalcule ici a partir de res$metadata par usp_parametre_standard()
# et usp_bareme_segment() (aucun calcul dans l'affichage) ; le sigma standard
# et le bareme recalcules doivent etre identiques a ceux du resultat, sinon
# erreur.
# Saisie libre : drapeaux explicites metadata$sigma_standard_saisi et
# metadata$bareme_saisi, pour les trois methodes (toute saisie est une
# derogation, meme egale a la table ; decisions du mainteneur du 25/09/2026
# et du 26/09/2026, issue #93). Un resultat qui ne les porte pas (produit
# avant l'issue #55 ou #93) est refuse plutot que devine.
.engine_drapeau <- function(m, nom, appelant) {
  v <- m[[nom]]
  if (!is.logical(v) || length(v) != 1L || is.na(v))
    stop(sprintf("%s : drapeau metadata$%s absent ou invalide.", appelant, nom))
  v
}

# Sigma standard retenu et sa tracabilite, recalcules depuis res$metadata ;
# controle de coherence avec le sigma standard du resultat.
.engine_trace_sigma <- function(res, appelant) {
  m <- res$metadata
  saisi <- .engine_drapeau(m, "sigma_standard_saisi", appelant)
  ps <- usp_parametre_standard(m$methode, m$segment, m$annexe, m$nature_donnees,
                               if (saisi) m$sigma_standard else NULL)
  if (!identical(ps$sigma_standard, m$sigma_standard))
    stop(sprintf("%s : sigma standard recalcule different de celui du resultat.", appelant))
  ps
}

# Bareme de credibilite retenu et sa tracabilite (issue #93), recalcules
# depuis res$metadata : bareme applicable selon la section G (NA sans
# segment designe : aucun texte ne le determine), paragraphe de la section G,
# facteurs c applicable et retenu (usp_credibilite(), duree metadata$T),
# etat de l'origine. Controles de coherence : un bareme non saisi doit etre
# celui de usp_bareme_segment() (le bareme "court" pose par convention sans
# segment compris) ; le c retenu doit etre celui de res$parametre_final.
.engine_trace_bareme <- function(res, appelant) {
  m <- res$metadata
  saisi <- .engine_drapeau(m, "bareme_saisi", appelant)
  if (!is.character(m$bareme) || length(m$bareme) != 1L ||
      !m$bareme %in% c("court", "long"))
    stop(sprintf("%s : bareme du resultat absent ou invalide.", appelant))
  if (!saisi && !identical(usp_bareme_segment(m$segment, m$annexe), m$bareme))
    stop(sprintf("%s : bareme recalcule different de celui du resultat.", appelant))
  c_ret <- usp_credibilite(m$T, m$bareme)
  if (!identical(c_ret, res$parametre_final$credibilite))
    stop(sprintf("%s : facteur de credibilite recalcule different de celui du resultat.",
                 appelant))
  sans_segment <- is.null(m$segment)
  regl <- if (sans_segment) NA_character_ else usp_bareme_segment(m$segment, m$annexe)
  paragraphe <- c(long = "annexe XVII, section G, paragraphe 1",
                  court = "annexe XVII, section G, paragraphe 2")
  etat <- if (!saisi) { if (sans_segment) "defaut" else "reglementaire" } else
          if (sans_segment) "saisi_sans_segment" else
          if (identical(regl, m$bareme)) "saisi_egal" else "saisi_contraire"
  list(saisi = saisi, retenu = m$bareme, reglementaire = regl,
       ref_reglementaire = if (sans_segment) NA_character_ else paragraphe[[regl]],
       c_reglementaire = if (sans_segment) NA_real_ else usp_credibilite(m$T, regl),
       c_retenu = c_ret, T = m$T, etat = etat,
       conforme = if (sans_segment) NA else identical(regl, m$bareme))
}

# Profondeur retenue et annees fournies (issue #104), lues sur res$metadata :
# n_fournies (annees fournies avant troncature) et T (annees retenues, duree
# de credibilite de l'annexe XVII, section G, paragraphe 3, lecture (A),
# decision du mainteneur du 28/09/2026). Un resultat qui ne porte pas
# n_fournies (produit avant l'issue #104), ou dont n_fournies n'est pas un
# entier >= T, est refuse plutot que devine ; pour la methode du risque de
# reserve no 2, le triangle n'est jamais tronque (n_fournies = T exige).
# Un T absent ou non entier est refuse ici : engine_derogations() appelle
# cette fonction avant .engine_trace_bareme() (#135).
.engine_trace_profondeur <- function(res, appelant) {
  m <- res$metadata
  n <- m$n_fournies; T <- m$T
  if (!is.numeric(n) || length(n) != 1L || !is.finite(n) || n != round(n))
    stop(sprintf("%s : metadata$n_fournies absent ou invalide.", appelant))
  if (!is.numeric(T) || length(T) != 1L || !is.finite(T) || T != round(T))
    stop(sprintf("%s : metadata$T absent ou invalide.", appelant))
  if (n < T)
    stop(sprintf("%s : metadata$n_fournies inferieur a la profondeur T retenue.", appelant))
  if (identical(m$methode, "reserve2") && n != T)
    stop(sprintf("%s : triangle tronque (n_fournies different de T), impossible en reserve no 2.",
                 appelant))
  list(n_fournies = as.integer(n), T = as.integer(T), tronque = n > T)
}

engine_parametre_standard <- function(res) {
  if (!isTRUE(res$ok)) return(NULL)
  m <- res$metadata
  ps <- .engine_trace_sigma(res, "engine_parametre_standard()")
  tb <- .engine_trace_bareme(res, "engine_parametre_standard()")
  prime <- identical(m$methode, "premium")
  lib_nature <- c(brutes = "brutes : non ajustees de la reassurance",
                  nettes = "nettes : ajustees de la reassurance")[[ps$nature_donnees]]
  origine_bareme <- switch(tb$etat,
    reglementaire = "bareme reglementaire du segment",
    defaut = paste("bareme par defaut (court), aucun segment designe : non determine par",
                   "l'annexe XVII, section G"),
    saisi_egal = sprintf(paste("bareme saisi (%s), egal au bareme de l'%s :",
                               "saisie declaree comme derogation"),
                         tb$retenu, tb$ref_reglementaire),
    saisi_contraire = sprintf(paste("bareme saisi (%s), contraire a l'%s :",
                                    "derogation au bareme de l'annexe XVII, section G"),
                              tb$retenu, tb$ref_reglementaire),
    saisi_sans_segment = sprintf(paste("bareme saisi (%s), non determine par l'annexe XVII,",
                                       "section G : aucun segment designe (saisie declaree",
                                       "comme derogation)"),
                                 tb$retenu))
  d <- data.frame(
    grandeur = c(
      if (prime) "Nature declaree des donnees" else "Nature des donnees (exigence de la methode)",
      "Parametre standard remplace",
      "Exigence relative aux donnees",
      sprintf("sigma %s de l'annexe %s", if (prime) "brut (primes)" else "(reserve)", ps$annexe),
      if (prime) sprintf("Facteur NP standard (%s, paragraphe 3)",
                         if (identical(ps$annexe, "XIV")) "art. 148" else "art. 117"),
      "sigma standard reglementaire",
      "sigma standard retenu dans le melange",
      "Origine du sigma standard retenu",
      "Bareme et facteur c applicables (annexe XVII, section G)",
      "Bareme et facteur c retenus",
      "Origine du bareme retenu"),
    valeur = c(NA, NA, NA, ps$sigma_annexe, if (prime) ps$np_standard,
               ps$sigma_reglementaire, ps$sigma_standard, NA,
               tb$c_reglementaire, tb$c_retenu, NA),
    texte = c(lib_nature,
              paste0(ps$point_art218, " : ", ps$parametre_remplace),
              ps$exigence_donnees,
              if (is.null(m$segment)) "aucun segment designe" else NA,
              if (prime) NA,
              if (is.null(m$segment)) "aucun segment designe" else
                if (!prime) "sigma(res,s)" else
                if (identical(ps$nature_donnees, "nettes")) "NP standard x sigma brut" else "sigma brut",
              NA,
              if (ps$saisie) "sigma standard saisi, derogation au parametre reglementaire"
              else "parametre reglementaire",
              if (is.na(tb$reglementaire)) "non determine : aucun segment designe"
              else paste0(tb$reglementaire, ", ", tb$ref_reglementaire),
              sprintf("%s, T = %d", tb$retenu, as.integer(tb$T)),
              origine_bareme),
    stringsAsFactors = FALSE)
  d
}

# Point de lecture unique des derogations (issue #93, forme de module de la
# fiche E0) : sigma standard saisi (#55) et bareme de credibilite saisi
# (#93), lus sur les drapeaux explicites de res$metadata, plus le bareme
# "court" pose par convention sans segment designe, non determine par la
# section G (ligne sans drapeau), plus la troncature de la serie fournie a
# la profondeur T (#104 : ligne "profondeur" si metadata$n_fournies > T ;
# choix de perimetre plutot que derogation a un parametre, restitue ici pour
# etre repris par le bandeau et le rapport fige, decision du mainteneur du
# 28/09/2026). L'affichage (bandeau de l'onglet Calibration, rapport fige,
# journal) ne connait que cette table.
# Valeur : NULL si !isTRUE(res$ok) ; sinon data.frame (0 ligne sans
# derogation), colonnes :
#   parametre            "sigma_standard", "bareme" ou "profondeur" ;
#   valeur_reglementaire valeur du texte (caractere ; NA sans segment, et
#                        toujours NA pour "profondeur", que le texte ne fixe
#                        pas) ;
#   valeur_retenue       valeur du melange (caractere ; "profondeur" : T) ;
#   conforme             valeur retenue egale a la valeur reglementaire
#                        (logique ; NA si non determinable, sans segment, et
#                        toujours NA pour "profondeur") ; une saisie egale
#                        reste une derogation ;
#   libelle              phrase complete pour bandeau et journal.
# Erreur si un drapeau manque ou est invalide (pas de deduction), si le
# sigma standard ou le bareme recalcules different du resultat, ou si
# metadata$n_fournies manque ou est incoherent, ou si metadata$T est absent
# ou non entier (.engine_trace_profondeur()).
engine_derogations <- function(res) {
  if (!isTRUE(res$ok)) return(NULL)
  ps <- .engine_trace_sigma(res, "engine_derogations()")
  # Profondeur avant bareme (#135) : un metadata$T invalide est refuse par le
  # message propre de .engine_trace_profondeur(), et non par celui de
  # usp_credibilite() appelee dans .engine_trace_bareme().
  tp <- .engine_trace_profondeur(res, "engine_derogations()")
  tb <- .engine_trace_bareme(res, "engine_derogations()")
  fmt <- function(x) if (is.na(x)) NA_character_ else format(x, digits = 10)
  d <- data.frame(parametre = character(0), valeur_reglementaire = character(0),
                  valeur_retenue = character(0), conforme = logical(0),
                  libelle = character(0), stringsAsFactors = FALSE)
  if (ps$saisie) {
    # Egalite a TOLERANCE_CONFORME_SIGMA pres en relatif (voir sa
    # definition en tete du moteur).
    conf <- if (is.na(ps$sigma_reglementaire)) NA else
      abs(ps$sigma_standard - ps$sigma_reglementaire) <=
        TOLERANCE_CONFORME_SIGMA * abs(ps$sigma_reglementaire)
    d <- rbind(d, data.frame(parametre = "sigma_standard",
      valeur_reglementaire = fmt(ps$sigma_reglementaire),
      valeur_retenue = fmt(ps$sigma_standard), conforme = conf,
      libelle = "sigma standard saisi, derogation au parametre reglementaire",
      stringsAsFactors = FALSE))
  }
  if (tb$etat != "reglementaire") {
    lib <- switch(tb$etat,
      defaut = sprintf(paste("bareme de credibilite %s non determine par l'annexe XVII,",
                             "section G : aucun segment designe"), tb$retenu),
      saisi_egal = sprintf(paste("bareme de credibilite saisi (%s), egal au bareme de l'%s :",
                                 "saisie declaree comme derogation"),
                           tb$retenu, tb$ref_reglementaire),
      saisi_contraire = sprintf(paste("bareme de credibilite saisi (%s), derogation au bareme",
                                      "de l'annexe XVII, section G : bareme reglementaire du",
                                      "segment %s de l'annexe %s : %s (%s)"),
                                tb$retenu, format(res$metadata$segment), res$metadata$annexe,
                                tb$reglementaire, tb$ref_reglementaire),
      saisi_sans_segment = sprintf(paste("bareme de credibilite saisi (%s), non determine par",
                                         "l'annexe XVII, section G : aucun segment designe",
                                         "(saisie declaree comme derogation)"), tb$retenu))
    d <- rbind(d, data.frame(parametre = "bareme",
      valeur_reglementaire = tb$reglementaire, valeur_retenue = tb$retenu,
      conforme = tb$conforme, libelle = lib, stringsAsFactors = FALSE))
  }
  if (tp$tronque) {
    # Troncature n_fournies -> T (issue #104) : lecture (A), la duree de
    # credibilite est T ; l'exclusion des annees les plus anciennes est a
    # justifier au titre de l'art. 219, paragraphe 1, point a), qui rend
    # applicable l'art. 19, paragraphe 1, point b), et a documenter au titre
    # de l'art. 219, paragraphe 1, point e) (lecture de regulatory, issue
    # #104) ; motif de representativite : annexe XVII, section B (primes) ou
    # C (reserve no 1), paragraphe 2, point a). Methodes lognormales
    # seulement (.engine_trace_profondeur() refuse un triangle tronque).
    # Point de G(3) et vocabulaire du texte selon la methode : point a) et
    # "annees" pour le risque de primes (section B), point b) et "exercices"
    # pour le risque de reserve no 1 (section C, paragraphe 3 ; G(3)(b)).
    r1 <- identical(res$metadata$methode, "reserve1")
    section <- if (r1) "C" else "B"
    point_g3 <- if (r1) "b" else "a"
    nb <- tp$n_fournies - tp$T
    unite <- if (r1) "exercices fournis" else "annees fournies"
    ecartes <- if (r1) {
      if (nb == 1L) "l'exercice le plus ancien est ecarte" else
        sprintf("les %d exercices les plus anciens sont ecartes", nb)
    } else {
      if (nb == 1L) "l'annee la plus ancienne est ecartee" else
        sprintf("les %d annees les plus anciennes sont ecartees", nb)
    }
    lib <- sprintf(paste(
      "profondeur retenue T = %d sur n = %d %s : %s de l'estimation, la duree de",
      "credibilite (annexe XVII, section G, paragraphe 3, point %s)) etant",
      "T = %d ; exclusion a justifier dans le dossier (art. 219, paragraphe 1, point a),",
      "renvoyant a l'art. 19, paragraphe 1, point b) ; motif de representativite :",
      "annexe XVII, section %s, paragraphe 2, point a)) et a documenter (art. 219,",
      "paragraphe 1, point e))"),
      tp$T, tp$n_fournies, unite, ecartes, point_g3, tp$T, section)
    d <- rbind(d, data.frame(parametre = "profondeur",
      valeur_reglementaire = NA_character_, valeur_retenue = as.character(tp$T),
      conforme = NA, libelle = lib, stringsAsFactors = FALSE))
  }
  rownames(d) <- NULL
  d
}

# Table des tests sous forme de data.frame auditable (donnees, pas affichage).
engine_table_tests <- function(res) {
  do.call(base::rbind, lapply(res$tests, function(t) data.frame(
    famille = t$famille, test = t$test, type = t$type,
    base = t$base, variante = t$variante,
    H0 = t$H0, H1 = t$H1,
    nom_statistique = t$stat_nom, statistique = t$stat, loi_sous_H0 = t$loi,
    nom_estimation = t$estim_nom, estimation = t$estim,
    p_exacte = t$p_exacte, p_asymptotique = t$p_asymptotique,
    p_monte_carlo = t$p_mc, erreur_MC = t$err_mc,
    # p_min (#44) : NULL sur un objet anterieur au champ, rendu NA.
    p_min = if (is.null(t$p_min)) NA_real_ else t$p_min,
    p_retenue = t$p_retenue, nature_p = t$nature_p,
    sens_du_test = t$sens, verdict = t$verdict,
    commentaire = t$detail, reference = t$reference,
    # fonction (#111) : NULL sur un objet anterieur au champ, rendu NA.
    fonction = if (is.null(t$fonction)) NA_character_ else t$fonction,
    # inoperant (#129, point 3) : NULL sur un objet anterieur au champ, rendu NA.
    inoperant = if (is.null(t$inoperant)) NA else t$inoperant,
    stringsAsFactors = FALSE)))
}
