###############################################################################
#  tests/mesure_dw_rho_negatif_t8.R  --  PUISSANCE DU TEST DE DURBIN-WATSON
#  CONTRE UN AR(1) AU VOISINAGE DE rho = -1 JUSQU'A LA GARDE rho = -1 + 1e-6,
#  ET LIMITES QUAND rho -> -1 ET rho -> 1, A T = 8 (#164) ET POUR LES T DE
#  L'INDEX, 4 A 100 (#421)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (tools::md5sum() pour les empreintes). Il ne modifie ni
#  R/engine.R ni tests/reference/ : il appelle dw_puissance_ar1() du moteur,
#  inchangee, pour la puissance, et .dw_matrices(), .dw_valeurs_propres(),
#  .imhof_p_sup0(), stat_dw(), dw_p_exacte() et engine_sous_graine() pour les
#  limites et le recoupement par simulation. La seule logique reprise est
#  declaree (points critiques, statistique matricielle, limite rho -> 1). Il
#  charge tests/outils_tests.R puis tests/outils_mesure_dw.R (#421, Q-78-4
#  (a)), definition unique, partagee avec tests/mesure_lb1_dw_t8.R, de
#  empreintes_code(), plateforme_calcul(), dw_mat(), ar1_mat() et
#  points_critiques_dw(). Le nom du script (_t8) est celui de #164 : depuis
#  #421 il porte aussi les autres T (fiche "Branche S9", etape 2 : extension
#  de ce script, non un script nouveau).
#  Sortie en markdown sur la console (UTF-8) ; un fichier n'est ecrit que sur
#  --ecrire. Tous les libelles non ASCII sont ecrits en echappements \u
#  (fichier source ASCII).
#
#  Objet.
#    #164 : avis d'actuary retenu par le mainteneur le 31/10/2026
#    (commentaire 6541872644 de #164) : puissance du test bilateral exact de
#    Durbin-Watson (dw_p_exacte(), p = 2 min(P0(DW <= d), P0(DW >= d)),
#    rejet si p < alpha) a T = 8 pour rho de -0,999 a 0, grille etendue
#    jusqu'a la garde du moteur (-1 + 1e-6) ; tableau
#    docs/tableaux/20261031-issue164-dw-rho-negatif.md.
#    #421 : protocole de l'avis d'actuary de l'etape 1 de S9
#    (docs/revues/20261127-s9-mesures/actuary-protocoles-etape-1.md, par. 1,
#    plan par. 1.4, criteres K421-1 a K421-5 du par. 1.5, ecrits avant toute
#    execution de ce script ; reserve de methode M42 acceptee avec trace par
#    le mainteneur, synthese.md) : memes grilles pour T dans {4 a 10, 12, 15,
#    20, 30, 50, 100} et les deux seuils (les couples de l'index du .tex,
#    alpha = 0,10 pour tous ces T et alpha = 0,05 pour T = 5, 8, 12, 20, 30,
#    en sont un sous-ensemble, marque en sortie) ; limites L- (rho -> -1) et
#    L+ (rho -> 1) ; recoupement par simulation jusqu'a la garde ; lecture
#    automatique des criteres.
#
#  Cadre (celui de dw_puissance_ar1()) : z gaussien centre, i.i.d. N(0,1)
#  sous H0, AR(1) STATIONNAIRE, Sigma = (rho^|i-j|), sous l'alternative ;
#  SANS reajustement ; statistique calculee sur la serie centree (stat_dw()).
#  Natures (avis, par. 1.1) :
#    (a) puissance : quantite EXACTE dans ce cadre, evaluee par quadrature
#        numerique (integrale d'Imhof, .imhof_p_sup0()) et uniroot() (points
#        critiques), sans tirage ; erreur numerique non bornee a priori,
#        verifiee sans etre bornee (controle N, controle S1, recoupement) ;
#    (b) L-(T, alpha) : RESULTAT EXACT (demonstration de l'avis, par. 1.2) :
#        L- = 1{dw_p_exacte(v_T) < alpha}, v_T = ((-1)^t), des que
#        dw_p_exacte(v_T) != alpha ; la valeur pour un T donne depend du signe
#        de la marge m = dw_p_exacte(v_T) - alpha, evaluee par quadrature ;
#    (c) L+(T, alpha) : loi limite exacte (avis, par. 1.3) : DW(z_rho) converge
#        en loi vers DW(u), u ~ N(0, M K M), K = (-|i-j|), M projecteur de
#        centrage ; L+ = P(DW(u) hors de [d_bas, d_haut]), valeur evaluee par
#        Imhof (approximation numerique d'une quantite exacte), sans franchir
#        la garde rho <= 1 - 1e-10 ;
#    (d) loi en (1 - |rho|)^(1/2) de |puissance - L-| : CONSTAT numerique,
#        non demontre (heuristique de l'avis, par. 1.2) ;
#    (e) recoupement : constat de simulation, erreur binomiale fonction de N.
#  L'AR(1) est une alternative choisie, hors modele reglementaire (l'annexe
#  XVII suppose des annees independantes) ; z n'est pas le vecteur de
#  residus reajustes du moteur ; rho -> +-1 borne le domaine numerique de
#  l'outil dw_puissance_ar1(), non la puissance utile du test.
#  Variante a depart nul (z_1 = e_1 a la place de la loi stationnaire) : NON
#  calculee (abandonnee sans issue, avis d'actuary du 31/10/2026).
#  Valeurs hors garde de #170 (0,5899253 a rho = 1 - 1e-12, 0,5906 a
#  1 - 1e-13, 0,4755 a 1 - 1e-15, T = 8, alpha = 0,10) : NON reproduites
#  (avis, par. 1.3 ; aucune copie du calcul sans garde) ; citees en sortie
#  comme valeurs historiques ; la limite 0,5899175 est versionnee par L+.
#
#  Protocole.
#    1. GRILLE IMHOF. rho dans {-1 + 1e-6 ; -0,99999 ; -0,9999 ; -0,999 ;
#       -0,99 ; -0,98 ; -0,95 ; -0,9 ; -0,8 ; -0,7 ; -0,5 ; -0,3 ; 0}, alpha
#       dans {0,10 ; 0,05}, T dans TS : puissance = dw_puissance_ar1(T, rho,
#       alpha). Le point -1 + 1e-6 EST la garde (1 - |rho| = 1e-6, admis : le
#       test de la garde, rho < -1 + 1e-6, est faux sur cette valeur calculee
#       de la meme facon). Section 1 : une table par T (colonnes du tableau
#       du 31/10). Section 1 bis : |puissance - L-| / (1 - |rho|)^(1/2)
#       (1 - |rho| lu comme 1 + rho), qui est le deficit rapporte du tableau
#       du 31/10 quand L- = 1 (T = 8) ; "--" si L- est indecidable.
#    2. LIMITES (section 3). Pour chaque (T, alpha) :
#       L- : DW(v_T) contre sa valeur rationnelle, 4(T - 1)/T (T pair) ou
#       4T/(T + 1) (T impair) (controle R, 1e-12) ; p_v = dw_p_exacte(v_T) ;
#       marge m = p_v - alpha ; L- = 1{p_v < alpha} si |m| >= 1e-6 (K421-1).
#       L+ : M K M, rang controle (T - 1, valeurs propres > 1e-10 x la plus
#       grande ; controle K, BLOQUANT selon K421-4), racine symetrique S ;
#       P(DW(u) > d) = P(e' S M (A - dI) M S e > 0), coefficients normalises
#       par max|h| et filtres a 1e-10 (comme dw_puissance_ar1()), par
#       .imhof_p_sup0() ; L+ = (1 - P(DW(u) > d_bas)) + P(DW(u) > d_haut),
#       d_bas et d_haut de points_critiques_dw() ; compare a
#       dw_puissance_ar1(T, 1 - 1e-10, alpha) et a dw_puissance_ar1(T,
#       1 - 1e-6, alpha).
#    3. RECOUPEMENT PAR SIMULATION (section 2), independant d'Imhof pour
#       l'alternative : rho dans {0 ; -0,9 ; -0,99 ; -0,9999 ; -1 + 1e-6}
#       pour chaque T, alpha = 0,10 et 0,05 ; N_SIM = 4e5 series AR(1)
#       stationnaires par rho (z_1 = e_1, z_t = rho z_{t-1} + sqrt(1 - rho^2)
#       e_t, ar1_mat()), memes innovations e pour tous les rho d'un meme T.
#       Graines (engine_sous_graine(), generateur ENGINE_RNG_KIND), une par
#       T, deterministes : graine_T(8) = SEED_SIM = 20261031, graine du 31/10
#       (flux de T = 8 inchange) ; graine_T(T) = SEED_BASE_T + T pour T != 8,
#       SEED_BASE_T = 421 000 000 (plage 421 000 004 - 421 000 100,
#       nouvelle, absente des litteraux de tests/ et de R/ le 27/11/2026,
#       hors des plages declarees des autres scripts, relevees le 27/11/2026
#       sur les constantes GRAINE_* et SEED* de tests/ (bornes ecrites en
#       millions : un litteral a huit chiffres commencant par 2 serait lu
#       comme une graine par controle_graines() de calibration_mc_mw_t8.R) :
#       graines datees 2026xxxx ; 20,8e6 - 21,2e6 (flux V3b et plages de
#       #206, #229, #276 : 20,8e6, 20,81e6, 20,82e6, 20,84e6, 20,87e6,
#       20,9e6, 21e6, 21,1e6, 21,2e6) ; 424242 (mesure_enveloppe_qq_t8.R) ; 305e6 (#305) ; 387e6 - 393e6 (#387 :
#       387e6, 387,5e6, 392e6, 393e6) ; 448e6 + 1e6 k + b (#448) ; 567e6 -
#       571,05e6 (#567 : 567e6, 568e6, 570,5e6, 571e6, 571,05e6) ; 610e6 -
#       641e6 (#610 : 610e6, 610,5e6, 620e6 + 4e6 par profil, 640e6,
#       640,05e6, 641e6) ; 660e6 - 664,5e6 (simulation_jm1_trapeze_t8.R :
#       660e6, 661e6, 661,5e6, 662e6, 663e6, 664e6, 664,5e6)). Tirage par blocs dans le flux
#       de chaque T : blocs de min(N_SIM, floor(TAILLE_BLOC / T)) lignes,
#       TAILLE_BLOC = 4e6 normales (32 Mo par matrice), chaque bloc tire par
#       matrix(rnorm(n T), n, T) a la suite du precedent ; pour T <= 10 un
#       seul bloc, donc a T = 8 la matrice du 31/10, a l'identique.
#       Statistique : dw_mat() (DW sur la serie centree). Points critiques
#       bilateraux de la loi nulle exacte par points_critiques_dw() (copie
#       declaree du calcul de dw_puissance_ar1() : cette loi nulle est celle
#       de dw_p_exacte(), seule l'alternative est recoupee). Erreur-type
#       binomiale ET = sqrt(p (1 - p) / N_SIM), p = min(valeur d'Imhof de
#       la grille, 1) (a rho = 0, la grille, egale a alpha au controle N
#       pres), rapportee pour la lecture ; la lecture K421-2 se fait sur la
#       p bilaterale binomiale exacte (ci-dessous).
#    Controles (code de sortie 1 si l'un echoue ; ecarts toujours rapportes) :
#       D1  determinisme : second appel de dw_puissance_ar1(8, -0,99, 0,10),
#           valeur de la grille a l'identique (tolerance 0) ;
#       N   niveau, chaque (T, alpha) : puissance a rho = 0 egale a alpha, a
#           1e-8 (tolerance de tests/unitaires/test_lois_exactes.R) ;
#       M, B (T = 8 seul, comme le 31/10) : paires voisines de la grille
#           (|rho| croissant) ou la puissance ne croit pas ; points rho < 0
#           ou elle ne depasse pas alpha. Constats a T = 8, non garantis en
#           general : pour les autres T, rapportes en section 1 ter sans etre
#           des controles ;
#       C   (T = 8, comme le 31/10) : ecart relatif du coefficient deficit /
#           (1 - |rho|)^(1/2) entre 1 - |rho| = 1e-4 et 1e-6, a 1e-3 ;
#       L   liens aux valeurs deja versionnees (T = 8, alpha = 0,10) :
#           rho = -0,5, 0,277840 a 1e-6 (test_lois_exactes.R, fiche DW,
#           #116) ; rho = -0,3 et -0,6, 0,163 et 0,355 a 5e-4
#           (docs/tableaux/20261020-mesure-lb1-dw-t8.md) ; un appel propre
#           de dw_puissance_ar1() par point ;
#       R   chaque T : DW(v_T) contre sa valeur rationnelle, 1e-12 ;
#       K   chaque T : rang de M K M egal a T - 1 (K421-4, bloquant) ;
#       L+  nombre de valeurs L+ non finies (integration d'Imhof en echec) : 0 ;
#       S0  chaque T (#421, point 4 : la serie de comparaison n'est plus la
#           sortie de ar1_mat() des deux cotes, ni prise a rho = 0) : sur
#           les 100 premieres lignes e des innovations, serie de reference
#           z = R'e, R = chol(Sigma), construite sans ar1_mat(), a chaque rho
#           simule non nul ; S0-ar1 : ecart max entre ar1_mat() et z, 1e-10
#           (arrondis de deux calculs differents) ; S0-dw : ecart max entre
#           dw_mat() et stat_dw() du moteur sur z, 1e-12 ;
#       S1  chaque (T, alpha) : la region [d_bas, d_haut] equivaut a
#           dw_p_exacte() < alpha sur N_S1 = 300 series simulees (reparties
#           entre les rho simules ; desaccords, tolerance 0) ; dw_p_exacte()
#           calculee une fois par serie, comparee a chaque alpha (#421,
#           point 4).
#    Lecture des criteres (section 4 ; avis, par. 1.5, et reponses d'actuary
#    du 27/11/2026, docs/revues/20261127-s9-mesures/actuary-questions-421.md,
#    points 1 et 2). K421-1 a K421-4 ne changent pas le code de sortie : un
#    critere non tenu est un resultat de mesure a lire par actuary, PM-3, non
#    une defaillance du script. K421-5 (critere d'acceptation de la fiche
#    "Branche S9", etape 2) est BLOQUANT : lignes de T = 8 differentes du
#    tableau du 31/10, absentes, ou tableau du 31/10 introuvable : --ecrire
#    refuse, code de sortie 1 (aussi en --essai) :
#       K421-1 limite : "decidee" si |m| >= 1e-6, sinon "indecidable a la
#              precision de la quadrature" ; le .tex peut remplacer
#              "hypothese non verifiee" si L-(4 ; 0,10) = 0 et L-(5 ; 0,05)
#              = 0, toute autre issue declenche PM-3 ;
#       K421-2 precision (decision A2 d'actuary, traduction exacte du
#              critere ecrit de 3 et 4 ET) : x = nombre de rejets sur N_SIM,
#              p0 = valeur d'Imhof bornee a [1e-9, 1 - 1e-9] ; p bilaterale
#              binomiale exacte 2 min(P(X <= x), P(X >= x)), X ~ B(N_SIM, p0),
#              bornee a 1 (pbinom()) ; "signale" si p < 2,700e-3
#              (2 pnorm(-3)), "desaccord" si p < 6,334e-5 (2 pnorm(-4)) ;
#              "desaccord" aussi si plus de 2 comparaisons sont signalees ;
#              130 comparaisons en execution complete (13 T x 5 rho x 2
#              alpha) ; la colonne en ET reste rapportee pour la lecture.
#              PM-3 si le desaccord porte sur un T ou un rho cite par le .tex
#              (TS_CITES_TEX, RHOS_CITES_TEX ci-dessous ; avec la grille de
#              ce script, tout desaccord en releve, ce que la lecture dit en
#              clair) ; un desaccord dans une cellule ou Imhof vaut 1 tronque
#              (p0 = 1 - 1e-9) se lit "simulation ou quadrature", l'erreur de
#              integrate() etant estimee et non bornee (Q10 d'actuary,
#              actuary-questions-420-367.md) ;
#       K421-3 vitesse (constat) : |puissance - L-| / (1 - |rho|)^(1/2) a
#              1 - |rho| = 1e-4 et 1e-6 : "stable" si l'ecart relatif est
#              <= 1e-3, sinon "regime asymptotique non atteint dans le
#              domaine garde", qui n'est PAS un echec ; "sans objet" si le
#              MINIMUM des deux deficits |puissance - L-| est inferieur a
#              1e-6 (decision A1 d'actuary, ecart a l'avis trace : erreur
#              absolue nominale de integrate() de l'ordre de 1e-10, soit,
#              sous 1e-6, une erreur relative superieure au dixieme du seuil
#              de 1e-3) ;
#       K421-4 rho -> 1 : |dw_puissance_ar1(T, 1 - 1e-10, alpha) - L+|
#              "signale" au-dela de 1e-5, "desaccord" au-dela de 1e-4 ;
#       K421-5 non-regression : lignes de T = 8 des sections 1, 1 bis et 2
#              identiques, cellule par cellule au chiffre imprime, a celles
#              de docs/tableaux/20261031-issue164-dw-rho-negatif.md (les
#              colonnes ajoutees en fin de ligne et les lignes ajoutees,
#              marquees, ne sont pas comparees).
#
#  Usage (depuis la racine du depot ; LC_ALL=C.UTF-8 sous Linux, #113) :
#      Rscript tests/mesure_dw_rho_negatif_t8.R
#      Rscript tests/mesure_dw_rho_negatif_t8.R --essai
#      Rscript tests/mesure_dw_rho_negatif_t8.R --ecrire --issue 421
#  --essai (M39, mode d'essai des scripts de mesure hors CI) : T dans {4 ;
#  5 ; 8 ; 100}, grille reduite (rho dans {-1 + 1e-6 ; -0,9999 ; -0,99 ;
#  0}), deux seuils, recoupement REDUIT (rho dans {0 ; -0,99 ; -1 + 1e-6},
#  N_SIM = 2e4, memes graines ; erreur-type plus grande ; S1 sur 300 series
#  par T), marques en sortie, NON versionnables (--ecrire refuse avec
#  --essai) ; annonce la duree estimee d'une execution COMPLETE : part fixe
#  mesuree + par T, duree par appel de dw_puissance_ar1() et par appel de
#  dw_p_exacte() (S1), et duree des limites, interpolees lineairement en T
#  entre les T de l'essai (approx(), constantes au-dela) et multipliees par
#  les nombres d'appels de l'execution complete + recoupement proportionnel
#  a N_SIM x T x (1 + nombre de rho) (extrapolation). Les controles
#  s'appliquent et le code de sortie suit les controles, comme pour une
#  execution complete (un script perime echoue donc a l'essai) ; K421-5 n'y
#  compare que les lignes presentes des sections 1 et 1 bis (section 2 : N
#  different, non comparee), et le code de sortie le suit.
#  --ecrire --issue N : ecrit, si tous les controles tiennent,
#  docs/tableaux/<AAAAMMJJ>-issue<N>-dw-rho-negatif.md (date du jour ;
#  plateforme, SHA de HEAD, md5 du moteur, empreintes du script, de
#  tests/outils_tests.R et de tests/outils_mesure_dw.R) ; --issue est
#  obligatoire avec --ecrire, refuse sans.
#  Sans --ecrire, rien n'est ecrit. Gardes anticipees (avant tout calcul)
#  puis finales (avant d'ecrire), comme les autres scripts (#205, #173) :
#  docs/tableaux/ doit exister ; refus (code 1, rien d'ecrit) si le commit lu
#  par commit_depot() n'est pas un SHA nu (arbre de travail modifie, script
#  non suivi ou git indisponible) ; refus si le fichier cible est suivi par
#  git (ce script n'a pas d'option --remplacer, comme mesure_lb1_dw_t8.R).
#  Le tableau se produit donc apres le commit du script.
#  Duree : voir la ligne "Duree" de la console (et, en --essai, la duree
#  estimee d'une execution complete).
#  Code de sortie : 0 si les controles tiennent et si K421-5 est tenu, 1
#  sinon.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/mesure_dw_rho_negatif_t8.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113) ------------------------------
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break

