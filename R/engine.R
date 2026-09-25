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
# L-BFGS-B sur delta : environ 1e-9 pour l'ajustement complet usp_ajuster()
# (factr = 1e5, reduction relative factr * eps = 2,2e-11) et environ 1e-7
# pour le reajustement rapide usp_ajuster_rapide() (factr = 1e7, 2,2e-9),
# l'objectif ne variant que de 2,3e-2 * (1 - delta) en relatif pres du bord
# sur les donnees de test. Mesure (avis actuary, 23/09/2026) : sur
# 1 399 ajustements (400 jeux simules ajustes par usp_ajuster(), 999
# repliques bootstrap par usp_ajuster_rapide()), aucune distance de delta au
# bord dans la fenetre (0 ; 1,7e-4) : le seuil 1e-6 ne separe donc aucun
# optimum interieur observe. Unique source de cette tolerance : usp_ajuster()
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

# Reperes des controles numeriques de l'estimation lognormale (issue #22).
# Reperes NUMERIQUES, non reglementaires. Source unique : usp_ajuster()
# (ensemble des demarrages a l'optimum) et usp_kkt_satisfaite() (valeurs par
# defaut). Les libelles de usp_controles_numeriques() ne les impriment plus
# (issue #76) : la regle et ses reperes sont dans les fiches du .tex.
# - TOL_OPTIMUM : un demarrage est "a l'optimum" si son objectif est a moins
#   de TOL_OPTIMUM de l'objectif minimal ; meme ensemble pour la convergence
#   multi-demarrages (M15) et pour la condition de Kuhn-Tucker (M25).
# - REP_PAS_KKT : repere sur |pas de Newton en gamma|, ancre sur M9 (erreur
#   relative sur sigma de l'ordre de Delta gamma, tolerance de
#   non-regression 1e-6), maintenu par M17.
# - REP_GD_KKT : repere sur |pg_delta|, regle unique au bord comme a
#   l'interieur (M16).
TOL_OPTIMUM <- 1e-6
REP_PAS_KKT <- 1e-6
REP_GD_KKT  <- 1e-4