# --- Options (avant tout chargement du moteur) -------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
local({
  i <- 1L
  while (i <= length(ARGS)) {
    a <- ARGS[i]
    if (a == "--issue") {
      if (sum(ARGS == "--issue") > 1L) stop("option --issue donnee plusieurs fois")
      if (i == length(ARGS)) stop("option --issue sans valeur")
      i <- i + 2L
    } else if (a %in% c("--ecrire", "--essai")) i <- i + 1L
    else stop("option inconnue : ", a)
  }
})
OPT_ECRIRE <- "--ecrire" %in% ARGS
OPT_ESSAI  <- "--essai" %in% ARGS
OPT_ISSUE  <- if ("--issue" %in% ARGS) ARGS[match("--issue", ARGS) + 1L] else NA_character_
if (OPT_ECRIRE && OPT_ESSAI) stop("--ecrire : refuse avec --essai (execution d'essai, non versionnable)")
if (OPT_ECRIRE && (is.na(OPT_ISSUE) || !grepl("^[1-9][0-9]*$", OPT_ISSUE)))
  stop("--ecrire exige --issue N (N entier positif, issue de rattachement du tableau)")
if (!OPT_ECRIRE && !is.na(OPT_ISSUE)) stop("--issue : reserve a --ecrire")

# --- Chargement du moteur et des outils --------------------------------------
DOSSIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) dirname(f) else if (file.exists("tests/outils_tests.R")) "tests" else "."
})
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))
# empreintes_code(), plateforme_calcul(), dw_mat(), ar1_mat(),
# points_critiques_dw() : definition unique (#421, Q-78-4 (a)).
source(file.path(DOSSIER_SCRIPT, "outils_mesure_dw.R"))

DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
NOM_FICHIER <- if (OPT_ECRIRE) sprintf("%s-issue%s-dw-rho-negatif.md", DATE_SORTIE, OPT_ISSUE) else NA_character_
CHEMIN_ECRIT <- if (OPT_ECRIRE) file.path(RACINE, "docs", "tableaux", NOM_FICHIER) else NA_character_
# Gardes de --ecrire (#205, #173), anticipees (avant tout calcul) puis
# finales (avant d'ecrire) : dossier cible, arbre propre et script suivi,
# fichier cible non suivi par git (ce script n'a pas d'option --remplacer).
gardes_ecrire <- function(quand) {
  if (!dir.exists(file.path(RACINE, "docs", "tableaux"))) stop("dossier de sortie introuvable : docs/tableaux")
  nv <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT), quand)
  if (length(nv)) {
    message("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
            " -- aucun fichier ecrit")
    quit(status = 1L)
  }
  tryCatch(garde_ecrasement(CHEMIN_ECRIT, FALSE, RACINE, quitter = FALSE),
           garde_ecrasement_refus = function(e) {
             message("--ecrire refuse : ", NOM_FICHIER, " existe deja et est suivi par git, ou son suivi par git ",
                     "ne peut etre verifie (git indisponible) ; ce script ne remplace pas un tableau suivi ",
                     "-- aucun fichier ecrit")
             quit(status = 1L)
           })
  invisible(NULL)
}
if (OPT_ECRIRE) gardes_ecrire("de l'ex\u00e9cution")
COMMIT <- commit_depot(SCRIPT)
MD5_MOTEUR <- unname(tools::md5sum(file.path(RACINE, "R", "engine.R")))
ecrire_console <- function(x) writeLines(enc2utf8(x), useBytes = TRUE)

# --- Mise en forme -------------------------------------------------------------
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
num <- function(x, d = 3) if (length(x) != 1L || is.na(x)) "\u2014" else sub(".", ",", sprintf(paste0("%.", d, "f"), x), fixed = TRUE)
sci <- function(g) sub(".", ",", sprintf("%.1e", g), fixed = TRUE)
sci3 <- function(g) if (length(g) != 1L || is.na(g)) "\u2014" else sub(".", ",", sprintf("%.3e", g), fixed = TRUE)
ALPHA <- "\u03b1"
RHO <- "\u03c1"
# rho de la section 2 : deux decimales comme le 31/10 ; au-dela de -0,999,
# sans zeros finaux (-0,9999 et -0,999999 rendraient -1,00).
lib_rho_s2 <- function(r) if (r < -0.999) sub(".", ",", sub("0+$", "", sprintf("%.6f", r)), fixed = TRUE) else num(r, 2)

# --- Parametres ----------------------------------------------------------------
TS_COMPLET <- c(4:10, 12L, 15L, 20L, 30L, 50L, 100L)
TS_ESSAI <- c(4L, 5L, 8L, 100L)
TS <- if (OPT_ESSAI) TS_ESSAI else TS_COMPLET
T8 <- 8L
# Couples (T, alpha) de l'index du .tex (ligne dw_puissance_ar1()) : alpha =
# 0,10 pour tous les T de TS_COMPLET, alpha = 0,05 pour ceux-ci.
TS_INDEX_A05 <- c(5L, 8L, 12L, 20L, 30L)
couple_index <- function(T, a) a == 0.10 || (a == 0.05 && T %in% TS_INDEX_A05)
RHO_GARDE <- -1 + 1e-6   # garde de dw_puissance_ar1() : 1 - |rho| = 1e-6
RHO_1E4 <- -0.9999       # 1 - |rho| = 1e-4
RHOS_COMPLET <- c(RHO_GARDE, -0.99999, RHO_1E4, -0.999, -0.99, -0.98, -0.95, -0.9, -0.8, -0.7, -0.5, -0.3, 0)
ALPHAS <- c(0.10, 0.05)
RHOS <- if (OPT_ESSAI) c(RHO_GARDE, RHO_1E4, -0.99, 0) else RHOS_COMPLET
RHOS_PLUS <- c(1 - 1e-10, 1 - 1e-6)   # comparaisons a L+ (K421-4)
N_APPELS_LIENS <- 3L   # rho = -0,5 ; -0,3 ; -0,6 (T = 8, alpha = 0,10), controles L
N_APPELS_DETERM <- 1L  # second appel du controle D1
SEED_SIM <- 20261031   # graine du recoupement a T = 8 (31/10), engine_sous_graine()
SEED_BASE_T <- 421000000   # graine du recoupement a T != 8 : SEED_BASE_T + T (#421)
graine_T <- function(T) if (T == T8) SEED_SIM else SEED_BASE_T + T
RHOS_SIM_COMPLET <- c(0, -0.9, -0.99, RHO_1E4, RHO_GARDE)
RHOS_SIM_31_10 <- c(0, -0.9, -0.99)   # rho recoupes a T = 8 le 31/10 (#164)
RHOS_SIM <- if (OPT_ESSAI) c(0, -0.99, RHO_GARDE) else RHOS_SIM_COMPLET
N_SIM_COMPLET <- 400000L
N_SIM <- if (OPT_ESSAI) 20000L else N_SIM_COMPLET
TAILLE_BLOC <- 4e6     # normales par bloc de tirage (32 Mo par matrice)
N_S0 <- 100L           # series des controles S0
N_S1 <- 300L           # series du controle S1 par T (reparties entre les rho simules)
TOL_NIVEAU <- 1e-8     # tolerance de test_lois_exactes.R (rho = 0 rend alpha)
TOL_6DEC <- 1e-6
TOL_3DEC <- 5e-4       # demi-pas d'arrondi d'une valeur a trois decimales
TOL_RATIONNEL <- 1e-12 # DW(v_T) contre sa valeur rationnelle (avis, par. 1.4, point 4)
TOL_S0_AR1 <- 1e-10    # ar1_mat() contre R'e : arrondis de deux calculs differents
TOL_S0_DW <- 1e-12     # dw_mat() contre stat_dw() sur la meme serie
SEUIL_RANG <- 1e-10    # valeur propre de M K M comptee non nulle au-dela de 1e-10 x la plus grande
ATT_FICHE <- 0.277840  # rho = -0,5, alpha = 0,10 (test_lois_exactes.R, fiche DW, #116)
ATT_LB1 <- c("-0.3" = 0.163, "-0.6" = 0.355)   # mesure_lb1_dw_t8.R, alpha = 0,10
# Criteres de lecture (avis, par. 1.5), ecrits avant l'execution.
K1_MARGE <- 1e-6       # K421-1 : limite decidee si |m| >= 1e-6
# K421-2 (decision A2 d'actuary, actuary-questions-421.md, point 2) : p
# bilaterale binomiale exacte, seuils = queues normales de 3 et 4 ET
# (2 pnorm(-3) = 2,700e-3, 2 pnorm(-4) = 6,334e-5) ; p d'Imhof bornee.
K2_P_SIGNALE <- 2.700e-3
K2_P_DESACCORD <- 6.334e-5
K2_BORNE_P <- 1e-9     # p d'Imhof ramenee a [1e-9, 1 - 1e-9]
K2_MAX_SIGNALES <- 2L  # K421-2 : desaccord si plus de 2 comparaisons signalees
# PM-3 de K421-2 (avis, par. 1.5 : "desaccord sur un T ou un rho cite par
# le .tex"). T et rho cites par docs/latex/doc_tests_usp.tex au voisinage de
# rho = -1, releves le 27/11/2026 (tete 70cbc12) : index, dw_puissance_ar1(),
# l. 1329-1331 (T = 4 a 10, 12, 15, 20, 30, 50, 100), l. 1333 (T dans {5, 8,
# 12, 20}), l. 1338-1340 (T = 4 et 5, T = 8, rho de -1 + 1e-6 a -0,9999),
# l. 1319 (garde -1 + 1e-6), l. 1353 et fiche DW l. 9887-9892 (T = 8, grille
# des 13 rho du 31/10, recoupement a rho = 0, -0,9 et -0,99).
TS_CITES_TEX <- c(4:10, 12L, 15L, 20L, 30L, 50L, 100L)
RHOS_CITES_TEX <- c(-1 + 1e-6, -0.99999, -0.9999, -0.999, -0.99, -0.98, -0.95, -0.9, -0.8, -0.7, -0.5, -0.3, 0)
K3_REL <- 1e-3         # K421-3 : stable si ecart relatif <= 1e-3
# K421-3, garde de lecture (decision A1 d'actuary, actuary-questions-421.md,
# point 1 ; ecart a l'avis trace) : "sans objet" des que le MINIMUM des deux
# deficits |puissance - L-| est inferieur a 1e-6 (erreur absolue nominale de
# integrate() de l'ordre de 1e-10 : en deca de 1e-6, l'erreur relative
# depasse le dixieme du seuil K3_REL).
K3_PLANCHER <- 1e-6
K4_SIGNALE <- 1e-5     # K421-4 : signale au-dela de 1e-5
K4_DESACCORD <- 1e-4   # K421-4 : desaccord au-dela de 1e-4
TABLEAU_31_10 <- file.path(RACINE, "docs", "tableaux", "20261031-issue164-dw-rho-negatif.md")
# Valeurs hors garde de #170 (commentaire de dw_puissance_ar1()), citees, non reproduites.
HIST_170 <- c("1 \u2212 10^\u221212" = "0,5899253", "1 \u2212 10^\u221213" = "0,5906", "1 \u2212 10^\u221215" = "0,4755")

# Controles : data.frame cumule (id, libelle, obtenu, attendu, tolerance, ok).
CTRL <- data.frame(id = character(0), libelle = character(0), obtenu = numeric(0), attendu = numeric(0),
                   tolerance = numeric(0), ok = logical(0), stringsAsFactors = FALSE)
ctrl <- function(id, libelle, obtenu, attendu, tol) {
  ok <- length(obtenu) == 1L && is.finite(obtenu) && abs(obtenu - attendu) <= tol
  CTRL[nrow(CTRL) + 1L, ] <<- list(id, libelle, obtenu, attendu, tol, ok)
  invisible(ok)
}
cle <- function(x) vapply(x, format, "")
DUREES <- data.frame(T = TS, grille = 0, appels = 0L, limites = 0, tirage = 0, s1 = 0, appels_s1 = 0L)

###############################################################################
# 1. Grille de puissances : dw_puissance_ar1(T, rho, alpha)
###############################################################################
t_grille <- Sys.time()
PUIS <- list()
n_appels <- 0L
for (k in seq_along(TS)) {
  T_ <- TS[k]; t0 <- Sys.time()
  P <- matrix(NA_real_, length(RHOS), length(ALPHAS), dimnames = list(cle(RHOS), cle(ALPHAS)))
  for (j in seq_along(ALPHAS)) for (i in seq_along(RHOS)) P[i, j] <- dw_puissance_ar1(T_, RHOS[i], ALPHAS[j])
  PUIS[[format(T_)]] <- P
  DUREES$grille[k] <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  DUREES$appels[k] <- length(P)
  n_appels <- n_appels + length(P)
}
P8 <- PUIS[[format(T8)]]