usp_credibilite <- function(T, bareme = c("court", "long")) {
  bareme <- match.arg(bareme)
  tab <- if (bareme == "long") CRED_LONG else CRED_COURT
  # La duree est un nombre entier d'annees (section G : "duree de la serie
  # chronologique") ; une valeur non entiere, non finie ou multiple n'a pas
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

usp_bareme_segment <- function(segment, annexe = "II") {
  annexe <- .annexe_verifiee(annexe)
  if (is.null(segment) || is.na(segment)) return("court")
  if (identical(annexe, "XIV")) return("court")
  if (segment %in% c(1, 5, 6)) "long" else "court"
}

# Renvoie les caracteristiques reglementaires d'un segment : libelle, ecarts
# types standard, facteur NP standard et bareme de credibilite applicable.
usp_segment_infos <- function(segment, annexe = "II") {
  annexe <- .annexe_verifiee(annexe)
  tab <- if (identical(annexe, "XIV")) ANNEXE_XIV else ANNEXE_II
  i <- match(segment, tab$segment)
  if (is.na(i)) stop(sprintf("Segment %s inconnu dans l'annexe %s.", segment, annexe))
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
# section B, point (2), c) et d), dans leur version consolidee, marqueur M1 :
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
    paste("annexe XVII, section C, point (2)(c) : donnees ajustees de la reassurance",
          "et des vehicules de titrisation, conformement aux contrats en place pour",
          "les douze mois a venir")
  else paste("annexe XVII, section D, point (2)(f) : montants de sinistres cumules",
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
      paste("annexe XVII, section B, point (2)(d), chapeau modifie par le reglement",
            "delegue (UE) 2016/467 (M1) : pertes agregees ajustees des montants",
            "recouvrables au titre de la reassurance et des vehicules de titrisation,",
            "primes acquises ajustees des primes de reassurance, conformement aux",
            "contrats de reassurance et vehicules de titrisation en place pour les",
            "douze mois a venir")
    else paste("annexe XVII, section B, point (2)(c), remplace par le reglement delegue",
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
      paste("annexe XVII, section C, point (2)(c) : donnees ajustees de la reassurance",
            "et des vehicules de titrisation, conformement aux contrats en place pour",
            "les douze mois a venir (exigence de la methode)")
    else paste("annexe XVII, section D, point (2)(f) : montants de sinistres cumules",
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

# Lecture d'un CSV "vecteur" (une serie annuelle), en ligne ou en colonne,
# avec ou sans en-tete. Les cellules sont lues comme du texte, sans retirer
# les lignes vides, afin que la position de chaque valeur soit conservee :
# une cellule vide ou non numerique AU MILIEU de la serie est refusee, car la
# retirer decalerait toutes les annees suivantes et desalignerait x et y
# (issue #33). Sont seulement ecartes : une premiere cellule non numerique
# (en-tete) et les cellules vides en tete de fichier, entre l'en-tete et la
# premiere valeur, et en fin de fichier (lues sans effet par l'ancien
# lecteur, qui sautait les lignes vides).
usp_lire_vecteur <- function(chemin, sep = ",", dec = ".") {
  if (!file.exists(chemin)) stop("Fichier introuvable : ", chemin)
  brut <- utils::read.csv(chemin, header = FALSE, sep = sep, dec = dec,
                          colClasses = "character", blank.lines.skip = FALSE,
                          na.strings = character(0), strip.white = TRUE)
  m <- as.matrix(brut)
  m[is.na(m)] <- ""
  m <- trimws(m)
  # Lignes et colonnes entierement vides AVANT la premiere valeur ou APRES
  # la derniere (debut ou fin de fichier, separateur final) ecartees ; une
  # ligne ou une colonne vide intercalee est conservee (cellule vide, refusee
  # plus bas). Il doit rester une seule ligne ou une seule colonne.
  nz <- matrix(nzchar(m), nrow(m), ncol(m))
  bornes <- function(k) if (length(k)) seq(min(k), max(k)) else integer(0)
  m <- m[bornes(which(rowSums(nz) > 0)), bornes(which(colSums(nz) > 0)), drop = FALSE]
  if (nrow(m) > 1 && ncol(m) > 1)
    stop("Format non reconnu dans ", chemin, " : une serie sur une seule ligne ou ",
         "une seule colonne est attendue (", nrow(m), " lignes x ", ncol(m), " colonnes).")
  cel <- as.vector(m)
  en_nombre <- function(v) suppressWarnings(as.numeric(if (dec != ".") gsub(dec, ".", v, fixed = TRUE) else v))
  # Cellules vides de tete ignorees, puis en-tete (premiere cellule non vide
  # et non numerique), puis cellules vides entre l'en-tete et la premiere
  # valeur. Les positions rapportees plus bas partent de la premiere valeur.
  sans_vides_tete <- function(v) { while (length(v) && !nzchar(v[1])) v <- v[-1]; v }
  cel <- sans_vides_tete(cel)
  if (length(cel) && is.na(en_nombre(cel[1]))) cel <- sans_vides_tete(cel[-1])
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
  non_num <- which(is.na(v))
  if (length(non_num))
    stop(sprintf("Valeur(s) non numerique(s) en position %s de la serie (comptee depuis la premiere valeur) de %s : %s.",
                 paste(non_num, collapse = ", "), chemin,
                 paste0("\"", cel[non_num], "\"", collapse = ", ")))
  v
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
    if (T > n) stop("T = ", T, " > profondeur disponible (", n, ").")
    idx <- (n - T + 1):n                     # on garde les T annees les plus recentes
    x <- x[idx]; y <- y[idx]
  }
  list(x = x, y = y, T = length(x))
}

# Controles de qualite (famille A). Verdict OK / ECHEC sans niveau alpha.
# Un controle qui ne peut pas etre etabli (valeur manquante, serie vide) vaut
# ECHEC, jamais un jugement sur les seules valeurs disponibles, et son detail
# le dit au lieu d'imprimer NA comme un nombre ; sous T = 5, la ligne de
# credibilite sort ECHEC sans appeler le bareme, qui n'y est pas defini
# (issue #33, avis d'actuary du 24/09/2026). run_engine() valide en amont :
# ces cas ne s'y presentent pas.
usp_controle_donnees <- function(x, y, alpha = 0.10) {
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
    add("Plausibilite du ratio y/x", all(ratio > 0 & ratio < 5),
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
  add("Credibilite pleine atteinte", T >= 10,
      if (T >= 5) sprintf("T = %d ; c = %.0f%% (bareme court) / %.0f%% (bareme long)",
                          T, 100 * usp_credibilite(T, "court"), 100 * usp_credibilite(T, "long"))
      else sprintf("T = %d ; bareme non defini sous T = 5 (annexe XVII, section G)", T))
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
  # ln(beta) : annexe XVII, sect. B/C par. 4-5 (estimateur MV du niveau)
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

# Condition du premier ordre (Kuhn-Tucker) au point (delta, gamma), issue #22 :
#   - gradient : usp_gradient() ;
#   - gradient_projete : composante annulee si elle pousse hors du domaine au
#     bord (borne inferieure : min(g, 0) ; borne superieure : max(g, 0)),
#     inchangee a l'interieur. Bord jugee a TOL_DELTA_BORD pres, pour delta
#     dans [0, 1] comme pour gamma dans BORNES_GAMMA ;
#   - hessien_gamma : difference centree (pas h) du gradient analytique en
#     gamma ;
#   - pas_newton_gamma : -pg_gamma / H_gamma_gamma, NA si la courbure n'est
#     pas strictement positive, si le gradient n'est pas fini, ou si gamma
#     est sur une borne numerique (le pas n'y a pas de sens : le maximum de
#     vraisemblance n'est pas atteint ; mineur d'audit, issue #22).
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
  H <- (usp_gradient(delta, gamma + h, x, y, xbar)[["gamma"]] -
        usp_gradient(delta, gamma - h, x, y, xbar)[["gamma"]]) / (2 * h)
  gamma_bord <- !is.finite(gamma) || gamma <= BORNES_GAMMA[1] + tol ||
    gamma >= BORNES_GAMMA[2] - tol
  pas <- if (!gamma_bord && is.finite(H) && H > 0 && is.finite(pg[["gamma"]]))
    -pg[["gamma"]] / H else NA_real_
  list(gradient = g, gradient_projete = pg, hessien_gamma = H, pas_newton_gamma = pas)
}

# Decision de Kuhn-Tucker pour UN demarrage (issue #22, decision du mainteneur
# du 24/09/2026 ; specification d'actuary) : fonction pure de
# cpo = usp_condition_premier_ordre(delta_s, gamma_s, ...) et de gamma_s.
# TRUE si et seulement si, sur ce MEME point : gradient et gradient projete
# finis, gamma_s hors des bornes numeriques BORNES_GAMMA (a TOL_DELTA_BORD
# pres), H_gamma_gamma finie et > 0, |pas de Newton en gamma| <= rep_pas et
# |pg_delta| <= rep_gd. Reperes par defaut REP_PAS_KKT (1e-6, ancre sur M9,
# M17) et REP_GD_KKT (1e-4, regle unique au bord comme a l'interieur, M16),
# definis en tete du moteur ; le libelle de usp_controles_numeriques() ne
# les imprime pas (issue #76) : la regle et ses reperes sont dans la fiche
# du .tex. Point d'accroche de #71 (pas de Newton complet).
usp_kkt_satisfaite <- function(cpo, gamma, rep_pas = REP_PAS_KKT, rep_gd = REP_GD_KKT) {
  gamma_bord <- !is.finite(gamma) || gamma <= BORNES_GAMMA[1] + TOL_DELTA_BORD ||
    gamma >= BORNES_GAMMA[2] - TOL_DELTA_BORD
  isTRUE(all(is.finite(c(cpo$gradient, cpo$gradient_projete)))) && !gamma_bord &&
    isTRUE(is.finite(cpo$hessien_gamma) && cpo$hessien_gamma > 0) &&
    isTRUE(is.finite(cpo$pas_newton_gamma) && abs(cpo$pas_newton_gamma) <= rep_pas) &&
    isTRUE(abs(cpo$gradient_projete[["delta"]]) <= rep_gd)
}

# Minimisation sous contrainte 0 <= delta <= 1 (annexe XVII, par. 6),
# avec démarrages multiples pour éviter les optima locaux.
# controle : parametres de stats::optim() ; la valeur par defaut est celle
# du calcul. Un autre reglage ne sert qu'aux tests (ajustement deliberement
# non converge, issue #22).
usp_ajuster <- function(x, y, n_starts_delta = 9, verbose = FALSE,
                        controle = list(factr = 1e5, maxit = 500)) {
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
      fn = usp_objectif, x = x, y = y, xbar = xbar,
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
  if (is.null(best)) stop("Echec de l'optimisation (annexe XVII, par. 6).")

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
  kkt_ok <- vapply(idx, function(i) usp_kkt_satisfaite(
    usp_condition_premier_ordre(pars[i, 1], pars[i, 2], x, y, xbar), pars[i, 2]),
    logical(1))

  d <- best$par[1]; g <- best$par[2]
  k <- usp_noyau(d, g, x, y, xbar)
  # Objectif non fini au point retenu : usp_objectif() y rend la penalite
  # 1e12, et comme toute valeur finie lui serait preferee, il n'est fini en
  # aucun point visite (valeur infinie dans x ou y, par exemple). Erreur
  # explicite plutot qu'un sigma = Inf rendu comme un optimum (issue #33).
  if (!is.finite(k$obj))
    stop("Echec de l'optimisation (annexe XVII, par. 6) : l'objectif n'est fini en aucun ",
         "point visite ; verifier que x et y sont finis et strictement positifs.")
  # Condition du premier ordre (issue #22) : gradient analytique de l'objectif
  # profile, projete sur les bornes. L'ancienne grandeur
  # |somme(pi_t v_t)| / somme(pi_t) etait une identite de la forme fermee de
  # ln(beta), nulle pour tout couple (delta, gamma) : elle ne controlait pas
  # la convergence et a ete retiree.
  cpo <- usp_condition_premier_ordre(d, g, x, y, xbar)
  c(k, list(delta = d, gamma = g, T = length(x), x = x, y = y, xbar = xbar,
            gradient = cpo$gradient, gradient_projete = cpo$gradient_projete,
            hessien_gamma = cpo$hessien_gamma, pas_newton_gamma = cpo$pas_newton_gamma,
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
  # que M15) satisfait les deux conditions sur le MEME point
  # (usp_kkt_satisfaite()) ; decision calculee dans usp_ajuster()
  # (fit$kkt_au_moins_un). L'ancienne regle jugeait le seul demarrage
  # retenu, departage par l'ordre de la grille : mesure d'actuary (200 jeux
  # simules a delta interieur, graine 20260924, Linux, R 4.3.3), 2 faux
  # ECHEC sur 200 (|Delta gamma| du retenu 1,24e-6 et 1,39e-6), 0 sur 200
  # avec la nouvelle regle (max sur les jeux de min_s |Delta gamma_s| =
  # 1,96e-7).
  # Reperes (constantes REP_PAS_KKT et REP_GD_KKT, en tete du moteur, lues
  # par usp_kkt_satisfaite()) : |pas de Newton en gamma| <= 1e-6, ancre sur
  # M9 (erreur relative sur sigma ~ Delta gamma, tolerance de
  # non-regression 1e-6) ; plancher Delta gamma ~ -h^2/3 ~ -3,3e-7 (biais de
  # la difference centree d'optim(), ndeps = h = 1e-3 ; derivation
  # d'actuary verifiee par simulation). |pg_delta| <= 1e-4, REGLE UNIQUE au
  # bord comme a l'interieur (decision du mainteneur apres audit : exiger
  # pg_delta = 0 au bord creait une discontinuite).
  # Libelle concis (issue #76, textes retenus par le mainteneur, retouches
  # du 24/09/2026) : le respect de la regle (oui / non), puis, s'il y a lieu,
  # la phrase "Volumes constants : delta non identifie.", puis UNE phrase
  # "Demarrage retenu : " reunissant, separees par " ; " et dans cet ordre,
  # les anomalies du demarrage retenu : gradient non fini, courbure (« non
  # finie » si H_gamma_gamma est NaN ou +-Inf, « non strictement positive »
  # si H est finie et <= 0), gamma sur une borne. La courbure n'est pas
  # mentionnee quand gamma est sur une borne (pas de Newton non defini dans
  # les deux cas). Ni repere, ni valeur
  # d'optimiseur : la regle, les reperes et leur justification sont dans la
  # fiche du .tex ; les valeurs du demarrage retenu dans res$ajustement
  # (gradient, gradient_projete, hessien_gamma, pas_newton_gamma) ; stat
  # reste le Delta gamma du demarrage retenu.
  g <- fit$gradient; pg <- fit$gradient_projete
  H <- fit$hessien_gamma
  grad_fini <- all(is.finite(c(g, pg)))
  gamma_bord <- !is.finite(fit$gamma) ||
    fit$gamma <= BORNES_GAMMA[1] + TOL_DELTA_BORD || fit$gamma >= BORNES_GAMMA[2] - TOL_DELTA_BORD
  H_finie <- isTRUE(is.finite(H))
  ok <- isTRUE(fit$kkt_au_moins_un)
  # Volumes constants (#58) : pi_t ne depend pas de delta, g_delta = 0 et
  # delta n'est pas identifie ; la valeur rendue par l'optimiseur (souvent 0)
  # est un artefact, que le libelle ne presente pas comme un bord.
  vol_cst <- isTRUE(usp_regime(fit$delta, fit$x)$volumes_constants)
  anomalies <- c(if (!grad_fini) "gradient non fini",
                 if (!gamma_bord && !H_finie) "courbure non finie",
                 if (!gamma_bord && H_finie && H <= 0) "courbure non strictement positive",
                 if (gamma_bord) "gamma sur une borne")
  add("Condition du premier ordre (gradient projete, KKT)", ok, fit$pas_newton_gamma,
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
  volumes_constants <- diff(range(x)) <= tol * mean(x)
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
ad_p_stephens <- function(A2, n) {
  if (!is.finite(A2) || n < 5) return(NA_real_)
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
  if (!is.finite(W2) || n < 5) return(NA_real_)
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
# (usp_bootstrap(), mw_bootstrap(), sw_loi_nulle(), engine_plots_data()).
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
# Graines fixes des simulations autres que le bootstrap (ADR 0004, point 2),
# consignees dans res$metadata : loi nulle de Shapiro-Wilk (sw_loi_nulle())
# et enveloppe du QQ-plot (engine_plots_data()).
SEED_LOI_NULLE_SW <- 20260901
SEED_ENVELOPPE_QQ <- 20260831
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
test_runs <- function(z) {
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
test_cox_stuart <- function(v) {
  n <- length(v); c0 <- ceiling(n / 2)
  d <- v[(c0 + 1):n] - v[1:(n - c0)]
  d <- d[d != 0]
  if (!length(d)) return(list(stat = NA_real_, p = NA_real_))
  k <- sum(d > 0); m <- length(d)
  list(stat = k, p = .p_borne(stats::binom.test(k, m, 0.5)$p.value))
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
mk_p_exacte <- function(v) {
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
  sg <- sign(z - stats::median(z)); sg <- sg[sg != 0]
  n1 <- sum(sg > 0); n2 <- sum(sg < 0)
  if (n1 < 1 || n2 < 1) return(NA_real_)
  Robs <- 1 + sum(diff(sg) != 0)
  d <- .runs_dens(n1, n2)
  if (!any(d$R == Robs)) return(NA_real_)
  .p_borne(2 * min(sum(d$prob[d$R <= Robs]), sum(d$prob[d$R >= Robs])))
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
# TRUE si les signes de a - med(a) et de b - med(b) coincident terme a terme.
.signes_mediane_egaux <- function(a, b) {
  length(a) == length(b) &&
    isTRUE(all(sign(a - stats::median(a)) == sign(b - stats::median(b))))
}

# Mann (1945) / Kendall (1975) - test de tendance monotone.
test_mann_kendall <- function(v) {
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
  if (stats::sd(reg) == 0 || mean(u2) <= 0)
    return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_))
  g <- u2 / mean(u2)
  aux <- stats::lm(g ~ reg)
  sce <- sum((stats::fitted(aux) - mean(g))^2)   # somme des carres expliques
  LM <- 0.5 * sce
  q <- 1
  list(stat = LM, p = .p_borne(1 - stats::pchisq(LM, q)), ddl = q)
}

# Breusch & Pagan (1979), Econometrica 47, 1287-1294 ; version studentisee
# (robuste a la non-normalite) de Koenker (1981) : LM = n R^2.
test_breusch_pagan <- function(u2, reg) {
  d <- data.frame(u2 = u2, reg = reg)
  m <- stats::lm(u2 ~ reg, data = d)
  R2 <- summary(m)$r.squared
  LM <- length(u2) * R2
  list(stat = LM, p = .p_borne(1 - stats::pchisq(LM, 1)))
}

# White (1980), Econometrica 48, 817-838 (forme auxiliaire quadratique).
test_white <- function(u2, reg) {
  d <- data.frame(u2 = u2, reg = reg, reg2 = reg^2)
  m <- stats::lm(u2 ~ reg + reg2, data = d)
  R2 <- summary(m)$r.squared
  LM <- length(u2) * R2
  list(stat = LM, p = .p_borne(1 - stats::pchisq(LM, 2)))
}

# Goldfeld & Quandt (1965), JASA 60, 539-547.
test_goldfeld_quandt <- function(u, reg) {
  o <- order(reg); u <- u[o]; n <- length(u)
  h <- floor(n / 2)
  s1 <- sum(u[1:h]^2) / h
  s2 <- sum(u[(n - h + 1):n]^2) / h
  F <- s2 / s1
  list(stat = F, p = .p_borne(2 * min(stats::pf(F, h, h), 1 - stats::pf(F, h, h))))
}

# Brown & Forsythe (1974), JASA 69, 364-367 (variante robuste de Levene).
test_brown_forsythe <- function(u, reg) {
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
  # x constant => colonne singuliere : la pente n'est pas identifiee et la
  # ligne "x" est absente de la matrice des coefficients. On renvoie des NA
  # plutot que de laisser une erreur d'indexation remonter.
  if (stats::sd(x) == 0 || length(unique(x)) < 2) {
    return(list(pente = NA_real_, t_pente = NA_real_, p_pente = NA_real_,
                F = NA_real_, ddl1 = NA_integer_, ddl2 = NA_integer_,
                p_F = NA_real_, R2 = NA_real_, R2_ajuste = NA_real_,
                modele = stats::lm(y ~ 1)))
  }
  m <- stats::lm(y ~ x)
  s <- summary(m)
  list(
    pente        = s$coefficients["x", "Estimate"],
    t_pente      = s$coefficients["x", "t value"],
    p_pente      = s$coefficients["x", "Pr(>|t|)"],
    F            = unname(s$fstatistic[1]),
    ddl1         = unname(s$fstatistic[2]),
    ddl2         = unname(s$fstatistic[3]),
    p_F          = stats::pf(s$fstatistic[1], s$fstatistic[2], s$fstatistic[3],
                             lower.tail = FALSE),
    R2           = s$r.squared,
    R2_ajuste    = s$adj.r.squared,
    modele       = m
  )
}

test_reset <- function(x, y) {
  if (stats::sd(x) == 0 || length(unique(x)) < 2)
    return(list(stat = NA_real_, p = NA_real_))
  m0 <- stats::lm(y ~ x - 1)                 # E[Y] = beta * X, sans constante
  f <- stats::fitted(m0)
  m1 <- stats::lm(y ~ x + I(f^2) + I(f^3) - 1)
  a <- stats::anova(m0, m1)
  list(stat = a[["F"]][2], p = .p_borne(a[["Pr(>F)"]][2]))
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
# il est traite en marge invalide.
test_tost_intercept <- function(x, y, theta = 0.10, delta_abs = NULL) {
  motif <- if (stats::sd(x) == 0 || length(unique(x)) < 2) "volumes constants"
  else if ((is.null(delta_abs) && (!is.finite(theta) || theta <= 0)) ||
           (!is.null(delta_abs) && (!is.finite(delta_abs) || delta_abs <= 0))) "marge"
  else NA_character_
  if (!is.na(motif))
    return(list(stat = NA_real_, p = NA_real_, delta = NA_real_,
                a = NA_real_, se = NA_real_, t_bas = NA_real_, t_haut = NA_real_,
                p_bas = NA_real_, p_haut = NA_real_, ddl = length(x) - 2,
                marge_a_priori = FALSE, non_applicable = motif))
  m <- summary(stats::lm(y ~ x))
  a  <- m$coefficients[1, 1]; se <- m$coefficients[1, 2]
  ddl <- length(x) - 2
  marge_a_priori <- !is.null(delta_abs)
  Delta <- if (marge_a_priori) delta_abs else theta * mean(y)
  t_bas  <- (a + Delta) / se        # H0_bas  : a <= -Delta, rejet si t_bas grand
  t_haut <- (a - Delta) / se        # H0_haut : a >= +Delta, rejet si t_haut petit
  p_bas  <- stats::pt(t_bas,  ddl, lower.tail = FALSE)
  p_haut <- stats::pt(t_haut, ddl, lower.tail = TRUE)
  p <- max(p_bas, p_haut)           # regle du maximum (intersection-union)
  list(stat = if (p_bas >= p_haut) t_bas else t_haut,
       p = .p_borne(p), delta = Delta, a = a, se = se,
       t_bas = t_bas, t_haut = t_haut, p_bas = p_bas, p_haut = p_haut,
       ddl = ddl, marge_a_priori = marge_a_priori, non_applicable = NA_character_)
}

# Significativité de la constante : rejette la proportionnalité stricte.
test_intercept <- function(x, y) {
  if (stats::sd(x) == 0 || length(unique(x)) < 2)
    return(list(stat = NA_real_, p = NA_real_))
  m <- summary(stats::lm(y ~ x))
  list(stat = m$coefficients[1, 3], p = .p_borne(m$coefficients[1, 4]))
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
# `degenere` : NULL pour toutes les entrees actuelles. Les deux statistiques
# degenerees (MeanZ, VarZ) ont ete retirees du bootstrap et restituees comme
# diagnostics par usp_tests() (issue #3, ADR 0001) ; le champ est reserve a une
# condition future et n'est lu par aucun calcul a ce jour.
# L'ordre des entrees fixe celui des statistiques dans l'objet bootstrap.
.mc_entree <- function(calc, queue, degenere = NULL) {
  if (length(queue) != 1L || !queue %in% c("haut", "bas", "deux"))
    stop("catalogue Monte-Carlo : sens de rejet inconnu : ", paste(queue, collapse = ", "))
  list(calc = calc, queue = queue, degenere = degenere)
}

# Contexte commun aux fonctions de calcul du catalogue lognormal.
# r : ratios S/P bruts ; u : ratios bruts centres, base alternative pour les
# tests d'independance et de stabilite (voir usp_tests, argument base_residus).
# Ces ratios sont heteroscedastiques par construction des que pi_t varie,
# donc leurs p-values classiques ne sont qu'indicatives ; seule la p-value
# de Monte-Carlo est valide, le bootstrap simulant sous le modele ajuste.
# Exception : a pi_t constant, la ligne Runsr recoit la p-value exacte de
# la loi combinatoire de R (usp_runsr_p_exacte(), issue #29).
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
    if (e$T >= 8 && stats::sd(e$x) > 0) {
      g <- e$x > stats::median(e$x)
      if (sum(g) >= 3 && sum(!g) >= 3)
        sm <- unname(suppressWarnings(stats::ks.test(e$z[g], e$z[!g])$statistic))
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
  SpearVol = .mc_entree(function(e)
    if (stats::sd(e$x) > 0)
      suppressWarnings(unname(stats::cor.test(e$r, e$x, method = "spearman",
                                              exact = FALSE)$statistic)) else NA_real_,
    "deux"),
  SpearTps = .mc_entree(function(e)
    suppressWarnings(unname(stats::cor.test(e$r, seq_along(e$r),
                                            method = "spearman", exact = FALSE)$statistic)),
    "deux"),
  DAgo   = .mc_entree(function(e) test_dagostino_skew(e$z)$stat, "deux"),
  # Cox-Stuart : la region de rejet bilaterale de K (nombre de differences
  # positives entre les deux moities) est pliee en |K - n_p / 2|, rejet en
  # queue haute, n_p = T - ceiling(T / 2) etant le nombre de paires. Sans
  # difference nulle, c'est le test binomial exact bilateral (loi de K
  # symetrique sous H0). La statistique affichee par usp_tests() reste K.
  CoxStuart = .mc_entree(function(e) {
    cx <- test_cox_stuart(e$r)
    m <- ceiling(e$T / 2)
    if (is.finite(cx$stat)) abs(cx$stat - (e$T - m) / 2) else NA_real_
  }, "haut"),
  # --- memes statistiques sur les ratios bruts centres (base "r") -----------
  DWr    = .mc_entree(function(e) stat_dw(e$u), "deux"),
  LB1r   = .mc_entree(function(e)
    unname(stats::Box.test(e$u, lag = 1, type = "Ljung-Box")$statistic), "haut"),
  Runsr  = .mc_entree(function(e) test_runs(e$u)$stat, "deux"),
  supFr  = .mc_entree(function(e) stat_supF(e$u), "haut"),
  CUSUMr = .mc_entree(function(e) stat_cusum(e$u), "haut"),
  Grubbsr = .mc_entree(function(e) test_grubbs(e$u)$stat, "haut")
)

# Evalue toutes les statistiques d'un catalogue sur un contexte. do.call(c, .)
# garde la semantique de c(AD = ..., CvM = ...) : vecteur numerique nomme dans
# l'ordre du catalogue. Une erreur de calcul se propage a l'appelant (dans le
# bootstrap, la replication est alors ecartee).
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
  do.call(c, vals)
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
engine_p_mc <- function(sim, obs, queue) {
  if (length(queue) != 1L || !queue %in% c("haut", "bas", "deux"))
    stop("engine_p_mc() : sens de rejet inconnu : ", paste(queue, collapse = ", "))
  fin <- is.finite(sim)
  B_eff <- as.numeric(sum(fin))
  s <- sim[fin]
  p <- if (!length(s) || !is.finite(obs)) NA_real_ else
    switch(queue,
           haut = (1 + sum(s >= obs)) / (length(s) + 1),
           bas  = (1 + sum(s <= obs)) / (length(s) + 1),
           deux = 2 * min((1 + sum(s >= obs)) / (length(s) + 1),
                          (1 + sum(s <= obs)) / (length(s) + 1)))
  p <- pmin(p, 1)
  k <- if (queue == "deux") 2 else 1
  list(p_mc = p, err_mc = sqrt(p * (k - p) / pmax(B_eff, 1)), B_effectif = B_eff,
       granularite = if (B_eff > 0) k / (B_eff + 1) else NA_real_)
}

# Applique engine_p_mc() a chaque colonne de la matrice des simulations, le
# sens du rejet etant lu au catalogue. Une statistique absente du catalogue
# leve une erreur.
.mc_p_values <- function(sim, obs, catalogue) {
  noms <- colnames(sim)
  inconnus <- setdiff(noms, names(catalogue))
  if (length(inconnus))
    stop("statistique(s) Monte-Carlo absente(s) du catalogue : ",
         paste(inconnus, collapse = ", "))
  r <- lapply(noms, function(nm) engine_p_mc(sim[, nm], obs[[nm]], catalogue[[nm]]$queue))
  champ <- function(k) stats::setNames(vapply(r, function(o) o[[k]], numeric(1)), noms)
  list(p_mc = champ("p_mc"), err_mc = champ("err_mc"), B_effectif = champ("B_effectif"),
       granularite = champ("granularite"))
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
engine_registre_tests <- function(boot, catalogue, alpha, nature_mc) {
  pmc <- boot$p_mc; emc <- boot$err_mc
  L <- list()
  add <- function(fam, nom, ref, type = "test",
                  H0 = NA_character_, H1 = NA_character_,
                  stat_nom = NA_character_, stat = NA_real_,
                  loi = NA_character_,
                  estim_nom = NA_character_, estim = NA_real_,
                  p_ex = NA_real_, p_as = NA_real_, mc_nom = NA_character_,
                  detail = "", verdict = NULL, sens = "ne pas rejeter",
                  motif_non_mc = NA_character_, nature_forcee = NA_character_,
                  base = "commun", variante = "principale") {
    # Refus explicite (ADR 0003, point 3) : une statistique Monte-Carlo
    # inconnue du catalogue, ou absente de l'objet bootstrap, est une erreur
    # de programmation ; le repli silencieux sur l'asymptotique est interdit.
    if (!is.na(mc_nom)) {
      if (!mc_nom %in% names(catalogue))
        stop("add() : statistique Monte-Carlo inconnue du catalogue : ", mc_nom, " (", nom, ")")
      if (!mc_nom %in% names(pmc) || !mc_nom %in% names(emc))
        stop("add() : statistique Monte-Carlo absente du bootstrap : ", mc_nom, " (", nom, ")")
    }
    p_mc <- if (!is.na(mc_nom)) unname(pmc[[mc_nom]]) else NA_real_
    e_mc <- if (!is.na(mc_nom)) unname(emc[[mc_nom]]) else NA_real_
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
      if (p_ret < alpha) "OK" else if (p_ret < 0.30) "ALERTE" else "ECHEC"
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
      verdict = v, detail = detail, sens = sens)
  }
  list(add = add, lignes = function() L)
}

usp_bootstrap <- function(fit, B = 999, seed = 20260831, refit = TRUE,
                          progres = FALSE) {
  # Tirages sous graine locale (ADR 0004, #42) : etat de l'appelant restaure.
  engine_sous_graine(seed, {
    stats_obs <- .stats_bootstrapables(fit$x, fit$y, fit$z)
    noms <- names(stats_obs)
    sim <- matrix(NA_real_, B, length(noms), dimnames = list(NULL, noms))
    sig <- del <- gam <- rep(NA_real_, B)
    for (b in seq_len(B)) {
      yb <- usp_simuler(fit)
      fb <- if (refit) {
        f <- try(usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
        if (inherits(f, "try-error")) next else f
      } else usp_noyau(fit$delta, fit$gamma, fit$x, yb, fit$xbar)
      sb <- try(.stats_bootstrapables(fit$x, yb, fb$z), silent = TRUE)
      if (inherits(sb, "try-error")) next
      sim[b, ] <- sb[noms]
      sig[b] <- fb$sigma
      if (!is.null(fb$delta)) { del[b] <- fb$delta; gam[b] <- fb$gamma }
      if (progres && b %% 100 == 0) cat(".")
    }
    if (progres) cat("\n")
  })

  # P-values de Monte-Carlo, erreur de Monte-Carlo et B effectif, le sens du
  # rejet etant lu au catalogue USP_CATALOGUE_MC.
  mc <- .mc_p_values(sim, stats_obs, USP_CATALOGUE_MC)

  # granularite : 1 / (B + 1) sur B nominal, pas elementaire unilateral (champ
  # affiche par app.R et display_helpers.R). granularite_stat : pas par
  # statistique, 1 / (B_eff + 1), ou 2 / (B_eff + 1) en bilateral (issue #40) ;
  # place en fin de liste pour ne pas deplacer les champs existants.
  list(stats_obs = as.list(stats_obs), p_mc = mc$p_mc, err_mc = mc$err_mc,
       B_effectif = mc$B_effectif, granularite = 1 / (B + 1),
       sigma_boot = sig[is.finite(sig)],
       delta_boot = del[is.finite(del)], gamma_boot = gam[is.finite(gam)], B = B,
       granularite_stat = mc$granularite)
}

# Réajustement rapide (un seul démarrage, à partir de l'optimum observé).
usp_ajuster_rapide <- function(x, y, d0, g0) {
  xbar <- mean(x)
  f <- stats::optim(c(d0, g0), usp_objectif, x = x, y = y, xbar = xbar,
                    method = "L-BFGS-B",
                    lower = c(0, BORNES_GAMMA[1]), upper = c(1, BORNES_GAMMA[2]),
                    control = list(factr = 1e7, maxit = 200))
  k <- usp_noyau(f$par[1], f$par[2], x, y, xbar)
  c(k, list(delta = f$par[1], gamma = f$par[2], T = length(x),
            x = x, y = y, xbar = xbar))
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

usp_profil <- function(fit, n = 41) {
  gd <- seq(0, 1, length.out = n)
  pd <- vapply(gd, function(d) {
    o <- stats::optimize(function(g) usp_objectif(c(d, g), fit$x, fit$y, fit$xbar),
                         interval = BORNES_GAMMA)
    o$objective
  }, numeric(1))
  gg <- seq(fit$gamma - 1.5, fit$gamma + 1.5, length.out = n)
  pg <- vapply(gg, function(g) {
    o <- stats::optimize(function(d) usp_objectif(c(d, g), fit$x, fit$y, fit$xbar),
                         interval = c(0, 1))
    o$objective
  }, numeric(1))
  # Tests du rapport de vraisemblance sur les cas limites de delta.
  lr <- function(d) {
    o <- stats::optimize(function(g) usp_objectif(c(d, g), fit$x, fit$y, fit$xbar),
                         interval = BORNES_GAMMA)$objective
    st <- o - fit$obj_min
    list(stat = st, p = .p_borne(1 - stats::pchisq(st, 1)))
  }
  list(delta_grid = gd, delta_obj = pd, gamma_grid = gg, gamma_obj = pg,
       lr_delta0 = lr(0), lr_delta1 = lr(1))
}


## =============================================================================
## 6. BATTERIE DE TESTS COMPLÈTE
## =============================================================================

usp_tests <- function(fit, boot, alpha = 0.10,
                      theta_equiv = 0.10, delta_equiv = NULL,
                      robustesse = NULL) {
  z <- fit$z; x <- fit$x; y <- fit$y; T <- fit$T
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

  ## --- B. H1 : E[Y_t] lineaire proportionnelle en X_t ------------------------
  fam <- "B. H1 - linearite / proportionnalite (annexe XVII B(2)(f)(i))"
  ti <- test_intercept(x, y); lmc <- test_lm_complet(x, y)
  # p-value EXACTE prioritaire : sous normalite des erreurs, t_a suit
  # exactement une loi de Student a T-2 ddl. La p-value de Monte-Carlo reste
  # calculee et affichee, mais a titre de complement seulement.
  add(fam, "Nullite de la constante (proportionnalite stricte)",
      "Student (1908), Biometrika 6",
      type = if (is.finite(ti$stat)) "test" else "non applicable",
      H0 = "a = 0 (proportionnalite stricte)", H1 = "a != 0",
      stat_nom = "t", stat = ti$stat,
      loi = sprintf("t(%d) EXACTE sous normalite des erreurs", T - 2),
      estim_nom = "constante a",
      estim = if (is.finite(ti$stat)) unname(stats::coef(lmc$modele)[1]) else NA_real_,
      p_ex = ti$p, mc_nom = "Intercept",
      detail = paste("Le NON-rejet ne prouve pas la proportionnalite :",
                     "voir le test d'equivalence ci-dessous."))
  tost <- test_tost_intercept(x, y, theta = theta_equiv, delta_abs = delta_equiv)
  add(fam, "Equivalence de la constante a zero (TOST)",
      "Schuirmann (1987), J. Pharmacokinet. Biopharm. 15",
      type = if (is.finite(tost$p)) "test" else "non applicable",
      H0 = "|a| >= Delta (la constante n'est PAS negligeable)",
      H1 = "|a| < Delta (constante negligeable : proportionnalite pratique)",
      stat_nom = "t (max des 2 unilateraux)", stat = tost$stat,
      loi = if (isTRUE(tost$marge_a_priori))
        sprintf("t(%d) EXACTE (marge fixee a priori)", T - 2)
      else sprintf("t(%d) ; marge estimee sur les donnees -> exactitude approchee", T - 2),
      estim_nom = "marge Delta", estim = tost$delta,
      p_ex = if (isTRUE(tost$marge_a_priori)) tost$p else NA_real_,
      p_as = if (isTRUE(tost$marge_a_priori)) NA_real_ else tost$p,
      nature_forcee = if (isTRUE(tost$marge_a_priori)) NA_character_
                      else "quasi-exacte (loi de Student ; marge estimee sur les donnees)",
      sens = "rejeter",
      # Issue #58 : un detail de longueur 1 sur chaque branche.
      detail = switch(if (is.na(tost$non_applicable)) "calcule" else tost$non_applicable,
        "volumes constants" = paste("x_t constant (volumes constants) : regression de y",
                                    "sur x non definie, test non applicable"),
        "marge" = paste("marge Delta invalide (sans delta_equiv : theta_equiv non",
                        "fini ou <= 0 ; ou delta_equiv non fini ou <= 0) : test",
                        "non applicable"),
        # La valeur de Delta n'est pas imprimee (elle est dans estim) : sur
        # les donnees de test, 0,1 * moyenne(y) = 8,5005 tombe sur un point
        # de bascule de %.4g, et une perturbation relative de 1e-12 des
        # donnees faisait passer le texte de "8.501" a "8.5" (issue #22,
        # test anti-bruit).
        "calcule" = sprintf(paste("Rejeter H0 fournit une preuve POSITIVE de proportionnalite.",
                                  "Delta = %s (valeur : estimation \"marge Delta\") ;",
                                  "p_bas = %.4f, p_haut = %.4f."),
                            if (isTRUE(tost$marge_a_priori)) "marge fixee a priori"
                            else sprintf("%.0f %% de la moyenne de y", 100 * theta_equiv),
                            tost$p_bas, tost$p_haut),
        stop("usp_tests : motif TOST inconnu : ", tost$non_applicable)))
  add(fam, "Test de Student sur la pente (lm(y~x))",
      "Student (1908), Biometrika 6",
      type = if (is.finite(lmc$t_pente)) "test" else "non applicable",
      H0 = "b = 0 (aucun lien volume / pertes)", H1 = "b != 0",
      stat_nom = "t", stat = lmc$t_pente, loi = sprintf("t(%d)", T - 2),
      estim_nom = "pente b", estim = lmc$pente,
      p_as = lmc$p_pente, sens = "rejeter",
      motif_non_mc = "H0 non simulable : le modele ajuste appartient a H1",
      detail = "Loi EXACTE sous normalite des erreurs. Ici on souhaite REJETER H0")
  add(fam, "Test de Fisher (significativite globale)", "Fisher (1922, 1925)",
      type = if (is.finite(lmc$F)) "test" else "non applicable",
      H0 = "b = 0", H1 = "b != 0",
      stat_nom = "F", stat = lmc$F,
      loi = if (is.finite(lmc$F)) sprintf("F(%d,%d)", lmc$ddl1, lmc$ddl2) else NA_character_,
      p_as = lmc$p_F, sens = "rejeter",
      motif_non_mc = "H0 non simulable : le modele ajuste appartient a H1",
      detail = "Loi EXACTE sous normalite. Equivaut a t^2 en regression simple")
  add(fam, "Coefficient de determination R2", "lm(y ~ x)",
      type = if (is.finite(lmc$R2)) "diagnostic" else "non applicable",
      estim_nom = "R2", estim = lmc$R2,
      detail = if (is.finite(lmc$R2))
        sprintf("R2 ajuste = %.4f ; sous H0 (b=0) E[R2] = 1/(T-1) = %.3f ; repere conventionnel R2 < 0.5 : %s. Diagnostic, pas un test",
                lmc$R2_ajuste, 1 / (T - 1),
                if (lmc$R2 < 0.5) "en dessous" else "au-dessus") else "x_t constant : R2 non defini")
  tr <- test_reset(x, y)
  add(fam, "RESET (forme fonctionnelle)", "Ramsey (1969), JRSS B 31",
      H0 = "gamma2 = gamma3 = 0 (forme lineaire correcte)",
      H1 = "forme fonctionnelle mal specifiee",
      stat_nom = "F", stat = tr$stat, loi = sprintf("F(2,%d) approx.", T - 3),
      p_as = tr$p, mc_nom = "RESET",
      detail = "La loi F n'est PAS exacte : les regresseurs auxiliaires y^2, y^3 dependent de y")
  if (stats::sd(x) > 0) {
    cs_ex <- suppressWarnings(try(stats::cor.test(r, x, method = "spearman", exact = TRUE),
                                  silent = TRUE))
    cs <- suppressWarnings(stats::cor.test(r, x, method = "spearman", exact = FALSE))
    add(fam, "Independance ratio S/P vs volume", "Spearman (1904) ; exact : Best & Roberts (1975), AS 89",
        H0 = "independance (aucune association monotone)", H1 = "association monotone",
        stat_nom = "S", stat = unname(cs$statistic),
        loi = "permutation exacte (T <= 9, sans ex aequo)",
        estim_nom = "rho_s", estim = unname(cs$estimate),
        p_ex = if (!inherits(cs_ex, "try-error")) cs_ex$p.value else NA_real_,
        p_as = cs$p.value, mc_nom = "SpearVol",
        detail = "Une correlation signale un effet d'echelle non modelise")
  } else {
    add(fam, "Independance ratio S/P vs volume", "Spearman (1904)",
        type = "non applicable", detail = "x_t constant : test non applicable")
  }
  ct_ex <- suppressWarnings(try(stats::cor.test(r, seq_along(r), method = "spearman",
                                                exact = TRUE), silent = TRUE))
  ct <- suppressWarnings(stats::cor.test(r, seq_along(r), method = "spearman", exact = FALSE))
  add(fam, "Correlation ratio S/P vs temps", "Spearman (1904) ; exact : Best & Roberts (1975)",
      H0 = "independance entre le ratio et le rang chronologique",
      H1 = "association monotone avec le temps",
      stat_nom = "S", stat = unname(ct$statistic),
      loi = "permutation exacte (T <= 9, sans ex aequo)",
      estim_nom = "rho_s", estim = unname(ct$estimate),
      p_ex = if (!inherits(ct_ex, "try-error")) ct_ex$p.value else NA_real_,
      p_as = ct$p.value, mc_nom = "SpearTps")
  mk <- test_mann_kendall(r)
  add(fam, "Tendance monotone du ratio S/P",
      "Mann (1945) ; loi exacte : Kendall & Gibbons (1990), ch. 4-5",
      H0 = "absence de tendance monotone (r_t i.i.d.)", H1 = "tendance monotone",
      stat_nom = "Z", stat = mk$stat,
      loi = "loi exacte de S (distribution mahonienne)",
      estim_nom = "S de Kendall", estim = mk$S,
      p_ex = mk_p_exacte(r), p_as = mk$p, mc_nom = "MK",
      detail = "Une derive du S/P contredit la constance de beta")
  cx <- test_cox_stuart(r); m_paires <- T - ceiling(T / 2)
  add(fam, "Tendance par signes du ratio S/P", "Cox & Stuart (1955), Biometrika 42",
      H0 = "P(D_t > 0) = 1/2 (absence de tendance)", H1 = "P(D_t > 0) != 1/2",
      stat_nom = "K", stat = cx$stat,
      loi = paste("Binomiale(m, 1/2) EXACTE, m differences non nulles ;",
                  "p_mc par |K - n_p/2|, n_p paires, queue haute"),
      p_ex = cx$p, mc_nom = "CoxStuart",
      detail = sprintf("m = %d paires ; p bilaterale minimale atteignable = %.4f",
                       m_paires, 2 * 0.5^m_paires))

  ## --- C. H2 : variance quadratique en X_t -----------------------------------
  fam <- "C. H2 - structure de variance (annexe XVII B(2)(f)(ii))"
  bp <- test_breusch_pagan(z^2, x)
  add(fam, "Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)",
      "Breusch & Pagan (1979) ; studentisation de Koenker (1981)",
      H0 = "c1 = 0 : la variance des residus standardises ne depend pas du volume",
      H1 = "variance residuelle dependante du volume",
      stat_nom = "LM", stat = bp$stat, loi = "chi2(1) asymptotique",
      p_as = bp$p, mc_nom = "BP",
      detail = "Doit etre non significatif si la ponderation pi_t est correcte")
  bp79 <- test_breusch_pagan_original(z^2, x)
  add(fam, "Heteroscedasticite vs volume - Breusch-Pagan original (non robuste)",
      "Breusch & Pagan (1979), Econometrica 47",
      variante = "secondaire",
      H0 = "c1 = 0 ET erreurs normales : variance residuelle independante du volume",
      H1 = "variance residuelle dependante du volume",
      stat_nom = "LM", stat = bp79$stat, loi = "chi2(1) asymptotique, SOUS NORMALITE",
      p_as = bp79$p, mc_nom = "BP79",
      detail = paste("Version publiee, avec le facteur 1/2 issu de Var(u^2) = 2 sigma^4.",
                     "NON ROBUSTE : sur-rejette si les erreurs ne sont pas normales.",
                     "A confronter systematiquement a la version de Koenker ci-dessus."))
  wh <- test_white(z^2, x)
  add(fam, "Heteroscedasticite (forme quadratique)", "White (1980), Econometrica 48",
      H0 = "c1 = c2 = 0", H1 = "heteroscedasticite residuelle de forme quadratique",
      stat_nom = "LM", stat = wh$stat, loi = "chi2(2) asymptotique",
      p_as = wh$p, mc_nom = "White")
  gq <- test_goldfeld_quandt(z, x)
  add(fam, "Egalite des variances petits vs gros volumes",
      "Goldfeld & Quandt (1965), JASA 60",
      H0 = "sigma1^2 = sigma2^2", H1 = "variances inegales entre les deux blocs",
      stat_nom = "F", stat = gq$stat,
      loi = sprintf("F(%d,%d) approx. (residus issus d'un ajustement global)",
                    floor(T / 2), floor(T / 2)),
      p_as = gq$p, mc_nom = "GQ")
  bf <- test_brown_forsythe(z, x)
  add(fam, "Homogeneite des dispersions (mediane)",
      "Brown & Forsythe (1974), JASA 69",
      H0 = "egalite des dispersions entre les deux groupes",
      H1 = "dispersions inegales",
      stat_nom = "W", stat = bf$stat, loi = sprintf("F(1,%d) approx.", T - 2),
      p_as = bf$p, mc_nom = "BF")
  if (T >= 8 && stats::sd(x) > 0) {
    grp <- x > stats::median(x)
    if (sum(grp) >= 3 && sum(!grp) >= 3) {
      ks2 <- suppressWarnings(stats::ks.test(z[grp], z[!grp]))
      add(fam, "Egalite des lois petits vs gros volumes (2 ech.)", "Smirnov (1939)",
          H0 = "F1 = F2 (memes lois)", H1 = "lois differentes",
          stat_nom = "D", stat = unname(ks2$statistic),
          loi = "exacte combinatoire (ks.test, sans ex aequo)",
          p_ex = ks2$p.value, mc_nom = "Smirnov",
          detail = "Voir aussi le QQ-plot a deux echantillons")
    }
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
  reg_delta <- usp_regime(fit$delta, fit$x)
  suite_cst <- paste(", qui n'est pas identifie ; la valeur affichee est celle",
                     "ou l'optimiseur s'est arrete")
  add(fam, "Position de delta dans [0,1]", "Annexe XVII, section B/C par. 6",
      type = "diagnostic", estim_nom = "delta", estim = fit$delta,
      detail = if (isTRUE(reg_delta$volumes_dans_bande))
        paste0(sprintf(paste("VOLUMES CONSTANTS a la tolerance TOL_DELTA_BORD = %g pres",
                             "(etendue relative = %.2g) : la vraisemblance ne depend",
                             "presque pas de delta"),
                       TOL_DELTA_BORD, diff(range(fit$x)) / mean(fit$x)), suite_cst)
      else if (isTRUE(reg_delta$volumes_constants))
        paste0("VOLUMES CONSTANTS : la vraisemblance ne depend pas de delta", suite_cst)
      else if (isTRUE(fit$delta_au_bord))
        "SOLUTION AU BORD : structure de variance non identifiee par les donnees"
      else "interieur du domaine : melange des deux composantes identifie")

  ## --- D. H3 : lognormalite --------------------------------------------------
  fam <- "D. H3 - lognormalite (annexe XVII B(2)(f)(iii))"
  H0n <- "les residus standardises suivent une loi normale"
  H1n <- "loi non normale"
  sw <- .shapiro_sur(z)
  add(fam, "Shapiro-Wilk sur residus standardises", "Shapiro & Wilk (1965), Biometrika 52",
      H0 = H0n, H1 = H1n, stat_nom = "W", stat = sw$stat,
      loi = "aucune forme fermee ; normalisation de Royston (1992)",
      p_as = sw$p, mc_nom = "SW")
  add(fam, "Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston)",
      "Shapiro & Wilk (1965) ; loi nulle evaluee par simulation directe",
      variante = "secondaire",
      H0 = H0n, H1 = H1n, stat_nom = "W", stat = sw$stat,
      loi = "loi exacte de W sous normalite, evaluee numeriquement (20 000 tirages)",
      p_ex = sw_p_loi_nulle(sw$stat, T),
      detail = paste("W etant invariant par translation et changement d'echelle,",
                     "sa loi nulle ne depend d'aucun parametre : la simulation est",
                     "independante du modele USP ajuste (ce n'est pas un bootstrap)."))
  sf <- test_shapiro_francia(z)
  add(fam, "Shapiro-Francia", "Shapiro & Francia (1972), JASA 67 ; Royston (1993)",
      H0 = H0n, H1 = H1n, stat_nom = "W'", stat = sf$stat,
      loi = "aucune forme fermee ; normalisation de Royston (1993)",
      p_as = sf$p, mc_nom = "SF")
  add(fam, "Anderson-Darling", "Anderson & Darling (1954), JASA 49",
      H0 = H0n, H1 = H1n, stat_nom = "A2", stat = boot$stats_obs$AD,
      loi = "loi AD, cas parametres estimes ; approximation de Stephens",
      p_as = ad_p_stephens(boot$stats_obs$AD, T), mc_nom = "AD",
      detail = paste("Sensible aux queues. p non simulee disponible :",
                     "ajustement empirique de D'Agostino & Stephens (1986)."))
  add(fam, "Cramer-von Mises", "Cramer (1928) / von Mises (1928) ; Stephens (1974)",
      H0 = H0n, H1 = H1n, stat_nom = "W2", stat = boot$stats_obs$CvM,
      loi = "loi CvM, cas parametres estimes ; approximation de Stephens",
      p_as = cvm_p_stephens(boot$stats_obs$CvM, T), mc_nom = "CvM")
  add(fam, "Kolmogorov-Smirnov contre N(0,1)", "Kolmogorov (1933) ; Smirnov (1948)",
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
      "Lilliefors (1967), JASA 62 ; p-value : Dallal & Wilkinson (1986)",
      H0 = H0n, H1 = H1n, stat_nom = "D", stat = Dl,
      loi = "loi de Lilliefors (moyenne et ecart-type estimes)",
      p_as = lillie_p(Dl, T), mc_nom = "Lillie",
      detail = paste("Distinct du KS contre N(0,1) : la loi de reference tient compte",
                     "de l'estimation des parametres. Appliquer la loi de Kolmogorov",
                     "dans ce cas rend le test extremement conservateur."))
  jb <- test_jarque_bera(z)
  add(fam, "Jarque-Bera", "Jarque & Bera (1980, 1987)",
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
        H0 = "coefficient d'asymetrie de la population nul", H1 = "asymetrie non nulle",
        stat_nom = "Z", stat = ds$stat, loi = "N(0,1) approx. (transformation de Johnson SU)",
        estim_nom = "asymetrie", estim = jb$skew, p_as = ds$p, mc_nom = "DAgo")
  else
    add(fam, "Asymetrie (D'Agostino, T >= 8)", "D'Agostino (1970), Biometrika 57",
        type = "non applicable", estim_nom = "asymetrie", estim = jb$skew,
        detail = sprintf("T = %d < 8 : transformation normalisante non definie", T))
  ak <- test_anscombe_kurt(z)
  if (is.finite(ak$stat))
    add(fam, "Aplatissement (Anscombe-Glynn, T >= 20)", "Anscombe & Glynn (1983), Biometrika 70",
        H0 = "aplatissement de la population egal a 3", H1 = "aplatissement different de 3",
        stat_nom = "Z", stat = ak$stat, loi = "N(0,1) approx. (Wilson-Hilferty)",
        estim_nom = "aplatissement", estim = jb$kurt, p_as = ak$p)
  else
    add(fam, "Aplatissement (Anscombe-Glynn, T >= 20)", "Anscombe & Glynn (1983), Biometrika 70",
        type = "non applicable", estim_nom = "aplatissement", estim = jb$kurt,
        detail = sprintf("T = %d < 20 : test non defini", T))

  ## --- E. H4 : independance / validite du MV ---------------------------------
  fam <- "E. H4 - independance et validite du MV (annexe XVII B(2)(f)(iv))"
  add(fam, "Autocorrelation d'ordre 1 (Durbin-Watson)", "Durbin & Watson (1950, 1951)",
      base = "z",
      H0 = "rho = 0 (absence d'autocorrelation d'ordre 1)", H1 = "rho != 0",
      stat_nom = "DW", stat = boot$stats_obs$DW,
      loi = "forme quadratique en normales ; loi EXACTE par la methode d'Imhof (1961)",
      p_ex = dw_p_exacte(z), mc_nom = "DW",
      detail = paste("Statistique calculee sur residus CENTRES. Les bornes d_L/d_U,",
                     "etablies pour des residus MCO, ne sont pas utilisees : la loi",
                     "exacte est obtenue par integration numerique d'Imhof."))
  lb1 <- stats::Box.test(z, lag = 1, type = "Ljung-Box")
  add(fam, "Ljung-Box (retard 1)", "Ljung & Box (1978), Biometrika 65",
      base = "z",
      H0 = "rho_1 = 0", H1 = "autocorrelation au retard 1",
      stat_nom = "Q", stat = unname(lb1$statistic), loi = "chi2(1) asymptotique",
      p_as = lb1$p.value, mc_nom = "LB1")
  if (T >= 8) {
    lb2 <- stats::Box.test(z, lag = 2, type = "Ljung-Box")
    add(fam, "Ljung-Box (retard 2)", "Ljung & Box (1978), Biometrika 65",
        H0 = "rho_1 = rho_2 = 0", H1 = "autocorrelation jusqu'au retard 2",
        stat_nom = "Q", stat = unname(lb2$statistic), loi = "chi2(2) asymptotique",
        p_as = lb2$p.value, mc_nom = "LB2")
    bp2 <- stats::Box.test(z, lag = 2, type = "Box-Pierce")
    add(fam, "Box-Pierce (retard 2)", "Box & Pierce (1970), JASA 65",
        H0 = "rho_1 = rho_2 = 0", H1 = "autocorrelation jusqu'au retard 2",
        variante = "secondaire",
        stat_nom = "Q", stat = unname(bp2$statistic), loi = "chi2(2) asymptotique",
        p_as = bp2$p.value, mc_nom = "BP2")
  }
  ru <- test_runs(z)
  add(fam, "Test des suites (aleatoire des signes)",
      base = "z",
      "Wald & Wolfowitz (1940) ; loi exacte : Swed & Eisenhart (1943)",
      H0 = "la suite des signes est un arrangement aleatoire",
      H1 = "arrangement non aleatoire (regroupement ou alternance)",
      stat_nom = "Z", stat = ru$stat, loi = "loi combinatoire EXACTE de R",
      estim_nom = "nb de suites R", estim = ru$runs,
      p_ex = runs_p_exacte(z), p_as = ru$p, mc_nom = "Runs")
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
  # melange).
  regime <- usp_regime(fit$delta, fit$x)
  pi_constant <- regime$pi_constant
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
  # de test) : cette somme vaut -3,3e-06 a delta = 0, T = 5 (volumes
  # variables, somme(z_t^2) - T = -1,07e-02), -5,4e-06 a delta = 1 ; elle
  # est de l'ordre de 1e-07 a delta = 0, T = 5 apres raffinement de gamma
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
  # tolerance d'arret (-5,4e-6 sur l'ajustement des donnees de test). Voir le
  # commentaire de usp_regime() pour le cas des volumes quasi constants.
  # 1 - delta est affiche plutot que delta : "%g" rendrait 1 - 5e-7 par "1".
  ecart_tol <- local({
    e <- character(0)
    if (regime$delta_dans_bande)
      e <- c(e, sprintf("1 - delta = %.2g", 1 - fit$delta))
    if (regime$volumes_dans_bande)
      e <- c(e, sprintf("etendue relative des volumes = %.2g",
                        diff(range(fit$x)) / mean(fit$x)))
    paste(e, collapse = ", ")
  })
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
      type = "diagnostic", estim_nom = "moyenne(z)", estim = mean(z),
      detail = paste("Grandeur rivee par l'estimation :",
                     "somme(sqrt(pi_t) z_t) = 0 par condition du premier ordre,",
                     "d'ou moyenne(z) = 0 lorsque pi_t est constant.",
                     contrainte("centrage"), sans_p))
  add(fam, "Variance unitaire des residus standardises", "Diagnostic d'echelle (ADR 0001)",
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
      base = "z",
      H0 = "E[z_t] constant (absence de rupture)", H1 = "rupture de niveau a une date inconnue",
      stat_nom = "supF", stat = boot$stats_obs$supF,
      loi = "supremum de processus (Andrews) -> Monte-Carlo", mc_nom = "supF",
      detail = "La loi de Fisher est inapplicable : le point de rupture est estime")
  add(fam, "Stabilite cumulee (OLS-CUSUM)", "Brown, Durbin & Evans (1975), JRSS B 37",
      base = "z",
      H0 = "constance des parametres sur la periode", H1 = "derive graduelle",
      stat_nom = "CUSUM", stat = boot$stats_obs$CUSUM,
      loi = "sup |pont brownien| ; formule de Kolmogorov asymptotique",
      p_as = { cc <- boot$stats_obs$CUSUM
               if (is.finite(cc)) .p_borne(2 * sum((-1)^(0:99) *
                 exp(-2 * (1:100)^2 * cc^2))) else NA_real_ },
      mc_nom = "CUSUM",
      detail = "La formule asymptotique n'a aucune validite a T = 8 : p_mc retenue")
  gr <- test_grubbs(z)
  add(fam, "Valeur aberrante isolee (Grubbs)", "Grubbs (1950, 1969), Technometrics 11",
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
      type = "procedure de decision",
      H0 = "aucune valeur aberrante", H1 = "il existe i <= k valeurs aberrantes",
      estim_nom = "nb de valeurs aberrantes", estim = ro$nb_outliers,
      detail = sprintf("procedure a niveau alpha = %.2f (aucune p-value)%s", alpha,
                       if (ro$nb_outliers > 0)
                         paste0(" ; rangs ", paste(ro$positions, collapse = ", ")) else ""),
      verdict = if (ro$nb_outliers >= 2) "ECHEC"
                else if (ro$nb_outliers == 1) "ALERTE" else "OK")
  mlm <- stats::lm(y ~ x - 1); ck <- stats::cooks.distance(mlm); hv <- stats::hatvalues(mlm)
  add(fam, "Points influents (distance de Cook)", "Cook (1977), Technometrics 19",
      type = "diagnostic", estim_nom = "max D_t", estim = max(ck),
      detail = sprintf("repere conventionnel 4/T = %.3f ; %d observation(s) au-dessus%s",
                       4 / T, sum(ck > 4 / T),
                       if (any(ck > 4 / T))
                         paste0(" (rangs ", paste(which(ck > 4 / T), collapse = ", "), ")") else ""))
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
  detail_runsr <- if (is.finite(p_ex_r)) {
    d1 <- paste("CONTROLE SANS OBJET ICI : pi_t est constant (delta = 1, ou volumes",
                "x_t constants), il n'y a donc aucun artefact de ponderation a",
                "detecter. Cette ligne est un quasi-doublon de son homologue sur",
                "residus standardises : les signes de u_t - med(u) et de z_t - med(z)",
                "coincident (z_t est une transformation croissante de r_t), la",
                "statistique des suites est IDENTIQUE a celle de la ligne sur residus",
                "standardises. Les r_t etant i.i.d. sous le modele ajuste, la loi",
                "combinatoire de R s'applique aussi aux ratios bruts : la p-value",
                "EXACTE est retenue (convention bilaterale du doublement, celle du",
                "bootstrap), la meme que sur la ligne des suites sur residus",
                "standardises (issue #29). La p-value Monte-Carlo de la colonne p_mc",
                "estime la meme quantite, a l'erreur Monte-Carlo pres.")
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
      "Monte-Carlo, simulee sous le modele ajuste, est retenue."),
      TOL_DELTA_BORD, ecart_tol)
  } else if (isTRUE(pi_constant)) {
    paste(note_r, "La loi combinatoire de R n'est pas definie ici (un seul cote",
          "de la mediane represente) : aucune p-value exacte (issue #29).")
  } else {
    paste("pi_t varie avec t : sous le modele ajuste, les r_t sont independants",
          "mais heteroscedastiques (echelle 1/sqrt(pi_t) et mediane propres a",
          "chaque annee), les arrangements des signes de u_t - med(u) ne sont pas",
          "equiprobables et la loi combinatoire de R n'est qu'une approximation,",
          "sans borne d'erreur connue a T = 8. Seule la p-value Monte-Carlo,",
          "simulee sous le modele ajuste avec ses pi_t, est retenue ; la",
          "statistique differe en general de celle de la ligne des suites sur",
          "residus standardises (issue #29).")
  }
  add("E. H4 - independance et validite du MV (annexe XVII B(2)(f)(iv))",
      "Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts",
      "Durbin & Watson (1950, 1951)", base = "r",
      H0 = "absence d'autocorrelation d'ordre 1 du ratio S/P",
      H1 = "autocorrelation du ratio S/P",
      stat_nom = "DW", stat = boot$stats_obs$DWr, loi = loi_ind, mc_nom = "DWr",
      detail = detail_r())
  add("E. H4 - independance et validite du MV (annexe XVII B(2)(f)(iv))",
      "Ljung-Box (retard 1) sur ratios bruts", "Ljung & Box (1978), Biometrika 65",
      base = "r", H0 = "rho_1 = 0 pour le ratio S/P", H1 = "autocorrelation au retard 1",
      stat_nom = "Q", stat = boot$stats_obs$LB1r, loi = loi_ind, mc_nom = "LB1r",
      detail = detail_r())
  add("E. H4 - independance et validite du MV (annexe XVII B(2)(f)(iv))",
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
      detail = detail_runsr)
  add(fam, "Rupture de niveau (sup-F) sur ratios bruts",
      "Quandt (1960) / Chow (1960) ; Andrews (1993)", base = "r",
      H0 = "niveau du ratio S/P constant", H1 = "rupture de niveau du ratio S/P",
      stat_nom = "supF", stat = boot$stats_obs$supFr,
      loi = "supremum de processus -> Monte-Carlo", mc_nom = "supFr",
      detail = detail_r("Detecte un changement de regime du ratio, independamment du modele."))
  add(fam, "Stabilite cumulee (OLS-CUSUM) sur ratios bruts",
      "Brown, Durbin & Evans (1975), JRSS B 37", base = "r",
      H0 = "constance du niveau du ratio S/P", H1 = "derive graduelle",
      stat_nom = "CUSUM", stat = boot$stats_obs$CUSUMr,
      loi = "sup |pont brownien| -> Monte-Carlo", mc_nom = "CUSUMr",
      detail = detail_r())
  add(fam, "Valeur aberrante isolee (Grubbs) sur ratios bruts",
      "Grubbs (1950, 1969), Technometrics 11", base = "r",
      H0 = "aucun ratio S/P aberrant", H1 = "exactement un ratio aberrant",
      stat_nom = "G", stat = boot$stats_obs$Grubbsr, loi = loi_ind,
      estim_nom = "rang du ratio extreme",
      estim = { g <- test_grubbs(u); if (is.finite(g$stat)) g$idx else NA_real_ },
      mc_nom = "Grubbsr",
      detail = detail_r("Identifie l'annee au boni/mali le plus atypique, sans passer par le modele."))

  add(fam, "Leviers (hat values)", "Hoaglin & Welsch (1978), Amer. Statist. 32",
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
        "Quenouille (1949) / Tukey (1958)", type = "diagnostic",
        estim_nom = "ecart relatif max", estim = fit$ecart_jackknife,
        detail = if (!is.null(rb$jack_annee))
          sprintf("Annee la plus influente : %d (sigma_USP %s).", as.integer(rb$jack_annee),
                  if (rb$jack_usp < 0) "en baisse" else if (rb$jack_usp > 0) "en hausse"
                  else "inchange")
        else "Annee la plus influente non determinee.")
  if (!is.null(fit$largeur_ic))
    add(fam, "Largeur relative de l'IC bootstrap 90%", "Efron (1979), Ann. Statist. 7",
        type = "diagnostic",
        estim_nom = "largeur / sigma_USP", estim = fit$largeur_ic,
        detail = "Intervalle bootstrap du parametre retenu : res$ic_bootstrap.")
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
  if (is.character(v)) v <- trimws(v)
  suppressWarnings(as.numeric(v))
}

engine_lire_donnees_csv <- function(df) {
  err <- character(0)
  if (!is.data.frame(df) || !nrow(df))
    return(list(ok = FALSE, erreurs = "Fichier vide ou illisible comme tableau.",
                xt = NULL, yt = NULL, n = 0L))
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
  df <- df[, setdiff(names(df), "i"), drop = FALSE]
  if (!ncol(df)) return(refus("Aucune colonne d'annee de developpement."))
  brut <- lapply(df, function(v) {
    if (is.factor(v)) v <- as.character(v)
    if (is.character(v)) v <- trimws(v)
    v
  })
  num <- lapply(brut, .en_numerique)
  vide <- lapply(brut, function(v) is.na(v) | (is.character(v) & !nzchar(v)))
  illisible <- which(!do.call(cbind, vide) & is.na(do.call(cbind, num)), arr.ind = TRUE)
  if (length(illisible)) {
    k <- utils::head(illisible, 5)
    return(refus(sprintf("Cellule(s) non numerique(s) en %s%s.",
                         paste0("(i=", k[, 1] - 1L, ", j=", k[, 2] - 1L, ")", collapse = ", "),
                         if (nrow(illisible) > 5) sprintf(" et %d autre(s)", nrow(illisible) - 5) else "")))
  }
  m <- unname(do.call(cbind, num))
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
engine_valider_donnees <- function(xt, yt, T_min = 5, theta_equiv = 0.10,
                                   delta_equiv = NULL, methode = NULL,
                                   nature_donnees = NULL) {
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
  if (length(xt) < T_min)
    err <- c(err, sprintf("Annexe XVII, B/C(2)(b) : au moins %d annees consecutives (T = %d).",
                          T_min, length(xt)))
  # Marge du TOST. Un scalaire numerique fini est exige avant toute
  # comparaison (NA, vide, vecteur, texte : refuses, sans erreur R).
  scalaire_fini <- function(v) is.numeric(v) && length(v) == 1L && is.finite(v)
  # Valeur refusee restituee par deparse() : un texte garde ses guillemets
  # ("0.1"), un vecteur sa forme c(...), afin que le motif du refus se voie.
  saisie <- function(v) if (is.null(v) || !length(v)) "vide" else paste(deparse(v), collapse = " ")
  if (!is.null(delta_equiv)) {
    if (!scalaire_fini(delta_equiv) || delta_equiv <= 0)
      err <- c(err, sprintf(paste("Marge Delta du test d'equivalence (delta_equiv = %s) : un nombre",
                                  "fini strictement positif est attendu."),
                            saisie(delta_equiv)))
    else if (is.numeric(yt) && length(yt) && all(is.finite(yt)) &&
             delta_equiv >= mean(yt))
      err <- c(err, sprintf(paste("Marge Delta du test d'equivalence (delta_equiv = %s) superieure",
                                  "ou egale a la perte moyenne (%s) : l'equivalence ne se lirait plus",
                                  "comme une proportionnalite ; 0 < Delta < moyenne(yt) est attendu."),
                            format(delta_equiv), format(mean(yt), digits = 6)))
  } else if (!scalaire_fini(theta_equiv) || theta_equiv <= 0 || theta_equiv >= 1)
    err <- c(err, sprintf(paste("Marge theta du test d'equivalence (theta_equiv = %s) : un nombre",
                                "fini, 0 < theta < 1 (fraction de la perte moyenne), est attendu."),
                          saisie(theta_equiv)))
  if (!length(err)) {
    r <- yt / xt
    if (any(r <= 0 | r >= 5))
      avt <- c(avt, "Ratio y/x hors de la plage plausible ]0 ; 5[ : verifier les unites.")
    if (max(xt) / min(xt) >= 10)
      avt <- c(avt, "Amplitude des volumes >= 10 : rupture de perimetre possible.")
    if (anyDuplicated(data.frame(xt, yt)) > 0)
      avt <- c(avt, "Couples (xt, yt) dupliques detectes.")
    if (length(xt) < 10)
      avt <- c(avt, sprintf(paste("T = %d : credibilite partielle et lois asymptotiques peu",
                                  "fiables. Privilegier les p-values exactes ou Monte-Carlo."),
                            length(xt)))
  }
  list(ok = length(err) == 0, erreurs = err, avertissements = avt, T = length(xt))
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
engine_influence <- function(fit, jackknife = NULL, sigma_usp = NULL) {
  x <- fit$x; y <- fit$y; T <- fit$T
  m <- stats::lm(y ~ x - 1)
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
  do.call(rbind, lapply(niveaux, function(D) {
    r <- sqrt(D * k * (1 - h) / h)
    rbind(data.frame(niveau = D, signe = "+", levier = h, residu = r),
          data.frame(niveau = D, signe = "-", levier = h, residu = -r))
  }))
}

engine_plots_data <- function(fit, boot, profil, jackknife = NULL,
                              sigma_usp = NULL) {
  T <- fit$T; x <- fit$x; z <- fit$z
  qq <- stats::qqnorm(z, plot.it = FALSE)
  # Droite de reference du QQ-plot (quartiles), comme stats::qqline
  qy <- stats::quantile(z, c(0.25, 0.75)); qx <- stats::qnorm(c(0.25, 0.75))
  pente_qq <- diff(qy) / diff(qx); ord_qq <- qy[1] - pente_qq * qx[1]

  # Enveloppe de simulation du QQ-plot : quantiles 5 % et 95 % des
  # statistiques d'ordre de 499 echantillons N(0,1) independants de taille T,
  # sous graine fixe SEED_ENVELOPPE_QQ (consignee dans metadata, issue #37),
  # sans reestimation du modele (l'enveloppe ne depend des
  # donnees que par T). Calibre la lecture visuelle a T faible. Tirages sous
  # graine locale (ADR 0004, #42) : etat de l'appelant restaure.
  ordres <- engine_sous_graine(SEED_ENVELOPPE_QQ, replicate(499, sort(stats::rnorm(T))))
  env <- t(apply(ordres, 1, stats::quantile, probs = c(0.05, 0.95)))

  # QQ-plot a deux echantillons (faible vs fort volume)
  qq2 <- NULL
  if (stats::sd(x) > 0) {
    g <- x > stats::median(x)
    if (sum(g) >= 3 && sum(!g) >= 3) {
      nn <- min(sum(g), sum(!g)); pr <- stats::ppoints(nn)
      qq2 <- data.frame(faible = stats::quantile(sort(z[!g]), pr, type = 7),
                        fort   = stats::quantile(sort(z[g]),  pr, type = 7))
    }
  }
  lo <- stats::lowess(x, sqrt(abs(z)))
  list(
    ajustement = data.frame(x = x, y = fit$y, ajuste = fit$beta * x),
    beta = fit$beta,
    ratio = data.frame(t = seq_len(T), ratio = fit$y / x, niveau = fit$beta),
    qqnorm = data.frame(theorique = qq$x, empirique = qq$y,
                        env_bas = env[order(order(qq$x)), 1],
                        env_haut = env[order(order(qq$x)), 2]),
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
mw_valider_triangle <- function(tri, T_min = 5) {
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
    }
  }
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
    if (nrow(tri) < 10)
      avt <- c(avt, sprintf("I + 1 = %d annees d'accident : credibilite partielle et estimateurs de variance tres bruites en fin de triangle.",
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
  # CAS sigma2_{J-3} = 0 (colonne J-3 a facteurs individuels tous egaux). Le
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
# F(i,j) = C(i,j+1) / C(i,j), i = 0..I-j-1, sont tous egaux a leur moyenne
# ponderee f_j a tol pres en relatif :
#     max_i |F(i,j) - f_j| / |f_j| <= tol   (tol = 1e-12 par defaut).
# C'est la propriete qui annule sigma2_j ; elle est testee sur les facteurs et
# non sur sigma2_j == 0, que l'arrondi rend en general strictement positif
# (voir mw_extrapolation_sigma2()). Le seuil est une convention de
# restitution, pas un seuil statistique (avis d'actuary sur #56) : environ
# 1e4 fois l'epsilon machine, plusieurs ordres de grandeur sous la dispersion
# d'une colonne reelle.
# UNE SEULE DEFINITION dans le moteur : mw_extrapolation_sigma2() (colonnes
# J-3 et J-2) et les trois verifications colonne par colonne de M1
# (mw_test_ordonnee_origine(), mw_test_homogeneite_f(), mw_test_courbure())
# appellent ce predicat. L'exclusion des residus de Mack par mw_residus()
# garde, elle, le critere sigma2_j = 0 exact (alignement renvoye a #60).
# .mw_ecart_facteurs() rend le nombre de facteurs n, f_j et l'ecart relatif
# maximal (NA si la colonne n'a aucun facteur).
.mw_ecart_facteurs <- function(aj, j) {
  if (aj$I - j - 1 < 0) return(list(n = 0L, f = aj$f[j + 1], ecart = NA_real_))
  idx <- 0:(aj$I - j - 1)
  Fij <- aj$tri[idx + 1, j + 2] / aj$tri[idx + 1, j + 1]
  list(n = length(idx), f = aj$f[j + 1],
       ecart = max(abs(Fij - aj$f[j + 1])) / abs(aj$f[j + 1]))
}
.mw_colonne_degeneree <- function(aj, j, tol = 1e-12) {
  e <- .mw_ecart_facteurs(aj, j)$ecart
  is.finite(e) && e <= tol
}
# Ensemble des colonnes j = 0..J-1 degenerees au sens du predicat ci-dessus
# (vecteur d'entiers, eventuellement vide). mw_bootstrap() le calcule UNE FOIS
# sur le triangle observe et le fige pour toutes les replications (#56).
.mw_colonnes_degenerees <- function(aj, tol = 1e-12) {
  j <- 0:(aj$J - 1L)
  as.integer(j[vapply(j, function(k) .mw_colonne_degeneree(aj, k, tol), logical(1))])
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
  # "numeriquement nul" et non "= 0" : la detection porte sur l'ecart relatif
  # des facteurs individuels a 1e-12 pres, si bien qu'une colonne constante a
  # 1e-14 pres donne un sigma2 de l'ordre de 1e-21, non nul. La valeur exacte
  # est imprimee quelques mots plus haut dans la meme chaine. Cette phrase
  # finale ne figure que dans les branches degenerees. Hors degenerescence, le
  # libelle ne peut changer que par la regle ex aequo ci-dessus, qui s'y
  # applique aussi ; pour un minimum unique (triangle de non-regression) il
  # est identique au libelle anterieur (reference reserve2.rds).
  d3 <- isTRUE(ex$degeneree_Jm3)
  d2 <- isTRUE(ex$degeneree_Jm2)
  if (d3 && d2)
    detail <- paste0(detail, ". Colonnes J-3 et J-2 a facteurs individuels tous egaux ",
                     "(sigma2_(J-3) et sigma2_(J-2) numeriquement nuls) : ",
                     "voir l'avertissement sur les donnees")
  else if (d3)
    detail <- paste0(detail, ". Colonne J-3 a facteurs individuels tous egaux ",
                     "(sigma2_(J-3) numeriquement nul) : voir l'avertissement sur les donnees")
  else if (d2)
    detail <- paste0(detail, ". Colonne J-2 a facteurs individuels tous egaux ",
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
  # Avertissement (et non refus) : sigma2_{J-1} = 0 par application litterale
  # du par. 5(d)(ii), ce qui arrive si et seulement si la colonne J-3 ou la
  # colonne J-2 a des facteurs individuels tous egaux (sigma2_{J-3} = 0 ou
  # sigma2_{J-2} = 0 ; voir mw_extrapolation_sigma2). Le cas est licite au
  # regard du texte, qui ne prevoit aucune clause de degenerescence, mais il
  # doit etre VISIBLE : la MSEP ne porte alors aucune variance sur la derniere
  # annee de developpement. UN SEUL avertissement par triangle, de meme
  # squelette quel que soit le chemin (J-3, J-2 ou les deux) : seule la cause
  # varie (issues #7 et #21).
  avt <- character(0)
  ex <- mw_extrapolation_sigma2(aj)
  if (isTRUE(ex$degeneree)) {
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
      "les %d facteurs individuels F(i,%d) sont tous egaux a f_%d = %s ",
      "(ecart relatif maximal %.1e)"),
      k$n, k$j, k$j, format(k$f, digits = 8), k$ecart), ""))
    nuls <- et(vapply(cols, function(k) sprintf("sigma2_(%s) = %s", k$nom,
                                                 format(k$s2, digits = 3)), ""))
    # L'absence de residus de Mack des colonnes a sigma2_j = 0 n'est plus dite
    # ici mais dans l'avertissement general sur les colonnes exclues (ci-
    # dessous), qui couvre toute colonne, J-3 et J-2 comprises, sans doublon
    # (issue #33).
    q <- if (is.na(ex$quotient)) "non defini" else format(ex$quotient, digits = 3)
    msg <- sprintf(paste0(
      "%s %s : %s, donc %s. ",
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
  # avis d'actuary du 24/09/2026). mw_residus() ecarte toute colonne a
  # sigma2_j = 0 (residu 0/0, non defini) ; sous le modele D(2)(h), une
  # colonne a facteurs tous egaux n'est pas un motif de refus (developpement
  # acheve, par exemple). UN SEUL avertissement par triangle, qui nomme
  # chaque colonne exclue, compte les residus exclus et retenus et cite les
  # lignes de mw_tests() fondees sur ces residus.
  # Objet d'ajustement reduit (I et reserve seuls, fonction publique) : rien
  # a restituer, comme dans mw_extrapolation_sigma2().
  complet <- is.list(aj) && all(c("I", "J", "sigma2", "f", "tri") %in% names(aj))
  rs <- if (complet) mw_residus(aj) else NULL
  ex_col <- attr(rs, "colonnes_exclues")
  if (!is.null(ex_col) && nrow(ex_col)) {
    n_ex <- sum(ex_col$n_facteurs)
    avt <- c(avt, sprintf(paste0(
      "%s a sigma2_j = 0 (facteurs individuels tous egaux a f_j) : %s. ",
      "Le residu de Mack y vaut 0/0 et n'est pas defini : ces %d facteurs individuels ",
      "n'ont pas de residu de Mack et sont exclus ; %d residu(s) de Mack sont retenus ",
      "pour les lignes fondees sur ces residus, soit %s. ",
      "Une colonne a facteurs tous egaux n'est pas un motif de refus (developpement ",
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
# Colonnes exclues (issue #33, avis d'actuary du 24/09/2026) : une colonne
# j a au moins deux facteurs dont sigma2_j n'est pas strictement positif (une
# somme ponderee de carres : "<= 0" se lit "= 0", facteurs individuels tous
# egaux a f_j) n'a pas de residu defini (0/0) ; elle est ecartee, et
# l'exclusion n'est plus silencieuse : l'attribut "colonnes_exclues"
# (data.frame j, n_facteurs) la consigne, et mw_valider_ajustement() en fait
# un avertissement. .run_engine_mw() retire l'attribut avant de stocker les
# residus (aucun champ nouveau dans le resultat). La colonne J-1 (un seul
# facteur) n'a jamais de residu et n'est pas comptee comme exclue. Le seuil
# reste l'egalite exacte a 0 : l'alignement sur la detection a 1e-12 des
# colonnes degenerees releve de l'issue #60.
mw_residus <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  out <- data.frame()
  exclues <- data.frame(j = integer(0), n_facteurs = integer(0))
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 2) next
    if (!is.finite(aj$sigma2[j + 1]) || aj$sigma2[j + 1] <= 0) {
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

mw_test_annees_calendaires <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  etiq <- data.frame()
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 2) next
    F <- tri[idx + 1, j + 2] / tri[idx + 1, j + 1]
    md <- stats::median(F)
    lab <- ifelse(F > md, "L", ifelse(F < md, "S", "*"))
    etiq <- rbind(etiq, data.frame(i = idx, j = j, diag = idx + j, lab = lab,
                                   stringsAsFactors = FALSE))
  }
  etiq <- etiq[etiq$lab != "*", , drop = FALSE]
  if (!nrow(etiq)) return(list(stat = NA_real_, p = NA_real_, Z = NA_real_))
  agg <- lapply(split(etiq$lab, etiq$diag), function(v) {
    L <- sum(v == "L"); S <- sum(v == "S"); n <- L + S
    m <- .mack_moments_Z(n)
    c(Z = min(L, S), E = unname(m["E"]), V = unname(m["V"]), n = n)
  })
  A <- do.call(rbind, agg)
  A <- A[A[, "n"] >= 2, , drop = FALSE]
  if (!nrow(A)) return(list(stat = NA_real_, p = NA_real_, Z = NA_real_))
  Z <- sum(A[, "Z"]); EZ <- sum(A[, "E"]); VZ <- sum(A[, "V"])
  if (!is.finite(VZ) || VZ <= 0) return(list(stat = NA_real_, p = NA_real_, Z = Z))
  st <- (Z - EZ) / sqrt(VZ)
  list(stat = st, p = .p_borne(2 * (1 - stats::pnorm(abs(st)))),
       Z = Z, E = EZ, V = VZ, detail = A)
}

# --- Test de correlation entre annees de developpement adjacentes (Mack) -----
# Mack (1997) / Mack (1993), ASTIN Bulletin 23(2). L'hypothese D(2)(h)(ii)
# suppose les facteurs de developpement successifs non correles. On mesure la
# correlation de rang de Spearman entre colonnes adjacentes, agregee sur le
# triangle. La loi sous H0 dependant de la geometrie du triangle, la p-value
# est obtenue par permutation (voir mw_bootstrap).
mw_stat_correlation_dev <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  Ts <- w <- numeric(0)
  for (k in 1:(J - 1)) {
    idx <- 0:(I - k - 1)
    if (length(idx) < 3) next
    Fk  <- tri[idx + 1, k + 1] / tri[idx + 1, k]        # colonne k-1 -> k
    Fk1 <- tri[idx + 1, k + 2] / tri[idx + 1, k + 1]    # colonne k -> k+1
    if (stats::sd(Fk) == 0 || stats::sd(Fk1) == 0) next
    rho <- suppressWarnings(stats::cor(rank(Fk), rank(Fk1)))
    if (!is.finite(rho)) next
    Ts <- c(Ts, rho); w <- c(w, length(idx) - 1)
  }
  if (!length(Ts)) return(list(stat = NA_real_, T = NA_real_))
  list(stat = sum(w * Ts) / sum(w), T = Ts, poids = w)
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
.fisher_combine <- function(p) {
  p <- p[is.finite(p) & p > 0 & p <= 1]
  if (length(p) < 2) return(list(stat = NA_real_, p = NA_real_, K = length(p)))
  X <- -2 * sum(log(p))
  list(stat = X, p = .p_borne(1 - stats::pchisq(X, 2 * length(p))), K = length(p))
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
#      observee et simulee (K peut encore varier pour une autre cause :
#      .fisher_combine() ecarte les p-values nulles, par exemple Spearman
#      asymptotique a rho = +-1 pour n = 4 ; defaut anterieur, issue #90) ;
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
    "%s (facteurs individuels tous egaux a f_j a 1e-12 pres en relatif, ",
    "sigma2_j nul ou numeriquement nul) : %s ; %s, %s hors de la combinaison ",
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
    F <- tri[idx + 1, j + 2] / tri[idx + 1, j + 1]
    ct <- suppressWarnings(stats::cor.test(F, idx, method = "spearman", exact = FALSE))
    det <- rbind(det, data.frame(j = j, n = length(idx),
      rho = unname(ct$estimate), p = ct$p.value, stringsAsFactors = FALSE))
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
mw_test_exposant_variance <- function(aj) {
  res <- mw_residus(aj)
  if (!nrow(res)) return(list(stat = NA_real_, p = NA_real_, detail = data.frame()))
  det <- data.frame()
  for (j in unique(res$j)) {
    d <- res[res$j == j, ]
    if (nrow(d) < 4 || stats::sd(d$C) == 0) next
    ct <- suppressWarnings(stats::cor.test(abs(d$residu), d$C,
                                           method = "spearman", exact = FALSE))
    det <- rbind(det, data.frame(j = j, n = nrow(d),
      rho = unname(ct$estimate), p = ct$p.value, stringsAsFactors = FALSE))
  }
  if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det))
  fc <- .fisher_combine(det$p)
  list(stat = fc$stat, p = fc$p, K = fc$K, detail = det)
}

# (f) Homogeneite des residus entre annees de survenance (hypothese (i)).
# Si les annees d'accident sont stochastiquement independantes et suivent le
# meme modele, les residus de Mack ne doivent pas differer systematiquement
# d'une ligne a l'autre. Test de Kruskal-Wallis (1952), non parametrique.
mw_test_homogeneite_accident <- function(aj) {
  res <- mw_residus(aj)
  g <- factor(res$i)
  if (nlevels(g) < 3 || nrow(res) < 6)
    return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_))
  k <- try(stats::kruskal.test(res$residu, g), silent = TRUE)
  if (inherits(k, "try-error")) return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_))
  list(stat = unname(k$statistic), p = .p_borne(k$p.value),
       ddl = unname(k$parameter))
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

mw_bootstrap <- function(aj, B = 999, seed = 20260831) {
  # Tirages sous graine locale (ADR 0004, #42) : etat de l'appelant restaure.
  engine_sous_graine(seed, {
    res <- mw_residus(aj)
    pool <- res$residu
    pool <- pool - mean(pool)                     # recentrage usuel
    # Colonnes degenerees de M1 determinees UNE FOIS sur le triangle observe et
    # figees pour la statistique observee et chaque replication (issue #56).
    jd <- .mw_colonnes_degenerees(aj)
    obs <- .mw_stats(aj, jd)
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
  mc <- .mc_p_values(sim, obs, MW_CATALOGUE_MC)
  # granularite (B nominal) et granularite_stat (par statistique, sur B_eff) :
  # comme dans usp_bootstrap() (issue #40).
  list(stats_obs = as.list(obs), p_mc = mc$p_mc,
       err_mc = mc$err_mc,
       B_effectif = mc$B_effectif, granularite = 1 / (B + 1),
       sigma_boot = sig[is.finite(sig)], B = B,
       granularite_stat = mc$granularite)
}

# --- Catalogue Monte-Carlo de la methode Merz-Wuthrich (ADR 0003) -------------
# Meme structure que USP_CATALOGUE_MC (voir .mc_entree()) ; contexte construit
# par .mw_contexte_mc(). `degenere` : NULL pour toutes les entrees.
# Contexte : ajustement aj, residus de Mack (mw_residus(), calcules une fois),
# leur vecteur r et l'ensemble j_degeneres des colonnes degenerees exclues des
# verifications colonne par colonne de M1 (issue #56) : fige a l'observe par
# mw_bootstrap(), calcule sur aj s'il n'est pas fourni.
.mw_contexte_mc <- function(aj, j_degeneres = NULL) {
  res <- mw_residus(aj)
  list(aj = aj, res = res, r = res$residu,
       j_degeneres = .mw_j_exclues(aj, j_degeneres))
}

MW_CATALOGUE_MC <- list(
  Calendrier = .mc_entree(function(e) mw_test_annees_calendaires(e$aj)$stat, "deux"),
  CorrDev    = .mc_entree(function(e) mw_stat_correlation_dev(e$aj)$stat, "deux"),
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
  ExpVar     = .mc_entree(function(e) mw_test_exposant_variance(e$aj)$stat, "haut"),
  KruskalAcc = .mc_entree(function(e) mw_test_homogeneite_accident(e$aj)$stat, "haut")
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
                     "ordonnee a l'origine nulle en arithmetique exacte, statistique de Student ",
                     "non definie (0/0)"), "de proportionnalite")))
  hf <- mw_test_homogeneite_f(aj)
  add(fam, "Homogeneite de f_j entre annees de survenance",
      "Annexe XVII, D(2)(h)(iii) : 'pour toutes les annees d'accident'",
      H0 = "le facteur f_j est commun a toutes les annees de survenance",
      H1 = "les facteurs individuels derivent avec l'annee de survenance",
      stat_nom = "X de Fisher", stat = hf$stat,
      loi = "chi2(2K) approx. -> Monte-Carlo",
      estim_nom = "colonnes testees", estim = if (is.null(hf$K)) NA_real_ else hf$K,
      p_as = hf$p, mc_nom = "HomogF",
      detail = .mw_avec_exclusion(
        "Correlation de rang entre F(i,j) et i, colonne par colonne, combinee par Fisher",
        .mw_phrase_exclusion(hf,
          "facteurs individuels constants, correlation de rang non definie",
          "de l'homogeneite de f_j entre annees de survenance")))
  cb <- mw_test_courbure(aj)
  add(fam, "Absence de courbure de la regression",
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
          "terme quadratique nul en arithmetique exacte, statistique de Student non definie (0/0)",
          "de linearite")))
  al <- mw_famille_alpha(aj)
  add(fam, "Stabilite du facteur selon la ponderation (famille alpha)",
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
      "Breusch & Pagan (1979) / Koenker (1981), applique aux residus de Mack",
      H0 = "les residus de Mack ne dependent plus de C(i,j)",
      H1 = "la ponderation en C(i,j) ne capture pas la variance",
      stat_nom = "LM", stat = bp$stat, loi = "chi2(1) asymptotique",
      p_as = bp$p, mc_nom = "BP",
      detail = "Si Var(C(i,j+1)|C(i,j)) = sigma_j^2 C(i,j), les residus standardises sont d'echelle constante")
  ev <- mw_test_exposant_variance(aj)
  add(fam, "Adequation de l'exposant de variance, colonne par colonne",
      "Annexe XVII, D(2)(h)(iv) ; complement de Breusch-Pagan",
      H0 = "|r(i,j)| ne depend pas de C(i,j) dans chaque colonne",
      H1 = "l'exposant 1 impose par le reglement est inadapte",
      stat_nom = "X de Fisher", stat = ev$stat,
      loi = "chi2(2K) approx. -> Monte-Carlo",
      estim_nom = "colonnes testees", estim = if (is.null(ev$K)) NA_real_ else ev$K,
      p_as = ev$p, mc_nom = "ExpVar",
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
      type = "diagnostic", estim_nom = "var(residus)", estim = stats::var(r),
      detail = sprintf(paste("Valeur de reference %s, et NON 1 : sigma2_j etant",
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
                       format(var_attendue, digits = 6), n, k_col, n - k_col,
                       format(mean(r), digits = 3)))

  ## --- M3 : independance des annees d'accident et de developpement ----------
  fam <- "M3. independance (annexe XVII D(2)(h)(i) et (ii))"
  cal <- mw_test_annees_calendaires(aj)
  add(fam, "Effets d'annee calendaire (test de Mack)",
      "Mack (1994), Insurance: Mathematics and Economics 15, 133-138",
      H0 = "absence d'effet d'annee calendaire (diagonales homogenes)",
      H1 = "une ou plusieurs diagonales atypiques (inflation, changement de cadence)",
      stat_nom = "Z centre reduit", stat = cal$stat,
      loi = "N(0,1) approx. ; moments EXACTS de Z = min(L, n-L)",
      estim_nom = "Z observe", estim = cal$Z,
      p_as = cal$p, mc_nom = "Calendrier",
      detail = "Les diagonales representent les exercices comptables : un effet calendaire viole l'independance des annees d'accident")
  ka <- mw_test_homogeneite_accident(aj)
  add(fam, "Homogeneite des residus entre annees de survenance",
      "Kruskal & Wallis (1952), JASA 47, 583-621",
      H0 = "les residus de Mack ont la meme distribution dans toutes les lignes",
      H1 = "au moins une annee de survenance se comporte differemment",
      stat_nom = "H", stat = ka$stat,
      loi = sprintf("chi2(%s) approx. -> Monte-Carlo",
                    ifelse(is.na(ka$ddl), "k-1", as.character(ka$ddl))),
      p_as = ka$p, mc_nom = "KruskalAcc",
      detail = "Traduction testable de l'independance des annees de survenance, D(2)(h)(i)")
  cor <- mw_stat_correlation_dev(aj)
  add(fam, "Correlation entre annees de developpement adjacentes",
      "Mack (1993, 1997), ASTIN Bulletin ; correlation de rang de Spearman",
      H0 = "facteurs de developpement successifs non correles",
      H1 = "correlation entre colonnes adjacentes",
      stat_nom = "rho agrege", stat = cor$stat,
      loi = "depend de la geometrie du triangle -> Monte-Carlo", mc_nom = "CorrDev",
      detail = "Une correlation positive signale une dependance entre cadences successives")
  add(fam, "Autocorrelation des residus (Durbin-Watson)",
      "Durbin & Watson (1950, 1951)",
      H0 = "residus de Mack non autocorreles", H1 = "autocorrelation residuelle",
      stat_nom = "DW", stat = stat_dw(r),
      loi = "residus de triangle -> Monte-Carlo", mc_nom = "DW")
  ru <- test_runs(r)
  add(fam, "Test des suites sur les residus de Mack",
      "Wald & Wolfowitz (1940)",
      H0 = "arrangement aleatoire des signes des residus", H1 = "arrangement non aleatoire",
      stat_nom = "Z", stat = ru$stat, loi = "N(0,1) approx. -> Monte-Carlo",
      estim_nom = "nb de suites", estim = ru$runs,
      p_as = ru$p, mc_nom = "Runs")

  ## --- M4 : points aberrants ------------------------------------------------
  fam <- "M4. points aberrants et stabilite"
  gr <- test_grubbs(r)
  add(fam, "Cellule aberrante du triangle (Grubbs)",
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
      "Rosner (1983), Technometrics 25", type = "procedure de decision",
      H0 = "aucun residu aberrant", H1 = "il existe i <= k residus aberrants",
      estim_nom = "nb de cellules aberrantes", estim = ro$nb_outliers,
      detail = sprintf("procedure a niveau alpha = %.2f (aucune p-value)", alpha),
      verdict = if (ro$nb_outliers >= 2) "ECHEC" else if (ro$nb_outliers == 1) "ALERTE" else "OK")

  ## --- M5 : normalite, DIAGNOSTIC seulement ---------------------------------
  fam <- "M5. normalite des residus (diagnostic, NON exige par le modele)"
  sw <- .shapiro_sur(r)
  add(fam, "Shapiro-Wilk sur les residus de Mack",
      "Shapiro & Wilk (1965) ; loi nulle evaluee par simulation directe",
      H0 = "les residus de Mack sont normaux", H1 = "loi non normale",
      stat_nom = "W", stat = sw$stat,
      loi = "loi exacte de W sous normalite, evaluee numeriquement",
      p_ex = sw_p_loi_nulle(sw$stat, n),
      detail = paste("L'annexe XVII, D(2)(h), ne specifie que les DEUX PREMIERS MOMENTS :",
                     "la normalite n'est pas requise par la methode. Ce test n'est pertinent",
                     "que si l'on souhaite exploiter la MSEP pour un quantile."))
  add(fam, "Lilliefors sur les residus de Mack",
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
#                  signalee par metadata$sigma_standard_saisi, issue #55)
#   nature_donnees "brutes" ou "nettes" (de reassurance) ; OBLIGATOIRE pour
#                  "premium", sans defaut (issue #55, M13) : sans elle, ok =
#                  FALSE ; methodes de reserve : NULL ou "nettes" acceptes,
#                  "brutes" refuse (ok = FALSE, C(2)(c), D(2)(f))
#   T              profondeur retenue (les T dernieres annees) ; NULL = tout
#   B              nombre de replications bootstrap / Monte-Carlo
#   alpha          seuil des verdicts
#   seed           graine des simulations (reproductibilite)
#   bareme         "court" ou "long" ; NULL = deduit du segment
#
# Valeur : liste de classe "usp_engine" (voir la structure en fin de fonction).
# Orchestrateur de la methode du risque de reserve no 2. Retourne un objet de
# meme classe et de meme forme generale que la branche lognormale, afin que la
# couche d'affichage puisse le consommer sans traitement particulier.
.run_engine_mw <- function(triangle, segment, annexe, sigma_standard,
                           B, alpha, seed, bareme, t0, nature_donnees = NULL) {
  if (is.null(triangle))
    stop("La methode du risque de reserve no 2 exige un triangle de paiements cumules.")
  triangle <- as.matrix(triangle)
  validation <- mw_valider_triangle(triangle)
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

  infos <- if (!is.null(segment)) usp_segment_infos(segment, annexe) else NULL
  # Saisie libre du sigma standard : derogation au parametre reglementaire,
  # restituee par metadata$sigma_standard_saisi (issue #55).
  saisi <- !is.null(sigma_standard)
  if (is.null(sigma_standard)) {
    if (is.null(infos)) stop("Fournir soit sigma_standard, soit segment (avec son annexe).")
    sigma_standard <- infos$sigma_reserve      # methode de reserve : sigma(res,s)
  }
  if (is.null(bareme)) bareme <- usp_bareme_segment(segment, annexe)

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
                    # seuls champs de l'issue #37 puis des champs d'execution.
                    sigma_standard_saisi = saisi,
                    # Generateur pose par engine_sous_graine() et graine fixe
                    # de la loi nulle de Shapiro-Wilk (issue #37, ADR 0004
                    # point 2). Places apres les champs existants, avant les
                    # champs d'execution.
                    generateur = as.list(ENGINE_RNG_KIND),
                    seed_loi_nulle_sw = SEED_LOI_NULLE_SW,
                    horodatage = t0,
                    duree_sec = as.numeric(difftime(Sys.time(), t0, units = "secs")),
                    version_R = R.version.string)
  ), class = "usp_engine")
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
  n <- length(xt)
  if (!is.null(T) && is.finite(T)) {
    if (T > n) stop(sprintf("T = %d > profondeur disponible (%d).", T, n))
    idx <- (n - T + 1):n; xt <- xt[idx]; yt <- yt[idx]
  }
  validation <- engine_valider_donnees(xt, yt, theta_equiv = theta_equiv,
                                       delta_equiv = delta_equiv, methode = methode,
                                       nature_donnees = nature_donnees)
  if (!validation$ok)
    return(structure(list(ok = FALSE, validation = validation,
                          metadata = list(horodatage = t0)), class = "usp_engine"))
  T <- length(xt)

  # --- 2. Parametre standard et bareme de credibilite -----------------------
  # Lecture conditionnelle de M13 (issue #55) : sigma brut sur donnees brutes,
  # NP standard x sigma brut sur donnees nettes (primes) ; sigma(res,s) pour
  # la methode de reserve no 1. Un sigma_standard saisi prime (derogation,
  # restituee par metadata$sigma_standard_saisi, pour les trois methodes).
  infos <- if (!is.null(segment)) usp_segment_infos(segment, annexe) else NULL
  saisi <- !is.null(sigma_standard)
  sigma_standard <- usp_parametre_standard(methode, segment, annexe, nature_donnees,
                                           sigma_standard)$sigma_standard
  # Annexe XVII, section G(2) : les segments de l'annexe XIV relevent tous du
  # bareme court, quel que soit leur numero.
  if (is.null(bareme)) bareme <- usp_bareme_segment(segment, annexe)

  # --- 3. Estimation, bootstrap, robustesse ---------------------------------
  controles <- usp_controle_donnees(xt, yt, alpha)
  fit   <- usp_ajuster(xt, yt)
  # Controles numeriques de l'estimation (famille H, non bloquants, #22)
  controles <- c(controles, usp_controles_numeriques(fit))
  boot  <- usp_bootstrap(fit, B = B, seed = seed, progres = FALSE)
  param <- usp_parametre(fit, sigma_standard, bareme)
  jack  <- usp_jackknife(fit, sigma_standard, bareme)
  prof  <- usp_profil(fit)

  cred <- param$credibilite; corr <- param$correction_taille
  usp_b <- cred * boot$sigma_boot * corr + (1 - cred) * sigma_standard
  ic <- if (length(usp_b) > 20)
    stats::quantile(usp_b, c(.025, .05, .5, .95, .975)) else NULL

  # Jackknife entierement non calcule (tous les reajustements en echec) : pas
  # de ligne jackknife (fit$ecart_jackknife NULL) plutot qu'un max a -Inf.
  d_jack <- jack$sigma_usp - param$sigma_usp
  jack_calcule <- any(is.finite(d_jack))
  fit$ecart_jackknife <- if (jack_calcule)
    max(abs(jack$sigma_usp - param$sigma_usp), na.rm = TRUE) / param$sigma_usp else NULL
  fit$largeur_ic <- if (!is.null(ic)) unname((ic[4] - ic[2]) / param$sigma_usp) else NULL
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
                     delta_equiv = delta_equiv, robustesse = robustesse)

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
    jackknife = jack,
    profil = prof,
    calibration = calibration,
    candidats = candidats,
    parametre_final = param,
    plots_data = engine_plots_data(fit, boot, prof, jack, param$sigma_usp),
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
      # anterieurs, suivis des seuls champs de l'issue #37 puis des champs
      # d'execution (retires par nettoyer() des tests).
      if (methode == "premium") list(nature_donnees = nature_donnees),
      list(sigma_standard_saisi = saisi),
      # Generateur pose par engine_sous_graine() et graines fixes des
      # simulations autres que le bootstrap (issue #37, ADR 0004 point 2) :
      # loi nulle de Shapiro-Wilk, enveloppe du QQ-plot. Places apres les
      # champs existants, avant les champs d'execution.
      list(generateur = as.list(ENGINE_RNG_KIND),
           seed_loi_nulle_sw = SEED_LOI_NULLE_SW,
           seed_enveloppe_qq = SEED_ENVELOPPE_QQ),
      list(horodatage = t0,
           duree_sec = as.numeric(difftime(Sys.time(), t0, units = "secs")),
           version_R = R.version.string))
  ), class = "usp_engine")
}


# Parametre standard remplace et sa tracabilite (issue #55, decision M13),
# sous forme de data.frame pour la restitution (onglet Calibration, rapport
# fige) : nature declaree des donnees, point de l'art. 218, paragraphe 1,
# remplace, exigence relative aux donnees, sigma de l'annexe, NP standard,
# sigma standard reglementaire, sigma standard retenu dans le melange et son
# origine (parametre reglementaire ou saisie libre, derogation).
# Colonnes : grandeur ; valeur (numerique, NA pour une ligne de texte) ;
# texte (NA pour une ligne purement numerique).
# Tout est recalcule ici a partir de res$metadata par usp_parametre_standard()
# (aucun calcul dans l'affichage) ; le sigma standard retenu recalcule doit
# etre identique a celui du resultat, sinon erreur.
# Saisie libre : drapeau explicite metadata$sigma_standard_saisi, pour les
# trois methodes (toute saisie est une derogation, meme egale a la table ;
# decision du mainteneur du 25/09/2026). Un resultat qui ne le porte pas
# (produit avant l'issue #55) est refuse plutot que devine.
engine_parametre_standard <- function(res) {
  if (!isTRUE(res$ok)) return(NULL)
  m <- res$metadata
  if (!is.logical(m$sigma_standard_saisi) || length(m$sigma_standard_saisi) != 1L ||
      is.na(m$sigma_standard_saisi))
    stop("engine_parametre_standard() : drapeau metadata$sigma_standard_saisi absent ou invalide.")
  saisi <- m$sigma_standard_saisi
  ps <- usp_parametre_standard(m$methode, m$segment, m$annexe, m$nature_donnees,
                               if (saisi) m$sigma_standard else NULL)
  if (!identical(ps$sigma_standard, m$sigma_standard))
    stop("engine_parametre_standard() : sigma standard recalcule different de celui du resultat.")
  prime <- identical(m$methode, "premium")
  lib_nature <- c(brutes = "brutes : non ajustees de la reassurance",
                  nettes = "nettes : ajustees de la reassurance")[[ps$nature_donnees]]
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
      "Origine du sigma standard retenu"),
    valeur = c(NA, NA, NA, ps$sigma_annexe, if (prime) ps$np_standard,
               ps$sigma_reglementaire, ps$sigma_standard, NA),
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
              else "parametre reglementaire"),
    stringsAsFactors = FALSE)
  d
}

# Table des tests sous forme de data.frame auditable (donnees, pas affichage).
engine_table_tests <- function(res) {
  do.call(rbind, lapply(res$tests, function(t) data.frame(
    famille = t$famille, test = t$test, type = t$type,
    base = t$base, variante = t$variante,
    H0 = t$H0, H1 = t$H1,
    nom_statistique = t$stat_nom, statistique = t$stat, loi_sous_H0 = t$loi,
    nom_estimation = t$estim_nom, estimation = t$estim,
    p_exacte = t$p_exacte, p_asymptotique = t$p_asymptotique,
    p_monte_carlo = t$p_mc, erreur_MC = t$err_mc,
    p_retenue = t$p_retenue, nature_p = t$nature_p,
    sens_du_test = t$sens, verdict = t$verdict,
    commentaire = t$detail, reference = t$reference,
    stringsAsFactors = FALSE)))
}