###############################################################################
# Controles de la grille (T = 8 : ceux du 31/10 ; N pour chaque T)
###############################################################################
t_d <- Sys.time()
p_d <- dw_puissance_ar1(T8, -0.99, 0.10)
ctrl("D1", "d\u00e9terminisme : second appel de dw_puissance_ar1(8, -0,99, 0,10) contre la valeur de la grille (\u00e9cart)",
     p_d - P8[format(-0.99), format(0.10)], 0, 0)
for (T_ in TS) for (a in ALPHAS)
  ctrl(sprintf("N-T%d-a%s", T_, num(a, 2)), sprintf("niveau : puissance \u00e0 \u03c1 = 0 contre \u03b1 = %s, T = %d", num(a, 2), T_),
       PUIS[[format(T_)]][[format(0), format(a)]], a, TOL_NIVEAU)
# M, B : constats de la grille ; controles a T = 8 seul (31/10).
nb_non_croissant <- function(p) { o <- order(abs(RHOS)); sum(diff(p[o]) <= 0) }
nb_sous_alpha <- function(p, a) sum(p[RHOS < 0] <= a)
for (a in ALPHAS) {
  p <- P8[, format(a)]
  ctrl(sprintf("M-a%s", num(a, 2)),
       sprintf("constat sur la grille \u00e0 T = 8 (non garanti en g\u00e9n\u00e9ral) : paires voisines (\\|\u03c1\\| croissant, \u03c1 = 0 compris) o\u00f9 la puissance ne cro\u00eet pas, \u03b1 = %s", num(a, 2)),
       nb_non_croissant(p), 0, 0)
  ctrl(sprintf("B-a%s", num(a, 2)),
       sprintf("constat sur la grille \u00e0 T = 8 (non garanti en g\u00e9n\u00e9ral) : points \u03c1 < 0 o\u00f9 la puissance ne d\u00e9passe pas \u03b1 = %s", num(a, 2)),
       nb_sous_alpha(p, a), 0, 0)
}
# C : stabilite du coefficient deficit / (1 - |rho|)^(1/2) de 1e-4 a 1e-6 (T = 8).
coef_deficit8 <- function(r, a) (1 - P8[format(r), format(a)]) / sqrt(1 + r)
for (a in ALPHAS) {
  c4 <- coef_deficit8(RHO_1E4, a)
  ctrl(sprintf("C-a%s", num(a, 2)),
       sprintf("constat \u00e0 T = 8 : d\u00e9ficit / (1 \u2212 \\|\u03c1\\|)^\u00bd, \u03c1 = \u22121 + 10^\u22126 contre \u03c1 = \u22120,9999 (obtenu et attendu = coefficients), \u03b1 = %s ; tol\u00e9rance = 10^\u22123 en relatif",
               num(a, 2)),
       coef_deficit8(RHO_GARDE, a), c4, 1e-3 * c4)
}
# L : liens aux valeurs versionnees (T = 8, alpha = 0,10), un appel propre par point.
p_l5 <- dw_puissance_ar1(T8, -0.5, 0.10)
p_l3 <- dw_puissance_ar1(T8, -0.3, 0.10)
p_l6 <- dw_puissance_ar1(T8, -0.6, 0.10)
ctrl("L-0,5", "dw_puissance_ar1(8, -0,5, 0,10) contre 0,277840 (test_lois_exactes.R, fiche DW, #116)", p_l5, ATT_FICHE, TOL_6DEC)
ctrl("L-0,3", "dw_puissance_ar1(8, -0,3, 0,10) contre 0,163 (mesure_lb1_dw_t8.R, 20261020-mesure-lb1-dw-t8.md)", p_l3, ATT_LB1[["-0.3"]], TOL_3DEC)
ctrl("L-0,6", "dw_puissance_ar1(8, -0,6, 0,10) contre 0,355 (mesure_lb1_dw_t8.R, 20261020-mesure-lb1-dw-t8.md)", p_l6, ATT_LB1[["-0.6"]], TOL_3DEC)
n_appels <- n_appels + N_APPELS_DETERM + N_APPELS_LIENS
DUREES$grille[DUREES$T == T8] <- DUREES$grille[DUREES$T == T8] + as.numeric(difftime(Sys.time(), t_d, units = "secs"))
DUREES$appels[DUREES$T == T8] <- DUREES$appels[DUREES$T == T8] + N_APPELS_DETERM + N_APPELS_LIENS

###############################################################################
# 2. Limites : L- (rho -> -1) et L+ (rho -> 1) ; points critiques
###############################################################################
v_alt <- function(T) (-1)^seq_len(T)
dw_rationnel <- function(T) if (T %% 2L == 0L) 4 * (T - 1) / T else 4 * T / (T + 1)
lib_rationnel <- function(T) if (T %% 2L == 0L) sprintf("4(T \u2212 1)/T = %d/%d", 4L * (T - 1L), T) else sprintf("4T/(T + 1) = %d/%d", 4L * T, T + 1L)
PC <- list(); LIM <- list(); PLUS <- list()
for (k in seq_along(TS)) {
  T_ <- TS[k]; t0 <- Sys.time()
  # L- : valeur de DW et p exacte sur le vecteur alterne.
  v <- v_alt(T_); dwv <- stat_dw(v); pv <- dw_p_exacte(v)
  ctrl(sprintf("R-T%d", T_), sprintf("DW(v_T) contre sa valeur rationnelle %s, T = %d", lib_rationnel(T_), T_), dwv, dw_rationnel(T_), TOL_RATIONNEL)
  # L+ : loi limite DW(u), u ~ N(0, M K M).
  m <- .dw_matrices(T_)
  K <- -abs(outer(seq_len(T_), seq_len(T_), "-"))
  MKM <- m$M %*% K %*% m$M
  ev <- eigen((MKM + t(MKM)) / 2, symmetric = TRUE)
  rang <- sum(ev$values > SEUIL_RANG * max(ev$values))
  ctrl(sprintf("K-T%d", T_), sprintf("rang de M K M (valeurs propres > 10^\u221210 \u00d7 la plus grande) contre T \u2212 1, T = %d (K421-4, bloquant)", T_),
       rang, T_ - 1L, 0)
  S <- ev$vectors %*% diag(sqrt(pmax(ev$values, 0))) %*% t(ev$vectors)
  p_sup_lim <- function(d) {
    h <- eigen(S %*% m$M %*% (m$A - d * diag(T_)) %*% m$M %*% S, symmetric = TRUE, only.values = TRUE)$values
    mx <- max(abs(h)); hn <- if (mx > 0) h / mx else h
    .imhof_p_sup0(hn[abs(hn) > 1e-10])
  }
  PC[[format(T_)]] <- list(); LIM[[format(T_)]] <- list()
  for (a in ALPHAS) {
    pc <- points_critiques_dw(a, T_)
    PC[[format(T_)]][[format(a)]] <- pc
    marge <- pv - a
    decidee <- is.finite(marge) && abs(marge) >= K1_MARGE
    lplus <- (1 - p_sup_lim(pc[["bas"]])) + p_sup_lim(pc[["haut"]])
    LIM[[format(T_)]][[format(a)]] <- list(dwv = dwv, pv = pv, marge = marge, decidee = decidee,
                                           lmoins = if (decidee) as.numeric(pv < a) else NA_real_,
                                           lplus = lplus, rang = rang)
  }
  DUREES$limites[k] <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  # Comparaisons a L+ : dw_puissance_ar1(T, 1 - 1e-10, alpha), (T, 1 - 1e-6, alpha).
  t0 <- Sys.time()
  PLUS[[format(T_)]] <- sapply(ALPHAS, function(a) vapply(RHOS_PLUS, function(r) dw_puissance_ar1(T_, r, a), 0))
  dimnames(PLUS[[format(T_)]]) <- list(c("1-1e-10", "1-1e-6"), cle(ALPHAS))
  DUREES$grille[k] <- DUREES$grille[k] + as.numeric(difftime(Sys.time(), t0, units = "secs"))
  DUREES$appels[k] <- DUREES$appels[k] + length(RHOS_PLUS) * length(ALPHAS)
  n_appels <- n_appels + length(RHOS_PLUS) * length(ALPHAS)
}
n_lplus_nf <- sum(vapply(TS, function(T_) sum(!vapply(ALPHAS, function(a) is.finite(LIM[[format(T_)]][[format(a)]]$lplus), TRUE)), 0))
ctrl("L+", "valeurs L+ non finies (int\u00e9gration d'Imhof en \u00e9chec), tous les (T, \u03b1)", n_lplus_nf, 0, 0)
lim_moins <- function(T_, a) LIM[[format(T_)]][[format(a)]]$lmoins

###############################################################################
# 3. Recoupement par simulation (independant d'Imhof pour l'alternative)
###############################################################################
# Frequences de rejet par rho et alpha sur N series, tirees par blocs dans le
# flux engine_sous_graine(graine) ; garde les N_GARDE premieres lignes
# d'innovations (premier bloc) pour S0 et S1.
n_s1 <- N_S1 %/% length(RHOS_SIM)
N_GARDE <- max(N_S0, n_s1)
simuler_T <- function(T_, graine, pc) {
  nb <- max(1L, min(N_SIM, as.integer(TAILLE_BLOC %/% T_)))
  engine_sous_graine(graine, {
    rej <- matrix(0, length(RHOS_SIM), length(ALPHAS)); reste <- N_SIM; E_garde <- NULL; nblocs <- 0L
    while (reste > 0L) {
      n <- min(nb, reste)
      E <- matrix(stats::rnorm(n * T_), n, T_)
      if (is.null(E_garde)) E_garde <- E[seq_len(min(N_GARDE, n)), , drop = FALSE]
      for (i in seq_along(RHOS_SIM)) {
        x <- dw_mat(ar1_mat(E, RHOS_SIM[i]))
        for (j in seq_along(ALPHAS))
          rej[i, j] <- rej[i, j] + sum(x <= pc[[j]][["bas"]] | x >= pc[[j]][["haut"]])
      }
      reste <- reste - n; nblocs <- nblocs + 1L
    }
    list(rej = rej, freq = rej / N_SIM, E_garde = E_garde, nblocs = nblocs, taille = nb)
  })
}
# Serie de reference des controles S0 (#421, point 4) : z = R'e, R =
# chol(Sigma), Sigma = (rho^|i-j|), sur les lignes de E (une serie par ligne :
# E R), construite sans ar1_mat().
ar1_chol <- function(E, rho) E %*% chol(outer(seq_len(ncol(E)), seq_len(ncol(E)), function(i, j) rho^abs(i - j)))
SIM <- NULL; BLOCS <- list()
for (k in seq_along(TS)) {
  T_ <- TS[k]; pc <- PC[[format(T_)]]
  t0 <- Sys.time()
  r_sim <- simuler_T(T_, graine_T(T_), lapply(ALPHAS, function(a) pc[[format(a)]]))
  DUREES$tirage[k] <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  BLOCS[[format(T_)]] <- c(nblocs = r_sim$nblocs, taille = r_sim$taille)
  # S0 : ar1_mat() et dw_mat() contre la serie de reference R'e, rho simules non nuls.
  E0 <- r_sim$E_garde[seq_len(N_S0), , drop = FALSE]
  e_ar1 <- e_dw <- 0
  for (r in RHOS_SIM[RHOS_SIM != 0]) {
    Zref <- ar1_chol(E0, r)
    e_ar1 <- max(e_ar1, abs(ar1_mat(E0, r) - Zref))
    e_dw <- max(e_dw, abs(dw_mat(Zref) - apply(Zref, 1L, stat_dw)))
  }
  rs <- paste(vapply(RHOS_SIM[RHOS_SIM != 0], lib_rho_s2, ""), collapse = " ; ")
  ctrl(sprintf("S0-ar1-T%d", T_), sprintf("ar1_mat() contre la s\u00e9rie de r\u00e9f\u00e9rence z = R'e (R = chol(\u03a3), sans ar1_mat()), T = %d, \u03c1 \u2208 {%s}, %d s\u00e9ries (\u00e9cart max)", T_, rs, N_S0),
       e_ar1, 0, TOL_S0_AR1)
  ctrl(sprintf("S0-dw-T%d", T_), sprintf("statistique DW matricielle dw_mat() contre stat_dw() du moteur sur z = R'e, T = %d, \u03c1 \u2208 {%s}, %d s\u00e9ries (\u00e9cart max)", T_, rs, N_S0),
       e_dw, 0, TOL_S0_DW)
  # S1 : region critique contre dw_p_exacte() < alpha ; dw_p_exacte() une fois par serie.
  t0 <- Sys.time()
  desacc <- stats::setNames(integer(length(ALPHAS)), cle(ALPHAS))
  for (r in RHOS_SIM) {
    Z1 <- ar1_mat(r_sim$E_garde[seq_len(n_s1), , drop = FALSE], r)
    d1 <- dw_mat(Z1)
    for (i in seq_len(n_s1)) {
      p_ex <- dw_p_exacte(Z1[i, ])
      for (a in ALPHAS) {
        d <- pc[[format(a)]]
        if (!identical(d1[i] <= d[["bas"]] || d1[i] >= d[["haut"]], p_ex < a)) desacc[[format(a)]] <- desacc[[format(a)]] + 1L
      }
    }
  }
  DUREES$s1[k] <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  DUREES$appels_s1[k] <- n_s1 * length(RHOS_SIM)
  for (a in ALPHAS)
    ctrl(sprintf("S1-T%d-a%s", T_, num(a, 2)),
         sprintf("r\u00e9gion critique de DW contre dw_p_exacte() < \u03b1 = %s, T = %d, %d s\u00e9ries \u00d7 %d \u03c1 (d\u00e9saccords)", num(a, 2), T_, n_s1, length(RHOS_SIM)),
         desacc[[format(a)]], 0, 0)
  # Frequences simulees contre Imhof (grille) : K421-2.
  for (i in seq_along(RHOS_SIM)) for (j in seq_along(ALPHAS)) {
    r <- RHOS_SIM[i]; a <- ALPHAS[j]
    imhof <- PUIS[[format(T_)]][[format(r), format(a)]]
    sim <- r_sim$freq[i, j]; p1 <- pmin(imhof, 1); se <- sqrt(p1 * (1 - p1) / N_SIM)
    z <- if (se > 0) (sim - imhof) / se else if (sim == imhof) 0 else Inf
    # p bilaterale binomiale exacte (decision A2) : X ~ B(N_SIM, p0), p0 borne.
    x <- r_sim$rej[i, j]; p0 <- min(max(imhof, K2_BORNE_P), 1 - K2_BORNE_P)
    p_bin <- min(1, 2 * min(stats::pbinom(x, N_SIM, p0), stats::pbinom(x - 1, N_SIM, p0, lower.tail = FALSE)))
    SIM <- rbind(SIM, data.frame(T = T_, rho = r, alpha = a, imhof = imhof, sim = sim, se = se, z = z, p_bin = p_bin))
  }
}
SIM$signale <- SIM$p_bin < K2_P_SIGNALE
SIM$desaccord <- SIM$p_bin < K2_P_DESACCORD
# Cellule ou la valeur d'Imhof atteint la borne haute de p0 (1 - 1e-9, Imhof
# egal a 1 tronque) : un desaccord s'y lit "simulation ou quadrature" (Q10,
# actuary-questions-420-367.md : l'erreur de integrate() est estimee, non
# bornee).
SIM$tronquee <- SIM$imhof >= 1 - K2_BORNE_P
SIM$cite <- SIM$T %in% TS_CITES_TEX | SIM$rho %in% RHOS_CITES_TEX
INTEGRITE <- all(CTRL$ok)

###############################################################################
# Sortie
###############################################################################
sortie <- character(0)
ajouter <- function(...) sortie <<- c(sortie, ...)
# Cellules d'une ligne (avant mise en forme markdown) : servent a K421-5.
lib_rho <- function(r) if (r == 0) "0 (contr\u00f4le de niveau)" else if (r < -0.999) sub(".", ",", sub("0+$", "", sprintf("%.6f", r)), fixed = TRUE) else num(r, 3)
cellules_s1 <- function(T_, i) {
  P <- PUIS[[format(T_)]]
  c(lib_rho(RHOS[i]), if (RHOS[i] == 0) "\u2014" else sci(1 + RHOS[i]),
    unlist(lapply(seq_along(ALPHAS), function(j) c(num(P[i, j], 4), num(1 - P[i, j], 4)))))
}
coef_limite <- function(T_, r, a) {
  L <- lim_moins(T_, a)
  if (is.na(L)) NA_real_ else abs(PUIS[[format(T_)]][[format(r), format(a)]] - L) / sqrt(1 + r)
}
cellules_s1bis <- function(T_, i)
  c(lib_rho(RHOS[i]), sci(1 + RHOS[i]), vapply(ALPHAS, function(a) num(coef_limite(T_, RHOS[i], a), 4), ""))
origine_s2 <- function(T_, r) if (T_ != T8) "#421" else if (r %in% RHOS_SIM_31_10) "31/10 (#164)" else "ajout\u00e9e (#421)"
cellules_s2 <- function(l) with(l, c(lib_rho_s2(rho), num(alpha, 2), num(imhof, 5), sprintf("%s \u00b1 %s", num(sim, 5), num(se, 5)),
                                     num(sim - imhof, 5), num(z, 2)))
lecture_s2 <- function(l) if (l$desaccord) "d\u00e9saccord (p < 6,334e-5)" else if (l$signale) "signal\u00e9 (p < 2,700e-3)" else "p \u2265 2,700e-3"
# Ligne markdown d'une table : barres verticales des cellules echappees
# (\|), sauf celles qui le sont deja.
md <- function(cel) paste0("| ", paste(gsub("(?<!\\\\)\\|", "\\\\|", cel, perl = TRUE), collapse = " | "), " |")

texte_essai <- if (OPT_ESSAI) c(paste0("**Essai (--essai) : non versionnable.** T \u2208 {", paste(TS_ESSAI, collapse = " ; "),
                                        "}, grille r\u00e9duite (\u03c1 \u2208 {\u22121 + 10^\u22126 ; \u22120,9999 ; \u22120,99 ; 0}), deux seuils ; l'ex\u00e9cution compl\u00e8te porte sur ",
                                        length(TS_COMPLET), " valeurs de T, ", length(RHOS_COMPLET), " valeurs de \u03c1 et 2 seuils. Recoupement par simulation r\u00e9duit \u00e0 \u03c1 \u2208 {0 ; \u22120,99 ; \u22121 + 10^\u22126}, N = ",
                                        format(N_SIM, scientific = FALSE), " (ex\u00e9cution compl\u00e8te : \u03c1 \u2208 {0 ; \u22120,9 ; \u22120,99 ; \u22120,9999 ; \u22121 + 10^\u22126}, N = ",
                                        format(N_SIM_COMPLET, scientific = FALSE), ")."), "")
ajouter("## Puissance du test de Durbin-Watson contre un AR(1) au voisinage de \u03c1 = \u00b11 : T = 8 (#164) et T de 4 \u00e0 100 (#421)", "",
        texte_essai,
        paste0("Statut : (a) puissance : quantit\u00e9 exacte \u00e9valu\u00e9e par quadrature num\u00e9rique (int\u00e9grale d'Imhof) et uniroot() (points critiques), sans tirage ; erreur num\u00e9rique de quadrature et de uniroot(), non born\u00e9e a priori, v\u00e9rifi\u00e9e sans \u00eatre born\u00e9e par le niveau \u00e0 \u03c1 = 0 (contr\u00f4le N), par l'accord des points critiques avec dw_p_exacte() (contr\u00f4le S1, m\u00eame quadrature) et par le recoupement par simulation (section 2) \u00e0 ",
               if (OPT_ESSAI) "\u03c1 \u2208 {0 ; \u22120,99 ; \u22121 + 10^\u22126} (essai)" else "\u03c1 \u2208 {0 ; \u22120,9 ; \u22120,99 ; \u22120,9999 ; \u22121 + 10^\u22126}",
               " seulement, pour chaque T ; (b) L\u208b : r\u00e9sultat exact (L\u208b = 1{dw_p_exacte(v_T) < \u03b1} d\u00e8s que dw_p_exacte(v_T) \u2260 \u03b1, v_T vecteur altern\u00e9), dont la valeur pour un T donn\u00e9 d\u00e9pend du signe d'une marge \u00e9valu\u00e9e par quadrature ; (c) L\u208a : loi limite exacte, valeur \u00e9valu\u00e9e par Imhof (approximation num\u00e9rique d'une quantit\u00e9 exacte) ; (d) loi en (1 \u2212 |\u03c1|)^\u00bd : constat num\u00e9rique, non d\u00e9montr\u00e9 ; (e) recoupement : constat de simulation. Loi de DW sous H0 pour z i.i.d. N(0,1), puissance sous un AR(1) stationnaire, alternative hors mod\u00e8le r\u00e9glementaire (l'annexe XVII suppose des ann\u00e9es ind\u00e9pendantes ; l'AR(1) est une alternative choisie) ; z n'est pas le vecteur de r\u00e9sidus r\u00e9ajust\u00e9s du moteur ; \u03c1 \u2192 \u00b11 borne le domaine num\u00e9rique de l'outil `dw_puissance_ar1()`, non la puissance utile du test. La grille d'Imhof et les limites sont d\u00e9terministes ; seul le recoupement tire, sous des graines consign\u00e9es en T0."), "",
        "Cadre : z gaussien centr\u00e9, i.i.d. N(0,1) sous H0, AR(1) stationnaire de matrice de covariance (\u03c1^|i\u2212j|) sous l'alternative ; sans r\u00e9ajustement ; statistique calcul\u00e9e sur la s\u00e9rie centr\u00e9e. Test bilat\u00e9ral exact de `dw_p_exacte()` (p = 2 min(P0(DW \u2264 d), P0(DW \u2265 d)), rejet si p < \u03b1), puissance par `dw_puissance_ar1(T, \u03c1, \u03b1)`. Variante \u00e0 d\u00e9part nul : non calcul\u00e9e (`dw_puissance_ar1()` ne porte que l'AR(1) stationnaire). Couples (T, \u03b1) de l'index du document : \u03b1 = 0,10 pour tous les T de 4 \u00e0 100 ci-dessous, \u03b1 = 0,05 pour T \u2208 {5 ; 8 ; 12 ; 20 ; 30} ; les autres couples sont mesur\u00e9s en plus (avis d'actuary de l'\u00e9tape 1 de S9, \u00a7 1.4).", "")

# Section 1 : une table par T, colonnes du tableau du 31/10.
cols_a <- unlist(lapply(ALPHAS, function(a) c(sprintf("Puissance (%s = %s)", ALPHA, num(a, 2)), "1 \u2212 puissance")))
ajouter("### 1. Puissance de DW par \u03c1", "",
        paste0("\u00ab 1 \u2212 puissance \u00bb : d\u00e9ficit de puissance, la quantit\u00e9 qui tend vers 0 quand \u03c1 \u2192 \u22121 si L\u208b = 1 (section 3). Le moteur refuse \u03c1 < \u22121 + 10^\u22126 (garde de `dw_puissance_ar1()`) ; le point le plus proche de \u22121 de la grille, \u03c1 = \u22121 + 10^\u22126, est la garde elle-m\u00eame (1 \u2212 |\u03c1| = 10^\u22126, admis)."), "")
for (T_ in TS)
  ajouter(sprintf("#### T = %d", T_), "", entete_md(c(RHO, "1 \u2212 \\|\u03c1\\|", cols_a)),
          vapply(seq_along(RHOS), function(i) md(cellules_s1(T_, i)), ""), "")
# Section 1 bis : ecart a la limite rapporte a (1 - |rho|)^(1/2).
neg <- which(RHOS < 0)
ajouter("### 1 bis. \u00c9cart \u00e0 la limite rapport\u00e9 \u00e0 (1 \u2212 |\u03c1|)^\u00bd", "",
        paste0("Coefficient = |puissance \u2212 L\u208b| / (1 \u2212 |\u03c1|)^\u00bd, 1 \u2212 |\u03c1| lu comme 1 + \u03c1, L\u208b de la section 3 (\u00ab \u2014 \u00bb si L\u208b est ind\u00e9cidable) ; quand L\u208b = 1, c'est le d\u00e9ficit rapport\u00e9 (1 \u2212 puissance) / (1 \u2212 |\u03c1|)^\u00bd du tableau du 31/10. Mesure pour \u03c1 < 0 de la grille, hors recoupement par simulation. La loi en (1 \u2212 |\u03c1|)^\u00bd est un constat num\u00e9rique (K421-3, section 4), non d\u00e9montr\u00e9. Au-del\u00e0 de la garde, non \u00e9valu\u00e9 ici."), "")
for (T_ in TS)
  ajouter(sprintf("#### T = %d", T_), "",
          entete_md(c(RHO, "1 \u2212 \\|\u03c1\\|", unlist(lapply(ALPHAS, function(a) sprintf("\\|puissance \u2212 L\u208b\\| / (1 \u2212 \\|\u03c1\\|)^\u00bd (%s = %s)", ALPHA, num(a, 2)))))),
          vapply(neg, function(i) md(cellules_s1bis(T_, i)), ""), "")
# Section 1 ter : constats de forme de la grille par T (controles a T = 8 seul).
ajouter("### 1 ter. Forme de la grille par T (constats)", "",
        "Nombre de paires voisines de la grille (|\u03c1| croissant, \u03c1 = 0 compris) o\u00f9 la puissance ne cro\u00eet pas, et nombre de points \u03c1 < 0 o\u00f9 elle ne d\u00e9passe pas \u03b1. Constats sur la grille, non garantis en g\u00e9n\u00e9ral ; contr\u00f4les (M, B) \u00e0 T = 8 seul, comme le 31/10.", "",
        entete_md(c("T", unlist(lapply(ALPHAS, function(a) c(sprintf("Paires non croissantes (%s = %s)", ALPHA, num(a, 2)), sprintf("Points \u03c1 < 0 sous %s (%s = %s)", ALPHA, ALPHA, num(a, 2))))))),
        vapply(TS, function(T_) md(c(T_, unlist(lapply(ALPHAS, function(a) {
          p <- PUIS[[format(T_)]][, format(a)]; c(nb_non_croissant(p), nb_sous_alpha(p, a)) })))), ""), "")

# Section 2 : recoupement par simulation, une table par T.
n_neg <- sum(SIM$sim - SIM$imhof < 0)
ajouter("### 2. Recoupement par simulation (ind\u00e9pendant d'Imhof pour l'alternative)", "",
        sprintf("N = %s s\u00e9ries AR(1) stationnaires par \u03c1 et par T (z_1 = e_1, z_t = \u03c1 z_{t\u22121} + \u221a(1 \u2212 \u03c1\u00b2) e_t, m\u00eames innovations pour tous les \u03c1 d'un m\u00eame T), g\u00e9n\u00e9rateur %s, une graine par T sous `engine_sous_graine()` : %s \u00e0 T = 8 (graine du 31/10, flux inchang\u00e9), %s + T sinon ; tirage par blocs de min(N, \u230a%s / T\u230b) lignes dans le flux de chaque T (un seul bloc pour T \u2264 10). Statistique DW sur la s\u00e9rie centr\u00e9e (formule matricielle, contr\u00f4les S0 contre une s\u00e9rie construite sans la r\u00e9currence et contre `stat_dw()`) ; points critiques bilat\u00e9raux de la loi nulle exacte (copie d\u00e9clar\u00e9e du calcul de `dw_puissance_ar1()`, contr\u00f4le S1 contre `dw_p_exacte()`). Erreur-type ET = sqrt(p(1 \u2212 p)/N) avec p = min(valeur d'Imhof de la grille, 1) (ET au plus %s ici). \u03c1 = 0 : niveau (valeur de r\u00e9f\u00e9rence \u03b1, \u00e0 la pr\u00e9cision du contr\u00f4le N). Lecture K421-2 (d\u00e9cision d'actuary du 27/11/2026, traduction exacte du crit\u00e8re de 3 et 4 ET) : p bilat\u00e9rale binomiale exacte 2 min(P(X \u2264 x), P(X \u2265 x)), X ~ B(N, p0), p0 = valeur d'Imhof born\u00e9e \u00e0 [10^\u22129, 1 \u2212 10^\u22129], born\u00e9e \u00e0 1 ; signal\u00e9 si p < 2,700e-3, d\u00e9saccord si p < 6,334e-5 ; la colonne en erreurs-types (ET calcul\u00e9e sur min(Imhof, 1)) est rapport\u00e9e pour la lecture. Constat : %d \u00e9cart(s) simul\u00e9 \u2212 Imhof n\u00e9gatif(s) sur %d ; les innovations sont communes \u00e0 tous les \u03c1 d'un m\u00eame T et les deux seuils reposent sur les m\u00eames s\u00e9ries, donc les comparaisons d'un m\u00eame T sont corr\u00e9l\u00e9es et ne se lisent pas comme des \u00e9vidences ind\u00e9pendantes. Colonne \u00ab Origine \u00bb : ligne du tableau du 31/10, ligne ajout\u00e9e \u00e0 T = 8, ou ligne nouvelle (#421).",
                format(N_SIM, scientific = FALSE), paste(ENGINE_RNG_KIND, collapse = ", "), format(SEED_SIM, scientific = FALSE),
                format(SEED_BASE_T, scientific = FALSE), format(TAILLE_BLOC, scientific = FALSE), sci(max(SIM$se)), n_neg, nrow(SIM)), "")
for (T_ in TS) {
  s <- SIM[SIM$T == T_, ]
  ajouter(sprintf("#### T = %d", T_), "",
          entete_md(c(RHO, ALPHA, "Imhof (grille)", "Simul\u00e9 \u00b1 erreur-type", "Simul\u00e9 \u2212 Imhof", "\u00c9cart en erreurs-types", "p binomiale exacte", "Lecture K421-2", "Origine")),
          vapply(seq_len(nrow(s)), function(i) md(c(cellules_s2(s[i, ]), sci3(s$p_bin[i]), lecture_s2(s[i, ]), origine_s2(T_, s$rho[i]))), ""), "")
}

# Section 3 : limites.
lib_L <- function(x) if (is.na(x)) "ind\u00e9cidable" else format(x)
ajouter("### 3. Limites quand \u03c1 \u2192 \u22121 (L\u208b) et quand \u03c1 \u2192 1 (L\u208a)", "",
        paste0("L\u208b : v_T = ((\u22121)^t), t = 1..T ; DW(v_T) contre sa valeur rationnelle (contr\u00f4le R) ; p_v = dw_p_exacte(v_T) ; marge m = p_v \u2212 \u03b1 ; L\u208b = 1{p_v < \u03b1}, d\u00e9cid\u00e9e si |m| \u2265 10^\u22126 (K421-1), r\u00e9sultat exact dont la valeur d\u00e9pend du signe de m, \u00e9valu\u00e9 par quadrature. ",
               "L\u208a : P(DW(u) \u2209 [d_bas, d_haut]), u ~ N(0, M K M), K = (\u2212|i \u2212 j|), M projecteur de centrage, par Imhof (approximation num\u00e9rique d'une quantit\u00e9 exacte), sans franchir la garde ; rang de M K M contr\u00f4l\u00e9 (contr\u00f4le K, T \u2212 1 attendu) ; compar\u00e9e \u00e0 `dw_puissance_ar1(T, 1 \u2212 10^\u221210, \u03b1)` (K421-4) et \u00e0 `dw_puissance_ar1(T, 1 \u2212 10^\u22126, \u03b1)` (rapport\u00e9e). ",
               "Colonne \u00ab Index \u00bb : couple (T, \u03b1) cit\u00e9 par l'index du document."), "",
        entete_md(c("T", ALPHA, "Index", "DW(v_T)", "Valeur rationnelle", "p_v = dw_p_exacte(v_T)", "m = p_v \u2212 \u03b1", "L\u208b", "Rang de M K M",
                    "L\u208a (Imhof sous M K M)", "P(1 \u2212 10^\u221210)", "P(1 \u2212 10^\u221210) \u2212 L\u208a", "P(1 \u2212 10^\u22126)", "P(1 \u2212 10^\u22126) \u2212 L\u208a")),
        unlist(lapply(TS, function(T_) vapply(ALPHAS, function(a) {
          l <- LIM[[format(T_)]][[format(a)]]; pl <- PLUS[[format(T_)]]
          p10 <- pl[["1-1e-10", format(a)]]; p6 <- pl[["1-1e-6", format(a)]]
          md(c(T_, num(a, 2), if (couple_index(T_, a)) "oui" else "non", num(l$dwv, 7), lib_rationnel(T_), sci3(l$pv), sci3(l$marge),
               lib_L(l$lmoins), l$rang, num(l$lplus, 7), num(p10, 7), sci3(p10 - l$lplus), num(p6, 7), sci3(p6 - l$lplus)))
        }, ""))), "",
        sprintf("Valeurs historiques de #170 (T = 8, \u03b1 = 0,10, commentaire de `dw_puissance_ar1()`) : %s, hors du domaine de la fonction actuelle (\u03c1 \u2264 1 \u2212 10^\u221210), **non reproduites** (aucune copie du calcul sans garde ; avis d'actuary de l'\u00e9tape 1 de S9, \u00a7 1.3) : elles mesurent la d\u00e9faillance d'un calcul abandonn\u00e9, non une propri\u00e9t\u00e9 du test. La limite cit\u00e9e par ce commentaire (0,5899175) est la valeur L\u208a(8 ; 0,10) ci-dessus%s.",
                paste(sprintf("%s \u00e0 \u03c1 = %s", HIST_170, names(HIST_170)), collapse = ", "),
                if (T8 %in% TS) sprintf(", ici %s", num(LIM[[format(T8)]][[format(0.10)]]$lplus, 7)) else ""), "")

###############################################################################
# 4. Lecture automatique des criteres K421-1 a K421-5
###############################################################################
# K421-1
k1 <- do.call(rbind, lapply(TS, function(T_) do.call(rbind, lapply(ALPHAS, function(a) {
  l <- LIM[[format(T_)]][[format(a)]]
  data.frame(T = T_, alpha = a, decidee = l$decidee, L = l$lmoins, marge = l$marge)
}))))
L4 <- if (4L %in% TS) k1$L[k1$T == 4L & k1$alpha == 0.10] else NA
L5 <- if (5L %in% TS) k1$L[k1$T == 5L & k1$alpha == 0.05] else NA
k1_verdict <- if (is.na(L4) && !(4L %in% TS) || is.na(L5) && !(5L %in% TS)) "non \u00e9valu\u00e9 (T = 4 ou T = 5 absent de l'ex\u00e9cution)" else
  if (isTRUE(L4 == 0) && isTRUE(L5 == 0)) "L\u208b(4 ; 0,10) = 0 et L\u208b(5 ; 0,05) = 0, d\u00e9cid\u00e9es : le document peut remplacer \u00ab hypoth\u00e8se non v\u00e9rifi\u00e9e \u00bb par ce r\u00e9sultat" else
    "**PM-3** : L\u208b(4 ; 0,10) ou L\u208b(5 ; 0,05) n'est pas 0 d\u00e9cid\u00e9"
# K421-2
n_cmp <- nrow(SIM); n_sig <- sum(SIM$signale); n_des <- sum(SIM$desaccord)
k2_desaccord <- n_des > 0L || n_sig > K2_MAX_SIGNALES
lib_cellule <- function(l) sprintf("T = %d, \u03c1 = %s, \u03b1 = %s (p = %s, %s ET%s%s)", l$T, lib_rho_s2(l$rho), num(l$alpha, 2), sci3(l$p_bin), num(l$z, 2),
                                   if (l$cite) ", T ou \u03c1 cit\u00e9 par le document" else "",
                                   if (l$tronquee) ", Imhof \u00e9gal \u00e0 1 tronqu\u00e9" else "")
sig <- SIM[SIM$signale, ]
k2_liste <- if (nrow(sig)) paste(vapply(seq_len(nrow(sig)), function(i) lib_cellule(sig[i, ]), ""), collapse = " ; ") else "aucune"
k2_verdict <- if (!k2_desaccord) sprintf("accord : %d comparaison(s) signal\u00e9e(s) sur %d (au plus %d admises), aucune en d\u00e9saccord (p < 6,334e-5)", n_sig, n_cmp, K2_MAX_SIGNALES) else
  sprintf("**d\u00e9saccord** : %d comparaison(s) en d\u00e9saccord (p < 6,334e-5), %d signal\u00e9e(s) (p < 2,700e-3) sur %d%s", n_des, n_sig, n_cmp,
          paste0(if (any(SIM$cite & (SIM$desaccord | (n_sig > K2_MAX_SIGNALES & SIM$signale)))) " ; porte sur un T ou un \u03c1 cit\u00e9 par le document : **PM-3**" else " ; sur aucun T ni \u03c1 cit\u00e9 par le document",
                 # Q10 : desaccord dans une cellule ou Imhof vaut 1 tronque
                 if (any(SIM$desaccord & SIM$tronquee))
                   sprintf(paste0(" ; %d d\u00e9saccord(s) dans une cellule o\u00f9 Imhof vaut 1 tronqu\u00e9 (p0 = 1 \u2212 10^\u22129) : \u00e0 lire \u00ab simulation ou quadrature \u00bb",
                                  " (l'erreur de `integrate()` est estim\u00e9e, non born\u00e9e), non comme un d\u00e9faut de la simulation"), sum(SIM$desaccord & SIM$tronquee)) else ""))
# Mineur 2 de l'audit leger de 6d7295e : TS_CITES_TEX couvre tous les T de
# l'execution, le filtre "T cite" est alors toujours vrai ; dit en clair.
k2_couverture <- if (all(TS %in% TS_CITES_TEX))
  " ; TS_CITES_TEX couvre tous les T de l'ex\u00e9cution : tout d\u00e9saccord porte sur un T cit\u00e9 par le document et rel\u00e8ve de PM-3" else ""
# K421-3
k3 <- do.call(rbind, lapply(TS, function(T_) do.call(rbind, lapply(ALPHAS, function(a) {
  c4 <- coef_limite(T_, RHO_1E4, a); c6 <- coef_limite(T_, RHO_GARDE, a)
  L <- lim_moins(T_, a); P <- PUIS[[format(T_)]]
  sous_plancher <- !is.na(L) && min(abs(P[c(format(RHO_1E4), format(RHO_GARDE)), format(a)] - L)) < K3_PLANCHER
  rel <- if (is.finite(c4) && c4 > 0 && !sous_plancher) abs(c6 - c4) / c4 else NA_real_
  data.frame(T = T_, alpha = a, c4 = c4, c6 = c6, rel = rel,
             lecture = if (sous_plancher) "sans objet (min des deux |puissance \u2212 L\u208b| < 10^\u22126 : rapport illisible \u00e0 la pr\u00e9cision de la quadrature)" else
               if (is.na(rel)) "sans objet (L\u208b ind\u00e9cidable ou coefficient nul)" else if (rel <= K3_REL) "stable" else
               "r\u00e9gime asymptotique non atteint dans le domaine gard\u00e9 (constat, pas un \u00e9chec)", stringsAsFactors = FALSE)
}))))
# K421-4
k4 <- do.call(rbind, lapply(TS, function(T_) do.call(rbind, lapply(ALPHAS, function(a) {
  e <- abs(PLUS[[format(T_)]][["1-1e-10", format(a)]] - LIM[[format(T_)]][[format(a)]]$lplus)
  data.frame(T = T_, alpha = a, ecart = e,
             lecture = if (!is.finite(e)) "non \u00e9valuable" else if (e > K4_DESACCORD) "d\u00e9saccord (> 10^\u22124)" else if (e > K4_SIGNALE) "signal\u00e9 (> 10^\u22125)" else "\u2264 10^\u22125",
             stringsAsFactors = FALSE)
}))))
k4_rang_ok <- all(CTRL$ok[grepl("^K-T", CTRL$id)])
# K421-5 : lignes de T = 8 contre le tableau du 31/10.
lire_lignes_section <- function(l, titre) {
  i0 <- which(startsWith(l, titre))
  if (length(i0) != 1L) return(NULL)
  fin <- which(startsWith(l, "### ") & seq_along(l) > i0)
  i1 <- if (length(fin)) min(fin) - 1L else length(l)
  bloc <- l[(i0 + 1L):i1]
  lignes <- bloc[startsWith(bloc, "| ")]
  lignes <- lignes[-(1:2)]   # en-tete et separateur
  lapply(lignes, function(x) strsplit(sub("^\\| ", "", sub(" \\|$", "", x)), " | ", fixed = TRUE)[[1]])
}
comparer_31_10 <- function() {
  if (!(T8 %in% TS)) return(list(ok = FALSE, verdict = "**non \u00e9valu\u00e9** (T = 8 absent)", detail = character(0)))
  if (!file.exists(TABLEAU_31_10)) return(list(ok = FALSE, verdict = "**non \u00e9valuable** : tableau du 31/10 introuvable", detail = character(0)))
  l <- enc2utf8(readLines(TABLEAU_31_10, encoding = "UTF-8", warn = FALSE))
  sections <- list(
    list(titre = "### 1. ", nom = "section 1", cle = 1L,
         neuves = lapply(seq_along(RHOS), function(i) cellules_s1(T8, i))),
    list(titre = "### 1 bis. ", nom = "section 1 bis", cle = 1L,
         neuves = lapply(neg, function(i) cellules_s1bis(T8, i))))
  if (!OPT_ESSAI) {
    s8 <- SIM[SIM$T == T8, ]
    sections[[3]] <- list(titre = "### 2. ", nom = "section 2", cle = 1:2,
                          neuves = lapply(seq_len(nrow(s8)), function(i) cellules_s2(s8[i, ])))
  }
  n_cmp5 <- 0L; n_diff <- 0L; n_abs <- 0L; detail <- character(0)
  for (s in sections) {
    anciennes <- lire_lignes_section(l, s$titre)
    if (is.null(anciennes)) { detail <- c(detail, sprintf("%s : introuvable dans le tableau du 31/10", s$nom)); n_diff <- n_diff + 1L; next }
    cles_neuves <- vapply(s$neuves, function(x) paste(x[s$cle], collapse = " | "), "")
    for (a in anciennes) {
      k <- match(paste(a[s$cle], collapse = " | "), cles_neuves)
      if (is.na(k)) { if (!OPT_ESSAI) { n_abs <- n_abs + 1L; detail <- c(detail, sprintf("%s : ligne %s absente", s$nom, paste(a[s$cle], collapse = " ; "))) }; next }
      n_cmp5 <- n_cmp5 + 1L
      nv <- s$neuves[[k]]
      if (length(nv) < length(a) || !identical(enc2utf8(nv[seq_along(a)]), a)) {
        n_diff <- n_diff + 1L
        detail <- c(detail, sprintf("%s, ligne %s : %s au lieu de %s", s$nom, paste(a[s$cle], collapse = " ; "),
                                    paste(nv, collapse = " | "), paste(a, collapse = " | ")))
      }
    }
  }
  list(ok = n_diff == 0L && n_abs == 0L && n_cmp5 > 0L,
       verdict = if (n_diff == 0L && n_abs == 0L && n_cmp5 > 0L) sprintf("identiques : %d ligne(s) de T = 8 compar\u00e9e(s) cellule par cellule au tableau du 31/10%s", n_cmp5,
                                                         if (OPT_ESSAI) " (essai : lignes pr\u00e9sentes des sections 1 et 1 bis seules)" else "")
                 else sprintf("**diff\u00e9rences** : %d ligne(s) diff\u00e9rente(s), %d absente(s), sur %d compar\u00e9e(s) : --ecrire refus\u00e9, code de sortie 1", n_diff, n_abs, n_cmp5),
       detail = detail)
}
k5 <- comparer_31_10()
SORTIE_OK <- INTEGRITE && isTRUE(k5$ok)   # K421-5 bloquant (critere d'acceptation de l'etape 2)

ajouter("### 4. Lecture des crit\u00e8res K421-1 \u00e0 K421-5", "",
        "Crit\u00e8res de l'avis d'actuary de l'\u00e9tape 1 de S9 (\u00a7 1.5), \u00e9crits avant toute ex\u00e9cution de ce script ; lecture automatique. K421-1 \u00e0 K421-4 sont sans effet sur le code de sortie (un crit\u00e8re non tenu est un r\u00e9sultat \u00e0 lire, PM-3, non une d\u00e9faillance du script) ; K421-5, crit\u00e8re d'acceptation de l'\u00e9tape 2 de S9, est bloquant (--ecrire refus\u00e9, code de sortie 1).", "",
        entete_md(c("Crit\u00e8re", "Lecture")),
        md(c("K421-1 (limite \u03c1 \u2192 \u22121)", sprintf("%s ; %d couple(s) d\u00e9cid\u00e9(s) sur %d ; L\u208b = 0 pour %s ; ind\u00e9cidables : %s", k1_verdict, sum(k1$decidee), nrow(k1),
                                                 { z0 <- k1[k1$decidee & k1$L == 0, ]; if (nrow(z0)) paste(sprintf("(%d ; %s)", z0$T, vapply(z0$alpha, num, "", d = 2)), collapse = ", ") else "aucun couple" },
                                                 { u <- k1[!k1$decidee, ]; if (nrow(u)) paste(sprintf("(%d ; %s), m = %s", u$T, vapply(u$alpha, num, "", d = 2), vapply(u$marge, sci3, "")), collapse = ", ") else "aucun" }))),
        md(c("K421-2 (pr\u00e9cision, simul\u00e9 contre Imhof)", sprintf("%s ; cellules signal\u00e9es : %s%s", k2_verdict, k2_liste, k2_couverture))),
        md(c("K421-3 (vitesse, constat)", sprintf("%d couple(s) stable(s), %d en r\u00e9gime asymptotique non atteint dans le domaine gard\u00e9, %d sans objet (d\u00e9tail ci-dessous)",
                                                    sum(k3$lecture == "stable"), sum(startsWith(k3$lecture, "r\u00e9gime")), sum(startsWith(k3$lecture, "sans objet"))))),
        md(c("K421-4 (\u03c1 \u2192 1)", sprintf("%s ; |P(1 \u2212 10^\u221210) \u2212 L\u208a| : %d \u2264 10^\u22125, %d signal\u00e9(s), %d d\u00e9saccord(s) ; \u00e9cart max %s",
                                             if (k4_rang_ok) "rang T \u2212 1 de M K M v\u00e9rifi\u00e9 pour tout T (contr\u00f4les K)" else "**rang de M K M en d\u00e9faut (contr\u00f4le K bloquant)**",
                                             sum(k4$lecture == "\u2264 10^\u22125"), sum(startsWith(k4$lecture, "signal")), sum(startsWith(k4$lecture, "d\u00e9saccord")), sci3(max(k4$ecart))))),
        md(c("K421-5 (non-r\u00e9gression \u00e0 T = 8)", k5$verdict)), "",
        if (length(k5$detail)) c("D\u00e9tail de K421-5 :", "", paste0("- ", k5$detail), "") else character(0),
        "K421-3, d\u00e9tail : coefficient |puissance \u2212 L\u208b| / (1 \u2212 |\u03c1|)^\u00bd \u00e0 1 \u2212 |\u03c1| = 10^\u22124 (\u03c1 = \u22120,9999) et 10^\u22126 (garde) ; stable si l'\u00e9cart relatif est \u2264 10^\u22123. Garde de lecture (d\u00e9cision d'actuary du 27/11/2026, \u00e9cart \u00e0 l'avis trac\u00e9) : \u00ab sans objet \u00bb si le minimum des deux |puissance \u2212 L\u208b| est inf\u00e9rieur \u00e0 10^\u22126 (erreur absolue nominale de la quadrature de l'ordre de 10^\u221210).", "",
        entete_md(c("T", ALPHA, "Coefficient \u00e0 10^\u22124", "Coefficient \u00e0 10^\u22126", "\u00c9cart relatif", "Lecture")),
        vapply(seq_len(nrow(k3)), function(i) with(k3[i, ], md(c(T, num(alpha, 2), num(c4, 4), num(c6, 4), sci3(rel), lecture))), ""), "",
        "K421-4, d\u00e9tail : |dw_puissance_ar1(T, 1 \u2212 10^\u221210, \u03b1) \u2212 L\u208a|, signal\u00e9 au-del\u00e0 de 10^\u22125, d\u00e9saccord au-del\u00e0 de 10^\u22124.", "",
        entete_md(c("T", ALPHA, "\u00c9cart", "Lecture")),
        vapply(seq_len(nrow(k4)), function(i) with(k4[i, ], md(c(T, num(alpha, 2), sci3(ecart), lecture))), ""), "")

fmt_ctrl <- function(g) if (abs(g) < 1e-3 && g != 0) sci(g) else num(g, 6)
ajouter("### Contr\u00f4les", "",
        entete_md(c("Id", "Contr\u00f4le", "Obtenu", "Attendu", "\u00c9cart", "Tol\u00e9rance", "Statut")),
        vapply(seq_len(nrow(CTRL)), function(i) with(CTRL[i, ], ligne_md(id, libelle, fmt_ctrl(obtenu), fmt_ctrl(attendu),
                                                              fmt_ctrl(obtenu - attendu), fmt_ctrl(tolerance), if (ok) "OK" else "**\u00c9CHEC**")), ""),
        "", sprintf("%d contr\u00f4les, %d en \u00e9chec.", nrow(CTRL), sum(!CTRL$ok)), "")

# Duree estimee d'une execution complete (--essai, M39) : part fixe (de
# l'ouverture du script au debut de la grille) + par T de l'execution
# complete, duree par appel de dw_puissance_ar1(), duree des limites et
# duree par appel de dw_p_exacte() (S1), interpolees lineairement en T entre
# les T de l'essai (constantes au-dela), multipliees par les nombres
# d'appels complets + recoupement proportionnel a N x T x (1 + nombre de rho)
# (tirage, recurrence et statistique) ; extrapolation.
duree_fixe <- as.numeric(difftime(t_grille, t_debut, units = "secs"))
interp <- function(y) stats::approx(DUREES$T, y, xout = TS_COMPLET, rule = 2)$y
appels_complets <- length(RHOS_COMPLET) * length(ALPHAS) + length(RHOS_PLUS) * length(ALPHAS) +
  ifelse(TS_COMPLET == T8, N_APPELS_DETERM + N_APPELS_LIENS, 0L)
d_grille <- sum(interp(DUREES$grille / DUREES$appels) * appels_complets)
d_limites <- sum(interp(DUREES$limites))
d_s1 <- sum(interp(DUREES$s1 / DUREES$appels_s1) * (N_S1 %/% length(RHOS_SIM_COMPLET)) * length(RHOS_SIM_COMPLET))
cout_unitaire_sim <- sum(DUREES$tirage) / sum(N_SIM * DUREES$T * (1 + length(RHOS_SIM)))
d_sim <- cout_unitaire_sim * sum(N_SIM_COMPLET * TS_COMPLET * (1 + length(RHOS_SIM_COMPLET)))
duree_estimee <- duree_fixe + d_grille + d_limites + d_s1 + d_sim
LIB_DUREE <- "Dur\u00e9e estim\u00e9e d'une ex\u00e9cution compl\u00e8te (--essai)"

T0 <- c("### T0", "",
        entete_md(c("Grandeur", "Valeur")),
        ligne_md("Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)", plateforme_calcul()),
        ligne_md("Al\u00e9a", sprintf("recoupement simul\u00e9 seul : engine_sous_graine(graine_T), g\u00e9n\u00e9rateur %s ; graine_T = %s \u00e0 T = 8, %s + T sinon (%s) ; grille d'Imhof et limites sans al\u00e9a",
                                      paste(ENGINE_RNG_KIND, collapse = ", "), format(SEED_SIM, scientific = FALSE), format(SEED_BASE_T, scientific = FALSE),
                                      paste(sprintf("T = %d : %s", TS, vapply(TS, function(T_) format(graine_T(T_), scientific = FALSE), "")), collapse = ", "))),
        ligne_md("N (s\u00e9ries simul\u00e9es par \u03c1 et par T)", format(N_SIM, scientific = FALSE)),
        ligne_md("Tirage par blocs (normales par bloc au plus ; blocs par T)", sprintf("%s ; %s", format(TAILLE_BLOC, scientific = FALSE),
                                                                                      paste(sprintf("T = %d : %d \u00d7 %d lignes", TS, vapply(BLOCS, `[[`, 0, "nblocs"), vapply(BLOCS, `[[`, 0, "taille")), collapse = ", "))),
        ligne_md("Commit (HEAD)", COMMIT),
        ligne_md("md5 de R/engine.R", MD5_MOTEUR),
        ligne_md("Empreintes du code (script ex\u00e9cut\u00e9, outils charg\u00e9s)", empreintes_code(SCRIPT)),
        ligne_md("Appels de dw_puissance_ar1()", sprintf("%d (grille : %d ; \u03c1 \u2192 1 : %d ; contr\u00f4les : %d)", n_appels,
                                                           length(TS) * length(RHOS) * length(ALPHAS), length(TS) * length(RHOS_PLUS) * length(ALPHAS),
                                                           N_APPELS_DETERM + N_APPELS_LIENS)),
        if (OPT_ESSAI) ligne_md(LIB_DUREE, sprintf("%.0f s (part fixe %.1f s + appels de dw_puissance_ar1() %.1f s + limites %.1f s + S1 %.1f s + recoupement %.1f s ; extrapolation des T = %s et de N = %s)",
                                                    duree_estimee, duree_fixe, d_grille, d_limites, d_s1, d_sim, paste(TS, collapse = ", "),
                                                    format(N_SIM, scientific = FALSE))),
        ligne_md("Script", sprintf("%s%s (hors CI ; protocole dans l'en-t\u00eate)", SCRIPT,
                                   if (OPT_ECRIRE) sprintf(" --ecrire --issue %s", OPT_ISSUE) else if (OPT_ESSAI) " --essai" else "")),
        "")

duree <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
ecrire_console(c(sortie, T0, sprintf("Dur\u00e9e totale : %.1f s.", duree)))

if (OPT_ECRIRE) {
  if (!INTEGRITE) {
    message("--ecrire : contr\u00f4les en \u00e9chec, aucun fichier \u00e9crit")
  } else if (!isTRUE(k5$ok)) {
    message("--ecrire refuse : K421-5 non tenu (lignes de T = 8 differentes du tableau du 31/10, absentes, ou tableau introuvable) -- aucun fichier ecrit")
  } else {
    gardes_ecrire("\u00e0 l'\u00e9criture")
    con <- file(CHEMIN_ECRIT, open = "wb")
    writeLines(enc2utf8(c(sortie, T0)), con, useBytes = TRUE)
    close(con)
    message("\u00e9crit : ", CHEMIN_ECRIT)
  }
}
if (!isTRUE(k5$ok)) message("K421-5 non tenu : ", k5$verdict)
quit(status = if (SORTIE_OK) 0L else 1L)
